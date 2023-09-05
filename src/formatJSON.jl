# SPDX-License-Identifier: MIT

convert_to_JSON(dataElement::AbstractSpdx, unused::Nothing)= string(dataElement)
convert_to_JSON(data, unused)= data # For Bool, Int, etc.

function convert_to_JSON(doc::Union{AbstractSpdxData, AbstractSpdxElement}, NameTable::Spdx_NameTable)
    jsonDoc= OrderedDict{String, Any}()
    for idx in eachindex(NameTable.Symbol)
        fieldval= getproperty(doc, NameTable.Symbol[idx])
        (ismissing(fieldval) || (isa(fieldval, Vector) && isempty(fieldval))) && continue  # goto next symbol if this one has no data
        isnothing(fieldval) && error("Field " * string(NameTable.Symbol[idx]) * "== nothing")  # This should not happen, but check just in case
        fieldnametable= eval(NameTable.NameTable[idx]::Symbol)

        if isa(fieldval, Vector)
            elementVector= Vector{Any}()
            for element in fieldval
                push!(elementVector, convert_to_JSON(element, fieldnametable))
            end
            jsonDoc[NameTable.JSONname[idx]]= elementVector
        else
            jsonDoc[NameTable.JSONname[idx]]= convert_to_JSON(fieldval, fieldnametable)
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

    relationships::Vector{SpdxRelationshipV2}= doc.Relationships
    for idx in eachindex(relationships)
        if relationships[idx].RelationshipType == "DESCRIBES" && relationships[idx].SPDXID == "SPDXRef-DOCUMENT" 
            push!(docDescribes, relationships[idx].RelatedSPDXID)
            push!(describedidx, idx)
        elseif relationships[idx].RelationshipType == "DESCRIBED_BY" && relationships[idx].RelatedSPDXID == "SPDXRef-DOCUMENT"
            push!(docDescribes, relationships[idx].SPDXID)
            push!(describedidx, idx)
        end

        if (relationships[idx].RelationshipType == "CONTAINS") && ((p_idx= findfirst(isequal(relationships[idx].SPDXID), pkgIDs)) != nothing) && ((f_idx= findfirst(isequal(relationships[idx].RelatedSPDXID), fileIDs)) != nothing)
            push!(hasFiles[p_idx], fileIDs[f_idx])
            push!(hasFilesidx, idx)
        end
    end
    
    if !isempty(docDescribes)
        jsonDoc["documentDescribes"]= docDescribes
    end

    for idx in eachindex(hasFiles)
        if !isempty(hasFiles[idx])
            jsonDoc["packages"][idx]["hasFiles"]= hasFiles[idx]
        end
    end

    !isempty(relationships) && deleteat!(jsonDoc["relationships"], sort(union(describedidx, hasFilesidx)))
end
