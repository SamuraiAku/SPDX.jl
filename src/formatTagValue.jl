# SPDX-License-Identifier: MIT

#########################
function convert_doc_to_TagValue!(TagValueDoc::IO, doc::SpdxDocumentV2, NameTable::Table)
    docfieldindicies= findall(!in((:Packages, :Files, :Snippets, :Relationships, :LicenseInfo)), NameTable.Symbol)
    docfieldsNameTable= NameTable[docfieldindicies]

    convert_to_TagValue!(TagValueDoc, doc, docfieldsNameTable)

    # Now analyze the relationships to find the proper order for writing packages, files, Snippets, and relationships
    # Order for writing as specified by SPDX is:
    # - Non Package-File relationships
    # - Files that have no relationships specified
    # - Loop through the packages
    #    - Write package
    #    - File contained in the package as specified in the relationships
    #    - Snippets associated with the file

    relationships::Vector{SpdxRelationshipV2}= doc.Relationships
    packages::Vector{SpdxPackageV2}= doc.Packages
    files::Vector{SpdxFileV2}= doc.Files
    snippets::Vector{SpdxSnippetV2}= doc.Snippets

    # Organize the packages/files/snippets into vectors in packagefilesets
    packagefilesets= [Vector() for x in 1:(length(packages)+1)]
    for idx in 1:length(packages)
        push!(packagefilesets[idx+1], packages[idx])
        # packagefilesets[1] is for files that are not contained in any packages
    end

    pkgIDs::Vector{String}= getproperty.(packages, :SPDXID)
    mark_pkgfilerelationships= [false for x in 1:length(relationships)]
    snippetfileIDs::Vector{String}= getproperty.(snippets, :FileSPDXID)
    r_contains= in.(getproperty.(relationships, :RelationshipType), Ref(("CONTAINS",)))
    r_pkgIDs= in.(getproperty.(relationships, :SPDXID), Ref(pkgIDs))
    for file in files
        contained= in.(getproperty.(relationships, :RelatedSPDXID), Ref((file.SPDXID, )))  .&&  r_contains .&& r_pkgIDs
        if reduce(|, contained) == false 
            push!(packagefilesets[1], file)  # File is not contained in any package
        else
            contained_idx= findall(contained)
            length(contained_idx) > 1  &&  println("WARNING: file $(file.SPDXID) is contained in multiple packages")
            for idx in contained_idx
                pkgidx= findfirst(isequal(relationships[idx].SPDXID), pkgIDs)
                push!(packagefilesets[pkgidx+1], file)
                mark_filesnippets= in.(snippetfileIDs, Ref((file.SPDXID, )))
                for s in snippets[mark_filesnippets]
                    push!(packagefilesets[pkgidx+1], s)
                end
            end
        end
        mark_pkgfilerelationships= mark_pkgfilerelationships .| contained
    end
    
    # Write all non pkg-file relationships
    r_notpkgfile= .!mark_pkgfilerelationships
    r_nametable::Table= eval(NameTable.NameTable[findfirst(isequal(:Relationships), NameTable.Symbol)])
    for r in relationships[r_notpkgfile]
        convert_to_TagValue!(TagValueDoc, r, r_nametable)
    end

    # Write all the package/files/snippets in the order specified by SPDX
    p_nametable::Table= eval(NameTable.NameTable[findfirst(isequal(:Packages), NameTable.Symbol)]::Symbol)
    f_nametable::Table= eval(NameTable.NameTable[findfirst(isequal(:Files), NameTable.Symbol)]::Symbol)
    s_nametable::Table= eval(NameTable.NameTable[findfirst(isequal(:Snippets), NameTable.Symbol)]::Symbol)
    for fileset in packagefilesets
        for element in fileset
            element_nametable= typeof(element)==SpdxFileV2 ? f_nametable : typeof(element)==SpdxPackageV2 ? p_nametable : s_nametable
            convert_to_TagValue!(TagValueDoc, element, element_nametable)
        end
    end

    # Write all License Info. Not required to be at the end, but it makes human reading of the document a little easier
    l_nametable::Table= eval(NameTable.NameTable[findfirst(isequal(:LicenseInfo), NameTable.Symbol)]::Symbol)
    for lic::SpdxLicenseInfoV2 in doc.LicenseInfo
        convert_to_TagValue!(TagValueDoc, lic, l_nametable)
    end

end


#########################
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
        fieldnametable= eval(NameTable.NameTable[idx]::Symbol)

        if isnothing(fieldnametable) || (isa(fieldval, Vector) && (typeof(fieldval[1]) <: AbstractSpdxElement)) || typeof(fieldval) <: AbstractSpdxElement
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
                    convert_to_TagValue!(TagValueDoc, element, fieldnametable, SPDXID)
                end
            else
                convert_to_TagValue!(TagValueDoc, fieldval, fieldnametable, SPDXID)
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

function convert_to_TagValue!(TagValueDoc::IO, snippet::SpdxSnippetRangeV2, NameTable::Table, unused::AbstractString)
    tvstrings= _tvSnippetRange(snippet, NameTable)
    for tagvalue in tvstrings
        write_TagValue!(TagValueDoc, tagvalue[2], tagvalue[1], false)
    end
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