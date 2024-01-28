# SPDX-License-Identifier: MIT

export ComputePackageVerificationCode, ComputeFileChecksum

function determine_checksum_algorithm(algorithm::AbstractString)
    # Check to see if algorithm is in the list of support algorithms, unsupported algorithms, or not recognized
    # TODO: substitute "_" for "-" and other things to account for user typos
    supported_algorithms= Set(["SHA1", "SHA224", "SHA256", "SHA384", "SHA512", "SHA3-256", "SHA3-384", "SHA3-512"])
    unsupported_algorithms= Set(["BLAKE2b-256", "BLAKE2b-384", "BLAKE2b-512", "BLAKE3", "MD2", "MD4", "MD5", "MD6", "ADLER32"])
    algorithm= strip(algorithm)

    issubset(Set([algorithm]), unsupported_algorithms) && error("checksum(): The hash algorithm $(algorithm) is not supported by SPDX.jl")
    issubset(Set([algorithm]), supported_algorithms) || error("checksum(): algorithm $(algorithm) is not recognized")

    HashFunction=   (algorithm == "SHA1")     ? sha1 :
                    (algorithm == "SHA224")   ? sha224 :
                    (algorithm == "SHA256")   ? sha256 :
                    (algorithm == "SHA384")   ? sha384 :
                    (algorithm == "SHA512")   ? sha512 :
                    (algorithm == "SHA3-256") ? sha3_256 :
                    (algorithm == "SHA3-384") ? sha3_384 :
                                                sha3_512

    return HashFunction
end


###############################
function spdxverifcode(rootdir::AbstractString, excluded_flist::Vector{<:AbstractString}, excluded_dirlist::Vector{<:AbstractString}, excluded_patterns::Vector{Regex})
    ignored_files= String[]
    flist_hash::Vector{String}= [file_hash(file, sha1) for file in getpackagefiles(rootdir, excluded_flist, excluded_dirlist, excluded_patterns, ignored_files)]
    flist_hash= sort(flist_hash)
    combined_hashes= join(flist_hash)
    return (sha1(combined_hashes), ignored_files)
end


###############################
file_hash(fpath::AbstractString, HashFunction::Function)=   open(fpath) do f
                                                                hash= HashFunction(f)
                                                                @logmsg Logging.LogLevel(-100) "$(string(HashFunction))($fpath)= $(bytes2hex(hash))"
                                                                return bytes2hex(hash)
                                                            end


###############################
function getpackagefiles(rootdir, excluded_flist, excluded_dirlist, excluded_patterns, ignored_files)
    return Channel{String}(chnl -> _getpackagefiles(chnl, rootdir, excluded_flist, excluded_dirlist, excluded_patterns, ignored_files))
end

function _getpackagefiles(chnl, root::AbstractString, excluded_flist::Vector{<:AbstractString}, excluded_dirlist::Vector{<:AbstractString}, excluded_patterns::Vector{Regex}, ignored_files::Vector{String})
    # On first call of this function put an absolute path on root and exclusion lists
    isabspath(root) || (root= abspath(root))
    all(isabspath.(excluded_flist)) || (excluded_flist= normpath.(joinpath.(root, excluded_flist)))
    all(isabspath.(excluded_dirlist)) || (excluded_dirlist= normpath.(joinpath.(root, excluded_dirlist)))

    content = readdir(root, join= true)
    content === nothing && return
    # TODO: Optional code for parsing .gitignore files. Will I need Glob.jl for that?
    #       Would need to search content to find the .gitignore so that it's contents can be applied to excluded_patterns before processing
    #       Would need to make a copy of the excluded_patterns so that additions are not passed back up to the caller.
    for path in content
        if isdir(path)
            if any(excluded_dirlist .== path)
                continue # Skip over exluded directories
            elseif islink(path)
                push!(ignored_files, path)
                continue # Skip over exluded directories
            else
                _getpackagefiles(chnl, path, excluded_flist, excluded_dirlist, excluded_patterns, ignored_files) # Descend into the directory and get the files there
            end
        elseif any(excluded_flist .== path)
            push!(ignored_files, path)
            continue # Skip over excluded files
        elseif any(occursin.(excluded_patterns, path))
            continue # Skip files that match one of the excluded patterns
        elseif islink(path)
            push!(ignored_files, path) # Any link that passes the previous checks is a part of the deployed code and it's exclusion from the computation needs to be noted 
            continue
        else
            push!(chnl, path) # Put the file path in the channel
        end
    end
    return nothing
end


###############################
function ComputePackageVerificationCode(rootdir::AbstractString, excluded_flist::Vector{<:AbstractString}= String[], excluded_dirlist::Vector{<:AbstractString}= String[], excluded_patterns::Vector{Regex}=Regex[])
    @logmsg Logging.LogLevel(-50) "Computing Verification Code at: $rootdir" excluded_flist= excluded_flist excluded_dirlist= excluded_dirlist excluded_patterns= excluded_patterns
    package_hash, ignored_files= spdxverifcode(rootdir, excluded_flist, excluded_dirlist, excluded_patterns)
    ignored_files= relpath.(ignored_files, rootdir)
    verif_code= SpdxPkgVerificationCodeV2(bytes2hex(package_hash), ignored_files)
    @logmsg Logging.LogLevel(-50) string(verif_code)
    return verif_code
end


###############################
function ComputeFileChecksum(algorithm::AbstractString, filepath::AbstractString)
    @logmsg Logging.LogLevel(-50) "Computing File Checksum on $filepath"
    HashFunction= determine_checksum_algorithm(algorithm)
    fhash= file_hash(filepath, HashFunction)
    checksum_obj= SpdxChecksumV2(algorithm, fhash)
    @logmsg Logging.LogLevel(-50) string(checksum_obj)
    return checksum_obj
end