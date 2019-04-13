
--设置全局变量CC，保存游戏中使用的常数
function SetGlobalConst()

	--无酒不欢：基本完整的SDL2键码，便于设置快捷键
	VK_ESCAPE=27
	VK_SPACE=32				--注意这里的空格实际上不需要定义，因为底层会自动把空格转换成回车
	VK_RETURN=13
	VK_F1=1073741882
	VK_F2=1073741883
	VK_F3=1073741884
	VK_F4=1073741885
	VK_A = 97
	VK_B = 98 
	VK_C = 99 
	VK_D = 100 
	VK_E = 101
	VK_F = 102 
	VK_G = 103
	VK_H = 104 
	VK_I = 105
	VK_J = 106 
	VK_K = 107
	VK_L = 108 
	VK_M = 109
	VK_N = 110 
	VK_O = 111
	VK_P = 112 
	VK_Q = 113
	VK_R = 114 
	VK_S = 115
	VK_T = 116 
	VK_U = 117
	VK_V = 118 
	VK_W = 119
	VK_X = 120 
	VK_Y = 121
	VK_Z = 122 
	
	VK_BACKSPACE = 8

	VK_UP=1073741906
	VK_DOWN=1073741905
	VK_LEFT=1073741904
	VK_RIGHT=1073741903
	VK_PGUP=1073741899
	VK_PGDN=1073741902
		
	-- 游戏中颜色定义
	C_GRAY22 = RGB(68, 68, 68)
	C_BLUE = RGB(7, 99, 219)
	C_WSTM = RGB(0, 0, 0)  --属性面板用	
	C_CYGOLD = RGB(216, 214, 175)  --属性面板用
	C_STARTMENU = RGB(132, 0, 4)
	C_RED = RGB(216, 20, 24) --红
	C_WHITE = RGB(236, 236, 236) --白
	C_ORANGE = RGB(252, 148, 16) --橘色
	C_GOLD = RGB(236, 200, 40) --金
	C_BLACK = RGB(0, 0, 0) --黑色
	M_Black = RGB(0, 0, 0) --黑色
	M_Sienna = RGB(160, 82, 45) --褐色
	M_DarkOliveGreen = RGB(85, 107, 47)--深绿 
	M_DarkGreen = RGB(0, 100, 0) --深绿
	M_DarkSlateBlue = RGB(72, 61, 139) --板岩暗蓝灰色
	M_Navy = RGB(0, 0, 128) --海军蓝
	M_Indigo = RGB(75, 0, 130) --靓蓝色
	M_DarkSlateGray = RGB(47, 79, 79) --深青色
	M_DarkRed = RGB(139, 0, 0) -- 深红
	M_DarkOrange = RGB(255, 140, 0) --深橘色
	M_Olive = RGB(128, 128, 0) --橄榄色
	M_Green = RGB(0, 128, 0) --绿
	M_Teal = RGB(0, 128, 128) --水绿
	M_Blue = RGB(0, 0, 255) --蓝
	M_SlateGray = RGB(112, 128, 144) --灰石
	M_DimGray = RGB(105, 105, 105) --暗灰
	M_Red = RGB(255, 0, 0) --红
	M_SandyBrown = RGB(244, 164, 96) --黄褐色
	M_YellowGreen = RGB(154, 205, 50) --黄绿
	M_SeaGreen = RGB(46, 139, 87) --海绿
	M_MediumTurquoise = RGB(72, 209, 204) --宝石绿
	M_RoyalBlue = RGB(65, 105, 225) --宝蓝色
	M_Purple = RGB(128, 0, 128) -- 紫
	M_Gray = RGB(128, 128, 128) --灰
	M_Magenta = RGB(255, 0, 255) --洋红
	M_Orange = RGB(255, 165, 0) --橘色
	M_Yellow = RGB(255, 255, 0) --黄
	M_Lime = RGB(0, 255, 0)  --石灰
	M_Cyan = RGB(0, 255, 255) --青色/蓝绿
	M_DeepSkyBlue = RGB(0, 191, 255) --深天蓝
	M_DarkOrchid = RGB(153, 50, 204) --深兰花紫 
	M_Silver = RGB(192, 192, 192) --银色
	M_Pink = RGB(255, 192, 203) -- 粉
	M_Wheat = RGB(245, 222, 179) --小麦色
	M_Wheat2 = RGB(205, 182, 139) --小麦色
	M_LemonChiffon = RGB(255, 250, 205) --柠檬色
	M_PaleGreen = RGB(152, 251, 152) -- 苍绿
	M_PaleTurquoise = RGB(175, 238, 238) -- 宝石绿
	M_LightBlue = RGB(173, 216, 230)   --浅蓝
	M_Plum = RGB(221, 160, 221) --紫红葡萄
	M_White = RGB(255, 255, 255) --白
	MilkWhite =RGB(255, 255, 204)  --奶白
	LimeGreen = RGB(100,200, 90) -- 灰灰绿
	Lime = RGB(0,255,0) --石灰
	LightGreen = RGB(144,238,144)  --浅绿
	LightSkyBlue = RGB(135,206,250) --深空蓝
	green1 = RGB(145, 235, 45)  --绿色1
	OliveDrab = RGB(107, 142, 35) --绿褐色
	Snow3 = RGB(205, 201, 201) --雪银
	grey21 = RGB(54, 54, 54)  --灰
	LightSlateBlue = RGB(132, 112, 255) -- 浅石蓝
	Violet = RGB(208, 152, 208) -- 紫罗兰
	PinkRed = RGB(255, 102, 102) --粉红
	LightPurple = RGB(165, 28, 218) --深紫
	Color_Hurt1 = RGB(255, 215, 0) --金
	TG_Red = RGB(216, 20, 24) --红色
	TG_Red_Bright = RGB(248, 40, 44) --亮红
	Dark_Gold = RGB(216, 180, 20) -- 黑金
	S_Yellow = RGB(245, 215, 15) --深黄
	LightYellow = RGB(255, 242, 204)  --浅黄
	LightYellow2 = RGB(255, 229, 153)  --浅黄
	LightYellow3 = RGB(255, 217, 102)  --浅黄2

	-- 游戏状态定义
    GAME_START =0       --开始画面
    GAME_FIRSTMMAP = 1  --第一次显示主地图
    GAME_MMAP =2;       --主地图
    GAME_FIRSTSMAP = 3  --第一次显示主地图
    GAME_SMAP =4;       --场景地图
    GAME_WMAP =5;       --战斗地图
	GAME_DEAD =6;       --死亡画面
    GAME_END  =7;       --结束
    GAME_NEWNAME = 8;		--开启新游戏
	
	
	--游戏数据全局变量
	CC={};				--定义游戏中使用的常量，这些可以在修改游戏时修改之

	--实际的屏幕宽度与高度
	CC.ScreenW=lib.GetScreenW();		--显示窗口宽高
    CC.ScreenH=lib.GetScreenH();

	CC.SrcCharSet=0;					--源代码的字符集 0 gb  1 big5，用于转换R×。 如果源码被转换为big5，则应设为1
	CC.OSCharSet=CONFIG.CharSet;		--OS 字符集，-1 系统判断，0 GB, 1 Big5
	CC.FontName=CONFIG.FontName;		--显示字体

	--定义记录文件名。S和D由于是固定大小，因此不再定义idx了。
	CC.R_IDXFilename = {[0] = CONFIG.DataPath .. "ranger.idx"}
	CC.R_GRPFilename = {[0] = CONFIG.DataPath .. "ranger.grp"}
	CC.S_Filename = {[0] = CONFIG.DataPath .. "allsin.grp"}
	CC.D_Filename = {[0] = CONFIG.DataPath .. "alldef.grp"}
	
	CC.SavePath = CONFIG.DataPath .. "save/";
	CC.R_GRP = CC.SavePath.."r%d.grp"
	CC.S_GRP = CC.SavePath.."s%d.grp"
	CC.D_GRP = CC.SavePath.."d%d.grp"
	CC.CS = CC.SavePath.."tjm"
	CC.SaveNum = 10;			--存档数量为10

	CC.TempS_Filename=CONFIG.DataPath .. "allsinbk.grp";

	CC.PaletteFile=CONFIG.DataPath .. "mmap.col";
   
    CC.GAMESTARTFile = CONFIG.PicturePath .. "GAMESTAR.png";
    CC.SayBoxNMFile=CONFIG.PicturePath .. "sayboxnm.png";  
    CC.SayBoxFile=CONFIG.PicturePath .. "saybox.png";
	CC.BG01File=CONFIG.PicturePath .. "bg01.png";
	CC.FirstFile=CONFIG.PicturePath .. "title.png";
	CC.DeadFile=CONFIG.PicturePath .. "dead.png";
    CC.JYXXFile=CONFIG.PicturePath .. "jyxx.png";
	CC.MMapFile={CONFIG.DataPath .. "earth.002",
				CONFIG.DataPath .. "surface.002",
				CONFIG.DataPath .. "building.002",
		        CONFIG.DataPath .. "buildx.002",
				CONFIG.DataPath .. "buildy.002"};

	--各种贴图文件名。这里只给出文件名，扩展名必须为idx/grp
	CC.MMAPPicFile = {CONFIG.DataPath .. "mmap.idx", CONFIG.DataPath .. "mmap.grp"}
	CC.SMAPPicFile = {CONFIG.DataPath .. "smap.idx", CONFIG.DataPath .. "smap.grp"}
	CC.WMAPPicFile = {CONFIG.DataPath .. "wmap.idx", CONFIG.DataPath .. "wmap.grp"}
	CC.EFTFile = {CONFIG.DataPath .. "eft.idx", CONFIG.DataPath .. "eft.grp"}
	CC.BJ = {CONFIG.DataPath .. "bj.idx", CONFIG.DataPath .. "bj.grp"}
	CC.FightPicFile = {CONFIG.DataPath .. "fight/fight%03d.idx", CONFIG.DataPath .. "fight/fight%03d.grp"}

	CC.BodyPath = CONFIG.DataPath .. "body/";
	CC.BodyNum = 1110;
	CC.HeadPath = CONFIG.DataPath .. "head/";
	CC.HeadNum = 1110;
	CC.ThingPicFile = {CONFIG.DataPath .. "thing.idx", CONFIG.DataPath .. "thing.grp"}
	
	CC.IconPath = CONFIG.DataPath .. "icons/";
	CC.IconNum = 1010;
  	CC.XTPath = CONFIG.DataPath .. "xt/";  
	CC.XTNum = 1100;	
	CC.UIPath = CONFIG.DataPath .. "ui/";
	CC.UINum = 1100;
	
	CC.PTPath = CONFIG.DataPath .. "portrait/";
	CC.PTNum = 1100;
	
	if CONFIG.MP3 == 1 then
		CC.MIDIFile=CONFIG.SoundPath .. "game%02d.mp3";
	else
		CC.MIDIFile=CONFIG.SoundPath .. "game%02d.mid";
	end
	CC.OGGFile=CONFIG.SoundPath .. "game%02d.ogg";
	CC.ATKFile=CONFIG.SoundPath .. "atk%02d.wav";
	CC.EFile=CONFIG.SoundPath .. "e%02d.wav";

	CC.WarFile=CONFIG.DataPath .. "war.sta";
	CC.WarMapFile={CONFIG.DataPath .. "warfld.idx",
                  CONFIG.DataPath .. "warfld.grp"};

	CC.TRP = CONFIG.DataPath.."talk.grp"
	CC.TDX = CONFIG.DataPath.."talk.idx"
	
	CC.Acvmts = CONFIG.DataPath .. "achievements"

	--定义记录文件R×结构。  lua不支持结构，无法直接从二进制文件中读取，因此需要这些定义，用table中不同的名字来仿真结构。
	CC.TeamNum=15;          --队伍人数
	CC.MyThingNum=400      --主角物品数量

	CC.Week = 1
	--CC.ItemInfoPath = CONFIG.ScriptPath .. "ItemInfo/"
	
	--版本号
	CC.Version="版本 除夕版"
   
	--动态显示提示
	CC.Timer={
						stime=0,
						status=0,
						str='',
						len=0,
						fun=demostr,
					};
	--动态显示的内容
	CC.RUNSTR={
							'快捷键 F1-马车 F3-队列 F4-整理物品 H-回家',
							'多培养一些队友，可以让你后面的战斗更轻松',
							'千年灵芝是能增加体质的药品，人物体质跟主运内功决定人物生命最大值，体质最多可以提升到10点',
							'更新下载问题反馈请加 QQ群号：198045761',
							'本游戏部分素材取自铁血丹心论坛/游侠网/人在江湖/金书红颜录',
							'小村的厨灶和炼丹炉可以制作药品',							
						};
	CC.TJMSJ = {} 
	CC.TJM = 0
    CC.HSLJ = {}
	CC.HSLJ2 = {}

	CC.commodity = {
		{343,600,0,'可重新选择天赋內功',0},
		{344,600,0,'可重新选择天赋轻功',0},
		{345,600,0,'可重新选择天赋外功',0},
		{346,500,0,'可使用四大山战斗模型',0},
	}

	rest()
	CC.Base_S={};         --保存基本数据的结构，以便以后存取
	CC.Base_S["乘船"]={0,0,2}   -- 起始位置(从0开始)，数据类型(0有符号 1无符号，2字符串)，长度
	CC.Base_S["无用"]={2,0,2};
	CC.Base_S["人X"]={4,0,2};
	CC.Base_S["人Y"]={6,0,2};
	CC.Base_S["人X1"]={8,0,2};
	CC.Base_S["人Y1"]={10,0,2};
	CC.Base_S["人方向"]={12,0,2};
	CC.Base_S["船X"]={14,0,2};
	CC.Base_S["船Y"]={16,0,2};
	CC.Base_S["船X1"]={18,0,2};
	CC.Base_S["船Y1"]={20,0,2};
	CC.Base_S["船方向"]={22,0,2};
	CC.Base_S["难度"]={24,0,2};
	CC.Base_S["标准"]={26,0,2};
	CC.Base_S["畅想"]={28,0,2};
	CC.Base_S["特殊"]={30,0,2};
	CC.Base_S["单通"]={32,0,2};
	CC.Base_S["周目"]={34,0,2};
	CC.Base_S["天书数量"]={36,0,2};
	CC.Base_S["武功数量"]={38,0,2};
	CC.Base_S["备用6"]={40,0,2};	
	CC.Base_S["备用5"]={42,0,2};	
	CC.Base_S["备用4"]={44,0,2};	
	CC.Base_S["备用3"]={46,0,2};	
	CC.Base_S["备用2"]={48,0,2};	
	CC.Base_S["备用1"]={50,0,2};	
	for i=1,CC.TeamNum do
		CC.Base_S["队伍" .. i]={52+2*(i-1),0,2};
	end

	for i=1,CC.MyThingNum do
		CC.Base_S["物品" .. i]={82+4*(i-1),0,2};
		CC.Base_S["物品数量" .. i]={82+4*(i-1)+2,0,2};
	end

   CC.PersonSize=274;   --每个人物数据占用字节
    CC.Person_S={};      --保存人物数据的结构，以便以后存取
    CC.Person_S["代号"]={0,0,2}
    CC.Person_S["头像代号"]={2,0,2}
    CC.Person_S["生命增长"]={4,0,2}
    CC.Person_S["无用"]={6,0,2}
    CC.Person_S["姓名"]={8,2,10}
    CC.Person_S["外号"]={18,2,10}
    CC.Person_S["性别"]={28,0,2}
    CC.Person_S["等级"]={30,0,2}
    CC.Person_S["经验"]={32,1,2}
    CC.Person_S["生命"]={34,0,2}
    CC.Person_S["生命最大值"]={36,0,2}
    CC.Person_S["受伤程度"]={38,0,2}
    CC.Person_S["中毒程度"]={40,0,2}
    CC.Person_S["体力"]={42,0,2}
    CC.Person_S["物品修炼点数"]={44,0,2}
    CC.Person_S["武器"]={46,0,2}
    CC.Person_S["防具"]={48,0,2}

	for i=1,5 do
		CC.Person_S["出招动画帧数" .. i]={50+2*(i-1),0,2};
        CC.Person_S["出招动画延迟" .. i]={60+2*(i-1),0,2};
        CC.Person_S["武功音效延迟" .. i]={70+2*(i-1),0,2};
	end

    CC.Person_S["内力性质"]={80,0,2}
    CC.Person_S["内力"]={82,0,2}
    CC.Person_S["内力最大值"]={84,0,2}
    CC.Person_S["攻击力"]={86,0,2}
    CC.Person_S["轻功"]={88,0,2}
    CC.Person_S["防御力"]={90,0,2}
    CC.Person_S["医疗能力"]={92,0,2}
    CC.Person_S["用毒能力"]={94,0,2}
    CC.Person_S["解毒能力"]={96,0,2}
    CC.Person_S["抗毒能力"]={98,0,2}
    CC.Person_S["拳掌功夫"]={100,0,2}
	CC.Person_S["指法技巧"]={102,0,2}
    CC.Person_S["御剑能力"]={104,0,2}
    CC.Person_S["耍刀技巧"]={106,0,2}
    CC.Person_S["特殊兵器"]={108,0,2}
    CC.Person_S["暗器技巧"]={110,0,2}
    CC.Person_S["武学常识"]={112,0,2}
    CC.Person_S["品德"]={114,0,2}
    CC.Person_S["攻击带毒"]={116,0,2}
    CC.Person_S["左右互搏"]={118,0,2}
    CC.Person_S["声望"]={120,0,2}
    CC.Person_S["资质"]={122,0,2}
    CC.Person_S["修炼物品"]={124,0,2}
    CC.Person_S["修炼点数"]={126,0,2}

    for i=1,15 do
       CC.Person_S["武功" .. i]={128+2*(i-1),0,2};
        CC.Person_S["武功等级" .. i]={158+2*(i-1),0,2};
    end

    for i=1,4 do
        CC.Person_S["携带物品" .. i]={188+2*(i-1),0,2};
        CC.Person_S["携带物品数量" .. i]={196+2*(i-1),0,2};
    end
	
	for i=1,4 do
		CC.Person_S["天赋外功"..i]={204+2*(i-1),0,2};
	end
	
	CC.Person_S["天赋内功"]={212,0,2}
	CC.Person_S["天赋轻功"]={214,0,2}
	CC.Person_S["实战"]={216,0,2}
	CC.Person_S["出战"]={218,0,2}
	CC.Person_S["休战"]={220,0,2}
	CC.Person_S["主运内功"]={222,0,2}
	CC.Person_S["主运轻功"]={224,0,2}
	CC.Person_S["六如觉醒"]={226,0,2}
	CC.Person_S["个人觉醒"]={228,0,2}
	CC.Person_S["畅想分阶"]={230,0,2}
	CC.Person_S["外号2"]={232,2,10}
	CC.Person_S["冰封程度"]={242,0,2}
	CC.Person_S["血量翻倍"]={244,0,2}
	CC.Person_S["论剑奖励"]={246,0,2}
	CC.Person_S["灼烧程度"]={248,0,2}
	CC.Person_S["行为模式"]={250,0,2}
	CC.Person_S["优先使用"]={252,0,2}
	CC.Person_S["是否吃药"]={254,0,2}
	CC.Person_S["生命阈值"]={256,0,2}
	CC.Person_S["内力阈值"]={258,0,2}
	CC.Person_S["体力阈值"]={260,0,2}
	CC.Person_S["禁用自动"]={262,0,2}
	CC.Person_S["特色指令"]={264,0,2}
	CC.Person_S["坐骑"]={266,0,2}
	CC.Person_S["中庸"]={268,0,2}
	CC.Person_S["半身像"]={270,0,2}
	CC.Person_S["迷踪步"]={272,0,2}
	
    CC.ThingSize=200;   --每个人物数据占用字节
    CC.Thing_S={};
    CC.Thing_S["代号"]={0,0,2}
    CC.Thing_S["名称"]={2,2,20}
    CC.Thing_S["名称2"]={22,2,20}
    CC.Thing_S["物品说明"]={42,2,30}
    CC.Thing_S["练出武功"]={72,0,2}
    CC.Thing_S["暗器动画编号"]={74,0,2}
    CC.Thing_S["使用人"]={76,0,2}
    CC.Thing_S["装备类型"]={78,0,2}
    CC.Thing_S["显示物品说明"]={80,0,2}
    CC.Thing_S["类型"]={82,0,2}
    CC.Thing_S["未知5"]={84,0,2}
    CC.Thing_S["未知6"]={86,0,2}
    CC.Thing_S["未知7"]={88,0,2}
    CC.Thing_S["加生命"]={90,0,2}
    CC.Thing_S["加生命最大值"]={92,0,2}
    CC.Thing_S["加中毒解毒"]={94,0,2}
    CC.Thing_S["加体力"]={96,0,2}
    CC.Thing_S["改变内力性质"]={98,0,2}
    CC.Thing_S["加内力"]={100,0,2}
    CC.Thing_S["加内力最大值"]={102,0,2}
    CC.Thing_S["加攻击力"]={104,0,2}
    CC.Thing_S["加轻功"]={106,0,2}
    CC.Thing_S["加防御力"]={108,0,2}
    CC.Thing_S["加医疗能力"]={110,0,2}
    CC.Thing_S["加用毒能力"]={112,0,2}
    CC.Thing_S["加解毒能力"]={114,0,2}
    CC.Thing_S["加抗毒能力"]={116,0,2}
    CC.Thing_S["加拳掌功夫"]={118,0,2}
	CC.Thing_S["加指法技巧"]={120,0,2}	
    CC.Thing_S["加御剑能力"]={122,0,2}
    CC.Thing_S["加耍刀技巧"]={124,0,2}
    CC.Thing_S["加特殊兵器"]={126,0,2}
    CC.Thing_S["加暗器技巧"]={128,0,2}
    CC.Thing_S["加武学常识"]={130,0,2}
    CC.Thing_S["加品德"]={132,0,2}

    CC.Thing_S["加攻击次数"]={134,0,2}
    CC.Thing_S["加攻击带毒"]={136,0,2}
    CC.Thing_S["仅修炼人物"]={138,0,2}
    CC.Thing_S["需内力性质"]={140,0,2}
    CC.Thing_S["需内力"]={142,0,2}
    CC.Thing_S["需攻击力"]={144,0,2}
    CC.Thing_S["需轻功"]={146,0,2}
    CC.Thing_S["需用毒能力"]={148,0,2}
    CC.Thing_S["需医疗能力"]={150,0,2}
    CC.Thing_S["需解毒能力"]={152,0,2}
    CC.Thing_S["需拳掌功夫"]={154,0,2}	
	CC.Thing_S["需指法技巧"]={156,0,2}	
    CC.Thing_S["需御剑能力"]={158,0,2}
    CC.Thing_S["需耍刀技巧"]={160,0,2}
    CC.Thing_S["需特殊兵器"]={162,0,2}
    CC.Thing_S["需暗器技巧"]={164,0,2}

    CC.Thing_S["需资质"]={166,0,2}
    CC.Thing_S["需经验"]={168,0,2}
    CC.Thing_S["练出物品需经验"]={170,0,2}
    CC.Thing_S["需材料"]={172,0,2}

    for i=1,5 do
		CC.Thing_S["练出物品" .. i]={174+2*(i-1),0,2};
		CC.Thing_S["需要物品数量" .. i]={184+2*(i-1),0,2};
	end
	 
	CC.Thing_S["是否特效"]={194,0,2}
	CC.Thing_S["装备经验"]={196,0,2}
	CC.Thing_S["装备等级"]={198,0,2}
	
    CC.SceneSize=54;   --每个场景数据占用字节
    CC.Scene_S={};
    CC.Scene_S["代号"]={0,0,2}
    CC.Scene_S["名称"]={2,2,10}
    CC.Scene_S["出门音乐"]={12,0,2}
    CC.Scene_S["进门音乐"]={14,0,2}
    CC.Scene_S["跳转场景"]={16,0,2}
    CC.Scene_S["进入条件"]={18,0,2}
    CC.Scene_S["外景入口X1"]={20,0,2}
    CC.Scene_S["外景入口Y1"]={22,0,2}
    CC.Scene_S["外景入口X2"]={24,0,2}
    CC.Scene_S["外景入口Y2"]={26,0,2}
    CC.Scene_S["入口X"]={28,0,2}
    CC.Scene_S["入口Y"]={30,0,2}
    CC.Scene_S["出口X1"]={32,0,2}
    CC.Scene_S["出口X2"]={34,0,2}
    CC.Scene_S["出口X3"]={36,0,2}
    CC.Scene_S["出口Y1"]={38,0,2}
    CC.Scene_S["出口Y2"]={40,0,2}
    CC.Scene_S["出口Y3"]={42,0,2}
    CC.Scene_S["跳转口X1"]={44,0,2}
    CC.Scene_S["跳转口Y1"]={46,0,2}
    CC.Scene_S["跳转口X2"]={48,0,2}
    CC.Scene_S["跳转口Y2"]={50,0,2}
	CC.Scene_S["场景类型"]={52,0,2}

    CC.WugongSize=146;   --每个武功数据占用字节
    CC.Wugong_S={};
    CC.Wugong_S["代号"]={0,0,2}
    CC.Wugong_S["名称"]={2,2,10}
    CC.Wugong_S["未知1"]={12,0,2}
    CC.Wugong_S["未知2"]={14,0,2}
    CC.Wugong_S["未知3"]={16,0,2}
    CC.Wugong_S["未知4"]={18,0,2}
    CC.Wugong_S["未知5"]={20,0,2}
    CC.Wugong_S["出招音效"]={22,0,2}
    CC.Wugong_S["武功类型"]={24,0,2}
    CC.Wugong_S["武功动画&音效"]={26,0,2}
    CC.Wugong_S["伤害类型"]={28,0,2}
    CC.Wugong_S["攻击范围"]={30,0,2}
    CC.Wugong_S["消耗内力点数"]={32,0,2}
    CC.Wugong_S["敌人中毒点数"]={34,0,2}

    for i=1,10 do
		CC.Wugong_S["攻击力" .. i]={36+2*(i-1),0,2};
		CC.Wugong_S["移动范围" .. i]={56+2*(i-1),0,2};
		CC.Wugong_S["杀伤范围" .. i]={76+2*(i-1),0,2};
		CC.Wugong_S["加内力" .. i]={96+2*(i-1),0,2};
		CC.Wugong_S["杀内力" .. i]={116+2*(i-1),0,2};
    end
	 
	CC.Wugong_S["冰封系数"]={136,0,2}
	CC.Wugong_S["灼烧系数"]={138,0,2}
    CC.Wugong_S["灵巧系数"]={140,0,2}
    CC.Wugong_S["力敌系数"]={142,0,2}
    CC.Wugong_S["普通系数"]={144,0,2}	
	CC.ShopSize=36;   --每个小宝商店数据占用字节
	CC.Shop_S={};
	for i=1,6 do
		CC.Shop_S["物品" .. i]={0+2*(i-1),0,2};
		CC.Shop_S["物品数量" .. i]={12+2*(i-1),0,2};
		CC.Shop_S["物品价格" .. i]={24+2*(i-1),0,2};
	end

	CC.ShopScene={};       --小宝商店场景数据，sceneid 场景id，d_shop 小宝位置D*, d_leave 小宝离开D*，一般在场景出口，路过触发
	CC.ShopScene[0]={sceneid=1,d_shop=16,d_leave={17,18}, };
	CC.ShopScene[1]={sceneid=3,d_shop=14,d_leave={15,16}, };
	CC.ShopScene[2]={sceneid=40,d_shop=20,d_leave={21,22}, };
	CC.ShopScene[3]={sceneid=60,d_shop=16,d_leave={17,18}, };
	CC.ShopScene[4]={sceneid=61,d_shop=9,d_leave={10,11,12}, };

	--其他常量
	CC.MWidth=480;       --主地图宽
	CC.MHeight=480;      --主地图高

	CC.SWidth=64;     --子场景地图大小
	CC.SHeight=64;

	CC.DNum=200;       --D*每个场景的事件数

	CC.XScale=CONFIG.XScale;    --贴图一半的宽高
	CC.YScale=CONFIG.YScale;


	CC.Frame=CONFIG.FrameRate;     --每帧毫秒数
	CC.BattleDelay=CONFIG.BattleDelay;     --战斗点数显示的延迟（毫秒）
	CC.Bj = CONFIG.Bj;
	CC.SceneMoveFrame=100;           --场景移动帧速，用于场景移动事件
	CC.PersonMoveFrame=100;          --主角移动速度，用于主角移动事件
	CC.AnimationFrame=150;           --动画显示帧速，用于显示动画事件

	CC.WarAutoDelay=300;                   --自动战斗时显示头像的延时

	CC.DirectX={0,1,-1,0};  --不同方向x，y的加减值，用于走路改变坐标值
	CC.DirectY={-1,0,0,1};

	CC.MyStartPicM=2501;      --男主角走路起始贴图
	CC.MyStartPicF=5001;      --女主角走路起始贴图
	CC.BoatStartPic=3715;    --船起始贴图

	CC.Level=30;                  ---人物等级和每等级经验
	CC.Exp={   50,    150,     300 ,500   , 750 ,
               1050,  1400,   1800 ,2250  , 2750 ,
               3850,  5050,   6350 ,7750  , 9250 ,
               10850, 12550, 14350 ,16750 , 18250 ,
               21400, 24700, 28150 ,31750 , 35500 ,
	           39400, 43450, 47650 ,52000 , 60000 , [0] = 0 };

    CC.MMapBoat={};    --主地图船可以进入的贴图
	local tmpBoat={ {0x166,0x16a},{0x176,0x17c},{0x1ca,0x1d0},{0x1fa,0x262},{0x3f8,0x3fe},};
    for i,v in ipairs(tmpBoat) do      --把这些数据变换成数组，其中有值就是可以进入
        for j=v[1],v[2],2 do
            CC.MMapBoat[j]=1;
        end
    end
	--Alungky 解决船开到深海区时，显示为人的问题
	local tmpForbid={{0x264,0x29E}}
    for i,v in ipairs(tmpForbid) do    
        for j=v[1],v[2],2 do
			CC.MMapBoat[j]=1;
        end
    end

    CC.SceneWater={};    --场景人不能进入的贴图
    local tmpWater={ {0x166,0x16a},{0x176,0x17c},{0x1ca,0x1d0},{0x1fa,0x262},{0x332,0x338},
                     {0x346,0x346},{0x3a6,0x3a8},{0x3f8,0x3fe},{0x52c,0x544},};
    for i,v in ipairs(tmpWater) do      --把这些数据变换成数组，其中空项就是可以进入的贴图
        for j=v[1],v[2],2 do
            CC.SceneWater[j]=1;
        end
    end

    CC.WarWater={};    --战斗地图人不能进入的贴图
    local tmpWater={ {0x166,0x16a},{0x176,0x17c},{0x1ca,0x1d0},{0x1fa,0x262},{0x332,0x338},
                     {0x346,0x346},{0x3a6,0x3a8},{0x3f8,0x3fe},{0x52c,0x544},};
    for i,v in ipairs(tmpWater) do      --把这些数据变换成数组，其中空项就是可以进入的贴图
        for j=v[1],v[2],2 do
            CC.WarWater[j]=1;
        end
    end

--武功招式
CC.KFMove={}
--白虹掌力4招
CC.KFMove[202]={
{'隐若白虹起',1200},
{'呼气兮成白虹',1200},
{'白虹为贯日',1200},
{'薄暮垂虹去',1200}
}
--寒袖拂穴4招
CC.KFMove[201]={
{'春寒乍暖',1200},
{'寒泉滞骨',1200},
{'独立寒秋',1200},
{'寒月笼纱',1200}
}
--岳家枪法4招
CC.KFMove[200]={
{'锁喉枪',1400},
{'一夫当关',1400},
{'枕戈待旦',1400},
{'烽火连城',1400}
}
--岳王散手4招
CC.KFMove[198]={
{'黑虎剪尾',1100},
{'上动不停',1100},
{'饱虎登山',1200},
{'黑虎剪',1200}
}
--无极玄功拳3招
CC.KFMove[197]={
{'冲天炮',1100},
{'铁牛耕地',1100},
{'仙鹤亮翅',1200}
}

--擒龙手3招
CC.KFMove[187]={
{'羚羊挂角',1100},
{'倏然而至',1100},
{'徒手擒龙',1200}
}
--猿公剑法4招
CC.KFMove[188]={
{'剑气长空',1400},
{'剑灵寰宇',1400},
{'剑主天地',1400},
{'剑破苍穹',1400}
}
--般若掌法4招
CC.KFMove[189]={
{'童子拜佛',1400},
{'礼戒四参',1400},
{'一拍两散',1400},
{'大梵般若',1400}
}
--追魂夺命剑招式
CC.KFMove[192]={
{'孟婆灌汤',1300},
{'一剑封喉',1300},
{'神驼骏足',1300},
{'追魂夺命',1300}
}
--奔雷手3招
CC.KFMove[191]={
{'轰雷贯耳',1100},
{'雷鸣瓦釜',1100},
{'平地风雷',1100},
{'电闪雷鸣',1100}
}
--解牛刀法3招
CC.KFMove[193]={
{'族庖月更刀',1400},
{'良庖岁更刀',1400},
{'无厚入有间',1400},
{'游刃必有馀',1400}
}
--袈裟伏魔功8招
CC.KFMove[194]={
{'菩提上首',1400},
{'处众人天',1400},
{'龙披免难',1400},
{'国王敬信',1400},
{'众生礼拜',1400},
{'罗刹恭敬',1400},
{'天龙护佑',1400},
{'得成佛道',1400}
}

--五毒神掌1招
CC.KFMove[3]={
{'五毒摧心',700}
}
--鹰爪功2招
CC.KFMove[4]={
{'锁喉',700},
{'探目',700}
}
--寒冰绵掌1招
CC.KFMove[5]={
{'寒冰封体',700}
}
--美女拳法3招
CC.KFMove[6]={
{'红玉击鼓',700},
{'文姬归汉',700},
{'木兰弯弓',700}
}
--绵掌1招
CC.KFMove[7]={
{'绵绵不绝',700}
}
--天山六阳掌3招
CC.KFMove[8]={
{'阳歌天钧',900},
{'阳春白雪',900},
{'阳关三叠',900}
}
--白驼雪山掌1招
CC.KFMove[9]={
{'雪山白驼',800}
}
--百花错拳2招
CC.KFMove[10]={
{'红花天梦',800},
{'天池缭乱',800}
}
--九阴白骨爪1招
CC.KFMove[11]={
{'探微索隐',1100},
{'犹鬼神幽',1100},
{'六阴已极',1100},
{'冥华幻灭',1100}
}
--落英神剑掌3招
CC.KFMove[12]={
{'珞樱缤纷',900},
{'雨急风狂',900},
{'江城飞花',900}
}
--铁掌1招
CC.KFMove[13]={
{'壁立千仞',900}
}
--天山折梅手2招
CC.KFMove[14]={
{'踏雪折梅',1200},
{'天山灵鹫',1200}
}
--空明拳3招
CC.KFMove[15]={
{'深藏若虚',1200},
{'天马行空',1200},
{'空空如也',1200}
}
--太极拳3招
CC.KFMove[16]={
{'上步野马分鬃',1000},
{'提步高探马',1000},
{'白鹤晾翅',1000}
}
--一阳指3招
CC.KFMove[17]={
{'梵指南天',1200},
{'指矢天日',1200},
{'紫微伏龙',1200}
}
--弹指神通2招
CC.KFMove[18]={
{'弹指一瞬',1200},
{'踏月香华',1200}
}
--幻阴指1招
CC.KFMove[19]={
{'魔幻天阴',1000}
}
--龙爪手1招
CC.KFMove[20]={
{'捉影式',1000},
{'捕风式',1000},
{'鼓瑟式',1000}
}
--玄冥神掌2招
CC.KFMove[21]={
{'玄冥侵体',1200},
{'天地幽冥',1200},
{'天梦冥蒙',1200},
{'冰毒缭绕',1200}
}
--大金刚掌3招
CC.KFMove[22]={
{'大梵炼狱',1000},
{'九仪崩乱',1000},
{'地火燃穹',1000}
}
--七伤拳2招
CC.KFMove[23]={
{'藏离精失',1000},
{'三焦齐逆',1000}
}
--须弥山神掌3招
CC.KFMove[24]={
{'色空四显',1200},
{'无色无相',1200},
{'慑伏外道',1200}
}
--黯然销魂掌6招
CC.KFMove[25]={
{'拖泥带水',1300},
{'倒行逆施',1300},
{'行尸走肉',1300},
{'魂不守舍',1300},
{'心惊肉跳',1300},
{'六神不安',1300}
}
--松风剑法3招
CC.KFMove[27]={
{'平沙落雁',300},
{'鸿飞冥冥',300},
{'碧渊腾蛟',300}
}
--雷震剑术2招
CC.KFMove[28]={
{'轰雷掣电',300},
{'雷霆万钧',300}
}
--三分剑术3招
CC.KFMove[29]={
{'冰河倒泻',400},
{'雪中奇莲',400},
{'千岩竞秀',400}
}
--恒山剑法3招
CC.KFMove[30]={
{'万花齐放',500},
{'万卉争艳',500},
{'清澈梅花',500}
}
--泰山剑法3招
CC.KFMove[31]={
{'五大夫剑',500},
{'岱宗如何',500},
{'七星落长空',500}
}
--衡山剑法3招
CC.KFMove[32]={
{'泉鸣芙蓉',600},
{'鹤翔紫盖',600},
{'天柱云气',600}
}
--嵩山剑法3招
CC.KFMove[33]={
{'叠翠浮青',600},
{'玉进天池',600},
{'天外玉龙',600}
}
--华山剑法3招
CC.KFMove[34]={
{'苍松迎客',600},
{'金雁横空',600},
{'天坤倒悬',600}
}
--雪山剑法3招
CC.KFMove[35]={
{'雪泥鸿爪',600},
{'梅雪争春',600},
{'雪山六出',600}
}
--柔云剑法3招
CC.KFMove[36]={
{'杏花春雨',700},
{'满天花雨',700},
{'玉带围腰',700}
}
--两仪剑法2招
CC.KFMove[37]={
{'金针渡劫',800},
{'峭壁断云',800}
}
--玉萧剑法5招
CC.KFMove[38]={
{'山外清音',800},
{'金声玉振',800},
{'凤曲长鸣',800},
{'响隔楼台',800},
{'棹歌中流',800}
}

--金蛇剑法5招
CC.KFMove[40]={
{'金光蛇影',900},
{'蛇影万馈',900},
{'金蛇化龙',900},
{'灵蛇电闪',900},
{'蛇困愁城',900}
}
--倚天剑法3招
CC.KFMove[41]={
{'玉碎昙香',1000},
{'天劫俱灭',1000}, 
{'倚天照海',1000}
}
--斩流剑术招
CC.KFMove[151]={
{'一念无量',1400},
{'现世执妄',1400}, 
{'悟入幻想',1400},
{'草木成佛',1400}, 
{'天人五衰',1400},
{'六根清净',1400}, 
{'众生无情',1400},
{'生死有命',1400}, 
{'半身大悟',1400}
}

--斗转星移2招
CC.KFMove[43]={
{'星落云散',1200},
{'星光日月',1200}
}
--苗家剑法6招
CC.KFMove[44]={
{'冲天掌苏秦背剑',1000},
{'黄龙转身吐须势',1000},
{'迎门腿反劈华山',1000},
{'洗剑怀中抱月',1000},
{'上步云边摘月',1000},
{'提撩剑白鹤舒翅',1000}
}
--玄铁剑法4招
CC.KFMove[45]={
{'逆击',1500},
{'倒劈',1500},
{'顺刺',1500},
{'横削',1500}
}
--太极剑法3招
CC.KFMove[46]={
{'仙人指路',1300},
{'青龙出水',1300},
{'三环套月',1300}
}
--独孤九剑9招
CC.KFMove[47]={
{'总决式',1600},
{'破剑式',1600},
{'破枪式',1600},
{'破刀式',1600},
{'破鞭式',1600},
{'破索式',1600},
{'破掌式',1600},
{'破箭式',1600},
{'破气式',1600}
}
--辟邪剑法6招
CC.KFMove[48]={
{'指打奸邪',1300},
{'飞燕穿柳',1300},
{'花开见佛',1300}, 
{'锺馗抉目',1300}, 
{'扫荡群魔',1400},
{'紫气东来',1300}
}
--阳春白雪曲5招
CC.KFMove[185]={
{'宫',1200},
{'商',1300},
{'角',1400},
{'徵',1400},
{'羽',1400}
}
--井月八法
CC.KFMove[181]={
{'不攻',1300},
{'击奇',1300},
{'兵诈',1300},
{'棋弈',1300},
{'战定',1300},
{'用谋',1300},
{'速战',1300},
{'方圆',1400}
}
--碧海惊涛掌6招
CC.KFMove[179]={
{'长风破浪',1200,'增加200气攻'},
{'碧波汹涌',1300,'必灼烧冰封'},
{'惊涛骇浪',1400,'附加真伤实害100'},
{'白浪滔天',1400,'必暴击'},
{'波谲云诡',1400,'如果冰封>50，冻结10时序'},
{'',1600,'大范围攻击，增加气攻2000点'}
}
--无极玄易功
CC.KFMove[183]={
{'卷一.诛仙',4500},
{'卷二.灭神',4500},
{'卷三.开天',4500}, 
{'卷四.创世',4500}, 
{'卷五.涅槃',4500},
}
--九阳神功3招
CC.KFMove[106]={
{'他强由他强 清风拂山冈',1500,'造成敌方“虚弱”状态60时序'},
{'他横任他横 明月照大江',1400,'造成敌方“散功”状态20时序'},
{'狠来他自恶 一口真气足',1500,'自身“长生”回复状态100时序'}
}
--柴刀十八路2招
CC.KFMove[50]={
{'砍',500},
{'劈',500}
}
--鬼头刀法1招
CC.KFMove[52]={
{'鬼见愁',600}
}
--南山刀法2招
CC.KFMove[53]={
{'铁锁横江',600},
{'燕子入巢',600}
}
--鸳鸯刀法2招
CC.KFMove[54]={
{'云蕾花开',1200},
{'玲珑偃月',1200}
}
--狂风刀法2招
CC.KFMove[55]={
{'狂风大作',700},
{'飞沙走石',700}
}
--奇门三才刀2招
CC.KFMove[56]={
{'带醉脱靴',700},
{'奇刀单鞭式',700}
}
--慈悲刀法2招
CC.KFMove[57]={
{'放下屠刀',600},
{'立地成佛',600}
}
--修罗刀1招
CC.KFMove[58]={
{'恨意绵绵',600}
}
--五虎断门刀2招
CC.KFMove[59]={
{'白虎跳涧',600},
{'剪扑自如',600}
}
--反两仪刀法2招
CC.KFMove[60]={
{'重节守义',700},
{'万劫不复',700}
}
--金乌刀法2招
CC.KFMove[61]={
{'梅雪逢夏',700},
{'赤日炎炎',700}
}
--夫妻刀法4招
CC.KFMove[62]={
{'女貌郎才珠万斛',1200},
{'天教丽质为眷属',1200}, 
{'清风引佩下瑶台',1200}, 
{'明月照妆成金屋',1200}
}
--血刀大法3招
CC.KFMove[63]={
{'呕心沥血',800},
{'批纸削腐',800},
{'流星经天',800}
}
--玄虚刀法2招
CC.KFMove[64]={
{'玄之又玄',900}
}
--燃木刀法2招
CC.KFMove[65]={
{'钻木取火',900},
{'无名孽火',900}
}
--火焰刀法2招
CC.KFMove[66]={
{'炽炎破军',1200},
{'昊火焚天',1200}
}
--胡家刀法2招
CC.KFMove[67]={
{'穿手藏刀式',1200},
{'八方藏刀式',1200}
}
--杨家枪法3招
CC.KFMove[68]={
{'回马枪',500},
{'春雷震怒',500},
{'凤点头',500}
}
--中平枪法2招
CC.KFMove[70]={
{'中正锁喉',600},
{'枪平九洲',600}
}
--裴将军帖2招
CC.KFMove[71]={
{'大君制六合',700},
{'猛将清九垓',700}
}
--棋盘招式8招
CC.KFMove[72]={
{'紧气',800},
{'提子',800},
{'大飞',800},
{'小飞',800},
{'天元',800},
{'跳',800},
{'立',800},
{'长',800}
}
--鹤蛇八打2招
CC.KFMove[74]={
{'冲天一鹤',700},
{'仙鹤穿云',700}
}
--大剪刀2招
CC.KFMove[75]={
{'咔嚓',800},
{'我剪',800}
}
--阴阳倒乱刃2招
CC.KFMove[77]={
{"假刀非刀",1000},
{"假剑非剑",1000}
}
--黄沙万里鞭2招
CC.KFMove[78]={
{"血染黄沙",800},
{"飞沙万里",800}
}
--银索金铃2招
CC.KFMove[79]={
{"银索缠身",1100},
{"锁穴金铃",1100}
}
--打狗棒法4招
CC.KFMove[80]={
{'棒打狗头',1400},
{'反截狗臀',1400},
{'獒口夺杖',1400},
{'棒打双犬',1400}
}
--灵蛇杖法2招
CC.KFMove[81]={
{'怪蟒翻身',1400},
{'毒蛇吐信',1400}
}
--金刚伏魔圈4招
CC.KFMove[82]={
{'祗园精舍',1200},
{'诸行无常',1200},
{'娑罗双树',1200}, 
{'幻梦一场',1200}
}
--无上大力杵3招
CC.KFMove[83]={
{'力战千钧',1200},
{'拔山填海',1200},
{'千钧压顶',1200}
}
--倚天屠龙功6招
CC.KFMove[84]={
{'武林至尊',1100},
{'宝刀屠龙',1100},
{'号令天下',1100},
{'莫敢不从',1100},
{'倚天不出',1100},
{'谁与争锋',1100}
}
--伏魔杖法2招
CC.KFMove[86]={
{'天魔降伏',1100},
{'降龙伏虎',1100}
}
--太玄神功5招
CC.KFMove[102]={
{'赵客缦胡缨 吴钩霜雪明',1200},
{'银鞍照白马 飒沓如流星',1200},
{'三杯吐然诺 五岳倒为轻',1200},
{'纵死侠骨香 不惭世上英',1200},
{'谁能书阁下 白首太玄经',1200}
}	
--野球拳3招
CC.KFMove[109]={
{'石头',1200},
{'剪子',1200},
{'布',1200}
}
--神山剑法3招
CC.KFMove[110]={
{'神洲移山剑',1200},
{'神洲镇山剑',1200},
{'神洲擎山剑',1200}
}
--西瓜刀法3招
CC.KFMove[111]={
{'切瓜',1200},
{'剁瓜',1200},
{'砍瓜',1200}
}
--犽月流空2招
CC.KFMove[112]={
{'月犽流',1200},
{'月骁流',1200}
}
--连城剑法4招
CC.KFMove[114]={
{'故人西辞黄鹤楼',900},
{'烟花三月下扬州',900},
{'孤帆远影碧空尽',900},
{'唯见长江天际流',900}
}
--三花聚顶掌1招
CC.KFMove[115]={
{'天虹倒划',700}
}
--化骨绵掌1招
CC.KFMove[118]={
{'百鬼恸哭',1000}
}
--冰蚕毒掌1招
CC.KFMove[120]={
{'冰毒缭绕',1100}
}
--凝血神爪2招
CC.KFMove[134]={
{'风驰电掣',1000},
{'逆挽天华',1000}
}
--大力金刚指2招
CC.KFMove[135]={
{'金刚揭谛',700},
{'金刚震脉',700}
}
--无相劫指2招
CC.KFMove[136]={
{'天地玄黄',1300},
{'天火焚城',1300}
}
--参合指6招
CC.KFMove[138]={
{'国破山河在，城春草木深',1500},
{'感时花溅泪，恨别鸟惊心',1500},
{'锋火连三月，兵败参合陂',1500},
{'白头搔更短，浑欲不胜簪',1500},
{'夜来参星斗，天命何所归',1500},
{'顾盼子孙贤，铭记复国志',1500}
}
--玉女素心剑6招
CC.KFMove[139]={
{'清饮小酌',1100},
{'浪迹天涯',1100},
{'举案齐眉',1100},
{'皓腕玉镯',1100},
{'冷月窥人',1100},
{'竹帘临池',1100}
}
--达摩剑法1招
CC.KFMove[140]={
{'天罗地煞',1000}
}
--百胜刀法2招
CC.KFMove[141]={
{'却月天戈',1000},
{'孤月寒江',1000}
}
--妙笔丹青1招
CC.KFMove[142]={
{'神封太渊',1200}
}
--沧溟刀法2招
CC.KFMove[153]={
{'素月分辉',1200},
{'银河共影',1200}
}
--越女剑法4招
CC.KFMove[156]={
{'电照长空',1500},
{'仙猿剑舞',1500},
{'诛天凌神',1500},
{'天仙剑影',1500}
}
--枣核钉1招
CC.KFMove[157]={
{'瞬狱一杀',1000}
}
--五轮大转2招
CC.KFMove[158]={
{'天罡震烈',1300},
{'天舞宝轮',1300}
}
--苍狼战戟2招
CC.KFMove[159]={
{'魔澜惊炽',2000},
{'罗摩沌灭',2000}
}
--玄女剑法1招
CC.KFMove[161]={
{'碧落穹苍',1200},
{'飞花逐蝶',1200}
}
--狂风快剑2招
CC.KFMove[162]={
{'一叶扁舟',1300},
{'天外飞龙',1300},
{'风驰云卷',1300},
{'长风破浪',1300},
{'疾风骤雨',1300},
{'狂风怒号',1300}
}
--白蟒鞭法1招
CC.KFMove[164]={
{'残烛引月',1200}
}
--青莲剑法10招
CC.KFMove[167]={
{'长风万里送秋雁',1200},
{'对此可以酣高楼',1200},
{'蓬莱文章建安骨',1200},
{'中间小谢又清发',1200},
{'俱怀逸兴壮思飞',1200},
{'欲上青天览明月',1200},
{'抽刀断水水更流',1200},
{'举杯消愁愁更愁',1200},
{'人生在世不称意',1200},
{'明朝散发弄扁舟',1200}
}
--逍遥神剑2招
CC.KFMove[168]={
{'蓬莱仙梦',1600},
{'百剑无终',1600}
}

--达摩神掌4招
CC.KFMove[173]={
{'亿万小时',3000},
{'精心打磨',3000},
{'国产绿色',3000},
{'休闲单机',3000}
}

--阴风刀2招
CC.KFMove[174]={
{'阴风阵阵',1200},
{'利刃寒锋',1200}
}

--烈火剑法1招
CC.KFMove[176]={
{'天灰地烬',2000}
}
--追魂压命剑法3招
CC.KFMove[183]={
{'剑一.封喉',2000},
{'剑二.追魂',2000},
{'剑三.夺命',2000}
}

--追魂压命剑法3招
CC.KFMove[222]={
{'三环套月',1500},
{'无我无剑',1500},
{'天地无极',1500},
{'八荒归元',1500},
}

--葵花点穴手
CC.KFMove[226]={
{'势如疾风',1200},
{'快如闪电',1200},
{'葵花点穴',1200}
}

--离队人员列表: {人员id，离队调用函数}      ----如果有新的离队人员加入，直接在这里增加
CC.PersonExit = {
[1]=100,
[2]=102,
[4]=104,
[9]=106,
[16]=108,
[17]=110,
[25]=112,
[28]=114,
[29]=116,
[30]=118,
[35]=120,
[36]=122,
[37]=124,
[38]=126,
[44]=128,
[45]=130,
[47]=132,
[48]=134,
[49]=136,
[51]=138,
[52]=140,
[53]=142,
[54]=144,
[55]=146,
[56]=148,
[58]=150,
[59]=152,
[63]=154,
[66]=156,
[72]=158,
[73]=160,
[74]=162,
[75]=164,
[76]=166,
[77]=168,
[78]=170,
[79]=172,
[80]=174,
[81]=176,
[82]=178,
[83]=180,
[84]=182,
[85]=184,
[86]=186,
[87]=188,
[88]=190,
[89]=192,
[90]=194,
[91]=196,
[92]=198,
[151]=11004,
[154]=11002,
[161]=4183,
[566]=11006,
[569]=11003,
[574]=11005,
[589]=8005,  --水笙
[590]=8650,
[601]=4138,
[604]=11001,
[607]=4202,	--焦万尔
[609]=4250,	--赵敏
[626]=4184,	--郭襄
[629]=4200,	--阿九
[646]=4249,	--殷离
	
}

    --所有可加入人员离队需要清除的D*事件，清除后这些人就找不到了。得到神杖时使用
    CC.AllPersonExit={ 
             {1, 5}, 
			{2, 6}, 
			{4, 21}, 
			{9, 17}, 
			{16, 31}, 
			{17, 32}, 
			{25, 28}, 
			{28, 29}, 
			{29, 26}, 
			{30, 13}, 
			{35, 15}, 
			{36, 25}, 
			{37, {7,8}}, 
			{38, {16,58}}, 
			{44, 33}, 
			{45, 12}, 
			{47, 23}, 
			{48, 24}, 
			{49, {10,11}}, 
			{51, 22}, 
			{52, 41}, 
			{53, 9}, 
			{54, 18}, 
			{55, 13}, 
			{56, 14}, 
			{58, 19}, 
			{59, 20}, 
			{63, 30}, 
			{66, 38}, 
			{72, 40}, 
			{73, 35}, 
			{74, 36}, 
			{75, 37}, 
			{76, 27}, 
			{77, 39}, 
			{78, 59}, 
			{79, 42}, 
			{80, 52}, 
			{81, 46}, 
			{82, 54}, 
			{83, 55}, 
			{84, 34}, 
			{85, 47}, 
			{86, 49}, 
			{87, 50}, 
			{88, 43}, 
			{89, 44}, 
			{90, 53}, 
			{91, 51}, 	
			{92, 1},
			{151, 115},	--文泰来
			{154, 112},	--骆冰
			{161, 99},	--李莫愁
			{566, 117},--袁冠南
			{569, 113},	--李沅芷
			{574, 110},	--李清露
			{589, 80}, --水笙
			{590, 86}, --李文秀
			{601, 48},	--韦小宝
			{604, 100},	--阿青
			{609, 105},	--赵敏
			{626, 120},	--郭襄
			{629, 51},	--阿九			
			{646, 106},	--殷离								
			};

    CC.BookNum=14;               --天书个数
    CC.BookStart=144;            --14天书起始物品id

    CC.MoneyID=174;              --金钱物品id
    CC.Shemale = {[93] = 1}

	--特效帧数
	CC.Effect = {
	14, 	--特效1 Blue puff
	17, 	--特效2 Water drop
	9, 		--特效3 Thin yellow line with tiny pink circle at bottom
	13, 	--特效4 Tiny yellow splashing
	17, 	--特效5 Water drop with thunder like effect
	17, 	--特效6 Water drop with thunder like effect + yellow flames rising
	17, 	--特效7 Vertical red flame fading
	18, 	--特效8	Ice falling then breaking
	19, 	--特效9 Bright yellow explotion smoke
	19, 	--特效10 yellow flames rising
	15, 	--特效11 Small blood spilling
	13, 	--特效12 Small blood spilling (fewer frames)
	10, 	--特效13 Black half circle splashing
	10, 	--特效14 Red half circle splashing
	15, 	--特效15 Tiny tornado exploding
	21, 	--特效16 blood spilling with tiny yellow explotion
	16, 	--特效17
	9, 		--特效18
	11, 	--特效19
	8, 		--特效20
	9, 		--特效21
	8, 		--特效22
	8, 		--特效23
	7, 		--特效24
	8, 		--特效25
	8, 		--特效26
	9, 		--特效27
	12, 	--特效28
	19, 	--特效29
	11, 	--特效30
	14, 	--特效31 Yellow puff
	12, 	--特效32
	17, 	--特效33
	8, 		--特效34
	11, 	--特效35
	10, 	--特效36
	13, 	--特效37
	10, 	--特效38 
	19, 	--特效39 Bright yellow mushroom cloud
	14, 	--特效40
	17, 	--特效41
	19, 	--特效42
	14, 	--特效43
	21, 	--特效44
	16, 	--特效45
	13, 	--特效46
	18, 	--特效47
	14, 	--特效48
	17, 	--特效49
	17, 	--特效50
	16, 	--特效51
	7, 		--特效52 Tiny mushroom cloud
	12, 	--特效53 Yellow dragon rising(badly drawn)
	40, 	--特效54 Beige ghost like smoke
	16, 	--特效55
	9, 		--特效56
	15, 	--特效57
	15, 	--特效58 Classic explotion flame
	31, 	--特效59
	38, 	--特效60 Swords falling
	24, 	--特效61
	26, 	--特效62 Swords falling(fewer and faded)
	24, 	--特效63 北冥
	20, 	--特效64 化功
	12, 	--特效65
	17, 	--特效66
	14, 	--特效67
	14, 	--特效68
	10, 	--特效69
	10, 	--特效70
	18, 	--特效71 吸星
	31, 	--特效72
	12, 	--特效73
	7, 		--特效74
	6, 		--特效75
	7, 		--特效76
	28, 	--特效77
	16, 	--特效78
	7, 		--特效79
	16, 	--特效80
	20, 	--特效81
	15, 	--特效82
	13, 	--特效83
	15, 	--特效84
	11, 	--特效85
	11, 	--特效86
	11, 	--特效87
	20, 	--特效88
	20, 	--特效89
	20, 	--特效90
	17, 	--特效91
	17, 	--特效92
	17, 	--特效93
	9, 		--特效94
	8, 		--特效95
	8, 		--特效96
	17, 	--特效97
	10, 	--特效98
	11, 	--特效99
	8, 		--特效100
	29, 	--特效101
	6, 		--特效102
	13, 	--特效103
	31, 	--特效104
	14, 	--特效105
	4, 		--特效106
	13, 	--特效107 two blades
	13, 	--特效108
	15,		--特效109
	24; 	--特效110 打狗
	20; 	--特效111 降龙
	12; 	--特效112 
	16; 	--特效113 blue serpent
	18; 	--特效114 yellow tornado
	17; 	--特效115 red lights flailing
	14; 	--特效116 ice breaking
	12; 	--特效117 dark serpent
	19; 	--特效118 Old school explotion
	16; 	--特效119 Yellow cross explotion
	12; 	--特效120 Red light rising
	14; 	--特效121 Light green explotion
	14; 	--特效122 Fire arrow
	6; 		--特效123 Devil face
	8; 		--特效124 Fire explosion
	24; 	--特效125 Light slashing
	19; 	--特效126 Yellow cosmic explosion
	16; 	--特效127 Small burning explotion
	14; 	--特效128 Heart shaped explotion
	20; 	--特效129 Violet halo
	18;		--特效130 五轮
	16;		--特效131 lightning
	13;		--特效132 bright light swords surrounding
	25;		--特效133 Flame ring
	20;		--特效134 连珠腐尸毒
	13;		--特效135 blizzard shield
	22;		--特效136 blue spiral
	35;		--特效137 Pink saber
	11;		--特效138 进阶太岳
	17;		--特效139 进阶云雾
	25;		--特效140 进阶万岳
	23;		--特效141 进阶万花
	16;		--特效142 进阶闪光的佛
	11;		--特效143 thin orange flame
	13;		--特效144 thin blue flame
	7;		--特效145 口才
	14;		--特效146 破军
	27;		--特效147 yellow halo
	16;		--特效148 poison
	14;		--特效149 倾国
	44;		--特效150 nuclear explosion
	12;		--特效151 集中
	16;		--特效152 ice entangle
	14;		--特效153 梯云纵
	18;		--特效154 fire bird
	11;		--特效155 万字
	17;		--特效156 金钟
	12;		--特效157 血骷髅
	12;		--特效158 莲花	
	17;     --特效159 太极
	14;      --特效160 --
	11;      --特效161 --
	12;      --特效162 --	剑1
	17;      --特效163 --	剑2	
	11;      --特效164 --	大剑
	9;      --特效165 --	文字
	24;      --特效166 --	八卦
	3;      --特效167 --	八卦1	
	19;      --特效168 --	酒神
	28;      --特效170 --	万佛朝宗	
	9;      --特效171 --	开太极	
	[0] = 9	--特效0	Tiny heart(when heal)
	}
	
	--装备对威力的加成
    CC.ExtraOffense = {
			{52, 75, 100},		--鳄嘴剪+大剪刀
			{45, 67, 100},		--冷月宝刀+胡刀
			{202, 67, 100},		--闯王军刀+胡刀
			{37, 41, 100},		--倚天剑+灭剑
			{49, 80, 200},		--打狗棒+打狗棒法
			{44, 63, 200},		--血刀+血刀
			{40, 40, 200},		--金蛇剑+金蛇
			{36, 45, 100},		--玄铁剑+玄铁
			{276, 155, 3000},	--火枪+火枪
			{51, 78, 200},		--金龙鞭+黄沙万里鞭法
			{50, 86, 100},		--伏魔杵+伏魔杖法
			{241, 39, 100},		--君子剑+全真剑法
			{242, 42, 100},		--淑女剑+玉女剑法
			{244, 81, 200},		--西毒蛇杖+灵蛇杖法
			{55, 110, 100},		--神山剑+神山剑法
			{56, 111, 100},		--玄铁菜刀+西瓜刀法
			{57, 112, 100},		--犽月+犽月流空
			{243, 77, 200},		--金刀黑剑+阴阳倒乱刃
			{39, 44, 100},		--白龙剑+苗家剑法
			{236, 46, 100},		--真武剑+太极剑法
			{326,156,200},
			{326,188,200},
			}

    CC.NewPersonName=CONFIG.PlayName;                --新游戏的数据
	
    CC.NewGameSceneID = 70
	CC.NewGameSceneX = 16
	CC.NewGameSceneY = 31
	CC.NewGameEvent = 691
	CC.NewPersonPicM = 2515
	CC.NewPersonPicF = 5015

	CC.PersonAttribMax = {}
	CC.PersonAttribMax["经验"] = 60000
	CC.PersonAttribMax["物品修炼点数"] = 30000
	CC.PersonAttribMax["修炼点数"] = 30000
	CC.PersonAttribMax["生命最大值"] = 9999
	CC.PersonAttribMax["受伤程度"] = 100
	CC.PersonAttribMax["中毒程度"] = 100
	CC.PersonAttribMax["内力最大值"] = 9999
	CC.PersonAttribMax["生命增长"] = 10
	CC.PersonAttribMax["体力"] = 100
	CC.PersonAttribMax["攻击力"] = 620
	CC.PersonAttribMax["防御力"] = 620
	CC.PersonAttribMax["轻功"] = 620
	CC.PersonAttribMax["医疗能力"] = 300
	CC.PersonAttribMax["用毒能力"] = 300
	CC.PersonAttribMax["解毒能力"] = 300
	CC.PersonAttribMax["抗毒能力"] = 300
	CC.PersonAttribMax["拳掌功夫"] = 420
	CC.PersonAttribMax["指法技巧"] = 420
	CC.PersonAttribMax["御剑能力"] = 420
	CC.PersonAttribMax["耍刀技巧"] = 420
	CC.PersonAttribMax["特殊兵器"] = 420
	CC.PersonAttribMax["暗器技巧"] = 420
	CC.PersonAttribMax["武学常识"] = 300
	CC.PersonAttribMax["品德"] = 120
	CC.PersonAttribMax["资质"] = 100
	CC.PersonAttribMax["攻击带毒"] = 440
	CC.PersonAttribMax["冰封程度"] = 100
	CC.PersonAttribMax["灼烧程度"] = 50
	
    CC.WarDataSize=186;         --战斗数据大小  war.sta数据结构
    CC.WarData_S={};        --战斗数据结构
    CC.WarData_S["代号"]={0,0,2};
    CC.WarData_S["名称"]={2,2,10};
    CC.WarData_S["地图"]={12,0,2};
    CC.WarData_S["经验"]={14,0,2};
    CC.WarData_S["音乐"]={16,0,2};
    for i=1,6 do
        CC.WarData_S["手动选择参战人"  .. i]={18+(i-1)*2,0,2};
        CC.WarData_S["自动选择参战人"  .. i]={30+(i-1)*2,0,2};
        CC.WarData_S["我方X"  .. i]={42+(i-1)*2,0,2};
        CC.WarData_S["我方Y"  .. i]={54+(i-1)*2,0,2};
    end
    for i=1,20 do
        CC.WarData_S["敌人"  .. i]={66+(i-1)*2,0,2};
        CC.WarData_S["敌方X"  .. i]={106+(i-1)*2,0,2};
        CC.WarData_S["敌方Y"  .. i]={146+(i-1)*2,0,2};
    end

    CC.WarWidth=64;        --战斗地图大小
    CC.WarHeight=64;

	--显示主地图和场景地图坐标
	--如果显示坐标，则会增加cpu占用。机器速度慢的话可能会卡。这个在调试时有用。
	CC.ShowXY=1      --0 不显示 1 显示


	--以下为控制显示方式的参数
	CC.MenuBorderPixel=5  -- 菜单四周边框留的像素数，也用于绘制字符串的box四周留得像素

	CC.DefaultFont=math.modf(math.min(CC.ScreenW,CC.ScreenH) / 320 * 14);
	CC.SmallFont = CC.DefaultFont*3/4;
	CC.FontBIG = math.modf(CC.DefaultFont*1.45)
	CC.FontBig = math.modf(CC.DefaultFont*1.3)
	CC.Fontbig = math.modf(CC.DefaultFont*1.15)
	CC.Fontsmall = math.modf(CC.DefaultFont*0.85)
	CC.FontSmall = math.modf(CC.DefaultFont*0.7)
	CC.FontSmall2 = math.modf(CC.DefaultFont*0.65)
	CC.FontSmall3 = math.modf(CC.DefaultFont*0.635)
	CC.FontSmall4 = math.modf(CC.DefaultFont*0.9)
	CC.FontSmall5 = math.modf(CC.DefaultFont*0.92)
	CC.FontSMALL = math.modf(CC.DefaultFont*0.55)
	CC.RowPixel = math.modf(math.min(CC.ScreenW, CC.ScreenH) / 100)

	--CC.StartMenuY= 160       --开始菜单Y坐标
	CC.StartMenuFontSize=CC.DefaultFont  --开始菜单字号

	--CC.NewGameY= 160         --新游戏属性显示Y坐标
	CC.NewGameFontSize =CC.DefaultFont   --新游戏属性选择字号


	CC.MainMenuX=10;         --主菜单开始坐标
	CC.MainMenuY=10;

	CC.GameOverX=90;
	CC.GameOverY=65;

    CC.PersonStateRowPixel= 5;    --显示人物状态行间距像素
    
    --物品显示定义
    CC.ThingFontSize = CC.Fontsmall;
		
	--CC.ThingPicWidth=math.modf(100*CONFIG.Zoom/100);    --物品图片宽高
	CC.ThingPicWidth=100	--物品图片固定尺寸
	CC.ThingPicHeight=CC.ThingPicWidth;

	local n = math.modf(CC.ScreenW/CC.ThingPicWidth-2);			--一行显示几个物品
	if n < 10 then	
		CC.MenuThingXnum = 9;				
	else
		CC.MenuThingXnum = 9
	end
		
	local m = math.modf(CC.ScreenH/CC.ThingPicHeight-2);		--物品显示几列
	if m < 5 then	
		CC.MenuThingYnum = 5;
	else
		CC.MenuThingYnum = 5;
	end

	CC.ThingGapOut=4;		--物品图像显示四周留白
	CC.ThingGapIn=4;		--物品图像显示中间间隔	

    CC.StartMenuY=CC.ScreenH-3*(CC.StartMenuFontSize+CC.RowPixel)-20;
	CC.NewGameY=CC.ScreenH-4*(CC.NewGameFontSize+CC.RowPixel)-10;

	--子菜单的开始坐标
	CC.MainSubMenuX=CC.MainMenuX+2*CC.MenuBorderPixel+2*CC.DefaultFont+5;       --主菜单为两个汉字
	CC.MainSubMenuY=CC.MainMenuY;

	--二级子菜单开始坐标
	CC.MainSubMenuX2=CC.MainSubMenuX+2*CC.MenuBorderPixel+4*CC.DefaultFont+5;   --子菜单为四个字符

	CC.SingleLineHeight=CC.DefaultFont+2*CC.MenuBorderPixel+5;  --带框的单行字符高

	CC.StartThingPic = 0
	
	CC.AutoMoveEvent = {[0]=0};		--鼠标操作时是否触发事件， 第一个位置0未触发， 1触发， 2触发并且能够走到面前， 第二和第三个位置为XY坐标
	CC.MMapAdress = {};				--大地图地址

	LMSJ = {"少商剑", "商阳剑", "中冲剑", "关冲剑", "少冲剑", "少泽剑"}
	XL18 = {"亢龙有悔", "见龙在田", "飞龙在天", "双龙出水", "神龙摆尾", "潜龙勿用"}
	XL18JY = {"极意--亢龙·鸿渐於陆", "极意--飞龙·或跃在渊", "极意--潜龙·密雨不云", "极意--神龙·震惊百里", "极意--见龙·利涉大川", "极意--双龙·突如其来", "极意--六龙·履霜冰至", "极意--龙战·损则有孚"}
	TFSSJ = {"·『天道惊雷憾』", "·『点墨山河』", "·『一剑镇神洲』", "·『羽葬煌炎斩』", "·『千机龙绝闪』", "·『斗焰罡霸劲』", "·『仁者无敌』", "·『八门聚万象』", "·『天人五衰』"}
	ZJTF = {"盖世神拳", "灵犀一指", "剑神一笑", "傲世狂刀", "奇门无双", "绝世天罡", "仁者无敌", "回天圣手", "欲天摩罗"}
	TFE = {"拳", "指", "剑", "刀", "特", "罡", "仁", "医", "毒"}
	YLJFZS = {"清饮小酌", "浪迹天涯", "举案齐眉", "皓腕玉镯", "冷月窥人", "竹帘临池"}
	QZJFZS = {"大江似练", "斜风细雨", "星河欲转", "桃花流水"}
	SJHBJFZS = {"双剑合璧--清饮小酌", "双剑合璧--浪迹天涯", "双剑合璧--举案齐眉", "双剑合璧--皓腕玉镯", "双剑合璧--冷月窥人", 
	"双剑合璧--竹帘临池","双剑合璧--大江似练", "双剑合璧--斜风细雨", "双剑合璧--星河欲转", "双剑合璧--桃花流水"}
	SHSGZS = {"石火电光", "火中取栗", "明火执仗", "引火烧身", "烽火连天", "刀山火海"}
	TSTF = {nil, "影帝"}
	--实战经验
	WARSZJY = {3, 2, 5, 2, 40, 15, 5, 5, 5, 5, 5, 5, 5, 5, 3, 2, 2,
	10, 5, 4, 4, 5, 4, 2, 2, 20, 40, 2, 3, 3, 3, 3, 3, 3, 5, 3, 4, 4,
	8, 8, 4, 4, 4, 4, 2, 5, 3, 4, 3, 30, 4, 2, 3, 3, 4, 4, 15, 5, 5,
	15, 3, 15, 3, 15, 10, 2, 8, 3, 15, 7, 8, 3, 3, 3, 4, 2, 2, 2, 2,
	4, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 7, 7, 4, 4, 2,
	2, 12, 2, 2, 2, 3, 3, 3, 3, 3, 7, 7, 50, 3, 3, 5, 6, 3, 3, 3, 3,
	3, 3, 3, 3, 3, 3, 20, 3, 3, 3, 3, 3, 3, 3, 2, 3, 2, 35, 2, 2, 2,
	2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
	3, 3, 3, 3, 3, 4, 3, 4, 4, 4, 2, 2, 2, 2, 2, 2, 2, 3, 7, 7, 4, 3, 5, 5, 3}
	--称号
	RWWH = {}
	RWWH[1] = "雪山飞狐"
	RWWH[2] = "灵枢素问"
	RWWH[3] = "金面佛"
	RWWH[4] = "雁过拨毛"
	RWWH[5] = "太极宗师"
	RWWH[6] = "灭绝师太"
	RWWH[7] = "铁琴先生"	--何太冲
	RWWH[8] = "崆峒掌门"	--唐文亮
	RWWH[9] = "九阳明尊"
	RWWH[10] = "光明右使"
	RWWH[11] = "光明左使"
	RWWH[12] = "白眉鹰王"
	RWWH[13] = "金毛狮王"
	RWWH[14] = "青翼蝠王"
	RWWH[15] = "紫衫龙王"
	RWWH[16] = "蝶谷医仙"
	RWWH[17] = "蝶谷毒仙"
	RWWH[18] = "混元霹雳手"
	RWWH[19] = "君子剑"
	RWWH[20] = "潇湘夜雨"
	RWWH[21] = "恒山掌门"
	RWWH[22] = "嵩山掌门"
	RWWH[23] = "泰山掌门"
	RWWH[24] = "青城掌门"
	RWWH[25] = "五毒教主"
	RWWH[26] = "日月魔帝"
	RWWH[27] = "风云再起"
	RWWH[28] = "杀人名医"
	RWWH[29] = "万里独行"
	RWWH[30] = "傻小子"
	RWWH[31] = "梅庄四友"
	RWWH[32] = "梅庄四友"
	RWWH[33] = "梅庄四友"
	RWWH[34] = "梅庄四友"
	RWWH[35] = "九剑传人"
	RWWH["35"] = "剑魔再临"
	RWWH[36] = "辟邪剑客"
	RWWH[37] = "真名神照"
	RWWH["38"] = "混沦太玄"
	RWWH[39] = "侠客岛主"
	RWWH[40] = "侠客岛主"
	RWWH[41] = "赏善使者"
	RWWH[42] = "罚恶使者"
	RWWH[43] = "雪山掌门"
	RWWH[44] = "凶神恶煞"
	RWWH[45] = "阎王敌"
	RWWH[46] = "星宿老怪"
	RWWH[47] = "曼珠沙华"
	RWWH[48] = "冰毒怪客"
	RWWH[49] = "小和尚"
	RWWH["49"] = "逍遥掌门"
	RWWH[50] = "狂龙天征"
	RWWH[51] = "姑苏慕容"
	RWWH[52] = "中平神枪"
	RWWH[53] = "六脉真传"
	RWWH[54] = "碧血长风"
	RWWH[55] = "侠之大者"
	RWWH[56] = "兰质蕙心"
	RWWH[57] = "桃花岛主"
	RWWH[58] = "西狂"
	RWWH[59] = "冷若天仙"
	RWWH[60] = "西毒"
	RWWH[62] = "元蒙帝师"
	RWWH[63] = "青箫落瑛"
	RWWH[64] = "顽童武痴"
	RWWH[65] = "南僧"
	RWWH[66] = "波斯圣女"
	RWWH[67] = "铁掌帮主"
	RWWH[68] = "长春子"
	RWWH[69] = "北丐"
	RWWH[71] = "神龙教主"
	RWWH[72] = "天龙掌门"
	RWWH[73] = "日月圣姑"
	RWWH[74] = "翠羽黄衫"
 	RWWH[75] = "天池红花"
	RWWH[76] = "琅嬛仙子"
	RWWH[77] = "秀外慧中"
	RWWH[78] = "铁尸魔煞"
	RWWH[79] = "慧中灵剑"
	RWWH[80] = "火手判官"
	RWWH[81] = "雪岭双姝"
	RWWH[82] = "玉面孟尝"
	RWWH[83] = "五毒教主"
	RWWH[84] = "小王爷"
	RWWH[85] = "老谋深算"
	RWWH[86] = "金枝玉叶"
	RWWH[87] = "媚眼如丝"
	RWWH[88] = "酒神"
	RWWH[89] = "食神"
	RWWH[90] = "毓秀灵姝"	
	RWWH[91] = "青青子衿"
	RWWH[92] = "扑朔迷离"
	RWWH[94] = "仁义刀"
	RWWH[95] = "柔云剑"
	RWWH[96] = "冷月剑"
	RWWH[97] = "血刀老祖"
	RWWH[98] = "恶贯满盈"
	RWWH[101] = "笔砚生"
	RWWH[102] = "天龙禅师"
	RWWH[103] = "大轮明王"
	RWWH[104] = "云舞霓裳"
	RWWH[105] = "琴韵温香"
	RWWH[106] = "金刀无敌"
	RWWH[112] = "震天魔狼"
	RWWH[113] = "参合潜龙"
	RWWH[114] = "达摩再世"
	RWWH[115] = "聪辩先生"
	RWWH[116] = "风月无间"
	RWWH[117] = "不老长春"
	RWWH[118] = "秋水无尘"
	RWWH[129] = "中神通"
	RWWH[131] = "妙手书生"
	RWWH[138] = "一指震江南"	--瓦尔拉齐
	RWWH[140] = "剑术通神"		--风清扬
	RWWH[142] = "狂风快剑"
	RWWH[149] = "少林掌门"
	RWWH[153] = "暗器之王"
	RWWH[154] = "鸳鸯刀"
	RWWH[157] = "湘西尸王"
	RWWH[158] = "波斯大贾"
	RWWH[159] = "瑜伽鬼王"
	RWWH[160] = "尊师重道"		--达尔巴
	RWWH[161] = "赤练仙子"
	RWWH[164] = "摩天居士"
	RWWH[171] = "武当儒侠"
	RWWH[185] = "神剑仙猿"
	RWWH[186] = "神拳无敌"
    RWWH[510] = '曲夕烟隙'
	RWWH[511] = '盗圣'
	RWWH[553] = "真田一之兵"
	RWWH[589] = "铃剑侠女"		--水笙
	RWWH[590] = "古道西风"		--李文秀
	RWWH[592] = "无我无剑"		--独孤求败
	RWWH[594] = "铁索横江"		--戚长发
	RWWH[601] = "天魁地宝"		--韦小宝
	RWWH[603] = "满洲勇士"		--鳌拜
	RWWH[604] = "越女剑仙"		--阿青
	RWWH[605] = "姑射仙姿"		--林朝英
	RWWH[606] = "西域战神"		--阿凡提
	RWWH[607] = "乱世浮萍"		--焦宛儿
	RWWH[609] = "绍敏郡主"		--赵敏
	RWWH[616] = "绝情谷主"		--公孙止
	RWWH[617] = "铁掌莲花"		--裘千尺
	RWWH[626] = "小东邪"		--郭襄
	RWWH["626"] = "峨眉祖师"
	RWWH[627] = "上帝之鞭"		--蒙哥
	RWWH[628] = "雕兄"			--神雕
	RWWH[629] = "长平公主"		--阿九
	RWWH[631] = "谁与争锋"		--周芷若
	RWWH[642] = "精心打磨"		--四大山
	RWWH[647] = "玄冥二老"		--鹤笔翁
	RWWH[648] = "玄冥二老"		--鹿杖客
	RWWH[649] = "华山玉女"		--宁中则
	RWWH[650] = "小王爷"		--杨康
	RWWH[651] = "影帝"			--张家辉
	RWWH[636] = "青莲剑仙"	    --李白
	RWWH[652] = "神州大侠"	    --萧秋水
	RWWH[635] = "西昆仑"	    --梁萧
	RWWH[497] = "金刚门人"	    --陆渐
	RWWH[498] = "小李探花"	    --李寻欢
	RWWH[638] = "九阳至尊"	    --斗酒僧
	RWWH[640] = "古墓后人"	    --黄衫女
	RWWH[189] = "晋阳大侠"	    --萧半和
	RWWH[633] = "辽东大侠"	    --胡一刀
	RWWH[500] = "剑神"	    --西门吹雪	
	RWWH[588] = "岛主夫人"	--冯蘅	
	RWWH[587] = "紫衣银鞭"	--袁紫衣		
	RWWH[586] = "昆仑三圣"	    --何足道
	RWWH[584] = "不哭死神"	    --
	RWWH[583] = "小尼姑"		--
	RWWH[582] = "冰川天女"		--	
	RWWH[581] = "丁丁当当"		--
	RWWH[580] = "银弧刀"		--	
	RWWH[579] = "盗王之王"	  --司空摘星	
	RWWH[637] = "九阴至尊"	  --黄赏
	RWWH[578] = "大唐双龙"	  --寇仲
	RWWH[634] = "逍遥祖师"	  --	逍遥子
	RWWH[577] = "禅宗始祖"	  --	达摩
	RWWH[569] = "小魔女"	  --	李沅芷
	RWWH[151] = "奔雷手"	  --	文泰来
	RWWH[574] = "寒露清梦"	  --萧玲
	RWWH[613] = "铁掌神鞭"	  
	RWWH[612] = "铁鞭震八方"
	RWWH[614] = "荒野游龙"	
	RWWH[615] = "玉堂飞燕"	
	RWWH[566] = "白衣书生"	
	RWWH[639] = "金蛇郎君"	--	
	RWWH[499] = "大理太祖"	--
	RWWH[313] = "天佛降世"	--	
	RWWH[658] = "天池怪侠"
	RWWH[657] = "悲天佛怜"	
	RWWH[567] = "千秋侠烈"	
	RWWH[573] = "仁阳佛光"	
	RWWH[575] = "神剑仙猿"	
	RWWH[576] = "佛门无双"	
	RWWH[641] = "圣火明尊"		
	RWWH[568] = "精忠报国"	
	RWWH[567] = "千秋侠烈"	
	RWWH[650] = "小王爷"	
	RWWH[505] = "大唐双龙"
	RWWH[504] = "太虚剑主"
	RWWH[507] = "琅琊公子"
	RWWH[508] = "琅琊公子"		
	RWWH[721] = "黄河老祖"	
	--天赋
	RWTFLB = {}
	RWTFLB[508] = "亘天赤焰"	
	RWTFLB[507] = "江左梅郎"		
	RWTFLB[505] = "九字真言"	
	RWTFLB[650] = "无妄无我"	
	RWTFLB[567] = "傲世神罡"	
	RWTFLB[568] = "决胜千里"		
	RWTFLB[641] = "魔道天行"		
	RWTFLB[576] = "无量禅震"	
	RWTFLB[575] = "闪电惊鸿"			
	RWTFLB[573] = "天域幻音"		
	RWTFLB[657] = "诸法无我"		
	RWTFLB[658] = "博通百家"	
	RWTFLB[313] = "诸行无常"		
	RWTFLB[140] = "无我无剑"		
	RWTFLB[499] = "文韬武略"	
	RWTFLB[27] = "化凰为凤"	  --萧玲		
	RWTFLB[574] = "天仙锁魂"	  --萧玲		
	RWTFLB[151] = "否极泰来"	  --文泰来	
	RWTFLB[68] = "一言止杀"	  --丘处机	
	RWTFLB[5] = "通微显化"	  --张三丰
	RWTFLB[577] = "一苇渡江"	  --达摩	
	RWTFLB[634] = "长春不老"	  --逍遥子
	RWTFLB[578] = "兵法入刀"	  --寇仲	
	RWTFLB[637] = "大道归藏"		 --黄赏
	RWTFLB[579] = "千变万幻"		 --司空摘星
	RWTFLB[629] = "浴火凤凰"		--
	RWTFLB[580] = "古墓无双"		--
	RWTFLB[581] = "机灵古怪"		--
	RWTFLB[649] = "娇美人妻"		--宁中则
	RWTFLB[583] = "普善圣心"		--仪琳
	RWTFLB[582] = "雪花神剑"		--白绣		
	RWTFLB[1] = "魂系一刀"
	RWTFLB[4] = "跌打医生"
	RWTFLB[9] = "运转乾坤"
    RWTFLB[20] = "七弦无形剑"
	RWTFLB[35] = "灵奇洒脱"
	RWTFLB[37] = "赤心连城"
	RWTFLB[38] = "名相皆无"	
	RWTFLB[48] = "心无所住"
	RWTFLB[49] = "福缘深厚"
	RWTFLB[50] = "奋英雄怒"
	RWTFLB[51] = "离合参商"
	RWTFLB[53] = "磊落仁心"
	RWTFLB[54] = "志垂日月"
	RWTFLB[55] = "大器晚成"
	RWTFLB[56] = "奇门遁甲"
	RWTFLB[58] = "逆流勇进"
	RWTFLB[59] = "一片冰心"
	RWTFLB[60] = "倒行逆施"
	RWTFLB[63] = "外和内刚"
	RWTFLB[64] = "返璞归真"
	RWTFLB[73] = "琴铮盈盈"
	RWTFLB[74] = "巾帼之才"
	RWTFLB[76] = "武中无相"
	RWTFLB[77] = "珠联璧合"
	RWTFLB[80] = "勇猛精进"
	RWTFLB[83] = "纤纤铁手"
	RWTFLB[84] = "龙象之姿"
	RWTFLB[92] = "指挥若定"
	RWTFLB[97] = "借刀杀人"
	RWTFLB[102] = "双树枯荣"
	RWTFLB[112] = "天威奋烈"
	RWTFLB[116] = "北冥极渊"
	RWTFLB[117] = "转瞬红颜"
	RWTFLB[118] = "无相转身"
	RWTFLB[129] = "仙风道骨"	
	RWTFLB[153] = "千臂如来"
	RWTFLB[553] = "赤胆忠魂"
	RWTFLB[589] = "似水柔情"	--水笙
	RWTFLB[590] = "心秀天铃"		--李文秀
	RWTFLB[592] = "料敌先机"	--独孤求败
	RWTFLB[601] = "机敏无双"	--韦小宝
	RWTFLB[605] = "惊才绝艳"	--林朝英
	RWTFLB[606] = "踏沙无痕"	--阿凡提
	RWTFLB[609] = "机智多谋"	--赵敏
	RWTFLB[631] = "秀若芝兰"	--周芷若
	RWTFLB[642] = "亿万小时"	--四大山
	RWTFLB[636] = "侠客行"	--李白	
	RWTFLB[652] = "惊天一剑"	--萧秋水
	RWTFLB[635] = "天机神算"	--梁萧
	RWTFLB[497] = "补天劫奴"	--陆渐
	RWTFLB[498] = "惊才绝艳"	--李寻欢	
	RWTFLB[638] = "氤氲紫气"	--斗酒僧
	RWTFLB[640] = "翩若惊鸿"	--黄衫女		
	RWTFLB[189] = "仁者无敌"	--萧半和	
	RWTFLB[633] = "刀剑归真"	--胡一刀	
	RWTFLB[500] = "剑道化身"	--西门吹雪	
	RWTFLB[588] = "过目不忘"	--冯蘅
	RWTFLB[586] = "何足道哉"	--何足道	
	RWTFLB[584] = "麒麟臂"	    --
	RWTFLB[569] = "沅芷澧兰"	--
	RWTFLB[639] = "意假情真"	--	
	

	--天赋介绍
	TFJS = {}
	--葵花尊者
	TFJS[608] = {"Ｌ葵花尊者",
	"Ｗ攻击防御1.5倍",
	"Ｗ攻击必发动葵花刺目",
	"Ｗ受到普通暗器攻击必定反击",
	"Ｗ葵花移形/真葵花移形/葵花概率提升",	
	"Ｗ可以装备绣花针",	
	"Ｌ定心圆气",
	"Ｗ时序回复气血/内力/体力，并额外回复冰封/灼烧/流血1点/时序",
	}		
	--林殊
	TFJS[508] = {"Ｌ琅琊公子",
	"Ｗ战斗中系数必然不低于对方",
	"Ｗ战斗中可以自由切换林殊/梅长苏两个身份",	
	"Ｎ",
	"Ｌ亘天赤焰",
	"Ｗ攻击必发动赤焰给敌方造成灼烧，小概率直接点燃，每点灼烧值减少敌方防御1%",
	"Ｗ免疫流血，敌方人数越多，自身三围，五系越高",
	}		
    
	--梅长苏
	TFJS[507] = {"Ｌ琅琊公子",
	"Ｗ战斗中系数必然不低于对方",
	"Ｗ战斗中可以自由切换林殊/梅长苏两个身份",	
	"Ｎ",
	"Ｌ冠绝江左",
	"Ｗ敌方每5点冰封值减少攻击伤害1%",
	"Ｗ自带特技“麒麟不动”：每本天书可以幻化敌方的一门武功",
	"Ｗ进战100点封值，100点灼烧值，每次行动后自身增加10点冰封值，5点灼烧值",
	"Ｗ当冰封值与灼烧值为0时“火寒毒发作，”发动“偷天换日”：",
	"Ｗ恢复生命/内力到最大值，冰封值增加100，灼烧值增加50，",
	"Ｗ其它状态清零。每100时序发动一次",
	}	
    
	--酒神
	TFJS[721] = {"Ｌ酒神",
	"Ｗ初始暗器200，暗器必定1倍伤害",
	"Ｗ拥有华丽的头像",	
	"Ｗ喝酒buff有特殊攻击特效",	
	"Ｗ休息时必定蓄力防御",		
	"Ｎ",
	"Ｌ酒神八杯",
	"Ｗ羊脂白玉杯：此杯极为珍贵，可卖出2万两*犀角杯：战场中每次喝酒集气增加4点，下回合集气位置提升*古藤杯：战斗结束随机获得一颗（灵芝、地灵外）的药*青铜爵：战斗结束随机获得一坛酒*夜光杯：连击率大幅度降低，暴怒必定连击*琉璃杯：5%概率触发“酒神迷踪步”闪避，喝酒后概率增加30%*古瓷杯：被攻击时免疫破绽，暴怒必中破绽；攻击时无法出破绽，暴怒必中破绽*翡翠杯：免疫冰封灼烧",
	"Ｇ福缘奇遇",
	"Ｗ得到辟邪剑谱，第一格洗辟邪剑法一级，并洗天外*笑傲正邪打败东方不败 第二格洗葵花宝典一级，并洗天内*可装备绣花针（必须接受惩罚）",	
    }	
    
	--徐子陵
	TFJS[505] = {"Ｌ大唐双龙",
	"Ｗ学会长生诀免疫冰封，攻击必冰封",
	"Ｗ修炼武功无视内功阴阳内属",	
	"Ｎ",
	"Ｌ九字真言",
	"Ｗ行动前概率触发九字真言其中的一种或多种",
	"Ｗ随天书跟实战的增加而增加触发最大数量",	
	"Ｗ临-「不动根本印」：减伤50点",	
	"Ｗ兵-「大金刚轮印」：破防40%",	
	"Ｗ斗-「外狮子印」：气攻提升800",	
	"Ｗ者-「内狮子印」：气防提升800",	
	"Ｗ列-「外缚印」：击中移动减3",	
	"Ｗ阵-「内缚印」：击中目标内力-200",	
	"Ｗ在-「日轮印」：攻击必灼烧,",	
	"Ｗ前-「宝瓶印」：攻击范围扩大",	
	"Ｗ皆-「智拳印」：必击中破绽",		
	}		
		--杨康
	TFJS[650] = {"Ｌ小王爷",
	"Ｗ每个武功到极减少3%所受伤害与杀气。最多减少21%",
	"Ｌ无妄无我",
	"Ｗ受到伤害为75%~125%。",
	"Ｗ攻击伤害为75%~125%。",	
	}		
		--觉远
	TFJS[573] = {"Ｌ仁阳佛光",
	"Ｗ内力上限9999",
	"Ｗ可使用九阳神功攻击",	
    "Ｎ",
	"Ｌ天域幻音",
	"Ｗ本方行动后清除流血、中毒、冰封、灼烧、内伤，并回复生命值",
	}	
		--白猿
	TFJS[575] = {"Ｌ仙剑神猿",
	"Ｗ使用剑系武功攻击时，敌方御剑系数减半",
	"Ｗ可装备白猿,猿公剑法威力+500",	
    "Ｎ",
	"Ｌ闪电惊虹",
	"Ｗ初始集气值1000，每次攻击后自身集气+200，连击率+50%",
	"Ｗ每学会一种剑法,伤害提升5%",	
	}		
		--玄澄
	TFJS[576] = {"Ｌ菩提金身",
	"Ｗ受到的伤害减少30%",
    "Ｎ",
	"Ｌ无量禅震",
	"Ｗ使用伏魔杖法必定暴击",
	"Ｗ攻击如被闪避则追加一次攻击",	
	"Ｗ伏魔伏法必暴击，追加内伤，并追加内内伤值伤害",		
    "Ｎ",
	"Ｌ佛门无双",
	"Ｗ所有少林武功无条件学习",	
	}		
		--摩尼
	TFJS[641] = {"Ｌ圣火明尊",
	"Ｗ攻击必灼烧，灼烧大于25点必点燃",
	"Ｗ点燃后会造成小范围伤害",
    "Ｎ",
	"Ｌ魔道天行",
	"Ｗ我方全体攻击伤害×120％，敌方全体攻击伤害×90％",
    "Ｎ",
	"Ｌ逆转乾坤",
	"Ｗ乾坤大挪移可同时反弹给两个人（学会乾坤大挪移后）反弹伤害50%",			
	"Ｗ免疫暗器",	
	}	
	
	--岳云
	TFJS[568] = {"Ｌ精忠报国",
	"Ｗ武穆遗书带2000点气防。增加100点武常",
	"Ｗ生命低于50%减伤50%，生命低于25%减伤75%",
	"Ｗ岳家枪法攻击必命中，必连击",	
	"Ｗ岳王散手攻击必暴击，必封穴",		
    "Ｎ",
	"Ｌ决胜千里",
	"Ｗ 每回合50％几率触发，敌方集气-150，本方集气+150",
	}
    
	--上官剑南
	TFJS[567] = {"Ｌ千秋侠烈",
	"Ｗ生命值低于50%，伤害1.5倍，低于25%伤害2倍。",
	"Ｗ武穆遗书自带2000点气防",	
	"Ｗ被攻击伤害90%",	
    "Ｎ",
	"Ｌ傲世神罡",
	"Ｗ攻击必暴击",
	"Ｗ拳掌武功必破防30%",
	}		
	--袁士宵
	TFJS[658] = {"Ｌ天池怪侠",
	"Ｗ被攻击时概率转移杀气值给攻击者",
	"Ｗ攻击系数只算拳法",	
	"Ｗ百花错拳威力+600",	
    "Ｎ",
	"Ｌ博通百家",
	"Ｗ修炼所有武功需求-20",
	"Ｗ修炼武功无视内力阴阳属性",
    "Ｎ",
	"Ｌ决胜千里",
	"Ｗ每回合50％几率触发，敌方集气-150，本方集气+150",
	}	
		--天镜
	TFJS[313] = {"Ｌ天佛降世",
	"Ｗ学会金刚不坏神功必定触发“金刚不坏”特效",
	"Ｗ战斗中可以复活一次，复活后免疫内伤，免疫暴击伤害，",	
	"Ｎ",
	"Ｌ诸行无常",
	"Ｗ可使用内功攻击，武功范围+1。",

	}	
		--天虹
	TFJS[657] = {"Ｌ诸法无我",
	"Ｗ每行动一次，自身伤害+5%,受到的伤害-5%。(上限40%)",	
	"Ｎ",
	"Ｌ悲天佛怜",
	"Ｗ生命值低于50%，免疫杀气",
	"Ｗ般若掌攻击范围变为点，威力增加50%。",	
	
	}		
	
		--段思平
	TFJS[499] = {"Ｌ六脉玄机",
	"Ｗ使用六脉神剑触发四种特效几率随实战的增加每100实战增加5％.）",
	"Ｗ剑逆天光：无视敌方气防 且必破防50%（初始出招几率10％）。",	
	"Ｗ剑煌镜影：增加一次连击 附带灼烧效果（初始出招几率8％）。",
	"Ｗ南柯万剑：必暴击,且暴击攻击加成提升至200％（初始出招几率6％）。",
	"Ｗ皇玺剑印：对目标造成随机造成眩晕/虚弱/定身。（初始出招几率6％）",
	"Ｎ",
	"Ｌ剑绝天南",
	"Ｗ使用六脉神剑必触发【剑气碧烟横】，内力上限9999。",
	"Ｎ",
	"Ｇ福缘奇遇",
	"Ｗ去天龙寺书架有六脉神剑特殊剧情。战胜第一格洗六脉神剑",		
	}	
	--夏雪宜
	TFJS[639] = {"Ｌ金蛇郎君",
	"Ｗ金蛇剑法威力1.5倍。",
	"Ｗ金蛇锥5~7倍伤害。",	
	"Ｗ暴怒使用金蛇剑法必出金蛇奥义。",
	"Ｎ",
	"Ｌ意假情真",
	"Ｗ暴怒后攻击怒气值概率只减少10~40。",	
	
	}		
	--周维信
	TFJS[612] = {"Ｌ铁鞭震八方",
	"Ｗ呼延十八鞭2~5倍威力。",		
	}		
	--卓天雄
	TFJS[613] = {"Ｌ铁掌神鞭",
	"Ｗ震天铁掌威力翻倍，呼延十八鞭威力三倍。",	
	"Ｗ使用震天铁掌10%概率直接震晕目标",
	"Ｗ使用呼延十八鞭大概率造成封穴",		
	}		
	--林玉龙
	TFJS[614] = {"Ｌ荒野游龙",
	"Ｗ每行动一次，减伤增加5%，增伤5%，最高减伤增加40%。",
	"Ｎ",
	"Ｌ欢喜冤家",
	"Ｗ萧中慧在场，攻防提各提升100。",	

	}		
	--任飞燕
	TFJS[615] = {"Ｌ玉堂飞燕",
	"Ｗ攻击附带轻功值2倍的杀气值",	
	"Ｗ被攻击附带轻功值2倍的气防值",
	"Ｗ使用夫妻刀法攻击附加（轻功值/2）的固定伤害。",	
	"Ｗ与林玉龙同时在场，攻防轻增加50",	
	}	
	--袁冠南
	TFJS[566] = {"Ｌ白驹过隙",
	"Ｗ15%概率闪避攻击，生命越低，闪避率越高，最高35%闪避率",
	"Ｗ闪避后反击敌方",		
	"Ｎ",
	"Ｌ白衣书生",
	"Ｗ萧中慧在场，攻防提各提升100。",
	"Ｗ夫妻刀法威力增加300。",	
	"Ｎ",	
	"Ｇ福缘奇遇",
	"Ｗ获得《夫妻刀法》第二格洗夫妻刀法。",
	}				
	--萧玲
	TFJS[574] = {"Ｌ寒露清梦",
	"Ｗ攻击与被攻击无视敌方系数",
	"Ｗ攻击概率无视敌方防御30%",	
	"Ｎ",
	"Ｌ天仙锁魂",
	"Ｗ敌方每回合30%几率附加虚弱状态2回合。",
	"Ｗ增加*(敌方人数)伤害，最多增加60%。",	
	"Ｎ",
	"Ｒ特色指令：云梦",
	"Ｗ效果：可自由切换第一格武功为寒袖拂穴/白虹掌力",
	"Ｎ",	
	"Ｇ福缘奇遇",
	"Ｗ灵鹫宫获得八荒六合功第三格洗小无相功。天内洗小无相功",
	"Ｗ灵鹫宫获得八荒六合功第四格洗八荒六合功。可以选择天内是否洗八荒六合功",	
	}			
	--李沅芷
	TFJS[569] = {"Ｌ小魔女",
	"Ｗ敌方气攻伤害减少20%",
	"Ｗ敌方命中减10%",	
	"Ｎ",
	"Ｌ芙蓉金针",
	"Ｗ攻击附带暗器系数的真实伤害",	
	"Ｎ",
	"Ｇ福缘奇遇",
	"Ｗ获得柔云剑法/无极玄功拳，第一/二格洗对应武功",
	"Ｗ获得纯阳无极功第三格洗纯阳无极功，天内洗纯阳无极功",	
	}		
	--文泰来
	TFJS[151] = {"Ｌ奔雷手",
	"Ｗ暴怒攻击概率触发雷动九天，为目标添加一层雷音BUFF，对大于等三层雷音BUFF的目标击晕一回合",
	"Ｎ",
	"Ｌ否极泰来",
	"Ｗ每过100时序激活一次【否极泰来】，免疫死亡伤害10时序",
	"Ｗ生命越低防御跟伤害越高，怒气回复越快",	
	}		
	--达摩
	TFJS[577] = {"Ｌ一苇渡江",
	"Ｗ一苇渡江轻功自动运功",
	"Ｎ",
	"Ｌ菩提金身",
	"Ｗ受到伤害减伤30%",	
	"Ｗ受到连击暴击伤害减伤50%",
	"Ｗ免疫杀气",	
	"Ｎ",
	"Ｇ万佛朝宗",
	"Ｗ攻击时概率触发万佛朝宗附加目标当前生命值10%的伤害，并减少内力20%。",
	"Ｗ受到万佛朝宗伤害最低会保留1血"	
	}	
	TFJS[1] = {"Ｌ魂系一刀",
	"Ｗ使用胡家刀法有50%几率触发极意，暴怒必触发",
	"Ｎ",
	"Ｌ雪山飞狐",
	"Ｗ集气速度提升8点",
	"Ｎ",
	"Ｒ特色指令：飞狐",
	"Ｗ效果：无视障碍物移动，在战场上来去自如",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ得到《雪山飞狐》后，找苗人凤可洗第二格武功"
	}
	TFJS[2] = {"Ｌ灵枢素问",
	"Ｗ医疗能力上限400",
	"Ｗ用毒能力上限500",
	"Ｗ攻击时附带【七心海棠】，敌方全体中毒20点，并扣除7%当前血量",
	"Ｗ攻击时即使杀死敌方，也不会中断连击"
	}
	TFJS[3] = {"Ｌ金面佛",
	"Ｗ攻击时高几率附带灼烧",
	"Ｗ每100点御剑系数增加苗家剑法攻击范围1格",
	"Ｎ",
	"Ｒ特色指令：破军",
	"Ｗ效果：攻击敌方附加散状态，时序掉内。",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ雪山飞狐闯王宝藏剧情，可选择洗第二格武功及天赋轻功"
	}
	TFJS[4] = {"Ｌ跌打医生",
	"Ｗ医疗能力上限300",
	"Ｗ用毒能力上限300",
	"Ｎ",
	"Ｌ雁过拔毛",
	"Ｗ击退敌方后可获得银两",
	"Ｗ让田归农的攻击中附加带毒",
	"Ｎ",
	"Ｒ特色指令：虚弱",
	"Ｗ用毒药侵蚀一名敌人的神经，使其在40时序内造成的伤害杀气减半"
	}
	TFJS[72] = {"Ｌ天龙掌门",
	"Ｗ无视兵器值需求装备『闯王军刀』",
	"Ｗ装备『闯王军刀』，攻击时必定附加流血效果",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ飞狐邪线杀苗人凤后，洗第一、二格武功，天赋外功洗为胡刀苗剑"
	}
	TFJS[37] = {"Ｌ赤心连城",
	"Ｗ使用连城剑法高连击",
	"Ｗ修炼血刀大法无惩罚，不会降低生命上限",
	"Ｚ畅想主角专属",
	"Ｗ如本次攻击造成伤害低于200，则追加一次连击（一轮追加上限3次）",
	"Ｎ",
	"Ｌ真名神照",
	"Ｗ主运神照功时免疫杀气",
	"Ｗ神照功复活效果强化，回复百分比为100%，并且立即行动，无需运功",
	"Ｗ可使用神照功攻击，并追加800点气攻",
	"Ｗ神照功等级修炼至极，轻功+20",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ连城诀雪山剧情，洗第二、三格武功"
	}
	TFJS[589] = {"Ｌ似水柔情",
	"Ｗ误伤队友时恢复其血量",
	"Ｎ",
	"Ｌ铃剑侠女",
	"Ｗ使用连城剑法高连击"
	}
	TFJS[594] = {"Ｌ铁索横江",
	"Ｗ【闭气离墙.起死回生】，战斗中可以复活一次",
	"Ｗ自带“铁索横江”加力、护体，600威力，可叠加（几率与天书数、实战相关）",
	"Ｗ基础连击率大幅度提高"
	}
	TFJS[52] = {"Ｌ中平神枪",
	"Ｗ使用中平枪法时，气攻+1000"
	}
	TFJS[94] = {"Ｌ仁义刀",
	"Ｗ "
	}
	TFJS[95] = {"Ｌ柔云剑",
	"Ｗ "
	}
	TFJS[96] = {"Ｌ冷月剑",
	"Ｗ "
	}
	TFJS[97] = {"Ｌ借刀杀人",
	"Ｗ将击退的敌人满血满状态复活为己方",
	"Ｎ",
	"Ｌ诡谲",
	"Ｗ初始集气位置900，且移动+3格",
	"Ｎ",
	"Ｌ血刀老祖",
	"Ｗ基础暴击率大幅度提高"
	}
	TFJS[45] = {"Ｌ阎王敌",
	"Ｗ医疗上限500点",
	"Ｗ战斗中满血复活自己或者同伴一次"
	}
	TFJS[46] = {"Ｌ星宿老怪",
	"Ｗ攻击时，追加等同于敌方中毒量的伤害"
	}
	TFJS[47] = {"Ｌ曼珠沙华",
	"Ｗ每击退一个敌方，自身气攻气防提高200点",
	"Ｎ",
	"Ｒ特色指令：禁药",
	"Ｗ使用禁药刺激神经，自身每时序损失1%最大血量",
	"Ｗ此状态下自身血量越低，伤害/集气越高，不消耗回合"
	}
	TFJS[48] = {"Ｌ心无所住",
	"Ｗ能使用内功攻击，内功可修炼至极",
	"Ｎ",
	"Ｌ冰毒怪客",
	"Ｗ攻击带毒340点",
	"Ｗ攻击时，如敌方身上的冰封大于50，则有60%几率将其冻结10时序"
	}
	TFJS[49] = {"Ｌ福缘深厚",
	"Ｗ攻击时50%几率触发【福泽加护】，下回合集气+200",
	"Ｎ",
	"Ｌ逍遥掌门",
	"Ｗ擂鼓山剧情后，自带北冥真气护体",
	"Ｗ学会八荒六合功后，使用天山六阳掌/天山折梅手攻击可触发【生死符】",
	"Ｗ生死符追加1000气攻，对被生死符击中的敌人，可使用【催符】指令",
	"Ｗ面板上每多一个武功到极，天山折梅手威力+50",
	"Ｗ天山折梅手修炼到极，资质变为50",
	"Ｎ",
	"Ｒ特色指令：催符",
	"Ｗ催动敌人身上的生死符，使其封穴25时序",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ擂鼓山支线剧情，洗第一、二格武功",
	"Ｗ灵鹫宫拿八荒时，第三格洗为八荒六合功",
	"Ｗ灵鹫宫拿折梅时，第五格洗为天山折梅手"
	}
	TFJS[50] = {"Ｌ奋英雄怒",
	"Ｗ攻击时必定造成暴击并有红字特效",
	"Ｗ防御加成提升30%，半血时防御加成提升50%，血量低于25%防御加成提升75%",
	"Ｗ集气速度+8",
	"Ｎ",
	"Ｌ狂龙天征",
	"Ｗ自带“擒龙功”加力、护体，1000威力，可叠加（几率与天书数、实战相关）",
	"Ｗ使用降龙十八掌，必定发动【降龙.极意】",
	"Ｗ使用降龙十八掌，40%几率发动【降龙.三叠浪】，暴怒时必定发动",
	"Ｗ使用降龙十八掌攻击无误伤",
	"Ｗ降龙十八掌耗内降低50%（与天赋外功效果叠加，降低75%内力消耗）",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ天龙八部正线挑战扫地老僧胜利后，可获得专属武器"
	}
	TFJS[51] = {"Ｌ离合参商",
	"Ｗ斗转反击时，无视兵器值需求必定发动离合参商",
	"Ｗ斗转星移发动几率100%",
	"Ｎ",
	"Ｌ姑苏慕容",
	"Ｗ可使用斗转星移进行攻击",
	"Ｎ",
	"Ｒ特色指令：幻梦",
	"Ｗ至该角色下次行动为止，被攻击必定发动幻梦星辰反击"
	}
	TFJS[53] = {"Ｌ磊落仁心",
	"Ｗ内力上限9999",
	"Ｎ",
	"Ｌ六脉真传",
	"Ｗ六脉神剑出招式几率追加二次判定",
	"Ｗ六脉神剑耗内降低50%（与天赋外功效果叠加，降低75%内力消耗）",
	"Ｎ",
	"Ｒ特色指令：凌波",
	"Ｗ至该角色下次行动为止，被攻击有50%几率闪避",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ无量山洞剧情，洗第一、二格武功",
	"Ｗ天龙寺剧情，洗第三格武功"
	}
	TFJS[70] = {"Ｌ少林掌门",
	"Ｗ "
	}
	TFJS[76] = {"Ｌ武中无相",
	"Ｗ无视限制条件修炼武学秘籍",
	"Ｗ初始自带100点武常",
	"Ｎ",
	"Ｌ琅嬛仙子",
	"Ｗ作为主角时，初始五系兵器值提升至30点",
	"Ｎ",
	"Ｚ妙法无形",
	"Ｗ在场时，我方全体攻击范围增加一格",
	"Ｎ",
	"Ｚ御法绝尘",
	"Ｗ☆需要自身五系兵器值之和大于等于500",
	"Ｗ在场时，敌方全体攻击时不会出招式",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ获得凌波微步后，天赋轻功洗为凌波微步"
	}
	TFJS[90] = {"Ｌ毓秀灵姝",
	"Ｗ攻击时必定造成流血",
	"Ｎ",
	"Ｒ特色指令：灵貂",
	"Ｗ☆找到闪电貂后可激活",
	"Ｗ偷窃敌方携带的物品，并对其强制上毒50点",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ天龙正线收段誉，洗第一格武功，天赋外功洗为六脉神剑"
	}
	TFJS[98] = {"Ｌ恶贯满盈",
	"Ｗ暴击攻击加成提升至200%"
	}
	TFJS[99] = {"Ｌ无恶不作",
	"Ｗ暴击攻击加成提升至200%"
	}
	TFJS[100] = {"Ｌ穷凶极恶",
	"Ｗ暴击攻击加成提升至200%"
	}
	TFJS[44] = {"Ｌ凶神恶煞",
	"Ｗ暴击攻击加成提升至200%"
	}
	TFJS[101] = {"Ｌ大理家臣",
	"Ｗ "
	}
	TFJS[102] = {"Ｌ双树枯荣",
	"Ｗ灼烧恢复能力加倍（时序恢复2点灼烧）",
	"Ｗ自带“枯荣真气”护体，600威力，可叠加（几率与天书数、实战相关）",
	"Ｗ攻击时几率追加600气攻，可叠加（几率与天书数、实战相关）",
	"Ｎ",
	"Ｌ天龙禅师",
	"Ｗ使用一阳指高几率连击"
	}
	TFJS[103] = {"Ｌ大轮明王",
	"Ｗ火焰刀法【大轮密宗.火焰刀】发动几率100%",
	"Ｗ自带“明王真气”加力、护体，600威力，可叠加（几率与天书数、实战相关）",
	"Ｎ",
	"Ｒ特色指令：幻化",
	"Ｗ使用小无相功模拟天下武学，必须要拥有对应的秘籍"
	}
	TFJS[104] = {"Ｌ云舞霓裳",
	"Ｗ无视限制条件穿戴任何装备"
	}
	TFJS[105] = {"Ｌ琴韵温香",
	"Ｗ "
	}
	TFJS[110] = {"Ｌ聚贤庄主",
	"Ｗ "
	}
	TFJS[111] = {"Ｌ聚贤庄主",
	"Ｗ "
	}
	TFJS[112] = {"Ｌ天威奋烈",
	"Ｗ时序增加2点怒气",
	"Ｎ",
	"Ｌ震天魔狼",
	"Ｗ必连击，必暴击"
	}
	TFJS[113] = {"Ｌ参合潜龙",
	"Ｗ斗转反击时，无视兵器值需求必定发动离合参商反击两次",
	"Ｗ自带“参合真气”加力、护体，600威力，可叠加（几率与天书数、实战相关）"
	}
	TFJS[114] = {"Ｌ达摩再世",
	"Ｗ内力上限9999，初始武学常识100",
	"Ｗ被攻击100%触发【天地独尊】，完全免疫杀气",
	"Ｗ攻击时高几率触发封穴",
	"Ｗ攻击时武功视觉特效随机触发，攻击无误伤",
	"Ｗ攻击时被攻击时系数必然不低于敌人。",	
	"Ｎ",
	"Ｌ不动如山",
	"Ｗ25%概率发动，被攻击只受到伤害30点",
	"Ｎ",
	"Ｌ天佛化生·金刚护体",
	"Ｗ降低受到的伤害30%",
	}
	TFJS[115] = {"Ｌ聪辩先生",
	"Ｗ拥有琴棋书画四种天赋外功"
	}
	TFJS[116] = {"Ｌ北冥极渊",
	"Ｗ内力上限9999",
	"Ｗ被攻击时必定发动北冥真气护体",
	"Ｚ畅想主角专属",
	"Ｗ主动攻击触发北冥神功吸内时，增加自身属性",
	"Ｎ",
	"Ｌ风月无间",
	"Ｗ对男性伤害提高20%，被女性伤害减少20%",
	"Ｎ",
	"Ｌ逍遥三老",
	"Ｗ面板上每多一个武功到极，天山折梅手威力+50"
	}
	TFJS[117] = {"Ｌ转瞬红颜",
	"Ｗ每过199时序，自动回满血内体并解除自身异常状态",
	"Ｎ",
	"Ｌ不老长春",
	"Ｗ被攻击时恢复80点生命",
	"Ｎ",
	"Ｌ逍遥三老",
	"Ｗ面板上每多一个武功到极，天山折梅手威力+50"
	}
	TFJS[118] = {"Ｌ无相转身（畅想主角专属）",
	"Ｗ被攻击时几率触发，免疫本次攻击并获得一次移动机会",
	"Ｗ移动后会在自身位置留下一个幻象",
	"Ｗ幻象生命为1点，且无法攻击",
	"Ｗ幻象消失前，不会再次触发无相转身",
	"Ｎ",
	"Ｌ秋水无尘",
	"Ｗ自身集气速度不受异常状态影响",
	"Ｎ",
	"Ｌ逍遥三老",
	"Ｗ面板上每多一个武功到极，天山折梅手威力+50"
	}
	TFJS[55] = {"Ｌ大器晚成",
	"Ｗ左右互搏发动几率固定为80%",
	"Ｗ作为队友时，最后10级的升级属性提高",
	"Ｎ",
	"Ｌ侠之大者",
	"Ｗ使用降龙十八掌，40%几率发动【降龙.极意】",
	"Ｗ使用降龙十八掌发动连击时，在第二击附加随机多重后劲，额外增加伤害和杀气",
	"Ｗ后劲上限随天书数而增加，最多13道；后劲超过11道时，无视敌方绝对气防",
	"Ｗ每道后劲增加8%的高优先级伤害和150点气攻，NPC郭靖上限固定为10道后劲",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ射雕桃花岛招亲剧情，洗第一、二、三格武功",
	"Ｗ射雕正线桃花岛收郭靖时，可重新选择内力属性"
	}
	TFJS[56] = {"Ｌ奇门遁甲",
	"Ｗ战斗开始前可布置奇阵，不同颜色的地面有不同效果:",
	"Ｒ红色——造成的伤害提高20%",
	"Ｌ绿色——受到的伤害减少20%",
	"Ｄ蓝色——攻击时追加400点气攻",
	"Ｚ紫色——被攻击时有30%几率闪避",
	"Ｎ",
	"Ｌ兰质蕙心",
	"Ｗ修炼武功秘籍时，兵器值成长翻倍",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ射雕明霞岛剧情，洗第一、二格武功"
	}
	TFJS[57] = {"Ｌ东邪",
	"Ｗ攻击时发动碧海潮生曲,杀全体敌人内力500",
	"Ｗ攻击时高几率造成封穴",
	"Ｗ集气速度+10",
	"Ｗ自带“奇门奥义”加力、护体，600威力，可叠加（几率与天书数、实战相关）"
	}
	TFJS[60] = {"Ｌ倒行逆施",
	"Ｗ集气时有小概率跳跃（集气值随机增加）",
	"Ｗ学会逆运后，被攻击必定进入【真.逆运经脉-走火入魔】状态",
	"Ｗ走火状态必定暴击，攻击/防御效果提高10%，加力/护体/出招几率大幅提高",
	"Ｗ走火状态无法休息，如体力低于20点，则停止走火",
	"Ｎ",
	"Ｌ西毒",
	"Ｗ所有攻击无误伤",
	"Ｗ攻击时无视敌方毒抗强制上毒30点",
	"Ｗ蛤蟆功.蟾震九天效果加强，会根据蓄力值追加伤害",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ射雕明霞岛剧情后，洗第二格武功，天赋内功洗为逆运经脉",
	"Ｗ华山绝顶支线剧情，洗第三格武功"
	}
	TFJS[61] = {"Ｌ白驼少主",
	"Ｗ暴怒时，使用雪山白驼掌可触发灵蛇拳，击中的敌人集气进入波动状态20时序"
	}
	TFJS[64] = {"Ｌ返璞归真",
	"Ｗ左右互搏发动几率100%",
	"Ｎ",
	"Ｌ顽童武痴",
	"Ｗ每行动一次，攻击效果提升10%",
	"Ｎ",
	"Ｚ空明之武道",
	"Ｗ攻击时，有(25+实战/20)%几率使敌方无法触发内功护体",
	"Ｎ",
	"Ｚ左右补偿（畅想主角专属）",
	"Ｗ发动左右互搏后，会根据资质补偿一次额外的左右机会"
	}
	TFJS[65] = {"Ｌ南僧",
	"Ｗ使用一阳指，给敌方追加“无明业火”状态，持续30时序",
	"Ｗ处于“无明业火”状态的人攻击时，会损失50%内力消耗量的生命",
	"Ｗ攻击时高几率造成封穴",
	"Ｎ",
	"Ｚ先天一阳",
	"Ｗ战斗中首次被击退可复活一次",
	"Ｗ回复70%生命值，部分状态，并立即行动",
	"Ｗ复活后，集气速度+5",
	"Ｎ",
	"Ｚ不动明王",
	"Ｗ复活后，完全免疫敌方连击的伤害"

	}
	TFJS[68] = {"Ｌ长春子",
	"Ｗ华山观武后全真剑法威力翻倍",
	"Ｗ主运先天功，全真剑法概率变化七星剑法 增加150点真实伤害",
    "Ｗ 先天功气血、内力回复翻倍",
	"Ｎ",
	"Ｒ特色指令：止杀",
	"Ｗ每三个回合可发动一次",
	"Ｗ身边10格内敌人不可攻击一回合",	
	}	

	TFJS[67] = {"Ｌ铁掌帮主",
	"Ｗ使用任何武功高连击，高暴击"
	}
	TFJS[69] = {"Ｌ北丐",
	"Ｗ使用降龙十八掌，40%几率发动【降龙.极意】",
	"Ｗ使用降龙十八掌攻击无误伤",
	"Ｗ自带“丐王真气”加力、护体，600威力，可叠加（几率与天书数、实战相关）",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ华山绝顶支线剧情，洗第三格武功，天赋内功洗为九阴神功，内力属性转为阴内"
	}
	TFJS[78] = {"Ｌ铁尸魔煞",
	"Ｗ华山观武后，九阴白骨爪威力增加50%"
	}
	TFJS[119] = {"Ｌ渔",
	"Ｗ "
	}
	TFJS[120] = {"Ｌ樵",
	"Ｗ "
	}
	TFJS[121] = {"Ｌ耕",
	"Ｗ "
	}
	TFJS[122] = {"Ｌ读",
	"Ｗ "
	}
	TFJS[123] = {"Ｌ丹阳子",
	"Ｗ华山观武后全真剑法威力翻倍"
	}
	TFJS[124] = {"Ｌ长真子",
	"Ｗ华山观武后全真剑法威力翻倍"
	}
	TFJS[125] = {"Ｌ长生子",
	"Ｗ华山观武后全真剑法威力翻倍"
	}
	TFJS[126] = {"Ｌ玉阳子",
	"Ｗ华山观武后全真剑法威力翻倍"
	}
	TFJS[127] = {"Ｌ广宁子",
	"Ｗ华山观武后全真剑法威力翻倍"
	}
	TFJS[128] = {"Ｌ清净散人",
	"Ｗ华山观武后全真剑法威力翻倍"
	}
	TFJS[129] = {"Ｌ中神通",
	"Ｗ华山观武后，全真剑法威力翻倍",
	"Ｗ使用全真剑法，60%几率发动重阳剑气，追加777气攻",
	"Ｗ攻击时高几率造成封穴",
	"Ｎ",
	"Ｚ神通技·重阳再现",
	"Ｗ战斗中首次被击退可复活一次",
	"Ｗ回复70%生命值，部分状态，并立即行动",
	"Ｗ复活后，集气速度+5",
	"Ｎ",
	"Ｚ神通技·北斗七闪",
	"Ｗ发动重阳再现后，自身进入北斗真打状态",
	"Ｗ获得两本天书后习得第一层效果之后每获得两本天书增加一层，共七层",
	"Ｗ层数即代表可维持真打状态的轮数",
	"Ｗ自身每行动一次减少一层，耗完即消去真打状态",	
	"Ｗ在真打状态下，全程怒气爆发",	
	"Ｗ必定发动内功加力且气攻值增幅",		
	"Ｎ",
	"Ｚ神通技·一气化三清",
	"Ｗ攻击时机率发动“中神通.一气化三清” 1.2倍伤害",
	"Ｎ",
	"Ｚ神通技·同归剑法",
	"Ｗ攻击时40%发动“同归剑法”为对方添加一个回合“同归”BUFF，",
	"Ｗ处于“同归”状态的人攻击时，会损失伤害同等的生命",	
	}
	TFJS[130] = {"Ｌ飞天蝙蝠",
	"Ｗ"
	}
	TFJS[131] = {"Ｌ妙手书生",
	"Ｗ使用妙手空空攻击，可盗取敌方身上携带的物品"
	}
	TFJS[132] = {"Ｌ马王神",
	"Ｗ "
	}
	TFJS[133] = {"Ｌ南山樵子",
	"Ｗ "
	}
	TFJS[134] = {"Ｌ笑弥陀",
	"Ｗ "
	}
	TFJS[135] = {"Ｌ闹市侠隐",
	"Ｗ "
	}
	TFJS[136] = {"Ｌ越女剑",
	"Ｗ "
	}
	TFJS[590] = {"Ｌ心秀天铃",
	"Ｗ使用奇门武功，有（天书数*2+实战/25）%的几率发动“心秀天铃·星月争辉”，",
	"Ｗ追加800点气攻，如已有14本天书，则触发此特效必破气防",
	"Ｎ",
	"Ｌ古道西风",
	"Ｗ装备白马时的集气加成效果翻倍",
	"Ｚ畅想主角专属",
	"Ｗ每修炼一个奇门武功到极，集气速度+2（上限7个）"
	}
	TFJS[137] = {"Ｌ青蟒剑",
	"Ｗ "
	}
	TFJS[138] = {"Ｌ一指镇江南",
	"Ｗ "
	}
	TFJS[86] = {"Ｌ金枝玉叶",
	"Ｗ敌方全体防御效果降低10%"
	}
	TFJS[87] = {"Ｌ媚眼如丝",
	"Ｗ敌方全体攻击效果降低10%"
	}
	TFJS[139] = {"Ｌ延平郡王",
	"Ｗ "
	}
	TFJS[150] = {"Ｌ一剑无血",
	"Ｗ "
	}
	TFJS[71] = {"Ｌ神龙教主",
	"Ｗ使用任何武功高连击，高暴击",
	"Ｎ",
	"Ｌ特技：豹胎易筋丸",
	"Ｗ在敌方要服用的药品中加入豹胎易筋丸，使其加血效果变为减血"
	}
	TFJS[19] = {"Ｌ君子剑",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ笑傲福威镖局选择正邪剧情，洗第一、三格武功"
	}
	TFJS[21] = {"Ｌ恒山掌门",
	"Ｗ "
	}
	TFJS[22] = {"Ｌ嵩山掌门",
	"Ｗ攻击时高几率附带冰封",
	"Ｗ自带“寒冰真气”加力、护体，500威力，可叠加（几率与天书数、实战相关）"
	}
	TFJS[23] = {"Ｌ泰山掌门",
	"Ｗ攻击时高几率附带灼烧"
	}
	TFJS[24] = {"Ｌ青城掌门",
	"Ｗ "
	}
	TFJS[25] = {"Ｌ五毒教主",
	"Ｗ攻击效果提升10%",
	"Ｗ用毒能力上限400"
	}
	TFJS[26] = {"Ｌ日月魔帝",
	"Ｗ吸星大法吸体力效果提高",
	"Ｗ自带加力护体（600威力，可叠加）几率与天书数、实战有关",
	"Ｗ使用任何武功高暴击",
	"Ｗ攻击时高几率造成封穴"
	}
	TFJS[27] = {"Ｌ风云再起",
	"Ｗ葵花神功为天赋内功时自动运功",	
	"Ｗ攻击无误伤",
	"Ｗ集气速度提升6点",
	"Ｗ必连击，50机率追加一次连击(暴怒必追加",
	"Ｗ连击时伤害、气攻不减",	
	"Ｗ自带绣花针，真.葵花移形概率30%",	
	"Ｎ",
	"Ｌ葵花点穴手",
	"Ｗ攻击时几率追加1000气攻，且必定造成封穴",
	"Ｎ",
	"Ｌ葵花秘法·化凤为凰",
	"Ｗ暴怒时触发，直至暴怒解除前无法被杀气"
	}
	TFJS[28] = {"Ｌ杀人名医",
	"Ｗ每击退一名敌人集气速度+3点、医疗能力+50（最多5个有效）",
	"Ｗ医疗能力上限500"
	}
	TFJS[29] = {"Ｌ万里独行",
	"Ｗ战场上已方人员越少集气速度提升越多",
	"Ｗ集气速度提升值为：20-在场队友数量×4"
	}
	TFJS[31] = {"Ｌ江南四友",
	"Ｗ "
	}
	TFJS[32] = {"Ｌ江南四友",
	"Ｗ "
	}
	TFJS[33] = {"Ｌ江南四友",
	"Ｗ "
	}
	TFJS[34] = {"Ｌ江南四友",
	"Ｗ "
	}
	TFJS[35] = {"Ｌ灵奇洒脱",
	"Ｗ移动格数+3",
	"Ｎ",
	"Ｌ九剑传人",
	"Ｗ被风清扬指点后，进入战斗初始集气值1000",
	"Ｎ",
	"Ｌ剑魔再临（独孤剑冢剧情后）",
	"Ｗ连击率大幅提升",
	"Ｗ使用独孤九剑攻击无误伤",
	"Ｗ攻击时有几率发动『剑魔再临·动如雷震』特效，三连击，暴怒必触发",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ笑傲思过崖剧情，洗第一格武功，天赋外功洗为独孤九剑",
	"Ｗ笑傲梅庄地牢剧情，洗第二格武功，天赋内功洗为吸星大法"
	}
	TFJS[36] = {"Ｌ辟邪剑客",
	"Ｗ初始集气位置900",
	"Ｗ可使用葵花神功攻击",
	"Ｗ使用辟邪剑法招式无冷却",
	"Ｎ",
	"Ｌ特技：血海飘香（杀余沧海后领悟）",
	"Ｗ根据本轮造成的伤害提高下一轮的集气位置，上限400",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ笑傲福威镖局选择正邪剧情，洗第一、二格武功",
	"Ｗ笑傲福威镖局选择正邪剧情，天赋内功洗为葵花神功"
	}
	TFJS[140] = {"Ｌ剑术通神",
	"Ｗ攻击和被攻击时，无论任何系，均按敌我御剑系数计算加成",
	"Ｎ",
	"Ｚ无招胜有招",
	"Ｗ暴怒时，使用独孤九剑攻击，追加1000点气攻，和10时序的静止状态，可叠加",
	"Ｎ",
	"Ｚ无我无剑",
	"Ｗ自带100武常。",	
	"Ｗ初始集气1000。",
	"Ｗ被攻击先手反击。",
	 "Ｎ",
	"Ｚ九剑真传",
	"Ｗ被攻击与攻击触发九剑真传。",	
	}
	TFJS[73] = {"Ｌ琴铮盈盈",
	"Ｗ使用持瑶琴，必定发动“七弦无形剑气”，对敌方全体造成50×血量倍数的伤害",
	"Ｎ",
	"Ｌ日月圣姑",
	"Ｗ每时序回复自身5点中毒"
	}
	TFJS[79] = {"Ｌ慧中灵剑",
	"Ｗ每修炼一门剑法，攻击效果提升5%",
	"Ｗ每修炼一门剑法，初始集气+50",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ笑傲福威镖局选择正邪剧情，洗第一、二、三格武功",
	}
	TFJS[88] = {"Ｌ酒神",
	"Ｗ被攻击时有30%几率发动\"酒神秘踪步\"闪避",
	"Ｎ",
	"Ｒ特色指令：传功",
	"Ｗ将五格范围内我方任一队友当前集气提升500点"
	}
	TFJS[106] = {"Ｌ金刀无敌",
	"Ｗ "
	}
	TFJS[141] = {"Ｌ剑宗弃徒",
	"Ｗ "
	}
	TFJS[142] = {"Ｌ狂风快剑",
	"Ｗ使用剑法攻击，下回合集气+100"
	}
	TFJS[143] = {"Ｌ桃谷六仙",
	"Ｗ "
	}
	TFJS[144] = {"Ｌ桃谷六仙",
	"Ｗ "
	}
	TFJS[145] = {"Ｌ桃谷六仙",
	"Ｗ "
	}
	TFJS[146] = {"Ｌ桃谷六仙",
	"Ｗ "
	}
	TFJS[147] = {"Ｌ桃谷六仙",
	"Ｗ "
	}
	TFJS[148] = {"Ｌ桃谷六仙",
	"Ｗ "
	}
	TFJS[149] = {"Ｌ少林掌门",
	"Ｗ无视限制条件修炼金刚不坏体",
	"Ｎ",
	"Ｌ特技：千手如来掌",
	"Ｗ使用拳法攻击时，攻击范围增加一格",
	"Ｎ",
	"Ｌ特技：易筋经大成",
	"Ｗ免疫敌方三大吸功的吸内效果",
	"Ｎ",
	"Ｒ菩提金身",
	"Ｗ受到的伤害降低30%，",
	}
	TFJS[74] = {"Ｌ巾帼之才",
	"Ｗ我方全体防御效果提高10%",
	"Ｗ我方全体攻击效果提高10%",
	"Ｎ",
	"Ｌ翠羽黄衫",
	"Ｗ自身增加我方存活人数*10的防御",
	"Ｎ",
	"Ｒ特色指令：指挥",
	"Ｗ每二个回合可使用一次指挥指令，我们全体集气+500，并获获得减伤增伤BUFF50时序，",
	"Ｗ减伤效果为我方存活人数*5%"
	}
	TFJS[75] = {"Ｌ天池红花",
	"Ｗ升级时兵器值大幅提高",
	"Ｗ华山觉醒后五系兵器值可突破上限",
	"Ｎ",
	"Ｌ特技：庖丁解牛（畅想主角专属）",
	"Ｗ攻击时有50%几率无视敌方30%防御",
	"Ｎ",	
	"Ｒ香魂",
	"Ｗ被女性攻击伤害×250%，对女性攻击伤害×50%"
	}
	TFJS[80] = {"Ｌ勇猛精进",
	"Ｗ我方全体攻击效果提高10%",
	"Ｎ",
	"Ｌ火手判官",
	"Ｗ攻击时所造成内伤效果加倍",
	"Ｎ",
	"Ｌ天赋内功",
	"Ｗ修炼纯阳无极功与九阳神功一脉相承后，天赋内功变为九阳神功",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ武当山偷太极三宝支线，洗第二、三格武功"
	}
	TFJS[152] = {"Ｌ追魂夺命剑",
	"Ｗ "
	}
	TFJS[153] = {"Ｌ千臂如来",
	"Ｗ初始暗器值200点",
	"Ｎ",
	"Ｌ暗器之王",
	"Ｗ战斗胜利后随机获得暗器"
	}
	TFJS[154] = {"Ｌ鸳鸯刀",
	"Ｗ战场上我方男性角色越多其攻击效果越高"
	}
	TFJS[155] = {"Ｌ黑无常",
	"Ｗ "
	}
	TFJS[156] = {"Ｌ白无常",
	"Ｗ "
	}
	TFJS[58] = {"Ｌ逆流勇进",
	"Ｗ生命值低于50%时暴击率两倍，生命值低于25%时暴击率3倍",
	"Ｗ当生命值50%时，生命值每再降低1%，下回合集气位置+10点",
	"Ｎ",
	"Ｌ西狂",
	"Ｗ使用玄铁剑法时，有几率发动重剑真传",

	"Ｗ使用黯然销魂掌击中生命敌于50%的目标概率直接击退(概率跟敌人血量有关)",		
	"Ｗ攻击时附带“西狂之怒啸”，敌方全体集气倒退100点",
	"Ｗ战斗中，当小龙女被击退时，杨过立即出手并发动【西狂之震怒·雷霆狂啸】",
	"Ｎ",
	"Ｄ黯然极意",
	"Ｗ资质高于50触发黯然极意必出三叠浪",
	"Ｗ资质低于50，触发黯然极意必定连击",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ作为畅想主角时，有大量专属剧情",
	"Ｗ独孤剑冢拿玄铁剑法时，洗第一格武功，解锁剑魔再临",
	"Ｗ神雕重阳宫大战后，洗第三格武功，可选择洗天赋内功",
	"Ｗ神雕百花谷剧情后，洗第二格武功",
	"Ｗ射雕牛家村支线，可选择洗第三格武功和天赋内功",
	"Ｗ华山绝顶支线剧情，可选择洗第五格武功"
	}
	TFJS[59] = {"Ｌ一片冰心",
	"Ｗ左右互搏发动几率70%",
	"Ｎ",
	"Ｌ冷若天仙",
	"Ｗ使用玉女素心剑法高几率连击"
	}
	TFJS[62] = {"Ｌ元蒙帝师",
	"Ｗ任何攻击追加2000点气攻",
	"Ｎ",
	"Ｒ特色指令：龙象",
	"Ｗ使用后自动执行蓄力，并使下一次的攻击附加昏迷效果",
	"Ｗ昏迷的敌人将丧失一次行动机会",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ神雕重阳宫大战后，洗第二格武功，天赋外功洗为五轮大转"
	}
	TFJS[63] = {"Ｌ外和内刚",
	"Ｗ生命值低于50%时，攻击效果提升20%",
	"Ｎ",
	"Ｌ青箫落瑛",
	"Ｗ使用玉箫剑法攻击，可杀敌内力300点",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ射雕正线牛家村剧情，洗第二、三格武功"
	}
	TFJS[89] = {"Ｌ食神",
	"Ｗ攻击不消耗体力",
	"Ｎ",
	"Ｒ特色指令：气补",
	"Ｗ回复指定邻接队友体力50点"
	}
	TFJS[157] = {"Ｌ湘西尸王",
	"Ｗ华山观武后鹤蛇八打威力翻倍"
	}
	TFJS[158] = {"Ｌ波斯大贾",
	"Ｗ作为畅想主角时开局获得一万银两"
	}
	TFJS[159] = {"Ｌ释迦掷象功",
	"Ｗ必定单击，伤害永久提高1.5倍（天赋外功与如雷的额外连击有效）"
	}
	TFJS[160] = {"Ｌ尊师重道",
	"Ｎ",
	"Ｒ特色指令：死战",
	"Ｗ锁定一名敌人，至其死亡之前，达尔巴对其的攻击效果提高50%，且必定命中",
	"Ｗ在目标死亡之前无法更换目标"
	}
	TFJS[161] = {"Ｌ赤练仙子",
	"Ｗ使用五毒神掌时，有70%几率变为赤练神掌，追加70点伤害，并强制上毒20点",
	"Ｗ对男性增伤10%",	
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ神雕邪线古墓密道剧情，洗第二、三格武功，天赋内功洗为玉女心经"
	}
	TFJS[38] = {"Ｌ名相皆无",
	"Ｗ计算加力/护体/出招几率时必定开启二次判定",
	"Ｗ学有罗汉伏魔功，攻击时必出【罗汉伏魔】特效",
	"Ｗ【罗汉伏魔】特效效果增强10%（包括伤害和杀气）",
	"Ｗ内力上限9999",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ侠客正线挑战岛主剧情，洗第二格武功，天赋内功洗为太玄神功"
	}
	TFJS["38-1"] = {"Ｌ名相皆无",
	"Ｗ计算加力/护体/出招几率时必定开启二次判定",
	"Ｗ学有罗汉伏魔功，攻击时必出【罗汉伏魔】特效",
	"Ｗ【罗汉伏魔】特效效果增强10%（包括伤害和杀气）",
	"Ｗ内力上限9999",
	"Ｎ",
	"Ｌ混沦太玄",
	"Ｗ可使用太玄神功攻击，并可选择招式",
	"Ｗ太玄神功耗内降低50%（与天赋外功效果叠加，降低75%内力消耗）",
	"Ｗ被攻击时，有50%几率触发太玄反震，对攻击方造成10点封穴",
	"Ｗ被攻击时，有30%几率将受到的伤害转化为减半回血",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ侠客正线挑战岛主剧情，洗第二格武功，天赋内功洗为太玄神功"
	}
	TFJS[39] = {"Ｌ侠客岛主",
	"Ｗ攻击效果提升20%",
	"Ｗ使用任何武功高几率造成封穴"
	}
	TFJS[40] = {"Ｌ侠客岛主",
	"Ｗ防御效果提升20%"
	}
	TFJS[41] = {"Ｌ赏善使者",
	"Ｗ攻击时高几率附带灼烧"
	}
	TFJS[42] = {"Ｌ罚恶使者",
	"Ｗ攻击时高几率附带冰封"
	}
	TFJS[43] = {"Ｌ雪山派掌门",
	"Ｗ "
	}
	TFJS[162] = {"Ｌ一日不过三",
	"Ｗ "
	}
	TFJS[163] = {"Ｌ一日不过四",
	"Ｗ "
	}
	TFJS[164] = {"Ｌ摩天居士",
	"Ｗ自带“摩天居士”护体（500威力，可叠加）几率与天书数、实战有关"
	}
	TFJS[85] = {"Ｌ老谋深算",
	"Ｗ医疗能力上限400"
	}
	TFJS[5] = {"Ｌ太极宗师",
	"Ｗ连击伤害杀气借力打力不减",	
	"Ｗ太极拳连击时亦享受借力打力效果",
	"Ｗ太极奥义发动几率无视资质固定为85%",
	"Ｗ太极神功蓄力只清除50%",	
	"Ｎ",
	"Ｌ通微显化",
	"Ｗ被攻击发动无根无形减伤30%",
	"Ｗ攻击时几率发动万法自然，下回合集气+500",
	"Ｗ移动格数至少为8格",
	"Ｗ蓄力效果增加",	
	"Ｗ攻击时几率触发化朽为奇，追加武功威力的气攻",
    }
	TFJS[6] = {"Ｌ灭绝师太",
	"Ｗ使用任何武功高连击，必暴击",
	"Ｗ移动格数+3",
	"Ｎ",
	"Ｒ特色指令：俱焚",
	"Ｗ开启后100时序，自身造成和受到的伤害皆提高50%，不消耗回合"
	}
	TFJS[7] = {"Ｌ铁琴先生",
	"Ｗ攻击时，有60%几率给敌方附加1-3层琴音状态",
	"Ｗ每层琴音状态降低敌方1%集气速度",
	"Ｗ琴音状态叠加上限为20层",
	"Ｎ",
	"Ｒ特色指令：铁琴",
	"Ｗ使全场敌人受到其身上琴音层数×50点伤害，并清除其身上的琴音状态"
	}
	TFJS[8] = {"Ｌ崆峒掌门",
	"Ｗ "
	}
	TFJS[9] = {"Ｌ运转乾坤",
	"Ｗ乾坤大挪移反弹效果 强化至反弹40%伤害（无需运功）",
	"Ｗ乾坤大挪移可同时反弹给两个人",
	"Ｎ",
	"Ｌ特技：逆转乾坤（畅想主角专属）",
	"Ｄ学会乾坤后，被攻击时，有（35+天书数）%的几率触发，可以选择",
	"ＷA.在两格范围内对敌方的攻击落点进行挪移（消耗300点内力）",
	"ＷB.按ESC键取消挪移，本次被攻击必定发动乾坤反弹50%伤害（无需运功）",
	"Ｚ触发『逆转乾坤』后，敌方的误伤伤害将大幅提高，并且对误伤者有杀气效果",
	"Ｚ主角处于爆豆状态时，『逆转乾坤』触发几率提升10%",	
	"Ｎ",
	"Ｌ九阳明尊",
	"Ｗ可使用九阳神功攻击",
	"Ｗ未触发内功加力，护体时，补偿九阳神功加力，护体",
	"Ｎ",
	"Ｒ特色指令：挪移",
	"Ｗ将八格范围内的我方任一队友挪移到指定位置",
	"Ｎ",	
	"Ｇ福缘际遇",
	"Ｗ光明顶密道拿到乾坤时，洗第二格武功",
	"Ｗ武当山见张三丰，洗第三、四格武功"
	}
	TFJS[10] = {"Ｌ光明右使",
	"Ｗ每次受到攻击，增加自身1%的减伤，上限20%"
	}
	TFJS[11] = {"Ｌ光明左使",
	"Ｗ每次攻击，使敌方受到的伤害提高1%，上限20%"
	}
	TFJS[12] = {"Ｌ白眉鹰王",
	"Ｗ华山观武后，鹰爪功威力增加50%",
	"Ｗ自带“鹰王真气”，提供额外的气攻气防"
	}
	TFJS[13] = {"Ｌ金毛狮王",
	"Ｗ狮子吼发动条件放宽为敌方内力低于自身即可",
	"Ｗ七伤拳一震七伤发动几率100%，且一震七伤额外造成7点内伤",
	"Ｗ受到的伤害减少15%",
	"Ｎ",
	"Ｒ特色指令：咆哮",
	"Ｗ使全场敌人进入混乱状态20时序，此状态下敌人行动时的敌我关系为随机",
	"Ｗ不会全部随机到我方，以免出现直接获胜的情况"
	}
	TFJS[14] = {"Ｌ青翼蝠王",
	"Ｗ集气速度提升10点",
	"Ｗ华山观武后，寒冰绵掌威力增加50%",
	"Ｎ",
	"Ｌ吸血蝙蝠",
	"Ｗ攻击时，恢复造成伤害10%的血量（单次攻击吸血上限100点）"
	}
	TFJS[15] = {"Ｌ紫衫龙王",
	"Ｎ",
	"Ｒ特色指令：倾国",
	"Ｗ开启后，接下来受到的前6次攻击将折射给在场随机第三方人物"
	}
	TFJS[16] = {"Ｌ蝶谷医仙",
	"Ｗ医疗上限500点",
	"Ｗ可向队友用药",
	"Ｗ全场友军使用药品效果上升30%",
	"Ｎ",
	"Ｒ特色指令：群疗",
	"Ｗ周围五格范围内的队友时序回内伤并按比例回血，持续20时序"
	}
	TFJS[17] = {"Ｌ蝶谷毒仙",
	"Ｗ用毒能力上限500",
	"Ｎ",
	"Ｒ特色指令：施毒",
	"Ｗ周围五格范围内的敌人时序中毒，持续50时序"
	}
	TFJS[18] = {"Ｌ混元霹雳手",
	"Ｗ自带混元霹雳功加力、护体，大概600威力，可叠加,几率与实战及天书数量有关",
	"Ｗ集气速度+10点",
	"Ｗ使用任何武功高几率连击",
	"Ｗ使用任何武功高几率封穴"
	}
	TFJS[66] = {"Ｌ波斯圣女",
	"Ｗ敌全体移动减三格",
	"Ｗ可使用圣火神功攻击，并追加1200点气攻",
	"Ｎ",
	"Ｒ特色指令：影步",
	"Ｗ标记自身周围一点，被攻击则移动至该处"
	}
	TFJS[81] = {"Ｌ雪岭双姝",
	"Ｗ战场上可发现食材"
	}
	TFJS[82] = {"Ｌ玉面孟尝",
	"Ｗ战场上我方女性角色越多其攻击效果越高"
	}
	TFJS[107] = {"Ｌ华山门人",
	"Ｗ "
	}
	TFJS[108] = {"Ｌ华山门人",
	"Ｗ "
	}
	TFJS[109] = {"Ｌ华山门人",
	"Ｗ "
	}
	TFJS[165] = {"Ｌ子柳传人",
	"Ｗ "
	}
	TFJS[166] = {"Ｌ太上掌门",
	"Ｗ "
	}
	TFJS[167] = {"Ｌ崆峒五老",
	"Ｗ "
	}
	TFJS[169] = {"Ｌ四大神僧",
	"Ｗ "
	}
	TFJS[170] = {"Ｌ四大神僧",
	"Ｗ "
	}
	TFJS[168] = {"Ｌ崆峒五老",
	"Ｗ "
	}
	TFJS[171] = {"Ｌ武当儒侠",
	"Ｗ使用太极拳或太极剑攻击后自动进入防御状态",
	"Ｎ",
	"Ｌ天赋内功",
	"Ｗ修炼纯阳无极功与九阳神功一脉相承后，天赋内功变为九阳神功"
	}
	TFJS[172] = {"Ｌ武当七侠",
	"Ｗ ",
	"Ｎ",
	"Ｌ天赋内功",
	"Ｗ修炼纯阳无极功与九阳神功一脉相承后，天赋内功变为九阳神功"
	}
	TFJS[173] = {"Ｌ波斯风使",
	"Ｗ "
	}
	TFJS[174] = {"Ｌ波斯云使",
	"Ｗ "
	}
    TFJS[175] = {"Ｌ波斯月使",
	"Ｗ "
	}
	TFJS[54] = {"Ｌ志垂日月",
	"Ｗ基础暴击率提升",
	"Ｗ暴击效果随天书数量提升（仅我方有效）上限1.5",
	"Ｎ",
	"Ｌ碧血长风（畅想主角专属）",
	"Ｗ本次行动如击退至少一名敌方，则可再次行动",
	"Ｎ",
	"Ｌ金蛇传人",
	"Ｗ使用暗器金蛇锥必定造成3倍伤害",
	"Ｎ",
	"Ｚ＜未解锁＞",
	"Ｗ？？？？？？",
	"Ｗ？？？？？？"
	}
	TFJS["54-1"] = {"Ｌ志垂日月",
	"Ｗ基础暴击率提升",
	"Ｗ暴击效果随天书数量提升（仅我方有效）",
	"Ｎ",
	"Ｌ碧血长风（畅想主角专属）",
	"Ｗ本次行动如击退至少一名敌方，则可再次行动",
	"Ｎ",
	"Ｌ金蛇传人",
	"Ｗ使用暗器金蛇锥必定造成3倍伤害",
	"Ｎ",
	"Ｚ长平公主的眷恋",
	"Ｗ神行百变闪避/减伤几率提高",
	"Ｗ生命值低于30%时，可触发金蛇奥义"
	}
	TFJS[91] = {"Ｌ青青子衿",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ金蛇山洞拔出金蛇剑，洗第一格武功"
	}
	TFJS[83] = {"Ｌ纤纤铁手",
	"Ｗ使用五毒神掌攻击，随机2-5倍威力",
	"Ｗ自带“红袖拂风”加力、护体，500威力，可叠加（几率与天书数、实战相关）",
	"Ｎ",
	"Ｌ五毒教主",
	"Ｗ被攻击无视毒抗使攻击者中毒45~50点",
	"Ｗ用毒能力上限500",
	"Ｎ",
	"Ｌ特技：含沙射影",
	"Ｗ暗器攻击范围提升至7×7方阵"
	}
	TFJS[176] = {"Ｌ五毒教姑",
	"Ｗ "
	}
	TFJS[182] = {"Ｌ五丁手",
	"Ｗ "
	}
	TFJS[183] = {"Ｌ没影子",
	"Ｗ "
	}
	TFJS[184] = {"Ｌ护国真人",
	"Ｗ使用任何武功高几率暴击 "
	}
	TFJS[185] = {"Ｌ神剑仙猿",
	"Ｗ攻击时高几率造成封穴",
	"Ｗ等待时自动蓄力（无法触发龙象蓄力等效果）"
	}
	TFJS[186] = {"Ｌ神拳无敌",
	"Ｗ使用拳法攻击追加100点真实伤害，如未装备武器，则此加成翻倍"
	}
	TFJS[187] = {"Ｌ八面威风",
	"Ｗ "
	}
	TFJS[188] = {"Ｌ铜笔铁算盘",
	"Ｗ "
	}
	TFJS[77] = {"Ｌ珠联璧合",
	"Ｗ使用夫妻刀法无误伤",
	"Ｗ可装备专属武器鸯刀",
	"Ｎ",
	"Ｌ秀外慧中",
	"Ｗ修炼武功秘籍时，兵器值成长翻倍",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ获得夫妻刀法，洗第一格武功"
	}
	TFJS[592] = {"Ｌ料敌先机",
	"Ｗ进入战斗的初始集气位置为1000，自身移动步数锁定为10格，免疫暗器",
	"Ｎ",
	"Ｌ无我无剑",
	"Ｗ被攻击时，先手反击敌方。",
	"Ｎ",
	"Ｇ剑道神话",
	"Ｗ攻击与被攻击必触发<剑魔再临>/<九剑真传>特效。",	
	"Ｗ战斗中，个人武常计算结果必定不会低于敌方，集气速度锁定全场最高",	
	}
	
	TFJS[510] = {"Ｌ曲夕烟隙",
	"Ｗ30%概率触发“曲夕烟隙”混乱目标，使目标随机移动",
	"Ｎ",
	"Ｌ曲径通幽",
	"Ｗ持瑶琴威力翻倍，攻击时30%概率触发“曲径通幽”必中",
	}
	
	TFJS[511] = {"Ｌ盗圣",
	"Ｗ攻击时随机窃取敌方一项可用状态，若为通用状态则可转给自身",
	"Ｗ拥有龟息功全部效果",
	"Ｎ",
	"Ｌ隔空点穴",
	"Ｗ造成封穴时，封穴增加10点，被攻击时对目标造成10点封穴",
	"Ｎ",
	"Ｌ踏雪无痕",
	"Ｗ移动距离增加2格",
	}
	
	TFJS[504] = {"Ｌ剑法无极",
	"Ｗ剑法攻击时无视目标１０％防御，每学会一门剑法至极，剑法破防效果增加2％",
	"Ｎ",
	"Ｌ神游太虚",
	"Ｗ免疫正面90度攻击，90~180度角30%免疫攻击（暴怒必定免疫）。移动独特动画",
	}
    
	--喵太极
	TFJS[92] = {"Ｌ指挥若定",
	"Ｗ在队伍中时，可以在战斗开始前布阵",
	"Ｎ",
	"Ｌ扑朔迷离",
	"Ｗ所有攻击无误伤",
	"Ｗ与主角同时在场时，主角集气速度增加2点",
	"Ｗ战斗开始后的前三次被攻击不受伤害（需主角7书觉醒后）",
	"Ｎ",
	"Ｒ特色指令：换装",
	"Ｗ使用后改变自身外形，并将获得不同的内功"
	}
	--韦小宝
	TFJS[601] = {"Ｌ机敏无双",
	"Ｗ战斗开始前50时序，受到的伤害不超过50点",
	"Ｎ",
	"Ｒ特色指令：口才",
	"Ｗ使一名敌方进入沉睡状态，此状态无法集气，不会自行解除，受到攻击会醒来",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ鹿鼎记鳌府密室剧情，洗第一、二格武功"
	}
	--鳌拜
	TFJS[603] = {"Ｌ满洲勇士",
	"Ｗ主运金刚不坏体，必定发动\"金刚不坏\"特效"
	}
	--阿青
	TFJS[604] = {"Ｌ天元剑气",
	"Ｗ使用剑系武功攻击时，敌方御剑系数按零计算",
	"Ｎ",
	"Ｌ听风辨位",
	"Ｗ无视敌方的闪避效果（包括刺目，轻功，天赋等）",
	"Ｎ",
	"Ｌ越女剑仙",
	"Ｗ使用越女剑法攻击无误伤",
	"Ｗ每次行动前解除自身所有异常",
	"Ｗ自带“九霄仙息”护体，增加自身御剑系数×5点气防",
	"Ｗ战场中增加自身御剑系数点攻防值",
	"Ｎ",	
	"Ｇ福缘际遇",
	"Ｗ侠客正获得太玄第二格洗太玄神功"	
	}
	TFJS[605] = {"Ｌ惊才绝艳",
	"Ｗ武功威力提高10%，加力/护体/出招几率提高10%，总气攻提高10%",
	"Ｎ",
	"Ｌ姑射仙姿",
	"Ｗ被攻击时必发动\"轻云蔽月\"，免疫攻击10时序，冷却时间50时序",
	"Ｗ攻击时几率发动\"流风回雪\"，本次攻击必定造成冰封"
	}
	--阿凡提
	TFJS[606] = {"Ｌ踏沙无痕",
	"Ｗ移动格数+3，攻击后可以再次移动",
	"Ｎ",
	"Ｌ西域战神",
	"Ｗ拥有专属坐骑毛驴",
	"Ｗ休息时自带蓄力兼防御效果"
	}
	--焦宛儿
	TFJS[607] = {"Ｌ乱世浮萍",
	"Ｗ我方全体连击率提高10%"
	}
	--赵敏
	TFJS[609] = {"Ｌ机智多谋",
	"Ｗ在场时，我方全体获得如下光环：",
	"Ｗ处于蓄力状态时，增加自身20%减伤（蓄力必定成功）",
	"Ｗ处于防御状态时，有20%几率闪避",
	"Ｎ",
	"Ｌ绍敏郡主",
	"Ｗ被攻击时，攻击方会损失其造成伤害30%的血量",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ神雕邪线襄阳剧情，洗第二格武功，天赋内功洗为天魔功"
	}
	--公孙止
	TFJS[616] = {"Ｌ绝情谷主",
	"Ｗ本方每阵亡一名队友，集气速度增加2点",
	"Ｎ",
	"Ｌ特技：闭穴功",
	"Ｗ受到的封穴降低50%"
	}
	--裘千尺
	TFJS[617] = {"Ｌ铁掌莲花",
	"Ｗ作为畅想主角时可以获得年轻漂亮的头像贴图"
	}
	--郭襄
	TFJS[626] = {"Ｌ小东邪",
	"Ｗ无需修炼三种武功即可触发桃花绝技",
	"Ｎ",
	"Ｒ特色指令：玲珑",
	"Ｗ可自由切换第一格武功为弹指神通/玉萧剑法/落英神剑掌，不消耗回合"
	}
	--郭襄
	TFJS["626-1"] = {"Ｌ小东邪",
	"Ｗ无需修炼三种武功即可触发桃花绝技",
	"Ｎ",
	"Ｌ峨眉祖师",
	"Ｗ领悟“诸天化身步”，被攻击时有30%几率完全闪避，并锁定反击全场",
	"Ｗ造成的伤害等同于自身五系兵器值中最高的一项",
	"Ｎ",
	"Ｒ特色指令：玲珑",
	"Ｗ可自由切换第一格武功为弹指神通/玉萧剑法/落英神剑掌，不消耗回合"
	}
	--神雕
	TFJS[628] = {"Ｌ雕兄",
	"Ｗ使用玄铁剑法时，有几率发动重剑真传",
	"Ｎ",
	"Ｌ大鹏展翅",
	"Ｗ使用玄铁剑法时，攻击范围变为可移动",
	"Ｎ",
	"Ｌ鹏程万里",
	"Ｗ移动格数+3"
	}
	--阿九
	TFJS[629] = {"Ｌ长平公主",
	"Ｗ每次行动前有60%几率使敌方全体集气位置倒退150",
	"Ｗ暴怒时集气免疫封穴且不受异常状态影响",		
	"Ｎ",
	"Ｇ浴火凤凰(畅想单通专享)",
	"Ｗ华山击败玉真子觉醒领悟：",
	"Ｗ“凤鸣九霄”：满怒触发范围伤害。",
	"Ｗ“凤凰涅槃”：机率触发杀气减999，伤害减99，"	,
	"Ｗ“浴火重生”：机率复活一次",	
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ获得“神行百变”第三格洗神百变1级",
	}
	--周芷若
	TFJS[631] = {"Ｌ秀若芝兰",
	"Ｗ面板上每个外功增加1点集气，每个内功增加4%减伤，最大40%减伤",
	"Ｎ",
	"Ｌ谁与争锋",
	"Ｗ装备『倚天剑』时，全部剑法威力+200",
	"Ｗ使用九阴白骨爪，攻击时无视敌方毒抗",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ倚天邪线少林剧情，可选择洗第一格武功",
	"Ｗ倚天邪线少林剧情，洗第二格武功，天赋内功洗为九阴神功",
	"Ｗ倚天邪线战三渡时，可领悟左右互搏术（发动几率70%）"
	}
	--逍遥子
	TFJS[634] = {"Ｌ长春不老",
	"Ｗ自带不老长春功",
	"Ｗ减伤30%伤害并用双倍内力抵消伤害值",
	"Ｗ击败无崖子直接激活“逍遥御风”(不需学小无相/八荒/北冥)",	
	"Ｎ",
	"Ｌ逍遥祖师",
	"Ｗ必发动“梅花三弄”特效之一",
	"Ｗ梅花一弄：造成散功30时序，不可主运内功",
	"Ｗ梅花二弄：减少敌方当前内力值的5%",
	"Ｗ梅花三弄：忽视绝对气防",	  	
	}	
	--李白
	TFJS[636] = {"Ｌ青莲剑仙",
	"Ｗ自带青莲剑法高连",
	"Ｗ“谪仙观气”攻击与被攻击发动，兵器值不会低于对方",		
	"Ｎ",
     "Ｌ侠客行",
	"Ｗ“十步杀一人”：击退敌人发动可再次行动",
	"Ｗ“深藏身与名”：攻击后30时序内50%概率闪避攻击",
	"Ｎ",  		
     "Ｚ绝技：青莲剑歌",
	"Ｗ华山后山觉醒后领悟",
	"Ｗ“青莲剑歌·长风当歌剑当扬”：满怒剑法攻击发动大范围伤害附加御剑值伤害并给目标添加“创伤”DEBUFF",
    "Ｗ““创伤”DEBUFF：不能回复任何任何状态",
	
	}
		--李寻欢
	TFJS[498] = {"Ｌ小李探花",
	"Ｗ敌人移动-1，自身移动+2",
	"Ｗ自带蜻蜓三抄水，30%躲避攻击",
	"Ｗ战斗胜利获得暗器",	
	"Ｗ7书领悟暗器为范围攻击",	
	"Ｎ",
	"Ｒ特色指令：飞刀",
	"Ｗ100时序暗器攻击”暴击5~8倍， ",
	"Ｗ华山觉醒后20%暴击10倍~12倍",
	"Ｗ攻击必命中",		
	"Ｗ每次开启消耗体力20，内力1000",
	"Ｎ",  
	"Ｄ惊才绝艳 ",
	"Ｗ自带100武常",	
	"Ｗ被攻击系数必然不低于对方",
	"Ｗ被攻击集气不会少于300",		
	}
		--冯蘅
	TFJS[588] = {"Ｌ岛主夫人",
	"Ｗ桃花岛武学威力+200",
	"Ｗ特效发动机率+10",		
	"Ｎ",
	"Ｌ过目不忘",
	"Ｗ修炼武功获得双倍三围属性",
	"Ｗ受到武功威力伤害-10%",
	"Ｎ",  
    "Ｇ福缘奇遇",
	"Ｗ桃花岛招亲后，第2格洗九阴神功1级，天内洗九阴神功",	
	"Ｗ射雕正线牛家村3格洗弹指神通，天外洗弹指神通",
	"Ｗ射雕邪线云岭山洞3格洗九阴白骨爪，天外洗九阴白骨爪",		

	}
		--斗酒僧
	TFJS[638] = {"Ｌ九阳至尊",
	"Ｗ内力上限9999，初始武学常识100",
	"Ｗ九阳神功必加力护体",
	"Ｗ九阳神功招式可以选择",
	"Ｗ反震40%伤害",
	"Ｎ",
	"Ｒ氤氲紫气",
	"Ｗ受到的气攻与伤害减少30%。 ",
	"Ｗ免疫连击。",
	}	
		--萧半和
	TFJS[189] = {"Ｌ晋阳大侠",
	"Ｗ天赋内功自动运功，混元功范围+1",
	"Ｗ连击率与暴击率+50%。",
	"Ｗ攻击时必触发“混元一气”造成敌全体内伤。增加1000气功",
	"Ｎ",
	"Ｇ仁者无敌",
	"Ｗ拥有仁者二次判定，特效+10。 ",
	"Ｎ",  
	"Ｇ半和太监",
	"Ｗ修炼葵花宝典没有惩罚，可以使用葵花神功攻击 。",	
	"Ｗ笑邪击败葵花尊者天内洗葵花神功，",
	}
		--西门吹雪
	TFJS[500] = {"Ｌ剑神",
	"Ｗ进战满集气行动",
	"Ｗ每个剑法到极减少伤害4% ",	
	"Ｎ",  
	"Ｇ绝技：剑道巅峰 五方行尽(需资质>79)",		
	"Ｒ击败谢云流领悟“剑道巅峰 五方行尽”可触增加一次行动",
	"Ｒ攻击时发动“剑道化身.破苍穹”无视敌方御剑系数50%",
	"Ｒ被攻击发动“化三清”无视敌方御剑系数50%",	
	"Ｎ",  	
	"Ｇ福缘奇遇（专属剧情）",
	"Ｗ战胜谢云流第一格洗斩流剑术，第二格洗太虚剑意”",	
	"Ｗ天赋外功洗斩流剑术，天赋内功洗太虚剑意”",		
	}		
		--胡一刀
	TFJS[633] ={"Ｌ辽东大侠",
	"Ｗ自带“飞天神行”主运效果。",
	"Ｗ自身免疫冰封。",
	"Ｗ装备冷月宝刀后胡家刀法威力+300",		
	"Ｗ装备冷月刀攻击必冰封。",
	"Ｎ",
	"Ｇ刀剑归真",	
	"Ｗ飞雪邪线杀苗/飞雪正线胜苗第一格洗胡刀1级，领悟刀剑归真绝技：",
	"Ｒ不悔：伤害增加10%，时序增加怒气",	
	"Ｒ贯通：不修炼苗家剑法即可发动刀剑归真",
	"Ｒ刀剑归真：攻击触发动刀剑归真时触发刀剑绝技。",
	"Ｒ刀剑绝技：暴怒触发，必定连击首击出胡刀二击出苗剑绝技，大范围伤害杀气。",
	}	
	--萧秋水
	TFJS[652] = {"Ｌ神州大侠",
	"Ｗ修炼辟邪剑法与葵花宝典没有惩罚，自带“忘情天书”护体+1200气防", 
	"Ｗ气血越低防御越高，最低15%，最高35%",	
	"Ｎ",
	"Ｄ忘情天书",
	"Ｗ1书领悟：“天意”死亡时必触发“天意”复活一次",
	"Ｗ2书领悟：“水逝”增加冰封，冰封过50点概率发动“月映”冰冻5时序", 
	"Ｗ3书领悟：“火延”增加燃烧，燃烧过50点概率发动“日明”点燃目标",    
	"Ｗ4书领悟：“土掩”减伤30点，机率发动“风流”完全闪避攻击",         
	"Ｗ5书领悟：“云翳”必杀集气200，自身暴怒后概率“我无”免伤", 
	"Ｎ", 	
     "Ｇ剑气飞纵（6书领悟）",
	"Ｇ连击不减伤害，攻击范围+1，",
	"Ｇ攻击时不随距离减伤害，目标距离越远，伤害越高",
	"Ｎ",       
      "Ｒ绝技：惊天一剑",
	"Ｗ7书华山后山觉醒后领悟",
      "Ｒ使用剑法暴怒时可使用“天剑”指令，无视敌方御剑系数30%防御30%",
	}

	--梁萧
	TFJS[635] = {"Ｌ西昆仑",
	"Ｗ自带“鲸息功”与“碧海惊涛掌”", 	
	"Ｗ主运鲸息功或使用碧海惊涛掌可以触发六大奇劲之一",	
	"Ｎ",
    "Ｌ星罗散手",
	"Ｗ用拳掌攻击时，必触发“星罗散手”给对方造成封穴",
	"Ｎ",
     "Ｒ绝技：谐之道",
    "Ｒ自身不会有破绽，暴怒时发动必中破绽，",
    "Ｒ击中敌方破绽高机率造成敌方5时序集气暂停",
	}
	--陆渐
	TFJS[497] = {"Ｌ金刚门人",
	"Ｗ攻击时为自己添加一个100时序“金刚法相”增益BUFF：", 
	"Ｗ攻击机率触发大金刚神力，无视绝对气防+1200气攻",	
	--"Ｗ初始+20暴击率，每本天书+5%",
	--"Ｗ七书无视防御40%",	
	"Ｎ",
    "Ｌ三十二身相",
	"Ｗ攻击时或被攻击时机率触发持续100时序“一合相”BUFF,减伤15%",
	"ＷBUFF“一合相”存在期间，才会发动以下身相：",
	"Ｗ1书领悟[神鱼相]：攻击时机率追加一次连击，暴怒必连",	
	"Ｗ2书领悟[白毫相] ：被攻击机率只受到100点气攻",
	"Ｗ3书领悟[雀母相]：被攻击机率减伤50点",	
	"Ｗ4书领悟[大自在相]：被攻击机率+200集气",	
	"Ｎ", 
    "Ｌ补天劫奴",
	"Ｗ攻击时偷取敌方物品,攻击与被攻击都算拳系",	
	"Ｎ", 
     "Ｚ绝技：海之道",
	"Ｒ华山后山觉醒后领悟",
    "Ｒ7书领悟 “海之道.海纳百川” 被攻击时无视对方系数",
    "Ｒ10书领悟“海之道.上善若水” 攻击时无视对方系数 ",	
	}	
	--黄衫女
	TFJS[640] = {"Ｌ古墓后人",
	"Ｗ玉女心经特效机率增加，",
	"Ｗ无需主运九阴神功可触发九阴白骨爪极意，",	
	"Ｗ华山觉醒九阴白骨爪威力+50%,",
	"Ｗ7书九阴神爪极意40%三连，暴怒必三连",	
	"Ｎ",
	"Ｌ翩若惊鸿",
	"Ｗ学会天罗地网后，每次攻击增加1~2层“疾风”每层+2.5%集气，最多10层",
	"Ｗ被男性目标攻击伤害减少10%",
	"Ｎ",
    "Ｚ绝技:广寒清辉",
	"Ｗ华山后山觉醒后暴怒触发“广寒清辉”必冻结目标集气5时序",					
	}
	--黄赏
	TFJS[637] = {"Ｌ九阴至尊",
	"Ｗ九阴神功自动运功",
	"Ｗ“易筋锻骨”：免疫封穴，免疫暴击伤害",
	"Ｗ“大伏魔拳”：攻击时触发大伏魔拳附加目标生命最大值5~10%的伤害",
	"Ｗ九阴神爪极意必两连，40%机率三连，暴怒必三连。",		
	"Ｎ",
	"Ｌ大道归藏(畅想专享)",
	"Ｗ无视条件修炼武功",
	"Ｗ所有武功可以到极",					
	}
	--寇仲
	TFJS[578] = {"Ｌ大唐双龙",
	"Ｗ阳内攻击必灼伤，概率点燃",
	"Ｗ无视内属修炼刀法",	
	"Ｎ",
	"Ｌ井月八法",
	"Ｗ每个刀法到极领悟一招",
	"Ｗ每一招加暴击伤害/暴击概率/加气攻(上限8个)", 		
	}
	--袁紫衣
	TFJS[587] = {"Ｌ紫衣银鞭",
	"Ｗ黄沙万里鞭威力加300，白莽鞭法威力加300",
	"Ｗ每修炼一个奇门武功到极，减伤提高4%（上限7个）",	
	"Ｎ",	
	"Ｇ福缘奇遇（专属剧情）",
	"Ｗ倚天正线光明顶胜灭绝第一格白莽鞭法，天外洗白莽鞭法”",	
	"Ｗ倚天邪线胜三渡第一格洗金刚伏魔圈,天外洗金刚伏魔圈”",
	"Ｗ飞雪拿到飞天神行,第三格洗飞天神行1级,天轻洗飞天神行”",	
	}
	--何足道
	TFJS[586] = {"Ｌ昆仑三圣",
	"Ｗ琴音：攻击时为敌全体添加1~4层琴音BUFF,最多30层",
	"Ｗ棋势：攻击目标附带天数书量*10的真实伤害",
	"Ｗ百鸟朝凤：每攻击一次给自身添加1~3层曲风，曲风BUFF>20层,消耗20层曲风给敌全体造成附加琴音层数*10真实伤害",	
	"Ｎ",
	"Ｌ何足道哉",
	"Ｗ气血越少连击、暴击越高",	
	"Ｎ",  	
	"Ｇ福缘奇遇（专属剧情）",
	"Ｗ获得九阳神功，天内洗九阳神功",	
	"Ｗ获得两仪剑法，第1格洗两仪剑法",
	"Ｗ获得两仪刀法，第2格洗两仪刀法",	
	}
	--司空摘星
	TFJS[579] = {"Ｌ千变万幻",
	"Ｗ机率(20+天书数)触发“千变.相由心生”只受到误伤，",
	"Ｗ受到伤害值随天书数增加而减少",
	"Ｗ挨打增加集气速度，集气上限99,集气不受异常状态影响",	
	"Ｎ",
	"Ｌ盗王之王",
	"Ｗ攻击偷取敌方身上的物品",	
	"Ｗ增加敌方存活人数*5的集气速度",
	"Ｗ行动后可再次移动",	
	}		
	--步惊云
	TFJS[584] = {"Ｌ不哭死神",
	--"Ｗ自带“虚云劲”减少受到气攻，时序回复内力",
	--"Ｗ“云踪魅影 ”集气速度提升30%,无视敌人位置移动10格，获得梯云纵领悟 ",
	"Ｎ",
	"Ｒ云无常",
	"Ｗ排云掌：随天书数量增加领悟招式",	
	"Ｗ使用拳掌时触发招式。招式气攻、伤害、破防（最大36%）随招式增加",	
	"Ｗ第十到第十二式无视绝对气防与大概率破防",		
	"Ｎ",  	
	"Ｒ剑廿三",
	"Ｗ自带1-14式圣灵剑法，使用剑法时随机出招增加气攻",	
	"Ｗ15-22式需获得天书领悟，",
	"Ｗ获得9本天书后满怒时使用剑法触发剑廿三大范围攻击并概率使目标昏迷1回合",	
	}	
	--莫大
	TFJS[20] = {"Ｚ七弦无形剑",
	"Ｗ华山觉醒后领悟",
	"Ｗ“绝技·七弦无形剑·无形剑气”用剑法攻击暴怒触发",
	"Ｎ",
    "Ｌ潇湘夜雨",		
	"Ｗ剑法攻击范围+1",
	"Ｗ“笑傲江湖”：攻击时机率发动笑傲江湖追加气攻",		
	}
	--霍都
	TFJS[84] = {"Ｌ小王爷",
	"Ｗ武功练到极，减少受到的3%伤害与杀气，最多减少21%",	
	}				
	--鹤笔翁
	TFJS[647] = {"Ｌ玄冥二老",
	"Ｗ使用玄冥神掌，必定发动极意"
	}
	--鹿杖客
	TFJS[648] = {"Ｌ玄冥二老",
	"Ｗ使用玄冥神掌，必定发动极意"
	}

	--宁中则
	TFJS[649] = {"Ｌ娇美人妻",
	"Ｗ被攻击时，消耗攻击方5-10点体力",
	"Ｗ使用剑法机率触发“宁氏一剑·无双无对”附加虚弱状态1~3回合",	
	"Ｎ",
	"Ｄ华山玉女",
	"Ｗ紫霞神功必发动紫霞剑气",
	"Ｗ剑法攻击必触发“玉女十九剑”增加自身连击率，暴怒必连",	
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ获得五岳剑诀第二格洗五岳剑诀",
	}
	--白绣
	TFJS[582] = {"Ｌ冰川天女",
	"Ｗ敌方全体集气-5",
	"Ｗ攻击必冰封，冰封超过50机率冻结目标",	
	"Ｗ追加冰封值的真实伤害，自身免疫冰封",		
	"Ｎ",
	"Ｄ雪花神剑",
	"Ｗ获得雪山剑谱后领悟“雪花神剑”：",
	"Ｗ雪山剑法威力翻倍",
	"Ｗ每个武功到极增加雪山剑法100威力",
	"Ｗ攻击时概率触发“雪花神剑”，增加杀气，暴怒必触发",	
	}
	--丁当
	TFJS[581] = {"Ｌ丁丁当当",
	"Ｗ敌方全体集气-5",
	"Ｗ攻击必灼烧",	
	"Ｗ击败丁不三丁不四，金乌刀法威力增加300，只学金乌刀法可触发举火燎原",		
	"Ｎ",
	"Ｄ机灵古怪",
	"Ｗ自身集气位置概率前进30，暴怒时3倍",
	"Ｗ集气位置不会低于0",
	}
	--陆无双
	TFJS[580] = {"Ｌ银弧刀",
	"Ｗ攻击必造成流血",
	"Ｗ暴击率+30",	
	"Ｎ",
	"Ｄ五毒真经",
	"Ｗ击败李莫愁天赋外功洗为",	
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ蝴蝴谷帮胡青牛治好腿伤 轻功+50",
	"Ｗ获得玉女剑法 第2格洗玉女剑法1级 ",
	"Ｗ获得玉女心经 第3格洗玉女心经1级，天内洗玉女心经 ",
	"Ｗ获得天罗地网 第5格洗天罗地网1级，天轻洗天罗地网 ",	
	}	
	--仪琳
	TFJS[583] = {"Ｌ小尼姑",
	"Ｗ被攻击伤害-15%，自身伤害-10%",
	"Ｗ获得万花剑法 1格洗万花剑法1级",	
	"Ｎ",
	"Ｄ天域幻音",
	"Ｗ行动结束时友方行动结束清除流血、中毒、冰封、灼烧、内伤并回复最多200点生命值",

	}	
	--拳王
	TFJS[547] = {"Ｌ盖世神拳",
	"Ｗ每修炼一个拳法到极，伤害提升5%、受伤害降低5%（上限7个）",
	"Ｎ",
	"Ｄ降龙极意",
	"Ｗ使用降龙十八掌，40%几率发动极意",
	"Ｎ",
	"Ｄ黯然极意",
	"Ｗ血量低于70%或内伤大于30时，使用黯然销魂掌有几率触发极意",
	"Ｗ血量越低，内伤越高，几率越高，满足条件时暴怒必定触发",
	"Ｗ触发黯然极意必定连击",
	"Ｎ",
	"Ｚ绝技：天道惊雷撼",
	"Ｗ华山后山觉醒后领悟",
	"Ｗ至少修炼9个武功，拳掌系数>=120，使用拳掌武功攻击几率触发",
	"Ｗ资质越高，触发几率越高",
	"Ｗ攻击无误伤，攻击效果提升33.3%，大幅提高封穴几率，追加1200气攻",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ可以花一万银两在云岭洞学习\"迷踪步\""
	}
	TFJS[548] = {"Ｌ灵犀一指",
	"Ｗ初始自带15%独立封穴几率",
	"Ｗ每修炼一个指法武功到极，封穴几率提高5%（上限7个）",
	"Ｗ使用六脉神剑的内力消耗减半",
	"Ｎ",
	"Ｚ绝技：点墨山河",
	"Ｗ华山后山觉醒后领悟",
	"Ｗ至少修炼9个武功，指法系数>=120，使用指法武功攻击几率触发",
	"Ｗ资质越高，触发几率越高",
	"Ｗ攻击无误伤，不造成怒气，同时清除敌方一半怒气，追加1100气攻",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ可以花一万银两在云岭洞学习\"迷踪步\""
	}
	TFJS[549] = {"Ｌ剑神一笑", 
	"Ｗ每修炼一个剑法到极，集气速度+2（上限7个）",
	"Ｗ使用玄铁剑法时，有几率发动重剑真传",
	"Ｗ可无视自宫需求修炼葵花宝典、辟邪剑法",
	"Ｎ",
	"Ｚ绝技：一剑镇神州",
	"Ｗ华山后山觉醒后领悟",
	"Ｗ至少修炼9个武功，御剑系数>=120，使用剑系武功攻击几率触发",
	"Ｗ资质越高，触发几率越高",
	"Ｗ攻击无误伤，锁定攻击战场上大范围敌方目标，追加1500气攻",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ可以花一万银两在云岭洞学习\"迷踪步\""
	}
	TFJS[550] = {"Ｌ傲世狂刀", 
	"Ｗ每修炼一个刀法到极，受伤害、杀气降低5%（上限7个）",
	"Ｗ使用胡家刀法有40%几率触发极意，暴怒必触发",
	"Ｗ使用火焰刀法和沧溟刀法时，特效触发几率追加二次判定",
	"Ｎ",
	"Ｚ绝技：羽葬煌炎斩",
	"Ｗ华山后山觉醒后领悟",
	"Ｗ至少修炼9个武功，耍刀系数>=120，使用刀系武功攻击几率触发",
	"Ｗ资质越高，触发几率越高",
	"Ｗ攻击无误伤，无视绝对气防，追加1500气攻，行动后自身怒气恢复25点（可叠加）",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ可以花一万银两在云岭洞学习\"迷踪步\""
	}
	TFJS[551] = {"Ｌ奇门无双", 
	"Ｗ初始自带15%闪避",
	"Ｗ每修炼一个奇门武功到极，闪避率提高5%（上限7个）",
	"Ｗ打狗棒法『天下无狗』的触发几率提高，追加二次判定",
	"Ｎ",
	"Ｚ绝技：千机龙绝闪",
	"Ｗ华山后山觉醒后领悟",
	"Ｗ至少修炼9个武功，奇门系数>=120，使用奇门武功攻击几率触发",
	"Ｗ资质越高，触发几率越高",
	"Ｗ攻击无误伤，必定造成流血及封穴，追加1000气攻",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ可以花一万银两在云岭洞学习\"迷踪步\""
	}

	TFJS[552] = {"Ｌ绝世天罡", 
	"Ｗ内力属性为天罡，同时拥有阴、阳、调和三种内力属性的特性",
	"Ｗ可使用内功攻击，内功可修炼至极",
	"Ｗ斗转反击时，无视兵器值需求必定发动离合参商",
	"Ｎ",
	"Ｄ天罡真气",
	"Ｗ使用内功攻击时50%几率触发天罡真气，提升气攻",
	"Ｎ",
	"Ｚ天赋内功",
	--"Ｗ游戏开始赞择内力属性时，阴/阳/调和分别对应天赋内功九阴神功/九阳神功/易筋神功",
	"Ｗ学会天赋内功后，进入战斗会自动运行",
	"Ｗ天赋内功不影响正常运功，即可同时运行两种内功",
	"Ｗ手动选择运功时，无法选择九阴/九阳/易筋",
	"Ｗ三神功真气只能触发天赋内功选择的",	
	"Ｎ",
	"Ｚ绝技：斗焰霸罡劲",
	"Ｗ华山后山觉醒后领悟",
	"Ｗ至少修炼9个武功，使用内功攻击40%几率触发",
	"Ｗ攻击无误伤，伤害提高30%，兵器值判定必定优势，无视绝对气防，追加1300气攻",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ可以花一万银两在云岭洞学习\"迷踪步\""
	}
	TFJS[553] = {"Ｌ仁者无敌", 
	"Ｗ特效机率+10",
	"Ｗ道德值增加伤害道德/100伤害",
	"Ｗ道德值减少伤害道德/100伤害",
	"Ｎ",
	"Ｄ善恶有报	",
	"Ｗ攻击（道德-40）概率1.5倍伤害或（道德-100）概率0.5倍伤害",
	}	
	TFJS[554] = {"Ｌ回天圣手", 
	"Ｗ初始医疗200，解毒200，用毒200；医疗上限400，用毒上限400，解毒上限400",
	"Ｗ医疗范围提升至7×7方阵",
	"Ｗ每时序随机恢复自身生命、内力、中毒、内伤",
	"Ｎ",
	"Ｚ绝技：八门聚万象",
	"Ｗ华山后山觉醒后领悟",
	"Ｗ至少修炼9个武功，体力大于50点，行动结束后几率触发",
	"Ｗ资质越高，触发几率越高",
	"Ｗ发动之后立即获得再次行动机会，需消耗10点体力",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ可以花一万银两在云岭洞学习\"迷踪步\""
	}
	TFJS[555] = {"Ｌ欲天摩罗",
	"Ｗ初始解毒300，用毒300；用毒上限500，解毒上限500",
	"Ｗ上毒范围提升至7×7方阵，可以给自己上毒",
	"Ｗ每时序随机增加自身中毒程度",
	"Ｗ自身中毒越深，能力反而越强",
	"Ｎ",
	"Ｚ绝技：天人五衰",
	"Ｗ华山后山觉醒后领悟",
	"Ｗ至少修炼9个武功，自身中毒100点，攻击时几率触发",
	"Ｗ资质越高，触发几率越高",
	"Ｗ攻击无误伤，伤害提高30%，本次攻击必定附加五种异常状态，清空自身中毒值",
	"Ｎ",
	"Ｇ福缘际遇",
	"Ｗ可以花一万银两在云岭洞学习\"迷踪步\""
	}
	--张家辉
	TFJS[651] = {"Ｒ人物介绍",
	"Ｗ大扎好，我系渣渣辉，探挽懒月，介四里没有挽过的船新版本，挤需体验三番钟，",
	"Ｗ里造会干我一样，爱象节款游戏。",
	"Ｎ",
	"Ｌ人物特性",
	"Ｗ自带四件传奇饰品，拥有极强大的特效"
	}
	
	--主角专属介绍
	ZJZSJS = {"Ｒ天赋外功",
	"Ｄ获得方式：拿到七本天书后，场景【华山后山】对话谢无悠",
	"Ｄ可选择一个武功作为天赋外功",
	"Ｎ",
	"Ｒ天赋内功",
	"Ｄ获得方式：拿到十本天书后，场景【华山后山】挑战谢无悠胜利",
	"Ｄ可选择一个内功作为天赋内功",
	}
	
    WPTX2 = {}
    WPTX2[0] = "时序恢复1点内伤，持续50时序"
    WPTX2[1] = "时序恢复2点生命，满实战翻倍，持续100时序"
    WPTX2[3] = "时序恢复8点内力，持续200时序"
    WPTX2[9] = "时序恢复1点中毒，持续50时序"
    WPTX2[10] = "时序恢复1点中毒，持续50时序"
    WPTX2[11] = "提升战场抗毒100点，持续至战斗结束"
    WPTX2[22] = "解除冰封50点并时序恢复1点冰封，持续50时序"
    WPTX2[23] = "解除灼烧20点并时序恢复1点灼烧，持续50时序"
    WPTX2[24] = "解除流血50点并时序恢复1点流血，持续100时序"
    WPTX2[25] = "清除所有基础异常"
	--物品特效说明
	WPTX = {}
	--绣花针
	WPTX[349] = {"必破气防，破防10%",
	"破防20%",
	"破防30%",
	"破防40%",
	"破防50%",
	"破防60%，进战集气增加900。"
	}
	--青冥剑
	WPTX[335] = {"根据御剑能力提升剑法范围",
	"根据御剑能力提升剑法攻击范围",
	"根据御剑能力提升剑法攻击范围",
	"根据御剑能力提升剑法攻击范围",
	"根据御剑能力提升剑法攻击范围",
	"根据御剑能力提升剑法攻击范围"
	}
	--白猿
	WPTX[326] = {"猿公剑法/越女剑法威力+200",
	"猿公剑法/越女剑法威力+200",
	"猿公剑法/越女剑法威力+200",
	"猿公剑法/越女剑法威力+200",
	"猿公剑法/越女剑法威力+200",
	"猿公剑法/越女剑法威力+200"
	}
	--伏魔禅杖
	WPTX[323] = {"伏魔杖法威力+200",
	"攻击时60%几率造成内伤5~15点",
	"攻击时70%几率造成内伤5~15点",
	"攻击时80%几率造成内伤5~15点",
	"攻击时90%几率造成内伤5~15点",
	"攻击时必造成内伤，增加“世尊降魔”发动机率10%"
	}
	--狼牙
	WPTX[320] = {"攻击时50%几率造成流血",
	"攻击时60%几率造成流血",
	"攻击时70%几率造成流血",
	"攻击时80%几率造成流血",
	"攻击时90%几率造成流血",
	"攻击时必造成流血，50%机率发动“天狼啸月”"
	}	
	--七宝指环
	WPTX[200] = {"逍遥派武学威力+100",
	"60%概率追加封穴5点",
	"70%概率追加封穴5点",
	"80%概率追加封穴5点",
	"90%概率追加封穴5点",
	"必封穴，50%机率发动“七宝琉璃”特效"
	}	
	--玄铁剑
	WPTX[36] = {"使用玄铁剑法时，增加50%暴击率",
	"使用玄铁剑法时，增加60%暴击率",
	"使用玄铁剑法时，增加70%暴击率",
	"使用玄铁剑法时，增加80%暴击率",
	"使用玄铁剑法时，增加90%暴击率",
	"使用玄铁剑法时，必定暴击，并可发动“破尽天下”"
	}
	--倚天剑
	WPTX[37] = {"攻击时70%几率造成流血效果",
	"攻击时80%几率造成流血效果",
	"攻击时90%几率造成流血效果",
	"攻击时必定造成流血效果",
	"攻击时必定造成流血效果",
	"使用剑法攻击时，有几率触发“谁于争锋”特效"
	}
	--流星剑
	WPTX[38] = {"连击率+10%",
	"连击率+11%",
	"连击率+12%",
	"连击率+13%",
	"连击率+14%",
	"连击率+15%"
	}
	--屠龙刀
	WPTX[43] = {"使用刀法攻击时，有几率触发两种特效",
	"使用刀法攻击时，有几率触发两种特效",
	"使用刀法攻击时，有几率触发两种特效",
	"使用刀法攻击时，有几率触发两种特效",
	"使用刀法攻击时，有几率触发两种特效",
	"使用刀法攻击时，有几率触发两种特效"
	}
	--血刀
	WPTX[44] = {"看起来不错，实际上没什么用",
	"看起来不错，实际上没什么用",
	"看起来不错，实际上没什么用",
	"看起来不错，实际上没什么用",
	"看起来不错，实际上没什么用",
	"看起来不错，实际上没什么用"
	}
	--软猬甲
	WPTX[58] = {"减伤20点，被拳指系武功攻击时，使攻击方流血10点",
	"减伤22点，被拳指系武功攻击时，使攻击方流血10点",
	"减伤24点，被拳指系武功攻击时，使攻击方流血10点",
	"减伤26点，被拳指系武功攻击时，使攻击方流血10点",
	"减伤28点，被拳指系武功攻击时，使攻击方流血10点",
	"减伤30点，被拳指系武功攻击时，使攻击方流血10点"
	}
	--乌蚕衣
	WPTX[59] = {"被攻击时，受到的内伤减少5点",
	"被攻击时，受到的内伤减少6点",
	"被攻击时，受到的内伤减少7点",
	"被攻击时，受到的内伤减少8点",
	"被攻击时，受到的内伤减少9点",
	"被攻击时，受到的内伤减少10点"
	}
	--金丝背心
	WPTX[60] = {"被攻击时，受到的封穴减少5点",
	"被攻击时，受到的封穴减少6点",
	"被攻击时，受到的封穴减少7点",
	"被攻击时，受到的封穴减少8点",
	"被攻击时，受到的封穴减少9点",
	"被攻击时，受到的封穴减少10点"
	}
	--鳄皮护甲
	WPTX[61] = {"每次行动结束后解毒25点",
	"每次行动结束后解毒35点",
	"每次行动结束后解毒45点",
	"每次行动结束后解毒55点",
	"每次行动结束后解毒65点",
	"每次行动结束后解毒75点"
	}
	--佛心甲
	WPTX[62] = {"被攻击时，受到的灼烧减少50%",
	"被攻击时，受到的灼烧减少60%",
	"被攻击时，受到的灼烧减少70%",
	"被攻击时，受到的灼烧减少80%",
	"被攻击时，受到的灼烧减少90%",
	"被攻击时，免疫灼烧状态"
	}
	--皮衣
	WPTX[63] = {"被攻击时，受到的冰封减少50%",
	"被攻击时，受到的冰封减少60%",
	"被攻击时，受到的冰封减少70%",
	"被攻击时，受到的冰封减少80%",
	"被攻击时，受到的冰封减少90%",
	"被攻击时，免疫冰封状态"
	}
	--白马
	WPTX[230] = {"集气速度增加2点",
	"集气速度增加2点",
	"集气速度增加3点",
	"集气速度增加3点",
	"集气速度增加4点",
	"集气速度增加4点"
	}	

	--真武剑
	WPTX[236] = {"使用太极剑法时，必定连击",
	"使用太极剑法时，必定连击",
	"使用太极剑法时，必定连击",
	"使用太极剑法时，必定连击",
	"使用太极剑法时，必定连击",
	"使用太极剑法时，必定连击"
	}
	--鸳鸯刀
	WPTX[217] = {"需男性，使用夫妻刀法时，必定连击",
	"使用夫妻刀法时，必定连击",
	"使用夫妻刀法时，必定连击",
	"使用夫妻刀法时，必定连击",
	"使用夫妻刀法时，必定连击，追加500气攻",
	"使用夫妻刀法时，必定连击，追加500气攻，伤害提高20%"
	}
	WPTX[218] = {"需女性，使用夫妻刀法时，必定连击",
	"使用夫妻刀法时，必定连击",
	"使用夫妻刀法时，必定连击",
	"使用夫妻刀法时，必定连击",
	"使用夫妻刀法时，必定连击，追加500气攻",
	"使用夫妻刀法时，必定连击，追加500气攻，伤害提高20%"
	}
	--毛驴
	WPTX[279] = {"集气速度增加10点",
	"集气速度增加10点",
	"集气速度增加10点",
	"集气速度增加10点",
	"集气速度增加10点",
	"集气速度增加10点"
	}
	--青驴
	WPTX[339] = {"集气速度增加5点，体力消耗减2点",
	"集气速度增加5点，体力消耗减2点",
	"集气速度增加5点，体力消耗减2点",
	"集气速度增加5点，体力消耗减2点",
	"集气速度增加5点，体力消耗减2点",
	"集气速度增加5点，体力消耗减2点"
	}
	--飞云骓
	WPTX[264] = {"集气速度增加12点",
	"集气速度增加12点",
	"集气速度增加12点",
	"集气速度增加12点",
	"集气速度增加12点",
	"集气速度增加12点"
	}	
	--汗血宝马
	WPTX[262] = {"集气速度增加8点，时序回复流血2点",
	"集气速度增加8点，时序回复流血2点",
	"集气速度增加8点，时序回复流血2点",
	"集气速度增加8点，时序回复流血2点",
	"集气速度增加8点，时序回复流血2点",
	"集气速度增加8点，时序回复流血2点"
	}		
	--西毒蛇杖
	WPTX[244] = {"攻击时无视敌方毒抗强制上毒10点",
	"攻击时无视敌方毒抗强制上毒15点",
	"攻击时无视敌方毒抗强制上毒20点",
	"攻击时无视敌方毒抗强制上毒25点",
	"攻击时无视敌方毒抗强制上毒30点",
	"攻击时无视敌方毒抗强制上毒35点"
	}
	--瘦黄马
	WPTX[284] = {nil,
	nil,
	nil,
	nil,
	nil,
	"血量越低，集气速度越快"
	}
	
	--金丝手套
	WPTX[239] = {"提高自身拳/指系数10点",
	"提高自身拳/指系数15点",
	"提高自身拳/指系数20点",
	"提高自身拳/指系数25点",
	"提高自身拳/指系数30点",
	"提高自身拳/指系数30点，免疫流血"
	}
	
	--音箱
	WPTX[300] = {"降龙三叠浪几率提高5%，暴怒时有几率触发四叠浪",
	"降龙三叠浪几率提高10%，暴怒时有几率触发四叠浪",
	"降龙三叠浪几率提高15%，暴怒时有几率触发四叠浪",
	"降龙三叠浪几率提高20%，暴怒时有几率触发四叠浪",
	"降龙三叠浪几率提高25%，暴怒时有几率触发四叠浪",
	"降龙三叠浪几率提高30%，暴怒时有几率触发四叠浪"
	}
	
	--麻痹戒指
	WPTX[301] = {"令击中的敌方进入麻痹状态，下回合移动能力-1",
	"令击中的敌方进入麻痹状态，下回合移动能力-1",
	"令击中的敌方进入麻痹状态，下回合移动能力-2",
	"令击中的敌方进入麻痹状态，下回合移动能力-2",
	"令击中的敌方进入麻痹状态，下回合移动能力-3",
	"令击中的敌方进入麻痹状态，下回合移动能力-3"
	}
	--护身戒指
	WPTX[302] = {"用内力抵消一半伤害，抵消比例为3内力=1伤害",
	"用内力抵消一半伤害，抵消比例为3内力=1伤害",
	"用内力抵消一半伤害，抵消比例为2内力=1伤害",
	"用内力抵消一半伤害，抵消比例为2内力=1伤害",
	"用内力抵消一半伤害，抵消比例为1内力=1伤害",
	"用内力抵消一半伤害，抵消比例为1内力=1伤害"
	}
	--复活戒指
	WPTX[303] = {"被击退时，满状态复活，复活6次之后物品损坏",
	"被击退时，满状态复活，复活6次之后物品损坏",
	"被击退时，满状态复活，复活6次之后物品损坏",
	"被击退时，满状态复活，复活6次之后物品损坏",
	"被击退时，满状态复活，复活6次之后物品损坏",
	"被击退时，满状态复活，复活6次之后物品损坏"
	}
	--隐身戒指
	WPTX[304] = {"敌方无法察觉你的存在，攻击后现形40时序",
	"敌方无法察觉你的存在，攻击后现形40时序",
	"敌方无法察觉你的存在，攻击后现形30时序",
	"敌方无法察觉你的存在，攻击后现形30时序",
	"敌方无法察觉你的存在，攻击后现形20时序",
	"敌方无法察觉你的存在，攻击后现形20时序"
	}
	--天书
	WPTX[312] = {"神秘强大的力量",
	"神秘强大的力量",
	"神秘强大的力量",
	"神秘强大的力量",
	"神秘强大的力量",
	"神秘强大的力量",
	}	
	--千年人参
	WPTX[14] = "可增加人物体质1点"	
	--独孤九剑
	WPTX[114] = "在一定机缘下可领悟九剑真传"
	--六脉神剑
	WPTX[113] = "连击时，伤害、气攻不会减少"
	--夫妻刀法
	WPTX[140] = "连击时，伤害、气攻不会减少"
	--北冥神功
	WPTX[64] = "主角修炼时，内力不会调和，主角修炼机率吸怒20点"
 	--小无相功
	WPTX[75] = "主角修炼不调和"	
 	--九阴功
	WPTX[83] = "主角修炼可习得飞絮劲机率+100真实伤害且无视闪避"
 	--九阳功
	WPTX[84] = "主角修炼可习得“抱元守一”，行动前清除所有异常状态"	
	--难度文字
	MODEXZ2 = {"简单", "普通", "困难","地狱"}
	--标主选天赋文字
	TFXZSAY1 = " 天下风云出我辈 * 一入江湖岁月催 * 皇图霸业谈笑中 * 不胜人生一场醉 "
	
	--特色指令
	GRTS = {}
	GRTSSAY = {}
	
	--段誉
	GRTS[53] = "凌波"
	GRTSSAY[53] = "效果：至该角色下次行动为止*      被攻击有50%几率闪避*消耗：体力10点"
	
	--虚竹
	GRTS[49] = "催符"
	GRTSSAY[49] = "效果：催动敌人身上的生死符*      使其封穴25时序*消耗：体力5点 内力500点"
	
	--人厨子
	GRTS[89] = "气补"
	GRTSSAY[89] = "效果：回复指定邻接队友体力50点**消耗：体力25点 内力300点"
	
	--张无忌
	GRTS[9] = "挪移"
	GRTSSAY[9] = "效果：将八格范围内的我方任一队友*      挪移到指定位置*消耗：体力10点 内力500点"
	
	--祖千秋
	GRTS[88] = "传功"
	GRTSSAY[88] = "效果：将五格范围内我方任一队友*      当前集气提升500点*消耗：体力10点 内力700点"
  
	--霍青桐
	GRTS[74] = "指挥"
	GRTSSAY[74] = "效果：我方获得号令三军50时序。*效果为我方存活人数*5%。*消耗：体力10点 内力150点"
	
	--王难姑
	GRTS[17] = "施毒"
	GRTSSAY[17] = "效果：周围五格范围内的敌人时序中毒*      持续50时序*消耗：体力15点 内力300点"
	
	--胡青牛
	GRTS[16] = "群疗"
	GRTSSAY[16] = "效果：周围五格范围内的队友时序回内伤*      并按比例回血，持续20时序*消耗：体力15点 内力300点"
	
	
	--慕容复
	GRTS[51] = "幻梦"
	GRTSSAY[51] = "效果：至该角色下次行动为止*      被攻击必定发动幻梦星辰反击*消耗：体力10点"
	
	--小昭
	GRTS[66] = "影步"
	GRTSSAY[66] = "效果：标记自身周围一点*      被攻击则移动至该处*消耗：体力20点 内力1000点"
	
	--钟灵
	GRTS[90] = "灵貂"
	GRTSSAY[90] = "效果：偷窃敌方携带的物品*      并对其强制上毒50点*消耗：体力5点"
	
	--郭襄
	GRTS[626] = "玲珑"
	GRTSSAY[626] = "效果：可自由切换第一格武功为*      弹指神通/玉萧剑法/落英神剑掌*      不消耗回合"
	--郭襄
	GRTS[574] = "云梦"
	GRTSSAY[574] = "效果：可自由切换第一格武功为*      寒袖拂穴/白虹掌力*      不消耗回合"	
	--胡斐
	GRTS[1] = "飞狐"
	GRTSSAY[1] = "效果：无视障碍物移动*      在战场上来去自如*消耗：体力10点"
	
	--鸠摩智
	GRTS[103] = "幻化"
	GRTSSAY[103] = "效果：使用小无相功模拟天下武学*      必须要拥有对应的秘籍*消耗：体力10点 内力500点"
	
	--达尔巴
	GRTS[160] = "死战"
	GRTSSAY[160] = "效果：锁定一名敌人，至其死亡之前，达尔巴*      对其的攻击效果提高50%，且必定命中*      在目标死亡之前无法更换目标*消耗：体力10点 内力500点"
	
	--金轮
	GRTS[62] = "龙象"
	GRTSSAY[62] = "效果：使用后自动执行蓄力*      并使下一次的攻击附加昏迷效果*      昏迷的敌人将丧失一次行动机会*消耗：体力10点 内力500点"
	
	--黄蓉
	GRTS[56] = "遁甲"
	GRTSSAY[56] = "效果：使用奇门遁甲*      重新布置战场地形效果*消耗：体力10点 内力500点"
	
	--阿紫
	GRTS[47] = "禁药"
	GRTSSAY[47] = "效果：使用禁药刺激神经*      自身每时序损失1%最大血量*      此状态下自身血量越低，伤害/集气越高*      不消耗回合"
	
	--韦小宝
	GRTS[601] = "口才"
	GRTSSAY[601] = "效果：使一名敌方进入沉睡状态*      此状态无法集气，不会自行解除*      受到攻击会醒来*消耗：体力15点"
	
	--苗人凤
	GRTS[3] = "破军"
	GRTSSAY[3] = "效果：攻击敌方*      并使其内功停运50时序*消耗：体力10点 内力300点"
	
	--灭绝
	GRTS[6] = "俱焚"
	GRTSSAY[6] = "效果：开启后100时序*      自身造成和受到的伤害皆提高50% *      不消耗回合"
	
	--谢逊
	GRTS[13] = "咆哮"
	GRTSSAY[13] = "效果：使全场敌人进入混乱状态20时序*      此状态下敌人行动时的敌我关系为随机*      不会全部随机到我方，以免出现直接获胜的情况*消耗：体力10点 2000内力"
	--丘处机
	GRTS[68] = "止杀"
	GRTSSAY[68] = "效果：自身十格范围内敌人不会攻击一回合    *     *消耗：体力15点 "	
	
	--何太冲
	GRTS[7] = "铁琴"
	GRTSSAY[7] = "效果：使全场敌人受到其身上琴音层数×50点伤害*      并清除其身上的琴音状态*消耗：体力10点 内力500点"
	
	--阎基
	GRTS[4] = "虚弱"
	GRTSSAY[4] = "效果：用毒药侵蚀一名敌人的神经*      使其在40时序内造成的伤害杀气减半*消耗：体力10点"
	
	--黛绮丝
	GRTS[15] = "倾国"
	GRTSSAY[15] = "效果：开启后，接下来受到的前6次攻击*      将折射给在场随机第三方人物*消耗：体力10点"
	
	--猫姐
	GRTS[92] = "换装"
	GRTSSAY[92] = "效果：使用后改变自身外形*      并将获得不同的内功*消耗：体力10点"
		
	GRTS[507] = "麒麟"
	GRTSSAY[507] = "效果1：使用后改变自身形象*效果2：每本天赋可复制敌方一个武功*消耗：体力10点"
		
	GRTS[508] = "麒麟"
	GRTSSAY[508] = "效果1：使用后改变自身形象*      无消耗消耗"
		
	--李寻欢
	GRTS[498] = "飞刀"
	GRTSSAY[498] = "效果：开启100时序后，自身伤害提升50%*    小李飞刀例无需发 攻击无视闪避必命中；*  暗器造成更高伤害，消耗：-10体，-500内"
	--萧秋水
	GRTS[652] = "天剑"
	GRTSSAY[652] = "效果：满怒后可使用，开启开50时序内*    任何剑系武功附加【惊天一剑】*  造成无视一切防御无视闪避的伤害*        消耗：-10体，-500内"	
	
	CC.Kungfunum = 12;	--人物武功数量
	
--队友攻击加成
CC.AddAtk = {
{10, 15, 50}, 		--金花给范遥加攻
{11, 15, 50}, 		--金花给杨逍加攻
{12, 15, 50}, 		--金花给殷天正加攻
{13, 15, 50}, 		--金花给谢逊加攻
{14, 15, 50}, 		--金花给韦一笑加攻
{48, 47, 100}, 		--阿紫给游坦之加攻
{47, 50, 100}, 		--乔峰给阿紫加攻
{53, 76, 100}, 		--王语嫣给段誉加攻
{79, 36, 60}, 		--林平之给岳灵珊加攻
{74, 75, 50}, 		--陈家洛给霍青桐加攻
{59, 58, 100}, 		--杨过给小龙女加攻
{54, 91, 100}, 		--温青青给袁承志加攻
{629, 54, 100}, 	--袁承志给阿九加攻
{99, 70, 100}, 		--玄慈给叶二娘加攻
{119, 65, 50}, 		--一灯给渔加攻
{120, 65, 50}, 		--一灯给樵加攻
{121, 65, 50}, 		--一灯给耕加攻
{122, 65, 50}, 		--一灯给读加攻
{68, 129, 50}, 		--王重阳给全真七子加攻
{123, 129, 50}, 
{124, 129, 50}, 
{125, 129, 50}, 
{126, 129, 50}, 
{127, 129, 50}, 
{128, 129, 50},
{37, 589, 50},		--狄云、水笙在场，攻各加50
{589, 37, 50},
{88, 89, 50},		--人厨子给祖千秋加攻
{311, 312, 100}, 		--天山
{604, 592, 100}, 	--独孤求败给阿青加攻
{566, 77, 100},
{614,615, 50},
{505,578, 100},    --大唐双龙
}

--队友防御加成
CC.AddDef = {	
{76, 51, 100}, 		--慕容复给王语嫣加防
{311, 312, 100}, 		--天山
{55, 56, 50}, 		--黄蓉给郭靖加防
{56, 55, 100}, 		--郭靖给黄蓉加防
{35, 73, 100}, 		--任盈盈给令狐冲加防
{79, 36, 60}, 		--岳灵珊给林平之加防
{73, 35, 50}, 		--令狐冲给任盈盈加防
{74, 75, 50}, 		--陈家洛给霍青桐加防
{58, 59, 50}, 		--小龙女给杨过加防
{59, 58, 50}, 		--杨过给小龙女加防	
{66, 9, 50}, 		--张无忌给小昭加防
{91, 54, 100}, 		--袁承志给温青青加防
{119, 65, 50}, 		--一灯给渔加防
{120, 65, 50}, 		--一灯给樵加防
{121, 65, 50}, 		--一灯给耕加防
{122, 65, 50}, 		--一灯给读加防
{68, 129, 50}, 		--王重阳给全真七子加防
{123, 129, 50}, 
{124, 129, 50}, 
{125, 129, 50}, 
{126, 129, 50}, 
{127, 129, 50}, 
{128, 129, 50},
{37, 589, 50},		--狄云、水笙在场，防各加50
{589, 37, 50},
{566, 77, 100},
{614,615, 50},
{578,505, 100},    --大唐双龙
}

--队友速度加成
CC.AddSpd = {
{25, 35, 50}, 		--令狐冲给蓝凤凰加轻
{90, 53, 50}, 		--段誉给钟灵加轻
{55, 56, 100}, 		--黄蓉给郭靖加轻
{56, 55, 50}, 		--郭靖给黄蓉加轻
{35, 79, 100}, 		--小师妹给令狐加轻
{73, 35, 50}, 		--令狐给盈盈加轻
{74, 75, 50}, 		--陈家洛给霍青桐加轻
{58, 59, 100}, 		--小龙女给杨过加轻
{63, 58, 60}, 		--杨过给程英加轻
{83, 54, 50},		--袁承志给何铁手加轻
{54, 629, 100}, 	--阿九给袁承志加轻
{37, 589, 50},		--狄云、水笙在场，轻各加50
{589, 37, 50},
{311, 312, 100}, 		--天山
{89, 88, 50},		--祖千秋给人厨子加轻
{592, 604, 100},	--阿青给独孤求败加轻
{614,615, 50},
{505,578, 50},    --大唐双龙
{578,505,50},    --大唐双龙
}

CC.AddDoc = {
{2, 1, 120}, 		--胡斐给程灵素加医疗
{16, 17, 50}}		--王难姑给胡青牛加医疗

CC.AddPoi = {
{17, 16, 50}}		--胡青牛给王难姑加用毒

--组合名称
CC.COMBO = {
	{1, 2, "海棠烛泪"},
	--{4, 72, "狼狈为奸"},
      {311, 312, "天山双鹰"}, 		--天山	
	--{37, 38, "赤诚仁心"},
	--{47, 48, "铁怪毒娇"},
	{51, 76, "姑苏表亲"},
	{53, 76, "仙洞眷侣"},
	--{90, 582, "灵婉双娇"},
	{55, 56, "铁血丹心"},
	--{87, 86, "鹿鼎双妹"},
	{35, 73, "剑胆琴心"},
	{36, 79, "苦命鸳鸯"},
	{75, 74, "巾帼红花"},
	{58, 59, "神雕侠侣"},
	{9, 66, "倚天奇情"},
	{16, 17, "蝶谷怪医"},
	{54, 91, "碧血情侠"},
	{54, 629, "情天长恨"},
	{88, 89, "酒食为天"},
	--{35, 58, "独孤传人"},
	--{83, 25, "五毒五仙"},
	--{35, 29, "酒肉冤家"},
	--{0, 92, "前尘如梦"},
	{37, 589, "雪山隐士"},
	--{38, 661, "金乌玉兔"},
	--{29, 591, "风流浪荡"},
	--{10, 11, "逍遥二仙"},
	--{162, 163, "不三不四"},
	--{60, 61, "雪山白驼"},
	--{620, 61, "雪山白驼"},
	--{51, 113, "燕国遗脉"},
	--{50, 112, "大辽战神"},
	--{3, 621, "刀剑双绝"},
	--{632, 633, "人淡如菊"},
	--{616, 635, "情义无解"},	
	--{77, 625, "女貌郎才"},		
	--{643, 644, "玄冥二老"},	
	--{663, 664, "义重情深"},	
	--{9, 638, "情深不寿"},
	--{9, 639, "张郎画眉"},
	{592, 604, "剑试天宵"},
	{566, 77, "珠联璧合"},
	{615, 614, "欢喜冤家"},	
	{505, 578, "大唐双龙"},	
}

	CC.CoupleDisplay = 0;
	
	--显示组合动画开关
	if CONFIG.CoupleDisplay == 1 then
		CC.CoupleDisplay = 1;
	end
	
	--无酒不欢：人物换装设定
	Avatar = {}
	
	--杨过
	Avatar[58] = {{},{}}
	Avatar[58][1].name = "神雕大侠"
	Avatar[58][1].num = 58
	Avatar[58][1].frameNum = {0,13,12,0,0}
	Avatar[58][1].frameDelay = {0,6,5,0,0}
	Avatar[58][1].soundDelay = {0,4,3,0,0}
	
	Avatar[58][2].name = "重剑无锋"
	Avatar[58][2].num = 376
	Avatar[58][2].frameNum = {0,13,12,0,0}
	Avatar[58][2].frameDelay = {0,11,11,0,0}
	Avatar[58][2].soundDelay = {0,11,11,0,0}
	
	--黛绮丝
	Avatar[15] = {{},{}}
	Avatar[15][1].name = "金花婆婆"
	Avatar[15][1].num = 15
	Avatar[15][1].frameNum = {0,0,0,0,14}
	Avatar[15][1].frameDelay = {0,0,0,0,12}
	Avatar[15][1].soundDelay = {0,0,0,0,10}
	
	Avatar[15][2].name = "紫衫龙王"
	Avatar[15][2].num = 377
	Avatar[15][2].frameNum = {0,0,0,0,12}
	Avatar[15][2].frameDelay = {0,0,0,0,10}
	Avatar[15][2].soundDelay = {0,0,0,0,10}

	--韦小宝
	Avatar[601] = {{},{}}
	Avatar[601][1].name = "游手好闲"
	Avatar[601][1].num = 225
	Avatar[601][1].frameNum = {0,8,0,7,0}
	Avatar[601][1].frameDelay = {0,6,0,5,0}
	Avatar[601][1].soundDelay = {0,6,0,5,0}
	
	Avatar[601][2].name = "一人之下"
	Avatar[601][2].num = 378
	Avatar[601][2].frameNum = {0,0,0,14,0}
	Avatar[601][2].frameDelay = {0,0,0,12,0}
	Avatar[601][2].soundDelay = {0,0,0,10,0}
	
	--乔峰
	Avatar[50] = {{},{}}
	Avatar[50][1].name = "奋英雄怒"
	Avatar[50][1].num = 50
	Avatar[50][1].frameNum = {0,14,0,0,0}
	Avatar[50][1].frameDelay = {0,8,0,0,0}
	Avatar[50][1].soundDelay = {0,5,0,0,0}
	
	Avatar[50][2].name = "狂龙天征"
	Avatar[50][2].num = 388
	Avatar[50][2].frameNum = {0,14,0,0,0}
	Avatar[50][2].frameDelay = {0,8,0,0,0}
	Avatar[50][2].soundDelay = {0,5,0,0,0}
	
	--文字颜色定义
	CC.Color = {["R"]=C_RED, ["G"]=M_Green, ["B"]=M_Blue}
  
	--是否显示滚动提醒，1打开，0关闭
	CC.OpenTimmerRemind = 0;
  
	--windows版本默认是打开
	if CONFIG.Operation == 0 then
		CC.OpenTimmerRemind = 1;
	end

	require("MyOEvent");
	
	CC.PTF = {}
CC.PTF[0] = {[0] = 1}
CC.PTF[1] = {[1] = 1}
CC.PTF[2] = {[2] = 1}
CC.PTF[3] = {[3] = 1}
CC.PTF[4] = {[4] = 1}
CC.PTF[5] = {[5] = 1}
CC.PTF[6] = {[6] = 1}
CC.PTF[7] = {[7] = 1}
CC.PTF[8] = {[8] = 1}
CC.PTF[9] = {[9] = 1}
CC.PTF[10] = {[10] = 1}
CC.PTF[11] = {[11] = 1}
CC.PTF[12] = {[12] = 1}
CC.PTF[13] = {[13] = 1}
CC.PTF[14] = {[14] = 1}
CC.PTF[15] = {[15] = 1}
CC.PTF[16] = {[16] = 1}
CC.PTF[17] = {[17] = 1}
CC.PTF[18] = {[18] = 1}
CC.PTF[19] = {[19] = 1}
CC.PTF[20] = {[20] = 1}
CC.PTF[21] = {[21] = 1}
CC.PTF[22] = {[22] = 1}
CC.PTF[23] = {[23] = 1}
CC.PTF[24] = {[24] = 1}
CC.PTF[25] = {[25] = 1}
CC.PTF[26] = {[26] = 1}
CC.PTF[27] = {[27] = 1,[9967] = 1}
CC.PTF[28] = {[28] = 1}
CC.PTF[29] = {[29] = 1}
CC.PTF[30] = {[30] = 1}
CC.PTF[31] = {[31] = 1}
CC.PTF[32] = {[32] = 1}
CC.PTF[33] = {[33] = 1}
CC.PTF[34] = {[34] = 1}
CC.PTF[35] = {[35] = 1}
CC.PTF[36] = {[36] = 1}
CC.PTF[37] = {[37] = 1}
CC.PTF[38] = {[38] = 1}
CC.PTF[39] = {[39] = 1}
CC.PTF[40] = {[40] = 1}
CC.PTF[41] = {[41] = 1}
CC.PTF[42] = {[42] = 1}
CC.PTF[43] = {[43] = 1}
CC.PTF[44] = {[44] = 1}
CC.PTF[45] = {[45] = 1}
CC.PTF[46] = {[46] = 1}
CC.PTF[47] = {[47] = 1}
CC.PTF[48] = {[48] = 1,[9985]=1}
CC.PTF[49] = {[49] = 1}
CC.PTF[50] = {[50] = 1}
CC.PTF[51] = {[51] = 1}
CC.PTF[52] = {[52] = 1}
CC.PTF[53] = {[53] = 1}
CC.PTF[54] = {[54] = 1}
CC.PTF[55] = {[55] = 1}
CC.PTF[56] = {[56] = 1}
CC.PTF[57] = {[57] = 1}
CC.PTF[58] = {[58] = 1,[9975]= 1}
CC.PTF[59] = {[59] = 1}
CC.PTF[60] = {[60] = 1}
CC.PTF[61] = {[61] = 1}
CC.PTF[62] = {[62] = 1}
CC.PTF[63] = {[63] = 1}
CC.PTF[64] = {[64] = 1}
CC.PTF[65] = {[65] = 1}
CC.PTF[66] = {[66] = 1}
CC.PTF[67] = {[67] = 1}
CC.PTF[68] = {[68] = 1}
CC.PTF[69] = {[69] = 1}
CC.PTF[70] = {[70] = 1}
CC.PTF[71] = {[71] = 1}
CC.PTF[72] = {[72] = 1}
CC.PTF[73] = {[73] = 1}
CC.PTF[74] = {[74] = 1}
CC.PTF[75] = {[75] = 1}
CC.PTF[76] = {[76] = 1}
CC.PTF[77] = {[77] = 1}
CC.PTF[78] = {[78] = 1}
CC.PTF[79] = {[79] = 1}
CC.PTF[80] = {[80] = 1}
CC.PTF[81] = {[81] = 1}
CC.PTF[82] = {[82] = 1}
CC.PTF[83] = {[83] = 1}
CC.PTF[84] = {[84] = 1,[9981] = 1}
CC.PTF[85] = {[85] = 1}
CC.PTF[86] = {[86] = 1}
CC.PTF[87] = {[87] = 1}
CC.PTF[88] = {[88] = 1}
CC.PTF[89] = {[89] = 1}
CC.PTF[90] = {[90] = 1}
CC.PTF[91] = {[91] = 1}
CC.PTF[92] = {[92] = 1}
CC.PTF[93] = {[93] = 1}
CC.PTF[94] = {[94] = 1}
CC.PTF[95] = {[95] = 1}
CC.PTF[96] = {[96] = 1}
CC.PTF[97] = {[97] = 1}
CC.PTF[98] = {[98] = 1}
CC.PTF[99] = {[99] = 1}
CC.PTF[100] = {[100] = 1}
CC.PTF[101] = {[101] = 1}
CC.PTF[102] = {[102] = 1}
CC.PTF[103] = {[103] = 1}
CC.PTF[104] = {[104] = 1}
CC.PTF[105] = {[105] = 1}
CC.PTF[106] = {[106] = 1}
CC.PTF[107] = {[107] = 1}
CC.PTF[108] = {[108] = 1}
CC.PTF[109] = {[109] = 1}
CC.PTF[110] = {[110] = 1}
CC.PTF[111] = {[111] = 1}
CC.PTF[112] = {[112] = 1}
CC.PTF[113] = {[113] = 1}
CC.PTF[114] = {[114] = 1,[9971] = 1}
CC.PTF[115] = {[115] = 1}
CC.PTF[116] = {[116] = 1}
CC.PTF[117] = {[117] = 1}
CC.PTF[118] = {[118] = 1}
CC.PTF[119] = {[119] = 1}
CC.PTF[120] = {[120] = 1}
CC.PTF[121] = {[121] = 1}
CC.PTF[122] = {[122] = 1}
CC.PTF[123] = {[123] = 1}
CC.PTF[124] = {[124] = 1}
CC.PTF[125] = {[125] = 1}
CC.PTF[126] = {[126] = 1}
CC.PTF[127] = {[127] = 1}
CC.PTF[128] = {[128] = 1}
CC.PTF[129] = {[129] = 1}
CC.PTF[130] = {[130] = 1}
CC.PTF[131] = {[131] = 1}
CC.PTF[132] = {[132] = 1}
CC.PTF[133] = {[133] = 1}
CC.PTF[134] = {[134] = 1}
CC.PTF[135] = {[135] = 1}
CC.PTF[136] = {[136] = 1}
CC.PTF[137] = {[137] = 1}
CC.PTF[138] = {[138] = 1}
CC.PTF[139] = {[139] = 1}
CC.PTF[140] = {[140] = 1,[9982] = 1,[9974]= 1}
CC.PTF[141] = {[141] = 1}
CC.PTF[142] = {[142] = 1}
CC.PTF[143] = {[143] = 1}
CC.PTF[144] = {[144] = 1}
CC.PTF[145] = {[145] = 1}
CC.PTF[146] = {[146] = 1}
CC.PTF[147] = {[147] = 1}
CC.PTF[148] = {[148] = 1}
CC.PTF[149] = {[149] = 1,[9995]= 1}
CC.PTF[150] = {[150] = 1}
CC.PTF[151] = {[151] = 1}
CC.PTF[152] = {[152] = 1}
CC.PTF[153] = {[153] = 1}
CC.PTF[154] = {[154] = 1}
CC.PTF[155] = {[155] = 1}
CC.PTF[156] = {[156] = 1}
CC.PTF[157] = {[157] = 1}
CC.PTF[158] = {[158] = 1}
CC.PTF[159] = {[159] = 1}
CC.PTF[160] = {[160] = 1}
CC.PTF[161] = {[161] = 1}
CC.PTF[162] = {[162] = 1}
CC.PTF[163] = {[163] = 1}
CC.PTF[164] = {[164] = 1}
CC.PTF[165] = {[165] = 1}
CC.PTF[166] = {[166] = 1}
CC.PTF[167] = {[167] = 1}
CC.PTF[168] = {[168] = 1}
CC.PTF[169] = {[169] = 1}
CC.PTF[170] = {[170] = 1}
CC.PTF[171] = {[171] = 1}
CC.PTF[172] = {[172] = 1}
CC.PTF[173] = {[173] = 1}
CC.PTF[174] = {[174] = 1}
CC.PTF[175] = {[175] = 1}
CC.PTF[176] = {[176] = 1}
CC.PTF[177] = {[177] = 1}
CC.PTF[178] = {[178] = 1}
CC.PTF[179] = {[179] = 1}
CC.PTF[180] = {[180] = 1}
CC.PTF[181] = {[181] = 1}
CC.PTF[182] = {[182] = 1}
CC.PTF[183] = {[183] = 1}
CC.PTF[184] = {[184] = 1}
CC.PTF[185] = {[185] = 1}
CC.PTF[186] = {[186] = 1}
CC.PTF[187] = {[187] = 1}
CC.PTF[188] = {[188] = 1}
CC.PTF[189] = {[189] = 1}
CC.PTF[190] = {[190] = 1}
CC.PTF[191] = {[191] = 1}
CC.PTF[192] = {[192] = 1}
CC.PTF[193] = {[193] = 1}
CC.PTF[194] = {[194] = 1}
CC.PTF[195] = {[195] = 1}
CC.PTF[196] = {[196] = 1}
CC.PTF[197] = {[197] = 1}
CC.PTF[198] = {[198] = 1}
CC.PTF[199] = {[199] = 1}
CC.PTF[200] = {[200] = 1}
CC.PTF[201] = {[201] = 1}
CC.PTF[202] = {[202] = 1}
CC.PTF[203] = {[203] = 1}
CC.PTF[204] = {[204] = 1}
CC.PTF[205] = {[205] = 1}
CC.PTF[206] = {[206] = 1}
CC.PTF[207] = {[207] = 1}
CC.PTF[208] = {[208] = 1}
CC.PTF[209] = {[209] = 1}
CC.PTF[210] = {[210] = 1}
CC.PTF[211] = {[211] = 1}
CC.PTF[212] = {[212] = 1}
CC.PTF[213] = {[213] = 1}
CC.PTF[214] = {[214] = 1}
CC.PTF[215] = {[215] = 1}
CC.PTF[216] = {[216] = 1}
CC.PTF[217] = {[217] = 1}
CC.PTF[218] = {[218] = 1}
CC.PTF[219] = {[219] = 1}
CC.PTF[220] = {[220] = 1}
CC.PTF[221] = {[221] = 1}
CC.PTF[222] = {[222] = 1}
CC.PTF[223] = {[223] = 1}
CC.PTF[224] = {[224] = 1}
CC.PTF[225] = {[225] = 1}
CC.PTF[226] = {[226] = 1}
CC.PTF[227] = {[227] = 1}
CC.PTF[228] = {[228] = 1}
CC.PTF[229] = {[229] = 1}
CC.PTF[230] = {[230] = 1}
CC.PTF[231] = {[231] = 1}
CC.PTF[232] = {[232] = 1}
CC.PTF[233] = {[233] = 1}
CC.PTF[234] = {[234] = 1}
CC.PTF[235] = {[235] = 1}
CC.PTF[236] = {[236] = 1}
CC.PTF[237] = {[237] = 1}
CC.PTF[238] = {[238] = 1}
CC.PTF[239] = {[239] = 1}
CC.PTF[240] = {[240] = 1}
CC.PTF[241] = {[241] = 1}
CC.PTF[242] = {[242] = 1}
CC.PTF[243] = {[243] = 1}
CC.PTF[244] = {[244] = 1}
CC.PTF[245] = {[245] = 1}
CC.PTF[246] = {[246] = 1}
CC.PTF[247] = {[247] = 1}
CC.PTF[248] = {[248] = 1}
CC.PTF[249] = {[249] = 1}
CC.PTF[250] = {[250] = 1}
CC.PTF[251] = {[251] = 1}
CC.PTF[252] = {[252] = 1}
CC.PTF[253] = {[253] = 1}
CC.PTF[254] = {[254] = 1}
CC.PTF[255] = {[255] = 1}
CC.PTF[256] = {[256] = 1}
CC.PTF[257] = {[257] = 1}
CC.PTF[258] = {[258] = 1}
CC.PTF[259] = {[259] = 1}
CC.PTF[260] = {[260] = 1}
CC.PTF[261] = {[261] = 1}
CC.PTF[262] = {[262] = 1}
CC.PTF[263] = {[263] = 1}
CC.PTF[264] = {[264] = 1}
CC.PTF[265] = {[265] = 1}
CC.PTF[266] = {[266] = 1}
CC.PTF[267] = {[267] = 1}
CC.PTF[268] = {[268] = 1}
CC.PTF[269] = {[269] = 1}
CC.PTF[270] = {[270] = 1}
CC.PTF[271] = {[271] = 1}
CC.PTF[272] = {[272] = 1}
CC.PTF[273] = {[273] = 1}
CC.PTF[274] = {[274] = 1}
CC.PTF[275] = {[275] = 1}
CC.PTF[276] = {[276] = 1}
CC.PTF[277] = {[277] = 1}
CC.PTF[278] = {[278] = 1}
CC.PTF[279] = {[279] = 1}
CC.PTF[280] = {[280] = 1}
CC.PTF[281] = {[281] = 1}
CC.PTF[282] = {[282] = 1}
CC.PTF[283] = {[283] = 1}
CC.PTF[284] = {[284] = 1}
CC.PTF[285] = {[285] = 1}
CC.PTF[286] = {[286] = 1}
CC.PTF[287] = {[287] = 1}
CC.PTF[288] = {[288] = 1}
CC.PTF[289] = {[289] = 1}
CC.PTF[290] = {[290] = 1}
CC.PTF[291] = {[291] = 1}
CC.PTF[292] = {[292] = 1}
CC.PTF[293] = {[293] = 1}
CC.PTF[294] = {[294] = 1}
CC.PTF[295] = {[295] = 1}
CC.PTF[296] = {[296] = 1}
CC.PTF[297] = {[297] = 1}
CC.PTF[298] = {[298] = 1}
CC.PTF[299] = {[299] = 1}
CC.PTF[300] = {[300] = 1}
CC.PTF[301] = {[301] = 1}
CC.PTF[302] = {[302] = 1}
CC.PTF[303] = {[303] = 1}
CC.PTF[304] = {[304] = 1}
CC.PTF[305] = {[305] = 1}
CC.PTF[306] = {[306] = 1}
CC.PTF[307] = {[307] = 1}
CC.PTF[308] = {[308] = 1}
CC.PTF[309] = {[309] = 1}
CC.PTF[310] = {[310] = 1}
CC.PTF[311] = {[311] = 1}
CC.PTF[312] = {[312] = 1}
CC.PTF[313] = {[9986] = 1,[9985] = 1}
CC.PTF[314] = {[314] = 1}
CC.PTF[315] = {[315] = 1}
CC.PTF[316] = {[316] = 1}
CC.PTF[317] = {[317] = 1}
CC.PTF[318] = {[318] = 1}
CC.PTF[319] = {[319] = 1}
CC.PTF[320] = {[320] = 1}
CC.PTF[321] = {[321] = 1}
CC.PTF[322] = {[322] = 1}
CC.PTF[323] = {[323] = 1}
CC.PTF[324] = {[324] = 1}
CC.PTF[325] = {[325] = 1}
CC.PTF[326] = {[326] = 1}
CC.PTF[327] = {[327] = 1}
CC.PTF[328] = {[328] = 1}
CC.PTF[329] = {[329] = 1}
CC.PTF[330] = {[330] = 1}
CC.PTF[331] = {[331] = 1}
CC.PTF[332] = {[332] = 1}
CC.PTF[333] = {[333] = 1}
CC.PTF[334] = {[334] = 1}
CC.PTF[335] = {[335] = 1}
CC.PTF[336] = {[336] = 1}
CC.PTF[337] = {[337] = 1}
CC.PTF[338] = {[338] = 1}
CC.PTF[339] = {[339] = 1}
CC.PTF[340] = {[340] = 1}
CC.PTF[341] = {[341] = 1}
CC.PTF[342] = {[342] = 1}
CC.PTF[343] = {[343] = 1}
CC.PTF[344] = {[344] = 1}
CC.PTF[345] = {[345] = 1}
CC.PTF[346] = {[346] = 1}
CC.PTF[347] = {[347] = 1}
CC.PTF[348] = {[348] = 1}
CC.PTF[349] = {[349] = 1}
CC.PTF[350] = {[350] = 1}
CC.PTF[351] = {[351] = 1}
CC.PTF[352] = {[352] = 1}
CC.PTF[353] = {[353] = 1}
CC.PTF[354] = {[354] = 1}
CC.PTF[355] = {[355] = 1}
CC.PTF[356] = {[356] = 1}
CC.PTF[357] = {[357] = 1}
CC.PTF[358] = {[358] = 1}
CC.PTF[359] = {[359] = 1}
CC.PTF[360] = {[360] = 1}
CC.PTF[361] = {[361] = 1}
CC.PTF[362] = {[362] = 1}
CC.PTF[363] = {[363] = 1}
CC.PTF[364] = {[364] = 1}
CC.PTF[365] = {[365] = 1}
CC.PTF[366] = {[366] = 1}
CC.PTF[367] = {[367] = 1}
CC.PTF[368] = {[368] = 1}
CC.PTF[369] = {[369] = 1}
CC.PTF[370] = {[370] = 1}
CC.PTF[371] = {[371] = 1}
CC.PTF[372] = {[372] = 1}
CC.PTF[373] = {[373] = 1}
CC.PTF[374] = {[374] = 1}
CC.PTF[375] = {[375] = 1}
CC.PTF[376] = {[376] = 1}
CC.PTF[377] = {[377] = 1}
CC.PTF[378] = {[378] = 1}
CC.PTF[379] = {[379] = 1}
CC.PTF[380] = {[380] = 1}
CC.PTF[381] = {[381] = 1}
CC.PTF[382] = {[382] = 1}
CC.PTF[383] = {[383] = 1}
CC.PTF[384] = {[384] = 1}
CC.PTF[385] = {[385] = 1}
CC.PTF[386] = {[386] = 1}
CC.PTF[387] = {[387] = 1}
CC.PTF[388] = {[388] = 1}
CC.PTF[389] = {[389] = 1}
CC.PTF[390] = {[390] = 1}
CC.PTF[391] = {[391] = 1}
CC.PTF[392] = {[392] = 1}
CC.PTF[393] = {[393] = 1}
CC.PTF[394] = {[394] = 1}
CC.PTF[395] = {[395] = 1}
CC.PTF[396] = {[396] = 1}
CC.PTF[397] = {[397] = 1}
CC.PTF[398] = {[398] = 1}
CC.PTF[399] = {[399] = 1}
CC.PTF[400] = {[400] = 1}
CC.PTF[401] = {[401] = 1}
CC.PTF[402] = {[402] = 1}
CC.PTF[403] = {[403] = 1}
CC.PTF[404] = {[404] = 1}
CC.PTF[405] = {[405] = 1}
CC.PTF[406] = {[406] = 1}
CC.PTF[407] = {[407] = 1}
CC.PTF[408] = {[408] = 1}
CC.PTF[409] = {[409] = 1}
CC.PTF[410] = {[410] = 1}
CC.PTF[411] = {[411] = 1}
CC.PTF[412] = {[412] = 1}
CC.PTF[413] = {[413] = 1}
CC.PTF[414] = {[414] = 1}
CC.PTF[415] = {[415] = 1}
CC.PTF[416] = {[416] = 1}
CC.PTF[417] = {[417] = 1}
CC.PTF[418] = {[418] = 1}
CC.PTF[419] = {[419] = 1}
CC.PTF[420] = {[420] = 1}
CC.PTF[421] = {[421] = 1}
CC.PTF[422] = {[422] = 1}
CC.PTF[423] = {[423] = 1}
CC.PTF[424] = {[424] = 1}
CC.PTF[425] = {[425] = 1}
CC.PTF[426] = {[426] = 1}
CC.PTF[427] = {[427] = 1}
CC.PTF[428] = {[428] = 1}
CC.PTF[429] = {[429] = 1}
CC.PTF[430] = {[430] = 1}
CC.PTF[431] = {[431] = 1}
CC.PTF[432] = {[432] = 1}
CC.PTF[433] = {[433] = 1}
CC.PTF[434] = {[434] = 1}
CC.PTF[435] = {[435] = 1}
CC.PTF[436] = {[436] = 1}
CC.PTF[437] = {[437] = 1}
CC.PTF[438] = {[438] = 1}
CC.PTF[439] = {[439] = 1}
CC.PTF[440] = {[440] = 1}
CC.PTF[441] = {[441] = 1}
CC.PTF[442] = {[442] = 1}
CC.PTF[443] = {[443] = 1}
CC.PTF[444] = {[444] = 1}
CC.PTF[445] = {[445] = 1}
CC.PTF[446] = {[446] = 1}
CC.PTF[447] = {[447] = 1}
CC.PTF[448] = {[448] = 1}
CC.PTF[449] = {[449] = 1}
CC.PTF[450] = {[450] = 1}
CC.PTF[451] = {[451] = 1}
CC.PTF[452] = {[452] = 1}
CC.PTF[453] = {[453] = 1}
CC.PTF[454] = {[454] = 1}
CC.PTF[455] = {[455] = 1}
CC.PTF[456] = {[456] = 1}
CC.PTF[457] = {[457] = 1}
CC.PTF[458] = {[458] = 1}
CC.PTF[459] = {[459] = 1}
CC.PTF[460] = {[460] = 1}
CC.PTF[461] = {[461] = 1}
CC.PTF[462] = {[462] = 1}
CC.PTF[463] = {[463] = 1}
CC.PTF[464] = {[464] = 1}
CC.PTF[465] = {[465] = 1}
CC.PTF[466] = {[466] = 1}
CC.PTF[467] = {[467] = 1}
CC.PTF[468] = {[468] = 1}
CC.PTF[469] = {[469] = 1}
CC.PTF[470] = {[470] = 1}
CC.PTF[471] = {[471] = 1}
CC.PTF[472] = {[472] = 1}
CC.PTF[473] = {[473] = 1}
CC.PTF[474] = {[474] = 1}
CC.PTF[475] = {[475] = 1}
CC.PTF[476] = {[476] = 1}
CC.PTF[477] = {[477] = 1}
CC.PTF[478] = {[478] = 1}
CC.PTF[479] = {[479] = 1}
CC.PTF[480] = {[480] = 1}
CC.PTF[481] = {[481] = 1}
CC.PTF[482] = {[482] = 1}
CC.PTF[483] = {[483] = 1}
CC.PTF[484] = {[484] = 1}
CC.PTF[485] = {[485] = 1}
CC.PTF[486] = {[486] = 1}
CC.PTF[487] = {[487] = 1}
CC.PTF[488] = {[488] = 1}
CC.PTF[489] = {[489] = 1}
CC.PTF[490] = {[490] = 1}
CC.PTF[491] = {[491] = 1}
CC.PTF[492] = {[492] = 1}
CC.PTF[493] = {[493] = 1}
CC.PTF[494] = {[494] = 1}
CC.PTF[495] = {[495] = 1}
CC.PTF[496] = {[496] = 1}
CC.PTF[497] = {[497] = 1}
CC.PTF[498] = {[498] = 1}
CC.PTF[499] = {[499] = 1}
CC.PTF[500] = {[500] = 1}
CC.PTF[501] = {[501] = 1}
CC.PTF[502] = {[502] = 1}
CC.PTF[503] = {[503] = 1}
CC.PTF[504] = {[9977] = 1,[9976] = 1,}
CC.PTF[505] = {[9979] = 1,[9978] = 1}
CC.PTF[506] = {[506] = 1}
CC.PTF[507] = {[507] = 1,[9969] = 1}
CC.PTF[508] = {[508] = 1,[9969] = 1}
CC.PTF[509] = {[509] = 1}
CC.PTF[510] = {[510] = 1}
CC.PTF[511] = {[511] = 1,[9967] = 1}
CC.PTF[512] = {[512] = 1}
CC.PTF[513] = {[513] = 1}
CC.PTF[514] = {[514] = 1}
CC.PTF[515] = {[515] = 1}
CC.PTF[516] = {[516] = 1}
CC.PTF[517] = {[517] = 1}
CC.PTF[518] = {[518] = 1}
CC.PTF[519] = {[519] = 1}
CC.PTF[520] = {[520] = 1}
CC.PTF[521] = {[521] = 1}
CC.PTF[522] = {[522] = 1}
CC.PTF[523] = {[523] = 1}
CC.PTF[524] = {[524] = 1}
CC.PTF[525] = {[525] = 1}
CC.PTF[526] = {[526] = 1}
CC.PTF[527] = {[527] = 1}
CC.PTF[528] = {[528] = 1}
CC.PTF[529] = {[529] = 1}
CC.PTF[530] = {[530] = 1}
CC.PTF[531] = {[531] = 1}
CC.PTF[532] = {[532] = 1}
CC.PTF[533] = {[533] = 1}
CC.PTF[534] = {[534] = 1}
CC.PTF[535] = {[535] = 1}
CC.PTF[536] = {[536] = 1}
CC.PTF[537] = {[537] = 1}
CC.PTF[538] = {[538] = 1}
CC.PTF[539] = {[539] = 1}
CC.PTF[540] = {[540] = 1}
CC.PTF[541] = {[541] = 1}
CC.PTF[542] = {[542] = 1}
CC.PTF[543] = {[543] = 1}
CC.PTF[544] = {[544] = 1}
CC.PTF[545] = {[545] = 1}
CC.PTF[546] = {[546] = 1}
CC.PTF[547] = {[547] = 1}
CC.PTF[548] = {[548] = 1}
CC.PTF[549] = {[549] = 1}
CC.PTF[550] = {[550] = 1}
CC.PTF[551] = {[551] = 1}
CC.PTF[552] = {[552] = 1}
CC.PTF[553] = {[553] = 1}
CC.PTF[554] = {[554] = 1}
CC.PTF[555] = {[555] = 1}
CC.PTF[556] = {[556] = 1}
CC.PTF[557] = {[557] = 1}
CC.PTF[558] = {[558] = 1}
CC.PTF[559] = {[559] = 1}
CC.PTF[560] = {[560] = 1}
CC.PTF[561] = {[561] = 1}
CC.PTF[562] = {[562] = 1}
CC.PTF[563] = {[563] = 1}
CC.PTF[564] = {[564] = 1}
CC.PTF[565] = {[565] = 1}
CC.PTF[566] = {[566] = 1}
CC.PTF[567] = {[9989] = 1,[567] = 1}
CC.PTF[568] = {[9968] = 1,[568]= 1}
CC.PTF[569] = {[569] = 1}
CC.PTF[570] = {[570] = 1}
CC.PTF[571] = {[571] = 1}
CC.PTF[572] = {[572] = 1}
CC.PTF[573] = {[9998] = 1,[9999] = 1}
CC.PTF[574] = {[574] = 1}
CC.PTF[575] = {[9997] = 1,[9996] = 1}
CC.PTF[576] = {[9995] = 1,[9994] = 1,[9993] = 1}
CC.PTF[577] = {[577] = 1,[9995]=1}
CC.PTF[578] = {[578] = 1}
CC.PTF[579] = {[579] = 1}
CC.PTF[580] = {[580] = 1}
CC.PTF[581] = {[581] = 1}
CC.PTF[582] = {[582] = 1}
CC.PTF[583] = {[583] = 1,[9998]=1}
CC.PTF[584] = {[584] = 1}
CC.PTF[585] = {[585] = 1}
CC.PTF[586] = {[586] = 1}
CC.PTF[587] = {[587] = 1}
CC.PTF[588] = {[588] = 1}
CC.PTF[589] = {[589] = 1}
CC.PTF[590] = {[590] = 1}
CC.PTF[591] = {[591] = 1}
CC.PTF[592] = {[592] = 1,[9982]= 1,[9975]= 1,[9974]= 1}
CC.PTF[593] = {[593] = 1}
CC.PTF[594] = {[594] = 1}
CC.PTF[595] = {[595] = 1}
CC.PTF[596] = {[596] = 1}
CC.PTF[597] = {[597] = 1}
CC.PTF[598] = {[598] = 1}
CC.PTF[599] = {[599] = 1}
CC.PTF[600] = {[600] = 1}
CC.PTF[601] = {[601] = 1}
CC.PTF[602] = {[602] = 1}
CC.PTF[603] = {[603] = 1}
CC.PTF[604] = {[604] = 1}
CC.PTF[605] = {[605] = 1}
CC.PTF[606] = {[606] = 1}
CC.PTF[607] = {[607] = 1}
CC.PTF[608] = {[608] = 1}
CC.PTF[609] = {[609] = 1}
CC.PTF[610] = {[610] = 1}
CC.PTF[611] = {[611] = 1}
CC.PTF[612] = {[612] = 1}
CC.PTF[613] = {[613] = 1}
CC.PTF[614] = {[614] = 1,[9984] = 1}
CC.PTF[615] = {[615] = 1}
CC.PTF[616] = {[616] = 1}
CC.PTF[617] = {[617] = 1}
CC.PTF[618] = {[618] = 1}
CC.PTF[619] = {[619] = 1}
CC.PTF[620] = {[620] = 1}
CC.PTF[621] = {[621] = 1}
CC.PTF[622] = {[622] = 1}
CC.PTF[623] = {[623] = 1}
CC.PTF[624] = {[624] = 1}
CC.PTF[625] = {[625] = 1}
CC.PTF[626] = {[626] = 1}
CC.PTF[627] = {[627] = 1}
CC.PTF[628] = {[628] = 1}
CC.PTF[629] = {[629] = 1}
CC.PTF[630] = {[630] = 1}
CC.PTF[631] = {[631] = 1}
CC.PTF[632] = {[632] = 1}
CC.PTF[633] = {[633] = 1}
CC.PTF[634] = {[634] = 1}
CC.PTF[635] = {[635] = 1}
CC.PTF[636] = {[636] = 1}
CC.PTF[637] = {[637] = 1}
CC.PTF[638] = {[638] = 1,[9966] = 1}
CC.PTF[639] = {[639] = 1}
CC.PTF[640] = {[640] = 1}
CC.PTF[641] = {[9992] = 1,[9991] = 1,[9990] = 1}
CC.PTF[642] = {[642] = 1}
CC.PTF[643] = {[643] = 1}
CC.PTF[644] = {[644] = 1}
CC.PTF[645] = {[645] = 1}
CC.PTF[646] = {[646] = 1}
CC.PTF[647] = {[647] = 1}
CC.PTF[648] = {[648] = 1}
CC.PTF[649] = {[649] = 1}
CC.PTF[650] = {[9981] = 1,[9980]= 1}
CC.PTF[651] = {[651] = 1}
CC.PTF[652] = {[652] = 1}
CC.PTF[653] = {[653] = 1}
CC.PTF[654] = {[654] = 1}
CC.PTF[655] = {[655] = 1}
CC.PTF[656] = {[656] = 1}
CC.PTF[657] = {[9984] = 1,[9983] = 1}
CC.PTF[658] = {[9987] = 1,[9988] = 1}
CC.PTF[659] = {[659] = 1}
CC.PTF[660] = {[660] = 1}
CC.PTF[661] = {[661] = 1}
CC.PTF[670] = {[670] = 1,[9974] = 1,[9982] = 1}
CC.PTF[721] = {[721] = 1}
CC.PTF[722] = {[722] = 1}
CC.PTF[723] = {[723] = 1}
CC.PTF[724] = {[724] = 1}
CC.PTF[725] = {[725] = 1}
CC.PTF[726] = {[726] = 1}

CC.PTFSM = {}
CC.PTFSM[9999] ={'仁阳佛光','内力上限9999，可使用九阳神功攻击'}
CC.PTFSM[9998] ={'天域幻音','行动结束时友方行动结束清除流血、中毒、冰封、灼烧、内伤并回复最多200点生命值'}
CC.PTFSM[9997] ={'仙剑神猿','使用剑系武功攻击时，敌方御剑系数减半，可装备白猿,猿公剑法威力+500。'}
CC.PTFSM[9996] ={'闪电惊虹','初始集气值1000，每次攻击后自身集气+200，连击率+50%，每学会一种剑法,伤害提升5%。'}
CC.PTFSM[9995] ={'菩提金身','受到的伤害降低30%'}
CC.PTFSM[9994] ={'无量禅震','使用伏魔杖法必定暴击，攻击如被闪避则追加一次攻击，伏魔伏法必暴击，追加内伤，并追加内伤值伤害。'}
CC.PTFSM[9993] ={'佛门无双','所有少林武功无条件学习'}
CC.PTFSM[9992] ={'圣火明尊','攻击必灼烧，灼烧大于25点必点燃。点燃后会造成小范围伤害'}
CC.PTFSM[9991] ={'魔道天行','我方全体攻击伤害×120％，敌方全体攻击伤害×90％。'}
CC.PTFSM[9990] ={'逆转乾坤','乾坤大挪移可同时反弹给两个人（学会乾坤大挪移后）反弹伤害50%。免疫暗器'}
CC.PTFSM[9989] ={'傲世神罡','攻击必暴击，拳掌武功必破防30%。'}
CC.PTFSM[9988] ={'天池怪侠','被攻击时概率转移杀气值给攻击者，攻击系数只算拳法，百花错拳威力+600。'}
CC.PTFSM[9987] ={'博通百家','修炼所有武功需求-20，修炼武功无视内力阴阳属性'}
CC.PTFSM[9986] ={'天佛降世','学会金刚不坏神功必定触发“金刚不坏”特效，战斗中可以复活一次，复活后免疫内伤，免疫暴击伤害。，'}
CC.PTFSM[9985] ={'诸行无常','可使用内功攻击，武功范围+1。'}
CC.PTFSM[9984] ={'诸法无我','每行动一次，自身伤害+5%,受到的伤害-5%。(上限30%)'}
CC.PTFSM[9983] ={'悲天佛怜','生命值低于50%，免疫杀气，般若掌攻击范围变为点，威力翻倍'}
CC.PTFSM[9982] ={'无我无剑','被攻击前先手反击'}
CC.PTFSM[9981] ={'小王爷','武功练到极，减少受到的5%伤害与杀气'}
CC.PTFSM[9980] ={'无妄无我','受到伤害为75%~125%。攻击伤害为75%~125%。'}
CC.PTFSM[9979] ={'九字真言','行动前概率触发九字真言其中的一种或多种，随天书跟实战的增加而增加触发最大数量，临-「不动根本印」：减伤50点。兵-「大金刚轮印」：破防40%。斗-「外狮子印」：气攻提升800。者-「内狮子印」：气防提升800。列-「外缚印」：击中移动减3。阵-「内缚印」：击中目标内力-200。在-「日轮印」：攻击必灼烧。前-「宝瓶印」：攻击范围扩大。皆-「智拳印」：必击中破绽。'}
CC.PTFSM[9978] ={'大唐双龙.冰','免疫冰封，攻击必冰封'}
CC.PTFSM[9977] ={'剑法无极','剑法攻击时无视目标１０％防御，每学会一门剑法至极，剑法破防效果增加2％'}
CC.PTFSM[9976] ={'神游太虚','免疫正面90°角攻击，正面两侧30%概率免疫，暴怒时必定免疫；移动时有独立动画'}
CC.PTFSM[9975] ={'剑魔再临','攻击时70%概率发动两种特效之一：天极剑渊：破防40%，破尽天下：无视气防，气攻增加2000'}
CC.PTFSM[9974] ={'九剑真传','使用剑法攻击时发动四种特效，荡剑式：集气+200，撩剑式：伤害+30%，倒剑式：强制杀气150，离剑式：伤害不随距离递减;被攻击时发动破X式，减少受到的伤害20%，攻击方下回合集气位置-200'}
CC.PTFSM[9973] ={'其疾如风','概率发动，攻击时发动后已方集气位置+100，自身集气位置+300'}
CC.PTFSM[9972] ={'侵略如火','概率发动，攻击气攻增加1000，必破气防。'}
CC.PTFSM[9971] ={'不动如山','概率发动，被攻击只受到伤害30点'}
CC.PTFSM[9970] ={'其徐如林','概率发动，被攻击增加自身集气，最多增加20点'}
CC.PTFSM[9969] ={'琅琊公子','战斗中系数必然不低于对方,可以自由切换林殊/梅长苏两个身份'}
CC.PTFSM[9968] ={'决胜千里','每回合50％几率触发，敌方集气-150，本方集气+150。'}
CC.PTFSM[9967] ={'葵花挪移','主运葵花神功时被攻击25%概率挪开位置。'}
CC.PTFSM[9966] ={'氤氲紫气','受到的气攻与伤害减少30%，免疫连击'}
CC.PTFSM[9965] ={'酒神八杯','羊脂白玉杯：此杯极为珍贵，可卖出2万两*犀角杯：战场中每次喝酒集气增加4点，下回合集气位置提升*古藤杯：战斗结束随机获得一颗（灵芝、地灵外）的药*青铜爵：战斗结束随机获得一坛酒*夜光杯：连击率大幅度降低，暴怒必定连击*琉璃杯：5%概率触发“酒神迷踪步”闪避，喝酒后概率增加30%*古瓷杯：被攻击时免疫破绽，暴怒必中破绽；攻击时无法出破绽，暴怒必中破绽*翡翠杯：免疫冰封灼烧'
}

CC.PTFSM[568] = {'精忠报国','武穆遗书带1000点气防。增加100点武常，生命低于50%减伤50%，生命低于25%减伤75%，岳家枪法攻击必命中，必连击。岳王散手攻击必暴击，必封穴。'}
CC.PTFSM[567] = {'千秋侠烈','生命值低于50%，伤害增加25%，低于25%伤害增加50%，武穆遗书自带2000点气防，被攻击伤害90%。'}

--护盾
CC.HD = {}
CC.HD[1] = {name = '坐忘无我',tt = 2032,tt1 = 2042,sm = '周身释放一个吸收（武功等级+基础内功）*0.8点伤害的真气防护罩，防护罩消失前，所受初始伤害降低伤害３０％'}
CC.HD[2] = {name = '菩提金身',tt = 2411,tt1 = 2422,sm = '受到的连击暴击伤害减少70%'}
CC.HD[3] =  {name = '先罡气',tt = 1305,tt1 = 1324,sm = '以护盾抵消伤害'}

--半身像手动偏移
CC.Png = {}

--复制队友
CC.Copy = {}
CC.Copy[662]=1
CC.Copy[663]=2
CC.Copy[664]=9
CC.Copy[665]=16
CC.Copy[666]=17
CC.Copy[667]=25
CC.Copy[668]=28
CC.Copy[669]=29
CC.Copy[670]=35
CC.Copy[670]=610
CC.Copy[671]=36
CC.Copy[672]=37
CC.Copy[673]=38
CC.Copy[674]=44
CC.Copy[675]=45
CC.Copy[676]=47
CC.Copy[677]=48
CC.Copy[678]=49
CC.Copy[679]=51
CC.Copy[680]=52
CC.Copy[681]=53
CC.Copy[682]=54
CC.Copy[683]=30
CC.Copy[683]=55
CC.Copy[684]=56
CC.Copy[685]=58
CC.Copy[686]=59
CC.Copy[687]=63
CC.Copy[688]=66
CC.Copy[689]=72
CC.Copy[690]=73
CC.Copy[690]=611
CC.Copy[691]=74
CC.Copy[692]=75
CC.Copy[693]=76
CC.Copy[694]=77
CC.Copy[695]=78
CC.Copy[696]=79
CC.Copy[697]=80
CC.Copy[698]=81
CC.Copy[699]=82
CC.Copy[700]=83
CC.Copy[701]=84
CC.Copy[702]=85
CC.Copy[703]=86
CC.Copy[704]=87
CC.Copy[705]=88
CC.Copy[706]=89
CC.Copy[707]=90
CC.Copy[708]=91
CC.Copy[709]=92
CC.Copy[710]=151
CC.Copy[711]=154
CC.Copy[712]=502
CC.Copy[712]=566
CC.Copy[713]=569
CC.Copy[714]=574
CC.Copy[715]=589
CC.Copy[716]=590
CC.Copy[717]=601
CC.Copy[718]=604
CC.Copy[719]=4
CC.Copy[720]=161
end

function rest()
	--银两
	CC.Gold = 0
	--天关残章奖励
	CC.Sp = 0
	--天关残章奖励判定是否触发，防止重复刷
	CC.Jl = 0
	--特效开启判定
	CC.TXM = {	'逆转乾坤',
				'迷踪步',
				'四神阵',
				'诛仙剑阵',
				'天关',	
				'杨过剑魔',
				'笑傲邪线',

} 

	--特效开启判定
	CC.TX = {   ['逆转乾坤'] = 0,
				['迷踪步'] = 0,
				['四神阵'] = 0,
				['诛仙剑阵'] = 0,
				['天关'] = 0,
				['杨过剑魔'] = 0,
				['笑傲邪线'] = 0,

} 

	--天关
	CC.TG = {}
	
	--天关奖励
	CC.TGJL = {}
	
end