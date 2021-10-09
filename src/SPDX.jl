# TODO: Put SPDX license header here
module SPDX

#using JSON
using DataStructures
using TypedTables

export AbstractSpdx, AbstractSpdxData, SpdxPackageV2, SpdxSimpleLicenseExpressionV2, PackageExternalReferenceV2
export SpdxDocumentV2, SpdxCreatorV2, DocumentExternalReferenceV2, SpdxRelationshipV2

include("./types.jl")
include("./tables.jl")
include("./accessors.jl")
include("./display.jl")

# Write your package code here.



end
