@ECHO OFF

:: ========== 1、获取脚本所在目录==========
for /f "delims=" %%i in ('git rev-parse --show-toplevel') do set "ROOT=%%i"
set "SORT_SCRIPT=%ROOT%/!src-dist/scripts/ordering.lua"
:: 检查lua是否可用
where lua >nul 2>&1
if errorlevel 1 (
    echo [警告] 环境变量找不到 lua.exe
    exit /b 0
)

if not exist "%SORT_SCRIPT%" (
    echo [警告] 格式化脚本缺失：%SORT_SCRIPT%
    exit /b 0
)

:: ========== 2、遍历暂存区文件 ==========

for /f "usebackq delims=" %%f in (`git diff --cached --name-only --diff-filter^=ACM ^| findstr /i "jx3dat"`) do (
    if exist "%%f" (
        echo 正在规整数据表: %%f
        lua "%SORT_SCRIPT%" "%%f"
        if not errorlevel 1 (
            git add "%%f"
            echo [完成]
        ) else (
            echo [失败]
        )
    )
)

echo 数据表有序格式化完成

exit /b 0