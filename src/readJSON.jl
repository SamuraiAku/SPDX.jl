
# Default
convert_from_JSON(element, unused, constructor::Union{Type, Function})= constructor(element)

function convert_from_JSON(JSONfile::Dict{String, Any}, NameTable::Table, constructor::Union{Type, Function})
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
    obj= constructor(constructorparameters...)

    if length(constructornames) != length(NameTable.Mutable)
        for (name, value) in JSONfile
            idx= findfirst(isequal(name), NameTable.JSONname)
            if isnothing(idx)
                process_additional_JSON_fields!(obj, name, value)
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

    return obj
end

############
function process_additional_JSON_fields!(obj, name, value)
    println("INFO: Ignoring JSON field ", name)
    return nothing
end

function process_additional_JSON_fields!(doc::SpdxDocumentV2, name::AbstractString, value)
    if name == "documentDescribes"
        if value isa Vector
            for element in value
                obj= SpdxRelationshipV2("SPDXRef-DOCUMENT", "DESCRIBES", element)
                push!(doc.Relationships, obj)
                # TODO: Check if the relationship already exists?
            end
        else
            println("Unable to parse \"documentDescribes\" : ", value)
        end
    else
        println("INFO: Ignoring JSON field ", name)
    end
end
