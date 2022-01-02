

function read_from_TagValue(TVfile::IO)
    regex_TagValue= r"^\s*(?<Tag>[^#:]*):\s*(?<Value>.*)$" # Match fails if all whitespace or comment line
    regex_checkmultilinestart= r"<text>"i
    regex_checkmultilinestop= r"</text>"i
    regex_multiline= r"^\s*(?<Tag>[^#:]*):\s*(?i:<text>)(?<Value>.*)(?i:</text>).*$"s 

    TagValues= Vector{RegexMatch}()
    NextSection= nothing
    while !eof(TVfile)
        fileline= readline(TVfile)
        match_tv= match(regex_TagValue, fileline)
        if match_tv isa RegexMatch
            if occursin(regex_checkmultilinestart, fileline)
                while !occursin(regex_checkmultilinestop, fileline)
                    fileline= fileline * "\n" * readline(TVfile)
                end
                match_tv= match(regex_multiline, fileline)
            end
            if match_tv["Tag"] in ["SPDXVersion", "PackageName", "FileName", "SnippetSPDXID", "LicenseID", "Relationship", "Annotator"]
                NextSection= match_tv
                break
            else
                push!(TagValues, match_tv)
            end
        end
    end

    return (TagValues= TagValues, NextSection= NextSection)
end