@testset "SpdxSnippetPointer" begin
    a= SpdxSnippetPointerV2()
    a.Reference= "SpdxRef-ID1"
    a.LineNumber= UInt(23)
    b= SpdxSnippetPointerV2("SpdxRef-ID1", "SnippetLineRange", UInt(23))
    @test SPDX.compare_b(a,b)

    # Create object from JSON fragment
    c_json= "{
        \"lineNumber\" : 23,
        \"reference\" : \"SpdxRef-ID1\"
    }"
    c_dict= JSON.parse(c_json)
    c= SPDX.convert_from_JSON(c_dict, SPDX.SpdxSnippetPointerV2_NameTable, SpdxSnippetPointerV2)
    @test SPDX.compare_b(a, c)
end

@testset "SpdxSnippetRange" begin
    a= SpdxSnippetRangeV2("SPDXRef-S1")
    a.Start.LineNumber= UInt(5)
    a.End.LineNumber= UInt(23)

    # Create object from JSON fragment
    c_json= "{
      \"endPointer\" : {
        \"lineNumber\" : 23,
        \"reference\" : \"SPDXRef-S1\"
      },
      \"startPointer\" : {
        \"lineNumber\" : 5,
        \"reference\" : \"SPDXRef-S1\"
      }
    }"
    c_dict= JSON.parse(c_json)
    c= SPDX.convert_from_JSON(c_dict, SPDX.SpdxSnippetRangeV2_NameTable, SpdxSnippetRangeV2)
    @test SPDX.compare_b(a, c)

    # Create object from TagValue
    d_tv= IOBuffer("SnippetLineRange: 5:23")
    d_tags= SPDX.read_from_TagValue(d_tv)
    d= SPDX.constructvalue(1, d_tags.TagValues, nothing, SPDX.SpdxSnippetV2_NameTable)
    d.Start.Reference= "SPDXRef-S1";  d.End.Reference= "SPDXRef-S1";  # Due to unusual structure of a SnippetRange, the Reference fields are set later
    @test SPDX.compare_b(a, d)
end

@testset "SpdxSnippet" begin
    # Construct the Snippet object
    a= SpdxSnippetV2("SPDXRef-SnippetID", "SPDXRef-FileID")
    push!(a.SnippetRange, SpdxSnippetRangeV2("SPDXRef-FileID", "SnippetByteRange", "3000:4000"))
    a.LicenseConcluded= SpdxLicenseExpressionV2("MIT")
    push!(a.LicenseInfo, SpdxLicenseExpressionV2("MIT"))
    push!(a.LicenseInfo, SpdxLicenseExpressionV2("GPL-2.0-only WITH Exception"))
    a.LicenseComments= "Not much to say about this."
    a.Copyright= "Copyright 2022 SamuraiAku"
    a.SnippetComments= "You should know where this came from"
    a.Name= "MySnippet"
    push!(a.Attributions, "Attribution 1")
    push!(a.Attributions, "Attribution 2")
      annotation= SpdxAnnotationV2()
      annotation.Annotator= SpdxCreatorV2(" Person:  Jane Doe    (nowhere@loopback.com)")
      annotation.Created= SpdxTimeV2(now())
      annotation.Type= "REVIEW"
      annotation.Comment= "This is a comment"
    push!(a.Annotations, annotation)

    # Create object from JSON fragment
    c_json= "{
    \"SPDXID\" : \"SPDXRef-SnippetID\",
    \"comment\" : \"You should know where this came from\",
    \"copyrightText\" : \"Copyright 2022 SamuraiAku\",
    \"licenseComments\" : \"Not much to say about this.\",
    \"licenseConcluded\" : \"MIT\",
    \"licenseInfoInSnippets\" : [ \"MIT\", \"GPL-2.0-only WITH Exception\"],
    \"name\" : \"MySnippet\",
    \"ranges\" : [ {
      \"endPointer\" : {
        \"offset\" : 4000,
        \"reference\" : \"SPDXRef-FileID\"
      },
      \"startPointer\" : {
        \"offset\" : 3000,
        \"reference\" : \"SPDXRef-FileID\"
      }
    } ],
    \"snippetFromFile\" : \"SPDXRef-FileID\",
    \"attributionTexts\" : [\"Attribution 1\", \"Attribution 2\"],
    \"annotations\" : [ {
      \"annotationDate\" : \"$(annotation.Created)\",
      \"annotationType\" : \"REVIEW\",
      \"annotator\" : \"Person: Jane Doe (nowhere@loopback.com)\",
      \"comment\" : \"This is a comment\"
    } ]
  }"
  c_dict= JSON.parse(c_json)
  c= SPDX.convert_from_JSON(c_dict, SPDX.SpdxSnippetV2_NameTable, SpdxSnippetV2)
  @test SPDX.compare_b(a, c)

  # Create object from TagValue parse
  d_tv= IOBuffer("
  SnippetSPDXID: SPDXRef-SnippetID
  SnippetFromFileSPDXID: SPDXRef-FileID
  SnippetName: MySnippet
  SnippetCopyrightText: <text>Copyright 2022 SamuraiAku</text>
  SnippetByteRange: 3000:4000
  SnippetLicenseConcluded: MIT
  LicenseInfoInSnippet: MIT
  LicenseInfoInSnippet: GPL-2.0-only WITH Exception
  SnippetLicenseComments: <text>Not much to say about this.</text>
  SnippetAttributionText: <text>Attribution 1</text>
  SnippetAttributionText: Attribution 2
  SnippetComment: <text>You should know where this came from</text>
  # Annotations
  Annotator: Person: Jane Doe (nowhere@loopback.com)
  AnnotationDate: $(annotation.Created)
  AnnotationType: REVIEW
  AnnotationComment: <text>This is a comment</text>
  ")
  d= SPDX.parse_TagValue(d_tv, SPDX.SpdxSnippetV2_NameTable, SpdxSnippetV2)
  @test SPDX.compare_b(a, d)
end
