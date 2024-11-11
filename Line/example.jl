# 定义抽象类型 AbstractLine，包含方程名称和参数字段
abstract type AbstractLine end

# 一般式直线 Ax + By + C = 0
struct GeneralFormLine <: AbstractLine
    equation_name::String
    params::Tuple{Float64, Float64, Float64}
    A::Float64
    B::Float64
    C::Float64

    function GeneralFormLine(A::Float64, B::Float64, C::Float64)
        new("General Form", (A, B, C), A, B, C)
    end
end

# 点斜式直线 y - y1 = m(x - x1)
struct PointSlopeFormLine <: AbstractLine
    equation_name::String
    params::Tuple{Float64, Float64, Float64}
    x1::Float64
    y1::Float64
    m::Float64

    function PointSlopeFormLine(x1::Float64, y1::Float64, m::Float64)
        new("Point-Slope Form", (x1, y1, m), x1, y1, m)
    end
end

# 斜截式直线 y = mx + b
struct SlopeInterceptFormLine <: AbstractLine
    equation_name::String
    params::Tuple{Float64, Float64}
    m::Float64
    b::Float64

    function SlopeInterceptFormLine(m::Float64, b::Float64)
        new("Slope-Intercept Form", (m, b), m, b)
    end
end

# 获取方程名称的通用方法
function get_equation_name(line::AbstractLine)
    return line.equation_name
end

# 获取参数的通用方法
function get_params(line::AbstractLine)
    return line.params
end

# 计算斜率的通用方法（对每种直线格式分别实现）
function slope(line::GeneralFormLine)
    return -line.A / line.B
end

function slope(line::PointSlopeFormLine)
    return line.m
end

function slope(line::SlopeInterceptFormLine)
    return line.m
end

# 将点斜式直线转换为一般式
function to_general_form(line::PointSlopeFormLine)
    A = -line.m
    B = 1.0
    C = line.m * line.x1 - line.y1
    return GeneralFormLine(A, B, C)
end

# 将斜截式直线转换为一般式
function to_general_form(line::SlopeInterceptFormLine)
    A = -line.m
    B = 1.0
    C = -line.b
    return GeneralFormLine(A, B, C)
end

# 使用示例
# 一般式直线
line1 = GeneralFormLine(1.0, -2.0, 3.0)
println("Equation name of line1: ", get_equation_name(line1))
println("Parameters of line1: ", get_params(line1))
println("Slope of line1: ", slope(line1))

# 点斜式直线
line2 = PointSlopeFormLine(1.0, 2.0, 0.5)
println("Equation name of line2: ", get_equation_name(line2))
println("Parameters of line2: ", get_params(line2))
println("Slope of line2: ", slope(line2))
println("General form of line2: ", get_params(to_general_form(line2)))

# 斜截式直线
line3 = SlopeInterceptFormLine(0.5, 1.0)
println("Equation name of line3: ", get_equation_name(line3))
println("Parameters of line3: ", get_params(line3))
println("Slope of line3: ", slope(line3))
println("General form of line3: ", get_params(to_general_form(line3)))
