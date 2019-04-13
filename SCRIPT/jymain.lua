function IncludeFile()
	package.path=CONFIG.ScriptLuaPath;  --设置加载路径
	require("jyconst")					--加载其他文件，使用require避免重复加载
	require("jywar")
	require("jyacvmts")
	require("kdef")
	require("ItemInfo")
end

function SetGlobal()  	 --设置游戏内部使用的全程变量
	JY={};

	JY.Status=GAME_INIT; --游戏当前状态
	--保存R×数据
	JY.Base={};          --基本数据
	JY.PersonNum=0;      --人物个数
	JY.Person={};        --人物数据
	JY.ThingNum=0        --物品数量
	JY.Thing={};         --物品数据
	JY.SceneNum=0        --场景数量
	JY.Scene={};         --场景数据
	JY.WugongNum=0       --物品数量
	JY.Wugong={};        --物品数据
	JY.ShopNum=0 		 --商店数量
	JY.Shop={};    		 --商店数据
   
	JY.MyCurrentPic = 0		--主角当前走路贴图在贴图文件中偏移
	JY.MyPic = 0     		--主角当前贴图
	JY.Mytick = 0			--主角没有走路的持续帧数
	JY.MyTick2 = 0			--显示事件动画的节拍
	JY.LOADTIME = 0
	JY.SAVETIME = 0
	JY.GTIME = 0			--游戏时间
	JY.GOLD = 0				--游戏银两

	JY.SubScene=-1;         --当前子场景编号
	JY.SubSceneX=0;         --子场景显示位置偏移，场景移动指令使用
	JY.SubSceneY=0;
	JY.ThingUse = -1;
	JY.Darkness=0;          --=0 屏幕正常显示，=1 不显示，屏幕全黑

	JY.CurrentD=-1;         --当前调用D*的编号
	JY.OldDPass=-1;         --上次触发路过事件的D*编号, 避免多次触发
	JY.CurrentEventType=-1  --当前触发事件的方式 1 空格 2 物品 3 路过

	JY.CurrentThing=-1;     --当前选择物品，触发事件使用

	JY.MmapMusic=-1;        --切换大地图音乐，返回主地图时，如果设置，则播放此音乐

	JY.CurrentMIDI=-1;      --当前播放的音乐id，用来在关闭音乐时保存音乐id。
	JY.EnableMusic=1;       --是否播放音乐 1 播放，0 不播放
	JY.EnableSound=1;       --是否播放音效 1 播放，0 不播放

	WAR={};					--战斗使用的全程变量 这里占个位置，因为程序后面不允许定义全局变量了。具体内容在WarSetGlobal函数中

	AutoMoveTab = {[0] = 0}
	
	JY.Restart = 0			--返回游戏初始界面
	JY.WalkCount = 0		--走路计步
	
	IsViewingKungfuScrolls = 0
	
	Achievements = {}
	Achievements.pChar = {}
	
	YC={}
	YC.ZJH = 0				--隐藏主角张家辉
end

function JY_Main()        --主程序入口
	os.remove("debug.txt");      	  --清除以前的debug输出
    xpcall(JY_Main_sub,myErrFun);     --捕获调用错误
end

function myErrFun(err)      --错误处理，打印错误信息
    lib.Debug(err);                 --输出错误信息
    lib.Debug(debug.traceback());   --输出调用堆栈信息
end

function JY_Main_sub()		--真正的游戏主程序入口
	Ct = {};
    IncludeFile();			--导入其他模块
    SetGlobalConst();		--设置全程变量CC, 程序使用的常量
    SetGlobal();			--设置全程变量JY

    --禁止访问全程变量
    setmetatable(_G,{ __newindex =function (_,n)
                       error("attempt read write to undeclared variable " .. n,2);
                       end,
                       __index =function (_,n)
                       error("attempt read read to undeclared variable " .. n,2);
                       end,
                     }  );
					
	
    lib.Debug("JY_Main start.");

	math.randomseed(os.time());			--初始化随机数发生器

    JY.Status=GAME_START;				--改变游戏状态

    lib.PicInit(CC.PaletteFile);		--加载原来的256色调色板
	
	lib.FillColor(0,0,0,0,0);

	--lib.PicLoadFile(CC.WMAPPicFile[1], CC.WMAPPicFile[2], 0)
	--lib.LoadPNGPath(CC.HeadPath, 1, CC.HeadNum, limitX(CC.ScreenW/936*100,0,100))	--设置读取PNG图片的路径
	--lib.PicLoadFile(CC.ThingPicFile[1], CC.ThingPicFile[2], 2, 100, 100)			--物品贴图，内存区域2
	--lib.PicLoadFile(CC.EFTFile[1], CC.EFTFile[2], 3)								--特效贴图，内存区域3
	--lib.LoadPNGPath(CC.BodyPath, 90, CC.BodyNum, limitX(CC.ScreenW/936*100,0,100))	--半身象
	--lib.LoadPNGPath(CC.XTPath, 91, CC.XTNum, limitX(CC.ScreenW/936*100,0,100))	--UI	
	--lib.PicLoadFile(CC.BJ[1], CC.BJ[2], 92) 
	--lib.LoadPNGPath('./data/mmap',93,-1,100)
	--lib.LoadPNGPath('./data/smap',94,-1,100)
	--lib.LoadPNGPath(CC.PTPath, 95, CC.PTNum, limitX(CC.ScreenW/936*100,0,100))
	--lib.LoadPNGPath(CC.UIPath, 96, CC.UINum, limitX(CC.ScreenW/936*100,0,100))	

	--97是云朵，切勿使用
	--lib.LoadPNGPath(CC.IconPath, 98, CC.IconNum, limitX(CC.ScreenW/936*100,0,100))	--状态图标，内存区域98
	--lib.LoadPNGPath(CC.HeadPath, 99, CC.HeadNum, 26.923076923)						--人物小头像，用于集气条，内存区域99
	
	while true do
		if JY.Restart == 1 then
			JY.Restart = 0
			JY.Status=GAME_START;
		end
		if JY.Status == GAME_END then
			break;
		end
		
		PlayMIDI(75);
		Cls();
		lib.ShowSlow(20,0);
		
		local r = StartMenu();
		if r ~= nil then
			return;
		end

		lib.LoadPicture("",0,0);
		lib.GetKey();
		
		Game_Cycle();
		
	end
end

function TitleSelection()
	local choice = 1
	local buttons ={
	{3,6,151,460,613,507},
	{4,7,351,460,613,507},
	{5,8,551,460,613,507}
	}
	local buttons2 ={
	{3,6,226,466,345,500},
	{4,7,425,466,550,500},
	{5,8,625,466,747,500}
	}
	--[[
	local choice = 1  选择1
	local buttons ={
	{961,964,351,340,613,387}, --{图1编号，图1底层编号,X轴，图1Y轴，？，？）
	{962,965,351,400,613,447},
	{963,966,351,460,613,507}
	}
	]]
	local function on_button(mx, my)
		local r = 0
			for i = 1, #buttons2 do
				if mx >= buttons2[i][3] and mx <= buttons2[i][5] and my >= buttons2[i][4] and my <= buttons2[i][6] then
					r = i
					break
				end
			end
		return r
	end
	while true do
		if JY.Restart == 1 then
			return
		end
		local keypress, ktype, mx, my = lib.GetKey()
		if keypress == VK_DOWN or keypress == VK_RIGHT then
			choice = choice + 1
			if choice > #buttons then
				choice = 1
			end
		elseif keypress == VK_UP or keypress == VK_LEFT then
			choice = choice - 1
			if choice < 1 then
				choice = #buttons
			end
		else
			if (ktype == 2 or ktype == 3) then
				local r = on_button(mx, my)
				if r > 0 then
					choice = r
				end
			end
			if keypress == VK_RETURN or (ktype == 3 and on_button(mx, my)>0) then
				break
			end
		end
		Cls()
		for i = 1, #buttons do
			local picid = buttons[i][1]
			if i == choice then
				picid = buttons[i][2]
			end
			lib.LoadPNG(91, picid * 2 , buttons[i][3], buttons[i][4], 1)
		end
		--版本号
		DrawString(CC.ScreenW-115-810,CC.ScreenH-30-670,CC.Version,C_WHITE,CC.Fontsmall)
		ShowScreen()
		lib.Delay(CC.Frame)

	end
	return choice
end

function StartMenu()
	Cls()
	local menuReturn = TitleSelection()
    if menuReturn == 1 then        --重新开始游戏
    Cls()

		NewGame();   		       --设置新游戏数据
		
		if JY.Restart == 1 then
			do return end
		end
		
		--畅想杨过初始场景
		if JY.Base["畅想"] == 58 then
			JY.SubScene = 18
			JY.Base["人X"] = 144
			JY.Base["人Y"] = 218
			JY.Base["人X1"] = 30
			JY.Base["人Y1"] = 32
		else
			JY.SubScene = CC.NewGameSceneID
			JY.Base["人X1"] = CC.NewGameSceneX
			JY.Base["人Y1"] = CC.NewGameSceneY
		end
		--无酒不欢：男女主角判定
		if JY.Person[0]["性别"] == 0 then
			JY.MyPic = CC.NewPersonPicM
		else
			JY.MyPic = CC.NewPersonPicF
		end
		JY.Status = GAME_SMAP
		JY.MmapMusic = -1
		CleanMemory()
		Init_SMap(0)
        lib.ShowSlow(20,0)
        
		--if DrawStrBoxYesNo(-1, -1, "是否观看序章剧情？", C_GOLD, CC.DefaultFont, LimeGreen) == true then 
			--oldCallEvent(CC.NewGameEvent)
		--end
		
		--开局事件
		if JY.Base["畅想"] == 58 then		--畅想杨过
			CallCEvent(4187)
		else								--其他人
			CallCEvent(691)
		end
		
		--畅想开局获得自身的装备
		if JY.Base["畅想"] > 0 then
			if JY.Person[0]["武器"] ~= - 1 and JY.Base["畅想"]~= 27 then
				instruct_2(JY.Person[0]["武器"], 1)
				JY.Person[0]["武器"] = - 1
			end
			if JY.Person[0]["防具"] ~= - 1 then
				instruct_2(JY.Person[0]["防具"], 1)
				JY.Person[0]["防具"] = - 1
			end
			if JY.Person[0]["坐骑"] ~= - 1 then
				instruct_2(JY.Person[0]["坐骑"], 1)
				JY.Person[0]["坐骑"] = - 1
			end			
		end
		--畅想尹克西获得一万两
		if JY.Base["畅想"] == 158 then
			instruct_2(174, 10000)
		end
		--标准获得1万两
		if JY.Base["标准"] > 0 then
			instruct_2(174, 10000)
		end			
		--畅想获得1万两
		if JY.Base["畅想"] > 0 then
			instruct_2(174, 10000)
		end	
        if JY.Base["畅想"] == 721 then
            instruct_2(174, 20000)
        end
		--畅想李寻欢获得小李飞刀
		if JY.Base["畅想"] == 498 then
			instruct_2(309, 1)
		end
		--畅想李寻欢获得小李飞刀
		if JY.Base["畅想"] == 498 then
			instruct_2(29, 99)
		end			
         --标主可以在云岭洞花钱学习迷踪步
		if JY.Base["标准"] > 0 then
			addevent(41, 0, 1, 4144, 1, 8694)
		end

		--张家辉的专属装备
		if JY.Base["畅想"] == 651 then
			for i = 301, 304 do
				instruct_2(i, 1)
			end
		end
		--周目奖励

        os.remove(CONFIG.DataPath..'TgJl')
        for i = 1, #CC.commodity do
            if CC.commodity[i][5] > 0 then 
                instruct_2(CC.commodity[i][1],CC.commodity[i][5])
                CC.commodity[i][5] = 0
            end
        end
        tgsave(1)
        
        CC.TGJL = {}
	elseif menuReturn == 2 then         --载入旧的进度

    	DrawStrBox(-1,CC.ScreenH*1/6-20,"读取进度",LimeGreen,CC.Fontbig,C_GOLD);
		DrawStrBox(104,CC.ScreenH*1/6+26,string.format("%-6s %-4s %-10s %-4s %-4s %-4s %-10s","存档名", "主角", "姓名", "难度", "资质", "天书", "位置"),C_ORANGE,CC.DefaultFont,C_GOLD);
	
    	local r = SaveList();
    	--ESC 重新返回选项
    	if r < 1 then
    		local s = StartMenu();
    		return s;
    	end
    	
    	Cls();
		DrawStrBox(-1,CC.StartMenuY,"请稍候...",C_GOLD,CC.DefaultFont);
		ShowScreen();
    	local result = LoadRecord(r);
    	if result ~= nil then
    		return StartMenu();
    	end

		if JY.Base["无用"] ~= -1 then
			if JY.SubScene < 0 then
				CleanMemory()
				--lib.UnloadMMap()
			end
			--lib.PicInit()
			lib.ShowSlow(20, 1)
			JY.Status = GAME_SMAP
			JY.SubScene = JY.Base["无用"]
			JY.MmapMusic = -1
			JY.MyPic = GetMyPic()
			Init_SMap(1)
		else
			JY.SubScene = -1
			JY.Status = GAME_FIRSTMMAP
		end
	elseif menuReturn == 3 then
        return -1;
	end
end

function CleanMemory()            --清理lua内存
    if CONFIG.CleanMemory==1 then
		collectgarbage("collect");
    end
end
function NewGame()     --选择新游戏，设置主角初始属性
	Cls();
	ShowScreen();
	LoadRecord(0); --  载入新游戏数据
	rest()
	--PlayMIDI(77);
	CC.Week = 1
	CC.Gold = 0
	CC.Sp = 0
	if existFile(CONFIG.DataPath..'TgJl') then
		tgload()
	end
    
	--执行成就文件
	if existFile(CC.Acvmts) then
		dofile(CC.Acvmts)
	--一周目
	else
		Achievements.Round = 1
		Achievements.pChar = {}
		Achievements.rdsCpltd = {}
		for i = 1, JY.PersonNum do
			Achievements.rdsCpltd[i] = {}
			Achievements.rdsCpltd[i].n = 0
			Achievements.rdsCpltd[i].lvlReached1 = 0
			Achievements.rdsCpltd[i].lvlReached2 = 0
		end
		Achievements.sp = 0
		Achievements.bonus = {}
		for i = 1, 7 do
			Achievements.bonus[i] = 0
		end
		--以表格形式保存新文件
		SaveTable(Achievements)
	end
    if CC.Week > 100 then 
        CC.Week = 100
    end
	JY.Base["周目"] = CC.Week--Achievements.Round
	--if Achievements.Round > 30 then
	--   Achievements.Round = 30
	--end
	--if JY.Base["周目"] > 30 then
		--JY.Base["周目"] = 30
	--end
	JY.Status = GAME_NEWNAME
	lib.PlayMPEG(CONFIG.DataPath .. "/avi/1.mp4",VK_ESCAPE) --视频文件
    Cls()
	
	--选择标主还是畅想
	lib.LoadPicture(CC.BG01File,-1,-1)	
	--local player_type = JYMsgBox("主角选择", "选择你想要的主角模式*", {"标准主角","畅想主角"}, 2, 903)
	GAME_START1()
	
	local player_type = 0
	
	local cx,zj,ts,xb = firstmenu()
	
	if ts > 0 then 
		player_type = 3
	elseif cx > 0 then
		player_type = 2
	else 
		player_type = 1
	end


    Cls()
	JY.Person[0]["姓名"]=CC.NewPersonName;
		  
	JY.Person[0]["生命最大值"] = 50
	JY.Person[0]["内力最大值"] = 500
	JY.Person[0]["生命"] = JY.Person[0]["生命最大值"]
	JY.Person[0]["内力"] = JY.Person[0]["内力最大值"]
	JY.Person[0]["攻击力"] = 80
	JY.Person[0]["防御力"] = 80
	JY.Person[0]["轻功"] = 80
	JY.Person[0]["医疗能力"] = 30
	JY.Person[0]["用毒能力"] = 30
	JY.Person[0]["解毒能力"] = 30
	JY.Person[0]["抗毒能力"] = 0
	JY.Person[0]["拳掌功夫"] = 40
	JY.Person[0]["指法技巧"] = 40
	JY.Person[0]["御剑能力"] = 40
	JY.Person[0]["耍刀技巧"] = 40
	JY.Person[0]["特殊兵器"] = 40
	JY.Person[0]["暗器技巧"] = 40

	local zm = JY.Base["周目"]
	local nd = JY.Base["难度"] 
	local addkfnum  
	if nd < 4 then 
		addkfnum = 12+math.modf(zm/2)
    else
		addkfnum = 12+math.modf(zm/1)
	end 
	JY.Base["武功数量"] = JY.Base["武功数量"] + addkfnum
	if JY.Base["武功数量"]>15 then 
		JY.Base["武功数量"]=15
	end	

	--标准主角+特殊主角
	lib.LoadPicture(CC.BG01File,-1,-1)
	if player_type == 3 then
		if ts == 1 then 
			JY.Base["特殊"] = 1
			--特殊主角的贴图
			JY.Person[0]["姓名"] = "无酒不欢"
			JY.Person[0]["头像代号"] = 355
			JY.Person[0]["半身像"] = 355
			local T_ani = {
				{0, 0, 0}, 
				{0, 0, 0}, 
				{10, 8, 6}, 
				{0, 0, 0}, 
				{0, 0, 0}}
			for i = 1, 5 do
				JY.Person[0]["出招动画帧数" .. i] = T_ani[i][1]
				JY.Person[0]["出招动画延迟" .. i] = T_ani[i][3]
				JY.Person[0]["武功音效延迟" .. i] = T_ani[i][2]
			end
		elseif ts == 2 then
            JY.Base["特殊"] = 2
			JY.Person[0]["姓名"] = "凡芯儿"
			JY.Person[0]["性别"] = 1
			JY.Person[0]["外号"] = "姑娘"
			JY.Person[0]["外号2"] = "丫头"
			JY.Person[0]["头像代号"] = 368
			JY.Person[0]["半身像"] = 580
			local f_ani = {
					{0, 0, 0}, 
					{0, 0, 0}, 
					{17, 15, 13}, 
					{0, 0, 0}, 
					{0, 0, 0}}
			for i = 1, 5 do
				JY.Person[0]["出招动画帧数" .. i] = f_ani[i][1]
				JY.Person[0]["出招动画延迟" .. i] = f_ani[i][3]
				JY.Person[0]["武功音效延迟" .. i] = f_ani[i][2]
			end
		end
	elseif player_type == 2 then
		local clone_choice = cx
		JY.Base["畅想"] = cx
		
		JY.Person[0]["代号"]=JY.Person[clone_choice]["代号"]
		JY.Person[0]["头像代号"]=JY.Person[clone_choice]["头像代号"]
		JY.Person[0]["半身像"]=JY.Person[clone_choice]["半身像"]
		JY.Person[0]["生命增长"]=JY.Person[clone_choice]["生命增长"]
       	if JY.Person[0]["生命增长"] < 5 then
		JY.Person[0]["生命增长"] = 5
		end
		if JY.Person[0]["生命增长"] > 12 then
            JY.Person[0]["生命增长"] = 12
		end
		JY.Person[0]["无用"]=JY.Person[clone_choice]["无用"]
		JY.Person[0]["姓名"]=JY.Person[clone_choice]["姓名"]
		JY.Person[0]["外号"]=JY.Person[clone_choice]["外号"]
		JY.Person[0]["性别"]=JY.Person[clone_choice]["性别"]

		JY.Person[0]["武器"]=-1
		JY.Person[0]["防具"]=-1
		JY.Person[0]["坐骑"]=-1
		for i=1,5 do
			JY.Person[0]["出招动画帧数" .. i]=JY.Person[clone_choice]["出招动画帧数" .. i]
			JY.Person[0]["出招动画延迟" .. i]=JY.Person[clone_choice]["出招动画延迟" .. i]
			JY.Person[0]["武功音效延迟" .. i]=JY.Person[clone_choice]["武功音效延迟" .. i]
		end
		
		--畅想攻防轻最低55
		JY.Person[0]["攻击力"]=limitX(JY.Person[clone_choice]["攻击力"]/4,55,75)
		JY.Person[0]["防御力"]=limitX(JY.Person[clone_choice]["防御力"]/4,55,75)
		JY.Person[0]["轻功"]=limitX(JY.Person[clone_choice]["轻功"]/4,55,75)
		--医疗用毒解毒最低30
		JY.Person[0]["医疗能力"]=limitX(JY.Person[clone_choice]["医疗能力"],30)
		JY.Person[0]["用毒能力"]=limitX(JY.Person[clone_choice]["用毒能力"],30)
		JY.Person[0]["解毒能力"]=limitX(JY.Person[clone_choice]["解毒能力"],30)
	    JY.Person[0]["暗器技巧"]=limitX(JY.Person[clone_choice]["暗器技巧"],30)+zm
		JY.Person[0]["抗毒能力"]=JY.Person[clone_choice]["抗毒能力"]
		JY.Person[0]["主运内功"]=nil
		JY.Person[0]["主运轻功"]=nil	
		JY.Person[0]["个人觉醒"]= 0
		JY.Person[0]["优先使用"]= 0

		if CC.PersonExit[clone_choice] ~= nil  then
		
		JY.Person[0]["拳掌功夫"]=limitX(JY.Person[clone_choice]["拳掌功夫"],30,70)+zm
		JY.Person[0]["指法技巧"]=limitX(JY.Person[clone_choice]["指法技巧"],30,70)+zm
		JY.Person[0]["御剑能力"]=limitX(JY.Person[clone_choice]["御剑能力"],30,70)+zm		
		JY.Person[0]["耍刀技巧"]=limitX(JY.Person[clone_choice]["耍刀技巧"],30,70)+zm	
		JY.Person[0]["特殊兵器"]=limitX(JY.Person[clone_choice]["特殊兵器"],30,70)+zm	
		else
        
		JY.Person[0]["拳掌功夫"]=limitX(JY.Person[clone_choice]["拳掌功夫"]/3,30,70)+zm
		JY.Person[0]["指法技巧"]=limitX(JY.Person[clone_choice]["指法技巧"]/3,30,70)+zm
		JY.Person[0]["御剑能力"]=limitX(JY.Person[clone_choice]["御剑能力"]/3,30,70)+zm		
		JY.Person[0]["耍刀技巧"]=limitX(JY.Person[clone_choice]["耍刀技巧"]/3,30,70)+zm	
		JY.Person[0]["特殊兵器"]=limitX(JY.Person[clone_choice]["特殊兵器"]/3,30,70)+zm	
	    end
        
		JY.Person[0]["武学常识"]=JY.Person[clone_choice]["武学常识"]
		JY.Person[0]["攻击带毒"]=JY.Person[clone_choice]["攻击带毒"]
		JY.Person[0]["左右互搏"]=JY.Person[clone_choice]["左右互搏"]
		JY.Person[0]["中庸"]=JY.Person[clone_choice]["中庸"]

			for i=1,JY.Base["武功数量"] do
				JY.Person[0]["武功" .. i]=JY.Person[clone_choice]["武功" .. i]
				JY.Person[0]["武功等级" .. i]=JY.Person[clone_choice]["武功等级" .. i]
				if i > 2 then
					JY.Person[0]["武功" .. i] = 0
				   JY.Person[0]["武功等级" .. i] = 0	
				end
			end

		for i=1,4 do
			JY.Person[0]["携带物品" .. i]=JY.Person[clone_choice]["携带物品" .. i]
			JY.Person[0]["携带物品数量" .. i]=JY.Person[clone_choice]["携带物品数量" .. i]
		end
		
		for i=1,4 do
			JY.Person[0]["天赋外功"..i]=JY.Person[clone_choice]["天赋外功"..i]
		end
		
		JY.Person[0]["天赋内功"]=JY.Person[clone_choice]["天赋内功"]
		JY.Person[0]["天赋轻功"]=JY.Person[clone_choice]["天赋轻功"]
		--JY.Person[0]["畅想分阶"]=JY.Person[clone_choice]["畅想分阶"]
		JY.Person[0]["外号2"]=JY.Person[clone_choice]["外号2"]
		JY.Person[0]["特色指令"] = JY.Person[clone_choice]["特色指令"]
			
		
		
		--畅想王重阳开局选择外功
		if JY.Base["畅想"] == 129 then
			local wcywg = JYMsgBox("请选择", "请选择你的初始外功", {"全真剑法","一阳指"}, 2, 129)
			if wcywg == 1 then
				JY.Person[0]["武功1"]=39
				JY.Person[0]["武功等级1"]=999
			elseif wcywg == 2 then
				JY.Person[0]["武功1"]=17
				JY.Person[0]["武功等级1"]=999
			end
			JY.Person[0]["武功2"]=100
			JY.Person[0]["武功等级2"]=999
			ClsN()
		end
		
		--畅想裘千尺头像变美
		if JY.Base["畅想"] == 617 then
			JY.Person[0]["头像代号"]=353
			JY.Person[0]["半身像"]=353
			JY.Person[0]["出招动画帧数3"]=24
			JY.Person[0]["出招动画延迟3"]=22
			JY.Person[0]["武功音效延迟3"]=22
		end
		--东方不败初骀
		if JY.Base["畅想"] == 27 then
           --instruct_32(349,-1)
		end		
		--畅想杨过初始化
		if JY.Base["畅想"] == 58 then
			JY.Scene[19]["进入条件"] = 1
			JY.Scene[101]["进入条件"] = 1
			JY.Scene[36]["进入条件"] = 1
			JY.Scene[28]["进入条件"] = 1
			JY.Scene[93]["进入条件"] = 1
			JY.Scene[105]["进入条件"] = 1
			null(18, 6)
			null(70, 87)
			addevent(70, 95, 0, 4188, 3, 0)
		end
        --初始独孤
		if JY.Base["畅想"] == 592 then
		    JY.Person[0]["武功2"]= 0
			JY.Person[0]["武功等级2"]= 0
			JY.Person[0]["耍刀技巧"]=30+zm
			JY.Person[0]["特殊兵器"]=30+zm
			JY.Person[0]["指法技巧"]=30+zm
			JY.Person[0]["拳掌功夫"]=30+zm
	     end
		--畅想斗酒僧初始化
		if JY.Base["畅想"] == 638 then
			JY.Person[0]["武功1"]=106
			JY.Person[0]["武功等级1"]=999
			JY.Person[0]["武功2"]=0	
			JY.Person[0]["武功等级2"]=0		
			JY.Person[0]["武学常识"]=100	   			
		end		
		--畅想胡一刀初始化
		if JY.Base["畅想"] == 633 then
			JY.Person[0]["耍刀技巧"]=70+zm
			JY.Person[0]["武功1"]=67
			JY.Person[0]["武功等级1"]=999
			JY.Person[0]["武功2"]=0
			JY.Person[0]["武功等级2"]=0			
		end	
        if JY.Base["畅想"] == 721 then
			JY.Person[0]["耍刀技巧"]=50
			JY.Person[0]["特殊兵器"]=50
			JY.Person[0]["指法技巧"]=50
			JY.Person[0]["拳掌功夫"]=50
            JY.Person[0]["暗器技巧"]=200
        end
   		Hp_Max(0)	
	elseif player_type == 1 then 
	
			if xb == 1 then 
				JY.Person[0]["性别"] = 1
				JY.Person[0]["外号"] = "姑娘"
				JY.Person[0]["外号2"] = "丫头"				
				local f_ani = {
				{0, 0, 0}, 
				{9, 9, 7}, 
				{8, 8, 6}, 
				{8, 8, 6}, 
				{9, 7, 7}}
				for i = 1, 5 do
					JY.Person[0]["出招动画帧数" .. i] = f_ani[i][1]
					JY.Person[0]["出招动画延迟" .. i] = f_ani[i][3]
					JY.Person[0]["武功音效延迟" .. i] = f_ani[i][2]
				end
			end
			
			--是标主
			SetS(10, 0, 6, 0, 1)
			if zj == 1 then         --拳
				SetS(4, 5, 5, 5, 1)
				JY.Person[0]["拳掌功夫"] = 50+zm
				JY.Base["标准"] = 1
				if xb == 1 then
				JY.Person[0]["头像代号"] = 227
				else
				JY.Person[0]["头像代号"] = 387
				end
			elseif zj == 2 then     --指
				JY.Person[0]["指法技巧"] = 50+zm
				JY.Base["标准"] = 2
				if xb == 1 then
				JY.Person[0]["头像代号"] = 227
				else
				JY.Person[0]["头像代号"] = 387
				end
			elseif zj == 3 then     --剑
				SetS(4, 5, 5, 5, 2)
				JY.Person[0]["御剑能力"] = 50+zm
				JY.Base["标准"] = 3	
				if xb == 1 then
				JY.Person[0]["头像代号"] = 228
				else
				JY.Person[0]["头像代号"] = 387
				end
			elseif zj == 4 then     --刀
				SetS(4, 5, 5, 5, 3)
				JY.Person[0]["耍刀技巧"] = 50+zm
				JY.Base["标准"] = 4
				if xb == 1 then
				JY.Person[0]["头像代号"] = 229
				else
				JY.Person[0]["头像代号"] = 387
				end
			elseif zj == 5 then		 --特 
				SetS(4, 5, 5, 5, 4)
				JY.Person[0]["特殊兵器"] = 50+zm
				JY.Base["标准"] = 5
				if xb == 1 then
				JY.Person[0]["头像代号"] = 230
				else
				JY.Person[0]["头像代号"] = 387
				end
			elseif zj == 6 then		 --天罡
				JY.Person[0]["内力最大值"] = 500
				JY.Person[0]["内力"] = 500
				SetS(4, 5, 5, 5, 5)
				JY.Base["标准"] = 6
				if xb == 1 then
				JY.Person[0]["头像代号"] = 227
				else
				JY.Person[0]["头像代号"] = 387
				end
			elseif zj == 7 then		 --仁者
				JY.Person[0]["品德"] = 100
				JY.Person[0]["拳掌功夫"] = 40+zm
				JY.Person[0]["指法技巧"] = 40+zm
				JY.Person[0]["御剑能力"] = 40+zm
				JY.Person[0]["耍刀技巧"] = 40+zm
				JY.Person[0]["特殊兵器"] = 40+zm
				SetS(4, 5, 5, 5, 6)
				JY.Base["标准"] = 7
				if xb == 1 then
				JY.Person[0]["头像代号"] = 227
				else
				JY.Person[0]["头像代号"] = 387
				end				
			elseif zj == 8 then		 --医生
				JY.Person[0]["拳掌功夫"] = 40+zm
				JY.Person[0]["指法技巧"] = 40+zm
				JY.Person[0]["御剑能力"] = 40+zm
				JY.Person[0]["耍刀技巧"] = 40+zm
				JY.Person[0]["特殊兵器"] = 40+zm
				JY.Person[0]["医疗能力"] = 200
				JY.Person[0]["用毒能力"] = 200
				JY.Person[0]["解毒能力"] = 200
				SetS(4, 5, 5, 5, 7)
				JY.Base["标准"] = 8
				if xb == 1 then
				JY.Person[0]["头像代号"] = 227
				else
				JY.Person[0]["头像代号"] = 387
				end				
			elseif zj == 9 then		 --毒王
				JY.Base["标准"] = 9
				JY.Person[0]["拳掌功夫"] = 40+zm
				JY.Person[0]["指法技巧"] = 40+zm
				JY.Person[0]["御剑能力"] = 40+zm
				JY.Person[0]["耍刀技巧"] = 40+zm
				JY.Person[0]["特殊兵器"] = 40+zm
				JY.Person[0]["用毒能力"] = 300
				JY.Person[0]["解毒能力"] = 300
				if xb == 1 then
				JY.Person[0]["头像代号"] = 227
				else
				JY.Person[0]["头像代号"] = 387
				end				
			end            	
	end
    
    GAME_START2()	

	ClsN()
	lib.LoadPicture(CC.BG01File,-1,-1)	
	
    TGTF()

	ClsN()
	ShowScreen()

    if JY.Base["标准"] == 6 then 
        JY.Person[0]["内力性质"] = 3
    end
	--其他人物初始化
	for p = 0, JY.PersonNum-1 do
		
		--敌方的初始化
		if CC.PersonExit[p] == nil and p ~= 0 then

			for i = 1, JY.Base["武功数量"] do
				if JY.Person[p]["武功" .. i] > 0 then
					if p < 191 then
						--JY.Person[p]["武功等级" .. i] = 999    --BOSS武功是为极
					else
						--不到10级的加到10级
						if JY.Person[p]["武功等级" .. i] < 900 then
							JY.Person[p]["武功等级" .. i] = 900
						end
					end
				else
					break;
				end
			end
		
			--生命不足200的加到200
			if JY.Person[p]["生命最大值"] < 200 then
				JY.Person[p]["生命最大值"] = 200
				JY.Person[p]["生命"] = JY.Person[p]["生命最大值"]
			end
			
			--内力不足200的加到200
			if JY.Person[p]["内力最大值"] < 200 then
				JY.Person[p]["内力最大值"] = 200
				JY.Person[p]["内力"] = JY.Person[p]["内力最大值"]
			end
			
			--设置血量翻倍，根据难度系数提高
			local dif_factor;
			--难1，难2
			if JY.Base["难度"] < 3 then
				dif_factor = 2;
			--难3，
			elseif JY.Base["难度"] == 3 then
				dif_factor = 3;
				--难4
			else
				dif_factor = 4;
			end			
			JY.Person[p]["血量翻倍"] = dif_factor
			
			--木桩血量不翻倍
			if p == 591 then
				JY.Person[p]["血量翻倍"] = 1
			end
			
			--李秋水的无相分身为1血
			if p == 600 then
				JY.Person[p]["生命最大值"] = 1
				JY.Person[p]["生命"] = JY.Person[p]["生命最大值"]
				JY.Person[p]["血量翻倍"] = 1
			end
	        JY.Person[p]["生命最大值"] = JY.Person[p]["生命最大值"]*JY.Person[p]["血量翻倍"]
        local nd = JY.Base["难度"]
	    local zm = limitX(JY.Base["周目"],1,100)
	    local xs = 0
	    local wc = 0
 	    local sw = 0
			
			--每周目增加20点系数，三围，武常
			if nd > 1 and  p ~= 591 then 
				xs = zm*3
				wc = zm*3
				sw = zm*3
			end
			--三周目开始，每周目增加20点系数，三围，武常
			if nd > 1 and  p ~= 591 then
				xs = xs + (nd-1)*3
				sw = sw + (nd-1)*5 
				wc = wc + (nd-1)*3
			end
			if  nd >= 4 then
				sw = sw + 50
            end
			local sz = sw*3
            local fx = math.random(4)
			while sz > 0 do 
				local n = math.random(3)
                local tt = 5
                if fx == 1 and n == 1 then 
                    tt = tt*2
                end    
                if fx == 2 and n == 2 then 
                    tt = tt*2
                end  
                if fx == 3 and n == 3 then 
                    tt = tt*2
                end
				if sz < tt then 
					tt = sz
				end
				if n == 1 then 
					JY.Person[p]["攻击力"] = JY.Person[p]["攻击力"] + tt
				elseif n == 2 then 
					JY.Person[p]["防御力"] = JY.Person[p]["防御力"] + tt
				else
					JY.Person[p]["轻功"] = JY.Person[p]["轻功"] + tt
				end
				sz = sz - tt
				
			end
			JY.Person[p]["拳掌功夫"] = JY.Person[p]["拳掌功夫"] + xs
			JY.Person[p]["指法技巧"] = JY.Person[p]["指法技巧"] + xs
			JY.Person[p]["御剑能力"] = JY.Person[p]["御剑能力"] + xs
			JY.Person[p]["耍刀技巧"] = JY.Person[p]["耍刀技巧"] + xs
			JY.Person[p]["特殊兵器"] = JY.Person[p]["特殊兵器"] + xs
			JY.Person[p]["武学常识"] = JY.Person[p]["武学常识"] + wc
			
			
			AddPersonAttrib(p,'生命',math.huge)		
        else 
            JY.Person[p]["畅想分阶"] = 7
		end
        
	end	
	--无酒不欢：增加一些初始化设定
	
	--华山后山谢无悠
	instruct_3(80, 17, 1, 0, 4105, 0, 0, 4133*2, 4133*2, 4133*2, 0, -2, -2)
	
	--鸠摩智贴图
	instruct_3(16, 10, -2,-2,-2,-2,-2,4153*2,4153*2,4153*2,-2,-2,-2)
	
	--李文秀贴图
	instruct_3(62,4,0,0,0,0,0,9238,9238,9238,0,0,0); 
	--新华山论剑事件
	addevent(80, 19, 1, 4141, 1, 4335*2)	--羊

end

--无酒不欢：机率判定函数
function JLSD(s1, s2, dw)
	local s = math.random(100)
	local chance_up = 0;
	--论剑打赢阿凡提奖励，几率+6
	--[[
	if dw == 0 and JY.Person[606]["论剑奖励"] == 1 then
		chance_up = 3
	end]]
	--如果不在队伍中，几率+20
	--if inteam(dw) == false then
	--	chance_up = 10
	--end
    if (JY.Base["标准"] == 7 and dw == 0 and  WAR.SEYB == 0) or match_ID(dw,189) then
       	chance_up = 10
	end	
	--冯衡增加特效
	if inteam(dw) == true and match_ID(dw,588) then
        chance_up =	10
	end 
	if inteam(dw) == true and Curr_NG(dw,102) then
        chance_up =	10
	end

	--判定是否成功
	if s1 < s and s <= s2 + chance_up then
		return true
	else
		return false
	end
end

--游戏主循环
function Game_Cycle()
    lib.Debug("Start game cycle");

    while JY.Status ~=GAME_END and JY.Status ~=GAME_START do
		if JY.Restart == 1 then
			break
		end
        local t1=lib.GetTime();

	    JY.Mytick=JY.Mytick+1;    --20个节拍无击键，则主角变为站立状态
		if JY.Mytick%20==0 then
            JY.MyCurrentPic=0;
		end

        if JY.Mytick%1000==0 then
            JY.MYtick=0;
        end

        if JY.Status==GAME_FIRSTMMAP then  --首次显示主场景，重新调用主场景贴图，渐变显示。然后转到正常显示
			CleanMemory()
			lib.ShowSlow(20, 1)
			JY.MmapMusic = 57
			JY.Status = GAME_MMAP
			Init_MMap()
			lib.DrawMMap(JY.Base["人X"], JY.Base["人Y"], GetMyPic())
			lib.ShowSlow(20, 0)
        elseif JY.Status==GAME_MMAP then
            Game_MMap();
 		elseif JY.Status==GAME_SMAP then
            Game_SMap();
		end
		collectgarbage("step", 0)
        local t2=lib.GetTime();
	    if t2-t1<CC.Frame then
            lib.Delay(CC.Frame-(t2-t1));
	    end
	end
end

function Game_MMap()      --主地图
	if JY.Restart == 1 then
		return
	end

    local direct = -1;
    local keypress, ktype, mx, my = lib.GetKey();
	--先检测跟上次不同的方向是否被按下
    for i = VK_RIGHT,VK_UP do
        if i ~= CC.PrevKeypress and lib.GetKeyState(i) ~=0 then
			keypress = i
		end
	end 
    --如果与上次不同的方向未被按下，则检测与上次相同的方向是否被按下
	if keypress==-1 and	lib.GetKeyState(CC.PrevKeypress) ~=0 then
		keypress = CC.PrevKeypress
	end
    CC.PrevKeypress = keypress
    if keypress==VK_UP then
		direct=0;
		JY.WalkCount = JY.WalkCount + 1
	elseif keypress==VK_DOWN then
		direct=3;
		JY.WalkCount = JY.WalkCount + 1
	elseif keypress==VK_LEFT then
		direct=2;
		JY.WalkCount = JY.WalkCount + 1
	elseif keypress==VK_RIGHT then
		direct=1;
		JY.WalkCount = JY.WalkCount + 1
	else
		JY.WalkCount = 0
	end
    
    if ktype == 1 then
	    JY.Mytick=0;
		if keypress==VK_ESCAPE then
			Cls()
			--MMenu();
			CMenu() 
			if JY.Status ~= GAME_MMAP  then
				return ;
			end
		elseif keypress == VK_H then		--按h直接回家
			My_Enter_SubScene(70, 35, 31, 2);
			return;
		--无酒不欢：全套快捷键 7-30
		elseif keypress == VK_S then	--存档
			Menu_SaveRecord()
			if JY.Status ~= GAME_MMAP  then
				return ;
			end
		elseif keypress == VK_L then	--读档
			Menu_ReadRecord()
			if JY.Status ~= GAME_MMAP  then
				return ;
			end
		elseif keypress == VK_Z then	--状态
			Cls()
			Menu_Status()
		elseif keypress == VK_E then	--物品
			Cls()
			Menu_Thing()
		elseif keypress == VK_F1 then	--马车	
			Cls()
			My_ChuangSong_Ex()
			if JY.Status ~= GAME_MMAP then
				return;
			end
		--elseif keypress == VK_F2 then	--双儿				
		--    CallCEvent(690)				
		elseif keypress == VK_F3 then	--队友排位
			Cls()
			Menu_TZDY()
		elseif keypress == VK_F4 then	--整理
			Cls()		
			Menu_WPZL()
		end
	elseif ktype == 2 or ktype == 3 then
		local tmpx,tmpy = mx, my
		mx = mx - CC.ScreenW / 2
		my = my - CC.ScreenH / 2
		mx = (mx) / CC.XScale
		my = (my) / CC.YScale
		mx, my = (mx + my) / 2, (my - mx) / 2
		if mx > 0 then
			mx = mx + 0.99
		else
			mx = mx - 0.01
		end
		if my > 0 then
			my = my + 0.99
		else
			mx = mx - 0.01
		end
		mx = math.modf(mx)+JY.Base["人X"];
		my = math.modf(my)+ JY.Base["人Y"]
				
		--鼠标移动
		if ktype == 2 then
			if lib.GetMMap(mx, my, 3) > 0 then				--如果有建筑，判断是否可进入
				for i=0, 4 do
		    		for j=0, 4 do
		    			local xx, yy = mx-i, my-j;
				    	local sid=CanEnterScene(xx,xx);
				    	if sid < 0 then
				    		xx, yy = mx+i, my+j;
				    		sid=CanEnterScene(xx,yy);
				    	end
						if sid>=0 then
							CC.MMapAdress[0] = sid;
							CC.MMapAdress[1] = tmpx;
							CC.MMapAdress[2] = tmpy;
							CC.MMapAdress[3] = xx;
							CC.MMapAdress[4] = yy;
		
							i=5;		--退出循环
							break;
						end
					end
				end
			else
				CC.MMapAdress[0]= nil;
			end
		--鼠标左键
		elseif ktype == 3 then
			if tmpx >= 0 and tmpx <= CC.ScreenW/936*63 and 
			   tmpy >= CC.ScreenH/701*110 and tmpy <= CC.ScreenH/701*160 then
			   CMenu()
			else   
				if CC.MMapAdress[0] ~= nil then
					mx = CC.MMapAdress[3] - JY.Base["人X"];
					my = CC.MMapAdress[4] - JY.Base["人Y"];
					CC.MMapAdress[0]= nil;
				else
					AutoMoveTab = {[0] = 0}
					mx = mx - JY.Base["人X"]
					my = my - JY.Base["人Y"]
				end
				walkto(mx, my)
			end
		end
	elseif ktype == 4 then
		JY.Mytick=0;
		Cls()
		--MMenu();
		CMenu() 
		if JY.Status ~= GAME_MMAP then
			return ;
		end
	end
    
    if AutoMoveTab[0] ~= 0 then
	    if direct == -1 then
			direct = AutoMoveTab[AutoMoveTab[0]]
			AutoMoveTab[AutoMoveTab[0]] = nil
			AutoMoveTab[0] = AutoMoveTab[0] - 1
	    end
	else
	    AutoMoveTab = {[0] = 0}
	end


    local x,y;              --按照方向键要到达的坐标
	local CanMove = function(nd, nnd)
		local nx, ny = JY.Base["人X"] + CC.DirectX[nd + 1], JY.Base["人Y"] + CC.DirectY[nd + 1]
		if nnd ~= nil then
			nx, ny = nx + CC.DirectX[nnd + 1], ny + CC.DirectY[nnd + 1]
		end
		if CC.hx == nil and ((lib.GetMMap(nx, ny, 3) == 0 and lib.GetMMap(nx, ny, 4) == 0) or CanEnterScene(nx, ny) ~= -1) then
			return true
		else
			return false
		end
	end
    if direct ~= -1 then   --按下了光标键
        AddMyCurrentPic();         --增加主角贴图编号，产生走路效果
        x=JY.Base["人X"]+CC.DirectX[direct+1];
        y=JY.Base["人Y"]+CC.DirectY[direct+1];
        JY.Base["人方向"]=direct;
		if JY.WalkCount == 1 then
			lib.Delay(90)
		end
    else
        x=JY.Base["人X"];
        y=JY.Base["人Y"];

    end

	if direct~=-1 then
		JY.SubScene=CanEnterScene(x,y);   --判断是否进入子场景
	end

    if lib.GetMMap(x,y,3)==0 and lib.GetMMap(x,y,4)==0 then     --没有建筑，可以到达
        JY.Base["人X"]=x;
        JY.Base["人Y"]=y;
    end
    JY.Base["人X"]=limitX(JY.Base["人X"],10,CC.MWidth-10);           --限制坐标不能超出范围
    JY.Base["人Y"]=limitX(JY.Base["人Y"],10,CC.MHeight-10);

    if CC.MMapBoat[lib.GetMMap(JY.Base["人X"],JY.Base["人Y"],0)]==1 then
	    JY.Base["乘船"]=1;
	else
	    JY.Base["乘船"]=0;
	end

    lib.DrawMMap(JY.Base["人X"],JY.Base["人Y"],GetMyPic());             --绘画主地图

	--当前XY坐标显示
    if CC.ShowXY==1 then
		lib.LoadPNG(91,43*2,CC.ScreenW/936*136,CC.ScreenH/702*142,2)
	    DrawString(CC.ScreenW/936*70,CC.ScreenH/702*129,string.format("%s %d %d","",JY.Base["人X"],JY.Base["人Y"]) ,C_GOLD,CC.Fontsmall*0.9);
	end
	
	DrawTimer();		--最下方动态提示
	JYZTB();			--左上角简易信息
		--JYZTB1();	
		
	--显示鼠标指中的场景名称
	if CC.MMapAdress[0] ~= nil then
		DrawStrBox(CC.MMapAdress[1]+10,CC.MMapAdress[2],JY.Scene[CC.MMapAdress[0]]["名称"],C_GOLD,CC.DefaultFont);
	end
		
    ShowScreen();

    if JY.SubScene >= 0 then          --进入子场景
        CleanMemory();
		--lib.UnloadMMap();
        --lib.PicInit();
        lib.ShowSlow(20,1)

		JY.Status=GAME_SMAP;
        JY.MmapMusic=-1;

        JY.MyPic=GetMyPic();
        JY.Base["人X1"]=JY.Scene[JY.SubScene]["入口X"]
        JY.Base["人Y1"]=JY.Scene[JY.SubScene]["入口Y"]

        Init_SMap(1);
		return
    end
end

--主角走路
function walkto(xx,yy,x,y,flag)
	local x,y
	AutoMoveTab={[0]=0}
	if JY.Status==GAME_SMAP  then
		x=x or JY.Base["人X1"]
		y=y or JY.Base["人Y1"]
	elseif JY.Status==GAME_MMAP then
		x=x or JY.Base["人X"]
		y=y or JY.Base["人Y"]
	end
	xx,yy=xx+x,yy+y
	if JY.Status==GAME_SMAP then
		CC.AutoMoveEvent[0] = 0;
		CC.AutoMoveEvent[1] = 0;
		CC.AutoMoveEvent[2] = 0;

		if SceneCanPass(xx, yy) == false then
			if GetS(JY.SubScene, xx, yy, 3) > 0 and GetD(JY.SubScene, GetS(JY.SubScene, xx, yy, 3), 2) > 0 then
				CC.AutoMoveEvent[1] = xx;
				CC.AutoMoveEvent[2] = yy;
				--无酒不欢：一处蛋疼的细节修改，自动触发事件的站位优先级
				if x < xx then
					if SceneCanPass(xx-1,yy) then
						xx = xx-1;
					elseif SceneCanPass(xx,yy+1) then
						yy = yy+1;
					elseif SceneCanPass(xx,yy-1) then
						yy = yy-1;
					elseif SceneCanPass(xx+1,yy) then
						xx = xx+1;
					else
						return;
					end
				else
					if SceneCanPass(xx+1,yy) then
						xx = xx+1;
					elseif SceneCanPass(xx,yy+1) then
						yy = yy+1;
					elseif SceneCanPass(xx,yy-1) then
						yy = yy-1;
					elseif SceneCanPass(xx-1,yy) then
						xx = xx-1;
					else
						return;
					end
				end
			else
				return;
			end
		end

	end
	if JY.Status==GAME_MMAP and ((lib.GetMMap(xx,yy,3)==0 and lib.GetMMap(xx,yy,4)==0) or CanEnterScene(xx,yy)~=-1)==false then
		return
	end
	local steparray={};
	local stepmax;
	local xy={}
	if JY.Status==GAME_SMAP then
		for i=0,CC.SWidth-1 do
			xy[i]={}
		end
	elseif JY.Status==GAME_MMAP then
		for i=0,479 do
			xy[i]={}
		end
	end
	if flag~=nil then
		stepmax=640
	else
		stepmax=240
	end
	for i=0,stepmax do
	    steparray[i]={};
        steparray[i].x={};
        steparray[i].y={};
	end
	local function canpass(nx,ny)
		if JY.Status==GAME_SMAP and (nx>CC.SWidth-1 or ny>CC.SWidth-1 or nx<0 or ny<0) then
			return false
		end
		if JY.Status==GAME_MMAP and (nx>479 or ny>479 or nx<1 or ny<1) then
			return false
		end
		if xy[nx][ny]==nil then
			if JY.Status==GAME_SMAP then
				if  SceneCanPass(nx,ny) then
					return true
				end
			elseif JY.Status==GAME_MMAP then
				if (lib.GetMMap(nx,ny,3)==0 and lib.GetMMap(nx,ny,4)==0) or CanEnterScene(nx,ny)~=-1 then
					return true
				end
			end
		end
		return false
	end

	local function FindNextStep(step)
		if step==stepmax then
			return
		end
		local step1=step+1
		local num=0
		for i=1,steparray[step].num do

			if steparray[step].x[i]==xx and steparray[step].y[i]==yy then
				return
			end

			if canpass(steparray[step].x[i]+1,steparray[step].y[i]) then
				num=num+1
				steparray[step1].x[num]=steparray[step].x[i]+1
				steparray[step1].y[num]=steparray[step].y[i]
				xy[steparray[step1].x[num]][steparray[step1].y[num]]=step1
			end
			if canpass(steparray[step].x[i]-1,steparray[step].y[i]) then
				num=num+1
				steparray[step1].x[num]=steparray[step].x[i]-1
				steparray[step1].y[num]=steparray[step].y[i]
				xy[steparray[step1].x[num]][steparray[step1].y[num]]=step1
			end
			if canpass(steparray[step].x[i],steparray[step].y[i]+1) then
				num=num+1
				steparray[step1].x[num]=steparray[step].x[i]
				steparray[step1].y[num]=steparray[step].y[i]+1
				xy[steparray[step1].x[num]][steparray[step1].y[num]]=step1
			end
			if canpass(steparray[step].x[i],steparray[step].y[i]-1) then
				num=num+1
				steparray[step1].x[num]=steparray[step].x[i]
				steparray[step1].y[num]=steparray[step].y[i]-1
				xy[steparray[step1].x[num]][steparray[step1].y[num]]=step1
			end
		end
		if num>0 then
			steparray[step1].num=num
			FindNextStep(step1)
		end
	end

	steparray[0].num=1;
	steparray[0].x[1]=x;
	steparray[0].y[1]=y;
	xy[x][y]=0
	FindNextStep(0);

    local movenum=xy[xx][yy];

	if movenum==nil then
		return
	end
	AutoMoveTab[0]=movenum
	for i=movenum,1,-1 do
        if xy[xx-1][yy]==i-1 then
            xx=xx-1;
            AutoMoveTab[1+movenum-i]=1;
        elseif xy[xx+1][yy]==i-1 then
            xx=xx+1;
            AutoMoveTab[1+movenum-i]=2;
        elseif xy[xx][yy-1]==i-1 then
            yy=yy-1;
            AutoMoveTab[1+movenum-i]=3;
        elseif xy[xx][yy+1]==i-1 then
            yy=yy+1;
            AutoMoveTab[1+movenum-i]=0;
        end
	end
end

function GetMyPic()      --计算主角当前贴图
    local n;
	if JY.Status==GAME_MMAP and JY.Base["乘船"]==1 then
		if JY.MyCurrentPic >=4 then
			JY.MyCurrentPic=0
		end
	else
		if JY.MyCurrentPic >6 then
			JY.MyCurrentPic=1
		end
	end

	if JY.Base["乘船"]==0 then
		if JY.Person[0]["性别"] == 0 then
			n=CC.MyStartPicM+JY.Base["人方向"]*7+JY.MyCurrentPic;
		else
			n=CC.MyStartPicF+JY.Base["人方向"]*7+JY.MyCurrentPic;
		end
	else
	    n=CC.BoatStartPic+JY.Base["人方向"]*4+JY.MyCurrentPic;
	end
	return n;
end

--增加当前主角走路动画帧, 主地图和场景地图都使用
function AddMyCurrentPic()
    JY.MyCurrentPic=JY.MyCurrentPic+1;
end

--场景是否可进
--id 场景代号
--x,y 当前主地图坐标
--返回：场景id，-1表示没有场景可进
function CanEnterScene(x,y)         --场景是否可进
    for id = 0,JY.SceneNum-1 do
		local scene=JY.Scene[id];
		if (x==scene["外景入口X1"] and y==scene["外景入口Y1"]) or
		   (x==scene["外景入口X2"] and y==scene["外景入口Y2"]) then
			local e=scene["进入条件"];
			if e==0 then        --可进
				return id;
			elseif e==1 then    --不可进
				return -1
			end
		end
	end
    return -1;
end

--主菜单
function MMenu()
    local menu={{"队伍",Menu_Teaminfo,1},
	            {"物品",Menu_Thing,1},
				{"医疗",Menu_Doctor,1},
	            {"解毒",Menu_DecPoison,1},
	            {"离队",Menu_PersonExit,1},
	            {"系统",Menu_System,1}
				};

    ShowMenu(menu,6,0,CC.MainMenuX,CC.MainMenuY,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE)
	local x1 =CC.ScreenH/2
	local y1 =CC.ScreenW/2
	--lib.LoadPicture("./data/body/999.png",x1,y1,CC.ScreenW/677*80)
end

--系统子菜单
function Menu_System()
	local menu = {
	{"读取进度", Menu_ReadRecord, 1}, 
	{"保存进度", Menu_SaveRecord, 1}, 
	{"关闭音乐", Menu_SetMusic, 1}, 
	{"关闭音效", Menu_SetSound, 1}, 
	{"物品整理", Menu_WPZL, 1}, 
	--{"系统攻略", Menu_Help, 1},
	{"通关记录", pastReview, 1},
	{"我的代码", Menu_MYDIY, 1},
	{"离开游戏", Menu_Exit2, 1}
	}
	if JY.EnableMusic == 0 then
		menu[3][1] = "打开音乐"
	end
	if JY.EnableSound == 0 then
		menu[4][1] = "打开音效"
	end
	local r = ShowMenu(menu, #menu, 0, CC.MainSubMenuX, CC.MainSubMenuY, 0, 0, 1, 1, CC.DefaultFont, C_ORANGE, C_WHITE)
	if r == 0 then
		return 0
	elseif r < 0 then
		return 1
	end
end

function Menu_MYDIY()
	local r = JYMsgBox("我的代码","执行自定义代码*指定在script/DIY.lua文件",{"确定","取消"},2,nil,1);
	--local r = JYMsgBox("我的代码","如此简单的游戏压根用不到代码");
	if r == 1 then
		dofile(CONFIG.ScriptPath.."DIY.lua");
	end
end

function Menu_Help()
	--暂时取消
	--[[
	local title = "系统攻略";
	local str ="装备说明：查看各种装备的说明。"
						.."*武功说明：查看各种武功的说明。"
						.."*天书攻略：各种天书的拿法，以及游戏技攻略。"
	local btn = {"装备说明","武功说明","天书攻略"};
	local num = #btn;
	local r = JYMsgBox(title,str,btn,num,nil,1);

	if r == 1 then
		ZBInstruce();
	elseif r == 2 then
		WuGongIntruce();
	elseif r == 3 then
		TSInstruce();
	end]]
	return 1;
end

--音乐开关
function Menu_SetMusic()
	if JY.EnableMusic == 0 then
		JY.EnableMusic = 1
		PlayMIDI(JY.CurrentMIDI)
	else
		JY.EnableMusic = 0
		lib.PlayMIDI("")
	end
	return 1
end

--音效开关
function Menu_SetSound()
	if JY.EnableSound == 0 then
		JY.EnableSound = 1
	else
		JY.EnableSound = 0
	end
	return 1
end

--队伍菜单
function Menu_Teaminfo()
	local menu = {
		{"状态查看", Menu_Status, 1}, 
		{"队伍排序", Menu_TZDY, 1}}
	
	ShowMenu(menu, 2, 0, CC.MainSubMenuX, CC.MainSubMenuY, 0, 0, 1, 1, CC.DefaultFont, C_ORANGE, C_WHITE)
end

--物品菜单
function Menu_Thing()
	local menu = {
	{"全部物品", nil, 1}, 
	{"剧情物品", nil, 1}, 
	{"神兵宝甲", nil, 1}, 
	{"武功秘笈", nil, 1}, 
	{"灵丹妙药", nil, 1}, 
	{"伤人暗器", nil, 1}}
	local r = ShowMenu(menu, 6, 0, CC.MainSubMenuX, CC.MainSubMenuY, 0, 0, 1, 1, CC.DefaultFont, C_ORANGE, C_WHITE)
	if r > 0 then
		local thing = {}
		local thingnum = {}
		for i = 0, CC.MyThingNum - 1 do
			thing[i] = -1
			thingnum[i] = 0
		end
		local num = 0
		for i = 0, CC.MyThingNum - 1 do
			local id = JY.Base["物品" .. i + 1]
			if id >= 0 then
				if r == 1 then
					thing[i] = id
					thingnum[i] = JY.Base["物品数量" .. i + 1]
				else
					if JY.Thing[id]["类型"] == r - 2 then
						thing[num] = id
						thingnum[num] = JY.Base["物品数量" .. i + 1]
						num = num + 1
					end
				end
			end 
		end
		--无酒不欢：秘笈显示区分
		if r == 4 then
			IsViewingKungfuScrolls = 1
		end
		local r = SelectThing(thing, thingnum)
		if r >= 0 then
			UseThing(r)
			return 1
		end
	end
	return 0
end

--物品整理
function Menu_WPZL()
	local function swap(a, b) 
		JY.Base["物品" .. a], JY.Base["物品" .. b] = JY.Base["物品" .. b], JY.Base["物品" .. a]
		JY.Base["物品数量" .. a], JY.Base["物品数量" .. b] = JY.Base["物品数量" .. b], JY.Base["物品数量" .. a]
	end
	
	local flag = 0;
	for i=1, CC.MyThingNum do
        flag = 0;
        for j=1, CC.MyThingNum-i+1 do
             if JY.Base["物品"..j] > -1 and JY.Base["物品" .. j+1] > -1 then				--如果两个物品有效
				local wg1 = JY.Thing[JY.Base["物品"..j]]["练出武功"];
				local wg2 = JY.Thing[JY.Base["物品"..j+1]]["练出武功"];                           
				if wg2 < 0 then								--不可练出武功的根据编号排序
					if wg1 > 0 or  (wg1 < 0 and JY.Base["物品"..j] > JY.Base["物品"..j+1])  then                
						swap(j, j+1);
						flag = 1;
					end   
                elseif wg1 > 0 then							--可练出武功的根据类型排序，如果类型相同，再根据武功10级威力排序                         
					if JY.Wugong[wg1]["武功类型"] > JY.Wugong[wg2]["武功类型"] or (JY.Wugong[wg1]["武功类型"] == JY.Wugong[wg2]["武功类型"] 
					and JY.Wugong[wg1]["攻击力10"] > JY.Wugong[wg2]["攻击力10"]) then
						swap(j, j+1);
						flag = 1;
					end
				end
			end
		end
		if flag == 0 then									--如果一轮下来没有任何的交换，肯定就是已经排好序了，直接退出
			break;
		end
	end
	Cls()
	DrawStrBoxWaitKey("行囊整理完毕", C_WHITE, CC.DefaultFont)
end

--大商家卖物品菜单
function MenuDSJ()
	local menu = {
	{"全部物品", nil, 0}, 
	{"剧情物品", nil, 0}, 
	{"神兵宝甲", nil, 1}, 
	{"武功秘笈", nil, 1}, 
	{"灵丹妙药", nil, 1}, 
	{"伤人暗器", nil, 1}}
	local r = ShowMenu(menu, 6, 0, CC.ScreenW/2-CC.DefaultFont*2-10, CC.ScreenH/2-CC.DefaultFont*3, 0, 0, 1, 1, CC.DefaultFont, C_ORANGE, C_WHITE)
	if r > 0 then
		local thing = {}
		local thingnum = {}
		for i = 0, CC.MyThingNum - 1 do
			thing[i] = -1
			thingnum[i] = 0
		end
		local num = 0
		for i = 0, CC.MyThingNum - 1 do
			local id = JY.Base["物品" .. i + 1]
			if id >= 0 then
				if r == 1 then
					thing[i] = id
					thingnum[i] = JY.Base["物品数量" .. i + 1]  
				else
					if JY.Thing[id]["类型"] == r - 2 then
						thing[num] = id
						thingnum[num] = JY.Base["物品数量" .. i + 1]
						num = num + 1
					end
				end
			end
		end
		--无酒不欢：秘笈显示区分
		if r == 4 then
			IsViewingKungfuScrolls = 1
		end
		local r = SelectThing(thing, thingnum)
		if r >= 0 then
			return r
		end
	end
	return -1
end

--铁匠强化物品菜单
function MenuTJQH()
	local thing = {}
	local thingnum = {}
	for i = 0, CC.MyThingNum - 1 do
		thing[i] = -1
		thingnum[i] = 0
	end
	local num = 0
	for i = 0, CC.MyThingNum - 1 do
		local id = JY.Base["物品" .. i + 1]
		if id >= 0 then
			if JY.Thing[id]["类型"] == 1 then
				thing[num] = id
				thingnum[num] = JY.Base["物品数量" .. i + 1]
				num = num + 1
			end	
		end
	end
	local r = SelectThing(thing, thingnum)
	if r >= 0 then
		return r
	end
	return -1
end

--回营整备
function Menu_HYZB()
	if JY.SubScene ~= 25 then
		JY.SubScene = 70
		JY.Base["人X1"] = 8
		JY.Base["人Y1"] = 28
		JY.Base["人X"] = 358
		JY.Base["人Y"] = 235
	end
end

--无酒不欢：新版X菜单
function Menu_Exit()      --离开菜单
	local surid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)
	lib.SetClip(0,0,0,0)
	local t = 0
	for i = 0, (CC.ScreenH/2), 3 do
		lib.Background(0,i,CC.ScreenW,i + 3,t)
		t = t + 1
	end
	for i = (CC.ScreenH/2)+1, CC.ScreenH-3, 3 do
		lib.Background(0,i,CC.ScreenW,i + 3,t)
		t = t - 1
	end
	lib.GetKey()
	local menu = {
	{"离开游戏", nil, 1}, 
	{"返回标题", nil, 1},
	{"继续游戏", nil, 2}}
	local r = ShowMenu(menu, 3, 0, CC.ScreenW/2-105, CC.ScreenH/2-89, 0, 0, 0, 0, 50, C_GOLD, C_WHITE)
	if r == 1 then
        JY.Status =GAME_END;
		lib.FreeSur(surid)
        return 1;
	elseif r == 2 then
		JY.Restart = 1
        JY.Status =GAME_START;
		lib.FreeSur(surid)
        return 0;
	end
	lib.LoadSur(surid, 0, 0)
	ShowScreen();
	lib.FreeSur(surid)
    return 0;
end

--离开菜单
function Menu_Exit2()
    Cls();
    if DrawStrBoxYesNo(-1,-1,"是否真的要离开游戏(Y/N)?",C_WHITE,CC.DefaultFont) == true then
        JY.Status =GAME_END;
		return 1;
    end
end

--保存进度
function Menu_SaveRecord()
	Cls();
	DrawStrBox(-1,CC.ScreenH*1/6-20,"保存进度",LimeGreen,CC.Fontbig,C_GOLD);
	DrawStrBox(104,CC.ScreenH*1/6+26,string.format("%-6s %-4s %-10s %-4s %-4s %-4s %-10s","存档名", "主角", "姓名", "难度", "资质", "天书", "位置"),C_ORANGE,CC.DefaultFont,C_GOLD);
	local r = SaveList();
    if r>0 then
        DrawStrBox(CC.MainSubMenuX2,CC.MainSubMenuY,"请稍候......",C_WHITE,CC.DefaultFont);
        ShowScreen();
        SaveRecord(r);
        Cls();
	end
    return 0;
end

--读取进度
function Menu_ReadRecord()
	Cls();
	DrawStrBox(-1,CC.ScreenH*1/6-20,"读取进度",LimeGreen,CC.Fontbig,C_GOLD);
	DrawStrBox(104,CC.ScreenH*1/6+26,string.format("%-6s %-4s %-10s %-4s %-4s %-4s %-10s","存档名", "主角", "姓名", "难度", "资质", "天书", "位置"),C_ORANGE,CC.DefaultFont,C_GOLD);
	local r = SaveList();
	if r < 1 then
		return 0;
	end
    	
	Cls();
	DrawStrBox(-1,CC.StartMenuY,"请稍候...",C_GOLD,CC.DefaultFont);
	ShowScreen();
	local result = LoadRecord(r);
	if result ~= nil then
		return 0;
	end
	--子场景
	if JY.Base["无用"] ~= -1 then
		if JY.SubScene < 0 then
			CleanMemory()
			--lib.UnloadMMap()
		end
		--lib.PicInit()
		lib.ShowSlow(20, 1)
		JY.Status = GAME_SMAP
		JY.SubScene = JY.Base["无用"]
		JY.MmapMusic = -1
		JY.MyPic = GetMyPic()
		Init_SMap(1)
	--大地图
	else
		JY.SubScene = -1
		JY.Status = GAME_FIRSTMMAP
	end
    return 1;
end

--状态子菜单
function Menu_Status()
	--无酒不欢：各状态下对应X轴
	local xcor = CC.MainSubMenuX +2*CC.MenuBorderPixel+4*CC.DefaultFont+5
	if JY.Status == GAME_WMAP then
		xcor = CC.MainSubMenuX + 15
	end
    DrawStrBox(xcor,CC.MainSubMenuY,"要查阅谁的状态",LimeGreen,CC.DefaultFont,C_GOLD);
	local nexty=CC.MainSubMenuY+CC.SingleLineHeight;

    local r=SelectTeamMenu(xcor,nexty);
    if r >0 then
        ShowPersonStatus(r)
		return 1;
	else
        Cls(xcor,CC.MainSubMenuY,CC.ScreenW,CC.ScreenH);
        return 0;
	end
end

--离队菜单
function Menu_PersonExit()
	DrawStrBox(CC.MainSubMenuX, CC.MainSubMenuY, "要求谁离队", C_WHITE, CC.DefaultFont)
	local nexty = CC.MainSubMenuY + CC.SingleLineHeight
	local r = SelectTeamMenu(CC.MainSubMenuX, nexty)
	if r == 1 then
		DrawStrBoxWaitKey("抱歉！没有你游戏进行不下去", C_GOLD, CC.DefaultFont, nil, LimeGreen)
	else
		if JY.SubScene == 82 then
			do return end
		end
	end
	if r > 0 and JY.SubScene == 55 and JY.Base["队伍" .. r] == 35 then
		do return end
	end
	if r > 1 then
		local personid = JY.Base["队伍" .. r]
		if CC.PersonExit[personid] ~= nil then 
			local v = CC.PersonExit[personid]
			CallCEvent(v)
		end
	end
	Cls()
	return 0
end

--状态子菜单
function Menu_Status()
	--无酒不欢：各状态下对应X轴
	local xcor = CC.MainSubMenuX +2*CC.MenuBorderPixel+4*CC.DefaultFont+5
	if JY.Status == GAME_WMAP then
		xcor = CC.MainSubMenuX + 15
	end
    DrawStrBox(xcor,CC.MainSubMenuY,"要查阅谁的状态",LimeGreen,CC.DefaultFont,C_GOLD);
	local nexty=CC.MainSubMenuY+CC.SingleLineHeight;

    local r=SelectTeamMenu(xcor,nexty);
    if r >0 then
        ShowPersonStatus(r)
		return 1;
	else
        Cls(xcor,CC.MainSubMenuY,CC.ScreenW,CC.ScreenH);
        return 0;
	end
end

--队伍选择人物菜单
function SelectTeamMenu(x,y)
	local menu={};
	for i=1,CC.TeamNum do
        menu[i]={"",nil,0};
		local id=JY.Base["队伍" .. i]
		if id>=0 then
            if JY.Person[id]["生命"]>0 then
                menu[i][1]=JY.Person[id]["姓名"];
                menu[i][3]=1;
            end
		end
	end
    return ShowMenu(menu,CC.TeamNum,0,x,y,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);
end

--计算当前队友个数
function GetTeamNum()
    local r=CC.TeamNum;
	for i=1,CC.TeamNum do
	    if JY.Base["队伍" .. i]<0 then
		    r=i-1;
		    break;
		end
    end
	return r;
end

---显示队伍状态
-- 左右键翻页，上下键换队友
function ShowPersonStatus(teamid)
	local page = 1
	local pagenum = 3
	if JY.Status == GAME_WMAP then
	    if WAR.Person[teamid]["我方"] == false then
	        pagenum = 2
	    end
	end
	--lib.LoadPNGPath(string.format('./data/fight/fight%03d',JY.Person[teamid]["头像代号"]), 89, -1, 100)   --战斗贴图
	local teamnum = GetTeamNum()
	local istart = 1
	local AI_s1 = 1
	local AI_menu_selected = 0
	local WG_num = 0
	local NG_num = 0
	local QG_num = 0
	local AniFrame = 0
	while true do
		if JY.Restart == 1 then
			break
		end
		Cls()
		local id = -1--JY.Base["队伍" .. teamid]
		
		if JY.Status == GAME_WMAP then 
			id = WAR.Person[teamid]["人物编号"]
		else 
			id = JY.Base["队伍" .. teamid]
		end
		local sp = JY.Person[id]
		
		--天赋ID
		local tfid;
		--主角
		if id == 0 then
			--标主
			if JY.Base["标准"] > 0 then
				tfid = 546 + JY.Base["标准"]
			--特殊
			elseif JY.Base["特殊"] > 0 then
				tfid = ''
			--畅想
			else
				tfid = JY.Base["畅想"]
				--畅想袁承志
				if tfid == 54 and JY.Person[id]["个人觉醒"] >= 1 then
					tfid = "54-1"
				--畅想石破天
				elseif tfid == 38 and JY.Person[id]["个人觉醒"] >= 1 then
					tfid = "38-1"
				--畅想郭襄
				elseif tfid == 626 and JY.Person[id]["个人觉醒"] >= 1 then
					tfid = "626-1"				
				end
			end
		--队友
		else
			tfid = id
			--袁承志
			if id == 54 and JY.Person[id]["个人觉醒"] >= 1 then
				tfid = "54-1"
			--石破天
			elseif id == 38 and JY.Person[id]["个人觉醒"] >= 1 then
				tfid = "38-1"
			--郭襄
			elseif id == 626 and JY.Person[id]["个人觉醒"] >= 1 then
				tfid = "626-1"					
			end
		end
		--无酒不欢：第二页的翻页上限判定需要因人而异
		local max_row = -17;
		if TFJS[tfid] ~= nil then
            for j = 1,#TFJS[tfid] do
                max_row = max_row + tjm2(TFJS[tfid][j],32)
            end
            max_row = max_row + 1
		end
		if id == 0 then
            for j = 1,#ZJZSJS do
                max_row = max_row + tjm2(ZJZSJS[j],32)
            end
            max_row = max_row + 1 
		end
        if id == 0 then
            for i,v in pairs(CC.TG) do
                if v == 1 then 
                    max_row = max_row + 1
                    if CC.PTFSM[i][2] ~= nil then
                        max_row = max_row + tjm2(CC.PTFSM[i][2],32)
                    end
                    max_row = max_row + 1
                end
            end
        end
		--AI的子选项默认值获取
		local AI_s2 = {sp["行为模式"],sp["优先使用"],sp["主运内功"],sp["主运轻功"],sp["是否吃药"],sp["生命阈值"],sp["内力阈值"],sp["体力阈值"],sp["禁用自动"]}
		local yxsy = {}
		local yxsynum = 0
		yxsy[0] = 0
		for j = 1, JY.Base["武功数量"] do
			if sp["武功"..j] == 0 then
				break
			end
			--外功，不能选斗转
			--石破天可以选太玄
		local wugongid = sp["武功"..j]
		if ((JY.Wugong[sp["武功"..j]]["武功类型"] <= 5 ) or (match_ID_awakened(id, 38 ,1) and sp["武功"..j] == 102) or  (JY.Wugong[sp["武功"..j]]["武功类型"] == 6 and JY.Base["标准"] == 6 and id == 0)) and 
           ( wugongid == 85 or wugongid == 87 or wugongid == 88 or wugongid == 144 or wugongid == 175  or wugongid == 182  or wugongid == 199 or wugongid == 43)== false then
				yxsynum = yxsynum + 1
				yxsy[yxsynum] = sp["武功"..j]
			end
		end
		local zyng = {}
		local zyngnum = 0
		zyng[0] = 0
		for j = 1, JY.Base["武功数量"] do
			if sp["武功"..j] == 0 then
				break
			end
			--五岳剑诀不能运
			if JY.Wugong[sp["武功"..j]]["武功类型"] == 6  then
				--天罡不能运三大
				if (id == 0 and JY.Base["标准"] == 6)  then
					if sp["武功"..j] == 106 or sp["武功"..j] == 107 or sp["武功"..j] == 108 then
					
					else
						zyngnum = zyngnum + 1
						zyng[zyngnum] = sp["武功"..j]
					end
				else
					zyngnum = zyngnum + 1
					zyng[zyngnum] = sp["武功"..j]
				end
			end
		end
		local zyqg = {}
		local zyqgnum = 0
		zyqg[0] = 0
		for j = 1, JY.Base["武功数量"] do
			if sp["武功"..j] == 0 then
				break
			end
			if JY.Wugong[sp["武功"..j]]["武功类型"] == 7 then
				zyqgnum = zyqgnum + 1
				zyqg[zyqgnum] = sp["武功"..j]
			end
		end
		--状态界面动画显示，89号
		--lib.PicLoadFile(string.format(CC.FightPicFile[1],JY.Person[id]["头像代号"]),
		--string.format(CC.FightPicFile[2],JY.Person[id]["头像代号"]), 89)
		
		local m = 0
		local dl = 0
		for j=1,5 do
			if JY.Person[id]['出招动画帧数'..j]>0 then
				if j>1 then
					m=j
					break;
				end
				dl=dl+JY.Person[id]['出招动画帧数'..j]*4
			end
		end
		dl=dl+JY.Person[id]['出招动画帧数'..m]*3
		ShowPersonStatus_sub(id, page, istart, tfid, max_row, nil, AI_s1, AI_s2, AI_menu_selected,AniFrame,dl)
		ShowScreen()
		local keypress, ktype, mx, my = lib.GetKey()
		lib.Delay(CC.Frame)
		--ktype  1：键盘，2：鼠标移动，3:鼠标左键，4：鼠标右键，5：鼠标中键，6：滚动上，7：滚动下
		if keypress == VK_ESCAPE or ktype == 4 then
			if page == 3 and AI_menu_selected > 0 then
				AI_menu_selected = 0
			else
				break;
			end
		--换装
		elseif keypress == VK_Q and page == 1 and JY.Status ~= GAME_WMAP then	
			Avatar_Switch(id)
			AniFrame = 0
		elseif keypress == VK_UP then
			if page == 1 then
				if JY.Status ~= GAME_WMAP then
					teamid = teamid - 1
					AniFrame = 0
				end
			elseif page == 2 then
				if istart > 1 then
					istart = istart - 1
				end
			elseif page == 3 then
				if AI_menu_selected == 0 then
					AI_s1 = AI_s1 - 1
					--战斗中不能在此切换主运内轻
					if JY.Status == GAME_WMAP and AI_s1 == 4 then
						AI_s1 = AI_s1 - 2
					end
					if AI_s1 < 1 then
						AI_s1 = 9
					end
				end
			end
		elseif keypress == VK_DOWN then
			if page == 1 then
				if JY.Status ~= GAME_WMAP then
					teamid = teamid + 1
					AniFrame = 0
				end
			elseif page == 2 then
				if istart < max_row then
					istart = istart + 1
				end
			elseif page == 3 then
				if AI_menu_selected == 0 then
					AI_s1 = AI_s1 + 1
					--战斗中不能在此切换主运内轻
					if JY.Status == GAME_WMAP and AI_s1 == 3 then
						AI_s1 = AI_s1 + 2
					end
					if AI_s1 > 9 then
						AI_s1 = 1
					end
				end
			end
		elseif keypress == VK_LEFT then
			if page == 3 and AI_menu_selected > 0 then
				if AI_menu_selected == 1 then
					JY.Person[id]["行为模式"] = JY.Person[id]["行为模式"] - 1
					if JY.Person[id]["行为模式"] < 1 then
						JY.Person[id]["行为模式"] = 4
					end
				elseif AI_menu_selected == 2 then
					if WG_num > 0 then
						WG_num = WG_num - 1
						JY.Person[id]["优先使用"] = yxsy[WG_num]
					end
				elseif AI_menu_selected == 3 then
					if NG_num > 0 then
						NG_num = NG_num - 1
						JY.Person[id]["主运内功"] = zyng[NG_num]
						Hp_Max(id)
					end
				elseif AI_menu_selected == 4 then
					if QG_num > 0 then
						QG_num = QG_num - 1
						JY.Person[id]["主运轻功"] = zyqg[QG_num]
					end
				elseif AI_menu_selected == 5 then
					JY.Person[id]["是否吃药"] = JY.Person[id]["是否吃药"] - 1
					if JY.Person[id]["是否吃药"] < 1 then
						JY.Person[id]["是否吃药"] = 2
					end
				elseif AI_menu_selected == 6 then
					JY.Person[id]["生命阈值"] = JY.Person[id]["生命阈值"] - 1
					if JY.Person[id]["生命阈值"] < 1 then
						JY.Person[id]["生命阈值"] = 3
					end
				elseif AI_menu_selected == 7 then
					JY.Person[id]["内力阈值"] = JY.Person[id]["内力阈值"] - 1
					if JY.Person[id]["内力阈值"] < 1 then
						JY.Person[id]["内力阈值"] = 3
					end
				elseif AI_menu_selected == 8 then
					JY.Person[id]["体力阈值"] = JY.Person[id]["体力阈值"] - 1
					if JY.Person[id]["体力阈值"] < 1 then
						JY.Person[id]["体力阈值"] = 3
					end
				elseif AI_menu_selected == 9 then
					JY.Person[id]["禁用自动"] = JY.Person[id]["禁用自动"] - 1
					if JY.Person[id]["禁用自动"] < 1 then
						JY.Person[id]["禁用自动"] = 2
					end
				end
			else
				page = page - 1
				if istart > 1 then
					istart = 1
				end
				if AI_s1 > 1 then
					AI_s1 = 1
				end
			end
		elseif keypress == VK_RIGHT then
			if page == 3 and AI_menu_selected > 0 then
				if AI_menu_selected == 1 then
					JY.Person[id]["行为模式"] = JY.Person[id]["行为模式"] + 1
					if JY.Person[id]["行为模式"] > 4 then
						JY.Person[id]["行为模式"] = 1
					end
				elseif AI_menu_selected == 2 then
					if WG_num < yxsynum then
						WG_num = WG_num + 1
						JY.Person[id]["优先使用"] = yxsy[WG_num]
					end
				elseif AI_menu_selected == 3 then
					if NG_num < zyngnum then
						NG_num = NG_num + 1
						JY.Person[id]["主运内功"] = zyng[NG_num]
						Hp_Max(id)
					end
				elseif AI_menu_selected == 4 then
					if QG_num < zyqgnum then
						QG_num = QG_num + 1
						JY.Person[id]["主运轻功"] = zyqg[QG_num]
					end
				elseif AI_menu_selected == 5 then
					JY.Person[id]["是否吃药"] = JY.Person[id]["是否吃药"] + 1
					if JY.Person[id]["是否吃药"] > 2 then
						JY.Person[id]["是否吃药"] = 1
					end	
				elseif AI_menu_selected == 6 then
					JY.Person[id]["生命阈值"] = JY.Person[id]["生命阈值"] + 1
					if JY.Person[id]["生命阈值"] > 3 then
						JY.Person[id]["生命阈值"] = 1
					end	
				elseif AI_menu_selected == 7 then
					JY.Person[id]["内力阈值"] = JY.Person[id]["内力阈值"] + 1
					if JY.Person[id]["内力阈值"] > 3 then
						JY.Person[id]["内力阈值"] = 1
					end	
				elseif AI_menu_selected == 8 then
					JY.Person[id]["体力阈值"] = JY.Person[id]["体力阈值"] + 1
					if JY.Person[id]["体力阈值"] > 3 then
						JY.Person[id]["体力阈值"] = 1
					end	
				elseif AI_menu_selected == 9 then
					JY.Person[id]["禁用自动"] = JY.Person[id]["禁用自动"] + 1
					if JY.Person[id]["禁用自动"] > 2 then
						JY.Person[id]["禁用自动"] = 1
					end	
				end
			else
				page = page + 1
				if istart > 1 then
					istart = 1
				end
			end
		elseif keypress == VK_SPACE or keypress == VK_RETURN then
			if page == 3 then
				if AI_menu_selected == 0 then
					AI_menu_selected = AI_s1
				else
					AI_menu_selected = 0
				end
			end
		end
		AniFrame = AniFrame + 1
		if AniFrame == JY.Person[id]['出招动画帧数'..m] then
			AniFrame = 0
		end
		if JY.Status ~= GAME_WMAP then
			teamid = limitX(teamid, 1, teamnum)
		end
		page = limitX(page, 1, pagenum)
	end
end

--无酒不欢：人物属性面板
--case：nil=正常浏览，else加点
function ShowPersonStatus_sub(id, page, istart, tfid, max_row, case, AI_s1, AI_s2, AI_menu_selected,AniFrame,dl)
	
	if JY.Restart == 1 then
		do return end
	end
	local size = CC.FontSmall4
	local p = JY.Person[id]
	local p0 = JY.Person[0]
	local h = size + CC.PersonStateRowPixel
	local dx = (CC.ScreenW)/936
	local dy = (CC.ScreenH)/702
	local i = 1
	local x1, y1 = nil, nil
  		--背景图
		lib.LoadPNG(91, 20 * 2 ,0 , 0, 1)
	--无酒不欢：属性显示
	local function DrawAttrib(str, x,y,color1,size)

		--DrawString(x1, y1 + h * i, string.sub(4), color1, size)
		--额外系数显示
		--local str;
		if str == "拳掌功夫" then
			local bonus = 0
			--金丝手套
			if JY.Person[id]["武器"] == 239 then
				bonus = 10
				if JY.Thing[239]["装备等级"] >= 5 then
					bonus = 30
				elseif JY.Thing[239]["装备等级"] >= 4 then
					bonus = 25
				elseif JY.Thing[239]["装备等级"] >= 3 then
					bonus = 20
				elseif JY.Thing[239]["装备等级"] >= 2 then
					bonus = 15
				end
			end
		--林殊敌方人数人越多，系数越高    
		if match_ID(id, 508) and JY.Status == GAME_WMAP then
			local jf = 0
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == false  then
				 jf = jf + 1
			   end				
	       end
         bonus = bonus + jf*5	
	   end			
			--太玄，战场系数*140%
			local ts = 0
			if PersonKF(id, 102) and JY.Status == GAME_WMAP then
				ts = math.modf((JY.Person[id][str]+bonus)*0.4)
			end
			if bonus > 0 or ts > 0 then
				DrawString(x,y,  string.format("+ %s",bonus+ts), color1, size)
			end
		end
		
		if str == "指法技巧" then
			local bonus = 0
			--金丝手套
			if JY.Person[id]["武器"] == 239 then
				bonus = 10
				if JY.Thing[239]["装备等级"] >= 5 then
					bonus = 30
				elseif JY.Thing[239]["装备等级"] >= 4 then
					bonus = 25
				elseif JY.Thing[239]["装备等级"] >= 3 then
					bonus = 20
				elseif JY.Thing[239]["装备等级"] >= 2 then
					bonus = 15
				end
			end
		--林殊敌方人数人越多，系数越高    
		if match_ID(id, 508) and JY.Status == GAME_WMAP then
			local jf = 0
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == false  then
				 jf = jf + 1
			   end				
	       end	
		bonus = bonus + jf*5
	   end			
			--太玄，战场系数*140%
			local ts = 0
			if PersonKF(id, 102) and JY.Status == GAME_WMAP then
				ts = math.modf((JY.Person[id][str]+bonus)*0.4)
			end
			if bonus > 0 or ts > 0 then
				DrawString(x, y, string.format("+ %s",bonus+ts), color1, size)
			end
		end
		
		if str == "御剑能力" then
			local bonus = 0
			--五岳剑法
			if WuyueJF(id) then
				bonus=bonus+50
			end

			--战斗中的剑胆琴心加成
			if JY.Status == GAME_WMAP then
				if WAR.JDYJ[id] then
					bonus = bonus + WAR.JDYJ[id]
				end
			end
			--步惊云剑法 系数
            if match_ID(id, 584) and JY.Status == GAME_WMAP  then
		       local JF = 0
		       for i = 1, JY.Base["武功数量"] do
			   if JY.Wugong[JY.Person[id]["武功" .. i]]["武功类型"] == 3 then
				 JF = JF + 1
			   end
				 bonus = math.modf(JF*10)
			   end
	       end
		--林殊敌方人数人越多，系数越高    
		if match_ID(id, 508) and JY.Status == GAME_WMAP then
			local jf = 0
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == false  then
				 jf = jf + 1
			   end				
	       end	
		bonus = bonus + jf*5
	   end			
			--太玄，战场系数*140%
			local ts = 0
			if PersonKF(id, 102) and JY.Status == GAME_WMAP then
				ts = math.modf((JY.Person[id][str]+bonus)*0.4)
			end
			if bonus > 0 or ts > 0 then
				DrawString(x, y, string.format("+ %s",bonus+ts), color1, size)
			end
		end
		
		if str == "耍刀技巧" then
			--太玄，战场系数*140%
			local ts = 0
			local bonus = 0
			if PersonKF(id, 102) and JY.Status == GAME_WMAP then
				ts = math.modf((JY.Person[id][str])*0.4)
			end
		--林殊敌方人数人越多，系数越高    
		if match_ID(id, 508) and JY.Status == GAME_WMAP then
			local df = 0
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == false  then
				df = df +1
			   end         
	       end
        bonus = bonus + df * 5			
	   end				
			if bonus > 0 or ts > 0 then
				DrawString(x, y, string.format("+ %s",ts+bonus), color1, size)
			end
		end
		
	   if str == "特殊兵器" then
			--太玄，战场系数*140%
			local ts = 0
			local bonus = 0
			if PersonKF(id, 102) and JY.Status == GAME_WMAP then
				ts = math.modf((JY.Person[id]["特殊兵器"])*0.4)
			end
		--林殊敌方人数人越多，系数越高    
		if match_ID(id, 508) and JY.Status == GAME_WMAP  then
			local df = 0
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == false  then
				df = df +1
			   end         		
	       end	
		 bonus = bonus + df * 5
	   end
			if bonus > 0 or ts > 0 then
				DrawString(x,y, string.format("+ %s",ts+bonus), color1, size)
			end
		end
	
		--战场情侣加成
		if JY.Status == GAME_WMAP then
			if str == "医疗能力" then
				for k,v in pairs(CC.AddDoc) do
					if match_ID(id, v[1]) then
						for wid = 0, WAR.PersonNum - 1 do
							if match_ID(WAR.Person[wid]["人物编号"], v[2]) and WAR.Person[wid]["死亡"] == false then
								DrawString(x,y, "+ "..v[3], color1, size)
								--break
							end
						end
					end
				end
			end
			if str == "用毒能力" then
				for k,v in pairs(CC.AddPoi) do
					if match_ID(id, v[1]) then
						for wid = 0, WAR.PersonNum - 1 do
							if match_ID(WAR.Person[wid]["人物编号"], v[2]) and WAR.Person[wid]["死亡"] == false then
								DrawString(x,y, "+ "..v[3], color1, size)
								--break
							end
						end
					end
				end
			end
		i = i + 1
	end
	end
	
	x1 = size*3 -10
	y1 = size + 6

	if page == 1 then
   --247 209
		local hid = nil
		hid = p["半身像"]  		
		--半身象
		local bodyw,  bodyh = lib.GetPNGXY(97, hid*2)		
	     lib.LoadPNG(90, hid * 2, dx*247, dy*209,2)  
-------------------------------
	i = 5

	local ch = nil
	local chcl = C_CYGOLD
    local fj = {[0] = {"传说",C_ORANGE},{"宗师",M_DarkRed},{"豪侠",C_RED},{"一流",M_Pink},{"二流",M_Pink},{"三流",M_Blue},{"弟子",M_LightBlue},{"菜鸟",C_CYGOLD}}

        local fjstr = "【"..fj[p["畅想分阶"]][1].."】"
        local nametre = p["姓名"]
        local djstr = p["等级"].."级"
        
        local namex = CC.ScreenW/2-string.len(fjstr..nametre..djstr)/4*size
        local fjx = namex + string.len(nametre)/2*size
        local djx = fjx + string.len(fjstr)/2*size
		DrawString(fjx, dx*24, fjstr, fj[JY.Person[id]["畅想分阶"]][2], size*0.8)
		DrawString(namex, dx*20, nametre, C_CYGOLD, size)		
		DrawString(djx, dx*24, djstr, C_CYGOLD, size*0.8)
		--DrawString(dx*621, dx*24, "级", C_CYGOLD, size*0.8)		
		i = i + 1	
	
	    local tfx1 = dx*110
		local fty1 = dy*79
		--主角天赋
		if id == 0 then
			local main_tf;
			--标主
			if JY.Base["标准"] > 0 then
				main_tf = ZJTF[JY.Base["标准"]]
			--特殊
			elseif JY.Base["特殊"] > 0 then
				main_tf = " "
			--畅想
			elseif JY.Base["畅想"] > 0 then
				if RWTFLB[p["代号"]] ~= nil then
					main_tf = RWTFLB[p["代号"]]
				end
			end
			if main_tf ~= nil then
				DrawString(tfx1 -string.len(main_tf)/4*size*0.8, fty1, main_tf, C_CYGOLD, size*0.8)
			end
		end

		--普通角色天赋
		if id ~= 0 and RWTFLB[id] ~= nil then
			--DrawString(x1-7, y1 + h * (i)-142,RWTFLB[id], C_CYGOLD, size*0.8)
		    DrawString(tfx1 -string.len(RWTFLB[id])/4*size*0.8, fty1, RWTFLB[id], C_CYGOLD, size*0.8)	
		end
	  
		
		--主角称号
		if id == 0 then
			local main_ch;
			--标主
			if JY.Base["标准"] > 0 then
				if p["六如觉醒"] == 0 then
					main_ch = "江湖小虾米"
				else
					main_ch = "觉醒之苍龙"
				end
			--特殊
			elseif JY.Base["特殊"] > 0 then
				main_ch = ''--TSTF[JY.Base["特殊"]]
			--畅想
			elseif JY.Base["畅想"] > 0 then
				if RWWH[JY.Base["畅想"]] ~= nil and JY.Base["畅想"] ~= 35 and JY.Base["畅想"] ~= 38 and JY.Base["畅想"] ~= 49 
				and JY.Base["畅想"] ~= 626 then
					main_ch = RWWH[JY.Base["畅想"]]
				elseif JY.Base["畅想"] == 35 then
					if JY.Person[id]["个人觉醒"] >= 2 then
						DrawString(tfx1 -string.len(RWWH["35"])/4*size*0.8, dy*122,  RWWH["35"], C_CYGOLD, size*0.8)	
					elseif JY.Person[id]["个人觉醒"] >= 1 then
						--DrawString(x1-7, y1 + h * (i)-100, RWWH[35], C_CYGOLD, size*0.8)
						 DrawString(tfx1 -string.len(RWWH["35"])/4*size*0.8, dy*122,  RWWH["35"], C_CYGOLD, size*0.8)		
					end
				elseif JY.Base["畅想"] == 38 then
					if JY.Person[id]["个人觉醒"] >= 1 then
						--DrawString(x1-7, y1 + h * (i)-100, RWWH["38"], C_CYGOLD, size*0.8)
					    DrawString(tfx1 -string.len(RWWH["38"])/4*size*0.8, dy*122,  RWWH["38"], C_CYGOLD, size*0.8)		
					end
				elseif JY.Base["畅想"] == 49 then
					if JY.Person[id]["个人觉醒"] >= 1 then
						--DrawString(x1-7, y1 + h * (i)-100, RWWH["49"], C_CYGOLD, size*0.8)
					   DrawString(tfx1 -string.len(RWWH["49"])/4*size*0.8, dy*122,  RWWH["49"], C_CYGOLD, size*0.8)	
					else
					--	DrawString(x1-7, y1 + h * (i)-100, RWWH[49], C_CYGOLD, size*0.8)
					   DrawString(tfx1 -string.len(RWWH[49])/4*size*0.8, dy*122,  RWWH[49], C_CYGOLD, size*0.8)	
					end
				elseif JY.Base["畅想"] == 626 then
					if JY.Person[id]["个人觉醒"] >= 1 then
						DrawString(tfx1 -string.len(RWWH["626"])/4*size*0.8, dy*122,  RWWH["626"], C_CYGOLD, size*0.8)
						--DrawString(x1-7, y1 + h * (i)-100, RWWH["626"], C_CYGOLD, size*0.8)
					else
					--	DrawString(x1-7, y1 + h * (i)-100, RWWH[626], C_CYGOLD, size*0.8)
					 DrawString(tfx1 -string.len(RWWH[626])/4*size*0.8, dy*122,  RWWH[626], C_CYGOLD, size*0.8)		
					end
			
				end
			end
			if main_ch ~= nil then
				--DrawString(x1-7, y1 + h * (i)-100, main_ch, C_CYGOLD, size*0.8)
				 DrawString(tfx1 -string.len(main_ch)/4*size*0.8, dy*122,  main_ch, C_CYGOLD, size*0.8)	
			end
		end
		
		--其他人称号
		if RWWH[id] ~= nil and id ~= 35 and id ~= 38 and id ~= 49 then
			--DrawString(x1-7, y1 + h * (i)-100, RWWH[id], C_CYGOLD, size*0.8)
		    DrawString(tfx1 -string.len( RWWH[id])/4*size*0.8, dy*122,  RWWH[id], C_CYGOLD, size*0.8)	
			
		end

		--令狐冲
		if id == 35 then
			if JY.Person[id]["个人觉醒"] >= 2 then
				--DrawString(x1-7, y1 + h * (i)-100, RWWH["35"], C_CYGOLD, size*0.8)
				DrawString(tfx1 -string.len(RWWH["35"])/4*size*0.8, dy*122,  RWWH["35"], C_CYGOLD, size*0.8)
			elseif JY.Person[id]["个人觉醒"] >= 1 then
			--	DrawString(x1-7, y1 + h * (i)-100, RWWH[35], C_CYGOLD, size*0.8)
				 DrawString(tfx1 -string.len(RWWH["35"])/4*size*0.8, dy*122,  RWWH["35"], C_CYGOLD, size*0.8)
			end
		end

		--虚竹
		if id == 49 then
			if JY.Person[id]["个人觉醒"] >= 1 then
				--DrawString(x1-7, y1 + h * (i)-100, RWWH["49"], C_CYGOLD, size*0.8)
				  DrawString(tfx1 -string.len(RWWH["49"])/4*size*0.8, dy*122,  RWWH["49"], C_CYGOLD, size*0.8)	
			else
				--DrawString(x1-7, y1 + h * (i)-100, RWWH[49], C_CYGOLD, size*0.8)
				  DrawString(tfx1 -string.len(RWWH[49])/4*size*0.8, dy*122,  RWWH[49], C_CYGOLD, size*0.8)	
			end
		end
	  
		--石破天
		if id == 38 then
			if JY.Person[id]["个人觉醒"] >= 1 then
				--DrawString(x1-7, y1 + h * (i)-100, RWWH["38"], C_CYGOLD, size*0.8)
				  DrawString(tfx1 -string.len(RWWH["38"])/4*size*0.8, dy*122,  RWWH["38"], C_CYGOLD, size*0.8)	
			end
		end
		
		--郭襄
		if id == 626 then
			if JY.Person[id]["个人觉醒"] >= 1 then
			--	DrawString(x1-7, y1 + h * (i)-100, RWWH["626"], C_CYGOLD, size*0.8)
				  DrawString(tfx1 -string.len(RWWH["626"])/4*size*0.8, dy*122,  RWWH["626"], C_CYGOLD, size*0.8)	
			end
		end
		--萧半和
		if id == 189 then
			if JY.Person[id]["个人觉醒"] >= 1 then
			--	DrawString(x1-7, y1 + h * (i)-100, RWWH["189"], C_CYGOLD, size*0.8)
				  DrawString(tfx1 -string.len(RWWH[189])/4*size*0.8, dy*122,  RWWH[189], C_CYGOLD, size*0.8)	
			end
		end	 
		--苗人凤
		if id == 633 then
			if JY.Person[id]["个人觉醒"] >= 1 then
				--DrawString(x1-7, y1 + h * (i)-100, RWWH["633"], C_CYGOLD, size*0.8)
				DrawString(tfx1 -string.len(RWWH[633])/4*size*0.8, dy*122,  RWWH[633], C_CYGOLD, size*0.8)	
			end
		end			

		--资质
		DrawString(dx*70, dy*155, "资质", C_CYGOLD, size*0.8)
		DrawString(dx*125, dy*155, p["资质"], C_CYGOLD, size*0.8)
		--体质
		DrawString(dx*70, dy*180, "体质", C_CYGOLD, size*0.8)
		DrawString(dx*125, dy*180, p["生命增长"], C_CYGOLD, size*0.8)
        local ii = 0
        local diyx,diyy = CC.ThingPicWidth/2,CC.ThingPicHeight/2
        local ax,ay = x1, y1 + h * i + diyy * ii
        local s = 2
        ax = x1 - size
        ay = y1 + h * i + diyy * ii

		--武器，防具
		i = i + 1
		if p["武器"] > -1 then
			lib.PicLoadCache(2, p["武器"] * 2, diyx/5+ax*8+30, diyy/4+ax*3-80, 1)
			DrawString( diyx/5+ax*8+32, diyy/4+ax*3-80, JY.Thing[p["武器"]]["名称"], C_CYGOLD, size*0.8)
			DrawString( diyx/5+ax*8+32, diyy/4+ax*3-80+size*0.7, "LV"..JY.Thing[p["武器"]]["装备等级"], M_DeepSkyBlue, size*0.7)
		end
		i = i + 1
		if p["防具"] > -1 then
			lib.PicLoadCache(2, p["防具"] * 2, diyx/5+ax*8+30, diyy/4+ax*3+83-63, 1)
			DrawString( diyx/5+ax*8+32, diyy/4+ax*3+20, JY.Thing[p["防具"]]["名称"], C_CYGOLD, size*0.8)
			DrawString( diyx/5+ax*8+32, diyy/4+ax*3+20+size*0.7, "LV"..JY.Thing[p["防具"]]["装备等级"], M_DeepSkyBlue, size*0.7)
		end		
		if p["坐骑"] > -1 then
		 lib.PicLoadCache(2, p["坐骑"] * 2, diyx/5+ax*8+30, diyy/4+ax*3+166-45, 1)
		DrawString( diyx/5+ax*8+32, diyy/4+ax*3+121, JY.Thing[p["坐骑"]]["名称"], C_CYGOLD, size*0.8)
		DrawString( diyx/5+ax*8+32, diyy/4+ax*3+121+size*0.7, "LV"..JY.Thing[p["坐骑"]]["装备等级"], M_DeepSkyBlue, size*0.7)
		end		

		--第二列开始D
	---------------------------------------------------------------------		
		i = 0
	    local color = nil
		if p["受伤程度"] < 33 then
			color = RGB(236, 200, 40)
		elseif p["受伤程度"] < 66 then
			color = RGB(244, 128, 32)
		else
			color = RGB(232, 32, 44)
		end
		i = i + 1
		DrawString(dx*152, dy*412, string.format("%5d", p["生命"]), C_CYGOLD, size*0.7)
		DrawString(dx*202, dy*414, "/", C_CYGOLD, size*0.6)
		if p["中毒程度"] == 0 then
			color = RGB(252, 148, 16)
		elseif p["中毒程度"] < 50 then
			color = RGB(120, 208, 88)
		else
			color = RGB(56, 136, 36)
		end
		DrawString(dx*202, dy*412, string.format("%5s", p["生命最大值"]), C_CYGOLD, size*0.7)
		local nl = nil
		if p["内力性质"] == 0 then
			color = RGB(208, 152, 208)
			nl = "(阴)"
		elseif p["内力性质"] == 1 then
			color = RGB(236, 200, 40)
			nl = "(阳)"
        elseif	p["内力性质"] == 2 then
			color =MilkWhite
			nl = "(调和)"
		else
			color = RGB(252, 172, 92)
			nl = "(天罡)"
		end
		DrawString(dx*152, dy*436, string.format("%5d", p["内力"]), color, size*0.7)
		DrawString(dx*202, dy*440, "/", color, size*0.6)
		DrawString(dx*202, dy*436, string.format("%5d", p["内力最大值"]), color, size*0.7)
		DrawString(dx*262, dy*436, nl, color, size*0.7)	
		if p["主运内功"] == 0 then
			DrawString(dx*398, dy*409, "未运内功",C_CYGOLD, size*0.7)
		else
			DrawString(dx*398, dy*409, JY.Wugong[p["主运内功"]]["名称"], TG_Red_Bright, size*0.7)
		 
			lib.LoadPNG(91, 15 * 2 ,0 ,0, 1)
        end		
		if p["主运轻功"] == 0 then
			DrawString(dx*398, dy*437, "未运轻功",C_CYGOLD, size*0.7)
		else
			DrawString(dx*398, dy*437, JY.Wugong[p["主运轻功"]]["名称"], M_DeepSkyBlue, size*0.7)
			lib.LoadPNG(91, 14 * 2 ,0 ,0, 1)
		end			
--------------------------------------------
		--第一列
        i = 0
		local x1 = dx*113
		local y1 = dy*471
        local dh = size*0.8
		local w1 = size

		--装备增加的属性
		local str_gain, def_gain, agi_gain = 0, 0, 0
		if p["武器"] > -1 then
			if JY.Thing[p["武器"]]["加攻击力"] > 0 then
				str_gain = str_gain + JY.Thing[p["武器"]]["加攻击力"]*10 + JY.Thing[p["武器"]]["加攻击力"]*(JY.Thing[p["武器"]]["装备等级"]-1)*2
			elseif JY.Thing[p["武器"]]["加攻击力"] < 0 then
				str_gain = str_gain + JY.Thing[p["武器"]]["加攻击力"]*10 - JY.Thing[p["武器"]]["加攻击力"]*(JY.Thing[p["武器"]]["装备等级"]-1)*2
			end
			if JY.Thing[p["武器"]]["加防御力"] > 0 then
				def_gain = def_gain + JY.Thing[p["武器"]]["加防御力"]*10 + JY.Thing[p["武器"]]["加防御力"]*(JY.Thing[p["武器"]]["装备等级"]-1)*2
			elseif JY.Thing[p["武器"]]["加防御力"] < 0 then
				def_gain = def_gain + JY.Thing[p["武器"]]["加防御力"]*10 - JY.Thing[p["武器"]]["加防御力"]*(JY.Thing[p["武器"]]["装备等级"]-1)*2
			end
			if JY.Thing[p["武器"]]["加轻功"] > 0 then
				agi_gain = agi_gain + JY.Thing[p["武器"]]["加轻功"]*10 + JY.Thing[p["武器"]]["加轻功"]*(JY.Thing[p["武器"]]["装备等级"]-1)*2
			elseif JY.Thing[p["武器"]]["加轻功"] < 0 then
				agi_gain = agi_gain + JY.Thing[p["武器"]]["加轻功"]*10 - JY.Thing[p["武器"]]["加轻功"]*(JY.Thing[p["武器"]]["装备等级"]-1)*2
			end
		end
		if p["坐骑"] > -1 then
			if JY.Thing[p["坐骑"]]["加攻击力"] > 0 then
				str_gain = str_gain + JY.Thing[p["坐骑"]]["加攻击力"]*10 + JY.Thing[p["坐骑"]]["加攻击力"]*(JY.Thing[p["坐骑"]]["装备等级"]-1)*2
			elseif JY.Thing[p["坐骑"]]["加攻击力"] < 0 then
				str_gain = str_gain + JY.Thing[p["坐骑"]]["加攻击力"]*10 - JY.Thing[p["坐骑"]]["加攻击力"]*(JY.Thing[p["坐骑"]]["装备等级"]-1)*2
			end
			if JY.Thing[p["坐骑"]]["加防御力"] > 0 then
				def_gain = def_gain + JY.Thing[p["坐骑"]]["加防御力"]*10 + JY.Thing[p["坐骑"]]["加防御力"]*(JY.Thing[p["坐骑"]]["装备等级"]-1)*2
			elseif JY.Thing[p["坐骑"]]["加防御力"] < 0 then
				def_gain = def_gain + JY.Thing[p["坐骑"]]["加防御力"]*10 - JY.Thing[p["坐骑"]]["加防御力"]*(JY.Thing[p["坐骑"]]["装备等级"]-1)*2
			end
			if JY.Thing[p["坐骑"]]["加轻功"] > 0 then
				agi_gain = agi_gain + JY.Thing[p["坐骑"]]["加轻功"]*10 + JY.Thing[p["坐骑"]]["加轻功"]*(JY.Thing[p["坐骑"]]["装备等级"]-1)*2
			elseif JY.Thing[p["坐骑"]]["加轻功"] < 0 then
				agi_gain = agi_gain + JY.Thing[p["坐骑"]]["加轻功"]*10 - JY.Thing[p["坐骑"]]["加轻功"]*(JY.Thing[p["坐骑"]]["装备等级"]-1)*2
			end
		end
		if p["防具"] > -1 then
			if JY.Thing[p["防具"]]["加攻击力"] > 0 then
				str_gain = str_gain + JY.Thing[p["防具"]]["加攻击力"]*10 + JY.Thing[p["防具"]]["加攻击力"]*(JY.Thing[p["防具"]]["装备等级"]-1)*2
			elseif JY.Thing[p["防具"]]["加攻击力"] < 0 then
				str_gain = str_gain + JY.Thing[p["防具"]]["加攻击力"]*10 - JY.Thing[p["防具"]]["加攻击力"]*(JY.Thing[p["防具"]]["装备等级"]-1)*2
			end
			if JY.Thing[p["防具"]]["加防御力"] > 0 then
				def_gain = def_gain + JY.Thing[p["防具"]]["加防御力"]*10 + JY.Thing[p["防具"]]["加防御力"]*(JY.Thing[p["防具"]]["装备等级"]-1)*2
			elseif JY.Thing[p["防具"]]["加防御力"] < 0 then
				def_gain = def_gain + JY.Thing[p["防具"]]["加防御力"]*10 - JY.Thing[p["防具"]]["加防御力"]*(JY.Thing[p["防具"]]["装备等级"]-1)*2
			end
			if JY.Thing[p["防具"]]["加轻功"] > 0 then
				agi_gain = agi_gain + JY.Thing[p["防具"]]["加轻功"]*10 + JY.Thing[p["防具"]]["加轻功"]*(JY.Thing[p["防具"]]["装备等级"]-1)*2
			elseif JY.Thing[p["防具"]]["加轻功"] < 0 then
				agi_gain = agi_gain + JY.Thing[p["防具"]]["加轻功"]*10 - JY.Thing[p["防具"]]["加轻功"]*(JY.Thing[p["防具"]]["装备等级"]-1)*2
			end
		end
		--易筋经加成
		local level = 0
		local gj = 0
		local qg = 0
		local fy = 0	
		for i =1,JY.Base["武功数量"] do               -- 查找当前已经炼成武功等级
			 if JY.Person[id]["武功" .. i]==108 then
                level=math.modf(JY.Person[id]["武功等级" .. i] /100)+1;	
		        if level >= 1 then
		        gj = math.modf (JY.Person[id]["攻击力"]*0.03*(level-1))
		        str_gain = str_gain +gj
		        fy = math.modf(JY.Person[id]["防御力"]*0.03*(level-1))
		        def_gain = def_gain +fy
		        qg = math.modf(JY.Person[id]["轻功"]*0.03*(level-1))
		       agi_gain = agi_gain +qg
		        break
		       end	
            end		
        end
	--逍遥游
	if Curr_QG(id,2) then
		 agi_gain =  agi_gain + 20
    end
	--金雁功
	if Curr_QG(id,223) then
		 agi_gain =  agi_gain + math.modf(JY.Person[id]["轻功"]*0.2)
    end	
	--蛇行狸翻
	if Curr_QG(id,224) then
		 agi_gain =  agi_gain + math.modf(JY.Person[id]["轻功"]*0.2)
    end		
		--战场情侣加成 
     if JY.Status == GAME_WMAP then
	    --霍青桐，我方人数人越多，防御越高    
		if match_ID(id, 74) then
		 local hqtgj= 0
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[i]["我方"] then
				 def_gain =  def_gain+10
			end		
	    end	
	end		 
	    --林殊敌方人数人越多，防御越高    
		if match_ID(id, 508) then
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == false  then
				 def_gain =  def_gain+10
				 str_gain =  str_gain +10
			end		
	    end	
	end		 		 
			--队友攻击力加成
			for i,v in pairs(CC.AddAtk) do
				if match_ID(id, v[1]) then
					for wid = 0, WAR.PersonNum - 1 do
						if match_ID(WAR.Person[wid]["人物编号"], v[2]) and WAR.Person[wid]["死亡"] == false then
							str_gain = str_gain + v[3]
						end
					end
				end
			end
			--队友防御力加成
			for i,v in pairs(CC.AddDef) do
				if match_ID(id, v[1]) then
					for wid = 0, WAR.PersonNum - 1 do
						if match_ID(WAR.Person[wid]["人物编号"], v[2]) and WAR.Person[wid]["死亡"] == false then
							def_gain = def_gain + v[3]
						end
					end
				end
			end
			--队友轻功加成
			for i,v in pairs(CC.AddSpd) do
				if match_ID(id, v[1]) then
					for wid = 0, WAR.PersonNum - 1 do
						if match_ID(WAR.Person[wid]["人物编号"], v[2]) and WAR.Person[wid]["死亡"] == false then
							agi_gain = agi_gain + v[3] 
						end
					end
				end
			end
		end

		DrawString(x1, y1, p["攻击力"], C_CYGOLD, size*0.7)		
		DrawString(x1+w1+size/3, y1, "↑ ", C_CYGOLD, size*0.7)
		DrawString(x1+w1*2, y1, str_gain, C_CYGOLD, size*0.7)		

		DrawString(x1, y1+dh, p["防御力"], C_CYGOLD, size*0.7)		
		DrawString(x1+w1+size/3, y1+dh, "↑ " , C_CYGOLD, size*0.7)
		DrawString(x1+w1*2, y1+dh, def_gain, C_CYGOLD, size*0.7)	
		
         DrawString(x1, y1+dh*2, p["轻功"], C_CYGOLD, size*0.7)		
		if agi_gain > -1 then
			DrawString(x1+w1+size/3,y1+dh*2, "↑ ", C_CYGOLD, size*0.7)
			DrawString(x1+w1*2,y1+dh*2, agi_gain, C_CYGOLD, size*0.7)			
		else
			agi_gain = -(agi_gain)
			DrawString(x1+w1+size/3,y1+dh*2, "↓ " , C_CYGOLD, size*0.7)
			DrawString(x1+w1*2,y1+dh*2, agi_gain, C_CYGOLD, size*0.7)			
		end

		--能力属性
		DrawString(dx*113, y1+dh*3.5, p["拳掌功夫"], C_CYGOLD, size*0.7)
		DrawAttrib("拳掌功夫", dx*150, y1+dh*3.5,C_CYGOLD,size*0.7)
		DrawString(dx*113, y1+dh*4.5, p["指法技巧"], C_CYGOLD, size*0.7)	
		DrawAttrib("指法技巧", dx*150, y1+dh*4.5,C_CYGOLD,size*0.7)
		DrawString(dx*113, y1+dh*5.5, p["御剑能力"], C_CYGOLD, size*0.7)	
		DrawAttrib("御剑能力", dx*150, y1+dh*5.5,C_CYGOLD,size*0.7)
		DrawString(dx*113, y1+dh*6.5, p["耍刀技巧"], C_CYGOLD, size*0.7)	
		DrawAttrib("耍刀技巧", dx*150, y1+dh*6.5,C_CYGOLD,size*0.7)
		DrawString(dx*113, y1+dh*7.5, p["特殊兵器"], C_CYGOLD, size*0.7)	
		DrawAttrib("特殊兵器", dx*150, y1+dh*7.5,C_CYGOLD,size*0.7)

    --第二列  
        -- 医疗 用毒 暗器 
	    local x2 = dx*270
		local y2 = y1
        DrawString(x2, y2,p["医疗能力"], C_CYGOLD, size*0.7)
		DrawAttrib("医疗能力", dx*310, y2,C_CYGOLD,size*0.7)
        DrawString(x2, y2+dh,p["用毒能力"], C_CYGOLD, size*0.7)	
		DrawAttrib("用毒能力", dx*310, y2+dh,C_CYGOLD,size*0.7)
        DrawString(x2, y2+dh*2,p["暗器技巧"], C_CYGOLD, size*0.7)		   

	   --连击 暴击 医疗 用毒    
		DrawString(x2, y2+dh*3.5,Person_LJ(id), C_CYGOLD, size*0.7)
		DrawString(x2, y2+dh*4.5,Person_BJ(id), C_CYGOLD, size*0.7)
		DrawString(x2, y2+dh*5.5,p["抗毒能力"], C_CYGOLD, size*0.7)	
		DrawString(x2, y2+dh*6.5,p["攻击带毒"], C_CYGOLD, size*0.7)	
		DrawString(x2, y2+dh*7.5,p["解毒能力"], C_CYGOLD, size*0.7)	

    --第三列
	--武常 实战 集气
	    local jqz = 0
	local jqz0 = 8
	local jqz1 = 0
	local jqz3 = 0
	local x = JY.Person[id]["轻功"]
	local jqz2 = 0
    local y = JY.Person[id]["内力"]	
	local x3 = dx*427
	local y3 = y1
	DrawString(x3 , y3,p["武学常识"], C_CYGOLD, size*0.7)
     if p["实战"] == 500 then
			DrawString(x3, y3+dh, string.format("%s", "极"), C_RED, size*0.7)
		else
			DrawString(x3, y3+dh, string.format("%s", p["实战"]), C_CYGOLD, size*0.7)
		end	
	--集气条
	
	local function getnewmove(x)
		return math.sqrt(x)
	end
	--无酒不欢：内力对于人物集气的影响函数
	local function getnewmove1(a, b)
		local x = (a * 2 + b) / 3
		if x > 5600 then
			return 8 + math.min((x - 5600) / 1200, 3)
		elseif x > 3600 then
			return 6 + (x - 3600) / 1000
		elseif x > 2000 then
			return 4 + (x - 2000) / 800
		elseif x > 800 then
			return 2 + (x - 800) / 600
		else
			return x / 400
		end
	end

	--战场轻功
	local function Qg1(i)

		id = i
		
		local qg = 0 
		
		qg = qg + JY.Person[id]['轻功']
		
		for i =1,JY.Base["武功数量"] do  
			local level = 0            
			if JY.Person[id]["武功" .. i]==108 then
				level = math.modf(JY.Person[id]["武功等级" .. i]/100)+1;
				level = limitX(level/10,0,1)
				qg = qg + math.modf(JY.Person[id]["轻功"]*0.3*level)	
				break
			end
		end
		
		return qg
	end
	
	jqz = (getnewmove(Qg1(id)) + getnewmove1(JY.Person[id]["内力"], JY.Person[id]["内力最大值"]) + JY.Person[id]["体力"] / 30)
	
	jqz = math.modf(jqz)
	
	DrawString(x3 , y3+dh*2,jqz, C_CYGOLD, size*0.7)	
 
	local zyhb = nil
	if p["左右互搏"] == 1 then
		zyhb  = "◎"
		else
		zyhb  = "※"
		end
	DrawString(x3 , y3+dh*3.5, zyhb, C_CYGOLD, size*0.7)
      local zyzd = nil	
	if id == 0 and ZhongYongZD(id) then
		zyzd  = "◎"
		else
		zyzd  = "※"
		end		
	DrawString(x3,y3+dh*4.5, zyzd, C_CYGOLD, size*0.7)
     local mrdz = nil	
	if MuRongDZ(id) == true  then
		mrdz  = "◎"
		else
		mrdz  = "※"
		end		
	DrawString(x3,y3+dh*5.5, mrdz, C_CYGOLD, size*0.7)
	
	
	
	DrawString(dx*360 , dy*616, "修炼", C_CYGOLD, size*0.7)
	local thingid = p["修炼物品"]
		if thingid > 0 then
			--lib.PicLoadCache(2, p["修炼物品"] * 2, x1 + size*4, y1*19+96-100, 1)
            DrawString(dx*400,dy*616, JY.Thing[thingid]["名称"], M_DeepSkyBlue, size*0.7)			
			i = i + 1
			local n = TrainNeedExp(id)
			if n < math.huge then
				DrawString(dx*360, dy*638, string.format("%5d/%5d", p["修炼点数"], n), C_CYGOLD, size*0.7)
			else
				DrawString(dx*360,  dy*638, string.format("%5d/===", p["修炼点数"]), C_CYGOLD, size*0.7)
			end
		else


	  --经验值
	  i = i + 1
		DrawString(x1-130, y1 + 12*h * (i)-40, "升级", C_CYGOLD, size*0.8)
		local kk = nil
		if p["等级"] >= 30 then
			kk = "   ="
		else
			p["等级"] = limitX(p["等级"],1,30)
			kk = 2 * (p["经验"] - CC.Exp[p["等级"] - 1])
			if kk < 0 then
				kk = "  0"
			elseif kk < 10 then
				kk = "   " .. kk
			elseif kk < 100 then
				kk = "  " .. kk
			elseif kk < 1000 then
				kk = " " .. kk
			end
		end		
		
		--等级
	--	DrawString(dx*189, dy*390, kk, C_CYGOLD, size*0.8)
	--	local tmp = nil
	--	if CC.Level <= p["等级"] then
	--		tmp = "="
	--	else
	--		tmp = 2 * (CC.Exp[p["等级"]] - CC.Exp[p["等级"] - 1])
	--	end
	--	DrawString(dx*209, dy*390, "/" .. tmp, C_CYGOLD, size*0.8)
	end
---------------------------------------------------------------
		--第四列开始 武功
		x1 = dx*2 - size*2-30
		y1 = size*2+30
		i = 0
		local T = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "极"}
	    local SortingNum = {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15"} 	
		for j = 1, 15 do
			i = i + 1
			local wugong = p["武功" .. j]
			if wugong > 0 then
				lib.LoadPNG(91, 18 * 2 ,dx*500, dy*90 + h * (i), 1)
				DrawString(dx*505, dy*95 + h * (i), SortingNum[j], C_WHITE, CC.FontSMALL)
				local level = math.modf(p["武功等级" .. j] / 100) + 1
				if p["武功等级" .. j] == 999 then
					level = 11
				end
				DrawString(dx*540, dy*93 + h * (i), string.format("%s", JY.Wugong[wugong]["名称"]), M_Orange, size*0.9)
				if p["武功等级" .. j] > 900 then
					--lib.SetClip(x1, y1 + h * 1, x1 + size + string.len(JY.Wugong[wugong]["名称"]) * size * (p["武功等级" .. j] - 900) / 200, y1 + h * (i) + h*0.8)
					DrawString(dx*540, dy*93 + h * (i), string.format("%s", JY.Wugong[wugong]["名称"]), M_Orange, size*0.9)
					lib.SetClip(0, 0, 0, 0)
				end
				--等级
				DrawString(dx*775, dy*93 + h * (i), T[level], C_CYGOLD, size*0.9)
				--耗内
				local nl = nil
		        nl = math.modf((level + 3) / 2) * JY.Wugong[wugong]["消耗内力点数"]
				DrawString(dx*695, dy*93 + h * (i), nl, C_CYGOLD, size*0.9)
				--如果是特技，显示特技
				if secondary_wugong(wugong) then
					DrawString(dx*825, dy*93 + h * (i), "特技", M_PaleGreen, size*0.9)
				--如果不是，则显示武功威力
				else
					--威力
					local wugongwl = get_skill_power(id, wugong, level)
					--区别天赋内外功的颜色
					if Given_WG(id, wugong) or Given_NG(id, wugong) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), PinkRed, size*0.9)
					--五岳剑法组合颜色
					elseif wugong >= 30 and wugong <= 34 and WuyueJF(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)
					--琴棋书画组合颜色
					elseif (wugong == 73 or wugong == 72 or wugong == 84 or wugong == 142) and QinqiSH(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)
					--桃花绝技组合颜色
					elseif (wugong == 12 or wugong == 18 or wugong == 38) and TaohuaJJ(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)
					--紫气天罗组合颜色
			       elseif (wugong == 3 or wugong == 120 or wugong == 5 or wugong == 21 or wugong == 118) and ZiqiTL(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)
					--举火燎原组合颜色
					elseif (wugong == 61 or wugong == 65 or wugong == 66) and JuHuoLY(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)
					--利刃寒锋组合颜色
					elseif (wugong == 58 or wugong == 174 or wugong == 153) and LiRenHF(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)
					--金刚般若组合颜色
			        elseif (wugong == 22 or wugong == 189 or wugong == 103) and JinGangBR(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)						
					--世尊降魔组合颜色
					elseif (wugong == 96 or wugong == 86 or wugong == 82 or wugong == 83 ) and ShiZunXM(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)
					--双剑合壁的组合颜色
					elseif (wugong == 39 or wugong == 42 or wugong == 100 or wugong == 154 or wugong == 139) and ShuangJianHB(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)							
					else
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), RGB(208, 152, 208), size*0.9)
					end
				end
			end
		end
		i = 17
		if p["天赋内功"] ~= 0 then

			DrawString(dx*620, dy*76+ h * 17, JY.Wugong[p["天赋内功"]]["名称"], TG_Red_Bright, size*0.8)
		end
		if p["天赋轻功"] ~= 0 then

			DrawString(dx*786,dy*76+ h * 17, JY.Wugong[p["天赋轻功"]]["名称"], M_DeepSkyBlue,  size*0.8)
			i = i + 1
		end
		if p["天赋外功1"] ~= 0 then
			DrawString(dx*619, dy*72 + h * 18, JY.Wugong[p["天赋外功1"]]["名称"], C_GOLD,  size*0.8)
		end
		if p["天赋外功2"] ~= 0 then
			--DrawString(x1, y1 + h * (i), "天赋外功", LightPurple, size)
			DrawString(dx*778, dy*72 + h * 18, JY.Wugong[p["天赋外功2"]]["名称"], C_GOLD,  size*0.8)
		end
		
		x1 = dx - size *3 -10
		i = 20
		if case == nil then
			if JY.Status ~= GAME_WMAP then
				DrawString(x1-size*5, y1 + h * (i)+2, "上下键换人 →键显示人物天赋 ESC退出", M_PaleTurquoise, size*0.7)
			else
				DrawString(x1-size*5, y1 + h * (i)+2, "上下键换人 →键显示人物天赋 ESC退出", Snow3, size*0.7)
			end
		else
			DrawString(x1-size*5, y1 + h * (i)+2, "上下键选择属性 左右键减少/增加 回车键确认加点", Snow3, size*0.7)
		end
	--动画显示
		if dl then
			lib.PicLoadCache(101+p["头像代号"],(dl+AniFrame)*2,diyx/5+ax*2,diyy/4+ax*5+130) 	
		end
-------------------------------------
--属性显示 顾	
		x1 = dx-450
		y1 = size*2+360
		i = 3
        size = CC.FontSmall4*0.7

-------------------------------------
	--第二页
	elseif page == 2 then
		local y2 = y1
		lib.LoadPNG(91, 19 * 2 , 0 , 0, 1)
        local tfsm = {}
        if TFJS[tfid] ~= nil then
            for i = 1,#TFJS[tfid] do
                tfsm[#tfsm+1] = TFJS[tfid][i]
                if i == #TFJS[tfid] then 
                    tfsm[#tfsm+1] = "Ｎ"
                end
            end
        end
        
        if id == 0 then
            for i = 1, #ZJZSJS do
                tfsm[#tfsm+1] = ZJZSJS[i]
                if i == #ZJZSJS then 
                    tfsm[#tfsm+1] = "Ｎ"
                end
            end
        end
        if id == 0 then
            for i,v in pairs(CC.TG) do 
                if v == 1 then
                    tfsm[#tfsm+1] = 'Ｄ'..CC.PTFSM[i][1]
                    tfsm[#tfsm+1] = 'Ｗ'..CC.PTFSM[i][2]
                    tfsm[#tfsm+1] = "Ｎ"
                end
            end   
        end
		--上下翻的箭头显示
		if istart > 1 then
			DrawString(x1-size*2-5, y1+2*h, "↑", C_CYGOLD, size)
		end
		if istart < max_row then
			DrawString(x1-size*2-5, y1+17*h+12, "↓", C_CYGOLD, size)
		end
		local function strcolor_switch(s)
			local Color_Switch={{"Ｒ",PinkRed},{"Ｇ",C_GOLD},{"Ｂ",C_BLACK},{"Ｗ",C_WHITE},{"Ｏ",C_ORANGE},{"Ｌ",LimeGreen},{"Ｄ",M_DeepSkyBlue},{"Ｚ",Violet}}
			for i = 1, 8 do
				if Color_Switch[i][1] == s then
					return Color_Switch[i][2]
				end
			end
		end
		x1 = x1 - size
		DrawString(x1+size*14+20, y1-13, p["姓名"], C_CYGOLD, size)
		DrawString(x1+size*6, y1+size+2, "上下键浏览 ←键返回状态页面 →键进入AI设定 ESC退出", C_CYGOLD, size*0.6)
		local row = 1
        
        y2 = y2 +size*2
        
        if #tfsm > 0 then 
            for i = istart, #tfsm do
				local tfstr = tfsm[i]
				--控制显示行数
				if row < 19 then
					if string.sub(tfstr,1,2) == "Ｎ" then
						row = row + 1
					else
                        local ed = 19-row
						local color;
						color = strcolor_switch(string.sub(tfstr,1,2))
						tfstr = string.sub(tfstr,3,-1)
						local n = tjm(x1+20, y2 + (h-2) * (row), tfstr, color, size*0.9,32,(h-2),0,ed)
                        --if n == 2 then
                        --    say(tfstr,0)
                       --end
						row = row + n
					end
				end
            end
        end
        

		x1 = dx - size *6 -10
		y1 = size*3
		i = 19
		
	--AI设定页面
	elseif page == 3  then
		lib.LoadPNG(91, 21 * 2 , 0 , 0, 1)
		
		local wg_color1 = C_WHITE
		local wg_color2 = C_ORANGE
		if JY.Status == GAME_WMAP then
			wg_color1 = M_DimGray
			wg_color2 = M_DimGray
		end
		
		x1 = size*2 + 10
		i = 0
		DrawString(x1+size*13+7+20, y1-13, p["姓名"], C_CYGOLD, size)

		y1 = y1 + h * 3
		local AI_s1_name = {"行为模式","优先使用","主运内功","主运轻功","是否吃药","生命阈值","内力阈值","体力阈值","禁用AI"}
		for j = 1, 9 do
			local color = LimeGreen
			if AI_s1 == j then
				color = C_GOLD
				DrawString(x1-size-2+10, y1 + h * (j-1)*2, "☆", color, size*0.9)
			end
			if JY.Status == GAME_WMAP and (j == 3 or j == 4) then
				color = M_DimGray
			end
			DrawString(x1+10, y1 + h * (j-1)*2, AI_s1_name[j], color, size*0.9)
		end
		local AI_1_s2_name = {"自动攻击","自动防御","原地休息","逃离休息"}
		for j = 1, 4 do
			local color = C_WHITE
			if AI_s2[1] == j then
				color = C_ORANGE
			end
			DrawString(x1+h*5*j, y1 + h * (i), AI_1_s2_name[j], color, size*0.9)
		end
		i = i + 2
		if p["优先使用"] == 0 then
			DrawString(x1+h*5, y1 + h * (i), "未设定", C_WHITE, size*0.9)
		else
			DrawString(x1+h*5, y1 + h * (i), JY.Wugong[p["优先使用"]]["名称"], C_ORANGE, size*0.9)
		end
		i = i + 2
		if p["主运内功"] == 0 then
			DrawString(x1+h*5, y1 + h * (i), "未运内功", wg_color1, size*0.9)	    
		else		
			DrawString(x1+h*5, y1 + h * (i), JY.Wugong[p["主运内功"]]["名称"], wg_color2, size*0.9)	

         end		
         i = i + 2
		if p["主运轻功"] == 0 then
			DrawString(x1+h*5, y1 + h * (i), "未运轻功", wg_color1, size*0.9)
		else
			DrawString(x1+h*5, y1 + h * (i), JY.Wugong[p["主运轻功"]]["名称"], wg_color2, size*0.9)
		end
		i = i + 2
		local AI_5_s2_name = {"是","否"}
		for j = 1, 2 do
			local color = C_WHITE
			if AI_s2[5] == j then
				color = C_ORANGE
			end
			DrawString(x1+h*5*j, y1 + h * (i), AI_5_s2_name[j], color, size*0.9)
		end
		i = i + 2
		local AI_6_s2_name = {"70%","50%","30%"}
		for j = 1, 3 do
			local color = C_WHITE
			if AI_s2[6] == j then
				color = C_ORANGE
			end
			DrawString(x1+h*5*j, y1 + h * (i), AI_6_s2_name[j], color, size*0.9)
		end
		i = i + 2
		local AI_7_s2_name = {"70%","50%","30%"}
		for j = 1, 3 do
			local color = C_WHITE
			if AI_s2[7] == j then
				color = C_ORANGE
			end
			DrawString(x1+h*5*j, y1 + h * (i), AI_7_s2_name[j], color, size*0.9)
		end
		i = i + 2
		local AI_8_s2_name = {"50","30","10"}
		for j = 1, 3 do
			local color = C_WHITE
			if AI_s2[8] == j then
				color = C_ORANGE
			end
			DrawString(x1+h*5*j, y1 + h * (i), AI_8_s2_name[j], color, size*0.9)
		end
		i = i + 2
		local AI_9_s2_name = {"是","否"}
		for j = 1, 2 do
			local color = C_WHITE
			if AI_s2[9] == j then
				color = C_ORANGE
			end
			DrawString(x1+h*5*j, y1 + h * (i), AI_9_s2_name[j], color, size*0.9)
		end
		
		if AI_menu_selected == 1 or AI_menu_selected > 4 then
			DrawString(x1+h*5*(AI_s2[AI_menu_selected])-h, y1 + h * (AI_menu_selected-1)*2+2, "→", C_ORANGE, size*0.99)
		end
		
		if AI_menu_selected > 1 and AI_menu_selected < 5 then
			DrawString(x1+h*4, y1 + h * (AI_menu_selected-1)*2+2, "←", C_ORANGE, size*0.99)
			DrawString(x1+h*9+12, y1 + h * (AI_menu_selected-1)*2+2, "→", C_ORANGE, size*0.9)
		end

		x1 = dx - size *5 -15
		y1 = size*2
		i = 19
		if AI_menu_selected > 0 then
			x1 = dx - 15
			DrawString(dx*211,dy*59, "左右键选择 回车/ESC键确认", C_CYGOLD, size*0.6)
		else
			DrawString(dx*211,dy*59, "上下键选择 回车键确认 ←键返回天赋页面 ESC退出", C_CYGOLD, size*0.6)
		end
	end
end

--计算人物修炼成功需要的点数
--id 人物id
function TrainNeedExp(id)         --计算人物修炼物品成功需要的点数
    local thingid=JY.Person[id]["修炼物品"];
	local r =0;
	if thingid >= 0 then
        if JY.Thing[thingid]["练出武功"] >=0 then
            local level=0;          --此处的level是实际level-1。这样没有武功時和炼成一级是一样的。
			for i =1,JY.Base["武功数量"] do               -- 查找当前已经炼成武功等级
			    if JY.Person[id]["武功" .. i]==JY.Thing[thingid]["练出武功"] then
                    level=math.modf(JY.Person[id]["武功等级" .. i] /100);
					break;
                end
            end
			if level <9 then
                r=math.modf((5-math.modf(JY.Person[id]["资质"]/25))*JY.Thing[thingid]["需经验"]*(level+1)*0.5);
			else
                r=math.huge;
			end
		else
            r=(5-math.modf(JY.Person[id]["资质"]/25))*JY.Thing[thingid]["需经验"];
		end
	end
    return r;
end

--医疗菜单
function Menu_Doctor()       --医疗菜单
	Cls()
    DrawStrBox(CC.MainSubMenuX,CC.MainSubMenuY,"谁要使用医术",C_WHITE,CC.DefaultFont);
	local nexty=CC.MainSubMenuY+CC.SingleLineHeight;
    DrawStrBox(CC.MainSubMenuX,nexty,"医疗能力",C_ORANGE,CC.DefaultFont);

	local menu1={};
	for i=1,CC.TeamNum do
        menu1[i]={"",nil,0};
		local id=JY.Base["队伍" .. i]
        if id >=0 then
            if JY.Person[id]["医疗能力"]>=20 then
                 menu1[i][1]=string.format("%-10s%4d",JY.Person[id]["姓名"],JY.Person[id]["医疗能力"]);
                 menu1[i][3]=1;
            end
        end
	end

    local id1,id2;
	nexty=nexty+CC.SingleLineHeight;
    local r=ShowMenu(menu1,CC.TeamNum,0,CC.MainSubMenuX,nexty,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);

    if r >0 then
	    id1=JY.Base["队伍" .. r];
        Cls(CC.MainSubMenuX,CC.MainSubMenuY,CC.ScreenW,CC.ScreenH);
        DrawStrBox(CC.MainSubMenuX,CC.MainSubMenuY,"要医治谁",C_WHITE,CC.DefaultFont);
        nexty=CC.MainSubMenuY+CC.SingleLineHeight;

		local menu2={};
		for i=1,CC.TeamNum do
			menu2[i]={"",nil,0};
			local id=JY.Base["队伍" .. i]
			if id>=0 then
				 menu2[i][1]=string.format("%-10s%4d/%4d",JY.Person[id]["姓名"],JY.Person[id]["生命"],JY.Person[id]["生命最大值"]);
				 menu2[i][3]=1;
			end
		end

		local r2=ShowMenu(menu2,CC.TeamNum,0,CC.MainSubMenuX,nexty,0,0,1,1,CC.DefaultFont,C_ORANGE,C_WHITE);

		if r2 >0 then
	        id2=JY.Base["队伍" .. r2];
            local num=ExecDoctor(id1,id2);
			if num>0 then
                AddPersonAttrib(id1,"体力",-2);
			end
            DrawStrBoxWaitKey(string.format("%s 生命增加 %d",JY.Person[id2]["姓名"],num),C_ORANGE,CC.DefaultFont);
		end
	end

	Cls();
    return 0;
end

--解毒
function Menu_DecPoison()         --解毒
    DrawStrBox(CC.MainSubMenuX,CC.MainSubMenuY,"谁要帮人解毒",C_WHITE,CC.DefaultFont);
	local nexty=CC.MainSubMenuY+CC.SingleLineHeight;
    DrawStrBox(CC.MainSubMenuX,nexty,"解毒能力",C_ORANGE,CC.DefaultFont);

	local menu1={};
	for i=1,CC.TeamNum do
        menu1[i]={"",nil,0};
		local id=JY.Base["队伍" .. i]
        if id>=0 then
            if JY.Person[id]["解毒能力"]>=20 then
                 menu1[i][1]=string.format("%-10s%4d",JY.Person[id]["姓名"],JY.Person[id]["解毒能力"]);
                 menu1[i][3]=1;
            end
        end
	end

    local id1,id2;
 	nexty=nexty+CC.SingleLineHeight;
    local r=ShowMenu(menu1,CC.TeamNum,0,CC.MainSubMenuX,nexty,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);

    if r >0 then
	    id1=JY.Base["队伍" .. r];
         Cls(CC.MainSubMenuX,CC.MainSubMenuY,CC.ScreenW,CC.ScreenH);
        DrawStrBox(CC.MainSubMenuX,CC.MainSubMenuY,"替谁解毒",C_WHITE,CC.DefaultFont);
		nexty=CC.MainSubMenuY+CC.SingleLineHeight;

        DrawStrBox(CC.MainSubMenuX,nexty,"中毒程度",C_WHITE,CC.DefaultFont);
	    nexty=nexty+CC.SingleLineHeight;

		local menu2={};
		for i=1,CC.TeamNum do
			menu2[i]={"",nil,0};
			local id=JY.Base["队伍" .. i]
			if id>=0 then
				 menu2[i][1]=string.format("%-10s%5d",JY.Person[id]["姓名"],JY.Person[id]["中毒程度"]);
				 menu2[i][3]=1;
			end
		end

		local r2=ShowMenu(menu2,CC.TeamNum,0,CC.MainSubMenuX,nexty,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);
		if r2 >0 then
	        id2=JY.Base["队伍" .. r2];
            local num=ExecDecPoison(id1,id2);
            DrawStrBoxWaitKey(string.format("%s 中毒程度减少 %d",JY.Person[id2]["姓名"],num),C_ORANGE,CC.DefaultFont);
		end
	end
    Cls();
    ShowScreen();
    return 0;
end

--解毒
--id1 解毒id2, 返回id2中毒减少点数
function ExecDecPoison(id1,id2)     --执行解毒
    local add=JY.Person[id1]["解毒能力"];
    local value=JY.Person[id2]["中毒程度"];

    if value > add+20 then
        return 0;
	end

 	add=limitX(math.modf(add/3)+Rnd(10)-Rnd(10),0,value);
    return -AddPersonAttrib(id2,"中毒程度",-add);
end


--显示物品菜单
function SelectThing(thing,thingnum)    

	local xnum=CC.MenuThingXnum;
	local ynum=CC.MenuThingYnum;

	local w=CC.ThingPicWidth*xnum+(xnum-1)*CC.ThingGapIn+2*CC.ThingGapOut;  --总体宽度
	local h=CC.ThingPicHeight*ynum+(ynum-1)*CC.ThingGapIn+2*CC.ThingGapOut; --物品栏高度

	local dx=(CC.ScreenW-w)/2;
	local dy=(CC.ScreenH-h-2*(CC.ThingFontSize+2*CC.MenuBorderPixel+8))/2-CC.ThingFontSize-11;

	local y1_1,y1_2,y2_1,y2_2,y3_1,y3_2;                  --名称，说明和图片的Y坐标

	local cur_line=0;
	local cur_x=0;
	local cur_y=0;
	local cur_thing=-1;
	
	--无酒不欢：记录最初的物品
	local original_thing = {}
	local original_thingnum = {}
	if IsViewingKungfuScrolls == 1 then
		original_thing = thing
		original_thingnum = thingnum
	end
	
	while true do
		if JY.Restart == 1 then
			break
		end
		Cls();
		y1_1=dy;
		y1_2=y1_1+CC.ThingFontSize+2*CC.MenuBorderPixel;
		y2_1=y1_2+5
		y2_2=y2_1+CC.ThingFontSize+2*CC.MenuBorderPixel
		y3_1=y2_2+5;
		y3_2=y3_1+h;
		lib.LoadPNG(91, 9 * 2 , 0 , 0, 1)
		for y=0,ynum-1 do
			for x=0,xnum-1 do
				local id=y*xnum+x+xnum*cur_line
				local boxcolor;
				--选中物品颜色
				if x==cur_x and y==cur_y then
					boxcolor=S_Yellow;
					if thing[id]>=0 then
						cur_thing=thing[id];
						local str=JY.Thing[thing[id]]["名称"];
						--装备等级显示
						if JY.Thing[thing[id]]["装备类型"] > -1 then
							str = str .." LV."..JY.Thing[thing[id]]["装备等级"]
						end
						if JY.Thing[thing[id]]["类型"]==1 or JY.Thing[thing[id]]["类型"]==2 then
							if JY.Thing[thing[id]]["使用人"] >=0 then
								str=str .. "(" .. JY.Person[JY.Thing[thing[id]]["使用人"]]["姓名"] .. ")";
							end
						end
						if thing[id] == 174 then 
							str=string.format("%s X %d",str,CC.Gold);
						else
						    str=string.format("%s X %d",str,thingnum[id]);
						end
						local str2=JY.Thing[thing[id]]["物品说明"];
						if thing[id]==182 then
							str2=str2..string.format('(人%3d,%3d)',JY.Base['人X'],JY.Base['人Y'])
						end
						DrawString(dx+CC.ThingGapOut+20,y1_1+CC.MenuBorderPixel+10,str,C_GOLD,CC.ThingFontSize);
						DrawString(dx+CC.ThingGapOut+20,y2_1+CC.MenuBorderPixel+10,str2,C_ORANGE,CC.ThingFontSize*0.9);
						local myfont=CC.FontSmall
						local mx, my = dx + 4 * myfont, y3_2 + 2
						local myflag=0
						local myThing=JY.Thing[thing[id]]
								
						--物品说明显示
						local function drawitem(ss,str,news)
							local color = C_GOLD
							local mys
							if str==nil then
								mys=ss
							elseif myThing[ss]~=0 then
								if news==nil then
									if myflag==0 then
										--无酒不欢：装备的数值随等级变化
										if myThing["装备类型"] > -1 then
											local attr_gain = 0;
											if myThing[ss] > 0 then
												attr_gain = myThing[ss]*10 + myThing[ss]*(myThing["装备等级"]-1)*2
											elseif myThing[ss] < 0 then
												attr_gain = myThing[ss]*10 - myThing[ss]*(myThing["装备等级"]-1)*2
											end
											if attr_gain ~= 0 then
												mys=string.format(str..':%+d',attr_gain)
											end
										else
											mys=string.format(str..':%+d',myThing[ss])
										end
									elseif myflag==1 then
										mys=string.format(str..':%d',myThing[ss])
									end
								else
									if myThing[ss]<0 then
										return
									end
									mys=string.format(str..':%s',news[myThing[ss]])
								end
								--内属颜色
								if myThing[ss]==1 and ss=="需内力性质" then
									color = RGB(236, 200, 40)
								elseif myThing[ss]==2 and ss=="需内力性质" then
									color = RGB(236, 236, 236)
								end
							elseif myThing[ss]==0 and ss=="需内力性质" then
								mys=string.format(str..':%s',news[myThing[ss]])
								color = RGB(208, 152, 208)
							else
								return
							end
							
							if mys ~= nil then
								local mylen = myfont * string.len(mys) / 2 + 12
								if CC.ScreenW - dx < mx + mylen then
									my = my + myfont + 10
									mx = dx + 4 * myfont
								end
								DrawString(mx+CC.MenuBorderPixel,my+CC.MenuBorderPixel,mys,color,myfont)
								mx=mx+mylen
							end
						end
					  
						--苍天泰坦：同样是老二
						if myThing["练出武功"] > 0 then
							local kfname = "习得:" .. JY.Wugong[myThing["练出武功"]]["名称"]
							DrawString(mx+CC.MenuBorderPixel, my+CC.MenuBorderPixel, kfname, C_GOLD, myfont)
							mx = mx + myfont * string.len(kfname) / 2 + 12
						end
								
						if myThing['类型'] > 0 then
							drawitem('加生命','生命')
							drawitem('加生命最大值','生命最值')
							drawitem('加中毒解毒','中毒')
							drawitem('加体力','体力')
							if myThing['改变内力性质']==2 then
								drawitem('内力属性变为调和')
							end
							drawitem('加内力','内力')
							drawitem('加内力最大值','内力最值')
							drawitem('加攻击力','攻击')
							drawitem('加轻功','轻功')
							drawitem('加防御力','防御')
							drawitem('加医疗能力','医疗')
							drawitem('加用毒能力','用毒')
							drawitem('加解毒能力','解毒')
							drawitem('加抗毒能力','抗毒')
							drawitem('加拳掌功夫','拳掌')
							drawitem('加指法技巧','指法')
							drawitem('加御剑能力','御剑')
							drawitem('加耍刀技巧','耍刀')
							drawitem('加特殊兵器','特殊')
							drawitem('加暗器技巧','暗器')
							drawitem('加武学常识','武常')
							drawitem('加品德','品德')
							drawitem('加攻击次数','左右',{[0]='否','是'})
							drawitem('加攻击带毒','带毒')
							if myThing['未知7']==1 then
                                drawitem('增加人物体质')
							end
                            if thing[id] == 372 then 
                                drawitem('领悟中庸之道')
                            end
							--武器装备威力加成
							for i,v in ipairs(CC.ExtraOffense) do
								if v[1] == thing[id] then
									DrawString(mx+CC.MenuBorderPixel+20,my+CC.MenuBorderPixel,"威力强化:"..JY.Wugong[v[2]]["名称"].."+"..v[3],PinkRed,myfont)
								end
							end
							
							if mx~=dx or my~=y3_2+2 then
								if thing[id] > 343 or thing[id] < 348 then	--特殊药品不显示
									DrawString(dx+CC.MenuBorderPixel+20, y3_2 + 2+CC.MenuBorderPixel, " 效果:", LimeGreen, myfont)
								end
															
							end
						end
						
						--装备类和秘籍类
						if myThing['类型']==1 or myThing['类型']==2 then
							if mx~=dx then
								mx=dx+4*myfont
								my=my+myfont+3
							end
							myflag=1
							local my2=my
							if myThing['仅修炼人物']>-1 then
								drawitem('仅限:'..JY.Person[myThing['仅修炼人物']]['姓名'])
							end
							drawitem('需内力性质','内属',{[0]='阴','阳','不限'})
							drawitem('需内力','内力')
							drawitem('需攻击力','攻击')
							drawitem('需轻功','轻功')
							drawitem('需用毒能力','用毒')
							drawitem('需医疗能力','医疗')
							drawitem('需解毒能力','解毒')
							drawitem('需拳掌功夫','拳掌')
							drawitem('需指法技巧','指法')
							drawitem('需御剑能力','御剑')
							drawitem('需耍刀技巧','耍刀')
							drawitem('需特殊兵器','特殊')
							drawitem('需暗器技巧','暗器')
                            if thing[id] == 372 then 
                                drawitem('需80>资质>30')
                            end
							--斗转的显示
							if thing[id] == 118 then
								local exstr = "五系兵器值之和>=120 "
								local mylen = myfont * string.len(exstr) / 2 + 12
								DrawString(mx+CC.MenuBorderPixel+20,my+CC.MenuBorderPixel,exstr,C_GOLD,myfont)
								mx=mx+mylen
							end
							--阴阳的显示
							if thing[id] == 176 then
								local exstr = "御剑/耍刀/特殊任一项>=70 "
								local mylen = myfont * string.len(exstr) / 2 + 12
								DrawString(mx+CC.MenuBorderPixel+20,my+CC.MenuBorderPixel,exstr,C_GOLD,myfont)
								mx=mx+mylen
							end
							--金丝手套的显示
							if thing[id] == 239 then
								local exstr = "拳掌或指法>=70 "
								local mylen = myfont * string.len(exstr) / 2 + 12
								DrawString(mx+CC.MenuBorderPixel+20,my+CC.MenuBorderPixel,exstr,C_GOLD,myfont)
								mx=mx+mylen
							end
							--七宝指环的显示
							if thing[id] == 200 then
								local exstr = "拳掌或指法>=200 "
								local mylen = myfont * string.len(exstr) / 2 + 12
								DrawString(mx+CC.MenuBorderPixel+20,my+CC.MenuBorderPixel,exstr,C_GOLD,myfont)
								mx=mx+mylen
							end							
							drawitem('需资质','资质')
							drawitem('需经验','修炼经验')
							if mx~=dx or my~=my2 then
								DrawString(dx+CC.MenuBorderPixel+20,my2+CC.MenuBorderPixel,' 需求:',LimeGreen,myfont)
							end
						end
						--特效说明
						if WPTX2[thing[id]] ~= nil then
							if mx~=dx then
								mx=dx+4*myfont
								my=my+myfont+3
							end
							local my2=my
							if mx~=dx or my~=my2 then
								DrawString(dx+CC.MenuBorderPixel+20,my2+CC.MenuBorderPixel,' 效果:',C_RED,myfont)
							end

							DrawString(dx+CC.MenuBorderPixel+myfont*3+20,my2+CC.MenuBorderPixel,WPTX2[thing[id]], M_DeepSkyBlue,myfont)
						end
						--特效说明
						if myThing['是否特效'] == 1 and (WPTX[thing[id]][myThing['装备等级']] ~= nil or myThing['装备类型'] == -1) then
							if mx~=dx then
								mx=dx+4*myfont
								my=my+myfont+3
							end
							local my2=my
							if mx~=dx or my~=my2 then
								DrawString(dx+CC.MenuBorderPixel+20,my2+CC.MenuBorderPixel,' 特效:',C_RED,myfont)
							end
							if myThing['装备类型'] > -1 then
								local TXstr = WPTX[thing[id]][myThing['装备等级']]
								--复活戒指的耐久度
								if thing[id] == 303 then
									TXstr = TXstr.."（剩余"..JY.Person[651]["品德"].."次）"
								end
								DrawString(dx+CC.MenuBorderPixel+myfont*3+20,my2+CC.MenuBorderPixel, TXstr, M_DeepSkyBlue,myfont)
							else
								DrawString(dx+CC.MenuBorderPixel+myfont*3+20,my2+CC.MenuBorderPixel, WPTX[thing[id]], M_DeepSkyBlue,myfont)
							end
						end
					else
						cur_thing=-1;
					end
				else
					boxcolor=C_BLACK;
				end
		  
				local boxx = dx + CC.ThingGapOut + x * (CC.ThingPicWidth + CC.ThingGapIn)
				local boxy = y3_1 + CC.ThingGapOut + y * (CC.ThingPicHeight + CC.ThingGapIn)

				if thing[id] >= 0 then
					lib.PicLoadCache(2, thing[id] * 2, boxx + 1, boxy + 1, 1)
				end
				--无酒不欢：修改选择框
				if boxcolor == S_Yellow then
					DrawSingleLine(boxx+2, boxy+1, boxx + CC.ThingPicWidth/4, boxy+1, boxcolor)
					DrawSingleLine(boxx+2+ CC.ThingPicWidth*3/4, boxy+1, boxx + CC.ThingPicWidth, boxy+1, boxcolor)
					DrawSingleLine(boxx+2, boxy+1, boxx+2, boxy + CC.ThingPicHeight/4 - 1, boxcolor)
					DrawSingleLine(boxx + CC.ThingPicWidth-1, boxy+2, boxx + CC.ThingPicWidth-1, boxy + CC.ThingPicHeight/4 - 1, boxcolor)
					DrawSingleLine(boxx+2, boxy+2+CC.ThingPicHeight*3/4, boxx+2, boxy + CC.ThingPicHeight - 1, boxcolor)
					DrawSingleLine(boxx + CC.ThingPicWidth-1, boxy+2+CC.ThingPicHeight*3/4, boxx + CC.ThingPicWidth-1, boxy + CC.ThingPicHeight - 1, boxcolor)
					DrawSingleLine(boxx+1, boxy + CC.ThingPicHeight - 1, boxx + CC.ThingPicWidth/4, boxy + CC.ThingPicHeight - 1, boxcolor)
					DrawSingleLine(boxx+2+ CC.ThingPicWidth*3/4, boxy + CC.ThingPicHeight - 1, boxx + CC.ThingPicWidth-1, boxy + CC.ThingPicHeight - 1, boxcolor)
				end
			end
		end
		
		DrawString(CC.ScreenW-240,CC.ScreenH-CC.Fontsmall-8	, "按F1查看详细说明", C_CYGOLD,CC.Fontsmall)
		DrawString(CC.ScreenW-220, CC.ScreenH-CC.Fontsmall*2-8, "银两:", C_GOLD, CC.Fontsmall)
	    DrawString(CC.ScreenW-220+CC.FontSmall*3, CC.ScreenH-CC.Fontsmall*2-8, CC.Gold, C_CYGOLD, CC.Fontsmall)
		if IsViewingKungfuScrolls > 0 then
			local list = {"1:全部","2:拳法","3:指法","4:剑法","5:刀法","6:奇门","7:内轻","8:杂学"}
			local space = 0
			local h = 0
			for i = 1, 8 do
				local color = C_GOLD
				if i == IsViewingKungfuScrolls then
					color = C_RED
				end
				if i == 5 then
					space = 0
					h = 35
				end
				space = space + 81
				DrawString(CC.ScreenW-405 + space-20 ,20+h, list[i], color,CC.Fontsmall)
			end
		end

		ShowScreen();
  	
		local keypress, ktype, mx, my = WaitKey(1)
		lib.Delay(CC.Frame);
		if keypress==VK_ESCAPE or ktype == 4 then
			cur_thing=-1;
			break;
		elseif keypress==VK_RETURN or keypress==VK_SPACE then
			break;
		--增加物品的内置说明
		elseif keypress==VK_F1 and cur_thing ~= -1 then
			detailed_info(cur_thing)
		--数字1 全部
		elseif IsViewingKungfuScrolls > 0 and keypress==49 then
			thing = original_thing
			thingnum = original_thingnum
			cur_line=0
			cur_x=0
			cur_y=0
			cur_thing=-1
			IsViewingKungfuScrolls = 1
		--数字2 拳法
		elseif IsViewingKungfuScrolls > 0 and keypress==50 then
			local newThing = {}
			local newThingnum = {}
			for i = 0, CC.MyThingNum - 1 do
				newThing[i] = -1
				newThingnum[i] = 0
			end
			local c = -1
			for i = 0, #original_thing do
				if original_thing[i] == -1 then
					break
				end
				local TSkill = JY.Thing[original_thing[i]]["练出武功"]
				if TSkill > -1 and JY.Wugong[TSkill]["武功类型"] == 1 then
					c = c + 1
					newThing[c] = original_thing[i]
					newThingnum[c] = original_thingnum[i]
				end
			end
			thing = newThing
			thingnum = newThingnum
			cur_line=0
			cur_x=0
			cur_y=0
			cur_thing=-1
			IsViewingKungfuScrolls = 2
		--数字3 指法
		elseif IsViewingKungfuScrolls > 0 and keypress==51 then
			local newThing = {}
			local newThingnum = {}
			for i = 0, CC.MyThingNum - 1 do
				newThing[i] = -1
				newThingnum[i] = 0
			end
			local c = -1
			for i = 0, #original_thing do
				if original_thing[i] == -1 then
					break
				end
				local TSkill = JY.Thing[original_thing[i]]["练出武功"]
				if TSkill > -1 and JY.Wugong[TSkill]["武功类型"] == 2 then
					c = c + 1
					newThing[c] = original_thing[i]
					newThingnum[c] = original_thingnum[i]
				end
			end
			thing = newThing
			thingnum = newThingnum
			cur_line=0
			cur_x=0
			cur_y=0
			cur_thing=-1
			IsViewingKungfuScrolls = 3
		--数字4 剑法
		elseif IsViewingKungfuScrolls > 0 and keypress==52 then
			local newThing = {}
			local newThingnum = {}
			for i = 0, CC.MyThingNum - 1 do
				newThing[i] = -1
				newThingnum[i] = 0
			end
			local c = -1
			for i = 0, #original_thing do
				if original_thing[i] == -1 then
					break
				end
				local TSkill = JY.Thing[original_thing[i]]["练出武功"]
				if TSkill > -1 and JY.Wugong[TSkill]["武功类型"] == 3 then
					c = c + 1
					newThing[c] = original_thing[i]
					newThingnum[c] = original_thingnum[i]
				end
			end
			thing = newThing
			thingnum = newThingnum
			cur_line=0
			cur_x=0
			cur_y=0
			cur_thing=-1
			IsViewingKungfuScrolls = 4
		--数字5 刀法
		elseif IsViewingKungfuScrolls > 0 and keypress==53 then
			local newThing = {}
			local newThingnum = {}
			for i = 0, CC.MyThingNum - 1 do
				newThing[i] = -1
				newThingnum[i] = 0
			end
			local c = -1
			for i = 0, #original_thing do
				if original_thing[i] == -1 then
					break
				end
				local TSkill = JY.Thing[original_thing[i]]["练出武功"]
				if TSkill > -1 and JY.Wugong[TSkill]["武功类型"] == 4 then
					c = c + 1
					newThing[c] = original_thing[i]
					newThingnum[c] = original_thingnum[i]
				end
			end
			thing = newThing
			thingnum = newThingnum
			cur_line=0
			cur_x=0
			cur_y=0
			cur_thing=-1
			IsViewingKungfuScrolls = 5
		--数字6 奇门
		elseif IsViewingKungfuScrolls > 0 and keypress==54 then
			local newThing = {}
			local newThingnum = {}
			for i = 0, CC.MyThingNum - 1 do
				newThing[i] = -1
				newThingnum[i] = 0
			end
			local c = -1
			for i = 0, #original_thing do
				if original_thing[i] == -1 then
					break
				end
				local TSkill = JY.Thing[original_thing[i]]["练出武功"]
				if TSkill > -1 and JY.Wugong[TSkill]["武功类型"] == 5 then
					c = c + 1
					newThing[c] = original_thing[i]
					newThingnum[c] = original_thingnum[i]
				end
			end
			thing = newThing
			thingnum = newThingnum
			cur_line=0
			cur_x=0
			cur_y=0
			cur_thing=-1
			IsViewingKungfuScrolls = 6
		--数字7 内轻
		elseif IsViewingKungfuScrolls > 0 and keypress==55 then
			local newThing = {}
			local newThingnum = {}
			for i = 0, CC.MyThingNum - 1 do
				newThing[i] = -1
				newThingnum[i] = 0
			end
			local c = -1
			for i = 0, #original_thing do
				if original_thing[i] == -1 then
					break
				end
				local TSkill = JY.Thing[original_thing[i]]["练出武功"]
				if TSkill > -1 and (JY.Wugong[TSkill]["武功类型"] == 6 or JY.Wugong[TSkill]["武功类型"] == 7) then
					c = c + 1
					newThing[c] = original_thing[i]
					newThingnum[c] = original_thingnum[i]
				end
			end
			thing = newThing
			thingnum = newThingnum
			cur_line=0
			cur_x=0
			cur_y=0
			cur_thing=-1
			IsViewingKungfuScrolls = 7
		--数字8 杂学
		elseif IsViewingKungfuScrolls > 0 and keypress==56 then
			local newThing = {}
			local newThingnum = {}
			for i = 0, CC.MyThingNum - 1 do
				newThing[i] = -1
				newThingnum[i] = 0
			end
			local c = -1
			for i = 0, #original_thing do
				if original_thing[i] == -1 then
					break
				end
				local TSkill = JY.Thing[original_thing[i]]["练出武功"]
				if TSkill == -1 then
					c = c + 1
					newThing[c] = original_thing[i]
					newThingnum[c] = original_thingnum[i]
				end
			end
			thing = newThing
			thingnum = newThingnum
			cur_line=0
			cur_x=0
			cur_y=0
			cur_thing=-1
			IsViewingKungfuScrolls = 8
		elseif keypress==VK_UP or ktype == 6 then
			if  cur_y == 0 then
				if  cur_line > 0 then
					cur_line = cur_line - 1;
				end
			else
				cur_y = cur_y - 1;
			end
		elseif keypress==VK_DOWN or ktype == 7 then
			if  cur_y ==ynum-1 then
				if  cur_line < (math.modf(CC.MyThingNum/xnum)-ynum) then
					cur_line = cur_line + 1;
				end
			else
				cur_y = cur_y + 1;
			end
		elseif keypress==VK_LEFT then
			if  cur_x > 0 then
				cur_x=cur_x-1;
			else
				cur_x=xnum-1;
			end
		elseif keypress==VK_RIGHT then
			if  cur_x ==xnum-1 then
				cur_x=0;
			else
				cur_x=cur_x+1;
			end
		elseif ktype == 2 or ktype == 3 then
			if mx>dx and my>dy and mx<CC.ScreenW-dx and my<CC.ScreenH-dy then
				cur_x=math.modf((mx-dx-CC.ThingGapOut/2)/(CC.ThingPicWidth+CC.ThingGapIn))
				cur_y=math.modf((my-y3_1-CC.ThingGapOut/2)/(CC.ThingPicHeight+CC.ThingGapIn))
				if ktype==3 then
					break
				end
			end
		end
	end

	Cls();
	--无酒不欢：秘笈显示区分
	if IsViewingKungfuScrolls > 0 then
		IsViewingKungfuScrolls = 0
	end
	return cur_thing;
end


--场景处理主函数
function Game_SMap()         --场景处理主函数
	if JY.Restart == 1 then
		return
	end
	
    DrawSMap();	
	--无酒不欢：下方显示
	if CC.ShowXY==1 then
		lib.LoadPNG(91,43*2,CC.ScreenW/936*136,CC.ScreenH/702*142,2)
        DrawString(CC.ScreenW/936*70,CC.ScreenH/702*129,string.format("%s %d %d",JY.Scene[JY.SubScene]["名称"],JY.Base["人X1"],JY.Base["人Y1"]) ,C_GOLD,CC.Fontsmall*0.9);
	end
		
	DrawTimer();
	
	JYZTB();
	--JYZTB1();
    ShowScreen();
    lib.SetClip(0, 0, 0, 0)
  
	local d_pass=GetS(JY.SubScene,JY.Base["人X1"],JY.Base["人Y1"],3);   --当前路过事件
	if d_pass>=0 then
		if d_pass ~=JY.OldDPass then     --避免重复触发
			EventExecute(d_pass,3);       --路过触发事件
			JY.OldDPass=d_pass;
			JY.oldSMapX=-1;
			JY.oldSMapY=-1;
			JY.D_Valid=nil;
		end
		if JY.Status~=GAME_SMAP then
			return ;
		else
		   JY.OldDPass=-1;
		end
	end
	local isout=0;                --是否碰到出口
	if (JY.Scene[JY.SubScene]["出口X1"] ==JY.Base["人X1"] and JY.Scene[JY.SubScene]["出口Y1"] ==JY.Base["人Y1"]) or
		(JY.Scene[JY.SubScene]["出口X2"] ==JY.Base["人X1"] and JY.Scene[JY.SubScene]["出口Y2"] ==JY.Base["人Y1"]) or
		(JY.Scene[JY.SubScene]["出口X3"] ==JY.Base["人X1"] and JY.Scene[JY.SubScene]["出口Y3"] ==JY.Base["人Y1"]) then
		isout=1;
	end
	--出到大地图
	if isout == 1 then
		--无酒不欢：修复马车直接飞进场景后出来会遮挡建筑物的问题
		if JY.Base["人X"] == JY.Scene[JY.SubScene]["外景入口X1"] and JY.Base["人Y"] == JY.Scene[JY.SubScene]["外景入口Y1"] then
			--雪山要单独处理
			if JY.SubScene == 2 then
				JY.Base["人Y"] = JY.Base["人Y"] + 1
			--朱府要单独处理
			elseif JY.SubScene == 92 then
				JY.Base["人X"] = JY.Base["人X"] + 1
			else
				if JY.Base["人方向"] == 0 then
					JY.Base["人Y"] = JY.Base["人Y"] - 1
				elseif JY.Base["人方向"] == 1 then
					JY.Base["人X"] = JY.Base["人X"] + 1
				elseif JY.Base["人方向"] == 2 then
					JY.Base["人X"] = JY.Base["人X"] - 1
				elseif JY.Base["人方向"] == 3 then
					JY.Base["人Y"] = JY.Base["人Y"] + 1
				end
			end
		end
		--明教地道要单独处理
		if JY.SubScene == 13 then
			JY.Base["人X"] = 68
			JY.Base["人Y"] = 397
		end
		--蒙古包要单独处理
		if JY.SubScene == 6 then
			JY.Base["人X"] = 49
			JY.Base["人Y"] = 111
		end
		JY.Status = GAME_MMAP
		--lib.PicInit()
		CleanMemory()
		JY.MmapMusic = JY.Scene[JY.SubScene]["出门音乐"]
		--如果没有设置出门音乐的话
		if JY.MmapMusic < 0 then
			JY.MmapMusic = 0
		end
		Init_MMap()
		JY.SubScene = -1
		JY.oldSMapX = -1
		JY.oldSMapY = -1
		lib.DrawMMap(JY.Base["人X"], JY.Base["人Y"], GetMyPic())
		lib.GetKey()
		lib.ShowSlow(20,0)
		return
	end
    --是否跳转到其他场景
    if JY.Scene[JY.SubScene]["跳转场景"] >= 0 and JY.Base["人X1"] == JY.Scene[JY.SubScene]["跳转口X1"] and JY.Base["人Y1"] == JY.Scene[JY.SubScene]["跳转口Y1"] then
		local OldScene = JY.SubScene
		JY.SubScene = JY.Scene[JY.SubScene]["跳转场景"]
		lib.ShowSlow(20, 1)
		if JY.Scene[OldScene]["外景入口X1"] ~= 0 then
			JY.Base["人X1"] = JY.Scene[JY.SubScene]["入口X"]
			JY.Base["人Y1"] = JY.Scene[JY.SubScene]["入口Y"]
		else
			JY.Base["人X1"] = JY.Scene[JY.SubScene]["跳转口X2"]
			JY.Base["人Y1"] = JY.Scene[JY.SubScene]["跳转口Y2"]
		end
		Init_SMap(1)
		return 
	end

    local x,y;
    local direct = -1;
    local keypress, ktype, mx, my = lib.GetKey();
	--先检测跟上次不同的方向是否被按下
    for i = VK_RIGHT,VK_UP do
        if i ~= CC.PrevKeypress and lib.GetKeyState(i) ~=0 then
			keypress = i
		end
	end 
    --如果与上次不同的方向未被按下，则检测与上次相同的方向是否被按下
	if keypress==-1 and	lib.GetKeyState(CC.PrevKeypress) ~=0 then
		keypress = CC.PrevKeypress
	end
    CC.PrevKeypress = keypress
    if keypress==VK_UP then
		direct=0;
		JY.WalkCount = JY.WalkCount + 1
	elseif keypress==VK_DOWN then
		direct=3;
		JY.WalkCount = JY.WalkCount + 1
	elseif keypress==VK_LEFT then
		direct=2;
		JY.WalkCount = JY.WalkCount + 1
	elseif keypress==VK_RIGHT then
		direct=1;
		JY.WalkCount = JY.WalkCount + 1
	else
		JY.WalkCount = 0
	end
	
	if ktype == 1 then
		JY.Mytick=0;
		if keypress==VK_ESCAPE then
			Cls()
			--MMenu();
			CMenu() 
		elseif keypress==VK_SPACE or keypress==VK_RETURN then       --空格触发事件
			if JY.Base["人方向"]>=0 then
				local d_num=GetS(JY.SubScene,JY.Base["人X1"]+CC.DirectX[JY.Base["人方向"]+1],JY.Base["人Y1"]+CC.DirectY[JY.Base["人方向"]+1],3);
				if d_num>=0 then
					EventExecute(d_num,1);
				end
			end
		--无酒不欢：全套快捷键 7-30
	    elseif keypress == VK_S then	--存档
			Menu_SaveRecord()
	    elseif keypress == VK_L then	--读档
			Menu_ReadRecord()
 
		elseif keypress == VK_Z then	--状态
			Cls()
			Menu_Status()
		elseif keypress == VK_E then	--物品
			Cls()
			Menu_Thing()
		elseif keypress == VK_F3 then	--队友排位
			Cls()
			Menu_TZDY()
		elseif keypress == VK_F4 then	--整理
			Cls()		
			Menu_WPZL()
		end
	elseif ktype == 3 then
		if mx >= 0 and mx <= CC.ScreenW/936*63 and 
		   my >= CC.ScreenH/701*110 and my <= CC.ScreenH/701*160 then
		   CMenu()
		else  
			AutoMoveTab = {[0]=0}
			local x0 = JY.Base["人X1"]
			local y0 = JY.Base["人Y1"]
			
			local px=x0
			local py=y0
			if CONFIG.Zoom == 100 then
				--无酒不欢：修正在地图边界自动寻路错误的问题
				px=limitX(x0,13,46)
				py=limitX(y0,13,46)
			else
				px=x0
				py=y0
			end
		
			mx = mx + (px-py)*CC.XScale - CC.ScreenW/2
			my = my + (px+py)*CC.YScale - CC.ScreenH/2
				
			local xx = (mx/CC.XScale + my/CC.YScale)/2;
			local yy = (my/CC.YScale - mx/CC.XScale)/2;
				
			if xx - math.modf(xx) > 0 then
				xx = math.modf(xx);
			end
				
			if yy - math.modf(yy) > 0 then
				yy = math.modf(yy);
			end	
			
			if CONFIG.Zoom ~= 100 then		--无酒不欢：不知道什么毛病，反正不加就是有毛病
				xx = xx + 1
				yy = yy + 1
			end

			if xx > 0 and xx < CC.SWidth and yy > 0 and yy < CC.SHeight then
				walkto(xx - x0,yy - y0)
			end
		end
	elseif ktype == 4 then
		JY.Mytick=0;
		Cls()
		--MMenu();
		CMenu() 
    end

    if JY.Status~=GAME_SMAP then
        return ;
    end
	
	--无酒不欢：有标记事件坐标，且自动走到前面一格才会触发事件
	if CC.AutoMoveEvent[1] ~= 0 and 
	(JY.Base["人X1"] == CC.AutoMoveEvent[1] or JY.Base["人X1"] - 1 == CC.AutoMoveEvent[1] or JY.Base["人X1"] + 1 == CC.AutoMoveEvent[1]) and 
	(JY.Base["人Y1"] == CC.AutoMoveEvent[2] or JY.Base["人Y1"] - 1 == CC.AutoMoveEvent[2] or JY.Base["人Y1"] + 1 == CC.AutoMoveEvent[2]) then
		CC.AutoMoveEvent[0] = 1			--鼠标操作触发事件
	end
    
    if AutoMoveTab[0] ~= 0 then			--鼠标自动走动
		if direct == -1 then
			direct = AutoMoveTab[AutoMoveTab[0]]
			AutoMoveTab[AutoMoveTab[0]] = nil
			AutoMoveTab[0] = AutoMoveTab[0] - 1
	    end
	else
	    AutoMoveTab = {[0] = 0}
		if CC.AutoMoveEvent[0] == 1 then
			EventExecute(GetS(JY.SubScene,CC.AutoMoveEvent[1],CC.AutoMoveEvent[2],3),1);
			CC.AutoMoveEvent[0] = 0;
			CC.AutoMoveEvent[1] = 0;
			CC.AutoMoveEvent[2] = 0;
		end
	end
	
    if direct ~= -1 then
        AddMyCurrentPic();
        x=JY.Base["人X1"]+CC.DirectX[direct+1];
        y=JY.Base["人Y1"]+CC.DirectY[direct+1];
        JY.Base["人方向"]=direct;
		if JY.WalkCount == 1 then
			lib.Delay(90)
		end
    else
        x=JY.Base["人X1"];
        y=JY.Base["人Y1"];
    end

    JY.MyPic=GetMyPic();
    DtoSMap();
    if SceneCanPass(x,y)==true then          --新的坐标可以走过去
        JY.Base["人X1"]=x;
        JY.Base["人Y1"]=y;
    end

    JY.Base["人X1"]=limitX(JY.Base["人X1"],1,CC.SWidth-2);
    JY.Base["人Y1"]=limitX(JY.Base["人Y1"],1,CC.SHeight-2);
    
	--一些新的事件
	NEvent(keypress)
end

--场景坐标(x,y)是否可以通过
--返回true,可以，false不能
function SceneCanPass(x,y)  --场景坐标(x,y)是否可以通过
    local ispass=true;        --是否可以通过

    if GetS(JY.SubScene,x,y,1)>0 then     --场景层1有物品，不可通过
        ispass=false;
    end

    local d_data=GetS(JY.SubScene,x,y,3);     --事件层4
    if d_data>=0 then
        if GetD(JY.SubScene,d_data,0)~=0 then  --d*数据为不能通过
            ispass=false;
        end
    end

    if CC.SceneWater[GetS(JY.SubScene,x,y,0)] ~= nil then   --水面，不可进入
        ispass=false;
    end
    return ispass;
end

function DtoSMap()          ---D*中的事件数据复制到S*中，同时处理动画效果。
    for i=0,CC.DNum-1 do
        local x=GetD(JY.SubScene,i,9);
        local y=GetD(JY.SubScene,i,10);
        if x>0 and y>0 then
            SetS(JY.SubScene,x,y,3,i);

			local p1=GetD(JY.SubScene,i,5);
			if p1>=0 then
				local p2=GetD(JY.SubScene,i,6);
				local p3=GetD(JY.SubScene,i,7);
				local delay=GetD(JY.SubScene,i,8);
				if p3<=p1 then     --动画已停止
					if JY.Mytick %100 > delay then
						p3=p3+1;
					end
				else
					if JY.Mytick % 4 ==0 then      --4个节拍动画增加一次
						p3=p3+1;
					end
				end
				if p3>p2 then
					 p3=p1;
				end
				SetD(JY.SubScene,i,7,p3);
			end
        end
    end
end


function DrawSMap()         --绘场景地图
	local x0=JY.SubSceneX+JY.Base["人X1"]-1;    --绘图中心点
    local y0=JY.SubSceneY+JY.Base["人Y1"]-1;

    local x=limitX(x0,12,45)-JY.Base["人X1"];
    local y=limitX(y0,12,45)-JY.Base["人Y1"];
	
	if CONFIG.Zoom == 100 then
		lib.DrawSMap(JY.SubScene,JY.Base["人X1"],JY.Base["人Y1"],x,y,JY.MyPic)
	else
		lib.DrawSMap(JY.SubScene,JY.Base["人X1"],JY.Base["人Y1"],JY.SubSceneX,JY.SubSceneY,JY.MyPic)
	end
end


-- 读取游戏进度
-- id=0 新进度，=1/2/3 进度
--这里是先把数据读入Byte数组中。然后定义访问相应表的方法，在访问表时直接从数组访问。
--与以前的实现相比，从文件中读取和保存到文件的时间显著加快。而且内存占用少了
function LoadRecord(id)       -- 读取游戏进度
    local zipfile=string.format('data/save/Save_%d',id)
    
    if id ~= 0 and ( existFile(zipfile) == false) then
		QZXS("此存档数据不全，不能读取。请选择其它存档或重新开始");
		return -1;
	end
    
    Byte.unzip(zipfile, 'r.grp','d.grp','s.grp','tjm')

    local t1=lib.GetTime();

    --读取R*.idx文件
    local data=Byte.create(6*4);
    Byte.loadfile(data,CC.R_IDXFilename[0],0,6*4);

	local idx={};
	idx[0]=0;
	for i =1,6 do
	    idx[i]=Byte.get32(data,4*(i-1));
	end
	
	local grpFile = 'r.grp';
	local sFile = 's.grp';
	local dFile = 'd.grp';
	if id == 0 then
		grpFile = CC.R_GRPFilename[id];
		sFile = CC.S_Filename[id];
		dFile = CC.D_Filename[id];
	end
	
    --读取R*.grp文件
    JY.Data_Base=Byte.create(idx[1]-idx[0]);              --基本数据
    Byte.loadfile(JY.Data_Base,grpFile,idx[0],idx[1]-idx[0]);

    --设置访问基本数据的方法，这样就可以用访问表的方式访问了。而不用把二进制数据转化为表。节约加载时间和空间
	local meta_t={
	    __index=function(t,k)
	        return GetDataFromStruct(JY.Data_Base,0,CC.Base_S,k);
		end,

		__newindex=function(t,k,v)
	        SetDataFromStruct(JY.Data_Base,0,CC.Base_S,k,v);
	 	end
	}
    setmetatable(JY.Base,meta_t);


    JY.PersonNum=math.floor((idx[2]-idx[1])/CC.PersonSize);   --人物

	JY.Data_Person=Byte.create(CC.PersonSize*JY.PersonNum);
	Byte.loadfile(JY.Data_Person,grpFile,idx[1],CC.PersonSize*JY.PersonNum);

	for i=0,JY.PersonNum-1 do
		JY.Person[i]={};
		local meta_t={
			__index=function(t,k)
				return GetDataFromStruct(JY.Data_Person,i*CC.PersonSize,CC.Person_S,k);
			end,

			__newindex=function(t,k,v)
				SetDataFromStruct(JY.Data_Person,i*CC.PersonSize,CC.Person_S,k,v);
			end
		}
        setmetatable(JY.Person[i],meta_t);
	end

    JY.ThingNum=math.floor((idx[3]-idx[2])/CC.ThingSize);     --物品
	JY.Data_Thing=Byte.create(CC.ThingSize*JY.ThingNum);
	Byte.loadfile(JY.Data_Thing,grpFile,idx[2],CC.ThingSize*JY.ThingNum);
	for i=0,JY.ThingNum-1 do
		JY.Thing[i]={};
		local meta_t={
			__index=function(t,k)
				return GetDataFromStruct(JY.Data_Thing,i*CC.ThingSize,CC.Thing_S,k);
			end,

			__newindex=function(t,k,v)
				SetDataFromStruct(JY.Data_Thing,i*CC.ThingSize,CC.Thing_S,k,v);
			end
		}
        setmetatable(JY.Thing[i],meta_t);
	end

    JY.SceneNum=math.floor((idx[4]-idx[3])/CC.SceneSize);     --场景
	JY.Data_Scene=Byte.create(CC.SceneSize*JY.SceneNum);
	Byte.loadfile(JY.Data_Scene,grpFile,idx[3],CC.SceneSize*JY.SceneNum);
	for i=0,JY.SceneNum-1 do
		JY.Scene[i]={};
		local meta_t={
			__index=function(t,k)
				return GetDataFromStruct(JY.Data_Scene,i*CC.SceneSize,CC.Scene_S,k);
			end,

			__newindex=function(t,k,v)
				SetDataFromStruct(JY.Data_Scene,i*CC.SceneSize,CC.Scene_S,k,v);
			end
		}
        setmetatable(JY.Scene[i],meta_t);
	end

    JY.WugongNum=math.floor((idx[5]-idx[4])/CC.WugongSize);     --武功
	JY.Data_Wugong=Byte.create(CC.WugongSize*JY.WugongNum);
	Byte.loadfile(JY.Data_Wugong,grpFile,idx[4],CC.WugongSize*JY.WugongNum);
	for i=0,JY.WugongNum-1 do
		JY.Wugong[i]={};
		local meta_t={
			__index=function(t,k)
				return GetDataFromStruct(JY.Data_Wugong,i*CC.WugongSize,CC.Wugong_S,k);
			end,

			__newindex=function(t,k,v)
				SetDataFromStruct(JY.Data_Wugong,i*CC.WugongSize,CC.Wugong_S,k,v);
			end
		}
        setmetatable(JY.Wugong[i],meta_t);
	end

    JY.ShopNum=math.floor((idx[6]-idx[5])/CC.ShopSize);     --城镇商店
	JY.Data_Shop=Byte.create(CC.ShopSize*JY.ShopNum);
	Byte.loadfile(JY.Data_Shop,grpFile,idx[5],CC.ShopSize*JY.ShopNum);
	for i=0,JY.ShopNum-1 do
		JY.Shop[i]={};
		local meta_t={
			__index=function(t,k)
				return GetDataFromStruct(JY.Data_Shop,i*CC.ShopSize,CC.Shop_S,k);
			end,

			__newindex=function(t,k,v)
				SetDataFromStruct(JY.Data_Shop,i*CC.ShopSize,CC.Shop_S,k,v);
			end
		}
        setmetatable(JY.Shop[i],meta_t);

    end

    lib.LoadSMap(sFile,CC.TempS_Filename,JY.SceneNum,CC.SWidth,CC.SHeight,dFile,CC.DNum,11);
	collectgarbage();

	lib.Debug(string.format("Loadrecord time=%d",lib.GetTime()-t1));
	
	JY.LOADTIME = lib.GetTime()
	
	rest()
	
	if id > 0 then 
	   tjmload(id)
	end
   
	os.remove('r.grp')
	os.remove('d.grp')
	os.remove('s.grp')
	os.remove('tjm');
end


-- 写游戏进度
-- id=0 新进度，=1/2/3 进度
function SaveRecord(id)         -- 写游戏进度

	--判断是否在子场景保存
	if JY.Status == GAME_SMAP then
      JY.Base["无用"] = JY.SubScene
    else
      JY.Base["无用"] = -1
    end
	
    --读取R*.idx文件
    local t1 = lib.GetTime()
	JY.SAVETIME = lib.GetTime()
	JY.GTIME = math.modf((JY.SAVETIME - JY.LOADTIME) / 60000)
	SetS(14, 2, 1, 4, GetS(14, 2, 1, 4) + JY.GTIME)
	JY.LOADTIME = lib.GetTime()

    local data=Byte.create(6*4);
    Byte.loadfile(data,CC.R_IDXFilename[0],0,6*4);

	local idx={};
	idx[0]=0;
	for i =1,6 do
	    idx[i]=Byte.get32(data,4*(i-1));
	end

	--os.remove('r.grp');
    --写R*.grp文件
	Byte.savefile(JY.Data_Base,'r.grp',idx[0],idx[1]-idx[0]);

	Byte.savefile(JY.Data_Person,'r.grp',idx[1],CC.PersonSize*JY.PersonNum);

	Byte.savefile(JY.Data_Thing,'r.grp',idx[2],CC.ThingSize*JY.ThingNum);

	Byte.savefile(JY.Data_Scene,'r.grp',idx[3],CC.SceneSize*JY.SceneNum);

	Byte.savefile(JY.Data_Wugong,'r.grp',idx[4],CC.WugongSize*JY.WugongNum);

	Byte.savefile(JY.Data_Shop,'r.grp',idx[5],CC.ShopSize*JY.ShopNum);

    lib.SaveSMap('s.grp','d.grp');
	
    tjmsave(id)
	
    local zipfile=string.format('data/save/Save_%d',id)
    Byte.zip(zipfile, 'r.grp','d.grp','s.grp','tjm')
    os.remove('r.grp')
    os.remove('d.grp')
    os.remove('s.grp')
	os.remove('tjm');
    lib.Debug(string.format("SaveRecord time=%d",lib.GetTime()-t1));
end

-------------------------------------------------------------------------------------
-----------------------------------通用函数-------------------------------------------

function filelength(filename)         --得到文件长度
    local inp=io.open(filename,"rb");
    local l= inp:seek("end");
	inp:close();
    return l;
end

--读S×数据, (x,y) 坐标，level 层 0-5
function GetS(id,x,y,level)       --读S×数据
	return lib.GetS(id,x,y,level);
end

--写S×
function SetS(id,x,y,level,v)       --写S×
	lib.SetS(id,x,y,level,v);
end

--读D*
--sceneid 场景编号，
--id D*编号
--要读第几个数据, 0-10
function GetD(Sceneid,id,i)          --读D*
    return lib.GetD(Sceneid,id,i);
end

--写D×
function SetD(Sceneid,id,i,v)         --写D×
	lib.SetD(Sceneid,id,i,v);
end

--从数据的结构中翻译数据
--data 二进制数组
--offset data中的偏移
--t_struct 数据的结构，在jyconst中有很多定义
--key  访问的key
function GetDataFromStruct(data,offset,t_struct,key)  --从数据的结构中翻译数据，用来取数据
    local t=t_struct[key];
	local r;
	if t[2]==0 then
		r=Byte.get16(data,t[1]+offset);
	elseif t[2]==1 then
		r=Byte.getu16(data,t[1]+offset);
	elseif t[2]==2 then
		if CC.SrcCharSet==0 then
			r=lib.CharSet(Byte.getstr(data,t[1]+offset,t[3]),0);
		else
			r=Byte.getstr(data,t[1]+offset,t[3]);
		end
	end
	return r;
end

function SetDataFromStruct(data,offset,t_struct,key,v)  --从数据的结构中翻译数据，保存数据
    local t=t_struct[key];
	if t[2]==0 then
		Byte.set16(data,t[1]+offset,v);
	elseif t[2]==1 then
		Byte.setu16(data,t[1]+offset,v);
	elseif t[2]==2 then
		local s;
		if CC.SrcCharSet==0 then
			s=lib.CharSet(v,1);
		else
			s=v;
		end
		Byte.setstr(data,t[1]+offset,t[3],s);
	end
end

--按照t_struct 定义的结构把数据从data二进制串中读到表t中
function LoadData(t,t_struct,data)        --data二进制串中读到表t中
    for k,v in pairs(t_struct) do
        if v[2]==0 then
            t[k]=Byte.get16(data,v[1]);
        elseif v[2]==1 then
            t[k]=Byte.getu16(data,v[1]);
		elseif v[2]==2 then
            if CC.SrcCharSet==0 then
                t[k]=lib.CharSet(Byte.getstr(data,v[1],v[3]),0);
		    else
		        t[k]=Byte.getstr(data,v[1],v[3]);
		    end
		end
	end
end

--按照t_struct 定义的结构把数据写入data Byte数组中。
function SaveData(t,t_struct,data)      --数据写入data Byte数组中。
    for k,v in pairs(t_struct) do
        if v[2]==0 then
            Byte.set16(data,v[1],t[k]);
		elseif v[2]==1 then
            Byte.setu16(data,v[1],t[k]);
		elseif v[2]==2 then
		    local s;
			if CC.SrcCharSet==0 then
			    s=lib.CharSet(t[k],1);
            else
			    s=t[k];
		    end
            Byte.setstr(data,v[1],v[3],s);
		end
	end
end

--限制x的范围
function limitX(x,minv,maxv)
	if x<minv then
	    x=minv;
	end
	if maxv ~= nil and x>maxv then
	    x=maxv;
	end
	return x
end

function RGB(r,g,b)          --设置颜色RGB
	return r*65536+g*256+b;
end

function GetRGB(color)      --分离颜色的RGB分量
    color=color%(65536*256);
    local r=math.floor(color/65536);
    color=color%65536;
    local g=math.floor(color/256);
    local b=color%256;
    return r,g,b
end

--等待键盘输入
function WaitKey(flag)
	--ktype  1：键盘，2：鼠标移动，3:鼠标左键，4：鼠标右键，5：鼠标中键，6：滚动上，7：滚动下
	local key, ktype, mx, my=-1,-1,-1,-1;
	while true do
		if JY.Restart == 1 then
			break
		end
		key, ktype, mx, my=lib.GetKey();
		if ktype == nil then
			ktype, mx, my=-1,-1,-1;
		end
		if ktype ~=-1 or key ~= -1 then
			if (flag == nil or flag == 0) and ktype ~= 2 then
				break;
			elseif flag ~= nil and flag ~= 0 then
				break;
			end
		end
		lib.Delay(CC.Frame/2);
	end
	return key, ktype, mx, my;
end

--绘制一个带背景的白色方框，四角凹进
function DrawBox(x1, y1, x2, y2, color)
	local s = 4
	lib.Background(x1 + 4, y1, x2 - 4, y1 + s, 88)
	lib.Background(x1 + 1, y1 + 1, x1 + s, y1 + s, 88)
	lib.Background(x2 - s, y1 + 1, x2 - 1, y1 + s, 88)
	lib.Background(x1, y1 + 4, x2, y2 - 4, 88)
	lib.Background(x1 + 1, y2 - s, x1 + s, y2 - 1, 88)
	lib.Background(x2 - s, y2 - s, x2 - 1, y2 - 1, 88)
	lib.Background(x1 + 4, y2 - s, x2 - 4, y2, 88)
	local r, g, b = GetRGB(color)
	DrawBox_1(x1 + 1, y1 + 1, x2, y2, RGB(math.modf(r / 2), math.modf(g / 2), math.modf(b / 2)))
	DrawBox_1(x1, y1, x2 - 1, y2 - 1, color)
end

--绘制一个带背景的白色方框，四角凹进
function DrawBox_1(x1, y1, x2, y2, color)
	local s = 4
	lib.DrawRect(x1 + s, y1, x2 - s, y1, color)
	lib.DrawRect(x1 + s, y2, x2 - s, y2, color)
	lib.DrawRect(x1, y1 + s, x1, y2 - s, color)
	lib.DrawRect(x2, y1 + s, x2, y2 - s, color)
	lib.DrawRect(x1 + 2, y1 + 1, x1 + s - 1, y1 + 1, color)
	lib.DrawRect(x1 + 1, y1 + 2, x1 + 1, y1 + s - 1, color)
	lib.DrawRect(x2 - s + 1, y1 + 1, x2 - 2, y1 + 1, color)
	lib.DrawRect(x2 - 1, y1 + 2, x2 - 1, y1 + s - 1, color)
	lib.DrawRect(x1 + 2, y2 - 1, x1 + s - 1, y2 - 1, color)
	lib.DrawRect(x1 + 1, y2 - s + 1, x1 + 1, y2 - 2, color)
	lib.DrawRect(x2 - s + 1, y2 - 1, x2 - 2, y2 - 1, color)
	lib.DrawRect(x2 - 1, y2 - s + 1, x2 - 1, y2 - 2, color)
end

--显示阴影字符串
function DrawString(x,y,str,color,size)         --显示阴影字符串
	if x==-1 then
		local ll=#str;
		local w=size*ll/2+2*CC.MenuBorderPixel;
		x=(CC.ScreenW-size/2*ll-2*CC.MenuBorderPixel)/2;
	end
	if y == -1 then
		y = (CC.ScreenH - size - 2 * CC.MenuBorderPixel) / 2
	end
    lib.DrawStr(x,y,str,color,size,CC.FontName,CC.SrcCharSet,CC.OSCharSet);
end

--显示带框的字符串
--(x,y) 坐标，如果都为-1,则在屏幕中间显示
function DrawStrBox(x,y,str,color,size,boxcolor)         --显示带框的字符串
    local ll=#str;
    local w=size*ll/2+2*CC.MenuBorderPixel;
	local h=size+2*CC.MenuBorderPixel;
	if boxcolor == nil then
		boxcolor = C_WHITE
	end
	if x==-1 then
        x=(CC.ScreenW-size/2*ll-2*CC.MenuBorderPixel)/2;
	end
	if y==-1 then
        y=(CC.ScreenH-size-2*CC.MenuBorderPixel)/2;
	end
    
   DrawBox(x,y,x+w-1,y+h-1,boxcolor);
    DrawString(x+CC.MenuBorderPixel,y+CC.MenuBorderPixel,str,color,size);
end

--无酒不欢：增加对颜色转换的支持
function DrawStrBox3(x, y, s, color, size, flag)         --显示带框的字符串
    local ll=#s -flag*2;
    local w=size*ll/2+2*CC.MenuBorderPixel;
	local h=size+2*CC.MenuBorderPixel;
	local function strcolor_switch(s)
		local Color_Switch={{"Ｒ",C_RED},{"Ｇ",C_GOLD},{"Ｂ",C_BLACK},{"Ｗ",C_WHITE},{"Ｏ",C_ORANGE}}
		local Numbers = {{"1",10},{"2",15},{"3",15},{"4",15},{"5",15},{"6",15},{"7",15},{"8",15},{"9",15},{"0",15}}
		for i = 1, 5 do
			if Color_Switch[i][1] == s then
				return 1, Color_Switch[i][2]
			end
		end
		for i = 1, 10 do
			if Numbers[i][1] == s then
				return 2, Numbers[i][2]
			end
		end
		return 0
	end
	
	if x==-1 then
        x=(CC.ScreenW-size/2*ll-2*CC.MenuBorderPixel)/2;
	end
	if y==-1 then
        y=(CC.ScreenH-size-2*CC.MenuBorderPixel)/2;
	end
	
	--无酒不欢：方框颜色 7-31
    DrawBox(x,y,x+w-1,y+h-1,LimeGreen);
	local space = 0;
	while string.len(s) >= 1 do
		local str
		str=string.sub(s,1,1)
		if string.byte(s,1,1) > 127 then		--判断单双字符
			str=string.sub(s,1,2)
			s=string.sub(s,3,-1)
		else
			str=string.sub(s,1,1)
			s=string.sub(s,2,-1)
		end
		local cs,cs2 = strcolor_switch(str)
		if cs == 1 then
			color = cs2
		elseif cs == 2 then
			DrawString(x+CC.MenuBorderPixel+space,y+CC.MenuBorderPixel,str,color,size);
			space = space + cs2;
		else
			DrawString(x+CC.MenuBorderPixel+space,y+CC.MenuBorderPixel,str,color,size);
			space = space + size;
		end
	end
end

--显示并询问Y/N，如果点击Y，则返回true, N则返回false
--(x,y) 坐标，如果都为-1,则在屏幕中间显示
--改为用菜单询问是否
function DrawStrBoxYesNo(x, y, str, color, size, boxcolor)
	if JY.Restart == 1 then
		return
	end
	lib.GetKey()
	local ll = #str
	local w = size * ll / 2 + 2 * CC.MenuBorderPixel
	local h = size + 2 * CC.MenuBorderPixel
	if x == -1 then
		x = (CC.ScreenW - size / 2 * ll - 2 * CC.MenuBorderPixel) / 2
	end
	if y == -1 then
		y = (CC.ScreenH - size - 2 * CC.MenuBorderPixel) / 2
	end
	Cls();
	DrawStrBox(x, y, str, color, size, boxcolor)
	local menu = {
	{"确定/是", nil, 1}, 
	{"取消/否", nil, 2}}
	local r = ShowMenu(menu, 2, 0, x + w - 4 * size - 2 * CC.MenuBorderPixel, y + h + CC.MenuBorderPixel, 0, 0, 1, 0, CC.DefaultFont, C_ORANGE, C_WHITE)
	if r == 1 then
		return true
	else
		return false
	end
end

--显示字符串并等待击键，字符串带框，显示在屏幕中间
function DrawStrBoxWaitKey(s,color,size,flag,boxcolor)
	if JY.Restart == 1 then
		return
	end
    lib.GetKey();
    Cls();
	--无酒不欢：分开多种
	if flag == nil then
		if boxcolor == nil then
			DrawStrBox(-1,-1,s,color,size);
		else
			DrawStrBox(-1,-1,s,color,size,boxcolor);
		end
	else
		DrawStrBox3(-1,-1,s,color,size,flag);
	end
    ShowScreen();
    WaitKey();
end

--返回 [0 , i-1] 的整形随机数
function Rnd(i)           --随机数
    local r=math.random(i);
    return r-1;
end

--增加人物属性，如果有最大值限制，则应用最大值限制。最小值则限制为0
--id 人物id
--str属性字符串
--value 要增加的值，负数表示减少
--返回1,实际增加的值
--返回2，字符串：xxx 增加/减少 xxxx，用于显示药品效果
function AddPersonAttrib(id, str, value)
	local oldvalue = JY.Person[id][str]
	local attribmax = math.huge
	if str == "生命" then
		attribmax = JY.Person[id]["生命最大值"]
	elseif str == "内力" then
		attribmax = JY.Person[id]["内力最大值"]
	elseif CC.PersonAttribMax[str] ~= nil then
		attribmax = CC.PersonAttribMax[str]
	end
	
	--瑜伽密乘减少受伤最大值
	if str == "受伤程度" then
		if PersonKF(id, 169) then
			attribmax = 50
		end
		
	end
	
	if str == "内力最大值" then
		local p_zz = JY.Person[id]["资质"];
        local zz = 100 - JY.Person[id]["资质"]
		if isteam(id) then
            attribmax = 1500
            attribmax = attribmax + zz*40
            --[[
            if p_zz <= 15 then
			   attribmax = 5499
            elseif p_zz >= 16 and p_zz <= 30 then
			   attribmax = 5000
            elseif p_zz >= 31 and p_zz <= 45 then
			   attribmax = 4500
            elseif p_zz >= 46 and p_zz <= 50 then
			   attribmax = 4000
            elseif p_zz >= 51 and p_zz <= 60 then
			   attribmax = 3300
            elseif p_zz >= 61 and p_zz <= 75 then
			   attribmax = 2700
            elseif p_zz >= 76 and p_zz <= 90 then
			   attribmax = 2100
            elseif p_zz >= 91 then
			   attribmax = 1500
            end
            ]]
            --attribmax = 6000+ (101 - JY.Person[id]["资质"])*400
        else
            attribmax = JY.Person[id]["内力最大值"]    
        end
		--段誉，扫地，石破天，无崖子 ，斗酒僧
		if match_ID(id, 53) or match_ID(id, 114) or match_ID(id, 38) or match_ID(id, 116)  or match_ID(id, 638) or match_ID(id, 499) or match_ID(id, 9999) then
			attribmax = 9999
		end
	
		--学一个内功开发1500内力上限
		if Num_of_Neigong(id) == 1 then
			attribmax = attribmax + 1500

			
		--学两个内功开发3000内力上限
		elseif Num_of_Neigong(id) == 2 then
			attribmax = attribmax + 3000
		
		--学两个以上内功开发4500内力上限
		elseif Num_of_Neigong(id) > 2 then
			attribmax = attribmax + 4500

		end
		--学有北冥或吸星，+300
		for i = 1, JY.Base["武功数量"] do
			if JY.Person[id]["武功" .. i] == 85 or JY.Person[id]["武功" .. i] == 88 then
				attribmax = attribmax + 300
				break
			end
		end
		--杨过吼过的内力
		if match_ID(id, 58) then
			attribmax = attribmax - JY.Person[300]["声望"] * 1000
		end
		--内力下限2999，上限9999
		if attribmax < 2999 then
			attribmax = 2999
		end
		if attribmax > 10000 then
			attribmax = 10000
		end
end	
    
	--程灵素，何铁手，王难姑，用毒500
	if str == "用毒能力" and (match_ID(id, 2) or match_ID(id, 83) or match_ID(id, 17)) then
		attribmax = 600
	end
	--蓝凤凰，用毒400
	if str == "用毒能力" and match_ID(id, 25) then
		attribmax = 500
	end
	--胡青牛，平一指，薛慕华医疗500
	if str == "医疗能力" and (match_ID(id, 16) or match_ID(id, 28) or match_ID(id, 45)) then
		attribmax = 600
	end
	--贝海石，程灵素医疗400
	if str == "医疗能力" and (match_ID(id, 85) or match_ID(id, 2)) then
		attribmax = 500
	end
	--标主医生，医疗用毒解毒都是400
	if (str == "医疗能力" or str == "用毒能力" or str == "解毒能力") and id == 0 and JY.Base["标准"] == 8 then
		attribmax = 500
	end
	--标主毒王，用毒解毒都是500
	if (str == "用毒能力" or str == "解毒能力") and id == 0 and JY.Base["标准"] == 9 then
		attribmax = 600
	end
	--阎基，医疗用毒都是300
	if (str == "医疗能力" or str == "用毒能力") and match_ID(id, 4) then
		attribmax = 400
	end
	--李寻欢，暗器技巧都是500
	if str == "暗器技巧" and match_ID(id, 498) then
		attribmax = 400
	end	
	--陈家洛觉醒后兵器值无上限
	if match_ID(id, 75) and JY.Person[0]["六如觉醒"] > 0 and (str == "拳掌功夫" or str == "指法技巧" or str == "御剑能力" or str == "耍刀技巧" or str == "特殊兵器") then
		attribmax = 9999
	end	
	local newvalue = limitX(oldvalue + value, 0, attribmax)
	JY.Person[id][str] = newvalue
	local add = newvalue - oldvalue
	local showstr = ""
	if add > 0 then
		showstr = string.format("%s 增加 %d", str, add)
	elseif add < 0 then
		showstr = string.format("%s 减少 %d", str, -add)
	end
	return add, showstr
end

--播放midi
function PlayMIDI(id)             --播放midi
    JY.CurrentMIDI=id;
    if JY.EnableMusic==0 then
        return ;
    end
    if id>=0 then
        lib.PlayMIDI(string.format(CC.MIDIFile,id+1));
    end
end

--播放音效atk***
function PlayWavAtk(id)             --播放音效atk***
    if JY.EnableSound==0 then
        return ;
    end
    if id>=0 then
        lib.PlayWAV(string.format(CC.ATKFile,id));
    end
end

--播放音效e**
function PlayWavE(id)              --播放音效e**
    if JY.EnableSound==0 then
        return ;
    end
    if id>=0 then
        lib.PlayWAV(string.format(CC.EFile,id));
    end
end

--flag =0 or nil 全部刷新屏幕
--1 考虑脏矩形的快速刷新
function ShowScreen(flag)
	if JY.Darkness == 0 then
		if flag == nil then
			flag = 0
		end
		lib.ShowSurface(flag)
	end
end

--通用菜单函数
-- menuItem 表，每项保存一个子表，内容为一个菜单项的定义
--          菜单项定义为  {   ItemName,     菜单项名称字符串
--                          ItemFunction, 菜单调用函数，如果没有则为nil
--                          Visible       是否可见  0 不可见 1 可见, 2 可见，作为当前选择项。只能有一个为2，
--                                        多了则只取第一个为2的，没有则第一个菜单项为当前选择项。
--                                        在只显示部分菜单的情况下此值无效。
--                                        此值目前只用于是否菜单缺省显示否的情况
--                       }
--          菜单调用函数说明：         itemfunction(newmenu,id)
--
--       返回值
--              0 正常返回，继续菜单循环 1 调用函数要求退出菜单，不进行菜单循环
--
-- numItem      总菜单项个数
-- numShow      显示菜单项目，如果总菜单项很多，一屏显示不下，则可以定义此值
--                =0表示显示全部菜单项

-- (x1,y1),(x2,y2)  菜单区域的左上角和右下角坐标，如果x2,y2=0,则根据字符串长度和显示菜单项自动计算x2,y2
-- isBox        是否绘制边框，0 不绘制，1 绘制。若绘制，则按照(x1,y1,x2,y2)的矩形绘制白色方框，并使方框内背景变暗
-- isEsc        Esc键是否起作用 0 不起作用，1起作用
-- Size         菜单项字体大小
-- color        正常菜单项颜色，均为RGB
-- selectColor  选中菜单项颜色,
--;
-- 返回值  0 Esc返回
--         >0 选中的菜单项(1表示第一项)
--         <0 选中的菜单项，调用函数要求退出父菜单，这个用于退出多层菜单

function ShowMenu(menuItem, numItem, numShow, x1, y1, x2, y2, isBox, isEsc, size, color, selectColor)
	local w = 0
	local h = 0
	local i = 0
	local num = 0
	local newNumItem = 0
	lib.GetKey()
	local newMenu = {}
	for i = 1, numItem do
		if menuItem[i][3] > 0 then
			newNumItem = newNumItem + 1
			newMenu[newNumItem] = {menuItem[i][1], menuItem[i][2], menuItem[i][3], i}
		end
	end
	if newNumItem == 0 then
		return 0
	end
	if numShow == 0 or newNumItem < numShow then
		num = newNumItem
	else
		num = numShow
	end
	local maxlength = 0
	if x2 == 0 and y2 == 0 then
		for i = 1, newNumItem do
		  if maxlength < string.len(newMenu[i][1]) then
			maxlength = string.len(newMenu[i][1])
		  end
		end
		w = size * maxlength / 2 + 2 * CC.MenuBorderPixel
		h = (size + CC.RowPixel) * num + CC.MenuBorderPixel
	else
		w = x2 - x1
		h = y2 - y1
	end
	local start = 1
	local current = 1
	for i = 1, newNumItem do
		if newMenu[i][3] == 2 then
		  current = i
		end
	end
	if numShow ~= 0 then
		current = 1
	end
	--无酒不欢：战斗快捷键时机判定
	local In_Battle = false;
	if JY.Status == GAME_WMAP and numItem >= 8 and menuItem[8][1] == "自动" then
		In_Battle = true
	end
	--无酒不欢：战术菜单判定
	local In_Tactics = false;
	if JY.Status == GAME_WMAP and numItem >= 3 and menuItem[3][1] == "等待" then
		In_Tactics = true
	end
	--其它菜单判定
	local In_Other = false;
	if JY.Status == GAME_WMAP and numItem >= 5 and menuItem[3][1] == "医疗" then
		In_Other = true
	end	
	--修改战斗菜单宽度以便显示快捷键
	if In_Battle == true or In_Tactics == true  or In_Other == true then
		w = w + 15
	end
	local surid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)
	local returnValue = 0
	if isBox == 1 then
		DrawBox(x1, y1, x1 + (w), y1 + (h), C_WHITE)
	end
  
  
  while true do
	lib.GetKey()
	if JY.Restart == 1 then
		break
	end
    if num ~= 0 then
		ClsN();
		lib.LoadSur(surid, 0, 0)
	    if isBox == 1 then
	      DrawBox(x1, y1, x1 + (w), y1 + (h), C_WHITE)
	    end
  	end
	  for i = start, start + num - 1 do
	    local drawColor = color
	    if i == current then
			drawColor = selectColor
			lib.Background(x1 + CC.MenuBorderPixel, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel), x1 - CC.MenuBorderPixel + (w), y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) + size, 128, color)
	    end
	    DrawString(x1 + CC.MenuBorderPixel, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel), newMenu[i][1], drawColor, size)
		--快捷键提示显示
		if In_Battle == true then
			if newMenu[i][1] == "攻击" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "A", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "运功" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "G", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "战术" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "S", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "其它" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "H", LimeGreen, CC.FontSmall)
			elseif newMenu[i][2] == War_TgrtsMenu then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "T", LimeGreen, CC.FontSmall)
			end
		end
		if In_Tactics == true then
			if newMenu[i][1] == "蓄力" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "P", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "防御" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "D", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "等待" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "W", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "集中" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "J", LimeGreen, CC.FontSmall)
		    elseif newMenu[i][1] == "休息" then
			DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "R", LimeGreen, CC.FontSmall)			
			end
		end 
		if In_Other == true then
		if newMenu[i][1] == "用毒" then
			DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "V", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "解毒" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "Q", LimeGreen, CC.FontSmall)
		    elseif newMenu[i][1] == "医疗" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "F", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "物品" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "E", LimeGreen, CC.FontSmall)
		    elseif newMenu[i][1] == "状态" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "Z", LimeGreen, CC.FontSmall)	
			end
		end
	  end
		ShowScreen()

		local keyPress, ktype, mx, my = WaitKey(1)
		lib.Delay(CC.Frame)
	  
		if keyPress==VK_ESCAPE or ktype == 4 then
			--Esc 或 退出
			if isEsc==1 then
				break
				--return 0
			end
		elseif keyPress==VK_DOWN or ktype == 7 then                --Down
			current = current +1;
			if current > (start + num-1) then
				start=start+1;
			end
			if current > newNumItem then
				start=1;
				current =1;
			end
		elseif keyPress==VK_UP or ktype == 6 then                  --Up
			current = current -1;
			if current < start then
				start=start-1;
			end
			if current < 1 then
				current = newNumItem;
				start =current-num+1;
			end
		elseif keyPress == VK_RIGHT then
			current = current + 10
			if start + num - 1 < current then
				start = start + 10
			end
			if newNumItem < current +start then                --Alungky 修复看攻略时会跳出的BUG
				current = newNumItem
				start = current - num + 1
			end
		elseif keyPress == VK_LEFT then
			current = current - 10
			if current < start then
				start = start - 10
			end
			if current < 1 then
				start = 1
				current = 1
			elseif current < num then                --Alungky 修复看攻略时会跳出的BUG
				start = 1
			end
		--无酒不欢：战斗快捷键
		--攻击
		elseif In_Battle == true and keyPress == VK_A and menuItem[2][3] == 1 then
			local r=War_FightMenu();
			if r==1 then
			returnValue= -2;
			break;
			end
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--1-9直接攻击
		elseif In_Battle == true and (keyPress >= 49 and keyPress <= 57) and menuItem[2][3] == 1 then
			local r=War_FightMenu(nil, nil, keyPress-48);
			if r==1 then
			returnValue= -2;
			break;
			end
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--运功
		elseif In_Battle == true and keyPress == VK_G then
			local r=War_YunGongMenu();
			if r==20 then
				returnValue= 20;
				break;
			elseif r==10 then
				returnValue= 10;
				break;
			end
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--战术
		elseif In_Battle == true and keyPress == VK_S then
			local r=War_TacticsMenu();
			if r==1 then
				returnValue= -4;
				break;
			elseif r == 20 then
				returnValue= 20;
				break;
			end
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--其它
		elseif In_Battle == true and keyPress == VK_H then
			local r=War_OtherMenu();
			if r==1 then
				returnValue= -4;
				break;
			elseif r == 20 then
				returnValue= 20;
				break;
			end
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end			
		--用毒
		elseif (In_Battle == true or In_Other == true) and keyPress == VK_V and menuItem[5][3] == 1 then
			local r=War_PoisonMenu();
			if r==1 then
			returnValue= -5;
			break;
			end
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--解毒
		elseif (In_Battle == true or In_Other == true) and keyPress == VK_Q and menuItem[5][3] == 1 then
			local r=War_DecPoisonMenu();
			if r==1 then
			returnValue= -6;
			break;
			end
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--医疗
		elseif (In_Battle == true or In_Other == true) and keyPress == VK_F and menuItem[5][3] == 1 then
			local r=War_DoctorMenu();
			if r==1 then
			returnValue= -7;
			break;
			end
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--物品
		elseif (In_Battle == true or In_Other == true) and keyPress == VK_E and menuItem[5][3] == 1 then
			local r=War_ThingMenu();
			if r==1 then
			returnValue= -8;
			break;
			end
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--状态
		elseif (In_Battle == true or In_Other == true) and keyPress == VK_Z then
			local r=War_StatusMenu();
			if r==1 then
			returnValue= -9;
			break;
			end
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--休息
		elseif (In_Battle == true or In_Tactics == true) and keyPress == VK_R then
			local r=War_RestMenu();
			if r==1 then
			returnValue= -10;
			break;
			end
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--特色指令
		elseif In_Battle == true and keyPress == VK_T and menuItem[6][3] == 1 then
			local r=War_TgrtsMenu();
			if r==1 then
				returnValue= -11;
				break;
			elseif r==20 then
				returnValue= 20
				break;
			end
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--C查看
		elseif In_Battle == true and keyPress == VK_C then
			local r=MapWatch();
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--蓄力
		elseif (In_Battle == true or In_Tactics == true) and keyPress == VK_P then
			local r=War_ActupMenu();
			if In_Battle == true then
				returnValue = -4;
			else	
				returnValue = 5;
			end
			break;
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--防御
		elseif (In_Battle == true or In_Tactics == true) and keyPress == VK_D then
			local r=War_DefupMenu();
			if In_Battle == true then
				returnValue = -4;
			else
				returnValue = 5;
			end
			break;
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--等待
		elseif (In_Battle == true or In_Tactics == true) and keyPress == VK_W then
			local r=War_Wait();
			if In_Battle == true then
				returnValue = -4;
			else
				returnValue = 5;
			end
			break;
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--集中
		elseif (In_Battle == true or In_Tactics == true) and keyPress == VK_J then
			War_Focus()
			if In_Battle == true then
				returnValue = 20;
			else
				returnValue = 6;
			end
			break;
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		else
			local mk = false;
			if ktype == 2 or ktype == 3 then			--选中
				if mx >= x1 and mx <= x1 + w and my >= y1 and my <= y1 + h then
					current = start + math.modf((my - y1 - CC.MenuBorderPixel) / (size + CC.RowPixel))
					mk = true;
				end
			end
			--选中确认
			if  keyPress==VK_SPACE or keyPress==VK_RETURN or ktype == 5 or (ktype == 3 and mk) then
				if newMenu[current][2]==nil then
					returnValue=newMenu[current][4];
					break;
				elseif newMenu[current][2] == SelectNeiGongMenu then
					local id = WAR.Person[WAR.CurID]["人物编号"]
					--运功内力不足
					if JY.Person[id]["内力"] < 2000 then
						DrawStrBoxWaitKey("内力不足，无法运功",C_RED,CC.DefaultFont,nil,LimeGreen)
					--运功体力不足
					elseif JY.Person[id]["体力"] < 20 then
						DrawStrBoxWaitKey("体力不足，无法运功",C_RED,CC.DefaultFont,nil,LimeGreen)
					else
						local r=newMenu[current][2](newMenu,current); 
						--连续两级菜单全部返回20作为判定参数
						if r == 20 then
							returnValue= 20; 
							break;
						end
						ClsN();
						lib.LoadSur(surid,0,0);
						if isBox==1 then
							DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
						end
					end
				elseif newMenu[current][2] == SelectQingGongMenu then
					local id = WAR.Person[WAR.CurID]["人物编号"]
					--运功体力不足
					if JY.Person[id]["体力"] < 20 then
						DrawStrBoxWaitKey("体力不足，无法运功",M_DeepSkyBlue,CC.DefaultFont,nil,LimeGreen)
					else
						local r=newMenu[current][2](newMenu,current); 
						if r == 10 then
							returnValue= 10; 
							break;
						end
						ClsN();
						lib.LoadSur(surid,0,0);
						if isBox==1 then
							DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
						end
					end
				else
					local r=newMenu[current][2](newMenu,current);               --调用菜单函数
			
					--无酒不欢：重写一下这里的返回逻辑以适应运功
					if r==1 then
						returnValue= -newMenu[current][4];
						break;
					--连续两级菜单全部返回20作为判定参数
					elseif In_Battle == true and r == 20 then	
						returnValue= 20;
						break;
					elseif In_Battle == true and r == 10 then	
						returnValue= 10;
						break;
					end			
					ClsN();
					lib.LoadSur(surid,0,0);
					if isBox==1 then
						DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
					end
				end
			end		
		end
	end
	lib.FreeSur(surid)
	return returnValue
end

--基本参数和ShowMenu一样，有一些特别的进行着重说明
--menu 每个数据三个值，1名称，2执行函数，3显示方式(0灰色可选择，1正常显示，2不显示, 3灰色不可选择)
--itemNum 菜单的个数，通常在调用的时候 #menu就可以了
--numShow 每行显示的菜单个数
--showRow 一个版面显示的最大行数，如果可显示菜单个数达不到一个版面的数，函数会自动适应这个值
--str 是标题的文字，传nil不显示
--选中项
function ShowMenu2(menu,itemNum,numShow,showRow,x1,y1,x2,y2,isBox,isEsc,size,color,selectColor, str, selIndex)     --通用菜单函数
    local w=0;
    local h=0;   --边框的宽高
    local i,j=0,0;
    local col=0;     --实际的显示菜单项
    local row=0;
    
    lib.GetKey();
    Cls();
    
    --建一个新的table
    local menuItem = {};
    local numItem = 0;                --显示的总数
    
    --把可显示的部分放到新table
    for i,v in pairs(menu) do
		if v[3] ~= 2 then
			numItem = numItem + 1;
			menuItem[numItem] = {v[1],v[2],v[3],i};                --注意第4个位置，保存i的值
		end
    end
    
    --计算实际显示的菜单项数
    if numShow==0 or numShow > numItem then
        col=numItem;
        row = 1;
    else
        col=numShow;
        row = math.modf((numItem-1)/col);
    end
    
    if showRow > row + 1 then
		showRow = row + 1;
    end

    --计算边框实际宽高
    local maxlength=0;
    if x2==0 and y2==0 then
        for i=1,numItem do
            if string.len(menuItem[i][1])>maxlength then
                maxlength=string.len(menuItem[i][1]);
            end
        end
		w=(size*maxlength/2+CC.RowPixel)*col+2*CC.MenuBorderPixel;
		h=showRow*(size+CC.RowPixel) + 2*CC.MenuBorderPixel;
    else
        w=x2-x1;
        h=y2-y1;
    end
    
    if x1 == -1 then
    	x1 = (CC.ScreenW-w)/2;
    end
    if y1 == -1 then
    	y1 = (CC.ScreenH-h+size)/2;
    end

    local start=0;             --显示的第一项

    local curx = 1;          --当前选择项
    local cury = 0;
    local current = curx + cury*numShow;
    
    --默认有选中
    if selIndex ~= nil and selIndex > 0 then
    	current = selIndex;
    	curx = math.fmod((selIndex-1),numShow) + 1;
    	cury = (selIndex - curx)/numShow;
    	if cury >= showRow/2 then
			start = limitX(cury-showRow/2,0,row-showRow+1);
		end
    end
    
    local returnValue =0;
    if str ~= nil then
		DrawStrBox(-1, y1 - size - 2*CC.MenuBorderPixel, str, color, size)
    end
    local surid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)
	if isBox==1 then
		DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
	end
	while true do
		lib.GetKey()
		if JY.Restart == 1 then
			break
		end
		if col ~= 0 then
			lib.LoadSur(surid, 0, 0)
			if isBox == 1 then
				DrawBox(x1, y1, x1 + (w), y1 + (h), C_WHITE)
			end
		end
        for i=start,showRow+start-1 do
			for j=1, col do
				local n = i*col+j;
				if n > numItem then
					break;
				end
				local drawColor=color;           --设置不同的绘制颜色
				if menuItem[n][3] == 0 or menuItem[n][3] == 3 then
					drawColor = M_DimGray
				end
				local xx = x1+(j-1)*(size*maxlength/2+CC.RowPixel) + CC.MenuBorderPixel
				local yy = y1+(i-start)*(size+CC.RowPixel) + CC.MenuBorderPixel
				if n==current then
					drawColor=selectColor;
					lib.Background(xx, yy, xx + size*maxlength/2, yy + size, 128, color)
				end
				DrawString(xx,yy,menuItem[n][1],drawColor,size);
			end
		end
		ShowScreen();
		local keyPress, ktype, mx, my = WaitKey(1)
		lib.Delay(CC.Frame);

		if keyPress==VK_ESCAPE or ktype == 4 then                  --Esc 退出
			if isEsc==1 then
				break;
			end
		elseif keyPress==VK_DOWN or ktype == 7 then                --Down
			if curx + (cury+1)*col <= numItem then
				cury = cury + 1;
				if cury > row then
					cury = row;
				elseif cury >= showRow/2 and cury <= row - showRow/2 + 1 and start <= row-showRow  then
					start = start + 1;
				end
			end
		elseif keyPress==VK_UP or ktype == 6 then                  --Up
			cury = cury -1;
			if cury < 0 then
				cury = 0;
			elseif cury >= showRow/2-1 and cury < row - showRow/2 and start > 0 then
				start = start - 1;
			end
		elseif keyPress==VK_RIGHT then                --RIGHT
			curx = curx +1;
			if curx > col then
				curx = 1;
			elseif curx + cury*col > numItem then
				curx = 1;
			end
		elseif keyPress==VK_LEFT then                  --LEFT
			curx = curx -1;
			if curx < 1 then
				curx = col;
				if curx + cury*col > numItem then
					curx = numItem - cury*col;
				end
			end
		else
			local mk = false;
			if ktype == 2 or ktype == 3 then			--选中
				--无酒不欢：加个逻辑判定防止跳出
				local re1, re2 = curx, cury;
				if mx >= x1 and mx <= x1 + w and my >= y1 and my <= y1 + h then
					curx = math.modf((mx-x1-CC.MenuBorderPixel)/(size*maxlength/2+CC.RowPixel)) + 1
					cury = start + math.modf((my - y1 - CC.MenuBorderPixel) / (size + CC.RowPixel))
					mk = true;
				end
				if (curx + cury*col) > #menuItem then
					curx = re1
					cury = re2
					mk = false;
				end
			end
		
			if keyPress==VK_SPACE or keyPress==VK_RETURN or ktype == 5 or (ktype == 3 and mk) then
				current = curx + cury*col;
				if menuItem[current][3]==3 then
                              
				elseif menuItem[current][2]==nil then
					returnValue=current;
					break;
				else
					local r=menuItem[current][2](menuItem,current);               --调用菜单函数
					if r==1 then
						returnValue= -current;
						break;
					else
						lib.LoadSur(surid, 0, 0)
						if isBox==1 then
							DrawBox(x1, y1, x1 + (w), y1 + (h), C_WHITE)
						end
					end
				end
			end
		end 
		current = curx + cury*col;
    end
	lib.FreeSur(surid)
        
	--返回值，这个是取第4个位置的值
	if returnValue > 0 then
		return menuItem[returnValue][4]
	else
		return returnValue
	end
end

function ShowMenu4(menuItem,numItem,rownum,x1,y1,x2,y2,isBox,isEsc,size,color,selectColor,Title1,color2,color3,linenum, flag)
  local w = 0
  local h = 0
  local i = 0
  local newNumItem = 0
  lib.GetKey()
  local newMenu = {}
  for i = 1, numItem do
    if menuItem[i][3] > 0 then
      newNumItem = newNumItem + 1
      newMenu[newNumItem] = {menuItem[i][1], menuItem[i][2], menuItem[i][3], i}
    end
  end
  if newNumItem == 0 then
    return 0
  end
  local maxlength = 0
  for i = 1, newNumItem do
	if maxlength < string.len(newMenu[i][1]) then
		maxlength = string.len(newMenu[i][1])
	end
  end
  if linenum == nil then
  	linenum = math.modf((newNumItem-1)/rownum+1)
  end
  if x1 == -2 and y1 == -2 or x2 == -2 and y2 == -2 then
    w = (size * maxlength / 2 + CC.MenuBorderPixel) * rownum + CC.MenuBorderPixel
	if w < size*string.len(Title1 or "")/2 + size + 2 * CC.MenuBorderPixel then
		w = size*string.len(Title1 or "")/2 + size + 2 * CC.MenuBorderPixel
	end
	if Title1 == nil then
		h = (size + CC.MenuBorderPixel*2 + 5) * linenum + CC.MenuBorderPixel
	else
		h = (size + CC.MenuBorderPixel*2 + 5) * (linenum + 1) + CC.MenuBorderPixel + 10
	end
  else
    w = x2 - x1
    h = y2 - y1
  end
  if x1 == -2 and y1 == -2 and x2 == -2 and y2 == -2 then
  	x1 = math.modf(CC.ScreenW/2 - w/2)
	y1 = math.modf(CC.ScreenH/2 - h/2)
  elseif x1 == -2 and y1 == -2 then
	x1 = x2 - w
	y1 = y2 - h
  end
  local xx = x1 + w/rownum/2 - size * maxlength / 4
  local start = 1
  local current = 1
  local keyPress = -1
  local returnValue = 0
  if isBox == 1 then
	DrawBox(x1,y1,x1+w,y1+h,C_WHITE)
  end
  local surid = lib.SaveSur(0,0,CC.ScreenW,CC.ScreenH)
  while true do
	lib.GetKey()
	if JY.Restart == 1 then
		break
	end
	if flag ~= nil then
		Cls(x1,y1,x1+w,y1+h)
	else
		Cls()
	end
	lib.LoadSur(surid, 0, 0)
	if Title1 ~= nil then
		DrawString(-1,y1 + CC.MenuBorderPixel,Title1,selectColor,size)
	end

	local over = limitX(start + rownum * linenum - 1,start,newNumItem)
	local yy = y1 + size + 2 * CC.MenuBorderPixel + 15
	if Title1 == nil then
		yy = y1 + 10
	end
	for i = start, over do
		local colorS = color
		local row = rownum - 1
		if math.fmod(i,rownum) ~= 0 then
			row = math.fmod(i,rownum) - 1
		end
		if i == current then
			colorS = selectColor
			lib.Background(xx+row*w/rownum-3,yy-3,xx+row*w/rownum+maxlength*size/2+3,yy+size+8, 128, color)
		end
		if newMenu[i][3] == 2 and color2 ~= nil then
			colorS = color2
		end
		if newMenu[i][3] == 3 and color3 ~= nil then
			colorS = color3
		end
		DrawString(xx+row*w/rownum,yy,newMenu[i][1],colorS,size)
		if math.fmod(i,rownum) == 0 then
			yy = yy + size + CC.MenuBorderPixel * 2 + 5
		end
	end
	ShowScreen()
	keyPress = WaitKey(1)
	local moda = math.fmod(newNumItem,rownum)
	if moda == 0 then
		moda = rownum
	end
	local modc = math.fmod(current,rownum)
	if modc == 0 then
		modc = rownum
	end
	if isEsc == 1 and keyPress==VK_ESCAPE then                  --Esc 退出
		break;
	elseif keyPress==VK_DOWN then                --Down
		current = current + rownum
		if current > over and over < newNumItem then
			start = start + rownum
		elseif current > newNumItem then
			start = 1
			current = modc
		end
	elseif keyPress==VK_UP then                  --Up
		current = current - rownum
		if current < start and start > 1 then
			start = start - rownum
		elseif current < 1 then
			start = limitX(newNumItem-(linenum-1)*rownum-moda+1,1,newNumItem)
			if moda >= modc then
				current = newNumItem + modc - moda
			else
				current = newNumItem - moda - rownum + modc
			end
		end
	elseif keyPress == VK_RIGHT then
		current = current + 1
		if current > over and over < newNumItem then
			start = start + rownum
		elseif current > newNumItem then
			start = 1
			current = 1
		end
	elseif keyPress == VK_LEFT then
		current = current - 1
		if current < start and start > 1 then
			start = start - rownum
		elseif current < 1 then
			start = limitX(newNumItem-(linenum-1)*rownum-moda+1,1,newNumItem)
			current = newNumItem
		end
	elseif  keyPress==VK_SPACE or keyPress==VK_RETURN  then
		if newMenu[current][2]== nil and newMenu[current][3] == 1 then
			returnValue=newMenu[current][4];
			break;
		elseif newMenu[current][3] == 1 then
			local r=newMenu[current][2](newMenu,current);               --调用菜单函数
			if r==1 then
				returnValue= -newMenu[current][4];
				break;
			else
				Cls(x1,y1,x1+w,y1+h);
				if isBox==1 then
					DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
				end
			end
		end
	--[[	
	elseif keyPress==888 and start>1 then
		start=start-rownum
	elseif keyPress==999 and start<newNumItem-(linenum-1)*rownum-moda+1 then
		start=start+rownum
	elseif keyPress>999999 then
		local kind, mx, my = nil, nil, nil
		if keyPress>1999999 then
			kind=1
			keyPress=keyPress-2000000
		else
			kind=0
			keyPress=keyPress-1000000
		end
		mx=math.modf(keyPress/1000)
		my=math.fmod(keyPress,1000)

		if mx>x1 and mx<x1+w and my>y1 and my<y1+h then
			if Title1 == nil and Title2 == nil then
				current = start-1+math.modf((mx-xx)/(w/rownum)+1) + rownum*math.modf((my-y1-10)/(size+CC.MenuBorderPixel*2+5))
			else
				current = start-1+math.modf((mx-xx)/(w/rownum)+1) + rownum*math.modf((my-y1-size-2*CC.MenuBorderPixel-15)/(size+CC.MenuBorderPixel*2+5))
			end
			current = limitX(current,1,newNumItem)
			if kind==1 then
				if newMenu[current][2]==nil and newMenu[current][3] == 1 then
					returnValue=newMenu[current][4];
					break;
				elseif newMenu[current][3] == 1 then
					local r=newMenu[current][2](newMenu,current);               --调用菜单函数
					if r==1 then
						returnValue= -newMenu[current][4];
						break;
					else
						Cls(x1,y1,x1+w,y1+h);
						if isBox==1 then
							DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
						end
					end
				end
			end
		end
	end]]
	end
  end
  lib.FreeSur(surid)
  return returnValue
end
------------------------------------------------------------------------------------
--------------------------------------物品使用---------------------------------------
--物品使用模块
--当前物品id
--返回1 使用了物品， 0 没有使用物品。可能是某些原因不能使用
function UseThing(id)
	return DefaultUseThing(id);
end

--缺省物品使用函数，实现原始游戏效果
--id 物品id
function DefaultUseThing(id)                --缺省物品使用函数
    if JY.Thing[id]["类型"]==0 then
        return UseThing_Type0(id);
    elseif JY.Thing[id]["类型"]==1 then
        return UseThing_Type1(id);
    elseif JY.Thing[id]["类型"]==2 then
        return UseThing_Type2(id);
    elseif JY.Thing[id]["类型"]==3 then
        return UseThing_Type3(id);
    elseif JY.Thing[id]["类型"]==4 then
        return UseThing_Type4(id);
    end
end

--剧情物品，触发事件
function UseThing_Type0(id)
	--合并九阴
	if id == 286 then
		local jyzj = 0
		for j=1, CC.MyThingNum do
			if JY.Base["物品" .. j] == 287 then
				jyzj = 1;
				break;
			end
		end
		if jyzj == 1 then
			instruct_2(286,-1)
			instruct_2(287,-1)
			instruct_2(84,1)
		end
		return 0;
	end
	if id == 287 then
		local jyzj = 0
		for j=1, CC.MyThingNum do
			if JY.Base["物品" .. j] == 286 then
				jyzj = 1;
				break;
			end
		end
		if jyzj == 1 then
			instruct_2(286,-1)
			instruct_2(287,-1)
			instruct_2(84,1)
		end
		return 0;
	end
	

	
    if JY.SubScene>=0 then
		local x=JY.Base["人X1"]+CC.DirectX[JY.Base["人方向"]+1];
		local y=JY.Base["人Y1"]+CC.DirectY[JY.Base["人方向"]+1];
        local d_num=GetS(JY.SubScene,x,y,3)
        if d_num>=0 then
            JY.CurrentThing=id;
            EventExecute(d_num,2);       --物品触发事件
            JY.CurrentThing=-1;
			return 1;
		else
		    return 0;
        end
    end
	--合地灵丹事件
	if id == 315 then
		local dld = 0
		for j=1, CC.MyThingNum do
			if JY.Base["物品" .. j] == 314 and JY.Base["物品" .. j] == 231 and JY.Base["物品" .. j] == 	26 then
				dld = 1;
				break;
			end
		end
		if dld == 1 then
			instruct_2(314,-1)
			instruct_2(231,-1)
			instruct_2(26,-1)			
			instruct_2(316,1)
		end
		return 0;
	end	

end


--判断一个人是否可以装备或修炼一个物品
--返回 true可以修炼，false不可
function CanUseThing(id, personid)
	local str = ""
		
	--张家辉的专属装备
	if JY.Thing[id]["仅修炼人物"] == 651 then
		if personid == 0 and JY.Base["畅想"] == 651 then
			return true
		else
			return false
		end
	end

    --if ZhongYongZD(personid) and (id == 118 or id == 235) then 
        --return true
   -- end
		--佛门无双
	if match_ID(personid, 9993) and (id == 72 or id == 69 or id == 83 or id == 85 or id == 88 or id == 90 or  id == 92 or id == 112 or id ==137 
      or id == 168 or id == 171 or id  == 245 or id ==250 or id == 253 or id == 260 or id == 265 or id == 268 or id == 269 or id == 274 
     or id == 277 or  id == 291 or id == 319 or id == 324 or id == 332)  then
		return true
	--王语嫣，随便修炼秘籍
	elseif (match_ID(personid, 76) or match_ID(personid, 637))  and JY.Thing[id]["类型"] == 2 then
		return true	
	--主角学圣火
	elseif id == 70 and personid == 0 then
		return true		
	--阿朱穿装备
	elseif match_ID(personid, 104) and JY.Thing[id]["装备类型"] >= 0 then
		return true
	--白猿装备白猿
	elseif match_ID(personid, 9997) and id == 326 then
		return true	
    --无聊装备绣花针
    elseif match_ID(personid, 721) and id == 349 then
        Cls(CC.MainSubMenuX, CC.MainSubMenuY, CC.ScreenW, CC.ScreenH)
		 if DrawStrBoxYesNo(-1, -1, "装备此物品需要自宫，是否继续装备?", C_WHITE, CC.DefaultFont) == false  then
			return 0
		else
			lib.FillColor(0, 0, CC.ScreenW, CC.ScreenH, C_RED, 128)
			ShowScreen()
			lib.Delay(80)
			lib.ShowSlow(15, 1)
			Cls()
			lib.ShowSlow(50, 0)
			JY.Person[personid]["性别"] = 2
			JY.Person[personid]["半身像"] = 721
			JY.Person[personid]["头像代号"]=322
			JY.Person[personid]["出招动画帧数2"]=16
			JY.Person[personid]["出招动画延迟2"]=14
			JY.Person[personid]["武功音效延迟2"]=14
			local add, str = AddPersonAttrib(personid, "攻击力", -20)
			DrawStrBoxWaitKey(JY.Person[personid]["姓名"] .. str, C_ORANGE, CC.DefaultFont)
			add, str = AddPersonAttrib(personid, "防御力", -30)
			DrawStrBoxWaitKey(JY.Person[personid]["姓名"] .. str, C_ORANGE, CC.DefaultFont)
			return true
		end
	--方证学金刚不坏体
	elseif match_ID(personid, 149) and id == 265 then
		return true
	else
		if JY.Thing[id]["仅修炼人物"] >= 0 and JY.Thing[id]["仅修炼人物"] ~= personid and (personid == 0 and JY.Thing[id]["仅修炼人物"]==JY.Base["畅想"])==false then
			return false
		end
		if JY.Thing[id]["需内力性质"] ~= 2 and JY.Person[personid]["内力性质"] ~= 2 and JY.Person[personid]["内力性质"] ~= 3 and JY.Thing[id]["需内力性质"] ~= JY.Person[personid]["内力性质"] then
			local cond = 1
			--天内可以无视阴阳学习 博通百家 大唐双龙之冰
			if JY.Thing[id]["练出武功"] == JY.Person[personid]["天赋内功"]  or match_ID(personid, 578)or match_ID(personid, 9987)
               or match_ID(personid,9978) then
				cond = 2
			--主角学降龙无视内力
			elseif id == 86 and personid == 0 then
				cond = 2
			end
			--天外也可以无视阴阳学习
			for i = 1, 4 do
				if JY.Thing[id]["练出武功"] == JY.Person[personid]["天赋外功"..i] then
					cond = 2
					break
				end
			end
			if cond == 1 then
				return false
			end
		end
		if JY.Person[personid]["内力最大值"] < JY.Thing[id]["需内力"] then
			return false
		end
		if JY.Person[personid]["攻击力"] < JY.Thing[id]["需攻击力"] then
			return false
		end
		if JY.Person[personid]["轻功"] < JY.Thing[id]["需轻功"] then
			return false
		end
		if JY.Person[personid]["用毒能力"] < JY.Thing[id]["需用毒能力"] then
			return false
		end
		if JY.Person[personid]["医疗能力"] < JY.Thing[id]["需医疗能力"] then
			return false
		end
		if JY.Person[personid]["解毒能力"] < JY.Thing[id]["需解毒能力"] then
			return false
		end

		--学有小无相功，兵器值视作+10点
		local lv = 0;
		if PersonKF(personid, 98) then
			lv = 10
		end
		--博通百家
		if match_ID(personid, 9987)  then
		 lv = lv + 20
		end
		--有胡刀，学苗剑，需求-40
		if id == 117 and PersonKF(personid, 67) then
			lv = lv + 40
		end
		--有苗剑，学胡刀，需求-40
		if id == 136 and PersonKF(personid, 44) then
			lv = lv + 40
		end
		
		--桃花绝技，学习其中之一后，剩下两个的需求减少-10，可叠加
		if id == 95 or id == 101 or id == 123 then
			for i = 1, JY.Base["武功数量"] do
				if JY.Person[personid]["武功" .. i] == 12 or JY.Person[personid]["武功" .. i] == 18 or JY.Person[personid]["武功" .. i] == 38 then
					lv = lv + 10
				end
			end
		end
		--太极奥义，学习其中之一后，剩下需求减少-10
		if id == 97 or id == 115  then
			for i = 1, JY.Base["武功数量"] do
				if JY.Person[personid]["武功" .. i] == 46 or JY.Person[personid]["武功" .. i] == 16  then
					lv = lv + 10
				end
			end
		end		
		--金刚般若-40
		if id == 291 or id == 90 or id == 324  then
			for i = 1, JY.Base["武功数量"] do
				if JY.Person[personid]["武功" .. i] == 46 or JY.Person[personid]["武功" .. i] == 16  then
					lv = lv + 10
				end
			end
		end			
		--有打狗，学降龙-40
		if id == 86 and PersonKF(personid, 80) then
		if PersonKF(personid,204) then
		  lv = lv + 60
		  else
			lv = lv + 40
		end
	end	
		--有降龙，学打狗-40
		if id == 167 and PersonKF(personid, 26) then
		if PersonKF(personid,204) then
		  lv = lv + 60
		  else
			lv = lv + 40
		end
	end	
		--有九剑，学持瑶琴-40
		if id == 180 and PersonKF(personid, 47) then
			lv = lv + 40
		end
		--有持瑶琴，学九剑-40
		if id == 114 and PersonKF(personid, 73) then
			lv = lv + 40
		end
		
		if JY.Person[personid]["拳掌功夫"] + lv < JY.Thing[id]["需拳掌功夫"] then
			return false
		end
		if JY.Person[personid]["指法技巧"] + lv < JY.Thing[id]["需指法技巧"] then
			return false
		end
		if JY.Person[personid]["御剑能力"] + lv  < JY.Thing[id]["需御剑能力"] then
			return false
		end
		if JY.Person[personid]["耍刀技巧"] + lv  < JY.Thing[id]["需耍刀技巧"] then
			return false
		end
		if JY.Person[personid]["特殊兵器"] + lv < JY.Thing[id]["需特殊兵器"] then
			return false
		end
		
		if JY.Person[personid]["暗器技巧"] < JY.Thing[id]["需暗器技巧"] then
			return false
		end
    
        if id == 372 then 
            if JY.Person[personid]["资质"] < 31 or JY.Person[personid]["资质"] > 79 then 
                return false
            end
        end
    
		if JY.Thing[id]["需资质"] >= 0 then
			if JY.Thing[id]["需资质"] > JY.Person[personid]["资质"] then
				return false;
			end
		else
			if -JY.Thing[id]["需资质"] < JY.Person[personid]["资质"] then
				return false;
			end 
		end
        
	end
	  
	--斗转限制
	if id == 118 then
		local R = JY.Person[personid]
		local wp = R["拳掌功夫"] + R["指法技巧"] + R["御剑能力"] + R["耍刀技巧"] + R["特殊兵器"]
		if wp < 120 then
			return false
		end
	end
	--阴阳限制
	if id == 176 then
		local R = JY.Person[personid]
		if R["御剑能力"] >= 70 then
			return true
		elseif R["耍刀技巧"] >= 70 then
			return true
		elseif R["特殊兵器"] >= 70 then
			return true
		else
			return false
		end
	end
    --绣花针
	if id == 349 then
		--local R = JY.Person[personid]
		if match_ID(personid, 27) then
			return true
		else 
			return false
		end
	end
    	--鸳鸯刀
	if id == 217  then
		local R = JY.Person[personid]
		if R["性别"]== 0 then
			return true
		else return false
		end
	end	
    	--鸳鸯刀
	if id == 218  then
		local R = JY.Person[personid]
		if R["性别"]== 1 then
			return true
		else return false
		end
	end		
	--金丝手套限制
	if id == 239 then
		local R = JY.Person[personid]
		if R["拳掌功夫"] >= 70 then
			return true
		elseif R["指法技巧"] >= 70 then
			return true
		else
			return false
		end
	end
	--七宝指环限制
	if id == 200 then
		local R = JY.Person[personid]
		if R["拳掌功夫"] >= 200 then
			return true
		elseif R["指法技巧"] >= 200 then
			return true
		else
			return false
		end
	end	
	return true
end

--药品使用实际效果
--id 物品id，
--personid 使用人id
--返回值：0 使用没有效果，物品数量应该不变。1 使用有效果，则使用后物品数量应该-1
function UseThingEffect(id, personid, amount)
	--无使用数量则默认为使用1个
	if amount == nil then
		amount = 1
	end

	--特殊药品
	if id == 343 then
		Cls()  --清屏
		local k = JY.Wugong;
		local menu = {}
	
		local kftype = JYMsgBox("请选择", "请选择喜欢的天赋内功类型", {"内功",}, 1, 347)
	
		for i = 1, JY.WugongNum - 1 do
			local kfname = k[i]["名称"]
			if string.len(kfname) == 8 then
				kfname = kfname.."  "
			elseif string.len(kfname) == 6 then
				kfname = kfname.."    "
			elseif string.len(kfname) == 4 then
				kfname = kfname.."      "
			end
			menu[i] = {kfname,nil,2}
			if k[i]["武功类型"] == 6 then
				menu[i][3] = 1
			end
		end
		local nexty = CC.ScreenH/2-CC.DefaultFont*4 + CC.SingleLineHeight
		local r = ShowMenu2(menu, #menu, 4, 5, CC.ScreenW/2-CC.DefaultFont*10-20, nexty, 0, 0, 1, 0, CC.DefaultFont, C_ORANGE, C_WHITE,"领悟天赋内功")
	
		if r > 0 then
			SetTianNei(personid, r)
		end
			return 2
	elseif id == 344 then
		Cls()  --清屏
		local k = JY.Wugong;
		local menu = {}
	
		local kftype = JYMsgBox("请选择", "请选择喜欢的天赋轻功类型", {"轻功",}, 1, 347)
	
		for i = 1, JY.WugongNum - 1 do
			local kfname = k[i]["名称"]
			if string.len(kfname) == 8 then
				kfname = kfname.."  "
			elseif string.len(kfname) == 6 then
				kfname = kfname.."    "
			elseif string.len(kfname) == 4 then
				kfname = kfname.."      "
			end
			menu[i] = {kfname,nil,2}
			if k[i]["武功类型"] == 7 then
				menu[i][3] = 1
			end
		end
		local nexty = CC.ScreenH/2-CC.DefaultFont*4 + CC.SingleLineHeight
		local r = ShowMenu2(menu, #menu, 4, 5, CC.ScreenW/2-CC.DefaultFont*10-20, nexty, 0, 0, 1, 0, CC.DefaultFont, C_ORANGE, C_WHITE,"领悟天赋轻功")
	
		if r > 0 then
			SetTianQing(personid, r)
		end
		return 2
	elseif id == 345 then
		Cls()  --清屏
		local k = JY.Wugong;
		local menu = {}
		local kftype = JYMsgBox("请选择", "请选择喜欢的天赋外功1类型", {"拳法","指法","剑法","刀法","奇门"}, 5, 347)
	
		for i = 1, JY.WugongNum - 1 do
			local kfname = k[i]["名称"]
			if string.len(kfname) == 8 then
				kfname = kfname.."  "
			elseif string.len(kfname) == 6 then
				kfname = kfname.."    "
			elseif string.len(kfname) == 4 then
				kfname = kfname.."      "
			end
			menu[i] = {kfname,nil,2}
			if k[i]["武功类型"] == kftype then
				menu[i][3] = 1
			end
		end
		local nexty = CC.ScreenH/2-CC.DefaultFont*4 + CC.SingleLineHeight
		local r = ShowMenu2(menu, #menu, 4, 5, CC.ScreenW/2-CC.DefaultFont*10-20, nexty, 0, 0, 1, 0, CC.DefaultFont, C_ORANGE, C_WHITE,"领悟天赋外功")
	
		if r > 0 then
			SetTianWai(personid, 1, r)
		end

		return 2
	elseif id == 346 then
		Cls()  --清屏
		JY.Person[0]["头像代号"]=JY.Person[642]["头像代号"]
		JY.Person[0]["半身像"]=JY.Person[642]["半身像"]
		JY.Person[0]["姓名"]=JY.Person[642]["姓名"]
		for i=1,5 do
			JY.Person[0]["出招动画帧数" .. i]=JY.Person[642]["出招动画帧数" .. i]
			JY.Person[0]["出招动画延迟" .. i]=JY.Person[642]["出招动画延迟" .. i]
			JY.Person[0]["武功音效延迟" .. i]=JY.Person[642]["武功音效延迟" .. i]
		end
		return 2
	else
		local str = {}
		str[0] = string.format("使用 %s × %d", JY.Thing[id]["名称"], amount)
		local strnum = 1
		local addvalue = nil
		if JY.Thing[id]["加生命"] > 0 then
			local add = JY.Thing[id]["加生命"] - math.modf(JY.Thing[id]["加生命"] * JY.Person[personid]["受伤程度"] / 200) + Rnd(5)
			--胡青牛在队，吃药效果为1.3倍
			if JY.Status == GAME_WMAP and inteam(personid) and (inteam(16) or JY.Base["畅想"] == 16) then
				for w = 0, WAR.PersonNum - 1 do
					if match_ID(WAR.Person[w]["人物编号"], 16) and WAR.Person[w]["死亡"] == false and WAR.Person[w]["我方"] then
						add = math.modf(add * 1.3)
						break;
					end
				end
			end
			if add <= 0 then
				add = 5 + Rnd(5)
			end
			add = math.modf(add)
			
			--洪安通，敌人吃药不加血反而减血
			if JY.Status == GAME_WMAP then
				for w = 0, WAR.PersonNum - 1 do
					if match_ID(WAR.Person[w]["人物编号"], 71) and WAR.Person[w]["死亡"] == false and WAR.Person[w]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
						add = -add
						break;
					end
				end
			end
			
			--敌人吃药效果加倍
			if not inteam(personid) then
				add = add * 2;
			end
			--实战后吃药效果加倍
			if  inteam(personid) and JY.Person[0]["实战"] >= 500 then
				add = add * 2;
			end			
		
			if JY.Status == GAME_WMAP then
				WAR.Person[WAR.CurID]["内伤点数"] = AddPersonAttrib(personid, "受伤程度", -math.modf(add / 8))
			end

			addvalue, str[strnum] = AddPersonAttrib(personid, "生命", add*amount)
			
			--蓝烟清：显示生命点数
			if JY.Status == GAME_WMAP then
				WAR.Person[WAR.CurID]["生命点数"] = addvalue;
			end
			if addvalue ~= 0 then
				strnum = strnum + 1
			end
		end
	  
		local function ThingAddAttrib(s)
			if JY.Thing[id]["加" .. s] ~= 0 then
				addvalue, str[strnum] = AddPersonAttrib(personid, s, JY.Thing[id]["加" .. s]*amount)
				if addvalue ~= 0 then
				strnum = strnum + 1
				end
				--蓝烟清：显示体力，内力点数
				if JY.Status == GAME_WMAP then
					if s == "体力" then
						WAR.Person[WAR.CurID]["体力点数"] = addvalue;
					elseif s == "内力" then
						WAR.Person[WAR.CurID]["内力点数"] = addvalue;
					end
				end
			end
		end
	  
		ThingAddAttrib("生命最大值")
	  
		if JY.Thing[id]["加中毒解毒"] < 0 then
			addvalue, str[strnum] = AddPersonAttrib(personid, "中毒程度", math.modf(JY.Thing[id]["加中毒解毒"] / 2)*amount)
			if addvalue ~= 0 then
				strnum = strnum + 1
			end
			--蓝烟清：显示中解毒点数
			if JY.Status == GAME_WMAP then
				if addvalue < 0 then
					WAR.Person[WAR.CurID]["解毒点数"] = -addvalue;
				elseif addvalue > 0 then
					WAR.Person[WAR.CurID]["中毒点数"] = addvalue;
				end
			end
		end
		  
		ThingAddAttrib("体力")
	  
		if JY.Thing[id]["改变内力性质"] == 2 then
			str[strnum] = "内力门路改为阴阳合一"
			strnum = strnum + 1
		end
		---
        if JY.Status == GAME_WMAP then 
            if id == 25 then 
                JY.Person[personid]['受伤程度'] = 0
                JY.Person[personid]['中毒程度'] = 0
                JY.Person[personid]['灼烧程度'] = 0
                JY.Person[personid]['冰封程度'] = 0
                WAR.FXDS[personid] = nil
				WAR.LXZT[personid] = nil
				WAR.PD['五宝花蜜酒'][personid] = 100               
            end
            if id == 24 then
                if WAR.LXZT[personid] ~= nil then 
                    WAR.LXZT[personid] = WAR.LXZT[personid] - 50
                    if WAR.LXZT[personid] < 1 then 
                        WAR.LXZT[personid] = nil
                    end
                end
                WAR.PD['即墨老酒'][personid] = 100
            end
            
            if id == 23 then 
                AddPersonAttrib(personid,'灼烧程度',-20)
                WAR.PD['玉露酒'][personid] = 50
            end    
            
            if id == 22 then 
                AddPersonAttrib(personid,'冰封程度',-50)
                WAR.PD['梨花酒'][personid] = 50
            end
            
            if id == 11 then 
                WAR.PD['六阳正气'][personid] = 100
            end
            
            if id == 10 then 
                WAR.PD['牛黄血蝎'][personid] = 50
            end
            
            if id == 9 then 
                WAR.PD['黄连解毒'][personid] = 50
            end
            
            if id == 3 then 
                WAR.PD['白云熊胆'][personid] = 200
            end
            
            if id == 1 then 
                WAR.PD['天香续命'][personid] = 100
            end
            
            if id == 0 then 
                WAR.PD['小还丹'][personid] = 50
            end
        else    
            if id == 25 then 
                JY.Person[personid]['受伤程度'] = 0
                JY.Person[personid]['中毒程度'] = 0
                JY.Person[personid]['灼烧程度'] = 0
				JY.Person[personid]['冰封程度'] = 0				
            end
        end
        
	    if JY.Person[id]["生命增长"] > 12 then
            JY.Person[id]["生命增长"] = 12 	   
	    end	
		ThingAddAttrib("内力")
		ThingAddAttrib("内力最大值")
		ThingAddAttrib("攻击力")
		ThingAddAttrib("防御力")
		ThingAddAttrib("轻功")
		ThingAddAttrib("医疗能力")
		ThingAddAttrib("用毒能力")
		ThingAddAttrib("解毒能力")
		ThingAddAttrib("抗毒能力")
		ThingAddAttrib("拳掌功夫")
		ThingAddAttrib("御剑能力")
		ThingAddAttrib("耍刀技巧")
		ThingAddAttrib("特殊兵器")
		ThingAddAttrib("暗器技巧")
		ThingAddAttrib("武学常识")
		ThingAddAttrib("攻击带毒")
	  
		Cls()
		
		if strnum > 1 then
			local maxlength = 0
			for i = 0, strnum-1 do
				if maxlength < #str[i] then
					maxlength = #str[i]
				end
			end
			
			if JY.Status ~= GAME_WMAP then
				local ww = maxlength * CC.DefaultFont / 2 + CC.MenuBorderPixel * 2
				local hh = (strnum) * CC.DefaultFont + (strnum - 1) * CC.RowPixel + 2 * CC.MenuBorderPixel
				local x = (CC.ScreenW - ww) / 2
				local y = (CC.ScreenH - hh) / 2
				DrawBox(x, y, x + ww, y + hh, C_WHITE)
				DrawString(x + CC.MenuBorderPixel, y + CC.MenuBorderPixel, str[0], C_WHITE, CC.DefaultFont)
				for i = 1, strnum - 1 do
				  DrawString(x + CC.MenuBorderPixel, y + CC.MenuBorderPixel + (CC.DefaultFont + CC.RowPixel) * i, str[i], C_ORANGE, CC.DefaultFont)
				end

				ShowScreen()
			else
				--显示使用物品文字
				DrawString(CC.MainMenuX, CC.ScreenH-(strnum+2)*CC.Fontsmall, JY.Person[WAR.Person[WAR.CurID]["人物编号"]]["姓名"].." "..str[0], C_WHITE, CC.Fontsmall);
				for i=1, strnum-1 do 
					DrawString(CC.MainMenuX, CC.ScreenH + (i-strnum-2)*CC.Fontsmall, str[i], C_WHITE, CC.Fontsmall);
				end
				
				ShowScreen()
				--显示点数
				War_Show_Count(WAR.CurID);
				return 1;
			end
			return 1
		else
			DrawStrBox(-1, -1, str[0], C_WHITE, CC.DefaultFont)
			ShowScreen()
			return 1
		end
	end
end

--装备物品
function UseThing_Type1(id)
	DrawStrBox(CC.MainSubMenuX, CC.MainSubMenuY, string.format("谁要配备%s?", JY.Thing[id]["名称"]), C_WHITE, CC.DefaultFont)
	local nexty = CC.MainSubMenuY + CC.SingleLineHeight
	local r = SelectTeamMenu(CC.MainSubMenuX, nexty)
	local pp1, pp2 = 0, 0
	if r > 0 then
		local personid = JY.Base["队伍" .. r]
		--田归农装闯王军刀
		if id == 202 and match_ID(personid, 72) then
			say("嘿嘿，这口宝刀本来就是田掌门的兵器，谁说耍刀不够就装不了？",72,0)
			if JY.Thing[id]["使用人"] >= 0 then
								
				JY.Person[JY.Thing[id]["使用人"]]["武器"] = -1
			end
			if JY.Person[personid]["武器"] >= 0 then
				JY.Thing[JY.Person[personid]["武器"]]["使用人"] = -1
			end
			JY.Person[personid]["武器"] = id
			JY.Thing[id]["使用人"] = personid
			return 1
		end
		
		if CanUseThing(id, personid) then
			if JY.Thing[id]["装备类型"] == 0 then
				if JY.Thing[id]["使用人"] >= 0 then
					
					JY.Person[JY.Thing[id]["使用人"]]["武器"] = -1
				end
				if JY.Person[personid]["武器"] >= 0 then
					JY.Thing[JY.Person[personid]["武器"]]["使用人"] = -1
				end
				JY.Person[personid]["武器"] = id
			
			elseif JY.Thing[id]["装备类型"] == 1 then
				if JY.Thing[id]["使用人"] >= 0 then
					
					JY.Person[JY.Thing[id]["使用人"]]["防具"] = -1
				end
				if JY.Person[personid]["防具"] >= 0 then
					JY.Thing[JY.Person[personid]["防具"]]["使用人"] = -1
				end
				JY.Person[personid]["防具"] = id
			elseif JY.Thing[id]["装备类型"] == 2 then
				if JY.Thing[id]["使用人"] >= 0 then
					
					JY.Person[JY.Thing[id]["使用人"]]["坐骑"] = -1
				end
				if JY.Person[personid]["坐骑"] >= 0 then
					JY.Thing[JY.Person[personid]["坐骑"]]["使用人"] = -1
				end
				JY.Person[personid]["坐骑"] = id				
			  
			end
			JY.Thing[id]["使用人"] = personid
		else
			DrawStrBoxWaitKey("此人不适合配备此物品", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	return 1
end
--秘籍物品使用
function UseThing_Type2(id)
	if JY.Thing[id]["使用人"] >= 0 and DrawStrBoxYesNo(-1, -1, "此物品已经有人修炼，是否换人修炼?", C_WHITE, CC.DefaultFont) == false then
		Cls(CC.MainSubMenuX, CC.MainSubMenuY, CC.ScreenW, CC.ScreenH)
		ShowScreen()
		return 0
	end
	Cls()
	DrawStrBox(CC.MainSubMenuX, CC.MainSubMenuY, string.format("谁要修炼%s?", JY.Thing[id]["名称"]), C_WHITE, CC.DefaultFont)
	local nexty = CC.MainSubMenuY + CC.SingleLineHeight
	local r = SelectTeamMenu(CC.MainSubMenuX, nexty)
	if r > 0 then
		local personid = JY.Base["队伍" .. r]
		local yes, full = nil, nil
		if JY.Thing[id]["练出武功"] >= 0 then
			yes = 0
			full = 1
			for i = 1, JY.Base["武功数量"] do
				if JY.Person[personid]["武功" .. i] == JY.Thing[id]["练出武功"] then
					yes = 1
				else
					if JY.Person[personid]["武功" .. i] == 0 then
						full = 0
					end
				end
			end
		end
		
        if CanUseThing(id, personid) then
            --纯阳一脉相承九阳，面板有纯阳的可以无条件学九阳
            if id == 83 then
                if PersonKF(personid, 99) and PersonKF(personid, 106) == false then
                    if DrawStrBoxYesNo(-1, -1, "纯阳九阳，一脉相承，是否将武功洗为九阳神功?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 99 then
                                JY.Person[personid]["武功" .. i] = 106
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋内功"] == 99 then
                                    JY.Person[personid]["天赋内功"] = 106
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end
            --紫霞一脉相承五岳，面板有紫霞的可以无条件学五岳剑诀
            if id == 299 then
                if PersonKF(personid, 89) and PersonKF(personid, 175) == false then
                    if DrawStrBoxYesNo(-1, -1, "五岳剑诀，一脉相承，是否将武功紫霞神功洗为五岳剑诀?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 89 then
                                JY.Person[personid]["武功" .. i] = 175
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋内功"] == 89 then
                                    JY.Person[personid]["天赋内功"] = 175
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end

            --血河天魔功一脉相承
            if id == 327 then
                if PersonKF(personid, 163) and PersonKF(personid, 160) == false then
                    if DrawStrBoxYesNo(-1, -1, "血河天魔，一脉相承，是否将武功血河神签洗为天魔功?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 163 then
                                JY.Person[personid]["武功" .. i] = 160
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋内功"] == 163 then
                                    JY.Person[personid]["天赋内功"] = 160
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end	
            --蛤蟆功鲸息功一脉相承
            if id == 308 then
                if PersonKF(personid, 95) and PersonKF(personid, 180) == false then
                    if DrawStrBoxYesNo(-1, -1, "万物有灵，一脉相承，是否将武功蛤蟆功洗为鲸息功?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 95 then
                                JY.Person[personid]["武功" .. i] = 180
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋内功"] == 95 then
                                    JY.Person[personid]["天赋内功"] = 180
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end	
            --神照长生一脉相承
            if id == 342 then
                if PersonKF(personid, 94) and PersonKF(personid, 203) == false then
                    if DrawStrBoxYesNo(-1, -1, "天照长生，一脉相承，是否将武功神照功洗为长生诀?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 94 then
                                JY.Person[personid]["武功" .. i] = 203
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋内功"] == 94 then
                                    JY.Person[personid]["天赋内功"] = 203
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end	
           --玉女剑法 玉女素心剑 一脉相承
           if id == 350 then
                if PersonKF(personid, 42) and PersonKF(personid, 139) == false then
                    if DrawStrBoxYesNo(-1, -1, "玉女素心，一脉相承，是否将武功玉女剑法洗为玉女素心剑法?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 42 then
                                JY.Person[personid]["武功" .. i] = 139
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋外功1"] == 42 then
                                    JY.Person[personid]["天赋外功1"] = 139
                                end
                                if JY.Person[personid]["天赋外功2"] == 42 then
                                    JY.Person[personid]["天赋外功2"] = 139
                                end							
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end		   
            --武当心法 太极神功一脉相承
            if id == 295 then
                if PersonKF(personid, 209) and PersonKF(personid, 171) == false then
                    if DrawStrBoxYesNo(-1, -1, "武当派内功一脉相承，是否将武当心法洗为太极神功?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 209 then
                                JY.Person[personid]["武功" .. i] = 171
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋内功"] == 209 then
                                    JY.Person[personid]["天赋内功"] = 171
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end 
            --少林心法 易筋经一脉相承
            if id == 85 then
                if PersonKF(personid, 208) and PersonKF(personid, 108) == false then
                    if DrawStrBoxYesNo(-1, -1, "少林派内功一脉相承，是否将少林心法洗为易筋经？", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 208 then
                                JY.Person[personid]["武功" .. i] = 108
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Base["标准"] == 6 then
                                    JY.Person[personid]["内力性质"] = 3
                                else
                                    JY.Person[personid]["内力性质"] = 2
                                end
                                if JY.Person[personid]["天赋内功"] == 208 then
                                    JY.Person[personid]["天赋内功"] = 108
                                end
                                yes = 2							
                                break
                            end
                        end
                    end
                end
            end    
            --全真心法 先天功一脉相承
            if id == 77 then
                if PersonKF(personid, 210) and PersonKF(personid, 100) == false then
                    if DrawStrBoxYesNo(-1, -1, "全真教内功一脉相承，是否将全真心法洗为先天功？", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 210 then
                                JY.Person[personid]["武功" .. i] = 100
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋内功"] == 200 then
                                    JY.Person[personid]["天赋内功"] = 100
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end  
                --古墓心法 玉女心经 一脉相承
            if id == 280 then
                if PersonKF(personid, 211) and PersonKF(personid, 154) == false then
                    if DrawStrBoxYesNo(-1, -1, "古墓派内功一脉相承，是否将古墓心法洗为玉女心经？", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 211 then
                                JY.Person[personid]["武功" .. i] = 154
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋内功"] == 211 then
                                    JY.Person[personid]["天赋内功"] = 154
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end
                --华山心法 紫霞神功 一脉相承
            if id == 67 then
                if PersonKF(personid, 212) and PersonKF(personid, 89) == false then
                    if DrawStrBoxYesNo(-1, -1, "华山派内功一脉相承，是否将华山心法洗为紫霞神功？", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 212 then
                                JY.Person[personid]["武功" .. i] = 89
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋内功"] == 212 then
                                    JY.Person[personid]["天赋内功"] = 89
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end  	
                --嵩山心法 寒冰真气 一脉相承
            if id == 366 then
                if PersonKF(personid, 213) and PersonKF(personid, 216) == false then
                    if DrawStrBoxYesNo(-1, -1, "嵩山派内功一脉相承，是否将嵩山心法洗为寒冰真气？", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 213 then
                                JY.Person[personid]["武功" .. i] = 216
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋内功"] == 213 then
                                    JY.Person[personid]["天赋内功"] = 216
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end  
                    --血刀心法 血海魔功 一脉相承
            if id == 285 then
                if PersonKF(personid, 214) and PersonKF(personid, 163) == false then
                    if DrawStrBoxYesNo(-1, -1, "血刀门内功一脉相承，是否将血刀心法洗为血河神签？", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 214 then
                                JY.Person[personid]["武功" .. i] = 163
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋内功"] == 214 then
                                    JY.Person[personid]["天赋内功"] = 163
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end  		
                        --丐帮莲花功 擒龙功 一脉相承
            if id == 351 then
                if PersonKF(personid, 215) and PersonKF(personid, 204) == false then
                    if DrawStrBoxYesNo(-1, -1, "丐帮内功一脉相承，是否将莲花功洗为擒龙功？", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 215 then
                                JY.Person[personid]["武功" .. i] = 204
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋内功"] == 215 then
                                    JY.Person[personid]["天赋内功"] = 204
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end 
             --地火功 圣火神功 一脉相承
            if id == 70 then
                if PersonKF(personid, 217) and PersonKF(personid, 93) == false then
                    if DrawStrBoxYesNo(-1, -1, "明教内功一脉相承，是否将地火功洗为圣火神功？", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 217 then
                                JY.Person[personid]["武功" .. i] = 93
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋内功"] == 217 then
                                    JY.Person[personid]["天赋内功"] = 93
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end 
               --罗汉拳 大金刚掌 一脉相承
           if id == 90 then
                if PersonKF(personid, 1) and PersonKF(personid, 22) == false then
                    if DrawStrBoxYesNo(-1, -1, "少林罗汉堂武功一脉相承，是否将武功罗汉拳法洗为大金刚掌?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["武功数量"] do
                            if JY.Person[personid]["武功" .. i] == 1 then
                                JY.Person[personid]["武功" .. i] = 22
                                JY.Person[personid]["武功等级" .. i] = 50
                                if JY.Person[personid]["天赋外功1"] == 1 then
                                    JY.Person[personid]["天赋外功1"] = 22
                                end
                                if JY.Person[personid]["天赋外功2"] == 1 then
                                    JY.Person[personid]["天赋外功2"] = 22
                                end							
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end	
        
        end
		--如果已经满武功并且选择的武功没有学会，则不可装备修炼
		if yes == 0 and full == 1 then
			DrawStrBoxWaitKey("修炼武功数已达本周目上限", C_WHITE, CC.DefaultFont)
			return 0
		end
    
		--葵花宝典
		if CC.Shemale[id] == 1 then
			--剑神可以直接学
			if (personid == 0 and JY.Base["标准"] == 3) or (personid == 0 and JY.Base["畅想"] == 652 ) or (personid == 0 and JY.Base["畅想"] == 189 ) then
				say("嗯……我看看，这套武功的精妙之处其实不在于是否自宫。看我如何以剑入道克服这个问题！",0,1)
				yes = 1
			--主角打赢葵花尊者，可以直接学
			elseif personid == 0 and CC.TX["笑傲邪线"] == 2 then
				yes = 1
			elseif personid == 92 then
				say("……我还需要切吗？",92,1)
				return 0
			elseif JY.Person[personid]["性别"] == 0 and CanUseThing(id, personid) then
				Cls(CC.MainSubMenuX, CC.MainSubMenuY, CC.ScreenW, CC.ScreenH)
				if DrawStrBoxYesNo(-1, -1, "修炼此书必须先挥刀自宫，是否仍要修炼?", C_WHITE, CC.DefaultFont) == false then
					return 0
				else
					lib.FillColor(0, 0, CC.ScreenW, CC.ScreenH, C_RED, 128)
					ShowScreen()
					lib.Delay(80)
					lib.ShowSlow(15, 1)
					Cls()
					lib.ShowSlow(50, 0)
					JY.Person[personid]["性别"] = 2
					local add, str = AddPersonAttrib(personid, "攻击力", -20)
					DrawStrBoxWaitKey(JY.Person[personid]["姓名"] .. str, C_ORANGE, CC.DefaultFont)
					add, str = AddPersonAttrib(personid, "防御力", -30)
					DrawStrBoxWaitKey(JY.Person[personid]["姓名"] .. str, C_ORANGE, CC.DefaultFont)
					if JY.Base["标准"] > 0 then
						JY.Person[0]["外号"] = "姑娘"
						JY.Person[0]["外号2"] = "丫头"
						local zddh = 227
						local js = JY.Base["标准"]
						local jsdz = JY.Person[0]["头像代号"]
						if js == 3 then
						jsdz = 228
						elseif js == 4 then
						jsdz = 229
						elseif js == 5 then
						jsdz = 230
						else
						jsdz = 227
						   end
						JY.Person[0]["半身像"] = 555+JY.Base["标准"]
						local f_ani = {
                         {0, 0, 0}, 
				         {9, 9, 7}, 
			            {8, 8, 6}, 
				        {8, 8, 6}, 
				        {9, 7, 7}}
						for i = 1, 5 do
							JY.Person[0]["出招动画帧数" .. i] = f_ani[i][1]
							JY.Person[0]["出招动画延迟" .. i] = f_ani[i][3]
							JY.Person[0]["武功音效延迟" .. i] = f_ani[i][2]
						end
					end
				end
	
			elseif JY.Person[personid]["性别"] == 1 then
				DrawStrBoxWaitKey("此人不适合修炼此物品", C_WHITE, CC.DefaultFont)
				return 0
			end
		end


		if yes == 1 or CanUseThing(id, personid) then
			if JY.Thing[id]["使用人"] == personid then
				return 0
			end
			if JY.Person[personid]["修炼物品"] >= 0 then
				JY.Thing[JY.Person[personid]["修炼物品"]]["使用人"] = -1
			end
			if JY.Thing[id]["使用人"] >= 0 then
				JY.Person[JY.Thing[id]["使用人"]]["修炼物品"] = -1
				JY.Person[JY.Thing[id]["使用人"]]["物品修炼点数"] = 0
			end
			JY.Thing[id]["使用人"] = personid
			JY.Person[personid]["修炼物品"] = id
			JY.Person[personid]["物品修炼点数"] = 0
		else
			DrawStrBoxWaitKey("此人不适合修炼此物品", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	return 1
end

--无酒不欢；使用药品和食品
function UseThing_Type3(id)
	local usepersonid = -1
	local amount_use = 0
	Cls()
	if JY.Status == GAME_MMAP or JY.Status == GAME_SMAP then
		--Cls(CC.MainSubMenuX, CC.MainSubMenuY, CC.ScreenW, CC.ScreenH)
		DrawStrBox(CC.MainSubMenuX, CC.MainSubMenuY, string.format("谁要使用%s?", JY.Thing[id]["名称"]), C_WHITE, CC.DefaultFont)
		local nexty = CC.MainSubMenuY + CC.SingleLineHeight
		local r = SelectTeamMenu(CC.MainSubMenuX, nexty)
		if r > 0 then
			usepersonid = JY.Base["队伍" .. r]

	
			--非战斗中可以批量使用
			local max_amount = 0
			for i = 1, CC.MyThingNum do
				if JY.Base["物品" .. i] == id then
					max_amount = JY.Base["物品数量" .. i]
					break;
				end
			end
			amount_use = InputNum("使用数量", 1, max_amount)
		end
	
	--战斗中
	elseif JY.Status == GAME_WMAP then
		--胡青牛可以向队友用药
		if match_ID(WAR.Person[WAR.CurID]["人物编号"], 16) then
			War_CalMoveStep(WAR.CurID, 8, 1)
			local x, y = War_SelectMove()
			if x ~= nil then
				local emeny = GetWarMap(x, y, 2)
				if emeny >= 0 and WAR.Person[WAR.CurID]["我方"] == WAR.Person[emeny]["我方"] then
					usepersonid = WAR.Person[emeny]["人物编号"]
				end
			end
		else
			usepersonid = WAR.Person[WAR.CurID]["人物编号"]
		end
	end

	--战斗中不可使用加血内上限的物品
	if JY.Status == GAME_WMAP and (id >=14 and id <= 21) then
		return 0
	end
	
	if usepersonid >= 0 then
		--非战斗下使用物品
		if JY.Status == GAME_MMAP or JY.Status == GAME_SMAP then

			local r = UseThingEffect(id, usepersonid, amount_use)
			if r == 1 then
				instruct_32(id, -amount_use)
				WaitKey()
			elseif r == 2 then
				instruct_32(id, -amount_use)
			end
			if id == 14 then
                JY.Person[usepersonid]["生命增长"] = JY.Person[usepersonid]["生命增长"]+amount_use
                if JY.Person[usepersonid]["生命增长"] > 12 then
                    JY.Person[usepersonid]["生命增长"] = 12
                end
                Hp_Max(usepersonid)
            end
		--战斗中使用物品
		elseif JY.Status == GAME_WMAP then
			if UseThingEffect(id, usepersonid) == 1 then
				instruct_32(id, -1)
                if id >= 22 and id <= 25 and match_ID(usepersonid, 9965) then 
                    WAR.PD['八酒杯'][usepersonid] = (WAR.PD['八酒杯'][usepersonid] or 0) + 1
                    WAR.PD['回气'][usepersonid] = (WAR.PD['回气'][usepersonid] or 0) + 500
                    CurIDTXDH(WAR.CurID, 79,1,"酒神·八酒杯",C_ORANGE);
                end
			end
		end
	else
		return 0
	end
	return 1
end

--暗器物品
function UseThing_Type4(id)
	if JY.Status == GAME_WMAP then
		return War_UseAnqi(id)
	end
	return 0
end

--------------------------------------------------------------------------------
--------------------------------------事件调用-----------------------------------

--事件调用主入口
--id，d*中的编号
--flag 1 空格触发，2，物品触发，3，路过触发
function EventExecute(id,flag)
    JY.CurrentD=id;

    oldEventExecute(flag)

    JY.CurrentD=-1;
end

--调用原有的指定位置的函数
--旧的函数名字格式为  oldevent_xxx();  xxx为事件编号
function oldEventExecute(flag)
	local eventnum = nil
	if flag == 1 then
		eventnum = GetD(JY.SubScene, JY.CurrentD, 2)
	elseif flag == 2 then
		eventnum = GetD(JY.SubScene, JY.CurrentD, 3)
	elseif flag == 3 then
		eventnum = GetD(JY.SubScene, JY.CurrentD, 4)
	end
	if eventnum > 0 then
			lib.Debug(eventnum.."");
		end
	if eventnum > 0 then
		CallCEvent(eventnum)  
	end
end

function existFile(filename)
    local f = io.open(filename)
    if f == nil then
        return false
    end
    io.close(f)
    return true
end
--[[
function CallCEvent(eventnum)
	local eventfilename = string.format("%s%d.lua", CONFIG.CEventPath,eventnum)
	if existFile(eventfilename) then
		dofile(eventfilename)
		return true
	else
		return false
	end
end
]]
function CallCEvent(eventnum)
	if newkdef[eventnum]~=nil then--首先判断这个事件编号是否存在
		lib.Debug("new kdef "..eventnum)--如果存在，在执行事件前，在debug文本里打印出  new kdef +事件标号，以便调试时使用
		if eventnum>0 then--如果事件编号大于0
			newkdef[eventnum]()--执行该事件
		end
	end
end

--改变大地图坐标，从场景出去后移动到相应坐标
function ChangeMMap(x,y,direct)          --改变大地图坐标
	JY.Base["人X"]=x;
	JY.Base["人Y"]=y;
	JY.Base["人方向"]=direct;
end

--改变当前场景
function ChangeSMap(sceneid,x,y,direct)       --改变当前场景
    JY.SubScene=sceneid;
	JY.Base["人X1"]=x;
	JY.Base["人Y1"]=y;
	JY.Base["人方向"]=direct;
end


--清除(x1,y1)-(x2,y2)矩形内的文字等。
--如果没有参数，则清除整个屏幕表面
--注意该函数并不直接刷新显示屏幕
function Cls(x1,y1,x2,y2)                    --清除屏幕
    if x1==nil then        --第一个参数为nil,表示没有参数，用缺省
	    x1=0;
		y1=0;
		x2=CC.ScreenW;
		y2=CC.ScreenH;
	end

	lib.SetClip(x1,y1,x2,y2);

	if JY.Status==GAME_START then
	    lib.FillColor(0,0,0,0,0);
        lib.LoadPicture(CC.FirstFile,-1,-1);
	elseif JY.Status==GAME_MMAP then
        lib.DrawMMap(JY.Base["人X"],JY.Base["人Y"],GetMyPic());             --显示主地图
	elseif JY.Status==GAME_SMAP then
        DrawSMap();
	elseif JY.Status==GAME_WMAP then
        WarDrawMap(0);
	elseif JY.Status==GAME_DEAD then
	    lib.FillColor(0,0,0,0,0);
        lib.LoadPicture(CC.DeadFile,-1,-1);
    else 
        lib.FillColor(0, 0, 0, 0, 0)
	end
	lib.SetClip(0,0,CC.ScreenW,CC.ScreenH);
end


--产生对话显示需要的字符串，即每隔n个中文字符加一个星号
function GenTalkString(str,n)             					 --产生对话显示需要的字符串
    local tmpstr="";
    for s in string.gmatch(str .. "*","(.-)%*") do           --去掉对话中的所有*. 字符串尾部加一个星号，避免无法匹配
        tmpstr=tmpstr .. s;
    end

    local newstr="";
    while #tmpstr>0 do
		local w=0;
		while w<#tmpstr do
		    local v=string.byte(tmpstr,w+1);	--当前字符的值
			if v>=128 then
			    w=w+2;
			else
			    w=w+1;
			end
			if w >= 2*n-1 then					--为了避免跨段中文字符
			    break;
			end
		end

        if w<#tmpstr then
		    if w==2*n-1 and string.byte(tmpstr,w+1)<128 then
				newstr=newstr .. string.sub(tmpstr,1,w+1) .. "*";
				tmpstr=string.sub(tmpstr,w+2,-1);
			else
				newstr=newstr .. string.sub(tmpstr,1,w)  .. "*";
				tmpstr=string.sub(tmpstr,w+1,-1);
			end
		else
		    newstr=newstr .. tmpstr;
			break;
		end
	end
    return newstr;
end

--个人新对话
function TalkEx(s,pid,flag,name)
	say(s,pid,flag,name)
end

--测试指令，占位置用
function instruct_test(s)
    DrawStrBoxWaitKey(s,C_ORANGE,24);
end

--清屏
function instruct_0()         --清屏
    Cls();
end

function ReadTalk(id, flag)
	local tidx = Byte.create(id * 4 + 4)
	Byte.loadfile(tidx, CC.TDX, 0, id * 4 + 4)
	local idx1, idx2 = nil, nil
	if id < 1 then
		idx1 = 0
	else
		idx1 = Byte.get32(tidx, (id - 1) * 4)
	end
	idx2 = Byte.get32(tidx, id * 4)
	local len = idx2 - idx1
	local talk = Byte.create(len)
	Byte.loadfile(talk, CC.TRP, idx1, len)
	local str = ""
	for i = 0, len - 2 do
		local byte = Byte.getu16(talk, i)
		byte = 255 - math.fmod(byte, 256)
		str = str .. string.char(byte)
	end
	if flag == nil then
		str = lib.CharSet(str, 0)
		str = GenTalkString(str, 12)
	end
	return str
end

--对话
--talkid: 为数字，则为对话编号；为字符串，则为对话本身。
--headid: 头像id
--flag :对话框位置：0 屏幕上方显示, 左边头像，右边对话
--            1 屏幕下方显示, 左边对话，右边头像
--            2 屏幕上方显示, 左边空，右边对话
--            3 屏幕下方显示, 左边对话，右边空
--            4 屏幕上方显示, 左边对话，右边头像
--            5 屏幕下方显示, 左边头像，右边对话
function instruct_1(talkid, headid, flag)
	local s = ReadTalk(talkid)
	if s == nil then
		return 
	end
	TalkEx(s, headid, flag)
end

--得到物品
function instruct_2(thingid, num)
	if JY.Thing[thingid] == nil then
		return 
	end
	instruct_32(thingid, num)
	if num > 0 then
		DrawStrBoxWaitKey(string.format("得到物品%sX%d", "【Ｇ"..JY.Thing[thingid]["名称"].."Ｏ】", num), C_ORANGE, CC.DefaultFont, 1)
	else
		DrawStrBoxWaitKey(string.format("失去物品%sX%d", "【Ｇ"..JY.Thing[thingid]["名称"].."Ｏ】", -num), C_ORANGE, CC.DefaultFont, 1)
	end
	if thingid >= CC.BookStart and thingid < CC.BookStart + CC.BookNum then
		instruct_2(174, 5000)
	end
end

--修改指定场景坐标的事件
function instruct_3(sceneid, id, v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10)
	if JY.Restart == 1 then
		return
	end
  if sceneid == -2 then
    sceneid = JY.SubScene
  end
  if id == -2 then
    id = JY.CurrentD
  end
  if v0 ~= -2 then
    SetD(sceneid, id, 0, v0)
  end
  if v1 ~= -2 then
    SetD(sceneid, id, 1, v1)
  end
  if v2 ~= -2 then
    SetD(sceneid, id, 2, v2)
  end
  if v3 ~= -2 then
    SetD(sceneid, id, 3, v3)
  end
  if v4 ~= -2 then
    SetD(sceneid, id, 4, v4)
  end
  if v5 ~= -2 then
    SetD(sceneid, id, 5, v5)
  end
  if v6 ~= -2 then
    SetD(sceneid, id, 6, v6)
  end
  if v7 ~= -2 then
    SetD(sceneid, id, 7, v7)
  end
  if v8 ~= -2 then
    SetD(sceneid, id, 8, v8)
  end
  if v9 ~= -2 and v10 ~= -2 and v9 > 0 and v10 > 0 then
    SetS(sceneid, GetD(sceneid, id, 9), GetD(sceneid, id, 10), 3, -1)
    SetD(sceneid, id, 9, v9)
    SetD(sceneid, id, 10, v10)
    SetS(sceneid, GetD(sceneid, id, 9), GetD(sceneid, id, 10), 3, id)
  end
end

function instruct_4(thingid)
	if JY.CurrentThing == thingid then
		JY.ThingUse = thingid
		return true
	else
		return false
	end
end

function instruct_5()
	return DrawStrBoxYesNo(-1, -1, "是否与之过招(Y/N)?", C_ORANGE, CC.DefaultFont)
end

function instruct_6(warid, tmp, tmp, flag)
	return WarMain(warid, flag)
end

function instruct_7()
	instruct_test("指令7测试")
end

function instruct_8(musicid)
	JY.MmapMusic = musicid
end

function instruct_9()
	return DrawStrBoxYesNo(-1, -1, "是否要求加入(Y/N)?", C_ORANGE, CC.DefaultFont)
end

--入队函数
function instruct_10(personid)
	if JY.Person[personid] == nil then
		lib.Debug("instruct_10 error: person id not exist")
		return 
	end
	local add = 0
	--无酒不欢：畅想不能收自己
	if personid ~= JY.Base["畅想"] then
		for i = 2, CC.TeamNum do
			if JY.Base["队伍" .. i] < 0 then
			  JY.Base["队伍" .. i] = personid
			  add = 1
			  break;
			end
		end
	end
	for i = 1, 4 do
		local id = JY.Person[personid]["携带物品" .. i]
		local n = JY.Person[personid]["携带物品数量" .. i]
		if n < 0 then
			n = 0
		end
		if id >= 0 and n > 0 then
			instruct_2(id, n)
			JY.Person[personid]["携带物品" .. i] = -1
			JY.Person[personid]["携带物品数量" .. i] = 0
		end
	end
	if add == 0 then
		lib.Debug("instruct_10 error: 加入队伍已满")
		return
	end
end

function instruct_11()
	return DrawStrBoxYesNo(-1, -1, "是否(Y/N)?", C_ORANGE, CC.DefaultFont)
end

--休息
function instruct_12(flag)
	for i = 1, CC.TeamNum do
		local id = JY.Base["队伍" .. i]
		if id >= 0 then
			JY.Person[id]["受伤程度"] = 0
			JY.Person[id]["中毒程度"] = 0
			AddPersonAttrib(id, "体力", math.huge)
			AddPersonAttrib(id, "生命", math.huge)
			AddPersonAttrib(id, "内力", math.huge)
		end
	end
end

--dark
function instruct_13()
	if JY.Restart == 1 then
		return
	end
	Cls()
	JY.Darkness = 0
	lib.ShowSlow(20, 0)
	lib.GetKey()
end

--light
function instruct_14()
	if JY.Restart == 1 then
		return
	end
	lib.ShowSlow(20, 1)
	JY.Darkness = 1
end

function instruct_15()
	JY.Status = GAME_DEAD
	Cls()
	DrawString(CC.GameOverX, CC.GameOverY, JY.Person[0]["姓名"], RGB(0, 0, 0), CC.DefaultFont)
	local x = CC.ScreenW - 9 * CC.DefaultFont
	DrawString(x, 10, os.date("%Y-%m-%d %H:%M"), RGB(216, 20, 24), CC.DefaultFont)
	DrawString(x, 10 + CC.DefaultFont + CC.RowPixel, "在地球的某处", RGB(216, 20, 24), CC.DefaultFont)
	DrawString(x, 10 + (CC.DefaultFont + CC.RowPixel) * 2, "当地人口的失踪数", RGB(216, 20, 24), CC.DefaultFont)
	DrawString(x, 10 + (CC.DefaultFont + CC.RowPixel) * 3, "又多了一笔。。。", RGB(216, 20, 24), CC.DefaultFont)
	local loadMenu = {
	{"选择读档", nil, 1},  
	{"回家睡觉去", nil, 1}}
	local y = CC.ScreenH - 4 * (CC.DefaultFont + CC.RowPixel) - 10
	local sl = ShowMenu(loadMenu, #loadMenu, 0, x, y, 0, 0, 0, 0, CC.DefaultFont, C_ORANGE, C_WHITE)
	if sl ==1 then
		local r = SaveList();
			if r < 1 then
				JY.Status = GAME_END
				return 0;
			end
			
			Cls();
			DrawStrBox(-1,CC.StartMenuY,"请稍候...",C_GOLD,CC.DefaultFont);
			ShowScreen();
			local result = LoadRecord(r);
			if result ~= nil then
				instruct_15();
				return 0;
			end
		if JY.Base["无用"] ~= -1 then
			JY.Status = GAME_SMAP
			JY.SubScene = JY.Base["无用"]
			JY.MmapMusic = -1
			JY.MyPic = GetMyPic()
			Init_SMap(1)
		else
			JY.SubScene = -1
			JY.Status = GAME_FIRSTMMAP
		end
		ShowScreen()
		lib.LoadPicture("", 0, 0)
		lib.GetKey()
		Game_Cycle()
	else
		JY.Status = GAME_END
	end
end

function inteam(pid)
	return instruct_16(pid)
end

function instruct_16(personid)
	local r = false
	local xwperson;	--判定人物
	--非战斗中才生效，用于触发剧情等判定
	if personid == JY.Base["畅想"] and JY.Status ~= GAME_WMAP then
		xwperson = 0
	else
		xwperson = personid
	end
	for i = 1, CC.TeamNum do
		if xwperson == JY.Base["队伍" .. i] then
			r = true
			break;
		end
	end
	return r
end

function instruct_17(sceneid, level, x, y, v)
	if sceneid == -2 then
		sceneid = JY.SubScene
	end
	SetS(sceneid, x, y, level, v)
end

function instruct_18(thingid)
	for i = 1, CC.MyThingNum do
		if JY.Base["物品" .. i] == thingid then
			return true
		end
	end
	return false
end

function instruct_19(x, y)
	JY.Base["人X1"] = x
	JY.Base["人Y1"] = y
	JY.SubSceneX = 0
	JY.SubSceneY = 0
end

function instruct_20()
	if JY.Base["队伍" .. CC.TeamNum] >= 0 then
		return true
	end
	return false
end

--离队函数
function instruct_21(personid)
	if JY.Person[personid] == nil then
		lib.Debug("instruct_21 error: personid not exist")
		return 
	end
	local j = 0
	for i = 1, CC.TeamNum do
		if personid == JY.Base["队伍" .. i] then
		  j = i
		end
	end
	if j == 0 then
		return 
	end
	for i = j + 1, CC.TeamNum do
		JY.Base["队伍" .. i - 1] = JY.Base["队伍" .. i]
	end
	JY.Base["队伍" .. CC.TeamNum] = -1
	if JY.Person[personid]["武器"] >= 0 then
		JY.Thing[JY.Person[personid]["武器"]]["使用人"] = -1
		JY.Person[personid]["武器"] = -1
	end
	if JY.Person[personid]["防具"] >= 0 then
		JY.Thing[JY.Person[personid]["防具"]]["使用人"] = -1
		JY.Person[personid]["防具"] = -1
	end
	if JY.Person[personid]["坐骑"] >= 0 then
		JY.Thing[JY.Person[personid]["坐骑"]]["使用人"] = -1
		JY.Person[personid]["坐骑"] = -1
	end	
	if JY.Person[personid]["修炼物品"] >= 0 then
		JY.Thing[JY.Person[personid]["修炼物品"]]["使用人"] = -1
		JY.Person[personid]["修炼物品"] = -1
	end
	JY.Person[personid]["物品修炼点数"] = 0
end

function instruct_22()
	for i = 1, CC.TeamNum do
		if JY.Base["队伍" .. i] >= 0 then
			JY.Person[JY.Base["队伍" .. i]]["内力"] = 0
		end
	end
end

function instruct_23(personid, value)
	JY.Person[personid]["用毒能力"] = value
	AddPersonAttrib(personid, "用毒能力", 0)
end

function instruct_24()
	instruct_test("指令24测试")
end

--镜头移动
function instruct_25(x1, y1, x2, y2)
	if JY.Restart == 1 then
		return
	end
	local sign = nil
	if y1 ~= y2 then
		if y2 < y1 then
			sign = -1
		else
			sign = 1
		end
		for i = y1 + sign, y2, sign do
			lib.GetKey()
			local t1 = lib.GetTime()
			JY.SubSceneY = JY.SubSceneY + sign
			DrawSMap()
			ShowScreen()
			local t2 = lib.GetTime()
			if t2 - t1 < CC.SceneMoveFrame then
				lib.Delay(CC.SceneMoveFrame - (t2 - t1))
			end
		end
	end
	if x1 ~= x2 then
		if x2 < x1 then
			sign = -1
		else
			sign = 1
		end
		for i = x1 + sign, x2, sign do
			lib.GetKey()
			local t1 = lib.GetTime()
			JY.SubSceneX = JY.SubSceneX + sign
			DrawSMap()
			ShowScreen()
			local t2 = lib.GetTime()
			if t2 - t1 < CC.SceneMoveFrame then
				lib.Delay(CC.SceneMoveFrame - (t2 - t1))
			end
		end
	end
end

function instruct_26(sceneid, id, v1, v2, v3)
	if sceneid == -2 then
		sceneid = JY.SubScene
	end
	local v = GetD(sceneid, id, 2)
	SetD(sceneid, id, 2, v + v1)
	v = GetD(sceneid, id, 3)
	SetD(sceneid, id, 3, v + v2)
	v = GetD(sceneid, id, 4)
	SetD(sceneid, id, 4, v + v3)
end

function instruct_27(id, startpic, endpic)
	local old1, old2, old3 = nil
	if id ~= -1 then
		old1 = GetD(JY.SubScene, id, 5)
		old2 = GetD(JY.SubScene, id, 6)
		old3 = GetD(JY.SubScene, id, 7)
	end
	for i = startpic, endpic, 2 do
		lib.GetKey()
		local t1 = lib.GetTime()
		if id == -1 then
			JY.MyPic = i / 2
		else
			SetD(JY.SubScene, id, 5, i)
			SetD(JY.SubScene, id, 6, i)
			SetD(JY.SubScene, id, 7, i)
		end
		DtoSMap()
		DrawSMap()
		ShowScreen()
		local t2 = lib.GetTime()
		if t2 - t1 < CC.AnimationFrame then
			lib.Delay(CC.AnimationFrame - (t2 - t1))
		end
	end
	if id ~= -1 then
		SetD(JY.SubScene, id, 5, old1)
		SetD(JY.SubScene, id, 6, old2)
		SetD(JY.SubScene, id, 7, old3)
	end
end

function instruct_28(personid, vmin, vmax)
	local v = JY.Person[personid]["品德"]
	if vmin <= v and v <= vmax then
		return true
	else
		return false
	end
end

function instruct_29(personid, vmin, vmax)
	local v = JY.Person[personid]["攻击力"]
	if vmin <= v and v <= vmax then
		return true
	else
		return false
	end
end

--人物自动移动
function instruct_30(x1, y1, x2, y2)
	if JY.Restart == 1 then
		return
	end
  if x1 < x2 then
    for i = x1 + 1, x2 do
      local t1 = lib.GetTime()
      instruct_30_sub1(1)
      local t2 = lib.GetTime()
      if t2 - t1 < CC.PersonMoveFrame then
        lib.Delay(CC.PersonMoveFrame - (t2 - t1))
      end
    end
  elseif x2 < x1 then
    for i = x2 + 1, x1 do
      local t1 = lib.GetTime()
      instruct_30_sub1(2)
      local t2 = lib.GetTime()
      if t2 - t1 < CC.PersonMoveFrame then
        lib.Delay(CC.PersonMoveFrame - (t2 - t1))
      end
    end
  end
  if y1 < y2 then
    for i = y1 + 1, y2 do
      local t1 = lib.GetTime()
      instruct_30_sub1(3)
      local t2 = lib.GetTime()
      if t2 - t1 < CC.PersonMoveFrame then
        lib.Delay(CC.PersonMoveFrame - (t2 - t1))
      end
    end
  elseif y2 < y1 then
    for i = y2 + 1, y1 do
      local t1 = lib.GetTime()
      instruct_30_sub1(0)
      local t2 = lib.GetTime()
      if t2 - t1 < CC.PersonMoveFrame then
        lib.Delay(CC.PersonMoveFrame - (t2 - t1))
      end
    end
  end
end

function instruct_30_sub1(direct)
  local x, y = nil, nil
  AddMyCurrentPic()
  x = JY.Base["人X1"] + CC.DirectX[direct + 1]
  y = JY.Base["人Y1"] + CC.DirectY[direct + 1]
  JY.Base["人方向"] = direct
  JY.MyPic = GetMyPic()
  DtoSMap()
  if SceneCanPass(x, y) == true then
    JY.Base["人X1"] = x
    JY.Base["人Y1"] = y
  end
  JY.Base["人X1"] = limitX(JY.Base["人X1"], 1, CC.SWidth - 2)
  JY.Base["人Y1"] = limitX(JY.Base["人Y1"], 1, CC.SHeight - 2)
  DrawSMap()
  ShowScreen()
  return 1
end

function instruct_30_sub(direct)
  local x, y = nil, nil
  local d_pass = GetS(JY.SubScene, JY.Base["人X1"], JY.Base["人Y1"], 3)

  if d_pass >= 0 and d_pass ~= JY.OldDPass then
    EventExecute(d_pass, 3)
    JY.OldDPass = d_pass
    JY.oldSMapX = -1
    JY.oldSMapY = -1
    JY.D_Valid = nil
  end

  JY.OldDPass = -1
  local isout = 0
  if (((JY.Scene[JY.SubScene]["出口X1"] == JY.Base["人X1"] and JY.Scene[JY.SubScene]["出口Y1"] == JY.Base["人Y1"]) or JY.Scene[JY.SubScene]["出口X2"] ~= JY.Base["人X1"] or JY.Scene[JY.SubScene]["出口Y2"] == JY.Base["人Y1"] or JY.Scene[JY.SubScene]["出口X3"] == JY.Base["人X1"] and JY.Scene[JY.SubScene]["出口Y3"] == JY.Base["人Y1"])) then
    isout = 1
  end
  if isout == 1 then
    JY.Status = GAME_MMAP
    --lib.PicInit()
    CleanMemory()
    lib.ShowSlow(20, 1)
    if JY.MmapMusic < 0 then
      JY.MmapMusic = JY.Scene[JY.SubScene]["出门音乐"]
    end
    Init_MMap()
    JY.SubScene = -1
    JY.oldSMapX = -1
    JY.oldSMapY = -1
    lib.DrawMMap(JY.Base["人X"], JY.Base["人Y"], GetMyPic())
    lib.ShowSlow(20, 0)
    lib.GetKey()
    return 
  end
  if JY.Scene[JY.SubScene]["跳转场景"] >= 0 and JY.Base["人X1"] == JY.Scene[JY.SubScene]["跳转口X1"] and JY.Base["人Y1"] == JY.Scene[JY.SubScene]["跳转口Y1"] then
    JY.SubScene = JY.Scene[JY.SubScene]["跳转场景"]
    lib.ShowSlow(20, 1)
    if JY.Scene[JY.SubScene]["外景入口X1"] == 0 and JY.Scene[JY.SubScene]["外景入口Y1"] == 0 then
      JY.Base["人X1"] = JY.Scene[JY.SubScene]["入口X"]
      JY.Base["人Y1"] = JY.Scene[JY.SubScene]["入口Y"]
    else
      JY.Base["人X1"] = JY.Scene[JY.SubScene]["跳转口X2"]
      JY.Base["人Y1"] = JY.Scene[JY.SubScene]["跳转口Y2"]
    end
    Init_SMap(1)
    return 
  end
  AddMyCurrentPic()
  x = JY.Base["人X1"] + CC.DirectX[direct + 1]
  y = JY.Base["人Y1"] + CC.DirectY[direct + 1]
  JY.Base["人方向"] = direct
  JY.MyPic = GetMyPic()
  DtoSMap()
  if SceneCanPass(x, y) == true then
    JY.Base["人X1"] = x
    JY.Base["人Y1"] = y
  end
  JY.Base["人X1"] = limitX(JY.Base["人X1"], 1, CC.SWidth - 2)
  JY.Base["人Y1"] = limitX(JY.Base["人Y1"], 1, CC.SHeight - 2)
  DrawSMap()
  ShowScreen()
  return 1
end

--计算钱是否足够
function instruct_31(num)
	local r = false
    if num <= CC.Gold then 
        return true    
    end
	return r
end

--增加，减少物品的函数
function instruct_32(thingid, num)
	local p = 1
	--首先控制获取数量，超过30000自动算30000
	for i = 1, CC.MyThingNum do
		if JY.Base["物品" .. i] == thingid then
			if thingid == 174 then 
				--JY.Base["物品数量" .. i] = 0
				p = i
				break;
			else
			    --已经有一定数量的物品，如果相加之后超过30000，按30000算
			    if (JY.Base["物品数量" .. i] + num) > 30000 then
				    JY.Base["物品数量" .. i] = 30000
			    else
				    JY.Base["物品数量" .. i] = JY.Base["物品数量" .. i] + num
			    end
			    p = i
			    break;
			end	
		elseif JY.Base["物品" .. i] == -1 then
			if thingid == 174 then 
				JY.Base["物品" .. i] = thingid
				--JY.Base["物品数量" .. i] = 0
				p = i
				break;
			else	
			    JY.Base["物品" .. i] = thingid
			    JY.Base["物品数量" .. i] = num
			    p = i
			    break;
			end
		end
	end
	
	--获取银两的时候刷新银两显示
	if thingid == CC.MoneyID then
		CC.Gold = CC.Gold + num--JY.Base["物品数量" .. p]
		if CC.Gold < 0 then 
			CC.Gold = 0
		end
	end
  
  
	--获得天书，增加15点声望
	--获得的时候才增加
	if num > 0 and thingid >= CC.BookStart and thingid < CC.BookStart + CC.BookNum then
		JY.Person[0]["声望"] = JY.Person[0]["声望"] + 15;
		JY.Base["天书数量"] = JY.Base["天书数量"] + 1
		--无酒不欢：用520号人物的品德判定可以摘取的蟠桃数量
		--替换蟠桃树贴图
		JY.Person[520]["品德"] = JY.Person[520]["品德"] + 1
		--在已经种过树的情况下，树会结果，用521号人物的品德判定是否已触发种树事件
		if JY.Person[521]["品德"] == 1 then
			addevent(70, 65, 1, 4119, 1, 2366*2)
		end

	end
	
	if JY.Base["物品数量" .. p] <= 0 then
        if thingid == 174 then
            if CC.Gold <= 0 then
                for i = p + 1, CC.MyThingNum do
                    JY.Base["物品" .. i - 1] = JY.Base["物品" .. i]
                    JY.Base["物品数量" .. i - 1] = JY.Base["物品数量" .. i]
                end
                JY.Base["物品" .. CC.MyThingNum] = -1
                JY.Base["物品数量" .. CC.MyThingNum] = 0
            end    
		else
		    for i = p + 1, CC.MyThingNum do
		        JY.Base["物品" .. i - 1] = JY.Base["物品" .. i]
		        JY.Base["物品数量" .. i - 1] = JY.Base["物品数量" .. i]
		    end
			JY.Base["物品" .. CC.MyThingNum] = -1
			JY.Base["物品数量" .. CC.MyThingNum] = 0
		end
	end
end

--人物学会武功
function instruct_33(personid, wugongid, flag)
	local xwperson;	--判定要洗武功的人
	xwperson = personid

	local add = 0
	for i = 1, JY.Base["武功数量"] do
		if JY.Person[xwperson]["武功" .. i] == 0 then
			JY.Person[xwperson]["武功" .. i] = wugongid
			JY.Person[xwperson]["武功等级" .. i] = 0
			add = 1		
			break;
		end
	end
	if add == 0 then
		JY.Person[xwperson]["武功"..JY.Base["武功数量"]] = wugongid
		JY.Person[xwperson]["武功等级"..JY.Base["武功数量"]] = 0
	end
    if isteam(xwperson) then 
        Hp_Max(xwperson)
    end
	if personid == JY.Base["畅想"] or personid == 0 then
		xwperson = 0
		local add = 0
		for i = 1, JY.Base["武功数量"] do
			if JY.Person[xwperson]["武功" .. i] == 0 then
				JY.Person[xwperson]["武功" .. i] = wugongid
				JY.Person[xwperson]["武功等级" .. i] = 0
				add = 1		
				break;
			end
		end
		if add == 0 then
			JY.Person[xwperson]["武功"..JY.Base["武功数量"]] = wugongid
			JY.Person[xwperson]["武功等级"..JY.Base["武功数量"]] = 0
		end
        Hp_Max(xwperson)
	end
	
	for i,v in pairs(CC.Copy) do 
		if v == personid then
			xwperson = i
            local add = 0
            for i = 1, JY.Base["武功数量"] do
                if JY.Person[xwperson]["武功" .. i] == 0 then
                    JY.Person[xwperson]["武功" .. i] = wugongid
                    JY.Person[xwperson]["武功等级" .. i] = 0
                    add = 1		
                    break;
                end
            end
            if add == 0 then
                JY.Person[xwperson]["武功"..JY.Base["武功数量"]] = wugongid
                JY.Person[xwperson]["武功等级"..JY.Base["武功数量"]] = 0
            end
			break
		end
	end
	
	if flag == 0 then
		DrawStrBoxWaitKey(string.format("%s 学会武功 %s", JY.Person[xwperson]["姓名"], JY.Wugong[wugongid]["名称"]), C_ORANGE, CC.DefaultFont)
	end
	
end

--改变资质
function instruct_34(id, value)
	local xwperson;	--判定人物
	if id == JY.Base["畅想"] then
		xwperson = 0
	else
		xwperson = id
	end
	local add, str = AddPersonAttrib(xwperson, "资质", value)
	DrawStrBoxWaitKey(JY.Person[xwperson]["姓名"] .. str, C_ORANGE, CC.DefaultFont)
end

--洗武功函数
function instruct_35(personid, id, wugongid, wugonglevel)
	local xwperson;	--判定要洗武功的人
	xwperson = personid
	--被洗掉的武功从自动列表清除
	if JY.Person[xwperson]["武功" .. id + 1] > 0 then
		if JY.Person[xwperson]["武功" .. id + 1] == JY.Person[xwperson]["优先使用"] then
			JY.Person[xwperson]["优先使用"] = 0
		elseif JY.Person[xwperson]["武功" .. id + 1] == JY.Person[xwperson]["主运内功"] then
			JY.Person[xwperson]["主运内功"] = 0
		elseif JY.Person[xwperson]["武功" .. id + 1] == JY.Person[xwperson]["主运轻功"] then
			JY.Person[xwperson]["主运轻功"] = 0
		end
	end
    if isteam(xwperson) then 
        Hp_Max(xwperson)
    end
	JY.Person[xwperson]["武功" .. id + 1] = wugongid
	JY.Person[xwperson]["武功等级" .. id + 1] = wugonglevel
	
	if personid == JY.Base["畅想"] or personid == 0 then
		xwperson = 0
		--被洗掉的武功从自动列表清除
		if JY.Person[xwperson]["武功" .. id + 1] > 0 then
			if JY.Person[xwperson]["武功" .. id + 1] == JY.Person[xwperson]["优先使用"] then
				JY.Person[xwperson]["优先使用"] = 0
			elseif JY.Person[xwperson]["武功" .. id + 1] == JY.Person[xwperson]["主运内功"] then
				JY.Person[xwperson]["主运内功"] = 0
			elseif JY.Person[xwperson]["武功" .. id + 1] == JY.Person[xwperson]["主运轻功"] then
				JY.Person[xwperson]["主运轻功"] = 0
			end
		end
		JY.Person[xwperson]["武功" .. id + 1] = wugongid
		JY.Person[xwperson]["武功等级" .. id + 1] = wugonglevel
        Hp_Max(xwperson)
	end
	
	for i,v in pairs(CC.Copy) do 
		if v == personid then
		--if CC.Copy[personid] ~= nil then 
			xwperson = i
			--被洗掉的武功从自动列表清除
			if JY.Person[xwperson]["武功" .. id + 1] > 0 then
				if JY.Person[xwperson]["武功" .. id + 1] == JY.Person[xwperson]["优先使用"] then
					JY.Person[xwperson]["优先使用"] = 0
				elseif JY.Person[xwperson]["武功" .. id + 1] == JY.Person[xwperson]["主运内功"] then
					JY.Person[xwperson]["主运内功"] = 0
				elseif JY.Person[xwperson]["武功" .. id + 1] == JY.Person[xwperson]["主运轻功"] then
					JY.Person[xwperson]["主运轻功"] = 0
				end
			end
			JY.Person[xwperson]["武功" .. id + 1] = wugongid
			JY.Person[xwperson]["武功等级" .. id + 1] = wugonglevel
			break
		end
	end
    
end

function instruct_36(sex)
	if JY.Person[0]["性别"] == sex then
		return true
	else
		return false
	end
end

--无酒不欢：加减道德显示
function instruct_37(v)
	AddPersonAttrib(0, "品德", v)
	if v < 0 then
		for i = 1, 15 do
			if JY.Restart == 1 then
				break
			end
			local y_off = i * 2 + CC.DefaultFont + CC.RowPixel
			DrawString(CC.ScreenW/2-CC.DefaultFont*5, CC.ScreenH/4 - CC.DefaultFont - CC.RowPixel + y_off, "你的道德指数下降了"..-v.."点", M_DeepSkyBlue, CC.DefaultFont)
			ShowScreen()		  
			lib.Delay(50)
			Cls()
		end
	else
		for i = 1, 15 do
			if JY.Restart == 1 then
				break
			end
			local y_off = i * 2 + CC.DefaultFont + CC.RowPixel
			DrawString(CC.ScreenW/2-CC.DefaultFont*5, CC.ScreenH/4 + 30 + CC.DefaultFont + CC.RowPixel - y_off, "你的道德指数提升了"..v.."点", PinkRed, CC.DefaultFont)
			ShowScreen()		  
			lib.Delay(50)
			Cls()
		end
	end
end

function instruct_38(sceneid, level, oldpic, newpic)
	if sceneid == -2 then
		sceneid = JY.SubScene
	end
	for i = 0, CC.SWidth - 1 do
		for j = 1, CC.SHeight - 1 do
			if GetS(sceneid, i, j, level) == oldpic then
				SetS(sceneid, i, j, level, newpic)
			end
		end
	end
end

function instruct_39(sceneid)
	JY.Scene[sceneid]["进入条件"] = 0
end

function instruct_40(v)
	JY.Base["人方向"] = v
	JY.MyPic = GetMyPic()
end

function instruct_41(personid, thingid, num)
	local k = 0
	for i = 1, 4 do
		if JY.Person[personid]["携带物品" .. i] == thingid then
			JY.Person[personid]["携带物品数量" .. i] = JY.Person[personid]["携带物品数量" .. i] + num
			k = i
			break;
		end
	end
	if k > 0 and JY.Person[personid]["携带物品数量" .. k] <= 0 then
		JY.Person[personid]["携带物品" .. k] = -1
	end
	if k == 0 then
		for i = 1, 4 do
			if JY.Person[personid]["携带物品" .. i] == -1 then
				JY.Person[personid]["携带物品" .. i] = thingid
				JY.Person[personid]["携带物品数量" .. i] = num
				break;
			end
		end
	end
end

function instruct_42()
	local r = false
	for i = 1, CC.TeamNum do
		if JY.Base["队伍" .. i] >= 0 and JY.Person[JY.Base["队伍" .. i]]["性别"] == 1 then
			r = true
		end
	end
	return r
end

function instruct_43(thingid)
	return instruct_18(thingid)
end

function instruct_44(id1, startpic1, endpic1, id2, startpic2, endpic2)
  local old1 = GetD(JY.SubScene, id1, 5)
  local old2 = GetD(JY.SubScene, id1, 6)
  local old3 = GetD(JY.SubScene, id1, 7)
  local old4 = GetD(JY.SubScene, id2, 5)
  local old5 = GetD(JY.SubScene, id2, 6)
  local old6 = GetD(JY.SubScene, id2, 7)
  for i = startpic1, endpic1, 2 do
	lib.GetKey()
    local t1 = lib.GetTime()
    if id1 == -1 then
      JY.MyPic = i / 2
    else
      SetD(JY.SubScene, id1, 5, i)
      SetD(JY.SubScene, id1, 6, i)
      SetD(JY.SubScene, id1, 7, i)
    end
    if id2 == -1 then
      JY.MyPic = i / 2
    else
      SetD(JY.SubScene, id2, 5, i - startpic1 + startpic2)
      SetD(JY.SubScene, id2, 6, i - startpic1 + startpic2)
      SetD(JY.SubScene, id2, 7, i - startpic1 + startpic2)
    end
    DtoSMap()
    DrawSMap()
    ShowScreen()
    local t2 = lib.GetTime()
    if t2 - t1 < CC.AnimationFrame then
      lib.Delay(CC.AnimationFrame - (t2 - t1))
    end
  end
  SetD(JY.SubScene, id1, 5, old1)
  SetD(JY.SubScene, id1, 6, old2)
  SetD(JY.SubScene, id1, 7, old3)
  SetD(JY.SubScene, id2, 5, old4)
  SetD(JY.SubScene, id2, 6, old5)
  SetD(JY.SubScene, id2, 7, old6)
end

--加轻
function instruct_45(id, value)
	local xwperson;	--判定要洗武功的人
	if id == JY.Base["畅想"] then
		xwperson = 0
	else
		xwperson = id
	end
	local add, str = AddPersonAttrib(xwperson, "轻功", value)
end

--加内
function instruct_46(id, value)
	local xwperson;	--判定要洗武功的人
	if id == JY.Base["畅想"] then
		xwperson = 0
	else
		xwperson = id
	end
	local add, str = AddPersonAttrib(xwperson, "内力最大值", value)
	AddPersonAttrib(xwperson, "内力", 0)
end

--加攻
function instruct_47(id, value)
	local xwperson;	--判定要洗武功的人
	if id == JY.Base["畅想"] then
		xwperson = 0
	else
		xwperson = id
	end
	local add, str = AddPersonAttrib(xwperson, "攻击力", value)
end

--加防
function add_deffense(id, value)
	local xwperson;	--判定要洗武功的人
	if id == JY.Base["畅想"] then
		xwperson = 0
	else
		xwperson = id
	end
	local add, str = AddPersonAttrib(xwperson, "防御力", value)
end

--加血
function instruct_48(id, value)
	local xwperson;	--判定要洗武功的人
	if id == JY.Base["畅想"] then
		xwperson = 0
	else
		xwperson = id
	end
	local add, str = AddPersonAttrib(xwperson, "生命最大值", value)
	AddPersonAttrib(xwperson, "生命", value)
end

--洗内属
function instruct_49(personid, value)
	local xwperson;	--判定要洗内属的人
	if personid == JY.Base["畅想"] then
		xwperson = 0
	else
		xwperson = personid
	end
	JY.Person[xwperson]["内力性质"] = value
    JY.Person[personid]["内力性质"] = value
end

function instruct_50(id1, id2, id3, id4, id5)
  local num = 0
  if instruct_18(id1) == true then
    num = num + 1
  end
  if instruct_18(id2) == true then
    num = num + 1
  end
  if instruct_18(id3) == true then
    num = num + 1
  end
  if instruct_18(id4) == true then
    num = num + 1
  end
  if instruct_18(id5) == true then
    num = num + 1
  end
  if num == 5 then
    return true
  else
    return false
  end
end

function instruct_51()
	instruct_1(2547 + Rnd(18), 114, 0)
end

function instruct_52()
	DrawStrBoxWaitKey(string.format("你现在的品德指数为: %d", JY.Person[0]["品德"]), C_ORANGE, CC.DefaultFont)
end

function instruct_53()
	DrawStrBoxWaitKey(string.format("你现在的声望指数为: %d", JY.Person[0]["声望"]), C_ORANGE, CC.DefaultFont)
end

function instruct_54()
	for i = 0, JY.SceneNum - 1 do
		JY.Scene[i]["进入条件"] = 0
	end
	JY.Scene[2]["进入条件"] = 2
	JY.Scene[38]["进入条件"] = 2
	JY.Scene[75]["进入条件"] = 1
	JY.Scene[80]["进入条件"] = 1
end

function instruct_55(id, num)
	if GetD(JY.SubScene, id, 2) == num then
		return true
	else
		return false
	end
end

function instruct_56(v)
	--JY.Person[0]["声望"] = JY.Person[0]["声望"] + v
	--instruct_2_sub()
end

function instruct_57()
  instruct_27(-1, 7664, 7674)
  for i = 0, 56, 2 do
    local t1 = lib.GetTime()
    if JY.MyPic < 3844 then
      JY.MyPic = (7676 + i) / 2
    end
    SetD(JY.SubScene, 2, 5, i + 7690)
    SetD(JY.SubScene, 2, 6, i + 7690)
    SetD(JY.SubScene, 2, 7, i + 7690)
    SetD(JY.SubScene, 3, 5, i + 7748)
    SetD(JY.SubScene, 3, 6, i + 7748)
    SetD(JY.SubScene, 3, 7, i + 7748)
    SetD(JY.SubScene, 4, 5, i + 7806)
    SetD(JY.SubScene, 4, 6, i + 7806)
    SetD(JY.SubScene, 4, 7, i + 7806)
    DtoSMap()
    DrawSMap()
    ShowScreen()
    local t2 = lib.GetTime()
    if t2 - t1 < CC.AnimationFrame then
      lib.Delay(CC.AnimationFrame - (t2 - t1))
    end
  end
end

function instruct_58()
  local group = 5
  local num1 = 6
  local num2 = 3
  local startwar = 102
  local flag = {}
  for i = 0, group - 1 do
    for j = 0, num1 - 1 do
      flag[j] = 0
    end
    for j = 1, num2 do
      local r = nil
      while 1 do
        r = Rnd(num1)
        if flag[r] == 0 then
          flag[r] = 1
          do break end
        end
      end
      local warnum = r + i * num1
      WarLoad(warnum + startwar)
      instruct_1(2854 + warnum, WAR.Data["敌人1"], 0)
      instruct_0()
      if WarMain(warnum + startwar, 0) == true then
        instruct_0()
        instruct_13()
        TalkEx("还有那位前辈肯赐教？", 0, 1)
        instruct_0()
      else
        instruct_15()
        return 
      end
    end
    if i < group - 1 then
      TalkEx(JY.Person[0]["外号"].."已连战三场，*可先休息再战．", 70, 0)
      instruct_0()
      instruct_14()
      lib.Delay(300)
      if JY.Person[0]["受伤程度"] < 50 and JY.Person[0]["中毒程度"] <= 0 then
        JY.Person[0]["受伤程度"] = 0
        AddPersonAttrib(0, "体力", math.huge)
        AddPersonAttrib(0, "内力", math.huge)
        AddPersonAttrib(0, "生命", math.huge)
      end
      instruct_13()
      TalkEx("我已经休息够了，*有谁要再上？", 0, 1)
      instruct_0()
    end
  end
  TalkEx("接下来换谁？**．．．．*．．．．***没有人了吗？", 0, 1)
  instruct_0()
  TalkEx("如果还没有人要出来向这位*"..JY.Person[0]["外号"].."挑战，那麽这武功天下*第一之名，武林盟主之位，*就由这位"..JY.Person[0]["外号"].."夺得．***．．．．．．*．．．．．．*．．．．．．*好，恭喜"..JY.Person[0]["外号"].."，这武林盟主*之位就由"..JY.Person[0]["外号"].."获得，而这把*”武林神杖”也由你保管．", 70, 0)
  instruct_0()
  TalkEx("恭喜"..JY.Person[0]["外号"].."！", 12, 0)
  instruct_0()
  TalkEx("小兄弟，恭喜你！", 64, 4)
  instruct_0()
  TalkEx("好，今年的武林大会到此已*圆满结束，希望明年各位武*林同道能再到我华山一游．", 19, 0)
  instruct_0()
  instruct_14()
  for i = 24, 72 do
    instruct_3(-2, i, 0, 0, -1, -1, -1, -1, -1, -1, -2, -2, -2)
  end
  instruct_0()
  instruct_13()
  TalkEx("历经千辛万苦，我终於打败*群雄，得到这武林盟主之位*及神杖．*但是”圣堂”在那呢？*为什麽没人告诉我，难道大*家都不知道．*这会儿又有的找了．", 0, 1)
  instruct_0()
  instruct_2(143, 1)
end

--全部队友离队
function instruct_59()
	for i = CC.TeamNum, 2, -1 do
		if JY.Base["队伍" .. i] >= 0 then
			instruct_21(JY.Base["队伍" .. i])
		end
	end
	for i,v in ipairs(CC.AllPersonExit) do
		instruct_3(v[1], v[2], 0, 0, -1, -1, -1, -1, -1, -1, 0, -2, -2)
	end
end

function instruct_60(sceneid, id, num)
  if sceneid == -2 then
    sceneid = JY.SubScene
  end
  if id == -2 then
    id = JY.CurrentD
  end
  if GetD(sceneid, id, 5) == num then
    return true
  else
    return false
  end
end

function instruct_61()
  for i = 11, 24 do
    if GetD(JY.SubScene, i, 5) ~= 4664 then
      return false
    end
  end
  return true
end

--通关函数
function instruct_62(id1, startnum1, endnum1, id2, startnum2, endnum2)
	--JY.MyPic = -1
	--instruct_44(id1, startnum1, endnum1, id2, startnum2, endnum2)
	--ShowScreen()
	lib.Delay(200)
	say("本次游戏就到这里了，选择重新开始可进行下一周目的游戏！", 260, 5, "无酒不欢")
    

	lib.PlayMPEG("ending.mp4",VK_ESCAPE)
	
    os.remove(CONFIG.DataPath..'TgJl')
	--tgsave()
    
	--增加周目
	local x = AddZM()

	if JY.Base["周目"] == CC.Week and CC.Jl == 0 then
		CC.Sp = CC.Sp + x
		CC.Jl = 1
		DrawStrBoxWaitKey("获得【Ｇ秘武残章Ｏ】×"..x, C_ORANGE, CC.DefaultFont, 2)
	end

	tgsave()
	
	Cls()
	lib.FillColor(0, 0, CC.ScreenW, CC.ScreenH, C_BLACK)
	DrawString(350, 200, "片尾曲《四大山》", C_WHITE, CC.DefaultFont)
	DrawString(375, 300, "演唱：老凡总", C_WHITE, CC.DefaultFont)
	ShowScreen()
  
	PlayMIDI(116)
	local stime = 0
	local a = 1
	local lyrics = {
	{530,"吓 近万个小时 精心打磨"},
	{560,"做游戏为了什么冷笑着"},
	{590,"前辈元老功高又如何"},
	{610,"开源码我随手可得"},
	{640,"我的 加密了得 却奈何 赞助还不够多"},
	{680,"江湖难测 人傻钱多 谁争六级会员的资格"},
	{730,"论坛里 发帖要统一 否则请离去"},
	{810,"充过钱的** 我记得你 你再来充一笔"},
	{920,"抄抄 抄抄 抄抄抄抄"},
	{940,"抄袭来的代码真的不错"},
	{970,"我我 我我 我我我我"},
	{1000,"只要加密它们就是我的"},
	{1030,"作作 作作 作作作作"},
	{1050,"国产绿色益智单机大作"},
	{1070,"你你 你你 你你你你"},
	{1100,"你的钱包终究要属于我"},
	{1220,"吓 阴谋破坏者 在论坛等着"},
	{1250,"讲道理 赢了什么 删封沉"},
	{1280,"天下谁的 原创又如何"},
	{1300,"开源码 我辈善抄袭"},
	{1320,"我的游戏热门 却奈何"},
	{1350,"徒增虚名一个"},
	{1370,"没有赞助 都是辣鸡"},
	{1390,"谁争热心玩家的资格"},
	{1410,"小城里 岁月流过去 清澈钱包里"},
	{1510,"充过钱的** 我记得你 骄傲的活下去"},
	{1610,"抄抄 抄抄 抄抄抄抄"},
	{1630,"抄过来的代码真的实用"},
	{1660,"发发 发发 发发发发"},
	{1680,"不发帖说就没赞助收入"},
	{1710,"过过 过过 过过过过"},
	{1730,"过错软弱从来不属于我"},
	{1760,"你你 你你 你你你你"},
	{1780,"你的钱包终究要属于我"},
	{2100,"抄抄 抄抄 抄抄抄抄"},
	{2120,"抄袭来的代码真的不错"},
	{2140,"我我 我我 我我我我"},
	{2170,"只要加密它们就是我的"},
	{2190,"作作 作作 作作作作"},
	{2210,"国产绿色益智单机大作"},
	{2240,"你你 你你 你你你你"},
	{2260,"你的钱包终究要属于我"},
	{2310,"论坛里 发帖要统一 否则请离去"},
	{2390,"充过钱的** 我记得你 你再来充一笔"},
	{2700,"全剧终 感谢支持"},
	{2750," "}
	}
	while true do
		if JY.Restart == 1 then
			break
		end
		local key = lib.GetKey()
		lib.Delay(100)
		stime = stime + 1
		if stime == lyrics[a][1] then
			local size = CC.DefaultFont
			Cls()
			lib.FillColor(0, 0, CC.ScreenW, CC.ScreenH, C_BLACK)
			DrawString(350, 200, "片尾曲《四大山》", C_WHITE, size)
			DrawString(375, 300, "演唱：老凡总", C_WHITE, size)
			local align = CC.ScreenW/2 - (string.len(lyrics[a][2])/2*size)/2
			DrawString(align, 500, lyrics[a][2], C_WHITE, size)
			ShowScreen()
			a = a + 1
		end
		if a > #lyrics then
			break
		end
		if key == VK_ESCAPE then
			break
		end
	end
	
	Cls()

	JY.Status=GAME_END;
end

function instruct_63(personid, sex)
	JY.Person[personid]["性别"] = sex
end

--无酒不欢：商店数据
function instruct_64()
	local headid = 223
	local id = -1
	for i = 0, JY.ShopNum - 1 do
		if CC.ShopScene[i].sceneid == JY.SubScene then
		  id = i
		end
	end
	if id < 0 then
		return 
	end
	TalkEx("这位小哥，看看有什么需要的，小店卖的东西价钱绝对公道。", headid, 0,"商家")
	local menu = {}
	for i = 1, 6 do
		local thingid = JY.Shop[id]["物品" .. i]
		if thingid ~= -1 then
			menu[i] = {}
			menu[i][1] = string.format("%-12s %5d", JY.Thing[thingid]["名称"], JY.Shop[id]["物品价格" .. i])
			menu[i][2] = nil
			if JY.Shop[id]["物品数量" .. i] > 0 then
			  menu[i][3] = 1
			else
			  menu[i][3] = 0
			end
		end
	end

	--3书以前没有混元
	if JY.Base["天书数量"] < 3 and id == 0 then
		menu[5][3] = 0
	end

	local x1 = (CC.ScreenW - 9 * CC.DefaultFont - 2 * CC.MenuBorderPixel) / 2
	local y1 = (CC.ScreenH - 5 * CC.DefaultFont - 4 * CC.RowPixel - 2 * CC.MenuBorderPixel) / 2
	local r = ShowMenu(menu, #menu, 0, x1, y1, 0, 0, 1, 1, CC.DefaultFont, C_ORANGE, C_WHITE)
	--[[
	local itemJC = {}
	itemJC[0] = {38, 12, 28, 14, 68, -1, 400, 100, 80, 500, 6000, -1}
	itemJC[1] = {48, 0, 29, 15, 90, -1, 400, 100, 100, 500, 1000, -1}
	itemJC[2] = {54, 3, 32, 16, 159, -1, 400, 100, 100, 600, 600, -1}
	itemJC[3] = {63, 7, 33, 17, 175, -1, 400, 200, 120, 600, 800, -1}
	itemJC[4] = {27, 9, 34, 22, 69, -1, 2000, 50, 130, 400, 8000, -1}]]
	if r > 0 then
		if instruct_31(JY.Shop[id]["物品价格" .. r]) == false then
			TalkEx("非常抱歉，你身上的钱似乎不够。", headid, 0,"商家")
		else
			JY.Shop[id]["物品数量" .. r] = JY.Shop[id]["物品数量" .. r] - 1
			instruct_32(CC.MoneyID, -JY.Shop[id]["物品价格" .. r])
			instruct_32(JY.Shop[id]["物品" .. r], 1)
			TalkEx(JY.Person[0]["外号"].."买了小店的东西，保证绝不后悔。", headid, 0,"商家")
		end
	end
	for i,v in ipairs(CC.ShopScene[id].d_leave) do
		instruct_3(-2, v, 0, -2, -1, -1, 939, -1, -1, -1, -2, -2, -2)
	end
end

function instruct_65()
  local id = -1
  for i = 0, JY.ShopNum - 1 do
    if CC.ShopScene[i].sceneid == JY.SubScene then
      id = i
    end
  end
  if id < 0 then
    return 
  end
  instruct_3(-2, CC.ShopScene[id].d_shop, 0, -2, -1, -1, -1, -1, -1, -1, -2, -2, -2)
  for i,v in ipairs(CC.ShopScene[id].d_leave) do
    instruct_3(-2, v, 0, -2, -1, -1, -1, -1, -1, -1, -2, -2, -2)
  end
  local newid = id + 1
  if newid >= 5 then
    newid = 0
  end
  instruct_3(CC.ShopScene[newid].sceneid, CC.ShopScene[newid].d_shop, 1, -2, 938, -1, -1, 8256, 8256, 8256, -2, -2, -2)
end

function instruct_66(id)
  PlayMIDI(id)
end

function instruct_67(id)
  PlayWavAtk(id)
end


--选择框，每个选项都带边框
--title 标题
--str 内容 *换行
--button 选项
--num 选项的个数，一定要和选项对应起来
--headid 显示在内容左边的贴图，如果不传值则不显示贴图
function JYMsgBox(title, str, button, num, headid, isEsc)
	if JY.Restart == 1 then
		return 1
	end
	local strArray = {}
	local xnum, ynum, width, height = nil, nil, nil, nil
	local picw, pich = 0, 0
	local x1, x2, y1, y2 = nil, nil, nil, nil
	local size = CC.DefaultFont;
	local xarr = {};

	local function between(x, select)
		for i=1, num do
			if xarr[i] < x and x < xarr[i] + string.len(button[i])*size/2 then
				return i
			end
		end
		return select
	end
  
	if headid ~= nil then
		headid = headid*2;
		--picw, pich = lib.PicGetXY(1, headid)
		picw, pich = lib.GetPNGXY(1, headid)
		picw = picw + CC.MenuBorderPixel * 2
		pich = pich + CC.MenuBorderPixel * 2
	end
	ynum, strArray = Split(str, "*")
	xnum = 0
	for i = 1, ynum do
		local len = string.len(strArray[i])
		if xnum < len then
			xnum = len
		end
	end
	if xnum < 12 then
		xnum = 12
	end
	width = CC.MenuBorderPixel * 2 + math.modf(size * xnum / 2) + (picw)
	height = CC.MenuBorderPixel * 2 + (size + CC.MenuBorderPixel) * ynum
	if height < pich then
		height = pich
	end
	y2 = height
	height = height + CC.MenuBorderPixel * 2 + size * 2
	x1 = (CC.ScreenW - (width)) / 2 + CC.MenuBorderPixel
	x2 = x1 + (picw)
	y1 = (CC.ScreenH - (height)) / 2 + CC.MenuBorderPixel + 2 + size * 0.7
	y2 = y2 + (y1) - 5
	local select = 1

	Cls();
  
	DrawBoxTitle(width, height, title, C_GOLD)
	if headid ~= nil then
		--lib.PicLoadCache(1, headid, x1, y1, 1, 0)
		lib.LoadPNG(1, headid, x1, y1,1)
	end
	for i = 1, ynum do
		DrawString(x2, y1 + (CC.MenuBorderPixel + size) * (i - 1), strArray[i], C_WHITE, size)
	end
	
	local yczj = 0	--隐藏主角张家辉
	
	if title == "主角选择" then
		yczj = 1
	end
	
	local surid = lib.SaveSur((CC.ScreenW - (width)) / 2 - 4, (CC.ScreenH - (height)) / 2 - size, (CC.ScreenW + (width)) / 2 + 4, (CC.ScreenH + (height)) / 2 + 4)
	while true do
		if JY.Restart == 1 then
			break
		end
		Cls();
		lib.LoadSur(surid, (CC.ScreenW - (width)) / 2 - 4, (CC.ScreenH - (height)) / 2 - size)
		
		for i = 1, num do
			local color, bjcolor = nil, nil
			if i == select then
				color = M_Yellow
				bjcolor = M_DarkOliveGreen
			else
				color = M_DarkOliveGreen
			end
			xarr[i] = (CC.ScreenW - (width)) / 2 + (width) * i / (num + 1) - string.len(button[i]) * size / 4;
			DrawStrBox2(xarr[i], y2, button[i], color, size, bjcolor)
		end
		ShowScreen()
		  
		local key, ktype, mx, my = WaitKey(1)
		lib.Delay(CC.Frame)
		if key == VK_ESCAPE or ktype == 4 then
			if isEsc ~= nil and isEsc == 1 then
				select = -2
				break
			end
		elseif key == VK_LEFT or ktype == 6 then
			select = select - 1
			if select < 1 then
				select = num
			end
			if yczj == 1 and key == VK_LEFT then
				YC_ZhangJiaHui(key)
			end
		elseif key == VK_RIGHT or ktype == 7 then
			select = select + 1
			if num < select then
				select = 1
			end
			if yczj == 1 and key == VK_RIGHT then
				YC_ZhangJiaHui(key)
			end
		elseif key == VK_UP then
			if yczj == 1 then
				YC_ZhangJiaHui(key)
			end
		elseif key == VK_DOWN then
			if yczj == 1 then
				YC_ZhangJiaHui(key)
			end
		elseif key >= VK_A and key <= VK_Z then
			if yczj == 1 then
				YC_ZhangJiaHui(key)
			end
		elseif key == VK_RETURN or key == VK_SPACE or ktype == 5 then
			break
		elseif ktype == 2 or ktype == 3 then
			if mx >= x1 and mx <= x1 + width and my >= y2 and my <= y2 + 2*CC.MenuBorderPixel + size then
				--无酒不欢：这里pass in select，避免在选择不到的情况下返回不存在的选项
				select = between(mx, select);
				if select > 0 and select <= num and ktype==3 then
					break
				end
			end
		end
		--隐藏主角张家辉
		if yczj == 1 and YC.ZJH == 12 then
			YC.ZJH = 0
			lib.FreeSur(surid)
			return 3
		end
	end
	select = limitX(select, -2, num)
	lib.FreeSur(surid)
	
	Cls()
	return select
end

function JYMsgBox2(title, str, button, num, headid, isEsc)
	if JY.Restart == 1 then
		return 1
	end
	local strArray = {}
	local xnum, ynum, width, height = nil, nil, nil, nil
	local picw, pich = 0, 0
	local x1, x2, y1, y2 = nil, nil, nil, nil
	local size = CC.DefaultFont;
	local xarr = {};

	local function between(x, select)
		for i=1, num do
			if xarr[i] < x and x < xarr[i] + string.len(button[i])*size/2 then
				return i
			end
		end
		return select
	end
  
	if headid ~= nil then
		headid = headid*2;
		picw, pich = lib.GetPNGXY(1, headid)
		picw = picw + CC.MenuBorderPixel * 2
		pich = pich + CC.MenuBorderPixel * 2
	end
	ynum, strArray = Split(str, "*")
	xnum = 0
	for i = 1, ynum do
		local len = string.len(strArray[i])
		if xnum < len then
			xnum = len
		end
	end
	if xnum < 12 then
		xnum = 12
	end
	width = CC.MenuBorderPixel * 2 + math.modf(size * xnum / 2) + (picw)
	height = CC.MenuBorderPixel * 2 + (size + CC.MenuBorderPixel) * ynum
	if height < pich then
		height = pich
	end
	y2 = height
	height = height + CC.MenuBorderPixel * 2 + size * 2
	x1 = (CC.ScreenW - (width)) / 2 + CC.MenuBorderPixel
	x2 = x1 + (picw)
	y1 = (CC.ScreenH - (height)) / 2 + CC.MenuBorderPixel + 2 + size * 0.7
	y2 = y2 + (y1) - 5
	local select = 1

	Cls()
  
	DrawBoxTitle(width, height, title, C_GOLD)
	if headid ~= nil then
		lib.LoadPNG(1, headid, x1, y1,1)
	end
	for i = 1, ynum do
		DrawString(x2, y1 + (CC.MenuBorderPixel + size) * (i - 1), strArray[i], C_WHITE, size)
	end
	
	local surid = lib.SaveSur((CC.ScreenW - (width)) / 2 - 4, (CC.ScreenH - (height)) / 2 - size, (CC.ScreenW + (width)) / 2 + 4, (CC.ScreenH + (height)) / 2 + 4)
	while true do
		if JY.Restart == 1 then
			break
		end
		Cls();
		lib.LoadSur(surid, (CC.ScreenW - (width)) / 2 - 4, (CC.ScreenH - (height)) / 2 - size)
		
		for i = 1, num do
			local color, bjcolor = nil, nil
			if i == select then
				color = M_Yellow
				bjcolor = M_DarkOliveGreen
			else
				color = M_DarkOliveGreen
			end
			xarr[i] = (CC.ScreenW - (width)) / 2 + (width) * i / (num + 1) - string.len(button[i]) * size / 4;
			DrawStrBox2(xarr[i], y2, button[i], color, size, bjcolor)
		end
		ShowScreen()
		  
		local key, ktype, mx, my = WaitKey(1)
		lib.Delay(CC.Frame)
		if key == VK_ESCAPE or ktype == 4 then
			if isEsc ~= nil and isEsc == 1 then
				select = -2
				break
			end
		elseif key == VK_LEFT or ktype == 6 then
			select = select - 1
			if select < 1 then
				select = num
			end
		elseif key == VK_RIGHT or ktype == 7 then
			select = select + 1
			if num < select then
				select = 1
			end
		elseif key == VK_RETURN or key == VK_SPACE or ktype == 5 then
			break
		elseif ktype == 2 or ktype == 3 then
			if mx >= x1 and mx <= x1 + width and my >= y2 and my <= y2 + 2*CC.MenuBorderPixel + size then
				--无酒不欢：这里pass in select，避免在选择不到的情况下返回不存在的选项
				select = between(mx, select);
				if select > 0 and select <= num and ktype==3 then
					break
				end
			end
		end
	end
	select = limitX(select, -2, num)
	lib.FreeSur(surid)
	
	Cls()
	return button[select]
end

--显示带边框的文字
function DrawBoxTitle(width, height, str, color)
  local s = 4
  local x1, y1, x2, y2, tx1, tx2 = nil, nil, nil, nil, nil, nil
  local fontsize = s + CC.DefaultFont
  local len = string.len(str) * fontsize / 2
  x1 = (CC.ScreenW - width) / 2
  x2 = (CC.ScreenW + width) / 2
  y1 = (CC.ScreenH - height) / 2
  y2 = (CC.ScreenH + height) / 2
  tx1 = (CC.ScreenW - len) / 2
  tx2 = (CC.ScreenW + len) / 2
  lib.Background(x1, y1 + s, x1 + s, y2 - s, 128)
  lib.Background(x1 + s, y1, x2 - s, y2, 128)
  lib.Background(x2 - s, y1 + s, x2, y2 - s, 128)
  lib.Background(tx1, y1 - fontsize / 2 + s, tx2, y1, 128)
  lib.Background(tx1 + s, y1 - fontsize / 2, tx2 - s, y1 - fontsize / 2 + s, 128)
  local r, g, b = GetRGB(color)
  DrawBoxTitle_sub(x1 + 1, y1 + 1, x2, y2, tx1 + 1, y1 - fontsize / 2 + 1, tx2, y1 + fontsize / 2, RGB(math.modf(r / 2), math.modf(g / 2), math.modf(b / 2)))
  DrawBoxTitle_sub(x1, y1, x2 - 1, y2 - 1, tx1, y1 - fontsize / 2, tx2 - 1, y1 + fontsize / 2 - 1, color)
  DrawString(tx1 + 2 * s, y1 - (fontsize - s) / 2, str, color, CC.DefaultFont)
end

function DrawBoxTitle_sub(x1, y1, x2, y2, tx1, ty1, tx2, ty2, color)
  local s = 4
  lib.DrawRect(x1 + s, y1, tx1, y1, color)
  lib.DrawRect(tx2, y1, x2 - s, y1, color)
  lib.DrawRect(x2 - s, y1, x2 - s, y1 + s, color)
  lib.DrawRect(x2 - s, y1 + s, x2, y1 + s, color)
  lib.DrawRect(x2, y1 + s, x2, y2 - s, color)
  lib.DrawRect(x2, y2 - s, x2 - s, y2 - s, color)
  lib.DrawRect(x2 - s, y2 - s, x2 - s, y2, color)
  lib.DrawRect(x2 - s, y2, x1 + s, y2, color)
  lib.DrawRect(x1 + s, y2, x1 + s, y2 - s, color)
  lib.DrawRect(x1 + s, y2 - s, x1, y2 - s, color)
  lib.DrawRect(x1, y2 - s, x1, y1 + s, color)
  lib.DrawRect(x1, y1 + s, x1 + s, y1 + s, color)
  lib.DrawRect(x1 + s, y1 + s, x1 + s, y1, color)
  DrawBox_1(tx1, ty1, tx2, ty2, color)
end

function Init_SMap(showname)
	--lib.PicInit()
	--加载场景贴图文件
	--lib.PicLoadFile(CC.SMAPPicFile[1], CC.SMAPPicFile[2], 0)
	--lib.LoadPNGPath('./data/smap',0,-1,100)
	--lib.PicLoadFile(CC.BJ[1], CC.BJ[2], 92)
	--lib.LoadPNGPath('./data/bj',0,-1,100)
	--lib.LoadPNGPath(CC.HeadPath, 1, CC.HeadNum, limitX(CC.ScreenW/936*100,0,80))
	--lib.LoadPNGPath(CC.BodyPath, 90, CC.BodyNum, limitX(CC.ScreenW/936*100,0,100))	
	--lib.LoadPNGPath(CC.PTPath, 95, CC.PTNum, limitX(CC.ScreenW/936*100,0,100))
	---lib.LoadPNGPath(CC.XTPath, 91, CC.XTNum, limitX(CC.ScreenW/936*100,0,100))	--UI				
	--lib.LoadPNGPath(CC.UIPath, 96, CC.UINum, limitX(CC.ScreenW/936*100,0,100))	
	--lib.PicLoadFile(CC.ThingPicFile[1], CC.ThingPicFile[2], 2, 100, 100)
   -- lib.LoadPNGPath('./data/thing',0,-1,100)
	PlayMIDI(JY.Scene[JY.SubScene]["进门音乐"])
	JY.oldSMapX = -1
	JY.oldSMapY = -1
	JY.SubSceneX = 0
	JY.SubSceneY = 0
	JY.OldDPass = -1
	JY.D_Valid = nil
	DrawSMap()
	lib.GetKey()
	if showname == 1 then
		DrawStrBox(-1, 10, JY.Scene[JY.SubScene]["名称"], C_WHITE, CC.DefaultFont)
		ShowScreen()
		WaitKey()
	end
  
	AutoMoveTab = {[0] = 0}
end

--新对话方式
--加入控制字符
--暂停，任意键后继续，ｐ
--控制颜色Ｒ=redＧ=goldＢ=blackＷ=whiteＯ=orange
--控制字符显示速度０,１,２,３,４,５,６,７,８,９
--控制字体ＡＳＤＦ
--控制换行Ｈ   分页Ｐ
--Ｎ代表自己ｎ代表主角

function say(s,pid,flag,name)          --个人新对话
	if JY.Restart == 1 then
		return
	end
    local picw=130;       --最大头像图片宽高
	local pich=130;
	local talkxnum=20;         --对话一行字数
	local talkynum=3;          --对话行数
	local dx=2;
	local dy=2;
    local boxpicw=picw+10;
	local boxpich=pich+10;
	local boxtalkw=talkxnum*CC.DefaultFont+10;
	local boxtalkh=boxpich-27;
	local headid = pid;
	if name == nil then 
		headid = JY.Person[pid]["半身像"]
	end
	name=name or JY.Person[pid]["姓名"]
    local talkBorder=(pich-talkynum*CC.DefaultFont)/(talkynum+1)-5;

	--显示头像和对话的坐标
    local xy={ [0]={headx=dx,heady=dy,
	                talkx=dx+boxpicw+2,talky=dy+27,
					namex=dx+boxpicw+2,namey=dy,
					showhead=1},--左上
                   {headx=CC.ScreenW-1-dx-boxpicw-80,heady=CC.ScreenH-dy-boxpich+40,
				    talkx=CC.ScreenW-1-dx-boxpicw-boxtalkw-2-150,talky= CC.ScreenH-dy-boxpich+27,
					namex=CC.ScreenW-1-dx-boxpicw-26,namey=CC.ScreenH-dy-boxpich+100,
					showhead=1},--右下
                   {headx=dx,heady=dy,
				   talkx=dx+boxpicw-43,talky=dy+27,
					namex=dx+boxpicw+2,namey=dy,
				   showhead=0},--上中
                   {headx=CC.ScreenW-1-dx-boxpicw,heady=CC.ScreenH-dy-boxpich,
				   talkx=CC.ScreenW-1-dx-boxpicw-boxtalkw-2,talky= CC.ScreenH-dy-boxpich+27,
					namex=CC.ScreenW-1-dx-boxpicw-96,namey=CC.ScreenH-dy-boxpich,
					showhead=1},
                   {headx=CC.ScreenW-1-dx-boxpicw,heady=dy,
				    talkx=CC.ScreenW-1-dx-boxpicw-boxtalkw-2,talky=dy+27,
					namex=CC.ScreenW-1-dx-boxpicw-96,namey=dy,
					showhead=1},--右上
                   {headx=dx+68,heady=CC.ScreenH-dy-boxpich+40,
				   talkx=dx+boxpicw+2+160,talky=CC.ScreenH-dy-boxpich+27,
					namex=dx+boxpicw-50,namey=CC.ScreenH-dy-boxpich+100,
				   showhead=1}, --左下
			}

	if pid==0 then
	   if name ~= JY.Person[pid]["姓名"] then 
	      flag=5
	   else 
	      flag=1
	   end 
	else
	   flag=5
	end
	
	

  if xy[flag].showhead == 0 then
    headid = -1
  end

    lib.GetKey();

	local function readstr(str)
		local T1={"０","１","２","３","４","５","６","７","８","９"}
		local T2={{"Ｒ",C_RED},{"Ｇ",C_GOLD},{"Ｂ",C_BLACK},{"Ｗ",C_WHITE},{"Ｏ",C_ORANGE},{"Ｌ",LimeGreen},{"Ｄ",M_DeepSkyBlue},{"Ｚ",LightPurple}}
		local T3={{"Ｈ",CC.FontNameSong},{"Ｓ",CC.FontNameHei},{"Ｆ",CC.FontName}}
		--美观起见，针对不同字体同一行显示，需要微调ｙ坐标，以及字号
		--以默认的字体为标准，启体需下移，细黑需上移
		for i=0,9 do
			if T1[i+1]==str then return 1,i*50 end
		end
		for i=1,8 do
			if T2[i][1]==str then return 2,T2[i][2] end
		end
		for i=1,3 do
			if T3[i][1]==str then return 3,T3[i][2] end
		end
		return 0
	end

	local function mydelay(t)
		if t<=0 then return end
		lib.ShowSurface(0)
		lib.Delay(t)
	end

	local page, cy, cx = 0, 0, 0
  local color, t, font = C_WHITE, 0, CC.FontName
  while string.len(s) >= 1 do
	lib.GetKey();
	if JY.Restart == 1 then
		break
	end
    if page == 0 then
      Cls()
      if headid >= 0 then

		local w, h = lib.GetPNGXY(1, headid*2)
        local x = (picw - w) / 2
        local y = (pich - h) / 2
	    lib.LoadPicture(CC.SayBoxFile,-1,-1);
		lib.LoadPNG(90, headid*2, xy[flag].headx + 5 + x-76, xy[flag].heady + 5 + y-220, 1)
       lib.LoadPicture(CC.SayBoxNMFile,xy[flag].namex-35,xy[flag].namey-10,1);	
	   MyDrawString(xy[flag].namex, xy[flag].namex + 96, xy[flag].namey + 1, name, C_CYGOLD, 24)
        	
      end
      page = 1
    end
		local str
		str=string.sub(s,1,1)
		if str=='*' then
			--str='Ｈ'
			s=string.sub(s,2,-1)
		else
			if string.byte(s,1,1) > 127 then		--判断单双字符
				str=string.sub(s,1,2)
				s=string.sub(s,3,-1)
			else
				str=string.sub(s,1,1)
				s=string.sub(s,2,-1)
			end
		end
		--开始控制逻辑
		if str=='*' then
		elseif str=="Ｈ" then
			cx=0
			cy=cy+1
			if cy==3 then
				cy=0
				page=0
			end
		elseif str=="Ｐ" then
			cx=0
			cy=0
			page=0
		elseif str=="ｐ" then
			ShowScreen();
			--WaitKey();
			lib.Delay(50)
		elseif str=="ｗ" then
			ShowScreen();
			WaitKey();
			--lib.Delay(50)
		elseif str=="Ｎ" then
			s=JY.Person[pid]["姓名"]..s
		elseif str=="ｎ" then
			s=JY.Person[0]["姓名"]..s
		else
			local kz1,kz2=readstr(str)
			if kz1==1 then
				t=kz2
			elseif kz1==2 then
				color=kz2
			elseif kz1==3 then
				font=kz2
			else
				lib.DrawStr(xy[flag].talkx+CC.DefaultFont*cx+5,
							xy[flag].talky+(CC.DefaultFont+talkBorder)*cy+talkBorder-8,
							str,color,CC.DefaultFont,font,0,0, 305)
				mydelay(t)
				cx=cx+string.len(str)/2
				if cx==talkxnum then
					cx=0
					cy=cy+1
					if cy==talkynum then
						cy=0
						page=0
					end
				end
			end
		end
		--如果换页，则显示，等待按键
		if page==0 or string.len(s)<1 then
			ShowScreen();
			WaitKey();
			lib.Delay(100)
		end

	end


	if JY.Restart == 1 then
		do return end
	end

	Cls();
end

function MyDrawString(x1, x2, y, str, color, size)
	local len = math.modf(string.len(str) * size / 4)
	local x = math.modf((x1 + x2) / 2) - len
	DrawString(x, y, str, color, size)
end

--分割字符串
--szFullString字符串
--szSeparator分割符
--返回总数,分割后数组
function Split(szFullString, szSeparator)
  local nFindStartIndex = 1
  local nSplitIndex = 1
  local nSplitArray = {}
  while true do
    local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
    if not nFindLastIndex then
      nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
      break;
    else
	    nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
	    nFindStartIndex = nFindLastIndex + string.len(szSeparator)
	    nSplitIndex = nSplitIndex + 1
	  end
  end
  return nSplitIndex, nSplitArray
end

function DrawStrBox2(x, y, str, color, size, bjcolor)
  local strarray = {}
  local num, maxlen = nil, nil
  maxlen = 0
  num, strarray = Split(str, "*")
  for i = 1, num do
    local len = string.len(strarray[i])
    if maxlen < len then
      maxlen = len
    end
  end
  local w = size * maxlen / 2 + 2 * CC.MenuBorderPixel
  local h = 2 * CC.MenuBorderPixel + size * num
  if x == -1 then
    x = (CC.ScreenW - size / 2 * maxlen - 2 * CC.MenuBorderPixel) / 2
  end
  if y == -1 then
    y = (CC.ScreenH - size * num - 2 * CC.MenuBorderPixel) / 2
  end
  DrawBox2(x, y, x + w - 1, y + h - 1, C_WHITE, bjcolor)
  for i = 1, num do
    DrawString(x + CC.MenuBorderPixel, y + CC.MenuBorderPixel + size * (i - 1), strarray[i], color, size)
  end
end

--绘制一个带背景的白色方框，四角凹进
function DrawBox2(x1, y1, x2, y2, color, bjcolor)
  local s = 4
  if not bjcolor then
    bjcolor = 0
  end
  if bjcolor >= 0 then
    lib.Background(x1, y1 + s, x1 + s, y2 - s, 128, bjcolor)
    lib.Background(x1 + s, y1, x2 - s, y2, 128, bjcolor)
    lib.Background(x2 - s, y1 + s, x2, y2 - s, 128, bjcolor)
  end
  if color >= 0 then
    local r, g, b = GetRGB(color)
    DrawBox_2(x1 + 1, y1, x2, y2, RGB(math.modf(r / 2), math.modf(g / 2), math.modf(b / 2)))
    DrawBox_2(x1, y1, x2 - 1, y2 - 1, color)
  end
end

--绘制四角凹进的方框
function DrawBox_2(x1, y1, x2, y2, color)
  local s = 4
  lib.DrawRect(x1 + s, y1, x2 - s, y1, color)
  lib.DrawRect(x2 - s, y1, x2 - s, y1 + s, color)
  lib.DrawRect(x2 - s, y1 + s, x2, y1 + s, color)
  lib.DrawRect(x2, y1 + s, x2, y2 - s, color)
  lib.DrawRect(x2, y2 - s, x2 - s, y2 - s, color)
  lib.DrawRect(x2 - s, y2 - s, x2 - s, y2, color)
  lib.DrawRect(x2 - s, y2, x1 + s, y2, color)
  lib.DrawRect(x1 + s, y2, x1 + s, y2 - s, color)
  lib.DrawRect(x1 + s, y2 - s, x1, y2 - s, color)
  lib.DrawRect(x1, y2 - s, x1, y1 + s, color)
  lib.DrawRect(x1, y1 + s, x1 + s, y1 + s, color)
  lib.DrawRect(x1 + s, y1 + s, x1 + s, y1, color)
end

--初始化主地图
function Init_MMap()
	--lib.PicInit()
	lib.LoadMMap(CC.MMapFile[1], CC.MMapFile[2], CC.MMapFile[3], CC.MMapFile[4], CC.MMapFile[5], CC.MWidth, CC.MHeight, JY.Base["人X"], JY.Base["人Y"])
  
    --lib.PicLoadFile(CC.MMAPPicFile[1], CC.MMAPPicFile[2], 0)
	--lib.LoadPNGPath('./data/mmap',0,-1,100)
   -- lib.PicLoadFile(CC.BJ[1], CC.BJ[2], 92)
	--lib.LoadPNGPath('./data/BJ',0,-1,100)
	--lib.LoadPNGPath(CC.HeadPath, 1, CC.HeadNum, limitX(CC.ScreenW/936*100,0,80))
	--lib.LoadPNGPath(CC.BodyPath, 90, CC.BodyNum, limitX(CC.ScreenW/936*100,0,100))	
	--lib.LoadPNGPath(CC.PTPath, 95, CC.PTNum, limitX(CC.ScreenW/936*100,0,100))
	--lib.LoadPNGPath(CC.XTPath, 91, CC.XTNum, limitX(CC.ScreenW/936*100,0,100))	--UI		
	--lib.LoadPNGPath(CC.UIPath, 96, CC.UINum, limitX(CC.ScreenW/936*100,0,100))
  
	--lib.PicLoadFile(CC.ThingPicFile[1], CC.ThingPicFile[2], 2, 100, 100)
    --lib.LoadPNGPath('./data/thing',0,-1,100)
	JY.EnterSceneXY = nil
	JY.oldMMapX = -1
	JY.oldMMapY = -1
	PlayMIDI(JY.MmapMusic)
  
	AutoMoveTab = {[0] = 0}
end

--自定义的进入子场景的函数
--需要进入的子场景编号
--x进入子场景后人物的X坐标，传入-1则默认为入口X
--y进入子场景后人物的Y坐标，传入-1则默认为入口Y
--direct人物面对的方向
function My_Enter_SubScene(sceneid,x,y,direct)
	--从大地图进入子场景前自动保存到10号档
	if JY.Status == GAME_MMAP then
		SaveRecord(10)
	end
	JY.SubScene = sceneid;
	local flag = 1;   --是否自定义的xy坐标, 0是，1否
	if x == -1 and y == -1 then
		JY.Base["人X1"]=JY.Scene[sceneid]["入口X"];
		JY.Base["人Y1"]=JY.Scene[sceneid]["入口Y"];
	else
		JY.Base["人X1"] = x;
		JY.Base["人Y1"] = y;
		flag = 0;
	end
	
	if direct > -1 then
		JY.Base["人方向"] = direct;
	end
 			
	
	if JY.Status == GAME_MMAP then
		CleanMemory();
		--lib.UnloadMMap();
	end
	lib.ShowSlow(20,1)

	JY.Status=GAME_SMAP;  --改变状态
	JY.MmapMusic=-1;

	JY.Base["乘船"]=0;
	JY.MyPic=GetMyPic(); 
  
	--外景入口是个难点，有些子场景是通过跳转的方式进入的，需要判断
	--由于目前最多只能有一个子场景跳转，所以不需要进行循环判断
	local sid = JY.Scene[sceneid]["跳转场景"];
  
	if sid < 0 or (JY.Scene[sid]["外景入口X1"] <= 0 and JY.Scene[sid]["外景入口Y1"] <= 0) then
		JY.Base["人X"] = JY.Scene[sceneid]["外景入口X1"];  --改变出子场景后的XY坐标
		JY.Base["人Y"] = JY.Scene[sceneid]["外景入口Y1"];
	else
		JY.Base["人X"] = JY.Scene[sid]["外景入口X1"];  --改变出子场景后的XY坐标
		JY.Base["人Y"] = JY.Scene[sid]["外景入口Y1"];
	end

    
	Init_SMap(flag);  --重新初始化地图
   -- lib.LoadPNGPath('./data/smap',0,-1,100)
	if flag == 0 then    --如果是自定义位置，先传送到那个位置，再显示场景名称
		DrawStrBox(-1,10,JY.Scene[JY.SubScene]["名称"],C_WHITE,CC.DefaultFont);
		ShowScreen();
		WaitKey();
	end
  
	Cls();	
end

--简易信息
function JYZTB(id,pid)
	ShowStatus() 
	end

function QZXS(s)
	DrawStrBoxWaitKey(s, C_GOLD, CC.DefaultFont)
end

--显示武功的文字
function KungfuString(str, x, y, color, size, font, place)
  if str == nil then
    return 
  end
  local w, h = size, size + 5
  local len = string.len(str) / 2
  x = x - len * w / 2
  y = y - h * place
  lib.DrawStr(x, y, str, color, size, font, 0, 0)
end

--清除贴图文字
function ClsN(x1, y1, x2, y2)
  if x1 == nil then
    x1 = 0
    y1 = 0
    x2 = 0
    y2 = 0
  end
  lib.SetClip(x1, y1, x2, y2)
  lib.FillColor(0, 0, 0, 0, 0)
  lib.SetClip(0, 0, 0, 0)
end


---对矩形进行屏幕剪裁
--返回剪裁后的矩形，如果超出屏幕，返回空
function ClipRect(r)
  if CC.ScreenW <= r.x1 or r.x2 <= 0 or CC.ScreenH <= r.y1 or r.y2 <= 0 then
    return nil
  else
    local res = {}
    res.x1 = limitX(r.x1, 0, CC.ScreenW)
    res.x2 = limitX(r.x2, 0, CC.ScreenW)
    res.y1 = limitX(r.y1, 0, CC.ScreenH)
    res.y2 = limitX(r.y2, 0, CC.ScreenH)
    return res
  end
end

--计算贴图改变形成的Clip裁剪
--(dx1,dy1) 新贴图和绘图中心点的坐标偏移。在场景中，视角不同而主角动时用到
--pic1 旧的贴图编号
--id1 贴图文件加载编号
--(dx2,dy2) 新贴图和绘图中心点的偏移
--pic2 旧的贴图编号
--id2 贴图文件加载编号
--返回，裁剪矩形 {x1,y1,x2,y2}
function Cal_PicClip(dx1, dy1, pic1, id1, dx2, dy2, pic2, id2)
  local w1, h1, x1_off, y1_off = lib.PicGetXY(id1, pic1 * 2)
  local old_r = {}
  old_r.x1 = CC.XScale * (dx1 - dy1) + CC.ScreenW / 2 - x1_off
  old_r.y1 = CC.YScale * (dx1 + dy1) + CC.ScreenH / 2 - y1_off
  old_r.x2 = old_r.x1 + w1
  old_r.y2 = old_r.y1 + h1
  local w2, h2, x2_off, y2_off = lib.PicGetXY(id2, pic2 * 2)
  local new_r = {}
  new_r.x1 = CC.XScale * (dx2 - dy2) + CC.ScreenW / 2 - x2_off
  new_r.y1 = CC.YScale * (dx2 + dy2) + CC.ScreenH / 2 - y2_off
  new_r.x2 = new_r.x1 + w2
  new_r.y2 = new_r.y1 + h2
  return MergeRect(old_r, new_r)
end

--合并矩形
function MergeRect(r1, r2)
  local res = {}
  res.x1 = math.min(r1.x1, r2.x1)
  res.y1 = math.min(r1.y1, r2.y1)
  res.x2 = math.max(r1.x2, r2.x2)
  res.y2 = math.max(r1.y2, r2.y2)
  return res
end



--显示阴影字符串
--如果x,y传-1，那么显示在屏幕中间
function NewDrawString(x, y, str, color, size)
	local ll = #str
	local w = size * ll / 2 + 2 * CC.MenuBorderPixel
	local h = size + 2 * CC.MenuBorderPixel
	if x == -1 then
		x = (CC.ScreenW - size / 2 * ll - 2 * CC.MenuBorderPixel) / 2
	else
		x = (x - size / 2 * ll - 2 * CC.MenuBorderPixel) / 2
	end
	if y == -1 then
		y = (CC.ScreenH - size - 2 * CC.MenuBorderPixel) / 2
	else
		y = (y - size - 2 * CC.MenuBorderPixel) / 2
	end
	lib.DrawStr(x, y, str, color, size, CC.FontName, CC.SrcCharSet, CC.OSCharSet)
end

--无酒不欢：仿造提款机ATM画的数字输入UI
function InputNum(str, minNum, maxNum, isEsc)
	local size = CC.DefaultFont;
	local b_space = size+CC.RowPixel
	local x=(CC.ScreenW-size*9-2*CC.MenuBorderPixel)/2;
	local y=(CC.ScreenH-size*9-2*CC.MenuBorderPixel)/2;
	local w=size*9+2*CC.MenuBorderPixel;
	local h=(b_space+CC.RowPixel*2)*6;
	local functional_button = {{name="确认"},{name="最大"},{name="清空"},{name="删除"},{name=0},{name=1},{name=2},{name=3},{name=4},{name=5},{name=6},{name=7},{name=8},{name=9}};
	local starting_y = 5;
	local starting_x = 1;

	for i = 1, #functional_button do
		functional_button[i].x1 = CC.ScreenW/2+(b_space+CC.RowPixel*2)*starting_x-11
		functional_button[i].y1 = y+(b_space+CC.RowPixel*2)*starting_y
		if i <= 4 then
			functional_button[i].x2 = CC.ScreenW/2+(b_space+CC.RowPixel*2)*starting_x-11+b_space*2
			functional_button[i].y2 = y+(b_space+CC.RowPixel*2)*starting_y+b_space
		else
			functional_button[i].x2 = CC.ScreenW/2+(b_space+CC.RowPixel*2)*starting_x-11+b_space
			functional_button[i].y2 = y+(b_space+CC.RowPixel*2)*starting_y+b_space
		end
		if i < 4 then
			starting_y = starting_y - 1
		elseif i == 4 then
			starting_y = 5
			starting_x = -1
		elseif i == 5 or i == 8 or i == 11 then
			starting_x = -2
			starting_y = starting_y - 1
		elseif i > 5 then
			starting_x = starting_x + 1
		end
	end

	local num = 0;
	if minNum ~= nil then
		num = minNum;
	end
	
	local selected_content = 0
	
	DrawBox(x,y,x+w-1,y+h-1,C_WHITE);
	DrawString(x+CC.MenuBorderPixel*2,y+CC.MenuBorderPixel,str.." "..minNum.." - "..maxNum,C_WHITE,size);
  
	local sid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH);
  
	while true do
		if JY.Restart == 1 then
			break
		end
		DrawShades(CC.ScreenW/2-b_space*3,y+b_space+CC.RowPixel*2,CC.ScreenW/2+b_space*3,y+b_space+CC.RowPixel*2+b_space)
		DrawString(CC.ScreenW/2,y+b_space+CC.RowPixel*2,string.format("%d",num),C_WHITE,size);
		
		for i = 1, #functional_button do
			local x_indent = 7
			local y_indent = 2
			if i > 4 then
				x_indent = 11
				y_indent = 0
			end
			local shade_color = nil;
			if i == selected_content then
				shade_color = C_GOLD
			end
			DrawShades(functional_button[i].x1,functional_button[i].y1,functional_button[i].x2,functional_button[i].y2,shade_color)
			DrawString(functional_button[i].x1+x_indent,functional_button[i].y1+y_indent,functional_button[i].name,C_GOLD,size);
		end
		
		ShowScreen()
		local key, ktype, mx, my = lib.GetKey();
		lib.Delay(CC.Frame)
        if (key == VK_ESCAPE or ktype == 4) and isEsc ~= nil then
			num = nil;
			break;
		elseif key >= 49 and key <= 57 then
			num = num * 10
			num = num + key - 48
			if num > maxNum then
				num = maxNum
			end
		elseif key >= 1073741913 and key <= 1073741921 then
			num = num * 10
			num = num + key - 1073741912
			if num > maxNum then
				num = maxNum
			end
		elseif key == 48 or key == 1073741922 then
			num = num * 10
			if num > maxNum then
				num = maxNum
			end
		elseif key == VK_BACKSPACE then
			num = math.modf(num/10)
		elseif key == VK_SPACE or key == VK_RETURN then
			if num >= minNum and num <= maxNum then
				break;
			end
		elseif ktype == 2 or ktype == 3 then
			selected_content = 0
			if mx >= x and mx <= x + w-1 and my >= y and my <= y + h-1 then
				for k = 1, #functional_button do 
					if mx >= functional_button[k].x1 and mx <= functional_button[k].x2 and my >= functional_button[k].y1 and my <= functional_button[k].y2 then
						selected_content = k;
						break;
					end
				end
			end
			if ktype == 3 then
				if selected_content == 1 then
					if num >= minNum and num <= maxNum then
						break;
					end
				elseif selected_content == 2 then
					num = maxNum
				elseif selected_content == 3 then
					num = 0
				elseif selected_content == 4 then
					num = math.modf(num/10)
				elseif selected_content > 4 then
					num = num * 10
					num = num + functional_button[selected_content].name
					if num > maxNum then
						num = maxNum
					end
				end
			end
		end
		ClsN();
		lib.LoadSur(sid,0,0)
	end
	lib.FreeSur(sid);
	return num;
end

--分析字符串中是否有颜色标志
--被DrawTxt函数调用
function AnalyString(str)
	local tlen = 0;
	local strcolor = {}
	--检查是否有颜色标志
	local f1, f2 = string.find(str, "<[A-R]>");
	if f1 ~= nil then
		while 1 do
			if f1 > 1 then
				local s1 = string.sub(str, 1, f1-1)
				table.insert(strcolor, {s1, nil});
				tlen = tlen + #s1;
			end
			local match = string.match(str, "<([A-R])>");
			local f3, f4 = string.find(str, "</"..match..">"); 
			if f3 ~= nil then
				local s2 = string.sub(str, f2+1, f3-1);
				table.insert(strcolor, {s2, CC.Color[match]});
				tlen = tlen + #s2;
				if f4+1 >= #str then
					break;
				end
				str = string.sub(str, f4+1, #str);
				f1, f2 = string.find(str, "<[A-R]>");
				--如果已经没有其它颜色标志，直接输入退出循环
				if f1 == nil then
					table.insert(strcolor, {str, nil});
					break;
				end
			else		--如果找不到结束标志，直接输入退出循环
				str = string.sub(str, f2+1, #str);
				table.insert(strcolor, {str, CC.Color[match]});
				break;
			end
		end
	else
		table.insert(strcolor, {str, nil});
	end
	return strcolor;
end

--存档列表
function SaveList()
	--读取R*.idx文件
	local idxData = Byte.create(24)
	Byte.loadfile(idxData, CC.R_IDXFilename[0], 0, 24)
	local idx = {}
	idx[0] = 0
	for i = 1, 6 do
		idx[i] = Byte.get32(idxData, 4 * (i - 1))
	end

	local table_struct = {}
	table_struct["姓名"]={idx[1]+8,2,10}
	table_struct["资质"]={idx[1]+122,0,2}
  
	table_struct["无用"]={idx[0]+2,0,2}
	table_struct["难度"]={idx[0]+24,0,2}
	
	table_struct["标准"]={idx[0]+26,0,2}
	table_struct["畅想"]={idx[0]+28,0,2}
	table_struct["特殊"]={idx[0]+30,0,2}
	
	table_struct["天书数量"]={idx[0]+36,0,2}
	table_struct["武功数量"]={idx[0]+38,0,2}
	table_struct["场景名称"]={idx[3]+2,2,10}

	--主角编号
	table_struct["队伍1"]={idx[0]+52,0,2}
  
	--table_struct[WZ7]={idx[2]+88,0,2}
  
	--时间保存在场景数据里
	--table_struct["游戏时间"]={(CC.SWidth*CC.SHeight*(14*6+4) + CC.SWidth + 2)*2, 0, 2}
	--S_XMax*S_YMax*(id*6+level)+y*S_XMax+x
	--14, 2, 1, 4
	--sFile,CC.TempS_Filename,JY.SceneNum,CC.SWidth,CC.SHeight

	--读取R*.grp文件

	local len = filelength(CC.R_GRPFilename[0]);
	local data = Byte.create(len);
	
	--读取SMAP.grp
	local slen  = filelength(CC.S_Filename[0]);
	local sdata = Byte.create(slen);
	
	local menu = {};

	for i=1, CC.SaveNum do
	
		local name = "";
		--local lv = "";
		local sname = "";
		local nd = "";
		local time = "";
		--天书数量
		local tssl = "";
		--主角类型
		local zjlx = "";	
		--资质
		local zz = "";
		
		if existFile(string.format('data/save/Save_%d',i)) then
			Byte.loadfilefromzip(data, string.format('data/save/Save_%d',i),'r.grp', 0, len);
			
			local pid = GetDataFromStruct(data,0,table_struct,"队伍1");
			
			name = GetDataFromStruct(data,pid*CC.PersonSize,table_struct,"姓名");
			zz = GetDataFromStruct(data,pid*CC.PersonSize,table_struct,"资质");
			
			local wy = GetDataFromStruct(data,0,table_struct,"无用");
			if wy == -1 then
				sname = "大地图";
			else
				sname = GetDataFromStruct(data,wy*CC.SceneSize,table_struct,"场景名称").."";
			end
			
			local lxid1 = GetDataFromStruct(data,0,table_struct,"标准");
			local lxid2 = GetDataFromStruct(data,0,table_struct,"畅想");
			local lxid3 = GetDataFromStruct(data,0,table_struct,"特殊");
			
			if lxid1 > 0 then
				zjlx = "标准"
			elseif lxid2 > 0 then
				zjlx = "畅想"
			elseif lxid3 > 0 then
				zjlx = "特殊"
			end
			
			local wz = GetDataFromStruct(data,0,table_struct,"难度");
			tssl = GetDataFromStruct(data,0,table_struct,"天书数量").."本";

			nd = MODEXZ2[wz]
			
			--游戏时间
			--[[
			Byte.loadfile(sdata, string.format(CC.S_GRP,i), 0, slen);
			
			local t = GetDataFromStruct(sdata, 0, table_struct, "游戏时间")
			local t1, t2 = 0, 0
			while t >= 60 do
				t = t - 60
				t1 = t1 + 1
			end
			t2 = t
		  
			time = string.format("%2d时%2d秒", t1, t2)]]
		end
		
		if i < 10 then
			menu[i] = {string.format("存档%02d %-4s %-10s %-4s %4s %4s %-10s", i, zjlx, name, nd, zz, tssl, sname), nil, 1};
		else
			menu[i] = {string.format("自动档 %-4s %-10s %-4s %4s %4s %-10s", zjlx, name, nd, zz, tssl, sname), nil, 1};
		end
	end

	local menux=(CC.ScreenW-24*CC.DefaultFont-2*CC.MenuBorderPixel)/2
	local menuy=(CC.ScreenH - 9*(CC.DefaultFont+CC.RowPixel))/2

	local r=ShowMenu(menu,CC.SaveNum,10,menux,menuy,0,0,1,1,CC.DefaultFont,C_WHITE,C_GOLD)
	lib.Debug("SaveList")
	CleanMemory()
	return r;
end

--动态提示显示
function DrawTimer()
	if CC.OpenTimmerRemind ~= 1 then
		return;
	end
	local t2 = lib.GetTime();
	if CC.Timer.status==0 then
		if t2-CC.Timer.stime > 30000 or CC.Timer.stime == 0 then
			CC.Timer.stime=t2;
			CC.Timer.status=1;
			CC.Timer.str=CC.RUNSTR[math.random(#CC.RUNSTR)];
			CC.Timer.len=string.len(CC.Timer.str)/2+3;
		end
	else
		CC.Timer.fun(t2);
	end
end

function demostr(t)
	local tt=t-CC.Timer.stime;
	tt=math.modf(tt/25)%(CC.ScreenW+CC.Timer.len*CC.Fontsmall);
	if runword(CC.Timer.str,M_Orange,CC.Fontsmall,1,tt)==1 then
		CC.Timer.status=0;
		CC.Timer.stime=t;
	end
end

function runword(str,color,size,place,offset)
	offset=CC.ScreenW-offset;
	local y1,y2
	if place==0 then
		y1=0;
		y2=size;
	elseif place==1 then
		y1=CC.ScreenH-size;
		y2=CC.ScreenH;
	end
	lib.Background(0,y1,CC.ScreenW,y2,128);
	if -offset>(CC.Timer.len-1)*size then
		return 1;
	end
	DrawString(offset,y1,str,color,size);
	return 0;
end

function dark()
	instruct_14()
end

function light()
	instruct_13()
end

--无酒不欢：添加事件函数
function addevent(sid, pid, pass, event, etype, pic, x, y)
	if JY.Restart == 1 then
		return
	end
	if x == nil then x = -2 end
	if y == nil then y = -2 end
	if pic == nil then pic = -2 end
	if etype == nil then etype = 1 end
	if event == nil then event = -2 end
	if pass == nil then pass = -2 end
	if etype == 1 then
		instruct_3(sid, pid, pass, 0, event, 0, 0, pic, pic, pic, -2, x, y)
	elseif etype == 2 then
		instruct_3(sid, pid, pass, 0, 0, event, 0, pic, pic, pic, -2, x, y)
	else
		instruct_3(sid, pid, pass, 0, 0, 0, event, pic, pic, pic, -2, x, y)
	end	
end

--无酒不欢：删除事件函数
function null(sid, pid)
	addevent(sid, pid, 0, 0, 0, 0)
end

--无酒不欢：畅想的选择菜单
function ShowMenu3(menu,itemNum,numShow,showRow,x1,y1,size,color,selectColor)
    local w=0;
    local h=0;   --边框的宽高
    local i,j=0,0;
    local col=0;     --实际的显示菜单项
    local row=0;
    
    lib.GetKey();
    Cls();
    
    --建一个新的table
    local menuItem = {};
    local numItem = 0;                --显示的总数
    
    --把可选为畅想的人物保存到新的table
    for i,v in pairs(menu) do
        if v[3] ~= 0 then
            numItem = numItem + 1;
			menuItem[numItem] = {v[1],v[2],v[3],i};                --注意第4个位置，保存i的值
        end
    end
    
    --计算实际显示的菜单项数
    if numShow==0 or numShow > numItem then
        col=numItem;
        row = 1;
    else
		--列数
        col=numShow;
		--(项目总数-1)/列数=行数
        row = math.modf((numItem-1)/col);
    end
    
    if showRow > row + 1 then
        showRow = row + 1;
    end

    --计算边框实际宽高
    local maxlength=0;

	for i=1,numItem do
		if string.len(menuItem[i][1])>maxlength then
			maxlength=string.len(menuItem[i][1]);
		end
	end
	w=(size*maxlength/2+CC.RowPixel*2)*col+2*CC.MenuBorderPixel;
	h=showRow*(size+CC.RowPixel*2) + 2*CC.MenuBorderPixel;

    local start=0;             --显示的第一项

    local curx = 1;          --当前选择项
    local cury = 0;
    local current = curx + cury*numShow;

    local returnValue =0;

    local surid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)

    while true do
		lib.GetKey()
		if JY.Restart == 1 then
			break
		end
        if col ~= 0 then
            lib.LoadSur(surid, 0, 0)
        end
		--说明行在此
		--DrawString(x1+(size+CC.RowPixel)*9-3,y1-(size+CC.RowPixel)*2-CC.RowPixel,"PgUp/PgDn/鼠标滚轮翻页",LimeGreen,size);
		--DrawString(x1+(size+CC.RowPixel)*8-50,y1-(size+CC.RowPixel)*1,"名称黄色为一阶 名称蓝色为高阶 红色为顶阶",LimeGreen,size);
		for i=start,showRow+start-1 do
			for j=1, col do
				local n = i*col+j;
				if n > numItem then
					break;
				end
                
				--设置不同的绘制颜色
                local drawColor=color; 
                if menuItem[n][3] == 2 then
					drawColor = M_DeepSkyBlue
				end
				if menuItem[n][1] == "独孤求败"  or menuItem[n][1] == "扫地老僧"
				 or menuItem[n][1] == "张三丰" 
				  then  
					drawColor = C_RED
                end
				if menuItem[n][1] == "萧玲" or menuItem[n][1] == "梁萧" or menuItem[n][1] == "李寻欢" 
				or menuItem[n][1] == "李白"or menuItem[n][1] == "斗酒僧"  or menuItem[n][1] == "黄裳" 
				or menuItem[n][1] == "逍遥子" or menuItem[n][1] == "达摩" or menuItem[n][1] == "陆渐" 
				or menuItem[n][1] == "寇仲" or menuItem[n][1] == "司空摘星" or menuItem[n][1] == "步惊云"
				or menuItem[n][1] == "冯蘅" or menuItem[n][1] == "张家辉" or menuItem[n][1] == "萧秋水"then
				   drawColor = M_Plum
				   end
                local xx = x1+(j-1)*(size*maxlength/2+CC.RowPixel*2) + CC.MenuBorderPixel
                local yy = y1+(i-start)*(size+CC.RowPixel*2) + CC.MenuBorderPixel
                if n==current then
                    drawColor=selectColor;
                    lib.Background(xx-5, yy-5, xx + size*maxlength/2, yy + size+5, 128, color)
                end
                DrawString(xx,yy,menuItem[n][1],drawColor,size);

            end
        end
		ShowScreen();
		local keyPress, ktype, mx, my = WaitKey(1)
		local mk = false;
		lib.Delay(CC.Frame);

		if keyPress==VK_DOWN then                --Down
			cury = cury + 1;
					if cury == showRow then
						cury = 0
					elseif curx + cury*col > numItem then
						cury = 15
					end
		elseif keyPress==VK_UP then                  --Up
					if cury ~= 15 then
						cury = cury -1;
						if cury < 0 then
							cury = showRow-1;
						end
					else
						if curx + row*col > numItem then
							cury = row - 1
						else
							cury = row
						end
					end
		elseif keyPress==VK_RIGHT then                --RIGHT
                    curx = curx +1;
                    if curx > col then
                        curx = 1;
                    elseif curx + cury*col > numItem then
                        curx = 1;
                    end
		elseif keyPress==VK_LEFT then                  --LEFT
                    curx = curx -1;
                    if curx < 1 then
                        curx = col;
                        if curx + cury*col > numItem then
							curx = numItem - cury*col;
                        end
                    end
		elseif keyPress==VK_PGUP or ktype == 6 then    --PgUp 或 鼠标滚轮上
					if start == 15 then
						start = start - 15;
						curx = 1
						cury = 0
						mk = true;
					end
		elseif keyPress==VK_PGDN or ktype == 7 then    --PgDn 或 鼠标滚轮下	
			if start == 0 then
				start = start + 15;
				curx = 1
				cury = 15
				mk = true;
			end
		else
			if ktype == 2 or ktype == 3 then			--选中
				--无酒不欢：加个逻辑判定防止跳出
				local re1, re2 = curx, cury;
				if mx >= x1 and mx <= x1 + w and my >= y1 and my <= y1 + h then
					curx = math.modf((mx-x1-CC.MenuBorderPixel)/(size*maxlength/2+CC.RowPixel*2)) + 1
					cury = start + math.modf((my - y1 - CC.MenuBorderPixel) / (size + CC.RowPixel*2))
					mk = true;
				end
				if (curx + cury*col) > #menuItem then
					curx = re1
					cury = re2
					mk = false;
				end
			end
			--空格，回车，
			if keyPress==VK_SPACE or keyPress==VK_RETURN or ktype == 5 or (ktype == 3 and mk) then
				current = curx + cury*col;
				if menuItem[current][3]==3 then
				
				elseif menuItem[current][2]==nil then
					local ys = showCXStatic(menuItem[current][4])
					if ys then
						returnValue=current
						break
					end
				else
					local r=menuItem[current][2](menuItem,current)
					if r==1 then
						returnValue= -current;
						break;
					else
						lib.LoadSur(surid, 0, 0)
					end
				end
            end
		end 
		current = curx + cury*col;
    end
	lib.FreeSur(surid)
        
	--返回值，这个是取第4个位置的值
	if returnValue > 0 then
		return menuItem[returnValue][4]
	else
		return returnValue
	end
end

function showCXStatic(id)
	if existFile(CC.Acvmts) then
		dofile(CC.Acvmts)
		local r = false
		local ndChn = {"入门","少侠","大侠","掌门","宗师","传说"}
		local highLvl
		if Achievements.rdsCpltd[id].lvlReached2 > 0 then
			highLvl = Achievements.rdsCpltd[id].lvlReached1.."周"..ndChn[Achievements.rdsCpltd[id].lvlReached2]
		else
			highLvl = "暂无"
		end
		while true do
			if JY.Restart == 1 then
				return
			end
			Cls()
			
			lib.LoadPNG(91, 30 * 2 , 0, 0, 1)
			
			DrawString(390,50-40,JY.Person[id]["姓名"],C_GOLD,CC.FontBig*0.9)
			
			DrawString(80,130,"通关次数："..Achievements.rdsCpltd[id].n.."次",C_WHITE,CC.DefaultFont)
			DrawString(80,200,"最高通关难度："..highLvl,C_WHITE,CC.DefaultFont)
			
			DrawString(CC.ScreenW/2 - 160,CC.ScreenH - 40,"回车键确认选择 ESC退出",LimeGreen,CC.DefaultFont*0.98)
			
			local keypress, ktype, mx, my = lib.GetKey()
			
			if keypress == VK_RETURN then
				r = true
				break
			elseif keypress == VK_ESCAPE or ktype == 4 then
				break
			end
			ShowScreen()
			lib.Delay(CC.Frame)
		end
		return r
	end
end

--无酒不欢：获取武功威力
function get_skill_power(personid, wugongid, wugonglvl)
	local power;
	--到极的武功按10级威力算
	if wugonglvl == 11 then
		wugonglvl = 10
	end
    local spower = 0 
	power = JY.Wugong[wugongid]["攻击力"..wugonglvl] 	
    
    spower = power
    
    if wugongid >= 109 and wugongid <= 112 then
        local xs = 0
        local lx = JY.Wugong[wugongid]['武功类型']
        if lx == 1 then 
            xs = TrueQZ(personid)--JY.Person[personid]["拳掌功夫"]
        elseif lx == 2 then 
            xs = TrueZF(personid)--JY.Person[personid]["指法技巧"]
        elseif lx == 3 then 
            xs = TrueYJ(personid)--JY.Person[personid]["御剑能力"]    
        elseif lx == 4 then 
            xs = TrueSD(personid)--JY.Person[personid]["耍刀技巧"]
        elseif lx == 5 then 
            xs = TrueTS(personid)--JY.Person[personid]["特殊兵器"]
        end
        if isteam(personid) then
            power = limitX(power + xs*3,300,1500)
        else 
            power = 1500
        end
    end
	--学了葵花之后，辟邪的威力
	if wugongid == 48 and PersonKF(personid, 105) then
		power = 1300
	end
    
	--提高天赋内功的威力
	if power < 1000 and Given_NG(personid, wugongid) then
		power = power + 100
		if power > 1000 then
			power = 1000
		end
	end
    
	--觉醒后翻倍的众人
	--王重阳+全真七子，全真剑法
	if wugongid == 39 and JY.Person[0]["六如觉醒"] > 0 then
		if match_ID(personid, 123) or match_ID(personid, 124) or match_ID(personid, 125) or match_ID(personid, 126) or
		match_ID(personid, 127) or match_ID(personid, 128) or match_ID(personid, 129) or match_ID(personid, 68) then
			power = power * 2
		end
	end
	--梅超风，黄衫女九阴白骨爪
	if wugongid == 11 and JY.Person[0]["六如觉醒"] > 0 and (match_ID(personid, 78) or match_ID(personid, 640))then
		power = power * 1.5
	end
	--悲天佛怜
	if wugongid == 189 and (match_ID(personid,9983) or JinGangBR(personid)) then
		power = power * 1.5
	end

	--夏雪宜 金蛇剑法
	if wugongid == 40  and match_ID(personid, 639)then
		power = power * 1.5
	end	
	--阿秀 雪山剑法
	if wugongid == 35 and match_ID_awakened(personid, 582,1)then
		power = power * 1.5
	end	
	--韦一笑，寒冰绵掌
	if wugongid == 5 and JY.Person[0]["六如觉醒"] > 0 and match_ID(personid, 14) then
		power = power * 1.5
	end
	--殷天正，鹰爪功
	if wugongid == 4 and JY.Person[0]["六如觉醒"] > 0 and match_ID(personid, 12) then
		power = power * 1.5
	end
	--朱聪，分筋错骨手
	if wugongid == 117 and JY.Person[0]["六如觉醒"] > 0 and match_ID(personid, 131) then
		power = power * 1.5
	end
	--潇湘子，鹤蛇八打
	if wugongid == 74 and JY.Person[0]["六如觉醒"] > 0 and match_ID(personid, 157) then
		power = power * 2
	end
	--周威信呼延十八鞭威力翻倍
	if match_ID(personid, 612) and wugongid == 206 and JY.Status == GAME_WMAP and WAR.ZWX > 0 then
		power = power *  WAR.ZWX
	end	
	--卓天雄呼延十八鞭威力翻倍
	if match_ID(personid, 613) and wugongid == 206 and JY.Status == GAME_WMAP and WAR.ZWX > 0 then
		power = power *  WAR.ZWX
	end	
	--卓天雄震天铁掌威力翻倍
	if match_ID(personid, 613) and wugongid == 205 and JY.Status == GAME_WMAP and WAR.ZWX > 0 then
		power = power * WAR.ZWX
	end	
	
	--曲非烟持瑶琴威力翻倍
	if match_ID(personid, 510) and wugongid == 73 then
		power = power * 2
	end		
    
	--何铁手战斗中五毒威力翻倍
	if match_ID(personid, 83) and wugongid == 3 and JY.Status == GAME_WMAP and WAR.HTS > 0 then
		power = power * WAR.HTS
	end
    
	--林朝英，惊才绝艳
	if match_ID(personid, 605) then
		power = power * 1.1
	end
    
	--提高天赋外功的威力
	if Given_WG(personid, wugongid) then
		--if power < 1200 then
			power = power + 200
		--elseif power >= 1200 and power < 1400 then
		--	power = 1400
		--end
        if JY.Status == GAME_WMAP then 
            if WAR.PD['雪花六出'][personid] ~= nil and wugongid == 35 then 
                power = power + spower*WAR.PD['雪花六出'][personid]*0.5
            end
        end
	end
    
	--袁冠南 夫妻刀法 1.5倍
	if wugongid == 62  and match_ID(personid, 566) then
		power = power + 300
	end	
    
	--袁紫衣威力翻倍
	if match_ID(personid, 587) and (wugongid == 78 or wugongid == 164) then
		power = power + 300
	end
    
	--天池怪侠
	if match_ID(personid,9988) and wugongid == 10 then
		power = power + 600
	end
	if JY.Person[personid]["武器"] == 200 then
		if wugongid == 8 or wugongid == 14 or wugongid == 185 or wugongid == 202 or wugongid == 201 then
           power = power + 100
        end
    end 
    
	--太极套
	if (wugongid == 16 or wugongid == 46) and Curr_NG(personid, 171) then
	   power = power + 200
	end
    
	--枯荣禅功 一阳指
	if wugongid ==17 and PersonKF(personid, 207) then
	   power = power + 200
	end
	-- 白猿
    if match_ID(personid, 9997) and JY.Person[personid]["坐骑"] == 326 and wugongid == 188 then
       power = power + 500
	end	
	--天山折梅手，虚竹，童姥，无崖子，李秋水，威力提高
	if wugongid == 14 then
		if match_ID(personid, 49) or match_ID(personid, 116) or match_ID(personid, 117) or match_ID(personid, 118) then
			for i = 1, JY.Base["武功数量"] do
				if JY.Person[personid]["武功"..i] ~= 14 and JY.Person[personid]["武功等级"..i] == 999 then
					power = power + 50
				end
			end
		end
	end
    -- 伏魔禅杖 伏魔杖法
	if wugongid == 86 and JY.Person[personid]["武器"] == 323 then
	   power = power + 200
	   end	
    -- 白猿 猿公剑法
	if (wugongid == 188 or wugongid ==156) and JY.Person[personid]["坐骑"] == 326 then
	   power = power + 200
	end		   
    
	if wugongid == 110 and JY.Person[personid]["武器"] == 55 then
	   power = power + 200
	end	
	if wugongid == 111 and JY.Person[personid]["武器"] == 56 then
	   power = power + 200
	end	
	if wugongid == 112 and JY.Person[personid]["武器"] == 57 then
	   power = power + 200
	end	
	--白秀雪山剑法
	if wugongid == 35 then
		if match_ID_awakened(personid, 582,1) then
			for i = 1, JY.Base["武功数量"] do
				if JY.Person[personid]["武功"..i] ~= 35 and JY.Person[personid]["武功等级"..i] == 999 then
					power = power + 100
				end
			end
		end
	end
    -- 丁当金乌刀法
    if wugongid == 61 and match_ID_awakened(personid, 581,1) then
	power = power + 300
	end
	--七宝指环 逍遥武功
    if (wugongid ==8 or wugongid == 14 or wugongid == 98 or wugongid == 101 or wugongid ==185 ) and JY.Person[personid]["武器"] == 200 then
	power = power+100
	end	
	--五岳剑法威力提高
	if wugongid >= 30 and wugongid <= 34 and WuyueJF(personid) then
		power = power + 500
	end
	--五岳剑法+五岳剑诀，威力提高
	if wugongid >= 30 and wugongid <= 34 and PersonKF(personid,175) then
		power = power + 200
	end
	--双剑合壁，威力提高
	if (wugongid == 39 or wugongid == 42  or wugongid == 139) and ShuangJianHB(personid) then
		power = power + 300
	end
	--琴棋书画威力提高
	if (wugongid == 73 or wugongid == 72 or wugongid == 84 or wugongid == 142) and QinqiSH(personid) then
		power = power + 300
	end
	--桃花绝技威力提高
	if (wugongid == 12 or wugongid == 18 or wugongid == 38) and TaohuaJJ(personid) then
		power = power + 200
	end
	--易筋加强少林武学
	if (wugongid == 1  or wugongid == 22 or wugongid == 24 or wugongid == 189
	 or wugongid == 86 or wugongid == 124 or wugongid == 132 or wugongid == 133 or wugongid == 135  or wugongid == 136   or wugongid == 137    
	or wugongid == 65
    or wugongid == 140	or wugongid== 194)	
	and Curr_NG(personid,108) then
        power = power + 200
	end
	--九阴神功对白骨爪威力提高
	if wugongid == 11 and PersonKF(personid, 107) then
		power = power + 200
	end
	--武器装备威力加成
	for i,v in ipairs(CC.ExtraOffense) do
		if v[1] == JY.Person[personid]["武器"] and v[2] == wugongid then
			power = power + v[3]
		end
	end
	--只有战斗中才有的加成
	if JY.Status == GAME_WMAP then
        --太极神功蓄力
        --只有战斗中才有的加成
        if Curr_NG(personid, 171) and (wugongid ==16 or wugongid == 46 ) and WAR.tmp[3000 + personid] ~= nil and WAR.tmp[3000 + personid] > 0 then
            if wugongid ==16 then
                power = power + WAR.tmp[3000 + personid]*1.5
            else			 
                power = power + WAR.tmp[3000 + personid]
            end
        end	
    end		
	--周芷若，谁与争锋
	if JY.Person[personid]["武器"] == 37 and JY.Wugong[wugongid]["武功类型"] == 3 then
		if match_ID(personid, 631) or match_ID(personid,6) then
            power = power + 300
        else
            power = power + 200
        end
    end
    
	--胡一刀 辽东大侠
	if match_ID(personid, 633) and JY.Person[personid]["武器"] == 45  and wugongid == 67 then
		power = power + 200
	end	
    
	--冯蘅
	if match_ID(personid, 588)   and (wugongid == 18 or wugongid == 38 or wugongid == 12 or wugongid == 126) then
		power = power + 200
	end
	return power
end

--无酒不欢：判定天赋外功的函数
function Given_WG(personid, WGid)
	local tw = false;
	for i = 1, 4 do
		if JY.Person[personid]["天赋外功"..i] == WGid then
			tw = true;
			break;
		end
	end
	return tw;
end

--无酒不欢：判定天赋内功的函数
function Given_NG(personid, NGid)
	local tw = false;
	if JY.Person[personid]["天赋内功"] == NGid then
		tw = true;
	end
	return tw;
end

--人物恢复站定
function stands()
	JY.MyCurrentPic=0
	if JY.Person[0]["性别"] == 0 then
		JY.MyPic=CC.MyStartPicM+JY.Base["人方向"]*7+JY.MyCurrentPic;
	else
		JY.MyPic=CC.MyStartPicF+JY.Base["人方向"]*7+JY.MyCurrentPic;
	end
end

--无酒不欢：马车的选择菜单
function TeleportMenu(menu, color, selectColor)
	local x1	--菜单起始X坐标
    local y1	--菜单起始Y坐标
    local w		--菜单宽度
    local h		--菜单高度
	local maxlength		--单位最大长度
	local size = CC.Fontsmall	--字体大小
    
	x1 = CC.MainMenuX+3
    y1 = CC.MainMenuY+CC.Fontsmall*2 +9

	maxlength = 8
	
	w = (size*maxlength/2+CC.RowPixel*4+5)*7 + CC.MenuBorderPixel	--7为列数
    h = (size+CC.RowPixel*2-1)*16 + CC.MenuBorderPixel				--16为最大行数
	
    lib.GetKey();
    Cls();
	
	lib.LoadPNG(91, 13 * 2 , 0 , 0, 1)		--背景图
    
	--建立七个表格来存储不同类型的场景
    local PType_1 = {};
    local PNum_1 = 0;
	local PType_2 = {};
    local PNum_2 = 0;
	local PType_3 = {};
    local PNum_3 = 0;
	local PType_4 = {};
    local PNum_4 = 0;
	local PType_5 = {};
    local PNum_5 = 0;
	local PType_6 = {};
    local PNum_6 = 0;
	local PType_7 = {};
    local PNum_7 = 0;
    
	--v123分别为场景名称，可否进入，场景编号
	--v2为0代表可进入，1代表不可进入
    for i,v in pairs(menu) do
        if v[4] == 1 then
			PNum_1 = PNum_1 +1
			PType_1[PNum_1] = {v[1],v[2],v[3]}
		elseif v[4] == 2 then
			PNum_2 = PNum_2 +1
			PType_2[PNum_2] = {v[1],v[2],v[3]}	
		elseif v[4] == 3 then
			PNum_3 = PNum_3 +1
			PType_3[PNum_3] = {v[1],v[2],v[3]}
		elseif v[4] == 4 then
			PNum_4 = PNum_4 +1
			PType_4[PNum_4] = {v[1],v[2],v[3]}	
		elseif v[4] == 5 then
			PNum_5 = PNum_5 +1
			PType_5[PNum_5] = {v[1],v[2],v[3]}
		elseif v[4] == 6 then
			PNum_6 = PNum_6 +1
			PType_6[PNum_6] = {v[1],v[2],v[3]}
		elseif v[4] == 7 then
			PNum_7 = PNum_7 +1
			PType_7[PNum_7] = {v[1],v[2],v[3]}
		end
    end
	
	--场景信息
	local P_inf = {{PType_1,PNum_1},{PType_2,PNum_2},{PType_3,PNum_3},{PType_4,PNum_4},{PType_5,PNum_5},{PType_6,PNum_6},{PType_7,PNum_7},[0]={0,0}}
	local PType_name = {"客栈城镇","江湖帮派","江湖帮会","人物居所","名山大川","山洞岛屿","杂类场所"}

	--光标的初始位置
	local cursor_x = 1
	local cursor_y = 1
	local current = 1

	--返回值
    local returnValue =-1;
  
    local surid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)

    while true do
		if JY.Restart == 1 then
			break
		end
        lib.LoadSur(surid, 0, 0)
		--DrawString(x1+10,y1-CC.RowPixel*4-7,"X:"..cursor_x.."，Y:"..cursor_y.."，Current:"..current,LimeGreen,size);	--输出测试信息
		for i = 1, 7 do
			--大类名称
		--	DrawString(x1+(i-1)*(size*maxlength/2+CC.RowPixel*4+5)+CC.MenuBorderPixel,y1-CC.RowPixel*6+1,PType_name[i],LimeGreen,size);
			for j = 1, 16 do
				if j > P_inf[i][2] then
					break;
				end
				--确定当前单位编号
				local id = 0
				for jj = 1, i do
					id = id + P_inf[jj-1][2]
				end
				id = id + j
				--无法进入的场景名称为灰色
				local drawColor = color; 
				if P_inf[i][1][j][2] == 1 then
					drawColor = M_DimGray
				end
				local xx = x1+(i-1)*(size*maxlength/2+CC.RowPixel*4+5) + CC.MenuBorderPixel
				local yy = y1+(j-1)*(size+CC.RowPixel*2-1)
				--区别当前选中的单位颜色
				if id == current then
					drawColor = selectColor;
					lib.Background(xx-5, yy-5, xx + size*maxlength/2+5, yy + size + 5, 128, color)
				end
				--显示场景名称
				DrawString(xx,yy,P_inf[i][1][j][1],drawColor,size);
			end
		end
  
        ShowScreen();
        local keyPress, ktype, mx, my = WaitKey(1)
		
		lib.Delay(CC.Frame);
				
		--ktype  1：键盘，2：鼠标移动，3:鼠标左键，4：鼠标右键，5：鼠标中键，6：滚动上，7：滚动下
        if keyPress==VK_ESCAPE or ktype == 4 then
            break;
        elseif keyPress==VK_DOWN then
			cursor_y = cursor_y + 1
			if cursor_y > P_inf[cursor_x][2] then
				cursor_y = 1
			end
		elseif keyPress==VK_UP then
			cursor_y = cursor_y - 1
			if cursor_y < 1 then
				cursor_y = P_inf[cursor_x][2]
			end
		elseif keyPress==VK_RIGHT then
			cursor_x = cursor_x + 1
			if cursor_x > 7 then
				cursor_x = 1
			end
			if cursor_y > P_inf[cursor_x][2] then
				cursor_y = 1
			end
		elseif keyPress==VK_LEFT then
			cursor_x = cursor_x - 1
			if cursor_x < 1 then
				cursor_x = 7
			end
			if cursor_y > P_inf[cursor_x][2] then
				cursor_y = 1
			end
		else
			local mk = false;
			if ktype == 2 or ktype == 3 then
				if mx >= x1 and mx <= x1 + w and my >= y1 and my <= y1 + h then
					cursor_x = math.modf((mx - x1 - CC.MenuBorderPixel)/(size*maxlength/2+CC.RowPixel*4+5)) + 1
					cursor_y = math.modf((my - y1 - CC.MenuBorderPixel) / (size+CC.RowPixel*2-1)) + 1
					mk = true;
				end
				if cursor_y > P_inf[cursor_x][2] then
					cursor_y = P_inf[cursor_x][2]
					mk = false;
				end
			end				
			if  keyPress==VK_SPACE or keyPress==VK_RETURN or (ktype == 3 and mk) then
				if P_inf[cursor_x][1][cursor_y][2] == 0 then
					returnValue=P_inf[cursor_x][1][cursor_y][3];
					break;
				end
			end
		end
		current = 0
		for i = 1, cursor_x do 
			current = current + P_inf[i-1][2]
		end
		current = current + cursor_y
    end
    lib.FreeSur(surid)
    --返回值
	return returnValue
end

--无酒不欢：判断队伍是不是有两个空位
function More_than_2_vacant_slot()
	if JY.Base["队伍14"] == -1 and JY.Base["队伍15"] == -1 then
		return true
	end
	return false
end

--无酒不欢：个人觉醒
function awakening(id, value)
	local xwperson;	--判定要觉醒的人
	if id == JY.Base["畅想"] then
		xwperson = 0
	else
		xwperson = id
	end
    
	JY.Person[xwperson]["个人觉醒"] = JY.Person[xwperson]["个人觉醒"] + value
end

--无酒不欢：增加武常
function kungfu_knowledge(id, value)
	local xwperson;	--判定要增加武常的人
	if id == JY.Base["畅想"] then
		xwperson = 0
	else
		xwperson = id
	end
	JY.Person[xwperson]["武学常识"] = JY.Person[xwperson]["武学常识"] + value
end

--无酒不欢：判定是否为指定ID的人物，并且判定是否达到指定觉醒次数
function match_ID_awakened(personid, id, awkntimes)
    
	if CC.Copy[personid] ~= nil then 
		personid = CC.Copy[personid]
	end
    
	if personid == id then
		if JY.Person[personid]["个人觉醒"] >= awkntimes then
			return true
		else
			return false
		end
	elseif personid == 0 and JY.Base["畅想"] == id then
		if JY.Person[0]["个人觉醒"] >= awkntimes then
			return true
		else
			return false
		end

    elseif personid == 0 and JY.Base["单通"] == 2 and instruct_16(id) then
        if JY.Person[0]["个人觉醒"] >= awkntimes then
            return true
        else
            return false
        end

	else
		return false
	end
end

--直接设定指定人物的资质
function set_potential(id, value)
	local xwperson;	--判定要指定资质的人
	if id == JY.Base["畅想"] or (JY.Base["单通"]==2 and instruct_16(id)) then
		xwperson = 0		
	else
		xwperson = id
	end
	JY.Person[xwperson]["资质"] = value
end

--无酒不欢：判定是不是显示特技
function secondary_wugong(wugongid)
	--轻功
	if JY.Wugong[wugongid]["武功类型"] == 7 then
		return true
	--吸功，金刚不坏，五岳剑诀 李飞刀 武穆遗书
	elseif wugongid == 85 or wugongid == 87 or wugongid == 88 or wugongid == 144 or wugongid == 175  or wugongid == 182  or wugongid == 199 or wugongid == 43 then
		return true
	end
	return false
end

--无酒不欢：判定主运内功的函数
function Curr_NG(personid, NGid)
	if JY.Person[personid]["主运内功"] == NGid then
		return true
	end	
	--天罡的判定
	if JY.Base["标准"] == 6  or  JY.Base["畅想"] == 637 or  JY.Base["畅想"] == 27 or JY.Base["畅想"] == 189  then
		--如果是天内，并且已经学会，则自动主运
		if JY.Person[personid]["天赋内功"] == NGid and PersonKF(personid, NGid) then
            Hp_Max(personid)
			return true
		end
	end
	
	if match_ID(personid,511) and NGid == 227 then 
		return true
	end	
	
	return false
end

--无酒不欢：判定主运轻功的函数
function Curr_QG(personid, QGid)
	if JY.Person[personid]["主运轻功"] == QGid then
		return true
	elseif personid == 577 then
  	if JY.Person[personid]["天赋轻功"] == QGid and PersonKF(personid, QGid)  then
			return true
			else
			return false
			end
	else
		return false
	end
end

--无酒不欢：判定人物面板上极的个数
function calc_mas_num(id)
	local mas_num = 0;
	for i = 1, JY.Base["武功数量"] do
		if JY.Person[id]["武功等级" .. i] == 999 then
			mas_num = mas_num + 1;
		end
	end
	return mas_num
end

--无酒不欢：判定是否为指定ID的人物，用作天赋等判定
function match_ID(personid, id)
	if personid == 0 then 
		if CC.TG[id] == 1 then 
			return true
		end
	end
	if personid == 0 and JY.Base["畅想"] > 0 then
		personid = JY.Base["畅想"]
	end	

    if (personid==0 or personid == JY.Base["畅想"]) and JY.Base["单通"]==2 and instruct_16(id) then
        return true
    end

	if CC.Copy[personid] ~= nil then 
		personid = CC.Copy[personid]
	end
	if CC.PTF[personid] ~= nil then 
		local tf = CC.PTF[personid]
		if tf[id] == 1 then 
			return true
		end
	end	

	return false
end

--无酒不欢：判定连击率
function Person_LJ(pid)
	--根据内轻资质计算基础连击率
	local LJ1 = math.modf(JY.Person[pid]["轻功"] / 18)
	local LJ2 = math.modf((JY.Person[pid]["内力最大值"] + JY.Person[pid]["内力"]) / 1000)
	local LJ3 = math.modf(JY.Person[pid]["资质"] / 10)
	local LJ = 0
	LJ = (LJ1 + LJ2 + LJ3) / 2
	
	--灭绝、裘千仞、洪教主、成昆、萧半和、戚长发、令狐冲二觉之后，连击率+70%
	if match_ID(pid, 6) or match_ID(pid, 67) or match_ID(pid, 71) or match_ID(pid, 18)  or match_ID(pid, 594) or match_ID_awakened(pid, 35, 2) then
		LJ = LJ + (100 - LJ) * 0.7
	end
	--何足道，100%血无加成，0血100%加成
	if match_ID(pid, 586) then
	local HZDLJ = 0
	HZDLJ = (1-JY.Person[pid]["生命"] / JY.Person[pid]["生命最大值"])*100
	LJ = LJ + HZDLJ
	end		
--萧半和连击+50% 闪电惊鸿
    if match_ID(pid, 189) or match_ID(pid, 9996) then
	   LJ = LJ +(100-LJ)*0.5
	   end
	--连击武功，每个连击+2.5%
	--百花，空明，玉女，泰山，鸳鸯，反两仪，杨家枪，海叟，银锁，连城，去烦恼，黑风, 素心
	local ljup = {10, 15, 42, 31, 54, 60, 68, 76, 79, 114, 124, 131, 139}
	for i = 1, JY.Base["武功数量"] do
		if JY.Person[pid]["武功" .. i] > 0 then
			for ii = 1, #ljup do
				if JY.Person[pid]["武功" .. i] == ljup[ii] then
					LJ = LJ + (100 - LJ) * 0.025
				end
			end
		else
			break;
		end
	end
	
	--独孤九剑连击+5%   
	for i = 1, JY.Base["武功数量"] do
		if JY.Person[pid]["武功" .. i] == 47 then
			LJ = LJ + (100 - LJ) * 0.05
            break
		end
	end

	--论剑打赢林朝英奖励+50%
	if pid == 0 and JY.Person[605]["论剑奖励"] == 1 then
		LJ = LJ + (100 - LJ) * 0.5
	end
	
	--实战，每40点+1%
	local jp = JY.Person[pid]["实战"] / 4000
	LJ = LJ + (100 - LJ) * jp
	
	
	--主运九阴+50% 
	if  Curr_NG(pid, 107) and (JY.Person[pid]["内力性质"] == 0 or JY.Person[pid]["内力性质"] == 3 ) then
		LJ = LJ + (100 - LJ) * 0.5
	end
	--双剑合壁 连击率+30%
		if  ShuangJianHB(pid) == true then
			LJ = LJ + (100 - LJ) * 0.3
		end
	--流星剑 连击率+10%
		if JY.Person[pid]["武器"]  == 38 then
			LJ = LJ + (100 - LJ) * (JY.Thing[38]["装备等级"]/10 -0.1)
		end	 

	--宁中则 玉女十九剑连击率+30%
	if match_ID(pid,649) and WAR.YLSJJ == 1 and JY.Status == GAME_WMAP then
		LJ = LJ + (100 - LJ) * 0.3
	end	
	--焦宛儿在场，全体加10%
	if inteam(pid) and JY.Status == GAME_WMAP then
		for wid = 0, WAR.PersonNum - 1 do
			if match_ID(WAR.Person[wid]["人物编号"], 607) and WAR.Person[wid]["死亡"] == false and WAR.Person[wid]["我方"] then
				LJ = LJ + (100 - LJ) * 0.1
				break
			end
		end
	end

	--东方不败、萧远山 必连击
	if match_ID(pid, 27) or match_ID(pid, 112)  then
		LJ = 100
	end
	
    if match_ID(pid, 9965) then 
        LJ = LJ*0.2
        if JY.Status == GAME_WMAP then 
            if WAR.LQZ[pid] == 100 then 
                LJ = 100
            end
        end
    end
    
	--连击率下限1
    if LJ < 1 then
		LJ = 1
    end
	
	--取整
	LJ = math.modf(LJ)
	
	return LJ
end

--无酒不欢：判定暴击率
function Person_BJ(pid)
    --根据内攻体力计算基础暴击率
    local BJ1 = math.modf(JY.Person[pid]["攻击力"] / 18)
    local BJ2 = math.modf((JY.Person[pid]["内力最大值"] + JY.Person[pid]["内力"]) / 1000)
    local BJ3 = math.modf(JY.Person[pid]["体力"] / 10)
    local BJ = 0
    BJ = (BJ1 + BJ2 + BJ3) / 2

    --血刀老祖、裘千仞、洪教主、任我行、玉真子、，暴击率+70%
    if match_ID(pid, 97) or match_ID(pid, 67) or match_ID(pid, 71) or match_ID(pid, 26) or match_ID(pid, 184) then
		BJ = BJ + (100 - BJ) * 0.7
    end
	--井月八法暴击率+5%   
	for i = 1, JY.Base["武功数量"] do
		if JY.Person[pid]["武功" .. i] == 181 then
			BJ = BJ + (100 - BJ) * 0.05
		end
	end	
	--袁承志，萧半和 暴击率+50%
    if match_ID(pid, 54)  or match_ID(pid, 189)then
		BJ = BJ + (100 - BJ) * 0.5
    end
    --世尊降魔暴击提高
	if ShiZunXM(pid) == true then
		BJ = BJ + (100 - BJ) * 0.5
	end
	--陆无双 暴击率+30%
    if match_ID(pid, 580) then
		BJ = BJ + (100 - BJ) * 0.3
    end	
	--陆无双 暴击率+30%
    if match_ID(pid, 580) then
		BJ = BJ + (100 - BJ) * 0.3
    end	
	--何足道，100%血无加成，0血100%加成
	if match_ID(pid, 586) then
		local HZDBJ = 0
		HZDBJ = (1-JY.Person[pid]["生命"] / JY.Person[pid]["生命最大值"])*100
		BJ = BJ + HZDBJ
	end	
    --杨过，血量少于四分之一时，基础暴击率3倍
    if match_ID(pid, 58) and JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 4 then
		BJ = BJ * 3
    --杨过，血量少于二分之一，基础暴击率2倍
    elseif match_ID(pid, 58) and JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 2 then
		BJ = BJ * 2
    end
	
	--暴击武功，每个暴击+2.5%
	--弹指，大力，全真，金蛇，奇门三才，燃木，裴将军，黄沙，鹤蛇，金乌，玄冥，铁指诀，一阳指
    local bjup = {18, 22, 39, 40, 56, 65, 71, 78, 74, 61, 21, 121, 17}
    for i = 1, JY.Base["武功数量"] do
		if JY.Person[pid]["武功" .. i] > 0 then
			for ii = 1, #bjup do
				if JY.Person[pid]["武功" .. i] == bjup[ii] then
					BJ = BJ + (100 - BJ) * 0.025
				end
			end
		else
			break;
		end
    end

	  
	--实战，每40点+1%
	local jp = JY.Person[pid]["实战"] / 4000
	BJ = BJ + (100 - BJ) * jp
	
	--主运逆运+50%
	if Curr_NG(pid, 104) then
	    BJ = BJ + (100 - BJ) * 0.5
    elseif PersonKF(pid,107) then
		BJ = BJ + (100 - BJ) * 0.3
	end

	--寇仲
	if match_ID(pid, 578) then
	local df = 0
		for i = 1, JY.Base["武功数量"] do
			if JY.Wugong[JY.Person[0]["武功" .. i]]["武功类型"] == 4 and JY.Person[0]["武功等级" .. i] == 999 then
				df = df + 1
				if df > 8 then
				df = 8
			end
		end
		BJ = BJ + (100 - BJ) *df*0.05
		end
		end
	--萧峰、灭绝、萧远山，必暴击
    if match_ID(pid, 50) or match_ID(pid, 6) or match_ID(pid, 112) or (match_ID(pid, 49) and pid == 0)then
		BJ = 100
    end
	
	--只有战斗中才有的加成
	if JY.Status == GAME_WMAP then
		--欧阳锋 逆运状态下必暴击
		if match_ID(pid, 60) and WAR.tmp[1000+pid] == 1 then
			BJ = 100
		end
		
		--怒气值100，非斗转下必暴击
		if WAR.LQZ[pid] == 100 and WAR.DZXY ~= 1 then
			BJ = 100
		end
	end
	
	--暴击率下限1
    if BJ < 1 then
		BJ = 1
    end
	
	--取整
	BJ = math.modf(BJ)
	
	return BJ
end

--无酒不欢：返回人物所学内功的数量
function Num_of_Neigong(id)
	local num = 0
	for i = 1, JY.Base["武功数量"] do
		local kfid = JY.Person[id]["武功"..i]
		if JY.Wugong[kfid]["武功类型"] == 6 then
			num = num + 1
		end
	end
	return num
end

--无酒不欢：判定一个人物是否满足五岳剑法的条件
function WuyueJF(id)
	local wuyuenum = 0;
	for i = 1, JY.Base["武功数量"] do
		local kfid = JY.Person[id]["武功"..i]
		local klvl = JY.Person[id]["武功等级"..i]
		if kfid >= 30 and kfid <= 34 and klvl == 999 then
			wuyuenum = wuyuenum + 1
		end
	end
	if wuyuenum >= 5 then
		return true
	else
		return false
	end
end

--无酒不欢：真实拳掌能力的判定
function TrueQZ(id)
	local qz = JY.Person[id]["拳掌功夫"]
	--金丝手套
	if JY.Person[id]["武器"] == 239 then
		local add = 10
		if JY.Thing[239]["装备等级"] >= 5 then
			add = 30
		elseif JY.Thing[239]["装备等级"] >= 4 then
			add = 25
		elseif JY.Thing[239]["装备等级"] >= 3 then
			add = 20
		elseif JY.Thing[239]["装备等级"] >= 2 then
			add = 15
		end
		qz = qz + add
	end
	if match_ID(id, 508) and JY.Status == GAME_WMAP then
		local df = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == false  then
				df = df +1
			end          
	    end	
		 qz = qz + df * 5		
	end	
	--太玄，战场系数*140%
	if PersonKF(id, 102) and JY.Status == GAME_WMAP then
		qz = qz + math.modf(qz*0.4)
	end
	return qz
end

--无酒不欢：真实指法能力的判定
function TrueZF(id)
	local zf = JY.Person[id]["指法技巧"]
	--金丝手套
	if JY.Person[id]["武器"] == 239 then
		local add = 10
		if JY.Thing[239]["装备等级"] >= 5 then
			add = 30
		elseif JY.Thing[239]["装备等级"] >= 4 then
			add = 25
		elseif JY.Thing[239]["装备等级"] >= 3 then
			add = 20
		elseif JY.Thing[239]["装备等级"] >= 2 then
			add = 15
		end
		zf = zf + add
	end
	if match_ID(id, 508)  and JY.Status == GAME_WMAP then
		local df = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == false  then
				df = df +1
			end         	
	    end	
		 zf = zf + df * 5	
	end		
	--太玄，战场系数*140%
	if PersonKF(id, 102) and JY.Status == GAME_WMAP then
		zf = zf + math.modf(zf*0.4)
	end
	return zf
end

--无酒不欢：真实御剑能力的判定
function TrueYJ(id)
	local yj = JY.Person[id]["御剑能力"]
	--五岳剑法
	if WuyueJF(id) then
		yj = yj + 50
	end
	--战斗中的加成
	if JY.Status == GAME_WMAP then
		--剑胆琴心
		if WAR.JDYJ[id] then
			yj = yj + WAR.JDYJ[id]
		end
		--太玄，战场系数*140%
		if PersonKF(id, 102) then
			yj = yj + math.modf(yj*0.4)
		end
	   if match_ID(id, 508) and JY.Status == GAME_WMAP then
		   local df = 0
		   for j = 0, WAR.PersonNum - 1 do
			   if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == false  then
				   df = df +1
			   end           	
	       end	
		 yj = yj + df * 5	
	   end		
		--步惊云
        if match_ID(id, 584)  then
		   local JF = 0
		   for i = 1, JY.Base["武功数量"] do
			  if JY.Wugong[JY.Person[id]["武功" .. i]]["武功类型"] == 3 then
				 JF = JF + 1
			  end
		   end
		yj =yj + JF * 10
	   end
	end
	return yj
end

--无酒不欢：真实耍刀能力的判定
function TrueSD(id)
	local sd = JY.Person[id]["耍刀技巧"]
	--太玄，战场系数*140%
	if PersonKF(id, 102) and JY.Status == GAME_WMAP then
		sd = sd + math.modf(sd*0.4)
	end
	if match_ID(id, 508)  and JY.Status == GAME_WMAP then
		local df = 0
		for j = 0, WAR.PersonNum - 1 do
		    if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == false  then
				   df = df +1
			   end         
	       end
	        sd = sd + df * 5		
	   end	
	return sd
end

--无酒不欢：真实特殊能力的判定
function TrueTS(id)
	local ts = JY.Person[id]["特殊兵器"]
	--太玄，战场系数*140%
	if PersonKF(id, 102) and JY.Status == GAME_WMAP then
		ts = ts + math.modf(ts*0.4)
	end
	if match_ID(id, 508)  and JY.Status == GAME_WMAP then
		local df = 0
		for j = 0, WAR.PersonNum - 1 do
		    if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == false  then
				   df = df +1
			   end          	
	       end
        ts = ts + df * 5		
	   end	
	return ts
end

--无酒不欢：判定一个人物是否满足琴棋书画的条件
function QinqiSH(id)
	local qinqinum = 0;
	for i = 1, JY.Base["武功数量"] do
		local kfid = JY.Person[id]["武功"..i]
		local klvl = JY.Person[id]["武功等级"..i]
		if (kfid == 73 or kfid == 72 or kfid == 84 or kfid == 142) and klvl == 999 then
			qinqinum = qinqinum + 1
		end
	end
	if qinqinum >= 4 then
		return true
	else
		return false
	end
end

--随风飘叶 调整队友顺序
function Menu_TZDY()
   local menu = {}
   local px={}
   local m=0
   --队友超过2人才会生效
   if JY.Base["队伍" .. 3]>0 then
		Cls()
		DrawStrBox(CC.MainMenuX,CC.MainSubMenuY,"需要调整谁的位置",LimeGreen,CC.DefaultFont,C_GOLD);
		local nexty=CC.MainSubMenuY+CC.SingleLineHeight;
		for i=1,CC.TeamNum do
			menu[i]={"",nil,0};
			local id=JY.Base["队伍" .. i]
			if id>0 then
				menu[i]={"",nil,0};
				if JY.Person[id]["生命"]>0 then
					menu[i][1]=JY.Person[id]["姓名"];
					menu[i][3]=1;
				end
			end
		end  
   
		local r = -1;
		while true do
			r = ShowMenu(menu,#menu,0,CC.MainMenuX,CC.MainSubMenuY+CC.SingleLineHeight,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE)
			if px["交换人"]==nil and r>1 then
				px["交换人"]=r
				menu[r]={"",nil,0}
				Cls()
				DrawStrBox(CC.MainMenuX,CC.MainSubMenuY,JY.Person[JY.Base["队伍" .. r]]["姓名"].."和谁交换位置",LimeGreen,CC.DefaultFont,C_GOLD);
			elseif r>1 and px["交换人"]~=nil and r ~=px["交换人"] then	
				local m1=JY.Base["队伍" .. r]
				local m2=JY.Base["队伍" .. px["交换人"]]
				JY.Base["队伍" .. r]=m2
				JY.Base["队伍" .. px["交换人"]]=m1
				say("Ｇ"..JY.Person[m2]["姓名"].."Ｗ 和 Ｇ"..JY.Person[m1]["姓名"].."Ｗ 交换了位置。",m2,1)
				Cls()
				--return
				break
			--无酒不欢：增加ESC退出功能
			else
				break
			end
		end
	end
end

--无酒不欢：画一条线
function DrawSingleLine(x1, y1, x2, y2, color)
	lib.DrawRect(x1 + 1, y1 + 1, x2, y2, color)
	lib.DrawRect(x1, y1, x2 - 1, y2 - 1, color)
end

--改变天外
function SetTianWai(personid, x, wugongid)
	local xwperson;	--判定要洗天外的人
	if personid == JY.Base["畅想"] then
		xwperson = 0
	else
		xwperson = personid
	end	
	JY.Person[xwperson]["天赋外功"..x] = wugongid
end

--改变天内
function SetTianNei(personid, wugongid)
	local xwperson;	--判定要洗天内的人
	if personid == JY.Base["畅想"] then
		xwperson = 0
	else
		xwperson = personid
	end	
	JY.Person[xwperson]["天赋内功"] = wugongid
end

--改变天轻
function SetTianQing(personid, wugongid)
	local xwperson;	--判定要洗天轻的人
	if personid == JY.Base["畅想"] then
		xwperson = 0
	else
		xwperson = personid
	end	
	JY.Person[xwperson]["天赋轻功"] = wugongid
end

--学会互搏
function SetHuBo(personid)
	local xwperson;
	if personid == JY.Base["畅想"] then
		xwperson = 0
	else
		xwperson = personid
	end	
	JY.Person[xwperson]["左右互搏"] = 1
end

--无酒不欢：判定一个人物是否满足桃花绝技的条件
function TaohuaJJ(id)
	--郭襄自动满足
	if match_ID(id, 626) then
		return true
	end
	local taohuanum = 0;
	for i = 1, JY.Base["武功数量"] do
		local kfid = JY.Person[id]["武功"..i]
		local klvl = JY.Person[id]["武功等级"..i]
		if (kfid == 12 or kfid == 18 or kfid == 38) and klvl == 999 then
			taohuanum = taohuanum + 1
		end
	end
	if taohuanum >= 3 then
		return true
	else
		return false
	end
end

--计算人物五系兵器值之和
function Xishu_sum(id)
	local sum = 0
	sum = sum + TrueQZ(id)
	sum = sum + TrueZF(id)
	sum = sum + TrueYJ(id)
	sum = sum + TrueSD(id)
	sum = sum + TrueTS(id)
	return sum
end

--求人物五系兵器值最高的一项
function Xishu_max(id)
	local m = 0
	local xishu = {TrueQZ,TrueZF,TrueYJ,TrueSD,TrueTS}
	for i = 1, #xishu do
		local x = xishu[i](id)
		if x > m then
			m = x
		end
	end
	return m
end

--剪裁版背景图
function Clipped_BgImg(x1,y1,x2,y2,picnum)
	lib.SetClip(x1 + 2, y1 + 2, x2 - 1, y2 - 1)
	lib.LoadPNG(1, picnum * 2 , 0 , 0, 1)
	lib.SetClip(0,0,0,0)
end

--显示带边框的文字
function DrawBoxTitle(width, height, str, color)
	local s = 4
	local x1, y1, x2, y2, tx1, tx2 = nil, nil, nil, nil, nil, nil
	local fontsize = s + CC.DefaultFont
	local len = string.len(str) * fontsize / 2
	x1 = (CC.ScreenW - width) / 2
	x2 = (CC.ScreenW + width) / 2
	y1 = (CC.ScreenH - height) / 2
	y2 = (CC.ScreenH + height) / 2
	tx1 = (CC.ScreenW - len) / 2
	tx2 = (CC.ScreenW + len) / 2
	lib.Background(x1, y1 + s, x1 + s, y2 - s, 128)
	lib.Background(x1 + s, y1, x2 - s, y2, 128)
	lib.Background(x2 - s, y1 + s, x2, y2 - s, 128)
	lib.Background(tx1, y1 - fontsize / 2 + s, tx2, y1, 128)
	lib.Background(tx1 + s, y1 - fontsize / 2, tx2 - s, y1 - fontsize / 2 + s, 128)
	local r, g, b = GetRGB(color)
	DrawBoxTitle_sub(x1 + 1, y1 + 1, x2, y2, tx1 + 1, y1 - fontsize / 2 + 1, tx2, y1 + fontsize / 2, RGB(math.modf(r / 2), math.modf(g / 2), math.modf(b / 2)))
	DrawBoxTitle_sub(x1, y1, x2 - 1, y2 - 1, tx1, y1 - fontsize / 2, tx2 - 1, y1 + fontsize / 2 - 1, color)
	DrawString(tx1 + 2 * s, y1 - (fontsize - s) / 2, str, color, CC.DefaultFont)
end

--无酒不欢：判定一个人物是否满足除却四相的条件
--同时修炼多罗叶指/大智无定指/无相劫指/拈花指到极
function ChuQueSX(id)
	local sixiangnum = 0;
	for i = 1, JY.Base["武功数量"] do
		local kfid = JY.Person[id]["武功"..i]
		local klvl = JY.Person[id]["武功等级"..i]
		if (kfid == 132 or kfid == 133 or kfid == 136 or kfid == 137) and klvl == 999 then
			sixiangnum = sixiangnum + 1
		end
	end
	if sixiangnum >= 4 then
		return true
	else
		return false
	end
end

--绘制一片四角凹进的背景
function DrawShades(x1,y1,x2,y2,color)
	local s=4;
	lib.Background(x1+4,y1,x2-4,y1+s,128,color);
	lib.Background(x1+1,y1+1,x1+s,y1+s,128,color);
	lib.Background(x2-s,y1+1,x2-1,y1+s,128,color);
	lib.Background(x1,y1+4,x2,y2-4,128,color);
	lib.Background(x1+1,y2-s,x1+s,y2-1,128,color);
	lib.Background(x2-s,y2-s,x2-1,y2-1,128,color);
	lib.Background(x1+4,y2-s,x2-4,y2,128,color);
end

--物品详细说明
function detailed_info(thingID)
	local str=JY.Thing[thingID]["代号"] .. JY.Thing[thingID]["名称"]
	local str2=JY.Thing[thingID]["物品说明"]
	local str3=JY.Thing[thingID]["名称"]	
	if ItemInfo[thingID]==nil then
		return
	end
	local info = {}
	info = ItemInfo[thingID]
	local function strcolor_switch(s)
		local Color_Switch={{"Ｒ",PinkRed},{"Ｇ",C_GOLD},{"Ｂ",C_BLACK},{"Ｗ",C_WHITE},{"Ｏ",C_ORANGE},{"Ｌ",LimeGreen},{"Ｄ",M_DeepSkyBlue},{"Ｚ",Violet}}
		for i = 1, 8 do
			if Color_Switch[i][1] == s then
				return Color_Switch[i][2]
			end
		end
	end
	local maxRowExisting = #info		--当前说明总行数
	local maxRowDisplayable = 11		--当面页面可以显示的最大行数
	if maxRowDisplayable > maxRowExisting-1 then
		maxRowDisplayable = maxRowExisting-1
	end
	local startingRow = 1
	local size = CC.Fontsmall
	while true do
		if JY.Restart == 1 then
			break
		end
		Cls()
		lib.LoadPNG(91, 30 * 2 , 0 , 0, 1)
		DrawString(CC.ScreenW/2,14.5,str3,C_GOLD,CC.ThingFontSize)
		DrawString(22,64.5,str2,C_ORANGE,CC.ThingFontSize)
		local row = 1
		for i = startingRow, startingRow+maxRowDisplayable do
			local tfstr = info[i]
			if string.sub(tfstr,1,2) == "Ｎ" then
				row = row + 1
			else
				local color;
				color = strcolor_switch(string.sub(tfstr,1,2))
				tfstr = string.sub(tfstr,3,-1)
				DrawString(22, 80 + (size+CC.RowPixel*2) * (row), tfstr, color, size)
				row = row + 1
			end
		end
		--上下翻的箭头显示
		if startingRow > 1 then
			DrawString(CC.ScreenW-40, 110, "↑", C_GOLD, size)
		end
		if startingRow+maxRowDisplayable < maxRowExisting then
			DrawString(CC.ScreenW-40, CC.ScreenH-140, "↓", C_GOLD, size)
		end
		DrawString(CC.ScreenW-220,CC.ScreenH-40, "按F1返回物品菜单", C_ORANGE,size)
		ShowScreen()
		local keypress, ktype, mx, my = WaitKey(1)
		if keypress==VK_ESCAPE or keypress==VK_RETURN or keypress==VK_F1 or ktype == 4 then
			return
		elseif keypress==VK_UP and startingRow > 1 then
			startingRow = startingRow - 1
		elseif keypress==VK_DOWN and startingRow+maxRowDisplayable < maxRowExisting then
			startingRow = startingRow + 1
		end
	end
end

--无酒不欢：判定一个人物是否满足紫气天罗的条件
function ZiqiTL(id)
	local ziqinum = 0;
	for i = 1, JY.Base["武功数量"] do
		local kfid = JY.Person[id]["武功"..i]
		local klvl = JY.Person[id]["武功等级"..i]
		if (kfid == 3 or kfid == 5 or kfid == 21  or kfid == 118 or kfid == 120 ) and klvl == 999 then
			ziqinum = ziqinum + 1
		end
	end
	if ziqinum >= 5 then
		return true
	else
		return false
	end
end

--无酒不欢：判定一个人物是否满足剑胆琴心的条件
function JiandanQX(id)
	local jiandannum = 0;
	for i = 1, JY.Base["武功数量"] do
		local kfid = JY.Person[id]["武功"..i]
		local klvl = JY.Person[id]["武功等级"..i]
		if (kfid == 47 or kfid == 73) and klvl == 999 then
			jiandannum = jiandannum + 1
		end
	end
	if jiandannum >= 2 then
		return true
	else
		return false
	end
end

--无酒不欢：判定一个人物是否满足天衣无缝的条件
function TianYiWF(id)
	local tianyinum = 0;
	for i = 1, JY.Base["武功数量"] do
		local kfid = JY.Person[id]["武功"..i]
		local klvl = JY.Person[id]["武功等级"..i]
		if (kfid == 54 or kfid == 62) and klvl == 999 then
			tianyinum = tianyinum + 1
		end
	end
	if tianyinum >= 2 then
		return true
	else
		return false
	end
end

--无酒不欢：举火燎原，金乌+燃木+火焰刀
function JuHuoLY(id)
	local juhuonum = 0;
	for i = 1, JY.Base["武功数量"] do
		local kfid = JY.Person[id]["武功"..i]
		local klvl = JY.Person[id]["武功等级"..i]
		if (kfid == 61 or kfid == 65 or kfid == 66) and klvl == 999 then
			juhuonum = juhuonum + 1
		end
	end
	if juhuonum >= 3 then
		return true
	else
		return false
	end
end

-- 世尊降魔 伏魔杵 金刚伏魔圈 伏魔杖法 罗汉伏魔功
function ShiZunXM(id)
	local sm = 0;
	for i = 1, JY.Base["武功数量"] do
		local kfid = JY.Person[id]["武功"..i]
		local klvl = JY.Person[id]["武功等级"..i]
		if  kfid == 96 or kfid == 86 or kfid == 83 or kfid == 82 then
			sm = sm + 1
		end
	end
	if sm >= 4 then
		return true
	else
		return false
	end
end
--双剑合壁 全真剑法 + 玉女剑
function ShuangJianHB(id)
	local shuangjiannum = 0;
	for i = 1, JY.Base["武功数量"] do
		local kfid = JY.Person[id]["武功"..i]
		local klvl = JY.Person[id]["武功等级"..i]
		if kfid == 39 or kfid == 42 or kfid == 154 or kfid == 100 or kfid == 139 then
			shuangjiannum = shuangjiannum + 1
		end
	end
	if shuangjiannum >= 3 then
		return true
	else
		return false
	end
end
--无酒不欢：利刃寒锋，修罗+阴风+沧溟
function LiRenHF(id)
	local lirennum = 0;
	for i = 1, JY.Base["武功数量"] do
		local kfid = JY.Person[id]["武功"..i]
		local klvl = JY.Person[id]["武功等级"..i]
		if (kfid == 58 or kfid == 174 or kfid == 153) and klvl == 999 then
			lirennum = lirennum + 1
		end
	end
	if lirennum >= 3 then
		return true
	else
		return false
	end
end

--换装
function Avatar_Switch(id)
	--判断是否畅想
	local Ani_id = id
	if id == 0 and JY.Base["畅想"] > 0 then
		Ani_id = JY.Base["畅想"]
	end
	if Avatar[Ani_id] == nil then
		return
	end
	local r = JYMsgBox("一键换装", "请选择"..JY.Person[id]["姓名"].."的造型", {Avatar[Ani_id][1].name,Avatar[Ani_id][2].name}, #Avatar[Ani_id], JY.Person[id]["头像代号"])
	JY.Person[id]["头像代号"] = Avatar[Ani_id][r].num
	JY.Person[id]["半身像"] = JY.Person[Ani_id]["半身像"]
	for i = 1, 5 do
		JY.Person[id]["出招动画帧数" .. i] = Avatar[Ani_id][r].frameNum[i]
		JY.Person[id]["出招动画延迟" .. i] = Avatar[Ani_id][r].frameDelay[i]
		JY.Person[id]["武功音效延迟" .. i] = Avatar[Ani_id][r].soundDelay[i]
	end
end

function Teammember_View()

	local choice = 1

	while true do
		if JY.Restart == 1 then
			return
		end
		Cls()
		
		lib.LoadPNG(96, 1 * 2 , 0, 0, 1)
		
		local x = 8
		for i = 1, 5 do
			if choice ~= i then
				lib.SetClip(x + 10, CC.ScreenH-579 + 13, x + 184 -10, CC.ScreenH-579 + 575)
				lib.LoadPNG(95, i * 2 , x - 90, CC.ScreenH-579, 1)
				
				local h = 494
				local space = 35
				local color = C_WHITE
				
				local indent = 0
				
				if string.len(JY.Person[i]["姓名"]) == 8 then
					indent = 29
				elseif string.len(JY.Person[i]["姓名"]) == 6 then
					indent = 14
				end
				
				DrawString(x + 61 - indent, h, JY.Person[i]["姓名"],color,CC.DefaultFont)
				h = h + space
				
				DrawString(x + 58, h, "LV."..JY.Person[i]["等级"],color,CC.Fontsmall)
				h = h + space
				
				DrawString(x + 41, h, "攻击 "..JY.Person[i]["攻击力"],color,CC.Fontsmall)
				h = h + space
				
				DrawString(x + 41, h, "防御 "..JY.Person[i]["防御力"],color,CC.Fontsmall)
				h = h + space
				
				DrawString(x + 41, h, "轻功 "..JY.Person[i]["轻功"],color,CC.Fontsmall)
				h = h + space
			end
			x = x + 184
		end
		
		lib.SetClip(0,0,0,0)
		
		x = 8
		for i = 1, 5 do
			if choice == i then
				lib.LoadPNG(96, 3 * 2 , x, CC.ScreenH-579, 1)
			else
				lib.LoadPNG(96, 2 * 2 , x, CC.ScreenH-579, 1)
			end
			x = x + 184
		end
		
		x = 8
		for i = 1, 5 do
			if choice == i then
				lib.SetClip(x + 10, CC.ScreenH-579 + 13, x + 184 -10, CC.ScreenH-579 + 575)
				lib.LoadPNG(95, i * 2 , x - 90, CC.ScreenH-579, 1)
				
				local h = 494
				local space = 35
				local color = LightYellow2
				
				local indent = 0
				
				if string.len(JY.Person[i]["姓名"]) == 8 then
					indent = 29
				elseif string.len(JY.Person[i]["姓名"]) == 6 then
					indent = 14
				end
				
				DrawString(x + 61 - indent, h, JY.Person[i]["姓名"],color,CC.DefaultFont)
				h = h + space
				
				DrawString(x + 58, h, "LV."..JY.Person[i]["等级"],color,CC.Fontsmall)
				h = h + space
				
				DrawString(x + 41, h, "攻击 "..JY.Person[i]["攻击力"],color,CC.Fontsmall)
				h = h + space
				
				DrawString(x + 41, h, "防御 "..JY.Person[i]["防御力"],color,CC.Fontsmall)
				h = h + space
				
				DrawString(x + 41, h, "轻功 "..JY.Person[i]["轻功"],color,CC.Fontsmall)
				h = h + space
			end
			x = x + 184
		end
		
		local keypress, ktype, mx, my = lib.GetKey()
		
		if keypress == VK_LEFT then
			choice = choice - 1
		elseif keypress == VK_RIGHT then
			choice = choice + 1
		end
		
		ShowScreen()
		lib.Delay(CC.Frame)

	end
	
end

--逍遥御风 and JY.Person[240]["品德"] == 50
function XiaoYaoYF(id)
	if id ~= 0 then
		return false
	end
	--if PersonKF(id,85) and PersonKF(id,98) and PersonKF(id,101) and JY.Person[634]["品德"] == 50 then
	if ((PersonKF(id,85) and PersonKF(id,98) and PersonKF(id,101)) or match_ID_awakened(id,634,1))  and  (JY.Person[240]["品德"] == 80 or not inteam(id)) then	
		return true
	end
	return false
end
--金刚般若
function JinGangBR(id)
local jgbrnum = 0
	for i = 1, JY.Base["武功数量"] do
		local kfid = JY.Person[id]["武功"..i]
		local klvl = JY.Person[id]["武功等级"..i]
		if kfid == 22 or kfid == 189  or kfid == 103 then
			jgbrnum = jgbrnum + 1
		end
	end
	if jgbrnum >= 3 then
		return true
	else
		return false
	end
end
--中庸之道
function ZhongYongZD(id)
    if JY.Person[id]["中庸"] == 1 then
		return true
	end
	return false
end
--斗转
function MuRongDZ(id)
	for i = 1, JY.Base["武功数量"] do
		if JY.Person[id]["武功"..i] == 43 then
			return true
		end
    end
	return false
end
			
--选择张家辉的秘籍
--上上下下左右左右BABA
function YC_ZhangJiaHui(key)
	local up,down,left,right = VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT
	local A,B = VK_A, VK_B
	local sequence = {up,up,down,down,left,right,left,right,B,A,B,A}
	if key == sequence[YC.ZJH + 1] then
		YC.ZJH = YC.ZJH + 1
	else
		YC.ZJH = 0
	end
end

--无酒不欢：太极+柔云，以柔克刚
function YiRouKG(id)
	local yirounum = 0;
	for i = 1, JY.Base["武功数量"] do
		local kfid = JY.Person[id]["武功"..i]
		local klvl = JY.Person[id]["武功等级"..i]
		if (kfid == 36 or kfid == 46) and klvl == 999 then
			yirounum = yirounum + 1
		end
	end
	if yirounum >= 2 then
		return true
	else
		return false
	end
end

--周目商店
function zmStore()
	dofile(CC.Acvmts)
	local mrchds = {}
	for i = 1, 4 do
		mrchds[i] = {}
		mrchds[i].num = 0
	end
	mrchds[1].name = "天内丹"
	mrchds[1].price = 600
	mrchds[2].name = "天轻丹"
	mrchds[2].price = 900
	mrchds[3].name = "天外丹"
	mrchds[3].price = 600
	mrchds[4].name = "四大山皮肤"
	mrchds[4].price = 500
	--mrchds[5].name = "玄元丹"
	--mrchds[5].price = 300
	--mrchds[6].name = "无极丹"
	--mrchds[6].price = 500
	local choice = 1
	local t_price = 0
	local m_left = CC.Sp

	while true do
		if JY.Restart == 1 then
			return
		end
		Cls()
		lib.LoadPNG(91, 10 * 2 , 0, 0, 1)
		for i = 1, #CC.commodity do
			local th = CC.commodity[i]
			local thname = JY.Thing[th[1]]['名称']
			local price = th[2]
			local num = th[3]
			local sm = th[4]
			local t_color = C_WHITE
			if i == choice then
				t_color = C_GOLD
			end
			lib.LoadPNG(91, 24 * 2 , 65, 115+40*(i-1), 1)
			DrawString(80,122+40*(i-1),string.format("%-14s %-8s %-6s %-6s %-6s",thname, price, th[5], num,sm),t_color,CC.DefaultFont*0.9)
		end
		
		DrawString(80,CC.ScreenH - 107,string.format("%-6s %-6s %-6s %-6s","总价：",t_price,"余额：",m_left), C_GOLD,CC.DefaultFont)
		
		DrawString(80,CC.ScreenH - 57,"秘武残章：".. CC.Sp, C_ORANGE, CC.DefaultFont)
		DrawString(400,CC.ScreenH - 50,"上下键选择 左右键调整数量 回车键确认 ESC退出",LimeGreen,CC.FontSmall)

		local keypress, ktype, mx, my = lib.GetKey()
		if keypress == VK_UP then
			choice = choice - 1
			if choice < 1 then
				choice = #CC.commodity
			end
		elseif keypress == VK_DOWN then
			choice = choice + 1
			if choice > #CC.commodity then
				choice = 1
			end
		elseif keypress == VK_LEFT then
            if CC.commodity[choice][3] > 0 then
                CC.commodity[choice][3] = CC.commodity[choice][3] - 1
			    m_left = m_left + CC.commodity[choice][2]
			    t_price = t_price - CC.commodity[choice][2]
			end
		elseif keypress == VK_RIGHT then
			if m_left >= CC.commodity[choice][2] then
				CC.commodity[choice][3] = CC.commodity[choice][3] + 1
				m_left = m_left - CC.commodity[choice][2]
				t_price = t_price + CC.commodity[choice][2]
			else
				DrawString(500,520,"您的余额不足！", C_RED, CC.FontBig)
				ShowScreen()
				lib.Delay(300)
			end
		elseif keypress == VK_RETURN then
            CC.Sp = m_left
            CC.commodity[choice][5] = CC.commodity[choice][5] + CC.commodity[choice][3]
            CC.commodity[choice][3] = 0
        elseif keypress == VK_ESCAPE then
            CC.commodity[choice][3] = 0
			break
		end
		ShowScreen()
		lib.Delay(CC.Frame)
	end
end

--根据动画贴图计算动画编号
function tjmdh(num)
local a = 0

for i = 0,#CC.Effect do
	a = CC.Effect[i] + a
	if num <= a then
	   say(i,0,1)
	   break
	end
	if i == #CC.Effect and num > a then  
	   say('超出范围',0,1)
	   break
	end
end
end

--大鸟人物选择菜单
function firstmenu()
	--设定窗口百分百,防止画面放大，缩小，导致画面中的文字，贴图不在规定位置
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	
	--文字大小
	local size = CC.DefaultFont
	
	--列表1，显示天书
	local menu1 = {'飞','雪','连','天','射','白','鹿','标准主角','笑','书','神','侠','倚','碧','鸳','特殊主角'}
	
	--列表1初始坐标位置
	local x1,y1 = bx*147,by*74
	
	local x2,y2 = bx*70,by*165
	--列表1的间隔
	local jg = bx*80
	
	--列表2的间隔
	local n = 15
	
	local menu2 = {	['飞'] = {1,2,3,4,72,587},
					['雪'] = {633,723,726,728,736},
					['连'] = {37,94,95,96,97,589,52,594,595},
					['天'] = {49,50,53,51,76,46,47,48,103,113,112,114,115,116,117,118,98,99,100,101,104,90,105,102,122,70,634,45,574,44,565,576,499},
					['射'] = {55,56,57,60,61,64,65,67,68,69,78,121,123,128,567,568,588,130,129,605,650,604},
					['白'] = {590,138,137},
					['鹿'] = {601,86,87,602,603,150,71,},
					['标准主角'] = {'盖世神拳','灵犀一指','剑神一笑','傲世狂刀','奇门无双','绝世天罡','仁者无敌','回天圣手','毒手药王'},
					['笑'] = {19,20,21,22,23,24,25,26,27,28,29,31,32,33,34,35,36,73,79,88,140,141,142,149,458,510,593,649,583},
					['书'] = {74,75,80,151,152,153,154,155,156,313,570,571,569,657,658,656,655,606},
					['神'] = {58,59,63,626,62,84,89,580,161,616,617,160,157,158,159,592,628,627,640},
					['侠'] = {38,581,582,39,40,41,42,43,85,164,162,163,636},
					['倚'] = {9,609,631,66,646,5,6,7,8,10,11,12,13,14,15,16,17,18,169,170,171,174,81,82,640,647,648,638,586,573,575,597,641,},
					['碧'] = {54,91,629,183,184,185,186,607,83,176,639},
					['鸳'] = {77,566,189,615,614,613,612},
					['特殊主角'] = {'陆渐','寇仲','司空摘星','步惊云','萧秋水','西门吹雪','李寻欢','黄裳','达摩','梁萧','谢云流','谢无悠','诡剑','徐子陵','梅长苏','酒神'},
	}

	--特殊人物人物id
	local tsrw = {	--['张家辉'] = 651,
                    ['陆渐'] = 497,
	                ['寇仲'] = 578,
			 		['司空摘星'] = 579,
					['步惊云'] = 584,					
					['萧秋水'] = 652,
					['西门吹雪'] = 500,
					['李寻欢'] = 498,
					['黄裳'] = 637,
					['达摩'] = 577,
					['梁萧'] = 635,
					--['喵太极'] = 92,
					['谢云流'] = 501,
					['谢无悠'] = 596,
					--['四大山'] = 642,
                    ['诡剑'] = 504,	
                    ['徐子陵'] = 505,
                    ['梅长苏'] = 507,
                   -- ['袁士霄'] = 658,
                    ['酒神'] = 721, 
	}	
	--列表0按键记录
	local cot = 1 
	
	local cont = 1 
	local cont1 = 0
	
	--列表2按键记录
	local coxt = 1
	--列表2按键翻页记录
	local coxt1 = 0
	local coxt2 = 0
	--记录当前菜单是在天书菜单还是人物菜单
	local lb = 2
	local xb = 0
	
	--畅想
	local cx = 0
	--主角
	local zj = 0
	--特殊
	local ts = 0
	
	local dh = 0
	local fy = 0
	local fymax = 0
	local star = 1

		
	while true do 
		if JY.Restart == 1 then
			break
		end
		--清除画面，因为菜单是无限循环的状态，所以显示画面前，需要清除之前的画面，否则贴图无限叠加
		ClsN()
		---------------
		
		--自己找一张背景图放这里
		lib.LoadPNG(91, 25 * 2 , 0,0, 1)
		
			local m = menu1[cont+cont1*8]
			
			if lb == 3 or lb == 4 then
				local id = coxt + coxt1*6
				local mid = menu2[m][id]
				--lib.LoadPNGPath(string.format('./data/fight/fight%03d',JY.Person[id]["头像代号"]), 89, -1, 100)   --战斗贴图
				if mid ~= nil then
					if m == '标准主角' then 
						--男主角半身像起始
						local tt = 546
						
						
						--女主角半身像起始 
						if xb == 1 then 
							tt = 555
						end

						lib.LoadPNG(90, (tt+id)* 2 , bx*160,by*370, 2)
						lib.LoadPNG(91, 26 * 2 , 0,0, 1)
						--
						--天赋显示处
						--
							local pic = 0
							local zs = 10
							local dl = 0
							if xb == 1 then 
								pic = 227
								zs = 10
								else
								pic = 387
								zs = 14
							end
							
							--状态界面动画显示，89号
							--lib.PicLoadFile(string.format(CC.FightPicFile[1],pic),
						--	string.format(CC.FightPicFile[2],pic), 89)
							
							lib.PicLoadCache(pic+101,(dl+dh+zs*3)*2,bx*890,by*670)
							
							dh = dh + 1
							if dh == zs then
								dh = 1
							end
							
						local tid = 546+id
						if TFJS[tid] ~= nil then
							local row = 0
							local maxh = 15
							local me = {}
							for i = 1, #TFJS[tid] do
								me[#me+1] = TFJS[tid][i]
							end
							for i = 1, #ZJZSJS do
								me[#me+1] = ZJZSJS[i]
							end
							for i = star, #me do
								local tfstr = me[i]
								local h = 0
									
								if string.sub(tfstr,1,2) == "Ｎ" then
									row = row + 1
								else
									h = tjm(bx*300, by*280 + size*0.8 * (row-fy), tfstr, C_WHITE, size*0.8,math.modf((bx*600)/size/0.8)-1,size*0.8,fy-row,maxh+1-row+fy)
								end
								row = row + h
							end
							if row > maxh then
								fymax = limitX(row-maxh-1,0)
							else
								fymax = 0
							end

						end		
					elseif m == '特殊主角' then 
						local tt = {290,580}
						if tsrw[mid] ~= nil then
							local pic = JY.Person[tsrw[mid]]['半身像']
							lib.LoadPNG(90, pic* 2 , bx*160,by*370, 2)
						end				
					        lib.LoadPNG(91, 26 * 2 , 0,0, 1)																			
							if tsrw[mid] ~= nil then 
								local tid = tsrw[mid]
								local pic = JY.Person[tid]['头像代号']
								
								local hh = 0
								for k = 1,2 do 
									if JY.Person[tid]['武功'..k] > 0 then 
										local kf = JY.Person[tid]['武功'..k]
										DrawString(x2,by*528+(hh)*by*41,JY.Wugong[kf]['名称'],C_WHITE,size*0.9);
										hh = hh + 1
									end
								end
								
							--	lib.PicLoadFile(string.format(CC.FightPicFile[1],pic),
							--	string.format(CC.FightPicFile[2],pic), 89)
								
								local zs = 0
								local dl = 0
								for j=1,5 do
									if JY.Person[tid]['出招动画帧数'..j]>0 then
										if j>1 then
											zs = JY.Person[tid]['出招动画帧数'..j]
											break;
										end
										dl = dl+JY.Person[tid]['出招动画帧数'..j]*4
									end
								end
								
								lib.PicLoadCache(pic+101,(dl+dh+zs*3)*2,bx*890,by*670)
								
								dh = dh + 1
								if dh == zs then
									dh = 1
								end
								
								if TFJS[tid] ~= nil then
								local row = 0
								local maxh = 15
								local me = {}
								for i = 1, #TFJS[tid] do
									me[#me+1] = TFJS[tid][i]
								end
								for i = 1, #ZJZSJS do
									me[#me+1] = ZJZSJS[i]
								end
								for i = star, #me do
									local tfstr = me[i]
									local h = 0
										
										if string.sub(tfstr,1,2) == "Ｎ" then
											row = row + 1
										else
											h = tjm(bx*300, by*280 + size*0.8 * (row-fy), tfstr, C_WHITE, size*0.8,math.modf((bx*600)/size/0.8)-1,size*0.8,fy-row,maxh+1-row+fy)
										end
										row = row + h
									end
									if row > maxh then
										fymax = limitX(row-maxh-1,0)
									else
										fymax = 0
									end
								end	
							end
						
					else
						lib.LoadPNG(90, JY.Person[mid]['半身像'] * 2 , bx*160,by*370, 2)
						lib.LoadPNG(91, 26 * 2 , 0,0, 1)
						--
						--天赋显示处
						--
						local hh = 0
						for k = 1,2 do 
							if JY.Person[mid]['武功'..k] > 0 then 
								local kf = JY.Person[mid]['武功'..k]	
								DrawString(x2,by*528+(hh)*by*41,JY.Wugong[kf]['名称'],C_WHITE,size*0.9);
								hh = hh + 1
							end
						end

						--状态界面动画显示，89号
						--lib.PicLoadFile(string.format(CC.FightPicFile[1],JY.Person[mid]["头像代号"]),
						--string.format(CC.FightPicFile[2],JY.Person[mid]["头像代号"]), 89)
						
						local zs = 0
						local dl = 0
						for j=1,5 do
							if JY.Person[mid]['出招动画帧数'..j]>0 then
								if j>1 then
									zs = JY.Person[mid]['出招动画帧数'..j]
									break;
								end
								dl = dl+JY.Person[mid]['出招动画帧数'..j]*4
							end
						end
						
						lib.PicLoadCache(JY.Person[mid]["头像代号"]+101,(dl+dh+zs*3)*2,bx*890,by*670)
						
						dh = dh + 1
						if dh == zs then
							dh = 0
						end
						
						if TFJS[mid] ~= nil then
								local row = 0
								local maxh = 15
								local me = {}
								for i = 1, #TFJS[mid] do
									me[#me+1] = TFJS[mid][i]
								end
								for i = 1, #ZJZSJS do
									me[#me+1] = ZJZSJS[i]
								end
								for i = star, #me do
									local tfstr = me[i]
									local h = 0
										
								if string.sub(tfstr,1,2) == "Ｎ" then
									row = row + 1
								else
									h = tjm(bx*300, by*280 + size*0.8 * (row-fy), tfstr, C_WHITE, size*0.8,math.modf((bx*600)/size/0.8)-1,size*0.8,fy-row,maxh+1-row+fy)
								end
								row = row + h
							end
							if row > maxh then
								fymax = limitX(row-maxh-1,0)
							else
								fymax = 0
							end
						end
					
					end
				end
				DrawString(-1,by*660,'PageUp 上翻页  PageDown 下翻页',C_GOLD,size*0.7);
			end

		--if lb == 2 or lb == 3 then
			--显示天书列表
			for i = 1,8 do
				for j = 1,2 do
					local id = i + (j-1)*8
					local cl = C_WHITE
					if cont == i and cont1 == j-1 and lb == 2 then
						cl = C_RED
					end	
					
					DrawString(x1+(i-1)*jg,y1+(j-1)*by*40,menu1[id],cl,size);
				end
			end
		--end
		--显示人物列表
		--if lb == 3 or lb == 2 then 
			for i = 1,6 do
				for j = 1,2 do
					local id = i + (j-1+coxt2)*6
					local cl = C_WHITE
					local mid = menu2[m][id]
					if mid ~= nil then
						if coxt + coxt1*6 == id and lb == 3 then
							cl = C_RED
						end	
						if m == '标准主角' then
							DrawString(x2+(i-1)*bx*140,y2+(j-1)*size,mid,cl,size*0.8);
						elseif m == '特殊主角' then
							DrawString(x2+(i-1)*bx*140,y2+(j-1)*size,mid,cl,size*0.8);
						
						else
							DrawString(x2+(i-1)*bx*140,y2+(j-1)*size,JY.Person[mid]['姓名'],cl,size*0.8);
						end
						
					end
				end
				
			end
			
		----------------
		--显示画面
		ShowScreen()
		--循环的间隔（数值随意）
		lib.Delay(40)
		--X是键盘操作，ktype是鼠标操作，ktype = 3 代表左键，4代表右键，6滚轮上，7滚轮下
		local X,ktype,mx,my = lib.GetKey()
		
		--空格键和enter键默认确定
		if X == VK_SPACE or X == VK_RETURN then 
			if lb == 2 then 
				lb = 3
			elseif lb == 3 then 
				if menu1[cont+cont1*8] == '标准主角' then 
					lb = 4
				elseif menu1[cont+cont1*8] == '特殊主角' then 
						cx = tsrw[menu2[m][coxt + coxt1*6]]					
					break
				else
					cx = menu2[m][coxt + coxt1*6]
					break
				end
			elseif lb == 4 then 
				zj = coxt + coxt1*6
				local tt = 546 
				if xb == 1 then 
					tt = 555
				end
				JY.Person[0]['半身像'] = zj+tt
				break
			end	
		--esc和鼠标右键默认返回
		elseif X == VK_ESCAPE or ktype == 4 then
			--循环结束，退出
			if lb == 3 then
				lb = 2
				coxt = 1 
				coxt1 = 0 
				coxt2 = 0
				dh = 0
				fy = 0
			elseif lb == 4 or lb == 5 then 
				lb = 3
			end
		elseif X == VK_UP then
			if lb == 2 then 
				if cont1 == 1 then 
					cont1 = 0
				else
					cont1 = 1
				end
			elseif lb == 3 then
				if coxt1 > 0 then
					if coxt1 == coxt2 then
						coxt2 = limitX(coxt2 - 1,0)
					end
					coxt1 = coxt1 - 1
				else 
					coxt = 1
				end
				dh = 0
				fy = 0
			elseif lb == 4 then 
				if xb == 1 then 
					xb = 0 
				else 
					xb = 1
				end	
			end

		elseif X == VK_DOWN then
			if lb == 2 then 
				if cont1 == 1 then 
					cont1 = 0
				else
					cont1 = 1
				end
			elseif lb == 3 then
				if coxt + coxt1*6 < #menu2[menu1[cont+cont1*8]] then
					if coxt1 < math.ceil(#menu2[menu1[cont+cont1*8]]/6) - 1 then 
						coxt1 = coxt1 + 1 
						if coxt + coxt1*6 > #menu2[menu1[cont+cont1*8]] then
							coxt = #menu2[menu1[cont+cont1*8]] - coxt1*6
						end
					else 
						coxt = #menu2[menu1[cont+cont1*8]] - coxt1*6
					end
					if coxt1 - coxt2 > 1 then
						coxt2 = coxt2 + 1
					end
				end
				dh = 0
				fy = 0
			elseif lb == 4 then 
				if xb == 1 then 
					xb = 0 
				else 
					xb = 1
				end	
			end
		elseif X == VK_LEFT or ktype == 6 then
			if lb == 2 then 
				if cont1 > 0 then
					if cont > 1 then
						cont = cont - 1 
					else 
						cont = 8
						cont1 = 0					
					end
				else 
					if cont > 1 then
						cont = cont - 1 	
					else 
						cont = 8
						cont1 = 1
					end
				end
			elseif lb == 3 then 
				if coxt > 1 then 
					coxt = coxt - 1
				else
					if coxt1 > 0 then 
						if coxt1 == coxt2 then
							coxt2 = limitX(coxt2 - 1,0)
						end
						coxt1 = coxt1 - 1
						coxt = 6
					end
				end	
				dh = 0
				fy = 0
			elseif lb == 4 then 
				if xb == 1 then 
					xb = 0 
				else 
					xb = 1
				end	
			end			
		elseif X == VK_RIGHT or ktype == 7 then
			if lb == 2 then 
				if cont1 < 1 then 
					if cont < 8 then 
						cont = cont + 1 
					else 
						cont = 1
						cont1 = 1
					end
				else 
					if cont < 8 then 
						cont = cont + 1 
					else 
						cont = 1
						cont1 = 0
					end
				end
			elseif lb == 3 then 
				if coxt + coxt1*6 < #menu2[menu1[cont+cont1*8]] then
					if coxt < 6 then 
						coxt = coxt + 1
					else
						if coxt1 < math.ceil(#menu2[menu1[cont+cont1*8]]/6) - 1 then 
							coxt = 1 
							coxt1 = coxt1 + 1
						end	
					end	
					if coxt1 - coxt2 > 1 then
						coxt2 = coxt2 + 1
					end
				end
				dh = 0
				fy = 0
			elseif lb == 4 then 
				if xb == 1 then 
					xb = 0 
				else 
					xb = 1
				end	
			end	
		elseif X == VK_PGUP then
			if lb == 3 then
				fy = fy - 1
				if fy < 0 then 
					fy = 0
				end	
			end
		elseif X == VK_PGDN then
			if lb == 3 then
				fy = fy + 1
				if fy > fymax then
					fy = fymax 
				end
			end
			
		else 
			local mxx = false
			if lb == 2 then 
				for i = 1,8 do
					for j = 1,2 do
						local id = i + (j-1)*8
						if mx >= x1+(i-1)*jg and mx <= x1+(i-1)*jg + size*#menu1[id]/2 and 
							my >= y1+(j-1)*by*40 and my <= y1+(j-1)*by*40 + size then
							cont = i 
							cont1 = j-1
							mxx = true
							break
						end
					end
					if mxx == true then 
						break
					end
				end
			elseif lb == 3 then 
				for i = 1,6 do 
					for j = 1,2 do
						local s = i + (j-1+coxt2)*6
						local mid = menu2[m][s]
						local s = 0
						if mid ~= nil then
							if m == '标准主角' or m == '特殊主角' then
								s = #mid*(size*0.8)/2
							else 
								local name = JY.Person[mid]['姓名']
								s = #name*(size*0.8)/2
							end
						end
						if mx >= x2+(i-1)*bx*140 and mx <= x2+(i-1)*bx*140 + s and 
							my >= y2+(j-1)*size*0.8 and my <= y2+(j-1)*size + size*0.8 then 
							if mid ~= nil then 
								coxt = i
								coxt1 = j - 1 + coxt2
								mxx = true
								dh = 0
								break
							end
						end	
					end
					if mxx == true then 
						break
					end
				end	
			elseif lb == 4 then 
				mxx = true
			end
			if mxx == true and ktype == 3 then 
				if lb == 2 then 
					lb = 3
				elseif lb == 3 then 
					if menu1[cont+cont1*8] == '标准主角' then 
						lb = 4
					elseif menu1[cont+cont1*8] == '特殊主角' then 
							cx = tsrw[menu2[m][coxt + coxt1*6]]
						break
					else
						cx = menu2[m][coxt + coxt1*6]
						if showCXStatic(cx) then						
						break
					end
                end
				elseif lb == 4 then 
				zj = coxt + coxt1*6
				local tt = 546 
				if xb == 1 then 
					tt = 555
				end
				JY.Person[0]['半身像'] = zj+tt
				break
				end	
			end
		end
		
	end
	return cx,zj,ts,xb
end

function tjm(x,y,str,color,size,xnum,hnum,first,last)
	if xnum == nil then 
		xnum = #str
	end  
 
	if x==-1 then
		local ll=#str;
		local w=size*ll/2+2*CC.MenuBorderPixel;
		x=(CC.ScreenW-size/2*ll-2*CC.MenuBorderPixel)/2;
	end

	if y == -1 then
		y = (CC.ScreenH - size - 2 * CC.MenuBorderPixel) / 2
	end
	
	local ynum=size
	local T2={};
	T2["Ｒ"] = PinkRed
	T2["Ｌ"] = LimeGreen
	T2["Ｂ"] = C_BLACK
	T2["Ｗ"] = C_WHITE
	T2["Ｏ"] = C_ORANGE
	T2["Ｄ"] = M_DeepSkyBlue
	T2["Ｚ"] = Violet
	T2['Ｇ'] = C_GOLD
	local cx,cy=0,0;
	--local sid=lib.SaveSur(0,0,CC.ScreenW,CC.ScreenH);
	while string.len(str)>=1 do
		if JY.Restart == 1 then
			break
		end
		local try=string.sub(str,1,1)
		local control=false;

		local hs = size+CC.RowPixel
		if hnum ~= nil then 
			hs = hnum
		end
		if string.byte(try)>127 then --中文
			local s=string.sub(str,1,2);
			str=string.sub(str,3,-1);

			if T2[s] ~= nil then 
				color = T2[s]
				control = true;
			end
            
			if not control then
                if s == '*' then 
                   -- cy = cy + 1 
                  --  cx = 0
                else
                    if first ~= nil then
                        if last ~= nil then
                            if cy >= first and cy < last then
                                lib.DrawStr(x+size*cx,y+(hs)*cy,s,color,size,CC.FontName,CC.SrcCharSet,CC.OSCharSet);
                            end
                        else 
                            if cy >= first then
                                lib.DrawStr(x+size*cx,y+(hs)*cy,s,color,size,CC.FontName,CC.SrcCharSet,CC.OSCharSet);
                            end	  
                        end
                    else 
                        if last ~= nil then
                            if cy < last then
                                lib.DrawStr(x+size*cx,y+(hs)*cy,s,color,size,CC.FontName,CC.SrcCharSet,CC.OSCharSet);
                            end
                        else 
                            lib.DrawStr(x+size*cx,y+(hs)*cy,s,color,size,CC.FontName,CC.SrcCharSet,CC.OSCharSet);
                        end		  
                    end
                    cx=cx+1;
                end
			end

		else
			local s=try
			str=string.sub(str,2,-1);
            if s == 'Ｎ' or s == '*' then 
                cy = cy + 1 
                cx = 0
            else
                if first ~= nil then
                    if last ~= nil then
                        if cy >= first and cy < last then
                            lib.DrawStr(x+size*cx,y+(hs)*cy,s,color,size,CC.FontName,CC.SrcCharSet,CC.OSCharSet);
                        end
                    else 
                        if cy >= first then
                            lib.DrawStr(x+size*cx,y+(hs)*cy,s,color,size,CC.FontName,CC.SrcCharSet,CC.OSCharSet);
                        end	  
                    end
                else 
                    if last ~= nil then
                        if cy < last then
                            lib.DrawStr(x+size*cx,y+(hs)*cy,s,color,size,CC.FontName,CC.SrcCharSet,CC.OSCharSet);
                        end
                    else 
                        lib.DrawStr(x+size*cx,y+(hs)*cy,s,color,size,CC.FontName,CC.SrcCharSet,CC.OSCharSet);
                    end		  
                end
                cx=cx+1;
            end
			
		end

		if not control then

			if cx > xnum then
				cx = 0;
				--字体结束不再进入下一行
				if string.len(str) >= 1 then 
					cy = cy + 1;
				end
			end
		end

	end

	--lib.FreeSur(sid);
	return cy+1
end

function tjm2(str,xnum)
	if xnum == nil then 
		xnum = #str
	end  
 
	local T2={};

	T2["Ｒ"] = PinkRed
	T2["Ｌ"] = LimeGreen
	T2["Ｂ"] = C_BLACK
	T2["Ｗ"] = C_WHITE
	T2["Ｏ"] = C_ORANGE
	T2["Ｄ"] = M_DeepSkyBlue
	T2["Ｚ"] = Violet
	T2['Ｇ'] = C_GOLD

	local cx,cy=0,0;
    --local color 
	while string.len(str)>=1 do
		if JY.Restart == 1 then
			break
		end
		local try=string.sub(str,1,1)
		local control=false;

		if string.byte(try)>127 then --中文
			local s=string.sub(str,1,2);
			str=string.sub(str,3,-1);

			if T2[s] ~= nil then 
				--color = T2[s]
				control = true;
			end
            
			if not control then
                if s == 'Ｎ' then 

                else

                    cx=cx+1;
                end
			end

		else
			local s=try
			str=string.sub(str,2,-1);
            if s == 'Ｎ' or s == '*' then 
                cy = cy + 1 
                cx = 0
            else

                cx=cx+1;
            end
			
		end

		if not control then

			if cx > xnum then
				cx = 0;
				--字体结束不再进入下一行
				if string.len(str) >= 1 then 
					cy = cy + 1;
				end
			end
		end

	end

	return cy+1
end

function tjmsave(id)
	CC.TJMSJ = {} 
	CC.TJM = 0

	for i = 1,#CC.TXM do
		CC.TJMSJ[#CC.TJMSJ+1] = CC.TX[CC.TXM[i]]
		CC.TJM = CC.TJM + 1
	end
	
	local tg = 0
	for i,v in pairs(CC.TG) do 
		tg = tg + 1
	end 
	
	CC.TJMSJ[#CC.TJMSJ+1] = tg
	CC.TJM = CC.TJM + 1
	
	for i,v in pairs(CC.TG) do 
		CC.TJMSJ[#CC.TJMSJ+1] = i
		CC.TJM = CC.TJM + 1
	end
	
	CC.TJMSJ[#CC.TJMSJ+1] = #CC.TGJL
	CC.TJM = CC.TJM + 1
	
	for i = 1,#CC.TGJL do
		CC.TJMSJ[#CC.TJMSJ+1] = CC.TGJL[i]
		CC.TJM = CC.TJM + 1
	end

	CC.TJMSJ[#CC.TJMSJ+1] = CC.Gold
	CC.TJM = CC.TJM + 1
	
	CC.TJMSJ[#CC.TJMSJ+1] = CC.Jl
	CC.TJM = CC.TJM + 1

	local fp_tmp=io.open('tjm',"w");
	
	if fp_tmp then
		fp_tmp:close();
		local data_header=Byte.create(4);
		Byte.set32(data_header,0, CC.TJM);
		Byte.savefile(data_header,'tjm', 0, 4);
		local data_keys=Byte.create(4*CC.TJM);
		for i=0,CC.TJM-1 do
			Byte.set32(data_keys, i*4, CC.TJMSJ[i+1]);
		end
		Byte.savefile(data_keys, 'tjm', 4, 4*CC.TJM);
	end
	CC.TJMSJ = {} 
	CC.TJM = 0
end

function tjmload(id)
	CC.TJMSJ = {} 
	CC.TJM = 0
	local fp_tmp=io.open('tjm',"r");
	if fp_tmp then
		fp_tmp:close();
   
		local data_header=Byte.create(4);
   
		Byte.loadfile(data_header,'tjm', 0, 4);
   
		CC.TJM=Byte.get32(data_header,0);
   
		local data_keys=Byte.create(4*CC.TJM);
   
		Byte.loadfile(data_keys,'tjm', 4, 4*CC.TJM);
		
		for i=0,CC.TJM-1 do
			CC.TJMSJ[i+1]=Byte.get32(data_keys, i*4);
		end
		
		CC.TJM = 1
		
		for i = 1,#CC.TXM do
			CC.TX[CC.TXM[i]] = CC.TJMSJ[CC.TJM]
			CC.TJM = CC.TJM + 1
		end
		
		local tg = CC.TJMSJ[CC.TJM]
		CC.TJM = CC.TJM + 1
		
		for i = 1,tg do
			local v = CC.TJMSJ[CC.TJM]
			CC.TG[v] = 1
			CC.TJM = CC.TJM + 1
		end
		
		local tgjl = CC.TJMSJ[CC.TJM]
		CC.TJM = CC.TJM + 1
		
		for i = 1,tgjl do
			CC.TGJL[i] = CC.TJMSJ[CC.TJM]
			CC.TJM = CC.TJM + 1
		end

        CC.Gold = CC.TJMSJ[CC.TJM]
		CC.TJM = CC.TJM + 1

        CC.Jl = CC.TJMSJ[CC.TJM]
		CC.TJM = CC.TJM + 1
	end
	Weekload()
	CC.TJMSJ = {} 
	CC.TJM = 0
end

function ShowStatus()
	--比利
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	--文字大小
	local size = CC.DefaultFont*0.6
	--文字大小2
	local size2 = CC.DefaultFont*0.55
	--生命坐标
	local x1,y1 = bx*183,bx*41
	--内力坐标
	local x2,y2 = bx*183,bx*59
	--头像坐标
	local x3,y3 = bx*56,bx*51
	--姓名坐标
	local x4,y4 = bx*152,bx*20
	--周目坐标
	local x5,y5 = bx*235,bx*20
	--银两坐标
	local x6,y6 = bx*135,bx*82
	--天书坐标
	local x7,y7 = bx*215,bx*82
	--难度坐标
	local x8,y8 = bx*40,bx*110
	--生命内力大小
	local w = bx*78
	local h = bx*7
	--生命
	local sm = JY.Person[0]['生命']
	--内力
	local nl = JY.Person[0]['内力']
	--最大生命
	local smmax = JY.Person[0]['生命最大值']
	--最大内力
	local nlmax = JY.Person[0]['内力最大值']
	--头像标号
	local hid = JY.Person[0]['半身像']
	--姓名
	local name = JY.Person[0]['姓名']
	--周目
	local zm = JY.Base["周目"]..'周目'
	--内力属性
	local sx = {'阴','阳','调和','天罡'}
	--内力属性
	local nlsx = sx[JY.Person[0]['内力性质']+1]
	--生命数字
	local smwz = sm..'/'..smmax
	--内力数字
	local nlwz = nl..'/'..nlmax..'（'..nlsx..'）'
	--银两
	local yl = CC.Gold
	--天书
	local ts = JY.Base["天书数量"]..'本'
	
	--难度
	local tnd = math.fmod(JY.Base["难度"],#MODEXZ2);
	if tnd == 0 then
		tnd = #MODEXZ2
	end
	tnd = MODEXZ2[tnd]
	
	--单通
	local yxms
	if JY.Base["单通"] == 0 then
		yxms = "普通"
	elseif JY.Base["单通"]==1 then
		yxms = "单通"
	else
		yxms = "娱乐"
	end
	
	--时间
	local t = math.modf((lib.GetTime() - JY.LOADTIME) / 60000 + GetS(14, 2, 1, 4))
	local t1, t2 = 0, 0
	while t >= 60 do
		t = t - 60
		t1 = t1 + 1
	end
	
	t2 = t
	
	--时间单通难度信息
	local xx = tnd..' '..yxms..' '..string.format("%2d时%2d分", t1, t2)
	local xx = tnd..'/ '..yxms..'/ '.."道德"..JY.Person[0]['品德']
	lib.LoadPNG(91, 39*2, 0, 0, 1)
	--头像贴图
	lib.LoadPNG(1, hid*2, x3, y3, 2)
	--背景图
	lib.LoadPNG(91, 40*2, 0, 0, 1)
	--生命条
	lib.SetClip(x1-w,y1-h,(x1-w)+(w*2)*(sm/smmax),y1+h)
	lib.LoadPNG(91, 41*2, x1, y1, 2)
	lib.SetClip(0,0,0,0)
	--内力条
	lib.SetClip(x2-w,y2-h,(x2-w)+(w*2)*(nl/nlmax),y2+h)
	lib.LoadPNG(91, 42*2, x2, y2, 2)
	lib.SetClip(0,0,0,0)
	
	--姓名
	DrawString(x4-string.len(name)/4*size,y4-size/2,name,C_GOLD,size)
	--周目
	DrawString(x5-string.len(zm)/4*size2,y5-size/2,zm,C_WHITE,size2)
	--生命
	DrawString(x1-string.len(smwz)/4*size2,y1-size2/2,smwz,C_WHITE,size2)
	--内力
	DrawString(x2-string.len(nlwz)/4*size2,y2-size2/2,nlwz,C_WHITE,size2)
	--银两
	DrawString(x6,y6-size2/2,yl,C_WHITE,size2)
	--天书
	DrawString(x7,y7-size2/2,ts,C_WHITE,size2)
	--时间单通难度信息
	DrawString(x8,y8-size2/2,xx,C_GOLD,size2*1.1)
end

function Cat(s,...)
	if not Ct[s] then 
		lib.Debug('错误：未知函数')
	end
	return Ct[s](...)
end

function CMenu() 
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	local cont = 1
	local cont2 = 1
	local cont3 = 1
	local cont4 = 1
	local cot4 = 0
	local page = 1
	local menu = {'人物','物品',MJMenu,'设置'}
	local menu2 = {'状态','排序','离队'}
	local menu3 = {nil,0,1,3,4}
	local menu4 = {Menu_ReadRecord,Menu_SaveRecord,Menu_SetMusic,Menu_SetSound,Menu_WPZL,pastReview,Menu_MYDIY,Menu_Exit2}

	local jg = bx*20
	while true do
		Cls()
		if JY.Restart == 1 then
			break
		end
		for i = 1,#menu do 
			lib.PicLoadCache(92,(1+i)*2,CC.ScreenW/2-((#menu-1)*bx*140)/2+(i-1)*bx*140,CC.ScreenH/2-bx*60,2,256,nil,bx*120)
			if cont ~= i then 
				lib.PicLoadCache(92,(1+i)*2,CC.ScreenW/2-((#menu-1)*bx*140)/2+(i-1)*bx*140,CC.ScreenH/2-bx*60,6,150,nil,bx*120)
			end
		end
		
		if page == 2 then 
			for i = 1,#menu2 do 
				lib.PicLoadCache(92,(5+i)*2,CC.ScreenW/2-((#menu2-1)*bx*140)/2+(i-1)*bx*140,CC.ScreenH/2+bx*60,2,256,nil,bx*100)
				if cont2 ~= i then 
					lib.PicLoadCache(92,(5+i)*2,CC.ScreenW/2-((#menu2-1)*bx*140)/2+(i-1)*bx*140,CC.ScreenH/2+bx*60,6,150,nil,bx*100)
				end
			end
		end
		
		if page == 3 then 
			for i = 1,#menu3 do 
				lib.PicLoadCache(92,(15+i)*2,CC.ScreenW/2-((#menu3-1)*bx*140)/2+(i-1)*bx*140,CC.ScreenH/2+bx*60,2,256,nil,bx*100)
				if cont3 ~= i then 
					lib.PicLoadCache(92,(15+i)*2,CC.ScreenW/2-((#menu3-1)*bx*140)/2+(i-1)*bx*140,CC.ScreenH/2+bx*60,6,150,nil,bx*100)
				end
			end
		end
		
		if page == 4 then 
			for i = 1,4 do 
				for j = 1,2 do
					local tid = i + (j-1)*4
					lib.PicLoadCache(92,(20+tid)*2,CC.ScreenW/2-((#menu4/2-1)*bx*140)/2+(i-1)*bx*140,CC.ScreenH/2+bx*60+(j-1)*bx*120,2,256,nil,bx*100)
					if cont4+cot4*4 ~= tid then 
						lib.PicLoadCache(92,(20+tid)*2,CC.ScreenW/2-((#menu4/2-1)*bx*140)/2+(i-1)*bx*140,CC.ScreenH/2+bx*60+(j-1)*bx*120,6,150,nil,bx*100)
					end
				end
			end
		end
		
		ShowScreen()
		lib.Delay(CC.BattleDelay)
		local X,ktype,mx,my = lib.GetKey()
		if X == VK_SPACE or X == VK_RETURN then 
			if page == 1 then
				if cont == 1 then 
					page = 2
				elseif cont == 2 then
					page = 3
				elseif cont == 4 then
					page = 4
				else 
					menu[cont]()
				end
			elseif page == 2 then 
				Team({menu2[cont2]})
			elseif page == 3 then 
				ThingMenu(menu3[cont3])
				if JY.ThingUse >= 0 then 
					JY.ThingUse = 0
					return 1
				end
				if JY.Status == GAME_WMAP then
					return 1
				end
			elseif page == 4 then 	
				local r = menu4[cont4+cot4*4]()
				if cont4+cot4*4 == #menu4 or cont4+cot4*4 == 1 then
					if r == 1 then
						break
					end
				end
			end
		elseif X == VK_ESCAPE or ktype == 4 then
			if page == 2 then 
				page = 1 
				cont2 = 1
			elseif page == 3 then 
				page = 1
				cont3 = 1
			elseif page == 4 then 
				page = 1
				cont4 = 1
				cot4 = 0
			else 	
				break
			end
		elseif X == VK_LEFT then
			if page == 1 then 
				cont = cont - 1 
				if cont < 1 then 
					cont = #menu
				end
			elseif page == 2 then 
				cont2 = cont2 - 1 
				if cont2 < 1 then 
					cont2 = #menu2
				end
			elseif page == 3 then 
				cont3 = cont3 - 1 
				if cont3 < 1 then 
					cont3 = #menu3
				end
			elseif page == 4 then 
				if cont4 > 1 then 
					cont4 = cont4 - 1
				else
					if cot4 > 0 then 
						cot4 = cot4 - 1
						cont4 = 4
					else
						cont4 = 4
						cot4 = math.ceil((#menu4-cont4)/4)
					end
				end
			end
		elseif X == VK_RIGHT then
			if page == 1 then 
				cont = cont + 1 
				if cont > #menu then 
					cont = 1
				end
			elseif page == 2 then 
				cont2 = cont2 + 1 
				if cont2 > #menu2 then 
					cont2 = 1
				end
			elseif page == 3 then 
				cont3 = cont3 + 1 
				if cont3 > #menu3 then 
					cont3 = 1
				end
			elseif page == 4 then
				if cont4 + cot4*4 < #menu4 then
					if cont4 < 4 then 
						cont4 = cont4 + 1
					else 
						cont4 = 1 
						cot4 = cot4 + 1
					end
				else 
					cont4 = 1 
					cot4 = 0
				end
			end
		elseif X == VK_UP or ktype == 6 then
			if page == 4 then
				if cot4 > 0 then
					cot4 = cot4 - 1
				else 
					cot4 = math.ceil((#menu4)/4) - 1
				end
			end
		elseif X == VK_DOWN or ktype == 7 then
			if page == 4 then
				if cot4 < math.ceil((#menu4)/4) - 1 then
					cot4 = cot4 + 1
				else 
					cot4 = 0
				end
			end
		else 
			local mxx = false
			if page == 1 then 
				for i = 1,#menu do 
					if mx >= CC.ScreenW/2-((#menu-1)*bx*140)/2+(i-1)*bx*140 - bx*60 and mx <= CC.ScreenW/2-((#menu-1)*bx*140)/2+(i-1)*bx*140 + bx*60
						and my >= CC.ScreenH/2-bx*120 and my <= CC.ScreenH/2 then 
						cont = i 
						mxx = true
						break
					end
				end
			elseif page == 2 then
				for i = 1,#menu2 do 
					if mx >= CC.ScreenW/2-((#menu2-1)*bx*140)/2+(i-1)*bx*140 - bx*50 and mx <= CC.ScreenW/2-((#menu2-1)*bx*140)/2+(i-1)*bx*140 + bx*50
						and my >= CC.ScreenH/2+bx*10 and my <= CC.ScreenH/2+bx*110 then 
						cont2 = i 
						mxx = true
						break
					end
				end
			elseif page == 3 then
				for i = 1,#menu3 do 
					if mx >= CC.ScreenW/2-((#menu3-1)*bx*140)/2+(i-1)*bx*140 - bx*50 and mx <= CC.ScreenW/2-((#menu3-1)*bx*140)/2+(i-1)*bx*140 + bx*50
						and my >= CC.ScreenH/2+bx*10 and my <= CC.ScreenH/2+bx*110 then 
						cont3 = i 
						mxx = true
						break
					end
				end
			elseif page == 4 then
				for i = 1,4 do 
					for j = 1,2 do 
						if mx >= CC.ScreenW/2-((#menu4/2-1)*bx*140)/2+(i-1)*bx*140 - bx*50 and mx <= CC.ScreenW/2-((#menu4/2-1)*bx*140)/2+(i-1)*bx*140 + bx*50
							and my >= CC.ScreenH/2+bx*10+(j-1)*bx*120 and my <= CC.ScreenH/2+bx*110+(j-1)*bx*120 then 
							cont4 = i
							cot4 = j-1
							mxx = true
							break
						end
					end
				end
			end
			if mxx == true and ktype == 3 then 
				if page == 1 then
					if cont == 1 then 
						page = 2
					elseif cont == 2 then
						page = 3
					elseif cont == 4 then
						page = 4
					else 
						menu[cont]()
					end
				elseif page == 2 then 
					Team({menu2[cont2]})
				elseif page == 3 then 
					ThingMenu(menu3[cont3])
					if JY.ThingUse >= 0 then 
						JY.ThingUse = 0
						return 1
					end
					if JY.Status == GAME_WMAP then
						return 1
					end
				elseif page == 4 then 	
					local r = menu4[cont4+cot4*4]()
					if cont4+cot4*4 == #menu4 or cont4+cot4*4 == 1 then
						if r == 1 then 
							break
						end
					end
				end
			end
		end
	end

end

function MJMenu() 

		local thing = {}
		local thingnum = {}
		for i = 0, CC.MyThingNum - 1 do
			thing[i] = -1
			thingnum[i] = 0
		end
		local num = 0
		for i = 0, CC.MyThingNum - 1 do
			local id = JY.Base["物品" .. i + 1]
			if id >= 0 then
				if JY.Thing[id]["类型"] == 2 then
					thing[num] = id
					thingnum[num] = JY.Base["物品数量" .. i + 1]
					num = num + 1
				end
			end 
		end

		IsViewingKungfuScrolls = 1

		local r = SelectThing(thing, thingnum)
		if r >= 0 then
			UseThing(r)
			return 1
		end
		return 0
end

function ThingMenu(flag)

		local thing = {}
		local thingnum = {}
		for i = 0, CC.MyThingNum - 1 do
			thing[i] = -1
			thingnum[i] = 0
		end
		local num = 0
		for i = 0, CC.MyThingNum - 1 do
			local id = JY.Base["物品" .. i + 1]
			if id >= 0 then
				if flag == nil then 
					thing[num] = id
					thingnum[num] = JY.Base["物品数量" .. i + 1]
					num = num + 1
				else 	
					if JY.Thing[id]["类型"] == flag then
						thing[num] = id
						thingnum[num] = JY.Base["物品数量" .. i + 1]
						num = num + 1
					end
				end
			end 
		end

		--IsViewingKungfuScrolls = 1

		local r = SelectThing(thing, thingnum)
		if r >= 0 then
			UseThing(r)
			return 1
		end
		return 0
end

function Team(tab)
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	local size = CC.DefaultFont*0.7
	local size1 = CC.DefaultFont*0.6
	local size2 = CC.DefaultFont*0.55
	local cont = 1 
	local cont1 = 0
	local tru = 0
	local p = JY.Person
	local px = 0
	while true do 
		Cls()
		if JY.Restart == 1 then
			break
		end
		local menu = {} 
		local maxn = 4
		local i = 0
		for ii = 1,CC.TeamNum do 
			if JY.Base['队伍'..ii] >= 0 then 
				menu[#menu+1] = {p[JY.Base['队伍'..ii]]['姓名'],JY.Base['队伍'..ii]}
			end
		end
		if maxn > #menu then 
			maxn = #menu 
		end	 
		lib.PicLoadCache(92,9*2,0,0,1,nil,nil,bx*936)

		for ii = 1,maxn do 
			local h = 0
			local pyx = 0
			if CC.Png[p[menu[ii+cont1][2]]['半身像']] ~= nil then 
				pyx = CC.Png[p[menu[ii+cont1][2]]['半身像']]
			end
			
			local sm = p[menu[ii+cont1][2]]['生命']
			local smmax = p[menu[ii+cont1][2]]['生命最大值']
			local nl = p[menu[ii+cont1][2]]['内力']
			local nlmax = p[menu[ii+cont1][2]]['内力最大值']
			local tl = p[menu[ii+cont1][2]]['体力']
			local tlmax = 100
			
			lib.SetClip(bx*42+(ii-1)*bx*220, 0, bx*38+(ii-1)*bx*220+bx*197,by*768) --菜单背景图
			lib.LoadPNG(90,p[menu[ii+cont1][2]]['半身像']*2,bx*138+(ii-1)*bx*220-bx*pyx,by*250,2)
			lib.SetClip(0,0,0,0)
			
			lib.PicLoadCache(92,15*2,bx*138+(ii-1)*bx*220,by*425,2,256,nil,bx*170)
			
			DrawString(bx*138+(ii-1)*bx*220-string.len(menu[ii+cont1][1])*size/4,by*440,menu[ii+cont1][1],C_WHITE,size)
			if ii == cont or px == ii then 
				lib.PicLoadCache(92,10*2,bx*138+(ii-1)*bx*220, CC.ScreenH/2,2,256,nil,bx*200) --菜单背景图
			end

			h = h + 1
			
			local tfid = menu[ii+cont1][2]
			if JY.Base['畅想'] > 0 and tfid == 0 then 
				tfid = JY.Base['畅想']
			end	
			if RWWH[tfid] ~= nil then 
				DrawString(bx*60+(ii-1)*bx*220,by*440+h*by*30,'称号：'..RWWH[tfid],LimeGreen,size)
			end
			
			h = h + 1
			
			if RWTFLB[tfid] ~= nil then 
				DrawString(bx*60+(ii-1)*bx*220,by*440+h*by*30,'天赋：'..RWTFLB[tfid],LimeGreen,size)
			end
			
			h = h + 1
			
			lib.PicLoadCache(92,11*2,bx*138+(ii-1)*bx*220,by*450+h*by*30+size1/2,2,256,nil,bx*160)
			
			lib.SetClip(bx*138+(ii-1)*bx*220-bx*71, by*450+h*by*30+size1/2-by*12, bx*138+(ii-1)*bx*220-bx*71+bx*142*(sm/smmax),by*450+h*by*30+size1/2+by*12)
			lib.PicLoadCache(92,12*2,bx*138+(ii-1)*bx*220,by*450+h*by*30+size1/2,2,150,nil,bx*160)
			lib.SetClip(0,0,0,0)

			DrawString(bx*70+(ii-1)*bx*220,by*450+h*by*30,'命  '..p[menu[ii+cont1][2]]['生命'],C_WHITE,size1)
			h = h + 1
			
			lib.PicLoadCache(92,11*2,bx*138+(ii-1)*bx*220,by*450+h*by*30+size1/2,2,256,nil,bx*160)
			lib.SetClip(bx*138+(ii-1)*bx*220-bx*71, by*450+h*by*30+size1/2-by*12, bx*138+(ii-1)*bx*220-bx*71+bx*142*(nl/nlmax),by*450+h*by*30+size1/2+by*12)
			lib.PicLoadCache(92,13*2,bx*138+(ii-1)*bx*220,by*450+h*by*30+size1/2,2,150,nil,bx*160)
			lib.SetClip(0,0,0,0)

			DrawString(bx*70+(ii-1)*bx*220,by*450+h*by*30,'内  '..p[menu[ii+cont1][2]]['内力'],C_WHITE,size1)
			h = h + 1
			
			lib.PicLoadCache(92,11*2,bx*138+(ii-1)*bx*220,by*450+h*by*30+size1/2,2,256,nil,bx*160)
			lib.SetClip(bx*138+(ii-1)*bx*220-bx*71, by*450+h*by*30+size1/2-by*12, bx*138+(ii-1)*bx*220-bx*71+bx*142*(tl/tlmax),by*450+h*by*30+size1/2+by*12)
			lib.PicLoadCache(92,14*2,bx*138+(ii-1)*bx*220,by*450+h*by*30+size1/2,2,150,nil,bx*160)
			lib.SetClip(0,0,0,0)

			DrawString(bx*70+(ii-1)*bx*220,by*450+h*by*30,'体  '..p[menu[ii+cont1][2]]['体力'],C_WHITE,size1)
		end
	  
		ShowScreen()
		lib.Delay(CC.BattleDelay)
		local X,ktype,mx,my = lib.GetKey()
		if X == VK_SPACE or X == VK_RETURN then 
			tru = cont + cont1
			local id = JY.Base['队伍'..tru]
			if tab ~= nil then
				if tab[1] == '离队' then
					if tru > 1 then
						if JY.SubScene == 55 and JY.Base["队伍" .. tru] == 35 then
						elseif JY.SubScene == 82 then	
						else
							local personid = JY.Base["队伍" .. tru]
							if CC.PersonExit[personid] ~= nil then 
								local v = CC.PersonExit[personid]
								CallCEvent(v)
							end
							cont = 1
							cont1 = 0
						end
					end
				elseif tab[1] == '状态' then 
					ShowPersonStatus(tru)
				elseif tab[1] == '排序' then
					if px == 0 then
						if tru > 1 then 
							px = cont
						end
					else 
						if tru > 1 then
							JY.Base['队伍'..tru] = JY.Base['队伍'..px+cont1]
							JY.Base['队伍'..px+cont1] = id
							px = 0
						end
					end
				end
			else 
				break
			end
		elseif X == VK_ESCAPE or ktype == 4 then
			if tab ~= nil then
				if tab[1] == '离队' then 
					return nil
				end
			end
			if px > 0 then 
				px = 0 
			else 
				break
			end
		elseif X == VK_LEFT then
			if cont1 > 0 then 
				if cont > 1 then 
					cont = cont - 1
				else 
					cont1 = cont1 - 1	  
				end	
			else
				cont = cont - 1		
				if cont < 1 then 
					cont = maxn
					cont1 = #menu - cont
				end
			end
		elseif X == VK_RIGHT then
			cont = cont + 1		
			if cont > maxn then 
				cont = maxn
				cont1 = cont1 + 1
			end
			if cont1 + cont > #menu then 
				cont1 = 0
				cont = 1
			end
		elseif X == VK_UP or ktype == 6 then
			cont1 = cont1 - maxn
			cont = 1
			if cont1 < 0 then 
				cont1 = 0 
			end
		elseif X == VK_DOWN or ktype == 7 then
			cont1 = cont1 + maxn
			cont = maxn
			if cont1 + cont > #menu then 
				cont1 = #menu-cont
			end	
		else 
			local mxx = false
			for ii = 1,maxn do 
				if mx >= bx*33+(ii-1)*bx*220 and mx <= bx*30+(ii-1)*bx*220+bx*197 and 
					my >= by*55 and my <= by*710 then 
					cont = ii
					mxx = true
					break
				end
			end		
			if ktype == 3 and mxx == true then 
				tru = cont + cont1
				local id = JY.Base['队伍'..tru]
				if tab ~= nil then
			if tab[1] == '离队' then
					if tru > 1 then
						if JY.SubScene == 55 and JY.Base["队伍" .. tru] == 35 then
						elseif JY.SubScene == 82 then	
						else
							local personid = JY.Base["队伍" .. tru]
							if CC.PersonExit[personid] ~= nil then 
								local v = CC.PersonExit[personid]
								CallCEvent(v)
							end
							cont = 1
							cont1 = 0
						end
					end
					elseif tab[1] == '状态' then 
						ShowPersonStatus(tru)
					elseif tab[1] == '排序' then
						if px == 0 then
							if tru > 1 then 
								px = cont
							end
						else 
							if tru > 1 then
								JY.Base['队伍'..tru] = JY.Base['队伍'..px+cont1]
								JY.Base['队伍'..px+cont1] = id
								px = 0
							end
						end
					end
				else 
					break
				end
			end	
		end
	end  
	return tru
end

function Hp_Max(id)
	local p = JY.Person[id]
	local kflvl = 0
	local wgwl = 0
	local wgwl1 = 0
	local wgwl2 = 0
	if p["主运内功"] > 0 then
        local zy = p["主运内功"] 
  
        --[[
        for i = 1, JY.Base["武功数量"] do
            local kf = p["武功" .. i]
            local lv = p["武功等级" .. i]
            local dj = math.modf(lv/100)+1
            local wl = get_skill_power(id, kf, dj)
            if JY.Wugong[kf]['武功类型'] == 6 then 
                if wgwl < wl then 
                    wgwl = wl
                end
            end
        end
        ]]

		for i = 1, JY.Base["武功数量"] do
			if p["武功" .. i]== p["主运内功"] then
				kflvl = p["武功等级" .. i]
				break
			end
		end
		if kflvl == 999 then
			kflvl = 11
		else
			kflvl = math.modf(kflvl/100)+1
		end
		wgwl2 = get_skill_power(id, p["主运内功"], kflvl)	
        if id == 0 and (JY.Base["标准"] == 6  or  JY.Base["畅想"] == 637 or  JY.Base["畅想"] == 27 or JY.Base["畅想"] == 189 ) then
		    for i = 1, JY.Base["武功数量"] do
		    if p["武功" .. i]== p["天赋内功"] then
                wgwl1 = get_skill_power(id, p["天赋内功"], kflvl)
				end
			end	
		end	
        
		if wgwl1 < wgwl2 then
           wgwl = wgwl2
		else
           wgwl = wgwl1
		end		
--[[
		if wgwl >= 1400 then	
			p["生命最大值"] = p["生命增长"]  * p["等级"]*4+500+p["生命增长"]*(wgwl/5-140)  			
		elseif 1400 > wgwl and wgwl >= 1200 then	
			p["生命最大值"] = p["生命增长"]  * p["等级"]*4+400+p["生命增长"]*(wgwl/5-140)
		elseif 1200 > wgwl and wgwl >= 1000 then		
			p["生命最大值"] = p["生命增长"]  * p["等级"]*4+300+p["生命增长"]*(wgwl/5-150)	   
		elseif 1000 > wgwl and wgwl >= 800 then		
			p["生命最大值"] = p["生命增长"]  * p["等级"]*4+200+p["生命增长"]*(wgwl/5-140)					
		elseif wgwl <= 600  then		
			p["生命最大值"] = p["生命增长"]  * p["等级"]*4+100+p["生命增长"]*10	
		end		
]]
        if wgwl < 500 then 
            wgwl = 500
        end
		p["生命最大值"] = p["生命增长"]  * p["等级"]*4+500+p["生命增长"]*(wgwl/7-100)  
		if p["生命"] >  p["生命最大值"] then
         	p["生命"] =  p["生命最大值"]
		end
		if JY.Status ~= GAME_WMAP then
			AddPersonAttrib(id,'生命',math.huge)
		else 
			p["生命"] = limitX(p["生命"],0,p["生命最大值"])
		end	
	else	
		p["生命最大值"] = p["生命增长"] * p["等级"]*4
		if id == 0 and (JY.Base["标准"] == 6  or  JY.Base["畅想"] == 637  or  JY.Base["畅想"] == 27 or JY.Base["畅想"] == 189 ) then
            for i = 1, JY.Base["武功数量"] do
                if p["武功" .. i]== p["天赋内功"] then
                    kflvl = p["武功等级" .. i]
                    break
                end
            end
            if kflvl == 999 then
                kflvl = 11
            else
                kflvl = math.modf(kflvl/100)+1
            end
		    wgwl = get_skill_power(id, p["天赋内功"], kflvl)
            --[[
		    if wgwl >= 1400 then	
			    p["生命最大值"] = p["生命增长"]  * p["等级"]*4+500+p["生命增长"]*(wgwl/5-140)  			
		    elseif 1400 > wgwl and wgwl >= 1200 then	
			    p["生命最大值"] = p["生命增长"]  * p["等级"]*4+400+p["生命增长"]*(wgwl/5-140)
		    elseif 1200 > wgwl and wgwl >= 1000 then		
			   p["生命最大值"] = p["生命增长"]  * p["等级"]*4+300+p["生命增长"]*(wgwl/5-150)	   
		   elseif 1000 > wgwl and wgwl >= 800 then		
			   p["生命最大值"] = p["生命增长"]  * p["等级"]*4+200+p["生命增长"]*(wgwl/5-140)					
		   elseif wgwl <= 600  then		
			   p["生命最大值"] = p["生命增长"]  * p["等级"]*4+100+p["生命增长"]*10	
		   end	
        ]]
        
            if wgwl < 500 then 
                wgwl = 500
            end
            
            p["生命最大值"] = p["生命增长"]  * p["等级"]*4+500+p["生命增长"]*(wgwl/7-100)  
		end
        
        
		if p["生命"] >  p["生命最大值"] then
         	p["生命"] =  p["生命最大值"]
		end
		if JY.Status ~= GAME_WMAP then
			AddPersonAttrib(id,'生命',math.huge)
		else 
			p["生命"] = limitX(p["生命"],0,p["生命最大值"])
		end		
	end
end

function tgsave(flag)
	
	local tgjl = 0
	local tg = 0
	local tgsize = 0
	if flag == nil then
		if CC.Week < 100 then
			if JY.Base["周目"] == CC.Week then
				CC.Week = CC.Week + 1
			end
		end
	end
	--CC.TGJL = {9973,9970,9972,9971,9996,9998,9987,9984,9968,9992}
	tg = #CC.TGJL
    
	tgjl = tgjl + tg

	tgjl = tgjl + #CC.commodity

	tgjl = tgjl + 4

	local size = (tgjl) * 4
	local data = Byte.create(size * 4)
	
	Byte.set32(data, 0, tgjl)
	Byte.set32(data, 4, CC.Sp)
	Byte.set32(data, 8, CC.Week)
	Byte.set32(data, 12, tg)
	tgsize = 16
	for i = 0,tg-1 do
		Byte.set32(data, tgsize, CC.TGJL[i+1]);
		tgsize = tgsize + 4
	end
	for i = 1,#CC.commodity do
		Byte.set32(data, tgsize, CC.commodity[i][3]);
        tgsize = tgsize + 4
		Byte.set32(data, tgsize, CC.commodity[i][5]);
        tgsize = tgsize + 4
	end
	Byte.savefile(data, CONFIG.DataPath..'TgJl', 0, size);

	CC.TJMSJ = {} 
	CC.TJM = 0
end

function tgload()

	local tgjl = 0
	local tg = 0
	local size = 0
	local tgsize = 0
	local fp_tmp=io.open(CONFIG.DataPath..'TgJl',"r");
	if fp_tmp then
		fp_tmp:close();
		
		local data_tgjl = Byte.create(4);
		Byte.loadfile(data_tgjl,CONFIG.DataPath..'TgJl', 0, 4);
		tgjl = Byte.get32(data_tgjl,0);
		size = (tgjl) * 4

		local data = Byte.create(size*4);
		Byte.loadfile(data,CONFIG.DataPath..'TgJl', 0, size);
		CC.Sp = Byte.get32(data,4);
		CC.Week = Byte.get32(data,8);
		tg = Byte.get32(data,12);
		tgsize = 16
		for i=1,tg do
			CC.TGJL[i]=Byte.get32(data, tgsize);
			tgsize = tgsize + 4
		end

		for i = 1,#CC.commodity do
			CC.commodity[i][3]=Byte.get32(data, tgsize);
            tgsize = tgsize + 4
			CC.commodity[i][5]=Byte.get32(data, tgsize);
			tgsize = tgsize + 4
		end

	end

end


function Weekload()
	local fp_tmp=io.open(CONFIG.DataPath..'TgJl',"r");
	if fp_tmp then
		fp_tmp:close();

		local data_Sp = Byte.create(4);
		Byte.loadfile(data_Sp,CONFIG.DataPath..'TgJl', 4, 4);
		CC.Sp = Byte.get32(data_Sp,0);

		local data_Week = Byte.create(4);
		Byte.loadfile(data_Week,CONFIG.DataPath..'TgJl', 8, 4);
		CC.Week = Byte.get32(data_Week,0);

	end
end

function GAME_START1()
	local bx = CC.ScreenW/936
	local by = CC.ScreenH/702
    local tb = 1
    local page = 1
    local size = CC.DefaultFont*0.7
    JY.Base["难度"] = 1
	local m = { {'周目选择','周目商店'},
                {'普通','单通','娱乐'},
                {'简单','普通','困难','地狱'},
                {'下一步'},
                }
    local sz = {{582,161,180},
                {556,328,120},
                {518,489,105},
                {818,656,0},
                }        

    local sm = {'Ｗ我方队友可以参加战斗，我方战场上场人物为6人Ｒ【提示：此模式为正常模式，一切以此模式为基准】',
                'Ｗ所有战斗只有主角可以参战Ｒ【郑重提示：此模式为自虐模式，若是造成无法游戏的后果，请自行调整模式。附：“此模式尔等无人权，请务BB”】',
                'Ｗ所有战斗只有主角可以参战，但是主角享有在对队友的所有天赋Ｒ【提示：此模式为娱乐模式，请勿炫耀】'
}
    local zmmax = CC.Week
    local w = math.modf(bx*350/size/0.96)
	while true do 
        if JY.Restart == 1 then
            break
        end	
		ClsN()
        local zm = JY.Base["周目"]
        if page ==2 then 
            lib.LoadPNG(91,48*2,0,0,1)
            tjm(bx*52,by*108,sm[tb],C_WHITE,size*0.96,w,size*1.6)
        else
            lib.LoadPNG(91,44*2,0,0,1)
            DrawString(bx*159-string.len(zm)/4*size,by*433-size/2,zm,C_RED,size)
            DrawString(bx*159-string.len(zmmax)/4*size,by*468-size/2,zmmax,C_RED,size)
            DrawString(bx*150,by*504-size/2,m[3][JY.Base["难度"]],C_RED,size)
            DrawString(bx*150,by*538-size/2,m[2][JY.Base["单通"]+1],C_RED,size)
        end
        
        for i = 1,#m do 
            for j = 1,#m[i] do
                local cl = M_Wheat
                local s = m[i][j]
                if page == i then
                    if tb == j then 
                        cl = C_RED
                    end
                end
                DrawString(bx*sz[i][1]-string.len(s)/4*size + (j-1)*bx*sz[i][3],by*sz[i][2]-size/2,s,cl,size)
            end
        end
        

        ShowScreen()
        lib.Delay(CC.BattleDelay)
        local X, ktype, mx, my = lib.GetKey();
        if X == VK_SPACE or X == VK_RETURN then
            if page == 1 then 
                if tb == 1 then 
                    JY.Base["周目"] = InputNum("选择周目",1,zmmax);
                else
                    zmStore()
                end
            elseif page == 2 then 
                JY.Base["单通"] = tb - 1
            elseif page == 3 then 
                JY.Base["难度"] = tb
            elseif page == 4 then 
                break
            end
		elseif X == VK_ESCAPE or ktype == 4 then

		elseif X == VK_UP then
            page = page - 1 
            if page < 1 then 
                page = #m
            end
            tb = 1
        elseif X == VK_DOWN then
            page = page + 1 
            if page > #m then 
                page = 1
            end
            tb = 1
        elseif X == VK_LEFT then
            tb = tb - 1 
            if tb < 1 then 
                tb = #m[page]
            end
		elseif X == VK_RIGHT then
            tb = tb + 1 
            if tb > #m[page] then 
                tb = 1
            end
        else 
            local mxx = false
            
            if mx >= bx*530 and mx <= bx*638 and my >= by*145 and my <= by*180 then 
                page = 1 
                tb = 1
                mxx = true
            end
            if mx >= bx*708 and mx <= bx*816 and my >= by*145 and my <= by*180 then 
                page = 1 
                tb = 2
                mxx = true
            end
            if mx >= bx*512 and mx <= bx*600 and my >= by*312 and my <= by*345 then 
                page = 2
                tb = 1
                mxx = true
            end
            if mx >= bx*632 and mx <= bx*720 and my >= by*312 and my <= by*345 then 
                page = 2
                tb = 2
                mxx = true
            end
            if mx >= bx*753 and mx <= bx*841 and my >= by*312 and my <= by*345 then 
                page = 2
                tb = 3
                mxx = true
            end
            if mx >= bx*474 and mx <= bx*562 and my >= by*473 and my <= by*506 then
                page = 3
                tb = 1
                mxx = true
            end
            if mx >= bx*580 and mx <= bx*668 and my >= by*473 and my <= by*506 then
                page = 3
                tb = 2
                mxx = true
            end
            if mx >= bx*685 and mx <= bx*773 and my >= by*473 and my <= by*506 then
                page = 3
                tb = 3
                mxx = true
            end
            if mx >= bx*790 and mx <= bx*878 and my >= by*473 and my <= by*506 then
                page = 3
                tb = 4
                mxx = true
            end
            if mx >= bx*742 and mx <= bx*896 and my >= by*638 and my <= by*673 then
                page = 4
                tb = 1
                mxx = true
            end
            if mxx == true and ktype == 3 then
                if page == 1 then 
                    if tb == 1 then 
                        JY.Base["周目"] = InputNum("选择周目",1,zmmax);
                    else
                        zmStore()
                    end
                elseif page == 2 then 
                    JY.Base["单通"] = tb - 1
                elseif page == 3 then 
                    JY.Base["难度"] = tb
                elseif page == 4 then 
                    break
                end
            end
		end
	end

end

function GAME_START2()
	local bx = CC.ScreenW/936
	local by = CC.ScreenH/702
	--local size = CC.DefaultFont
    local tb = 1
    local page = 1
    local size = CC.DefaultFont*0.7
	local p = JY.Person[0]
	local m = { {'阴性','阳性','调和'},
                {'1-30','31-50','51-79','80-100'},
                {'下一步'},
                }
    local sz ={{520,327,155},
               {520,488,105},
		       {818,656,0},
                }  
    local nlsm = {
                    '阴性内力在攻击方面得天独厚，时序回血、回体能力突出。*江湖中传说的阴性内功之最莫属九阴神功，高连击，高暴击，高暴击伤害，只要出手必让对手没有还手之力，搭配上逆运真经，先天功，飞天神行等武功让敌人无从防御。*推荐内功：九阴神功／逆运神功／先天功／鲸息功／长生诀。*推荐轻功:蛇行狸翻／梯云纵／飞天神行',
                    '阳性内力在防御方面更胜一筹，时序回内、回复冲穴、免疫破绽、连击减伤等能力突出。*江湖中传说的阳性内功之最莫属九阳神功，搭配上瑜伽神功，龙象般若功，金雁功，乾坤大挪移等让防御固若金汤。',               
                    '调和内力是行走江湖的万金油，少林寺绝学内功《易筋经》易筋煅骨，不但能增加人物三围属性，与罗汉伏魔功、金刚不坏神功一起修炼更有特独妙处。攻击与防御都有不俗表现。',  
                    }

    local zzsm = {'特殊武功：太玄神功，左右互搏',
                 '特殊武功：左右互搏',
                 '特殊武学：中庸之道',
                 '特殊武学：太极神功、斗转星移',
                 }
    p["内力性质"] = 0
    local w = math.modf(bx*333/size)
	while true do 
        if JY.Restart == 1 then
            break
        end	
		ClsN()
        local zz = JY.Person[0]["资质"]
	 
        lib.LoadPNG(91,45*2,0,0,1)
        for i = 1,#m do 
            for j = 1,#m[i] do
                local cl = M_Wheat
                local s = m[i][j]
                if page == i then
                    if tb == j then 
                        cl = C_RED
                    end
                end
                DrawString(bx*sz[i][1]-string.len(s)/4*size + (j-1)*bx*sz[i][3],by*sz[i][2]-size/2,s,cl,size)
            end
        end
        DrawString(bx*70,by*99,"内力性质",M_Wheat,size)
        DrawString(bx*70+size*5,by*99,m[1][p["内力性质"]+1],C_RED,size)
        
        DrawString(bx*260,by*97,'资质',M_Wheat,size)
		DrawString(bx*260+size*3,by*97,zz,C_RED,size)
        
        local n = 0
        if page == 1  then
            n = tjm(bx*68,by*130,nlsm[tb],C_WHITE,size,w,size)
        else 
            n = tjm(bx*68,by*130,nlsm[p["内力性质"]+1],C_WHITE,size,w,size)
        end
        n = n + 1
        for i = 1,#zzsm do 
            DrawString(bx*68,by*130+(n+i-1)*size,zzsm[i],M_Wheat,size)
        end
        ShowScreen()
       
        lib.Delay(CC.BattleDelay)
        local X, ktype, mx, my = lib.GetKey();
        if X == VK_SPACE or X == VK_RETURN then
            if page == 1 then   
                 p["内力性质"] = tb - 1
            elseif page == 2 then 
				if tb == 1 then
					JY.Person[0]["资质"] = InputNum("输入资质",1,30)					
				elseif tb == 2 then
					JY.Person[0]["资质"] = InputNum("输入资质",31,50)
				elseif tb == 3 then
					JY.Person[0]["资质"] = InputNum("输入资质",51,79)  
				elseif tb == 4 then
					JY.Person[0]["资质"] = InputNum("输入资质",80,100)					
				end
            elseif page == 3 then 
                break
            end
		elseif X == VK_ESCAPE or ktype == 4 then

		elseif X == VK_UP then
            page = page - 1 
            if page < 1 then 
                page = #m
            end
            tb = 1
        elseif X == VK_DOWN then
            page = page + 1 
            if page > #m then 
                page = 1
            end
            tb = 1	
        elseif X == VK_LEFT then
            tb = tb - 1 
            if tb < 1 then 
                tb = #m[page]
            end
		elseif X == VK_RIGHT then
            tb = tb + 1 
            if tb > #m[page] then 
                tb = 1
            end
        else 
            local mxx = false
            
            if mx >= bx*475 and mx <= bx*565 and my >= by*313 and my <= by*345 then 
                page = 1 
                tb = 1
                mxx = true
            end
            if mx >= bx*630 and mx <= bx*720 and my >= by*313 and my <= by*345 then 
                page = 1 
                tb = 2
                mxx = true
            end
            if mx >= bx*785 and mx <= bx*875 and my >= by*313 and my <= by*345 then 
                page = 1
                tb = 3
                mxx = true
            end		
            if mx >= bx*477 and mx <= bx*567 and my >= by*473 and my <= by*505 then 
                page = 2
                tb = 1
                mxx = true
            end
            if mx >= bx*581 and mx <= bx*671 and my >= by*473 and my <= by*505 then
                page = 2
                tb = 2
                mxx = true
            end			
            if mx >= bx*688 and mx <= bx*778 and my >= by*473 and my <= by*505 then
                page = 2
                tb = 3
                mxx = true
            end
            if mx >= bx*788 and mx <= bx*878 and my >= by*473 and my <= by*505 then
                page = 2
                tb = 4
                mxx = true
            end
            if mx >= bx*742 and mx <= bx*896 and my >= by*638 and my <= by*673 then
                page = 3
                tb = 1
                mxx = true
            end
            if mxx == true and ktype == 3 then
               if page == 1 then 
                    if tb == 1 then
                       p["内力性质"] = 0
					elseif tb == 2 then
						   p["内力性质"] = 1				
					elseif tb == 3 then
                        p["内力性质"] = 2
				    end
               elseif page == 2 then 
				   if tb == 1 then
					   p["资质"] = InputNum("输入资质",1,30)
				   elseif tb == 2 then
					  p["资质"] = InputNum("输入资质",31,50)
				   elseif tb == 3 then
					   p["资质"] = InputNum("输入资质",51,79)  
				   elseif tb == 4 then
					   p["资质"] = InputNum("输入资质",80,100)					
				   end
               elseif page == 3 then 
                   break
               end
            end
		end
	end
end

function TGTF()
    local bx = CC.ScreenW/936
    local by = CC.ScreenH/702
    local cot = 1
    local cot1 = 0
    local cot2 = 0
    local size = CC.DefaultFont*0.7
    local maxn = 7
    local page = 1
    local jl = 0
    local menu = {}
    local w = math.modf(bx*218/size)
	--if existFile(CONFIG.DataPath..'TgJl') then
	--	tgload()
		
    for i = 1,#CC.TGJL do
        menu[#menu+1] = CC.TGJL[i]
    end
		
    if #menu <= 0  then
        return   
    end
	--end
    --menu = {9999,9998,9997,9996,9995,9994,9993,9992,9991,9990,9988,9987,9986,9985,9984}
    menu[#menu+1] = -1
    local max = math.ceil((#menu-1)/4)
    if maxn > max then 
        maxn = max
    end
    
    while true do
	   if JY.Restart == 1 then
            break
       end	
        ClsN()
        lib.LoadPNG(91,46*2,0,0,1)
        for i = 1,4 do 
            for j = 1,maxn do
                local tf = i + (j-1+cot2)*4
                local sm = CC.PTFSM[menu[tf]]
                local cl = M_Wheat
                if tf == cot + cot1*4 then 
                    cl = C_RED
                end
                if sm ~= nil then
                    lib.LoadPNG(91,47*2,bx*396+(i-1)*bx*150,by*100+(j-1)*by*63,2)
                    DrawString(bx*396+(i-1)*bx*150-string.len(sm[1])/4*size,by*99+(j-1)*by*63-size/2,sm[1],cl,size)
                end
            end
        end
        
        local n = 0
        local dtf = '无'
        local xtf = '无'
        
        DrawString(bx*63,by*100-size/2,'已选天赋',M_Wheat,size)
        
        if jl > 0 then 
            if CC.PTFSM[jl] ~= nil then 
                local ptf = CC.PTFSM[jl][2]
                dtf = CC.PTFSM[jl][1]
                if ptf ~= nil then 
                    n = tjm(bx*63,by*100-size/2 + size,ptf,C_WHITE,size,w,size)
                end   
            end
        else 
            n = tjm(bx*63,by*100-size/2 + size,'没有天赋',C_WHITE,size,w,size)
        end
        n = n + 2
        DrawString(bx*190,by*100-size/2,dtf,C_RED,size)
        
        if cot + cot1*4 == #menu then 
            DrawString(bx*818-1.5*size,by*656-size/2,'下一步',C_RED,size)
        else    
            DrawString(bx*818-1.5*size,by*656-size/2,'下一步',M_Wheat,size)
        end
        
        DrawString(bx*63,by*100-size/2+ size + n*size,'当前天赋',M_Wheat,size)
        if CC.PTFSM[menu[cot+cot1*4]]~= nil then
            xtf = CC.PTFSM[menu[cot+cot1*4]][1]
        end    
        DrawString(bx*190,by*100-size/2+ size + n*size,xtf,C_RED,size)
        n = n + 1
        
        if CC.PTFSM[menu[cot+cot1*4]]~= nil then
            local ptf = CC.PTFSM[menu[cot+cot1*4]][2]
            if ptf ~= nil then
                n = tjm(bx*63,by*100-size/2 + size+n*size,ptf,C_WHITE,size,w,size)
            end
        end

        
        --缺失背景图，无法继续做
        ShowScreen()
        lib.Delay(CC.BattleDelay)
        local X, ktype, mx, my = lib.GetKey();
        if X == VK_SPACE or X == VK_RETURN then
            if cot + cot1*4 < #menu then 
                jl = menu[cot+cot1*4]
            else
                if jl > 0 then
                CC.TG[jl] = 1
				end
                break
            end
		elseif X == VK_ESCAPE or ktype == 4 then

		elseif X == VK_UP then
			if cot1 > 0 then
				if cot1 == cot2 then
					cot2 = limitX(cot2 - 1,0)
				end
				cot1 = cot1 - 1
			else 
				cot = 1
			end
        elseif X == VK_DOWN then
			if cot + cot1*4 < #menu then
				if cot1 < math.ceil((#menu)/4) - 1 then 
					cot1 = cot1 + 1 
					if cot + cot1*4 > (#menu) then
						cot = (#menu) - cot1*4
					end
				else 
					cot = (#menu) - cot1*4
				end
				if cot1 - cot2 > 4 then
					cot2 = cot2 + 1
				end
			end
        elseif X == VK_LEFT then
			cot = cot - 1 
			if cot1 > 0 then 
				if cot < 1 then
					if cot1 == cot2 then
						cot2 = limitX(cot2 - 1,0)
					end
					cot1 = cot1 - 1
					cot = 4
				end
			elseif cot < 1 then 
				cot = 1
			end
		elseif X == VK_RIGHT then
			if cot + cot1*4 < (#menu) then
				cot = cot + 1
				if cot > 4 then
					if cot1 < math.ceil((#menu)/4) - 1 then 
						cot = 1 
						cot1 = cot1 + 1
					end	
				end
				if cot1 - cot2 > 4 then
					cot2 = cot2 + 1
				end
			end
        else
			local mxx = false
            if mx >= bx*742 and mx <= bx*896 and my >= by*638 and my <= by*673 then
                cot1 = maxn-1
                cot = (#menu) - cot1*4
                mxx = true
            else
                for i = 1,4 do 
                    for j = 1,maxn do
                        --bx*396+(i-1)*bx*150,by*100+(j-1)*by*63
                        if mx >= bx*396+(i-1)*bx*150-bx*67 and mx <= bx*396+(i-1)*bx*150+bx*67 and 
                            my >= by*100+(j-1)*by*63-by*17 and my <= by*100+(j-1)*by*63+by*17 then 
                            local p = i+(j - 1 + cot2)*4
                            if CC.PTFSM[menu[p]] ~= nil then 
                                cot = i 
                                cot1 = j - 1 + cot2
                                mxx = true 
                                break
                            end
                        end	
                    end
                end	 
            end  
            if mxx == true and ktype == 3 then 
                if cot + cot1*4 < #menu then 
                    jl = menu[cot+cot1*4]
                else
                    if jl > 0 then
                    CC.TG[jl] = 1
					end
                    break
                end
            end
        end
    end
    --CC.TGJL = {}
end

function NpcWar()
local menu = {}
local n = 0
for i = 1,JY.PersonNum-1 do
    if CC.PersonExit[i] == nil then 
        n = n + 1
        menu[n] = {JY.Person[i]['姓名'],nil,1,i}
    end
end

CC.HSLJ = {}
while #CC.HSLJ < 50 do 
	   if JY.Restart == 1 then
            break
       end	
    Cls()
    local r = ShowMenu4(menu,#menu,5,-2,-2,-2,-2,1,1,CC.DefaultFont,C_GOLD,C_WHITE,"请选择想要上场人物，最多50人："..#CC.HSLJ,C_ORANGE, C_WHITE,10)
    if r <= 0 then 
        break
    else
        CC.HSLJ[#CC.HSLJ + 1] = menu[r][4]
        table.remove(menu,r)
    end
    Cls()
end

if #CC.HSLJ == 0 then 
    return    
end

CC.HSLJ2 = {}
while #CC.HSLJ2 < 50 do 
	   if JY.Restart == 1 then
            break
       end	
    Cls()
    local r = ShowMenu4(menu,#menu,5,-2,-2,-2,-2,1,1,CC.DefaultFont,C_GOLD,C_WHITE,"请选择想要上场人物，最多50人："..#CC.HSLJ2,C_ORANGE, C_WHITE,10)
    if r <= 0 then 
        break
    else
        CC.HSLJ2[#CC.HSLJ2 + 1] = menu[r][4]
        table.remove(menu,r)
    end
    Cls()
    
end

if #CC.HSLJ2 == 0 then 
    return    
end

WarMain(354)
end

--传送地址列表
function My_ChuangSong_List()
	local menu = {};
	for i = 0, JY.SceneNum-1 do
		--不显示的场景：闯王宝藏1 3 明教地道，高昌迷宫+沙漠废墟3组 少林寺 思过崖 梅庄地牢 大功坊地窖 无量山洞 鹿鼎山1 3 少林后山 皇宫 北京郊外 鳌府密室 华山绝顶 绝情谷底 古墓密道 峨眉金顶 鹊桥 黑山大会
		--老祖居 万安寺顶 华山秘洞 不老长春谷 六合塔 小村 襄阳城外 岳王洞
		if i == 5 or i == 85 or i == 13 or i == 14 or i == 15 or i == 86 or i == 88 or i == 89 
		or i == 28 or (i >= 81 and i <= 83) or i == 42 or i == 67 or i == 91 or i == 106 
		or i == 108 or i == 109 or i == 110 or i == 111 or i == 113 or i == 114 or i == 116 
		or i == 117 or i == 104 or i == 119 or i == 102 or i == 122 or i == 123 or i == 124 
		or i == 134 or i == 70 or i == 131 or i == 115 or i == 137 or i == 138 or i == 140 or i == 141 
		or i==126 or i==125 or i == 142 or i == 143 or i == 144 or i == 145 or i== 146 then
		
		else
			--无酒不欢：这里i即为场景编号
			menu[i+1] = {JY.Scene[i]["名称"], JY.Scene[i]["进入条件"], i, JY.Scene[i]["场景类型"]};	
		end
	end

	--颜色依次为常规颜色和选中颜色
	local r = TeleportMenu(menu, C_GOLD, C_WHITE);
	
	--返回值小于0（ESC），直接返回
	if r < 0 then
		return 0;
	end
	
	--返回值大于等于0，返回值即为场景编号
	if r >= 0 then	
		local sid = r;

		
		My_Enter_SubScene(sid,-1,-1,-1);
	end
	return 1;
end

--加强版传送地址菜单
function My_ChuangSong_Ex()     
	local title = "雇佣马车";
	local str = JY.Person[0]["外号"].."想去什么地方？*路费纹银三两*再远也给您送到";
	local btn = {"指点江山", "激扬文字"};
	local num = #btn;
	local r = JYMsgBox(title,str,btn,num,119,1);
	if r == 1 then
		return My_ChuangSong_List();
	elseif r == 2 then
		Cls();
		local sid = InputNum("场景代码",0,JY.SceneNum-1,1);
		if sid ~= nil then			
			--标注几个不显示的：闯王宝藏1 3 明教地道，高昌迷宫+沙漠废墟3组 少林寺 思过崖 梅庄地牢 大功坊地窖 无量山洞 鹿鼎山1 3 鹊桥 不老长春谷
			if sid == 5 or sid == 85 or sid == 13 or sid == 14 or sid == 15 or sid == 86 or sid == 88 or sid == 89 
				or sid == 28 or (sid >= 81 and sid <= 83) or sid == 42 or sid == 67 or sid == 91 or sid == 106 
				or sid == 108 or sid == 109 or sid == 110 or sid == 111 or sid == 113 or sid == 114 or sid == 116 
				or sid == 117 or sid == 104 or sid == 119 or sid == 102 or sid == 122 or sid == 123 or sid == 124 
				or sid == 134 or sid == 70 or sid == 131 or sid == 115 or sid == 137 or sid == 138 or sid == 140 or sid == 141 
				or sid==126 or sid==125 or sid == 142 or sid == 143 or sid == 144 or sid == 145 or sid== 146 or JY.Scene[sid]["进入条件"] == 1 then
				say("１Ｒ您目前不能进入此场景。", 119, 5, "车夫");
				return 1;
			else
				My_Enter_SubScene(sid,-1,-1,-1);
			end
		end
	end
end

--进练功房
function LianGong(lx)
	JY.Person[591]["等级"] = 1
	JY.Person[591]["内力性质"] = lx
	local id = math.random(190)
	JY.Person[591]["头像代号"] = JY.Person[id]["头像代号"]
	for i = 1,5 do 
		JY.Person[591]["出招动画帧数"..i] = JY.Person[id]["出招动画帧数"..i]
		JY.Person[591]["出招动画延迟"..i] = JY.Person[id]["出招动画延迟"..i]
		JY.Person[591]["武功音效延迟"..i] = JY.Person[id]["武功音效延迟"..i]
	end
	JY.Person[591]["半身像"] = JY.Person[id]["半身像"]
	JY.Person[591]["生命最大值"] = 10
	JY.Person[591]["生命"] = JY.Person[591]["生命最大值"]
    JY.Person[591]["畅想分阶"] = 7
	instruct_6(226, 8, 0, 1)
	JY.Person[591]["内力性质"] = 0
	light()
	--return 1;
end

--武功特效说明
function WuGongIntruce()
	local menu = {};
	
	for i = 1, JY.WugongNum-1 do
		menu[i] = {i..JY.Wugong[i]["名称"], nil, 0}
	end
	
	--拥有的秘籍
	for i = 1, CC.MyThingNum do
    if JY.Base["物品" .. i] > -1 and JY.Base["物品数量" .. i] > 0 then
    	local wg = JY.Thing[JY.Base["物品" .. i]]["练出武功"];
    	if wg > 0 then
    		menu[wg][3] = 1;
    	end
    else
    	break;
    end
  end
  
  --学会的武功
  for i=1, CC.TeamNum do
  	if JY.Base["队伍"..i] >= 0 then
  		for j=1, 10 do
  			if JY.Person[JY.Base["队伍"..i]]["武功"..j] > 0 then
  				menu[JY.Person[JY.Base["队伍"..i]]["武功"..j]][3] = 1;
  			else
  				break;
  			end
  		end
  	else
  		break;
  	end
  end
	
	local r = -1;
	while true do
		Cls();
		
		r = ShowMenu2(menu,JY.WugongNum-1,4,12,10,(CC.ScreenH-12*(CC.DefaultFont+CC.RowPixel))/2+20,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE, "请选择查看的武功", r);
		--local r = ShowMenu(menu,n,15,CC.ScreenW/4,20,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);
		
		if r > 0 and r < JY.WugongNum then	
			InstruceWuGong(r);
		else
			break;
		end
	end
	
end

--显示武功或内功特效
function InstruceWuGong(id)
	if id < 0 or id >= JY.WugongNum then
		QZXS("武功未知错误，无法查看");
		return;
	end
	local filename = string.format("%s%d.txt", CONFIG.WuGongPath,id)
	if existFile(filename) == false then
		QZXS("此武功未包含任何说明，请自行琢磨");
		return;
	end
	DrawTxt(filename);
end

function TSInstruce()
	local filemenu = {};
	local n = 0;
	for i=1, math.huge do
		if existFile(string.format("%s%d.txt",CONFIG.HelpPath, i)) then
			filemenu[i] = string.format("%s%d.txt",CONFIG.HelpPath, i);
			n = n + 1;
		else
			break;
		end
	end
	
	local menu = {}
	local maxlen = 0;
	for i=1, n do
		local file = io.open(filemenu[i],"r")
		local str = file:read("*l")
		
		if str == nil then
			str = " ";
		end
		
		if #str > maxlen then
			maxlen = #str;
		end
		
		menu[i] = {i..str, nil, 1};
		
		file:close()
	end
	
	local size = CC.DefaultFont;
	
	while true do
		Cls();
		--local r = ShowMenu(menu,n,10,x1,y1,0,0,1,1,size,C_ORANGE,C_WHITE);
		local r = ShowMenu2(menu,#menu,2,12,20,(CC.ScreenH-12*(size+CC.RowPixel))/2+20,0,0,1,1,size,C_ORANGE,C_WHITE);
		if r > 0 then
			InstruceTS(r);
		else
			break;
		end
	end
end

--显示武功或内功特效
function InstruceTS(id)
		
	local filename = string.format("%s%d.txt", CONFIG.HelpPath,id)
	if existFile(filename) == false then
		QZXS("未找到相关的攻略文件");
		return;
	end
	
	DrawTxt(filename);
end

function DrawTxt(filename)
	Cls();
	
	--读取文件说明
	local file = io.open(filename,"r")
	local str = file:read("*a")
	file:close()
	
	local size = CC.DefaultFont;
	local color = C_WHITE;
	
	local linenum = 50;		--显示长度
	local maxlen = 14;
	local w = linenum*size/2 + size;
	local h = maxlen*(size+CC.RowPixel) + 2*CC.RowPixel;
	
	local bx = (CC.ScreenW-w)/2;
	local by = (CC.ScreenH-h)/2;
	DrawBox(bx,by,bx+w,by+h,C_WHITE);		--底边框
	local x = bx + CC.RowPixel;
	local y = by + CC.RowPixel;
	
	local surid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)
	
	local strcolor = AnalyString(str)
	local l = 0
	local row = 0;


	for i,v in pairs(strcolor) do
		while 1 do
			if v[1] == nil then
				break;
			end
			local index = string.find(v[1], "\n")
			
			if l+#v[1] < linenum and index == nil then		--如果未到换行，没有找到换行
				DrawString(x + l*size/2, y + row*(size+CC.RowPixel), v[1], v[2] or color, size);
				l = l + #v[1]

				if i == #strcolor then
					--显示文字	ALungky:j 改成 j+1解决了末尾文字有时候无法显示的问题。
					for j=0, l do
						lib.SetClip(x,y,x+(j+1)*size/2,y+size+row*(size+CC.RowPixel));
						ShowScreen(1);
					end
					lib.SetClip(0,0,0,0);
				end
				break;
			else	--如果达到换行
				local tmp, pos1, pos2;
				if index == nil then
					pos1 = linenum-l;
					pos2 = pos1+1;
				else
					pos1 = index-1;
					pos2 = pos1+2;
					
					if pos1 > linenum-l then
						index = nil;
						pos1 = linenum-l;
						pos2 = pos1+1;
					end
				end
				
				--这个用于判断是否已经到达v[1]的最后内容部分
				if pos1 > #v[1] then
					tmp = v[1];
					v[1] = nil;
				else
					tmp = string.sub(v[1], 1, pos1)
					local flag = 0
					for i=1, pos1 do
						if string.byte(tmp, i) <= 127 then
							flag = flag + 1;
						end
					end
					
	
					if math.fmod(flag,2) == 1 and index == nil  then		--如果包含有单字符
							if string.byte(tmp, -1) > 127 then
								tmp = string.sub(v[1], 1, pos1-1);
								pos2 = pos2 - 1
							end
					end
	
					v[1] = string.sub(v[1], pos2);
				end
					
	
					DrawString(x + l*size/2, y + row*(size+CC.RowPixel), tmp, v[2] or color, size);
	
	
					l = l + #tmp
					--显示文字
					for j=0, l do
						lib.SetClip(x,y,x+j*size/2,y+size+row*(size+CC.RowPixel));
						ShowScreen(1);
					end
					
					--行数+1
					row = row + 1
					l = 0

				
			end

			lib.SetClip(0,0,0,0);
			
			if row == maxlen then
				WaitKey();
				row = 0;
				Cls();
				lib.LoadSur(surid, 0, 0)
				
			end
		end
	end
	lib.SetClip(0,0,0,0);
	WaitKey();
	lib.FreeSur(surid)
end

--十四本天书之后得到5000两
--修复自动洗四神技的BUG
function NEvent2(keypress)
    --[[
	if JY.SubScene == 70 and GetD(70, 3, 0) == 0 and instruct_18(151) then
		instruct_3(70, 3, 1, 0, 0, 0, 0, 2610, 2610, 2610, 0, -2, -2)
	end
	if GetD(70, 3, 5) == 2610 and JY.SubScene == 70 and JY.Base["人X1"] == 8 and JY.Base["人Y1"] == 41 and JY.Base["人方向"] == 2 and (keypress == VK_SPACE or keypress == VK_RETURN) then
		say("１咦，有张纸条……Ｈ（"..JY.Person[0]["外号2"].."，这是留给你的五千两银子，好好准备一下吧）Ｈ哈，那老家伙还很够意思嘛！",0,1)
		instruct_2(174, 5000)
		SetS(10, 0, 17, 0, 1)
		SetD(83, 48, 4, 882)
		say("１这里还有一本秘籍，让我看一下……",0,1)
		local hid = 0
		if JY.Base["标准"] > 0 then
			if JY.Person[0]["性别"] == 0 then
				hid = 280 + JY.Base["标准"]
			else
				hid = 500 + JY.Base["标准"]
			end
		elseif JY.Base["特殊"] > 0 then
			if JY.Person[0]["性别"] == 0 then
				hid = 290
			else
				hid = 510
			end
		else
			hid = JY.Person[0]["半身像"]
		end
		local r = JYMsgBox("请选择", "是否要洗第一格武功？*一：野球拳*二：神山剑法*三：西瓜刀法*四：犽月流空", {"一","二","三","四","放弃"}, 5, hid)
		if r == 1 then
			instruct_35(0, 0, 109, 999)
			DrawStrBoxWaitKey("你学会了『Ｇ野球拳Ｏ』", C_ORANGE, CC.DefaultFont, 2)
		elseif r == 2 then
			instruct_35(0, 0, 110, 999)
			DrawStrBoxWaitKey("你学会了『Ｇ神山剑法Ｏ』", C_ORANGE, CC.DefaultFont, 2)
			instruct_2(55, 1)
		elseif r == 3 then
			instruct_35(0, 0, 111, 999)
			DrawStrBoxWaitKey("你学会了『Ｇ西瓜刀法Ｏ』", C_ORANGE, CC.DefaultFont, 2)
			instruct_2(56, 1)
		elseif r == 4 then
			instruct_35(0, 0, 112, 999)
			DrawStrBoxWaitKey("你学会了『Ｇ犽月流空Ｏ』", C_ORANGE, CC.DefaultFont, 2)
			instruct_2(57, 1)
		end
		instruct_3(70, 3, 1, 0, 0, 0, 0, 2612, 2612, 2612, 0, -2, -2)
	end
    ]]
end

--胡斐 苗人凤教苗家剑法
function NEvent3(keypress)
	if JY.SubScene == 24 and JY.Base["人X1"] == 18 and JY.Base["人Y1"] == 23 and JY.Base["人方向"] == 2 and (keypress == VK_SPACE or keypress == VK_RETURN) and GetS(10, 0, 3, 0) ~= 1 and instruct_16(1) and instruct_18(145) then
		say("１苗大侠，我已经找到雪山飞狐这本书了。", 1, 0)
		say("１嗯，很好！看来你的胡家刀法也已练得炉火纯青了，以后的江湖就看你们这些年轻人的了！这本苗家剑法你拿去吧！", 3,4)
		say("１多谢苗大侠！", 1, 0)
		instruct_35(1, 1, 44, 0)
		DrawStrBox(-1, -1, "胡斐学会苗家剑法", C_ORANGE, CC.DefaultFont)
		ShowScreen()
		lib.Delay(800)
		Cls()
		instruct_2(117, 1)
		SetS(10, 0, 3, 0, 1)
	end
end

--令狐冲变身
function NEvent4(keypress)
	if JY.SubScene == 7 and JY.Base["人X1"] == 34 and JY.Base["人Y1"] == 11 and JY.Base["人方向"] == 2 then
		--令狐冲在队，有九剑秘籍
		if instruct_16(35) and instruct_18(114) and GetS(10, 1, 1, 0) ~= 1 and (keypress == VK_SPACE or keypress == VK_RETURN) then
			SetS(7, 34, 12, 3, 102)
			instruct_3(7, 102, 1, 0, 0, 0, 0, 7148, 7148, 7148, 0, 34, 12)
			say("１雕兄－－，真想见识一下独孤前辈的风采啊！最近总感觉到对九剑有了新的领悟，但又很模糊，不能具体总结出来！", 35, 1)
			say("１哈哈－－－－，是时候了！", 140, 0)
			say("１风太师叔！！！", 35,1)
			instruct_14()
			SetS(7, 33, 12, 3, 101)
			instruct_3(7, 101, 1, 0, 0, 0, 0, 5896, 5896, 5896, 0, 33, 12)
			instruct_13()
			PlayMIDI(24)
			lib.Delay(500)
			say("１冲儿，跟我一起唱：沧海一声笑　滔滔两岸潮　浮沉随浪只记今朝　苍天笑　纷纷世上潮　谁负谁胜出天知晓　江山笑　烟雨遥　涛浪淘尽红尘俗事知多少　清风笑竟惹寂寥　豪情还剩一襟晚照　苍生笑　不再寂寥　豪情仍在痴痴笑笑", 140, 0)
			say("１冲儿，九剑的极意就隐藏在这首歌中，自已好好去体会吧！老夫心愿已了，从此再无牵挂，就此去也，哈哈－－－－", 140, 0)
			say("１多谢太师叔传剑，你老人家多保重！嗯，就在这里参悟九剑的奥义吧－－－－", 35, 1)
			instruct_14()
			instruct_3(7, 101, 0, 0, 0, 0, 0, -1, -1, -1, 0, 33, 12)
			instruct_13()
			DrawStrBox(-1, -1, "三日后", C_ORANGE, CC.DefaultFont)
			ShowScreen()
			lib.Delay(500)
			say("１成了！这才是真正的独孤九剑啊！此生有幸能学到独孤前辈之神技，夫复何憾！", 35, 1)
			DrawStrBox(-1, -1, "令狐冲领悟九剑之秘传", C_ORANGE, CC.DefaultFont)
			ShowScreen()
			lib.Delay(500)
			Cls()
			awakening(35, 1)	--令狐冲第二次觉醒
			DrawStrBox(-1, -1, "令狐冲称号变改", C_ORANGE, CC.DefaultFont)
			ShowScreen()
			lib.Delay(500)
			Cls()
			SetS(10, 1, 1, 0, 1)
			instruct_3(7, 102, 0, 0, 0, 0, 0, -1, -1, -1, 0, 34, 12)
		end
	end
end

--山洞事件
function NEvent6(keypress)
	if JY.SubScene == 10 then
		SetD(10, 28, 4, -1)
		SetS(10, 23, 22, 1, 2)
		SetS(10, 22, 22, 1, 2)
	end
	if JY.SubScene == 59 then
		JY.SubSceneX = 0
		JY.SubSceneY = 0
	end
end

--武道大会后，SYP自动放书
function NEvent10(keypress)
  if JY.SubScene == 25 and GetS(10, 0, 9, 0) ~= 1 then
    SetS(25, 9, 44, 3, 103)
    instruct_3(25, 103, 1, 0, 0, 0, 0, 4133*2, 4133*2, 4133*2, 0, -2, -2)
    if JY.Base["人X1"] == 10 and JY.Base["人Y1"] == 44 and JY.Base["人方向"] == 2 and (keypress == VK_SPACE or keypress == VK_RETURN) and GetD(25, 82, 5) == 4662 then
      say("１一路来到这里，真是辛苦了！我来帮你放书吧。",596,0);
      instruct_14()
      for i = 79, 92 do
          instruct_3(25, i, 1, 0, 0, 0, 0, 4664, 4664, 4664, 0, -2, -2)
      end
      for ii = CC.BookStart, CC.BookStart + CC.BookNum -1 do
          instruct_32(ii, -10)
      end
	  JY.Base["天书数量"] = 15
      instruct_3(25, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2, -2)
      instruct_3(25, 76, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2, -2)
      instruct_13()
      say("１书已经放好了，从上面的门出去吧。", 596,0);
      SetS(10, 0, 9, 0, 1)
      instruct_3(25, 103, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2, -2)
      
    end
  end
end

--大功坊 和袁承志对话后，金蛇剑归还
function NEvent12(keypress)
	if JY.SubScene == 95 and GetD(95, 4, 5) ~= 0 and JY.Thing[40]["使用人"] ~= -1 then
		JY.Person[JY.Thing[40]["使用人"]]["武器"] = -1
		JY.Thing[40]["使用人"] = -1
	end
end

--山洞女主角的剧情
function mm4R()
	local r = JYMsgBox("请选择", "内力性质呢？", {"阴内","阳内","调和"}, 3, JY.Person[92]["半身像"])
	if r == 1 then
		JY.Person[92]["内力性质"] = 0
		Cls()  --清屏
	elseif r == 2 then
		JY.Person[92]["内力性质"] = 1
		Cls()  --清屏
	elseif r == 3 then
		JY.Person[92]["内力性质"] = 2
		Cls()  --清屏
	end
	if JY.Person[0]["资质"] == 50 then
		JY.Person[92]["资质"] = 50
	else
		JY.Person[92]["资质"] = 101 - JY.Person[0]["资质"]
	end
end

--自定义事件
function NEvent(keypress)
	NEvent2(keypress)		--十四本天书之后得到5000两，洗四神技
	NEvent3(keypress)		--胡斐 苗人凤教苗家剑法
	NEvent4(keypress)		--令狐冲变身
	NEvent6(keypress)		--蜘蛛洞 金龙帮
	NEvent10(keypress)	--武道大会放书
	NEvent12(keypress)	--归还金蛇剑
end