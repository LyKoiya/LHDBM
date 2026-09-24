#!/usr/bin/env python3
"""
Git pre-commit hook: 批量格式化 .jx3dat 文件
"""
import sys
import subprocess
from pathlib import Path
import build

def run_git(*args):
    """执行 git 命令，自动处理编码"""
    result = subprocess.run(
        ['git'] + list(args),
        capture_output=True,
        text=True,
        encoding='utf-8',      # Git 内部就是 UTF-8
        errors='surrogateescape'  # 保留无法解码的字节，而不是崩溃
    )
    return result

# 获取暂存区的文件并过滤
def getdiffFile(szEndSwith):
    result = run_git('diff', '--cached', '--name-only', '--diff-filter=ACM')

    # 过滤文件
    files = []
    for line in result.stdout.splitlines():
        line = line.strip()
        if Path(line).exists():
            if line.lower().endswith(szEndSwith):
                files.append(line)
    return files

def main() -> None:
    # 获取 Git 根目录
    result = run_git('rev-parse', '--show-toplevel')
    git_root = result.stdout.strip()

    script = Path(git_root) / '!src-dist/scripts/ordering.lua'

    # 检查 Lua 是否可用
    try:
        subprocess.run(['where', 'lua'], capture_output=True, check=True)
    except subprocess.CalledProcessError:
        print('[警告] 找不到 lua.exe')
        sys.exit(0)

    # 检查脚本是否存在
    if not script.exists():
        print(f'[警告] 格式化脚本缺失：{script}')
        sys.exit(0)

    xlsxfiles = getdiffFile(".xlsx")
    if not xlsxfiles:
        print('没有需要处理的 .xlsx 文件')

    # 批量处理
    print('开始数据有序格式化规整')
    backSave = []
    print(f'收集到 {len(xlsxfiles)} 个.xlsx文件:')
    for f in xlsxfiles:
        print(f'  - {f}')
        dst = Path(f"xlsxdiff/{f}")
        dst = dst.with_suffix(".jx3dat")
        dst.parent.mkdir(parents=True, exist_ok=True)
        build.xlsx2jx3dat(f, str(Path(dst).resolve()))
        backSave.append(dst)

    run_git('add', *backSave)
    jx3datfiles = getdiffFile(".jx3dat")
    try:
        subprocess.run(
            ['lua', str(script)] + jx3datfiles,
            check=True,
            encoding='utf-8',
            errors='surrogateescape',
            cwd=git_root,
            env={
                'LUA_PATH': f"{git_root}/?.lua;"
            }  # 设置模块路径
        )
        
        run_git('add', *jx3datfiles)
        
        print('[成功] 已处理并暂存所有 .jx3dat 文件')
        
    except subprocess.CalledProcessError:
        print('[失败] 处理出错')
        sys.exit(1)
    finally:
        print('结束数据有序格式化规整')

if __name__ == "__main__":
    main()