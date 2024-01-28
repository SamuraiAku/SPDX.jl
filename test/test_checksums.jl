@testset "checksums" begin
    verifcode= ComputePackageVerificationCode(pkgdir(SPDX), String["SPDX.spdx.json"], String[".git"])
    @test verifcode isa SpdxPkgVerificationCodeV2  # No good way to indepently verify that the calculation is correct.

    checksum= ComputeFileChecksum("SHA256", joinpath(pkgdir(SPDX), "Project.toml"))
    @test checksum isa SpdxChecksumV2  # No good way to indepently verify that the calculation is correct.
end