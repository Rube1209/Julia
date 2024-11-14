module Physics

export Motion, Velocity, Position, Acceleration

# 定义运动的主要属性，包括质量
struct Motion
    speed::Float64          # 速度
    displacement::Float64    # 位移
    acceleration::Float64    # 加速度
    mass::Float64            # 质量
end

# Motion 构造函数
function Motion(speed::Float64, displacement::Float64, acceleration::Float64, mass::Float64)
    return Motion(speed, displacement, acceleration, mass)
end

# 定义速度的矢量分量
struct Velocity
    vx::Float64              # x方向的速度
    vy::Float64              # y方向的速度
end

# Velocity 构造函数
function Velocity(vx::Float64, vy::Float64)
    return Velocity(vx, vy)
end

# 定义位置
struct Position
    x::Float64               # x方向的位置
end

# Position 构造函数
function Position(x::Float64)
    return Position(x)
end

# 定义加速度的矢量分量
struct Acceleration
    ax::Float64              # x方向的加速度
    ay::Float64              # y方向的加速度
end

# Acceleration 构造函数
function Acceleration(ax::Float64, ay::Float64)
    return Acceleration(ax, ay)
end

end # module Physics
