# OneTwoFive.jl

This package makes approximately-log-spaced ranges, whose values are always nice round numbers. While `logrange` tries to exactly divide the space betweek given endpoints, `onetwofive` approximates these to 1 digit:

```julia
julia> using OneTwoFive

julia> onetwofive(100)
7-element OneTwoFive.Struct{Int64, 10, 3}:
 1, 2, 5, 10, 20, 50, 100

julia> logrange(1, 100; length=7)
7-element Base.LogRange{Float64, Base.TwicePrecision{Float64}}:
 1.0, 2.15443, 4.64159, 10.0, 21.5443, 46.4159, 100.0

julia> onetwofive(0.01, 0.5)
6-element OneTwoFive.Struct{Float64, 10, 3}:
 0.01, 0.02, 0.05, 0.1, 0.2, 0.5
```

There are similar functions `onethree` (with 2 steps per decade) and `decades`.
Note that for all of them, endpoints may be rounded either up or down:

```julia
julia> onethree(2, 99)
5-element OneTwoFive.Struct{Int64, 10, 2}:
 1, 3, 10, 30, 100

julia> logrange(1, 100, length=5)
5-element Base.LogRange{Float64, Base.TwicePrecision{Float64}}:
 1.0, 3.16228, 10.0, 31.6228, 100.0
```

There is also a similar function `onetwo` which does powers of 2 not 10:

```julia
julia> onetwo(128) == 2 .^ (0:7)
true

julia> onetwo(0.1, 20)
8-element OneTwoFive.Struct{Float64, 2, 1}:
 0.125, 0.25, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0
```
