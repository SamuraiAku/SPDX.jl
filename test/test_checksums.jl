@testset "checksums" begin
    checksum= spdxchecksum("SHA1", pkgdir(SPDX), String["SPDX.spdx.json"], String[".git"])
    @test checksum isa Vector{UInt8}  # No good way to indepently verify that the calculation is correct.
end