module Physics

using QuadGK  # 导入用于积分计算的库

export Motion, Velocity, Position, Acceleration, update_position, update_velocity, update_acceleration, kinetic_energy

# 定义运动的主要属性，包括质量
struct Motion
    speed::Float64          # 速度
    displacement::Float64    # 位移
    acceleration::Float64    # 加速度
    mass::Float64            # 质量
end

# 定义速度的矢量分量
struct Velocity
    vx::Float64              # x方向的速度
    vy::Float64              # y方向的速度
end

# 定义位置
struct Position
    x::Float64               # x方向的位置
end

# 定义加速度的矢量分量
struct Acceleration
    ax::Float64              # x方向的加速度
    ay::Float64              # y方向的加速度
end

# 更新速度：通过积分加速度随时间的变化来更新速度
function update_velocity(v0::Velocity, ax_fn, ay_fn, t_start::Float64, t_end::Float64)
    # 积分加速度函数来获得速度增量
    Δvx, _ = quadgk(ax_fn, t_start, t_end)
    Δvy, _ = quadgk(ay_fn, t_start, t_end)
    # 返回新的速度
    return Velocity(v0.vx + Δvx, v0.vy + Δvy)
end

# 更新位置：通过积分速度随时间的变化来更新位置
function update_position(p0::Position, vx_fn, vy_fn, t_start::Float64, t_end::Float64)
    # 积分速度函数来获得位移增量
    Δx, _ = quadgk(vx_fn, t_start, t_end)
    return Position(p0.x + Δx)
end

# 更新加速度：根据力和质量（假设加速度是力除以质量）
function update_acceleration(motion::Motion, force_x::Float64, force_y::Float64)
    ax = force_x / motion.mass
    ay = force_y / motion.mass
    return Acceleration(ax, ay)
end

# 计算动能：0.5 * mass * speed^2
function kinetic_energy(motion::Motion)
    return 0.5 * motion.mass * motion.speed^2
end

end # module Physics
