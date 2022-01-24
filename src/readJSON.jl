
# Default
convert_from_JSON(element, unused, constructor::Union{Type, Function})= constructor(element)

function convert_from_JSON(JSONvector::Vector{Any}, NameTable, constructor::Union{Type, Function})
    valuearray= Vector{Any}(missing, length(JSONvector))
    for valueidx in 1:length(JSONvector)
        valuearray[valueidx]= convert_from_JSON(JSONvector[valueidx], NameTable, constructor)
    end
    return valuearray
end


function convert_from_JSON(JSONfile::Dict{String, Any}, NameTable::Table, constructor::Union{Type, Function})
    #ImmutableIndicies= map(value -> value == false, NameTable.Mutable) # Replace with findall?
    constructoridx= findall(.!NameTable.Mutable::Vector{Bool})
    constructorparameters= Vector{Any}(missing, length(constructoridx))
    objparameters= Vector{Any}(missing, length(JSONfile))
    jsonkeys= collect(keys(JSONfile))
    
    # Process all the entries
    for keyidx in 1:length(jsonkeys)
        paramidx= findfirst(isequal(jsonkeys[keyidx]), NameTable.JSONname)
        if isnothing(paramidx)
            println("Cannot process field ", jsonkeys[keyidx], " for now")
        else
            value= convert_from_JSON(JSONfile[jsonkeys[keyidx]], NameTable.NameTable[paramidx], NameTable.Constructor[paramidx])
            idx= findfirst(isequal(paramidx), constructoridx)
            if idx isa Integer
                constructorparameters[idx]= value
            else
                objparameters[keyidx]= value
            end
        end
    end

    obj= constructor(constructorparameters...)

    # Populate the object with any remaining fields
    populatedidx= findall(!ismissing, objparameters)
    for idx in populatedidx
        parameter= objparameters[idx]
        paramidx= findfirst(isequal(jsonkeys[idx]), NameTable.JSONname)
        set_obj_param!(obj, parameter, NameTable.Symbol[paramidx])
    end


    #paramnames= NameTable.JSONname[ImmutableIndicies]
    #ImmutableParameters= Vector{Any}(missing, length(paramnames))
    #ImmutableTables= NameTable.NameTable[ImmutableIndicies]
    #ImmutableConstructors= NameTable.Constructor[ImmutableIndicies]



    #for idx in 1:length(paramnames)
    #    if haskey(JSONfile, paramnames[idx]) 
    #        ImmutableParameters[idx]=  convert_from_JSON(JSONfile[paramnames[idx]], ImmutableTables[idx], ImmutableConstructors[idx])
    #    end
    #end
    #constructorparams= Tuple(ImmutableParameters)
    #obj= constructor(constructorparams...)
#
    #if sum(ImmutableIndicies) != length(NameTable.Mutable)
    #    for (name, value) in JSONfile
    #        idx= findfirst(isequal(name), NameTable.JSONname)
    #        if idx === nothing
    #            process_additional_JSON_fields!(obj, name, value)
    #        elseif NameTable.Mutable[idx] == true
    #            if value isa Vector
    #                for element in value
    #                    objval= convert_from_JSON(element, NameTable.NameTable[idx], NameTable.Constructor[idx])
    #                    push!(getproperty(obj, NameTable.Symbol[idx]),  objval)
    #                end
    #            else
    #                objval= convert_from_JSON(value, NameTable.NameTable[idx], NameTable.Constructor[idx])
    #                setproperty!(obj, NameTable.Symbol[idx], objval)
    #            end
    #        end
    #    end
    #end

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
