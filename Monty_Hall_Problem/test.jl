# 三门问题模拟代码（Monty Hall Problem）

# 定义函数来模拟游戏
function monty_hall_simulation(n_simulations::Int)
    # 初始化变量来统计胜利次数
    stay_wins = 0
    switch_wins = 0

    # 进行n次模拟
    for _ in 1:n_simulations
        # 随机选择一个门作为奖品门（1, 2, 3）
        prize_door = rand(1:3)
        
        # 玩家随机选择一个门
        player_choice = rand(1:3)
        
        # 主持人选择一个非奖品、非玩家选中门来打开
        # 过滤出可供主持人选择的门
        possible_doors = setdiff(1:3, [prize_door, player_choice])
        host_choice = rand(possible_doors)
        
        # 玩家选择是否换门
        # 若换门，则会选择除了当前选择和主持人选择之外的门
        switch_choice = setdiff(1:3, [player_choice, host_choice])[1]
        
        # 判断胜负
        # 若玩家坚持原选择，并且选择的是奖品门
        if player_choice == prize_door
            stay_wins += 1
        end
        # 若玩家换门，并且换到的是奖品门
        if switch_choice == prize_door
            switch_wins += 1
        end
    end

    # 计算并输出胜率
    stay_win_rate = stay_wins / n_simulations
    switch_win_rate = switch_wins / n_simulations

    println("在 $n_simulations 次模拟中：")
    println("坚持原选择的胜率: $(stay_win_rate * 100)%")
    println("换门的胜率: $(switch_win_rate * 100)%")
end

# 运行模拟，指定模拟次数
monty_hall_simulation(10000)
