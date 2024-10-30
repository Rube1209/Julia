
using Optim

# 2. 数据准备
data = [
    (2.98, 52.77, 3.4738),
    (24.1, 41.49, 4.2105),
    (2.12, 77.84, 2.33),
    (3.57, 51.92, 3.5414),
    (26.08, 64.03, 3.3427),
    (4.84, 36.3, 4.559),
    (40.91, 34.59, 3.6203),
    (40.88, 66.03, 2.8454),
    (36.12, 6.68, 2.6098),
    (7.49, 10.65, 2.8221),
    (34.63, 23.34, 3.45),
    (45.56, 12.45, 2.98),
    (34.21, 25.67, 9.23)
]

x = [d[1] for d in data]
y = [d[2] for d in data]
measured_concentration = [d[3] for d in data]

# 3. 定义高斯模型损失函数
function gaussian_loss_function(params)
    c0, sigma_x, sigma_y, x0, y0 = params
    predicted_concentration = [
        c0 * exp(-((x[i] - x0)^2 / (2 * sigma_x^2) + (y[i] - y0)^2 / (2 * sigma_y^2))) 
        for i in eachindex(x)
    ]
    sum((predicted_concentration .- measured_concentration).^2)
end

# 定义双曲模型损失函数
function hyperbolic_loss_function(params)
    c1, alpha_x, alpha_y, x1, y1 = params
    predicted_concentration = [
        c1 / (1 + ((x[i] - x1)^2 / alpha_x^2 + (y[i] - y1)^2 / alpha_y^2)) 
        for i in eachindex(x)
    ]
    sum((predicted_concentration .- measured_concentration).^2)
end

# 4. 初始模型优化
initial_params_gaussian = [1.0, 10.0, 10.0, 0.0, 0.0]
result_gaussian = optimize(gaussian_loss_function, initial_params_gaussian)
opt_params_gaussian = Optim.minimizer(result_gaussian)
c0_opt, sigma_x_opt, sigma_y_opt, x0_opt, y0_opt = opt_params_gaussian

initial_params_hyperbolic = [1.0, 10.0, 10.0, 0.0, 0.0]
result_hyperbolic = optimize(hyperbolic_loss_function, initial_params_hyperbolic)
opt_params_hyperbolic = Optim.minimizer(result_hyperbolic)
c1_opt, alpha_x_opt, alpha_y_opt, x1_opt, y1_opt = opt_params_hyperbolic

# 5. 初次计算预测值、误差和相对误差
predicted_concentration_gaussian = [
    c0_opt * exp(-((x[i] - x0_opt)^2 / (2 * sigma_x_opt^2) + (y[i] - y0_opt)^2 / (2 * sigma_y_opt^2)))
    for i in eachindex(x)
]
predicted_concentration_hyperbolic = [
    c1_opt / (1 + ((x[i] - x1_opt)^2 / alpha_x_opt^2 + (y[i] - y1_opt)^2 / alpha_y_opt^2))
    for i in eachindex(x)
]
absolute_errors_gaussian = [abs(predicted_concentration_gaussian[i] - measured_concentration[i]) for i in eachindex(x)]
relative_errors_gaussian = [abs(predicted_concentration_gaussian[i] - measured_concentration[i]) / measured_concentration[i] * 100 for i in eachindex(x)]
absolute_errors_hyperbolic = [abs(predicted_concentration_hyperbolic[i] - measured_concentration[i]) for i in eachindex(x)]
relative_errors_hyperbolic = [abs(predicted_concentration_hyperbolic[i] - measured_concentration[i]) / measured_concentration[i] * 100 for i in eachindex(x)]

# 输出清洗前的表格
println("清洗前的最优参数 - 高斯模型：")
println("c0 = $c0_opt, sigma_x = $sigma_x_opt, sigma_y = $sigma_y_opt, x0 = $x0_opt, y0 = $y0_opt\n")
println("清洗前的最优参数 - 双曲模型：")
println("c1 = $c1_opt, alpha_x = $alpha_x_opt, alpha_y = $alpha_y_opt, x1 = $x1_opt, y1 = $y1_opt\n")

println("清洗前的结果 - 高斯模型：")
println("测量点 | 预测值 | 实际值 | 绝对误差 | 相对误差(%)")
for i in eachindex(x)
    println("测量点 $i: 预测值 = $(round(predicted_concentration_gaussian[i], digits=4)), 实际值 = $(measured_concentration[i]), 绝对误差 = $(round(absolute_errors_gaussian[i], digits=4)), 相对误差 = $(round(relative_errors_gaussian[i], digits=2))%")
end

println("\n清洗前的结果 - 双曲模型：")
println("测量点 | 预测值 | 实际值 | 绝对误差 | 相对误差(%)")
for i in eachindex(x)
    println("测量点 $i: 预测值 = $(round(predicted_concentration_hyperbolic[i], digits=4)), 实际值 = $(measured_concentration[i]), 绝对误差 = $(round(absolute_errors_hyperbolic[i], digits=4)), 相对误差 = $(round(relative_errors_hyperbolic[i], digits=2))%")
end

# 6. 数据清洗：过滤掉相对误差超过20%的数据点
cleaned_data_gaussian = [(x[i], y[i], measured_concentration[i]) for i in eachindex(x) if relative_errors_gaussian[i] <= 20.0]
cleaned_data_hyperbolic = [(x[i], y[i], measured_concentration[i]) for i in eachindex(x) if relative_errors_hyperbolic[i] <= 20.0]
x_cleaned_gaussian = [d[1] for d in cleaned_data_gaussian]
y_cleaned_gaussian = [d[2] for d in cleaned_data_gaussian]
measured_concentration_cleaned_gaussian = [d[3] for d in cleaned_data_gaussian]

x_cleaned_hyperbolic = [d[1] for d in cleaned_data_hyperbolic]
y_cleaned_hyperbolic = [d[2] for d in cleaned_data_hyperbolic]
measured_concentration_cleaned_hyperbolic = [d[3] for d in cleaned_data_hyperbolic]

# 7. 使用清洗后的数据重新优化模型参数
function gaussian_loss_function_cleaned(params)
    c0, sigma_x, sigma_y, x0, y0 = params
    predicted_concentration_cleaned = [
        c0 * exp(-((x_cleaned_gaussian[i] - x0)^2 / (2 * sigma_x^2) + (y_cleaned_gaussian[i] - y0)^2 / (2 * sigma_y^2)))
        for i in eachindex(x_cleaned_gaussian)
    ]
    sum((predicted_concentration_cleaned .- measured_concentration_cleaned_gaussian).^2)
end

function hyperbolic_loss_function_cleaned(params)
    c1, alpha_x, alpha_y, x1, y1 = params
    predicted_concentration_cleaned = [
        c1 / (1 + ((x_cleaned_hyperbolic[i] - x1)^2 / alpha_x^2 + (y_cleaned_hyperbolic[i] - y1)^2 / alpha_y^2))
        for i in eachindex(x_cleaned_hyperbolic)
    ]
    sum((predicted_concentration_cleaned .- measured_concentration_cleaned_hyperbolic).^2)
end

result_gaussian_cleaned = optimize(gaussian_loss_function_cleaned, initial_params_gaussian)
opt_params_gaussian_cleaned = Optim.minimizer(result_gaussian_cleaned)
c0_opt_cleaned, sigma_x_opt_cleaned, sigma_y_opt_cleaned, x0_opt_cleaned, y0_opt_cleaned = opt_params_gaussian_cleaned

result_hyperbolic_cleaned = optimize(hyperbolic_loss_function_cleaned, initial_params_hyperbolic)
opt_params_hyperbolic_cleaned = Optim.minimizer(result_hyperbolic_cleaned)
c1_opt_cleaned, alpha_x_opt_cleaned, alpha_y_opt_cleaned, x1_opt_cleaned, y1_opt_cleaned = opt_params_hyperbolic_cleaned

# 重新计算清洗后的预测值和误差（高斯模型）
predicted_concentration_cleaned_gaussian = [
    c0_opt_cleaned * exp(-((x_cleaned_gaussian[i] - x0_opt_cleaned)^2 / (2 * sigma_x_opt_cleaned^2) + 
                           (y_cleaned_gaussian[i] - y0_opt_cleaned)^2 / (2 * sigma_y_opt_cleaned^2)))
    for i in eachindex(x_cleaned_gaussian)
]
absolute_errors_cleaned_gaussian = [abs(predicted_concentration_cleaned_gaussian[i] - measured_concentration_cleaned_gaussian[i]) for i in eachindex(x_cleaned_gaussian)]
relative_errors_cleaned_gaussian = [abs(predicted_concentration_cleaned_gaussian[i] - measured_concentration_cleaned_gaussian[i]) / measured_concentration_cleaned_gaussian[i] * 100 for i in eachindex(x_cleaned_gaussian)]

# 重新计算清洗后的预测值和误差（双曲模型）
predicted_concentration_cleaned_hyperbolic = [
    c1_opt_cleaned / (1 + ((x_cleaned_hyperbolic[i] - x1_opt_cleaned)^2 / alpha_x_opt_cleaned^2 + 
                           (y_cleaned_hyperbolic[i] - y1_opt_cleaned)^2 / alpha_y_opt_cleaned^2))
    for i in eachindex(x_cleaned_hyperbolic)
]
absolute_errors_cleaned_hyperbolic = [abs(predicted_concentration_cleaned_hyperbolic[i] - measured_concentration_cleaned_hyperbolic[i]) for i in eachindex(x_cleaned_hyperbolic)]
relative_errors_cleaned_hyperbolic = [abs(predicted_concentration_cleaned_hyperbolic[i] - measured_concentration_cleaned_hyperbolic[i]) / measured_concentration_cleaned_hyperbolic[i] * 100 for i in eachindex(x_cleaned_hyperbolic)]

# 输出清洗后的表格
println("\n清洗后的最优参数 - 高斯模型：")
println("c0 = $c0_opt_cleaned, sigma_x = $sigma_x_opt_cleaned, sigma_y = $sigma_y_opt_cleaned, x0 = $x0_opt_cleaned, y0 = $y0_opt_cleaned\n")
println("清洗后的最优参数 - 双曲模型：")
println("c1 = $c1_opt_cleaned, alpha_x = $alpha_x_opt_cleaned, alpha_y = $alpha_y_opt_cleaned, x1 = $x1_opt_cleaned, y1 = $y1_opt_cleaned\n")

println("清洗后的结果 - 高斯模型：")
println("测量点 | 预测值 | 实际值 | 绝对误差 | 相对误差(%)")
for i in eachindex(x_cleaned_gaussian)
    println("测量点 $i: 预测值 = $(round(predicted_concentration_cleaned_gaussian[i], digits=4)), 实际值 = $(measured_concentration_cleaned_gaussian[i]), 绝对误差 = $(round(absolute_errors_cleaned_gaussian[i], digits=4)), 相对误差 = $(round(relative_errors_cleaned_gaussian[i], digits=2))%")
end

println("\n清洗后的结果 - 双曲模型：")
println("测量点 | 预测值 | 实际值 | 绝对误差 | 相对误差(%)")
for i in eachindex(x_cleaned_hyperbolic)
    println("测量点 $i: 预测值 = $(round(predicted_concentration_cleaned_hyperbolic[i], digits=4)), 实际值 = $(measured_concentration_cleaned_hyperbolic[i]), 绝对误差 = $(round(absolute_errors_cleaned_hyperbolic[i], digits=4)), 相对误差 = $(round(relative_errors_cleaned_hyperbolic[i], digits=2))%")
end
