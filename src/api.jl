#########################
function printJSON(doc::SpdxDocumentV2, fname::AbstractString)
    open(fname, "w") do f
        jsonDoc= convert_to_JSON(doc)
        JSON.print(f, jsonDoc, 4)
    end
end

#########################
function setcreationtime(doc::SpdxDocumentV2, CreationTime::ZonedDateTime= now(localzone()))
    doc.CreationInfo.Created= SpdxTimeV2(CreationTime)
end

function setcreationtime(doc::SpdxDocumentV2, CreationTime::DateTime)
    doc.CreationInfo.Created= SpdxTimeV2(CreationTime)
end
