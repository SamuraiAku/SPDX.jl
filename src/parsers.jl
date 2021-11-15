
function parse_file_to_obj(SpdxFile::AbstractSpdxFile, NameTable::Table, constructor::Type)
    constructorparams= get_constructor_parameters(SpdxFile, NameTable)
    SpdxDoc= constructor(constructorparams...)
end


function get_constructor_parameters(SpdxFile::SpdxJsonFile, NameTable::Table)
    ImmutableIndicies= map(value -> value == false, NameTable.Mutable)
    paramnames= NameTable.JSONname[ImmutableIndicies]
    ImmutableParameters= Vector{Any}(nothing, length(paramnames))
    for idx in 1:length(paramnames)
        paramstring= SpdxFile.Data[paramnames[idx]]
        ImmutableParameters[idx]= NameTable.Constructor[idx](paramstring)
    end
    return Tuple(ImmutableParameters)
end
#function parse_JSON_to_doc(JSONdoc::SpdxJsonFile)= parse_JSON_to_obj(JSONdoc, SpdxDocumentV2_NameTable)