# SPDX-License-Identifier: MIT

function checksum(algorithm::AbstractString, rootdir::AbstractString, excluded_flist::Vector{<:AbstractString}= String[], excluded_dirlist::Vector{<:AbstractString}= String[], excluded_patterns::Vector{Regex}=Regex[])
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

    package_hash::Vector{UInt8}= package_sha(HashFunction, HashContext, rootdir, excluded_flist, excluded_dirlist, excluded_patterns)

    return package_hash
end

function package_sha(HashFunction::Function, HashContext::DataType, rootdir::AbstractString, excluded_flist::Vector{<:AbstractString}, excluded_dirlist::Vector{<:AbstractString}, excluded_patterns::Vector{Regex})
    flist_hash::Vector{Vector{UInt8}}= [file_hash(file, HashFunction) for file in getpackagefiles(rootdir, excluded_dirlist, excluded_flist, excluded_patterns)]
    flist_hash= sort(flist_hash)

    ctx= HashContext()
    for hash in flist_hash
        SHA.update!(ctx, hash)
    end

    return SHA.digest!(ctx)
end

file_hash(fpath::AbstractString, HashFunction::Function)=   open(fpath) do f
                                                                return HashFunction(f)
                                                            end

###############################
function getpackagefiles(rootdir::AbstractString, excluded_flist::Vector{<:AbstractString}, excluded_dirlist::Vector{<:AbstractString}, excluded_patterns::Vector{Regex})
    return Channel{String}(chnl -> _getpackagefiles(chnl, rootdir, excluded_flist, excluded_dirlist, excluded_patterns))
end

# I want flist and dirlist to match the whole path. How to best make that work??
function _getpackagefiles(chnl, root::AbstractString, excluded_flist::Vector{<:AbstractString}, excluded_dirlist::Vector{<:AbstractString}, excluded_patterns::Vector{Regex})
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
            else
                _getpackagefiles(chnl, path, excluded_flist, excluded_dirlist, excluded_patterns) # Descend into the directory and get the files there
            end
        elseif any(excluded_flist .== path)
            continue # Skip over excluded files
        elseif any(occursin.(excluded_patterns, path))
            continue # Skip files that match one of the excluded patterns
        else
            push!(chnl, path) # Put the file path in the channel
        end
    end
    return nothing
end