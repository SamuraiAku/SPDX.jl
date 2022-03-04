
# Default
convert_from_JSON(element, unused, constructor::Union{Type, Function})= constructor(element)

function convert_from_JSON(JSONfile::Dict{String, Any}, NameTable::Table, constructor::Type)
    constructoridx= map(isequal(false), NameTable.Mutable)
    constructornames= NameTable.JSONname[constructoridx]
    constructorparameters= Vector{Any}(missing, length(constructornames))
    paramtables= NameTable.NameTable[constructoridx]
    paramconstructors= NameTable.Constructor[constructoridx]
    for idx in 1:length(constructornames)
        if haskey(JSONfile, constructornames[idx]) 
            constructorparameters[idx]=  convert_from_JSON(JSONfile[constructornames[idx]], paramtables[idx], paramconstructors[idx])
        end
    end
    obj= constructobj_json(constructor, Tuple(constructorparameters))

    if length(constructornames) != length(NameTable.Mutable)
        for (name, value) in JSONfile
            idx= findfirst(isequal(name), NameTable.JSONname)
            if isnothing(idx)
                process_additional_JSON_fields!(obj, name, (value,))
            elseif NameTable.Mutable[idx] == true
                if value isa Vector
                    for element in value
                        objval= convert_from_JSON(element, NameTable.NameTable[idx], NameTable.Constructor[idx])
                        push!(getproperty(obj, NameTable.Symbol[idx]),  objval)
                    end
                else
                    objval= convert_from_JSON(value, NameTable.NameTable[idx], NameTable.Constructor[idx])
                    setproperty!(obj, NameTable.Symbol[idx], objval)
                end
            end
        end
    end

    # Loop through all the packages and process their hasFiles field
    if obj isa SpdxDocumentV2
        for pkg_json::Dict{String, Any} in JSONfile["packages"]
            if haskey(pkg_json, "hasFiles")
                process_additional_JSON_fields!(obj, "hasFiles", (pkg_json["hasFiles"], pkg_json["SPDXID"]))
            end
        end
    end

    return obj
end


############
constructobj_json(constructor::Type, params::Tuple)= constructor(params...)

############
function process_additional_JSON_fields!(obj, name::AbstractString, unused::Tuple)
    if obj isa SpdxPackageV2 && name == "hasFiles"
        return nothing
    else
        println("INFO: Ignoring JSON field ", name)
        return nothing
    end
end


function process_additional_JSON_fields!(doc::SpdxDocumentV2, name::AbstractString, value::Tuple)
    if name in ("documentDescribes", "hasFiles")
        # 1-element Tuple structure is (describesVector,)
        # 2-element Tuple structure is (filesVector, pkgSPDXID)
        doc_r= doc.Relationships
        if value[1] isa Vector
            if name == "documentDescribes"
                ID= "SPDXRef-DOCUMENT"
                rtype= "DESCRIBES"
            else
                ID::String= value[2]
                rtype= "CONTAINS"
            end

            for element in value[1]
                obj= SpdxRelationshipV2(ID, rtype, element)
                if isnothing(findfirst(isequal(obj), doc_r))
                    push!(doc_r, obj)
                end
            end
        else
            println("Unable to parse \"$name\" : ", value[1])
        end
    else
        println("INFO: Ignoring JSON field ", name)
    end
end
