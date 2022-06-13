@testset "SpdxAnnotation" begin
    a= SpdxAnnotationV2()
    a.Annotator= SpdxCreatorV2(" Person:  Jane Doe    (nowhere@loopback.com)")
    a.Created= SpdxTimeV2(now())
    a.Type= "REVIEW"
    a.Comment= "This is a comment"

    # Create object from JSON fragment
    c_json= "{
        \"annotator\" : \"Person:    Jane Doe (nowhere@loopback.com)\",
        \"annotationDate\" : \"$(a.Created)\",
        \"annotationType\" : \"REVIEW\",
        \"comment\" : \"This is a comment\"
      }"
    c_dict= JSON.parse(c_json)
    c= SPDX.convert_from_JSON(c_dict, SPDX.SpdxAnnotationV2_NameTable, SpdxAnnotationV2)
    @test SPDX.compare_b(a, c)

    # Create object from TagValue parse
    d_tv= IOBuffer("Annotator: Person:   Jane Doe ( nowhere@loopback.com)  
    AnnotationDate: $(a.Created)
    AnnotationComment: <text>This is a comment</text>
    AnnotationType:  REVIEW")
    d= SPDX.parse_TagValue(d_tv, SPDX.SpdxAnnotationV2_NameTable, SpdxAnnotationV2)
    @test SPDX.compare_b(a, d)
end
