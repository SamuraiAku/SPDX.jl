#############################################
const SpdxRelationshipV2_NameTable= Table(
         Symbol= [ :SPDXID,          :RelationshipType,    :RelatedSPDXID,         :Comment],
        Mutable= [  false,            false,                false,                  true], 
        Default= [  missing,          missing,              missing,                missing],
    Constructor= [  string,           string,               string,                 string],
      NameTable= [  nothing,          nothing,              nothing,                nothing],
      Multiline= [  false,            false,                false,                  true],
       JSONname= [  "spdxElementId",  "relationshipType",   "relatedSpdxElement",   "comment"],
   TagValueName= [  "Relationship",   nothing,              nothing,                "RelationshipComment"]
)

struct SpdxRelationshipV2 <: AbstractSpdxData
    SPDXID::String
    RelationshipType::String
    RelatedSPDXID::String
    MutableFields::OrderedDict{Symbol, Any}
end

function SpdxRelationshipV2(SPDXID::AbstractString, RelationshipType::AbstractString, RelatedSPDXID::AbstractString)
    MutableFields= init_MutableFields(SpdxRelationshipV2_NameTable)
    return SpdxRelationshipV2(SPDXID, RelationshipType, RelatedSPDXID, MutableFields)
end

function SpdxRelationshipV2(RelationshipString::AbstractString)
    regex_relationship= r"^\s*(?<SPDXID>[^\s]+)\s+(?<Type>[^\s]+)\s+(?<Related>[^\s]+)\s*$"
    match_relationship= match(regex_relationship, RelationshipString)
    if isnothing(match_relationship)
        return nothing
    end

    return SpdxRelationshipV2(match_relationship["SPDXID"], match_relationship["Type"], match_relationship["Related"])
end
# TODO : Validate the RelationshipType
# TODO : Check if the IDs are present when added to a Document
# TODO : Support external document references

#############################################
# Deliberately not comparing the comments 
Base.isequal(y::SpdxRelationshipV2, x::SpdxRelationshipV2)= (y.SPDXID == x.SPDXID) && (y.RelationshipType == x.RelationshipType) && (y.RelatedSPDXID == x.RelatedSPDXID)
