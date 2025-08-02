module OneTwoFive

export onetwofive, onethree, decades, onetwo

"""
    OneTwoFive.Struct{T,B,N}

`LogRange`-like object with eltype `T`,
which divides `1` to `B` into `N` steps.
Case B=10 understands N=1,2,3,4, and case B=2 only N=1.
"""
struct Struct{T<:Real,B,N} <: AbstractVector{T}
    off::Int
    len::Int
end

Base.length(x::Struct) = x.len
Base.size(x::Struct) = (x.len,)

# TODO, perhaps:
# add a type parameter for how many digits to display,
# and write generic `getindex` which rounds as required.

function Base.getindex(x::Struct{T,B,N}, ij::UnitRange{Int}) where {T,B,N}
    off = x.off + ij.start - 1
    if (T <: Integer) && (off < 0)
        @error lazy"""`r::OneTwoFive.Struct{$T}` allows some out-of-bounds indexing,
            but only where the result is still an integer. Try with `float(r)`."""
        throw(BoundsError(x, ij.start))
    end
    Struct{T,B,N}(off, length(ij))
end
Base.view(x::Struct, ij::UnitRange{Int}) = getindex(x, ij)

Base.float(x::Struct{T,B,N}) where {T,B,N} = Struct{float(T),B,N}(x.off, x.len)

Base.reverse(x::Struct) = view(x, reverse(eachindex(x)))

#####
##### Base 10
#####

for list in [true, (1,3), (1,2,5), (1,2,3,6)]
    N = length(list)
    @eval function Base.getindex(x::Struct{T,10,$N}, i::Int) where T
        a, b = fldmod1(i + x.off, $N)
        if (T <: Integer) && (a <= 0)
            @error lazy"""`r::OneTwoFive.Struct{$T}` allows some out-of-bounds indexing,
                but only where the result is still an integer. Try with `float(r)`."""
            throw(BoundsError(x, i))
        end
        if a > 0
            $list[b] * 10^(a-1) |> T
        else
            $list[b] / 10^(1-a) |> T
        end
    end
end

#=
julia> onetwo(1//8, 8)
7-element OneTwoFive.Struct{Rational{Int64}, 2, 1}:
 1//8, 1//4, 1//2, 1//1, 2//1, 4//1, 8//1

julia> onetwofive(1//10, 10)  # this is pretty ugly!
7-element OneTwoFive.Struct{Rational{Int64}, 10, 3}:
 3602879701896397//36028797018963968 … 1//2, 1//1, 2//1, 5//1, 10//1
=#

# Int.(10 .* round.(logrange(1, 10, 5+1)[1:end-1]; sigdigits=2)) |> Tuple
for list in [
        (10//10, 16//10, 25//10, 40//10, 63//10),
        (10//10, 15//10, 22//10, 32//10, 46//10, 68//10),
        (10//10, 14//10, 19//10, 27//10, 37//10, 52//10, 72//10),
    ]
    N = length(list)
    @eval function Base.getindex(x::Struct{T,10,$N}, i::Int) where T
        a, b = fldmod1(i + x.off, $N)
        if (T <: Integer) && (a <= 0)
            @error lazy"""`r::OneTwoFive.Struct{$T}` allows some out-of-bounds indexing,
                but only where the result is still an integer. Try with `float(r)`."""
            throw(BoundsError(x, ij.start))
        end
        if a > 0
            $list[b] * 10^(a-1) |> T
        else
            $list[b] / 10^(1-a) |> T
        end
    end
end

"""
    onetwofive(stop)

Constructs a range a bit like `logrange(1, stop; length)`,
whose elements are exactly `[1, 2, 5, 10, 20, 50, ...]`,
ending with the value nearest (in log) to `stop`.

See also [`onethree`](@ref) and [`decades`](@ref).

## Examples

```jldoctest
julia> onetwofive(9)
4-element OneTwoFive.Struct{Int64, 10, 3}:
 1, 2, 5, 10

julia> relerror(x, y) = (x-y)/y;

julia> relerror.(onetwofive(10), logrange(1, 10, 4))
4-element Vector{Float64}:
  0.0
 -0.07168223327744426
  0.07721734501594177
  0.0
```
"""
function onetwofive(stop::Real)
    stop < 1 && _domainerror(1, stop, :onetwofive)
    Struct{typeof(stop),10,3}(0, 1 + round(Int, 3*log10(stop)))
end

function _domainerror(start::Real, stop::Real, fun::Symbol)
    str = if start <= 0 || stop <= 0
        lazy"This range must start & stop at positive numbers"
    else
        lazy"This range must stop after it starts! Try reverse($fun($stop, $start))"
    end
    throw(DomainError((start, stop), str))
end

"""
    onethree(stop)

Constructs a range a bit like `logrange(1, stop; length)`,
whose elements are exactly `[1, 3, 10, 30, 100, ...]`,
ending with the value nearest (in log) to `stop`.

## Examples

```jldoctest
julia> onethree(10_000)
9-element OneTwoFive.Struct{Int64, 10, 2}:
 1, 3, 10, 30, 100, 300, 1000, 3000, 10000

julia> relerror(x, y) = (x-y)/y;

julia> relerror.(onethree(10), logrange(1, 10, 3))
3-element Vector{Float64}:
  0.0
 -0.05131670194948626
  0.0
```
"""
function onethree(stop::Real)
    stop < 1 && _domainerror(1, stop, :onethree)
    Struct{typeof(stop),10,2}(0, 1 + round(Int, 2*log10(stop)))
end

"""
    decades(stop)

Constructs a range a bit like `logrange(1, stop; length)`,
whose elements are exactly `[1, 10, 100, ...]`,
ending with the value nearest (in log) to `stop`.

## Examples

```jldoctest
julia> decades(1001)
4-element OneTwoFive.Struct{Int64, 10, 1}:
 1, 10, 100, 1000

julia> decades(315f0)
3-element OneTwoFive.Struct{Float32, 10, 1}:
 1.0, 10.0, 100.0
```
"""
function decades(stop::Real; divide::Int=1)
    divide == 1 || return decades(1, stop; divide)
    stop < 1 && _domainerror(1, stop, :decades)
    Struct{typeof(stop),10,1}(0, 1 + round(Int, log10(stop)))
end

function four(stop::Real)
    stop < 1 && error("bad limits!")
    Struct{typeof(stop),10,4}(0, 1 + round(Int, 4*log10(stop)))
end

"""
    onetwofive(start, stop)

Constructs a range a bit like `logrange(start, stop; length)`,
whose elements are in `[1, 2, 5] .* 10^n`.
Both `start` and `stop` will be rounded to the nearest such value.

See also `onethree(start, stop)` for two divisions per decade, and `decades(start, stop)` for one.

## Examples

```jldoctest
julia> onetwofive(27, 73)
3-element OneTwoFive.Struct{Int64, 10, 3}:
 20, 50, 100

julia> onetwofive(0.0101, 0.9899)
7-element OneTwoFive.Struct{Float64, 10, 3}:
 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1.0
```
"""
function onetwofive(start::Real, stop::Real)
    stop < start && _domainerror(start, stop, :onetwofive)
    start <= 0 && _domainerror(start, stop, :onetwofive)
    T = promote_type(typeof(start), typeof(stop))
    off = round(Int, 3*log10(start))
    beta = round(Int, 3*log10(stop))
    Struct{T,10,3}(off, 1 + beta - off)
end
function onethree(start::Real, stop::Real)
    stop < start && _domainerror(start, stop, :onethree)
    start <= 0 && _domainerror(start, stop, :onethree)
    T = promote_type(typeof(start), typeof(stop))
    off = round(Int, 2*log10(start))
    beta = round(Int, 2*log10(stop))
    Struct{T,10,2}(off, 1 + beta - off)
end

"""
    decades(start, stop; divide=1)

Constructs a range a bit like `logrange(start, stop; length)`,
with `divide` nicely rounded points per decade.
The keyword divide accepts only values `1, 2, 3, 4`:

## Examples

```jldoctest
julia> Any[d => decades(0.1, 10; divide=d) for d in (1,2,3,4)]
4-element Vector{Any}:
 1 => [0.1, 1.0, 10.0]
 2 => [0.1, 0.3, 1.0, 3.0, 10.0]
 3 => [0.1, 0.2, 0.5, 1.0, 2.0, 5.0, 10.0]
 4 => [0.1, 0.2, 0.3, 0.6, 1.0, 2.0, 3.0, 6.0, 10.0]
```

Case `divide=2` is also `onethree`, and case `divide=3` is called `onetwofive`.

Here's a plot of how far from logrythmic the different cases are:

```
using Plots

plot(decades(1, 100; divide=1), yaxis=:log10, xguide="index", yguide="value", lab="decades")
plot!(decades(1, 100; divide=2), lab="onethree")
plot!(decades(1, 100; divide=3), lab="onetwofive")
plot!(decades(1, 100; divide=4), lab="divide = 4", legend=:bottomright)

plot!(decades(1.0, 100.0; divide=5), lab="divide = 5")
```

Here's an example of using them as ticks in the plot:

```
using Plots
plt = map(1:4) do n
  vec = decades(1, 100; divide=n)
  plot(cumsum(rand(200)); yaxis=:log10, ylim=[1, 100], yticks=(vec, vec), title=string("divide = ", n), lab="")
end;
plot(plt...)
```

"""
function decades(start, stop; divide::Int=1)
    stop < start && _domainerror(start, stop, :decades)
    start <= 0 && _domainerror(start, stop, :decades)
    off = round(Int, divide*log10(start))
    beta = round(Int, divide*log10(stop))
    T = promote_type(typeof(start), typeof(stop))
    if divide in (1,2,3,4)  # ok!
    elseif divide in (5,6,7)
        if T <: Integer && off < divide
            throw(ArgumentError(lazy"with divide=$divide, this range would contain non-integer values"))
        end
    else
        throw(ArgumentError(lazy"can't divide into $divide, sorry"))
    end
    Struct{T,10,divide}(off, 1 + beta - off)
end

# function decades(start, stop; divide::Int=1)
#     stop < start && error("bad limits!")
#     divide in (1,2,3,4) || error("can't divide into $divide")
#     T = promote_type(typeof(start), typeof(stop))
#     off = round(Int, divide*log10(start))
#     beta = round(Int, divide*log10(stop))
#     Struct{T,10,divide}(off, 1 + beta - off)
# end

#####
##### Base 2
#####

function Base.getindex(x::Struct{T,2,1}, i::Int) where T
    # 2^(i + x.off - 1) |> T
    a = i + x.off - 1
    if a >= 0
        1 << a |> T
    else
        inv(1 << -a) |> T
    end
end

# function Base.getindex(x::Struct{T,2,2}, i::Int) where T
#     a, b = fldmod1(i + x.off, 2)
#     if a > 0
#         (1.0, 1.4, 2.0)[b] * 2^(a-1) |> T
#     else
#         (1.0, 1.4, 2.0)[b] / 2^(1-a) |> T
#     end
# end

"""
    onetwo(stop)

Constructs a range a bit like `logrange(1, stop; length)`,
whose elements are exactly `[1, 2, 4, 8, 16, ...]`,
ending with the value nearest (in log) to `stop`.

## Example

```jldoctest
julia> onetwo(90.6)
8-element OneTwoFive.Struct{Float64, 2, 1}:
 1.0, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0, 128.0
```
"""
function onetwo(stop::Real)
    stop < 1 && _domainerror(1, stop, :onetwo)
    Struct{typeof(stop),2,1}(0, 1 + round(Int, log2(stop)))
end
"""
    onetwo(start, stop)

Constructs a range a bit like `logrange(start, stop; length)`,
whose elements are all `2^n` for some integer `n`.
Both `start` and `stop` will be rounded to the nearest such value.

See also [`decades`](@ref) for the same idea with `10^n` instead.

## Examples

```
julia> onetwo(10^2, 10^3)
4-element OneTwoFive.Struct{Int64, 2, 1}:
 128, 256, 512, 1024

julia> onetwo(1//10, 30)
9-element OneTwoFive.Struct{Rational{Int64}, 2, 1}:
 1//8, 1//4, 1//2, 1//1, 2//1, 4//1, 8//1, 16//1, 32//1
```
"""
function onetwo(start::Real, stop::Real)
    stop < start && _domainerror(start, stop, :onetwo)
    start <= 0 && _domainerror(start, stop, :onetwo)
    T = promote_type(typeof(start), typeof(stop))
    off = round(Int, log2(start))
    beta = round(Int, log2(stop))
    Struct{T,2,1}(off, 1 + beta - off)
end

#####
##### Printing
#####

function Base.show(io::IO, ::MIME"text/plain", r::Struct)  # display like LinRange
    # isempty(r) && return show(io, r)  # can never be empty
    summary(io, r)
    println(io, ":")
    Base.print_range(io, r, " ", ", ", "", " \u2026 ")
end

function Base.show(io::IO, ::MIME"text/plain", r::SubArray{<:Real, 1, <:Struct, <:Tuple{AbstractRange{Int}}, false}
)
    # isempty(r) && return show(io, r)  # can never be empty
    summary(io, r)
    println(io, ":")
    Base.print_range(io, r, " ", ", ", "", " \u2026 ")
end


end # module OneTwoFive
