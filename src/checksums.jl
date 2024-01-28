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

    HashFunction, HashContext= (algorithm == "SHA1")     ? (sha1,     SHA1_CTX) :
                               (algorithm == "SHA224")   ? (sha224,   SHA224_CTX) :
                               (algorithm == "SHA256")   ? (sha256,   SHA256_CTX) :
                               (algorithm == "SHA384")   ? (sha384,   SHA384_CTX) :
                               (algorithm == "SHA512")   ? (sha512,   SHA256_CTX) :
                               (algorithm == "SHA3-256") ? (sha3_256, SHA3_256_CTX) :
                               (algorithm == "SHA3-384") ? (sha3_384, SHA3_384_CTX) :
                                                           (sha3_512, SHA3_512_CTX)

    return (HashFunction, HashContext)
end

function spdxchecksum_sha(HashFunction::Function, HashContext::DataType, rootdir::AbstractString, excluded_flist::Vector{<:AbstractString}, excluded_dirlist::Vector{<:AbstractString}, excluded_patterns::Vector{Regex})
    ignored_files= String[]
    flist_hash::Vector{Vector{UInt8}}= [file_hash(file, HashFunction) for file in getpackagefiles(rootdir, excluded_flist, excluded_dirlist, excluded_patterns, ignored_files)]
    flist_hash= sort(flist_hash)

    ctx= HashContext()
    for hash in flist_hash
        SHA.update!(ctx, hash)
    end

    return (SHA.digest!(ctx), ignored_files)
end

file_hash(fpath::AbstractString, HashFunction::Function)=   open(fpath) do f
                                                                hash= HashFunction(f)
                                                                @logmsg Logging.LogLevel(-100) "$(string(HashFunction))($fpath)= $(bytes2hex(hash))"
                                                                return hash
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
    package_hash, ignored_files= spdxchecksum_sha(sha1, SHA1_CTX, rootdir, excluded_flist, excluded_dirlist, excluded_patterns)
    ignored_files= relpath.(ignored_files, rootdir)
    verif_code= SpdxPkgVerificationCodeV2(bytes2hex(package_hash), ignored_files)
    @logmsg Logging.LogLevel(-50) string(verif_code)
    return verif_code
end


###############################
function ComputeFileChecksum(algorithm::AbstractString, filepath::AbstractString)
    @logmsg Logging.LogLevel(-50) "Computing File Checksum on $filepath"
    HashFunction, HashContext= determine_checksum_algorithm(algorithm)
    fhash= file_hash(filepath, HashFunction)
    return SpdxChecksumV2(algorithm, bytes2hex(fhash))
end