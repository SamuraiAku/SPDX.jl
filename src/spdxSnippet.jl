#############################################
const SpdxSnippetPointerV2_NameTable= Table(
         Symbol= [ :SPDXID,       :Offset,               :LineNumber,  ],
        Default= [  nothing,       missing,               missing,     ],
        Mutable= [  false,         true,                  true,        ],
    Constructor= [  string,        UInt,                  UInt,        ],
      NameTable= [  nothing,       nothing,               nothing,     ],
      Multiline= [  false,         false,                 false,       ],
       JSONname= [  "reference",   "offset",              "lineNumber",],
   TagValueName= [  nothing,       "SnippetByteRange",    "SnippetLineRange",],
)

struct SpdxSnippetPointerV2 <: AbstractSpdxData
    SPDXID::String
    MutableFields::OrderedDict{Symbol, Any}
end

function SpdxSnippetPointerV2(SPDXID::AbstractString)
    MutableFields= init_MutableFields(SpdxSnippetPointerV2_NameTable)
    return SpdxSnippetPointerV2(SPDXID, MutableFields)
end

#############################################
const SpdxSnippetRangeV2_NameTable= Table(
         Symbol= [ :Start,                           :End,                            ],
        Default= [  nothing,                          nothing,                        ],
        Mutable= [  false,                            false,                          ],
    Constructor= [  SpdxSnippetPointerV2,             SpdxSnippetPointerV2            ],
      NameTable= [  SpdxSnippetPointerV2_NameTable,   SpdxSnippetPointerV2_NameTable  ],
      Multiline= [  false,                            false,                          ],
       JSONname= [  "startPointer",                   "endPointer",                   ],
   TagValueName= [  nothing,                          nothing,                        ],
)

struct SpdxSnippetRangeV2 <: AbstractSpdxData
    Start::SpdxSnippetPointerV2
    End::SpdxSnippetPointerV2
    MutableFields::OrderedDict{Symbol, Any}
end

function SpdxSnippetRangeV2(Start::SpdxSnippetPointerV2, End::SpdxSnippetPointerV2)
    MutableFields= init_MutableFields(SpdxSnippetRangeV2_NameTable)
    return SpdxSnippetRangeV2(Start, End, MutableFields)
end

function SpdxSnippetRangeV2(SPDXID::String)
    return SpdxSnippetRangeV2(SpdxSnippetPointerV2(SPDXID), SpdxSnippetPointerV2(SPDXID))
end

# Special formatting function for TagValue
function _tvSnippetRange(obj::SpdxSnippetRangeV2, NameTable::Table)
    hasbyteoffset= !ismissing(obj.Start.Offset) || !ismissing(obj.End.Offset)
    haslinenumber= !ismissing(obj.Start.LineNumber) || !ismissing(obj.End.LineNumber)
    ranges= Vector{Tuple}()

    if hasbyteoffset
        push!(ranges, (NameTable.NameTable[1].TagValueName[2], string(obj.Start.Offset) * ":" * string(obj.End.Offset)))
    end

    if haslinenumber
        push!(ranges, (NameTable.NameTable[1].TagValueName[3], string(obj.Start.LineNumber) * ":" * string(obj.End.LineNumber)))
    end

    return ranges
end


#############################################
const SpdxSnippetV2_NameTable= Table(
         Symbol= [  :SPDXID,           :FileSPDXID,                :SnippetRange,                  :LicenseConcluded,              :LicenseInfo,                              :LicenseComments,          :Copyright,               :SnippetComments,  :Name,          :Attributions,              :Annotations,                ],
        Default= [   nothing,           nothing,                    Vector{SpdxSnippetRangeV2}(),   missing,                        Vector{SpdxSimpleLicenseExpressionV2}(),   missing,                   missing,                  missing,           missing,        Vector{String}(),           Vector{SpdxAnnotationV2}(), ],
        Mutable= [   false,             false,                      true,                           true,                           true,                                      true,                      true,                     true,              true,           true,                       true,                       ],
    Constructor= [   string,            string,                     SpdxSnippetRangeV2,             SpdxSimpleLicenseExpressionV2,  SpdxSimpleLicenseExpressionV2,             string,                    string,                   string,            string,         string,                     SpdxAnnotationV2,           ],
      NameTable= [   nothing,           nothing,                    SpdxSnippetRangeV2_NameTable,   nothing,                        nothing,                                   nothing,                   nothing,                  nothing,           nothing,        nothing,                    SpdxAnnotationV2_NameTable, ],
      Multiline= [   false,             false,                      false,                          false,                          false,                                     false,                     true,                     true,              false,          false,                      false,                      ],
       JSONname= [   "SPDXID",          "snippetFromFile",          "ranges",                       "licenseConcluded",             "licenseInfoInSnippets",                   "licenseComments",         "copyrightText",          "comment",         "name",         "attributionTexts",         "annotations",              ],
   TagValueName= [   "SnippetSPDXID",   "SnippetFromFileSPDXID",    nothing,                        "SnippetLicenseConcluded",      "LicenseInfoInSnippet",                    "SnippetLicenseComments",  "SnippetCopyrightText",   "SnippetComment",  "SnippetName",  "SnippetAttributionText",   "Annotator",                ],
)

struct SpdxSnippetV2 <: AbstractSpdxData
    SPDXID::String
    FileSPDXID::String
    MutableFields::OrderedDict{Symbol, Any}
end

function SpdxSnippetV2(SPDXID::AbstractString, FileSPDXID::AbstractString)
    MutableFields= init_MutableFields(SpdxSnippetV2_NameTable)
    return SpdxSnippetV2(SPDXID, FileSPDXID, MutableFields)
end