# SPDX-License-Identifier: MIT

function parse_TagValue(TVfile::IO, NameTable::Spdx_NameTable, constructor::Union{Type, Function})
    TVdata= read_from_TagValue(TVfile) # TagValues will be empty, only NextSection will be filled

    if TVdata.NextSection["Tag"] != NameTable.TagValueName[1]
        println("Parsing Error! First Tag is not ", NameTable.TagValueName[1])
        return nothing
    end

    NextSection= TVdata.NextSection
    TVdata= read_from_TagValue(TVfile)
    pushfirst!(TVdata.TagValues, NextSection)
    spdxdoc= convert_from_TagValue(TVdata.TagValues, NameTable, constructor)
    deferredData= Vector{Tuple}()

    NextSection= TVdata.NextSection
    while !isnothing(NextSection)
        TVdata= read_from_TagValue(TVfile)
        pushfirst!(TVdata.TagValues, NextSection)
        
        sectionidx= findfirst(isequal(TVdata.TagValues[1]["Tag"]), NameTable.TagValueName)
        if isnothing(sectionidx)
            println("INFO: Ignoring Tag section beginning at ", TVdata.TagValues[1]["Tag"], ": ", TVdata.TagValues[1]["Value"])
            NextSection= TVdata.NextSection
            continue
        end

        objconstructor= eval(NameTable.Constructor[sectionidx]::Union{Symbol, Expr})
        objnametable= eval(NameTable.NameTable[sectionidx]::Symbol)
        obj= convert_from_TagValue(TVdata.TagValues, objnametable, objconstructor)
        if obj isa Tuple
            push!(deferredData, obj)
        else
            set_obj_param!(spdxdoc, obj, NameTable.Symbol[sectionidx] )
        end
        NextSection= TVdata.NextSection
    end

    for data in deferredData
        set_obj_deferred_param!(spdxdoc, data)
    end

    return spdxdoc
end

#######################
function convert_from_TagValue(TagValues::Vector{RegexMatch}, NameTable::Spdx_NameTable, constructor::Union{Type, Function})
    TagValueNames= NameTable.TagValueName
    tags::Vector{SubString}= getindex.(getproperty.(TagValues, :captures), 1)
    constructoridx= findall(.!NameTable.Mutable::Vector{Bool} .& (NameTable.TagValueName .!== nothing))
    constructorparameters= Vector{Any}(missing, length(constructoridx))
    objparameters= Vector{Any}(missing, length(tags))
    Annotation_SPDXREF::Union{Nothing, AbstractString}= nothing

    # Process all the TagValue pairs
    for tagidx in eachindex(tags)
        paramidx= findfirst(isequal(tags[tagidx]), TagValueNames)
        value= constructvalue(tagidx, TagValues, paramidx, NameTable)
        if isnothing(value)
            if tags[tagidx] == "SPDXREF"
                # This case happens only with Annotations, a very small percentage of the whole file
                Annotation_SPDXREF= TagValues[tagidx]["Value"]
            else
                println("INFO: Ignoring Tag ", tags[tagidx])
            end
        else
            idx= findfirst(isequal(paramidx), constructoridx)
            if idx isa Integer
                constructorparameters[idx]= value
            else
                objparameters[tagidx]= value
            end
        end
    end

    obj= constructor(constructorparameters...)

    # Populate the object with any remaining fields
    populatedidx= findall(!ismissing, objparameters)
    for idx in populatedidx
        parameter= objparameters[idx]
        paramidx= findfirst(isequal(tags[idx]), TagValueNames)
        set_from_TagValue!(obj, parameter, paramidx, tags[idx], NameTable)
    end

    if isnothing(Annotation_SPDXREF)
        return obj
    else
        return (Annotation_SPDXREF, obj)
    end
end

#######################
function constructvalue(tagidx::Integer, TagValues::Vector{RegexMatch}, paramidx::Integer, NameTable::Spdx_NameTable)
    constructor= eval(NameTable.Constructor[paramidx]::Union{Symbol, Expr})
    return constructor(TagValues[tagidx]["Value"])
end

function constructvalue(tagidx::Integer, TagValues::Vector{RegexMatch}, paramidx::Nothing, NameTable::Spdx_NameTable)
    # Check if :CreationInfo exists in this NameTable (i.e. we're constructing Document level parameters)
    # Check if :ExternalReferences exists in this NameTable (i.e. we're construcing Package level parameters)
    # Check if :SnippetRange exists in this NameTable (i.e. we're constructing Snippet level parameters)
    objectcheck= findfirst(in((:CreationInfo, :ExternalReferences, :SnippetRange)), NameTable.Symbol)
    if isnothing(objectcheck)
        value= nothing
    elseif NameTable.Symbol[objectcheck] == :SnippetRange
        # Weird case that requires special handling
        # The tag tells us which fields of the snippetRange to fill out
        value= SpdxSnippetRangeV2("Unknown", TagValues[tagidx]["Tag"], TagValues[tagidx]["Value"])
    else
        # If the tag is not valid, then this call of constructvalue will return nothing, so no need for further checks here
        objNameTable= eval(NameTable.NameTable[objectcheck]::Symbol)
        objidx= findfirst(isequal(TagValues[tagidx]["Tag"]), objNameTable.TagValueName)
        value= constructvalue(tagidx, TagValues, objidx, objNameTable)
    end
    return value
end


#######################
function set_from_TagValue!(obj::AbstractSpdx, value, valueidx::Integer, Tag, NameTable::Spdx_NameTable)
    objsymbol= NameTable.Symbol[valueidx]
    set_obj_param!(obj, value, objsymbol)
end

function set_from_TagValue!(obj::SpdxDocumentV2, value, valueidx::Nothing, Tag::AbstractString, NameTable::Spdx_NameTable)
    # Special case where we need to set CreationInfo sub-object
    creationidx= findfirst(isequal(:CreationInfo), NameTable.Symbol)
    creationNameTable= eval(NameTable.NameTable[creationidx]::Symbol)
    paramidx= findfirst(isequal(Tag), creationNameTable.TagValueName)
    set_from_TagValue!(obj.CreationInfo, value, paramidx, Tag, creationNameTable)
end

function set_from_TagValue!(obj::SpdxPackageV2, value, valueidx::Nothing, Tag::AbstractString, NameTable::Spdx_NameTable)
    # Special case where we need to set the comment field on an external reference sub-object
    refcommentidx= findfirst(isequal(:ExternalReferences), NameTable.Symbol)
    refNameTable= eval(NameTable.NameTable[refcommentidx]::Symbol)
    paramidx= findfirst(isequal(Tag), refNameTable.TagValueName)
    # Assume that the  is being applied to the latest Reference
    set_from_TagValue!(obj.ExternalReferences[end], value, paramidx, Tag, refNameTable)
end

function set_from_TagValue!(obj::SpdxSnippetV2, value::SpdxSnippetRangeV2, valueidx::Nothing, Tag::AbstractString, NameTable::Spdx_NameTable)
    set_obj_param!(obj, value, :SnippetRange)
end


#######################
function set_obj_param!(obj::AbstractSpdx, value, objsym::Symbol)
    if getproperty(obj, objsym) isa Vector
        push!(getproperty(obj, objsym), value)
    else
        setproperty!(obj, objsym, value)
    end
end

function set_obj_param!(doc::SpdxDocumentV2, value::SpdxFileV2, objsym::Symbol)
    # Files come right after the Package they belong to. Create a relationship for that
    # If a File appears before any Packages, then no such relationship exists
    packages::Vector{SpdxPackageV2}= doc.Packages
    relationships::Vector{SpdxRelationshipV2}= doc.Relationships

    if objsym == :Files
        if !isempty(packages)
            fileRelationship= SpdxRelationshipV2(packages[end].SPDXID, "CONTAINS", value.SPDXID)
            if isnothing(findfirst(compare_rel(fileRelationship), relationships))  # Check for duplicates
                push!(relationships, fileRelationship)
            end
        end
        push!(doc.Files, value)
    else
        # This should never execute, but it's an easy error check
        println("ERROR:  set_obj_param!(::SpdxDocumentV2, ::SpdxFileV2, ::Symbol);  Symbol is wrong somehow!")
    end
end

function set_obj_param!(doc::SpdxDocumentV2, value::SpdxRelationshipV2, objsym::Symbol)
    relationships::Vector{SpdxRelationshipV2}= doc.Relationships

    if objsym == :Relationships
        if isnothing(findfirst(compare_rel(value), relationships))  # Check for duplicates
            push!(relationships, value)
        end
    else
        # This should never execute, but it's an easy error check
        println("ERROR:  set_obj_param!(::SpdxDocumentV2, ::SpdxRelationshipV2, ::Symbol);  Symbol is wrong somehow!")
    end
end

function set_obj_param!(snippet::SpdxSnippetV2, range::SpdxSnippetRangeV2, objsym::Symbol)
    # Had to wait until now to be able to set the SPDXID in the SnippetRange
    range.Start.Reference= snippet.FileSPDXID
    range.End.Reference= snippet.FileSPDXID

    if objsym == :SnippetRange
        push!(snippet.SnippetRange, range)
    else
        # This should never execute, but it's an easy error check
        println("ERROR:  set_obj_param!(::SpdxSnippetV2, ::SpdxSnippetRangeV2, ::Symbol);  Symbol is wrong somehow!")
    end
end

#######################
function set_obj_deferred_param!(doc::SpdxDocumentV2, param::Tuple{AbstractString, SpdxAnnotationV2})
    # Check the document, package, file, and snippet SPDXIDs and find a match
    if param[1] == doc.SPDXID
        push!(doc.Annotations, param[2])
        return
    end

    idcheck= findfirst(isequal(param[1]), getproperty.(doc.Packages, :SPDXID))
    if idcheck isa Int
        push!(doc.Packages[idcheck].Annotations, param[2])
        return
    end

    idcheck= findfirst(isequal(param[1]), getproperty.(doc.Files, :SPDXID))
    if idcheck isa Int
        push!(doc.Files[idcheck].Annotations, param[2])
        return
    end

    idcheck= findfirst(isequal(param[1]), getproperty.(doc.Snippets, :SPDXID))
    if idcheck isa Int
        push!(doc.Snippets[idcheck].Annotations, param[2])
        return
    end
end


#######################
function read_from_TagValue(TVfile::IO)
    regex_TagValue= r"^\s*(?<Tag>[^#:]*):\s*(?<Value>.*[[:^blank:]]{1})\s*$" # Match fails if all whitespace or comment line
    regex_checkmultilinestart= r"^<text>"i
    regex_checkmultilinestop= r"</text>\s*$"i
    regex_multiline= r"^\s*(?<Tag>[^#:]*):\s*(?i:<text>)(?<Value>.*)(?i:</text>)\s*$"s 

    TagValues= Vector{RegexMatch}()
    NextSection= nothing
    while !eof(TVfile)
        fileline= readline(TVfile)
        match_tv= match(regex_TagValue, fileline)
        if match_tv isa RegexMatch
            if occursin(regex_checkmultilinestart, match_tv["Value"])
                while !occursin(regex_checkmultilinestop, fileline)
                    fileline= fileline * "\n" * readline(TVfile)
                end
                match_tv= match(regex_multiline, fileline)
                if isnothing(match_tv)
                    println("WARNING (read_from_TagValue): Unable to parse, skipping this Tag\n\t", fileline)
                    continue
                end
            end
            if match_tv["Tag"] in ("SPDXVersion", "PackageName", "FileName", "SnippetSPDXID", "LicenseID", "Relationship", "Annotator")
                NextSection= match_tv
                break
            else
                push!(TagValues, match_tv)
            end
        end
    end

    return (TagValues= TagValues, NextSection= NextSection)
end