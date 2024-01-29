# SPDX-License-Identifier: MIT

using SPDX
using Test
using JSON
using Dates
using TimeZones
using SHA

@testset "Bool check" begin
    @test Bool(" True ")
    @test !Bool(" fALSE  ")
    @test_throws Exception Bool("flse ")
end

include("test_api.jl")
include("test_types.jl")
include("test_checksums.jl")
include("test_SpdxAnnotation.jl")
include("test_SpdxLicense.jl")
include("test_SpdxRelationship.jl")
include("test_SpdxSnippet.jl")
include("test_SpdxFile.jl")
include("test_SpdxPackage.jl")
include("test_SpdxDocument.jl")
include("test_read_write.jl")
