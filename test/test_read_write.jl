@testset "`readspdx`/`writespdx`" begin
    using SPDX: readJSON, readTagValue

    include("build_testDocument.jl") 
    spdxDoc = readspdx(joinpath(pkgdir(SPDX), "SPDX.spdx.json"))
    @test spdxDoc isa SpdxDocumentV2

    @testset "JSON format roundtrips" begin
        rt_path = joinpath(mktempdir(), "out.spdx.json")
        writespdx(spdxDoc, rt_path)
        rt_spdx = readspdx(rt_path)
        @test isequal(spdxDoc, rt_spdx)

        @test isequal(spdxDoc, readJSON(rt_path))
        @test_throws Exception readTagValue(rt_path)

        # Change the describes relationship in the SPDX document to get more code coverage
        spdxDoc2 = readspdx(joinpath(pkgdir(SPDX), "SPDX.spdx.json"))
        idx= findfirst(x -> isequal(x.RelationshipType, "DESCRIBES"), spdxDoc2.Relationships)
        describesRelationShip= spdxDoc2.Relationships[idx]
        spdxDoc2.Relationships[idx]= SpdxRelationshipV2(describesRelationShip.RelatedSPDXID, "DESCRIBED_BY", describesRelationShip.SPDXID)
        writespdx(spdxDoc2, rt_path)
        rt_spdx = readspdx(rt_path)
        @test isequal(spdxDoc, rt_spdx)  # Reading documentDescribes in a JSON file produces a DESCRIBES Relationship

        # Write and read a second SPDX file for more coverage.
        spdxDoc2= a  # from build_testDocument.jl
        writespdx(spdxDoc2, rt_path)
        rt_spdx = readspdx(rt_path)
        @test isequal(spdxDoc2, rt_spdx)
    end

    @testset "JSON format errors" begin
        # Point of this test is to trigger certain println() when a JSON file with unrecognized fields is present
        # for code coverage.
        temp= readspdx(joinpath(pkgdir(SPDX), "test/SPDX_badfields.spdx.json"));
        @test temp isa SpdxDocumentV2
    end
    
    @testset "TagValue format roundtrips" begin
        rt_path = mktempdir() * "out.spdx"
        writespdx(spdxDoc, rt_path)
        rt_spdx = readspdx(rt_path)
        @test isequal(spdxDoc, rt_spdx)

        @test isequal(spdxDoc, readTagValue(rt_path))
        @test_throws Exception readJSON(rt_path)

        # Write and read a second SPDX file for more coverage.
        spdxDoc2= c  # from build_testDocument.jl
        writespdx(spdxDoc2, rt_path)
        rt_spdx = readspdx(rt_path)
        @test_broken compare_b(spdxDoc2, rt_spdx)  # Relationships are in different order, so skip until we have a better compare
    end

    @testset "TagValue format errors" begin
        tv_path= joinpath(pkgdir(SPDX), "test", "SPDX_badparse.spdx")
        @test isnothing(readspdx(tv_path))
        tv_path= joinpath(pkgdir(SPDX), "test", "SPDX_discardedtags.spdx")
        @test readspdx(tv_path) isa SpdxDocumentV2
    end
end
