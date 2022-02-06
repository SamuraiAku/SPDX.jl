
abstract type AbstractSpdx end
abstract type AbstractSpdxElement <: AbstractSpdx end
abstract type AbstractSpdxData <: AbstractSpdx end

######################################
function init_MutableFields(NameTable::Table)
    MutableIndicies= findall(NameTable.Mutable)
    MutableFields= OrderedDict{Symbol, Any}(NameTable.Symbol[MutableIndicies] .=> deepcopy(NameTable.Default[MutableIndicies]))
    return MutableFields
end


######################################
struct SpdxSimpleLicenseExpressionV2 <: AbstractSpdx
    LicenseId::String
    LicenseExceptionId::Union{String, Nothing}
end

# TODO : Have the constructor check the LicenseId against the approved list from SPDX group
# TODO : Support user defined licenses
# TODO : Support compound expressions
function SpdxSimpleLicenseExpressionV2(LicenseString::AbstractString)
    regex_LicenseId= r"^\s*(?<LicenseId>[^\s]+)(?<PostLicense>[[:print:]]*)$"
    regex_Exception= r"\s*WITH\s*(?<Exception>[^\s]*)\s*$"i
    regex_whitespacecheck= r"^\s*$"

    match_LicenseId= match(regex_LicenseId, LicenseString)
    if match_LicenseId === nothing
        error("Empty License String ", LicenseString)
    end

    Exception= nothing
    if length(match_LicenseId["PostLicense"]) > 0 && match(regex_whitespacecheck, match_LicenseId["PostLicense"]) === nothing
        match_Exception= match(regex_Exception, match_LicenseId["PostLicense"])
        if match_Exception === nothing
            println("WARNING:  Unable to parse License Exception ==> ", LicenseString)
        else
            Exception= match_Exception["Exception"]
        end
    end

    obj= SpdxSimpleLicenseExpressionV2(match_LicenseId["LicenseId"], Exception)
    return obj
end

precompile(string, (SpdxSimpleLicenseExpressionV2,))


######################################
struct SpdxCreatorV2 <: AbstractSpdx
    CreatorType::String
    Name::String
    Email::String
    
    # Inner Constructor
    function SpdxCreatorV2(CreatorType::AbstractString, Name::AbstractString, Email::AbstractString; validate= true)
        validate == false && return new(CreatorType, Name, Email)

        ## Input Validation
        CreatorType in ("Person", "Organization", "Tool") || error("Invalid CreatorType")
        (CreatorType == "Tool" && !isempty(Email)) && error("Tools do not have an email per SPDX spec")

        new(CreatorType, Name, Email)
    end
end

function SpdxCreatorV2(Creator::AbstractString)
    regex_full= r"^\s*(?<Type>Person|Organization|Tool):\s*(?<Name>[[:alnum:]]{1}[[:print:]]*)?(\((?<Email>[[:print:]]*)\))"i  # Case-insensitive search, fails if email parenthesis not present (fix this)
    regex_noemail= r"^\s*(?<Type>Person|Organization|Tool):\s*(?<Name>[[:alnum:]]{1}[[:print:]]*)?"i  # In case first one fails because no email parenthesis is present

    match_creator= match(regex_full, Creator)
    if match_creator !== nothing
        c_type=  isnothing(match_creator[:Type])  ? "" : titlecase(match_creator[:Type])
        c_name=  isnothing(match_creator[:Name])  ? "" : string(rstrip(match_creator[:Name]))
        c_email= isnothing(match_creator[:Email]) ? "" : string(match_creator[:Email])
        obj= SpdxCreatorV2(c_type, c_name, c_email ; validate= false)
    else
        match_creator= match(regex_noemail, Creator)
        if match_creator !== nothing
            c_type=  isnothing(match_creator[:Type])  ? "" : titlecase(match_creator[:Type])
            c_name=  isnothing(match_creator[:Name])  ? "" : string(rstrip(match_creator[:Name]))
            obj= SpdxCreatorV2(c_type, c_name, "" ; validate= false)
        else
            obj= SpdxCreatorV2("", string(lstrip(rstrip(Creator))), ""; validate= false)
        end
    end

    return obj
end

precompile(string, (SpdxCreatorV2,))

######################################
struct SpdxTimeV2 <: AbstractSpdx
    Time::ZonedDateTime

    function SpdxTimeV2(Time::ZonedDateTime)
        return new(astimezone(Time, tz"UTC"))
    end
end

function SpdxTimeV2(Time::DateTime)
    SpdxTimeV2(ZonedDateTime(Time, localzone()))
end

function SpdxTimeV2(Time::AbstractString)
    spdxTimeFormat= TimeZones.dateformat"yyyy-mm-ddTHH:MM:SSZ"  # The 'Z' at the end is a format code for Time Zone 
    if Time[end] == 'Z'
        Time= Time[1:prevind(Time, end, 1)] * "UTC"
    else
        println("WARNING: SPDX creation date may not match the specification")
    end
    return SpdxTimeV2(ZonedDateTime(Time, spdxTimeFormat))
end

precompile(string, (SpdxTimeV2,))

######################################
const SpdxChecksumV2_NameTable= Table(
         Symbol= [ :Algorithm,   :Hash           ],
        Mutable= [  false,        false          ],
    Constructor= [  string,       string         ],
      NameTable= [  nothing,      nothing        ],
      Multiline= [  false,        false          ],
       JSONname= [ "algorithm",   "checksumValue"],
)

struct SpdxChecksumV2 <: AbstractSpdxElement
    Algorithm::String
    Hash::String

    function SpdxChecksumV2(Algorithm::AbstractString, Hash::AbstractString)
        regex_findhash=  r"^\s*[[:xdigit:]]*\s*$"i  # Find hexadecimal values and nothing else besides whitespace

        if Algorithm ∉ ( "SHA256", "SHA1", "SHA384", "MD2", "MD4", "SHA512", "MD6", "MD5", "SHA224" )
            error("Checksum Algorithm is not recognized")
        end
        # TODO: verify that the value is the correct length for the specified algorithm and are all hex values
        match_hash= match(regex_findhash, Hash)
        if match_hash === nothing
            error("Checksum Hash is invalid: Non-hex values detected ==> ", Hash)
        end
        return new(Algorithm, Hash)
    end
end

function SpdxChecksumV2(ChecksumString::AbstractString)
    regex_checksum= r"^\s*(?<Algorithm>[[:print:]]*):\s*(?<Hash>[[:xdigit:]]*)\x*$"

    match_checksum= match(regex_checksum, ChecksumString)
    if match_checksum === nothing
        error("Unable to parse checksum string ==> ", ChecksumString)
    else
        obj= SpdxChecksumV2(match_checksum["Algorithm"], match_checksum["Hash"])
    end

    return obj
end

precompile(string, (SpdxChecksumV2,))