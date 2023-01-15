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
    a= SpdxDocumentV2()
    a.Name= "SPDX.jl"
    a.Namespace= SpdxNamespaceV2("http://spdx.org/spdxdocs/spdx-example-444504E0-4F89-41D3-9A0C-0305E82C3301")
    push!(a.ExternalDocReferences, SpdxDocumentExternalReferenceV2("DocumentRef-spdx-tool-1.2 http://spdx.org/spdxdocs/spdx-tools-v1.2-3F2504E0-4F89-41D3-9A0C-0305E82C3301 SHA1: d6a770ba38583ed4bb4525bd96e50461655d2759"))
        creationInfo= SpdxCreationInfoV2()
        creationInfo.LicenseListVersion= "3.9"
        push!(creationInfo.Creator, SpdxCreatorV2("Person: Jane Doe (nowhere@loopback.com)"))
        creationInfo.Created= SpdxTimeV2(now())
        creationInfo.CreatorComment= "This is a comment"
    a.CreationInfo= creationInfo
    a.DocumentComment= "I don't have very much to say about it."

    # Add a package
        pkg= SpdxPackageV2("SpdxRef-P1")
        pkg.Name= "Package1"
        pkg.Version= "v1.0.0"
        pkg.FileName= "./src"
        pkg.Supplier= SpdxCreatorV2("Person: Jane Doe (somewhere@overthere.com)")
        pkg.Originator= SpdxCreatorV2("NOASSERTION")
        pkg.DownloadLocation= SpdxDownloadLocationV2("git+https://github.com/SamuraiAku/SPDX.jl.git")
        pkg.FilesAnalyzed= true
        pkg.VerificationCode= SpdxPkgVerificationCodeV2("d6a770ba38583ed4bb4525bd96e50461655d2758",  ["./package.spdx"])
        push!(pkg.Checksums, SpdxChecksumV2("SHA1: 85ed0817af83a24ad8da68c2b5094de69833983c"))
        pkg.HomePage= "https://github.com/SamuraiAku/SPDX.jl"
        pkg.SourceInfo= "Where did this code come from?"
        pkg.LicenseConcluded= SpdxLicenseExpressionV2("MIT")
        push!(pkg.LicenseInfoFromFiles, SpdxLicenseExpressionV2("MIT"))
        push!(pkg.LicenseInfoFromFiles, SpdxLicenseExpressionV2("BSD-3 WITH Exception"))
        pkg.LicenseDeclared= SpdxLicenseExpressionV2("MIT")
        pkg.LicenseComments= "Anything to say?"
        pkg.Copyright= "Copyright 2022 SamuraiAku"
        pkg.Summary= "This is a summary of the package"
        pkg.DetailedDescription= "More details of the package."
        pkg.Comment= "It's a pretty good piece of code."
        push!(pkg.ExternalReferences, SpdxPackageExternalReferenceV2("SECURITY", "cpe23Type", "cpe:2.3:a:pivotal_software:spring_framework:4.1.0:*:*:*:*:*:*:*"))
        push!(pkg.Attributions, "Attribution 1")
        pkg.PrimaryPurpose= SpdxPkgPurposeV2("APPLICATION")
        pkg.ReleaseDate= SpdxTimeV2(now())
        pkg.BuiltDate= SpdxTimeV2(now()-Dates.Day(1))
        pkg.ValidUntilDate= SpdxTimeV2(now()+Dates.Day(3))
            pkg_annotation= SpdxAnnotationV2()
            pkg_annotation.Annotator= SpdxCreatorV2(" Person:  Jane Doe    (nowhere@loopback.com)")
            pkg_annotation.Created= SpdxTimeV2(now())
            pkg_annotation.Type= "REVIEW"
            pkg_annotation.Comment= "This is a comment"
        push!(pkg.Annotations, pkg_annotation)
    push!(a.Packages, pkg)

    # Add a File
        file= SpdxFileV2("./src/Foo.jl", "SpdxRef-F1")
        push!(file.Type, SpdxFileTypeV2("SOURCE"))
        push!(file.Type, SpdxFileTypeV2("TEXT"))
        push!(file.Checksum, SpdxChecksumV2("SHA1: 85ed0817af83a24ad8da68c2b5094de69833983c"))
        push!(file.Checksum, SpdxChecksumV2("MD5: 624c1abb3664f4b35547e7c73864ad24"))
        file.LicenseConcluded= SpdxLicenseExpressionV2("MIT")
        push!(file.LicensesInFile, SpdxLicenseExpressionV2("MIT"))
        push!(file.LicensesInFile, SpdxLicenseExpressionV2("BSD-3"))
        file.LicenseComments= "I have a comment."
        file.Copyright= "Copyright 2022 SamuraiAku"
        file.FileComments= "Have a look at this file."
        file.Notice= "Are we sure about this license?"
        push!(file.Contributors, "SamuraiAku")
        push!(file.Contributors, "The SPDX project")
        push!(file.Attributions, "Attribution 1")
        push!(file.Attributions, "Attribution 2")
            file_annotation= SpdxAnnotationV2()
            file_annotation.Annotator= SpdxCreatorV2(" Person:  Jack Frost    (somewhere@overthere.com)")
            file_annotation.Created= SpdxTimeV2(now())
            file_annotation.Type= "REVIEW"
            file_annotation.Comment= "This is a comment"
        push!(file.Annotations, file_annotation)
    push!(a.Files, file)

    # Add a Snippet
        snip= SpdxSnippetV2("SpdxRef-S1", "SpdxRef-F1")
        push!(snip.SnippetRange, SpdxSnippetRangeV2("SpdxRef-F1", "SnippetByteRange", "3000:4000"))
        snip.LicenseConcluded= SpdxLicenseExpressionV2("MIT")
        push!(snip.LicenseInfo, SpdxLicenseExpressionV2("MIT"))
        push!(snip.LicenseInfo, SpdxLicenseExpressionV2("GPL-2.0-only WITH Exception"))
        snip.LicenseComments= "Not much to say about this."
        snip.Copyright= "Copyright 2022 SamuraiAku"
        snip.SnippetComments= "You should know where this came from"
        snip.Name= "MySnippet"
        push!(snip.Attributions, "Attribution 1")
        push!(snip.Attributions, "Attribution 2")
          snip_annotation= SpdxAnnotationV2()
          snip_annotation.Annotator= SpdxCreatorV2(" Person:  John Doe    (everywhere@loopback.com)")
          snip_annotation.Created= SpdxTimeV2(now())
          snip_annotation.Type= "REVIEW"
          snip_annotation.Comment= "This is a comment"
        push!(snip.Annotations, snip_annotation)
    push!(a.Snippets, snip)

    # Add a custom Licsnse
        customLic= SpdxLicenseInfoV2("LicenseRef-ID1")
        customLic.ExtractedText= "This is a test license. You have permission to share the code with your friends"
        customLic.Name= "test license"
        push!(customLic.URL, "https://nowhere.loopback.com")
        push!(customLic.URL, "https://julialang.org")
    push!(a.LicenseInfo, customLic)

    # Relationships
    push!(a.Relationships, SpdxRelationshipV2("SpdxRef-P1  CONTAINS  SpdxRef-F1"))
    push!(a.Relationships, SpdxRelationshipV2("SPDXRef-DOCUMENT DESCRIBES SpdxRef-P1"))

    # Document Annotation
        doc_annotation= SpdxAnnotationV2()
        doc_annotation.Annotator= SpdxCreatorV2(" Person:  Harry Doe    (somewhere@loopback.com)")
        doc_annotation.Created= SpdxTimeV2(now())
        doc_annotation.Type= "REVIEW"
        doc_annotation.Comment= "This is a pretty good test document"
    push!(a.Annotations, doc_annotation)


    # Create object from JSON fragment
    c_json= """{
        "spdxVersion" : "SPDX-2.3",  
        "dataLicense" : "CC0-1.0",                  
        "SPDXID" : "SPDXRef-DOCUMENT",   
        "name" : "SPDX.jl",
        "documentDescribes" : ["SpdxRef-P1"],
        "documentNamespace" : "http://spdx.org/spdxdocs/spdx-example-444504E0-4F89-41D3-9A0C-0305E82C3301",
        "externalDocumentRefs" : [
            {
                "externalDocumentId" : "DocumentRef-spdx-tool-1.2",
                "checksum" : {
                    "algorithm" : "SHA1",
                    "checksumValue" : "d6a770ba38583ed4bb4525bd96e50461655d2759"
                },
                "spdxDocument" : "http://spdx.org/spdxdocs/spdx-tools-v1.2-3F2504E0-4F89-41D3-9A0C-0305E82C3301"
            }
        ],
        "creationInfo": {
            "comment" : "This is a comment",
            "created" : "$(a.CreationInfo.Created)",
            "creators" : [ "Person: Jane Doe (nowhere@loopback.com)" ],
            "licenseListVersion" : "3.9"
        },
        "comment" : "I don't have very much to say about it.",

        "packages" : [
            {
                "name": "Package1",
                "SPDXID": "SpdxRef-P1",
                "versionInfo": "v1.0.0",
                "packageFileName": "./src",
                "supplier": "Person: Jane Doe (somewhere@overthere.com)",
                "originator": "NOASSERTION",
                "downloadLocation": "git+https://github.com/SamuraiAku/SPDX.jl.git",
                "filesAnalyzed": true,
                "packageVerificationCode": {
                    "packageVerificationCodeValue": "d6a770ba38583ed4bb4525bd96e50461655d2758",
                    "packageVerificationCodeExcludedFiles": ["./package.spdx"]
                },
                "checksums": [
                    {
                        "algorithm": "SHA1",
                        "checksumValue": "85ed0817af83a24ad8da68c2b5094de69833983c"
                    }
                ],
                "homepage": "https://github.com/SamuraiAku/SPDX.jl",
                "sourceInfo": "Where did this code come from?",
                "licenseConcluded": "MIT",
                "licenseInfoFromFiles": ["MIT", "BSD-3 WITH Exception"],
                "licenseDeclared": "MIT",
                "licenseComments": "Anything to say?",
                "copyrightText": "Copyright 2022 SamuraiAku",
                "summary": "This is a summary of the package",
                "description": "More details of the package.",
                "comment": "It's a pretty good piece of code.",
                "externalRefs": [
                    {
                        "referenceCategory": "SECURITY",
                        "referenceLocator": "cpe:2.3:a:pivotal_software:spring_framework:4.1.0:*:*:*:*:*:*:*",
                        "referenceType": "cpe23Type"
                    }
                ],
                "attributionTexts": ["Attribution 1"],
                "primaryPackagePurpose": "APPLICATION",
                "releaseDate": "$(pkg.ReleaseDate)",
                "builtDate": "$(pkg.BuiltDate)",
                "validUntilDate": "$(pkg.ValidUntilDate)",
                "annotations": [
                    {
                        "annotationDate" : "$(pkg_annotation.Created)",
                        "annotationType" : "REVIEW",
                        "annotator" : "Person: Jane Doe (nowhere@loopback.com)",
                        "comment" : "This is a comment"
                    }
                ]
            }
        ],

        "files": [
            {
                "fileName" : "./src/Foo.jl",
                "SPDXID" : "SpdxRef-F1",
                "fileTypes" : ["SOURCE", "TEXT"],
                "checksums" : [ {
                    "algorithm" : "SHA1",
                    "checksumValue" : "85ed0817af83a24ad8da68c2b5094de69833983c"
                    }, {
                    "algorithm" : "MD5",
                    "checksumValue" : "624c1abb3664f4b35547e7c73864ad24"
                } ],
                "licenseConcluded" : "MIT",
                "licenseInfoInFiles" : ["MIT", "BSD-3"],
                "licenseComments" : "I have a comment.",
                "copyrightText" : "Copyright 2022 SamuraiAku",
                "comment" : "Have a look at this file.",
                "noticeText" : "Are we sure about this license?",
                "fileContributors" : ["SamuraiAku", "The SPDX project"],
                "attributionTexts" : ["Attribution 1", "Attribution 2"],
                "annotations" : [ {
                    "annotationDate" : "$(file_annotation.Created)",
                    "annotationType" : "REVIEW",
                    "annotator" : "Person: Jack Frost  (somewhere@overthere.com)",
                    "comment" : "This is a comment"
                  } ]
            }
        ],

        "snippets" : [
            {
                "SPDXID" : "SpdxRef-S1",
                "comment" : "You should know where this came from",
                "copyrightText" : "Copyright 2022 SamuraiAku",
                "licenseComments" : "Not much to say about this.",
                "licenseConcluded" : "MIT",
                "licenseInfoInSnippets" : [ "MIT", "GPL-2.0-only WITH Exception"],
                "name" : "MySnippet",
                "ranges" : [ {
                  "endPointer" : {
                    "offset" : 4000,
                    "reference" : "SpdxRef-F1"
                  },
                  "startPointer" : {
                    "offset" : 3000,
                    "reference" : "SpdxRef-F1"
                  }
                } ],
                "snippetFromFile" : "SpdxRef-F1",
                "attributionTexts" : ["Attribution 1", "Attribution 2"],
                "annotations" : [ {
                  "annotationDate" : "$(snip_annotation.Created)",
                  "annotationType" : "REVIEW",
                  "annotator" : "Person: John Doe (everywhere@loopback.com)",
                  "comment" : "This is a comment"
                } ]
            }
        ],

        "hasExtractedLicensingInfos" : [
            {
                "licenseId" : "LicenseRef-ID1",
                "extractedText" : "This is a test license. You have permission to share the code with your friends",
                "name" : "test license",
                "seeAlsos" : ["https://nowhere.loopback.com", "https://julialang.org"]
            }
        ],

        "relationships" : [
            {
                "spdxElementId" : "SpdxRef-P1",
                "relationshipType" : "CONTAINS",
                "relatedSpdxElement" : "SpdxRef-F1"
            }
        ],

        "annotations": [
            {
                "annotationDate" : "$(doc_annotation.Created)",
                "annotationType" : "REVIEW",
                "annotator" : "Person:  Harry Doe    (somewhere@loopback.com)",
                "comment" : "This is a pretty good test document"
            }
        ]
    }"""
    # 

    c_dict= JSON.parse(c_json)
    c= SPDX.convert_from_JSON(c_dict, SPDX.SpdxDocumentV2_NameTable, SpdxDocumentV2)
    @test SPDX.compare_b(a, c)

    # Create object from TagValue parse
    d_tv= IOBuffer("
        SPDXVersion: SPDX-2.3
        DataLicense: CC0-1.0
        SPDXID: SPDXRef-DOCUMENT
        DocumentName: SPDX.jl
        DocumentNamespace: http://spdx.org/spdxdocs/spdx-example-444504E0-4F89-41D3-9A0C-0305E82C3301
        ExternalDocumentRef: DocumentRef-spdx-tool-1.2 http://spdx.org/spdxdocs/spdx-tools-v1.2-3F2504E0-4F89-41D3-9A0C-0305E82C3301 SHA1: d6a770ba38583ed4bb4525bd96e50461655d2759
        Creator: Person: Jane Doe (nowhere@loopback.com)
        Created: $(a.CreationInfo.Created)
        CreatorComment: <text>This is a comment</text>
        LicenseListVersion: 3.9
        DocumentComment: I don't have very much to say about it.

        # Package
        PackageName:  Package1
        SPDXID:  SpdxRef-P1
        PackageVersion:  v1.0.0
        PackageFileName:  ./src
        PackageSupplier:  Person: Jane Doe (somewhere@overthere.com)
        PackageOriginator:  NOASSERTION
        PackageDownloadLocation:  git+https://github.com/SamuraiAku/SPDX.jl.git
        FilesAnalyzed:  true
        PackageVerificationCode: d6a770ba38583ed4bb4525bd96e50461655d2758 (excludes: ./package.spdx)
        PackageChecksum:    SHA1: 85ed0817af83a24ad8da68c2b5094de69833983c
        PackageHomePage:  https://github.com/SamuraiAku/SPDX.jl
        PackageSourceInfo: Where did this code come from?
        PackageLicenseConcluded:  MIT
        PackageLicenseInfoFromFiles:  MIT
        PackageLicenseInfoFromFiles: BSD-3 WITH Exception
        PackageLicenseDeclared: MIT  
        PackageLicenseComments:  Anything to say?
        PackageCopyrightText:  Copyright 2022 SamuraiAku
        PackageSummary:  This is a summary of the package
        PackageDescription:   More details of the package.
        PackageComment:   It's a pretty good piece of code.
        ExternalRef: SECURITY cpe23Type  cpe:2.3:a:pivotal_software:spring_framework:4.1.0:*:*:*:*:*:*:*
        PackageAttributionText: Attribution 1
        PrimaryPackagePurpose: APPLICATION
        ReleaseDate: $(pkg.ReleaseDate)
        BuiltDate: $(pkg.BuiltDate)
        ValidUntilDate: $(pkg.ValidUntilDate)
        Annotator: Person: Jane Doe (nowhere@loopback.com)
        AnnotationDate: $(pkg_annotation.Created)
        AnnotationType: REVIEW
        AnnotationComment: This is a comment
        SPDXREF: SpdxRef-P1

        # File
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
        Annotator: Person: Jack Frost  (somewhere@overthere.com)
        AnnotationDate: $(file_annotation.Created)
        AnnotationType: REVIEW
        AnnotationComment: <text>This is a comment</text>
        SPDXREF: SpdxRef-F1

        # Snippet
        SnippetSPDXID: SpdxRef-S1
        SnippetFromFileSPDXID: SpdxRef-F1
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

        # Other Licenses
        LicenseID: LicenseRef-ID1
        ExtractedText: <text>This is a test license. You have permission to share the code with your friends</text>
        LicenseName: test license
        LicenseCrossReference: https://nowhere.loopback.com
        LicenseCrossReference: https://julialang.org
        
        # Annotations
        Annotator: Person: John Doe (everywhere@loopback.com)
        AnnotationDate: $(snip_annotation.Created)
        AnnotationType: REVIEW
        AnnotationComment: <text>This is a comment</text>
        SPDXREF: SpdxRef-S1

        # Relationships
        Relationship: SPDXRef-DOCUMENT DESCRIBES SpdxRef-P1

        # Annotations
        Annotator: Person: Harry Doe (somewhere@loopback.com)
        AnnotationDate: $(doc_annotation.Created)
        AnnotationType: REVIEW
        AnnotationComment: <text>This is a pretty good test document</text>
        SPDXREF: SPDXRef-DOCUMENT
    ")
    # 

    d= SPDX.parse_TagValue(d_tv, SPDX.SpdxDocumentV2_NameTable, SpdxDocumentV2)
    @test SPDX.compare_b(a, d)
end