function Set_Eff_Text(id, txwz, str)
	if WAR.Person[id][txwz] ~= nil then
		WAR.Person[id][txwz] = WAR.Person[id][txwz].."+"..str
	else
		WAR.Person[id][txwz] = str
	end
end

--������Ч���� 
function TXWZXS(str,cl,n)
    if n == nil then 
	   n = 0
	end
	local i = n 
	if i > 20 then 
		i = 20 
	end	
    Cat('ʵʱ��Ч����')
	Cls()
	DrawStrBox(-1, 24, str, cl, 10 + i)
	ShowScreen()
	lib.Delay(CC.BattleDelay)
    if n == 40 then
	   return
	else
	   return TXWZXS(str,cl,n+5)
	end
end

--��������֮���ʵ�ʾ���
function War_realjl(ida, idb)
	if ida == nil then
		ida = WAR.CurID
	end
	CleanWarMap(3, 255)
	local x = WAR.Person[ida]["����X"]
	local y = WAR.Person[ida]["����Y"]
	local steparray = {}
	steparray[0] = {}
	steparray[0].bushu = {}
	steparray[0].x = {}
	steparray[0].y = {}
	SetWarMap(x, y, 3, 0)
	steparray[0].num = 1
	steparray[0].bushu[1] = 0		--�����ƶ��Ĳ���
	steparray[0].x[1] = x
	steparray[0].y[1] = y
	return War_FindNextStep1(steparray, 0, ida, idb)
end

--AIѡ��Ŀ��ĺ���
function unnamed(kfid)
	local pid = WAR.Person[WAR.CurID]["������"]
	local kungfuid = JY.Person[pid]["�书" .. kfid]
	local kungfulv = JY.Person[pid]["�书�ȼ�" .. kfid]
	if kungfulv == 999 then
		kungfulv = 11
	else
		kungfulv = math.modf(kungfulv / 100) + 1
	end
	local m1, m2, a1, a2, a3, a4, a5 = refw(kungfuid, kungfulv)
	local mfw = {m1, m2}
	local atkfw = {a1, a2, a3, a4, a5}
	if kungfulv == 11 then
		kungfulv = 10
	end
	--AIҲ���µ������ж�
	local kungfuatk = get_skill_power(pid, kungfuid, kungfulv)
	local atkarray = {}
	local num = 0
	CleanWarMap(4, -1)
	local movearray = War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["�ƶ�����"], 0)
	--Cat('ʵʱ��Ч����')
	--WarDrawMap(1)
	--ShowScreen()
	--lib.Delay(CC.BattleDelay)
	for i = 0, WAR.Person[WAR.CurID]["�ƶ�����"] do
		local step_num = movearray[i].num
		if step_num ~= nil then
			for j = 1, step_num do
				local xx = movearray[i].x[j]
				local yy = movearray[i].y[j]
				num = num + 1
				atkarray[num] = {}
				atkarray[num].x, atkarray[num].y = xx, yy
				atkarray[num].p, atkarray[num].ax, atkarray[num].ay = GetAtkNum(xx, yy, mfw, atkfw, kungfuatk)
			end
		end
	end
	for i = 1, num - 1 do
		for j = i + 1, num do
			if atkarray[i].p < atkarray[j].p then
				atkarray[i], atkarray[j] = atkarray[j], atkarray[i]
			end
		end
	end
	if atkarray[1].p > 0 then
		for i = 2, num do
			if atkarray[i].p == 0 or atkarray[i].p < atkarray[1].p / 2 then
				num = i - 1
				break;
			end
		end
		for i = 1, num do
			if WAR.Person[WAR.CurID]["�ҷ�"] == true then
				--flag: approach enemies.
				atkarray[i].p = atkarray[i].p + GetMovePoint(atkarray[i].x, atkarray[i].y)
			else
				--flag: aviod enemies. avoiding as many enemies as possible while retaining targeting the spot with higher threat
				atkarray[i].p = atkarray[i].p + GetMovePoint(atkarray[i].x, atkarray[i].y, 1)
			end
		end
		for i = 1, num - 1 do
			for j = i + 1, num do
				if atkarray[i].p < atkarray[j].p then
					atkarray[i], atkarray[j] = atkarray[j], atkarray[i]
				elseif atkarray[i].p == atkarray[j].p and math.random(2) > 1 then
					atkarray[i], atkarray[j] = atkarray[j], atkarray[i]
				end
			end
		end
		for i = 2, num do
			if atkarray[i].p < atkarray[1].p *4/5 then
				num = i - 1
				break;
			end
		end
		
		local select = 1
		
		War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["�ƶ�����"], 0)
		War_MovePerson(atkarray[select].x, atkarray[select].y)
		War_Fight_Sub(WAR.CurID, kfid, atkarray[select].ax, atkarray[select].ay)
		if fjpd(WAR.CurID) then 
			return
		end	
		--�����ṥ����㿪
		if pid == 606 then
			WAR.Person[WAR.CurID]["�ƶ�����"] = 10
			War_AutoEscape()
			War_RestMenu()
		end
	else
		if fjpd(WAR.CurID) then 
			return
		end	
			--�򲻵��ˣ����ǳ�ҩ
			local jl, nx, ny = War_realjl()
			AutoMove()
			--Ĭ��Ϊ��Ϣ
			local what_to_do = 0
			local can_eat_drug = 0
			--���ҷ����ῼ�ǳ�ҩ
			if WAR.Person[WAR.CurID]["�ҷ�"] == false then
				can_eat_drug = 1
			--������ҷ���ֻ���ڶ�������Ż��ҩ
			else
				if isteam(pid) and JY.Person[pid]["�Ƿ��ҩ"] == 1 then
					can_eat_drug = 1
				end
			end
			--����������ս����ҩ
			--���߹��Ӻ��߹�����ҩ
			if WAR.Person[WAR.CurID]["�ҷ�"] == false and (WAR.ZDDH == 188 or WAR.ZDDH == 257) then
				can_eat_drug = 0
			end
			--���ҵڶ��£����ܳ�ҩ
			if WAR.ZYHB == 2 then
				can_eat_drug = 0
			end
			--1:������ҩ 2����Ѫ 3��ҽ�� 4�������� 5���Խⶾ
			if can_eat_drug == 1 then
				local r = -1
				--��������10��������ҩ
				if JY.Person[pid]["����"] < 10 then
					r = War_ThinkDrug(4)
					if r >= 0 then
						what_to_do = 1
					end
				end
				local rate = -1
				if JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 5 then
					rate = 90
				elseif JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 4 then
					rate = 70
				elseif JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 3 then
					rate = 50
				elseif JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 2 then
					rate = 25
				end
				--����Ҳ���ӳ�Ѫҩ����
				if JY.Person[pid]["���˳̶�"] > 50 then
					rate = rate + 50
				end
				if Rnd(100) < rate then
					r = War_ThinkDrug(2)
					if r >= 0 then				--�����ҩ��ҩ 
						what_to_do = 2
						
					else
						r = War_ThinkDoctor()		--���û��ҩ������ҽ��
						if r >= 0 then
							what_to_do = 3
						end
					end
				end
				--��������
				rate = -1
				if JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 6 then
					rate = 100
				elseif JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 5 then
					rate = 75
				elseif JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 4 then
					rate = 50
				end
				if Rnd(100) < rate then
					r = War_ThinkDrug(3)
					if r >= 0 then
						what_to_do = 4
					end
				end
				rate = -1
				if CC.PersonAttribMax["�ж��̶�"] * 3 / 4 < JY.Person[pid]["�ж��̶�"] then
					rate = 60
				else
					if CC.PersonAttribMax["�ж��̶�"] / 2 < JY.Person[pid]["�ж��̶�"] then
						rate = 30
					end
				end
				--��Ѫ���£��ųԽⶾҩ
				if JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 2 and Rnd(100) < rate then
					r = War_ThinkDrug(6)
					if r >= 0 then
						what_to_do = 5
					end
				end
			end
			--��ҩflag 2������ 3������ 4������ 6���ⶾ
			if what_to_do == 0 then
				War_RestMenu()
			elseif what_to_do == 1 then
				War_AutoEatDrug(4)
				
			elseif what_to_do == 2 then
				War_AutoEatDrug(2)
				
			elseif what_to_do == 3 then
				War_AutoDoctor()
				
			elseif what_to_do == 4 then
				War_AutoEatDrug(3)
				
			elseif what_to_do == 5 then
				War_AutoEatDrug(6)
				
			end
		end
end

function AutoMove()
	local x, y = nil, nil
	local minDest = math.huge
	local enemyid=War_AutoSelectEnemy()   --ѡ���������

	War_CalMoveStep(WAR.CurID,100,0);   --�����ƶ����� �������100��

	for i=0,CC.WarWidth-1 do
		for j=0,CC.WarHeight-1 do
			local dest=GetWarMap(i,j,3);
			if dest <128 then
				local dx=math.abs(i-WAR.Person[enemyid]["����X"])
				local dy=math.abs(j-WAR.Person[enemyid]["����Y"])
				if minDest>(dx+dy) then        --��ʱx,y�Ǿ�����˵����·������Ȼ���ܱ�Χס
					minDest=dx+dy;
					x=i;
					y=j;
				elseif minDest==(dx+dy) then
					if Rnd(2)==0 then
						x=i;
						y=j;
					end
				end
			end
		end
	end

	if minDest<math.huge then   --��·����
	    while true do    --��Ŀ��λ�÷����ҵ������ƶ���λ�ã���Ϊ�ƶ��Ĵ���
			local i=GetWarMap(x,y,3);
			if i<=WAR.Person[WAR.CurID]["�ƶ�����"] then
				break;
			end

			if GetWarMap(x-1,y,3)==i-1 then
				x=x-1;
			elseif GetWarMap(x+1,y,3)==i-1 then
				x=x+1;
			elseif GetWarMap(x,y-1,3)==i-1 then
				y=y-1;
			elseif GetWarMap(x,y+1,3)==i-1 then
				y=y+1;
			end
	    end
		War_MovePerson(x,y);    --�ƶ�����Ӧ��λ��
	end
end

function GetMovePoint(x, y, flag)
	local point = 0
	local wofang = WAR.Person[WAR.CurID]["�ҷ�"]
	local movearray = MY_CalMoveStep(x, y, 16, 1)
	for i = 1, 16 do
		local step_num = movearray[i].num
		if step_num ~= nil then
			if step_num == 0 then
				break;
			end
			for j = 1, step_num do
				local xx = movearray[i].x[j]
				local yy = movearray[i].y[j]
				local v = GetWarMap(xx, yy, 2)
				if v ~= -1 then
					if v == WAR.CurID then
						break;
					else   
						if WAR.Person[v]["�ҷ�"] == wofang then
							point = point + i * 2 - 26
						elseif WAR.Person[v]["�ҷ�"] ~= wofang then
							if flag ~= nil then
								point = point + i - 17
							else
								point = point + 26 - i
							end
						end
					end
				end
			end
		end
	end
	return point
end

function MY_CalMoveStep(x, y, stepmax, flag)
	CleanWarMap(3, 255)
	local steparray = {}
	for i = 0, stepmax do
		steparray[i] = {}
		steparray[i].bushu = {}
		steparray[i].x = {}
		steparray[i].y = {}
	end
	SetWarMap(x, y, 3, 0)
	steparray[0].num = 1
	steparray[0].bushu[1] = stepmax
	steparray[0].x[1] = x
	steparray[0].y[1] = y
	War_FindNextStep(steparray, 0, flag)
	return steparray
end

function GetAtkNum(x, y, movfw, atkfw, atk)
  local point = {}
  local num = 0
  local kind, len = movfw[1], movfw[2]
  
  if kind == 0 then
    local array = MY_CalMoveStep(x, y, len, 1)
    for i = 0, len do
      local step_num = array[i].num
      if step_num ~= nil then
        if step_num == 0 then
          break;
        end
	      for j = 1, step_num do
	        num = num + 1
	        point[num] = {array[i].x[j], array[i].y[j]}
	      end
	    end
    end
  elseif kind == 1 then
    local array = MY_CalMoveStep(x, y, len * 2, 1)
    for r = 1, len * 2 do
      for i = 0, r do
        local j = r - i
        if len < i or len < j then
          SetWarMap(x + i, y + j, 3, 255)
          SetWarMap(x + i, y - j, 3, 255)
          SetWarMap(x - i, y + j, 3, 255)
          SetWarMap(x - i, y - j, 3, 255)
        end
      end
    end
    for i = 0, len do
      local step_num = array[i].num
      if step_num ~= nil then
        if step_num == 0 then
          break;
        end
	      for j = 1, step_num do
	        if GetWarMap(array[i].x[j], array[i].y[j], 3) < 128 then
	          num = num + 1
	          point[num] = {array[i].x[j], array[i].y[j]}
	        end
	      end
	    end
    end
  elseif kind == 2 then
    if not len then
      len = 1
    end
    for i = 1, len do
      if x + i < CC.WarWidth - 1 and GetWarMap(x + i, y, 1) > 0 and CC.WarWater[GetWarMap(x + i, y, 0)] == nil then
        break;
      end
      num = num + 1
      point[num] = {x + i, y}
    end
    for i = 1, len do
      if x - i > 0 and GetWarMap(x - i, y, 1) > 0 and CC.WarWater[GetWarMap(x - i, y, 0)] == nil then
        break;
      end
      num = num + 1
      point[num] = {x - i, y}
    end
    for i = 1, len do
      if y + i < CC.WarHeight - 1 and GetWarMap(x, y + i, 1) > 0 and CC.WarWater[GetWarMap(x, y + i, 0)] == nil then
        break;
      end
      num = num + 1
      point[num] = {x, y + i}
    end
    for i = 1, len do
      if y - i > 0 and GetWarMap(x, y - i, 1) > 0 and CC.WarWater[GetWarMap(x, y - i, 0)] == nil then
        break;
      end
      num = num + 1
      point[num] = {x, y - i}
    end
  elseif kind == 3 then
    if x + 1 < CC.WarWidth - 1 and GetWarMap(x + 1, y, 1) == 0 and CC.WarWater[GetWarMap(x + 1, y, 0)] == nil then
      num = num + 1
      point[num] = {x + 1, y}
    end
    if x - 1 > 0 and GetWarMap(x - 1, y, 1) == 0 and CC.WarWater[GetWarMap(x - 1, y, 0)] == nil then
      num = num + 1
      point[num] = {x - 1, y}
    end
    if y + 1 < CC.WarHeight - 1 and GetWarMap(x, y + 1, 1) == 0 and CC.WarWater[GetWarMap(x, y + 1, 0)] == nil then
      num = num + 1
      point[num] = {x, y + 1}
    end
    if y - 1 > 0 and GetWarMap(x, y - 1, 1) == 0 and CC.WarWater[GetWarMap(x, y - 1, 0)] == nil then
      num = num + 1
      point[num] = {x, y - 1}
    end
    if x + 1 < CC.WarWidth - 1 and y + 1 < CC.WarHeight - 1 and GetWarMap(x + 1, y + 1, 1) == 0 and CC.WarWater[GetWarMap(x + 1, y + 1, 0)] == nil then
      num = num + 1
      point[num] = {x + 1, y + 1}
    end
    if x - 1 > 0 and y + 1 < CC.WarHeight - 1 and GetWarMap(x - 1, y + 1, 1) == 0 and CC.WarWater[GetWarMap(x - 1, y + 1, 0)] == nil then
      num = num + 1
      point[num] = {x - 1, y + 1}
    end
    if x + 1 < CC.WarWidth - 1 and y - 1 > 0 and GetWarMap(x + 1, y - 1, 1) == 0 and CC.WarWater[GetWarMap(x + 1, y - 1, 0)] == nil then
      num = num + 1
      point[num] = {x + 1, y - 1}
    end
    if x - 1 > 0 and y - 1 > 0 and GetWarMap(x - 1, y - 1, 1) == 0 and CC.WarWater[GetWarMap(x - 1, y - 1, 0)] == nil then
    	num = num + 1
    	point[num] = {x - 1, y - 1}
  	end
  end
  local maxx, maxy, maxnum, atknum = 0, 0, 0, 0
  

  for i = 1, num do
    atknum = GetWarMap(point[i][1], point[i][2], 4)
    
    if atknum == -1 or atkfw[1] > 9 then
      atknum = WarDrawAtt(point[i][1], point[i][2], atkfw, 2, x, y, atk)
      SetWarMap(point[i][1], point[i][2], 4, atknum)
    end
    if atknum~= nil and maxnum < atknum then
      maxnum, maxx, maxy = atknum, point[i][1], point[i][2]
    end
  end
  
  return maxnum, maxx, maxy
end

function War_FindNextStep1(steparray,step,id,idb)      --������һ�����ƶ�������
	--������ĺ�������   
	local num=0;
	local step1=step+1;
	
	steparray[step1]={};
	steparray[step1].bushu={};
	steparray[step1].x={};
	steparray[step1].y={};
	
	local function fujinnum(tx,ty)
		local tnum=0
		local wofang=WAR.Person[id]["�ҷ�"]
		local tv;
		tv=GetWarMap(tx+1,ty,2);
		if idb==nil then
			if tv~=-1 then
				if WAR.Person[tv]["�ҷ�"]~=wofang then
					return -1
				end
			end
		elseif tv==idb then
			return -1
		end
		if tv~=-1 then
			if WAR.Person[tv]["�ҷ�"]~=wofang then
				tnum=tnum+1
			end
		end
		tv=GetWarMap(tx-1,ty,2);
		if idb==nil then
			if tv~=-1 then
				if WAR.Person[tv]["�ҷ�"]~=wofang then
					return -1
				end
			end
		elseif tv==idb then
			return -1
		end
		if tv~=-1 then
			if WAR.Person[tv]["�ҷ�"]~=wofang then
				tnum=tnum+1
			end
		end
		tv=GetWarMap(tx,ty+1,2);
		if idb==nil then
			if tv~=-1 then
				if WAR.Person[tv]["�ҷ�"]~=wofang then
					return -1
				end
			end
		elseif tv==idb then
			return -1
		end
		if tv~=-1 then
			if WAR.Person[tv]["�ҷ�"]~=wofang then
				tnum=tnum+1
			end
		end
		tv=GetWarMap(tx,ty-1,2);
		if idb==nil then
			if tv~=-1 then
				if WAR.Person[tv]["�ҷ�"]~=wofang then
					return -1
				end
			end
		elseif tv==idb then
			return -1
		end
		if tv~=-1 then
			if WAR.Person[tv]["�ҷ�"]~=wofang then
				tnum=tnum+1
			end
		end
		return tnum
	end
	
	for i=1,steparray[step].num do
		--if steparray[step].bushu[i]<128 then
		steparray[step].bushu[i]=steparray[step].bushu[i]+1;
	    local x=steparray[step].x[i];
	    local y=steparray[step].y[i];
	    if x+1<CC.WarWidth-1 then                        --��ǰ���������ڸ�
		    local v=GetWarMap(x+1,y,3);
			if v ==255 and War_CanMoveXY(x+1,y,0)==true then
                num= num+1;
                steparray[step1].x[num]=x+1;
                steparray[step1].y[num]=y;
				SetWarMap(x+1,y,3,step1);
				local mnum=fujinnum(x+1,y);
				if mnum==-1 then 
					return steparray[step].bushu[i],x+1,y
				else
					steparray[step1].bushu[num]=steparray[step].bushu[i]+mnum;
				end
			end
		end

	    if x-1>0 then                        --��ǰ���������ڸ�
		    local v=GetWarMap(x-1,y,3);
			if v ==255 and War_CanMoveXY(x-1,y,0)==true then
                 num=num+1;
                steparray[step1].x[num]=x-1;
                steparray[step1].y[num]=y;
				SetWarMap(x-1,y,3,step1);
				local mnum=fujinnum(x-1,y);
				if mnum==-1 then 
					return steparray[step].bushu[i],x-1,y
				else
					steparray[step1].bushu[num]=steparray[step].bushu[i]+mnum;
				end
			end
		end

	    if y+1<CC.WarHeight-1 then                        --��ǰ���������ڸ�
		    local v=GetWarMap(x,y+1,3);
			if v ==255 and War_CanMoveXY(x,y+1,0)==true then
                 num= num+1;
                steparray[step1].x[num]=x;
                steparray[step1].y[num]=y+1;
				SetWarMap(x,y+1,3,step1);
				local mnum=fujinnum(x,y+1);
				if mnum==-1 then 
					return steparray[step].bushu[i],x,y+1
				else
					steparray[step1].bushu[num]=steparray[step].bushu[i]+mnum;
				end
			end
		end

	    if y-1>0 then                        --��ǰ���������ڸ�
		    local v=GetWarMap(x ,y-1,3);
			if v ==255 and War_CanMoveXY(x,y-1,0)==true then
                num= num+1;
                steparray[step1].x[num]=x ;
                steparray[step1].y[num]=y-1;
				SetWarMap(x ,y-1,3,step1);
				local mnum=fujinnum(x,y-1);
				if mnum==-1 then 
					return steparray[step].bushu[i],x,y-1
				else
					steparray[step1].bushu[num]=steparray[step].bushu[i]+mnum;
				end
			end
		end
		--end
	end
	if num==0 then return -1 end;
    steparray[step1].num=num;
	for i=1,num-1 do
		for j=i+1,num do
			if steparray[step1].bushu[i]>steparray[step1].bushu[j] then
				steparray[step1].bushu[i],steparray[step1].bushu[j]=steparray[step1].bushu[j],steparray[step1].bushu[i]
				steparray[step1].x[i],steparray[step1].x[j]=steparray[step1].x[j],steparray[step1].x[i]
				steparray[step1].y[i],steparray[step1].y[j]=steparray[step1].y[j],steparray[step1].y[i]
			end
		end
	end

	return War_FindNextStep1(steparray,step1,id,idb)
end
--������Ʒ
function War_PersonTrainDrug(pid)
	local p = JY.Person[pid]
	local thingid = p["������Ʒ"]
	if thingid < 0 then
		return 
	end
	if JY.Thing[thingid]["������Ʒ�辭��"] <= 0 then
		return 
	end
	local needpoint = (7 - math.modf(p["����"] / 15)) * JY.Thing[thingid]["������Ʒ�辭��"]
	if p["��Ʒ��������"] < needpoint then
		return 
	end
	  
	local haveMaterial = 0
	local MaterialNum = -1
	for i = 1, CC.MyThingNum do
		if JY.Base["��Ʒ" .. i] == JY.Thing[thingid]["�����"] then
			haveMaterial = 1
			MaterialNum = JY.Base["��Ʒ����" .. i]
		end
	end
  
	--�����㹻
	if haveMaterial == 1 then
		local enough = {}
		local canMake = 0
		for i = 1, 5 do
			if JY.Thing[thingid]["������Ʒ" .. i] >= 0 and JY.Thing[thingid]["��Ҫ��Ʒ����" .. i] <= MaterialNum then
				canMake = 1
				enough[i] = 1
			else
				enough[i] = 0
			end
		end
		--��������
		if canMake == 1 then
			local makeID = nil
			while true do
				makeID = Rnd(5) + 1
				if thingid == 221 and pid == 88 and enough[4] == 1 then
					makeID = 4
				end
				if thingid == 220 and pid == 89 and enough[4] == 1 then
					makeID = 4
				end
				if enough[makeID] == 1 then
					break;
				end
			end
			
			local newThingID = JY.Thing[thingid]["������Ʒ" .. makeID]
			DrawStrBoxWaitKey(string.format("%s ����� %s", p["����"], JY.Thing[newThingID]["����"]), C_WHITE, CC.DefaultFont)
			if instruct_18(newThingID) == true then
				instruct_32(newThingID, 1)
			else
				instruct_32(newThingID, 1)
			end
			instruct_32(JY.Thing[thingid]["�����"], -JY.Thing[thingid]["��Ҫ��Ʒ����" .. makeID])
			p["��Ʒ��������"] = 0
		end
	end
end
--��������ж�����
--pid ʹ���ˣ�
--enemyid  �ж���
function War_PoisonHurt(pid, enemyid)
	local vv = math.modf((JY.Person[pid]["�ö�����"] - JY.Person[enemyid]["��������"]) / 4)
	--����ţ�ڳ����ѹ��ö�+50
	if JY.Status == GAME_WMAP then
		for i,v in pairs(CC.AddPoi) do
			if match_ID(pid, v[1]) then
				for wid = 0, WAR.PersonNum - 1 do
					if match_ID(WAR.Person[wid]["������"], v[2]) and WAR.Person[wid]["����"] == false then
						vv = vv + v[3] / 4
					end
				end
			end
		end
	end
	vv = vv - JY.Person[enemyid]["����"] / 200
	for i = 1, JY.Base["�书����"] do
		if JY.Person[enemyid]["�书" .. i] == 108 then
			vv = 0
		end
	end
	vv = math.modf(vv)
	if vv < 0 then
		vv = 0
	end
	return AddPersonAttrib(enemyid, "�ж��̶�", vv)
end

--���ﰴ�Ṧ��������
function WarPersonSort(flag)
	for i = 0, WAR.PersonNum - 1 do
		local id = WAR.Person[i]["������"]
		local add = 0
		local p = JY.Person[id]
	
		
		--���㹦
		if Curr_QG(id,223) then
		   add =add + math.modf(JY.Person[id]["�Ṧ"]*0.2)
		 end

		--��ң��
		if Curr_QG(id,2) then
		  add = add + 20
		end	 
		
		WAR.Person[i]["�Ṧ"] = Qg(i) + (add)
	--�з���ս���Ṧ����������͵ȼ��ӳ�
		--if WAR.Person[i]["�ҷ�"] then
		  
		--else
			--WAR.Person[i]["�Ṧ"] = WAR.Person[i]["�Ṧ"] + math.modf(JY.Person[id]["�������ֵ"] / 50) + JY.Person[id]["�ȼ�"]
		--end
		--���¼ӳ�
		for ii,v in pairs(CC.AddSpd) do
			if match_ID(id, v[1]) then
				for wid = 0, WAR.PersonNum - 1 do
					if match_ID(WAR.Person[wid]["������"], v[2]) and WAR.Person[wid]["����"] == false then
						WAR.Person[i]["�Ṧ"] = WAR.Person[i]["�Ṧ"] + v[3]
					end
					
                end
			end
		end
	end
	if flag ~= nil then
		return 
	end
	for i = 0, WAR.PersonNum - 2 do
		local maxid = i
		for j = i, WAR.PersonNum - 1 do
			if WAR.Person[maxid]["�Ṧ"] < WAR.Person[j]["�Ṧ"] then
				maxid = j;
			end
		end
		WAR.Person[maxid], WAR.Person[i] = WAR.Person[i], WAR.Person[maxid]
	end
end

--��ʾ�ǹ���ʱ�ĵ���
function War_Show_Count(id, str)
	if JY.Restart == 1 then
		return
	end
	
	local pid = WAR.Person[id]["������"];
	local x = WAR.Person[id]["����X"];
	local y = WAR.Person[id]["����Y"];
	
	local hp = WAR.Person[id]["��������"];
	local mp = WAR.Person[id]["��������"];
	local tl = WAR.Person[id]["��������"];
	local ed = WAR.Person[id]["�ж�����"];
	local dd = WAR.Person[id]["�ⶾ����"];
	local ns = WAR.Person[id]["���˵���"];
  
	local show = {x, y, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil};		--x, y, ����, ����, ����, ��Ѩ, ��Ѫ, �ж�, �ⶾ, ���ˣ����⣬����
	
	if hp ~= nil and hp ~= 0 then		--��ʾ����
		if hp > 0 then
			show[3] = "����+"..hp;
		else
			show[3] = "����"..hp;
		end
	end
	
	if mp ~= nil and mp ~= 0 then		--��ʾ����
		if mp > 0 then
			show[5] = "����+"..mp;
		else
			show[5] = "����"..mp;
		end
	end
	
	if tl ~= nil and tl ~= 0 then		--��ʾ����
		if tl > 0 then
			show[6] = "����+"..tl;
		else
			show[6] = "����"..tl;
		end
	end
	
    if WAR.FXXS[WAR.Person[id]["������"]] ~= nil and WAR.FXXS[WAR.Person[id]["������"]] == 1 then			--��ʾ�Ƿ��Ѩ
       	show[7] = "��Ѩ "..WAR.FXDS[WAR.Person[id]["������"]];
       	WAR.FXXS[WAR.Person[id]["������"]] = 0
    end
      
    if WAR.LXXS[WAR.Person[id]["������"]] ~=nil and WAR.LXXS[WAR.Person[id]["������"]] == 1 then		--��ʾ�Ƿ���Ѫ
      	show[8] = "��Ѫ "..WAR.LXZT[WAR.Person[id]["������"]];
        WAR.LXXS[WAR.Person[id]["������"]] = 0
    end
	
	if ed ~= nil and ed ~= 0 then		--��ʾ�ж�
		show[9] = "�ж�+"..ed;
	end
	
	if dd ~= nil and dd ~= 0 then		--��ʾ�ⶾ
		show[4] = "�ж�-"..dd;
	end
	
	if ns ~= nil and ns ~= 0 then		--��ʾ����
		if ns > 0 then
			show[10] = "���ˡ�"..ns;
		else
			show[10] = "���ˡ�"..-ns;
		end
	end
	
	if WAR.BFXS[WAR.Person[id]["������"]] == 1 then		--��ʾ�Ƿ񱻱���
		show[11] = "���� "..JY.Person[WAR.Person[id]["������"]]["����̶�"];
		WAR.BFXS[WAR.Person[id]["������"]] = 0
	end
		
	if WAR.ZSXS[WAR.Person[id]["������"]] == 1 then		--��ʾ�Ƿ�����
		show[12] = "���� "..JY.Person[WAR.Person[id]["������"]]["���ճ̶�"];
		WAR.ZSXS[WAR.Person[id]["������"]] = 0
	end
	
	--��¼�ĸ�λ�����е���
	local showValue = {};
	local showNum = 0;
	for i=3, 12 do
		if show[i] ~= nil then
			showNum = showNum + 1;
			showValue[showNum] = i;
		end
	end

	if showNum == 0 then
		return;
	end
	
	local hb = GetS(JY.SubScene, x, y, 4);
  
	local ll = string.len(show[showValue[1]]);	--����
	
	local w = ll * CC.DefaultFont / 2 + 1
	local clip = {x1 = CC.ScreenW / 2 - w/2 - CC.XScale/2, y1 = CC.YScale + CC.ScreenH / 2 - hb, x2 = CC.XScale + CC.ScreenW / 2 + w, y2 = CC.YScale + CC.ScreenH / 2 + CC.DefaultFont + 1}
	local area = (clip.x2 - clip.x1) * (clip.y2 - clip.y1) + CC.DefaultFont*4		--�滭�ķ�Χ
	--local surid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)		--�滭���

	for i = 5, 18 do
		if JY.Restart == 1 then
			break
		end
		local tstart = lib.GetTime()
		local y_off = i * 2
		
		--lib.SetClip(0, 0, CC.ScreenW, CC.ScreenH)
		--lib.LoadSur(surid, 0, 0)
		--��ʾ����
		Cat('ʵʱ��Ч����')
		Cls()
		if str ~= nil then
			DrawString(clip.x1 - #str*CC.Fontsmall/5 + 30, clip.y1 - y_off - CC.DefaultFont*4, str, C_WHITE, CC.Fontsmall);
		end
		for j=1, showNum do
			local c = showValue[j] - 1;
			if showValue[j] == 3 and (string.sub(show[3],1,1) == "-" or string.sub(show[3],2,2) == "-") then		--������������ʾΪ��ɫ
				c = 1;
			end
			DrawString(clip.x1, clip.y1 - y_off - (showNum-j+1)*CC.DefaultFont, show[showValue[j]], WAR.L_EffectColor[c], CC.DefaultFont); 	
		end 
		ShowScreen()
		lib.Delay(CC.BattleDelay)
	end
  
	--lib.SetClip(0, 0, 0, 0)		--���
	WAR.Person[id]["��������"] = nil;
	WAR.Person[id]["��������"] = nil;
	WAR.Person[id]["��������"] = nil;
	WAR.Person[id]["�ж�����"] = nil;
	WAR.Person[id]["�ⶾ����"] = nil;
	WAR.Person[id]["���˵���"] = nil;
	Cls()
	--lib.FreeSur(surid)
end

--����ҽ����
--id1 ҽ��id2, ����id2�������ӵ���
function ExecDoctor(id1, id2)
	if JY.Person[id1]["����"] < 50 then
		return 0
	end
	local add = JY.Person[id1]["ҽ������"]
	local value = JY.Person[id2]["���˳̶�"]
	if add + 20 < value then
		return 0
	end
  
	-- ƽһָ��ҽ������ɱ�����й�
	if match_ID(id1, 28) and JY.Status == GAME_WMAP then
		add = math.modf(JY.Person[id1]["ҽ������"] * (1 + WAR.PYZ / 10))
	end
  
	--ս��״̬��ҽ��
	--����ڳ�������ҽ��+120
	--���ѹ��ڳ�����ţҽ��+50
	if JY.Status == GAME_WMAP then
		for i,v in pairs(CC.AddDoc) do
			if match_ID(id1, v[1]) then
				for wid = 0, WAR.PersonNum - 1 do
					if match_ID(WAR.Person[wid]["������"], v[2]) and WAR.Person[wid]["����"] == false then
						add = add + v[3]
					end
				end
			end
		end
	end
  
	add = add - (add) * value / 200
	add = math.modf(add) + Rnd(5)
  
	local n = AddPersonAttrib(id2, "���˳̶�", -math.modf((add) / 10))
	--�����壺ҽ��ʱ��ʾ���˼���
	if JY.Status == GAME_WMAP then
		local p = -1;
		for wid = 0, WAR.PersonNum - 1 do
			if WAR.Person[wid]["������"] == id2 and WAR.Person[wid]["����"] == false then
				p = wid;
				break;
			end
		end
		WAR.Person[p]["���˵���"] = n;
	end
	return AddPersonAttrib(id2, "����", add)
end

--�޾Ʋ����������书�˺���WAR.CurIDΪ������
function War_WugongHurtLife(enemyid, wugong, level, ang, x, y)
    
	local pid = WAR.Person[WAR.CurID]["������"]
	local eid = WAR.Person[enemyid]["������"]
	--����
	local dng = 0
	local WGLX = JY.Wugong[wugong]["�书����"]
	
	--������
	local LYZ = 0
	--�����ڳ�

	local hurt = nil
	--�޾Ʋ��������������˺��������㱣���˺�
	local hurt2 = 0
	local hurt3 = 0
	local zshurt = 0
	
	local w = {g = 0,f = 0, q = 0, n = 0, wc = 0, xs = 0 ,wl = 0}

	local d = {g = 0,f = 0, q = 0, n = 0, wc = 0, xs = 0,wl = 0}

	local wnc = 0

	local wwc = 0

	local wsc = 0

	local dnc = 0

	local dwc = 0

	local dsc = 0
	
	local wxs = 0 
	
	local dxs = 0
	--�޾Ʋ�������¼����Ѫ��
	WAR.Person[enemyid]["Life_Before_Hit"] = JY.Person[eid]["����"]
	WAR.Person[enemyid]["Neili_Before_Hit"] = JY.Person[eid]["����"]
	
	--�Ƿ�Ϊ����
	local function DWPD()

		--��תǬ��״̬��Ĭ��Ϊ����
		if WAR.Person[enemyid]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] or WAR.NZQK > 0 or WAR.HLZT[pid] ~= nil then
			return true
		else
			return false
		end
	end
  
	--���ʳ�ǩ������Xֵ����1ʱ���������Xֵ��50%~100%
	local function myrnd(x)
		if x <= 1 then
			return 0
		end
		return math.random(x * 0.5, x)
	end
	
	--��ȡ�书����ʵ����
	local true_WL = get_skill_power(pid, wugong, level)

	--�޾Ʋ�����������������
	local atk = Atk(WAR.CurID)--JY.Person[pid]["������"]
	--�޾Ʋ������ط���������
	local def = Def(enemyid)--JY.Person[eid]["������"]
	
	--�޾Ʋ�����ϵ������
	local defadd = 0
	local wgtype = JY.Wugong[wugong]["�书����"];
	local NPCgxf = 1;
	local NPCfxf = 1;
	local defadd_max = 0

	--�޾Ʋ����������˺����㣬�Ѷ�ϵ��
	local difficulty_factor = 1;
	--�ҷ�����ʱ
	
	local mywuxue = 0
	local emenywuxue = 0
	for i = 0, WAR.PersonNum - 1 do
		local id = WAR.Person[i]["������"]
		
		--��ѧ��ʶ����
		if WAR.Person[i]["����"] == false and JY.Person[id]["��ѧ��ʶ"] > 10 then
			if WAR.Person[WAR.CurID]["�ҷ�"] == WAR.Person[i]["�ҷ�"] and mywuxue < JY.Person[id]["��ѧ��ʶ"] then
				mywuxue = JY.Person[id]["��ѧ��ʶ"]
			end
			if WAR.Person[enemyid]["�ҷ�"] == WAR.Person[i]["�ҷ�"] and emenywuxue < JY.Person[id]["��ѧ��ʶ"] then
				emenywuxue = JY.Person[id]["��ѧ��ʶ"]
			end
		end
		
		if emenywuxue < 10 then
			emenywuxue = 10
		end
	end
	
	--�޾Ʋ�����һЩ�߷�Ѩ������
	--ɨ�أ������У���������һ�ƣ������������������ȣ������죬��ҩʦ��������
	local gfxp = {114, 26, 129, 65, 18, 39, 70, 98, 57, 185}
	--�޾Ʋ�����һЩ����Ѫ������
	local glxp = {6, 3, 40, 97, 103, 19, 60, 71}

	--�����칦 ����ʦ 
	if WAR.DZTG_DZS == 1 or match_ID(pid,574) then
		if WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[enemyid]["�ҷ�"] then
			emenywuxue = emenywuxue*0.2
		end
	end	
	
	local hwxonbf = mywuxue
	if hwxonbf < emenywuxue then
		hwxonbf = emenywuxue
	end
	
	if match_ID(pid, 592) then
		if WAR.Person[WAR.CurID]["�ҷ�"] then
			mywuxue = hwxonbf
		else
			emenywuxue = hwxonbf
		end
	elseif match_ID(eid, 592) then
		if WAR.Person[WAR.CurID]["�ҷ�"] then
			emenywuxue = hwxonbf
		else
			mywuxue = hwxonbf
		end
	end
	
	--����ʵ��ʹ���书�ȼ�
	while true do
		if JY.Person[pid]["����"] < math.modf((level + 1) / 2) * JY.Wugong[wugong]["������������"] then
			level = level - 1
		else
			break;
		end
	end

	--��ֹ�������һ���ʱ��һ�ι�����ϣ��ڶ��ι���û�������������
	if level <= 0 then
		level = 1
	end

	
------------------------------------------------------------------------------------
-----------------------------------һЩ��Ч-----------------------------------------
------------------------------------------------------------------------------------
	
	
------------------------------------���ܼ���--------------------------------------

	
    if match_ID(pid, 510) and WAR.PD['����ͨ��'][pid] == 1 then 

    --���������λ
    elseif match_ID(pid, 604) then
		if WAR.TFBW == 0 then
			WAR.TFBW = 1
			Set_Eff_Text(WAR.CurID, "��Ч����0", "�����λ")
		end
	--��Ѱ�� С��ɵ� �����鷢
	elseif  match_ID(pid, 498) and WAR.XLFD[pid]~=nil then
		if WAR.TFBW == 0 then
			WAR.TFBW = 1
			Set_Eff_Text(WAR.CurID, "��Ч����0", "�����鷢")
		end	
	--
	elseif WAR.JYZJ_FXJ == 1 then
		--if WAR.TFBW == 0 then
		--	WAR.TFBW = 1
		--end				
	--����һ�� ��������
	elseif WAR.JTYJ[pid]~= nil or WAR.SL23  == 1 then 
		--if WAR.TFBW == 0 then
		--	WAR.TFBW = 1
		--end				
	--���޵���  
	elseif Curr_QG(pid,148) then
		if WAR.TLDWX == 0 then
			WAR.TLDWX = 1
			Set_Eff_Text(WAR.CurID, "��Ч����0", "���޵���")
		end
	--��������ǹ��������
	elseif match_ID(pid,568) and wugong == 200 then
		--if WAR.TFBW == 0 then
		--	WAR.TFBW = 1
		--end	
	--�����һ
	elseif WAR.Focus[pid] ~= nil then		
	--�������ս
	elseif match_ID(pid, 160) and WAR.SZSD == eid then
        
    elseif WAR.PD['��������������'][pid] == 1 then	
	else
		--�޾Ʋ������貨΢����15%��������
		if Curr_QG(eid, 147) and JLSD(0,15,eid) then
			local jl = 0
			if inteam(eid) then
				jl = 15
			else
				jl =30
			end
			WAR.Dodge = 1
			WAR.Person[enemyid]["��Ч����2"] = "�貨΢��"

		end
            --end
		--��ǧ�30%����
		if match_ID(eid, 88) and JLSD(0,30,eid) then
			WAR.Dodge = 1
			WAR.Person[enemyid]["��Ч����2"] = "�������ٲ�"	
		end
        
        if match_ID(eid, 9965) then 
            local jl = 5 
            if WAR.PD['�˾Ʊ�'][eid] ~= nil then
                jl = jl + 30
            end
            if JLSD(0,jl,eid) then
                WAR.Dodge = 1
                WAR.Person[enemyid]["��Ч����2"] = "�˾Ʊ����������ٲ�"
            end    
        end
        
			--����ˮ ������15%����
		if (match_ID(eid, 652) or Curr_NG(eid,177)) and JLSD(0,15,eid) and JY.Base["��������"] > 4  then
			WAR.Dodge = 1
			WAR.Person[enemyid]["��Ч����2"] = "����"	
			WAR.Person[enemyid]["��Ч����"] = 89
			
		end

		--���� ָ�50%����
		if match_ID(eid, 53) and WAR.TZ_DY == 1 and JLSD(0,50,eid) then
			WAR.Dodge = 1
			WAR.Person[enemyid]["��Ч����2"] = "�貨΢��"
		end
		
		--Ԭ���� ����
		if match_ID(eid, 566) then
			local sbjl = 15
			if  JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 4 then 
				sbjl = sbjl+20
			elseif JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 2 then 
				sbjl = sbjl+10 
			end	
			if JLSD(0,sbjl,eid) then
				WAR.Dodge = 1
		    end
	    end
		
		--�������Ŷݼף���ɫ��30%����
		if WAR.Person[enemyid]["�ҷ�"] == true and GetWarMap(WAR.Person[enemyid]["����X"], WAR.Person[enemyid]["����Y"],6) == 4 and JLSD(0,30,eid) then
			WAR.Dodge = 1
		end
		
		--����̩ɽ��ʹ�ú�30ʱ��������
		if WAR.TSSB[eid] ~= nil and JLSD(0,20,eid) then
			WAR.Dodge = 1
			WAR.Person[enemyid]["��Ч����2"] = "������"
		end

		--��ף�ʹ�ú�30ʱ��������
		if WAR.QLJX[eid] ~= nil and JLSD(20, 70, eid) then
			WAR.Dodge = 1
			WAR.Person[enemyid]["��Ч����2"] = "���������"
		end
		
		--���� ��ϵ����ʼ15%���ܣ�ÿ������������������5%����
		if JY.Base["��׼"] == 5 and eid == 0 then
			local gctj = 15
			for i = 1, JY.Base["�书����"] do
				if JY.Wugong[JY.Person[0]["�书" .. i]]["�书����"] == 5 and JY.Person[0]["�书�ȼ�" .. i] == 999 then
					gctj = gctj + 5
				end
			end
			if gctj > 50 then
				gctj = 50
			end
			if JLSD(0,gctj,eid) then
				WAR.Dodge = 1
				WAR.Person[enemyid]["��Ч����1"] = "�����"		--�����
			end
		end
		--������ ����
		if ZDGH(enemyid,569) and JLSD(0,15,eid) then	
			WAR.Dodge = 1
			WAR.Person[enemyid]["��Ч����1"] = "�������"		
		end
		
		--�������� 		--����;���
		if Curr_NG(eid, 105)  then
			--�������߱ض�����
			local jl = 15
			local jl1 = 0
			if match_ID(eid,27) then
				jl1 = 15
			end
			if match_ID(eid,511) then
				jl1 = 15
			end
			--if match_ID(eid,608) then
			--	jl1 = 30
			--end			
			if JLSD(0,jl+jl1,eid)  then
				WAR.Dodge = 1
				WAR.Person[enemyid]["��Ч����2"] = "��.��������"
				WAR.Person[enemyid]["��Ч����"] = 89
			end
		end
		
		--if inteam(eid) then
			for i = 0, WAR.PersonNum - 1 do
				local zid = WAR.Person[i]["������"]
				if WAR.Person[i]["����"] == false and WAR.Person[i]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and match_ID(zid, 609) then
                    if WAR.Defup[eid] == 1 and JLSD(0,20,zid) then
                        WAR.Dodge = 1
                    end
					break
				end
			end
		--end
		
		--����Ŀ���˺�ɱ������15%����15%����miss
		if WAR.KHCM[pid] == 2 then
			if WAR.MMGJ == 1 then
				WAR.Dodge = 1
			end
		end
		
		-- �����귭 15%����
		if Curr_QG(eid,224) then
			if JLSD(0,15,eid) then
				WAR.Dodge = 1
			end
		end
		-- ��ң�� 10%����
		if Curr_QG(eid,2)  then
			local jl = 10
			if JLSD(0,jl,eid) then
				WAR.Dodge = 1
			end	
		end
		
		--�޾Ʋ��������аٱ䣬12%��������
		if Curr_QG(eid, 146) then
			local c_up = 0
			local jl = 12

			--Ԭ��־���Ѻ�������+5%
			if match_ID_awakened(eid, 54, 1) then
				c_up = 10
			end
			if JLSD(0,jl+c_up,eid) then
				WAR.Dodge = 1
				WAR.Person[enemyid]["��Ч����2"] = "���аٱ�"
			end
		end
    end
    
	--�޾Ʋ���������ͳһ����
	if WAR.Dodge == 1 then
        
		WAR.Miss[eid] = 1
		WAR.Person[enemyid]['����'] = true
		WAR.MissPd = 1
		WAR.Dodge = 0
		hurt = 0
		--�׾Թ�϶
	    if  match_ID(eid, 566) then
			WAR.Person[enemyid]["��Ч����2"] = "�׾Թ�϶"
			if fjpd(WAR.CurID) == false and MyFj(WAR.CurID) == false then
				WAR.Person[enemyid]['����'] = 1
			end
	    end
	
		--��������
		if match_ID(pid,9994) then 
        --if pid == 0 then    
			if WAR.PD['��������'][pid] == nil then
                WAR.PD['��������'][pid] = {}
                WAR.PD['��������'][pid].n = 1
                WAR.PD['��������'][pid].s = 1
            else 
                if WAR.PD['��������'][pid].s == nil then
                    WAR.PD['��������'][pid].s = 1
                    WAR.PD['��������'][pid].n = (WAR.PD['��������'][pid].n or 0) + 1
                end
			end
		end
		goto label0
	end
	
	--���ܵ��˲���״̬
	if WAR.Miss[eid] == nil then 
	
		--ѩ����
		if WAR.BXXHSJ ==1 and DWPD() then
			JY.Person[eid]["����̶�"] = JY.Person[eid]["����̶�"] + 10 + Rnd(10)
			if JY.Person[eid]["����̶�"] > 100 then
				JY.Person[eid]["����̶�"] = 100
			end
			WAR.BFXS[eid] = 1
			if WAR.Person[enemyid]["��Ч����"] == -1 or WAR.Person[enemyid]["��Ч����"] == 63 then
				WAR.Person[enemyid]["��Ч����"] = 80
			end
		end

        if PersonKF(eid,227) then
            local gl = 25 
            local bl = limitX(JY.Person[eid]['����']/JY.Person[eid]['�������ֵ'],0.25,1)
            local gl2 = math.modf((1-bl)*100)
            if JLSD(0,gl+gl2,eid) then 
                WAR.Defup[eid] = 1
            end
        end
        
		-- ����
		if match_ID(pid,582) and JY.Person[eid]["����̶�"] > 50 and (JLSD(20,70,pid) or WAR.LQZ[pid] == 100) then
			WAR.LRHF[eid] = 10
			WAR.Person[enemyid]["��Ч����"] = 116
		end	

        if match_ID(pid, 510) and WAR.PD['��Ϧ��϶'][pid] == 1 then
            WAR.HLZT[eid] = 1
        end
        
		--����ˮ�����������50�ĵ��ˣ���60%���ʽ��䶳��5ʱ��
		if (match_ID(pid,652)  or Curr_NG(pid,177)) and JY.Person[eid]["����̶�"] > 50 and (JY.Base["��������"] > 1 or isteam(pid) == false) and JLSD(20,70,pid) and DWPD() then
			WAR.LRHF[eid] = 5
			WAR.Person[enemyid]["��Ч����"] = 116
			Set_Eff_Text(enemyid, "��Ч����3", "��ӳ")
		end
		
		--����ˮ����ȼ�մ���50�ĵ��ˣ�������ȼ
		if (match_ID(pid,652)  or Curr_NG(pid,177)) and JY.Person[eid]["���ճ̶�"] > 50 and JY.Base["��������"] > 2 
		and JLSD(20,70,pid) and DWPD() then
			WAR.JHLY[eid] = 10
			WAR.Person[enemyid]["��Ч����"] = 127
			Set_Eff_Text(enemyid, "��Ч����3", "����")
		end	

		--��̹֮�����������50�ĵ��ˣ���60%���ʽ��䶳��10ʱ��
		if match_ID(pid,48) and JY.Person[eid]["����̶�"] > 50 and JLSD(20,80,pid) and DWPD() then
			WAR.LRHF[eid] = 10
			WAR.Person[enemyid]["��Ч����"] = 116
			Set_Eff_Text(enemyid, "��Ч����3", "ǧ����ϡ�����")
		end
		
		--��һ��װ�����±��������������50�ĵ��ˣ���60%���ʽ��䶳��10ʱ��
		if match_ID(pid,633) and JY.Person[pid]["����"] == 45  and JY.Person[eid]["����̶�"] > 50 and JLSD(20,80,pid) and DWPD() then
			WAR.LRHF[eid] = 10
			WAR.Person[enemyid]["��Ч����"] = 116
			Set_Eff_Text(enemyid, "��Ч����3", "���µ���������")
		end	
		
		--�񾨸�
		if WAR.JXG_SJG ==1 and  DWPD()  then
			WAR.LSQ[eid] = 30
		end
		
		--������ȭ����
		if WAR.OYK == 1 and DWPD() then
			WAR.LSQ[eid] = 20
		end
		
		--�����л��е��ˣ��˺�����1%������20%
		if match_ID(pid,11) and DWPD() then
			WAR.GMZS[eid] = (WAR.GMZS[eid] or 0) + 1
			if WAR.GMZS[eid] > 20 then
				WAR.GMZS[eid] = 20
			end
		end
		--ɨ�ط�������
		if match_ID(pid,9963) and JLSD(0,50,pid) and DWPD() then
			WAR.PD["��������"][eid] = 1
			Set_Eff_Text(enemyid,"��Ч����0","��������")
			if WAR.Person[enemyid]["��Ч����"] == nil or WAR.Person[enemyid]["��Ч����"] == -1 then
			   WAR.Person[enemyid]["��Ч����"] = 142
			end			
		end
		 --��������ʽ1����
		if WAR.JYZS == 1 and DWPD() then
			WAR.XRZT[eid] = 60
			if WAR.Person[enemyid]["��Ч����"] == nil or WAR.Person[enemyid]["��Ч����"] == -1 then
				WAR.Person[enemyid]["��Ч����"] = 80
			end
			Set_Eff_Text(enemyid,"��Ч����3","����")
		end	
		 --�������� ����
		 if WAR.QLJG == 1 and DWPD() then
			WAR.PD['����'][eid] = 60
			if WAR.Person[enemyid]["��Ч����"] == nil or WAR.Person[enemyid]["��Ч����"] == -1 then
				WAR.Person[enemyid]["��Ч����"] = 80
			end
			Set_Eff_Text(enemyid,"��Ч����3","����")
		end		
	    --�������������
	    if PersonKF(pid,100) then
		   WAR.PD["�������"][pid] = 1
		    if WAR.PD["̫������"][eid] ~= nil or WAR.PD["�������"][eid] ~= nil or WAR.PD["��Ϣ����"][eid] ~= nil then
			   if WAR.Person[enemyid]["��Ч����"] == nil or WAR.Person[enemyid]["��Ч����"] == -1 then
				  WAR.Person[enemyid]["��Ч����"] = 80
			   end
			 Set_Eff_Text(enemyid,"��Ч����3","�������")
		   end
       end
		--�׶�����
		if WAR.LDJT == 1 and DWPD() then
			if WAR.WTL_LDJT[eid] == nil then
				--WAR.WTL_LDJT[eid] = math.random(3)
                WAR.WTL_LDJT[eid] = 1
			else WAR.WTL_LDJT[eid] = WAR.WTL_LDJT[eid]+1
                if WAR.WTL_LDJT[eid] > 3 then
					WAR.WTL_LDJT[eid] = 3
				end
			end
		end	
		
		--���˷�ָ�� �ƾ�
		if match_ID(pid, 3) and WAR.MRF == 1 then
			WAR.SGZT[eid] = 50
		end

		--��������ʽ2ɢ��״̬������ֹͣ���� ��ʱ����ʧ1%����
		if WAR.JYZS == 2 and DWPD() then
			WAR.SGZT[eid] = 20
		end	
		
		-- ÷����Ū1
		if WAR.MHSN == 1 and WAR.ACT == 1 and  DWPD()then 
			WAR.SGZT[eid] = 20
		end	
		
		--���֣�ʮ��ʮ������
		if WAR.SLSX[pid] ~= nil and DWPD() then
			WAR.HMZT[eid] = 1
		end
		
        if WAR.PD['�������𾪰���'][pid] == 1 and DWPD() then 
            WAR.HMZT[eid] = 1
        end
        
		--��̫�壬����ʱ60%���ʸ�������״̬������20��
		if match_ID(pid, 7) and DWPD() then
			if WAR.QYZT[eid] == nil then
				WAR.QYZT[eid] = math.random(3)
			else
				WAR.QYZT[eid] = WAR.QYZT[eid] + math.random(3)
				if WAR.QYZT[eid] > 20 then
					WAR.QYZT[eid] = 20
				end
			end
			if WAR.Person[enemyid]["��Ч����"] == nil or WAR.Person[enemyid]["��Ч����"] == -1 then
				WAR.Person[enemyid]["��Ч����"] = 63
			end
			Set_Eff_Text(enemyid,"��Ч����0","��������")
		end
		
		--��������
		if PersonKF(pid,138) and DWPD() then 
			if WAR.MRSHZT[eid] == nil then
				WAR.MRSHZT[eid] = math.random(2)
			else
				WAR.MRSHZT[eid] =WAR.MRSHZT[eid] + math.random(2)
				if WAR.MRSHZT[eid] > 3 then
					WAR.MRSHZT[eid] = 3	   
				end
			end
			if WAR.Person[enemyid]["��Ч����"] == nil or WAR.Person[enemyid]["��Ч����"] == -1 then
				WAR.Person[enemyid]["��Ч����"] = 72
			end
			Set_Eff_Text(enemyid,"��Ч����0","�κ�")	
		end

			--���� ����
		if WAR.KHLH ==1 and DWPD()then
			if WAR.CHZT[eid] == nil then
				WAR.CHZT[eid] = math.random(2)
			else
				WAR.CHZT[eid] = WAR.CHZT[eid] + math.random(2)
				if WAR.CHZT[eid] > 20 then
					WAR.CHZT[eid] = 20
				end
			end
		end	
		
        if WAR.PD['���־�'][pid] == 1 and DWPD() then 
            WAR.YYZS[eid] = 1
        end
        
        if WAR.PD['���־�'][pid] == 1 and DWPD() then 
            if WAR.CHZT[eid] == nil then
                WAR.CHZT[eid] = 20
            else
                WAR.CHZT[eid] = WAR.CHZT[eid] + 20
            end
			if WAR.CHZT[eid] > 20 then
				WAR.CHZT[eid] = 20
			end
        end
        
			--��������
		if WAR.PD["��"][pid]~= nil and WAR.PD["��"][pid] == 1 then
			WAR.MBJZ[eid] = 3
		end
		
	   -- ��������4
		if WAR.DSP_LM4 == 1 then
			local times = 1
			for i = 1, times do 
				local lm4 =  math.random(3)
				if lm4 == 1 then
					WAR.HMZT[eid] = 1
			end
				if lm4 == 2 then
					WAR.SZZT[eid] = 1
				end
				if lm4 == 3 then
					WAR.XRZT1[eid] = 1
				end
			end
		end
		
		if WAR.SL23 == 1 and JLSD(20,50,pid) and DWPD() then
			WAR.HMZT[eid] = 1
		end	
		
		--׿������������
		if match_ID(pid,613) and wugong == 205 and JLSD(10,20,pid) and DWPD() then
			WAR.HMZT[eid] = 1
		end	
		
		--�׶�����
		if WAR.LQZ[pid] == 100 and WAR.WTL_LDJT[eid] ~= nil and WAR.WTL_LDJT[eid] >=3 and DWPD() then
			WAR.HMZT[eid] = 1
			WAR.WTL_LDJT[eid] = nil
		end	

		--�������� ����
		if WAR.YLTW == 1 and JLSD(20,70,pid) and DWPD()  then
			WAR.SZZT[eid] = 1
		end	
		
		--Ұ��ȭ ����
		if WAR.PD['Ұ��ȭ'][pid] == 3 and DWPD() and JLSD(0,40,pid) then
			WAR.SZZT[eid] = 1
		end	
        
        if WAR.PD['���־�'][pid] == 1 and DWPD() then 
            WAR.SZZT[eid] = 1
        end
        
		--����1
		if WAR.NZZ1 ==1 and DWPD() then
			WAR.XRZT1[eid] = 1
		end
		if  WAR.DHBUFF == 1 and DWPD() then
			WAR.PD["����"][eid] = 1
	     end	
		--�Ȼ�״̬
		--if WAR.AJFHNP ==1 and DWPD() then
			--WAR.MHZT[eid] = 2
		--end	
		
		--һ����һ��ָ������ҵ��
		if match_ID(pid, 65) and wugong == 17 and DWPD() then
			WAR.WMYH[eid] = 30
		end
		
		--������1  ͬ�齣����
		if match_ID(pid,129) and DWPD() then
			WAR.TGJF[eid] = 1
		end	
		
		--�޾Ʋ��������к��棬����+����+���飬��ŭ��ɶ���Ч��
		if (WAR.LiRen == 1 or Curr_NG(pid,216 and JLSD(10,90,eid)))and DWPD() then
			WAR.LRHF[eid] = 10
			WAR.Person[enemyid]["��Ч����"] = 116
		end	
		
        if WAR.PD['���ϵ�'][pid] == 2 and DWPD() then
            if JY.Person[pid]['��������'] == 0 or JY.Person[pid]['��������'] == 3 then 
                WAR.LRHF[eid] = 10	
                WAR.Person[enemyid]["��Ч����"] = 116
            end
        end
        
		--�޾Ʋ������ٻ���ԭ������+ȼľ+���浶����ŭ�����ȼЧ��
		if WAR.JuHuo == 1 and DWPD() then
			WAR.JHLY[eid] = 10	
			WAR.Person[enemyid]["��Ч����"] = 112
		end
        
        if WAR.PD['���ϵ�'][pid] == 2 and DWPD() then
            if JY.Person[pid]['��������'] == 1 or JY.Person[pid]['��������'] == 3 then 
                WAR.JHLY[eid] = 10	
                WAR.Person[enemyid]["��Ч����"] = 112
            end
        end
        
		--ʥ������
		if match_ID(pid,9992) and JY.Person[eid]["���ճ̶�"] > 25  and DWPD() then
			WAR.JHLY[eid] = 10
			WAR.Person[enemyid]["��Ч����"] = 112
		end
		
		if match_ID(pid,9992) and JY.Person[eid]["���ճ̶�"] > 25 then
			for i= 0,WAR.PersonNum-1 do
				if WAR.Person[i]["����"] == false and WAR.Person[i]["�ҷ�"] == WAR.Person[enemyid]["�ҷ�"] then
					local e = WAR.Person[i]["������"]
					local x1,y1 = WAR.Person[enemyid]["����X"],WAR.Person[enemyid]["����Y"]
					local x2,y2 = WAR.Person[i]["����X"],WAR.Person[i]["����Y"]
					if math.abs(x1-x2) +math.abs(y1-y2) <= 3 then
						WAR.JHLY[e] = 5
					end		
				end
			end
		end
	end	
	
	--����Ů���޵����������Ӽ���״̬
	if Curr_QG(pid,148) and match_ID(pid,640) then
		if WAR.JFJQ[pid] == nil then
			WAR.JFJQ[pid] = math.random(2)
		else
			WAR.JFJQ[pid] = WAR.JFJQ[pid] + math.random(3)
			if WAR.JFJQ[pid] > 10 then
				WAR.JFJQ[pid] = 10
			end
		end
	end	
	
	--��ң����
	if XiaoYaoYF(eid) and JLSD(20,70,eid) and (WAR.XYYF[eid] == nil or WAR.XYYF[eid] < 9) and WAR.YFCS < 3 then
		WAR.YFCS = WAR.YFCS + 1
		WAR.XYYF[eid] = (WAR.XYYF[eid] or 0) + 1
		Set_Eff_Text(enemyid,"��Ч����2","��ң����")
		if WAR.XYYF[eid] == 9 then
			WAR.XYYF[eid] = 11
			WAR.XYYF_10 = 1
		end
	end	
	
	--ŷ���������߻�
	--�����˲Ż�
	if WAR.PD["�߻�״̬"][eid] ~= 1 and match_ID(eid, 60) and PersonKF(eid, 104) then
		if JY.Person[eid]["����"] > 50 then
			WAR.Person[enemyid]["��Ч����"] = math.fmod(wugong, 10) + 85
			WAR.Person[enemyid]["��Ч����3"] = "��--���˽����߻���ħ"
			WAR.PD["�߻�״̬"][eid] = 1
		end
	end
	
	--ʯ���죬50%���ʸ��������Ϸ�Ѩ
	if (match_ID_awakened(eid, 38, 1) or (Curr_NG(eid,102) and (JY.Person[192]["Ʒ��"] == 60))) and DWPD() and JLSD(20,70,eid) and MyFj(WAR.CurID) == false then
		WAR.Person[enemyid]["��Ч����"] = math.fmod(wugong, 10) + 85
		Set_Eff_Text(enemyid, "��Ч����3", "̫���񹦡�����")
		WAR.FXXS[WAR.Person[WAR.CurID]["������"]] = 1
       	WAR.FXDS[WAR.Person[WAR.CurID]["������"]] = (WAR.FXDS[WAR.Person[WAR.CurID]["������"]] or 0) + 10
		--��Ѩ����50��
		if 50 < WAR.FXDS[WAR.Person[WAR.CurID]["������"]] then
			WAR.FXDS[WAR.Person[WAR.CurID]["������"]] = 50
		end
	end
	
	--�����֣���������ǿ���϶�
	if match_ID(eid, 83) and DWPD() then
		WAR.Person[WAR.CurID]["�ж�����"] = (WAR.Person[WAR.CurID]["�ж�����"] or 0) + AddPersonAttrib(pid, "�ж��̶�", math.random(45, 50))
	end
	
	--�����򣬽��͹���������
	if match_ID(eid, 649) and DWPD() then
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", -math.random(5,10))
	end
	
	   -- �����칦 ������
    if PersonKF(eid,190) and WAR.ZTHF[eid]== nil then
		local jl = 30
		if Curr_NG(eid,190) then
			jl = 50
		end
		if JLSD(0,jl,eid) then
			WAR.ZTHF[eid] = 50
			Set_Eff_Text(enemyid, "��Ч����1", "������")
		end
	end
	
	--����̫���񹦣�60%�����ۻ�̫��֮��
	if Curr_NG(eid, 171) and JLSD(20,80,eid) then
		WAR.TJZX[eid] = (WAR.TJZX[eid] or 0) + 1
		if WAR.TJZX[eid] > 10 then
			WAR.TJZX[eid] = 10
		end
		Set_Eff_Text(enemyid, "��Ч����3", "̫��֮��")
	end

	--˾��ժ��ǧ�����
	if match_ID(eid, 579) then
		WAR.SKZX[eid] = (WAR.SKZX[eid] or 0) + 2
		if WAR.SKZX[eid] > 10 then
			WAR.SKZX[eid] = 20
		end
		Set_Eff_Text(enemyid, "��Ч����3", "ǧ�����")
	end
	
	--������ʤ���л���
	--����Ů �㺮���
	if WAR.FQY == 1 or WAR.GHQH == 1 then
		if WAR.WZSYZ[eid] == nil then
			WAR.WZSYZ[eid] = 10
		end
		if WAR.WZSYZ[eid] > 10 then
			WAR.WZSYZ[eid] = 10	
		end
	end
		
	
		--������г֮������
	if WAR.LXXZD == 1 then
		if WAR.XZD[eid] == nil then
			WAR.XZD[eid] = 10
		end
		if WAR.XZD[eid] > 10 then
			WAR.XZD[eid] = 10	
		end
	end

	
	--��ң����Ӽ��ˣ�����20%
	if match_ID(eid,10) and WAR.GMYS < 20 then
		WAR.GMYS = WAR.GMYS + 1
	end
	
	
	   -- ��󡹦����
	if PersonKF(eid, 95) then
		if WAR.PD["�������"][eid] == nil or WAR.PD["�������"][eid] == 0 then
			WAR.PD["�������"][eid] = 50;
		else
			WAR.PD["�������"][eid] = WAR.PD["�������"][eid] + 35;
		end
	  Set_Eff_Text(enemyid, "��Ч����2", "��󡹦����")
	end
	
		--½����֮��
	if match_ID(eid, 497) and JY.Base["��������"] > 6 then
 	    WAR.HZD_2 = 1
       Set_Eff_Text(enemyid, "��Ч����1", "���ɰٴ�")
		WAR.Person[enemyid]["��Ч����"] = 111
	end	
	
	--��Ϧ���أ��򹷰��������־����»غϲ����ƶ�
	if wugong == 80 and match_ID(pid, 613) and WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[enemyid]["�ҷ�"] then
		WAR.L_NOT_MOVE[eid] = 1;
	end
	
	--���޵�����������
	if Curr_QG(pid,148) then
		WAR.TLDW[eid] = 1;
	end
	
	--���� �������
	if match_ID_awakened(eid,629,1) and (JLSD(20, 70, eid) or WAR.LQZ[eid] == 100) then
		WAR.FGPZ[eid]= 1
		WAR.Person[enemyid]["��Ч����"] = 154
       Set_Eff_Text(enemyid, "��Ч����1", "�������")
	end	
	
	--��ȴ���࣬50%�������߱��ι�����ɵ�����/��Ѩ/����/����
	if ChuQueSX(eid) and JLSD(20,90,eid) then
		WAR.CQSX = 1
		WAR.Person[enemyid]["��Ч����"] = 79
		Set_Eff_Text(enemyid, "��Ч����1", "��ȴ����")
	end
	
	--������������
	if match_ID(eid,5) and not inteam(eid) and WAR.ZDDH == 348 and JLSD(10,40,eid) then
		WAR.Person[enemyid]["��Ч����"] = 6
		Set_Eff_Text(enemyid, "��Ч����0", "��������")
		WAR.PD['������'][eid] = limitX((WAR.PD['������'][eid] or 0) + math.random(2, 3),0,20)
	end	
	
	--��������
	if match_ID(eid, 9970) and JLSD(10,50,eid) then 
		WAR.Person[enemyid]["��Ч����"] = 6
		Set_Eff_Text(enemyid, "��Ч����0", "��������")
		WAR.PD['������'][eid] = limitX((WAR.PD['������'][eid] or 0) + math.random(2, 3),0,20)
	end
	
   
	--��ӹ֮�� 
    --[[
	if eid == 0 and DWPD() and ZhongYongZD(eid) and WAR.ZYCD == 0 then
		if JLSD(20,40+JY.Base["��������"]*0.5,eid) or WAR.LQZ[eid] == 100 then
			WAR.Person[enemyid]["��Ч����"] = 6
			Set_Eff_Text(enemyid, "��Ч����0", "��ӹ֮��")
			WAR.ACT = 10
			--������ɶ�ת�����ģ��򲻴������
			if WAR.DZXY == 0 then
				WAR.ZYHB = 0
			end
			WAR.ZYZD = 1
			WAR.ZYCD = 40
		end
	end	
	]]
    --½����ʮ������ һ����
	if match_ID(eid, 497)  then
		WAR.SSESS[eid] = 100
	end	
------------------------------------------------------------------------------------
-----------------------------------�����ӳ�-----------------------------------------
------------------------------------------------------------------------------------
    --if inteam(pid) == false then 
        --ang = ang + (JY.Base['�Ѷ�'])*500
    --end
    
	--��ת�����˺���ɱ��������
	if WAR.DZXYLV[pid] ~= nil and WAR.DZXYLV[pid] > 10 then
		ang = ang + WAR.DZXYLV[pid] * 10
	end

	--ȫ�����ӣ�������������˺�������
	if WAR.ZDDH == 73 then
		if (pid >= 123 and pid <= 128) or pid == 68 then
			ang = ang + 1200
		end
	end	

	--�ֳ�Ӣ����������
	if match_ID(pid, 605) then
		ang = ang * 1.1
	end

	--�������˺�����������
	if WAR.ACT > 1 then
		local LJ_fac = 0.7	--ͨ��Ϊ70%
		if match_ID(pid, 27)  or wugong == 49 or wugong == 62 or WAR.YNXJ == 1 or match_ID(pid,5) or WAR.ZYHB > 0 then
			LJ_fac = 1
		end	
		if Curr_NG(eid, 169)  then
			LJ_fac = LJ_fac - 0.4
		elseif PersonKF(eid, 169) then
			LJ_fac = LJ_fac - 0.2
		end
		ang = math.modf(ang * LJ_fac)
	end

	--����״̬��ɱ������
	if WAR.XRZT[pid] ~= nil then
		ang = math.modf(ang * 0.5)
	end
	
	--����״̬1��ɱ������
	if WAR.XRZT1[pid] ~= nil then
		ang = math.modf(ang * 0.5)
	end

	--����״̬���˺���ɱ��������
	if WAR.Focus[pid] ~= nil then
	    ang = math.modf(ang * 0.5)
	end

	--�޺���ħ�����˺���ɱ��Ч��Ϊ��[(��ǰ����ֵ/500)��(�书��������/140)]%
	if Curr_NG(pid, 96) or ((Curr_NG(pid, 108) or match_ID(pid,38)) and PersonKF(pid,96)) then
		local nlmod = JY.Person[pid]["����"]/30000
		local wgmod = JY.Wugong[wugong]["������������"]/2000
		local totalmod = 1 + nlmod + wgmod;
		--ʯ����Ч�����1.1��
		if match_ID(pid, 38)  or Curr_NG(pid, 108) then
			totalmod = totalmod * 1.1;
		end
		ang = math.modf(ang * totalmod)
	end

	--�������Ŷݼף���ɫ����ɱ��
	if WAR.Person[WAR.CurID]["�ҷ�"] == true and GetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"],6) == 3 then
		ang = ang + 400
	end
	
	--����Ŀ���˺�ɱ������15%����15%����miss
	if WAR.KHCM[pid] == 2 then
		ang = math.modf(ang *0.85)
	end
	
	--�����ݣ�50%���ʼ���50%��������
	if Curr_QG(eid,149) and JLSD(20, 70, eid) and ang > 0  then
		ang = math.modf(ang *0.8)
		WAR.Person[enemyid]["��Ч����"] = 153
		Set_Eff_Text(enemyid, "��Ч����2", "�����ݺ�")
	end
	
    if ZDGH(enemyid,569) then 	
        ang = math.modf(ang *0.8)
		WAR.Person[enemyid]["��Ч����"] = 90
	end
	
	--���ѧ��������������δ�����������壬����(����-220)%���ʴ����Խ��������з���������
	if PersonKF(eid, 175) and WAR.ZQHT == 0 and ang > 0 then
		local chance = math.modf(TrueYJ(eid)/10)+10
		--local chance = yj
		if JLSD(0,chance,eid) or inteam(eid) == false then
			ang = math.modf(ang *0.8)
			WAR.Person[enemyid]["��Ч����"] = 137
			Set_Eff_Text(enemyid, "��Ч����1", "�Խ�����")
		end
	end
	
	--���
	if match_ID(eid, 588) then
	    ang = math.modf(ang * 0.9)
	end

	--������
	if Curr_NG(eid,203) then
	    ang = math.modf(ang * 0.7)
	end
    
	--������
	if Curr_NG(eid,203) and JLSD(0,25,eid) then
	    WAR.PD['������'][eid] = 10
        Set_Eff_Text(enemyid, "��Ч����3", "�˵�����")
	end
	
	-- ����
	if match_ID(eid,583) then
		ang = math.modf(ang *0.85)
	end
	
	
	--�޾Ʋ�����̫�����壬����35%ɱ������̫������ɱ��
	for i = 1, JY.Base["�书����"] do
		if (JY.Person[eid]["�书" .. i] == 16 or JY.Person[eid]["�书" .. i] == 46) and JY.Person[eid]["�书�ȼ�" .. i] == 999 then
		  WAR.TJAY = WAR.TJAY + 1
		end
	end

	if WAR.TJAY == 2 then
		--������85%����
		if match_ID(eid, 5) then
			if JLSD(10, 95, eid) then
				WAR.TJAY = 3
			end
		--������(45+����/4)%����
		else
			if JLSD(10, 55 + math.modf(JY.Person[eid]["����"] / 4), eid) then
				WAR.TJAY = 3
			end
		end
	end
    
	--ɱ������25%
	if WAR.TJAY == 3 then
		ang = ang * 0.75
	end
	
	--������
	if  Curr_NG(eid,106) and ang > 0 and (JY.Person[eid]["��������"] == 1 or JY.Person[eid]["��������"] == 3) and (JLSD(20,80,eid) or WAR.LQZ[eid] == 100) and DWPD() then
		ang = ang*0.7
		WAR.PD['������'][eid] = 1
		Set_Eff_Text(enemyid, "��Ч����0", "������")
		WAR.Person[enemyid]["��Ч����"] = 90
	end
	
	--���ǵ�ϵ��ÿ�������������������ܵ���5%ɱ��
	if JY.Base["��׼"] == 4 and eid == 0 then
		local askd = 0
		for i = 1, JY.Base["�书����"] do
			if JY.Wugong[JY.Person[0]["�书" .. i]]["�书����"] == 4 and JY.Person[0]["�书�ȼ�" .. i] == 999 then
				askd = askd + 1
			end
		end
		if askd > 7 then
			askd = 7
		end
		
		ang = math.modf(ang * (1 - 0.05 * askd))
	end
	
	--����ÿ���书�������������ܵ���3%ɱ��
	if match_ID(eid, 9981) then
		local LXBR = 0
		for i = 1, JY.Base["�书����"] do
			if JY.Wugong[JY.Person[0]["�书" .. i]] and JY.Person[0]["�书�ȼ�" .. i] == 999 then
				LXBR = LXBR + 1
			end
		end
		if LXBR > 7 then
			LXBR = 7
		end
		ang = math.modf(ang * (1 - 0.03 * LXBR))
	end
	
	--�޾Ʋ����������ػ�64%���ʣ��̶�����32���˺�
	for i = 1, JY.Base["�书����"] do
		if (JY.Person[eid]["�书" .. i] == 37 or JY.Person[eid]["�书" .. i] == 60) and JY.Person[eid]["�书�ȼ�" .. i] == 999 then
			WAR.LYSH = WAR.LYSH + 1
		end
	end
    
	if WAR.LYSH == 2 and JLSD(20, 84, eid) then
		WAR.LYSH = 3
	end
    
	--�����ػ�����320������
	if WAR.LYSH == 3 then
		ang = ang - 320
		if ang < 0 then
			ang = 0
		end
	end
	
   
	
	--���� ����999������
	if WAR.FGPZ[eid]~= nil then
		ang = ang -999
	 	if ang < 0 then
			ang = 0
		end
	end
	
    WAR.FGPZ[eid] = nil
	
------------------------------------------------------------------------------------
-----------------------------------�����ӳ�-----------------------------------------
------------------------------------------------------------------------------------
	--�޾Ʋ����������ڹ����壬��Ϊ�з��Żᴥ��
	--�ܲ�ͨ����֮���ʹ�з����Ụ��
	if DWPD() and WAR.KMZWD == 0 then
		local ht = {};		
		local num = 0;	--��ǰѧ�˶��ٸ��ڹ�
		for i = 1, CC.Kungfunum do
			local kfid = JY.Person[eid]["�书" .. i]
			local kflvl = JY.Person[eid]["�书�ȼ�" .. i]
			if kflvl == 999 then
				kflvl = 11
			else
				kflvl = math.modf(kflvl / 100) + 1
			end
			--�Ȱ��ڹ�����������������ղ�������������������
			if JY.Wugong[kfid]["�书����"] == 6 and kfid ~= 85 and kfid ~= 87 and kfid ~= 88 and kfid ~= 144 and kfid ~= 175 then
				num = num + 1;
				ht[num] = {kfid,i,get_skill_power(eid, kfid, kflvl)};
			end
		end
				
		--���ѧ���ڹ�
		if num > 0 then	
			--���������Ӵ�С��������һ���Ļ����������Ⱥ�˳��
			for i = 1, num - 1 do
				for j = i + 1, num do
					if ht[i][3] < ht[j][3] or (ht[i][3] == ht[j][3] and ht[i][2] > ht[j][2])then
						ht[i], ht[j] = ht[j], ht[i]
					end
				end
			end
			--��˳���ж�����
			for i = 1, num do
				if myrandom(10, eid) then
					dng = ht[i][3];
					WAR.Person[enemyid]["��Ч����2"] = JY.Wugong[ht[i][1]]["����"] .. "����"
					WAR.Person[enemyid]["��Ч����"] =  87 + math.random(6)
					WAR.NGHT = ht[i][1];
					break;
				end
			end
		end
	

		--�����츳�ڹ�����+200����35%������+300
		if JY.Person[eid]["�����ڹ�"] > 0 and JY.Person[eid]["�����ڹ�"] == JY.Person[eid]["�츳�ڹ�"] then
			dng = dng + 200;
			if JLSD(30, 65, eid) then
				dng = dng + 300;
				Set_Eff_Text(enemyid, "��Ч����3", "�츳�ڹ�����")
			end
		end

		--��󡹦��������
		if WAR.NGHT == 0 and (PersonKF(eid, 95) or PersonKF(eid, 180)) then
			dng = dng + 900;
			WAR.Person[enemyid]["��Ч����"] = 87 + math.random(6)
		end
	end
	
    if WAR.NGHT == 0 then 
        if isteam(eid) == false then 
            Set_Eff_Text(enemyid, "��Ч����2", "��������")
            WAR.Person[enemyid]["��Ч����"] =  87 + math.random(6)
        end
    end
    
	--���嶯��
	if WAR.NGHT == 204 then
		WAR.Person[enemyid]["��Ч����"] = 111 
	end
	
	if match_ID(eid,50) and WAR.NGHT == 0 and PersonKF(eid,204) then
	 	WAR.Person[enemyid]["��Ч����"] = 111
		WAR.Person[enemyid]["��Ч����2"] = "����������"
		dng = dng + 1200
	end
	
	--���޼� ����ɮ�����񹦻���
	if  WAR.NGHT == 0 and PersonKF(eid, 106) then
		WAR.Person[enemyid]["��Ч����"] = 87 + math.random(6)
		WAR.Person[enemyid]["��Ч����2"] = "�����񹦻���"
		dng = dng + 1200
	end
	
	--�۽���Ӯ����Ľ����������������800��
	if eid == 0 and JY.Person[604]["�۽�����"] == 1 then
		dng = dng + 800
	end
	
	-- ���㹦
	if Curr_QG(eid,223) then
		dng = dng + 800
	end
	
	--�������� ��
	if WAR.PD["��"][eid]~= nil and WAR.PD["��"][eid] == 1 then
		dng = dng + 800
	end

	--�ɸ磬����+2000��
	if eid == 627 or eid ==567 or eid == 568 then
		dng = dng + 2000
	end
	
    -- ��ϫ��
	if Curr_NG(eid,172) then
	    dng = dng + JY.Person[eid]["����"]/7
	end
	
	--[[
    --�ѷ������ӳ�����
	if inteam(eid) then
		dng = dng + (JY.Person[eid]["����"]/10)
	end
	]]
	
	--����״̬
	if WAR.Defup[eid] == 1  then
		WAR.Person[enemyid]["��Ч����"] = 90
		Set_Eff_Text(enemyid, "��Ч����1", "����״̬")
		if PersonKF(eid, 101) then     --�˻�����+1000
			dng = dng + 800
		else
			dng = dng + 400
		end
	end

		--����ˮ �������黤��
	if match_ID(eid, 652) then
		dng = dng + 800
		if not inteam(eid) then
			dng = dng + 800
		end
		WAR.Person[enemyid]["��Ч����"] = 86
		if WAR.Person[enemyid]["��Ч����2"] ~= nil then
			WAR.Person[enemyid]["��Ч����2"] = WAR.Person[enemyid]["��Ч����2"].."+��������"
		else
			WAR.Person[enemyid]["��Ч����2"] = "�������黤��"
		end
		WAR.ZQHT = 1
	end

	--�Ħ��
	if match_ID(eid, 103) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["��������"]+math.modf(JY.Person[eid]["ʵս"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			WAR.Person[enemyid]["��Ч����"] = math.fmod(98, 10) + 85
			Set_Eff_Text(enemyid, "��Ч����2", "��������")
			WAR.ZQHT = 1
		end
	end
	
	
	--����
	if match_ID(eid, 18) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["��������"]+math.modf(JY.Person[eid]["ʵս"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			WAR.Person[enemyid]["��Ч����"] = math.fmod(106, 10) + 85
			if WAR.Person[enemyid]["��Ч����2"] ~= nil then
				WAR.Person[enemyid]["��Ч����2"] = WAR.Person[enemyid]["��Ч����2"].."+��Ԫ������"
			else
				WAR.Person[enemyid]["��Ч����2"] = "��Ԫ����������"
			end
			WAR.ZQHT = 1
		end	
	end

	--���߹�
    if match_ID(eid, 69) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["��������"]+math.modf(JY.Person[eid]["ʵս"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			
			WAR.Person[enemyid]["��Ч����"] = 67
			Set_Eff_Text(enemyid, "��Ч����2", "ؤ������")
			WAR.ZQHT = 1
		end	
    end
 
	--��ҩʦ
    if match_ID(eid, 57) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["��������"]+math.modf(JY.Person[eid]["ʵս"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			WAR.Person[enemyid]["��Ч����"] = 95
			Set_Eff_Text(enemyid, "��Ч����2", "���Ű���")
			WAR.ZQHT = 1
		end
    end
      --��̫��
    if match_ID(eid, 7) then
		dng = dng + 1200
		if not inteam(eid) then
			dng = dng + 1200
		end
		WAR.Person[enemyid]["��Ч����"] = math.fmod(98, 10) + 85
		Set_Eff_Text(enemyid, "��Ч����2", "̫�����")
		WAR.ZQHT = 1
	end
	
	--л�̿�
    if match_ID(eid, 164) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["��������"]+math.modf(JY.Person[eid]["ʵս"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 500
			if not inteam(eid) then
				dng = dng + 500
			end
			WAR.Person[enemyid]["��Ч����"] = 23
			Set_Eff_Text(enemyid, "��Ч����2", "Ħ���ʿ")
			WAR.ZQHT = 1
		end
    end
	
	--������
	if match_ID(eid, 26) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["��������"]+math.modf(JY.Person[eid]["ʵս"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			WAR.Person[enemyid]["��Ч����"] = 6
			Set_Eff_Text(enemyid, "��Ч����2", "���¡�ͬ��")
			WAR.ZQHT = 1
		end
	end
	
	--�ݳ���
    if match_ID(eid, 594) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["��������"]+math.modf(JY.Person[eid]["ʵս"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			WAR.Person[enemyid]["��Ч����"] = 93
			Set_Eff_Text(enemyid, "��Ч����2", "�����Ὥ")
			WAR.ZQHT = 1
		end
    end
	
	--Ľ�ݲ�
    if match_ID(eid, 113) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["��������"]+math.modf(JY.Person[eid]["ʵս"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			WAR.Person[enemyid]["��Ч����"] = 93
			Set_Eff_Text(enemyid, "��Ч����2", "�κ�����")
			WAR.ZQHT = 1
		end
    end
	
	--��������ɳ����ÿɱһ����+200����
	if match_ID(eid, 47) then
		dng = dng + 200*WAR.MZSH
	end
	
	--��Ϣ������ֵ������������ֵ
	if PersonKF(eid,180) and WAR.PD["��Ϣ����"][eid] ~= nil then
		dng = dng + math.modf(WAR.PD["��Ϣ����"][eid])
	end
	
	--����
    if match_ID(eid, 102) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["��������"]+math.modf(JY.Person[eid]["ʵս"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			WAR.Person[enemyid]["��Ч����"] = 93
			Set_Eff_Text(enemyid, "��Ч����2", "��������")
			WAR.ZQHT = 1
		end
    end
	
	--������
    if match_ID(eid, 83) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["��������"]+math.modf(JY.Person[eid]["ʵս"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 500
			if not inteam(eid) then
				dng = dng + 500
			end
			WAR.Person[enemyid]["��Ч����"] = 92
			Set_Eff_Text(enemyid, "��Ч����2", "�������")
			WAR.ZQHT = 1
		end
    end
	
	--������
    if match_ID(eid, 22) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["��������"]+math.modf(JY.Person[eid]["ʵս"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 500
			if not inteam(eid) then
				dng = dng + 500
			end
			WAR.Person[enemyid]["��Ч����"] = 1
			Set_Eff_Text(enemyid, "��Ч����2", "��������")
			WAR.ZQHT = 1
		end
    end
	
	--������
    if match_ID(eid, 12) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["��������"]+math.modf(JY.Person[eid]["ʵս"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 500
			if not inteam(eid) then
				dng = dng + 500
			end
			WAR.Person[enemyid]["��Ч����"] = 92
			Set_Eff_Text(enemyid, "��Ч����2", "ӥ������")
			WAR.ZQHT = 1
		end
    end
	
	--����
	if match_ID(eid, 604) then
		dng = dng + TrueYJ(eid)*5
		if not inteam(eid) then
			dng = dng + TrueYJ(eid)*5
		end
		WAR.Person[enemyid]["��Ч����"] = 121
		Set_Eff_Text(enemyid, "��Ч����2", "������Ϣ")
		WAR.ZQHT = 1
    end
	
	
	--���񹦵�����
	if PersonKF(eid, 106) and (JY.Person[eid]["��������"] == 1 or (JY.Person[eid]["��������"] == 3 and JY.Person[eid]["�츳�ڹ�"] == 106)) then
		if  JLSD(30, 50 + JY.Base["��������"]*3,eid) then 
			dng = dng + 800
			if WAR.Person[enemyid]["��Ч����"] == -1 then
				WAR.Person[enemyid]["��Ч����"] =  87 + math.random(6)
			end
			Set_Eff_Text(enemyid, "��Ч����1", "��������")
			WAR.ZQHT = 1
		end
	end
	
	--��������
	if PersonKF(eid, 107) and (JY.Person[eid]["��������"] == 0 or (JY.Person[eid]["��������"] == 3 and JY.Person[eid]["�츳�ڹ�"] == 107)) then
		if JLSD(30, 50 + JY.Base["��������"]*3,eid) then
			dng = dng + 650
			if WAR.Person[enemyid]["��Ч����"] == -1 then
				WAR.Person[enemyid]["��Ч����"] =  87 + math.random(6)
			end
			Set_Eff_Text(enemyid, "��Ч����1", "��������")
			WAR.ZQHT = 1
		end
	end
	
	--�׽�����
	if PersonKF(eid, 108) and (JY.Person[eid]["��������"] == 2 or (JY.Person[eid]["��������"] == 3 and JY.Person[eid]["�츳�ڹ�"] == 108) ) then
		if JLSD(30, 50 + JY.Base["��������"]*3,eid) then
			dng = dng + 650
			if WAR.Person[enemyid]["��Ч����"] == -1 then
				WAR.Person[enemyid]["��Ч����"] =  87 + math.random(6)
			end
			Set_Eff_Text(enemyid, "��Ч����1", "�׽�����")
			WAR.ZQHT = 1
		end
	end
	
	--��ڤ�����������ӱط�����ѧ�б�ڤ/������Ѻ��ʷ���
	if ((PersonKF(eid, 85) or match_ID_awakened(eid, 49, 1)) and JLSD(20, 70, eid)) or match_ID(eid, 634) or match_ID(eid, 116) then
		dng = dng + 800
		if WAR.Person[enemyid]["��Ч����"] == -1 then
			WAR.Person[enemyid]["��Ч����"] = 85
		end
		Set_Eff_Text(enemyid, "��Ч����2", "��ڤ����")
		WAR.ZQHT = 1
	end
		
 	if match_ID(eid, 637)  then
		if WAR.HXZYJ == 1 then
			dng = dng + 1200
		end
	end
	
	--ʥ����ʹ ���˺����١��������
	if WAR.ZDDH == 14 and (eid == 173 or eid == 174 or eid == 175) then
		local shz = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[enemyid]["�ҷ�"] then
			shz = shz + 1
			end
		end
		if shz == 3 then
			dng = dng + 1000
		end
	end

	--�η���
    if match_ID(eid,615)then
       dng = dng + JY.Person[eid]["�Ṧ"]*2
    end
	
	--�޾Ʋ�����С���๦��������
	--����
	if Curr_NG(eid, 98) then
		dng = dng * 1.3
	--����
	elseif PersonKF(eid, 98) then
		dng = dng * 1.1
	end
	
	--̫�齣�� �������� 躹�����
	if Curr_NG(eid, 152) then
		local TX = 0
		TX = ang*0.2
		if TX < 1500 then	 
			dng = dng + TX
			WAR.Person[enemyid]["��Ч����"] = 137
			Set_Eff_Text(enemyid, "��Ч����1", "躹����ޡ���������")	
		end
	end
	
	--ȫ�����ӣ�����������˺����ٺ���������
	if WAR.ZDDH == 73 then
		if (eid >= 123 and eid <= 128) or eid == 68 then
			dng = dng + 1200
			WAR.Person[enemyid]["��Ч����"] = 93
			Set_Eff_Text(enemyid, "��Ч����2", "���������")
		end
	end
	
	--��շ�ħȦ���˺�һ���٣��������
	if PersonKF(eid, 82) then
		local jgfmq = 0
		local effstr = "��շ�ħȦ"
		for j = 0, WAR.PersonNum - 1 do
			if PersonKF(WAR.Person[j]["������"], 82) and WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[enemyid]["�ҷ�"] then
				jgfmq = jgfmq + 1
			end
		end
		--����3��
		if jgfmq > 3 then
			jgfmq = 3
		end
		if jgfmq == 3 then
			effstr = "��."..effstr
		end
		if jgfmq > 1 then
			dng = dng + 500 * (jgfmq-1)
			Set_Eff_Text(enemyid, "��Ч����3", effstr)
		end
	end
	
	--�����߹�
	if WAR.ZDDH==189  and  (eid >= 130 and eid <= 136)  then
		local JLQX = 0
		local effstr = "ͬ������"
		for j = 0, WAR.PersonNum - 1 do
			 if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[enemyid]["�ҷ�"] then
				JLQX = JLQX + 1
			end
		end
		if JLQX > 1 then
			dng = dng + 400 * (JLQX-1)
			Set_Eff_Text(enemyid, "��Ч����1", effstr)
		end
	end	
	
	--������
	if WAR.PD['������'][eid] == 1 then
		dng = 1000
	end
	

---------------------------------------------------------------------------
-----------------------------�����˺�����----------------------------------
---------------------------------------------------------------------------

	--��ת����
	--50%���ʷ�����Ľ�ݸ���Ľ�ݲ��ط���
    if PersonKF(eid, 43) and MyFj(WAR.CurID) == false and JY.Person[eid]["����"] > 10 and WAR.DZXY ~= 1 and WAR.Person[enemyid]["�����书"] == -1 and WAR.Person[enemyid]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
		--local gl = 0
        local gl = (JY.Person[eid]['����']-30)
        --gl = 25 + math.ceil(zz/2)
		if WAR.LQZ[eid] == 100 then
			gl = gl + 20
		end		

        if match_ID(eid, 51) or match_ID(eid, 113) then 
            gl = 100
        end

        if fjpd(WAR.CurID) == false and JLSD(0,gl,eid) then
			local dzlv = Xishu_sum(eid)
			local dzwz = nil
			--����ֵ֮�ʹ��ڵ���360����ϲ���
			--Ľ�ݸ���Ľ�ݲ�����س�
			if dzlv >= 360 or match_ID(eid, 51) or match_ID(eid, 113) or (eid == 0 and JY.Base["��׼"] == 6) then
				local hm = 0
				--����ֵ֮�ͳ���520���м��ʳ������ǳ�����
				--����Ϊ����ֵ֮��-520������50%����
				if dzlv > 520 then
					local chance = limitX(dzlv-520, 0, 50)
					if JLSD(0, chance, eid) then
						hm = 1
					end
				end
				--Ľ�ݸ�ָ��س�����
				if WAR.TZ_MRF == 1 then
					hm = 1
				end
				if hm == 1 then
					dzwz = "�����ǳ�"
					WAR.DZXYLV[eid] = 4
				else
					dzwz = "��ϲ���"
					WAR.DZXYLV[eid] = 3
				end
			--����ֵ֮�ʹ��ڵ���240����ת����
			elseif dzlv >= 240 then
				dzwz = "��ת����"
				WAR.DZXYLV[eid] = 2
			--�������㣬���Ǳ����Ƴ�
			else
				dzwz = "�����Ƴ�"
				WAR.DZXYLV[eid] = 1
			end
			Set_Eff_Text(enemyid, "��Ч����2", dzwz)
			if WAR.Person[enemyid]["��Ч����"] == -1 then
				WAR.Person[enemyid]["��Ч����"] = 93
			end
			WAR.Person[enemyid]["�����书"] = wugong
		end
    end
  
	--�޾Ʋ������˺���ʽ�����￪ʼ�������ܵ����˺�
	
	--���ط�Ϊ���ʱ�������˺�һ = 30 + (�������� + ��������/50)/1.5 + �书����/2.5
	--if inteam(eid) then
	--	hurt =  30 + (JY.Person[pid]["������"] + getnl(pid)/50)/1.5 + true_WL/2.5
		
	--���ط�ΪNPCʱ�������˺�һ = (�������� + ��������/50 + �书����)/3
	--else
	--	hurt = (JY.Person[pid]["������"] + getnl(pid)/50 + true_WL)/3
	--end
	
--	hurt =  30 + (atk + getnl(pid)/50)/1.5 + true_WL/2.5
	



	--�˺�һ = �˺�һ + װ������ * װ���ӳ�ϵ��
	--NPC��װ�������ȼ�

	
	--����������/50�ӳɵ�������������
	--atk = atk + getnl(pid) / 50	
	  
	--����������/20���ӳɵ�������������
	--�������䳣���ӳɵ�������������
	--atk = atk + mywuxue + ang / 100
	
	--�ط�������/40���ӳɵ��ط���������
	--�ط����䳣���ӳɵ��ط���������
	--def = def + getnl(eid) / 40 + emenywuxue
	

	
	--hurt =  30 + (Atk[WAR.CurID] + getnl(pid)/50)/1.5 + true_WL/2.5
	
	--�˺�һ = �����˺�һ * ������������/(������������ + �ط���������)
	--hurt = (hurt) * (atk) / (atk + def)

 	--�����˺�һ = �����˺�һ + (�����䳣 - �ط��䳣)/2
	--hurt = hurt + (mywuxue - emenywuxue) / 2 

	--�˺�һ = �˺�һ - �ط���������/5
	--hurt = hurt - (def) / 5
	
	--�˺�һ = �˺�һ + (�������� - �ط�����)/5 - ����/50 - (�������� - �ط�����)/3 - (�����ж� - �ط��ж�)/2
	--hurt = hurt + JY.Person[pid]["����"] / 5   - (dng) / 50- JY.Person[eid]["����"] / 5 + JY.Person[eid]["���˳̶�"] / 3 - JY.Person[pid]["���˳̶�"] / 3 + JY.Person[eid]["�ж��̶�"] / 2 - JY.Person[pid]["�ж��̶�"] / 2
	
---------------------------------------------------------------------------
--///////////////////////////�����˺�////////////////////////////////////
---------------------------------------------------------------------------

	--������Ϊ�ҷ����˺��� = INT(������������/7 + ���1~5) + INT(�书����/15)
	--if inteam(pid) then
	--	hurt2 = math.modf(math.random(30) + (atk) / 7) + math.modf(true_WL / 15)
	--������ΪNPC���˺��� = INT(������������/6 + ���1~20) + INT(�书����/13)
	--else
	--	hurt2 = math.modf(math.random(30) + (atk) / 7) + math.modf(true_WL / 13)
	--end
	--������ΪNPC���˺��� = �˺��� * 1.2
	--if not inteam(pid) then
		--hurt2 = math.modf(hurt2 * 1.2)
	--end
	
	--����˺�һС���˺�����������˺�����������
	--if hurt < hurt2 then
	--	hurt = hurt2
	--end
		
	if wgtype == 6 then
		--̫�������ֶ�ѡ��ϵ��
		if wugong == 102 and WAR.TXZS > 0 then
			WAR.NGXS = WAR.TXZS
		else
			WAR.NGXS = math.random(5)
		end
		wgtype = WAR.NGXS
	end	
	--�������κ��书�����㽣ϵ
	if match_ID(pid, 140)  then
		wgtype = 3
	end
	--������ܱ��κ��书�����㽣ϵ
	if match_ID(eid, 592)  then
		wgtype = 3
	end	
	--�����ﱻ�κ��书�����㽣ϵ
	if match_ID(eid, 140)  then
		wgtype = 3
	end
	
	--½�� ���κ��书������ȭϵ
	if match_ID(eid, 497) then
		wgtype = 1
	end
	
	--½�� �κ��书������ȭϵ
	if match_ID(pid, 497) then
		wgtype = 1				
	end
	if wugong == 93 then
		wgtype = 5
	end		
	--��ع���
	if match_ID(pid,9988) then
   		wgtype = 1				
	end	
	if wgtype == 1 and wugong ~= 109 then
		wxs = TrueQZ(pid)
		dxs = TrueQZ(eid)
		--�޾Ʋ�������ȭ��������ȡȭָ�ϸ��߼������
		if dxs < TrueZF(eid) then
			dxs = TrueZF(eid)
			end
		--½����֮����������ˮ���з�ȭ��ϵ����0��
		if WAR.HZD_1 == 1 then
			dxs = 0
		end	

     --½����֮�������ɰٴ����з�ȭ��ϵ����0��
		if WAR.HZD_1 == 2 then
			wxs = 0
		end
	elseif wgtype == 2 or wugong == 109 then
		wxs = TrueZF(pid)
		dxs = TrueZF(eid)
		--�޾Ʋ�������ָ��������ȡȭָ�ϸ��߼������
		if dxs < TrueQZ(eid) then
			dxs = TrueQZ(eid)
		end
		--�����������̺ᣬ�з�ָ��ϵ����50%��
		if WAR.JQBYH == 1 then
			dxs = dxs / 2
		end
	elseif wgtype == 3 then
		wxs = TrueYJ(pid)
		dxs = TrueYJ(eid)
		if WAR.PD["��������"][pid] ~= nil then
			wxs = wxs + TrueSD(pid)
        end	
		--������ܣ��з�����ϵ����1/3����
		if WAR.WWWJ == 1  then
			dxs = dxs/3			
		end		
		--������Ԫ�������з�����ϵ����0��
		if WAR.TYJQ == 1  then
			dxs = 0
		end
		
		--��Գ��
        if match_ID(pid,9997) then
			dxs = dxs/2
		end		
		
		if WAR.XMJDHS == 1	then  
			dxs = dxs/2
		end	
		
		--�޾Ʋ�����NPC������Ч��Ϊ2��
		--��������.����
		if match_ID(eid, 500)  then
			WAR.Person[enemyid]["��Ч����"] = 95
			if WAR.Person[enemyid]["��Ч����2"] ~= nil then
				WAR.Person[enemyid]["��Ч����2"] = WAR.Person[enemyid]["��Ч����2"].."+������"
			else
				WAR.Person[enemyid]["��Ч����2"] = "������"
			end
			wxs = wxs/2
		end	
				
		if WAR.JTYJ[pid] ~= nil  then
			dxs = dxs*0.7
		end		

	elseif wgtype == 4 then
		wxs= TrueSD(pid)
		if WAR.PD["��������"][pid] ~= nil then
			wxs = wxs + TrueSD(pid)
        end	
		dxs = TrueSD(eid)
	elseif wgtype == 5 then
		wxs = TrueTS(pid)
		dxs = TrueTS(eid)
	end	
		

   -- local dnc_max = 0

	
	w = {g = Atk(WAR.CurID),f = Def(WAR.CurID), q = Qg(WAR.CurID), wc = mywuxue, xs = wxs ,wl = true_WL}

	d = {g = Atk(enemyid),f = Def(enemyid), q = Qg(enemyid),  wc = emenywuxue, xs = dxs ,wl = 0}
	
	wwc = w.wc - d.wc 

	wsc = w.xs - d.xs

	dnc = -wnc

	dwc = -wwc

	dsc = -wsc

	--����������
	if wnc < 0 then 
		wnc = 1
	else 
        wnc = wnc/9999
	end
    --�����䳣��
	if wwc < 0 then 	
		wwc = 1
	else 
		local wwc_max = 0
		wwc_max = math.sqrt(wwc)*0.02
		if wwc_max > 1 then
			wwc_max = 1
		end
		wwc = wwc_max + 1
	end
    --����ϵ����
	if wsc < 0 then 	
		wsc = 1
	else 
		local wsc_max = 0
		wsc_max = wsc/420
		if wsc_max > 1 then
			wsc_max = 1
		end
		wsc =wsc_max + 1
	end
    --�ط�������
	if dnc < 0 then 
		dnc = 1
	else 
		dnc = dnc/9999 + 1
	end
    --�ط��䳣
	if dwc < 0 then 		
		dwc = 1
	else 
		local dwc_max = 0
		dwc_max =  math.sqrt(dwc)*0.02
		if dwc_max > 1 then
			dwc_max = 1
		end
		dwc = dwc_max + 1
	end
    --�ط�ϵ��
	if dsc < 0 then 		
		dsc = 1
	else 
		local dsc_max = 0	
		dsc_max = dsc/420
		if dsc_max > 1 then
			dsc_max = 1
		end
		dsc = dsc_max + 1
	end

	--����У�ϵ����������
	if WAR.JSTG == 1 and wsc < dsc then
		dsc = 1
		Set_Eff_Text(enemyid, "��Ч����2","��ǿ��ǿ")
	end
	
	--С���๦��ϵ����������
	if Curr_NG(pid, 98) and wsc < dsc and WAR.HZD_1~= 1  then
		dsc = 1
		Set_Eff_Text(enemyid, "��Ч����2","��������")
	end
	
	if Curr_NG(eid, 98) and wsc > dsc and WAR.TYJQ ~= 1 and WAR.HZD_2~= 1 and WAR.XMJDHS ~= 1 and WAR.WWWJ ~= 1 then
		wsc = 1
		if Curr_NG(pid, 98) == false then
			Set_Eff_Text(enemyid, "��Ч����2","��������") 
		end
	end
	--ɨ��ϵ����������
	if match_ID(pid,114) and wsc < dsc then
		dsc = 1
	end

	if match_ID(eid,114) and wsc > dsc then
		wsc = 1
	end
	--����ϵ����������
	if match_ID(pid,574) and wsc < dsc then
		dsc = 1
	end	
	if match_ID(eid,574) and wsc > dsc then
		wsc = 1
	end	
	--÷����ϵ����������
	if match_ID(pid,9969)  and wsc < dsc then
		dsc = 1
	end	
	if match_ID(eid,9969)  and wsc > dsc then
		wsc = 1
	end
	--��ף�ϵ����������
	if match_ID(pid, 636)  and wsc < dsc then
		dsc = 1
		Set_Eff_Text(enemyid, "��Ч����2","���ɹ���") 
		end
	
	if match_ID(eid, 636)  and wsc > dsc then
		wsc = 1
		Set_Eff_Text(enemyid, "��Ч����2","���ɹ���") 
		end
	--��Ѱ����������ϵ����������
	if match_ID(eid, 498) and wsc > dsc then
		wsc = 1
		Set_Eff_Text(enemyid, "��Ч����2","���ž���")
	end	

	atk = w.g*wwc*wsc--*wgc

	def = d.f*dwc*dsc--*dgc
	
    --������ �޷�����
	if match_ID(pid,584) and WAR.BJYPYZ > 0 and JLSD(20,70+WAR.BJYPYZ,pid) then
		def = math.modf(def * (1-WAR.BJYPYZ*0.03))
	end
	--��������Ʒ�
	if match_ID(pid,574) and JLSD(20,70,pid) then
		def = math.modf(def * 0.7)
	end
    
    if WAR.PD['�����������л�'][pid] == 1 then 
        def = math.modf(def * 0.7)
    end
    
    if WAR.PD['���־�'][pid] == 1 then 
        def = math.modf(def * 0.7)
    end
    
	--�������� ��
	if WAR.PD["��"][pid] ~= nil and WAR.PD["��"][pid] == 1 then
		def = math.modf(def * 0.7)
	end
	--��ħ�����ӵз�40%����
	if Curr_NG(pid, 160) then
		def = math.modf(def * 0.7)
	elseif PersonKF(pid,160) then 
		def = math.modf(def * 0.9)
	end
	--���� �з�ÿ������ֵ�Ʒ�1%
	if match_ID(pid,508) then
		local pf = JY.Person[eid]["���ճ̶�"]/100
		def = math.modf(def*(1-pf))
    end	
	--�廨�� �Ʒ�
	if JY.Person[pid]["����"] == 349 then
		local dj = JY.Thing[349]["װ���ȼ�"]
		if pid == 27 then
			dj = 6
		end
		local xhzpf = 1 - dj/20
		def = math.modf(def * xhzpf)
    end
	
	--��հ��� ������
	if WAR.PD["��հ���"][pid] ~=nil and WAR.PD["��հ���"][pid] == 1 then
        def = math.modf(def * 0.7)
		--WAR.PD["��հ���"][pid] = nil
    end  	
	
	-- �������  JY.Wugong[wugong]["�书����"]
	if match_ID(pid,9989) and (JY.Wugong[wugong]["�书����"] == 1 or JY.Wugong[wugong]["�书����"] == 2) then
		def = math.modf(def * 0.7)
    end	
	
	--��������1
	if  WAR.DSP_LM1 == 1	then
	    def = math.modf(def * 0.7)
	end	
	
 	--��Ϣ�� �ݿ���
    if WAR.BHJTZ6 == 1 then
		def = math.modf(def * 0.7)
    end	    
	
	--��ħ���� �켫��Ԩ
	if WAR.JMZL == 1  then
		def = math.modf(def * 0.7)
	end
	
	--�¼����Ҷ���ţ
	if match_ID(pid,75) and WAR.PDJN == 1 then
		def = math.modf(def * 0.7)
	end	
	
	--����ˮ ���ӵз�����50% ����һ��
	if (JY.Person[pid]["�������"] > 0 or isteam(pid) == false) and WAR.JTYJ[pid] ~= nil then
		def = math.modf(def * 0.7)
	end		
	
	--�������ߣ���������*1.5
	--if pid == 608 then
		--atk = atk * 1.5
	--end
	
    if WAR.PD['Ұ��ȭ'][pid] == 1 then 
        atk = atk * 1.4
        def = math.modf(def * 0.7)
    end
    
	--�������ߣ���������*1.5
	--if eid == 608 then
	--	def = def * 1.5
	--end
 	--̫���������ӷ���
	if Curr_NG(eid,171) and WAR.PD["̫������"][eid]~= nil  then
		def = def + WAR.PD["̫������"][eid]/20
	end   	
	
	if match_ID(pid,9977) and WGLX == 3 then 
		local n = 0
		for j = 1, JY.Base["�书����"] do
			if JY.Person[pid]['�书'..j] > 0 and JY.Person[pid]['�书�ȼ�'..j] >= 999 then 
				local kf = JY.Person[pid]['�书'..j]
				if JY.Wugong[kf]['�书����'] == 3 then 
					n = n + 1
				end
			end
		end
		if isteam(pid) == false then 
			n = 10
		end
		def = def*(0.9-n*0.02)
	end
	

	hurt = (w.wl+w.g/2)^0.8*atk/def/2
	hurt3 = hurt
	--say('���Լ����˺���'..hurt,1)
---------------------------------------------------------------------------
-----------------------------�˺��ӳɼ���----------------------------------
---------------------------------------------------------------------------

---------------------------------------------------------------------------
--///////////////////////////�˳�������////////////////////////////////////
---------------------------------------------------------------------------
if hurt > 0 then
	local zjh = 0
	local hm = 1
	local hx = 0


	--�����˺��ݼ�
	--�뽣ʽ ������ �������̺᲻�ݼ�
	if match_ID(pid, 652) and JY.Base["��������"] > 5 then
		local offset = math.abs(WAR.Person[WAR.CurID]["����X"] - WAR.Person[enemyid]["����X"]) + math.abs(WAR.Person[WAR.CurID]["����Y"] - WAR.Person[enemyid]["����Y"])
		if offset > 11 then
			offset = 11
		end
		hurt = (hurt) * (100 + (offset - 1) * 6) / 100
	elseif WAR.YLTW == 1 then
		local offset = math.abs(WAR.Person[WAR.CurID]["����X"] - WAR.Person[enemyid]["����X"]) + math.abs(WAR.Person[WAR.CurID]["����Y"] - WAR.Person[enemyid]["����Y"])
		if offset > 11then
			offset = 11
		end
		hurt = (hurt) * (100 + (offset - 1) * 6) / 100
	elseif isteam(pid) == false then 
	elseif Curr_QG(pid,149) == false then
	elseif WAR.JQBYH ~= 1 then 
	elseif WAR.JJZC ~= 1 then
	else 
	--if isteam(pid) or WAR.JJZC ~= 1 or Curr_QG(pid,149) == false or WAR.JQBYH ~= 1 then
		local offset = math.abs(WAR.Person[WAR.CurID]["����X"] - WAR.Person[enemyid]["����X"]) + math.abs(WAR.Person[WAR.CurID]["����Y"] - WAR.Person[enemyid]["����Y"])
		if offset > 11 then
			offset = 11
		end
		hurt = (hurt) * (100 - (offset - 1) * 3) / 100
		--hurtsh = hurtsh + (100 - (offset - 1) * 3) / 100 -1
	end

	--('���Լ����˺�1��'..hurt,1)

	--����
	if WAR.BJ == 1 then
	    local bjsh =1.25
		local SLWX = 0
		for i = 1, CC.Kungfunum do
			if JY.Person[eid]["�书" .. i] == 106 or JY.Person[eid]["�书" .. i] == 107  then
				SLWX = SLWX + 1
			end
		end
		--�Ĵ����
		if match_ID(pid, 44) or match_ID(pid, 98) or match_ID(pid, 99) or match_ID(pid, 100)then
			bjsh = 1.5
		end
		--��������
		if WAR.DSP_LM3== 1 then
			bjsh = 1.5	
		end
		--Ԭ��־
		if match_ID(pid, 54) and inteam(pid) then 
			bjsh = bjsh + 0.05 * JY.Base["��������"]
			if bjsh > 1.5 then
				bjsh = 1.5 
			end
		end
		--����
		if  match_ID(pid, 578) then
			bjsh = bjsh + 0.1
		end
		--����
		if Curr_NG(pid,104) then
			bjsh = bjsh + 0.2
		elseif PersonKF(pid, 104) then
			bjsh = bjsh + 0.1
		end
		--���㹦
		if Curr_QG(pid,223) then
			bjsh = bjsh + 0.1
		end	
		--����
		if Curr_NG(eid,104) then
			bjsh = bjsh - 0.15
		end	
		--����
		if Curr_NG(eid,107) and PersonKF(eid,104)then 
			bjsh = bjsh - 0.2
		end
		--����
		if match_ID(eid, 637) then
			bjsh = 1
		end
        --�����
	    if match_ID(eid,9986) and WAR.FUHUOZT[eid] ~= nil and WAR.BJ == 1 and hurt > 0 then
		   bjsh = 1
		   dng = dng + 1200
		   Set_Eff_Text(enemyid, "��Ч����1", "�����")
	    end			
		--ɭ������
		if SLWX == 2  then
			WAR.Person[enemyid]["��Ч����"] = 6
			Set_Eff_Text(enemyid, "��Ч����2", "ɭ������")
			--���߻���֮һ���Ķ���ɱ��
		    if WAR.HXZYJ == 1 then
				dng = dng + 1200
			end
			bjsh = 1
		end
		--hurtsh = hurtsh + bjsh - 1
		hurt = hurt * bjsh
	end	


    if Cat('����',enemyid) and hurt > 0 and WAR.Weakspot[eid] ~= nil then 
        local num = 3
        if match_ID(pid,635) and (JY.Person[pid]["�������"] > 0 or isteam(pid) == false) then 
            num = 6   
        end
        
        local pz_str = "��������";
        
        if WAR.Weakspot[eid] < num then 
            hurt = math.modf(hurt * 1.25)
            ang = math.modf(ang * 1.25)
            if WAR.Weakspot[eid] == 1 then
                pz_str = "��������";
            elseif WAR.Weakspot[eid] == 2 then
                pz_str = "��������";
            elseif WAR.Weakspot[eid] == 3 then
                pz_str = "��������";
            elseif WAR.Weakspot[eid] == 4 then
                pz_str = "��������";
            elseif WAR.Weakspot[eid] == 5 then
                pz_str = "½������";				
            end
            WAR.Weakspot[eid] = WAR.Weakspot[eid] + 1
            if WAR.Person[enemyid]["��Ч����0"] ~= nil then
                WAR.Person[enemyid]["��Ч����0"] = pz_str.."+"..WAR.Person[enemyid]["��Ч����0"]
            else
                WAR.Person[enemyid]["��Ч����0"] = pz_str
            end
            if WAR.Person[enemyid]["��Ч����"] == nil or WAR.Person[enemyid]["��Ч����"] == -1 then
                WAR.Person[enemyid]["��Ч����"] = 63
            end
        end    
    end    

------------------------------------------------------------
--------------------������Ч--------------------------------
------------------------------------------------------------
	
--------------------�츳������Ч----------------------------

	--����ÿ5���ж��̶�����1%
	if pid == 0 and JY.Base["��׼"] == 9 then		
		local dw = JY.Person[pid]["�ж��̶�"]/500
		zjh = zjh + (hm-zjh)*dw
	end

	--��Ӣ����Ѫ���£�����ʱ�˺�һ*120%
	if match_ID(pid, 63) and JY.Person[pid]["����"] < math.modf(JY.Person[pid]["�������ֵ"] / 2) then
		zjh = zjh + (hm-zjh)*0.2
	end
	--��Ħ���˺��������1.5��
	if match_ID(pid, 159) then
		--hurt = math.modf(hurt * 1.5)
		zjh = zjh + (hm-zjh)*0.5
	end
	--brolycjw��������������ʱ�˺�һ*120%
	if match_ID(pid, 39) then
		zjh = zjh + (hm-zjh)*0.2
	end

	--����ͣ�����ս������Ŀ�꣬�˺�һ+50%
	if match_ID(pid, 160) and WAR.SZSD == eid then
		--hurt = math.modf(hurt * 1.5)
		zjh = zjh + (hm-zjh)*0.5
	end


	--����ˣ�����ʱ�˺�һ*110%
	if match_ID(pid, 25) then
		zjh = zjh + (hm-zjh)*0.1
	end
 
	--�ܲ�ͨ��ÿ�ж�һ�Σ�����ʱ�˺�һ+10%
	if match_ID(pid, 64) then
		local ztb = WAR.ZBT / 10
		if ztb > 0.4 then
			ztb = 0.4
		end
		zjh = zjh + (hm-zjh)*ztb
	end
	
 	--�����ÿ�ж�һ�Σ�����ʱ�˺�һ+5%
	if WAR.PD["�����"][pid] ~=nil and WAR.PD["�����"][pid] > 0 then
		--hurtsh = hurtsh + WAR.PD["�����"][pid]/20
		zjh = zjh + (hm-zjh)*WAR.PD["�����"][pid]/20
	end  
    
	--ȭϵ���У�����ʱ�˺�һ*133.3%
	if WAR.LXZQ == 1 then
		--hurt = math.modf(hurt * 1.333)
		--hurtsh = hurtsh +0.333
		zjh = zjh + (hm-zjh)*0.333
	end
	--ʥ����ʹ �˺����
	if WAR.ZDDH == 14 and (pid == 173 or pid == 174 or pid == 175) then
		local shz = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[WAR.CurID]["�ҷ�"] then
			shz = shz + 1
			end
		end
		if shz == 3 then			
			--hurtsh = hurtsh +0.5
			zjh = zjh + (hm-zjh)*0.5
		end
	end	
	--ȫ�����ӣ�������������˺�������
	if WAR.ZDDH == 73 then
		if (pid >= 123 and pid <= 128) or pid == 68 then
			--hurt = math.modf(hurt * (1+0.30))
			--hurtsh = hurtsh + 0.3
			zjh = zjh + (hm-zjh)*0.3
		end
	end		
	--������ һ��Ů��+5%�˺�һ
	if match_ID(pid, 82) then
		local s = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[WAR.CurID]["�ҷ�"] and JY.Person[WAR.Person[j]["������"]]["�Ա�"] == 1 then
				s = s + 1
			end
		end
		--hurt = math.modf(hurt * (1 + s*0.05))
		--hurtsh = hurtsh + s*0.05
		zjh = zjh + (hm-zjh)*s*0.05
	end
	
	--��� һ���е�+5%�˺�һ
	if match_ID(pid, 154) then
		local s = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[WAR.CurID]["�ҷ�"] and JY.Person[WAR.Person[j]["������"]]["�Ա�"] == 0 then
				s = s + 1
			end
		end
		--hurt = math.modf(hurt * (1 + s*0.05))
		-- hurtsh = hurtsh + s*0.05
		 zjh = zjh + (hm-zjh)*s*0.05
	end
  
	--����ɺ ÿ����������˺�һ5%
	if match_ID(pid, 79) or match_ID(pid,9996) then
		local JF = 0
		for i = 1, CC.Kungfunum do
			if JY.Wugong[JY.Person[pid]["�书" .. i]]["�书����"] == 3 then
				JF = JF + 1
			end
		end
        if JF > 7 then 
            JF = 7
        end
		--hurtsh = hurtsh + JF*0.05
		zjh = zjh + (hm-zjh)*JF*0.05
		--hurt = math.modf(hurt * (1 + JF*0.05))
	end
	--����ȭϵ��ÿ��ȭ����������������ɵ�5%�˺�
	if JY.Base["��׼"] == 1 and pid == 0 then
		local lxzq = 0
		for i = 1, CC.Kungfunum do
			if JY.Wugong[JY.Person[0]["�书" .. i]]["�书����"] == 1 and JY.Person[0]["�书�ȼ�" .. i] == 999 then
				lxzq = lxzq + 1
			end
		end
		if lxzq > 7 then
			lxzq = 7
		end
		--hurt = math.modf(hurt * (1 + 0.05 * lxzq))
		--hurtsh = hurtsh + 0.05 * lxzq
		zjh = zjh + (hm-zjh)*0.05 * lxzq
	end	
	--�������ʯ���״̬
	if WAR.YSJF[pid] ~= nil then
		--hurt = math.modf(hurt * 1.5)
		--hurtsh = hurtsh + 0.5
		zjh = zjh + (hm-zjh)*0.5
	end
	
	--��������ɳ����Ѫ��Խ���˺�Խ�ߣ�100%Ѫ�޼ӳɣ�0Ѫ100%�ӳ�
	if match_ID(pid, 47) and WAR.JYZT[pid]~=nil then
		local bonus_perctge = 0
		bonus_perctge = 2 - JY.Person[pid]["����"] / JY.Person[pid]["�������ֵ"]
		--hurt = math.modf(hurt * bonus_perctge)
		--hurtsh = hurtsh + bonus_perctge - 1
		zjh = zjh + (hm-zjh)*(bonus_perctge - 1)
	end
	--�����Ľ���ʮ���ƣ����಻��
	if WAR.YYBJ > 9 then
		--hurt = math.modf(hurt*(1+0.08*WAR.YYBJ));
		--hurtsh = hurtsh + 0.04*WAR.YYBJ
		zjh = zjh + (hm-zjh)*0.04*WAR.YYBJ
	end	
	--�Ž��洫���ý�ʽ�˺�+30%
	if WAR.JJZC == 3 then
		--hurt = math.modf(hurt*1.3);
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end	
	--������
	if WAR.BJYPYZ > 0 then
		--hurt = math.modf(hurt*(1+0.08*WAR.BJYPYZ));
		--hurtsh = 0.04*WAR.BJYPYZ
		zjh = zjh + (hm-zjh)*0.04*BJYPYZ
	end	
	--��̩����100%Ѫ�޼ӳɣ�1Ѫ50%�ӳ�
	if match_ID(pid, 151) then
		local HZDBJ = 0
		HZDBJ = 1- JY.Person[pid]["����"] / JY.Person[pid]["�������ֵ"]
		--hurt = hurt +math.modf(HZDBJ)
        if HZDBJ > 0.5 then 
            HZDBJ = 0.5    
        end
		--hurtsh = hurtsh + HZDBJ
		zjh = zjh + (hm-zjh)*0.04* HZDBJ
	end		
    --�Ϲٽ���ѪԽ���˺�Խ��
	if match_ID(pid, 567) and JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 4 then
		--hurt = math.modf(hurt*2)
		--hurtsh = hurtsh + 0.5
		zjh = zjh + (hm-zjh)*0.5
       end
    if match_ID(pid, 567) and JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 2 then
		--hurt =  math.modf(hurt*1.5)
		--hurtsh = hurtsh + 0.25
		zjh = zjh + (hm-zjh)*0.25
    end	
    --���� �ƶ��б�	
	if WAR.SEYB == 1 and JY.Person[pid]["Ʒ��"] >= 120 and DWPD() then
		if JLSD(0,(JY.Person[pid]["Ʒ��"]-40),pid) then
			--hurt = math.modf(hurt*1.5)
			hurtsh = hurtsh + 0.3 
        elseif JLSD(0,(JY.Person[pid]["Ʒ��"]-100),pid) then
			--hurt = math.modf(hurt*0.5) 
		  -- hurtsh = hurtsh - 0.3 
		   zjh = zjh + (hm-zjh)*(- 0.3 )     	   
		end	 
	end	
	
     --��������
	if match_ID(pid,9980) then
		--hurt = math.modf(hurt*math.random(75,125)/100)
		hurtsh = hurtsh + math.random(75,125)/100 - 1
		zjh = zjh + (hm-zjh)*(math.random(75,125)/100 - 1)
	end	
	--�����Ӷ����Թ�������20%
	if match_ID(pid, 116) and JY.Person[eid]["�Ա�"] == 0 then
		--hurt = math.modf(hurt*1.2);
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end
	--��Ī�����������10%
	if match_ID(pid, 161) and JY.Person[eid]["�Ա�"] == 0 then
		--hurt = math.modf(hurt*1.1);
		--hurtsh = hurtsh + 0.1
		zjh = zjh + (hm-zjh)*0.1
	end	
	
	--�¼����Ů�Թ����˺�*50%
	if match_ID(pid, 75) and JY.Person[eid]["�Ա�"] == 1 then
		--hurt = math.modf(hurt*0.5);
		--hurtsh = hurtsh - 0.3
		zjh = zjh + (hm-zjh)*(-0.3)
	end
	
	--����У��˺�����30%
	if WAR.JSTG == 1 then
		--hurt = math.modf(hurt*1.3)
		--hurtsh = hurtsh + 0.3
		zjh = zjh + (hm-zjh)*0.3
	end
	--������1 һ�������壬�˺�����20%��	
	if match_ID(pid,129)  and WAR.YQFSQ == 1 then
		--hurt = math.modf(hurt*1.2)	
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end
	--�������Ŷݼף���ɫ����
	if WAR.Person[WAR.CurID]["�ҷ�"] == true and GetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"],6) == 2 then
		--hurt = math.modf(hurt*1.2)
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end	
	--�������У��˺�����30%	
	if WAR.YTML == 1 then
		--hurt = math.modf(hurt*1.3)
		--hurtsh= hurtsh + 0.3
		zjh = zjh + (hm-zjh)*0.3
	end		
  	--����
	if JY.Base["��׼"] == 7 and JY.Person[pid]["Ʒ��"] > 100 then
	   --hurt =  math.modf(hurt*(JY.Person[pid]["Ʒ��"]/100))
	   --hurtsh = hurtsh + JY.Person[pid]["Ʒ��"]/100 - 1
	   zjh = zjh + (hm-zjh)*(JY.Person[pid]["Ʒ��"]/100 - 1)
    end	
	--����
    if match_ID(pid,574) then 
		local n = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
				n = n + 1
				if n > 6 then
					n = 6
					break
				end	
			end
		end
	    --hurt =math.modf(hurt*(1+n*0.1))
		--hurtsh = hurtsh + n*0.1
		zjh = zjh + (hm-zjh)*n*0.1
	end	

    
    if ZDGH(WAR.CurID,9991) then
		--hurt = math.modf(hurt * 1.2)
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
    end		

--------------------�书/���������Ч----------------------------

	--�������棬����ʱ�˺�һ*130%
	if WAR.DJGZ == 1 then
		--hurtsh = hurtsh + 0.3
		zjh = zjh + (hm-zjh)*0.3
	end
	--��������

    for i = 0, WAR.PersonNum - 1 do
		local zid = WAR.Person[i]["������"]
		if WAR.Person[i]["����"] == false and WAR.Person[i]["�ҷ�"] and PersonKF(zid, 199) then
			--hurtsh = hurtsh + 0.1	
			zjh = zjh + (hm-zjh)*0.1
			break
		end
	end
	
	--��ת�����˺���ɱ��������
	if WAR.DZXYLV[pid] ~= nil and WAR.DZXYLV[pid] > 10 then
		local dz = WAR.DZXYLV[pid] / 100 - 1
		--hurt = math.modf(hurt * WAR.DZXYLV[pid] / 100)
		--hurtsh = hurtsh + dz
		zjh = zjh + (hm-zjh)*dz
	end

	--�����߻�
	--�˺�һ�ӳ�
	if WAR.PD["�߻�״̬"][pid] == 1 then
		--hurt = math.modf(hurt * 1.1)
		--hurtsh = hurtsh + 0.1
		zjh = zjh + (hm-zjh)*0.1
	end

	--��Ӣ���ƣ�����һ����������ݵз�����������׷���˺�������+100%
	if wugong == 12 and TaohuaJJ(pid) then
		local mp_percentage = (JY.Person[eid]["�������ֵ"]-JY.Person[eid]["����"])/JY.Person[eid]["�������ֵ"]
		--hurt = math.modf(hurt * (1 + mp_percentage))
		--hurtsh =  hurtsh + mp_percentage
		zjh = zjh + (hm-zjh)*mp_percentage
	end

	--�޺���ħ�����˺���ɱ��Ч��Ϊ��[(��ǰ����ֵ/500)��(�书��������/140)]%
	if Curr_NG(pid, 96) or ((Curr_NG(pid, 108) or match_ID(pid,38)) and PersonKF(pid,96)) then
		local nlmod = JY.Person[pid]["����"]/30000
		local wgmod = JY.Wugong[wugong]["������������"]/2000
		local totalmod = nlmod + wgmod;
		--ʯ����Ч�����1.1��
		if match_ID(pid, 38)  or Curr_NG(pid, 108) then
			totalmod = totalmod * 1.1;
		end
		--hurt = math.modf(hurt * totalmod)
		--hurtsh = hurtsh + totalmod
		zjh = zjh + (hm-zjh)*totalmod
	end
 
	--�����������ڰ�Ѫ���µ����˺�*2
	if wugong == 32 and PersonKF(pid,175) and JY.Person[eid]["����"]<JY.Person[eid]["�������ֵ"]/2 then
		--hurt = hurt * 2
		--hurtsh = hurtsh + 0.5
		zjh = zjh + (hm-zjh)*0.5
	end
	
	--�����黭֮����������������20%
	if WAR.QQSH3 == 1 then
		--hurt = math.modf(hurt*1.2);
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end	
	--��������20%
	--�������˻������ѧ�������
	if Curr_NG(pid, 107) and (JY.Person[pid]["��������"] == 0 or JY.Person[pid]["��������"] == 3) then
		--hurt = math.modf(hurt*1.2);
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end
	--��������10%
	if Curr_NG(pid, 103) then
		--hurt = math.modf(hurt*1.1);
		--hurtsh = hurtsh + 0.1
		zjh = zjh + (hm-zjh)*0.1
	end
	
	--Ѫ���������10%
	if Curr_NG(pid, 163) then
		--hurt = math.modf(hurt*1.1);
		--hurtsh = hurtsh + 0.1
		zjh = zjh + (hm-zjh)*0.1
	end

--------------------״̬������Ч----------------------------

	  
	--��������
	if WAR.Actup[pid] ~= nil then
		--���˸�󡣬�˺�һ*150%
		if  Curr_NG(pid, 95)  then
			--hurt = math.modf(hurt * 1.5)
			--hurtsh = hurtsh + 0.5
			zjh = zjh + (hm-zjh)*0.5
		--��̬���˺�һ*125%
		else
			--hurt = math.modf(hurt * 1.25)
		  --hurtsh  =	hurtsh + 0.25
		  zjh = zjh + (hm-zjh)*0.25
	   end
    end
	--÷����
	if WAR.PD["÷����"][pid]~= nil and  WAR.PD["÷����"][pid] > 0  then
		--hurtsh = hurtsh - WAR.PD["÷����"][pid]
		zjh = zjh + (hm-zjh)*(- WAR.PD["÷����"][pid])
		WAR.PD["÷����"][pid] = nil
	end
	--����״̬���˺�����
	if WAR.XRZT[pid] ~= nil then
		--hurt = math.modf(hurt * 0.5)
		--hurtsh = hurtsh - 0.5
		zjh = zjh + (hm-zjh)*(-0.5)
	end
	--lib.Debug("��ǰ����25������״̬���˺���ɱ��������"..hurt)
	--����״̬1���˺�����
	if WAR.XRZT1[pid] ~= nil then
		--hurt = math.modf(hurt * 0.5)
		--hurtsh = hurtsh - 0.5
		zjh = zjh + (hm-zjh)*(-0.5)
	end
	--���������˺�����30%
	if WAR.PD["��������"][pid] ~= nil then
		zjh = zjh + (hm-zjh)*(-0.3)
	end		
	if WAR.PD["����"][pid] ~= nil then
		--hurtsh = hurtsh - 0.1
		zjh = zjh + (hm-zjh)*(-0.1)
	end
	--��������
	if WAR.MRSHZT[pid] ~= nil then
	   --hurt = math.modf(hurt * math.random(5,12)/10)
	   --hurtsh = hurtsh + (math.random(5,12)/10-1)
	   zjh = zjh + (hm-zjh)*(math.random(5,12)/10-1)
	end
 
	--����״̬���˺���ɱ��������
	if WAR.Focus[pid] ~= nil then
		--hurt = math.modf(hurt * 0.5)
		--hurtsh = hurtsh - 0.5
		zjh = zjh + (hm-zjh)*(-0.5)
	end


	--ŷ����  ս��171 �˺�����
	if pid == 60 and WAR.ZDDH == 171 then
		--hurtsh = hurtsh - 0.2
		zjh = zjh + (hm-zjh)*(-0.2)
	end
	
	--װ��ԧ�쵶��6���������˺����20%
	if JY.Person[pid]["����"] == 217 and wugong == 62 and JY.Thing[217]["װ���ȼ�"] == 6 then
		--hurt = math.modf(hurt*1.2);
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end	
	if JY.Person[pid]["����"] == 218 and wugong == 62 and JY.Thing[218]["װ���ȼ�"] == 6 then
		--hurt = math.modf(hurt*1.2);
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end
		
	--�۽���Ӯ������������20%
	if pid == 0 and JY.Person[129]["�۽�����"] == 1 then
		--hurt = math.modf(hurt*1.2)
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end
		
	--�����޼���
	if Curr_NG(pid, 221) then
		local nl = JY.Person[pid]['����']
		local n = limitX(1+nl/20000,0,1.5)
		--hurt = math.modf(hurt*n);
		--hurtsh = hurtsh + n -1
		zjh = zjh + (hm-zjh)*(n-1)
	end
--------------------����������Ч----------------------------
		--����
	if WAR.ZDDH == 344 and inteam(pid) == false then
		--hurt = math.modf(hurt * 1.3)
		--hurtsh = hurtsh + 0.3
		zjh = zjh + (hm-zjh)*0.3
    end	
		
    if WAR.HQT_ZL[pid]~= nil then 
		local n = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[WAR.CurID]["�ҷ�"]  then
			    n = n + 1
			end	
		end
		--hurt =math.modf(hurt*(1+n*0.05))
		--hurtsh = hurtsh + n*0.05
		zjh = zjh + (hm-zjh)*n*0.05
	end
	
    hurt = math.modf(hurt *  (1+zjh))
 end  


	--���������ÿ����+3%�˺����ط����ÿ����-3%�˺�
	--hurt =  math.modf(hurt * (1 + (calc_mas_num(pid) - calc_mas_num(eid))* 0.03))
	
	if not inteam(pid) then
		local nd = JY.Base['�Ѷ�']-1
	    hurt = math.modf(hurt*(1+ nd*0.08))
	end
	
---------------------------------------------------------------------------
--///////////////////////////�Ӽ�������������Ч////////////////////////////////////
---------------------------------------------------------------------------


	--�������ж�����ÿ5���ж��̶�����1%
	if pid == 0 and JY.Base["��׼"] == 9 then
		hurt = hurt + JY.Person[pid]["�ж��̶�"] / 2
	end
	
--	lib.Debug("��ǰ����41������ÿ5���ж��̶�����1%"..hurt)
	--�����壺ȼľ��������ͨ�ڹ��������������˺�
	if wugong == 65 and WAR.NGJL > 0 then
		hurt  = hurt + math.modf(JY.Wugong[WAR.NGJL]["������10"]/12);
	end
	
	if WAR.DFMQ == 1 then
		hurt = hurt + math.modf((JY.Person[eid]["�������ֵ"]*0.01)*math.random(2,4))
	end
	
	--ŷ������ݸ�����������˺�
	if match_ID(pid, 60) and WAR.OYFXL > 0 then
		hurt = hurt + WAR.OYFXL/2
	end
	
  	--�������������˺�
	if match_ID(pid, 635) and WAR.LXXL > 0 then
		hurt = hurt + WAR.LXXL/2
	end	
	
	--��ţ����
    if wugong == 193 and DWPD() then
	    if JY.Person[eid]["����"]/JY.Person[eid]["�������ֵ"] < 0.4 and JLSD(10,60,pid) then
			hurt = hurt + math.modf(JY.Person[eid]["�������ֵ"]*0.05)
		end
		WAR.Person[enemyid]["��Ч����"] = 116
		Set_Eff_Text(enemyid, "��Ч����3", "���������")
	end
	--����ɽ����
    if 	wugong == 24 and DWPD() then
	    if JY.Person[eid]["����"]/JY.Person[eid]["�������ֵ"] < 0.5 and JLSD(10,60,pid) then
			 WAR.PD["��������"][pid] = 1
			hurt = hurt + math.modf(JY.Person[eid]["�������ֵ"]*0.05)		   
	    end	 
	end
	--�����
	if WAR.PD["�����"][pid]~=nil and WAR.PD["�����"][pid] == 1 then
		local a1 = JY.Person[eid]["����"]/JY.Person[eid]["�������ֵ"]
		local nl = JY.Person[eid]["����"]/20
		if inteam(eid) then
		   hurt = hurt + math.modf(JY.Person[eid]["����"]*0.2)	
		else
		   hurt = hurt + math.modf(JY.Person[eid]["����"]*0.2)
		end	
        AddPersonAttrib(eid,"����",-nl)
		if a1 < 0.333 and JLSD(0,(1-a1)*20,pid) then
			if inteam(eid) then
				hurt = hurt + JY.Person[eid]["����"]
			else
				hurt = hurt + JY.Person[eid]["����"]
		    end
		end
    end	 
	--�����˺�
	if match_ID(pid,586) and JY.Base["��������"] > 0  then
		local YQ = 0
		YQ = YQ +JY.Base["��������"]*10
		hurt = hurt +YQ
	end	
	
	if WAR.LHQ_BNZ == 1 then		--������ �˺�+50
		hurt = hurt + 50
	end
	
	if WAR.JGZ_DMZ == 1 then		--��Ħ�� �˺�+100
		hurt = hurt + 100
	end
	
	if WAR.WD_CLSZ == 1 then		--�������� �˺�+70
		hurt = hurt + 70
	end
		
	--����׷���˺�
	if JY.Person[eid]["���ճ̶�"] > 25 then
		zshurt = zshurt + JY.Person[eid]["���ճ̶�"]*2
	elseif JY.Person[eid]["���ճ̶�"] > 0 then
		zshurt = zshurt + JY.Person[eid]["���ճ̶�"]	
	end	
	lib.Debug("��ǰ����42������׷���˺�"..hurt)
		--�����﹥�������ݵз��ж�׷���˺�
	if match_ID(pid, 46) and JY.Person[eid]["�ж��̶�"] > 0 then
		zshurt = zshurt + JY.Person[eid]["�ж��̶�"]
	end	
		-- ������������׷���˼��˺�
	if WAR.XC_WLCZ == 1 then
		zshurt = zshurt + JY.Person[eid]["���˳̶�"]*2
	end	
		--������ ܽ�ؽ���
	if match_ID(pid, 569) then
	    local fr = JY.Person[pid]["��������"]
		zshurt = zshurt + fr 
	end	
	--��������ʹ��ȭ������׷��100���˺�����δװ����������˼ӳɷ���
	if match_ID(pid, 186) and JY.Wugong[wugong]["�书����"] == 1 then
		hurt = hurt + 100
		if JY.Person[pid]["����"] == -1 then
			zshurt = zshurt + 100
		end
	end
	--��������
	if WAR.JYZJ_FXJ==1 then
		zshurt = zshurt + 100
		if Curr_NG(pid,107) then 
			zshurt = zshurt + 200
		end
	end	
	--��������
	if WAR.QLJG  == 1 then
		local h = JY.Person[pid]['��������']
		zshurt = zshurt + h
	end	

	--��Ѫ��צ
	if wugong == 134 and DWPD() and WAR.LXZT[eid]~=nil then
		zshurt = zshurt + WAR.LXZT[eid]
    end
    --�η���
    if match_ID(pid,615) and wugong ==62 then
       zshurt = zshurt + math.modf(JY.Person[pid]["�Ṧ"]/3)	
	end
    
	if match_ID(pid, 511) then 
		local fx = WAR.FXDS[eid] or 0
		local lx = WAR.LXZT[eid] or 0
		zshurt = zshurt + fx*2 + lx*2 + 100
	end
	--��̫��
	if WAR.WDKTJ == 1 then
        local s1 = 1-JY.Person[pid]["����"]/JY.Person[pid]["�������ֵ"]
		local s2 = JY.Person[pid]["����"]/JY.Person[pid]["�������ֵ"]		
        local s3 = JY.Person[pid]["����"]*0.04
		local s4 = s1+s2
		local s = math.modf(s3*s4) 
		zshurt = zshurt + s
		if WAR.ACT > 1 then
			zshurt = zshurt + s*0.7
		end	
	end	
    
	-- ����ħ
    if WAR.SZXM == 1 then
        if hurt < 100 then
            zshurt = zshurt + 100
        end   
	    if WAR.LQZ[pid] == 100 then
	        zshurt = zshurt + math.modf(ang/15)
	    else
			zshurt = zshurt + math.modf(ang/20)
	    end
    end

	--����ʮ��
	if WAR.SL23 == 1 then
		if hurt < 200 then
			zshurt = zshurt + 200
	    end	
    end	
	--����һ���˺� 
	if match_ID(pid, 652) and WAR.JTYJ[pid] ~= nil then
		zshurt = zshurt + 200	
	end
    
	--����
	if match_ID(pid, 582)  then
		local bxbf = JY.Person[eid]["����̶�"]
		zshurt = zshurt + bxbf*2
	end
	
    if WAR.PD['��������������'][pid] == 1 then 
        zshurt = zshurt + 200
    end
    
	hurt = hurt + zshurt

---------------------------------------------------------------------------
--///////////////////////////�˺����˼���////////////////////////////////////
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-----------------------------��������˺�-------------------------------------
---------------------------------------------------------------------------
	if WAR.Miss[eid] == 1 then 
		hurt = 0
	end
	
---------------------------------------------------------------------------
--///////////////////////////�˷�������////////////////////////////////////
---------------------------------------------------------------------------
---------------------------------------------------------------------------
--///////////////////////////�츳����////////////////////////////////////
---------------------------------------------------------------------------
if hurt > 30 then 
	local hurtjs = 0
	local jsm = 1

	--�������˺�����������
	if WAR.ACT > 1 then
		local LJ_fac = 0.7	--ͨ��Ϊ70%
		--�������ܲ����� ������
		--�����񽣣����޵���������
		--ز�ÿձ̲�����
		if match_ID(pid, 27) or wugong == 49 or wugong == 62 or WAR.YNXJ == 1 or match_ID(pid,5)  then
			LJ_fac = 1
		end	
		--�٤�ܳ˼��ٱ��������˺�������
		--���˼���40%
		--��������20%
		if Curr_NG(eid, 169)  then
			LJ_fac = LJ_fac - 0.4
		elseif PersonKF(eid, 169) then
			LJ_fac = LJ_fac - 0.2
		end
		hurt = math.modf(hurt * LJ_fac)
	end


	if not isteam(eid) then
		local nd = JY.Base['�Ѷ�']-1
		--hurt = math.modf(hurt*(1 - nd*0.05))
		--hurtjs = hurtjs + nd*0.05
		hurtjs =  hurtjs + (jsm-hurtjs)*nd*0.05
	end	


	--���������˺�
	if JY.Person[eid]["���˳̶�"] > 0 then
		local ns = - JY.Person[eid]["���˳̶�"] * 0.003
		hurtjs =  hurtjs + ns--(jsm-hurtjs)*ns
	end	


    if WAR.PD['���ϵ����е�'][pid] ~= nil then 
        if WAR.PD['���ϵ����е�'][pid][1] ~= nil then 
            local pf = WAR.PD['���ϵ����е�'][pid][1]
			local xg = - pf/100
			hurtjs =  hurtjs + xg--(jsm-hurtjs)*xg
        end
    end

	
	-- ����
	if match_ID(eid,583) then
		--hurt = math.modf(hurt *0.85)
		--hurtjs = hurtjs + 0.15
		hurtjs =  hurtjs + (jsm-hurtjs)*0.15
	end

	--brolycjw: ľ������������ʱ�˺�һ*80%
	if match_ID(eid, 40) then
		--hurt = math.modf(hurt * 0.8)
		--hurtjs = hurtjs + 0.2
		hurtjs =  hurtjs + (jsm-hurtjs)*0.2
	end	

	--����ÿ5���ж��̶ȼ���1%
	if eid == 0 and JY.Base["��׼"] == 9 then
		--hurt = math.modf(hurt * (1 - JY.Person[eid]["�ж��̶�"]/500))
		local ns = JY.Person[eid]["�ж��̶�"]/500
		hurtjs =  hurtjs + (jsm-hurtjs)*ns
	end	

	--лѷ��������ʱ�˺�һ*85%
	if match_ID(eid, 13) then
		--hurt = math.modf(hurt * 0.85)
		--hurtjs = hurtjs + 0.15
		hurtjs =  hurtjs + (jsm-hurtjs)*0.15
	end

	--�����ͻ���ͩ��Ϊ�ط�����ս��ʱ���˺�һ����10%
	for j = 0, WAR.PersonNum - 1 do
		if (match_ID(WAR.Person[j]["������"], 87) or match_ID(WAR.Person[j]["������"], 74)) and WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
			--hurt = math.modf(hurt * 0.9)
			--hurtjs = hurtjs + 0.1
			hurtjs =  hurtjs + (jsm-hurtjs)*0.1
		end
	end	

	--ʥ����ʹ ���˺����١��������
	if WAR.ZDDH == 14 and (eid == 173 or eid == 174 or eid == 175) then
		local shz = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[enemyid]["�ҷ�"] then
			shz = shz + 1
			end
		end
		if shz == 3 then
			--hurt = math.modf(hurt * 0.5)
			--hurtjs = hurtjs + 0.5
			hurtjs =  hurtjs + (jsm-hurtjs)*0.5
		end
	end	


	if WAR.PD["�߻�״̬"][eid] == 1 then
		--hurt = math.modf(hurt * 0.9)
		--hurtjs = hurtjs + 0.1
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
	end

	--ŷ����  ս��171 ���˺����
	if eid == 60 and WAR.ZDDH == 171 then
		--hurt = math.modf(hurt * 1.2)
		--hurtjs = hurtjs - 0.2 
		hurtjs =  hurtjs + (jsm-hurtjs)*(-0.2)
	end
		
	--�Ƿ壬��̩�� ����ˮ����30%����Ѫʱ50%��Ѫ������25%����75%
	if match_ID(eid, 50) or match_ID(eid, 151) or match_ID(eid, 652) then
		local minhurt = math.modf(hurt * 0.15)
		local qfjs = 1 - JY.Person[eid]["����"] / JY.Person[eid]["�������ֵ"]
        qfjs = limitX(qfjs,minhurt,0.35)
		--hurt = math.modf(hurt * JY.Person[eid]["����"] / JY.Person[eid]["�������ֵ"])
		--hurtjs = hurtjs + qfjs
		hurtjs =  hurtjs + (jsm-hurtjs)*qfjs
	end
			
	--����״̬
	if WAR.Defup[eid] == 1 then
		--�а˻ģ�����40%
		if PersonKF(eid, 101) then
			--hurt = math.modf(hurt * 0.6)
			--hurtjs = hurtjs + 0.4
			hurtjs =  hurtjs + (jsm-hurtjs)*0.4
		--�ް˻ģ�����25%
		else
			--hurt = math.modf(hurt * 0.75)
			--hurtjs = hurtjs + 0.25
			hurtjs =  hurtjs + (jsm-hurtjs)*0.25
		end
	end
	
	if WAR.MRSHZT[eid] ~= nil then
		local sh = 1- math.random(10,15)/10
	   --hurt = math.modf(hurt * math.random(10,15)/10)
	  -- hurtjs = hurtjs + sh
	   hurtjs =  hurtjs + (jsm-hurtjs)*sh
	end
	
	--��ң����Ӽ��ˣ�����20%
	if match_ID(eid,10) then
		local rd = (100 - WAR.GMYS)/100
		if rd > 0.2 then
			rd = 0.2
		end
		--hurtjs = hurtjs + rd
		hurtjs =  hurtjs + (jsm-hurtjs)*rd
	end
	
	--���
	if match_ID(eid, 588) then
		--hurt = math.modf(hurt * 0.9)
		--hurtjs = hurtjs + 0.1
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
	end

	--�����л��е��ˣ��˺�����1%������20%
	if WAR.GMZS[eid] ~= nil then
		local bn = WAR.GMZS[eid]/100
		if bn > 0.2 then
			bn = 0.2
		end
		--hurtjs =  hurtjs + bn
		hurtjs =  hurtjs + (jsm-hurtjs)*bn
	end
	
	--if WAR.YSJF[eid] ~= nil then
		--hurt = math.modf(hurt * 1.5)
		--hurtjs = hurtjs - 0.5
	--end
		
	--��������ÿ���ڹ������ܵ���4%�˺�
	if match_ID(eid, 631) then
		local zzr = 0
		local zzr1 = 0
		for i = 1, CC.Kungfunum do
			if JY.Wugong[JY.Person[0]["�书" .. i]]["�书����"] == 6 then
				zzr = zzr + 1
			end
		end
		if zzr > 10 then 
			zzr = 10
		end
		zzr1 = 0.03 * zzr
		--hurtjs = hurtjs + zzr1
		hurtjs =  hurtjs + (jsm-hurtjs)*zzr1
	end
	
	--����ȭϵ��ÿ��ȭ���������������ܵ���5%�˺�
	if JY.Base["��׼"] == 1 and eid == 0 then
		local lxzq = 0
		local lxzq1 = 0
		for i = 1, CC.Kungfunum do
			if JY.Wugong[JY.Person[0]["�书" .. i]]["�书����"] == 1 and JY.Person[0]["�书�ȼ�" .. i] == 999 then
				lxzq = lxzq + 1
			end
		end
		if lxzq > 7 then
			lxzq = 7
		end
		lxzq1 = 0.05 * lxzq
		--hurtjs = hurtjs + lxzq1
		hurtjs =  hurtjs + (jsm-hurtjs)*lxzq1
	end

		--���ǵ�ϵ��ÿ�����������������ܵ���5%�˺� JY.Wugong[JY.Person[0]["�书" .. i]]["�书����"] == 5 and JY.Person[0]["�书�ȼ�" .. i] == 999
	if JY.Base["��׼"] == 4 and eid == 0 then
		local askd = 0
		for i = 1, CC.Kungfunum do
			if JY.Wugong[JY.Person[eid]["�书" .. i]]["�书����"] == 4 and JY.Person[eid]["�书�ȼ�" .. i] == 999 then
				askd = askd + 1
			end
		end
		if askd > 7 then
			askd = 7
		end
		--hurt = math.modf(hurt * (1 - 0.05 * askd))
		--hurtjs = hurtjs +  0.05 * askd
		hurtjs =  hurtjs + (jsm-hurtjs)*0.05*askd
	end
	
	--Ԭ����ÿ�����ŵ��������ܵ���5%�˺� 
	if match_ID(eid,587) then
		local YZYQM = 0
		for i = 1, JY.Base["�书����"] do
			if JY.Wugong[JY.Person[0]["�书" .. i]]["�书����"] == 5 and JY.Person[0]["�书�ȼ�" .. i] == 999 then
				YZYQM = YZYQM + 1
			end
		end
		if YZYQM > 7 then
			YZYQM = 7
		end
		--hurt = math.modf(hurt * (1 - 0.05 * YZYQM))
		--hurtjs = hurtjs +  0.05 * YZYQM
		hurtjs =  hurtjs + (jsm-hurtjs)*0.05*YZYQM
	end
	
	--�¼��屻Ů�Թ����˺�*200%
	if match_ID(eid, 75) and JY.Person[pid]["�Ա�"] == 1 then
		--hurt = math.modf(hurt*2)
		--hurtjs = hurtjs - 1
		hurtjs =  hurtjs + (jsm-hurtjs)*(-1)
	end
	
	--ͬʱѧ���׽���+��ղ����壬�����׽��񹦱س��������ֻ�����Ч
	--�����/�������� �س���ղ���  
    if(Curr_NG(eid, 144) and (JLSD(30, 90, eid) or match_ID(eid, 603))) or (Curr_NG(eid, 108) and PersonKF(eid, 144)) or match_ID(eid,9986) then
			--hurt = math.modf(hurt *0.7)
			--hurtjs = hurtjs + 0.3
			hurtjs =  hurtjs + (jsm-hurtjs)*0.3
			ang = math.modf(ang *0.7)
			Set_Eff_Text(enemyid, "��Ч����0", "��ղ���")
			WAR.Person[enemyid]["��Ч����"] = 88
		--����
	  elseif PersonKF(eid, 144) and JLSD(30, 65, eid)then
		--hurt = math.modf(hurt *0.8)
		--hurtjs = hurtjs + 0.2
		hurtjs =  hurtjs + (jsm-hurtjs)*0.2
		ang = math.modf(ang *0.8)
		Set_Eff_Text(enemyid, "��Ч����0", "�����ֻ���")
		WAR.Person[enemyid]["��Ч����"] = 88
	end	


	--�����ӱ�Ů�Թ�������20%
	if match_ID(eid, 116) and JY.Person[pid]["�Ա�"] == 1 then
		--hurt = math.modf(hurt*0.8);
		--hurtjs = hurtjs + 0.2
		hurtjs =  hurtjs + (jsm-hurtjs)*0.2
	end
	--����Ů�����Թ�������10%
	if match_ID(eid, 640) and JY.Person[pid]["�Ա�"] == 0 then
		--hurt = math.modf(hurt*0.9);
		hurtjs = hurtjs + 0.1
	end	
		--����������ϼ���10%������20��
	if ZiqiTL(eid) and DWPD() and hurt > 0 then
		--hurt = math.modf(hurt*0.9);
		--hurtjs = hurtjs + 0.1
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
		WAR.BFXS[pid] = 1
		JY.Person[pid]["����̶�"] = JY.Person[pid]["����̶�"] + 20
		if JY.Person[pid]["����̶�"] > 100 then
			JY.Person[pid]["����̶�"] = 100
		end
	end
    
    if match_ID(eid, 9989) then
        if JY.Person[eid]["����"] < JY.Person[eid]["�������ֵ"] / 2 then
		  --hurt = math.modf(hurt/2)
		  --hurtjs = hurtjs + 0.3
		  hurtjs =  hurtjs + (jsm-hurtjs)*0.3
        elseif JY.Person[eid]["����"] < JY.Person[eid]["�������ֵ"] / 4 then
		  --hurt = math.modf(hurt/4)
		  --hurtjs = hurtjs + 0.15
		  hurtjs =  hurtjs + (jsm-hurtjs)*0.15
		end
    end
	
	--ȫ�����ӣ�����������˺����ٺ���������
	if WAR.ZDDH == 73 then
		if (eid >= 123 and eid <= 128)  then
			--hurt = math.modf(hurt * (1-0.30))
			--hurtjs = hurtjs + 0.3
			hurtjs =  hurtjs + (jsm-hurtjs)*0.3
		end
	end	
	--�𴦻�
	if match_ID(eid,68) then
		--hurtjs = hurtjs + 0.15
		hurtjs =  hurtjs + (jsm-hurtjs)*0.15
	end
	--��������30%
	--�������˻������ѧ�������	
    --��������10% 
	if PersonKF(eid, 106) and (JY.Person[eid]["��������"] == 1 or JY.Person[eid]["��������"] == 3) then
		if Curr_NG(eid,106) then
			--hurt = math.modf(hurt*0.7);
			--hurtjs = hurtjs + 0.3
			hurtjs =  hurtjs + (jsm-hurtjs)*0.3
		else
			--hurt = math.modf(hurt*0.85);
			--hurtjs = hurtjs + 0.15
			hurtjs =  hurtjs + (jsm-hurtjs)*0.15
		end
	end
	
	--��������10%
	--ѧ��������������ڻ������
	if PersonKF(eid, 107) and (JY.Person[eid]["��������"] == 0 or JY.Person[eid]["��������"] == 3) then
		--hurt = math.modf(hurt*0.9);
		--hurtjs = hurtjs + 0.1
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
	end	
	
	--�������10%
	if Curr_NG(eid, 103) then
		--hurt = math.modf(hurt*0.9);
		--hurtjs = hurtjs + 0.2
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
	end	
	
		--ɨ����ɮ
	if match_ID(eid, 114) and hurt > 0 then
		--hurtjs = hurtjs + 0.3
		hurtjs =  hurtjs + (jsm-hurtjs)*0.3
		Set_Eff_Text(enemyid, "��Ч����3", "���������ջ���")
	end
	
	--�����᣺�޸����μ���
	if match_ID(eid, 5) and hurt > 0 and JLSD(0,50,eid)then
		--hurt = math.modf(hurt * 0.7)
		--hurtjs = hurtjs + 0.3
		hurtjs =  hurtjs + (jsm-hurtjs)*0.3
		Set_Eff_Text(enemyid, "��Ч����2", "�޸�����")
	end	
	
    --����ָͩ��
    if WAR.HQT_ZL[eid]~= nil then
		local n = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[enemyid]["�ҷ�"]  then
				n = n + 1
			end	
		end
		--hurt =math.modf(hurt*(1-n*0.05))
		--hurtjs = hurtjs + n*0.05
		hurtjs =  hurtjs + (jsm-hurtjs)*n*0.05
	end
	
	--��շ�ħȦ���˺�һ���٣��������
	if PersonKF(eid, 82) and hurt > 0 then
		local jgfmq = 0
		local effstr = "��շ�ħȦ"
		for j = 0, WAR.PersonNum - 1 do
			if PersonKF(WAR.Person[j]["������"], 82) and WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[enemyid]["�ҷ�"] then
				jgfmq = jgfmq + 1
			end
		end
		--����3��
		if jgfmq > 3 then
			jgfmq = 3
		end
		if jgfmq == 3 then
			effstr = "��."..effstr
		end
		if jgfmq > 1 then
			--hurt = math.modf(hurt * (1-0.15*(jgfmq-1)))
			--hurtjs = hurtjs + 0.15*(jgfmq-1)
			hurtjs =  hurtjs + (jsm-hurtjs)*0.15*(jgfmq-1)
		end
	end

	--�����߹�
	if WAR.ZDDH==189  and  (eid >= 130 and eid <= 136) and hurt > 0  then
		local JLQX = 0
		local effstr = "ͬ������"
		for j = 0, WAR.PersonNum - 1 do
			 if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[enemyid]["�ҷ�"] then
				JLQX = JLQX + 1
			end
		end
		if JLQX > 1 then
			--hurt = math.modf(hurt * (1-0.1*(JLQX-1)))
			--hurtjs = hurtjs + 0.1*(JLQX-1)
			hurtjs =  hurtjs + (jsm-hurtjs) *0.1*(JLQX-1)
		end
	end			

   -- �������
	if match_ID(eid,9995) and hurt > 0 then
		if match_ID(eid,577) and (WAR.BJ == 1 or WAR.ACT > 1) then
			--hurtjs = hurtjs + 0.5
			hurtjs =  hurtjs + (jsm-hurtjs) *0.5
		else
			--hurt = math.modf(hurt * 0.5)
			--hurtjs = hurtjs + 0.3
			hurtjs =  hurtjs + (jsm-hurtjs) *0.3
		end
		WAR.Person[enemyid]["��Ч����"] = 118
		Set_Eff_Text(enemyid, "��Ч����1", "�������")	 
	end
	
    if match_ID(eid,9966) and hurt > 0 then
		--hurtjs = hurtjs + 0.3
		hurtjs =  hurtjs + (jsm-hurtjs) *0.3
    end
    
	if Curr_QG(eid,186) and JLSD(40, 70, eid) and hurt > 0 then
		--hurt = math.modf(hurt*0.7)
		--hurtjs = hurtjs + 0.3
		hurtjs =  hurtjs + (jsm-hurtjs) *0.3
 		WAR.Person[enemyid]["��Ч����"] = 51
		Set_Eff_Text(enemyid, "��Ч����2", "һέ�ɽ�����")   
	end
		
	--�޾Ʋ������貨΢����
	if Curr_QG(eid, 147) and JLSD(30, 80, eid) and hurt > 0 then
		--hurt = math.modf(hurt *0.6)
		--hurtjs = hurtjs + 0.4
		hurtjs =  hurtjs + (jsm-hurtjs) *0.4
		ang = math.modf(ang *0.6)
		WAR.Person[enemyid]["��Ч����"] = 51
		Set_Eff_Text(enemyid, "��Ч����2", "�貨΢������")
	end
	
	--½����ʮ������
    if match_ID(eid, 497) and hurt > 0 then
		--hurt = math.modf(hurt*0.85)
		--hurtjs = hurtjs + 0.15
		hurtjs =  hurtjs + (jsm-hurtjs) *0.15
		WAR.Person[enemyid]["��Ч����2"] = "һ���໤��"
		WAR.Person[enemyid]["��Ч����"] = 136
	end	
	
	--�޾Ʋ�������������
	--����;���
	if Curr_NG(eid, 105) or (match_ID_awakened(eid, 189, 1) and PersonKF(eid, 105)) then
		--�������߱ض�����
		local khzz = 0
		if (JLSD(20, 50, eid) or match_ID(eid, 27) or match_ID(eid, 511)) and hurt > 0  then
			--hurt = math.modf(hurt *0.7)
			--hurtjs = hurtjs + 0.3
			hurtjs =  hurtjs + (jsm-hurtjs) *0.3
			ang = math.modf(ang *0.7)
			WAR.Person[enemyid]["��Ч����"] = 51
			Set_Eff_Text(enemyid, "��Ч����2", "��������")
		end
	end

	--�ҷ������ڳ�
	if ZDGH(enemyid,609) and WAR.Miss[eid] == nil then
		--����ʱ20%����
		if WAR.Actup[eid] ~= nil then
			--hurt = math.modf(hurt*0.8)
			--hurtjs = hurtjs + 0.2
			hurtjs =  hurtjs + (jsm-hurtjs) *0.2
		end
	end
	
	--�������Ŷݼף���ɫ����
	if WAR.Person[enemyid]["�ҷ�"] == true and GetWarMap(WAR.Person[enemyid]["����X"], WAR.Person[enemyid]["����Y"],6) == 1 then
		--hurt = math.modf(hurt*0.8)
		--hurtjs = hurtjs + 0.2
		hurtjs =  hurtjs + (jsm-hurtjs) *0.2
	end
	
	--�����޼���
	if Curr_NG(eid, 221) and hurt > 0 then
		local nl = JY.Person[eid]['����']
		local n = limitX(nl/20000,0,0.5)
		--hurt = math.modf(hurt*n);
		--hurtjs = hurtjs + n
		hurtjs =  hurtjs + (jsm-hurtjs) *n
		WAR.Person[enemyid]["��Ч����"] = 21
		Set_Eff_Text(enemyid, "��Ч����2", "�����޼�")
	end
    
     --�������ڳ�
    if ZDGH(enemyid,569) then 	
		--hurt = math.modf(hurt*0.8)
		--hurtjs = hurtjs + 0.2
		hurtjs =  hurtjs + (jsm-hurtjs) *0.2
	end
	
   -- ÷�����ڳ����з�ÿ5�����ֵ�����˺�1%
    if ZDGH(enemyid,507) then
		local bfjs = JY.Person[pid]["����̶�"]/500
		--hurtjs = hurtjs - bfjs
		hurtjs =  hurtjs + (jsm-hurtjs) *bfjs
	end
	--ħ������
	if ZDGH(enemyid,9991) then
		--hurt = math.modf(hurt*0.9)
		--hurtjs = hurtjs + 0.1
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
    end
    
	
	--�޾Ʋ��������аٱ����
	if Curr_QG(eid, 146) and WAR.Miss[eid] == nil then
		local c_up = 0
		--Ԭ��־���Ѻ�������+5%
		if match_ID_awakened(eid, 54, 1)   then
			c_up = 10
		end
		if JLSD(40, 65+c_up, eid) and hurt > 0 then
			--hurt = math.modf(hurt *0.7)
			--hurtjs = hurtjs + 0.3
			hurtjs =  hurtjs + (jsm-hurtjs)*0.3
			ang = math.modf(ang *0.7)
			WAR.Person[enemyid]["��Ч����"] = 51
			Set_Eff_Text(enemyid, "��Ч����2", "���аٱ����")
		end
	end
	

	
	--�۽���Ӯ���£��Ž��洫70%���ʼ���20%�������͹����»غϼ���λ��
	--��Ϧ������Դ�
	if (match_ID(eid,9974) or match_ID_awakened(eid,35,2) or (eid == 0 and JY.Person[241]["Ʒ��"] == 80) ) and JLSD(15, 85,eid)  and DWPD() and hurt > 0  then
		local jpwz;
		if JY.Wugong[wugong]["�书����"] == 1 or JY.Wugong[wugong]["�书����"] == 2 then
			jpwz = "�Ž��洫������ʽ"
		elseif JY.Wugong[wugong]["�书����"] == 3 then
			jpwz = "�Ž��洫���ƽ�ʽ"
		elseif JY.Wugong[wugong]["�书����"] == 4 then
			jpwz = "�Ž��洫���Ƶ�ʽ"
		elseif JY.Wugong[wugong]["�书����"] == 5 then
			jpwz = "�Ž��洫���ƹ�ʽ"
		elseif JY.Wugong[wugong]["�书����"] == 6 then
			jpwz = "�Ž��洫������ʽ"
		end
		WAR.Person[enemyid]["��Ч����"] = 83
		--hurt = math.modf(hurt * 0.8)
		--hurtjs = hurtjs + 0.2
		hurtjs =  hurtjs + (jsm-hurtjs)*0.2
		WAR.JJPZ[pid] = 1	--�Ž�����
		Set_Eff_Text(enemyid, "��Ч����1", jpwz)
	end
  
		--�޾Ʋ�����̫��ж��35%���ʣ�����33.3%���з��»غϼ���λ��-120
	for i = 1, JY.Base["�书����"] do
		if (JY.Person[eid]["�书" .. i] == 15 or JY.Person[eid]["�书" .. i] == 16) and JY.Person[eid]["�书�ȼ�" .. i] == 999 then
			WAR.TKXJ = WAR.TKXJ + 1
		end
	end
	if WAR.TKXJ == 2 and JLSD(30, 65, eid) then
		WAR.TKXJ = 3
	end
	if WAR.TKXJ == 3  then
		--hurt = math.modf(hurt * 0.7)
		--hurtjs = hurtjs + 0.3
		hurtjs =  hurtjs + (jsm-hurtjs)*0.3
		WAR.TKJQ[pid] = 1	--̫��ж��
		WAR.Person[enemyid]["��Ч����"] = 113
		Set_Eff_Text(enemyid, "��Ч����3", "̫��ж��")
	end
	WAR.TKXJ = 0
	
	   -- ��������������
	if match_ID(eid,5) and WAR.PD["̫������"][eid]~= nil and  WAR.PD["̫������"][eid] > 0 then
		local tjxl = WAR.PD["̫������"][eid]/5000
		hurtjs =  hurtjs + (jsm-hurtjs)*tjxl
	end	 
	
	--����
	if WAR.ZDDH == 344 and inteam(eid) == false then
		--hurt = math.modf(hurt * 0.7)
		--hurtjs = hurtjs + 0.3
		hurtjs =  hurtjs + (jsm-hurtjs)*0.3
    end	
	

	--ɱ������25%
	if WAR.TJAY == 3 then
		--ѧ��̫���񹦣�����̫���������10%
		if PersonKF(eid, 171) and hurt > 0  then
			--hurt = math.modf(hurt * 0.9)
			--hurtjs = hurtjs + 0.1
			hurtjs =  hurtjs + (jsm-hurtjs)*0.1
		end
		WAR.Person[enemyid]["��Ч����"] = 21
		--ѧ��̫���񹦱س���̫�£�������35%���ʷ���
		if PersonKF(eid, 171) or JLSD(40, 75, eid) then
			WAR.TJAY = 4
			Set_Eff_Text(enemyid,"��Ч����1","̫�����塤������ǧ��");
		else
			Set_Eff_Text(enemyid,"��Ч����2","̫������");
		end
	end
	
	--���ϳ�����
	if Curr_NG(eid,183) then
		--hurt = math.modf(hurt * 0.75)
		--hurtjs = hurtjs + 0.25
		hurtjs =  hurtjs + (jsm-hurtjs)*0.25
	end	
	
     --��������
	if match_ID(eid,9980) then
		--hurt = math.modf(hurt*math.random(75,125)/100)
		local wwwql = math.random(75,125)/100 - 1
		hurtjs =  hurtjs + (jsm-hurtjs)*wwwql
	end	
	
 	--�����ÿ�ж�һ�Σ�����ʱ�˺�һ-5%
	if WAR.PD["�����"][eid] ~=nil and WAR.PD["�����"][eid] > 0 then
		--hurt = math.modf(hurt * (1 - WAR.PD["�����"][pid]/20))
	    local zfjs = WAR.PD["�����"][eid]*0.05
		hurtjs =  hurtjs + (jsm-hurtjs)*zfjs
	end  	
	
    --�Ϲٽ��� 
	if match_ID(eid,567) then
		--hurt = math.modf(hurt*0.9)
		--hurtjs = hurtjs + 0.1
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
    end
	
    --��ң��
	if Curr_QG(eid,2) then
		--hurt = math.modf(hurt*0.9)
		--hurtjs = hurtjs + 0.1
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
    end	
	
	--���ܲ����������ػ������żһԵĻ����ָ
	if hurt > 0 and DWPD() then
		--�żһԵĻ����ָ             
		if JY.Person[eid]["����"] == 302 then
			local factor = 3
			if JY.Thing[302]["װ���ȼ�"] >=5 then
				factor = 1
			elseif JY.Thing[302]["װ���ȼ�"] >=3 then
				factor = 2
			end
			local hn = math.modf(hurt/2*factor)
			if JY.Person[eid]["����"] > hn then
				--hurt = math.modf(hurt/2)
				--hurtjs = hurtjs + 0.5
				hurtjs =  hurtjs + (jsm-hurtjs)*0.5
				WAR.Person[enemyid]["��������"] = (WAR.Person[enemyid]["��������"] or 0)+AddPersonAttrib(eid, "����", -hn)
				WAR.Person[enemyid]["��Ч����"] = 144
			end
		end
	end
	--��������
	--hurtjs = hurtjs + math.modf(hurt * (1 - limitX(Def(enemyid)/1500,0,0.7)))	
	if hurtjs > 0.75 then
		hurtjs = 0.75
	end
   hurt =  hurt* (1-hurtjs)
   
end	

	--���¼���Ч����ֻ���˺�����30ʱ�Żᴥ��
	--Ǭ����Ų�Ʒ������������ڶԷ��Ŵ���
	--���˲�����
	if ((PersonKF(eid, 97) and JY.Person[eid]["����"] > JY.Person[pid]["����"]) or (eid == 0 and WAR.NZQK == 1)) and DWPD() and MyFj(WAR.CurID) == false then
		local ft = 0
		--WAR.fthurt = 0
		local nydx = {}
		local nynum = 1
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["�ҷ�"] ~= WAR.Person[enemyid]["�ҷ�"] and WAR.Person[i]["����"] == false and MyFj(i) == false then
				nydx[nynum] = i
				nynum = nynum + 1
			end
		end
			
		--��������
		local nyft = nydx[math.random(nynum - 1)]
		--���޼ɿ��Է�������
		local nyft2 = nydx[math.random(nynum - 1)]
			
		local h = 0;
		--������������50%������20%
		--���˷�������75%������30%
		local chance = 51
		local cfr = 0.8
		if Curr_NG(eid, 97) then
			chance = 76
			cfr = 0.7
		end
		--�ҷ���ÿ����������3%��������
		if inteam(eid) then
			chance = chance + JY.Base["��������"]*3
		end
		--���޼ɷ���40%
		if match_ID(eid, 9) then
			cfr = 0.6
		end
  		--ѧ�������
		if Curr_NG(eid,106) then
			cfr = 0.6
			chance = 80
		end         
		
		--��תǬ�����ض�����50%
		if WAR.NZQK == 1 then
			chance = 101
			cfr = 0.5
		end
			
		if (math.random(100) < chance) and WAR.L_QKDNY[WAR.Person[nyft]["������"]] == nil then
			ft = math.modf(hurt*(1-cfr))			
			hurt = math.modf(hurt*cfr)
			h = math.modf(ft + Rnd(10));		--�������˺�
			SetWarMap(WAR.Person[nyft]["����X"], WAR.Person[nyft]["����Y"], 4, 2);	--�����߱�ʶΪ������
				
			WAR.L_QKDNY[WAR.Person[nyft]["������"]] = 1;
				
			WAR.Person[nyft]["��������"] = (WAR.Person[nyft]["��������"] or 0) - h;
			--�޾Ʋ�������¼����Ѫ��
			WAR.Person[nyft]["Life_Before_Hit"] = JY.Person[WAR.Person[nyft]["������"]]["����"]	
			JY.Person[WAR.Person[nyft]["������"]]["����"] = JY.Person[WAR.Person[nyft]["������"]]["����"] - h
			if JY.Person[WAR.Person[nyft]["������"]]["����"] < 1 then
				JY.Person[WAR.Person[nyft]["������"]]["����"] = 1
			end
				
			Set_Eff_Text(enemyid, "��Ч����3", "Ǭ����Ų�ơ�����")
				  
			--���޼ɣ����Է���������
			if (match_ID(eid, 9) or Curr_NG(eid,106)or match_ID(eid, 9990)) and nyft ~= nyft2 then
				WAR.Person[nyft2]["��������"] = (WAR.Person[nyft2]["��������"] or 0) - h;
				--�޾Ʋ�������¼����Ѫ��
				WAR.Person[nyft2]["Life_Before_Hit"] = JY.Person[WAR.Person[nyft2]["������"]]["����"]	
				JY.Person[WAR.Person[nyft2]["������"]]["����"] = JY.Person[WAR.Person[nyft2]["������"]]["����"] - h;
				if JY.Person[WAR.Person[nyft2]["������"]]["����"] < 1 then
					JY.Person[WAR.Person[nyft2]["������"]]["����"] = 1
				end
				WAR.Person[enemyid]["��Ч����3"] = WAR.Person[enemyid]["��Ч����3"] .. "��˫"
				SetWarMap(WAR.Person[nyft2]["����X"], WAR.Person[nyft2]["����Y"], 4, 2);	--�����߱�ʶΪ������
			end
		end
			
	end
	


	hurt2 = limitX (math.modf(math.random(20) + math.modf(true_WL / 10)),math.random(20)+50)

	--��ֹ�书���״��ڻ����˺�
	if hurt2 > hurt3 then 
		hurt2 = hurt3
	end

	if hurt > 300 then
		local hn = 0
		local hm = 0
		hn,hm = math.modf((hurt-200)/100) -- ˥������
		hurt = 300
		while hn > 0 do
			local r = math.random(8,10)
			local r1 = r/100
			local sj = limitX(1-(hn*r1),0,1) --˥������
			if hm > 0 then
			hurt =  hurt + hm*100*sj
			hm = 0
			else 
			hurt = hurt + 100*sj
			end
			hn = hn-1
		end
	end

	--����˺�һС���˺�����������˺�����������
	if hurt < hurt2 then
		hurt = hurt2
	end

	---------------------------------------------------------------------------
	--///////////////////////////�Ӽ�������////////////////////////////////////
	---------------------------------------------------------------------------
	--����ǿ���˺�
	if WAR.FGPZ[eid]~= nil then  
		hurt =  hurt - 30
	end 
	--�˺�ǿ��Ϊ50 װ������
	if eid == 0 and JY.Person[eid]["����"] == 312 and hurt > 50 then
		hurt = 50
	end	
	
  	--����ˮ ����
	if (match_ID(eid, 652) or Curr_NG(eid,177)) and JLSD(0, 35, eid) and JY.Base["��������"] > 3 and hurt > 32 then
		hurt = hurt - 32
		WAR.Person[enemyid]["��Ч����"] = 63
		Set_Eff_Text(enemyid, "��Ч����3", "����")
	end
	

	
	-- ˾��ժ�� �������� math.modf(WAR.fthurt + Rnd(10))
	if match_ID(eid,579) and eid == 0 and JLSD(15, 35+JY.Base["��������"],eid) and hurt > 0 then
		hurt = math.modf(WAR.WS + Rnd(10))
		Set_Eff_Text(enemyid, "��Ч����0", "ǧ��.��������")
		WAR.Person[enemyid]["��Ч����"] = 102
	end 
	
	--����ÿ5���ж��̶ȼ���1%
	if eid == 0 and JY.Base["��׼"] == 9 then
		hurt = hurt - JY.Person[eid]["�ж��̶�"] / 2
	end
	

	if WAR.LYSH == 3 then
			--32%���ʱ������ػ�����
		if JLSD(30,62,eid) and hurt > 32 then 
			hurt = hurt - 64
            ang = ang - 640
			WAR.Person[enemyid]["��Ч����"] = 21
			Set_Eff_Text(enemyid, "��Ч����1", "�����ػ�����")
		else  
			hurt = hurt - 32
			WAR.Person[enemyid]["��Ч����"] = 21
			Set_Eff_Text(enemyid, "��Ч����1", "�����ػ�")
	   end
	end
    
    WAR.LYSH = 0
	--�������� ��������ӡ
	if WAR.PD["��"][eid]~= nil and WAR.PD["��"][eid] == 1 and hurt > 50 then 
		hurt = hurt - 50
		Set_Eff_Text(enemyid, "��Ч����1", "��������ӡ")
	end

	--½�� ȸĸ�����50��
	if match_ID(eid,497) and JLSD(20, 50, eid) and JY.Base["��������"] > 2 and WAR.SSESS[eid] ~= nil and hurt > 50 then
		hurt = hurt - 50
		Set_Eff_Text(enemyid, "��Ч����1", "ȸĸ��")
	end
		
	--������
	if WAR.PD['������'][eid] == 1 and hurt > 99 then
		if hurt > 199 then
			hurt = hurt - 99
		else
			hurt = hurt - 66
	    end
    end
		--��⬼׼���20�㣬��ȭָϵ�书���������������ǿ����10����Ѫ
	--���ܲ��ᴥ����⬼�
	if JY.Person[eid]["����"] == 58 and hurt > 0 and DWPD() then
		local hurt_reduction = 20 + 2 * (JY.Thing[58]["װ���ȼ�"]-1)
		hurt = hurt - hurt_reduction
		--������⬼�֮��������1Ѫ
		if hurt < 1 then
			hurt = 1
		end
		
		if WGLX == 1 or WGLX == 2 then
			WAR.LXXS[pid] = 1
			if WAR.LXZT[pid] == nil then
				WAR.LXZT[pid] = 10
			else
				WAR.LXZT[pid] = WAR.LXZT[pid] + 10
			end
			if WAR.LXZT[pid] > 100 then
				WAR.LXZT[pid] = 100
			end
			
		end
	end
	--ɨ�ز�����ɽ
	if hurt > 30 then
	   if match_ID(eid,9963) and JLSD(10,35,eid)  then
		Set_Eff_Text(enemyid, "��Ч����0", "���سɷ�")
		WAR.Person[enemyid]['����'] = 4
		WAR.PD["���سɷ�"][eid] = (WAR.PD["���سɷ�"][eid] or 0) + hurt/2			   		
	   elseif match_ID(eid,9971) and JLSD(10,35,eid) then
			hurt = 30
			WAR.Person[enemyid]["��Ч����"] = 6
			Set_Eff_Text(enemyid, "��Ч����0", "������ɽ")
		end
	end	
   if match_ID(eid,9963) and WAR.PD["���سɷ�"][eid] ~= nil and WAR.PD["���سɷ�"][eid] > 0 then
	    if hurt < WAR.PD["���سɷ�"][eid] then	 
		   WAR.PD["���سɷ�"][eid] = WAR.PD["���سɷ�"][eid] - hurt
		   hurt = 0
	    else
	      hurt = hurt - WAR.PD["���سɷ�"][eid]
	      WAR.PD["���سɷ�"][eid] = nil
	      WAR.Person[enemyid]['����'] = nil
		end     
	end	
    if JY.Person[eid]["����"] == 312 and hurt > 30 then
		hurt = 30
	end	
---------------------------------------------------------------------------
-----------------------------��ʵ�˺�-------------------------------------
---------------------------------------------------------------------------
	--��ţ����
    if 	wugong == 193 and (WAR.Person[enemyid].Time >= -200 and WAR.Person[enemyid].Time <= 200) and DWPD() then
		if JY.Person[eid]["����"]/JY.Person[eid]["�������ֵ"] < 0.1 and math.random(100) <= 30 then
			hurt = hurt + JY.Person[eid]["����"]			
		end
	end
 
	--��Ȼ������ 
	if wugong == 25 and match_ID(pid,58) and DWPD() then
		local jl = (1- JY.Person[eid]["����"]/JY.Person[eid]["�������ֵ"])*30
		if JY.Person[eid]["����"] < JY.Person[eid]["�������ֵ"]/2 and  math.random(100) <= jl then
			hurt = hurt + JY.Person[eid]["����"]
			
		end
	end
	
	--����ɽ���� 
	if wugong == 24 and DWPD() then
		local jl = (1- JY.Person[eid]["����"]/JY.Person[eid]["�������ֵ"])*30
		if JY.Person[eid]["����"] < JY.Person[eid]["�������ֵ"]/10 and math.random(100) <= jl then
			hurt = hurt + JY.Person[eid]["����"]
			WAR.PD["��������"][pid] = 2
		end
	end	
	

---------------------------------------------------------------------------
-----------------------------��������˺�-------------------------------------
---------------------------------------------------------------------------
	if WAR.Miss[eid] == 1 then 
		hurt = 0
	end

---------------------------------------------------------------------------
-----------------------------����һ�н����˺�-------------------------------------
---------------------------------------------------------------------------
	--ΤС��������˫������ǰ50ʱ�����˺�������50
	if match_ID(eid, 601) and WAR.SXTJ <= 50 and hurt > 50 then
		hurt = math.random(40,50)
		WAR.Person[enemyid]["��Ч����"] = 90
		Set_Eff_Text(enemyid, "��Ч����1", "������˫")
	end
	
	--һ�Ƹ���󣬲��������˺�
	if match_ID(eid, 65) and DWPD() and WAR.FUHUOZT[eid] ~= nil and WAR.ACT > 1 and hurt > 0 then
		hurt = 0
		WAR.Person[enemyid]["��Ч����"] = 136
		Set_Eff_Text(enemyid, "��Ч����2", "��������")
	end
	
	 --��̩�� ��̩�� 
    if match_ID(eid,151) and WAR.WTL_1[eid] == 0 and hurt >  JY.Person[eid]["����"] then
		WAR.WTL_PJTL[eid] = 10
	end 
	
	--��̩����̩�� 	
    if  WAR.WTL_PJTL[eid] ~= nil then	        
	    WAR.Person[enemyid]["��Ч����0"] = nil
		WAR.Person[enemyid]["��Ч����1"] = nil
		WAR.Person[enemyid]["��Ч����2"] = nil
		WAR.Person[enemyid]["��Ч����3"] = nil
		WAR.Person[enemyid]["��Ч����4"] = nil
		WAR.Person[enemyid]["��Ч����"] = nil
	    hurt = 0
		WAR.Person[enemyid]["��Ч����"] = 157
		Set_Eff_Text(enemyid, "��Ч����1", "��̩��")
    end	
	 
	--����״̬
	if  WAR.BTZT[eid] ~= nil then		
	    hurt = 0
	    WAR.Person[enemyid]["��Ч����0"] = nil
		WAR.Person[enemyid]["��Ч����1"] = nil
		WAR.Person[enemyid]["��Ч����2"] = nil
		WAR.Person[enemyid]["��Ч����3"] = nil
		WAR.Person[enemyid]["��Ч����4"] = nil
		WAR.Person[enemyid]["��Ч����"] = nil		
	    WAR.Person[enemyid]["��Ч����"] = 118
	    Set_Eff_Text(enemyid, "��Ч����1", "����")
	end	
	
	--����ɮ���������˺�
	if match_ID(eid, 9966) and WAR.ACT > 1 then
		hurt = 0
	end
	
        --�����
	if match_ID(eid,9986) and WAR.FUHUOZT[eid] ~= nil and WAR.BJ == 1 and hurt > 0 then
        hurt = 0
	end		
        
	--�Ĵ�ɽ�����㲻�������˺�
	if eid == 642 then
		local s = 0
		for j = 0, WAR.PersonNum - 1 do
			if j ~= enemyid and WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[enemyid]["�ҷ�"] then
				s = 1
				break
			end
		end
		if s == 1 then
			hurt = 0
			Set_Eff_Text(enemyid, "��Ч����1", "�Ǻ������������˺�")
		end
	end
	
		--�޾Ʋ������˻����Ϲ�
	if ((PersonKF(eid, 101) and JLSD(40, 60, eid)) or (Curr_NG(eid, 101) and JLSD(20, 80, eid)) or WAR.NGHT == 101) and DWPD() and hurt > 0 then
		local reduction = math.modf(hurt * 0.333)
		hurt = hurt - reduction
		WAR.Person[enemyid]["��������"] = (WAR.Person[enemyid]["��������"] or 0)+reduction
		AddPersonAttrib(eid, "����", reduction)
		local bhwz;
		if math.random(2) == 1 then
			bhwz = "�˻�����.Ψ�Ҷ���"
		else
			bhwz = "Ψ�Ҷ���.�˻�����"
		end
		Set_Eff_Text(enemyid, "��Ч����3", bhwz)
	end
	
     --���ϳ�����
	if (Curr_NG(eid,183) or match_ID(eid,634)) and hurt > 0 and DWPD() and JLSD(10,50,eid) then
		WAR.Person[enemyid]["��Ч����"] = 79
		Set_Eff_Text(enemyid, "��Ч����1", "��������")
		if  JY.Person[eid]["����"] < 0 then
		elseif hurt*2 < JY.Person[eid]["����"] then
			WAR.Person[enemyid]["��������"] = (WAR.Person[enemyid]["��������"] or 0) + AddPersonAttrib(eid, "����",-math.modf(hurt*2));
	        hurt = 0
	    else
	        hurt = hurt - math.modf(JY.Person[eid]["����"]/2)
	        WAR.Person[enemyid]["��������"] = (WAR.Person[enemyid]["��������"]or 0) + AddPersonAttrib(eid,"����",-JY.Person[eid]["����"])
	    end
    end
	--�������
	if Curr_NG(eid,100) and WAR.PD["���커��"][eid] ~=nil and WAR.PD["���커��"][eid] > 0 then
		WAR.Person[enemyid]["��Ч����"] = 79
		Set_Eff_Text(enemyid, "��Ч����1", "�������")	
          if hurt < WAR.PD["���커��"][eid] then	 
			 WAR.PD["���커��"][eid] = WAR.PD["���커��"][eid] - hurt
			 hurt = 0
	      else
            hurt = hurt - WAR.PD["���커��"][eid]
			WAR.PD["���커��"][eid] = nil
		    WAR.Person[enemyid]['����'] = nil
	      end
    end
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
	----------------------------------------------------------------
	------------------------�����Ѫǰ������˺�����ֹ�˺�С0--------------------------------
	hurt = limitX(math.modf(hurt),0)
	----------------------------------------------------------------
	------------------------�����Ѫǰ������˺�����ֹ�˺�С0--------------------------------

	WAR.ZQHT = 0
	
  
	--�Ž��洫������ʽǿ��ɱ����
	if WAR.JJZC == 2 and DWPD() then
		WAR.Person[enemyid].TimeAdd = WAR.Person[enemyid].TimeAdd - 150
	end


	--����ˮ ����
	if (match_ID(pid, 652) or Curr_NG(pid,177)) and JLSD(0, 35, pid) and JY.Base["��������"] > 4 and DWPD() then
		WAR.Person[enemyid].TimeAdd = WAR.Person[enemyid].TimeAdd - 200
		WAR.Person[enemyid]["��Ч����"] = 63
		Set_Eff_Text(enemyid, "��Ч����3", "����")
	end
    
	--�������ģ�������������
	if JiandanQX(eid) and DWPD() then
		local max_bonus = 420 - JY.Person[eid]["��������"]
		if WAR.JDYJ[eid] == nil then
			WAR.JDYJ[eid] = 0
		end
		if WAR.JDYJ[eid] < max_bonus then
			WAR.JDYJ[eid] = WAR.JDYJ[eid] + math.modf(hurt/20)
			WAR.Person[enemyid]["��Ч����"] = 125
			Set_Eff_Text(enemyid,"��Ч����3","��������")
			if WAR.JDYJ[eid] > max_bonus then
				WAR.JDYJ[eid] = max_bonus
			end
		end
	end
	
	--������1 ͬ�齣��
	if WAR.TGJF[pid] ~= nil and DWPD() and MyFj(WAR.CurID)== false then	
	    local selfhurt = math.modf(hurt * 1)
		JY.Person[pid]["����"] = JY.Person[pid]["����"] - math.modf(selfhurt)
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0)-math.modf(selfhurt)
		CurIDTXDH(WAR.CurID, 63,2, "���ͬ��", C_ORANGE)
		if JY.Person[pid]["����"] < 1 then
			JY.Person[pid]["����"] = 1
		end
	end

	--��������
	if match_ID(eid, 609) and DWPD() and hurt > 10 and MyFj(WAR.CurID)== false then
		WAR.Person[enemyid]["��Ч����"] = 144
		SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 4, 2)
		--�޾Ʋ�������¼����Ѫ��
		WAR.Person[WAR.CurID]["Life_Before_Hit"] = JY.Person[pid]["����"]
		local selfhurt = math.modf(hurt * 0.3)
		JY.Person[pid]["����"] = JY.Person[pid]["����"] - math.modf(selfhurt)
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0)-math.modf(selfhurt)
		if JY.Person[pid]["����"] < 1 then
			JY.Person[pid]["����"] = 1
		end
	end
	
	--����ɮ
	if match_ID(eid,638) and DWPD() and hurt > 10 and MyFj(WAR.CurID) == false then
		WAR.Person[enemyid]["��Ч����"] = 88
		Set_Eff_Text(enemyid, "��Ч����0", "�����񹦡�����")
		SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 4, 2)
		--�޾Ʋ�������¼����Ѫ��
		WAR.Person[WAR.CurID]["Life_Before_Hit"] = JY.Person[pid]["����"]
		local selfhurt = math.modf(hurt * 0.4)
		JY.Person[pid]["����"] = JY.Person[pid]["����"] - math.modf(selfhurt)
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0)-math.modf(selfhurt)
		if JY.Person[pid]["����"] < 1 then
			JY.Person[pid]["����"] = 1
		end
	end	

	--����
	if JY.Person[pid]["����"] < 0 then
		JY.Person[pid]["����"] = 0
	end
  
	--���˴��Լ���
	if WAR.Person[WAR.CurID]["�ҷ�"] == WAR.Person[enemyid]["�ҷ�"] then
		--�ҷ�
		if WAR.Person[WAR.CurID]["�ҷ�"] then
			--ˮ�����˼�Ѫ
			if match_ID(pid, 589) then
				hurt = -(math.modf(hurt) + Rnd(3))
			--����������30%
			else
				hurt = math.modf(hurt * 0.3) + Rnd(3)
			end
		--NPC������=20%
		else
			--�������100%
			if WAR.NZQK == 3 then
			
			--������תǬ����NPC���������50%
			elseif WAR.NZQK == 0 then
				hurt = math.modf(hurt * 0.2) + Rnd(3)
			else
				hurt = math.modf(hurt * 0.5) + Rnd(3)
			end
		end
	end

		   
	--�޾Ʋ������˺��Ľ��㵽��Ϊֹ���۳���������Ѫ��
	if hurt > 1999 then
		hurt = 1999
	end
	
	--���Ƴ�������׷������
	if match_ID(pid, 37) and hurt < 150 and DWPD()  then
		WAR.CXLC = 1
	end

	--��ƽ֮���Ѻ󣬸����˺�����
	if match_ID_awakened(pid, 36, 1) then
		WAR.LPZ = hurt/2
		if WAR.LPZ > 400 then
			WAR.LPZ = 400
		end
	end
	
	--ʯ������Ѻ���30%���ʰ����Ѫ
	if (match_ID_awakened(eid, 38, 1) or Curr_NG(eid,102) and (JY.Person[191]["Ʒ��"] == 60 or not inteam(eid))) and DWPD() and math.random(10) < 3 then
		hurt = -math.modf(hurt/2)
		WAR.Person[enemyid]["��Ч����2"] = "����̫��"
		WAR.Person[enemyid]["��Ч����"] = 147
	end		
	
	if WAR.ZDDH == 356 and WAR.PD['�����4'][eid] == 5 then 
		hurt = -hurt
		WAR.Person[enemyid]["��Ч����"] = 6
		Set_Eff_Text(enemyid, "��Ч����0", "������")
	end
		
	--��ֹ�˺�����С����
	hurt = math.modf(hurt)
  
	--��Ѫ��ʽ
	JY.Person[eid]["����"] = JY.Person[eid]["����"] - hurt
	
	if JY.Person[eid]["����"] > JY.Person[eid]["�������ֵ"] then
		JY.Person[eid]["����"] = JY.Person[eid]["�������ֵ"]
	end
	

	--̫������
	if Curr_NG(eid,171) then
		if WAR.PD["̫������"][eid] == nil or WAR.PD["̫������"][eid] == 0 then
			WAR.PD["̫������"][eid] = 0
		end
		if match_ID(eid,5) then
            WAR.PD["̫������"][eid] = 50 + math.modf(WAR.PD["̫������"][eid] + hurt*1.2);
		else
            WAR.PD["̫������"][eid] = 50 + WAR.PD["̫������"][eid] + hurt;
		end
		--����1080
		if WAR.PD["̫������"][eid] > 980 then
			WAR.PD["̫������"][eid] = 980
			
		end
	end

		--���� ��Ϣ������
	if Curr_NG(eid, 180) then
		--��������
		if WAR.PD["��Ϣ����"][eid] == nil or WAR.PD["��Ϣ����"][eid] == 0 then
			WAR.PD["��Ϣ����"][eid] = 50+hurt;
		else
			WAR.PD["��Ϣ����"][eid] = WAR.PD["��Ϣ����"][eid] + hurt;
		end
				--����1080
		if WAR.PD["��Ϣ����"][eid] > 1080 then
			WAR.PD["��Ϣ����"][eid] = 1080
		end
	end	
	--��ȡ�þ���
	WAR.Person[WAR.CurID]["����"] = WAR.Person[WAR.CurID]["����"] + math.modf((hurt) / 5)
	
	--װ����ȡ����
	if WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[enemyid]["�ҷ�"] and WAR.ZDDH ~= 226 then
		--������ȡ����
		if JY.Person[pid]["����"] ~= - 1 then
			JY.Thing[JY.Person[pid]["����"]]["װ������"] = JY.Thing[JY.Person[pid]["����"]]["װ������"] + 5
			if JY.Thing[JY.Person[pid]["����"]]["װ������"] > 100 and JY.Thing[JY.Person[pid]["����"]]["װ���ȼ�"] < 6 then
				JY.Thing[JY.Person[pid]["����"]]["װ������"] = 0
				JY.Thing[JY.Person[pid]["����"]]["װ���ȼ�"] = JY.Thing[JY.Person[pid]["����"]]["װ���ȼ�"] + 1
			end
		end
		--���߻�ȡ����
		if JY.Person[eid]["����"] ~= - 1 then
			JY.Thing[JY.Person[eid]["����"]]["װ������"] = JY.Thing[JY.Person[eid]["����"]]["װ������"] + 5
			if JY.Thing[JY.Person[eid]["����"]]["װ������"] > 100 and JY.Thing[JY.Person[eid]["����"]]["װ���ȼ�"] < 6 then
				JY.Thing[JY.Person[eid]["����"]]["װ������"] = 0
				JY.Thing[JY.Person[eid]["����"]]["װ���ȼ�"] = JY.Thing[JY.Person[eid]["����"]]["װ���ȼ�"] + 1
			end
		end
		--�����ȡ����
		if JY.Person[eid]["����"] ~= - 1 then
			JY.Thing[JY.Person[eid]["����"]]["װ������"] = JY.Thing[JY.Person[eid]["����"]]["װ������"] + 5
			if JY.Thing[JY.Person[eid]["����"]]["װ������"] > 100 and JY.Thing[JY.Person[eid]["����"]]["װ���ȼ�"] < 6 then
				JY.Thing[JY.Person[eid]["����"]]["װ������"] = 0
				JY.Thing[JY.Person[eid]["����"]]["װ���ȼ�"] = JY.Thing[JY.Person[eid]["����"]]["װ���ȼ�"] + 1
			end
		end		
	end
	
	--�߱�����
	if WAR.QBLL == 1 then
		dng = dng/2
    end	
    
	--�����Ƿ���������dngΪ0��ʾ��������
	ang = ang - dng
	if 0 < ang then
		dng = 0
	else
		dng = -ang
		ang = 0
	end
	
	--�������ܣ����ƾ��ұ��� �����ط�������Ϊ������ɱ��
	if (match_ID(eid, 27) or match_ID(eid,568)) and WAR.LQZ[eid] == 100 then
		dng = 1
	end	
	--�׺���
	if match_ID(eid, 497) and JLSD(20,70) and JY.Base["��������"] > 1  then
		Set_Eff_Text(enemyid,"��Ч����1","�׺���");
	   --WAR.Person[enemyid]["��Ч����1"] = "�׺���"
		WAR.Person[enemyid]["��Ч����"] = 144
		dng = 1
	end	
	
	--ɨ��  ��ɱ��
	if match_ID(eid, 114) then
		WAR.Person[enemyid]["��Ч����2"] = "��ض���"
		WAR.Person[enemyid]["��Ч����"] = 39
		dng = 1
	end
	--��Ħ ��ɱ��
	if match_ID(eid, 577) then
		dng = 1
	end	
	--�׽�����  ��ɱ��
	if Curr_NG(eid, 108) and JLSD(30,70,eid) then
		Set_Eff_Text(enemyid,"��Ч����1","�׽�����");
		WAR.Person[enemyid]["��Ч����"] = 39
		dng = 1
	end
	
	--����
	if match_ID(eid, 37) and Curr_NG(eid, 94) then
		Set_Eff_Text(enemyid,"��Ч����1","��������");
		WAR.Person[enemyid]["��Ч����"] = 89
		dng = 1
	end
	
	--������˫��50%���������ˣ���ɱ��
	for i = 1, JY.Base["�书����"] do
		if (JY.Person[eid]["�书" .. i] == 26 or JY.Person[eid]["�书" .. i] == 80) and JY.Person[eid]["�书�ȼ�" .. i] == 999 then
			WAR.GSWS = WAR.GSWS + 1
		end
	end
    
	if WAR.GSWS == 2 then
	   if Curr_NG(eid,204) or JLSD(20, 70, eid) then 	
	      dng = 1
		  WAR.Person[enemyid]["��Ч����"] = 10
		  Set_Eff_Text(enemyid,"��Ч����1","������˫")
	   end
    end
    
    if WAR.PD['���ϵ�������'][eid] ~= nil then 
        dng = 1
        Set_Eff_Text(enemyid,"��Ч����1","���˺�һ")
    end
    
	WAR.GSWS = 0
  
	--�˺�С�ڵ���30 �����ˣ���ɱ�� 
	if hurt <= 30 then
		dng = 1
	end
	 --������� 
	if match_ID(eid, 9983) and JY.Person[eid]["����"] < JY.Person[eid]["�������ֵ"]/2 then
		dng = 1
	end   
	--��̫������ɱ��
	if WAR.TJAY == 4 then
		dng = 1
	end
    
	WAR.TJAY = 0
    
	--�˺�С�ڵ���30 �����ˣ���ɱ�� 
	if hurt <= 30  then
		dng = 1
	end  
    
	--��ϵ���У����Ӿ�������
	if WAR.ASKD == 1 then
		dng = 0
	end
    
    if WAR.PD['�����'][pid] == 1 then 
        dng = 0
    end
	
	if WAR.ZDDH == 356 and WAR.PD['�����4'][pid] == 50 then 
		dng = 0
		--WAR.Person[enemyid]["��Ч����"] = 6
		--Set_Eff_Text(enemyid, "��Ч����0", "�����")
	end
		
	--������
	if WAR.BJYPYZ > 9 then
		dng = 0
	end
	--����У����Ӿ�������
	if WAR.JSTG == 1 then
		dng = 0
	end

	--�廨�룬���Ӿ������� 
	if WAR.PD["�廨��"][pid] ~= nil and WAR.PD["�廨��"][pid] > 0 then
		dng = 0
	end	
	--�ƾ����£����Ӿ�������
	if WAR.PJTX == 1 then
		dng = 0
	end
	--½���������������Ӿ�������
	if WAR.JGSL == 1 then
		dng = 0
	end
	--����������������Ӿ�������
	if WAR.QLJG == 1 then
		dng = 0
	end
	--���Ӿ�������
	if WAR.SL23 == 1 then
		dng = 0
	end	
	--��������+�������������Ӿ�������
	if WAR.ZWYJF == 1 then
		dng = 0
	end
	if WAR.JMZL == 2 then
	    dng = 0
	end
     if  WAR.DSP_LM1 == 1	then
	    dng = 0
	end	
	--����֮����ŭ�����Ӿ�������
	if WAR.LXZL10 == 1 then
		dng = 0
	end				
	--������14�飬��Ч���Ӿ�������
	if WAR.LWX == 1 then
		dng = 0
	end
	--÷����Ū3
	if WAR.MHSN == 3  then
	dng = 0
  end	
	--���������󾢳���11�������Ӿ�������
	if WAR.YYBJ > 11 then
		dng = 0
	end
	--��Ϣ�� �ݿ���
    if WAR.BHJTZ6 == 1 then
       dng = 0
    end	    
	
	--̫��֮��40%����
	if Curr_NG(eid, 102) and JLSD(20, 60, eid)  then
		WAR.TXZQ[eid] = 1
	end

	--½��60%���� �������� 
	if match_ID(eid, 497) and JLSD(20, 80, eid) and JY.Base["��������"] > 3 and WAR.SSESS[eid] ~= nil  then
		WAR.DZZ[eid] = 1
	end	

	--��ң�����ۻ�9�㣬δ�ж�ǰ���ᱻɱ��
	if WAR.XYYF[eid] and WAR.XYYF[eid] == 11 then
		dng = 1
	end

	
	--�����������˼���
	--��ȴ������������
	--�������в�������Ҳ������  	
	if (dng == 0 or WAR.YTML == 1) and hurt > 0 and DWPD() and myns(enemyid) == false then
		local n = 0;		--���˵���ֵ
		if inteam(eid) then		--�������˼���
			n = (hurt) / 10
		else
			n = (hurt) / 16
		end
		
		--�����ع��������˼ӱ�
		if match_ID(pid, 80) then
			n = n * 2
		end
	   
		--�������죬���ˣ���󡣬����-30%
		if Curr_NG(eid, 100) or Curr_NG(eid, 104) or Curr_NG(eid, 95) then
			n = n*0.7
		end
		
		--����Ǭ�����޺�������-60%
		if Curr_NG(eid, 97) or Curr_NG(eid, 96) then
			n = n*0.4
		end
		
		--װ���ڲ��£�1������-5��6������-10
		if JY.Person[eid]["����"] == 59 then
			n = n - 5 - 1*(JY.Thing[59]["װ���ȼ�"]-1)
		end

		n= math.modf(n)
		
    	WAR.Person[enemyid]["���˵���"] = (WAR.Person[enemyid]["���˵���"] or 0) + AddPersonAttrib(eid, "���˳̶�", n);
	end

	--�Ʒ�ɱ��������
	if dng == 0 and hurt > 0 and DWPD() then
		local killsq = 1

		
		local killjq = 0
        
		killjq = math.modf(ang / 15)

		--���˺�����ɱ����
		local spdhurt = 0
        
        local nd = JY.Base['�Ѷ�']
        
        if inteam(pid) == false then
            spdhurt = spdhurt + (nd-1)*hurt*0.15
        end
        
		if WAR.ZDDH == 356 and WAR.PD['�����4'][pid] == 50 then 
			spdhurt = spdhurt + 200
		end
		
		--�׶�����׷���˺�ɱ��
		if WAR.LDJT == 1 and DWPD() then
		   spdhurt = spdhurt + math.modf(hurt * 0.6)
		end
		
		--�������ɱ��
		if PersonKF(eid, 103) then
			spdhurt = math.modf(spdhurt * 0.5)
		end

		--���ѧ�˰˻Ĳ����˺�ɱ����
		if Curr_NG(eid, 101) then
			spdhurt = 0
		elseif PersonKF(eid, 101) then
			spdhurt = math.modf(spdhurt * 0.5)
		end
	
        killjq = killjq + spdhurt

        if WAR.PD['���ϵ�'][pid] == 1 then 
            WAR.PD['����'][pid] = (WAR.PD['����'][pid] or 0) + killjq
        end
        
        if Curr_NG(eid, 227) and WAR.Defup[eid] ~= nil and WAR.Defup[eid] > 0 then
            if WAR.Person[enemyid].TimeAdd < 0 then
                WAR.Person[enemyid].TimeAdd = 0
            end
			if JLSD(0,35,eid) then
				WAR.Person[enemyid].TimeAdd = WAR.Person[enemyid].TimeAdd + 100
				Set_Eff_Text(enemyid,"��Ч����1","�Ż�����")
			end
        elseif match_ID(eid,9988) and JLSD(20,50,eid)  then
		   WAR.Person[WAR.CurID].TimeAdd = WAR.Person[WAR.CurID].TimeAdd - killjq*0.5					   
		--½���������200����
		elseif WAR.DZZ[eid] ~= nil and WAR.DZZ[eid] == 1 then
			WAR.Person[enemyid].TimeAdd = WAR.Person[enemyid].TimeAdd + 200
			Set_Eff_Text(enemyid,"��Ч����1","��������")		
		--̫��֮�ᣬ�ѱ�ɱ�ļ���תΪ�Լ��ļ���ֵ
		elseif WAR.TXZQ[eid] ~= nil and WAR.TXZQ[eid] == 1 then
			WAR.Person[enemyid].TimeAdd = WAR.Person[enemyid].TimeAdd + killjq
			Set_Eff_Text(enemyid,"��Ч����1","̫��֮��")
        else
            WAR.Person[enemyid].TimeAdd = WAR.Person[enemyid].TimeAdd - killjq	
        end	 
	
		--̫��+���ƣ�����˸գ�50%���ʽ���ɱ��ת��Ϊ��Ѫ
		if YiRouKG(eid) and JLSD(20, 70, eid) then
			local heal = math.modf(killjq/3)
			WAR.Person[enemyid]["��������"] = (WAR.Person[enemyid]["��������"] or 0) + AddPersonAttrib(eid, "����", heal)
			Set_Eff_Text(enemyid,"��Ч����1","̫����������˸�")
			WAR.Person[enemyid]["��Ч����"] = 21
		end
		if WAR.ZDDH == 356 and WAR.PD['�����4'][eid] == 27 then 
			if WAR.Person[enemyid].TimeAdd < 0 then 
				WAR.Person[enemyid].TimeAdd = 0
			end
			WAR.Person[enemyid].TimeAdd = WAR.Person[enemyid].TimeAdd + 300
			WAR.Person[enemyid]["��Ч����"] = 6
			Set_Eff_Text(enemyid, "��Ч����0", "�����")
		end
	end
  
	--С��Ů�����������
	if match_ID(eid, 59) and JY.Person[eid]["����"] <= 0 then
		WAR.XK = 1
		WAR.XK2 = WAR.Person[enemyid]["�ҷ�"]
	end 

    
    --�żһԵ���Խ�ָ
	if JY.Person[pid]["����"] == 301 and DWPD() then
		local mb = 1
		if JY.Thing[301]["װ���ȼ�"] >=5 then
			mb = 3
		elseif JY.Thing[301]["װ���ȼ�"] >=3 then
			mb = 2
		end
		WAR.MBJZ[eid] = mb
	end

	
	--�޾Ʋ������Ż�����������͵����
	if WAR.TD == -2  and DWPD() then
		for i = 1, 4 do
			if 0 < JY.Person[eid]["Я����Ʒ����" .. i] and -1 < JY.Person[eid]["Я����Ʒ" .. i] then
				WAR.TD = JY.Person[eid]["Я����Ʒ" .. i]
				WAR.TDnum = JY.Person[eid]["Я����Ʒ����" .. i]
				JY.Person[eid]["Я����Ʒ����" .. i] = 0
				JY.Person[eid]["Я����Ʒ" .. i] = -1
				break
			end
		end
	else
		WAR.TD = -1
	end

	--Ѫ����Ѫ��1��5%��3��6%��5��7%
	--����100��
	
	if JY.Person[pid]["����"] == 44 then
		local bs = 0
		if JY.Thing[44]["װ���ȼ�"] >= 5 then
			bs = 2
		elseif JY.Thing[44]["װ���ȼ�"] >= 3 then
			bs = 1
		end
		local leech_rate = 0.05 + 0.01*bs
		if WAR.XDLeech < 100 then
			WAR.XDLeech = WAR.XDLeech + limitX(math.modf(hurt * leech_rate),0,100)
			if WAR.XDLeech > 100 then
				WAR.XDLeech = 100
			end
		end
	end
	--��ħ����Ѫ20%
	if Curr_NG(pid, 160)  then
		WAR.TMGLeech = WAR.TMGLeech + math.modf(hurt * 0.2)
	end	
	--Ѫ�ӣ�10%��Ѫ
	if PersonKF(pid, 163) then
		if WAR.XHSJ < 100 then
			WAR.XHSJ = WAR.XHSJ + limitX(math.modf(hurt * 0.1),0,100)
			if WAR.XHSJ > 100 then
				WAR.XHSJ = 100
			end
		end
	end
	
	--ΤһЦ��Ѫ10%������100��
	if match_ID(pid, 14) then
		if WAR.WYXLeech < 100 then
			WAR.WYXLeech = WAR.WYXLeech + limitX(math.modf((hurt) * 0.1),0,100)
			if WAR.WYXLeech > 100 then
				WAR.WYXLeech = 100
			end
		end
	end


	--��ɽͯ�� ������������+80
	if match_ID(eid, 117) and 0 < JY.Person[eid]["����"] then
		WAR.Person[enemyid]["��������"] = (WAR.Person[enemyid]["��������"] or 0) + AddPersonAttrib(eid, "����", 80);
	end


	--��Ӣ ɱ����
	if WAR.CY == 1 and DWPD() then
		WAR.Person[enemyid]["��������"] = (WAR.Person[enemyid]["��������"] or 0) + AddPersonAttrib(eid, "����", -300);
	end
	-- 
	if WAR.PD["��"][pid]~=nil and WAR.PD["��"][pid]== 1 and DWPD() then
		WAR.Person[enemyid]["��������"] = (WAR.Person[enemyid]["��������"] or 0) + AddPersonAttrib(eid,"����", -200)
   end
	--����������ɱ����
	if wugong == 33 and PersonKF(pid,175) then
		local neiliLoss = hurt
		WAR.Person[enemyid]["��������"] = (WAR.Person[enemyid]["��������"] or 0) + AddPersonAttrib(eid, "����", -neiliLoss);
	end

	--�ֻ�͵Ǯ
	if eid ~= 591 and match_ID(pid, 4) and JY.Person[eid]["����"] <= 0 and inteam(pid) and DWPD() then
		WAR.YJ = WAR.YJ + math.random(15) + 25
	end
	    
	--��а��Ŀ��100%MISS
	if WAR.KHBX == 2 and 0 < hurt and DWPD() then
       WAR.KHCM[eid] = 2
	end
  
    if WAR.PD['Ұ��ȭ'][pid] == 2 and 0 < hurt and DWPD() and math.random(100) <= 40 then
       WAR.KHCM[eid] = 2
	end

	--ȭ�����У��߼��ʷ�Ѩ
	if WAR.LXZQ == 1 and JLSD(25, 75, pid) and DWPD() then
		WAR.BFX = 1
	end
	if match_ID(pid,613) and wugong == 206 and JLSD(10,60,pid) and DWPD() then
       WAR.BFX = 1
	end	
	--�����黭֮�������������ط�Ѩ
	if WAR.QQSH3 == 1 and DWPD() then
		WAR.BFX = 1
	end
	
	--�������Ǵ��У��ط�Ѩ
	if WAR.GCTJ == 1 and DWPD() then
		WAR.BFX = 1
	end
	
	--һ��ָ50%���ʷ�Ѩ�������ж�
	if wugong == 17 and JLSD(30,80,pid) and DWPD() then
		WAR.BFX = 1
	end
	
	--ȭ��ָ��45%���ʷ�Ѩ
	if (WGLX == 1 or WGLX == 2) and JLSD(30, 75, pid) and DWPD() then
		WAR.BFX = 1
	end
    
    if wugong == 226 then 
        WAR.BFX = 1
    end
    
	--�߱�ָ��
	if JY.Person[pid]["����"] == 200 and JY.Thing[200]["װ���ȼ�"] == 6 and DWPD() then
		WAR.BFX = 1
	end			
	--�������бط�Ѩ
	if WAR.YTML == 1 then
		WAR.BFX = 1
	end	
	--��������ɢ�ֱط�Ѩ
	if match_ID(pid,635) and JY.Wugong[wugong]["�书����"] == 2 and DWPD() then
		WAR.BFX = 1
	end	
	--��������ɢ�ֱط�Ѩ
	if match_ID(pid,568) and wugong == 198 and DWPD() then
		WAR.BFX = 1
    end
    
    --Ѩ���Ѩ�ط�Ѩ
	if wugong == 201 and DWPD() then
        WAR.BFX = 1
	end
	
    if WAR.PD['���־�'][pid] == 1 and DWPD() then 
        WAR.BFX = 1
    end
    
	--ָ�����ǣ���ʼ15%��Ѩ�ʣ�ÿ��ָ��+5%
	if JY.Base["��׼"] == 2 and pid == 0 and DWPD() then
		local lxyz = 15
		for i = 1, JY.Base["�书����"] do
			if JY.Wugong[JY.Person[0]["�书" .. i]]["�书����"] == 2 and JY.Person[0]["�书�ȼ�" .. i] == 999 then
				lxyz = lxyz + 5
			end
		end
		if lxyz > 50 then
			lxyz = 50
		end
		if JLSD(30, 30 + lxyz, pid) then
			WAR.BFX = 1
		end
	end

	
	--�˺�С��50�޷�Ѩ��ȭ��ָ�������Ѩ��һ��ָ�߷�Ѩ������30%���ʷ�Ѩ
	--��ȴ�������߷�Ѩ
	if DWPD() and 50 <= hurt and (WAR.BFX == 1 or JLSD(30, 60, pid)) and myfx(enemyid) == false then
		--�޾Ʋ�����ʹ�÷ֶκ���
		local fxz = 1;
		if hurt >= 50 and hurt < 100 then
			fxz = fxz + math.modf((hurt - 50)/10)
		elseif hurt >= 100 and hurt <= 200 then
			fxz = math.modf((hurt - 50)/10) + math.random(3)
		elseif hurt > 200 then
			fxz = math.modf(hurt/15) + 5 + math.random(3)
		end
		--��Ѩ����
		if inteam(pid) then
			fxz = math.modf(fxz *0.4)
		else
			fxz = math.modf(fxz *0.6)
		end
        
		if match_ID(pid, 511) then 
			fxz = fxz + 10
		end
		
        if WAR.PD['���־�'][pid] == 1 then 
            fxz = fxz + 10
        end
		--���˻�Ԫ����ɵķ�ѨЧ�����20%
		--�����
		if Curr_NG(pid, 90) or match_ID(pid,189) then
			fxz = math.modf(fxz *1.2)
		--������Ԫ����ɵķ�ѨЧ�����10%
		elseif PersonKF(pid, 90) then
			fxz = math.modf(fxz *1.1)
		end
		--����ֹ�ܷ�Ѩ����
		if match_ID(eid, 616) then
			fxz = math.modf(fxz *0.5)
		end
		--ʥ���ܷ�Ѩ����
		if Curr_NG(eid, 93) then
			fxz = math.modf(fxz *0.5)
		end

		--Ǭ���ܷ�Ѩ����
		if Curr_NG(eid, 97) then
			fxz = math.modf(fxz *0.5)
		end
			   
        if PersonKF(eid, 190) then
			fxz = math.modf(fxz *0.5)
		end
		--һέ�ɽ�
		if Curr_QG(eid,186) then
		    fxz = math.modf(fxz *0.5)
		end
		--װ����˿���ģ�1����Ѩ-5��6����Ѩ-10
		if JY.Person[eid]["����"] == 60 then
			fxz = fxz - 5 - 1*(JY.Thing[60]["װ���ȼ�"]-1)
		end
        
        if PersonKF(eid, 226) then
            fxz = fxz - 10
		end
		
        if PersonKF(eid, 104) then
            fxz = fxz - 10
		end
		
		if fxz < 0 then
			fxz = 0
		end
		if fxz > 0 then
			--��Һ�NPCһ������
			if WAR.FXDS[eid] == nil then
				WAR.FXDS[eid] = fxz
			else
				WAR.FXDS[eid] = WAR.FXDS[eid] + fxz
			end
			WAR.FXXS[eid] = 1
			--��Ѩ����50��
			if 50 < WAR.FXDS[eid] then
				WAR.FXDS[eid] = 50
			end
		end
	end
    
	if match_ID(eid, 511) and DWPD() and myfx(WAR.CurID) == false then
		WAR.FXDS[pid] = limitX((WAR.FXDS[pid] or 0) + 10,0,50)
		WAR.FXXS[pid] = 1
	end
		
    if WAR.PD['Ұ��ȭ'][pid] == 2 and 0 < hurt and DWPD() and myfx(enemyid) == false then
        local lx = WAR.LXZT[eid] or 0
        if lx >= 25 then 
			WAR.LXXS[eid] = nil
            WAR.FXDS[eid] = limitX((WAR.FXDS[eid] or 0) + lx,0,50)
            WAR.LXZT[eid] = nil
            WAR.FXXS[eid] = 1
            Set_Eff_Text(enemyid,"��Ч����1","��Ѫ��Ѩ")
        end    
	end
    
	WAR.BFX = 0
	
	--for g = 1, 9 do
	--	if match_ID(pid, glxp[g]) and JLSD(30, 70, pid) then
	--		WAR.BLX = 1
	--	end
	--end
	  
	--���콣������Ѫ
	--1��70%������Ѫ
	--4����ʼ׷������
	if JY.Person[pid]["����"] == 37 then
		if JLSD(0, 40 + JY.Thing[37]["װ���ȼ�"] * 10, pid) then
			WAR.BLX = 1
		end
	end
	--����������Ѫ
	--1��70%������Ѫ
	if JY.Person[pid]["����"] == 320 then
		if JLSD(0, 40 + JY.Thing[320]["װ���ȼ�"] * 10, pid) then
			WAR.BLX = 1
		end
	end	
	--���ũװ����������������Ѫ
	if JY.Person[pid]["����"] == 202 and match_ID(pid, 72) then
		WAR.BLX = 1
	end
	--½��˫������Ѫ
	if  match_ID(pid, 580) then
		WAR.BLX = 1
	end	
	--�������Ѫ
	if match_ID(pid, 90) then
		WAR.BLX = 1
	end
	
	--��������45%������Ѫ
	if (WGLX == 3 or WGLX == 4) and JLSD(30, 75, pid) then
		WAR.BLX = 1
	end
	
	--���鵶����Ч������Ѫ
	if WAR.CMDF == 1 then
		WAR.BLX = 1
	end
	
	--����Ѫ�����������Ѫ
	if Curr_NG(pid, 163) then
		WAR.BLX = 1
	end
	
	--�������б���Ѫ
	if WAR.YTML == 1 then
		WAR.BLX = 1
	end
	--��צ�ֱ���Ѫ
	if wugong == 20 and DWPD() then
	   WAR.BLX = 1
	end  
	--��Ѫ��צ����Ѫ
	if wugong == 134 and DWPD() then
		WAR.BLX = 1
    end
    -- Ѫս�˷�
 	if WAR.XZBF == 1 and DWPD() then
	   WAR.BLX = 1
	end
	--�廨�����Ѫ
    if JY.Person[pid]["����"] == 349  then   
       WAR.BLX = 1
	end
    if WAR.PD['Ұ��ȭ'][pid] == 2 then
       WAR.BLX = 1
	end
	--װ�����콣����������һ����Ч�����ű������У�����Ѫ������30%������Ѫ
	--��������6����˿������Ѫ  ���ϳ�����
	if hurt > 30 and DWPD() and (JY.Person[eid]["����"] == 239 and JY.Thing[239]["װ���ȼ�"] == 6) == false 
		and (Curr_NG(eid,183)) == false  and (PersonKF(eid, 160)) == false
		and (WAR.L_TLD == 1 or WAR.BLX == 1 or WAR.GCTJ == 1 or JLSD(30, 60, pid)) then
			if WAR.LXZT[eid] == nil then
				WAR.LXZT[eid] = math.modf((hurt) / 10)
			else
				WAR.LXZT[eid] = WAR.LXZT[eid] + math.modf((hurt) / 10)
			end
			WAR.LXXS[eid] = 1
			if 100 < WAR.LXZT[eid] then
				WAR.LXZT[eid] = 100
			end
	end
   
	WAR.BLX = 0
	
	--������� 
    -- ���ھ����ر���
	if JY.Wugong[wugong]["����ϵ��"] == 1 and ((PersonKF(pid, 107) and (JY.Person[pid]["��������"] == 0 or JY.Person[pid]["��������"] == 3)) or JLSD(10,90,pid)) then
		WAR.BBF = 1
	end
	-- �������� �ر���
	if PersonKF(pid,216) or match_ID(pid,9978) then
		WAR.BBF = 1
    end	
	--�ֳ�Ӣ�����ѩ
	if WAR.LFHX == 1 then
		WAR.BBF = 1
	end
	
	--�����黭����ʵ�����Ч
	if WAR.QQSH2 >= 1 then
		WAR.BBF = 1
	end
	
	--���｣������һ�����60%����
	if wugong == 38 and TaohuaJJ(pid) and JLSD(20,80,pid) then
		WAR.BBF = 1
	end
	
	--�����������ģ��߼��ʱ���
	if (match_ID(pid, 22) or match_ID(pid, 42)) and JLSD(10,90,pid) then
		WAR.BBF = 1
	end
	--��һ����������
	if match_ID(pid,633) and JY.Person[pid]["����"] == 45 then
		WAR.BBF = 1
	end		
	--�������бر���
	if WAR.YTML == 1 then
		WAR.BBF = 1
	end
	--����ر���
	if match_ID(pid,582) then
		WAR.BBF = 1
	end	
    --������2	
	if WAR.BHJTZ1== 1 then
		WAR.BBF = 1
	end		

	--���ռ���
	--���ھ���������
	if JY.Wugong[wugong]["����ϵ��"] == 1 and ((PersonKF(pid, 106) and ( JY.Person[pid]["��������"] == 1 or JY.Person[pid]["��������"] == 3)) or JLSD(10,90,pid)) then
		WAR.BZS = 1
	end
	--ʥ������
	if match_ID(pid,9992) or wugong == 93 then
		WAR.BZS = 1
    end
    if WAR.PD['����'][pid] == 1 then 
        WAR.BZS = 1
    end
	--���˷���ţ��������߼�������
	if (match_ID(pid, 3) or match_ID(pid, 23) or match_ID(pid, 41)) and JLSD(10,90,pid) then
		WAR.BZS = 1
	end
	
	--�������б�����
	if WAR.YTML == 1 then
		WAR.BZS = 1
	end
    -- ��������1 ��ɽ������
    if WAR.DSP_LM2 == 1 or wugong == 8 then
      	WAR.BZS = 1
	end
	--���������
	if match_ID(pid,508) then
		WAR.BZS = 1
    end
	--���ٱ�����
	if match_ID(pid,578) and  JY.Person[pid]["��������"] == 1 then
		WAR.BZS = 1
	end	
	--�������� ��
	if WAR.PD["��"][pid] ~= nil and WAR.PD["��"][pid] == 1 then
	  WAR.BZS = 1
    end
    --������1	
	if WAR.BHJTZ1== 1 then
        WAR.BZS = 1
	end	
	
    -- ����
 	if match_ID(pid,581) then
		WAR.BZS = 1
	end   	

    --����
    if WAR.BZS == 1 and PersonKF(pid, 203) then
        WAR.BBF = 1
    elseif WAR.BBF == 1 and PersonKF(pid, 203) then
        WAR.BZS = 1
    end
    
	--��ȴ������������
	if hurt > 30 and DWPD() and WAR.BZS == 1 and myzs(enemyid) == false then
		local zsz = math.modf(hurt / 15)
		--if zsz > 20 then
			--zsz = 20
	    --end
	--װ�����ļף�1������-50%��6����������
		if JY.Person[eid]["����"] == 62 then
			local kz = 0.5 + 0.1 * (JY.Thing[62]["װ���ȼ�"]-1)
			zsz = math.modf(zsz *(1-kz))
		end
	
	--��Ů����������-50%
		if PersonKF(eid, 154) then
			zsz = math.modf(zsz / 2)
		end
		if zsz > 0 then
			--JY.Person[eid]["���ճ̶�"] = JY.Person[eid]["���ճ̶�"] + zsz
			AddPersonAttrib(eid,'���ճ̶�',zsz)
			WAR.ZSXS[eid] = 1
			--if 100 < JY.Person[eid]["���ճ̶�"] then
			--	JY.Person[eid]["���ճ̶�"] = 100
			--end
		end
	end
	
	WAR.BZS = 0

	--��ȴ���� �������� ���߱���
	if hurt > 30 and DWPD() and WAR.BBF == 1 and mybf(enemyid) == false then
		local bfz = math.modf(hurt / 15)
		--�����黭����ʵ�����Ч��ɽ�续
		if WAR.QQSH2 == 2 then
			bfz = bfz * 2
		end
		--װ��Ƥ�£�1������-50%��6�����߱���
		if JY.Person[eid]["����"] == 63 then
			local kh = 0.5 + 0.1 * (JY.Thing[63]["װ���ȼ�"]-1)
			bfz = math.modf(bfz *(1-kh))
		end
		
		--��������������-50%
		if PersonKF(eid, 99) then
			bfz = math.modf(bfz / 2)
		end
		if bfz > 0 then
			--JY.Person[eid]["����̶�"] = JY.Person[eid]["����̶�"] + bfz
			AddPersonAttrib(eid,'����̶�',bfz)
			WAR.BFXS[eid] = 1
			--if 100 < JY.Person[eid]["����̶�"] then
			--	JY.Person[eid]["����̶�"] = 100
			--end
		end
	end
	
	WAR.BBF = 0
    
	--�������������
	if WAR.PD["�������"][pid]~= nil  then
		if WAR.PD["̫������"][eid] ~= nil and  WAR.PD["̫������"][eid] > 0 then
			 WAR.PD["̫������"][eid]  =  nil
		end
		if WAR.PD["��Ϣ����"][eid] ~= nil and  WAR.PD["��Ϣ����"][eid] > 0 then
			 WAR.PD["��Ϣ����"][eid]  =  nil
		end
		if WAR.PD["�������"][eid] ~= nil and  WAR.PD["�������"][eid] > 0 then
			 WAR.PD["�������"][eid]  =  nil
		end	      
    end
	
	--ŭ��ֵ���㣬��ת���Ʋ���ŭ��ָ�����в���ŭ
	if 0 < JY.Person[eid]["����"] and hurt > 0 and (WAR.LQZ[eid] == nil or WAR.LQZ[eid] < 100) and WAR.Person[enemyid]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.DZXY ~= 1 and WAR.LXYZ ~= 1 then
		local lqzj = math.modf((hurt) / 6 + 1)
		lqzj = math.random(lqzj, lqzj+10)
		
		--�����Ѷ��¶������ӵ�ŭ��ֵ
		if WAR.Person[enemyid]["�ҷ�"] == false then
			local flqzj = 0
			if JY.Base["�Ѷ�"] == 1 then
				flqzj = 2
			elseif JY.Base["�Ѷ�"] == 2 then
				flqzj = 5
			else
				flqzj = 8 + JY.Base["�Ѷ�"]
			end
			lqzj = lqzj + flqzj;
		end
		
		if lqzj < 10 then 
			lqzj = 10 
		end	
        
		--��ң�α�������������ŭ��ֵ20
		if Curr_QG(eid,2) 	and WAR.Weakspot[eid] ~= nil and WAR.Person[enemyid].Time >= -200 and WAR.Person[enemyid].Time <= 200 then
			lqzj = lqzj+ 20
	    end
        
        if Curr_NG(pid, 102) then 
            lqzj = math.modf(lqzj/2)
        end
        
		--��ľ�ɷ�
        if WAR.PD['���ϵ�'][pid] == 3 then
        --̫��֮�أ�����ŭ    
        elseif WAR.TXZZ == 1 then
		--�����黭֮�����ٲ���ŭ
		elseif WAR.QQSH1 > 0 then
		else
			if WAR.LQZ[eid] == nil then
				WAR.LQZ[eid] = lqzj + 2
			else
				WAR.LQZ[eid] = WAR.LQZ[eid] + lqzj + 2
			end
		end
		  
		if WAR.LQZ[eid] ~= nil and WAR.LQZ[eid] <= 0 then
			WAR.LQZ[eid] = nil;
		end
    end
	--�������ڱ�������״̬�²��ᱻ��ŭ
		if not (match_ID(eid, 129) and WAR.BDQS > 0) then
			--ָ��������һ��ŭ
			if WAR.LXYZ == 1 and DWPD() and WAR.LQZ[eid] ~= nil then
				WAR.LQZ[eid] = math.modf(WAR.LQZ[eid] * 0.5)
			end
		end
        
		--ŭ������
		if WAR.LQZ[eid] ~=  nil and 100 < WAR.LQZ[eid] then
			WAR.LQZ[eid] = 100
			--�������ܣ������ط�������Ϊ��
			if match_ID(eid, 27) then
				WAR.Person[enemyid]["��Ч����"] = 7
				Set_Eff_Text(enemyid,"��Ч����1","�����ط�������Ϊ��");
			else
				WAR.Person[enemyid]["��Ч����"] = 6
				Set_Eff_Text(enemyid,"��Ч����1","ŭ������");
	        end	
        end		
        
    if WAR.PD['���ϵ�'][pid] == 3 then
        if WAR.LQZ[eid] == 100 then 
            WAR.HMZT[eid] = 1
        end
        if WAR.LQZ[eid] ~= nil then 
            WAR.LQZ[eid] = WAR.LQZ[eid] - 20
        end
    end
    
    --��ڤ��ŭ����ת������   
	if XiaoYaoYF(pid) and PersonKF(pid,85) and WAR.DZXY ~= 1 and WAR.LQZ[eid] ~= nil and DWPD() and JLSD(25, 40 + math.modf(JY.Person[pid]["ʵս"]/25), pid) then
		local lq = WAR.LQZ[eid] or 0
		if lq >= 10 then 
			WAR.BMSGXL = WAR.BMSGXL + 10
			WAR.LQZ[eid] = WAR.LQZ[eid] - 10
		else 
			WAR.BMSGXL = WAR.BMSGXL + lq
			WAR.LQZ[eid] = 0
		end
		Set_Eff_Text(enemyid,"��Ч����1","��ڤ.����ɽ��");
	end				
    
		--����������һ��ŭ
	if WAR.QQSH1 == 2 and DWPD() and WAR.LQZ[eid] ~= nil then
		WAR.LQZ[eid] = math.modf(WAR.LQZ[eid] * 0.5)
	end
		
		--����̫��֮��ʱ���з��Ѿ���ŭ�Ļ������м�����ŭ��
	if WAR.TXZZ == 1 and WAR.LQZ[eid] ~= nil and WAR.LQZ[eid] == 100  and JLSD(20,45+JY.Person[pid]["ʵս"]/20) then
		WAR.LQZ[eid] = WAR.LQZ[eid] - 20
		Set_Eff_Text(enemyid,"��Ч����1","���Իӽ�.��������");
	end
    
    --��ֹŭ��С��0
    if WAR.LQZ[eid] ~= nil and WAR.LQZ[eid] < 0 then 
        WAR.LQZ[eid] = 0
    end
    
	if DWPD() and ZhongYongZD(eid) and WAR.LQZ[eid] == 100 then
		--if JLSD(20,40+JY.Base["��������"]*0.5,eid) or WAR.LQZ[eid] == 100 then
		WAR.Person[enemyid]["��Ч����"] = 6
		Set_Eff_Text(enemyid, "��Ч����0", "��ӹ֮��")
        Cat('���̳���',enemyid)
		WAR.ACT = 10
			--������ɶ�ת�����ģ��򲻴������
		--if WAR.DZXY == 0 then
		WAR.ZYHB = 0
		--end
	end	
    
	--�ɲ��� ������� ��ɱ
	if WAR.ZDDH == 205 and eid == 141 then
		WAR.Person[enemyid]["��������"] = -JY.Person[eid]["����"];
		JY.Person[eid]["����"] = 0
	end

	--������ �������� ��ɱ
	if WAR.ZDDH == 279 and eid == 632 then
		WAR.Person[enemyid]["��������"] = -JY.Person[eid]["����"];
		JY.Person[eid]["����"] = 0
	end
  
	--���ƣ��߻����������12~15��
	if wugong == 13 and JLSD(30, 90, pid) and DWPD() and myns(enemyid) == false then
		WAR.Person[enemyid]["���˵���"] = (WAR.Person[enemyid]["���˵���"] or 0) + AddPersonAttrib(eid, "���˳̶�", math.random(12, 15));
	end
    
    if WAR.PD['Ұ��ȭ'][pid] == 1 and myns(enemyid) == false then 
        WAR.Person[enemyid]["���˵���"] = (WAR.Person[enemyid]["���˵���"] or 0) + AddPersonAttrib(eid, "���˳̶�", math.random(15, 20));
    end
    
	--����ͻ�Ԫһ��
	if WAR.HYYQ == 1 and DWPD() and myns(enemyid) == false then 
		WAR.Person[enemyid]["���˵���"] = (WAR.Person[enemyid]["���˵���"] or 0) + AddPersonAttrib(eid, "���˳̶�", math.random(10, 15));  
	end
    
	--��ħ�����������10~15��
	if JY.Person[pid]["����"] == 323 and JY.Thing[323]["װ���ȼ�"] >= 2 and JLSD(0, 50+(JY.Thing[323]["װ���ȼ�"]-1)*10, pid) and DWPD() and myns(enemyid) == false then
		WAR.Person[enemyid]["���˵���"] = (WAR.Person[enemyid]["���˵���"] or 0) + AddPersonAttrib(eid, "���˳̶�", math.random(10, 15));
	end	
    
	--���� �������� ׷��10-15������
	if WAR.XC_WLCZ== 1 and DWPD() and myns(enemyid) == false then
        local ns = 10 + math.random(1, 5) 
        WAR.Person[enemyid]["���˵���"] = (WAR.Person[enemyid]["���˵���"] or 0) + AddPersonAttrib(eid, "���˳̶�", ns);
	end
        
    if Curr_NG(eid, 227) and WAR.Defup[eid] ~= nil and WAR.Defup[eid] > 0 then
        WAR.Person[WAR.CurID]["���˵���"] = (WAR.Person[WAR.CurID]["���˵���"] or 0) + AddPersonAttrib(pid, "���˳̶�", 15);
    end
    
	--����ȭ�������������17��
	if WAR.YZQS == 1 and DWPD() and myns(enemyid) == false then
		local ns = 17
		--лѷ�������+7
		if match_ID(pid, 13) then
			ns = ns + 7
		end
		WAR.Person[enemyid]["���˵���"] = (WAR.Person[enemyid]["���˵���"] or 0) + AddPersonAttrib(eid, "���˳̶�", ns);
		--���Լ�����ֵ����5000ʱ�����ܵ�����
		if JY.Person[pid]["����"] < 5000 then
			WAR.Person[WAR.CurID]["���˵���"] = (WAR.Person[WAR.CurID]["���˵���"] or 0) + AddPersonAttrib(pid, "���˳̶�", 7);
		end
	end
    
	if (WAR.BMXH == 1 or WAR.BMXH == 2 ) and 0 < hurt and DWPD() then
		local xnl = nil
		xnl = math.modf(JY.Person[eid]["����"] * 0.07)
		if xnl > 300 then
			xnl = 300
		end
		--��֤���ᱻ��
		if match_ID(eid,149) then
			xnl = 0
		end
		WAR.Person[enemyid]["��������"] = (WAR.Person[enemyid]["��������"] or 0) + AddPersonAttrib(eid, "����", -xnl);
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", xnl)
		
        if isteam(pid) then
            AddPersonAttrib(pid, "�������ֵ", xnl * 10)
        end    
		--���������ӷ�����ڤʱ��ȡ����
		if WAR.BMXH == 1 and match_ID(pid, 116) and pid == 0 then
			AddPersonAttrib(pid, "������", 2)
			AddPersonAttrib(pid, "������", 2)
			AddPersonAttrib(pid, "�Ṧ", 2)
		end
	end

     -- ��ң�� ÷����Ū2
	if WAR.MHSN == 2 and WAR.ACT == 1 and DWPD()then 
        local xnl = nil
        xnl = math.modf(JY.Person[eid]["����"] * 0.05)
        --��֤���ᱻ��
        if match_ID(eid,149) then
            xnl = 0
        end  
        WAR.Person[enemyid]["��������"] = AddPersonAttrib(eid, "����", -xnl);
	end
    
	--������ �϶� ������
	if WAR.BMXH == 3 and 0 < hurt and DWPD() then
		local xnl = nil
		xnl = math.modf(JY.Person[eid]["����"] * 0.05)
		if xnl < 100 then
			xnl = 100
		elseif xnl > 300 then
			xnl = 300
		end
		--��֤���ᱻ��
		if match_ID(eid,149) then
			xnl = 0
		end
		WAR.Person[enemyid]["��������"] = AddPersonAttrib(eid, "����", -xnl);
	end
  
	--���Ǵ󷨣�һ������3-4����
	if WAR.BMXH == 2 and 0 < hurt and DWPD() then
		local xt1 = 3 + Rnd(2)
		local n = AddPersonAttrib(eid, "����", -xt1)
		local m = AddPersonAttrib(pid, "����", xt1)
		
		--������ ������3����
		if match_ID(pid, 26) then
			n = n + AddPersonAttrib(eid, "����", -3)
			m = m + AddPersonAttrib(pid, "����", 3)
		end

		WAR.Person[enemyid]["��������"] = (WAR.Person[enemyid]["��������"] or 0) + n;
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + m;
	end

	--���˱�ڤ����Ҳ����
	if Curr_NG(eid, 85) and 0 < hurt and DWPD() and JLSD(20,70,eid) then
		local xnl = 200
		--��֤���ᱻ��
		if match_ID(pid,149) then
			xnl = 0
		end
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", -xnl)
		WAR.Person[enemyid]["��������"] = (WAR.Person[enemyid]["��������"] or 0) + AddPersonAttrib(eid, "����", xnl)
		AddPersonAttrib(eid, "�������ֵ", 2000)
		WAR.Person[enemyid]["��Ч����"] = 63
		Set_Eff_Text(enemyid,"��Ч����1","�ٴ��뺣");
	end
	
	--�������ǰ���Ҳ����
	if Curr_NG(eid, 88) and 0 < hurt and DWPD() and JLSD(20,70,eid) then
		local xnl = 200
		--��֤���ᱻ��
		if match_ID(pid,149) then
			xnl = 0
		end
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", -xnl)
		WAR.Person[enemyid]["��������"] = (WAR.Person[enemyid]["��������"] or 0) + AddPersonAttrib(eid, "����", xnl/2)
		AddPersonAttrib(eid, "�������ֵ", 1000)
		WAR.Person[enemyid]["��Ч����"] = 71
		Set_Eff_Text(enemyid,"��Ч����1","��������");
	end
	
	--���˻�������Ҳ����+�϶�
	if Curr_NG(eid, 87) and 0 < hurt and DWPD() and JLSD(20,70,eid) then
		local xnl = 200
		--��֤���ᱻ��
		if match_ID(pid,149) then
			xnl = 0
		end
        WAR.Person[WAR.CurID]["�ж�����"] = AddPersonAttrib(pid, "�ж��̶�", math.random(10,15))
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", -xnl)
		WAR.Person[enemyid]["��Ч����"] = 64
		Set_Eff_Text(enemyid,"��Ч����1","������");
	end

        	
	--���������������е�
	if WAR.TZ_XZ == 1 and DWPD() then
		WAR.TZ_XZ_SSH[eid] = 1
	end
  
	if hurt > 0 and DWPD() then
		--�ж�����
		local poisonnum = math.modf(JY.Wugong[wugong]["�����ж�����"] + JY.Person[pid]["��������"])
        
		local kd = JY.Person[eid]["��������"] + JY.Person[eid]["����"] / 50
        
        if WAR.PD['��������'][eid] ~= nil then 
            kd = kd + WAR.PD['��������'][eid]
        end
        
		--�������׹�צ���ӵ��˶���
		if match_ID(pid, 631) and wugong == 11 then
			kd = 0
		end
        
		poisonnum = math.modf((poisonnum - kd) / 4)
        
        --������ �϶� ������
        if WAR.BMXH == 3 then
            --WAR.Person[enemyid]["�ж�����"] = AddPersonAttrib(eid, "�ж��̶�", math.random(16,20))
            poisonnum = poisonnum + math.random(16,20)
        end

        --ŷ���棬�����ж�+30
        if match_ID(pid, 60) then
            poisonnum = poisonnum + 30
            --WAR.Person[enemyid]["�ж�����"] = (WAR.Person[enemyid]["�ж�����"] or 0) + AddPersonAttrib(eid, "�ж��̶�", 30)
        end
	
        --��������
        if JY.Person[pid]["����"] == 244 then
            local sz = 10 + 5 * (JY.Thing[244]["װ���ȼ�"]-1)
            poisonnum = poisonnum + sz
            --WAR.Person[enemyid]["�ж�����"] = (WAR.Person[enemyid]["�ж�����"] or 0) + AddPersonAttrib(eid, "�ж��̶�", sz)
        end
	
        --�����������ǿ���϶�
        if (wugong == 3 or wugong == 120 or wugong == 5 or wugong == 21 or wugong == 118) and ZiqiTL(pid) then
            poisonnum = poisonnum + math.random(20,30)
            --WAR.Person[enemyid]["�ж�����"] = (WAR.Person[enemyid]["�ж�����"] or 0) + AddPersonAttrib(eid, "�ж��̶�", math.random(20,30))
        end
	
        --�������ƣ�ǿ���϶�20
        if WAR.WD_CLSZ == 1 then
            poisonnum = poisonnum + 20
            --WAR.Person[enemyid]["�ж�����"] = (WAR.Person[enemyid]["�ж�����"] or 0) + AddPersonAttrib(eid, "�ж��̶�", 20)
        end
        
        --�嶾�澭��ǿ���϶�20
        if PersonKF(pid,220) then
            poisonnum = poisonnum + 30
            --WAR.Person[enemyid]["�ж�����"] = (WAR.Person[enemyid]["�ж�����"] or 0) + AddPersonAttrib(eid, "�ж��̶�", 30)
        end
	
        --���ũ���ֻ��ļӳɣ��ж�+5 + ���15
        if match_ID(pid, 72) then
            for j = 0, WAR.PersonNum - 1 do
                if match_ID(WAR.Person[j]["������"],4) and WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[WAR.CurID]["�ҷ�"] then
                    poisonnum = poisonnum + 5 + math.random(15)
                    --WAR.Person[enemyid]["�ж�����"] = (WAR.Person[enemyid]["�ж�����"] or 0) + AddPersonAttrib(eid, "�ж��̶�", 5 + math.random(15));
                    break
                end
            end
        end
        
		if poisonnum < 0 then
			poisonnum = 0
		end
        
		if myzd(enemyid) == false then
			WAR.Person[enemyid]["�ж�����"] = (WAR.Person[enemyid]["�ж�����"] or 0) + AddPersonAttrib(eid, "�ж��̶�", math.modf(myrnd(poisonnum)))
		end
	end
	
	--��֪�������
	if eid == -1 then
		local x, y = nil, nil
		while true do
			x = math.random(63)
			y = math.random(63)
			if not SceneCanPass(x, y) or GetWarMap(x, y, 2) < 0 then
				SetWarMap(WAR.Person[enemyid]["����X"], WAR.Person[enemyid]["����Y"], 2, -1)
				SetWarMap(WAR.Person[enemyid]["����X"], WAR.Person[enemyid]["����Y"], 5, -1)
                SetWarMap(WAR.Person[enemyid]["����X"], WAR.Person[enemyid]["����Y"], 10, -1)
				WAR.Person[enemyid]["����X"] = x
				WAR.Person[enemyid]["����Y"] = y
				SetWarMap(WAR.Person[enemyid]["����X"], WAR.Person[enemyid]["����Y"], 2, enemyid)
				SetWarMap(WAR.Person[enemyid]["����X"], WAR.Person[enemyid]["����Y"], 5, WAR.Person[enemyid]["��ͼ"])
                SetWarMap(WAR.Person[enemyid]["����X"], WAR.Person[enemyid]["����Y"], 10, JY.Person[WAR.Person[enemyid]["������"]]['ͷ�����'])
				break;
			end
		end
	end
  
	--�ж��Ƿ���Լ�ʵս
	if JY.Person[eid]["����"] <= 0 and inteam(pid) and DWPD() and WAR.SZJPYX[eid] == nil and JY.Person[pid]["ʵս"] < 500 then
		--�����ս����������ջɱŷ���ˡ�������������ȫ����������������������������   ����ʵս
		local wxzd = {17, 67, 226, 220, 224, 219, 79}
		local wx = 0
		for i = 1, 7 do
			if WAR.ZDDH == wxzd[i] then
				wx = 1
			end
		end
		
		--ؤ���ſ�
		if WAR.ZDDH == 82 and GetS(10, 0, 18, 0) == 1 then
			wx = 1
		end
		--ľ����
		if WAR.ZDDH == 214 and GetS(10, 0, 19, 0) == 1 then
			wx = 1
		end
		
		--����ɼ�ʵս
		if wx == 0 and inteam(pid) then
			local szexp = 1
			if eid < 191 and 0 < eid then
				szexp = WARSZJY[eid]
			end
			JY.Person[pid]["ʵս"] = JY.Person[pid]["ʵս"] + szexp
			if JY.Person[pid]["ʵս"] > 500 then
				JY.Person[pid]["ʵս"] = 500
			end
			WAR.SZJPYX[eid] = 1
		end
	end
	
	--����������
	if JY.Person[eid]["����"] <= 0 and PersonKF(eid, 203) and WAR.PD['�������'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.Person[enemyid]["��Ч����"] = 89
		WAR.Person[enemyid]["��Ч����3"] = "������������"
		local modifier = 0.6+JY.Base["��������"]*0.01
		--���� ����
		if match_ID(eid, 37) or match_ID(eid, 578) then
			modifier = 1
		--���˳���
		elseif Curr_NG(eid, 203) then
			modifier = 1
		end
		JY.Person[eid]["����"] = math.modf(JY.Person[eid]["�������ֵ"]*modifier)
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + math.modf((JY.Person[eid]["�������ֵ"]-JY.Person[eid]["����"])*modifier)
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + math.modf((100 - JY.Person[eid]["����"])*modifier)
		JY.Person[eid]["�ж��̶�"] = JY.Person[eid]["�ж��̶�"]-math.modf(JY.Person[eid]["�ж��̶�"]*modifier)
		JY.Person[eid]["���˳̶�"] = JY.Person[eid]["���˳̶�"]-math.modf(JY.Person[eid]["���˳̶�"]*modifier)
		JY.Person[eid]["����̶�"] = JY.Person[eid]["����̶�"]-math.modf(JY.Person[eid]["����̶�"]*modifier)
		JY.Person[eid]["���ճ̶�"] = JY.Person[eid]["���ճ̶�"]-math.modf(JY.Person[eid]["���ճ̶�"]*modifier)
        if match_ID(eid, 129) then
            WAR.LQZ[eid] = 100
            --�������ǵ������������������ӣ�NPC�̶�Ϊ7
            if eid == 0 then
                WAR.BDQS = math.modf(JY.Base["��������"]/2)
            else
                WAR.BDQS = 7
            end
            
            WAR.Person[enemyid]["��Ч����"] = 115
            WAR.Person[enemyid]["��Ч����3"] = "�������� �۽���̬"
            
        end
		--��Ѫ
		if WAR.LXZT[eid] ~= nil then
			WAR.LXZT[eid] = WAR.LXZT[eid]-math.modf(WAR.LXZT[eid]*modifier)
			if WAR.LXZT[eid] < 1 then
				WAR.LXZT[eid] = nil
				WAR.LXXS[eid] = nil
			end
		end
		--��Ѩ
		if WAR.FXDS[eid] ~= nil then
			WAR.FXDS[eid] = WAR.FXDS[eid]-math.modf(WAR.FXDS[eid]*modifier)
			if WAR.FXDS[eid] < 1 then
				WAR.FXDS[eid] = nil
				WAR.FXXS[eid] = nil
			end
		end				
		WAR.Person[enemyid].Time = WAR.Person[enemyid].Time + 500
		WAR.FUHUOZT[eid] = 1
        WAR.PD['�������'][eid] = 1
		--���� ����
		if match_ID(eid, 37) or match_ID(eid, 578) then
			WAR.Person[enemyid].Time = 990
		end
		if WAR.Person[enemyid].Time > 990 then
			WAR.Person[enemyid].Time = 990
		end
		--10%�ļ��ʶ��θ���
		--if math.random(100) > 10 then		
		--WAR.PD["����״̬"][eid] = 1
		--end
	end	
	
	
	--��������
	if JY.Person[eid]["����"] <= 0 and PersonKF(eid, 94) and WAR.PD['�������'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.Person[enemyid]["��Ч����"] = 89
		WAR.Person[enemyid]["��Ч����3"] = "���չ���������"
		local modifier = 0.35+JY.Base["��������"]*0.01
		--����
		if match_ID(eid, 37) then
			modifier = 1
		--��������
		elseif Curr_NG(eid, 94) then
			modifier = 0.7+JY.Base["��������"]*0.02
		end
		JY.Person[eid]["����"] = math.modf(JY.Person[eid]["�������ֵ"]*modifier)
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + math.modf((JY.Person[eid]["�������ֵ"]-JY.Person[eid]["����"])*modifier)
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + math.modf((100 - JY.Person[eid]["����"])*modifier)
		JY.Person[eid]["�ж��̶�"] = JY.Person[eid]["�ж��̶�"]-math.modf(JY.Person[eid]["�ж��̶�"]*modifier)
		JY.Person[eid]["���˳̶�"] = JY.Person[eid]["���˳̶�"]-math.modf(JY.Person[eid]["���˳̶�"]*modifier)
		JY.Person[eid]["����̶�"] = JY.Person[eid]["����̶�"]-math.modf(JY.Person[eid]["����̶�"]*modifier)
		JY.Person[eid]["���ճ̶�"] = JY.Person[eid]["���ճ̶�"]-math.modf(JY.Person[eid]["���ճ̶�"]*modifier)
        if match_ID(eid, 129) then
            WAR.LQZ[eid] = 100
            --�������ǵ������������������ӣ�NPC�̶�Ϊ7
            if eid == 0 then
                WAR.BDQS = math.modf(JY.Base["��������"]/2)
            else
                WAR.BDQS = 7
            end
            
            WAR.Person[enemyid]["��Ч����"] = 115
            WAR.Person[enemyid]["��Ч����3"] = "�������� �۽���̬"
            
        end
		--��Ѫ
		if WAR.LXZT[eid] ~= nil then
			WAR.LXZT[eid] = WAR.LXZT[eid]-math.modf(WAR.LXZT[eid]*modifier)
			if WAR.LXZT[eid] < 1 then
				WAR.LXZT[eid] = nil
				WAR.LXXS[eid] = nil
			end
		end
		--��Ѩ
		if WAR.FXDS[eid] ~= nil then
			WAR.FXDS[eid] = WAR.FXDS[eid]-math.modf(WAR.FXDS[eid]*modifier)
			if WAR.FXDS[eid] < 1 then
				WAR.FXDS[eid] = nil
				WAR.FXXS[eid] = nil
			end
		end				
		WAR.Person[enemyid].Time = WAR.Person[enemyid].Time + 500
		WAR.FUHUOZT[eid] = 1
        --WAR.PD['�������'][eid] = 1
		--����
		if match_ID(eid, 37) then
			WAR.Person[enemyid].Time = 990
		end
		if WAR.Person[enemyid].Time > 990 then
			WAR.Person[enemyid].Time = 990
		end
		--6%�ļ��ʶ��θ���
		if math.random(100) > 6 then		
		--	WAR.PD["����״̬"][eid] = 1
            WAR.PD['�������'][eid] = 1
		end
	end
    
 	--�����
	if JY.Person[eid]["����"] <= 0 and match_ID(eid, 9986) and WAR.PD['������'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.Person[enemyid]["��Ч����"] = 19
		WAR.Person[enemyid]["��Ч����3"] = "����� ��������"
		WAR.PD['������'][eid] = 1
		JY.Person[eid]["����"] = JY.Person[eid]["�������ֵ"] * 0.7
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + (JY.Person[eid]["�������ֵ"] - JY.Person[eid]["����"])* 0.5
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + (100 - JY.Person[eid]["����"])* 0.5
		JY.Person[eid]["�ж��̶�"] = JY.Person[eid]["�ж��̶�"] * 0.5
		JY.Person[eid]["���˳̶�"] = JY.Person[eid]["���˳̶�"] * 0.5
        
        if match_ID(eid, 129) then
            WAR.LQZ[eid] = 100
            --�������ǵ������������������ӣ�NPC�̶�Ϊ7
            if eid == 0 then
                WAR.BDQS = math.modf(JY.Base["��������"]/2)
            else
                WAR.BDQS = 7
            end
            
            WAR.Person[enemyid]["��Ч����"] = 115
            WAR.Person[enemyid]["��Ч����3"] = "�������� �۽���̬"
            
        end
        
		WAR.Person[enemyid].Time = 980
		WAR.FUHUOZT[eid] = 1
	end 
    
	--һ�ƣ�����
	if JY.Person[eid]["����"] <= 0 and match_ID(eid, 65) and WAR.PD['���һ��'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.Person[enemyid]["��Ч����"] = 19
		WAR.Person[enemyid]["��Ч����3"] = "����һ�� ��������"
		WAR.PD['���һ��'][eid] = 1
		JY.Person[eid]["����"] = JY.Person[eid]["�������ֵ"] * 0.7
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + (JY.Person[eid]["�������ֵ"] - JY.Person[eid]["����"])* 0.5
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + (100 - JY.Person[eid]["����"])* 0.5
		JY.Person[eid]["�ж��̶�"] = JY.Person[eid]["�ж��̶�"] * 0.5
		JY.Person[eid]["���˳̶�"] = JY.Person[eid]["���˳̶�"] * 0.5
		WAR.Person[enemyid].Time = 980
        WAR.FUHUOZT[eid] = 1
	end
    
	--����ˮ�����⸴�� 
	if JY.Person[eid]["����"] <= 0 and (match_ID(eid, 652) or Curr_NG(eid,177)) and JY.Base["��������"] > 0 and WAR.PD['�������'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.Person[enemyid]["��Ч����"] = 19
		WAR.Person[enemyid]["��Ч����3"] = "�������� �����ƻ�"
		--WAR.WQTS_TY = WAR.WQTS_TY + 1
        WAR.PD['�������'][eid] = 1
		JY.Person[eid]["����"] = JY.Person[eid]["�������ֵ"] * 0.8
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + (JY.Person[eid]["�������ֵ"] - JY.Person[eid]["����"])* 0.5
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + (100 - JY.Person[eid]["����"])* 0.5
		JY.Person[eid]["�ж��̶�"] = JY.Person[eid]["�ж��̶�"] * 0.5
		JY.Person[eid]["���˳̶�"] = JY.Person[eid]["���˳̶�"] * 0.5
		WAR.Person[enemyid].Time = 980
		WAR.FUHUOZT[eid]=1
	end
        
	--���� ����
	if JY.Person[eid]["����"] <= 0 and match_ID_awakened(eid, 629,1) and WAR.PD['�������'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.Person[enemyid]["��Ч����"] = 154
		WAR.Person[enemyid]["��Ч����3"] = "ԡ������"
		WAR.PD['�������'][eid] = 1
		JY.Person[eid]["����"] = JY.Person[eid]["�������ֵ"] * 0.8
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + (JY.Person[eid]["�������ֵ"] - JY.Person[eid]["����"])* 0.5
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + (100 - JY.Person[eid]["����"])* 0.5
		JY.Person[eid]["�ж��̶�"] = JY.Person[eid]["�ж��̶�"] * 0.5
		JY.Person[eid]["���˳̶�"] = JY.Person[eid]["���˳̶�"] * 0.5
		WAR.Person[enemyid].Time = 980
        WAR.FUHUOZT[eid]=1
	end	
    
	--������������
	if JY.Person[eid]["����"] <= 0 and match_ID(eid, 129) and WAR.PD['���������'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.LQZ[eid] = 100
		--�������ǵ������������������ӣ�NPC�̶�Ϊ7
		if eid == 0 then
			WAR.BDQS = math.modf(JY.Base["��������"]/2)
		else
			WAR.BDQS = 7
		end
		WAR.Person[enemyid]["��Ч����"] = 115
		WAR.Person[enemyid]["��Ч����3"] = "�������� �۽���̬"
		WAR.PD['���������'][eid] = 1
		JY.Person[eid]["����"] = JY.Person[eid]["�������ֵ"] * 0.7
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + (JY.Person[eid]["�������ֵ"] - JY.Person[eid]["����"])* 0.5
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + (100 - JY.Person[eid]["����"])* 0.5
		JY.Person[eid]["�ж��̶�"] = JY.Person[eid]["�ж��̶�"] * 0.5
		JY.Person[eid]["���˳̶�"] = JY.Person[eid]["���˳̶�"] * 0.5
		WAR.Person[enemyid].Time = 980
		WAR.FUHUOZT[eid]=1
	end

	
	--�ݳ���������
	if JY.Person[eid]["����"] <= 0 and match_ID(eid, 594) and WAR.QCF < 1 and WAR.PD['����ݳ���'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.Person[enemyid]["��Ч����"] = 19
		WAR.Person[enemyid]["��Ч����3"] = "������ǽ ��������"
		WAR.PD['����ݳ���'][eid] = 1
		JY.Person[eid]["����"] = JY.Person[eid]["�������ֵ"] * 0.7
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + (JY.Person[eid]["�������ֵ"] - JY.Person[eid]["����"])* 0.5
		JY.Person[eid]["����"] = JY.Person[eid]["����"] + (100 - JY.Person[eid]["����"])* 0.5
		JY.Person[eid]["�ж��̶�"] = JY.Person[eid]["�ж��̶�"] * 0.5
		JY.Person[eid]["���˳̶�"] = JY.Person[eid]["���˳̶�"] * 0.5
		WAR.Person[enemyid].Time = 980
		WAR.FUHUOZT[eid]=1
	end
  
	--ѦĽ�� ����һ����
	if JY.Person[eid]["����"] <= 0 and WAR.PD['����ݳ���'][eid] == 0 and WAR.FUHUOZT[eid] < 1 then
		for i = 0, WAR.PersonNum - 1 do
			if match_ID(WAR.Person[i]["������"], 45) and WAR.Person[i]["����"] == false and WAR.Person[i]["�ҷ�"] == WAR.Person[enemyid]["�ҷ�"] then
				WAR.Person[enemyid]["��Ч����"] = 89
				WAR.Person[enemyid]["��Ч����3"] = "������ ����"
				JY.Person[eid]["����"] = JY.Person[eid]["�������ֵ"]
				JY.Person[eid]["����"] = JY.Person[eid]["�������ֵ"]
				JY.Person[eid]["�ж��̶�"] = 0
				JY.Person[eid]["���˳̶�"] = 0
				JY.Person[eid]["����̶�"] = 0
				JY.Person[eid]["���ճ̶�"] = 0
				JY.Person[eid]["����"] = 100
                
                if match_ID(eid, 129) then
                    WAR.LQZ[eid] = 100
                    --�������ǵ������������������ӣ�NPC�̶�Ϊ7
                    if eid == 0 then
                        WAR.BDQS = math.modf(JY.Base["��������"]/2)
                    else
                        WAR.BDQS = 7
                    end
                    
                    WAR.Person[enemyid]["��Ч����"] = 115
                    WAR.Person[enemyid]["��Ч����3"] = "�������� �۽���̬"
                    
                end
                
				--��Ѫ
				if WAR.LXZT[eid] ~= nil then
					WAR.LXZT[eid] = nil
					WAR.LXXS[eid] = nil
				end
				--��Ѩ
				if WAR.FXDS[eid] ~= nil then
					WAR.FXDS[eid] = nil
					WAR.FXXS[eid] = nil
				end
				WAR.XMH = 1
				WAR.FUHUOZT[eid] = 1
				break
			end
		end
	end
	
	--�żһԵĸ����ָ
	if JY.Person[eid]["����"] <= 0 and JY.Person[eid]["����"] == 303 then
		JY.Person[eid]["����"] = JY.Person[eid]["�������ֵ"]
		JY.Person[eid]["����"] = JY.Person[eid]["�������ֵ"]
		JY.Person[eid]["����"] = 100
		JY.Person[eid]["�ж��̶�"] = 0
		JY.Person[eid]["���˳̶�"] = 0
		JY.Person[eid]["����̶�"] = 0
		JY.Person[eid]["���ճ̶�"] = 0
		--��Ѫ
		if WAR.LXZT[eid] ~= nil then
			WAR.LXZT[eid] = nil
			WAR.LXXS[eid] = nil
		end
		--��Ѩ
		if WAR.FXDS[eid] ~= nil then
			WAR.FXDS[eid] = nil
			WAR.FXXS[eid] = nil
		end
        if match_ID(eid, 129) then
            WAR.LQZ[eid] = 100
            --�������ǵ������������������ӣ�NPC�̶�Ϊ7
            if eid == 0 then
                WAR.BDQS = math.modf(JY.Base["��������"]/2)
            else
                WAR.BDQS = 7
            end
            
            WAR.Person[enemyid]["��Ч����"] = 115
            WAR.Person[enemyid]["��Ч����3"] = "�������� �۽���̬"
            
        end
		WAR.Person[enemyid]["��Ч����"] = 154
		WAR.Person[enemyid]["��Ч����3"] = "�����ָ������"
		JY.Person[651]["Ʒ��"] = JY.Person[651]["Ʒ��"] - 1
		if JY.Person[651]["Ʒ��"] == 0 then
			JY.Person[eid]["����"] = -1
			JY.Thing[303]["ʹ����"] = -1
			instruct_32(303,-1)
			WAR.FHJZ = 1
		end
	end
  
	--��������
	if JY.Person[eid]["����"] < 0 then
		JY.Person[eid]["����"] = 0
		WAR.Person[WAR.CurID]["����"] = WAR.Person[WAR.CurID]["����"] + JY.Person[eid]["�ȼ�"] * 5
		WAR.Person[enemyid]["�����书"] = -1		--����������򲻻ᴥ������
		if WAR.SZSD == eid then						--ȡ����ս���
			WAR.SZSD = -1
		end
	end
	
	--Ѫ������ ɱ�����˺�ת��Ϊ����
	if match_ID(pid, 97) and JY.Person[eid]["����"] <= 0 and DWPD() and JLSD(0,50,eid) then
		WAR.Person[enemyid]["�ҷ�"] = WAR.Person[WAR.CurID]["�ҷ�"]
		JY.Person[eid]["����"] = JY.Person[eid]["�������ֵ"]
		JY.Person[eid]["����"] = JY.Person[eid]["�������ֵ"]
		JY.Person[eid]["�ж��̶�"] = 0
		JY.Person[eid]["���˳̶�"] = 0
		JY.Person[eid]["����̶�"] = 0
		JY.Person[eid]["���ճ̶�"] = 0
		JY.Person[eid]["����"] = 100
		WAR.FXXS[eid] = nil
		WAR.LXXS[eid] = nil
		WAR.FXDS[eid] = nil
		WAR.LXZT[eid] = nil
		WAR.XDLZ[eid] = 1
	end
  
	--ƽһָɱ��
	if JY.Person[eid]["����"] <= 0 and match_ID(pid, 28) and DWPD() then
		WAR.PYZ = WAR.PYZ + 1
		if 10 < WAR.PYZ then
			WAR.PYZ = 10
		end
	end
	
	--����ɱ��
	if JY.Person[eid]["����"] <= 0 and match_ID(pid, 47) and DWPD() then
		WAR.MZSH = WAR.MZSH + 1
	end


	--���ɱ��
	if JY.Person[eid]["����"] <= 0 and match_ID(pid, 636) and DWPD() then
		WAR.SBSYR = 1
	end
    
	--Ѫս�˷�
    if JY.Person[pid]["ˣ������"] >= 300 and JY.Person[eid]["����"] <= 0 and DWPD() then
	   WAR.XZBFZT[pid]  = (WAR.XZBFZT[pid] or 0)  + 1
	end   
    
	--�޾Ʋ�����Ԭ��־��Ѫ����
	--������
	if JY.Person[eid]["����"] <= 0 and match_ID(pid, 54) and DWPD() then
		WAR.BXCF = 1
	end
	--�������ޣ�ɱ����������
	if JY.Person[eid]["����"] <= 0 and (wugong == 3 or wugong == 120 or wugong == 5 or wugong == 21 or wugong == 118) and ZiqiTL(pid) and DWPD() then
		local dam = math.modf((JY.Person[eid]["�ж��̶�"]/100)*(JY.Person[eid]["�������ֵ"]/10))
		WAR.ZQTL = {dam, enemyid, WAR.Person[enemyid]["����X"], WAR.Person[enemyid]["����Y"]}
	end
	--ʵ������
    if inteam(pid) and DWPD() and JY.Person[eid]["����"] <= 0 then 
        while JY.Person[pid]["����ֽ�"] > JY.Person[eid]["����ֽ�"] do
              JY.Person[pid]["����ֽ�"] = JY.Person[pid]["����ֽ�"] - 1	
              if JY.Person[pid]["����ֽ�"] == 6 then
				 --CC.TX["����"] = 1
				 AddPersonAttrib(pid, "������", 3)
			     AddPersonAttrib(pid, "������",3)
		         AddPersonAttrib(pid, "�Ṧ", 3)
				--say( "�ҷ�"..JY.Person[pid]["����"].."��"..JY.Person[pid]["����ֽ�"].."��",0,1)
			  end
			  if JY.Person[pid]["����ֽ�"] == 5 then
				 --CC.TX["����"] = 1
			     AddPersonAttrib(pid, "ȭ�ƹ���", 3)
			     AddPersonAttrib(pid, "ָ������", 3)
			     AddPersonAttrib(pid, "��������", 3)
			     AddPersonAttrib(pid, "ˣ������", 3)
			     AddPersonAttrib(pid, "�������", 3)
			--say( "�ҷ�"..JY.Person[pid]["����"].."��"..JY.Person[pid]["����ֽ�"].."��",0,1)	
			  end
			  if JY.Person[pid]["����ֽ�"] == 4 then
				 --CC.TX["����"] = 1
			     AddPersonAttrib(pid, "������", 7)
			     AddPersonAttrib(pid, "������", 7)
			     AddPersonAttrib(pid, "�Ṧ", 7)
			--say( "�ҷ�"..JY.Person[pid]["����"].."��"..JY.Person[pid]["����ֽ�"].."��",0,1)	
			  end
			  if JY.Person[pid]["����ֽ�"] == 3 then
				 --CC.TX["һ��"] = 1
          	     AddPersonAttrib(pid, "ȭ�ƹ���", 7)
			     AddPersonAttrib(pid, "ָ������", 7)
			     AddPersonAttrib(pid, "��������", 7)
			     AddPersonAttrib(pid, "ˣ������", 7)
			     AddPersonAttrib(pid, "�������", 7)
			--say( "�ҷ�"..JY.Person[pid]["����"].."��"..JY.Person[pid]["����ֽ�"].."��",0,1)	
			  end
			  if JY.Person[pid]["����ֽ�"] == 2 then
				 --CC.TX["����"] = 1
                 AddPersonAttrib(pid, "������",20)
			--say( "�ҷ�"..JY.Person[pid]["����"].."��"..JY.Person[pid]["����ֽ�"].."��",0,1)	
			  end
			  if JY.Person[pid]["����ֽ�"] == 1 then
				 --CC.TX["��ʦ"] = 1
                 AddPersonAttrib(pid, "������", 20)
                 AddPersonAttrib(pid, "�Ṧ", 20)
			--say( "�ҷ�"..JY.Person[pid]["����"].."��"..JY.Person[pid]["����ֽ�"].."��",0,1)	
			  end
			  if JY.Person[pid]["����ֽ�"] == 0 then
				 --CC.TX["��˵"] = 1
			     AddPersonAttrib(pid, "ȭ�ƹ���",20)
			     AddPersonAttrib(pid, "ָ������",20)
			     AddPersonAttrib(pid, "��������",20)
			     AddPersonAttrib(pid, "ˣ������",20)
			     AddPersonAttrib(pid, "�������",20)
			--say( "�ҷ�"..JY.Person[pid]["����"].."��"..JY.Person[pid]["����ֽ�"].."��",0,1)
			  end
		 end					   
    end


	--��ڤ�񹦺����Ǵ󷨣�����������

	  
	WAR.NGHT = 0	--�ڹ�����
	WAR.CQSX = 0	--��ȴ����



	--if WAR.Person[enemyid]["��Ч����2"] == nil then
	--	WAR.Person[enemyid]["��Ч����2"] = "  "
	--end
	--���˲���ʾ����
	if DWPD() == false then
		WAR.Person[enemyid]["��Ч����"] = -1
		WAR.Person[enemyid]["��Ч����0"] = nil
		WAR.Person[enemyid]["��Ч����1"] = nil
		WAR.Person[enemyid]["��Ч����2"] = nil
		WAR.Person[enemyid]["��Ч����3"] = nil
		WAR.Person[enemyid]["��Ч����4"] = nil
	end	
	--��Ħ����Ч����
    if match_ID(eid,577) then	
        WAR.Person[enemyid]["��Ч����"] = 156
    end   
	--��Ѫ�������ɱ������ûغ���ʾ����
	if WAR.XDLZ[eid] ~= nil then
		WAR.Person[enemyid]["��Ч����"] = 123
		WAR.XDLZ[eid] = nil
	end

	if match_ID(pid, 511) and DWPD() then
		local zt = {{'��������',2},{'�����ⶾ',2},{'ţ��ѪЫ',2},{'С����',2},{'��������',2},{'�����ܵ�',2},
					{'��ī�Ͼ�',2},{'��¶��',2},{'�滨��',2},{'�屦���۾�',2},{'�����',2},{'��',1},{'ǰ',1},{'��',1},{'��',1},
					{'��',1},{'��',1},{'��',1},{'��',1},{'��',1},{'���ϵ�������',2},{'���ϵ����е�',2},
					{'���ϵ����е�',2},{'̫������',1},{'�������',1},{'��Ϣ����',1},{'�����',2},{'������',2},
					}

		local zt2 = {{'TJZX',1},{'HZD_QF',1},{'SLSX',2},{'YSJF',2},{'WTL_LDJT',2},{'ZTHF',2},{'QGZT',2},
					{'QGZT',2},{'SSESS',1},{'JGFX',1},{'XLFD',1},{'JTYJ',2},{'Focus',1},{'TSSB',2},{'QLJX',2},
					{'CSHF',2},{'XYYF',1},{'JFJQ',2},{'BTZT',2},
					}
		local pd = false 
		--local n = 0
		local menu = {}
		for j = 1,#zt do 
			local yc = zt[j][1]
			if WAR.PD[yc][eid] ~= nil and WAR.PD[yc][eid] > 0 then 
				menu[#menu+1] = {j,1}
			end
		end
		for j = 1,#zt2 do 
			local yc = zt2[j][1]
			if WAR[yc][eid] ~= nil and WAR[yc][eid] > 0 then 
				menu[#menu+1] = {j,2}
			end
		end
		if #menu > 0 then 
			local n = math.random(#menu)
			if menu[n][2] == 1 then 
				local yc = zt[menu[n][1]][1]
				local lx = zt[menu[n][1]][2]
				if lx == 2 then
					WAR.PD[yc][pid] = (WAR.PD[yc][pid] or 0) + WAR.PD[yc][eid]
				end
				WAR.PD[yc][eid] = nil
			else 
				local yc = zt2[menu[n][1]][1]
				local lx = zt2[menu[n][1]][2]
				if lx == 2 then
					WAR[yc][pid] = (WAR[yc][pid] or 0) + WAR[yc][eid]
				end
				WAR[yc][eid] = nil
			end
		end
	end
	
	if Curr_NG(eid, 171) and JLSD(0,30,eid) then 
        local YC = {
        {WAR.KHCM},
        {WAR.SZZT},
        {WAR.YYZS},
        {WAR.WMYH},
        {WAR.FXDS},
        {WAR.XRZT},
        {WAR.SGZT},
        {WAR.CHZT},
        {WAR.HLZT},
        {WAR.TGJF},
        {WAR.HMZT},
        {WAR.CSZT},
        {WAR.XRZT1},
        {WAR.MHZT},
        {WAR.MBJZ},
        {WAR.LXZT},
        {WAR.LRHF},
        {WAR.WZSYZ},
        {WAR.TZ_XZ_SSH},
        {WAR.LSQ},
        {WAR.XZD},
        {WAR.QYZT},
        {WAR.MRSHZT},
        }
        local YC2 = {
		{"����"},
		{"��������"},
        }
        for j = 1,#YC do
            local yc = YC[j][1]

            if yc[eid] ~= nil and yc[eid] > 0 then 
                yc[pid] = (yc[pid] or 0) + yc[eid]
                if yc == WAR.FXDS then 
                    if yc[pid] > 50 then 
                        yc[pid] = 50   
                    end
                    WAR.FXXS[pid] = 1
                    WAR.FXXS[eid] = nil
                end
                if yc == WAR.LXZT then 
                    if yc[pid] > 100 then 
                        yc[pid] = 100   
                    end
                    WAR.LXXS[pid] = 1
                    WAR.LXXS[eid] = nil
                end
                yc[eid] = nil
            end
        end
        for j = 1,#YC2 do
            local yc = YC2[j][1]
            if WAR.PD[yc][eid] ~= nil then 
                WAR.PD[yc][pid] = (WAR.PD[yc][pid] or 0) + WAR.PD[yc][eid]
                WAR.PD[yc][eid] = nil
            end
        end
        local ns = JY.Person[eid]['���˳̶�']
        local zd = JY.Person[eid]['�ж��̶�']
        local bf = JY.Person[eid]['����̶�']
        local zs = JY.Person[eid]['���ճ̶�']
        if ns > 0 then 
            --WAR.Person[i]["�ⶾ����"];
            WAR.Person[WAR.CurID]["���˵���"] = (WAR.Person[WAR.CurID]["���˵���"] or 0) + AddPersonAttrib(pid,'���˳̶�',ns)
            JY.Person[eid]['���˳̶�'] = 0
            WAR.Person[enemyid]["���˵���"] = nil
        end
        if zd > 0 then 
            --WAR.Person[i]["�ⶾ����"];
            WAR.Person[WAR.CurID]["�ж�����"] = (WAR.Person[WAR.CurID]["�ж�����"] or 0) + AddPersonAttrib(pid,'�ж��̶�',zd)
            JY.Person[eid]['�ж��̶�'] = 0
            WAR.Person[enemyid]["�ж�����"] = nil
        end
        if bf > 0 then 
            WAR.BFXS[pid] = 1
            AddPersonAttrib(pid,'����̶�',bf)
            JY.Person[eid]['����̶�'] = 0
            WAR.BFXS[eid] = nil
        end
        if zs > 0 then 
            WAR.ZSXS[pid] = 1
            AddPersonAttrib(pid,'���ճ̶�',zs)
            JY.Person[eid]['���ճ̶�'] = 0
            WAR.ZSXS[eid] = nil
        end
		WAR.Person[enemyid]["��Ч����"] = 21
		Set_Eff_Text(enemyid,"��Ч����0","ת����");
    end
    
	WAR.PD['������'][eid] = nil
    if match_ID(pid, 9965) then
        JY.Person[pid]['����̶�'] = 0
        JY.Person[pid]['���ճ̶�'] = 0
        WAR.BFXS[pid] = nil
        WAR.ZSXS[pid] = nil
    end
	::label0::
	return math.modf(hurt);
end

-- ����ս����ͼ
-- flag=0  ���ƻ���ս����ͼ
--     =1  ��ʾ���ƶ���·����(v1,v2)��ǰ�ƶ����꣬��ɫ����(ѩ��ս��)
--     =2  ��ʾ���ƶ���·����(v1,v2)��ǰ�ƶ����꣬��ɫ����
--     =3  ���е������ð�ɫ������ʾ
--     =4  ս����������  v1 ս������pic, v2��ͼ�����ļ����ļ�id
--                       v3 �书Ч��pic  -1��ʾû���书Ч��
function WarDrawMap(flag, v1, v2, v3, v4, v5, ex, ey, px, py)
	local x = WAR.Person[WAR.CurID]["����X"]
	local y = WAR.Person[WAR.CurID]["����Y"]
	if not v4 then
		v4 = JY.SubScene
	end
	if not v5 then
		v5 = -1;
	end
	
	px = px or 0
	
	py = py or 0
	
	if flag == 0 then
		lib.DrawWarMap(0, x, y, 0, 0, -1, v4)
	elseif flag == 1 then
		--��쳾ӣ�ѩɽ���м��ջ�������ǣ������ǣ���ɽ����
		if v4 == 0 or v4 == 2 or v4 == 3 or v4 == 39 or v4 == 107 or v4 == 111 then
			lib.DrawWarMap(1, x, y, v1, v2, -1, v4)
		else
			lib.DrawWarMap(2, x, y, v1, v2, -1, v4)
		end
	elseif flag == 2 then
			lib.DrawWarMap(3, x, y, 0, 0, -1, v4)
	elseif flag == 4 then
		lib.DrawWarMap(4, x, y, v1, v2, v3, v4,v5, ex, ey)
	--���˶���
	elseif flag == 6 then
		lib.DrawWarMap(6, x, y, v1, v2, v3, v4,v5, ex, ey, px, py)

	--��������
	elseif flag == 7 then
		lib.DrawWarMap(7, x, y, 0, 0, v3, v4,v5, ex, ey, px, py)
	end
  
	if WAR.ShowHead == 1 then
		WarShowHead()
	end
	
	if CONFIG.HPDisplay == 1 then
		if WAR.ShowHP == 1 then
			HP_Display_When_Idle()	--��̬��Ѫ
		end
	end
end

--�з�ս������
function WarSelectEnemy()
	--�з������ر����
	if PNLBD[WAR.ZDDH] ~= nil then
		PNLBD[WAR.ZDDH]()
	end
  
    if WAR.ZDDH == 354 then 
        local x = 20
        local y = 46
        for i = 1,#CC.HSLJ2 do
            local id = CC.HSLJ2[i]
            WAR.Person[WAR.PersonNum]["������"] = id
            WAR.Person[WAR.PersonNum]["�ҷ�"] = false
            WAR.Person[WAR.PersonNum]["����X"] = x
            WAR.Person[WAR.PersonNum]["����Y"] = y
            WAR.Person[WAR.PersonNum]["����"] = false
            WAR.Person[WAR.PersonNum]["�˷���"] = 0
            WAR.PersonNum = WAR.PersonNum + 1
            x = x + 1
            if x == 34 then 
                x = 20
                y = y - 2
            end
        end
    else
        for i = 1, 20 do
            if WAR.Data["����" .. i] > 0 then
                --�������������´ﺣ
                if WAR.ZDDH == 92 and GetS(87,31,33,5) == 1 then
                    for i=2,5 do	
                        WAR.Data["����" .. i] = -1;
                    end
                end
                
                --�޾Ʋ��������۽�����
                if WAR.ZDDH == 266 then
                    WAR.Data["����1"] = GetS(85, 40, 38, 4)
                end
                
                WAR.Person[WAR.PersonNum]["������"] = WAR.Data["����" .. i]
                WAR.Person[WAR.PersonNum]["�ҷ�"] = false
                WAR.Person[WAR.PersonNum]["����X"] = WAR.Data["�з�X" .. i]
                WAR.Person[WAR.PersonNum]["����Y"] = WAR.Data["�з�Y" .. i]
                WAR.Person[WAR.PersonNum]["����"] = false
                WAR.Person[WAR.PersonNum]["�˷���"] = 1
                
                --�޾Ʋ���������ս����ʼ����
                --ս����
                if WAR.ZDDH == 259 then
                    WAR.Person[WAR.PersonNum]["�˷���"] = 2
                end
                --˫������ֹ
                if WAR.ZDDH == 273 then
                    WAR.Person[WAR.PersonNum]["�˷���"] = 3
                end
                --���������
                if WAR.ZDDH == 275 then
                    WAR.Person[WAR.PersonNum]["�˷���"] = 3
                end
                --ս����
                if WAR.ZDDH == 75 then
                    WAR.Person[WAR.PersonNum]["�˷���"] = 3
                end
                --�ɸ�
                if WAR.ZDDH == 278 then
                    WAR.Person[WAR.PersonNum]["�˷���"] = 3
                end
                --����������
                if WAR.ZDDH == 279 then
                    WAR.Person[WAR.PersonNum]["�˷���"] = 3
                end
                --��������
                if WAR.ZDDH == 293 then
                    WAR.Person[WAR.PersonNum]["�˷���"] = 3
                end
                --��ڤ����
                if WAR.ZDDH == 295 then
                    WAR.Person[WAR.PersonNum]["�˷���"] = 3
                end
                --��������Ⱥ
                if WAR.ZDDH == 298 then
                    WAR.Person[WAR.PersonNum]["�˷���"] = 2
                end
                --����а
                if WAR.ZDDH == 170 then
                    WAR.Person[WAR.PersonNum]["�˷���"] = 3
                end
                WAR.PersonNum = WAR.PersonNum + 1
            end
        end
    end
end

--����ս��������ͼ
function WarCalPersonPic(id)
	
	--local n = 5106
	--n = n + JY.Person[WAR.Person[id]["������"]]["ͷ�����"] * 8 + WAR.Person[id]["�˷���"] * 2
	

	local pid = WAR.Person[id]['������']
	local t = 0
	local n = 0
	for i = 1,5 do 
		if JY.Person[pid]['���ж���֡��'..i] > 0 then 
			t = JY.Person[pid]['���ж���֡��'..i]
			break
		end
	end

	n = n + WAR.Person[id]["�˷���"]*t*2
	return n
end

--�����׼��������������ͼ
function WarCalPersonPic2(id, gender)
	local n = 5058
	if gender == 1 then
		n = 5010
	end
	n = n + WAR.Person[id]["�˷���"] * 12
	return n
end

--ս���Ƿ����
function War_isEnd()
	for i = 0, WAR.PersonNum - 1 do
		if JY.Person[WAR.Person[i]["������"]]["����"] <= 0 then
			WAR.Person[i]["����"] = true
		end
	end
	Cat('ʵʱ��Ч����')
	WarSetPerson()
	Cls()
	ShowScreen()
	lib.Delay(CC.BattleDelay)
	local myNum = 0
	local EmenyNum = 0
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["����"] == false then
			if WAR.Person[i]["�ҷ�"] == true then
				myNum = 1
			else
				EmenyNum = 1
			end
		end
	end

	if EmenyNum == 0 then
		return 1;
	end
	if myNum == 0 then
		return 2;
	end
	return 0
end

--�޾Ʋ�����ս���Ƿ����2
function War_isEnd2()
	local myNum = 0
	local EmenyNum = 0
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["����"] == false then
			if WAR.Person[i]["�ҷ�"] == true then
				myNum = 1
			else
				EmenyNum = 1
			end
		end
	end

	if EmenyNum == 0 then
		return 1;
	end
	if myNum == 0 then
		return 2;
	end
	return 0
end

function WarSet()
	WAR.WGWL = 0		--��¼�书10���Ĺ�����
	WAR.ZYHB = 0		--���һ�����1���������ҵĻغϣ�2�����ҵĶ���غ�
	WAR.ZYHBP = -1		--��¼�������ҵ��˵ı��
	WAR.ZHB = 0			--�ܲ�ͨ��׷�������ж�
	WAR.AQBS = 0		--��������
	WAR.BJ = 0			--����
	WAR.XK = 0			--����֮ŭХ
	WAR.XK2 = nil
	WAR.DXZL = 0			--��а֮ŭ
	WAR.DXZL2 = nil	
	WAR.SKXYXS = 0			--
	WAR.TD = -1			--͵��
	WAR.TDnum = 0		--͵������
	WAR.HTSS = 0		--ҽ������
	WAR.ZSF = 0			--����������Ȼ
	WAR.QLBLX = 0		--���ǧ�ﲻ����
	
	WAR.XZZ = 0			--������ӻ�
	WAR.KFKJ = 0		--�ⲻƽ���콣
	WAR.HTS = 0			--�������嶾���2-5������
	WAR.ZWX = 0	
	WAR.JYZJ_FXJ = 0	--	������
    WAR.DZTG_DZS = 0	--	����ʦ	
	WAR.FS = 0			--�İ���֮ս���Ƿ�������
	WAR.ZBT = 1			--�ܲ�ͨ��ÿ�ж�һ�Σ�����ʱ�˺�һ+10%
	WAR.HQT = 0			--����ͩ ɱ����
	WAR.CY = 0			--��Ӣ ɱ����
	WAR.HDWZ = 0		--��������϶�
	WAR.ZJZ = 0			--����棬����õ�ʳ��
	WAR.YJ = 0			--�ֻ�͵Ǯ
	WAR.DJGZ = 0		--��������
	WAR.DFMQ = 0		--���ħȭ	
	WAR.WS = 0			--����
	WAR.ACT = 1			--��������
	WAR.WDKTJ = 0		--	
	WAR.LYSH = 0 		--�����ػ�
	WAR.AJFHNP1 = 0 	--
	WAR.TKXJ = 0		--̫��ж��
	WAR.SJHB = 0		--˫���ϱ�
	WAR.SJHB_G = 0		--˫���ϱ�.��
	WAR.SJHB_S = 0		--˫���ϱ�.��		
	WAR.DZXY = 0		--��ת����
	WAR.LXZQ = 0		--ȭ������
	WAR.LXYZ = 0		--ָ������
	WAR.JSYX = 0		--�������
	WAR.QLJG = 0		--�����������
	WAR.SL23 = 0	
	WAR.ASKD = 0		--��������
	WAR.LXBR = 0		--�������
	WAR.LXZL10 = 0			--����֮����ŭ�����Ӿ�������	
	WAR.XC_WLCZ = 0			--	
	WAR.XC_JJNP = 0			--	
	WAR.YZHYZ = 0		--������������ŭ������
	WAR.GCTJ = 0		--���Ŵ���
	WAR.JSTG = 0		--�����
	WAR.YTML = 0 		--��������
	WAR.SLSS = 0 		--���� ����ɢ��	
	WAR.NGXS = 0		--�ڹ�������ϵ��
	WAR.TXZZ = 0		--̫��֮��
	WAR.MMGJ = 0		--äĿ����
	WAR.TFBW = 0		--�����λ�����ּ�¼
	WAR.TLDWX = 0		--���޵��������ּ�¼
	WAR.JSAY = 0		--���߰���
	WAR.JYSZ = 0		--������צ
	WAR.OYFXL = 0 		--ŷ������ݸ�����������˺�
	WAR.LXXL = 0 		--�������������˺�	
	WAR.XDLeech = 0		--Ѫ����Ѫ��
	WAR.WYXLeech = 0	--ΤһЦ��Ѫ��
	WAR.TMGLeech = 0	--��ħ����Ѫ��
	WAR.BHLeech = 0	--�̺���Ѫ��
	WAR.BMSGXL = 0	--��ڤ����	
	WAR.XHSJ = 0		--Ѫ�������Ѫ��
	WAR.WDRX = 0		--��Զ��ʹ��̫��ȭ��̫�����������Զ��������״̬
	WAR.KMZWD = 0 		--�ܲ�ͨ����֮���
	WAR.ARJY = 0		--��Ȼ����
	WAR.ARJY1 = 0		--��Ȼ����	
	WAR.YLTW = 0		--��������	
	WAR.LFHX = 0 		--�ֳ�Ӣ�����ѩ
	WAR.LWSWD = 0		--	
	WAR.YQFSQ = 0		--һ��������	
	WAR.QXWXJ = 0		--�������ν� Ī��	
	WAR.YYBJ = 0 		--���������಻��
	WAR.SEYB = 0
	WAR.MHSN = 0 		--	
    WAR.KZJYBF = 0      --
	WAR.BJYPYZ = 0 		--	
	WAR.BJYJF = 0 		--		
	WAR.YNXJ = 0		--��Ů�ľ���ز�ÿձ�
	WAR.HXZYJ = 0		--����֮һ��
	WAR.QQSH1 = 0		--�����黭֮������
	WAR.QQSH2 = 0		--�����黭֮��ʵ���
	WAR.QQSH3 = 0		--�����黭֮����������
	WAR.YZQS = 0		--һ������
	WAR.HYYQ=0
	WAR.TYJQ = 0		--������Ԫ����
	WAR.WWWJ = 0
	WAR.LDJT = 0		--�׶�����
	WAR.CXLZ = 0	
	WAR.QBLL = 0		--
	WAR.SZXM = 0		--
    WAR.BLCC = 0
	WAR.XMJDHS = 0
	WAR.XMHSQ = 0	
	WAR.JTYJ1 = 0		--
	WAR.HZD_1 = 0		--½����֮����������ˮ��
	WAR.HZD_2 = 0		--½����֮�������ɰٴ�		
	WAR.OYK = 0 		--ŷ��������ȭ
    WAR.JXG_SJG =0      --��Ϣ�� �񾨸�
	WAR.JQBYH = 0		--�������������̺�
	WAR.CMDF = 0		--���鵶��
	WAR.NZQK = 0		--��תǬ��
	WAR.XMJDHS = 0
	WAR.XMHSQ = 0	
	WAR.JTYJ1 = 0		--
	WAR.HZD_1 = 0		--½����֮����������ˮ��
	WAR.HZD_2 = 0		--½����֮�������ɰٴ�		
	WAR.OYK = 0 		--ŷ��������ȭ
    WAR.JXG_SJG =0      --��Ϣ�� �񾨸�
	WAR.JQBYH = 0		--�������������̺�
	WAR.CMDF = 0		--���鵶��
	WAR.NZQK = 0		--��תǬ��
	WAR.BXCF = 0 		--Ԭ��־��Ѫ����
	WAR.XMCX = 0 		--���Ŵ�ѩ
	WAR.LJXD = 0 		--�����ж�
	WAR.LJXD1 = 0 		--�����ж�1		
	WAR.SBSYR = 0 		--���ʮ��ɱһ��
	WAR.FLHS1 = 0		--�伲���
	WAR.FLHS2 = 0		--��������
	WAR.FLHS4 = 0		--������ɽ	
	--WAR.FLHS5 = 0		--��֪����
	WAR.ZYZD = 0		--��ӹ֮��
	--WAR.SSESS = 0		--��ʮ������
	WAR.SSESS1 = 0		--��ʮ������.������
	WAR.SSESS4 = 0		--��ʮ������.�׺���
	WAR.SSESS5 = 0		--��ʮ������.������
	WAR.SSESS6 = 0		--��ʮ������.������
	WAR.NGJL = 0		--��ǰ�����ڹ����
	WAR.NGHT = 0		--��ǰ�����ڹ����
	WAR.CQSX = 0		--��ȴ����
	WAR.ZWWW = 0		--��������
	WAR.BMXH = 0		--��������
 	WAR.HDJY = 0		--��������   	
	WAR.BTJS = 0		--�������
	WAR.ZYYD = 0		--��¼���ҵ�ʥ���ƶ�����
	WAR.LMSJwav = 0		--�����񽣵���Ч
	WAR.JGZ_DMZ = 0		--��Ħ��
	WAR.LHQ_BNZ = 0		--������
	WAR.WD_CLSZ = 0		--��������
	WAR.QZ_QXJF = 0		--���ǽ���
	WAR.BXXHSJ = 0		--	
	WAR.ShowHead = 0	--��ʾ���½�ͷ����Ϣ
	WAR.Effect = 0		--���ι�����Ч����2���˺���3��ɱ�ڣ�4��ҽ�ƣ�5���϶���6���ⶾ
	WAR.Delay = 0
	WAR.LifeNum = 0
	WAR.TZ_MRF = 0		--Ľ�ݸ�ָ��
	WAR.KHBX = 0		--������Ŀ
	WAR.BFX = 0			--�ط�Ѩ
	WAR.BLX = 0			--����Ѫ
	WAR.BBF = 0 		--�ر���
	WAR.BZS = 0			--������
	WAR.GSWS = 0 		--������˫
	--WAR.SSESS = 0 		--½����ʮ������
	--WAR.JGFX = 0 		--½����շ���	
	WAR.TWLJ = 0 		--��������
	WAR.DJJJ_LJ = 0
	WAR.SYLJ = 0 		--½����ʮ������ ����������
	WAR.JYLJ = 0 		--��������	
	WAR.hit_DGQB = 0	--�޾Ʋ�����������ܷ�������Ч��ʾ
	WAR.XTTX = 0			--�����Ϣ
	WAR.WFCZ_1 = 0			--�����	
	WAR.JHZT = 0	
	WAR.MZSH = 0			--��������ɳ����ÿɱһ����+200��������
   
	WAR.SZSD = -1			--����ս������Ŀ��
	WAR.BJGX = 0
	WAR.JJZC = 0		--�Ž��洫��4������������Ч
	WAR.JJDJ = 0 		--�Ž�����ʽ����
	WAR.Dodge = 0		--�ж��Ƿ�����

	WAR.CXLC = 0		--���Ƴ�������
    WAR.YTLJ = 0		--��������	
	WAR.CXLC_Count = 0	--���Ƴ������Ǽ���
	WAR.WLLJ_Count = 0
	WAR.FQY = 0			--����������ʤ����
	WAR.GHQH = 0		--����Ů �㺮���
	WAR.LXXZD = 0	    --���� г֮��	
	WAR.LPZ = 0			--��ƽ֮����
	WAR.JMZL = 0
	WAR.L_TLD = 0;		--װ����������Ч��1��Ѫ
	WAR.PJTX = 0 		--�������������������ƾ�����
    WAR.YLSJJ = 0
	WAR.NZZ1 = 0
	WAR.BXZS = 0				--��а��ʽ
	WAR.JYZS = 0				--������ʽ
	WAR.KHSZ = 0			--��������
	WAR.ZWYJF = 0			--�н������������������Ӿ�������
	WAR.KHLH = 0			--���� ����
	WAR.TXZS = 0 			--̫����ʽ
	WAR.AJFHNP = 0	        -- ����	
	WAR.JuHuo = 0			--�ٻ���ԭ
	WAR.LiRen = 0			--���к���
	WAR.LWX = 0				--���������������Ч
	WAR.PDJN = 0			--�¼����Ҷ���ţ
	WAR.KF = 0	
	WAR.ATNum = 1
	WAR.RULAISZ = 0
	WAR.RULAISZ_1 = 0
end	

--����ս��ȫ�ֱ���
function WarSetGlobal()
	WAR = {}
	WAR.Data = {}
	WAR.Person = {}
	WAR.MCRS = 0 --�޾Ʋ�����ÿ��ս��ѡ������
	for i = 0, 100 do
		WAR.Person[i] = {}
		WAR.Person[i]["������"] = -1
		WAR.Person[i]["�ҷ�"] = true
		WAR.Person[i]["����X"] = -1
		WAR.Person[i]["����Y"] = -1
		WAR.Person[i]["����"] = true
		WAR.Person[i]["����"] = false;
		WAR.Person[i]["�˷���"] = -1
		WAR.Person[i]["��ͼ"] = -1
		WAR.Person[i]["��ͼ����"] = 0
		WAR.Person[i]["�Ṧ"] = 0
		WAR.Person[i]["�ƶ�����"] = 0
		WAR.Person[i]["����"] = 0
		WAR.Person[i]["�Զ�ѡ�����"] = -1
		WAR.Person[i].Move = {}
		WAR.Person[i].Action = {}
		WAR.Person[i].Time = 0
		WAR.Person[i].TimeAdd = 0
		WAR.Person[i].SpdAdd = 0
		WAR.Person[i].Point = 0
		WAR.Person[i]["��Ч����"] = -1
		WAR.Person[i]["�����书"] = -1
		WAR.Person[i]["��Ч����0"] = nil
		WAR.Person[i]["��Ч����1"] = nil
		WAR.Person[i]["��Ч����2"] = nil
		WAR.Person[i]["��Ч����3"] = nil
		WAR.Person[i]["��Ч����4"] = nil	--�޾Ʋ������ӵ����� 8-11
		WAR.Person[i]["���ַ���"] = -1
		WAR.Person[i]["����"] = -1
		WAR.Person[i]["����"] = -1
		WAR.Person[i]["������ͼ"] = -1
		WAR.Person[i]["�����ӳ�"] = nil
		WAR.Person[i]["����̫��"] = nil
	end
    
	WAR.PersonNum = 0
	WAR.AutoFight = 0
	WAR.CurID = -1
	WAR.MissPd = 0
	WAR.SXTJ = 0		--ʱ��
	WAR.SSX_Counter = 0	--��ʱ�������
	WAR.WSX_Counter = 0	--��ʱ�������
	WAR.LSX_Counter = 0	--��ʱ�������
	WAR.JSX_Counter = 0	--��ʱ�������
	WAR.BDQS = 0		--�������������״̬����
	WAR.QCF = 0			--�ݳ�������
	WAR.WQTS_TY = 0		--�������� ����	
	WAR.XMH = 0			--ѦĽ�� ����һ����
	WAR.ZSHY = {}		--ת˲���ռ�����
	WAR.WCY = {}		--һ�Ƹ���
	WAR.CYZX = {} 		--����������
 
	--�����ж�
	WAR.ATK = {['����'] = nil,['����table'] = {},['����pd'] = {},
				}
    
    --��פ����
	WarSet()
	
	WAR.PYZ = 0			--ƽһָɱ��
	
	
	WAR.ZDDH = -1		--ս������
	WAR.NO1 = -1		--�ɰ��۽���һ��
	
	WAR.TJAY = 0		--̫������
	

	WAR.DZXYLV = {}
	--WAR.fthurt = 0		--Ǭ���������˺�

	
	WAR.TLDW = {}		--���޵���
	
	--�ж����ݣ�ͳһ��д
	WAR.PD = {
			['Ǭ'] = {},			--���ԡ�Ǭ��Ч
			['��'] = {},			--���ԡ�����Ч
			['��'] = {},			--���ԡ�����Ч
			['��'] = {},			--���ԡ�����Ч
			['��'] = {},			--���ԡ�����Ч
			['��'] = {},			--���ԡ�����Ч
			['��'] = {},			--���ԡ�����Ч
			['��'] = {},			--���ԡ�����Ч
			['��������'] = {},     --��������
			['��'] = {},			--���ԡ�����Ч
			['��'] = {},			--���ԡ�����Ч
			['��'] = {},			--���ԡ�����Ч
			['��'] = {},			--���ԡ�����Ч
			['��'] = {},			--���ԡ�����Ч
			['��'] = {},			--���ԡ�����Ч
			['��'] = {},			--���ԡ�����Ч
			['��'] = {},			--���ԡ�����Ч
			['ǰ'] = {},			--���ԡ�����Ч
			['����̫��'] = {},		
			['�����귭'] = {},
			['������'] = {},
			['��������'] = {},
            ['��հ���']	= {},	
			['�����'] = {},
			['�����'] = {},
			['����ɽ'] = {},
			['������'] = {},
			['�廨��'] = {},
			['��������'] = {},
			['�����'] = {},
			['͵�컻��'] = {},
			['÷����'] = {},
			['���커��CD'] = {},
			['���커��'] = {},
			['�������'] = {},
			['��Ϣ����'] = {},
			['̫������'] = {},
			['����״̬'] = {},
			['�߻�״̬'] = {},
			['�������'] = {},
			['�������'] = {},
            ['Ұ��ȭ'] = {},
            ['���ϵ�'] = {},
            ['���ϵ����е�'] = {},
            ['���ϵ�������'] = {},
            ['������'] = {},
            ['ѩ������'] = {},
            ['������˫��ȡˮ'] = {},
            ['�����������л�'] = {},
            ['������Ǳ������'] = {},
            ['�������𾪰���'] = {},
            ['��������������'] = {},
            ['��������������'] = {},
            ['������ʱ������'] = {},
            ['����'] = {},
            ['���һ��'] = {},
            ['������'] = {},
            ['���������'] = {},
            ['�������'] = {},
            ['�������'] = {},
            ['�������'] = {},
            ['�������'] = {},
            ['����ݳ���'] = {},
            ['����'] = {},
            ['���־�'] = {},
            ['���־�'] = {},
            ['ת�־�'] = {},
            ['���־�'] = {},
            ['���־�'] = {},
            ['���־�'] = {},
            ['���־�'] = {},
            ['��Ϧ��϶'] = {},
            ['����ͨ��'] = {},
            ['�˾Ʊ�'] = {},
            ['�滨��'] = {},
			['��¶��'] = {},
            ['�屦���۾�'] = {},			
            ['��ī�Ͼ�'] = {},
            ['�����ܵ�'] = {},
            ['��������'] = {},
            ['С����'] = {},
            ['�����ⶾ'] = {},
            ['ţ��ѪЫ'] = {},
            ['��������'] = {},
			['�����'] = {},
			['����'] = {},
            ['��ӹ'] = {},
			['�����4'] = {},
			['���سɷ�'] = {},
			['��������'] = {},
			['����'] = {},
	}
	
	WAR.TGCD = {[356] = 50,
	}
	WAR.CD = 0  --��ص�CD
	
    WAR.BLCC_1 = {}		

	WAR.TXXS = {} 		--��Ч������ʾ
	
	WAR.EffectXY = nil
	WAR.EffectXYNum = 0
	WAR.tmp = {}		-- 100������   200����󡹦������1000��ŷ���������߻�1500����Ϣ��������2000��̫��ȭ������3000�����ո��4000��̫�齣��������5000��ͷ����
	WAR.Actup = {}		--������¼
	WAR.Defup = {}		--������¼
	WAR.Wait = {}		--�ȴ���¼
	WAR.Focus = {}		--���м�¼
	WAR.HMGXL = {}		--�����������300����
	WAR.Weakspot = {}	--��������
	WAR.KHCM = {}		--����Ŀ���˼�¼
	WAR.LQZ = {}		--ŭ��ֵ
	WAR.FXDS = {}		--��Ѩ����
	WAR.FXXS = {}		--��Ѩ��ʾ
	WAR.LXZT = {}		--��Ѫ����
	WAR.LXXS = {}		--��Ѫ��ʾ
	WAR.BFXS = {}		--������ʾ
	WAR.ZSXS = {}		--������ʾ
	WAR.SZJPYX = {}		--�Ѿ��ṩ��ʵս���˼�¼���������ģ�
	

	
	WAR.DXMX = {}		--��������
	
	WAR.TZ_DY = 0		--����ָ��
	WAR.TZ_XZ = 0		--����ָ��

	WAR.TZ_XZ_SSH = {}	--�������������˼�¼
	WAR.TXZQ = {}		--̫��֮��

	WAR.DZZ = {}		--��ʮ������ ��������
	WAR.FGPZ = {}		--		
	WAR.JJJ = {}		--������
	WAR.JQSDXS = {} 	--�޾Ʋ����������ٶ���ʾ
	
	
	WAR.WXFS = nil		--����ˮ�������ı�ż�¼
	WAR.JJPZ = {} 		--�޾Ʋ������Ž�����
	WAR.TKJQ = {}		--̫��ж�����ټ���
	WAR.BHJQ = {}		--�̺���������ʽ4���ټ���	

	WAR.TJZX = {}		--̫��֮�μ�¼
	WAR.WFCZ = {}		--�����
	WAR.TXSH = {}		--�����	
	WAR.HZD_QF = {}		--�����¼	


	WAR.WZSYZ = {}		--������ʤ���л��е���
	WAR.ZXXS = {}		--��ϼ����
	WAR.GMYS = 0		--��ң����Ӽ���
	WAR.GMZS = {}		--�����д��е��˼�¼
	
		
	WAR.JYFX = {}		--����7ʱ������Ѩ
		
	WAR.QYBY = {}		--�ֳ�Ӣ���Ʊ��£�ÿ50ʱ��ɴ���һ�Σ������˺�10ʱ��
	WAR.XZ_YB = {}		--С��Ӱ����¼
	WAR.LSQ = {}		--������ȭ���е��˼�¼
	
	WAR.HP_Bonus_Count = {}	--��¼Ѫ�������ı��
  
	WAR.L_EffectColor = {}					--�쳣״̬����ɫ��ʾ
	WAR.L_EffectColor[1] = M_Silver;		--��ʾ��������
	WAR.L_EffectColor[2] = M_Pink;			--��ʾ��������
	WAR.L_EffectColor[3] = M_LightBlue;		--��ʾ�ⶾ
	WAR.L_EffectColor[4] = M_DeepSkyBlue;	--��ʾ�������ٺ�����
	WAR.L_EffectColor[5] = M_PaleGreen;		--��ʾ�������ٺ�����
	WAR.L_EffectColor[6] = C_GOLD;			--��ʾ��Ѩ
	WAR.L_EffectColor[7] = M_Red;			--��ʾ��Ѫ
	WAR.L_EffectColor[8] = M_DarkGreen;		--��ʾ�ж�
	WAR.L_EffectColor[9] = PinkRed;			--��ʾ���˼��ٺ�����
	WAR.L_EffectColor[10] = LightSkyBlue;	--��ʾ����
	WAR.L_EffectColor[11] = C_ORANGE;		--��ʾ����
  
	WAR.L_WNGZL = {};		--���ѹ�ָ������ж���Ѫ
	WAR.L_HQNZL = {};		--����ţָ�������Ѫ������
  
	WAR.L_QKDNY = {};		--�趨���������ʱ��Ǭ��ֻ�ܱ���һ��
  
	WAR.L_NOT_MOVE = {};	--��¼�����ƶ�����
	WAR.XDLZ = {};			--��¼��Ѫ������ɱ������
	WAR.ZZRZY = 0			--�������������ҵľ���
	--WAR.YLHF = 0			--
	--WAR.BSTX = 0			--����̫��
	WAR.ShowHP = 1			--Ѫ����ʾ
	WAR.FF = 0				--���Ǿ��Ѻ����㿪��ǰ���β����˺�
	WAR.ZQHT = 0 			--�Ƿ񴥷���������
	
	WAR.TSSB = {}			--����̩ɽ��ʹ�ú�30ʱ��������
	WAR.QLJX = {}			--��������������ʹ�ú�50ʱ��������
	WAR.SFB = {}			--������������ʹ�ú�30ʱ��������
	WAR.CSHF = {}			--�����ظ� 
	WAR.BTZT = {}			--����״̬ 	
	WAR.WQTS_WW = {}	    --����	
	WAR.JDYJ = {}			--��������������������
	WAR.SKZX= {}	
	WAR.WMYH = {}			--����ҵ��״̬������ʹ�õ�����һ�������
	WAR.TGJF = {}			--������ ͬ�齣��	
	
	WAR.JHLY = {}			--�޾Ʋ������ٻ���ԭ������+ȼľ+���浶
	WAR.LRHF = {}			--�޾Ʋ��������к��棬����+����+����
	WAR.XZD = {}			--����г֮��	
	WAR.SLSX = {}			--���֣�ʮ��ʮ��
	WAR.HMZT = {}			--����״̬
	WAR.YYZS= {}           --һ��ֹɱ
	WAR.HQT_ZL= {}           --����ָͩ��
	WAR.HQT_CD= 0           --����ָͩ��
	WAR.JYZT = {}			--���ϣ���ҩ״̬

	
	WAR.CSZT = {}			--��˯״̬

	WAR.SGZT = {}			--ɢ��״̬			
	WAR.PJZT = {}			--�ƾ�״̬
	WAR.PJJL = {}			--���ƾ�ǰ���ڹ���¼
	WAR.SGJL = {}			--ɢ��ǰ���ڹ���¼	
	
	WAR.YSJF = {}			--��ʯ���
	WAR.XLFD = {}			--С��ɵ�
    WAR.JTYJ = {}			--����һ��
	
	WAR.HLZT = {}			--����״̬
	WAR.MHZT = {}			--�Ȼ�״̬
	
	WAR.QYZT = {}			--����״̬
	WAR.WFZT = {}			--	
    WAR.CHZT = {}			--�ٻ�״̬
    WAR.JFJQ = {}			--����״̬��0	
	WAR.XRZT = {}			--����״̬
	WAR.ZYCD = 0
	WAR.XRZT1 = {}			--����״̬1
	WAR.XZBFZT = {}			    --Ѫս�˷�ZT
    WAR.WTL_PJTL= {}	
    WAR.WTL_1= {}	
	WAR.WMYS= {}
	WAR.JSZT1 ={}          --�𴦻���ʱ״̬�ѷ�
	
	WAR.JSZT2 ={}          --ͨ�ü�ʱ״̬�з�	
	WAR.QGZT = {}			--���״̬
	
	WAR.BiXieZhaoShi = {}        --��а��ʽ	
	WAR.BXLQ = {}				--��а��ȴ��¼
	WAR.BXCD = {0,1,0,1,2,3}	--��а��ȴʱ��

	--WAR.LXBHZS = 0					--�̺���ʽ
	--WAR.LXBHLQ = {}				--�̺���ȴ��¼	
   -- WAR.LXBHCD = {0,0,2,2,3,5}	--�̺���ȴʱ��	
	--WAR.LXBIHAIZhaoShi = {}        --�̺���ʽ

	WAR.JYLQ = {}				--������ȴ��¼	
	WAR.JYCD = {0,1,5}	       --����������ȴʱ��
	WAR.JIUYANGZhaoShi = {}     --������ʽ	
	

	WAR.SSESS = {}			--��ʮ������
	WAR.JGFX = {}			--½����շ���

	

	
	WAR.XYYF = {}			--��ң����
	
	WAR.XYYF_10 = 0			--���غ���ң�����ۻ���9��
	
	WAR.YFCS = 0			--��ң�������

	
	
	WAR.ZQTL = {}			--��������

	WAR.ZTHSB = 0			--���컯��
	WAR.ZT_id = -1			--�����˵�ID
	WAR.ZT_X = -1			--�����˵�X����
	WAR.ZT_Y = -1			--�����˵�Y����
	
	WAR.Miss = {}			--���ܵ�miss��ʾ
	
	WAR.MBJZ = {}			--�żһԵ���Խ�ָ
	WAR.SZZT = {}			--����	
    WAR.WTL_LDJT= {} 
    WAR.MRSHZT= {}   	
	--WAR.JHZT = {}	
	WAR.ZTHF = {}		
	--WAR.JHZT1 = {}	
	WAR.FHJZ = 0 			--�żһԵĸ����ָ
    WAR.FUHUOZT={}	
	WAR.YSJZ = 0 			--�żһԵ������ָ
	
	WAR.FW = {}
    WAR.Atid = -1
	CleanWarMap(7, 0)
end


--��ʾ�����ս����Ϣ������ͷ��������������
function WarShowHead(id)
	if not id then
		id = WAR.CurID
	end
	if id < 0 then
		return 
	end
	local pid = WAR.Person[id]["������"]
	local p = JY.Person[pid]
	local h = CC.FontSMALL
	local width = CC.FontSMALL*11 - 6
	local height = (CC.FontSMALL+CC.RowPixel)*9 - 12
	local x1, y1 = nil, nil
	local i = 1
	local size = CC.FontSmall3

	if WAR.Person[id]["�ҷ�"] == true then
		x1 = CC.ScreenW - width - 6
		y1 = CC.ScreenH - height - CC.ScreenH/6 -6
		lib.LoadPNG(91, 28 * 2 ,x1, y1+height+CC.ScreenH/30-253, 1)
	end
	if WAR.Person[id]["�ҷ�"] == false then		
        x1 = 10
        y1 = 35
	    lib.LoadPNG(91, 28 * 2 ,x1,y1-35, 1)	
	end
		 
	---------------------------------------------------------״̬��ʾ---------------------------------------------------------
	
	local zt_num = 0
	if WAR.ZDDH == 356 then 
		local ss = {[5] = '������',[27] = '�����',[50] = '�����',[114] = '����ɽ'}
		if WAR.PD["�����4"][pid] ~= nil then 
			local sm = ss[WAR.PD["�����4"][pid]]
			if WAR.Person[id]["�ҷ�"] == true then
				lib.LoadPNG(98, 101 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len(sm)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, sm, C_WHITE, size)				
			else
				lib.LoadPNG(98, 101 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, sm, C_WHITE, size)
			end
			zt_num = zt_num + 1
		end
	end
	
	--��������	
	if   WAR.PD["��������"][pid] ~= nil and WAR.PD["��������"][pid] > 0 then
		local tjzx = WAR.PD["��������"][pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��������:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��������:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��������:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	
	--ţ��ѪЫ��	
	if   WAR.PD["ţ��ѪЫ"][pid] ~= nil and WAR.PD["ţ��ѪЫ"][pid] > 0 then
		local tjzx = WAR.PD["ţ��ѪЫ"][pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("ţ��ѪЫ:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "ţ��ѪЫ:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "ţ��ѪЫ:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	
	--�����ⶾ��	
	if   WAR.PD["�����ⶾ"][pid] ~= nil and WAR.PD["�����ⶾ"][pid] > 0 then
		local tjzx = WAR.PD["�����ⶾ"][pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�����ⶾ:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�����ⶾ:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�����ⶾ:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	
	--С����	
	if   WAR.PD["С����"][pid] ~= nil and WAR.PD["С����"][pid] > 0 then
		local tjzx = WAR.PD["С����"][pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("С����:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "С����:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "С����:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	
	--����������	
	if   WAR.PD["��������"][pid] ~= nil and WAR.PD["��������"][pid] > 0 then
		local tjzx = WAR.PD["��������"][pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��������:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��������:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��������:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	
	--�����ܵ�	
	if   WAR.PD["�����ܵ�"][pid] ~= nil and WAR.PD["�����ܵ�"][pid] > 0 then
		local tjzx = WAR.PD["�����ܵ�"][pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�����ܵ�:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�����ܵ�:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�����ܵ�:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	--�屦���۾�	
	if   WAR.PD["�屦���۾�"][pid] ~= nil and WAR.PD["�屦���۾�"][pid] > 0 then
		local tjzx = WAR.PD["�屦���۾�"][pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�屦���۾�:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�屦���۾�:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)		
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�屦���۾�:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	--��ī�Ͼ�	
	if   WAR.PD["��ī�Ͼ�"][pid] ~= nil and WAR.PD["��ī�Ͼ�"][pid] > 0 then
		local tjzx = WAR.PD["��ī�Ͼ�"][pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��ī�Ͼ�:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��ī�Ͼ�:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)		
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��ī�Ͼ�:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	
	--��¶��	
	if   WAR.PD["��¶��"][pid] ~= nil and WAR.PD["��¶��"][pid] > 0 then
		local tjzx = WAR.PD["��¶��"][pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��¶��:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��¶��:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��¶��:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	--�滨��	
	if  WAR.PD["�滨��"][pid] ~= nil and WAR.PD["�滨��"][pid] > 0 then
		local tjzx = WAR.PD["�滨��"][pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�滨��:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�滨��:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)	
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�滨��:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end			
	--�����	
	if   WAR.PD["�����"][pid] ~= nil and WAR.PD["�����"][pid] > 0 then
		local tjzx = WAR.PD["�����"][pid] or 0

		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 98 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�����:"..tjzx.."��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�����:"..tjzx.."��", C_WHITE, size)				
		else
			lib.LoadPNG(98, 98 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�����:"..tjzx.."��", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
		--��
	if WAR.PD["��"][pid] ~= nil and WAR.PD["��"][pid] > 0 then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 134 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("��ȭӡ:�ػ�������")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��ȭӡ:�ػ�������", C_WHITE, size)
		else
			lib.LoadPNG(98, 134 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��ȭӡ:�ػ�������", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end			
		--ǰ
	if WAR.PD["ǰ"][pid] ~= nil and WAR.PD["ǰ"][pid] > 0 then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 133 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("��ƿӡ:������Χ����")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��ƿӡ:������Χ����", C_WHITE, size)
		else
			lib.LoadPNG(98, 133 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��ƿӡ:������Χ����", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
		--��
	if WAR.PD["��"][pid] ~= nil and WAR.PD["��"][pid] > 0 then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 132 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("����ӡ:����������")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "����ӡ:����������", C_WHITE, size)
		else
			lib.LoadPNG(98, 132 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����ӡ:����������", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	
		--��
	if WAR.PD["��"][pid] ~= nil and WAR.PD["��"][pid] > 0 then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 131 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("�ڸ�ӡ:����Ŀ������-200")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,  "�ڸ�ӡ:����Ŀ������-200", C_WHITE, size)
		else
			lib.LoadPNG(98, 131 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�ڸ�ӡ:����Ŀ������-200", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
		--��
	if WAR.PD["��"][pid] ~= nil and WAR.PD["��"][pid] > 0 then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 130 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("�⸿ӡ:�����ƶ�-3")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�⸿ӡ:�����ƶ�-3", C_WHITE, size)
		else
			lib.LoadPNG(98, 130 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�⸿ӡ:�����ƶ�-3", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
		--��
	if WAR.PD["��"][pid] ~= nil and WAR.PD["��"][pid] > 0 then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 129 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("��ʨ��ӡ:��������500")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��ʨ��ӡ:��������500", C_WHITE, size)
		else
			lib.LoadPNG(98, 129 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��ʨ��ӡ:��������500", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
		--��
	if WAR.PD["��"][pid] ~= nil and WAR.PD["��"][pid] > 0 then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 128 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("��ʨ��ӡ:��������500")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,  "��ʨ��ӡ:��������500", C_WHITE, size)
		else
			lib.LoadPNG(98, 128 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��ʨ��ӡ:��������500", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
		--��
	if WAR.PD["��"][pid] ~= nil and WAR.PD["��"][pid] > 0 then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 127 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("������ӡ:�Ʒ�40%")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,  "������ӡ:�Ʒ�40%", C_WHITE, size)
		else
			lib.LoadPNG(98, 127 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "������ӡ:�Ʒ�40%", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
		--��
	if WAR.PD["��"][pid] ~= nil and WAR.PD["��"][pid] > 0 then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 126 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("��������ӡ:����50��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��������ӡ:����50��", C_WHITE, size)
		else
			lib.LoadPNG(98, 126 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��������ӡ:����50��", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
    
		--���˺�һ
	if WAR.PD["���ϵ�������"][pid] ~= nil and WAR.PD["���ϵ�������"][pid] > 0 then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 49 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("���˺�һ")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "���˺�һ", C_WHITE, size)
		else
			lib.LoadPNG(98, 49 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "���˺�һ", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
    
	--���ϲе�
	if WAR.PD["���ϵ����е�"][pid] ~= nil then
        local cs = 0
        local sx = 0
        if WAR.PD["���ϵ����е�"][pid][1] ~= nil then 
            cs = WAR.PD["���ϵ����е�"][pid][1]..'��'
        end
        if WAR.PD["���ϵ����е�"][pid][2] ~= nil then 
            sx = WAR.PD["���ϵ����е�"][pid][2]..'ʱ��'
        end
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 135 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��е�ȱ:"..cs..sx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,"��е�ȱ:"..cs..sx, C_GOLD, size)
		else
			lib.LoadPNG(98, 135 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��е�ȱ:"..cs..sx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    
	--Ѫս�˷�
	if WAR.XZBFZT[pid] ~= nil and WAR.XZBFZT[pid] > 0  then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 107 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("Ѫս�˷�:" .. WAR.XZBFZT[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "Ѫս�˷�:"..WAR.XZBFZT[pid], C_WHITE, size)
		else
			lib.LoadPNG(98, 107 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "Ѫս�˷�:" .. WAR.XZBFZT[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--ֹɱCD	
	if  match_ID(pid, 68) and WAR.JSZT1[pid] ~= nil then
	local tjzx = WAR.JSZT1[pid] or 0
		if tjzx == 0 then
			if WAR.Person[id]["�ҷ�"] == true then
				lib.LoadPNG(98, 58 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("ֹɱCD:"..tjzx.."�غ�")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "ֹɱCD:"..tjzx.."�غ�", C_WHITE, size)
			else
				lib.LoadPNG(98, 58 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "ֹɱ��ʹ��", C_WHITE, size)
			end
		else
			if WAR.Person[id]["�ҷ�"] == true then
				lib.LoadPNG(98, 57 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
				DrawString(CC.ScreenW/936*550, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "ֹɱCD:"..tjzx.."�غ�", C_WHITE, size)
				 DrawString(CC.ScreenW/936*705-string.len("ֹɱCD:"..tjzx.."�غ�")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "ֹɱCD:"..tjzx.."�غ�", C_WHITE, size)
			else
				lib.LoadPNG(98, 57 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num,"ֹɱ��ʹ��", C_WHITE, size)
			end
		end
		zt_num = zt_num + 1
	end	
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
			--��̩����ʱCD����ʱ��ȷ����
	if  match_ID(pid, 151) and WAR.WTL_1[pid] ~= nil then
	        local tjzx = WAR.WTL_1[pid] or 0
		    if tjzx == 0 then
				if WAR.Person[id]["�ҷ�"] == true then
					lib.LoadPNG(98, 125 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )			
					 DrawString(CC.ScreenW/936*705-string.len("��̩��CD:"..tjzx.."ʱ��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��̩��CD:"..tjzx.."ʱ��", C_WHITE, size)
				else
					lib.LoadPNG(98, 6 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
					DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��̩������", C_WHITE, size)
				end
			else
				if WAR.Person[id]["�ҷ�"] == true then
					lib.LoadPNG(98, 125 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				  DrawString(CC.ScreenW/936*705-string.len("��̩��CD:"..tjzx.."ʱ��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��̩��CD:"..tjzx.."ʱ��", C_WHITE, size)
				else
					lib.LoadPNG(98, 8 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
					DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num,"��̩��CD:"..tjzx.."ʱ��", C_WHITE, size)
				end
			end
			zt_num = zt_num + 1
	end	
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--������ʾ
	if WAR.FUHUOZT[pid]~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 1 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
         DrawString(CC.ScreenW/936*705-string.len("�Ѹ���")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�Ѹ���", C_WHITE, size)			
		else
			lib.LoadPNG(98, 1 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3, "�Ѹ���", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--�������ʾ
	if match_ID(pid, 577) then
		local tjzx = WAR.WFCZ[pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 25 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�����:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�����:"..tjzx, C_GOLD, size)	
		else
			lib.LoadPNG(98, 25 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�����:"..tjzx, C_GOLD , size)
		end
		zt_num = zt_num + 1
	end	
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--̫��֮����ʾ
	if Curr_NG(pid, 171) then
		local tjzx = WAR.TJZX[pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 2 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("̫��֮��:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "̫��֮��:"..tjzx, C_GOLD, size)
		else
			lib.LoadPNG(98, 2 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "̫��֮��:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--������ʾ
	if match_ID(pid, 586) then
		local qf = WAR.HZD_QF[pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 70 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )			
           DrawString(CC.ScreenW/936*705-string.len("����:"..qf)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "����:"..qf, C_GOLD, size)			
		else
			lib.LoadPNG(98, 70 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����:"..qf, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	
	--���ٲ���ʾ
	if pid == 0 and JY.Person[615]["�۽�����"] == 1 then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 3 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
           DrawString(CC.ScreenW/936*705-string.len("���ٲ�����")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "���ٲ�����", C_GOLD, size)			
		else
			lib.LoadPNG(98, 3 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "���ٲ�����", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end


	
	--����ɺ�������齣��ʾ
	if match_ID(pid, 79) then
		local JF = 0
		for i = 1, JY.Base["�书����"] do
			if JY.Wugong[JY.Person[pid]["�书" .. i]]["�书����"] == 3 then
				JF = JF + 1
			end
		end
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 4 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�����齣:"..JF)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�����齣:"..JF, C_GOLD, size)
		else
			lib.LoadPNG(98, 4 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�����齣:"..JF, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--����������ʾ
	if JiandanQX(pid) then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 5 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��������")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��������", C_GOLD, size)
		else
			lib.LoadPNG(98, 5 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��������", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--����ҵ����ʾ	
	if WAR.WMYH[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 6 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("����ҵ��:"..WAR.WMYH[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "����ҵ��:"..WAR.WMYH[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 6 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����ҵ��:"..WAR.WMYH[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--������1 ͬ�齣��	
	if WAR.TGJF[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 6 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("ͬ��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "ͬ��", C_GOLD, size)
		else
			lib.LoadPNG(98, 6 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "ͬ��", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--�����޷���ʾ
	if TianYiWF(pid) then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 7 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�����޷�")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�����޷�", C_GOLD, size)
		else
			lib.LoadPNG(98, 7 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�����޷�", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--��������
	if WAR.WMYS[pid]~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 109 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
	        DrawString(CC.ScreenW/936*705-string.len("��������")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��������", C_GOLD, size)			
		else
			lib.LoadPNG(98, 109 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��������", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--�޾Ʋ������ٻ���ԭ������+ȼľ+���浶�������ȼЧ��
	if WAR.JHLY[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 8 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��ȼ״̬:"..WAR.JHLY[pid].."ʱ��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��ȼ״̬:"..WAR.JHLY[pid].."ʱ��", C_GOLD, size)			
		else
			lib.LoadPNG(98, 8 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��ȼ״̬:"..WAR.JHLY[pid].."ʱ��", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--�޾Ʋ��������к��棬����+����+���飬��ɶ���Ч��
	if WAR.LRHF[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 9 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("����״̬:"..WAR.LRHF[pid].."ʱ��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,"����״̬:"..WAR.LRHF[pid].."ʱ��", C_GOLD, size)
		else
			lib.LoadPNG(98, 9 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����״̬:"..WAR.LRHF[pid].."ʱ��", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--�޾Ʋ���������ս������Ŀ��
	if pid == WAR.SZSD then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 10 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("��սĿ��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��սĿ��", C_GOLD, size)
		else
			lib.LoadPNG(98, 10 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��սĿ��", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--�޾Ʋ��������� ʮ��ʮ��״̬
	if WAR.SLSX[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 11 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("ʮ��ʮ��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "ʮ��ʮ��", C_GOLD, size)
		else
			lib.LoadPNG(98, 11 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "ʮ��ʮ��", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--�޾Ʋ���������״̬
	if WAR.HMZT[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 12 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("����״̬")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "����״̬", C_GOLD, size)
		else
			lib.LoadPNG(98, 12 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����״̬", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--�޾Ʋ�������������ɳ��
	if match_ID(pid, 47) then
		local tjzx = WAR.TJZX[pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 13 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
            DrawString(CC.ScreenW/936*705-string.len("����ɳ��:" .. WAR.MZSH)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "����ɳ��:" .. WAR.MZSH, C_GOLD, size)
		else
			lib.LoadPNG(98, 13 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����ɳ��:" .. WAR.MZSH, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--̫������
	if WAR.PD["̫������"][pid]~= nil and WAR.PD["̫������"][pid] > 0 then	
		local tjzx = WAR.PD["̫������"][pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 104 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("̫������ֵ:" .. WAR.PD["̫������"][pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "̫������ֵ:" .. WAR.PD["̫������"][pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 104 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "̫������ֵ:" .. WAR.PD["̫������"][pid], C_WHITE, size*0.8)
		end
		zt_num = zt_num + 1
	end	
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--��󡹦����
	if WAR.PD["�������"][pid]~= nil and WAR.PD["�������"][pid] > 0 then	
		local tjzx = WAR.PD["�������"][pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 95 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�������ֵ:" .. WAR.PD["�������"][pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�������ֵ:" .. WAR.PD["�������"][pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 95 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�������ֵ:" .. WAR.PD["�������"][pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--��Ϣ������
	if WAR.PD["��Ϣ����"][pid]~= nil and WAR.PD["��Ϣ����"][pid] > 0 then	
		local tjzx = WAR.PD["��Ϣ����"][pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 89 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��Ϣ����ֵ:" .. WAR.PD["��Ϣ����"][pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��Ϣ����ֵ:" .. WAR.PD["��Ϣ����"][pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 89 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��Ϣ����ֵ:" .. WAR.PD["��Ϣ����"][pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--�޾Ʋ��������Ͻ�ҩ״̬
	if WAR.JYZT[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 14 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��ҩ״̬")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��ҩ״̬", C_GOLD, size)
		else
			lib.LoadPNG(98, 14 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��ҩ״̬", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--�޾Ʋ�������˯״̬
	if WAR.CSZT[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 15 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��˯״̬")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��˯״̬", C_GOLD, size)
		else
			lib.LoadPNG(98, 15 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��˯״̬", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--�޾Ʋ������������ʯ���
	if WAR.YSJF[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 16 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��ʯ���:" .. WAR.YSJF[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��ʯ���:" .. WAR.YSJF[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 16 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��ʯ���:" .. WAR.YSJF[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--�޾Ʋ���������״̬
	if WAR.HLZT[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 18 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("����״̬:" .. WAR.HLZT[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "����״̬:" .. WAR.HLZT[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 18 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����״̬:" .. WAR.HLZT[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--ɢ��״̬
	if WAR.SGZT[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 17 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("ɢ��״̬:" .. WAR.SGZT[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "ɢ��״̬:" .. WAR.SGZT[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 17 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "ɢ��״̬:" .. WAR.SGZT[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	--[[��������״̬
	if WAR.TXSH[pid] ~= nil  then
			if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 22 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("����״̬")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "����״̬", C_GOLD, size)
		else
			lib.LoadPNG(98, 22 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����״̬", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	]]
    
	--����״̬
	if WAR.WTL_LDJT[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 116 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("����" .. WAR.WTL_LDJT[pid].."��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "����" .. WAR.WTL_LDJT[pid].."��", C_GOLD, size)
		else
			lib.LoadPNG(98, 116 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����" .. WAR.WTL_LDJT[pid].."��", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--�������� �κ�Ч��״̬
	if WAR.MRSHZT[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 116 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�κ�" .. WAR.MRSHZT[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�κ�" .. WAR.MRSHZT[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 116 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�κ�" .. WAR.MRSHZT[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	--�޾Ʋ���������״̬
	if WAR.QYZT[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 19 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("����" .. WAR.QYZT[pid].."��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "����" .. WAR.QYZT[pid].."��", C_GOLD, size)
		else
			lib.LoadPNG(98, 19 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����" .. WAR.QYZT[pid].."��", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--ֹɱ״̬
	if WAR.YYZS[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 58 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��������")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "ֹɱ״̬", C_GOLD, size)
		else
			lib.LoadPNG(98, 58 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "ֹɱ״̬:" .. WAR.YYZS[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	--����ָͩ��״̬
	if WAR.HQT_ZL[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 117 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��������:" .. WAR.HQT_ZL[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��������:" .. WAR.HQT_ZL[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 117 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��������:" .. WAR.HQT_ZL[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	--÷����͵�컻��
	if WAR.PD["͵�컻��"][pid] ~= nil  then
	 if  WAR.PD["͵�컻��"][pid] >= 100  then
			if WAR.Person[id]["�ҷ�"] == true then
				lib.LoadPNG(98, 85 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("͵�컻��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "͵�컻��", C_GOLD, size)
			else
				lib.LoadPNG(98, 85 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "͵�컻��", C_WHITE, size)
			end
		   else
			if WAR.Person[id]["�ҷ�"] == true then
				lib.LoadPNG(98, 66 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("�𺮶�����:" .. WAR.PD["͵�컻��"][pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�𺮶�����:" .. WAR.PD["͵�컻��"][pid], C_GOLD, size)
			else
				lib.LoadPNG(98, 66 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num,"�𺮶�����:" .. WAR.PD["͵�컻��"][pid], C_WHITE, size)
			end
			end
		zt_num = zt_num + 1
	end		
	--������ظ� ������
	if WAR.ZTHF[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 110 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len( "������:" .. WAR.ZTHF[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,  "������:" .. WAR.ZTHF[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 110 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "������:" .. WAR.ZTHF[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--�޾Ʋ���������״̬
	if WAR.XRZT[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 20 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("����״̬:" .. WAR.XRZT[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "����״̬:" .. WAR.XRZT[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 20 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����״̬:" .. WAR.XRZT[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--����״̬1
	if WAR.XRZT1[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 20 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("����״̬:" .. WAR.XRZT1[pid].."�غ�")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "����״̬:" .. WAR.XRZT1[pid].."�غ�", C_GOLD, size)
		else
			lib.LoadPNG(98, 20 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����״̬:" .. WAR.XRZT1[pid].."�غ�", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--��������
	if WAR.PD["��������"][pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 20 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�˺�����:" .. WAR.PD["��������"][pid].."�غ�")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�˺�����:" .. WAR.PD["��������"][pid].."�غ�", C_GOLD, size)
		else
			lib.LoadPNG(98, 20 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�˺�����:" .. WAR.PD["��������"][pid].."�غ�", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	--�Ȼ�״̬
	if WAR.MHZT[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 40 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�Ȼ�״̬:" .. WAR.MHZT[pid].."�غ�")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�Ȼ�״̬:" .. WAR.MHZT[pid].."�غ�", C_GOLD, size)
		else
			lib.LoadPNG(98, 40 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�Ȼ�״̬:" .. WAR.MHZT[pid].."�غ�", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	--�޾Ʋ��������״̬
	if WAR.QGZT[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 21 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("���ʣ��" .. WAR.QGZT[pid].."��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "���ʣ��" .. WAR.QGZT[pid].."��", C_GOLD, size)
		else
			lib.LoadPNG(98, 21 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "���ʣ��" .. WAR.QGZT[pid].."��", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--�޾Ʋ�����äĿ״̬
	if WAR.KHCM[pid] == 2 then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 22 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("äĿ״̬")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "äĿ״̬", C_GOLD, size)
		else
			lib.LoadPNG(98, 22 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "äĿ״̬", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
		
	--�޾Ʋ������伲���
	--if WAR.FLHS1 == 1 and match_ID(pid,27) and WAR.ZDDH == 348  then
	if WAR.PD['�����'][pid] == 1 then	
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 24 * 2 ,  CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�伲���")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�伲���", C_GOLD, size)
		else
			lib.LoadPNG(98, 24 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�伲���", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	
--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
 if WAR.SSESS[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 25 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("һ����:" .. WAR.SSESS[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "һ����:" .. WAR.SSESS[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 25 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "һ����:" .. WAR.SSESS[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--½����շ���
   if WAR.JGFX[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 11 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��շ���:" .. WAR.JGFX[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,"��շ���:" .. WAR.JGFX[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 11 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��շ���:" .. WAR.JGFX[pid], C_WHITE, size)
		end
				zt_num = zt_num + 1
	end
	--��Ѱ�� ��������ˮ
	if match_ID(pid,498) then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 3 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��������ˮ����")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��������ˮ����", C_GOLD, size)
		else
			lib.LoadPNG(98, 3 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��������ˮ����", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
		--��Ѱ�� С��ɵ�
	if WAR.XLFD[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 26 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�����鷢:" .. WAR.XLFD[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�����鷢:" .. WAR.XLFD[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 26 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�����鷢:" .. WAR.XLFD[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
		--����ˮ �콣BUFF
	if WAR.JTYJ[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 55 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len( "�콣:" .. WAR.JTYJ[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,  "�콣:" .. WAR.JTYJ[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 55 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�콣:" .. WAR.JTYJ[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end				
	
	--����״̬
	if WAR.Focus[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 14 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�����һ")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�����һ", C_GOLD, size)
		else
			lib.LoadPNG(98, 14 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�����һ", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end

	--̩ɽʮ���̣�������
	if WAR.TSSB[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 27 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("������:"..WAR.TSSB[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "������:"..WAR.TSSB[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 27 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "������:"..WAR.TSSB[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end

	--�������ɣ����������
	if WAR.QLJX[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 52 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("���������:"..WAR.QLJX[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "���������:"..WAR.QLJX[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 52 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "���������:"..WAR.QLJX[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	
		--�������� �ظ�
	if WAR.CSHF[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 14 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��������:"..WAR.CSHF[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��������:"..WAR.CSHF[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 14 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��������:"..WAR.CSHF[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end

		--�������� �ظ�
	if WAR.PD['������'][pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 67 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�˵�����:"..WAR.PD['������'][pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��������:"..WAR.PD['������'][pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 67 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�˵�����:"..WAR.PD['������'][pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    
	--��ң����
	if XiaoYaoYF(pid) then
		local count = WAR.XYYF[pid] or 0
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 28 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��ң����:"..count)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��ң����:"..count, C_GOLD, size)
		else
			lib.LoadPNG(98, 28 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��ң����:"..count, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--���״̬
	if WAR.MBJZ[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 29 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("��ԣ��ƶ�-"..WAR.MBJZ[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��ԣ��ƶ�-"..WAR.MBJZ[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 29 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��ԣ��ƶ�-"..WAR.MBJZ[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--����״̬
	if WAR.SZZT[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 29 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("����״̬")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "����״̬", C_GOLD, size)
		else
			lib.LoadPNG(98, 29 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����״̬", C_WHITE, size)
				end	
		zt_num = zt_num + 1
	end	
		--�ٻ�״̬
	if WAR.CHZT[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 64 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("�ٻ�" .. WAR.CHZT[pid].."��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�ٻ�" .. WAR.CHZT[pid].."��", C_GOLD, size)
		else
			lib.LoadPNG(98, 64 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�ٻ�" .. WAR.CHZT[pid].."��", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--���缯��״̬
	if WAR.JFJQ[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 47 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("����" .. WAR.JFJQ[pid].."��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "����" .. WAR.JFJQ[pid].."��", C_GOLD, size)
		else
			lib.LoadPNG(98, 47 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����" .. WAR.JFJQ[pid].."��", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	--����״̬
	if WAR.BTZT[pid] ~= nil then
		if WAR.Person[id]["�ҷ�"] == true then
			lib.LoadPNG(98, 8 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("����״̬")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "����״̬", C_GOLD, size)
		else
			lib.LoadPNG(98, 8 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "����״̬", C_WHITE, size)
				end	
		zt_num = zt_num + 1
	end	
	--�żһԵ������ָ
	if JY.Person[pid]["����"] == 304 then
		if WAR.YSJZ == 0 then
			if WAR.Person[id]["�ҷ�"] == true then
				lib.LoadPNG(98, 30 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("�����С���")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�����С���", C_GOLD, size)
			else
				lib.LoadPNG(98, 30 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�����С���", C_WHITE, size)
			end
		else
			if WAR.Person[id]["�ҷ�"] == true then
				lib.LoadPNG(98, 31 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("�´�����:"..WAR.YSJZ)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "�´�����:"..WAR.YSJZ, C_GOLD, size)
			else
				lib.LoadPNG(98, 31 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "�´�����:"..WAR.YSJZ, C_WHITE, size)
			end
		end
		zt_num = zt_num + 1
	end
	--��ӹ����CD
	if ZhongYongZD(pid) then
        local cd = WAR.PD['��ӹ'][pid] or 0
        local mcd = limitX(JY.Person[pid]['����'] - 1,30) - cd

        --if cd == 0  then
            --[[
			if WAR.Person[id]["�ҷ�"] == true then
				lib.LoadPNG(98, 124 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("��ӹ����")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��ӹ����", C_GOLD, size)
			else
				lib.LoadPNG(98, 124 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��ӹ����", C_WHITE, size)
			end
		else
            ]]
			if WAR.Person[id]["�ҷ�"] == true then
				lib.LoadPNG(98, 124 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("��ӹCD:"..mcd)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "��ӹCD:"..mcd, C_GOLD, size)
			else
				lib.LoadPNG(98, 124 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "��ӹCD:"..mcd, C_WHITE, size)
			end
		--end
		zt_num = zt_num + 1
	end
	--ָ��CD
	if  match_ID(pid,74) then
	 if  WAR.HQT_CD == 0  then
			if WAR.Person[id]["�ҷ�"] == true then
				lib.LoadPNG(98, 118 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("ָ�ӿ�ʹ��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "ָ�ӿ�ʹ��", C_GOLD, size)
			else
				lib.LoadPNG(98, 118 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "ָ�ӿ�ʹ��", C_WHITE, size)
			end
		   else
			if WAR.Person[id]["�ҷ�"] == true then
				lib.LoadPNG(98, 119 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("ָ��CD:"..WAR.HQT_CD.."ʱ��")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "ָ��CD:"..WAR.HQT_CD.."ʱ��", C_GOLD, size)
			else
				lib.LoadPNG(98, 119 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num,"ָ��CD:"..WAR.HQT_CD.."ʱ��", C_WHITE, size)
			end
			end
		zt_num = zt_num + 1
	end		
	--------------------------------------------------------------------------------------------------------------------------

	local headw, headh = lib.GetPNGXY(1, p["������"])
	local headx = (width - headw) / 2
	local heady = (CC.ScreenH/5 - headh) / 2
	--ͷ����Ϣ
	local headid = JY.Person[pid]["������"]
	if WAR.Person[id]["�ҷ�"] then
        lib.LoadPNG(1, headid*2, CC.ScreenW/936*849,CC.ScreenH/702*421, 2)
	else
        lib.LoadPNG(1, headid*2, CC.ScreenW/936*99,CC.ScreenH/702*73, 2)
    end
	x1 = x1 + CC.RowPixel
	y1 = y1 + CC.RowPixel + CC.ScreenH/6 - 12
	local color = nil
	if p["���˳̶�"] < p["�ж��̶�"] then
		if p["�ж��̶�"] == 0 then
			color = RGB(252, 148, 16)
		elseif p["�ж��̶�"] < 50 then
			color = RGB(120, 208, 88)
		else
			color = RGB(56, 136, 36)
		end
	elseif p["���˳̶�"] < 33 then
		color = RGB(236, 200, 40)
	elseif p["���˳̶�"] < 66 then
		color = RGB(244, 128, 32)
	else
		color = RGB(232, 32, 44)
	end
	local yy1 = y1 + CC.RowPixel + CC.ScreenH/15 - 100
	local zi = {}
	local name = p["����"]
    local namelen  = string.len(name) / 2	
	for i = 1,namelen do
		zi[i] = string.sub(name, i * 2 - 1, i * 2)
		DrawString(x1, yy1+12-100, zi[i], color, CC.DefaultFont*0.9)
		yy1 = yy1 + CC.DefaultFont*0.9
	end
	--���˹�ʱ����ʾ
	local ayy1 = y1 + CC.RowPixel + CC.ScreenH/10 +CC.DefaultFont-8
	if p["�����ڹ�"] > 0 then
		--DrawString(x1 + 8, y1 + CC.RowPixel + CC.DefaultFont, "�˹�", MilkWhite, size)
		DrawString(x1+50, ayy1-47-CC.DefaultFont*2,JY.Wugong[p["�����ڹ�"]]["����"], TG_Red_Bright, CC.DefaultFont*0.7)
		else
		DrawString(x1+50, ayy1-47-CC.DefaultFont*2,"��", TG_Red_Bright, CC.DefaultFont*0.7)
	--end		
end	
	--���Ṧʱ����ʾ
	local ayy2 =y1 + CC.RowPixel + CC.ScreenH/10 +CC.DefaultFont-5
	if p["�����Ṧ"] > 0 then
	DrawString(x1+50, ayy2-30-CC.DefaultFont*2, JY.Wugong[p["�����Ṧ"]]["����"], M_DeepSkyBlue, CC.DefaultFont*0.7)
	else
	DrawString(x1+50, ayy2-30-CC.DefaultFont*2, "��", M_DeepSkyBlue, CC.DefaultFont*0.7)
	

  end	
	--��ɫ��
	local pcx = x1 + 3 - CC.RowPixel + 2;
	local pcy = y1 + CC.RowPixel +1+30
    local pcx1 = x1 + 3 - CC.RowPixel + 2+9;	
	--������
	lib.LoadPNG(91, 35 * 2 , pcx  , pcy, 1)
	local pcw, pch = lib.GetPNGXY(91, 31 * 2);  
	lib.SetClip(pcx1, pcy, pcx1 + (p["����"]/p["�������ֵ"])*(pcw-10), pcy + pch)
	lib.LoadPNG(91, 31 * 2 , pcx  , pcy, 1)
	pcy = pcy + CC.RowPixel + size -2
	lib.SetClip(0,0,0,0)
  
	--������
	lib.LoadPNG(91, 35 * 2 , pcx  , pcy, 1)
	local pcw, pch = lib.GetPNGXY(91, 32 * 2);
	lib.SetClip(pcx1, pcy, pcx1+ (p["����"]/p["�������ֵ"])*(pcw-18), pcy+ pch)
	lib.LoadPNG(91, 32 * 2 , pcx  , pcy, 1)
	pcy = pcy + CC.RowPixel + size -2
	lib.SetClip(0,0,0,0)
  
	--������
	lib.LoadPNG(91, 35 * 2 , pcx  , pcy, 1)
	local pcw, pch = lib.GetPNGXY(91, 34 * 2);
	lib.SetClip(pcx, pcy, pcx + (p["����"]/100)*(pcw-10), pcy + pch)
	lib.LoadPNG(91, 34 * 2 , pcx  , pcy, 1)
	pcy = pcy + CC.RowPixel + size -2
	lib.SetClip(0,0,0,0)
  
	local lifexs = "�� "..p["����"]
	local nlxs = "�� "..p["����"]
	local tlxs = "�� "..p["����"]
	local lqzxs = WAR.LQZ[pid] or 0;	--ŭ��
	local zdxs = p["�ж��̶�"]
  
	local nsxs = p["���˳̶�"];		--����
	local bfxs = p["����̶�"];		--����
	local zsxs = p["���ճ̶�"];		--����
	local fxxs = WAR.FXDS[pid] or 0;		--��Ѩ
	local lxxs = WAR.LXZT[pid] or 0;		--��Ѫ
  
	DrawString(x1 + 9, y1 + CC.RowPixel + 6+29, lifexs, M_White, CC.FontSMALL)
	DrawString(x1 + 9, y1 + CC.RowPixel + size + 11+29, nlxs, M_White, CC.FontSMALL)
	DrawString(x1 + 9, y1 + CC.RowPixel + 2*size + 16+29, tlxs, M_White, CC.FontSMALL)

	y1 = y1 + 3*(CC.RowPixel + size) + 4
  	
  	local myx1 = 3;
  	local myy1 = 28;
	--ŭ��
	--DrawString(x1 + myx1, y1 + myy1, "ŭ��", C_RED, size)
	if lqzxs == 100 then
		lqzxs = "��"
	end
	DrawString(x1 + myx1 + size*2 + 10, y1 + myy1, lqzxs, C_RED, size)
	--����
	--myx1 = myx1 + size * 4;
	--DrawString(x1 + myx1, y1 + myy1, "����", M_DeepSkyBlue, size)
	--if pid == 0 then
		--DrawString(x1 + size*5/2 + myx1, y1 + myy1, WAR.FLHS2, M_DeepSkyBlue, size)
	--else
		--DrawString(x1 + size*5/2 + myx1, y1 + myy1, "��", M_DeepSkyBlue, size)
	--end
	--����
	myx1 = 3;
	myy1 = myy1 + size + 2;
	DrawString(x1 + myx1 + size*2 + 10, y1 + myy1, bfxs, M_LightBlue, size)
	--����
	myx1 = myx1 + size * 4;
  	DrawString(x1 + size*5/2 + myx1, y1 + myy1, zsxs, C_ORANGE, size)
	--��Ѩ
	myx1 = 3;
	myy1 = myy1 + size + 2;
	if fxxs == 50 then
		fxxs = "��"
	end
	DrawString(x1 + myx1 + size*2 + 10, y1 + myy1, fxxs, C_GOLD, size)
	--��Ѫ
	myx1 = myx1 + size * 4;
	if lxxs == 100 then
		lxxs = "��"
	end
  	DrawString(x1 + size*5/2 + myx1, y1 + myy1, lxxs, M_DarkRed, size)
	--����
	myx1 = 3;
	myy1 = myy1 + size + 2;
	if nsxs == 100 then
		nsxs = "��"
	end
	DrawString(x1 + myx1 + size*2 + 10, y1 + myy1, nsxs, PinkRed, size)
	--�ж�
	myx1 = myx1 + size * 4;
	if zdxs == 100 then
		zdxs = "��"
	end
  	DrawString(x1 + size*5/2 + myx1, y1 + myy1, zdxs, LimeGreen, size)	
	
	if WAR.Person[id]["�ҷ�"] == false then
		y1 = y1 + 3*(CC.RowPixel + size) +12
	   lib.LoadPNG(91, 27 * 2 ,x1-6,y1+25, 1)	 
		local hl = 1
		for i = 1, 4 do
			local wp = p["Я����Ʒ" .. i]
			local wps = p["Я����Ʒ����" .. i]
			if wp >= 0 then
				local wpm = JY.Thing[wp]["����"]
				DrawString(x1+2, y1 + hl * (size+CC.RowPixel) , wpm .. wps, C_WHITE, size)
				hl = hl + 1
			end
		end
	end
end

--�Զ�ѡ����ʵ��书
function War_AutoSelectWugong()
	local pid = WAR.Person[WAR.CurID]["������"]
	local probability = {}
	local wugongnum = JY.Base["�书����"]
	for i = 1, JY.Base["�书����"] do
		local wugongid = JY.Person[pid]["�书" .. i]
		if wugongid > 0 then
			if JY.Wugong[wugongid]["�˺�����"] == 0 then
		  
				--ѡ��ɱ�������书������������������������С��������Է���һ�����书��
				if JY.Wugong[wugongid]["������������"] <= JY.Person[pid]["����"] then
					local level = math.modf(JY.Person[pid]["�书�ȼ�" .. i] / 100) + 1
					probability[i] = get_skill_power(pid, wugongid, level)	--�޾Ʋ����������¹�ʽ
				else
					probability[i] = 0
				end
				
				--�Ṧ���ɹ����ؼ����ɹ���
				if JY.Wugong[wugongid]["�书����"] == 7 or wugongid == 85 or wugongid == 87 or wugongid == 88 or wugongid == 144 or wugongid == 175  or wugongid == 182  or wugongid == 199 or wugongid == 43  then
					probability[i] = 0
				end
					
				--�ڹ�����
				if JY.Wugong[wugongid]["�书����"] == 6 then
				
					if inteam(pid) == false and i == 1 then 				--NPC���õ�һ���ڹ�
					
					elseif pid == 0 and JY.Base["����"] > 0 and i == 1 then --������õ�һ���ڹ�
			  
					elseif wugongid == 105 and (match_ID(pid, 36) or match_ID(pid, 27))then		--��ƽ֮ ���� ʹ�ÿ�����
					
					elseif wugongid == 102 and match_ID_awakened(pid, 38, 1) then		--ʯ���� ʹ��̫����
					elseif wugongid == 106 and match_ID(pid, 638) then		--����ɮ ������					
					
					elseif wugongid == 106 and match_ID(pid, 9) then		--���޼� ʹ�þ�����
					
					elseif wugongid == 94 and match_ID(pid, 37) then		--���� ʹ������
					
					elseif wugongid == 108 and match_ID(pid, 114) then		--ɨ�� ʹ���׽
					
					elseif wugongid == 93 and match_ID(pid, 66) then		--С�� ʹ��ʥ��
					
					elseif wugongid == 104 and match_ID(pid, 60) then		--ŷ���� ʹ������
					
					elseif wugongid == 103 and (match_ID(pid, 39) or match_ID(pid, 40))then		--���͵��� ʹ������
						
					elseif (pid == 0 and GetS(4, 5, 5, 5) == 5) or match_ID(pid, 9985)  then		--��� ��̹֮ ʹ���ڹ�
						
					else
						probability[i] = 0
					end
				end

				--��ת����
				if wugongid == 43 and match_ID(pid, 51) == false then
					probability[i] = 0
				end
				
				--�Ƿ岻�ô�
				if wugongid == 80 and pid == 50 then
					probability[i] = 0
				end
				
				--��ҩʦ����������Ӣ
				if (wugongid == 12 or wugongid == 38) and pid == 57 then
					probability[i] = 0
				end
				
				--�ܲ�ͨ����̫��ȭ
				if wugongid == 16 and pid == 64 then
					probability[i] = 0
				end
				
				--��ʮ��ŷ���治�����˸��
				if (wugongid == 95 or wugongid == 104) and pid == 60 and WAR.ZDDH == 289 then
					probability[i] = 0
				end
					
				--�������ֲ�������
				--��аս������������
				--��ʮ��������
				if wugongid == 103 and pid == 62 and (WAR.ZDDH == 275 or WAR.ZDDH == 277 or WAR.ZDDH == 289) then
					probability[i] = 0
				end
				
				--���������һ�������罣
				if wugongid == 44 and pid == 633 and WAR.ZDDH == 280 then
					probability[i] = 0
				end
				
				--����������˷ﲻ�ú���
				if wugongid == 67 and pid == 3 and WAR.ZDDH == 280 then
					probability[i] = 0
				end
				
				--��������������������������
				if pid == 22 and (wugongid == 30 or wugongid == 31 or wugongid == 32 or wugongid == 34) then
					probability[i] = 0
				end
			else
				probability[i] = 0		 --�Զ�����ɱ����
			end
		else
			wugongnum = i - 1
			break;
		end
	end
  
	if wugongnum ==  0 then			--���û���书��ֱ�ӷ���-1
		return -1;
	end

	local maxoffense = 0			--������󹥻���
	for i = 1, wugongnum do
		if maxoffense < probability[i] then
			maxoffense = probability[i]
		end
	end
	
	local mynum = 0					--�����ҷ��͵��˸���
	local enemynum = 0
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["����"] == false then
			if WAR.Person[i]["�ҷ�"] == WAR.Person[WAR.CurID]["�ҷ�"] then
				mynum = mynum + 1
			else
				enemynum = enemynum + 1
			end
		end
	end
	
	
	local factor = 0			--��������Ӱ�����ӣ����˶��������ȹ��������书��ѡ���������
	if mynum < enemynum then
		factor = 2
	else
		factor = 1
	end
	
	for i = 1, wugongnum do		--������������Ч��
		local wugongid = JY.Person[pid]["�书" .. i]
		if probability[i] > 0 then
			if probability[i] < maxoffense*3/4 then		--ȥ��������С���书
				probability[i] = 0
			else
				local level = math.modf(JY.Person[pid]["�书�ȼ�" .. i] / 100) + 1
				probability[i] = probability[i] + JY.Wugong[wugongid]["�ƶ���Χ".. level]  * factor*10
				if JY.Wugong[wugongid]["ɱ�˷�Χ" .. level] > 0 then
					probability[i] = probability[i] + JY.Wugong[wugongid]["ɱ�˷�Χ" .. level]* factor*10
				end
			end
		end
	end
	
	local s = {}			--���ո��������ۼ�
	local maxnum = 0
	for i = 1, wugongnum do
		s[i] = maxnum
		maxnum = maxnum + probability[i]
	end
	s[wugongnum + 1] = maxnum
	if maxnum == 0 then		--û�п���ѡ����书
		return -1
	end
	
	local v = Rnd(maxnum)		--���������
	local selectid = 0
	for i = 1, wugongnum do		--���ݲ������������Ѱ�������ĸ��书����
		if s[i] <= v and v < s[i + 1] then
			selectid = i
		end
	end
	return selectid
end

--ս���书ѡ��˵�
--sb starΪ�������������Ϊ��ֹ�����﷨��������
function War_FightMenu(sb, star, wgnum)
	local pid = WAR.Person[WAR.CurID]["������"]
	local numwugong = 0
	local menu = {}
	local canuse = {}
	local c = 0;
	for i = 1, JY.Base["�书����"] do
		local tmp = JY.Person[pid]["�书" .. i]
		if tmp > 0 then
			menu[i] = {JY.Wugong[tmp]["����"], nil, 1}
	
			--�ڹ��޷�����
			--��̹֮����
			if match_ID(pid, 48) == false and JY.Wugong[tmp]["�书����"] == 6 then
				menu[i][3] = 0
			end
			
			--�Ṧ�޷�����
			if JY.Wugong[tmp]["�书����"] == 7  or 
           (tmp == 85 or tmp == 87 or tmp == 88 or tmp == 144 or tmp == 175  or tmp == 182  or tmp == 199)then
				menu[i][3] = 0
			end
			
			--��ת���Ʋ���ʾ
			if tmp == 43 then
				menu[i][3] = 0
			end

			--�������������ڹ��ɹ����������һ���ڹ��ɹ���
			if ((pid == 0 and JY.Base["��׼"] == 6) or (pid == 0 and JY.Base["����"] > 0 and i == 1)) and JY.Wugong[tmp]["�书����"] == 6 then
				menu[i][3] = 1
			end
			--��ƽ֮ ���� ����� ��ʾ������
			if tmp == 105 and (match_ID(pid, 36) or match_ID(pid, 27) or match_ID(pid, 189) ) then
				menu[i][3] = 1
			end
		   
			--ʯ���� ��ʾ̫����
			if tmp == 102 and match_ID_awakened(pid, 38, 1) then
				menu[i][3] = 1
			end
		  
			--���޼� ��ʾ������
			if tmp == 106 and match_ID(pid, 9) then
				menu[i][3] = 1
			end
			--����ɮ ��ʾ������
			if tmp == 106 and match_ID(pid, 638) then
				menu[i][3] = 1
			end			
		  
			--���� ��ʾ����
			if tmp == 94 and match_ID(pid, 37) then
				menu[i][3] = 1
			end
		  
			--Ľ�ݸ� ��ʾ��ת����
			if tmp == 43 and match_ID(pid, 51) then
				menu[i][3] = 1
			end
		  
			--ŷ���� ��ʾ����
			if tmp == 104 and match_ID(pid, 60) then
				menu[i][3] = 1
			end

			--С�� ��ʾʥ��
			if tmp == 93 and match_ID(pid, 66) then
				menu[i][3] = 1
			end
		  
			--�����ٲ���ʾ
			if JY.Person[pid]["����"] < JY.Wugong[tmp]["������������"] then
				menu[i][3] = 0
			end

			--��������10����ʾ
			if JY.Person[pid]["����"] < 10 then
				menu[i][3] = 0
			end
			  
			numwugong = numwugong + 1
		  
			if menu[i][3] == 1 then
				c = c + 1
				canuse[c] = i
			end
		end
	end
	if c == 0 then
		return 0
	end
	if wgnum == nil then
		local r = nil
		r = Cat('�˵�',menu, numwugong, 0,CC.MainMenuX, CC.MainMenuY, 0, 0, 1, 1, CC.DefaultFont, C_ORANGE, C_WHITE)
		if r == 0 then
			return 0
		end
		WAR.ShowHead = 0
		local r2 = War_Fight_Sub(WAR.CurID, r)
		WAR.ShowHead = 1
		Cls()
		return r2
	--�޾Ʋ��������ֿ�ݼ�ֱ��ʹ���书
	else
		if wgnum <= c then
			WAR.ShowHead = 0
			local r2 = War_Fight_Sub(WAR.CurID, canuse[wgnum])
			WAR.ShowHead = 1
			Cls()
			return r2
		else
			return 0
		end
	end
end

--�Զ�ս��ʱ ��˼��
--��ҩ��flag��2 ������3������4������6 �ⶾ
function War_Think()
	local pid = WAR.Person[WAR.CurID]["������"]
	local r = -1
	local minNeili = War_GetMinNeiLi(pid)
	local can_eat_drug = 0
	--���ҷ����ῼ�ǳ�ҩ
	if WAR.Person[WAR.CurID]["�ҷ�"] == false then
		can_eat_drug = 1
	--������ҷ���ֻ���ڶ�������Ż��ҩ
	else
		if inteam(pid) and JY.Person[pid]["�Ƿ��ҩ"] == 1 then
			can_eat_drug = 1
		end
	end
	--����������ս����ҩ
	--���߹��Ӻ��߹�����ҩ
	if WAR.Person[WAR.CurID]["�ҷ�"] == false and (WAR.ZDDH == 188 or WAR.ZDDH == 257) then
		can_eat_drug = 0
	end
	--���Գ�ҩ�Ļ�
	if can_eat_drug == 1 then 
		--������ҩ
		local eat_eng_drug = 0
		if inteam(pid) then
			local fz = {50, 30, 10}
			if JY.Person[pid]["����"] < fz[JY.Person[pid]["������ֵ"]] then
				eat_eng_drug = 1
			end
		else
			if JY.Person[pid]["����"] < 10 then
				eat_eng_drug = 1
			end
		end
		if eat_eng_drug == 1 then
			r = War_ThinkDrug(4)
			if r >= 0 then
			  return r
			end
			return 0
		end
		
		--��Ѫҩ
		local eat_hp_drug = 0
		if inteam(pid) then
			local fz = {0.7, 0.5, 0.3}
			if JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"]*fz[JY.Person[pid]["������ֵ"]] then
				eat_hp_drug = 1
			end
		else
			--��������ȷ����Ѫҩ����
			local rate = -1
			if JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 5 then
				rate = 90
			elseif JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 4 then
				rate = 70
			elseif JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 3 then
				rate = 50
			elseif JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 2 then
				rate = 25
			end
			
			--����Ҳ���ӳ�Ѫҩ����
			if JY.Person[pid]["���˳̶�"] > 50 then
				rate = rate + 50
			end
			
			--����ʱ������ҩ
			if Rnd(100) < rate and WAR.LQZ[pid] ~= nil and WAR.LQZ[pid] ~= 100 then
				eat_hp_drug = 1
			end
		end
		if eat_hp_drug == 1 then
			r = War_ThinkDrug(2)
			if r >= 0 then				--�����ҩ��ҩ
				return r
			else
				r = War_ThinkDoctor()		--���û��ҩ������ҽ��
				if r >= 0 then
					return r
				end
			end
		end
		
		--������ҩ
		local eat_mp_drug = 0
		if inteam(pid) then
			local fz = {0.7, 0.5, 0.3}
			if JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"]*fz[JY.Person[pid]["������ֵ"]] then
				eat_mp_drug = 1
			end
		else
			--��������
			local rate = -1
			if JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 6 then
				rate = 100
			elseif JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 5 then
				rate = 75
			elseif JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 4 then
				rate = 50
			end

			if Rnd(100) < rate or minNeili > JY.Person[pid]["����"] then
				eat_mp_drug = 1
			end
		end
		if eat_mp_drug == 1 then
			r = War_ThinkDrug(3)
			if r >= 0 then
				return r
			end
		end
	  
		local jdrate = -1
		if CC.PersonAttribMax["�ж��̶�"] * 3 / 4 < JY.Person[pid]["�ж��̶�"] then
			jdrate = 60
		else
			if CC.PersonAttribMax["�ж��̶�"] / 2 < JY.Person[pid]["�ж��̶�"] then
				jdrate = 30
			end
		end
	  
		--��Ѫ���³Խⶾҩ
		--��ŭ���Խⶾҩ
		if Rnd(100) < jdrate and JY.Person[pid]["����"] < JY.Person[pid]["�������ֵ"] / 2 and WAR.LQZ[pid] ~= nil and WAR.LQZ[pid] ~= 100 then
			r = War_ThinkDrug(6)
			if r >= 0 then
				return r
			end
		end
	end
	
	if inteam(pid) then 
		if JY.Person[pid]["��Ϊģʽ"] == 4 then
			r = 0
		elseif JY.Person[pid]["��Ϊģʽ"] == 3 then
			r = 7
		elseif JY.Person[pid]["��Ϊģʽ"] == 2 then
			r = 8
		elseif JY.Person[pid]["��Ϊģʽ"] == 1 then
			if minNeili <= JY.Person[pid]["����"] and JY.Person[pid]["����"] > 10 then
				r = 1
			else
				r = 0
			end
		end
	else
		if minNeili <= JY.Person[pid]["����"] and JY.Person[pid]["����"] > 10 then
			r = 1
		else
			r = 0
		end
	end
	return r
end

--�Զ�����
function War_AutoFight()
	local pid = WAR.Person[WAR.CurID]["������"]
	local wugongnum;
	if  JY.Person[pid]["����ʹ��"] ~= 0 then
		for i = 1, JY.Base["�书����"] do
			if JY.Person[pid]["�书"..i] == JY.Person[pid]["����ʹ��"] then
				wugongnum = i
				break
			end
		end
		--��һ����ֹ��ϴ��������
		if wugongnum == nil then
			wugongnum = War_AutoSelectWugong()
		end
	else
		wugongnum = War_AutoSelectWugong()
	end
	if wugongnum <= 0 then
		War_AutoEscape()
		War_RestMenu()
		return 
	end
    --say('1',1)
	unnamed(wugongnum)
    --say('2',1)
end

--�Զ�ս��
function War_Auto()
	local pid = WAR.Person[WAR.CurID]["������"]
	WAR.ShowHead = 1
	Cat('ʵʱ��Ч����')
	WarDrawMap(0)
	ShowScreen()
	lib.Delay(CC.BattleDelay)
	WAR.ShowHead = 0
	if CC.AutoWarShowHead == 1 then
		WAR.ShowHead = 1
	end
    if WAR.HLZT[pid] ~= nil then 
        Cat('����ƶ�')
    end
	local autotype = War_Think()
	--һ��ֹɱ
    if autotype == 1 and WAR.YYZS[pid]~= nil then
		WarDrawMap(0); --���������򶯻�λ���޷�������ʾ
		CurIDTXDH(WAR.CurID, 122,1,"ֹɱ״̬��",C_ORANGE)
	    autotype =0
		WAR.YYZS[pid]= nil
	end

	if autotype == 0 then
		War_AutoEscape()
		War_RestMenu()
	elseif autotype == 1 then
		War_AutoFight()
        --say('1',1)
	elseif autotype == 2 then
		War_AutoEscape()
		War_AutoEatDrug(2)
	elseif autotype == 3 then
		War_AutoEscape()
		War_AutoEatDrug(3)
	elseif autotype == 4 then
		War_AutoEscape()
		War_AutoEatDrug(4)
	elseif autotype == 5 then
		War_AutoEscape()
		War_AutoDoctor()
	elseif autotype == 6 then
		War_AutoEscape()
		War_AutoEatDrug(6)
	elseif autotype == 7 then
		War_RestMenu()
	elseif autotype == 8 then
		War_DefupMenu()
	end
	return 0
end

--��������
function War_AddPersonLVUP(pid)
	local tmplevel = JY.Person[pid]["�ȼ�"]
	if CC.Level <= tmplevel then
		return false
	end
	if JY.Person[pid]["����"] < CC.Exp[tmplevel] then
		return false
	end
	while CC.Exp[tmplevel] <= JY.Person[pid]["����"] do
		tmplevel = tmplevel + 1
		if CC.Level <= tmplevel then
			break;
		end
	end
    
    tmplevel = 30
    
	DrawStrBoxWaitKey(string.format("%s ������", JY.Person[pid]["����"]), C_WHITE, CC.DefaultFont)
	--���������ĵȼ�
	local leveladd = tmplevel - JY.Person[pid]["�ȼ�"]
	
	JY.Person[pid]["�ȼ�"] = 30--JY.Person[pid]["�ȼ�"] + leveladd
	
	--�����������
	AddPersonAttrib(pid, "�������ֵ", (JY.Person[pid]["��������"] ) * leveladd * 4)
	
	JY.Person[pid]["����"] = JY.Person[pid]["�������ֵ"]
	JY.Person[pid]["����"] = CC.PersonAttribMax["����"]
	JY.Person[pid]["���˳̶�"] = 0
	JY.Person[pid]["�ж��̶�"] = 0
    
	local theadd = JY.Person[pid]["����"] / 4
	--�������������١�����
	--���������ĳɳ�
	AddPersonAttrib(pid, "�������ֵ", math.modf(leveladd * ((16 - JY.Person[pid]["��������"]) * 7 + 210 / (theadd + 1))))
	
	--�������ÿ�������50
	if pid == 0 and JY.Base["��׼"] == 6 then
        AddPersonAttrib(pid, "�������ֵ", 50 * leveladd)
	end
	JY.Person[pid]["����"] = JY.Person[pid]["�������ֵ"]
	local p_zz = JY.Person[pid]["����"];
	--ѭ�������ȼ����ۼ�����
	for i = 1, leveladd do
		local ups;
		
		--if p_zz <31 then --87*3 261   1/9
		ups = 3
		--elseif p_zz >= 31 and p_zz <= 50 then --116*3 348  1/12
		--	ups = 4
		--elseif p_zz >= 51 and p_zz <= 79 then --147*3 441  1/15
		--	ups = 5
		--elseif p_zz >= 80 and p_zz <= 100 then --177*3 522  1/18
			--ups = 6
		--end
		--
		--����� ���˻ظ�ǰ��ÿ��3��
		--[[
		if pid == 35 and GetD(82, 1, 0) == 1 then
			ups = 3
		end]]
		  
		--���ѹ��� 20��֮��ÿ��6��
		if pid == 55 and JY.Person[pid]["�ȼ�"] > 20 then
			ups = 6
		end
	  
		AddPersonAttrib(pid, "������", ups)
		AddPersonAttrib(pid, "������", ups)
		AddPersonAttrib(pid, "�Ṧ", ups)
		
		--�޸�ҽ�ơ��ö����ⶾ��������ȼ��ҹ�������
		if JY.Person[pid]["ҽ������"] >= 20 then
			AddPersonAttrib(pid, "ҽ������", 2)
		end
		if JY.Person[pid]["�ö�����"] >= 20 then
			AddPersonAttrib(pid, "�ö�����", 2)
		end
		if JY.Person[pid]["�ⶾ����"] >= 20 then
			AddPersonAttrib(pid, "�ⶾ����", 2)
		end
		
		--���ѳ¼��� ��������Χ
		if pid == 75 then
			if JY.Person[pid]["ȭ�ƹ���"] >= 0 then
				AddPersonAttrib(pid, "ȭ�ƹ���", (5 + math.random(0,1)))
			end
			if JY.Person[pid]["ָ������"] >= 0 then
				AddPersonAttrib(pid, "ָ������", (7 + math.random(0,1)))
			end
			if JY.Person[pid]["��������"] >= 0 then
				AddPersonAttrib(pid, "��������", (7 + math.random(0,1)))
			end
			if JY.Person[pid]["ˣ������"] >= 0 then
				AddPersonAttrib(pid, "ˣ������", (7 + math.random(0,1)))
			end
			if JY.Person[pid]["�������"] >= 0 then
				AddPersonAttrib(pid, "�������", (7 + math.random(0,1)))
			end
		end

		
		--����ÿ�����
		if JY.Person[pid]["��������"] >= 20 then
			AddPersonAttrib(pid, "��������", 2)
		end
	end

	local ey = 1;  --ÿ�������ɵ���
	ey = ey + JY.Base["�Ѷ�"];
	
	--local zm = limitX(JY.Base["��Ŀ"],1,20)
	
	local n = ey*leveladd;		--��������������
 
	n = n + math.ceil(p_zz*2.5*leveladd/29)
	
	--�ӵ�
	local gj = JY.Person[pid]["������"];
	local fy = JY.Person[pid]["������"];
	local qg = JY.Person[pid]["�Ṧ"];
	local tmpN = n;
	
	--�츳ID
	local tfid;
	--����
	if pid == 0 then
		--����
		if JY.Base["��׼"] > 0 then
			tfid = 280 + JY.Base["��׼"]
		--����
		elseif JY.Base["����"] > 0 then
			tfid = 289 + JY.Base["����"]
		--����
		else
			tfid = JY.Base["����"]
		end
	--����
	else
		tfid = pid
	end
	
	--�����ӵ����
	local current = 1
	while true do
		if JY.Restart == 1 then
			break
		end
		Cls();
		ShowPersonStatus_sub(pid, 1, 1, tfid, -17, 1)
		DrawString(CC.ScreenW/4-CC.Fontsmall*6-2+28-10,CC.ScreenH/2+100+20-15,string.format("�ɷ��������%d ��",tmpN) ,C_ORANGE, CC.Fontsmall*0.7);
		for i = 1, 3 do
			local shade_color = C_GOLD
			if i ==  current then
				shade_color = PinkRed
			end
			DrawString(CC.ScreenW/4-CC.Fontsmall*7-30, CC.ScreenH/2+100+24+i*(CC.FontSmall4+CC.PersonStateRowPixel)-40, "��",shade_color, CC.Fontsmall*0.7);
		end
		ShowScreen()
		local keypress, ktype, mx, my = WaitKey()
		--lib.Delay(CC.Frame)
		if ktype == 1 then
			if keypress == VK_UP then
				current = current - 1
				if current < 1 then
					current = 3
				end
			elseif keypress == VK_DOWN then
				current = current + 1
				if current > 3 then
					current = 1
				end
			elseif keypress == VK_LEFT and tmpN < n then
				if current == 1 and JY.Person[pid]["������"] > gj then
					JY.Person[pid]["������"] = JY.Person[pid]["������"]-1
					tmpN = tmpN+1
				elseif current == 2 and JY.Person[pid]["������"] > fy then
					JY.Person[pid]["������"] = JY.Person[pid]["������"]-1
					tmpN = tmpN+1
				elseif current == 3 and JY.Person[pid]["�Ṧ"] > qg then
					JY.Person[pid]["�Ṧ"] = JY.Person[pid]["�Ṧ"]-1
					tmpN = tmpN+1
				end
			elseif keypress == VK_RIGHT and tmpN > 0 then
				if current == 1 and JY.Person[pid]["������"] < 620 then
					JY.Person[pid]["������"] = JY.Person[pid]["������"]+1
					tmpN = tmpN-1
				elseif current == 2 and JY.Person[pid]["������"] < 620 then
					JY.Person[pid]["������"] = JY.Person[pid]["������"]+1
					tmpN = tmpN-1
				elseif current == 3 and JY.Person[pid]["�Ṧ"] < 620 then
					JY.Person[pid]["�Ṧ"] = JY.Person[pid]["�Ṧ"]+1
					tmpN = tmpN-1
				end
			elseif keypress==VK_SPACE or keypress==VK_RETURN then
				if tmpN == 0 or (JY.Person[pid]["������"] == 620 and JY.Person[pid]["������"] == 620 and JY.Person[pid]["�Ṧ"] == 620) then
					Cls();
					break
				else
					DrawStrBoxWaitKey("�Բ���"..JY.Person[pid]["����"].."����ʣ��ĵ���û��!", C_WHITE, CC.DefaultFont)
				end
			end
		end
	end
	return true
end

--ս������������
--isexp ����ֵ
--warStatus ս��״̬
function War_EndPersonData(isexp, warStatus)
	--�޾Ʋ�����Ѫ����ԭ����
	Health_in_Battle_Reset()
	--�޾Ʋ�����ս��״̬�ָ�
	for i = 0, WAR.PersonNum - 1 do
		local pid = WAR.Person[i]["������"]
		--�з��ظ���״̬
		if isteam(pid) == false then
			JY.Person[pid]["����"] = JY.Person[pid]["�������ֵ"]
			JY.Person[pid]["����"] = JY.Person[pid]["�������ֵ"]
			JY.Person[pid]["����"] = CC.PersonAttribMax["����"]
			JY.Person[pid]["���˳̶�"] = 0
			JY.Person[pid]["�ж��̶�"] = 0
			JY.Person[pid]["����̶�"] = 0
			JY.Person[pid]["���ճ̶�"] = 0
		--�ҷ��ָ�״̬
		else	
			JY.Person[pid]["����"] = JY.Person[pid]["�������ֵ"]
			JY.Person[pid]["����"] = JY.Person[pid]["�������ֵ"]
			JY.Person[pid]["����"] = CC.PersonAttribMax["����"]
			JY.Person[pid]["���˳̶�"] = 0
			JY.Person[pid]["�ж��̶�"] = 0
			JY.Person[pid]["����̶�"] = 0
			JY.Person[pid]["���ճ̶�"] = 0
			--��սͳ��
			JY.Person[pid]["��ս"] = JY.Person[pid]["��ս"] + 1
		end
	end

	--�Ƿ��书�ظ�
	JY.Person[50]["�书1"] = 26
	JY.Wugong[13]["����"] = "����"
	
	--�Ħ���书�ָ�
	if JY.Base["����"] == 103 then
		JY.Person[0]["�书2"] = 98
	end
  
	--��ؤ�����
	if WAR.ZDDH == 82 then
		SetS(10, 0, 18, 0, 1)
	end
  
	--÷ׯ ͺ����ս����
	if WAR.ZDDH == 44 then
		instruct_3(55, 6, 1, 0, 0, 0, 0, -2, -2, -2, 0, -2, -2)
		instruct_3(55, 7, 1, 0, 0, 0, 0, -2, -2, -2, 0, -2, -2)
	end
  
	--÷ׯ �ڰ���ս��
	if WAR.ZDDH == 45 then
		instruct_3(55, 9, 1, 0, 0, 0, 0, -2, -2, -2, 0, -2, -2)
	end
  
	--÷ׯ ���ӹ�ս��
	if WAR.ZDDH == 46 then
		instruct_3(55, 13, 0, 0, 0, 0, 0, -2, -2, -2, 0, -2, -2)
	end
  
  	--��������ս��ʤ��
	--�ö�����Ʒ�¼�¼
	if WAR.ZDDH == 54 and CC.TX["Ц��а��"] == 1 and WAR.MCRS == 1 then
		CC.TX["Ц��а��"] = 2
        CC.TG[9967] = 1
	end		
	
    if WAR.ZDDH == 100 and warStatus == 1 then
	    JY.Person[344]["Ʒ��"] = 10
    end
	--ս��ʧ�ܣ������޾���
	if warStatus == 2 and isexp == 0 then
		return 
	end
  
	--ͳ�ƻ������
	local liveNum = 0
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["�ҷ�"] == true and JY.Person[WAR.Person[i]["������"]]["����"] > 0 then
			liveNum = liveNum + 1
		end
	end
  
	--���侭��
	local canyu = false
	if warStatus == 1 then
		if WAR.Data["����"] < 1000 then
			WAR.Data["����"] = 1000
		end
		--����ľ׮��ľ׮�ľ���
		if WAR.ZDDH == 226 then
			WAR.Data["����"] = 45000
		end
		for i = 0, WAR.PersonNum - 1 do
			local pid = WAR.Person[i]["������"]
			if WAR.Person[i]["�ҷ�"] == true and inteam(pid) and JY.Person[pid]["����"] > 0 then
				if pid == 0 then
					canyu = true
				end
				--����ľ׮�ľ���
				if WAR.ZDDH == 226  then
					WAR.Person[i]["����"] = 120000
				else
					WAR.Person[i]["����"] = WAR.Person[i]["����"] + math.modf(WAR.Data["����"] / (liveNum))
				end
				--С�޾��鷭��
				if PersonKF(pid, 98) then
					WAR.Person[i]["����"] = WAR.Person[i]["����"] + math.modf(WAR.Data["����"] / (liveNum))
				end
			end
		end
	end
  
	--�ѵȼ����������ؼ��ĺ���
	for i = 0, WAR.PersonNum - 1 do
		local pid = WAR.Person[i]["������"]
		if WAR.Person[i]["�ҷ�"] == true and inteam(pid) then
			--�޾Ʋ�����С��30����������������Ʒ����ʾ�Ի�����ʾ
			if JY.Person[pid]["�ȼ�"] < 30 or JY.Person[pid]["������Ʒ"] >= 0 then
				DrawStrBoxWaitKey(string.format("%s ��þ������ %d", JY.Person[pid]["����"], WAR.Person[i]["����"]), C_WHITE, CC.DefaultFont)
			end
			--������Ʒ
			AddPersonAttrib(pid, "��Ʒ��������", math.modf(WAR.Person[i]["����"] * 8 / 10))
			AddPersonAttrib(pid, "��������", math.modf(WAR.Person[i]["����"] * 8 / 10))
			if JY.Person[pid]["��������"] < 0 then
				JY.Person[pid]["��������"] = 0
			end
			War_PersonTrainBook(pid)     --�����ؼ�
			War_PersonTrainDrug(pid)		 --����ҩƷ
			--�ѵȼ����������ؼ��ĺ���
			AddPersonAttrib(pid, "����", math.modf(WAR.Person[i]["����"] / 2))
			War_AddPersonLVUP(pid)
		else
			AddPersonAttrib(pid, "����", WAR.Person[i]["����"])
		end
	end
  
	--�������
	if WAR.ZDDH == 48 then
		SetS(57, 52, 29, 1, 0)
		SetS(57, 52, 30, 1, 0)
	--һ�ƾӣ�ŷ���棬��ǧ��
	elseif WAR.ZDDH == 175 then
		instruct_3(32, 12, 1, 0, 0, 0, 0, 0, 0, 0, -2, -2, -2)
	--�ƴ���
	elseif WAR.ZDDH == 82 then
		SetS(10, 0, 18, 0, 1)
	--ľ����
	elseif WAR.ZDDH == 214 then
		SetS(10, 0, 19, 0, 1)
	--����а
	elseif WAR.ZDDH == 170 then
		JY.Scene[JY.SubScene]["��������"] = -1
	end

	if JY.Restart == 1 then
		return
	end
end

--ִ��ս�����Զ����ֶ�ս��������
--idս��������
--wugongnum ʹ�õ��书��λ��
--x,yΪս����������
function War_Fight_Sub(id, wugongnum, x, y)
	WAR.Person[id]['��Ч����'] = -1
	WAR.Person[id]['��Ч����1'] = nil
	WAR.Person[id]['��Ч����2'] = nil
	WAR.Person[id]['��Ч����3'] = nil
	WAR.Person[id]['��Ч����4'] = nil
	
	local pid = WAR.Person[id]["������"]
	local x0, y0 = WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"]
	local wugong = 0
	if wugongnum < 100 then
		wugong = JY.Person[pid]["�书" .. wugongnum]
	else
		wugong = wugongnum - 100
		wugongnum = 1
		for i = 1, JY.Base["�书����"] do
			if JY.Person[pid]["�书" .. i] == 43  then	--���ѧϰ�ж�ת����
				wugongnum = i							--��¼��ת�书λ��
				break;
			end
		end
        if x ~= nil and y ~= nil then
            x = WAR.Person[WAR.CurID]["����X"] - x
            y = WAR.Person[WAR.CurID]["����Y"] - y
        end
		WarDrawMap(0)   
		local fj = "����"		--��ת����
		--��ת������ʾ������
		if WAR.DZXYLV[pid] == 100 then
			fj = string.format("%s���Ź�Ԫ�ơ�����", JY.Person[pid]["����"])
		elseif WAR.DZXYLV[pid] == 115 then
			fj = string.format("%s���������ǳ�����", JY.Person[pid]["����"])
		elseif WAR.DZXYLV[pid] == 110 then
			fj = string.format("%s������ϲ��̷���", JY.Person[pid]["����"])
		elseif WAR.DZXYLV[pid] == 85 then
			fj = string.format("%s������ת���Ʒ���", JY.Person[pid]["����"])
		elseif WAR.DZXYLV[pid] == 60 then
			fj = string.format("%s���������Ƴ�����", JY.Person[pid]["����"])
		end
		TXWZXS(fj, C_ORANGE)

	end

	WAR.WGWL = JY.Wugong[wugong]["������10"]
	local fightscope = JY.Wugong[wugong]["������Χ"]		--ûɶ�õ�����
	local kfkind = JY.Wugong[wugong]["�书����"]
	local level = JY.Person[pid]["�书�ȼ�" .. wugongnum]   --�ж��书�Ƿ�Ϊ��

	if level == 999 then
		level = 11
	else
		level = math.modf(level / 100) + 1
	end
	WAR.ShowHead = 0
	
	--��ֹ�Ժ�ָ�����ǵ�����±���ת������Ч
	--������0
	WAR.JYZS = 0 
	--�̺���0
	WAR.LXBHZS = 0
    WAR.BHJTZ = 0
	
	local m1, m2, a1, a2, a3, a4, a5,a6 = refw(wugong, level)  --��ȡ�书�ķ�Χ
		
	local movefanwei = {m1, m2}				--���ƶ��ķ�Χ
	local atkfanwei = {a1, a2, a3, a4, a5}	--������Χ
    if a6 == 0	 then
		WAR.JYZS = 0;		
		WAR.LXBHZS = 0;
		return 0
	end 
	x, y = War_FightSelectType(movefanwei, atkfanwei, x, y,wugong)
    --ȡ��ʱ˳���ָ������ͷ� ���� �̺� ��ʽ
	--��ֹ����ѡ���书��ȡ�������
	if x == nil  then
		WAR.JYZS = 0;		
		WAR.LXBHZS = 0;
		return 0
	end 
	
	if WAR.Person[WAR.CurID]["��ͼ"] ~= WarCalPersonPic(WAR.CurID) then
		WAR.Person[WAR.CurID]["��ͼ"] = WarCalPersonPic(WAR.CurID)
		SetWarMap(x0,y0, 5, WAR.Person[WAR.CurID]["��ͼ"])
		WarDrawMap(0)
		Cat('ʵʱ��Ч����')
		ShowScreen()
		lib.Delay(CC.BattleDelay)
	end
	
	--ʹ���˾���������ʽ������ȴ��
	if  wugong == 106 and level == 11 and  WAR.JYCD[WAR.JYZS] ~= nil and WAR.JYCD[WAR.JYZS] > 0 and inteam(pid)  and WAR.DZXY == 0 and WAR.AutoFight == 0 and WAR.ZYHB==0 then
		WAR.JYLQ[pid][WAR.JYZS] = WAR.JYCD[WAR.JYZS] + 1
	end
	--ʹ���˱�а������ʽ������ȴ
	--��ƽ֮����ȴ
	if wugong == 48 and level == 11 and inteam(pid) and WAR.AutoFight == 0 and WAR.DZXY == 0  then
		if not match_ID(pid, 36)  then
			WAR.BXLQ[pid][WAR.BXZS] = WAR.BXCD[WAR.BXZS] + 1
		end
	end
    
	--�жϺϻ�
	local ZHEN_ID = -1
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[WAR.CurID]["�ҷ�"] == WAR.Person[i]["�ҷ�"] and i ~= WAR.CurID and WAR.Person[i]["����"] == false then
			local nx = WAR.Person[i]["����X"]
			local ny = WAR.Person[i]["����Y"]
			local fid = WAR.Person[i]["������"]
			for j = 1, JY.Base["�书����"] do
				if JY.Person[fid]["�书" .. j] == wugong then         
					if math.abs(nx-x0)+math.abs(ny-y0)<9 then
						local flagx, flagy = 0, 0
						if math.abs(nx - x0) <= 1 then
							flagx = 1
						end
						if math.abs(ny - y0) <= 1 then
							flagy = 1
						end
						if x0 == nx then
							flagy = 1
						end
						if y0 == ny then
							flagx = 1
						end
						if between(x, x0, nx, flagx) and between(y, y0, ny, flagy) then
							ZHEN_ID = i
							WAR.Person[i]["�˷���"] = 3 - War_Direct(x0, y0, x, y)
							break;
						end
					end
				end
			end
			if ZHEN_ID >= 0 then
				break;
			end
		end
	end

	--��������
	WAR.ATNum = 1

	--�ж�����
	if JY.Person[pid]["���һ���"] == 1 and WAR.ZYHB == 0 and fjpd(WAR.CurID) == false then
		--�ж����ң�71-����
        local zyjl = (71-JY.Person[pid]['����'])

		if zyjl < 0 then
			zyjl = 0
		end
		--�ܲ�ͨ100%
		if match_ID(pid, 64) then
			zyjl = 100
		end
		--����80%
		if match_ID(pid, 55) then
			zyjl = 80
		end
		--С��Ů70%
		if match_ID(pid, 59) then
			zyjl = 70
		end
		--���������Ѻ�70%
		if match_ID_awakened(pid, 631, 1) then
			zyjl = 70
		end
		--��Ϧ����100%
		--��Ϧ��Ů100%
		if match_ID(pid, 612) or match_ID(pid, 615) then
			zyjl = 100
		end
        
		--��ŭ������
		if WAR.LQZ[pid] == 100 then
			zyjl = zyjl + 20
		end		
		--�ܲ�֧ͨ����ɺ�����+20%
		if pid == 0 and JY.Person[64]["Ʒ��"] == 80 then
			zyjl = zyjl + 20
		end

		--����100%
		if zyjl > 100 then
			zyjl = 100
		end
		--��ת���Ʋ���������
		if JLSD(0, zyjl, pid) and WAR.DZXY == 0 then
			WAR.ZYHB = 1
			--�ĵ���Ч����4��ʾ
			if WAR.Person[WAR.CurID]["��Ч����4"] ~= nil then
				WAR.Person[WAR.CurID]["��Ч����4"] = WAR.Person[WAR.CurID]["��Ч����4"] .."�����һ���";
			else
				WAR.Person[WAR.CurID]["��Ч����4"] = "���һ���";
			end
		end
	end
	
	--�ܲ�ͨ����һ�����Һ��м��ʸ�������׷�ӵڶ������ң�����ר��
	if match_ID(pid, 64) and WAR.ZYHB == 2 and WAR.ZHB == 0 then
		local zyjl = 80 - JY.Person[pid]["����"]
		if zyjl < 0 then
			zyjl = 0
		end
		--��ת���Ʋ���������
		--����ֹ������������
		if JLSD(0, zyjl, pid) and (WAR.DZXY == 0 or WAR.LJXD == 0) and fjpd(WAR.CurID) == false then
			WAR.ZYHB = 1
			WAR.ZHB = 1
		
			--�ĵ���Ч����4��ʾ
			if WAR.Person[WAR.CurID]["��Ч����4"] ~= nil then
				WAR.Person[WAR.CurID]["��Ч����4"] = WAR.Person[WAR.CurID]["��Ч����4"] .."�����һ���";
			else
				WAR.Person[WAR.CurID]["��Ч����4"] = "���һ���";
			end
		end
	end
	
	--�޾Ʋ������������ú�������
	local LJ;
	
	LJ = Person_LJ(pid)
	--��������+20%
	--if WAR.Person[id]["�ҷ�"] == false then
	--	LJ = LJ + 10
	--end
		
	--����������100
	if LJ > 100 then
		LJ = 100 
	end
	
	if JLSD(0,LJ,pid) then
		WAR.ATNum = 2
	end

	--�������书
	local glj = {7, 2, 34, 37, 55, 57, 70, 77,156}
	for i = 1, 8 do
		if JY.Person[pid]["�书" .. wugongnum] == glj[i] and JLSD(20, 75, pid) then
			WAR.ATNum = 2
			break;
		end
	end
	
	--����������϶�������
	if wugong >= 30 and wugong <= 34 and WuyueJF(pid) and JLSD(30, 60, pid) then
		WAR.ATNum = 2
	end
	
	--����������϶�������
	if (wugong == 3 or wugong == 120 or wugong == 5 or wugong == 21 or wugong == 118) and ZiqiTL(pid) and JLSD(30, 60, pid) then
		WAR.ATNum = 2
	end
	
	--�����޷���ϣ�����������+30%
	if kfkind == 4 and TianYiWF(pid) and JLSD(30, 60, pid) then
		WAR.ATNum = 2
	end
	
	--���л۷��ޱ���
	if match_ID(pid, 77) and wugong == 62 then
		WAR.ATNum = 2
	end
	
	--װ��ԧ�쵶�����ޱ���
	if (JY.Person[pid]["����"] == 217 or JY.Person[pid]["����"] == 218) and wugong == 62 then
		WAR.ATNum = 2
	end
	
	--���ƣ�ˮ�����Ǹ���
	if (match_ID(pid, 37) or match_ID(pid, 589)) and wugong == 114 and JLSD(20, 75, pid) then
		WAR.ATNum = 2
	end
	
	
	--����һ��ָ����
	if match_ID(pid, 102) and wugong == 17 and JLSD(20, 75, pid) then
		WAR.ATNum = 2
	end
	
	--С��Ů��Ů���Ľ�����
	if match_ID(pid, 59) and wugong == 139 and JLSD(20, 75, pid) then
		WAR.ATNum = 2
	end
	
	--������̫������������600������
	--�����κ��书 
	if Curr_NG(pid,171) and WAR.PD["̫������"][pid] ~= nil then
	    if match_ID(pid,5) and WAR.PD["̫������"][pid] > 500 then
	       WAR.ATNum = 2
	    elseif WAR.PD["̫������"][pid] > 600 then
		   WAR.ATNum = 2
	    end
    end
    
    -- �����۶��Ʊ�����
    if wugong == 115 then
	   WAR.ATNum = 2
    end
	    
	--�����ܵ��������ض�����
	--����Ҳ��������
	if WAR.ZDDH == 237 and pid == 18 then
		WAR.ATNum = 1
		WAR.TWLJ = 2
	end
    --������
	if wugong == 187 then
		WAR.ATNum = 1
		WAR.TWLJ = 2
	end
	--�����󷨱ض�����
	if wugong == 87 then
		WAR.ATNum = 1
	end
  
	--�޾Ʋ�������Ȼ�����������
	--������ܴ���
	if wugong == 25 and level == 11 and (match_ID(pid, 58) or pid == 0 ) then
		local jl = 20;
		--���˴���30ʱ��ÿ����������1%����
		if JY.Person[pid]["���˳̶�"] > 30 then
			jl = jl + (JY.Person[pid]["���˳̶�"]-30)
		end    
		--��������70%ʱ��ÿ��һ����������������10%
		if JY.Person[pid]["����"] < (JY.Person[pid]["�������ֵ"]*0.7) then
			jl = jl + math.ceil(((JY.Person[pid]["�������ֵ"]*0.7) - JY.Person[pid]["����"])/10);	  		
		end

		--���ʴ���0�Ŵ���
		if jl > 0 then
			--��ŭ�ش���
			if WAR.LQZ[pid] == 100 or JLSD(0,jl,pid) or match_ID(pid, 58) then	
                 WAR.ARJY = 1			
				--�����ˣ������
				if match_ID(pid, 58) and JY.Person[pid]["����"] > 50  then                  
					WAR.ATNum = 3;
					TXWZXS("��Ȼ����.��������.��Ȼ������", M_DeepSkyBlue)
				else
					WAR.ATNum = 2;
				end			
			end
		end
	end
	
	--�������� 
	if  wugong == 11 and level == 11  and (Curr_NG(pid,107) or match_ID(pid,640))  then
	    WAR.JYSZ = 1
		TXWZXS("������צ.�޼᲻��", M_DeepSkyBlue)
			--WAR.ATNum = 2
	end
    
	--��������Ů
	if match_ID(pid, 640) and WAR.JYSZ == 1 then
		if JY.Base["��������"]>= 7 and(JLSD(20,60,pid) or WAR.LQZ[pid] == 100) then
		    WAR.ATNum = 3
		else
			WAR.ATNum = 2
		end
	end  
	--���� ����
	if match_ID(pid, 637)  and WAR.JYSZ == 1then
		if (JY.Base["��������"] >= 7 or not inteam(pid)) and (JLSD(20,60,pid) or WAR.LQZ[pid] == 100)  then
            WAR.ATNum = 3
		else
            WAR.ATNum = 2	
        end	
    end		   

	--�������� 
	--if kfkind == 5 and pid == 0 and level == 11 and WAR.DZXY ~= 1 and (JLSD(20, 20+JY.Person[pid]["�������"]*0.1, pid) or WAR.LQZ[pid] == 100) then
	--    WAR.YLTW = 1
	--	local zs = {"����.�Ź�ε���","���š�����̽ץ��","���š����������","���š�ժ�ǻ�����"}
	--	WAR.Person[id]["��Ч����3"] = zs[math.random(4)]
	--	WAR.Person[id]["��Ч����"] = 119
	--end	
		
   
	--�Ƿ�
	if match_ID(pid, 50)  then

		--����Ƿ��õ��ǽ�������ô��40%�Ļ�����������ŭ������ʱ������
		--������������˼��ʣ�ÿ��+5%
		local ex_chance = 0
		if JY.Person[pid]["����"] == 300 then
			ex_chance = JY.Thing[300]["װ���ȼ�"] * 5
		end
		if wugong == 26 and (JLSD(25, 65+ex_chance, pid) or WAR.LQZ[pid] == 100) then
			WAR.FS = 1
			WAR.ATNum = 3
			local color = M_Red
			local display = "��������.��Ӣ��ŭ.����������"
			--װ�����䣬��ŭ��50%���ʳ��ĵ���
			if JY.Person[pid]["����"] == 300 and WAR.LQZ[pid] == 100 and JLSD(25, 75, pid) then
				WAR.ATNum = 4
				display = "��Х����.��������.�����ĵ���"
				color = C_GOLD
			end
			TXWZXS(display, color)
			--[[
			for i = 1, 30 do
				DrawStrBox(-1, 24, display, color, 10 + i)
				ShowScreen()
				lib.Delay(10)
			end
			]]
		end
		--NPC�Ƿ����
		if inteam(pid) == false then
			if JY.Person[pid]["����"] < 1000 then
				JY.Person[pid]["����"] = 1200 + math.random(100)
			end
		end
	end


	
	--�һ���������40%��������������ŭ�ش���
	if (wugong == 12 or wugong == 18 or wugong == 38) and TaohuaJJ(pid) and (WAR.LQZ[pid] == 100 or JLSD(35, 75, pid)) then
		WAR.ATNum = 3
		TXWZXS("�һ�������������ת", PinkRed)
	end
	
		--̫�齣�⽣��50%������������
    if PersonKF(pid,152)  and kfkind == 3 then
       local jl = 30
	   if Curr_NG(pid,152) then
		jl = 50
		end
		if math.random(100) <= jl  then
			WAR.ATNum = 3	
			TXWZXS("��������", PinkRed)
		end
	end
    
  	--��������
	if match_ID(pid, 27) and (WAR.LQZ[pid]== 100 or JLSD(10,40,pid))then
		WAR.ATNum = WAR.ATNum + 1
    end 
    
	--��������
	if JY.Person[pid]["����"] == 37 and JY.Thing[37]["װ���ȼ�"] == 6 and kfkind == 3 then
	    local jl = 0;
        if JY.Person[pid]["��������"] > 200 then
			jl = jl + (JY.Person[pid]["��������"]*0.1);	
		end
        if jl > 0 then
			--��ŭ�ش���
			if WAR.LQZ[pid] == 100 or jl > Rnd(100) then	
		       WAR.ATNum = WAR.ATNum + 1
		      Set_Eff_Text(id,"��Ч����0","˭������");
	        end	
	    end
	end
    
	--½����ʮ������ �����࣬33%׷������һ�� 
	if match_ID(pid, 497)  and WAR.SSESS[pid] ~= nil and WAR.SSESS4 < 1 and (WAR.LQZ[pid] == 100 or JLSD(33, 53, pid)) and JY.Base["��������"] > 0 then
		WAR.ATNum = WAR.ATNum + 1
        WAR.SSESS4 = WAR.SSESS4 +1         		
		Set_Eff_Text(id,"��Ч����2","������");
	end	  	
		
	--��̫�壬40%���ʶ������𣬱�ŭ�ش���
	if match_ID(pid, 7) and(WAR.LQZ[pid] == 100 or JLSD(35, 75, pid)) and WAR.DZXY ~= 1 then
		WAR.ATNum = 3
		TXWZXS("�����ش���̫�彣����Ѹ�״���ʽ", M_Red)
	end
    
 	--���Ƴ�������׷������
	if match_ID(pid, 37) and WAR.CXLC == 1 and WAR.CXLC_Count < 3 then
		WAR.ATNum = WAR.ATNum + 1
		WAR.CXLC_Count = WAR.CXLC_Count + 1
	end 

	--�����壺װ�����佣ʱʹ��̫������������
	if JY.Person[pid]["����"] == 236 and wugong == 46 then
		WAR.ATNum = 2;
	end
	--���� ����ǹ������
    if match_ID(pid,568) and wugong == 200 then
		WAR.ATNum = 2
	end

	--��Ħ�Ǳض�����
	if match_ID(pid, 159) then
		WAR.ATNum = 1
	end
    
	--˫���ϱ� ����
	if (wugong == 39 or wugong == 42 or wugong == 139) and ShuangJianHB(pid) then
	    WAR.ATNum = 2
	end
    
	 --��Ůʮ�Ž� ��ŭ����
	if WAR.YLSJJ == 1 and WAR.LQZ[pid] == 100 then
	   WAR.ATNum = 2
	end
    
	--����̫��������ʱΪ������
	if wugong == 34 and PersonKF(pid,175) and WAR.ATNum == 2 then
		WAR.ATNum = 3
	end
  
	WAR.ACT = 1
	WAR.SSESS4 = 0	--��ʮ������

	--��ת
	if WAR.DZXY == 1 then
		--Ľ�ݲ����Σ�������һ��
		if match_ID(pid, 113) then
			WAR.ATNum = 2
		else
			WAR.ATNum = 1
		end
	end

	local kf = wugong
  while WAR.ACT <= WAR.ATNum do
	wugong = kf
	if JY.Restart == 1 then
		break
	end
	lib.GetKey()
    
    if WAR.WS == 1 then		--����
       WAR.WS = 0
    end
    
    if WAR.BJ == 1 then		--����
       WAR.BJ = 0
    end
    
	if WAR.PD["�������"][pid] ~= nil then
       WAR.PD["�������"][pid] = nil
	end
--����--
    WAR.PD['Ұ��ȭ'][pid] = nil
    WAR.PD['���ϵ�'][pid] = nil
    WAR.PD["��հ���"][pid] = nil
    WAR.PD['ѩ������'][pid] = nil
    WAR.PD['�����������л�'][pid] = nil
    WAR.PD['�������𾪰���'][pid] = nil
    WAR.PD['��������������'][pid] = nil
    WAR.PD['����'][pid] = nil
    WAR.PD['�����'][pid] = nil
    WAR.PD['���־�'][pid] = nil
    WAR.PD['���־�'][pid] = nil
    WAR.PD['���־�'][pid] = nil
    WAR.PD['���־�'][pid] = nil 
    WAR.PD['���־�'][pid] = nil
    WAR.PD['��Ϧ��϶'][pid] = nil
    WAR.PD['����ͨ��'][pid] = nil
    WAR.PD['�����'][pid] = nil	
    if WAR.DJGZ == 1 then	--��������
       WAR.DJGZ = 0
    end
    if WAR.HQT == 1 then	--����ͩ ɱ����
       WAR.HQT = 0
    end
    if WAR.CY == 1 then		--��Ӣ ɱ����
       WAR.CY = 0
    end
	WAR.JYZJ_FXJ= 0
	WAR.DFMQ = 0		--���ħȭ	
    WAR.NGJL = 0		--��ǰ�����ڹ����
    WAR.KHBX = 0		--������Ŀ
    WAR.LXZQ = 0
	WAR.LXYZ = 0
    WAR.GCTJ = 0
    WAR.ASKD = 0
    WAR.LXBR = 0
    WAR.JSYX = 0
    WAR.JLJG = 0
    WAR.BMXH = 0
	WAR.BMSGXL=0
	WAR.DZTG_DZS=0
    WAR.TD = -1
	WAR.TDnum = 0
    WAR.TZ_XZ = 0		--����ָ��
    WAR.JGZ_DMZ = 0		--��Ħ��
    WAR.LHQ_BNZ = 0		--������
	WAR.WD_CLSZ = 0		--��������
	WAR.QZ_QXJF = 0		--���ǽ���	
	WAR.BXXHSJ = 0		--
	WAR.LWSWD = 0		--	
	WAR.TXZQ = {}		--̫��֮�������¼
	WAR.HSHD = {}		--��������	
	WAR.DZZ = {}		--��ʮ������ �������� �����������¼
	WAR.FGPZ = {}		--	
	WAR.JJJ = {}		--�����������¼
    CleanWarMap(4, 0)           --ȫ��
    WAR.SJHB_G =0
    WAR.L_TLD = 0		--װ����������Ч����Ѫ
	WAR.XZBF = 0
	WAR.PJTX = 0 		--�������������������ƾ�����
	WAR.YLSJJ = 0
	WAR.NZZ1 = 0	
	WAR.JGSL = 0 		--��������
	WAR.CXLC = 0		--���Ƴ�������
	WAR.YTLJ = 0		--��������	
	WAR.FQY = 0			--����������ʤ����
	WAR.GHQH = 0		--����Ů�㺮���	
	WAR.LXXZD = 0		--����г֮��
	
	WAR.AJFHNP = 0		--
	WAR.YTML = 0 		--��������
	WAR.SLSS = 0 		--���� ����ɢ��	
	WAR.JSTG = 0		--�����
	WAR.TXZZ = 0		--̫��֮��
	WAR.MMGJ = 0		--äĿ����
	WAR.KHLH = 0	
	WAR.JSAY = 0		--���߰���
	WAR.WDKTJ = 0		--
	WAR.GHQH = 0		--	
	WAR.YQFSQ = 0		--һ��������	
	
	WAR.QXWXJ = 0		--�������ν� Ī��	
	WAR.OYFXL = 0 		--ŷ������ݸ�����������˺�
	WAR.LXXL = 0 		--�������������˺�	
	WAR.XDLeech = 0		--Ѫ����Ѫ��
	WAR.WYXLeech = 0	--ΤһЦ��Ѫ��
	WAR.TMGLeech = 0	--��ħ����Ѫ��
	WAR.BHGLeech = 0	--�̺���Ѫ��	
	WAR.XHSJ = 0		--Ѫ�������Ѫ��
	WAR.KMZWD = 0 		--�ܲ�ͨ����֮���
	WAR.LFHX = 0 		--�ֳ�Ӣ�����ѩ
	WAR.YNXJ = 0		--ز�ÿձ�
	WAR.HXZYJ = 0		--����֮һ��
	WAR.YYBJ = 0 		--���������಻��
    WAR.SEYB = 0	
	WAR.BHJTZ = 0 		--		
	WAR.MHSN = 0 		--	
    WAR.KZJYBF = 0      --
	WAR.BJYPYZ = 0 		--
	WAR.XMJDHS = 0

	WAR.BJYJF = 0      --�̺���ʽ
    WAR.BHJTZ1= 0
	WAR.BHJTZ2= 0
    WAR.BHJTZ3= 0
	WAR.BHJTZ4= 0
    WAR.BHJTZ5= 0
	WAR.BHJTZ6= 0
	
    WAR.DSP_LM1=0   --��������
    WAR.DSP_LM2=0	    
    WAR.DSP_LM3=0	
    WAR.DSP_LM4=0
	
	WAR.NGXS = 0		--�ڹ�������ϵ��
	WAR.TYJQ = 0		--������Ԫ����
	WAR.WWWJ = 0
	WAR.HYYQ=0
	WAR.LDJT = 0
	WAR.CXLZ = 0	
	WAR.QBLL = 0		--
	WAR.SZXM = 0		--	
    WAR.BLCC = 0
    WAR.BLCC_1 = {}	
    WAR.XMHSQ = 0		
	WAR.JTYJ1 = 0		--����һ��
	WAR.HZD_1 = 0		--½����֮����������ˮ��
	WAR.HZD_2 = 0		--½����֮�������ɰٴ�		
	WAR.OYK = 0 		--ŷ��������ȭ
	WAR.JQBYH = 0		--�������������̺�
	WAR.LPZ = 0			--��ƽ֮����
    WAR.JXG_SJG =0      --��Ϣ�� �񾨸�
	
	WAR.QQSH1 = 0		--�����黭֮������
	WAR.QQSH2 = 0		--�����黭֮��ʵ���
	WAR.QQSH3 = 0		--�����黭֮����������
	
	WAR.CMDF = 0		--���鵶��
    WAR.ZWX = 0	
	WAR.HTS = 0			--�������嶾���2-5������
	WAR.YZQS = 0		--һ������
	
	WAR.JJZC = 0		--�Ž��洫��4������������Ч�����������0
	WAR.JMZL = 0
	
	WAR.ZWYJF = 0		--�н������������������Ӿ�������
	
	
	WAR.JuHuo = 0			--�ٻ���ԭ
	WAR.LiRen = 0			--���к���
	
	
	WAR.LWX = 0				--���������������Ч
  	WAR.LXZL10 = 0			--����֮����ŭ�����Ӿ������� 
	WAR.XC_WLCZ = 0			--	
	WAR.XC_JJNP = 0		
	WAR.PDJN = 0			--�¼����Ҷ���ţ	
    WAR.L_QKDNY = {}	--���¼���Ǭ����Ų���Ƿ񱻷�����
	WAR.TXXS = {} 		--��Ч������ʾ
    WAR.RULAISZ = 0
	WAR.RULAISZ_1 = 0
    
    WarDrawAtt(x, y, atkfanwei, 3)
    if ZHEN_ID >= 0 then
		local tmp_id = WAR.CurID
		WAR.CurID = ZHEN_ID
		WarDrawAtt(WAR.Person[ZHEN_ID]["����X"] + x0 - x, WAR.Person[ZHEN_ID]["����Y"] + y0 - y, atkfanwei, 3)
		WAR.CurID = tmp_id
    end
	
	Cat('����̫��2')
	
    if wugong == 26 then
        local m = 1

        if WAR.PD['������˫��ȡˮ'][pid] == 2 then
            m = 2
        end
        local jl = 0
        
        jl = limitX(JY.Person[pid]["ȭ�ƹ���"]/14,0,25)
        
        if match_ID(pid, 50) then 
            if isteam(pid) == false then
                jl = 35
            else 
                jl = limitX(JY.Person[pid]["ȭ�ƹ���"]/10,0,35)
            end
        end
        if JY.Base["��׼"] == 1 then
            jl = limitX(JY.Person[pid]["ȭ�ƹ���"]/10,0,35)
        end
        local a = math.random(m,7)
        if JLSD(0,jl,pid) then
            if a == 1 then
                if WAR.PD['������˫��ȡˮ'][pid] == nil then
                    WAR.PD['������˫��ȡˮ'][pid] = 1
                    TXWZXS('�������⡤˫��ȡˮ', M_Red)
                end
            elseif a == 2 then 
                WAR.PD['�����������л�'][pid] = 1
                TXWZXS('�������⡤�����л�', M_Red)
            elseif a == 3 then 
                WAR.PD['������Ǳ������'][pid] = 1
                TXWZXS('�������⡤Ǳ������', M_Red)
            elseif a == 4 then 
                WAR.PD['�������𾪰���'][pid] = 1
                TXWZXS('�������⡤�𾪰���', M_Red)
            elseif a == 5 then 
                WAR.PD['��������������'][pid] = 1
                TXWZXS('�������⡤��������', M_Red)
            elseif a == 6 then 
                WAR.PD['��������������'][pid] = 1
                TXWZXS('�������⡤��������', M_Red)
            elseif a == 7 then
                --WAR.PD['������ʱ������'][pid] = 1
                TXWZXS('�������⡤ʱ������', M_Red)
                --if WAR.ATNum < 3 then
                WAR.ATNum = WAR.ATNum + 1
                --end
            end
        end
    end   
    
    --��
    if wugong == 80 then 
        local gl = 0
        gl = limitX(JY.Person[pid]["�������"]/14,0,25)
        if match_ID(pid, 69) then 
            if isteam(pid) == false then
                gl = 35
            else 
                gl = limitX(JY.Person[pid]["�������"]/10,0,35)
            end
        end
        if JY.Base["��׼"] == 5 then
            gl = limitX(JY.Person[pid]["�������"]/10,0,35)
        end
            --['���־�'] = {},
            --['���־�'] = {},
            --['ת�־�'] = {},
           -- ['���־�'] = {},
            --['���־�'] = {},
           -- ['���־�'] = {},
           -- ['���־�'] = {},
        local a = math.random(1,6)
        if JLSD(0,gl,pid) then
            if a == 1 then 
                WAR.PD['���־�'][pid] = 1
                TXWZXS('�򹷰��塤���־�', M_Red)
            elseif a == 2 then 
                WAR.PD['���־�'][pid] = 1
                TXWZXS('�򹷰��塤���־�', M_Red)
            elseif a == 3 then 
                --WAR.PD['ת�־�'][pid] = 1
                --if WAR.ATNum < 3 then
                WAR.ATNum = WAR.ATNum + 1
                --end
                TXWZXS('�򹷰��塤ת�־�', M_Red)
            elseif a == 4 then 
                WAR.PD['���־�'][pid] = 1
                TXWZXS('�򹷰��塤���־�', M_Red)
            elseif a == 5 then 
                WAR.PD['���־�'][pid] = 1
                TXWZXS('�򹷰��塤���־�', M_Red)
            elseif a == 6 then 
                WAR.PD['���־�'][pid] = 1
                TXWZXS('�򹷰��塤���־�', M_Red)
            end
        end
    end
    
	--��������
    if WAR.PD["��������"][pid]~= nil and  WAR.PD["��������"][pid] == 1 and WAR.ACT == 2 then
        WAR.Person[id]["��Ч����"] = 119	   
        wugong = 44
		local HDJYLJZS = {"�����������罣�� ���ر���","�����������罣�� ��������","�����������罣�� �׺����","�����������罣�� ���б���","�����������罣�� ������ɽ"};
		local A = HDJYLJZS[math.random(5)];
		TXWZXS(A, M_DeepSkyBlue)
		WAR.PD["��������"][pid] = 2
	end	
	
    --�жϹ�����������1����ʾ����
    if WAR.ACT > 1 and WAR.PD["��������"][pid] == nil then   
		local A = "����"
		if WAR.TWLJ == 1 then
			A = "�츳�⹦.¯����"
		end	
		if WAR.TJZX_LJ == 1 then
			A = "̫��֮��.Բת����"
			WAR.TJZX_LJ = 0
		end

		--���޵���
		if wugong == 62 then
			--���л�
			if match_ID(pid, 77) then
				A = "��������˫����"
			--��������
			elseif pid == 0 and JY.Person[0]["�Ա�"] == 0 then
				A = "Ӣ����˫������"
			--����Ů��
			elseif pid == 0 and JY.Person[0]["�Ա�"] ~= 0 then
				A = "������ӳ��ȸ��"
			end
		end

		
		--��������
		if match_ID(pid, 27) then
			A = "��������"
		end
		--�ĵ���Ч����4��ʾ
		if WAR.Person[WAR.CurID]["��Ч����4"] ~= nil then
			WAR.Person[WAR.CurID]["��Ч����4"] = WAR.Person[WAR.CurID]["��Ч����4"] .."��".. A
		else
			WAR.Person[WAR.CurID]["��Ч����4"] = A;
		end
    end

	--��Ů�ľ���������磬��һ���м��ʷ�����׷��һ������
	if Curr_NG(pid, 154)  and WAR.ACT == 1 then
		local ynjl = 0;
		if pid == 0 then
			ynjl = 5
		end
		--����ŮŮ�ط���  
		if  match_ID(pid,640) or WAR.LQZ[pid] == 100 or JLSD(30, 30 + JY.Base["��������"]*2 + ynjl, pid) then
			WAR.ATNum = WAR.ATNum + 1
			Set_Eff_Text(id,"��Ч����1","�������");
		end
	end

	--���⣬��33%���ʶ�����һ��
	if Given_WG(pid, wugong) and JLSD(33, 66, pid) and WAR.TWLJ == 0 and WAR.ATNum < 2 then
		WAR.ATNum = WAR.ATNum + 1
		WAR.TWLJ = 1
	end

	--����������������
	if WAR.JYSZ ==1 and WAR.SYLJ == 0 and  WAR.ACT > 1  then
		WAR.JYLJ = 1
		local color = M_DeepSkyBlue
		local n = {'����','����','�Ļ�','���'}
		local display = "������צ.�޼᲻��."
		if WAR.ACT > 1 then
			display = display..n[WAR.ACT-1]
			TXWZXS(display, color)
		end
    end		

	--�޾Ʋ������������ú�������
	local BJ;
	
	BJ = Person_BJ(pid)
	
	--���˱���+20%
    --if WAR.Person[id]["�ҷ�"] == false then
    	--BJ = BJ + 20
   -- end
	--���㹦
	if Curr_QG(pid,223) then
		BJ = BJ + 20
	end
	--��Ϣ����������500���ر�
	if PersonKF(pid, 180) and WAR.PD["��Ϣ����"][pid] ~= nil and WAR.PD["��Ϣ����"][pid] > 500  then
		BJ = BJ + 100
	end	
	--����������100
    if BJ > 100 then
		BJ = 100
    end
    
	if JLSD(0,BJ,pid) then
		WAR.BJ = 1
    end
	
    --�߱����书
    local gbj = {11, 13, 28, 33, 58, 59, 72, 75, 114}
    for i = 1, 9 do
		if JY.Person[pid]["�书" .. wugongnum] == gbj[i] and JLSD(20, 75, pid) then
			WAR.BJ = 1
			break;
		end
    end
    
    --װ���������������������
	--1��50%�����ʣ�6��100%
	--6�������ƾ����£��ر��������Ӿ�������
    if JY.Person[pid]["����"] == 36 and wugong == 45 then
		if JLSD(0, 40 + JY.Thing[36]["װ���ȼ�"] * 10, pid) then
			WAR.BJ = 1
		end
		if JY.Thing[36]["װ���ȼ�"] == 6 then
			WAR.PJTX = 1
			Set_Eff_Text(id,"��Ч����0","�ؽ��޷桤�ƾ�����");
		end
    end
	--�廨�룬���Ӿ������� 
	if JY.Person[pid]["����"] == 349 and JY.Thing[349]["װ���ȼ�"] == 6 then
       WAR.PD["�廨��"][pid] = 1
	   --Set_Eff_Text(id,"��Ч����0","�������ղ�");
	end	
	--�̺���ʽ5�ر��� ��ˮ��
	if WAR.BHJTZ5== 1  then
	WAR.BJ = 1
	end			
	--��ָ��ͨ������һ��������ر���
	if wugong == 18 and TaohuaJJ(pid) then
		WAR.BJ = 1
	end
    --�������
	if match_ID(pid,9989) then
		WAR.BJ = 1
	end
	--��������
	if wugong == 86 and match_ID(pid,9994) then
		WAR.BJ = 1
	end
	--��հ��� ������
	if wugong == 22 and JinGangBR(pid) then
        WAR.BJ = 1 
    end  		
	--��ħ�����ر���
	if Curr_NG(pid, 160) then
		WAR.BJ = 1
	end
    if match_ID(pid,568) and wugong == 198 then
		WAR.BJ = 1
	end
   --װ����������ʹ�õȼ�Ϊ���ĵ������м��ʴ���������Ч
	if JY.Person[pid]["����"] == 43 then
	  	if kfkind == 4 and level == 11 then
    		--����Ѫ����׷�ӵ�ͬ���书������ɱ����50%���������ж�
    		if JLSD(25, 75, pid) then
    			WAR.L_TLD = 1;
				Set_Eff_Text(id,"��Ч����0","��������.��������");
			--���û�д���������40%���ʴ����ض�����
    		elseif JLSD(35, 75, pid) then	
    			WAR.BJ = 1
				Set_Eff_Text(id,"��Ч����0","��������.Ī�Ҳ���");
    		end
    	end
	end
	  
	local ng = 0
	
	--�����󷨱ض�������
	if wugong == 87 then
		WAR.BJ = 0
	end
	--�����۶��Ʊض�������
	if wugong == 115 then
		WAR.BJ = 0
	end	
	--�����ֱض�������
	if wugong == 187 then
	WAR.BJ = 0
	end		
	--�������
    if WAR.BJ == 1 then
		WAR.Person[id]["��Ч����"] = 89		--������Ч����
		if match_ID(pid, 50) then			--�Ƿ���Ч����
			local r = nil
			r = math.random(3)
			if r == 1 then
				Set_Eff_Text(id,"��Ч����1","�̵����ۼ� �������� ��Ӣ��ŭ");
			elseif r == 2 then
				Set_Eff_Text(id,"��Ч����1","����ǧ��������");
			elseif r == 3 then
				Set_Eff_Text(id,"��Ч����1","�������� ����Ӣ����");
			end
		end
		--�ĳ���Ч����4��ʾ
		if WAR.Person[WAR.CurID]["��Ч����4"] ~= nil then
			WAR.Person[WAR.CurID]["��Ч����4"] = WAR.Person[WAR.CurID]["��Ч����4"] .."��".. "����"
		else
			WAR.Person[WAR.CurID]["��Ч����4"] = "����";
		end
    end
	
    --�޾Ʋ����������ڹ�����
	if JY.Person[pid]["�����ڹ�"] > 0 then
		local cur_NG = JY.Person[pid]["�����ڹ�"]
		--��������ղ������������磬��������������
		if cur_NG ~= 85 and cur_NG ~= 87 and cur_NG ~= 88 and cur_NG ~= 144 and cur_NG ~= 143 and cur_NG ~= 91 and cur_NG ~= 175 then
			local cur_NGL = 0;
			for i = 1, JY.Base["�书����"] do
				if JY.Person[pid]["�书"..i] ==  cur_NG then
					cur_NGL = JY.Person[pid]["�书�ȼ�" .. i];
					if cur_NGL == 999 then
						cur_NGL = 11
					else
						cur_NGL = math.modf(cur_NGL / 100) + 1
					end
					break;
				end
			end
			--�����ڹ���35%�ĸ����ȼ��ж�
			if cur_NGL ~= 0 and JLSD(30, 65, pid) then
				ng = get_skill_power(pid, cur_NG, cur_NGL);
				WAR.Person[id]["��Ч����2"] = JY.Wugong[JY.Person[pid]["�����ڹ�"]]["����"] .. "����"
				WAR.Person[id]["��Ч����"] = 93
				WAR.NGJL = JY.Person[pid]["�����ڹ�"];
			end
		end
	end
	
	--���û�д��������ڹ����������ж�һ�����
	if WAR.NGJL == 0 then
		local N_JL = {};		
		local num = 0;	--��ǰѧ�˶��ٸ��ڹ�
		for i = 1, JY.Base["�书����"] do
			local kfid = JY.Person[pid]["�书" .. i]
			local kflvl = JY.Person[pid]["�书�ȼ�" .. i]
			if kflvl == 999 then
				kflvl = 11
			else
				kflvl = math.modf(kflvl / 100) + 1
			end
			--�Ȱ��ڹ�����������������ղ������������磬��������������
			if JY.Wugong[kfid]["�书����"] == 6 and kfid ~= 85 and kfid ~= 87 and kfid ~= 88 and kfid ~= 144 and kfid ~= 143 and kfid ~= 91 and kfid ~= 175 then
				num = num + 1;
				N_JL[num] = {kfid,i,get_skill_power(pid, kfid, kflvl)};
			end
		end
				
		--���ѧ���ڹ�
		if num > 0 then	
			--���������Ӵ�С��������һ���Ļ����������Ⱥ�˳��
			for i = 1, num - 1 do
				for j = i + 1, num do
					if N_JL[i][3] < N_JL[j][3] or (N_JL[i][3] == N_JL[j][3] and N_JL[i][2] > N_JL[j][2])then
						N_JL[i], N_JL[j] = N_JL[j], N_JL[i]
					end
				end
			end
			--��˳���ж�����
			for i = 1, num do
				--��������������״̬�ض�����
				if (match_ID(pid, 129) and WAR.BDQS > 0) or myrandom(10, pid) then
					ng = N_JL[i][3];
					WAR.Person[id]["��Ч����2"] = JY.Wugong[N_JL[i][1]]["����"] .. "����"
					WAR.Person[id]["��Ч����"] = 87 + math.random(6)
					WAR.NGJL = N_JL[i][1];
					break;
				end
					for i = 1, num do
			   end

			end
		end
	end

    if isteam(pid) == false then 
        local nd = JY.Base['�Ѷ�']
        local fj = 7 - JY.Person[pid]["����ֽ�"]
        ng = ng + nd*300 + fj*300
        if WAR.NGJL == 0 then
            WAR.Person[id]["��Ч����"] = 87
            WAR.Person[id]["��Ч����2"] = '�����ڹ�'.. "����"
        end
    end
    
   --��������������
    if WAR.NGJL == 204 then
        WAR.Person[id]["��Ч����"] = 111 
    end
    if match_ID(pid,50) and PersonKF(pid,204) and WAR.NGJL == 0 then
    		WAR.Person[id]["��Ч����"] = 111
		WAR.Person[id]["��Ч����2"] = "����������"
		ng = ng + 1000
    end   
	--���޼� ����ɮ ��������
    if match_ID(pid, 9) or match_ID(pid, 638) and WAR.NGJL == 0 and PersonKF(pid, 106) then
		WAR.Person[id]["��Ч����"] = math.fmod(106, 10) + 85
		WAR.Person[id]["��Ч����2"] = "�����񹦼���"
		ng = ng + 1200
    end
		--��Ϣ����������
	if PersonKF(pid, 180) and WAR.DZXY == 0 then
		if WAR.PD["��Ϣ����"][pid] == nil then
			WAR.PD["��Ϣ����"][pid] = 0
		elseif WAR.PD["��Ϣ����"][pid] > 100 then
			ng = ng + WAR.PD["��Ϣ����"][pid]+500
		  
			if WAR.Person[id]["��Ч����2"] ~= nil then
				WAR.Person[id]["��Ч����2"] = WAR.Person[id]["��Ч����2"].. "��һ�ղ׺�ʽ"
			else
				WAR.Person[id]["��Ч����2"] = "һ�ղ׺�ʽ"
			end
			--��������˺�
			if match_ID(pid, 635) then
				WAR.LXXL = WAR.PD["��Ϣ����"][pid]
			end
			WAR.Person[id]["��Ч����"] = math.fmod(95, 10) + 85
			--������0
			WAR.PD["��Ϣ����"][pid] = WAR.PD["��Ϣ����"][pid]*0.5
		end
	end	

	--�����죬��ת������
	if PersonKF(pid, 95) and WAR.DZXY == 0 then
		if WAR.PD["�������"][pid] == nil then
			WAR.PD["�������"][pid] = 0
		elseif WAR.PD["�������"][pid] > 100 then
			ng = ng + WAR.PD["�������"][pid] * 10 
			if ng > 1000 then
			ng = 1000	  
			if WAR.Person[id]["��Ч����3"] ~= nil then
				WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"].. "��������"
			else
				WAR.Person[id]["��Ч����3"] = "������"
			end
			--ŷ��������˺�
			if match_ID(pid, 60) then
				WAR.OYFXL = WAR.PD["�������"][pid]
			end
			WAR.Person[id]["��Ч����"] = math.fmod(95, 10) + 85
			--���᲻��0
			--������0
			WAR.PD["�������"][pid] = 0
		    end
	    end	
    end

	--�츳�⹦���100������
	if Given_WG(pid, wugong) then
		ng = ng + 100
	end
    -- �̺���ʽ1 �����˺�
	--if WAR.LXBHZS == 1 then
	 -- ng = ng +200
	 --end
	 --���� ����Х��
	
	-- 	��Ϣ��
	if (match_ID(pid,635) and (wugong == 179 or Curr_NG(pid,180))) or (wugong == 179 and Curr_NG(pid,180) and JLSD(0,40,pid)) then
		local yyl = 0
		local ttq = 0
		local xwj = 0
		local dsj = 0
		local smd = 0
		local xkl = 0		
		local times = 1
		--if WAR.LQZ[pid] == 100  then
            --times = 2
		--end
		--for i = 1, times do
            local bh = math.random(6)
			if bh == 1 then
                WAR.BHJTZ1= 1
                Set_Eff_Text(id,"��Ч����1","������");
			elseif bh == 2 then
                WAR.BHJTZ3= 1
                Set_Eff_Text(id,"��Ч����1","�����");
			elseif bh == 3 then
                Set_Eff_Text(id,"��Ч����1","���о�");
                WAR.ATNum = WAR.ATNum + 1
            elseif bh == 4 then
                WAR.BHJTZ5= 1
                Set_Eff_Text(id,"��Ч����1","��ˮ��");
			elseif bh == 5 then
                WAR.BHJTZ2= 1
                Set_Eff_Text(id,"��Ч����1","�����");
			elseif bh == 6 then
                WAR.BHJTZ6= 1
                Set_Eff_Text(id,"��Ч����1","�ݿ���");				
			end
		--end
    end

 		-- 	��˼ƽ ������
	if wugong == 49 then
        local gl = math.modf(JY.Person[pid]["ʵս"]/20)
        if match_ID(pid,499) or JLSD(0,25+gl,pid) then
			local jntg = 0
			local jhjy = 0
			local nkwj = 0
			local hxjy = 0	
			local times = 1
			--if WAR.LQZ[pid] == 100  then
				--times = 2
			--end
			--for i = 1, times do
			local bh = math.random(4)
			if bh == 1 then
				jntg = 1
			elseif bh == 2 then
				jhjy = 1
			elseif bh == 3 then
				nkwj = 1
			elseif bh == 4 then
				hxjy = 1					
			end
			--end
			if jntg == 1 then
				WAR.DSP_LM1= 1
				Set_Eff_Text(id,"��Ч����1","�������");
			end	
			if jhjy == 1 then
				Set_Eff_Text(id,"��Ч����1","���;�Ӱ");
				WAR.DSP_LM2= 1
				WAR.ATNum = WAR.ATNum + 1
			end		
			if nkwj == 1 then
				Set_Eff_Text(id,"��Ч����1","�Ͽ���");
				 WAR.BJ = 1
				 WAR.DSP_LM3= 1
			end			
			if hxjy == 1  then
				Set_Eff_Text(id,"��Ч����1","������ӡ");			
			   WAR.DSP_LM4= 1			
			end
        end    
	end	
	
    if wugong == 109 then 
        local gl = 0
        if inteam(pid) then
            gl = math.modf(JY.Person[pid]["ʵս"]/20)
        else
            gl = 25
        end
        if JLSD(0,25+gl,pid) then
            local str = {'��ȭ��ȭ����ɽ','��ȭ�����Ƽ�ˮ','��ȭ�������Ʋ�'}
            local a = math.random(3)
            WAR.PD['Ұ��ȭ'][pid] = a
            Set_Eff_Text(id,"��Ч����3",str[a])
        end
    end
    
    if wugong == 111 then 
        local gl = 0
        if inteam(pid) then
            gl = math.modf(JY.Person[pid]["ʵս"]/20)
        else
            gl = 25
        end
        if JLSD(0,25+gl,pid) then
            local str = {'����ӭ�����','������������','������ľ�ɷ�','�������˺�һ'}
            local a = math.random(4)
            if a < 4 then
                WAR.PD['���ϵ�'][pid] = a
            else
                WAR.PD['���ϵ�������'][pid] = 2
            end
            Set_Eff_Text(id,"��Ч����3",str[a])
        end
        if WAR.PD['���ϵ����е�'][pid] == nil then 
            WAR.PD['���ϵ����е�'][pid] = {}
            WAR.PD['���ϵ����е�'][pid][1] = 1
            WAR.PD['���ϵ����е�'][pid][2] = 50
        else
            WAR.PD['���ϵ����е�'][pid][1] = (WAR.PD['���ϵ����е�'][pid][1] or 0) + 1 
            if WAR.PD['���ϵ����е�'][pid][1] > 20 then 
                WAR.PD['���ϵ����е�'][pid][1] = 20
            end
            WAR.PD['���ϵ����е�'][pid][2] = 50
        end
    end
    
	--�¼����Ҷ���ţ
	if match_ID(pid, 75) and JLSD(20,70,pid) then
		WAR.PDJN = 1
		Set_Eff_Text(id,"��Ч����1","�Ҷ���ţ")
	end
   -- ʮ��ʮ��
    if Curr_NG(pid,103) and JinGangBR(pid) and JLSD(20,40,pid) then
		WAR.SLSX[pid] = 1
    end	
   -- ���� ������
   if PersonKF(pid,107) and (JY.Person[pid]["��������"] == 0  or JY.Person[pid]["��������"] == 3) then
       local jl = 50
		if JLSD(0,jl,pid) or WAR.LQZ[pid] == 100 then
			WAR.JYZJ_FXJ = 1
			Set_Eff_Text(id,"��Ч����1","������");
		end
	end

   -- �����칦 ����ʦ
    if PersonKF(pid,190)  then
		local jl = 30
		if Curr_NG(pid,190) then
			jl = 50
		end
		if JLSD(0,jl,pid) or WAR.LQZ[pid] == 100 then
			WAR.DZTG_DZS = 1
			Set_Eff_Text(id,"��Ч����1","����ʦ");
		end
	end
	
  --���ѧ�ᱱڤ��
    if (PersonKF(pid, 85) and JLSD(45, 75, pid)) or (Curr_NG(pid, 85) and JLSD(20, 70, pid)) then
		if WAR.Person[id]["��Ч����"] == -1 then
			WAR.Person[id]["��Ч����"] = math.fmod(85, 10) + 85
		end
		Set_Eff_Text(id,"��Ч����2","��ڤ��");
		WAR.BMXH = 1
		  
		--��ڤ������
		for w = 1, JY.Base["�书����"] do
			if JY.Person[pid]["�书" .. w] < 0 then
				break;
			end
			if JY.Person[pid]["�书" .. w] == 85 then
				JY.Person[pid]["�书�ȼ�" .. w] = JY.Person[pid]["�书�ȼ�" .. w] + 50
				if JY.Person[pid]["�书�ȼ�" .. w] > 999 then
					JY.Person[pid]["�书�ȼ�" .. w] = 999
				end
				break;
			end
		end
    end
      
    --���Ǵ󷨣��뱱ڤ����ͬʱ����
	--������Դ�50���ʴ���
    if (((PersonKF(pid, 88) and JLSD(45, 75, pid)) or (Curr_NG(pid, 88) and JLSD(20, 70, pid))) or (match_ID(pid,189) and JLSD(20, 70, pid))) and WAR.BMXH == 0  then
		if WAR.Person[id]["��Ч����"] == -1 then
			WAR.Person[id]["��Ч����"] = math.fmod(88, 10) + 85
		end
		Set_Eff_Text(id,"��Ч����2","���Ǵ�");
		WAR.BMXH = 2

		--���Ǵ�����
		for w = 1, JY.Base["�书����"] do
			if JY.Person[pid]["�书" .. w] < 0 then
				break;
			end
			if JY.Person[pid]["�书" .. w] == 88 then
				JY.Person[pid]["�书�ȼ�" .. w] = JY.Person[pid]["�书�ȼ�" .. w] + 50
				if JY.Person[pid]["�书�ȼ�" .. w] > 999 then
					JY.Person[pid]["�书�ȼ�" .. w] = 999
				end
				break;
			end
		end
    end
    
    --������
    if ((PersonKF(pid, 87) and JLSD(45, 75, pid)) or (Curr_NG(pid, 87) and JLSD(20, 70, pid))) and WAR.BMXH == 0 then
		if WAR.Person[id]["��Ч����"] == -1 then
			WAR.Person[id]["��Ч����"] = math.fmod(87, 10) + 85
		end
		Set_Eff_Text(id,"��Ч����2","������");
		WAR.BMXH = 3
		  
		--����������
		for w = 1, JY.Base["�书����"] do
			if JY.Person[pid]["�书" .. w] < 0 then
				break;
			end
			if JY.Person[pid]["�书" .. w] == 87 then
				JY.Person[pid]["�书�ȼ�" .. w] = JY.Person[pid]["�书�ȼ�" .. w] + 50
				if JY.Person[pid]["�书�ȼ�" .. w] > 999 then
					JY.Person[pid]["�书�ȼ�" .. w] = 999
				end
				break;
			end
		end
    end
	
	--�ɸ磬����+2000��
	if pid == 627 then
		ng = ng + 2000
	end
    --�۽������ｱ��
    if pid == 0 and JY.Person[592]["�۽�����"] == 1	then
	   ng = ng + 1000
	end
    
    --�����ʹ�û�Ԫ������1000����
    if match_ID(pid,189) and wugong ==90 then
       ng = ng +1000
    end     

    --�����伲���
    if match_ID(pid,27) and inteam(pid) == false and WAR.ZDDH == 348 and JLSD(10,40,pid) then
			WAR.Person[id]["��Ч����"] = 6
			Set_Eff_Text(id,"��Ч����0","�伲���");
			--WAR.FLHS1 = 1
			WAR.PD['�����'][pid] = (WAR.PD['�����'][pid] or 0) + 1
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[WAR.CurID]["�ҷ�"] then
					WAR.Person[j].Time = WAR.Person[j].Time + 100
				end
				if WAR.Person[j].Time > 980 then
					WAR.Person[j].Time = 980
			   end
		  end
	end
		
	--�伲���
	if match_ID(pid, 9973) and JLSD(10,40,pid) then 
		WAR.Person[id]["��Ч����"] = 6
		Set_Eff_Text(id, "��Ч����0", "�伲���")
		WAR.PD['�����'][pid] = (WAR.PD['�����'][pid] or 0) + 1
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[WAR.CurID]["�ҷ�"] then
				WAR.Person[j].Time = WAR.Person[j].Time + 100
			end
			if WAR.Person[j].Time > 980 then
				WAR.Person[j].Time = 980
			end
		end
	end

	--�Ƿ��������
	if match_ID(pid,50) and not inteam(pid) and WAR.ZDDH == 348 and JLSD(10,50,pid) then
		WAR.Person[id]["��Ч����"] = 6
		Set_Eff_Text(id,"��Ч����0","�������");
		ng = ng + 2000
	end
		
		--�Ƿ��������
	if match_ID(pid,9972) and JLSD(10,50,pid) then
        WAR.PD['�����'][pid] = 1
		WAR.Person[id]["��Ч����"] = 6
		Set_Eff_Text(id,"��Ч����0","�������");
		ng = ng + 1000
	end

	
	   --����ˮ �������
    if match_ID(pid, 652) then
		ng = ng + 1000

		WAR.Person[id]["��Ч����"] = 83
		if WAR.Person[id]["��Ч����2"] ~= nil then
			WAR.Person[id]["��Ч����2"] = WAR.Person[id]["��Ч����2"].."+��������"
		else
			WAR.Person[id]["��Ч����2"] = "�����������"
		end
    end	


	--�Ħ��
	if match_ID(pid, 103) and (inteam(pid)==false or JLSD(20,70+JY.Base["��������"]+math.modf(JY.Person[pid]["ʵս"]/50),pid)) then
		ng = ng + 600

		WAR.Person[id]["��Ч����"] = math.fmod(98, 10) + 85
		Set_Eff_Text(id, "��Ч����2", "��������")
	end
	
	--����
    if match_ID(pid, 18) and (inteam(pid)==false or JLSD(20,70+JY.Base["��������"]+math.modf(JY.Person[pid]["ʵս"]/50),pid)) then
		ng = ng + 600

		WAR.Person[id]["��Ч����"] = 6
		if WAR.Person[id]["��Ч����2"] == nil then
			WAR.Person[id]["��Ч����2"] = "��Ԫ����������"
		else
			WAR.Person[id]["��Ч����2"] = WAR.Person[id]["��Ч����2"].."+��Ԫ������"
		end
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = "ħ�ࡤ����".."��"..WAR.Person[id]["��Ч����3"]
		else
			WAR.Person[id]["��Ч����3"] = "ħ�ࡤ����"
		end
    end
	--��̫��
    if match_ID(pid, 7) then
		ng = ng + 1000

		WAR.Person[id]["��Ч����"] = 6
		if WAR.Person[id]["��Ч����2"] == nil then
			WAR.Person[id]["��Ч����2"] = "̫���������"
		else
			WAR.Person[id]["��Ч����2"] = WAR.Person[id]["��Ч����2"].."+̫�����"
		end
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = "̫�塤����һ".."��"..WAR.Person[id]["��Ч����3"]
		else
			WAR.Person[id]["��Ч����3"] = "̫�塤����һ"
		end
    end
	
 	--������
    if match_ID(pid, 12) and (inteam(pid)==false or JLSD(20,70+JY.Base["��������"]+math.modf(JY.Person[pid]["ʵս"]/50),pid)) then
		ng = ng + 500

		WAR.Person[id]["��Ч����"] = 67
		Set_Eff_Text(id,"��Ч����2","ӥ������");
    end
	

	
	--brolycjw: ��ҩʦ
    if match_ID(pid, 57) and (inteam(pid)==false or JLSD(20,70+JY.Base["��������"]+math.modf(JY.Person[pid]["ʵս"]/50),pid)) then
		ng = ng + 600

		WAR.Person[id]["��Ч����"] = 95
		Set_Eff_Text(id,"��Ч����2","���Ű���");
    end
	

	
	--�ݳ���
    if match_ID(pid, 594) and (inteam(pid)==false or JLSD(20,70+JY.Base["��������"]+math.modf(JY.Person[pid]["ʵս"]/50),pid)) then
		ng = ng + 600

		WAR.Person[id]["��Ч����"] = 93
		Set_Eff_Text(id,"��Ч����2","�����Ὥ");
    end
	
	--Ľ�ݲ�
    if match_ID(pid, 113) and (inteam(pid)==false or JLSD(20,70+JY.Base["��������"]+math.modf(JY.Person[pid]["ʵս"]/50),pid)) then
		ng = ng + 600

		WAR.Person[id]["��Ч����"] = 93
		Set_Eff_Text(id,"��Ч����2","�κ�����");
    end
	
    --������ 
    if match_ID(pid, 26) and (inteam(pid)==false or JLSD(20,70+JY.Base["��������"]+math.modf(JY.Person[pid]["ʵս"]/50),pid)) then
		ng = ng + 600

		WAR.Person[id]["��Ч����"] = 6
		Set_Eff_Text(id,"��Ч����2","ħ�ۡ�����");
    end
	
	--������
    if match_ID(pid, 83) and (inteam(pid)==false or JLSD(20,70+JY.Base["��������"]+math.modf(JY.Person[pid]["ʵս"]/50),pid)) then
		ng = ng + 500

		WAR.Person[id]["��Ч����"] =  92
		Set_Eff_Text(id,"��Ч����2","�������");
    end
	
	--��������ɳ����ÿɱһ����+200����
	if match_ID(pid, 47) then
		ng = ng + 200*WAR.MZSH
	end
	
	
    --����
    if match_ID(pid, 102) and (inteam(pid)==false or JLSD(20,70+JY.Base["��������"]+math.modf(JY.Person[pid]["ʵս"]/50),pid)) then
		ng = ng + 600

		WAR.Person[id]["��Ч����"] = 23
		if math.random(2) == 1 then
			if WAR.Person[id]["��Ч����3"] ~= nil then
				WAR.Person[id]["��Ч����3"] = "�г��޳���˫�����١�"..WAR.Person[id]["��Ч����3"]
			else
				WAR.Person[id]["��Ч����3"] = "�г��޳���˫������"
			end
		else
			if WAR.Person[id]["��Ч����3"] ~= nil then
				WAR.Person[id]["��Ч����3"] = "�ϱ��������Ǽٷǿա�"..WAR.Person[id]["��Ч����3"]
			else
				WAR.Person[id]["��Ч����3"] = "�ϱ��������Ǽٷǿ�"
			end
		end
    end
    
    --����ڹ����������ˣ�50%���ʷ������������
    if pid == 0 and JY.Base["��׼"] == 6 and kfkind == 6 and level == 11 then
		WAR.WS = 1
		if JLSD(25, 75, pid) then
			if WAR.Person[id]["��Ч����3"] ~= nil then
				WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"].."+���������"..JY.Wugong[wugong]["����"]
			else
				WAR.Person[id]["��Ч����3"] = "���������"..JY.Wugong[wugong]["����"]
			end
			ng = ng + JY.Wugong[wugong]["������10"]
		end
    end

	
	--��ת�����ǳ���Ч����
	if WAR.DZXYLV[id] == 115 then
		WAR.Person[id]["��Ч����"] = 107
    end

	
    --��������1
    if wugong == 11 and (Curr_NG(pid,107) or match_ID(pid,640)) then
		local jy = 0
		---����50% ��������40
		if  WAR.JYSZ == 0 and (JY.Person[pid]["��������"] == 0 or JY.Person[pid]["��������"] == 3)and (JLSD(20, 60+JY.Base["��������"]*2, pid) or WAR.LQZ[pid] == 100) then
			jy = 1
			ng = ng + 1000
			WAR.WS = 1
			for i = 1, (level) / 2 + 1 do
				for j = 1, (level) / 2 + 1 do
					SetWarMap(x + i - 1, y + j - 1, 4, 1)
					SetWarMap(x - i + 1, y + j - 1, 4, 1)
					SetWarMap(x + i - 1, y - j + 1, 4, 1)
					SetWarMap(x - i + 1, y - j + 1, 4, 1)
				end
			end
		end
	end

    if WAR.PD['Ұ��ȭ'][pid] == 3 then
        ng = ng + 1000
        WAR.WS = 1
		for i = 1, (level) / 2 + 1 do
			for j = 1, (level) / 2 + 1 do
				SetWarMap(x + i - 1, y + j - 1, 4, 1)
				SetWarMap(x - i + 1, y + j - 1, 4, 1)
				SetWarMap(x + i - 1, y - j + 1, 4, 1)
				SetWarMap(x - i + 1, y - j + 1, 4, 1)
			end
		end
    end
    
    --ʹ�ý���ʮ����
    if wugong == 26 then
		local jy = 0
		local xljl = 0
		if PersonKF(pid,204) then
            xljl = 0
		end
		--�Ƿ�س����⣬���߹���������ȭ����40% ������15%
		--if match_ID(pid, 50) or ((match_ID(pid, 69) or match_ID(pid, 55) or (pid == 0 and JY.Base["��׼"] == 1)) and JLSD(30, 70+xljl, pid)) or (Curr_NG(pid,204) and JLSD(0,xljl*2,pid) then
	    if match_ID(pid, 69) then
			xljl = xljl + 40
		end
        if 	pid == 0 and JY.Base["��׼"] == 1 then
			xljl = xljl + 40
		end
		if  match_ID(pid, 55) then
			xljl = xljl + 40
		end
		if Curr_NG(pid,204) then
			xljl = xljl + 15
		end
        if JLSD(30,40+xljl,pid) or 	match_ID(pid, 50) then
          Set_Eff_Text(id, "��Ч����3", XL18JY[math.random(8)])		
			jy = 1
			ng = ng + 1000
			WAR.WS = 1
			for i = 1, (level) / 2 + 1 do
				for j = 1, (level) / 2 + 1 do
					SetWarMap(x + i - 1, y + j - 1, 4, 1)
					SetWarMap(x - i + 1, y + j - 1, 4, 1)
					SetWarMap(x + i - 1, y - j + 1, 4, 1)
					SetWarMap(x - i + 1, y - j + 1, 4, 1)
				end
			end
        elseif myrandom(15 + (level), pid) then
			if jy == 0 then
				Set_Eff_Text(id, "��Ч����3", XL18[math.random(6)])
				ng = ng + 800
			end
			for i = 1, (1 + (level)) / 2 do
				for j = 1, (1 + (level)) / 2 do
					SetWarMap(WAR.Person[WAR.CurID]["����X"] + i * 2 - 1, WAR.Person[WAR.CurID]["����Y"] + j * 2 - 1, 4, 1)
					SetWarMap(WAR.Person[WAR.CurID]["����X"] - i * 2 + 1, WAR.Person[WAR.CurID]["����Y"] + j * 2 - 1, 4, 1)
					SetWarMap(WAR.Person[WAR.CurID]["����X"] + i * 2 - 1, WAR.Person[WAR.CurID]["����Y"] - j * 2 + 1, 4, 1)
					SetWarMap(WAR.Person[WAR.CurID]["����X"] - i * 2 + 1, WAR.Person[WAR.CurID]["����Y"] - j * 2 + 1, 4, 1)
				end
			end
		end
    end
    
    
    --˫���ϱڣ���������
	if ShuangJianHB(pid) and (wugong == 39 or wugong == 42 or wugong == 139 )  then
		Set_Eff_Text(id, "��Ч����3", SJHBJFZS[math.random(10)])		 
		ng = ng + 800
	    WAR.WS = 1
    end
    
	if ShuangJianHB(pid) == false and wugong == 39 then
		ng = ng + 800
		Set_Eff_Text(id, "��Ч����3", QZJFZS[math.random(4)])
    end
    
    if ShuangJianHB(pid) == false and (wugong == 42 or wugong == 139) then
		ng = ng + 800
     	Set_Eff_Text(id, "��Ч����3", YLJFZS[math.random(6)])
    end	
	
	--��ڤ���⣬������40%���ʴ�������ŭ�س�����ڤ���ϱس�
	local xmjy = 0
	if match_ID(pid,647) or match_ID(pid,648) then
		xmjy = 1
	end
	if pid == 0 and (WAR.LQZ[pid] == 100 or JLSD(30, 70, pid)) then
		xmjy = 1
	end
	
	--�����񽣣�50%���ʽ������̺�
	if wugong == 49 then
	    local jl = 50
	    if PersonKF(pid,207) then
            jl = jl + 10 
            if JLSD(20,jl,pid)  or match_ID(pid,499) then
                WAR.JQBYH = 1
                Set_Eff_Text(id, "��Ч����3", "�������̺�")
            end
        end
    end 
	--ʹ��������
    if wugong == 49 then
		local jl = 0
    	--ѧ��һ��ָ
     	if PersonKF(pid, 17) then
			jl = jl + 30
		end
		if myrandom(level+jl, pid) or (match_ID(pid, 53) and myrandom(level+jl, pid)) then
			if WAR.Person[id]["��Ч����3"] ~= nil then
				WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "��" ..LMSJ[math.random(6)]
			else
				WAR.Person[id]["��Ч����3"] = LMSJ[math.random(6)]
			end
			ng = ng + 1000
			if match_ID(pid, 53) then
				WAR.LMSJwav = 1
				WAR.WS = 1
			end
		end
    end
    
      
    --�޺�ȭ���׽���������ƣ�60%���ʣ��з��س�
    if wugong == 1 and PersonKF(pid, 108) then
    	if JLSD(20, 80, pid) then
     	 	WAR.LHQ_BNZ = 1
    	end
    end
      
    --��������ƣ��׽������Ħ�ƣ�60%���ʣ��з��س�
    if wugong == 22 and PersonKF(pid, 108)  then
    	if JLSD(40, 100, pid) then
			WAR.JGZ_DMZ = 1
    	end
    end
	

	--�嶾���ƣ���Ī������70%���ʱ��������
    if wugong == 3 and match_ID(pid, 161) and JLSD(10, 80, pid) then
		WAR.WD_CLSZ = 1
    end	
   	--�𴦻� ȫ�潣��ѧ�����칦 �����ǽ���
    if wugong == 39 and match_ID(pid, 68) and PersonKF(pid,100) then
		WAR.QZ_QXJF = 1
    end	   
    --ͭ����9��ǿ��ͭ�ˣ�ֱ�Ӵ�����Ħ��
    if pid > 480 and pid < 490 then
		WAR.Person[id]["��Ч����2"] = "�׾������"
		ng = ng + 1200
		WAR.JGZ_DMZ = 1
    end
    
    --���ƣ����գ�׷������
    if match_ID(pid, 37) and wugong == 94 and level == 11 then
		WAR.Person[id]["��Ч����3"] = "���չ�����Ӱ��ȭ"
		ng = ng + 800
    end
	
    --С�ѣ�ʥ��׷������
    if match_ID(pid, 66) and wugong == 93 and level == 11 then
		local zs = {"��ɳ���罵�Ļ�","����δ�����ӻ�","����嫹�ɳ�ٺ�","ҵ�����������"}
		WAR.Person[id]["��Ч����3"] = zs[math.random(4)]
		ng = ng + 800
    end
	-- ���ǽ���
	if WAR.QZ_QXJF == 1 and match_ID(pid,68)then
	ng = ng + 800
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "�����ǽ���"
		else
			WAR.Person[id]["��Ч����3"] = "���ǽ���"
		end
		--50%���ʴ����ٴ�׷��ɱ��
		if JLSD(20, 70, pid) then
		local zs = {"����","���","����","��Ȩ","���","����","����"}
			ng = ng + 800
			if WAR.Person[id]["��Ч����1"] ~= nil then
				WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "�����ǽ���".."��"..zs[math.random(7)]
			else
				WAR.Person[id]["��Ч����1"] = "���ǽ���-".."��"..zs[math.random(7)]
			end
		end
    end
    --Ī��׷������
    if match_ID(pid, 20) and (JY.Person[0]["�������"] > 0 or isteam(pid) == false) then
		local zs = {"�׺�һ��Ц","����������","�׷����ϳ�","�����ǽ� "}
		WAR.Person[id]["��Ч����3"] = zs[math.random(4)]
		ng = ng + 800
    end	
     --��ʮ������׷������
    if match_ID(pid, 497) then
		local zs = {"������","��ʨ��","������","��ƽ��","Բ����","ţ����",}
		WAR.Person[id]["��Ч����3"] = zs[math.random(4)]
		ng = ng + 800
    end 
	
    --��ҽ�����Ϊ������Ϻ��ҵ����� 60%��������
    if wugong == 44 and level == 11 and JLSD(0,60,pid) then
		for i = 1, JY.Base["�书����"] do
			if JY.Person[pid]["�书" .. i] == 67 and JY.Person[pid]["�书�ȼ�" .. i] == 999 then
				Set_Eff_Text(id, "��Ч����1", "�����罣 �����һ")
				WAR.Person[id]["��Ч����"] = 6
				WAR.DJGZ = 1
				ng = ng + 1000
				break
			end
		end
    end
    
    --���ҵ�����Ϊ���������ҽ����� 60%�������桢
	--��һ�����Ѳ���Ҫ
    if wugong == 67 and level == 11 and JLSD(0,60,pid) then
		if match_ID_awakened(pid,633,1) then
			Set_Eff_Text(id, "��Ч����1", "�����罣 �����һ")
			WAR.Person[id]["��Ч����"] = 6
			WAR.DJGZ = 1
			ng = ng + 1000
			if WAR.ACT == 1 then
				local  HDJYZS = {"������������������������","�����������������ݷ�����","����������������ɳŸ�Ӳ�","�����������������ΰݱ���","�����������������˷��ص�ʽ"};
				local display = HDJYZS[math.random(5)];
				WAR.Person[id]["��Ч����"] = 119
				WAR.PD["��������"][pid] = 1
				WAR.ATNum = 2
				TXWZXS(display, M_DeepSkyBlue)
			end
		else
			for i = 1, JY.Base["�书����"] do
				if JY.Person[pid]["�书" .. i] == 44 and JY.Person[pid]["�书�ȼ�" .. i] == 999 or match_ID_awakened(pid,633,1)  then
					Set_Eff_Text(id, "��Ч����1", "�����罣 �����һ")
					WAR.Person[id]["��Ч����"] = 6
					WAR.DJGZ = 1
					ng = ng + 1000
					break
				end
			end
		end
    end
	
	--����������ϣ�����+1000
	if (wugong == 3 or wugong == 120 or wugong == 5 or wugong == 21 or wugong == 118) and ZiqiTL(pid) then
		ng = ng + 800
		Set_Eff_Text(id, "��Ч����1", "��������")
	end
	--������ϼ��50%���ʽ�ϵ����+1000
    if PersonKF(pid,89)  and kfkind == 3 then
       local jl = 30
	   if Curr_NG(pid,89) then
		jl = 50
		end
		if JLSD(0,jl,pid) or WAR.LQZ[pid] == 100 then
			ng = ng + 800
			Set_Eff_Text(id, "��Ч����2", "��ϼ����")
		end
	end
	--��������
    if PersonKF(pid,175)  and kfkind == 3 and WAR.ZWYJF == 0 then
       local jl = 30
	   if Curr_NG(pid,175) then
		jl = 50
		end
		if JLSD(0,jl,pid) or WAR.LQZ[pid] == 100 then
			ng = ng + 800
			Set_Eff_Text(id, "��Ч����2", "��������")
		end
	end
		
	--�ƾ����£�����2000������
	if WAR.PJTX == 1  then
		ng = ng + 1000
	end 
    --�廨��	
    if WAR.PD["�廨��"][pid] ~= nil and WAR.PD["�廨��"][pid] > 0 then	
		ng = ng + 800
	end
	--��������������1200������
	if WAR.JGSL == 1 then
		ng = ng + 800
	end	
	
	--�żһԵ������ָ
	if JY.Person[pid]["����"] == 304 then
		local cd = 40
		if JY.Thing[304]["װ���ȼ�"] >=5 then
			cd = 20
		elseif JY.Thing[304]["װ���ȼ�"] >=3 then
			cd = 30
		end
		WAR.YSJZ = cd
	end
	
	--װ��ԧ�쵶��5����ʼ������׷��500����
	if JY.Person[pid]["����"] == 217 and wugong == 62 and JY.Thing[217]["װ���ȼ�"] >=5 then
		ng = ng + 500
	end
	if JY.Person[pid]["����"] == 218 and wugong == 62 and JY.Thing[218]["װ���ȼ�"] >=5 then
		ng = ng + 500
	end
	
	--����������ϣ�50%���ʶ�������+1000����ŭ�ط�����ѧ�����������ط���
	if wugong >= 30 and wugong <= 34 and WuyueJF(pid) and (WAR.LQZ[pid] == 100 or PersonKF(pid, 175) or JLSD(20, 70, pid))then
		local qg = 500
		--ѧ�����������������ټ�500�����Ӿ�������
		if PersonKF(pid, 175) then
			qg = qg + 500
			WAR.ZWYJF = 1
		end
		ng = ng + qg
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = "����������"..WAR.Person[id]["��Ч����3"]
		else
			WAR.Person[id]["��Ч����3"] = "��������"
		end
	end
    -- ��ħ���� 
	if WAR.JMZL == 2 then
	   ng = ng +800
	   end
    -- ��ħ���� 
	if WAR.DSP_LM1 == 1 then
	   ng = ng +800
	   end	
	--�����黭��������ʽ������ɱ��
	if wugong == 72 and QinqiSH(pid) then
		ng = ng + 800
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "�����һ��"
		else
			WAR.Person[id]["��Ч����3"] = "���һ��"
		end
		--50%���ʴ����ٴ�׷��ɱ��
		if JLSD(20, 70, pid) then
			ng = ng + 500
			if WAR.Person[id]["��Ч����1"] ~= nil then
				WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "�������岼"
			else
				WAR.Person[id]["��Ч����1"] = "�����岼"
			end
		end
    end

	--���鵶����30%���ʣ�����ɱ�����ض���Ѫ
	--���������ж�
	if wugong == 153 and (JLSD(30, 60, pid) or (pid == 0 and JY.Base["��׼"] == 4 and JLSD(30,60,pid))) then
		WAR.CMDF = 1
		ng = ng + 1000
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "���߶�����"
		else
			WAR.Person[id]["��Ч����1"] = "�߶�����"
		end
	end
    -- ��צ�� ����ɱ��
	if wugong == 20 then
		ng =ng +800
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "����������"
		else
			WAR.Person[id]["��Ч����1"] = "��������"
		end
	end
	--����֮��
	if PersonKF(pid, 103) and JLSD(20,80,pid) then
		ng = ng + 1000
		if Curr_NG(pid, 103) then
			local nq = WAR.LQZ[pid] or 0
			local lvl = math.modf(nq/10)
			ng = ng + 100 * lvl
			if nq == 100 then
				WAR.LXZL10 = 1
			end
		end
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "+" .."����֮��"
		else
			WAR.Person[id]["��Ч����1"] = "����֮��"
		end
	end

 	
	--��������������׷������1000��
	if match_ID(pid, 129) and WAR.BDQS > 0 then
		ng = ng + 1000
		local BDQS = {"����", "���", "����", "��Ȩ", "���", "����", "ҡ��"}
		if WAR.Person[id]["��Ч����2"] ~= nil then
			WAR.Person[id]["��Ч����2"] = WAR.Person[id]["��Ч����2"] .. "+" .."����������"..BDQS[WAR.BDQS]
		else
			WAR.Person[id]["��Ч����2"] = "����������"..BDQS[WAR.BDQS]
		end
	end

	
	--����ȭ�������������17��
	--лѷ�س�
	if wugong == 23 and (match_ID(pid, 13) or WAR.LQZ[pid] == 100 or JLSD(30, 60, pid))then
		WAR.YZQS = 1
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "+һ������"
		else
			WAR.Person[id]["��Ч����1"] = "һ������"
		end
	end
 	--���� �������� ׷��10-15������
	if match_ID(pid,9994) then
	    WAR.XC_WLCZ= 1 
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"].."+��������"
		else
			WAR.Person[id]["��Ч����1"] = "��������"
		end
	end	
	
    --���� ʹ������������͵�ԣ�������ֿտ�Ҳ��
	--½���������  ˾��ժ��
    if (match_ID(pid, 90) and wugong == 113) 
	or (match_ID(pid, 131) and wugong == 116) 
	or match_ID(pid, 497) or match_ID(pid, 579)then
		WAR.TD = -2
		--�����壺��սս������͵����
		if WAR.ZDDH == 226 or WAR.ZDDH == 79 or WAR.ZDDH == 354 then
			WAR.TD = -1;
		end
    end
	
	--��Զ��ʹ��̫��ȭ��̫�����������Զ��������״̬
	if match_ID(pid, 171) and (wugong == 16 or wugong == 46) then
		WAR.WDRX = 1
	end

	
	if wugong == 21 and level == 11 and xmjy == 1 then
		Set_Eff_Text(id, "��Ч����1", "��ڤ����")
		ng = ng + 1000
		WAR.WS = 1
		TXWZXS("����ڤ���ơ��������塻", M_DeepSkyBlue)
		for i = 1, 5 do
			for j = 1, 5 do
				SetWarMap(x + i - 1, y + j - 1, 4, 1)
				SetWarMap(x - i + 1, y + j - 1, 4, 1)
				SetWarMap(x + i - 1, y - j + 1, 4, 1)
				SetWarMap(x - i + 1, y - j + 1, 4, 1)
			end
		end
	end		
	--��Ȼ����
	if WAR.ARJY == 1 then 
		ng = ng + 1200
		WAR.WS = 1
		for i = 1, 5 do
			for j = 1, 5 do
				SetWarMap(x + i - 1, y + j - 1, 4, 1)
				SetWarMap(x - i + 1, y + j - 1, 4, 1)
				SetWarMap(x + i - 1, y - j + 1, 4, 1)
				SetWarMap(x - i + 1, y - j + 1, 4, 1)
				
			end
		end
	end
	--[[��������
	if WAR.YLTW == 1 then 
		ng = ng + 1000
		WAR.WS = 1
		for i = 1, 6 do
			for j = 1, 6 do
				SetWarMap(x + i - 1, y + j - 1, 4, 1)
				SetWarMap(x - i + 1, y + j - 1, 4, 1)
				SetWarMap(x + i - 1, y - j + 1, 4, 1)
				SetWarMap(x - i + 1, y - j + 1, 4, 1)
				
			end
		end
	end	
	]]
	--��������
	if WAR.PD["��������"][pid] ~= nil and WAR.PD["��������"][pid] < 3 then 
		ng = ng + 1000
		WAR.WS = 1	
		for i = 1, 5 do
			for j = 1, 5 do
				SetWarMap(x + i - 1, y + j - 1, 4, 1)
				SetWarMap(x - i + 1, y + j - 1, 4, 1)
				SetWarMap(x + i - 1, y - j + 1, 4, 1)
				SetWarMap(x - i + 1, y - j + 1, 4, 1)
			end				
		end		
	end	
	
	--��������
	if WAR.JYSZ == 1  then 
		ng = ng + 1000
		WAR.WS = 1
		for i = 1, 5 do
			for j = 1, 5 do
				SetWarMap(x + i - 1, y + j - 1, 4, 1)
				SetWarMap(x - i + 1, y + j - 1, 4, 1)
				SetWarMap(x + i - 1, y - j + 1, 4, 1)
				SetWarMap(x - i + 1, y - j + 1, 4, 1)
			end
		end	
	end
	
   	--�̺���ʽ5 �����
	if WAR.BHJTZ2== 1  then 
		ng = ng + 1000
		WAR.WS = 1
		for i = 1, 5 do
			for j = 1, 5 do
				SetWarMap(x + i - 1, y + j - 1, 4, 1)
				SetWarMap(x - i + 1, y + j - 1, 4, 1)
				SetWarMap(x + i - 1, y - j + 1, 4, 1)
				SetWarMap(x - i + 1, y - j + 1, 4, 1)
			end
		end	
	end	
	if WAR.PD["ǰ"][pid] == 1 then
		WAR.WS = 1
		for i = 1, 5 do
			for j = 1, 5 do
				SetWarMap(x + i - 1, y + j - 1, 4, 1)
				SetWarMap(x - i + 1, y + j - 1, 4, 1)
				SetWarMap(x + i - 1, y - j + 1, 4, 1)
				SetWarMap(x - i + 1, y - j + 1, 4, 1)
			end
		end	
	end	
	--�������嶾���2-5������
	if match_ID(pid, 83) and  wugong == 3 then
		WAR.HTS = math.random(2, 5)
    end
	--���������2-5������
	if match_ID(pid, 612) and  wugong == 206 then
		WAR.ZWX = math.random(2, 5)
    end	
		--׿�������3������
	if match_ID(pid, 613) and  wugong == 206 then
		WAR.ZWX = 3
    end	
		--׿�������3������
	if match_ID(pid, 613) and  wugong == 205 then
		WAR.ZWX = 2
    end	

    --���� ������
    if match_ID(pid, 92) then
		WAR.WS = 1
    end
	
    --ŷ���� ������
    if match_ID(pid, 60) then
		WAR.WS = 1
    end
    
    --�������� ������
    if match_ID(pid, 27) then
		WAR.WS = 1
    end
	
	--ɨ�� ������
    if match_ID(pid, 114) then
		WAR.WS = 1
    end
	
	--���࣬ԽŮ������
	if match_ID(pid, 604) and wugong == 156 then
		WAR.WS = 1
	end
	
	--���ɽ�ħս������������
	if match_ID(pid, 592) and WAR.ZDDH == 291 then
		WAR.WS = 1
	end
    
    --�Ƿ壬���������߹���ʹ�ý���ʮ���� ������
    if (match_ID(pid, 50) or match_ID(pid, 55) or match_ID(pid, 69)) and wugong == 26 then
		WAR.WS = 1
    end
	
    --���л�ʹ�÷��޵��� ������
    if match_ID(pid, 77) and wugong == 62 then
		WAR.WS = 1
    end
    
    --����� ����֮��ʹ�ö��¾Ž� ������
    if match_ID_awakened(pid, 35, 2) and wugong == 47 then
		WAR.WS = 1
    end
	
	--��Ů���Ľ� ������
	if wugong == 139 then
		WAR.WS = 1
	end
    
    --���ַ��� ����+2500
    if match_ID(pid, 62) then
		ng = ng + 2000
    end
    
    
    --�����ɣ�ʹ����ƽǹ��������+1500
    if match_ID(pid, 52) and wugong == 70 then
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "+" .."��ƽ��ǹ"
		else
			WAR.Person[id]["��Ч����3"] = "��ƽ��ǹ"
		end
		ng = ng + 1000
    end
   
	
    --������ ����Ȼ��������500��ʼ
    if match_ID(pid, 5) and JLSD(0,70,pid) then
		WAR.ZSF = 1
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "+" .."����Ȼ"
		else
			WAR.Person[id]["��Ч����1"] ="����Ȼ"
		end
    end



	    --½����������
    if match_ID(pid, 497) and JLSD(0,70,pid) and  WAR.JGFX[pid]~= nil then
		WAR.JGSL = 1
		if WAR.Person[id]["��Ч����0"] ~= nil then
			WAR.Person[id]["��Ч����0"] = WAR.Person[id]["��Ч����0"] .. "+" .."��������"
		else
			WAR.Person[id]["��Ч����1"] ="��������"
		end
    end
	
	
    --��� ʫ�ƻ��У�������200��ʼ
    if match_ID(pid, 636) and JLSD(0,70,pid) then
		WAR.QLBLX = 1
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "+" .."ʫ�ƻ���"
		else
			WAR.Person[id]["��Ч����1"] ="ʫ�ƻ���"
		end
    end

    --����  ����ӻ���������200��ʼ
    if match_ID(pid, 49) and JLSD(0,60,pid) then
		WAR.XZZ = 1
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .."+".."����ӻ�"
		else
			WAR.Person[id]["��Ч����1"] = "����ӻ�"
		end
    end
	
	--�ⲻƽ���콣��ʹ�ý�������
    if match_ID(pid, 142) and kfkind == 3 then
		WAR.KFKJ = 1
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .."+".."���콣"
		else
			WAR.Person[id]["��Ч����3"] = "���콣"
		end
    end
	
	--�Ž��洫������ʽ�����������+150
	if WAR.JJZC == 4  then
		WAR.JJDJ = 1
	end
    
    --�������� ����� ������Ѩ�֣�����+1000
	--����س���Ѩ��
    if match_ID(pid, 27) or match_ID_awakened(pid, 189, 1) or (PersonKF(pid, 105) and JLSD(0,30,pid)) then
		ng = ng + 1400
		WAR.BFX = 1
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "+" .."������Ѩ��"
		else
			WAR.Person[id]["��Ч����3"] = "������Ѩ��"
		end
    end
    
	--̫�齣�� �򽣹���
    if Curr_NG(pid,152 ) and JLSD(20,70,pid) and kfkind == 3 then
		ng = ng + 1100
		elseif PersonKF(pid,152) and JLSD(20,45,pid) then
		 ng = ng + 600
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "+" .."�򽣹���"
		else
			WAR.Person[id]["��Ч����1"] = "�򽣹���"
		end
    end	
    
    if match_ID(pid,510) then
        if JLSD(0,30,pid) then 
            WAR.PD['��Ϧ��϶'][pid] = 1
            if WAR.Person[id]["��Ч����1"] ~= nil then
                WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .."+".."��Ϧ��϶"
            else
                WAR.Person[id]["��Ч����1"] = "��Ϧ��϶"
            end
            WAR.Person[id]["��Ч����"] = 61
        end
        if JLSD(0,30,pid) then 
            WAR.PD['����ͨ��'][pid] = 1
            if WAR.Person[id]["��Ч����1"] ~= nil then
                WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .."+".."����ͨ��"
            else
                WAR.Person[id]["��Ч����1"] = "����ͨ��"
            end
            WAR.Person[id]["��Ч����"] = 61
        end
        
    end

	
	--�޺���ħ����������Ч
	--ͬʱѧ���׽���+�޺���ħ���������׽��񹦱س����޺���ħ����Ч
	--ʯ����س��޺���ħ
	if Curr_NG(pid, 96) or (Curr_NG(pid, 108) and PersonKF(pid, 96)) or (match_ID(pid,38) and PersonKF(pid,96)) then
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "+�޺���ħ";
		else
			WAR.Person[id]["��Ч����1"] = "�޺���ħ"
		end
	end
       --̫��ȭ����������
	   --������ʹ���κ��书
    if Curr_NG(pid,171)  and (wugong == 16 or wugong == 46 ) then
		if WAR.PD["̫������"][pid] == nil then
			WAR.PD["̫������"][pid] = 0
		elseif 0 < WAR.PD["̫������"][pid] then
			if WAR.Person[id]["��Ч����3"] ~= nil then
				WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"].."����������"
			else
				WAR.Person[id]["��Ч����3"] = "��������"
			end
			ng = ng + WAR.PD["̫������"][pid]
		end
    end 
   
	-- ���� ѩ����
    if match_ID_awakened(pid,582,1) and (JLSD(20,50+JY.Base["��������"],pid) or WAR.LQZ[pid] == 100) and WAR.DZXY ~= 1 then
	   WAR.BXXHSJ =1
	end
    
	--���� ѩɽ����
    if wugong == 35 and match_ID_awakened(pid,582,1) and WAR.DZXY ~= 1then
	   ng = ng + 600
	end	
    
	if WAR.BXXHSJ == 1 then
		local exng = 0
		local CN_num = {"һʽ", "��ʽ", "��ʽ", "��ʽ", "��ʽ", "��ʽ", "��ʽ", "��ʽ", "��ʽ", "ʮʽ", "ʮһʽ","ʮ��ʽ", "ʮ��ʽ","ʮ��ʽ","ʮ��ʽ"}
		for i = 1, JY.Base["�书����"] do
			if JY.Person[pid]["�书"..i] ~= 35 and JY.Person[pid]["�书�ȼ�"..i] == 999 then
				ng = ng + 100
				exng = exng + 1
			end
		end
		if exng > 0 then
			if WAR.Person[id]["��Ч����0"] ~= nil then
				WAR.Person[id]["��Ч����0"] = WAR.Person[id]["��Ч����0"].."+ѩ���񽣡�"..CN_num[exng]
			else
				WAR.Person[id]["��Ч����0"] = "ѩ���񽣡�"..CN_num[exng]
			end
		end
	end
 
	--��ɽ��÷�֣�ɱ�����
	if wugong == 14 and WAR.DZXY ~= 1 then
		local exng = 0
		local CN_num = {"һ", "��", "��", "��", "��", "��", "��", "��", "��", "ʮ", "ʮһ","ʮ��","ʮ��","ʮ��","ʮ��"}
		for i = 1, JY.Base["�书����"] do
			if JY.Person[pid]["�书"..i] ~= 14 and JY.Person[pid]["�书�ȼ�"..i] == 999 then
				ng = ng + 100
				exng = exng + 1
			end
		end
		if exng > 0 then
			if WAR.Person[id]["��Ч����3"] ~= nil then
				WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"].."+��ɽ��÷"..CN_num[exng]
			else
				WAR.Person[id]["��Ч����3"] = "��ɽ��÷"..CN_num[exng]
			end
		end
	end
  		--�����˺�
	if match_ID(pid,586) and JY.Base["��������"] > 0  and WAR.DZXY ~= 1 then
	    local zs = {" ʮ��������","����ɱ����","������","һ�ӽ�˫��"}
        local exng = JY.Base["��������"]*1
	    local CN_num = {"һ", "��", "��", "��", "��", "��", "��", "��", "��", "ʮ", "ʮһ","ʮ��","ʮ��","ʮ��","ʮ��"}	
	    ng = ng + 1000
	    if WAR.Person[id]["��Ч����3"] ~= nil then
	        WAR.Person[id]["��Ч����3"] = "���塤"..CN_num[exng].."�ơ�"..zs[math.random(4)].."+"..WAR.Person[id]["��Ч����3"]
	    else
	        WAR.Person[id]["��Ч����3"] ="���塤"..CN_num[exng].."�ơ�"..zs[math.random(4)]
	    end	
    end	
    --ʥ����
    if PersonKF(pid,93) and JY.Person[pid]["�������"] >= 200 then
	   Set_Eff_Text(id, "��Ч����3", SHSGZS[math.random(6)])
	   ng = ng + 1200
	   WAR.DHBUFF = 1
	end
	
    --����ʹ����ɽ�����ƻ���÷�֣�����������ɱ����+1700
    if (wugong == 8 or wugong == 14) and match_ID(pid, 49) and PersonKF(pid, 101) and (JLSD(20, 80, pid) or WAR.NGJL == 98)  and WAR.DZXY ~= 1 then
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"].."+���չ���ѧ��������"
		else
			WAR.Person[id]["��Ч����3"] = "���չ���ѧ��������"
		end
		ng = ng + 1000
		WAR.TZ_XZ = 1
    end

    --������ʹ����ϵ������60%�Ļ��ʴ����ɱ����
    if match_ID(pid, 590) and kfkind == 5 and JLSD(0, 50 + JY.Base["��������"]*2 + math.modf(JY.Person[pid]["ʵս"]/25), pid) then
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"].."+".."�������塤��������"
		else
			WAR.Person[id]["��Ч����3"] = "�������塤��������"
		end	
    	ng = ng + 800
		--����14���飬����Ӿ�������
		if JY.Base["��������"] >= 14 then
			WAR.LWX = 1
		end
    end
	--����Ů �㺮���
		--��ŭ�ش���
	if match_ID(pid, 640) and JY.Person[0]["�������"] > 0  and (JLSD(0, 10 + JY.Base["��������"]*1,  pid) or WAR.LQZ[pid] == 100) and WAR.DZXY ~= 1 then
		ng = ng + 1000
		WAR.GHQH = 1
		if WAR.Person[id]["��Ч����0"] ~= nil then
			WAR.Person[id]["��Ч����0"] = WAR.Person[id]["��Ч����3"].."��".."�㺮���"
		else
			WAR.Person[id]["��Ч����0"] = "�㺮���"
		end
	
	end
    -- ˫���ϱ�.����
	if ShuangJianHB(pid) and (wugong == 39 or wugong == 42 or wugong == 139)  then
	WAR.SJHB_G = 1
	end
	--����г֮��
	--������ɽ��������г֮��
		if match_ID(pid, 635)  and WAR.LQZ[pid] == 100 and (JY.Person[pid]["�������"] > 0 or isteam(pid) == false) then
		   ng = ng + 1000
			WAR.LXXZD = 1
			if WAR.Person[id]["��Ч����0"] ~= nil then
				WAR.Person[id]["��Ч����0"] = WAR.Person[id]["��Ч����0"].."��".."г֮��������г�"
			else
				WAR.Person[id]["��Ч����0"] = "г֮��������г�"
				WAR.Person[id]["��Ч����"] = 126
			end	
         end
			
	--��������������
	local YufaJC = 0
	for i = 0, WAR.PersonNum - 1 do
		local yfid = WAR.Person[i]["������"]
		if WAR.Person[i]["����"] == false and WAR.Person[i]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and match_ID(yfid, 76) and Xishu_sum(yfid) >= 500 then
			YufaJC = 1
			break
		end
	end
	
	--�书��ʽ��ɱ����
	if YufaJC == 0 then
		--�������ŭ�Ž���������ʤ����
		if match_ID(pid, 140) and wugong == 47 and WAR.LQZ[pid] == 100 then
			if WAR.Person[id]["��Ч����3"] ~= nil then
				WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"].."��".."����ʤ����"
			else
				WAR.Person[id]["��Ч����3"] = "����ʤ����"
			end
			ng = ng + 2000
			WAR.FQY = 1

		--����û����ʽ
		elseif CC.KFMove[wugong] ~= nil then
			--npc�س��У�С���๦�����س���ʽ����ŭ�س���ʽ����а�س��У�̫���س���
			if inteam(pid) == false or myrandom(level, pid) or WAR.NGJL == 98 or WAR.LQZ[pid] == 100 or ((wugong == 48 or wugong == 102 or wugong == 106) and level == 11 and WAR.DZXY == 0)  or (wugong == 151  and level == 11 and PersonKF(pid,152)) then
				local num
				if wugong == 48 and level == 11 and inteam(pid) and WAR.DZXY ~= 1 and WAR.AutoFight == 0 then		--��а��ʽ�̶�
					num = WAR.BXZS
				--elseif  inteam(pid) and WAR.DZXY ~= 1 and WAR.AutoFight == 0 then		--�̺���ʽ�̶�
				--	num = WAR.LXBHZS	
				elseif	wugong == 106 and inteam(pid) and level == 11 and WAR.DZXY ~= 1 and WAR.AutoFight == 0  then		--������ʽ�̶�
					num = WAR.JYZS					
				elseif wugong == 102 and level == 11 and inteam(pid) and match_ID_awakened(pid, 38, 1)  and WAR.DZXY ~= 1 and WAR.AutoFight == 0 then	--̫����ʽ�̶�
					num = WAR.TXZS								
				else
					local choice = math.random(#CC.KFMove[wugong])											--������������ȡһ��
					num = choice
					if wugong == 102 and WAR.TXZS == 0 then
						WAR.TXZS = choice
					end
				end
				if WAR.Person[id]["��Ч����3"] ~= nil then
					WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"].."��"..CC.KFMove[wugong][num][1]
				else
					WAR.Person[id]["��Ч����3"] =CC.KFMove[wugong][num][1]
				end
				ng = ng + CC.KFMove[wugong][num][2]
			end
		end
	end
	
	--�����ᣬ50%������������
    if match_ID(pid, 5) and WAR.Person[id]["��Ч����3"] ~= nil and JLSD(30, 80, pid) then
		WAR.Person[id]["��Ч����3"] = "����Ϊ��" .. "��" .. WAR.Person[id]["��Ч����3"]
		ng = ng + get_skill_power(pid, wugong, 11)
    end
	
	--��������ȫ�潣����60%������������777����
	if wugong == 39 and match_ID(pid, 129) and JLSD(20, 80, pid) then
		ng = ng + 777
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = "����������"..WAR.Person[id]["��Ч����3"]
		else
			WAR.Person[id]["��Ч����3"] = "��������"
		end
	end
	-- �������� ��
	if WAR.PD["��"][pid]~= nil and WAR.PD["��"][pid] ==1 then
		ng = ng + 800
    end
	--��ָ��ͨ������һ�����������+1000
	if wugong == 18 and TaohuaJJ(pid) then
		ng = ng + 1000
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "����Ӱ��ʯ"
		else
			WAR.Person[id]["��Ч����3"] = "��Ӱ��ʯ"
		end
	end
    --�򹷰��� ����
    if wugong == 80 and level == 11  then
	   local jl = 50
	   if JY.Person[pid]["����"] == 218 and JY.Thing[218]["װ���ȼ�"] >=5 then
	      jl = jl + 10
	   end
	   if pid == 0 and JY.Base["��׼"] == 5 then
	      jl = jl + 5
	   end
	   if Curr_NG(204,pid) then
	      jl = jl + 10
	   end
	   if WAR.LQZ[pid] == 100 or jl > Rnd(100) then	
		    if WAR.Person[id]["��Ч����3"] ~= nil then
			   WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "���򹷰�����ѧ--�����޹�"
		    else
			   WAR.Person[id]["��Ч����3"] = "�򹷰�����ѧ--�����޹�"
		       WAR.Person[id]["��Ч����"] = 89
            end
            ng = ng+1000
		    WAR.WS = 1
		    for i = 1, 6 do
			     for j = 1, 6 do
			         SetWarMap(x + i - 1, y + j - 1, 4, 1)
			         SetWarMap(x - i + 1, y + j - 1, 4, 1)
			         SetWarMap(x + i - 1, y - j + 1, 4, 1)
			         SetWarMap(x - i + 1, y - j + 1, 4, 1)
			     end
		    end
       end 
    end

    --�����壺���ҵ���������
    --��ϵ����40%�����50%����ŭ�س�
	--��һ��70%
    if wugong == 67 and level == 11 and WAR.PD["��������"][pid] == nil and ((((pid == 0 and JY.Base["��׼"] == 4)
	and (WAR.LQZ[pid] == 100 or JLSD(30,70,pid))))or (match_ID(pid, 633) and (WAR.LQZ[pid] == 100 or JLSD(20,80,pid)))
	or (match_ID(pid, 1) and (WAR.LQZ[pid] == 100 or JLSD(20,70,pid)))) then
		local HDJY = {"���⡤����ʽ","���⡤�ݷ�����","���⡤���ֲص�","���⡤ɳŸ�Ӳ�","���⡤�ΰݱ���","���⡤�������ȵ�",
		"���⡤����ժ�ĵ�","���⡤����������","���⡤�˷��ص�ʽ"};
		WAR.Person[id]["��Ч����3"] = HDJY[math.random(9)];
		WAR.Person[id]["��Ч����"] = 6
		ng = ng + 1000
		WAR.WS = 1
		WAR.HDJY =1
		for i = 1, 5 do
			for j = 1, 5 do
				SetWarMap(x + i - 1, y + j - 1, 4, 1)
				SetWarMap(x - i + 1, y + j - 1, 4, 1)
				SetWarMap(x + i - 1, y - j + 1, 4, 1)
				SetWarMap(x - i + 1, y - j + 1, 4, 1)
			end
		end
	end
				
    --�������񣬱������� ��������
	--����ʽʱ�ش�������ŭʱ�س�
    if wugong == 45 and level == 11 and (match_ID(pid, 58) or match_ID(pid, 628) or (pid == 0 and JY.Base["��׼"] == 3) ) 
	   and (WAR.LQZ[pid] == 100 or WAR.Person[id]["��Ч����3"] == nil) then
		--WAR.Person[id]["��Ч����3"] = "�ؽ��洫������ɽӿ�����"
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "+�ؽ��洫������ɽӿ�����"
		else
			WAR.Person[id]["��Ч����3"] = "�ؽ��洫������ɽӿ�����"
		end
		WAR.Person[id]["��Ч����"] = 84
		ng = ng + 1200
		WAR.WS = 1
		for i = 1, 5 do
			for j = 1, 5 do
				SetWarMap(x + i - 1, y + j - 1, 4, 1)
				SetWarMap(x - i + 1, y + j - 1, 4, 1)
				SetWarMap(x + i - 1, y - j + 1, 4, 1)
				SetWarMap(x - i + 1, y - j + 1, 4, 1)
			end
		end
    end
    
    
    --������ ��Ŀ
    if wugong == 48 and PersonKF(pid, 105) then
		WAR.KHBX = 2
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "����а��Ŀ"
		else
			WAR.Person[id]["��Ч����3"] = "��а��Ŀ"
		end
		--WAR.Person[id]["��Ч����1"] = "���а������������Ŀ";
		WAR.Person[id]["��Ч����"] = 6
    end
	--���ϳٻ�
	--����;��Ѿ��� 
	if Curr_NG(pid, 105) and JLSD(20,70,pid) then
		WAR.KHLH = 1
		WAR.WS=1
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "����������"
		else
			WAR.Person[id]["��Ч����1"] = "��������"
		end
		--WAR.Person[id]["��Ч����1"] = "������������";
		WAR.Person[id]["��Ч����"] = 6	
	end	
        
	--�������߱ش�Ŀ
	if match_ID(pid,27) or (PersonKF(pid,105) and JLSD(10,20,pid)) or (Curr_NG(pid,105) and JLSD(0,30,pid)) then
		WAR.KHBX = 2
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "��������Ŀ"
		else
			WAR.Person[id]["��Ч����3"] = "������Ŀ"
		end
		--WAR.Person[id]["��Ч����1"] = "������Ŀ";
		WAR.Person[id]["��Ч����"] = 6
	end
  
    --äĿ״̬��20%���ʹ�����Ч
    if WAR.KHCM[pid] == 2 and JLSD(0,50,pid) then
		WAR.MMGJ = 1
		WAR.Person[id]["��Ч����"] = 89
		WAR.Person[id]["��Ч����2"] = "äĿ״̬��������Ч"
    end
    
    -- ��̫�� WAR.PD["̫������"][pid] > 600
    if Curr_NG(pid,171) and (wugong == 16 or  wugong == 46) and WAR.LQZ[pid] == 100 and ((WAR.PD["̫������"][pid]~= nil and 
        WAR.PD["̫������"][pid]>=600) or (WAR.TJZX[pid] ~= nil and WAR.TJZX[pid] >= 8)) then
		--WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", -math.modf(JY.Person[pid]["����"]/10));
		--WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", -math.modf(JY.Person[pid]["����"]/10))
	    local qg = JY.Person[pid]["����"]/JY.Person[pid]["�������ֵ"]*1200
	    WAR.WDKTJ = 1
	    ng = ng+ qg
		local size = 60
		local x = CC.ScreenW/2;
        local y = CC.ScreenH/2;
        local offx = (#"��̫һ����.��̫����")*size/4
        local offy = size/2
		for k = 1,10 do
			Cat('ʵʱ��Ч����')
			Cls()
			lib.Background(0,y-50,CC.ScreenW,y+50,98)
			DrawString(x-offx,y-offy,"��̫һ����.��̫����",C_GOLD,size);  
			ShowScreen();
			lib.Delay(CC.BattleDelay)
		end
	end



	--���������Ѻ�
	if (match_ID_awakened(pid, 636,1) or (not inteam(pid) and match_ID(pid,636)))  and kfkind == 3 and WAR.LQZ[pid] == 100 then
		WAR.QLJG  = 1
		ng = ng + 1500
		local size = 60
		local x = CC.ScreenW/2;
        local y = CC.ScreenH/2;
        local offx = (#"���������������衿")*size/4
        local offy = size/2
		for k = 1,10 do
			Cat('ʵʱ��Ч����')
			Cls()
			lib.Background(0,y-50,CC.ScreenW,y+50,98)
			DrawString(x-offx,y-offy,"���������������衿",C_GOLD,size);  
			ShowScreen();
			lib.Delay(CC.BattleDelay)
		end
	end
	--Ԭ��־���Ѻ���������30%��50%���ʳ����߰���
	if (match_ID_awakened(pid, 54, 1) and wugong == 40 and JY.Person[pid]["����"] <= (JY.Person[pid]["�������ֵ"]*0.3) and JLSD(20,70,pid)) or  (match_ID(pid,639) and (WAR.LQZ[pid] == 100 or JLSD(10,40,pid))) then
		WAR.JSAY = 1
		ng = ng + 1000
	
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.Person[i]["����"] == false then
				local offset1 = math.abs(WAR.Person[WAR.CurID]["����X"] - WAR.Person[i]["����X"])
				local offset2 = math.abs(WAR.Person[WAR.CurID]["����Y"] - WAR.Person[i]["����Y"])
				if offset1 <= 5 and offset2 <= 5 then
					SetWarMap(WAR.Person[i]["����X"], WAR.Person[i]["����Y"], 4, 1)
				end
			end
		end
	end
    
	--Ѫս�˷�
	if WAR.XZBFZT[pid] ~= nil and WAR.XZBFZT[pid] > 0 and WAR.DZXY ~= 1 and kfkind == 4 then			
	   WAR.XZBF =1 
	   WAR.WS =1
	   WAR.XZBFZT[pid] = WAR.XZBFZT[pid] - 1
	   if WAR.XZBFZT[pid] < 0 then
	      WAR.XZBFZT[pid] = 0
	   end
		  ng = ng + 800
		  local size = 60
		  local x = CC.ScreenW/2;
          local y = CC.ScreenH/2;
          local offx = (#"����������.Ѫս�˷���")*size/4
          local offy = size/2
		  for k = 1,10 do
			 Cat('ʵʱ��Ч����')
			 Cls()
			 lib.Background(0,y-50,CC.ScreenW,y+50,98)
			 DrawString(x-offx,y-offy,"����������.Ѫս�˷���",C_GOLD,size);  
			 ShowScreen();
			 lib.Delay(CC.BattleDelay)
		  end
		  for i = 0, WAR.PersonNum - 1 do
			 if WAR.Person[i]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.Person[i]["����"] == false then
				local offset1 = math.abs(WAR.Person[WAR.CurID]["����X"] - WAR.Person[i]["����X"])
				local offset2 = math.abs(WAR.Person[WAR.CurID]["����Y"] - WAR.Person[i]["����Y"])
				if offset1 <= 5 and offset2 <= 5 then
					SetWarMap(WAR.Person[i]["����X"], WAR.Person[i]["����Y"], 4, 1)
					
				end
			end			
		end
		WAR.XZBF = 0
	end	
  
	--���� ��������
	if match_ID_awakened(pid, 629,1) and WAR.LQZ[pid] == 100   and JY.Base["��ͨ"] > 0 and WAR.DZXY ~= 1  then	
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", -math.modf(JY.Person[pid]["����"]/10))
        WAR.AJFHNP =1 
        WAR.WS =1
		ng = ng + 800
		local size = 60
		local x = CC.ScreenW/2;
        local y = CC.ScreenH/2;
        local offx = (#"����������.˭��������")*size/4
        local offy = size/2
		for k = 1,10 do
			Cat('ʵʱ��Ч����')
			Cls()
			lib.Background(0,y-50,CC.ScreenW,y+50,98)
			DrawString(x-offx,y-offy,"����������.˭��������",C_GOLD,size);  
			ShowScreen();
			lib.Delay(CC.BattleDelay)
		end
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.Person[i]["����"] == false then
				local offset1 = math.abs(WAR.Person[WAR.CurID]["����X"] - WAR.Person[i]["����X"])
				local offset2 = math.abs(WAR.Person[WAR.CurID]["����Y"] - WAR.Person[i]["����Y"])
				if offset1 <= 5 and offset2 <= 5 then
					SetWarMap(WAR.Person[i]["����X"], WAR.Person[i]["����Y"], 4, 1)
				end
			end
		end
	end	
    
	--Ī��50%���ʳ��������ν�����
	if match_ID(pid, 20) and (WAR.LQZ[pid] == 100 or JLSD(35, 85, pid)) then
		--WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", -math.modf(JY.Person[pid]["����"]/10))
		WAR.QXWXJ = 1
		ng = ng + 800
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.Person[i]["����"] == false then
				local offset1 = math.abs(WAR.Person[WAR.CurID]["����X"] - WAR.Person[i]["����X"])
				local offset2 = math.abs(WAR.Person[WAR.CurID]["����Y"] - WAR.Person[i]["����Y"])
				if offset1 <= 4 and offset2 <= 4 then
					SetWarMap(WAR.Person[i]["����X"], WAR.Person[i]["����Y"], 4, 1)
				end
			end
		end
	end

	--������1 һ��������
	if match_ID(pid, 129) and (JY.Person[0]["�������"] > 0 or isteam(pid) == false) and WAR.LQZ[pid] == 100 then
		WAR.YQFSQ = 1
	end

	--�޾Ʋ�������ת���Ĳ㣬�����ǳ�������ȫ��
    if WAR.DZXYLV[pid] == 115 then
        CleanWarMap(4, 0)
        for i = 0, WAR.PersonNum - 1 do
            if WAR.Person[i]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.Person[i]["����"] == false then
                SetWarMap(WAR.Person[i]["����X"], WAR.Person[i]["����Y"], 4, 1)
            end
        end
	end

    local pz = math.modf(JY.Person[0]["����"] / 10)
    
    --���ǽ�����У�10�񹥻�
    if pid == 0 and JY.Base["��׼"] == 3 and 120 <= TrueYJ(pid) and 0 < JY.Person[pid]["�书9"] and kfkind == 3 and wugong ~= 43 and JLSD(25, 50 +JY.Person[pid]["��������"]*0.0625, pid) and JY.Person[pid]["�������"] > 0 then
		CleanWarMap(4, 0)
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.Person[i]["����"] == false then
				local offset1 = math.abs(WAR.Person[WAR.CurID]["����X"] - WAR.Person[i]["����X"])
				local offset2 = math.abs(WAR.Person[WAR.CurID]["����Y"] - WAR.Person[i]["����Y"])
				if offset1 <= 10 and offset2 <= 10then
					SetWarMap(WAR.Person[i]["����X"], WAR.Person[i]["����Y"], 4, 1)
				end
			end
		end
		WAR.Person[id]["��Ч����"] = 6
		if WAR.Person[id]["��Ч����3"] == nil then
			WAR.Person[id]["��Ч����3"] = ZJTF[3]
		else
			WAR.Person[id]["��Ч����3"] = ZJTF[3] .. "��" .. WAR.Person[id]["��Ч����3"]
		end
		ng = ng + 1000
		WAR.WS = 1
		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('ʵʱ��Ч����')
			Cls()
			NewDrawString(-1, -1, ZJTF[3] .. TFSSJ[3], C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
		WAR.JSYX = 1
    end

    --������ ��إ��  6��
    if match_ID(pid,584) and (JY.Base["��������"] > 8 or isteam(pid) == false) and 230 <= TrueYJ(pid) and WAR.LQZ[pid] == 100 and kfkind == 3 then
        CleanWarMap(4, 0)
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.Person[i]["����"] == false then
				local offset1 = math.abs(WAR.Person[WAR.CurID]["����X"] - WAR.Person[i]["����X"])
				local offset2 = math.abs(WAR.Person[WAR.CurID]["����Y"] - WAR.Person[i]["����Y"])
				if offset1 <= 7 and offset2 <= 7 then
					SetWarMap(WAR.Person[i]["����X"], WAR.Person[i]["����Y"], 4, 1)
					end
			end
		end
		ng = ng + 1000
		WAR.WS = 1
		
		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('ʵʱ��Ч����')
			Cls()
			NewDrawString(-1, -1, " ��ʥ����--" .. "ʥ�顤����إ����", C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end

		WAR.SL23 = 1
    end

      
    --����ȭϵ����
    if pid == 0 and JY.Base["��׼"] == 1 and 0 < JY.Person[pid]["�书9"] and 120 <= TrueQZ(pid) and JLSD(25, 50 +JY.Person[pid]["ȭ�ƹ���"]*0.1, pid) and kfkind == 1 and JY.Person[pid]["�������"] > 0 then
		WAR.Person[id]["��Ч����"] = 6
		if WAR.Person[id]["��Ч����3"] == nil then
			WAR.Person[id]["��Ч����3"] = ZJTF[1]
		else
			WAR.Person[id]["��Ч����3"] = ZJTF[1] .. "��" .. WAR.Person[id]["��Ч����3"]
		end
		ng = ng + 1000
		WAR.WS = 1

		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('ʵʱ��Ч����')
			Cls()
			NewDrawString(-1, -1, ZJTF[1] .. TFSSJ[1], C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
		WAR.LXZQ = 1
    end
	
    --����ָ������
    if pid == 0 and JY.Base["��׼"] == 2 and 0 < JY.Person[pid]["�书9"] and 120 <= TrueZF(pid) and JLSD(25, 60 + JY.Person[pid]["ָ������"]*0.1, pid) and kfkind == 2 and JY.Person[pid]["�������"] > 0 then
		WAR.Person[id]["��Ч����"] = 6
		if WAR.Person[id]["��Ч����3"] == nil then
			WAR.Person[id]["��Ч����3"] = ZJTF[2]
		else
			WAR.Person[id]["��Ч����3"] = ZJTF[2] .. "��" .. WAR.Person[id]["��Ч����3"]
		end
		ng = ng + 1000
		WAR.WS = 1
		
		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('ʵʱ��Ч����')
			Cls()
			NewDrawString(-1, -1, ZJTF[2] .. TFSSJ[2], C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end

		WAR.LXYZ = 1
    end
    
    --������ϵ����
    if pid == 0 and JY.Base["��׼"] == 5 and 0 < JY.Person[pid]["�书9"] and 120 <= TrueTS(pid) and JLSD(25, 50 + JY.Person[pid]["�������"]*0.1, pid) and kfkind == 5 and JY.Person[pid]["�������"] > 0 then
		WAR.Person[id]["��Ч����"] = 6
		if WAR.Person[id]["��Ч����3"] == nil then
			WAR.Person[id]["��Ч����3"] = ZJTF[5]
		else
			WAR.Person[id]["��Ч����3"] = ZJTF[5] .. "��" .. WAR.Person[id]["��Ч����3"]
		end
		ng = ng + 1000
		WAR.WS = 1
		
		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('ʵʱ��Ч����')
			Cls()
			NewDrawString(-1, -1, ZJTF[5] .. TFSSJ[5], C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end

		WAR.GCTJ = 1
    end
    
    --���ǵ�ϵ����
    if pid == 0 and JY.Base["��׼"] == 4 and 0 < JY.Person[pid]["�书9"] and 120 <= TrueSD(pid) and JLSD(25, 50 + JY.Person[pid]["ˣ������"]*0.1, pid) and kfkind == 4 and JY.Person[pid]["�������"] > 0 then
		WAR.Person[id]["��Ч����"] = 6
		if WAR.Person[id]["��Ч����3"] == nil then
			WAR.Person[id]["��Ч����3"] = ZJTF[4]
		else
			WAR.Person[id]["��Ч����3"] = ZJTF[4] .. "��" .. WAR.Person[id]["��Ч����3"]
		end
		ng = ng + 1000
		WAR.WS = 1
		
		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('ʵʱ��Ч����')
			Cls()
			NewDrawString(-1, -1, ZJTF[4] .. TFSSJ[4], C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end

		WAR.ASKD = 1
		--��������Լ���ŭ��25
		WAR.YZHYZ = WAR.YZHYZ + 25
    end
 
    --��������У��ڹ��ɴ���
    if pid == 0 and JY.Base["��׼"] == 6 and 0 < JY.Person[pid]["�书9"] and JLSD(25, 60 + pz, pid) and kfkind == 6 and JY.Person[pid]["�������"] > 0 then
		WAR.Person[id]["��Ч����"] = 6
		if WAR.Person[id]["��Ч����3"] == nil then
			WAR.Person[id]["��Ч����3"] = ZJTF[6]
		else
			WAR.Person[id]["��Ч����3"] = ZJTF[6] .. "��" .. WAR.Person[id]["��Ч����3"]
		end
		ng = ng + 1000
		WAR.WS = 1
		
		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('ʵʱ��Ч����')
			Cls()
			NewDrawString(-1, -1, ZJTF[6] .. TFSSJ[6], C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end

		WAR.JSTG = 1
	end
	
    --���Ƕ������У������ж�100�ɴ���
    if pid == 0 and JY.Base["��׼"] == 9 and 0 < JY.Person[pid]["�书9"] and JLSD(25, 60 + pz, pid) and JY.Person[pid]["�ж��̶�"] == 100 and JY.Person[pid]["�������"] > 0 then
		WAR.Person[id]["��Ч����"] = 6
		if WAR.Person[id]["��Ч����3"] == nil then
			WAR.Person[id]["��Ч����3"] = ZJTF[9]
		else
			WAR.Person[id]["��Ч����3"] = ZJTF[9] .. "��" .. WAR.Person[id]["��Ч����3"]
		end
		WAR.WS = 1
		JY.Person[pid]["�ж��̶�"] = 0
		
		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('ʵʱ��Ч����')
			Cls()
			NewDrawString(-1, -1, ZJTF[9] .. TFSSJ[9], C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end

		WAR.YTML = 1
	end
	

	--ŷ���ˣ���ŭʹ��ѩɽ�����ƣ���Ϊ����ȭ
	if match_ID(pid,61) and wugong == 9 and WAR.LQZ[pid] == 100 then
		WAR.OYK = 1
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "������ȭ"
		else
			WAR.Person[id]["��Ч����1"] = "����ȭ"
		end
	end
	--��Ϣ�� �񾨸�
	if PersonKF(pid,180) and (JLSD(20,70,pid) or WAR.LQZ[pid] == 100) then
		WAR.JXG_SJG = 1
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "���񾨸�"
		else
			WAR.Person[id]["��Ч����1"] = "�񾨸�"
		end
	end	

  --���°˷� ����
	if match_ID(pid,578)  and kfkind == 4  then
		local df = 0
		for i = 1, JY.Base["�书����"] do
			if JY.Wugong[JY.Person[0]["�书" .. i]]["�书����"] == 4 and JY.Person[0]["�书�ȼ�" .. i] == 999 then
				df = df + 1
			end
		end
		local DFWZ = {"����", "����", "ս��", "��ı", "��ս", "����", "��թ", "��Բ"}
		if inteam(pid)  then
			WAR.KZJYBF = math.random(0, df)
			if WAR.KZJYBF > 8then
				WAR.KZJYBF = 8
			end
			--���׺�����
			if df > 7 then
				WAR.KZJYBF = math.random(6, 8)
			end
		else
			WAR.KZJYBF = math.random(1, 8)	
		end
		if WAR.KZJYBF > 0 then
			ng = ng + 1000+WAR.KZJYBF*150
	    end
	end	
	

	--������ ������
	if match_ID(pid, 584) and kfkind == 1  then
		local DFWZ = {"һʽ����ˮ���ơ�", "��ʽ�����ƴ��¡�", "��ʽ�����Ƹ��꡻", "��ʽ����ɽ������", "��ʽ�����Ʊ��ա�", "��ʽ������������", "��ʽ��˺�����ơ�", "��ʽ���ƺ����Ρ�", 
		"��ʽ�������޶���", "ʮʽ�������콵��", "ʮһʽ�������ɾ���","ʮ��ʽ�����Ʋҵ���"}
		if inteam(pid) then
			WAR.BJYPYZ = math.random(0, JY.Base["��������"])
			if WAR.BJYPYZ > 12then
				WAR.BJYPYZ = 12
			end
			--������������-5
			if JY.Base["��������"] > 5 then
				if WAR.BJYPYZ < JY.Base["��������"] - 5 then
					WAR.BJYPYZ = JY.Base["��������"] - 5
				end
			end
		else
			WAR.BJYPYZ = math.random(1, 10)
		end
		if WAR.BJYPYZ > 0 then
			ng = ng + 1000
			if WAR.Person[id]["��Ч����0"] ~= nil then
				WAR.Person[id]["��Ч����0"] = "�����ơ�"..DFWZ[WAR.BJYPYZ].."+"..WAR.Person[id]["��Ч����0"]
			else
				WAR.Person[id]["��Ч����0"] = "�����ơ�"..DFWZ[WAR.BJYPYZ]
			end
		end
	end	

	
	--������ ʥ�齣��15~22 "ʥ�顤����ʮ��", "ʥ�顤����ʮһ��", "ʥ�顤����ʮ����", "ʥ�顤����ʮ����", "ʥ�顤����ʮ�ġ�","ʥ�顤����ʮ��", "ʥ�顤����ʮһ��", 
		--"ʥ�顤����ʮ����", "ʥ�顤����ʮ����", "ʥ�顤����ʮ�ġ�",
	if match_ID(pid, 584) and kfkind == 3 and WAR.SL23 ==0 then
		local txwz = { "ʥ�顤����ʮ�塻", "ʥ�顤����ʮ����", "ʥ�顤����ʮ�ߡ�", 
		"ʥ�顤����ʮ�ˡ�", "ʥ�顤����ʮ�š�", "ʥ�顤����إ��", "ʥ�顤����إһ��", "ʥ�顤����إ����"}
		if inteam(pid) then
			WAR.BJYJF = math.random(0, JY.Base["��������"])
			--������������-5
			if JY.Base["��������"] > 8 then
				if WAR.BJYJF < JY.Base["��������"] - 8 then
					WAR.BJYJF = JY.Base["��������"] - 8
				end
						if WAR.BJYJF > 8then
				WAR.BJYJF = 8
			end
			end
		else
			WAR.BJYJF = math.random(1, 8)
		end
		if WAR.BJYJF > 0 then
			ng = ng + (1000+WAR.BJYJF*80)
			if WAR.Person[id]["��Ч����0"] ~= nil then
				WAR.Person[id]["��Ч����0"] = txwz[WAR.BJYJF].."+"..WAR.Person[id]["��Ч����0"]
			else
				WAR.Person[id]["��Ч����0"] = txwz[WAR.BJYJF]
			end
		end
	end
   --÷����Ū
	if  match_ID(pid,634) then
		local txwz = {"һ", "��", "��"}
	    if inteam(pid) then	
	        WAR.MHSN = math.random(1, 3)
		if WAR.MHSN > 0 then
			ng = ng + WAR.MHSN*150
			if WAR.Person[id]["��Ч����1"] ~= nil then
				WAR.Person[id]["��Ч����1"] = "÷��"..txwz[WAR.MHSN].."Ū".."+"..WAR.Person[id]["��Ч����1"]
			else
				WAR.Person[id]["��Ч����1"] = "÷��"..txwz[WAR.MHSN].."Ū"
			end
		end
	end
	end

	--������ ʥ�齣��1-9
	if match_ID(pid, 584) and kfkind == 3 and WAR.BJYJF < 1 and WAR.SL23 ==0  then
		local zs = {"ʥ�顤����һ��", "ʥ�顤��������", "ʥ�顤��������", "ʥ�顤�����ġ�", "ʥ�顤�����塻", "ʥ�顤��������", "ʥ�顤�����ߡ�", "ʥ�顤�����ˡ�", 
		"ʥ�顤�����š�",}
		WAR.Person[id]["��Ч����1"] = zs[math.random(9)]
		ng = ng +1000
		end	
	

	--��������������ʱ����󾢣����಻��
	if match_ID(pid, 55) and wugong == 26 and WAR.ACT > 1 then
		local txwz = {"һ", "��", "��", "��", "��", "��", "��", "��", "��", "ʮ", "ʮһ","ʮ��","ʮ��"}
		if inteam(pid) then
			WAR.YYBJ = math.random(0, JY.Base["��������"])
			if WAR.YYBJ > 13 then
				WAR.YYBJ = 13
			end
			--������������-7
			if JY.Base["��������"] > 7 then
				if WAR.YYBJ < JY.Base["��������"] - 7 then
					WAR.YYBJ = JY.Base["��������"] - 7
				end
			end
		else
			WAR.YYBJ = math.random(1, 10)
		end
		if WAR.YYBJ > 0 then
			ng = ng + WAR.YYBJ*150
			if WAR.Person[id]["��Ч����1"] ~= nil then
				WAR.Person[id]["��Ч����1"] = "���������಻����"..txwz[WAR.YYBJ].."�غ�".."+"..WAR.Person[id]["��Ч����1"]
			else
				WAR.Person[id]["��Ч����1"] = "���������಻����"..txwz[WAR.YYBJ].."�غ�"
			end
		end
	end

    --�����
	if match_ID(pid,577) and (JLSD(20,45,pid) or WAR.WFCZ[pid]>=5) then
       WAR.PD["�����"][pid] = 1
	   TXWZXS("�����", C_GOLD)
	   if WAR.WFCZ[pid]>=5 then
		  WAR.WFCZ[pid] = 0
		end
	end 
	--����
	if JY.Base["��׼"] == 7 and pid == 0  and JY.Person[pid]["Ʒ��"] == 120 then
		WAR.SEYB =1
		TXWZXS("�ƶ��б�", M_DeepSkyBlue)
	end
 -- ½��˫ �嶾
	if match_ID_awakened(pid,580,1)  and (JLSD(20,70,pid) or WAR.LQZ[pid]==100) then
	   WAR.LWSWD = 1 
	 if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "���嶾�澭"
		else
			WAR.Person[id]["��Ч����1"] = "�嶾�澭"
		end
    end
 -- ��̩�� �׶�����
	if match_ID(pid,151) and WAR.LQZ[pid] == 100 then
	   WAR.LDJT = 1 
	 if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "���׶�����"
		else
			WAR.Person[id]["��Ч����1"] = "�׶�����"
		end
    end	
	--���ͣ����ħȭ
	if match_ID(pid, 637)  and (JLSD(10,30+JY.Base["��������"],pid) or WAR.LQZ[pid]==100) then
		WAR.DFMQ = 1
		WAR.WS = 1
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "�����ħȭ"
		else
			WAR.Person[id]["��Ч����1"] = "���ħȭ"
		end
    end
	--���࣬��Ԫ����
	if match_ID(pid, 604) and kfkind == 3 then
		WAR.TYJQ = 1
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "����Ԫ����"
		else
			WAR.Person[id]["��Ч����1"] = "��Ԫ����"
		end
	end 


   -- ��������һ�뽣ϵ
    if match_ID(pid,592) then
		WAR.WWWJ = 1
    end
		
   -- ���������
    if (wugong == 22 or wugong == 289) and JinGangBR(pid) then
		WAR.PD["��հ���"][pid] = 1
    end
	--��Ԫ��
    if (Curr_NG(pid, 90) and (JLSD(20,90,pid) or WAR.LQZ[pid] == 100)) or match_ID(pid,189) then
       WAR.HYYQ = 1	   
	   if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "����Ԫһ��"
		else
			WAR.Person[id]["��Ч����1"] = "��Ԫһ��"
	   end
    end  
	--�߱�����
	if JY.Person[pid]["����"] == 200 and JY.Thing[200]["װ���ȼ�"] == 6 and JLSD(0, 40, pid) then
		WAR.QBLL = 1
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "���߱�����"
		else
			WAR.Person[id]["��Ч����1"] = "�߱�����"
		end
    end	
   --����ħ
   if ShiZunXM(pid) then
   	   local ex_chance = 0
	   if JY.Person[pid]["����"] == 323 then
			ex_chance = JY.Thing[323]["װ���ȼ�"] * 2
	   end
       if (wugong == 96 or wugong == 86 or wugong == 82 or wugong == 83 ) and (JLSD(20,60+ex_chance,pid) or WAR.LQZ[pid] == 100) then
           WAR.SZXM = 1
       if WAR.Person[id]["��Ч����0"] ~= nil then
			WAR.Person[id]["��Ч����0"] = WAR.Person[id]["��Ч����0"] .. "������ħ"
	   else
			WAR.Person[id]["��Ч����0"] = "����ħ"
	   end
       end
    end	
	--���� ��������
	if match_ID(pid, 629) and  WAR.AJFHNP == 1 then
	   WAR.Person[id]["��Ч����"] = 154
    end	
	--������ ��Ůʮ�Ž�
	if match_ID(pid, 649) and kfkind == 3 then
		WAR.YLSJJ = 1
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "����Ůʮ�Ž�"
		else
			WAR.Person[id]["��Ч����1"] = "��Ůʮ�Ž�"
		end
    end	
	--������ ����һ��
	if match_ID(pid, 649) and kfkind == 3 and (JLSD(20,80,pid) or WAR.LQZ[pid] == 100) then
		WAR.NZZ1 = 1
		if WAR.Person[id]["��Ч����0"] ~= nil then
			WAR.Person[id]["��Ч����0"] = WAR.Person[id]["��Ч����0"] .. "������һ������˫�޶�"
		else
			WAR.Person[id]["��Ч����0"] = "����һ������˫�޶�"
		end
    end		
	--���Ŵ�ѩ
	if match_ID_awakened(pid, 500,1)  then
		WAR.XMJDHS = 1
		ng = ng +1000
		if WAR.Person[id]["��Ч����0"] ~= nil then
			WAR.Person[id]["��Ч����0"] = WAR.Person[id]["��Ч����0"] .. "���������Ʋ��"
		else
			WAR.Person[id]["��Ч����0"] = "���������Ʋ��"
		end
    end	
	--½����֮����������ˮ���з�ϵ����0��
	if match_ID(pid, 497) and JY.Person[0]["�������"] > 0 and JY.Base["��������"] > 9 and  WAR.LQZ[pid] == 100 then
		WAR.HZD_1 = 1
		if WAR.Person[id]["��Ч����0"] ~= nil then
			WAR.Person[id]["��Ч����0"] = WAR.Person[id]["��Ч����0"] .. "��������ˮ"
		else
			WAR.Person[id]["��Ч����0"] = "������ˮ"
		end
    end


	--�ֳ�Ӣ�������ѩ
	if match_ID(pid, 605) and JLSD(20, 80, pid) then
		WAR.LFHX = 1
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "�������ѩ"
		else
			WAR.Person[id]["��Ч����3"] = "�����ѩ"
		end
    end
			--����ˮ ����
	if (match_ID(pid, 652) or Curr_NG(pid,177)) and JLSD(0, 35, pid) and JY.Base["��������"] > 2  then
        WAR.PD['����'][pid] = 1
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "������"
		else
			WAR.Person[id]["��Ч����3"] = "����"
		end
    end
		--����ˮ ˮ��
	if (match_ID(pid, 652)  or Curr_NG(pid,177)) and JY.Base["��������"] > 1 and JLSD(0, 35, pid) then
		WAR.LFHX = 1
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "��ˮ��"
		else
			WAR.Person[id]["��Ч����3"] = "ˮ��"
		end
    end
	
	--��Ϧ���أ��򹷲��־�
	if wugong == 80 and match_ID(pid, 613) then
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "+�򹷰��������־�"
		else
			WAR.Person[id]["��Ч����1"] = "�򹷰��������־�"
		end
	end
	
	--����̩ɽ��ʹ�ú�30ʱ��������
	if wugong == 31 and PersonKF(pid,175) then
		WAR.TSSB[pid] = 30
	end

	--�����������ʹ�ú�10ʱ��������
	if match_ID(pid, 636) then
		WAR.QLJX[pid] = 30
	end
	
	--�̺���ʽ2 �����
	if WAR.BHJTZ3 == 1 and WAR.BTZT[pid]== nil then
		WAR.BTZT[pid] = 1
	end	
	   --½����շ���
	if match_ID(pid, 497) then
		WAR.JGFX[pid] = 100
	end	



    --��������ʽ3 ��ʹ�ú�100ʱ���ڴ�ظ�
	if  WAR.JYZS ==3 then
		WAR.CSHF[pid] = 100
	end	

	--�������޵��������ٵз��ƶ�
	if Curr_QG(pid,148) then
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "+������"
		else
			WAR.Person[id]["��Ч����1"] = "������"
		end
	end
		
	--�޾Ʋ������ٻ���ԭ������+ȼľ+���浶����ȼЧ����ƽʱ50%���ʣ���ŭ�س�
	--����
	if ((wugong == 61 or wugong == 65 or wugong == 66)  and JuHuoLY(pid)) 
	or (match_ID(pid,578) and JY.Person[pid]["��������"] == 1 and (WAR.LQZ[pid] == 100 or JLSD(20,70,pid))) then
		Set_Eff_Text(id,"��Ч����1","�ٻ���ԭ")
		WAR.JuHuo = 1
	end
	-- ���������ȼ
	if match_ID(pid,508) and JLSD(20,30,pid) then
		WAR.JuHuo = 1
    end		
	--������ƽʱ50%���ʣ���ŭ�س�
	if match_ID_awakened(pid,581,1) and wugong == 61 and (WAR.LQZ[pid] == 100 or JLSD(20,40,pid)) then
		Set_Eff_Text(id,"��Ч����1","�ٻ���ԭ")
		WAR.JuHuo = 1
	end	
	--�޾Ʋ��������к��棬����+����+���飬����Ч����ƽʱ50%���ʣ���ŭ�س�
	if (wugong == 58 or wugong == 174 or wugong == 153) and LiRenHF(pid) and (WAR.LQZ[pid] == 100 or JLSD(20,70,pid)) then
		Set_Eff_Text(id,"��Ч����1","���к���")
		WAR.LiRen = 1
	end
	
	--��ң����
	if XiaoYaoYF(pid) and JLSD(20,70,pid) and (WAR.XYYF[pid] == nil or WAR.XYYF[pid] < 9) and WAR.YFCS < 3 then
		WAR.YFCS = WAR.YFCS + 1
		WAR.XYYF[pid] = (WAR.XYYF[pid] or 0) + 1
		Set_Eff_Text(id,"��Ч����0","��ң����")
		if WAR.XYYF[pid] == 9 then
			WAR.XYYF[pid] = 11
		end
	end

	--����̫����̫��֮�أ�����ŭ
	if Curr_NG(pid, 102) and JLSD(20, 35 + math.modf(JY.Person[pid]["ʵս"]/25), pid)  then
		WAR.TXZZ = 1
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "��̫��֮��"
		else
			WAR.Person[id]["��Ч����1"] = "̫��֮��"
		end
    end
	--һ����һ��ָ������ҵ��
	if match_ID(pid, 65) and wugong == 17 then
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = "����ҵ��"..WAR.Person[id]["��Ч����1"]
		else
			WAR.Person[id]["��Ч����1"] = "����ҵ��"
		end
	end
	--������1��ͬ�齣��
	if match_ID(pid, 129) and JLSD(20,60,pid) then
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = "ͬ�齣����"..WAR.Person[id]["��Ч����1"]
		else
			WAR.Person[id]["��Ч����1"] = "ͬ�齣��"
		end
	end	
	
	--�ܲ�ͨ����֮���ʹ�з����Ụ�壬��ʼ����25%��ÿ20��ʵս+1%����
	if match_ID(pid, 64) and JLSD(20, 45 + math.modf(JY.Person[pid]["ʵս"]/20), pid) then
		WAR.KMZWD = 1
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = "����֮�����"..WAR.Person[id]["��Ч����1"]
		else
			WAR.Person[id]["��Ч����1"] = "����֮���"
		end
    end
	
	--�Ž��洫��������������70%���ʴ���4����Ч֮һ
	if  (match_ID(pid,9974) or match_ID_awakened(pid,35,2) or (pid == 0 and JY.Person[241]["Ʒ��"] == 80)) and kfkind == 3 and JLSD(15, 85,pid) then
		local t = math.random(4)
		local wz = {"�뽣ʽ","����ʽ","�ý�ʽ","����ʽ"}
		WAR.JJZC = t
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .."+�Ž��洫��"..wz[t]
		else
			WAR.Person[id]["��Ч����1"] = "�Ž��洫��"..wz[t]
		end
	end
	--��ħ���٣�������������50%���ʴ���2����Ч֮һ
	if ((pid == 0 and JY.Person[242]["Ʒ��"] == 90 and JLSD(15, 65,pid)) or match_ID(pid,9975) or (match_ID(pid,58) and CC.TX['�����ħ'] == 1 )) and kfkind == 3 then	
		local t = math.random(2)
		local wz = {"��ħ���١��켫��Ԩ","��ħ���١��ƾ�����"}
		WAR.JMZL = t
		TXWZXS(wz[t], M_Red)
	end
	
	--�����黭�������٣�����ŭ
	if wugong == 73 and QinqiSH(pid) then
		WAR.QQSH1 = 1
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "�������ö�"
		else
			WAR.Person[id]["��Ч����1"] = "�����ö�"
		end
		--50%���ʴ�����ŭ
		if JLSD(20, 70, pid) then
			WAR.QQSH1 = 2
			if WAR.Person[id]["��Ч����1"] ~= nil then
				WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "����������"
			else
				WAR.Person[id]["��Ч����1"] = "��������"
			end
		end
    end
	
	--�����黭����ʵ��࣬����
	if wugong == 142 and QinqiSH(pid) then
		--60%���ʱ���
		if JLSD(20, 80, pid) then
			WAR.QQSH2 = 1
			if WAR.Person[id]["��Ч����3"] ~= nil then
				WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "������Ϊ��"
			else
				WAR.Person[id]["��Ч����3"] = "����Ϊ��"
			end
		end
		
		--30%���ʴ����
		if JLSD(30, 60, pid) then
			WAR.QQSH2 = 2
			if WAR.Person[id]["��Ч����3"] ~= nil then
				WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "����ɽ�续"
			else
				WAR.Person[id]["��Ч����3"] = "��ɽ�续"
			end
		end
	end
	
	--�����黭��������������50%���ʳ���Ч���˺����20%���ط�Ѩ
	if wugong == 84 and QinqiSH(pid) and JLSD(20, 70, pid) then
		WAR.QQSH3 = 1
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "������ֱ��"
		else
			WAR.Person[id]["��Ч����3"] = "����ֱ��"
		end
	end
	
	--���� ����ɢ�֣��ط�Ѩ
	if match_ID(pid,635) then
		WAR.SLSS = 1
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "+����ɢ��"
		else
			WAR.Person[id]["��Ч����3"] = "����ɢ��"
		end
	end	
	
	--������Ů��ز�ÿձ̣������˺�ɱ������
	--����Ů�ط���
	if ((Curr_NG(pid, 154) and (JLSD(30, 60 + JY.Base["��������"]*2, pid))) or (match_ID(pid,640)and PersonKF(pid,154) and JLSD(30,80))) and WAR.ACT > 1then
		WAR.YNXJ = 1
		if WAR.Person[id]["��Ч����0"] ~= nil then
			WAR.Person[id]["��Ч����0"] = WAR.Person[id]["��Ч����0"] .. "+ز�ÿձ�"
		else
			WAR.Person[id]["��Ч����0"] = "ز�ÿձ�"
		end
    end
	--����ˮ �������� �����˺�ɱ������
	if  match_ID(pid,652) and JY.Base["��������"] > 5 then
		WAR.YNXJ = 1
		if WAR.Person[id]["��Ч����0"] ~= nil then
			WAR.Person[id]["��Ч����0"] = WAR.Person[id]["��Ч����0"] .. "+��������"
		else
			WAR.Person[id]["��Ч����0"] = "��������"
		end
    end	
	
    --ŭ������������+1200
    if WAR.LQZ[pid] == 100 and WAR.DZXY ~= 1 then
		WAR.HXZYJ = 1
		WAR.Person[id]["��Ч����"] = 6
		ng = ng + 1200
    end
	
	--ȫ�����ӣ��������������ʾ
	if WAR.ZDDH == 73 then
		if (pid >= 123 and pid <= 128) or pid == 68 then
			WAR.Person[id]["��Ч����"] = 93
			if WAR.Person[id]["��Ч����2"] ~= nil then
				WAR.Person[id]["��Ч����2"] = WAR.Person[id]["��Ч����2"] .. "+����������"
			else
				WAR.Person[id]["��Ч����2"] = "����������"
			end
		end
	end
	
    --��������
    if WAR.Actup[pid] ~= nil then
    	--���˸�󡣬׷��ɱ��
		if Curr_NG(pid, 95)  then
			ng = ng + 1200
		else
			ng = ng + 600
		end
		local str = "��������"
		if WAR.SLSX[pid] ~= nil then
			str = str .. "��ʮ��ʮ��"
		end
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "+"..str
		else
			WAR.Person[id]["��Ч����1"] = str
		end
    end  
     
    --��������Чһ��׷�ӵ�ͬ���书������ɱ��
  	if WAR.L_TLD == 1 then
		ng = ng + get_skill_power(pid, wugong, 11)
  	end
    
	--�η���
    --if match_ID(pid,615)then
       --ng = ng + JY.Person[pid]["�Ṧ"]*2
   -- end
    --��Ч����1������Ϊ��ɫȦ
    if WAR.Person[id]["��Ч����1"] ~= nil and WAR.Person[id]["��Ч����"] == -1 then
		WAR.Person[id]["��Ч����"] = 88
    end
	
	--������������Ч����
	if match_ID(pid, 129) and WAR.BDQS > 0 then
		WAR.Person[id]["��Ч����"] = 126
	end
	--��Ħ������Ч����
	if match_ID(pid, 577)  then
		WAR.Person[id]["��Ч����"] = 158
	end	
	--�޾Ʋ�������Ч����
	if pid == 0 and JY.Base["����"] == 1 then
		WAR.Person[id]["��Ч����"] = 132
	end

	--����ˮ������Ч����
	if match_ID(pid, 652) and JY.Person[0]["�������"] > 0 then
		WAR.Person[id]["��Ч����"] = 83
	end

    --��̫���Ķ���
	if WAR.WDKTJ == 1 then
	    WAR.Person[id]["��Ч����"] = 159
	end		
	--½��������Ч����
	if match_ID(pid, 635) and JY.Person[0]["�������"] > 0 then
		WAR.Person[id]["��Ч����"] = 126
	end
    -- ˫���ϱڶ��� 	
    if (wugong == 39 or wugong == 42 or wugong == 139) and ShuangJianHB(pid) then 
	 WAR.Person[id]["��Ч����"] = 83
	 end
	--���˷��ƾ��Ķ���������
	if match_ID(pid, 3) and WAR.MRF == 1 then
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = "�ƾ���"..WAR.Person[id]["��Ч����1"]
		else
			WAR.Person[id]["��Ч����1"] = "�ƾ�"
		end
		WAR.Person[id]["��Ч����"] = 146
	end
	
    if Given_WG(pid, wugong) and wugong == 35 then
        if WAR.ATNum > 1 then 
            local str = {'һ','��','��','��','��','��'}
            WAR.PD['ѩ������'][pid] = math.random(6)
            if WAR.Person[id]["��Ч����3"] == nil then 
                WAR.Person[id]["��Ч����3"] = str[WAR.PD['ѩ������'][pid]]..'��'
            else
                WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"]..'��'..str[WAR.PD['ѩ������'][pid]]..'��'
            end
        end
    end
    
	WAR.KF = wugong
    if MyFj(WAR.CurID) == false then
        if DGFJ() == 1 then
			return 1
		end
    end
	wugong = WAR.KF
    
    for i = 0,WAR.PersonNum -1 do 
        local mid = WAR.Person[i]['������']
        if match_ID(mid, 9967) and Curr_NG(mid, 105)  then
			local jl = 30       	
            if WAR.Person[i]['����'] == false and GetWarMap(WAR.Person[i]['����X'],WAR.Person[i]['����Y'],4) > 0 and i ~= WAR.CurID and JLSD(0,jl,mid) then
                Cat('Ų��',i,7,1)   
            end
        end
    end
    
	if JY.Person[pid]["����"] <= 0 then
		return 1
	end	

	if JY.Person[pid]["����"] == 320 and JY.Wugong[wugong]["�书����"] == 2 and JY.Thing[320]["װ���ȼ�"] == 6  and JLSD(20,70,pid) then
		Set_Eff_Text(id,"��Ч����1","����Х��");
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.Person[j]["����"] == false  then
				WAR.Person[j].TimeAdd = WAR.Person[j].TimeAdd - 100
			end
		end
    end

  --�޾Ʋ�����ʨ�Ӻ�
    if PersonKF(pid, 92) then
    	if WAR.Person[id]["��Ч����"] == -1 then
    		WAR.Person[id]["��Ч����"] = math.fmod(92, 10) + 85
    	end
    	local nl = JY.Person[pid]["����"];
    	local f = 0;
		local chance = 70
		local force = 100
		--�������Ч��
		if Curr_NG(pid, 92) then
			chance = 100
			force = 200
		end
		--һ������Ҫ���������2000����лѷֻҪ���������0����
		local neilicha = 2000
		if match_ID(pid, 13) then
			neilicha = 0
		end

		if JLSD(0,chance,pid) or wugong == 92 then
			f = 1
		end
		if f == 1 then
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.Person[j]["����"] == false and (nl - JY.Person[WAR.Person[j]["������"]]["����"]) > neilicha then
					WAR.Person[j].TimeAdd = WAR.Person[j].TimeAdd - force 
					if Curr_NG(pid, 92) and myns(j) == false then
						WAR.Person[j]["���˵���"] = (WAR.Person[j]["���˵���"] or 0) + AddPersonAttrib(WAR.Person[j]["������"], "���˳̶�", math.random(5,9))
						WAR.TXXS[WAR.Person[j]["������"]] = 1
					end
				end
			end
			Set_Eff_Text(id,"��Ч����2","ʨ�Ӻ�");
		end
    end	
    
    --��Ӣ��ʹ�����｣����ɱ����300
    if match_ID(pid, 63) and wugong == 38 then
		WAR.CY = 1
    end

    --��� �������Ǻ� ȫ�弯����100
    if match_ID(pid, 58) and WAR.XK ~= 2 then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
				WAR.Person[j].TimeAdd = WAR.Person[j].TimeAdd - 100
			end
		end
		if WAR.Person[id]["��Ч����"] == nil then
			WAR.Person[id]["��Ч����"] = 89
		end
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "+" .."����֮ŭХ"
		else
			WAR.Person[id]["��Ч����1"] = "����֮ŭХ"
		end
    end
      
    --�����
    if WAR.XK == 2 and match_ID(pid, 58) and WAR.Person[WAR.CurID]["�ҷ�"] == WAR.XK2 then
		for e = 0, WAR.PersonNum - 1 do
			if WAR.Person[e]["����"] == false and WAR.Person[e]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
				WAR.Person[e].TimeAdd = WAR.Person[e].TimeAdd - math.modf(JY.Person[WAR.Person[WAR.CurID]["������"]]["����"] / 5)
				if WAR.Person[e].Time < -450 then
					WAR.Person[e].Time = -450
				end
				JY.Person[WAR.Person[e]["������"]]["����"] = JY.Person[WAR.Person[e]["������"]]["����"] - math.modf(JY.Person[WAR.Person[WAR.CurID]["������"]]["����"] / 5)
				if JY.Person[WAR.Person[e]["������"]]["����"] < 0 then
					JY.Person[WAR.Person[e]["������"]]["����"] = 0
				end
				JY.Person[WAR.Person[e]["������"]]["����"] = JY.Person[WAR.Person[e]["������"]]["����"] - math.modf(JY.Person[WAR.Person[WAR.CurID]["������"]]["����"] / 25)
			end
			if JY.Person[WAR.Person[e]["������"]]["����"] < 0 then
				JY.Person[WAR.Person[e]["������"]]["����"] = 0
			end
		end
			
		--���֮������Ϊ0���������ֵ-1000��������������������
		if inteam(pid) then
			JY.Person[pid]["����"] = 0
			JY.Person[pid]["�������ֵ"] = JY.Person[pid]["�������ֵ"] - 1000
			JY.Person[300]["����"] = JY.Person[300]["����"] + 1
		else
			AddPersonAttrib(pid, "����", -1000)  --���з�����ֻ��1000
		end
		  
		if JY.Person[pid]["�������ֵ"] < 500 then
			JY.Person[pid]["�������ֵ"] = 500
		end
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "+" .."����֮��ŭ��������Х"
		else
			WAR.Person[id]["��Ч����1"] = "����֮��ŭ��������Х"
		end
		WAR.Person[id]["��Ч����"] = 6
		WAR.XK = 3
	end    
  
    --��ӯӯ��ʹ�ó����٣����ν���
    if match_ID(pid, 73) and wugong == 73 then
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "+" .."�������ν���"
		else
			WAR.Person[id]["��Ч����3"] = "�������ν���"
		end
		WAR.Person[id]["��Ч����"] = 89
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
				WAR.TXXS[WAR.Person[j]["������"]] = 1
				--�޾Ʋ�������¼����Ѫ��
				WAR.Person[j]["Life_Before_Hit"] = JY.Person[WAR.Person[j]["������"]]["����"]
				JY.Person[WAR.Person[j]["������"]]["����"] = JY.Person[WAR.Person[j]["������"]]["����"] - 50
				WAR.Person[j]["��������"] = (WAR.Person[j]["��������"] or 0) - 50
				--��˯״̬�ĵ��˻�����
				if WAR.CSZT[WAR.Person[j]["������"]] ~= nil then
					WAR.CSZT[WAR.Person[j]["������"]] = nil
				end
			end
		end
	end

	--�������� �����ٻ�Ѫ5%������10����
	if wugong == 73 and JiandanQX(pid) then
		Set_Eff_Text(id, "��Ч����3", "����������")
		WAR.Person[id]["��Ч����"] = 89	
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", JY.Person[pid]["����"]*0.05)
		WAR.Person[WAR.CurID]["���˵���"] = (WAR.Person[WAR.CurID]["���˵���"] or 0) + AddPersonAttrib(pid, "���˳̶�", -10)
	end
	
	--��Ϧ��ӯӯ��ǿ��Ч��
    if match_ID(pid, 611) and wugong == 73 then
		if WAR.Person[id]["��Ч����3"] ~= nil then
			WAR.Person[id]["��Ч����3"] = WAR.Person[id]["��Ч����3"] .. "+" .."ħ���ѻ�"
		else
			WAR.Person[id]["��Ч����3"] = "ħ���ѻ�"
		end
		WAR.Person[id]["��Ч����"] = 89
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
				JY.Person[WAR.Person[j]["������"]]["����"] = JY.Person[WAR.Person[j]["������"]]["����"] - 100
			end
		end
	end
    
    --��ҩʦ����һ�ι�����������500����������500׷���˺�
    if match_ID(pid, 57) and WAR.ACT == 1  then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
				if JY.Person[WAR.Person[j]["������"]]["����"] > 500 then
					JY.Person[WAR.Person[j]["������"]]["����"] = JY.Person[WAR.Person[j]["������"]]["����"] - 500
					WAR.Person[j]["��������"] = (WAR.Person[j]["��������"] or 0) - 500;
				else
					WAR.Person[j]["��������"] = (WAR.Person[j]["��������"] or 0) - JY.Person[WAR.Person[j]["������"]]["����"];
					JY.Person[WAR.Person[j]["������"]]["����"] = 0
					--�޾Ʋ�������¼����Ѫ��
					WAR.Person[j]["Life_Before_Hit"] = JY.Person[WAR.Person[j]["������"]]["����"]
					JY.Person[WAR.Person[j]["������"]]["����"] = JY.Person[WAR.Person[j]["������"]]["����"] - 100
					WAR.Person[j]["��������"] = (WAR.Person[j]["��������"] or 0) - 100
				end
				WAR.TXXS[WAR.Person[j]["������"]] = 1
			end
		end
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .. "+" .."ħ�����̺�������"
		else
			WAR.Person[id]["��Ч����1"] = "ħ�����̺�������"
		end
		WAR.Person[id]["��Ч����"] = 39
    end
    
     	--�����������ʱ��������״̬������30��
	if match_ID(pid, 586) then
		WAR.HZD_QF[pid] = (WAR.HZD_QF[pid] or 0) + math.random(2,4)
		if WAR.HZD_QF[pid] > 30 then
			WAR.HZD_QF[pid] = 30
	    end
	    for j = 0, WAR.PersonNum - 1 do
            if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"]  then
                if WAR.QYZT[WAR.Person[j]["������"]] == nil then
                    WAR.QYZT[WAR.Person[j]["������"]] = math.random(2,3)
                else
                    WAR.QYZT[WAR.Person[j]["������"]] = WAR.QYZT[WAR.Person[j]["������"]] + math.random(3)
                    if WAR.QYZT[WAR.Person[j]["������"]] > 30 then
                        WAR.QYZT[WAR.Person[j]["������"]] = 30
                    end	
                end
            end	
        end	
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .."+".."�����"
		else
			WAR.Person[id]["��Ч����1"] = "�����"
		end
		WAR.Person[id]["��Ч����"] = 83
    end 
 
		
	--�����˺�
	if match_ID(pid,586) and WAR.HZD_QF[pid] > 20 then
			CleanWarMap(4, 0)
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
					local eid = WAR.Person[j]["������"]
					local qycs = WAR.QYZT[eid] or 0
					if qycs >0 then
						WAR.TXXS[eid] = 1
						--�޾Ʋ�������¼����Ѫ��
						WAR.Person[j]["Life_Before_Hit"] = JY.Person[eid]["����"]
						JY.Person[eid]["����"] = JY.Person[eid]["����"] - 20*qycs
						WAR.Person[j]["��������"] = (WAR.Person[j]["��������"] or 0) - 20*qycs
						WAR.HZD_QF[pid] = nil
						SetWarMap(WAR.Person[j]["����X"], WAR.Person[j]["����Y"], 4, 1)

					end
				end
			end
		if WAR.Person[id]["��Ч����0"] ~= nil then
			WAR.Person[id]["��Ч����0"] = WAR.Person[id]["��Ч����0"] .."+".."���񳯷�"
		else
			WAR.Person[id]["��Ч����0"] = "���񳯷�"
		end
		WAR.Person[id]["��Ч����"] = 154
    end 	
    --������ ����ȫ���ж�+20
	--�۳���ǰѪ��7%
    if match_ID(pid, 2) then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
				local loss = math.modf(JY.Person[WAR.Person[j]["������"]]["����"]*0.07)
				--�޾Ʋ�������¼����Ѫ��
				WAR.Person[j]["Life_Before_Hit"] = JY.Person[WAR.Person[j]["������"]]["����"]
				JY.Person[WAR.Person[j]["������"]]["����"] = JY.Person[WAR.Person[j]["������"]]["����"] - loss
				WAR.Person[j]["��������"] = (WAR.Person[j]["��������"] or 0) - loss
				WAR.Person[j]["�ж�����"] = (WAR.Person[j]["�ж�����"] or 0) + AddPersonAttrib(WAR.Person[j]["������"], "�ж��̶�", 20)
				WAR.TXXS[WAR.Person[j]["������"]] = 1
				--��˯״̬�ĵ��˻�����
				if WAR.CSZT[WAR.Person[j]["������"]] ~= nil then
					WAR.CSZT[WAR.Person[j]["������"]] = nil
				end
			end
		end
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .."+".."���ĺ���"
		else
			WAR.Person[id]["��Ч����1"] = "���ĺ���"
		end
		WAR.Person[id]["��Ч����"] = 64
    end
      
    --�Ħ��  ʹ�û��浶����������30����ɱ����1000
    --��ͨ��ɫʹ����30%�Ļ���
	--���������ж�
    if wugong == 66 and level == 11 and (match_ID(pid, 103) or JLSD(30,60,pid) or (pid == 0 and JY.Base["��׼"] == 4 and JLSD(30,70,pid)))  then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and myns(j) == false then
				WAR.Person[j]["���˵���"] = (WAR.Person[j]["���˵���"] or 0) + AddPersonAttrib(WAR.Person[j]["������"], "���˳̶�", 30)
				WAR.TXXS[WAR.Person[j]["������"]] = 1
			end
		end
		if WAR.Person[id]["��Ч����1"] ~= nil then
			WAR.Person[id]["��Ч����1"] = WAR.Person[id]["��Ч����1"] .."+".."�������ڡ����浶"
		else
			WAR.Person[id]["��Ч����1"] = "�������ڡ����浶"
		end
		WAR.Person[id]["��Ч����"] = 58
		ng = ng + 1000
    end
    
	--����ˮ����ת��û�д����������߷����������ſɴ�������30%���ʴ���
	if (WAR.WXFS == nil or (WAR.WXFS ~= nil and WAR.Person[WAR.WXFS]["����"] == true)) and math.random(10) < 4 then
		local lqs_WXZS;
		for i = 0, CC.WarWidth - 1 do
			for j = 0, CC.WarHeight - 1 do
				local effect = GetWarMap(i, j, 4)
				if 0 < effect then
					local emeny = GetWarMap(i, j, 2)
					if emeny >= 0 and emeny ~= WAR.CurID then
						
						if WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[emeny]["�ҷ�"] and match_ID(WAR.Person[emeny]["������"], 118) and WAR.Person[emeny]["������"] == 0 then
							lqs_WXZS = emeny
							SetWarMap(i, j, 4, 0)
							break;
						end
					end
				end
			end
		end
	
		if lqs_WXZS ~= nil then
			
			--ID��ʱ��������ˮ
			local s = WAR.CurID
			WAR.CurID = lqs_WXZS
			local wxlox, wxloy;
			War_CalMoveStep(WAR.CurID, 10, 0)
			local function SelfXY(x, y)
				local yes = 0
				if x == WAR.Person[WAR.CurID]["����X"] then
					yes = yes +1
				end
				if y == WAR.Person[WAR.CurID]["����Y"] then
					yes = yes +1
				end
				if yes == 2 then
					return true
				end
				return false
			end
	        local x, y = nil, nil
	        while true do
				x, y = War_SelectMove()
				if x ~= nil then
					WAR.ShowHead = 0
					wxlox, wxloy = x, y
					break;
				--ESC�˳�
				else
					WAR.ShowHead = 0
					x, y = WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"]
					--wxlox, wxloy = WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"]
					break;
				end
			end
			--��������λ�ò��ܴ�������
			if SelfXY(x, y) == false then
				SetWarMap(wxlox, wxloy, 4, 0)
				--������û����������ת�������������
				if WAR.WXFS == nil then
					WAR.Person[WAR.PersonNum]["������"] = 600
					WAR.Person[WAR.PersonNum]["�ҷ�"] = WAR.Person[WAR.CurID]["�ҷ�"]
					WAR.Person[WAR.PersonNum]["����X"] = wxlox
					WAR.Person[WAR.PersonNum]["����Y"] = wxloy
					WAR.Person[WAR.PersonNum]["����"] = false
					WAR.Person[WAR.PersonNum]["�˷���"] = WAR.Person[WAR.CurID]["�˷���"]
					WAR.Person[WAR.PersonNum]["��ͼ"] = WarCalPersonPic(WAR.PersonNum)
                   
					--lib.PicLoadFile(string.format(CC.FightPicFile[1], JY.Person[600]["ͷ�����"]), string.format(CC.FightPicFile[2], JY.Person[600]["ͷ�����"]), 4 + WAR.PersonNum)
					WAR.JQSDXS[600] = 0	--ֱ��ָ�������������ٻ��������ϱ���ת����
					WAR.WXFS = WAR.PersonNum
					WAR.PersonNum = WAR.PersonNum + 1
				--�Ѿ������������÷�����
				else
					WAR.Person[WAR.WXFS]["����"] = false
					WAR.Person[WAR.WXFS]["�ҷ�"] = WAR.Person[WAR.CurID]["�ҷ�"]
					WAR.Person[WAR.WXFS]["����X"] = wxlox
					WAR.Person[WAR.WXFS]["����Y"] = wxloy
					WAR.Person[WAR.WXFS]["�˷���"] = WAR.Person[WAR.CurID]["�˷���"]
					WAR.Person[WAR.WXFS]["��ͼ"] = WarCalPersonPic(WAR.WXFS)
					JY.Person[600]["����"] = JY.Person[600]["�������ֵ"]
					JY.Person[600]["����"] = JY.Person[600]["�������ֵ"]
					JY.Person[600]["����"] = 100
					JY.Person[600]["���˳̶�"] = 0 
					JY.Person[600]["�ж��̶�"] = 0
					JY.Person[600]["����̶�"] = 0
					JY.Person[600]["���ճ̶�"] = 0
					WAR.Person[WAR.WXFS].Time = 0
					--��Ѫ
					if WAR.LXZT[600] ~= nil then
						WAR.LXZT[600] = nil
					end
					--��Ѩ
					if WAR.FXDS[600] ~= nil then
						WAR.FXDS[600] = nil
					end
				end
		  
				--�������λ����ͼ
				SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, -1)
				SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, -1)
                SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, -1)
				--�޸��������������
				WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], WAR.Person[WAR.WXFS]["����X"], WAR.Person[WAR.WXFS]["����Y"] = WAR.Person[WAR.WXFS]["����X"], WAR.Person[WAR.WXFS]["����Y"],WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"]
					
				--���ӻ�����ͼ
				SetWarMap(WAR.Person[WAR.WXFS]["����X"], WAR.Person[WAR.WXFS]["����Y"], 5, WAR.Person[WAR.WXFS]["��ͼ"])
				SetWarMap(WAR.Person[WAR.WXFS]["����X"], WAR.Person[WAR.WXFS]["����Y"], 2, WAR.WXFS)
                SetWarMap(WAR.Person[WAR.WXFS]["����X"], WAR.Person[WAR.WXFS]["����Y"],10,JY.Person[WAR.Person[WAR.WXFS]["������"]]['ͷ�����'])
                
				--����������ͼ
				SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, WAR.Person[WAR.CurID]["��ͼ"])
				SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, WAR.CurID)
                SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"],10,JY.Person[WAR.Person[WAR.CurID]["������"]]['ͷ�����'])
			end
			WarDrawMap(0)
			CurIDTXDH(WAR.CurID, 90,1,"����ת��")
				
			--��ԭID���������
			WAR.CurID = s
			WAR.ACT = 10
		end
	end
    
    --�����˺��ĵ���
    for i = 0, CC.WarWidth - 1 do
		for j = 0, CC.WarHeight - 1 do
			lib.GetKey()
			local effect = GetWarMap(i, j, 4)
			if 0 < effect then
				local emeny = GetWarMap(i, j, 2)
				if 0 <= emeny and emeny ~= WAR.CurID then		--������ˣ����Ҳ��ǵ�ǰ������
					--������תǬ��������£���������Ч�ͺϻ���Ȼ����Լ���
                    if match_ID(WAR.Person[emeny]["������"], 9965) then
                        JY.Person[WAR.Person[emeny]["������"]]['����̶�'] = 0
                        JY.Person[WAR.Person[emeny]["������"]]['���ճ̶�'] = 0
                        WAR.BFXS[WAR.Person[emeny]["������"]] = nil
                        WAR.ZSXS[WAR.Person[emeny]["������"]] = nil
                    end

					if WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[emeny]["�ҷ�"] or (ZHEN_ID < 0 and WAR.WS == 0) or WAR.NZQK > 0 or WAR.HLZT[pid] ~= nil then
						if JY.Wugong[wugong]["�˺�����"] == 1 and (fightscope == 0 or fightscope == 3) then
							if level == 11 then
								level = 10
							end
							SetWarMap(i, j, 4, 3)
							WAR.Effect = 3
						else
							--�ֳ�Ӣ���Ʊ��£�ÿ50ʱ��ɴ���һ�Σ������˺�10ʱ�����˲�����
							if match_ID(WAR.Person[emeny]["������"], 605) and WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[emeny]["�ҷ�"] then
								if WAR.QYBY[WAR.Person[emeny]["������"]] == nil then
									WAR.QYBY[WAR.Person[emeny]["������"]] = 50
								end
								if WAR.QYBY[WAR.Person[emeny]["������"]] > 40 then
									WAR.Person[emeny]["��Ч����3"] = "���Ʊ���"
									WAR.Person[emeny]["��Ч����"] = 102
								else
									WAR.Person[emeny]["��������"] = (WAR.Person[emeny]["��������"] or 0) - War_WugongHurtLife(emeny, wugong, level, ng, x, y)
									WAR.Effect = 2
									SetWarMap(i, j, 4, 2)
								end			
							--���Ǿ��Ѻ����㿪��ǰ���β����˺�
							elseif match_ID(WAR.Person[emeny]["������"], 92) and JY.Person[0]["�������"] > 0 and WAR.FF < 3 and WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[emeny]["�ҷ�"] then
								WAR.FF = WAR.FF + 1
								WAR.Person[emeny]["��Ч����"] = 135						
							--���˿���
							elseif WAR.QGZT[WAR.Person[emeny]["������"]] ~= nil and WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[emeny]["�ҷ�"] then
								local list = {}
								for q = 0, WAR.PersonNum - 1 do
									if WAR.Person[q]["����"] == false and q ~= WAR.CurID and WAR.Person[q]["�ҷ�"] ~= WAR.Person[emeny]["�ҷ�"] then
										table.insert(list,q)
									end
								end
								local F_target
								if list[1] ~= nil then
									WAR.Person[emeny]["��Ч����"] = 149
									F_target = list[math.random(#list)]
									WAR.NZQK = 3
									WAR.Person[F_target]["��������"] = (WAR.Person[F_target]["��������"] or 0) - War_WugongHurtLife(F_target, wugong, level, ng, x, y)
									WAR.Effect = 2
									SetWarMap(WAR.Person[F_target]["����X"], WAR.Person[F_target]["����Y"], 4, 2)
									WAR.NZQK = 0
								else
									WAR.Person[emeny]["��������"] = (WAR.Person[emeny]["��������"] or 0) - War_WugongHurtLife(emeny, wugong, level, ng, x, y)
									WAR.Effect = 2
									SetWarMap(i, j, 4, 2)
								end
								--�����Ƿ��е��������������Ƿ񷴵���������һ�δ���
								WAR.QGZT[WAR.Person[emeny]["������"]] = WAR.QGZT[WAR.Person[emeny]["������"]] -1
								if WAR.QGZT[WAR.Person[emeny]["������"]] < 1 then
									WAR.QGZT[WAR.Person[emeny]["������"]] = nil
								end
							--���壬���컯��
                                elseif match_ID_awakened(WAR.Person[emeny]["������"], 626, 1) and WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[emeny]["�ҷ�"] and JLSD(0,30,WAR.Person[emeny]["������"]) then
								WAR.ZTHSB = 1
								WAR.ZT_id = emeny
								WAR.ZT_X = WAR.Person[emeny]["����X"]
								WAR.ZT_Y = WAR.Person[emeny]["����Y"]
								local dam = Xishu_max(WAR.Person[emeny]["������"])
								local s = WAR.CurID
								WAR.CurID = emeny
								for f = 0, WAR.PersonNum - 1 do
									if WAR.Person[f]["�ҷ�"] ~= WAR.Person[emeny]["�ҷ�"] and WAR.Person[f]["����"] == false then					
										WAR.TXXS[WAR.Person[f]["������"]] = 1
										WAR.Person[f]["Life_Before_Hit"] = JY.Person[WAR.Person[f]["������"]]["����"]
										JY.Person[WAR.Person[f]["������"]]["����"] = JY.Person[WAR.Person[f]["������"]]["����"] - 50*JY.Person[WAR.Person[f]["������"]]
										WAR.Person[f]["��������"] = (WAR.Person[f]["��������"] or 0) - dam
									end
								end
								--һ�ƣ����ⱻ����
								if JY.Person[65]["����"] <= 0 then
									JY.Person[65]["����"] = 1
								end
								--������
								if JY.Person[129]["����"] <= 0 then
									JY.Person[129]["����"] = 1
								end
								WAR.CurID = s
							else
								WAR.Person[emeny]["��������"] = (WAR.Person[emeny]["��������"] or 0) - War_WugongHurtLife(emeny, wugong, level, ng, x, y)
								WAR.Effect = 2
								SetWarMap(i, j, 4, 2)
							end
							--��˯״̬�ĵ��˻�����
							if WAR.CSZT[WAR.Person[emeny]["������"]] ~= nil then
								WAR.CSZT[WAR.Person[emeny]["������"]] = nil
							end
						end
					end
                    if match_ID(WAR.Person[emeny]["������"], 9965) then
                        JY.Person[WAR.Person[emeny]["������"]]['����̶�'] = 0
                        JY.Person[WAR.Person[emeny]["������"]]['���ճ̶�'] = 0
                        WAR.BFXS[WAR.Person[emeny]["������"]] = nil
                        WAR.ZSXS[WAR.Person[emeny]["������"]] = nil
                    end
				end
			end
		end
    end

	--�޾Ʋ����������Ĵ�����Ч
    local dhxg = JY.Wugong[wugong]["�书����&��Ч"]
    if WAR.LXZQ == 1 then
		dhxg = 71
    elseif WAR.JSYX == 1 then
        dhxg = 84
    elseif WAR.ASKD == 1 then
        dhxg = 65
    elseif WAR.LXBR == 1 then
        dhxg = 65
    elseif WAR.GCTJ == 1 then
        dhxg = 108
    elseif WAR.JSTG == 1 then
        dhxg = 119
    end
	


	--Ѫ����Ѫ������100��

	if WAR.XDLeech > 0 then
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", WAR.XDLeech);
	end
	
	--ΤһЦ��Ѫ10%������100��
	if WAR.WYXLeech > 0 then
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", WAR.WYXLeech);
	end
	
	--��ħ����Ѫ20%
	if WAR.TMGLeech > 0 then
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", WAR.TMGLeech);
	end
	--Ѫ�������Ѫ������100��
	if WAR.XHSJ > 0 then
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", WAR.XHSJ);
	end

	--�޾Ʋ���������Ĺ��������͵�����ʾ
	War_ShowFight(pid, wugong, JY.Wugong[wugong]["�书����"], level, x, y, dhxg, ZHEN_ID)
	
	--�������ޣ�ɱ����������
	if WAR.ZQTL[1] ~= nil then
		local dam = WAR.ZQTL[1]
		local ybid = WAR.ZQTL[2]
		local bpX = WAR.ZQTL[3]
		local bpY = WAR.ZQTL[4]
		
		for i = 1, 4 do
			WAR.ZQTL[i] = nil
		end
		
		local ys_list = {}
		local ys_num = 0
		for i = 0, WAR.PersonNum - 1 do
			if GetWarMap(WAR.Person[i]["����X"], WAR.Person[i]["����Y"], 4) == 1 then
				ys_num = ys_num + 1
				ys_list[ys_num] = {WAR.Person[i]["����X"],WAR.Person[i]["����Y"]}
			end
		end
		
		local yes = 1
		
		while (yes == 1) do
			yes = 0
			WAR.Person[ybid]["����"] = 1
			WAR.Person[ybid]["��Ч����"] = 117
			for i = 0, WAR.PersonNum - 1 do
				if WAR.Person[i]["����"] == nil and WAR.Person[i]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.Person[i]["����"] == false then
					local bdid = WAR.Person[i]["������"]
					local offset1 = math.abs(bpX - WAR.Person[i]["����X"])
					local offset2 = math.abs(bpY - WAR.Person[i]["����Y"])
					if offset1 <= 5 and offset2 <= 5 then
						WAR.Person[i]["��������"] = (WAR.Person[i]["��������"] or 0) - dam
						JY.Person[bdid]["����"] = JY.Person[bdid]["����"] - dam
						--һ�ƣ����ⱻ����
						if JY.Person[65]["����"] <= 0 then
							JY.Person[65]["����"] = 1
						end
						--������
						if JY.Person[129]["����"] <= 0 then
							JY.Person[129]["����"] = 1
						end
						if JY.Person[bdid]["����"] < 0 then
							JY.Person[bdid]["����"] = 0
							yes = 1
							ybid = i
							bpX = WAR.Person[i]["����X"]
							bpY = WAR.Person[i]["����Y"]
						end
						WAR.TXXS[bdid] = 1
					end
				end
			end
			War_ShowFight(-1, 0, 0, 0, 0, 0, 0, 0)
		end
		CleanWarMap(4, 0)
		for i = 1, ys_num do
			SetWarMap(ys_list[i][1], ys_list[i][2], 4, 1)
		end
	end

	--����ҵ��״̬������ʹ�õ�����һ�������
	if WAR.WMYH[pid] ~= nil then
		CurIDTXDH(WAR.CurID, 127,1, "����ҵ��", C_ORANGE)
		local nlDam = math.modf((math.modf((level + 3) / 2) * JY.Wugong[wugong]["������������"])/2)
		WAR.Person[WAR.CurID]["��������"] = (WAR.Person[WAR.CurID]["��������"] or 0) + AddPersonAttrib(pid, "����", -nlDam)
	    --������1��Ѫ
	    if JY.Person[pid]["����"] <= 0 then
			JY.Person[pid]["����"] = 1
	    end
	end

	WAR.PD['����̫��'] = {}
	War_Show_Count(WAR.CurID);		--��ʾ��ǰ�����˵ĵ���
	
	WAR.TFBW = 0		--�����λ�����ּ�¼�ָ�
	WAR.TLDWX = 0		--���޵��������ּ�¼�ָ�
    
	WAR.ZTHSB = 0			--���컯��
	WAR.ZT_id = -1			--�����˵�ID
	WAR.ZT_X = -1			--�����˵�X����
	WAR.ZT_Y = -1			--�����˵�Y����
	
	if WAR.FHJZ == 1 then
		DrawStrBoxWaitKey("���Ǹ����ָ�ϡ����ˣ�", C_ORANGE, CC.DefaultFont, 2)
		WAR.FHJZ = 0
	end
	
    WAR.Person[WAR.CurID]["����"] = WAR.Person[WAR.CurID]["����"] + 2
	
    --�书���Ӿ��������
    if inteam(pid) then
		if JY.Person[pid]["�书�ȼ�" .. wugongnum] < 900 then
			JY.Person[pid]["�书�ȼ�" .. wugongnum] = JY.Person[pid]["�书�ȼ�" .. wugongnum] + 10
		elseif JY.Person[pid]["�书�ȼ�" .. wugongnum] < 999 then
			--JY.Person[pid]["�书�ȼ�" .. wugongnum] = JY.Person[pid]["�书�ȼ�" .. wugongnum] + math.modf(JY.Person[pid]["����"] / 20 + math.random(2)) + rz
			--�޾Ʋ������ջ�һ�ε���
			JY.Person[pid]["�书�ȼ�" .. wugongnum] = JY.Person[pid]["�书�ȼ�" .. wugongnum] + 99;
			--�书����Ϊ��
			if 999 <= JY.Person[pid]["�书�ȼ�" .. wugongnum] then
				JY.Person[pid]["�书�ȼ�" .. wugongnum] = 999
				PlayWavAtk(42)
				DrawStrBoxWaitKey(string.format("%s����%s���Ƿ��켫", JY.Person[pid]["����"], JY.Wugong[JY.Person[pid]["�书" .. wugongnum]]["����"]), C_ORANGE, CC.DefaultFont)

				--���� ��ɽ��÷��Ϊ�������ʱ��50
				if match_ID(pid, 49) and wugong == 14 then
					say("��ң�ɵ���ѧ��Ȼ�������Сɮ�������ඥ֮�С�", 49, 0);
					DrawStrBoxWaitKey("�������ʸı䣡", C_ORANGE, CC.DefaultFont)
					set_potential(49, 50)
				end
				
				--���� ���չ�Ϊ���������Ṧ20��
				if match_ID(pid, 37) and wugong == 94 then
					say("���վ����������֫�ٺ��о�������ӯ������磬��һ����������ʧ���ģ�", 37, 0);
					DrawStrBoxWaitKey("�����������վ������裬�Ṧ�Ӷ�ʮ", C_ORANGE, CC.DefaultFont)
					AddPersonAttrib(pid, "�Ṧ", 20)
				end
				
				--��쳣����ҵ�������������10��ˣ������
				if match_ID(pid, 1) and wugong == 67 then
					say("��������Խ��Խ���", 1, 0);
					DrawStrBoxWaitKey("��쳹��������ᡢˣ�����ɸ�����10��", C_ORANGE, CC.DefaultFont)
					AddPersonAttrib(pid, "������", 10)
					AddPersonAttrib(pid, "������", 10)
					AddPersonAttrib(pid, "�Ṧ", 10)
					AddPersonAttrib(pid, "ˣ������", 10)
				end
			end
		end
			
		--�书������ͨ�ȼ�
		if level < math.modf(JY.Person[pid]["�书�ȼ�" .. wugongnum] / 100) + 1 then
			level = math.modf(JY.Person[pid]["�书�ȼ�" .. wugongnum] / 100) + 1
			for i = 1,10 do
				Cat('ʵʱ��Ч����')
				Cls()
				DrawStrBox(-1, -1, string.format("%s ��Ϊ %d ��", JY.Wugong[JY.Person[pid]["�书" .. wugongnum]]["����"], level), C_ORANGE, CC.DefaultFont)
				ShowScreen()
				lib.Delay(CC.BattleDelay)
			end
		end
    end
  
    --�ҷ������ĵ�����
    if WAR.Person[WAR.CurID]["�ҷ�"] then
		local nl = nil
	
		nl = math.modf((level + 3) / 2) * JY.Wugong[wugong]["������������"]
		
		--����������������
		--����
		if Curr_NG(pid, 99) then
			nl = math.modf(nl*0.4);
		--����
		elseif PersonKF(pid, 99) then
			nl = math.modf(nl*0.5);
		end
	    if PersonKF(pid, 43) then
		   nl = math.modf(nl*0.7)
		end  
		--�������˾���������70%����
		if Curr_NG(pid, 106) and (JY.Person[pid]["��������"] == 1 or JY.Person[pid]["��������"] == 3) then
			nl = math.modf(nl*0.3);
		end
		
		--�Ƿ彵�����ļ���
		if match_ID(pid, 50) and wugong == 26 then
			nl = math.modf(nl/2);
		end	
		
		--ʯ������Ѻ�̫�����ļ���
		if match_ID_awakened(pid, 38, 1) and wugong == 102 then
			nl = math.modf(nl/2);
		end
		  
		--�����������ļ���
		if match_ID(pid, 53) and wugong == 49 then
			nl = math.modf(nl/2);
		end

		--ָ�������������ļ���
		if pid == 0 and JY.Base["��׼"] == 2 and wugong == 49 then
			nl = math.modf(nl/2);
		end
		  
		--���⹥����ֻ����һ������
		if Given_WG(pid, wugong) then
			nl = math.modf(nl/2);
		end
		
		--�ܲ�ͨ�۽��������������ļ���50%
		if pid == 0 and JY.Person[64]["�۽�����"] == 1 then
			nl = math.modf(nl/2)
		end

		AddPersonAttrib(pid, "����", -(nl))
	--NPC�ĺ���
	else
		AddPersonAttrib(pid, "����", -math.modf((level + 3) / 2) * JY.Wugong[wugong]["������������"]/7*2)
    end
  
    if JY.Person[pid]["����"] < 0 then
		JY.Person[pid]["����"] = 0
    end
    
    if JY.Person[pid]["����"] <= 0 then
		break;
    end
 
   
	
	--�޾Ʋ�������ɱ���Ķ�̬��ʾ
  	DrawTimeBar2()
	

	--̫��ȭ�������������������
	--�����᲻���
	--if Curr_NG(pid,171) and (wugong == 16 or wugong == 46)  and WAR.PD["̫������"][pid] ~= nil and WAR.PD["̫������"][pid] > 0 and match_ID(pid, 5) == false then
	    
		--WAR.PD["̫������"][pid] = 0
	--end

	WAR.ACT = WAR.ACT + 1   --ͳ�ƹ��������ۼ�1
 		
  	--�����壺������Χ�ڵĵ���ȫ������ʱȡ������
  	local flag = 0;
  	local n = 0;
    for i = 0, CC.WarWidth - 1 do
		for j = 0, CC.WarHeight - 1 do
			lib.GetKey()
			local effect = GetWarMap(i, j, 4)
			if 0 < effect then
				local emeny = GetWarMap(i, j, 2)
				if 0 <= emeny and WAR.Person[id]["�ҷ�"] ~= WAR.Person[emeny]["�ҷ�"] then
					n = n + 1;
					if JY.Person[WAR.Person[emeny]["������"]]["����"] > 0 then
						flag = 1;
					end
				end
    		end
    	end
    end
	
	--�޾Ʋ����������ز����ж�����
    if flag == 0 and n > 0 and match_ID(pid, 2) == false then
    	break
    end

	--����̫���񹦣�̫��֮����������
	if Curr_NG(pid, 171) and  WAR.TJZX[pid] ~= nil and WAR.TJZX[pid] >= 5 then
		WAR.ATNum = WAR.ATNum + 1
		WAR.TJZX[pid] = WAR.TJZX[pid] - 5
		WAR.TJZX_LJ = 1
	end
	
	--if match_ID(pid,9994) then 
		if WAR.PD['��������'][pid] ~= nil then
			if WAR.PD['��������'][pid].s == 1 and WAR.PD['��������'][pid].n < 3 then
				WAR.ATNum = WAR.ATNum + 1
				WAR.PD['��������'][pid].s = nil
			end
		end
	--end
    
end

----------------״̬���-----------------
	--���������ж�ȡ��
	WAR.TWLJ = 0
	WAR.DJJJ_LJ = 0
	--��Ȼ���ⷶΧ�ָ�
	WAR.ARJY = 0
	WAR.ARJY1 = 0		--��Ȼ����	
	--���������ָ�
	WAR.YLTW = 0	
	--�������ⷶΧ�ָ�
	WAR.JYSZ = 0
	--��������1��Χ�ָ�
	WAR.JYSZ1 = 0
   
	WAR.PD["��������"][pid] = nil
	
	--���Ƴ������Ǽ����ָ�
	WAR.CXLC_Count = 0
	--���������ָ�
	WAR.WLLJ_Count = 0
	--��ң��������ָ�
	WAR.YFCS = 0
	WAR.MHSN = 0
	--��������

	--̫��ȭ�������������������
	--���������������
	if (wugong == 16 or wugong == 46 ) and  WAR.PD["̫������"][pid] ~= nil and WAR.PD["̫������"][pid] > 0  then
		if match_ID(pid, 5) then
			WAR.PD["̫������"][pid] = math.modf( WAR.PD["̫������"][pid]/2)
		else	
			WAR.PD["̫������"][pid] = 0
		end
	end	

	--�����������תǬ����ǿ������Ч����������ָ�
	if WAR.NZQK > 0 then
		WAR.NZQK = 0
	end
  
	--�������ĵ�����
	local jtl = 0
	if 1100 <= WAR.WGWL then
		jtl = 7
	elseif 900 <= WAR.WGWL then
		jtl = 5
	elseif 600 <= WAR.WGWL then
		jtl = 3
	else
		jtl = 1
	end
	
	--�ܲ�ͨ�۽��������������ļ���50%
	if pid == 0 and JY.Person[64]["�۽�����"] == 1 then
		jtl = math.modf(jtl/2)
		if jtl < 1 then
			jtl = 1
		end
	end
       --�������ļ���50%
	if pid == 0  then
		jtl = math.modf(jtl/2)
		if jtl < 1 then
			jtl = 1
		end
	end
	 if PersonKF(pid, 43) then
		   jtl = math.modf(jtl*0.3)
		if jtl < 1 then
			jtl = 1
		end
	end	
	--װ����¿ �����ٶ�+5��
		if JY.Person[id]["����"] == 339 then
				jtl = jtl - 2
		if jtl < 1 then
			jtl = 1
		end
	end
	--̫������������������2��
	if PersonKF(pid, 102) then
		jtl = jtl - 2
		if jtl < 1 then
			jtl = 1
		end
	end

	--�˳��ӹ�������������
	--NPCֻ����1��
	if match_ID(pid, 89) == false then
		if WAR.Person[WAR.CurID]["�ҷ�"] then
			AddPersonAttrib(pid, "����", -(jtl))
		else
			AddPersonAttrib(pid, "����", -1);
		end
	end
    

	
	--��ת���Ƽ���
	local dz = {}
	local dznum = 0
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["�����书"] ~= -1 and WAR.Person[i]["�����书"] ~= 9999 then --��������书��Ϊ��ֵ �ͣ�
			dznum = dznum + 1  --��ת = ��ת +1 
			dz[dznum] = {i, WAR.Person[i]["�����书"], x - WAR.Person[WAR.CurID]["����X"], y - WAR.Person[WAR.CurID]["����Y"]} -- ��ת���� = �����书 x Y���귶Χ��
			WAR.Person[i]["�����书"] = 9999
		end
	end
	for i = 1, dznum do
		local tmp = WAR.CurID
		WAR.CurID = dz[i][1]
		WAR.DZXY = 1
		if WAR.DZXYLV[WAR.Person[WAR.CurID]["������"]] == 1 then
			WAR.DZXYLV[WAR.Person[WAR.CurID]["������"]] = 60
		elseif WAR.DZXYLV[WAR.Person[WAR.CurID]["������"]] == 2 then
			WAR.DZXYLV[WAR.Person[WAR.CurID]["������"]] = 85
		elseif WAR.DZXYLV[WAR.Person[WAR.CurID]["������"]] == 3 then
			WAR.DZXYLV[WAR.Person[WAR.CurID]["������"]] = 110
		elseif WAR.DZXYLV[WAR.Person[WAR.CurID]["������"]] == 5 then     --���Ź�Ԫ��������
			WAR.DZXYLV[WAR.Person[WAR.CurID]["������"]] = 100
		elseif WAR.DZXYLV[WAR.Person[WAR.CurID]["������"]] == 4 then	--�޾Ʋ��������Ӷ�ת���Ĳ�
			WAR.DZXYLV[WAR.Person[WAR.CurID]["������"]] = 115
		end
        if WAR.AutoFight == 1 or WAR.Person[WAR.CurID]['�ҷ�'] == false or WAR.ZDDH == 354 or JY.Person[WAR.Person[WAR.CurID]['������']]['����'] <= 79 then
            War_Fight_Sub(dz[i][1], dz[i][2] + 100, dz[i][3], dz[1][4])
        else 
            War_Fight_Sub(dz[i][1], dz[i][2] + 100)
        end
		WAR.Person[WAR.CurID]["�����书"] = -1
		WAR.DZXYLV[WAR.Person[WAR.CurID]["������"]] = nil
		WAR.CurID = tmp
		WAR.DZXY = 0
	end 
		fjtx()
	if JY.Restart == 1 then
		return 1
	end
	WAR.PD['��������'][pid] = {}
    
    if WAR.PD['������˫��ȡˮ'][pid] ~= nil and WAR.PD['������˫��ȡˮ'][pid] == 1 then
        WAR.PD['������˫��ȡˮ'][pid] = 2
        WAR.Person[WAR.CurID]['�ƶ�����'] = 0
        if WAR.AutoFight == 1 or WAR.Person[WAR.CurID]['�ҷ�'] == false or WAR.ZDDH == 354 then
            Cat('�Զ�����',wugongnum)
        else
            War_Fight_Sub(WAR.CurID, wugongnum)
        end
        WAR.PD['������˫��ȡˮ'][pid] = nil
    end
	return 1;
end

--�޾Ʋ�����ѡ���ƶ�
--����7*7����ʾflag
function War_SelectMove(flag)
	local x0 = WAR.Person[WAR.CurID]["����X"]
	local y0 = WAR.Person[WAR.CurID]["����Y"]
	local x = x0
	local y = y0
	if flag ~= nil then
		CleanWarMap(7, 0)
	end
	while true do
		if JY.Restart == 1 then
			break
		end
		local x2 = x
		local y2 = y
		
		Cat('ʵʱ��Ч����')
	
		WarDrawMap(1, x, y)
		
		if flag ~= nil then
			for i = 1, 4 do
				for j = 1, 4 do
					SetWarMap(x + i - 1, y + j - 1, 7, 1)
					SetWarMap(x - i + 1, y + j - 1, 7, 1)
					SetWarMap(x + i - 1, y - j + 1, 7, 1)
					SetWarMap(x - i + 1, y - j + 1, 7, 1)
				end
			end
			WarDrawMap(1, x, y)
		end
		
		WarShowHead(GetWarMap(x, y, 2))
		
		--����ʱ��ʾ������
		if WAR.FLHS5 == 2 then
			DrawTimeBar_sub()
		end
	
		ShowScreen()
		
		if flag ~= nil then
			CleanWarMap(7, 0)
		end
	
		lib.Delay(CC.BattleDelay)
		local key, ktype, mx, my = lib.GetKey()
		if key == VK_UP then
			y2 = y - 1
		elseif key == VK_DOWN then
			y2 = y + 1
		elseif key == VK_LEFT then
			x2 = x - 1
		elseif key == VK_RIGHT then
			x2 = x + 1
		elseif key == VK_SPACE or key == VK_RETURN then
			return x, y
		elseif key == VK_ESCAPE or ktype == 4 then
			return nil
		elseif ktype == 2 or ktype == 3 then
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
			mx = math.modf(mx)
			my = math.modf(my)
			for i = 0, 10 do
				if mx + i <= 63 then
					if my + i > 63 then
						break;
					end
				end
				local hb = GetS(JY.SubScene, x0 + mx + i, y0 + my + i, 4)

				if math.abs(hb - CC.YScale * i * 2) < 5 then
					mx = mx + i
					my = my + i
				end
			end
			x2, y2 = mx + x0, my + y0
			  
			if ktype == 3 then
				return x, y
			end
		end
    
		--�޾Ʋ�������������
		if GetWarMap(x2, y2, 3) ~= nil and GetWarMap(x2, y2, 3) < 128 then
			x = x2
			y = y2
		end
	end
end

--��ȡ�书��С����
function War_GetMinNeiLi(pid)
	local minv = math.huge
	for i = 1, JY.Base["�书����"] do
		local tmpid = JY.Person[pid]["�书" .. i]
		if tmpid > 0 and JY.Wugong[tmpid]["������������"] < minv then
			minv = JY.Wugong[tmpid]["������������"]
		end
	end
	return minv
end

--�޾Ʋ������ֶ�ս���˵��ϼ�
function War_Manual()
	local r = nil
    local pid = WAR.Person[WAR.CurID]['������']
    if WAR.HLZT[pid] ~= nil then
        Cat('����ƶ�')
    end
	local x, y, move, pic, face_dir = WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], WAR.Person[WAR.CurID]["�ƶ�����"], WAR.Person[WAR.CurID]["��ͼ"], WAR.Person[WAR.CurID]["�˷���"]
	while true do
		if JY.Restart == 1 then
			break
		end
		WAR.ShowHead = 1
		--r = War_Manual_Sub()
		r = Cat('ս���˵�')
		--�ƶ�������ʵ�ʷ��ص�Ӧ����-1
		if r == 1 or r == -1 then
			--WAR.Person[WAR.CurID]["�ƶ�����"] = 0 
		--ESC����
		elseif r == 0 then
			SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, -1)
			SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, -1)
            SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, -1)
			WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], WAR.Person[WAR.CurID]["�ƶ�����"] = x, y, move
			SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, WAR.CurID)
			SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, pic)
            SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, JY.Person[WAR.Person[WAR.CurID]["������"]]['ͷ�����'])
			--�޾Ʋ�������������ҲҪ��ԭ
			WAR.Person[WAR.CurID]["�˷���"] = face_dir
		elseif r == 20 then
	
		else
			break;
		end
	end
	WAR.ShowHead = 0
	WarDrawMap(0)
	return r	--�޾Ʋ���������ķ���ֵ�ƺ�ûʲô����
end

function WarTitleSelection()
	local choice = 1
	local buttons ={
	{967,971,100,0,200,0},
	{968,972,100,40,220,40},
	{969,973,100,80,200,80},
	{970,974,100,120,200,120},
	{970,974,100,160,200,160},
	{970,974,100,200,200,200},
	{970,974,100,240,200,240},
	{970,974,100,280,200,280},	
	}
	local function on_button(mx, my)
		local r = 0
			for i = 1, #buttons do
				if mx >= buttons[i][4] and mx <= buttons[i][6] and my >= buttons[i][5] and my <= buttons[i][7] then
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
			if (ktype == 2 or ktype == 3 or ktype == 4 or ktype == 5 or ktype == 6 or ktype == 7 or ktype == 7) then
				local r = on_button(mx, my)
				if r > 0 then
					choice = r
				end
			end
			if keypress == VK_RETURN or (ktype == 9 and on_button(mx, my)>0) then
				break
			end
		end
		Cls()
		for i = 1, #buttons do
			local picid = buttons[i][1]
			if i == choice then
				picid = buttons[i][2]
			end
			lib.LoadPNG(1, picid * 2 , buttons[i][3], buttons[i][4], 1)
		end
		ShowScreen()
		lib.Delay(CC.BattleDelay)
	end
	return choice
end

	      
--�ֶ�ս���˵�
function War_Manual_Sub()
	local pid = WAR.Person[WAR.CurID]["������"]
	--local isEsc = 0
	
	local warmenu = {
	{"�ƶ�", War_MoveMenu, 1},	--1
	{"����", War_FightMenu, 1},	--2
	{"�˹�", War_YunGongMenu, 1},	--3
	{"ս��", War_TacticsMenu, 1},	--4
     {"����", War_OtherMenu, 1},	--13  --5		

	{"��ɫ", War_TgrtsMenu, 1},	--11 --6
	{"����", War_Retreat, 1},	--12  --7
	{"�Զ�", War_AutoMenu, 1}	--13  --8
	
	}
  	--[[ 
   local warmenu = WarTitleSelection()
	if warmenu == 1 then
	War_MoveMenu()
	end
	if warmenu == 2 then
	War_FightMenu()
	end
	if warmenu == 3 then
	War_YunGongMenu()
	end
	if warmenu == 4 then
	War_TacticsMenu()
	end
	if warmenu == 5 then
	War_OtherMenu()
	end	
	if warmenu == 6 then
	War_TgrtsMenu()
	end	
	if warmenu == 7 then
	War_Retreat()
	end	
	if warmenu == 8 then
	War_AutoMenu()
	end		
]]
	--��ɫָ��
	
	if JY.Person[pid]["��ɫָ��"] == 1 then
		--����ǳ���
		if pid == 0 then
			warmenu[6][1] = GRTS[JY.Base["����"]]
		else
			warmenu[6][1] = GRTS[pid]
		end
	else
		warmenu[6][3] = 0
	end
  
	--����
	if match_ID(pid, 49) then
		--���û��������������������ʾ��ɫָ��
		local t = 0
		for i = 0, WAR.PersonNum - 1 do
			local wid = WAR.Person[i]["������"]
			if WAR.TZ_XZ_SSH[wid] == 1 and WAR.Person[i]["����"] == false then
				t = 1
			end
		end
		if t == 0 then
			warmenu[6][3] = 0
		end
		--����С��20����ʾ��ɫָ��
		if JY.Person[pid]["����"] < 20 then
			warmenu[6][3] = 0
		end
	end
  
	--��ǧ��
	if match_ID(pid, 88) then
		--�����Χû�ж��Ѳ���ʾ��ɫָ��
		local yes = 0
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["�ҷ�"] == true and WAR.Person[i]["����"] == false and RealJL(WAR.CurID, i, 5) and i ~= WAR.CurID then
				yes = 1
			end
		end
		if yes == 0 then
			warmenu[6][3] = 0
		end
		--����С��20����ʾ��ɫָ��
		--����С��1000����ʾ
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 then
			warmenu[6][3] = 0
		end
	end

	--�˳���
	if match_ID(pid, 89) then
		--�����Χû�ж��Ѳ���ʾ��ɫָ��
		local px, py = WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"]
		local mxy = {
					{WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"] + 1}, 
					{WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"] - 1}, 
					{WAR.Person[WAR.CurID]["����X"] + 1, WAR.Person[WAR.CurID]["����Y"]}, 
					{WAR.Person[WAR.CurID]["����X"] - 1, WAR.Person[WAR.CurID]["����Y"]}}

		local yes = 0
		for i = 1, 4 do
			if GetWarMap(mxy[i][1], mxy[i][2], 2) >= 0 then
			local mid = GetWarMap(mxy[i][1], mxy[i][2], 2)
			if inteam(WAR.Person[mid]["������"]) then
				yes = 1
				end
			end  
		end
		if yes == 0 then
			warmenu[6][3] = 0
		end
		--����С��25����ʾ��ɫָ��
		if JY.Person[pid]["����"] < 25 then
			warmenu[6][3] = 0
		end
	end

	--���޼�
	if match_ID(pid, 9) then
		--�����Χû�ж��Ѳ���ʾ��ɫָ��
		local yes = 0
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["�ҷ�"] == true and WAR.Person[i]["����"] == false and RealJL(WAR.CurID, i, 8) and i ~= WAR.CurID then
				yes = 1
			end
		end
		if yes == 0 then
			warmenu[6][3] = 0
		end
		--����С��20����ʾ��ɫָ��
		if JY.Person[pid]["����"] < 20 then
			warmenu[6][3] = 0
		end
	end
 
	--����ָͩ��ָ��
	if match_ID(pid, 74) then
		--����С��10����ʾ��ɫָ��
		if JY.Person[pid]["����"] < 10 or JY.Person[pid]["����"] < 150 or  WAR.HQT_CD > 0 then
			warmenu[6][3] = 0
		end
	end
	
	--Ľ�ݸ�ָ�� ����
	if match_ID(pid, 51) then
		--����С��20����ʾ��ɫָ��
		if JY.Person[pid]["����"] < 20 then
			warmenu[6][3] = 0
		end
	end

	--С��ָ�� Ӱ��
	if match_ID(pid, 66) then
		--����С��30��������С��2000����ʾ��ɫָ��
		if JY.Person[pid]["����"] < 30 or JY.Person[pid]["����"] < 2000 then
			warmenu[6][3] = 0
		end
	end
  
	--����ָ�� ����
	if match_ID(pid, 90) then
		--����С��10����ʾ��ɫָ��
		if JY.Person[pid]["����"] < 10 then
			warmenu[6][3] = 0
		end
	end
	
	--����ָ�� ��װ
	if match_ID(pid, 92) then
		--����С��20����ʾ��ɫָ��
		if JY.Person[pid]["����"] < 20 then
			warmenu[6][3] = 0
		end
	end
	--����� ֹɱ
	if match_ID(pid, 68) then
		--����С��20����ʾ��ɫָ��
		if JY.Person[pid]["����"] < 20 or WAR.JSZT1[pid]> 0 then
			warmenu[6][3] = 0
		end
	end	
	--���ָ�� �ɺ�
	if match_ID(pid, 1) then
		--����С��20����ʾ��ɫָ��
		if JY.Person[pid]["����"] < 20 then
			warmenu[6][3] = 0
		end
	end
	
	--�Ħ��ָ�� �û�
	if match_ID(pid, 103) then
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 then
			warmenu[6][3] = 0
		end
	end
	
	--�����ָ�� ��ս
	if match_ID(pid, 160) then
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 or WAR.SZSD ~= -1 then
			warmenu[6][3] = 0
		end
	end
	
	--���� ����
	if match_ID(pid, 62) then
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 then
			warmenu[6][3] = 0
		end
	end
	
	--���� �ݼ�
	if match_ID(pid, 56) then
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 then
			warmenu[6][3] = 0
		end
	end
	
	--ΤС�� �ڲ�
	if match_ID(pid, 601) then
		if JY.Person[pid]["����"] < 30 then
			warmenu[6][3] = 0
		end
	end
	
	--���˷� �ƾ�
	if match_ID(pid, 3) then
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 then
			warmenu[6][3] = 0
		end
	end
	
	--��̫�� ����
	if match_ID(pid, 7) then
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 then
			warmenu[6][3] = 0
		end
	end
	

	--��Ѱ�� �ɵ�
	if match_ID(pid, 498) then
		if  JY.Person[pid]["����"] < 1000 then
			warmenu[6][3] = 0
		end
	end	
	--����ˮ �콣
	if match_ID(pid, 652) and JY.Base["��������"] < 7 then
			warmenu[6][3] = 0
		end
	
	--�ֻ� ����
	if match_ID(pid, 4) then	
		if JY.Person[pid]["����"] < 20 then
			warmenu[6][3] = 0
		end
	end

	--������ʱ���ƶ����ⶾ��ҽ�ƣ���Ʒ����ɫ���Զ����ɼ�
	if WAR.ZYHB == 2 then
		warmenu[1][3] = 0
		warmenu[5][3] = 0	
		warmenu[8][3] = 0
	end
  
	--����С��5�����Ѿ��ƶ���ʱ���ƶ����ɼ�
	if JY.Person[pid]["����"] <= 5 or WAR.Person[WAR.CurID]["�ƶ�����"] <= 0 then
		warmenu[1][3] = 0
		--isEsc = 1
	end
  
	--�ж���С�������Ƿ����ʾ����
	local minv = War_GetMinNeiLi(pid)
	if JY.Person[pid]["����"] < minv or JY.Person[pid]["����"] < 10 then
		warmenu[2][3] = 0
	end

	lib.GetKey()
	Cls()
	DrawTimeBar_sub()
	return Cat('�˵�',warmenu, #warmenu, 0, CC.MainMenuX, CC.MainMenuY, 0, 0, 1, 1, CC.DefaultFont, C_ORANGE, C_WHITE)
	
end

--�޾Ʋ������˹�ѡ��˵�
function War_YunGongMenu()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	local id = WAR.Person[WAR.CurID]["������"]
	local menu={};
	menu[1]={"�����ڹ�",SelectNeiGongMenu,1};
	--menu[2]={"ͣ���ڹ�",nil,1};
	menu[2]={"�����Ṧ",SelectQingGongMenu,1};
	--menu[4]={"ͣ���Ṧ",nil,1};
	local r =  Cat('�˵�',menu,#menu,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
   -- local r = Cat('�˵�',menu,#menu,0,CC.MainMenuX, CC.MainMenuY,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);	
	if r == 0 then 
		return 0
	end	
	local r1 = menu[r][2]()
	if r1 == 2 then
		JY.Person[id]["�����ڹ�"] = 0
		DrawStrBoxWaitKey(JY.Person[id]["����"].."ֹͣ���������ڹ�",C_RED,CC.DefaultFont,nil,LimeGreen)
		return 20;
	elseif r1 == 20 then
		return 20;
	elseif r1 == 4 then
		JY.Person[id]["�����Ṧ"] = 0
		DrawStrBoxWaitKey(JY.Person[id]["����"].."ֹͣ���������Ṧ",M_DeepSkyBlue,CC.DefaultFont,nil,LimeGreen)
		return 20;
	elseif r1 == 10 then
		return 10;
	end
end

--�޾Ʋ�����ѡ���ڹ��˵�
function SelectNeiGongMenu()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	local id, x1, y1 = WAR.Person[WAR.CurID]["������"], WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"]
	local menu={};
	local a = 0
	for i=1,JY.Base["�书����"] do
        menu[i]={JY.Wugong[JY.Person[id]["�书" .. i]]["����"],nil,0};
		if JY.Wugong[JY.Person[id]["�书" .. i]]["�书����"] == 6 then
			menu[i][3]=1;
		end
		--�����������
		if (id == 0 and JY.Base["��׼"] == 6)
		and (JY.Person[id]["�书" .. i] == 106 or JY.Person[id]["�书" .. i] == 107 or JY.Person[id]["�书" .. i] == 108) then
			menu[i][3]=0;	
		end
		--��������������
		--if JY.Person[id]["�书" .. i] == 175 then
		--	menu[i][3]=0
		--end
		if menu[i][3] == 1 then 
			a = 1
		end
	end
	if a == 0 then 
		return 0
	end
	local main_neigong =  Cat('�˵�',menu,#menu,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
   -- local main_neigong =  Cat('�˵�',menu,#menu,0,CC.MainMenuX, CC.MainMenuY,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);
	if main_neigong ~= nil and main_neigong > 0 then
		CleanWarMap(4, 0)
		SetWarMap(x1, y1, 4, 1)
		War_ShowFight(id, 0, 0, 0, 0, 0, 9)	
		AddPersonAttrib(id, "����", -200);
		AddPersonAttrib(id, "����", -5);
		JY.Person[id]["�����ڹ�"] = JY.Person[id]["�书" .. main_neigong]
		Hp_Max(id)
		return 20;
	end
end



--�޾Ʋ�����ѡ���Ṧ�˵�
function SelectQingGongMenu()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	local id, x1, y1 = WAR.Person[WAR.CurID]["������"], WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"]
	local menu={};
	local a = 0
	for i=1,JY.Base["�书����"] do
        menu[i]={JY.Wugong[JY.Person[id]["�书" .. i]]["����"],nil,0};
		if JY.Wugong[JY.Person[id]["�书" .. i]]["�书����"] == 7 then
			menu[i][3]=1;
		end
		if menu[i][3] == 1 then 
			a = 1
		end
	end
	if a == 0 then 
		return 0
	end
	local main_qinggong =  Cat('�˵�',menu,#menu,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
   -- local main_qinggong =  Cat('�˵�',menu,#menu,0,CC.MainMenuX, CC.MainMenuY,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);
	if main_qinggong ~= nil and main_qinggong > 0 then
		CleanWarMap(4, 0)
		SetWarMap(x1, y1, 4, 1)
		War_ShowFight(id, 0, 0, 0, 0, 0, 9)	
		AddPersonAttrib(id, "����", -10);
		WAR.YQG = 1
		JY.Person[id]["�����Ṧ"] = JY.Person[id]["�书" .. main_qinggong]
		return 10;
	end
end

--�޾Ʋ�����ս���˵�
function War_TacticsMenu()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	local menu={};
	menu[1]={"������",nil,1};
	menu[2]={"������",nil,1};
	menu[3]={"�ȴ���",nil,1};
	menu[4]={"���У�",nil,1};
	menu[5]={"��Ϣ��",nil,1};	
	local r =  Cat('�˵�',menu,10,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1,LimeGreen)
   -- local r = Cat('�˵�',menu,#menu,0,CC.MainMenuX, CC.MainMenuY,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);
	--����
	if r == 1 then
		return War_ActupMenu()
	--����
	elseif r == 2 then
		return War_DefupMenu()
	--�ȴ�
	elseif r == 3 then
		return War_Wait()
	--����
	elseif r == 4 then
		return War_Focus()
	--��Ϣ
	elseif r == 5then
		return War_RestMenu()
	--��ݼ��Ķ����ж�	
	elseif r == 6 then
		return 1
	--��ݼ��Ķ����ж�
	elseif r == 7 then
		return 20
	end
end

--�޾Ʋ����������˵�
function War_OtherMenu()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	local menu={};
	menu[1]={"�ö���",nil,1};
	menu[2]={"�ⶾ��",nil,1};
	menu[3]={"ҽ�ƣ�",nil,1};
	--menu[4]={"��Ʒ",nil,1};
	menu[4]={"״̬��",nil,1};	
	local r =  Cat('�˵�',menu,#menu,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1,LimeGreen)
   -- local r = Cat('�˵�',menu,#menu,0,CC.MainMenuX, CC.MainMenuY,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);
	
	--�ö�
	if r == 1 then
		return War_PoisonMenu()
	--�ⶾ
	elseif r == 2 then
		return War_DecPoisonMenu()
	--ҽ��
	elseif r == 3 then
		return War_DoctorMenu()
	--��Ʒ
	--elseif r == 4 then
		--return  War_ThingMenu()
	--״̬
	elseif r == 4 then
		return  Ckstatus()		
	--��ݼ��Ķ����ж�
	elseif r == 6 then
		return 1
	--��ݼ��Ķ����ж�
	elseif r == 7 then
		return 20
	end
end

--�����书
function War_PersonTrainBook(pid)
  local p = JY.Person[pid]
  local thingid = p["������Ʒ"]
  if thingid < 0 then
    return 
  end
  JY.Thing[101]["����������"] = 1
  JY.Thing[123]["��ȭ�ƹ���"] = 1
  local wugongid = JY.Thing[thingid]["�����书"]
  local wg = 0
  if JY.Person[pid]["�书" .. JY.Base["�书����"]] > 0 and wugongid >= 0 then
    for i = 1, JY.Base["�书����"] do
      if JY.Thing[thingid]["�����书"] == JY.Person[pid]["�书" .. i] then
        wg = 1
      end
    end
  if wg == 0 then		--�޸���һ�汾�����������书��BUG
  	return 
	end
  end
  
  
	local yes1, yes2, kfnum = false, false, nil
	while true do 
		local needpoint = TrainNeedExp(pid)
		if needpoint <= p["��������"] then
			yes1 = true
			AddPersonAttrib(pid, "�������ֵ", JY.Thing[thingid]["���������ֵ"])
			--����Ѫ����������
			--���Ʋ���
			if thingid == 139 and match_ID(pid, 37) == false then
				AddPersonAttrib(pid, "�������ֵ", -15)
				AddPersonAttrib(pid, "����", -15)
				if JY.Person[pid]["�������ֵ"] < 1 then
					JY.Person[pid]["�������ֵ"] = 1
				end
			end
			if JY.Person[pid]["����"] < 1 then
				JY.Person[pid]["����"] = 1
			end
			--������С�ޣ���ڤ������
			if JY.Thing[thingid]["�ı���������"] == 2 and JY.Person[pid]["��������"] ~= 3 then
				if thingid == 75 or thingid == 64 then
					if pid ~= 0 then
						p["��������"] = 2
					end
				else
					p["��������"] = 2
				end
			end
			
	    if match_ID(pid, 588)   then		--��� ˫������ֵ
            AddPersonAttrib(pid, "�������ֵ", JY.Thing[thingid]["���������ֵ"])
			AddPersonAttrib(pid, "������", JY.Thing[thingid]["�ӹ�����"] * 2)
			AddPersonAttrib(pid, "�Ṧ", JY.Thing[thingid]["���Ṧ"] * 2)
			AddPersonAttrib(pid, "������", JY.Thing[thingid]["�ӷ�����"] * 2)
			AddPersonAttrib(pid, "ҽ������", JY.Thing[thingid]["��ҽ������"])
			AddPersonAttrib(pid, "�ö�����", JY.Thing[thingid]["���ö�����"])
			AddPersonAttrib(pid, "�ⶾ����", JY.Thing[thingid]["�ӽⶾ����"])
			AddPersonAttrib(pid, "��������", JY.Thing[thingid]["�ӿ�������"])
		else 
		    AddPersonAttrib(pid, "�������ֵ", JY.Thing[thingid]["���������ֵ"])
			AddPersonAttrib(pid, "������", JY.Thing[thingid]["�ӹ�����"])
			AddPersonAttrib(pid, "�Ṧ", JY.Thing[thingid]["���Ṧ"])
			AddPersonAttrib(pid, "������", JY.Thing[thingid]["�ӷ�����"])
			AddPersonAttrib(pid, "ҽ������", JY.Thing[thingid]["��ҽ������"])
			AddPersonAttrib(pid, "�ö�����", JY.Thing[thingid]["���ö�����"])
			AddPersonAttrib(pid, "�ⶾ����", JY.Thing[thingid]["�ӽⶾ����"])
			AddPersonAttrib(pid, "��������", JY.Thing[thingid]["�ӿ�������"])
			end
			if match_ID(pid, 56) or match_ID(pid, 77)   then		--���� ���л� ˫������ֵ
				AddPersonAttrib(pid, "ȭ�ƹ���", JY.Thing[thingid]["��ȭ�ƹ���"] * 2)
				AddPersonAttrib(pid, "ָ������", JY.Thing[thingid]["��ָ������"] * 2)
				AddPersonAttrib(pid, "��������", JY.Thing[thingid]["����������"] * 2)
				AddPersonAttrib(pid, "ˣ������", JY.Thing[thingid]["��ˣ������"] * 2)
				AddPersonAttrib(pid, "�������", JY.Thing[thingid]["���������"] * 2)
			else
				AddPersonAttrib(pid, "ȭ�ƹ���", JY.Thing[thingid]["��ȭ�ƹ���"])
				AddPersonAttrib(pid, "ָ������", JY.Thing[thingid]["��ָ������"])
				AddPersonAttrib(pid, "��������", JY.Thing[thingid]["����������"])
				AddPersonAttrib(pid, "ˣ������", JY.Thing[thingid]["��ˣ������"])
				AddPersonAttrib(pid, "�������", JY.Thing[thingid]["���������"])
			end
			
			AddPersonAttrib(pid, "��������", JY.Thing[thingid]["�Ӱ�������"])
			AddPersonAttrib(pid, "��ѧ��ʶ", JY.Thing[thingid]["����ѧ��ʶ"])
			AddPersonAttrib(pid, "Ʒ��", JY.Thing[thingid]["��Ʒ��"])
			AddPersonAttrib(pid, "��������", JY.Thing[thingid]["�ӹ�������"])
			if JY.Thing[thingid]["�ӹ�������"] == 1 then
			   p["���һ���"] = 1
			end
			if thingid == 372 then
			   p["��ӹ"] = 1
			end
			p["��������"] = p["��������"] - needpoint

			if wugongid >= 0 then 
				yes2 = true
				local oldwugong = 0
				for i = 1, JY.Base["�书����"] do
					if p["�书" .. i] == wugongid then
						oldwugong = 1
						p["�书�ȼ�" .. i] = math.modf((p["�书�ȼ�" .. i] + 100) / 100) * 100
						kfnum = i
						break;
					end
				end
				if oldwugong == 0 then
					for i = 1, JY.Base["�书����"] do
						if p["�书" .. i] == 0 then
							p["�书" .. i] = wugongid
							p["�书�ȼ�" .. i] = 0;
							kfnum = i
							break;
						end
					end
				end
			end
		else
			break;
		end
	end
	

	if yes1 then
		DrawStrBoxWaitKey(string.format("%s ���� %s �ɹ�", p["����"], JY.Thing[thingid]["����"]), C_WHITE, CC.DefaultFont)
	end
	if yes2 then
		--�޾Ʋ������Զ��������ж�������
		if p["�书�ȼ�" .. kfnum] == 900 then
			--��쳵��������ж�
			if (match_ID(pid, 1) and wugongid == 67) or (match_ID(pid, 37) and wugongid == 94) or (match_ID(pid, 49) and wugongid == 14) then
				DrawStrBoxWaitKey(string.format("%s ��Ϊ��%s��", JY.Wugong[wugongid]["����"], math.modf(p["�书�ȼ�" .. kfnum] / 100) + 1), C_WHITE, CC.DefaultFont)
			--�ڹ����Ṧ
			elseif JY.Wugong[wugongid]["�书����"] == 6 or JY.Wugong[wugongid]["�书����"] == 7 then
				--��������ֱ�ӵ���
				if wugongid == 85 or wugongid == 87 or wugongid == 88 then
					p["�书�ȼ�" .. kfnum] = 999
					DrawStrBoxWaitKey(string.format("%s ����������", JY.Wugong[wugongid]["����"]), C_WHITE, CC.DefaultFont)
				elseif match_ID(pid, 637) then
				    p["�书�ȼ�" .. kfnum] = 999
					DrawStrBoxWaitKey(string.format("%s ����������", JY.Wugong[wugongid]["����"]), C_WHITE, CC.DefaultFont)
				--����������Ե���
				elseif wugongid == p["�츳�ڹ�"] or wugongid == p["�츳�Ṧ"] then
					p["�书�ȼ�" .. kfnum] = 999
					DrawStrBoxWaitKey(string.format("%s ����������", JY.Wugong[wugongid]["����"]), C_WHITE, CC.DefaultFont)
				else
					DrawStrBoxWaitKey(string.format("%s ��Ϊ��%s��", JY.Wugong[wugongid]["����"], math.modf(p["�书�ȼ�" .. kfnum] / 100) + 1), C_WHITE, CC.DefaultFont)
				end
			--�⹦ֱ�ӵ���
			else
				p["�书�ȼ�" .. kfnum] = 999
				DrawStrBoxWaitKey(string.format("%s ����������", JY.Wugong[wugongid]["����"]), C_WHITE, CC.DefaultFont)
			end
		else
			DrawStrBoxWaitKey(string.format("%s ��Ϊ��%s��", JY.Wugong[wugongid]["����"], math.modf(p["�书�ȼ�" .. kfnum] / 100) + 1), C_WHITE, CC.DefaultFont)
		end
	end
	Hp_Max(pid)
end

--��ɫָ��
function War_TgrtsMenu()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	local pid = WAR.Person[WAR.CurID]["������"]
	Cls()
	WAR.ShowHead = 0
	WarDrawMap(0)
	local grts_id;
	--����ǳ���
	if pid == 0 then
		grts_id = JY.Base["����"]
	else
		grts_id = pid
	end
	--local 
    --if JY.Person[pid]["��ɫָ��"] == 1 then
	   
	--����¶����ɫָ������
	if match_ID(pid, 574) then	
		local wg = JYMsgBox("��ɫָ�" .. GRTS[grts_id], GRTSSAY[grts_id], {"����", "�׺�"}, 2,  JY.Person[pid]["������"],1)
		if wg == 1 then
			JY.Person[pid]["�书1"] = 201
		elseif wg == 2 then
			JY.Person[pid]["�书1"] = 202
		end
		return 0
	--�����ָ������
	elseif match_ID(pid, 626) then
		local wg = JYMsgBox("��ɫָ�" .. GRTS[grts_id], GRTSSAY[grts_id], {"��ָ", "����", "��Ӣ"}, 3, JY.Person[pid]["������"],1)
		if wg == 1 then
			JY.Person[pid]["�书1"] = 18
		elseif wg == 2 then
			JY.Person[pid]["�书1"] = 38
		elseif wg == 3 then
			JY.Person[pid]["�书1"] = 12
		end
		return 0
	else
		local yn = JYMsgBox("��ɫָ�" .. GRTS[grts_id], GRTSSAY[grts_id], {"ȷ��", "ȡ��"}, 2, JY.Person[pid]["������"])
		if yn == 2 then
			return 0
		end
	end
		
	--����
	if match_ID(pid, 53) then
		if JY.Person[pid]["����"] > 20 then
			WAR.TZ_DY = 1
			PlayWavE(16)
			CurIDTXDH(WAR.CurID, 72,1, "��Ѹ���� Ʈ������", M_DeepSkyBlue, 15);
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
  
	--����
	if match_ID(pid, 49) then
		if JY.Person[pid]["����"] > 20 and JY.Person[pid]["����"] > 1000 then
		  JY.Person[pid]["����"] = JY.Person[pid]["����"] - 5
		  JY.Person[pid]["����"] = JY.Person[pid]["����"] - 500
		  local ssh = {}
		  local num = 1
		  for i = 0, WAR.PersonNum - 1 do
			local wid = WAR.Person[i]["������"]
			if WAR.TZ_XZ_SSH[wid] == 1 and WAR.Person[i]["����"] == false then
				--��Ѩ25��
				if WAR.FXDS[wid] == nil then
					WAR.FXDS[wid] = 25
				else
					WAR.FXDS[wid] = WAR.FXDS[wid] + 25
				end
				if WAR.FXDS[wid] > 50 then
					WAR.FXDS[wid] = 50
				end
				WAR.TZ_XZ_SSH[wid] = nil
				if WAR.Person[i].Time > 995 then
					WAR.Person[i].Time = 995
				end
				ssh[num] = {}
				ssh[num][1] = i
				ssh[num][2] = wid
				num = num + 1
			end
		  end
		  local name = {}
		  for i = 1, num - 1 do
			name[i] = {}
			name[i][1] = JY.Person[ssh[i][2]]["����"]
			name[i][2] = nil
			name[i][3] = 1
		  end
		  --DrawStrBox(CC.MainMenuX, CC.MainMenuY, "�߷���", C_GOLD, CC.DefaultFont)
			local r =  Cat('�˵�',name,num-1,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
		 -- Cat('�˵�',name, num - 1, 10, CC.MainMenuX, CC.MainMenuY + 45, 0, 0, 1, 0, CC.DefaultFont, C_RED, C_GOLD)
		  Cls()
		  PlayWavAtk(32)
		  CurIDTXDH(WAR.CurID, 72,1, "�������� ����Ⱥ��")
		  PlayWavE(8)
		 -- local sssid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)
			for DH = 114, 129 do
				Cat('ʵʱ��Ч����')
				Cls()
				for i = 1, num - 1 do
					local x0 = WAR.Person[WAR.CurID]["����X"]
					local y0 = WAR.Person[WAR.CurID]["����Y"]
					local dx = WAR.Person[ssh[i][1]]["����X"] - x0
					local dy = WAR.Person[ssh[i][1]]["����Y"] - y0
					local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
					local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
					local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)

					ry = ry - hb
					
					lib.PicLoadCache(3, DH * 2, rx, ry, 2, 192)
					if DH > 124 then
						DrawString(rx - 10, ry - 15, "��Ѩ", C_GOLD, CC.DefaultFont)
					end
					
				end
				ShowScreen()
				--lib.ShowSurface(0)
				--lib.LoadSur(sssid, 0, 0)
				lib.Delay(CC.BattleDelay)
			end
		 -- lib.FreeSur(sssid)
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
  
  --�˳���
  if match_ID(pid, 89) then
    if JY.Person[pid]["����"] > 25 and JY.Person[pid]["����"] > 300 then
      local px, py = WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"]
      local mxy = {
					{WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"] + 1}, 
					{WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"] - 1}, 
					{WAR.Person[WAR.CurID]["����X"] + 1, WAR.Person[WAR.CurID]["����Y"]}, 
					{WAR.Person[WAR.CurID]["����X"] - 1, WAR.Person[WAR.CurID]["����Y"]}}
      local zdp = {}
      local num = 1
      for i = 1, 4 do
        if GetWarMap(mxy[i][1], mxy[i][2], 2) >= 0 then
          local mid = GetWarMap(mxy[i][1], mxy[i][2], 2)
          if inteam(WAR.Person[mid]["������"]) then
          	zdp[num] = WAR.Person[mid]["������"]
          	num = num + 1
        	end
        end
        
      end
      local zdp2 = {}
      for i = 1, num - 1 do
        zdp2[i] = {}
        zdp2[i][1] = JY.Person[zdp[i]]["����"] .. "��" .. JY.Person[zdp[i]]["����"]
        zdp2[i][2] = nil
        zdp2[i][3] = 1
      end
		--DrawStrBox(CC.MainMenuX, CC.MainMenuY, "������", C_GOLD, CC.DefaultFont)
		local r =  Cat('�˵�',zdp2,num-1,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
		--local r = Cat('�˵�',zdp2, num - 1, 10, CC.MainMenuX, CC.MainMenuY + 45, 0, 0, 1, 0, CC.DefaultFont, C_RED, C_GOLD)
		Cls()
		AddPersonAttrib(zdp[r], "����", 50)
		AddPersonAttrib(pid, "����", -25)
		AddPersonAttrib(pid, "����", -300)
		PlayWavE(28)
		--lib.Delay(10)
		CurIDTXDH(WAR.CurID, 86,1, "������Ԫ")
		local Ocur = WAR.CurID
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["������"] == zdp[r] then
				WAR.CurID = i
			end
		end
		Cat('ʵʱ��Ч����')
		WarDrawMap(0)
		PlayWavE(36)
      --lib.Delay(100)
		lib.Delay(CC.BattleDelay)
		CurIDTXDH(WAR.CurID, 86, 1, "�ָ�����50��")
		WAR.CurID = Ocur
		WarDrawMap(0)
    else
    	DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
    	return 0
    end
  end
  
  --���޼�
  if match_ID(pid, 9) then
    if JY.Person[pid]["����"] > 10 and JY.Person[pid]["����"] > 500 then
      local nyp = {}
      local num = 1
      for i = 0, WAR.PersonNum - 1 do
        if WAR.Person[i]["�ҷ�"] == true and WAR.Person[i]["����"] == false and RealJL(WAR.CurID, i, 8) and i ~= WAR.CurID then
          nyp[num] = {}
          nyp[num][1] = JY.Person[WAR.Person[i]["������"]]["����"]
          nyp[num][2] = nil
          nyp[num][3] = 1
          nyp[num][4] = i
          num = num + 1
        end
      end
      --DrawStrBox(CC.MainMenuX, CC.MainMenuY, "Ų�ƣ�", C_GOLD, CC.DefaultFont)
		local r =  Cat('�˵�',nyp,num-1,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
      --local r = Cat('�˵�',nyp, num - 1, 10, CC.MainMenuX, CC.MainMenuY + 45, 0, 0, 1, 0, CC.DefaultFont, C_RED, C_GOLD)
      Cls()
      local mid = WAR.Person[nyp[r][4]]["������"]
      QZXS("��ѡ��Ҫ��" .. JY.Person[mid]["����"] .. "Ų�Ƶ�ʲôλ�ã�")
      War_CalMoveStep(WAR.CurID, 8, 1)
      local nx, ny = nil, nil
      while true do
	      nx, ny = War_SelectMove()
	      if nx ~= nil then
		      if lib.GetWarMap(nx, ny, 2) > 0 or lib.GetWarMap(nx, ny, 5) > 0 then
		        QZXS("�˴����ˣ�������ѡ��")			--�˴����ˣ�������ѡ��
	      	elseif CC.SceneWater[lib.GetWarMap(nx, ny, 0)] ~= nil then
	        	QZXS("ˮ�棬���ɽ��룡������ѡ��")		--ˮ�棬���ɽ��룡������ѡ��
	       	else
	       		break;
	        end
	      end
	    end
	    PlayWavE(5)
	    CurIDTXDH(WAR.CurID, 88,1, "�������� Ų��Ǭ��")		--�������� Ų��Ǭ��
	    local Ocur = WAR.CurID
	    WAR.CurID = nyp[r][4]
	    WarDrawMap(0)
	    CurIDTXDH(WAR.CurID, 88,1)
	    SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, -1)
	    SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, -1)
        SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, -1)
	    WarDrawMap(0)
	    CurIDTXDH(WAR.CurID, 88,1)
	    WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"] = nx, ny
	    WarDrawMap(0)
	    CurIDTXDH(WAR.CurID, 88,1)
	    SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, WAR.Person[WAR.CurID]["��ͼ"])
	    SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, WAR.CurID)
        SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, JY.Person[WAR.Person[WAR.CurID]["������"]]['ͷ�����'])
	    WarDrawMap(0)
	    CurIDTXDH(WAR.CurID, 88,1)
	    WAR.CurID = Ocur
	    AddPersonAttrib(pid, "����", -10)
	    AddPersonAttrib(pid, "����", -500)
	    
	  else
	  	DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
	  	return 0
	  end
	end
	
	--��ǧ��
	if match_ID(pid, 88) then
	  if JY.Person[pid]["����"] > 10 and JY.Person[pid]["����"] > 700 then
	    local dxp = {}
	    local num = 1
	    for i = 0, WAR.PersonNum - 1 do
	      if WAR.Person[i]["�ҷ�"] == true and WAR.Person[i]["����"] == false and RealJL(WAR.CurID, i, 5) and i ~= WAR.CurID then
	        dxp[num] = {}
	        dxp[num][1] = JY.Person[WAR.Person[i]["������"]]["����"]
	        dxp[num][2] = nil
	        dxp[num][3] = 1
	        dxp[num][4] = i
	        num = num + 1
	      end
	    end
	    --DrawStrBox(CC.MainMenuX, CC.MainMenuY, "������", C_GOLD, 30)
		local r =  Cat('�˵�',dxp,num-1,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
	    --local r = Cat('�˵�',dxp, num - 1, 10, CC.MainMenuX, CC.MainMenuY + 45, 0, 0, 1, 0, CC.DefaultFont, C_RED, C_GOLD)
	    Cls()
	    local mid = WAR.Person[dxp[r][4]]["������"]
	    PlayWavE(28)
	    --lib.Delay(10)
	    CurIDTXDH(WAR.CurID,87,1, "����Ϸ�쳾")
	    local Ocur = WAR.CurID
	    WAR.CurID = dxp[r][4]
		Cat('ʵʱ��Ч����')
		WarDrawMap(0)
	    PlayWavE(36)
	    lib.Delay(CC.BattleDelay)
	    CurIDTXDH(WAR.CurID, 87, 1, "��������500")
	    WAR.CurID = Ocur
	    WarDrawMap(0)
	    WAR.Person[dxp[r][4]].Time = WAR.Person[dxp[r][4]].Time + 500
	    if WAR.Person[dxp[r][4]].Time > 999 then
	      WAR.Person[dxp[r][4]].Time = 999
	    end
	    AddPersonAttrib(pid, "����", -10)
	    AddPersonAttrib(pid, "����", -1000)
	  else
	  	DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
	  	return 0
		end
	end
	

	--���лۣ�����
	if match_ID(pid, 77) then
		if JY.Person[pid]["����"] > 500 and JY.Person[pid]["���˳̶�"] < 50 then
			local zjwid = nil
			for i = 0, WAR.PersonNum - 1 do
				if WAR.Person[i]["������"] == 0 and WAR.Person[i]["����"] == false then
					zjwid = i
					break
				end
			end
			if zjwid ~= nil then
				DrawStrBoxWaitKey("���ı��ۡ���Ů����", C_RED, 36)
				say("�����á�����",0,1)
				if JY.Person[0]["�Ա�"] == 0 then
					say("�����磬���롭�����������ͣ�",77,0)
				else
					say("�����㣬���롭�����������ͣ�",77,0)
				end
				JY.Person[pid]["����"] = 1
				JY.Person[pid]["���˳̶�"] = 100
				WAR.Person[WAR.CurID].Time = -500
				JY.Person[0]["����"] = JY.Person[0]["�������ֵ"]
				JY.Person[0]["���˳̶�"] = 0
				WAR.Person[zjwid].Time = 999
				WAR.FXDS[0] = nil
				WAR.LQZ[0] = 100
			else
				DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)		-- "δ���㷢������"
				return 0
			end

		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)		-- "δ���㷢������"
			return 0
		end
	end
	
	--�����壺���ѹ���ɫָ�� - ʩ��  ��Χ���Χ�ڵĵ���ʱ���ж���ʱ���Ѫ
	if match_ID(pid, 17) then
		if JY.Person[pid]["����"] >= 30 and JY.Person[pid]["����"] >= 300 then
			CleanWarMap(4,0);
			AddPersonAttrib(pid, "����", -15)
			AddPersonAttrib(pid, "����", -300)
			local x1 = WAR.Person[WAR.CurID]["����X"];
			local y1 = WAR.Person[WAR.CurID]["����Y"];
			for ex = x1 - 5, x1 + 5 do
				for ey = y1 - 5, y1 + 5 do
					SetWarMap(ex, ey, 4, 1)
					if GetWarMap(ex, ey, 2) ~= nil and GetWarMap(ex, ey, 2) > -1 then
						local ep = GetWarMap(ex, ey, 2)
						if WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[ep]["�ҷ�"] then
	          
							WAR.L_WNGZL[WAR.Person[ep]["������"]] = 50;			--50ʱ���ڳ������ж�+��Ѫ
							SetWarMap(ex, ey, 4, 4)
						end
					end
				end
			end
			War_ShowFight(pid,0,0,0,x1,y1,30);
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--brolycjw������ţ��ɫָ�� - Ⱥ��  ��Χ���Χ�ڵĶ���ʱ������˲���������Ѫ
	if match_ID(pid, 16) then
		if JY.Person[pid]["����"] >= 30 and JY.Person[pid]["����"] >= 300 then
			CleanWarMap(4,0);
			AddPersonAttrib(pid, "����", -15)
			AddPersonAttrib(pid, "����", -300)
			local x1 = WAR.Person[WAR.CurID]["����X"];
			local y1 = WAR.Person[WAR.CurID]["����Y"];
			
			for ex = x1 - 5, x1 + 5 do
				for ey = y1 - 5, y1 + 5 do
					SetWarMap(ex, ey, 4, 1)
					if GetWarMap(ex, ey, 2) ~= nil and GetWarMap(ex, ey, 2) > -1 then
						local ep = GetWarMap(ex, ey, 2)
						if WAR.Person[WAR.CurID]["�ҷ�"] == WAR.Person[ep]["�ҷ�"] then
				  
							WAR.L_HQNZL[WAR.Person[ep]["������"]] = 20;			--20ʱ���ڳ�����Ѫ+������
							SetWarMap(ex, ey, 4, 4)
					  
						end
					end
				end
			end
			War_ShowFight(pid,0,0,0,x1,y1,0);

		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--Ľ�ݸ� ����
	if match_ID(pid, 51) then
		if JY.Person[pid]["����"] > 20 then
			WAR.TZ_MRF = 1
			CurIDTXDH(WAR.CurID, 127,1, "���������� ���Ǹ���־", C_GOLD);
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--С�� Ӱ��
	if match_ID(pid, 66) then
		if JY.Person[pid]["����"] > 30 and JY.Person[pid]["����"] > 2000 then
			War_CalMoveStep(WAR.CurID, 10, 0)
			WAR.XZ_YB[1],WAR.XZ_YB[2]=War_SelectMove()
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 20
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 1000
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--����ָ�� ����
	if match_ID(pid, 90) then
		if JY.Person[pid]["����"] > 10 then
			War_CalMoveStep(WAR.CurID, 8, 1)
			local x,y = War_SelectMove()
			if lib.GetWarMap(x, y, 2) > 0 or lib.GetWarMap(x, y, 5) > 0 then
				local tdID = lib.GetWarMap(x, y, 2)
				if WAR.Person[tdID]["�ҷ�"] == WAR.Person[WAR.CurID]["�ҷ�"] then
					return 0
				end
				local eid = WAR.Person[tdID]["������"]
				local x0, y0 = WAR.Person[WAR.CurID]["����X"],WAR.Person[WAR.CurID]["����Y"]
				local x1, y1 = WAR.Person[tdID]["����X"],WAR.Person[tdID]["����Y"]
				for i = 1, 4 do
					if 0 < JY.Person[eid]["Я����Ʒ����" .. i] and -1 < JY.Person[eid]["Я����Ʒ" .. i] then
						WAR.TD = JY.Person[eid]["Я����Ʒ" .. i]
						WAR.TDnum = JY.Person[eid]["Я����Ʒ����" .. i]
						JY.Person[eid]["Я����Ʒ����" .. i] = 0
						JY.Person[eid]["Я����Ʒ" .. i] = -1
						break
					end
				end
				WAR.Person[WAR.CurID]["�˷���"] = War_Direct(x0, y0, x1, y1)
				CleanWarMap(4, 0)
				SetWarMap(x1, y1, 4, 1)
				WAR.Person[tdID]["�ж�����"] = (WAR.Person[tdID]["�ж�����"] or 0) + AddPersonAttrib(eid, "�ж��̶�", 50)
				WAR.TXXS[eid] = 1
				War_ShowFight(WAR.Person[WAR.CurID]["������"], 0, 0, 0, 0, 0, 12)
				if WAR.TD ~= -1 then
					if WAR.TD == 118 then
						say("����Ҫ����Ľ�ݸ�����͵�������ߺߣ��±��Ӱɣ�", 51,0)
					else
						instruct_2(WAR.TD, WAR.TDnum)
					end
					WAR.TD = -1
					WAR.TDnum = 0
				end
				WAR.TXXS[eid] = nil
			else
				return 0
			end
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 5
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--��� �ɺ�
	if match_ID(pid, 1) then
		if JY.Person[pid]["����"] > 20 then
			War_CalMoveStep(WAR.CurID, 10, 2)
			local x,y = War_SelectMove()
			if not x then
				return 0
			end
			if GetWarMap(x, y, 1) > 0 or GetWarMap(x, y, 2) > 0 or GetWarMap(x, y, 5) > 0 or CC.WarWater[GetWarMap(x, y, 0)] ~= nil then
				return 0
			else
				CurIDTXDH(WAR.CurID, 25,1, "ѩɽ�ɺ�", Violet);
				WAR.Person[WAR.CurID]["�ƶ�����"] = 10
				War_MovePerson(x, y, 1)
				WAR.Person[WAR.CurID]["�ƶ�����"] = 0
				JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
			end
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--�Ħ�� �û�
	if match_ID(pid, 103) then
		if JY.Person[pid]["����"] > 20 and JY.Person[pid]["����"] > 1000 then
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
					if JY.Thing[id]["����"] == 2 and JY.Thing[id]["�����书"] > -1 then
						thing[num] = id
						thingnum[num] = JY.Base["��Ʒ����" .. i + 1]
						num = num + 1
					end
				end 
			end
			IsViewingKungfuScrolls = 1
			local r = SelectThing(thing, thingnum)
			if r >= 0 then
				CurIDTXDH(WAR.CurID, 93,1, "����û�", C_GOLD)
				JY.Person[pid]["�书2"]= JY.Thing[r]["�����书"]
				JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
				JY.Person[pid]["����"] = JY.Person[pid]["����"] - 500
			else
				return 0
			end
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--�����ָ�� ��ս
	if match_ID(pid, 160) then
		if JY.Person[pid]["����"] > 20 and JY.Person[pid]["����"] > 1000 then
			War_CalMoveStep(WAR.CurID, 8, 1)
			local x,y = War_SelectMove()
			if lib.GetWarMap(x, y, 2) > 0 or lib.GetWarMap(x, y, 5) > 0 then
				local tdID = lib.GetWarMap(x, y, 2)
				if WAR.Person[tdID]["�ҷ�"] == WAR.Person[WAR.CurID]["�ҷ�"] then
					return 0
				end
				local eid = WAR.Person[tdID]["������"]
				WAR.SZSD = eid
				
				CurIDTXDH(WAR.CurID, 93,1, "����Ŀ��", C_GOLD)
				JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
				JY.Person[pid]["����"] = JY.Person[pid]["����"] - 500
			else
				return 0
			end
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--���� ����
	if match_ID(pid, 62) then
		if JY.Person[pid]["����"] > 20 and JY.Person[pid]["����"] > 1000 then
			War_ActupMenu()
			WAR.SLSX[pid] = 2
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 500
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end

	--���� �ݼ�
	if match_ID(pid, 56) then
		if JY.Person[pid]["����"] > 20 and JY.Person[pid]["����"] > 1000 then
			local x,y = WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"]
			--1��ɫ��2��ɫ��3��ɫ��4��ɫ
			CleanWarMap(6,-1);
					
			local QMDJ = {"��","��","��","��","��","��","��","��"}
						
			--��������Χ��������
			SetWarMap(x,y, 6, math.random(4))
			
			for j=1, 2 do
				SetWarMap(x + math.random(6), y + math.random(6), 6, math.random(4));
				for n = 30, 40 do
					local i = n
					if i > 40 then
						i = 40
					end
					Cat('ʵʱ��Ч����')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
			end
						
			for j=3, 4 do
				SetWarMap(x + math.random(6), y - math.random(6), 6, math.random(4));
				for n = 30, 40 do
					local i = n
					if i > 40 then
						i = 40
					end
					Cat('ʵʱ��Ч����')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
			end
						
			for j=5, 6 do
				SetWarMap(x - math.random(6), y - math.random(6), 6, math.random(4));
				for n = 30, 40 do
					local i = n
					if i > 40 then
						i = 40
					end
					Cat('ʵʱ��Ч����')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
			end
						
			for j=7, 8 do
				SetWarMap(x - math.random(6), y + math.random(6), 6, math.random(4));
				for n = 30, 40 do
					local i = n
					if i > 40 then
						i = 40
					end
					Cat('ʵʱ��Ч����')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
				
			end
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 500
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--���ϣ���ҩ
	if match_ID(pid, 47) then
		WAR.JYZT[pid] = 1
		CurIDTXDH(WAR.CurID, 128,1, "��ҩ", C_RED);
		return 20
	end
	
	--ΤС�� �ڲ�
	if match_ID(pid, 601) then
		if JY.Person[pid]["����"] > 30 then
			War_CalMoveStep(WAR.CurID, 8, 1)
			local x,y = War_SelectMove()
			if lib.GetWarMap(x, y, 2) > 0 or lib.GetWarMap(x, y, 5) > 0 then
				local tdID = lib.GetWarMap(x, y, 2)
				if WAR.Person[tdID]["�ҷ�"] == WAR.Person[WAR.CurID]["�ҷ�"] then
					return 0
				end
				local eid = WAR.Person[tdID]["������"]
				WAR.CSZT[eid] = 1
				
				Cls()
				local KC = {"����Ӣ������","��������"}
				
				for n = 1, #KC + 25 do
					local i = n 
					if i > #KC then 
						i = #KC
					end
					lib.GetKey()
					Cat('ʵʱ��Ч����')
					Cls()
					DrawString(-1, -1, KC[i], C_GOLD, CC.Fontsmall)
					ShowScreen()
					lib.Delay(CC.BattleDelay)
				end
				Cls()
				local s = WAR.CurID
				WAR.CurID = tdID
				WarDrawMap(0)
				CurIDTXDH(WAR.CurID, 145,1)
				WAR.CurID = s
				JY.Person[pid]["����"] = JY.Person[pid]["����"] - 15
			else
				return 0
			end
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--���˷�ָ�� �ƾ�
	if match_ID(pid, 3) then
		if JY.Person[pid]["����"] > 20 and JY.Person[pid]["����"] > 1000 then
			WAR.MRF = 1
			if Cat('�书') == 0 then
			--if War_FightMenu() == 0 then
				return 0
			end
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 300
			WAR.MRF = 0
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end

	
	--��������
	if match_ID(pid, 6) then
		WAR.YSJF[pid] = 100
		CurIDTXDH(WAR.CurID, 124,1, "��ʯ���", M_Silver);
		return 20
	end

	--лѷָ�� ����
	if match_ID(pid, 13) then
		if JY.Person[pid]["����"] > 20 and JY.Person[pid]["����"] > 3000 then
			CurIDTXDH(WAR.CurID, 118,1, "ʨ������", C_GOLD)
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.Person[j]["����"] == false then
					WAR.HLZT[WAR.Person[j]["������"]] = 2
				end
			end
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 2000
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	--�𴦻� һ��ֹɱ
	if match_ID(pid, 68) then
		if JY.Person[pid]["����"] > 20 and WAR.JSZT1[pid]~= nil and WAR.JSZT1[pid] == 0 then
			CurIDTXDH(WAR.CurID, 118,1, "һ��ֹɱ", C_GOLD)
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.Person[j]["����"] == false then		
                local offset1 = math.abs(WAR.Person[j]["����X"] - WAR.Person[WAR.CurID]["����X"])
                local offset2 = math.abs(WAR.Person[j]["����Y"] - WAR.Person[WAR.CurID]["����Y"])				
				if offset1 < 10 and offset2 < 10 then
				WAR.YYZS[WAR.Person[j]["������"]] = 1
				end
			 end
			end
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 15
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
		WAR.JSZT1[pid]= nil
	end
	--����ͩͳ��ָ��ҷ�ȫ���������50ʱ��
	if match_ID(pid, 74) then
		if JY.Person[pid]["����"] > 10 and JY.Person[pid]["����"] > 150 and WAR.HQT_CD == 0 then
			CurIDTXDH(WAR.CurID, 92,1, "ָ��");		--������ʾ
			for i = 0, WAR.PersonNum - 1 do
				if WAR.Person[i]["�ҷ�"] == true and WAR.Person[i]["����"] == false then
					WAR.HQT_ZL[WAR.Person[i]["������"]] = 50
					WAR.HQT_CD = 2
					WAR.Person[i].Time = WAR.Person[i].Time + 500;
					if WAR.Person[i].Time > 999 then
						WAR.Person[i].Time = 999;
				end
			end
			end
			AddPersonAttrib(pid, "����", -15)
			AddPersonAttrib(pid, "����", -500)
			--lib.Delay(100)		
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
	  	return 0
		end
	end

	--��̫��ָ�� ����
	if match_ID(pid, 7) then
		if JY.Person[pid]["����"] > 20 and JY.Person[pid]["����"] > 1000 then
			CleanWarMap(4, 0)
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
					local eid = WAR.Person[j]["������"]
					local qycs = WAR.QYZT[eid] or 0
					if qycs > 0 then
						WAR.TXXS[eid] = 1
						--�޾Ʋ�������¼����Ѫ��
						WAR.Person[j]["Life_Before_Hit"] = JY.Person[eid]["����"]
						JY.Person[eid]["����"] = JY.Person[eid]["����"] - 50*qycs
						WAR.Person[j]["��������"] = (WAR.Person[j]["��������"] or 0) - 50*qycs
						SetWarMap(WAR.Person[j]["����X"], WAR.Person[j]["����Y"], 4, 1)
						WAR.QYZT[eid] = nil
					end
				end
			end
			War_ShowFight(WAR.Person[WAR.CurID]["������"], 0, 0, 0, 0, 0, 144)
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 500
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--�ֻ�ָ�� ����
	if match_ID(pid, 4) then
		if JY.Person[pid]["����"] > 20 then
			War_CalMoveStep(WAR.CurID, 8, 1)
			local x,y = War_SelectMove()
			if lib.GetWarMap(x, y, 2) > 0 or lib.GetWarMap(x, y, 5) > 0 then
				local tdID = lib.GetWarMap(x, y, 2)
				if WAR.Person[tdID]["�ҷ�"] == WAR.Person[WAR.CurID]["�ҷ�"] then
					return 0
				end
				local eid = WAR.Person[tdID]["������"]
				local x0, y0 = WAR.Person[WAR.CurID]["����X"],WAR.Person[WAR.CurID]["����Y"]
				local x1, y1 = WAR.Person[tdID]["����X"],WAR.Person[tdID]["����Y"]
				
				WAR.XRZT[eid] = 40
				WAR.Person[WAR.CurID]["�˷���"] = War_Direct(x0, y0, x1, y1)
				CleanWarMap(4, 0)
				SetWarMap(x1, y1, 4, 1)
				War_ShowFight(WAR.Person[WAR.CurID]["������"], 0, 0, 0, 0, 0, 148)
			else
				return 0
			end
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--���˿�����
	if match_ID(pid, 15) then
	   if JY.Person[pid]['����'] >= 2000 and JY.Person[pid]["����"] >= 10 then
		  WAR.QGZT[pid] = 6
		  CurIDTXDH(WAR.CurID, 149,1)
		  JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
		  JY.Person[pid]["����"] = JY.Person[pid]["����"] - 2000
	   else 
          DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
       end	   
	   return 20
	end
	
	--����ָ�� Ůװ
	if match_ID(pid, 92) then
		if JY.Person[pid]["����"] > 20 then
			WarDrawMap(0)
			CurIDTXDH(WAR.CurID, 135, 1, "�ճ����� Ψ���㲻��", C_GOLD)
			lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, -1)
			lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, -1)
			WarDrawMap(0)
			local mj = {}
			if JY.Person[pid]["�Ա�"] == 0 then
				JY.Person[pid]["ͷ�����"] = 384
				JY.Person[pid]["������"] = 504
				JY.Person[pid]["�Ա�"] = 1
				JY.Person[pid]["�书2"] = 105
				JY.Person[pid]["�츳�ڹ�"] = 105
				JY.Person[pid]["�����ڹ�"] = 105
				mj[1]={0,13,0,0,0}
				mj[2]={0,11,0,0,0}
				mj[3]={0,11,0,0,0}
			else
				JY.Person[pid]["ͷ�����"] = 387
				JY.Person[pid]["������"] = 92
				JY.Person[pid]["�Ա�"] = 0
				JY.Person[pid]["�书2"] = 105
				JY.Person[pid]["�츳�ڹ�"] = 105
				JY.Person[pid]["�����ڹ�"] = 105
				mj[1]={0,14,0,0,0}
				mj[2]={0,12,0,0,0}
				mj[3]={0,12,0,0,0}
			end
			for i = 1, 5 do
				JY.Person[pid]["���ж���֡��" .. i] = mj[1][i]
				JY.Person[pid]["���ж����ӳ�" .. i] = mj[2][i]
				JY.Person[pid]["�书��Ч�ӳ�" .. i] = mj[3][i]
			end	

			WAR.Person[WAR.CurID]["��ͼ"] = WarCalPersonPic(WAR.CurID)
			WarDrawMap(0)
			CurIDTXDH(WAR.CurID, 135, 1, "�ճ����� Ψ������", C_GOLD)
			SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, WAR.Person[WAR.CurID]["��ͼ"])
			SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, WAR.CurID)
            SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, JY.Person[WAR.Person[WAR.CurID]["������"]]['ͷ�����'])
			WarDrawMap(0)
			CurIDTXDH(WAR.CurID, 135, 1, "�ճ����� Ψ������", C_GOLD)
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	--��Ѱ�� �ɵ�
	if match_ID(pid, 498) then
		if WAR.XLFD[pid] ~= nil then
			WAR.XLFD[pid] = nil
			return 20
		end
		if JY.Person[pid]["����"] > 20 and JY.Person[pid]["����"] > 1000 then
			WAR.XLFD[pid] = 100
			CurIDTXDH(WAR.CurID, 124,1,"С��ɵ�",C_GOLD)
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 500
			return 20
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end	
	--����ˮ ����һ��
	if match_ID(pid, 652)  then
		if WAR.JTYJ[pid] ~= nil then
			WAR.JTYJ[pid] = nil
			return 20
		end
		if JY.Person[pid]["����"] > 20 and JY.Person[pid]["����"] > 1000 and WAR.LQZ[pid] == 100 and WAR.DZXY ~= 1  then
			WAR.JTYJ[pid] = 20
			CurIDTXDH(WAR.CurID, 132,1,"�콣",C_GOLD)
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 10
			JY.Person[pid]["����"] = JY.Person[pid]["����"] - 500
			return 20
		else
			DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
			return 0
		end
	end	
	
	--÷���� ����
	if match_ID(pid, 9969) then
		local ql = 1
		local bx,by = CC.ScreenW/936,CC.ScreenH/701
		local menu={};
		local mj = {}
		local str = '����ӭ�� ���������'
		local p = 507
		local ts = JY.Base['��������']
		menu[1]={"��װ",nil,1};
		menu[2]={"���벻��",nil,1};
		mj[1]={0,10,0,0,0}
		mj[2]={0,9,0,0,0}
		mj[3]={0,9,0,0,0}
		if match_ID(pid, 507) then 
			mj[1]={0,14,0,0,0}
			mj[2]={0,14,0,0,0}
			mj[3]={0,14,0,0,0}
			p = 508
			str = '����÷��  ����֮��'
			ql =  Cat('�˵�',menu,#menu,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
			if ql == 0 then 
				return 0
			end	
		end
		if ql == 1 then
			WarDrawMap(0)
			CurIDTXDH(WAR.CurID, 135, 1, str, C_GOLD)
			lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, -1)
			lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, -1)
			WarDrawMap(0)
			JY.Person[pid]["ͷ�����"] = JY.Person[p]["ͷ�����"]
			JY.Person[pid]["������"] = JY.Person[p]["������"]
			for i = 1, 5 do
				JY.Person[pid]["���ж���֡��" .. i] = mj[1][i]
				JY.Person[pid]["���ж����ӳ�" .. i] = mj[2][i]
				JY.Person[pid]["�书��Ч�ӳ�" .. i] = mj[3][i]
			end	
			JY.Base['����'] = p
			--lib.PicLoadFile(string.format(CC.FightPicFile[1], JY.Person[pid]["ͷ�����"]), string.format(CC.FightPicFile[2], JY.Person[pid]["ͷ�����"]), 4 + WAR.CurID)

			WAR.Person[WAR.CurID]["��ͼ"] = WarCalPersonPic(WAR.CurID)
			WarDrawMap(0)
			CurIDTXDH(WAR.CurID, 135, 1, str, C_GOLD)
			lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, WAR.Person[WAR.CurID]["��ͼ"])
			lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, WAR.CurID)
            SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, JY.Person[WAR.Person[WAR.CurID]["������"]]['ͷ�����'])
			WarDrawMap(0)
			CurIDTXDH(WAR.CurID, 135, 1, str, C_GOLD)
		elseif ql == 2 then 
			if ts <= 0 or JY.Person[pid]['����'] < 10 then 
				DrawStrBoxWaitKey("δ���㷢������", C_WHITE, CC.DefaultFont)
				return 0
			end
			local x = WAR.Person[WAR.CurID]["����X"];
			local y = WAR.Person[WAR.CurID]["����Y"];
			local page = 1

			War_CalMoveStep(WAR.CurID,255,1)
			Cat('ʵʱ��Ч����')
			WarDrawMap(1,x,y);	
			ShowScreen()
			lib.Delay(CC.BattleDelay)
			x,y = War_SelectMove()
			if x == nil then
				return 0
			end
			local id = -1
			local kfmenu = {}
			local i = GetWarMap(x,y,2)
			local kfid = 0
			local kflv = 0
			if i >= 0 and WAR.Person[i]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
				id = WAR.Person[i]['������']
				for j = 1,JY.Base['�书����'] do 
					if JY.Person[id]['�书'..j] > 0 then 
						kfmenu[#kfmenu+1] = {JY.Wugong[JY.Person[id]['�书'..j]]['����'],JY.Person[id]['�书'..j],1,JY.Person[id]['�书�ȼ�'..j]}
					end
				end
			end
			if #kfmenu == 0 then 
				DrawStrBoxWaitKey("Ŀ�����书��ѧ", C_WHITE, CC.DefaultFont)
				return 0
			end
			local r = Cat('�˵�',kfmenu,#kfmenu,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
			if r <= 0 then 
				return 0
			end
			
			kfid = kfmenu[r][2]
			kflv = kfmenu[r][4]
			local kfmenu1 = {}
			if ts > JY.Base["�书����"] then
				ts = JY.Base["�书����"]
			end
			for j = 1,ts do
				local kn = '�հ�'
				if JY.Person[pid]['�书'..j] > 0 then 
					kn = JY.Wugong[JY.Person[pid]['�书'..j]]['����']
				end
				kfmenu1[#kfmenu1+1] = {kn,j,1}
				if JY.Person[pid]['�书'..j] <= 0 then 
					break
				end
			end
			local r1 = Cat('�˵�',kfmenu1,#kfmenu1,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
			if r1 <= 0 then 
				return 0
			end
			JY.Person[pid]['�书'..kfmenu1[r1][2]] = kfid
			JY.Person[pid]['�书�ȼ�'..kfmenu1[r1][2]] = kflv
			AddPersonAttrib(pid,'����',-10)
			CurIDTXDH(WAR.CurID, 135, 1, '����÷��  ����֮��', C_GOLD)
		end
	end
	
	return 1
end

--ս������
function War_ActupMenu()
	local p = WAR.CurID
	local id = WAR.Person[p]["������"]
	local x0, y0 = WAR.Person[p]["����X"], WAR.Person[p]["����Y"]
	


	--���˸������������Ч��
	if Curr_NG(id, 95) then
		WAR.Actup[id] = 2;
		WAR.Defup[id] = 1
		WAR.HMGXL[id] = 1
		CurIDTXDH(WAR.CurID, 85,1,"���ؼ汸�����ƴ���", LightSlateBlue);
		return 1;
	
	--������������������Ч��
	elseif PersonKF(id, 103) then
		WAR.Actup[id] = 2;
		WAR.Defup[id] = 1
		CurIDTXDH(WAR.CurID, 85, 1,"��֮��������֮����", LightGreen);
		return 1;
		--������ϼ����ǿ��
	elseif PersonKF(id, 89) then
		WAR.Actup[id] = 2
		if inteam(id) then
			WAR.ZXXS[id] = 1 + math.modf(JY.Base["��������"]/7)
		else
			WAR.ZXXS[id] = 3
		end
		CurIDTXDH(WAR.CurID, 85, 1,"��ϼ���ơ����಻��", Violet);
		return 1;

	--���������سɹ�
	elseif id == 0  then
		WAR.Actup[id] = 2
	--NPC�����سɹ�
	elseif not inteam(id) then
		WAR.Actup[id] = 2
	--�ҷ��������ڳ��سɹ�
	elseif ZDGH(WAR.CurID,609) then
		WAR.Actup[id] = 2
	--��̬70%���ʳɹ�
	elseif JLSD(15, 85, id) then
		WAR.Actup[id] = 2
	end
	if WAR.Actup[id] ~= 2 then
			for i = 1,10 do
				Cat('ʵʱ��Ч����')
				Cls()
				DrawStrBox(-1, -1, "����ʧ��", C_GOLD, CC.DefaultFont)
				ShowScreen()
				lib.Delay(CC.BattleDelay)
			end
	else
		CurIDTXDH(WAR.CurID, 85, 1,"�����ɹ�", C_GOLD);
	end
	return 1
end


--ս������
function War_DefupMenu()
	local p = WAR.CurID
	local id = WAR.Person[p]["������"]
	local x0, y0 = WAR.Person[p]["����X"], WAR.Person[p]["����Y"]
	WAR.Defup[id] = 1
	Cls()
	--local hb = GetS(JY.SubScene, x0, y0, 4)
	  
	--̫������������
	if PersonKF(id, 102) then
		WAR.Actup[id] = 2;
		CurIDTXDH(WAR.CurID, 86,1,"������ʼ��̫������", C_RED);
		return 1;
	end
	  
	CurIDTXDH(WAR.CurID, 86,1,"������ʼ", LimeGreen);

	return 1
end

--��������ļ���ֵ������һ���ۺ�ֵ�Ա�ѭ��ˢ�¼�����
function GetJiqi()
	local num, total = 0, 0
	--�޾Ʋ������Ṧ�������Ｏ����Ӱ�캯��
	local function getnewmove(x)
		if x <= 0 then 
			return 0
		end
		return math.sqrt(x)
		--[[
		if x > 160 then
			return 6 + (x - 160) / 60
		elseif x > 80 then
			return 4 + (x - 80) / 40
		elseif x > 30 then
			return 2 + (x - 30) / 25
		else
			return x / 15
		end
		]]
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
	--�޾Ʋ��������˼������Ѷȱ仯
	local function NPCjiqimod(nd)
		local x;
		if nd == 1 then
			return 0.8
		elseif nd == 2 then
			return 1.6
		elseif nd == 3 then
			return 1.8
		elseif nd == 4 then
			return 2.0
		end
	end
	local dgqb = {}			--��¼������ܵ�����
	local max_jq = 0		--��¼ȫ����߼���	
	for i = 0, WAR.PersonNum - 1 do
		if not WAR.Person[i]["����"] then
			local id = WAR.Person[i]["������"]
			WAR.Person[i].TimeAdd = (getnewmove(WAR.Person[i]["�Ṧ"]) + getnewmove1(JY.Person[id]["����"], JY.Person[id]["�������ֵ"]) + JY.Person[id]["����"] / 30)
			

			if not inteam(id) then
				local nd = JY.Base["�Ѷ�"]-1
				WAR.Person[i].TimeAdd = math.modf(WAR.Person[i].TimeAdd*(1+nd*0.05))
			end	
			
			WAR.Person[i].TimeAdd = math.modf(WAR.Person[i].TimeAdd)
			--end
			
			--5�㼯������ JY.Person[id]["����"] == 61
			if WAR.Person[i].TimeAdd < 5 then
				WAR.Person[i].TimeAdd = 5
			end
			--���˿����������ٶ�+20%
			--����;���
			if Curr_NG(id,105) or (match_ID_awakened(id, 189, 1) and PersonKF(id, 105)) then
				WAR.Person[i].TimeAdd = math.modf(WAR.Person[i].TimeAdd * 1.2)
			end
			--�����񹦱���������+3
			--����;���
			if PersonKF(id,105)  or (match_ID_awakened(id, 189, 1) ) then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 3
			end
			--
				--����
	        if WAR.ZDDH == 344 and inteam(id) == false then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 10
            end	
			
			--if match_ID(id,582)then
			for j = 0, WAR.PersonNum - 1 do
				if match_ID(WAR.Person[j]["������"], 582) and WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[i]["�ҷ�"] then
					WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd - 5
					break	
				end
			end
			
			--��Ů�ľ�����������+1
			if PersonKF(id,154) then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 1
			end		
			--���˷��죬����+3 ��һ��
			if Curr_QG(id,145) or match_ID(id,633) then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 3
			end
			
			--�����츳�Ṧ
			if JY.Person[id]["�����Ṧ"] > 0 and JY.Person[id]["�����Ṧ"] == JY.Person[id]["�츳�Ṧ"] then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 1
			end
			
			--��쳣��Ƿ壬����+8
			if match_ID(id, 1) or match_ID(id, 50) then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 8
			end
			
			--�������ܣ�����+6
			if match_ID(id, 27) then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 6
			end
			
            if WAR.PD['�˾Ʊ�'][id] ~= nil then 
                WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + WAR.PD['�˾Ʊ�'][id]*4
            end
            
			--ΤһЦ����������ҩʦ
			if match_ID(id, 14) or match_ID(id, 18) or match_ID(id, 57)  then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 10
			end
			--һ�ƣ���������⼯���ٶ�+5
			if match_ID(id, 65) and WAR.FUHUOZT[id] ~= nil then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 5
			end

			--����������������⼯���ٶ�+5
			if match_ID(id, 129) and WAR.FUHUOZT[id] ~= nil then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 5
			end
			
			
			--�ﲮ�� ������� ��Խ�ټ���Խ��
			--�������� ��ͨ
			if match_ID(id, 29)  then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 20
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[i]["�ҷ�"] then
						WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd - 4
					end
				end
			end
		  
			--����ֹ���ҷ�ÿ����һ���ˣ������ٶ�+2
			if match_ID(id, 616) then
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["����"] == true and WAR.Person[j]["�ҷ�"] == WAR.Person[i]["�ҷ�"] then
						WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 2
					end
				end
			end
            
			--˾��ժ�ǣ��з���Խ�༯���ٶ�Խ��
			if match_ID(id, 579) then
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[i]["�ҷ�"] then
						WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 5
					end
				end
			end	

			--ʥ����ʹ��ͬʱ�ڳ�ʱ��ÿ�˼����ٶȶ���+20��
			if WAR.ZDDH == 14 and (id == 173 or id == 174 or id == 175) then
				local shz = 0
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[i]["�ҷ�"] then
						shz = shz + 1
					end
				end
				
				if shz == 3 then
					WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 20
				end
			end
		  
			--�����壺������󣬼���+6
			if WAR.ZDDH == 73 and WAR.Person[i]["�ҷ�"] == false then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 6
			end
			  
			--ɽ�����ø�����+2����
			if id == 0 then
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["������"] == 92 and WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == WAR.Person[i]["�ҷ�"] then
						WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 2
						break
					end
				end
			end
			
			if WAR.PD['������'][id] ~= nil then 
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + WAR.PD['������'][id]
			end
			
			--����̫���񹦣�̫��֮�����Ӽ���
			if Curr_NG(id, 171) and WAR.TJZX[id] ~= nil then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + WAR.TJZX[id]
			end
	      --˾��ժ�ǰ������Ӽ���
	        if match_ID(id, 579) and id == 0 and  WAR.SKZX[id] ~= nil then
	        WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + WAR.SKZX[id]
	        end			
			--�����۽���Ӯ��������+8
			if id == 0 and JY.Person[27]["�۽�����"] == 1 then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 8
			end
	  
			--ƽһָ�������ٶȶ���ӳ�5*ɱ����
			if match_ID(id, 28) then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + WAR.PYZ * 5
			end
			--װ������ 1����2������
			if JY.Person[id]["����"] == 230 then
				local sd = 2
				if JY.Thing[230]["װ���ȼ�"] >= 5 then
					sd = 4
				elseif JY.Thing[230]["װ���ȼ�"] >= 3 then
					sd = 3
				end
				--�������Ч������
				if match_ID(id, 590) then
					sd = sd * 2
				end
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + sd
			end
			
			--װ��ë¿ �����ٶ�+10��
			if JY.Person[id]["����"] == 279 then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 10;
			end
			--װ������ �����ٶ�+10��
			if JY.Person[id]["����"] == 264 then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 12;
			end			
			--װ����¿ �����ٶ�+5��
			if JY.Person[id]["����"] == 339 then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 5;
			end
			--װ����Ѫ���� �����ٶ�+5��
			if JY.Person[id]["����"] == 262 then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 8;
			end			
			--�ݻ���Ѫ��Խ�ͼ���Խ�죬50%Ѫ+5��0Ѫ+10
			if JY.Person[id]["����"] == 284 and JY.Thing[284]["װ���ȼ�"] == 6 and JY.Person[id]["����"] < JY.Person[id]["�������ֵ"]/2 then
				local spd_add = 5;
				spd_add = spd_add + math.floor(JY.Person[id]["�������ֵ"]/2 - JY.Person[id]["����"]/100)
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + spd_add;
			end	
			--��������ɳ����Ѫ��Խ�ͼ���Խ�죬100%Ѫ�޼ӳɣ�0Ѫ100%�ӳ�
			if match_ID(id, 47) and WAR.JYZT[id]~=nil then
				local bonus_perctge = 0
				bonus_perctge = 2 - JY.Person[id]["����"] / JY.Person[id]["�������ֵ"]
				WAR.Person[i].TimeAdd = math.modf(WAR.Person[i].TimeAdd * bonus_perctge)
			end
		
            if Curr_NG(id, 227) and WAR.Actup[id] ~= nil and WAR.Actup[id] > 0 then
                WAR.Person[i].TimeAdd = math.modf(WAR.Person[i].TimeAdd * 1.3)
            end
            
			--��������ÿ���⹦+1����
			if match_ID(id, 631) then
				local zzr = 0
				for i = 1, JY.Base["�书����"] do
					if JY.Wugong[JY.Person[id]["�书" .. i]]["�书����"] < 6 then
						zzr = zzr + 1
					end
				end
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + zzr
			end		
		  
		  
			--��������10��
			if WAR.Person[i].TimeAdd < 10 then
				WAR.Person[i].TimeAdd = 10
			end
		  
			--ľ׮������
			if id == 591 and WAR.ZDDH == 226 then
				WAR.Person[i].TimeAdd = 0
			end
			
			--����ˮ�������������
			if id == 600 then
				WAR.Person[i].TimeAdd = 0
			end
		  
			 
			--����ÿ������������+2����
			if JY.Base["��׼"] == 3 and id == 0 then
				local jsyx = 0
				for i = 1, JY.Base["�书����"] do
					if JY.Wugong[JY.Person[id]["�书" .. i]]["�书����"] == 3 and JY.Person[id]["�书�ȼ�" .. i] == 999 then
						jsyx = jsyx + 1
					end
				end
				if jsyx > 7 then
					jsyx = 7
				end
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + jsyx*2
			end
		  
			--�����㣬ÿ�����ŵ�����+2����
			if match_ID(id, 590) then
				local lwx = 0
				for i = 1, JY.Base["�书����"] do
					if JY.Wugong[JY.Person[id]["�书" .. i]]["�书����"] == 5 and JY.Person[id]["�书�ȼ�" .. i] == 999 then
						lwx = lwx + 1
					end
				end
				if lwx > 7 then
					lwx = 7
				end
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + lwx*2
			end

            if WAR.PD['��������������'][id] == 1 then
                WAR.Person[i].TimeAdd = math.modf(WAR.Person[i].TimeAdd*1.5)
            end
            
			--��������80��
			if WAR.Person[i].TimeAdd > 80 then
				if not match_ID(id,579) then
					WAR.Person[i].TimeAdd = 80
				end
			end
			
	        if match_ID(id,579) and WAR.Person[i].TimeAdd > 99 then
				WAR.Person[i].TimeAdd = 99
			end
			
			if max_jq < WAR.Person[i].TimeAdd then
				max_jq = WAR.Person[i].TimeAdd
			end
			
			
	        --�������
          	if match_ID(id, 592) or JY.Person[id]["����"] == 312 then
				dgqb = {i, WAR.Person[i].TimeAdd}
			end		  
			num = num + 1
			total = total + WAR.Person[i].TimeAdd
		end
	end
	     
  	--������ܼ�������ȫ�����
	if dgqb[1] then
		if dgqb[2] < max_jq then
			total = total - WAR.Person[dgqb[1]].TimeAdd + max_jq + 1
			WAR.Person[dgqb[1]].TimeAdd = max_jq + 1
		end
	end
  
	--�޾Ʋ������������ֵ��ﲻ��ȷ������
	WAR.LifeNum = num
	return math.modf(((total) / (num) + (num) - 2))
end


--�书��Χѡ��
function War_KfMove(movefanwei, atkfanwei,wugong)
  local kind = movefanwei[1] or 0
  local len = movefanwei[2] or 0
  local x0 = WAR.Person[WAR.CurID]["����X"]
  local y0 = WAR.Person[WAR.CurID]["����Y"]
  local x = x0
  local y = y0
  if kind ~= nil then
    if kind == 0 then
      War_CalMoveStep(WAR.CurID, len, 1)
	  elseif kind == 1 then
	    War_CalMoveStep(WAR.CurID, len * 2, 1)
	    for r = 1, len * 2 do
	      for i = 0, r do
	        local j = r - i
	        if len < i or len < j then
	          SetWarMap(x0 + i, y0 + j, 3, 255)
	          SetWarMap(x0 + i, y0 - j, 3, 255)
	          SetWarMap(x0 - i, y0 + j, 3, 255)
	          SetWarMap(x0 - i, y0 - j, 3, 255)
	        end
	      end
	    end
	  elseif kind == 2 then
	    War_CalMoveStep(WAR.CurID, len, 1)
	    for i = 1, len - 1 do
	      for j = 1, len - 1 do
	        SetWarMap(x0 + i, y0 + j, 3, 255)
	        SetWarMap(x0 - i, y0 + j, 3, 255)
	        SetWarMap(x0 + i, y0 - j, 3, 255)
	        SetWarMap(x0 - i, y0 - j, 3, 255)
	      end
	    end
	  elseif kind == 3 then
	    War_CalMoveStep(WAR.CurID, 2, 1)
	    SetWarMap(x0 + 2, y0, 3, 255)
	    SetWarMap(x0 - 2, y0, 3, 255)
	    SetWarMap(x0, y0 + 2, 3, 255)
	    SetWarMap(x0, y0 - 2, 3, 255)
	  else
	    War_CalMoveStep(WAR.CurID, 0, 1)
	  end
  end
  
  CleanWarMap(7, 0)
  
  while true do
	if JY.Restart == 1 then
		break
	end
    local x2 = x
    local y2 = y
	Cat('ʵʱ��Ч����')
	WarDrawMap(1, x, y)
	if wugong == 26 then
		WarDrawAtt(x, y, atkfanwei, 4, nil, nil, nil, 1)
	else
		WarDrawAtt(x, y, atkfanwei, 4)
	end
    
    --�жϺϻ����ж��Ƿ��кϻ���

	local ZHEN_ID = -1;
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[WAR.CurID]["�ҷ�"] == WAR.Person[i]["�ҷ�"] and i ~= WAR.CurID and WAR.Person[i]["����"] == false then
			local nx = WAR.Person[i]["����X"]
			local ny = WAR.Person[i]["����Y"]
			local fid = WAR.Person[i]["������"]
			for j = 1, JY.Base["�书����"] do
				if JY.Person[fid]["�书" .. j] == wugong then         
					if math.abs(nx-x0)+math.abs(ny-y0)<9 then
						local flagx, flagy = 0, 0
						if math.abs(nx - x0) <= 1 then
							flagx = 1
						end
						if math.abs(ny - y0) <= 1 then
							flagy = 1
						end
						if x0 == nx then
							flagy = 1
						end
						if y0 == ny then
							flagx = 1
						end
						if between(x, x0, nx, flagx) and between(y, y0, ny, flagy) then
							--�ϻ��˵�ս�����
							ZHEN_ID = i
							
							--�滭�ϻ��ķ�Χ
							local tmp_id = WAR.CurID
							WAR.CurID = ZHEN_ID
							WarDrawAtt(WAR.Person[ZHEN_ID]["����X"] + x0 - x, WAR.Person[ZHEN_ID]["����Y"] + y0 - y, atkfanwei, 4)
							SetWarMap(nx,ny,7,3)
							WAR.CurID = tmp_id
																
							break;
						end
					end
				end
			end
			if ZHEN_ID >= 0 then
				break;
			end
		end
	end
    
	WarDrawMap(1, x, y)
    WarShowHead(GetWarMap(x, y, 2))
	
	--�ϻ��˱�ʶ
	if ZHEN_ID ~= -1 then
		local nx = WAR.Person[ZHEN_ID]["����X"]
		local ny = WAR.Person[ZHEN_ID]["����Y"]
		local dx = nx - x0
		local dy = ny - y0
		local size = CC.FontSmall;
		local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
		local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
									
		local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)
									
		DrawString(rx - size*1.5, ry-hb-size/2, "�ϻ���", M_DeepSkyBlue, size);
	end
	
	--��ʾ���Ը��ǵĵ�����Ϣ
	for i = 0, CC.WarWidth - 1 do
		for j = 0, CC.WarHeight - 1 do
			local target = GetWarMap(i, j, 7)
			if target ~= nil and target == 2 then
				if GetWarMap(i, j, 2) ~= nil and WAR.Person[GetWarMap(i, j, 2)]["������"] ~= nil then
					local x0 = WAR.Person[WAR.CurID]["����X"];
					local y0 = WAR.Person[WAR.CurID]["����Y"];
					local dx = i - x0
					local dy = j - y0
					local size = CC.FontSmall;
					local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
					local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
					
					local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)

					ry = ry - hb - CC.ScreenH/6;
							
					if ry < 1 then			--�����������ֹ������Ѫ�����
						ry = 1;
					end
					
					--��ʾѡ�����������ֵ
					local color = RGB(245, 251, 5);
					local hp = JY.Person[WAR.Person[GetWarMap(i, j, 2)]["������"]]["����"] or 0;
					local maxhp = JY.Person[WAR.Person[GetWarMap(i, j, 2)]["������"]]["�������ֵ"] or 0;
					
					local ns = JY.Person[WAR.Person[GetWarMap(i, j, 2)]["������"]]["���˳̶�"] or 0;
					local zd = JY.Person[WAR.Person[GetWarMap(i, j, 2)]["������"]]["�ж��̶�"] or 0;
					local len = #(string.format("%d/%d",hp,maxhp));
					rx = rx - len*size/4;
					
					--��ɫ�������ܵ�����ȷ��
					if ns < 33 then
						color = RGB(236, 200, 40)
					elseif ns < 66 then
						color = RGB(244, 128, 32)
					else
						color = RGB(232, 32, 44)
					end
					
					DrawString(rx, ry, string.format("%d",hp), color, size);
					DrawString(rx + #string.format("%d",hp)*size/2, ry, "/", C_GOLD, size);
					
					if zd == 0 then
						color = RGB(252, 148, 16)
					elseif zd < 50 then
						color = RGB(120, 208, 88)
					else
						color = RGB(56, 136, 36)
					end
					DrawString(rx + #string.format("%d",hp)*size/2 + size/2 , ry, string.format("%d", maxhp), color, size)
				end
			end
		end
	end

    ShowScreen()
	CleanWarMap(7, 0)
	lib.Delay(CC.BattleDelay)
    local key, ktype, mx, my = lib.GetKey()

    if key == VK_UP then
      y2 = y - 1
    elseif key == VK_DOWN then
      y2 = y + 1
    elseif key == VK_LEFT then
      x2 = x - 1
    elseif key == VK_RIGHT then
      x2 = x + 1
    elseif (key == VK_SPACE or key == VK_RETURN) then
      return x, y

    elseif key == VK_ESCAPE or ktype == 4 then
      return nil
    elseif ktype == 2 or ktype == 3 then
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
      mx = math.modf(mx)
      my = math.modf(my)
      for i = 1, 20 do
        if mx + i > 63 or my + i > 63 then
           return;
        end
        local hb = GetS(JY.SubScene, mx + i, my + i, 4)

        if math.abs(hb - CC.YScale * i * 2) < 8 then
          mx = mx + i
          my = my + i
        end
      end
      
      x2, y2 = mx + x0, my + y0
	    if ktype == 3 and (kind < 2 or x ~= x0 or y ~= y0) then
	      return x, y					
	    end
	    
    end
    if x2 >= 0 and x2 < CC.WarWidth and y2 >= 0 and y2 < CC.WarHeight then
			if GetWarMap(x2, y2, 3) ~= nil and GetWarMap(x2, y2, 3) < 128 then
	      x = x2
	      y = y2
		  end
		end
	end
end
--WarDrawAtt
--xlΪ�����ķ�Χ��ʾ
function WarDrawAtt(x, y, fanwei, flag, cx, cy, atk, xl)
  local x0, y0 = nil
  if cx == nil or cy == nil then
    x0 = WAR.Person[WAR.CurID]["����X"]
    y0 = WAR.Person[WAR.CurID]["����Y"]
  else
    x0, y0 = cx, cy
  end
  local kind = fanwei[1]			--������Χ
  local len1 = fanwei[2]
  local len2 = fanwei[3]
  local len3 = fanwei[4]
  local len4 = fanwei[5]
  local xy = {}
  local num = 0
  if kind == 0 then
    num = 1
    xy[1] = {x, y}
  elseif kind == 1 then
    if not len1 then
      len1 = 0
    end
    if not len2 then
      len2 = 0
    end
    num = num + 1
    xy[num] = {x, y}
    for i = 1, len1 do
      xy[num + 1] = {x + i, y}
      xy[num + 2] = {x - i, y}
      xy[num + 3] = {x, y + i}
      xy[num + 4] = {x, y - i}
      num = num + 4
    end
    for i = 1, len2 do
      xy[num + 1] = {x + i, y + i}
      xy[num + 2] = {x - i, y - i}
      xy[num + 3] = {x - i, y + i}
      xy[num + 4] = {x + i, y - i}
      num = num + 4
    end
  elseif kind == 2 then
    for tx = x - len1, x + len1 do
      for ty = y - len1, y + len1 do
        if len1 < math.abs(tx - x) + math.abs(ty - y) then
          
        else
        	num = num + 1
        	xy[num] = {tx, ty}
        end
        
      end
    end
  elseif kind == 3 then
    if not len2 then
      len2 = len1
    end
    local dx, dy = math.abs(x - x0), math.abs(y - y0)
    if dy < dx then
      len1, len2 = len2, len1
    end
    for tx = x - len1, x + len1 do
      for ty = y - len2, y + len2 do
        num = num + 1
        xy[num] = {tx, ty}
      end
    end
  elseif kind == 5 then
    if not len1 then
      len1 = 0
    end
    if not len2 then
      len2 = 0
    end
    num = num + 1
    xy[num] = {x, y}
    for i = 1, len1 do
      xy[num + 1] = {x + i, y}
      xy[num + 2] = {x - i, y}
      xy[num + 3] = {x, y + i}
      xy[num + 4] = {x, y - i}
      num = num + 4
    end
    if len2 > 0 then
      xy[num + 1] = {x + 1, y + 1}
      xy[num + 2] = {x + 1, y - 1}
      xy[num + 3] = {x - 1, y + 1}
      xy[num + 4] = {x - 1, y - 1}
      num = num + 4
    end
    for i = 2, len2 do
      xy[num + 1] = {x + i, y + 1}
      xy[num + 2] = {x - i, y - 1}
      xy[num + 3] = {x - i, y + 1}
      xy[num + 4] = {x + i, y - 1}
      xy[num + 5] = {x + 1, y + i}
      xy[num + 6] = {x - 1, y - i}
      xy[num + 7] = {x - 1, y + i}
      xy[num + 8] = {x + 1, y - i}
      num = num + 8
    end
  elseif kind == 6 then
    if not len2 then
      len2 = len1
    end
    xy[1] = {x + 1, y}
    xy[2] = {x - 1, y}
    xy[3] = {x, y + 1}
    xy[4] = {x, y - 1}
    num = num + 4
    if len1 > 0 or len2 > 0 then
      xy[5] = {x + 1, y + 1}
      xy[6] = {x + 1, y - 1}
      xy[7] = {x - 1, y + 1}
      xy[8] = {x - 1, y - 1}
      num = num + 4
      for i = 2, len1 do
        xy[num + 1] = {x + i, y + 1}
        xy[num + 2] = {x - i, y + 1}
        xy[num + 3] = {x + i, y - 1}
        xy[num + 4] = {x - i, y - 1}
        num = num + 4
      end
      for i = 2, len2 do
        xy[num + 1] = {x + 1, y + i}
        xy[num + 2] = {x + 1, y - i}
        xy[num + 3] = {x - 1, y + i}
        xy[num + 4] = {x - 1, y - i}
        num = num + 4
      end
    end
 elseif kind == 7 then
    if not len2 then
      len2 = len1
    end
    if len1 == 0 then
      for i = y - len2, y + len2 do
        num = num + 1
        xy[num] = {x, i}
      end
    elseif len2 == 0 then
      for i = x - len1, x + len1 do
        num = num + 1
        xy[num] = {i, y}
      end
    else
      for i = x - len1, x + len1 do
        num = num + 1
        xy[num] = {i, y}
        num = num + 1
        xy[num] = {i, y + len2}
        num = num + 1
        xy[num] = {i, y - len2}
      end
      for i = 1, len2 - 1 do
        xy[num + 1] = {x, y + i}
        xy[num + 2] = {x, y - i}
        xy[num + 3] = {x - len1, y + i}
        xy[num + 4] = {x - len1, y - i}
        xy[num + 5] = {x + len1, y + i}
        xy[num + 6] = {x + len1, y - i}
        num = num + 6
      end
    end
  elseif kind == 8 then
    xy[1] = {x, y}
    num = 1
    for i = 1, len1 do
      xy[num + 1] = {x + i, y}
      xy[num + 2] = {x - i, y}
      xy[num + 3] = {x, y + i}
      xy[num + 4] = {x, y - i}
      xy[num + 5] = {x + i, y + len1}
      xy[num + 6] = {x - i, y - len1}
      xy[num + 7] = {x + len1, y - i}
      xy[num + 8] = {x - len1, y + i}
      num = num + 8
    end
  elseif kind == 9 then
    xy[1] = {x, y}
    num = 1
    for i = 1, len1 do
      xy[num + 1] = {x + i, y}
      xy[num + 2] = {x - i, y}
      xy[num + 3] = {x, y + i}
      xy[num + 4] = {x, y - i}
      xy[num + 5] = {x - i, y + len1}
      xy[num + 6] = {x + i, y - len1}
      xy[num + 7] = {x + len1, y + i}
      xy[num + 8] = {x - len1, y - i}
      num = num + 8
    end
  elseif x == x0 and y == y0 then
    return 0
  elseif kind == 10 then
    if not len2 then
      len2 = 0
    end
    if not len3 then
      len3 = 0
    end
    if not len4 then
      len4 = 0
    end
    local fx, fy = x - x0, y - y0
    if fx > 0 then
      fx = 1
    elseif fx < 0 then
      fx = -1
    end
    if fy > 0 then
      fy = 1
    elseif fy < 0 then
      fy = -1
    end
    local dx1, dy1, dx2, dy2 = -fy, fx, fy, -fx
    dx1 = -(dx1 + fx) / 2
    dx2 = -(dx2 + fx) / 2
    dy1 = -(dy1 + fy) / 2
    dy2 = -(dy2 + fy) / 2
    if dx1 > 0 then
      dx1 = 1
    elseif dx1 < 0 then
      dx1 = -1
    end
    if dx2 > 0 then
      dx2 = 1
    elseif dx2 < 0 then
      dx2 = -1
    end
    if dy1 > 0 then
      dy1 = 1
    elseif dy1 < 0 then
      dy1 = -1
    end
    if dy2 > 0 then
      dy2 = 1
    elseif dy2 < 0 then
      dy2 = -1
    end
    for i = 0, len1 - 1 do
      num = num + 1
      xy[num] = {x + i * fx, y + i * fy}
    end
    for i = 0, len2 - 1 do
      num = num + 1
      xy[num] = {x + dx1 + i * fx, y + dy1 + i * fy}
      num = num + 1
      xy[num] = {x + dx2 + i * fx, y + dy2 + i * fy}
    end
    for i = 0, len3 - 1 do
      num = num + 1
      xy[num] = {x + 2 * dx1 + i * fx, y + 2 * dy1 + i * fy}
      num = num + 1
      xy[num] = {x + 2 * dx2 + i * fx, y + 2 * dy2 + i * fy}
    end
    for i = 0, len4 - 1 do
      num = num + 1
      xy[num] = {x + 3 * dx1 + i * fx, y + 3 * dy1 + i * fy}
      num = num + 1
      xy[num] = {x + 3 * dx2 + i * fx, y + 3 * dy2 + i * fy}
    end
  elseif kind == 11 then
    local fx, fy = x - x0, y - y0
    if fx > 1 then
      fx = 1
    elseif fx < -1 then
      fx = -1
    end
    if fy > 1 then
      fy = 1
    elseif fy < -1 then
      fy = -1
    end
    local dx1, dy1, dx2, dy2 = -fy, fx, fy, -fx
    if fx ~= 0 and fy ~= 0 then
      dx1 = -(dx1 + fx) / 2
      dx2 = -(dx2 + fx) / 2
      dy1 = -(dy1 + fy) / 2
      dy2 = -(dy2 + fy) / 2
      len1 = math.modf(len1 * 0.7071)
      for i = 0, len1 do
        num = num + 1
        xy[num] = {x + i * fx, y + i * fy}
        for j = 1, 2 * i + 1 do
          num = num + 1
          xy[num] = {x + i * fx + j * (dx1), y + i * fy + j * (dy1)}
          num = num + 1
          xy[num] = {x + i * fx + j * (dx2), y + i * fy + j * (dy2)}
        end
      end
    else
      for i = 0, len1 do
        num = num + 1
        xy[num] = {x + i * fx, y + i * fy}
        for j = 1, len1 - i do
          num = num + 1
          xy[num] = {x + i * fx + j * (dx1), y + i * fy + j * (dy1)}
          num = num + 1
          xy[num] = {x + i * fx + j * (dx2), y + i * fy + j * (dy2)}
        end
      end
    end
  elseif kind == 12 then
    local fx, fy = x - x0, y - y0
    if fx > 1 then
      fx = 1
    elseif fx < -1 then
      fx = -1
    end
    if fy > 1 then
      fy = 1
    elseif fy < -1 then
      fy = -1
    end
    local dx1, dy1, dx2, dy2 = -fy, fx, fy, -fx
    if fx ~= 0 and fy ~= 0 then
      dx1 = (dx1 + fx) / 2
      dx2 = (dx2 + fx) / 2
      dy1 = (dy1 + fy) / 2
      dy2 = (dy2 + fy) / 2
      len1 = math.modf(len1 * 1.41421)
      for i = 0, len1 do
        if i <= len1 / 2 then
          num = num + 1
          xy[num] = {x + i * fx, y + i * fy}
        end
        for j = 1, len1 - i * 2 do
          num = num + 1
          xy[num] = {x + i * fx + j * (dx1), y + i * fy + j * (dy1)}
          num = num + 1
          xy[num] = {x + i * fx + j * (dx2), y + i * fy + j * (dy2)}
        end
      end
    else
      for i = 0, len1 do
        num = num + 1
        xy[num] = {x + i * fx, y + i * fy}
        for j = 1, i do
          num = num + 1
          xy[num] = {x + i * fx + j * (dx1), y + i * fy + j * (dy1)}
          num = num + 1
          xy[num] = {x + i * fx + j * (dx2), y + i * fy + j * (dy2)}
        end
      end
    end
  elseif kind == 13 then
    local fx, fy = x - x0, y - y0
    if fx > 1 then
      fx = 1
    elseif fx < -1 then
      fx = -1
    end
    if fy > 1 then
      fy = 1
    elseif fy < -1 then
      fy = -1
    end
    local xx = x + fx * len1
    local yy = y + fy * len1
    for tx = xx - len1, xx + len1 do
      for ty = yy - len1, yy + len1 do
        if len1 < math.abs(tx - xx) + math.abs(ty - yy) then
          break;
        end
        num = num + 1
        xy[num] = {tx, ty}
      end
    end
  else
    return 0
  end
  
	--�����ķ�Χ
	if xl then
		local xl_x = WAR.Person[WAR.CurID]["����X"]
		local xl_y = WAR.Person[WAR.CurID]["����Y"]
		for i = 1, 11, 2 do
			for j = 1, 11, 2 do
				num = num + 1
				xy[num] = {xl_x - i, xl_y + j}
				num = num + 1
				xy[num] = {xl_x - i, xl_y - j}
				num = num + 1
				xy[num] = {xl_x + i, xl_y + j}
				num = num + 1
				xy[num] = {xl_x + i, xl_y - j}
			end
		end
	end
  
  if flag == 1 then
    local thexy = function(nx, ny, x, y)
	    local dx, dy = nx - x, ny - y
	    local hb = lib.GetS(JY.SubScene, nx, ny, 4)
	    return CC.ScreenW / 2 + CC.XScale * (dx - dy), CC.ScreenH / 2 + CC.YScale * (dx + dy) - hb
    end
    
    for i = 1, num do
    	if xy[i][1] >= 0 and xy[i][1] < CC.WarWidth and xy[i][2] >= 0 and xy[i][2] < CC.WarHeight then
      	local tx, ty = thexy(xy[i][1], xy[i][2], x0, y0)

	      if GetWarMap(xy[i][1], xy[i][2], 2) ~= nil and GetWarMap(xy[i][1], xy[i][2], 2) >= 0 and GetWarMap(xy[i][1], xy[i][2], 2) ~= WAR.CurID then
				if not inteam(WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["������"]) and WAR.Person[WAR.CurID]["�ҷ�"] then
		      	local x0 = WAR.Person[WAR.CurID]["����X"];
		      	local y0 = WAR.Person[WAR.CurID]["����Y"];
		      	local dx = xy[i][1] - x0
		        local dy = xy[i][2] - y0
		        local size = CC.FontSmall;
		        local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
		        local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
		        
		        local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)

		        ry = ry - hb - CC.ScreenH/6;
						
		        if ry < 1 then			--�����������ֹ������Ѫ�����
		        	ry = 1;
		        end
		      	
		      	--��ʾѡ�����������ֵ
		      	local color = RGB(245, 251, 5);
		      	local hp = JY.Person[WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["������"]]["����"];
		      	local maxhp = JY.Person[WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["������"]]["�������ֵ"];
		      	
		      	local ns = JY.Person[WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["������"]]["���˳̶�"];
		      	local zd = JY.Person[WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["������"]]["�ж��̶�"];
		      	local len = #(string.format("%d/%d",hp,maxhp));
		      	rx = rx - len*size/4;
		      	
		      	--��ɫ�������ܵ�����ȷ��
		      	if ns < 33 then
					color = RGB(236, 200, 40)
				elseif ns < 66 then
					color = RGB(244, 128, 32)
				else
					color = RGB(232, 32, 44)
				end
		      	
		      	DrawString(rx, ry, string.format("%d",hp), color, size);
		      	DrawString(rx + #string.format("%d",hp)*size/2, ry, "/", C_GOLD, size);
		      	
		      	if zd == 0 then
				      color = RGB(252, 148, 16)
				    elseif zd < 50 then
				      color = RGB(120, 208, 88)
				    else
				      color = RGB(56, 136, 36)
				    end
				    DrawString(rx + #string.format("%d",hp)*size/2 + size/2 , ry, string.format("%d", maxhp), color, size)
		      end
		      
	      	--lib.PicLoadCache(0, 0, tx, ty, 2, 200)
	      else
	      	--lib.PicLoadCache(0, 0, tx, ty, 2, 112)
	      end
	      
	    end
    end

  elseif flag == 2 then
    local diwo = WAR.Person[WAR.CurID]["�ҷ�"]
    local atknum = 0
    for i = 1, num do
      if xy[i][1] >= 0 and xy[i][1] < CC.WarWidth and xy[i][2] >= 0 and xy[i][2] < CC.WarHeight then
        local id = GetWarMap(xy[i][1], xy[i][2], 2)
      
	      if id ~= -1 and id ~= WAR.CurID then
	        local xa, xb, xc = nil, nil, nil
			local e_diwo = WAR.Person[id]["�ҷ�"]
			--�żһԵ������ָ
			if (JY.Person[WAR.Person[id]["������"]]["����"] == 304 and WAR.YSJZ == 0) then
				e_diwo = diwo
			end
			
	        if diwo ~= e_diwo then
				xa = 2
	        else
				xa = 0
	        end
			
			if WAR.HLZT[WAR.Person[id]["������"]] ~= nil then
				if e_diwo == diwo and math.random(100) <= 40 then
					xa = 2
				end
				if e_diwo ~= diwo and math.random(100) <= 40 then 
					xa = 0
				end
			end
			
	        local hp = JY.Person[WAR.Person[id]["������"]]["����"]
	        if hp < atk / 6 then
	          xb = 2
	        elseif hp < atk / 3 then
	          xb = 1
	        else
	          xb = 0
	        end
	        local danger = JY.Person[WAR.Person[id]["������"]]["�������ֵ"]
	        xc = danger / 500
	        atknum = atknum + xa * math.modf(xb * (xc) + 5)
	      end
      end
    end
    return atknum
  elseif flag == 3 then
    for i = 1, num do
    	if xy[i][1] >= 0 and xy[i][1] < CC.WarWidth and xy[i][2] >= 0 and xy[i][2] < CC.WarHeight then
			SetWarMap(xy[i][1], xy[i][2], 4, 1)
		end
    end
	--�书ѡ��Χ
  elseif flag == 4 then
    for i = 1, num do
    	if xy[i][1] >= 0 and xy[i][1] < CC.WarWidth and xy[i][2] >= 0 and xy[i][2] < CC.WarHeight then
			if GetWarMap(xy[i][1], xy[i][2], 2) ~= nil and GetWarMap(xy[i][1], xy[i][2], 2) >= 0 then
				--��Ϧ��Ů���۽����������Ƿ�ѧ�����ٲ�
				--�Զ�������
				if WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["������"] == 0 and JY.Person[615]["�۽�����"] == 1 and JLSD(0,100,0) and WAR.AutoFight == 0 and WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["�ҷ�"] then
					--�ð������Ʒ����Ϊ�������ٲ����ж�
					CC.TX["���ٲ�"] = 1
				end
				if match_ID(WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["������"], 498) and math.random(10) < 4 and WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["�ҷ�"] then
					--����Ѱ����Ʒ����Ϊ����������ˮ���ж�
					JY.Person[498]["Ʒ��"] = 30
				end					
				--С��Ӱ��
				if match_ID(WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["������"], 66) and WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["�ҷ�"] then
					--��С�ѵ�Ʒ����Ϊ����Ӱ�����ж�
					JY.Person[66]["Ʒ��"] = 90
				end
				--�������޼���תǬ��
				--�Զ�������
				if WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["������"] == 0 and JY.Base["����"] == 9  and PersonKF(0, 97) and WAR.AutoFight == 0 and WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["�ҷ�"] then
					--����35%����
					local chance = 36
					--ÿ������+1����
					chance = chance + JY.Base["��������"]
					if WAR.LQZ[0] == 100 then
						chance = chance + 10
					end
					if JLSD(0,chance,WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["������"]) then
						--JY.Person[614]["Ʒ��"] = 90
						CC.TX["��תǬ��"] = 1
					end
				end
			
				--���еĵз��ĵ�Ϊ2
				if not inteam(WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["������"]) and WAR.Person[WAR.CurID]["�ҷ�"] then
					SetWarMap(xy[i][1], xy[i][2], 7, 2)
				else
					SetWarMap(xy[i][1], xy[i][2], 7, 1)
				end
			else
				SetWarMap(xy[i][1], xy[i][2], 7, 1)
			end
		end
    end
  end
end

PNLBD = {}


--���׹���
PNLBD[76] = function()
	JY.Person[683]["�书1"] = 26
	JY.Person[683]["�书�ȼ�1"] = 600
    JY.Person[683]["�书2"] = 15
	JY.Person[683]["�书�ȼ�2"] = 500
    JY.Person[683]["�书3"] = 107
	JY.Person[683]["�书�ȼ�3"] = 50
end

--�������������
PNLBD[275] = function()
	JY.Person[62]["�书3"] = 169
	JY.Person[62]["�书�ȼ�3"] = 999
	JY.Person[62]["�츳�ڹ�"] = 169
end

--boss ռλ��ŭ
function BOSSBF(id, x, y)
	local pid = WAR.Person[id]['������']
	if r == 1 then
		return 
	end
	local s = WAR.CurID
	WAR.CurID =  id
	--1��ɫ��2��ɫ��3��ɫ��4��ɫ
	CleanWarMap(6,-1);
	    	
	local QMDJ = {"��","��","��","��"}
				
	--��������Χ��������
	SetWarMap(x, y, 4, math.random(4));
	    		
	for j=1, 2 do
	    SetWarMap(x + math.random(4), y + math.random(4), 4, math.random(4));
				for n = 30, 100 do
					local i = n
					if i > 100 then
						i = 100
					end
					Cat('ʵʱ��Ч����')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
		
		
	end
				
	for j=3, 4 do
		SetWarMap(x + math.random(4), y - math.random(4), 4, math.random(4));
				for n = 30, 100 do
					local i = n
					if i > 100 then
						i = 100
					end
					Cat('ʵʱ��Ч����')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
	end
				
	for j=5, 6 do
	    SetWarMap(x - math.random(4), y - math.random(4), 4, math.random(4));
				for n = 30,100 do
					local i = n
					if i > 100 then
						i = 100
					end
					Cat('ʵʱ��Ч����')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
	end
				
	for j=7, 8 do
		SetWarMap(x - math.random(4), y + math.random(4), 4, math.random(4));
				for n = 30, 100 do
					local i = n
					if i > 100 then
						i = 100
					end
					Cat('ʵʱ��Ч����')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
	end
	
	WAR.CurID =  s
end	
	
--���أ����Ŷݼ�
function WarNewLand(id, x, y)
	if WAR.ZDDH == 226 then
		return 
	end
	local pid = WAR.Person[id]['������']
	local r = JYMsgBox("���Ŷݼ�", "�Ƿ�Ҫ�������Ŷݼף�", {"��","��"}, 2, JY.Person[pid]["������"])
	if r == 1 then
		return 
	end
	local s = WAR.CurID
	WAR.CurID =  id
	--1��ɫ��2��ɫ��3��ɫ��4��ɫ
	CleanWarMap(6,-1);
	    	
	local QMDJ = {"��","��","��","��","��","��","��","��"}
				
	--��������Χ��������
	SetWarMap(x, y, 6, math.random(4));
	    		
	for j=1, 2 do
	    SetWarMap(x + math.random(6), y + math.random(6), 6, math.random(4));
				for n = 30, 40 do
					local i = n
					if i > 40 then
						i = 40
					end
					Cat('ʵʱ��Ч����')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
		
		
	end
				
	for j=3, 4 do
		SetWarMap(x + math.random(6), y - math.random(6), 6, math.random(4));
				for n = 30, 40 do
					local i = n
					if i > 40 then
						i = 40
					end
					Cat('ʵʱ��Ч����')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
	end
				
	for j=5, 6 do
	    SetWarMap(x - math.random(6), y - math.random(6), 6, math.random(4));
				for n = 30, 40 do
					local i = n
					if i > 40 then
						i = 40
					end
					Cat('ʵʱ��Ч����')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
	end
				
	for j=7, 8 do
		SetWarMap(x - math.random(6), y + math.random(6), 6, math.random(4));
				for n = 30, 40 do
					local i = n
					if i > 40 then
						i = 40
					end
					Cat('ʵʱ��Ч����')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
	end
	
	WAR.CurID =  s
end
		
--ս��������
function WarMain(warid, isexp)
	WarLoad(warid)			--��ʼ��ս������
	WarSelectTeam_Enhance()	--ѡ���ҷ����Ż��棩
	WarSelectEnemy()		--ѡ�����
	
	Health_in_Battle()		--�޾Ʋ�����Ѫ������
 
	if JY.Restart == 1 then
		return false
	end
	
	CleanMemory()
	--lib.PicInit()
	lib.ShowSlow(20, 1)
	WarLoadMap(WAR.Data["��ͼ"])	--����ս����ͼ
	
	--Ĭ���ڵ�ǰ����ս��
	local BattleField = JY.SubScene
	if WAR.ZDDH == 354 then
        BattleField = 25
    end
	--���������þ���ս��
	if WAR.ZDDH == 287 then
		BattleField = 116
	end

	for i = 0, CC.WarWidth-1 do
		for j = 0, CC.WarHeight-1 do
			lib.SetWarMap(i, j, 0, lib.GetS(BattleField, i, j, 0))
			lib.SetWarMap(i, j, 1, lib.GetS(BattleField, i, j, 1))
		end
	end
  
	--ѩɽ�仨��ˮս��
	if WAR.ZDDH == 42 then
		SetS(2, 24, 31, 1, 0)
		SetS(2, 30, 34, 1, 0)
		SetS(2, 27, 27, 1, 0)
	end
  
	--�ɰ滪ɽ�۽�����̨
	if WAR.ZDDH == 238 then
		for x = 24, 34 do
			for y = 24, 34 do
				lib.SetWarMap(x, y, 0, 1030)
			end
		end
		for y = 23, 35 do
			lib.SetWarMap(23, y, 1, 1174)
			lib.SetWarMap(35, y, 1, 1174)
		end
		for x = 24, 35 do
			lib.SetWarMap(x, 35, 1, 1174)
			lib.SetWarMap(x, 23, 1, 1174)
		end
		lib.SetWarMap(23, 23, 0, 1174)
		lib.SetWarMap(35, 35, 0, 1174)
		lib.SetWarMap(23, 35, 0, 1174)
		lib.SetWarMap(35, 23, 0, 1174)
		lib.SetWarMap(23, 23, 1, 2960)
		lib.SetWarMap(35, 35, 1, 2960)
		lib.SetWarMap(23, 35, 1, 2960)
		lib.SetWarMap(35, 23, 1, 2960)
	end
	--�����������
	if WAR.ZDDH == 348 or WAR.ZDDH == 349 or WAR.ZDDH == 350 then
		lib.SetWarMap(28, 6, 1, 1843*2)
        lib.SetWarMap(28, 5, 1, 1843*2)		
	end
 
	--20����֣���������
	if WAR.ZDDH == 289 then
		lib.SetWarMap(39, 29, 1, 1417*2)
		lib.SetWarMap(39, 30, 1, 1416*2)
		lib.SetWarMap(39, 31, 1, 1416*2)
		lib.SetWarMap(39, 32, 1, 1417*2)
		for i = 40, 43 do
			lib.SetWarMap(i, 30, 0, 35*2)
			lib.SetWarMap(i, 31, 0, 35*2)
			lib.SetWarMap(i, 32, 0, 35*2)
			lib.SetWarMap(i, 30, 1, 0)
			lib.SetWarMap(i, 32, 1, 0)
		end
		for i = 30, 32 do
			lib.SetWarMap(40, i, 0, 76*2)
			lib.SetWarMap(41, i, 0, 72*2)
		end
		lib.SetWarMap(15, 19, 1, 1843*2)
		lib.SetWarMap(15, 20, 1, 1843*2)
	end
	--20����֣���������
	if WAR.ZDDH == 337 then
		lib.SetWarMap(39, 29, 1, 1417*2)
		lib.SetWarMap(39, 30, 1, 1416*2)
		lib.SetWarMap(39, 31, 1, 1416*2)
		lib.SetWarMap(39, 32, 1, 1417*2)
		for i = 40, 43 do
			lib.SetWarMap(i, 30, 0, 35*2)
			lib.SetWarMap(i, 31, 0, 35*2)
			lib.SetWarMap(i, 32, 0, 35*2)
			lib.SetWarMap(i, 30, 1, 0)
			lib.SetWarMap(i, 32, 1, 0)
		end
		for i = 30, 32 do
			lib.SetWarMap(40, i, 0, 76*2)
			lib.SetWarMap(41, i, 0, 72*2)
		end

	end	
	--ս�Ĵ�ɽ����������
	if WAR.ZDDH == 290 then
		for i = 5, 34 do
			lib.SetWarMap(7, i, 1, 0)
			lib.SetWarMap(9, i, 1, 0)
			lib.SetWarMap(54, i, 1, 0)
			lib.SetWarMap(56, i, 1, 0)
		end
	end
  
	--ɱ��������
	if WAR.ZDDH == 54 then
		lib.SetWarMap(11, 36, 1, 2)
	end
  
	--�ı���Ϸ״̬
	JY.Status = GAME_WMAP
	  
	--������ͼ�ļ�
	--lib.PicLoadFile(CC.WMAPPicFile[1], CC.WMAPPicFile[2], 0)						--ս����ͼ���ڴ�����0
	
	--lib.LoadPNGPath(CC.HeadPath, 1, CC.HeadNum, limitX(CC.ScreenW/936*100,0,100))	--�����ͷ���ڴ�����1
	
	--lib.PicLoadFile(CC.ThingPicFile[1], CC.ThingPicFile[2], 2, 100, 100)			--��Ʒ��ͼ���ڴ�����2
	--lib.LoadPNGPath('./data/thing',0,-1,100)
	--lib.PicLoadFile(CC.EFTFile[1], CC.EFTFile[2], 3)								--��Ч��ͼ���ڴ�����3
	--lib.LoadPNGPath('./data/eft',0,-1,100)
	--lib.LoadPNGPath(CC.PTPath, 95, CC.PTNum, limitX(CC.ScreenW/936*100,0,100))
	
	--lib.LoadPNGPath(CC.UIPath, 96, CC.UINum, limitX(CC.ScreenW/936*100,0,100))
	
	--lib.LoadPNGPath(CC.IconPath, 98, CC.IconNum, limitX(CC.ScreenW/936*100,0,100))	--״̬ͼ�꣬�ڴ�����98
	
	--lib.LoadPNGPath(CC.HeadPath, 99, CC.HeadNum, 26.923076923)						--����Сͷ�����ڼ��������ڴ�����99
   
   -- lib.LoadPNGPath(CC.BodyPath, 90, CC.BodyNum, limitX(CC.ScreenW/936*100,0,100))	--������
	--lib.LoadPNGPath(CC.XTPath, 91, CC.XTNum, limitX(CC.ScreenW/936*100,0,100))	--UI	
	--lib.PicLoadFile(CC.BJ[1], CC.BJ[2], 92) 
    --lib.LoadPNGPath('./data/bj',0,-1,100)	
	--�޾Ʋ��������ս������
	local zdyy = math.random(10) + 99
	
	--15��̶�
	if WAR.ZDDH == 133 or WAR.ZDDH == 134 then
		zdyy = 27
	end
	
	--VS������ɮս�̶�
	if WAR.ZDDH == 80 then
		zdyy = 22
	end
	
	--��������ս�̶�
	if WAR.ZDDH == 54  then
		zdyy = 112
	end

	--����а�̶�
	if WAR.ZDDH == 170 then
		zdyy = 119
	end
	
	--�ɸ�ս�̶�
	if WAR.ZDDH == 278 then
		zdyy = 110
	end
	
	--�䵱ս����̶�
	if WAR.ZDDH == 22 then
		zdyy = 113
	end
	
	--20�����ս�̶�
	if WAR.ZDDH == 289 then
		zdyy = 115
	end
	
	--ս�Ĵ�ɽ�̶�
	if WAR.ZDDH == 290 then
		zdyy = 117
	end
	
	--��ħ���ɹ̶�
	if WAR.ZDDH == 291 then
		zdyy = 118
	end
	
	PlayMIDI(zdyy)
	
	--PlayMIDI(WAR.Data["����"])  
	  
	local warStatus = nil		 --ս��״̬
  
	WarPersonSort()			--���Ṧ����
	CleanWarMap(2, -1)
	CleanWarMap(6, -2)
	  

	for i = 0, WAR.PersonNum - 1 do
		
		if i == 0 then
		  WAR.Person[i]["����X"], WAR.Person[i]["����Y"] = WE_xy(WAR.Person[i]["����X"], WAR.Person[i]["����Y"])
		else
		  WAR.Person[i]["����X"], WAR.Person[i]["����Y"] = WE_xy(WAR.Person[i]["����X"], WAR.Person[i]["����Y"], i)
		end
		
		SetWarMap(WAR.Person[i]["����X"], WAR.Person[i]["����Y"], 2, i)
		
		local pid = WAR.Person[i]["������"]
		--lib.PicLoadFile(string.format(CC.FightPicFile[1], JY.Person[pid]["ͷ�����"]), string.format(CC.FightPicFile[2], JY.Person[pid]["ͷ�����"]), 4 + i)	--����ս��������ͼ���ڴ�����4-29��һ��ս������26�ˣ�
		
	end
	  
	--�Ṧ���ƶ����ӵļ���
	--xΪս���Ṧ��yΪ����
	local function getnewmove(x, y)
		local mob = x + y
		if mob > 478 then
			return 7
			elseif mob > 328 then
			return 6
			elseif mob >198 then
			return 5
			elseif mob > 148 then
			return 4
		elseif mob > 126 then
			return 3
		elseif mob > 116 then
			return 2
		else
			return 1
		end
	end
	local function getdelay(x, y)
		return math.modf(1.5 * (x / y + y - 3))
	end
	
	for i = 0, WAR.PersonNum - 1 do
		WAR.Person[i]["��ͼ"] = WarCalPersonPic(i)
	end
	WarSetPerson()
	WAR.CurID = 0
	WarDrawMap(0)
	lib.ShowSlow(20, 0)
	  
	--�޾Ʋ�������������ĳ�ʼ����λ��
	for i = 0, WAR.PersonNum - 1 do
		WAR.Person[i].Time = 800 - i * 1000 / WAR.PersonNum
        
			
        
		--����ɺ ÿ������+50���ʼ����
		if match_ID(WAR.Person[i]["������"], 79) then
			local JF = 0
			local bh = WAR.Person[i]["������"]
			for i = 1, JY.Base["�书����"] do
				if JY.Wugong[JY.Person[bh]["�书" .. i]]["�书����"] == 3 then
					JF = JF + 1
				end
			end
			WAR.Person[i].Time = WAR.Person[i].Time + (JF) * 50
		end
		
		if WAR.Person[i].Time > 990 then
			WAR.Person[i].Time = 990
		end
		
		--����壬һ��֮�󣬳�ʼ������
		--���羪��
		if match_ID_awakened(WAR.Person[i]["������"], 35, 1) or match_ID(WAR.Person[i]["������"], 500) or match_ID(WAR.Person[i]["������"], 9996) then
			WAR.Person[i].Time = 998
		end
		--������� ������
		if match_ID(WAR.Person[i]["������"], 592) or  match_ID(WAR.Person[i]["������"], 140) then
			WAR.Person[i].Time = 998
		end	

		--Ѫ������ ��ʼ����900
		if match_ID(WAR.Person[i]["������"], 97) then
			WAR.Person[i].Time = 900
		end
		--̫���ʼ����-200
		if JY.Person[WAR.Person[i]["������"]]["�Ա�"] == 2 then
			WAR.Person[i].Time = -200
		end
		
		--��ƽ֮ ��ʼ����900
		if match_ID(WAR.Person[i]["������"], 36) then
			WAR.Person[i].Time = 900
		end
		
		--ľ׮�ĳ�ʼ����
		if WAR.Person[i]["������"] == 591 and WAR.ZDDH == 226 then
			WAR.Person[i].Time = 0
		end
		
		--ʥ���� ��ʼ������200��100���
		local id = WAR.Person[i]["������"]
		if PersonKF(id, 93) then
			WAR.Person[i].Time = WAR.Person[i].Time + 200 + math.random(100)
		end
		--һέ�ɽ�
		if Curr_QG(id,186) then
		   WAR.Person[i].Time = WAR.Person[i].Time + 500
		end
		if WAR.Person[i].Time > 990 then
			WAR.Person[i].Time = 990
		end
		if JY.Person[id]["����"] == 312 then
			WAR.Person[i].Time = 998
		end
		-- �廨��
	    if JY.Person[id]["����"] == 349  then
            WAR.Person[i].Time = 900
		end			
		--�۽���Ӯ�����ά�����������֣���ȫ���з�λ��-500
		if WAR.Person[i]["������"] == 0 and JY.Person[606]["�۽�����"] == 1 then
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["�ҷ�"] then
					WAR.Person[j].Time = WAR.Person[j].Time - 75
				else
					WAR.Person[j].Time = WAR.Person[j].Time - 500
				end
				if WAR.Person[j].Time < -450 then
					WAR.Person[j].Time = -450
				end
				if WAR.Person[j].Time > 990 then
					WAR.Person[j].Time = 990
				end
			end
			WAR.Person[i].Time = 1005
		end
				
		if Curr_NG(id,152) then
             WAR.Person[i]['����'] = 1
		end		
		if match_ID(id,577) then
             WAR.Person[i]['����'] = 2
		end	


	end
  
	--Я����Ʒ�ĳ�ʼ��
	for a = 0, WAR.PersonNum - 1 do
		for s = 1, 4 do
			if JY.Person[WAR.Person[a]["������"]]["Я����Ʒ����" .. s] == nil or JY.Person[WAR.Person[a]["������"]]["Я����Ʒ����" .. s] < 1 then
				JY.Person[WAR.Person[a]["������"]]["Я����Ʒ" .. s] = -1
				JY.Person[WAR.Person[a]["������"]]["Я����Ʒ����" .. s] = 0;
			end
		end
	end
	
	--Ц��а�ߣ���ľ����������������ܣ��򶫷����Կ���������̬��ս
	if WAR.ZDDH == 54 and WAR.MCRS == 1 then
		local dfid;
		for i = 0, WAR.PersonNum - 1 do
			local id = WAR.Person[i]["������"]
			if id == 27 then
				dfid = i;
				break
			end
		end
		local orid = WAR.CurID
		WAR.CurID = dfid
		
		Cls()
		local KHZZ = {"��Ա���","�Է����ҵ�����ս","������"}
		
		for n = 1, #KHZZ + 25 do
			local i = n 
			if i > #KHZZ then 
				i = #KHZZ
			end
			lib.GetKey()
			Cat('ʵʱ��Ч����')
			Cls()
			DrawString(-1, -1, KHZZ[i], C_GOLD, CC.Fontsmall)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
		Cls()
		CurIDTXDH(WAR.CurID, 7, 1)
		
		for n = 1,50 do
			Cat('ʵʱ��Ч����')
			Cls()
			lib.Background(0,200,CC.ScreenW,400,78)
			NewDrawString(CC.ScreenW, CC.ScreenH/2 + 160, "������������̬", C_GOLD, 80)
			NewDrawString(CC.ScreenW, CC.ScreenH/2 + 360, "���� �����ڳ���ȼ��", C_RED, 70)
			
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
		Cls()
		local KHZZ2 = {"��֪�����"..JY.Person[0]["���2"],"�ú�����һ�������Ŀֲ���"}

		for n = 1, #KHZZ2 + 25 do
			local i = n 
			if i > #KHZZ2 then 
				i = #KHZZ2
			end
			lib.GetKey()
			Cat('ʵʱ��Ч����')
			Cls()
			DrawString(-1, -1, KHZZ2[i], C_GOLD, CC.Fontsmall)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
		WAR.CurID = orid
	end
	
	if WAR.ZDDH == 356 then
		for n = 1,50 do
			local j = 70 + n
			local k = 60 + n
			if j > 80 then 
				j = 80 
			end
			if k > 70 then 
				k = 70 
			end
			Cat('ʵʱ��Ч����')
			Cls()
			lib.Background(0,200,CC.ScreenW,400,78)
			NewDrawString(CC.ScreenW, CC.ScreenH/2 + 160, "����֮��", C_GOLD, j)
			NewDrawString(CC.ScreenW, CC.ScreenH/2 + 360, "���ֻ�ɽ", C_RED, k)
			
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
		Cat('�����')
		--local 
		--WAR.PD['�����4'] = {5,27,50,114}
	end
	--ʥ����ʹս���ֵ�������Ч
	if WAR.ZDDH == 14 then
		say("�ǣ����ʹ��", 173, 0)   --���ʹ
		say("�ǣ�����ʹ��", 174, 1)   --����ʹ
		say("�ǣ�����ʹ����ʥ��������", 175, 5)   --����ʹ����ʥ��������

        
		for n = 15,50 do
            local i = n 
            if i > 35 then 
                i = 35   
            end
            lib.GetKey()
			Cat('ʵʱ��Ч����')
			Cls()
			lib.GetKey()
			NewDrawString(-1, -1, "ʥ��������", C_GOLD, CC.DefaultFont+i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end

	--������̫��ս��׶Ի�
	if WAR.ZDDH == 302 then
		say("�ģ��������½����ǣ��м�Сл���巢��", 636, 0)
		say("�ģ��㻳����׳˼�ɣ��������������¡�", 0, 1)
		say("�ģ��鵶��ˮˮ�������ٱ��������", 636, 0)
		say("�ģ��������������⣬����ɢ��Ū���ۡ�", 0, 1)
	end
  
	--�ܵ�����ս���ҷ�����ȫ��Ϊ0
	if WAR.ZDDH == 237 then
		for a = 0, WAR.PersonNum - 1 do
			if WAR.Person[a]["�ҷ�"] == true then
				WAR.Person[a].Time = 0
			end
		end
	end

	--ȫ�����ӣ��������
	if WAR.ZDDH == 73 then

        
		for n = 15,50 do
            local i = n 
            if i > 35 then 
                i = 35   
            end
            lib.GetKey()
			Cat('ʵʱ��Ч����')
			Cls()
			lib.GetKey()
			NewDrawString(-1, -1, "�������", C_GOLD, CC.DefaultFont+i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end

			
		--���� г֮�������
	if WAR.ZDDH > 0 and JY.Base["����"] == 635 and JY.Person[0]["�������"] > 0 then

		for n = 15,50 do
            local i = n 
            if i > 35 then 
                i = 35   
            end
            lib.GetKey()
			Cat('ʵʱ��Ч����')
			Cls()
			lib.GetKey()
			NewDrawString(-1, -1, "г֮�������", C_GOLD, CC.DefaultFont+i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end
		--½�� ��֮�������ɰٴ�
	if WAR.ZDDH > 0 and JY.Base["����"] == 497 and JY.Person[0]["�������"] > 0   then
        
		for n = 15,50 do
            local i = n 
            if i > 35 then 
                i = 35   
            end
            lib.GetKey()
			Cat('ʵʱ��Ч����')
			Cls()
			lib.GetKey()
			NewDrawString(-1, -1, "��֮�������ɰٴ�", C_GOLD, CC.DefaultFont+i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end	
		--������1 �������
	if WAR.ZDDH > 0 and JY.Base["����"] == 129   then

		for n = 15,50 do
            local i = n 
            if i > 35 then 
                i = 35   
            end
            lib.GetKey()
			Cat('ʵʱ��Ч����')
			Cls()
			lib.GetKey()
			NewDrawString(-1, -1, "�������", C_GOLD, CC.DefaultFont+i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end		
		--ؤ�����
	if WAR.ZDDH ==  344  then

		for n = 15,50 do
            local i = n 
            if i > 35 then 
                i = 35   
            end
            lib.GetKey()
			Cat('ʵʱ��Ч����')
			Cls()
			lib.GetKey()
			NewDrawString(-1, -1, "��.����", C_GOLD, CC.DefaultFont+i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end	
	--��϶�����ʾ
	if CC.CoupleDisplay == 1 then
		local function fightcombo()
			local combo = {}
			for i = 1, #CC.COMBO do
				combo[i] = {CC.COMBO[i][1], CC.COMBO[i][2], CC.COMBO[i][3],0}
			end
			for i = 0, WAR.PersonNum - 1 do
				local t = WAR.Person[i]["������"]
				for j = 1, #combo do
					lib.GetKey()
					if match_ID(t, combo[j][1]) then
						for z = 0, WAR.PersonNum - 1 do
							local t2 = WAR.Person[z]["������"]
							if match_ID(t2, combo[j][2]) and WAR.Person[i]["�ҷ�"] == WAR.Person[z]["�ҷ�"] then
								combo[j][4] = 1
								break
							end
						end
					end
				end
			end
			for i = 1, #combo do
				if combo[i][4] == 1 then
					local t1 = combo[i][1]
					local t2 = combo[i][2]
					for k = 0, 20 do
                        local j = k 
                        if k > 10 then 
                           k = 10   
                        end
						lib.GetKey()
						local str = JY.Person[t1]["����"].."��"..JY.Person[t2]["����"]
						local str2 = combo[i][3]
                        Cat('ʵʱ��Ч����')
						Cls()
						DrawBox(150, CC.ScreenH / 3 + 30, CC.ScreenW - 150, CC.ScreenH / 3 * 2 - 20, C_BLACK)
						lib.LoadPNG(1, JY.Person[t1]["������"]*2, CC.ScreenW / 4 - 80, CC.ScreenH / 2 - 35, 1)
						lib.LoadPNG(1, JY.Person[t2]["������"]*2, CC.ScreenW / 4 + 50, CC.ScreenH / 2 - 35, 1)
						NewDrawString(CC.ScreenW / 2 * 3 - 170, CC.ScreenH + 120, str, C_ORANGE, 25)	
						NewDrawString(CC.ScreenW / 2 * 3 - 170, -1, str2, C_GOLD, 50 + j)
						ShowScreen()							
						lib.Delay(CC.BattleDelay)
					end		
				end
			end
		end
		fightcombo()
	end

	warStatus = 0
	buzhen()
	--Pre_Yungong()	--�޾Ʋ�����սǰ�˹�
	
	--�������Ŷݼף��ҷ��Ŵ���
	for j = 0, WAR.PersonNum - 1 do
		if match_ID(WAR.Person[j]["������"], 56) and WAR.Person[j]["�ҷ�"] == true then
			WarNewLand(j, WAR.Person[j]["����X"], WAR.Person[j]["����Y"])
			break
		end
	end
	
	WAR.Delay = GetJiqi()
	local startt, endt = lib.GetTime()
  
 
  --ս����ѭ��
  while true do
	if JY.Restart == 1 then
		return false
	end
	
    
    WAR.ShowHead = 0
	WAR.CurID = DrawTimeBar()
    if WAR.ZYHB == 1 then
		WAR.ZYHB = 2
    end	
    Cat('�����ƶ�����')
    WarDrawMap(0)
    lib.GetKey()
    ShowScreen()
    local p = WAR.CurID
    local id = WAR.Person[p]["������"]
    --for p = 0, WAR.PersonNum - 1 do
	--	lib.GetKey()

	if WAR.Person[p]["����"] == false and JY.Person[id]['����'] > 0 then
      	WAR.Person[p].Time = 1000
	    Cat('ʵʱ��Ч����')
		WarDrawMap(0)
        local keypress = lib.GetKey()
        
        if WAR.AutoFight == 1 and (keypress == VK_SPACE or keypress == VK_RETURN) then
			WAR.AutoFight = 0
        end

        ShowScreen()
		lib.Delay(CC.BattleDelay)
        WAR.ShowHead = 0
        WAR.Person[p].TimeAdd = 0
        local r = nil
        local pid = WAR.Person[WAR.CurID]["������"]
        WAR.Defup[pid] = nil
		--�������
		
		--��ң���磬�ж�ǰ�ָ�
		--���ҵڶ��²�����0
		if WAR.XYYF[pid] and WAR.XYYF[pid] == 11 and WAR.ZYHB ~= 2 then
			WAR.XYYF[pid] = nil
		end
		
		--������ָ��ж�ǰ�ָ�
        if match_ID(pid, 53) then
			WAR.TZ_DY = 0
        end
		
		--Ľ�ݸ���ָ��ж�ǰ�ָ�
        if match_ID(pid, 51) then
			WAR.TZ_MRF = 0
        end
		
		--���࣬�ж�ǰ�����ж���0
	    if match_ID(pid, 604) then
			Cat('��������쳣',WAR.CurID)
	    end
		
		--���ţ��ж���ʼǰ��60%���ʽ��͵з�����-150��
		if match_ID(pid, 629) and JLSD(20,80,pid) then
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
					WAR.Person[j].TimeAdd = WAR.Person[j].TimeAdd - 150
				end
			end
			DrawTimeBar2()
		end
		--��ʤǧ�� 
		if match_ID(pid, 9968) and JLSD(20,80,pid) then
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
					WAR.Person[j].TimeAdd = WAR.Person[j].TimeAdd - 150
				end
			end
			DrawTimeBar2()
		end
        --�𴦻�ͨ�ü�ʱ״̬�ѷ�
		if match_ID(pid,68) and WAR.JSZT1[pid] == nil then
				WAR.JSZT1[pid] = 3
		     end
		 
		--�����Ϣ��60%������Ϣ
		if Curr_NG(pid, 100) and JLSD(0,60,pid) then
			WarDrawMap(0); --���������򶯻�λ���޷�������ʾ
			CurIDTXDH(WAR.CurID, 19,1,"�����Ϣ",C_ORANGE);
			--WAR.XTTX = 1
			War_RestMenu()
			--WAR.XTTX = 0
		end
		--��������
		 if match_ID(pid,574) then
              local txsh = math.random(5)	 
		         for j = 0, WAR.PersonNum - 1 do
				     if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then 
                        if  WAR.XRZT1[WAR.Person[j]["������"]] == nil and JLSD(0,60,pid) then     
	                        WAR.XRZT1[WAR.Person[j]["������"]] = 2
	                   end
                   end
               end
         end
		--�����
		if match_ID(pid,577) then 
			WAR.WFCZ[pid] = (WAR.WFCZ[pid] or 0) + 1
			if WAR.WFCZ[pid] > 5 then
				WAR.WFCZ[pid] = 5
			end
		end

			--����ʱ��
		if WAR.BTZT[id] ~= nil then
			WAR.BTZT[id] = WAR.BTZT[id] - 1
			if WAR.BTZT[id] < 1 then
				WAR.BTZT[id] = nil
			end
		end
        if Curr_NG(pid,100) and WAR.PD["���커��CD"][pid] == nil then
			WAR.PD["���커��"][pid] = 500
			WarDrawMap(0); --���������򶯻�λ���޷�������ʾ
			CurIDTXDH(WAR.CurID, 80,1,"�����������",C_ORANGE);
			WAR.Person[WAR.CurID]['����'] = 3
			WAR.PD["���커��CD"][pid] = 100
		end
		--������Ԫ��һ
		if Curr_NG(pid,106)  and (JY.Person[pid]["��������"] == 1 or JY.Person[pid]["��������"] == 3)then 
			Cat('��������쳣',WAR.CurID)
			WarDrawMap(0); --���������򶯻�λ���޷�������ʾ
			CurIDTXDH(WAR.CurID, 78,1,"����.��Ԫ��һ",C_ORANGE);
			WAR.JHZT = 1
		end
		
		--����״̬
		if WAR.JHZT==1 then				
			JY.Person[pid]["�ж��̶�"] = 0
			JY.Person[pid]["���˳̶�"] = 0
			JY.Person[pid]["����̶�"] = 0
			JY.Person[pid]["���ճ̶�"] = 0
			--��Ѫ
			if WAR.LXZT[pid] ~= nil then
				WAR.LXZT[pid] = nil
			end
		end	
		
	    WAR.JHZT=0 

		--������������Զ�����
		if Curr_NG(pid, 103) then
			WarDrawMap(0); --���������򶯻�λ���޷�������ʾ
			War_ActupMenu()
		end	

		--������
		if match_ID(pid,9979) and WAR.ZYHB ~= 2 then
			Bagua(pid)
		end

		--ս����ʱ������100ʱ����������������
		if WAR.ZDDH == 253 and match_ID(pid, 631) and WAR.ZZRZY == 0 and 100 < WAR.SXTJ then
			say("���̣�������������ͨ���繥��һ�ˣ����������������ػ�����������ܹ����󣿣��������ܷ��Ķ��ã�ͬʱ�������������������Ӧ�ԣ���", 357, 0,"������")  --�Ի�
			if JY.Base["����"] == 631 then
				JY.Person[0]["���һ���"] = 1
			else
				JY.Person[631]["���һ���"] = 1
			end
			WAR.ZZRZY = 1
		end

		--�ж�ʱ��ʾѪ��
		WAR.ShowHP = 1
        
		WAR.PD['��������������'][pid] = nil
        
        
		--�޾Ʋ������ж�ʱ����ȡָ��
		if WAR.HMZT[pid] ~= nil then			--����״̬
			WarDrawMap(0); --���������򶯻�λ���޷�������ʾ
			CurIDTXDH(WAR.CurID, 94,1,"������",C_ORANGE)			
        elseif WAR.ZDDH == 354 then
            r = War_Auto()
        elseif inteam(pid) and WAR.Person[p]["�ҷ�"] then
			--����״̬50%�����Զ�
			if WAR.HLZT[pid] ~= nil and math.random(100) <= 50 then
				r = War_Auto()
			elseif WAR.AutoFight == 0 then
				r = War_Manual()
			elseif JY.Person[pid]["�����Զ�"] == 1 then
				r = War_Manual()
			else
				r = War_Auto()
			end
        else
			r = War_Auto()
        end
		
		if JY.Restart == 1 then
			return false
		end
        
		
        --����������һ���
        if WAR.ZYHB == 1 then
            WAR.ATK['����'] = p    
			WAR.Person[p].Time = 1000
			if WAR.ZHB == 0 then	--�ܲ�ͨ�Ķ����������ﲻ���ظ���¼
				WAR.ZYYD = WAR.Person[p]["�ƶ�����"]
			end

			--�ֻ�͵Ǯ
			if WAR.YJ > 0 then
				instruct_2(174, WAR.YJ)
				WAR.YJ = 0
			end
        else
	        if WAR.ZYHB == 2 then
				WAR.ZYHB = 0
	        end
	        
	        WAR.Person[p].Time = WAR.Person[p].Time - 1000
	        if WAR.Person[p].Time < -500 then
	          WAR.Person[p].Time = -500
	        end
		--������ ��23	
	        if WAR.SL23  == 1 and match_ID(pid, 584) then
		   WAR.SL23 = 0
		   end   
	 	        
          --�������
			if ZDGH(WAR.CurID,9998) then	
			    JY.Person[id]["�ж��̶�"] = 0
			    JY.Person[id]["���˳̶�"] = 0
			    JY.Person[id]["���ճ̶�"] = 0
			    JY.Person[id]["����̶�"] = 0					
			    if WAR.LXZT[id] ~= nil then
					WAR.LXZT[id] = nil
			    end
				local heal_amount1;
				local heal_amount;
				heal_amount1 = (JY.Person[id]["�������ֵ"] - JY.Person[id]["����"])
				heal_amount = limitX(math.modf(heal_amount1 * 0.05),100,200)
					if heal_amount < 100 then
					heal_amount = 100
					end
					if  JY.Base["��������"] > 6 or not inteam(id) then
						heal_amount = math.modf(heal_amount1 * 0.1)
                    end
					WAR.Person[WAR.CurID]["��������"] = AddPersonAttrib(id, "����", heal_amount);
					Cls();
					War_Show_Count(WAR.CurID, "");
		  end

		   --�޺���ħ�� ÿ�غϻظ�����
			if PersonKF(id, 96) and JY.Person[id]["����"] > 0 then
				local heal_amount;
				heal_amount = limitX(JY.Person[id]["�������ֵ"] - JY.Person[id]["����"],1000,2000)
				if Curr_NG(id, 96) then
					heal_amount = math.modf(heal_amount * 0.1)
				else
					heal_amount = math.modf(heal_amount * 0.05)
				end
				WAR.Person[WAR.CurID]["��������"] = AddPersonAttrib(id, "����", heal_amount);
				Cls();
				War_Show_Count(WAR.CurID, "�޺���ħ���ָ�����");
			end
			--��������ÿ�غϸ���������������
			if PersonKF(id,207) and JY.Person[id]["����"] > 0 and JY.Person[id]["����"] > 0 and JY.Person[id]["����"] < JY.Person[id]["�������ֵ"] then
			local krnl = limitX(math.modf(JY.Person[id]["����"]/50),100,200)
			 CurIDTXDH(WAR.CurID, 77,1,"�������",C_ORANGE);
			WAR.Person[WAR.CurID]["��������"] = AddPersonAttrib(id, "����", krnl);
			Cls();
			WAR.Person[WAR.CurID]["��������"] = AddPersonAttrib(id, "����", -krnl);
			Cls();
			War_Show_Count(WAR.CurID, "");
			end  
	        
	        --��ϼ���ж��󣬻ظ�����
			if PersonKF(id, 89) then
				local HN;
				if Curr_NG(id, 89) then
					HN = math.modf((JY.Person[id]["�������ֵ"] - JY.Person[id]["����"])*0.2)
				else
					HN = math.modf((JY.Person[id]["�������ֵ"] - JY.Person[id]["����"])*0.1)
				end
				WAR.Person[WAR.CurID]["��������"] = AddPersonAttrib(id, "����", HN);
				Cls();
				War_Show_Count(WAR.CurID, "��ϼ�񹦻ظ�����");
			end
         --÷�����ж������ֵ+10 ����ֵ+5
			if match_ID(id,507) then
				local bfz = 0
				local zsz = 0
				bfz = bfz + 10
				zsz =  zsz + 5
				--WAR.ZSXS[id] = 1
				--WAR.BFXS[id] = 1
				AddPersonAttrib(id,'���ճ̶�',zsz)
				AddPersonAttrib(id,'���ճ̶�',bfz)
				WAR.ZSXS[id] = zsz
				WAR.BFXS[id] = bfz
			end     
	        --��Ԫ���ж��󣬼�������
			--�����
			if PersonKF(id, 90) or (id == 0 and JY.Base["����"] == 189) then
				local NS;
				NS = 5 + math.modf(JY.Person[id]["���˳̶�"]/10)
				WAR.Person[WAR.CurID]["���˵���"] = (WAR.Person[WAR.CurID]["���˵���"] or 0) + AddPersonAttrib(id, "���˳̶�", -NS)
				Cls();
				War_Show_Count(WAR.CurID, "��Ԫ���ظ�����");
			end

	        --��Ƥ���� ÿ�غϽⶾ
			if JY.Person[id]["����"] == 61 and JY.Person[id]["�ж��̶�"] > 0 then
				local JD = 25 + 10 * (JY.Thing[61]["װ���ȼ�"]-1)
				if JY.Person[id]["�ж��̶�"] < JD then
					JD = JY.Person[id]["�ж��̶�"]
				end
				WAR.Person[WAR.CurID]["�ⶾ����"] = -AddPersonAttrib(id, "�ж��̶�", -JD)
				Cls();
				War_Show_Count(WAR.CurID, "��Ƥ���������ⶾ");
			end
			
			--�޾Ʋ������ȴ�
			if WAR.Wait[id] == 1 then
				WAR.Wait[id] = 0
				WAR.Person[p].Time = WAR.Person[p].Time + 400
			end
			
			--�������
			if WAR.HMGXL[id] == 1 then
				WAR.HMGXL[id] = 0
				WAR.Person[p].Time = WAR.Person[p].Time + 300
			end
		
			--��ƽ֮�����˺�����
			if match_ID_awakened(id, 36, 1) and WAR.LPZ > 0 then
				WAR.Person[p].Time = WAR.Person[p].Time + WAR.LPZ
				WAR.LPZ = 0
			end
 

			--������ӻ�
	        if match_ID(id, 49) and WAR.XZZ == 1 then
				WAR.XZZ = 0
				WAR.Person[p].Time = WAR.Person[p].Time + 200
	        end
	        
			--����������Ȼ 
	        if match_ID(id, 5)  and WAR.ZSF == 1 then
				WAR.Person[p].Time = WAR.Person[p].Time + 500
				WAR.ZSF = 0
	        end		
 
            --if WAR.PD['���ϵ�'][pid] == 1 then
            if WAR.PD['����'][id] ~= nil then 
                WAR.Person[p].Time = WAR.Person[p].Time + WAR.PD['����'][id] 
                WAR.PD['����'][id] = nil
            end
               -- WAR.PD['���ϵ�'][pid] = nil
           -- end
            
			--���ʫ�ƻ��� 
	        if match_ID(id, 636) and WAR.QLBLX == 1 then
				WAR.Person[p].Time = WAR.Person[p].Time + 200
				WAR.QLBLX = 0
	        end
			
			--�ⲻƽ���콣
			if match_ID(id, 142) and WAR.KFKJ == 1 then
				WAR.Person[p].Time = WAR.Person[p].Time + 150
				WAR.KFKJ = 0
			end
			
			--�Ž��洫������ʽ������200
			if WAR.JJDJ == 1 and id == 0 then
				WAR.JJDJ = 0
				WAR.Person[p].Time = WAR.Person[p].Time + 200
			end 
		
			--���˷������200 ��һ��
			if Curr_QG(id,145) or match_ID(id,633) then
				WAR.Person[p].Time = WAR.Person[p].Time + 200
			end
			--�� �羪��
			if match_ID(id,9996) then
				WAR.Person[p].Time = WAR.Person[p].Time + 200
			end
			--���Ṧ
			if WAR.YQG == 1 then
				WAR.Person[p].Time = WAR.Person[p].Time + 500
				WAR.YQG = 0
			end
	        
	        --����棬����õ�ʳ��
	        if match_ID(id, 81) and WAR.ZJZ == 0 and JLSD(0,40,id) then
				instruct_2(210, 10)
				WAR.ZJZ = 1
	        end
	        

	        --������ж�������ʼλ�ö�������
	        --�����ٹ�����֮һʱÿ��100�����ж�����λ�ü�100
	        if match_ID(id, 58) and JY.Person[id]["����"] < JY.Person[id]["�������ֵ"]/2 then
	        	WAR.Person[p].Time = WAR.Person[p].Time + math.floor(JY.Person[id]["�������ֵ"]/2 - JY.Person[id]["����"]);
	        end
	          
			if WAR.PD['�����'][id] ~= nil and WAR.PD['�����'][id] > 0 then 
				local rf = WAR.PD['�����'][id]
				WAR.Person[p].Time = WAR.Person[p].Time + rf*300
			    if WAR.Person[p].Time > 980 then
					WAR.Person[p].Time = 980
			    end				
				WAR.PD['�����'][id] = nil
			end
			
			--�ֻ�͵Ǯ
	        if WAR.YJ > 0 then
				instruct_2(174, WAR.YJ)
				WAR.YJ = 0
	        end
	        

				--������1 ͬ�齣�� 30ʱ��
			if WAR.TGJF[id] ~= nil then
				WAR.TGJF[id] = nil
			end	
				
			--��Զ��ʹ��̫��ȭ��̫�����������Զ��������״̬
			if match_ID(id, 171)  and WAR.WDRX == 1  then
				War_DefupMenu()
				WAR.WDRX = 0
			end
			
			--̫�����Զ�����
	        if PersonKF(id,171) and WAR.Defup[id] == nil then
				WarDrawMap(0); --���������򶯻�λ���޷�������ʾ
				War_DefupMenu()
			end
			
            if WAR.PD['������Ǳ������'][id] == 1 then 
                War_DefupMenu()
                WAR.PD['������Ǳ������'][id] = nil
            end
            
            if WAR.PD['���ϵ�������'][id] ~= nil then 
                WAR.PD['���ϵ�������'][id] = WAR.PD['���ϵ�������'][id] - 1 
                if WAR.PD['���ϵ�������'][id] < 1 then 
                    WAR.PD['���ϵ�������'][id] = nil   
                end
            end
            
	        if WAR.Actup[id] ~= nil then
				if WAR.ZXXS[id] ~= nil then				--��ϼ����״̬����������
					WAR.ZXXS[id] = WAR.ZXXS[id] - 1
					if WAR.ZXXS[id] == 0 then
						WAR.ZXXS[id] = nil
					end
				else
					WAR.Actup[id] = WAR.Actup[id] - 1	--�������ж�һ�μ�1
				end
	        end
	        
	        if WAR.Actup[id] == 0 then
				WAR.Actup[id] = nil
	        end
			
			if WAR.SLSX[pid] ~= nil then
				WAR.SLSX[pid] = WAR.SLSX[pid] - 1
				if WAR.SLSX[pid] == 0 then
					WAR.SLSX[pid] = nil
				end
			end
			
				--[[�Ȼ�״̬������󣬵���״̬�ָ�
				if WAR.MHZT[id] ~= nil then
					WAR.MHZT[id] = WAR.MHZT[id] - 1
					if WAR.MHZT[id] < 1 then
						WAR.MHZT[id] = nil
						if not inteam(id) then
                            WAR.Person[p]["�ҷ�"] = false
                        end
                    end
                end	]]
                
			if WAR.MRSHZT[id]~= nil then
			   WAR.MRSHZT[id]= WAR.MRSHZT[id] - 1
			    if WAR.MRSHZT[id]  == 0 then
				 WAR.MRSHZT[id] = nil
			end   
		end	
			--����״̬
			if WAR.Focus[id] ~= nil then
				WAR.Focus[id] = nil
			end

			--����״̬������󣬵���״̬�ָ�
			if WAR.HLZT[id] ~= nil then
				WAR.HLZT[id] = WAR.HLZT[id] - 1
				if WAR.HLZT[id] < 1 then
					WAR.HLZT[id] = nil
				end
			end
                
			--����״̬
			if WAR.SZZT[id] ~= nil then
				WAR.SZZT[id] = nil
			end	
           if WAR.PD["����"][id] ~= nil then
              WAR.PD["����"][id] = nil
		   end	
	        --�ٻ�״̬	        --äĿ״̬�ָ�
		
	        if WAR.KHCM[pid] ==2 then
				WAR.KHCM[pid] =WAR.KHCM[pid] - 1
				if WAR.KHCM[pid] == 0 then
					WAR.KHCM[pid] = nil 
				end
                for k = 0,10 do
                    Cat('ʵʱ��Ч����')
                    Cls()
                    DrawStrBox(-1, -1, "äĿ״̬�ָ�", C_ORANGE, CC.DefaultFont)
                    ShowScreen();
                    lib.Delay(CC.BattleDelay)
                end
	        end
			--����
			if WAR.HMZT[pid] ~= nil then
				WAR.HMZT[pid] = nil
			end
            --�ٻ�
		   if WAR.CHZT[pid]~=nil  then
			    WAR.CHZT[pid] = WAR.CHZT[pid] - 1
				if WAR.CHZT[pid] == 0 then
					WAR.CHZT[pid] = nil
				end
			end	
			--����״̬1
			if WAR.XRZT1 [pid]~=nil  then
			    WAR.XRZT1[pid] = WAR.XRZT1[pid] - 1
				if WAR.XRZT1[pid] == 0 then
					WAR.XRZT1[pid] = nil
				end
			end	
			--��������
			if WAR.PD["��������"][pid]~=nil  then
			    WAR.PD["��������"][pid] = WAR.PD["��������"][pid] - 1
				if WAR.PD["��������"][pid] == 0 then
					WAR.PD["��������"][pid] = nil
				end
			end		
		    if WAR.HQT_CD > 0  then
			    WAR.HQT_CD = WAR.HQT_CD - 1
			end				
			--�ж���©������
			WAR.Weakspot[id] = 0
			--���ϳ�����������
			if PersonKF(id,183) then
			WAR.Weakspot[id] = nil
			end
			--˫���ϱ�������
			if ShuangJianHB(id)  then
			WAR.Weakspot[id] = nil
			end
			--�٤������
			if PersonKF(id,169)  then
			WAR.Weakspot[id] = nil
			end
			--��а��ȴʱ��ָ�
			if WAR.BXLQ[id]  then
				for i = 1, 6 do
					WAR.BXLQ[id][i] = WAR.BXLQ[id][i] - 1
					if WAR.BXLQ[id][i] < 0 then
						WAR.BXLQ[id][i] = 0
					end
				end
			end
			--������ȴʱ��ָ�
			if WAR.JYLQ[id]  then
				for i = 1, 3 do
					WAR.JYLQ[id][i] = WAR.JYLQ[id][i] - 1
					if WAR.JYLQ[id][i] < 0 then
						WAR.JYLQ[id][i] = 0
					end
				end
			end			
			--�̺���ȴʱ��ָ�
			--[[
			if WAR.LXBHLQ[id] then
				for i = 1, 6 do
					WAR.LXBHLQ[id][i] = WAR.LXBHLQ[id][i] - 1
					if WAR.LXBHLQ[id][i] < 0 then
						WAR.LXBHLQ[id][i] = 0
					end
				end
			end			
			]]
			--�Ƿ���������ָֻ�
	        JY.Wugong[13]["����"] = "����"
	        
	        --�ܲ�ͨ��ÿ�ж�һ�Σ�����ʱ�˺�һ+10%
	        if match_ID(id, 64) then
				WAR.ZBT = WAR.ZBT + 1
	        end
			if match_ID(id,9984) then
				if WAR.PD["�����"][id] == nil then
                   WAR.PD["�����"][id] = 1
				else
                   WAR.PD["�����"][id] = WAR.PD["�����"][id] +1
				end
				if WAR.PD["�����"][id] > 6 then
					WAR.PD["�����"][id] = 6
				end
			end

			
			--��������������״̬����
			if match_ID(id, 129) and WAR.BDQS > 0 then
				WAR.BDQS = WAR.BDQS - 1
				if WAR.BDQS == 0 then
					CurIDTXDH(WAR.CurID, 126,1,"��������������",C_GOLD);
				end
			end
			
			--��ŭ�ָ�
	        if WAR.LQZ[id] == 100 then
				--��������������״̬�ж���ŭ����
				if not (match_ID(id, 129) and WAR.BDQS > 0) then
					if  match_ID(id,639) then
	                 WAR.LQZ[id] = math.modf(60,90)
				else
					WAR.LQZ[id] = 0			  
				end
	        end
		end	
				
			--��ڤ�񹦸��Լ���ŭ��
	        if WAR.BMSGXL > 0 and id == 0 then
	           WAR.LQZ[id] =(WAR.LQZ[id] or 0)+WAR.BMSGXL
	           if WAR.LQZ[id] > 100 then
	              WAR.LQZ[id] = 100
	              WAR.BMSGXL = 0
                  if WAR.LQZ[id] ~= nil and WAR.LQZ[id] == 100 then
	                 CurIDTXDH(WAR.CurID, 6, 1, "ŭ������")
				  end
			   end		
            end
            
			--�������У��ж���ָ�ŭ��
			if id == 0 and JY.Base["��׼"] == 4 and WAR.YZHYZ > 0 then
				WAR.LQZ[id] = limitX((WAR.LQZ[id] or 0) + WAR.YZHYZ, 0, 100)
				WAR.YZHYZ = 0
				if WAR.LQZ[id] ~= nil and WAR.LQZ[id] == 100 then
					CurIDTXDH(WAR.CurID, 6, 1, "ŭ������")
				end
			end

	        --��� ��  ����~~
	        if WAR.XK == 1 then
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["������"] == 58 and 0 < JY.Person[WAR.Person[j]["������"]]["����"] and WAR.Person[j]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
						WAR.Person[j].Time = 980
						say("�����������������������ȣ�����������������������������������������������������������������", 58,0)
						WAR.XK = 2
					end
				end
	        end
	     	--[[   
	        --���� ��֪����
	        if WAR.FLHS5 == 1 and WAR.ZYZD == 0 then
				local z = WAR.CurID
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["������"] == 0 and 0 < JY.Person[0]["����"] then
						WAR.FLHS5 = 2
						WAR.CurID = j
					end
				end
				if WAR.FLHS5 == 2 and WAR.AutoFight == 0 then
					WAR.Person[WAR.CurID]["�ƶ�����"] = 6
					War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["�ƶ�����"], 0)
					local x, y = nil, nil
					while 1 do
						if JY.Restart == 1 then
							break
						end
						x, y = War_SelectMove()
						if x ~= nil then
							WAR.ShowHead = 0
							War_MovePerson(x, y)
							break;
						end
					end
				end
				WAR.FLHS5 = 0
				WAR.CurID = z
	        end
			]]
	        --[[���� ��ӹ֮��
	if WAR.ZYZD == 1 then
		local z = WAR.CurID
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["������"] == 0 and 0 < JY.Person[0]["����"] then
				WAR.ZYZD = 2
				WAR.CurID = j
                break
			end
		end
		if WAR.ZYZD == 2  then
				  	 
			WAR.Person[WAR.CurID]["�ƶ�����"] = 6
			War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["�ƶ�����"], 0)
			local x, y = nil, nil
			while 1 do
				if JY.Restart == 1 then
					break
				end
				x, y = War_SelectMove()
				if x ~= nil then
					WAR.ShowHead = 0
					War_MovePerson(x, y)
					if 995 < WAR.Person[WAR.CurID].Time then
						WAR.Person[WAR.CurID].Time = 995
					end
                    WAR.Person[WAR.CurID].Time = 1005							
					break;
				end
			end
		end
				
		WAR.ZYZD = 0
		WAR.CurID = z
	end 
  ]]

      
	   				
	        --ʥ���� ��������ƶ�
	        if (0 < WAR.Person[p]["�ƶ�����"] or 0 < WAR.ZYYD) and WAR.Person[p]["�ҷ�"] == true and inteam(id) and WAR.AutoFight == 0 and PersonKF(id, 93) and 0 < JY.Person[id]["����"] then
				if 0 < WAR.ZYYD then
					WAR.Person[p]["�ƶ�����"] = WAR.ZYYD
					War_CalMoveStep(p, WAR.ZYYD, 0)
				else
					War_CalMoveStep(p, WAR.Person[p]["�ƶ�����"], 0)
				end
				local x, y = nil, nil
				while 1 do
					if JY.Restart == 1 then
						break
					end
					x, y = War_SelectMove()
					if x ~= nil then
						WAR.ShowHead = 0
						War_MovePerson(x, y)
						break;
					end 
				end
	        end
			
			--�޾Ʋ����������Ƿ񴥷���ʥ�����ƶ������������Ӧ������һ������������Ӱ�쵽��һ���˵�ʥ���ж�
			--�����ܲ�ͨ���Ҳ��������
			if WAR.ZHB == 0 then
				WAR.ZYYD = 0
			end
			
			--�ܲ�ͨ��׷�ӻ����ж�
			if WAR.ZHB == 1 then
				WAR.ZHB = 0
			end
	       -- 

			--������ ��������ƶ�
			if match_ID(id,606) and WAR.Person[p]["�ҷ�"] == true and WAR.AutoFight == 0 and 0 < JY.Person[id]["����"] then
				WAR.Person[p]["�ƶ�����"] = 10
				War_CalMoveStep(p, WAR.Person[p]["�ƶ�����"], 0)
				local x, y = nil, nil
				while 1 do
					if JY.Restart == 1 then
						break
					end
					x, y = War_SelectMove()
					if x ~= nil then
						WAR.ShowHead = 0
						War_MovePerson(x, y)
						break;
					end 
				end
			end			

			--˾��ժ�� ��������ƶ�
			if match_ID(id,579) and WAR.Person[p]["�ҷ�"] == true and WAR.AutoFight == 0 and 0 < JY.Person[id]["����"] then
				WAR.Person[p]["�ƶ�����"] = 5
				War_CalMoveStep(p, WAR.Person[p]["�ƶ�����"], 0)
				local x, y = nil, nil
				while 1 do
					if JY.Restart == 1 then
						break
					end
					x, y = War_SelectMove()
					if x ~= nil then
						WAR.ShowHead = 0
						War_MovePerson(x, y)
						break;
					end 
				end
			end
	
	        --ѩɽ��ɱѪ������󣬻ָ��ҷ����� 
	        if WAR.ZDDH == 7 then
				for x = 0, WAR.PersonNum - 1 do
					if WAR.Person[x]["������"] == 97 and JY.Person[97]["����"] <= 0 then
						for xx = 0, WAR.PersonNum - 1 do
							if WAR.Person[xx]["������"] ~= 97 then
								WAR.Person[xx]["�ҷ�"] = true
							end
						end
					end
				end
	        end

			
			--�Ž����м��ټ���
			if WAR.JJPZ[id] == 1 then
				WAR.Person[p].Time = -200
				WAR.JJPZ[id] = nil
			end
			
			--̫��ж�����ټ���
			if WAR.TKJQ[id] == 1 then
				WAR.Person[p].Time = -100
				WAR.TKJQ[id] = nil
			end
		
	        
			--�ж��������Ч������600��
	        if 600 < WAR.Person[p].Time then
				WAR.Person[p].Time = 600
	        end
			

            --���Ŵ�ѩ 
			 local ljxd = 0
             if  match_ID_awakened(pid,500,1) and JY.Person[0]["����"]> 79  and  WAR.LJXD < 1 and JLSD(10,50,pid)then     				
				WAR.LJXD = WAR.LJXD + 1
				ljxd = 1

				WarDrawMap(0); --���������򶯻�λ���޷�������ʾ
				CurIDTXDH(WAR.CurID, 132,1,"�����۷塤�巽�о�",C_ORANGE);			
				--ShowScreen()
				--lib.Delay(400)
			  --�����ж� (�ܶ���ʼ) ����ж�
              for j = 0, WAR.PersonNum - 1  do
					WAR.Person[j].Time = WAR.Person[j].Time - 10
					if 995 < WAR.Person[j].Time then
						WAR.Person[j].Time = 995
					end
			   end
				WAR.Person[WAR.CurID].Time = 1005
	           end
					if ljxd == 0 then
               WAR.LJXD = 0
               end
	
			--�޾Ʋ�����Ԭ��־����Ѫ���磬ɱ�˺��ٶ�
	        if match_ID(id, 54) and WAR.BXCF == 1 and War_isEnd() == 0 then	
				for k = 1,20 do
					local i = 12+k
					if i > 24 then 
						i = 24 	
					end
					Cat('ʵʱ��Ч����')
					Cls()
					NewDrawString(-1, -1, "��Ѫ����", C_RED, 25 + i)
					ShowScreen();
					lib.Delay(CC.BattleDelay)
				end
				

				for j = 0, WAR.PersonNum - 1 do
					WAR.Person[j].Time = WAR.Person[j].Time - 10
					if 995 < WAR.Person[j].Time then
						WAR.Person[j].Time = 995
					end
				end
				WAR.Person[WAR.CurID].Time = 1005
					
				WAR.BXCF = 0		
	        end
			--���ʮ��ɱһ�ˣ�ɱ�˺��ٶ�
	        if match_ID(id, 636) and id ==0 and WAR.SBSYR == 1 and War_isEnd() == 0 then	
				for k = 1,20 do
					local i = 12+k
					if i > 24 then 
						i = 24 	
					end
					Cat('ʵʱ��Ч����')
					Cls()
					NewDrawString(-1, -1, "ʮ��ɱһ��", C_RED, 25 + i)
					ShowScreen();
					lib.Delay(CC.BattleDelay)
				end
				for j = 0, WAR.PersonNum - 1 do
					WAR.Person[j].Time = WAR.Person[j].Time - 10
					if 995 < WAR.Person[j].Time then
						WAR.Person[j].Time = 995
					end
				end
				WAR.Person[WAR.CurID].Time = 1005
					
				WAR.SBSYR = 0		
	        end
	        
	        --����Խ�߷�������Խ��
	        local pz = math.modf(JY.Person[0]["����"] / 10)
	        --����ҽ�����У�ֱ���ٴ��ж�
	        if id == 0 and JY.Base["��׼"] == 8 and JY.Person[pid]["�������"] > 0 then
                if WAR.HTSS == 1 then 
                    WAR.HTSS = 0
                else
                    if JY.Person[0]["����"] > 50 then
                        if WAR.HTSS == 0 and JLSD(25, 60 + pz, 0) and 0 < JY.Person[0]["�书9"] then
                            CurIDTXDH(WAR.CurID, 91, 1)

                            for k = 1,20 do
                                local i = 12+k
                                if i > 24 then 
                                    i = 24 	
                                end
                                Cat('ʵʱ��Ч����')
                                Cls()
                                NewDrawString(-1, -1,  ZJTF[8] .. TFSSJ[8], C_GOLD, 25 + i)
                                ShowScreen();
                                lib.Delay(CC.BattleDelay)
                            end
                    
                            for j = 0, WAR.PersonNum - 1 do
                                WAR.Person[j].Time = WAR.Person[j].Time - 10
                                if 995 < WAR.Person[j].Time then
                                    WAR.Person[j].Time = 995
                                end
                            end
                            WAR.Person[WAR.CurID].Time = 1005
                            JY.Person[0]["����"] = JY.Person[0]["����"] - 10
                            --�е͸����ٴη���
                            if JLSD(45, 50, 0) then
                                WAR.HTSS = 0        
                            else
                                WAR.HTSS = 1
                            end
                        end
                    end
                end
	        end
	
	        --�����ܵ� 100ʱ�����
	        if WAR.ZDDH == 237 and 100 < WAR.SXTJ then
				for i = 0, WAR.PersonNum - 1 do
					if WAR.Person[i]["�ҷ�"] == false then
						WAR.Person[i]["����"] = true
					end
				end
				say("���̣��ţ�û�������"..JY.Person[0]["���2"].."�����ˣ��׹�������"..JY.Person[0]["���2"].."���������ˣ��Ϸ���Ҫ�´��죬��ξͷ���һ��", 18,0)
	        end
	        --�����ܵ� С��100ʱ��սʤ
	        if WAR.ZDDH == 237 and 100 > WAR.SXTJ and War_isEnd() then
				for i = 0, WAR.PersonNum - 1 do
					if WAR.Person[i]["�ҷ�"] == false and WAR.Person[i]["����"] == true then
			           instruct_2(14,1)
	               end						
			    end
			end	
			--������սʤ����Ѫ����
			if WAR.ZDDH == 353 and JY.Person[657]["����"] < JY.Person[657]["�������ֵ"]/2 then
				for i = 0, WAR.PersonNum - 1 do
					if WAR.Person[i]["�ҷ�"] == false then
					   WAR.Person[i]["����"] = true
					end
				end
			end
	        --������ ̫����200ʱ��
	        if WAR.ZDDH == 22 and 200 < WAR.SXTJ then
				for i = 0, WAR.PersonNum - 1 do
					if WAR.Person[i]["�ҷ�"] == false then
						WAR.Person[i]["����"] = true
					end
				end
				if JY.Person[0]["�Ա�"] == 0 then
	           TalkEx("С�ֵ�������ᣬ�书���ѵ���˾��磬ʵ���ѵá����վ͵���Ϊֹ", 5, 0)  --�Ի�
              else
	        TalkEx("С����������ᣬ�书���ѵ���˾��磬ʵ���ѵá����վ͵���Ϊֹ", 5, 0)  --�Ի�
	        end			
         end

	        --�׽�ս ��Ħ��Ѫ����ʤ
	        if WAR.ZDDH == 309 and (JY.Person[577]["����"] < JY.Person[577]["�������ֵ"]/2 or 300 < WAR.SXTJ) then
				for i = 0, WAR.PersonNum - 1 do
					if WAR.Person[i]["�ҷ�"] == false then
						WAR.Person[i]["����"] = true
					end
		end
				if JY.Person[0]["�Ա�"] == 0 then
	             TalkEx("С�ֵ�������ᣬ�书���ѵ���˾��磬ʵ���ѵá����վ͵���Ϊֹ", 577, 0)  --�Ի�
                else
	              TalkEx("С����������ᣬ�书���ѵ���˾��磬ʵ���ѵá����վ͵���Ϊֹ", 577, 0)  --�Ի�
	        end			
        end

	
			--��������аʮ���20ʱ��ʤ��
	        if WAR.ZDDH == 133 and 20 < WAR.SXTJ and GetS(87,31,31,5) == 1 then
				for i = 0, WAR.PersonNum - 1 do
					if WAR.Person[i]["�ҷ�"] == false then
						WAR.Person[i]["����"] = true
					end
				end
				TalkEx("��ϲ"..JY.Person[0]["���"].."ͦ��20ʱ�򣬳ɹ����ء�",269,0);
	        end

	        
	        --�ɰ滪ɽ�۽�����������任
	        if WAR.ZDDH == 238 then
	        	local life = 0  ---�������
	        	WAR.NO1 = 114; --- 1�� ս����ɫ����ɨ��
				for i = 0, WAR.PersonNum - 1 do   --ִ��ָ��
					if WAR.Person[i]["����"] == false and 0 < JY.Person[WAR.Person[i]["������"]]["����"] then   --���û�����˺�������������0 ����
						life = life + 1 -- ����+1
						if WAR.NO1 >= WAR.Person[i]["������"] then  --�����Ŵ��ڵ���1������
							WAR.NO1 = WAR.Person[i]["������"] --���˵���1��
						end
					end
				end
	          
				if 1 < life then  --���������������1
					local m, n = 0, 0 --��� �趨 һ��M��,һ��N��
					while true do			--��ֹȫ��������ѷ�
						if m >= 1 and n >= 1 then  --���M�����ڵ���1��N�����ڵ���1
							break;  --��ֹѭ��
						else  -- Ҳ������
							m = 0;  --M��Ϊ0 
							n = 0;  --N��Ϊ0
						end
						
						for i = 0, WAR.PersonNum - 1 do  --ִ��ָ��
							if WAR.Person[i]["����"] == false and 0 < JY.Person[WAR.Person[i]["������"]]["����"] then   --���û����������������������0 
								if WAR.Person[i]["������"] == 0 then  --��������ŵ���0
									WAR.Person[i]["�ҷ�"] = true   --��Ϊ�ҷ�
									m = m + 1    --M������+1
								elseif math.random(2) == 1 then   --Ҳ���� ���1~2Ϊ1ʱ
									WAR.Person[i]["�ҷ�"] = true  --��Ϊ�ҷ�
									m = m + 1  --M������+1
								else
									WAR.Person[i]["�ҷ�"] = false  --Ҳ���ܲ����ҷ�
									n = n + 1  --��N������+1
								end
							end
						end
					end
				end
	        end
	    end
       -- warStatus = War_isEnd()   --ս���Ƿ������   0������1Ӯ��2��
		--if 0 < warStatus then
		--	break;
		--end
	end
	    
		--warStatus = War_isEnd()   --ս���Ƿ������   0������1Ӯ��2��
		--if 0 < warStatus then
		--	break;
		--end
	CleanMemory()
    --end
	warStatus = War_isEnd()
    if 0 < warStatus then
     	break;
    end
	
    WarPersonSort(1)
    WAR.Delay = GetJiqi()
    startt = lib.GetTime()
    collectgarbage("step", 0)
  end
  local r = nil
  WAR.ShowHead = 0
 
	--ս��������Ľ���
	if WAR.ZDDH == 238 then
		PlayMIDI(111)
		PlayWavAtk(41)
		DrawStrBoxWaitKey("�۽�����", C_WHITE, CC.DefaultFont)
		DrawStrBoxWaitKey("�书���µ�һ�ߣ�" .. JY.Person[WAR.NO1]["����"], C_RED, CC.DefaultFont)
		if WAR.NO1 == 0 then
		  r = true
		else
		  r = false
		end
	--ս��ʤ��
	elseif warStatus == 1 then
		PlayMIDI(111)
		PlayWavAtk(41)
		lib.LoadPNG(91, 1*2 , 295, 295, 1)
		ShowScreen();
		WaitKey();

		if WAR.ZDDH == 76 then
			DrawStrBoxWaitKey("���⽱����ǧ����֥һö", C_GOLD, CC.DefaultFont)
			instruct_32(14, 1)
		elseif WAR.ZDDH == 15 or WAR.ZDDH == 80 then
			DrawStrBoxWaitKey("���⽱����������ϵ����ֵ����ʮ��", C_RED, CC.DefaultFont,nil,C_GOLD)
			AddPersonAttrib(0, "ȭ�ƹ���", 10)
			AddPersonAttrib(0, "ָ������", 10)
			AddPersonAttrib(0, "��������", 10)
			AddPersonAttrib(0, "ˣ������", 10)
			AddPersonAttrib(0, "�������", 10)

		elseif WAR.ZDDH == 172 then
			DrawStrBoxWaitKey("���⽱������ø�󡹦�ؼ�һ��", C_GOLD, CC.DefaultFont)
			instruct_32(73, 1)
		elseif WAR.ZDDH == 173 then
			DrawStrBoxWaitKey("���⽱���������ɽѩ����ö", C_GOLD, CC.DefaultFont)
			instruct_32(17, 2)
		elseif WAR.ZDDH == 188 then
			local hqjl = JYMsgBox("���⽱��", "������˽���ս**��ѡ��һ�����ֵ�������", {"ȭ��","ָ��","����","����","����"}, 5, 69)
			if hqjl == 1 then
				AddPersonAttrib(0, "ȭ�ƹ���", 10)
				DrawStrBoxWaitKey("���ȭ�ƹ��������ʮ��",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --����
			elseif hqjl == 2 then
				AddPersonAttrib(0, "ָ������", 10)
				DrawStrBoxWaitKey("���ָ�����������ʮ��",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --����
			elseif hqjl == 3 then
				AddPersonAttrib(0, "��������", 10)
				DrawStrBoxWaitKey("����������������ʮ��",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --����
			elseif hqjl == 4 then
				AddPersonAttrib(0, "ˣ������", 10)
				DrawStrBoxWaitKey("���ˣ�����������ʮ��",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --����
			elseif hqjl == 5 then
				AddPersonAttrib(0, "�������", 10)
				DrawStrBoxWaitKey("���������������ʮ��",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --����
			end
		elseif WAR.ZDDH == 292 then
			local hqjl = JYMsgBox("���⽱��", "������˽���ս**��ѡ��һ�����ֵ�������", {"ȭ��","ָ��","����","����","����"}, 5, 6)
			if hqjl == 1 then
				AddPersonAttrib(0, "ȭ�ƹ���", 10)
				DrawStrBoxWaitKey("���ȭ�ƹ��������ʮ��",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --����
			elseif hqjl == 2 then
				AddPersonAttrib(0, "ָ������", 10)
				DrawStrBoxWaitKey("���ָ�����������ʮ��",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --����
			elseif hqjl == 3 then
				AddPersonAttrib(0, "��������", 10)
				DrawStrBoxWaitKey("����������������ʮ��",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --����
			elseif hqjl == 4 then
				AddPersonAttrib(0, "ˣ������", 10)
				DrawStrBoxWaitKey("���ˣ�����������ʮ��",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --����
			elseif hqjl == 5 then
				AddPersonAttrib(0, "�������", 10)
				DrawStrBoxWaitKey("���������������ʮ��",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --����
			end
		elseif WAR.ZDDH == 211 then
			DrawStrBoxWaitKey("���⽱�������Ƿ��������Ṧ������ʮ��", C_GOLD, CC.DefaultFont)
			AddPersonAttrib(0, "������", 10)
			AddPersonAttrib(0, "�Ṧ", 10)
		elseif WAR.ZDDH == 86 then
			instruct_2(66, 1)
		elseif WAR.ZDDH == 4 then
			if JY.Person[0]["ʵս"] < 500 then
				QZXS(string.format("%s ʵս����%s��",JY.Person[0]["����"],30));
				JY.Person[0]["ʵս"] = JY.Person[0]["ʵս"] + 30
				if JY.Person[0]["ʵս"] > 500 then
					JY.Person[0]["ʵս"] = 500
				end
			end
		elseif WAR.ZDDH == 77 then
			if JY.Person[0]["ʵս"] < 500 then
				QZXS(string.format("%s ʵս����%s��",JY.Person[0]["����"],20));
				JY.Person[0]["ʵս"] = JY.Person[0]["ʵս"] + 20
				if JY.Person[0]["ʵս"] > 500 then
					JY.Person[0]["ʵս"] = 500
				end
			end
		elseif WAR.ZDDH > 42 and  WAR.ZDDH < 47 then
			if JY.Person[0]["ʵս"] < 500 then
				QZXS(string.format("%s ʵս����%s��",JY.Person[0]["����"],10));
				JY.Person[0]["ʵս"] = JY.Person[0]["ʵս"] + 10
				if JY.Person[0]["ʵս"] > 500 then
					JY.Person[0]["ʵս"] = 500
				end
			end
		elseif WAR.ZDDH == 161 then
			if JY.Person[0]["ʵս"] < 500 then
				QZXS(string.format("%s ʵս����%s��",JY.Person[0]["����"],30));
				JY.Person[0]["ʵս"] = JY.Person[0]["ʵս"] + 30
				if JY.Person[0]["ʵս"] > 500 then
					JY.Person[0]["ʵս"] = 500
				end
			end
		--սʤ����
		elseif WAR.ZDDH == 259 then
			DrawStrBoxWaitKey("���⽱������û��������ؼ�һ��", C_GOLD, CC.DefaultFont)
			instruct_32(275,1)
		elseif  WAR.ZDDH == 100 then
		DrawStrBoxWaitKey("���⽱�������ǧ����֥һö", C_GOLD, CC.DefaultFont)
		instruct_32(14, 1)
		
	
		--���۽����� ���ݵ��˲�ͬ������ͬ
		elseif WAR.ZDDH == 266 then
			--����
			if GetS(85, 40, 38, 4) == 64 then
				DrawStrBoxWaitKey("���⽱������������������ý�����50% ", LimeGreen, 36,nil, C_GOLD)
				JY.Person[64]["�۽�����"] = 1
			--����
			elseif GetS(85, 40, 38, 4) == 129 then
				DrawStrBoxWaitKey("���⽱��������˺������������20% ", LimeGreen, 36,nil, C_GOLD)
				JY.Person[129]["�۽�����"] = 1
			--�ֳ�Ӣ
			elseif GetS(85, 40, 38, 4) == 605 then
				DrawStrBoxWaitKey("���⽱����������������������50% ", LimeGreen, 36,nil, C_GOLD)
				JY.Person[605]["�۽�����"] = 1
			--����
			elseif GetS(85, 40, 38, 4) == 604 then
				DrawStrBoxWaitKey("���⽱��������������������800��", LimeGreen, 36,nil, C_GOLD)
				JY.Person[604]["�۽�����"] = 1
				--instruct_32(278,1)
			--������
			elseif GetS(85, 40, 38, 4) == 140 then
				if PersonKF(0, 47) then
					DrawStrBoxWaitKey("���⽱��������������������1000��", LimeGreen, 36,nil, C_GOLD)
					JY.Person[592]["�۽�����"] = 1
				else
					DrawStrBoxWaitKey("���ƺ������һ�������", LimeGreen, 36,nil, C_GOLD)
				end
			--��������
			elseif GetS(85, 40, 38, 4) == 27 then
				DrawStrBoxWaitKey("���⽱������ļ����ٶ����������8��", LimeGreen, 36,nil, C_GOLD)
				JY.Person[27]["�۽�����"] = 1
			--ɨ��
			elseif GetS(85, 40, 38, 4) == 114 then
				DrawStrBoxWaitKey("���⽱���������ѧ��ʶ�����100��", LimeGreen, 36,nil, C_GOLD)
				JY.Person[114]["�۽�����"] = 1
				AddPersonAttrib(0, "��ѧ��ʶ", 100)
			--����
			elseif GetS(85, 40, 38, 4) == 5 then
				DrawStrBoxWaitKey("���⽱������Ĺ��������ϵ����ֵȫ�������", LimeGreen, 36,nil, C_GOLD)
				JY.Person[5]["�۽�����"] = 1
				AddPersonAttrib(0, "������", 30)
				AddPersonAttrib(0, "������", 30)
				AddPersonAttrib(0, "�Ṧ", 30)
				AddPersonAttrib(0, "ȭ�ƹ���", 20)
				AddPersonAttrib(0, "ָ������", 20)
				AddPersonAttrib(0, "��������", 20)
				AddPersonAttrib(0, "ˣ������", 20)
				AddPersonAttrib(0, "�������", 20)
			--������
			elseif GetS(85, 40, 38, 4) == 606 then
				DrawStrBoxWaitKey("���⽱���������˾������ֵ�����", LimeGreen, 36,nil, C_GOLD)
				JY.Person[606]["�۽�����"] = 1
			end
		end

		r = true
		--�԰�ɽ ��Ѱ��ս��ʤ����ð���
		if (JY.Base["����"] == 153 or JY.Base["����"] == 498) and WAR.ZDDH ~= 226 and WAR.ZDDH ~= 354 then
			local anqi = math.random(28,35)
			local num = math.random(5)
			instruct_2(anqi,num)
		end
		r = true
		--ս��ʤ���������
		if (JY.Base["��׼"] > 0 or JY.Base["����"] > 0) and WAR.ZDDH ~= 226 and WAR.ZDDH > 0 and WAR.ZDDH ~= 354 then
			local num = math.random(50,100)
			instruct_2(174,num)
			--instruct_2(209,num)			
		end
        if WAR.ZDDH ~= 226 and WAR.ZDDH ~= 354 then
            for i = 0,WAR.PersonNum-1 do
                local id = WAR.Person[i]['������']
                if WAR.Person[i]['�ҷ�'] then
                    if match_ID(id, 9965) then
                        local a = math.random(22,25)
                        local b = math.random(0,13)
                        instruct_2(a,1)
                        instruct_2(b,1)
                        break
                    end
                end
            end
        end
		r = true

	--ս��ʧ��
	elseif warStatus == 2 then
		--DrawStrBoxWaitKey("ս��ʧ��", C_WHITE, CC.DefaultFont)
		lib.LoadPNG(91, 2 * 2 , 295, 295, 1)
		ShowScreen();
		WaitKey();
		r = false
	end
  
	War_EndPersonData(isexp, warStatus)
	lib.ShowSlow(20, 1)
	if 0 <= JY.Scene[JY.SubScene]["��������"] then
		PlayMIDI(JY.Scene[JY.SubScene]["��������"])
	else
		PlayMIDI(0)
	end
	CleanMemory()
	--lib.PicInit()
  
	--ս�����������¼��س�����ͼ
	--lib.PicLoadFile(CC.SMAPPicFile[1], CC.SMAPPicFile[2], 0)	--�ӳ�����ͼ���ڴ�����0
	--lib.LoadPNGPath('./data/smap',0,-1,100)
	--lib.LoadPNGPath(CC.HeadPath, 1, CC.HeadNum, limitX(CC.ScreenW/936*100,0,100))	--����ͷ���ڴ�����1
	--lib.LoadPNGPath(CC.XTPath, 91, CC.XTNum, limitX(CC.ScreenW/936*100,0,100))	--UI		
	--lib.LoadPNGPath(CC.BodyPath, 90, CC.BodyNum, limitX(CC.ScreenW/936*100,0,100))	--�������ڴ�����100
	--lib.LoadPNGPath(CC.UIPath, 96, CC.UINum, limitX(CC.ScreenW/936*100,0,100))
	--lib.PicLoadFile(CC.ThingPicFile[1], CC.ThingPicFile[2], 2, 100, 100)	--��Ʒ��ͼ���ڴ�����2
	--lib.LoadPNGPath('./data/thing',0,-1,100)
	--lib.PicLoadFile(CC.BJ[1], CC.BJ[2], 92)
	--lib.LoadPNGPath('./data/bj',0,-1,100)
	JY.Status = GAME_SMAP
	return r
end

--ɽ�����ã�����
function buzhen()
	if not inteam(92) then
		return 
	end
	if WAR.ZDDH == 226 then
		return 
	end
	local line = "Ҫ����������";
	local tiles = 2;
	if (WAR.ZDDH == 133 or WAR.ZDDH == 134) and WAR.MCRS == 1 then
		if JY.Person[0]["�Ա�"] == 0 then
			line = "��������¸ң�һ������սʮ�����֣���ǧ��С�ġ�"
		else
			line = "��������¸ң�һ������սʮ�����֣���ǧ��С�ġ�"
		end
		tiles = 4
	end
	say(line, 92,0,JY.Person[92]["����"])
	if not DrawStrBoxYesNo(-1, -1, "Ҫ����������", C_WHITE, CC.DefaultFont) then
		return 
	end
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["�ҷ�"] then
			WAR.CurID = i
            WAR.ShowHead = 1
            WarDrawMap(0)
            --����ͳһΪ2��
            WAR.Person[WAR.CurID]["�ƶ�����"] = tiles
			War_CalMoveStep(WAR.CurID, tiles, 0)
			local x, y = nil, nil
			while true do
				if JY.Restart == 1 then
					break
				end
				x, y = War_SelectMove()
                if x ~= nil then

                    WAR.ShowHead = 0
					War_MovePerson(x, y)
					break;
				end
			end
		end
	end
end

--�޾Ʋ�����սǰ�˹�
function Pre_Yungong()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701 
	if WAR.ZDDH == 226 then
		return 
	end
	if Num_of_Neigong(0) == 0 then
		return 
	end
	local id, x1, y1;
	for j = 0, WAR.PersonNum - 1 do
		if WAR.Person[j]["������"] == 0 then
			id, x1, y1 = j, WAR.Person[j]["����X"], WAR.Person[j]["����Y"]
			break
		end
	end
	if x1 == nil then
		return 
	end
	local s = WAR.CurID
	local pid = WAR.Person[id]['������']
	local r = JYMsgBox("սǰ�˹�", "սǰǿ���˹����ж�����۵�*Ҫ������", {"��","��"}, 2, JY.Person[pid]["������"])
	if r == 2 then
		local menu={};
		for i=1,JY.Base["�书����"] do
			menu[i]={JY.Wugong[JY.Person[0]["�书" .. i]]["����"],nil,0};
			if JY.Wugong[JY.Person[0]["�书" .. i]]["�书����"] == 6 then
				menu[i][3]=1;
			end
			--�����������
			if (jqid == 0 and JY.Base["��׼"] == 6 )  and (JY.Person[0]["�书" .. i] == 106 or JY.Person[0]["�书" .. i] == 107 or JY.Person[0]["�书" .. i] == 108) then
				menu[i][3]=0;	
			end
		end
		local main_neigong =  Cat('�˵�',menu,#menu,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
		if main_neigong ~= nil and main_neigong > 0 then
			WAR.CurID = id
			CleanWarMap(4, 0)
			SetWarMap(x1, y1, 4, 1)
			War_ShowFight(0, 0, 0, 0, 0, 0, 9)	
			--AddPersonAttrib(0, "����", -500);
			AddPersonAttrib(0, "����", -10);
			AddPersonAttrib(0, "����", 500);
            AddPersonAttrib(0, "�������ֵ", 500);			
			JY.Person[0]["�����ڹ�"] = JY.Person[0]["�书" .. main_neigong]
			Hp_Max(pid)
			WAR.CurID = s
		end
	end
end

--�޾Ʋ�����������λ�ò��Ŷ����ĺ���
function CurIDTXDH(id, eft, order, str, strColor, endFrame)
	--����������ɫ����
	if strColor == nil then
		strColor = C_GOLD
	end
	--����ǿ�ƽ���֡
	if endFrame == nil then
		endFrame = CC.Effect[eft]
	end
	local x0, y0 = WAR.Person[id]["����X"], WAR.Person[id]["����Y"]
	local hb = GetS(JY.SubScene, x0, y0, 4)
	local starteft = 0
	
	for i = 0, eft - 1 do
		starteft = starteft + CC.Effect[i]
	end

	--local ssid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)
	for ii = 1, endFrame, order do
		lib.GetKey()
		Cat('ʵʱ��Ч����')
		WarDrawMap(6, 0, 0, (starteft + ii) * 2, nil, 3)
		if str ~= nil then
			DrawString(-1, CC.ScreenH / 2 - hb, str, strColor, CC.DefaultFont)
		end
		ShowScreen()
		lib.Delay(CC.BattleDelay)
		--lib.LoadSur(ssid, 0, 0)
	end
	--lib.FreeSur(ssid)
	Cls()
end


function WE_xy(x, y, id)
  if id ~= nil then
    War_CalMoveStep(id, 128, 0)
  else
    CleanWarMap(3, 0)
  end
  if GetWarMap(x, y, 3) ~= 255 and War_CanMoveXY(x, y, 0) then
    return x, y
  else
    for s = 1, 128 do
      for i = 1, s do
        local j = s - i
        if x + i < 63 and y + j < 63 and GetWarMap(x + i, y + j, 3) ~= 255 and War_CanMoveXY(x + i, y + j, 0) then
          return x + i, y + j
        end
        if x + j < 63 and y - i > 0 and GetWarMap(x + j, y - i, 3) ~= 255 and War_CanMoveXY(x + j, y - i, 0) then
          return x + j, y - i
        end
        if x - i > 0 and y - j > 0 and GetWarMap(x - i, y - j, 3) ~= 255 and War_CanMoveXY(x - i, y - j, 0) then
          return x - i, y - j
        end
        if x - j > 0 and y + i < 63 and GetWarMap(x - j, y + i, 3) ~= 255 and War_CanMoveXY(x - j, y + i, 0) then
          return x - j, y + i
        end
      end
    end
  end
  for s = 1, 128 do
    for i = 1, s do
      local j = s - i
      if x + i < 63 and y + j < 63 and War_CanMoveXY(x + i, y + j, 0) then
        return x + i, y + j
      end
      if x + j < 63 and y - i > 0 and War_CanMoveXY(x + j, y - i, 0) then
        return x + j, y - i
      end
      if x - i > 0 and y - j > 0 and War_CanMoveXY(x - i, y - j, 0) then
        return x - i, y - j
      end
      if x - j > 0 and y + i < 63 and War_CanMoveXY(x - j, y + i, 0) then
        return x - j, y + i
      end
    end
  end
  return x, y
end

--���㰵���˺�
function War_AnqiHurt(pid, emenyid, thingid, emeny)
	local num = nil
	local dam = nil
    local kd = JY.Person[emenyid]["��������"]

    if WAR.PD['��������'][emenyid] ~= nil then 
        kd = kd + WAR.PD['��������'][emenyid]
    end
    
	if JY.Person[emenyid]["���˳̶�"] == 0 then
		num = JY.Thing[thingid]["������"] / 2 - Rnd(3)
	elseif JY.Person[emenyid]["���˳̶�"] <= 33 then
		num = math.modf(JY.Thing[thingid]["������"] *2 / 3) - Rnd(3)
	elseif JY.Person[emenyid]["���˳̶�"] <= 66 then
		num = JY.Thing[thingid]["������"] - Rnd(3)
	else
		num = math.modf(JY.Thing[thingid]["������"] *4 / 3) - Rnd(3)
	end
	  
	num = math.modf(num - JY.Person[pid]["��������"]/4 + JY.Person[emenyid]["��������"]/4)
	WAR.Person[emeny]["���˵���"] = AddPersonAttrib(emenyid, "���˳̶�", math.modf(-num / 6))
	dam = num * WAR.AQBS

	local r = AddPersonAttrib(emenyid, "����", math.modf(dam))
	if (emenyid == 129 or emenyid == 65) and JY.Person[emenyid]["����"] <= 0 then
		JY.Person[emenyid]["����"] = 1
	end

	if JY.Person[emenyid]["����"] <= 0 then
		WAR.Person[WAR.CurID]["����"] = WAR.Person[WAR.CurID]["����"] + JY.Person[emenyid]["�ȼ�"] * 5
	end
    
	if JY.Thing[thingid]["���ж��ⶾ"] > 0 then
		num = math.modf(JY.Thing[thingid]["���ж��ⶾ"] + JY.Person[pid]["��������"] / 4)
		num = num - kd
		num = limitX(num, 0, CC.PersonAttribMax["�ö�����"])
		WAR.Person[emeny]["�ж�����"] = AddPersonAttrib(emenyid, "�ж��̶�", num)
	end
    
	--��˯״̬�ĵ��˻�����
	if WAR.CSZT[emenyid] ~= nil then
		WAR.CSZT[emenyid] = nil
	end
	return r
end

--�����(x,y)��ʼ��������ܹ����м�������
function War_AutoCalMaxEnemy(x, y, wugongid, level)
  local wugongtype = JY.Wugong[wugongid]["������Χ"]
  local movescope = JY.Wugong[wugongid]["�ƶ���Χ" .. level]
  local fightscope = JY.Wugong[wugongid]["ɱ�˷�Χ" .. level]
  local maxnum = 0
  local xmax, ymax = nil, nil
  if wugongtype == 0 or wugongtype == 3 then
    local movestep = War_CalMoveStep(WAR.CurID, movescope, 1)	--�����书�ƶ�����
    for i = 1, movescope do
      local step_num = movestep[i].num
      if step_num == 0 then
        break;
      end
      for j = 1, step_num do
        local xx = movestep[i].x[j]
        local yy = movestep[i].y[j]
        local enemynum = 0
        for n = 0, WAR.PersonNum - 1 do
          if n ~= WAR.CurID and WAR.Person[n]["����"] == false and WAR.Person[n]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
            local x = math.abs(WAR.Person[n]["����X"] - xx)
            local y = math.abs(WAR.Person[n]["����Y"] - yy)
          end
          if x <= fightscope and y <= fightscope then
            enemynum = enemynum + 1
          end
        end
        if maxnum < enemynum then
          maxnum = enemynum
          xmax = xx
          ymax = yy
        end
      end
    end
  elseif wugongtype == 1 then
    for direct = 0, 3 do
      local enemynum = 0
      for i = 1, movescope do
        local xnew = x + CC.DirectX[direct + 1] * i
        local ynew = y + CC.DirectY[direct + 1] * i
        if xnew >= 0 and xnew < CC.WarWidth and ynew >= 0 and ynew < CC.WarHeight then
          local id = GetWarMap(xnew, ynew, 2)
        end
        if id >= 0 and WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[id]["�ҷ�"] then
          enemynum = enemynum + 1
        end
      end
      if maxnum < enemynum then
        maxnum = enemynum
        xmax = x + CC.DirectX[direct + 1]
        ymax = y + CC.DirectY[direct + 1]
      end
    end
  elseif wugongtype == 2 then
    local enemynum = 0
    for direct = 0, 3 do
      for i = 1, movescope do
        local xnew = x + CC.DirectX[direct + 1] * i
        local ynew = y + CC.DirectY[direct + 1] * i
        if xnew >= 0 and xnew < CC.WarWidth and ynew >= 0 and ynew < CC.WarHeight then
          local id = GetWarMap(xnew, ynew, 2)
        end
        if id >= 0 and WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[id]["�ҷ�"] then
          enemynum = enemynum + 1
        end
      end
    end
  end
  if enemynum > 0 then
    maxnum = enemynum
    xmax = x
    ymax = y
  end
  return maxnum, xmax, ymax
end


--�õ������ߵ����������˵����λ�á�
--scope���Թ����ķ�Χ
--���� x,y������޷��ߵ�����λ�ã����ؿ�
function War_AutoCalMaxEnemyMap(wugongid, level)
  local wugongtype = JY.Wugong[wugongid]["������Χ"]
  local movescope = JY.Wugong[wugongid]["�ƶ���Χ" .. level]
  local fightscope = JY.Wugong[wugongid]["ɱ�˷�Χ" .. level]
  local x0 = WAR.Person[WAR.CurID]["����X"]
  local y0 = WAR.Person[WAR.CurID]["����Y"]
  CleanWarMap(4, 0)
  if wugongtype == 0 or wugongtype == 3 then
    for n = 0, WAR.PersonNum - 1 do
      if n ~= WAR.CurID and WAR.Person[n]["����"] == false and WAR.Person[n]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
        local xx = WAR.Person[n]["����X"]
        local yy = WAR.Person[n]["����Y"]
        local movestep = War_CalMoveStep(n, movescope, 1)
        for i = 1, movescope do
          local step_num = movestep[i].num
	        if step_num == 0 then
	          
	        else
	          for j = 1, step_num do
	            SetWarMap(movestep[i].x[j], movestep[i].y[j], 4, 1)
	          end
	        end
	      end
      end
    end
  elseif wugongtype == 1 or wugongtype == 2 then
    for n = 0, WAR.PersonNum - 1 do
      if n ~= WAR.CurID and WAR.Person[n]["����"] == false and WAR.Person[n]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
        local xx = WAR.Person[n]["����X"]
        local yy = WAR.Person[n]["����Y"]
        for direct = 0, 3 do
          for i = 1, movescope do
            local xnew = xx + CC.DirectX[direct + 1] * i
            local ynew = yy + CC.DirectY[direct + 1] * i
            if xnew >= 0 and xnew < CC.WarWidth and ynew >= 0 and ynew < CC.WarHeight then
              local v = GetWarMap(xnew, ynew, 4)
              SetWarMap(xnew, ynew, 4, v + 1)
            end
          end
        end
      end
    end
  end
end

--�Զ�ҽ��
function War_AutoDoctor()
  local x1 = WAR.Person[WAR.CurID]["����X"]
  local y1 = WAR.Person[WAR.CurID]["����Y"]
  War_ExecuteMenu_Sub(x1, y1, 3, -1)
end

--�Զ���ҩ
--flag=2 ������3������4����  6 �ⶾ
function War_AutoEatDrug(flag)
	local pid = WAR.Person[WAR.CurID]["������"]
	local life = JY.Person[pid]["����"]
	local maxlife = JY.Person[pid]["�������ֵ"]
	local selectid = nil
	local minvalue = math.huge
	local shouldadd, maxattrib, str = nil, nil, nil
	if flag == 2 then
		maxattrib = JY.Person[pid]["�������ֵ"]
		shouldadd = maxattrib - JY.Person[pid]["����"]
		str = "������"
		
	elseif flag == 3 then
		maxattrib = JY.Person[pid]["�������ֵ"]
		shouldadd = maxattrib - JY.Person[pid]["����"]
		str = "������"
		
	elseif flag == 4 then
		maxattrib = CC.PersonAttribMax["����"]
		shouldadd = maxattrib - JY.Person[pid]["����"]
		str = "������"
		
	elseif flag == 6 then
		maxattrib = CC.PersonAttribMax["�ж��̶�"]
		shouldadd = JY.Person[pid]["�ж��̶�"]
		str = "���ж��ⶾ"
		
	else
		return 
	end
	local function Get_Add(thingid)
		if flag == 6 then
		  return -JY.Thing[thingid][str] / 2
		else
		  return JY.Thing[thingid][str]
		end
	end
  
	--�ڶ�
	if inteam(pid) and WAR.Person[WAR.CurID]["�ҷ�"] == true then
		local extra = 0
		for i = 1, CC.MyThingNum do
			local thingid = JY.Base["��Ʒ" .. i]
			if thingid >= 0 then
				local add = Get_Add(thingid)
				if JY.Thing[thingid]["����"] == 3 and add > 0 then
					local v = shouldadd - add
					if v < 0 then
						extra = 1
					elseif v < minvalue then
						minvalue = v
						selectid = thingid
					end
				end
			end
		end
		if extra == 1 then
			minvalue = math.huge
			for i = 1, CC.MyThingNum do
				local thingid = JY.Base["��Ʒ" .. i]
				if thingid >= 0 then
					local add = Get_Add(thingid)
					if JY.Thing[thingid]["����"] == 3 and add > 0 then
						local v = add - shouldadd
						if v >= 0 and v < minvalue then
							minvalue = v
							selectid = thingid
						end
					end
				end
			end
		end
		--ʹ����Ʒ
		if UseThingEffect(selectid, pid) == 1 then
			instruct_32(selectid, -1)
			
		end
	--���ڶ�
	else
		local extra = 0
		for i = 1, 4 do
			local thingid = JY.Person[pid]["Я����Ʒ" .. i]
			local tids = JY.Person[pid]["Я����Ʒ����" .. i]
			if thingid >= 0 and tids > 0 then
				local add = Get_Add(thingid)
				if JY.Thing[thingid]["����"] == 3 and add > 0 then
					local v = shouldadd - add
					if v < 0 then		--���Լ�������, �����������Һ���ҩƷ
						extra = 1
					elseif v < minvalue then
						minvalue = v
						selectid = thingid
					end
				end
			end
		end
		if extra == 1 then
			minvalue = math.huge
			for i = 1, 4 do
				local thingid = JY.Person[pid]["Я����Ʒ" .. i]
				local tids = JY.Person[pid]["Я����Ʒ����" .. i]
				if thingid >= 0 and tids > 0 then
					local add = Get_Add(thingid)
					if JY.Thing[thingid]["����"] == 3 and add > 0 then
						local v = add - shouldadd
						if v >= 0 and v < minvalue then
							minvalue = v
							selectid = thingid
						end
					end
				end 
			end
		end
		--NPCʹ����Ʒ
		if UseThingEffect(selectid, pid) == 1 then
			instruct_41(pid, selectid, -1)
		end
	end
	--lib.Delay(500)
end

--�Զ�����
function War_AutoEscape()
  local pid = WAR.Person[WAR.CurID]["������"]
  if JY.Person[pid]["����"] <= 5 then
    return 
  end
  local x, y = nil, nil
  War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["�ƶ�����"], 0)		 --�����ƶ�����
  Cat('ʵʱ��Ч����')
  WarDrawMap(1)
  ShowScreen()
  lib.Delay(CC.BattleDelay)
  local array = {}
  local num = 0
  
  for i = 0, CC.WarWidth - 1 do
    for j = 0, CC.WarHeight - 1 do
      if GetWarMap(i, j, 3) < 128 then
        local minDest = math.huge
        for k = 0, WAR.PersonNum - 1 do
          if WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[k]["�ҷ�"] and WAR.Person[k]["����"] == false then
            local dx = math.abs(i - WAR.Person[k]["����X"])
            local dy = math.abs(j - WAR.Person[k]["����Y"])
	          if dx + dy < minDest then		--���㵱ǰ������������λ��
	            minDest = dx + dy
	          end
          end
        end
        num = num + 1
        array[num] = {}
        array[num].x = i
        array[num].y = j
        array[num].p = minDest
      end
    end
  end
  
  for i = 1, num - 1 do
    for j = i, num do
      if array[i].p < array[j].p then
        array[i], array[j] = array[j], array[i]
      end
    end
  end
  for i = 2, num do
    if array[i].p < array[1].p / 2 then
      num = i - 1
      break;
    end
  end
  for i = 1, num do
    array[i].p = array[i].p * 5 + GetMovePoint(array[i].x, array[i].y, 1)
  end
  for i = 1, num - 1 do
    for j = i, num do
      if array[i].p < array[j].p then
        array[i], array[j] = array[j], array[i]
      end
    end
  end
  x = array[1].x
  y = array[1].y

  War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["�ƶ�����"], 0)
  War_MovePerson(x, y)	--�ƶ�����Ӧ��λ��
end


--�Զ�ִ��ս������ʱ��λ��һ�����Դ򵽵���
function War_AutoExecuteFight(wugongnum)
  local pid = WAR.Person[WAR.CurID]["������"]
  local x0 = WAR.Person[WAR.CurID]["����X"]
  local y0 = WAR.Person[WAR.CurID]["����Y"]
  local wugongid = JY.Person[pid]["�书" .. wugongnum]
  local level = math.modf(JY.Person[pid]["�书�ȼ�" .. wugongnum] / 100) + 1
  local maxnum, x, y = War_AutoCalMaxEnemy(x0, y0, wugongid, level)
  if x ~= nil then
    War_Fight_Sub(WAR.CurID, wugongnum, x, y)
    WAR.Person[WAR.CurID].Action = {"atk", x - WAR.Person[WAR.CurID]["����X"], y - WAR.Person[WAR.CurID]["����Y"]}
  end
end

--�Զ�ս��
function War_AutoMenu()
	local pid = WAR.Person[WAR.CurID]["������"]
	WAR.AutoFight = 1
	WAR.ShowHead = 0
	Cls()
	if JY.Person[pid]["�����Զ�"] == 1 then
		return 0
	else
		War_Auto()
		return 1
	end
end

--������ƶ�����
--id ս����id��
--stepmax �������
--flag=0  �ƶ�����Ʒ�����ƹ���1 �书���ö�ҽ�Ƶȣ������ǵ�·��
--flag=2  ���ӽ���
function War_CalMoveStep(id, stepmax, flag)
  CleanWarMap(3, 255)
  local x = WAR.Person[id]["����X"]
  local y = WAR.Person[id]["����Y"]
  local steparray = {}
  for i = 0, stepmax do
    steparray[i] = {}
    steparray[i].bushu = {}
    steparray[i].x = {}
    steparray[i].y = {}
  end
  SetWarMap(x, y, 3, 0)
  steparray[0].num = 1
  steparray[0].bushu[1] = stepmax
  steparray[0].x[1] = x
  steparray[0].y[1] = y
  War_FindNextStep(steparray, 0, flag, id)
  return steparray
end

--�ж�x,y�Ƿ�Ϊ���ƶ�λ��
function War_CanMoveXY(x, y, flag)
	if flag == 2 then
		return true
	end
	if GetWarMap(x, y, 1) > 0 then
		return false
	end
	if flag == 1 then 
		if CC.WarWater[GetWarMap(x, y, 0)] ~= nil then
			return false
		end
		if GetWarMap(x, y, 2) >= 0 then
		   return true
		end	
	end
	if flag == 0 then
		if CC.WarWater[GetWarMap(x, y, 0)] ~= nil then
			return false
		end
		if GetWarMap(x, y, 2) >= 0 then
			return false
		end
	end
	return true
end

--�ⶾ�˵�
function War_DecPoisonMenu()
	WAR.ShowHead = 0
	local r = War_ExecuteMenu(2)
	WAR.ShowHead = 1
	Cls()
	return r
end

--�жϹ�������Եķ���
function War_Direct(x1, y1, x2, y2)
	local x = x2 - x1
	local y = y2 - y1
	if x == 0 and y == 0 then
		return WAR.Person[WAR.CurID]["�˷���"]
	end
	if math.abs(x) < math.abs(y) then
		if y > 0 then
			return 3
		else
			return 0
		end
	else 
		if x > 0 then
			return 1
		else
			return 2
		end
	end
end

--ҽ�Ʋ˵�
function War_DoctorMenu()
	WAR.ShowHead = 0
	local r = War_ExecuteMenu(3)
	WAR.ShowHead = 1
	Cls()
	return r
end

---ִ��ҽ�ƣ��ⶾ�ö�
---flag=1 �ö��� 2 �ⶾ��3 ҽ�� 4 ����
---thingid ������Ʒid
function War_ExecuteMenu(flag, thingid)
	local pid = WAR.Person[WAR.CurID]["������"]
	local step = nil
	local sts =  nil
	if flag == 1 then
		step = math.modf(JY.Person[pid]["�ö�����"] / 40)
	elseif flag == 2 then
		step = math.modf(JY.Person[pid]["�ⶾ����"] / 40)
	elseif flag == 3 then
		step = math.modf(JY.Person[pid]["ҽ������"] / 40)
	elseif flag == 4 then
		step = math.modf(JY.Person[pid]["��������"] / 15) + 1
	end
	War_CalMoveStep(WAR.CurID, step, 1)
	--���Ӳ��������7*7��ʾ
	if pid == 0 and JY.Base["��׼"] == 8 and flag == 3 then
		sts = 1
	elseif pid == 0 and JY.Base["��׼"] == 9 and flag == 1 then 
		sts = 1
	elseif match_ID(pid, 83) and flag == 4 then 
		sts = 1
	end
	local x1, y1 = War_SelectMove(sts)
	if x1 == nil then
		lib.GetKey()
		Cls()
		return 0
	else
		return War_ExecuteMenu_Sub(x1, y1, flag, thingid)
	end
end

--ѡ���书�ĺ������ֶ���AI����������
function War_FightSelectType(movefanwei, atkfanwei, x, y,wugong)
	local x0 = WAR.Person[WAR.CurID]["����X"]
	local y0 = WAR.Person[WAR.CurID]["����Y"]
	if x == nil and y == nil then
		x, y = War_KfMove(movefanwei, atkfanwei,wugong)
		if x == nil then
			lib.GetKey()
			Cls()
			return 
		end
	--�޾Ʋ�����AIҲ��ʾѡ��Χ
	else
		Cat('ʵʱ��Ч����')
		WarDrawAtt(x, y, atkfanwei, 4)
		WarDrawMap(1, x, y)
		ShowScreen()
		lib.Delay(CC.BattleDelay)
		Delay(5,x,y)
		--���޼���תǬ��
		if CC.TX["��תǬ��"] == 1 then
			local z = WAR.CurID
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["������"] == 0 and 0 < JY.Person[0]["����"] then
					WAR.CurID = j
					break
				end
			end
			Cls()
			CurIDTXDH(WAR.CurID, 114,1,"��תǬ��",C_ORANGE);
			WAR.CurID = z
			local ori_x, ori_y = x, y
			local min_x, min_y,max_x, max_y = x-2, y-2, x+2, y+2
			Cls()
			CleanWarMap(3, 255)
			local ssx = 0
			for i = min_x+1, max_x-1 do
				for j = min_y+1, max_y-1 do
					SetWarMap(i, j, 3, 0)
				end
			end
			
			SetWarMap(min_x, y, 3, 0)
			SetWarMap(max_x, y, 3, 0)
			SetWarMap(x, min_y, 3, 0)
			SetWarMap(x, max_y, 3, 0)
			Cat('ʵʱ��Ч����')
			WarDrawMap(1, x, y)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
			while true do
				if JY.Restart == 1 then
					break
				end
				local key, ktype, mx, my = lib.GetKey()
				if key == VK_UP then
					if (y > min_y + 1 and x > min_x and x < max_x) or (x == ori_x and y > min_y) then
						y = y - 1
					end
				elseif key == VK_DOWN then
					if (y < max_y - 1 and x > min_x and x < max_x) or (x == ori_x and y < max_y) then
						y = y + 1
					end
				elseif key == VK_LEFT then
					if (x > min_x + 1 and y > min_y and y < max_y) or (y == ori_y and x > min_x) then
						x = x - 1
					end
				elseif key == VK_RIGHT then
					if (x < max_x - 1 and y > min_y and y < max_y) or (y == ori_y and x < max_x) then
						x = x + 1
					end
				elseif key == VK_ESCAPE then
					x, y = ori_x, ori_y
					WAR.NZQK = 1
					Cat('ʵʱ��Ч����')
					CleanWarMap(7, 0)
					WarDrawAtt(x, y, atkfanwei, 4)
					WarDrawMap(1, x, y)
					ShowScreen()
					lib.Delay(CC.BattleDelay)
					break
				elseif (key == VK_SPACE or key == VK_RETURN) then
					--�������ڵ���300����ʹ��
					if JY.Person[0]["����"] >= 300 then
						JY.Person[0]["����"] = JY.Person[0]["����"] - 300
						WAR.NZQK = 2
						break
					else
						x, y = ori_x, ori_y
						WAR.NZQK = 1
						CleanWarMap(7, 0)
						WarDrawAtt(x, y, atkfanwei, 4)
						WarDrawMap(1, x, y)
						ShowScreen()
						break
					end
				end
				Cat('ʵʱ��Ч����')
				CleanWarMap(7, 0)
				WarDrawAtt(x, y, atkfanwei, 4)
				WarDrawMap(1, x, y)
				ShowScreen()
				lib.Delay(CC.BattleDelay)
			end
			CC.TX["��תǬ��"] = 0
		end
		--���ǣ����ٲ���ܹ���
		if CC.TX["���ٲ�"] == 1 then
			local z = WAR.CurID
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["������"] == 0 and 0 < JY.Person[0]["����"] then
					WAR.CurID = j
					break
				end
			end
			Cls()
			CurIDTXDH(WAR.CurID, 129,1,"���ٲ�",Violet);
			WAR.Person[WAR.CurID]["�ƶ�����"] = 6
			War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["�ƶ�����"], 0)
			local x, y = nil, nil
			while 1 do
				if JY.Restart == 1 then
					break
				end
				x, y = War_SelectMove()
				if x ~= nil then
					WAR.ShowHead = 0					
					War_MovePerson(x, y)
					break;
				end
			end
			WAR.CurID = z
			CC.TX["���ٲ�"] = 0
		end
				--��Ѱ�� ��������ˮ��ܹ���
		if JY.Person[498]["Ʒ��"] == 30 then
			local z = WAR.CurID
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["������"] == 0 and 0 < JY.Person[0]["����"] then
					WAR.CurID = j
					break
				end
			end
			Cls()
			CurIDTXDH(WAR.CurID, 129,1,"��������ˮ",Violet);
		
			WAR.Person[WAR.CurID]["�ƶ�����"] = 6
			War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["�ƶ�����"], 0)
			local x, y = nil, nil
			while 1 do
				if JY.Restart == 1 then
					break
				end
				x, y = War_SelectMove()
				if x ~= nil then
					WAR.ShowHead = 0
					War_MovePerson(x, y)
					break;
				end
			end
			WAR.CurID = z
			JY.Person[498]["Ʒ��"] = 10
		end
		--С��Ӱ��
		if JY.Person[66]["Ʒ��"] == 90 then
			JY.Person[66]["Ʒ��"] = 50
			if WAR.XZ_YB[1] ~= nil then
				local z = WAR.CurID
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["������"] == 0 and 0 < JY.Person[0]["����"] then
						WAR.CurID = j
						break
					end
				end
				Cls()
				WarDrawMap(0)
				CurIDTXDH(WAR.CurID, 122,1, "������˹����", C_RED)
				lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, -1)
				lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, -1)
                lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, -1)
				WarDrawMap(0)
				WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"] = WAR.XZ_YB[1], WAR.XZ_YB[2]
				WarDrawMap(0)
				CurIDTXDH(WAR.CurID, 122,1, "�ù�����������", C_RED)
				lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, WAR.Person[WAR.CurID]["��ͼ"])
				lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, WAR.CurID)
                SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, JY.Person[WAR.Person[WAR.CurID]["������"]]['ͷ�����'])
				WarDrawMap(0)
				WAR.XZ_YB[1]=nil
				WAR.XZ_YB[2]=nil
				WAR.CurID = z
			end
		end
		CleanWarMap(7,0)
		--lib.Delay(200)
	end
	if not War_Direct(x0, y0, x, y) then
		WAR.Person[WAR.CurID]["�˷���"] = WAR.Person[WAR.CurID]["�˷���"]
	else
		WAR.Person[WAR.CurID]["�˷���"] = War_Direct(x0, y0, x, y)
	end
	SetWarMap(x, y, 4, 1)
	WAR.EffectXY = {}
	return x, y
end

--������һ�����ƶ�������
function War_FindNextStep(steparray, step, flag, id)
	local num = 0
	local step1 = step + 1
  
	--ZOC�ж�
	local fujinnum = function(tx, ty)
		if flag ~= 0 or id == nil then
			return 0
		end
		local tnum = 0
		local wofang = WAR.Person[id]["�ҷ�"]
		local tv = nil
		tv = GetWarMap(tx + 1, ty, 2)
		if tv ~= -1 and WAR.Person[tv]["�ҷ�"] ~= wofang then
			tnum = 9999
		end
		tv = GetWarMap(tx - 1, ty, 2)
		if tv ~= -1 and WAR.Person[tv]["�ҷ�"] ~= wofang then
			tnum = 999
		end
		tv = GetWarMap(tx, ty + 1, 2)
		if tv ~= -1 and WAR.Person[tv]["�ҷ�"] ~= wofang then
			tnum = 999
		end
		tv = GetWarMap(tx, ty - 1, 2)
		if tv ~= -1 and WAR.Person[tv]["�ҷ�"] ~= wofang then
			tnum = 999
		end
		return tnum
	end
  
  for i = 1, steparray[step].num do
    if steparray[step].bushu[i] > 0 then
      steparray[step].bushu[i] = steparray[step].bushu[i] - 1
      local x = steparray[step].x[i]
      local y = steparray[step].y[i]
      if x + 1 < CC.WarWidth - 1 then
        local v = GetWarMap(x + 1, y, 3)
        if v == 255 and War_CanMoveXY(x + 1, y, flag) == true then
	        num = num + 1
	        steparray[step1].x[num] = x + 1
	        steparray[step1].y[num] = y
	        SetWarMap(x + 1, y, 3, step1)
	        steparray[step1].bushu[num] = steparray[step].bushu[i] - fujinnum(x + 1, y)
      	end
      end
      
      if x - 1 > 0 then
        local v = GetWarMap(x - 1, y, 3)
        if v == 255 and War_CanMoveXY(x - 1, y, flag) == true then
	        num = num + 1
	        steparray[step1].x[num] = x - 1
	        steparray[step1].y[num] = y
	        SetWarMap(x - 1, y, 3, step1)
	        steparray[step1].bushu[num] = steparray[step].bushu[i] - fujinnum(x - 1, y)
	      end
      end
      
      if y + 1 < CC.WarHeight - 1 then
        local v = GetWarMap(x, y + 1, 3)
        if v == 255 and War_CanMoveXY(x, y + 1, flag) == true then
	        num = num + 1
	        steparray[step1].x[num] = x
	        steparray[step1].y[num] = y + 1
	        SetWarMap(x, y + 1, 3, step1)
	        steparray[step1].bushu[num] = steparray[step].bushu[i] - fujinnum(x, y + 1)
	      end
      end
      
      if y - 1 > 0 then
	      local v = GetWarMap(x, y - 1, 3)
	      if v == 255 and War_CanMoveXY(x, y - 1, flag) == true then
		      num = num + 1
		      steparray[step1].x[num] = x
		      steparray[step1].y[num] = y - 1
		      SetWarMap(x, y - 1, 3, step1)
		      steparray[step1].bushu[num] = steparray[step].bushu[i] - fujinnum(x, y - 1)
	    	end
    	end
    end
  end
  if num == 0 then
    return 
  end
  steparray[step1].num = num
  War_FindNextStep(steparray, step1, flag, id)
end

--�ж��Ƿ��ܴ򵽵���
function War_GetCanFightEnemyXY()
	local num, x, y = nil, nil, nil
	num, x, y = War_realjl(WAR.CurID)
	if num == -1 then
		return 
	end
	return x, y
end

--�ƶ�
function War_MoveMenu()
  if WAR.Person[WAR.CurID]["������"] ~= -1 then
    WAR.ShowHead = 0
    if WAR.Person[WAR.CurID]["�ƶ�����"] <= 0 then
      return 0
    end
    War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["�ƶ�����"], 0)
    local r = nil
    local x, y = War_SelectMove()
    if x ~= nil then
      War_MovePerson(x, y, 1)
      r = 1
    else
      r = 0
      WAR.ShowHead = 1
      Cls()
    end
    lib.GetKey()
    return r
  else
    local ydd = {}
    local n = 1
    for i = 0, WAR.PersonNum - 1 do
      if WAR.Person[i]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.Person[i]["����"] == false then
        ydd[n] = i
        n = n + 1
      end
    end
    local dx = ydd[math.random(n - 1)]
    local DX = WAR.Person[dx]["����X"]
    local DY = WAR.Person[dx]["����Y"]
    local YDX = {DX + 1, DX - 1, DX}
    local YDY = {DY + 1, DY - 1, DY}
    local ZX = YDX[math.random(3)]
    local ZY = YDY[math.random(3)]
    if not SceneCanPass(ZX, ZY) or GetWarMap(ZX, ZY, 2) < 0 then
      SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, -1)
      SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, -1)
      SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, -1)
      WAR.Person[WAR.CurID]["����X"] = ZX
      WAR.Person[WAR.CurID]["����Y"] = ZY
      SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, WAR.CurID)
      SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, WAR.Person[WAR.CurID]["��ͼ"])
      SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, JY.Person[WAR.Person[WAR.CurID]["������"]]['ͷ�����'])
    end
  end
  return 1
end

--�����ƶ�
function War_MovePerson(x, y, flag)
	local id = WAR.Person[WAR.CurID]['������']
 	local x1 = x
 	local y1 = y
    if not flag then
        flag = 0
    end
    local movenum = GetWarMap(x, y, 3)
    local movetable = {}
    for i = movenum, 1, -1 do
        movetable[i] = {}
        movetable[i].x = x
        movetable[i].y = y
        if GetWarMap(x - 1, y, 3) == i - 1 then
            x = x - 1
            movetable[i].direct = 1
        elseif GetWarMap(x + 1, y, 3) == i - 1 then
            x = x + 1
            movetable[i].direct = 2
        elseif GetWarMap(x, y - 1, 3) == i - 1 then
            y = y - 1
            movetable[i].direct = 3
        elseif GetWarMap(x, y + 1, 3) == i - 1 then
            y = y + 1
            movetable[i].direct = 0
        end
    end
	--�����ƶ�����
	movetable.num = movenum
	movetable.now = 0
	WAR.Person[WAR.CurID].Move = movetable
	if WAR.Person[WAR.CurID]["�ƶ�����"] < movenum then
		movenum = WAR.Person[WAR.CurID]["�ƶ�����"]
		WAR.Person[WAR.CurID]["�ƶ�����"] = 0
	else
		WAR.Person[WAR.CurID]["�ƶ�����"] = WAR.Person[WAR.CurID]["�ƶ�����"] - movenum
	end
	--�ƶ�����
	--������������ʾ
	--��Ϧ��Ů���۽����������Ƿ�ѧ�����ٲ�(WAR.Person[WAR.CurID]["������"] == 0 and JY.Base["��׼"] > 0 and JY.Person[615]["�۽�����"] == 1)  and
	if match_ID(id, 9976) then 
		Cat('����̫��',x1,y1)
		--[[
	elseif  movenum > 2 and JY.Person[id]["�����Ṧ"] > 0 then
		local a = 0
		local gender = 0
		if JY.Person[0]["�Ա�"] > 0 then
			gender = 1
		end
		for i = 1, movenum do
			local t1 = lib.GetTime()
			if a == 6 then
				a = 0
			end
			if i == 1 then
				SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, -1)
				SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, -1)
			end
			if i > 3 then
				SetWarMap(movetable[i-3].x, movetable[i-3].y, 2, -1)
				SetWarMap(movetable[i-3].x, movetable[i-3].y, 5, -1)
			end
			if i == movenum then
				SetWarMap(movetable[i-2].x, movetable[i-2].y, 2, -1)
				SetWarMap(movetable[i-2].x, movetable[i-2].y, 5, -1)
				SetWarMap(movetable[i-1].x, movetable[i-1].y, 2, -1)
				SetWarMap(movetable[i-1].x, movetable[i-1].y, 5, -1)
			end
			WAR.Person[WAR.CurID]["����X"] = movetable[i].x
			WAR.Person[WAR.CurID]["����Y"] = movetable[i].y
			WAR.Person[WAR.CurID]["�˷���"] = movetable[i].direct
			if i < movenum then
				WAR.Person[WAR.CurID]["��ͼ"] = WarCalPersonPic2(WAR.CurID, gender) + (a)*2
			else
				WAR.Person[WAR.CurID]["��ͼ"] = WarCalPersonPic(WAR.CurID)
			end
			--WAR.Person[WAR.CurID]["��ͼ"] = WarCalPersonPic(WAR.CurID)
			SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, WAR.CurID)
			SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, WAR.Person[WAR.CurID]["��ͼ"])
			Cat('ʵʱ��Ч����')

			WarDrawMap(0)
			ShowScreen()
			a = a + 1
			lib.Delay(CC.BattleDelay)
		end
		]]
	else
		for i = 1, movenum do
			local t1 = lib.GetTime()
			SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, -1)
			SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, -1)
            SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, -1)
			WAR.Person[WAR.CurID]["����X"] = movetable[i].x
			WAR.Person[WAR.CurID]["����Y"] = movetable[i].y
			WAR.Person[WAR.CurID]["�˷���"] = movetable[i].direct
			WAR.Person[WAR.CurID]["��ͼ"] = WarCalPersonPic(WAR.CurID)
			SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, WAR.CurID)
			SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, WAR.Person[WAR.CurID]["��ͼ"])
            SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, JY.Person[WAR.Person[WAR.CurID]["������"]]['ͷ�����'])
			Cat('ʵʱ��Ч����')
			WarDrawMap(0)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end
	--�����Ṧ�Ļ�����ZOC�ƶ�����0����֮��0
	if JY.Person[WAR.Person[WAR.CurID]["������"]]["�����Ṧ"] == 0 then
		local fujinnum = function(tx, ty)
			local tnum = 0
			local wofang = WAR.Person[WAR.CurID]["�ҷ�"]
			local tv = nil
			tv = GetWarMap(tx + 1, ty, 2)
			if tv ~= -1 and WAR.Person[tv]["�ҷ�"] ~= wofang then
				tnum = 999
			end
			tv = GetWarMap(tx - 1, ty, 2)
			if tv ~= -1 and WAR.Person[tv]["�ҷ�"] ~= wofang then
				tnum = 999
			end
			tv = GetWarMap(tx, ty + 1, 2)
			if tv ~= -1 and WAR.Person[tv]["�ҷ�"] ~= wofang then
				tnum = 999
			end
			tv = GetWarMap(tx, ty - 1, 2)
			if tv ~= -1 and WAR.Person[tv]["�ҷ�"] ~= wofang then
				tnum = 999
			end
			return tnum
		end
		if fujinnum(WAR.Person[WAR.CurID]["����X"],WAR.Person[WAR.CurID]["����Y"]) ~= 0 then
			WAR.Person[WAR.CurID]["�ƶ�����"] = 0
		end
	end
end

---�ö��˵�
function War_PoisonMenu()
	WAR.ShowHead = 0
	local r = War_ExecuteMenu(1)
	WAR.ShowHead = 1
	Cls()
	return r
end

--ս����Ϣ
function War_RestMenu()
	if WAR.CurID and WAR.CurID >= 0  then
		local pid = WAR.Person[WAR.CurID]["������"]
		--�߻�����Ϣ
		if WAR.PD["�߻�״̬"][pid] == 1 then
			return 1
		end
		local vv = math.modf(JY.Person[pid]["����"] / 100 - JY.Person[pid]["���˳̶�"] / 50 - JY.Person[pid]["�ж��̶�"] / 50) + 2
		if WAR.Person[WAR.CurID]["�ƶ�����"] > 0 then
			vv = vv + 2
		end
		if inteam(pid) then
			vv = vv + math.random(3)
		else
			vv = vv + 6
		end
		vv = (vv) / 120
		local v = 3 + Rnd(3)
		WAR.Person[WAR.CurID]["��������"] = AddPersonAttrib(pid, "����", v)
        
        if JY.Person[pid]["����"] < 100 then
            local hn = 3 + math.modf(JY.Person[pid]["�������ֵ"] * (vv))
            WAR.Person[WAR.CurID]["��������"] = AddPersonAttrib(pid, "����", hn)
        else
			if not inteam(pid) then
			v = 3 + math.modf(JY.Person[pid]["�������ֵ"]  * (vv))
			else
			v = 3 + math.modf(JY.Person[pid]["�������ֵ"] /4* (vv))
			end
			WAR.Person[WAR.CurID]["��������"] = AddPersonAttrib(pid, "����", v)
			v = 3 + math.modf(JY.Person[pid]["�������ֵ"] * (vv))
			WAR.Person[WAR.CurID]["��������"] = AddPersonAttrib(pid, "����", v)
		end
		
		War_Show_Count(WAR.CurID);		--��ʾ��ǰ�����˵ĵ���
        
        if PersonKF(pid, 227) then 
			Cls()
			WAR.Defup[pid] = 1
			CurIDTXDH(WAR.CurID, 85,1,"��Ϣ������", LimeGreen);
        end
		
		if match_ID(pid, 721) then 
			Cls()
			WAR.Actup[pid] = 2;
			WAR.Defup[pid] = 1
			CurIDTXDH(WAR.CurID, 85,1,"����������", LimeGreen);
        end
		--��������Ϣ������+����
		if match_ID(pid, 606) then
			Cls()
			WAR.Actup[pid] = 2;
			WAR.Defup[pid] = 1
			CurIDTXDH(WAR.CurID, 85,1,"�˳��ᢡ���ʤǧ��", LimeGreen);
		end	
		--[[NPC��Ϣ���Զ�����
		--�����Ϣ������
		if not isteam(pid) and WAR.XTTX == 0 then
			if math.modf(JY.Person[pid]["�������ֵ"] / 2) < JY.Person[pid]["����"] then
				Cls()
				return War_ActupMenu()
			else
				Cls()
				return War_DefupMenu()
			end
		else
			return 1
		end]]
		return 1
	end
end

--ս���鿴״̬
function War_StatusMenu()
	WAR.ShowHead = 0
	Menu_Status()
	WAR.ShowHead = 1
	Cls()	
end

--ս����Ʒ�˵�
function War_ThingMenu()
	WAR.ShowHead = 0
	local thing = {}
	local thingnum = {}
	for i = 0, CC.MyThingNum - 1 do
		thing[i] = -1
		thingnum[i] = 0
	end
	local num = 0
	for i = 0, CC.MyThingNum - 1 do
		local id = JY.Base["��Ʒ" .. i + 1]
		if id >= 0 and (JY.Thing[id]["����"] == 1 or JY.Thing[id]["����"] == 3 or JY.Thing[id]["����"] == 4) then
			thing[num] = id
			thingnum[num] = JY.Base["��Ʒ����" .. i + 1]
			num = num + 1
		end
	end
	local r = SelectThing(thing, thingnum)
	Cls()
	local rr = 0
	if r >= 0 and UseThing(r) == 1 then
		rr = 1
	end
	WAR.ShowHead = 1
	Cls()
	return rr
end


--�Զ�ս���ж��Ƿ���ҽ��
function War_ThinkDoctor()
  local pid = WAR.Person[WAR.CurID]["������"]
  if JY.Person[pid]["����"] < 50 or JY.Person[pid]["ҽ������"] < 20 then
    return -1
  end
  if JY.Person[pid]["ҽ������"] + 20 < JY.Person[pid]["���˳̶�"] then
    return -1
  end
  local rate = -1
  local v = JY.Person[pid]["�������ֵ"] - JY.Person[pid]["����"]
  if JY.Person[pid]["ҽ������"] < v / 4 then
    rate = 30
  elseif JY.Person[pid]["ҽ������"] < v / 3 then
      rate = 50
  elseif JY.Person[pid]["ҽ������"] < v / 2 then
      rate = 70
  else
    rate = 90
  end
  if Rnd(100) < rate then
    return 5
  end
  return -1
end

--�ܷ��ҩ���Ӳ���
--flag=2 ������3������4����  6 �ⶾ
function War_ThinkDrug(flag)
  local pid = WAR.Person[WAR.CurID]["������"]
  local str = nil
  local r = -1
  if flag == 2 then
    str = "������"
  elseif flag == 3 then
    str = "������"
  elseif flag == 4 then
    str = "������"
  elseif flag == 6 then
    str = "���ж��ⶾ"
  else
    return r
  end
  local function Get_Add(thingid)
    if flag == 6 then
      return -JY.Thing[thingid][str]
    else
      return JY.Thing[thingid][str]
    end
  end
  
  --�����Ƿ���ҩƷ
  if inteam(pid) and WAR.Person[WAR.CurID]["�ҷ�"] == true then
    for i = 1, CC.MyThingNum do
      local thingid = JY.Base["��Ʒ" .. i]
      if thingid >= 0 and JY.Thing[thingid]["����"] == 3 and Get_Add(thingid) > 0 then
        r = flag
        break;
      end
    end
  else
    for i = 1, 4 do
      local thingid = JY.Person[pid]["Я����Ʒ" .. i]
      if thingid >= 0 and JY.Thing[thingid]["����"] == 3 and Get_Add(thingid) > 0 then
        r = flag
        break;
      end
    end
  end
  return r
end

--ʹ�ð���
function War_UseAnqi(id)

	return War_ExecuteMenu(4, id)
end

--��ʼ��ս������
function WarLoad(warid)
	WarSetGlobal()
	local data = Byte.create(CC.WarDataSize)
	Byte.loadfile(data, CC.WarFile, warid * CC.WarDataSize, CC.WarDataSize)
	LoadData(WAR.Data, CC.WarData_S, data)
	WAR.ZDDH = warid
end

--����ս����ͼ
function WarLoadMap(mapid)
	lib.Debug(string.format("load war map %d", mapid))
	lib.LoadWarMap(CC.WarMapFile[1], CC.WarMapFile[2], mapid, 12, CC.WarWidth, CC.WarHeight)
end


function GetWarMap(x, y, level)
	if x > 63 or x < 0 or y > 63 or y < 0 then
		return 
	end
	return lib.GetWarMap(x, y, level)
end

function SetWarMap(x, y, level, v)
	if x > 63 or x < 0 or y > 63 or y < 0 then
		return 
	end
	lib.SetWarMap(x, y, level, v)
end

function CleanWarMap(level, v)
	lib.CleanWarMap(level, v)
end

--����������ͼ
function WarSetPerson()
	CleanWarMap(2, -1)
	CleanWarMap(5, -1)
    CleanWarMap(10, -1)
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["����"] == false then
            
			SetWarMap(WAR.Person[i]["����X"], WAR.Person[i]["����Y"], 2, i)
			SetWarMap(WAR.Person[i]["����X"], WAR.Person[i]["����Y"], 5, WAR.Person[i]["��ͼ"])
            SetWarMap(WAR.Person[i]["����X"], WAR.Person[i]["����Y"], 10, JY.Person[WAR.Person[i]["������"]]['ͷ�����'])
		end
	end
	--��������컯��
	if WAR.ZTHSB == 1 then
		lib.SetWarMap(WAR.Person[WAR.ZT_id]["����X"], WAR.Person[WAR.ZT_id]["����Y"], 5, -1)
	end
end

--��ʾ�书�������������˶�������Ч��
function War_ShowFight(pid, wugong, wugongtype, level, x, y, eft, ZHEN_ID)
	--����ʱ����ʾѪ��
	WAR.ShowHP = 0
	
	--û�кϻ�
	if not ZHEN_ID then
		ZHEN_ID = -1
	end
	
	--�ڹ�
	if wugongtype == 6 then
		wugongtype = WAR.NGXS
	end
	if wugong == 93 then
		wugongtype = 5
	end	
	--�޾Ʋ���������һ���µĶ���˳��
	if wugongtype == 2 then
		wugongtype = 1
	elseif wugongtype > 2 and wugongtype < 6 then
		wugongtype = wugongtype - 1
	end
  
	local x0 = WAR.Person[WAR.CurID]["����X"]
	local y0 = WAR.Person[WAR.CurID]["����Y"]
	
	local starteft = 0
	
	if pid > -1 then
	Cat('����̫��2',1)
	local using_anqi = 0
	local anqi_name;
	--��������
	if wugongtype == -1 then
		using_anqi = 1
		anqi_name = JY.Thing[eft]["����"]
		--�����ֺ�ɳ��Ӱ
		if match_ID(pid, 83) then
			anqi_name = "��ɳ��Ӱ��"..anqi_name
		end
		eft = JY.Thing[eft]["�����������"]
		--��Ѱ��С��ɵ� �����鷢
		if  WAR.XLFD[pid] ~= nil then
			anqi_name = "С��ɵ��������鷢"
		end		
		eft = 125
	end	

	
	--ɨ����ɮ  �������
	if match_ID(pid, 114) then
		eft = math.random(100)
	end
	--����ˮ ����
	if match_ID(pid, 652) then
		eft = 75
	end
	--½�� ����
	if match_ID(pid, 497) then
		eft = math.random(100)
	end
   if  match_ID(pid,721) and (WAR.PD['��¶��'][pid] ~= nil or WAR.PD['�滨��'][pid] ~= nil or WAR.PD['��ī�Ͼ�'][pid] ~= nil or WAR.PD['�屦���۾�'][pid] ~= nil )then
     eft =168
    end	  
	--��ħ�ȷ�����
	if (wugong == 86 or wugong == 96 or wugong == 82 or wugong == 83) and ShiZunXM(pid) then
		eft = 7
	end		
	--�׽ ����
	if wugong == 108 then
		eft = math.random(100)
	end	
	--������ ����
	if WAR.LDJT == 1 then
	   eft = 9
	end	
 
    if wugong == 73  then
	eft = 61
	end	
	--˫���ϱڶ���
	if (wugong == 39 or wugong == 42 or wugong == 139 ) and ShuangJianHB(pid) then 
		eft = 83
	end	
	--��Ȼ���⶯��
	if  WAR.ARJY == 1 or WAR.ARJY1 == 1 then
		eft = 7
	end

	--����  ���󶯻�
	if match_ID(pid, 84) and wugong == 103 then
		eft = 73
	end

	--���߰��嶯��
	if wugong == 40 and WAR.JSAY == 1 then
		eft = 44
	end
	--����ڶ���
	if WAR.PD["�����"][pid] == 1  then
	   eft = 169
	end
	--
	if WAR.WDKTJ == 1 then 
		eft = 170
	end
	if  WAR.AJFHNP == 1 then
		eft = 61
	end
	--�������ν����嶯��
	if  WAR.QXWXJ == 1 then
		eft = 125
	end	
	--
	if  WAR.YQFSQ == 1 then
		eft = 126
	end	
	--׷������Ķ���
	if wugong == 192 then
	 eft = 162
	end	
	--���������Ķ���
	if wugong == 45 then
	 eft = 164
	end	
			
	--������
	if wugong == 30 and PersonKF(pid,175) then
		eft = 138
	end
	--����̩ɽ
	if wugong == 31 and PersonKF(pid,175) then
		eft = 138
	end
	--��������
	if wugong == 32 and PersonKF(pid,175) then
		eft = 138
	end
	--��������
	if wugong == 33 and PersonKF(pid,175) then
		eft = 138
	end
	--����̫��
	if wugong == 34 and PersonKF(pid,175) then
		eft = 138
	end
	--������ѩ��
	if wugong == 185  then
		eft = 129
	end	
	--�޾Ʋ�������Ч����
	if pid == 0 and JY.Base["����"] == 1 then
		if JY.Person[0]["�Ա�"] == 0 then
			eft = 65
		else
			eft = 8
		end
	end

	--������ǹ��
	if match_ID(pid,650) and wugong == 68 then
		eft = 150
	end
	
	--����ʤ���ж���
	if wugong == 47 and WAR.FQY == 1 then
		eft = 83
	end
------------------------------------------------------
-- ���书��Ч	
	local ex, ey = -1, -1;		
	--ָ��XY����ôֻ��ʾ��һ������ʾ����
	if eft == 170 then
		ex, ey = x, y;
     end
	if eft == 168 then
		ex, ey = x, y;		
	end
	if eft == 169 then
		ex, ey = x, y;		
	end	
 ----------------------------------------------------- 
	--�����񽣵���������Ϊȭ��
	if wugong == 49 then
		wugongtype = 1
	end

	--�ϻ�����
	local ZHEN_pid, ZHEN_type, ZHEN_startframe, ZHEN_fightframe = nil, nil, nil, nil
	if ZHEN_ID >= 0 then
		ZHEN_pid = WAR.Person[ZHEN_ID]["������"]
		ZHEN_type = wugongtype
		ZHEN_startframe = 0
		ZHEN_fightframe = 0
	end
  
	local fightdelay, fightframe, sounddelay = nil, nil, nil
	if wugongtype >= 0 then
		fightdelay = JY.Person[pid]["���ж����ӳ�" .. wugongtype + 1]
		fightframe = JY.Person[pid]["���ж���֡��" .. wugongtype + 1]
		sounddelay = JY.Person[pid]["�书��Ч�ӳ�" .. wugongtype + 1]
	else
		fightdelay = 0
		fightframe = -1
		sounddelay = -1
	end
  
	if fightdelay == 0 or fightframe == 0 then
		for i = 1, 5 do
			if JY.Person[pid]["���ж���֡��" .. i] ~= 0 then
				fightdelay = JY.Person[pid]["���ж����ӳ�" .. i]
				fightframe = JY.Person[pid]["���ж���֡��" .. i]
				sounddelay = JY.Person[pid]["�书��Ч�ӳ�" .. i]
				wugongtype = i - 1
			end
		end
	end

	if ZHEN_ID >= 0 then
		if JY.Person[ZHEN_pid]["���ж���֡��" .. ZHEN_type + 1] == 0 then
			for i = 1, 5 do
				if JY.Person[ZHEN_pid]["���ж���֡��" .. i] ~= 0 then
					ZHEN_type = i - 1
					ZHEN_fightframe = JY.Person[ZHEN_pid]["���ж���֡��" .. i]
				end
			end
		else
			ZHEN_fightframe = JY.Person[ZHEN_pid]["���ж���֡��" .. ZHEN_type + 1]
		end
	end
  
	local framenum = fightdelay + CC.Effect[eft]
	
	local oldframe = framenum
	if framenum < fightdelay + 20 then 
	   framenum = fightdelay + 20
	end
	
	local startframe = 0
	if wugongtype >= 0 then
		for i = 0, wugongtype - 1 do
			startframe = startframe + 4 * JY.Person[pid]["���ж���֡��" .. i + 1]
		end
	end
	if ZHEN_ID >= 0 and ZHEN_type >= 0 then
		for i = 0, ZHEN_type - 1 do
			ZHEN_startframe = ZHEN_startframe + 4 * JY.Person[ZHEN_pid]["���ж���֡��" .. i + 1]
		end
	end
  
	--local starteft = 0
	for i = 0, eft - 1 do
		starteft = starteft + CC.Effect[i]
	end

	WAR.Person[WAR.CurID]["��ͼ����"] = 0
	WAR.Person[WAR.CurID]["��ͼ"] = WarCalPersonPic(WAR.CurID)
	if ZHEN_ID >= 0 then
		WAR.Person[ZHEN_ID]["��ͼ����"] = 0
		WAR.Person[ZHEN_ID]["��ͼ"] = WarCalPersonPic(ZHEN_ID)
	end
  
	local oldpic = WAR.Person[WAR.CurID]["��ͼ"] / 2		--��ǰ��ͼ��λ��
	local oldpic_type = 0
	local oldeft = -1
	local kfname = JY.Wugong[wugong]["����"]
	local showsize = CC.FontBig
	local showx = CC.ScreenW / 2 - showsize * string.len(kfname) / 4
	local hb = GetS(JY.SubScene, x0, y0, 4)
  
	--��ʾ�书���ŵ���Ч����4
	if wugong ~= 0 then
		if WAR.LHQ_BNZ == 1 then
			kfname = "������"
		end
		if WAR.JGZ_DMZ == 1 then
			kfname = "��Ħ��"
		end
		if WAR.WD_CLSZ == 1 then
			kfname = "��������"
		end
		if WAR.QZ_QXJF == 1 then
			kfname = "���ǽ���"
		end	
		if ( wugong == 22 or wugong == 189 ) and JinGangBR(pid) then
			kfname = "��հ�����"
		end	
        if wugong == 93 then
 	       kfname = "ʥ������"
		end	
	end
	
	--������һ������������
	if WAR.YQFSQ == 1 then
		kfname = "����ͨ��һ��������"
	end	
	if WAR.PD["��������"][pid] == 1 then
		kfname = "��������"
		WAR.PD["��������"][pid] =nil
	end	
	if WAR.PD["��������"][pid] == 2 then
		kfname = "�������ơ���"
		WAR.PD["��������"][pid] =nil
	end	
	--���߰���
	if WAR.JSAY == 1 then
		kfname = "���塤���߿���"
	end
	--Ī���������ν� ����
	if WAR.QXWXJ == 1 then
		kfname = "�������������ν������ν���"
	end	
	--�����ź���ʮ�˱���ʾ����
	if wugong == 206 and match_ID(pid, 612) and WAR.ZWX > 0 then
		kfname = kfname.." X "..WAR.ZWX
	end 
	--׿���ۺ���ʮ�˱���ʾ����
	if wugong == 206 and match_ID(pid, 613) and WAR.ZWX > 0 then
		kfname = kfname.." X "..WAR.ZWX
	end 	
	--׿��������������ʾ����
	if wugong == 205 and match_ID(pid, 613) and WAR.ZWX > 0 then
		kfname = kfname.." X "..WAR.ZWX
	end 		
	--�������嶾��ʾ����
	if wugong == 3 and match_ID(pid, 83) and WAR.HTS > 0 then
		kfname = kfname.." X "..WAR.HTS
	end 
	--����������
	if WAR.YLTW > 0 then
		kfname = "��������������"..kfname
	end
	--���°˷�
	if WAR.KZJYBF > 0 then
		kfname = "�����°˷�����"..WAR.KZJYBF.." ʽ��"..kfname
	end	

    if WAR.JTYJ1 == 1 then
	  kfname = "������һ������"..kfname
	  end  
    if ShuangJianHB(pid) and (wugong == 42 or wugong ==39 or wugong == 139 ) then
	  kfname = "��˫����赡���"..kfname
	  end 	  
    if WAR.BXXHSJ == 1 then
	  kfname = "��ѩ���񽣡���"..kfname
	  end  	  
	--�ڹ���ʾ�������ϵ
	if WAR.NGXS > 0 and wugong ~= 93 then
		local display = {"ȭ�","ָ��","����","����","����"}
		kfname = kfname.."��"..display[WAR.NGXS]
	end
  
	if ZHEN_ID >= 0 then
		kfname = "˫�˺ϻ���"..kfname
	end
  
	--��Ч����4���书������ʾ
	if wugong > 0 or WAR.hit_DGQB == 1 then				--ʹ���书ʱ����ʾ��������ܷ���Ҳ��ʾ
		if WAR.Person[WAR.CurID]["��Ч����4"] ~= nil then
			for k=0, 30, 4 do
				local i = k 
				if i > 20 then 
					i = 20 
				end	
				Cat('ʵʱ��Ч����')
				Cls()
				local n, strs = Split(WAR.Person[WAR.CurID]["��Ч����4"], "��");
				local len = string.len(WAR.Person[WAR.CurID]["��Ч����4"]);
				local color = RGB(255,40,10);
				local off = 0;
				for j=1, n do
					if strs[j] == "����" or strs[j] == "�츳�⹦.¯����" 
					or strs[j] == "��������˫����" or strs[j] == "Ӣ����˫������" or strs[j] == "������ӳ��ȸ��" 
					or strs[j] == "̫��֮��.Բת����" then
						color = M_LightBlue;
					elseif strs[j] == "���һ���" then
						color = M_DarkOrange
					else
						color = RGB(255,40,10);
					end
					if j > 1 then
						strs[j] = strs[j];
						off = off + 42
					end		
					DrawStrBox(-1, 10 + off, strs[j], color, 10+i) 
				end
				
				ShowScreen()
				lib.Delay(CC.BattleDelay)
			end
		end
		--�书��ʾ
		for n = 5, 20 do
			local i = n 
			if i > 10 then 
				i = 10
			end
			Cat('ʵʱ��Ч����')
			Cls()
			KungfuString(kfname, CC.ScreenW / 2 -#kfname/2, CC.ScreenH / 3 - 20 - hb  , C_GOLD, CC.FontBig+i, CC.FontName, 0)
			ShowScreen()
			lib.Delay(CC.BattleDelay)  
		end
	end
	
	--������ʾ
	if using_anqi == 1 then
		for i = 5, 10 do
			Cat('ʵʱ��Ч����')
			Cls()
			if WAR.KHSZ == 1 then
				KungfuString("��������", CC.ScreenW / 2 -#anqi_name/2, CC.ScreenH / 3 - 20 - hb  , C_RED, CC.FontBig+i, CC.FontName, 0)
			else
				KungfuString(anqi_name.."��"..WAR.AQBS, CC.ScreenW / 2 -#anqi_name/2, CC.ScreenH / 3 - 20 - hb  , C_GOLD, CC.FontBig+i, CC.FontName, 0)
			end
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end
  
  --��ʾ��������
	for i = 0, framenum - 1 do
		if JY.Restart == 1 then
			break
		end
		local tstart = lib.GetTime()
		local mytype = nil
		if fightframe > 0 then
			WAR.Person[WAR.CurID]["��ͼ����"] = 1
			mytype = 101+JY.Person[pid]['ͷ�����']
			if i < fightframe then
				WAR.Person[WAR.CurID]["��ͼ"] = (startframe + WAR.Person[WAR.CurID]["�˷���"] * fightframe + i) * 2
			end
		else
			WAR.Person[WAR.CurID]["��ͼ����"] = 0
			WAR.Person[WAR.CurID]["��ͼ"] = WarCalPersonPic(WAR.CurID)
			mytype = 0
		end
    
		if ZHEN_ID >= 0 then
			if ZHEN_fightframe > 0 then
				WAR.Person[ZHEN_ID]["��ͼ����"] = 1
				
				if i < ZHEN_fightframe and i < oldframe - 1 then
					WAR.Person[ZHEN_ID]["��ͼ"] = (ZHEN_startframe + WAR.Person[ZHEN_ID]["�˷���"] * ZHEN_fightframe + i) * 2
				else
					WAR.Person[ZHEN_ID]["��ͼ"] = WarCalPersonPic(ZHEN_ID)
				end
			else
				WAR.Person[ZHEN_ID]["��ͼ����"] = 0
				WAR.Person[ZHEN_ID]["��ͼ"] = WarCalPersonPic(ZHEN_ID)
			end
			SetWarMap(WAR.Person[ZHEN_ID]["����X"], WAR.Person[ZHEN_ID]["����Y"], 5, WAR.Person[ZHEN_ID]["��ͼ"])
		end
    
    if i == sounddelay then
		PlayWavAtk(JY.Wugong[wugong]["������Ч"])		--
    end
    
    if i == fightdelay then
		PlayWavE(eft)
    end
    
	--�����񽣵���Ч
    if i == 1 and WAR.LMSJwav == 1 then
		PlayWavAtk(31)
		WAR.LMSJwav = 0
    end
    
    local pic = WAR.Person[WAR.CurID]["��ͼ"] / 2
    
    lib.SetClip(0, 0, 0, 0)
    
    oldpic = pic
    oldpic_type = mytype
    
    --�޾Ʋ�����������Ч������ʾ 8-3
   
    if i < fightdelay then
		WarDrawMap(4, pic * 2, mytype, -1)
		
		--Ԭ��־����������ʾ
		--�����ҷ�
		if match_ID(pid, 54) and inteam(pid) and using_anqi == 0 and WAR.BJ == 1 then
			local cri_factor = 1.5 + 0.1 * JY.Base["��������"]
			KungfuString("������"..cri_factor, CC.ScreenW -230 +i*2, CC.ScreenH / 3 - 50 - hb -i*2, C_RED, CC.FontBig+i*2, CC.FontName, 0)
  		end
		
		if i == 1 and WAR.Person[WAR.CurID]["��Ч����"] ~= -1 then
			local theeft = WAR.Person[WAR.CurID]["��Ч����"]
			local sf = 0
			for ii = 0, theeft - 1 do
				sf = sf + CC.Effect[ii]
			end
			
			for ii = 1, CC.Effect[theeft] do
				lib.GetKey()
				
				Cat('ʵʱ��Ч����')	
				WarDrawMap(6, pic * 2, mytype,  (sf+ii)*2, nil, 3, nil, nil)
				--lib.PicLoadCache(3, (sf+ii) * 2, CC.ScreenW/2 , CC.ScreenH/2  - hb, 2, 192, nil, 0, 0)	
				if WAR.Person[WAR.CurID]["��Ч����0"] ~= nil then
					KungfuString(WAR.Person[WAR.CurID]["��Ч����0"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_ORANGE, CC.FontSmall5, CC.FontName, 4)
				end
				if WAR.Person[WAR.CurID]["��Ч����1"] ~= nil then
					KungfuString(WAR.Person[WAR.CurID]["��Ч����1"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_RED, CC.FontSmall5, CC.FontName, 3)
				end
				if WAR.Person[WAR.CurID]["��Ч����2"] ~= nil then
					KungfuString(WAR.Person[WAR.CurID]["��Ч����2"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_GOLD, CC.FontSmall5, CC.FontName, 2)
				end
				if WAR.Person[WAR.CurID]["��Ч����3"] ~= nil then
					KungfuString(WAR.Person[WAR.CurID]["��Ч����3"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_WHITE, CC.FontSmall5, CC.FontName, 1)
				end
				ShowScreen()
				lib.Delay(CC.BattleDelay)
			  
			end
			WAR.Person[WAR.CurID]["��Ч����"] = -1
		else
			if WAR.Person[WAR.CurID]["��Ч����0"] ~= nil or WAR.Person[WAR.CurID]["��Ч����1"] ~= nil or WAR.Person[WAR.CurID]["��Ч����2"] ~= nil or WAR.Person[WAR.CurID]["��Ч����3"] ~= nil then
				Cat('ʵʱ��Ч����')	
				WarDrawMap(4, pic * 2, mytype, -1)
				KungfuString(WAR.Person[WAR.CurID]["��Ч����0"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_ORANGE, CC.FontSmall5, CC.FontName, 4)
				KungfuString(WAR.Person[WAR.CurID]["��Ч����1"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_RED, CC.FontSmall5, CC.FontName, 3)
				KungfuString(WAR.Person[WAR.CurID]["��Ч����2"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_GOLD, CC.FontSmall5, CC.FontName, 2)
				KungfuString(WAR.Person[WAR.CurID]["��Ч����3"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_WHITE, CC.FontSmall5, CC.FontName, 1)
			end
		end
    else
		
		for k = 0,WAR.PersonNum-1 do
			local sx,sy = WAR.Person[k]['����X'],WAR.Person[k]['����Y']
			if WAR.Person[k]['����'] == false then
				if WAR.Person[k]['����'] == true then

					if GetWarMap(sx,sy,4) <= 10 then 
						SetWarMap(sx,sy,4,11)
					else 
						SetWarMap(sx,sy,4,GetWarMap(sx,sy,4)+1) 
					end
				end
			end		
		end
		
		--���ﶯ������
		if i <= oldframe-1 then
		   starteft = starteft + 1
		else   
		   starteft = -1
		end  
      
		if WAR.ZTHSB == 1 then
			lib.SetWarMap(WAR.Person[WAR.ZT_id]["����X"], WAR.Person[WAR.ZT_id]["����Y"], 5, -1)
		end
		Cat('ʵʱ��Ч����')
        WarDrawMap(4, pic * 2, mytype, (starteft) * 2, nil, 3, ex, ey)
		
		--��������컯��
		if WAR.ZTHSB == 1 then
			local dx = WAR.ZT_X - x0
			local dy = WAR.ZT_Y - y0
			local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
			local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
			lib.PicLoadCache(0, 3862*2, rx+i*3, ry+i*3, 2, 200-i*5)
			lib.PicLoadCache(0, 3863*2, rx-i*3, ry-i*3, 2, 200-i*5)
			lib.PicLoadCache(0, 3861*2, rx+i*3, ry-i*3, 2, 200-i*5)
			lib.PicLoadCache(0, 3864*2, rx-i*3, ry+i*3, 2, 200-i*5)
		end

		oldeft = starteft
      
		if WAR.MissPd == 0 then
			if oldframe < framenum then 
				if i == oldframe-1 then
					break
				end 
			else 
				if i == framenum-1 then
					break
				end
			end
		end
    end
	
	ShowScreen()
	lib.Delay(CC.BattleDelay);
	lib.GetKey();
  end

    WAR.Person[WAR.CurID]['��Ч����0'] = nil;
    WAR.Person[WAR.CurID]['��Ч����1'] = nil;
    WAR.Person[WAR.CurID]['��Ч����2'] = nil;
    WAR.Person[WAR.CurID]['��Ч����3'] = nil;
	WAR.Person[WAR.CurID]['��Ч����4'] = nil;
    WAR.Person[WAR.CurID]['��Ч����'] = -1;
	
  --lib.SetClip(0, 0, 0, 0)
	WAR.Person[WAR.CurID]["��ͼ����"] = 0
	WAR.Person[WAR.CurID]["��ͼ"] = WarCalPersonPic(WAR.CurID)
	WAR.MissPd = 0
	WarSetPerson()
	Cat('ʵʱ��Ч����')
	WarDrawMap(0)
	ShowScreen()
	lib.Delay(CC.BattleDelay)
	local yc = math.ceil(200/CC.BattleDelay)
	for j = 1,yc do
		Cat('ʵʱ��Ч����')
		WarDrawMap(2)
		ShowScreen()
		lib.Delay(CC.BattleDelay)
	end
  --�޾Ʋ��������е������ð�ɫ��ʾ
  --WarSetPerson()
  --WarDrawMap(0)
  --ShowScreen()
  --lib.Delay(200)
  --WarDrawMap(2)
  --ShowScreen()
  --lib.Delay(200)
 -- WarDrawMap(0)
  --ShowScreen()
  
  end

  --���㹥��������
  local HitXY = {}
  local HitXYNum = 0
  local hnum = 13;		--HitXY�ĳ��ȸ���
  for i = 0, WAR.PersonNum - 1 do
    local x1 = WAR.Person[i]["����X"]
    local y1 = WAR.Person[i]["����Y"]
	--����Ч���е�Ҳ��ʾ
    if WAR.Person[i]["����"] == false and (GetWarMap(x1, y1, 4) > 1 or WAR.TXXS[WAR.Person[i]["������"]] == 1) then
		local dx = 0
		if GetWarMap(x1, y1, 4) > 1 then
			dx = 1
		end
      SetWarMap(x1, y1, 4, 1)
      --local n = WAR.Person[i]["����"]
      local hp = WAR.Person[i]["��������"];
      local mp = WAR.Person[i]["��������"];
      local tl = WAR.Person[i]["��������"];
      local ed = WAR.Person[i]["�ж�����"];
      local dd = WAR.Person[i]["�ⶾ����"];
      local ns = WAR.Person[i]["���˵���"];
      
      HitXY[HitXYNum] = {x1, y1, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil};		--x, y, ����, ����, ����, ��Ѩ, ��Ѫ, �ж�, �ⶾ, ���ˣ����⣬����
	  
		if hp ~= nil and (dx == 1 or hp ~= 0)  then
		 
			if hp == 0 then			--��ʾ�ܵ�������
				--if WAR.Miss[WAR.Person[i]["������"]] ~= nil  then
				HitXY[HitXYNum][3] = "miss"
				--end
			elseif hp > 0 then
				HitXY[HitXYNum][3] = "+"..hp;
			else
				HitXY[HitXYNum][3] = hp;
			end
	    end

    
      if mp ~= nil then			--��ʾ�����仯
      	if mp > 0 then
      		HitXY[HitXYNum][5] = "����+"..mp;
      	elseif mp ==  0 then
      		HitXY[HitXYNum][5] = nil;			--�仯Ϊ0ʱ����ʾ
      	else
      		HitXY[HitXYNum][5] = "����"..mp;
      	end
      end
      
      if tl ~= nil then			--��ʾ�����仯
      	if tl > 0 then
      		HitXY[HitXYNum][6] = "����+"..tl;
      	elseif tl == 0 then
      		HitXY[HitXYNum][6] = nil;
      	else
      		HitXY[HitXYNum][6] = "����"..tl;
      	end
      end
      
      if WAR.FXXS[WAR.Person[i]["������"]] ~= nil and WAR.FXXS[WAR.Person[i]["������"]] == 1 then			--��ʾ�Ƿ��Ѩ
       	HitXY[HitXYNum][7] = "��Ѩ "..WAR.FXDS[WAR.Person[i]["������"]];
       	WAR.FXXS[WAR.Person[i]["������"]] = 0
      end
      
      if WAR.LXXS[WAR.Person[i]["������"]] ~=nil and WAR.LXXS[WAR.Person[i]["������"]] == 1 then		--��ʾ�Ƿ���Ѫ
      	HitXY[HitXYNum][8] = "��Ѫ "..WAR.LXZT[WAR.Person[i]["������"]];
        WAR.LXXS[WAR.Person[i]["������"]] = 0
      end
         
      if ed ~= nil then				--��ʾ�ж�
      	if ed == 0 then
      		HitXY[HitXYNum][9] = nil;
      	else
      		HitXY[HitXYNum][9] = "�ж���"..ed;
      	end
      end
      
      if dd ~= nil then			--��ʾ�ⶾ
      	if dd  == 0 then
      		HitXY[HitXYNum][4] = nil;
      	else
      		HitXY[HitXYNum][4] = "�ж���"..dd;
      	end
      end
      
      if ns ~= nil then		--��ʾ����
      	if ns == 0 then
      		HitXY[HitXYNum][10] = nil;
      	elseif ns > 0 then
      		HitXY[HitXYNum][10] = "���ˡ�"..ns;
      	else
      		HitXY[HitXYNum][10] = "���ˡ�"..ns;
      	end
      end
	  
		if WAR.BFXS[WAR.Person[i]["������"]] == 1 then		--��ʾ�Ƿ񱻱���
			HitXY[HitXYNum][11] = "���� "..JY.Person[WAR.Person[i]["������"]]["����̶�"];
			WAR.BFXS[WAR.Person[i]["������"]] = 0
		end
		
		if WAR.ZSXS[WAR.Person[i]["������"]] == 1 then		--��ʾ�Ƿ�����
			HitXY[HitXYNum][12] = "���� "..JY.Person[WAR.Person[i]["������"]]["���ճ̶�"];
			WAR.ZSXS[WAR.Person[i]["������"]] = 0
		end
		
		HitXYNum = HitXYNum + 1
    end
    
		--͵��������ת����͵
		if WAR.TD > -1 then
			if WAR.TD == 118 then
				say("����Ҫ����Ľ�ݸ�����͵�������ߺߣ��±��Ӱɣ�", 51,0)
			else
				instruct_2(WAR.TD, WAR.TDnum)
				Cls()
			end
			WAR.TD = -1
		end
	end
  
	local minx = 0;
	local maxx = CC.ScreenW;
	local miny = 0;
	local maxy = CC.ScreenH;
  
	--local sssid = lib.SaveSur(minx, miny, maxx, maxy)
	--������Ч������ʾ
	local txsx = 0
	local txwz = 0
	local mz = false
	--������󶯻�֡��
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["����"] == false then
			local theeft = WAR.Person[i]["��Ч����"]
			if theeft ~= -1 then
				if txsx < CC.Effect[theeft] then 
					txsx = CC.Effect[theeft]
				end
			end
			if theeft == -1 and (WAR.Person[i]["��Ч����0"] ~= nil or WAR.Person[i]["��Ч����1"] ~= nil or WAR.Person[i]["��Ч����2"] ~= nil or WAR.Person[i]["��Ч����3"] ~= nil or WAR.Person[i]["��Ч����4"] ~= nil) then	
				txwz = 1
			end
			mz = true
		end	 
	end
	local bj = {-6,6,-5,5,-4,4,-3,3}
	
	--��ʾ��Ч����
	--û����Ч�̶�10��ѭ��
	if txsx == 0 and (txwz == 1 or (WAR.BJ == 1 and CC.Bj == 1)) then 
		txsx = 10 
	end	


	local zt_count = 0
	for ii = 1, txsx do
		if JY.Restart == 1 then
			break
		end
		local yanshi = false
		local yanshi2 = false		--�޶���ʱ���ӳ�

		local _,ys = math.modf(ii/2)
		if ys == 0 then
			zt_count = zt_count + 1
		end
		
        for i = 0, WAR.PersonNum - 1 do
	        if WAR.Person[i]["����"] == false then
				local theeft = WAR.Person[i]["��Ч����"]
				local ix,iy = WAR.Person[i]["����X"],WAR.Person[i]["����Y"]  
				if theeft ~= -1 and ii < CC.Effect[theeft] then
					
					starteft = ii
					for i = 0, WAR.Person[i]["��Ч����"] - 1 do
						starteft = starteft + CC.Effect[i]
					end
					SetWarMap(ix,iy,11,(starteft+1)*2)
				elseif i ~= WAR.ZT_id and WAR.ZTHSB == 1 then	
					SetWarMap(ix,iy,11,0)
				else 
					SetWarMap(ix,iy,11,0)
				end  
	        end 
        end
		
		Cat('ʵʱ��Ч����')
		

	    if (WAR.BJ == 1 and CC.Bj == 1) or WAR.PD["�����"][pid] == 1 then

			if ii < 9 then
				WarDrawMap(7, 0, 0, nil, nil, 3,nil,nil,bj[ii])
			else
				WarDrawMap(7, 0, 0, nil, nil, 3)
			end
		else   
			WarDrawMap(7, 0, 0, nil, nil, 3)
		end
		
		
		for i = 0, WAR.PersonNum - 1 do
			lib.GetKey()
			if WAR.Person[i]["����"] == false then
				local theeft = WAR.Person[i]["��Ч����"]
				--��������컯��
				if i ~= WAR.ZT_id and WAR.ZTHSB == 1 then
                    local zid = JY.Person[WAR.Person[WAR.ZT_id]["������"]]['ͷ�����']
					local dx = WAR.Person[i]["����X"] - x0
					local dy = WAR.Person[i]["����Y"] - y0
					local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
					local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
					
					lib.PicLoadCache(101+zid, (0+zt_count)*2, rx-80+ii*4, ry+80-ii*4, 2, 100+ii*5)
					lib.PicLoadCache(101+zid, (11+zt_count)*2, rx-80+ii*4, ry-80+ii*4, 2, 100+ii*5)
					lib.PicLoadCache(101+zid, (22+zt_count)*2, rx+80-ii*4, ry+80-ii*4, 2, 100+ii*5)
					lib.PicLoadCache(101+zid, (33+zt_count)*2, rx+80-ii*4, ry-80+ii*4, 2, 100+ii*5)
					yanshi = true
				elseif theeft ~= -1 and ii < CC.Effect[theeft] then
					local dx = WAR.Person[i]["����X"] - x0
					local dy = WAR.Person[i]["����Y"] - y0
					local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
					local ry = CC.YScale * (dx + dy) + CC.ScreenH / 702*265
					local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)
					
					local py = 0

					ry = ry - hb
					starteft = ii
					for i = 0, WAR.Person[i]["��Ч����"] - 1 do
						starteft = starteft + CC.Effect[i]
					end

					--lib.PicLoadCache(3, (starteft) * 2, rx, ry + py, 2, 192, nil, 0, 0)
	
					--�޾Ʋ�������Ч����һ�����������������ʾ�ķ�ʽ
					--if ii < TPXS[i] * TP and (TPXS[i] - 1) * TP < ii then	
						KungfuString(WAR.Person[i]["��Ч����3"], rx, ry, C_WHITE, CC.FontSmall5, CC.FontName, 1)
						KungfuString(WAR.Person[i]["��Ч����2"], rx, ry, C_GOLD, CC.FontSmall5, CC.FontName, 2)
						KungfuString(WAR.Person[i]["��Ч����1"], rx, ry, C_RED, CC.FontSmall5, CC.FontName, 3)
						KungfuString(WAR.Person[i]["��Ч����0"], rx, ry, C_ORANGE, CC.FontSmall5, CC.FontName, 4)
						yanshi = true
					--end
				else
					--�����壺 �����޶���ʱ����ʾ���ֵ�BUG
					if theeft == -1 and (WAR.Person[i]["��Ч����0"] ~= nil or WAR.Person[i]["��Ч����1"] ~= nil or WAR.Person[i]["��Ч����2"] ~= nil or WAR.Person[i]["��Ч����3"] ~= nil or WAR.Person[i]["��Ч����4"] ~= nil) then	
						local dx = WAR.Person[i]["����X"] - x0
						local dy = WAR.Person[i]["����Y"] - y0
						local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
						local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
						local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)

						ry = ry - hb
						
						KungfuString(WAR.Person[i]["��Ч����3"], rx, ry, C_WHITE, CC.FontSmall5, CC.FontName, 1)
						KungfuString(WAR.Person[i]["��Ч����2"], rx, ry, C_GOLD, CC.FontSmall5, CC.FontName, 2)
						KungfuString(WAR.Person[i]["��Ч����1"], rx, ry, C_RED, CC.FontSmall5, CC.FontName, 3)
						KungfuString(WAR.Person[i]["��Ч����0"], rx, ry, C_ORANGE, CC.FontSmall5, CC.FontName, 4)
						yanshi2 = true
					end
				end
			end
		end
		ShowScreen()
		lib.Delay(CC.BattleDelay)
	end
	--lib.FreeSur(sssid)
	--Cls()	--��ʾ����ǰ��ն�����Ӱ
	
	--��������컯��
	if WAR.ZTHSB == 1 then
		lib.SetWarMap(WAR.Person[WAR.ZT_id]["����X"], WAR.Person[WAR.ZT_id]["����Y"], 5, WAR.Person[WAR.ZT_id]["��ͼ"])
	end
  
	--�޾Ʋ���������ʱ�ĵ�Ѫ��״̬��ʾ
	if HitXYNum > 0 then
		local clips = {}
		for i = 0, HitXYNum - 1 do
			local dx = HitXY[i][1] - x0
			local dy = HitXY[i][2] - y0
			local hb = GetS(JY.SubScene, HitXY[i][1], HitXY[i][2], 4)		--����
		  
			local ll = 4;
			for y=3, hnum do
				if HitXY[i][y] ~= nil then
					ll = string.len(HitXY[i][y]);
					break;
				end
			end
			local w = ll * CC.DefaultFont / 2 + 1
			clips[i] = {x1 = CC.XScale * (dx - dy) + CC.ScreenW / 2, y1 = CC.YScale * (dx + dy) + CC.ScreenH / 2 - hb, x2 = CC.XScale * (dx - dy) + CC.ScreenW / 2 + w, y2 = CC.YScale * (dx + dy) + CC.ScreenH / 2 + CC.DefaultFont + 1}
		end
		
		local clip = clips[0]
		for i = 1, HitXYNum - 1 do
			clip = MergeRect(clip, clips[i])
		end
		
		local area = (clip.x2 - clip.x1) * (clip.y2 - clip.y1)		--�滭�ķ�Χ
		--local surid = lib.SaveSur(minx, miny, maxx, maxy)		--�滭���
		
		Cat('ʵʱ��Ч����')
	    local xs = false
		--��ʾ����
		--�޾Ʋ�����һ����ʾ����״̬
		for y = 3, hnum-2, 2 do
			if JY.Restart == 1 then
				break
			end
			local flag = false;
			for i = 5, 15 do
				local tstart = lib.GetTime()
				local y_off = i * 2 + CC.DefaultFont + CC.RowPixel
				local pd = 0

				for j = 0, HitXYNum - 1 do
					if pd == 0 then
						WarDrawMap(0)
						pd = 1
					end
					if HitXY[j][y] ~= nil or HitXY[j][y+1] ~= nil then	

						local c = y - 1;
						--�޾Ʋ������������ַ�������λ�ж��Ƿ�Ϊ��Ѫ
						if y == 3 and HitXY[j][y] ~= nil and string.sub(HitXY[j][y],1,1) == "-" then
							if CONFIG.HPDisplay == 1 then
								HP_Display_When_Hit(i) --�޾Ʋ�����ʵʱ��Ѫ
							end
							DrawString(clips[j].x1 - string.len(HitXY[j][y])*CC.DefaultFont/4, clips[j].y1 - y_off, HitXY[j][y], Color_Hurt1, CC.DefaultFont)
						else
							--�޾Ʋ�����˫����ʾ��ʱ����д��
							local spacing = 0
							if HitXY[j][y] ~= nil then
								DrawString(clips[j].x1 - string.len(HitXY[j][y])*CC.DefaultFont/4, clips[j].y1 - y_off, HitXY[j][y], WAR.L_EffectColor[c], CC.DefaultFont)
								spacing = CC.DefaultFont
							end
							if HitXY[j][y+1] ~= nil then
								DrawString(clips[j].x1 - string.len(HitXY[j][y+1])*CC.DefaultFont/4, clips[j].y1 + spacing - y_off, HitXY[j][y+1], WAR.L_EffectColor[c+1], CC.DefaultFont)
							end
						end
							
						flag = true;
					end
				end

				if flag then
					Cat('ʵʱ��Ч����')
				    ShowScreen()
					lib.Delay(CC.BattleDelay)
				end
			end
		end
	end
	
	--������ָ�Ѫ��
	WAR.ShowHP = 1

	--�������
	for i = 0, HitXYNum - 1 do
		local id = GetWarMap(HitXY[i][1], HitXY[i][2], 2);
		WAR.Person[id]["��������"] = nil;
		WAR.Person[id]["��������"] = nil;
		WAR.Person[id]["��������"] = nil;
		WAR.Person[id]["�ж�����"] = nil;
		WAR.Person[id]["�ⶾ����"] = nil;
		WAR.Person[id]["���˵���"] = nil;
		WAR.Person[id]["Life_Before_Hit"] = 0;
	end
  
	--�����Ч����
	for i = 0, WAR.PersonNum - 1 do
        local id = WAR.Person[i]["������"]
		WAR.Person[i]["��Ч����"] = -1
		WAR.Person[i]["��Ч����0"] = nil
		WAR.Person[i]["��Ч����1"] = nil
		WAR.Person[i]["��Ч����2"] = nil
		WAR.Person[i]["��Ч����3"] = nil
		WAR.Person[i]["��Ч����4"] = nil
		WAR.Person[i]["����"] = false;
        WAR.Miss[id] = nil
	end
	lib.SetClip(0, 0, 0, 0)
	Cat('ʵʱ��Ч����')
	WarDrawMap(0)
	ShowScreen()
	lib.Delay(CC.BattleDelay)
	CleanWarMap(11,0)
end


---ִ��ҽ�ƣ��ⶾ�ö��������Ӻ������Զ�ҽ��Ҳ�ɵ���
function War_ExecuteMenu_Sub(x1, y1, flag, thingid)
	local pid = WAR.Person[WAR.CurID]["������"]
	local x0 = WAR.Person[WAR.CurID]["����X"]
	local y0 = WAR.Person[WAR.CurID]["����Y"]
	CleanWarMap(4, 0)
	WAR.ShowHP = 0
	WAR.Person[WAR.CurID]["�˷���"] = War_Direct(x0, y0, x1, y1)
	SetWarMap(x1, y1, 4, 1)
	local emeny = GetWarMap(x1, y1, 2)
	if emeny >= 0 then
		if flag == 1 and WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[emeny]["�ҷ�"] then
			Cat('����̫��2')
			if myzd(emeny) == false then
				WAR.Person[emeny]["�ж�����"] = War_PoisonHurt(pid, WAR.Person[emeny]["������"])
			end
			SetWarMap(x1, y1, 4, 5)
			WAR.Effect = 5
		elseif flag == 2 and WAR.Person[WAR.CurID]["�ҷ�"] == WAR.Person[emeny]["�ҷ�"] then
			WAR.Person[emeny]["�ⶾ����"] = ExecDecPoison(pid, WAR.Person[emeny]["������"])
			SetWarMap(x1, y1, 4, 6)
			WAR.Effect = 6
		elseif flag == 3 then
			--ҽ�������ж�
			if WAR.Person[WAR.CurID]["������"] == 0 and JY.Base["��׼"] == 8 then
			  
			elseif WAR.Person[WAR.CurID]["�ҷ�"] == WAR.Person[emeny]["�ҷ�"] then
			  WAR.Person[emeny]["��������"] = ExecDoctor(pid, WAR.Person[emeny]["������"])
			  SetWarMap(x1, y1, 4, 4)
			  WAR.Effect = 4
			end
		--����
		elseif flag == 4 and WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[emeny]["�ҷ�"] then
			Cat('����̫��2')
			--�������߷�������
			if  WAR.Person[emeny]["������"] == 27 and match_ID(WAR.Person[WAR.CurID]["������"],498) == false then
				CleanWarMap(4, 0)
				local orid = WAR.CurID
				WAR.CurID = emeny
				
				WAR.Person[WAR.CurID]["�˷���"] = War_Direct(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], x0, y0)
				
				Cls()
				local KHZZ = {"��֪��"..JY.Person[0]["���2"],"��Ȼ�����Ū��","���ҵĿ�������"}
				
				for n = 1, #KHZZ + 25 do
					local i = n 
					if i > #KHZZ then 
						i = #KHZZ
					end
					lib.GetKey()
					Cat('ʵʱ��Ч����')
					Cls()
					DrawString(-1, -1, KHZZ[i], C_GOLD, CC.Fontsmall)
					ShowScreen()
					lib.Delay(CC.BattleDelay)
				end
		
				SetWarMap(x0, y0, 4, 1)
				
				WAR.Person[orid]["��������"] = (WAR.Person[orid]["��������"] or 0) + AddPersonAttrib(WAR.Person[orid]["������"], "����", -300)
				if myzd(orid) == false then
					WAR.Person[orid]["�ж�����"] = (WAR.Person[orid]["�ж�����"] or 0) + AddPersonAttrib(WAR.Person[orid]["������"], "�ж��̶�", 100)
				end
				WAR.TXXS[WAR.Person[orid]["������"]] = 1
				
				WAR.KHSZ = 1
				
				War_ShowFight(WAR.Person[WAR.CurID]["������"], 0, -1, 0, x0, y0, 35)
				
				WAR.KHSZ = 0
				
				WAR.CurID = orid
				return 1
			end	

		
			--����������߰���
			if match_ID(WAR.Person[emeny]["������"],592) and  match_ID(WAR.Person[WAR.CurID]["������"],498)==false  then
				local orid = WAR.CurID
				WAR.CurID = emeny
				Cls()
				CurIDTXDH(WAR.CurID, 137,1, "�ϵ��Ȼ�������ʽ", C_GOLD)
				WAR.CurID = orid
				return 1
			end	
			--���߰���
			if match_ID(WAR.Person[emeny]["������"],9990) and  match_ID(WAR.Person[WAR.CurID]["������"],498)==false  then
				local orid = WAR.CurID
				WAR.CurID = emeny
				Cls()
				WAR.CurID = orid
				return 1
			end	
			if not match_ID(pid, 83) then
				--��������˺�����
				WAR.AQBS = math.random(3)
				--Ԭ��־�ý���׶�ض�����
				if (match_ID(pid, 54) and thingid == 30) or match_ID(pid, 498) then
					WAR.AQBS = 3
				end
				--��ѩ���ý���׶�ض�����
				if match_ID(pid, 639) and thingid == 30 then
					WAR.AQBS = math.random(5,7)
				end				
				--��Ѱ��������������
				if  WAR.XLFD[pid] ~= nil  then
                    WAR.AQBS = math.random(5,8)
				end
				if  WAR.XLFD[pid] ~= nil  and JLSD(35, 55, pid) and JY.Person[0]["�������"] > 0  then
                    WAR.AQBS = math.random(10,12)	
				end
				
				WAR.Person[emeny]["��������"] = War_AnqiHurt(pid, WAR.Person[emeny]["������"], thingid, emeny)
				SetWarMap(x1, y1, 4, 2)
				WAR.Effect = 2
			end
            if match_ID(pid, 721) then
                WAR.AQBS = 1
            end
		end
	end
			
	--����ҽ������ҽ��
	if flag == 3 and pid == 0 and JY.Base["��׼"] == 8 then
		for ex = x1 - 3, x1 + 3 do
			for ey = y1 - 3, y1 + 3 do
				SetWarMap(ex, ey, 4, 1)
				if GetWarMap(ex, ey, 2) ~= nil and GetWarMap(ex, ey, 2) > -1 then
					local ep = GetWarMap(ex, ey, 2)
					if WAR.Person[WAR.CurID]["�ҷ�"] == WAR.Person[ep]["�ҷ�"] then
						WAR.Person[ep]["��������"] = ExecDoctor(pid, WAR.Person[ep]["������"])
						SetWarMap(ex, ey, 4, 4)
						WAR.Effect = 4
					end
				end        
			end
		end
	end
	--���Ƕ��������϶������Ը��Լ��϶�
	if flag == 1 and pid == 0 and JY.Base["��׼"] == 9 then
		for ex = x1 - 3, x1 + 3 do
			for ey = y1 - 3, y1 + 3 do
				SetWarMap(ex, ey, 4, 1)
				if GetWarMap(ex, ey, 2) ~= nil and GetWarMap(ex, ey, 2) > -1 then
					local ep = GetWarMap(ex, ey, 2)
					if (WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[ep]["�ҷ�"]) or ep == WAR.CurID then
						if myzd(ep) == false then
							WAR.Person[ep]["�ж�����"] = War_PoisonHurt(pid, WAR.Person[ep]["������"])
						end
						SetWarMap(ex, ey, 4, 5)
						WAR.Effect = 5
					end
				end        
			end
		end
	end

	--������ʹ�ð���Ϊ7*7����
	if flag == 4 and match_ID(pid, 83) then
		--��������˺�����
		WAR.AQBS = math.random(3)
		for ex = x1 - 3, x1 + 3 do
			for ey = y1 - 3, y1 + 3 do
				SetWarMap(ex, ey, 4, 1)
				if GetWarMap(ex, ey, 2) ~= nil and GetWarMap(ex, ey, 2) > -1 then
					local ep = GetWarMap(ex, ey, 2)
					if WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[ep]["�ҷ�"] then
						WAR.Person[ep]["��������"] = War_AnqiHurt(pid, WAR.Person[ep]["������"], thingid, ep)
						SetWarMap(ex, ey, 4, 4)
						WAR.Effect = 2
					end
				end
			end
		end
	end
	--��Ѱ�� С��ɵ�ʹ�ð���Ϊ3*3����
	if flag == 4 and match_ID(pid,498) and  JY.Base["��������"] > 5 then
		for ex = x1 - 3, x1 + 3 do
			for ey = y1 - 3, y1 + 3 do
				SetWarMap(ex, ey, 4, 1)
				if GetWarMap(ex, ey, 2) ~= nil and GetWarMap(ex, ey, 2) > -1 then
					local ep = GetWarMap(ex, ey, 2)
					if WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[ep]["�ҷ�"] then
						WAR.Person[ep]["��������"] = War_AnqiHurt(pid, WAR.Person[ep]["������"], thingid, ep)
						SetWarMap(ex, ey, 4, 4)
						WAR.Effect = 2
					end
				end
			end
		end
	end	


	WAR.EffectXY = {}
	WAR.EffectXY[1] = {x1, y1}
	WAR.EffectXY[2] = {x1, y1}
	if flag == 1 then
		War_ShowFight(pid, 0, 0, 0, x1, y1, 30)
	elseif flag == 2 then
		War_ShowFight(pid, 0, 0, 0, x1, y1, 36)
	elseif flag == 3 then
		War_ShowFight(pid, 0, 0, 0, x1, y1, 0)
	elseif flag == 4 and (emeny >= 0 or match_ID(pid, 83)) then
		War_ShowFight(pid, 0, -1, 0, x1, y1, thingid)
	end

	
		--��������˺�����	
	--for i = 0, WAR.PersonNum - 1 do
		--WAR.Person[i]["����"] = 0
	--end
	if flag == 4 then
		if emeny >= 0 or match_ID(pid, 83) then
			instruct_32(thingid, -1)
			--�żһԵ������ָ
			if JY.Person[pid]["����"] == 304 then
				local cd = 40
				if JY.Thing[304]["װ���ȼ�"] >=5 then
					cd = 20
				elseif JY.Thing[304]["װ���ȼ�"] >=3 then
					cd = 30
				end
				WAR.YSJZ = cd
			end
			return 1
		else
			return 0
		end
	else
		WAR.Person[WAR.CurID]["����"] = WAR.Person[WAR.CurID]["����"] + 1
		AddPersonAttrib(pid, "����", -2)
	end
  
	if inteam(pid) then
		AddPersonAttrib(pid, "����", -4)
	end
	return 1
end


--�޾Ʋ���������󣬻滭��̬���������ж�
function DrawTimeBar2()
	local x1,x2,y = CC.ScreenW * 1 / 2 - 34, CC.ScreenW * 19 / 20 - 2, CC.ScreenH/10 + 29
	local draw = false
	
	--�������ǹ̶��ģ�ֻ��Ҫ����һ�ξͿ�����
	--�޾Ʋ���������ҲҪ�ж��Ƿ�����Ҫdraw��������Ҫ�򲻼���
	local drawframe = false
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["����"] == false then
			if WAR.Person[i].TimeAdd ~= 0 then
				drawframe =  true
				break
			end
		end
	end
	if drawframe == true then
		DrawString(x2 + 10-410, y - 60-25, "ʱ��", C_WHITE, CC.DefaultFont*0.8)	
        lib.LoadPicture("./data/xt/23.png",0,0,1)	
	end
	
	--local surid = lib.SaveSur(x1 - (10 + (x2 - x1) / 2), 0, x2 + 10 + 20 + 30, y * 2 + 18 + 25)
	local pd = false 
	while true do
		if JY.Restart == 1 then
			break
		end
		lib.GetKey()
		draw = false

		for i = 0, WAR.PersonNum - 1 do
			lib.GetKey()
			local pid = WAR.Person[i]["������"];
			--�����ж������Ƿ����
			if WAR.Person[i]["����"] == false then
                if Curr_NG(pid, 227) and WAR.Defup[pid] ~= nil and WAR.Defup[pid] > 0 then 
                    if WAR.Person[i].TimeAdd < 0 then 
                        WAR.Person[i].TimeAdd = 0
                    end
                end
				--����TimeAddС��0������λ��Ҫ���٣���ֵΪ��������
				if WAR.Person[i].TimeAdd < 0 then
					draw = true
					--������20Ϊ��λѭ�����ӣ����ӵ�����0ʱ���ж������ٳ�������ֹͣ���ټ���λ��
					WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 20
					if WAR.Person[i].TimeAdd > 0 then
						WAR.Person[i].TimeAdd = 0;
					end					
					--�������ļ���λ��û�дﵽ-500�������20����-500����
					if WAR.Person[i].Time > -500 then
						--��������٤���򲻻����300
						--��Ѱ��
						if Curr_NG(pid, 169)  or match_ID(pid,498) then
							if WAR.Person[i].Time > 300 then
								WAR.Person[i].Time = WAR.Person[i].Time - 20
								if WAR.Person[i].Time <= 300 then
									WAR.Person[i].Time = 300
									WAR.Person[i].TimeAdd = 0
								end
							end
						--�����٤��������0 or ShuangJianHB(pid)
						elseif PersonKF(pid, 169) or match_ID(pid,581)  then
							if WAR.Person[i].Time > 0 then
								WAR.Person[i].Time = WAR.Person[i].Time - 20
								if WAR.Person[i].Time <= 0 then
									WAR.Person[i].Time = 0
									WAR.Person[i].TimeAdd = 0
								end
							end
						--˫���ϱ�ɱ���������-100  
						elseif ShuangJianHB(pid)  then
							if WAR.Person[i].Time > 0 then
								WAR.Person[i].Time = WAR.Person[i].Time - 20
								if WAR.Person[i].Time <= -100 then
									WAR.Person[i].Time = -100
									WAR.Person[i].TimeAdd = 0
								end
							end	
						else
							WAR.Person[i].Time = WAR.Person[i].Time - 20
						end
					--�������ļ���λ���Ѿ��ﵽ-500������λ�ò��ټ��٣�����ת��Ϊ����
					else
						for k = 0,-WAR.Person[i].TimeAdd,20 do
							if JY.Person[pid]["���˳̶�"] < 100 then
								AddPersonAttrib(pid, "���˳̶�", math.random(3))
							else 
								WAR.Person[i].TimeAdd = 0
								break
							end
						end	
						WAR.Person[i].TimeAdd = 0
					end
					if WAR.Person[i].Time <= -500 and PersonKF(pid, 100) then	--�������칦�󣬵�������ɱ��-500������ֱ����0
						JY.Person[pid]["���˳̶�"] = 0;	
					end						
				--����0������λ��Ҫ���ӣ�
				elseif WAR.Person[i].TimeAdd > 0 then
					draw = true
					--������20Ϊ��λѭ�����٣����ٵ�����0ʱ���ж������ٳ�������ֹͣ���Ӽ���λ��
					WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd - 20
					--����ļ���λ����20Ϊ��λ���ӣ��������λ�ó���995����ǿ�ƶ�Ϊ995
					WAR.Person[i].Time = WAR.Person[i].Time + 20
					if WAR.Person[i].Time > 995 then
						WAR.Person[i].Time = 995;
						WAR.Person[i].TimeAdd = 0
					end
				end
			end
		end
		
		if draw then		 
			Cat('ʵʱ��Ч����')
			Cls()
			DrawTimeBar_sub()
			ShowScreen()
			lib.Delay(CC.BattleDelay)
			pd = true
		else 
			break
		end

	end
	if pd == true then
		local n = math.ceil(400/CC.BattleDelay)
		for i = 1,n do 
			Cat('ʵʱ��Ч����')
			Cls()
			DrawTimeBar_sub()
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end
end

--���Ƽ�����
function DrawTimeBar()
	
	--local x1,x2,y = CC.ScreenW * 1 / 2 - 34, CC.ScreenW * 19 / 20 - 2, CC.ScreenH/10 + 29
	local xunhuan = true
    
	--local xh = 0
    local jqwz = 0
	local atid = -1
	if WAR.ATK['����'] ~= nil then
		atid = WAR.ATK['����']
		WAR.ATK['����'] = nil
		goto label1
	end
    WAR.ZYHB = 0
    
	if #WAR.ATK['����table'] > 0 then
		atid = WAR.ATK['����table'][#WAR.ATK['����table']]
		local id = WAR.Person[atid]['������']
		table.remove(WAR.ATK['����table'],#WAR.ATK['����table'])
		WAR.ATK['����pd'][id] = nil
		if #WAR.ATK['����table'] == 0 then 
			WAR.ATK['����table'] = {}
		end
		goto label1
	end
    
	while xunhuan do
		if JY.Restart == 1 then
			break
		end
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["����"] == false then
				local jqid = WAR.Person[i]["������"]
				local jq = WAR.Person[i].TimeAdd	--���Ｏ���ٶ�
				--�޾Ʋ�����ÿ25������-1������ÿ25���ж�-1�����������NPCһ��
				local ns_factor = math.modf(JY.Person[jqid]["���˳̶�"] / 25)
				local zd_factor = math.modf(JY.Person[jqid]["�ж��̶�"] / 25)
				--�����ж��������Ӽ���
				if jqid == 0 and JY.Base["��׼"] == 9 then
					zd_factor = -(zd_factor*2)
				end
				--����Ҳ����
				local bf_factor = 0;
				if JY.Person[jqid]["����̶�"] >= 50 then
					bf_factor = 6
				elseif JY.Person[jqid]["����̶�"] > 0 then
					bf_factor = 3
				end
				--��̫������ټ��ټ�����һ�����1%
				local HTC_tq = 0
				if WAR.QYZT[jqid] ~= nil then
					HTC_tq = jq * 0.015 * WAR.QYZT[jqid]
				end
                local chzt_jq = 0
				--�ٻ����ټ�����һ�����1%
				if WAR.CHZT[jqid] ~= nil then
					chzt_jq = jq * 0.01 * WAR.CHZT[jqid]
				end
				local hsv_jq = 0
				 --����Ů ���������� һ������1.25%
				if WAR.JFJQ[jqid] ~= nil then
					hsv_jq = jq * (-0.0125) * WAR.JFJQ[jqid]
				end					
				--����ˮ��������״̬Ӱ��
				--һέ�ɽ�
				
				if match_ID(jqid, 118) or  match_ID(jqid, 579) or (match_ID(jqid, 629) and WAR.LQZ[jqid] == 100) or PersonKF(jqid,186) then
				
				else
					jq = jq - ns_factor - zd_factor - bf_factor - HTC_tq - chzt_jq - hsv_jq
				end
				
				if jq < 0 then
					jq = 0
				end
				if WAR.LQZ[jqid] == 100 then
					if Curr_QG(jqid,150) then	--�˹�˲Ϣǧ���ŭ4������
						jq = jq * 4
					else
						jq = jq * 3				--��ŭ3������
					end
				end
				--��˯�ĵ��ˣ��޷�����
				if WAR.CSZT[jqid] == 1 then
					jq = 0
				--������ʤ���л��е��ˣ��޷�����
				elseif WAR.WZSYZ[jqid] ~= nil then
					jq = 0
					WAR.WZSYZ[jqid] = WAR.WZSYZ[jqid] - 1
					if WAR.WZSYZ[jqid] < 1 then
						WAR.WZSYZ[jqid] = nil
					end
				--����ĵ��ˣ��޷�����				
				elseif WAR.LRHF[jqid] ~= nil then
					jq = 0
					WAR.LRHF[jqid] = WAR.LRHF[jqid] - 1
					if WAR.LRHF[jqid] < 1 then
						WAR.LRHF[jqid] = nil
					end
				--���� г֮�����еĵ��ˣ��޷�����				
				elseif WAR.XZD[jqid] ~= nil then
					jq = 0
					WAR.XZD[jqid] = WAR.XZD[jqid] - 1
					if WAR.XZD[jqid] < 1 then
						WAR.XZD[jqid] = nil
					end					
				--û�з�Ѩ������£����Լ���
				elseif WAR.FXDS[jqid] == nil then
				    --
					--ŷ���������
					if match_ID(jqid, 60) and JLSD(0,20,jqid) then
						jq = jq + math.random(30, 60);
					end
                    
					--�����귭����
					if Curr_QG(jqid,224)  and  JLSD(10,math.random(Qg(i)*0.1),jqid)  then						
					    local tq = math.random(50,100)
						WAR.Person[i].Time = WAR.Person[i].Time + jq
					end
			
                    if PersonKF(jqid, 104) and JLSD(0,20,jqid) then 
                        jq = jq + 50
                        if PersonKF(jqid, 107) then 
                            jq = jq + 50
                        end
                    end
                    
					--����������
					if match_ID(jqid, 581) and JLSD(0,20,jqid) then
                        local a = math.random(10, 30);
                        if WAR.LQZ[jqid] == 100 then 
                            a = a*3
                        end
                        jq = jq + a
					end		
			
					if WAR.LSQ[jqid] ~= nil then	--������ȭ���У���������20ʱ��
						if math.random(3) == 1 then
							WAR.Person[i].Time = WAR.Person[i].Time - jq
						else
							WAR.Person[i].Time = WAR.Person[i].Time + jq
						end
						WAR.LSQ[jqid] = WAR.LSQ[jqid] - 1
						if WAR.LSQ[jqid] == 0 then
							WAR.LSQ[jqid] = nil
						end
	                else
					    WAR.Person[i].Time = WAR.Person[i].Time + jq
					end 
                    
					if WAR.Person[i].Time > 1005 then
						WAR.Person[i].Time = 1005
					end
                    
					if WAR.Person[i].Time <  -500 then
						WAR.Person[i].Time = -500
					end
                    
				--����Ѩ�Ļ������Ἧ����ʱ����ٷ�Ѩ
				else
					WAR.FXDS[jqid] = WAR.FXDS[jqid] - 1
			  
					--�׽ ��Ѩ�ظ�+1
					if PersonKF(jqid, 108) or Curr_NG(jqid,184)then
						WAR.FXDS[jqid] = WAR.FXDS[jqid] - 1
					end
					
					--����+��Ů����Ѩ�ظ�+1
					if PersonKF(jqid, 100) and PersonKF(jqid, 154) then
						WAR.FXDS[jqid] = WAR.FXDS[jqid] - 1
					end

					--����5ʱ������Ѩ
					--�������˻������ѧ�������
					if Curr_NG(jqid, 106) and (JY.Person[jqid]["��������"] == 1 or JY.Person[jqid]["��������"] == 3) then
						if WAR.JYFX[jqid] == nil then
							WAR.JYFX[jqid] = 1;
						elseif WAR.JYFX[jqid] < 5 then
							WAR.JYFX[jqid] = WAR.JYFX[jqid] + 1;
						else
							WAR.JYFX[jqid] = nil;
							WAR.FXDS[jqid] = 0;
						end
					end
					
					--��ŭʱ��Ѩ�ٶȼӱ�
					if WAR.LQZ[jqid] == 100 then
						WAR.FXDS[jqid] = WAR.FXDS[jqid] - 1
					end
					if WAR.FXDS[WAR.Person[i]["������"]] < 1 then
						WAR.FXDS[WAR.Person[i]["������"]] = nil
					end
				end  
				
				
				if PersonKF(jqid,199) then
					WAR.WMYS[jqid]=1
                end
				
				--��̩����ʱ״̬
				if match_ID(jqid,151) and WAR.WTL_1[jqid] == nil then
					WAR.WTL_1[jqid] = 100
				end	
				----------------------------------�������������ظ�-----------------------------------
			if  WAR.PD['����'][jqid] ~= nil then	
				--�����񹦻���
				--ѧ��������������ڻ������
				if PersonKF(jqid, 106) and (JY.Person[jqid]["��������"] == 1 or JY.Person[jqid]["��������"] == 3)  then
					--JY.Person[jqid]["����"] = JY.Person[jqid]["����"] + 9
					AddPersonAttrib(jqid,'����',9)
				end

				--�����񹦻�Ѫ
				--ѧ��������������ڻ������
				if PersonKF(jqid, 107)and (JY.Person[jqid]["��������"] == 0  or JY.Person[jqid]["��������"] == 3)then
					--JY.Person[jqid]["����"] = JY.Person[jqid]["����"] + 2
					AddPersonAttrib(jqid,'����',2)
				end	
			
		        --������Ϣ
                if PersonKF(jqid, 184) then
					AddPersonAttrib(jqid,'����',2)
					AddPersonAttrib(jqid,'����',5)
					AddPersonAttrib(jqid,'����',1)
				end
				
		        --�����޼���
                if Curr_NG(jqid, 221) then
					AddPersonAttrib(jqid,'����',2)
					AddPersonAttrib(jqid,'����',5)
				end
				
				--̫�齣���Ѫ
				if PersonKF(jqid, 152) then
					--JY.Person[jqid]["����"] = JY.Person[jqid]["����"] + 2
					AddPersonAttrib(jqid,'����',2)
				end
				
				--��Ϣ���ظ�����
				if PersonKF(jqid, 180) then
					--JY.Person[jqid]["����"] = JY.Person[jqid]["����"] + 5
					AddPersonAttrib(jqid,'����',5)
				end	
				
				--���ϳ�������Ѫ
				if Curr_NG(jqid, 183) then
					--JY.Person[jqid]["����"] = JY.Person[jqid]["����"] + 5
					AddPersonAttrib(jqid,'����',4)
				elseif PersonKF(jqid, 183) then
					AddPersonAttrib(jqid,'����',2)
				end	
				
				--��������Ѫ
				if Curr_NG(jqid, 203) then
					--JY.Person[jqid]["����"] = JY.Person[jqid]["����"] + 5
					AddPersonAttrib(jqid,'����',5)
				elseif PersonKF(jqid, 203) then
					AddPersonAttrib(jqid,'����',2)
				end	
			
				--���������Ѫ
				--�������˻������ѧ�������
				if inteam(jqid) then
					if Curr_NG(jqid, 107) and (JY.Person[jqid]["��������"] == 0 or JY.Person[jqid]["��������"] == 3) then
						--JY.Person[jqid]["����"] = JY.Person[jqid]["����"] + 2
						AddPersonAttrib(jqid,'����',2)
					end
				end	
				
                if Curr_NG(jqid,227) then
                    AddPersonAttrib(jqid,'����',2)
                end
                
				--���칦��Ѫ����  --�𴦻��ظ��ӱ�
				--���������Ѫ����
				if PersonKF(jqid, 100) or  PersonKF(jqid, 177) then
					if match_ID(jqid,68) then 
						AddPersonAttrib(jqid,'����',8)
						AddPersonAttrib(jqid,'����',4)
					else 
						AddPersonAttrib(jqid,'����',4)
						AddPersonAttrib(jqid,'����',2)
					end
				end
				--�׽����
				if PersonKF(jqid, 108) then
					AddPersonAttrib(jqid,'����',6)
				end
				--̫�齣�����
				if PersonKF(jqid, 152) then
					AddPersonAttrib(jqid,'����',4)
				end				

                if WAR.PD['��������'][jqid] ~= nil then 
                    local sm = 2 
                    if JY.Person[jqid]['ʵս'] >= 500 then 
                        sm = 4
                    end
                    AddPersonAttrib(jqid,'����',sm)
                    WAR.PD['��������'][jqid] = WAR.PD['��������'][jqid] - 1
                    if WAR.PD['��������'][jqid] < 1 then 
                        WAR.PD['��������'][jqid] = nil   
                    end
                end
                
                if WAR.PD['�����ܵ�'][jqid] ~= nil then 
                    AddPersonAttrib(jqid,'����',8)
                    WAR.PD['�����ܵ�'][jqid] = WAR.PD['�����ܵ�'][jqid] - 1
                    if WAR.PD['�����ܵ�'][jqid] < 1 then 
                        WAR.PD['�����ܵ�'][jqid] = nil   
                    end
                end
                
				--������ظ�
				if WAR.ZTHF[jqid] ~=nil then
					AddPersonAttrib(jqid,'����',2)
					AddPersonAttrib(jqid,'����',4)			
					JY.Person[jqid]["���˳̶�"] = 0;
				end
				
				--����ҽ����Ѫ�ڣ������ˣ����ж�
				if jqid == 0 and JY.Base["��׼"] == 8 then
					AddPersonAttrib(jqid,'����',math.random(10))
					AddPersonAttrib(jqid,'����',math.random(10))
					AddPersonAttrib(jqid,'�ж��̶�',-math.random(10))
					AddPersonAttrib(jqid,'���˳̶�',-math.random(10))
				end				
				--����ʱ�������ж�
				if jqid == 0 and JY.Base["��׼"] == 9 then
					AddPersonAttrib(jqid,'�ж��̶�',math.random(10))
				end
                ----------------------------------��Ѫ�ظ�-----------------------------------
				--ÿʱ��ظ�1����Ѫ
				if WAR.LXZT[jqid] ~= nil then
					JY.Person[jqid]["����"] = JY.Person[jqid]["����"] - 2 - math.modf(JY.Person[jqid]["���˳̶�"] / 50)
					if JY.Person[jqid]["����"] < 1 then
						JY.Person[jqid]["����"] = 1
					end
					WAR.LXZT[jqid] = WAR.LXZT[jqid] - 1
                
					--����Ǭ�����޺�����ָ���Ѫ
					--��������
					if Curr_NG(jqid, 97) or Curr_NG(jqid, 96) or Curr_NG(jqid, 177) then
						WAR.LXZT[jqid] = WAR.LXZT[jqid] - 1
					end
					if JY.Person[jqid]["����"] == 262 or PersonKF(jqid,204) and WAR.LXZT[jqid] ~= nil then 
						WAR.LXZT[jqid] = WAR.LXZT[jqid] - 2
					end					  
					if WAR.LXZT[jqid] < 1 then
						WAR.LXZT[jqid] = nil
					end
				end
				----------------------------------����ظ�-----------------------------------
                if JY.Person[jqid]["����̶�"] > 0 and JY.Person[jqid]["���ճ̶�"] > 0 then
                    AddPersonAttrib(jqid,'����',-math.random(2,5))
                    AddPersonAttrib(jqid,'����',-math.random(2,5))
                end
                
				--ÿʱ��ظ�1�����
				if JY.Person[jqid]["����̶�"] > 0 then
					--ÿʱ��-5��
					AddPersonAttrib(jqid,'����',-5)
					
					--��ȱ���ÿʱ��-15��
					if JY.Person[jqid]["����̶�"] >= 50 then
						AddPersonAttrib(jqid,'����',-10)
					end
					AddPersonAttrib(jqid,'����̶�',-1)
					
					--���˴�������������ָ�����
					if Curr_NG(jqid, 99) or Curr_NG(jqid, 106) then
						AddPersonAttrib(jqid,'����̶�',-1)
					end				
					
					--�����޼���
					if Curr_NG(jqid, 221) then
						AddPersonAttrib(jqid,'����̶�',-2)
					end
				end
				----------------------------------���ջظ�-----------------------------------
				--ÿʱ��ظ�1������
				if JY.Person[jqid]["���ճ̶�"] > 0 then
					--JY.Person[jqid]["���ճ̶�"] = JY.Person[jqid]["���ճ̶�"] - 1
					AddPersonAttrib(jqid,'���ճ̶�',-1)
					--���˾�������ָ�����
					if Curr_NG(jqid, 107)  and (JY.Person[jqid]["��������"] == 0 or JY.Person[jqid]["��������"] == 3)  then
						AddPersonAttrib(jqid,'���ճ̶�',-1)
					end
					--���ٶ���ָ�����
					if match_ID(jqid, 102) then
						AddPersonAttrib(jqid,'���ճ̶�',-1)
					end
					
					--���ϳ�����
					if PersonKF(jqid, 183) then
						AddPersonAttrib(jqid,'���ճ̶�',-1)
					end		

					--�����޼���
					if Curr_NG(jqid, 221) then
						AddPersonAttrib(jqid,'���ճ̶�',-2)
					end
				end
				----------------------------------���˻ظ�-----------------------------------
                --�޾Ʋ�����ʱ��ظ����˵��趨
                if JY.Person[jqid]["���˳̶�"] > 0 then
                        --3ʱ���1���˵��ж�
                        --��ϼ�����ˣ���������գ����������������ǣ���ڤ��̫�����׽����Ů�ľ����٤�ܳˣ���Ԫ ����,̫�齣�⣬��Ϣ�������ϳ����� ̫����
                        --����ͣ�����
                    if Curr_NG(jqid, 89) or Curr_NG(jqid, 105)or Curr_NG(jqid, 104) or Curr_NG(jqid, 107) or Curr_NG(jqid, 144) or Curr_NG(jqid, 106) 
                        or Curr_NG(jqid, 87) or Curr_NG(jqid, 88) or Curr_NG(jqid, 85) or Curr_NG(jqid, 102) or Curr_NG(jqid, 108) 
                        or Curr_NG(jqid, 154) or Curr_NG(jqid, 169) or Curr_NG(jqid, 90) or Curr_NG(jqid, 152) or Curr_NG(jqid, 180)
                        or Curr_NG(jqid, 183) or Curr_NG(jqid, 171) or Curr_NG(jqid, 184) then
                        if WAR.SSX_Counter == 3 then
                            AddPersonAttrib(jqid,'���˳̶�',-1)
                        end
                    end

                    --5ʱ���1���˵��ж�
                    --ʥ�𣬿������˻ģ����죬��󡣬����С�ޣ�Ѫ�� ����,��������
                    if Curr_NG(jqid, 93)  or Curr_NG(jqid, 101) or Curr_NG(jqid, 100) 
                        or Curr_NG(jqid, 95) or Curr_NG(jqid, 103) or Curr_NG(jqid, 98) or Curr_NG(jqid, 163) or Curr_NG(jqid, 177) 
                        or Curr_NG(jqid, 190) or Curr_NG(jqid,216) or Curr_NG(jqid,227) then
                        if WAR.WSX_Counter == 5 then
                            --JY.Person[jqid]["���˳̶�"] = JY.Person[jqid]["���˳̶�"] - 1
                            AddPersonAttrib(jqid,'���˳̶�',-1)
                        end
                    end
                        
                    --�����޼���
                    if Curr_NG(jqid, 221) then
                        if WAR.SSX_Counter == 3 then
                            --JY.Person[jqid]["���˳̶�"] = JY.Person[jqid]["���˳̶�"] - 1
                            AddPersonAttrib(jqid,'���˳̶�',-1)
                        end
                    end
                        
                        -- �����ڹ��ظ�5ʱ���1����
                    for i = 208,220 do
                        if Curr_NG(jqid,i) then
                            if WAR.WSX_Counter == 5 then
                                AddPersonAttrib(jqid,'���˳̶�',-1)
                            end
                        end	
                    end	
                        --�����츳�ڹ���5ʱ������1����
                    if JY.Person[jqid]["�����ڹ�"] ~= 0 and JY.Person[jqid]["�����ڹ�"] == JY.Person[jqid]["�츳�ڹ�"] then
                        if WAR.WSX_Counter == 5 then
                            --JY.Person[jqid]["���˳̶�"] = JY.Person[jqid]["���˳̶�"] - 1
                            AddPersonAttrib(jqid,'���˳̶�',-1)
                        end
                    end
                        
                    --�����������˴���50ʱ������ظ�
                    if JY.Person[jqid]["���˳̶�"] > 50 and (Curr_NG(jqid, 106) or Curr_NG(jqid, 107) or Curr_NG(jqid, 108)) then
                        if WAR.SSX_Counter == 3 then
                            --JY.Person[jqid]["���˳̶�"] = JY.Person[jqid]["���˳̶�"] - 1
                            AddPersonAttrib(jqid,'���˳̶�',-1)
                        end
                    end
                        
                end
                    
                if WAR.PD['С����'][jqid] ~= nil then 
                    AddPersonAttrib(jqid,'���˳̶�',-1)
                    WAR.PD['С����'][jqid] = WAR.PD['С����'][jqid] - 1
                    if WAR.PD['С����'][jqid] < 1 then 
                        WAR.PD['С����'][jqid] = nil   
                    end
                end
                ----------------------------------�ж��ظ�-----------------------------------
                    --���������������ˣ��׽ÿʱ��ظ�1���ж�
                if JY.Person[jqid]["�ж��̶�"] > 0 and (Curr_NG(jqid, 99) or Curr_NG(jqid, 106) or Curr_NG(jqid, 104) or Curr_NG(jqid, 108)) then	
                    AddPersonAttrib(jqid,'�ж��̶�',-1)
                end
                    
                    --��ӯӯ��ÿʱ��ظ�5���ж�
                if match_ID(jqid,73) then	
                    AddPersonAttrib(jqid,'�ж��̶�',-5)
                end
                        
                if WAR.PD['�����ⶾ'][jqid] ~= nil then 
                    AddPersonAttrib(jqid,'�ж��̶�',-1)
                    WAR.PD['�����ⶾ'][jqid] = WAR.PD['�����ⶾ'][jqid] - 1
                    if WAR.PD['�����ⶾ'][jqid] < 1 then 
                        WAR.PD['�����ⶾ'][jqid] = nil   
                    end
                end
                
                if WAR.PD['ţ��ѪЫ'][jqid] ~= nil then 
                    AddPersonAttrib(jqid,'�ж��̶�',-1)
                    WAR.PD['ţ��ѪЫ'][jqid] = WAR.PD['ţ��ѪЫ'][jqid] - 1
                    if WAR.PD['ţ��ѪЫ'][jqid] < 1 then 
                        WAR.PD['ţ��ѪЫ'][jqid] = nil   
                    end
                end
                ----------------------------------�����ظ�-----------------------------------
                    --�ظ�����
                if JY.Person[jqid]["����"] < 100 then
                    --���˻�Ԫ��3ʱ���1���� 
                    --�����
                    if Curr_NG(jqid, 90) or (jqid == 0 and JY.Base["����"] == 189) then
                        if WAR.SSX_Counter == 3 then
                            AddPersonAttrib(jqid,'����',1)
                        end
                    --������Ԫ��6ʱ���1����
                    elseif PersonKF(jqid, 90) then
                        if WAR.LSX_Counter == 6 then
                            AddPersonAttrib(jqid,'����',1)
                        end
                    end
                    --���˾��������ˣ�6ʱ���1���� 
                    if (Curr_NG(jqid, 107)  or Curr_NG(jqid, 104)) and (JY.Person[jqid]["��������"] == 0 or JY.Person[jqid]["��������"] == 3)  then
                        if WAR.LSX_Counter == 6 then
                            AddPersonAttrib(jqid,'����',1)
                        end
                    end
				end
			end	
                ----------------------------------ʱ���Ѫ-----------------------------------    
                --��������ɳ����ÿʱ���1%Ѫ
                if match_ID(jqid, 47) and WAR.JYZT[jqid]~=nil then
                    AddPersonAttrib(jqid,'����',-math.modf(JY.Person[jqid]["�������ֵ"]*0.01))
                    if JY.Person[jqid]["����"] < 1 then
                        JY.Person[jqid]["����"] = 0
                        WAR.Person[WAR.CurID]["����"] = true
                        WarSetPerson()
                        
                        break
                    end
                end               
                --��ȼ��ÿʱ����ʧ2%��ǰѪ��
                if WAR.JHLY[jqid] ~= nil then
                    AddPersonAttrib(jqid,'����',-math.modf(JY.Person[jqid]["����"]*0.02))
                    
                    if JY.Person[jqid]["����"] < 1 then
                        JY.Person[jqid]["����"] = 1
                    end
                    WAR.JHLY[jqid] = WAR.JHLY[jqid] - 1
                    
                    if WAR.JHLY[jqid] < 1 then
                        WAR.JHLY[jqid] = nil
                    end
				end
                --���ˣ�ÿʱ����ʧ0.5%���ֵѪ��
                if WAR.PD['����'][jqid] ~= nil then
                    AddPersonAttrib(jqid,'����',-math.modf(JY.Person[jqid]["�������ֵ"]*5/1000))
                    
                    if JY.Person[jqid]["����"] < 1 then
                        JY.Person[jqid]["����"] = 1
                    end
					WAR.PD['����'][jqid] = WAR.PD['����'][jqid] - 1
                    
                    if WAR.PD['����'][jqid] < 1 then
                        WAR.PD['����'][jqid] = nil
                    end
				end	
				----------------------------------ʱ�����-----------------------------------    			
                --ɢ����ÿʱ����ʧ1%��ǰ����
                if WAR.SGZT[jqid] ~= nil then
                    AddPersonAttrib(jqid,'����',-math.modf(JY.Person[jqid]["����"]*0.01))
                    if JY.Person[jqid]["����"] < 1 then
                        JY.Person[jqid]["����"] = 1
                    end	
                    WAR.SGZT[jqid] = WAR.SGZT[jqid] - 1
                    if WAR.SGZT[jqid] < 1 then
                        WAR.SGZT[jqid] = nil
                    end
				end					
				--[[
            ['�˾Ʊ�'] = {},
            ['�滨��'] = {},
            ['��¶��'] = {},
            ['��ī�Ͼ�'] = {},
            ['�����ܵ�'] = {},
            ['��������'] = {},
            ['С����'] = {},
            ['�����ⶾ'] = {},
            ['ţ��ѪЫ'] = {},
            ['��������'] = {},
            ]]
            
                if WAR.PD['�滨��'][jqid] ~= nil then 
                    AddPersonAttrib(jqid,'����̶�',-1)
                    WAR.PD['�滨��'][jqid] = WAR.PD['�滨��'][jqid] - 1
                    if WAR.PD['�滨��'][jqid] < 1 then 
                        WAR.PD['�滨��'][jqid] = nil   
                    end
                end
                
                if WAR.PD['��¶��'][jqid] ~= nil then 
                    AddPersonAttrib(jqid,'���ճ̶�',-1)
                    WAR.PD['��¶��'][jqid] = WAR.PD['��¶��'][jqid] - 1
                    if WAR.PD['��¶��'][jqid] < 1 then 
                        WAR.PD['��¶��'][jqid] = nil   
                    end
                end
                if WAR.PD['�屦���۾�'][jqid] ~= nil then 
                    WAR.PD['�屦���۾�'][jqid] = WAR.PD['�屦���۾�'][jqid] - 1
                    if WAR.PD['�屦���۾�'][jqid] < 1 then 
                        WAR.PD['�屦���۾�'][jqid] = nil   
                    end
                end                
                if WAR.PD['��ī�Ͼ�'][jqid] ~= nil then
                    if WAR.LXZT[jqid] ~= nil then
                        WAR.LXZT[jqid] = WAR.LXZT[jqid] - 1
                        if WAR.LXZT[jqid] < 1 then 
                            WAR.LXZT[jqid] = nil
                        end
                    end
                    WAR.PD['��ī�Ͼ�'][jqid] = WAR.PD['��ī�Ͼ�'][jqid] - 1
                    if WAR.PD['��ī�Ͼ�'][jqid] < 1 then 
                        WAR.PD['��ī�Ͼ�'][jqid] = nil   
                    end
                end

 				--�������ʯ��٣�100ʱ��
				if WAR.YSJF[jqid] ~= nil then
					WAR.YSJF[jqid] = WAR.YSJF[jqid] - 1
					
					if WAR.YSJF[jqid] < 1 then
						WAR.YSJF[jqid] = nil
					end
				end
				--��Ѱ��С��ɵ�״̬��
				if WAR.XLFD[jqid] ~= nil then
					WAR.XLFD[jqid] = WAR.XLFD[jqid] - 1
					
					if WAR.XLFD[jqid] < 1 then
						WAR.XLFD[jqid] = nil
					end
				end		
				--����һ��״̬
				if WAR.JTYJ[jqid] ~= nil then
					WAR.JTYJ[jqid] = WAR.JTYJ[jqid] - 1
					
					if WAR.JTYJ[jqid] < 1 then
						WAR.JTYJ[jqid] = nil
					end
				end					
	
				if WAR.PD['���ϵ����е�'][jqid] ~= nil then 
                    if WAR.PD['���ϵ����е�'][jqid][2] ~= nil and WAR.PD['���ϵ����е�'][jqid][2] > 0 then 
                        WAR.PD['���ϵ����е�'][jqid][2] = WAR.PD['���ϵ����е�'][jqid][2] - 1
                        if WAR.PD['���ϵ����е�'][jqid][2] < 1 then 
                            WAR.PD['���ϵ����е�'][jqid] = nil
                        end
                    end
                end
                
				--����״̬ 
				if WAR.XRZT[jqid] ~= nil then
					WAR.XRZT[jqid] = WAR.XRZT[jqid] - 1
					if WAR.XRZT[jqid] < 1 then
						WAR.XRZT[jqid] = nil
					end
				end		
                --���커��
				if WAR.PD["���커��CD"][jqid] ~= nil and WAR.PD["���커��"][jqid] == nil then
					WAR.PD["���커��CD"][jqid] = WAR.PD["���커��CD"][jqid] -1
					if WAR.PD["���커��CD"][jqid] < 1 then
						WAR.PD["���커��CD"][jqid] = nil
					end
                end	
				--�޾Ʋ��������˸�󡹦 ��Ϣ��ʱ������ŭ��
				--��һ������
				if Curr_NG(jqid, 95) or match_ID_awakened(jqid,633,1) or Curr_NG(jqid, 180)then
					if WAR.LQZ[jqid] == nil then
						WAR.LQZ[jqid] = 1
					elseif WAR.LQZ[jqid] < 100 then
						WAR.LQZ[jqid] = WAR.LQZ[jqid] + 1
						if WAR.LQZ[jqid] == 100 then
							--�������ܣ������ط�������Ϊ��
							local s = WAR.CurID
							local say = "ŭ������"
							local ani_num = 6
							WAR.CurID = i
							if match_ID(jqid, 27) then
								say = "�����ط�������Ϊ��"
								ani_num = 7
							end
							if match_ID(jqid, 568) then
								say = "���ұ���"
								ani_num = 8
							end	
							WarDrawMap(0)

							CurIDTXDH(WAR.CurID, ani_num, 1, say)

						end
					end
				end
					
				--�޾Ʋ�������Զɽʱ������ŭ��
				if match_ID(jqid, 112) then
					if WAR.LQZ[jqid] == nil then
						WAR.LQZ[jqid] = 2
					elseif WAR.LQZ[jqid] < 100 then
						WAR.LQZ[jqid] = WAR.LQZ[jqid] + 2
						if WAR.LQZ[jqid] >= 100 then
							WAR.LQZ[jqid] = 100
							local s = WAR.CurID
							WAR.CurID = i
							--Cls()
							WarDrawMap(0)

							CurIDTXDH(WAR.CurID, 6, 1, "ŭ������")

						end
					end
				end
			--��̩����Ѫ������һ��ʱ��+2��ʱ��ŭ��
	            if match_ID(jqid, 151)  then
					if WAR.LQZ[jqid] == nil then
                        WAR.LQZ[jqid] = 1
					elseif WAR.LQZ[jqid] < 100 then
                        WAR.LQZ[jqid] = WAR.LQZ[jqid] + 1
                        if JY.Person[jqid]["����"] < JY.Person[jqid]["�������ֵ"] *0.5 then
                            WAR.LQZ[jqid] = WAR.LQZ[jqid] + 1					
                            if WAR.LQZ[jqid] >= 100 then
                                WAR.LQZ[jqid] = 100
                                local s = WAR.CurID
                                WAR.CurID = i

                                WarDrawMap(0)

                                CurIDTXDH(WAR.CurID, 6, 1, "ŭ������")

                            end
                        end
                    end
                end
                
               -- ÷���� ͵�컻��
                 if match_ID(jqid,507)   then
                    if WAR.PD["͵�컻��"][jqid] == nil then
                        WAR.PD["͵�컻��"][jqid] = 1
                    else
                        WAR.PD["͵�컻��"][jqid] = WAR.PD["͵�컻��"][jqid] + 1
                    end	
                    if WAR.PD["͵�컻��"][jqid] >= 100 and JY.Person[jqid]["����̶�"] == 0 and JY.Person[jqid]["���ճ̶�"] == 0 then
                       WAR.PD["͵�컻��"][jqid] = nil	
                       WAR.ZSXS[jqid] = 1
                       AddPersonAttrib(jqid,'���ճ̶�',50)
                       WAR.BFXS[jqid] = 1										
                      AddPersonAttrib(jqid,'����̶�',100)
                       local s = WAR.CurID
                       WAR.CurID = i
                       WarDrawMap(0)
                       CurIDTXDH(WAR.CurID, 104, 1, "�𺮶�����͵�컻��", PinkRed)
                       WAR.CurID = s
                       JY.Person[jqid]["����"] = JY.Person[jqid]["�������ֵ"]
                       JY.Person[jqid]["����"] = JY.Person[jqid]["�������ֵ"]
                       JY.Person[jqid]["����"] = 100
                       JY.Person[jqid]["�ж��̶�"] = 0
                       JY.Person[jqid]["���˳̶�"] = 0
                        --��Ѫ
                       if WAR.LXZT[jqid] ~= nil then
                          WAR.LXZT[jqid] = nil
                       end
                       --��Ѩ
                       if WAR.FXDS[jqid] ~= nil then
                          WAR.FXDS[jqid] = nil
                       end
                       
                    end
                end			   

				--��ɽͯ�ѣ�ת˲����
				if match_ID(jqid, 117) then
					if WAR.ZSHY[jqid] == nil then
						WAR.ZSHY[jqid] = 1
					else
						WAR.ZSHY[jqid] = WAR.ZSHY[jqid] + 1
					end
					if WAR.ZSHY[jqid] == 199 then
						WAR.ZSHY[jqid] = nil
						local s = WAR.CurID
						WAR.CurID = i

						WarDrawMap(0)

						CurIDTXDH(WAR.CurID, 104, 1, "���յ�ָ�ϡ�ɲ�Ƿ���", PinkRed)
						WAR.CurID = s

						JY.Person[jqid]["����"] = JY.Person[jqid]["�������ֵ"]
						JY.Person[jqid]["����"] = JY.Person[jqid]["�������ֵ"]
						JY.Person[jqid]["����"] = 100
						JY.Person[jqid]["�ж��̶�"] = 0
						JY.Person[jqid]["���˳̶�"] = 0
						JY.Person[jqid]["����̶�"] = 0
						JY.Person[jqid]["���ճ̶�"] = 0
						--��Ѫ
						if WAR.LXZT[jqid] ~= nil then
							WAR.LXZT[jqid] = nil
						end
						--��Ѩ
						if WAR.FXDS[jqid] ~= nil then
							WAR.FXDS[jqid] = nil
						end
					end
				end
	

				--�������ߣ��ָ�
				if match_ID(jqid,608) then
					AddPersonAttrib(jqid,'����',5)
					AddPersonAttrib(jqid,'����',10)
					AddPersonAttrib(jqid,'����',1)
					AddPersonAttrib(jqid,'�ж��̶�',-1)
					AddPersonAttrib(jqid,'���˳̶�',-1)
					AddPersonAttrib(jqid,'����̶�',-1)	
					AddPersonAttrib(jqid,'���ճ̶�',-1)	
					--��Ѫ
					
					if WAR.LXZT[jqid] ~= nil then
						WAR.LXZT[jqid] = WAR.LXZT[jqid] - 1
					end
					--��Ѩ
					if WAR.FXDS[jqid] ~= nil then
						WAR.FXDS[jqid] = WAR.FXDS[jqid] - 1
					end
				end
				
				--���Ʊ���ʱ�����
				if WAR.QYBY[jqid] ~= nil then
					WAR.QYBY[jqid] = WAR.QYBY[jqid] - 1	
					if WAR.QYBY[jqid] < 1 then
						WAR.QYBY[jqid] = nil
					end
				end
		
				--����̩ɽ��ʹ�ú�30ʱ�������� 
				if WAR.TSSB[jqid] ~= nil then
					WAR.TSSB[jqid] = WAR.TSSB[jqid] - 1
					if WAR.TSSB[jqid] < 1 then
						WAR.TSSB[jqid] = nil
					end
				end
				--����ָͩ��
				if WAR.HQT_ZL[jqid] ~= nil then
					WAR.HQT_ZL[jqid] = WAR.HQT_ZL[jqid] - 1
					if WAR.HQT_ZL[jqid] < 1 then
						WAR.HQT_ZL[jqid] = nil
					end
				end			
				--��̩�� ��̩��״̬��ʱ WTL_PJTL
				if WAR.WTL_PJTL[jqid] ~= nil then
				   WAR.WTL_PJTL[jqid] = WAR.WTL_PJTL[jqid] - 1
					if WAR.WTL_PJTL[jqid] < 1 then
						WAR.WTL_PJTL[jqid] = nil
						WAR.WTL_1[jqid] = nil
					end
				end	
				--��̩�� ��̩������ʱ
				if WAR.WTL_1[jqid] ~= nil then
				  WAR.WTL_1[jqid] = WAR.WTL_1[jqid] - 1
					if WAR.WTL_1[jqid] < 1 then
						WAR.WTL_1[jqid] = 0
					end
				end
			
				--�������ɣ�ʹ�ú�50ʱ��������
				if WAR.QLJX[jqid] ~= nil then
					WAR.QLJX[jqid] = WAR.QLJX[jqid] - 1
					if WAR.QLJX[jqid] < 1 then
						WAR.QLJX[jqid] = nil
					end
				end
				--�����칦�ظ�50ʱ��
				if WAR.ZTHF[jqid] ~= nil then
					WAR.ZTHF[jqid] = WAR.ZTHF[jqid] - 1
					if WAR.ZTHF[jqid] < 1 then
						WAR.ZTHF[jqid] = nil
					end
				end				
				--½����ʮ������ һ����
				if WAR.SSESS[jqid] ~= nil then
					WAR.SSESS[jqid] = WAR.SSESS[jqid] - 1
					if WAR.SSESS[jqid] < 1 then
						WAR.SSESS[jqid] = nil
					end
				end	
				--½�� ��շ���
				if WAR.JGFX[jqid] ~= nil then
					WAR.JGFX[jqid] = WAR.JGFX[jqid] - 1
					if WAR.JGFX[jqid] < 1 then
						WAR.JGFX[jqid] = nil
					end
				end	
			
				--����ʮ������ʹ�ú�30ʱ��������
				if WAR.SFB[jqid] ~= nil then
					WAR.SFB[jqid] = WAR.SFB[jqid] - 1
					if WAR.SFB[jqid] < 1 then
						WAR.SFB[jqid] = nil
					end
				end
				--��������ظ���ʹ�ú�100ʱ���ڻظ�
				if WAR.CSHF[jqid] ~= nil then
					WAR.CSHF[jqid] = WAR.CSHF[jqid] - 1
					if WAR.CSHF[jqid] < 1 then
						WAR.CSHF[jqid] = nil
					end
				end	
	
                if WAR.PD['������'][jqid] ~= nil then 
					AddPersonAttrib(jqid,'����',math.modf(JY.Person[jqid]["�������ֵ"]/100))
					AddPersonAttrib(jqid,'����',math.modf(JY.Person[jqid]["�������ֵ"]/100))
					AddPersonAttrib(jqid,'����',1)
                    WAR.PD['������'][jqid] = WAR.PD['������'][jqid] - 1
                    if WAR.PD['������'][jqid] < 1 then 
                       WAR.PD['������'][jqid] = nil     
                    end
                end
				--����ҵ��״̬������ʹ�õ�����һ���������30ʱ��
				if WAR.WMYH[jqid] ~= nil then
					WAR.WMYH[jqid] = WAR.WMYH[jqid] - 1
					if WAR.WMYH[jqid] < 1 then
						WAR.WMYH[jqid] = nil
					end
				end
			
				
				--�żһԵ������ָ
				if WAR.YSJZ ~= 0 then
					WAR.YSJZ = WAR.YSJZ - 1
				end
                
                
                if ZhongYongZD(jqid) then 
                    local t = JY.Person[jqid]['����']-1
                    if t < 30 then 
                        t = 30
                    end
                    if WAR.PD['��ӹ'][jqid] == nil or WAR.PD['��ӹ'][jqid] < t then 
                        WAR.PD['��ӹ'][jqid] = (WAR.PD['��ӹ'][jqid] or 0) + 1
                        if WAR.PD['��ӹ'][jqid] >= t then 
                            WAR.PD['��ӹ'][jqid] = 0
                            Cat('���̳���',i)
                            WAR.CurID = i
                            WarDrawMap(0)
                            CurIDTXDH(WAR.CurID, 6, 1, "��ӹ֮��", PinkRed)
                            --atid = i
                            xunhuan = false
                        end
                    end
                end
                
				--[[��ӹCD
				if WAR.ZYCD < 30 and jqid == 0 and ZhongYongZD(jqid) and WAR.Atid == -1 then
					WAR.ZYCD = WAR.ZYCD + 1
                    if WAR.ZYCD >= 30 then
                        if WAR.ZYHBP ~= i and WAR.ZYHB == 1 then
                            WAR.ZYHB = 0
                            WAR.ZYHBP = -1
                            WAR.ZYCD = 0
                            WAR.Atid = i
                            WAR.CurID = i
                            --Cls()
                            WarDrawMap(0)
                            --lib.SetClip(0, CC.ScreenH/4 + 20, CC.ScreenW, CC.ScreenH)
                            CurIDTXDH(WAR.CurID, 6, 1, "��ӹ֮��", PinkRed)
                            xunhuan = false
                        end
                    end
				end	
                ]]
                --WAR.Person[i].Time = 1001
				--�����壺���ѹ�ָ���ʱ���ж�
				if WAR.L_WNGZL[jqid] ~= nil and WAR.L_WNGZL[jqid] > 0 then
					AddPersonAttrib(jqid,'�ж��̶�',1)
					WAR.L_WNGZL[jqid] = WAR.L_WNGZL[jqid] -1;
						
					if WAR.L_WNGZL[jqid] <= 0 then
						WAR.L_WNGZL[jqid] = nil;
					end
				end
					
				--brolycjw������ţָ�ÿ��ʱ��ظ�1%Ѫ
				if WAR.L_HQNZL[jqid] ~= nil and WAR.L_HQNZL[jqid] > 0 then
					--JY.Person[jqid]["����"] = JY.Person[jqid]["����"] + math.modf(JY.Person[jqid]["�������ֵ"]/100);
					AddPersonAttrib(jqid,'����',math.modf(JY.Person[jqid]["�������ֵ"]/100))
					
					if JY.Person[jqid]["���˳̶�"] > 50 then
						--JY.Person[jqid]["���˳̶�"] = JY.Person[jqid]["���˳̶�"] - 2;
						AddPersonAttrib(jqid,'���˳̶�',-2)
					else
						--JY.Person[jqid]["���˳̶�"] = JY.Person[jqid]["���˳̶�"] - 1;
						AddPersonAttrib(jqid,'���˳̶�',-1)
					end
					WAR.L_HQNZL[jqid] = WAR.L_HQNZL[jqid] -1;
					if WAR.L_HQNZL[jqid] <= 0 then
						WAR.L_HQNZL[jqid] = nil;
					end
				end
				--��������ظ� ��Ѫ1%  ������2
				if WAR.CSHF[jqid] ~= nil  then
					--JY.Person[jqid]["����"] = JY.Person[jqid]["����"] + math.modf(JY.Person[jqid]["�������ֵ"]/100);
					--JY.Person[jqid]["����"] = JY.Person[jqid]["����"] + math.modf(JY.Person[jqid]["�������ֵ"]/100);
					--JY.Person[jqid]["����"] = JY.Person[jqid]["����"] + math.modf(JY.Person[jqid]["�������ֵ"]/100);	
					AddPersonAttrib(jqid,'����',math.modf(JY.Person[jqid]["�������ֵ"]/100))
					AddPersonAttrib(jqid,'����',math.modf(JY.Person[jqid]["�������ֵ"]/100))
					AddPersonAttrib(jqid,'����',1)
					if JY.Person[jqid]["���˳̶�"] > 50 then
						--JY.Person[jqid]["���˳̶�"] = JY.Person[jqid]["���˳̶�"] - 2;
						AddPersonAttrib(jqid,'���˳̶�',-2)
					else
						--JY.Person[jqid]["���˳̶�"] = JY.Person[jqid]["���˳̶�"] - 1;
						AddPersonAttrib(jqid,'���˳̶�',-1)
					end
					WAR.CSHF[jqid] = WAR.CSHF[jqid] -1;
					if WAR.CSHF[jqid] <= 0 then
						WAR.CSHF[jqid] = nil;
					end
				end				

                if match_ID(jqid, 581) then 
                    if WAR.Person[i].Time < 0 then 
                        WAR.Person[i].Time = 0    
                    end
                end
                
				--�޾Ʋ���������������ȡλ��
				WAR.JQSDXS[jqid] = math.modf(jq)
		 
				if WAR.Person[i].Time >= 1000 then
					if jqwz < WAR.Person[i].Time then 
						jqwz = WAR.Person[i].Time
						atid = i
					end
                    xunhuan = false
				end
    
                --[[
				if WAR.Person[i].Time >= 1000 then
					if WAR.ZYHB == 1 then
						if i ~= WAR.ZYHBP then
							WAR.Person[i].Time = 990
						else
							WAR.Person[i].Time = 1001
						end
					end
					xunhuan = false
				end
                ]]
			end
		end
		
		if WAR.CD > 0 then 
			WAR.CD = WAR.CD - 1
		end
		
		Cat('�����')
		
        if #WAR.ATK['����table'] > 0 then
            atid = WAR.ATK['����table'][#WAR.ATK['����table']]
            local id = WAR.Person[atid]['������']
            table.remove(WAR.ATK['����table'],#WAR.ATK['����table'])
            WAR.ATK['����pd'][id] = nil
            if #WAR.ATK['����table'] == 0 then 
                WAR.ATK['����table'] = {}
            end
        end  
		
		--local num = math.ceil(CC.BattleDelay/10)
		--xh = xh + 1
		--if xh == num then 
		Cat('ʵʱ��Ч����')
		--	xh = 0
		--end
		WarDrawMap(0) 
		--DrawString(x2 + 10-410, y - 60-25, "ʱ��", C_WHITE, CC.DefaultFont*0.8)
		--lib.LoadPicture("./data/xt/23.png",0,0,1)	
		--DrawTimeBar_sub(x1, x2, nil, 0)
        DrawTimeBar_sub()
		ShowScreen()
		lib.Delay(CC.BattleDelay) --��������֭����ˢ���ٶ�
		--lib.Delay(10)
		WAR.SXTJ = WAR.SXTJ + 1
		--�޾Ʋ�������ʱ����ʱ����ʱ�򣬾�ʱ��ļ�����
		WAR.SSX_Counter = WAR.SSX_Counter + 1
		if WAR.SSX_Counter == 4 then
			WAR.SSX_Counter = 1
		end
		WAR.WSX_Counter = WAR.WSX_Counter + 1
		if WAR.WSX_Counter == 6 then
			WAR.WSX_Counter = 1
		end
		WAR.LSX_Counter = WAR.LSX_Counter + 1
		if WAR.LSX_Counter == 7 then
			WAR.LSX_Counter = 1
		end
		WAR.JSX_Counter = WAR.JSX_Counter + 1
		if WAR.JSX_Counter == 10 then
			WAR.JSX_Counter = 1
		end
		--lib.Delay(10) -- �޾Ʋ����������������ٶ�	
		
		--���������а��ո��س�ֹͣ�Զ�
		local keypress = lib.GetKey()
		if (keypress == VK_SPACE or keypress == VK_RETURN) then
			if WAR.AutoFight == 1 then 
				WAR.AutoFight = 0
			end	
            
		end
		--lib.LoadSur(surid, x1 - ((x2 - x1) / 2)-100, 0)	--�޾Ʋ������޸�ɱ��-500������Сͷ��ˢ������
	end
    
	::label1::
  
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["����"] == false then
			WAR.Person[i].TimeAdd = 0
		end
	end
  
	--WAR.ZYHBP = -1
	--lib.SetClip(0, 0, 0, 0)
	--lib.FreeSur(surid)
    return atid
end

--�滭���弯����
function DrawTimeBar_sub(x1, x2, y, flag)

	--�޾Ʋ������滭����������������ʾ
	if not x2 then
		x2 = CC.ScreenW * 19 / 20 - 2  --X�Ϸ�λ��
	end
	if not y then
		y = CC.ScreenH/10 + 29
	end
	if not x1 then
		x1 = CC.ScreenW * 1 / 2 - 34  --X�·�λ��
		lib.LoadPicture("./data/xt/23.png",0,0,1)	
	end
  
	for i = 0, WAR.PersonNum - 1 do
		if not WAR.Person[i]["����"] then
			--�޾Ʋ�����������������ʾ������ɹ�1000
			if WAR.Person[i].Time > 1001 then
				WAR.Person[i].Time = 1001
			end
			local id = WAR.Person[i]["������"]
			local cx = x1 + math.modf(WAR.Person[i].Time*(x2 - x1)/1000)
			local headid = JY.Person[id]["������"]
			if headid == nil then
				headid = JY.Person[id]["������"]
			end
			local w, h = limitX(CC.ScreenW/25,12,35),limitX(CC.ScreenW/25,12,35)
			local jq_color = C_WHITE
			if JY.Person[id]["�ж��̶�"] == 100 then
				jq_color = RGB(56, 136, 36)
			elseif JY.Person[id]["�ж��̶�"] >= 50 then
				jq_color = RGB(120, 208, 88)
			end
			if WAR.LQZ[id] == 100 then
				jq_color = C_RED
			end
			if WAR.Person[i]["�ҷ�"] then
				drawname(cx, 1, id, CC.FontSmall)
				lib.LoadPNG(99, headid*2, cx - w / 2, y - h - 4, 1, 0)
				DrawString(cx-17-5, y-10-90-5, string.format("%3d",WAR.JQSDXS[id]), jq_color, CC.FontSMALL)	--�����ٶ�
				if JY.Person[id]["���ճ̶�"] ~= 0 then
					DrawString(cx, y-10-33, string.format("%3d",JY.Person[id]["���ճ̶�"]), C_ORANGE, CC.FontSMALL)	--������ֵ
				end
				if WAR.FXDS[id] ~= nil and WAR.FXDS[id] ~= 0 then
					DrawString(cx-21, y-10-33, string.format("%3d",WAR.FXDS[id]), C_GOLD, CC.FontSMALL)	--��Ѩ��ֵ
				end
			else
				drawname(cx, y+h, id, CC.FontSmall)
				lib.LoadPNG(99, headid*2, cx - w / 2, y + 6-5, 1, 0)
				DrawString(cx-21, y+h-5, string.format("%3d",WAR.JQSDXS[id]), jq_color, CC.FontSMALL)	--�����ٶ�
				if JY.Person[id]["���ճ̶�"] ~= 0 then
					DrawString(cx, y+h-33, string.format("%3d",JY.Person[id]["���ճ̶�"]), C_ORANGE, CC.FontSMALL)	--������ֵ
				end
				if WAR.FXDS[id] ~= nil and WAR.FXDS[id] ~= 0 then
					DrawString(cx-21, y+h-33, string.format("%3d",WAR.FXDS[id]), C_GOLD, CC.FontSMALL)	--��Ѩ��ֵ
				end
			end
		end
	end
	DrawString(x2 + 10-370, y-80-8 , WAR.SXTJ, C_GOLD, CC.DefaultFont*0.9)
    DrawString(x2 + 10-420, y - 60-25, "ʱ��", C_WHITE, CC.DefaultFont*0.8)	
	
end

--�滭�������ϵ�����
function drawname(x, y, id, size)
	local name = JY.Person[id]["����"]
	local color = C_WHITE
	--������ɫ���������˱仯
	if JY.Person[id]["���˳̶�"] > JY.Person[id]["����̶�"] then
		if JY.Person[id]["���˳̶�"] > 99 then
			color = RGB(232, 32, 44)
		elseif JY.Person[id]["���˳̶�"] > 66 then
			color = RGB(244, 128, 32)
		elseif JY.Person[id]["���˳̶�"] > 33 then
			color = RGB(236, 200, 40)
		end
	else
		if JY.Person[id]["����̶�"] >= 50 then
			color = M_RoyalBlue
		elseif JY.Person[id]["����̶�"] > 0 then
			color = LightSkyBlue
		end
	end
	x = x - math.modf(size / 2)
	local namelen = string.len(name) / 2
	local zi = {}
	for i = 1, namelen do
		zi[i] = string.sub(name, i * 2 - 1, i * 2)
		DrawString(x-5, y+12-5, zi[i], color, size)
		y = y + size
	end
end


function draw2(str,x, y, color,size,color2)

	x = x - size/2
	local namelen = string.len(str) / 2
	local zi = {}
	for i = 1, namelen do
		zi[i] = string.sub(str, i * 2 - 1, i * 2)
		if color2 ~= nil then
			if i == namelen then 
				color = color2
			end
		end
		DrawString(x, y+size*(i-1)/2, zi[i], color, size)
		y = y + size
	end
end


function draw3(str,x, y, color,size,color2,h)

	x = x - size/2
	local namelen = string.len(str) / 2
	local zi = {}
	h = h or size
	for i = 1, namelen do
		zi[i] = string.sub(str, i * 2 - 1, i * 2)
		if color2 ~= nil then
			if i == namelen then 
				color = color2
			end
		end
		DrawString(x, y, zi[i], color, size)
		y = y + h
	end
end

--�ж�����֮��ľ���
function RealJL(id1, id2, len)
	if not len then
		len = 1
	end
	local x1, y1 = WAR.Person[id1]["����X"], WAR.Person[id1]["����Y"]
	local x2, y2 = WAR.Person[id2]["����X"], WAR.Person[id2]["����Y"]
	local s = math.abs(x1 - x2) + math.abs(y1 - y2)
	if len == nil then
		return s
	end
	if s <= len then
		return true
	else
		return false
	end
end

--�����书��Χ
function refw(wugong, level)
  --�޾Ʋ���������˵��
  --m1Ϊ�ƶ���Χб�����죺
	--0������Ϊֱ�߾���-1��1��������ֱ�߾��룬2������Ϊ0 3���ƶ���Χ�̶�Ϊ������Χ8��
  --m2Ϊ�ƶ���Χֱ�����죻
	--���ּ������������
  --a1Ϊ������Χ���ͣ�
	--0���㹥��1��ʮ�֣�2�����Σ�3���湥��5��ʮ�֣�6�����֣�7�����֣�8���d�֣�9���e�֣�10��ֱ�ߣ�11�������ǣ�12�������ǣ�13������
  --a2Ϊ������Χ���Ⱦ��룺
	--0���㹥������0ʱ������ = a2
  --a3Ϊ������Χ���(ƫ��1��)���룺
	--0���㹥������0ʱ������ = a3  
  --a4Ϊ������Χ���(ƫ��2��)���룺
	--0���㹥������0ʱ������ = a4
  --a5Ϊ������Χ���(ƫ��3��)���룺
	--0���㹥������0ʱ������ = a5
	local m1, m2, a1, a2, a3, a4, a5, a6  = nil, nil, nil, nil, nil, nil, nil ,nil
	if JY.Wugong[wugong]["������Χ"] == -1 then
		return JY.Wugong[wugong]["������1"], JY.Wugong[wugong]["������2"], JY.Wugong[wugong]["δ֪1"], JY.Wugong[wugong]["δ֪2"], JY.Wugong[wugong]["δ֪3"], JY.Wugong[wugong]["δ֪4"], JY.Wugong[wugong]["δ֪5"]
	end
	--0����
	--1����
	--2��ʮ��
	--3����
	local fightscope = JY.Wugong[wugong]["������Χ"]
	local kfkind = JY.Wugong[wugong]["�书����"]
	local pid = WAR.Person[WAR.CurID]["������"]
	--�������㽣���ķ�Χ
	if wugong == 49 then
		kfkind = 3
	end
	--��Ů���������ŵķ�Χ
	if wugong == 161 then
		kfkind = 5
	end

	--��ң���㵶���ķ�Χ
	if wugong == 168 then
		kfkind = 4
	end
	--���絶�㽣���ķ�Χ
	if wugong == 174 then
		kfkind = 3
	end
	if wugong == 47 then
		kfkind = 2
	end	
	--�����������
	local MiaofaWX = 0
	local mx = 0
	for i = 0, WAR.PersonNum - 1 do
		local id = WAR.Person[i]["������"]
		if WAR.Person[i]["����"] == false and WAR.Person[i]["�ҷ�"] and match_ID(id, 76) and inteam(pid) then
			MiaofaWX = MiaofaWX + 1
			break
		end
	end
	if mx > 2 then
	mx  = 2
	end	
	--���޵���Ҳ���ӹ�����Χ
	if Curr_QG(pid,148) and (JY.Person[pid]["����"] == 335)  == false then
	    mx = MiaofaWX + 1
		MiaofaWX = mx
	end
	--�����޳�
	if match_ID(pid, 9985)  then
		MiaofaWX = MiaofaWX + 1
	end	
	--��֤��ȭ����Χ+1
	if match_ID(pid, 149) and kfkind == 1 then
		MiaofaWX = MiaofaWX + 1
	end
	--����ͻ�Ԫ����Χ+1
	if match_ID(pid, 189) and wugong == 90 then
		MiaofaWX = MiaofaWX + 1
	end	
    --����ˮ �������� ���书��Χ+1
	if match_ID(pid, 652) and JY.Base["��������"] > 5then
		MiaofaWX = MiaofaWX + 1
	end
    --Ī�󽣷���Χ+1
	if match_ID(pid, 20) and kfkind == 3 then
		MiaofaWX = MiaofaWX + 1
	end	
	
	--˫���ϱڷ�Χ���ӷ�Χ
	if  (wugong == 39 or wugong == 42 or wugong == 139) and ShuangJianHB(pid) then 
	   MiaofaWX	= MiaofaWX + 1
	end	

	--���˷�罣��Χ������ϵ������
	if match_ID(pid, 3) and wugong == 44 then
		MiaofaWX = MiaofaWX + math.modf(TrueYJ(pid)/200)
	end
	--�����������ֿտշ�Χ������
	if wugong == 113 or wugong == 116 then
		MiaofaWX = 0
	end
	--��
	if fightscope == 0 then
		if level > 10 then
			m1 = 1
			m2 = JY.Wugong[wugong]["�ƶ���Χ" .. 10]
			a1 = 1
			a2 = 3 + MiaofaWX
			a3 = 3 + MiaofaWX
		else
			m1 = 0
			m2 = JY.Wugong[wugong]["�ƶ���Χ" .. level]
			a1 = 1
			a2 = math.modf(level / 5) + MiaofaWX
			a3 = math.modf(level / 8) + MiaofaWX
		end
	--��
	elseif fightscope == 1 then
		--ȭָ
		if kfkind == 1 or kfkind == 2 then
			a1 = 12
			if level > 10 then
				m1 = 3
				m2 = 1
				a2 = JY.Wugong[wugong]["�ƶ���Χ" .. 10] - 1 + MiaofaWX
			else
				m1 = 2
				m2 = 1
				a2 = JY.Wugong[wugong]["�ƶ���Χ" .. level] - 1 + MiaofaWX
			end
		--��
		elseif kfkind == 3 then
			a1 = 10
			if level > 10 then
				m1 = 3
				m2 = 1
				a2 = JY.Wugong[wugong]["�ƶ���Χ" .. 10] + MiaofaWX
				a3 = a2 - 1
				a4 = a3 - 1
			else
				m1 = 2
				m2 = 1
				a2 = JY.Wugong[wugong]["�ƶ���Χ" .. level] + MiaofaWX
			end
			if level > 7 then
				a3 = a2 - 1
			end
		--��
		elseif kfkind == 4 then
			a1 = 11
			if level > 10 then
				m1 = 3
				m2 = 1
				a2 = JY.Wugong[wugong]["�ƶ���Χ" .. 10] - 1 + MiaofaWX
			else
				m1 = 2
				m2 = 1
				a2 = JY.Wugong[wugong]["�ƶ���Χ" .. level] - 1 + MiaofaWX
			end
		--��
		elseif kfkind == 5 then
			m1 = 2
			if level > 10 then
				m2 = JY.Wugong[wugong]["�ƶ���Χ" .. 10] - 1
				a1 = 7
				--���ֶ�תʱ�������ӷ�Χ
				if WAR.DZXY == 0 then
					a2 = 1 + math.modf(level / 3) + MiaofaWX
				else
					a2 = 1 + math.modf(level / 3)
				end
				a3 = a2
			else
				m2 = JY.Wugong[wugong]["�ƶ���Χ" .. level] - 1
				a1 = 1
				a2 = 1 + math.modf(level / 3) + MiaofaWX
			end
		else
			a1 = 11
			if level > 10 then
				m1 = 3
				m2 = 1
				a2 = JY.Wugong[wugong]["�ƶ���Χ" .. 10] - 1 + MiaofaWX
			else
				m1 = 2
				m2 = 1
				a2 = JY.Wugong[wugong]["�ƶ���Χ" .. level] - 1 + MiaofaWX
			end
		end
	--ʮ��
	elseif fightscope == 2 then
		m1 = 0
		m2 = 0
		--��
		if kfkind == 4 then
			if level > 10 then
				a1 = 6
				a2 = JY.Wugong[wugong]["�ƶ���Χ" .. 10] + MiaofaWX
			else
				a1 = 8
				a2 = JY.Wugong[wugong]["�ƶ���Χ" .. level] + MiaofaWX
			end
		--�����ķǵ�
		elseif level > 10 then
			--ȭָ
			if kfkind == 1 or kfkind == 2 then
				a1 = 5
				a2 = JY.Wugong[wugong]["�ƶ���Χ" .. 10] - 1 + MiaofaWX
				a3 = a2 - 3
			--��
			elseif kfkind == 3 then
				a1 = 1
				a2 = JY.Wugong[wugong]["�ƶ���Χ" .. 10] - 1 + MiaofaWX
				a3 = a2
			else
				a1 = 2
				a2 = 1 + math.modf(JY.Wugong[wugong]["�ƶ���Χ" .. 10] / 2) + MiaofaWX
			end
		--�������ķǵ�
		else
			  a1 = 1
			  a2 = JY.Wugong[wugong]["�ƶ���Χ" .. level] + MiaofaWX
			  a3 = 0
		end
	--��
	elseif fightscope == 3 then
		m1 = 0
		a1 = 3
		if level > 10 then
			m2 = JY.Wugong[wugong]["�ƶ���Χ" .. 10] + 1
			a2 = JY.Wugong[wugong]["ɱ�˷�Χ" .. 10] + MiaofaWX
			a3 = a2
		else
			m2 = JY.Wugong[wugong]["�ƶ���Χ" .. level]
			a2 = JY.Wugong[wugong]["ɱ�˷�Χ" .. level] + MiaofaWX
		end
	end
	--������� 
   if( match_ID(pid,9983) or JinGangBR(pid))   and wugong == 189 then
	  a1 = 0
	  m1 = 0
	  m2 = 8
    end
	--������
	if wugong == 187 then
	 a1 = 0
	 mi = 0
	 m2 = 7
	end
	--̫���񹦷�Χ���������仯
	--��תʱ��Χ���仯
	if Curr_NG(pid,171) and (wugong == 16 or wugong == 46 ) and WAR.PD["̫������"][pid] ~= nil and WAR.PD["̫������"][pid] > 0  and WAR.DZXY == 0 then
		if WAR.PD["̫������"][pid] > 600 then
			m1 = 0
			m2 = 4
			a1 = 3
			a2 = 4 + MiaofaWX
			a3 = a2
		elseif WAR.PD["̫������"][pid] > 500 then
			m1 = 0
			m2 = 4
			a1 = 3
			a2 = 3 + MiaofaWX
			a3 = a2			
		elseif WAR.PD["̫������"][pid] > 300 then
			a2 = a2 + 2
			a3 = a3 + 2
		else
			a2 = a2 + 1
			a3 = a3 + 1
		end
	end

	
	--��ڤ��������ϵ������
	if JY.Person[pid]["����"] == 335 and kfkind == 3  then
        mx =  1
		a2 = a2 + mx
		a3 = a2
     
	end	
	
	--���｣��������һ�������Χ����
	if wugong == 38 and level == 11 and TaohuaJJ(pid) then
		a2 = 8 + MiaofaWX
		a3 = a2 - 1
		a4 = a3 - 1
	end
	--��Ӣ���ƣ�����һ��������ƶ�
	if wugong == 12 and level == 11 and TaohuaJJ(pid) then
		m1 = 0
		m2 = 6
	end
	if wugong == 47 then
		m1 = 0
		m2 = 6
	end
	--�������ƶ�
	if  wugong == 45 then
		m1 = 0
		m2 = 4
	end
	
	--�����򻨣���Χ+1
	if wugong == 30 and PersonKF(pid,175) then
		a2 = a2 + 1
		a3 = a2
	end


	--��а�����ֶ�ѡ��Χ
	if wugong == 48 and level == 11 and inteam(pid) and WAR.AutoFight == 0 and WAR.DZXY == 0 then
		m1, m2, a1, a2, a3, a4 , a5, a6 = BiXieZhaoShi(pid,MiaofaWX)
	end

	
	--�������ֶ�ѡ����ʽ 
	if wugong == 106 and level == 11  and  inteam(pid)  and WAR.DZXY == 0 and WAR.AutoFight == 0 then
		m1, m2, a1, a2, a3, a4 , a5, a6 = JIUYANGZhaoShi(pid,MiaofaWX)
	end	
	--̫�����ֶ�ѡ��ϵ��
	if wugong == 102 and level == 11 and match_ID_awakened(pid, 38, 1)  and  inteam(pid) and WAR.AutoFight == 0 and WAR.DZXY == 0 then
		a6 = TaiXuanZhaoShi()
	end
	
	return m1, m2, a1, a2, a3, a4, a5 , a6

  
end

--��CC���ж������Ƿ�Ϊ���ѣ������ڲ��ڶ�
function isteam(p)
	local r = false
	if p == 0 then
		r = true
	end
    
	if CC.PersonExit[p] ~= nil then
		r = true
	end

	return r;
end

--�ж������Ƿ���ĳ���书
function PersonKF(p, kf)
	for i = 1, JY.Base["�书����"] do
		if JY.Person[p]["�书" .. i] <= 0 then
			return false;
		elseif JY.Person[p]["�书" .. i] == kf then
			return true
		end
	end
	return false
end

--�ж������Ƿ���ĳ���书�����ҵȼ�Ϊ��
function PersonKFJ(p, kf)
	for i = 1, JY.Base["�书����"] do
		if JY.Person[p]["�书" .. i] <= 0 then
			return false;
		elseif JY.Person[p]["�书" .. i] == kf and JY.Person[p]["�书�ȼ�" .. i] == 999 then
			return true
		end
	end
	return false
end

--�жϴ�������
function myrandom(p, id)
	--����Խ�ͣ�����Խ�ߣ����10
	p = p + math.modf((JY.Person[id]["�������ֵ"] - JY.Person[id]["����"])/100 + 1);	
	
	--����Խ�ߣ�����Խ�ߣ����10
	p = p + math.modf(JY.Person[id]["����"] / 10)
	
	--�ֳ�Ӣ+10
	if match_ID(id, 605) then
		p = p + 10
	end

	--�����߻�+20
	if WAR.PD["�߻�״̬"][id] == 1 then
		p = p + 20
	end

	--ÿ25��ʵս+1������20
	local jp = math.modf(JY.Person[id]["ʵս"] / 25 + 1)
	if jp > 20 then
		jp = 20
	end
	p = p + jp

	--ÿ500����+1�����20
	p = p + limitX(math.modf(JY.Person[id]["����"] / 500), 0, 20)
	
	--ÿ50�㹥����+1�����10
	p = p + limitX(math.modf(JY.Person[id]["������"] / 50), 0, 10)
	
	--ÿ50�������+1�����10
	p = p + limitX(math.modf(JY.Person[id]["������"] / 50), 0, 10)
	
	--ÿ50���Ṧ+1�����10
	p = p + limitX(math.modf(JY.Person[id]["�Ṧ"] / 50), 0, 10)
	
	--�����ж�����Ϊһ��
	local times = 1
	--������ҷ�
	if inteam(id) then
		--�ҷ��������Ӽ���
		p = p + JY.Base["��������"]
		--50%���ʶ����ж�
		if math.random(2) == 2 then
			times = 2
		end
		--ʯ����ض������ж�
		if match_ID(id, 38) and times == 1  then
			times = 2
		end
		--��ͨ �ض������ж�
		if id ==0 and times == 1 and JY.Base["��ͨ"] > 0 then
	    times = 2
		end		
	--NPCĬ��Ϊ�����ж��Ҽ���+60
	else
		times = 3
		p = p + 50
	end

	for i = 1, times do
		local bd = math.random(120)
		if bd <= p then
			return true
		end
	end
	return false
end


--�Զ�ѡ�����
function War_AutoSelectEnemy()
	local enemyid = War_AutoSelectEnemy_near()
	WAR.Person[WAR.CurID]["�Զ�ѡ�����"] = enemyid
	return enemyid
end

--ѡ���������
function War_AutoSelectEnemy_near()
	War_CalMoveStep(WAR.CurID, 100, 1)			--���ÿ��λ�õĲ���
	local maxDest = math.huge
	local nearid = -1
	for i = 0, WAR.PersonNum - 1 do		--������������ĵ���
		if WAR.Person[WAR.CurID]["�ҷ�"] ~= WAR.Person[i]["�ҷ�"] and WAR.Person[i]["����"] == false then
			local step = GetWarMap(WAR.Person[i]["����X"], WAR.Person[i]["����Y"], 3)
			if step < maxDest then
				nearid = i
				maxDest = step
			end
		end
	end
	return nearid
end

--ս���м���������
function NewWARPersonZJ(id, dw, x, y, life, fx)
	WAR.Person[WAR.PersonNum]["������"] = id
	WAR.Person[WAR.PersonNum]["�ҷ�"] = dw
	WAR.Person[WAR.PersonNum]["����X"] = x
	WAR.Person[WAR.PersonNum]["����Y"] = y
	WAR.Person[WAR.PersonNum]["����"] = life
	WAR.Person[WAR.PersonNum]["�˷���"] = fx
	WAR.Person[WAR.PersonNum]["��ͼ"] = WarCalPersonPic(WAR.PersonNum)
	--lib.PicLoadFile(string.format(CC.FightPicFile[1], JY.Person[id]["ͷ�����"]), string.format(CC.FightPicFile[2], JY.Person[id]["ͷ�����"]), 4 + WAR.PersonNum)
	SetWarMap(x, y, 2, WAR.PersonNum)
	SetWarMap(x, y, 5, WAR.Person[WAR.PersonNum]["��ͼ"])
    SetWarMap(x, y, 10, JY.Person[WAR.Person[WAR.PersonNum]["������"]]['ͷ�����'])
	WAR.PersonNum = WAR.PersonNum + 1
end

--�޾Ʋ������ж��ϻ��õĺ���
function between(num_1, num_2, num_3, flag)
    if not flag then
		flag = 0
    end
    if num_3 < num_2 then
		num_2, num_3 = num_3, num_2
    end
    if flag == 0 and num_2 < num_1 and num_1 < num_3 then
		return true
    elseif flag == 1 and num_2 <= num_1 and num_1 <= num_3 then
		return true
    else
		return false
    end
end
--�޾Ʋ�����������ܷ������˺��ж�
function First_strike_dam_DG(pid, eid)
	local dam;
	local YJ_dif = TrueYJ(pid)*1.2 - TrueYJ(eid)
	local p_wc = JY.Person[pid]["��ѧ��ʶ"]
	local e_wc = JY.Person[eid]["��ѧ��ʶ"]
	if p_wc < e_wc then
		p_wc = e_wc
	end
	dam = (JY.Person[pid]["������"]-JY.Person[eid]["������"])+(p_wc*1.2-e_wc)+(getnl(pid)/50*1.2-getnl(eid)/50)
	dam = math.modf(dam + YJ_dif)
	return dam
end

--�˺���ʽ�е���������ǰ����������������������
function getnl(id)
	return (JY.Person[id]["����"] * 2 + JY.Person[id]["�������ֵ"]) / 3
end

--�޾Ʋ�����Ѫ����������
function Health_in_Battle()
	for i = 0, WAR.PersonNum - 1 do
		local pid = WAR.Person[i]["������"]

		--��һ�����������ظ�����
		--if JY.Person[pid]["Ѫ������"] > 1 and WAR.HP_Bonus_Count[pid] == nil then
			--JY.Person[pid]["�������ֵ"] = JY.Person[pid]["�������ֵ"] * JY.Person[pid]["Ѫ������"]
			--JY.Person[pid]["����"] = JY.Person[pid]["����"] * JY.Person[pid]["Ѫ������"]
			--WAR.HP_Bonus_Count[pid] = 1
		--end
        
		if WAR.ZDDH == 354 and WAR.Person[i]["�ҷ�"] then
			if JY.Person[pid]["�츳�ڹ�"] > 0 then
				JY.Person[pid]["�����ڹ�"] = JY.Person[pid]["�츳�ڹ�"]
			end
			if JY.Person[pid]["�츳�Ṧ"] > 0 then
			JY.Person[pid]["�����Ṧ"] = JY.Person[pid]["�츳�Ṧ"]
			end
		end
        
		--�޾Ʋ��������ҷ��Զ��˹�
		if inteam(pid) == false or WAR.Person[i]["�ҷ�"] == false then
			if JY.Person[pid]["�����ڹ�"] == 0 and (JY.Person[pid]["����ֽ�"] > 5 )  then
				JY.Person[pid]["�����ڹ�"] = 219 
			end
			if JY.Person[pid]["�����ڹ�"] == 0 and JY.Person[pid]["����ֽ�"] < 5 then
				JY.Person[pid]["�����ڹ�"] = 219 
			end				
			if JY.Person[pid]["�츳�ڹ�"] > 0 then
				JY.Person[pid]["�����ڹ�"] = JY.Person[pid]["�츳�ڹ�"]
			end
			if JY.Person[pid]["�츳�Ṧ"] > 0 then
			JY.Person[pid]["�����Ṧ"] = JY.Person[pid]["�츳�Ṧ"]
			end		
		end
	end
end

--�޾Ʋ�����Ѫ����ԭ����
function Health_in_Battle_Reset()
	--for i = 0, WAR.PersonNum - 1 do
	--	local pid = WAR.Person[i]["������"]
	--	if JY.Person[pid]["Ѫ������"] > 1 and WAR.HP_Bonus_Count[pid] ~= nil then
	--		JY.Person[pid]["�������ֵ"] = JY.Person[pid]["�������ֵ"] / JY.Person[pid]["Ѫ������"]
	--		WAR.HP_Bonus_Count[pid] = nil
	--	end
	--end
end

--ս���в鿴�з�������Ϣ
function MapWatch()
	local x = WAR.Person[WAR.CurID]["����X"];
	local y = WAR.Person[WAR.CurID]["����Y"];
	WAR.ShowHead = 0
	War_CalMoveStep(WAR.CurID,128,1);
	Cat('ʵʱ��Ч����')
	WarDrawMap(1,x,y);
	ShowScreen();
	lib.Delay(CC.BattleDelay)
	x,y=War_SelectMove()
	if x == nil then
		return
	end
	WAR.ShowHead = 1
end

--�޾Ʋ������ȴ�ָ��
function War_Wait()
	local id = WAR.Person[WAR.CurID]["������"]
	WAR.Wait[id] = 1
	Cls()
  	CurIDTXDH(WAR.CurID, 72, 1, "�Ż�����", LightGreen, 15)
	--������ȴ�ʱ����
	if match_ID(id, 185) then
		WAR.Actup[id] = 2
	end
  	return 1
end

--����ָ��
function War_Focus()
	local id = WAR.Person[WAR.CurID]["������"]
	WAR.Focus[id] = 1
	Cls()
  	CurIDTXDH(WAR.CurID, 151, 1, "�����һ", C_GOLD)
  	return 20
end

--�޾Ʋ���������
function War_Retreat()
	local id = WAR.Person[WAR.CurID]["������"]
	local r = JYMsgBox(JY.Person[id]["����"], "ȷ��Ҫ�ҳ�����", {"��","��"}, 2, JY.Person[id]["������"])
	if r == 2 then
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["�ҷ�"] then
			   WAR.Person[i]["����"] = true
			end		
		end 
		return 1;
	end
end

--�޾Ʋ�������̬Ѫ����ʾ
function HP_Display_When_Idle()
    local x0 = WAR.Person[WAR.CurID]["����X"];
    local y0 = WAR.Person[WAR.CurID]["����Y"];
	for k = 0, WAR.PersonNum - 1 do
		local tmppid = WAR.Person[k]["������"]
		if WAR.Person[k]["����"] == false then
			local dx = WAR.Person[k]["����X"] - x0
			local dy = WAR.Person[k]["����Y"] - y0

			local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
			local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
	 
			local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)
					ry = ry - hb - CC.YScale*7
					
			local pid = WAR.Person[k]["������"]

			local Color = RGB(238,44, 44)
			--local Color1 = RGB(30, 144, 255)
			
			local HP_MAX = JY.Person[pid]["�������ֵ"]
            local MP_MAX = JY.Person[pid]["�������ֵ"]
			local PH_MAX = 100		
			local Current_HP = limitX(JY.Person[pid]["����"],0,HP_MAX)
			local Current_MP = limitX(JY.Person[pid]["����"],0,MP_MAX)
			local Current_PH = limitX(JY.Person[pid]["����"],0,PH_MAX)	
			--�Ѿ�NPC��ʾΪ��ɫѪ��
			if WAR.Person[k]["�ҷ�"] == true then
				Color = RGB(0, 238, 0)
			end
			
			lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/9, rx+CC.XScale*1.4, ry-CC.YScale*30/17,C_GRAY22)	--����
			if HP_MAX > 0 then
				lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/9, rx-CC.XScale*1.4+(Current_HP/HP_MAX)*(2.8*CC.XScale), ry-CC.YScale*30/17, Color)  --����
			end
			DrawBox3(rx-CC.XScale*1.4, ry-CC.YScale*20/9, rx+CC.XScale*1.4, ry-CC.YScale*30/17, C_BLACK)

			lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/11+0.5, rx+CC.XScale*1.4, ry-CC.YScale*30/21,C_GRAY22)	--����			
			if MP_MAX > 0 then
				lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/11+0.5, rx-CC.XScale*1.4+(Current_MP/MP_MAX)*(2.8*CC.XScale), ry-CC.YScale*30/21, C_BLUE)  --����
			end
			DrawBox3(rx-CC.XScale*1.4, ry-CC.YScale*20/11+0.5, rx+CC.XScale*1.4, ry-CC.YScale*30/21, C_BLACK)			

			lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/13+1, rx+CC.XScale*1.4, ry-CC.YScale*60/54+1,C_GRAY22)	--����			
			lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/13+1, rx-CC.XScale*1.4+(Current_PH/PH_MAX)*(2.8*CC.XScale), ry-CC.YScale*60/54+1, S_Yellow)  --����
			DrawBox3(rx-CC.XScale*1.4, ry-CC.YScale*20/13+1, rx+CC.XScale*1.4, ry-CC.YScale*60/54+1, C_BLACK)
		end
	end
end

--�޾Ʋ����������Ѫ��ʾ
function HP_Display_When_Hit(ssxx)
    local x0 = WAR.Person[WAR.CurID]["����X"];
    local y0 = WAR.Person[WAR.CurID]["����Y"];
	--��Ѫ������ʾ			
	ssxx = ssxx - 4
	for k = 0, WAR.PersonNum - 1 do
		local tmppid = WAR.Person[k]["������"]
		--Ѫ���б仯����ʾ
		if WAR.Person[k]["����"] == false and WAR.Person[k]["��������"] ~= nil and WAR.Person[k]["��������"] ~= 0 then
			local dx = WAR.Person[k]["����X"] - x0
			local dy = WAR.Person[k]["����Y"] - y0

			local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
			local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
	 
			local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)
					ry = ry - hb - CC.YScale*7
					
			local pid = WAR.Person[k]["������"]

			local Color = RGB(238,44, 44)
			--local Color1 = RGB(30, 144, 255)
			
			--�����Ѫ
			local HP_MAX = JY.Person[pid]["�������ֵ"]
			
			local HP_AfterHit = JY.Person[pid]["����"]
			
			if HP_AfterHit < 0 then
				HP_AfterHit = 0
			end
				
			local HP_BeforeHit = WAR.Person[k]["Life_Before_Hit"] or 0

			local HP_Loss = HP_BeforeHit - HP_AfterHit
			
			local Gradual_HP_Loss;
			local Gradual_HP_Display;
			
			Gradual_HP_Loss = HP_Loss*(ssxx/11)
			Gradual_HP_Display = HP_BeforeHit - Gradual_HP_Loss			


			
			
			--�Ѿ�NPC��ʾΪ��ɫѪ��
			if WAR.Person[k]["�ҷ�"] == true then
				Color = RGB(0, 238, 0)
			end
			
			lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/9, rx+CC.XScale*1.4, ry-CC.YScale*15/9,grey21)	--����
			
			lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/9, rx-CC.XScale*1.4+(HP_AfterHit/HP_MAX)*(2.8*CC.XScale), ry-CC.YScale*15/9, Color)  --����
			
			--��Ѫ��ʾ
			if HP_Loss > 0 then
				lib.FillColor(rx-CC.XScale*1.4+(HP_AfterHit/HP_MAX)*(2.8*CC.XScale), ry-CC.YScale*20/9, rx-CC.XScale*1.4+(Gradual_HP_Display/HP_MAX)*(2.8*CC.XScale), ry-CC.YScale*15/9, Color)  --ʧȥ����
			end
		
			DrawBox3(rx-CC.XScale*1.4, ry-CC.YScale*20/9, rx+CC.XScale*1.4, ry-CC.YScale*15/9, C_BLACK)
		end
	end
end

--����̩̹����ս����Ѫ��������
function DrawBox3(x1, y1, x2, y2, color)
	lib.DrawRect(x1, y1, x2, y1, color)
	lib.DrawRect(x1, y2, x2, y2, color)
	lib.DrawRect(x1, y1, x1, y2, color)
	lib.DrawRect(x2, y1, x2, y2, color)
	--�޾Ʋ����������������ķָ���
	--lib.DrawRect(x1, y1+(y2-y1)/2+1, x2, y1+(y2-y1)/2+1, color)
end

--��ʾ���ж�����ѡ���ս�������
function WarSelectTeam_Enhance()
	if JY.Restart == 1 then
		do return end
	end
	local T_Num=GetTeamNum();
	--�޾Ʋ������߶���3Ϊ��λ����
	local h_factor = 3
	if T_Num > 12 then
		h_factor = 15
	elseif T_Num > 9 then
		h_factor = 12
	elseif T_Num > 6 then
		h_factor = 9
	elseif T_Num > 3 then
		h_factor = 6
	end
	local p={};
	local pic_w=CC.ScreenW/6--160;
	local pic_h=CC.ScreenW/6*3/4--128;
	local width=pic_w*3+CC.DefaultFont*5+4*8;
	local height=math.max((h_factor+2)*(CC.DefaultFont+4)+4*3,pic_h*math.modf((h_factor+1)/4))+CC.FontBig;
	local x=(CC.ScreenW-width)/2;
	local y=(CC.ScreenH-height-4*2)/2+CC.FontBig/2+8;
	local x0=x+4*4;
	local x1=x0+4;
	local y1=(CC.ScreenH-((T_Num+2)*(CC.DefaultFont+4)+4*3))/2;
	local x2=x0+4*3+CC.DefaultFont*5+pic_w/2
	local y2=y;
	local ts=(width-(CC.FontBig*4+16)*2)/3;
	local tx1=x+ts+4;
	local tx2=tx1+(CC.FontBig*4+16)+ts;
	local ty=y+pic_h+30+CC.DefaultFont;
	
    if WAR.ZDDH == 354 then 
        local x = 20
        local y = 17
        for i = 1,#CC.HSLJ do
            local id = CC.HSLJ[i]
            WAR.Person[WAR.PersonNum]["������"] = id
            WAR.Person[WAR.PersonNum]["�ҷ�"] = true
            WAR.Person[WAR.PersonNum]["����X"] = x
            WAR.Person[WAR.PersonNum]["����Y"] = y
            WAR.Person[WAR.PersonNum]["����"] = false
            WAR.Person[WAR.PersonNum]["�˷���"] = 3
            WAR.PersonNum = WAR.PersonNum + 1
            x = x + 1
            if x == 34 then 
                x = 20
                y = y + 2
            end
        end
        return
    end
    
	--��ͨģʽ
	if JY.Base["��ͨ"] > 0 then
		WAR.Data["�Զ�ѡ���ս��1"] = 0
		for i = 2, 6 do
			WAR.Data["�Զ�ѡ���ս��" .. i] = -1
		end
	end
	
	--���õı���ͼ
	--û���Զ�ѡ���ս��ʱ����ʾ
	--�����´ﺣս�����ж�
	if WAR.Data["�Զ�ѡ���ս��1"] == -1 and not (WAR.ZDDH == 92 and GetS(87,31,33,5) == 1) then
		Clipped_BgImg((CC.ScreenW - width) / 2,(CC.ScreenH - height) / 2,(CC.ScreenW + width) / 2,(CC.ScreenH + height) / 2,1000)
		Clipped_BgImg((CC.ScreenW - (CC.DefaultFont+4)*4) / 2,(CC.ScreenH - height) / 2-(CC.DefaultFont+4)/2,
		(CC.ScreenW + (CC.DefaultFont+4)*4) / 2,(CC.ScreenH - height) / 2+(CC.DefaultFont+4)/2,1000)
	end
	for i=1,T_Num do
		local pid=JY.Base["����"..i];
		if pid <0 then
			break;
		end
	  
	  --�������������´ﺣ
		if WAR.ZDDH == 92 and GetS(87,31,33,5) == 1 then
			WAR.Data["�Զ�ѡ���ս��1"] = 0;
			WAR.Data["�ҷ�X1"] = 33
			WAR.Data["�ҷ�Y1"] = 24
		end
		
		--ս���ɣ�����������ڶ����������س�ս
		if WAR.ZDDH == 253 and inteam(631) then
			WAR.Data["�ֶ�ѡ���ս��2"] = 631
		end
		
		--��������������ս
		if (WAR.ZDDH == 272 or WAR.ZDDH == 273) and JY.Base["����"] == 58 then
			WAR.Data["�Զ�ѡ���ս��2"] = 59
		end
		
		for i = 1, 6 do
			local id = WAR.Data["�Զ�ѡ���ս��" .. i]
			if id >= 0 then
				--�����������������ǻ�ȡ��ǿ�Ƴ�ս�Ķ���
				if id == JY.Base["����"] then
					WAR.Person[WAR.PersonNum]["������"] = 0
				else
					WAR.Person[WAR.PersonNum]["������"] = id
				end
				WAR.Person[WAR.PersonNum]["�ҷ�"] = true
				WAR.Person[WAR.PersonNum]["����X"] = WAR.Data["�ҷ�X" .. i]
				WAR.Person[WAR.PersonNum]["����Y"] = WAR.Data["�ҷ�Y" .. i]
				WAR.Person[WAR.PersonNum]["����"] = false
				WAR.Person[WAR.PersonNum]["�˷���"] = 2
				--�޾Ʋ���������ս����ʼ����
				--ս����
				if WAR.ZDDH == 259 then
					WAR.Person[WAR.PersonNum]["�˷���"] = 1
				end
				--˫������ֹ
				if WAR.ZDDH == 273 then
					WAR.Person[WAR.PersonNum]["�˷���"] = 1
				end
				--���������
				if WAR.ZDDH == 275 then
					WAR.Person[WAR.PersonNum]["�˷���"] = 0
				end
				--ս����
				if WAR.ZDDH == 75 then
					WAR.Person[WAR.PersonNum]["�˷���"] = 0
				end
				--�ɸ�
				if WAR.ZDDH == 278 then
					WAR.Person[WAR.PersonNum]["�˷���"] = 0
				end
				--������������
				if WAR.ZDDH == 279 then
					WAR.Person[WAR.PersonNum]["�˷���"] = 0
				end
				--��������
				if WAR.ZDDH == 293 then
					WAR.Person[WAR.PersonNum]["�˷���"] = 0
				end
				--��ڤ����
				if WAR.ZDDH == 295 then
					WAR.Person[WAR.PersonNum]["�˷���"] = 0
				end
				--��������Ⱥ
				if WAR.ZDDH == 298 then
					WAR.Person[WAR.PersonNum]["�˷���"] = 1
				end
				--����а
				if WAR.ZDDH == 170 then
					WAR.Person[WAR.PersonNum]["�˷���"] = 0
				end
				WAR.PersonNum = WAR.PersonNum + 1
				WAR.MCRS = WAR.MCRS + 1
			end
		end

		if WAR.PersonNum > 0 and WAR.ZDDH ~= 235 then
			return 
		end

		--lib.PicLoadFile(string.format(CC.FightPicFile[1],JY.Person[pid]["ͷ�����"]),
		--string.format(CC.FightPicFile[2],JY.Person[pid]["ͷ�����"]), 4+i);
		local n=0;
		local m=0;
		for j=1,5 do
			if JY.Person[pid]['���ж���֡��'..j]>0 then
				if j>1 then
					m=j;
					break;
				end
				n=n+JY.Person[pid]['���ж���֡��'..j]
			end
		end
		p[i]= {id=pid, name=JY.Person[pid]["����"]; 
        zid = JY.Person[pid]["ͷ�����"]; 
		Pic=n*8+JY.Person[pid]['���ж���֡��'..m]*6, PicNum=JY.Person[pid]['���ж���֡��'..m], idx=0, 
		x=x2+((i+3)%4)*pic_w, y=y2+math.modf((i+3)/4)*pic_h, x=x2+((i+2)%3)*pic_w, y=y2+math.modf((i+2)/3)*pic_h, picked=0,
		};
		--�޾Ʋ�����ǿ�Ƴ�ս�Ķ���
		for j = 1, 6 do
			if WAR.Data["�ֶ�ѡ���ս��" .. j] == p[i].id then
				p[i].picked = 1
				WAR.MCRS = WAR.MCRS + 1
			end
		end
	end
	
	--ս����
	if WAR.ZDDH == 253 then
		WAR.MCRS = WAR.MCRS + 3
	end
	
	--��ң���� ��ع��� ̫��ʫ�� ��Ĺ��ɼ �����ɾ�
	--�޶�1��
	if WAR.ZDDH == 281 or WAR.ZDDH == 283 or WAR.ZDDH == 284 or WAR.ZDDH == 285 or WAR.ZDDH == 286 then
		WAR.MCRS = WAR.MCRS + 5
	end
	
	--�������
	--�޶�2��
	if WAR.ZDDH == 280 then
		WAR.MCRS = WAR.MCRS + 4
	end
 
	p[0]={name="ȫ��ѡ��"};

	if T_Num>6 then
		p[0]={name="�Զ�ѡ��"}
	end

	p[T_Num+1]={name="��ʼս��"};
	local leader=-1;
	--�޾Ʋ�����ǿ�Ƴ�ս��Ԥ��leader
	for i=1,T_Num do
		if p[i].picked == 1 then
			leader = i
			break
		end
	end
	DrawBoxTitle(width,height,'��ս׼��',C_ORANGE);
	local select=1;
	local sid=lib.SaveSur(0,0,CC.ScreenW,CC.ScreenH);
	local function redraw(zdrs)
		lib.LoadSur(sid,0,0);
		DrawBox(x0,y1,x0+CC.DefaultFont*5+4*2,y1+CC.DefaultFont*(T_Num+2)+4*(T_Num+3),C_WHITE);
		for i=0,T_Num+1 do
			local str=p[i].name;
			--ѡ��ʱ��������ʾ
			--С��7�ˣ�����ǰ��ʾ�̱�ʾ��ѡ��
			--���ڵ���7�ˣ�����ǰ��ʾ����ʾ��Ҫȡ�����ɿ�ʼս��
			if i > 0 and i < T_Num+1 and p[i].picked > 0 then
				if zdrs < 7 then
					str="��"..str;
				else
					str="��"..str
				end
			--δѡ�е�ֻ��ʾ����
			else
				str=" "..str;
			end
			if select==i then
				lib.Background(x1,y1+(CC.DefaultFont+4)*(i)+4,x1+CC.DefaultFont*5,y1+(CC.DefaultFont+4)*(i+1),128,C_ORANGE)
				DrawString(x1,y1+(CC.DefaultFont+4)*(i)+4,str,C_WHITE,CC.DefaultFont,C_ORANGE);
			elseif i>0 and i<=T_Num then
				DrawString(x1,y1+(CC.DefaultFont+4)*(i)+4,str,C_ORANGE,CC.DefaultFont);
			else
				DrawString(x1,y1+(CC.DefaultFont+4)*(i)+4,str,C_GOLD,CC.DefaultFont);
			end
		end
		for i=1,T_Num do
			local color;
			if p[i].picked > 0 then
				--DrawString(p[i].x-CC.DefaultFont,p[i].y-CC.DefaultFont/2,"��ս",C_WHITE,CC.DefaultFont*2/3)
				color=C_WHITE;
				lib.PicLoadCache(p[i].zid+101,p[i].Pic+p[i].idx*2,p[i].x,p[i].y)
				p[i].idx=p[i].idx+1;
				if p[i].idx>=p[i].PicNum then
					p[i].idx=0;
				end
			else
				color=M_Gray;
				lib.PicLoadCache(p[i].zid+101,p[i].Pic,p[i].x,p[i].y)
				lib.PicLoadCache(p[i].zid+101,p[i].Pic,p[i].x,p[i].y,6,180)
			end
		end
	end
	
	--local zdrs=0
	while true do
		if JY.Restart == 1 then
			break
		end
		redraw(WAR.MCRS);
		ShowScreen();
		lib.Delay(65);
		local k=lib.GetKey();
		if k==VK_UP then
			select=select-1;
		elseif k==VK_DOWN then
			select=select+1;
		elseif k==VK_SPACE or k==VK_RETURN then
			if select==0 then
				if p[0].name=="ȫ��ѡ��" or p[0].name=="�Զ�ѡ��" then
					local zrs=T_Num
					if zrs>6 then
						zrs=6
					end
					for i=1,zrs do
						if p[i].picked == 0 then
							p[i].picked=2;
							WAR.MCRS=WAR.MCRS+1
						end
					end
					if leader<0 then
						leader=1;
					end
					p[0].name="ȫ��ȡ��";
				elseif p[0].name=="ȫ��ȡ��" then
					for i=1,T_Num do
						if p[i].picked == 2 then
							p[i].picked=0;
							WAR.MCRS=WAR.MCRS-1
						end
					end
					leader=-1;
					--�޾Ʋ�����ǿ�Ƴ�ս��Ԥ��leader
					for i=1,T_Num do
						if p[i].picked == 1 then
							leader = i
							break
						end
					end
					p[0].name="ȫ��ѡ��"

					if T_Num>6 then
						p[0].name="�Զ�ѡ��"
					end
				end
			elseif select==T_Num+1 then
				if leader<0 then
					select=1;
				elseif WAR.MCRS>6 then
					select=1
				else
					local px={}
					local wz=0
					for i=1,T_Num do
						if p[i].picked > 0 then
							wz=wz+1
							px[wz]=i
						end
					end

					for i=1,wz do
						if px[i]~=nil then
							WAR.Person[WAR.PersonNum]["������"]=JY.Base["����" ..px[i]]
							WAR.Person[WAR.PersonNum]["�ҷ�"]=true
							WAR.Person[WAR.PersonNum]["����X"]=WAR.Data["�ҷ�X"..i]
							WAR.Person[WAR.PersonNum]["����Y"]=WAR.Data["�ҷ�Y"..i]
							WAR.Person[WAR.PersonNum]["����"]=false
							WAR.Person[WAR.PersonNum]["�˷���"]=2
							--�޾Ʋ���������ս����ʼ����
							--ս����
							if WAR.ZDDH == 259 then
								WAR.Person[WAR.PersonNum]["�˷���"] = 1
							end
							--˫������ֹ
							if WAR.ZDDH == 273 then
								WAR.Person[WAR.PersonNum]["�˷���"] = 1
							end
							--���������
							if WAR.ZDDH == 275 then
								WAR.Person[WAR.PersonNum]["�˷���"] = 0
							end
							--ս����
							if WAR.ZDDH == 75 then
								WAR.Person[WAR.PersonNum]["�˷���"] = 0
							end
							--�ɸ�
							if WAR.ZDDH == 278 then
								WAR.Person[WAR.PersonNum]["�˷���"] = 0
							end
							--������������
							if WAR.ZDDH == 279 then
								WAR.Person[WAR.PersonNum]["�˷���"] = 0
							end
							--��������
							if WAR.ZDDH == 293 then
								WAR.Person[WAR.PersonNum]["�˷���"] = 0
							end
							--���ĵ�������
							if WAR.ZDDH == 355 then
								WAR.Person[WAR.PersonNum]["�˷���"] = 0
							end							
							--��ڤ����
							if WAR.ZDDH == 295 then
								WAR.Person[WAR.PersonNum]["�˷���"] = 0
							end
							--��������Ⱥ
							if WAR.ZDDH == 298 then
								WAR.Person[WAR.PersonNum]["�˷���"] = 1
							end
							--����а
							if WAR.ZDDH == 170 then
								WAR.Person[WAR.PersonNum]["�˷���"] = 0
							end
							WAR.PersonNum=WAR.PersonNum+1
						end
					end
					break;
				end
			else
				if p[select].picked == 2 then
					p[select].picked=0;
					WAR.MCRS=WAR.MCRS-1
					if leader==select then
						leader=-1;
						for i=1,T_Num do
							if p[i].picked > 0 then
								leader=i;
								break;
							end
						end
					end
					if leader==-1 then
						p[0].name="ȫ��ѡ��"

						if T_Num>6 then
							p[0].name="�Զ�ѡ��"
						end
					end
				elseif p[select].picked == 0 then
					p[select].picked=2;
					WAR.MCRS=WAR.MCRS+1
					if leader<0 then
						leader=select;
					end
					for i=1,T_Num do
						if p[i].picked == 0 then
							break;
						end
						if i==T_Num then
							p[0].name="ȫ��ȡ��";
						end
					end
				end
			end
		end
		if select<0 then
			select=T_Num+1;
		elseif select>T_Num+1 then
			select=0;
		end
	end
	lib.FreeSur(sid);
end

--������Ӱ
function kuihuameiying()
	local x, y
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] then
			x, y = WAR.Person[i]["����X"], WAR.Person[i]["����Y"]
			break
		end
	end
	if x == nil then 
		return false
	end
	
	War_CalMoveStep(WAR.CurID, 100, 1)
	
	local function vacant(x,y)
		local r = true
		if GetWarMap(x, y, 3) == 255 then 
			r = false
		end
		if lib.GetWarMap(x, y, 2) > 0 or lib.GetWarMap(x, y, 5) > 0 then
			r = false
	    elseif CC.SceneWater[lib.GetWarMap(x, y, 0)] ~= nil then
	       	r = false
	    end
		if x < 1 or x > 63 then
			r = false
		end
		if y < 1 or y > 63 then
			r = false
		end
		return r
	end
	local telx, tely = 0, 0
	local can_tele = 0
	for i = -5, 5 do
		for j = -5, 5 do
			if vacant(x+i,y+j) then
				telx, tely = x+i, y+j
				can_tele = 1
				break
			end
		end
	end
	if can_tele == 1 then
		WarDrawMap(0)
		CurIDTXDH(WAR.CurID, 120, 1, "������Ӱ", C_GOLD)
		lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, -1)
		lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, -1)
        lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, -1)
		WarDrawMap(0)
		WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"] = telx, tely
		WarDrawMap(0)
		CurIDTXDH(WAR.CurID, 120, 1, "������Ӱ", C_GOLD)
		lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, WAR.Person[WAR.CurID]["��ͼ"])
		lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, WAR.CurID)
        SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, JY.Person[WAR.Person[WAR.CurID]["������"]]['ͷ�����'])
        
		WarDrawMap(0)
		return true
	else
		return false
	end
end

--��а��ʽ
function BiXieZhaoShi(id,MiaofaWX)
	WAR.BXZS = 0
	if not WAR.BXLQ[id] then
		WAR.BXLQ[id] = {0,0,0,0,0,0}
	end
	local zs={
	{name="ָ���а",Usable=true,m1=1,m2=1,a1=1,a2=3+MiaofaWX,a3=3+MiaofaWX},
	{name="���ഩ��",Usable=true,m1=3,m2=1,a1=10,a2=8+MiaofaWX,a3=7+MiaofaWX,a4=6+MiaofaWX},
	{name="��������",Usable=true,m1=0,m2=0,a1=5,a2=6+MiaofaWX,a3=3+MiaofaWX},
	{name="��ظ��Ŀ",Usable=true,m1=0,m2=5,a1=2,a2=4+MiaofaWX},
	{name="ɨ��Ⱥħ",Usable=true,m1=3,m2=1,a1=11,a2=6+MiaofaWX},
	{name="��������",Usable=true,m1=0,m2=6,a1=3,a2=3+MiaofaWX,a3=3+MiaofaWX},
	}
	local size = CC.DefaultFont
	--local surid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)
	local m1, m2, a1, a2, a3, a4, a5 ,a6
	local choice = 1
	if not PersonKF(id,105) then
		for i = 3, 6 do
			zs[i].Usable=false
		end
	end
	while true do
		if JY.Restart == 1 then
			break
		end
		Cat('ʵʱ��Ч����')
		Cls()
		for i = 1, #zs do
			lib.LoadPNG(91, 17 * 2 , 510, 118+i*50, 1)
			local color = C_WHITE
			if WAR.BXLQ[id][i] > 0 then
				zs[i].Usable=false
			end
			if zs[i].Usable==false then
				color = M_Gray
				if i == choice then
					DrawString(680, 122+i*50, "X", C_RED, size)
				end
			end
			if i == choice then
				color = C_GOLD
			end
			DrawString(520, 123+i*50, i, color, size*0.8)
			DrawString(551, 122+i*50, zs[i].name, color, size)
		end
		
		lib.LoadPNG(91, 15 * 2 , 480, 500, 1)
		DrawString(500, 520, "��ʽ������"..CC.KFMove[48][choice][2], C_WHITE, size)
		if WAR.BXCD[choice] == 0 or match_ID(id, 36) then
			DrawString(500, 570, "��ȴʱ�䣺��", C_WHITE, size)
		else
			DrawString(500, 570, "��ȴʱ�䣺"..WAR.BXCD[choice].."�غ�", C_WHITE, size)
		end
		if choice > 2 and not PersonKF(id,105) then
			DrawString(500, 620, "ϰ�ÿ����񹦺󷽿�ʹ��", C_WHITE, size)
		elseif WAR.BXLQ[id][choice] > 0 then
			DrawString(500, 620, "��ȴ�У�"..WAR.BXLQ[id][choice].."�غϺ���ٴ�ʹ��", C_WHITE, size)

		end
		ShowScreen()
		lib.Delay(CC.BattleDelay)
		local keyPress, ktype, mx, my = lib.GetKey()
		--lib.Delay(CC.Frame)
		
		if keyPress==VK_SPACE or keyPress==VK_RETURN then
			if zs[choice].Usable then
				WAR.BXZS = choice
				m1, m2, a1, a2, a3, a4, a5 = zs[choice].m1, zs[choice].m2, zs[choice].a1, zs[choice].a2, zs[choice].a3, zs[choice].a4, zs[choice].a5 , zs[choice].a6
				break
			end
		elseif keyPress == VK_ESCAPE or ktype == 4 then
		    a6 = 0
			break
		elseif keyPress == VK_UP then
			choice = choice - 1
			if choice < 1 then
				choice = #zs
			end
		elseif keyPress == VK_DOWN then
			choice = choice + 1
			if choice > #zs then
				choice = 1
			end
		elseif keyPress >= 49 and keyPress <= 57 then
			local input = keyPress - 48
			if input <= #zs and zs[input].Usable then
				choice = input
				WAR.BXZS = choice
				m1, m2, a1, a2, a3, a4, a5 = zs[choice].m1, zs[choice].m2, zs[choice].a1, zs[choice].a2, zs[choice].a3, zs[choice].a4, zs[choice].a5 , zs[choice].a6
				break
			end
		end
	end
	return m1, m2, a1, a2, a3, a4, a5 ,a6
end

--������ʽ
function JIUYANGZhaoShi(id,MiaofaWX)
	WAR.JYZS = 0
	if not WAR.JYLQ[id] then
		WAR.JYLQ[id] = {0,0,0}
	end
	local zs={
   {name="��ǿ����ǿ������ɽ��",Usable=true,m1=0,m2=6,a1=3,a2=3+MiaofaWX,a3=3+MiaofaWX},
   {name="���������ᣬ�����մ�",Usable=true,m1=0,m2=6,a1=3,a2=3+MiaofaWX,a3=3+MiaofaWX},
   {name="�������Զ�һ��������",Usable=true,m1=0,m2=6,a1=3,a2=3+MiaofaWX,a3=3+MiaofaWX},
	}
	local size = CC.DefaultFont
	--local surid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)
	local m1, m2, a1, a2, a3, a4, a5,a6
	local choice = 1

	while true do
		if JY.Restart == 1 then
			break
		end
		Cat('ʵʱ��Ч����')
		Cls()

		for i = 1, #zs do
			lib.LoadPNG(91, 17 * 2 , 510, 118+i*50, 1)
			local color = C_WHITE
			if WAR.JYLQ[id][i] > 0 then
				zs[i].Usable=false
			end
			if zs[i].Usable==false then
				color = M_Gray
				if i == choice then
					DrawString(680, 122+i*50, "X", C_RED, size)
				end
			end
			if i == choice then
				color = C_GOLD
			end
			DrawString(520, 123+i*50, i, color, size*0.8)
			DrawString(551, 122+i*50, zs[i].name, color, size)
		end
		
		lib.LoadPNG(91, 16 * 2 , 480, 500, 1)
		DrawString(500, 570, "��ʽ������"..CC.KFMove[106][choice][2], C_WHITE, size)
		if WAR.JYCD[choice] == 0  then
			DrawString(500, 620, "��ȴʱ�䣺��", C_WHITE, size)
		else
			DrawString(500, 620, "��ȴʱ�䣺"..WAR.JYCD[choice].."�غ�", C_WHITE, size)
		end
		if  WAR.JYLQ[id][choice] > 0 then
			DrawString(500, 670, "��ȴ�У�"..WAR.JYLQ[id][choice].."�غϺ���ٴ�ʹ��", C_WHITE, size)
		end
        if CC.KFMove[106][choice][3] ~= nil then
           DrawString(500, 520, CC.KFMove[106][choice][3], C_WHITE, size*0.8)
           end		
		ShowScreen()
		lib.Delay(CC.BattleDelay)
		local keyPress, ktype, mx, my = lib.GetKey()
		
		if keyPress==VK_SPACE or keyPress==VK_RETURN then
			if zs[choice].Usable then
				WAR.JYZS = choice
				m1, m2, a1, a2, a3, a4, a5 = zs[choice].m1, zs[choice].m2, zs[choice].a1, zs[choice].a2, zs[choice].a3, zs[choice].a4, zs[choice].a5 , zs[choice].a6
				break
			end
		elseif keyPress == VK_ESCAPE or ktype == 4 then
             a6 = 0 
            break	
		elseif keyPress == VK_UP then
			choice = choice - 1
			if choice < 1 then
				choice = #zs
			end
			
		elseif keyPress == VK_DOWN then
			choice = choice + 1
			if choice > #zs then
				choice = 1
			end
	  
		elseif keyPress >= 49 and keyPress <= 57 then
			local input = keyPress - 48
			if input <= #zs and zs[input].Usable then
				choice = input	
				WAR.JYZS = choice
				m1, m2, a1, a2, a3, a4, a5 = zs[choice].m1, zs[choice].m2, zs[choice].a1, zs[choice].a2, zs[choice].a3, zs[choice].a4, zs[choice].a5 , zs[choice].a6
				break
			end
		end
	end
	
	return m1, m2, a1, a2, a3, a4, a5 ,a6
  	
end


--̫����ʽ
function TaiXuanZhaoShi()
	WAR.TXZS = 0
	local zs={	
	{name="̫���񹦡�ȭ"},
	{name="̫���񹦡�ָ"},
	{name="̫���񹦡���"},
	{name="̫���񹦡���"},
	{name="̫���񹦡���"}
	}
	local size = CC.DefaultFont
	--local surid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)

	local choice = 1

	while true do
		if JY.Restart == 1 then
			break
		end
		Cat('ʵʱ��Ч����')
		Cls()
		for i = 1, #zs do
			lib.LoadPNG(91, 17 * 2 , 510, 118+i*50, 1)
			local color = C_WHITE

			if i == choice then
				color = C_GOLD
			end
			DrawString(520, 123+i*50, i, color, size*0.8)
			DrawString(551, 123+i*50, zs[i].name, color, size*0.9)
		end
		
		lib.LoadPNG(91, 16 * 2 , 480, 500, 1)
		DrawString(500, 520, CC.KFMove[102][choice][1], C_WHITE, size)

		ShowScreen()
		lib.Delay(CC.BattleDelay)
		local keyPress, ktype, mx, my = lib.GetKey();
		if keyPress==VK_SPACE or keyPress==VK_RETURN then
			break
		elseif keyPress == VK_UP then
			choice = choice - 1
			if choice < 1 then
				choice = #zs
			end
		elseif keyPress == VK_DOWN then
			choice = choice + 1
			if choice > #zs then
				choice = 1
			end
		elseif keyPress >= 49 and keyPress <= 57 then
			local input = keyPress - 48
			if input <= #zs then
				choice = input
				break
			end
		end
	end
	WAR.TXZS = choice
	return

end

function DGFJ()
   local pd = 0	
	for i = 0,WAR.PersonNum - 1 do 
		local id = WAR.Person[i]['������']
		if WAR.Person[i]['����'] == false and WAR.Person[WAR.CurID]['�ҷ�'] ~= WAR.Person[i]['�ҷ�']  then 
			local x,y = WAR.Person[i]['����X'],WAR.Person[i]['����Y']
			local eft = GetWarMap(x,y,4)
			if match_ID(id, 9982) and JY.Person[id]['����'] > 0 and  JY.Person[id]['����'] > 10 and fjpd(WAR.CurID) == false and eft > 0 and WAR.Person[i]['���ַ���'] == -1  then
				WAR.Person[i]['���ַ���'] = 1
				WAR.Person[i]["�ƶ�����"] = 0
				WAR.FW = {}
				for i = 0, CC.WarWidth - 1 do
					for j = 0, CC.WarHeight - 1 do
						local effect = GetWarMap(i, j, 4)
						if effect > 0 then 
							WAR.FW[#WAR.FW+1] = {i,j}
						end
					end
				end
				savewar()
				local pid = WAR.Person[WAR.CurID]['������']
				local tx = {}
				local at = WAR.CurID
				tx.dh = WAR.Person[WAR.CurID]['��Ч����']
				tx.wz1 = WAR.Person[WAR.CurID]['��Ч����1']
				tx.wz2 = WAR.Person[WAR.CurID]['��Ч����2']
				tx.wz3 = WAR.Person[WAR.CurID]['��Ч����3']
				tx.wz4 = WAR.Person[WAR.CurID]['��Ч����4']
				WAR.Person[WAR.CurID]['��Ч����'] = -1
				WAR.Person[WAR.CurID]['��Ч����1'] = nil
				WAR.Person[WAR.CurID]['��Ч����2'] = nil
				WAR.Person[WAR.CurID]['��Ч����3'] = nil
				WAR.Person[WAR.CurID]['��Ч����4'] = nil
	
				WAR.CurID = i
			
				WarDrawMap(0)
				CurIDTXDH(WAR.CurID, 84,1, "�����޽�", C_GOLD)
				WarSet()
				if WAR.AutoFight == 1 or WAR.Person[i]['�ҷ�'] == false or WAR.ZDDH == 354 then 
					War_AutoFight()
				else 
					--War_FightMenu()
					Cat('�书')
				end
				WAR.Person[i]['���ַ���'] = -1
				WAR.CurID = at
				WarDrawMap(0)

				WAR.Person[WAR.CurID]['��Ч����'] = tx.dh
				WAR.Person[WAR.CurID]['��Ч����1'] = tx.wz1
				WAR.Person[WAR.CurID]['��Ч����2'] = tx.wz2
				WAR.Person[WAR.CurID]['��Ч����3'] = tx.wz3
				WAR.Person[WAR.CurID]['��Ч����4'] = tx.wz4
				CleanWarMap(4,0)
				for i = 1,#WAR.FW do 
					SetWarMap(WAR.FW[i][1],WAR.FW[i][2],4,1)
				end
				WAR.FW = {}
				loadwar()
				if match_ID(id,592) and JLSD(0,30,id) then
					pd = 1
				end
			end
		end
	end
	--say(WAR.Person[WAR.CurID]['������'],0)
	return pd
end

function savewar()
	local file = io.open(CONFIG.DataPath..'1', "w");
	assert(file);
	for i,v in pairs(WAR) do
		local t = type(WAR[i]); --�ж϶�������
		if t == "number" then
			file:write(string.format("WAR.%s =", i))
			file:write(WAR[i])
			file:write("\n")
		end
	end
	file:close();
end

function loadwar()
	if existFile(CONFIG.DataPath..'1') then
		dofile(CONFIG.DataPath..'1')
		os.remove(CONFIG.DataPath..'1');
	end	
end

--�Ƿ񴥷����������ڷ�����һЩ�ж�
function fjpd(i)
	local id = WAR.Person[i]['������']
	if WAR.Person[i]["�����书"] ~= -1  then 
		return true
	end
	if WAR.Person[i]["���ַ���"] ~= -1  then 
		return true
	end
	if WAR.Person[i]["����"] ~= -1 then 
		return true
	end
	return false
end

--���߷����ж�
function MyFj(i)
	local id = WAR.Person[i]['������']
	if Curr_NG(id,204) then 
		return true
	end
	return false
end

function fjtx()
	local at = WAR.CurID
	for i = 0,WAR.PersonNum - 1 do 
		local id = WAR.Person[i]['������']
		if WAR.Person[i]['����'] == false and WAR.Person[WAR.CurID]['�ҷ�'] ~= WAR.Person[i]['�ҷ�'] then 
			if fjpd(WAR.CurID) == false and WAR.Person[i]['����'] == 1 and JY.Person[id]['����'] > 0 and JY.Person[id]['����'] > 10   then 
				WAR.Person[i]["�ƶ�����"] = 0
				WAR.CurID = i
				WarDrawMap(0)
				if WAR.AutoFight == 1 or WAR.Person[i]['�ҷ�'] == false then 
					War_AutoFight()
				else 
					Cat('�书')
					--War_FightMenu()
				end
			
				WAR.CurID = at
				WarDrawMap(0)
			end
				WAR.Person[i]['����'] = -1
		end
	end	
end

function Bagua(pid)
	
	local str = {}
	local lb = {'��','��','��','��','��','��','��','��','ǰ'}

	local jl = {30,25,25,25,25,20,20,15,15}
	if JY.Base["��������"] < 10 then 
		table.remove(lb,#lb)
	end
	if JY.Base["��������"] < 7 then 
		table.remove(lb,#lb)
	end
	if JY.Person[pid]['ʵս'] < 500 then 
		table.remove(lb,#lb)
	end
	if JY.Person[pid]['ʵս'] < 400 then 
		table.remove(lb,#lb)
	end
	if JY.Person[pid]['ʵս'] < 300 then 
		table.remove(lb,#lb)
	end
	if JY.Person[pid]['ʵս'] < 200 then 
		table.remove(lb,#lb)
	end
	for i = 1,#lb do
		WAR.PD[lb[i]][pid] = nil
		if JLSD(0,jl[i],pid) then
			str[#str+1] = i
			WAR.PD[lb[i]][pid] = 1
		--if #lb > 2 then
      -- break
    -- end
		end
	end

	local x0,y0 = WAR.Person[WAR.CurID]['����X'],WAR.Person[WAR.CurID]['����Y']
	local a = 2546
	local c = 1
	local e = 1
	local zoom = CONFIG.Zoom/100
   if #str > 0 then
		local hb = GetS(JY.SubScene, WAR.Person[WAR.CurID]['����X'], WAR.Person[WAR.CurID]['����Y'], 4)*CONFIG.Zoom/100
		local x,y = CC.ScreenW/2,CC.ScreenH/2
		local x1,y1 = math.sin(40*2*math.pi/360)*220*zoom,math.sin(50*2*math.pi/360)*220*zoom
		local x2,y2 = math.sin(80*2*math.pi/360)*220*zoom,math.sin(10*2*math.pi/360)*220*zoom
		local x3,y3 = math.sin(60*2*math.pi/360)*220*zoom,math.sin(30*2*math.pi/360)*220*zoom
		local x4,y4 = math.sin(20*2*math.pi/360)*220*zoom,math.sin(70*2*math.pi/360)*220*zoom
		local bl = {{0,1/2},
				  {-x1/220/zoom,y1/2/220/zoom},
				  {-x2/220/zoom,y2/2/220/zoom},
				  {-x3/220/zoom,-y3/2/220/zoom},
				  {-x4/220/zoom,-y4/2/220/zoom},
				  {x4/220/zoom,-y4/2/220/zoom},
				  {x3/220/zoom,-y3/2/220/zoom},
				  {x2/220/zoom,y2/2/220/zoom},
				  {x1/220/zoom,y1/2/220/zoom},}

		local zb = {{x,y-220/2*zoom-zoom*18},
				  {x+x1,y-y1/2-zoom*18},
				  {x+x2,y-y2/2-zoom*18},
				  {x+x3,y+y3/2-zoom*18},
				  {x+x4,y+y4/2-zoom*18},
				  {x-x4,y+y4/2-zoom*18},
				  {x-x3,y+y3/2-zoom*18},
				  {x-x2,y-y2/2-zoom*18},
				  {x-x1,y-y1/2-zoom*18}}
		for i = 1,#str do 
		    lib.GetKey()
		    local n = str[i]
		    for j = 0,220*zoom,20*zoom do 
			    lib.GetKey()
				Cat('ʵʱ��Ч����')
			    Cls()
				SetWarMap(x0,y0,8,a*2) 
				e = e + 1 
				if e == 3 then 
				   e = 1 
				   a = a + 1
				end   
				if a > 2569 then
				   a = 2546
				end  
				for i = 1,#lb do 
					if WAR.PD[lb[i]][pid] == nil then
					   lib.PicLoadCache(3,(2536+i)*2,zb[i][1],zb[i][2]-hb,2,256,nil,CC.ScreenW/936*50*zoom)
					else--if  
					   lib.PicLoadCache(3,(2536+i)*2,zb[i][1],zb[i][2]-hb,10,256,nil,CC.ScreenW/936*50*zoom)
					end
				end
				if j <= 200*zoom then 
				   --lib.PicLoadCache(99,(158+n)*2,zb[n][1]+bl[n][1]*j,zb[n][2]+bl[n][2]*j,10,256,nil,CC.ScreenW/1360*50)
				   lib.PicLoadCache(3,(2536+n)*2,zb[n][1]+bl[n][1]*j,zb[n][2]+bl[n][2]*j-hb,10,256,nil,CC.ScreenW/936*50*zoom)
				end   
				ShowScreen()
				lib.Delay(CC.BattleDelay)
			end
		end
   end
   CleanWarMap(8,-1)
end

Ct['ʵʱ��Ч����'] = function(s)
	CleanWarMap(9,-1)

	local bx,by = CC.ScreenW/936,CC.ScreenH/701 
	for i = 0,WAR.PersonNum-1 do 
		local id = WAR.Person[i]['������']
		local xx,yy = WAR.Person[i]['����X'],WAR.Person[i]['����Y']
		   
		local x0 = WAR.Person[WAR.CurID]["����X"]
		local y0 = WAR.Person[WAR.CurID]["����Y"]
		local dx = WAR.Person[i]["����X"] - x0
		local dy = WAR.Person[i]["����Y"] - y0
		local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
		local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
		local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)*CONFIG.Zoom/100
		ry = ry - hb
		
        if	WAR.Person[i]['����'] == false then
		
				if WAR.Person[i]['����'] ~= nil and WAR.Person[i]['����'] > 0 then
					local hd = WAR.Person[i]['����']
					if CC.HD[hd] ~= nil then
						local ys = math.ceil(30/CC.BattleDelay)
						local t1 = CC.HD[hd].tt
						local t2 = CC.HD[hd].tt1
						if WAR.Person[i]['�����ӳ�'] == nil then 
							WAR.Person[i]['�����ӳ�'] = 1 
						else 
							if WAR.Person[i]['�����ӳ�'] < ys then
								WAR.Person[i]['�����ӳ�'] = WAR.Person[i]['�����ӳ�'] + 1
							end
						end
						if WAR.Person[i]['�����ӳ�'] == ys then 
							if WAR.Person[i]['������ͼ'] == -1 then 
								WAR.Person[i]['������ͼ'] = t1 
							else 
								WAR.Person[i]['������ͼ'] = WAR.Person[i]['������ͼ'] + 1
							end	
							if WAR.Person[i]['������ͼ'] > t2 then 
								WAR.Person[i]['������ͼ'] = t1 
							end	
							SetWarMap(xx,yy,9,WAR.Person[i]['������ͼ']*2)	
							WAR.Person[i]['�����ӳ�'] = 0
						else	
							if WAR.Person[i]['������ͼ'] == -1 then 
								WAR.Person[i]['������ͼ'] = t1 
							end
							SetWarMap(xx,yy,9,WAR.Person[i]['������ͼ']*2)
						end	
					end
				end	
        end       
	end
end

function Delay(tt,x,y)
	for i = 1, tt do
		Cat('ʵʱ��Ч����')
		if x ~= nil and y ~= nil then 
		   WarDrawMap(1, x, y) 
		else 
		   WarDrawMap(0) 
		end
		ShowScreen()
		lib.Delay(CC.BattleDelay)
	end
end

Ct['�˵�'] = function(me,num,x,y,color,size,lx,color2,h)
	local bx,by = CC.ScreenW/936,CC.ScreenH/701 
	local menu = {}
	local size = CC.FontSmall
	local cot = 1
	local cot1 = 0
	for i = 1,#me do 
		if me[i][3] == 1 then 
			menu[#menu+1] = {me[i][1],i}
		end
	end
	if #menu == 0 then 
		return 0 
	end	
	if num == nil then 
		num = #menu 
	else 
		if num > #menu  then 
			num = #menu
		end
	end
	while true do
		if JY.Restart == 1 then
			break
		end
		Cls()
		Cat('ʵʱ��Ч����')
		Cls()
		
		for i = 1,num do 
			lib.PicLoadCache(92,1*2,x+(i-1)*bx*40,y,2,255)
			local cl = C_WHITE
			if i == cot then 
				cl = C_RED
			end
			if lx == nil then
				draw2(menu[i+cot1][1],x+(i-1)*bx*40,y - size*2 , cl, size,color2,h)	
			else 
				local stn = string.len(menu[i+cot1][1])/2
				local hsize = bx*100/stn
				draw3(menu[i+cot1][1],x+(i-1)*bx*40,y - ((stn-1)*hsize+size)/2, cl, size,color2,hsize)	
			end
		end
		ShowScreen()
		lib.Delay(CC.BattleDelay)
		
		local X, ktype, mx, my = lib.GetKey();
		if X == VK_SPACE or X == VK_RETURN then
			return menu[cot+cot1][2]
		elseif X == VK_ESCAPE or ktype == 4 then
			return 0
		elseif X == VK_UP then	
			
		elseif X == VK_DOWN then
			
		elseif X == VK_LEFT then
			if cot > 1 then 
				cot = cot - 1 
			else 
				if cot1 > 0 then 
					cot1 = cot1 - 1
				else 
					cot = num
					cot1 = #menu - num
				end
			end
		elseif X == VK_RIGHT then
			if cot + cot1 < #menu then 
				if cot < num then 
					cot = cot + 1
				else 
					cot1 = cot1 + 1
				end
			else 
				cot = 1
				cot1 = 0
			end		
		elseif menu[1] ~= nil and string.sub(menu[1][1],1,4) == '����' and X == VK_P then 
			return 1
		elseif menu[2] ~= nil and string.sub(menu[2][1],1,4) == '����' and X == VK_D then 
			return 2
		elseif menu[3] ~= nil and string.sub(menu[3][1],1,4) == '�ȴ�' and X == VK_W then 
			return 3
		elseif menu[4] ~= nil and string.sub(menu[4][1],1,4) == '����' and X == VK_J then 
			return 4
		elseif menu[5] ~= nil and string.sub(menu[5][1],1,4) == '��Ϣ' and X == VK_R then 
			return 5
		else 	
			local mxx = false 
			for i = 1,#menu do 
				if mx >= bx*25+(i-1)*bx*40 - bx*20 and mx <= bx*25+(i-1)*bx*40 + bx*20 and 
					my >= CC.ScreenH-by*60 - by*55 and my <= CC.ScreenH-by*60 + by*55 then 
					cot = i 
					mxx = true
					break
				end
			end
			if ktype == 3 and mxx == true then
				return menu[cot+cot1][2]
			end
		end
		
	end
end


Ct['ս���˵�'] = function()
	
	local bx,by = CC.ScreenW/936,CC.ScreenH/701 
	
	local pid = WAR.Person[WAR.CurID]["������"]
	
	local warmenu = {
					{'�ƶ���','�ƶ�',1},
					{'�书��','�书',1},
					{'������','����',1},
					{'�˹���','�˹�',1},
					{'ս����','ս��',1},
					{'��Ʒ��','��Ʒ',1},
					{'������','����',1},
					{'���ˣ�','����',1},
					{'�Զ���','�Զ�',1},
	
				}
	
	if JY.Person[pid]["��ɫָ��"] == 1 then
		--����ǳ���
		if pid == 0 then
			--'����'
			warmenu[3][1] = GRTS[JY.Base["����"]]..'��'
		else
			--'����'
			warmenu[3][1] = GRTS[pid]..'��'
		end
	else
		--'����'
		warmenu[3][3] = 0
	end
  
	--����
	if match_ID(pid, 49) then
		--���û��������������������ʾ��ɫָ��
		local t = 0
		for i = 0, WAR.PersonNum - 1 do
			local wid = WAR.Person[i]["������"]
			if WAR.TZ_XZ_SSH[wid] == 1 and WAR.Person[i]["����"] == false then
				t = 1
			end
		end
		--'����'
		if t == 0 then
			warmenu[3][3] = 0
		end
		--����С��20����ʾ��ɫָ��
		--'����'
		if JY.Person[pid]["����"] < 20 then
			warmenu[3][3] = 0
		end
	end
  
	--��ǧ��
	if match_ID(pid, 88) then
		--�����Χû�ж��Ѳ���ʾ��ɫָ��
		local yes = 0
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["�ҷ�"] == true and WAR.Person[i]["����"] == false and RealJL(WAR.CurID, i, 5) and i ~= WAR.CurID then
				yes = 1
			end
		end
		--'����'
		if yes == 0 then
			warmenu[3][3] = 0
		end
		--����С��20����ʾ��ɫָ��
		--����С��1000����ʾ
		--'����'
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 then
			warmenu[3][3] = 0
		end
	end

	--�˳���
	if match_ID(pid, 89) then
		--�����Χû�ж��Ѳ���ʾ��ɫָ��
		local px, py = WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"]
		local mxy = {
					{WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"] + 1}, 
					{WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"] - 1}, 
					{WAR.Person[WAR.CurID]["����X"] + 1, WAR.Person[WAR.CurID]["����Y"]}, 
					{WAR.Person[WAR.CurID]["����X"] - 1, WAR.Person[WAR.CurID]["����Y"]}}

		local yes = 0
		for i = 1, 4 do
			if GetWarMap(mxy[i][1], mxy[i][2], 2) >= 0 then
			local mid = GetWarMap(mxy[i][1], mxy[i][2], 2)
			if inteam(WAR.Person[mid]["������"]) then
				yes = 1
				end
			end  
		end
		--'����'
		if yes == 0 then
			warmenu[3][3] = 0
		end
		--'����'
		--����С��25����ʾ��ɫָ��
		if JY.Person[pid]["����"] < 25 then
			warmenu[3][3] = 0
		end
	end

	--���޼�
	if match_ID(pid, 9) then
		--�����Χû�ж��Ѳ���ʾ��ɫָ��
		local yes = 0
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["�ҷ�"] == true and WAR.Person[i]["����"] == false and RealJL(WAR.CurID, i, 8) and i ~= WAR.CurID then
				yes = 1
			end
		end
		--'����'
		if yes == 0 then
			warmenu[3][3] = 0
		end
		--'����'
		--����С��20����ʾ��ɫָ��
		if JY.Person[pid]["����"] < 20 then
			warmenu[3][3] = 0
		end
	end
 
	--����ָͩ��ָ��
	if match_ID(pid, 74) then
		--����С��10����ʾ��ɫָ��
		--'����'
		if JY.Person[pid]["����"] < 10 or JY.Person[pid]["����"] < 150 or  WAR.HQT_CD > 0 then
			warmenu[3][3] = 0
		end
	end
	
	--Ľ�ݸ�ָ�� ����
	if match_ID(pid, 51) then
		--����С��20����ʾ��ɫָ��
		--'����'
		if JY.Person[pid]["����"] < 20 then
			warmenu[3][3] = 0
		end
	end

	--С��ָ�� Ӱ��
	if match_ID(pid, 66) then
		--����С��30��������С��2000����ʾ��ɫָ��
		--'����'
		if JY.Person[pid]["����"] < 30 or JY.Person[pid]["����"] < 2000 then
			warmenu[3][3] = 0
		end
	end
  
	--����ָ�� ����
	if match_ID(pid, 90) then
		--����С��10����ʾ��ɫָ��
		if JY.Person[pid]["����"] < 10 then
			--'����'
			warmenu[3][3] = 0
		end
	end
	
	--����ָ�� ��װ
	if match_ID(pid, 92) then
		--����С��20����ʾ��ɫָ��
		if JY.Person[pid]["����"] < 20 then
			--'����'
			warmenu[3][3] = 0
		end
	end
	--����� ֹɱ
	if match_ID(pid, 68) then
		--����С��20����ʾ��ɫָ��
		--'����'
		if JY.Person[pid]["����"] < 20 or WAR.JSZT1[pid]> 0 then
			warmenu[3][3] = 0
		end
	end	
	--���ָ�� �ɺ�
	if match_ID(pid, 1) then
		--����С��20����ʾ��ɫָ��
		--'����'
		if JY.Person[pid]["����"] < 20 then
			warmenu[3][3] = 0
		end
	end
	
	--�Ħ��ָ�� �û�
	if match_ID(pid, 103) then
		--'����'
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 then
			warmenu[3][3] = 0
		end
	end
	
	--�����ָ�� ��ս
	if match_ID(pid, 160) then
		--'����'
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 or WAR.SZSD ~= -1 then
			warmenu[3][3] = 0
		end
	end
	
	--���� ����
	if match_ID(pid, 62) then
		--'����'
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 then
			warmenu[3][3] = 0
		end
	end
	
	--���� �ݼ�
	if match_ID(pid, 56) then
		--'����'
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 then
			warmenu[3][3] = 0
		end
	end
	
	--ΤС�� �ڲ�
	if match_ID(pid, 601) then
		--'����'
		if JY.Person[pid]["����"] < 30 then
			warmenu[3][3] = 0
		end
	end
	
	--���˷� �ƾ�
	if match_ID(pid, 3) then
		--'����'
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 then
			warmenu[3][3] = 0
		end
	end
	
	--��̫�� ����
	if match_ID(pid, 7) then
		--'����'
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 then
			warmenu[3][3] = 0
		end
	end
	
	--��֤ ����
	--'����'
	if match_ID(pid, 149) then
		if JY.Person[pid]["����"] < 20 or JY.Person[pid]["����"] < 1000 then
			warmenu[3][3] = 0
		end
	end
	--��Ѱ�� �ɵ�
	if match_ID(pid, 498) then
		--'����'
		if  JY.Person[pid]["����"] < 1000 then
			warmenu[3][3] = 0
		end
	end	
	--����ˮ �콣
	--'����'
	if match_ID(pid, 652) and JY.Base["��������"] < 7 then
			warmenu[3][3] = 0
		end
	
	--�ֻ� ����
	if match_ID(pid, 4) then	
		--'����'
		if JY.Person[pid]["����"] < 20 then
			warmenu[3][3] = 0
		end
	end

------------------------------------------------------
------------------------------------------------------
	--������ʱ���ƶ����ⶾ��ҽ�ƣ���Ʒ����ɫ���Զ����ɼ�
	if WAR.ZYHB == 2 then
		for i = 1,#warmenu do
			if i == 2 or i == 4 or i == 5  then
				warmenu[i][3] = 1
			else 	
				warmenu[i][3] = 0
			end
		end
	end
  
	--����С��5�����Ѿ��ƶ���ʱ���ƶ����ɼ�
	if JY.Person[pid]["����"] <= 5 or WAR.Person[WAR.CurID]["�ƶ�����"] <= 0 then
		warmenu[1][3] = 0
		--isEsc = 1
	end
  
	--�ж���С�������Ƿ����ʾ����
	local minv = War_GetMinNeiLi(pid)
	if JY.Person[pid]["����"] < minv or JY.Person[pid]["����"] < 10 then
		warmenu[2][3] = 0
	end
	
	local menu = {}
	for i = 1,#warmenu do
		if warmenu[i][3] == 1 then 
			menu[#menu+1] = {warmenu[i][2],i,warmenu[i][1]}
		end
	end	
	local size = CC.FontSmall
	local cot = 1
	while true do 
		if JY.Restart == 1 then
			break
		end	
		Cat('ʵʱ��Ч����')
		Cls()
		DrawTimeBar_sub()
		for i = 1,#menu do 
			lib.PicLoadCache(92,1*2,bx*25+(i-1)*bx*40,CC.ScreenH-by*60,2,255)
			local cl = C_WHITE
			if i == cot then 
				cl = C_RED
			end
			draw2(menu[i][3],bx*25+(i-1)*bx*40,CC.ScreenH-by*60 - size*2, cl, size,LimeGreen)	
		end
		ShowScreen()
		lib.Delay(CC.BattleDelay)
		
		local X, ktype, mx, my = lib.GetKey();
		if X == VK_SPACE or X == VK_RETURN then
			local r
			if menu[cot][2] ~= nil then
				r = Cat(menu[cot][1])
				if r == 1 then 
					if menu[cot][2] == 1 then 
						return 1
					else 
						break
					end
				end
			end
		elseif X == VK_ESCAPE or ktype == 4 then
			return 0
		elseif X == VK_UP then	
			
		elseif X == VK_DOWN then
			
		elseif X == VK_LEFT then
			cot = cot - 1 
			if cot < 1 then
				cot = #menu
			end
		elseif X == VK_RIGHT then
			cot = cot + 1 
			if cot > #menu then 
				cot = 1
			end
			--�ƶ�
		elseif X == VK_M then
			if warmenu[1][3] == 1 then
				local r = Cat(warmenu[1][2])
				if r == 1 then 
					return 1 
				end
			end	
			--�书
		elseif X == VK_A then
			if warmenu[2][3] == 1 then
				local r = Cat(warmenu[2][2])
				if r == 1 then 
					break
				end
			end	
			--����
		elseif X == VK_L then
			if warmenu[3][3] == 1 then
				local r = Cat(warmenu[3][2])
				if r == 1 then 
					break
				end
			end	
			--�˹�
		elseif X == VK_G then
			if warmenu[4][3] == 1 then
				local r = Cat(warmenu[4][2])
				if r == 1 then 
					break
				end
			end	
			--ս��
		elseif X == VK_S then
			if warmenu[5][3] == 1 then
				local r = Cat(warmenu[5][2])
				if r == 1 then 
					break
				end
			end	
			--��Ʒ
		elseif X == VK_E then
			if warmenu[6][3] == 1 then
				local r = Cat(warmenu[6][2])
				if r == 1 then 
					break
				end
			end	
			--����
		elseif X == VK_H then
			if warmenu[7][3] == 1 then
				local r = Cat(warmenu[7][2])
				if r == 1 then 
					break
				end
			end	
			--����
		elseif X == VK_C then
			if warmenu[8][3] == 1 then
				local r = Cat(warmenu[8][2])
				if r == 1 then 
					break
				end
			end	
			--�Զ�
		elseif X == VK_T then
			if warmenu[9][3] == 1 then
				local r = Cat(warmenu[9][2])
				if r == 1 then 
					break
				end
			end	
		elseif X >= 49 and X <= 57 and warmenu[2][3] == 1 then
			local r = War_FightMenu(nil, nil, X-48);
			if r == 1 then 
				break
			end
		elseif X == VK_P and warmenu[5][3] == 1 then
			War_ActupMenu()
			break
		elseif X == VK_D and warmenu[5][3] == 1 then
			War_DefupMenu()
			break
		elseif X == VK_W and warmenu[5][3] == 1 then
			War_Wait()
			break
		elseif X == VK_J and warmenu[5][3] == 1 then
			War_Focus()
		elseif X == VK_R and warmenu[5][3] == 1 then
			War_RestMenu()
			break
		elseif X == VK_V and warmenu[7][3] == 1 then 
			local r = War_PoisonMenu()
			--�ⶾ
				if r == 1 then 
					break
				end
		elseif X == VK_Q and warmenu[7][3] == 1 then 
			local r = War_DecPoisonMenu()
			--ҽ��
				if r == 1 then 
					break
				end
		elseif X == VK_F and warmenu[7][3] == 1 then 
			local r = War_DoctorMenu()
				if r == 1 then 
					break
				end
		elseif X == VK_Z and warmenu[7][3] == 1 then 
			Ckstatus()
		else 	
			local mxx = false 
			for i = 1,#menu do 
				if mx >= bx*25+(i-1)*bx*40 - bx*20 and mx <= bx*25+(i-1)*bx*40 + bx*20 and 
					my >= CC.ScreenH-by*60 - by*55 and my <= CC.ScreenH-by*60 + by*55 then 
					cot = i 
					mxx = true
					break
				end
			end
			if ktype == 3 and mxx == true then
				local r
				if menu[cot][2] ~= nil then
					r = Cat(menu[cot][1])
					if r == 1 then 
						if menu[cot][2] == 1 then 
							return 1
						else 
							break
						end
					end
				end
			end
		end
		
	end
end

Ct['�ƶ�'] = function()
	if WAR.Person[WAR.CurID]["������"] ~= -1 then
		WAR.ShowHead = 0
		if WAR.Person[WAR.CurID]["�ƶ�����"] <= 0 then
		  return 0
		end
		War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["�ƶ�����"], 0)
		local r = nil
		local x, y = War_SelectMove()
		if x ~= nil then
			War_MovePerson(x, y, 1)
			r = 1
		else
			r = 0
			WAR.ShowHead = 1
			Cls()
		end
		lib.GetKey()
		return r
	else
		local ydd = {}
		local n = 1
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["�ҷ�"] ~= WAR.Person[WAR.CurID]["�ҷ�"] and WAR.Person[i]["����"] == false then
				ydd[n] = i
				n = n + 1
			end
		end
		local dx = ydd[math.random(n - 1)]
		local DX = WAR.Person[dx]["����X"]
		local DY = WAR.Person[dx]["����Y"]
		local YDX = {DX + 1, DX - 1, DX}
		local YDY = {DY + 1, DY - 1, DY}
		local ZX = YDX[math.random(3)]
		local ZY = YDY[math.random(3)]
		if not SceneCanPass(ZX, ZY) or GetWarMap(ZX, ZY, 2) < 0 then
		SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, -1)
		SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, -1)
        SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, -1)
		WAR.Person[WAR.CurID]["����X"] = ZX
		WAR.Person[WAR.CurID]["����Y"] = ZY
		SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, WAR.CurID)
		SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, WAR.Person[WAR.CurID]["��ͼ"])
        SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, JY.Person[WAR.Person[WAR.CurID]["������"]]['ͷ�����'])
		end
	end
	return 1
end

Ct['�书'] = function()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701 
	
	local pid = WAR.Person[WAR.CurID]["������"]
	
	local numwugong = 0
	local kfmenu = {}

	for i = 1, JY.Base["�书����"] do
		local tmp = JY.Person[pid]["�书" .. i]
		if tmp > 0 then
			kfmenu[i] = {tmp, i, 1}
	
			--�ڹ��޷�����
			--��̹֮����
			if match_ID(pid, 48) == false and JY.Wugong[tmp]["�书����"] == 6
			then
				kfmenu[i][3] = 0
			end
			
			--�Ṧ�޷�����
			if JY.Wugong[tmp]["�书����"] == 7  or 
           (tmp == 85 or tmp == 87 or tmp == 88 or tmp == 144 or tmp == 175  or tmp == 182  or tmp == 199)then
				kfmenu[i][3] = 0
			end
			
			--��ת���Ʋ���ʾ
			if tmp == 43 then
				kfmenu[i][3] = 0
			end

			--�������������ڹ��ɹ����������һ���ڹ��ɹ���
			if ((pid == 0 and JY.Base["��׼"] == 6) or (pid == 0 and JY.Base["����"] > 0 and i == 1)) and JY.Wugong[tmp]["�书����"] == 6 then
				kfmenu[i][3] = 1
			end
			--��ƽ֮ ���� ����� ��ʾ������
			if tmp == 105 and (match_ID(pid, 36) or match_ID(pid, 27) or match_ID(pid, 189))  then
				kfmenu[i][3] = 1
			end
		   
			--ʯ���� ��ʾ̫����
			if tmp == 102 and match_ID_awakened(pid, 38, 1) then
				kfmenu[i][3] = 1
			end
		  
			--���޼� ��ʾ������
			if tmp == 106 and match_ID(pid, 9) then
				kfmenu[i][3] = 1
			end
			--����ɮ ��ʾ������
			if tmp == 106 and (match_ID(pid, 638) or match_ID(pid,9999)) then
				kfmenu[i][3] = 1
			end			
		  
			--���� ��ʾ����
			if tmp == 94 and match_ID(pid, 37) then
				kfmenu[i][3] = 1
			end
		  
			--Ľ�ݸ� ��ʾ��ת����
			if tmp == 43 and match_ID(pid, 51) then
				kfmenu[i][3] = 1
			end
		  
			--ŷ���� ��ʾ����
			if tmp == 104 and match_ID(pid, 60) then
				kfmenu[i][3] = 1
			end

			--С�� ��ʾʥ��
			if tmp == 93 and match_ID(pid, 66) then
				kfmenu[i][3] = 1
			end
		  
			--�����ٲ���ʾ
			if JY.Person[pid]["����"] < JY.Wugong[tmp]["������������"] then
				kfmenu[i][3] = 0
			end

			--��������10����ʾ
			if JY.Person[pid]["����"] < 10 then
				kfmenu[i][3] = 0
			end
			  
			numwugong = numwugong + 1
		  
		end
	end
	
	
	local menu = {}
	for i = 1,#kfmenu do
		if kfmenu[i][3] == 1 then 
			menu[#menu+1] = {kfmenu[i][1],i}
		end
	end	
	
	if #menu == 0 then
		return 0
	end
	local num = 15
	if num > #menu then 
		num = #menu 
	end	
	local size = CC.FontSmall--*0.95
	local cot = 1
	local cot1 = 0
	while true do 
		if JY.Restart == 1 then
			break
		end
		Cls()
		Cat('ʵʱ��Ч����')
		Cls()
		
		for i = 1,num do 
			lib.PicLoadCache(92,1*2,bx*25+(i-1)*bx*40,CC.ScreenH-by*60,2,255)
			local cl = C_WHITE
			if i == cot then 
				cl = C_RED
			end
			local stn = string.len(JY.Wugong[menu[i+cot1][1]]['����'])/2
			local hsize = bx*100/stn
			draw3(JY.Wugong[menu[i+cot1][1]]['����'],bx*25+(i-1)*bx*40,CC.ScreenH-by*60- ((stn-1)*hsize+size)/2, cl, size,nil,hsize)
		end
		ShowScreen()
		lib.Delay(CC.BattleDelay)
		
		local X, ktype, mx, my = lib.GetKey();
		if X == VK_SPACE or X == VK_RETURN then
			return War_Fight_Sub(WAR.CurID, menu[cot+cot1][2])
		elseif X == VK_ESCAPE or ktype == 4 then
			return 0
		elseif X == VK_UP then	
			
		elseif X == VK_DOWN then
			
		elseif X == VK_LEFT then
			if cot > 1 then 
				cot = cot - 1 
			else 
				if cot1 > 0 then 
					cot1 = cot1 - 1
				else 
					cot = num
					cot1 = #menu - num
				end
			end
		elseif X == VK_RIGHT then
			if cot + cot1 < #menu then 
				if cot < num then 
					cot = cot + 1
				else 
					cot1 = cot1 + 1
				end
			else 
				cot = 1
				cot1 = 0
			end	
		elseif X >= 49 and X <= 57 then
			local r = War_FightMenu(nil, nil, X-48);
			if r == 1 then 
				return 1
			end
		else 	
			local mxx = false 
			for i = 1,#menu do 
				if mx >= bx*25+(i-1)*bx*40 - bx*20 and mx <= bx*25+(i-1)*bx*40 + bx*20 and 
					my >= CC.ScreenH-by*60 - by*55 and my <= CC.ScreenH-by*60 + by*55 then 
					cot = i 
					mxx = true
					break
				end
			end
			if ktype == 3 and mxx == true then
				return War_Fight_Sub(WAR.CurID, menu[cot][2])
			end
		end
		
	end
end

Ct['����'] = function()
	return War_TgrtsMenu()
end

Ct['�˹�'] = function()
	return War_YunGongMenu()
end

Ct['ս��'] = function()
	return War_TacticsMenu()
end

Ct['����'] = function()
	return War_OtherMenu()
end

Ct['��Ʒ'] = function()
	return War_ThingMenu()
end

Ct['����'] = function()
	return War_Retreat()
end

Ct['�Զ�'] = function()
	return War_AutoMenu()
end

function Ckstatus()
--function MapWatch()
 --WAR.ShowHead = 0
	local x = WAR.Person[WAR.CurID]["����X"];
	local y = WAR.Person[WAR.CurID]["����Y"];
	local page = 1

	War_CalMoveStep(WAR.CurID,255,1)
	Cat('ʵʱ��Ч����')
	WarDrawMap(1,x,y);	
	ShowScreen()
	lib.Delay(CC.BattleDelay)
	x,y=War_SelectMove()
	if x == nil then
		return
	end
	local i
	local id = -1
	for i = 0,WAR.PersonNum do
		if WAR.Person[i]["����X"] == x and WAR.Person[i]["����Y"] == y and WAR.Person[i]["����"] == false then
			id =  i-- WAR.Person[i]["������"]
			break;
		end
	end

	if id >= 0 then
		--Cat('��ʾ״̬',id,page)
		ShowPersonStatus(id)
	end

--end
end

--����ֹͣ
Ct['����ֹͣ'] = function(i)
	WAR.Person[i]['����'] = -1 
	WAR.Person[i]['������ͼ'] = -1 
	WAR.Person[i]['�����ӳ�'] = nil
end

Ct['����̫��'] = function(x,y)
	local id = WAR.Person[WAR.CurID]['������']
	local x0,y0 = WAR.Person[WAR.CurID]['����X'],WAR.Person[WAR.CurID]['����Y']
	PlayWavE(5)
	CurIDTXDH(WAR.CurID, 129,1,'����̫��')
	lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, -1)
	lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, -1)
    lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, -1)
	--WarDrawMap(0)
	--CurIDTXDH(WAR.CurID, 129,1)
	WAR.Person[WAR.CurID]["�˷���"] = War_Direct(x0, y0, x, y)
	WAR.Person[WAR.CurID]["��ͼ"] = WarCalPersonPic(WAR.CurID)
	WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"] = x, y
	WarDrawMap(0)
	--CurIDTXDH(WAR.CurID, 129,1)
	lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, WAR.Person[WAR.CurID]["��ͼ"])
	lib.SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, WAR.CurID)
    SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, JY.Person[WAR.Person[WAR.CurID]["������"]]['ͷ�����'])
	--WarDrawMap(0)
	CurIDTXDH(WAR.CurID, 129,1,'����̫��')
end

Ct['����̫��2'] = function(flag)
	if flag == nil then
		local x0,y0 = WAR.Person[WAR.CurID]['����X'],WAR.Person[WAR.CurID]['����Y']
		WAR.PD['����̫��'] = {}
		for j = 0,WAR.PersonNum - 1 do 
			local mid = WAR.Person[j]['������']
			local zbx,zby = WAR.Person[j]['����X'],WAR.Person[j]['����Y']
			local mx = WAR.Person[j]['�˷���']
			local zm = false
			--Ϊɶ��ô�鷳�����뿴���м�ĸ���
			local a = math.random(10)
			if mx == 0 then 
				if y0 < zby then
					if math.abs(x0-zbx) - math.abs(y0-zby) >= 1 then
						if (a < 8 and a > 4) or WAR.LQZ[mid] == 100 then 
							zm = true
						end
					else
						zm = true
					end
				end
			elseif mx == 1 then 
				if x0 > zbx then 
					if math.abs(y0-zby) - math.abs(x0-zbx) >= 1 then 
						if (a < 8 and a > 4) or WAR.LQZ[mid] == 100 then
							zm = true
						end
					else
						zm = true
					end
				end
			elseif mx == 2 then 
				if x0 < zbx then 
					if math.abs(y0-zby) - math.abs(x0-zbx) >= 1 then 
						if (a < 8 and a > 4) or WAR.LQZ[mid] == 100 then
							zm = true
						end
					else
						zm = true
					end
				end
			elseif mx == 3 then 
				if y0 > zby then 
					if math.abs(x0-zbx) - math.abs(y0-zby) >= 1 then 
						if (a < 8 and a > 4) or WAR.LQZ[mid] == 100 then
							zm = true
						end
					else
						zm = true
					end
				end
			end
			if zm == true and WAR.Person[j]['����'] == false and j ~= WAR.CurID and match_ID(mid,9976) then 
				WAR.PD['����̫��'][mid] = {}
				WAR.PD['����̫��'][mid].hp = JY.Person[mid]['����']
				WAR.PD['����̫��'][mid].nl = JY.Person[mid]['����']
				WAR.PD['����̫��'][mid].tl = JY.Person[mid]['����']
				WAR.PD['����̫��'][mid].zd = JY.Person[mid]['�ж��̶�']
				WAR.PD['����̫��'][mid].ns = JY.Person[mid]['���˳̶�']
				WAR.PD['����̫��'][mid].bs = JY.Person[mid]['����̶�']
				WAR.PD['����̫��'][mid].zs = JY.Person[mid]['���ճ̶�']
				WAR.PD['����̫��'][mid]['��������'] = WAR.Person[j]['��������']
				WAR.PD['����̫��'][mid]['��������'] = WAR.Person[j]['��������']
				WAR.PD['����̫��'][mid]['��������'] = WAR.Person[j]['��������']
				WAR.PD['����̫��'][mid]['�ж�����'] = WAR.Person[j]["�ж�����"];
				WAR.PD['����̫��'][mid]['���˵���'] = WAR.Person[j]["���˵���"];
				for k,v in pairs(WAR) do 
					if k ~= 'Person' and k ~= 'Data' then
						local t = type(WAR[k])
						if t == 'table' then
							WAR.PD['����̫��'][mid][k] = WAR[k][mid]
						end
					end
				end
				WAR.Person[j]['����̫��'] = 1
			end
		end
	else 
		for j = 0,WAR.PersonNum - 1 do 
			local mid = WAR.Person[j]['������']
			local zbx,zby = WAR.Person[j]['����X'],WAR.Person[j]['����Y']
			if WAR.Person[j]['����'] == false and match_ID(mid,9976) and WAR.Person[j]['����̫��'] == 1 and (GetWarMap(zbx,zby,4) > 1 or WAR.TXXS[mid] ~= nil) then
				if WAR.PD['����̫��'][mid] ~= nil then
					WAR.Person[j]["��Ч����"] = -1
					WAR.Person[j]["��Ч����0"] = nil
					WAR.Person[j]["��Ч����1"] = nil
					WAR.Person[j]["��Ч����2"] = nil
					WAR.Person[j]["��Ч����3"] = nil
					WAR.Person[j]["��Ч����4"] = nil
					JY.Person[mid]['����'] = WAR.PD['����̫��'][mid].hp
					JY.Person[mid]['����'] = WAR.PD['����̫��'][mid].nl
					JY.Person[mid]['����'] = WAR.PD['����̫��'][mid].tl
					JY.Person[mid]['�ж��̶�'] = WAR.PD['����̫��'][mid].zd 
					JY.Person[mid]['���˳̶�'] = WAR.PD['����̫��'][mid].ns 
					JY.Person[mid]['����̶�'] = WAR.PD['����̫��'][mid].bs 
					JY.Person[mid]['���ճ̶�'] = WAR.PD['����̫��'][mid].zs 
					WAR.Person[j]['��������'] = WAR.PD['����̫��'][mid]['��������']
					WAR.Person[j]['��������'] = WAR.PD['����̫��'][mid]['��������']
					WAR.Person[j]['��������'] = WAR.PD['����̫��'][mid]['��������']
					WAR.Person[j]['�ж�����'] = WAR.PD['����̫��'][mid]['�ж�����']
					WAR.Person[j]['���˵���'] = WAR.PD['����̫��'][mid]['���˵���']
					for k,v in pairs(WAR) do
						if k ~= 'Person' and k ~= 'Data' then
							local t = type(WAR[k])
							if t == 'table' then
								WAR[k][mid] = WAR.PD['����̫��'][mid][k]
							end
						end
					end
					WAR.Person[j]["��Ч����3"] = "����̫��"
					WAR.Person[j]["��Ч����"] = 129
					if WAR.Person[j].TimeAdd ~= nil and WAR.Person[j].TimeAdd < 0 then 
						WAR.Person[j].TimeAdd = 0
					end
					WAR.Person[j]['����̫��'] = nil
					SetWarMap(zbx,zby,4,0)
					WAR.TXXS[mid] = nil
				end
			end
		end
		
		WAR.PD['����̫��'] = {}
	end
end

--ս��������
function Atk(i)
	local id = WAR.Person[i]['������']
	local gj = 0
	gj = gj + JY.Person[id]['������']
			
	gj  = gj + limitX((JY.Person[id]['����'] - JY.Person[id]['����']*10)/60,0)

	for i =1,JY.Base["�书����"] do  
        local level = 0            
		if JY.Person[id]["�书" .. i] == 108 then
			level = math.modf(JY.Person[id]["�书�ȼ�" .. i]/100)+1;
			level = limitX(level/10,0,1)
			gj = gj + math.modf(JY.Person[id]["������"]*0.3*level)
			break
        end
    end
	
	if match_ID(id, 604) then
		gj = gj + TrueYJ(id)
	end
	--NPC��װ�������ȼ�
	if inteam(id) then

		if JY.Person[id]["����"] >= 0 then
			gj = gj + JY.Thing[JY.Person[id]["����"]]["�ӹ�����"]*10+JY.Thing[JY.Person[id]["����"]]["�ӹ�����"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end
		if JY.Person[id]["����"] >= 0 then
			gj = gj + JY.Thing[JY.Person[id]["����"]]["�ӹ�����"]*10+JY.Thing[JY.Person[id]["����"]]["�ӹ�����"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end
		if JY.Person[id]["����"] >= 0 then
			gj = gj + JY.Thing[JY.Person[id]["����"]]["�ӹ�����"]*10+JY.Thing[JY.Person[id]["����"]]["�ӹ�����"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end		
	else
		if JY.Person[id]["����"] >= 0 then
			gj = gj + JY.Thing[JY.Person[id]["����"]]["�ӹ�����"]*10+JY.Thing[JY.Person[id]["����"]]["�ӹ�����"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end
		if JY.Person[id]["����"] >= 0 then
			gj = gj + JY.Thing[JY.Person[id]["����"]]["�ӹ�����"]*10+JY.Thing[JY.Person[id]["����"]]["�ӹ�����"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end
		if JY.Person[id]["����"] >= 0 then
			gj = gj + JY.Thing[JY.Person[id]["����"]]["�ӹ�����"]*10+JY.Thing[JY.Person[id]["����"]]["�ӹ�����"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end	
		
	end
	--����ͩ
	if match_ID(id, 74) then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == true then
				gj = gj+10
			end		
	    end
	end		
	--����
	if match_ID(id, 508) then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == false then
				gj = gj+5
			end		
	    end
	end		
	--for wid = 0, WAR.PersonNum - 1 do
		--���ѹ������ӳ�
	for i,v in pairs(CC.AddAtk) do
		if match_ID(id, v[1]) then
			for wid = 0, WAR.PersonNum - 1 do
				if match_ID(WAR.Person[wid]["������"], v[2]) and WAR.Person[wid]["����"] == false then
					gj = gj + v[3]
				end
			end
		end
	end
	--end
    if WAR.PD['���ϵ�������'][id] ~= nil then 
        gj = gj*1.5
    end
    
	return gj
end

--ս��������
function Def(i)
	local id = WAR.Person[i]['������']
	local fy = 0 
	fy = fy + JY.Person[id]['������']
	fy  = fy + limitX((JY.Person[id]['����'] - JY.Person[id]['����']*10)/60,0)
	
   for i =1,JY.Base["�书����"] do  
		local level = 0            
		if JY.Person[id]["�书" .. i]==108 then
			level = math.modf(JY.Person[id]["�书�ȼ�" .. i]/100)+1;
			level = limitX(level/10,0,1)
			fy = fy + math.modf(JY.Person[id]["������"]*0.3*level)	
			break
        end
    end
	
	if match_ID(id, 604) then
		fy = fy + TrueYJ(id)
	end
	if inteam(id) then
		if JY.Person[id]["����"] >= 0 then	
			fy = fy - JY.Thing[JY.Person[id]["����"]]["�ӷ�����"]*10+JY.Thing[JY.Person[id]["����"]]["�ӷ�����"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end
		if JY.Person[id]["����"] >= 0 then
			fy = fy - JY.Thing[JY.Person[id]["����"]]["�ӷ�����"]*10+JY.Thing[JY.Person[id]["����"]]["�ӷ�����"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end
		if JY.Person[id]["����"] >= 0 then
			fy = fy - JY.Thing[JY.Person[id]["����"]]["�ӷ�����"]*10+JY.Thing[JY.Person[id]["����"]]["�ӷ�����"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end		
	else
		if JY.Person[id]["����"] >= 0 then
			fy = fy - JY.Thing[JY.Person[id]["����"]]["�ӷ�����"]*10+JY.Thing[JY.Person[id]["����"]]["�ӷ�����"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end
		if JY.Person[id]["����"] >= 0 then
			fy = fy - JY.Thing[JY.Person[id]["����"]]["�ӷ�����"]*10+JY.Thing[JY.Person[id]["����"]]["�ӷ�����"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end
		if JY.Person[id]["����"] >= 0 then
			fy = fy - JY.Thing[JY.Person[id]["����"]]["�ӷ�����"]*10+JY.Thing[JY.Person[id]["����"]]["�ӷ�����"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end		
	end
	
	if match_ID(id, 74) then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == true then
				fy = fy+10
			end		
	    end
	end		
	--����
	if match_ID(id, 508) then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] == false then
				fy = fy+5
			end		
	    end
	end		
	
	--���ѷ������ӳ�
	for i,v in pairs(CC.AddDef) do
		if match_ID(id, v[1]) then
			for wid = 0, WAR.PersonNum - 1 do
				if match_ID(WAR.Person[wid]["������"], v[2]) and WAR.Person[wid]["����"] == false then
					fy = fy + v[3]
				end
			end
		end
	end

    if WAR.PD['���ϵ�������'][id] ~= nil then 
        fy = fy*1.5
    end
	return fy
end

--ս���Ṧ
function Qg(i)
	local id

	id = WAR.Person[i]['������']

	local qg = 0 
	qg = qg + JY.Person[id]['�Ṧ']
	
	qg = qg + limitX((JY.Person[id]['����'] - JY.Person[id]['����']*10)/60,0)
	if inteam(id) then
		if JY.Person[id]["����"] >= 0 then	
			qg = qg - JY.Thing[JY.Person[id]["����"]]["���Ṧ"]*10+JY.Thing[JY.Person[id]["����"]]["���Ṧ"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end
		if JY.Person[id]["����"] >= 0 then
			qg = qg - JY.Thing[JY.Person[id]["����"]]["���Ṧ"]*10+JY.Thing[JY.Person[id]["����"]]["���Ṧ"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end
		if JY.Person[id]["����"] >= 0 then
			qg = qg - JY.Thing[JY.Person[id]["����"]]["���Ṧ"]*10+JY.Thing[JY.Person[id]["����"]]["���Ṧ"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end		
	else
		if JY.Person[id]["����"] >= 0 then
			qg = qg - JY.Thing[JY.Person[id]["����"]]["���Ṧ"]*10+JY.Thing[JY.Person[id]["����"]]["���Ṧ"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end
		if JY.Person[id]["����"] >= 0 then
			qg = qg - JY.Thing[JY.Person[id]["����"]]["���Ṧ"]*10+JY.Thing[JY.Person[id]["����"]]["���Ṧ"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end
		if JY.Person[id]["����"] >= 0 then
			qg = qg - JY.Thing[JY.Person[id]["����"]]["���Ṧ"]*10+JY.Thing[JY.Person[id]["����"]]["���Ṧ"]*(JY.Thing[JY.Person[id]["����"]]["װ���ȼ�"]-1)*2
		end		
	end	

	--���㹦
	if Curr_QG(id,223) then
		qg =qg + math.modf(JY.Person[id]["�Ṧ"]*0.2)
	end	
		 
	--��ң��
	if Curr_QG(id,2) then
	    qg = qg + 20
	end	 
		
	for i =1,JY.Base["�书����"] do  
		local level = 0            
		if JY.Person[id]["�书" .. i]==108 then
			level = math.modf(JY.Person[id]["�书�ȼ�" .. i]/100)+1;
			level = limitX(level/10,0,1)
			qg = qg + math.modf(JY.Person[id]["�Ṧ"]*0.3*level)	
			break
        end
    end
	
    if WAR.PD['���ϵ�������'][id] ~= nil then 
        qg = qg*1.5
    end
	return qg
end


function ZDGH(i,id)
     for j = 0, WAR.PersonNum - 1 do
		local zid = WAR.Person[j]["������"]
		if WAR.Person[j]["����"] == false and WAR.Person[i]["�ҷ�"]  == WAR.Person[j]["�ҷ�"] and match_ID(zid, id) then
			return true
		end
	end
    return false
end

Ct['Ų��'] = function(i,bs,lx,auto)
	local nx,ny = nil,nil
	local id = WAR.Person[i]['������']
	if lx == nil then 
		lx = 0
	end	
    local at = WAR.CurID
	--auto �Զ�
	if WAR.Person[i]['�ҷ�'] == false or WAR.AutoFight == 1 or auto == '�Զ�' or WAR.ZDDH == 354 then 
		--say('1')
		local menu = {}
		local menu2 = {}
		War_CalMoveStep(i, bs, lx)
		local xi,yi = WAR.Person[i]['����X'],WAR.Person[i]['����Y']
		--��¼���п����ƶ�������
		for ix = limitX(xi-bs,0,xi),limitX(xi+bs,xi,62) do 
			for iy = limitX(yi-bs,0,yi), limitX(yi+bs,yi,62) do 
				if GetWarMap(ix, iy, 3) ~= 255 and GetWarMap(ix, iy, 2) < 0 and GetWarMap(ix, iy, 4) <= 0 then 
				   menu[#menu+1] = {ix,iy}
				end
			end 
		end
		--���ѡ��һ�������ƶ������꣬��¼��ǰ�����ͼ��2����ֵ���趨��ǰ����
		if #menu > 0 then 
		   local a = math.random(#menu)
			nx = menu[a][1]
			ny = menu[a][2]
			--WAR.NyPd[#WAR.NyPd+1] = {nx,ny,GetWarMap(nx,ny,2)}
			--SetWarMap(nx,ny,2,i)
		end
	else 

		WAR.CurID = i
		War_CalMoveStep(i, bs, lx)
		while true do
			nx, ny = War_SelectMove() --��ʾ+ѡ����
			if nx ~= nil then
				if GetWarMap(nx, ny, 3) ~= 255 and GetWarMap(nx, ny, 2) < 0 then 
					--WAR.NyPd[#WAR.NyPd+1] = {nx,ny,GetWarMap(nx,ny,2)}
					--SetWarMap(nx,ny,2,i)
				   break
				end
			elseif nx == nil then 
				break
			end
		end

	end
    
    if nx ~= nil and ny ~= nil then 
	    PlayWavE(5)
        WAR.CurID = i
	    WarDrawMap(0)
	    CurIDTXDH(WAR.CurID, 89,1, "�桤����Ų��")
	    SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, -1)
	    SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, -1)
        SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, -1)
	    WarDrawMap(0)
	    --CurIDTXDH(WAR.CurID, 89,1, "�桤����Ų��")
	    WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"] = nx, ny
	    --WarDrawMap(0)
	    --CurIDTXDH(WAR.CurID, 89,1, "�桤����Ų��")
	    SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 5, WAR.Person[WAR.CurID]["��ͼ"])
	    SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 2, WAR.CurID)
        SetWarMap(WAR.Person[WAR.CurID]["����X"], WAR.Person[WAR.CurID]["����Y"], 10, JY.Person[WAR.Person[WAR.CurID]["������"]]['ͷ�����'])
	    --WarDrawMap(0)
	    CurIDTXDH(WAR.CurID, 89,1, "�桤����Ų��")
    end
    

    WAR.CurID = at

	--return nx,ny
end 

Ct['�Զ�����'] = function(kfid)
    local x,y = nil,nil
	local pid = WAR.Person[WAR.CurID]["������"]
	local kungfuid = JY.Person[pid]["�书" .. kfid]
	local kungfulv = JY.Person[pid]["�书�ȼ�" .. kfid]
	if kungfulv == 999 then
		kungfulv = 11
	else
		kungfulv = math.modf(kungfulv / 100) + 1
	end
	local m1, m2, a1, a2, a3, a4, a5 = refw(kungfuid, kungfulv)
	local mfw = {m1, m2}
	local atkfw = {a1, a2, a3, a4, a5}
	if kungfulv == 11 then
		kungfulv = 10
	end
	--AIҲ���µ������ж�
	local kungfuatk = get_skill_power(pid, kungfuid, kungfulv)
	local atkarray = {}
	local num = 0
	CleanWarMap(4, -1)
	local movearray = War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["�ƶ�����"], 0)

	for i = 0, WAR.Person[WAR.CurID]["�ƶ�����"] do
		local step_num = movearray[i].num
		if step_num ~= nil then
			for j = 1, step_num do
				local xx = movearray[i].x[j]
				local yy = movearray[i].y[j]
				num = num + 1
				atkarray[num] = {}
				atkarray[num].x, atkarray[num].y = xx, yy
				atkarray[num].p, atkarray[num].ax, atkarray[num].ay = GetAtkNum(xx, yy, mfw, atkfw, kungfuatk)
			end
		end
	end
	for i = 1, num - 1 do
		for j = i + 1, num do
			if atkarray[i].p < atkarray[j].p then
				atkarray[i], atkarray[j] = atkarray[j], atkarray[i]
			end
		end
	end
	if atkarray[1].p > 0 then
		for i = 2, num do
			if atkarray[i].p == 0 or atkarray[i].p < atkarray[1].p / 2 then
				num = i - 1
				break;
			end
		end
		for i = 1, num do
			if WAR.Person[WAR.CurID]["�ҷ�"] == true then
				--flag: approach enemies.
				atkarray[i].p = atkarray[i].p + GetMovePoint(atkarray[i].x, atkarray[i].y)
			else
				--flag: aviod enemies. avoiding as many enemies as possible while retaining targeting the spot with higher threat
				atkarray[i].p = atkarray[i].p + GetMovePoint(atkarray[i].x, atkarray[i].y, 1)
			end
		end
		for i = 1, num - 1 do
			for j = i + 1, num do
				if atkarray[i].p < atkarray[j].p then
					atkarray[i], atkarray[j] = atkarray[j], atkarray[i]
				elseif atkarray[i].p == atkarray[j].p and math.random(2) > 1 then
					atkarray[i], atkarray[j] = atkarray[j], atkarray[i]
				end
			end
		end
		for i = 2, num do
			if atkarray[i].p < atkarray[1].p *4/5 then
				num = i - 1
				break;
			end
		end
		
		local select = 1
		
		War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["�ƶ�����"], 0)
		War_MovePerson(atkarray[select].x, atkarray[select].y)
		War_Fight_Sub(WAR.CurID, kfid, atkarray[select].ax, atkarray[select].ay)
    end    
    --return x,y
end

function Atid(i)
    if WAR.Atid == i then 
        WAR.Person[i].Time = 1000
        WAR.Atid = -1
        return true
    end
    if WAR.Person[i].Time > 1000 then
        return true   
    end
    return false
end

Ct['����ƶ�'] = function()
    local id = WAR.Person[WAR.CurID]['������']
	local lx = 0 
	local x0,y0 = WAR.Person[WAR.CurID]['����X'],WAR.Person[WAR.CurID]['����Y']
	local bs = WAR.Person[WAR.CurID]['�ƶ�����']
	local xx,yy = nil
	local menu = {}

    War_CalMoveStep(WAR.CurID, bs, lx)
	
	for ix = limitX(x0-bs,0),limitX(x0+bs,x0,62) do 
		for iy = limitX(y0-bs,0), limitX(y0+bs,y0,62) do 
			if GetWarMap(ix, iy, 3) ~= 255 and GetWarMap(ix, iy, 2) < 0 then 
			   menu[#menu+1] = {ix,iy}
			end
		end
	end
	
	if #menu > 0 then 
	   local a = math.random(#menu)
	    xx = menu[a][1]
		yy = menu[a][2]
	    War_MovePerson(xx,yy)
	    WAR.Person[WAR.CurID]['�ƶ�����'] = 0
	end
end

Ct['����'] = function(enemyid)
    local pid = WAR.Person[WAR.CurID]['������']
    local eid = WAR.Person[enemyid]['������']
    --�����޷�����
    if WAR.Defup[eid] ~= nil and WAR.Defup[eid] > 0 then 
        return false
    end
    
    if PersonKF(eid,227) then
        return false
    end
 
    if match_ID(pid,9965) then 
        if WAR.LQZ[pid] == nil or WAR.LQZ[pid] < 100 then
            return false
        elseif WAR.LQZ[pid] == 100 then 
            return true
        end
    end
    
    if match_ID(eid,9965) then 
        if WAR.LQZ[eid] == nil or WAR.LQZ[eid] < 100 then
            return false
        elseif WAR.LQZ[eid] == 100 then 
            return true
        end
    end
    
    if match_ID(pid,635) and WAR.Weakspot[eid] ~= nil and WAR.Weakspot[eid] < 6 and (JY.Person[pid]["�������"] > 0 or isteam(pid) == false) then 
        return true
    end
    
    if WAR.Person[enemyid].Time >= -200 and WAR.Person[enemyid].Time <= 200 then 
        return true
    end
    
    if WAR.SJHB_G == 1 then
        return true
    end
    
    if Curr_NG(pid, 93) and JLSD(20,80,pid) then
        return true
    end
    
    if WAR.PD["��"][pid] == 1 then 
        return true    
    end
    return false
end

--��������
function myns(i)
	local eid = WAR.Person[i]['������']
	
	if WAR.CQSX == 1 then 
		return true 
	end
	
	if Curr_NG(eid,207) then 
		return true 
	end
    
	--��������������
    if Curr_NG(eid, 203) then
        return true 
    end	
	
      --�����
	if match_ID(eid,9986) and WAR.FUHUOZT[eid]~=nil  then
		return true 
    end	
		--̫��֮����������
	if WAR.TXZQ[eid] ~= nil and WAR.TXZQ[eid] == 1 then
		return true 
	end	
	return false
end

--������Ѫ
function mylx(i)
	local eid = WAR.Person[i]['������']
	
	if WAR.CQSX == 1 then 
		return true 
	end
	
	return false
end

--�����ж�
function myzd(i)
	local eid = WAR.Person[i]['������']
	
	--½��˫�����ж�
	if match_ID_awakened(eid, 580,1) then
		return true 
	end	
	--̫��֮�������ж�
	if WAR.TXZQ[eid] ~= nil and WAR.TXZQ[eid] == 1 then
		return true 
	end
  	--�屦���۾������ж�
	if WAR.PD['�屦���۾�'][eid] ~= nil  then
		return true 
	end      
	--�嶾�������ж�
	if Curr_NG(eid, 220) then
		return true 
	end
        
	return false
end

--���߷�Ѩ
function myfx(i)
	local eid = WAR.Person[i]['������']
	
	if WAR.CQSX == 1 then 
	    return true 
	end
	
	--��ң�����ۻ�9�㣬δ�ж�ǰ���ᱻ��Ѩ
	if WAR.XYYF[eid] and WAR.XYYF[eid] == 11 then
	    return true 
	end
	
	--�������߷�Ѩ
	if Curr_NG(eid, 104) then
	    return true 
	end
	
	--�����칦�ظ�50ʱ��
	if WAR.ZTHF[eid]~= nil then
		return true 
	end	
	--���ű�ŭ���Ѩ
	if match_ID(eid, 629) and WAR.LQZ[eid] == 100 then
	    return true 
	end	
    --�������߷�Ѩ
	if match_ID(eid,637)  then
	    return true 
	end	 
	
	--����˲Ϣǧ���ŭ״̬���ᱻ��Ѩ
	if Curr_QG(eid,150) and WAR.LQZ[eid]==100 then
		return true 
	end
	return false
end

--���߱���
function mybf(i)
	local eid = WAR.Person[i]['������']
	
	if WAR.CQSX == 1 then 
		return true 
	end
	
	--��������
	if PersonKF(eid,216) then
		return true 
	end
	
	--��һ�����߱���
	if match_ID(eid,633)  then
		return true 
	end	
	
	--���������߱���
	if match_ID(eid,9978)  then
		return true 
	end	
	
	--����
	if match_ID(eid,582) then 
		return true 
	end	
	
	return false
end

--��������
function myzs(i)
	local eid = WAR.Person[i]['������']
	
	if WAR.CQSX == 1 then 
		return true 
	end
	
	return false
end

--���߻���
function myhl(i)

	return false
end

--���߻���
function myhm(i)

	return false
end

Ct['���̳���'] = function(i)
	local id = WAR.Person[i]['������']
	if WAR.ATK['����pd'][id] == nil then 
		WAR.ATK['����table'][#WAR.ATK['����table']+1] = i
		WAR.ATK['����pd'][id] = #WAR.ATK['����table']
	end
end

Ct['�����ƶ�����'] = function()
	local function getnewmove(x, y)
		local mob = x + y
		if mob > 478 then
			return 7
			elseif mob > 328 then
			return 6
			elseif mob >198 then
			return 5
			elseif mob > 148 then
			return 4
		elseif mob > 126 then
			return 3
		elseif mob > 116 then
			return 2
		else
			return 1
		end
	end
        local p = WAR.CurID
        local id = WAR.Person[p]['������']
        --���Ҵ���֮�󣬲����ƶ�
        if WAR.ZYHB == 2 then
			WAR.Person[p]["�ƶ�����"] = 0
		--��Ч�������ƶ�
        elseif WAR.L_NOT_MOVE[WAR.Person[p]["������"]] ~= nil and WAR.L_NOT_MOVE[WAR.Person[p]["������"]] == 1 then
        	WAR.Person[p]["�ƶ�����"] = 0
        	WAR.L_NOT_MOVE[WAR.Person[p]["������"]] = nil
        else
        	--�����ƶ�����
			WAR.Person[p]["�ƶ�����"] = math.modf(getnewmove(WAR.Person[p]["�Ṧ"], JY.Person[id]["����"]) - JY.Person[id]["�ж��̶�"] / 50 - JY.Person[id]["���˳̶�"] / 50)
			
			--�����ж��ƶ���������
			if id == 0 and JY.Base["��׼"] == 9 then
				WAR.Person[p]["�ƶ�����"] = WAR.Person[p]["�ƶ�����"] + math.modf(JY.Person[id]["�ж��̶�"] / 50)
			end
			for j = 0, WAR.PersonNum - 1 do
				--С�ѣ���Ѱ�������Ʋ�����1��
				if match_ID(WAR.Person[j]["������"], 66) and match_ID(WAR.Person[j]["������"], 498) and WAR.Person[j]["����"] == false and WAR.Person[j]["�ҷ�"] ~= WAR.Person[p]["�ҷ�"] then
					WAR.Person[p]["�ƶ�����"] = WAR.Person[p]["�ƶ�����"] - 1
				end
			end

				
			--���޵����������ƣ������ƶ���һ��
			if WAR.TLDW[WAR.Person[p]["������"]] ~= nil and WAR.TLDW[WAR.Person[p]["������"]] == 1 then
				WAR.Person[p]["�ƶ�����"] = WAR.Person[p]["�ƶ�����"] - 1
				WAR.TLDW[WAR.Person[p]["������"]] = nil
			end
			--�żһԵ���Խ�ָ�����ٵ����ƶ�
			if WAR.MBJZ[WAR.Person[p]["������"]] ~= nil then
				WAR.Person[p]["�ƶ�����"] = WAR.Person[p]["�ƶ�����"] - WAR.MBJZ[WAR.Person[p]["������"]]
				WAR.MBJZ[WAR.Person[p]["������"]] = nil
			end
	
			--���㣬���˲����ƶ�
			if WAR.SZZT[id] ~= nil then
				WAR.Person[p]["�ƶ�����"] = WAR.Person[p]["�ƶ�����"] - 15
				WAR.TLDW[WAR.Person[p]["������"]] = nil
				end
				if WAR.Person[p]["�ƶ�����"]<0 then
				WAR.Person[p]["�ƶ�����"] = 0
			
			end			
			--����壬�����Ѫ�����棬�����ᣬ����ƶ�+3��
			if match_ID(id, 35) or match_ID(id, 6) or match_ID(id, 97) or match_ID(id, 606) or match_ID(id, 628) then
				WAR.Person[p]["�ƶ�����"] = WAR.Person[p]["�ƶ�����"] + 3
			end
			--�����ᣬ�ƶ�����8��
			if match_ID(id, 5) and WAR.Person[p]["�ƶ�����"] < 8 then
				WAR.Person[p]["�ƶ�����"] = 8
			end	
			--���˷��죬�貨�����ޣ��ƶ�+1 ��һ�� ��ң��
			if Curr_QG(id,145) or Curr_QG(id,147) or Curr_QG(id,148)   or match_ID(id,633)  or Curr_QG(id,2) then
				WAR.Person[p]["�ƶ�����"] = WAR.Person[p]["�ƶ�����"] + 1
			end
			--�������У�˲Ϣ��һέ�ɽ��ƶ�+2
			if Curr_QG(id,146) or Curr_QG(id,150) or Curr_QG(id,186) then
				WAR.Person[p]["�ƶ�����"] = WAR.Person[p]["�ƶ�����"] + 2
			end
			--̤ѩ�޺ۣ��ƶ�����10��
			if match_ID(id, 511) then
				WAR.Person[p]["�ƶ�����"] = WAR.Person[p]["�ƶ�����"] + 2
			end
			--���㹦�������귭 �ƶ�+2
			if Curr_QG(id,223) or Curr_QG(id,224) then
				WAR.Person[p]["�ƶ�����"] = WAR.Person[p]["�ƶ�����"] + 2
			end			
			--����ѧ�����ٲ����ƶ�+1
			if id == 0 and JY.Person[615]["�۽�����"] == 1 then
				WAR.Person[p]["�ƶ�����"] = WAR.Person[p]["�ƶ�����"] + 1
			end
			--��Ѱ��ѧ����������ˮ���ƶ�+2
			if match_ID(id, 498) and WAR.Person[p]["�ƶ�����"] < 8 then
				WAR.Person[p]["�ƶ�����"] = 8
			end	
			--�¶���ܣ��ƶ�����10��
			if match_ID(id, 592) then
				WAR.Person[p]["�ƶ�����"] = 10
			end
        end

        --����ƶ�����10
        if WAR.Person[p]["�ƶ�����"] > 10 then
			WAR.Person[p]["�ƶ�����"] = 10
        end
		--���㣬���˲����ƶ�
		if WAR.SZZT[id] ~= nil then
		WAR.Person[p]["�ƶ�����"] = WAR.Person[p]["�ƶ�����"] - 10
		WAR.TLDW[WAR.Person[p]["������"]] = nil
		end
		if WAR.PD["����"][id] ~= nil then
		   WAR.Person[p]["�ƶ�����"] = WAR.Person[p]["�ƶ�����"] - 2
		  WAR.TLDW[WAR.Person[p]["������"]] = nil	
		end		
		if WAR.Person[p]["�ƶ�����"]<0 then
            WAR.Person[p]["�ƶ�����"] = 0
			
		end	
end

Ct['�����'] = function()
	if WAR.ZDDH == 356 then
		if WAR.CD == 0 then 
			WAR.PD['�����4'] = {}
			local menu = {}
			local str = {[5] = '��',[27] = '��',[50] = '��',[114] = 'ɽ'}
			for i = 0,WAR.PersonNum-1 do 
				local id = WAR.Person[i]['������']
				if WAR.Person[i]['����'] == false and WAR.Person[i]['�ҷ�'] == false then 
					if id == 5 or id == 27 or id == 50 or id == 114 then 
						menu[#menu+1] = {id,i}
					end
				end
			end
			if #menu > 1 then 
				local m = math.random(#menu)
				local id = menu[m][1]
				for i = 1,#menu do 
					if i ~= m then
						WAR.PD['�����4'][menu[i][1]] = id
					end
				end
				WAR.CurID = menu[m][2]
				CurIDTXDH(WAR.CurID, 19,1,'���ֻ�ɽ��'..str[id],LimeGreen);
			end
			WAR.CD = WAR.TGCD[WAR.ZDDH]
		end
	end
end

Ct['��������쳣'] = function(i)
	local pid = WAR.Person[i]['������']
            local YC = {
            {WAR.KHCM},
            {WAR.SZZT},
            {WAR.YYZS},
            {WAR.WMYH},
            {WAR.FXDS},
            {WAR.XRZT},
            {WAR.SGZT},
            {WAR.CHZT},
            {WAR.HLZT},
            {WAR.TGJF},
            {WAR.HMZT},
            {WAR.CSZT},
            {WAR.XRZT1},
            {WAR.MHZT},
            {WAR.MBJZ},
            {WAR.LXZT},
            {WAR.LRHF},
            {WAR.WZSYZ},
            {WAR.TZ_XZ_SSH},
            {WAR.LSQ},
            {WAR.XZD},
            {WAR.QYZT},
			{WAR.MRSHZT},
            }
            local YC2 = {
			{"����"},
			{"��������"},
            }
            for j = 1,#YC do
                local yc = YC[j][1]
                yc[pid] = nil
            end
            for j = 1,#YC2 do
                local yc = YC2[j][1]
                WAR.PD[yc][pid] = nil
            end
            JY.Person[pid]['���˳̶�'] = 0
            JY.Person[pid]['�ж��̶�'] = 0
            JY.Person[pid]['����̶�'] = 0
            JY.Person[pid]['���ճ̶�'] = 0
            
end