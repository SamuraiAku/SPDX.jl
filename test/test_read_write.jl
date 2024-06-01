@testset "`readspdx`/`writespdx`" begin
    using SPDX: readJSON, readTagValue

    include("build_testDocument.jl") 
    spdxdir= pkgdir(SPDX)
    @test_throws "Specified Format YAML is not supported" spdxDoc= readspdx(joinpath(spdxdir, "SPDX.spdx.json"); format= "YAML")
    @test_throws "File format .yml is not supported" spdxDoc= readspdx(joinpath(spdxdir, "SPDX.spdx.yml")) # File doesn't exist but it errors out because of the unsupported file extension before checking that
    spdxDoc = readspdx(joinpath(spdxdir, "SPDX.spdx.json"))
    @test spdxDoc isa SpdxDocumentV2
    testdir= mktempdir()

    @testset "JSON format I/O roundtrips" begin
        io = IOBuffer()
        @test_throws "Specified Format YAML is not supported" writespdx(io, spdxDoc; format= "YAML")
        @test_throws UndefKeywordError writespdx(io, spdxDoc)
        writespdx(io, spdxDoc; format= "JSON")
        rt_spdx = readspdx(seekstart(io); format= "JSON")
        @test isequal(spdxDoc, rt_spdx)

        @test isequal(spdxDoc, readJSON(seekstart(io)))
        @test_throws Exception readTagValue(seekstart(io))
    end

    @testset "JSON format file roundtrips" begin
        rt_path = joinpath(testdir, "out.spdx.json")
        @test_throws "File format .yml is not supported" writespdx(spdxDoc, replace(rt_path, "json" => "yml"))
        writespdx(spdxDoc, rt_path)
        rt_spdx = readspdx(rt_path)
        @test isequal(spdxDoc, rt_spdx)

        # Change the describes relationship in the SPDX document to get more code coverage
        spdxDoc2 = readspdx(joinpath(spdxdir, "SPDX.spdx.json"))
        idx= findfirst(x -> isequal(x.RelationshipType, "DESCRIBES"), spdxDoc2.Relationships)
        describesRelationShip= spdxDoc2.Relationships[idx]
        spdxDoc2.Relationships[idx]= SpdxRelationshipV2(describesRelationShip.RelatedSPDXID, "DESCRIBED_BY", describesRelationShip.SPDXID)
        writespdx(spdxDoc2, rt_path; format= "JSON")
        rt_spdx = readspdx(rt_path; format= "JSON")
        @test isequal(spdxDoc, rt_spdx)  # Reading documentDescribes in a JSON file produces a DESCRIBES Relationship

        # Write and read a second SPDX file for more coverage.
        spdxDoc2= a  # from build_testDocument.jl
        writespdx(spdxDoc2, rt_path)
        rt_spdx = readspdx(rt_path)
        @test isequal(spdxDoc2, rt_spdx)
        open(joinpath(testdir, "spdx_print.txt"), "w") do io
            print(io, spdxDoc2)
        end
    end

    @testset "JSON format errors" begin
        # Point of this test is to trigger certain println() when a JSON file with unrecognized fields is present
        # for code coverage.
        temp= readspdx(joinpath(spdxdir, "test/SPDX_badfields.spdx.json"));
        @test temp isa SpdxDocumentV2
    end

    @testset "TagValue format I/O roundtrips" begin
        io = IOBuffer()
        writespdx(io, spdxDoc; format= "TagValue")
        rt_spdx = readspdx(seekstart(io); format= "TagValue")
        @test isequal(spdxDoc, rt_spdx)

        @test isequal(spdxDoc, readTagValue(seekstart(io)))
        @test_throws Exception readJSON(seekstart(io))
    end

    @testset "TagValue format file roundtrips" begin
        rt_path = joinpath(testdir, "out.spdx")
        # Write and read a second SPDX file for more coverage.
        spdxDoc2= c  # from build_testDocument.jl
        writespdx(spdxDoc2, rt_path; format= "TagValue")
        rt_spdx = readspdx(rt_path; format= "TagValue")
        @test SPDX.compare_b(spdxDoc2, rt_spdx)
    end

    @testset "TagValue format errors" begin
        tv_path= joinpath(spdxdir, "test", "SPDX_badparse.spdx")
        @test isnothing(readspdx(tv_path))
        tv_path= joinpath(spdxdir, "test", "SPDX_discardedtags.spdx")
        @test readspdx(tv_path) isa SpdxDocumentV2
    end
end
