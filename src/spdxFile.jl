# SPDX-License-Identifier: MIT

export SpdxFileTypeV2, SpdxFileV2

#############################################
struct SpdxFileTypeV2 <: AbstractSpdx
    Value::String

    function SpdxFileTypeV2(fileType::AbstractString)
        if fileType in ("SOURCE", "BINARY", "ARCHIVE", "APPLICATION", "AUDIO", "IMAGE", "TEXT", "VIDEO", "DOCUMENTATION", "SPDX", "OTHER")
            return new(fileType)
        else
            println("FileType \"" * fileType * "\" not recognized!")
            return nothing
        end
    end
end

#############################################
const SpdxFileV2_NameTable= Table(
         Symbol= [ :Name,       :SPDXID,    :Type,                  :Checksum,                    :LicenseConcluded,               :LicensesInFile,             :LicenseComments,    :Copyright,             :FileComments,   :Notice,         :Contributors,         :Attributions,           :Annotations                  ],
        Mutable= [  false,       false,      true,                   true,                         true,                            true,                        true,                true,                   true,            true,            true,                  true,                    true,                        ],
    Constructor= [  :string,     :string,    :SpdxFileTypeV2,        :SpdxChecksumV2,              :SpdxLicenseExpressionV2,        :SpdxLicenseExpressionV2,    :string,             :string,                :string,         :string,         :string,               :string,                 :SpdxAnnotationV2,           ],
      NameTable= [  :nothing,    :nothing,   :nothing,               :SpdxChecksumV2_NameTable,    :nothing,                        :nothing,                    :nothing,            :nothing,               :nothing,        :nothing,        :nothing,              :nothing,                :SpdxAnnotationV2_NameTable, ],
      Multiline= [  false,       false,      false,                  false,                        false,                           false,                       true,                true,                   true,            true,            false,                 true,                    false,                       ],
       JSONname= [  "fileName",  "SPDXID",   "fileTypes",            "checksums",                  "licenseConcluded",              "licenseInfoInFiles",        "licenseComments",   "copyrightText",        "comment",       "noticeText",    "fileContributors",    "attributionTexts",      "annotations",               ],
   TagValueName= [  "FileName",  "SPDXID",   "FileType",             "FileChecksum",               "LicenseConcluded",              "LicenseInfoInFile",         "LicenseComments",   "FileCopyrightText",    "FileComment",   "FileNotice",    "FileContributor",     "FileAttributionText",   "Annotator",                 ],
)

Base.@kwdef mutable struct SpdxFileV2 <: AbstractSpdxData
    const Name::String
    const SPDXID::String
    Type::Vector{SpdxFileTypeV2}= Vector{SpdxFileTypeV2}()
    Checksum::Vector{SpdxChecksumV2}= Vector{SpdxChecksumV2}()
    LicenseConcluded::Union{Missing, SpdxComplexLicenseExpressionV2, SpdxSimpleLicenseExpressionV2}= missing
    LicensesInFile::Vector{Union{SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2}}= Vector{Union{SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2}}()
    LicenseComments::Union{Missing, String}= missing
    Copyright::Union{Missing, String}= missing
    FileComments::Union{Missing, String}= missing
    Notice::Union{Missing, String}= missing
    Contributors::Vector{String}= String[]
    Attributions::Vector{String}= String[]
    Annotations::Vector{SpdxAnnotationV2}= SpdxAnnotationV2[]
end

function SpdxFileV2(Name::AbstractString, SPDXID::AbstractString)
    return SpdxFileV2(Name= Name, SPDXID= SPDXID)
end