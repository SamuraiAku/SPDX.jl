@testset "SpdxPackageExternalReference" begin
    a= SpdxPackageExternalReferenceV2("SECURITY", "cpe23Type", "cpe:2.3:a:pivotal_software:spring_framework:4.1.0:*:*:*:*:*:*:*")
    a.Comment= "This is a comment."

    b= SpdxPackageExternalReferenceV2("SECURITY  cpe23Type  cpe:2.3:a:pivotal_software:spring_framework:4.1.0:*:*:*:*:*:*:*")
    b.Comment= "This is a comment."
    @test SPDX.compare_b(a, b)
end

@testset "SpdxPkgVerificationCode" begin
    a= SpdxPkgVerificationCodeV2("d6a770ba38583ed4bb4525bd96e50461655d2758", ["./package.spdx", "./otherPkg"])

    b= SpdxPkgVerificationCodeV2("d6a770ba38583ed4bb4525bd96e50461655d2758  (excludes: ./package.spdx ./otherPkg)")
    @test SPDX.compare_b(a, b)
end

@testset "SpdxPkgPurpose" begin
    str= "LIBRARY"
    a= SpdxPkgPurposeV2(str)

    @test string(a) == str
end

@testset "SpdxDownloadLocation" begin
    # start with processing a bunch of example strings
    # test that the string version matches the original
    test_strings= [
        "http://ftp.gnu.org/gnu/glibc/glibc-ports-2.15.tar.gz",
        "NOASSERTION",
        "NONE",
        "git+https://git.myproject.org/MyProject.git",
        "git+https://git.myproject.org/MyProject#src/Class.java",
        "git+https://git.myproject.org/MyProject.git@v1.0",
        "git+https://git.myproject.org/MyProject.git@master#/src/MyClass.cpp",
        "BAD_TEST_STRING"
    ]

    for str in test_strings
        @test str == string(SpdxDownloadLocationV2(str))
    end
end

@testset "SpdxPackage" begin
    a= SpdxPackageV2("SpdxRef-P1")
    a.Name= "Package1"
    a.Version= "v1.0.0"
    a.FileName= "./src"
    a.Supplier= SpdxCreatorV2("Person: Jane Doe (somewhere@overthere.com)")
    a.Originator= SpdxCreatorV2("Person: SamuraiAku (loopback@here.com)")
    a.DownloadLocation= SpdxDownloadLocationV2("git+https://github.com/SamuraiAku/SPDX.jl.git")
    a.FilesAnalyzed= false
    a.VerificationCode= SpdxPkgVerificationCodeV2("d6a770ba38583ed4bb4525bd96e50461655d2758",  ["./package.spdx"])
    push!(a.Checksums, SpdxChecksumV2("SHA1: 85ed0817af83a24ad8da68c2b5094de69833983c"))
    a.HomePage= "https://github.com/SamuraiAku/SPDX.jl"
    a.SourceInfo= "Where did this code come from?"
    a.LicenseConcluded= SpdxLicenseExpressionV2("MIT")
    push!(a.LicenseInfoFromFiles, SpdxLicenseExpressionV2("MIT"))
    push!(a.LicenseInfoFromFiles, SpdxLicenseExpressionV2("BSD-3 WITH Exception"))
    a.LicenseDeclared= SpdxLicenseExpressionV2("MIT")
    a.LicenseComments= "Anything to say?"
    a.Copyright= "Copyright 2022 SamuraiAku"
    a.Summary= "This is a summary of the package"
    a.DetailedDescription= "More details of the package."
    a.Comment= "It's a pretty good piece of code."
    push!(a.ExternalReferences, SpdxPackageExternalReferenceV2("SECURITY", "cpe23Type", "cpe:2.3:a:pivotal_software:spring_framework:4.1.0:*:*:*:*:*:*:*"))
    push!(a.Attributions, "Attribution 1")
    a.PrimaryPurpose= SpdxPkgPurposeV2("APPLICATION")
    a.ReleaseDate= SpdxTimeV2(now())
    a.BuiltDate= SpdxTimeV2(now()-Dates.Day(1))
    a.ValidUntilDate= SpdxTimeV2(now()+Dates.Day(3))
        annotation= SpdxAnnotationV2()
        annotation.Annotator= SpdxCreatorV2(" Person:  Jane Doe    (nowhere@loopback.com)")
        annotation.Created= SpdxTimeV2(now())
        annotation.Type= "REVIEW"
        annotation.Comment= "This is a comment"
    push!(a.Annotations, annotation)

    # Create object from JSON
    # Deliberately add some leading and trailing whitespace to test the code.
    c_json= """{
        "name": "Package1",
        "SPDXID": "  SpdxRef-P1    ",
        "versionInfo": "v1.0.0",
        "packageFileName": "./src",
        "supplier": "Person: Jane Doe (somewhere@overthere.com)",
        "originator": "Person: SamuraiAku (loopback@here.com)",
        "downloadLocation": "git+https://github.com/SamuraiAku/SPDX.jl.git",
        "filesAnalyzed": false,
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
        "releaseDate": "$(a.ReleaseDate)",
        "builtDate": "$(a.BuiltDate)",
        "validUntilDate": "$(a.ValidUntilDate)",
        "annotations": [
            {
                "annotationDate" : "$(annotation.Created)",
                "annotationType" : "REVIEW",
                "annotator" : "Person: Jane Doe (nowhere@loopback.com)",
                "comment" : "This is a comment"
            }
        ]

    }"""
    
    c_dict= JSON.parse(c_json)
    c= SPDX.convert_from_JSON(c_dict, SPDX.SpdxPackageV2_NameTable, SpdxPackageV2)
    @test SPDX.compare_b(a, c)

    # Create object from TagValue parse
    d_tv= IOBuffer("
    PackageName:  Package1
    SPDXID:  SpdxRef-P1
    PackageVersion:  v1.0.0
    PackageFileName:  ./src
    PackageSupplier:  Person: Jane Doe (somewhere@overthere.com)
    PackageOriginator:  Person: SamuraiAku (loopback@here.com)
    PackageDownloadLocation:  git+https://github.com/SamuraiAku/SPDX.jl.git
    FilesAnalyzed:  False
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
    ReleaseDate: $(a.ReleaseDate)
    BuiltDate: $(a.BuiltDate)
    ValidUntilDate: $(a.ValidUntilDate)
    Annotator: Person: Jane Doe (nowhere@loopback.com)
    AnnotationDate: $(annotation.Created)
    AnnotationType: REVIEW
    AnnotationComment: This is a comment
    ")

    d= SPDX.parse_TagValue(d_tv, SPDX.SpdxPackageV2_NameTable, SpdxPackageV2)
    @test SPDX.compare_b(a, d)
end