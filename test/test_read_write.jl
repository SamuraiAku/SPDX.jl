@testset "`readspdx`/`writespdx`" begin
    using SPDX: readJSON, readTagValue

    spdx = readspdx(joinpath(pkgdir(SPDX), "SPDX.spdx.json"))
    @test spdx isa SpdxDocumentV2

    @testset "JSON format roundtrips" begin
        rt_path = mktempdir() * "out.spdx.json"
        writespdx(spdx, rt_path)
        rt_spdx = readspdx(rt_path)
        @test isequal(spdx, rt_spdx)

        @test isequal(spdx, readJSON(rt_path))
        @test_throws Exception readTagValue(rt_path)
    end

    @testset "TagValue format roundtrips" begin
        rt_path = mktempdir() * "out.spdx"
        writespdx(spdx, rt_path)
        rt_spdx = readspdx(rt_path)
        @test isequal(spdx, rt_spdx)

        @test isequal(spdx, readTagValue(rt_path))
        @test_throws Exception readJSON(rt_path)
    end
end
