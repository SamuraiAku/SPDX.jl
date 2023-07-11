# SPDX-License-Identifier: MIT

# Default
function convert_from_JSON(element, unused, constructor::Union{Type, Function})
    if element isa String
        element= strip(element) # Remove leading or trailing whitespace
    end
    return constructor(element)
end

function convert_from_JSON(JSONfile::Dict{String, Any}, NameTable::Table, constructor::Union{Type, Function})
    constructoridx= map(isequal(false), NameTable.Mutable)
    constructornames= NameTable.JSONname[constructoridx]
    constructorparameters= Vector{Any}(missing, length(constructornames))
    paramtables::Vector{Union{Nothing,Table}}= NameTable.NameTable[constructoridx]
    paramconstructors::Vector{Union{Symbol,Expr}}= NameTable.Constructor[constructoridx]
    for idx in eachindex(constructornames)
        if haskey(JSONfile, constructornames[idx])
            parameterconstructor= eval(paramconstructors[idx])
            constructorparameters[idx]=  convert_from_JSON(JSONfile[constructornames[idx]], paramtables[idx], parameterconstructor)
        end
    end
    obj= constructobj_json(constructor, Tuple(constructorparameters))

    if length(constructornames) != length(NameTable.Mutable)
        for (name, value) in JSONfile
            idx= findfirst(isequal(name), NameTable.JSONname)
            if isnothing(idx)
                check_unknown_JSON_field(obj, name,)
            elseif NameTable.Mutable[idx] == true
                parameterconstructor= eval(NameTable.Constructor[idx]::Union{Symbol, Expr})
                if value isa Vector
                    for element in value
                        objval= convert_from_JSON(element, NameTable.NameTable[idx], parameterconstructor)
                        push!(getproperty(obj, NameTable.Symbol[idx]),  objval)
                    end
                else
                    objval= convert_from_JSON(value, NameTable.NameTable[idx], parameterconstructor)
                    setproperty!(obj, NameTable.Symbol[idx], objval)
                end
            end
        end
    end

    # Process other JSON fields that add additional relationships to the SPDX document
    if obj isa SpdxDocumentV2
        haskey(JSONfile, "packages") && for pkg_json::Dict{String, Any} in JSONfile["packages"]
            if haskey(pkg_json, "hasFiles")
                process_additional_JSON_fields!(obj, "hasFiles", (pkg_json["hasFiles"], pkg_json["SPDXID"]))
            end
        end

        if haskey(JSONfile, "documentDescribes")
            process_additional_JSON_fields!(obj, "documentDescribes", (JSONfile["documentDescribes"],))
        end
    end

    return obj
end


############
constructobj_json(constructor::Union{Type, Function}, params::Tuple)= constructor(map(x-> if x isa String return strip(x) else return x end, params)...)

############
function check_unknown_JSON_field(obj, name::AbstractString)
    if obj isa SpdxPackageV2 && name == "hasFiles"
        return nothing
    elseif obj isa SpdxDocumentV2 && name == "documentDescribes"
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
        doc_r::Vector{SpdxRelationshipV2}= doc.Relationships
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
                if isnothing(findfirst(compare_rel(obj), doc_r))
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
