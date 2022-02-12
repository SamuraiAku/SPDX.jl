# TODO: Put SPDX license header here
module SPDX

using JSON
using DataStructures
using TypedTables
using Dates
using UUIDs
using TimeZones

export AbstractSpdx, AbstractSpdxData, SpdxPackageV2, SpdxSimpleLicenseExpressionV2, SpdxPackageExternalReferenceV2, SpdxNamespaceV2
export SpdxDocumentV2, SpdxCreatorV2, SpdxDocumentExternalReferenceV2, SpdxRelationshipV2, SpdxCreationInfoV2, SpdxChecksumV2
export SpdxLicenseInfoV2, SpdxLicenseCrossReferenceV2
export printJSON, setcreationtime!, SpdxTimeV2, createnamespace!, updatenamespace!
export addcreator!, getcreators, deletecreator!, printTagValue, readJSON, readTagValue

include("types.jl")
include("spdxAnnotation.jl")
include("spdxLicense.jl")
include("spdxRelationship.jl")
include("spdxPackage.jl")
include("spdxDocument.jl")
include("accessors.jl")
include("display.jl")
include("formatJSON.jl")
include("formatTagValue.jl")
include("readJSON.jl")
include("readTagValue.jl")
include("api.jl")

# Write your package code here.

function __init__()
    # Force compilation of all SPDX data types + string()

    #### SpdxRelationshipV2
    a= string(SpdxRelationshipV2("DOCA CONTAINS FILEB"))
    precompile(getproperty,   (SpdxRelationshipV2, Symbol))
    precompile(setproperty!,  (SpdxRelationshipV2, Symbol, Any))
    precompile(propertynames, (SpdxRelationshipV2,))
    precompile(convert_to_JSON, (SpdxRelationshipV2, typeof(SpdxRelationshipV2_NameTable)))
    precompile(convert_from_JSON, (Dict{String, Any}, typeof(SpdxRelationshipV2_NameTable), Type{SpdxRelationshipV2}))
    precompile(convert_to_TagValue!, (IOBuffer, SpdxRelationshipV2, typeof(SpdxRelationshipV2_NameTable), String))

    #### SpdxSimpleLicenseExpressionV2
    b= string(SpdxSimpleLicenseExpressionV2("MIT"))
    precompile(convert_from_JSON, (String, Nothing, Type{SpdxSimpleLicenseExpressionV2}))

    #### SpdxCreatorV2
    c= string(SpdxCreatorV2("Person: Me ()"))
    precompile(convert_from_JSON, (String, Nothing, Type{SpdxCreatorV2}))

    #### SpdxTimeV2
    d= string(SpdxTimeV2(now()))
    precompile(convert_from_JSON, (String, Nothing, Type{SpdxTimeV2}))

    #### SpdxChecksumV2
    e= string(SpdxChecksumV2("SHA1: 85ed0817af83a24ad8da68c2b5094de69833983c"))
    precompile(convert_to_JSON, (SpdxChecksumV2, typeof(SpdxChecksumV2_NameTable)))
    precompile(convert_from_JSON, (Dict{String, Any}, typeof(SpdxChecksumV2_NameTable), Type{SpdxChecksumV2}))
    precompile(convert_to_TagValue!, (IOBuffer, SpdxChecksumV2, typeof(SpdxChecksumV2_NameTable), String))

    #### SpdxAnnotationV2
    f= string(SpdxAnnotationV2())
    precompile(getproperty,   (SpdxAnnotationV2, Symbol))
    precompile(setproperty!,  (SpdxAnnotationV2, Symbol, Any))
    precompile(propertynames, (SpdxAnnotationV2,))
    precompile(convert_to_JSON, (SpdxAnnotationV2, typeof(SpdxAnnotationV2_NameTable)))
    precompile(convert_from_JSON, (Dict{String, Any}, typeof(SpdxAnnotationV2_NameTable), Type{SpdxAnnotationV2}))
    precompile(convert_to_TagValue!, (IOBuffer, SpdxAnnotationV2, typeof(SpdxAnnotationV2_NameTable), String))

    #### SpdxLicenseInfoV2
    g= string(SpdxLicenseInfoV2("LicID"))
    precompile(getproperty,   (SpdxLicenseInfoV2, Symbol))
    precompile(setproperty!,  (SpdxLicenseInfoV2, Symbol, Any))
    precompile(propertynames, (SpdxLicenseInfoV2,))
    precompile(convert_to_JSON, (SpdxLicenseInfoV2, typeof(SpdxLicenseInfoV2_NameTable)))
    precompile(convert_from_JSON, (Dict{String, Any}, typeof(SpdxLicenseInfoV2_NameTable), Type{SpdxLicenseInfoV2}))
    precompile(convert_to_TagValue!, (IOBuffer, SpdxLicenseInfoV2, typeof(SpdxLicenseInfoV2_NameTable), String))


    #### SpdxLicenseCrossReferenceV2
    h= string(SpdxLicenseCrossReferenceV2())
    precompile(getproperty,   (SpdxLicenseCrossReferenceV2, Symbol))
    precompile(setproperty!,  (SpdxLicenseCrossReferenceV2, Symbol, Any))
    precompile(propertynames, (SpdxLicenseCrossReferenceV2,))
    precompile(convert_to_JSON, (SpdxLicenseCrossReferenceV2, typeof(SpdxLicenseCrossReferenceV2_NameTable)))
    precompile(convert_from_JSON, (Dict{String, Any}, typeof(SpdxLicenseCrossReferenceV2_NameTable), Type{SpdxLicenseCrossReferenceV2}))
    precompile(convert_to_TagValue!, (IOBuffer, SpdxLicenseCrossReferenceV2, typeof(SpdxLicenseCrossReferenceV2_NameTable), String))

    #### SpdxPackageExternalReferenceV2
    i= string(SpdxPackageExternalReferenceV2("SECURITY cpe23Type cpe:2.3:a:pivotal_software:spring_framework:4.1.0:*:*:*:*:*:*:*"))
    precompile(getproperty,   (SpdxPackageExternalReferenceV2, Symbol))
    precompile(setproperty!,  (SpdxPackageExternalReferenceV2, Symbol, Any))
    precompile(propertynames, (SpdxPackageExternalReferenceV2,))
    precompile(convert_to_JSON, (SpdxPackageExternalReferenceV2, typeof(SpdxPackageExternalReferenceV2_NameTable)))
    precompile(convert_from_JSON, (Dict{String, Any}, typeof(SpdxPackageExternalReferenceV2_NameTable), Type{SpdxPackageExternalReferenceV2}))
    precompile(convert_to_TagValue!, (IOBuffer, SpdxPackageExternalReferenceV2, typeof(SpdxPackageExternalReferenceV2_NameTable), String))
    
    #### SpdxPkgVerificationCodeV2
    j= string(SpdxPkgVerificationCodeV2("d6a770ba38583ed4bb4525bd96e50461655d2758 (excludes: ./package.spdx)"))
    precompile(convert_to_JSON, (SpdxPkgVerificationCodeV2, typeof(SpdxPkgVerificationCodeV2_NameTable)))
    precompile(convert_from_JSON, (Dict{String, Any}, typeof(SpdxPkgVerificationCodeV2_NameTable), Type{SpdxPkgVerificationCodeV2}))


    #### SpdxPackageV2
    k= string(SpdxPackageV2("MyID"))
    precompile(getproperty,   (SpdxPackageV2, Symbol))
    precompile(setproperty!,  (SpdxPackageV2, Symbol, Any))
    precompile(propertynames, (SpdxPackageV2,))
    precompile(convert_to_JSON, (SpdxPackageV2, typeof(SpdxPackageV2_NameTable)))
    precompile(convert_from_JSON, (Dict{String, Any}, typeof(SpdxPackageV2_NameTable), Type{SpdxPackageV2}))
    precompile(convert_to_TagValue!, (IOBuffer, SpdxPackageV2, typeof(SpdxPackageV2_NameTable), String))


    #### SpdxCreationInfoV2
    l= string(SpdxCreationInfoV2())
    precompile(getproperty,   (SpdxCreationInfoV2, Symbol))
    precompile(setproperty!,  (SpdxCreationInfoV2, Symbol, Any))
    precompile(propertynames, (SpdxCreationInfoV2,))
    precompile(convert_to_JSON, (SpdxCreationInfoV2, typeof(SpdxCreationInfoV2_NameTable)))
    precompile(convert_from_JSON, (Dict{String, Any}, typeof(SpdxCreationInfoV2_NameTable), Type{SpdxCreationInfoV2}))
    precompile(convert_to_TagValue!, (IOBuffer, SpdxCreationInfoV2, typeof(SpdxCreationInfoV2_NameTable), String))

    #### SpdxNamespaceV2
    m= string(SpdxNamespaceV2("http://spdx.org/spdxdocs/spdx-example-444504E0-4F89-41D3-9A0C-0305E82C3301"))
    precompile(convert_from_JSON, (String, Nothing, Type{SpdxNamespaceV2}))
    
    #### SpdxDocumentExternalReferenceV2
    n= string(SpdxDocumentExternalReferenceV2("DocumentRef-spdx-tool-1.2 http://spdx.org/spdxdocs/spdx-tools-v1.2-3F2504E0-4F89-41D3-9A0C-0305E82C3301 SHA1: d6a770ba38583ed4bb4525bd96e50461655d2759"))
    precompile(convert_to_JSON, (SpdxDocumentExternalReferenceV2, typeof(SpdxDocumentExternalReferenceV2_NameTable)))
    precompile(convert_from_JSON, (Dict{String, Any}, typeof(SpdxDocumentExternalReferenceV2_NameTable), Type{SpdxDocumentExternalReferenceV2}))

    #### SpdxDocumentV2
    z= string(SpdxDocumentV2())
    precompile(getproperty,   (SpdxDocumentV2, Symbol))
    precompile(setproperty!,  (SpdxDocumentV2, Symbol, Any))
    precompile(propertynames, (SpdxDocumentV2,))
    precompile(convert_to_JSON, (SpdxDocumentV2, typeof(SpdxDocumentV2_NameTable)))
    precompile(compute_additional_JSON_fields!, (OrderedDict{String, Any}, SpdxDocumentV2))
    precompile(convert_from_JSON, (Dict{String, Any}, typeof(SpdxDocumentV2_NameTable), Type{SpdxDocumentV2}))
    precompile(process_additional_JSON_fields!, (SpdxDocumentV2, String, String))
    precompile(convert_to_TagValue!, (IOBuffer, SpdxDocumentV2, typeof(SpdxDocumentV2_NameTable), String))

    #### Other
    precompile(convert_from_JSON, (Bool, Nothing, Type{Bool}))
    
    
end


end
