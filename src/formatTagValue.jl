

convert_to_TagValue!(TagValueDoc::IO, dataElement::AbstractSpdx)= write(TagValueDoc, string(dataElement) * "\n")  # Default
convert_to_TagValue!(TagValueDoc::IO, stringElement::AbstractString)= write(TagValueDoc, stringElement * "\n")
convert_to_TagValue!(TagValueDoc::IO, boolElement::Bool)= write(TagValueDoc, string(boolElement) * "\n")

function write_TagValue!(TagValueDoc::IO, element, TagValueName::Union{Nothing, String}, Multiline::Bool)
    if TagValueName !== nothing
        write(TagValueDoc, string(TagValueName) * ":  ")
        if Multiline == true
            write(TagValueDoc, "<text>")
        end
    end
    convert_to_TagValue!(TagValueDoc, element)
    if (TagValueName !== nothing) && (Multiline == true)
        write(TagValueDoc, "    </text>\n")
    end
end

function convert_to_TagValue!(TagValueDoc::IO, doc::AbstractSpdxData, NameTable::Table)
    for idx in range(1,length= length(NameTable))
        fieldval= getproperty(doc, NameTable.Symbol[idx])
        (ismissing(fieldval) || (isa(fieldval, Vector) && isempty(fieldval))) && continue  # goto next symbol if this one has no data
        isnothing(fieldval) && error("Field " * string(NameTable.Symbol[idx]) * "== nothing")  # This should not happen, but check just in case

        if isa(fieldval, Vector)
            for element in fieldval
                write_TagValue!(TagValueDoc, element, NameTable.TagValueName[idx], NameTable.Multiline[idx])
            end
        else
            write_TagValue!(TagValueDoc, fieldval, NameTable.TagValueName[idx], NameTable.Multiline[idx])
        end
    end
    write(TagValueDoc, "\n\n####\n")
    return nothing
end

convert_to_TagValue!(TagValueDoc::IO, doc::SpdxDocumentV2)= convert_to_TagValue!(TagValueDoc, doc, SpdxDocumentV2_NameTable)
convert_to_TagValue!(TagValueDoc::IO, pkg::SpdxPackageV2) = convert_to_TagValue!(TagValueDoc, pkg, SpdxPackageV2_NameTable)
convert_to_TagValue!(TagValueDoc::IO, info::SpdxCreationInfoV2)= convert_to_TagValue!(TagValueDoc, info, SpdxCreationInfoV2_NameTable)


function convert_to_TagValue!(TagValueDoc::IO, PkgRef::SpdxPackageExternalReferenceV2)
    write(TagValueDoc, PkgRef.Category * " " * PkgRef.RefType * " " * PkgRef.Locator * "\n")
    ismissing(PkgRef.Comment) || write_TagValue!(TagValueDoc, PkgRef.Comment, SpdxPackageExternalReferenceV2_NameTable.TagValueName[4], SpdxPackageExternalReferenceV2_NameTable.Multiline[4])
end

function convert_to_TagValue!(TagValueDoc::IO, relationship::SpdxRelationshipV2)
    write(TagValueDoc, relationship.SPDXID * "  " * relationship.RelationshipType * "  " * relationship.RelatedSPDXID * "\n")
    ismissing(relationship.Comment) || write_TagValue!(TagValueDoc, relationship.Comment, SpdxRelationshipV2_NameTable.TagValueName[4], SpdxRelationshipV2_NameTable.Multiline[4])
end