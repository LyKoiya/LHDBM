
import os
import importlib.util
import pLualib
from python_calamine import CalamineWorkbook

Lua = None
ALLOWED_EXTENSIONS = {'.jx3dat', '.xlsx'}
aType = ['有利气劲', '不利气劲', '武学招式', '系统角色', '交互物件', '角色喊话', '系统频道']

# 加载模块
def loadModule(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod

# 加载Lua
def InitLua():
    # 检查文件是否存在
    lua_script = os.path.abspath("!src-dist\\scripts\\PackDBM.lua")
    if not os.path.exists(lua_script):
        print(f"lua_script not found: {lua_script}")
        return
    try:
        # 创建 Lua 状态机
        Lua = pLualib.LuaState()
        if Lua:
            print("lua newstate success.")
        else:
            print("lua newstate fail.")

        if Lua.dofile(lua_script):
            print(f"dofile success {lua_script}.")
        else:
            print(f"dofile fail {Lua.tostring(-1)}.")
            Lua.pop(1)
    except Exception as e:
        print(f"error: {e}")
    finally:
        return Lua

# 遍历文件
def get_filtered_files(pick_list, extensions=None):
    dict_files = {}
    
    for item in pick_list:
        relative_path = item['Path'].lstrip("\\")
        absolute_path = os.path.abspath(relative_path)
        # 文件直接存字典
        if os.path.isfile(absolute_path):
            # 检查文件后缀
            if extensions is None or any(absolute_path.endswith(ext) for ext in extensions):
                dict_files[absolute_path] = {
                    "Checked": item['Checked'],
                    "Method": item['Method']
                }
        # 目录遍历所有文件
        elif os.path.isdir(absolute_path):
            # 遍历目录
            for root, dirs, files in os.walk(absolute_path):
                for file in files:
                    file_path = os.path.join(root, file)
                    if extensions is None or any(file_path.endswith(ext) for ext in extensions):
                        # 只添加不存在的文件路径，可以把不想打包的文件先设置Checked=false，防止错误打包
                        dict_files.setdefault(file_path, {
                            "Checked": item['Checked'],
                            "Method": item['Method']
                        })

    return dict_files

# 提取团队气劲数据
def teamBuff(L, Ranges):
        i = 0
        for row in Ranges:
            i += 1
            result = "\t".join(str(item).replace("\t", "") for item in row)
            L.getglobal("decodeBuff")
            L.pushlstringA(result)
            if L.pcall(1, 0, 0) != 0:
                print(f"Error calling decodeBuff({i}): {L.tostring(-1)}({result})")
                Lua.pop(1)

# 提取表格文件数据，返回数组列表，一个元素是一种数据（气劲、角色、物件、喊话）
def xlsx2list(wb):
    retList = []
    for szType in aType:
        if szType in wb.sheet_names:
            try:
                sheet = wb.get_sheet_by_name(szType)
                Ranges = sheet.to_python(skip_empty_area=False)
                if len(Ranges) > 3:  # 大于三行有数据，小于三行无效数据
                    Row = Ranges[0]   # 第一行，list，每个元素是单元格值
                    # 遍历第一行每个单元格
                    for idx, cell in enumerate(Row):
                        if cell.startswith("return"):
                            data = []
                            for row in Ranges:
                                data.append(row[idx])
                            retList.append(''.join(data))
            except Exception as e:
                print(f"Error occurred while processing sheet: {szType} {e}")
    return retList

# 打包表格文件，有两种表格数据，分别处理，一种是团队气劲面板，一种是团队监控数据
def packxlsx(L, szPath, szMethod):
    if szPath.lower().endswith(('.xls', '.xlsx')):
        # 打开文件
        Workbook = CalamineWorkbook.from_path(szPath)
        sheet = Workbook.get_sheet_by_index(0)   # 通过下标，0为第一个sheet
        try:
            
            if sheet.name == "茗伊团队气劲":
                if szMethod == "fileMerge":
                    Ranges = sheet.to_python(skip_empty_area=False)
                    teamBuff(L, Ranges)
            else:
                listStr = xlsx2list(Workbook)
                for str in listStr:
                    if szMethod == "fileMerge":
                        L.getglobal("strMerge")
                        L.pushlstringA(str)
                        if L.pcall(1, 0, 0) != 0:
                            print(f"Error calling strMerge: {L.tostring(-1)}")
                            Lua.pop(1)
        finally:
            Workbook.close()

# 打包jx3dat文件
def packjx3dat(L, szPath, szMethod):
    if szMethod == "fileMerge":
        with open(szPath, 'rb') as f:
            data = f.read()
        if data:
            L.getglobal("strMerge")
            L.pushlstringA(data)
            if L.pcall(1, 0, 0) != 0:
                print(f"Error calling {szMethod}: {L.tostring(-1)}")
                L.pop(1)

# 打包模块总控
def runPack(filesPath):
    
    try:
        L = InitLua()
        i = 0
        for file_path, file_info in filesPath.items():
            i += 1
            print(f"[{i}/{len(filesPath)}] Checked={file_info['Checked']} {file_info['Method']}: {file_path}")
            # 只处理选中的且方法为fileMerge的文件
            if file_info['Checked']:
                if file_path.lower().endswith(('.xls', '.xlsx')):
                    packxlsx(L, file_path, file_info['Method'])
                elif file_path.lower().endswith(('.jx3dat')):
                    packjx3dat(L, file_path, file_info['Method'])
            else:
                continue
    except Exception as e:
        print(f"error: {e}")
    finally:
        L.getglobal("fileSave")
        L.pushlstringA(os.path.abspath("output\\mergeDBM.jx3dat"))
        L.pushinteger(3)
        L.pushboolean(True)
        L.pushboolean(True)
        if L.pcall(4, 0, 0) == 0:
            print("fileSave success.")
        else:
            print(f"fileSave fail.{L.tostring(-1)}")
            Lua.pop(1)
        L.close()

def xlsx2jx3dat(szDataPath, szSavePath):
    global Lua
    try:
        if not Lua:
            Lua = InitLua()
        Lua.getglobal("fileClear")
        Lua.pcall(0, 0, 0)
        packxlsx(Lua, szDataPath, "fileMerge")

    finally:
        Lua.getglobal("fileSave")
        Lua.pushlstringA(szSavePath)
        Lua.pushnil()
        Lua.pushboolean(False)
        Lua.pushboolean(False)
        if Lua.pcall(4, 0, 0) == 0:
            print("xlsxfileSave success.")
            Lua.getglobal("fileClear")
            Lua.pcall(0, 0, 0)
        else:
            print(f"xlsxfileSave fail.{Lua.tostring(-1)}")
            Lua.pop(1)

        #Lua.close()
        return

def main() -> None:
    """主入口：执行打包任务。"""
    # 只处理 .xlsx 和 .jx3dat 文件
    packConfig = loadModule("!src-dist\\data\\packConfig.py", "packConfig")
    files = get_filtered_files(packConfig.packList, ALLOWED_EXTENSIONS)
    print(f"find {len(files)} files to process.")
    runPack(files)

if __name__ == "__main__":
    main()
