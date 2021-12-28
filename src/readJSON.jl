
# Default
convert_from_JSON(element, unused, constructor::Union{Type, Function})= constructor(element)

function convert_from_JSON(JSONfile::Dict{String, Any}, NameTable::Table, constructor::Union{Type, Function})
    ImmutableIndicies= map(value -> value == false, NameTable.Mutable) # Replace with findall? 
    paramnames= NameTable.JSONname[ImmutableIndicies]
    ImmutableParameters= Vector{Any}(missing, length(paramnames))
    for idx in 1:length(paramnames)
        if haskey(JSONfile, paramnames[idx]) 
            ImmutableParameters[idx]=  NameTable.Constructor[idx](JSONfile[paramnames[idx]])
        end
    end
    constructorparams= Tuple(ImmutableParameters)
    obj= constructor(constructorparams...)

    if sum(ImmutableIndicies) == length(NameTable.Mutable)
        return obj
    else
        for (name, value) in JSONfile
            idx= findfirst(isequal(name), NameTable.JSONname)
            if idx === nothing
                println("INFO: Ignoring JSON field ", name)
                # TODO: Functions that process these extra JSON fields like documentDescribes
            elseif NameTable.Mutable[idx] == true
                elements= (value isa Vector) ? value : Vector([value])
                for item in elements
                    objval= convert_from_JSON(item, NameTable.NameTable[idx], NameTable.Constructor[idx])
                    if NameTable.Default[idx] isa Vector
                        push!(getproperty(obj, NameTable.Symbol[idx]),  objval)
                    else
                        setproperty!(obj, NameTable.Symbol[idx], objval)
                    end
                end
            end
        end
    end

    return obj
end
