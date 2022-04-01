# SPDX-License-Identifier: MIT

export SpdxLicenseCrossReferenceV2, SpdxLicenseInfoV2, SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2, SpdxLicenseExpressionV2

######################################
const SpdxLicenseCrossReferenceV2_NameTable= Table(
        Symbol= [ :URL,       :isValid,    :isLive,   :isWayBackLink,   :Match,    :Timestamp,   :Order],
       Default= [  missing,    missing,     missing,   missing,          missing,   missing,      missing],
       Mutable= [  true,       true,        true,      true,             true,      true,         true],
   Constructor= [  string,     Bool,        Bool,      Bool,             string,    string,       string],
     NameTable= [  nothing,    nothing,     nothing,   nothing,          nothing,   nothing,      nothing],
     Multiline= [  false,      false,       false,     false,            false,     false,        false],
      JSONname= [  "url",      "isValid",   "isLive",  "isWayBackLink",  "match",   "timestamp",  "order"],
  TagValueName= [  nothing,    nothing,     nothing,   nothing,          nothing,   nothing,      nothing],
)

struct SpdxLicenseCrossReferenceV2  <: AbstractSpdxData
    MutableFields::OrderedDict{Symbol, Any}
end

function SpdxLicenseCrossReferenceV2()
    MutableFields= init_MutableFields(SpdxLicenseCrossReferenceV2_NameTable)
    return SpdxLicenseCrossReferenceV2(MutableFields)
end

function SpdxLicenseCrossReferenceV2(URL::AbstractString)
    obj= SpdxLicenseCrossReferenceV2()
    obj.URL= URL
end


######################################
const SpdxLicenseInfoV2_NameTable= Table(
        Symbol= [ :LicenseID,    :ExtractedText,   :Name,           :URL,                       :CrossReference,                          :Comment],
       Default= [  nothing,       missing,          missing,         Vector{String}(),           missing,                                  missing],
       Mutable= [  false,         true,             true,            true,                       true,                                     true],
   Constructor= [  string,        string,           string,          string,                     SpdxLicenseCrossReferenceV2,              string],
     NameTable= [  nothing,       nothing,          nothing,         nothing,                    SpdxLicenseCrossReferenceV2_NameTable,    nothing],
     Multiline= [  false,         true,             false,           false,                      false,                                    false],
      JSONname= [  "licenseId",   "extractedText",  "name",          "seeAlsos",                 "crossRefs",                              "comment"],
  TagValueName= [  "LicenseID",   "ExtractedText",  "LicenseName",   "LicenseCrossReference",    nothing,                                  "LicenseComment"],
)

struct SpdxLicenseInfoV2 <: AbstractSpdxData
    LicenseID::String
    MutableFields::OrderedDict{Symbol, Any}
end

function SpdxLicenseInfoV2(LicenseID::AbstractString)
    MutableFields= init_MutableFields(SpdxLicenseInfoV2_NameTable)
    return SpdxLicenseInfoV2(LicenseID, MutableFields)
end

######################################
struct SpdxSimpleLicenseExpressionV2 <: AbstractSpdx
    LicenseId::String
    LicenseExceptionId::Union{String, Nothing}
end

# TODO : Have the constructor check the LicenseId against the approved list from SPDX group
# TODO : Support user defined licenses
function SpdxSimpleLicenseExpressionV2(LicenseString::AbstractString)
    regex_LicenseId= r"^\s*(?<LicenseId>[^\s]+)(?<PostLicense>[[:print:]]*)$"
    regex_Exception= r"\s*WITH\s*(?<Exception>[^\s]*)\s*$"i
    regex_whitespacecheck= r"^\s*$"

    match_LicenseId= match(regex_LicenseId, LicenseString)
    if match_LicenseId === nothing
        error("Empty License String ", LicenseString)
    end

    Exception= nothing
    if length(match_LicenseId["PostLicense"]) > 0 && match(regex_whitespacecheck, match_LicenseId["PostLicense"]) === nothing
        match_Exception= match(regex_Exception, match_LicenseId["PostLicense"])
        if match_Exception === nothing
            println("WARNING:  Unable to parse License Exception ==> ", LicenseString)
        else
            Exception= match_Exception["Exception"]
        end
    end

    obj= SpdxSimpleLicenseExpressionV2(match_LicenseId["LicenseId"], Exception)
    return obj
end


######################################
struct SpdxComplexLicenseExpressionV2 <: AbstractSpdx
    Expression::String
end


######################################
function SpdxLicenseExpressionV2(LicenseString::AbstractString)
    # Scan and determine if a simple or complex expression is contained. And call the correct constructor
    # Eventually may end up calling this function recursively to build up a true complex expression structure.
    # Once this works, put this function in the all the NameTables
    regex_complex= r" AND | OR "
    if occursin(regex_complex, LicenseString)
        return SpdxComplexLicenseExpressionV2(LicenseString)
    else
        return SpdxSimpleLicenseExpressionV2(LicenseString)
    end
end