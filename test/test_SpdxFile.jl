@testset "SpdxFileType" begin
    a= SpdxFileTypeV2("SOURCE")
    @test typeof(a) === SpdxFileTypeV2

    b= SpdxFileTypeV2("BADTYPE")
    @test b === nothing
end

@testset "SpdxFile" begin
    a= SpdxFileV2("./src/Foo.jl", "SpdxRef-F1")
    push!(a.Type, SpdxFileTypeV2("SOURCE"))
    push!(a.Type, SpdxFileTypeV2("TEXT"))
    push!(a.Checksum, SpdxChecksumV2("SHA1: 85ed0817af83a24ad8da68c2b5094de69833983c"))
    push!(a.Checksum, SpdxChecksumV2("MD5: 624c1abb3664f4b35547e7c73864ad24"))
    a.LicenseConcluded= SpdxLicenseExpressionV2("MIT")
    push!(a.LicensesInFile, SpdxLicenseExpressionV2("MIT"))
    push!(a.LicensesInFile, SpdxLicenseExpressionV2("BSD-3"))
    a.LicenseComments= "I have a comment."
    a.Copyright= "Copyright 2022 SamuraiAku"
    a.FileComments= "Have a look at this file."
    a.Notice= "Are we sure about this license?"
    push!(a.Contributors, "SamuraiAku")
    push!(a.Contributors, "The SPDX project")
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
        \"fileName\" : \"./src/Foo.jl\",
        \"SPDXID\" : \"SpdxRef-F1\",
        \"fileTypes\" : [\"SOURCE\", \"TEXT\"],
        \"checksums\" : [ {
            \"algorithm\" : \"SHA1\",
            \"checksumValue\" : \"85ed0817af83a24ad8da68c2b5094de69833983c\"
            }, {
            \"algorithm\" : \"MD5\",
            \"checksumValue\" : \"624c1abb3664f4b35547e7c73864ad24\"
        } ],
        \"licenseConcluded\" : \"MIT\",
        \"licenseInfoInFiles\" : [\"MIT\", \"BSD-3\"],
        \"licenseComments\" : \"I have a comment.\",
        \"copyrightText\" : \"Copyright 2022 SamuraiAku\",
        \"comment\" : \"Have a look at this file.\",
        \"noticeText\" : \"Are we sure about this license?\",
        \"fileContributors\" : [\"SamuraiAku\", \"The SPDX project\"],
        \"attributionTexts\" : [\"Attribution 1\", \"Attribution 2\"],
        \"annotations\" : [ {
            \"annotationDate\" : \"$(annotation.Created)\",
            \"annotationType\" : \"REVIEW\",
            \"annotator\" : \"Person: Jane Doe (nowhere@loopback.com)\",
            \"comment\" : \"This is a comment\"
          } ]
    }"
    c_dict= JSON.parse(c_json)
    c= SPDX.convert_from_JSON(c_dict, SPDX.SpdxFileV2_NameTable, SpdxFileV2)
    @test SPDX.compare_b(a, c)

    # Create object from TagValue parse
    d_tv= IOBuffer("
    FileName: ./src/Foo.jl
    SPDXID: SpdxRef-F1
    FileType: SOURCE
    FileType: TEXT
    FileChecksum: SHA1: 85ed0817af83a24ad8da68c2b5094de69833983c
    FileChecksum: MD5: 624c1abb3664f4b35547e7c73864ad24
    LicenseConcluded: MIT
    LicenseInfoInFile: MIT
    LicenseInfoInFile: BSD-3
    LicenseComments: <text>I have a comment.</text>
    FileCopyrightText: <text>Copyright 2022 SamuraiAku</text>
    FileComment: Have a look at this file.
    FileNotice: Are we sure about this license?
    FileContributor: SamuraiAku
    FileContributor: <text>The SPDX project</text>
    FileAttributionText: Attribution 1
    FileAttributionText: <text>Attribution 2</text>
    # Annotations
    Annotator: Person: Jane Doe (nowhere@loopback.com)
    AnnotationDate: $(annotation.Created)
    AnnotationType: REVIEW
    AnnotationComment: <text>This is a comment</text>
    ")
    d= SPDX.parse_TagValue(d_tv, SPDX.SpdxFileV2_NameTable, SpdxFileV2)
    @test SPDX.compare_b(a, d)

end