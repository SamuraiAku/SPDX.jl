@testset "SpdxLicenseCrossReference" begin
    a= SpdxLicenseCrossReferenceV2()
    a.URL= "https://nowhere.loopback.com"
    a.isValid= true
    a.isLive= true
    a.isWayBackLink= false

    b= SpdxLicenseCrossReferenceV2("https://nowhere.loopback.com")
    @test !SPDX.compare_b(a, b)
    b.isValid= true
    b.isLive= true
    b.isWayBackLink= false
    @test SPDX.compare_b(a, b)

    # Create object from JSON fragment
    c_json= "{ 
        \"url\": \"https://nowhere.loopback.com\",
        \"isValid\" : true,
        \"isLive\" : true,
        \"isWayBackLink\" : false
    }"
    c_dict= JSON.parse(c_json)
    c= SPDX.convert_from_JSON(c_dict, SPDX.SpdxLicenseCrossReferenceV2_NameTable, SpdxLicenseCrossReferenceV2)
    @test SPDX.compare_b(a, c)

    # There is no TagValue equivalent to SpdxLicenseCrossReference

end

@testset "SpdxLicenseInfo" begin
    a= SpdxLicenseInfoV2("LicenseRef-ID1")
    a.ExtractedText= "This is a test license.\n You have permission to share the code with your friends"
    a.Name= "test license"
    push!(a.URL, "https://nowhere.loopback.com")
    push!(a.URL, "https://julialang.org")
    push!(a.CrossReference, SpdxLicenseCrossReferenceV2())
    push!(a.CrossReference, SpdxLicenseCrossReferenceV2())
    a.CrossReference[1].URL= "https://julialang.org"
    a.CrossReference[2].URL= "https://nowhere.loopback.com"

    # Create object from Dictionary that would have come from JSON.parsefile()
    # JSON.parse(::String) errors out with ASCII control characters such as \n
    c_dict= Dict{String, Any}([
        "licenseId" => "LicenseRef-ID1",
        "extractedText" => "This is a test license.\n You have permission to share the code with your friends",
        "name" => "test license",
        "seeAlsos" => Any["https://nowhere.loopback.com", "https://julialang.org"],
        "crossRefs" => Vector([Dict{String, Any}(["url"=>"https://julialang.org"]), Dict{String, Any}(["url"=>"https://nowhere.loopback.com"])])
    ])
    c= SPDX.convert_from_JSON(c_dict, SPDX.SpdxLicenseInfoV2_NameTable, SpdxLicenseInfoV2)
    @test SPDX.compare_b(a, c)

    # Create object from TagValue parse
    d_tv= IOBuffer("LicenseID: LicenseRef-ID1
    ExtractedText: <text>This is a test license.\n You have permission to share the code with your friends</text>
    LicenseName: test license
    LicenseCrossReference: https://nowhere.loopback.com
    LicenseCrossReference: https://julialang.org
    ")
    d= SPDX.parse_TagValue(d_tv, SPDX.SpdxLicenseInfoV2_NameTable, SpdxLicenseInfoV2)
    @test SPDX.compare_b(a, d; skipproperties= Symbol[:CrossReference])
end

@testset "SpdxSimpleLicenseExpression" begin
    a= SpdxSimpleLicenseExpressionV2("MIT", "Exception1")
    b= SpdxSimpleLicenseExpressionV2("  MIT WITH  Exception1   ")
    @test SPDX.compare_b(a, b)

    # Error Checking
    @test_throws "Empty License String" SpdxSimpleLicenseExpressionV2("")
end

# SpdxComplexLicenseExpressionV2 has only a single constructor and nothing to compare against
#@testset "SpdxComplexLicenseExpression" begin
#    a= SpdxComplexLicenseExpressionV2("MIT AND GPLV2 WITH Exception2")
#end

@testset "SpdxLicenseExpression" begin
    a= SpdxLicenseExpressionV2("  MIT WITH  Exception1   ")
    b= SpdxSimpleLicenseExpressionV2("MIT", "Exception1")
    @test SPDX.compare_b(a, b)

    c= SpdxLicenseExpressionV2("  MIT WITH  Exception1   ")
    d= SpdxSimpleLicenseExpressionV2("MIT", "Exception1")
    @test SPDX.compare_b(c, d)

    e= SpdxLicenseExpressionV2("MIT AND GPLV2 WITH Exception2")
    f= SpdxComplexLicenseExpressionV2("MIT AND GPLV2 WITH Exception2")
    @test SPDX.compare_b(e, f)
end