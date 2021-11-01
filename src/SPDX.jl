# TODO: Put SPDX license header here
module SPDX

using JSON
using DataStructures
using TypedTables
using Dates
using TimeZones

export AbstractSpdx, AbstractSpdxData, SpdxPackageV2, SpdxSimpleLicenseExpressionV2, SpdxPackageExternalReferenceV2
export SpdxDocumentV2, SpdxCreatorV2, SpdxDocumentExternalReferenceV2, SpdxRelationshipV2, SpdxCreationInfoV2, SpdxChecksumV2
export printJSON, setcreationtime, SpdxTimeV2

include("types.jl")
include("tables.jl")
include("accessors.jl")
include("display.jl")
include("formatJSON.jl")
include("api.jl")

# Write your package code here.



end
