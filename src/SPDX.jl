# SPDX-License-Identifier: MIT
module SPDX

using JSON
using DataStructures
using Dates
using UUIDs
using TimeZones
using SHA
using Base.Filesystem

#######################
Base.Bool(x::AbstractString)= parse(Bool, lowercase(x))

#######################
include("types.jl")
include("spdxAnnotation.jl")
include("spdxLicense.jl")
include("spdxRelationship.jl")
include("spdxSnippet.jl")
include("spdxFile.jl")
include("spdxPackage.jl")
include("spdxDocument.jl")
include("analysis.jl")
include("display.jl")
include("formatJSON.jl")
include("formatTagValue.jl")
include("readJSON.jl")
include("readTagValue.jl")
include("checksums.jl")
include("api.jl")

# Precompilation
include("../test/build_testDocument.jl")
h= hash(a)

end
