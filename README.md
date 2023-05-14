# SPDX.jl

This package provides for the creation, reading and writing of SPDX files in multiple file formats. Written in pure Julia.

Software Package Data eXchange (SPDX) is an open standard for communicating software bill of material information, including provenance, license, security, and other related information. SPDX reduces redundant work by providing common formats for organizations and communities to share important data, thereby streamlining and improving compliance, security, and dependability. The SPDX specification is recognized as the international open standard for security, license compliance, and other software supply chain artifacts as ISO/IEC 5962:2021.

Supports version 2.3 of the SPDX spec.

Please read the SPDX specification ([link](https://spdx.github.io/spdx-spec/))  for full details.

## Installation

Type `] add SPDX` and then hit ⏎ Return at the REPL. You should see `pkg> add SPDX`.

## SPDX Document Read/Write

```julia
using SPDX

# Read from JSON: file extension used to determine file type
# Returned type is SpdxDocumentV2
jsonDoc= readspdx("./SPDXJSONExample-v2.2.spdx.json") 

# Read from TagValue
tvDoc= readspdx("./SPDXTagExample-v2.2.spdx") 

# Write SPDX document in TagValue format
writespdx(jsonDoc, "jsonread.spdx")

# Write SPDX document in JSON format
writespdx(tvDoc, "tagvalueread.spdx.json")

```

## Creating and populating/modifying a new SPDX document
```julia
# Creating an empty Document
myDoc= SpdxDocumentV2()
# Properties Version, DataLicense, and SPDXID have fixed values that are set at creation time
```

In a new document, most properties are set to ```missing ``` or an empty vector. The document creator then creates other objects (strings, boolean, other SPDX data types) and populates the document properties.

```julia
myDoc.Name= "foo"
push!(myDoc.Packages, Pkg1)
```

Details of the SPDX objects are documented below.

As a convienence to the user, some complex document properties can be set with helper functions

```julia
# Create a new document namespace [Clause 6.5]
createnamespace!(myDoc, "https://namespaceURL.nowhere.com/path") # Function adds the UUID creating a namespace that conforms to SPDX best practices

updatenamespace!(myDoc) # Updates only the UUID portion of the namespace

setcreationtime!(myDoc) # Sets document creation time to the local time, taking the local timezone into account

# Compute a verification code or checksum of a directory [Clauses 7.9, 7.10]
# Supported checksum algorithms are:
#   ["SHA1", "SHA224", "SHA256", "SHA384", "SHA512", "SHA3-256", "SHA3-384", "SHA3-512"]
spdxchecksum("SHA1", "/path/to/dir", ["IgnoreThisFile.spdx.json"], [".git"]) # Compute a checksum that ignores a specific file and a .git directory at the root level.  A common usage pattern.

```

## SPDX Document Structure 


The document object contains many properties.  Each property corresponds to a clause of the SPDX specification. Some properties contain a single object of particular data type while others contain a vector of that type.  This section will list each property along with its data type (Name::Type) and a reference to the relevant clause of the SPDX specification. 

Please see the SPDX specification [https://spdx.github.io/spdx-spec/document-creation-information/](https://spdx.github.io/spdx-spec/document-creation-information/) for further description of the property content and purpose.


```julia
Document::SpdxDocumentV2 [Clause 6]
    Version::String [Clause 6.1]
    DataLicense::SpdxSimpleLicenseExpressionV2 [Clause 6.2]
    SPDXID::String [Clause 6.3]
    Name::String [Clause 6.4]
    Namespace::SpdxNamespaceV2 [Clause 6.5]
    ExternalDocReferences::Vector{SpdxDocumentExternalReferenceV2} [Clause 6.6]
    CreationInfo::SpdxCreationInfoV2 [Clauses 6.7, 6.8, 6.9, 6.10]
    DocumentComment::String [Clause 6.11]
    Packages::Vector{SpdxPackageV2} [Clause 7]
    Files::Vector{SpdxFileV2} [Clause 8]
    Snippets::Vector{SpdxSnippetV2} [Clause 9]
    LicenseInfo::Vector{SpdxLicenseInfoV2} [Clause 10]
    Relationships::Vector{SpdxRelationshipV2} [Clause 11]
    Annotations::Vector{SpdxAnnotationV2} [Clause 12]
```

## SPDX Package Structure

Please see the SPDX specification [https://spdx.github.io/spdx-spec/package-information/](https://spdx.github.io/spdx-spec/package-information/) for further description of the property content and purpose.

```julia
# Creating a new Package
SPDXID= "SPDXRef-idstring" # Replace "idstring" with a unique identifier for the package. 
myPkg= SpdxPackageV2(SPDXID) 
```

```julia
Package::SpdxPackageV2 [Clause 7]
    Name::String [Clause 7.1]
    SPDXID::String [Clause 7.2]
    Version::String [Clause 7.3]
    FileName::String [Clause 7.4]
    Supplier::SpdxCreatorV2 [Clause 7.5]
    Originator::SpdxCreatorV2 [Clause 7.6]
    DownloadLocation::SpdxDownloadLocationV2 [Clause 7.7]
    FilesAnalyzed::Bool [Clause 7.8]
    VerificationCode::SpdxPkgVerificationCodeV2 [Clause 7.9]
    Checksums::Vector{SpdxChecksumV2} [Clause 7.10]
    HomePage::String [Clause 7.11]
    SourceInfo::String [Clause 7.12]
    LicenseConcluded::Union{SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2} [Clause 7.13]
    LicenseInfoFromFiles::Vector{Union{SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2}} [Clause 7.14]
    LicenseDeclared::Union{SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2} [Clause 7.15]
    LicenseComments::String [Clause 7.16]
    Copyright::String [Clause 7.17]
    Summary::String [Clause 7.18]
    DetailedDescription::String [Clause 7.19]
    Comment::String [Clause 7.20]
    ExternalReferences::Vector{SpdxPackageExternalReferenceV2} [Clauses 7.21, 7.22]
    Attributions::Vector{String} [Clause 7.23]
    PrimaryPurpose::SpdxPkgPurposeV2 [Clause 7.24]            
    ReleaseDate::SpdxTimeV2 [Clause 7.25]
    BuiltDate::SpdxTimeV2 [Clause 7.26]
    ValidUntilDate::SpdxTimeV2 [Clause 7.27]
    Annotations::Vector{SpdxAnnotationV2} [Clause 12]
```

## SPDX File Object Structure

Please see the SPDX specification [https://spdx.github.io/spdx-spec/file-information/](https://spdx.github.io/spdx-spec/file-information/) for further description of the property content and purpose.

Clauses 8.9, 8.10, 8.11, and 8.16 are deprecated and not implemented in this object.

```julia
# Creating a new File object
FilePath= "./src/module1/foo.c" # The path to the file of interest relative to the root of the package. 
SPDXID= "SPDXRef-idstring" # Replace "idstring" with a unique identifier for the file.
pkgFile= SpdxFileV2(FilePath, SPDXID) 
```

```julia
File::SpdxFileV2 [Clause 8]
    Name::String [Clause 8.1]
    SPDXID::String [Clause 8.2]
    Type::Vector{SpdxFileTypeV2} [Clause 8.3]
    Checksum::Vector{SpdxChecksumV2} [Clause 8.4]
    LicenseConcluded::Union{SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2} [Clause 8.5]
    LicensesInFile::Vector{Union{SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2}} [Clause 8.6]
    LicenseComments::String [Clause 8.7]
    Copyright::String [Clause 8.8]
    FileComments::String [Clause 8.12]
    Notice::String [Clause 8.13]
    Contributors::Vector{String} [Clause 8.14]
    Attributions::Vector{String} [Clause 8.15]
    Annotations::Vector{SpdxAnnotationV2} [Clause 12]
```

## SPDX Snippet Structure

Please see the SPDX specification [https://spdx.github.io/spdx-spec/snippet-information/](https://spdx.github.io/spdx-spec/snippet-information/) for further description of the property content and purpose.

```julia
# Creating a new Snippet
SPDXID= "SPDXRef-idstring" # Replace "idstring" with a unique identifier for the snippet.
FileSPDXID= "SPDXRef-File1" # The SPDXID of the file object that contains this snippet.
pkgSnippet= SpdxSnippetV2("SPDXRef-idstring", FileSPDXID)
```

```julia
Snippet::SpdxSnippetV2 [Clause 9]
    SPDXID::String [Clause 9.1]
    FileSPDXID::String [Clause 9.2]
    SnippetRange::Vector{SpdxSnippetRangeV2} [Clause 9.3, 9.4]
    LicenseConcluded::Union{SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2} [Clause 9.5]
    LicenseInfo::Vector{Union{SpdxSimpleLicenseExpressionV2, SpdxComplexLicenseExpressionV2}} [Clause 9.6]
    LicenseComments::String [Clause 9.7]
    Copyright::String [Clause 9.8]
    SnippetComments::String [Clause 9.9]
    Name::String [Clause 9.10]
    Attributions::Vector{String} [Clause 9.11]
```

## SPDX Other License Info Structure

Please see the SPDX specification [https://spdx.github.io/spdx-spec/other-licensing-information-detected/](https://spdx.github.io/spdx-spec/other-licensing-information-detected/) for further description of the property content and purpose.

This object is only needed if a Package/File/Snippet license is not listed in the SPDX License List [https://spdx.dev/licenses/](https://spdx.dev/licenses/)

```julia
# Creating a License not in the SPDX License List
LicenseID= "LicenseRef-idstring" # Replace "idstring" with a unique identifier for the snippet.
newLicense= SpdxLicenseInfoV2(LicenseID)
```

```julia
License::SpdxLicenseInfoV2 [Clause 10]
    LicenseID::String [Clause 10.1]
    ExtractedText::String [Clause 10.2]
    Name::String [Clause 10.3]
    URL::Vector{String} [Clause 10.4]
    CrossReference::SpdxLicenseCrossReferenceV2 [Not Specified. An additional field in the SPDX JSON schema]
    Comment::String [Clause 10.5]
```

## SPDX Relationship Structure

Please see the SPDX specification [https://spdx.github.io/spdx-spec/relationships-between-SPDX-elements/](https://spdx.github.io/spdx-spec/relationships-between-SPDX-elements/) for further description of the property content and purpose.

```julia
# Creating a new Relationship
SPDXID= "SPDXRef-DOCUMENT"
Relationship= "CONTAINS"
RelatedSPDXID= "SPDXRef-Pkg1"
relationship= SpdxRelationshipV2(SPDXID, RelationshipType, RelatedSPDXID)
```

```julia
Relationship::SpdxRelationshipV2 [Clause 11]
    SPDXID::String  [Clause 11.1]
    RelationshipType::String [Clause 11.1]
    RelatedSPDXID::String [Clause 11.1]
    Comment::String [Clause 11.2]
```

## SPDX Annotation Structure

Please see the SPDX specification [https://spdx.github.io/spdx-spec/annotations/](https://spdx.github.io/spdx-spec/annotations/) for further description of the property content and purpose.

Clause 12.4 (SPDX identifier reference field) is not directly implemented in this object. Instead the annotations are a property of the SPDX document, package, file, or snippet they are annotating.

```julia
# Creating a new Annotation
annotation= SpdxAnnotationV2()
```

```julia
Annotation::SpdxAnnotationV2 [Clause 12]
    Annotator::SpdxCreatorV2 [Clause 12.1]
    Created::SpdxTimeV2 [Clause 12.2]
    Type::String [Clause 12.3]
    Comment::String [Clause 12.5]
```
