# TODO: Put SPDX license header here
module SPDX

using JSON
using DataStructures

export AbstractSpdx, AbstractSpdxPackage, SpdxPackageV2

# Type definitions
abstract type AbstractSpdx end
abstract type AbstractSpdxData end
abstract type AbstractSpdxLicense end
abstract type AbstractSpdxExternalReference end


struct SpdxPackageV2 <: AbstractSpdxData
    SPDXID::String
    ObjFields::OrderedDict{Symbol, Any}
    ObjSymbols::OrderedSet{Symbol}
end
function SpdxPackageV2(SPDXID::AbstractString)
    # Initialize the object fields
    ObjSymbols= OrderedSet{Symbol}([:a, 
                                    :b, 
                                    :c])
    ObjFields= OrderedDict{Symbol, Union{Missing, String, AbstractSpdx}}(ObjSymbols .=> missing)
    # TODO: For any vector types, replace with a Vector
    return obj= SpdxPackageV2(SPDXID, ObjFields, ObjSymbols)
end
# Write your package code here.



end
