const SpdxPackageV2_NameTable= Table(  
     Symbol= [ :SPDXID,  :Name,    :Version,       :FileName,         :Supplier,  :Originator,   :DownloadLocation,   :FilesAnalyzed,   :VerificationCode,          :Checksums,        :HomePage,   :SourceInfo,   :LicenseConcluded,   :LicenseInfoFromFiles,                    :LicenseDeclared,   :LicenseComments,   :Copyright,       :Summary,   :DetailedDescription, :Comment,   :ExternalReferences,                   :ExternalReferenceComment, :Attributions],
    Default= [  nothing,  missing,  missing,        missing,           missing,    missing,       missing,             missing,          missing,                    Vector{String}(),  missing,     missing,       missing,             Vector{SpdxSimpleLicenseExpressionV2}(),  missing,            missing,            missing,          missing,    missing,              missing,    Vector{PackageExternalReferenceV2}(),  missing,                   Vector{String}()],
    Mutable= [  false,    true,     true,           true,              true,       true,          true,                true,             true,                       true,              true,        true,          true,                true,                                     true,               true,               true,             true,       true,                 true,       true,                                  true,                      true],
   JSONname= [ "SPDXID",  "name",   "versionInfo",  "packageFileName", "supplier", "originator",  "downloadLocation",  "filesAnalyzed",  "packageVerificationCode",  "checksums",       "homepage",  "sourceInfo",  "licenseConcluded",  "licenseInfoFromFiles",                   "licenseDeclared",  "licenseComments",  "copyrightText",  "summary",  "description",        "comment",  "externalRefs",                        "comment",                 "attributionTexts" ]
)

const SpdxDocumentV2_NameTable= Table(
     Symbol= [ :Version,       :DataLicense,    :SPDXID,    :Name,     :Namespace,           :ExternalReferences,                     :CreationInfo,    :DocumentComment,   :Packages,                 :Relationships],
    Default= [  nothing,        nothing,         nothing,    missing,   missing,              Vector{DocumentExternalReferenceV2}(),   missing,          missing,            Vector{SpdxPackageV2}(),   Vector{SpdxRelationshipV2}()],
    Mutable= [  false,          false,           false,      true,      true,                 true,                                    true,             true,               true,                      true],
   JSONname= [  "spdxVersion",  "dataLicense",   "SPDXID",   "name",    "documentNamespace",  "externalDocumentRefs",                  "creationInfo",   "comment",          "packages",                "relationships"]
)

const SpdxCreationInfoV2_NameTable= Table(
     Symbol= [ :LicenseListVersion,   :Creator,                 :Created,   :CreatorComment],
    Default= [  missing,               Vector{SpdxCreatorV2}(),  missing,    missing],
    Mutable= [  true,                  true,                     true,       true], 
   JSONname= [ "licenseListVersion",   "creators",               "created",  "comment"]
)