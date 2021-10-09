

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
struct DocumentExternalReferenceV2 <: AbstractSpdx
    SPDXID::String
    Namespace::String
    Checksum::String
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
        (CreatorType == "Tool" && length(Email) > 0) && error("Tools do not have an email per SPDX spec")

        new(CreatorType, Name, Email)
    end
end

function SpdxCreatorV2(CreatorType::String, Name::String; validate= true)
    SpdxCreatorV2(CreatorType, Name, "", validate= validate)
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
struct SpdxRelationshipV2 <: AbstractSpdx
    SPDXID::String
    RelationshipType::String
    RelatedSPDXID::String
end
# TODO : Validate the RelationshipType
# TODO : Check if the IDs are present when added to a Document