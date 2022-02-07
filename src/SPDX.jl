# TODO: Put SPDX license header here
module SPDX

using JSON
using DataStructures
using TypedTables
using Dates
using UUIDs
using TimeZones

export AbstractSpdx, AbstractSpdxData, SpdxPackageV2, SpdxSimpleLicenseExpressionV2, SpdxPackageExternalReferenceV2, SpdxNamespaceV2
export SpdxDocumentV2, SpdxCreatorV2, SpdxDocumentExternalReferenceV2, SpdxRelationshipV2, SpdxCreationInfoV2, SpdxChecksumV2
export SpdxLicenseInfoV2, SpdxLicenseCrossReferenceV2
export printJSON, setcreationtime!, SpdxTimeV2, createnamespace!, updatenamespace!
export addcreator!, getcreators, deletecreator!, printTagValue, readJSON, readTagValue

include("types.jl")
include("spdxAnnotation.jl")
include("spdxLicense.jl")
include("spdxRelationship.jl")
include("spdxPackage.jl")
include("spdxDocument.jl")
include("accessors.jl")
include("display.jl")
include("formatJSON.jl")
include("formatTagValue.jl")
include("readJSON.jl")
include("readTagValue.jl")
include("api.jl")

# Write your package code here.

function __init__()
    precompile(Pair, (Symbol, Vector{String}))
    precompile(Pair, (Symbol, Missing))

    precompile(string, (SpdxSimpleLicenseExpressionV2,))
    precompile(string, (SpdxCreatorV2,))
    precompile(string, (SpdxTimeV2,))
    precompile(string, (SpdxDocumentV2,))
    precompile(string, (SpdxChecksumV2,))

    precompile(string, (SpdxAnnotationV2,))
    precompile(init_MutableFields, (typeof(SpdxAnnotationV2_NameTable),))

    precompile(string, (SpdxLicenseInfoV2,))
    precompile(init_MutableFields, (typeof(SpdxLicenseInfoV2_NameTable),))
    precompile(string, (SpdxLicenseCrossReferenceV2,))
    precompile(init_MutableFields, (typeof(SpdxLicenseCrossReferenceV2_NameTable),))

    precompile(string, (SpdxRelationshipV2,))
    precompile(init_MutableFields, (typeof(SpdxRelationshipV2_NameTable),))

    precompile(string, (SpdxPackageExternalReferenceV2,))
    precompile(init_MutableFields, (typeof(SpdxPackageExternalReferenceV2_NameTable),))
    precompile(string, (SpdxPkgVerificationCodeV2,))
    precompile(string, (SpdxPackageV2,))
    precompile(Pair, (Symbol, Vector{SpdxChecksumV2}))
    precompile(Pair, (Symbol, Vector{SpdxSimpleLicenseExpressionV2}))
    precompile(Pair, (Symbol, Vector{SpdxPackageExternalReferenceV2}))

    precompile(deepcopy, (Vector{SpdxChecksumV2},))
    precompile(deepcopy, (Vector{SpdxSimpleLicenseExpressionV2},))
    precompile(deepcopy, (Vector{SpdxPackageExternalReferenceV2},))

    precompile(init_MutableFields, (typeof(SpdxPackageV2_NameTable),))

    precompile(Pair, (Symbol, Vector{SpdxDocumentExternalReferenceV2}))
    precompile(Pair, (Symbol, SpdxCreationInfoV2))
    precompile(Pair, (Symbol, Vector{SpdxPackageV2}))
    precompile(Pair, (Symbol, Vector{SpdxLicenseInfoV2}))
    precompile(Pair, (Symbol, Vector{SpdxRelationshipV2}))
    precompile(Pair, (Symbol, Vector{SpdxAnnotationV2}))

    precompile(string, (SpdxDocumentExternalReferenceV2,))
    precompile(string, (SpdxNamespaceV2,))
    precompile(string, (SpdxCreationInfoV2,))
    precompile(Pair, (Symbol, Vector{SpdxCreatorV2}))
    precompile(deepcopy, (Vector{SpdxCreatorV2},))
    precompile(init_MutableFields, (typeof(SpdxCreationInfoV2_NameTable),))

    precompile(deepcopy, (Vector{SpdxDocumentExternalReferenceV2},))
    precompile(deepcopy, (SpdxCreationInfoV2,))
    precompile(deepcopy, (Vector{SpdxPackageV2},))
    precompile(deepcopy, (Vector{SpdxLicenseInfoV2},))
    precompile(deepcopy, (Vector{SpdxRelationshipV2},))
    precompile(deepcopy, (Vector{SpdxAnnotationV2},))

    precompile(init_MutableFields, (typeof(SpdxDocumentV2_NameTable),))
end


end
