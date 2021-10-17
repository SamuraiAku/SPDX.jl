

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
struct PackageExternalReferenceV2 <: AbstractSpdx
    Category::String
    RefType::String
    Locator::String
end

######################################
struct ChecksumV2 <: AbstractSpdx
    Algorithm::String
    Value::String

    function ChecksumV2(Algorithm::String, Value::String)
        if Algorithm ∉ [ "SHA256", "SHA1", "SHA384", "MD2", "MD4", "SHA512", "MD6", "MD5", "SHA224" ]
            error("Checksum Algorithm is not recognized")
        end
        # TODO: verify that the value is the correct length for the specified algorithm and are all hex values
        return new(Algorithm, Value)
    end
end

######################################
struct DocumentExternalReferenceV2 <: AbstractSpdx
    SPDXID::String
    Namespace::String
    Checksum::ChecksumV2
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

function SpdxCreatorV2(CreatorType::String, Name::String; validate= true)
    SpdxCreatorV2(CreatorType, Name, "", validate= validate)
end

#############################################
struct SpdxCreationInfoV2 <: AbstractSpdxData
    MutableFields::OrderedDict{Symbol, Union{Missing, String, Vector{String}, AbstractSpdx, Vector{<:AbstractSpdx}}}
end

function SpdxCreationInfoV2()
    global SpdxCreationInfoV2_NameTable
    MutableIndicies= map(row -> row.Mutable == true, SpdxCreationInfoV2_NameTable)
    MutableFields= OrderedDict{Symbol, Any}(SpdxCreationInfoV2_NameTable[MutableIndicies].Symbol .=> deepcopy(SpdxCreationInfoV2_NameTable[MutableIndicies].Default))
    return SpdxCreationInfoV2(MutableFields)
end

#############################################
struct SpdxDocumentV2 <: AbstractSpdxData
    Version::String
    DataLicense::SpdxSimpleLicenseExpressionV2
    SPDXID::String
    MutableFields::OrderedDict{Symbol, Union{Missing, String, Vector{String}, AbstractSpdx, Vector{<:AbstractSpdx}}}
end

function SpdxDocumentV2()
    global SpdxDocumentV2_NameTable
    MutableIndicies= map(row -> row.Mutable == true, SpdxDocumentV2_NameTable)
    MutableFields= OrderedDict{Symbol, Any}(SpdxDocumentV2_NameTable[MutableIndicies].Symbol .=> deepcopy(SpdxDocumentV2_NameTable[MutableIndicies].Default))
    return SpdxDocumentV2("SPDX-2.2", SpdxSimpleLicenseExpressionV2("CC0-1.0"), "SPDXRef-DOCUMENT", MutableFields)
end

#############################################
struct SpdxPackageV2 <: AbstractSpdxData
    SPDXID::String
    MutableFields::OrderedDict{Symbol, Union{Missing, String, Vector{String}, AbstractSpdx, Vector{<:AbstractSpdx}}}
end

function SpdxPackageV2(SPDXID::AbstractString)
    global SpdxPackageV2_NameTable
    MutableIndicies= map(row -> row.Mutable == true, SpdxPackageV2_NameTable)
    MutableFields= OrderedDict{Symbol, Any}(SpdxPackageV2_NameTable[MutableIndicies].Symbol .=> deepcopy(SpdxPackageV2_NameTable[MutableIndicies].Default) )
    return SpdxPackageV2(SPDXID, MutableFields)
end

#############################################
struct SpdxRelationshipV2 <: AbstractSpdxData
    SPDXID::String
    RelationshipType::String
    RelatedSPDXID::String
    MutableFields::OrderedDict{Symbol, Union{Missing, String, Vector{String}, AbstractSpdx, Vector{<:AbstractSpdx}}}
end

function SpdxRelationshipV2(SPDXID::String, RelationshipType::String, RelatedSPDXID::String)
    global SpdxPackageV2_NameTable
    MutableIndicies= map(row -> row.Mutable == true, SpdxPackageV2_NameTable)
    MutableFields= OrderedDict{Symbol, Any}(SpdxPackageV2_NameTable[MutableIndicies].Symbol .=> deepcopy(SpdxPackageV2_NameTable[MutableIndicies].Default) )
    return SpdxRelationshipV2(SPDXID, RelationshipType, RelatedSPDXID, MutableFields)
end
# TODO : Validate the RelationshipType
# TODO : Check if the IDs are present when added to a Document