#########################
function printJSON(doc::SpdxDocumentV2, fname::AbstractString)
    open(fname, "w") do f
        jsonDoc= convert_to_JSON(doc)
        JSON.print(f, jsonDoc, 4)
    end
end

#########################
function printTagValue(doc::SpdxDocumentV2, fname::AbstractString)
    TagValueDoc= IOBuffer()
    open(fname, "w") do f
        convert_to_TagValue!(TagValueDoc, doc)
        write(f, take!(TagValueDoc))
    end
    return nothing
end

#########################
function readJSON(fname::AbstractString)
    JSONfile= JSON.parsefile(fname)
    doc= convert_from_JSON(JSONfile, SpdxDocumentV2_NameTable, SpdxDocumentV2)
    return doc
end

#########################
function setcreationtime!(doc::SpdxDocumentV2, CreationTime::Union{ZonedDateTime, DateTime}= now(localzone()) )
    doc.CreationInfo.Created= SpdxTimeV2(CreationTime)
end

#########################
function setnamespace!(doc::SpdxDocumentV2, URI::String)
    doc.Namespace= SpdxNamespaceV2(URI)
end

function updatenamespace!(doc::SpdxDocumentV2)
    if doc.Namespace === missing
        error("Namespace is not set.  Please use setnamespace!()")
    else
        setnamespace!(doc, doc.Namespace.URI::String)
    end
end

#########################
function addcreator!(doc::SpdxDocumentV2, CreatorType::String, Name::String, Email::String= ""; validate= true)
    push!(doc.CreationInfo.Creator, SpdxCreatorV2(CreatorType, Name, Email, validate= validate))
end

function deletecreator!(doc::SpdxDocumentV2, creator::SpdxCreatorV2)
    filter!(x -> x!= creator, doc.CreationInfo.Creator)
end

function getcreators(doc::SpdxDocumentV2)
    return deepcopy(doc.CreationInfo.Creator)
end
