# TODO: Put SPDX license header here
module SPDX

#using JSON
using DataStructures

export AbstractSpdx, AbstractSpdxData, SpdxPackageV2, SpdxSimpleLicenseExpressionV2

# Type definitions
abstract type AbstractSpdx end
abstract type AbstractSpdxData <: AbstractSpdx end
abstract type AbstractSpdxLicense <: AbstractSpdx end
abstract type AbstractSpdxExternalReference <: AbstractSpdx end


struct SpdxPackageV2 <: AbstractSpdxData
    SPDXID::String
    MutableFields::OrderedDict{Symbol, Union{Missing, String, Vector{String}, AbstractSpdx, Vector{AbstractSpdx}}}
end
function SpdxPackageV2(SPDXID::AbstractString)
    # Initialize the object fields.  Maybe this should be a column from a DataFrame Table later. 
    # So that I can track the subtle name translations between different fileformats
    # If object Symbols becomes a DataFrame column, then the default values could become one too!
    # MutableFields= OrderedDict{Symbol, Any}(ObjSymbols .=> ObjDefaults)
    MutableFields= OrderedDict{Symbol, Any}([                 :Name   => missing, 
                                                           :Version   => missing, 
                                                          :FileName   => missing,
                                                          :Supplier   => missing,
                                                        :Originator   => missing,
                                                  :DownloadLocation   => missing,
                                                     :FilesAnalyzed   => missing,
                                                  :VerificationCode   => missing,
                                                         :Checksums   => Vector{String}(),
                                                          :HomePage   => missing,
                                                        :SourceInfo   => missing,
                                                  :LicenseConcluded   => missing,
                                              :LicenseInfoFromFiles   => Vector{AbstractSpdx}(),
                                                   :LicenseDeclared   => missing,
                                                   :LicenseComments   => missing,
                                                         :Copyright   => missing,
                                                           :Summary   => missing,
                                               :DetailedDescription   => missing,
                                                           :Comment   => missing,
                                                :ExternalReferences   => Vector{AbstractSpdx}(),
                                          :ExternalReferenceComment   => missing,
                                                      :Attributions   => Vector{String}() ])

    return SpdxPackageV2(SPDXID, MutableFields)
end


struct SpdxSimpleLicenseExpressionV2 <: AbstractSpdxLicense
    LicenseId::String
    LicenseExceptionId::Union{String, Nothing}
end

SpdxSimpleLicenseExpressionV2(LicenseId::String)= SpdxSimpleLicenseExpressionV2(LicenseId, nothing)
# TODO : Have the constructor check the LicenseId against the approved list from SPDX group
# TODO : Support user defined licenses
# TODO : Support compound expressions



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
