

abstract type AbstractSpdx end
abstract type AbstractSpdxElement <: AbstractSpdx end
abstract type AbstractSpdxData <: AbstractSpdx end
abstract type AbstractSpdxFile <: AbstractSpdx end

######################################
struct SpdxSimpleLicenseExpressionV2 <: AbstractSpdx
    LicenseId::String
    LicenseExceptionId::Union{String, Nothing}
end

SpdxSimpleLicenseExpressionV2(LicenseId::String)= SpdxSimpleLicenseExpressionV2(LicenseId, nothing)
# TODO : Parse the string so that we can populate both fields from a single string
# TODO : Have the constructor check the LicenseId against the approved list from SPDX group
# TODO : Support user defined licenses
# TODO : Support compound expressions

######################################
struct SpdxTimeV2 <: AbstractSpdx
    Time::ZonedDateTime

    function SpdxTimeV2(Time::ZonedDateTime)
        return new(astimezone(Time, tz"UTC"))
    end
end

function SpdxTimeV2(Time::DateTime)
    SpdxTimeV2(ZonedDateTime(Time, localzone()))
end

function SpdxTimeV2(Time::String)
    spdxTimeFormat= TimeZones.dateformat"yyyy-mm-ddTHH:MM:SSZ"  # The 'Z' at the end is a format code for Time Zone 
    if Time[end] == 'Z'
        Time= Time[1:end-1] * "UTC"
    else
        println("WARNING: SPDX creation date may not match the specification")
    end
    return SpdxTimeV2(ZonedDateTime(Time, spdxTimeFormat))
end

######################################
struct SpdxNamespaceV2 <: AbstractSpdx
    URI::String
    UUID::Union{String, Nothing}
end

function SpdxNamespaceV2(Namespace::String)
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
struct SpdxCreatorV2 <: AbstractSpdx
    CreatorType::String
    Name::String
    Email::String
    
    # Inner Constructor
    function SpdxCreatorV2(CreatorType::String, Name::String, Email::String; validate= true)
        validate == false && return new(CreatorType, Name, Email)

        ## Input Validation
        CreatorType in ["Person", "Organization", "Tool"] || error("Invalid CreatorType")
        (CreatorType == "Tool" && !isempty(Email)) && error("Tools do not have an email per SPDX spec")

        new(CreatorType, Name, Email)
    end
end

function SpdxCreatorV2(Creator::String)
    #TODO !!!!!  Actually parse the string
    SpdxCreatorV2(Creator, "", ""; validate= false)
end

######################################
struct SpdxChecksumV2 <: AbstractSpdxElement
    Algorithm::String
    Value::String

    function SpdxChecksumV2(Algorithm::String, Value::String)
        if Algorithm ∉ [ "SHA256", "SHA1", "SHA384", "MD2", "MD4", "SHA512", "MD6", "MD5", "SHA224" ]
            error("Checksum Algorithm is not recognized")
        end
        # TODO: verify that the value is the correct length for the specified algorithm and are all hex values
        return new(Algorithm, Value)
    end
end

SpdxChecksumV2(JSONfile::Dict{String, Any})= SpdxChecksumV2(JSONfile["algorithm"], JSONfile["checksumValue"])

######################################
struct SpdxDocumentExternalReferenceV2 <: AbstractSpdxElement
    SPDXID::String
    Namespace::SpdxNamespaceV2
    Checksum::SpdxChecksumV2
end

######################################
struct SpdxPackageExternalReferenceV2 <: AbstractSpdxElement
    Category::String
    RefType::String
    Locator::String
    Comment::Union{String, Missing}
end

function SpdxPackageExternalReferenceV2(Category::String, RefType::String, Locator::String)
    return SpdxPackageExternalReferenceV2(Category, RefType, Locator, missing)
end

#############################################
struct SpdxRelationshipV2 <: AbstractSpdxElement
    SPDXID::String
    RelationshipType::String
    RelatedSPDXID::String
    Comment::Union{String, Missing}
end

function SpdxRelationshipV2(SPDXID::String, RelationshipType::String, RelatedSPDXID::String)
    return SpdxRelationshipV2(SPDXID, RelationshipType, RelatedSPDXID, missing)
end
# TODO : Validate the RelationshipType
# TODO : Check if the IDs are present when added to a Document

#############################################
function init_MutableFields(NameTable::Table)
    MutableIndicies= map(row -> row == true, NameTable.Mutable)
    MutableFields= OrderedDict{Symbol, Any}(NameTable.Symbol[MutableIndicies] .=> deepcopy(NameTable.Default[MutableIndicies]))
    return MutableFields
end

#############################################
struct SpdxCreationInfoV2 <: AbstractSpdxData
    MutableFields::OrderedDict{Symbol, Any}
end

function SpdxCreationInfoV2()
    MutableFields= init_MutableFields(SpdxCreationInfoV2_NameTable)
    return SpdxCreationInfoV2(MutableFields)
end

#############################################
struct SpdxDocumentV2 <: AbstractSpdxData
    Version::String
    DataLicense::SpdxSimpleLicenseExpressionV2
    SPDXID::String
    MutableFields::OrderedDict{Symbol, Any}
end

function SpdxDocumentV2()
    MutableFields= init_MutableFields(SpdxDocumentV2_NameTable)
    return SpdxDocumentV2("SPDX-2.2", SpdxSimpleLicenseExpressionV2("CC0-1.0"), "SPDXRef-DOCUMENT", MutableFields)
end

function SpdxDocumentV2(Version::String, DataLicense::SpdxSimpleLicenseExpressionV2, SPDXID::String)
    MutableFields= init_MutableFields(SpdxDocumentV2_NameTable)
    return SpdxDocumentV2(Version, DataLicense, SPDXID, MutableFields)
end

#############################################
struct SpdxPackageV2 <: AbstractSpdxData
    SPDXID::String
    MutableFields::OrderedDict{Symbol, Any}
end

function SpdxPackageV2(SPDXID::AbstractString)
    MutableFields= init_MutableFields(SpdxPackageV2_NameTable)
    return SpdxPackageV2(SPDXID, MutableFields)
end

#############################################
struct SpdxJsonFile <: AbstractSpdxFile
    Data::Dict{Any, Any}
end