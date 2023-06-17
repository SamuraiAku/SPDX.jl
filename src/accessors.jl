# SPDX-License-Identifier: MIT

##### Temporary code until everything is moved to mutable structs
################  Default Accessors for AbstractSpdxData2
Base.getproperty(obj::AbstractSpdxData2, sym::Symbol)= getfield(obj, sym)
Base.setproperty!(obj::AbstractSpdxData2, sym::Symbol, newval)= setfield!(obj, sym, newval)
Base.propertynames(obj::AbstractSpdxData2)= fieldnames(typeof(obj))
#############################################





################  Default Accessors for AbstractSpdxData
function Base.getproperty(obj::AbstractSpdxData, sym::Symbol)
    MutableFields= getfield(obj, :MutableFields)
    if sym in keys(MutableFields)
        return MutableFields[sym]
    else
        return getfield(obj, sym)
    end
end

function Base.setproperty!(obj::AbstractSpdxData, sym::Symbol, newval)
    MutableFields= getfield(obj, :MutableFields)
    if sym in keys(MutableFields)
        if isa(MutableFields[sym], Vector)
            error("MethodError: " * string(sym) * " is a vector. Use push!() and pop!() instead.")
        else
            MutableFields[sym]= newval
        end
    else
        ImmutableFields= filter(sym -> sym != :MutableFields, fieldnames(typeof(obj)))
        if !(sym in ImmutableFields) 
            error("type " * string(typeof(obj)) * " has no field " * string(sym))
        else
            setfield!(obj, sym, newval)
        end
    end
end

function Base.propertynames(obj::AbstractSpdxData)
    ImmutableFields= filter(sym -> sym != :MutableFields, fieldnames(typeof(obj)))
    MutableFields= Tuple(keys(getfield(obj, :MutableFields)))
    return (ImmutableFields..., MutableFields...)
end