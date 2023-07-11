# SPDX-License-Identifier: MIT

export SpdxCreationInfoV2, SpdxNamespaceV2, SpdxDocumentExternalReferenceV2, SpdxDocumentV2

#############################################
const SpdxCreationInfoV2_NameTable= Table(
         Symbol= [ :LicenseListVersion,   :Creator,                 :Created,     :CreatorComment],
        Mutable= [  true,                  true,                     true,         true], 
    Constructor= [  :string,               :SpdxCreatorV2,           :SpdxTimeV2,  :string],
      NameTable= [  nothing,               nothing,                  nothing,      nothing],    
      Multiline= [  false,                 false,                    false,        true],
       JSONname= [ "licenseListVersion",   "creators",               "created",    "comment"],
   TagValueName= [ "LicenseListVersion",   "Creator",                "Created",    "CreatorComment"],
)

Base.@kwdef mutable struct SpdxCreationInfoV2 <: AbstractSpdxData
    LicenseListVersion::Union{Missing, String}= missing
    Creator::Vector{SpdxCreatorV2}= SpdxCreatorV2[]
    Created::Union{Missing, SpdxTimeV2}= missing
    CreatorComment::Union{Missing, String}= missing
end

######################################
struct SpdxNamespaceV2 <: AbstractSpdx
    URI::String
    UUID::Union{String, Nothing}
end

function SpdxNamespaceV2(Namespace::AbstractString)
    # The URL search is taken from Appendix B of RFC 3986, parts 1-5
    uri_regex= r"(?<URL>^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*))"
    best_practice_regex= r"(?<URL>^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*))-(?<UUID>[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12})"
    
    # Assume that nearly every SPDX document out there will follow best practices from the SPDX specification for forming a namespace
    match_namespace= match(best_practice_regex, Namespace)
    if match_namespace !== nothing
        obj= SpdxNamespaceV2(match_namespace[:URL], match_namespace[:UUID])
    else
        match_namespace= match(uri_regex, Namespace)
        println("WARNING: Namespace format does not follow SPDX recommended best practices")
        for idx in 2:6
            if match_namespace[idx] === nothing
                println("ERROR: Namespace format is not a valid URI")
                break;
            end
        end
        obj= SpdxNamespaceV2(match_namespace[:URL], nothing)
    end
    return obj
end


######################################
const SpdxDocumentExternalReferenceV2_NameTable= Table(
         Symbol= [ :SPDXID,              :Namespace,         :Checksum,   ],
        Mutable= [  false,                false,              false       ],
    Constructor= [  :string,              :SpdxNamespaceV2,   :SpdxChecksumV2],
      NameTable= [  nothing,              nothing,            SpdxChecksumV2_NameTable],
      Multiline= [  false,                false,              false,      ],
       JSONname= [ "externalDocumentId",  "spdxDocument",     "checksum", ],
)

struct SpdxDocumentExternalReferenceV2 <: AbstractSpdxElement
    SPDXID::String
    Namespace::SpdxNamespaceV2
    Checksum::SpdxChecksumV2
end

function SpdxDocumentExternalReferenceV2(TVstring::AbstractString)
    regex_reference= r"^\s*(?<SPDXID>[^\s]+)\s+(?<Namespace>[^\s]+)\s+(?<Checksum>.+)$"
    match_reference= match(regex_reference, TVstring)
    return SpdxDocumentExternalReferenceV2(match_reference["SPDXID"], SpdxNamespaceV2(match_reference["Namespace"]), SpdxChecksumV2(match_reference["Checksum"]))
end

#############################################
const SpdxDocumentV2_NameTable= Table(
         Symbol= [ :Version,       :DataLicense,                    :SPDXID,    :Name,           :Namespace,           :ExternalDocReferences,                      :CreationInfo,                   :DocumentComment,   :Packages,                 :Files,                  :Snippets,                 :LicenseInfo,                  :Relationships,                :Annotations],
        Mutable= [  false,          false,                           false,      true,            true,                 true,                                        true,                            true,               true,                      true,                    true,                      true,                          true,                          true],
    Constructor= [  :string,        :SpdxSimpleLicenseExpressionV2,  :string,    :string,         :SpdxNamespaceV2,     :SpdxDocumentExternalReferenceV2,            :SpdxCreationInfoV2,             :string,            :SpdxPackageV2,            :SpdxFileV2,             :SpdxSnippetV2,            :SpdxLicenseInfoV2,            :SpdxRelationshipV2,           :SpdxAnnotationV2],
      NameTable= [  nothing,        nothing,                         nothing,    nothing,         nothing,              SpdxDocumentExternalReferenceV2_NameTable,   SpdxCreationInfoV2_NameTable,    nothing,            SpdxPackageV2_NameTable,   SpdxFileV2_NameTable,    SpdxSnippetV2_NameTable,   SpdxLicenseInfoV2_NameTable,   SpdxRelationshipV2_NameTable,  SpdxAnnotationV2_NameTable],
      Multiline= [  false,          false,                           false,      false,           false,                false,                                       false,                           true,               false,                     false,                   false,                     false,                         false,                         false],
       JSONname= [  "spdxVersion",  "dataLicense",                   "SPDXID",   "name",          "documentNamespace",  "externalDocumentRefs",                      "creationInfo",                  "comment",          "packages",                "files",                 "snippets",                "hasExtractedLicensingInfos",  "relationships",               "annotations"],
   TagValueName= [  "SPDXVersion",  "DataLicense",                   "SPDXID",   "DocumentName",  "DocumentNamespace",  "ExternalDocumentRef",                       nothing,                         "DocumentComment",  "PackageName",             "FileName",              "SnippetSPDXID",           "LicenseID",                   "Relationship",                "Annotator"] 
)

Base.@kwdef mutable struct SpdxDocumentV2 <: AbstractSpdxData
    const Version::String= "SPDX-2.3"
    const DataLicense::SpdxSimpleLicenseExpressionV2= SpdxSimpleLicenseExpressionV2("CC0-1.0")
    const SPDXID::String= "SPDXRef-DOCUMENT"
    Name::Union{Missing, String}= missing
    Namespace::Union{Missing, SpdxNamespaceV2}= missing
    ExternalDocReferences::Vector{SpdxDocumentExternalReferenceV2}= SpdxDocumentExternalReferenceV2[]
    CreationInfo::SpdxCreationInfoV2= SpdxCreationInfoV2()
    DocumentComment::Union{Missing, String}= missing
    Packages::Vector{SpdxPackageV2}= SpdxPackageV2[]
    Files::Vector{SpdxFileV2}= SpdxFileV2[]
    Snippets::Vector{SpdxSnippetV2}= SpdxSnippetV2[]
    LicenseInfo::Vector{SpdxLicenseInfoV2}= SpdxLicenseInfoV2[]
    Relationships::Vector{SpdxRelationshipV2}= SpdxRelationshipV2[]
    Annotations::Vector{SpdxAnnotationV2}= SpdxAnnotationV2[]
end

function SpdxDocumentV2(Version::AbstractString, DataLicense::SpdxSimpleLicenseExpressionV2, SPDXID::AbstractString)
    return SpdxDocumentV2(Version= Version, DataLicense= DataLicense, SPDXID= SPDXID)
end