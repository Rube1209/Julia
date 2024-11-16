module PolynomialExpansion

using Printf

"""
生成所有可能的指数组合矩阵
"""
function generate_exponent_matrix(n::Int, m::Int)
    combinations = Vector{Vector{Int}}()
    
    function recursive_generate(remaining::Int, current::Vector{Int}, pos::Int)
        if pos == m
            if remaining == 0
                push!(combinations, copy(current))
            elseif remaining > 0 && pos == m
                current[pos] = remaining
                push!(combinations, copy(current))
            end
            return
        end
        
        for i in 0:remaining
            current[pos] = i
            recursive_generate(remaining - i, current, pos + 1)
        end
    end
    
    recursive_generate(n, zeros(Int, m), 1)
    sort!(combinations, lt=(a,b) -> lexicographic_compare(a,b))
    
    result_matrix = zeros(Int, length(combinations), m)
    for (i, comb) in enumerate(combinations)
        result_matrix[i, :] = comb
    end
    
    return result_matrix
end

function lexicographic_compare(a::Vector{Int}, b::Vector{Int})
    for (x, y) in zip(reverse(a), reverse(b))
        if x != y
            return x < y
        end
    end
    return false
end

"""
计算阶乘缓存
"""
function factorial_cache(max_n::Int)
    cache = ones(BigInt, max_n + 2)
    for i in 2:(max_n+1)
        cache[i+1] = cache[i] * i
    end
    return cache
end

"""
计算组合的系数
"""
function compute_coefficient(combination::Vector{Int}, fact_cache::Vector{BigInt})
    total = sum(combination)
    coef = fact_cache[total+1]
    for k in combination
        if k > 0
            coef ÷= fact_cache[k+1]
        end
    end
    return coef
end

"""
格式化多项式项
"""
function format_term(combination::Vector{Int})
    if all(x -> x == 0, combination)
        return "1"
    end
    
    term = ""
    for (i, power) in enumerate(combination)
        if power > 0
            term *= "x$(i)"
            if power > 1
                term *= "^$(power)"
            end
        end
    end
    
    return term
end

"""
计算系数矩阵和对应项
"""
function calculate_expansion(matrix::Matrix{Int})
    max_n = maximum([sum(matrix[i,:]) for i in 1:size(matrix,1)])
    fact_cache = factorial_cache(max_n)
    
    coefficients = BigInt[]
    terms = String[]
    
    for i in 1:size(matrix, 1)
        combination = matrix[i, :]
        coef = compute_coefficient(combination, fact_cache)
        term = format_term(combination)
        push!(coefficients, coef)
        push!(terms, term)
    end
    
    return coefficients, terms
end

"""
打印多项式展开的详细结果
"""
function print_expansion(n::Int, m::Int)
    println("\n=== (x₁ + x₂ + ... + x_$m)^$n 的展开式 ===\n")
    
    # 生成指数组合矩阵
    matrix = generate_exponent_matrix(n, m)
    coefficients, terms = calculate_expansion(matrix)
    
    # 打印详细信息
    println("指数矩阵:")
    display(matrix)
    println()
    
    println("系数向量:")
    display(coefficients)
    println()
    
    println("对应单项式:")
    for (i, term) in enumerate(terms)
        println("[$i] $term")
    end
    println()
    
    println("完整对应关系:")
    println("-" ^ 40)
    println("项次  系数  指数组合  单项式")
    println("-" ^ 40)
    for i in 1:length(terms)
        coef_str = string(coefficients[i])
        exponents_str = join(matrix[i,:], "  ")
        @printf("%-6d %-6s %-10s %s\n", i, coef_str, exponents_str, terms[i])
    end
    println("-" ^ 40)
    
    println("\n展开式:")
    expansion = join(["$(coefficients[i])" * (terms[i] == "1" ? "" : terms[i]) for i in 1:length(terms)], " + ")
    println(expansion)
    
    return matrix, coefficients, terms
end

end # module

# 使用示例
using .PolynomialExpansion

# 测试 (x₁ + x₂)²
matrix, coefficients, terms = PolynomialExpansion.print_expansion(2, 2)
