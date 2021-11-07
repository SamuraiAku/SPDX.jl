

convert_to_TagValue!(TagValueDoc::IOBuffer, dataElement::Union{AbstractSpdx, AbstractSpdxElement})= write(TagValueDoc, string(dataElement) * "\n")  # Default
convert_to_TagValue!(TagValueDoc::IOBuffer, stringElement::String)= write(TagValueDoc, stringElement * "\n")

function write_TagValue(TagValueDoc::IOBuffer, element, TableColumn::NamedTuple)
    if TableColumn.TagValueName !== nothing
        write(TagValueDoc, TableColumn.TagValueName * ":  ")
        if TableColumn.Multiline == true
            write(TagValueDoc, "<text>")
        end
    end
    convert_to_TagValue!(TagValueDoc, element)
    if TableColumn.Multiline == true
        write(TagValueDoc, "    </text>\n")
    end
end

function convert_to_TagValue!(TagValueDoc::IOBuffer, doc::AbstractSpdxData, NameTable::Table)
    for idx in range(1,length= length(NameTable))
        fieldval= getproperty(doc, NameTable[idx].Symbol)
        (ismissing(fieldval) || (isa(fieldval, Vector) && isempty(fieldval))) && continue  # goto next symbol if this one has no data
        isnothing(fieldval) && error("Field " * string(NameTable[idx].Symbol) * "== nothing")  # This should not happen, but check just in case

        if isa(fieldval, Vector)
            for element in fieldval
                write_TagValue(TagValueDoc, element, NameTable[idx])
            end
        else
            write_TagValue(TagValueDoc, fieldval, NameTable[idx])
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