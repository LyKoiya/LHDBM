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

# 取该文件上一次被修改的提交里的内容；不存在返回 None
def get_old_content(file_path):
    r = run_git('show', f'HEAD:{file_path}')
    if r.returncode != 0:
        return None
    return r.stdout

def main() -> None:
    # 获取 Git 根目录
    result = run_git('rev-parse', '--show-toplevel')
    git_root = result.stdout.strip()

    script = Path(git_root) / '!src-dist/scripts/ordering.lua'

    # 检查脚本是否存在
    if not script.exists():
        print(f'[警告] 格式化脚本缺失：{script}')
        sys.exit(0)
    Lua = build.InitLua(script)
    xlsxfiles = getdiffFile(".xlsx")

    # 批量处理
    print('开始数据有序格式化规整')
    backSave = []
    print(f'收集到 {len(xlsxfiles)} 个.xlsx文件:')
    for f in xlsxfiles:
        print(f'  - {f}')
        dst = Path(f"xlsxdiff/{f}")
        dst = dst.with_suffix(".formatted.jx3dat")
        dst.parent.mkdir(parents=True, exist_ok=True)
        szPath = build.xlsx2jx3dat(f, str(Path(dst).resolve()))
        if szPath != str(dst):
            backSave.append(szPath)
        backSave.append(dst)
    run_git('add', *backSave)
    backSave.clear()
    
    jx3datfiles = getdiffFile(".formatted.jx3dat")
    print(f'收集到 {len(jx3datfiles)} 个.formatted.jx3dat文件')
    try:
        if Lua:
            for file_path in jx3datfiles:
                print(f'  - {file_path}')
                old_content = get_old_content(file_path)
                tmp_file_path = f"{file_path}.temp"
                Path(tmp_file_path).parent.mkdir(parents=True, exist_ok=True)
                with open(tmp_file_path, "wb") as fTmp:
                    fTmp.write(old_content.encode("utf-8", errors="surrogateescape"))
                # 调用 Lua 脚本处理差异
                dst = Path(f"datadiff/{file_path}")
                dst = dst.with_suffix("").with_suffix(".diff.jx3dat")
                dst.parent.mkdir(parents=True, exist_ok=True)
                Lua.xpcall("processFilediff", file_path, tmp_file_path, str(dst))
                backSave.append(file_path)
                backSave.append(dst)
                Path(tmp_file_path).unlink(missing_ok=True)

        
        run_git('add', *backSave)
            
        print('[成功] 已处理并暂存所有 .jx3dat 文件')
        
    except subprocess.CalledProcessError:
        print('[失败] 处理出错')
        sys.exit(1)
    finally:
        print('结束数据有序格式化规整')

if __name__ == "__main__":
    main()