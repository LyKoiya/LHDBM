import ctypes
from ctypes import *

# 加载 lua5.1.dll
try:
    lua = ctypes.CDLL("!src-dist\\bin\\lua.dll")
    print("lua load success")
except OSError:
    print("lua load fail")


# ==================== 基本类型定义 ====================
# Lua 状态机指针
lua_State = ctypes.c_void_p

# Lua 函数类型（用于回调）
lua_CFunction = ctypes.CFUNCTYPE(ctypes.c_int, lua_State)

# ==================== luaL_* 函数 ====================
lua.luaL_addlstring.argtypes = [lua_State, ctypes.c_char_p, ctypes.c_size_t]
lua.luaL_addlstring.restype = None

lua.luaL_addstring.argtypes = [lua_State, ctypes.c_char_p]
lua.luaL_addstring.restype = None

lua.luaL_addvalue.argtypes = [lua_State]
lua.luaL_addvalue.restype = None

lua.luaL_argerror.argtypes = [lua_State, ctypes.c_int, ctypes.c_char_p]
lua.luaL_argerror.restype = ctypes.c_int

lua.luaL_buffinit.argtypes = [lua_State]
lua.luaL_buffinit.restype = None

lua.luaL_callmeta.argtypes = [lua_State, ctypes.c_int, ctypes.c_char_p]
lua.luaL_callmeta.restype = ctypes.c_int

lua.luaL_checkany.argtypes = [lua_State, ctypes.c_int]
lua.luaL_checkany.restype = None

lua.luaL_checkinteger.argtypes = [lua_State, ctypes.c_int]
lua.luaL_checkinteger.restype = ctypes.c_longlong  # 或 ctypes.c_long

lua.luaL_checklstring.argtypes = [lua_State, ctypes.c_int, ctypes.POINTER(ctypes.c_size_t)]
lua.luaL_checklstring.restype = ctypes.c_char_p

lua.luaL_checknumber.argtypes = [lua_State, ctypes.c_int]
lua.luaL_checknumber.restype = ctypes.c_double

lua.luaL_checkoption.argtypes = [lua_State, ctypes.c_int, ctypes.c_char_p, ctypes.POINTER(ctypes.c_char_p)]
lua.luaL_checkoption.restype = ctypes.c_int

lua.luaL_checkstack.argtypes = [lua_State, ctypes.c_int, ctypes.c_char_p]
lua.luaL_checkstack.restype = None

lua.luaL_checktype.argtypes = [lua_State, ctypes.c_int, ctypes.c_int]
lua.luaL_checktype.restype = None

lua.luaL_checkudata.argtypes = [lua_State, ctypes.c_int, ctypes.c_char_p]
lua.luaL_checkudata.restype = ctypes.c_void_p

lua.luaL_error.argtypes = [lua_State, ctypes.c_char_p]
lua.luaL_error.restype = ctypes.c_int

lua.luaL_findtable.argtypes = [lua_State, ctypes.c_int, ctypes.c_char_p, ctypes.c_size_t]
lua.luaL_findtable.restype = ctypes.c_int

lua.luaL_getmetafield.argtypes = [lua_State, ctypes.c_int, ctypes.c_char_p]
lua.luaL_getmetafield.restype = ctypes.c_int

lua.luaL_gsub.argtypes = [lua_State, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p]
lua.luaL_gsub.restype = ctypes.c_char_p

lua.luaL_loadbuffer.argtypes = [lua_State, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p]
lua.luaL_loadbuffer.restype = ctypes.c_int

lua.luaL_loadfile.argtypes = [lua_State, ctypes.c_char_p]
lua.luaL_loadfile.restype = ctypes.c_int

lua.luaL_loadstring.argtypes = [lua_State, ctypes.c_char_p]
lua.luaL_loadstring.restype = ctypes.c_int

lua.luaL_newmetatable.argtypes = [lua_State, ctypes.c_char_p]
lua.luaL_newmetatable.restype = ctypes.c_int

lua.luaL_newstate.argtypes = []
lua.luaL_newstate.restype = lua_State

lua.luaL_openlib.argtypes = [lua_State, ctypes.c_char_p, ctypes.c_void_p, ctypes.c_int]
lua.luaL_openlib.restype = None

lua.luaL_openlibs.argtypes = [lua_State]
lua.luaL_openlibs.restype = None

lua.luaL_optinteger.argtypes = [lua_State, ctypes.c_int, ctypes.c_longlong]
lua.luaL_optinteger.restype = ctypes.c_longlong

lua.luaL_optlstring.argtypes = [lua_State, ctypes.c_int, ctypes.c_char_p, ctypes.POINTER(ctypes.c_size_t)]
lua.luaL_optlstring.restype = ctypes.c_char_p

lua.luaL_optnumber.argtypes = [lua_State, ctypes.c_int, ctypes.c_double]
lua.luaL_optnumber.restype = ctypes.c_double

lua.luaL_prepbuffer.argtypes = [lua_State]
lua.luaL_prepbuffer.restype = ctypes.c_char_p

lua.luaL_pushresult.argtypes = [lua_State]
lua.luaL_pushresult.restype = None

lua.luaL_ref.argtypes = [lua_State, ctypes.c_int]
lua.luaL_ref.restype = ctypes.c_int

lua.luaL_register.argtypes = [lua_State, ctypes.c_char_p, ctypes.c_void_p]
lua.luaL_register.restype = None

lua.luaL_typerror.argtypes = [lua_State, ctypes.c_int, ctypes.c_char_p]
lua.luaL_typerror.restype = ctypes.c_int

lua.luaL_unref.argtypes = [lua_State, ctypes.c_int, ctypes.c_int]
lua.luaL_unref.restype = None

lua.luaL_where.argtypes = [lua_State, ctypes.c_int]
lua.luaL_where.restype = None

# ==================== lua_* 核心函数 ====================
lua.lua_atpanic.argtypes = [lua_State, lua_CFunction]
lua.lua_atpanic.restype = lua_CFunction

lua.lua_call.argtypes = [lua_State, ctypes.c_int, ctypes.c_int]
lua.lua_call.restype = None

lua.lua_checkstack.argtypes = [lua_State, ctypes.c_int]
lua.lua_checkstack.restype = ctypes.c_int

lua.lua_close.argtypes = [lua_State]
lua.lua_close.restype = None

lua.lua_concat.argtypes = [lua_State, ctypes.c_int]
lua.lua_concat.restype = None

lua.lua_cpcall.argtypes = [lua_State, lua_CFunction, ctypes.c_void_p]
lua.lua_cpcall.restype = ctypes.c_int

lua.lua_createtable.argtypes = [lua_State, ctypes.c_int, ctypes.c_int]
lua.lua_createtable.restype = None

lua.lua_dump.argtypes = [lua_State, ctypes.CFUNCTYPE(ctypes.c_int, lua_State, ctypes.c_void_p, ctypes.c_size_t), ctypes.c_void_p]
lua.lua_dump.restype = ctypes.c_int

lua.lua_equal.argtypes = [lua_State, ctypes.c_int, ctypes.c_int]
lua.lua_equal.restype = ctypes.c_int

lua.lua_error.argtypes = [lua_State]
lua.lua_error.restype = ctypes.c_int

lua.lua_gc.argtypes = [lua_State, ctypes.c_int, ctypes.c_int]
lua.lua_gc.restype = ctypes.c_int

lua.lua_getallocf.argtypes = [lua_State, ctypes.POINTER(ctypes.c_void_p)]
lua.lua_getallocf.restype = ctypes.CFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_size_t)

lua.lua_getfenv.argtypes = [lua_State, ctypes.c_int]
lua.lua_getfenv.restype = None

lua.lua_getfield.argtypes = [lua_State, ctypes.c_int, ctypes.c_char_p]
lua.lua_getfield.restype = None

lua.lua_gethook.argtypes = [lua_State]
lua.lua_gethook.restype = ctypes.CFUNCTYPE(None, lua_State, ctypes.c_void_p)

lua.lua_gethookcount.argtypes = [lua_State]
lua.lua_gethookcount.restype = ctypes.c_int

lua.lua_gethookmask.argtypes = [lua_State]
lua.lua_gethookmask.restype = ctypes.c_int

lua.lua_getinfo.argtypes = [lua_State, ctypes.c_char_p, ctypes.c_void_p]
lua.lua_getinfo.restype = ctypes.c_int

lua.lua_getlocal.argtypes = [lua_State, ctypes.c_void_p, ctypes.c_int]
lua.lua_getlocal.restype = ctypes.c_char_p

lua.lua_getmetatable.argtypes = [lua_State, ctypes.c_int]
lua.lua_getmetatable.restype = ctypes.c_int

lua.lua_getstack.argtypes = [lua_State, ctypes.c_int, ctypes.c_void_p]
lua.lua_getstack.restype = ctypes.c_int

lua.lua_gettable.argtypes = [lua_State, ctypes.c_int]
lua.lua_gettable.restype = None

lua.lua_gettop.argtypes = [lua_State]
lua.lua_gettop.restype = ctypes.c_int

lua.lua_getupvalue.argtypes = [lua_State, ctypes.c_int, ctypes.c_int]
lua.lua_getupvalue.restype = ctypes.c_char_p

lua.lua_insert.argtypes = [lua_State, ctypes.c_int]
lua.lua_insert.restype = None

lua.lua_iscfunction.argtypes = [lua_State, ctypes.c_int]
lua.lua_iscfunction.restype = ctypes.c_int

lua.lua_isnumber.argtypes = [lua_State, ctypes.c_int]
lua.lua_isnumber.restype = ctypes.c_int

lua.lua_isstring.argtypes = [lua_State, ctypes.c_int]
lua.lua_isstring.restype = ctypes.c_int

lua.lua_isuserdata.argtypes = [lua_State, ctypes.c_int]
lua.lua_isuserdata.restype = ctypes.c_int

lua.lua_lessthan.argtypes = [lua_State, ctypes.c_int, ctypes.c_int]
lua.lua_lessthan.restype = ctypes.c_int

lua.lua_load.argtypes = [lua_State, ctypes.CFUNCTYPE(ctypes.c_char_p, lua_State, ctypes.c_void_p, ctypes.POINTER(ctypes.c_size_t)), ctypes.c_void_p, ctypes.c_char_p]
lua.lua_load.restype = ctypes.c_int

lua.lua_newstate.argtypes = [ctypes.CFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t), ctypes.c_void_p]
lua.lua_newstate.restype = lua_State

lua.lua_newthread.argtypes = [lua_State]
lua.lua_newthread.restype = lua_State

lua.lua_newuserdata.argtypes = [lua_State, ctypes.c_size_t]
lua.lua_newuserdata.restype = ctypes.c_void_p

lua.lua_next.argtypes = [lua_State, ctypes.c_int]
lua.lua_next.restype = ctypes.c_int

lua.lua_objlen.argtypes = [lua_State, ctypes.c_int]
lua.lua_objlen.restype = ctypes.c_size_t

lua.lua_pcall.argtypes = [lua_State, ctypes.c_int, ctypes.c_int, ctypes.c_int]
lua.lua_pcall.restype = ctypes.c_int

lua.lua_pushboolean.argtypes = [lua_State, ctypes.c_int]
lua.lua_pushboolean.restype = None

lua.lua_pushcclosure.argtypes = [lua_State, lua_CFunction, ctypes.c_int]
lua.lua_pushcclosure.restype = None

lua.lua_pushfstring.argtypes = [lua_State, ctypes.c_char_p]
lua.lua_pushfstring.restype = ctypes.c_char_p

lua.lua_pushinteger.argtypes = [lua_State, ctypes.c_longlong]
lua.lua_pushinteger.restype = None

lua.lua_pushlightuserdata.argtypes = [lua_State, ctypes.c_void_p]
lua.lua_pushlightuserdata.restype = None

lua.lua_pushlstring.argtypes = [lua_State, ctypes.c_char_p, ctypes.c_size_t]
lua.lua_pushlstring.restype = None

lua.lua_pushnil.argtypes = [lua_State]
lua.lua_pushnil.restype = None

lua.lua_pushnumber.argtypes = [lua_State, ctypes.c_double]
lua.lua_pushnumber.restype = None

lua.lua_pushstring.argtypes = [lua_State, ctypes.c_char_p]
lua.lua_pushstring.restype = None

lua.lua_pushthread.argtypes = [lua_State]
lua.lua_pushthread.restype = ctypes.c_int

lua.lua_pushvalue.argtypes = [lua_State, ctypes.c_int]
lua.lua_pushvalue.restype = None

lua.lua_pushvfstring.argtypes = [lua_State, ctypes.c_char_p, ctypes.c_void_p]
lua.lua_pushvfstring.restype = ctypes.c_char_p

lua.lua_rawequal.argtypes = [lua_State, ctypes.c_int, ctypes.c_int]
lua.lua_rawequal.restype = ctypes.c_int

lua.lua_rawget.argtypes = [lua_State, ctypes.c_int]
lua.lua_rawget.restype = None

lua.lua_rawgeti.argtypes = [lua_State, ctypes.c_int, ctypes.c_int]
lua.lua_rawgeti.restype = None

lua.lua_rawset.argtypes = [lua_State, ctypes.c_int]
lua.lua_rawset.restype = None

lua.lua_rawseti.argtypes = [lua_State, ctypes.c_int, ctypes.c_int]
lua.lua_rawseti.restype = None

lua.lua_remove.argtypes = [lua_State, ctypes.c_int]
lua.lua_remove.restype = None

lua.lua_replace.argtypes = [lua_State, ctypes.c_int]
lua.lua_replace.restype = None

lua.lua_resume.argtypes = [lua_State, ctypes.c_int]
lua.lua_resume.restype = ctypes.c_int

lua.lua_setallocf.argtypes = [lua_State, ctypes.CFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_size_t), ctypes.c_void_p]
lua.lua_setallocf.restype = None

lua.lua_setfenv.argtypes = [lua_State, ctypes.c_int]
lua.lua_setfenv.restype = ctypes.c_int

lua.lua_setfield.argtypes = [lua_State, ctypes.c_int, ctypes.c_char_p]
lua.lua_setfield.restype = None

lua.lua_sethook.argtypes = [lua_State, ctypes.CFUNCTYPE(None, lua_State, ctypes.c_void_p), ctypes.c_int, ctypes.c_int]
lua.lua_sethook.restype = None

lua.lua_setlevel.argtypes = [lua_State, lua_State]
lua.lua_setlevel.restype = None

lua.lua_setlocal.argtypes = [lua_State, ctypes.c_void_p, ctypes.c_int]
lua.lua_setlocal.restype = ctypes.c_char_p

lua.lua_setmetatable.argtypes = [lua_State, ctypes.c_int]
lua.lua_setmetatable.restype = None

lua.lua_settable.argtypes = [lua_State, ctypes.c_int]
lua.lua_settable.restype = None

lua.lua_settop.argtypes = [lua_State, ctypes.c_int]
lua.lua_settop.restype = None

lua.lua_setupvalue.argtypes = [lua_State, ctypes.c_int, ctypes.c_int]
lua.lua_setupvalue.restype = ctypes.c_char_p

lua.lua_status.argtypes = [lua_State]
lua.lua_status.restype = ctypes.c_int

lua.lua_toboolean.argtypes = [lua_State, ctypes.c_int]
lua.lua_toboolean.restype = ctypes.c_int

lua.lua_tocfunction.argtypes = [lua_State, ctypes.c_int]
lua.lua_tocfunction.restype = lua_CFunction

lua.lua_tointeger.argtypes = [lua_State, ctypes.c_int]
lua.lua_tointeger.restype = ctypes.c_longlong

lua.lua_tolstring.argtypes = [lua_State, ctypes.c_int, ctypes.POINTER(ctypes.c_size_t)]
lua.lua_tolstring.restype = ctypes.c_char_p

lua.lua_tonumber.argtypes = [lua_State, ctypes.c_int]
lua.lua_tonumber.restype = ctypes.c_double

lua.lua_topointer.argtypes = [lua_State, ctypes.c_int]
lua.lua_topointer.restype = ctypes.c_void_p

lua.lua_tothread.argtypes = [lua_State, ctypes.c_int]
lua.lua_tothread.restype = lua_State

lua.lua_touserdata.argtypes = [lua_State, ctypes.c_int]
lua.lua_touserdata.restype = ctypes.c_void_p

lua.lua_type.argtypes = [lua_State, ctypes.c_int]
lua.lua_type.restype = ctypes.c_int

lua.lua_typename.argtypes = [lua_State, ctypes.c_int]
lua.lua_typename.restype = ctypes.c_char_p

lua.lua_xmove.argtypes = [lua_State, lua_State, ctypes.c_int]
lua.lua_xmove.restype = None

lua.lua_yield.argtypes = [lua_State, ctypes.c_int]
lua.lua_yield.restype = ctypes.c_int

# ==================== luaopen_* 库函数 ====================
lua.luaopen_base.argtypes = [lua_State]
lua.luaopen_base.restype = ctypes.c_int

lua.luaopen_debug.argtypes = [lua_State]
lua.luaopen_debug.restype = ctypes.c_int

lua.luaopen_io.argtypes = [lua_State]
lua.luaopen_io.restype = ctypes.c_int

lua.luaopen_math.argtypes = [lua_State]
lua.luaopen_math.restype = ctypes.c_int

lua.luaopen_os.argtypes = [lua_State]
lua.luaopen_os.restype = ctypes.c_int

lua.luaopen_package.argtypes = [lua_State]
lua.luaopen_package.restype = ctypes.c_int

lua.luaopen_string.argtypes = [lua_State]
lua.luaopen_string.restype = ctypes.c_int

lua.luaopen_table.argtypes = [lua_State]
lua.luaopen_table.restype = ctypes.c_int

# ==================== LUA 常量 ====================
LUA_GLOBALSINDEX = -10002
LUA_REGISTRYINDEX = -10000

# ==================== Python 封装类 ====================
class LuaState:
    """Lua 状态机封装"""

    def __init__(self, open_libs=True):
        """
        初始化 Lua 状态机
        :param open_libs: 是否自动打开标准库
        """
        self.state = lua.luaL_newstate()
        if not self.state:
            raise RuntimeError("Failed to create Lua state")
        
        if open_libs:
            lua.luaL_openlibs(self.state)
        
        self._closed = False
    
    def loadstring(self, code: str, chunk_name: str = "chunk") -> int:
        """加载 Lua 代码字符串"""
        return lua.luaL_loadstring(self.state, code.encode("gbk"))
    
    def loadfile(self, filename: str) -> int:
        """加载 Lua 文件"""
        return lua.luaL_loadfile(self.state, filename.encode("gbk"))
    def pcall(self, nargs: int = 0, nresults: int = 0, errfunc: int = 0) -> int:
        """保护调用 Lua 函数"""
        return lua.lua_pcall(self.state, nargs, nresults, errfunc)
    
    def call(self, nargs: int = 0, nresults: int = 0):
        """直接调用 Lua 函数（不保护）"""
        lua.lua_call(self.state, nargs, nresults)
    
    def pushstring(self, s: str):
        """推送字符串到栈"""
        lua.lua_pushstring(self.state, s.encode("gbk") + b"\0")

    def pushlstring(self, s: str):
        """显式推送字符串到栈"""
        lua.lua_pushlstring(self.state, s.encode("gbk"), len(s.encode("gbk")))
    
    def pushnumber(self, n: float):
        """推送数字到栈"""
        lua.lua_pushnumber(self.state, ctypes.c_double(n))
    
    def pushinteger(self, n: int):
        """推送整数到栈"""
        lua.lua_pushinteger(self.state, ctypes.c_longlong(n))
    
    def pushboolean(self, b: bool):
        """推送布尔值到栈"""
        lua.lua_pushboolean(self.state, 1 if b else 0)
    
    def pushnil(self):
        """推送 nil 到栈"""
        lua.lua_pushnil(self.state)
    
    def getglobal(self, name: str):
        """获取全局变量（推送到栈顶）"""
        lua.lua_getfield(self.state, LUA_GLOBALSINDEX, name.encode("gbk"))
    
    def setglobal(self, name: str):
        """设置全局变量（从栈顶弹出）"""
        lua.lua_setfield(self.state, LUA_GLOBALSINDEX, name.encode("gbk"))
    
    def gettop(self) -> int:
        """获取栈顶索引"""
        return lua.lua_gettop(self.state)
    
    def settop(self, idx: int):
        """设置栈顶"""
        lua.lua_settop(self.state, idx)
    
    def tostring(self, idx: int) -> str:
        """将栈上的值转换为字符串"""
        result = lua.lua_tolstring(self.state, idx, None)
        return result.decode('gbk') if result else None
    
    def tonumber(self, idx: int) -> float:
        """将栈上的值转换为数字"""
        return lua.lua_tonumber(self.state, idx)
    
    def tointeger(self, idx: int) -> int:
        """将栈上的值转换为整数"""
        return lua.lua_tointeger(self.state, idx)
    
    def toboolean(self, idx: int) -> bool:
        """将栈上的值转换为布尔值"""
        return lua.lua_toboolean(self.state, idx) != 0
    
    def dostring(self, code: str) -> bool:
        """
        执行 Lua 代码字符串（便捷方法）
        :return: 是否成功
        """
        if self.loadstring(code) != 0:
            return False
        return self.pcall(0, 0, 0) == 0
    
    def dofile(self, filename: str) -> bool:
        """
        执行 Lua 文件（便捷方法）
        :return: 是否成功
        """
        if self.loadfile(filename) != 0:
            return False
        return self.pcall(0, 0, 0) == 0

    def close(self):
        """关闭 Lua 状态机"""
        if not self._closed and self.state:
            lua.lua_close(self.state)
            self._closed = True
            self.state = None
    
    def __enter__(self):
        """上下文管理器支持"""
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """上下文管理器退出时自动关闭"""
        self.close()
    
    def __del__(self):
        """析构函数：确保资源释放"""
        self.close()

