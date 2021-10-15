
function convert_to_JSON(doc::AbstractSpdxData, NameTable::Table)
    jsonDoc= OrderedDict{String, Any}()
    for idx in range(1,length= length(NameTable))
        fieldval= getproperty(doc, NameTable[idx].Symbol)
        (ismissing(fieldval) || (isa(fieldval, Vector) && isempty(fieldval))) && continue  # goto next symbol if this one has no data
        isnothing(fieldval) && error("Field " * string(NameTable[idx].Symbol) * "== nothing")  # This should not happen, but check just in case
        
        if isa(fieldval, Vector)
            elementVector= Vector{Any}()
            for element in fieldval
                push!(elementVector, convert_to_JSON(element))
            end
            jsonDoc[NameTable[idx].JSONname]= elementVector
        else
            jsonDoc[NameTable[idx].JSONname]= convert_to_JSON(fieldval)
        end
    end
    return jsonDoc
end

convert_to_JSON(doc::SpdxDocumentV2)= convert_to_JSON(doc, SpdxDocumentV2_NameTable)
convert_to_JSON(pkg::SpdxPackageV2) = convert_to_JSON(pkg, SpdxPackageV2_NameTable)
convert_to_JSON(info::SpdxCreationInfoV2)= convert_to_JSON(info, SpdxCreationInfoV2_NameTable)

convert_to_JSON(dataElement::AbstractSpdx)= string(dataElement)
convert_to_JSON(stringElement::String)= stringElement