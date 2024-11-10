# 定义基因型及其显性/隐性关系
struct Pea
    color::String  # 黄色(A) 或 绿色(a)
    shape::String  # 圆形(B) 或 皱形(b)
end

# 创建F1代亲本（假设AaBb与AaBb交配）
parent1 = Pea("Aa", "Bb")
parent2 = Pea("Aa", "Bb")


# 基因分离并自由组合的函数
function cross(parent1::Pea, parent2::Pea, num_offspring::Int)
    offspring = Vector{Pea}()  # 明确指定 offspring 为 Vector{Pea} 类型
    # 从每个亲本中获取可能的配子（每种性状基因分别考虑）
    color_alleles1 = [parent1.color[1], parent1.color[2]]
    color_alleles2 = [parent2.color[1], parent2.color[2]]
    shape_alleles1 = [parent1.shape[1], parent1.shape[2]]
    shape_alleles2 = [parent2.shape[1], parent2.shape[2]]

    for _ in 1:num_offspring
        # 随机选择一个颜色等位基因和形状等位基因
        color_gene = rand(color_alleles1) * rand(color_alleles2)
        shape_gene = rand(shape_alleles1) * rand(shape_alleles2)
        # 创建后代个体
        push!(offspring, Pea(color_gene, shape_gene))
    end
    return offspring
end

# 模拟F2代实验
num_offspring = 100000
offspring_F2 = cross(parent1, parent2, num_offspring)

# 统计后代的性状分布
function count_traits(offspring::Vector{Pea})
    traits_count = Dict("Yellow Round" => 0, "Yellow Wrinkled" => 0, "Green Round" => 0, "Green Wrinkled" => 0)
    for pea in offspring
        color_trait = contains(pea.color, "A") ? "Yellow" : "Green"
        shape_trait = contains(pea.shape, "B") ? "Round" : "Wrinkled"
        traits_count["$color_trait $shape_trait"] += 1
    end
    return traits_count
end

# 输出F2代的性状统计结果
traits_distribution = count_traits(offspring_F2)
println("F2 generation traits distribution:")
for (trait, count) in traits_distribution
    println("$trait: $count")
end
