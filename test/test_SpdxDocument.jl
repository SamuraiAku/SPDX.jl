@testset "SpdxCreationInfo" begin
    a= SpdxCreationInfoV2()
    a.LicenseListVersion= "3.9"
    push!(a.Creator, SpdxCreatorV2("Person: Jane Doe (nowhere@loopback.com)"))
    a.Created= SpdxTimeV2(now())
    a.CreatorComment= "This is a comment"

    # Create object from JSON fragment
    c_json= "{
        \"comment\" : \"This is a comment\",
        \"created\" : \"$(a.Created)\",
        \"creators\" : [ \"Person: Jane Doe (nowhere@loopback.com)\" ],
        \"licenseListVersion\" : \"3.9\"
    }"

    c_dict= JSON.parse(c_json)
    c= SPDX.convert_from_JSON(c_dict, SPDX.SpdxCreationInfoV2_NameTable, SpdxCreationInfoV2)
    @test SPDX.compare_b(a, c)

    # Create object from TagValue parse
    d_tv= IOBuffer("
        Creator: Person: Jane Doe (nowhere@loopback.com)
        Created: $(a.Created)
        CreatorComment: This is a comment
        LicenseListVersion: 3.9
    ")
    
    d_tags= getproperty(SPDX.read_from_TagValue(d_tv), :TagValues)
    d= SPDX.convert_from_TagValue(d_tags, SPDX.SpdxCreationInfoV2_NameTable, SPDX.SpdxCreationInfoV2)
    @test SPDX.compare_b(a, d)

end

@testset "SpdxNamespace" begin
    a= SpdxNamespaceV2("http://spdx.org/spdxdocs/spdx-example-444504E0-4F89-41D3-9A0C-0305E82C3301")

    # Create object from JSON fragment
    c_json= "{
        \"documentNamespace\" : \"http://spdx.org/spdxdocs/spdx-example-444504E0-4F89-41D3-9A0C-0305E82C3301\"
    }"

    c_dict= JSON.parse(c_json)
    c= SPDX.convert_from_JSON(c_dict[ iterate(keys(c_dict))[1] ], nothing, SPDX.SpdxNamespaceV2)
    @test SPDX.compare_b(a, c)

    # Create object from TagValue parse
    d_tv= IOBuffer("
        DocumentNamespace: http://spdx.org/spdxdocs/spdx-example-444504E0-4F89-41D3-9A0C-0305E82C3301
    ")

    d_tags= getproperty(SPDX.read_from_TagValue(d_tv), :TagValues)
    paramidx= findfirst(isequal(d_tags[1].captures[1]), SPDX.SpdxDocumentV2_NameTable.TagValueName)
    d= SPDX.constructvalue(1, d_tags, paramidx, SPDX.SpdxDocumentV2_NameTable)
    @test SPDX.compare_b(a, d)
end

@testset "SpdxDocumentExternalReference" begin
    a= SpdxDocumentExternalReferenceV2("DocumentRef-spdx-tool-1.2",
        SpdxNamespaceV2("http://spdx.org/spdxdocs/spdx-tools-v1.2-3F2504E0-4F89-41D3-9A0C-0305E82C3301"),
        SpdxChecksumV2("SHA1: d6a770ba38583ed4bb4525bd96e50461655d2759")
    )
    
    # Create object from JSON fragment
    c_json= "{
        \"externalDocumentId\" : \"DocumentRef-spdx-tool-1.2\",
        \"checksum\" : {
            \"algorithm\" : \"SHA1\",
            \"checksumValue\" : \"d6a770ba38583ed4bb4525bd96e50461655d2759\"
        },
        \"spdxDocument\" : \"http://spdx.org/spdxdocs/spdx-tools-v1.2-3F2504E0-4F89-41D3-9A0C-0305E82C3301\"
    }"

    c_dict= JSON.parse(c_json)
    c= SPDX.convert_from_JSON(c_dict, SPDX.SpdxDocumentExternalReferenceV2_NameTable, SpdxDocumentExternalReferenceV2)
    @test SPDX.compare_b(a, c)

    # Create object from TagValue parse
    d_tv= IOBuffer("
        ExternalDocumentRef: DocumentRef-spdx-tool-1.2 http://spdx.org/spdxdocs/spdx-tools-v1.2-3F2504E0-4F89-41D3-9A0C-0305E82C3301 SHA1: d6a770ba38583ed4bb4525bd96e50461655d2759
    ")
    d_tags= getproperty(SPDX.read_from_TagValue(d_tv), :TagValues)
    paramidx= findfirst(isequal(d_tags[1].captures[1]), SPDX.SpdxDocumentV2_NameTable.TagValueName)
    d= SPDX.constructvalue(1, d_tags, paramidx, SPDX.SpdxDocumentV2_NameTable)
    @test SPDX.compare_b(a, d)
end

@testset "SpdxDocument" begin
    include("build_testDocument.jl")
    @test SPDX.compare_b(a, c)
    @test SPDX.compare_b(a, d)
end