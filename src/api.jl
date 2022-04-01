# SPDX-License-Identifier: MIT

########################
function printJSON(doc::SpdxDocumentV2, fname::AbstractString)
    open(fname, "w") do f
        jsonDoc= convert_to_JSON(doc, SpdxDocumentV2_NameTable)
        JSON.print(f, jsonDoc, 4)
    end
end

#########################
function printTagValue(doc::SpdxDocumentV2, fname::AbstractString)
    TagValueDoc= IOBuffer()
    open(fname, "w") do f
        convert_doc_to_TagValue!(TagValueDoc, doc, SpdxDocumentV2_NameTable)
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
function readTagValue(fname::AbstractString)
    doc= nothing
    open(fname) do TVfile
        doc= parse_TagValue(TVfile, SpdxDocumentV2_NameTable, SpdxDocumentV2)
    end
    return doc
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
