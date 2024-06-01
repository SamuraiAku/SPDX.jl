# SPDX-License-Identifier: MIT

export createnamespace!, updatenamespace!
export addcreator!, getcreators, deletecreator!, setcreationtime!
export readspdx, writespdx

########################
function printJSON(io::IO, doc::SpdxDocumentV2)
    jsonDoc= convert_to_JSON(doc, SpdxDocumentV2_NameTable)
    JSON.print(io, jsonDoc, 4)
    return nothing
end

#########################
function printTagValue(io::IO, doc::SpdxDocumentV2)
    convert_doc_to_TagValue!(io, doc, SpdxDocumentV2_NameTable)
    return nothing
end

#########################
function readJSON(io::IO)
    JSONfile= JSON.parse(io)
    doc= convert_from_JSON(JSONfile, SpdxDocumentV2_NameTable, SpdxDocumentV2)
    return doc
end

#########################
function readTagValue(io::IO)
    doc= parse_TagValue(io, SpdxDocumentV2_NameTable, SpdxDocumentV2)
    return doc
end

#########################
function readspdx(io::IO; format::AbstractString)
    doc= if format == "JSON"
        readJSON(io)
    elseif format == "TagValue"
        readTagValue(io)
    else
        error("Specified Format ", format, " is not supported")
    end

    return doc
end

function readspdx(fname::AbstractString; format::Union{AbstractString, Nothing}=nothing)
    if isnothing(format)
        fext= last(splitext(fname))
        format= if fext == ".json"
            "JSON"
        elseif fext == ".spdx"
            "TagValue"
        else
            error("File format ", fext, " is not supported")
        end
    end

    doc= open(fname) do io
        readspdx(io; format)
    end

    return doc
end

#########################
function writespdx(io::IO, doc::SpdxDocumentV2; format::AbstractString)
    if format == "JSON"
        printJSON(io, doc)
    elseif format == "TagValue"
        printTagValue(io, doc)
    else
        error("Specified Format ", format, " is not supported")
    end
end

function writespdx(doc::SpdxDocumentV2, fname::AbstractString; format::Union{AbstractString, Nothing}=nothing)
    if isnothing(format)
        fext= last(splitext(fname))
        format= if fext == ".json"
            "JSON"
        elseif fext == ".spdx"
            "TagValue"
        else
            error("File format ", fext, " is not supported")
        end
    end

    open(fname, "w") do io
        writespdx(io, doc; format)
    end
end

#########################
function setcreationtime!(doc::SpdxDocumentV2, CreationTime::Union{ZonedDateTime, DateTime}= now(localzone()) )
    doc.CreationInfo.Created= SpdxTimeV2(CreationTime)
end

#########################
function createnamespace!(doc::SpdxDocumentV2, URI::AbstractString)
    doc.Namespace= SpdxNamespaceV2(URI, string(uuid4()) )
end

function updatenamespace!(doc::SpdxDocumentV2)
    if doc.Namespace === missing
        error("Namespace is not set.  Please use createnamespace!()")
    elseif doc.Namespace.UUID === nothing
        error("UUID not set in namespace. Unable to update")
    else
        createnamespace!(doc, doc.Namespace.URI)
    end
end

#########################
function addcreator!(doc::SpdxDocumentV2, CreatorType::AbstractString, Name::AbstractString, Email::AbstractString= ""; validate= true)
    push!(doc.CreationInfo.Creator, SpdxCreatorV2(CreatorType, Name, Email, validate= validate))
end

function deletecreator!(doc::SpdxDocumentV2, creator::SpdxCreatorV2)
    filter!(x -> x!= creator, doc.CreationInfo.Creator)
end

function getcreators(doc::SpdxDocumentV2)
    return deepcopy(doc.CreationInfo.Creator)
end

#########################
for pred in (:(==), :(isequal))
    @eval function Base.$pred(x::AbstractSpdx, y::AbstractSpdx)
        return all(f -> $pred(getproperty(x, f), getproperty(y, f)), fieldnames(typeof(x)))
    end
end

#########################
_hash(A, h::UInt; skipproperties)= hash(A, h) # Ignore skipproperties if it's not AbstractSpdx

function _hash(A::AbstractSpdx, h::UInt; skipproperties::Vector{Symbol}= Symbol[])
    propset= setdiff(propertynames(A), skipproperties)
    for p in propset
        h= hash(getproperty(A, p), h)
    end
    return h
end

function Base.hash(A::AbstractSpdx, h::UInt)
    return _hash(A, h)
end
