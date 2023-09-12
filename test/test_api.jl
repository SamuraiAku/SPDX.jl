@testset "Base extensions" begin
    sbom_path = joinpath(pkgdir(SPDX), "SPDX.spdx.json")
    mysbom= readspdx(sbom_path)
    mysbom2= readspdx(sbom_path)

    @testset "`Base.==`" begin
        # mysbom contains `missing` entries...
        @test ismissing(mysbom.CreationInfo.LicenseListVersion)
        # ...so a test of `==` should also be missing:
        @test ismissing(mysbom == mysbom)
    end

    @testset "`Base.isequal`" begin
        @test isequal(mysbom, mysbom)
        @test isequal(mysbom, mysbom2)
    end
end
