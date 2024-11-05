# 定义 InclinedPlane 结构体，表示斜面模型
struct InclinedPlane
    base_length::Float64   # 底边长度 l
    angle::Float64         # 斜面角度 ϕ (以弧度表示)
end

# 重力加速度 (常量)
const g = 9.81  # m/s^2

# 定义方法来计算斜面的长度 L
function length_of_plane(plane::InclinedPlane)
    return plane.base_length / cos(plane.angle)
end

# 定义方法来计算物体在斜面上的下滑时间
function sliding_time(plane::InclinedPlane)
    L = length_of_plane(plane)  # 计算斜面长度
    sin_ϕ = sin(plane.angle)
    if sin_ϕ == 0
        error("斜面角度不能为零")  # 避免除零错误
    end
    t = sqrt(2 * L / (g * sin_ϕ))  # 计算滑动时间
    return t
end

# 定义一个显示方法，打印斜面的信息
function show(plane::InclinedPlane)
    println("斜面模型:")
    println("底边长度 (l): ", plane.base_length, " m")
    println("角度 (ϕ): ", plane.angle, " radians")
    println("斜面长度 (L): ", length_of_plane(plane), " m")
    println("滑动时间 (t): ", sliding_time(plane), " seconds")
end

# 示例使用：创建一个 InclinedPlane 对象并展示其信息
plane = InclinedPlane(1.0, π/6)  # 1米的底边长度，30度的角度
show(plane)
