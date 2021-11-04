

abstract type AbstractSpdx end
abstract type AbstractSpdxData <: AbstractSpdx end

######################################
struct SpdxSimpleLicenseExpressionV2 <: AbstractSpdx
    LicenseId::String
    LicenseExceptionId::Union{String, Nothing}
end

SpdxSimpleLicenseExpressionV2(LicenseId::String)= SpdxSimpleLicenseExpressionV2(LicenseId, nothing)
# TODO : Have the constructor check the LicenseId against the approved list from SPDX group
# TODO : Support user defined licenses
# TODO : Support compound expressions

######################################
struct SpdxPackageExternalReferenceV2 <: AbstractSpdx
    Category::String
    RefType::String
    Locator::String
end

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

######################################
struct SpdxNamespaceV2 <: AbstractSpdx
    URI::String
    UUID::String
end

function SpdxNamespaceV2(URI::String)
    SpdxNamespaceV2(URI, string(uuid4()))
end

######################################
struct SpdxChecksumV2 <: AbstractSpdx
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

######################################
struct SpdxDocumentExternalReferenceV2 <: AbstractSpdx
    SPDXID::String
    Namespace::String
    Checksum::SpdxChecksumV2
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

#############################################
function init_MutableFields(NameTable::Table)
    MutableIndicies= map(row -> row.Mutable == true, NameTable)
    MutableFields= OrderedDict{Symbol, Any}(NameTable[MutableIndicies].Symbol .=> deepcopy(NameTable[MutableIndicies].Default))
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
struct SpdxRelationshipV2 <: AbstractSpdxData
    SPDXID::String
    RelationshipType::String
    RelatedSPDXID::String
    MutableFields::OrderedDict{Symbol, Any}
end

function SpdxRelationshipV2(SPDXID::String, RelationshipType::String, RelatedSPDXID::String)
    MutableFields= init_MutableFields(SpdxRelationshipV2_NameTable)
    return SpdxRelationshipV2(SPDXID, RelationshipType, RelatedSPDXID, MutableFields)
end
# TODO : Validate the RelationshipType
# TODO : Check if the IDs are present when added to a Document