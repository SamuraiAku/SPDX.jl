
convert_to_JSON(dataElement::AbstractSpdx, unused::Nothing)= string(dataElement)
convert_to_JSON(data, unused)= data # For Bool, Int, etc.

function convert_to_JSON(doc::Union{AbstractSpdxData, AbstractSpdxElement}, NameTable::Table)
    jsonDoc= OrderedDict{String, Any}()
    for idx in range(1,length= length(NameTable))
        fieldval= getproperty(doc, NameTable.Symbol[idx])
        (ismissing(fieldval) || (isa(fieldval, Vector) && isempty(fieldval))) && continue  # goto next symbol if this one has no data
        isnothing(fieldval) && error("Field " * string(NameTable.Symbol[idx]) * "== nothing")  # This should not happen, but check just in case
        
        if isa(fieldval, Vector)
            elementVector= Vector{Any}()
            for element in fieldval
                push!(elementVector, convert_to_JSON(element, NameTable.NameTable[idx]))
            end
            jsonDoc[NameTable.JSONname[idx]]= elementVector
        else
            jsonDoc[NameTable.JSONname[idx]]= convert_to_JSON(fieldval, NameTable.NameTable[idx])
        end
    end

    compute_additional_JSON_fields!(jsonDoc, doc)
    return jsonDoc
end

#########################
compute_additional_JSON_fields!(jsonDoc, doc)= nothing

# These fields are derived from the document contents
function compute_additional_JSON_fields!(jsonDoc::OrderedDict{String, Any}, doc::SpdxDocumentV2)
    docDescribes= Vector{String}()
    describedidx= Vector{Int}()

    pkgIDs= Tuple(getproperty.(doc.Packages, :SPDXID))
    fileIDs= Tuple(getproperty.(doc.Files, :SPDXID))
    hasFiles= Tuple([Vector{String}() for i= 1:length(pkgIDs)])
    hasFilesidx= Vector{Int}()

    for idx in 1:length(jsonDoc["relationships"])
        if jsonDoc["relationships"][idx]["relationshipType"] == "DESCRIBES" && jsonDoc["relationships"][idx]["spdxElementId"] == "SPDXRef-DOCUMENT" 
            push!(docDescribes, jsonDoc["relationships"][idx]["relatedSpdxElement"])
            push!(describedidx, idx)
        elseif jsonDoc["relationships"][idx]["relationshipType"] == "DESCRIBED_BY" && jsonDoc["relationships"][idx]["spdxElementId"] == "SPDXRef-DOCUMENT"
            push!(docDescribes, jsonDoc["relationships"][idx]["spdxElementId"])
            push!(describedidx, idx)
        end

        if (doc.Relationships[idx].RelationshipType == "CONTAINS") && ((p_idx= findfirst(isequal(doc.Relationships[idx].SPDXID), pkgIDs)) != nothing) && ((f_idx= findfirst(isequal(doc.Relationships[idx].RelatedSPDXID), fileIDs)) != nothing)
            push!(hasFiles[p_idx], fileIDs[f_idx])
            push!(hasFilesidx, idx)
        end
    end
    
    if !isempty(docDescribes)
        jsonDoc["documentDescribes"]= docDescribes
    end

    for idx in 1:length(hasFiles)
        if !isempty(hasFiles[idx])
            jsonDoc["packages"][idx]["hasFiles"]= hasFiles[idx]
        end
    end

    deleteat!(jsonDoc["relationships"], sort(union(describedidx, hasFilesidx)))
end
