const SpdxPackageV2_NameTable= Table(  
         Symbol= [ :SPDXID,  :Name,          :Version,          :FileName,          :Supplier,          :Originator,          :DownloadLocation,          :FilesAnalyzed,   :VerificationCode,          :Checksums,                 :HomePage,          :SourceInfo,          :LicenseConcluded,          :LicenseInfoFromFiles,                    :LicenseDeclared,          :LicenseComments,          :Copyright,              :Summary,          :DetailedDescription,   :Comment,          :ExternalReferences,                        :Attributions],
        Default= [  nothing,  missing,        missing,           missing,            missing,            missing,              missing,                    missing,          missing,                    Vector{SpdxChecksumV2}(),   missing,            missing,              missing,                    Vector{SpdxSimpleLicenseExpressionV2}(),  missing,                   missing,                   missing,                 missing,           missing,                missing,           Vector{SpdxPackageExternalReferenceV2}(),   Vector{String}()],
        Mutable= [  false,    true,           true,              true,               true,               true,                 true,                       true,             true,                       true,                       true,               true,                 true,                       true,                                     true,                      true,                      true,                    true,              true,                   true,              true,                                       true],
       JSONname= [ "SPDXID",  "name",         "versionInfo",     "packageFileName",  "supplier",         "originator",         "downloadLocation",         "filesAnalyzed",  "packageVerificationCode",  "checksums",                "homepage",         "sourceInfo",         "licenseConcluded",         "licenseInfoFromFiles",                   "licenseDeclared",         "licenseComments",         "copyrightText",         "summary",         "description",          "comment",         "externalRefs",                             "attributionTexts" ],
   TagValueName= [ "SPDXID",  "PackageName",  "PackageVersion",  "PackageFileName",  "PackageSupplier",  "PackageOriginator",  "PackageDownloadLocation",  "FilesAnalyzed",  "PackageVerificationCode",  "PackageChecksum",          "PackageHomePage",  "PackageSourceInfo",  "PackageLicenseConcluded",  "PackageLicenseInfoFromFiles",            "PackageLicenseDeclared",  "PackageLicenseComments",  "PackageCopyrightText",  "PackageSummary",  "PackageDescription",   "PackageComment",  "ExternalRef",                              "PackageAttributionText"]
)

const SpdxPackageExternalReferenceV2_NameTable= Table(
         Symbol= [ :Category,             :RefType,            :Locator,             :Comment],
        Default= [  nothing,               nothing,             nothing,              nothing],
        Mutable= [  false,                 false,               false,                false],
       JSONname= [ "referenceCategory",    "referenceType",     "referenceLocator",   "comment"],
)

const SpdxChecksumV2_NameTable= Table(
         Symbol= [ :Algorithm,   :Value          ],
        Default= [  nothing,      nothing        ],
        Mutable= [  false,        false          ],
       JSONname= [ "algorithm",   "checksumValue"],
)

const SpdxDocumentExternalReferenceV2_NameTable= Table(
         Symbol= [ :SPDXID,              :Namespace,      :Checksum,   ],
        Default= [  nothing,              nothing,         nothing,    ],
        Mutable= [  false,                false,           false,      ],
       JSONname= [ "externalDocumentId",  "spdxDocument",  "checksum", ],
)

const SpdxCreationInfoV2_NameTable= Table(
         Symbol= [ :LicenseListVersion,   :Creator,                 :Created,   :CreatorComment],
        Default= [  missing,               Vector{SpdxCreatorV2}(),  missing,    missing],
        Mutable= [  true,                  true,                     true,       true], 
       JSONname= [ "licenseListVersion",   "creators",               "created",  "comment"],
   TagValueName= [ "LicenseListVersion",   "Creator",                "Created",  "CreatorComment"],
)

const SpdxRelationshipV2_NameTable= Table(
     Symbol= [ :SPDXID,          :RelationshipType,    :RelatedSPDXID],
    Default= [  nothing,          nothing,              nothing],
    Mutable= [  false,            false,                false], 
   JSONname= [  "spdxElementId",  "relationshipType",   "relatedSpdxElement"]
)

const SpdxDocumentV2_NameTable= Table(
         Symbol= [ :Version,       :DataLicense,    :SPDXID,    :Name,           :Namespace,           :ExternalReferences,                         :CreationInfo,         :DocumentComment,   :Packages,                 :Relationships],
        Default= [  nothing,        nothing,         nothing,    missing,         missing,              Vector{SpdxDocumentExternalReferenceV2}(),   SpdxCreationInfoV2(),  missing,            Vector{SpdxPackageV2}(),   Vector{SpdxRelationshipV2}()],
        Mutable= [  false,          false,           false,      true,            true,                 true,                                        true,                  true,               true,                      true],
       JSONname= [  "spdxVersion",  "dataLicense",   "SPDXID",   "name",          "documentNamespace",  "externalDocumentRefs",                      "creationInfo",        "comment",          "packages",                "relationships"],
   TagValueName= [  "SPDXVersion",  "DataLicense",   "SPDXID",   "DocumentName",  "DocumentNamespace",  "ExternalDocumentRef",                       nothing,               "DocumentComment",  nothing,                   nothing] 
)
