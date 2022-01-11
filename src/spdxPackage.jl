######################################
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

struct SpdxPackageExternalReferenceV2 <: AbstractSpdxElement
    Category::String
    RefType::String
    Locator::String
    Comment::Union{String, Missing}
end

function SpdxPackageExternalReferenceV2(Category::AbstractString, RefType::AbstractString, Locator::AbstractString)
    return SpdxPackageExternalReferenceV2(Category, RefType, Locator, missing)
end

######################################
const SpdxPkgVerificationCodeV2_NameTable= Table(
         Symbol= [ :Hash,                           :ExcludedFiles  ],
        Mutable= [  false,                           false,         ],
    Constructor= [  string,                          Vector{String} ],
      NameTable= [  nothing,                         nothing        ],
      Multiline= [  false,                           false          ],
       JSONname= [  "packageVerificationCodeValue",  "packageVerificationCodeExcludedFiles"],
)

struct SpdxPkgVerificationCodeV2 <: AbstractSpdxElement
    Hash::String
    ExcludedFiles::Union{Vector{String}, Missing}
end

function SpdxPkgVerificationCodeV2(VerifCodeString::AbstractString)
    regex_findhash=  r"^\s*(?<Hash>[[:xdigit:]]{40})(?<PostHash>[[:print:]]*)$"i  # Find 40 digit hash + anything after that
    regex_findexclusions= r"^\s*\((?<exclusions>[[:print:]]*)\)\s*$"  # Search for the brackets of the exclusions list. Verify only whitespace preceeds and follows it. Grab anything between the brackets.
    regex_whitespacecheck= r"^\s*$"
    regex_getfilelist= r"^\s*excludes:(?<Filelist>[[:print:]]*)"i  # Extract the file list as a single string

    match_hash= match(regex_findhash, VerifCodeString)
    if match_hash !== nothing
        ExcludedFiles= missing
        if length(match_hash["PostHash"]) > 0 && match(regex_whitespacecheck, match_hash["PostHash"]) === nothing
            ExcludedFiles= Vector{String}()
            match_exclusions= match(regex_findexclusions, match_hash["PostHash"])
            if (match_exclusions === nothing) 
                println("WARNING: Unable to parse exclusion list in PackageVerificationCode ==> ", match_hash["PostHash"])
                ExcludedFiles= push!(ExcludedFiles, match_hash["PostHash"])
            else
                match_filelist= match(regex_getfilelist, match_exclusions["exclusions"])
                if match_filelist === nothing
                    println("WARNING: Unable to parse exclusion list in PackageVerificationCode ==> ", match_exclusions["exclusions"])
                    ExcludedFiles= push!(ExcludedFiles, match_exclusions["exclusions"])
                else
                    ExcludedFiles= split(match_filelist["Filelist"])
                end
            end
        end
        obj= SpdxPkgVerificationCodeV2(match_hash["Hash"], ExcludedFiles)
    else
        error("Unable to parse Package Verification Code")
    end

    return obj
end

#############################################
const SpdxPackageV2_NameTable= Table(  
         Symbol= [ :Name,              :SPDXID,   :Version,          :FileName,          :Supplier,          :Originator,          :DownloadLocation,          :FilesAnalyzed,   :VerificationCode,                      :Checksums,                 :HomePage,          :SourceInfo,          :LicenseConcluded,                :LicenseInfoFromFiles,                    :LicenseDeclared,                  :LicenseComments,          :Copyright,              :Summary,          :DetailedDescription,   :Comment,          :ExternalReferences,                        :Attributions],
        Default= [  missing,            nothing,   missing,           missing,            missing,            missing,              missing,                    missing,          missing,                                Vector{SpdxChecksumV2}(),   missing,            missing,              missing,                          Vector{SpdxSimpleLicenseExpressionV2}(),  missing,                           missing,                   missing,                 missing,           missing,                missing,           Vector{SpdxPackageExternalReferenceV2}(),   Vector{String}()],
        Mutable= [  true,               false,     true,              true,               true,               true,                 true,                       true,             true,                                   true,                       true,               true,                 true,                             true,                                     true,                              true,                      true,                    true,              true,                   true,              true,                                       true],
    Constructor= [  string,             string,    string,            string,             string,             string,               string,                     Bool,             SpdxPkgVerificationCodeV2,              SpdxChecksumV2,             string,             string,               SpdxSimpleLicenseExpressionV2,    SpdxSimpleLicenseExpressionV2,            SpdxSimpleLicenseExpressionV2,     string,                    string,                  string,            string,                 string,            SpdxPackageExternalReferenceV2,             string],    
      NameTable= [  nothing,            nothing,   nothing,           nothing,            nothing,            nothing,              nothing,                    nothing,          SpdxPkgVerificationCodeV2_NameTable,    SpdxChecksumV2_NameTable,   nothing,            nothing,              nothing,                          nothing,                                  nothing,                           nothing,                   nothing,                 nothing,           nothing,                nothing,           SpdxPackageExternalReferenceV2_NameTable,   nothing], 
      Multiline= [  false,              false,     false,             false,              false,              false,                false,                      false,            false,                                  false,                      false,              true,                 false,                            false,                                    false,                             true,                      true,                    true,              true,                   true,              false,                                      true],
       JSONname= [  "name",             "SPDXID",  "versionInfo",     "packageFileName",  "supplier",         "originator",         "downloadLocation",         "filesAnalyzed",  "packageVerificationCode",              "checksums",                "homepage",         "sourceInfo",         "licenseConcluded",               "licenseInfoFromFiles",                   "licenseDeclared",                 "licenseComments",         "copyrightText",         "summary",         "description",          "comment",         "externalRefs",                             "attributionTexts" ],
   TagValueName= [  "PackageName",      "SPDXID",  "PackageVersion",  "PackageFileName",  "PackageSupplier",  "PackageOriginator",  "PackageDownloadLocation",  "FilesAnalyzed",  "PackageVerificationCode",              "PackageChecksum",          "PackageHomePage",  "PackageSourceInfo",  "PackageLicenseConcluded",        "PackageLicenseInfoFromFiles",            "PackageLicenseDeclared",          "PackageLicenseComments",  "PackageCopyrightText",  "PackageSummary",  "PackageDescription",   "PackageComment",  "ExternalRef",                              "PackageAttributionText"]
)


struct SpdxPackageV2 <: AbstractSpdxData
    SPDXID::String
    MutableFields::OrderedDict{Symbol, Any}
end

function SpdxPackageV2(SPDXID::AbstractString)
    MutableFields= init_MutableFields(SpdxPackageV2_NameTable)
    return SpdxPackageV2(SPDXID, MutableFields)
end