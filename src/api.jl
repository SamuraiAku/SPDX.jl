#########################
function printJSON(doc::SpdxDocumentV2, fname::AbstractString)
    open(fname, "w") do f
        jsonDoc= convert_to_JSON(doc)
        JSON.print(f, jsonDoc, 4)
    end
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
