#include "jychm.h"
#include "../src/sdlfun.h"
#include "../src/jymain.h"


// 创建CHM文件
bool jychm::creatChm()
{

	int result = 0;

	//调用lua的函数IncludeFile
	lua_getglobal(pL_main, "IncludeFile");
	result = lua_pcall(pL_main, 0, 0, 0);

	//调用lua的函数SetGlobalConst
	lua_getglobal(pL_main, "SetGlobalConst");
	result = lua_pcall(pL_main, 0, 0, 0);

	//调用lua的函数SetGlobal
	lua_getglobal(pL_main, "SetGlobal");
	result = lua_pcall(pL_main, 0, 0, 0);




	//调用lua的函数SetGlobal
	lua_getglobal(pL_main, "LoadRecord");
	lua_pushnumber(pL_main, 0);
	result = lua_pcall(pL_main, 1, 0, 0);

	lua_getglobal(pL_main, "VK_ESCAPE");

	if (lua_isnumber(pL_main, -1)) {
		int width = (int)lua_tonumber(pL_main, -1);
		int aaa = width + 1;

	}
	lua_pop(pL_main, 1);


	lua_getglobal(pL_main, "JY.PersonNum");
	int personnum = 0;
	if (lua_isnumber(pL_main, -1)) {
		personnum = (int)lua_tonumber(pL_main, -1);

	}
	lua_pop(pL_main, 1);


	lua_getglobal(pL_main, "CC");

	/*if (lua_isstring(pL_main, -1)) {
	const char* str = lua_tostring(pL_main, -1);
	printf(str);

	}*/

	lua_pushnil(pL_main);
	while (lua_next(pL_main, -2))
	{
		//这时值在-1（栈顶）处，key在-2处，表在-3处  
		lua_pushvalue(pL_main, -2);
		if (lua_isstring(pL_main, -1)) {
			const char* str = lua_tostring(pL_main, -1);
			printf("%s : ", str);
		}

		if (lua_isstring(pL_main, -2)) {
			const char* str = lua_tostring(pL_main, -2);
			printf("%s \r\n", str);

		}
		else
		{
			printf("%s \r\n", "not str");
		}

		lua_pop(pL_main, 2);//把栈顶的值移出栈，让key成为栈顶以便继续遍历  
	}

	lua_pop(pL_main, 1);

	return false;
}
