#include "jychm.h"
#include "sdlfun.h"
#include "jymain.h"
#include <fstream>
#include <iostream>
#include <string>
#include "charset.h"
#include <list>
#include <direct.h>
#include <io.h>

using namespace std;

jychm::jychm()
{
	personsize = 0;
	itemsize = 0;
	kongfusize=0;

	memset(idx, 0, sizeof(int) * 6);

	char * buffer;
	long size;
	ifstream file("DATA\\ranger.idx", ios::in | ios::binary | ios::ate);
	size = file.tellg();
	file.seekg(0, ios::beg);
	buffer = new char[size];
	file.read(buffer, size);
	file.close();
	idx[0] = 0;
	for (int i = 1; i < 6; ++i)
	{
		idx[i]  = *(int*)(buffer + (i-1)*4);

		printf("%d \r\n", idx[i]);
	}

	delete[] buffer;


	char * buffercontent;
	long sizecontent;
	ifstream filecontent("DATA\\ranger.grp", ios::in | ios::binary | ios::ate);
	sizecontent = filecontent.tellg();
	filecontent.seekg(0, ios::beg);
	buffercontent = new char[sizecontent];
	filecontent.read(buffercontent, sizecontent);
	filecontent.close();


	for (int i = 0; i < 5; ++i)
	{
		int lenth = idx[i + 1] - idx[i];
		context[i] = new char[lenth];

		memcpy(context[i], buffercontent + idx[i], lenth);
		printf("%d \r\n", idx[i]);
	}

	delete[] buffercontent;


}



jychm::~jychm()
{
	
}

// 创建CHM文件
bool jychm::creatChm()
{

	init_baseinfo();
	read_ItemInfo();
	setperson();
	setitems();
	setkongfus();
	setbase();
	return false;
}

// 创建CHM文件
bool jychm::insertitem()
{
	char * buffercontent;
	long sizecontent;
	ifstream filecontent("DATA\\ranger.grp", ios::in | ios::binary | ios::ate);
	sizecontent = filecontent.tellg();
	filecontent.seekg(0, ios::beg);
	buffercontent = new char[sizecontent];
	filecontent.read(buffercontent, sizecontent);
	filecontent.close();


	

	delete[] buffercontent;

	return false;
}


int* jychm::get_subinfo()
{
	lua_pop(pL_main, 1);
	int* indexseek = new int[3];
	memset(indexseek, 0, sizeof(int) * 3);

	lua_pushnil(pL_main);
	int index = 0;
	while (lua_next(pL_main, -2))
	{

		if (lua_isnumber(pL_main, -1)) {

			indexseek[index] = (int)lua_tonumber(pL_main, -1);
			index++;
		}

		lua_pop(pL_main, 1);
	}

	
	return indexseek;
}

bool jychm::getinfo(string filepath)
{

	// 以写模式打开文件
	basic_ofstream<char> outfile;
	outfile.open(filepath);

	lua_pop(pL_main, 1);

	lua_pushnil(pL_main);
	while (lua_next(pL_main, -2))
	{
		//这时值在-1（栈顶）处，key在-2处，表在-3处  
		lua_pushvalue(pL_main, -2);
		if (lua_isstring(pL_main, -1)) {
			const char* str = lua_tostring(pL_main, -1);

			string tmpstr = string(str);
			outfile << tmpstr << "\t";
		}

		int* indexp = get_subinfo();



		outfile <<indexp[0] << "\t" << indexp[1] << "\t" << indexp[2] << endl;

		free(indexp);


		lua_pop(pL_main, 1);//把栈顶的值移出栈，让key成为栈顶以便继续遍历  
	}

	// 关闭打开的文件
	outfile.close();

	return true;
}

void jychm::read_TFJS_baseinfo()
{
	lua_getglobal(pL_main, "TFJS");

	basic_ofstream<char> outfile;



	outfile.open("天赋系统.txt");


	string nameid = "";

	lua_pushnil(pL_main);
	while (lua_next(pL_main, -2))
	{
		//这时值在-1（栈顶）处，key在-2处，表在-3处  
		lua_pushvalue(pL_main, -2);
		if (lua_isstring(pL_main, -1)) {
			const char* str = lua_tostring(pL_main, -1);
			printf("%s : ", str);

			nameid = string(str);
			outfile << nameid;
		}

		vector<string> v;
		get_strinfo(pL_main, v);
		vector<string>::iterator it = v.begin();
		// vector<int>::const_iterator iter=v.begin();
		for (; it != v.end(); ++it)
		{
			outfile << "\t"<<*it;
		}
		outfile << endl;

		lua_pop(pL_main, 1);//把栈顶的值移出栈，让key成为栈顶以便继续遍历  
	}
	outfile.close();


	lua_pop(pL_main, 1);
}



void jychm::read_RWWH_baseinfo()
{
	lua_getglobal(pL_main, "RWWH");

	basic_ofstream<char> outfile;



	outfile.open("人物外号.txt");


	string nameid = "";

	lua_pushnil(pL_main);
	while (lua_next(pL_main, -2))
	{
		//这时值在-1（栈顶）处，key在-2处，表在-3处  
		lua_pushvalue(pL_main, -2);
		if (lua_isstring(pL_main, -1)) {
			const char* str = lua_tostring(pL_main, -1);
			printf("%s : ", str);

			nameid = string(str);

		}

		if (lua_isstring(pL_main, -2)) {
			const char* str = lua_tostring(pL_main, -2);
			//printf("%s \r\n", str);
			string tmpstr = string(str);

			outfile << nameid << "\t" << tmpstr << endl;

		}
		else
		{
			//printf("%s \r\n", "not str");
		}

		lua_pop(pL_main, 2);//把栈顶的值移出栈，让key成为栈顶以便继续遍历  
	}
	outfile.close();


	lua_pop(pL_main, 1);
}

void jychm::read_CC_baseinfo()
{
	lua_getglobal(pL_main, "CC");

	/*if (lua_isstring(pL_main, -1)) {
	const char* str = lua_tostring(pL_main, -1);
	printf(str);

	}*/

	personsize = getfield(pL_main, "PersonSize");
	itemsize = getfield(pL_main, "ThingSize");
	kongfusize = getfield(pL_main, "WugongSize");


	lua_pushnil(pL_main);
	while (lua_next(pL_main, -2))
	{
		//这时值在-1（栈顶）处，key在-2处，表在-3处  
		lua_pushvalue(pL_main, -2);
		if (lua_isstring(pL_main, -1)) {
			const char* str = lua_tostring(pL_main, -1);
			printf("%s : ", str);
			
			string tmpstr = string(str);
			std::cout << tmpstr << endl;
			if (tmpstr.compare("Person_S") == 0 || tmpstr.compare("Base_S") == 0 || tmpstr.compare("Thing_S") == 0 ||
				tmpstr.compare("Scene_S") == 0 || tmpstr.compare("Wugong_S") == 0)
			{

				getinfo(tmpstr);
				lua_pop(pL_main, 1);
				continue;
			}
			

		}

		if (lua_isstring(pL_main, -2)) {
			const char* str = lua_tostring(pL_main, -2);
			//printf("%s \r\n", str);

		}
		else
		{
			//printf("%s \r\n", "not str");
		}

		lua_pop(pL_main, 2);//把栈顶的值移出栈，让key成为栈顶以便继续遍历  
	}

	lua_pop(pL_main, 1);
}

void jychm::get_strinfo(lua_State* pl, std::vector<std::string>& v)
{
	lua_pop(pl, 1);

	lua_pushnil(pl);
	while (lua_next(pl, -2))
	{

		if (lua_isstring(pl, -1)) {
			const char* str = lua_tostring(pl, -1);
			//printf("%s : ", str);

			string tmpstr = string(str);

			v.push_back(tmpstr);


		}

		lua_pop(pl, 1);
	}


	return;
}

void jychm::read_ItemInfo()
{

	lua_State* pl = NULL;
	pl = luaL_newstate();
	luaL_openlibs(pl);
	//加载lua配置文件
	int result = luaL_loadfile(pl, "./script/ItemInfo.lua");

	result = lua_pcall(pl, 0, LUA_MULTRET, 0);

	lua_getglobal(pl, "ItemInfo");

	lua_pushnil(pl);
	while (lua_next(pl, -2))
	{
		Base_ItemInfo* tmpitem =new Base_ItemInfo();
		//这时值在-1（栈顶）处，key在-2处，表在-3处  
		lua_pushvalue(pl, -2);
		if (lua_isstring(pl, -1)) {
			const char* str = lua_tostring(pl, -1);
			string tmpstr = string(str);

			tmpitem->index = tmpstr;
			}
		vector<string> v;
		get_strinfo(pl,v);
		tmpitem->explaninfos.clear();
		tmpitem->explaninfos.assign(v.begin(), v.end());
		lua_pop(pl, 1);

		items.push_back(tmpitem);
	}


	lua_pop(pl, 1);


	list<Base_ItemInfo*>::iterator it; //声明一个迭代器
	for (it = items.begin(); it != items.end(); it++) {

		basic_ofstream<char> outfile;

		Base_ItemInfo* tmpinfo = *it;

		if (_access("物品说明", 0) == -1)//不存在
		{
			_mkdir("物品说明");
		}

		string filename = "物品说明\\" + tmpinfo->index + ".txt";

		outfile.open(filename);

		for (auto i : tmpinfo->explaninfos)
		{
			outfile << i << endl;
		}


		outfile.close();



	}

}

void jychm::init_baseinfo()
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


	read_CC_baseinfo();

	read_ItemInfo();

	read_RWWH_baseinfo();

	read_TFJS_baseinfo();
}



void jychm::SplitString(const std::string& s, std::vector<std::string>& v, const std::string& c)
{
	std::string::size_type pos1, pos2;
	pos2 = s.find(c);
	pos1 = 0;
	while (std::string::npos != pos2)
	{
		v.push_back(s.substr(pos1, pos2 - pos1));

		pos1 = pos2 + c.size();
		pos2 = s.find(c, pos1);
	}
	if (pos1 != s.length())
		v.push_back(s.substr(pos1));
}


bool jychm::dirExists(const std::string& dirName_in)
{
	int ftyp = _access(dirName_in.c_str(), 0);

	if (0 == ftyp)
		return true;   // this is a directory!
	else
		return false;    // this is not a directory!
}


void jychm::outputinfo(char* personcont, list<Base_Info_jyoffset*> baseinfo, string path,string keyvalue)
{

	if (_access(path.c_str(), 0) == -1)//不存在
	{
		_mkdir(path.c_str());
	}



	string name;
	list<Base_Info_jyoffset*>::iterator it; //声明一个迭代器
	for (it = baseinfo.begin(); it != baseinfo.end(); it++) {
		Base_Info_jyoffset* tmpinfo = *it;

		

		char* src = (char*)malloc(tmpinfo->infolenth + 1);
		int j;
		for (j = 0; j < tmpinfo->infolenth; j++)
		{
			src[j] = personcont[tmpinfo->startoffset + j];
		}

		src[tmpinfo->infolenth] = '\0';
		unsigned short sint = 0;
		int vint = 0;
		int length = 0;
		char* dest;
		switch (tmpinfo->infotype)
		{
		case 0:
			sint  = *(unsigned short*)src;
			tmpinfo->value = to_string(sint);
			break;
		case 1:

			vint  = *(int*)src;
			tmpinfo->value = to_string(vint);
			break;
		case 2:

			length = strlen(src);
			dest = (char*)malloc(length + 2);
			JY_CharSet(src, dest, 0);
			tmpinfo->value = dest;
			break;
		default:
			break;
		}

		if (tmpinfo->infoName == keyvalue)
		{
			name = tmpinfo->value;
		}
	}


	basic_ofstream<char> outfile;

	string filename = path+"\\" + name + ".txt";

	outfile.open(filename);

	for (it = baseinfo.begin(); it != baseinfo.end(); it++) {
		Base_Info_jyoffset* tmpinfo = *it;
		outfile << tmpinfo->infoName << "=" << tmpinfo->value << endl;

	}
	
	//printf("name = %s", dest);
	outfile.close();
}


void jychm::outputinfo(int psize, int infosize, char* contextp, string filename,string subfilename,string reslutfilekey)
{
	int infonum = psize / infosize;

	ifstream filecontent(filename);
	std::string line;

	list<Base_Info_jyoffset*> PESONLIST;

	while (std::getline(filecontent, line))
	{
		vector<string> v;
		SplitString(line,v,"\t"); //可按多个字符来分隔;

		Base_Info_jyoffset* personbaseinfo = new Base_Info_jyoffset();

		personbaseinfo->infoName = v[0];
		personbaseinfo->startoffset = stoi(v[1]);
		personbaseinfo->infotype = stoi(v[2]);
		personbaseinfo->infolenth = stoi(v[3]);
		PESONLIST.push_back(personbaseinfo);
	}

	filecontent.close();

	for (int i = 0; i < infonum; ++i)
	{
		char* oneperson = new char[infosize];
		memcpy(oneperson, contextp +i* infosize, infosize);


		outputinfo(oneperson, PESONLIST, subfilename,reslutfilekey);

	}

	for (list<Base_Info_jyoffset*>::iterator it = PESONLIST.begin(); it != PESONLIST.end(); it++)
	{
		if (NULL != *it)
		{
			delete *it;
			*it = NULL;
		}
	}
	PESONLIST.clear();
}

bool jychm::setperson()
{
	int psize = idx[2] - idx[1];

	int infosize = personsize;
	char* contextp = context[1];
	string filename = "Person_S";


	outputinfo(psize, infosize, contextp, filename,"人物","姓名");


	return true;
	
}

bool jychm::setitems()
{
	int psize = idx[3] - idx[2];

	int infosize = itemsize;
	char* contextp = context[2];
	string filename = "Thing_S";


	outputinfo(psize, infosize, contextp, filename, "物品", "代号");


	return true;

}

bool jychm::setkongfus()
{
	int psize = idx[5] - idx[4];

	int infosize = kongfusize;
	char* contextp = context[4];
	string filename = "Wugong_S";


	outputinfo(psize, infosize, contextp, filename, "武功", "名称");


	return true;

}


bool jychm::setbase()
{
	int psize = idx[1] - idx[0];

	int infosize = idx[1];
	char* contextp = context[0];
	string filename = "Base_S";


	outputinfo(psize, infosize, contextp, filename, "基本", "船X");


	return true;

}

bool jychm::loadimage(string pid)
{
	return true;
}