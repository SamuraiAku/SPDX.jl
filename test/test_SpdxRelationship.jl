@testset "SpdxRelationship" begin
    a= SpdxRelationshipV2("SPDX-Ref1", "CONTAINS", "SPDX-Ref2") # Create object and populate directly
    b= SpdxRelationshipV2(" SPDX-Ref1     CONTAINS  SPDX-Ref2 ")  # Create object via string parsing. Add extra spaces to make it interesting
    @test SPDX.compare_b(a, b)

    # Create object from JSON fragment
    c_json= "{
           \"spdxElementId\" : \"SPDX-Ref1\",
           \"relationshipType\" : \"CONTAINS\",
           \"relatedSpdxElement\" : \"SPDX-Ref2\"
         }"
    c_dict= JSON.parse(c_json)
    c= SPDX.convert_from_JSON(c_dict, SPDX.SpdxRelationshipV2_NameTable, SpdxRelationshipV2)
    @test SPDX.compare_b(a, c)
    
    # Create object via TagValue parse
    d_tv= IOBuffer("Relationship: SPDX-Ref1 CONTAINS SPDX-Ref2\nRelationshipComment: <text> This is a comment.\n In two lines. </text>")
    d= SPDX.parse_TagValue(d_tv, SPDX.SpdxRelationshipV2_NameTable, SpdxRelationshipV2)
    @test !SPDX.compare_b(a, d)
    @test SPDX.compare_b(a, d; skipproperties= Symbol[:Comment])

    # Error checking
    @test isnothing(SpdxRelationshipV2("Garbage "))
end