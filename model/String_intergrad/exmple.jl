# 定义结构体 Round
struct Round
    O::Tuple{Float64, Float64}  # 圆心坐标，O = (x, y)
    radius::Float64             # 半径
end

# 定义函数 f，将圆的方程转换为字符串并打印
function f(R::Round)
    x, y = R.O  # 提取圆心的 x 和 y 坐标
    r = R.radius  # 半径

    # 使用字符串插值构造方程字符串
    equation = "((X - $x)^2 + (Y - $y)^2 = $r^2)"
    return equation
end

# 示例调用
R = Round((1.0, 2.0), 3.0)
println(f(R))  # 输出: ((X - 1.0)^2 + (Y - 2.0)^2 = 9.0)
