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
    # Force compilation of all SPDX data types
    a= SpdxRelationshipV2("DOCA CONTAINS FILEB")
    b= SpdxSimpleLicenseExpressionV2("MIT")
    c= SpdxCreatorV2("Person: Me ()")
    d= SpdxTimeV2(now())
    e= SpdxChecksumV2("SHA1: 85ed0817af83a24ad8da68c2b5094de69833983c")
    f= SpdxAnnotationV2()
    g= SpdxLicenseInfoV2("LicID")
    h= SpdxLicenseCrossReferenceV2()
    i= SpdxPackageExternalReferenceV2("SECURITY cpe23Type cpe:2.3:a:pivotal_software:spring_framework:4.1.0:*:*:*:*:*:*:*")
    j= SpdxPkgVerificationCodeV2("d6a770ba38583ed4bb4525bd96e50461655d2758 (excludes: ./package.spdx)")
    k= SpdxPackageV2("MyID")
    l= SpdxCreationInfoV2()
    m= SpdxNamespaceV2("http://spdx.org/spdxdocs/spdx-example-444504E0-4F89-41D3-9A0C-0305E82C3301")
    n= SpdxDocumentExternalReferenceV2("DocumentRef-spdx-tool-1.2 http://spdx.org/spdxdocs/spdx-tools-v1.2-3F2504E0-4F89-41D3-9A0C-0305E82C3301 SHA1: d6a770ba38583ed4bb4525bd96e50461655d2759")
    z= SpdxDocumentV2()

    # Precompile custom accessor methods
    precompile(getproperty,   (SpdxDocumentV2, Symbol))
    precompile(setproperty!,   (SpdxDocumentV2, Symbol, Any))
    precompile(propertynames, (SpdxDocumentV2,))

    precompile(getproperty,   (SpdxAnnotationV2, Symbol))
    precompile(setproperty!,  (SpdxAnnotationV2, Symbol, Any))
    precompile(propertynames, (SpdxAnnotationV2,))

    precompile(getproperty,   (SpdxCreationInfoV2, Symbol))
    precompile(setproperty!,  (SpdxCreationInfoV2, Symbol, Any))
    precompile(propertynames, (SpdxCreationInfoV2,))

    precompile(getproperty,   (SpdxLicenseCrossReferenceV2, Symbol))
    precompile(setproperty!,  (SpdxLicenseCrossReferenceV2, Symbol, Any))
    precompile(propertynames, (SpdxLicenseCrossReferenceV2,))

    precompile(getproperty,   (SpdxPackageExternalReferenceV2, Symbol))
    precompile(setproperty!,  (SpdxPackageExternalReferenceV2, Symbol, Any))
    precompile(propertynames, (SpdxPackageExternalReferenceV2,))

    precompile(getproperty,   (SpdxPackageV2, Symbol))
    precompile(setproperty!,  (SpdxPackageV2, Symbol, Any))
    precompile(propertynames, (SpdxPackageV2,))

    precompile(getproperty,   (SpdxRelationshipV2, Symbol))
    precompile(setproperty!,  (SpdxRelationshipV2, Symbol, Any))
    precompile(propertynames, (SpdxRelationshipV2,))

    # Precompile string methods for all SPDX types
    precompile(string, (SpdxSimpleLicenseExpressionV2,))
    precompile(string, (SpdxCreatorV2,))
    precompile(string, (SpdxTimeV2,))
    precompile(string, (SpdxDocumentV2,))
    precompile(string, (SpdxChecksumV2,))
    precompile(string, (SpdxAnnotationV2,))
    precompile(string, (SpdxLicenseInfoV2,))
    precompile(string, (SpdxLicenseCrossReferenceV2,))
    precompile(string, (SpdxRelationshipV2,))
    precompile(string, (SpdxPackageExternalReferenceV2,))
    precompile(string, (SpdxPkgVerificationCodeV2,))
    precompile(string, (SpdxPackageV2,))
    precompile(string, (SpdxDocumentExternalReferenceV2,))
    precompile(string, (SpdxNamespaceV2,))
    precompile(string, (SpdxCreationInfoV2,))
end


end
