#!/usr/bin/env python3
"""
Git pre-commit hook: 批量格式化 .jx3dat 文件
"""

import subprocess
import sys
from pathlib import Path

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

# 获取暂存区的 .jx3dat 文件
result = run_git('diff', '--cached', '--name-only', '--diff-filter=ACM')

# 过滤文件
files = []
for line in result.stdout.splitlines():
    line = line.strip()
    if line.lower().endswith('.jx3dat') and Path(line).exists():
        files.append(line)

if not files:
    print('没有需要处理的 .jx3dat 文件')
    sys.exit(0)

# 批量处理
print('开始数据有序格式化规整')
print(f'收集到 {len(files)} 个文件:')
for f in files:
    print(f'  - {f}')

try:
    subprocess.run(
        ['lua', str(script)] + files,
        check=True,
        encoding='utf-8',
        errors='surrogateescape',
        cwd=git_root,
        env={
            'LUA_PATH': f"{git_root}/?.lua;"
        }  # 设置模块路径
    )
    
    run_git('add', *files)
    
    print('[成功] 已处理并暂存所有 .jx3dat 文件')
    
except subprocess.CalledProcessError:
    print('[失败] 处理出错')
    sys.exit(1)

print('结束数据有序格式化规整')