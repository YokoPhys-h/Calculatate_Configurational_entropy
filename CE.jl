#####################################################################
# FUNCTIONS
#####################################################################
## Packages
using FFTW
using Plots

## Function: Data loading
function file_input(hoge::String)
    f = open("$hoge", "r")
    data = readlines(f)
    data = [split(data[i], r"\s+", keepempty = false) for i = 1:length(data)]
    data = [parse.(Float64, data[i]) for i = 1:length(data)]
    data1 = [data[i][1] for i = 1:length(data)]
    data2 = [data[i][2:length(data[1])] for i = 1:length(data)]
    close(f)
    return hcat(data1, data2)
end

## Function: Discretize a function by its parameters
function disc(CE_func, N::Int64, c::StepRangeLen)
    xj = (0:(N-1)) * 2 * π / (N)
    para_val = []
    func_disc = []
    func_disc_para = []
    for c0 in c
        para_val = push!(para_val, c0)
        func_disc = vcat(func_disc, [CE_func.(xj, c0)])
    end
    func_disc_para = hcat(para_val, func_disc)
    return func_disc_para
end


## Funcion: Calculate the Fast Fourier Transformation (FFT) by its parameters
function FFT(data)
    shifted_k = []
    shifted_fft = []
    shifted_para_fft = []
    shifted_k = fftshift(fftfreq(length(data[1, 2])) * length(data[1, 2]))
    for i = 1:size(data, 1)
        shifted_fft = vcat(shifted_fft, [fftshift(fft(data[i, 2])) / (length(test[1, 2]))])
    end
    shifted_para_fft = hcat(data[1:size(data, 1)], shifted_fft)
    return [shifted_k, shifted_para_fft]
end


## Function: Calculate the Configurational_Entropy by its parameters
function CE(fft_ans)
    A_k = []
    f_k = []
    ds = []
    S = []
    CE_para_S = []
    for i = 1:size(fft_ans[2, 1], 1)
        A_k = vcat(A_k, [(abs.(fft_ans[2, 1][i, 2]))])
    end
    for i = 1:length(A_k)
        f_k = vcat(f_k, [A_k[i, 1] .^ 2 / sum(A_k[i, 1] .^ 2)])
    end
    for i = 1:size(fft_ans[2, 1], 1)
        ds = vcat(ds, [-log.(f_k[i, 1]) .* f_k[i, 1]])
    end
    for i = 1:size(fft_ans[2, 1], 1)
        S = vcat(S, [sum(ds[i, 1])])
    end
    CE_para_S = hcat(fft_ans[2, 1][1:size(fft_ans[2, 1], 1)], S)
    return CE_para_S
end

#####################################################################
#####################################################################






#####################################################################
# MAIN
#####################################################################
## Funcion: Define a function to calculate CE by its parameter.
## CE_func(<variable>, <parameter>)
function CE_func(x, c0)
    λ = 1.03
    α = c0 / √(c0^2 - 4)
    a1 = -c0 / α
    (6 * (λ)^2) / (a1 + cosh(2 * (λ) * x))^4 - (8 * (λ)^2 * c0 * cosh(2 * (λ) * x)) / (α * (a1 + cosh(2 * (λ) * x))^4) + (2 * (λ)^2 * cosh(4 * (λ) * x)) / (a1 + cosh(2 * (λ) * x))^4
end

## disc(<CE_func>, <Number of divisions>, <range of parameter>)
test = disc(CE_func, 2000, -3.0:0.005:-2.0) # When you calculate CE using function. 

test_d = file_input("C:\\Users\\<username>\\hoge\\piyo\\hogehoge.txt") # When you calculate CE using numerical data.

## calculate FFT
fft_ans = FFT(test)

## plot FFT data. (x-axis: frequency, y-axis: Fourier coefficient)
plotly()
plot(fft_ans[1, 1], abs.(fft_ans[2, 1][1, 2]), title = "Shifted FFT")

## calculate CE
CE_para_S = CE(fft_ans)

## plot CE (x-axis: parameter, y-axis: CE)
plot(CE_para_S[1:size(CE_para_S, 1), 1], CE_para_S[1:size(CE_para_S, 1), 2])

## Output CE data
open("file.txt", "w") do out
    Base.print_array(out, CE_para_S)
end
#####################################################################
#####################################################################