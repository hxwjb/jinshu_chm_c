#pragma once
#include <string>
using namespace std;

class jyperson
{
public:
	//
	int    pid;
	//头像代号
	int    hid;

	//姓名
	string name;

	//外号
	string name2;

	//性别
	string sex;
	
	//等级
	string level;

	//生命
	string hp;

	//内力
	string mp;
	//攻击力
	string ack;
	//轻功
	string skill;
	
	//防御力

public:
	jyperson();
	~jyperson();

};