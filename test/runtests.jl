using Test, OneTwoFive

using OneTwoFive: OneTwoFiveStruct

@testset "day one" begin
    @test onetwofive(10) == [1, 2, 5, 10]
    @test eltype(onetwofive(10)) == Int
    @test onetwofive(0.1f0, 5) ≈ [0.1, 0.2, 0.5, 1.0, 2.0, 5.0]
    @test eltype(onetwofive(0.1f0, 5)) == Float32

    @test onethree(30) == [1, 3, 10, 30]
    @test eltype(onethree(30)) == Int
    @test eltype(onethree(30.0)) == Float64
    @test onethree(0.1, 10) == [0.1, 0.3, 1.0, 3.0, 10.0]

    @test decades(100) == [1, 10, 100]
    @test decades(0.1, 10) == [0.1, 1, 10]

    @test decades(10; divide=1) == [1, 10]
    @test decades(10; divide=2) == [1, 3, 10]
    @test decades(10; divide=3) == [1, 2, 5, 10]
    @test decades(10; divide=4) == [1, 2, 3, 6, 10]
    @test_throws ArgumentError decades(10; divide=5)
    @test_throws ArgumentError decades(10; divide=0)
end
