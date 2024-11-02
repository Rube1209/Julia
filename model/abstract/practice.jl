# 定义矩形的抽象类型
abstract type Rectangle end

# 定义具体类型 Rect
struct Rect <: Rectangle
    length::Float64
    width::Float64  # 修正拼写

    # 构造函数
    function Rect(length::Float64, width::Float64)
        if length <= 0 || width <= 0
            throw(ArgumentError("Length and width must be positive numbers."))
        end
        new(length, width)
    end
end

# 计算矩形的面积
function rectangle_area(r::Rect)
    return r.length * r.width
end

# 计算矩形的周长
function rectangle_perimeter(r::Rect)
    return 2 * (r.length + r.width)
end

# 定义圆的抽象类型
abstract type Round end

# 定义具体类型 R
struct R <: Round
    center::Tuple{Float64, Float64}  # 圆心坐标 (x, y)
    radius::Float64                   # 半径

    # 构造函数
    function R(x::Float64, y::Float64, radius::Float64)
        if radius <= 0
            throw(ArgumentError("Radius must be a positive number."))
        end
        new((x, y), radius)
    end
end

# 计算圆的面积
function circle_area(c::R)
    return π * c.radius^2
end

# 计算圆的周长
function circle_circumference(c::R)
    return 2 * π * c.radius
end

# 示例
rect = Rect(5.0, 3.0)
println("Rectangle Area: ", rectangle_area(rect))          # 输出矩形面积
println("Rectangle Perimeter: ", rectangle_perimeter(rect)) # 输出矩形周长

circle = R(0.0, 0.0, 5.0)
println("Circle Area: ", circle_area(circle))              # 输出圆面积
println("Circle Circumference: ", circle_circumference(circle)) # 输出圆周长
