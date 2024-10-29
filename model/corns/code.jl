using Random
using LsqFit

# 1. 生成随机抛币实验
function coin_toss_simulation(n)
    tosses = 10^n
    heads_count = sum(rand(Bool, tosses))  # 统计正面出现次数
    probability = heads_count / tosses  # 计算正面概率
    return heads_count, probability
end

# 2. 计算误差
function calculate_errors(probability, true_probability=0.5)
    absolute_error = abs(probability - true_probability)
    relative_error = absolute_error / true_probability
    return absolute_error, relative_error
end

# 3. 进行实验并收集结果
function run_experiment(max_n)
    results = []

    for n in 1:max_n
        heads_count, probability = coin_toss_simulation(n)
        absolute_error, relative_error = calculate_errors(probability)
        
        push!(results, (n, heads_count, probability, absolute_error, relative_error))
    end

    return results
end

# 4. 拟合模型
function model(n::Float64, c::Float64, k::Float64)
    return 0.5 + c / (n ^ k)  # 单个 n 的计算
end

function model_full(n::Vector{Float64}, p::Vector{Float64})
    c = p[1]  # 从参数中提取 c
    k = p[2]  # 从参数中提取 k
    return map(n_i -> model(n_i, c, k), n)  # 对 n 的每个元素应用 model
end

# 5. 主函数
function main(max_n)
    # 进行实验并获取结果
    results = run_experiment(max_n)

    # 提取数据以进行拟合
    n_values = Float64[res[1] for res in results]  # n 值
    probabilities = [res[3] for res in results]     # 概率

    # 拟合
    initial_params = [0.1, 1.0]  # 初始参数 [c, k]
    fit = curve_fit(model_full, n_values, probabilities, initial_params)

    # 拟合参数
    c_fit, k_fit = fit.param

    # 生成拟合数据
    fitted_probabilities = model_full(n_values, fit.param)

    # 打印实验结果
    println("Fitted parameters:")
    println("c: $c_fit")
    println("k: $k_fit")
    println("Fitted probabilities:")
    for (n, prob, fitted_prob) in zip(n_values, probabilities, fitted_probabilities)
        println("n: $n, Observed Probability: $prob, Fitted Probability: $fitted_prob")
    end
end

# 6. 执行实验，设定最大 n 为 6 (对应 10^6 次抛币)
main(6)
