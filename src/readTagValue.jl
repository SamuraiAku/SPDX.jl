function parse_TagValue(TVfile::IO, NameTable::Table, constructor::Union{Type, Function})
    TVdata= read_from_TagValue(TVfile) # TagValues will be empty, only NextSection will be filled

    if TVdata.NextSection["Tag"] != NameTable.TagValueName[1]
        println("Parsing Error! First Tag is not ", NameTable.TagValueName[1])
        return nothing
    end

    NextSection= TVdata.NextSection
    TVdata= read_from_TagValue(TVfile)
    pushfirst!(TVdata.TagValues, NextSection)
    spdxdoc= convert_from_TagValue(TVdata.TagValues, NameTable, constructor)

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

        obj= convert_from_TagValue(TVdata.TagValues, NameTable.NameTable[sectionidx], NameTable.Constructor[sectionidx])
        set_obj_param!(spdxdoc, obj, NameTable.Symbol[sectionidx] )
        NextSection= TVdata.NextSection
    end

    return spdxdoc
end

#######################
function convert_from_TagValue(TagValues::Vector{RegexMatch}, NameTable::Table, constructor::Union{Type, Function})
    TagValueNames= NameTable.TagValueName
    tags::Vector{SubString}= getindex.(getproperty.(TagValues, :captures), 1)
    constructoridx= findall(.!NameTable.Mutable::Vector{Bool} .& (NameTable.TagValueName .!== nothing))
    constructorparameters= Vector{Any}(missing, length(constructoridx))
    objparameters= Vector{Any}(missing, length(tags))

    # Process all the TagValue pairs
    for tagidx in 1:length(tags)
        paramidx= findfirst(isequal(tags[tagidx]), TagValueNames)
        value= constructvalue(tagidx, TagValues, paramidx, NameTable)
        if isnothing(value)
            println("INFO: Ignoring Tag ", tags[tagidx])
        else
            idx= findfirst(isequal(paramidx), constructoridx)
            if idx isa Integer
                constructorparameters[idx]= value
            else
                objparameters[tagidx]= value
            end
        end
    end

    obj= constructor(Tuple(constructorparameters)...)

    # Populate the object with any remaining fields
    populatedidx= findall(!ismissing, objparameters)
    for idx in populatedidx
        parameter= objparameters[idx]
        paramidx= findfirst(isequal(tags[idx]), TagValueNames)
        set_from_TagValue!(obj, parameter, paramidx, tags[idx], NameTable)
    end

    return obj
end

#######################
constructvalue(tagidx::Integer, TagValues::Vector{RegexMatch}, paramidx::Integer, NameTable::Table)= NameTable.Constructor[paramidx](TagValues[tagidx]["Value"])

function constructvalue(tagidx::Integer, TagValues::Vector{RegexMatch}, paramidx::Nothing, NameTable::Table)
    # Check if :CreationInfo exists in this NameTable (i.e. we're constructing Document level parameters)
    # Check if :ExternalReferences exists in this NameTable (i.e. we're construcing Package level parameters)
    objectcheck= findfirst(in((:CreationInfo, :ExternalReferences)), NameTable.Symbol)
    if isnothing(objectcheck)
        return nothing
    else
        objNameTable= NameTable.NameTable[objectcheck]
        objidx= findfirst(isequal(TagValues[tagidx]["Tag"]), objNameTable.TagValueName)
        value= constructvalue(tagidx, TagValues, objidx, objNameTable)
    end
    return value
end


#######################
function set_from_TagValue!(obj::AbstractSpdx, value, valueidx::Integer, Tag, NameTable::Table)
    objsymbol= NameTable.Symbol[valueidx]
    set_obj_param!(obj, value, objsymbol)
end

function set_from_TagValue!(obj::SpdxDocumentV2, value, valueidx::Nothing, Tag::AbstractString, NameTable::Table)
    # Special case where we need to set CreationInfo sub-object
    creationidx= findfirst(isequal(:CreationInfo), NameTable.Symbol)
    creationNameTable= NameTable.NameTable[creationidx]
    paramidx= findfirst(isequal(Tag), creationNameTable.TagValueName)
    set_from_TagValue!(obj.CreationInfo, value, paramidx, Tag, creationNameTable)
end

function set_from_TagValue!(obj::SpdxPackageV2, value, valueidx::Nothing, Tag::AbstractString, NameTable::Table)
    # Special case where we need to set the comment field on an external reference sub-object
    refcommentidx= findfirst(isequal(:ExternalReferences), NameTable.Symbol)
    refNameTable= NameTable.NameTable[refcommentidx]
    paramidx= findfirst(isequal(Tag), refNameTable.TagValueName)
    # Assume that the  is being applied to the latest Reference
    set_from_TagValue!(obj.ExternalReferences[end], value, paramidx, Tag, refNameTable)
end


#######################
function set_obj_param!(obj::AbstractSpdx, value, objsym::Symbol)
    #println(objsym, " ==> ", typeof(obj), ": (", typeof(value), ")  ", value)
    if getproperty(obj, objsym) isa Vector
        if value isa Vector
            for element in value
                push!(getproperty(obj, objsym), element)
            end
        else
            push!(getproperty(obj, objsym), value)
        end
    else
        setproperty!(obj, objsym, value)
    end
end


#######################
function read_from_TagValue(TVfile::IO)
    regex_TagValue= r"^\s*(?<Tag>[^#:]*):\s*(?<Value>.*)$" # Match fails if all whitespace or comment line
    regex_checkmultilinestart= r"<text>"i
    regex_checkmultilinestop= r"</text>"i
    regex_multiline= r"^\s*(?<Tag>[^#:]*):\s*(?i:<text>)(?<Value>.*)(?i:</text>).*$"s 

    TagValues= Vector{RegexMatch}()
    NextSection= nothing
    while !eof(TVfile)
        fileline= readline(TVfile)
        match_tv= match(regex_TagValue, fileline)
        if match_tv isa RegexMatch
            if occursin(regex_checkmultilinestart, fileline)
                while !occursin(regex_checkmultilinestop, fileline)
                    fileline= fileline * "\n" * readline(TVfile)
                end
                match_tv= match(regex_multiline, fileline)
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


#######################
function Bool(x::AbstractString)
    _x= lowercase(x)
    if _x == "true"
        return true
    elseif _x == "false"
        return false
    else
        error("InexactError: Bool($x)")
    end
end