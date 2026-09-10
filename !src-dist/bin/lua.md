# Lua 5.1 DLL 导出函数参考手册

## 概述
- **文件**: `luaDLL.dll`
- **Lua 版本**: 5.1
- **导出函数总数**: 123
- **序号基值**: 1

---

## 辅助库函数 (luaL_*)

| 序号 | 函数名 | 说明 |
|------|--------|------|
| 1 | `luaL_addlstring` | 向缓冲区添加长度指定的字符串 |
| 2 | `luaL_addstring` | 向缓冲区添加字符串 |
| 3 | `luaL_addvalue` | 将栈顶值添加到缓冲区 |
| 4 | `luaL_argerror` | 报告参数错误 |
| 5 | `luaL_buffinit` | 初始化缓冲区 |
| 6 | `luaL_callmeta` | 调用元方法 |
| 7 | `luaL_checkany` | 检查任意类型参数 |
| 8 | `luaL_checkinteger` | 检查整数参数 |
| 9 | `luaL_checklstring` | 检查字符串参数 |
| 10 | `luaL_checknumber` | 检查数字参数 |
| 11 | `luaL_checkoption` | 检查选项参数 |
| 12 | `luaL_checkstack` | 检查栈空间 |
| 13 | `luaL_checktype` | 检查参数类型 |
| 14 | `luaL_checkudata` | 检查用户数据 |
| 15 | `luaL_error` | 抛出错误 |
| 16 | `luaL_findtable` | 查找或创建表 |
| 17 | `luaL_getmetafield` | 获取元表字段 |
| 18 | `luaL_gsub` | 全局替换子串 |
| 19 | `luaL_loadbuffer` | 加载缓冲区中的代码 |
| 20 | `luaL_loadfile` | 加载文件 |
| 21 | `luaL_loadstring` | 加载字符串代码 |
| 22 | `luaL_newmetatable` | 创建元表 |
| 23 | `luaL_newstate` | 创建新 Lua 状态 |
| 24 | `luaL_openlib` | 打开库 |
| 25 | `luaL_openlibs` | 打开所有标准库 |
| 26 | `luaL_optinteger` | 可选整数参数 |
| 27 | `luaL_optlstring` | 可选字符串参数 |
| 28 | `luaL_optnumber` | 可选数字参数 |
| 29 | `luaL_prepbuffer` | 准备缓冲区 |
| 30 | `luaL_pushresult` | 推送缓冲区结果 |
| 31 | `luaL_ref` | 创建引用 |
| 32 | `luaL_register` | 注册库函数 |
| 33 | `luaL_typerror` | 类型错误 |
| 34 | `luaL_unref` | 释放引用 |
| 35 | `luaL_where` | 获取调用位置 |

---

## 基础 API 函数 (lua_*)

### 状态管理

| 序号 | 函数名 | 说明 |
|------|--------|------|
| 36 | `lua_atpanic` | 设置恐慌函数 |
| 39 | `lua_close` | 关闭 Lua 状态 |
| 42 | `lua_newstate` | 创建新状态（自定义分配器） |
| 67 | `lua_newthread` | 创建新线程 |
| 103 | `lua_status` | 获取线程状态 |

### 栈操作

| 序号 | 函数名 | 说明 |
|------|--------|------|
| 38 | `lua_checkstack` | 检查栈空间 |
| 58 | `lua_gettop` | 获取栈顶索引 |
| 60 | `lua_insert` | 插入值到指定位置 |
| 90 | `lua_remove` | 移除指定位置值 |
| 91 | `lua_replace` | 替换指定位置值 |
| 101 | `lua_settop` | 设置栈顶 |

### 压栈操作

| 序号 | 函数名 | 说明 |
|------|--------|------|
| 73 | `lua_pushboolean` | 压入布尔值 |
| 74 | `lua_pushcclosure` | 压入 C 闭包 |
| 75 | `lua_pushfstring` | 压入格式化字符串 |
| 76 | `lua_pushinteger` | 压入整数 |
| 77 | `lua_pushlightuserdata` | 压入轻量级用户数据 |
| 78 | `lua_pushlstring` | 压入长度指定字符串 |
| 79 | `lua_pushnil` | 压入 nil |
| 80 | `lua_pushnumber` | 压入数字 |
| 81 | `lua_pushstring` | 压入字符串 |
| 82 | `lua_pushthread` | 压入线程 |
| 83 | `lua_pushvalue` | 压入值副本 |
| 84 | `lua_pushvfstring` | 压入格式化字符串（va_list） |

### 取值操作

| 序号 | 函数名 | 说明 |
|------|--------|------|
| 104 | `lua_toboolean` | 转布尔值 |
| 105 | `lua_tocfunction` | 转 C 函数 |
| 106 | `lua_tointeger` | 转整数 |
| 107 | `lua_tolstring` | 转字符串 |
| 108 | `lua_tonumber` | 转数字 |
| 109 | `lua_topointer` | 转指针 |
| 110 | `lua_tothread` | 转线程 |
| 111 | `lua_touserdata` | 转用户数据 |
| 112 | `lua_type` | 获取类型 |
| 113 | `lua_typename` | 获取类型名 |

### 表操作

| 序号 | 函数名 | 说明 |
|------|--------|------|
| 42 | `lua_createtable` | 创建表 |
| 49 | `lua_getfield` | 获取表字段 |
| 55 | `lua_getmetatable` | 获取元表 |
| 57 | `lua_gettable` | 获取表值 |
| 85 | `lua_rawequal` | 原始相等比较 |
| 86 | `lua_rawget` | 原始获取 |
| 87 | `lua_rawgeti` | 原始获取（整数索引） |
| 88 | `lua_rawset` | 原始设置 |
| 89 | `lua_rawseti` | 原始设置（整数索引） |
| 95 | `lua_setfield` | 设置表字段 |
| 99 | `lua_setmetatable` | 设置元表 |
| 100 | `lua_settable` | 设置表值 |

### 函数调用

| 序号 | 函数名 | 说明 |
|------|--------|------|
| 37 | `lua_call` | 调用函数 |
| 41 | `lua_cpcall` | 保护调用 C 函数 |
| 72 | `lua_pcall` | 保护调用 |

### 环境与上值

| 序号 | 函数名 | 说明 |
|------|--------|------|
| 48 | `lua_getfenv` | 获取环境表 |
| 59 | `lua_getupvalue` | 获取上值 |
| 94 | `lua_setfenv` | 设置环境表 |
| 102 | `lua_setupvalue` | 设置上值 |

### GC 与内存

| 序号 | 函数名 | 说明 |
|------|--------|------|
| 46 | `lua_gc` | 垃圾回收控制 |
| 47 | `lua_getallocf` | 获取分配函数 |
| 93 | `lua_setallocf` | 设置分配函数 |

### 调试与钩子

| 序号 | 函数名 | 说明 |
|------|--------|------|
| 50 | `lua_gethook` | 获取钩子 |
| 51 | `lua_gethookcount` | 获取钩子计数 |
| 52 | `lua_gethookmask` | 获取钩子掩码 |
| 53 | `lua_getinfo` | 获取调试信息 |
| 54 | `lua_getlocal` | 获取局部变量 |
| 56 | `lua_getstack` | 获取调用栈 |
| 96 | `lua_sethook` | 设置钩子 |
| 98 | `lua_setlocal` | 设置局部变量 |

### 协程

| 序号 | 函数名 | 说明 |
|------|--------|------|
| 92 | `lua_resume` | 恢复协程 |
| 115 | `lua_yield` | 挂起协程 |

### 其他基础函数

| 序号 | 函数名 | 说明 |
|------|--------|------|
| 40 | `lua_concat` | 连接栈上字符串 |
| 43 | `lua_dump` | 转储函数为二进制 |
| 44 | `lua_equal` | 比较相等 |
| 45 | `lua_error` | 抛出错误 |
| 61 | `lua_iscfunction` | 是否为 C 函数 |
| 62 | `lua_isnumber` | 是否为数字 |
| 63 | `lua_isstring` | 是否为字符串 |
| 64 | `lua_isuserdata` | 是否为用户数据 |
| 65 | `lua_lessthan` | 小于比较 |
| 66 | `lua_load` | 加载代码 |
| 70 | `lua_next` | 遍历表 |
| 71 | `lua_objlen` | 获取对象长度 |
| 97 | `lua_setlevel` | 设置线程等级 |
| 114 | `lua_xmove` | 移动值到另一状态 |

---

## 标准库开放函数

| 序号 | 函数名 | 说明 |
|------|--------|------|
| 116 | `luaopen_base` | 基础库 |
| 117 | `luaopen_debug` | 调试库 |
| 118 | `luaopen_io` | I/O 库 |
| 119 | `luaopen_math` | 数学库 |
| 120 | `luaopen_os` | 操作系统库 |
| 121 | `luaopen_package` | 包管理库 |
| 122 | `luaopen_string` | 字符串库 |
| 123 | `luaopen_table` | 表处理库 |

---

## 段信息

| 段名 | 大小 |
|------|------|
| `.data` | 0x1000 |
| `.pdata` | 0x3000 |
| `.rdata` | 0x8000 |
| `.reloc` | 0x1000 |
| `.rsrc` | 0x1000 |
| `.text` | 0x27000 |