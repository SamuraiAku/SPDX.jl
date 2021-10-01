

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
    MutableFields::OrderedDict{Symbol, Union{Missing, String, Vector{String}, AbstractSpdx, Vector{AbstractSpdx}}}
end

function SpdxDocumentV2()
    MutableFields= OrderedDict{Symbol, Any}([           :Name  => missing,
                                                   :Namespace  => missing,
                                          :ExternalReferences  => Vector{AbstractSpdx}(),
                                          :LicenseListVersion  => missing,
                                                     :Creator  => Vector{AbstractSpdx}(),
                                                     :Created  => missing,
                                              :CreatorComment  => missing,
                                             :DocumentComment  => missing
    ])
    return SpdxDocumentV2("SPDX-2.2", SpdxSimpleLicenseExpressionV2("CC0-1.0"), "SPDXRef-DOCUMENT", MutableFields)
end

#############################################
struct SpdxPackageV2 <: AbstractSpdxData
    SPDXID::String
    MutableFields::OrderedDict{Symbol, Union{Missing, String, Vector{String}, AbstractSpdx, Vector{AbstractSpdx}}}
end

function SpdxPackageV2(SPDXID::AbstractString)
    # Initialize the object fields.  Maybe this should be a column from a DataFrame Table later. 
    # So that I can track the subtle name translations between different fileformats
    # If object Symbols becomes a DataFrame column, then the default values could become one too!
    # MutableFields= OrderedDict{Symbol, Any}(ObjSymbols .=> ObjDefaults)
    MutableFields= OrderedDict{Symbol, Any}([                 :Name   => missing, 
                                                           :Version   => missing, 
                                                          :FileName   => missing,
                                                          :Supplier   => missing,
                                                        :Originator   => missing,
                                                  :DownloadLocation   => missing,
                                                     :FilesAnalyzed   => missing,
                                                  :VerificationCode   => missing,
                                                         :Checksums   => Vector{String}(),
                                                          :HomePage   => missing,
                                                        :SourceInfo   => missing,
                                                  :LicenseConcluded   => missing,
                                              :LicenseInfoFromFiles   => Vector{AbstractSpdx}(),
                                                   :LicenseDeclared   => missing,
                                                   :LicenseComments   => missing,
                                                         :Copyright   => missing,
                                                           :Summary   => missing,
                                               :DetailedDescription   => missing,
                                                           :Comment   => missing,
                                                :ExternalReferences   => Vector{AbstractSpdx}(),
                                          :ExternalReferenceComment   => missing,
                                                      :Attributions   => Vector{String}() ])

    return SpdxPackageV2(SPDXID, MutableFields)
end

