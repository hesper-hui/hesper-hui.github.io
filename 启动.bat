@echo off
cd /d "%~dp0"

echo.
echo ==============================================
echo   老年认知功能评估系统
echo ==============================================
echo.

REM Check for Python first (most reliable)
where python >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] 使用 Python 启动本地服务器...
    echo.
    echo 浏览器将自动打开 http://localhost:8080
    echo 关闭此窗口即可停止服务
    echo.
    start http://localhost:8080
    python -m http.server 8080
    goto :end
)

REM Try Python3
where python3 >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] 使用 Python3 启动本地服务器...
    start http://localhost:8080
    python3 -m http.server 8080
    goto :end
)

REM Fallback to PowerShell TCP server (no admin required)
echo Python 未安装，尝试 PowerShell...
powershell -ExecutionPolicy Bypass -File "%~dp0serve.ps1"
if %errorlevel% neq 0 (
    echo.
    echo ==============================================
    echo   自动启动失败，请手动操作：
    echo   1. 安装 Python: https://python.org
    echo   2. 解压后在此文件夹运行: python -m http.server 8080
    echo   3. 浏览器打开: http://localhost:8080
    echo ==============================================
)

:end
pause
