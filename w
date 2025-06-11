<#
.SYNOPSIS
   人生模拟器 - 终端版（带AI交互）
.DESCRIPTION
   一个在Windows终端中运行的人生模拟游戏，带有AI交互功能
.AUTHOR
   终端游戏开发者
#>

# 设置控制台窗口
$Host.UI.RawUI.WindowTitle = "人生模拟器 v2.0 (AI增强版)"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# API配置（用户提供的凭据）
$global:API_APPID = "82f64706"
$global:API_APISecret = "ODVlYjIzNjg5ZWUwZTBiMWRiNWVkOTU3"
$global:API_APIKey = "51b4b5c3c13b26f26a9eadb628be71ba"
$global:AI_Enabled = $true  # 默认启用AI

# 定义颜色
$titleColor = "Cyan"
$menuColor = "Green"
$highlightColor = "Yellow"
$infoColor = "Gray"
$aiColor = "Magenta"

# 显示开始界面
function Show-SplashScreen {
    Clear-Host
    Write-Host ""
    Write-Host "  ██╗     ██╗███╗   ██╗███████╗    ███████╗██╗███╗   ███╗██╗   ██╗██╗      █████╗ ████████╗ ██████╗ ██████╗ " -ForegroundColor $titleColor
    Write-Host "  ██║     ██║████╗  ██║██╔════╝    ██╔════╝██║████╗ ████║██║   ██║██║     ██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗" -ForegroundColor $titleColor
    Write-Host "  ██║     ██║██╔██╗ ██║█████╗      █████╗  ██║██╔████╔██║██║   ██║██║     ███████║   ██║   ██║   ██║██████╔╝" -ForegroundColor $titleColor
    Write-Host "  ██║     ██║██║╚██╗██║██╔══╝      ██╔══╝  ██║██║╚██╔╝██║██║   ██║██║     ██╔══██║   ██║   ██║   ██║██╔══██╗" -ForegroundColor $titleColor
    Write-Host "  ███████╗██║██║ ╚████║███████╗    ██║     ██║██║ ╚═╝ ██║╚██████╔╝███████╗██║  ██║   ██║   ╚██████╔╝██║  ██║" -ForegroundColor $titleColor
    Write-Host "  ╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝    ╚═╝     ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝" -ForegroundColor $titleColor
    Write-Host ""
    Write-Host "                                        终端版人生模拟体验" -ForegroundColor $infoColor
    Write-Host ""
    Write-Host "                                        版本 2.0 | AI增强版" -ForegroundColor $aiColor
    Write-Host ""
    Write-Host ""
}

# 主菜单
function Show-MainMenu {
    $menuItems = @("开始游戏", "设置", "退出游戏")
    $selectedItem = 0
    
    do {
        Show-SplashScreen
        Write-Host "`n`n" -ForegroundColor $menuColor
        
        for ($i = 0; $i -lt $menuItems.Count; $i++) {
            if ($i -eq $selectedItem) {
                Write-Host ("  > " + $menuItems[$i] + " <") -ForegroundColor $highlightColor
            } else {
                Write-Host ("    " + $menuItems[$i]) -ForegroundColor $menuColor
            }
        }
        
        Write-Host "`n使用上下箭头键选择，按Enter键确认" -ForegroundColor $infoColor
        
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
        
        switch ($key) {
            38 { # 上箭头
                $selectedItem = ($selectedItem - 1) % $menuItems.Count
                if ($selectedItem -lt 0) { $selectedItem = $menuItems.Count - 1 }
            }
            40 { # 下箭头
                $selectedItem = ($selectedItem + 1) % $menuItems.Count
            }
            13 { # 回车
                return $selectedItem
            }
        }
    } while ($true)
}

# 调用AI API
function Invoke-AIInteraction {
    param (
        [string]$prompt
    )
    
    if (-not $global:AI_Enabled) {
        return "AI功能已禁用"
    }
    
    try {
        # 构建请求头
        $headers = @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $global:API_APIKey"
        }
        
        # 构建请求体
        $body = @{
            "header" = @{
                "app_id" = $global:API_APPID
                "uid" = "12345"
            }
            "parameter" = @{
                "chat" = @{
                    "domain" = "general"
                    "temperature" = 0.5
                    "max_tokens" = 1024
                }
            }
            "payload" = @{
                "message" = @{
                    "text" = @(
                        @{
                            "role" = "user"
                            "content" = $prompt
                        }
                    )
                }
            }
        } | ConvertTo-Json -Depth 10
        
        # 调用API
        $response = Invoke-RestMethod -Uri "https://api.xf-yun.com/v1/chat" `
                                     -Method Post `
                                     -Headers $headers `
                                     -Body $body
        
        # 提取并返回AI响应
        if ($response.payload.choices.text.content) {
            return $response.payload.choices.text.content
        } else {
            return "AI没有返回有效响应"
        }
    } catch {
        Write-Host "AI调用失败: $_" -ForegroundColor "Red"
        return "AI服务暂时不可用"
    }
}

# 开始游戏
function Start-Game {
    Clear-Host
    Write-Host "`n`n欢迎来到人生模拟器！" -ForegroundColor $titleColor
    Write-Host "`n在这个游戏中，你将体验从出生到老去的完整人生。" -ForegroundColor $menuColor
    
    if ($global:AI_Enabled) {
        Write-Host "`nAI辅助功能: 已启用" -ForegroundColor $aiColor
    } else {
        Write-Host "`nAI辅助功能: 已禁用" -ForegroundColor $infoColor
    }
    
    Write-Host "`n按任意键继续..." -ForegroundColor $infoColor
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
    
    # 角色创建
    Clear-Host
    Write-Host "`n`n角色创建" -ForegroundColor $titleColor
    $name = Read-Host "`n输入你的角色名字"
    $gender = Read-Host "选择性别 (男/女)" -ForegroundColor $menuColor
    while ($gender -notin @("男","女")) {
        $gender = Read-Host "请输入有效的性别 (男/女)"
    }
    
    # 初始化角色属性
    $character = @{
        Name = $name
        Gender = $gender
        Age = 0
        Health = 100
        Intelligence = 50
        Happiness = 70
        Wealth = 30
    }
    
    # 游戏主循环
    while ($character.Age -lt 100 -and $character.Health -gt 0) {
        Clear-Host
        Write-Host "`n$($character.Name)的人生 - $($character.Age)岁" -ForegroundColor $titleColor
        Write-Host "`n健康: $($character.Health) | 智力: $($character.Intelligence)" -ForegroundColor "Green"
        Write-Host "幸福: $($character.Happiness) | 财富: $($character.Wealth)" -ForegroundColor "Green"
        
        # 年龄相关事件
        $event = Get-AgeEvent -Age $character.Age
        Write-Host "`n$event" -ForegroundColor $highlightColor
        
        # AI交互提示
        if ($global:AI_Enabled -and ($character.Age % 10 -eq 0 -or $character.Age -eq 0)) {
            $aiPrompt = "你是一个人生模拟游戏的AI助手。玩家现在$($character.Age)岁，刚经历了: $event。请给出一段简短的人生建议或评论。"
            $aiResponse = Invoke-AIInteraction -prompt $aiPrompt
            Write-Host "`nAI建议: $aiResponse" -ForegroundColor $aiColor
        }
        
        # 选择行动
        $actions = @("继续生活", "寻求AI建议", "查看状态", "退出游戏")
        $action = Show-ChoiceMenu -Title "选择你的行动" -Options $actions
        
        switch ($action) {
            1 { # 继续生活
                # 正常年龄增长
                $character.Age++
                
                # 随机属性变化
                $character.Health += Get-Random -Minimum -5 -Maximum 10
                $character.Intelligence += Get-Random -Minimum 0 -Maximum 5
                $character.Happiness += Get-Random -Minimum -10 -Maximum 15
                $character.Wealth += Get-Random -Minimum -20 -Maximum 30
                
                # 确保属性在合理范围内
                $character.Health = [Math]::Max(0, [Math]::Min(100, $character.Health))
                $character.Intelligence = [Math]::Max(0, [Math]::Min(100, $character.Intelligence))
                $character.Happiness = [Math]::Max(0, [Math]::Min(100, $character.Happiness))
                $character.Wealth = [Math]::Max(0, $character.Wealth)
            }
            2 { # 寻求AI建议
                $question = Read-Host "`n向AI提问关于你人生的问题"
                $aiResponse = Invoke-AIInteraction -prompt "在人生模拟游戏中，玩家$($character.Name)现在$($character.Age)岁，属性: 健康$($character.Health), 智力$($character.Intelligence), 幸福$($character.Happiness), 财富$($character.Wealth)。玩家问: $question"
                Write-Host "`nAI回复: $aiResponse" -ForegroundColor $aiColor
                Write-Host "`n按任意键继续..." -ForegroundColor $infoColor
                $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
            }
            3 { # 查看状态
                Show-CharacterStatus -Character $character
            }
            4 { # 退出游戏
                return
            }
        }
    }
    
    # 游戏结束
    Clear-Host
    if ($character.Health -le 0) {
        Write-Host "`n`n很遗憾，$($character.Name)因健康问题离开了人世..." -ForegroundColor "Red"
        Write-Host "享年 $($character.Age) 岁" -ForegroundColor "Red"
    } else {
        Write-Host "`n`n恭喜！$($character.Name)度过了完整的一生！" -ForegroundColor $titleColor
        Write-Host "享年 $($character.Age) 岁" -ForegroundColor $titleColor
    }
    
    # 人生总结
    if ($global:AI_Enabled) {
        $aiPrompt = "为一个刚刚结束的人生模拟游戏角色写一段简短的总结。角色名叫$($character.Name)，$($character.Gender)性，活了$($character.Age)岁，最终属性: 健康$($character.Health), 智力$($character.Intelligence), 幸福$($character.Happiness), 财富$($character.Wealth)。"
        $aiSummary = Invoke-AIInteraction -prompt $aiPrompt
        Write-Host "`n人生总结: $aiSummary" -ForegroundColor $aiColor
    }
    
    Write-Host "`n按任意键返回主菜单..." -ForegroundColor $infoColor
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}

# 根据年龄获取事件
function Get-AgeEvent {
    param ($Age)
    
    $events = @{
        0 = "你出生了！一个全新的生命来到这个世界。"
        1 = "你学会了走路和说简单的话。"
        5 = "你开始上幼儿园，认识了新朋友。"
        6 = "你上了小学，开始了正式的学习生涯。"
        12 = "你升入初中，青春期开始了。"
        15 = "你进入高中，学习压力变大了。"
        18 = "你高中毕业，即将步入大学或社会。"
        22 = "你大学毕业，开始寻找工作。"
        25 = "你在职场上取得了一些成就。"
        30 = "你开始思考人生的意义和方向。"
        35 = "你在事业上更加稳定，可能组建了家庭。"
        40 = "中年危机？你开始反思自己的人生选择。"
        50 = "你的事业达到巅峰，但也开始考虑退休计划。"
        60 = "你退休了，开始享受晚年生活。"
        70 = "你有了更多时间陪伴家人和追求兴趣爱好。"
        80 = "你回顾自己漫长而丰富的一生。"
        90 = "你成为家族中的长者，受到尊敬。"
        100 = "你庆祝了自己的百岁生日！"
    }
    
    if ($events.ContainsKey($Age)) {
        return $events[$Age]
    } elseif ($Age -lt 5) {
        return "你在快乐地成长，学习新事物。"
    } elseif ($Age -lt 12) {
        return "你在小学里学习和玩耍。"
    } elseif ($Age -lt 18) {
        return "你在中学里努力学习。"
    } elseif ($Age -lt 25) {
        return "你在大学或工作中积累经验。"
    } elseif ($Age -lt 40) {
        return "你在事业和家庭中寻找平衡。"
    } elseif ($Age -lt 60) {
        return "你在事业上稳步前进，同时规划未来。"
    } else {
        return "你享受着退休生活的宁静。"
    }
}

# 显示选择菜单
function Show-ChoiceMenu {
    param (
        [string]$Title,
        [array]$Options
    )
    
    $selected = 0
    do {
        Clear-Host
        Write-Host "`n$Title" -ForegroundColor $titleColor
        Write-Host "`n"
        
        for ($i = 0; $i -lt $Options.Count; $i++) {
            if ($i -eq $selected) {
                Write-Host ("  > " + $Options[$i] + " <") -ForegroundColor $highlightColor
            } else {
                Write-Host ("    " + $Options[$i]) -ForegroundColor $menuColor
            }
        }
        
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
        
        switch ($key) {
            38 { # 上箭头
                $selected = ($selected - 1) % $Options.Count
                if ($selected -lt 0) { $selected = $Options.Count - 1 }
            }
            40 { # 下箭头
                $selected = ($selected + 1) % $Options.Count
            }
            13 { # 回车
                return $selected
            }
        }
    } while ($true)
}

# 显示角色状态
function Show-CharacterStatus {
    param ($Character)
    
    Clear-Host
    Write-Host "`n角色状态" -ForegroundColor $titleColor
    Write-Host "`n名字: $($Character.Name)" -ForegroundColor $menuColor
    Write-Host "性别: $($Character.Gender)" -ForegroundColor $menuColor
    Write-Host "年龄: $($Character.Age)岁" -ForegroundColor $menuColor
    Write-Host "`n属性:" -ForegroundColor $titleColor
    Write-Host "健康: $(Get-ProgressBar $Character.Health)" -ForegroundColor "Red"
    Write-Host "智力: $(Get-ProgressBar $Character.Intelligence)" -ForegroundColor "Blue"
    Write-Host "幸福: $(Get-ProgressBar $Character.Happiness)" -ForegroundColor "Yellow"
    Write-Host "财富: $($Character.Wealth) $" -ForegroundColor "Green"
    
    Write-Host "`n按任意键继续..." -ForegroundColor $infoColor
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}

# 获取进度条
function Get-ProgressBar {
    param ($Value)
    
    $filled = [Math]::Floor($Value / 10)
    $empty = 10 - $filled
    return ("[" + ("#" * $filled) + ("-" * $empty) + "] $Value%")
}

# 设置菜单
function Show-Settings {
    $selected = 0
    $aiStatus = @("禁用", "启用")[$global:AI_Enabled -as [int]]
    
    do {
        Clear-Host
        Write-Host "`n设置" -ForegroundColor $titleColor
        Write-Host "`n1. AI辅助: $aiStatus" -ForegroundColor $menuColor
        Write-Host "2. 重置API密钥" -ForegroundColor $menuColor
        Write-Host "3. 返回主菜单" -ForegroundColor $menuColor
        
        if ($selected -eq 0) {
            Write-Host "`n> 切换AI辅助功能状态 <" -ForegroundColor $highlightColor
        } elseif ($selected -eq 1) {
            Write-Host "`n> 输入新的API密钥 <" -ForegroundColor $highlightColor
        } else {
            Write-Host "`n> 返回主菜单 <" -ForegroundColor $highlightColor
        }
        
        Write-Host "`n使用上下箭头键选择，按Enter键确认" -ForegroundColor $infoColor
        
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
        
        switch ($key) {
            38 { # 上箭头
                $selected = ($selected - 1) % 3
                if ($selected -lt 0) { $selected = 2 }
            }
            40 { # 下箭头
                $selected = ($selected + 1) % 3
            }
            13 { # 回车
                switch ($selected) {
                    0 { 
                        $global:AI_Enabled = -not $global:AI_Enabled
                        $aiStatus = @("禁用", "启用")[$global:AI_Enabled -as [int]]
                        Write-Host "`nAI辅助已$aiStatus" -ForegroundColor $highlightColor
                        Start-Sleep -Seconds 1
                    }
                    1 {
                        Clear-Host
                        Write-Host "`nAPI设置" -ForegroundColor $titleColor
                        $global:API_APPID = Read-Host "`n输入APPID (当前: $global:API_APPID)"
                        $global:API_APISecret = Read-Host "输入APISecret (当前: 隐藏)"
                        $global:API_APIKey = Read-Host "输入APIKey (当前: 隐藏)"
                        Write-Host "`nAPI设置已更新！" -ForegroundColor $highlightColor
                        Start-Sleep -Seconds 1
                    }
                    2 { return }
                }
            }
        }
    } while ($true)
}

# 主程序循环
do {
    $choice = Show-MainMenu
    
    switch ($choice) {
        0 { Start-Game }
        1 { Show-Settings }
        2 { 
            Clear-Host
            Write-Host "`n`n感谢游玩人生模拟器！" -ForegroundColor $titleColor
            Write-Host "再见！" -ForegroundColor $menuColor
            Start-Sleep -Seconds 2
            exit 
        }
    }
} while ($true)
