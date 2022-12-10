# SPDX-License-Identifier: MIT

using SPDX
using Test
using JSON
using Dates
using TimeZones


include("test_types.jl")
include("test_SpdxAnnotation.jl")
include("test_SpdxLicense.jl")
include("test_SpdxRelationship.jl")
include("test_SpdxSnippet.jl")
include("test_SpdxFile.jl")
include("test_SpdxPackage.jl")
include("test_SpdxDocument.jl")
