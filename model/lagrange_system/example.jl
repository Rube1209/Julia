# 定义常量
const G = 6.67430e-11  # 引力常数 (m^3 kg^-1 s^-2)
const m1 = 5.972e24    # 地球质量 (kg)
const m2 = 7.348e22    # 月球质量 (kg)
const R = 3.844e8      # 地月平均距离 (m)

# 使用改进后的符号近似公式求解 L3 的近似位置
L3_x = -R * (1 - (5/12) * (m2 / (m1 + m2)) + (m2 / (m1 + m2))^2)

# 输出 L3 结果并与精确值比较
L3_exact = -3.84e8  # 精确值 (m)，带负号
L3_error = abs(L3_x - L3_exact) / abs(L3_exact) * 100

println("L3: 计算值 = $(L3_x / 1e6) 万公里, 精确值 = $(L3_exact / 1e6) 万公里, 相对误差 = $L3_error%")

# 计算其余拉格朗日点的位置
using NLsolve

# 系统的角速度
const ω = sqrt(G * (m1 + m2) / R^3)

# 定义有效势场的平衡方程
function lagrange_system!(F, x)
    r1 = sqrt((x[1] + R * m2 / (m1 + m2))^2 + x[2]^2)
    r2 = sqrt((x[1] - R * m1 / (m1 + m2))^2 + x[2]^2)
    F[1] = -G * m1 / r1^3 * (x[1] + R * m2 / (m1 + m2)) - G * m2 / r2^3 * (x[1] - R * m1 / (m1 + m2)) + ω^2 * x[1]
    F[2] = -G * m1 / r1^3 * x[2] - G * m2 / r2^3 * x[2] + ω^2 * x[2]
end

# 求解 L1 和 L2
L1_sol = nlsolve(lagrange_system!, [0.9*R, 0.0])  # 初始猜测接近精确值
L2_sol = nlsolve(lagrange_system!, [1.1*R, 0.0])

# 求解 L4 和 L5
L4_sol = nlsolve(lagrange_system!, [0.5*R, 0.866*R])
L5_sol = nlsolve(lagrange_system!, [0.5*R, -0.866*R])

# 提取结果
L1_x = L1_sol.zero[1]
L2_x = L2_sol.zero[1]
L4_x, L4_y = L4_sol.zero
L5_x, L5_y = L5_sol.zero

# 精确值（单位：米）
L1_exact = 3.23e8
L2_exact = 4.49e8
L4_exact = sqrt((R / 2)^2 + (R * sqrt(3) / 2)^2)
L5_exact = L4_exact

# 计算相对误差
L1_error = abs(L1_x - L1_exact) / L1_exact * 100
L2_error = abs(L2_x - L2_exact) / L2_exact * 100
L4_error = abs(sqrt(L4_x^2 + L4_y^2) - L4_exact) / L4_exact * 100
L5_error = abs(sqrt(L5_x^2 + L5_y^2) - L5_exact) / L5_exact * 100

# 输出结果
println("L1: 计算值 = $(L1_x / 1e6) 万公里, 精确值 = $(L1_exact / 1e6) 万公里, 相对误差 = $L1_error%")
println("L2: 计算值 = $(L2_x / 1e6) 万公里, 精确值 = $(L2_exact / 1e6) 万公里, 相对误差 = $L2_error%")
println("L3: 计算值 = $(L3_x / 1e6) 万公里, 精确值 = $(L3_exact / 1e6) 万公里, 相对误差 = $L3_error%")
println("L4: 计算值 = $(sqrt(L4_x^2 + L4_y^2) / 1e6) 万公里, 精确值 = $(L4_exact / 1e6) 万公里, 相对误差 = $L4_error%")
println("L5: 计算值 = $(sqrt(L5_x^2 + L5_y^2) / 1e6) 万公里, 精确值 = $(L5_exact / 1e6) 万公里, 相对误差 = $L5_error%")
