
# Default
convert_from_JSON(element, unused, constructor::Union{Type, Function})= constructor(element)

function convert_from_JSON(JSONfile::Dict{String, Any}, NameTable::Table, constructor::Union{Type, Function})
    ImmutableIndicies= map(value -> value == false, NameTable.Mutable) # Replace with findall? 
    paramnames= NameTable.JSONname[ImmutableIndicies]
    ImmutableParameters= Vector{Any}(missing, length(paramnames))
    ImmutableTables= NameTable.NameTable[ImmutableIndicies]
    ImmutableConstructors= NameTable.Constructor[ImmutableIndicies]
    for idx in 1:length(paramnames)
        if haskey(JSONfile, paramnames[idx]) 
            ImmutableParameters[idx]=  convert_from_JSON(JSONfile[paramnames[idx]], ImmutableTables[idx], ImmutableConstructors[idx])
        end
    end
    constructorparams= Tuple(ImmutableParameters)
    obj= constructor(constructorparams...)

    if sum(ImmutableIndicies) != length(NameTable.Mutable)
        for (name, value) in JSONfile
            idx= findfirst(isequal(name), NameTable.JSONname)
            if idx === nothing
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
process_additional_JSON_fields!(obj, name, value)= nothing

function process_additional_JSON_fields!(doc::SpdxDocumentV2, name::AbstractString, value)
    if name == "documentDescribes"
        if value isa Vector
            for element in value
                obj= SpdxRelationshipV2("SPDXRef-DOCUMENT", "DESCRIBES", element)
                push!(doc.Relationships, obj)
            end
        else
            println("Unable to parse \"documentdocumentDescribes\" :", value)
        end
    else
        println("INFO: Ignoring JSON field ", name)
    end
end
