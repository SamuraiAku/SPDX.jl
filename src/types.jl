# SPDX-License-Identifier: MIT

abstract type AbstractSpdx end
abstract type AbstractSpdxElement <: AbstractSpdx end
abstract type AbstractSpdxData <: AbstractSpdx end

export AbstractSpdx, AbstractSpdxData, AbstractSpdxElement
export SpdxCreatorV2, SpdxTimeV2, SpdxChecksumV2

######################################
Base.@kwdef struct Spdx_NameTable
    Symbol::Vector{Symbol}
    Mutable::Vector{Bool}
    Constructor::Vector{Union{Symbol, Expr}}
    NameTable::Vector{Symbol}
    Multiline::Vector{Bool}
    JSONname::Vector{Union{String, Nothing}}
    TagValueName::Vector{Union{String, Nothing}}
end

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
    regex_full= r"^\s*(?<Type>Person|Organization|Tool)\s*:\s*(?<Name>[[:alnum:]]{1}[[:print:]]*)?(\(\s*(?<Email>[[:print:]]*)\)\s*)"i  # Case-insensitive search, fails if email parenthesis not present (fix this)
    regex_noemail= r"^\s*(?<Type>Person|Organization|Tool)\s*:\s*(?<Name>[[:alnum:]]{1}[[:print:]]*)?(?<Email>)"i  # In case first one fails because no email parenthesis is present

    match_creator= match(regex_full, Creator)
    if match_creator !== nothing  || (match_creator= match(regex_noemail, Creator)) !== nothing
        c_type=  isnothing(match_creator[:Type])  ? "" : titlecase(match_creator[:Type])
        c_name=  isnothing(match_creator[:Name])  ? "" : rstrip(match_creator[:Name])
        c_email= isnothing(match_creator[:Email]) ? "" : strip(match_creator[:Email])
        obj= SpdxCreatorV2(c_type, c_name, c_email ; validate= false)
    elseif strip(uppercase(Creator)) == "NOASSERTION"
        obj= SpdxCreatorV2("", "NOASSERTION", "" ; validate= false)
    else
        println("(SpdxCreatorV2) Unable to parse \"", Creator, "\". Please review and correct manually.")
        obj= SpdxCreatorV2("", Creator, "" ; validate= false)
    end

    return obj
end


######################################
struct SpdxTimeV2 <: AbstractSpdx
    Time::ZonedDateTime

    function SpdxTimeV2(Time::ZonedDateTime)
        return new(astimezone(floor(Time, Dates.Second), tz"UTC"))
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

######################################
const SpdxChecksumV2_NameTable= Spdx_NameTable(
         Symbol= [ :Algorithm,   :Hash           ],
        Mutable= [  false,        false          ],
    Constructor= [  :string,      :string        ],
      NameTable= [  :nothing,     :nothing        ],
      Multiline= [  false,        false          ],
       JSONname= [ "algorithm",   "checksumValue"],
   TagValueName= [  nothing,      nothing]
)

struct SpdxChecksumV2 <: AbstractSpdxElement
    Algorithm::String
    Hash::String

    function SpdxChecksumV2(Algorithm::AbstractString, Hash::AbstractString)
        regex_findhash=  r"^\s*[[:xdigit:]]*\s*$"i  # Find hexadecimal values and nothing else besides whitespace

        if Algorithm ∉ ( "SHA256", "SHA1", "SHA384", "MD2", "MD4", "SHA512", "MD6", "MD5", "SHA224", "SHA3-256", "SHA3-384", "SHA3-512", "BLAKE2b-256", "BLAKE2b-384", "BLAKE2b-512", "BLAKE3", "ADLER32")
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
    regex_checksum= r"^\s*(?<Algorithm>[[:print:]]*):\s*(?<Hash>[[:xdigit:]]*)\s*$"

    match_checksum= match(regex_checksum, ChecksumString)
    if match_checksum === nothing
        error("Unable to parse checksum string ==> ", ChecksumString)
    else
        obj= SpdxChecksumV2(match_checksum["Algorithm"], match_checksum["Hash"])
    end

    return obj
end
