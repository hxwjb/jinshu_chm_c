#pragma once
#include "jyperson.h"
#include <xstring>
#include <vector>
#include <list>
#include "jymain.h"


struct Base_Info_jyoffset {      //声明一个结构体类型Student 
	string	infoName;
	int		startoffset;
	int		infotype;
	int		infolenth;
	string  value;
};


struct Base_ItemInfo {      //声明一个结构体类型Student 
	string		index;
	vector<string> explaninfos;
};


class jychm
{
public:
	int personsize;
	int itemsize;
	int kongfusize;

	int idx[6];

	char *context[5];
	list<Base_ItemInfo*> items;
public:
	jychm();
	~jychm();
	int* get_subinfo();
	bool getBaseinfo();
	bool getinfo(std::string filepath);
	void read_RWWH_baseinfo();
	void read_CC_baseinfo();
	void get_strinfo(lua_State* pl, std::vector<std::string>& v);
	void read_ItemInfo();
	void init_baseinfo();
	// 创建CHM文件
	bool creatChm();
	bool insertitem();
	void SplitString(const std::string& s, std::vector<std::string>& v, const std::string& c);
	bool dirExists(const std::string& dirName_in);
	void outputinfo(char* personcont, list<Base_Info_jyoffset*> baseinfo, string path, string keyvalue);
	void outinfo(char* personcont, list<Base_Info_jyoffset*> baseinfo, string filename);
	void outpersoninfo(char* personcont, list<Base_Info_jyoffset*> baseinfo);
	void outputinfo(int psize, int infosize, char* contextp, string filename, string subfilename, string reslutfilekey);
	bool setperson();
	bool setitems();
	bool setkongfus();
	bool setbase();
	bool loadimage(string pid);
};

