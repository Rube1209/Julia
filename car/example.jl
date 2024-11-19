using Plots
using Statistics

# 基础参数结构体
struct LocomotiveParams
    mass::Float64            # 质量 (kg)
    max_power::Float64      # 最大功率 (W)
    max_force::Float64      # 最大牵引力 (N)
    max_brake_force::Float64 # 最大制动力 (N)
    resistance_coef::Float64 # 基础阻力系数
    wheel_diameter::Float64  # 轮径 (m)
    front_area::Float64     # 迎风面积 (m²)
    gear_ratio::Float64     # 传动比
    regen_efficiency::Float64 # 能量回收效率
end

struct MotorParams
    efficiency::Float64     # 电机效率
    max_rpm::Float64       # 最大转速
end

struct EnvironmentParams
    temperature::Float64   # 温度 (℃)
    wind_speed::Float64   # 风速 (m/s)
    wind_direction::Float64 # 风向 (rad)
    grade::Float64        # 坡度 (rad)
    curve_radius::Float64 # 曲线半径 (m)
end

# PID控制器结构体
mutable struct PIDController
    kp::Float64
    ki::Float64
    kd::Float64
    integral::Float64
    last_error::Float64
end

# 制动模式枚举
@enum BrakeMode begin
    NO_BRAKE
    REGEN_BRAKE
    MECHANICAL_BRAKE
    BLENDED_BRAKE
end

# 载荷变化结构体
struct LoadProfile
    base_load::Float64      # 基础载荷
    variations::Vector{Tuple{Float64, Float64}}  # (时间点, 载荷变化)
end

# 控制模式结构体
struct ControlMode
    speed_control::Bool     # 速度控制模式
    energy_saving::Bool     # 节能模式
    smooth_control::Bool    # 平顺模式
end

# 高级控制器结构体
mutable struct AdvancedController
    pid::PIDController
    mode::ControlMode
    last_output::Float64
    max_rate::Float64      # 最大变化率
end

# 计算总阻力
function calculate_total_resistance(v::Float64, params::LocomotiveParams, 
                                  env::EnvironmentParams)
    # 基本运行阻力
    basic_resistance = params.resistance_coef * params.mass * 9.81
    
    # 空气阻力 (0.5 * ρ * Cd * A * v²)
    air_density = 1.225 * (288.15 / (273.15 + env.temperature))
    air_resistance = 0.5 * air_density * 0.8 * params.front_area * v^2
    
    # 坡道阻力
    grade_resistance = params.mass * 9.81 * sin(env.grade)
    
    # 曲线阻力
    curve_resistance = if env.curve_radius > 0
        600 * params.mass * 9.81 / env.curve_radius
    else
        0.0
    end
    
    return basic_resistance + air_resistance + grade_resistance + curve_resistance
end

# 计算牵引力
function calculate_traction_force(v::Float64, throttle::Float64, 
                                loco::LocomotiveParams, motor::MotorParams, 
                                env::EnvironmentParams)
    if v <= 0.0
        return throttle * loco.max_force
    end
    
    # 计算当前转速
    rpm = (60 * v * loco.gear_ratio) / (π * loco.wheel_diameter)
    
    if rpm > motor.max_rpm
        return 0.0
    end
    
    # 功率限制下的牵引力
    power_limited_force = loco.max_power * motor.efficiency / v
    
    # 考虑最大牵引力和功率限制
    max_available_force = min(loco.max_force, power_limited_force)
    
    return throttle * max_available_force
end

# 基础PID控制
function pid_control(pid::PIDController, target::Float64, current::Float64, 
                    dt::Float64)
    error = target - current
    pid.integral += error * dt
    derivative = (error - pid.last_error) / dt
    pid.last_error = error
    
    return pid.kp * error + pid.ki * pid.integral + pid.kd * derivative
end

# 制动力计算
function calculate_brake_force(v::Float64, brake_demand::Float64, 
                             mode::BrakeMode, params::LocomotiveParams)
    if mode == NO_BRAKE
        return 0.0
    end
    
    max_brake = params.max_brake_force
    
    if mode == REGEN_BRAKE
        if v < 5.0
            return 0.0
        else
            return min(max_brake * brake_demand, params.max_power / v)
        end
    elseif mode == MECHANICAL_BRAKE
        return max_brake * brake_demand
    else  # BLENDED_BRAKE
        if v < 5.0
            return max_brake * brake_demand
        else
            regen_force = min(max_brake * 0.6 * brake_demand, 
                            params.max_power / v)
            mech_force = max_brake * 0.4 * brake_demand
            return regen_force + mech_force
        end
    end
end

# 计算回收能量
function calculate_regenerated_energy(brake_force::Float64, v::Float64, 
                                    params::LocomotiveParams)
    if v < 5.0
        return 0.0
    else
        return brake_force * v * params.regen_efficiency
    end
end

# 计算当前载荷
function calculate_current_load(t::Float64, load_profile::LoadProfile)
    current_load = load_profile.base_load
    
    for (time, variation) in load_profile.variations
        if t >= time
            current_load += variation
        end
    end
    
    return current_load
end

# 改进的控制算法
function advanced_control(controller::AdvancedController, 
                         target_v::Float64, current_v::Float64, 
                         current_power::Float64, dt::Float64)
    pid_output = pid_control(controller.pid, target_v, current_v, dt)
    
    if controller.mode.smooth_control
        rate = (pid_output - controller.last_output) / dt
        if abs(rate) > controller.max_rate
            pid_output = controller.last_output + 
                        sign(rate) * controller.max_rate * dt
        end
    end
    
    if controller.mode.energy_saving
        pid_output *= 0.8
    end
    
    controller.last_output = pid_output
    return pid_output
end

# 主模拟函数中修改这行
function simulate_advanced(loco_params::LocomotiveParams,
    motor_params::MotorParams,
    env::EnvironmentParams,
    load_profile::LoadProfile,
    target_v::Float64,
    duration::Float64,
    dt::Float64)
steps = Int(duration/dt)
t = collect(range(0, duration, length=steps))  # 添加 collect 转换为向量

    
    v = zeros(steps)  # 速度
    s = zeros(steps)  # 位移
    f = zeros(steps)  # 牵引力
    b = zeros(steps)  # 制动力
    p = zeros(steps)  # 功率
    e = zeros(steps)  # 回收能量
    
    controller = AdvancedController(
        PIDController(0.5, 0.1, 0.05, 0.0, 0.0),
        ControlMode(true, true, true),
        0.0,
        0.2
    )
    
    for i in 2:steps
        current_load = calculate_current_load(t[i], load_profile)
        
        control_output = advanced_control(controller, target_v, v[i-1], p[i-1], dt)
        
        brake_mode = if control_output < 0
            BLENDED_BRAKE
        else
            NO_BRAKE
        end
        
        if control_output >= 0
            f[i] = calculate_traction_force(v[i-1], control_output, 
                                          loco_params, motor_params, env)
            b[i] = 0.0
        else
            f[i] = 0.0
            b[i] = calculate_brake_force(v[i-1], -control_output, 
                                       brake_mode, loco_params)
        end
        
        e[i] = calculate_regenerated_energy(b[i], v[i-1], loco_params)
        
        total_force = f[i] - b[i] - 
                     calculate_total_resistance(v[i-1], loco_params, env)
        a = total_force / (loco_params.mass + current_load)
        
        v[i] = max(0.0, v[i-1] + a * dt)
        s[i] = s[i-1] + v[i-1] * dt
        p[i] = f[i] * v[i]
    end
    
    return t, v, s, f, b, p, e
end

## 修改评估性能函数
function evaluate_performance(t::Vector{Float64}, v::Vector{Float64}, 
    p::Vector{Float64}, e::Vector{Float64})
# 找到首次达到20m/s的时间
acc_index = findfirst(x -> x >= 20.0, v)
acc_time = isnothing(acc_index) ? Inf : t[acc_index]

# 计算能量消耗
total_energy = sum(p) * (t[2]-t[1]) / 3600000
recovered_energy = sum(e) * (t[2]-t[1]) / 3600000
net_energy = total_energy - recovered_energy

# 计算加加速度
jerk = diff(diff(v)) ./ (t[2]-t[1])^2
max_jerk = maximum(abs.(jerk))

return Dict(
"acceleration_time" => acc_time,
"total_energy" => total_energy,
"recovered_energy" => recovered_energy,
"net_energy" => net_energy,
"max_jerk" => max_jerk
)
end
# 创建参数实例并运行模拟
# 调整机车参数
loco = LocomotiveParams(
    80000.0,    # 质量 (kg)
    4000000.0,  # 最大功率 (W) - 增加
    300000.0,   # 最大牵引力 (N) - 增加
    180000.0,   # 最大制动力 (N)
    0.002,      # 阻力系数 - 降低
    1.0,        # 轮径 (m)
    10.0,       # 迎风面积 (m²)
    4.5,        # 传动比
    0.85        # 能量回收效率
)

# 保持电机参数不变
motor = MotorParams(
    0.95,       # 效率
    3000.0      # 最大转速
)

# 调整环境参数
env = EnvironmentParams(
    20.0,       # 温度 (℃)
    0.0,        # 风速 (m/s)
    0.0,        # 风向 (rad)
    0.0,        # 坡度 (rad)
    0.0         # 曲线半径 (m)
)

# 简化载荷配置
load_profile = LoadProfile(
    0.0,  # 基础载荷
    [(10.0, 2000.0), (30.0, -1000.0)]  # 载荷变化降低
)

# 修改主模拟函数中的控制器参数
function simulate_advanced(loco_params::LocomotiveParams,
                         motor_params::MotorParams,
                         env::EnvironmentParams,
                         load_profile::LoadProfile,
                         target_v::Float64,
                         duration::Float64,
                         dt::Float64)
    steps = Int(duration/dt)
    t = collect(range(0, duration, length=steps))
    
    v = zeros(steps)  # 速度
    s = zeros(steps)  # 位移
    f = zeros(steps)  # 牵引力
    b = zeros(steps)  # 制动力
    p = zeros(steps)  # 功率
    e = zeros(steps)  # 回收能量
    
    # 调整控制器参数
    controller = AdvancedController(
        PIDController(2.0, 0.5, 0.1, 0.0, 0.0),  # 增加PID增益
        ControlMode(true, false, true),  # 关闭节能模式
        0.0,
        1.0  # 增加最大变化率
    )
    
    for i in 2:steps
        current_load = calculate_current_load(t[i], load_profile)
        
        control_output = advanced_control(controller, target_v, v[i-1], p[i-1], dt)
        
        brake_mode = if control_output < 0
            BLENDED_BRAKE
        else
            NO_BRAKE
        end
        
        if control_output >= 0
            f[i] = calculate_traction_force(v[i-1], control_output, 
                                          loco_params, motor_params, env)
            b[i] = 0.0
        else
            f[i] = 0.0
            b[i] = calculate_brake_force(v[i-1], -control_output, 
                                       brake_mode, loco_params)
        end
        
        e[i] = calculate_regenerated_energy(b[i], v[i-1], loco_params)
        
        total_force = f[i] - b[i] - 
                     calculate_total_resistance(v[i-1], loco_params, env)
        a = total_force / (loco_params.mass + current_load)
        
        v[i] = max(0.0, v[i-1] + a * dt)
        s[i] = s[i-1] + v[i-1] * dt
        p[i] = f[i] * v[i]
    end
    
    return t, v, s, f, b, p, e
end

# 运行模拟
t, v, s, f, b, p, e = simulate_advanced(loco, motor, env, 
                                      load_profile, 25.0, 60.0, 0.1)

# 绘制结果
plt = plot(layout=(3,2), size=(1000,1200))

plot!(subplot=1, t, v, label="Velocity", ylabel="m/s", title="Velocity Profile")
plot!(subplot=2, t, f./1000, label="Traction Force", ylabel="kN", title="Traction Force")
plot!(subplot=3, t, b./1000, label="Brake Force", ylabel="kN", title="Brake Force")
plot!(subplot=4, t, p./1000000, label="Power", ylabel="MW", title="Power")
plot!(subplot=5, t, e./1000000, label="Recovered Power", ylabel="MW", title="Recovered Power")
plot!(subplot=6, t, s, label="Distance", ylabel="m", title="Distance")

display(plt)

# 评估性能
performance = evaluate_performance(t, v, p, e)
println("\nPerformance Metrics:")
for (key, value) in performance
    println("$key: $value")
end
