# TODO: Put SPDX license header here
module SPDX

#using JSON
using DataStructures

export AbstractSpdx, AbstractSpdxData, SpdxPackageV2

# Type definitions
abstract type AbstractSpdx end
abstract type AbstractSpdxData end
abstract type AbstractSpdxLicense end
abstract type AbstractSpdxExternalReference end


struct SpdxPackageV2 <: AbstractSpdxData
    SPDXID::String
    MutableFields::OrderedDict{Symbol, Union{Missing, String, Vector{String}, AbstractSpdx, Vector{AbstractSpdx}}}
end
function SpdxPackageV2(SPDXID::AbstractString)
    # Initialize the object fields
    ObjSymbols= OrderedSet{Symbol}([:a, 
                                    :b, 
                                    :c])
    MutableFields= OrderedDict{Symbol, Any}(ObjSymbols .=> missing)
    # TODO: For any vector types, replace missing with an empty Vector
    MutableFields[:b]= Vector{String}()
    return SpdxPackageV2(SPDXID, MutableFields)
end

function Base.getproperty(obj::AbstractSpdxData, sym::Symbol)
    MutableFields= getfield(obj, :MutableFields)
    if(sym in keys(MutableFields))
        return MutableFields[sym]
    else
        return getfield(obj, sym)
    end
end

function Base.setproperty!(obj::AbstractSpdxData, sym::Symbol, newval)
    MutableFields= getfield(obj, :MutableFields)
    if(sym in keys(MutableFields))
        if(isa(MutableFields[sym], Vector))
            error("MethodError: " * string(sym) * " is a vector. Use push!() and pop!() instead.")
        else
            MutableFields[sym]= newval
        end
    else
        setfield!(obj, sym, newval)
    end
end

function Base.propertynames(obj::AbstractSpdxData)
    ImmutableFields= filter(sym -> sym != :MutableFields, fieldnames(typeof(obj)))
    MutableFields= Tuple(keys(getfield(obj, :MutableFields)))
    return (ImmutableFields..., MutableFields...)
end

# Write your package code here.



end
