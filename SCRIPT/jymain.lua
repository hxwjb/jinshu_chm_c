function IncludeFile()
	package.path=CONFIG.ScriptLuaPath;  --���ü���·��
	require("jyconst")					--���������ļ���ʹ��require�����ظ�����
	require("jywar")
	require("jyacvmts")
	require("kdef")
	require("ItemInfo")
end

function SetGlobal()  	 --������Ϸ�ڲ�ʹ�õ�ȫ�̱���
	JY={};

	JY.Status=GAME_INIT; --��Ϸ��ǰ״̬
	--����R������
	JY.Base={};          --��������
	JY.PersonNum=0;      --�������
	JY.Person={};        --��������
	JY.ThingNum=0        --��Ʒ����
	JY.Thing={};         --��Ʒ����
	JY.SceneNum=0        --��������
	JY.Scene={};         --��������
	JY.WugongNum=0       --��Ʒ����
	JY.Wugong={};        --��Ʒ����
	JY.ShopNum=0 		 --�̵�����
	JY.Shop={};    		 --�̵�����
   
	JY.MyCurrentPic = 0		--���ǵ�ǰ��·��ͼ����ͼ�ļ���ƫ��
	JY.MyPic = 0     		--���ǵ�ǰ��ͼ
	JY.Mytick = 0			--����û����·�ĳ���֡��
	JY.MyTick2 = 0			--��ʾ�¼������Ľ���
	JY.LOADTIME = 0
	JY.SAVETIME = 0
	JY.GTIME = 0			--��Ϸʱ��
	JY.GOLD = 0				--��Ϸ����

	JY.SubScene=-1;         --��ǰ�ӳ������
	JY.SubSceneX=0;         --�ӳ�����ʾλ��ƫ�ƣ������ƶ�ָ��ʹ��
	JY.SubSceneY=0;
	JY.ThingUse = -1;
	JY.Darkness=0;          --=0 ��Ļ������ʾ��=1 ����ʾ����Ļȫ��

	JY.CurrentD=-1;         --��ǰ����D*�ı��
	JY.OldDPass=-1;         --�ϴδ���·���¼���D*���, �����δ���
	JY.CurrentEventType=-1  --��ǰ�����¼��ķ�ʽ 1 �ո� 2 ��Ʒ 3 ·��

	JY.CurrentThing=-1;     --��ǰѡ����Ʒ�������¼�ʹ��

	JY.MmapMusic=-1;        --�л����ͼ���֣���������ͼʱ��������ã��򲥷Ŵ�����

	JY.CurrentMIDI=-1;      --��ǰ���ŵ�����id�������ڹر�����ʱ��������id��
	JY.EnableMusic=1;       --�Ƿ񲥷����� 1 ���ţ�0 ������
	JY.EnableSound=1;       --�Ƿ񲥷���Ч 1 ���ţ�0 ������

	WAR={};					--ս��ʹ�õ�ȫ�̱��� ����ռ��λ�ã���Ϊ������治������ȫ�ֱ����ˡ�����������WarSetGlobal������

	AutoMoveTab = {[0] = 0}
	
	JY.Restart = 0			--������Ϸ��ʼ����
	JY.WalkCount = 0		--��·�Ʋ�
	
	IsViewingKungfuScrolls = 0
	
	Achievements = {}
	Achievements.pChar = {}
	
	YC={}
	YC.ZJH = 0				--���������żһ�
end

function JY_Main()        --���������
	os.remove("debug.txt");      	  --�����ǰ��debug���
    xpcall(JY_Main_sub,myErrFun);     --������ô���
end

function myErrFun(err)      --��������ӡ������Ϣ
    lib.Debug(err);                 --���������Ϣ
    lib.Debug(debug.traceback());   --������ö�ջ��Ϣ
end

function JY_Main_sub()		--��������Ϸ���������
	Ct = {};
    IncludeFile();			--��������ģ��
    SetGlobalConst();		--����ȫ�̱���CC, ����ʹ�õĳ���
    SetGlobal();			--����ȫ�̱���JY

    --��ֹ����ȫ�̱���
    setmetatable(_G,{ __newindex =function (_,n)
                       error("attempt read write to undeclared variable " .. n,2);
                       end,
                       __index =function (_,n)
                       error("attempt read read to undeclared variable " .. n,2);
                       end,
                     }  );
					
	
    lib.Debug("JY_Main start.");

	math.randomseed(os.time());			--��ʼ�������������

    JY.Status=GAME_START;				--�ı���Ϸ״̬

    lib.PicInit(CC.PaletteFile);		--����ԭ����256ɫ��ɫ��
	
	lib.FillColor(0,0,0,0,0);

	--lib.PicLoadFile(CC.WMAPPicFile[1], CC.WMAPPicFile[2], 0)
	--lib.LoadPNGPath(CC.HeadPath, 1, CC.HeadNum, limitX(CC.ScreenW/936*100,0,100))	--���ö�ȡPNGͼƬ��·��
	--lib.PicLoadFile(CC.ThingPicFile[1], CC.ThingPicFile[2], 2, 100, 100)			--��Ʒ��ͼ���ڴ�����2
	--lib.PicLoadFile(CC.EFTFile[1], CC.EFTFile[2], 3)								--��Ч��ͼ���ڴ�����3
	--lib.LoadPNGPath(CC.BodyPath, 90, CC.BodyNum, limitX(CC.ScreenW/936*100,0,100))	--������
	--lib.LoadPNGPath(CC.XTPath, 91, CC.XTNum, limitX(CC.ScreenW/936*100,0,100))	--UI	
	--lib.PicLoadFile(CC.BJ[1], CC.BJ[2], 92) 
	--lib.LoadPNGPath('./data/mmap',93,-1,100)
	--lib.LoadPNGPath('./data/smap',94,-1,100)
	--lib.LoadPNGPath(CC.PTPath, 95, CC.PTNum, limitX(CC.ScreenW/936*100,0,100))
	--lib.LoadPNGPath(CC.UIPath, 96, CC.UINum, limitX(CC.ScreenW/936*100,0,100))	

	--97���ƶ䣬����ʹ��
	--lib.LoadPNGPath(CC.IconPath, 98, CC.IconNum, limitX(CC.ScreenW/936*100,0,100))	--״̬ͼ�꣬�ڴ�����98
	--lib.LoadPNGPath(CC.HeadPath, 99, CC.HeadNum, 26.923076923)						--����Сͷ�����ڼ��������ڴ�����99
	
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
	local choice = 1  ѡ��1
	local buttons ={
	{961,964,351,340,613,387}, --{ͼ1��ţ�ͼ1�ײ���,X�ᣬͼ1Y�ᣬ��������
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
		--�汾��
		DrawString(CC.ScreenW-115-810,CC.ScreenH-30-670,CC.Version,C_WHITE,CC.Fontsmall)
		ShowScreen()
		lib.Delay(CC.Frame)

	end
	return choice
end

function StartMenu()
	Cls()
	local menuReturn = TitleSelection()
    if menuReturn == 1 then        --���¿�ʼ��Ϸ
    Cls()

		NewGame();   		       --��������Ϸ����
		
		if JY.Restart == 1 then
			do return end
		end
		
		--���������ʼ����
		if JY.Base["����"] == 58 then
			JY.SubScene = 18
			JY.Base["��X"] = 144
			JY.Base["��Y"] = 218
			JY.Base["��X1"] = 30
			JY.Base["��Y1"] = 32
		else
			JY.SubScene = CC.NewGameSceneID
			JY.Base["��X1"] = CC.NewGameSceneX
			JY.Base["��Y1"] = CC.NewGameSceneY
		end
		--�޾Ʋ�������Ů�����ж�
		if JY.Person[0]["�Ա�"] == 0 then
			JY.MyPic = CC.NewPersonPicM
		else
			JY.MyPic = CC.NewPersonPicF
		end
		JY.Status = GAME_SMAP
		JY.MmapMusic = -1
		CleanMemory()
		Init_SMap(0)
        lib.ShowSlow(20,0)
        
		--if DrawStrBoxYesNo(-1, -1, "�Ƿ�ۿ����¾��飿", C_GOLD, CC.DefaultFont, LimeGreen) == true then 
			--oldCallEvent(CC.NewGameEvent)
		--end
		
		--�����¼�
		if JY.Base["����"] == 58 then		--�������
			CallCEvent(4187)
		else								--������
			CallCEvent(691)
		end
		
		--���뿪�ֻ�������װ��
		if JY.Base["����"] > 0 then
			if JY.Person[0]["����"] ~= - 1 and JY.Base["����"]~= 27 then
				instruct_2(JY.Person[0]["����"], 1)
				JY.Person[0]["����"] = - 1
			end
			if JY.Person[0]["����"] ~= - 1 then
				instruct_2(JY.Person[0]["����"], 1)
				JY.Person[0]["����"] = - 1
			end
			if JY.Person[0]["����"] ~= - 1 then
				instruct_2(JY.Person[0]["����"], 1)
				JY.Person[0]["����"] = - 1
			end			
		end
		--�������������һ����
		if JY.Base["����"] == 158 then
			instruct_2(174, 10000)
		end
		--��׼���1����
		if JY.Base["��׼"] > 0 then
			instruct_2(174, 10000)
		end			
		--������1����
		if JY.Base["����"] > 0 then
			instruct_2(174, 10000)
		end	
        if JY.Base["����"] == 721 then
            instruct_2(174, 20000)
        end
		--������Ѱ�����С��ɵ�
		if JY.Base["����"] == 498 then
			instruct_2(309, 1)
		end
		--������Ѱ�����С��ɵ�
		if JY.Base["����"] == 498 then
			instruct_2(29, 99)
		end			
         --�������������붴��Ǯѧϰ���ٲ�
		if JY.Base["��׼"] > 0 then
			addevent(41, 0, 1, 4144, 1, 8694)
		end

		--�żһԵ�ר��װ��
		if JY.Base["����"] == 651 then
			for i = 301, 304 do
				instruct_2(i, 1)
			end
		end
		--��Ŀ����

        os.remove(CONFIG.DataPath..'TgJl')
        for i = 1, #CC.commodity do
            if CC.commodity[i][5] > 0 then 
                instruct_2(CC.commodity[i][1],CC.commodity[i][5])
                CC.commodity[i][5] = 0
            end
        end
        tgsave(1)
        
        CC.TGJL = {}
	elseif menuReturn == 2 then         --����ɵĽ���

    	DrawStrBox(-1,CC.ScreenH*1/6-20,"��ȡ����",LimeGreen,CC.Fontbig,C_GOLD);
		DrawStrBox(104,CC.ScreenH*1/6+26,string.format("%-6s %-4s %-10s %-4s %-4s %-4s %-10s","�浵��", "����", "����", "�Ѷ�", "����", "����", "λ��"),C_ORANGE,CC.DefaultFont,C_GOLD);
	
    	local r = SaveList();
    	--ESC ���·���ѡ��
    	if r < 1 then
    		local s = StartMenu();
    		return s;
    	end
    	
    	Cls();
		DrawStrBox(-1,CC.StartMenuY,"���Ժ�...",C_GOLD,CC.DefaultFont);
		ShowScreen();
    	local result = LoadRecord(r);
    	if result ~= nil then
    		return StartMenu();
    	end

		if JY.Base["����"] ~= -1 then
			if JY.SubScene < 0 then
				CleanMemory()
				--lib.UnloadMMap()
			end
			--lib.PicInit()
			lib.ShowSlow(20, 1)
			JY.Status = GAME_SMAP
			JY.SubScene = JY.Base["����"]
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

function CleanMemory()            --����lua�ڴ�
    if CONFIG.CleanMemory==1 then
		collectgarbage("collect");
    end
end
function NewGame()     --ѡ������Ϸ���������ǳ�ʼ����
	Cls();
	ShowScreen();
	LoadRecord(0); --  ��������Ϸ����
	rest()
	--PlayMIDI(77);
	CC.Week = 1
	CC.Gold = 0
	CC.Sp = 0
	if existFile(CONFIG.DataPath..'TgJl') then
		tgload()
	end
    
	--ִ�гɾ��ļ�
	if existFile(CC.Acvmts) then
		dofile(CC.Acvmts)
	--һ��Ŀ
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
		--�Ա����ʽ�������ļ�
		SaveTable(Achievements)
	end
    if CC.Week > 100 then 
        CC.Week = 100
    end
	JY.Base["��Ŀ"] = CC.Week--Achievements.Round
	--if Achievements.Round > 30 then
	--   Achievements.Round = 30
	--end
	--if JY.Base["��Ŀ"] > 30 then
		--JY.Base["��Ŀ"] = 30
	--end
	JY.Status = GAME_NEWNAME
	lib.PlayMPEG(CONFIG.DataPath .. "/avi/1.mp4",VK_ESCAPE) --��Ƶ�ļ�
    Cls()
	
	--ѡ��������ǳ���
	lib.LoadPicture(CC.BG01File,-1,-1)	
	--local player_type = JYMsgBox("����ѡ��", "ѡ������Ҫ������ģʽ*", {"��׼����","��������"}, 2, 903)
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
	JY.Person[0]["����"]=CC.NewPersonName;
		  
	JY.Person[0]["�������ֵ"] = 50
	JY.Person[0]["�������ֵ"] = 500
	JY.Person[0]["����"] = JY.Person[0]["�������ֵ"]
	JY.Person[0]["����"] = JY.Person[0]["�������ֵ"]
	JY.Person[0]["������"] = 80
	JY.Person[0]["������"] = 80
	JY.Person[0]["�Ṧ"] = 80
	JY.Person[0]["ҽ������"] = 30
	JY.Person[0]["�ö�����"] = 30
	JY.Person[0]["�ⶾ����"] = 30
	JY.Person[0]["��������"] = 0
	JY.Person[0]["ȭ�ƹ���"] = 40
	JY.Person[0]["ָ������"] = 40
	JY.Person[0]["��������"] = 40
	JY.Person[0]["ˣ������"] = 40
	JY.Person[0]["�������"] = 40
	JY.Person[0]["��������"] = 40

	local zm = JY.Base["��Ŀ"]
	local nd = JY.Base["�Ѷ�"] 
	local addkfnum  
	if nd < 4 then 
		addkfnum = 12+math.modf(zm/2)
    else
		addkfnum = 12+math.modf(zm/1)
	end 
	JY.Base["�书����"] = JY.Base["�书����"] + addkfnum
	if JY.Base["�书����"]>15 then 
		JY.Base["�书����"]=15
	end	

	--��׼����+��������
	lib.LoadPicture(CC.BG01File,-1,-1)
	if player_type == 3 then
		if ts == 1 then 
			JY.Base["����"] = 1
			--�������ǵ���ͼ
			JY.Person[0]["����"] = "�޾Ʋ���"
			JY.Person[0]["ͷ�����"] = 355
			JY.Person[0]["������"] = 355
			local T_ani = {
				{0, 0, 0}, 
				{0, 0, 0}, 
				{10, 8, 6}, 
				{0, 0, 0}, 
				{0, 0, 0}}
			for i = 1, 5 do
				JY.Person[0]["���ж���֡��" .. i] = T_ani[i][1]
				JY.Person[0]["���ж����ӳ�" .. i] = T_ani[i][3]
				JY.Person[0]["�书��Ч�ӳ�" .. i] = T_ani[i][2]
			end
		elseif ts == 2 then
            JY.Base["����"] = 2
			JY.Person[0]["����"] = "��о��"
			JY.Person[0]["�Ա�"] = 1
			JY.Person[0]["���"] = "����"
			JY.Person[0]["���2"] = "Ѿͷ"
			JY.Person[0]["ͷ�����"] = 368
			JY.Person[0]["������"] = 580
			local f_ani = {
					{0, 0, 0}, 
					{0, 0, 0}, 
					{17, 15, 13}, 
					{0, 0, 0}, 
					{0, 0, 0}}
			for i = 1, 5 do
				JY.Person[0]["���ж���֡��" .. i] = f_ani[i][1]
				JY.Person[0]["���ж����ӳ�" .. i] = f_ani[i][3]
				JY.Person[0]["�书��Ч�ӳ�" .. i] = f_ani[i][2]
			end
		end
	elseif player_type == 2 then
		local clone_choice = cx
		JY.Base["����"] = cx
		
		JY.Person[0]["����"]=JY.Person[clone_choice]["����"]
		JY.Person[0]["ͷ�����"]=JY.Person[clone_choice]["ͷ�����"]
		JY.Person[0]["������"]=JY.Person[clone_choice]["������"]
		JY.Person[0]["��������"]=JY.Person[clone_choice]["��������"]
       	if JY.Person[0]["��������"] < 5 then
		JY.Person[0]["��������"] = 5
		end
		if JY.Person[0]["��������"] > 12 then
            JY.Person[0]["��������"] = 12
		end
		JY.Person[0]["����"]=JY.Person[clone_choice]["����"]
		JY.Person[0]["����"]=JY.Person[clone_choice]["����"]
		JY.Person[0]["���"]=JY.Person[clone_choice]["���"]
		JY.Person[0]["�Ա�"]=JY.Person[clone_choice]["�Ա�"]

		JY.Person[0]["����"]=-1
		JY.Person[0]["����"]=-1
		JY.Person[0]["����"]=-1
		for i=1,5 do
			JY.Person[0]["���ж���֡��" .. i]=JY.Person[clone_choice]["���ж���֡��" .. i]
			JY.Person[0]["���ж����ӳ�" .. i]=JY.Person[clone_choice]["���ж����ӳ�" .. i]
			JY.Person[0]["�书��Ч�ӳ�" .. i]=JY.Person[clone_choice]["�书��Ч�ӳ�" .. i]
		end
		
		--���빥�������55
		JY.Person[0]["������"]=limitX(JY.Person[clone_choice]["������"]/4,55,75)
		JY.Person[0]["������"]=limitX(JY.Person[clone_choice]["������"]/4,55,75)
		JY.Person[0]["�Ṧ"]=limitX(JY.Person[clone_choice]["�Ṧ"]/4,55,75)
		--ҽ���ö��ⶾ���30
		JY.Person[0]["ҽ������"]=limitX(JY.Person[clone_choice]["ҽ������"],30)
		JY.Person[0]["�ö�����"]=limitX(JY.Person[clone_choice]["�ö�����"],30)
		JY.Person[0]["�ⶾ����"]=limitX(JY.Person[clone_choice]["�ⶾ����"],30)
	    JY.Person[0]["��������"]=limitX(JY.Person[clone_choice]["��������"],30)+zm
		JY.Person[0]["��������"]=JY.Person[clone_choice]["��������"]
		JY.Person[0]["�����ڹ�"]=nil
		JY.Person[0]["�����Ṧ"]=nil	
		JY.Person[0]["���˾���"]= 0
		JY.Person[0]["����ʹ��"]= 0

		if CC.PersonExit[clone_choice] ~= nil  then
		
		JY.Person[0]["ȭ�ƹ���"]=limitX(JY.Person[clone_choice]["ȭ�ƹ���"],30,70)+zm
		JY.Person[0]["ָ������"]=limitX(JY.Person[clone_choice]["ָ������"],30,70)+zm
		JY.Person[0]["��������"]=limitX(JY.Person[clone_choice]["��������"],30,70)+zm		
		JY.Person[0]["ˣ������"]=limitX(JY.Person[clone_choice]["ˣ������"],30,70)+zm	
		JY.Person[0]["�������"]=limitX(JY.Person[clone_choice]["�������"],30,70)+zm	
		else
        
		JY.Person[0]["ȭ�ƹ���"]=limitX(JY.Person[clone_choice]["ȭ�ƹ���"]/3,30,70)+zm
		JY.Person[0]["ָ������"]=limitX(JY.Person[clone_choice]["ָ������"]/3,30,70)+zm
		JY.Person[0]["��������"]=limitX(JY.Person[clone_choice]["��������"]/3,30,70)+zm		
		JY.Person[0]["ˣ������"]=limitX(JY.Person[clone_choice]["ˣ������"]/3,30,70)+zm	
		JY.Person[0]["�������"]=limitX(JY.Person[clone_choice]["�������"]/3,30,70)+zm	
	    end
        
		JY.Person[0]["��ѧ��ʶ"]=JY.Person[clone_choice]["��ѧ��ʶ"]
		JY.Person[0]["��������"]=JY.Person[clone_choice]["��������"]
		JY.Person[0]["���һ���"]=JY.Person[clone_choice]["���һ���"]
		JY.Person[0]["��ӹ"]=JY.Person[clone_choice]["��ӹ"]

			for i=1,JY.Base["�书����"] do
				JY.Person[0]["�书" .. i]=JY.Person[clone_choice]["�书" .. i]
				JY.Person[0]["�书�ȼ�" .. i]=JY.Person[clone_choice]["�书�ȼ�" .. i]
				if i > 2 then
					JY.Person[0]["�书" .. i] = 0
				   JY.Person[0]["�书�ȼ�" .. i] = 0	
				end
			end

		for i=1,4 do
			JY.Person[0]["Я����Ʒ" .. i]=JY.Person[clone_choice]["Я����Ʒ" .. i]
			JY.Person[0]["Я����Ʒ����" .. i]=JY.Person[clone_choice]["Я����Ʒ����" .. i]
		end
		
		for i=1,4 do
			JY.Person[0]["�츳�⹦"..i]=JY.Person[clone_choice]["�츳�⹦"..i]
		end
		
		JY.Person[0]["�츳�ڹ�"]=JY.Person[clone_choice]["�츳�ڹ�"]
		JY.Person[0]["�츳�Ṧ"]=JY.Person[clone_choice]["�츳�Ṧ"]
		--JY.Person[0]["����ֽ�"]=JY.Person[clone_choice]["����ֽ�"]
		JY.Person[0]["���2"]=JY.Person[clone_choice]["���2"]
		JY.Person[0]["��ɫָ��"] = JY.Person[clone_choice]["��ɫָ��"]
			
		
		
		--��������������ѡ���⹦
		if JY.Base["����"] == 129 then
			local wcywg = JYMsgBox("��ѡ��", "��ѡ����ĳ�ʼ�⹦", {"ȫ�潣��","һ��ָ"}, 2, 129)
			if wcywg == 1 then
				JY.Person[0]["�书1"]=39
				JY.Person[0]["�书�ȼ�1"]=999
			elseif wcywg == 2 then
				JY.Person[0]["�书1"]=17
				JY.Person[0]["�书�ȼ�1"]=999
			end
			JY.Person[0]["�书2"]=100
			JY.Person[0]["�书�ȼ�2"]=999
			ClsN()
		end
		
		--������ǧ��ͷ�����
		if JY.Base["����"] == 617 then
			JY.Person[0]["ͷ�����"]=353
			JY.Person[0]["������"]=353
			JY.Person[0]["���ж���֡��3"]=24
			JY.Person[0]["���ж����ӳ�3"]=22
			JY.Person[0]["�书��Ч�ӳ�3"]=22
		end
		--�������ܳ���
		if JY.Base["����"] == 27 then
           --instruct_32(349,-1)
		end		
		--���������ʼ��
		if JY.Base["����"] == 58 then
			JY.Scene[19]["��������"] = 1
			JY.Scene[101]["��������"] = 1
			JY.Scene[36]["��������"] = 1
			JY.Scene[28]["��������"] = 1
			JY.Scene[93]["��������"] = 1
			JY.Scene[105]["��������"] = 1
			null(18, 6)
			null(70, 87)
			addevent(70, 95, 0, 4188, 3, 0)
		end
        --��ʼ����
		if JY.Base["����"] == 592 then
		    JY.Person[0]["�书2"]= 0
			JY.Person[0]["�书�ȼ�2"]= 0
			JY.Person[0]["ˣ������"]=30+zm
			JY.Person[0]["�������"]=30+zm
			JY.Person[0]["ָ������"]=30+zm
			JY.Person[0]["ȭ�ƹ���"]=30+zm
	     end
		--���붷��ɮ��ʼ��
		if JY.Base["����"] == 638 then
			JY.Person[0]["�书1"]=106
			JY.Person[0]["�书�ȼ�1"]=999
			JY.Person[0]["�书2"]=0	
			JY.Person[0]["�书�ȼ�2"]=0		
			JY.Person[0]["��ѧ��ʶ"]=100	   			
		end		
		--�����һ����ʼ��
		if JY.Base["����"] == 633 then
			JY.Person[0]["ˣ������"]=70+zm
			JY.Person[0]["�书1"]=67
			JY.Person[0]["�书�ȼ�1"]=999
			JY.Person[0]["�书2"]=0
			JY.Person[0]["�书�ȼ�2"]=0			
		end	
        if JY.Base["����"] == 721 then
			JY.Person[0]["ˣ������"]=50
			JY.Person[0]["�������"]=50
			JY.Person[0]["ָ������"]=50
			JY.Person[0]["ȭ�ƹ���"]=50
            JY.Person[0]["��������"]=200
        end
   		Hp_Max(0)	
	elseif player_type == 1 then 
	
			if xb == 1 then 
				JY.Person[0]["�Ա�"] = 1
				JY.Person[0]["���"] = "����"
				JY.Person[0]["���2"] = "Ѿͷ"				
				local f_ani = {
				{0, 0, 0}, 
				{9, 9, 7}, 
				{8, 8, 6}, 
				{8, 8, 6}, 
				{9, 7, 7}}
				for i = 1, 5 do
					JY.Person[0]["���ж���֡��" .. i] = f_ani[i][1]
					JY.Person[0]["���ж����ӳ�" .. i] = f_ani[i][3]
					JY.Person[0]["�书��Ч�ӳ�" .. i] = f_ani[i][2]
				end
			end
			
			--�Ǳ���
			SetS(10, 0, 6, 0, 1)
			if zj == 1 then         --ȭ
				SetS(4, 5, 5, 5, 1)
				JY.Person[0]["ȭ�ƹ���"] = 50+zm
				JY.Base["��׼"] = 1
				if xb == 1 then
				JY.Person[0]["ͷ�����"] = 227
				else
				JY.Person[0]["ͷ�����"] = 387
				end
			elseif zj == 2 then     --ָ
				JY.Person[0]["ָ������"] = 50+zm
				JY.Base["��׼"] = 2
				if xb == 1 then
				JY.Person[0]["ͷ�����"] = 227
				else
				JY.Person[0]["ͷ�����"] = 387
				end
			elseif zj == 3 then     --��
				SetS(4, 5, 5, 5, 2)
				JY.Person[0]["��������"] = 50+zm
				JY.Base["��׼"] = 3	
				if xb == 1 then
				JY.Person[0]["ͷ�����"] = 228
				else
				JY.Person[0]["ͷ�����"] = 387
				end
			elseif zj == 4 then     --��
				SetS(4, 5, 5, 5, 3)
				JY.Person[0]["ˣ������"] = 50+zm
				JY.Base["��׼"] = 4
				if xb == 1 then
				JY.Person[0]["ͷ�����"] = 229
				else
				JY.Person[0]["ͷ�����"] = 387
				end
			elseif zj == 5 then		 --�� 
				SetS(4, 5, 5, 5, 4)
				JY.Person[0]["�������"] = 50+zm
				JY.Base["��׼"] = 5
				if xb == 1 then
				JY.Person[0]["ͷ�����"] = 230
				else
				JY.Person[0]["ͷ�����"] = 387
				end
			elseif zj == 6 then		 --���
				JY.Person[0]["�������ֵ"] = 500
				JY.Person[0]["����"] = 500
				SetS(4, 5, 5, 5, 5)
				JY.Base["��׼"] = 6
				if xb == 1 then
				JY.Person[0]["ͷ�����"] = 227
				else
				JY.Person[0]["ͷ�����"] = 387
				end
			elseif zj == 7 then		 --����
				JY.Person[0]["Ʒ��"] = 100
				JY.Person[0]["ȭ�ƹ���"] = 40+zm
				JY.Person[0]["ָ������"] = 40+zm
				JY.Person[0]["��������"] = 40+zm
				JY.Person[0]["ˣ������"] = 40+zm
				JY.Person[0]["�������"] = 40+zm
				SetS(4, 5, 5, 5, 6)
				JY.Base["��׼"] = 7
				if xb == 1 then
				JY.Person[0]["ͷ�����"] = 227
				else
				JY.Person[0]["ͷ�����"] = 387
				end				
			elseif zj == 8 then		 --ҽ��
				JY.Person[0]["ȭ�ƹ���"] = 40+zm
				JY.Person[0]["ָ������"] = 40+zm
				JY.Person[0]["��������"] = 40+zm
				JY.Person[0]["ˣ������"] = 40+zm
				JY.Person[0]["�������"] = 40+zm
				JY.Person[0]["ҽ������"] = 200
				JY.Person[0]["�ö�����"] = 200
				JY.Person[0]["�ⶾ����"] = 200
				SetS(4, 5, 5, 5, 7)
				JY.Base["��׼"] = 8
				if xb == 1 then
				JY.Person[0]["ͷ�����"] = 227
				else
				JY.Person[0]["ͷ�����"] = 387
				end				
			elseif zj == 9 then		 --����
				JY.Base["��׼"] = 9
				JY.Person[0]["ȭ�ƹ���"] = 40+zm
				JY.Person[0]["ָ������"] = 40+zm
				JY.Person[0]["��������"] = 40+zm
				JY.Person[0]["ˣ������"] = 40+zm
				JY.Person[0]["�������"] = 40+zm
				JY.Person[0]["�ö�����"] = 300
				JY.Person[0]["�ⶾ����"] = 300
				if xb == 1 then
				JY.Person[0]["ͷ�����"] = 227
				else
				JY.Person[0]["ͷ�����"] = 387
				end				
			end            	
	end
    
    GAME_START2()	

	ClsN()
	lib.LoadPicture(CC.BG01File,-1,-1)	
	
    TGTF()

	ClsN()
	ShowScreen()

    if JY.Base["��׼"] == 6 then 
        JY.Person[0]["��������"] = 3
    end
	--���������ʼ��
	for p = 0, JY.PersonNum-1 do
		
		--�з��ĳ�ʼ��
		if CC.PersonExit[p] == nil and p ~= 0 then

			for i = 1, JY.Base["�书����"] do
				if JY.Person[p]["�书" .. i] > 0 then
					if p < 191 then
						--JY.Person[p]["�书�ȼ�" .. i] = 999    --BOSS�书��Ϊ��
					else
						--����10���ļӵ�10��
						if JY.Person[p]["�书�ȼ�" .. i] < 900 then
							JY.Person[p]["�书�ȼ�" .. i] = 900
						end
					end
				else
					break;
				end
			end
		
			--��������200�ļӵ�200
			if JY.Person[p]["�������ֵ"] < 200 then
				JY.Person[p]["�������ֵ"] = 200
				JY.Person[p]["����"] = JY.Person[p]["�������ֵ"]
			end
			
			--��������200�ļӵ�200
			if JY.Person[p]["�������ֵ"] < 200 then
				JY.Person[p]["�������ֵ"] = 200
				JY.Person[p]["����"] = JY.Person[p]["�������ֵ"]
			end
			
			--����Ѫ�������������Ѷ�ϵ�����
			local dif_factor;
			--��1����2
			if JY.Base["�Ѷ�"] < 3 then
				dif_factor = 2;
			--��3��
			elseif JY.Base["�Ѷ�"] == 3 then
				dif_factor = 3;
				--��4
			else
				dif_factor = 4;
			end			
			JY.Person[p]["Ѫ������"] = dif_factor
			
			--ľ׮Ѫ��������
			if p == 591 then
				JY.Person[p]["Ѫ������"] = 1
			end
			
			--����ˮ���������Ϊ1Ѫ
			if p == 600 then
				JY.Person[p]["�������ֵ"] = 1
				JY.Person[p]["����"] = JY.Person[p]["�������ֵ"]
				JY.Person[p]["Ѫ������"] = 1
			end
	        JY.Person[p]["�������ֵ"] = JY.Person[p]["�������ֵ"]*JY.Person[p]["Ѫ������"]
        local nd = JY.Base["�Ѷ�"]
	    local zm = limitX(JY.Base["��Ŀ"],1,100)
	    local xs = 0
	    local wc = 0
 	    local sw = 0
			
			--ÿ��Ŀ����20��ϵ������Χ���䳣
			if nd > 1 and  p ~= 591 then 
				xs = zm*3
				wc = zm*3
				sw = zm*3
			end
			--����Ŀ��ʼ��ÿ��Ŀ����20��ϵ������Χ���䳣
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
					JY.Person[p]["������"] = JY.Person[p]["������"] + tt
				elseif n == 2 then 
					JY.Person[p]["������"] = JY.Person[p]["������"] + tt
				else
					JY.Person[p]["�Ṧ"] = JY.Person[p]["�Ṧ"] + tt
				end
				sz = sz - tt
				
			end
			JY.Person[p]["ȭ�ƹ���"] = JY.Person[p]["ȭ�ƹ���"] + xs
			JY.Person[p]["ָ������"] = JY.Person[p]["ָ������"] + xs
			JY.Person[p]["��������"] = JY.Person[p]["��������"] + xs
			JY.Person[p]["ˣ������"] = JY.Person[p]["ˣ������"] + xs
			JY.Person[p]["�������"] = JY.Person[p]["�������"] + xs
			JY.Person[p]["��ѧ��ʶ"] = JY.Person[p]["��ѧ��ʶ"] + wc
			
			
			AddPersonAttrib(p,'����',math.huge)		
        else 
            JY.Person[p]["����ֽ�"] = 7
		end
        
	end	
	--�޾Ʋ���������һЩ��ʼ���趨
	
	--��ɽ��ɽл����
	instruct_3(80, 17, 1, 0, 4105, 0, 0, 4133*2, 4133*2, 4133*2, 0, -2, -2)
	
	--�Ħ����ͼ
	instruct_3(16, 10, -2,-2,-2,-2,-2,4153*2,4153*2,4153*2,-2,-2,-2)
	
	--��������ͼ
	instruct_3(62,4,0,0,0,0,0,9238,9238,9238,0,0,0); 
	--�»�ɽ�۽��¼�
	addevent(80, 19, 1, 4141, 1, 4335*2)	--��

end

--�޾Ʋ����������ж�����
function JLSD(s1, s2, dw)
	local s = math.random(100)
	local chance_up = 0;
	--�۽���Ӯ�����ά��������+6
	--[[
	if dw == 0 and JY.Person[606]["�۽�����"] == 1 then
		chance_up = 3
	end]]
	--������ڶ����У�����+20
	--if inteam(dw) == false then
	--	chance_up = 10
	--end
    if (JY.Base["��׼"] == 7 and dw == 0 and  WAR.SEYB == 0) or match_ID(dw,189) then
       	chance_up = 10
	end	
	--���������Ч
	if inteam(dw) == true and match_ID(dw,588) then
        chance_up =	10
	end 
	if inteam(dw) == true and Curr_NG(dw,102) then
        chance_up =	10
	end

	--�ж��Ƿ�ɹ�
	if s1 < s and s <= s2 + chance_up then
		return true
	else
		return false
	end
end

--��Ϸ��ѭ��
function Game_Cycle()
    lib.Debug("Start game cycle");

    while JY.Status ~=GAME_END and JY.Status ~=GAME_START do
		if JY.Restart == 1 then
			break
		end
        local t1=lib.GetTime();

	    JY.Mytick=JY.Mytick+1;    --20�������޻����������Ǳ�Ϊվ��״̬
		if JY.Mytick%20==0 then
            JY.MyCurrentPic=0;
		end

        if JY.Mytick%1000==0 then
            JY.MYtick=0;
        end

        if JY.Status==GAME_FIRSTMMAP then  --�״���ʾ�����������µ�����������ͼ��������ʾ��Ȼ��ת��������ʾ
			CleanMemory()
			lib.ShowSlow(20, 1)
			JY.MmapMusic = 57
			JY.Status = GAME_MMAP
			Init_MMap()
			lib.DrawMMap(JY.Base["��X"], JY.Base["��Y"], GetMyPic())
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

function Game_MMap()      --����ͼ
	if JY.Restart == 1 then
		return
	end

    local direct = -1;
    local keypress, ktype, mx, my = lib.GetKey();
	--�ȼ����ϴβ�ͬ�ķ����Ƿ񱻰���
    for i = VK_RIGHT,VK_UP do
        if i ~= CC.PrevKeypress and lib.GetKeyState(i) ~=0 then
			keypress = i
		end
	end 
    --������ϴβ�ͬ�ķ���δ�����£��������ϴ���ͬ�ķ����Ƿ񱻰���
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
		elseif keypress == VK_H then		--��hֱ�ӻؼ�
			My_Enter_SubScene(70, 35, 31, 2);
			return;
		--�޾Ʋ�����ȫ�׿�ݼ� 7-30
		elseif keypress == VK_S then	--�浵
			Menu_SaveRecord()
			if JY.Status ~= GAME_MMAP  then
				return ;
			end
		elseif keypress == VK_L then	--����
			Menu_ReadRecord()
			if JY.Status ~= GAME_MMAP  then
				return ;
			end
		elseif keypress == VK_Z then	--״̬
			Cls()
			Menu_Status()
		elseif keypress == VK_E then	--��Ʒ
			Cls()
			Menu_Thing()
		elseif keypress == VK_F1 then	--��	
			Cls()
			My_ChuangSong_Ex()
			if JY.Status ~= GAME_MMAP then
				return;
			end
		--elseif keypress == VK_F2 then	--˫��				
		--    CallCEvent(690)				
		elseif keypress == VK_F3 then	--������λ
			Cls()
			Menu_TZDY()
		elseif keypress == VK_F4 then	--����
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
		mx = math.modf(mx)+JY.Base["��X"];
		my = math.modf(my)+ JY.Base["��Y"]
				
		--����ƶ�
		if ktype == 2 then
			if lib.GetMMap(mx, my, 3) > 0 then				--����н������ж��Ƿ�ɽ���
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
		
							i=5;		--�˳�ѭ��
							break;
						end
					end
				end
			else
				CC.MMapAdress[0]= nil;
			end
		--������
		elseif ktype == 3 then
			if tmpx >= 0 and tmpx <= CC.ScreenW/936*63 and 
			   tmpy >= CC.ScreenH/701*110 and tmpy <= CC.ScreenH/701*160 then
			   CMenu()
			else   
				if CC.MMapAdress[0] ~= nil then
					mx = CC.MMapAdress[3] - JY.Base["��X"];
					my = CC.MMapAdress[4] - JY.Base["��Y"];
					CC.MMapAdress[0]= nil;
				else
					AutoMoveTab = {[0] = 0}
					mx = mx - JY.Base["��X"]
					my = my - JY.Base["��Y"]
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


    local x,y;              --���շ����Ҫ���������
	local CanMove = function(nd, nnd)
		local nx, ny = JY.Base["��X"] + CC.DirectX[nd + 1], JY.Base["��Y"] + CC.DirectY[nd + 1]
		if nnd ~= nil then
			nx, ny = nx + CC.DirectX[nnd + 1], ny + CC.DirectY[nnd + 1]
		end
		if CC.hx == nil and ((lib.GetMMap(nx, ny, 3) == 0 and lib.GetMMap(nx, ny, 4) == 0) or CanEnterScene(nx, ny) ~= -1) then
			return true
		else
			return false
		end
	end
    if direct ~= -1 then   --�����˹���
        AddMyCurrentPic();         --����������ͼ��ţ�������·Ч��
        x=JY.Base["��X"]+CC.DirectX[direct+1];
        y=JY.Base["��Y"]+CC.DirectY[direct+1];
        JY.Base["�˷���"]=direct;
		if JY.WalkCount == 1 then
			lib.Delay(90)
		end
    else
        x=JY.Base["��X"];
        y=JY.Base["��Y"];

    end

	if direct~=-1 then
		JY.SubScene=CanEnterScene(x,y);   --�ж��Ƿ�����ӳ���
	end

    if lib.GetMMap(x,y,3)==0 and lib.GetMMap(x,y,4)==0 then     --û�н��������Ե���
        JY.Base["��X"]=x;
        JY.Base["��Y"]=y;
    end
    JY.Base["��X"]=limitX(JY.Base["��X"],10,CC.MWidth-10);           --�������겻�ܳ�����Χ
    JY.Base["��Y"]=limitX(JY.Base["��Y"],10,CC.MHeight-10);

    if CC.MMapBoat[lib.GetMMap(JY.Base["��X"],JY.Base["��Y"],0)]==1 then
	    JY.Base["�˴�"]=1;
	else
	    JY.Base["�˴�"]=0;
	end

    lib.DrawMMap(JY.Base["��X"],JY.Base["��Y"],GetMyPic());             --�滭����ͼ

	--��ǰXY������ʾ
    if CC.ShowXY==1 then
		lib.LoadPNG(91,43*2,CC.ScreenW/936*136,CC.ScreenH/702*142,2)
	    DrawString(CC.ScreenW/936*70,CC.ScreenH/702*129,string.format("%s %d %d","",JY.Base["��X"],JY.Base["��Y"]) ,C_GOLD,CC.Fontsmall*0.9);
	end
	
	DrawTimer();		--���·���̬��ʾ
	JYZTB();			--���ϽǼ�����Ϣ
		--JYZTB1();	
		
	--��ʾ���ָ�еĳ�������
	if CC.MMapAdress[0] ~= nil then
		DrawStrBox(CC.MMapAdress[1]+10,CC.MMapAdress[2],JY.Scene[CC.MMapAdress[0]]["����"],C_GOLD,CC.DefaultFont);
	end
		
    ShowScreen();

    if JY.SubScene >= 0 then          --�����ӳ���
        CleanMemory();
		--lib.UnloadMMap();
        --lib.PicInit();
        lib.ShowSlow(20,1)

		JY.Status=GAME_SMAP;
        JY.MmapMusic=-1;

        JY.MyPic=GetMyPic();
        JY.Base["��X1"]=JY.Scene[JY.SubScene]["���X"]
        JY.Base["��Y1"]=JY.Scene[JY.SubScene]["���Y"]

        Init_SMap(1);
		return
    end
end

--������·
function walkto(xx,yy,x,y,flag)
	local x,y
	AutoMoveTab={[0]=0}
	if JY.Status==GAME_SMAP  then
		x=x or JY.Base["��X1"]
		y=y or JY.Base["��Y1"]
	elseif JY.Status==GAME_MMAP then
		x=x or JY.Base["��X"]
		y=y or JY.Base["��Y"]
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
				--�޾Ʋ�����һ�����۵�ϸ���޸ģ��Զ������¼���վλ���ȼ�
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

function GetMyPic()      --�������ǵ�ǰ��ͼ
    local n;
	if JY.Status==GAME_MMAP and JY.Base["�˴�"]==1 then
		if JY.MyCurrentPic >=4 then
			JY.MyCurrentPic=0
		end
	else
		if JY.MyCurrentPic >6 then
			JY.MyCurrentPic=1
		end
	end

	if JY.Base["�˴�"]==0 then
		if JY.Person[0]["�Ա�"] == 0 then
			n=CC.MyStartPicM+JY.Base["�˷���"]*7+JY.MyCurrentPic;
		else
			n=CC.MyStartPicF+JY.Base["�˷���"]*7+JY.MyCurrentPic;
		end
	else
	    n=CC.BoatStartPic+JY.Base["�˷���"]*4+JY.MyCurrentPic;
	end
	return n;
end

--���ӵ�ǰ������·����֡, ����ͼ�ͳ�����ͼ��ʹ��
function AddMyCurrentPic()
    JY.MyCurrentPic=JY.MyCurrentPic+1;
end

--�����Ƿ�ɽ�
--id ��������
--x,y ��ǰ����ͼ����
--���أ�����id��-1��ʾû�г����ɽ�
function CanEnterScene(x,y)         --�����Ƿ�ɽ�
    for id = 0,JY.SceneNum-1 do
		local scene=JY.Scene[id];
		if (x==scene["�⾰���X1"] and y==scene["�⾰���Y1"]) or
		   (x==scene["�⾰���X2"] and y==scene["�⾰���Y2"]) then
			local e=scene["��������"];
			if e==0 then        --�ɽ�
				return id;
			elseif e==1 then    --���ɽ�
				return -1
			end
		end
	end
    return -1;
end

--���˵�
function MMenu()
    local menu={{"����",Menu_Teaminfo,1},
	            {"��Ʒ",Menu_Thing,1},
				{"ҽ��",Menu_Doctor,1},
	            {"�ⶾ",Menu_DecPoison,1},
	            {"���",Menu_PersonExit,1},
	            {"ϵͳ",Menu_System,1}
				};

    ShowMenu(menu,6,0,CC.MainMenuX,CC.MainMenuY,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE)
	local x1 =CC.ScreenH/2
	local y1 =CC.ScreenW/2
	--lib.LoadPicture("./data/body/999.png",x1,y1,CC.ScreenW/677*80)
end

--ϵͳ�Ӳ˵�
function Menu_System()
	local menu = {
	{"��ȡ����", Menu_ReadRecord, 1}, 
	{"�������", Menu_SaveRecord, 1}, 
	{"�ر�����", Menu_SetMusic, 1}, 
	{"�ر���Ч", Menu_SetSound, 1}, 
	{"��Ʒ����", Menu_WPZL, 1}, 
	--{"ϵͳ����", Menu_Help, 1},
	{"ͨ�ؼ�¼", pastReview, 1},
	{"�ҵĴ���", Menu_MYDIY, 1},
	{"�뿪��Ϸ", Menu_Exit2, 1}
	}
	if JY.EnableMusic == 0 then
		menu[3][1] = "������"
	end
	if JY.EnableSound == 0 then
		menu[4][1] = "����Ч"
	end
	local r = ShowMenu(menu, #menu, 0, CC.MainSubMenuX, CC.MainSubMenuY, 0, 0, 1, 1, CC.DefaultFont, C_ORANGE, C_WHITE)
	if r == 0 then
		return 0
	elseif r < 0 then
		return 1
	end
end

function Menu_MYDIY()
	local r = JYMsgBox("�ҵĴ���","ִ���Զ������*ָ����script/DIY.lua�ļ�",{"ȷ��","ȡ��"},2,nil,1);
	--local r = JYMsgBox("�ҵĴ���","��˼򵥵���Ϸѹ���ò�������");
	if r == 1 then
		dofile(CONFIG.ScriptPath.."DIY.lua");
	end
end

function Menu_Help()
	--��ʱȡ��
	--[[
	local title = "ϵͳ����";
	local str ="װ��˵�����鿴����װ����˵����"
						.."*�书˵�����鿴�����书��˵����"
						.."*���鹥�ԣ�����������÷����Լ���Ϸ�����ԡ�"
	local btn = {"װ��˵��","�书˵��","���鹥��"};
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

--���ֿ���
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

--��Ч����
function Menu_SetSound()
	if JY.EnableSound == 0 then
		JY.EnableSound = 1
	else
		JY.EnableSound = 0
	end
	return 1
end

--����˵�
function Menu_Teaminfo()
	local menu = {
		{"״̬�鿴", Menu_Status, 1}, 
		{"��������", Menu_TZDY, 1}}
	
	ShowMenu(menu, 2, 0, CC.MainSubMenuX, CC.MainSubMenuY, 0, 0, 1, 1, CC.DefaultFont, C_ORANGE, C_WHITE)
end

--��Ʒ�˵�
function Menu_Thing()
	local menu = {
	{"ȫ����Ʒ", nil, 1}, 
	{"������Ʒ", nil, 1}, 
	{"�������", nil, 1}, 
	{"�书����", nil, 1}, 
	{"�鵤��ҩ", nil, 1}, 
	{"���˰���", nil, 1}}
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
			local id = JY.Base["��Ʒ" .. i + 1]
			if id >= 0 then
				if r == 1 then
					thing[i] = id
					thingnum[i] = JY.Base["��Ʒ����" .. i + 1]
				else
					if JY.Thing[id]["����"] == r - 2 then
						thing[num] = id
						thingnum[num] = JY.Base["��Ʒ����" .. i + 1]
						num = num + 1
					end
				end
			end 
		end
		--�޾Ʋ�����������ʾ����
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

--��Ʒ����
function Menu_WPZL()
	local function swap(a, b) 
		JY.Base["��Ʒ" .. a], JY.Base["��Ʒ" .. b] = JY.Base["��Ʒ" .. b], JY.Base["��Ʒ" .. a]
		JY.Base["��Ʒ����" .. a], JY.Base["��Ʒ����" .. b] = JY.Base["��Ʒ����" .. b], JY.Base["��Ʒ����" .. a]
	end
	
	local flag = 0;
	for i=1, CC.MyThingNum do
        flag = 0;
        for j=1, CC.MyThingNum-i+1 do
             if JY.Base["��Ʒ"..j] > -1 and JY.Base["��Ʒ" .. j+1] > -1 then				--���������Ʒ��Ч
				local wg1 = JY.Thing[JY.Base["��Ʒ"..j]]["�����书"];
				local wg2 = JY.Thing[JY.Base["��Ʒ"..j+1]]["�����书"];                           
				if wg2 < 0 then								--���������书�ĸ��ݱ������
					if wg1 > 0 or  (wg1 < 0 and JY.Base["��Ʒ"..j] > JY.Base["��Ʒ"..j+1])  then                
						swap(j, j+1);
						flag = 1;
					end   
                elseif wg1 > 0 then							--�������书�ĸ��������������������ͬ���ٸ����书10����������                         
					if JY.Wugong[wg1]["�书����"] > JY.Wugong[wg2]["�书����"] or (JY.Wugong[wg1]["�书����"] == JY.Wugong[wg2]["�书����"] 
					and JY.Wugong[wg1]["������10"] > JY.Wugong[wg2]["������10"]) then
						swap(j, j+1);
						flag = 1;
					end
				end
			end
		end
		if flag == 0 then									--���һ������û���κεĽ������϶������Ѿ��ź����ˣ�ֱ���˳�
			break;
		end
	end
	Cls()
	DrawStrBoxWaitKey("�����������", C_WHITE, CC.DefaultFont)
end

--���̼�����Ʒ�˵�
function MenuDSJ()
	local menu = {
	{"ȫ����Ʒ", nil, 0}, 
	{"������Ʒ", nil, 0}, 
	{"�������", nil, 1}, 
	{"�书����", nil, 1}, 
	{"�鵤��ҩ", nil, 1}, 
	{"���˰���", nil, 1}}
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
			local id = JY.Base["��Ʒ" .. i + 1]
			if id >= 0 then
				if r == 1 then
					thing[i] = id
					thingnum[i] = JY.Base["��Ʒ����" .. i + 1]  
				else
					if JY.Thing[id]["����"] == r - 2 then
						thing[num] = id
						thingnum[num] = JY.Base["��Ʒ����" .. i + 1]
						num = num + 1
					end
				end
			end
		end
		--�޾Ʋ�����������ʾ����
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

--����ǿ����Ʒ�˵�
function MenuTJQH()
	local thing = {}
	local thingnum = {}
	for i = 0, CC.MyThingNum - 1 do
		thing[i] = -1
		thingnum[i] = 0
	end
	local num = 0
	for i = 0, CC.MyThingNum - 1 do
		local id = JY.Base["��Ʒ" .. i + 1]
		if id >= 0 then
			if JY.Thing[id]["����"] == 1 then
				thing[num] = id
				thingnum[num] = JY.Base["��Ʒ����" .. i + 1]
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

--��Ӫ����
function Menu_HYZB()
	if JY.SubScene ~= 25 then
		JY.SubScene = 70
		JY.Base["��X1"] = 8
		JY.Base["��Y1"] = 28
		JY.Base["��X"] = 358
		JY.Base["��Y"] = 235
	end
end

--�޾Ʋ������°�X�˵�
function Menu_Exit()      --�뿪�˵�
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
	{"�뿪��Ϸ", nil, 1}, 
	{"���ر���", nil, 1},
	{"������Ϸ", nil, 2}}
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

--�뿪�˵�
function Menu_Exit2()
    Cls();
    if DrawStrBoxYesNo(-1,-1,"�Ƿ����Ҫ�뿪��Ϸ(Y/N)?",C_WHITE,CC.DefaultFont) == true then
        JY.Status =GAME_END;
		return 1;
    end
end

--�������
function Menu_SaveRecord()
	Cls();
	DrawStrBox(-1,CC.ScreenH*1/6-20,"�������",LimeGreen,CC.Fontbig,C_GOLD);
	DrawStrBox(104,CC.ScreenH*1/6+26,string.format("%-6s %-4s %-10s %-4s %-4s %-4s %-10s","�浵��", "����", "����", "�Ѷ�", "����", "����", "λ��"),C_ORANGE,CC.DefaultFont,C_GOLD);
	local r = SaveList();
    if r>0 then
        DrawStrBox(CC.MainSubMenuX2,CC.MainSubMenuY,"���Ժ�......",C_WHITE,CC.DefaultFont);
        ShowScreen();
        SaveRecord(r);
        Cls();
	end
    return 0;
end

--��ȡ����
function Menu_ReadRecord()
	Cls();
	DrawStrBox(-1,CC.ScreenH*1/6-20,"��ȡ����",LimeGreen,CC.Fontbig,C_GOLD);
	DrawStrBox(104,CC.ScreenH*1/6+26,string.format("%-6s %-4s %-10s %-4s %-4s %-4s %-10s","�浵��", "����", "����", "�Ѷ�", "����", "����", "λ��"),C_ORANGE,CC.DefaultFont,C_GOLD);
	local r = SaveList();
	if r < 1 then
		return 0;
	end
    	
	Cls();
	DrawStrBox(-1,CC.StartMenuY,"���Ժ�...",C_GOLD,CC.DefaultFont);
	ShowScreen();
	local result = LoadRecord(r);
	if result ~= nil then
		return 0;
	end
	--�ӳ���
	if JY.Base["����"] ~= -1 then
		if JY.SubScene < 0 then
			CleanMemory()
			--lib.UnloadMMap()
		end
		--lib.PicInit()
		lib.ShowSlow(20, 1)
		JY.Status = GAME_SMAP
		JY.SubScene = JY.Base["����"]
		JY.MmapMusic = -1
		JY.MyPic = GetMyPic()
		Init_SMap(1)
	--���ͼ
	else
		JY.SubScene = -1
		JY.Status = GAME_FIRSTMMAP
	end
    return 1;
end

--״̬�Ӳ˵�
function Menu_Status()
	--�޾Ʋ�������״̬�¶�ӦX��
	local xcor = CC.MainSubMenuX +2*CC.MenuBorderPixel+4*CC.DefaultFont+5
	if JY.Status == GAME_WMAP then
		xcor = CC.MainSubMenuX + 15
	end
    DrawStrBox(xcor,CC.MainSubMenuY,"Ҫ����˭��״̬",LimeGreen,CC.DefaultFont,C_GOLD);
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

--��Ӳ˵�
function Menu_PersonExit()
	DrawStrBox(CC.MainSubMenuX, CC.MainSubMenuY, "Ҫ��˭���", C_WHITE, CC.DefaultFont)
	local nexty = CC.MainSubMenuY + CC.SingleLineHeight
	local r = SelectTeamMenu(CC.MainSubMenuX, nexty)
	if r == 1 then
		DrawStrBoxWaitKey("��Ǹ��û������Ϸ���в���ȥ", C_GOLD, CC.DefaultFont, nil, LimeGreen)
	else
		if JY.SubScene == 82 then
			do return end
		end
	end
	if r > 0 and JY.SubScene == 55 and JY.Base["����" .. r] == 35 then
		do return end
	end
	if r > 1 then
		local personid = JY.Base["����" .. r]
		if CC.PersonExit[personid] ~= nil then 
			local v = CC.PersonExit[personid]
			CallCEvent(v)
		end
	end
	Cls()
	return 0
end

--״̬�Ӳ˵�
function Menu_Status()
	--�޾Ʋ�������״̬�¶�ӦX��
	local xcor = CC.MainSubMenuX +2*CC.MenuBorderPixel+4*CC.DefaultFont+5
	if JY.Status == GAME_WMAP then
		xcor = CC.MainSubMenuX + 15
	end
    DrawStrBox(xcor,CC.MainSubMenuY,"Ҫ����˭��״̬",LimeGreen,CC.DefaultFont,C_GOLD);
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

--����ѡ������˵�
function SelectTeamMenu(x,y)
	local menu={};
	for i=1,CC.TeamNum do
        menu[i]={"",nil,0};
		local id=JY.Base["����" .. i]
		if id>=0 then
            if JY.Person[id]["����"]>0 then
                menu[i][1]=JY.Person[id]["����"];
                menu[i][3]=1;
            end
		end
	end
    return ShowMenu(menu,CC.TeamNum,0,x,y,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);
end

--���㵱ǰ���Ѹ���
function GetTeamNum()
    local r=CC.TeamNum;
	for i=1,CC.TeamNum do
	    if JY.Base["����" .. i]<0 then
		    r=i-1;
		    break;
		end
    end
	return r;
end

---��ʾ����״̬
-- ���Ҽ���ҳ�����¼�������
function ShowPersonStatus(teamid)
	local page = 1
	local pagenum = 3
	if JY.Status == GAME_WMAP then
	    if WAR.Person[teamid]["�ҷ�"] == false then
	        pagenum = 2
	    end
	end
	--lib.LoadPNGPath(string.format('./data/fight/fight%03d',JY.Person[teamid]["ͷ�����"]), 89, -1, 100)   --ս����ͼ
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
		local id = -1--JY.Base["����" .. teamid]
		
		if JY.Status == GAME_WMAP then 
			id = WAR.Person[teamid]["������"]
		else 
			id = JY.Base["����" .. teamid]
		end
		local sp = JY.Person[id]
		
		--�츳ID
		local tfid;
		--����
		if id == 0 then
			--����
			if JY.Base["��׼"] > 0 then
				tfid = 546 + JY.Base["��׼"]
			--����
			elseif JY.Base["����"] > 0 then
				tfid = ''
			--����
			else
				tfid = JY.Base["����"]
				--����Ԭ��־
				if tfid == 54 and JY.Person[id]["���˾���"] >= 1 then
					tfid = "54-1"
				--����ʯ����
				elseif tfid == 38 and JY.Person[id]["���˾���"] >= 1 then
					tfid = "38-1"
				--�������
				elseif tfid == 626 and JY.Person[id]["���˾���"] >= 1 then
					tfid = "626-1"				
				end
			end
		--����
		else
			tfid = id
			--Ԭ��־
			if id == 54 and JY.Person[id]["���˾���"] >= 1 then
				tfid = "54-1"
			--ʯ����
			elseif id == 38 and JY.Person[id]["���˾���"] >= 1 then
				tfid = "38-1"
			--����
			elseif id == 626 and JY.Person[id]["���˾���"] >= 1 then
				tfid = "626-1"					
			end
		end
		--�޾Ʋ������ڶ�ҳ�ķ�ҳ�����ж���Ҫ���˶���
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
		--AI����ѡ��Ĭ��ֵ��ȡ
		local AI_s2 = {sp["��Ϊģʽ"],sp["����ʹ��"],sp["�����ڹ�"],sp["�����Ṧ"],sp["�Ƿ��ҩ"],sp["������ֵ"],sp["������ֵ"],sp["������ֵ"],sp["�����Զ�"]}
		local yxsy = {}
		local yxsynum = 0
		yxsy[0] = 0
		for j = 1, JY.Base["�书����"] do
			if sp["�书"..j] == 0 then
				break
			end
			--�⹦������ѡ��ת
			--ʯ�������ѡ̫��
		local wugongid = sp["�书"..j]
		if ((JY.Wugong[sp["�书"..j]]["�书����"] <= 5 ) or (match_ID_awakened(id, 38 ,1) and sp["�书"..j] == 102) or  (JY.Wugong[sp["�书"..j]]["�书����"] == 6 and JY.Base["��׼"] == 6 and id == 0)) and 
           ( wugongid == 85 or wugongid == 87 or wugongid == 88 or wugongid == 144 or wugongid == 175  or wugongid == 182  or wugongid == 199 or wugongid == 43)== false then
				yxsynum = yxsynum + 1
				yxsy[yxsynum] = sp["�书"..j]
			end
		end
		local zyng = {}
		local zyngnum = 0
		zyng[0] = 0
		for j = 1, JY.Base["�书����"] do
			if sp["�书"..j] == 0 then
				break
			end
			--��������������
			if JY.Wugong[sp["�书"..j]]["�书����"] == 6  then
				--�����������
				if (id == 0 and JY.Base["��׼"] == 6)  then
					if sp["�书"..j] == 106 or sp["�书"..j] == 107 or sp["�书"..j] == 108 then
					
					else
						zyngnum = zyngnum + 1
						zyng[zyngnum] = sp["�书"..j]
					end
				else
					zyngnum = zyngnum + 1
					zyng[zyngnum] = sp["�书"..j]
				end
			end
		end
		local zyqg = {}
		local zyqgnum = 0
		zyqg[0] = 0
		for j = 1, JY.Base["�书����"] do
			if sp["�书"..j] == 0 then
				break
			end
			if JY.Wugong[sp["�书"..j]]["�书����"] == 7 then
				zyqgnum = zyqgnum + 1
				zyqg[zyqgnum] = sp["�书"..j]
			end
		end
		--״̬���涯����ʾ��89��
		--lib.PicLoadFile(string.format(CC.FightPicFile[1],JY.Person[id]["ͷ�����"]),
		--string.format(CC.FightPicFile[2],JY.Person[id]["ͷ�����"]), 89)
		
		local m = 0
		local dl = 0
		for j=1,5 do
			if JY.Person[id]['���ж���֡��'..j]>0 then
				if j>1 then
					m=j
					break;
				end
				dl=dl+JY.Person[id]['���ж���֡��'..j]*4
			end
		end
		dl=dl+JY.Person[id]['���ж���֡��'..m]*3
		ShowPersonStatus_sub(id, page, istart, tfid, max_row, nil, AI_s1, AI_s2, AI_menu_selected,AniFrame,dl)
		ShowScreen()
		local keypress, ktype, mx, my = lib.GetKey()
		lib.Delay(CC.Frame)
		--ktype  1�����̣�2������ƶ���3:��������4������Ҽ���5������м���6�������ϣ�7��������
		if keypress == VK_ESCAPE or ktype == 4 then
			if page == 3 and AI_menu_selected > 0 then
				AI_menu_selected = 0
			else
				break;
			end
		--��װ
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
					--ս���в����ڴ��л���������
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
					--ս���в����ڴ��л���������
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
					JY.Person[id]["��Ϊģʽ"] = JY.Person[id]["��Ϊģʽ"] - 1
					if JY.Person[id]["��Ϊģʽ"] < 1 then
						JY.Person[id]["��Ϊģʽ"] = 4
					end
				elseif AI_menu_selected == 2 then
					if WG_num > 0 then
						WG_num = WG_num - 1
						JY.Person[id]["����ʹ��"] = yxsy[WG_num]
					end
				elseif AI_menu_selected == 3 then
					if NG_num > 0 then
						NG_num = NG_num - 1
						JY.Person[id]["�����ڹ�"] = zyng[NG_num]
						Hp_Max(id)
					end
				elseif AI_menu_selected == 4 then
					if QG_num > 0 then
						QG_num = QG_num - 1
						JY.Person[id]["�����Ṧ"] = zyqg[QG_num]
					end
				elseif AI_menu_selected == 5 then
					JY.Person[id]["�Ƿ��ҩ"] = JY.Person[id]["�Ƿ��ҩ"] - 1
					if JY.Person[id]["�Ƿ��ҩ"] < 1 then
						JY.Person[id]["�Ƿ��ҩ"] = 2
					end
				elseif AI_menu_selected == 6 then
					JY.Person[id]["������ֵ"] = JY.Person[id]["������ֵ"] - 1
					if JY.Person[id]["������ֵ"] < 1 then
						JY.Person[id]["������ֵ"] = 3
					end
				elseif AI_menu_selected == 7 then
					JY.Person[id]["������ֵ"] = JY.Person[id]["������ֵ"] - 1
					if JY.Person[id]["������ֵ"] < 1 then
						JY.Person[id]["������ֵ"] = 3
					end
				elseif AI_menu_selected == 8 then
					JY.Person[id]["������ֵ"] = JY.Person[id]["������ֵ"] - 1
					if JY.Person[id]["������ֵ"] < 1 then
						JY.Person[id]["������ֵ"] = 3
					end
				elseif AI_menu_selected == 9 then
					JY.Person[id]["�����Զ�"] = JY.Person[id]["�����Զ�"] - 1
					if JY.Person[id]["�����Զ�"] < 1 then
						JY.Person[id]["�����Զ�"] = 2
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
					JY.Person[id]["��Ϊģʽ"] = JY.Person[id]["��Ϊģʽ"] + 1
					if JY.Person[id]["��Ϊģʽ"] > 4 then
						JY.Person[id]["��Ϊģʽ"] = 1
					end
				elseif AI_menu_selected == 2 then
					if WG_num < yxsynum then
						WG_num = WG_num + 1
						JY.Person[id]["����ʹ��"] = yxsy[WG_num]
					end
				elseif AI_menu_selected == 3 then
					if NG_num < zyngnum then
						NG_num = NG_num + 1
						JY.Person[id]["�����ڹ�"] = zyng[NG_num]
						Hp_Max(id)
					end
				elseif AI_menu_selected == 4 then
					if QG_num < zyqgnum then
						QG_num = QG_num + 1
						JY.Person[id]["�����Ṧ"] = zyqg[QG_num]
					end
				elseif AI_menu_selected == 5 then
					JY.Person[id]["�Ƿ��ҩ"] = JY.Person[id]["�Ƿ��ҩ"] + 1
					if JY.Person[id]["�Ƿ��ҩ"] > 2 then
						JY.Person[id]["�Ƿ��ҩ"] = 1
					end	
				elseif AI_menu_selected == 6 then
					JY.Person[id]["������ֵ"] = JY.Person[id]["������ֵ"] + 1
					if JY.Person[id]["������ֵ"] > 3 then
						JY.Person[id]["������ֵ"] = 1
					end	
				elseif AI_menu_selected == 7 then
					JY.Person[id]["������ֵ"] = JY.Person[id]["������ֵ"] + 1
					if JY.Person[id]["������ֵ"] > 3 then
						JY.Person[id]["������ֵ"] = 1
					end	
				elseif AI_menu_selected == 8 then
					JY.Person[id]["������ֵ"] = JY.Person[id]["������ֵ"] + 1
					if JY.Person[id]["������ֵ"] > 3 then
						JY.Person[id]["������ֵ"] = 1
					end	
				elseif AI_menu_selected == 9 then
					JY.Person[id]["�����Զ�"] = JY.Person[id]["�����Զ�"] + 1
					if JY.Person[id]["�����Զ�"] > 2 then
						JY.Person[id]["�����Զ�"] = 1
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
		if AniFrame == JY.Person[id]['���ж���֡��'..m] then
			AniFrame = 0
		end
		if JY.Status ~= GAME_WMAP then
			teamid = limitX(teamid, 1, teamnum)
		end
		page = limitX(page, 1, pagenum)
	end
end

--�޾Ʋ����������������
--case��nil=���������else�ӵ�
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
  		--����ͼ
		lib.LoadPNG(91, 20 * 2 ,0 , 0, 1)
	--�޾Ʋ�����������ʾ
	local function DrawAttrib(str, x,y,color1,size)

		--DrawString(x1, y1 + h * i, string.sub(4), color1, size)
		--����ϵ����ʾ
		--local str;
		if str == "ȭ�ƹ���" then
			local bonus = 0
			--��˿����
			if JY.Person[id]["����"] == 239 then
				bonus = 10
				if JY.Thing[239]["װ���ȼ�"] >= 5 then
					bonus = 30
				elseif JY.Thing[239]["װ���ȼ�"] >= 4 then
					bonus = 25
				elseif JY.Thing[239]["װ���ȼ�"] >= 3 then
					bonus = 20
				elseif JY.Thing[239]["װ���ȼ�"] >= 2 then
					bonus = 15
				end
			end
		--����з�������Խ�࣬ϵ��Խ��    
		if match_ID(id, 508) and JY.Status == GAME_WMAP then
			local jf = 0
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == false  then
				 jf = jf + 1
			   end				
	       end
         bonus = bonus + jf*5	
	   end			
			--̫����ս��ϵ��*140%
			local ts = 0
			if PersonKF(id, 102) and JY.Status == GAME_WMAP then
				ts = math.modf((JY.Person[id][str]+bonus)*0.4)
			end
			if bonus > 0 or ts > 0 then
				DrawString(x,y,  string.format("+ %s",bonus+ts), color1, size)
			end
		end
		
		if str == "ָ������" then
			local bonus = 0
			--��˿����
			if JY.Person[id]["����"] == 239 then
				bonus = 10
				if JY.Thing[239]["װ���ȼ�"] >= 5 then
					bonus = 30
				elseif JY.Thing[239]["װ���ȼ�"] >= 4 then
					bonus = 25
				elseif JY.Thing[239]["װ���ȼ�"] >= 3 then
					bonus = 20
				elseif JY.Thing[239]["װ���ȼ�"] >= 2 then
					bonus = 15
				end
			end
		--����з�������Խ�࣬ϵ��Խ��    
		if match_ID(id, 508) and JY.Status == GAME_WMAP then
			local jf = 0
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == false  then
				 jf = jf + 1
			   end				
	       end	
		bonus = bonus + jf*5
	   end			
			--̫����ս��ϵ��*140%
			local ts = 0
			if PersonKF(id, 102) and JY.Status == GAME_WMAP then
				ts = math.modf((JY.Person[id][str]+bonus)*0.4)
			end
			if bonus > 0 or ts > 0 then
				DrawString(x, y, string.format("+ %s",bonus+ts), color1, size)
			end
		end
		
		if str == "��������" then
			local bonus = 0
			--��������
			if WuyueJF(id) then
				bonus=bonus+50
			end

			--ս���еĽ������ļӳ�
			if JY.Status == GAME_WMAP then
				if WAR.JDYJ[id] then
					bonus = bonus + WAR.JDYJ[id]
				end
			end
			--�����ƽ��� ϵ��
            if match_ID(id, 584) and JY.Status == GAME_WMAP  then
		       local JF = 0
		       for i = 1, JY.Base["�书����"] do
			   if JY.Wugong[JY.Person[id]["�书" .. i]]["�书����"] == 3 then
				 JF = JF + 1
			   end
				 bonus = math.modf(JF*10)
			   end
	       end
		--����з�������Խ�࣬ϵ��Խ��    
		if match_ID(id, 508) and JY.Status == GAME_WMAP then
			local jf = 0
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == false  then
				 jf = jf + 1
			   end				
	       end	
		bonus = bonus + jf*5
	   end			
			--̫����ս��ϵ��*140%
			local ts = 0
			if PersonKF(id, 102) and JY.Status == GAME_WMAP then
				ts = math.modf((JY.Person[id][str]+bonus)*0.4)
			end
			if bonus > 0 or ts > 0 then
				DrawString(x, y, string.format("+ %s",bonus+ts), color1, size)
			end
		end
		
		if str == "ˣ������" then
			--̫����ս��ϵ��*140%
			local ts = 0
			local bonus = 0
			if PersonKF(id, 102) and JY.Status == GAME_WMAP then
				ts = math.modf((JY.Person[id][str])*0.4)
			end
		--����з�������Խ�࣬ϵ��Խ��    
		if match_ID(id, 508) and JY.Status == GAME_WMAP then
			local df = 0
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == false  then
				df = df +1
			   end         
	       end
        bonus = bonus + df * 5			
	   end				
			if bonus > 0 or ts > 0 then
				DrawString(x, y, string.format("+ %s",ts+bonus), color1, size)
			end
		end
		
	   if str == "�������" then
			--̫����ս��ϵ��*140%
			local ts = 0
			local bonus = 0
			if PersonKF(id, 102) and JY.Status == GAME_WMAP then
				ts = math.modf((JY.Person[id]["�������"])*0.4)
			end
		--����з�������Խ�࣬ϵ��Խ��    
		if match_ID(id, 508) and JY.Status == GAME_WMAP  then
			local df = 0
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == false  then
				df = df +1
			   end         		
	       end	
		 bonus = bonus + df * 5
	   end
			if bonus > 0 or ts > 0 then
				DrawString(x,y, string.format("+ %s",ts+bonus), color1, size)
			end
		end
	
		--ս�����¼ӳ�
		if JY.Status == GAME_WMAP then
			if str == "ҽ������" then
				for k,v in pairs(CC.AddDoc) do
					if match_ID(id, v[1]) then
						for wid = 0, WAR.PersonNum - 1 do
							if match_ID(WAR.Person[wid]["������"], v[2]) and WAR.Person[wid]["����"] == false then
								DrawString(x,y, "+ "..v[3], color1, size)
								--break
							end
						end
					end
				end
			end
			if str == "�ö�����" then
				for k,v in pairs(CC.AddPoi) do
					if match_ID(id, v[1]) then
						for wid = 0, WAR.PersonNum - 1 do
							if match_ID(WAR.Person[wid]["������"], v[2]) and WAR.Person[wid]["����"] == false then
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
		hid = p["������"]  		
		--������
		local bodyw,  bodyh = lib.GetPNGXY(97, hid*2)		
	     lib.LoadPNG(90, hid * 2, dx*247, dy*209,2)  
-------------------------------
	i = 5

	local ch = nil
	local chcl = C_CYGOLD
    local fj = {[0] = {"��˵",C_ORANGE},{"��ʦ",M_DarkRed},{"����",C_RED},{"һ��",M_Pink},{"����",M_Pink},{"����",M_Blue},{"����",M_LightBlue},{"����",C_CYGOLD}}

        local fjstr = "��"..fj[p["����ֽ�"]][1].."��"
        local nametre = p["����"]
        local djstr = p["�ȼ�"].."��"
        
        local namex = CC.ScreenW/2-string.len(fjstr..nametre..djstr)/4*size
        local fjx = namex + string.len(nametre)/2*size
        local djx = fjx + string.len(fjstr)/2*size
		DrawString(fjx, dx*24, fjstr, fj[JY.Person[id]["����ֽ�"]][2], size*0.8)
		DrawString(namex, dx*20, nametre, C_CYGOLD, size)		
		DrawString(djx, dx*24, djstr, C_CYGOLD, size*0.8)
		--DrawString(dx*621, dx*24, "��", C_CYGOLD, size*0.8)		
		i = i + 1	
	
	    local tfx1 = dx*110
		local fty1 = dy*79
		--�����츳
		if id == 0 then
			local main_tf;
			--����
			if JY.Base["��׼"] > 0 then
				main_tf = ZJTF[JY.Base["��׼"]]
			--����
			elseif JY.Base["����"] > 0 then
				main_tf = " "
			--����
			elseif JY.Base["����"] > 0 then
				if RWTFLB[p["����"]] ~= nil then
					main_tf = RWTFLB[p["����"]]
				end
			end
			if main_tf ~= nil then
				DrawString(tfx1 -string.len(main_tf)/4*size*0.8, fty1, main_tf, C_CYGOLD, size*0.8)
			end
		end

		--��ͨ��ɫ�츳
		if id ~= 0 and RWTFLB[id] ~= nil then
			--DrawString(x1-7, y1 + h * (i)-142,RWTFLB[id], C_CYGOLD, size*0.8)
		    DrawString(tfx1 -string.len(RWTFLB[id])/4*size*0.8, fty1, RWTFLB[id], C_CYGOLD, size*0.8)	
		end
	  
		
		--���ǳƺ�
		if id == 0 then
			local main_ch;
			--����
			if JY.Base["��׼"] > 0 then
				if p["�������"] == 0 then
					main_ch = "����СϺ��"
				else
					main_ch = "����֮����"
				end
			--����
			elseif JY.Base["����"] > 0 then
				main_ch = ''--TSTF[JY.Base["����"]]
			--����
			elseif JY.Base["����"] > 0 then
				if RWWH[JY.Base["����"]] ~= nil and JY.Base["����"] ~= 35 and JY.Base["����"] ~= 38 and JY.Base["����"] ~= 49 
				and JY.Base["����"] ~= 626 then
					main_ch = RWWH[JY.Base["����"]]
				elseif JY.Base["����"] == 35 then
					if JY.Person[id]["���˾���"] >= 2 then
						DrawString(tfx1 -string.len(RWWH["35"])/4*size*0.8, dy*122,  RWWH["35"], C_CYGOLD, size*0.8)	
					elseif JY.Person[id]["���˾���"] >= 1 then
						--DrawString(x1-7, y1 + h * (i)-100, RWWH[35], C_CYGOLD, size*0.8)
						 DrawString(tfx1 -string.len(RWWH["35"])/4*size*0.8, dy*122,  RWWH["35"], C_CYGOLD, size*0.8)		
					end
				elseif JY.Base["����"] == 38 then
					if JY.Person[id]["���˾���"] >= 1 then
						--DrawString(x1-7, y1 + h * (i)-100, RWWH["38"], C_CYGOLD, size*0.8)
					    DrawString(tfx1 -string.len(RWWH["38"])/4*size*0.8, dy*122,  RWWH["38"], C_CYGOLD, size*0.8)		
					end
				elseif JY.Base["����"] == 49 then
					if JY.Person[id]["���˾���"] >= 1 then
						--DrawString(x1-7, y1 + h * (i)-100, RWWH["49"], C_CYGOLD, size*0.8)
					   DrawString(tfx1 -string.len(RWWH["49"])/4*size*0.8, dy*122,  RWWH["49"], C_CYGOLD, size*0.8)	
					else
					--	DrawString(x1-7, y1 + h * (i)-100, RWWH[49], C_CYGOLD, size*0.8)
					   DrawString(tfx1 -string.len(RWWH[49])/4*size*0.8, dy*122,  RWWH[49], C_CYGOLD, size*0.8)	
					end
				elseif JY.Base["����"] == 626 then
					if JY.Person[id]["���˾���"] >= 1 then
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
		
		--�����˳ƺ�
		if RWWH[id] ~= nil and id ~= 35 and id ~= 38 and id ~= 49 then
			--DrawString(x1-7, y1 + h * (i)-100, RWWH[id], C_CYGOLD, size*0.8)
		    DrawString(tfx1 -string.len( RWWH[id])/4*size*0.8, dy*122,  RWWH[id], C_CYGOLD, size*0.8)	
			
		end

		--�����
		if id == 35 then
			if JY.Person[id]["���˾���"] >= 2 then
				--DrawString(x1-7, y1 + h * (i)-100, RWWH["35"], C_CYGOLD, size*0.8)
				DrawString(tfx1 -string.len(RWWH["35"])/4*size*0.8, dy*122,  RWWH["35"], C_CYGOLD, size*0.8)
			elseif JY.Person[id]["���˾���"] >= 1 then
			--	DrawString(x1-7, y1 + h * (i)-100, RWWH[35], C_CYGOLD, size*0.8)
				 DrawString(tfx1 -string.len(RWWH["35"])/4*size*0.8, dy*122,  RWWH["35"], C_CYGOLD, size*0.8)
			end
		end

		--����
		if id == 49 then
			if JY.Person[id]["���˾���"] >= 1 then
				--DrawString(x1-7, y1 + h * (i)-100, RWWH["49"], C_CYGOLD, size*0.8)
				  DrawString(tfx1 -string.len(RWWH["49"])/4*size*0.8, dy*122,  RWWH["49"], C_CYGOLD, size*0.8)	
			else
				--DrawString(x1-7, y1 + h * (i)-100, RWWH[49], C_CYGOLD, size*0.8)
				  DrawString(tfx1 -string.len(RWWH[49])/4*size*0.8, dy*122,  RWWH[49], C_CYGOLD, size*0.8)	
			end
		end
	  
		--ʯ����
		if id == 38 then
			if JY.Person[id]["���˾���"] >= 1 then
				--DrawString(x1-7, y1 + h * (i)-100, RWWH["38"], C_CYGOLD, size*0.8)
				  DrawString(tfx1 -string.len(RWWH["38"])/4*size*0.8, dy*122,  RWWH["38"], C_CYGOLD, size*0.8)	
			end
		end
		
		--����
		if id == 626 then
			if JY.Person[id]["���˾���"] >= 1 then
			--	DrawString(x1-7, y1 + h * (i)-100, RWWH["626"], C_CYGOLD, size*0.8)
				  DrawString(tfx1 -string.len(RWWH["626"])/4*size*0.8, dy*122,  RWWH["626"], C_CYGOLD, size*0.8)	
			end
		end
		--�����
		if id == 189 then
			if JY.Person[id]["���˾���"] >= 1 then
			--	DrawString(x1-7, y1 + h * (i)-100, RWWH["189"], C_CYGOLD, size*0.8)
				  DrawString(tfx1 -string.len(RWWH[189])/4*size*0.8, dy*122,  RWWH[189], C_CYGOLD, size*0.8)	
			end
		end	 
		--���˷�
		if id == 633 then
			if JY.Person[id]["���˾���"] >= 1 then
				--DrawString(x1-7, y1 + h * (i)-100, RWWH["633"], C_CYGOLD, size*0.8)
				DrawString(tfx1 -string.len(RWWH[633])/4*size*0.8, dy*122,  RWWH[633], C_CYGOLD, size*0.8)	
			end
		end			

		--����
		DrawString(dx*70, dy*155, "����", C_CYGOLD, size*0.8)
		DrawString(dx*125, dy*155, p["����"], C_CYGOLD, size*0.8)
		--����
		DrawString(dx*70, dy*180, "����", C_CYGOLD, size*0.8)
		DrawString(dx*125, dy*180, p["��������"], C_CYGOLD, size*0.8)
        local ii = 0
        local diyx,diyy = CC.ThingPicWidth/2,CC.ThingPicHeight/2
        local ax,ay = x1, y1 + h * i + diyy * ii
        local s = 2
        ax = x1 - size
        ay = y1 + h * i + diyy * ii

		--����������
		i = i + 1
		if p["����"] > -1 then
			lib.PicLoadCache(2, p["����"] * 2, diyx/5+ax*8+30, diyy/4+ax*3-80, 1)
			DrawString( diyx/5+ax*8+32, diyy/4+ax*3-80, JY.Thing[p["����"]]["����"], C_CYGOLD, size*0.8)
			DrawString( diyx/5+ax*8+32, diyy/4+ax*3-80+size*0.7, "LV"..JY.Thing[p["����"]]["װ���ȼ�"], M_DeepSkyBlue, size*0.7)
		end
		i = i + 1
		if p["����"] > -1 then
			lib.PicLoadCache(2, p["����"] * 2, diyx/5+ax*8+30, diyy/4+ax*3+83-63, 1)
			DrawString( diyx/5+ax*8+32, diyy/4+ax*3+20, JY.Thing[p["����"]]["����"], C_CYGOLD, size*0.8)
			DrawString( diyx/5+ax*8+32, diyy/4+ax*3+20+size*0.7, "LV"..JY.Thing[p["����"]]["װ���ȼ�"], M_DeepSkyBlue, size*0.7)
		end		
		if p["����"] > -1 then
		 lib.PicLoadCache(2, p["����"] * 2, diyx/5+ax*8+30, diyy/4+ax*3+166-45, 1)
		DrawString( diyx/5+ax*8+32, diyy/4+ax*3+121, JY.Thing[p["����"]]["����"], C_CYGOLD, size*0.8)
		DrawString( diyx/5+ax*8+32, diyy/4+ax*3+121+size*0.7, "LV"..JY.Thing[p["����"]]["װ���ȼ�"], M_DeepSkyBlue, size*0.7)
		end		

		--�ڶ��п�ʼD
	---------------------------------------------------------------------		
		i = 0
	    local color = nil
		if p["���˳̶�"] < 33 then
			color = RGB(236, 200, 40)
		elseif p["���˳̶�"] < 66 then
			color = RGB(244, 128, 32)
		else
			color = RGB(232, 32, 44)
		end
		i = i + 1
		DrawString(dx*152, dy*412, string.format("%5d", p["����"]), C_CYGOLD, size*0.7)
		DrawString(dx*202, dy*414, "/", C_CYGOLD, size*0.6)
		if p["�ж��̶�"] == 0 then
			color = RGB(252, 148, 16)
		elseif p["�ж��̶�"] < 50 then
			color = RGB(120, 208, 88)
		else
			color = RGB(56, 136, 36)
		end
		DrawString(dx*202, dy*412, string.format("%5s", p["�������ֵ"]), C_CYGOLD, size*0.7)
		local nl = nil
		if p["��������"] == 0 then
			color = RGB(208, 152, 208)
			nl = "(��)"
		elseif p["��������"] == 1 then
			color = RGB(236, 200, 40)
			nl = "(��)"
        elseif	p["��������"] == 2 then
			color =MilkWhite
			nl = "(����)"
		else
			color = RGB(252, 172, 92)
			nl = "(���)"
		end
		DrawString(dx*152, dy*436, string.format("%5d", p["����"]), color, size*0.7)
		DrawString(dx*202, dy*440, "/", color, size*0.6)
		DrawString(dx*202, dy*436, string.format("%5d", p["�������ֵ"]), color, size*0.7)
		DrawString(dx*262, dy*436, nl, color, size*0.7)	
		if p["�����ڹ�"] == 0 then
			DrawString(dx*398, dy*409, "δ���ڹ�",C_CYGOLD, size*0.7)
		else
			DrawString(dx*398, dy*409, JY.Wugong[p["�����ڹ�"]]["����"], TG_Red_Bright, size*0.7)
		 
			lib.LoadPNG(91, 15 * 2 ,0 ,0, 1)
        end		
		if p["�����Ṧ"] == 0 then
			DrawString(dx*398, dy*437, "δ���Ṧ",C_CYGOLD, size*0.7)
		else
			DrawString(dx*398, dy*437, JY.Wugong[p["�����Ṧ"]]["����"], M_DeepSkyBlue, size*0.7)
			lib.LoadPNG(91, 14 * 2 ,0 ,0, 1)
		end			
--------------------------------------------
		--��һ��
        i = 0
		local x1 = dx*113
		local y1 = dy*471
        local dh = size*0.8
		local w1 = size

		--װ�����ӵ�����
		local str_gain, def_gain, agi_gain = 0, 0, 0
		if p["����"] > -1 then
			if JY.Thing[p["����"]]["�ӹ�����"] > 0 then
				str_gain = str_gain + JY.Thing[p["����"]]["�ӹ�����"]*10 + JY.Thing[p["����"]]["�ӹ�����"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			elseif JY.Thing[p["����"]]["�ӹ�����"] < 0 then
				str_gain = str_gain + JY.Thing[p["����"]]["�ӹ�����"]*10 - JY.Thing[p["����"]]["�ӹ�����"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			end
			if JY.Thing[p["����"]]["�ӷ�����"] > 0 then
				def_gain = def_gain + JY.Thing[p["����"]]["�ӷ�����"]*10 + JY.Thing[p["����"]]["�ӷ�����"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			elseif JY.Thing[p["����"]]["�ӷ�����"] < 0 then
				def_gain = def_gain + JY.Thing[p["����"]]["�ӷ�����"]*10 - JY.Thing[p["����"]]["�ӷ�����"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			end
			if JY.Thing[p["����"]]["���Ṧ"] > 0 then
				agi_gain = agi_gain + JY.Thing[p["����"]]["���Ṧ"]*10 + JY.Thing[p["����"]]["���Ṧ"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			elseif JY.Thing[p["����"]]["���Ṧ"] < 0 then
				agi_gain = agi_gain + JY.Thing[p["����"]]["���Ṧ"]*10 - JY.Thing[p["����"]]["���Ṧ"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			end
		end
		if p["����"] > -1 then
			if JY.Thing[p["����"]]["�ӹ�����"] > 0 then
				str_gain = str_gain + JY.Thing[p["����"]]["�ӹ�����"]*10 + JY.Thing[p["����"]]["�ӹ�����"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			elseif JY.Thing[p["����"]]["�ӹ�����"] < 0 then
				str_gain = str_gain + JY.Thing[p["����"]]["�ӹ�����"]*10 - JY.Thing[p["����"]]["�ӹ�����"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			end
			if JY.Thing[p["����"]]["�ӷ�����"] > 0 then
				def_gain = def_gain + JY.Thing[p["����"]]["�ӷ�����"]*10 + JY.Thing[p["����"]]["�ӷ�����"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			elseif JY.Thing[p["����"]]["�ӷ�����"] < 0 then
				def_gain = def_gain + JY.Thing[p["����"]]["�ӷ�����"]*10 - JY.Thing[p["����"]]["�ӷ�����"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			end
			if JY.Thing[p["����"]]["���Ṧ"] > 0 then
				agi_gain = agi_gain + JY.Thing[p["����"]]["���Ṧ"]*10 + JY.Thing[p["����"]]["���Ṧ"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			elseif JY.Thing[p["����"]]["���Ṧ"] < 0 then
				agi_gain = agi_gain + JY.Thing[p["����"]]["���Ṧ"]*10 - JY.Thing[p["����"]]["���Ṧ"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			end
		end
		if p["����"] > -1 then
			if JY.Thing[p["����"]]["�ӹ�����"] > 0 then
				str_gain = str_gain + JY.Thing[p["����"]]["�ӹ�����"]*10 + JY.Thing[p["����"]]["�ӹ�����"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			elseif JY.Thing[p["����"]]["�ӹ�����"] < 0 then
				str_gain = str_gain + JY.Thing[p["����"]]["�ӹ�����"]*10 - JY.Thing[p["����"]]["�ӹ�����"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			end
			if JY.Thing[p["����"]]["�ӷ�����"] > 0 then
				def_gain = def_gain + JY.Thing[p["����"]]["�ӷ�����"]*10 + JY.Thing[p["����"]]["�ӷ�����"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			elseif JY.Thing[p["����"]]["�ӷ�����"] < 0 then
				def_gain = def_gain + JY.Thing[p["����"]]["�ӷ�����"]*10 - JY.Thing[p["����"]]["�ӷ�����"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			end
			if JY.Thing[p["����"]]["���Ṧ"] > 0 then
				agi_gain = agi_gain + JY.Thing[p["����"]]["���Ṧ"]*10 + JY.Thing[p["����"]]["���Ṧ"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			elseif JY.Thing[p["����"]]["���Ṧ"] < 0 then
				agi_gain = agi_gain + JY.Thing[p["����"]]["���Ṧ"]*10 - JY.Thing[p["����"]]["���Ṧ"]*(JY.Thing[p["����"]]["װ���ȼ�"]-1)*2
			end
		end
		--�׽�ӳ�
		local level = 0
		local gj = 0
		local qg = 0
		local fy = 0	
		for i =1,JY.Base["�书����"] do               -- ���ҵ�ǰ�Ѿ������书�ȼ�
			 if JY.Person[id]["�书" .. i]==108 then
                level=math.modf(JY.Person[id]["�书�ȼ�" .. i] /100)+1;	
		        if level >= 1 then
		        gj = math.modf (JY.Person[id]["������"]*0.03*(level-1))
		        str_gain = str_gain +gj
		        fy = math.modf(JY.Person[id]["������"]*0.03*(level-1))
		        def_gain = def_gain +fy
		        qg = math.modf(JY.Person[id]["�Ṧ"]*0.03*(level-1))
		       agi_gain = agi_gain +qg
		        break
		       end	
            end		
        end
	--��ң��
	if Curr_QG(id,2) then
		 agi_gain =  agi_gain + 20
    end
	--���㹦
	if Curr_QG(id,223) then
		 agi_gain =  agi_gain + math.modf(JY.Person[id]["�Ṧ"]*0.2)
    end	
	--�����귭
	if Curr_QG(id,224) then
		 agi_gain =  agi_gain + math.modf(JY.Person[id]["�Ṧ"]*0.2)
    end		
		--ս�����¼ӳ� 
     if JY.Status == GAME_WMAP then
	    --����ͩ���ҷ�������Խ�࣬����Խ��    
		if match_ID(id, 74) then
		 local hqtgj= 0
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[i]["�ҷ�"] then
				 def_gain =  def_gain+10
			end		
	    end	
	end		 
	    --����з�������Խ�࣬����Խ��    
		if match_ID(id, 508) then
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == false  then
				 def_gain =  def_gain+10
				 str_gain =  str_gain +10
			end		
	    end	
	end		 		 
			--���ѹ������ӳ�
			for i,v in pairs(CC.AddAtk) do
				if match_ID(id, v[1]) then
					for wid = 0, WAR.PersonNum - 1 do
						if match_ID(WAR.Person[wid]["������"], v[2]) and WAR.Person[wid]["����"] == false then
							str_gain = str_gain + v[3]
						end
					end
				end
			end
			--���ѷ������ӳ�
			for i,v in pairs(CC.AddDef) do
				if match_ID(id, v[1]) then
					for wid = 0, WAR.PersonNum - 1 do
						if match_ID(WAR.Person[wid]["������"], v[2]) and WAR.Person[wid]["����"] == false then
							def_gain = def_gain + v[3]
						end
					end
				end
			end
			--�����Ṧ�ӳ�
			for i,v in pairs(CC.AddSpd) do
				if match_ID(id, v[1]) then
					for wid = 0, WAR.PersonNum - 1 do
						if match_ID(WAR.Person[wid]["������"], v[2]) and WAR.Person[wid]["����"] == false then
							agi_gain = agi_gain + v[3] 
						end
					end
				end
			end
		end

		DrawString(x1, y1, p["������"], C_CYGOLD, size*0.7)		
		DrawString(x1+w1+size/3, y1, "�� ", C_CYGOLD, size*0.7)
		DrawString(x1+w1*2, y1, str_gain, C_CYGOLD, size*0.7)		

		DrawString(x1, y1+dh, p["������"], C_CYGOLD, size*0.7)		
		DrawString(x1+w1+size/3, y1+dh, "�� " , C_CYGOLD, size*0.7)
		DrawString(x1+w1*2, y1+dh, def_gain, C_CYGOLD, size*0.7)	
		
         DrawString(x1, y1+dh*2, p["�Ṧ"], C_CYGOLD, size*0.7)		
		if agi_gain > -1 then
			DrawString(x1+w1+size/3,y1+dh*2, "�� ", C_CYGOLD, size*0.7)
			DrawString(x1+w1*2,y1+dh*2, agi_gain, C_CYGOLD, size*0.7)			
		else
			agi_gain = -(agi_gain)
			DrawString(x1+w1+size/3,y1+dh*2, "�� " , C_CYGOLD, size*0.7)
			DrawString(x1+w1*2,y1+dh*2, agi_gain, C_CYGOLD, size*0.7)			
		end

		--��������
		DrawString(dx*113, y1+dh*3.5, p["ȭ�ƹ���"], C_CYGOLD, size*0.7)
		DrawAttrib("ȭ�ƹ���", dx*150, y1+dh*3.5,C_CYGOLD,size*0.7)
		DrawString(dx*113, y1+dh*4.5, p["ָ������"], C_CYGOLD, size*0.7)	
		DrawAttrib("ָ������", dx*150, y1+dh*4.5,C_CYGOLD,size*0.7)
		DrawString(dx*113, y1+dh*5.5, p["��������"], C_CYGOLD, size*0.7)	
		DrawAttrib("��������", dx*150, y1+dh*5.5,C_CYGOLD,size*0.7)
		DrawString(dx*113, y1+dh*6.5, p["ˣ������"], C_CYGOLD, size*0.7)	
		DrawAttrib("ˣ������", dx*150, y1+dh*6.5,C_CYGOLD,size*0.7)
		DrawString(dx*113, y1+dh*7.5, p["�������"], C_CYGOLD, size*0.7)	
		DrawAttrib("�������", dx*150, y1+dh*7.5,C_CYGOLD,size*0.7)

    --�ڶ���  
        -- ҽ�� �ö� ���� 
	    local x2 = dx*270
		local y2 = y1
        DrawString(x2, y2,p["ҽ������"], C_CYGOLD, size*0.7)
		DrawAttrib("ҽ������", dx*310, y2,C_CYGOLD,size*0.7)
        DrawString(x2, y2+dh,p["�ö�����"], C_CYGOLD, size*0.7)	
		DrawAttrib("�ö�����", dx*310, y2+dh,C_CYGOLD,size*0.7)
        DrawString(x2, y2+dh*2,p["��������"], C_CYGOLD, size*0.7)		   

	   --���� ���� ҽ�� �ö�    
		DrawString(x2, y2+dh*3.5,Person_LJ(id), C_CYGOLD, size*0.7)
		DrawString(x2, y2+dh*4.5,Person_BJ(id), C_CYGOLD, size*0.7)
		DrawString(x2, y2+dh*5.5,p["��������"], C_CYGOLD, size*0.7)	
		DrawString(x2, y2+dh*6.5,p["��������"], C_CYGOLD, size*0.7)	
		DrawString(x2, y2+dh*7.5,p["�ⶾ����"], C_CYGOLD, size*0.7)	

    --������
	--�䳣 ʵս ����
	    local jqz = 0
	local jqz0 = 8
	local jqz1 = 0
	local jqz3 = 0
	local x = JY.Person[id]["�Ṧ"]
	local jqz2 = 0
    local y = JY.Person[id]["����"]	
	local x3 = dx*427
	local y3 = y1
	DrawString(x3 , y3,p["��ѧ��ʶ"], C_CYGOLD, size*0.7)
     if p["ʵս"] == 500 then
			DrawString(x3, y3+dh, string.format("%s", "��"), C_RED, size*0.7)
		else
			DrawString(x3, y3+dh, string.format("%s", p["ʵս"]), C_CYGOLD, size*0.7)
		end	
	--������
	
	local function getnewmove(x)
		return math.sqrt(x)
	end
	--�޾Ʋ����������������Ｏ����Ӱ�캯��
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

	--ս���Ṧ
	local function Qg1(i)

		id = i
		
		local qg = 0 
		
		qg = qg + JY.Person[id]['�Ṧ']
		
		for i =1,JY.Base["�书����"] do  
			local level = 0            
			if JY.Person[id]["�书" .. i]==108 then
				level = math.modf(JY.Person[id]["�书�ȼ�" .. i]/100)+1;
				level = limitX(level/10,0,1)
				qg = qg + math.modf(JY.Person[id]["�Ṧ"]*0.3*level)	
				break
			end
		end
		
		return qg
	end
	
	jqz = (getnewmove(Qg1(id)) + getnewmove1(JY.Person[id]["����"], JY.Person[id]["�������ֵ"]) + JY.Person[id]["����"] / 30)
	
	jqz = math.modf(jqz)
	
	DrawString(x3 , y3+dh*2,jqz, C_CYGOLD, size*0.7)	
 
	local zyhb = nil
	if p["���һ���"] == 1 then
		zyhb  = "��"
		else
		zyhb  = "��"
		end
	DrawString(x3 , y3+dh*3.5, zyhb, C_CYGOLD, size*0.7)
      local zyzd = nil	
	if id == 0 and ZhongYongZD(id) then
		zyzd  = "��"
		else
		zyzd  = "��"
		end		
	DrawString(x3,y3+dh*4.5, zyzd, C_CYGOLD, size*0.7)
     local mrdz = nil	
	if MuRongDZ(id) == true  then
		mrdz  = "��"
		else
		mrdz  = "��"
		end		
	DrawString(x3,y3+dh*5.5, mrdz, C_CYGOLD, size*0.7)
	
	
	
	DrawString(dx*360 , dy*616, "����", C_CYGOLD, size*0.7)
	local thingid = p["������Ʒ"]
		if thingid > 0 then
			--lib.PicLoadCache(2, p["������Ʒ"] * 2, x1 + size*4, y1*19+96-100, 1)
            DrawString(dx*400,dy*616, JY.Thing[thingid]["����"], M_DeepSkyBlue, size*0.7)			
			i = i + 1
			local n = TrainNeedExp(id)
			if n < math.huge then
				DrawString(dx*360, dy*638, string.format("%5d/%5d", p["��������"], n), C_CYGOLD, size*0.7)
			else
				DrawString(dx*360,  dy*638, string.format("%5d/===", p["��������"]), C_CYGOLD, size*0.7)
			end
		else


	  --����ֵ
	  i = i + 1
		DrawString(x1-130, y1 + 12*h * (i)-40, "����", C_CYGOLD, size*0.8)
		local kk = nil
		if p["�ȼ�"] >= 30 then
			kk = "   ="
		else
			p["�ȼ�"] = limitX(p["�ȼ�"],1,30)
			kk = 2 * (p["����"] - CC.Exp[p["�ȼ�"] - 1])
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
		
		--�ȼ�
	--	DrawString(dx*189, dy*390, kk, C_CYGOLD, size*0.8)
	--	local tmp = nil
	--	if CC.Level <= p["�ȼ�"] then
	--		tmp = "="
	--	else
	--		tmp = 2 * (CC.Exp[p["�ȼ�"]] - CC.Exp[p["�ȼ�"] - 1])
	--	end
	--	DrawString(dx*209, dy*390, "/" .. tmp, C_CYGOLD, size*0.8)
	end
---------------------------------------------------------------
		--�����п�ʼ �书
		x1 = dx*2 - size*2-30
		y1 = size*2+30
		i = 0
		local T = {"һ", "��", "��", "��", "��", "��", "��", "��", "��", "ʮ", "��"}
	    local SortingNum = {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15"} 	
		for j = 1, 15 do
			i = i + 1
			local wugong = p["�书" .. j]
			if wugong > 0 then
				lib.LoadPNG(91, 18 * 2 ,dx*500, dy*90 + h * (i), 1)
				DrawString(dx*505, dy*95 + h * (i), SortingNum[j], C_WHITE, CC.FontSMALL)
				local level = math.modf(p["�书�ȼ�" .. j] / 100) + 1
				if p["�书�ȼ�" .. j] == 999 then
					level = 11
				end
				DrawString(dx*540, dy*93 + h * (i), string.format("%s", JY.Wugong[wugong]["����"]), M_Orange, size*0.9)
				if p["�书�ȼ�" .. j] > 900 then
					--lib.SetClip(x1, y1 + h * 1, x1 + size + string.len(JY.Wugong[wugong]["����"]) * size * (p["�书�ȼ�" .. j] - 900) / 200, y1 + h * (i) + h*0.8)
					DrawString(dx*540, dy*93 + h * (i), string.format("%s", JY.Wugong[wugong]["����"]), M_Orange, size*0.9)
					lib.SetClip(0, 0, 0, 0)
				end
				--�ȼ�
				DrawString(dx*775, dy*93 + h * (i), T[level], C_CYGOLD, size*0.9)
				--����
				local nl = nil
		        nl = math.modf((level + 3) / 2) * JY.Wugong[wugong]["������������"]
				DrawString(dx*695, dy*93 + h * (i), nl, C_CYGOLD, size*0.9)
				--������ؼ�����ʾ�ؼ�
				if secondary_wugong(wugong) then
					DrawString(dx*825, dy*93 + h * (i), "�ؼ�", M_PaleGreen, size*0.9)
				--������ǣ�����ʾ�书����
				else
					--����
					local wugongwl = get_skill_power(id, wugong, level)
					--�����츳���⹦����ɫ
					if Given_WG(id, wugong) or Given_NG(id, wugong) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), PinkRed, size*0.9)
					--�������������ɫ
					elseif wugong >= 30 and wugong <= 34 and WuyueJF(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)
					--�����黭�����ɫ
					elseif (wugong == 73 or wugong == 72 or wugong == 84 or wugong == 142) and QinqiSH(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)
					--�һ����������ɫ
					elseif (wugong == 12 or wugong == 18 or wugong == 38) and TaohuaJJ(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)
					--�������������ɫ
			       elseif (wugong == 3 or wugong == 120 or wugong == 5 or wugong == 21 or wugong == 118) and ZiqiTL(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)
					--�ٻ���ԭ�����ɫ
					elseif (wugong == 61 or wugong == 65 or wugong == 66) and JuHuoLY(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)
					--���к��������ɫ
					elseif (wugong == 58 or wugong == 174 or wugong == 153) and LiRenHF(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)
					--��հ��������ɫ
			        elseif (wugong == 22 or wugong == 189 or wugong == 103) and JinGangBR(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)						
					--����ħ�����ɫ
					elseif (wugong == 96 or wugong == 86 or wugong == 82 or wugong == 83 ) and ShiZunXM(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)
					--˫���ϱڵ������ɫ
					elseif (wugong == 39 or wugong == 42 or wugong == 100 or wugong == 154 or wugong == 139) and ShuangJianHB(id) then
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), LightPurple, size*0.9)							
					else
						DrawString(dx*825, dy*93 + h * (i), string.format("%4d",wugongwl), RGB(208, 152, 208), size*0.9)
					end
				end
			end
		end
		i = 17
		if p["�츳�ڹ�"] ~= 0 then

			DrawString(dx*620, dy*76+ h * 17, JY.Wugong[p["�츳�ڹ�"]]["����"], TG_Red_Bright, size*0.8)
		end
		if p["�츳�Ṧ"] ~= 0 then

			DrawString(dx*786,dy*76+ h * 17, JY.Wugong[p["�츳�Ṧ"]]["����"], M_DeepSkyBlue,  size*0.8)
			i = i + 1
		end
		if p["�츳�⹦1"] ~= 0 then
			DrawString(dx*619, dy*72 + h * 18, JY.Wugong[p["�츳�⹦1"]]["����"], C_GOLD,  size*0.8)
		end
		if p["�츳�⹦2"] ~= 0 then
			--DrawString(x1, y1 + h * (i), "�츳�⹦", LightPurple, size)
			DrawString(dx*778, dy*72 + h * 18, JY.Wugong[p["�츳�⹦2"]]["����"], C_GOLD,  size*0.8)
		end
		
		x1 = dx - size *3 -10
		i = 20
		if case == nil then
			if JY.Status ~= GAME_WMAP then
				DrawString(x1-size*5, y1 + h * (i)+2, "���¼����� ������ʾ�����츳 ESC�˳�", M_PaleTurquoise, size*0.7)
			else
				DrawString(x1-size*5, y1 + h * (i)+2, "���¼����� ������ʾ�����츳 ESC�˳�", Snow3, size*0.7)
			end
		else
			DrawString(x1-size*5, y1 + h * (i)+2, "���¼�ѡ������ ���Ҽ�����/���� �س���ȷ�ϼӵ�", Snow3, size*0.7)
		end
	--������ʾ
		if dl then
			lib.PicLoadCache(101+p["ͷ�����"],(dl+AniFrame)*2,diyx/5+ax*2,diyy/4+ax*5+130) 	
		end
-------------------------------------
--������ʾ ��	
		x1 = dx-450
		y1 = size*2+360
		i = 3
        size = CC.FontSmall4*0.7

-------------------------------------
	--�ڶ�ҳ
	elseif page == 2 then
		local y2 = y1
		lib.LoadPNG(91, 19 * 2 , 0 , 0, 1)
        local tfsm = {}
        if TFJS[tfid] ~= nil then
            for i = 1,#TFJS[tfid] do
                tfsm[#tfsm+1] = TFJS[tfid][i]
                if i == #TFJS[tfid] then 
                    tfsm[#tfsm+1] = "��"
                end
            end
        end
        
        if id == 0 then
            for i = 1, #ZJZSJS do
                tfsm[#tfsm+1] = ZJZSJS[i]
                if i == #ZJZSJS then 
                    tfsm[#tfsm+1] = "��"
                end
            end
        end
        if id == 0 then
            for i,v in pairs(CC.TG) do 
                if v == 1 then
                    tfsm[#tfsm+1] = '��'..CC.PTFSM[i][1]
                    tfsm[#tfsm+1] = '��'..CC.PTFSM[i][2]
                    tfsm[#tfsm+1] = "��"
                end
            end   
        end
		--���·��ļ�ͷ��ʾ
		if istart > 1 then
			DrawString(x1-size*2-5, y1+2*h, "��", C_CYGOLD, size)
		end
		if istart < max_row then
			DrawString(x1-size*2-5, y1+17*h+12, "��", C_CYGOLD, size)
		end
		local function strcolor_switch(s)
			local Color_Switch={{"��",PinkRed},{"��",C_GOLD},{"��",C_BLACK},{"��",C_WHITE},{"��",C_ORANGE},{"��",LimeGreen},{"��",M_DeepSkyBlue},{"��",Violet}}
			for i = 1, 8 do
				if Color_Switch[i][1] == s then
					return Color_Switch[i][2]
				end
			end
		end
		x1 = x1 - size
		DrawString(x1+size*14+20, y1-13, p["����"], C_CYGOLD, size)
		DrawString(x1+size*6, y1+size+2, "���¼���� ��������״̬ҳ�� ��������AI�趨 ESC�˳�", C_CYGOLD, size*0.6)
		local row = 1
        
        y2 = y2 +size*2
        
        if #tfsm > 0 then 
            for i = istart, #tfsm do
				local tfstr = tfsm[i]
				--������ʾ����
				if row < 19 then
					if string.sub(tfstr,1,2) == "��" then
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
		
	--AI�趨ҳ��
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
		DrawString(x1+size*13+7+20, y1-13, p["����"], C_CYGOLD, size)

		y1 = y1 + h * 3
		local AI_s1_name = {"��Ϊģʽ","����ʹ��","�����ڹ�","�����Ṧ","�Ƿ��ҩ","������ֵ","������ֵ","������ֵ","����AI"}
		for j = 1, 9 do
			local color = LimeGreen
			if AI_s1 == j then
				color = C_GOLD
				DrawString(x1-size-2+10, y1 + h * (j-1)*2, "��", color, size*0.9)
			end
			if JY.Status == GAME_WMAP and (j == 3 or j == 4) then
				color = M_DimGray
			end
			DrawString(x1+10, y1 + h * (j-1)*2, AI_s1_name[j], color, size*0.9)
		end
		local AI_1_s2_name = {"�Զ�����","�Զ�����","ԭ����Ϣ","������Ϣ"}
		for j = 1, 4 do
			local color = C_WHITE
			if AI_s2[1] == j then
				color = C_ORANGE
			end
			DrawString(x1+h*5*j, y1 + h * (i), AI_1_s2_name[j], color, size*0.9)
		end
		i = i + 2
		if p["����ʹ��"] == 0 then
			DrawString(x1+h*5, y1 + h * (i), "δ�趨", C_WHITE, size*0.9)
		else
			DrawString(x1+h*5, y1 + h * (i), JY.Wugong[p["����ʹ��"]]["����"], C_ORANGE, size*0.9)
		end
		i = i + 2
		if p["�����ڹ�"] == 0 then
			DrawString(x1+h*5, y1 + h * (i), "δ���ڹ�", wg_color1, size*0.9)	    
		else		
			DrawString(x1+h*5, y1 + h * (i), JY.Wugong[p["�����ڹ�"]]["����"], wg_color2, size*0.9)	

         end		
         i = i + 2
		if p["�����Ṧ"] == 0 then
			DrawString(x1+h*5, y1 + h * (i), "δ���Ṧ", wg_color1, size*0.9)
		else
			DrawString(x1+h*5, y1 + h * (i), JY.Wugong[p["�����Ṧ"]]["����"], wg_color2, size*0.9)
		end
		i = i + 2
		local AI_5_s2_name = {"��","��"}
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
		local AI_9_s2_name = {"��","��"}
		for j = 1, 2 do
			local color = C_WHITE
			if AI_s2[9] == j then
				color = C_ORANGE
			end
			DrawString(x1+h*5*j, y1 + h * (i), AI_9_s2_name[j], color, size*0.9)
		end
		
		if AI_menu_selected == 1 or AI_menu_selected > 4 then
			DrawString(x1+h*5*(AI_s2[AI_menu_selected])-h, y1 + h * (AI_menu_selected-1)*2+2, "��", C_ORANGE, size*0.99)
		end
		
		if AI_menu_selected > 1 and AI_menu_selected < 5 then
			DrawString(x1+h*4, y1 + h * (AI_menu_selected-1)*2+2, "��", C_ORANGE, size*0.99)
			DrawString(x1+h*9+12, y1 + h * (AI_menu_selected-1)*2+2, "��", C_ORANGE, size*0.9)
		end

		x1 = dx - size *5 -15
		y1 = size*2
		i = 19
		if AI_menu_selected > 0 then
			x1 = dx - 15
			DrawString(dx*211,dy*59, "���Ҽ�ѡ�� �س�/ESC��ȷ��", C_CYGOLD, size*0.6)
		else
			DrawString(dx*211,dy*59, "���¼�ѡ�� �س���ȷ�� ���������츳ҳ�� ESC�˳�", C_CYGOLD, size*0.6)
		end
	end
end

--�������������ɹ���Ҫ�ĵ���
--id ����id
function TrainNeedExp(id)         --��������������Ʒ�ɹ���Ҫ�ĵ���
    local thingid=JY.Person[id]["������Ʒ"];
	local r =0;
	if thingid >= 0 then
        if JY.Thing[thingid]["�����书"] >=0 then
            local level=0;          --�˴���level��ʵ��level-1������û���书�r������һ����һ���ġ�
			for i =1,JY.Base["�书����"] do               -- ���ҵ�ǰ�Ѿ������书�ȼ�
			    if JY.Person[id]["�书" .. i]==JY.Thing[thingid]["�����书"] then
                    level=math.modf(JY.Person[id]["�书�ȼ�" .. i] /100);
					break;
                end
            end
			if level <9 then
                r=math.modf((5-math.modf(JY.Person[id]["����"]/25))*JY.Thing[thingid]["�辭��"]*(level+1)*0.5);
			else
                r=math.huge;
			end
		else
            r=(5-math.modf(JY.Person[id]["����"]/25))*JY.Thing[thingid]["�辭��"];
		end
	end
    return r;
end

--ҽ�Ʋ˵�
function Menu_Doctor()       --ҽ�Ʋ˵�
	Cls()
    DrawStrBox(CC.MainSubMenuX,CC.MainSubMenuY,"˭Ҫʹ��ҽ��",C_WHITE,CC.DefaultFont);
	local nexty=CC.MainSubMenuY+CC.SingleLineHeight;
    DrawStrBox(CC.MainSubMenuX,nexty,"ҽ������",C_ORANGE,CC.DefaultFont);

	local menu1={};
	for i=1,CC.TeamNum do
        menu1[i]={"",nil,0};
		local id=JY.Base["����" .. i]
        if id >=0 then
            if JY.Person[id]["ҽ������"]>=20 then
                 menu1[i][1]=string.format("%-10s%4d",JY.Person[id]["����"],JY.Person[id]["ҽ������"]);
                 menu1[i][3]=1;
            end
        end
	end

    local id1,id2;
	nexty=nexty+CC.SingleLineHeight;
    local r=ShowMenu(menu1,CC.TeamNum,0,CC.MainSubMenuX,nexty,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);

    if r >0 then
	    id1=JY.Base["����" .. r];
        Cls(CC.MainSubMenuX,CC.MainSubMenuY,CC.ScreenW,CC.ScreenH);
        DrawStrBox(CC.MainSubMenuX,CC.MainSubMenuY,"Ҫҽ��˭",C_WHITE,CC.DefaultFont);
        nexty=CC.MainSubMenuY+CC.SingleLineHeight;

		local menu2={};
		for i=1,CC.TeamNum do
			menu2[i]={"",nil,0};
			local id=JY.Base["����" .. i]
			if id>=0 then
				 menu2[i][1]=string.format("%-10s%4d/%4d",JY.Person[id]["����"],JY.Person[id]["����"],JY.Person[id]["�������ֵ"]);
				 menu2[i][3]=1;
			end
		end

		local r2=ShowMenu(menu2,CC.TeamNum,0,CC.MainSubMenuX,nexty,0,0,1,1,CC.DefaultFont,C_ORANGE,C_WHITE);

		if r2 >0 then
	        id2=JY.Base["����" .. r2];
            local num=ExecDoctor(id1,id2);
			if num>0 then
                AddPersonAttrib(id1,"����",-2);
			end
            DrawStrBoxWaitKey(string.format("%s �������� %d",JY.Person[id2]["����"],num),C_ORANGE,CC.DefaultFont);
		end
	end

	Cls();
    return 0;
end

--�ⶾ
function Menu_DecPoison()         --�ⶾ
    DrawStrBox(CC.MainSubMenuX,CC.MainSubMenuY,"˭Ҫ���˽ⶾ",C_WHITE,CC.DefaultFont);
	local nexty=CC.MainSubMenuY+CC.SingleLineHeight;
    DrawStrBox(CC.MainSubMenuX,nexty,"�ⶾ����",C_ORANGE,CC.DefaultFont);

	local menu1={};
	for i=1,CC.TeamNum do
        menu1[i]={"",nil,0};
		local id=JY.Base["����" .. i]
        if id>=0 then
            if JY.Person[id]["�ⶾ����"]>=20 then
                 menu1[i][1]=string.format("%-10s%4d",JY.Person[id]["����"],JY.Person[id]["�ⶾ����"]);
                 menu1[i][3]=1;
            end
        end
	end

    local id1,id2;
 	nexty=nexty+CC.SingleLineHeight;
    local r=ShowMenu(menu1,CC.TeamNum,0,CC.MainSubMenuX,nexty,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);

    if r >0 then
	    id1=JY.Base["����" .. r];
         Cls(CC.MainSubMenuX,CC.MainSubMenuY,CC.ScreenW,CC.ScreenH);
        DrawStrBox(CC.MainSubMenuX,CC.MainSubMenuY,"��˭�ⶾ",C_WHITE,CC.DefaultFont);
		nexty=CC.MainSubMenuY+CC.SingleLineHeight;

        DrawStrBox(CC.MainSubMenuX,nexty,"�ж��̶�",C_WHITE,CC.DefaultFont);
	    nexty=nexty+CC.SingleLineHeight;

		local menu2={};
		for i=1,CC.TeamNum do
			menu2[i]={"",nil,0};
			local id=JY.Base["����" .. i]
			if id>=0 then
				 menu2[i][1]=string.format("%-10s%5d",JY.Person[id]["����"],JY.Person[id]["�ж��̶�"]);
				 menu2[i][3]=1;
			end
		end

		local r2=ShowMenu(menu2,CC.TeamNum,0,CC.MainSubMenuX,nexty,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);
		if r2 >0 then
	        id2=JY.Base["����" .. r2];
            local num=ExecDecPoison(id1,id2);
            DrawStrBoxWaitKey(string.format("%s �ж��̶ȼ��� %d",JY.Person[id2]["����"],num),C_ORANGE,CC.DefaultFont);
		end
	end
    Cls();
    ShowScreen();
    return 0;
end

--�ⶾ
--id1 �ⶾid2, ����id2�ж����ٵ���
function ExecDecPoison(id1,id2)     --ִ�нⶾ
    local add=JY.Person[id1]["�ⶾ����"];
    local value=JY.Person[id2]["�ж��̶�"];

    if value > add+20 then
        return 0;
	end

 	add=limitX(math.modf(add/3)+Rnd(10)-Rnd(10),0,value);
    return -AddPersonAttrib(id2,"�ж��̶�",-add);
end


--��ʾ��Ʒ�˵�
function SelectThing(thing,thingnum)    

	local xnum=CC.MenuThingXnum;
	local ynum=CC.MenuThingYnum;

	local w=CC.ThingPicWidth*xnum+(xnum-1)*CC.ThingGapIn+2*CC.ThingGapOut;  --������
	local h=CC.ThingPicHeight*ynum+(ynum-1)*CC.ThingGapIn+2*CC.ThingGapOut; --��Ʒ���߶�

	local dx=(CC.ScreenW-w)/2;
	local dy=(CC.ScreenH-h-2*(CC.ThingFontSize+2*CC.MenuBorderPixel+8))/2-CC.ThingFontSize-11;

	local y1_1,y1_2,y2_1,y2_2,y3_1,y3_2;                  --���ƣ�˵����ͼƬ��Y����

	local cur_line=0;
	local cur_x=0;
	local cur_y=0;
	local cur_thing=-1;
	
	--�޾Ʋ�������¼�������Ʒ
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
				--ѡ����Ʒ��ɫ
				if x==cur_x and y==cur_y then
					boxcolor=S_Yellow;
					if thing[id]>=0 then
						cur_thing=thing[id];
						local str=JY.Thing[thing[id]]["����"];
						--װ���ȼ���ʾ
						if JY.Thing[thing[id]]["װ������"] > -1 then
							str = str .." LV."..JY.Thing[thing[id]]["װ���ȼ�"]
						end
						if JY.Thing[thing[id]]["����"]==1 or JY.Thing[thing[id]]["����"]==2 then
							if JY.Thing[thing[id]]["ʹ����"] >=0 then
								str=str .. "(" .. JY.Person[JY.Thing[thing[id]]["ʹ����"]]["����"] .. ")";
							end
						end
						if thing[id] == 174 then 
							str=string.format("%s X %d",str,CC.Gold);
						else
						    str=string.format("%s X %d",str,thingnum[id]);
						end
						local str2=JY.Thing[thing[id]]["��Ʒ˵��"];
						if thing[id]==182 then
							str2=str2..string.format('(��%3d,%3d)',JY.Base['��X'],JY.Base['��Y'])
						end
						DrawString(dx+CC.ThingGapOut+20,y1_1+CC.MenuBorderPixel+10,str,C_GOLD,CC.ThingFontSize);
						DrawString(dx+CC.ThingGapOut+20,y2_1+CC.MenuBorderPixel+10,str2,C_ORANGE,CC.ThingFontSize*0.9);
						local myfont=CC.FontSmall
						local mx, my = dx + 4 * myfont, y3_2 + 2
						local myflag=0
						local myThing=JY.Thing[thing[id]]
								
						--��Ʒ˵����ʾ
						local function drawitem(ss,str,news)
							local color = C_GOLD
							local mys
							if str==nil then
								mys=ss
							elseif myThing[ss]~=0 then
								if news==nil then
									if myflag==0 then
										--�޾Ʋ�����װ������ֵ��ȼ��仯
										if myThing["װ������"] > -1 then
											local attr_gain = 0;
											if myThing[ss] > 0 then
												attr_gain = myThing[ss]*10 + myThing[ss]*(myThing["װ���ȼ�"]-1)*2
											elseif myThing[ss] < 0 then
												attr_gain = myThing[ss]*10 - myThing[ss]*(myThing["װ���ȼ�"]-1)*2
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
								--������ɫ
								if myThing[ss]==1 and ss=="����������" then
									color = RGB(236, 200, 40)
								elseif myThing[ss]==2 and ss=="����������" then
									color = RGB(236, 236, 236)
								end
							elseif myThing[ss]==0 and ss=="����������" then
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
					  
						--����̩̹��ͬ�����϶�
						if myThing["�����书"] > 0 then
							local kfname = "ϰ��:" .. JY.Wugong[myThing["�����书"]]["����"]
							DrawString(mx+CC.MenuBorderPixel, my+CC.MenuBorderPixel, kfname, C_GOLD, myfont)
							mx = mx + myfont * string.len(kfname) / 2 + 12
						end
								
						if myThing['����'] > 0 then
							drawitem('������','����')
							drawitem('���������ֵ','������ֵ')
							drawitem('���ж��ⶾ','�ж�')
							drawitem('������','����')
							if myThing['�ı���������']==2 then
								drawitem('�������Ա�Ϊ����')
							end
							drawitem('������','����')
							drawitem('���������ֵ','������ֵ')
							drawitem('�ӹ�����','����')
							drawitem('���Ṧ','�Ṧ')
							drawitem('�ӷ�����','����')
							drawitem('��ҽ������','ҽ��')
							drawitem('���ö�����','�ö�')
							drawitem('�ӽⶾ����','�ⶾ')
							drawitem('�ӿ�������','����')
							drawitem('��ȭ�ƹ���','ȭ��')
							drawitem('��ָ������','ָ��')
							drawitem('����������','����')
							drawitem('��ˣ������','ˣ��')
							drawitem('���������','����')
							drawitem('�Ӱ�������','����')
							drawitem('����ѧ��ʶ','�䳣')
							drawitem('��Ʒ��','Ʒ��')
							drawitem('�ӹ�������','����',{[0]='��','��'})
							drawitem('�ӹ�������','����')
							if myThing['δ֪7']==1 then
                                drawitem('������������')
							end
                            if thing[id] == 372 then 
                                drawitem('������ӹ֮��')
                            end
							--����װ�������ӳ�
							for i,v in ipairs(CC.ExtraOffense) do
								if v[1] == thing[id] then
									DrawString(mx+CC.MenuBorderPixel+20,my+CC.MenuBorderPixel,"����ǿ��:"..JY.Wugong[v[2]]["����"].."+"..v[3],PinkRed,myfont)
								end
							end
							
							if mx~=dx or my~=y3_2+2 then
								if thing[id] > 343 or thing[id] < 348 then	--����ҩƷ����ʾ
									DrawString(dx+CC.MenuBorderPixel+20, y3_2 + 2+CC.MenuBorderPixel, " Ч��:", LimeGreen, myfont)
								end
															
							end
						end
						
						--װ������ؼ���
						if myThing['����']==1 or myThing['����']==2 then
							if mx~=dx then
								mx=dx+4*myfont
								my=my+myfont+3
							end
							myflag=1
							local my2=my
							if myThing['����������']>-1 then
								drawitem('����:'..JY.Person[myThing['����������']]['����'])
							end
							drawitem('����������','����',{[0]='��','��','����'})
							drawitem('������','����')
							drawitem('�蹥����','����')
							drawitem('���Ṧ','�Ṧ')
							drawitem('���ö�����','�ö�')
							drawitem('��ҽ������','ҽ��')
							drawitem('��ⶾ����','�ⶾ')
							drawitem('��ȭ�ƹ���','ȭ��')
							drawitem('��ָ������','ָ��')
							drawitem('����������','����')
							drawitem('��ˣ������','ˣ��')
							drawitem('���������','����')
							drawitem('�谵������','����')
                            if thing[id] == 372 then 
                                drawitem('��80>����>30')
                            end
							--��ת����ʾ
							if thing[id] == 118 then
								local exstr = "��ϵ����ֵ֮��>=120 "
								local mylen = myfont * string.len(exstr) / 2 + 12
								DrawString(mx+CC.MenuBorderPixel+20,my+CC.MenuBorderPixel,exstr,C_GOLD,myfont)
								mx=mx+mylen
							end
							--��������ʾ
							if thing[id] == 176 then
								local exstr = "����/ˣ��/������һ��>=70 "
								local mylen = myfont * string.len(exstr) / 2 + 12
								DrawString(mx+CC.MenuBorderPixel+20,my+CC.MenuBorderPixel,exstr,C_GOLD,myfont)
								mx=mx+mylen
							end
							--��˿���׵���ʾ
							if thing[id] == 239 then
								local exstr = "ȭ�ƻ�ָ��>=70 "
								local mylen = myfont * string.len(exstr) / 2 + 12
								DrawString(mx+CC.MenuBorderPixel+20,my+CC.MenuBorderPixel,exstr,C_GOLD,myfont)
								mx=mx+mylen
							end
							--�߱�ָ������ʾ
							if thing[id] == 200 then
								local exstr = "ȭ�ƻ�ָ��>=200 "
								local mylen = myfont * string.len(exstr) / 2 + 12
								DrawString(mx+CC.MenuBorderPixel+20,my+CC.MenuBorderPixel,exstr,C_GOLD,myfont)
								mx=mx+mylen
							end							
							drawitem('������','����')
							drawitem('�辭��','��������')
							if mx~=dx or my~=my2 then
								DrawString(dx+CC.MenuBorderPixel+20,my2+CC.MenuBorderPixel,' ����:',LimeGreen,myfont)
							end
						end
						--��Ч˵��
						if WPTX2[thing[id]] ~= nil then
							if mx~=dx then
								mx=dx+4*myfont
								my=my+myfont+3
							end
							local my2=my
							if mx~=dx or my~=my2 then
								DrawString(dx+CC.MenuBorderPixel+20,my2+CC.MenuBorderPixel,' Ч��:',C_RED,myfont)
							end

							DrawString(dx+CC.MenuBorderPixel+myfont*3+20,my2+CC.MenuBorderPixel,WPTX2[thing[id]], M_DeepSkyBlue,myfont)
						end
						--��Ч˵��
						if myThing['�Ƿ���Ч'] == 1 and (WPTX[thing[id]][myThing['װ���ȼ�']] ~= nil or myThing['װ������'] == -1) then
							if mx~=dx then
								mx=dx+4*myfont
								my=my+myfont+3
							end
							local my2=my
							if mx~=dx or my~=my2 then
								DrawString(dx+CC.MenuBorderPixel+20,my2+CC.MenuBorderPixel,' ��Ч:',C_RED,myfont)
							end
							if myThing['װ������'] > -1 then
								local TXstr = WPTX[thing[id]][myThing['װ���ȼ�']]
								--�����ָ���;ö�
								if thing[id] == 303 then
									TXstr = TXstr.."��ʣ��"..JY.Person[651]["Ʒ��"].."�Σ�"
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
				--�޾Ʋ������޸�ѡ���
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
		
		DrawString(CC.ScreenW-240,CC.ScreenH-CC.Fontsmall-8	, "��F1�鿴��ϸ˵��", C_CYGOLD,CC.Fontsmall)
		DrawString(CC.ScreenW-220, CC.ScreenH-CC.Fontsmall*2-8, "����:", C_GOLD, CC.Fontsmall)
	    DrawString(CC.ScreenW-220+CC.FontSmall*3, CC.ScreenH-CC.Fontsmall*2-8, CC.Gold, C_CYGOLD, CC.Fontsmall)
		if IsViewingKungfuScrolls > 0 then
			local list = {"1:ȫ��","2:ȭ��","3:ָ��","4:����","5:����","6:����","7:����","8:��ѧ"}
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
		--������Ʒ������˵��
		elseif keypress==VK_F1 and cur_thing ~= -1 then
			detailed_info(cur_thing)
		--����1 ȫ��
		elseif IsViewingKungfuScrolls > 0 and keypress==49 then
			thing = original_thing
			thingnum = original_thingnum
			cur_line=0
			cur_x=0
			cur_y=0
			cur_thing=-1
			IsViewingKungfuScrolls = 1
		--����2 ȭ��
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
				local TSkill = JY.Thing[original_thing[i]]["�����书"]
				if TSkill > -1 and JY.Wugong[TSkill]["�书����"] == 1 then
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
		--����3 ָ��
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
				local TSkill = JY.Thing[original_thing[i]]["�����书"]
				if TSkill > -1 and JY.Wugong[TSkill]["�书����"] == 2 then
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
		--����4 ����
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
				local TSkill = JY.Thing[original_thing[i]]["�����书"]
				if TSkill > -1 and JY.Wugong[TSkill]["�书����"] == 3 then
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
		--����5 ����
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
				local TSkill = JY.Thing[original_thing[i]]["�����书"]
				if TSkill > -1 and JY.Wugong[TSkill]["�书����"] == 4 then
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
		--����6 ����
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
				local TSkill = JY.Thing[original_thing[i]]["�����书"]
				if TSkill > -1 and JY.Wugong[TSkill]["�书����"] == 5 then
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
		--����7 ����
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
				local TSkill = JY.Thing[original_thing[i]]["�����书"]
				if TSkill > -1 and (JY.Wugong[TSkill]["�书����"] == 6 or JY.Wugong[TSkill]["�书����"] == 7) then
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
		--����8 ��ѧ
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
				local TSkill = JY.Thing[original_thing[i]]["�����书"]
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
	--�޾Ʋ�����������ʾ����
	if IsViewingKungfuScrolls > 0 then
		IsViewingKungfuScrolls = 0
	end
	return cur_thing;
end


--��������������
function Game_SMap()         --��������������
	if JY.Restart == 1 then
		return
	end
	
    DrawSMap();	
	--�޾Ʋ������·���ʾ
	if CC.ShowXY==1 then
		lib.LoadPNG(91,43*2,CC.ScreenW/936*136,CC.ScreenH/702*142,2)
        DrawString(CC.ScreenW/936*70,CC.ScreenH/702*129,string.format("%s %d %d",JY.Scene[JY.SubScene]["����"],JY.Base["��X1"],JY.Base["��Y1"]) ,C_GOLD,CC.Fontsmall*0.9);
	end
		
	DrawTimer();
	
	JYZTB();
	--JYZTB1();
    ShowScreen();
    lib.SetClip(0, 0, 0, 0)
  
	local d_pass=GetS(JY.SubScene,JY.Base["��X1"],JY.Base["��Y1"],3);   --��ǰ·���¼�
	if d_pass>=0 then
		if d_pass ~=JY.OldDPass then     --�����ظ�����
			EventExecute(d_pass,3);       --·�������¼�
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
	local isout=0;                --�Ƿ���������
	if (JY.Scene[JY.SubScene]["����X1"] ==JY.Base["��X1"] and JY.Scene[JY.SubScene]["����Y1"] ==JY.Base["��Y1"]) or
		(JY.Scene[JY.SubScene]["����X2"] ==JY.Base["��X1"] and JY.Scene[JY.SubScene]["����Y2"] ==JY.Base["��Y1"]) or
		(JY.Scene[JY.SubScene]["����X3"] ==JY.Base["��X1"] and JY.Scene[JY.SubScene]["����Y3"] ==JY.Base["��Y1"]) then
		isout=1;
	end
	--�������ͼ
	if isout == 1 then
		--�޾Ʋ������޸���ֱ�ӷɽ�������������ڵ������������
		if JY.Base["��X"] == JY.Scene[JY.SubScene]["�⾰���X1"] and JY.Base["��Y"] == JY.Scene[JY.SubScene]["�⾰���Y1"] then
			--ѩɽҪ��������
			if JY.SubScene == 2 then
				JY.Base["��Y"] = JY.Base["��Y"] + 1
			--�츮Ҫ��������
			elseif JY.SubScene == 92 then
				JY.Base["��X"] = JY.Base["��X"] + 1
			else
				if JY.Base["�˷���"] == 0 then
					JY.Base["��Y"] = JY.Base["��Y"] - 1
				elseif JY.Base["�˷���"] == 1 then
					JY.Base["��X"] = JY.Base["��X"] + 1
				elseif JY.Base["�˷���"] == 2 then
					JY.Base["��X"] = JY.Base["��X"] - 1
				elseif JY.Base["�˷���"] == 3 then
					JY.Base["��Y"] = JY.Base["��Y"] + 1
				end
			end
		end
		--���̵ص�Ҫ��������
		if JY.SubScene == 13 then
			JY.Base["��X"] = 68
			JY.Base["��Y"] = 397
		end
		--�ɹŰ�Ҫ��������
		if JY.SubScene == 6 then
			JY.Base["��X"] = 49
			JY.Base["��Y"] = 111
		end
		JY.Status = GAME_MMAP
		--lib.PicInit()
		CleanMemory()
		JY.MmapMusic = JY.Scene[JY.SubScene]["��������"]
		--���û�����ó������ֵĻ�
		if JY.MmapMusic < 0 then
			JY.MmapMusic = 0
		end
		Init_MMap()
		JY.SubScene = -1
		JY.oldSMapX = -1
		JY.oldSMapY = -1
		lib.DrawMMap(JY.Base["��X"], JY.Base["��Y"], GetMyPic())
		lib.GetKey()
		lib.ShowSlow(20,0)
		return
	end
    --�Ƿ���ת����������
    if JY.Scene[JY.SubScene]["��ת����"] >= 0 and JY.Base["��X1"] == JY.Scene[JY.SubScene]["��ת��X1"] and JY.Base["��Y1"] == JY.Scene[JY.SubScene]["��ת��Y1"] then
		local OldScene = JY.SubScene
		JY.SubScene = JY.Scene[JY.SubScene]["��ת����"]
		lib.ShowSlow(20, 1)
		if JY.Scene[OldScene]["�⾰���X1"] ~= 0 then
			JY.Base["��X1"] = JY.Scene[JY.SubScene]["���X"]
			JY.Base["��Y1"] = JY.Scene[JY.SubScene]["���Y"]
		else
			JY.Base["��X1"] = JY.Scene[JY.SubScene]["��ת��X2"]
			JY.Base["��Y1"] = JY.Scene[JY.SubScene]["��ת��Y2"]
		end
		Init_SMap(1)
		return 
	end

    local x,y;
    local direct = -1;
    local keypress, ktype, mx, my = lib.GetKey();
	--�ȼ����ϴβ�ͬ�ķ����Ƿ񱻰���
    for i = VK_RIGHT,VK_UP do
        if i ~= CC.PrevKeypress and lib.GetKeyState(i) ~=0 then
			keypress = i
		end
	end 
    --������ϴβ�ͬ�ķ���δ�����£��������ϴ���ͬ�ķ����Ƿ񱻰���
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
		elseif keypress==VK_SPACE or keypress==VK_RETURN then       --�ո񴥷��¼�
			if JY.Base["�˷���"]>=0 then
				local d_num=GetS(JY.SubScene,JY.Base["��X1"]+CC.DirectX[JY.Base["�˷���"]+1],JY.Base["��Y1"]+CC.DirectY[JY.Base["�˷���"]+1],3);
				if d_num>=0 then
					EventExecute(d_num,1);
				end
			end
		--�޾Ʋ�����ȫ�׿�ݼ� 7-30
	    elseif keypress == VK_S then	--�浵
			Menu_SaveRecord()
	    elseif keypress == VK_L then	--����
			Menu_ReadRecord()
 
		elseif keypress == VK_Z then	--״̬
			Cls()
			Menu_Status()
		elseif keypress == VK_E then	--��Ʒ
			Cls()
			Menu_Thing()
		elseif keypress == VK_F3 then	--������λ
			Cls()
			Menu_TZDY()
		elseif keypress == VK_F4 then	--����
			Cls()		
			Menu_WPZL()
		end
	elseif ktype == 3 then
		if mx >= 0 and mx <= CC.ScreenW/936*63 and 
		   my >= CC.ScreenH/701*110 and my <= CC.ScreenH/701*160 then
		   CMenu()
		else  
			AutoMoveTab = {[0]=0}
			local x0 = JY.Base["��X1"]
			local y0 = JY.Base["��Y1"]
			
			local px=x0
			local py=y0
			if CONFIG.Zoom == 100 then
				--�޾Ʋ����������ڵ�ͼ�߽��Զ�Ѱ·���������
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
			
			if CONFIG.Zoom ~= 100 then		--�޾Ʋ�������֪��ʲôë�����������Ӿ�����ë��
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
	
	--�޾Ʋ������б���¼����꣬���Զ��ߵ�ǰ��һ��Żᴥ���¼�
	if CC.AutoMoveEvent[1] ~= 0 and 
	(JY.Base["��X1"] == CC.AutoMoveEvent[1] or JY.Base["��X1"] - 1 == CC.AutoMoveEvent[1] or JY.Base["��X1"] + 1 == CC.AutoMoveEvent[1]) and 
	(JY.Base["��Y1"] == CC.AutoMoveEvent[2] or JY.Base["��Y1"] - 1 == CC.AutoMoveEvent[2] or JY.Base["��Y1"] + 1 == CC.AutoMoveEvent[2]) then
		CC.AutoMoveEvent[0] = 1			--�����������¼�
	end
    
    if AutoMoveTab[0] ~= 0 then			--����Զ��߶�
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
        x=JY.Base["��X1"]+CC.DirectX[direct+1];
        y=JY.Base["��Y1"]+CC.DirectY[direct+1];
        JY.Base["�˷���"]=direct;
		if JY.WalkCount == 1 then
			lib.Delay(90)
		end
    else
        x=JY.Base["��X1"];
        y=JY.Base["��Y1"];
    end

    JY.MyPic=GetMyPic();
    DtoSMap();
    if SceneCanPass(x,y)==true then          --�µ���������߹�ȥ
        JY.Base["��X1"]=x;
        JY.Base["��Y1"]=y;
    end

    JY.Base["��X1"]=limitX(JY.Base["��X1"],1,CC.SWidth-2);
    JY.Base["��Y1"]=limitX(JY.Base["��Y1"],1,CC.SHeight-2);
    
	--һЩ�µ��¼�
	NEvent(keypress)
end

--��������(x,y)�Ƿ����ͨ��
--����true,���ԣ�false����
function SceneCanPass(x,y)  --��������(x,y)�Ƿ����ͨ��
    local ispass=true;        --�Ƿ����ͨ��

    if GetS(JY.SubScene,x,y,1)>0 then     --������1����Ʒ������ͨ��
        ispass=false;
    end

    local d_data=GetS(JY.SubScene,x,y,3);     --�¼���4
    if d_data>=0 then
        if GetD(JY.SubScene,d_data,0)~=0 then  --d*����Ϊ����ͨ��
            ispass=false;
        end
    end

    if CC.SceneWater[GetS(JY.SubScene,x,y,0)] ~= nil then   --ˮ�棬���ɽ���
        ispass=false;
    end
    return ispass;
end

function DtoSMap()          ---D*�е��¼����ݸ��Ƶ�S*�У�ͬʱ������Ч����
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
				if p3<=p1 then     --������ֹͣ
					if JY.Mytick %100 > delay then
						p3=p3+1;
					end
				else
					if JY.Mytick % 4 ==0 then      --4�����Ķ�������һ��
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


function DrawSMap()         --�泡����ͼ
	local x0=JY.SubSceneX+JY.Base["��X1"]-1;    --��ͼ���ĵ�
    local y0=JY.SubSceneY+JY.Base["��Y1"]-1;

    local x=limitX(x0,12,45)-JY.Base["��X1"];
    local y=limitX(y0,12,45)-JY.Base["��Y1"];
	
	if CONFIG.Zoom == 100 then
		lib.DrawSMap(JY.SubScene,JY.Base["��X1"],JY.Base["��Y1"],x,y,JY.MyPic)
	else
		lib.DrawSMap(JY.SubScene,JY.Base["��X1"],JY.Base["��Y1"],JY.SubSceneX,JY.SubSceneY,JY.MyPic)
	end
end


-- ��ȡ��Ϸ����
-- id=0 �½��ȣ�=1/2/3 ����
--�������Ȱ����ݶ���Byte�����С�Ȼ���������Ӧ��ķ������ڷ��ʱ�ʱֱ�Ӵ�������ʡ�
--����ǰ��ʵ����ȣ����ļ��ж�ȡ�ͱ��浽�ļ���ʱ�������ӿ졣�����ڴ�ռ������
function LoadRecord(id)       -- ��ȡ��Ϸ����
    local zipfile=string.format('data/save/Save_%d',id)
    
    if id ~= 0 and ( existFile(zipfile) == false) then
		QZXS("�˴浵���ݲ�ȫ�����ܶ�ȡ����ѡ�������浵�����¿�ʼ");
		return -1;
	end
    
    Byte.unzip(zipfile, 'r.grp','d.grp','s.grp','tjm')

    local t1=lib.GetTime();

    --��ȡR*.idx�ļ�
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
	
    --��ȡR*.grp�ļ�
    JY.Data_Base=Byte.create(idx[1]-idx[0]);              --��������
    Byte.loadfile(JY.Data_Base,grpFile,idx[0],idx[1]-idx[0]);

    --���÷��ʻ������ݵķ����������Ϳ����÷��ʱ�ķ�ʽ�����ˡ������ðѶ���������ת��Ϊ����Լ����ʱ��Ϳռ�
	local meta_t={
	    __index=function(t,k)
	        return GetDataFromStruct(JY.Data_Base,0,CC.Base_S,k);
		end,

		__newindex=function(t,k,v)
	        SetDataFromStruct(JY.Data_Base,0,CC.Base_S,k,v);
	 	end
	}
    setmetatable(JY.Base,meta_t);


    JY.PersonNum=math.floor((idx[2]-idx[1])/CC.PersonSize);   --����

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

    JY.ThingNum=math.floor((idx[3]-idx[2])/CC.ThingSize);     --��Ʒ
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

    JY.SceneNum=math.floor((idx[4]-idx[3])/CC.SceneSize);     --����
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

    JY.WugongNum=math.floor((idx[5]-idx[4])/CC.WugongSize);     --�书
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

    JY.ShopNum=math.floor((idx[6]-idx[5])/CC.ShopSize);     --�����̵�
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


-- д��Ϸ����
-- id=0 �½��ȣ�=1/2/3 ����
function SaveRecord(id)         -- д��Ϸ����

	--�ж��Ƿ����ӳ�������
	if JY.Status == GAME_SMAP then
      JY.Base["����"] = JY.SubScene
    else
      JY.Base["����"] = -1
    end
	
    --��ȡR*.idx�ļ�
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
    --дR*.grp�ļ�
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
-----------------------------------ͨ�ú���-------------------------------------------

function filelength(filename)         --�õ��ļ�����
    local inp=io.open(filename,"rb");
    local l= inp:seek("end");
	inp:close();
    return l;
end

--��S������, (x,y) ���꣬level �� 0-5
function GetS(id,x,y,level)       --��S������
	return lib.GetS(id,x,y,level);
end

--дS��
function SetS(id,x,y,level,v)       --дS��
	lib.SetS(id,x,y,level,v);
end

--��D*
--sceneid ������ţ�
--id D*���
--Ҫ���ڼ�������, 0-10
function GetD(Sceneid,id,i)          --��D*
    return lib.GetD(Sceneid,id,i);
end

--дD��
function SetD(Sceneid,id,i,v)         --дD��
	lib.SetD(Sceneid,id,i,v);
end

--�����ݵĽṹ�з�������
--data ����������
--offset data�е�ƫ��
--t_struct ���ݵĽṹ����jyconst���кܶඨ��
--key  ���ʵ�key
function GetDataFromStruct(data,offset,t_struct,key)  --�����ݵĽṹ�з������ݣ�����ȡ����
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

function SetDataFromStruct(data,offset,t_struct,key,v)  --�����ݵĽṹ�з������ݣ���������
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

--����t_struct ����Ľṹ�����ݴ�data�����ƴ��ж�����t��
function LoadData(t,t_struct,data)        --data�����ƴ��ж�����t��
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

--����t_struct ����Ľṹ������д��data Byte�����С�
function SaveData(t,t_struct,data)      --����д��data Byte�����С�
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

--����x�ķ�Χ
function limitX(x,minv,maxv)
	if x<minv then
	    x=minv;
	end
	if maxv ~= nil and x>maxv then
	    x=maxv;
	end
	return x
end

function RGB(r,g,b)          --������ɫRGB
	return r*65536+g*256+b;
end

function GetRGB(color)      --������ɫ��RGB����
    color=color%(65536*256);
    local r=math.floor(color/65536);
    color=color%65536;
    local g=math.floor(color/256);
    local b=color%256;
    return r,g,b
end

--�ȴ���������
function WaitKey(flag)
	--ktype  1�����̣�2������ƶ���3:��������4������Ҽ���5������м���6�������ϣ�7��������
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

--����һ���������İ�ɫ�����Ľǰ���
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

--����һ���������İ�ɫ�����Ľǰ���
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

--��ʾ��Ӱ�ַ���
function DrawString(x,y,str,color,size)         --��ʾ��Ӱ�ַ���
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

--��ʾ������ַ���
--(x,y) ���꣬�����Ϊ-1,������Ļ�м���ʾ
function DrawStrBox(x,y,str,color,size,boxcolor)         --��ʾ������ַ���
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

--�޾Ʋ��������Ӷ���ɫת����֧��
function DrawStrBox3(x, y, s, color, size, flag)         --��ʾ������ַ���
    local ll=#s -flag*2;
    local w=size*ll/2+2*CC.MenuBorderPixel;
	local h=size+2*CC.MenuBorderPixel;
	local function strcolor_switch(s)
		local Color_Switch={{"��",C_RED},{"��",C_GOLD},{"��",C_BLACK},{"��",C_WHITE},{"��",C_ORANGE}}
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
	
	--�޾Ʋ�����������ɫ 7-31
    DrawBox(x,y,x+w-1,y+h-1,LimeGreen);
	local space = 0;
	while string.len(s) >= 1 do
		local str
		str=string.sub(s,1,1)
		if string.byte(s,1,1) > 127 then		--�жϵ�˫�ַ�
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

--��ʾ��ѯ��Y/N��������Y���򷵻�true, N�򷵻�false
--(x,y) ���꣬�����Ϊ-1,������Ļ�м���ʾ
--��Ϊ�ò˵�ѯ���Ƿ�
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
	{"ȷ��/��", nil, 1}, 
	{"ȡ��/��", nil, 2}}
	local r = ShowMenu(menu, 2, 0, x + w - 4 * size - 2 * CC.MenuBorderPixel, y + h + CC.MenuBorderPixel, 0, 0, 1, 0, CC.DefaultFont, C_ORANGE, C_WHITE)
	if r == 1 then
		return true
	else
		return false
	end
end

--��ʾ�ַ������ȴ��������ַ���������ʾ����Ļ�м�
function DrawStrBoxWaitKey(s,color,size,flag,boxcolor)
	if JY.Restart == 1 then
		return
	end
    lib.GetKey();
    Cls();
	--�޾Ʋ������ֿ�����
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

--���� [0 , i-1] �����������
function Rnd(i)           --�����
    local r=math.random(i);
    return r-1;
end

--�����������ԣ���������ֵ���ƣ���Ӧ�����ֵ���ơ���Сֵ������Ϊ0
--id ����id
--str�����ַ���
--value Ҫ���ӵ�ֵ��������ʾ����
--����1,ʵ�����ӵ�ֵ
--����2���ַ�����xxx ����/���� xxxx��������ʾҩƷЧ��
function AddPersonAttrib(id, str, value)
	local oldvalue = JY.Person[id][str]
	local attribmax = math.huge
	if str == "����" then
		attribmax = JY.Person[id]["�������ֵ"]
	elseif str == "����" then
		attribmax = JY.Person[id]["�������ֵ"]
	elseif CC.PersonAttribMax[str] ~= nil then
		attribmax = CC.PersonAttribMax[str]
	end
	
	--�٤�ܳ˼����������ֵ
	if str == "���˳̶�" then
		if PersonKF(id, 169) then
			attribmax = 50
		end
		
	end
	
	if str == "�������ֵ" then
		local p_zz = JY.Person[id]["����"];
        local zz = 100 - JY.Person[id]["����"]
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
            --attribmax = 6000+ (101 - JY.Person[id]["����"])*400
        else
            attribmax = JY.Person[id]["�������ֵ"]    
        end
		--������ɨ�أ�ʯ���죬������ ������ɮ
		if match_ID(id, 53) or match_ID(id, 114) or match_ID(id, 38) or match_ID(id, 116)  or match_ID(id, 638) or match_ID(id, 499) or match_ID(id, 9999) then
			attribmax = 9999
		end
	
		--ѧһ���ڹ�����1500��������
		if Num_of_Neigong(id) == 1 then
			attribmax = attribmax + 1500

			
		--ѧ�����ڹ�����3000��������
		elseif Num_of_Neigong(id) == 2 then
			attribmax = attribmax + 3000
		
		--ѧ���������ڹ�����4500��������
		elseif Num_of_Neigong(id) > 2 then
			attribmax = attribmax + 4500

		end
		--ѧ�б�ڤ�����ǣ�+300
		for i = 1, JY.Base["�书����"] do
			if JY.Person[id]["�书" .. i] == 85 or JY.Person[id]["�书" .. i] == 88 then
				attribmax = attribmax + 300
				break
			end
		end
		--������������
		if match_ID(id, 58) then
			attribmax = attribmax - JY.Person[300]["����"] * 1000
		end
		--��������2999������9999
		if attribmax < 2999 then
			attribmax = 2999
		end
		if attribmax > 10000 then
			attribmax = 10000
		end
end	
    
	--�����أ������֣����ѹã��ö�500
	if str == "�ö�����" and (match_ID(id, 2) or match_ID(id, 83) or match_ID(id, 17)) then
		attribmax = 600
	end
	--����ˣ��ö�400
	if str == "�ö�����" and match_ID(id, 25) then
		attribmax = 500
	end
	--����ţ��ƽһָ��ѦĽ��ҽ��500
	if str == "ҽ������" and (match_ID(id, 16) or match_ID(id, 28) or match_ID(id, 45)) then
		attribmax = 600
	end
	--����ʯ��������ҽ��400
	if str == "ҽ������" and (match_ID(id, 85) or match_ID(id, 2)) then
		attribmax = 500
	end
	--����ҽ����ҽ���ö��ⶾ����400
	if (str == "ҽ������" or str == "�ö�����" or str == "�ⶾ����") and id == 0 and JY.Base["��׼"] == 8 then
		attribmax = 500
	end
	--�����������ö��ⶾ����500
	if (str == "�ö�����" or str == "�ⶾ����") and id == 0 and JY.Base["��׼"] == 9 then
		attribmax = 600
	end
	--�ֻ���ҽ���ö�����300
	if (str == "ҽ������" or str == "�ö�����") and match_ID(id, 4) then
		attribmax = 400
	end
	--��Ѱ�����������ɶ���500
	if str == "��������" and match_ID(id, 498) then
		attribmax = 400
	end	
	--�¼�����Ѻ����ֵ������
	if match_ID(id, 75) and JY.Person[0]["�������"] > 0 and (str == "ȭ�ƹ���" or str == "ָ������" or str == "��������" or str == "ˣ������" or str == "�������") then
		attribmax = 9999
	end	
	local newvalue = limitX(oldvalue + value, 0, attribmax)
	JY.Person[id][str] = newvalue
	local add = newvalue - oldvalue
	local showstr = ""
	if add > 0 then
		showstr = string.format("%s ���� %d", str, add)
	elseif add < 0 then
		showstr = string.format("%s ���� %d", str, -add)
	end
	return add, showstr
end

--����midi
function PlayMIDI(id)             --����midi
    JY.CurrentMIDI=id;
    if JY.EnableMusic==0 then
        return ;
    end
    if id>=0 then
        lib.PlayMIDI(string.format(CC.MIDIFile,id+1));
    end
end

--������Чatk***
function PlayWavAtk(id)             --������Чatk***
    if JY.EnableSound==0 then
        return ;
    end
    if id>=0 then
        lib.PlayWAV(string.format(CC.ATKFile,id));
    end
end

--������Чe**
function PlayWavE(id)              --������Чe**
    if JY.EnableSound==0 then
        return ;
    end
    if id>=0 then
        lib.PlayWAV(string.format(CC.EFile,id));
    end
end

--flag =0 or nil ȫ��ˢ����Ļ
--1 ��������εĿ���ˢ��
function ShowScreen(flag)
	if JY.Darkness == 0 then
		if flag == nil then
			flag = 0
		end
		lib.ShowSurface(flag)
	end
end

--ͨ�ò˵�����
-- menuItem ��ÿ���һ���ӱ�����Ϊһ���˵���Ķ���
--          �˵����Ϊ  {   ItemName,     �˵��������ַ���
--                          ItemFunction, �˵����ú��������û����Ϊnil
--                          Visible       �Ƿ�ɼ�  0 ���ɼ� 1 �ɼ�, 2 �ɼ�����Ϊ��ǰѡ���ֻ����һ��Ϊ2��
--                                        ������ֻȡ��һ��Ϊ2�ģ�û�����һ���˵���Ϊ��ǰѡ���
--                                        ��ֻ��ʾ���ֲ˵�������´�ֵ��Ч��
--                                        ��ֵĿǰֻ�����Ƿ�˵�ȱʡ��ʾ������
--                       }
--          �˵����ú���˵����         itemfunction(newmenu,id)
--
--       ����ֵ
--              0 �������أ������˵�ѭ�� 1 ���ú���Ҫ���˳��˵��������в˵�ѭ��
--
-- numItem      �ܲ˵������
-- numShow      ��ʾ�˵���Ŀ������ܲ˵���ܶ࣬һ����ʾ���£�����Զ����ֵ
--                =0��ʾ��ʾȫ���˵���

-- (x1,y1),(x2,y2)  �˵���������ϽǺ����½����꣬���x2,y2=0,������ַ������Ⱥ���ʾ�˵����Զ�����x2,y2
-- isBox        �Ƿ���Ʊ߿�0 �����ƣ�1 ���ơ������ƣ�����(x1,y1,x2,y2)�ľ��λ��ư�ɫ���򣬲�ʹ�����ڱ����䰵
-- isEsc        Esc���Ƿ������� 0 �������ã�1������
-- Size         �˵��������С
-- color        �����˵�����ɫ����ΪRGB
-- selectColor  ѡ�в˵�����ɫ,
--;
-- ����ֵ  0 Esc����
--         >0 ѡ�еĲ˵���(1��ʾ��һ��)
--         <0 ѡ�еĲ˵�����ú���Ҫ���˳����˵�����������˳����˵�

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
	--�޾Ʋ�����ս����ݼ�ʱ���ж�
	local In_Battle = false;
	if JY.Status == GAME_WMAP and numItem >= 8 and menuItem[8][1] == "�Զ�" then
		In_Battle = true
	end
	--�޾Ʋ�����ս���˵��ж�
	local In_Tactics = false;
	if JY.Status == GAME_WMAP and numItem >= 3 and menuItem[3][1] == "�ȴ�" then
		In_Tactics = true
	end
	--�����˵��ж�
	local In_Other = false;
	if JY.Status == GAME_WMAP and numItem >= 5 and menuItem[3][1] == "ҽ��" then
		In_Other = true
	end	
	--�޸�ս���˵�����Ա���ʾ��ݼ�
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
		--��ݼ���ʾ��ʾ
		if In_Battle == true then
			if newMenu[i][1] == "����" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "A", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "�˹�" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "G", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "ս��" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "S", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "����" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "H", LimeGreen, CC.FontSmall)
			elseif newMenu[i][2] == War_TgrtsMenu then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "T", LimeGreen, CC.FontSmall)
			end
		end
		if In_Tactics == true then
			if newMenu[i][1] == "����" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "P", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "����" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "D", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "�ȴ�" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "W", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "����" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "J", LimeGreen, CC.FontSmall)
		    elseif newMenu[i][1] == "��Ϣ" then
			DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "R", LimeGreen, CC.FontSmall)			
			end
		end 
		if In_Other == true then
		if newMenu[i][1] == "�ö�" then
			DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "V", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "�ⶾ" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "Q", LimeGreen, CC.FontSmall)
		    elseif newMenu[i][1] == "ҽ��" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "F", LimeGreen, CC.FontSmall)
			elseif newMenu[i][1] == "��Ʒ" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "E", LimeGreen, CC.FontSmall)
		    elseif newMenu[i][1] == "״̬" then
				DrawString(x1 + CC.MenuBorderPixel + size*2, y1 + CC.MenuBorderPixel + (i - start) * (size + CC.RowPixel) +2, "Z", LimeGreen, CC.FontSmall)	
			end
		end
	  end
		ShowScreen()

		local keyPress, ktype, mx, my = WaitKey(1)
		lib.Delay(CC.Frame)
	  
		if keyPress==VK_ESCAPE or ktype == 4 then
			--Esc �� �˳�
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
			if newNumItem < current +start then                --Alungky �޸�������ʱ��������BUG
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
			elseif current < num then                --Alungky �޸�������ʱ��������BUG
				start = 1
			end
		--�޾Ʋ�����ս����ݼ�
		--����
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
		--1-9ֱ�ӹ���
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
		--�˹�
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
		--ս��
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
		--����
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
		--�ö�
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
		--�ⶾ
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
		--ҽ��
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
		--��Ʒ
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
		--״̬
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
		--��Ϣ
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
		--��ɫָ��
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
		--C�鿴
		elseif In_Battle == true and keyPress == VK_C then
			local r=MapWatch();
			ClsN();
			lib.LoadSur(surid,0,0);
			if isBox==1 then
				DrawBox(x1,y1,x1+w,y1+h,C_WHITE);
			end
		--����
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
		--����
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
		--�ȴ�
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
		--����
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
			if ktype == 2 or ktype == 3 then			--ѡ��
				if mx >= x1 and mx <= x1 + w and my >= y1 and my <= y1 + h then
					current = start + math.modf((my - y1 - CC.MenuBorderPixel) / (size + CC.RowPixel))
					mk = true;
				end
			end
			--ѡ��ȷ��
			if  keyPress==VK_SPACE or keyPress==VK_RETURN or ktype == 5 or (ktype == 3 and mk) then
				if newMenu[current][2]==nil then
					returnValue=newMenu[current][4];
					break;
				elseif newMenu[current][2] == SelectNeiGongMenu then
					local id = WAR.Person[WAR.CurID]["������"]
					--�˹���������
					if JY.Person[id]["����"] < 2000 then
						DrawStrBoxWaitKey("�������㣬�޷��˹�",C_RED,CC.DefaultFont,nil,LimeGreen)
					--�˹���������
					elseif JY.Person[id]["����"] < 20 then
						DrawStrBoxWaitKey("�������㣬�޷��˹�",C_RED,CC.DefaultFont,nil,LimeGreen)
					else
						local r=newMenu[current][2](newMenu,current); 
						--���������˵�ȫ������20��Ϊ�ж�����
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
					local id = WAR.Person[WAR.CurID]["������"]
					--�˹���������
					if JY.Person[id]["����"] < 20 then
						DrawStrBoxWaitKey("�������㣬�޷��˹�",M_DeepSkyBlue,CC.DefaultFont,nil,LimeGreen)
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
					local r=newMenu[current][2](newMenu,current);               --���ò˵�����
			
					--�޾Ʋ�������дһ������ķ����߼�����Ӧ�˹�
					if r==1 then
						returnValue= -newMenu[current][4];
						break;
					--���������˵�ȫ������20��Ϊ�ж�����
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

--����������ShowMenuһ������һЩ�ر�Ľ�������˵��
--menu ÿ����������ֵ��1���ƣ�2ִ�к�����3��ʾ��ʽ(0��ɫ��ѡ��1������ʾ��2����ʾ, 3��ɫ����ѡ��)
--itemNum �˵��ĸ�����ͨ���ڵ��õ�ʱ�� #menu�Ϳ�����
--numShow ÿ����ʾ�Ĳ˵�����
--showRow һ��������ʾ������������������ʾ�˵������ﲻ��һ������������������Զ���Ӧ���ֵ
--str �Ǳ�������֣���nil����ʾ
--ѡ����
function ShowMenu2(menu,itemNum,numShow,showRow,x1,y1,x2,y2,isBox,isEsc,size,color,selectColor, str, selIndex)     --ͨ�ò˵�����
    local w=0;
    local h=0;   --�߿�Ŀ��
    local i,j=0,0;
    local col=0;     --ʵ�ʵ���ʾ�˵���
    local row=0;
    
    lib.GetKey();
    Cls();
    
    --��һ���µ�table
    local menuItem = {};
    local numItem = 0;                --��ʾ������
    
    --�ѿ���ʾ�Ĳ��ַŵ���table
    for i,v in pairs(menu) do
		if v[3] ~= 2 then
			numItem = numItem + 1;
			menuItem[numItem] = {v[1],v[2],v[3],i};                --ע���4��λ�ã�����i��ֵ
		end
    end
    
    --����ʵ����ʾ�Ĳ˵�����
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

    --����߿�ʵ�ʿ��
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

    local start=0;             --��ʾ�ĵ�һ��

    local curx = 1;          --��ǰѡ����
    local cury = 0;
    local current = curx + cury*numShow;
    
    --Ĭ����ѡ��
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
				local drawColor=color;           --���ò�ͬ�Ļ�����ɫ
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

		if keyPress==VK_ESCAPE or ktype == 4 then                  --Esc �˳�
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
			if ktype == 2 or ktype == 3 then			--ѡ��
				--�޾Ʋ������Ӹ��߼��ж���ֹ����
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
					local r=menuItem[current][2](menuItem,current);               --���ò˵�����
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
        
	--����ֵ�������ȡ��4��λ�õ�ֵ
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
	if isEsc == 1 and keyPress==VK_ESCAPE then                  --Esc �˳�
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
			local r=newMenu[current][2](newMenu,current);               --���ò˵�����
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
					local r=newMenu[current][2](newMenu,current);               --���ò˵�����
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
--------------------------------------��Ʒʹ��---------------------------------------
--��Ʒʹ��ģ��
--��ǰ��Ʒid
--����1 ʹ������Ʒ�� 0 û��ʹ����Ʒ��������ĳЩԭ����ʹ��
function UseThing(id)
	return DefaultUseThing(id);
end

--ȱʡ��Ʒʹ�ú�����ʵ��ԭʼ��ϷЧ��
--id ��Ʒid
function DefaultUseThing(id)                --ȱʡ��Ʒʹ�ú���
    if JY.Thing[id]["����"]==0 then
        return UseThing_Type0(id);
    elseif JY.Thing[id]["����"]==1 then
        return UseThing_Type1(id);
    elseif JY.Thing[id]["����"]==2 then
        return UseThing_Type2(id);
    elseif JY.Thing[id]["����"]==3 then
        return UseThing_Type3(id);
    elseif JY.Thing[id]["����"]==4 then
        return UseThing_Type4(id);
    end
end

--������Ʒ�������¼�
function UseThing_Type0(id)
	--�ϲ�����
	if id == 286 then
		local jyzj = 0
		for j=1, CC.MyThingNum do
			if JY.Base["��Ʒ" .. j] == 287 then
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
			if JY.Base["��Ʒ" .. j] == 286 then
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
		local x=JY.Base["��X1"]+CC.DirectX[JY.Base["�˷���"]+1];
		local y=JY.Base["��Y1"]+CC.DirectY[JY.Base["�˷���"]+1];
        local d_num=GetS(JY.SubScene,x,y,3)
        if d_num>=0 then
            JY.CurrentThing=id;
            EventExecute(d_num,2);       --��Ʒ�����¼�
            JY.CurrentThing=-1;
			return 1;
		else
		    return 0;
        end
    end
	--�ϵ��鵤�¼�
	if id == 315 then
		local dld = 0
		for j=1, CC.MyThingNum do
			if JY.Base["��Ʒ" .. j] == 314 and JY.Base["��Ʒ" .. j] == 231 and JY.Base["��Ʒ" .. j] == 	26 then
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


--�ж�һ�����Ƿ����װ��������һ����Ʒ
--���� true����������false����
function CanUseThing(id, personid)
	local str = ""
		
	--�żһԵ�ר��װ��
	if JY.Thing[id]["����������"] == 651 then
		if personid == 0 and JY.Base["����"] == 651 then
			return true
		else
			return false
		end
	end

    --if ZhongYongZD(personid) and (id == 118 or id == 235) then 
        --return true
   -- end
		--������˫
	if match_ID(personid, 9993) and (id == 72 or id == 69 or id == 83 or id == 85 or id == 88 or id == 90 or  id == 92 or id == 112 or id ==137 
      or id == 168 or id == 171 or id  == 245 or id ==250 or id == 253 or id == 260 or id == 265 or id == 268 or id == 269 or id == 274 
     or id == 277 or  id == 291 or id == 319 or id == 324 or id == 332)  then
		return true
	--�����̣���������ؼ�
	elseif (match_ID(personid, 76) or match_ID(personid, 637))  and JY.Thing[id]["����"] == 2 then
		return true	
	--����ѧʥ��
	elseif id == 70 and personid == 0 then
		return true		
	--���촩װ��
	elseif match_ID(personid, 104) and JY.Thing[id]["װ������"] >= 0 then
		return true
	--��Գװ����Գ
	elseif match_ID(personid, 9997) and id == 326 then
		return true	
    --����װ���廨��
    elseif match_ID(personid, 721) and id == 349 then
        Cls(CC.MainSubMenuX, CC.MainSubMenuY, CC.ScreenW, CC.ScreenH)
		 if DrawStrBoxYesNo(-1, -1, "װ������Ʒ��Ҫ�Թ����Ƿ����װ��?", C_WHITE, CC.DefaultFont) == false  then
			return 0
		else
			lib.FillColor(0, 0, CC.ScreenW, CC.ScreenH, C_RED, 128)
			ShowScreen()
			lib.Delay(80)
			lib.ShowSlow(15, 1)
			Cls()
			lib.ShowSlow(50, 0)
			JY.Person[personid]["�Ա�"] = 2
			JY.Person[personid]["������"] = 721
			JY.Person[personid]["ͷ�����"]=322
			JY.Person[personid]["���ж���֡��2"]=16
			JY.Person[personid]["���ж����ӳ�2"]=14
			JY.Person[personid]["�书��Ч�ӳ�2"]=14
			local add, str = AddPersonAttrib(personid, "������", -20)
			DrawStrBoxWaitKey(JY.Person[personid]["����"] .. str, C_ORANGE, CC.DefaultFont)
			add, str = AddPersonAttrib(personid, "������", -30)
			DrawStrBoxWaitKey(JY.Person[personid]["����"] .. str, C_ORANGE, CC.DefaultFont)
			return true
		end
	--��֤ѧ��ղ�����
	elseif match_ID(personid, 149) and id == 265 then
		return true
	else
		if JY.Thing[id]["����������"] >= 0 and JY.Thing[id]["����������"] ~= personid and (personid == 0 and JY.Thing[id]["����������"]==JY.Base["����"])==false then
			return false
		end
		if JY.Thing[id]["����������"] ~= 2 and JY.Person[personid]["��������"] ~= 2 and JY.Person[personid]["��������"] ~= 3 and JY.Thing[id]["����������"] ~= JY.Person[personid]["��������"] then
			local cond = 1
			--���ڿ�����������ѧϰ ��ͨ�ټ� ����˫��֮��
			if JY.Thing[id]["�����书"] == JY.Person[personid]["�츳�ڹ�"]  or match_ID(personid, 578)or match_ID(personid, 9987)
               or match_ID(personid,9978) then
				cond = 2
			--����ѧ������������
			elseif id == 86 and personid == 0 then
				cond = 2
			end
			--����Ҳ������������ѧϰ
			for i = 1, 4 do
				if JY.Thing[id]["�����书"] == JY.Person[personid]["�츳�⹦"..i] then
					cond = 2
					break
				end
			end
			if cond == 1 then
				return false
			end
		end
		if JY.Person[personid]["�������ֵ"] < JY.Thing[id]["������"] then
			return false
		end
		if JY.Person[personid]["������"] < JY.Thing[id]["�蹥����"] then
			return false
		end
		if JY.Person[personid]["�Ṧ"] < JY.Thing[id]["���Ṧ"] then
			return false
		end
		if JY.Person[personid]["�ö�����"] < JY.Thing[id]["���ö�����"] then
			return false
		end
		if JY.Person[personid]["ҽ������"] < JY.Thing[id]["��ҽ������"] then
			return false
		end
		if JY.Person[personid]["�ⶾ����"] < JY.Thing[id]["��ⶾ����"] then
			return false
		end

		--ѧ��С���๦������ֵ����+10��
		local lv = 0;
		if PersonKF(personid, 98) then
			lv = 10
		end
		--��ͨ�ټ�
		if match_ID(personid, 9987)  then
		 lv = lv + 20
		end
		--�к�����ѧ�罣������-40
		if id == 117 and PersonKF(personid, 67) then
			lv = lv + 40
		end
		--���罣��ѧ����������-40
		if id == 136 and PersonKF(personid, 44) then
			lv = lv + 40
		end
		
		--�һ�������ѧϰ����֮һ��ʣ���������������-10���ɵ���
		if id == 95 or id == 101 or id == 123 then
			for i = 1, JY.Base["�书����"] do
				if JY.Person[personid]["�书" .. i] == 12 or JY.Person[personid]["�书" .. i] == 18 or JY.Person[personid]["�书" .. i] == 38 then
					lv = lv + 10
				end
			end
		end
		--̫�����壬ѧϰ����֮һ��ʣ���������-10
		if id == 97 or id == 115  then
			for i = 1, JY.Base["�书����"] do
				if JY.Person[personid]["�书" .. i] == 46 or JY.Person[personid]["�书" .. i] == 16  then
					lv = lv + 10
				end
			end
		end		
		--��հ���-40
		if id == 291 or id == 90 or id == 324  then
			for i = 1, JY.Base["�书����"] do
				if JY.Person[personid]["�书" .. i] == 46 or JY.Person[personid]["�书" .. i] == 16  then
					lv = lv + 10
				end
			end
		end			
		--�д򹷣�ѧ����-40
		if id == 86 and PersonKF(personid, 80) then
		if PersonKF(personid,204) then
		  lv = lv + 60
		  else
			lv = lv + 40
		end
	end	
		--�н�����ѧ��-40
		if id == 167 and PersonKF(personid, 26) then
		if PersonKF(personid,204) then
		  lv = lv + 60
		  else
			lv = lv + 40
		end
	end	
		--�оŽ���ѧ������-40
		if id == 180 and PersonKF(personid, 47) then
			lv = lv + 40
		end
		--�г����٣�ѧ�Ž�-40
		if id == 114 and PersonKF(personid, 73) then
			lv = lv + 40
		end
		
		if JY.Person[personid]["ȭ�ƹ���"] + lv < JY.Thing[id]["��ȭ�ƹ���"] then
			return false
		end
		if JY.Person[personid]["ָ������"] + lv < JY.Thing[id]["��ָ������"] then
			return false
		end
		if JY.Person[personid]["��������"] + lv  < JY.Thing[id]["����������"] then
			return false
		end
		if JY.Person[personid]["ˣ������"] + lv  < JY.Thing[id]["��ˣ������"] then
			return false
		end
		if JY.Person[personid]["�������"] + lv < JY.Thing[id]["���������"] then
			return false
		end
		
		if JY.Person[personid]["��������"] < JY.Thing[id]["�谵������"] then
			return false
		end
    
        if id == 372 then 
            if JY.Person[personid]["����"] < 31 or JY.Person[personid]["����"] > 79 then 
                return false
            end
        end
    
		if JY.Thing[id]["������"] >= 0 then
			if JY.Thing[id]["������"] > JY.Person[personid]["����"] then
				return false;
			end
		else
			if -JY.Thing[id]["������"] < JY.Person[personid]["����"] then
				return false;
			end 
		end
        
	end
	  
	--��ת����
	if id == 118 then
		local R = JY.Person[personid]
		local wp = R["ȭ�ƹ���"] + R["ָ������"] + R["��������"] + R["ˣ������"] + R["�������"]
		if wp < 120 then
			return false
		end
	end
	--��������
	if id == 176 then
		local R = JY.Person[personid]
		if R["��������"] >= 70 then
			return true
		elseif R["ˣ������"] >= 70 then
			return true
		elseif R["�������"] >= 70 then
			return true
		else
			return false
		end
	end
    --�廨��
	if id == 349 then
		--local R = JY.Person[personid]
		if match_ID(personid, 27) then
			return true
		else 
			return false
		end
	end
    	--ԧ�쵶
	if id == 217  then
		local R = JY.Person[personid]
		if R["�Ա�"]== 0 then
			return true
		else return false
		end
	end	
    	--ԧ�쵶
	if id == 218  then
		local R = JY.Person[personid]
		if R["�Ա�"]== 1 then
			return true
		else return false
		end
	end		
	--��˿��������
	if id == 239 then
		local R = JY.Person[personid]
		if R["ȭ�ƹ���"] >= 70 then
			return true
		elseif R["ָ������"] >= 70 then
			return true
		else
			return false
		end
	end
	--�߱�ָ������
	if id == 200 then
		local R = JY.Person[personid]
		if R["ȭ�ƹ���"] >= 200 then
			return true
		elseif R["ָ������"] >= 200 then
			return true
		else
			return false
		end
	end	
	return true
end

--ҩƷʹ��ʵ��Ч��
--id ��Ʒid��
--personid ʹ����id
--����ֵ��0 ʹ��û��Ч������Ʒ����Ӧ�ò��䡣1 ʹ����Ч������ʹ�ú���Ʒ����Ӧ��-1
function UseThingEffect(id, personid, amount)
	--��ʹ��������Ĭ��Ϊʹ��1��
	if amount == nil then
		amount = 1
	end

	--����ҩƷ
	if id == 343 then
		Cls()  --����
		local k = JY.Wugong;
		local menu = {}
	
		local kftype = JYMsgBox("��ѡ��", "��ѡ��ϲ�����츳�ڹ�����", {"�ڹ�",}, 1, 347)
	
		for i = 1, JY.WugongNum - 1 do
			local kfname = k[i]["����"]
			if string.len(kfname) == 8 then
				kfname = kfname.."  "
			elseif string.len(kfname) == 6 then
				kfname = kfname.."    "
			elseif string.len(kfname) == 4 then
				kfname = kfname.."      "
			end
			menu[i] = {kfname,nil,2}
			if k[i]["�书����"] == 6 then
				menu[i][3] = 1
			end
		end
		local nexty = CC.ScreenH/2-CC.DefaultFont*4 + CC.SingleLineHeight
		local r = ShowMenu2(menu, #menu, 4, 5, CC.ScreenW/2-CC.DefaultFont*10-20, nexty, 0, 0, 1, 0, CC.DefaultFont, C_ORANGE, C_WHITE,"�����츳�ڹ�")
	
		if r > 0 then
			SetTianNei(personid, r)
		end
			return 2
	elseif id == 344 then
		Cls()  --����
		local k = JY.Wugong;
		local menu = {}
	
		local kftype = JYMsgBox("��ѡ��", "��ѡ��ϲ�����츳�Ṧ����", {"�Ṧ",}, 1, 347)
	
		for i = 1, JY.WugongNum - 1 do
			local kfname = k[i]["����"]
			if string.len(kfname) == 8 then
				kfname = kfname.."  "
			elseif string.len(kfname) == 6 then
				kfname = kfname.."    "
			elseif string.len(kfname) == 4 then
				kfname = kfname.."      "
			end
			menu[i] = {kfname,nil,2}
			if k[i]["�书����"] == 7 then
				menu[i][3] = 1
			end
		end
		local nexty = CC.ScreenH/2-CC.DefaultFont*4 + CC.SingleLineHeight
		local r = ShowMenu2(menu, #menu, 4, 5, CC.ScreenW/2-CC.DefaultFont*10-20, nexty, 0, 0, 1, 0, CC.DefaultFont, C_ORANGE, C_WHITE,"�����츳�Ṧ")
	
		if r > 0 then
			SetTianQing(personid, r)
		end
		return 2
	elseif id == 345 then
		Cls()  --����
		local k = JY.Wugong;
		local menu = {}
		local kftype = JYMsgBox("��ѡ��", "��ѡ��ϲ�����츳�⹦1����", {"ȭ��","ָ��","����","����","����"}, 5, 347)
	
		for i = 1, JY.WugongNum - 1 do
			local kfname = k[i]["����"]
			if string.len(kfname) == 8 then
				kfname = kfname.."  "
			elseif string.len(kfname) == 6 then
				kfname = kfname.."    "
			elseif string.len(kfname) == 4 then
				kfname = kfname.."      "
			end
			menu[i] = {kfname,nil,2}
			if k[i]["�书����"] == kftype then
				menu[i][3] = 1
			end
		end
		local nexty = CC.ScreenH/2-CC.DefaultFont*4 + CC.SingleLineHeight
		local r = ShowMenu2(menu, #menu, 4, 5, CC.ScreenW/2-CC.DefaultFont*10-20, nexty, 0, 0, 1, 0, CC.DefaultFont, C_ORANGE, C_WHITE,"�����츳�⹦")
	
		if r > 0 then
			SetTianWai(personid, 1, r)
		end

		return 2
	elseif id == 346 then
		Cls()  --����
		JY.Person[0]["ͷ�����"]=JY.Person[642]["ͷ�����"]
		JY.Person[0]["������"]=JY.Person[642]["������"]
		JY.Person[0]["����"]=JY.Person[642]["����"]
		for i=1,5 do
			JY.Person[0]["���ж���֡��" .. i]=JY.Person[642]["���ж���֡��" .. i]
			JY.Person[0]["���ж����ӳ�" .. i]=JY.Person[642]["���ж����ӳ�" .. i]
			JY.Person[0]["�书��Ч�ӳ�" .. i]=JY.Person[642]["�书��Ч�ӳ�" .. i]
		end
		return 2
	else
		local str = {}
		str[0] = string.format("ʹ�� %s �� %d", JY.Thing[id]["����"], amount)
		local strnum = 1
		local addvalue = nil
		if JY.Thing[id]["������"] > 0 then
			local add = JY.Thing[id]["������"] - math.modf(JY.Thing[id]["������"] * JY.Person[personid]["���˳̶�"] / 200) + Rnd(5)
			--����ţ�ڶӣ���ҩЧ��Ϊ1.3��
			if JY.Status == GAME_WMAP and inteam(personid) and (inteam(16) or JY.Base["����"] == 16) then
				for w = 0, WAR.PersonNum - 1 do
					if match_ID(WAR.Person[w]["������"], 16) and WAR.Person[w]["����"] == false and WAR.Person[w]["�ҷ�"] then
						add = math.modf(add * 1.3)
						break;
					end
				end
			end
			if add <= 0 then
				add = 5 + Rnd(5)
			end
			add = math.modf(add)
			
			--�鰲ͨ�����˳�ҩ����Ѫ������Ѫ
			if JY.Status == GAME_WMAP then
				for w = 0, WAR.PersonNum - 1 do
					if match_ID(WAR.Person[w]["������"], 71) and WAR.Person[w]["����"] == false and WAR.Person[w]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
						add = -add
						break;
					end
				end
			end
			
			--���˳�ҩЧ���ӱ�
			if not inteam(personid) then
				add = add * 2;
			end
			--ʵս���ҩЧ���ӱ�
			if  inteam(personid) and JY.Person[0]["ʵս"] >= 500 then
				add = add * 2;
			end			
		
			if JY.Status == GAME_WMAP then
				WAR.Person[WAR.CurID]["���˵���"] = AddPersonAttrib(personid, "���˳̶�", -math.modf(add / 8))
			end

			addvalue, str[strnum] = AddPersonAttrib(personid, "����", add*amount)
			
			--�����壺��ʾ��������
			if JY.Status == GAME_WMAP then
				WAR.Person[WAR.CurID]["��������"] = addvalue;
			end
			if addvalue ~= 0 then
				strnum = strnum + 1
			end
		end
	  
		local function ThingAddAttrib(s)
			if JY.Thing[id]["��" .. s] ~= 0 then
				addvalue, str[strnum] = AddPersonAttrib(personid, s, JY.Thing[id]["��" .. s]*amount)
				if addvalue ~= 0 then
				strnum = strnum + 1
				end
				--�����壺��ʾ��������������
				if JY.Status == GAME_WMAP then
					if s == "����" then
						WAR.Person[WAR.CurID]["��������"] = addvalue;
					elseif s == "����" then
						WAR.Person[WAR.CurID]["��������"] = addvalue;
					end
				end
			end
		end
	  
		ThingAddAttrib("�������ֵ")
	  
		if JY.Thing[id]["���ж��ⶾ"] < 0 then
			addvalue, str[strnum] = AddPersonAttrib(personid, "�ж��̶�", math.modf(JY.Thing[id]["���ж��ⶾ"] / 2)*amount)
			if addvalue ~= 0 then
				strnum = strnum + 1
			end
			--�����壺��ʾ�нⶾ����
			if JY.Status == GAME_WMAP then
				if addvalue < 0 then
					WAR.Person[WAR.CurID]["�ⶾ����"] = -addvalue;
				elseif addvalue > 0 then
					WAR.Person[WAR.CurID]["�ж�����"] = addvalue;
				end
			end
		end
		  
		ThingAddAttrib("����")
	  
		if JY.Thing[id]["�ı���������"] == 2 then
			str[strnum] = "������·��Ϊ������һ"
			strnum = strnum + 1
		end
		---
        if JY.Status == GAME_WMAP then 
            if id == 25 then 
                JY.Person[personid]['���˳̶�'] = 0
                JY.Person[personid]['�ж��̶�'] = 0
                JY.Person[personid]['���ճ̶�'] = 0
                JY.Person[personid]['����̶�'] = 0
                WAR.FXDS[personid] = nil
				WAR.LXZT[personid] = nil
				WAR.PD['�屦���۾�'][personid] = 100               
            end
            if id == 24 then
                if WAR.LXZT[personid] ~= nil then 
                    WAR.LXZT[personid] = WAR.LXZT[personid] - 50
                    if WAR.LXZT[personid] < 1 then 
                        WAR.LXZT[personid] = nil
                    end
                end
                WAR.PD['��ī�Ͼ�'][personid] = 100
            end
            
            if id == 23 then 
                AddPersonAttrib(personid,'���ճ̶�',-20)
                WAR.PD['��¶��'][personid] = 50
            end    
            
            if id == 22 then 
                AddPersonAttrib(personid,'����̶�',-50)
                WAR.PD['�滨��'][personid] = 50
            end
            
            if id == 11 then 
                WAR.PD['��������'][personid] = 100
            end
            
            if id == 10 then 
                WAR.PD['ţ��ѪЫ'][personid] = 50
            end
            
            if id == 9 then 
                WAR.PD['�����ⶾ'][personid] = 50
            end
            
            if id == 3 then 
                WAR.PD['�����ܵ�'][personid] = 200
            end
            
            if id == 1 then 
                WAR.PD['��������'][personid] = 100
            end
            
            if id == 0 then 
                WAR.PD['С����'][personid] = 50
            end
        else    
            if id == 25 then 
                JY.Person[personid]['���˳̶�'] = 0
                JY.Person[personid]['�ж��̶�'] = 0
                JY.Person[personid]['���ճ̶�'] = 0
				JY.Person[personid]['����̶�'] = 0				
            end
        end
        
	    if JY.Person[id]["��������"] > 12 then
            JY.Person[id]["��������"] = 12 	   
	    end	
		ThingAddAttrib("����")
		ThingAddAttrib("�������ֵ")
		ThingAddAttrib("������")
		ThingAddAttrib("������")
		ThingAddAttrib("�Ṧ")
		ThingAddAttrib("ҽ������")
		ThingAddAttrib("�ö�����")
		ThingAddAttrib("�ⶾ����")
		ThingAddAttrib("��������")
		ThingAddAttrib("ȭ�ƹ���")
		ThingAddAttrib("��������")
		ThingAddAttrib("ˣ������")
		ThingAddAttrib("�������")
		ThingAddAttrib("��������")
		ThingAddAttrib("��ѧ��ʶ")
		ThingAddAttrib("��������")
	  
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
				--��ʾʹ����Ʒ����
				DrawString(CC.MainMenuX, CC.ScreenH-(strnum+2)*CC.Fontsmall, JY.Person[WAR.Person[WAR.CurID]["������"]]["����"].." "..str[0], C_WHITE, CC.Fontsmall);
				for i=1, strnum-1 do 
					DrawString(CC.MainMenuX, CC.ScreenH + (i-strnum-2)*CC.Fontsmall, str[i], C_WHITE, CC.Fontsmall);
				end
				
				ShowScreen()
				--��ʾ����
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

--װ����Ʒ
function UseThing_Type1(id)
	DrawStrBox(CC.MainSubMenuX, CC.MainSubMenuY, string.format("˭Ҫ�䱸%s?", JY.Thing[id]["����"]), C_WHITE, CC.DefaultFont)
	local nexty = CC.MainSubMenuY + CC.SingleLineHeight
	local r = SelectTeamMenu(CC.MainSubMenuX, nexty)
	local pp1, pp2 = 0, 0
	if r > 0 then
		local personid = JY.Base["����" .. r]
		--���ũװ��������
		if id == 202 and match_ID(personid, 72) then
			say("�ٺ٣���ڱ����������������ŵı�����˭˵ˣ��������װ���ˣ�",72,0)
			if JY.Thing[id]["ʹ����"] >= 0 then
								
				JY.Person[JY.Thing[id]["ʹ����"]]["����"] = -1
			end
			if JY.Person[personid]["����"] >= 0 then
				JY.Thing[JY.Person[personid]["����"]]["ʹ����"] = -1
			end
			JY.Person[personid]["����"] = id
			JY.Thing[id]["ʹ����"] = personid
			return 1
		end
		
		if CanUseThing(id, personid) then
			if JY.Thing[id]["װ������"] == 0 then
				if JY.Thing[id]["ʹ����"] >= 0 then
					
					JY.Person[JY.Thing[id]["ʹ����"]]["����"] = -1
				end
				if JY.Person[personid]["����"] >= 0 then
					JY.Thing[JY.Person[personid]["����"]]["ʹ����"] = -1
				end
				JY.Person[personid]["����"] = id
			
			elseif JY.Thing[id]["װ������"] == 1 then
				if JY.Thing[id]["ʹ����"] >= 0 then
					
					JY.Person[JY.Thing[id]["ʹ����"]]["����"] = -1
				end
				if JY.Person[personid]["����"] >= 0 then
					JY.Thing[JY.Person[personid]["����"]]["ʹ����"] = -1
				end
				JY.Person[personid]["����"] = id
			elseif JY.Thing[id]["װ������"] == 2 then
				if JY.Thing[id]["ʹ����"] >= 0 then
					
					JY.Person[JY.Thing[id]["ʹ����"]]["����"] = -1
				end
				if JY.Person[personid]["����"] >= 0 then
					JY.Thing[JY.Person[personid]["����"]]["ʹ����"] = -1
				end
				JY.Person[personid]["����"] = id				
			  
			end
			JY.Thing[id]["ʹ����"] = personid
		else
			DrawStrBoxWaitKey("���˲��ʺ��䱸����Ʒ", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	return 1
end
--�ؼ���Ʒʹ��
function UseThing_Type2(id)
	if JY.Thing[id]["ʹ����"] >= 0 and DrawStrBoxYesNo(-1, -1, "����Ʒ�Ѿ������������Ƿ�������?", C_WHITE, CC.DefaultFont) == false then
		Cls(CC.MainSubMenuX, CC.MainSubMenuY, CC.ScreenW, CC.ScreenH)
		ShowScreen()
		return 0
	end
	Cls()
	DrawStrBox(CC.MainSubMenuX, CC.MainSubMenuY, string.format("˭Ҫ����%s?", JY.Thing[id]["����"]), C_WHITE, CC.DefaultFont)
	local nexty = CC.MainSubMenuY + CC.SingleLineHeight
	local r = SelectTeamMenu(CC.MainSubMenuX, nexty)
	if r > 0 then
		local personid = JY.Base["����" .. r]
		local yes, full = nil, nil
		if JY.Thing[id]["�����书"] >= 0 then
			yes = 0
			full = 1
			for i = 1, JY.Base["�书����"] do
				if JY.Person[personid]["�书" .. i] == JY.Thing[id]["�����书"] then
					yes = 1
				else
					if JY.Person[personid]["�书" .. i] == 0 then
						full = 0
					end
				end
			end
		end
		
        if CanUseThing(id, personid) then
            --����һ����о���������д����Ŀ���������ѧ����
            if id == 83 then
                if PersonKF(personid, 99) and PersonKF(personid, 106) == false then
                    if DrawStrBoxYesNo(-1, -1, "����������һ����У��Ƿ��书ϴΪ������?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 99 then
                                JY.Person[personid]["�书" .. i] = 106
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�ڹ�"] == 99 then
                                    JY.Person[personid]["�츳�ڹ�"] = 106
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end
            --��ϼһ������������������ϼ�Ŀ���������ѧ��������
            if id == 299 then
                if PersonKF(personid, 89) and PersonKF(personid, 175) == false then
                    if DrawStrBoxYesNo(-1, -1, "����������һ����У��Ƿ��书��ϼ��ϴΪ��������?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 89 then
                                JY.Person[personid]["�书" .. i] = 175
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�ڹ�"] == 89 then
                                    JY.Person[personid]["�츳�ڹ�"] = 175
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end

            --Ѫ����ħ��һ�����
            if id == 327 then
                if PersonKF(personid, 163) and PersonKF(personid, 160) == false then
                    if DrawStrBoxYesNo(-1, -1, "Ѫ����ħ��һ����У��Ƿ��书Ѫ����ǩϴΪ��ħ��?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 163 then
                                JY.Person[personid]["�书" .. i] = 160
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�ڹ�"] == 163 then
                                    JY.Person[personid]["�츳�ڹ�"] = 160
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end	
            --��󡹦��Ϣ��һ�����
            if id == 308 then
                if PersonKF(personid, 95) and PersonKF(personid, 180) == false then
                    if DrawStrBoxYesNo(-1, -1, "�������飬һ����У��Ƿ��书��󡹦ϴΪ��Ϣ��?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 95 then
                                JY.Person[personid]["�书" .. i] = 180
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�ڹ�"] == 95 then
                                    JY.Person[personid]["�츳�ڹ�"] = 180
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end	
            --���ճ���һ�����
            if id == 342 then
                if PersonKF(personid, 94) and PersonKF(personid, 203) == false then
                    if DrawStrBoxYesNo(-1, -1, "���ճ�����һ����У��Ƿ��书���չ�ϴΪ������?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 94 then
                                JY.Person[personid]["�书" .. i] = 203
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�ڹ�"] == 94 then
                                    JY.Person[personid]["�츳�ڹ�"] = 203
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end	
           --��Ů���� ��Ů���Ľ� һ�����
           if id == 350 then
                if PersonKF(personid, 42) and PersonKF(personid, 139) == false then
                    if DrawStrBoxYesNo(-1, -1, "��Ů���ģ�һ����У��Ƿ��书��Ů����ϴΪ��Ů���Ľ���?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 42 then
                                JY.Person[personid]["�书" .. i] = 139
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�⹦1"] == 42 then
                                    JY.Person[personid]["�츳�⹦1"] = 139
                                end
                                if JY.Person[personid]["�츳�⹦2"] == 42 then
                                    JY.Person[personid]["�츳�⹦2"] = 139
                                end							
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end		   
            --�䵱�ķ� ̫����һ�����
            if id == 295 then
                if PersonKF(personid, 209) and PersonKF(personid, 171) == false then
                    if DrawStrBoxYesNo(-1, -1, "�䵱���ڹ�һ����У��Ƿ��䵱�ķ�ϴΪ̫����?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 209 then
                                JY.Person[personid]["�书" .. i] = 171
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�ڹ�"] == 209 then
                                    JY.Person[personid]["�츳�ڹ�"] = 171
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end 
            --�����ķ� �׽һ�����
            if id == 85 then
                if PersonKF(personid, 208) and PersonKF(personid, 108) == false then
                    if DrawStrBoxYesNo(-1, -1, "�������ڹ�һ����У��Ƿ������ķ�ϴΪ�׽��", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 208 then
                                JY.Person[personid]["�书" .. i] = 108
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Base["��׼"] == 6 then
                                    JY.Person[personid]["��������"] = 3
                                else
                                    JY.Person[personid]["��������"] = 2
                                end
                                if JY.Person[personid]["�츳�ڹ�"] == 208 then
                                    JY.Person[personid]["�츳�ڹ�"] = 108
                                end
                                yes = 2							
                                break
                            end
                        end
                    end
                end
            end    
            --ȫ���ķ� ���칦һ�����
            if id == 77 then
                if PersonKF(personid, 210) and PersonKF(personid, 100) == false then
                    if DrawStrBoxYesNo(-1, -1, "ȫ����ڹ�һ����У��Ƿ�ȫ���ķ�ϴΪ���칦��", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 210 then
                                JY.Person[personid]["�书" .. i] = 100
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�ڹ�"] == 200 then
                                    JY.Person[personid]["�츳�ڹ�"] = 100
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end  
                --��Ĺ�ķ� ��Ů�ľ� һ�����
            if id == 280 then
                if PersonKF(personid, 211) and PersonKF(personid, 154) == false then
                    if DrawStrBoxYesNo(-1, -1, "��Ĺ���ڹ�һ����У��Ƿ񽫹�Ĺ�ķ�ϴΪ��Ů�ľ���", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 211 then
                                JY.Person[personid]["�书" .. i] = 154
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�ڹ�"] == 211 then
                                    JY.Person[personid]["�츳�ڹ�"] = 154
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end
                --��ɽ�ķ� ��ϼ�� һ�����
            if id == 67 then
                if PersonKF(personid, 212) and PersonKF(personid, 89) == false then
                    if DrawStrBoxYesNo(-1, -1, "��ɽ���ڹ�һ����У��Ƿ񽫻�ɽ�ķ�ϴΪ��ϼ�񹦣�", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 212 then
                                JY.Person[personid]["�书" .. i] = 89
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�ڹ�"] == 212 then
                                    JY.Person[personid]["�츳�ڹ�"] = 89
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end  	
                --��ɽ�ķ� �������� һ�����
            if id == 366 then
                if PersonKF(personid, 213) and PersonKF(personid, 216) == false then
                    if DrawStrBoxYesNo(-1, -1, "��ɽ���ڹ�һ����У��Ƿ���ɽ�ķ�ϴΪ����������", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 213 then
                                JY.Person[personid]["�书" .. i] = 216
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�ڹ�"] == 213 then
                                    JY.Person[personid]["�츳�ڹ�"] = 216
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end  
                    --Ѫ���ķ� Ѫ��ħ�� һ�����
            if id == 285 then
                if PersonKF(personid, 214) and PersonKF(personid, 163) == false then
                    if DrawStrBoxYesNo(-1, -1, "Ѫ�����ڹ�һ����У��Ƿ�Ѫ���ķ�ϴΪѪ����ǩ��", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 214 then
                                JY.Person[personid]["�书" .. i] = 163
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�ڹ�"] == 214 then
                                    JY.Person[personid]["�츳�ڹ�"] = 163
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end  		
                        --ؤ�������� ������ һ�����
            if id == 351 then
                if PersonKF(personid, 215) and PersonKF(personid, 204) == false then
                    if DrawStrBoxYesNo(-1, -1, "ؤ���ڹ�һ����У��Ƿ�������ϴΪ��������", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 215 then
                                JY.Person[personid]["�书" .. i] = 204
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�ڹ�"] == 215 then
                                    JY.Person[personid]["�츳�ڹ�"] = 204
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end 
             --�ػ� ʥ���� һ�����
            if id == 70 then
                if PersonKF(personid, 217) and PersonKF(personid, 93) == false then
                    if DrawStrBoxYesNo(-1, -1, "�����ڹ�һ����У��Ƿ񽫵ػ�ϴΪʥ���񹦣�", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 217 then
                                JY.Person[personid]["�书" .. i] = 93
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�ڹ�"] == 217 then
                                    JY.Person[personid]["�츳�ڹ�"] = 93
                                end
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end 
               --�޺�ȭ ������ һ�����
           if id == 90 then
                if PersonKF(personid, 1) and PersonKF(personid, 22) == false then
                    if DrawStrBoxYesNo(-1, -1, "�����޺����书һ����У��Ƿ��书�޺�ȭ��ϴΪ������?", C_WHITE, CC.DefaultFont) then
                        for i = 1, JY.Base["�书����"] do
                            if JY.Person[personid]["�书" .. i] == 1 then
                                JY.Person[personid]["�书" .. i] = 22
                                JY.Person[personid]["�书�ȼ�" .. i] = 50
                                if JY.Person[personid]["�츳�⹦1"] == 1 then
                                    JY.Person[personid]["�츳�⹦1"] = 22
                                end
                                if JY.Person[personid]["�츳�⹦2"] == 1 then
                                    JY.Person[personid]["�츳�⹦2"] = 22
                                end							
                                yes = 2
                                break
                            end
                        end
                    end
                end
            end	
        
        end
		--����Ѿ����书����ѡ����书û��ѧ�ᣬ�򲻿�װ������
		if yes == 0 and full == 1 then
			DrawStrBoxWaitKey("�����书���Ѵﱾ��Ŀ����", C_WHITE, CC.DefaultFont)
			return 0
		end
    
		--��������
		if CC.Shemale[id] == 1 then
			--�������ֱ��ѧ
			if (personid == 0 and JY.Base["��׼"] == 3) or (personid == 0 and JY.Base["����"] == 652 ) or (personid == 0 and JY.Base["����"] == 189 ) then
				say("�š����ҿ����������书�ľ���֮����ʵ�������Ƿ��Թ�����������Խ�����˷�������⣡",0,1)
				yes = 1
			--���Ǵ�Ӯ�������ߣ�����ֱ��ѧ
			elseif personid == 0 and CC.TX["Ц��а��"] == 2 then
				yes = 1
			elseif personid == 92 then
				say("�����һ���Ҫ����",92,1)
				return 0
			elseif JY.Person[personid]["�Ա�"] == 0 and CanUseThing(id, personid) then
				Cls(CC.MainSubMenuX, CC.MainSubMenuY, CC.ScreenW, CC.ScreenH)
				if DrawStrBoxYesNo(-1, -1, "������������Ȼӵ��Թ����Ƿ���Ҫ����?", C_WHITE, CC.DefaultFont) == false then
					return 0
				else
					lib.FillColor(0, 0, CC.ScreenW, CC.ScreenH, C_RED, 128)
					ShowScreen()
					lib.Delay(80)
					lib.ShowSlow(15, 1)
					Cls()
					lib.ShowSlow(50, 0)
					JY.Person[personid]["�Ա�"] = 2
					local add, str = AddPersonAttrib(personid, "������", -20)
					DrawStrBoxWaitKey(JY.Person[personid]["����"] .. str, C_ORANGE, CC.DefaultFont)
					add, str = AddPersonAttrib(personid, "������", -30)
					DrawStrBoxWaitKey(JY.Person[personid]["����"] .. str, C_ORANGE, CC.DefaultFont)
					if JY.Base["��׼"] > 0 then
						JY.Person[0]["���"] = "����"
						JY.Person[0]["���2"] = "Ѿͷ"
						local zddh = 227
						local js = JY.Base["��׼"]
						local jsdz = JY.Person[0]["ͷ�����"]
						if js == 3 then
						jsdz = 228
						elseif js == 4 then
						jsdz = 229
						elseif js == 5 then
						jsdz = 230
						else
						jsdz = 227
						   end
						JY.Person[0]["������"] = 555+JY.Base["��׼"]
						local f_ani = {
                         {0, 0, 0}, 
				         {9, 9, 7}, 
			            {8, 8, 6}, 
				        {8, 8, 6}, 
				        {9, 7, 7}}
						for i = 1, 5 do
							JY.Person[0]["���ж���֡��" .. i] = f_ani[i][1]
							JY.Person[0]["���ж����ӳ�" .. i] = f_ani[i][3]
							JY.Person[0]["�书��Ч�ӳ�" .. i] = f_ani[i][2]
						end
					end
				end
	
			elseif JY.Person[personid]["�Ա�"] == 1 then
				DrawStrBoxWaitKey("���˲��ʺ���������Ʒ", C_WHITE, CC.DefaultFont)
				return 0
			end
		end


		if yes == 1 or CanUseThing(id, personid) then
			if JY.Thing[id]["ʹ����"] == personid then
				return 0
			end
			if JY.Person[personid]["������Ʒ"] >= 0 then
				JY.Thing[JY.Person[personid]["������Ʒ"]]["ʹ����"] = -1
			end
			if JY.Thing[id]["ʹ����"] >= 0 then
				JY.Person[JY.Thing[id]["ʹ����"]]["������Ʒ"] = -1
				JY.Person[JY.Thing[id]["ʹ����"]]["��Ʒ��������"] = 0
			end
			JY.Thing[id]["ʹ����"] = personid
			JY.Person[personid]["������Ʒ"] = id
			JY.Person[personid]["��Ʒ��������"] = 0
		else
			DrawStrBoxWaitKey("���˲��ʺ���������Ʒ", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	return 1
end

--�޾Ʋ�����ʹ��ҩƷ��ʳƷ
function UseThing_Type3(id)
	local usepersonid = -1
	local amount_use = 0
	Cls()
	if JY.Status == GAME_MMAP or JY.Status == GAME_SMAP then
		--Cls(CC.MainSubMenuX, CC.MainSubMenuY, CC.ScreenW, CC.ScreenH)
		DrawStrBox(CC.MainSubMenuX, CC.MainSubMenuY, string.format("˭Ҫʹ��%s?", JY.Thing[id]["����"]), C_WHITE, CC.DefaultFont)
		local nexty = CC.MainSubMenuY + CC.SingleLineHeight
		local r = SelectTeamMenu(CC.MainSubMenuX, nexty)
		if r > 0 then
			usepersonid = JY.Base["����" .. r]

	
			--��ս���п�������ʹ��
			local max_amount = 0
			for i = 1, CC.MyThingNum do
				if JY.Base["��Ʒ" .. i] == id then
					max_amount = JY.Base["��Ʒ����" .. i]
					break;
				end
			end
			amount_use = InputNum("ʹ������", 1, max_amount)
		end
	
	--ս����
	elseif JY.Status == GAME_WMAP then
		--����ţ�����������ҩ
		if match_ID(WAR.Person[WAR.CurID]["������"], 16) then
			War_CalMoveStep(WAR.CurID, 8, 1)
			local x, y = War_SelectMove()
			if x ~= nil then
				local emeny = GetWarMap(x, y, 2)
				if emeny >= 0 and WAR.Person[WAR.CurID]["�ҷ�"] == WAR.Person[emeny]["�ҷ�"] then
					usepersonid = WAR.Person[emeny]["������"]
				end
			end
		else
			usepersonid = WAR.Person[WAR.CurID]["������"]
		end
	end

	--ս���в���ʹ�ü�Ѫ�����޵���Ʒ
	if JY.Status == GAME_WMAP and (id >=14 and id <= 21) then
		return 0
	end
	
	if usepersonid >= 0 then
		--��ս����ʹ����Ʒ
		if JY.Status == GAME_MMAP or JY.Status == GAME_SMAP then

			local r = UseThingEffect(id, usepersonid, amount_use)
			if r == 1 then
				instruct_32(id, -amount_use)
				WaitKey()
			elseif r == 2 then
				instruct_32(id, -amount_use)
			end
			if id == 14 then
                JY.Person[usepersonid]["��������"] = JY.Person[usepersonid]["��������"]+amount_use
                if JY.Person[usepersonid]["��������"] > 12 then
                    JY.Person[usepersonid]["��������"] = 12
                end
                Hp_Max(usepersonid)
            end
		--ս����ʹ����Ʒ
		elseif JY.Status == GAME_WMAP then
			if UseThingEffect(id, usepersonid) == 1 then
				instruct_32(id, -1)
                if id >= 22 and id <= 25 and match_ID(usepersonid, 9965) then 
                    WAR.PD['�˾Ʊ�'][usepersonid] = (WAR.PD['�˾Ʊ�'][usepersonid] or 0) + 1
                    WAR.PD['����'][usepersonid] = (WAR.PD['����'][usepersonid] or 0) + 500
                    CurIDTXDH(WAR.CurID, 79,1,"���񡤰˾Ʊ�",C_ORANGE);
                end
			end
		end
	else
		return 0
	end
	return 1
end

--������Ʒ
function UseThing_Type4(id)
	if JY.Status == GAME_WMAP then
		return War_UseAnqi(id)
	end
	return 0
end

--------------------------------------------------------------------------------
--------------------------------------�¼�����-----------------------------------

--�¼����������
--id��d*�еı��
--flag 1 �ո񴥷���2����Ʒ������3��·������
function EventExecute(id,flag)
    JY.CurrentD=id;

    oldEventExecute(flag)

    JY.CurrentD=-1;
end

--����ԭ�е�ָ��λ�õĺ���
--�ɵĺ������ָ�ʽΪ  oldevent_xxx();  xxxΪ�¼����
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
	if newkdef[eventnum]~=nil then--�����ж�����¼�����Ƿ����
		lib.Debug("new kdef "..eventnum)--������ڣ���ִ���¼�ǰ����debug�ı����ӡ��  new kdef +�¼���ţ��Ա����ʱʹ��
		if eventnum>0 then--����¼���Ŵ���0
			newkdef[eventnum]()--ִ�и��¼�
		end
	end
end

--�ı���ͼ���꣬�ӳ�����ȥ���ƶ�����Ӧ����
function ChangeMMap(x,y,direct)          --�ı���ͼ����
	JY.Base["��X"]=x;
	JY.Base["��Y"]=y;
	JY.Base["�˷���"]=direct;
end

--�ı䵱ǰ����
function ChangeSMap(sceneid,x,y,direct)       --�ı䵱ǰ����
    JY.SubScene=sceneid;
	JY.Base["��X1"]=x;
	JY.Base["��Y1"]=y;
	JY.Base["�˷���"]=direct;
end


--���(x1,y1)-(x2,y2)�����ڵ����ֵȡ�
--���û�в����������������Ļ����
--ע��ú�������ֱ��ˢ����ʾ��Ļ
function Cls(x1,y1,x2,y2)                    --�����Ļ
    if x1==nil then        --��һ������Ϊnil,��ʾû�в�������ȱʡ
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
        lib.DrawMMap(JY.Base["��X"],JY.Base["��Y"],GetMyPic());             --��ʾ����ͼ
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


--�����Ի���ʾ��Ҫ���ַ�������ÿ��n�������ַ���һ���Ǻ�
function GenTalkString(str,n)             					 --�����Ի���ʾ��Ҫ���ַ���
    local tmpstr="";
    for s in string.gmatch(str .. "*","(.-)%*") do           --ȥ���Ի��е�����*. �ַ���β����һ���Ǻţ������޷�ƥ��
        tmpstr=tmpstr .. s;
    end

    local newstr="";
    while #tmpstr>0 do
		local w=0;
		while w<#tmpstr do
		    local v=string.byte(tmpstr,w+1);	--��ǰ�ַ���ֵ
			if v>=128 then
			    w=w+2;
			else
			    w=w+1;
			end
			if w >= 2*n-1 then					--Ϊ�˱����������ַ�
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

--�����¶Ի�
function TalkEx(s,pid,flag,name)
	say(s,pid,flag,name)
end

--����ָ�ռλ����
function instruct_test(s)
    DrawStrBoxWaitKey(s,C_ORANGE,24);
end

--����
function instruct_0()         --����
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

--�Ի�
--talkid: Ϊ���֣���Ϊ�Ի���ţ�Ϊ�ַ�������Ϊ�Ի�����
--headid: ͷ��id
--flag :�Ի���λ�ã�0 ��Ļ�Ϸ���ʾ, ���ͷ���ұ߶Ի�
--            1 ��Ļ�·���ʾ, ��߶Ի����ұ�ͷ��
--            2 ��Ļ�Ϸ���ʾ, ��߿գ��ұ߶Ի�
--            3 ��Ļ�·���ʾ, ��߶Ի����ұ߿�
--            4 ��Ļ�Ϸ���ʾ, ��߶Ի����ұ�ͷ��
--            5 ��Ļ�·���ʾ, ���ͷ���ұ߶Ի�
function instruct_1(talkid, headid, flag)
	local s = ReadTalk(talkid)
	if s == nil then
		return 
	end
	TalkEx(s, headid, flag)
end

--�õ���Ʒ
function instruct_2(thingid, num)
	if JY.Thing[thingid] == nil then
		return 
	end
	instruct_32(thingid, num)
	if num > 0 then
		DrawStrBoxWaitKey(string.format("�õ���Ʒ%sX%d", "����"..JY.Thing[thingid]["����"].."�ϡ�", num), C_ORANGE, CC.DefaultFont, 1)
	else
		DrawStrBoxWaitKey(string.format("ʧȥ��Ʒ%sX%d", "����"..JY.Thing[thingid]["����"].."�ϡ�", -num), C_ORANGE, CC.DefaultFont, 1)
	end
	if thingid >= CC.BookStart and thingid < CC.BookStart + CC.BookNum then
		instruct_2(174, 5000)
	end
end

--�޸�ָ������������¼�
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
	return DrawStrBoxYesNo(-1, -1, "�Ƿ���֮����(Y/N)?", C_ORANGE, CC.DefaultFont)
end

function instruct_6(warid, tmp, tmp, flag)
	return WarMain(warid, flag)
end

function instruct_7()
	instruct_test("ָ��7����")
end

function instruct_8(musicid)
	JY.MmapMusic = musicid
end

function instruct_9()
	return DrawStrBoxYesNo(-1, -1, "�Ƿ�Ҫ�����(Y/N)?", C_ORANGE, CC.DefaultFont)
end

--��Ӻ���
function instruct_10(personid)
	if JY.Person[personid] == nil then
		lib.Debug("instruct_10 error: person id not exist")
		return 
	end
	local add = 0
	--�޾Ʋ��������벻�����Լ�
	if personid ~= JY.Base["����"] then
		for i = 2, CC.TeamNum do
			if JY.Base["����" .. i] < 0 then
			  JY.Base["����" .. i] = personid
			  add = 1
			  break;
			end
		end
	end
	for i = 1, 4 do
		local id = JY.Person[personid]["Я����Ʒ" .. i]
		local n = JY.Person[personid]["Я����Ʒ����" .. i]
		if n < 0 then
			n = 0
		end
		if id >= 0 and n > 0 then
			instruct_2(id, n)
			JY.Person[personid]["Я����Ʒ" .. i] = -1
			JY.Person[personid]["Я����Ʒ����" .. i] = 0
		end
	end
	if add == 0 then
		lib.Debug("instruct_10 error: �����������")
		return
	end
end

function instruct_11()
	return DrawStrBoxYesNo(-1, -1, "�Ƿ�(Y/N)?", C_ORANGE, CC.DefaultFont)
end

--��Ϣ
function instruct_12(flag)
	for i = 1, CC.TeamNum do
		local id = JY.Base["����" .. i]
		if id >= 0 then
			JY.Person[id]["���˳̶�"] = 0
			JY.Person[id]["�ж��̶�"] = 0
			AddPersonAttrib(id, "����", math.huge)
			AddPersonAttrib(id, "����", math.huge)
			AddPersonAttrib(id, "����", math.huge)
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
	DrawString(CC.GameOverX, CC.GameOverY, JY.Person[0]["����"], RGB(0, 0, 0), CC.DefaultFont)
	local x = CC.ScreenW - 9 * CC.DefaultFont
	DrawString(x, 10, os.date("%Y-%m-%d %H:%M"), RGB(216, 20, 24), CC.DefaultFont)
	DrawString(x, 10 + CC.DefaultFont + CC.RowPixel, "�ڵ����ĳ��", RGB(216, 20, 24), CC.DefaultFont)
	DrawString(x, 10 + (CC.DefaultFont + CC.RowPixel) * 2, "�����˿ڵ�ʧ����", RGB(216, 20, 24), CC.DefaultFont)
	DrawString(x, 10 + (CC.DefaultFont + CC.RowPixel) * 3, "�ֶ���һ�ʡ�����", RGB(216, 20, 24), CC.DefaultFont)
	local loadMenu = {
	{"ѡ�����", nil, 1},  
	{"�ؼ�˯��ȥ", nil, 1}}
	local y = CC.ScreenH - 4 * (CC.DefaultFont + CC.RowPixel) - 10
	local sl = ShowMenu(loadMenu, #loadMenu, 0, x, y, 0, 0, 0, 0, CC.DefaultFont, C_ORANGE, C_WHITE)
	if sl ==1 then
		local r = SaveList();
			if r < 1 then
				JY.Status = GAME_END
				return 0;
			end
			
			Cls();
			DrawStrBox(-1,CC.StartMenuY,"���Ժ�...",C_GOLD,CC.DefaultFont);
			ShowScreen();
			local result = LoadRecord(r);
			if result ~= nil then
				instruct_15();
				return 0;
			end
		if JY.Base["����"] ~= -1 then
			JY.Status = GAME_SMAP
			JY.SubScene = JY.Base["����"]
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
	local xwperson;	--�ж�����
	--��ս���в���Ч�����ڴ���������ж�
	if personid == JY.Base["����"] and JY.Status ~= GAME_WMAP then
		xwperson = 0
	else
		xwperson = personid
	end
	for i = 1, CC.TeamNum do
		if xwperson == JY.Base["����" .. i] then
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
		if JY.Base["��Ʒ" .. i] == thingid then
			return true
		end
	end
	return false
end

function instruct_19(x, y)
	JY.Base["��X1"] = x
	JY.Base["��Y1"] = y
	JY.SubSceneX = 0
	JY.SubSceneY = 0
end

function instruct_20()
	if JY.Base["����" .. CC.TeamNum] >= 0 then
		return true
	end
	return false
end

--��Ӻ���
function instruct_21(personid)
	if JY.Person[personid] == nil then
		lib.Debug("instruct_21 error: personid not exist")
		return 
	end
	local j = 0
	for i = 1, CC.TeamNum do
		if personid == JY.Base["����" .. i] then
		  j = i
		end
	end
	if j == 0 then
		return 
	end
	for i = j + 1, CC.TeamNum do
		JY.Base["����" .. i - 1] = JY.Base["����" .. i]
	end
	JY.Base["����" .. CC.TeamNum] = -1
	if JY.Person[personid]["����"] >= 0 then
		JY.Thing[JY.Person[personid]["����"]]["ʹ����"] = -1
		JY.Person[personid]["����"] = -1
	end
	if JY.Person[personid]["����"] >= 0 then
		JY.Thing[JY.Person[personid]["����"]]["ʹ����"] = -1
		JY.Person[personid]["����"] = -1
	end
	if JY.Person[personid]["����"] >= 0 then
		JY.Thing[JY.Person[personid]["����"]]["ʹ����"] = -1
		JY.Person[personid]["����"] = -1
	end	
	if JY.Person[personid]["������Ʒ"] >= 0 then
		JY.Thing[JY.Person[personid]["������Ʒ"]]["ʹ����"] = -1
		JY.Person[personid]["������Ʒ"] = -1
	end
	JY.Person[personid]["��Ʒ��������"] = 0
end

function instruct_22()
	for i = 1, CC.TeamNum do
		if JY.Base["����" .. i] >= 0 then
			JY.Person[JY.Base["����" .. i]]["����"] = 0
		end
	end
end

function instruct_23(personid, value)
	JY.Person[personid]["�ö�����"] = value
	AddPersonAttrib(personid, "�ö�����", 0)
end

function instruct_24()
	instruct_test("ָ��24����")
end

--��ͷ�ƶ�
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
	local v = JY.Person[personid]["Ʒ��"]
	if vmin <= v and v <= vmax then
		return true
	else
		return false
	end
end

function instruct_29(personid, vmin, vmax)
	local v = JY.Person[personid]["������"]
	if vmin <= v and v <= vmax then
		return true
	else
		return false
	end
end

--�����Զ��ƶ�
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
  x = JY.Base["��X1"] + CC.DirectX[direct + 1]
  y = JY.Base["��Y1"] + CC.DirectY[direct + 1]
  JY.Base["�˷���"] = direct
  JY.MyPic = GetMyPic()
  DtoSMap()
  if SceneCanPass(x, y) == true then
    JY.Base["��X1"] = x
    JY.Base["��Y1"] = y
  end
  JY.Base["��X1"] = limitX(JY.Base["��X1"], 1, CC.SWidth - 2)
  JY.Base["��Y1"] = limitX(JY.Base["��Y1"], 1, CC.SHeight - 2)
  DrawSMap()
  ShowScreen()
  return 1
end

function instruct_30_sub(direct)
  local x, y = nil, nil
  local d_pass = GetS(JY.SubScene, JY.Base["��X1"], JY.Base["��Y1"], 3)

  if d_pass >= 0 and d_pass ~= JY.OldDPass then
    EventExecute(d_pass, 3)
    JY.OldDPass = d_pass
    JY.oldSMapX = -1
    JY.oldSMapY = -1
    JY.D_Valid = nil
  end

  JY.OldDPass = -1
  local isout = 0
  if (((JY.Scene[JY.SubScene]["����X1"] == JY.Base["��X1"] and JY.Scene[JY.SubScene]["����Y1"] == JY.Base["��Y1"]) or JY.Scene[JY.SubScene]["����X2"] ~= JY.Base["��X1"] or JY.Scene[JY.SubScene]["����Y2"] == JY.Base["��Y1"] or JY.Scene[JY.SubScene]["����X3"] == JY.Base["��X1"] and JY.Scene[JY.SubScene]["����Y3"] == JY.Base["��Y1"])) then
    isout = 1
  end
  if isout == 1 then
    JY.Status = GAME_MMAP
    --lib.PicInit()
    CleanMemory()
    lib.ShowSlow(20, 1)
    if JY.MmapMusic < 0 then
      JY.MmapMusic = JY.Scene[JY.SubScene]["��������"]
    end
    Init_MMap()
    JY.SubScene = -1
    JY.oldSMapX = -1
    JY.oldSMapY = -1
    lib.DrawMMap(JY.Base["��X"], JY.Base["��Y"], GetMyPic())
    lib.ShowSlow(20, 0)
    lib.GetKey()
    return 
  end
  if JY.Scene[JY.SubScene]["��ת����"] >= 0 and JY.Base["��X1"] == JY.Scene[JY.SubScene]["��ת��X1"] and JY.Base["��Y1"] == JY.Scene[JY.SubScene]["��ת��Y1"] then
    JY.SubScene = JY.Scene[JY.SubScene]["��ת����"]
    lib.ShowSlow(20, 1)
    if JY.Scene[JY.SubScene]["�⾰���X1"] == 0 and JY.Scene[JY.SubScene]["�⾰���Y1"] == 0 then
      JY.Base["��X1"] = JY.Scene[JY.SubScene]["���X"]
      JY.Base["��Y1"] = JY.Scene[JY.SubScene]["���Y"]
    else
      JY.Base["��X1"] = JY.Scene[JY.SubScene]["��ת��X2"]
      JY.Base["��Y1"] = JY.Scene[JY.SubScene]["��ת��Y2"]
    end
    Init_SMap(1)
    return 
  end
  AddMyCurrentPic()
  x = JY.Base["��X1"] + CC.DirectX[direct + 1]
  y = JY.Base["��Y1"] + CC.DirectY[direct + 1]
  JY.Base["�˷���"] = direct
  JY.MyPic = GetMyPic()
  DtoSMap()
  if SceneCanPass(x, y) == true then
    JY.Base["��X1"] = x
    JY.Base["��Y1"] = y
  end
  JY.Base["��X1"] = limitX(JY.Base["��X1"], 1, CC.SWidth - 2)
  JY.Base["��Y1"] = limitX(JY.Base["��Y1"], 1, CC.SHeight - 2)
  DrawSMap()
  ShowScreen()
  return 1
end

--����Ǯ�Ƿ��㹻
function instruct_31(num)
	local r = false
    if num <= CC.Gold then 
        return true    
    end
	return r
end

--���ӣ�������Ʒ�ĺ���
function instruct_32(thingid, num)
	local p = 1
	--���ȿ��ƻ�ȡ����������30000�Զ���30000
	for i = 1, CC.MyThingNum do
		if JY.Base["��Ʒ" .. i] == thingid then
			if thingid == 174 then 
				--JY.Base["��Ʒ����" .. i] = 0
				p = i
				break;
			else
			    --�Ѿ���һ����������Ʒ��������֮�󳬹�30000����30000��
			    if (JY.Base["��Ʒ����" .. i] + num) > 30000 then
				    JY.Base["��Ʒ����" .. i] = 30000
			    else
				    JY.Base["��Ʒ����" .. i] = JY.Base["��Ʒ����" .. i] + num
			    end
			    p = i
			    break;
			end	
		elseif JY.Base["��Ʒ" .. i] == -1 then
			if thingid == 174 then 
				JY.Base["��Ʒ" .. i] = thingid
				--JY.Base["��Ʒ����" .. i] = 0
				p = i
				break;
			else	
			    JY.Base["��Ʒ" .. i] = thingid
			    JY.Base["��Ʒ����" .. i] = num
			    p = i
			    break;
			end
		end
	end
	
	--��ȡ������ʱ��ˢ��������ʾ
	if thingid == CC.MoneyID then
		CC.Gold = CC.Gold + num--JY.Base["��Ʒ����" .. p]
		if CC.Gold < 0 then 
			CC.Gold = 0
		end
	end
  
  
	--������飬����15������
	--��õ�ʱ�������
	if num > 0 and thingid >= CC.BookStart and thingid < CC.BookStart + CC.BookNum then
		JY.Person[0]["����"] = JY.Person[0]["����"] + 15;
		JY.Base["��������"] = JY.Base["��������"] + 1
		--�޾Ʋ�������520�������Ʒ���ж�����ժȡ���������
		--�滻�������ͼ
		JY.Person[520]["Ʒ��"] = JY.Person[520]["Ʒ��"] + 1
		--���Ѿ��ֹ���������£�����������521�������Ʒ���ж��Ƿ��Ѵ��������¼�
		if JY.Person[521]["Ʒ��"] == 1 then
			addevent(70, 65, 1, 4119, 1, 2366*2)
		end

	end
	
	if JY.Base["��Ʒ����" .. p] <= 0 then
        if thingid == 174 then
            if CC.Gold <= 0 then
                for i = p + 1, CC.MyThingNum do
                    JY.Base["��Ʒ" .. i - 1] = JY.Base["��Ʒ" .. i]
                    JY.Base["��Ʒ����" .. i - 1] = JY.Base["��Ʒ����" .. i]
                end
                JY.Base["��Ʒ" .. CC.MyThingNum] = -1
                JY.Base["��Ʒ����" .. CC.MyThingNum] = 0
            end    
		else
		    for i = p + 1, CC.MyThingNum do
		        JY.Base["��Ʒ" .. i - 1] = JY.Base["��Ʒ" .. i]
		        JY.Base["��Ʒ����" .. i - 1] = JY.Base["��Ʒ����" .. i]
		    end
			JY.Base["��Ʒ" .. CC.MyThingNum] = -1
			JY.Base["��Ʒ����" .. CC.MyThingNum] = 0
		end
	end
end

--����ѧ���书
function instruct_33(personid, wugongid, flag)
	local xwperson;	--�ж�Ҫϴ�书����
	xwperson = personid

	local add = 0
	for i = 1, JY.Base["�书����"] do
		if JY.Person[xwperson]["�书" .. i] == 0 then
			JY.Person[xwperson]["�书" .. i] = wugongid
			JY.Person[xwperson]["�书�ȼ�" .. i] = 0
			add = 1		
			break;
		end
	end
	if add == 0 then
		JY.Person[xwperson]["�书"..JY.Base["�书����"]] = wugongid
		JY.Person[xwperson]["�书�ȼ�"..JY.Base["�书����"]] = 0
	end
    if isteam(xwperson) then 
        Hp_Max(xwperson)
    end
	if personid == JY.Base["����"] or personid == 0 then
		xwperson = 0
		local add = 0
		for i = 1, JY.Base["�书����"] do
			if JY.Person[xwperson]["�书" .. i] == 0 then
				JY.Person[xwperson]["�书" .. i] = wugongid
				JY.Person[xwperson]["�书�ȼ�" .. i] = 0
				add = 1		
				break;
			end
		end
		if add == 0 then
			JY.Person[xwperson]["�书"..JY.Base["�书����"]] = wugongid
			JY.Person[xwperson]["�书�ȼ�"..JY.Base["�书����"]] = 0
		end
        Hp_Max(xwperson)
	end
	
	for i,v in pairs(CC.Copy) do 
		if v == personid then
			xwperson = i
            local add = 0
            for i = 1, JY.Base["�书����"] do
                if JY.Person[xwperson]["�书" .. i] == 0 then
                    JY.Person[xwperson]["�书" .. i] = wugongid
                    JY.Person[xwperson]["�书�ȼ�" .. i] = 0
                    add = 1		
                    break;
                end
            end
            if add == 0 then
                JY.Person[xwperson]["�书"..JY.Base["�书����"]] = wugongid
                JY.Person[xwperson]["�书�ȼ�"..JY.Base["�书����"]] = 0
            end
			break
		end
	end
	
	if flag == 0 then
		DrawStrBoxWaitKey(string.format("%s ѧ���书 %s", JY.Person[xwperson]["����"], JY.Wugong[wugongid]["����"]), C_ORANGE, CC.DefaultFont)
	end
	
end

--�ı�����
function instruct_34(id, value)
	local xwperson;	--�ж�����
	if id == JY.Base["����"] then
		xwperson = 0
	else
		xwperson = id
	end
	local add, str = AddPersonAttrib(xwperson, "����", value)
	DrawStrBoxWaitKey(JY.Person[xwperson]["����"] .. str, C_ORANGE, CC.DefaultFont)
end

--ϴ�书����
function instruct_35(personid, id, wugongid, wugonglevel)
	local xwperson;	--�ж�Ҫϴ�书����
	xwperson = personid
	--��ϴ�����书���Զ��б����
	if JY.Person[xwperson]["�书" .. id + 1] > 0 then
		if JY.Person[xwperson]["�书" .. id + 1] == JY.Person[xwperson]["����ʹ��"] then
			JY.Person[xwperson]["����ʹ��"] = 0
		elseif JY.Person[xwperson]["�书" .. id + 1] == JY.Person[xwperson]["�����ڹ�"] then
			JY.Person[xwperson]["�����ڹ�"] = 0
		elseif JY.Person[xwperson]["�书" .. id + 1] == JY.Person[xwperson]["�����Ṧ"] then
			JY.Person[xwperson]["�����Ṧ"] = 0
		end
	end
    if isteam(xwperson) then 
        Hp_Max(xwperson)
    end
	JY.Person[xwperson]["�书" .. id + 1] = wugongid
	JY.Person[xwperson]["�书�ȼ�" .. id + 1] = wugonglevel
	
	if personid == JY.Base["����"] or personid == 0 then
		xwperson = 0
		--��ϴ�����书���Զ��б����
		if JY.Person[xwperson]["�书" .. id + 1] > 0 then
			if JY.Person[xwperson]["�书" .. id + 1] == JY.Person[xwperson]["����ʹ��"] then
				JY.Person[xwperson]["����ʹ��"] = 0
			elseif JY.Person[xwperson]["�书" .. id + 1] == JY.Person[xwperson]["�����ڹ�"] then
				JY.Person[xwperson]["�����ڹ�"] = 0
			elseif JY.Person[xwperson]["�书" .. id + 1] == JY.Person[xwperson]["�����Ṧ"] then
				JY.Person[xwperson]["�����Ṧ"] = 0
			end
		end
		JY.Person[xwperson]["�书" .. id + 1] = wugongid
		JY.Person[xwperson]["�书�ȼ�" .. id + 1] = wugonglevel
        Hp_Max(xwperson)
	end
	
	for i,v in pairs(CC.Copy) do 
		if v == personid then
		--if CC.Copy[personid] ~= nil then 
			xwperson = i
			--��ϴ�����书���Զ��б����
			if JY.Person[xwperson]["�书" .. id + 1] > 0 then
				if JY.Person[xwperson]["�书" .. id + 1] == JY.Person[xwperson]["����ʹ��"] then
					JY.Person[xwperson]["����ʹ��"] = 0
				elseif JY.Person[xwperson]["�书" .. id + 1] == JY.Person[xwperson]["�����ڹ�"] then
					JY.Person[xwperson]["�����ڹ�"] = 0
				elseif JY.Person[xwperson]["�书" .. id + 1] == JY.Person[xwperson]["�����Ṧ"] then
					JY.Person[xwperson]["�����Ṧ"] = 0
				end
			end
			JY.Person[xwperson]["�书" .. id + 1] = wugongid
			JY.Person[xwperson]["�书�ȼ�" .. id + 1] = wugonglevel
			break
		end
	end
    
end

function instruct_36(sex)
	if JY.Person[0]["�Ա�"] == sex then
		return true
	else
		return false
	end
end

--�޾Ʋ������Ӽ�������ʾ
function instruct_37(v)
	AddPersonAttrib(0, "Ʒ��", v)
	if v < 0 then
		for i = 1, 15 do
			if JY.Restart == 1 then
				break
			end
			local y_off = i * 2 + CC.DefaultFont + CC.RowPixel
			DrawString(CC.ScreenW/2-CC.DefaultFont*5, CC.ScreenH/4 - CC.DefaultFont - CC.RowPixel + y_off, "��ĵ���ָ���½���"..-v.."��", M_DeepSkyBlue, CC.DefaultFont)
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
			DrawString(CC.ScreenW/2-CC.DefaultFont*5, CC.ScreenH/4 + 30 + CC.DefaultFont + CC.RowPixel - y_off, "��ĵ���ָ��������"..v.."��", PinkRed, CC.DefaultFont)
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
	JY.Scene[sceneid]["��������"] = 0
end

function instruct_40(v)
	JY.Base["�˷���"] = v
	JY.MyPic = GetMyPic()
end

function instruct_41(personid, thingid, num)
	local k = 0
	for i = 1, 4 do
		if JY.Person[personid]["Я����Ʒ" .. i] == thingid then
			JY.Person[personid]["Я����Ʒ����" .. i] = JY.Person[personid]["Я����Ʒ����" .. i] + num
			k = i
			break;
		end
	end
	if k > 0 and JY.Person[personid]["Я����Ʒ����" .. k] <= 0 then
		JY.Person[personid]["Я����Ʒ" .. k] = -1
	end
	if k == 0 then
		for i = 1, 4 do
			if JY.Person[personid]["Я����Ʒ" .. i] == -1 then
				JY.Person[personid]["Я����Ʒ" .. i] = thingid
				JY.Person[personid]["Я����Ʒ����" .. i] = num
				break;
			end
		end
	end
end

function instruct_42()
	local r = false
	for i = 1, CC.TeamNum do
		if JY.Base["����" .. i] >= 0 and JY.Person[JY.Base["����" .. i]]["�Ա�"] == 1 then
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

--����
function instruct_45(id, value)
	local xwperson;	--�ж�Ҫϴ�书����
	if id == JY.Base["����"] then
		xwperson = 0
	else
		xwperson = id
	end
	local add, str = AddPersonAttrib(xwperson, "�Ṧ", value)
end

--����
function instruct_46(id, value)
	local xwperson;	--�ж�Ҫϴ�书����
	if id == JY.Base["����"] then
		xwperson = 0
	else
		xwperson = id
	end
	local add, str = AddPersonAttrib(xwperson, "�������ֵ", value)
	AddPersonAttrib(xwperson, "����", 0)
end

--�ӹ�
function instruct_47(id, value)
	local xwperson;	--�ж�Ҫϴ�书����
	if id == JY.Base["����"] then
		xwperson = 0
	else
		xwperson = id
	end
	local add, str = AddPersonAttrib(xwperson, "������", value)
end

--�ӷ�
function add_deffense(id, value)
	local xwperson;	--�ж�Ҫϴ�书����
	if id == JY.Base["����"] then
		xwperson = 0
	else
		xwperson = id
	end
	local add, str = AddPersonAttrib(xwperson, "������", value)
end

--��Ѫ
function instruct_48(id, value)
	local xwperson;	--�ж�Ҫϴ�书����
	if id == JY.Base["����"] then
		xwperson = 0
	else
		xwperson = id
	end
	local add, str = AddPersonAttrib(xwperson, "�������ֵ", value)
	AddPersonAttrib(xwperson, "����", value)
end

--ϴ����
function instruct_49(personid, value)
	local xwperson;	--�ж�Ҫϴ��������
	if personid == JY.Base["����"] then
		xwperson = 0
	else
		xwperson = personid
	end
	JY.Person[xwperson]["��������"] = value
    JY.Person[personid]["��������"] = value
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
	DrawStrBoxWaitKey(string.format("�����ڵ�Ʒ��ָ��Ϊ: %d", JY.Person[0]["Ʒ��"]), C_ORANGE, CC.DefaultFont)
end

function instruct_53()
	DrawStrBoxWaitKey(string.format("�����ڵ�����ָ��Ϊ: %d", JY.Person[0]["����"]), C_ORANGE, CC.DefaultFont)
end

function instruct_54()
	for i = 0, JY.SceneNum - 1 do
		JY.Scene[i]["��������"] = 0
	end
	JY.Scene[2]["��������"] = 2
	JY.Scene[38]["��������"] = 2
	JY.Scene[75]["��������"] = 1
	JY.Scene[80]["��������"] = 1
end

function instruct_55(id, num)
	if GetD(JY.SubScene, id, 2) == num then
		return true
	else
		return false
	end
end

function instruct_56(v)
	--JY.Person[0]["����"] = JY.Person[0]["����"] + v
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
      instruct_1(2854 + warnum, WAR.Data["����1"], 0)
      instruct_0()
      if WarMain(warnum + startwar, 0) == true then
        instruct_0()
        instruct_13()
        TalkEx("������λǰ���ϴͽ̣�", 0, 1)
        instruct_0()
      else
        instruct_15()
        return 
      end
    end
    if i < group - 1 then
      TalkEx(JY.Person[0]["���"].."����ս������*������Ϣ��ս��", 70, 0)
      instruct_0()
      instruct_14()
      lib.Delay(300)
      if JY.Person[0]["���˳̶�"] < 50 and JY.Person[0]["�ж��̶�"] <= 0 then
        JY.Person[0]["���˳̶�"] = 0
        AddPersonAttrib(0, "����", math.huge)
        AddPersonAttrib(0, "����", math.huge)
        AddPersonAttrib(0, "����", math.huge)
      end
      instruct_13()
      TalkEx("���Ѿ���Ϣ���ˣ�*��˭Ҫ���ϣ�", 0, 1)
      instruct_0()
    end
  end
  TalkEx("��������˭��**��������*��������***û��������", 0, 1)
  instruct_0()
  TalkEx("�����û����Ҫ��������λ*"..JY.Person[0]["���"].."��ս���������书����*��һ֮������������֮λ��*������λ"..JY.Person[0]["���"].."��ã�***������������*������������*������������*�ã���ϲ"..JY.Person[0]["���"].."������������*֮λ����"..JY.Person[0]["���"].."��ã������*���������ȡ�Ҳ���㱣�ܣ�", 70, 0)
  instruct_0()
  TalkEx("��ϲ"..JY.Person[0]["���"].."��", 12, 0)
  instruct_0()
  TalkEx("С�ֵܣ���ϲ�㣡", 64, 4)
  instruct_0()
  TalkEx("�ã���������ִ�ᵽ����*Բ��������ϣ�������λ��*��ͬ�����ٵ��һ�ɽһ�Σ�", 19, 0)
  instruct_0()
  instruct_14()
  for i = 24, 72 do
    instruct_3(-2, i, 0, 0, -1, -1, -1, -1, -1, -1, -2, -2, -2)
  end
  instruct_0()
  instruct_13()
  TalkEx("����ǧ����࣬����춴��*Ⱥ�ۣ��õ�����������֮λ*�����ȣ�*���ǡ�ʥ�á������أ�*Ϊʲ��û�˸����ң��ѵ���*�Ҷ���֪����*�������е����ˣ�", 0, 1)
  instruct_0()
  instruct_2(143, 1)
end

--ȫ���������
function instruct_59()
	for i = CC.TeamNum, 2, -1 do
		if JY.Base["����" .. i] >= 0 then
			instruct_21(JY.Base["����" .. i])
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

--ͨ�غ���
function instruct_62(id1, startnum1, endnum1, id2, startnum2, endnum2)
	--JY.MyPic = -1
	--instruct_44(id1, startnum1, endnum1, id2, startnum2, endnum2)
	--ShowScreen()
	lib.Delay(200)
	say("������Ϸ�͵������ˣ�ѡ�����¿�ʼ�ɽ�����һ��Ŀ����Ϸ��", 260, 5, "�޾Ʋ���")
    

	lib.PlayMPEG("ending.mp4",VK_ESCAPE)
	
    os.remove(CONFIG.DataPath..'TgJl')
	--tgsave()
    
	--������Ŀ
	local x = AddZM()

	if JY.Base["��Ŀ"] == CC.Week and CC.Jl == 0 then
		CC.Sp = CC.Sp + x
		CC.Jl = 1
		DrawStrBoxWaitKey("��á���������£ϡ���"..x, C_ORANGE, CC.DefaultFont, 2)
	end

	tgsave()
	
	Cls()
	lib.FillColor(0, 0, CC.ScreenW, CC.ScreenH, C_BLACK)
	DrawString(350, 200, "Ƭβ�����Ĵ�ɽ��", C_WHITE, CC.DefaultFont)
	DrawString(375, 300, "�ݳ����Ϸ���", C_WHITE, CC.DefaultFont)
	ShowScreen()
  
	PlayMIDI(116)
	local stime = 0
	local a = 1
	local lyrics = {
	{530,"�� �����Сʱ ���Ĵ�ĥ"},
	{560,"����ϷΪ��ʲô��Ц��"},
	{590,"ǰ��Ԫ�Ϲ��������"},
	{610,"��Դ�������ֿɵ�"},
	{640,"�ҵ� �����˵� ȴ�κ� ������������"},
	{680,"�����Ѳ� ��ɵǮ�� ˭��������Ա���ʸ�"},
	{730,"��̳�� ����Ҫͳһ ��������ȥ"},
	{810,"���Ǯ��** �Ҽǵ��� ��������һ��"},
	{920,"���� ���� ��������"},
	{940,"��Ϯ���Ĵ�����Ĳ���"},
	{970,"���� ���� ��������"},
	{1000,"ֻҪ�������Ǿ����ҵ�"},
	{1030,"���� ���� ��������"},
	{1050,"������ɫ���ǵ�������"},
	{1070,"���� ���� ��������"},
	{1100,"���Ǯ���վ�Ҫ������"},
	{1220,"�� ��ı�ƻ��� ����̳����"},
	{1250,"������ Ӯ��ʲô ɾ���"},
	{1280,"����˭�� ԭ�������"},
	{1300,"��Դ�� �ұ��Ƴ�Ϯ"},
	{1320,"�ҵ���Ϸ���� ȴ�κ�"},
	{1350,"ͽ������һ��"},
	{1370,"û������ ��������"},
	{1390,"˭��������ҵ��ʸ�"},
	{1410,"С���� ��������ȥ �峺Ǯ����"},
	{1510,"���Ǯ��** �Ҽǵ��� �����Ļ���ȥ"},
	{1610,"���� ���� ��������"},
	{1630,"�������Ĵ������ʵ��"},
	{1660,"���� ���� ��������"},
	{1680,"������˵��û��������"},
	{1710,"���� ���� ��������"},
	{1730,"��������������������"},
	{1760,"���� ���� ��������"},
	{1780,"���Ǯ���վ�Ҫ������"},
	{2100,"���� ���� ��������"},
	{2120,"��Ϯ���Ĵ�����Ĳ���"},
	{2140,"���� ���� ��������"},
	{2170,"ֻҪ�������Ǿ����ҵ�"},
	{2190,"���� ���� ��������"},
	{2210,"������ɫ���ǵ�������"},
	{2240,"���� ���� ��������"},
	{2260,"���Ǯ���վ�Ҫ������"},
	{2310,"��̳�� ����Ҫͳһ ��������ȥ"},
	{2390,"���Ǯ��** �Ҽǵ��� ��������һ��"},
	{2700,"ȫ���� ��л֧��"},
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
			DrawString(350, 200, "Ƭβ�����Ĵ�ɽ��", C_WHITE, size)
			DrawString(375, 300, "�ݳ����Ϸ���", C_WHITE, size)
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
	JY.Person[personid]["�Ա�"] = sex
end

--�޾Ʋ������̵�����
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
	TalkEx("��λС�磬������ʲô��Ҫ�ģ�С�����Ķ�����Ǯ���Թ�����", headid, 0,"�̼�")
	local menu = {}
	for i = 1, 6 do
		local thingid = JY.Shop[id]["��Ʒ" .. i]
		if thingid ~= -1 then
			menu[i] = {}
			menu[i][1] = string.format("%-12s %5d", JY.Thing[thingid]["����"], JY.Shop[id]["��Ʒ�۸�" .. i])
			menu[i][2] = nil
			if JY.Shop[id]["��Ʒ����" .. i] > 0 then
			  menu[i][3] = 1
			else
			  menu[i][3] = 0
			end
		end
	end

	--3����ǰû�л�Ԫ
	if JY.Base["��������"] < 3 and id == 0 then
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
		if instruct_31(JY.Shop[id]["��Ʒ�۸�" .. r]) == false then
			TalkEx("�ǳ���Ǹ�������ϵ�Ǯ�ƺ�������", headid, 0,"�̼�")
		else
			JY.Shop[id]["��Ʒ����" .. r] = JY.Shop[id]["��Ʒ����" .. r] - 1
			instruct_32(CC.MoneyID, -JY.Shop[id]["��Ʒ�۸�" .. r])
			instruct_32(JY.Shop[id]["��Ʒ" .. r], 1)
			TalkEx(JY.Person[0]["���"].."����С��Ķ�������֤������ڡ�", headid, 0,"�̼�")
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


--ѡ���ÿ��ѡ����߿�
--title ����
--str ���� *����
--button ѡ��
--num ѡ��ĸ�����һ��Ҫ��ѡ���Ӧ����
--headid ��ʾ��������ߵ���ͼ���������ֵ����ʾ��ͼ
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
	
	local yczj = 0	--���������żһ�
	
	if title == "����ѡ��" then
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
				--�޾Ʋ���������pass in select��������ѡ�񲻵�������·��ز����ڵ�ѡ��
				select = between(mx, select);
				if select > 0 and select <= num and ktype==3 then
					break
				end
			end
		end
		--���������żһ�
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
				--�޾Ʋ���������pass in select��������ѡ�񲻵�������·��ز����ڵ�ѡ��
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

--��ʾ���߿������
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
	--���س�����ͼ�ļ�
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
	PlayMIDI(JY.Scene[JY.SubScene]["��������"])
	JY.oldSMapX = -1
	JY.oldSMapY = -1
	JY.SubSceneX = 0
	JY.SubSceneY = 0
	JY.OldDPass = -1
	JY.D_Valid = nil
	DrawSMap()
	lib.GetKey()
	if showname == 1 then
		DrawStrBox(-1, 10, JY.Scene[JY.SubScene]["����"], C_WHITE, CC.DefaultFont)
		ShowScreen()
		WaitKey()
	end
  
	AutoMoveTab = {[0] = 0}
end

--�¶Ի���ʽ
--��������ַ�
--��ͣ����������������
--������ɫ��=red��=gold��=black��=white��=orange
--�����ַ���ʾ�ٶȣ�,��,��,��,��,��,��,��,��,��
--����������ӣģ�
--���ƻ��У�   ��ҳ��
--�δ����Լ����������

function say(s,pid,flag,name)          --�����¶Ի�
	if JY.Restart == 1 then
		return
	end
    local picw=130;       --���ͷ��ͼƬ���
	local pich=130;
	local talkxnum=20;         --�Ի�һ������
	local talkynum=3;          --�Ի�����
	local dx=2;
	local dy=2;
    local boxpicw=picw+10;
	local boxpich=pich+10;
	local boxtalkw=talkxnum*CC.DefaultFont+10;
	local boxtalkh=boxpich-27;
	local headid = pid;
	if name == nil then 
		headid = JY.Person[pid]["������"]
	end
	name=name or JY.Person[pid]["����"]
    local talkBorder=(pich-talkynum*CC.DefaultFont)/(talkynum+1)-5;

	--��ʾͷ��ͶԻ�������
    local xy={ [0]={headx=dx,heady=dy,
	                talkx=dx+boxpicw+2,talky=dy+27,
					namex=dx+boxpicw+2,namey=dy,
					showhead=1},--����
                   {headx=CC.ScreenW-1-dx-boxpicw-80,heady=CC.ScreenH-dy-boxpich+40,
				    talkx=CC.ScreenW-1-dx-boxpicw-boxtalkw-2-150,talky= CC.ScreenH-dy-boxpich+27,
					namex=CC.ScreenW-1-dx-boxpicw-26,namey=CC.ScreenH-dy-boxpich+100,
					showhead=1},--����
                   {headx=dx,heady=dy,
				   talkx=dx+boxpicw-43,talky=dy+27,
					namex=dx+boxpicw+2,namey=dy,
				   showhead=0},--����
                   {headx=CC.ScreenW-1-dx-boxpicw,heady=CC.ScreenH-dy-boxpich,
				   talkx=CC.ScreenW-1-dx-boxpicw-boxtalkw-2,talky= CC.ScreenH-dy-boxpich+27,
					namex=CC.ScreenW-1-dx-boxpicw-96,namey=CC.ScreenH-dy-boxpich,
					showhead=1},
                   {headx=CC.ScreenW-1-dx-boxpicw,heady=dy,
				    talkx=CC.ScreenW-1-dx-boxpicw-boxtalkw-2,talky=dy+27,
					namex=CC.ScreenW-1-dx-boxpicw-96,namey=dy,
					showhead=1},--����
                   {headx=dx+68,heady=CC.ScreenH-dy-boxpich+40,
				   talkx=dx+boxpicw+2+160,talky=CC.ScreenH-dy-boxpich+27,
					namex=dx+boxpicw-50,namey=CC.ScreenH-dy-boxpich+100,
				   showhead=1}, --����
			}

	if pid==0 then
	   if name ~= JY.Person[pid]["����"] then 
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
		local T1={"��","��","��","��","��","��","��","��","��","��"}
		local T2={{"��",C_RED},{"��",C_GOLD},{"��",C_BLACK},{"��",C_WHITE},{"��",C_ORANGE},{"��",LimeGreen},{"��",M_DeepSkyBlue},{"��",LightPurple}}
		local T3={{"��",CC.FontNameSong},{"��",CC.FontNameHei},{"��",CC.FontName}}
		--�����������Բ�ͬ����ͬһ����ʾ����Ҫ΢�������꣬�Լ��ֺ�
		--��Ĭ�ϵ�����Ϊ��׼�����������ƣ�ϸ��������
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
			--str='��'
			s=string.sub(s,2,-1)
		else
			if string.byte(s,1,1) > 127 then		--�жϵ�˫�ַ�
				str=string.sub(s,1,2)
				s=string.sub(s,3,-1)
			else
				str=string.sub(s,1,1)
				s=string.sub(s,2,-1)
			end
		end
		--��ʼ�����߼�
		if str=='*' then
		elseif str=="��" then
			cx=0
			cy=cy+1
			if cy==3 then
				cy=0
				page=0
			end
		elseif str=="��" then
			cx=0
			cy=0
			page=0
		elseif str=="��" then
			ShowScreen();
			--WaitKey();
			lib.Delay(50)
		elseif str=="��" then
			ShowScreen();
			WaitKey();
			--lib.Delay(50)
		elseif str=="��" then
			s=JY.Person[pid]["����"]..s
		elseif str=="��" then
			s=JY.Person[0]["����"]..s
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
		--�����ҳ������ʾ���ȴ�����
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

--�ָ��ַ���
--szFullString�ַ���
--szSeparator�ָ��
--��������,�ָ������
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

--����һ���������İ�ɫ�����Ľǰ���
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

--�����Ľǰ����ķ���
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

--��ʼ������ͼ
function Init_MMap()
	--lib.PicInit()
	lib.LoadMMap(CC.MMapFile[1], CC.MMapFile[2], CC.MMapFile[3], CC.MMapFile[4], CC.MMapFile[5], CC.MWidth, CC.MHeight, JY.Base["��X"], JY.Base["��Y"])
  
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

--�Զ���Ľ����ӳ����ĺ���
--��Ҫ������ӳ������
--x�����ӳ����������X���꣬����-1��Ĭ��Ϊ���X
--y�����ӳ����������Y���꣬����-1��Ĭ��Ϊ���Y
--direct������Եķ���
function My_Enter_SubScene(sceneid,x,y,direct)
	--�Ӵ��ͼ�����ӳ���ǰ�Զ����浽10�ŵ�
	if JY.Status == GAME_MMAP then
		SaveRecord(10)
	end
	JY.SubScene = sceneid;
	local flag = 1;   --�Ƿ��Զ����xy����, 0�ǣ�1��
	if x == -1 and y == -1 then
		JY.Base["��X1"]=JY.Scene[sceneid]["���X"];
		JY.Base["��Y1"]=JY.Scene[sceneid]["���Y"];
	else
		JY.Base["��X1"] = x;
		JY.Base["��Y1"] = y;
		flag = 0;
	end
	
	if direct > -1 then
		JY.Base["�˷���"] = direct;
	end
 			
	
	if JY.Status == GAME_MMAP then
		CleanMemory();
		--lib.UnloadMMap();
	end
	lib.ShowSlow(20,1)

	JY.Status=GAME_SMAP;  --�ı�״̬
	JY.MmapMusic=-1;

	JY.Base["�˴�"]=0;
	JY.MyPic=GetMyPic(); 
  
	--�⾰����Ǹ��ѵ㣬��Щ�ӳ�����ͨ����ת�ķ�ʽ����ģ���Ҫ�ж�
	--����Ŀǰ���ֻ����һ���ӳ�����ת�����Բ���Ҫ����ѭ���ж�
	local sid = JY.Scene[sceneid]["��ת����"];
  
	if sid < 0 or (JY.Scene[sid]["�⾰���X1"] <= 0 and JY.Scene[sid]["�⾰���Y1"] <= 0) then
		JY.Base["��X"] = JY.Scene[sceneid]["�⾰���X1"];  --�ı���ӳ������XY����
		JY.Base["��Y"] = JY.Scene[sceneid]["�⾰���Y1"];
	else
		JY.Base["��X"] = JY.Scene[sid]["�⾰���X1"];  --�ı���ӳ������XY����
		JY.Base["��Y"] = JY.Scene[sid]["�⾰���Y1"];
	end

    
	Init_SMap(flag);  --���³�ʼ����ͼ
   -- lib.LoadPNGPath('./data/smap',0,-1,100)
	if flag == 0 then    --������Զ���λ�ã��ȴ��͵��Ǹ�λ�ã�����ʾ��������
		DrawStrBox(-1,10,JY.Scene[JY.SubScene]["����"],C_WHITE,CC.DefaultFont);
		ShowScreen();
		WaitKey();
	end
  
	Cls();	
end

--������Ϣ
function JYZTB(id,pid)
	ShowStatus() 
	end

function QZXS(s)
	DrawStrBoxWaitKey(s, C_GOLD, CC.DefaultFont)
end

--��ʾ�书������
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

--�����ͼ����
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


---�Ծ��ν�����Ļ����
--���ؼ��ú�ľ��Σ����������Ļ�����ؿ�
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

--������ͼ�ı��γɵ�Clip�ü�
--(dx1,dy1) ����ͼ�ͻ�ͼ���ĵ������ƫ�ơ��ڳ����У��ӽǲ�ͬ�����Ƕ�ʱ�õ�
--pic1 �ɵ���ͼ���
--id1 ��ͼ�ļ����ر��
--(dx2,dy2) ����ͼ�ͻ�ͼ���ĵ��ƫ��
--pic2 �ɵ���ͼ���
--id2 ��ͼ�ļ����ر��
--���أ��ü����� {x1,y1,x2,y2}
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

--�ϲ�����
function MergeRect(r1, r2)
  local res = {}
  res.x1 = math.min(r1.x1, r2.x1)
  res.y1 = math.min(r1.y1, r2.y1)
  res.x2 = math.max(r1.x2, r2.x2)
  res.y2 = math.max(r1.y2, r2.y2)
  return res
end



--��ʾ��Ӱ�ַ���
--���x,y��-1����ô��ʾ����Ļ�м�
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

--�޾Ʋ�������������ATM������������UI
function InputNum(str, minNum, maxNum, isEsc)
	local size = CC.DefaultFont;
	local b_space = size+CC.RowPixel
	local x=(CC.ScreenW-size*9-2*CC.MenuBorderPixel)/2;
	local y=(CC.ScreenH-size*9-2*CC.MenuBorderPixel)/2;
	local w=size*9+2*CC.MenuBorderPixel;
	local h=(b_space+CC.RowPixel*2)*6;
	local functional_button = {{name="ȷ��"},{name="���"},{name="���"},{name="ɾ��"},{name=0},{name=1},{name=2},{name=3},{name=4},{name=5},{name=6},{name=7},{name=8},{name=9}};
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

--�����ַ������Ƿ�����ɫ��־
--��DrawTxt��������
function AnalyString(str)
	local tlen = 0;
	local strcolor = {}
	--����Ƿ�����ɫ��־
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
				--����Ѿ�û��������ɫ��־��ֱ�������˳�ѭ��
				if f1 == nil then
					table.insert(strcolor, {str, nil});
					break;
				end
			else		--����Ҳ���������־��ֱ�������˳�ѭ��
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

--�浵�б�
function SaveList()
	--��ȡR*.idx�ļ�
	local idxData = Byte.create(24)
	Byte.loadfile(idxData, CC.R_IDXFilename[0], 0, 24)
	local idx = {}
	idx[0] = 0
	for i = 1, 6 do
		idx[i] = Byte.get32(idxData, 4 * (i - 1))
	end

	local table_struct = {}
	table_struct["����"]={idx[1]+8,2,10}
	table_struct["����"]={idx[1]+122,0,2}
  
	table_struct["����"]={idx[0]+2,0,2}
	table_struct["�Ѷ�"]={idx[0]+24,0,2}
	
	table_struct["��׼"]={idx[0]+26,0,2}
	table_struct["����"]={idx[0]+28,0,2}
	table_struct["����"]={idx[0]+30,0,2}
	
	table_struct["��������"]={idx[0]+36,0,2}
	table_struct["�书����"]={idx[0]+38,0,2}
	table_struct["��������"]={idx[3]+2,2,10}

	--���Ǳ��
	table_struct["����1"]={idx[0]+52,0,2}
  
	--table_struct[WZ7]={idx[2]+88,0,2}
  
	--ʱ�䱣���ڳ���������
	--table_struct["��Ϸʱ��"]={(CC.SWidth*CC.SHeight*(14*6+4) + CC.SWidth + 2)*2, 0, 2}
	--S_XMax*S_YMax*(id*6+level)+y*S_XMax+x
	--14, 2, 1, 4
	--sFile,CC.TempS_Filename,JY.SceneNum,CC.SWidth,CC.SHeight

	--��ȡR*.grp�ļ�

	local len = filelength(CC.R_GRPFilename[0]);
	local data = Byte.create(len);
	
	--��ȡSMAP.grp
	local slen  = filelength(CC.S_Filename[0]);
	local sdata = Byte.create(slen);
	
	local menu = {};

	for i=1, CC.SaveNum do
	
		local name = "";
		--local lv = "";
		local sname = "";
		local nd = "";
		local time = "";
		--��������
		local tssl = "";
		--��������
		local zjlx = "";	
		--����
		local zz = "";
		
		if existFile(string.format('data/save/Save_%d',i)) then
			Byte.loadfilefromzip(data, string.format('data/save/Save_%d',i),'r.grp', 0, len);
			
			local pid = GetDataFromStruct(data,0,table_struct,"����1");
			
			name = GetDataFromStruct(data,pid*CC.PersonSize,table_struct,"����");
			zz = GetDataFromStruct(data,pid*CC.PersonSize,table_struct,"����");
			
			local wy = GetDataFromStruct(data,0,table_struct,"����");
			if wy == -1 then
				sname = "���ͼ";
			else
				sname = GetDataFromStruct(data,wy*CC.SceneSize,table_struct,"��������").."";
			end
			
			local lxid1 = GetDataFromStruct(data,0,table_struct,"��׼");
			local lxid2 = GetDataFromStruct(data,0,table_struct,"����");
			local lxid3 = GetDataFromStruct(data,0,table_struct,"����");
			
			if lxid1 > 0 then
				zjlx = "��׼"
			elseif lxid2 > 0 then
				zjlx = "����"
			elseif lxid3 > 0 then
				zjlx = "����"
			end
			
			local wz = GetDataFromStruct(data,0,table_struct,"�Ѷ�");
			tssl = GetDataFromStruct(data,0,table_struct,"��������").."��";

			nd = MODEXZ2[wz]
			
			--��Ϸʱ��
			--[[
			Byte.loadfile(sdata, string.format(CC.S_GRP,i), 0, slen);
			
			local t = GetDataFromStruct(sdata, 0, table_struct, "��Ϸʱ��")
			local t1, t2 = 0, 0
			while t >= 60 do
				t = t - 60
				t1 = t1 + 1
			end
			t2 = t
		  
			time = string.format("%2dʱ%2d��", t1, t2)]]
		end
		
		if i < 10 then
			menu[i] = {string.format("�浵%02d %-4s %-10s %-4s %4s %4s %-10s", i, zjlx, name, nd, zz, tssl, sname), nil, 1};
		else
			menu[i] = {string.format("�Զ��� %-4s %-10s %-4s %4s %4s %-10s", zjlx, name, nd, zz, tssl, sname), nil, 1};
		end
	end

	local menux=(CC.ScreenW-24*CC.DefaultFont-2*CC.MenuBorderPixel)/2
	local menuy=(CC.ScreenH - 9*(CC.DefaultFont+CC.RowPixel))/2

	local r=ShowMenu(menu,CC.SaveNum,10,menux,menuy,0,0,1,1,CC.DefaultFont,C_WHITE,C_GOLD)
	lib.Debug("SaveList")
	CleanMemory()
	return r;
end

--��̬��ʾ��ʾ
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

--�޾Ʋ���������¼�����
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

--�޾Ʋ�����ɾ���¼�����
function null(sid, pid)
	addevent(sid, pid, 0, 0, 0, 0)
end

--�޾Ʋ����������ѡ��˵�
function ShowMenu3(menu,itemNum,numShow,showRow,x1,y1,size,color,selectColor)
    local w=0;
    local h=0;   --�߿�Ŀ��
    local i,j=0,0;
    local col=0;     --ʵ�ʵ���ʾ�˵���
    local row=0;
    
    lib.GetKey();
    Cls();
    
    --��һ���µ�table
    local menuItem = {};
    local numItem = 0;                --��ʾ������
    
    --�ѿ�ѡΪ��������ﱣ�浽�µ�table
    for i,v in pairs(menu) do
        if v[3] ~= 0 then
            numItem = numItem + 1;
			menuItem[numItem] = {v[1],v[2],v[3],i};                --ע���4��λ�ã�����i��ֵ
        end
    end
    
    --����ʵ����ʾ�Ĳ˵�����
    if numShow==0 or numShow > numItem then
        col=numItem;
        row = 1;
    else
		--����
        col=numShow;
		--(��Ŀ����-1)/����=����
        row = math.modf((numItem-1)/col);
    end
    
    if showRow > row + 1 then
        showRow = row + 1;
    end

    --����߿�ʵ�ʿ��
    local maxlength=0;

	for i=1,numItem do
		if string.len(menuItem[i][1])>maxlength then
			maxlength=string.len(menuItem[i][1]);
		end
	end
	w=(size*maxlength/2+CC.RowPixel*2)*col+2*CC.MenuBorderPixel;
	h=showRow*(size+CC.RowPixel*2) + 2*CC.MenuBorderPixel;

    local start=0;             --��ʾ�ĵ�һ��

    local curx = 1;          --��ǰѡ����
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
		--˵�����ڴ�
		--DrawString(x1+(size+CC.RowPixel)*9-3,y1-(size+CC.RowPixel)*2-CC.RowPixel,"PgUp/PgDn/�����ַ�ҳ",LimeGreen,size);
		--DrawString(x1+(size+CC.RowPixel)*8-50,y1-(size+CC.RowPixel)*1,"���ƻ�ɫΪһ�� ������ɫΪ�߽� ��ɫΪ����",LimeGreen,size);
		for i=start,showRow+start-1 do
			for j=1, col do
				local n = i*col+j;
				if n > numItem then
					break;
				end
                
				--���ò�ͬ�Ļ�����ɫ
                local drawColor=color; 
                if menuItem[n][3] == 2 then
					drawColor = M_DeepSkyBlue
				end
				if menuItem[n][1] == "�������"  or menuItem[n][1] == "ɨ����ɮ"
				 or menuItem[n][1] == "������" 
				  then  
					drawColor = C_RED
                end
				if menuItem[n][1] == "����" or menuItem[n][1] == "����" or menuItem[n][1] == "��Ѱ��" 
				or menuItem[n][1] == "���"or menuItem[n][1] == "����ɮ"  or menuItem[n][1] == "����" 
				or menuItem[n][1] == "��ң��" or menuItem[n][1] == "��Ħ" or menuItem[n][1] == "½��" 
				or menuItem[n][1] == "����" or menuItem[n][1] == "˾��ժ��" or menuItem[n][1] == "������"
				or menuItem[n][1] == "��޿" or menuItem[n][1] == "�żһ�" or menuItem[n][1] == "����ˮ"then
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
		elseif keyPress==VK_PGUP or ktype == 6 then    --PgUp �� ��������
					if start == 15 then
						start = start - 15;
						curx = 1
						cury = 0
						mk = true;
					end
		elseif keyPress==VK_PGDN or ktype == 7 then    --PgDn �� ��������	
			if start == 0 then
				start = start + 15;
				curx = 1
				cury = 15
				mk = true;
			end
		else
			if ktype == 2 or ktype == 3 then			--ѡ��
				--�޾Ʋ������Ӹ��߼��ж���ֹ����
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
			--�ո񣬻س���
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
        
	--����ֵ�������ȡ��4��λ�õ�ֵ
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
		local ndChn = {"����","����","����","����","��ʦ","��˵"}
		local highLvl
		if Achievements.rdsCpltd[id].lvlReached2 > 0 then
			highLvl = Achievements.rdsCpltd[id].lvlReached1.."��"..ndChn[Achievements.rdsCpltd[id].lvlReached2]
		else
			highLvl = "����"
		end
		while true do
			if JY.Restart == 1 then
				return
			end
			Cls()
			
			lib.LoadPNG(91, 30 * 2 , 0, 0, 1)
			
			DrawString(390,50-40,JY.Person[id]["����"],C_GOLD,CC.FontBig*0.9)
			
			DrawString(80,130,"ͨ�ش�����"..Achievements.rdsCpltd[id].n.."��",C_WHITE,CC.DefaultFont)
			DrawString(80,200,"���ͨ���Ѷȣ�"..highLvl,C_WHITE,CC.DefaultFont)
			
			DrawString(CC.ScreenW/2 - 160,CC.ScreenH - 40,"�س���ȷ��ѡ�� ESC�˳�",LimeGreen,CC.DefaultFont*0.98)
			
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

--�޾Ʋ�������ȡ�书����
function get_skill_power(personid, wugongid, wugonglvl)
	local power;
	--�������书��10��������
	if wugonglvl == 11 then
		wugonglvl = 10
	end
    local spower = 0 
	power = JY.Wugong[wugongid]["������"..wugonglvl] 	
    
    spower = power
    
    if wugongid >= 109 and wugongid <= 112 then
        local xs = 0
        local lx = JY.Wugong[wugongid]['�书����']
        if lx == 1 then 
            xs = TrueQZ(personid)--JY.Person[personid]["ȭ�ƹ���"]
        elseif lx == 2 then 
            xs = TrueZF(personid)--JY.Person[personid]["ָ������"]
        elseif lx == 3 then 
            xs = TrueYJ(personid)--JY.Person[personid]["��������"]    
        elseif lx == 4 then 
            xs = TrueSD(personid)--JY.Person[personid]["ˣ������"]
        elseif lx == 5 then 
            xs = TrueTS(personid)--JY.Person[personid]["�������"]
        end
        if isteam(personid) then
            power = limitX(power + xs*3,300,1500)
        else 
            power = 1500
        end
    end
	--ѧ�˿���֮�󣬱�а������
	if wugongid == 48 and PersonKF(personid, 105) then
		power = 1300
	end
    
	--����츳�ڹ�������
	if power < 1000 and Given_NG(personid, wugongid) then
		power = power + 100
		if power > 1000 then
			power = 1000
		end
	end
    
	--���Ѻ󷭱�������
	--������+ȫ�����ӣ�ȫ�潣��
	if wugongid == 39 and JY.Person[0]["�������"] > 0 then
		if match_ID(personid, 123) or match_ID(personid, 124) or match_ID(personid, 125) or match_ID(personid, 126) or
		match_ID(personid, 127) or match_ID(personid, 128) or match_ID(personid, 129) or match_ID(personid, 68) then
			power = power * 2
		end
	end
	--÷���磬����Ů�����׹�צ
	if wugongid == 11 and JY.Person[0]["�������"] > 0 and (match_ID(personid, 78) or match_ID(personid, 640))then
		power = power * 1.5
	end
	--�������
	if wugongid == 189 and (match_ID(personid,9983) or JinGangBR(personid)) then
		power = power * 1.5
	end

	--��ѩ�� ���߽���
	if wugongid == 40  and match_ID(personid, 639)then
		power = power * 1.5
	end	
	--���� ѩɽ����
	if wugongid == 35 and match_ID_awakened(personid, 582,1)then
		power = power * 1.5
	end	
	--ΤһЦ����������
	if wugongid == 5 and JY.Person[0]["�������"] > 0 and match_ID(personid, 14) then
		power = power * 1.5
	end
	--��������ӥצ��
	if wugongid == 4 and JY.Person[0]["�������"] > 0 and match_ID(personid, 12) then
		power = power * 1.5
	end
	--��ϣ��ֽ�����
	if wugongid == 117 and JY.Person[0]["�������"] > 0 and match_ID(personid, 131) then
		power = power * 1.5
	end
	--�����ӣ����߰˴�
	if wugongid == 74 and JY.Person[0]["�������"] > 0 and match_ID(personid, 157) then
		power = power * 2
	end
	--�����ź���ʮ�˱���������
	if match_ID(personid, 612) and wugongid == 206 and JY.Status == GAME_WMAP and WAR.ZWX > 0 then
		power = power *  WAR.ZWX
	end	
	--׿���ۺ���ʮ�˱���������
	if match_ID(personid, 613) and wugongid == 206 and JY.Status == GAME_WMAP and WAR.ZWX > 0 then
		power = power *  WAR.ZWX
	end	
	--׿��������������������
	if match_ID(personid, 613) and wugongid == 205 and JY.Status == GAME_WMAP and WAR.ZWX > 0 then
		power = power * WAR.ZWX
	end	
	
	--�����̳�������������
	if match_ID(personid, 510) and wugongid == 73 then
		power = power * 2
	end		
    
	--������ս�����嶾��������
	if match_ID(personid, 83) and wugongid == 3 and JY.Status == GAME_WMAP and WAR.HTS > 0 then
		power = power * WAR.HTS
	end
    
	--�ֳ�Ӣ�����ž���
	if match_ID(personid, 605) then
		power = power * 1.1
	end
    
	--����츳�⹦������
	if Given_WG(personid, wugongid) then
		--if power < 1200 then
			power = power + 200
		--elseif power >= 1200 and power < 1400 then
		--	power = 1400
		--end
        if JY.Status == GAME_WMAP then 
            if WAR.PD['ѩ������'][personid] ~= nil and wugongid == 35 then 
                power = power + spower*WAR.PD['ѩ������'][personid]*0.5
            end
        end
	end
    
	--Ԭ���� ���޵��� 1.5��
	if wugongid == 62  and match_ID(personid, 566) then
		power = power + 300
	end	
    
	--Ԭ������������
	if match_ID(personid, 587) and (wugongid == 78 or wugongid == 164) then
		power = power + 300
	end
    
	--��ع���
	if match_ID(personid,9988) and wugongid == 10 then
		power = power + 600
	end
	if JY.Person[personid]["����"] == 200 then
		if wugongid == 8 or wugongid == 14 or wugongid == 185 or wugongid == 202 or wugongid == 201 then
           power = power + 100
        end
    end 
    
	--̫����
	if (wugongid == 16 or wugongid == 46) and Curr_NG(personid, 171) then
	   power = power + 200
	end
    
	--�������� һ��ָ
	if wugongid ==17 and PersonKF(personid, 207) then
	   power = power + 200
	end
	-- ��Գ
    if match_ID(personid, 9997) and JY.Person[personid]["����"] == 326 and wugongid == 188 then
       power = power + 500
	end	
	--��ɽ��÷�֣�����ͯ�ѣ������ӣ�����ˮ���������
	if wugongid == 14 then
		if match_ID(personid, 49) or match_ID(personid, 116) or match_ID(personid, 117) or match_ID(personid, 118) then
			for i = 1, JY.Base["�书����"] do
				if JY.Person[personid]["�书"..i] ~= 14 and JY.Person[personid]["�书�ȼ�"..i] == 999 then
					power = power + 50
				end
			end
		end
	end
    -- ��ħ���� ��ħ�ȷ�
	if wugongid == 86 and JY.Person[personid]["����"] == 323 then
	   power = power + 200
	   end	
    -- ��Գ Գ������
	if (wugongid == 188 or wugongid ==156) and JY.Person[personid]["����"] == 326 then
	   power = power + 200
	end		   
    
	if wugongid == 110 and JY.Person[personid]["����"] == 55 then
	   power = power + 200
	end	
	if wugongid == 111 and JY.Person[personid]["����"] == 56 then
	   power = power + 200
	end	
	if wugongid == 112 and JY.Person[personid]["����"] == 57 then
	   power = power + 200
	end	
	--����ѩɽ����
	if wugongid == 35 then
		if match_ID_awakened(personid, 582,1) then
			for i = 1, JY.Base["�书����"] do
				if JY.Person[personid]["�书"..i] ~= 35 and JY.Person[personid]["�书�ȼ�"..i] == 999 then
					power = power + 100
				end
			end
		end
	end
    -- �������ڵ���
    if wugongid == 61 and match_ID_awakened(personid, 581,1) then
	power = power + 300
	end
	--�߱�ָ�� ��ң�书
    if (wugongid ==8 or wugongid == 14 or wugongid == 98 or wugongid == 101 or wugongid ==185 ) and JY.Person[personid]["����"] == 200 then
	power = power+100
	end	
	--���������������
	if wugongid >= 30 and wugongid <= 34 and WuyueJF(personid) then
		power = power + 500
	end
	--��������+�����������������
	if wugongid >= 30 and wugongid <= 34 and PersonKF(personid,175) then
		power = power + 200
	end
	--˫���ϱڣ��������
	if (wugongid == 39 or wugongid == 42  or wugongid == 139) and ShuangJianHB(personid) then
		power = power + 300
	end
	--�����黭�������
	if (wugongid == 73 or wugongid == 72 or wugongid == 84 or wugongid == 142) and QinqiSH(personid) then
		power = power + 300
	end
	--�һ������������
	if (wugongid == 12 or wugongid == 18 or wugongid == 38) and TaohuaJJ(personid) then
		power = power + 200
	end
	--�׽��ǿ������ѧ
	if (wugongid == 1  or wugongid == 22 or wugongid == 24 or wugongid == 189
	 or wugongid == 86 or wugongid == 124 or wugongid == 132 or wugongid == 133 or wugongid == 135  or wugongid == 136   or wugongid == 137    
	or wugongid == 65
    or wugongid == 140	or wugongid== 194)	
	and Curr_NG(personid,108) then
        power = power + 200
	end
	--�����񹦶԰׹�צ�������
	if wugongid == 11 and PersonKF(personid, 107) then
		power = power + 200
	end
	--����װ�������ӳ�
	for i,v in ipairs(CC.ExtraOffense) do
		if v[1] == JY.Person[personid]["����"] and v[2] == wugongid then
			power = power + v[3]
		end
	end
	--ֻ��ս���в��еļӳ�
	if JY.Status == GAME_WMAP then
        --̫��������
        --ֻ��ս���в��еļӳ�
        if Curr_NG(personid, 171) and (wugongid ==16 or wugongid == 46 ) and WAR.tmp[3000 + personid] ~= nil and WAR.tmp[3000 + personid] > 0 then
            if wugongid ==16 then
                power = power + WAR.tmp[3000 + personid]*1.5
            else			 
                power = power + WAR.tmp[3000 + personid]
            end
        end	
    end		
	--��������˭������
	if JY.Person[personid]["����"] == 37 and JY.Wugong[wugongid]["�书����"] == 3 then
		if match_ID(personid, 631) or match_ID(personid,6) then
            power = power + 300
        else
            power = power + 200
        end
    end
    
	--��һ�� �ɶ�����
	if match_ID(personid, 633) and JY.Person[personid]["����"] == 45  and wugongid == 67 then
		power = power + 200
	end	
    
	--��޿
	if match_ID(personid, 588)   and (wugongid == 18 or wugongid == 38 or wugongid == 12 or wugongid == 126) then
		power = power + 200
	end
	return power
end

--�޾Ʋ������ж��츳�⹦�ĺ���
function Given_WG(personid, WGid)
	local tw = false;
	for i = 1, 4 do
		if JY.Person[personid]["�츳�⹦"..i] == WGid then
			tw = true;
			break;
		end
	end
	return tw;
end

--�޾Ʋ������ж��츳�ڹ��ĺ���
function Given_NG(personid, NGid)
	local tw = false;
	if JY.Person[personid]["�츳�ڹ�"] == NGid then
		tw = true;
	end
	return tw;
end

--����ָ�վ��
function stands()
	JY.MyCurrentPic=0
	if JY.Person[0]["�Ա�"] == 0 then
		JY.MyPic=CC.MyStartPicM+JY.Base["�˷���"]*7+JY.MyCurrentPic;
	else
		JY.MyPic=CC.MyStartPicF+JY.Base["�˷���"]*7+JY.MyCurrentPic;
	end
end

--�޾Ʋ���������ѡ��˵�
function TeleportMenu(menu, color, selectColor)
	local x1	--�˵���ʼX����
    local y1	--�˵���ʼY����
    local w		--�˵����
    local h		--�˵��߶�
	local maxlength		--��λ��󳤶�
	local size = CC.Fontsmall	--�����С
    
	x1 = CC.MainMenuX+3
    y1 = CC.MainMenuY+CC.Fontsmall*2 +9

	maxlength = 8
	
	w = (size*maxlength/2+CC.RowPixel*4+5)*7 + CC.MenuBorderPixel	--7Ϊ����
    h = (size+CC.RowPixel*2-1)*16 + CC.MenuBorderPixel				--16Ϊ�������
	
    lib.GetKey();
    Cls();
	
	lib.LoadPNG(91, 13 * 2 , 0 , 0, 1)		--����ͼ
    
	--�����߸�������洢��ͬ���͵ĳ���
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
    
	--v123�ֱ�Ϊ�������ƣ��ɷ���룬�������
	--v2Ϊ0����ɽ��룬1�����ɽ���
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
	
	--������Ϣ
	local P_inf = {{PType_1,PNum_1},{PType_2,PNum_2},{PType_3,PNum_3},{PType_4,PNum_4},{PType_5,PNum_5},{PType_6,PNum_6},{PType_7,PNum_7},[0]={0,0}}
	local PType_name = {"��ջ����","��������","�������","�������","��ɽ��","ɽ������","���ೡ��"}

	--���ĳ�ʼλ��
	local cursor_x = 1
	local cursor_y = 1
	local current = 1

	--����ֵ
    local returnValue =-1;
  
    local surid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)

    while true do
		if JY.Restart == 1 then
			break
		end
        lib.LoadSur(surid, 0, 0)
		--DrawString(x1+10,y1-CC.RowPixel*4-7,"X:"..cursor_x.."��Y:"..cursor_y.."��Current:"..current,LimeGreen,size);	--���������Ϣ
		for i = 1, 7 do
			--��������
		--	DrawString(x1+(i-1)*(size*maxlength/2+CC.RowPixel*4+5)+CC.MenuBorderPixel,y1-CC.RowPixel*6+1,PType_name[i],LimeGreen,size);
			for j = 1, 16 do
				if j > P_inf[i][2] then
					break;
				end
				--ȷ����ǰ��λ���
				local id = 0
				for jj = 1, i do
					id = id + P_inf[jj-1][2]
				end
				id = id + j
				--�޷�����ĳ�������Ϊ��ɫ
				local drawColor = color; 
				if P_inf[i][1][j][2] == 1 then
					drawColor = M_DimGray
				end
				local xx = x1+(i-1)*(size*maxlength/2+CC.RowPixel*4+5) + CC.MenuBorderPixel
				local yy = y1+(j-1)*(size+CC.RowPixel*2-1)
				--����ǰѡ�еĵ�λ��ɫ
				if id == current then
					drawColor = selectColor;
					lib.Background(xx-5, yy-5, xx + size*maxlength/2+5, yy + size + 5, 128, color)
				end
				--��ʾ��������
				DrawString(xx,yy,P_inf[i][1][j][1],drawColor,size);
			end
		end
  
        ShowScreen();
        local keyPress, ktype, mx, my = WaitKey(1)
		
		lib.Delay(CC.Frame);
				
		--ktype  1�����̣�2������ƶ���3:��������4������Ҽ���5������м���6�������ϣ�7��������
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
    --����ֵ
	return returnValue
end

--�޾Ʋ������ж϶����ǲ�����������λ
function More_than_2_vacant_slot()
	if JY.Base["����14"] == -1 and JY.Base["����15"] == -1 then
		return true
	end
	return false
end

--�޾Ʋ��������˾���
function awakening(id, value)
	local xwperson;	--�ж�Ҫ���ѵ���
	if id == JY.Base["����"] then
		xwperson = 0
	else
		xwperson = id
	end
    
	JY.Person[xwperson]["���˾���"] = JY.Person[xwperson]["���˾���"] + value
end

--�޾Ʋ����������䳣
function kungfu_knowledge(id, value)
	local xwperson;	--�ж�Ҫ�����䳣����
	if id == JY.Base["����"] then
		xwperson = 0
	else
		xwperson = id
	end
	JY.Person[xwperson]["��ѧ��ʶ"] = JY.Person[xwperson]["��ѧ��ʶ"] + value
end

--�޾Ʋ������ж��Ƿ�Ϊָ��ID����������ж��Ƿ�ﵽָ�����Ѵ���
function match_ID_awakened(personid, id, awkntimes)
    
	if CC.Copy[personid] ~= nil then 
		personid = CC.Copy[personid]
	end
    
	if personid == id then
		if JY.Person[personid]["���˾���"] >= awkntimes then
			return true
		else
			return false
		end
	elseif personid == 0 and JY.Base["����"] == id then
		if JY.Person[0]["���˾���"] >= awkntimes then
			return true
		else
			return false
		end

    elseif personid == 0 and JY.Base["��ͨ"] == 2 and instruct_16(id) then
        if JY.Person[0]["���˾���"] >= awkntimes then
            return true
        else
            return false
        end

	else
		return false
	end
end

--ֱ���趨ָ�����������
function set_potential(id, value)
	local xwperson;	--�ж�Ҫָ�����ʵ���
	if id == JY.Base["����"] or (JY.Base["��ͨ"]==2 and instruct_16(id)) then
		xwperson = 0		
	else
		xwperson = id
	end
	JY.Person[xwperson]["����"] = value
end

--�޾Ʋ������ж��ǲ�����ʾ�ؼ�
function secondary_wugong(wugongid)
	--�Ṧ
	if JY.Wugong[wugongid]["�书����"] == 7 then
		return true
	--��������ղ������������� ��ɵ� ��������
	elseif wugongid == 85 or wugongid == 87 or wugongid == 88 or wugongid == 144 or wugongid == 175  or wugongid == 182  or wugongid == 199 or wugongid == 43 then
		return true
	end
	return false
end

--�޾Ʋ������ж������ڹ��ĺ���
function Curr_NG(personid, NGid)
	if JY.Person[personid]["�����ڹ�"] == NGid then
		return true
	end	
	--����ж�
	if JY.Base["��׼"] == 6  or  JY.Base["����"] == 637 or  JY.Base["����"] == 27 or JY.Base["����"] == 189  then
		--��������ڣ������Ѿ�ѧ�ᣬ���Զ�����
		if JY.Person[personid]["�츳�ڹ�"] == NGid and PersonKF(personid, NGid) then
            Hp_Max(personid)
			return true
		end
	end
	
	if match_ID(personid,511) and NGid == 227 then 
		return true
	end	
	
	return false
end

--�޾Ʋ������ж������Ṧ�ĺ���
function Curr_QG(personid, QGid)
	if JY.Person[personid]["�����Ṧ"] == QGid then
		return true
	elseif personid == 577 then
  	if JY.Person[personid]["�츳�Ṧ"] == QGid and PersonKF(personid, QGid)  then
			return true
			else
			return false
			end
	else
		return false
	end
end

--�޾Ʋ������ж���������ϼ��ĸ���
function calc_mas_num(id)
	local mas_num = 0;
	for i = 1, JY.Base["�书����"] do
		if JY.Person[id]["�书�ȼ�" .. i] == 999 then
			mas_num = mas_num + 1;
		end
	end
	return mas_num
end

--�޾Ʋ������ж��Ƿ�Ϊָ��ID����������츳���ж�
function match_ID(personid, id)
	if personid == 0 then 
		if CC.TG[id] == 1 then 
			return true
		end
	end
	if personid == 0 and JY.Base["����"] > 0 then
		personid = JY.Base["����"]
	end	

    if (personid==0 or personid == JY.Base["����"]) and JY.Base["��ͨ"]==2 and instruct_16(id) then
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

--�޾Ʋ������ж�������
function Person_LJ(pid)
	--�����������ʼ������������
	local LJ1 = math.modf(JY.Person[pid]["�Ṧ"] / 18)
	local LJ2 = math.modf((JY.Person[pid]["�������ֵ"] + JY.Person[pid]["����"]) / 1000)
	local LJ3 = math.modf(JY.Person[pid]["����"] / 10)
	local LJ = 0
	LJ = (LJ1 + LJ2 + LJ3) / 2
	
	--�������ǧ�𡢺����������������͡��ݳ�������������֮��������+70%
	if match_ID(pid, 6) or match_ID(pid, 67) or match_ID(pid, 71) or match_ID(pid, 18)  or match_ID(pid, 594) or match_ID_awakened(pid, 35, 2) then
		LJ = LJ + (100 - LJ) * 0.7
	end
	--�������100%Ѫ�޼ӳɣ�0Ѫ100%�ӳ�
	if match_ID(pid, 586) then
	local HZDLJ = 0
	HZDLJ = (1-JY.Person[pid]["����"] / JY.Person[pid]["�������ֵ"])*100
	LJ = LJ + HZDLJ
	end		
--���������+50% ���羪��
    if match_ID(pid, 189) or match_ID(pid, 9996) then
	   LJ = LJ +(100-LJ)*0.5
	   end
	--�����书��ÿ������+2.5%
	--�ٻ�����������Ů��̩ɽ��ԧ�죬�����ǣ����ǹ�����ţ����������ǣ�ȥ���գ��ڷ�, ����
	local ljup = {10, 15, 42, 31, 54, 60, 68, 76, 79, 114, 124, 131, 139}
	for i = 1, JY.Base["�书����"] do
		if JY.Person[pid]["�书" .. i] > 0 then
			for ii = 1, #ljup do
				if JY.Person[pid]["�书" .. i] == ljup[ii] then
					LJ = LJ + (100 - LJ) * 0.025
				end
			end
		else
			break;
		end
	end
	
	--���¾Ž�����+5%   
	for i = 1, JY.Base["�书����"] do
		if JY.Person[pid]["�书" .. i] == 47 then
			LJ = LJ + (100 - LJ) * 0.05
            break
		end
	end

	--�۽���Ӯ�ֳ�Ӣ����+50%
	if pid == 0 and JY.Person[605]["�۽�����"] == 1 then
		LJ = LJ + (100 - LJ) * 0.5
	end
	
	--ʵս��ÿ40��+1%
	local jp = JY.Person[pid]["ʵս"] / 4000
	LJ = LJ + (100 - LJ) * jp
	
	
	--���˾���+50% 
	if  Curr_NG(pid, 107) and (JY.Person[pid]["��������"] == 0 or JY.Person[pid]["��������"] == 3 ) then
		LJ = LJ + (100 - LJ) * 0.5
	end
	--˫���ϱ� ������+30%
		if  ShuangJianHB(pid) == true then
			LJ = LJ + (100 - LJ) * 0.3
		end
	--���ǽ� ������+10%
		if JY.Person[pid]["����"]  == 38 then
			LJ = LJ + (100 - LJ) * (JY.Thing[38]["װ���ȼ�"]/10 -0.1)
		end	 

	--������ ��Ůʮ�Ž�������+30%
	if match_ID(pid,649) and WAR.YLSJJ == 1 and JY.Status == GAME_WMAP then
		LJ = LJ + (100 - LJ) * 0.3
	end	
	--������ڳ���ȫ���10%
	if inteam(pid) and JY.Status == GAME_WMAP then
		for wid = 0, WAR.PersonNum - 1 do
			if match_ID(WAR.Person[wid]["������"], 607) and WAR.Person[wid]["����"] == false and WAR.Person[wid]["�ҷ�"] then
				LJ = LJ + (100 - LJ) * 0.1
				break
			end
		end
	end

	--�������ܡ���Զɽ ������
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
    
	--����������1
    if LJ < 1 then
		LJ = 1
    end
	
	--ȡ��
	LJ = math.modf(LJ)
	
	return LJ
end

--�޾Ʋ������ж�������
function Person_BJ(pid)
    --�����ڹ������������������
    local BJ1 = math.modf(JY.Person[pid]["������"] / 18)
    local BJ2 = math.modf((JY.Person[pid]["�������ֵ"] + JY.Person[pid]["����"]) / 1000)
    local BJ3 = math.modf(JY.Person[pid]["����"] / 10)
    local BJ = 0
    BJ = (BJ1 + BJ2 + BJ3) / 2

    --Ѫ�����桢��ǧ�𡢺�����������С������ӡ���������+70%
    if match_ID(pid, 97) or match_ID(pid, 67) or match_ID(pid, 71) or match_ID(pid, 26) or match_ID(pid, 184) then
		BJ = BJ + (100 - BJ) * 0.7
    end
	--���°˷�������+5%   
	for i = 1, JY.Base["�书����"] do
		if JY.Person[pid]["�书" .. i] == 181 then
			BJ = BJ + (100 - BJ) * 0.05
		end
	end	
	--Ԭ��־������� ������+50%
    if match_ID(pid, 54)  or match_ID(pid, 189)then
		BJ = BJ + (100 - BJ) * 0.5
    end
    --����ħ�������
	if ShiZunXM(pid) == true then
		BJ = BJ + (100 - BJ) * 0.5
	end
	--½��˫ ������+30%
    if match_ID(pid, 580) then
		BJ = BJ + (100 - BJ) * 0.3
    end	
	--½��˫ ������+30%
    if match_ID(pid, 580) then
		BJ = BJ + (100 - BJ) * 0.3
    end	
	--�������100%Ѫ�޼ӳɣ�0Ѫ100%�ӳ�
	if match_ID(pid, 586) then
		local HZDBJ = 0
		HZDBJ = (1-JY.Person[pid]["����"] / JY.Person[pid]["�������ֵ"])*100
		BJ = BJ + HZDBJ
	end	
    --�����Ѫ�������ķ�֮һʱ������������3��
    if match_ID(pid, 58) and JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 4 then
		BJ = BJ * 3
    --�����Ѫ�����ڶ���֮һ������������2��
    elseif match_ID(pid, 58) and JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 2 then
		BJ = BJ * 2
    end
	
	--�����书��ÿ������+2.5%
	--��ָ��������ȫ�棬���ߣ��������ţ�ȼľ���Ὣ������ɳ�����ߣ����ڣ���ڤ����ָ����һ��ָ
    local bjup = {18, 22, 39, 40, 56, 65, 71, 78, 74, 61, 21, 121, 17}
    for i = 1, JY.Base["�书����"] do
		if JY.Person[pid]["�书" .. i] > 0 then
			for ii = 1, #bjup do
				if JY.Person[pid]["�书" .. i] == bjup[ii] then
					BJ = BJ + (100 - BJ) * 0.025
				end
			end
		else
			break;
		end
    end

	  
	--ʵս��ÿ40��+1%
	local jp = JY.Person[pid]["ʵս"] / 4000
	BJ = BJ + (100 - BJ) * jp
	
	--��������+50%
	if Curr_NG(pid, 104) then
	    BJ = BJ + (100 - BJ) * 0.5
    elseif PersonKF(pid,107) then
		BJ = BJ + (100 - BJ) * 0.3
	end

	--����
	if match_ID(pid, 578) then
	local df = 0
		for i = 1, JY.Base["�书����"] do
			if JY.Wugong[JY.Person[0]["�书" .. i]]["�书����"] == 4 and JY.Person[0]["�书�ȼ�" .. i] == 999 then
				df = df + 1
				if df > 8 then
				df = 8
			end
		end
		BJ = BJ + (100 - BJ) *df*0.05
		end
		end
	--���塢�������Զɽ���ر���
    if match_ID(pid, 50) or match_ID(pid, 6) or match_ID(pid, 112) or (match_ID(pid, 49) and pid == 0)then
		BJ = 100
    end
	
	--ֻ��ս���в��еļӳ�
	if JY.Status == GAME_WMAP then
		--ŷ���� ����״̬�±ر���
		if match_ID(pid, 60) and WAR.tmp[1000+pid] == 1 then
			BJ = 100
		end
		
		--ŭ��ֵ100���Ƕ�ת�±ر���
		if WAR.LQZ[pid] == 100 and WAR.DZXY ~= 1 then
			BJ = 100
		end
	end
	
	--����������1
    if BJ < 1 then
		BJ = 1
    end
	
	--ȡ��
	BJ = math.modf(BJ)
	
	return BJ
end

--�޾Ʋ���������������ѧ�ڹ�������
function Num_of_Neigong(id)
	local num = 0
	for i = 1, JY.Base["�书����"] do
		local kfid = JY.Person[id]["�书"..i]
		if JY.Wugong[kfid]["�书����"] == 6 then
			num = num + 1
		end
	end
	return num
end

--�޾Ʋ������ж�һ�������Ƿ�������������������
function WuyueJF(id)
	local wuyuenum = 0;
	for i = 1, JY.Base["�书����"] do
		local kfid = JY.Person[id]["�书"..i]
		local klvl = JY.Person[id]["�书�ȼ�"..i]
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

--�޾Ʋ�������ʵȭ���������ж�
function TrueQZ(id)
	local qz = JY.Person[id]["ȭ�ƹ���"]
	--��˿����
	if JY.Person[id]["����"] == 239 then
		local add = 10
		if JY.Thing[239]["װ���ȼ�"] >= 5 then
			add = 30
		elseif JY.Thing[239]["װ���ȼ�"] >= 4 then
			add = 25
		elseif JY.Thing[239]["װ���ȼ�"] >= 3 then
			add = 20
		elseif JY.Thing[239]["װ���ȼ�"] >= 2 then
			add = 15
		end
		qz = qz + add
	end
	if match_ID(id, 508) and JY.Status == GAME_WMAP then
		local df = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == false  then
				df = df +1
			end          
	    end	
		 qz = qz + df * 5		
	end	
	--̫����ս��ϵ��*140%
	if PersonKF(id, 102) and JY.Status == GAME_WMAP then
		qz = qz + math.modf(qz*0.4)
	end
	return qz
end

--�޾Ʋ�������ʵָ���������ж�
function TrueZF(id)
	local zf = JY.Person[id]["ָ������"]
	--��˿����
	if JY.Person[id]["����"] == 239 then
		local add = 10
		if JY.Thing[239]["װ���ȼ�"] >= 5 then
			add = 30
		elseif JY.Thing[239]["װ���ȼ�"] >= 4 then
			add = 25
		elseif JY.Thing[239]["װ���ȼ�"] >= 3 then
			add = 20
		elseif JY.Thing[239]["װ���ȼ�"] >= 2 then
			add = 15
		end
		zf = zf + add
	end
	if match_ID(id, 508)  and JY.Status == GAME_WMAP then
		local df = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == false  then
				df = df +1
			end         	
	    end	
		 zf = zf + df * 5	
	end		
	--̫����ս��ϵ��*140%
	if PersonKF(id, 102) and JY.Status == GAME_WMAP then
		zf = zf + math.modf(zf*0.4)
	end
	return zf
end

--�޾Ʋ�������ʵ�����������ж�
function TrueYJ(id)
	local yj = JY.Person[id]["��������"]
	--��������
	if WuyueJF(id) then
		yj = yj + 50
	end
	--ս���еļӳ�
	if JY.Status == GAME_WMAP then
		--��������
		if WAR.JDYJ[id] then
			yj = yj + WAR.JDYJ[id]
		end
		--̫����ս��ϵ��*140%
		if PersonKF(id, 102) then
			yj = yj + math.modf(yj*0.4)
		end
	   if match_ID(id, 508) and JY.Status == GAME_WMAP then
		   local df = 0
		   for j = 0, WAR.PersonNum - 1 do
			   if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == false  then
				   df = df +1
			   end           	
	       end	
		 yj = yj + df * 5	
	   end		
		--������
        if match_ID(id, 584)  then
		   local JF = 0
		   for i = 1, JY.Base["�书����"] do
			  if JY.Wugong[JY.Person[id]["�书" .. i]]["�书����"] == 3 then
				 JF = JF + 1
			  end
		   end
		yj =yj + JF * 10
	   end
	end
	return yj
end

--�޾Ʋ�������ʵˣ���������ж�
function TrueSD(id)
	local sd = JY.Person[id]["ˣ������"]
	--̫����ս��ϵ��*140%
	if PersonKF(id, 102) and JY.Status == GAME_WMAP then
		sd = sd + math.modf(sd*0.4)
	end
	if match_ID(id, 508)  and JY.Status == GAME_WMAP then
		local df = 0
		for j = 0, WAR.PersonNum - 1 do
		    if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == false  then
				   df = df +1
			   end         
	       end
	        sd = sd + df * 5		
	   end	
	return sd
end

--�޾Ʋ�������ʵ�����������ж�
function TrueTS(id)
	local ts = JY.Person[id]["�������"]
	--̫����ս��ϵ��*140%
	if PersonKF(id, 102) and JY.Status == GAME_WMAP then
		ts = ts + math.modf(ts*0.4)
	end
	if match_ID(id, 508)  and JY.Status == GAME_WMAP then
		local df = 0
		for j = 0, WAR.PersonNum - 1 do
		    if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == false  then
				   df = df +1
			   end          	
	       end
        ts = ts + df * 5		
	   end	
	return ts
end

--�޾Ʋ������ж�һ�������Ƿ����������黭������
function QinqiSH(id)
	local qinqinum = 0;
	for i = 1, JY.Base["�书����"] do
		local kfid = JY.Person[id]["�书"..i]
		local klvl = JY.Person[id]["�书�ȼ�"..i]
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

--���ƮҶ ��������˳��
function Menu_TZDY()
   local menu = {}
   local px={}
   local m=0
   --���ѳ���2�˲Ż���Ч
   if JY.Base["����" .. 3]>0 then
		Cls()
		DrawStrBox(CC.MainMenuX,CC.MainSubMenuY,"��Ҫ����˭��λ��",LimeGreen,CC.DefaultFont,C_GOLD);
		local nexty=CC.MainSubMenuY+CC.SingleLineHeight;
		for i=1,CC.TeamNum do
			menu[i]={"",nil,0};
			local id=JY.Base["����" .. i]
			if id>0 then
				menu[i]={"",nil,0};
				if JY.Person[id]["����"]>0 then
					menu[i][1]=JY.Person[id]["����"];
					menu[i][3]=1;
				end
			end
		end  
   
		local r = -1;
		while true do
			r = ShowMenu(menu,#menu,0,CC.MainMenuX,CC.MainSubMenuY+CC.SingleLineHeight,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE)
			if px["������"]==nil and r>1 then
				px["������"]=r
				menu[r]={"",nil,0}
				Cls()
				DrawStrBox(CC.MainMenuX,CC.MainSubMenuY,JY.Person[JY.Base["����" .. r]]["����"].."��˭����λ��",LimeGreen,CC.DefaultFont,C_GOLD);
			elseif r>1 and px["������"]~=nil and r ~=px["������"] then	
				local m1=JY.Base["����" .. r]
				local m2=JY.Base["����" .. px["������"]]
				JY.Base["����" .. r]=m2
				JY.Base["����" .. px["������"]]=m1
				say("��"..JY.Person[m2]["����"].."�� �� ��"..JY.Person[m1]["����"].."�� ������λ�á�",m2,1)
				Cls()
				--return
				break
			--�޾Ʋ���������ESC�˳�����
			else
				break
			end
		end
	end
end

--�޾Ʋ�������һ����
function DrawSingleLine(x1, y1, x2, y2, color)
	lib.DrawRect(x1 + 1, y1 + 1, x2, y2, color)
	lib.DrawRect(x1, y1, x2 - 1, y2 - 1, color)
end

--�ı�����
function SetTianWai(personid, x, wugongid)
	local xwperson;	--�ж�Ҫϴ�������
	if personid == JY.Base["����"] then
		xwperson = 0
	else
		xwperson = personid
	end	
	JY.Person[xwperson]["�츳�⹦"..x] = wugongid
end

--�ı�����
function SetTianNei(personid, wugongid)
	local xwperson;	--�ж�Ҫϴ���ڵ���
	if personid == JY.Base["����"] then
		xwperson = 0
	else
		xwperson = personid
	end	
	JY.Person[xwperson]["�츳�ڹ�"] = wugongid
end

--�ı�����
function SetTianQing(personid, wugongid)
	local xwperson;	--�ж�Ҫϴ�������
	if personid == JY.Base["����"] then
		xwperson = 0
	else
		xwperson = personid
	end	
	JY.Person[xwperson]["�츳�Ṧ"] = wugongid
end

--ѧ�ụ��
function SetHuBo(personid)
	local xwperson;
	if personid == JY.Base["����"] then
		xwperson = 0
	else
		xwperson = personid
	end	
	JY.Person[xwperson]["���һ���"] = 1
end

--�޾Ʋ������ж�һ�������Ƿ������һ�����������
function TaohuaJJ(id)
	--�����Զ�����
	if match_ID(id, 626) then
		return true
	end
	local taohuanum = 0;
	for i = 1, JY.Base["�书����"] do
		local kfid = JY.Person[id]["�书"..i]
		local klvl = JY.Person[id]["�书�ȼ�"..i]
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

--����������ϵ����ֵ֮��
function Xishu_sum(id)
	local sum = 0
	sum = sum + TrueQZ(id)
	sum = sum + TrueZF(id)
	sum = sum + TrueYJ(id)
	sum = sum + TrueSD(id)
	sum = sum + TrueTS(id)
	return sum
end

--��������ϵ����ֵ��ߵ�һ��
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

--���ð汳��ͼ
function Clipped_BgImg(x1,y1,x2,y2,picnum)
	lib.SetClip(x1 + 2, y1 + 2, x2 - 1, y2 - 1)
	lib.LoadPNG(1, picnum * 2 , 0 , 0, 1)
	lib.SetClip(0,0,0,0)
end

--��ʾ���߿������
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

--�޾Ʋ������ж�һ�������Ƿ������ȴ���������
--ͬʱ��������Ҷָ/�����޶�ָ/�����ָ/�黨ָ����
function ChuQueSX(id)
	local sixiangnum = 0;
	for i = 1, JY.Base["�书����"] do
		local kfid = JY.Person[id]["�书"..i]
		local klvl = JY.Person[id]["�书�ȼ�"..i]
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

--����һƬ�Ľǰ����ı���
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

--��Ʒ��ϸ˵��
function detailed_info(thingID)
	local str=JY.Thing[thingID]["����"] .. JY.Thing[thingID]["����"]
	local str2=JY.Thing[thingID]["��Ʒ˵��"]
	local str3=JY.Thing[thingID]["����"]	
	if ItemInfo[thingID]==nil then
		return
	end
	local info = {}
	info = ItemInfo[thingID]
	local function strcolor_switch(s)
		local Color_Switch={{"��",PinkRed},{"��",C_GOLD},{"��",C_BLACK},{"��",C_WHITE},{"��",C_ORANGE},{"��",LimeGreen},{"��",M_DeepSkyBlue},{"��",Violet}}
		for i = 1, 8 do
			if Color_Switch[i][1] == s then
				return Color_Switch[i][2]
			end
		end
	end
	local maxRowExisting = #info		--��ǰ˵��������
	local maxRowDisplayable = 11		--����ҳ�������ʾ���������
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
			if string.sub(tfstr,1,2) == "��" then
				row = row + 1
			else
				local color;
				color = strcolor_switch(string.sub(tfstr,1,2))
				tfstr = string.sub(tfstr,3,-1)
				DrawString(22, 80 + (size+CC.RowPixel*2) * (row), tfstr, color, size)
				row = row + 1
			end
		end
		--���·��ļ�ͷ��ʾ
		if startingRow > 1 then
			DrawString(CC.ScreenW-40, 110, "��", C_GOLD, size)
		end
		if startingRow+maxRowDisplayable < maxRowExisting then
			DrawString(CC.ScreenW-40, CC.ScreenH-140, "��", C_GOLD, size)
		end
		DrawString(CC.ScreenW-220,CC.ScreenH-40, "��F1������Ʒ�˵�", C_ORANGE,size)
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

--�޾Ʋ������ж�һ�������Ƿ������������޵�����
function ZiqiTL(id)
	local ziqinum = 0;
	for i = 1, JY.Base["�书����"] do
		local kfid = JY.Person[id]["�书"..i]
		local klvl = JY.Person[id]["�书�ȼ�"..i]
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

--�޾Ʋ������ж�һ�������Ƿ����㽣�����ĵ�����
function JiandanQX(id)
	local jiandannum = 0;
	for i = 1, JY.Base["�书����"] do
		local kfid = JY.Person[id]["�书"..i]
		local klvl = JY.Person[id]["�书�ȼ�"..i]
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

--�޾Ʋ������ж�һ�������Ƿ����������޷������
function TianYiWF(id)
	local tianyinum = 0;
	for i = 1, JY.Base["�书����"] do
		local kfid = JY.Person[id]["�书"..i]
		local klvl = JY.Person[id]["�书�ȼ�"..i]
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

--�޾Ʋ������ٻ���ԭ������+ȼľ+���浶
function JuHuoLY(id)
	local juhuonum = 0;
	for i = 1, JY.Base["�书����"] do
		local kfid = JY.Person[id]["�书"..i]
		local klvl = JY.Person[id]["�书�ȼ�"..i]
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

-- ����ħ ��ħ�� ��շ�ħȦ ��ħ�ȷ� �޺���ħ��
function ShiZunXM(id)
	local sm = 0;
	for i = 1, JY.Base["�书����"] do
		local kfid = JY.Person[id]["�书"..i]
		local klvl = JY.Person[id]["�书�ȼ�"..i]
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
--˫���ϱ� ȫ�潣�� + ��Ů��
function ShuangJianHB(id)
	local shuangjiannum = 0;
	for i = 1, JY.Base["�书����"] do
		local kfid = JY.Person[id]["�书"..i]
		local klvl = JY.Person[id]["�书�ȼ�"..i]
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
--�޾Ʋ��������к��棬����+����+����
function LiRenHF(id)
	local lirennum = 0;
	for i = 1, JY.Base["�书����"] do
		local kfid = JY.Person[id]["�书"..i]
		local klvl = JY.Person[id]["�书�ȼ�"..i]
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

--��װ
function Avatar_Switch(id)
	--�ж��Ƿ���
	local Ani_id = id
	if id == 0 and JY.Base["����"] > 0 then
		Ani_id = JY.Base["����"]
	end
	if Avatar[Ani_id] == nil then
		return
	end
	local r = JYMsgBox("һ����װ", "��ѡ��"..JY.Person[id]["����"].."������", {Avatar[Ani_id][1].name,Avatar[Ani_id][2].name}, #Avatar[Ani_id], JY.Person[id]["ͷ�����"])
	JY.Person[id]["ͷ�����"] = Avatar[Ani_id][r].num
	JY.Person[id]["������"] = JY.Person[Ani_id]["������"]
	for i = 1, 5 do
		JY.Person[id]["���ж���֡��" .. i] = Avatar[Ani_id][r].frameNum[i]
		JY.Person[id]["���ж����ӳ�" .. i] = Avatar[Ani_id][r].frameDelay[i]
		JY.Person[id]["�书��Ч�ӳ�" .. i] = Avatar[Ani_id][r].soundDelay[i]
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
				
				if string.len(JY.Person[i]["����"]) == 8 then
					indent = 29
				elseif string.len(JY.Person[i]["����"]) == 6 then
					indent = 14
				end
				
				DrawString(x + 61 - indent, h, JY.Person[i]["����"],color,CC.DefaultFont)
				h = h + space
				
				DrawString(x + 58, h, "LV."..JY.Person[i]["�ȼ�"],color,CC.Fontsmall)
				h = h + space
				
				DrawString(x + 41, h, "���� "..JY.Person[i]["������"],color,CC.Fontsmall)
				h = h + space
				
				DrawString(x + 41, h, "���� "..JY.Person[i]["������"],color,CC.Fontsmall)
				h = h + space
				
				DrawString(x + 41, h, "�Ṧ "..JY.Person[i]["�Ṧ"],color,CC.Fontsmall)
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
				
				if string.len(JY.Person[i]["����"]) == 8 then
					indent = 29
				elseif string.len(JY.Person[i]["����"]) == 6 then
					indent = 14
				end
				
				DrawString(x + 61 - indent, h, JY.Person[i]["����"],color,CC.DefaultFont)
				h = h + space
				
				DrawString(x + 58, h, "LV."..JY.Person[i]["�ȼ�"],color,CC.Fontsmall)
				h = h + space
				
				DrawString(x + 41, h, "���� "..JY.Person[i]["������"],color,CC.Fontsmall)
				h = h + space
				
				DrawString(x + 41, h, "���� "..JY.Person[i]["������"],color,CC.Fontsmall)
				h = h + space
				
				DrawString(x + 41, h, "�Ṧ "..JY.Person[i]["�Ṧ"],color,CC.Fontsmall)
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

--��ң���� and JY.Person[240]["Ʒ��"] == 50
function XiaoYaoYF(id)
	if id ~= 0 then
		return false
	end
	--if PersonKF(id,85) and PersonKF(id,98) and PersonKF(id,101) and JY.Person[634]["Ʒ��"] == 50 then
	if ((PersonKF(id,85) and PersonKF(id,98) and PersonKF(id,101)) or match_ID_awakened(id,634,1))  and  (JY.Person[240]["Ʒ��"] == 80 or not inteam(id)) then	
		return true
	end
	return false
end
--��հ���
function JinGangBR(id)
local jgbrnum = 0
	for i = 1, JY.Base["�书����"] do
		local kfid = JY.Person[id]["�书"..i]
		local klvl = JY.Person[id]["�书�ȼ�"..i]
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
--��ӹ֮��
function ZhongYongZD(id)
    if JY.Person[id]["��ӹ"] == 1 then
		return true
	end
	return false
end
--��ת
function MuRongDZ(id)
	for i = 1, JY.Base["�书����"] do
		if JY.Person[id]["�书"..i] == 43 then
			return true
		end
    end
	return false
end
			
--ѡ���żһԵ��ؼ�
--����������������BABA
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

--�޾Ʋ�����̫��+���ƣ�����˸�
function YiRouKG(id)
	local yirounum = 0;
	for i = 1, JY.Base["�书����"] do
		local kfid = JY.Person[id]["�书"..i]
		local klvl = JY.Person[id]["�书�ȼ�"..i]
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

--��Ŀ�̵�
function zmStore()
	dofile(CC.Acvmts)
	local mrchds = {}
	for i = 1, 4 do
		mrchds[i] = {}
		mrchds[i].num = 0
	end
	mrchds[1].name = "���ڵ�"
	mrchds[1].price = 600
	mrchds[2].name = "���ᵤ"
	mrchds[2].price = 900
	mrchds[3].name = "���ⵤ"
	mrchds[3].price = 600
	mrchds[4].name = "�Ĵ�ɽƤ��"
	mrchds[4].price = 500
	--mrchds[5].name = "��Ԫ��"
	--mrchds[5].price = 300
	--mrchds[6].name = "�޼���"
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
			local thname = JY.Thing[th[1]]['����']
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
		
		DrawString(80,CC.ScreenH - 107,string.format("%-6s %-6s %-6s %-6s","�ܼۣ�",t_price,"��",m_left), C_GOLD,CC.DefaultFont)
		
		DrawString(80,CC.ScreenH - 57,"������£�".. CC.Sp, C_ORANGE, CC.DefaultFont)
		DrawString(400,CC.ScreenH - 50,"���¼�ѡ�� ���Ҽ��������� �س���ȷ�� ESC�˳�",LimeGreen,CC.FontSmall)

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
				DrawString(500,520,"�������㣡", C_RED, CC.FontBig)
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

--���ݶ�����ͼ���㶯�����
function tjmdh(num)
local a = 0

for i = 0,#CC.Effect do
	a = CC.Effect[i] + a
	if num <= a then
	   say(i,0,1)
	   break
	end
	if i == #CC.Effect and num > a then  
	   say('������Χ',0,1)
	   break
	end
end
end

--��������ѡ��˵�
function firstmenu()
	--�趨���ڰٷְ�,��ֹ����Ŵ���С�����»����е����֣���ͼ���ڹ涨λ��
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	
	--���ִ�С
	local size = CC.DefaultFont
	
	--�б�1����ʾ����
	local menu1 = {'��','ѩ','��','��','��','��','¹','��׼����','Ц','��','��','��','��','��','ԧ','��������'}
	
	--�б�1��ʼ����λ��
	local x1,y1 = bx*147,by*74
	
	local x2,y2 = bx*70,by*165
	--�б�1�ļ��
	local jg = bx*80
	
	--�б�2�ļ��
	local n = 15
	
	local menu2 = {	['��'] = {1,2,3,4,72,587},
					['ѩ'] = {633,723,726,728,736},
					['��'] = {37,94,95,96,97,589,52,594,595},
					['��'] = {49,50,53,51,76,46,47,48,103,113,112,114,115,116,117,118,98,99,100,101,104,90,105,102,122,70,634,45,574,44,565,576,499},
					['��'] = {55,56,57,60,61,64,65,67,68,69,78,121,123,128,567,568,588,130,129,605,650,604},
					['��'] = {590,138,137},
					['¹'] = {601,86,87,602,603,150,71,},
					['��׼����'] = {'������ȭ','��Ϭһָ','����һЦ','������','������˫','�������','�����޵�','����ʥ��','����ҩ��'},
					['Ц'] = {19,20,21,22,23,24,25,26,27,28,29,31,32,33,34,35,36,73,79,88,140,141,142,149,458,510,593,649,583},
					['��'] = {74,75,80,151,152,153,154,155,156,313,570,571,569,657,658,656,655,606},
					['��'] = {58,59,63,626,62,84,89,580,161,616,617,160,157,158,159,592,628,627,640},
					['��'] = {38,581,582,39,40,41,42,43,85,164,162,163,636},
					['��'] = {9,609,631,66,646,5,6,7,8,10,11,12,13,14,15,16,17,18,169,170,171,174,81,82,640,647,648,638,586,573,575,597,641,},
					['��'] = {54,91,629,183,184,185,186,607,83,176,639},
					['ԧ'] = {77,566,189,615,614,613,612},
					['��������'] = {'½��','����','˾��ժ��','������','����ˮ','���Ŵ�ѩ','��Ѱ��','����','��Ħ','����','л����','л����','�','������','÷����','����'},
	}

	--������������id
	local tsrw = {	--['�żһ�'] = 651,
                    ['½��'] = 497,
	                ['����'] = 578,
			 		['˾��ժ��'] = 579,
					['������'] = 584,					
					['����ˮ'] = 652,
					['���Ŵ�ѩ'] = 500,
					['��Ѱ��'] = 498,
					['����'] = 637,
					['��Ħ'] = 577,
					['����'] = 635,
					--['��̫��'] = 92,
					['л����'] = 501,
					['л����'] = 596,
					--['�Ĵ�ɽ'] = 642,
                    ['�'] = 504,	
                    ['������'] = 505,
                    ['÷����'] = 507,
                   -- ['Ԭʿ��'] = 658,
                    ['����'] = 721, 
	}	
	--�б�0������¼
	local cot = 1 
	
	local cont = 1 
	local cont1 = 0
	
	--�б�2������¼
	local coxt = 1
	--�б�2������ҳ��¼
	local coxt1 = 0
	local coxt2 = 0
	--��¼��ǰ�˵���������˵���������˵�
	local lb = 2
	local xb = 0
	
	--����
	local cx = 0
	--����
	local zj = 0
	--����
	local ts = 0
	
	local dh = 0
	local fy = 0
	local fymax = 0
	local star = 1

		
	while true do 
		if JY.Restart == 1 then
			break
		end
		--������棬��Ϊ�˵�������ѭ����״̬��������ʾ����ǰ����Ҫ���֮ǰ�Ļ��棬������ͼ���޵���
		ClsN()
		---------------
		
		--�Լ���һ�ű���ͼ������
		lib.LoadPNG(91, 25 * 2 , 0,0, 1)
		
			local m = menu1[cont+cont1*8]
			
			if lb == 3 or lb == 4 then
				local id = coxt + coxt1*6
				local mid = menu2[m][id]
				--lib.LoadPNGPath(string.format('./data/fight/fight%03d',JY.Person[id]["ͷ�����"]), 89, -1, 100)   --ս����ͼ
				if mid ~= nil then
					if m == '��׼����' then 
						--�����ǰ�������ʼ
						local tt = 546
						
						
						--Ů���ǰ�������ʼ 
						if xb == 1 then 
							tt = 555
						end

						lib.LoadPNG(90, (tt+id)* 2 , bx*160,by*370, 2)
						lib.LoadPNG(91, 26 * 2 , 0,0, 1)
						--
						--�츳��ʾ��
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
							
							--״̬���涯����ʾ��89��
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
									
								if string.sub(tfstr,1,2) == "��" then
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
					elseif m == '��������' then 
						local tt = {290,580}
						if tsrw[mid] ~= nil then
							local pic = JY.Person[tsrw[mid]]['������']
							lib.LoadPNG(90, pic* 2 , bx*160,by*370, 2)
						end				
					        lib.LoadPNG(91, 26 * 2 , 0,0, 1)																			
							if tsrw[mid] ~= nil then 
								local tid = tsrw[mid]
								local pic = JY.Person[tid]['ͷ�����']
								
								local hh = 0
								for k = 1,2 do 
									if JY.Person[tid]['�书'..k] > 0 then 
										local kf = JY.Person[tid]['�书'..k]
										DrawString(x2,by*528+(hh)*by*41,JY.Wugong[kf]['����'],C_WHITE,size*0.9);
										hh = hh + 1
									end
								end
								
							--	lib.PicLoadFile(string.format(CC.FightPicFile[1],pic),
							--	string.format(CC.FightPicFile[2],pic), 89)
								
								local zs = 0
								local dl = 0
								for j=1,5 do
									if JY.Person[tid]['���ж���֡��'..j]>0 then
										if j>1 then
											zs = JY.Person[tid]['���ж���֡��'..j]
											break;
										end
										dl = dl+JY.Person[tid]['���ж���֡��'..j]*4
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
										
										if string.sub(tfstr,1,2) == "��" then
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
						lib.LoadPNG(90, JY.Person[mid]['������'] * 2 , bx*160,by*370, 2)
						lib.LoadPNG(91, 26 * 2 , 0,0, 1)
						--
						--�츳��ʾ��
						--
						local hh = 0
						for k = 1,2 do 
							if JY.Person[mid]['�书'..k] > 0 then 
								local kf = JY.Person[mid]['�书'..k]	
								DrawString(x2,by*528+(hh)*by*41,JY.Wugong[kf]['����'],C_WHITE,size*0.9);
								hh = hh + 1
							end
						end

						--״̬���涯����ʾ��89��
						--lib.PicLoadFile(string.format(CC.FightPicFile[1],JY.Person[mid]["ͷ�����"]),
						--string.format(CC.FightPicFile[2],JY.Person[mid]["ͷ�����"]), 89)
						
						local zs = 0
						local dl = 0
						for j=1,5 do
							if JY.Person[mid]['���ж���֡��'..j]>0 then
								if j>1 then
									zs = JY.Person[mid]['���ж���֡��'..j]
									break;
								end
								dl = dl+JY.Person[mid]['���ж���֡��'..j]*4
							end
						end
						
						lib.PicLoadCache(JY.Person[mid]["ͷ�����"]+101,(dl+dh+zs*3)*2,bx*890,by*670)
						
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
										
								if string.sub(tfstr,1,2) == "��" then
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
				DrawString(-1,by*660,'PageUp �Ϸ�ҳ  PageDown �·�ҳ',C_GOLD,size*0.7);
			end

		--if lb == 2 or lb == 3 then
			--��ʾ�����б�
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
		--��ʾ�����б�
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
						if m == '��׼����' then
							DrawString(x2+(i-1)*bx*140,y2+(j-1)*size,mid,cl,size*0.8);
						elseif m == '��������' then
							DrawString(x2+(i-1)*bx*140,y2+(j-1)*size,mid,cl,size*0.8);
						
						else
							DrawString(x2+(i-1)*bx*140,y2+(j-1)*size,JY.Person[mid]['����'],cl,size*0.8);
						end
						
					end
				end
				
			end
			
		----------------
		--��ʾ����
		ShowScreen()
		--ѭ���ļ������ֵ���⣩
		lib.Delay(40)
		--X�Ǽ��̲�����ktype����������ktype = 3 ���������4�����Ҽ���6�����ϣ�7������
		local X,ktype,mx,my = lib.GetKey()
		
		--�ո����enter��Ĭ��ȷ��
		if X == VK_SPACE or X == VK_RETURN then 
			if lb == 2 then 
				lb = 3
			elseif lb == 3 then 
				if menu1[cont+cont1*8] == '��׼����' then 
					lb = 4
				elseif menu1[cont+cont1*8] == '��������' then 
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
				JY.Person[0]['������'] = zj+tt
				break
			end	
		--esc������Ҽ�Ĭ�Ϸ���
		elseif X == VK_ESCAPE or ktype == 4 then
			--ѭ���������˳�
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
							if m == '��׼����' or m == '��������' then
								s = #mid*(size*0.8)/2
							else 
								local name = JY.Person[mid]['����']
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
					if menu1[cont+cont1*8] == '��׼����' then 
						lb = 4
					elseif menu1[cont+cont1*8] == '��������' then 
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
				JY.Person[0]['������'] = zj+tt
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
	T2["��"] = PinkRed
	T2["��"] = LimeGreen
	T2["��"] = C_BLACK
	T2["��"] = C_WHITE
	T2["��"] = C_ORANGE
	T2["��"] = M_DeepSkyBlue
	T2["��"] = Violet
	T2['��'] = C_GOLD
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
		if string.byte(try)>127 then --����
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
            if s == '��' or s == '*' then 
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
				--����������ٽ�����һ��
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

	T2["��"] = PinkRed
	T2["��"] = LimeGreen
	T2["��"] = C_BLACK
	T2["��"] = C_WHITE
	T2["��"] = C_ORANGE
	T2["��"] = M_DeepSkyBlue
	T2["��"] = Violet
	T2['��'] = C_GOLD

	local cx,cy=0,0;
    --local color 
	while string.len(str)>=1 do
		if JY.Restart == 1 then
			break
		end
		local try=string.sub(str,1,1)
		local control=false;

		if string.byte(try)>127 then --����
			local s=string.sub(str,1,2);
			str=string.sub(str,3,-1);

			if T2[s] ~= nil then 
				--color = T2[s]
				control = true;
			end
            
			if not control then
                if s == '��' then 

                else

                    cx=cx+1;
                end
			end

		else
			local s=try
			str=string.sub(str,2,-1);
            if s == '��' or s == '*' then 
                cy = cy + 1 
                cx = 0
            else

                cx=cx+1;
            end
			
		end

		if not control then

			if cx > xnum then
				cx = 0;
				--����������ٽ�����һ��
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
	--����
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	--���ִ�С
	local size = CC.DefaultFont*0.6
	--���ִ�С2
	local size2 = CC.DefaultFont*0.55
	--��������
	local x1,y1 = bx*183,bx*41
	--��������
	local x2,y2 = bx*183,bx*59
	--ͷ������
	local x3,y3 = bx*56,bx*51
	--��������
	local x4,y4 = bx*152,bx*20
	--��Ŀ����
	local x5,y5 = bx*235,bx*20
	--��������
	local x6,y6 = bx*135,bx*82
	--��������
	local x7,y7 = bx*215,bx*82
	--�Ѷ�����
	local x8,y8 = bx*40,bx*110
	--����������С
	local w = bx*78
	local h = bx*7
	--����
	local sm = JY.Person[0]['����']
	--����
	local nl = JY.Person[0]['����']
	--�������
	local smmax = JY.Person[0]['�������ֵ']
	--�������
	local nlmax = JY.Person[0]['�������ֵ']
	--ͷ����
	local hid = JY.Person[0]['������']
	--����
	local name = JY.Person[0]['����']
	--��Ŀ
	local zm = JY.Base["��Ŀ"]..'��Ŀ'
	--��������
	local sx = {'��','��','����','���'}
	--��������
	local nlsx = sx[JY.Person[0]['��������']+1]
	--��������
	local smwz = sm..'/'..smmax
	--��������
	local nlwz = nl..'/'..nlmax..'��'..nlsx..'��'
	--����
	local yl = CC.Gold
	--����
	local ts = JY.Base["��������"]..'��'
	
	--�Ѷ�
	local tnd = math.fmod(JY.Base["�Ѷ�"],#MODEXZ2);
	if tnd == 0 then
		tnd = #MODEXZ2
	end
	tnd = MODEXZ2[tnd]
	
	--��ͨ
	local yxms
	if JY.Base["��ͨ"] == 0 then
		yxms = "��ͨ"
	elseif JY.Base["��ͨ"]==1 then
		yxms = "��ͨ"
	else
		yxms = "����"
	end
	
	--ʱ��
	local t = math.modf((lib.GetTime() - JY.LOADTIME) / 60000 + GetS(14, 2, 1, 4))
	local t1, t2 = 0, 0
	while t >= 60 do
		t = t - 60
		t1 = t1 + 1
	end
	
	t2 = t
	
	--ʱ�䵥ͨ�Ѷ���Ϣ
	local xx = tnd..' '..yxms..' '..string.format("%2dʱ%2d��", t1, t2)
	local xx = tnd..'/ '..yxms..'/ '.."����"..JY.Person[0]['Ʒ��']
	lib.LoadPNG(91, 39*2, 0, 0, 1)
	--ͷ����ͼ
	lib.LoadPNG(1, hid*2, x3, y3, 2)
	--����ͼ
	lib.LoadPNG(91, 40*2, 0, 0, 1)
	--������
	lib.SetClip(x1-w,y1-h,(x1-w)+(w*2)*(sm/smmax),y1+h)
	lib.LoadPNG(91, 41*2, x1, y1, 2)
	lib.SetClip(0,0,0,0)
	--������
	lib.SetClip(x2-w,y2-h,(x2-w)+(w*2)*(nl/nlmax),y2+h)
	lib.LoadPNG(91, 42*2, x2, y2, 2)
	lib.SetClip(0,0,0,0)
	
	--����
	DrawString(x4-string.len(name)/4*size,y4-size/2,name,C_GOLD,size)
	--��Ŀ
	DrawString(x5-string.len(zm)/4*size2,y5-size/2,zm,C_WHITE,size2)
	--����
	DrawString(x1-string.len(smwz)/4*size2,y1-size2/2,smwz,C_WHITE,size2)
	--����
	DrawString(x2-string.len(nlwz)/4*size2,y2-size2/2,nlwz,C_WHITE,size2)
	--����
	DrawString(x6,y6-size2/2,yl,C_WHITE,size2)
	--����
	DrawString(x7,y7-size2/2,ts,C_WHITE,size2)
	--ʱ�䵥ͨ�Ѷ���Ϣ
	DrawString(x8,y8-size2/2,xx,C_GOLD,size2*1.1)
end

function Cat(s,...)
	if not Ct[s] then 
		lib.Debug('����δ֪����')
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
	local menu = {'����','��Ʒ',MJMenu,'����'}
	local menu2 = {'״̬','����','���'}
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
			local id = JY.Base["��Ʒ" .. i + 1]
			if id >= 0 then
				if JY.Thing[id]["����"] == 2 then
					thing[num] = id
					thingnum[num] = JY.Base["��Ʒ����" .. i + 1]
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
			local id = JY.Base["��Ʒ" .. i + 1]
			if id >= 0 then
				if flag == nil then 
					thing[num] = id
					thingnum[num] = JY.Base["��Ʒ����" .. i + 1]
					num = num + 1
				else 	
					if JY.Thing[id]["����"] == flag then
						thing[num] = id
						thingnum[num] = JY.Base["��Ʒ����" .. i + 1]
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
			if JY.Base['����'..ii] >= 0 then 
				menu[#menu+1] = {p[JY.Base['����'..ii]]['����'],JY.Base['����'..ii]}
			end
		end
		if maxn > #menu then 
			maxn = #menu 
		end	 
		lib.PicLoadCache(92,9*2,0,0,1,nil,nil,bx*936)

		for ii = 1,maxn do 
			local h = 0
			local pyx = 0
			if CC.Png[p[menu[ii+cont1][2]]['������']] ~= nil then 
				pyx = CC.Png[p[menu[ii+cont1][2]]['������']]
			end
			
			local sm = p[menu[ii+cont1][2]]['����']
			local smmax = p[menu[ii+cont1][2]]['�������ֵ']
			local nl = p[menu[ii+cont1][2]]['����']
			local nlmax = p[menu[ii+cont1][2]]['�������ֵ']
			local tl = p[menu[ii+cont1][2]]['����']
			local tlmax = 100
			
			lib.SetClip(bx*42+(ii-1)*bx*220, 0, bx*38+(ii-1)*bx*220+bx*197,by*768) --�˵�����ͼ
			lib.LoadPNG(90,p[menu[ii+cont1][2]]['������']*2,bx*138+(ii-1)*bx*220-bx*pyx,by*250,2)
			lib.SetClip(0,0,0,0)
			
			lib.PicLoadCache(92,15*2,bx*138+(ii-1)*bx*220,by*425,2,256,nil,bx*170)
			
			DrawString(bx*138+(ii-1)*bx*220-string.len(menu[ii+cont1][1])*size/4,by*440,menu[ii+cont1][1],C_WHITE,size)
			if ii == cont or px == ii then 
				lib.PicLoadCache(92,10*2,bx*138+(ii-1)*bx*220, CC.ScreenH/2,2,256,nil,bx*200) --�˵�����ͼ
			end

			h = h + 1
			
			local tfid = menu[ii+cont1][2]
			if JY.Base['����'] > 0 and tfid == 0 then 
				tfid = JY.Base['����']
			end	
			if RWWH[tfid] ~= nil then 
				DrawString(bx*60+(ii-1)*bx*220,by*440+h*by*30,'�ƺţ�'..RWWH[tfid],LimeGreen,size)
			end
			
			h = h + 1
			
			if RWTFLB[tfid] ~= nil then 
				DrawString(bx*60+(ii-1)*bx*220,by*440+h*by*30,'�츳��'..RWTFLB[tfid],LimeGreen,size)
			end
			
			h = h + 1
			
			lib.PicLoadCache(92,11*2,bx*138+(ii-1)*bx*220,by*450+h*by*30+size1/2,2,256,nil,bx*160)
			
			lib.SetClip(bx*138+(ii-1)*bx*220-bx*71, by*450+h*by*30+size1/2-by*12, bx*138+(ii-1)*bx*220-bx*71+bx*142*(sm/smmax),by*450+h*by*30+size1/2+by*12)
			lib.PicLoadCache(92,12*2,bx*138+(ii-1)*bx*220,by*450+h*by*30+size1/2,2,150,nil,bx*160)
			lib.SetClip(0,0,0,0)

			DrawString(bx*70+(ii-1)*bx*220,by*450+h*by*30,'��  '..p[menu[ii+cont1][2]]['����'],C_WHITE,size1)
			h = h + 1
			
			lib.PicLoadCache(92,11*2,bx*138+(ii-1)*bx*220,by*450+h*by*30+size1/2,2,256,nil,bx*160)
			lib.SetClip(bx*138+(ii-1)*bx*220-bx*71, by*450+h*by*30+size1/2-by*12, bx*138+(ii-1)*bx*220-bx*71+bx*142*(nl/nlmax),by*450+h*by*30+size1/2+by*12)
			lib.PicLoadCache(92,13*2,bx*138+(ii-1)*bx*220,by*450+h*by*30+size1/2,2,150,nil,bx*160)
			lib.SetClip(0,0,0,0)

			DrawString(bx*70+(ii-1)*bx*220,by*450+h*by*30,'��  '..p[menu[ii+cont1][2]]['����'],C_WHITE,size1)
			h = h + 1
			
			lib.PicLoadCache(92,11*2,bx*138+(ii-1)*bx*220,by*450+h*by*30+size1/2,2,256,nil,bx*160)
			lib.SetClip(bx*138+(ii-1)*bx*220-bx*71, by*450+h*by*30+size1/2-by*12, bx*138+(ii-1)*bx*220-bx*71+bx*142*(tl/tlmax),by*450+h*by*30+size1/2+by*12)
			lib.PicLoadCache(92,14*2,bx*138+(ii-1)*bx*220,by*450+h*by*30+size1/2,2,150,nil,bx*160)
			lib.SetClip(0,0,0,0)

			DrawString(bx*70+(ii-1)*bx*220,by*450+h*by*30,'��  '..p[menu[ii+cont1][2]]['����'],C_WHITE,size1)
		end
	  
		ShowScreen()
		lib.Delay(CC.BattleDelay)
		local X,ktype,mx,my = lib.GetKey()
		if X == VK_SPACE or X == VK_RETURN then 
			tru = cont + cont1
			local id = JY.Base['����'..tru]
			if tab ~= nil then
				if tab[1] == '���' then
					if tru > 1 then
						if JY.SubScene == 55 and JY.Base["����" .. tru] == 35 then
						elseif JY.SubScene == 82 then	
						else
							local personid = JY.Base["����" .. tru]
							if CC.PersonExit[personid] ~= nil then 
								local v = CC.PersonExit[personid]
								CallCEvent(v)
							end
							cont = 1
							cont1 = 0
						end
					end
				elseif tab[1] == '״̬' then 
					ShowPersonStatus(tru)
				elseif tab[1] == '����' then
					if px == 0 then
						if tru > 1 then 
							px = cont
						end
					else 
						if tru > 1 then
							JY.Base['����'..tru] = JY.Base['����'..px+cont1]
							JY.Base['����'..px+cont1] = id
							px = 0
						end
					end
				end
			else 
				break
			end
		elseif X == VK_ESCAPE or ktype == 4 then
			if tab ~= nil then
				if tab[1] == '���' then 
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
				local id = JY.Base['����'..tru]
				if tab ~= nil then
			if tab[1] == '���' then
					if tru > 1 then
						if JY.SubScene == 55 and JY.Base["����" .. tru] == 35 then
						elseif JY.SubScene == 82 then	
						else
							local personid = JY.Base["����" .. tru]
							if CC.PersonExit[personid] ~= nil then 
								local v = CC.PersonExit[personid]
								CallCEvent(v)
							end
							cont = 1
							cont1 = 0
						end
					end
					elseif tab[1] == '״̬' then 
						ShowPersonStatus(tru)
					elseif tab[1] == '����' then
						if px == 0 then
							if tru > 1 then 
								px = cont
							end
						else 
							if tru > 1 then
								JY.Base['����'..tru] = JY.Base['����'..px+cont1]
								JY.Base['����'..px+cont1] = id
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
	if p["�����ڹ�"] > 0 then
        local zy = p["�����ڹ�"] 
  
        --[[
        for i = 1, JY.Base["�书����"] do
            local kf = p["�书" .. i]
            local lv = p["�书�ȼ�" .. i]
            local dj = math.modf(lv/100)+1
            local wl = get_skill_power(id, kf, dj)
            if JY.Wugong[kf]['�书����'] == 6 then 
                if wgwl < wl then 
                    wgwl = wl
                end
            end
        end
        ]]

		for i = 1, JY.Base["�书����"] do
			if p["�书" .. i]== p["�����ڹ�"] then
				kflvl = p["�书�ȼ�" .. i]
				break
			end
		end
		if kflvl == 999 then
			kflvl = 11
		else
			kflvl = math.modf(kflvl/100)+1
		end
		wgwl2 = get_skill_power(id, p["�����ڹ�"], kflvl)	
        if id == 0 and (JY.Base["��׼"] == 6  or  JY.Base["����"] == 637 or  JY.Base["����"] == 27 or JY.Base["����"] == 189 ) then
		    for i = 1, JY.Base["�书����"] do
		    if p["�书" .. i]== p["�츳�ڹ�"] then
                wgwl1 = get_skill_power(id, p["�츳�ڹ�"], kflvl)
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
			p["�������ֵ"] = p["��������"]  * p["�ȼ�"]*4+500+p["��������"]*(wgwl/5-140)  			
		elseif 1400 > wgwl and wgwl >= 1200 then	
			p["�������ֵ"] = p["��������"]  * p["�ȼ�"]*4+400+p["��������"]*(wgwl/5-140)
		elseif 1200 > wgwl and wgwl >= 1000 then		
			p["�������ֵ"] = p["��������"]  * p["�ȼ�"]*4+300+p["��������"]*(wgwl/5-150)	   
		elseif 1000 > wgwl and wgwl >= 800 then		
			p["�������ֵ"] = p["��������"]  * p["�ȼ�"]*4+200+p["��������"]*(wgwl/5-140)					
		elseif wgwl <= 600  then		
			p["�������ֵ"] = p["��������"]  * p["�ȼ�"]*4+100+p["��������"]*10	
		end		
]]
        if wgwl < 500 then 
            wgwl = 500
        end
		p["�������ֵ"] = p["��������"]  * p["�ȼ�"]*4+500+p["��������"]*(wgwl/7-100)  
		if p["����"] >  p["�������ֵ"] then
         	p["����"] =  p["�������ֵ"]
		end
		if JY.Status ~= GAME_WMAP then
			AddPersonAttrib(id,'����',math.huge)
		else 
			p["����"] = limitX(p["����"],0,p["�������ֵ"])
		end	
	else	
		p["�������ֵ"] = p["��������"] * p["�ȼ�"]*4
		if id == 0 and (JY.Base["��׼"] == 6  or  JY.Base["����"] == 637  or  JY.Base["����"] == 27 or JY.Base["����"] == 189 ) then
            for i = 1, JY.Base["�书����"] do
                if p["�书" .. i]== p["�츳�ڹ�"] then
                    kflvl = p["�书�ȼ�" .. i]
                    break
                end
            end
            if kflvl == 999 then
                kflvl = 11
            else
                kflvl = math.modf(kflvl/100)+1
            end
		    wgwl = get_skill_power(id, p["�츳�ڹ�"], kflvl)
            --[[
		    if wgwl >= 1400 then	
			    p["�������ֵ"] = p["��������"]  * p["�ȼ�"]*4+500+p["��������"]*(wgwl/5-140)  			
		    elseif 1400 > wgwl and wgwl >= 1200 then	
			    p["�������ֵ"] = p["��������"]  * p["�ȼ�"]*4+400+p["��������"]*(wgwl/5-140)
		    elseif 1200 > wgwl and wgwl >= 1000 then		
			   p["�������ֵ"] = p["��������"]  * p["�ȼ�"]*4+300+p["��������"]*(wgwl/5-150)	   
		   elseif 1000 > wgwl and wgwl >= 800 then		
			   p["�������ֵ"] = p["��������"]  * p["�ȼ�"]*4+200+p["��������"]*(wgwl/5-140)					
		   elseif wgwl <= 600  then		
			   p["�������ֵ"] = p["��������"]  * p["�ȼ�"]*4+100+p["��������"]*10	
		   end	
        ]]
        
            if wgwl < 500 then 
                wgwl = 500
            end
            
            p["�������ֵ"] = p["��������"]  * p["�ȼ�"]*4+500+p["��������"]*(wgwl/7-100)  
		end
        
        
		if p["����"] >  p["�������ֵ"] then
         	p["����"] =  p["�������ֵ"]
		end
		if JY.Status ~= GAME_WMAP then
			AddPersonAttrib(id,'����',math.huge)
		else 
			p["����"] = limitX(p["����"],0,p["�������ֵ"])
		end		
	end
end

function tgsave(flag)
	
	local tgjl = 0
	local tg = 0
	local tgsize = 0
	if flag == nil then
		if CC.Week < 100 then
			if JY.Base["��Ŀ"] == CC.Week then
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
    JY.Base["�Ѷ�"] = 1
	local m = { {'��Ŀѡ��','��Ŀ�̵�'},
                {'��ͨ','��ͨ','����'},
                {'��','��ͨ','����','����'},
                {'��һ��'},
                }
    local sz = {{582,161,180},
                {556,328,120},
                {518,489,105},
                {818,656,0},
                }        

    local sm = {'���ҷ����ѿ��Բμ�ս�����ҷ�ս���ϳ�����Ϊ6�ˣҡ���ʾ����ģʽΪ����ģʽ��һ���Դ�ģʽΪ��׼��',
                '������ս��ֻ�����ǿ��Բ�ս�ҡ�֣����ʾ����ģʽΪ��Űģʽ����������޷���Ϸ�ĺ���������е���ģʽ����������ģʽ��������Ȩ������BB����',
                '������ս��ֻ�����ǿ��Բ�ս���������������ڶԶ��ѵ������츳�ҡ���ʾ����ģʽΪ����ģʽ��������ҫ��'
}
    local zmmax = CC.Week
    local w = math.modf(bx*350/size/0.96)
	while true do 
        if JY.Restart == 1 then
            break
        end	
		ClsN()
        local zm = JY.Base["��Ŀ"]
        if page ==2 then 
            lib.LoadPNG(91,48*2,0,0,1)
            tjm(bx*52,by*108,sm[tb],C_WHITE,size*0.96,w,size*1.6)
        else
            lib.LoadPNG(91,44*2,0,0,1)
            DrawString(bx*159-string.len(zm)/4*size,by*433-size/2,zm,C_RED,size)
            DrawString(bx*159-string.len(zmmax)/4*size,by*468-size/2,zmmax,C_RED,size)
            DrawString(bx*150,by*504-size/2,m[3][JY.Base["�Ѷ�"]],C_RED,size)
            DrawString(bx*150,by*538-size/2,m[2][JY.Base["��ͨ"]+1],C_RED,size)
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
                    JY.Base["��Ŀ"] = InputNum("ѡ����Ŀ",1,zmmax);
                else
                    zmStore()
                end
            elseif page == 2 then 
                JY.Base["��ͨ"] = tb - 1
            elseif page == 3 then 
                JY.Base["�Ѷ�"] = tb
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
                        JY.Base["��Ŀ"] = InputNum("ѡ����Ŀ",1,zmmax);
                    else
                        zmStore()
                    end
                elseif page == 2 then 
                    JY.Base["��ͨ"] = tb - 1
                elseif page == 3 then 
                    JY.Base["�Ѷ�"] = tb
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
	local m = { {'����','����','����'},
                {'1-30','31-50','51-79','80-100'},
                {'��һ��'},
                }
    local sz ={{520,327,155},
               {520,488,105},
		       {818,656,0},
                }  
    local nlsm = {
                    '���������ڹ�������������ʱ���Ѫ����������ͻ����*�����д�˵�������ڹ�֮��Ī�������񹦣����������߱������߱����˺���ֻҪ���ֱ��ö���û�л���֮���������������澭�����칦���������е��书�õ����޴ӷ�����*�Ƽ��ڹ��������񹦣������񹦣����칦����Ϣ������������*�Ƽ��Ṧ:�����귭�������ݣ���������',
                    '���������ڷ��������ʤһ�ʱ����ڡ��ظ���Ѩ�������������������˵�����ͻ����*�����д�˵�������ڹ�֮��Ī�������񹦣��������٤�񹦣���������������㹦��Ǭ����Ų�Ƶ��÷�������������',               
                    '�������������߽���������ͣ������¾�ѧ�ڹ����׽���׽��ѹǣ�����������������Χ���ԣ����޺���ħ������ղ�����һ�����������ض����������������в��ױ��֡�',  
                    }

    local zzsm = {'�����书��̫���񹦣����һ���',
                 '�����书�����һ���',
                 '������ѧ����ӹ֮��',
                 '������ѧ��̫���񹦡���ת����',
                 }
    p["��������"] = 0
    local w = math.modf(bx*333/size)
	while true do 
        if JY.Restart == 1 then
            break
        end	
		ClsN()
        local zz = JY.Person[0]["����"]
	 
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
        DrawString(bx*70,by*99,"��������",M_Wheat,size)
        DrawString(bx*70+size*5,by*99,m[1][p["��������"]+1],C_RED,size)
        
        DrawString(bx*260,by*97,'����',M_Wheat,size)
		DrawString(bx*260+size*3,by*97,zz,C_RED,size)
        
        local n = 0
        if page == 1  then
            n = tjm(bx*68,by*130,nlsm[tb],C_WHITE,size,w,size)
        else 
            n = tjm(bx*68,by*130,nlsm[p["��������"]+1],C_WHITE,size,w,size)
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
                 p["��������"] = tb - 1
            elseif page == 2 then 
				if tb == 1 then
					JY.Person[0]["����"] = InputNum("��������",1,30)					
				elseif tb == 2 then
					JY.Person[0]["����"] = InputNum("��������",31,50)
				elseif tb == 3 then
					JY.Person[0]["����"] = InputNum("��������",51,79)  
				elseif tb == 4 then
					JY.Person[0]["����"] = InputNum("��������",80,100)					
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
                       p["��������"] = 0
					elseif tb == 2 then
						   p["��������"] = 1				
					elseif tb == 3 then
                        p["��������"] = 2
				    end
               elseif page == 2 then 
				   if tb == 1 then
					   p["����"] = InputNum("��������",1,30)
				   elseif tb == 2 then
					  p["����"] = InputNum("��������",31,50)
				   elseif tb == 3 then
					   p["����"] = InputNum("��������",51,79)  
				   elseif tb == 4 then
					   p["����"] = InputNum("��������",80,100)					
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
        local dtf = '��'
        local xtf = '��'
        
        DrawString(bx*63,by*100-size/2,'��ѡ�츳',M_Wheat,size)
        
        if jl > 0 then 
            if CC.PTFSM[jl] ~= nil then 
                local ptf = CC.PTFSM[jl][2]
                dtf = CC.PTFSM[jl][1]
                if ptf ~= nil then 
                    n = tjm(bx*63,by*100-size/2 + size,ptf,C_WHITE,size,w,size)
                end   
            end
        else 
            n = tjm(bx*63,by*100-size/2 + size,'û���츳',C_WHITE,size,w,size)
        end
        n = n + 2
        DrawString(bx*190,by*100-size/2,dtf,C_RED,size)
        
        if cot + cot1*4 == #menu then 
            DrawString(bx*818-1.5*size,by*656-size/2,'��һ��',C_RED,size)
        else    
            DrawString(bx*818-1.5*size,by*656-size/2,'��һ��',M_Wheat,size)
        end
        
        DrawString(bx*63,by*100-size/2+ size + n*size,'��ǰ�츳',M_Wheat,size)
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

        
        --ȱʧ����ͼ���޷�������
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
        menu[n] = {JY.Person[i]['����'],nil,1,i}
    end
end

CC.HSLJ = {}
while #CC.HSLJ < 50 do 
	   if JY.Restart == 1 then
            break
       end	
    Cls()
    local r = ShowMenu4(menu,#menu,5,-2,-2,-2,-2,1,1,CC.DefaultFont,C_GOLD,C_WHITE,"��ѡ����Ҫ�ϳ�������50�ˣ�"..#CC.HSLJ,C_ORANGE, C_WHITE,10)
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
    local r = ShowMenu4(menu,#menu,5,-2,-2,-2,-2,1,1,CC.DefaultFont,C_GOLD,C_WHITE,"��ѡ����Ҫ�ϳ�������50�ˣ�"..#CC.HSLJ2,C_ORANGE, C_WHITE,10)
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

--���͵�ַ�б�
function My_ChuangSong_List()
	local menu = {};
	for i = 0, JY.SceneNum-1 do
		--����ʾ�ĳ�������������1 3 ���̵ص����߲��Թ�+ɳĮ����3�� ������ ˼���� ÷ׯ���� �󹦷��ؽ� ����ɽ�� ¹��ɽ1 3 ���ֺ�ɽ �ʹ� �������� �������� ��ɽ���� ����ȵ� ��Ĺ�ܵ� ��ü�� ȵ�� ��ɽ���
		--����� ���¶� ��ɽ�ض� ���ϳ����� ������ С�� �������� ������
		if i == 5 or i == 85 or i == 13 or i == 14 or i == 15 or i == 86 or i == 88 or i == 89 
		or i == 28 or (i >= 81 and i <= 83) or i == 42 or i == 67 or i == 91 or i == 106 
		or i == 108 or i == 109 or i == 110 or i == 111 or i == 113 or i == 114 or i == 116 
		or i == 117 or i == 104 or i == 119 or i == 102 or i == 122 or i == 123 or i == 124 
		or i == 134 or i == 70 or i == 131 or i == 115 or i == 137 or i == 138 or i == 140 or i == 141 
		or i==126 or i==125 or i == 142 or i == 143 or i == 144 or i == 145 or i== 146 then
		
		else
			--�޾Ʋ���������i��Ϊ�������
			menu[i+1] = {JY.Scene[i]["����"], JY.Scene[i]["��������"], i, JY.Scene[i]["��������"]};	
		end
	end

	--��ɫ����Ϊ������ɫ��ѡ����ɫ
	local r = TeleportMenu(menu, C_GOLD, C_WHITE);
	
	--����ֵС��0��ESC����ֱ�ӷ���
	if r < 0 then
		return 0;
	end
	
	--����ֵ���ڵ���0������ֵ��Ϊ�������
	if r >= 0 then	
		local sid = r;

		
		My_Enter_SubScene(sid,-1,-1,-1);
	end
	return 1;
end

--��ǿ�洫�͵�ַ�˵�
function My_ChuangSong_Ex()     
	local title = "��Ӷ��";
	local str = JY.Person[0]["���"].."��ȥʲô�ط���*·����������*��ԶҲ�����͵�";
	local btn = {"ָ�㽭ɽ", "��������"};
	local num = #btn;
	local r = JYMsgBox(title,str,btn,num,119,1);
	if r == 1 then
		return My_ChuangSong_List();
	elseif r == 2 then
		Cls();
		local sid = InputNum("��������",0,JY.SceneNum-1,1);
		if sid ~= nil then			
			--��ע��������ʾ�ģ���������1 3 ���̵ص����߲��Թ�+ɳĮ����3�� ������ ˼���� ÷ׯ���� �󹦷��ؽ� ����ɽ�� ¹��ɽ1 3 ȵ�� ���ϳ�����
			if sid == 5 or sid == 85 or sid == 13 or sid == 14 or sid == 15 or sid == 86 or sid == 88 or sid == 89 
				or sid == 28 or (sid >= 81 and sid <= 83) or sid == 42 or sid == 67 or sid == 91 or sid == 106 
				or sid == 108 or sid == 109 or sid == 110 or sid == 111 or sid == 113 or sid == 114 or sid == 116 
				or sid == 117 or sid == 104 or sid == 119 or sid == 102 or sid == 122 or sid == 123 or sid == 124 
				or sid == 134 or sid == 70 or sid == 131 or sid == 115 or sid == 137 or sid == 138 or sid == 140 or sid == 141 
				or sid==126 or sid==125 or sid == 142 or sid == 143 or sid == 144 or sid == 145 or sid== 146 or JY.Scene[sid]["��������"] == 1 then
				say("������Ŀǰ���ܽ���˳�����", 119, 5, "����");
				return 1;
			else
				My_Enter_SubScene(sid,-1,-1,-1);
			end
		end
	end
end

--��������
function LianGong(lx)
	JY.Person[591]["�ȼ�"] = 1
	JY.Person[591]["��������"] = lx
	local id = math.random(190)
	JY.Person[591]["ͷ�����"] = JY.Person[id]["ͷ�����"]
	for i = 1,5 do 
		JY.Person[591]["���ж���֡��"..i] = JY.Person[id]["���ж���֡��"..i]
		JY.Person[591]["���ж����ӳ�"..i] = JY.Person[id]["���ж����ӳ�"..i]
		JY.Person[591]["�书��Ч�ӳ�"..i] = JY.Person[id]["�书��Ч�ӳ�"..i]
	end
	JY.Person[591]["������"] = JY.Person[id]["������"]
	JY.Person[591]["�������ֵ"] = 10
	JY.Person[591]["����"] = JY.Person[591]["�������ֵ"]
    JY.Person[591]["����ֽ�"] = 7
	instruct_6(226, 8, 0, 1)
	JY.Person[591]["��������"] = 0
	light()
	--return 1;
end

--�书��Ч˵��
function WuGongIntruce()
	local menu = {};
	
	for i = 1, JY.WugongNum-1 do
		menu[i] = {i..JY.Wugong[i]["����"], nil, 0}
	end
	
	--ӵ�е��ؼ�
	for i = 1, CC.MyThingNum do
    if JY.Base["��Ʒ" .. i] > -1 and JY.Base["��Ʒ����" .. i] > 0 then
    	local wg = JY.Thing[JY.Base["��Ʒ" .. i]]["�����书"];
    	if wg > 0 then
    		menu[wg][3] = 1;
    	end
    else
    	break;
    end
  end
  
  --ѧ����书
  for i=1, CC.TeamNum do
  	if JY.Base["����"..i] >= 0 then
  		for j=1, 10 do
  			if JY.Person[JY.Base["����"..i]]["�书"..j] > 0 then
  				menu[JY.Person[JY.Base["����"..i]]["�书"..j]][3] = 1;
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
		
		r = ShowMenu2(menu,JY.WugongNum-1,4,12,10,(CC.ScreenH-12*(CC.DefaultFont+CC.RowPixel))/2+20,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE, "��ѡ��鿴���书", r);
		--local r = ShowMenu(menu,n,15,CC.ScreenW/4,20,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);
		
		if r > 0 and r < JY.WugongNum then	
			InstruceWuGong(r);
		else
			break;
		end
	end
	
end

--��ʾ�书���ڹ���Ч
function InstruceWuGong(id)
	if id < 0 or id >= JY.WugongNum then
		QZXS("�书δ֪�����޷��鿴");
		return;
	end
	local filename = string.format("%s%d.txt", CONFIG.WuGongPath,id)
	if existFile(filename) == false then
		QZXS("���书δ�����κ�˵������������ĥ");
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

--��ʾ�书���ڹ���Ч
function InstruceTS(id)
		
	local filename = string.format("%s%d.txt", CONFIG.HelpPath,id)
	if existFile(filename) == false then
		QZXS("δ�ҵ���صĹ����ļ�");
		return;
	end
	
	DrawTxt(filename);
end

function DrawTxt(filename)
	Cls();
	
	--��ȡ�ļ�˵��
	local file = io.open(filename,"r")
	local str = file:read("*a")
	file:close()
	
	local size = CC.DefaultFont;
	local color = C_WHITE;
	
	local linenum = 50;		--��ʾ����
	local maxlen = 14;
	local w = linenum*size/2 + size;
	local h = maxlen*(size+CC.RowPixel) + 2*CC.RowPixel;
	
	local bx = (CC.ScreenW-w)/2;
	local by = (CC.ScreenH-h)/2;
	DrawBox(bx,by,bx+w,by+h,C_WHITE);		--�ױ߿�
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
			
			if l+#v[1] < linenum and index == nil then		--���δ�����У�û���ҵ�����
				DrawString(x + l*size/2, y + row*(size+CC.RowPixel), v[1], v[2] or color, size);
				l = l + #v[1]

				if i == #strcolor then
					--��ʾ����	ALungky:j �ĳ� j+1�����ĩβ������ʱ���޷���ʾ�����⡣
					for j=0, l do
						lib.SetClip(x,y,x+(j+1)*size/2,y+size+row*(size+CC.RowPixel));
						ShowScreen(1);
					end
					lib.SetClip(0,0,0,0);
				end
				break;
			else	--����ﵽ����
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
				
				--��������ж��Ƿ��Ѿ�����v[1]��������ݲ���
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
					
	
					if math.fmod(flag,2) == 1 and index == nil  then		--��������е��ַ�
							if string.byte(tmp, -1) > 127 then
								tmp = string.sub(v[1], 1, pos1-1);
								pos2 = pos2 - 1
							end
					end
	
					v[1] = string.sub(v[1], pos2);
				end
					
	
					DrawString(x + l*size/2, y + row*(size+CC.RowPixel), tmp, v[2] or color, size);
	
	
					l = l + #tmp
					--��ʾ����
					for j=0, l do
						lib.SetClip(x,y,x+j*size/2,y+size+row*(size+CC.RowPixel));
						ShowScreen(1);
					end
					
					--����+1
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

--ʮ�ı�����֮��õ�5000��
--�޸��Զ�ϴ���񼼵�BUG
function NEvent2(keypress)
    --[[
	if JY.SubScene == 70 and GetD(70, 3, 0) == 0 and instruct_18(151) then
		instruct_3(70, 3, 1, 0, 0, 0, 0, 2610, 2610, 2610, 0, -2, -2)
	end
	if GetD(70, 3, 5) == 2610 and JY.SubScene == 70 and JY.Base["��X1"] == 8 and JY.Base["��Y1"] == 41 and JY.Base["�˷���"] == 2 and (keypress == VK_SPACE or keypress == VK_RETURN) then
		say("���ף�����ֽ�������ȣ�"..JY.Person[0]["���2"].."���������������ǧ�����ӣ��ú�׼��һ�°ɣ��ȹ������ϼһﻹ�ܹ���˼�",0,1)
		instruct_2(174, 5000)
		SetS(10, 0, 17, 0, 1)
		SetD(83, 48, 4, 882)
		say("�����ﻹ��һ���ؼ������ҿ�һ�¡���",0,1)
		local hid = 0
		if JY.Base["��׼"] > 0 then
			if JY.Person[0]["�Ա�"] == 0 then
				hid = 280 + JY.Base["��׼"]
			else
				hid = 500 + JY.Base["��׼"]
			end
		elseif JY.Base["����"] > 0 then
			if JY.Person[0]["�Ա�"] == 0 then
				hid = 290
			else
				hid = 510
			end
		else
			hid = JY.Person[0]["������"]
		end
		local r = JYMsgBox("��ѡ��", "�Ƿ�Ҫϴ��һ���书��*һ��Ұ��ȭ*������ɽ����*�������ϵ���*�ģ���������", {"һ","��","��","��","����"}, 5, hid)
		if r == 1 then
			instruct_35(0, 0, 109, 999)
			DrawStrBoxWaitKey("��ѧ���ˡ���Ұ��ȭ�ϡ�", C_ORANGE, CC.DefaultFont, 2)
		elseif r == 2 then
			instruct_35(0, 0, 110, 999)
			DrawStrBoxWaitKey("��ѧ���ˡ�����ɽ�����ϡ�", C_ORANGE, CC.DefaultFont, 2)
			instruct_2(55, 1)
		elseif r == 3 then
			instruct_35(0, 0, 111, 999)
			DrawStrBoxWaitKey("��ѧ���ˡ������ϵ����ϡ�", C_ORANGE, CC.DefaultFont, 2)
			instruct_2(56, 1)
		elseif r == 4 then
			instruct_35(0, 0, 112, 999)
			DrawStrBoxWaitKey("��ѧ���ˡ��Ǡ������գϡ�", C_ORANGE, CC.DefaultFont, 2)
			instruct_2(57, 1)
		end
		instruct_3(70, 3, 1, 0, 0, 0, 0, 2612, 2612, 2612, 0, -2, -2)
	end
    ]]
end

--��� ���˷����ҽ���
function NEvent3(keypress)
	if JY.SubScene == 24 and JY.Base["��X1"] == 18 and JY.Base["��Y1"] == 23 and JY.Base["�˷���"] == 2 and (keypress == VK_SPACE or keypress == VK_RETURN) and GetS(10, 0, 3, 0) ~= 1 and instruct_16(1) and instruct_18(145) then
		say("������������Ѿ��ҵ�ѩɽ�ɺ��Ȿ���ˡ�", 1, 0)
		say("���ţ��ܺã�������ĺ��ҵ���Ҳ������¯�����ˣ��Ժ�Ľ����Ϳ�������Щ�����˵��ˣ��Ȿ��ҽ�������ȥ�ɣ�", 3,4)
		say("����л�������", 1, 0)
		instruct_35(1, 1, 44, 0)
		DrawStrBox(-1, -1, "���ѧ����ҽ���", C_ORANGE, CC.DefaultFont)
		ShowScreen()
		lib.Delay(800)
		Cls()
		instruct_2(117, 1)
		SetS(10, 0, 3, 0, 1)
	end
end

--��������
function NEvent4(keypress)
	if JY.SubScene == 7 and JY.Base["��X1"] == 34 and JY.Base["��Y1"] == 11 and JY.Base["�˷���"] == 2 then
		--������ڶӣ��оŽ��ؼ�
		if instruct_16(35) and instruct_18(114) and GetS(10, 1, 1, 0) ~= 1 and (keypress == VK_SPACE or keypress == VK_RETURN) then
			SetS(7, 34, 12, 3, 102)
			instruct_3(7, 102, 1, 0, 0, 0, 0, 7148, 7148, 7148, 0, 34, 12)
			say("�����֣����������ʶһ�¶���ǰ���ķ�ɰ�������ܸо����ԾŽ������µ����򣬵��ֺ�ģ�������ܾ����ܽ������", 35, 1)
			say("������������������ʱ���ˣ�", 140, 0)
			say("����̫ʦ�壡����", 35,1)
			instruct_14()
			SetS(7, 33, 12, 3, 101)
			instruct_3(7, 101, 1, 0, 0, 0, 0, 5896, 5896, 5896, 0, 33, 12)
			instruct_13()
			PlayMIDI(24)
			lib.Delay(500)
			say("�����������һ�𳪣��׺�һ��Ц����������������������ֻ�ǽ񳯡�����Ц���׷����ϳ���˭��˭ʤ����֪������ɽЦ������ң�������Ծ��쳾����֪���١����Ц���Ǽ��ȡ����黹ʣһ�����ա�����Ц�����ټ��ȡ��������ڳճ�ЦЦ", 140, 0)
			say("��������Ž��ļ�������������׸��У����Ѻú�ȥ���ɣ��Ϸ���Ը���ˣ��Ӵ�����ǣ�ң��ʹ�ȥҲ��������������", 140, 0)
			say("����л̫ʦ�崫���������˼Ҷౣ�أ��ţ������������Ž��İ���ɣ�������", 35, 1)
			instruct_14()
			instruct_3(7, 101, 0, 0, 0, 0, 0, -1, -1, -1, 0, 33, 12)
			instruct_13()
			DrawStrBox(-1, -1, "���պ�", C_ORANGE, CC.DefaultFont)
			ShowScreen()
			lib.Delay(500)
			say("�����ˣ�����������Ķ��¾Ž���������������ѧ������ǰ��֮�񼼣��򸴺κ���", 35, 1)
			DrawStrBox(-1, -1, "���������Ž�֮�ش�", C_ORANGE, CC.DefaultFont)
			ShowScreen()
			lib.Delay(500)
			Cls()
			awakening(35, 1)	--�����ڶ��ξ���
			DrawStrBox(-1, -1, "�����ƺű��", C_ORANGE, CC.DefaultFont)
			ShowScreen()
			lib.Delay(500)
			Cls()
			SetS(10, 1, 1, 0, 1)
			instruct_3(7, 102, 0, 0, 0, 0, 0, -1, -1, -1, 0, 34, 12)
		end
	end
end

--ɽ���¼�
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

--�������SYP�Զ�����
function NEvent10(keypress)
  if JY.SubScene == 25 and GetS(10, 0, 9, 0) ~= 1 then
    SetS(25, 9, 44, 3, 103)
    instruct_3(25, 103, 1, 0, 0, 0, 0, 4133*2, 4133*2, 4133*2, 0, -2, -2)
    if JY.Base["��X1"] == 10 and JY.Base["��Y1"] == 44 and JY.Base["�˷���"] == 2 and (keypress == VK_SPACE or keypress == VK_RETURN) and GetD(25, 82, 5) == 4662 then
      say("��һ·����������������ˣ������������ɡ�",596,0);
      instruct_14()
      for i = 79, 92 do
          instruct_3(25, i, 1, 0, 0, 0, 0, 4664, 4664, 4664, 0, -2, -2)
      end
      for ii = CC.BookStart, CC.BookStart + CC.BookNum -1 do
          instruct_32(ii, -10)
      end
	  JY.Base["��������"] = 15
      instruct_3(25, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2, -2)
      instruct_3(25, 76, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2, -2)
      instruct_13()
      say("�����Ѿ��ź��ˣ���������ų�ȥ�ɡ�", 596,0);
      SetS(10, 0, 9, 0, 1)
      instruct_3(25, 103, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2, -2)
      
    end
  end
end

--�󹦷� ��Ԭ��־�Ի��󣬽��߽��黹
function NEvent12(keypress)
	if JY.SubScene == 95 and GetD(95, 4, 5) ~= 0 and JY.Thing[40]["ʹ����"] ~= -1 then
		JY.Person[JY.Thing[40]["ʹ����"]]["����"] = -1
		JY.Thing[40]["ʹ����"] = -1
	end
end

--ɽ��Ů���ǵľ���
function mm4R()
	local r = JYMsgBox("��ѡ��", "���������أ�", {"����","����","����"}, 3, JY.Person[92]["������"])
	if r == 1 then
		JY.Person[92]["��������"] = 0
		Cls()  --����
	elseif r == 2 then
		JY.Person[92]["��������"] = 1
		Cls()  --����
	elseif r == 3 then
		JY.Person[92]["��������"] = 2
		Cls()  --����
	end
	if JY.Person[0]["����"] == 50 then
		JY.Person[92]["����"] = 50
	else
		JY.Person[92]["����"] = 101 - JY.Person[0]["����"]
	end
end

--�Զ����¼�
function NEvent(keypress)
	NEvent2(keypress)		--ʮ�ı�����֮��õ�5000����ϴ����
	NEvent3(keypress)		--��� ���˷����ҽ���
	NEvent4(keypress)		--��������
	NEvent6(keypress)		--֩�붴 ������
	NEvent10(keypress)	--���������
	NEvent12(keypress)	--�黹���߽�
end