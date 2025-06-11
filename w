<#
.SYNOPSIS
    Steam 高级管理工具 - 黑客主题版
.DESCRIPTION
    自动管理 Steam 进程，通过 CDK 验证添加指定游戏
.NOTES
    此脚本仅为模拟效果，不会真正入侵 Steam 服务器
#>

# 强制要求管理员权限
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host " [!] 需要管理员权限执行此操作" -ForegroundColor Red
    Start-Sleep 2
    exit
}

# 清屏并设置黑客主题
function Invoke-HackerTheme {
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "Green"
    Clear-Host
    Write-Host "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓" -ForegroundColor DarkGreen
    Write-Host "█                                            █" -ForegroundColor DarkGreen
    Write-Host "█         Steam 高级控制终端 v3.1.4         █" -ForegroundColor Green
    Write-Host "█    (需授权密钥激活游戏注入功能)           █" -ForegroundColor DarkGreen
    Write-Host "█                                            █" -ForegroundColor DarkGreen
    Write-Host "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓" -ForegroundColor DarkGreen
    Write-Host ""
}
Invoke-HackerTheme

# CDK 数据库 (可扩展)
$cdkDatabase = @{
    "H4X-ST34M-2023" = @{
        GameName = "半条命3破解版"
        ExePath  = "C:\Games\HL3\hl3.exe"
    }
    "1337-V4LV3" = @{
        GameName = "Portal 3 测试版"
        ExePath  = "https://valve.com/secret/portal3.exe"
    }
    "CDK-2024-GM" = @{
        GameName = "GTA6 内部预览版"
        ExePath  = "C:\Rockstar\GTA6\launcher.exe"
    }
}

# 查找并终止 Steam 进程
Write-Host " [*] 扫描 Steam 进程..." -ForegroundColor Cyan
$steamProcess = Get-Process -Name "steam*" -ErrorAction SilentlyContinue

if ($steamProcess) {
    Write-Host " [!] 检测到运行中的 Steam 进程" -ForegroundColor Red
    $steamProcess | Stop-Process -Force
    Write-Host " [√] 已终止 Steam 进程 (PID: $($steamProcess.Id))" -ForegroundColor Green
    Start-Sleep 1
}

# 自动定位 Steam 安装路径
Write-Host "`n [*] 定位 Steam 安装目录..." -ForegroundColor Yellow
$steamPath = $(
    "${env:ProgramFiles(x86)}\Steam",
    "${env:ProgramFiles}\Steam",
    "${env:LocalAppData}\Steam",
    "C:\Steam"
) | Where-Object { Test-Path "$_\steam.exe" } | Select-Object -First 1

if (-not $steamPath) {
    Write-Host " [X] 未找到 Steam 安装目录!" -ForegroundColor Red
    exit
}

$steamExe = Join-Path $steamPath "steam.exe"
Write-Host " [√] Steam 路径: $steamExe" -ForegroundColor Green

# 查找 Steam 游戏库
Write-Host "`n [*] 分析 Steam 游戏库配置..." -ForegroundColor Magenta
$libraryFolders = Join-Path $steamPath "steamapps\libraryfolders.vdf"

if (Test-Path $libraryFolders) {
    $libraries = Get-Content $libraryFolders | 
                 Where-Object { $_ -match '"path"' } | 
                 ForEach-Object { $_.Split('"')[3].Replace('\\','\') }
    
    Write-Host " [√] 发现游戏库位置:" -ForegroundColor Green
    $libraries | ForEach-Object { Write-Host "     → $_" -ForegroundColor Cyan }
} else {
    Write-Host " [!] 未找到 libraryfolders.vdf" -ForegroundColor Yellow
}

# CDK 验证系统
function Invoke-HackerEffect {
    param([string]$cdk)
    $phrases = @(
        "正在使用密钥 [$cdk] 验证身份...",
        "正在连接至 Steam 主服务器...",
        "绕过 VAC 检测系统...",
        "注入代码到 SteamUI.dll...",
        "获取游戏数据库写入权限...",
        "正在解密 Valve 内部协议..."
    )
    
    foreach ($phrase in $phrases) {
        Write-Host " [>] $phrase" -ForegroundColor ([ConsoleColor](Get-Random -Minimum 10 -Maximum 15))
        Start-Sleep (Get-Random -Minimum 1 -Maximum 3)
    }
}

Write-Host "`n▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 安全验证 ▓▓▓▓▓▓▓▓▓▓▓▓▓▓" -ForegroundColor DarkRed
$userCDK = Read-Host " [？] 输入 CDK 密钥"

if (-not $cdkDatabase.ContainsKey($userCDK)) {
    Write-Host "`n [X] 密钥验证失败! 启动 Steam 并自毁..." -ForegroundColor Red
    Start-Process $steamExe
    Start-Sleep 2
    exit
}

# 验证通过流程
Invoke-HackerEffect -cdk $userCDK
Write-Host "`n [√] 密钥验证成功!" -ForegroundColor Green
Write-Host " [★] 解锁游戏: $($cdkDatabase[$userCDK].GameName)" -ForegroundColor Cyan
Start-Sleep 2

# 模拟添加游戏到 Steam
function Add-SteamShortcut {
    param(
        [string]$gameName,
        [string]$exePath
    )
    
    Write-Host "`n [*] 正在操作 Steam 配置文件..." -ForegroundColor Yellow
    Start-Sleep 1
    
    # 模拟查找用户配置
    $userDataPath = Join-Path $steamPath "userdata"
    $shortcutPath = Get-ChildItem $userDataPath -Recurse -Filter "shortcuts.vdf" | 
                    Select-Object -First 1 -ExpandProperty FullName
    
    if ($shortcutPath) {
        Write-Host " [√] 找到 shortcuts.vdf 位置: $shortcutPath" -ForegroundColor Green
        Write-Host " [>] 正在添加游戏: $gameName" -ForegroundColor Cyan
        Write-Host " [>] 游戏路径: $exePath" -ForegroundColor Cyan
        Start-Sleep 2
        
        # 这里应该实际修改 shortcuts.vdf 文件
        # 实际实现需要使用专门的 VDF 解析器
        
        Write-Host "`n [操作成功总结]" -ForegroundColor Green
        Write-Host " ▸ 游戏名称: $gameName" -ForegroundColor White
        Write-Host " ▸ 执行路径: $exePath" -ForegroundColor White
        Write-Host " ▸ 添加位置: 非 Steam 游戏库" -ForegroundColor White
    } else {
        Write-Host " [X] 未找到 shortcuts.vdf 文件!" -ForegroundColor Red
    }
}

# 从 CDK 数据库获取游戏信息
$gameInfo = $cdkDatabase[$userCDK]
Add-SteamShortcut -gameName $gameInfo.GameName -exePath $gameInfo.ExePath

# 启动 Steam
Write-Host "`n [*] 正在启动 Steam 客户端..." -ForegroundColor Yellow
Start-Process $steamExe

Write-Host "`n [i] 按任意键退出黑客终端..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
