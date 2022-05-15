@testset "SpdxCreator" begin
    a= SpdxCreatorV2("Person", "Jane Doe", "nowhere@loopback.com"; validate= true) # Create object and populate directly
    b= SpdxCreatorV2(" Person:  Jane Doe    (nowhere@loopback.com)")  # Create object via string parsing. Add extra spaces to make it interesting
    @test SPDX.compare_b(a, b)
  
    # Create object from JSON fragment
    c_json= "{\"creators\" : [ \"Tool: LicenseFind-1.0\", \"Organization: ExampleCodeInspect ()\", \"Person: Jane Doe (nowhere@loopback.com)\" ]}"
    c_dict= JSON.parse(c_json) # A vector of creators. Check one of them
    c= SPDX.convert_from_JSON(c_dict["creators"][3], nothing, SpdxCreatorV2)
    @test SPDX.compare_b(a, c)
    c_wrong= SPDX.convert_from_JSON(c_dict["creators"][1], nothing, SpdxCreatorV2)
    @test !SPDX.compare_b(a, c_wrong)
  
    # Create object from TagValue parse
    d_tv= IOBuffer("Creator: Organization: ExampleCodeInspect ()\nCreator:Person: Jane Doe (nowhere@loopback.com)\nCreator: Tool: LicenseFind-1.0\n")
    d_tags= getproperty(SPDX.read_from_TagValue(d_tv), :TagValues)
    @test d_tags[2]["Tag"] in SPDX.SpdxCreationInfoV2_NameTable.TagValueName
    d= SpdxCreatorV2(d_tags[2]["Value"])
    @test SPDX.compare_b(a, d)

    # Test some error conditions, someday
  end