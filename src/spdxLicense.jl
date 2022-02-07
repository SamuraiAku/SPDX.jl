

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


