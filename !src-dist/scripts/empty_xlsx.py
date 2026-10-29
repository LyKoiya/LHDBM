import subprocess
import sys

# 回调代码：只处理 .xlsx，内容置空，保留路径
callback = '''
if not filename.endswith(b".xlsx"):
    return (filename, mode, blob_id)

new_blob_id = value.insert_file_with_contents(b"")
return (filename, mode, new_blob_id)
'''

cmd = [
    "git", "filter-repo",
    "--file-info-callback", callback,
    "--force",
]

print("执行:", " ".join(cmd))
result = subprocess.run(cmd, text=True)
sys.exit(result.returncode)