@testset "SpdxCreator" begin
    a= SpdxCreatorV2("Person", "Jane Doe", "nowhere@loopback.com"; validate= true) # Create object and populate directly
    b= SpdxCreatorV2(" Person:  Jane Doe    (nowhere@loopback.com)")  # Create object via string parsing. Add extra spaces to make it interesting
    @test SPDX.compare_b(a, b)
  
    # Create object from JSON fragment
    c_json= "{\"creators\" : [ \"Tool: LicenseFind-1.0\", \"Organization: ExampleCodeInspect ()\", \"Person: Jane Doe (nowhere@loopback.com)\" ]}"
    c_dict= JSON.parse(c_json) # A vector of creators. Check one of them
    c= SPDX.convert_from_JSON(c_dict["creators"][3], nothing, SpdxCreatorV2)
    @test "creators" in SPDX.SpdxCreationInfoV2_NameTable.JSONname
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
    weird_creator= SpdxCreatorV2("NotAperson: John Smith")
    @test weird_creator isa SpdxCreatorV2
  end

@testset "SpdxTime" begin
  a= SPDX.SpdxTimeV2(ZonedDateTime(2022, 5, 15, 10, 5, 2, tz"UTC-5"))
  b= SPDX.SpdxTimeV2("2022-05-15T15:05:02Z") # Same time as above, but adjusted to UTC
  @test SPDX.compare_b(a, b)

  # Create object from JSON fragment
  c_json= "{ \"created\" : \"2022-05-15T15:05:02Z\" }"
  c_dict= JSON.parse(c_json)
  c= SPDX.convert_from_JSON(c_dict["created"], nothing, SpdxTimeV2)
  @test "created" in SPDX.SpdxCreationInfoV2_NameTable.JSONname
  @test SPDX.compare_b(a, c)

  # Create object from TagValue parse
  d_tv= IOBuffer("Created: 2022-05-15T15:05:02Z")
  d_tags= getproperty(SPDX.read_from_TagValue(d_tv), :TagValues)
  @test d_tags[1]["Tag"] in SPDX.SpdxCreationInfoV2_NameTable.TagValueName

  # Error Checking
  @test_throws Exception SpdxTimeV2("2022-05-15T15:05:02P")
end


@testset "SpdxChecksumV2" begin
  a= SpdxChecksumV2("SHA256", "11b6d3ee554eedf79299905a98f9b9a04e498210b59f15094c916c91d150efcd")
  b= SpdxChecksumV2("SHA256:   11b6d3ee554eedf79299905a98f9b9a04e498210b59f15094c916c91d150efcd   ")
  @test SPDX.compare_b(a, b)

  
  # Create object from JSON fragment
  c_json= "{ \"algorithm\" : \"SHA256\", \"checksumValue\" : \"11b6d3ee554eedf79299905a98f9b9a04e498210b59f15094c916c91d150efcd\" }"
  c_dict= JSON.parse(c_json)
  c= SPDX.convert_from_JSON(c_dict, SPDX.SpdxChecksumV2_NameTable, SpdxChecksumV2)
  @test SPDX.compare_b(a, c)

  # Create object from TagValue parse
  d_tv= IOBuffer("PackageChecksum: SHA256: 11b6d3ee554eedf79299905a98f9b9a04e498210b59f15094c916c91d150efcd")
  d_tags= getproperty(SPDX.read_from_TagValue(d_tv), :TagValues)
  @test d_tags[1]["Tag"] in SPDX.SpdxPackageV2_NameTable.TagValueName

  # Error Checking
  @test_throws "Checksum Algorithm is not recognized" SpdxChecksumV2("BADALG", "11b6d3ee554eedf79299905a98f9b9a04e498210b59f15094c916c91d150efcd")
  @test_throws "Checksum Hash is invalid: Non-hex values detected" SpdxChecksumV2("SHA256", "11b6d3ee554eedf79299905a98f9b9a04e498210b59f15094c916c91d150eXYZ")
  @test_throws "Unable to parse checksum string" SpdxChecksumV2("SHA256:   11b6d3ee554eedf79299905a98f9b9a04e498210  b59f15094c916c91d150efcd   ")
end