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
include("spdxFile.jl")
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

function precompile_spdx(spdxtype::Type, NameTable::Union{Table, Nothing}, constructparams::Tuple, jsondatatype::DataType)
    a= string(spdxtype(constructparams...))
    if spdxtype <: AbstractSpdxData
        precompile(getproperty,   (typeof(a), Symbol))
        precompile(setproperty!,  (typeof(a), Symbol, Any))
        precompile(propertynames, (typeof(a),))
        precompile(convert_to_TagValue!, (IOBuffer, spdxtype, typeof(NameTable), String))
        precompile(convert_from_TagValue, (Vector{RegexMatch}, typeof(NameTable), Type{spdxtype}))
    end

    if spdxtype <: Union{AbstractSpdxData, AbstractSpdxElement}
        precompile(convert_to_JSON, (spdxtype, typeof(NameTable)))
    end

    if jsondatatype <: Dict{String,Any}
        precompile(convert_from_JSON, (jsondatatype, typeof(NameTable), Type{spdxtype}))
    end

    return nothing
end


function __init__()
    # Force compilation of all SPDX data types + string()

    precompile_tuple= (
        (SpdxRelationshipV2,              SpdxRelationshipV2_NameTable,              ("DOCA CONTAINS FILEB",),  Dict{String, Any}),
        (SpdxSimpleLicenseExpressionV2,   nothing,                                   ("MIT",),                  String),
        (SpdxCreatorV2,                   nothing,                                   ("Person: Me ()",),        String),
        (SpdxTimeV2,                      nothing,                                   ("2022-02-11T07:19:38Z",), String),
        (SpdxChecksumV2,                  SpdxChecksumV2_NameTable,                  ("SHA1: 85ed0817af83a24ad8da68c2b5094de69833983c",), Dict{String, Any}),
        (SpdxAnnotationV2,                SpdxAnnotationV2_NameTable,                Tuple(()),                 Dict{String, Any}),
        (SpdxLicenseInfoV2,               SpdxLicenseInfoV2_NameTable,               ("LicID",),                Dict{String, Any}),
        (SpdxLicenseCrossReferenceV2,     SpdxLicenseCrossReferenceV2_NameTable,     Tuple(()),                 Dict{String, Any}),
        (SpdxPackageExternalReferenceV2,  SpdxPackageExternalReferenceV2_NameTable,  ("SECURITY cpe23Type cpe:2.3:a:pivotal_software:spring_framework:4.1.0:*:*:*:*:*:*:*",), Dict{String, Any}),
        (SpdxPkgVerificationCodeV2,       SpdxPkgVerificationCodeV2_NameTable,       ("d6a770ba38583ed4bb4525bd96e50461655d2758 (excludes: ./package.spdx)",), Dict{String, Any}),
        (SpdxFileV2,                      SpdxFileV2_NameTable,                      ("MyFile", "FileID"),      Dict{String, Any}),
        (SpdxPackageV2,                   SpdxPackageV2_NameTable,                   ("MyID",),                 Dict{String, Any}),
        (SpdxCreationInfoV2,              SpdxCreationInfoV2_NameTable,              Tuple(()),                 Dict{String, Any}),
        (SpdxNamespaceV2,                 nothing,                                   ("http://spdx.org/spdxdocs/spdx-example-444504E0-4F89-41D3-9A0C-0305E82C3301",), String),
        (SpdxDocumentExternalReferenceV2, SpdxDocumentExternalReferenceV2_NameTable, ("DocumentRef-spdx-tool-1.2 http://spdx.org/spdxdocs/spdx-tools-v1.2-3F2504E0-4F89-41D3-9A0C-0305E82C3301 SHA1: d6a770ba38583ed4bb4525bd96e50461655d2759",), Dict{String, Any}),
        (SpdxDocumentV2,                  SpdxDocumentV2_NameTable,                  Tuple(()),                 Dict{String, Any})
    )

    for parameters in precompile_tuple
        precompile_spdx(parameters...)
    end

    precompile(compute_additional_JSON_fields!, (OrderedDict{String, Any}, SpdxDocumentV2))
    precompile(process_additional_JSON_fields!, (SpdxDocumentV2, String, String))
    precompile(parse_TagValue, (IOStream, typeof(SpdxDocumentV2_NameTable), Type{SpdxDocumentV2}))
    precompile(convert_from_JSON, (Bool, Nothing, Type{Bool}))
    precompile(read_from_TagValue, (IOStream,))
    
    
end


end
