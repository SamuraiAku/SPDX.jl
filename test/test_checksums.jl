@testset "checksums" begin
    verifcode= ComputePackageVerificationCode(pkgdir(SPDX), String["SPDX.spdx.json"], String[".git"])
    @test verifcode isa SpdxPkgVerificationCodeV2  # No good way to indepently verify that the calculation is correct.
    @test issubset(["SPDX.spdx.json"], verifcode.ExcludedFiles)

    checksum= ComputeFileChecksum("SHA256", joinpath(pkgdir(SPDX), "Project.toml"))
    @test checksum isa SpdxChecksumV2
    @test checksum.Hash == open(joinpath(pkgdir(SPDX), "Project.toml")) do f 
                                return bytes2hex(sha256(f))
                            end
    
    linktest_code= ComputePackageVerificationCode(joinpath(pkgdir(SPDX), "test", "test_package"))
    @test issetequal(linktest_code.ExcludedFiles, ["dir_link", "file_link", "src/bad_link"])
end