
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
            if isa(MutableFields[key], Vector) && length(MutableFields[key]) == 0
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


###################
function _show(io::IO, obj::PackageExternalReferenceV2)
    print(io, obj.Category * " " * obj.RefType * " " * obj.Locator)
end

###################
function _show(io::IO, obj::DocumentExternalReferenceV2)
    print(io, obj.SPDXID * "  " * obj.Namespace * " " * obj.Checksum)
end

################
function _show(io::IO, obj::SpdxCreatorV2)
    print(io, obj.CreatorType * ":  " * obj.Name * "  (" * obj.Email * ")")
end