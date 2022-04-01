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
         Symbol= [ :Name,       :SPDXID,    :Type,                       :Checksum,                    :LicenseConcluded,               :LicensesInFile,                                                                  :LicenseComments,    :Copyright,             :FileComments,   :Notice,         :Contributors,         :Attributions,           :Annotations      ],
        Default= [  nothing,     nothing,    Vector{SpdxFileTypeV2}(),    Vector{SpdxChecksumV2}(),     missing,                         Vector{Union{SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2}}(),   missing,             missing,                missing,         missing,         Vector{String}(),      Vector{String}(),        Vector{SpdxAnnotationV2}(),  ],
        Mutable= [  false,       false,      true,                        true,                         true,                            true,                                                                             true,                true,                   true,            true,            true,                  true,                    true,                        ],
    Constructor= [  string,      string,     SpdxFileTypeV2,              SpdxChecksumV2,               SpdxLicenseExpressionV2,         SpdxLicenseExpressionV2,                                                          string,              string,                 string,          string,          string,                string,                  SpdxAnnotationV2,            ],
      NameTable= [  nothing,     nothing,    nothing,                     SpdxChecksumV2_NameTable,     nothing,                         nothing,                                                                          nothing,             nothing,                nothing,         nothing,         nothing,               nothing,                 SpdxAnnotationV2_NameTable,  ],
      Multiline= [  false,       false,      false,                       false,                        false,                           false,                                                                            true,                true,                   true,            true,            false,                 true,                    false,                       ],
       JSONname= [  "fileName",  "SPDXID",   "fileTypes",                 "checksums",                  "licenseConcluded",              "licenseInfoInFiles",                                                             "licenseComments",   "copyrightText",        "comment",       "noticeText",    "fileContributors",    "attributionTexts",      "annotations",               ],
   TagValueName= [  "FileName",  "SPDXID",   "FileType",                  "FileChecksum",               "LicenseConcluded",              "LicenseInfoInFile",                                                              "LicenseComments",   "FileCopyrightText",    "FileComment",   "FileNotice",    "FileContributor",     "FileAttributionText",   "Annotator",                 ],
)

struct SpdxFileV2 <: AbstractSpdxData
    Name::String
    SPDXID::String
    MutableFields::OrderedDict{Symbol, Any}
end

function SpdxFileV2(Name::AbstractString, SPDXID::AbstractString)
    MutableFields= init_MutableFields(SpdxFileV2_NameTable)
    return SpdxFileV2(Name, SPDXID, MutableFields)
end



