# 定义 Point 结构体，表示二维点
struct Point
    x::Float64
    y::Float64
end

# 定义 Vector 结构体，表示二维向量
struct Vector
    x::Float64
    y::Float64
end

# 定义 Circle 结构体，表示圆
struct Circle
    center::Point
    radius::Float64
end

# 辅助函数

# 计算两个点的中点
function midpoint(p1::Point, p2::Point)::Point
    return Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)
end

# 根据两个点创建向量
function create_vector(p1::Point, p2::Point)::Vector
    return Vector(p2.x - p1.x, p2.y - p1.y)
end

# 计算两个向量的点积
function dot_product(v1::Vector, v2::Vector)::Float64
    return v1.x * v2.x + v1.y * v2.y
end

# 主函数：通过三个点计算圆
function circle_from_points(A::Point, B::Point, C::Point)::Circle
    # 计算中点 D 和 E
    D = midpoint(A, B)
    E = midpoint(A, C)

    # 生成向量 AB 和 AC
    AB = create_vector(A, B)
    AC = create_vector(A, C)

    # 构建方程的系数
    C1 = dot_product(AB, Vector(D.x, D.y))
    C2 = dot_product(AC, Vector(E.x, E.y))

    # 通过消元法解出圆心坐标 (h, k)
    h = (C1 * AC.y - C2 * AB.y) / (AB.x * AC.y - AC.x * AB.y)
    k = (C1 * AC.x - C2 * AB.x) / (AB.y * AC.x - AB.x * AC.y)
    center = Point(h, k)

    # 计算半径 r
    r = sqrt((A.x - h)^2 + (A.y - k)^2)

    # 返回 Circle 实例
    return Circle(center, r)
end

# 函数：返回圆的标准方程表示
function equation(circle::Circle)::String
    h, k, r = circle.center.x, circle.center.y, circle.radius
    return "(x - $(h))^2 + (y - $(k))^2 = $(r)^2"
end
