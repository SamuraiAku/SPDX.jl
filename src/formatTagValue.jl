

convert_to_TagValue!(TagValueDoc::IOBuffer, dataElement::Union{AbstractSpdx, AbstractSpdxElement})= write(TagValueDoc, string(dataElement) * "\n")  # Default
convert_to_TagValue!(TagValueDoc::IOBuffer, stringElement::String)= write(TagValueDoc, stringElement * "\n")

function convert_to_TagValue!(TagValueDoc::IOBuffer, doc::AbstractSpdxData, NameTable::Table)
    for idx in range(1,length= length(NameTable))
        fieldval= getproperty(doc, NameTable[idx].Symbol)
        (ismissing(fieldval) || (isa(fieldval, Vector) && isempty(fieldval))) && continue  # goto next symbol if this one has no data
        isnothing(fieldval) && error("Field " * string(NameTable[idx].Symbol) * "== nothing")  # This should not happen, but check just in case

        if isa(fieldval, Vector)
            for element in fieldval
                if NameTable[idx].TagValueName !== nothing
                    write(TagValueDoc, NameTable[idx].TagValueName * ":  ")
                    if NameTable[idx].Multiline == true
                        write(TagValueDoc, "<text>")
                    end
                end
                convert_to_TagValue!(TagValueDoc, element)
                if NameTable[idx].Multiline == true
                    write(TagValueDoc, "    </text>\n")
                end
            end
        else
            if NameTable[idx].TagValueName !== nothing
                write(TagValueDoc, NameTable[idx].TagValueName * ":  ")
                if NameTable[idx].Multiline == true
                    write(TagValueDoc, "<text>")
                end
            end
            convert_to_TagValue!(TagValueDoc, fieldval)
            if NameTable[idx].Multiline == true
                write(TagValueDoc, "    </text>\n")
            end
        end
    end
    write(TagValueDoc, "\n\n####\n")
end

convert_to_TagValue!(TagValueDoc::IOBuffer, doc::SpdxDocumentV2)= convert_to_TagValue!(TagValueDoc, doc, SpdxDocumentV2_NameTable)
convert_to_TagValue!(TagValueDoc::IOBuffer, pkg::SpdxPackageV2) = convert_to_TagValue!(TagValueDoc, pkg, SpdxPackageV2_NameTable)
convert_to_TagValue!(TagValueDoc::IOBuffer, info::SpdxCreationInfoV2)= convert_to_TagValue!(TagValueDoc, info, SpdxCreationInfoV2_NameTable)


function convert_to_TagValue!(TagValueDoc::IOBuffer, PkgRef::SpdxPackageExternalReferenceV2)
    write(TagValueDoc, PkgRef.Category * " " * PkgRef.RefType * " " * PkgRef.Locator * "\n")
    isempty(PkgRef.Comment) || write(TagValueDoc, "ExternalRefComment:  " * PkgRef.Comment * "\n")
end