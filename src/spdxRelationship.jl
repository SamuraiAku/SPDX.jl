# SPDX-License-Identifier: MIT

export SpdxRelationshipV2

#############################################
const SpdxRelationshipV2_NameTable= Table(
         Symbol= [ :SPDXID,          :RelationshipType,    :RelatedSPDXID,         :Comment],
        Mutable= [  false,            false,                false,                  true], 
    Constructor= [  :string,          :string,              :string,                :string],
      NameTable= [  :nothing,         :nothing,             :nothing,               :nothing],
      Multiline= [  false,            false,                false,                  true],
       JSONname= [  "spdxElementId",  "relationshipType",   "relatedSpdxElement",   "comment"],
   TagValueName= [  "Relationship",   nothing,              nothing,                "RelationshipComment"]
)

Base.@kwdef mutable struct SpdxRelationshipV2 <: AbstractSpdxData
    const SPDXID::String
    const RelationshipType::String
    const RelatedSPDXID::String
    Comment::Union{Missing, String}= missing
end

function SpdxRelationshipV2(SPDXID::AbstractString, RelationshipType::AbstractString, RelatedSPDXID::AbstractString)
    return SpdxRelationshipV2(SPDXID= SPDXID, RelationshipType= RelationshipType, RelatedSPDXID= RelatedSPDXID)
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
