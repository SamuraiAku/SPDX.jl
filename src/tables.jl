const SpdxPackageExternalReferenceV2_NameTable= Table(
         Symbol= [ :Category,             :RefType,            :Locator,             :Comment],
        Default= [  nothing,               nothing,             nothing,              nothing],
        Mutable= [  false,                 false,               false,                false],
    Constructor= [  string,                string,              string,               string], 
      NameTable= [  nothing,               nothing,             nothing,              nothing],
      Multiline= [  false,                 false,               false,                true],
       JSONname= [ "referenceCategory",    "referenceType",     "referenceLocator",   "comment"],
   TagValueName= [  nothing,               nothing,              nothing,             "ExternalRefComment"]
)

const SpdxChecksumV2_NameTable= Table(
         Symbol= [ :Algorithm,   :Hash           ],
        Mutable= [  false,        false          ],
    Constructor= [  string,       string         ],
      NameTable= [  nothing,      nothing        ],
      Multiline= [  false,        false          ],
       JSONname= [ "algorithm",   "checksumValue"],
)

const SpdxPkgVerificationCodeV2_NameTable= Table(
         Symbol= [ :Hash,                           :ExcludedFiles  ],
        Mutable= [  false,                           false,         ],
    Constructor= [  string,                          Vector{String} ],
      NameTable= [  nothing,                         nothing        ],
      Multiline= [  false,                           false          ],
       JSONname= [  "packageVerificationCodeValue",  "packageVerificationCodeExcludedFiles"],
)

const SpdxDocumentExternalReferenceV2_NameTable= Table(
         Symbol= [ :SPDXID,              :Namespace,       :Checksum,   ],
        Mutable= [  false,                false,            false       ],
    Constructor= [  string,               SpdxNamespaceV2,  SpdxChecksumV2],
      NameTable= [  nothing,              nothing,          SpdxChecksumV2_NameTable],
      Multiline= [  false,                false,            false,      ],
       JSONname= [ "externalDocumentId",  "spdxDocument",   "checksum", ],
)

const SpdxCreationInfoV2_NameTable= Table(
         Symbol= [ :LicenseListVersion,   :Creator,                 :Created,     :CreatorComment],
        Default= [  missing,               Vector{SpdxCreatorV2}(),  missing,      missing],
        Mutable= [  true,                  true,                     true,         true], 
    Constructor= [  string,                SpdxCreatorV2,            SpdxTimeV2,   string],
      NameTable= [  nothing,               nothing,                  nothing,      nothing],    
      Multiline= [  false,                 false,                    false,        true],
       JSONname= [ "licenseListVersion",   "creators",               "created",    "comment"],
   TagValueName= [ "LicenseListVersion",   "Creator",                "Created",    "CreatorComment"],
)

const SpdxRelationshipV2_NameTable= Table(
         Symbol= [ :SPDXID,          :RelationshipType,    :RelatedSPDXID,         :Comment],
        Mutable= [  false,            false,                false,                  false], 
    Constructor= [  string,           string,               string,                 string],
      NameTable= [  nothing,          nothing,              nothing,                nothing],
      Multiline= [  false,            false,                false,                  true],
       JSONname= [  "spdxElementId",  "relationshipType",   "relatedSpdxElement",   "comment"],
   TagValueName= [  nothing,          nothing,              nothing,                "RelationshipComment"]
)

const SpdxPackageV2_NameTable= Table(  
         Symbol= [ :Name,              :SPDXID,   :Version,          :FileName,          :Supplier,          :Originator,          :DownloadLocation,          :FilesAnalyzed,   :VerificationCode,                      :Checksums,                 :HomePage,          :SourceInfo,          :LicenseConcluded,                :LicenseInfoFromFiles,                    :LicenseDeclared,                  :LicenseComments,          :Copyright,              :Summary,          :DetailedDescription,   :Comment,          :ExternalReferences,                        :Attributions],
        Default= [  missing,            nothing,   missing,           missing,            missing,            missing,              missing,                    missing,          missing,                                Vector{SpdxChecksumV2}(),   missing,            missing,              missing,                          Vector{SpdxSimpleLicenseExpressionV2}(),  missing,                           missing,                   missing,                 missing,           missing,                missing,           Vector{SpdxPackageExternalReferenceV2}(),   Vector{String}()],
        Mutable= [  true,               false,     true,              true,               true,               true,                 true,                       true,             true,                                   true,                       true,               true,                 true,                             true,                                     true,                              true,                      true,                    true,              true,                   true,              true,                                       true],
    Constructor= [  string,             string,    string,            string,             string,             string,               string,                     string,           SpdxPkgVerificationCodeV2,              SpdxChecksumV2,             string,             string,               SpdxSimpleLicenseExpressionV2,    SpdxSimpleLicenseExpressionV2,            SpdxSimpleLicenseExpressionV2,     string,                    string,                  string,            string,                 string,            SpdxPackageExternalReferenceV2,             string],    
      NameTable= [  nothing,            nothing,   nothing,           nothing,            nothing,            nothing,              nothing,                    nothing,          SpdxPkgVerificationCodeV2_NameTable,    SpdxChecksumV2_NameTable,   nothing,            nothing,              nothing,                          nothing,                                  nothing,                           nothing,                   nothing,                 nothing,           nothing,                nothing,           SpdxPackageExternalReferenceV2_NameTable,   nothing], 
      Multiline= [  false,              false,     false,             false,              false,              false,                false,                      false,            false,                                  false,                      false,              true,                 false,                            false,                                    false,                             true,                      true,                    true,              true,                   true,              false,                                      true],
       JSONname= [  "name",             "SPDXID",  "versionInfo",     "packageFileName",  "supplier",         "originator",         "downloadLocation",         "filesAnalyzed",  "packageVerificationCode",              "checksums",                "homepage",         "sourceInfo",         "licenseConcluded",               "licenseInfoFromFiles",                   "licenseDeclared",                 "licenseComments",         "copyrightText",         "summary",         "description",          "comment",         "externalRefs",                             "attributionTexts" ],
   TagValueName= [  "PackageName",      "SPDXID",  "PackageVersion",  "PackageFileName",  "PackageSupplier",  "PackageOriginator",  "PackageDownloadLocation",  "FilesAnalyzed",  "PackageVerificationCode",              "PackageChecksum",          "PackageHomePage",  "PackageSourceInfo",  "PackageLicenseConcluded",        "PackageLicenseInfoFromFiles",            "PackageLicenseDeclared",          "PackageLicenseComments",  "PackageCopyrightText",  "PackageSummary",  "PackageDescription",   "PackageComment",  "ExternalRef",                              "PackageAttributionText"]
)

const SpdxDocumentV2_NameTable= Table(
         Symbol= [ :Version,       :DataLicense,                    :SPDXID,    :Name,           :Namespace,           :ExternalReferences,                         :CreationInfo,                   :DocumentComment,   :Packages,                 :Relationships],
        Default= [  nothing,        nothing,                         nothing,    missing,         missing,              Vector{SpdxDocumentExternalReferenceV2}(),   SpdxCreationInfoV2(),            missing,            Vector{SpdxPackageV2}(),   Vector{SpdxRelationshipV2}()],
        Mutable= [  false,          false,                           false,      true,            true,                 true,                                        true,                            true,               true,                      true],
    Constructor= [  string,         SpdxSimpleLicenseExpressionV2,   string,     string,          SpdxNamespaceV2,      SpdxDocumentExternalReferenceV2,             SpdxCreationInfoV2,              string,             SpdxPackageV2,             SpdxRelationshipV2 ],
      NameTable= [  nothing,        nothing,                         nothing,    nothing,         nothing,              SpdxDocumentExternalReferenceV2_NameTable,   SpdxCreationInfoV2_NameTable,    nothing,            SpdxPackageV2_NameTable,   SpdxRelationshipV2_NameTable],
      Multiline= [  false,          false,                           false,      false,           false,                false,                                       false,                           true,               false,                     false],
       JSONname= [  "spdxVersion",  "dataLicense",                   "SPDXID",   "name",          "documentNamespace",  "externalDocumentRefs",                      "creationInfo",                  "comment",          "packages",                "relationships"],
   TagValueName= [  "SPDXVersion",  "DataLicense",                   "SPDXID",   "DocumentName",  "DocumentNamespace",  "ExternalDocumentRef",                       nothing,                         "DocumentComment",  nothing,                   "Relationship"] 
)
