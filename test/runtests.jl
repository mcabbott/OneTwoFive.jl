using Test, OneTwoFive

@testset "day one" begin
    @test onetwofive(10) == [1, 2, 5, 10]
    @test eltype(onetwofive(10)) == Int
    @test onetwofive(0.1f0, 5) ≈ [0.1, 0.2, 0.5, 1.0, 2.0, 5.0]
    @test eltype(onetwofive(0.1f0, 5)) == Float32

    @test onethree(30) == [1, 3, 10, 30]
    @test eltype(onethree(30)) == Int
    @test eltype(onethree(30.0)) == Float64
    @test onethree(0.1, 10) == [0.1, 0.3, 1.0, 3.0, 10.0]

    @test view(onethree(100), 2:4) == [3, 10, 30]
    @test view(onethree(100), 2:4) isa OneTwoFive.Struct
    @test reverse(onethree(10)) == [10, 3, 1]
    @test reverse(onethree(10)) isa SubArray{Int, 1, <:OneTwoFive.Struct}

    @test decades(100) == [1, 10, 100]
    @test decades(0.1, 10) == [0.1, 1, 10]

    @test decades(10; divide=1) == [1, 10]
    @test decades(10; divide=2) == [1, 3, 10]
    @test decades(10; divide=3) == [1, 2, 5, 10]
    @test decades(10; divide=4) == [1, 2, 3, 6, 10]
    @test_throws ArgumentError decades(10; divide=5)
    @test_throws ArgumentError decades(10; divide=0)

    @test onetwo(10) == [1, 2, 4, 8]
    @test onetwo(1//4, 4) == [1//4, 1//2, 1, 2, 4]
    @test onetwo(1//4, 4) isa OneTwoFive.Struct{<:Rational}

    for fun in [onetwofive, onethree, decades, onetwo]
        @test_throws DomainError fun(0.1)
        @test_throws DomainError fun(0)
        @test_throws DomainError fun(10, 1)
        @test_throws DomainError fun(-3, 4)
        @test_throws DomainError fun(5, 0)
    end
end
