# 定义抽象类型 Shape
abstract type Shape end

# 定义 area 和 perimeter 函数的占位符
function area(s::Shape)
    throw(MethodError(area, (s,)))
end

function perimeter(s::Shape)
    throw(MethodError(perimeter, (s,)))
end

# 定义矩形类型 Rectangle
struct Rectangle <: Shape
    length::Float64
    width::Float64

    function Rectangle(length::Float64, width::Float64)
        if length <= 0 || width <= 0
            throw(ArgumentError("Length and width must be positive numbers."))
        end
        new(length, width)
    end
end

# 实现矩形的 area 和 perimeter 函数
function area(r::Rectangle)
    return r.length * r.width
end

function perimeter(r::Rectangle)
    return 2 * (r.length + r.width)
end

# 定义圆形类型 Round
struct Round <: Shape
    radius::Float64

    function Round(radius::Float64)
        if radius <= 0
            throw(ArgumentError("Radius must be a positive number."))
        end
        new(radius)
    end
end

# 实现圆形的 area 和 perimeter 函数
function area(c::Round)
    return π * c.radius^2
end

function perimeter(c::Round)
    return 2 * π * c.radius
end


# 创建一个矩形实例
rect = Rectangle(5.0, 3.0)
println("Rectangle Area: ", area(rect))          # 输出矩形面积
println("Rectangle Perimeter: ", perimeter(rect)) # 输出矩形周长

# 创建一个圆形实例
circle = Round(4.0)
println("Circle Area: ", area(circle))              # 输出圆面积
println("Circle Circumference: ", perimeter(circle)) # 输出圆周长
