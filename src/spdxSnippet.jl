# SPDX-License-Identifier: MIT

export SpdxSnippetPointerV2, SpdxSnippetRangeV2, SpdxSnippetV2

#############################################
const SpdxSnippetPointerV2_NameTable= Table(
         Symbol= [ :Reference,    :Offset,               :LineNumber,  ],
        Mutable= [  true,          true,                  true,        ],
    Constructor= [  string,        UInt,                  UInt,        ],
      NameTable= [  nothing,       nothing,               nothing,     ],
      Multiline= [  false,         false,                 false,       ],
       JSONname= [  "reference",   "offset",              "lineNumber",],
   TagValueName= [  nothing,       "SnippetByteRange",    "SnippetLineRange",],
)

Base.@kwdef mutable struct SpdxSnippetPointerV2 <: AbstractSpdxData
    Reference::Union{Missing,String}= missing
    Offset::Union{Missing,UInt}= missing
    LineNumber::Union{Missing,UInt}= missing
end

function SpdxSnippetPointerV2(Reference::AbstractString)
    return SpdxSnippetPointerV2(Reference= Reference)
end

function SpdxSnippetPointerV2(Reference::AbstractString, Tag::AbstractString, Value::UInt)
    # Used for TagValue processing
    pointer= SpdxSnippetPointerV2(Reference)
    pntr_idx= findfirst(isequal(Tag), SpdxSnippetPointerV2_NameTable.TagValueName)
    pntr_idx === nothing && return nothing

    pntr_symbol= SpdxSnippetPointerV2_NameTable.Symbol[pntr_idx]
    setproperty!(pointer, pntr_symbol, Value)
    return pointer
end

#############################################
const SpdxSnippetRangeV2_NameTable= Table(
         Symbol= [ :Start,                           :End,                            ],
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
end

function SpdxSnippetRangeV2(SPDXID::AbstractString)
    return SpdxSnippetRangeV2(SpdxSnippetPointerV2(SPDXID), SpdxSnippetPointerV2(SPDXID))
end

function SpdxSnippetRangeV2(SPDXID::AbstractString, Tag::AbstractString, Range::AbstractString)
    # Used for TagValue processing
    regex_range= r"^\s*(?<Start>[[:digit:]]+):(?<End>[[:digit:]]+)\s*$"
    match_range= match(regex_range, Range)
    range_start= parse(UInt, match_range["Start"])
    range_end=  parse(UInt, match_range["End"])

    startpntr= SpdxSnippetPointerV2(SPDXID, Tag, range_start)
    stoppntr= SpdxSnippetPointerV2(SPDXID, Tag, range_end)
    (startpntr===nothing || stoppntr===nothing) && return nothing

    return SpdxSnippetRangeV2(startpntr, stoppntr)
    
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
         Symbol= [  :SPDXID,           :FileSPDXID,                :SnippetRange,                  :LicenseConcluded,              :LicenseInfo,                                                                     :LicenseComments,          :Copyright,               :SnippetComments,  :Name,          :Attributions,              :Annotations,                ],
        Mutable= [   false,             false,                      true,                           true,                           true,                                                                             true,                      true,                     true,              true,           true,                       true,                       ],
    Constructor= [   string,            string,                     SpdxSnippetRangeV2,             SpdxLicenseExpressionV2,        SpdxLicenseExpressionV2,                                                          string,                    string,                   string,            string,         string,                     SpdxAnnotationV2,           ],
      NameTable= [   nothing,           nothing,                    SpdxSnippetRangeV2_NameTable,   nothing,                        nothing,                                                                          nothing,                   nothing,                  nothing,           nothing,        nothing,                    SpdxAnnotationV2_NameTable, ],
      Multiline= [   false,             false,                      false,                          false,                          false,                                                                            false,                     true,                     true,              false,          false,                      false,                      ],
       JSONname= [   "SPDXID",          "snippetFromFile",          "ranges",                       "licenseConcluded",             "licenseInfoInSnippets",                                                          "licenseComments",         "copyrightText",          "comment",         "name",         "attributionTexts",         "annotations",              ],
   TagValueName= [   "SnippetSPDXID",   "SnippetFromFileSPDXID",    nothing,                        "SnippetLicenseConcluded",      "LicenseInfoInSnippet",                                                           "SnippetLicenseComments",  "SnippetCopyrightText",   "SnippetComment",  "SnippetName",  "SnippetAttributionText",   "Annotator",                ],
)

Base.@kwdef mutable struct SpdxSnippetV2 <: AbstractSpdxData
    const SPDXID::String
    const FileSPDXID::String
    SnippetRange::Vector{SpdxSnippetRangeV2}= SpdxSnippetRangeV2[]
    LicenseConcluded::Union{Missing, SpdxComplexLicenseExpressionV2, SpdxSimpleLicenseExpressionV2}= missing
    LicenseInfo::Vector{Union{SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2}}= Vector{Union{SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2}}()
    LicenseComments::Union{Missing, String}= missing
    Copyright::Union{Missing, String}= missing
    SnippetComments::Union{Missing, String}= missing
    Name::Union{Missing, String}= missing
    Attributions::Vector{String}= String[]
    Annotations::Vector{SpdxAnnotationV2}= SpdxAnnotationV2[]
end

function SpdxSnippetV2(SPDXID::AbstractString, FileSPDXID::AbstractString)
    return SpdxSnippetV2(SPDXID= SPDXID, FileSPDXID= FileSPDXID)
end