# 定义 Point 结构体
struct Point
    x::Float64
    y::Float64

    # 构造函数，用两个浮点数初始化点
    function Point(x::Float64, y::Float64)
        new(x, y)
    end
end

# 定义 Vec 结构体，表示二维向量
struct Vec
    x::Float64
    y::Float64

    # 构造函数，用两个浮点数初始化向量
    function Vec(x::Float64, y::Float64)
        new(x, y)
    end

    # 构造函数，用两个 Point 初始化向量
    function Vec(A::Point, B::Point)
        new(B.x - A.x, B.y - A.y)
    end
end

# 向量加法
function add(A::Vec, B::Vec)
    return Vec(A.x + B.x, A.y + B.y)
end

# 向量减法
function sub(A::Vec, B::Vec)
    return Vec(A.x - B.x, A.y - B.y)
end

# 向量点积
function dot(A::Vec, B::Vec)
    return A.x * B.x + A.y * B.y
end

# 向量模长
function norm(A::Vec)
    return sqrt(A.x^2 + A.y^2)
end

# 求向量夹角（返回弧度值）
function theta(A::Vec, B::Vec)
    return acos(dot(A, B) / (norm(A) * norm(B)))
end

# 求两个向量之间夹角的余弦值
function cos_theta(A::Vec, B::Vec)
    return dot(A, B) / (norm(A) * norm(B))
end

# 求两个向量之间夹角的正弦值
function sin_theta(A::Vec, B::Vec)
    # 使用叉积计算正弦值
    return cross(A, B) / (norm(A) * norm(B))
end

# 叉乘，返回标量
function cross(A::Vec, B::Vec)
    return A.x * B.y - A.y * B.x
end

# 施密特正交化的 Orth 结构体
struct Orth
    A::Vec
    B::Vec

    # 正交化构造函数
    function Orth(A::Vec, B::Vec)
        # 确保 A 和 B 非零向量
        if norm(A) == 0 || norm(B) == 0
            error("A 和 B 必须是非零向量")
        end

        # 归一化 A
        A_unit = Vec(A.x / norm(A), A.y / norm(A))

        # B 在 A 方向上的投影
        proj_B_on_A = Vec(dot(B, A_unit) * A_unit.x, dot(B, A_unit) * A_unit.y)

        # B' = B - proj_B_on_A，得到正交于 A 的向量
        B_orthogonal = sub(B, proj_B_on_A)

        new(A_unit, B_orthogonal)
    end
end

# 定义点到直线距离的函数
function point_line_distance(P::Point, A::Point, B::Point)
    # 计算向量 AP 和 AB
    AP = Vec(A, P)
    AB = Vec(A, B)
    
    # 计算叉积的绝对值并除以 AB 的模长
    return abs(cross(AP, AB)) / norm(AB)
end
