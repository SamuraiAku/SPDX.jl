#############################################
const SpdxChecksumV2_NameTable= Table(
         Symbol= [ :Algorithm,   :Hash           ],
        Mutable= [  false,        false          ],
    Constructor= [  string,       string         ],
      NameTable= [  nothing,      nothing        ],
      Multiline= [  false,        false          ],
       JSONname= [ "algorithm",   "checksumValue"],
)

const SpdxRelationshipV2_NameTable= Table(
         Symbol= [ :SPDXID,          :RelationshipType,    :RelatedSPDXID,         :Comment],
        Mutable= [  false,            false,                false,                  false], 
    Constructor= [  string,           string,               string,                 string],
      NameTable= [  nothing,          nothing,              nothing,                nothing],
      Multiline= [  false,            false,                false,                  true],
       JSONname= [  "spdxElementId",  "relationshipType",   "relatedSpdxElement",   "comment"],
   TagValueName= [  nothing,          nothing,              nothing,                "RelationshipComment"]
)

struct SpdxRelationshipV2 <: AbstractSpdxElement
    SPDXID::String
    RelationshipType::String
    RelatedSPDXID::String
    Comment::Union{String, Missing}
end

function SpdxRelationshipV2(SPDXID::AbstractString, RelationshipType::AbstractString, RelatedSPDXID::AbstractString)
    return SpdxRelationshipV2(SPDXID, RelationshipType, RelatedSPDXID, missing)
end
# TODO : Validate the RelationshipType
# TODO : Check if the IDs are present when added to a Document
