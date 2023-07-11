# SPDX-License-Identifier: MIT

export SpdxPackageExternalReferenceV2, SpdxPkgVerificationCodeV2, SpdxPackageV2, SpdxPkgPurposeV2, SpdxDownloadLocationV2

######################################
const SpdxPackageExternalReferenceV2_NameTable= Table(
         Symbol= [ :Category,             :RefType,            :Locator,             :Comment],
        Mutable= [  false,                 false,               false,                true],
    Constructor= [  string,                string,              string,               string], 
      NameTable= [  nothing,               nothing,             nothing,              nothing],
      Multiline= [  false,                 false,               false,                true],
       JSONname= [  "referenceCategory",   "referenceType",     "referenceLocator",   "comment"],
   TagValueName= [  "ExternalRef",         nothing,              nothing,             "ExternalRefComment"]
)

Base.@kwdef mutable struct SpdxPackageExternalReferenceV2 <: AbstractSpdxData2
    const Category::String
    const RefType::String
    const Locator::String
    Comment::Union{Missing, String}= missing
end

function SpdxPackageExternalReferenceV2(Category::AbstractString, RefType::AbstractString, Locator::AbstractString)
    return SpdxPackageExternalReferenceV2(Category= Category, RefType= RefType, Locator= Locator)
end

function SpdxPackageExternalReferenceV2(TVstring::AbstractString)
    regex_reference= r"^\s*(?<Category>[^\s]+)\s+(?<Type>[^\s]+)\s+(?<Locator>[^\s]+)\s*$"
    match_reference= match(regex_reference, TVstring)
    if isnothing(match_reference)
        println("Error: Unable to parse Package External Reference: ", TVstring)
        return nothing
    end

    return SpdxPackageExternalReferenceV2(match_reference["Category"], match_reference["Type"], match_reference["Locator"])
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
struct SpdxPkgPurposeV2 <: AbstractSpdxElement
    Purpose::String

    function SpdxPkgPurposeV2(purpose::AbstractString)
        if purpose ∉ ["APPLICATION", "FRAMEWORK", "LIBRARY", "CONTAINER", "OPERATING-SYSTEM", "DEVICE", "FIRMWARE", "SOURCE", "ARCHIVE", "FILE", "INSTALL", "OTHER"]
            println("WARNING! PackagePrimaryPurpose ", purpose, " is not a recognized value")
        end
        return new(string(purpose))
    end
end

#############################################
struct SpdxDownloadLocationV2 <: AbstractSpdxElement
    VCS_Protocol::String
    HostProtocol::String
    HostPath::String
    VCS_Tag::String
    VCS_SubPath::String
    nolocationReason::String
end

function SpdxDownloadLocationV2(location::AbstractString)
    location= strip(location)

    loc_nonecheck= uppercase(location)
    if loc_nonecheck == "NOASSERTION" || loc_nonecheck == "NONE" 
        return SpdxDownloadLocationV2("", "", "", "", "", loc_nonecheck )
    end

    # The URL parsing is inspired by Appendix B of RFC 3986, parts 1-5
    protocol_regex= r"^(?<Protocol>(?<P1>[^:/?#+]*)?[+]?(?<P2>[^:/?#+]*)?)"
    hostpath_regex= r"://(?<HostPath>(?<Host>[^/?#]*)?(?<Path>[^?#@]*))"
    tag_regex= r"(@(?<Tag>[^#]*))?"
    subpath_regex= r"(#(?<SubPath>[[:print:]]*))?"

    parsed_location= match(protocol_regex * hostpath_regex * tag_regex * subpath_regex, location)
    if isnothing(parsed_location)
        println("(SpdxDownloadLocationV2) WARNING: Download Location cannot be parsed. Please review and correct manually\n\t", location)
        return SpdxDownloadLocationV2("", "", location, "", "", "")
    end

    VCS_Protocol::String= ""
    HostProtocol::String= ""
    HostPath::String= ""
    VCS_Tag::String= ""
    VCS_SubPath::String= ""
    !isnothing(parsed_location["SubPath"])  && (VCS_SubPath= parsed_location["SubPath"])
    !isnothing(parsed_location["Tag"])      && (VCS_Tag    = parsed_location["Tag"])
    !isnothing(parsed_location["HostPath"]) && (HostPath   = parsed_location["HostPath"])
    if isempty(parsed_location["P2"]) && !isempty(parsed_location["P1"])
        HostProtocol= parsed_location["P1"]
    elseif !isempty(parsed_location["P1"]) && !isempty(parsed_location["P2"])
        VCS_Protocol= parsed_location["P1"]
        HostProtocol= parsed_location["P2"]
    end

    if isempty(HostProtocol) && isempty(VCS_Protocol)
        println("(SpdxDownloadLocationV2) WARNING: Host and VCS protocol cannot be parsed. Please review and correct manually\n\t", parsed_location["Protocol"])
    end

    return SpdxDownloadLocationV2(VCS_Protocol, HostProtocol, HostPath, VCS_Tag, VCS_SubPath, "")   
end

function SpdxDownloadLocationV2(DL::SpdxDownloadLocationV2;  
                                VCS_Protocol::AbstractString= "",
                                HostProtocol::AbstractString= "",
                                HostPath::AbstractString= "",
                                VCS_Tag::AbstractString= "",
                                VCS_SubPath::AbstractString= "",
                                nolocationReason::AbstractString= "")
                                
    # This function returns an object that copies all fields from DL, except for those the user
    # modifies in kwargs
    return SpdxDownloadLocationV2(  isempty(VCS_Protocol) ? DL.VCS_Protocol : VCS_Protocol,
                                    isempty(HostProtocol) ? DL.HostProtocol : HostProtocol,
                                    isempty(HostPath) ? DL.HostPath : HostPath,
                                    isempty(VCS_Tag) ? DL.VCS_Tag : VCS_Tag,
                                    isempty(VCS_SubPath) ? DL.VCS_SubPath : VCS_SubPath,
                                    isempty(nolocationReason) ? DL.nolocationReason : nolocationReason
                                )
end

#############################################
const SpdxPackageV2_NameTable= Table(  
         Symbol= [ :Name,              :SPDXID,   :Version,          :FileName,          :Supplier,          :Originator,          :DownloadLocation,          :FilesAnalyzed,   :VerificationCode,                      :Checksums,                 :HomePage,          :SourceInfo,          :LicenseConcluded,                :LicenseInfoFromFiles,                                                            :LicenseDeclared,                  :LicenseComments,          :Copyright,              :Summary,          :DetailedDescription,   :Comment,          :ExternalReferences,                        :Attributions,               :PrimaryPurpose,            :ReleaseDate,     :BuiltDate,     :ValidUntilDate,    :Annotations],
        Mutable= [  true,               false,     true,              true,               true,               true,                 true,                       true,             true,                                   true,                       true,               true,                 true,                             true,                                                                             true,                              true,                      true,                    true,              true,                   true,              true,                                       true,                        true,                       true,             true,           true,               true],
    Constructor= [  string,             string,    string,            string,             SpdxCreatorV2,      SpdxCreatorV2,        SpdxDownloadLocationV2,     Bool,             SpdxPkgVerificationCodeV2,              SpdxChecksumV2,             string,             string,               SpdxLicenseExpressionV2,          SpdxLicenseExpressionV2,                                                          SpdxLicenseExpressionV2,           string,                    string,                  string,            string,                 string,            SpdxPackageExternalReferenceV2,             string,                      SpdxPkgPurposeV2,           SpdxTimeV2,       SpdxTimeV2,     SpdxTimeV2,         SpdxAnnotationV2],
      NameTable= [  nothing,            nothing,   nothing,           nothing,            nothing,            nothing,              nothing,                    nothing,          SpdxPkgVerificationCodeV2_NameTable,    SpdxChecksumV2_NameTable,   nothing,            nothing,              nothing,                          nothing,                                                                          nothing,                           nothing,                   nothing,                 nothing,           nothing,                nothing,           SpdxPackageExternalReferenceV2_NameTable,   nothing,                     nothing,                    nothing,          nothing,        nothing,            SpdxAnnotationV2_NameTable],
      Multiline= [  false,              false,     false,             false,              false,              false,                false,                      false,            false,                                  false,                      false,              true,                 false,                            false,                                                                            false,                             true,                      true,                    true,              true,                   true,              false,                                      true,                        false,                      false,            false,          false,              false],
       JSONname= [  "name",             "SPDXID",  "versionInfo",     "packageFileName",  "supplier",         "originator",         "downloadLocation",         "filesAnalyzed",  "packageVerificationCode",              "checksums",                "homepage",         "sourceInfo",         "licenseConcluded",               "licenseInfoFromFiles",                                                           "licenseDeclared",                 "licenseComments",         "copyrightText",         "summary",         "description",          "comment",         "externalRefs",                             "attributionTexts",          "primaryPackagePurpose",    "releaseDate",    "builtDate",    "validUntilDate",   "annotations"],
   TagValueName= [  "PackageName",      "SPDXID",  "PackageVersion",  "PackageFileName",  "PackageSupplier",  "PackageOriginator",  "PackageDownloadLocation",  "FilesAnalyzed",  "PackageVerificationCode",              "PackageChecksum",          "PackageHomePage",  "PackageSourceInfo",  "PackageLicenseConcluded",        "PackageLicenseInfoFromFiles",                                                    "PackageLicenseDeclared",          "PackageLicenseComments",  "PackageCopyrightText",  "PackageSummary",  "PackageDescription",   "PackageComment",  "ExternalRef",                              "PackageAttributionText",    "PrimaryPackagePurpose",    "ReleaseDate",    "BuiltDate",    "ValidUntilDate",   "Annotator"]
)


Base.@kwdef mutable struct SpdxPackageV2 <: AbstractSpdxData2
    Name::Union{Missing, String}= missing
    const SPDXID::String
    Version::Union{Missing, String}= missing
    FileName::Union{Missing, String}= missing
    Supplier::Union{Missing, SpdxCreatorV2}= missing
    Originator::Union{Missing, SpdxCreatorV2}= missing
    DownloadLocation::Union{Missing, SpdxDownloadLocationV2}= missing
    FilesAnalyzed::Bool= true
    VerificationCode::Union{Missing, SpdxPkgVerificationCodeV2}= missing
    Checksums::Vector{SpdxChecksumV2}= SpdxChecksumV2[]
    HomePage::Union{Missing, String}= missing
    SourceInfo::Union{Missing, String}= missing
    LicenseConcluded::Union{Missing, SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2}= missing
    LicenseInfoFromFiles::Vector{Union{SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2}}= Vector{Union{SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2}}()
    LicenseDeclared::Union{Missing, SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2}= missing
    LicenseComments::Union{Missing, String}= missing
    Copyright::Union{Missing, String}= missing
    Summary::Union{Missing, String}= missing
    DetailedDescription::Union{Missing, String}= missing
    Comment::Union{Missing, String}= missing
    ExternalReferences::Vector{SpdxPackageExternalReferenceV2}= SpdxPackageExternalReferenceV2[]
    Attributions::Vector{String}= String[]
    PrimaryPurpose::Union{Missing, SpdxPkgPurposeV2}= missing
    ReleaseDate::Union{Missing, SpdxTimeV2}= missing
    BuiltDate::Union{Missing, SpdxTimeV2}= missing
    ValidUntilDate::Union{Missing, SpdxTimeV2}= missing
    Annotations::Vector{SpdxAnnotationV2}= SpdxAnnotationV2[]
end

function SpdxPackageV2(SPDXID::AbstractString)
    return SpdxPackageV2(SPDXID= SPDXID)
end
