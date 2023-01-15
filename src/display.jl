# SPDX-License-Identifier: MIT

Base.show(io::IO, x::AbstractSpdx)= _show(io, x)


########### Default
function _show(io::IO, obj::AbstractSpdx)
    ImmutableFields= filter(sym -> sym != :MutableFields, fieldnames(typeof(obj)))
    for name in ImmutableFields
        println(io, string(name) * ":\t\t" * string(getproperty(obj, name)))
    end
    if hasfield(typeof(obj), :MutableFields)
        MutableFields= obj.MutableFields
        for key in keys(skipmissing(MutableFields))
            if isa(MutableFields[key], Vector) && isempty(MutableFields[key])
                continue
            else
                println(io, String(key) * ":\t\t" * string(MutableFields[key]))
            end
        end
    end
end


################
function _show(io::IO, obj::SPDX.SpdxPkgPurposeV2)
    print(io, obj.Purpose)
end

################
function _show(io::IO, obj::SpdxDownloadLocationV2)
    if !isempty(obj.nolocationReason)
        if isempty(obj.HostProtocol) && isempty(obj.HostPath) && isempty(obj.VCS_Protocol) && isempty(obj.VCS_Tag) && isempty(obj.VCS_SubPath)
            print(io, obj.nolocationReason)
            return
        end
    end

    # Case where constructor couldn't parse the input string properly. 
    # The whole raw string is stuffed into obj.HostPath
    if isempty(obj.HostProtocol) && !isempty(obj.HostPath) && isempty(obj.VCS_Protocol) && isempty(obj.VCS_Tag) && isempty(obj.VCS_SubPath)
        print(io, obj.HostPath)
        return
    end

    print(io, isempty(obj.VCS_Protocol) ? "" : "$(obj.VCS_Protocol)+",
              obj.HostProtocol, "://",
              obj.HostPath,
              isempty(obj.VCS_Tag) ? "" : "@$(obj.VCS_Tag)",
              isempty(obj.VCS_SubPath) ? "" : "#$(obj.VCS_SubPath)")
end

################
function _show(io::IO, obj::SpdxSimpleLicenseExpressionV2)
    print(io, obj.LicenseId)
    if obj.LicenseExceptionId !== nothing && length(obj.LicenseExceptionId) > 0
        print(io, " WITH " * string(obj.LicenseExceptionId))
    end
end

################
function _show(io::IO, obj::SpdxComplexLicenseExpressionV2)
    print(io, obj.Expression)
end

################
function _show(io::IO, obj::SpdxChecksumV2) 
    print(io, obj.Algorithm * ": " * obj.Hash)
end

################
function _show(io::IO, obj::SpdxPkgVerificationCodeV2) 
    print(io, obj.Hash)
    if !ismissing(obj.ExcludedFiles) 
        print(io, "  (excludes:")
        for fname in obj.ExcludedFiles
            print(io, " ", fname)
        end
        print(io, ")")
    end
end

###################
function _show(io::IO, obj::SpdxPackageExternalReferenceV2)
    print(io, obj.Category * " " * obj.RefType * " " * obj.Locator)
    ismissing(obj.Comment) || print(io, "\n" * obj.Comment)
end

###################
function _show(io::IO, obj::SpdxDocumentExternalReferenceV2)
    print(io, obj.SPDXID * "  " * string(obj.Namespace) * " " * string(obj.Checksum))
end

################
function _show(io::IO, obj::SpdxCreatorV2)
    print(io, obj.CreatorType,
              isempty(obj.CreatorType) ? "" : ":  ",  # Empty creator means Name is NOASSERTION
              obj.Name,
              isempty(obj.CreatorType) ? "" :  "  (",
              obj.Email,
              isempty(obj.CreatorType) ? "" : ")"
        )
end

################
function _show(io::IO, obj::SpdxRelationshipV2)
    print(io, obj.SPDXID * "  " * obj.RelationshipType * "  " * obj.RelatedSPDXID)
    ismissing(obj.Comment) || print(io, "\n" * obj.Comment)
end

################
function _show(io::IO, obj::SpdxTimeV2)
    print(io, Dates.format(obj.Time, "yyyy-mm-ddTHH:MM:SS") * "Z")
end

################
function _show(io::IO, obj::SpdxNamespaceV2)
    print(io, obj.URI)
    obj.UUID !== nothing && print(io, "-" * obj.UUID)
end

################
function _show(io::IO, obj::SpdxFileTypeV2)
    print(io, obj.Value)
end

################
function _show(io::IO, obj::SpdxSnippetRangeV2)
    hasbyteoffset= !ismissing(obj.Start.Offset) || !ismissing(obj.End.Offset)
    haslinenumber= !ismissing(obj.Start.LineNumber) || !ismissing(obj.End.LineNumber)

    if hasbyteoffset && haslinenumber
        print(io, "(")
    end

    if hasbyteoffset
        print(io, "ByteOffset   ",  string(obj.Start.Offset) * ":" * string(obj.End.Offset))
    end

    if hasbyteoffset && haslinenumber
        print(io, ",  ")
    end

    if haslinenumber
        print(io, "LineNumber   ",  string(obj.Start.LineNumber) * ":" * string(obj.End.LineNumber))
    end

    if hasbyteoffset && haslinenumber
        print(io, ")")
    end
end