# SPDX-License-Identifier: MIT

###################
function compare(x::T, y::T; skipproperties::Vector{Symbol}= Symbol[]) where T
    return (bval= isequal(x,y), mismatches= Symbol[] )
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
        # How to compare vectors? Broadcast will error if they are different sizes
        x_prop= getproperty(x,prop)
        if x_prop isa Vector
            println("INFO: Also skipping property %s because compare() can't handle vectors at this time")
        else
            compareresult= compare_b(x_prop, getproperty(y,prop))
            if false == compareresult
                bval= false
                push!(mismatches, prop)
            end
        end
    end
    return (bval= bval, mismatches= mismatches) 
end

###################
function compare_b(x, y; skipproperties::Vector{Symbol}= Symbol[])
    if typeof(x) !== typeof(y)
        return false
    else
        (;bval::Bool, mismatches)= compare(x, y; skipproperties= skipproperties)
        return bval
    end
end
