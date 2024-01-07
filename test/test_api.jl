@testset "Comparison Operations" begin
    sbom_path = joinpath(pkgdir(SPDX), "SPDX.spdx.json")
    mysbom= readspdx(sbom_path)
    mysbom2= readspdx(sbom_path)
    mysbom3= readspdx(sbom_path)
    push!(mysbom3.Packages[2].LicenseInfoFromFiles, SpdxLicenseExpressionV2("MIT"))

    @testset "`Base.==`" begin
        # mysbom contains `missing` entries...
        @test ismissing(mysbom.CreationInfo.LicenseListVersion)
        # ...so a test of `==` should also be missing:
        @test ismissing(mysbom == mysbom)
        @test ismissing(mysbom == mysbom2)
        @test mysbom != mysbom3
    end

    @testset "`Base.isequal`" begin
        @test isequal(mysbom, mysbom)
        @test isequal(mysbom, mysbom2)
        @test !isequal(mysbom, mysbom3)
    end

    @testset "compare" begin
        @test !SPDX.compare_b(mysbom, mysbom3)
    end

    @testset "hash" begin
        @test hash(mysbom) == hash(mysbom2)
        @test hash(mysbom) !== hash(mysbom3)
    end
end

@testset "Helper API" begin
    sbom_path = joinpath(pkgdir(SPDX), "SPDX.spdx.json")
    mysbom= readspdx(sbom_path)
    creationtime= now(localzone())
    setcreationtime!(mysbom, creationtime)
    @test mysbom.CreationInfo.Created == SpdxTimeV2(creationtime)

    old_namespace= mysbom.Namespace
    new_URI= "https://nowhere.loopback.com/here"
    createnamespace!(mysbom, new_URI)
    @test mysbom.Namespace.URI == new_URI && mysbom.Namespace.UUID != old_namespace.UUID

    old_namespace= mysbom.Namespace
    updatenamespace!(mysbom)
    @test mysbom.Namespace.URI == old_namespace.URI && mysbom.Namespace.UUID != old_namespace.UUID
    mysbom.Namespace= missing
    @test_throws "Namespace is not set" updatenamespace!(mysbom)
    mysbom.Namespace= SpdxNamespaceV2("https://nowhere.loopback.com", nothing)
    @test_throws "UUID not set in namespace" updatenamespace!(mysbom)

    docCreators= getcreators(mysbom)
    @test isequal(docCreators, mysbom.CreationInfo.Creator)

    addcreator!(mysbom, "Person", "Jane Doe", "nowhere@loopback.com")
    newCreator= SpdxCreatorV2("Person", "Jane Doe", "nowhere@loopback.com")
    @test !isequal(docCreators, mysbom.CreationInfo.Creator)
    @test mysbom.CreationInfo.Creator[end] == newCreator

    deletecreator!(mysbom, newCreator)
    @test isequal(docCreators, mysbom.CreationInfo.Creator)
end



