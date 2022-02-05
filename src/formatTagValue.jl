
function convert_to_TagValue!(TagValueDoc::IO, doc::AbstractSpdx, NameTable::Table, SPDXREF::AbstractString= "")
    if hasproperty(doc, :SPDXID)
        SPDXID= doc.SPDXID
    else
        SPDXID= ""
    end

    for idx in range(1,length= length(NameTable))
        fieldval= getproperty(doc, NameTable.Symbol[idx])
        (ismissing(fieldval) || (isa(fieldval, Vector) && isempty(fieldval))) && continue  # goto next symbol if this one has no data
        isnothing(fieldval) && error("Field " * string(NameTable.Symbol[idx]) * "== nothing")  # This should not happen, but check just in case

        if isnothing(NameTable.NameTable[idx]) || (isa(fieldval, Vector) && (typeof(fieldval[1]) <: AbstractSpdxElement)) || typeof(fieldval) <: AbstractSpdxElement
            if fieldval isa Vector
                for element in fieldval
                    write_TagValue!(TagValueDoc, element, NameTable.TagValueName[idx], NameTable.Multiline[idx])
                end
            else
                write_TagValue!(TagValueDoc, fieldval, NameTable.TagValueName[idx], NameTable.Multiline[idx])
            end
        else
            if fieldval isa Vector
                for element in fieldval
                    convert_to_TagValue!(TagValueDoc, element, NameTable.NameTable[idx], SPDXID)
                end
            else
                convert_to_TagValue!(TagValueDoc, fieldval, NameTable.NameTable[idx], SPDXID)
            end
        end
    end

    if !isempty(SPDXREF)  && (doc isa SpdxAnnotationV2)
        write(TagValueDoc, "SPDXREF: " * SPDXREF * "\n")
    end
    write(TagValueDoc, "\n\n####\n")
    return nothing
end

# TODO: Work on a generic function for these types of structures
function convert_to_TagValue!(TagValueDoc::IO, PkgRef::SpdxPackageExternalReferenceV2, NameTable::Table, unused::AbstractString)
    write_TagValue!(TagValueDoc, PkgRef.Category * " " * PkgRef.RefType * " " * PkgRef.Locator, NameTable.TagValueName[1], NameTable.Multiline[1])
    ismissing(PkgRef.Comment) || write_TagValue!(TagValueDoc, PkgRef.Comment, NameTable.TagValueName[4], NameTable.Multiline[4])
end

function convert_to_TagValue!(TagValueDoc::IO, relationship::SpdxRelationshipV2, NameTable::Table, unused::AbstractString)
    write_TagValue!(TagValueDoc, relationship.SPDXID * "  " * relationship.RelationshipType * "  " * relationship.RelatedSPDXID, NameTable.TagValueName[1], NameTable.Multiline[1])
    ismissing(relationship.Comment) || write_TagValue!(TagValueDoc, relationship.Comment, NameTable.TagValueName[4], NameTable.Multiline[4])
end

#########################
function write_TagValue!(TagValueDoc::IO, element, TagValueName::AbstractString, Multiline::Bool)
    write(TagValueDoc, TagValueName * ":  ")
    if Multiline == true
        write(TagValueDoc, "<text>")
    end
    write(TagValueDoc, string(element))
    if Multiline == true
        write(TagValueDoc, "</text>")
    end
    write(TagValueDoc, "\n")
end