
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
function _show(io::IO, obj::SpdxSimpleLicenseExpressionV2)
    print(io, obj.LicenseId)
    if obj.LicenseExceptionId !== nothing && length(obj.LicenseExceptionId) > 0
        print(io, " WITH " * string(obj.LicenseExceptionId))
    end
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
    print(io, obj.CreatorType * ":  " * obj.Name * "  (" * obj.Email * ")")
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