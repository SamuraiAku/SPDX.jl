# SPDX-License-Identifier: MIT

###################
function compare(x, y; skipproperties::Vector{Symbol}= Symbol[])
    if typeof(x) === typeof(y)
        return (bval= isequal(x,y), mismatches= Symbol[])
    else
        return (bval= false, mismatches= Symbol[])
    end
end

function compare(x::T, y::T; skipproperties::Vector{Symbol}= Symbol[]) where T<:AbstractSpdx
    if isempty(skipproperties)
        compareprops= propertynames(x)
    else
        compareprops= setdiff(propertynames(x), skipproperties)
    end

    mismatches= Symbol[]
    bval= true

    for prop in compareprops
        compareresult= compare_b(getproperty(x,prop), getproperty(y,prop))
        if false == compareresult
            bval= false
            push!(mismatches, prop)
        end
    end
    return (bval= bval, mismatches= mismatches) 
end

###################
function compare_b(x, y; skipproperties::Vector{Symbol}= Symbol[])
    (;bval::Bool, mismatches)= compare(x, y; skipproperties= skipproperties)
    return bval
end

compare_b(x::Vector, y::Vector; skipproperties::Vector{Symbol}= Symbol[])= is_spdxset_equal(x, y, skipproperties)

###################
function is_spdxset_equal(x::Vector, y::Vector, skipproperties::Vector{Symbol}= Symbol[])
    if length(x) == length(y)
        hash_xvec= _hash.(x, zero(UInt), skipproperties= skipproperties)
        hash_yvec= _hash.(y, zero(UInt), skipproperties= skipproperties)
        return issetequal(hash_xvec, hash_yvec)
    else
        return false
    end
end

###################
compare_rel(r1::SpdxRelationshipV2, r2::SpdxRelationshipV2)= compare_b(r1, r2; skipproperties=Symbol[:Comment])
compare_rel(r1::SpdxRelationshipV2)= Base.Fix2(compare_rel, r1)
