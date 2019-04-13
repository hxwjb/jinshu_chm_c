function Set_Eff_Text(id, txwz, str)
	if WAR.Person[id][txwz] ~= nil then
		WAR.Person[id][txwz] = WAR.Person[id][txwz].."+"..str
	else
		WAR.Person[id][txwz] = str
	end
end

--顶部特效文字 
function TXWZXS(str,cl,n)
    if n == nil then 
	   n = 0
	end
	local i = n 
	if i > 20 then 
		i = 20 
	end	
    Cat('实时特效动画')
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

--返回两人之间的实际距离
function War_realjl(ida, idb)
	if ida == nil then
		ida = WAR.CurID
	end
	CleanWarMap(3, 255)
	local x = WAR.Person[ida]["坐标X"]
	local y = WAR.Person[ida]["坐标Y"]
	local steparray = {}
	steparray[0] = {}
	steparray[0].bushu = {}
	steparray[0].x = {}
	steparray[0].y = {}
	SetWarMap(x, y, 3, 0)
	steparray[0].num = 1
	steparray[0].bushu[1] = 0		--还能移动的步数
	steparray[0].x[1] = x
	steparray[0].y[1] = y
	return War_FindNextStep1(steparray, 0, ida, idb)
end

--AI选择目标的函数
function unnamed(kfid)
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	local kungfuid = JY.Person[pid]["武功" .. kfid]
	local kungfulv = JY.Person[pid]["武功等级" .. kfid]
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
	--AI也用新的威力判定
	local kungfuatk = get_skill_power(pid, kungfuid, kungfulv)
	local atkarray = {}
	local num = 0
	CleanWarMap(4, -1)
	local movearray = War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["移动步数"], 0)
	--Cat('实时特效动画')
	--WarDrawMap(1)
	--ShowScreen()
	--lib.Delay(CC.BattleDelay)
	for i = 0, WAR.Person[WAR.CurID]["移动步数"] do
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
			if WAR.Person[WAR.CurID]["我方"] == true then
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
		
		War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["移动步数"], 0)
		War_MovePerson(atkarray[select].x, atkarray[select].y)
		War_Fight_Sub(WAR.CurID, kfid, atkarray[select].ax, atkarray[select].ay)
		if fjpd(WAR.CurID) then 
			return
		end	
		--阿凡提攻击完躲开
		if pid == 606 then
			WAR.Person[WAR.CurID]["移动步数"] = 10
			War_AutoEscape()
			War_RestMenu()
		end
	else
		if fjpd(WAR.CurID) then 
			return
		end	
			--打不到人，考虑吃药
			local jl, nx, ny = War_realjl()
			AutoMove()
			--默认为休息
			local what_to_do = 0
			local can_eat_drug = 0
			--非我方，会考虑吃药
			if WAR.Person[WAR.CurID]["我方"] == false then
				can_eat_drug = 1
			--如果是我方，只有在队且允许才会吃药
			else
				if isteam(pid) and JY.Person[pid]["是否吃药"] == 1 then
					can_eat_drug = 1
				end
			end
			--侠客正岛主战不吃药
			--洪七公居洪七公不吃药
			if WAR.Person[WAR.CurID]["我方"] == false and (WAR.ZDDH == 188 or WAR.ZDDH == 257) then
				can_eat_drug = 0
			end
			--左右第二下，不能吃药
			if WAR.ZYHB == 2 then
				can_eat_drug = 0
			end
			--1:吃体力药 2：吃血 3：医疗 4：吃内力 5：吃解毒
			if can_eat_drug == 1 then
				local r = -1
				--体力低于10，吃体力药
				if JY.Person[pid]["体力"] < 10 then
					r = War_ThinkDrug(4)
					if r >= 0 then
						what_to_do = 1
					end
				end
				local rate = -1
				if JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 5 then
					rate = 90
				elseif JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 4 then
					rate = 70
				elseif JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 3 then
					rate = 50
				elseif JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 2 then
					rate = 25
				end
				--内伤也增加吃血药几率
				if JY.Person[pid]["受伤程度"] > 50 then
					rate = rate + 50
				end
				if Rnd(100) < rate then
					r = War_ThinkDrug(2)
					if r >= 0 then				--如果有药吃药 
						what_to_do = 2
						
					else
						r = War_ThinkDoctor()		--如果没有药，考虑医疗
						if r >= 0 then
							what_to_do = 3
						end
					end
				end
				--考虑内力
				rate = -1
				if JY.Person[pid]["内力"] < JY.Person[pid]["内力最大值"] / 6 then
					rate = 100
				elseif JY.Person[pid]["内力"] < JY.Person[pid]["内力最大值"] / 5 then
					rate = 75
				elseif JY.Person[pid]["内力"] < JY.Person[pid]["内力最大值"] / 4 then
					rate = 50
				end
				if Rnd(100) < rate then
					r = War_ThinkDrug(3)
					if r >= 0 then
						what_to_do = 4
					end
				end
				rate = -1
				if CC.PersonAttribMax["中毒程度"] * 3 / 4 < JY.Person[pid]["中毒程度"] then
					rate = 60
				else
					if CC.PersonAttribMax["中毒程度"] / 2 < JY.Person[pid]["中毒程度"] then
						rate = 30
					end
				end
				--半血以下，才吃解毒药
				if JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 2 and Rnd(100) < rate then
					r = War_ThinkDrug(6)
					if r >= 0 then
						what_to_do = 5
					end
				end
			end
			--吃药flag 2：生命 3：内力 4：体力 6：解毒
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
	local enemyid=War_AutoSelectEnemy()   --选择最近敌人

	War_CalMoveStep(WAR.CurID,100,0);   --计算移动步数 假设最大100步

	for i=0,CC.WarWidth-1 do
		for j=0,CC.WarHeight-1 do
			local dest=GetWarMap(i,j,3);
			if dest <128 then
				local dx=math.abs(i-WAR.Person[enemyid]["坐标X"])
				local dy=math.abs(j-WAR.Person[enemyid]["坐标Y"])
				if minDest>(dx+dy) then        --此时x,y是距离敌人的最短路径，虽然可能被围住
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

	if minDest<math.huge then   --有路可走
	    while true do    --从目的位置反着找到可以移动的位置，作为移动的次序
			local i=GetWarMap(x,y,3);
			if i<=WAR.Person[WAR.CurID]["移动步数"] then
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
		War_MovePerson(x,y);    --移动到相应的位置
	end
end

function GetMovePoint(x, y, flag)
	local point = 0
	local wofang = WAR.Person[WAR.CurID]["我方"]
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
						if WAR.Person[v]["我方"] == wofang then
							point = point + i * 2 - 26
						elseif WAR.Person[v]["我方"] ~= wofang then
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

function War_FindNextStep1(steparray,step,id,idb)      --设置下一步可移动的坐标
	--被上面的函数调用   
	local num=0;
	local step1=step+1;
	
	steparray[step1]={};
	steparray[step1].bushu={};
	steparray[step1].x={};
	steparray[step1].y={};
	
	local function fujinnum(tx,ty)
		local tnum=0
		local wofang=WAR.Person[id]["我方"]
		local tv;
		tv=GetWarMap(tx+1,ty,2);
		if idb==nil then
			if tv~=-1 then
				if WAR.Person[tv]["我方"]~=wofang then
					return -1
				end
			end
		elseif tv==idb then
			return -1
		end
		if tv~=-1 then
			if WAR.Person[tv]["我方"]~=wofang then
				tnum=tnum+1
			end
		end
		tv=GetWarMap(tx-1,ty,2);
		if idb==nil then
			if tv~=-1 then
				if WAR.Person[tv]["我方"]~=wofang then
					return -1
				end
			end
		elseif tv==idb then
			return -1
		end
		if tv~=-1 then
			if WAR.Person[tv]["我方"]~=wofang then
				tnum=tnum+1
			end
		end
		tv=GetWarMap(tx,ty+1,2);
		if idb==nil then
			if tv~=-1 then
				if WAR.Person[tv]["我方"]~=wofang then
					return -1
				end
			end
		elseif tv==idb then
			return -1
		end
		if tv~=-1 then
			if WAR.Person[tv]["我方"]~=wofang then
				tnum=tnum+1
			end
		end
		tv=GetWarMap(tx,ty-1,2);
		if idb==nil then
			if tv~=-1 then
				if WAR.Person[tv]["我方"]~=wofang then
					return -1
				end
			end
		elseif tv==idb then
			return -1
		end
		if tv~=-1 then
			if WAR.Person[tv]["我方"]~=wofang then
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
	    if x+1<CC.WarWidth-1 then                        --当前步数的相邻格
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

	    if x-1>0 then                        --当前步数的相邻格
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

	    if y+1<CC.WarHeight-1 then                        --当前步数的相邻格
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

	    if y-1>0 then                        --当前步数的相邻格
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
--修炼物品
function War_PersonTrainDrug(pid)
	local p = JY.Person[pid]
	local thingid = p["修炼物品"]
	if thingid < 0 then
		return 
	end
	if JY.Thing[thingid]["练出物品需经验"] <= 0 then
		return 
	end
	local needpoint = (7 - math.modf(p["资质"] / 15)) * JY.Thing[thingid]["练出物品需经验"]
	if p["物品修炼点数"] < needpoint then
		return 
	end
	  
	local haveMaterial = 0
	local MaterialNum = -1
	for i = 1, CC.MyThingNum do
		if JY.Base["物品" .. i] == JY.Thing[thingid]["需材料"] then
			haveMaterial = 1
			MaterialNum = JY.Base["物品数量" .. i]
		end
	end
  
	--材料足够
	if haveMaterial == 1 then
		local enough = {}
		local canMake = 0
		for i = 1, 5 do
			if JY.Thing[thingid]["练出物品" .. i] >= 0 and JY.Thing[thingid]["需要物品数量" .. i] <= MaterialNum then
				canMake = 1
				enough[i] = 1
			else
				enough[i] = 0
			end
		end
		--可以练出
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
			
			local newThingID = JY.Thing[thingid]["练出物品" .. makeID]
			DrawStrBoxWaitKey(string.format("%s 制造出 %s", p["姓名"], JY.Thing[newThingID]["名称"]), C_WHITE, CC.DefaultFont)
			if instruct_18(newThingID) == true then
				instruct_32(newThingID, 1)
			else
				instruct_32(newThingID, 1)
			end
			instruct_32(JY.Thing[thingid]["需材料"], -JY.Thing[thingid]["需要物品数量" .. makeID])
			p["物品修炼点数"] = 0
		end
	end
end
--计算敌人中毒点数
--pid 使毒人，
--enemyid  中毒人
function War_PoisonHurt(pid, enemyid)
	local vv = math.modf((JY.Person[pid]["用毒能力"] - JY.Person[enemyid]["抗毒能力"]) / 4)
	--胡青牛在场王难姑用毒+50
	if JY.Status == GAME_WMAP then
		for i,v in pairs(CC.AddPoi) do
			if match_ID(pid, v[1]) then
				for wid = 0, WAR.PersonNum - 1 do
					if match_ID(WAR.Person[wid]["人物编号"], v[2]) and WAR.Person[wid]["死亡"] == false then
						vv = vv + v[3] / 4
					end
				end
			end
		end
	end
	vv = vv - JY.Person[enemyid]["内力"] / 200
	for i = 1, JY.Base["武功数量"] do
		if JY.Person[enemyid]["武功" .. i] == 108 then
			vv = 0
		end
	end
	vv = math.modf(vv)
	if vv < 0 then
		vv = 0
	end
	return AddPersonAttrib(enemyid, "中毒程度", vv)
end

--人物按轻功进行排序
function WarPersonSort(flag)
	for i = 0, WAR.PersonNum - 1 do
		local id = WAR.Person[i]["人物编号"]
		local add = 0
		local p = JY.Person[id]
	
		
		--金雁功
		if Curr_QG(id,223) then
		   add =add + math.modf(JY.Person[id]["轻功"]*0.2)
		 end

		--逍遥游
		if Curr_QG(id,2) then
		  add = add + 20
		end	 
		
		WAR.Person[i]["轻功"] = Qg(i) + (add)
	--敌方的战场轻功会根据内力和等级加成
		--if WAR.Person[i]["我方"] then
		  
		--else
			--WAR.Person[i]["轻功"] = WAR.Person[i]["轻功"] + math.modf(JY.Person[id]["内力最大值"] / 50) + JY.Person[id]["等级"]
		--end
		--情侣加成
		for ii,v in pairs(CC.AddSpd) do
			if match_ID(id, v[1]) then
				for wid = 0, WAR.PersonNum - 1 do
					if match_ID(WAR.Person[wid]["人物编号"], v[2]) and WAR.Person[wid]["死亡"] == false then
						WAR.Person[i]["轻功"] = WAR.Person[i]["轻功"] + v[3]
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
			if WAR.Person[maxid]["轻功"] < WAR.Person[j]["轻功"] then
				maxid = j;
			end
		end
		WAR.Person[maxid], WAR.Person[i] = WAR.Person[i], WAR.Person[maxid]
	end
end

--显示非攻击时的点数
function War_Show_Count(id, str)
	if JY.Restart == 1 then
		return
	end
	
	local pid = WAR.Person[id]["人物编号"];
	local x = WAR.Person[id]["坐标X"];
	local y = WAR.Person[id]["坐标Y"];
	
	local hp = WAR.Person[id]["生命点数"];
	local mp = WAR.Person[id]["内力点数"];
	local tl = WAR.Person[id]["体力点数"];
	local ed = WAR.Person[id]["中毒点数"];
	local dd = WAR.Person[id]["解毒点数"];
	local ns = WAR.Person[id]["内伤点数"];
  
	local show = {x, y, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil};		--x, y, 生命, 内力, 体力, 封穴, 流血, 中毒, 解毒, 内伤，冰封，灼烧
	
	if hp ~= nil and hp ~= 0 then		--显示生命
		if hp > 0 then
			show[3] = "生命+"..hp;
		else
			show[3] = "生命"..hp;
		end
	end
	
	if mp ~= nil and mp ~= 0 then		--显示内力
		if mp > 0 then
			show[5] = "内力+"..mp;
		else
			show[5] = "内力"..mp;
		end
	end
	
	if tl ~= nil and tl ~= 0 then		--显示体力
		if tl > 0 then
			show[6] = "体力+"..tl;
		else
			show[6] = "体力"..tl;
		end
	end
	
    if WAR.FXXS[WAR.Person[id]["人物编号"]] ~= nil and WAR.FXXS[WAR.Person[id]["人物编号"]] == 1 then			--显示是否封穴
       	show[7] = "封穴 "..WAR.FXDS[WAR.Person[id]["人物编号"]];
       	WAR.FXXS[WAR.Person[id]["人物编号"]] = 0
    end
      
    if WAR.LXXS[WAR.Person[id]["人物编号"]] ~=nil and WAR.LXXS[WAR.Person[id]["人物编号"]] == 1 then		--显示是否被流血
      	show[8] = "流血 "..WAR.LXZT[WAR.Person[id]["人物编号"]];
        WAR.LXXS[WAR.Person[id]["人物编号"]] = 0
    end
	
	if ed ~= nil and ed ~= 0 then		--显示中毒
		show[9] = "中毒+"..ed;
	end
	
	if dd ~= nil and dd ~= 0 then		--显示解毒
		show[4] = "中毒-"..dd;
	end
	
	if ns ~= nil and ns ~= 0 then		--显示内伤
		if ns > 0 then
			show[10] = "内伤↑"..ns;
		else
			show[10] = "内伤↓"..-ns;
		end
	end
	
	if WAR.BFXS[WAR.Person[id]["人物编号"]] == 1 then		--显示是否被冰封
		show[11] = "冰封 "..JY.Person[WAR.Person[id]["人物编号"]]["冰封程度"];
		WAR.BFXS[WAR.Person[id]["人物编号"]] = 0
	end
		
	if WAR.ZSXS[WAR.Person[id]["人物编号"]] == 1 then		--显示是否被灼烧
		show[12] = "灼烧 "..JY.Person[WAR.Person[id]["人物编号"]]["灼烧程度"];
		WAR.ZSXS[WAR.Person[id]["人物编号"]] = 0
	end
	
	--记录哪个位置上有点数
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
  
	local ll = string.len(show[showValue[1]]);	--长度
	
	local w = ll * CC.DefaultFont / 2 + 1
	local clip = {x1 = CC.ScreenW / 2 - w/2 - CC.XScale/2, y1 = CC.YScale + CC.ScreenH / 2 - hb, x2 = CC.XScale + CC.ScreenW / 2 + w, y2 = CC.YScale + CC.ScreenH / 2 + CC.DefaultFont + 1}
	local area = (clip.x2 - clip.x1) * (clip.y2 - clip.y1) + CC.DefaultFont*4		--绘画的范围
	--local surid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)		--绘画句柄

	for i = 5, 18 do
		if JY.Restart == 1 then
			break
		end
		local tstart = lib.GetTime()
		local y_off = i * 2
		
		--lib.SetClip(0, 0, CC.ScreenW, CC.ScreenH)
		--lib.LoadSur(surid, 0, 0)
		--显示文字
		Cat('实时特效动画')
		Cls()
		if str ~= nil then
			DrawString(clip.x1 - #str*CC.Fontsmall/5 + 30, clip.y1 - y_off - CC.DefaultFont*4, str, C_WHITE, CC.Fontsmall);
		end
		for j=1, showNum do
			local c = showValue[j] - 1;
			if showValue[j] == 3 and (string.sub(show[3],1,1) == "-" or string.sub(show[3],2,2) == "-") then		--减少生命，显示为红色
				c = 1;
			end
			DrawString(clip.x1, clip.y1 - y_off - (showNum-j+1)*CC.DefaultFont, show[showValue[j]], WAR.L_EffectColor[c], CC.DefaultFont); 	
		end 
		ShowScreen()
		lib.Delay(CC.BattleDelay)
	end
  
	--lib.SetClip(0, 0, 0, 0)		--清除
	WAR.Person[id]["生命点数"] = nil;
	WAR.Person[id]["内力点数"] = nil;
	WAR.Person[id]["体力点数"] = nil;
	WAR.Person[id]["中毒点数"] = nil;
	WAR.Person[id]["解毒点数"] = nil;
	WAR.Person[id]["内伤点数"] = nil;
	Cls()
	--lib.FreeSur(surid)
end

--计算医疗量
--id1 医疗id2, 返回id2生命增加点数
function ExecDoctor(id1, id2)
	if JY.Person[id1]["体力"] < 50 then
		return 0
	end
	local add = JY.Person[id1]["医疗能力"]
	local value = JY.Person[id2]["受伤程度"]
	if add + 20 < value then
		return 0
	end
  
	-- 平一指，医疗量和杀人数有关
	if match_ID(id1, 28) and JY.Status == GAME_WMAP then
		add = math.modf(JY.Person[id1]["医疗能力"] * (1 + WAR.PYZ / 10))
	end
  
	--战斗状态的医疗
	--胡斐在场程灵素医疗+120
	--王难姑在场胡青牛医疗+50
	if JY.Status == GAME_WMAP then
		for i,v in pairs(CC.AddDoc) do
			if match_ID(id1, v[1]) then
				for wid = 0, WAR.PersonNum - 1 do
					if match_ID(WAR.Person[wid]["人物编号"], v[2]) and WAR.Person[wid]["死亡"] == false then
						add = add + v[3]
					end
				end
			end
		end
	end
  
	add = add - (add) * value / 200
	add = math.modf(add) + Rnd(5)
  
	local n = AddPersonAttrib(id2, "受伤程度", -math.modf((add) / 10))
	--蓝烟清：医疗时显示内伤减少
	if JY.Status == GAME_WMAP then
		local p = -1;
		for wid = 0, WAR.PersonNum - 1 do
			if WAR.Person[wid]["人物编号"] == id2 and WAR.Person[wid]["死亡"] == false then
				p = wid;
				break;
			end
		end
		WAR.Person[p]["内伤点数"] = n;
	end
	return AddPersonAttrib(id2, "生命", add)
end

--无酒不欢：计算武功伤害，WAR.CurID为攻击方
function War_WugongHurtLife(enemyid, wugong, level, ang, x, y)
    
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	local eid = WAR.Person[enemyid]["人物编号"]
	--气防
	local dng = 0
	local WGLX = JY.Wugong[wugong]["武功类型"]
	
	--李沅芷
	local LYZ = 0
	--赵敏在场

	local hurt = nil
	--无酒不欢：这里引入伤害二，计算保底伤害
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
	--无酒不欢：记录人物血量
	WAR.Person[enemyid]["Life_Before_Hit"] = JY.Person[eid]["生命"]
	WAR.Person[enemyid]["Neili_Before_Hit"] = JY.Person[eid]["内力"]
	
	--是否为敌人
	local function DWPD()

		--逆转乾坤状态下默认为敌人
		if WAR.Person[enemyid]["我方"] ~= WAR.Person[WAR.CurID]["我方"] or WAR.NZQK > 0 or WAR.HLZT[pid] ~= nil then
			return true
		else
			return false
		end
	end
  
	--几率抽签函数：X值大于1时，随机返回X值的50%~100%
	local function myrnd(x)
		if x <= 1 then
			return 0
		end
		return math.random(x * 0.5, x)
	end
	
	--获取武功的真实威力
	local true_WL = get_skill_power(pid, wugong, level)

	--无酒不欢：攻方基础攻击
	local atk = Atk(WAR.CurID)--JY.Person[pid]["攻击力"]
	--无酒不欢：守方基础防御
	local def = Def(enemyid)--JY.Person[eid]["防御力"]
	
	--无酒不欢：系数减伤
	local defadd = 0
	local wgtype = JY.Wugong[wugong]["武功类型"];
	local NPCgxf = 1;
	local NPCfxf = 1;
	local defadd_max = 0

	--无酒不欢：最终伤害计算，难度系数
	local difficulty_factor = 1;
	--我方攻击时
	
	local mywuxue = 0
	local emenywuxue = 0
	for i = 0, WAR.PersonNum - 1 do
		local id = WAR.Person[i]["人物编号"]
		
		--武学常识共用
		if WAR.Person[i]["死亡"] == false and JY.Person[id]["武学常识"] > 10 then
			if WAR.Person[WAR.CurID]["我方"] == WAR.Person[i]["我方"] and mywuxue < JY.Person[id]["武学常识"] then
				mywuxue = JY.Person[id]["武学常识"]
			end
			if WAR.Person[enemyid]["我方"] == WAR.Person[i]["我方"] and emenywuxue < JY.Person[id]["武学常识"] then
				emenywuxue = JY.Person[id]["武学常识"]
			end
		end
		
		if emenywuxue < 10 then
			emenywuxue = 10
		end
	end
	
	--无酒不欢：一些高封穴的人物
	--扫地，任我行，王重阳，一灯，成昆，龙岛主，玄慈，段延庆，黄药师，穆人清
	local gfxp = {114, 26, 129, 65, 18, 39, 70, 98, 57, 185}
	--无酒不欢：一些高流血的人物
	local glxp = {6, 3, 40, 97, 103, 19, 60, 71}

	--大周天功 大宗师 
	if WAR.DZTG_DZS == 1 or match_ID(pid,574) then
		if WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[enemyid]["我方"] then
			emenywuxue = emenywuxue*0.2
		end
	end	
	
	local hwxonbf = mywuxue
	if hwxonbf < emenywuxue then
		hwxonbf = emenywuxue
	end
	
	if match_ID(pid, 592) then
		if WAR.Person[WAR.CurID]["我方"] then
			mywuxue = hwxonbf
		else
			emenywuxue = hwxonbf
		end
	elseif match_ID(eid, 592) then
		if WAR.Person[WAR.CurID]["我方"] then
			emenywuxue = hwxonbf
		else
			mywuxue = hwxonbf
		end
	end
	
	--计算实际使用武功等级
	while true do
		if JY.Person[pid]["内力"] < math.modf((level + 1) / 2) * JY.Wugong[wugong]["消耗内力点数"] then
			level = level - 1
		else
			break;
		end
	end

	--防止出现左右互博时第一次攻击完毕，第二次攻击没有内力的情况。
	if level <= 0 then
		level = 1
	end

	
------------------------------------------------------------------------------------
-----------------------------------一些特效-----------------------------------------
------------------------------------------------------------------------------------
	
	
------------------------------------闪避计算--------------------------------------

	
    if match_ID(pid, 510) and WAR.PD['曲径通幽'][pid] == 1 then 

    --阿青听风辨位
    elseif match_ID(pid, 604) then
		if WAR.TFBW == 0 then
			WAR.TFBW = 1
			Set_Eff_Text(WAR.CurID, "特效文字0", "听风辨位")
		end
	--李寻欢 小李飞刀 例无虚发
	elseif  match_ID(pid, 498) and WAR.XLFD[pid]~=nil then
		if WAR.TFBW == 0 then
			WAR.TFBW = 1
			Set_Eff_Text(WAR.CurID, "特效文字0", "例无虚发")
		end	
	--
	elseif WAR.JYZJ_FXJ == 1 then
		--if WAR.TFBW == 0 then
		--	WAR.TFBW = 1
		--end				
	--惊天一剑 无视闪壁
	elseif WAR.JTYJ[pid]~= nil or WAR.SL23  == 1 then 
		--if WAR.TFBW == 0 then
		--	WAR.TFBW = 1
		--end				
	--天罗地网  
	elseif Curr_QG(pid,148) then
		if WAR.TLDWX == 0 then
			WAR.TLDWX = 1
			Set_Eff_Text(WAR.CurID, "特效文字0", "天罗地网")
		end
	--岳云岳家枪法必命中
	elseif match_ID(pid,568) and wugong == 200 then
		--if WAR.TFBW == 0 then
		--	WAR.TFBW = 1
		--end	
	--心念合一
	elseif WAR.Focus[pid] ~= nil then		
	--达尔巴死战
	elseif match_ID(pid, 160) and WAR.SZSD == eid then
        
    elseif WAR.PD['降龙·见龙在田'][pid] == 1 then	
	else
		--无酒不欢：凌波微步，15%几率闪避
		if Curr_QG(eid, 147) and JLSD(0,15,eid) then
			local jl = 0
			if inteam(eid) then
				jl = 15
			else
				jl =30
			end
			WAR.Dodge = 1
			WAR.Person[enemyid]["特效文字2"] = "凌波微步"

		end
            --end
		--祖千秋，30%闪避
		if match_ID(eid, 88) and JLSD(0,30,eid) then
			WAR.Dodge = 1
			WAR.Person[enemyid]["特效文字2"] = "酒神秘踪步"	
		end
        
        if match_ID(eid, 9965) then 
            local jl = 5 
            if WAR.PD['八酒杯'][eid] ~= nil then
                jl = jl + 30
            end
            if JLSD(0,jl,eid) then
                WAR.Dodge = 1
                WAR.Person[enemyid]["特效文字2"] = "八酒杯·酒神迷踪步"
            end    
        end
        
			--萧秋水 风流，15%闪避
		if (match_ID(eid, 652) or Curr_NG(eid,177)) and JLSD(0,15,eid) and JY.Base["天书数量"] > 4  then
			WAR.Dodge = 1
			WAR.Person[enemyid]["特效文字2"] = "风流"	
			WAR.Person[enemyid]["特效动画"] = 89
			
		end

		--段誉 指令，50%闪避
		if match_ID(eid, 53) and WAR.TZ_DY == 1 and JLSD(0,50,eid) then
			WAR.Dodge = 1
			WAR.Person[enemyid]["特效文字2"] = "凌波微步"
		end
		
		--袁冠南 闪避
		if match_ID(eid, 566) then
			local sbjl = 15
			if  JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 4 then 
				sbjl = sbjl+20
			elseif JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 2 then 
				sbjl = sbjl+10 
			end	
			if JLSD(0,sbjl,eid) then
				WAR.Dodge = 1
		    end
	    end
		
		--黄蓉奇门遁甲，紫色，30%闪避
		if WAR.Person[enemyid]["我方"] == true and GetWarMap(WAR.Person[enemyid]["坐标X"], WAR.Person[enemyid]["坐标Y"],6) == 4 and JLSD(0,30,eid) then
			WAR.Dodge = 1
		end
		
		--进阶泰山，使用后30时序内闪避
		if WAR.TSSB[eid] ~= nil and JLSD(0,20,eid) then
			WAR.Dodge = 1
			WAR.Person[enemyid]["特效文字2"] = "峻岭横空"
		end

		--李白，使用后30时序内闪避
		if WAR.QLJX[eid] ~= nil and JLSD(20, 70, eid) then
			WAR.Dodge = 1
			WAR.Person[enemyid]["特效文字2"] = "深藏身与名"
		end
		
		--主角 特系，初始15%闪避，每个奇门练到极，增加5%闪避
		if JY.Base["标准"] == 5 and eid == 0 then
			local gctj = 15
			for i = 1, JY.Base["武功数量"] do
				if JY.Wugong[JY.Person[0]["武功" .. i]]["武功类型"] == 5 and JY.Person[0]["武功等级" .. i] == 999 then
					gctj = gctj + 5
				end
			end
			if gctj > 50 then
				gctj = 50
			end
			if JLSD(0,gctj,eid) then
				WAR.Dodge = 1
				WAR.Person[enemyid]["特效文字1"] = "天机身法"		--天机身法
			end
		end
		--李沅芷 闪避
		if ZDGH(enemyid,569) and JLSD(0,15,eid) then	
			WAR.Dodge = 1
			WAR.Person[enemyid]["特效文字1"] = "沅芷澧兰"		
		end
		
		--葵花移行 		--萧半和觉醒
		if Curr_NG(eid, 105)  then
			--葵花尊者必定移形
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
				WAR.Person[enemyid]["特效文字2"] = "真.葵花移形"
				WAR.Person[enemyid]["特效动画"] = 89
			end
		end
		
		--if inteam(eid) then
			for i = 0, WAR.PersonNum - 1 do
				local zid = WAR.Person[i]["人物编号"]
				if WAR.Person[i]["死亡"] == false and WAR.Person[i]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and match_ID(zid, 609) then
                    if WAR.Defup[eid] == 1 and JLSD(0,20,zid) then
                        WAR.Dodge = 1
                    end
					break
				end
			end
		--end
		
		--被刺目，伤害杀气降低15%，有15%几率miss
		if WAR.KHCM[pid] == 2 then
			if WAR.MMGJ == 1 then
				WAR.Dodge = 1
			end
		end
		
		-- 蛇行狸翻 15%闪避
		if Curr_QG(eid,224) then
			if JLSD(0,15,eid) then
				WAR.Dodge = 1
			end
		end
		-- 逍遥游 10%闪避
		if Curr_QG(eid,2)  then
			local jl = 10
			if JLSD(0,jl,eid) then
				WAR.Dodge = 1
			end	
		end
		
		--无酒不欢：神行百变，12%几率闪避
		if Curr_QG(eid, 146) then
			local c_up = 0
			local jl = 12

			--袁承志觉醒后，闪避率+5%
			if match_ID_awakened(eid, 54, 1) then
				c_up = 10
			end
			if JLSD(0,jl+c_up,eid) then
				WAR.Dodge = 1
				WAR.Person[enemyid]["特效文字2"] = "神行百变"
			end
		end
    end
    
	--无酒不欢：闪避统一结算
	if WAR.Dodge == 1 then
        
		WAR.Miss[eid] = 1
		WAR.Person[enemyid]['闪避'] = true
		WAR.MissPd = 1
		WAR.Dodge = 0
		hurt = 0
		--白驹过隙
	    if  match_ID(eid, 566) then
			WAR.Person[enemyid]["特效文字2"] = "白驹过隙"
			if fjpd(WAR.CurID) == false and MyFj(WAR.CurID) == false then
				WAR.Person[enemyid]['反击'] = 1
			end
	    end
	
		--无量禅震
		if match_ID(pid,9994) then 
        --if pid == 0 then    
			if WAR.PD['无量禅震'][pid] == nil then
                WAR.PD['无量禅震'][pid] = {}
                WAR.PD['无量禅震'][pid].n = 1
                WAR.PD['无量禅震'][pid].s = 1
            else 
                if WAR.PD['无量禅震'][pid].s == nil then
                    WAR.PD['无量禅震'][pid].s = 1
                    WAR.PD['无量禅震'][pid].n = (WAR.PD['无量禅震'][pid].n or 0) + 1
                end
			end
		end
		goto label0
	end
	
	--闪避的人不受状态
	if WAR.Miss[eid] == nil then 
	
		--雪花神剑
		if WAR.BXXHSJ ==1 and DWPD() then
			JY.Person[eid]["冰封程度"] = JY.Person[eid]["冰封程度"] + 10 + Rnd(10)
			if JY.Person[eid]["冰封程度"] > 100 then
				JY.Person[eid]["冰封程度"] = 100
			end
			WAR.BFXS[eid] = 1
			if WAR.Person[enemyid]["特效动画"] == -1 or WAR.Person[enemyid]["特效动画"] == 63 then
				WAR.Person[enemyid]["特效动画"] = 80
			end
		end

        if PersonKF(eid,227) then
            local gl = 25 
            local bl = limitX(JY.Person[eid]['生命']/JY.Person[eid]['生命最大值'],0.25,1)
            local gl2 = math.modf((1-bl)*100)
            if JLSD(0,gl+gl2,eid) then 
                WAR.Defup[eid] = 1
            end
        end
        
		-- 白绣
		if match_ID(pid,582) and JY.Person[eid]["冰封程度"] > 50 and (JLSD(20,70,pid) or WAR.LQZ[pid] == 100) then
			WAR.LRHF[eid] = 10
			WAR.Person[enemyid]["特效动画"] = 116
		end	

        if match_ID(pid, 510) and WAR.PD['曲夕烟隙'][pid] == 1 then
            WAR.HLZT[eid] = 1
        end
        
		--萧秋水攻击冰封大于50的敌人，有60%几率将其冻结5时序
		if (match_ID(pid,652)  or Curr_NG(pid,177)) and JY.Person[eid]["冰封程度"] > 50 and (JY.Base["天书数量"] > 1 or isteam(pid) == false) and JLSD(20,70,pid) and DWPD() then
			WAR.LRHF[eid] = 5
			WAR.Person[enemyid]["特效动画"] = 116
			Set_Eff_Text(enemyid, "特效文字3", "月映")
		end
		
		--萧秋水攻击燃烧大于50的敌人，将其引燃
		if (match_ID(pid,652)  or Curr_NG(pid,177)) and JY.Person[eid]["灼烧程度"] > 50 and JY.Base["天书数量"] > 2 
		and JLSD(20,70,pid) and DWPD() then
			WAR.JHLY[eid] = 10
			WAR.Person[enemyid]["特效动画"] = 127
			Set_Eff_Text(enemyid, "特效文字3", "日明")
		end	

		--游坦之攻击冰封大于50的敌人，有60%几率将其冻结10时序
		if match_ID(pid,48) and JY.Person[eid]["冰封程度"] > 50 and JLSD(20,80,pid) and DWPD() then
			WAR.LRHF[eid] = 10
			WAR.Person[enemyid]["特效动画"] = 116
			Set_Eff_Text(enemyid, "特效文字3", "千年冰蚕·冻结")
		end
		
		--胡一刀装备冷月宝刀攻击冰封大于50的敌人，有60%几率将其冻结10时序
		if match_ID(pid,633) and JY.Person[pid]["武器"] == 45  and JY.Person[eid]["冰封程度"] > 50 and JLSD(20,80,pid) and DWPD() then
			WAR.LRHF[eid] = 10
			WAR.Person[enemyid]["特效动画"] = 116
			Set_Eff_Text(enemyid, "特效文字3", "冷月刀气·冻结")
		end	
		
		--神鲸歌
		if WAR.JXG_SJG ==1 and  DWPD()  then
			WAR.LSQ[eid] = 30
		end
		
		--被灵蛇拳击中
		if WAR.OYK == 1 and DWPD() then
			WAR.LSQ[eid] = 20
		end
		
		--被杨逍击中的人，伤害增加1%，上限20%
		if match_ID(pid,11) and DWPD() then
			WAR.GMZS[eid] = (WAR.GMZS[eid] or 0) + 1
			if WAR.GMZS[eid] > 20 then
				WAR.GMZS[eid] = 20
			end
		end
		--扫地放下屠刀
		if match_ID(pid,9963) and JLSD(0,50,pid) and DWPD() then
			WAR.PD["放下屠刀"][eid] = 1
			Set_Eff_Text(enemyid,"特效文字0","放下屠刀")
			if WAR.Person[enemyid]["特效动画"] == nil or WAR.Person[enemyid]["特效动画"] == -1 then
			   WAR.Person[enemyid]["特效动画"] = 142
			end			
		end
		 --九阳神功招式1虚弱
		if WAR.JYZS == 1 and DWPD() then
			WAR.XRZT[eid] = 60
			if WAR.Person[enemyid]["特效动画"] == nil or WAR.Person[enemyid]["特效动画"] == -1 then
				WAR.Person[enemyid]["特效动画"] = 80
			end
			Set_Eff_Text(enemyid,"特效文字3","虚弱")
		end	
		 --青莲剑歌 创伤
		 if WAR.QLJG == 1 and DWPD() then
			WAR.PD['创伤'][eid] = 60
			if WAR.Person[enemyid]["特效动画"] == nil or WAR.Person[enemyid]["特效动画"] == -1 then
				WAR.Person[enemyid]["特效动画"] = 80
			end
			Set_Eff_Text(enemyid,"特效文字3","创伤")
		end		
	    --先天罡气清蓄力
	    if PersonKF(pid,100) then
		   WAR.PD["先天罡气"][pid] = 1
		    if WAR.PD["太极蓄力"][eid] ~= nil or WAR.PD["蛤蟆蓄力"][eid] ~= nil or WAR.PD["鲸息蓄力"][eid] ~= nil then
			   if WAR.Person[enemyid]["特效动画"] == nil or WAR.Person[enemyid]["特效动画"] == -1 then
				  WAR.Person[enemyid]["特效动画"] = 80
			   end
			 Set_Eff_Text(enemyid,"特效文字3","罡气破力")
		   end
       end
		--雷动九天
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
		
		--苗人凤指令 破军
		if match_ID(pid, 3) and WAR.MRF == 1 then
			WAR.SGZT[eid] = 50
		end

		--九阳神功招式2散功状态，敌人停止动功 并时序流失1%内力
		if WAR.JYZS == 2 and DWPD() then
			WAR.SGZT[eid] = 20
		end	
		
		-- 梅花三弄1
		if WAR.MHSN == 1 and WAR.ACT == 1 and  DWPD()then 
			WAR.SGZT[eid] = 20
		end	
		
		--金轮，十龙十象蓄力
		if WAR.SLSX[pid] ~= nil and DWPD() then
			WAR.HMZT[eid] = 1
		end
		
        if WAR.PD['降龙·震惊百里'][pid] == 1 and DWPD() then 
            WAR.HMZT[eid] = 1
        end
        
		--何太冲，攻击时60%几率附加琴音状态，上限20层
		if match_ID(pid, 7) and DWPD() then
			if WAR.QYZT[eid] == nil then
				WAR.QYZT[eid] = math.random(3)
			else
				WAR.QYZT[eid] = WAR.QYZT[eid] + math.random(3)
				if WAR.QYZT[eid] > 20 then
					WAR.QYZT[eid] = 20
				end
			end
			if WAR.Person[enemyid]["特效动画"] == nil or WAR.Person[enemyid]["特效动画"] == -1 then
				WAR.Person[enemyid]["特效动画"] = 63
			end
			Set_Eff_Text(enemyid,"特效文字0","铁琴琴音")
		end
		
		--辰宿列张
		if PersonKF(pid,138) and DWPD() then 
			if WAR.MRSHZT[eid] == nil then
				WAR.MRSHZT[eid] = math.random(2)
			else
				WAR.MRSHZT[eid] =WAR.MRSHZT[eid] + math.random(2)
				if WAR.MRSHZT[eid] > 3 then
					WAR.MRSHZT[eid] = 3	   
				end
			end
			if WAR.Person[enemyid]["特效动画"] == nil or WAR.Person[enemyid]["特效动画"] == -1 then
				WAR.Person[enemyid]["特效动画"] = 72
			end
			Set_Eff_Text(enemyid,"特效文字0","参合")	
		end

			--葵花 六合
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
		
        if WAR.PD['封字决'][pid] == 1 and DWPD() then 
            WAR.YYZS[eid] = 1
        end
        
        if WAR.PD['缠字决'][pid] == 1 and DWPD() then 
            if WAR.CHZT[eid] == nil then
                WAR.CHZT[eid] = 20
            else
                WAR.CHZT[eid] = WAR.CHZT[eid] + 20
            end
			if WAR.CHZT[eid] > 20 then
				WAR.CHZT[eid] = 20
			end
        end
        
			--九字真言
		if WAR.PD["列"][pid]~= nil and WAR.PD["列"][pid] == 1 then
			WAR.MBJZ[eid] = 3
		end
		
	   -- 六脉大招4
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
		
		--卓天雄震天铁掌
		if match_ID(pid,613) and wugong == 205 and JLSD(10,20,pid) and DWPD() then
			WAR.HMZT[eid] = 1
		end	
		
		--雷动九天
		if WAR.LQZ[pid] == 100 and WAR.WTL_LDJT[eid] ~= nil and WAR.WTL_LDJT[eid] >=3 and DWPD() then
			WAR.HMZT[eid] = 1
			WAR.WTL_LDJT[eid] = nil
		end	

		--云罗天网 锁足
		if WAR.YLTW == 1 and JLSD(20,70,pid) and DWPD()  then
			WAR.SZZT[eid] = 1
		end	
		
		--野球拳 锁足
		if WAR.PD['野球拳'][pid] == 3 and DWPD() and JLSD(0,40,pid) then
			WAR.SZZT[eid] = 1
		end	
        
        if WAR.PD['绊字决'][pid] == 1 and DWPD() then 
            WAR.SZZT[eid] = 1
        end
        
		--虚弱1
		if WAR.NZZ1 ==1 and DWPD() then
			WAR.XRZT1[eid] = 1
		end
		if  WAR.DHBUFF == 1 and DWPD() then
			WAR.PD["洞火"][eid] = 1
	     end	
		--魅惑状态
		--if WAR.AJFHNP ==1 and DWPD() then
			--WAR.MHZT[eid] = 2
		--end	
		
		--一灯用一阳指，无明业火
		if match_ID(pid, 65) and wugong == 17 and DWPD() then
			WAR.WMYH[eid] = 30
		end
		
		--王重阳1  同归剑气，
		if match_ID(pid,129) and DWPD() then
			WAR.TGJF[eid] = 1
		end	
		
		--无酒不欢：利刃寒锋，修罗+阴风+沧溟，暴怒造成冻结效果
		if (WAR.LiRen == 1 or Curr_NG(pid,216 and JLSD(10,90,eid)))and DWPD() then
			WAR.LRHF[eid] = 10
			WAR.Person[enemyid]["特效动画"] = 116
		end	
		
        if WAR.PD['西瓜刀'][pid] == 2 and DWPD() then
            if JY.Person[pid]['内力性质'] == 0 or JY.Person[pid]['内力性质'] == 3 then 
                WAR.LRHF[eid] = 10	
                WAR.Person[enemyid]["特效动画"] = 116
            end
        end
        
		--无酒不欢：举火燎原，金乌+燃木+火焰刀，暴怒造成引燃效果
		if WAR.JuHuo == 1 and DWPD() then
			WAR.JHLY[eid] = 10	
			WAR.Person[enemyid]["特效动画"] = 112
		end
        
        if WAR.PD['西瓜刀'][pid] == 2 and DWPD() then
            if JY.Person[pid]['内力性质'] == 1 or JY.Person[pid]['内力性质'] == 3 then 
                WAR.JHLY[eid] = 10	
                WAR.Person[enemyid]["特效动画"] = 112
            end
        end
        
		--圣火明尊
		if match_ID(pid,9992) and JY.Person[eid]["灼烧程度"] > 25  and DWPD() then
			WAR.JHLY[eid] = 10
			WAR.Person[enemyid]["特效动画"] = 112
		end
		
		if match_ID(pid,9992) and JY.Person[eid]["灼烧程度"] > 25 then
			for i= 0,WAR.PersonNum-1 do
				if WAR.Person[i]["死亡"] == false and WAR.Person[i]["我方"] == WAR.Person[enemyid]["我方"] then
					local e = WAR.Person[i]["人物编号"]
					local x1,y1 = WAR.Person[enemyid]["坐标X"],WAR.Person[enemyid]["坐标Y"]
					local x2,y2 = WAR.Person[i]["坐标X"],WAR.Person[i]["坐标Y"]
					if math.abs(x1-x2) +math.abs(y1-y2) <= 3 then
						WAR.JHLY[e] = 5
					end		
				end
			end
		end
	end	
	
	--黄衫女天罗地网觉醒增加疾风状态
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
	
	--逍遥御风
	if XiaoYaoYF(eid) and JLSD(20,70,eid) and (WAR.XYYF[eid] == nil or WAR.XYYF[eid] < 9) and WAR.YFCS < 3 then
		WAR.YFCS = WAR.YFCS + 1
		WAR.XYYF[eid] = (WAR.XYYF[eid] or 0) + 1
		Set_Eff_Text(enemyid,"特效文字2","逍遥御风")
		if WAR.XYYF[eid] == 9 then
			WAR.XYYF[eid] = 11
			WAR.XYYF_10 = 1
		end
	end	
	
	--欧阳锋逆运走火
	--有逆运才会
	if WAR.PD["走火状态"][eid] ~= 1 and match_ID(eid, 60) and PersonKF(eid, 104) then
		if JY.Person[eid]["体力"] > 50 then
			WAR.Person[enemyid]["特效动画"] = math.fmod(wugong, 10) + 85
			WAR.Person[enemyid]["特效文字3"] = "真--逆运筋脉走火入魔"
			WAR.PD["走火状态"][eid] = 1
		end
	end
	
	--石破天，50%几率给攻击方上封穴
	if (match_ID_awakened(eid, 38, 1) or (Curr_NG(eid,102) and (JY.Person[192]["品德"] == 60))) and DWPD() and JLSD(20,70,eid) and MyFj(WAR.CurID) == false then
		WAR.Person[enemyid]["特效动画"] = math.fmod(wugong, 10) + 85
		Set_Eff_Text(enemyid, "特效文字3", "太玄神功·反震")
		WAR.FXXS[WAR.Person[WAR.CurID]["人物编号"]] = 1
       	WAR.FXDS[WAR.Person[WAR.CurID]["人物编号"]] = (WAR.FXDS[WAR.Person[WAR.CurID]["人物编号"]] or 0) + 10
		--封穴上限50点
		if 50 < WAR.FXDS[WAR.Person[WAR.CurID]["人物编号"]] then
			WAR.FXDS[WAR.Person[WAR.CurID]["人物编号"]] = 50
		end
	end
	
	--何铁手，给攻击方强制上毒
	if match_ID(eid, 83) and DWPD() then
		WAR.Person[WAR.CurID]["中毒点数"] = (WAR.Person[WAR.CurID]["中毒点数"] or 0) + AddPersonAttrib(pid, "中毒程度", math.random(45, 50))
	end
	
	--宁中则，降低攻击方体力
	if match_ID(eid, 649) and DWPD() then
		WAR.Person[WAR.CurID]["体力点数"] = (WAR.Person[WAR.CurID]["体力点数"] or 0) + AddPersonAttrib(pid, "体力", -math.random(5,10))
	end
	
	   -- 大周天功 养生主
    if PersonKF(eid,190) and WAR.ZTHF[eid]== nil then
		local jl = 30
		if Curr_NG(eid,190) then
			jl = 50
		end
		if JLSD(0,jl,eid) then
			WAR.ZTHF[eid] = 50
			Set_Eff_Text(enemyid, "特效文字1", "养生主")
		end
	end
	
	--主运太极神功，60%几率累积太极之形
	if Curr_NG(eid, 171) and JLSD(20,80,eid) then
		WAR.TJZX[eid] = (WAR.TJZX[eid] or 0) + 1
		if WAR.TJZX[eid] > 10 then
			WAR.TJZX[eid] = 10
		end
		Set_Eff_Text(enemyid, "特效文字3", "太极之形")
	end

	--司空摘星千变万幻
	if match_ID(eid, 579) then
		WAR.SKZX[eid] = (WAR.SKZX[eid] or 0) + 2
		if WAR.SKZX[eid] > 10 then
			WAR.SKZX[eid] = 20
		end
		Set_Eff_Text(enemyid, "特效文字3", "千变万幻")
	end
	
	--被无招胜有招击中
	--黄衫女 广寒清辉
	if WAR.FQY == 1 or WAR.GHQH == 1 then
		if WAR.WZSYZ[eid] == nil then
			WAR.WZSYZ[eid] = 10
		end
		if WAR.WZSYZ[eid] > 10 then
			WAR.WZSYZ[eid] = 10	
		end
	end
		
	
		--被梁萧谐之道击中
	if WAR.LXXZD == 1 then
		if WAR.XZD[eid] == nil then
			WAR.XZD[eid] = 10
		end
		if WAR.XZD[eid] > 10 then
			WAR.XZD[eid] = 10	
		end
	end

	
	--范遥挨打加减伤，上限20%
	if match_ID(eid,10) and WAR.GMYS < 20 then
		WAR.GMYS = WAR.GMYS + 1
	end
	
	
	   -- 蛤蟆功蓄力
	if PersonKF(eid, 95) then
		if WAR.PD["蛤蟆蓄力"][eid] == nil or WAR.PD["蛤蟆蓄力"][eid] == 0 then
			WAR.PD["蛤蟆蓄力"][eid] = 50;
		else
			WAR.PD["蛤蟆蓄力"][eid] = WAR.PD["蛤蟆蓄力"][eid] + 35;
		end
	  Set_Eff_Text(enemyid, "特效文字2", "蛤蟆功蓄力")
	end
	
		--陆渐海之道
	if match_ID(eid, 497) and JY.Base["天书数量"] > 6 then
 	    WAR.HZD_2 = 1
       Set_Eff_Text(enemyid, "特效文字1", "海纳百川")
		WAR.Person[enemyid]["特效动画"] = 111
	end	
	
	--七夕黄蓉，打狗棒法，缠字诀，下回合不可移动
	if wugong == 80 and match_ID(pid, 613) and WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[enemyid]["我方"] then
		WAR.L_NOT_MOVE[eid] = 1;
	end
	
	--天罗地网，柔网势
	if Curr_QG(pid,148) then
		WAR.TLDW[eid] = 1;
	end
	
	--阿九 凤凰涅槃
	if match_ID_awakened(eid,629,1) and (JLSD(20, 70, eid) or WAR.LQZ[eid] == 100) then
		WAR.FGPZ[eid]= 1
		WAR.Person[enemyid]["特效动画"] = 154
       Set_Eff_Text(enemyid, "特效文字1", "凤凰涅槃")
	end	
	
	--除却四相，50%几率免疫本次攻击造成的内伤/封穴/冰封/灼烧
	if ChuQueSX(eid) and JLSD(20,90,eid) then
		WAR.CQSX = 1
		WAR.Person[enemyid]["特效动画"] = 79
		Set_Eff_Text(enemyid, "特效文字1", "除却四相")
	end
	
	--三丰其徐如林
	if match_ID(eid,5) and not inteam(eid) and WAR.ZDDH == 348 and JLSD(10,40,eid) then
		WAR.Person[enemyid]["特效动画"] = 6
		Set_Eff_Text(enemyid, "特效文字0", "其徐如林")
		WAR.PD['徐如林'][eid] = limitX((WAR.PD['徐如林'][eid] or 0) + math.random(2, 3),0,20)
	end	
	
	--其徐如林
	if match_ID(eid, 9970) and JLSD(10,50,eid) then 
		WAR.Person[enemyid]["特效动画"] = 6
		Set_Eff_Text(enemyid, "特效文字0", "其徐如林")
		WAR.PD['徐如林'][eid] = limitX((WAR.PD['徐如林'][eid] or 0) + math.random(2, 3),0,20)
	end
	
   
	--中庸之道 
    --[[
	if eid == 0 and DWPD() and ZhongYongZD(eid) and WAR.ZYCD == 0 then
		if JLSD(20,40+JY.Base["天书数量"]*0.5,eid) or WAR.LQZ[eid] == 100 then
			WAR.Person[enemyid]["特效动画"] = 6
			Set_Eff_Text(enemyid, "特效文字0", "中庸之道")
			WAR.ACT = 10
			--如果是由斗转触发的，则不打断左右
			if WAR.DZXY == 0 then
				WAR.ZYHB = 0
			end
			WAR.ZYZD = 1
			WAR.ZYCD = 40
		end
	end	
	]]
    --陆渐三十二身相 一合相
	if match_ID(eid, 497)  then
		WAR.SSESS[eid] = 100
	end	
------------------------------------------------------------------------------------
-----------------------------------气攻加成-----------------------------------------
------------------------------------------------------------------------------------
    --if inteam(pid) == false then 
        --ang = ang + (JY.Base['难度'])*500
    --end
    
	--斗转星移伤害和杀集气计算
	if WAR.DZXYLV[pid] ~= nil and WAR.DZXYLV[pid] > 10 then
		ang = ang + WAR.DZXYLV[pid] * 10
	end

	--全真七子，天罡北斗阵，增加伤害和气攻
	if WAR.ZDDH == 73 then
		if (pid >= 123 and pid <= 128) or pid == 68 then
			ang = ang + 1200
		end
	end	

	--林朝英增加总气攻
	if match_ID(pid, 605) then
		ang = ang * 1.1
	end

	--连击，伤害，气攻计算
	if WAR.ACT > 1 then
		local LJ_fac = 0.7	--通常为70%
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

	--虚弱状态，杀气减半
	if WAR.XRZT[pid] ~= nil then
		ang = math.modf(ang * 0.5)
	end
	
	--虚弱状态1，杀气减半
	if WAR.XRZT1[pid] ~= nil then
		ang = math.modf(ang * 0.5)
	end

	--集中状态，伤害和杀气都减半
	if WAR.Focus[pid] ~= nil then
	    ang = math.modf(ang * 0.5)
	end

	--罗汉伏魔提升伤害和杀气效果为：[(当前内力值/500)×(武功消耗内力/140)]%
	if Curr_NG(pid, 96) or ((Curr_NG(pid, 108) or match_ID(pid,38)) and PersonKF(pid,96)) then
		local nlmod = JY.Person[pid]["内力"]/30000
		local wgmod = JY.Wugong[wugong]["消耗内力点数"]/2000
		local totalmod = 1 + nlmod + wgmod;
		--石破天效果提高1.1倍
		if match_ID(pid, 38)  or Curr_NG(pid, 108) then
			totalmod = totalmod * 1.1;
		end
		ang = math.modf(ang * totalmod)
	end

	--黄蓉奇门遁甲，蓝色增加杀气
	if WAR.Person[WAR.CurID]["我方"] == true and GetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"],6) == 3 then
		ang = ang + 400
	end
	
	--被刺目，伤害杀气降低15%，有15%几率miss
	if WAR.KHCM[pid] == 2 then
		ang = math.modf(ang *0.85)
	end
	
	--梯云纵，50%几率减少50%所受气攻
	if Curr_QG(eid,149) and JLSD(20, 70, eid) and ang > 0  then
		ang = math.modf(ang *0.8)
		WAR.Person[enemyid]["特效动画"] = 153
		Set_Eff_Text(enemyid, "特效文字2", "梯云纵横")
	end
	
    if ZDGH(enemyid,569) then 	
        ang = math.modf(ang *0.8)
		WAR.Person[enemyid]["特效动画"] = 90
	end
	
	--如果学有五岳剑诀，且未发动真气护体，则有(御剑-220)%几率触发以剑御气，敌方气攻减半
	if PersonKF(eid, 175) and WAR.ZQHT == 0 and ang > 0 then
		local chance = math.modf(TrueYJ(eid)/10)+10
		--local chance = yj
		if JLSD(0,chance,eid) or inteam(eid) == false then
			ang = math.modf(ang *0.8)
			WAR.Person[enemyid]["特效动画"] = 137
			Set_Eff_Text(enemyid, "特效文字1", "以剑御气")
		end
	end
	
	--冯衡
	if match_ID(eid, 588) then
	    ang = math.modf(ang * 0.9)
	end

	--长生诀
	if Curr_NG(eid,203) then
	    ang = math.modf(ang * 0.7)
	end
    
	--长生诀
	if Curr_NG(eid,203) and JLSD(0,25,eid) then
	    WAR.PD['长生诀'][eid] = 10
        Set_Eff_Text(enemyid, "特效文字3", "顾道长生")
	end
	
	-- 仪琳
	if match_ID(eid,583) then
		ang = math.modf(ang *0.85)
	end
	
	
	--无酒不欢：太极奥义，降低35%杀气，真太奥免疫杀气
	for i = 1, JY.Base["武功数量"] do
		if (JY.Person[eid]["武功" .. i] == 16 or JY.Person[eid]["武功" .. i] == 46) and JY.Person[eid]["武功等级" .. i] == 999 then
		  WAR.TJAY = WAR.TJAY + 1
		end
	end

	if WAR.TJAY == 2 then
		--张三丰85%几率
		if match_ID(eid, 5) then
			if JLSD(10, 95, eid) then
				WAR.TJAY = 3
			end
		--其他人(45+资质/4)%几率
		else
			if JLSD(10, 55 + math.modf(JY.Person[eid]["资质"] / 4), eid) then
				WAR.TJAY = 3
			end
		end
	end
    
	--杀气降低25%
	if WAR.TJAY == 3 then
		ang = ang * 0.75
	end
	
	--九阳神功
	if  Curr_NG(eid,106) and ang > 0 and (JY.Person[eid]["内力性质"] == 1 or JY.Person[eid]["内力性质"] == 3) and (JLSD(20,80,eid) or WAR.LQZ[eid] == 100) and DWPD() then
		ang = ang*0.7
		WAR.PD['氤氲紫气'][eid] = 1
		Set_Eff_Text(enemyid, "特效文字0", "氤氲紫气")
		WAR.Person[enemyid]["特效动画"] = 90
	end
	
	--主角刀系，每个刀法练到极，减少受到的5%杀气
	if JY.Base["标准"] == 4 and eid == 0 then
		local askd = 0
		for i = 1, JY.Base["武功数量"] do
			if JY.Wugong[JY.Person[0]["武功" .. i]]["武功类型"] == 4 and JY.Person[0]["武功等级" .. i] == 999 then
				askd = askd + 1
			end
		end
		if askd > 7 then
			askd = 7
		end
		
		ang = math.modf(ang * (1 - 0.05 * askd))
	end
	
	--霍都每个武功练到极，减少受到的3%杀气
	if match_ID(eid, 9981) then
		local LXBR = 0
		for i = 1, JY.Base["武功数量"] do
			if JY.Wugong[JY.Person[0]["武功" .. i]] and JY.Person[0]["武功等级" .. i] == 999 then
				LXBR = LXBR + 1
			end
		end
		if LXBR > 7 then
			LXBR = 7
		end
		ang = math.modf(ang * (1 - 0.03 * LXBR))
	end
	
	--无酒不欢：两仪守护64%几率，固定降低32点伤害
	for i = 1, JY.Base["武功数量"] do
		if (JY.Person[eid]["武功" .. i] == 37 or JY.Person[eid]["武功" .. i] == 60) and JY.Person[eid]["武功等级" .. i] == 999 then
			WAR.LYSH = WAR.LYSH + 1
		end
	end
    
	if WAR.LYSH == 2 and JLSD(20, 84, eid) then
		WAR.LYSH = 3
	end
    
	--两仪守护降低320点气攻
	if WAR.LYSH == 3 then
		ang = ang - 320
		if ang < 0 then
			ang = 0
		end
	end
	
   
	
	--阿九 降低999点气攻
	if WAR.FGPZ[eid]~= nil then
		ang = ang -999
	 	if ang < 0 then
			ang = 0
		end
	end
	
    WAR.FGPZ[eid] = nil
	
------------------------------------------------------------------------------------
-----------------------------------气防加成-----------------------------------------
------------------------------------------------------------------------------------
	--无酒不欢：计算内功护体，互为敌方才会触发
	--周伯通空明之武道使敌方不会护体
	if DWPD() and WAR.KMZWD == 0 then
		local ht = {};		
		local num = 0;	--当前学了多少个内功
		for i = 1, CC.Kungfunum do
			local kfid = JY.Person[eid]["武功" .. i]
			local kflvl = JY.Person[eid]["武功等级" .. i]
			if kflvl == 999 then
				kflvl = 11
			else
				kflvl = math.modf(kflvl / 100) + 1
			end
			--先把内功都存入表格，吸功，金刚不坏，五岳剑诀不护体
			if JY.Wugong[kfid]["武功类型"] == 6 and kfid ~= 85 and kfid ~= 87 and kfid ~= 88 and kfid ~= 144 and kfid ~= 175 then
				num = num + 1;
				ht[num] = {kfid,i,get_skill_power(eid, kfid, kflvl)};
			end
		end
				
		--如果学有内功
		if num > 0 then	
			--按照威力从大到小排序，威力一样的话按照面板的先后顺序
			for i = 1, num - 1 do
				for j = i + 1, num do
					if ht[i][3] < ht[j][3] or (ht[i][3] == ht[j][3] and ht[i][2] > ht[j][2])then
						ht[i], ht[j] = ht[j], ht[i]
					end
				end
			end
			--按顺序判定触发
			for i = 1, num do
				if myrandom(10, eid) then
					dng = ht[i][3];
					WAR.Person[enemyid]["特效文字2"] = JY.Wugong[ht[i][1]]["名称"] .. "护体"
					WAR.Person[enemyid]["特效动画"] =  87 + math.random(6)
					WAR.NGHT = ht[i][1];
					break;
				end
			end
		end
	

		--运行天赋内功气防+200，有35%几率再+300
		if JY.Person[eid]["主运内功"] > 0 and JY.Person[eid]["主运内功"] == JY.Person[eid]["天赋内功"] then
			dng = dng + 200;
			if JLSD(30, 65, eid) then
				dng = dng + 300;
				Set_Eff_Text(enemyid, "特效文字3", "天赋内功护体")
			end
		end

		--蛤蟆功补偿护体
		if WAR.NGHT == 0 and (PersonKF(eid, 95) or PersonKF(eid, 180)) then
			dng = dng + 900;
			WAR.Person[enemyid]["特效动画"] = 87 + math.random(6)
		end
	end
	
    if WAR.NGHT == 0 then 
        if isteam(eid) == false then 
            Set_Eff_Text(enemyid, "特效文字2", "内力护体")
            WAR.Person[enemyid]["特效动画"] =  87 + math.random(6)
        end
    end
    
	--护体动画
	if WAR.NGHT == 204 then
		WAR.Person[enemyid]["特效动画"] = 111 
	end
	
	if match_ID(eid,50) and WAR.NGHT == 0 and PersonKF(eid,204) then
	 	WAR.Person[enemyid]["特效动画"] = 111
		WAR.Person[enemyid]["特效文字2"] = "擒龙功护体"
		dng = dng + 1200
	end
	
	--张无忌 斗酒僧九阳神功护体
	if  WAR.NGHT == 0 and PersonKF(eid, 106) then
		WAR.Person[enemyid]["特效动画"] = 87 + math.random(6)
		WAR.Person[enemyid]["特效文字2"] = "九阳神功护体"
		dng = dng + 1200
	end
	
	--论剑打赢阿青的奖励，气防永久提高800点
	if eid == 0 and JY.Person[604]["论剑奖励"] == 1 then
		dng = dng + 800
	end
	
	-- 金雁功
	if Curr_QG(eid,223) then
		dng = dng + 800
	end
	
	--九字真言 者
	if WAR.PD["者"][eid]~= nil and WAR.PD["者"][eid] == 1 then
		dng = dng + 800
	end

	--蒙哥，气防+2000点
	if eid == 627 or eid ==567 or eid == 568 then
		dng = dng + 2000
	end
	
    -- 潮汐神功
	if Curr_NG(eid,172) then
	    dng = dng + JY.Person[eid]["内力"]/7
	end
	
	--[[
    --已方内力加成气防
	if inteam(eid) then
		dng = dng + (JY.Person[eid]["内力"]/10)
	end
	]]
	
	--防御状态
	if WAR.Defup[eid] == 1  then
		WAR.Person[enemyid]["特效动画"] = 90
		Set_Eff_Text(enemyid, "特效文字1", "防御状态")
		if PersonKF(eid, 101) then     --八荒气防+1000
			dng = dng + 800
		else
			dng = dng + 400
		end
	end

		--萧秋水 忘情天书护体
	if match_ID(eid, 652) then
		dng = dng + 800
		if not inteam(eid) then
			dng = dng + 800
		end
		WAR.Person[enemyid]["特效动画"] = 86
		if WAR.Person[enemyid]["特效文字2"] ~= nil then
			WAR.Person[enemyid]["特效文字2"] = WAR.Person[enemyid]["特效文字2"].."+忘情天书"
		else
			WAR.Person[enemyid]["特效文字2"] = "忘情天书护体"
		end
		WAR.ZQHT = 1
	end

	--鸠摩智
	if match_ID(eid, 103) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["天书数量"]+math.modf(JY.Person[eid]["实战"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			WAR.Person[enemyid]["特效动画"] = math.fmod(98, 10) + 85
			Set_Eff_Text(enemyid, "特效文字2", "明王真气")
			WAR.ZQHT = 1
		end
	end
	
	
	--成昆
	if match_ID(eid, 18) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["天书数量"]+math.modf(JY.Person[eid]["实战"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			WAR.Person[enemyid]["特效动画"] = math.fmod(106, 10) + 85
			if WAR.Person[enemyid]["特效文字2"] ~= nil then
				WAR.Person[enemyid]["特效文字2"] = WAR.Person[enemyid]["特效文字2"].."+混元霹雳功"
			else
				WAR.Person[enemyid]["特效文字2"] = "混元霹雳功护体"
			end
			WAR.ZQHT = 1
		end	
	end

	--洪七公
    if match_ID(eid, 69) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["天书数量"]+math.modf(JY.Person[eid]["实战"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			
			WAR.Person[enemyid]["特效动画"] = 67
			Set_Eff_Text(enemyid, "特效文字2", "丐王真气")
			WAR.ZQHT = 1
		end	
    end
 
	--黄药师
    if match_ID(eid, 57) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["天书数量"]+math.modf(JY.Person[eid]["实战"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			WAR.Person[enemyid]["特效动画"] = 95
			Set_Eff_Text(enemyid, "特效文字2", "奇门奥义")
			WAR.ZQHT = 1
		end
    end
      --何太冲
    if match_ID(eid, 7) then
		dng = dng + 1200
		if not inteam(eid) then
			dng = dng + 1200
		end
		WAR.Person[enemyid]["特效动画"] = math.fmod(98, 10) + 85
		Set_Eff_Text(enemyid, "特效文字2", "太清罡气")
		WAR.ZQHT = 1
	end
	
	--谢烟客
    if match_ID(eid, 164) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["天书数量"]+math.modf(JY.Person[eid]["实战"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 500
			if not inteam(eid) then
				dng = dng + 500
			end
			WAR.Person[enemyid]["特效动画"] = 23
			Set_Eff_Text(enemyid, "特效文字2", "摩天居士")
			WAR.ZQHT = 1
		end
    end
	
	--任我行
	if match_ID(eid, 26) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["天书数量"]+math.modf(JY.Person[eid]["实战"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			WAR.Person[enemyid]["特效动画"] = 6
			Set_Eff_Text(enemyid, "特效文字2", "日月·同辉")
			WAR.ZQHT = 1
		end
	end
	
	--戚长发
    if match_ID(eid, 594) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["天书数量"]+math.modf(JY.Person[eid]["实战"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			WAR.Person[enemyid]["特效动画"] = 93
			Set_Eff_Text(enemyid, "特效文字2", "铁锁横江")
			WAR.ZQHT = 1
		end
    end
	
	--慕容博
    if match_ID(eid, 113) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["天书数量"]+math.modf(JY.Person[eid]["实战"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			WAR.Person[enemyid]["特效动画"] = 93
			Set_Eff_Text(enemyid, "特效文字2", "参合真气")
			WAR.ZQHT = 1
		end
    end
	
	--阿紫曼珠沙华，每杀一个人+200气防
	if match_ID(eid, 47) then
		dng = dng + 200*WAR.MZSH
	end
	
	--鲸息功气防值蓄力增加气防值
	if PersonKF(eid,180) and WAR.PD["鲸息蓄力"][eid] ~= nil then
		dng = dng + math.modf(WAR.PD["鲸息蓄力"][eid])
	end
	
	--枯荣
    if match_ID(eid, 102) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["天书数量"]+math.modf(JY.Person[eid]["实战"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 600
			if not inteam(eid) then
				dng = dng + 600
			end
			WAR.Person[enemyid]["特效动画"] = 93
			Set_Eff_Text(enemyid, "特效文字2", "枯荣真气")
			WAR.ZQHT = 1
		end
    end
	
	--何铁手
    if match_ID(eid, 83) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["天书数量"]+math.modf(JY.Person[eid]["实战"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 500
			if not inteam(eid) then
				dng = dng + 500
			end
			WAR.Person[enemyid]["特效动画"] = 92
			Set_Eff_Text(enemyid, "特效文字2", "红袖拂风")
			WAR.ZQHT = 1
		end
    end
	
	--左冷禅
    if match_ID(eid, 22) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["天书数量"]+math.modf(JY.Person[eid]["实战"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 500
			if not inteam(eid) then
				dng = dng + 500
			end
			WAR.Person[enemyid]["特效动画"] = 1
			Set_Eff_Text(enemyid, "特效文字2", "寒冰真气")
			WAR.ZQHT = 1
		end
    end
	
	--殷天正
    if match_ID(eid, 12) then
		local pd = false
		if inteam(eid) == false then 
			pd = true
		end
		
		local gl = 70+JY.Base["天书数量"]+math.modf(JY.Person[eid]["实战"]/50)
		if JLSD(20,gl,eid) then 
			pd = true
		end
		
		if pd == true then 
			dng = dng + 500
			if not inteam(eid) then
				dng = dng + 500
			end
			WAR.Person[enemyid]["特效动画"] = 92
			Set_Eff_Text(enemyid, "特效文字2", "鹰王真气")
			WAR.ZQHT = 1
		end
    end
	
	--阿青
	if match_ID(eid, 604) then
		dng = dng + TrueYJ(eid)*5
		if not inteam(eid) then
			dng = dng + TrueYJ(eid)*5
		end
		WAR.Person[enemyid]["特效动画"] = 121
		Set_Eff_Text(enemyid, "特效文字2", "九宵仙息")
		WAR.ZQHT = 1
    end
	
	
	--三神功的真气
	if PersonKF(eid, 106) and (JY.Person[eid]["内力性质"] == 1 or (JY.Person[eid]["内力性质"] == 3 and JY.Person[eid]["天赋内功"] == 106)) then
		if  JLSD(30, 50 + JY.Base["天书数量"]*3,eid) then 
			dng = dng + 800
			if WAR.Person[enemyid]["特效动画"] == -1 then
				WAR.Person[enemyid]["特效动画"] =  87 + math.random(6)
			end
			Set_Eff_Text(enemyid, "特效文字1", "九阳真气")
			WAR.ZQHT = 1
		end
	end
	
	--九阴真气
	if PersonKF(eid, 107) and (JY.Person[eid]["内力性质"] == 0 or (JY.Person[eid]["内力性质"] == 3 and JY.Person[eid]["天赋内功"] == 107)) then
		if JLSD(30, 50 + JY.Base["天书数量"]*3,eid) then
			dng = dng + 650
			if WAR.Person[enemyid]["特效动画"] == -1 then
				WAR.Person[enemyid]["特效动画"] =  87 + math.random(6)
			end
			Set_Eff_Text(enemyid, "特效文字1", "九阴真气")
			WAR.ZQHT = 1
		end
	end
	
	--易筋真气
	if PersonKF(eid, 108) and (JY.Person[eid]["内力性质"] == 2 or (JY.Person[eid]["内力性质"] == 3 and JY.Person[eid]["天赋内功"] == 108) ) then
		if JLSD(30, 50 + JY.Base["天书数量"]*3,eid) then
			dng = dng + 650
			if WAR.Person[enemyid]["特效动画"] == -1 then
				WAR.Person[enemyid]["特效动画"] =  87 + math.random(6)
			end
			Set_Eff_Text(enemyid, "特效文字1", "易筋真气")
			WAR.ZQHT = 1
		end
	end
	
	--北冥真气，无崖子必发动，学有北冥/虚竹觉醒后几率发动
	if ((PersonKF(eid, 85) or match_ID_awakened(eid, 49, 1)) and JLSD(20, 70, eid)) or match_ID(eid, 634) or match_ID(eid, 116) then
		dng = dng + 800
		if WAR.Person[enemyid]["特效动画"] == -1 then
			WAR.Person[enemyid]["特效动画"] = 85
		end
		Set_Eff_Text(enemyid, "特效文字2", "北冥真气")
		WAR.ZQHT = 1
	end
		
 	if match_ID(eid, 637)  then
		if WAR.HXZYJ == 1 then
			dng = dng + 1200
		end
	end
	
	--圣火三使 受伤害减少、气防提高
	if WAR.ZDDH == 14 and (eid == 173 or eid == 174 or eid == 175) then
		local shz = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[enemyid]["我方"] then
			shz = shz + 1
			end
		end
		if shz == 3 then
			dng = dng + 1000
		end
	end

	--任飞燕
    if match_ID(eid,615)then
       dng = dng + JY.Person[eid]["轻功"]*2
    end
	
	--无酒不欢：小无相功增加气防
	--主运
	if Curr_NG(eid, 98) then
		dng = dng * 1.3
	--被动
	elseif PersonKF(eid, 98) then
		dng = dng * 1.1
	end
	
	--太虚剑意 坐忘无我 韬光养晦
	if Curr_NG(eid, 152) then
		local TX = 0
		TX = ang*0.2
		if TX < 1500 then	 
			dng = dng + TX
			WAR.Person[enemyid]["特效动画"] = 137
			Set_Eff_Text(enemyid, "特效文字1", "韬光养晦·坐忘无我")	
		end
	end
	
	--全真七子，天罡北斗阵，受伤害减少和增加气防
	if WAR.ZDDH == 73 then
		if (eid >= 123 and eid <= 128) or eid == 68 then
			dng = dng + 1200
			WAR.Person[enemyid]["特效动画"] = 93
			Set_Eff_Text(enemyid, "特效文字2", "天罡北斗阵护体")
		end
	end
	
	--金刚伏魔圈，伤害一减少，气防提高
	if PersonKF(eid, 82) then
		local jgfmq = 0
		local effstr = "金刚伏魔圈"
		for j = 0, WAR.PersonNum - 1 do
			if PersonKF(WAR.Person[j]["人物编号"], 82) and WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[enemyid]["我方"] then
				jgfmq = jgfmq + 1
			end
		end
		--上限3人
		if jgfmq > 3 then
			jgfmq = 3
		end
		if jgfmq == 3 then
			effstr = "真."..effstr
		end
		if jgfmq > 1 then
			dng = dng + 500 * (jgfmq-1)
			Set_Eff_Text(enemyid, "特效文字3", effstr)
		end
	end
	
	--江南七怪
	if WAR.ZDDH==189  and  (eid >= 130 and eid <= 136)  then
		local JLQX = 0
		local effstr = "同生共死"
		for j = 0, WAR.PersonNum - 1 do
			 if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[enemyid]["我方"] then
				JLQX = JLQX + 1
			end
		end
		if JLQX > 1 then
			dng = dng + 400 * (JLQX-1)
			Set_Eff_Text(enemyid, "特效文字1", effstr)
		end
	end	
	
	--九阳神功
	if WAR.PD['氤氲紫气'][eid] == 1 then
		dng = 1000
	end
	

---------------------------------------------------------------------------
-----------------------------基础伤害计算----------------------------------
---------------------------------------------------------------------------

	--斗转星移
	--50%几率发动，慕容复，慕容博必发动
    if PersonKF(eid, 43) and MyFj(WAR.CurID) == false and JY.Person[eid]["体力"] > 10 and WAR.DZXY ~= 1 and WAR.Person[enemyid]["反击武功"] == -1 and WAR.Person[enemyid]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
		--local gl = 0
        local gl = (JY.Person[eid]['资质']-30)
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
			--兵器值之和大于等于360出离合参商
			--慕容复，慕容博，天罡必出
			if dzlv >= 360 or match_ID(eid, 51) or match_ID(eid, 113) or (eid == 0 and JY.Base["标准"] == 6) then
				local hm = 0
				--兵器值之和超过520，有几率出幻梦星辰反击
				--几率为兵器值之和-520，上限50%几率
				if dzlv > 520 then
					local chance = limitX(dzlv-520, 0, 50)
					if JLSD(0, chance, eid) then
						hm = 1
					end
				end
				--慕容复指令必出幻梦
				if WAR.TZ_MRF == 1 then
					hm = 1
				end
				if hm == 1 then
					dzwz = "幻梦星辰"
					WAR.DZXYLV[eid] = 4
				else
					dzwz = "离合参商"
					WAR.DZXYLV[eid] = 3
				end
			--兵器值之和大于等于240出斗转星移
			elseif dzlv >= 240 then
				dzwz = "斗转星移"
				WAR.DZXYLV[eid] = 2
			--都不满足，则是北斗移辰
			else
				dzwz = "北斗移辰"
				WAR.DZXYLV[eid] = 1
			end
			Set_Eff_Text(enemyid, "特效文字2", dzwz)
			if WAR.Person[enemyid]["特效动画"] == -1 then
				WAR.Person[enemyid]["特效动画"] = 93
			end
			WAR.Person[enemyid]["反击武功"] = wugong
		end
    end
  
	--无酒不欢：伤害公式从这里开始，计算受到的伤害
	
	--当守方为玩家时，基础伤害一 = 30 + (攻方攻击 + 攻方内力/50)/1.5 + 武功威力/2.5
	--if inteam(eid) then
	--	hurt =  30 + (JY.Person[pid]["攻击力"] + getnl(pid)/50)/1.5 + true_WL/2.5
		
	--当守方为NPC时，基础伤害一 = (攻方攻击 + 攻方内力/50 + 武功威力)/3
	--else
	--	hurt = (JY.Person[pid]["攻击力"] + getnl(pid)/50 + true_WL)/3
	--end
	
--	hurt =  30 + (atk + getnl(pid)/50)/1.5 + true_WL/2.5
	



	--伤害一 = 伤害一 + 装备攻击 * 装备加成系数
	--NPC的装备不带等级

	
	--攻方的内力/50加成到攻方基础攻击
	--atk = atk + getnl(pid) / 50	
	  
	--攻方的气攻/20，加成到攻方基础攻击
	--攻方的武常，加成到攻方基础攻击
	--atk = atk + mywuxue + ang / 100
	
	--守方的内力/40，加成到守方基础防御
	--守方的武常，加成到守方基础防御
	--def = def + getnl(eid) / 40 + emenywuxue
	

	
	--hurt =  30 + (Atk[WAR.CurID] + getnl(pid)/50)/1.5 + true_WL/2.5
	
	--伤害一 = 基础伤害一 * 攻方基础攻击/(攻方基础攻击 + 守方基础防御)
	--hurt = (hurt) * (atk) / (atk + def)

 	--基础伤害一 = 基础伤害一 + (攻方武常 - 守方武常)/2
	--hurt = hurt + (mywuxue - emenywuxue) / 2 

	--伤害一 = 伤害一 - 守方基础防御/5
	--hurt = hurt - (def) / 5
	
	--伤害一 = 伤害一 + (攻方体力 - 守方体力)/5 - 气防/50 - (攻方内伤 - 守方内伤)/3 - (攻方中毒 - 守方中毒)/2
	--hurt = hurt + JY.Person[pid]["体力"] / 5   - (dng) / 50- JY.Person[eid]["体力"] / 5 + JY.Person[eid]["受伤程度"] / 3 - JY.Person[pid]["受伤程度"] / 3 + JY.Person[eid]["中毒程度"] / 2 - JY.Person[pid]["中毒程度"] / 2
	
---------------------------------------------------------------------------
--///////////////////////////保底伤害////////////////////////////////////
---------------------------------------------------------------------------

	--攻击方为我方，伤害二 = INT(攻方基础攻击/7 + 随机1~5) + INT(武功威力/15)
	--if inteam(pid) then
	--	hurt2 = math.modf(math.random(30) + (atk) / 7) + math.modf(true_WL / 15)
	--攻击方为NPC，伤害二 = INT(攻方基础攻击/6 + 随机1~20) + INT(武功威力/13)
	--else
	--	hurt2 = math.modf(math.random(30) + (atk) / 7) + math.modf(true_WL / 13)
	--end
	--攻击方为NPC，伤害二 = 伤害二 * 1.2
	--if not inteam(pid) then
		--hurt2 = math.modf(hurt2 * 1.2)
	--end
	
	--如果伤害一小于伤害二，则采用伤害二继续计算
	--if hurt < hurt2 then
	--	hurt = hurt2
	--end
		
	if wgtype == 6 then
		--太玄可以手动选择系数
		if wugong == 102 and WAR.TXZS > 0 then
			WAR.NGXS = WAR.TXZS
		else
			WAR.NGXS = math.random(5)
		end
		wgtype = WAR.NGXS
	end	
	--风清扬任何武功攻击算剑系
	if match_ID(pid, 140)  then
		wgtype = 3
	end
	--独孤求败被任何武功攻击算剑系
	if match_ID(eid, 592)  then
		wgtype = 3
	end	
	--风清扬被任何武功攻击算剑系
	if match_ID(eid, 140)  then
		wgtype = 3
	end
	
	--陆渐 被任何武功攻击算拳系
	if match_ID(eid, 497) then
		wgtype = 1
	end
	
	--陆渐 任何武功攻击算拳系
	if match_ID(pid, 497) then
		wgtype = 1				
	end
	if wugong == 93 then
		wgtype = 5
	end		
	--天池怪侠
	if match_ID(pid,9988) then
   		wgtype = 1				
	end	
	if wgtype == 1 and wugong ~= 109 then
		wxs = TrueQZ(pid)
		dxs = TrueQZ(eid)
		--无酒不欢：被拳法攻击，取拳指较高者计算减伤
		if dxs < TrueZF(eid) then
			dxs = TrueZF(eid)
			end
		--陆渐海之道，上善若水，敌方拳法系数按0算
		if WAR.HZD_1 == 1 then
			dxs = 0
		end	

     --陆渐海之道，海纳百川，敌方拳法系数按0算
		if WAR.HZD_1 == 2 then
			wxs = 0
		end
	elseif wgtype == 2 or wugong == 109 then
		wxs = TrueZF(pid)
		dxs = TrueZF(eid)
		--无酒不欢：被指法攻击，取拳指较高者计算减伤
		if dxs < TrueQZ(eid) then
			dxs = TrueQZ(eid)
		end
		--六脉剑气碧烟横，敌方指法系数按50%算
		if WAR.JQBYH == 1 then
			dxs = dxs / 2
		end
	elseif wgtype == 3 then
		wxs = TrueYJ(pid)
		dxs = TrueYJ(eid)
		if WAR.PD["刀剑绝技"][pid] ~= nil then
			wxs = wxs + TrueSD(pid)
        end	
		--独孤求败，敌方御剑系数按1/3计算
		if WAR.WWWJ == 1  then
			dxs = dxs/3			
		end		
		--阿青天元剑气，敌方御剑系数按0算
		if WAR.TYJQ == 1  then
			dxs = 0
		end
		
		--仙猿神剑
        if match_ID(pid,9997) then
			dxs = dxs/2
		end		
		
		if WAR.XMJDHS == 1	then  
			dxs = dxs/2
		end	
		
		--无酒不欢：NPC的真气效果为2倍
		--剑道化身.护体
		if match_ID(eid, 500)  then
			WAR.Person[enemyid]["特效动画"] = 95
			if WAR.Person[enemyid]["特效文字2"] ~= nil then
				WAR.Person[enemyid]["特效文字2"] = WAR.Person[enemyid]["特效文字2"].."+化三清"
			else
				WAR.Person[enemyid]["特效文字2"] = "化三清"
			end
			wxs = wxs/2
		end	
				
		if WAR.JTYJ[pid] ~= nil  then
			dxs = dxs*0.7
		end		

	elseif wgtype == 4 then
		wxs= TrueSD(pid)
		if WAR.PD["刀剑绝技"][pid] ~= nil then
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

	--攻方内力差
	if wnc < 0 then 
		wnc = 1
	else 
        wnc = wnc/9999
	end
    --攻方武常差
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
    --攻方系数差
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
    --守方内力差
	if dnc < 0 then 
		dnc = 1
	else 
		dnc = dnc/9999 + 1
	end
    --守方武常
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
    --守方系数
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

	--天罡大招，系数不会劣势
	if WAR.JSTG == 1 and wsc < dsc then
		dsc = 1
		Set_Eff_Text(enemyid, "特效文字2","遇强则强")
	end
	
	--小无相功，系数不会劣势
	if Curr_NG(pid, 98) and wsc < dsc and WAR.HZD_1~= 1  then
		dsc = 1
		Set_Eff_Text(enemyid, "特效文字2","无我无相")
	end
	
	if Curr_NG(eid, 98) and wsc > dsc and WAR.TYJQ ~= 1 and WAR.HZD_2~= 1 and WAR.XMJDHS ~= 1 and WAR.WWWJ ~= 1 then
		wsc = 1
		if Curr_NG(pid, 98) == false then
			Set_Eff_Text(enemyid, "特效文字2","无我无相") 
		end
	end
	--扫地系数不会劣势
	if match_ID(pid,114) and wsc < dsc then
		dsc = 1
	end

	if match_ID(eid,114) and wsc > dsc then
		wsc = 1
	end
	--萧玲系数不会劣势
	if match_ID(pid,574) and wsc < dsc then
		dsc = 1
	end	
	if match_ID(eid,574) and wsc > dsc then
		wsc = 1
	end	
	--梅长苏系数不会劣势
	if match_ID(pid,9969)  and wsc < dsc then
		dsc = 1
	end	
	if match_ID(eid,9969)  and wsc > dsc then
		wsc = 1
	end
	--李白，系数不会劣势
	if match_ID(pid, 636)  and wsc < dsc then
		dsc = 1
		Set_Eff_Text(enemyid, "特效文字2","谪仙观气") 
		end
	
	if match_ID(eid, 636)  and wsc > dsc then
		wsc = 1
		Set_Eff_Text(enemyid, "特效文字2","谪仙观气") 
		end
	--李寻欢被攻击，系数不会劣势
	if match_ID(eid, 498) and wsc > dsc then
		wsc = 1
		Set_Eff_Text(enemyid, "特效文字2","惊才绝艳")
	end	

	atk = w.g*wwc*wsc--*wgc

	def = d.f*dwc*dsc--*dgc
	
    --排云掌 无防防御
	if match_ID(pid,584) and WAR.BJYPYZ > 0 and JLSD(20,70+WAR.BJYPYZ,pid) then
		def = math.modf(def * (1-WAR.BJYPYZ*0.03))
	end
	--萧玲概率破防
	if match_ID(pid,574) and JLSD(20,70,pid) then
		def = math.modf(def * 0.7)
	end
    
    if WAR.PD['降龙·亢龙有悔'][pid] == 1 then 
        def = math.modf(def * 0.7)
    end
    
    if WAR.PD['挑字决'][pid] == 1 then 
        def = math.modf(def * 0.7)
    end
    
	--九字真言 兵
	if WAR.PD["兵"][pid] ~= nil and WAR.PD["兵"][pid] == 1 then
		def = math.modf(def * 0.7)
	end
	--天魔功无视敌方40%防御
	if Curr_NG(pid, 160) then
		def = math.modf(def * 0.7)
	elseif PersonKF(pid,160) then 
		def = math.modf(def * 0.9)
	end
	--林殊 敌方每点灼烧值破防1%
	if match_ID(pid,508) then
		local pf = JY.Person[eid]["灼烧程度"]/100
		def = math.modf(def*(1-pf))
    end	
	--绣花针 破防
	if JY.Person[pid]["武器"] == 349 then
		local dj = JY.Thing[349]["装备等级"]
		if pid == 27 then
			dj = 6
		end
		local xhzpf = 1 - dj/20
		def = math.modf(def * xhzpf)
    end
	
	--金刚般若 大金刚掌
	if WAR.PD["金刚般若"][pid] ~=nil and WAR.PD["金刚般若"][pid] == 1 then
        def = math.modf(def * 0.7)
		--WAR.PD["金刚般若"][pid] = nil
    end  	
	
	-- 傲世神罡  JY.Wugong[wugong]["武功类型"]
	if match_ID(pid,9989) and (JY.Wugong[wugong]["武功类型"] == 1 or JY.Wugong[wugong]["武功类型"] == 2) then
		def = math.modf(def * 0.7)
    end	
	
	--六脉大招1
	if  WAR.DSP_LM1 == 1	then
	    def = math.modf(def * 0.7)
	end	
	
 	--鲸息功 陷空力
    if WAR.BHJTZ6 == 1 then
		def = math.modf(def * 0.7)
    end	    
	
	--剑魔再临 天极剑渊
	if WAR.JMZL == 1  then
		def = math.modf(def * 0.7)
	end
	
	--陈家洛庖丁解牛
	if match_ID(pid,75) and WAR.PDJN == 1 then
		def = math.modf(def * 0.7)
	end	
	
	--萧秋水 无视敌方防御50% 惊天一剑
	if (JY.Person[pid]["六如觉醒"] > 0 or isteam(pid) == false) and WAR.JTYJ[pid] ~= nil then
		def = math.modf(def * 0.7)
	end		
	
	--葵花尊者，基础攻击*1.5
	--if pid == 608 then
		--atk = atk * 1.5
	--end
	
    if WAR.PD['野球拳'][pid] == 1 then 
        atk = atk * 1.4
        def = math.modf(def * 0.7)
    end
    
	--葵花尊者，基础防御*1.5
	--if eid == 608 then
	--	def = def * 1.5
	--end
 	--太极蓄力增加防御
	if Curr_NG(eid,171) and WAR.PD["太极蓄力"][eid]~= nil  then
		def = def + WAR.PD["太极蓄力"][eid]/20
	end   	
	
	if match_ID(pid,9977) and WGLX == 3 then 
		local n = 0
		for j = 1, JY.Base["武功数量"] do
			if JY.Person[pid]['武功'..j] > 0 and JY.Person[pid]['武功等级'..j] >= 999 then 
				local kf = JY.Person[pid]['武功'..j]
				if JY.Wugong[kf]['武功类型'] == 3 then 
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
	--say('测试减伤伤害：'..hurt,1)
---------------------------------------------------------------------------
-----------------------------伤害加成计算----------------------------------
---------------------------------------------------------------------------

---------------------------------------------------------------------------
--///////////////////////////乘除法计算////////////////////////////////////
---------------------------------------------------------------------------
if hurt > 0 then
	local zjh = 0
	local hm = 1
	local hx = 0


	--距离伤害递减
	--离剑式 梯云纵 剑气碧烟横不递减
	if match_ID(pid, 652) and JY.Base["天书数量"] > 5 then
		local offset = math.abs(WAR.Person[WAR.CurID]["坐标X"] - WAR.Person[enemyid]["坐标X"]) + math.abs(WAR.Person[WAR.CurID]["坐标Y"] - WAR.Person[enemyid]["坐标Y"])
		if offset > 11 then
			offset = 11
		end
		hurt = (hurt) * (100 + (offset - 1) * 6) / 100
	elseif WAR.YLTW == 1 then
		local offset = math.abs(WAR.Person[WAR.CurID]["坐标X"] - WAR.Person[enemyid]["坐标X"]) + math.abs(WAR.Person[WAR.CurID]["坐标Y"] - WAR.Person[enemyid]["坐标Y"])
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
		local offset = math.abs(WAR.Person[WAR.CurID]["坐标X"] - WAR.Person[enemyid]["坐标X"]) + math.abs(WAR.Person[WAR.CurID]["坐标Y"] - WAR.Person[enemyid]["坐标Y"])
		if offset > 11 then
			offset = 11
		end
		hurt = (hurt) * (100 - (offset - 1) * 3) / 100
		--hurtsh = hurtsh + (100 - (offset - 1) * 3) / 100 -1
	end

	--('测试减伤伤害1：'..hurt,1)

	--暴击
	if WAR.BJ == 1 then
	    local bjsh =1.25
		local SLWX = 0
		for i = 1, CC.Kungfunum do
			if JY.Person[eid]["武功" .. i] == 106 or JY.Person[eid]["武功" .. i] == 107  then
				SLWX = SLWX + 1
			end
		end
		--四大恶人
		if match_ID(pid, 44) or match_ID(pid, 98) or match_ID(pid, 99) or match_ID(pid, 100)then
			bjsh = 1.5
		end
		--六脉大招
		if WAR.DSP_LM3== 1 then
			bjsh = 1.5	
		end
		--袁承志
		if match_ID(pid, 54) and inteam(pid) then 
			bjsh = bjsh + 0.05 * JY.Base["天书数量"]
			if bjsh > 1.5 then
				bjsh = 1.5 
			end
		end
		--逆运
		if  match_ID(pid, 578) then
			bjsh = bjsh + 0.1
		end
		--逆运
		if Curr_NG(pid,104) then
			bjsh = bjsh + 0.2
		elseif PersonKF(pid, 104) then
			bjsh = bjsh + 0.1
		end
		--金雁功
		if Curr_QG(pid,223) then
			bjsh = bjsh + 0.1
		end	
		--逆运
		if Curr_NG(eid,104) then
			bjsh = bjsh - 0.15
		end	
		--九逆
		if Curr_NG(eid,107) and PersonKF(eid,104)then 
			bjsh = bjsh - 0.2
		end
		--黄裳
		if match_ID(eid, 637) then
			bjsh = 1
		end
        --天佛降世
	    if match_ID(eid,9986) and WAR.FUHUOZT[eid] ~= nil and WAR.BJ == 1 and hurt > 0 then
		   bjsh = 1
		   dng = dng + 1200
		   Set_Eff_Text(enemyid, "特效文字1", "天佛降世")
	    end			
		--森罗万象
		if SLWX == 2  then
			WAR.Person[enemyid]["特效动画"] = 6
			Set_Eff_Text(enemyid, "特效文字2", "森罗万象")
			--免疫会心之一击的额外杀气
		    if WAR.HXZYJ == 1 then
				dng = dng + 1200
			end
			bjsh = 1
		end
		--hurtsh = hurtsh + bjsh - 1
		hurt = hurt * bjsh
	end	


    if Cat('破绽',enemyid) and hurt > 0 and WAR.Weakspot[eid] ~= nil then 
        local num = 3
        if match_ID(pid,635) and (JY.Person[pid]["六如觉醒"] > 0 or isteam(pid) == false) then 
            num = 6   
        end
        
        local pz_str = "击中破绽";
        
        if WAR.Weakspot[eid] < num then 
            hurt = math.modf(hurt * 1.25)
            ang = math.modf(ang * 1.25)
            if WAR.Weakspot[eid] == 1 then
                pz_str = "再中破绽";
            elseif WAR.Weakspot[eid] == 2 then
                pz_str = "叁中破绽";
            elseif WAR.Weakspot[eid] == 3 then
                pz_str = "肆中破绽";
            elseif WAR.Weakspot[eid] == 4 then
                pz_str = "伍中破绽";
            elseif WAR.Weakspot[eid] == 5 then
                pz_str = "陆中破绽";				
            end
            WAR.Weakspot[eid] = WAR.Weakspot[eid] + 1
            if WAR.Person[enemyid]["特效文字0"] ~= nil then
                WAR.Person[enemyid]["特效文字0"] = pz_str.."+"..WAR.Person[enemyid]["特效文字0"]
            else
                WAR.Person[enemyid]["特效文字0"] = pz_str
            end
            if WAR.Person[enemyid]["特效动画"] == nil or WAR.Person[enemyid]["特效动画"] == -1 then
                WAR.Person[enemyid]["特效动画"] = 63
            end
        end    
    end    

------------------------------------------------------------
--------------------增伤特效--------------------------------
------------------------------------------------------------
	
--------------------天赋增伤特效----------------------------

	--毒王每5点中毒程度增伤1%
	if pid == 0 and JY.Base["标准"] == 9 then		
		local dw = JY.Person[pid]["中毒程度"]/500
		zjh = zjh + (hm-zjh)*dw
	end

	--程英，半血以下，攻击时伤害一*120%
	if match_ID(pid, 63) and JY.Person[pid]["生命"] < math.modf(JY.Person[pid]["生命最大值"] / 2) then
		zjh = zjh + (hm-zjh)*0.2
	end
	--尼摩星伤害永久提高1.5倍
	if match_ID(pid, 159) then
		--hurt = math.modf(hurt * 1.5)
		zjh = zjh + (hm-zjh)*0.5
	end
	--brolycjw：龙岛主，攻击时伤害一*120%
	if match_ID(pid, 39) then
		zjh = zjh + (hm-zjh)*0.2
	end

	--达尔巴，被死战锁定的目标，伤害一+50%
	if match_ID(pid, 160) and WAR.SZSD == eid then
		--hurt = math.modf(hurt * 1.5)
		zjh = zjh + (hm-zjh)*0.5
	end


	--蓝凤凰，攻击时伤害一*110%
	if match_ID(pid, 25) then
		zjh = zjh + (hm-zjh)*0.1
	end
 
	--周伯通，每行动一次，攻击时伤害一+10%
	if match_ID(pid, 64) then
		local ztb = WAR.ZBT / 10
		if ztb > 0.4 then
			ztb = 0.4
		end
		zjh = zjh + (hm-zjh)*ztb
	end
	
 	--诸法无我每行动一次，攻击时伤害一+5%
	if WAR.PD["诸法无我"][pid] ~=nil and WAR.PD["诸法无我"][pid] > 0 then
		--hurtsh = hurtsh + WAR.PD["诸法无我"][pid]/20
		zjh = zjh + (hm-zjh)*WAR.PD["诸法无我"][pid]/20
	end  
    
	--拳系大招，攻击时伤害一*133.3%
	if WAR.LXZQ == 1 then
		--hurt = math.modf(hurt * 1.333)
		--hurtsh = hurtsh +0.333
		zjh = zjh + (hm-zjh)*0.333
	end
	--圣火三使 伤害提高
	if WAR.ZDDH == 14 and (pid == 173 or pid == 174 or pid == 175) then
		local shz = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[WAR.CurID]["我方"] then
			shz = shz + 1
			end
		end
		if shz == 3 then			
			--hurtsh = hurtsh +0.5
			zjh = zjh + (hm-zjh)*0.5
		end
	end	
	--全真七子，天罡北斗阵，增加伤害和气攻
	if WAR.ZDDH == 73 then
		if (pid >= 123 and pid <= 128) or pid == 68 then
			--hurt = math.modf(hurt * (1+0.30))
			--hurtsh = hurtsh + 0.3
			zjh = zjh + (hm-zjh)*0.3
		end
	end		
	--宋青书 一个女的+5%伤害一
	if match_ID(pid, 82) then
		local s = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[WAR.CurID]["我方"] and JY.Person[WAR.Person[j]["人物编号"]]["性别"] == 1 then
				s = s + 1
			end
		end
		--hurt = math.modf(hurt * (1 + s*0.05))
		--hurtsh = hurtsh + s*0.05
		zjh = zjh + (hm-zjh)*s*0.05
	end
	
	--骆冰 一个男的+5%伤害一
	if match_ID(pid, 154) then
		local s = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[WAR.CurID]["我方"] and JY.Person[WAR.Person[j]["人物编号"]]["性别"] == 0 then
				s = s + 1
			end
		end
		--hurt = math.modf(hurt * (1 + s*0.05))
		-- hurtsh = hurtsh + s*0.05
		 zjh = zjh + (hm-zjh)*s*0.05
	end
  
	--岳灵珊 每个剑法提高伤害一5%
	if match_ID(pid, 79) or match_ID(pid,9996) then
		local JF = 0
		for i = 1, CC.Kungfunum do
			if JY.Wugong[JY.Person[pid]["武功" .. i]]["武功类型"] == 3 then
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
	--主角拳系，每个拳法练到极，增加造成的5%伤害
	if JY.Base["标准"] == 1 and pid == 0 then
		local lxzq = 0
		for i = 1, CC.Kungfunum do
			if JY.Wugong[JY.Person[0]["武功" .. i]]["武功类型"] == 1 and JY.Person[0]["武功等级" .. i] == 999 then
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
	--灭绝的玉石俱焚状态
	if WAR.YSJF[pid] ~= nil then
		--hurt = math.modf(hurt * 1.5)
		--hurtsh = hurtsh + 0.5
		zjh = zjh + (hm-zjh)*0.5
	end
	
	--阿紫曼珠沙华，血量越低伤害越高，100%血无加成，0血100%加成
	if match_ID(pid, 47) and WAR.JYZT[pid]~=nil then
		local bonus_perctge = 0
		bonus_perctge = 2 - JY.Person[pid]["生命"] / JY.Person[pid]["生命最大值"]
		--hurt = math.modf(hurt * bonus_perctge)
		--hurtsh = hurtsh + bonus_perctge - 1
		zjh = zjh + (hm-zjh)*(bonus_perctge - 1)
	end
	--郭靖的降龙十八掌，有余不尽
	if WAR.YYBJ > 9 then
		--hurt = math.modf(hurt*(1+0.08*WAR.YYBJ));
		--hurtsh = hurtsh + 0.04*WAR.YYBJ
		zjh = zjh + (hm-zjh)*0.04*WAR.YYBJ
	end	
	--九剑真传，撩剑式伤害+30%
	if WAR.JJZC == 3 then
		--hurt = math.modf(hurt*1.3);
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end	
	--排云掌
	if WAR.BJYPYZ > 0 then
		--hurt = math.modf(hurt*(1+0.08*WAR.BJYPYZ));
		--hurtsh = 0.04*WAR.BJYPYZ
		zjh = zjh + (hm-zjh)*0.04*BJYPYZ
	end	
	--文泰来，100%血无加成，1血50%加成
	if match_ID(pid, 151) then
		local HZDBJ = 0
		HZDBJ = 1- JY.Person[pid]["生命"] / JY.Person[pid]["生命最大值"]
		--hurt = hurt +math.modf(HZDBJ)
        if HZDBJ > 0.5 then 
            HZDBJ = 0.5    
        end
		--hurtsh = hurtsh + HZDBJ
		zjh = zjh + (hm-zjh)*0.04* HZDBJ
	end		
    --上官剑南血越少伤害越高
	if match_ID(pid, 567) and JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 4 then
		--hurt = math.modf(hurt*2)
		--hurtsh = hurtsh + 0.5
		zjh = zjh + (hm-zjh)*0.5
       end
    if match_ID(pid, 567) and JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 2 then
		--hurt =  math.modf(hurt*1.5)
		--hurtsh = hurtsh + 0.25
		zjh = zjh + (hm-zjh)*0.25
    end	
    --仁者 善恶有报	
	if WAR.SEYB == 1 and JY.Person[pid]["品德"] >= 120 and DWPD() then
		if JLSD(0,(JY.Person[pid]["品德"]-40),pid) then
			--hurt = math.modf(hurt*1.5)
			hurtsh = hurtsh + 0.3 
        elseif JLSD(0,(JY.Person[pid]["品德"]-100),pid) then
			--hurt = math.modf(hurt*0.5) 
		  -- hurtsh = hurtsh - 0.3 
		   zjh = zjh + (hm-zjh)*(- 0.3 )     	   
		end	 
	end	
	
     --无妄无我
	if match_ID(pid,9980) then
		--hurt = math.modf(hurt*math.random(75,125)/100)
		hurtsh = hurtsh + math.random(75,125)/100 - 1
		zjh = zjh + (hm-zjh)*(math.random(75,125)/100 - 1)
	end	
	--无崖子对男性攻击增伤20%
	if match_ID(pid, 116) and JY.Person[eid]["性别"] == 0 then
		--hurt = math.modf(hurt*1.2);
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end
	--李莫愁对男性增伤10%
	if match_ID(pid, 161) and JY.Person[eid]["性别"] == 0 then
		--hurt = math.modf(hurt*1.1);
		--hurtsh = hurtsh + 0.1
		zjh = zjh + (hm-zjh)*0.1
	end	
	
	--陈家洛对女性攻击伤害*50%
	if match_ID(pid, 75) and JY.Person[eid]["性别"] == 1 then
		--hurt = math.modf(hurt*0.5);
		--hurtsh = hurtsh - 0.3
		zjh = zjh + (hm-zjh)*(-0.3)
	end
	
	--天罡大招，伤害增加30%
	if WAR.JSTG == 1 then
		--hurt = math.modf(hurt*1.3)
		--hurtsh = hurtsh + 0.3
		zjh = zjh + (hm-zjh)*0.3
	end
	--王重阳1 一气化三清，伤害增加20%倍	
	if match_ID(pid,129)  and WAR.YQFSQ == 1 then
		--hurt = math.modf(hurt*1.2)	
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end
	--黄蓉奇门遁甲，红色增伤
	if WAR.Person[WAR.CurID]["我方"] == true and GetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"],6) == 2 then
		--hurt = math.modf(hurt*1.2)
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end	
	--毒王大招，伤害增加30%	
	if WAR.YTML == 1 then
		--hurt = math.modf(hurt*1.3)
		--hurtsh= hurtsh + 0.3
		zjh = zjh + (hm-zjh)*0.3
	end		
  	--仁者
	if JY.Base["标准"] == 7 and JY.Person[pid]["品德"] > 100 then
	   --hurt =  math.modf(hurt*(JY.Person[pid]["品德"]/100))
	   --hurtsh = hurtsh + JY.Person[pid]["品德"]/100 - 1
	   zjh = zjh + (hm-zjh)*(JY.Person[pid]["品德"]/100 - 1)
    end	
	--萧玲
    if match_ID(pid,574) then 
		local n = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
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

--------------------武功/组合增伤特效----------------------------

	--刀剑归真，攻击时伤害一*130%
	if WAR.DJGZ == 1 then
		--hurtsh = hurtsh + 0.3
		zjh = zjh + (hm-zjh)*0.3
	end
	--武穆遗书

    for i = 0, WAR.PersonNum - 1 do
		local zid = WAR.Person[i]["人物编号"]
		if WAR.Person[i]["死亡"] == false and WAR.Person[i]["我方"] and PersonKF(zid, 199) then
			--hurtsh = hurtsh + 0.1	
			zjh = zjh + (hm-zjh)*0.1
			break
		end
	end
	
	--斗转星移伤害和杀集气计算
	if WAR.DZXYLV[pid] ~= nil and WAR.DZXYLV[pid] > 10 then
		local dz = WAR.DZXYLV[pid] / 100 - 1
		--hurt = math.modf(hurt * WAR.DZXYLV[pid] / 100)
		--hurtsh = hurtsh + dz
		zjh = zjh + (hm-zjh)*dz
	end

	--逆运走火
	--伤害一加成
	if WAR.PD["走火状态"][pid] == 1 then
		--hurt = math.modf(hurt * 1.1)
		--hurtsh = hurtsh + 0.1
		zjh = zjh + (hm-zjh)*0.1
	end

	--落英神剑掌，配合桃花绝技，根据敌方内力耗损量追加伤害，上限+100%
	if wugong == 12 and TaohuaJJ(pid) then
		local mp_percentage = (JY.Person[eid]["内力最大值"]-JY.Person[eid]["内力"])/JY.Person[eid]["内力最大值"]
		--hurt = math.modf(hurt * (1 + mp_percentage))
		--hurtsh =  hurtsh + mp_percentage
		zjh = zjh + (hm-zjh)*mp_percentage
	end

	--罗汉伏魔提升伤害和杀气效果为：[(当前内力值/500)×(武功消耗内力/140)]%
	if Curr_NG(pid, 96) or ((Curr_NG(pid, 108) or match_ID(pid,38)) and PersonKF(pid,96)) then
		local nlmod = JY.Person[pid]["内力"]/30000
		local wgmod = JY.Wugong[wugong]["消耗内力点数"]/2000
		local totalmod = nlmod + wgmod;
		--石破天效果提高1.1倍
		if match_ID(pid, 38)  or Curr_NG(pid, 108) then
			totalmod = totalmod * 1.1;
		end
		--hurt = math.modf(hurt * totalmod)
		--hurtsh = hurtsh + totalmod
		zjh = zjh + (hm-zjh)*totalmod
	end
 
	--进阶云雾，对于半血以下敌人伤害*2
	if wugong == 32 and PersonKF(pid,175) and JY.Person[eid]["生命"]<JY.Person[eid]["生命最大值"]/2 then
		--hurt = hurt * 2
		--hurtsh = hurtsh + 0.5
		zjh = zjh + (hm-zjh)*0.5
	end
	
	--琴棋书画之倚天屠龙功，增伤20%
	if WAR.QQSH3 == 1 then
		--hurt = math.modf(hurt*1.2);
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end	
	--九阴增伤20%
	--阴内主运或者阴罡学会九阴后
	if Curr_NG(pid, 107) and (JY.Person[pid]["内力性质"] == 0 or JY.Person[pid]["内力性质"] == 3) then
		--hurt = math.modf(hurt*1.2);
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end
	--龙象增伤10%
	if Curr_NG(pid, 103) then
		--hurt = math.modf(hurt*1.1);
		--hurtsh = hurtsh + 0.1
		zjh = zjh + (hm-zjh)*0.1
	end
	
	--血河神鉴增伤10%
	if Curr_NG(pid, 163) then
		--hurt = math.modf(hurt*1.1);
		--hurtsh = hurtsh + 0.1
		zjh = zjh + (hm-zjh)*0.1
	end

--------------------状态增伤特效----------------------------

	  
	--蓄力攻击
	if WAR.Actup[pid] ~= nil then
		--主运蛤蟆，伤害一*150%
		if  Curr_NG(pid, 95)  then
			--hurt = math.modf(hurt * 1.5)
			--hurtsh = hurtsh + 0.5
			zjh = zjh + (hm-zjh)*0.5
		--常态，伤害一*125%
		else
			--hurt = math.modf(hurt * 1.25)
		  --hurtsh  =	hurtsh + 0.25
		  zjh = zjh + (hm-zjh)*0.25
	   end
    end
	--梅长苏
	if WAR.PD["梅长苏"][pid]~= nil and  WAR.PD["梅长苏"][pid] > 0  then
		--hurtsh = hurtsh - WAR.PD["梅长苏"][pid]
		zjh = zjh + (hm-zjh)*(- WAR.PD["梅长苏"][pid])
		WAR.PD["梅长苏"][pid] = nil
	end
	--虚弱状态，伤害减半
	if WAR.XRZT[pid] ~= nil then
		--hurt = math.modf(hurt * 0.5)
		--hurtsh = hurtsh - 0.5
		zjh = zjh + (hm-zjh)*(-0.5)
	end
	--lib.Debug("当前步骤25，虚弱状态，伤害和杀气都减半"..hurt)
	--虚弱状态1，伤害减半
	if WAR.XRZT1[pid] ~= nil then
		--hurt = math.modf(hurt * 0.5)
		--hurtsh = hurtsh - 0.5
		zjh = zjh + (hm-zjh)*(-0.5)
	end
	--放下屠刀伤害减少30%
	if WAR.PD["放下屠刀"][pid] ~= nil then
		zjh = zjh + (hm-zjh)*(-0.3)
	end		
	if WAR.PD["洞火"][pid] ~= nil then
		--hurtsh = hurtsh - 0.1
		zjh = zjh + (hm-zjh)*(-0.1)
	end
	--辰宿列张
	if WAR.MRSHZT[pid] ~= nil then
	   --hurt = math.modf(hurt * math.random(5,12)/10)
	   --hurtsh = hurtsh + (math.random(5,12)/10-1)
	   zjh = zjh + (hm-zjh)*(math.random(5,12)/10-1)
	end
 
	--集中状态，伤害和杀气都减半
	if WAR.Focus[pid] ~= nil then
		--hurt = math.modf(hurt * 0.5)
		--hurtsh = hurtsh - 0.5
		zjh = zjh + (hm-zjh)*(-0.5)
	end


	--欧阳锋  战斗171 伤害减少
	if pid == 60 and WAR.ZDDH == 171 then
		--hurtsh = hurtsh - 0.2
		zjh = zjh + (hm-zjh)*(-0.2)
	end
	
	--装备鸳鸯刀，6级，夫妻伤害提高20%
	if JY.Person[pid]["武器"] == 217 and wugong == 62 and JY.Thing[217]["装备等级"] == 6 then
		--hurt = math.modf(hurt*1.2);
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end	
	if JY.Person[pid]["武器"] == 218 and wugong == 62 and JY.Thing[218]["装备等级"] == 6 then
		--hurt = math.modf(hurt*1.2);
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end
		
	--论剑打赢王重阳，增伤20%
	if pid == 0 and JY.Person[129]["论剑奖励"] == 1 then
		--hurt = math.modf(hurt*1.2)
		--hurtsh = hurtsh + 0.2
		zjh = zjh + (hm-zjh)*0.2
	end
		
	--阴阳无极功
	if Curr_NG(pid, 221) then
		local nl = JY.Person[pid]['内力']
		local n = limitX(1+nl/20000,0,1.5)
		--hurt = math.modf(hurt*n);
		--hurtsh = hurtsh + n -1
		zjh = zjh + (hm-zjh)*(n-1)
	end
--------------------其它增伤特效----------------------------
		--打狗阵
	if WAR.ZDDH == 344 and inteam(pid) == false then
		--hurt = math.modf(hurt * 1.3)
		--hurtsh = hurtsh + 0.3
		zjh = zjh + (hm-zjh)*0.3
    end	
		
    if WAR.HQT_ZL[pid]~= nil then 
		local n = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[WAR.CurID]["我方"]  then
			    n = n + 1
			end	
		end
		--hurt =math.modf(hurt*(1+n*0.05))
		--hurtsh = hurtsh + n*0.05
		zjh = zjh + (hm-zjh)*n*0.05
	end
	
    hurt = math.modf(hurt *  (1+zjh))
 end  


	--攻方面板上每个极+3%伤害，守方面板每个极-3%伤害
	--hurt =  math.modf(hurt * (1 + (calc_mas_num(pid) - calc_mas_num(eid))* 0.03))
	
	if not inteam(pid) then
		local nd = JY.Base['难度']-1
	    hurt = math.modf(hurt*(1+ nd*0.08))
	end
	
---------------------------------------------------------------------------
--///////////////////////////加减法计算增伤特效////////////////////////////////////
---------------------------------------------------------------------------


	--毒王的中毒补偿每5点中毒程度增伤1%
	if pid == 0 and JY.Base["标准"] == 9 then
		hurt = hurt + JY.Person[pid]["中毒程度"] / 2
	end
	
--	lib.Debug("当前步骤41，毒王每5点中毒程度增伤1%"..hurt)
	--蓝烟清：燃木刀法，普通内功加力额外增加伤害
	if wugong == 65 and WAR.NGJL > 0 then
		hurt  = hurt + math.modf(JY.Wugong[WAR.NGJL]["攻击力10"]/12);
	end
	
	if WAR.DFMQ == 1 then
		hurt = hurt + math.modf((JY.Person[eid]["生命最大值"]*0.01)*math.random(2,4))
	end
	
	--欧阳锋根据蛤蟆蓄力增加伤害
	if match_ID(pid, 60) and WAR.OYFXL > 0 then
		hurt = hurt + WAR.OYFXL/2
	end
	
  	--梁萧蓄力增加伤害
	if match_ID(pid, 635) and WAR.LXXL > 0 then
		hurt = hurt + WAR.LXXL/2
	end	
	
	--解牛刀法
    if wugong == 193 and DWPD() then
	    if JY.Person[eid]["生命"]/JY.Person[eid]["生命最大值"] < 0.4 and JLSD(10,60,pid) then
			hurt = hurt + math.modf(JY.Person[eid]["生命最大值"]*0.05)
		end
		WAR.Person[enemyid]["特效动画"] = 116
		Set_Eff_Text(enemyid, "特效文字3", "良庖岁更刀")
	end
	--须弥山神掌
    if 	wugong == 24 and DWPD() then
	    if JY.Person[eid]["生命"]/JY.Person[eid]["生命最大值"] < 0.5 and JLSD(10,60,pid) then
			 WAR.PD["如来神掌"][pid] = 1
			hurt = hurt + math.modf(JY.Person[eid]["生命最大值"]*0.05)		   
	    end	 
	end
	--万佛朝宗
	if WAR.PD["万佛朝宗"][pid]~=nil and WAR.PD["万佛朝宗"][pid] == 1 then
		local a1 = JY.Person[eid]["生命"]/JY.Person[eid]["生命最大值"]
		local nl = JY.Person[eid]["内力"]/20
		if inteam(eid) then
		   hurt = hurt + math.modf(JY.Person[eid]["生命"]*0.2)	
		else
		   hurt = hurt + math.modf(JY.Person[eid]["生命"]*0.2)
		end	
        AddPersonAttrib(eid,"内力",-nl)
		if a1 < 0.333 and JLSD(0,(1-a1)*20,pid) then
			if inteam(eid) then
				hurt = hurt + JY.Person[eid]["生命"]
			else
				hurt = hurt + JY.Person[eid]["生命"]
		    end
		end
    end	 
	--棋势伤害
	if match_ID(pid,586) and JY.Base["天书数量"] > 0  then
		local YQ = 0
		YQ = YQ +JY.Base["天书数量"]*10
		hurt = hurt +YQ
	end	
	
	if WAR.LHQ_BNZ == 1 then		--般若掌 伤害+50
		hurt = hurt + 50
	end
	
	if WAR.JGZ_DMZ == 1 then		--达摩掌 伤害+100
		hurt = hurt + 100
	end
	
	if WAR.WD_CLSZ == 1 then		--赤练神掌 伤害+70
		hurt = hurt + 70
	end
		
	--灼烧追加伤害
	if JY.Person[eid]["灼烧程度"] > 25 then
		zshurt = zshurt + JY.Person[eid]["灼烧程度"]*2
	elseif JY.Person[eid]["灼烧程度"] > 0 then
		zshurt = zshurt + JY.Person[eid]["灼烧程度"]	
	end	
	lib.Debug("当前步骤42，灼烧追加伤害"..hurt)
		--丁春秋攻击，根据敌方中毒追加伤害
	if match_ID(pid, 46) and JY.Person[eid]["中毒程度"] > 0 then
		zshurt = zshurt + JY.Person[eid]["中毒程度"]
	end	
		-- 玄澄无量禅震追内伤加伤害
	if WAR.XC_WLCZ == 1 then
		zshurt = zshurt + JY.Person[eid]["受伤程度"]*2
	end	
		--李沅芷 芙蓉金针
	if match_ID(pid, 569) then
	    local fr = JY.Person[pid]["暗器技巧"]
		zshurt = zshurt + fr 
	end	
	--归辛树，使用拳法攻击追加100点伤害，如未装备武器，则此加成翻倍
	if match_ID(pid, 186) and JY.Wugong[wugong]["武功类型"] == 1 then
		hurt = hurt + 100
		if JY.Person[pid]["武器"] == -1 then
			zshurt = zshurt + 100
		end
	end
	--九阴飞絮
	if WAR.JYZJ_FXJ==1 then
		zshurt = zshurt + 100
		if Curr_NG(pid,107) then 
			zshurt = zshurt + 200
		end
	end	
	--青莲剑歌
	if WAR.QLJG  == 1 then
		local h = JY.Person[pid]['御剑能力']
		zshurt = zshurt + h
	end	

	--凝血神爪
	if wugong == 134 and DWPD() and WAR.LXZT[eid]~=nil then
		zshurt = zshurt + WAR.LXZT[eid]
    end
    --任飞燕
    if match_ID(pid,615) and wugong ==62 then
       zshurt = zshurt + math.modf(JY.Person[pid]["轻功"]/3)	
	end
    
	if match_ID(pid, 511) then 
		local fx = WAR.FXDS[eid] or 0
		local lx = WAR.LXZT[eid] or 0
		zshurt = zshurt + fx*2 + lx*2 + 100
	end
	--开太极
	if WAR.WDKTJ == 1 then
        local s1 = 1-JY.Person[pid]["生命"]/JY.Person[pid]["生命最大值"]
		local s2 = JY.Person[pid]["内力"]/JY.Person[pid]["内力最大值"]		
        local s3 = JY.Person[pid]["内力"]*0.04
		local s4 = s1+s2
		local s = math.modf(s3*s4) 
		zshurt = zshurt + s
		if WAR.ACT > 1 then
			zshurt = zshurt + s*0.7
		end	
	end	
    
	-- 世尊降魔
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

	--剑二十三
	if WAR.SL23 == 1 then
		if hurt < 200 then
			zshurt = zshurt + 200
	    end	
    end	
	--惊天一剑伤害 
	if match_ID(pid, 652) and WAR.JTYJ[pid] ~= nil then
		zshurt = zshurt + 200	
	end
    
	--白绣
	if match_ID(pid, 582)  then
		local bxbf = JY.Person[eid]["冰封程度"]
		zshurt = zshurt + bxbf*2
	end
	
    if WAR.PD['降龙·见龙在田'][pid] == 1 then 
        zshurt = zshurt + 200
    end
    
	hurt = hurt + zshurt

---------------------------------------------------------------------------
--///////////////////////////伤害减伤计算////////////////////////////////////
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-----------------------------闪避清除伤害-------------------------------------
---------------------------------------------------------------------------
	if WAR.Miss[eid] == 1 then 
		hurt = 0
	end
	
---------------------------------------------------------------------------
--///////////////////////////乘法法计算////////////////////////////////////
---------------------------------------------------------------------------
---------------------------------------------------------------------------
--///////////////////////////天赋减伤////////////////////////////////////
---------------------------------------------------------------------------
if hurt > 30 then 
	local hurtjs = 0
	local jsm = 1

	--连击，伤害，气攻计算
	if WAR.ACT > 1 then
		local LJ_fac = 0.7	--通常为70%
		--东方不败不减少 张三丰
		--六脉神剑，夫妻刀法不减少
		--夭矫空碧不减少
		if match_ID(pid, 27) or wugong == 49 or wugong == 62 or WAR.YNXJ == 1 or match_ID(pid,5)  then
			LJ_fac = 1
		end	
		--瑜伽密乘减少被连击的伤害，气攻
		--主运减少40%
		--被动减少20%
		if Curr_NG(eid, 169)  then
			LJ_fac = LJ_fac - 0.4
		elseif PersonKF(eid, 169) then
			LJ_fac = LJ_fac - 0.2
		end
		hurt = math.modf(hurt * LJ_fac)
	end


	if not isteam(eid) then
		local nd = JY.Base['难度']-1
		--hurt = math.modf(hurt*(1 - nd*0.05))
		--hurtjs = hurtjs + nd*0.05
		hurtjs =  hurtjs + (jsm-hurtjs)*nd*0.05
	end	


	--内伤增加伤害
	if JY.Person[eid]["受伤程度"] > 0 then
		local ns = - JY.Person[eid]["受伤程度"] * 0.003
		hurtjs =  hurtjs + ns--(jsm-hurtjs)*ns
	end	


    if WAR.PD['西瓜刀·残刀'][pid] ~= nil then 
        if WAR.PD['西瓜刀·残刀'][pid][1] ~= nil then 
            local pf = WAR.PD['西瓜刀·残刀'][pid][1]
			local xg = - pf/100
			hurtjs =  hurtjs + xg--(jsm-hurtjs)*xg
        end
    end

	
	-- 仪琳
	if match_ID(eid,583) then
		--hurt = math.modf(hurt *0.85)
		--hurtjs = hurtjs + 0.15
		hurtjs =  hurtjs + (jsm-hurtjs)*0.15
	end

	--brolycjw: 木岛主，被攻击时伤害一*80%
	if match_ID(eid, 40) then
		--hurt = math.modf(hurt * 0.8)
		--hurtjs = hurtjs + 0.2
		hurtjs =  hurtjs + (jsm-hurtjs)*0.2
	end	

	--毒王每5点中毒程度减伤1%
	if eid == 0 and JY.Base["标准"] == 9 then
		--hurt = math.modf(hurt * (1 - JY.Person[eid]["中毒程度"]/500))
		local ns = JY.Person[eid]["中毒程度"]/500
		hurtjs =  hurtjs + (jsm-hurtjs)*ns
	end	

	--谢逊，被攻击时伤害一*85%
	if match_ID(eid, 13) then
		--hurt = math.modf(hurt * 0.85)
		--hurtjs = hurtjs + 0.15
		hurtjs =  hurtjs + (jsm-hurtjs)*0.15
	end

	--苏荃和霍青桐，为守方，在战场时，伤害一减少10%
	for j = 0, WAR.PersonNum - 1 do
		if (match_ID(WAR.Person[j]["人物编号"], 87) or match_ID(WAR.Person[j]["人物编号"], 74)) and WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
			--hurt = math.modf(hurt * 0.9)
			--hurtjs = hurtjs + 0.1
			hurtjs =  hurtjs + (jsm-hurtjs)*0.1
		end
	end	

	--圣火三使 受伤害减少、气防提高
	if WAR.ZDDH == 14 and (eid == 173 or eid == 174 or eid == 175) then
		local shz = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[enemyid]["我方"] then
			shz = shz + 1
			end
		end
		if shz == 3 then
			--hurt = math.modf(hurt * 0.5)
			--hurtjs = hurtjs + 0.5
			hurtjs =  hurtjs + (jsm-hurtjs)*0.5
		end
	end	


	if WAR.PD["走火状态"][eid] == 1 then
		--hurt = math.modf(hurt * 0.9)
		--hurtjs = hurtjs + 0.1
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
	end

	--欧阳锋  战斗171 受伤害提高
	if eid == 60 and WAR.ZDDH == 171 then
		--hurt = math.modf(hurt * 1.2)
		--hurtjs = hurtjs - 0.2 
		hurtjs =  hurtjs + (jsm-hurtjs)*(-0.2)
	end
		
	--乔峰，文泰来 萧秋水减伤30%，半血时50%，血量低于25%提升75%
	if match_ID(eid, 50) or match_ID(eid, 151) or match_ID(eid, 652) then
		local minhurt = math.modf(hurt * 0.15)
		local qfjs = 1 - JY.Person[eid]["生命"] / JY.Person[eid]["生命最大值"]
        qfjs = limitX(qfjs,minhurt,0.35)
		--hurt = math.modf(hurt * JY.Person[eid]["生命"] / JY.Person[eid]["生命最大值"])
		--hurtjs = hurtjs + qfjs
		hurtjs =  hurtjs + (jsm-hurtjs)*qfjs
	end
			
	--防御状态
	if WAR.Defup[eid] == 1 then
		--有八荒，减伤40%
		if PersonKF(eid, 101) then
			--hurt = math.modf(hurt * 0.6)
			--hurtjs = hurtjs + 0.4
			hurtjs =  hurtjs + (jsm-hurtjs)*0.4
		--无八荒，减伤25%
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
	
	--范遥挨打加减伤，上限20%
	if match_ID(eid,10) then
		local rd = (100 - WAR.GMYS)/100
		if rd > 0.2 then
			rd = 0.2
		end
		--hurtjs = hurtjs + rd
		hurtjs =  hurtjs + (jsm-hurtjs)*rd
	end
	
	--冯衡
	if match_ID(eid, 588) then
		--hurt = math.modf(hurt * 0.9)
		--hurtjs = hurtjs + 0.1
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
	end

	--被杨逍击中的人，伤害增加1%，上限20%
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
		
	--周芷若，每个内功减少受到的4%伤害
	if match_ID(eid, 631) then
		local zzr = 0
		local zzr1 = 0
		for i = 1, CC.Kungfunum do
			if JY.Wugong[JY.Person[0]["武功" .. i]]["武功类型"] == 6 then
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
	
	--主角拳系，每个拳法练到极，减少受到的5%伤害
	if JY.Base["标准"] == 1 and eid == 0 then
		local lxzq = 0
		local lxzq1 = 0
		for i = 1, CC.Kungfunum do
			if JY.Wugong[JY.Person[0]["武功" .. i]]["武功类型"] == 1 and JY.Person[0]["武功等级" .. i] == 999 then
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

		--主角刀系，每个刀法练到极减少受到的5%伤害 JY.Wugong[JY.Person[0]["武功" .. i]]["武功类型"] == 5 and JY.Person[0]["武功等级" .. i] == 999
	if JY.Base["标准"] == 4 and eid == 0 then
		local askd = 0
		for i = 1, CC.Kungfunum do
			if JY.Wugong[JY.Person[eid]["武功" .. i]]["武功类型"] == 4 and JY.Person[eid]["武功等级" .. i] == 999 then
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
	
	--袁紫衣每个奇门到极减少受到的5%伤害 
	if match_ID(eid,587) then
		local YZYQM = 0
		for i = 1, JY.Base["武功数量"] do
			if JY.Wugong[JY.Person[0]["武功" .. i]]["武功类型"] == 5 and JY.Person[0]["武功等级" .. i] == 999 then
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
	
	--陈家洛被女性攻击伤害*200%
	if match_ID(eid, 75) and JY.Person[pid]["性别"] == 1 then
		--hurt = math.modf(hurt*2)
		--hurtjs = hurtjs - 1
		hurtjs =  hurtjs + (jsm-hurtjs)*(-1)
	end
	
	--同时学有易筋神功+金刚不坏体，主运易筋神功必出“金钟罩护”特效
	--天佛降世/鳌拜主运 必出金刚不坏  
    if(Curr_NG(eid, 144) and (JLSD(30, 90, eid) or match_ID(eid, 603))) or (Curr_NG(eid, 108) and PersonKF(eid, 144)) or match_ID(eid,9986) then
			--hurt = math.modf(hurt *0.7)
			--hurtjs = hurtjs + 0.3
			hurtjs =  hurtjs + (jsm-hurtjs)*0.3
			ang = math.modf(ang *0.7)
			Set_Eff_Text(enemyid, "特效文字0", "金刚不坏")
			WAR.Person[enemyid]["特效动画"] = 88
		--被动
	  elseif PersonKF(eid, 144) and JLSD(30, 65, eid)then
		--hurt = math.modf(hurt *0.8)
		--hurtjs = hurtjs + 0.2
		hurtjs =  hurtjs + (jsm-hurtjs)*0.2
		ang = math.modf(ang *0.8)
		Set_Eff_Text(enemyid, "特效文字0", "金钟罩护体")
		WAR.Person[enemyid]["特效动画"] = 88
	end	


	--无崖子被女性攻击减伤20%
	if match_ID(eid, 116) and JY.Person[pid]["性别"] == 1 then
		--hurt = math.modf(hurt*0.8);
		--hurtjs = hurtjs + 0.2
		hurtjs =  hurtjs + (jsm-hurtjs)*0.2
	end
	--黄衫女被男性攻击减伤10%
	if match_ID(eid, 640) and JY.Person[pid]["性别"] == 0 then
		--hurt = math.modf(hurt*0.9);
		hurtjs = hurtjs + 0.1
	end	
		--紫气天罗组合减伤10%，反冰20点
	if ZiqiTL(eid) and DWPD() and hurt > 0 then
		--hurt = math.modf(hurt*0.9);
		--hurtjs = hurtjs + 0.1
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
		WAR.BFXS[pid] = 1
		JY.Person[pid]["冰封程度"] = JY.Person[pid]["冰封程度"] + 20
		if JY.Person[pid]["冰封程度"] > 100 then
			JY.Person[pid]["冰封程度"] = 100
		end
	end
    
    if match_ID(eid, 9989) then
        if JY.Person[eid]["生命"] < JY.Person[eid]["生命最大值"] / 2 then
		  --hurt = math.modf(hurt/2)
		  --hurtjs = hurtjs + 0.3
		  hurtjs =  hurtjs + (jsm-hurtjs)*0.3
        elseif JY.Person[eid]["生命"] < JY.Person[eid]["生命最大值"] / 4 then
		  --hurt = math.modf(hurt/4)
		  --hurtjs = hurtjs + 0.15
		  hurtjs =  hurtjs + (jsm-hurtjs)*0.15
		end
    end
	
	--全真七子，天罡北斗阵，受伤害减少和增加气防
	if WAR.ZDDH == 73 then
		if (eid >= 123 and eid <= 128)  then
			--hurt = math.modf(hurt * (1-0.30))
			--hurtjs = hurtjs + 0.3
			hurtjs =  hurtjs + (jsm-hurtjs)*0.3
		end
	end	
	--丘处机
	if match_ID(eid,68) then
		--hurtjs = hurtjs + 0.15
		hurtjs =  hurtjs + (jsm-hurtjs)*0.15
	end
	--九阳减伤30%
	--阳内主运或者阳罡学会九阳后	
    --被动减伤10% 
	if PersonKF(eid, 106) and (JY.Person[eid]["内力性质"] == 1 or JY.Person[eid]["内力性质"] == 3) then
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
	
	--九阴减伤10%
	--学会九阴并且是阴内或者天罡
	if PersonKF(eid, 107) and (JY.Person[eid]["内力性质"] == 0 or JY.Person[eid]["内力性质"] == 3) then
		--hurt = math.modf(hurt*0.9);
		--hurtjs = hurtjs + 0.1
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
	end	
	
	--龙象减伤10%
	if Curr_NG(eid, 103) then
		--hurt = math.modf(hurt*0.9);
		--hurtjs = hurtjs + 0.2
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
	end	
	
		--扫地老僧
	if match_ID(eid, 114) and hurt > 0 then
		--hurtjs = hurtjs + 0.3
		hurtjs =  hurtjs + (jsm-hurtjs)*0.3
		Set_Eff_Text(enemyid, "特效文字3", "天佛化生·金刚护体")
	end
	
	--张三丰：无根无形减伤
	if match_ID(eid, 5) and hurt > 0 and JLSD(0,50,eid)then
		--hurt = math.modf(hurt * 0.7)
		--hurtjs = hurtjs + 0.3
		hurtjs =  hurtjs + (jsm-hurtjs)*0.3
		Set_Eff_Text(enemyid, "特效文字2", "无根无形")
	end	
	
    --霍青桐指令
    if WAR.HQT_ZL[eid]~= nil then
		local n = 0
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[enemyid]["我方"]  then
				n = n + 1
			end	
		end
		--hurt =math.modf(hurt*(1-n*0.05))
		--hurtjs = hurtjs + n*0.05
		hurtjs =  hurtjs + (jsm-hurtjs)*n*0.05
	end
	
	--金刚伏魔圈，伤害一减少，气防提高
	if PersonKF(eid, 82) and hurt > 0 then
		local jgfmq = 0
		local effstr = "金刚伏魔圈"
		for j = 0, WAR.PersonNum - 1 do
			if PersonKF(WAR.Person[j]["人物编号"], 82) and WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[enemyid]["我方"] then
				jgfmq = jgfmq + 1
			end
		end
		--上限3人
		if jgfmq > 3 then
			jgfmq = 3
		end
		if jgfmq == 3 then
			effstr = "真."..effstr
		end
		if jgfmq > 1 then
			--hurt = math.modf(hurt * (1-0.15*(jgfmq-1)))
			--hurtjs = hurtjs + 0.15*(jgfmq-1)
			hurtjs =  hurtjs + (jsm-hurtjs)*0.15*(jgfmq-1)
		end
	end

	--江南七怪
	if WAR.ZDDH==189  and  (eid >= 130 and eid <= 136) and hurt > 0  then
		local JLQX = 0
		local effstr = "同生共死"
		for j = 0, WAR.PersonNum - 1 do
			 if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[enemyid]["我方"] then
				JLQX = JLQX + 1
			end
		end
		if JLQX > 1 then
			--hurt = math.modf(hurt * (1-0.1*(JLQX-1)))
			--hurtjs = hurtjs + 0.1*(JLQX-1)
			hurtjs =  hurtjs + (jsm-hurtjs) *0.1*(JLQX-1)
		end
	end			

   -- 菩提金身
	if match_ID(eid,9995) and hurt > 0 then
		if match_ID(eid,577) and (WAR.BJ == 1 or WAR.ACT > 1) then
			--hurtjs = hurtjs + 0.5
			hurtjs =  hurtjs + (jsm-hurtjs) *0.5
		else
			--hurt = math.modf(hurt * 0.5)
			--hurtjs = hurtjs + 0.3
			hurtjs =  hurtjs + (jsm-hurtjs) *0.3
		end
		WAR.Person[enemyid]["特效动画"] = 118
		Set_Eff_Text(enemyid, "特效文字1", "菩提金身")	 
	end
	
    if match_ID(eid,9966) and hurt > 0 then
		--hurtjs = hurtjs + 0.3
		hurtjs =  hurtjs + (jsm-hurtjs) *0.3
    end
    
	if Curr_QG(eid,186) and JLSD(40, 70, eid) and hurt > 0 then
		--hurt = math.modf(hurt*0.7)
		--hurtjs = hurtjs + 0.3
		hurtjs =  hurtjs + (jsm-hurtjs) *0.3
 		WAR.Person[enemyid]["特效动画"] = 51
		Set_Eff_Text(enemyid, "特效文字2", "一苇渡江减伤")   
	end
		
	--无酒不欢：凌波微步，
	if Curr_QG(eid, 147) and JLSD(30, 80, eid) and hurt > 0 then
		--hurt = math.modf(hurt *0.6)
		--hurtjs = hurtjs + 0.4
		hurtjs =  hurtjs + (jsm-hurtjs) *0.4
		ang = math.modf(ang *0.6)
		WAR.Person[enemyid]["特效动画"] = 51
		Set_Eff_Text(enemyid, "特效文字2", "凌波微步减伤")
	end
	
	--陆渐三十二身相
    if match_ID(eid, 497) and hurt > 0 then
		--hurt = math.modf(hurt*0.85)
		--hurtjs = hurtjs + 0.15
		hurtjs =  hurtjs + (jsm-hurtjs) *0.15
		WAR.Person[enemyid]["特效文字2"] = "一合相护体"
		WAR.Person[enemyid]["特效动画"] = 136
	end	
	
	--无酒不欢：葵花移行
	--萧半和觉醒
	if Curr_NG(eid, 105) or (match_ID_awakened(eid, 189, 1) and PersonKF(eid, 105)) then
		--葵花尊者必定移形
		local khzz = 0
		if (JLSD(20, 50, eid) or match_ID(eid, 27) or match_ID(eid, 511)) and hurt > 0  then
			--hurt = math.modf(hurt *0.7)
			--hurtjs = hurtjs + 0.3
			hurtjs =  hurtjs + (jsm-hurtjs) *0.3
			ang = math.modf(ang *0.7)
			WAR.Person[enemyid]["特效动画"] = 51
			Set_Eff_Text(enemyid, "特效文字2", "葵花移形")
		end
	end

	--我方赵敏在场
	if ZDGH(enemyid,609) and WAR.Miss[eid] == nil then
		--蓄力时20%减伤
		if WAR.Actup[eid] ~= nil then
			--hurt = math.modf(hurt*0.8)
			--hurtjs = hurtjs + 0.2
			hurtjs =  hurtjs + (jsm-hurtjs) *0.2
		end
	end
	
	--黄蓉奇门遁甲，绿色减伤
	if WAR.Person[enemyid]["我方"] == true and GetWarMap(WAR.Person[enemyid]["坐标X"], WAR.Person[enemyid]["坐标Y"],6) == 1 then
		--hurt = math.modf(hurt*0.8)
		--hurtjs = hurtjs + 0.2
		hurtjs =  hurtjs + (jsm-hurtjs) *0.2
	end
	
	--阴阳无极功
	if Curr_NG(eid, 221) and hurt > 0 then
		local nl = JY.Person[eid]['内力']
		local n = limitX(nl/20000,0,0.5)
		--hurt = math.modf(hurt*n);
		--hurtjs = hurtjs + n
		hurtjs =  hurtjs + (jsm-hurtjs) *n
		WAR.Person[enemyid]["特效动画"] = 21
		Set_Eff_Text(enemyid, "特效文字2", "阴阳无极")
	end
    
     --李沅芷在场
    if ZDGH(enemyid,569) then 	
		--hurt = math.modf(hurt*0.8)
		--hurtjs = hurtjs + 0.2
		hurtjs =  hurtjs + (jsm-hurtjs) *0.2
	end
	
   -- 梅长苏在场，敌方每5点冰封值减少伤害1%
    if ZDGH(enemyid,507) then
		local bfjs = JY.Person[pid]["冰封程度"]/500
		--hurtjs = hurtjs - bfjs
		hurtjs =  hurtjs + (jsm-hurtjs) *bfjs
	end
	--魔道天行
	if ZDGH(enemyid,9991) then
		--hurt = math.modf(hurt*0.9)
		--hurtjs = hurtjs + 0.1
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
    end
    
	
	--无酒不欢：神行百变减伤
	if Curr_QG(eid, 146) and WAR.Miss[eid] == nil then
		local c_up = 0
		--袁承志觉醒后，闪避率+5%
		if match_ID_awakened(eid, 54, 1)   then
			c_up = 10
		end
		if JLSD(40, 65+c_up, eid) and hurt > 0 then
			--hurt = math.modf(hurt *0.7)
			--hurtjs = hurtjs + 0.3
			hurtjs =  hurtjs + (jsm-hurtjs)*0.3
			ang = math.modf(ang *0.7)
			WAR.Person[enemyid]["特效动画"] = 51
			Set_Eff_Text(enemyid, "特效文字2", "神行百变减伤")
		end
	end
	

	
	--论剑打赢独孤，九剑真传70%几率减伤20%，并降低攻方下回合集气位置
	--七夕令狐冲自带
	if (match_ID(eid,9974) or match_ID_awakened(eid,35,2) or (eid == 0 and JY.Person[241]["品德"] == 80) ) and JLSD(15, 85,eid)  and DWPD() and hurt > 0  then
		local jpwz;
		if JY.Wugong[wugong]["武功类型"] == 1 or JY.Wugong[wugong]["武功类型"] == 2 then
			jpwz = "九剑真传·破掌式"
		elseif JY.Wugong[wugong]["武功类型"] == 3 then
			jpwz = "九剑真传·破剑式"
		elseif JY.Wugong[wugong]["武功类型"] == 4 then
			jpwz = "九剑真传·破刀式"
		elseif JY.Wugong[wugong]["武功类型"] == 5 then
			jpwz = "九剑真传·破棍式"
		elseif JY.Wugong[wugong]["武功类型"] == 6 then
			jpwz = "九剑真传·破气式"
		end
		WAR.Person[enemyid]["特效动画"] = 83
		--hurt = math.modf(hurt * 0.8)
		--hurtjs = hurtjs + 0.2
		hurtjs =  hurtjs + (jsm-hurtjs)*0.2
		WAR.JJPZ[pid] = 1	--九剑破招
		Set_Eff_Text(enemyid, "特效文字1", jpwz)
	end
  
		--无酒不欢：太空卸劲35%几率，减伤33.3%，敌方下回合集气位置-120
	for i = 1, JY.Base["武功数量"] do
		if (JY.Person[eid]["武功" .. i] == 15 or JY.Person[eid]["武功" .. i] == 16) and JY.Person[eid]["武功等级" .. i] == 999 then
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
		WAR.TKJQ[pid] = 1	--太空卸劲
		WAR.Person[enemyid]["特效动画"] = 113
		Set_Eff_Text(enemyid, "特效文字3", "太空卸劲")
	end
	WAR.TKXJ = 0
	
	   -- 张三丰蓄力减伤
	if match_ID(eid,5) and WAR.PD["太极蓄力"][eid]~= nil and  WAR.PD["太极蓄力"][eid] > 0 then
		local tjxl = WAR.PD["太极蓄力"][eid]/5000
		hurtjs =  hurtjs + (jsm-hurtjs)*tjxl
	end	 
	
	--打狗阵
	if WAR.ZDDH == 344 and inteam(eid) == false then
		--hurt = math.modf(hurt * 0.7)
		--hurtjs = hurtjs + 0.3
		hurtjs =  hurtjs + (jsm-hurtjs)*0.3
    end	
	

	--杀气降低25%
	if WAR.TJAY == 3 then
		--学有太极神功，触发太极奥义减伤10%
		if PersonKF(eid, 171) and hurt > 0  then
			--hurt = math.modf(hurt * 0.9)
			--hurtjs = hurtjs + 0.1
			hurtjs =  hurtjs + (jsm-hurtjs)*0.1
		end
		WAR.Person[enemyid]["特效动画"] = 21
		--学有太极神功必出真太奥，否则有35%几率发动
		if PersonKF(eid, 171) or JLSD(40, 75, eid) then
			WAR.TJAY = 4
			Set_Eff_Text(enemyid,"特效文字1","太极真义·四两拨千斤");
		else
			Set_Eff_Text(enemyid,"特效文字2","太极奥义");
		end
	end
	
	--不老长春功
	if Curr_NG(eid,183) then
		--hurt = math.modf(hurt * 0.75)
		--hurtjs = hurtjs + 0.25
		hurtjs =  hurtjs + (jsm-hurtjs)*0.25
	end	
	
     --无妄无我
	if match_ID(eid,9980) then
		--hurt = math.modf(hurt*math.random(75,125)/100)
		local wwwql = math.random(75,125)/100 - 1
		hurtjs =  hurtjs + (jsm-hurtjs)*wwwql
	end	
	
 	--诸法无我每行动一次，攻击时伤害一-5%
	if WAR.PD["诸法无我"][eid] ~=nil and WAR.PD["诸法无我"][eid] > 0 then
		--hurt = math.modf(hurt * (1 - WAR.PD["诸法无我"][pid]/20))
	    local zfjs = WAR.PD["诸法无我"][eid]*0.05
		hurtjs =  hurtjs + (jsm-hurtjs)*zfjs
	end  	
	
    --上官剑南 
	if match_ID(eid,567) then
		--hurt = math.modf(hurt*0.9)
		--hurtjs = hurtjs + 0.1
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
    end
	
    --逍遥游
	if Curr_QG(eid,2) then
		--hurt = math.modf(hurt*0.9)
		--hurtjs = hurtjs + 0.1
		hurtjs =  hurtjs + (jsm-hurtjs)*0.1
    end	
	
	--闪避不触发两仪守护，或张家辉的护身戒指
	if hurt > 0 and DWPD() then
		--张家辉的护身戒指             
		if JY.Person[eid]["防具"] == 302 then
			local factor = 3
			if JY.Thing[302]["装备等级"] >=5 then
				factor = 1
			elseif JY.Thing[302]["装备等级"] >=3 then
				factor = 2
			end
			local hn = math.modf(hurt/2*factor)
			if JY.Person[eid]["内力"] > hn then
				--hurt = math.modf(hurt/2)
				--hurtjs = hurtjs + 0.5
				hurtjs =  hurtjs + (jsm-hurtjs)*0.5
				WAR.Person[enemyid]["内力点数"] = (WAR.Person[enemyid]["内力点数"] or 0)+AddPersonAttrib(eid, "内力", -hn)
				WAR.Person[enemyid]["特效动画"] = 144
			end
		end
	end
	--防御减伤
	--hurtjs = hurtjs + math.modf(hurt * (1 - limitX(Def(enemyid)/1500,0,0.7)))	
	if hurtjs > 0.75 then
		hurtjs = 0.75
	end
   hurt =  hurt* (1-hurtjs)
   
end	

	--以下减伤效果，只在伤害大于30时才会触发
	--乾坤大挪移反弹，内力高于对方才触发
	--误伤不触发
	if ((PersonKF(eid, 97) and JY.Person[eid]["内力"] > JY.Person[pid]["内力"]) or (eid == 0 and WAR.NZQK == 1)) and DWPD() and MyFj(WAR.CurID) == false then
		local ft = 0
		--WAR.fthurt = 0
		local nydx = {}
		local nynum = 1
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["我方"] ~= WAR.Person[enemyid]["我方"] and WAR.Person[i]["死亡"] == false and MyFj(i) == false then
				nydx[nynum] = i
				nynum = nynum + 1
			end
		end
			
		--反弹的人
		local nyft = nydx[math.random(nynum - 1)]
		--张无忌可以反弹两人
		local nyft2 = nydx[math.random(nynum - 1)]
			
		local h = 0;
		--被动反弹几率50%，弹伤20%
		--主运反弹几率75%，弹伤30%
		local chance = 51
		local cfr = 0.8
		if Curr_NG(eid, 97) then
			chance = 76
			cfr = 0.7
		end
		--我方，每本天书增加3%反弹几率
		if inteam(eid) then
			chance = chance + JY.Base["天书数量"]*3
		end
		--张无忌反弹40%
		if match_ID(eid, 9) then
			cfr = 0.6
		end
  		--学会九阳神功
		if Curr_NG(eid,106) then
			cfr = 0.6
			chance = 80
		end         
		
		--逆转乾坤，必定反弹50%
		if WAR.NZQK == 1 then
			chance = 101
			cfr = 0.5
		end
			
		if (math.random(100) < chance) and WAR.L_QKDNY[WAR.Person[nyft]["人物编号"]] == nil then
			ft = math.modf(hurt*(1-cfr))			
			hurt = math.modf(hurt*cfr)
			h = math.modf(ft + Rnd(10));		--反弹的伤害
			SetWarMap(WAR.Person[nyft]["坐标X"], WAR.Person[nyft]["坐标Y"], 4, 2);	--反弹者标识为被命中
				
			WAR.L_QKDNY[WAR.Person[nyft]["人物编号"]] = 1;
				
			WAR.Person[nyft]["生命点数"] = (WAR.Person[nyft]["生命点数"] or 0) - h;
			--无酒不欢：记录人物血量
			WAR.Person[nyft]["Life_Before_Hit"] = JY.Person[WAR.Person[nyft]["人物编号"]]["生命"]	
			JY.Person[WAR.Person[nyft]["人物编号"]]["生命"] = JY.Person[WAR.Person[nyft]["人物编号"]]["生命"] - h
			if JY.Person[WAR.Person[nyft]["人物编号"]]["生命"] < 1 then
				JY.Person[WAR.Person[nyft]["人物编号"]]["生命"] = 1
			end
				
			Set_Eff_Text(enemyid, "特效文字3", "乾坤大挪移·反弹")
				  
			--张无忌，可以反弹两个人
			if (match_ID(eid, 9) or Curr_NG(eid,106)or match_ID(eid, 9990)) and nyft ~= nyft2 then
				WAR.Person[nyft2]["生命点数"] = (WAR.Person[nyft2]["生命点数"] or 0) - h;
				--无酒不欢：记录人物血量
				WAR.Person[nyft2]["Life_Before_Hit"] = JY.Person[WAR.Person[nyft2]["人物编号"]]["生命"]	
				JY.Person[WAR.Person[nyft2]["人物编号"]]["生命"] = JY.Person[WAR.Person[nyft2]["人物编号"]]["生命"] - h;
				if JY.Person[WAR.Person[nyft2]["人物编号"]]["生命"] < 1 then
					JY.Person[WAR.Person[nyft2]["人物编号"]]["生命"] = 1
				end
				WAR.Person[enemyid]["特效文字3"] = WAR.Person[enemyid]["特效文字3"] .. "·双"
				SetWarMap(WAR.Person[nyft2]["坐标X"], WAR.Person[nyft2]["坐标Y"], 4, 2);	--反弹者标识为被命中
			end
		end
			
	end
	


	hurt2 = limitX (math.modf(math.random(20) + math.modf(true_WL / 10)),math.random(20)+50)

	--防止武功保底大于基础伤害
	if hurt2 > hurt3 then 
		hurt2 = hurt3
	end

	if hurt > 300 then
		local hn = 0
		local hm = 0
		hn,hm = math.modf((hurt-200)/100) -- 衰减数量
		hurt = 300
		while hn > 0 do
			local r = math.random(8,10)
			local r1 = r/100
			local sj = limitX(1-(hn*r1),0,1) --衰减倍数
			if hm > 0 then
			hurt =  hurt + hm*100*sj
			hm = 0
			else 
			hurt = hurt + 100*sj
			end
			hn = hn-1
		end
	end

	--如果伤害一小于伤害二，则采用伤害二继续计算
	if hurt < hurt2 then
		hurt = hurt2
	end

	---------------------------------------------------------------------------
	--///////////////////////////加减法计算////////////////////////////////////
	---------------------------------------------------------------------------
	--阿九强制伤害
	if WAR.FGPZ[eid]~= nil then  
		hurt =  hurt - 30
	end 
	--伤害强制为50 装备天书
	if eid == 0 and JY.Person[eid]["武器"] == 312 and hurt > 50 then
		hurt = 50
	end	
	
  	--萧秋水 土掩
	if (match_ID(eid, 652) or Curr_NG(eid,177)) and JLSD(0, 35, eid) and JY.Base["天书数量"] > 3 and hurt > 32 then
		hurt = hurt - 32
		WAR.Person[enemyid]["特效动画"] = 63
		Set_Eff_Text(enemyid, "特效文字3", "土掩")
	end
	

	
	-- 司空摘星 相由心生 math.modf(WAR.fthurt + Rnd(10))
	if match_ID(eid,579) and eid == 0 and JLSD(15, 35+JY.Base["天书数量"],eid) and hurt > 0 then
		hurt = math.modf(WAR.WS + Rnd(10))
		Set_Eff_Text(enemyid, "特效文字0", "千变.相由心生")
		WAR.Person[enemyid]["特效动画"] = 102
	end 
	
	--毒王每5点中毒程度减伤1%
	if eid == 0 and JY.Base["标准"] == 9 then
		hurt = hurt - JY.Person[eid]["中毒程度"] / 2
	end
	

	if WAR.LYSH == 3 then
			--32%几率变两仪守护·极
		if JLSD(30,62,eid) and hurt > 32 then 
			hurt = hurt - 64
            ang = ang - 640
			WAR.Person[enemyid]["特效动画"] = 21
			Set_Eff_Text(enemyid, "特效文字1", "两仪守护·极")
		else  
			hurt = hurt - 32
			WAR.Person[enemyid]["特效动画"] = 21
			Set_Eff_Text(enemyid, "特效文字1", "两仪守护")
	   end
	end
    
    WAR.LYSH = 0
	--九字真言 不动根本印
	if WAR.PD["临"][eid]~= nil and WAR.PD["临"][eid] == 1 and hurt > 50 then 
		hurt = hurt - 50
		Set_Eff_Text(enemyid, "特效文字1", "不动根本印")
	end

	--陆渐 雀母相减伤50点
	if match_ID(eid,497) and JLSD(20, 50, eid) and JY.Base["天书数量"] > 2 and WAR.SSESS[eid] ~= nil and hurt > 50 then
		hurt = hurt - 50
		Set_Eff_Text(enemyid, "特效文字1", "雀母相")
	end
		
	--九阳神功
	if WAR.PD['氤氲紫气'][eid] == 1 and hurt > 99 then
		if hurt > 199 then
			hurt = hurt - 99
		else
			hurt = hurt - 66
	    end
    end
		--软猬甲减伤20点，被拳指系武功攻击，会给攻击方强制上10点流血
	--闪避不会触发软猬甲
	if JY.Person[eid]["防具"] == 58 and hurt > 0 and DWPD() then
		local hurt_reduction = 20 + 2 * (JY.Thing[58]["装备等级"]-1)
		hurt = hurt - hurt_reduction
		--触发软猬甲之后至少留1血
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
	--扫地不动如山
	if hurt > 30 then
	   if match_ID(eid,9963) and JLSD(10,35,eid)  then
		Set_Eff_Text(enemyid, "特效文字0", "立地成佛")
		WAR.Person[enemyid]['护盾'] = 4
		WAR.PD["立地成佛"][eid] = (WAR.PD["立地成佛"][eid] or 0) + hurt/2			   		
	   elseif match_ID(eid,9971) and JLSD(10,35,eid) then
			hurt = 30
			WAR.Person[enemyid]["特效动画"] = 6
			Set_Eff_Text(enemyid, "特效文字0", "不动如山")
		end
	end	
   if match_ID(eid,9963) and WAR.PD["立地成佛"][eid] ~= nil and WAR.PD["立地成佛"][eid] > 0 then
	    if hurt < WAR.PD["立地成佛"][eid] then	 
		   WAR.PD["立地成佛"][eid] = WAR.PD["立地成佛"][eid] - hurt
		   hurt = 0
	    else
	      hurt = hurt - WAR.PD["立地成佛"][eid]
	      WAR.PD["立地成佛"][eid] = nil
	      WAR.Person[enemyid]['护盾'] = nil
		end     
	end	
    if JY.Person[eid]["坐骑"] == 312 and hurt > 30 then
		hurt = 30
	end	
---------------------------------------------------------------------------
-----------------------------真实伤害-------------------------------------
---------------------------------------------------------------------------
	--解牛刀法
    if 	wugong == 193 and (WAR.Person[enemyid].Time >= -200 and WAR.Person[enemyid].Time <= 200) and DWPD() then
		if JY.Person[eid]["生命"]/JY.Person[eid]["生命最大值"] < 0.1 and math.random(100) <= 30 then
			hurt = hurt + JY.Person[eid]["生命"]			
		end
	end
 
	--黯然销魂掌 
	if wugong == 25 and match_ID(pid,58) and DWPD() then
		local jl = (1- JY.Person[eid]["生命"]/JY.Person[eid]["生命最大值"])*30
		if JY.Person[eid]["生命"] < JY.Person[eid]["生命最大值"]/2 and  math.random(100) <= jl then
			hurt = hurt + JY.Person[eid]["生命"]
			
		end
	end
	
	--须弥山神掌 
	if wugong == 24 and DWPD() then
		local jl = (1- JY.Person[eid]["生命"]/JY.Person[eid]["生命最大值"])*30
		if JY.Person[eid]["生命"] < JY.Person[eid]["生命最大值"]/10 and math.random(100) <= jl then
			hurt = hurt + JY.Person[eid]["生命"]
			WAR.PD["如来神掌"][pid] = 2
		end
	end	
	

---------------------------------------------------------------------------
-----------------------------闪避清除伤害-------------------------------------
---------------------------------------------------------------------------
	if WAR.Miss[eid] == 1 then 
		hurt = 0
	end

---------------------------------------------------------------------------
-----------------------------无视一切降低伤害-------------------------------------
---------------------------------------------------------------------------
	--韦小宝机敏无双，开场前50时序，受伤害不超过50
	if match_ID(eid, 601) and WAR.SXTJ <= 50 and hurt > 50 then
		hurt = math.random(40,50)
		WAR.Person[enemyid]["特效动画"] = 90
		Set_Eff_Text(enemyid, "特效文字1", "机敏无双")
	end
	
	--一灯复活后，不受连击伤害
	if match_ID(eid, 65) and DWPD() and WAR.FUHUOZT[eid] ~= nil and WAR.ACT > 1 and hurt > 0 then
		hurt = 0
		WAR.Person[enemyid]["特效动画"] = 136
		Set_Eff_Text(enemyid, "特效文字2", "不动明王")
	end
	
	 --文泰来 否极泰来 
    if match_ID(eid,151) and WAR.WTL_1[eid] == 0 and hurt >  JY.Person[eid]["生命"] then
		WAR.WTL_PJTL[eid] = 10
	end 
	
	--文泰来否极泰来 	
    if  WAR.WTL_PJTL[eid] ~= nil then	        
	    WAR.Person[enemyid]["特效文字0"] = nil
		WAR.Person[enemyid]["特效文字1"] = nil
		WAR.Person[enemyid]["特效文字2"] = nil
		WAR.Person[enemyid]["特效文字3"] = nil
		WAR.Person[enemyid]["特效文字4"] = nil
		WAR.Person[enemyid]["特效动画"] = nil
	    hurt = 0
		WAR.Person[enemyid]["特效动画"] = 157
		Set_Eff_Text(enemyid, "特效文字1", "否极泰来")
    end	
	 
	--霸体状态
	if  WAR.BTZT[eid] ~= nil then		
	    hurt = 0
	    WAR.Person[enemyid]["特效文字0"] = nil
		WAR.Person[enemyid]["特效文字1"] = nil
		WAR.Person[enemyid]["特效文字2"] = nil
		WAR.Person[enemyid]["特效文字3"] = nil
		WAR.Person[enemyid]["特效文字4"] = nil
		WAR.Person[enemyid]["特效动画"] = nil		
	    WAR.Person[enemyid]["特效动画"] = 118
	    Set_Eff_Text(enemyid, "特效文字1", "霸体")
	end	
	
	--斗酒僧不受连击伤害
	if match_ID(eid, 9966) and WAR.ACT > 1 then
		hurt = 0
	end
	
        --天佛降世
	if match_ID(eid,9986) and WAR.FUHUOZT[eid] ~= nil and WAR.BJ == 1 and hurt > 0 then
        hurt = 0
	end		
        
	--四大山，杂鱼不死不受伤害
	if eid == 642 then
		local s = 0
		for j = 0, WAR.PersonNum - 1 do
			if j ~= enemyid and WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[enemyid]["我方"] then
				s = 1
				break
			end
		end
		if s == 1 then
			hurt = 0
			Set_Eff_Text(enemyid, "特效文字1", "星河真气·免疫伤害")
		end
	end
	
		--无酒不欢：八荒六合功
	if ((PersonKF(eid, 101) and JLSD(40, 60, eid)) or (Curr_NG(eid, 101) and JLSD(20, 80, eid)) or WAR.NGHT == 101) and DWPD() and hurt > 0 then
		local reduction = math.modf(hurt * 0.333)
		hurt = hurt - reduction
		WAR.Person[enemyid]["内力点数"] = (WAR.Person[enemyid]["内力点数"] or 0)+reduction
		AddPersonAttrib(eid, "内力", reduction)
		local bhwz;
		if math.random(2) == 1 then
			bhwz = "八荒六合.唯我独尊"
		else
			bhwz = "唯我独尊.八荒六合"
		end
		Set_Eff_Text(enemyid, "特效文字3", bhwz)
	end
	
     --不老长春功
	if (Curr_NG(eid,183) or match_ID(eid,634)) and hurt > 0 and DWPD() and JLSD(10,50,eid) then
		WAR.Person[enemyid]["特效动画"] = 79
		Set_Eff_Text(enemyid, "特效文字1", "长春不老")
		if  JY.Person[eid]["内力"] < 0 then
		elseif hurt*2 < JY.Person[eid]["内力"] then
			WAR.Person[enemyid]["内力点数"] = (WAR.Person[enemyid]["内力点数"] or 0) + AddPersonAttrib(eid, "内力",-math.modf(hurt*2));
	        hurt = 0
	    else
	        hurt = hurt - math.modf(JY.Person[eid]["内力"]/2)
	        WAR.Person[enemyid]["内力点数"] = (WAR.Person[enemyid]["内力点数"]or 0) + AddPersonAttrib(eid,"内力",-JY.Person[eid]["内力"])
	    end
    end
	--先天罡气
	if Curr_NG(eid,100) and WAR.PD["先天护盾"][eid] ~=nil and WAR.PD["先天护盾"][eid] > 0 then
		WAR.Person[enemyid]["特效动画"] = 79
		Set_Eff_Text(enemyid, "特效文字1", "罡气护体")	
          if hurt < WAR.PD["先天护盾"][eid] then	 
			 WAR.PD["先天护盾"][eid] = WAR.PD["先天护盾"][eid] - hurt
			 hurt = 0
	      else
            hurt = hurt - WAR.PD["先天护盾"][eid]
			WAR.PD["先天护盾"][eid] = nil
		    WAR.Person[enemyid]['护盾'] = nil
	      end
    end
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
	----------------------------------------------------------------
	------------------------被打回血前，清空伤害，防止伤害小0--------------------------------
	hurt = limitX(math.modf(hurt),0)
	----------------------------------------------------------------
	------------------------被打回血前，清空伤害，防止伤害小0--------------------------------

	WAR.ZQHT = 0
	
  
	--九剑真传，倒剑式强制杀集气
	if WAR.JJZC == 2 and DWPD() then
		WAR.Person[enemyid].TimeAdd = WAR.Person[enemyid].TimeAdd - 150
	end


	--萧秋水 云翳
	if (match_ID(pid, 652) or Curr_NG(pid,177)) and JLSD(0, 35, pid) and JY.Base["天书数量"] > 4 and DWPD() then
		WAR.Person[enemyid].TimeAdd = WAR.Person[enemyid].TimeAdd - 200
		WAR.Person[enemyid]["特效动画"] = 63
		Set_Eff_Text(enemyid, "特效文字3", "云翳")
	end
    
	--剑胆琴心，挨打增加御剑
	if JiandanQX(eid) and DWPD() then
		local max_bonus = 420 - JY.Person[eid]["御剑能力"]
		if WAR.JDYJ[eid] == nil then
			WAR.JDYJ[eid] = 0
		end
		if WAR.JDYJ[eid] < max_bonus then
			WAR.JDYJ[eid] = WAR.JDYJ[eid] + math.modf(hurt/20)
			WAR.Person[enemyid]["特效动画"] = 125
			Set_Eff_Text(enemyid,"特效文字3","剑胆琴心")
			if WAR.JDYJ[eid] > max_bonus then
				WAR.JDYJ[eid] = max_bonus
			end
		end
	end
	
	--王重阳1 同归剑法
	if WAR.TGJF[pid] ~= nil and DWPD() and MyFj(WAR.CurID)== false then	
	    local selfhurt = math.modf(hurt * 1)
		JY.Person[pid]["生命"] = JY.Person[pid]["生命"] - math.modf(selfhurt)
		WAR.Person[WAR.CurID]["生命点数"] = (WAR.Person[WAR.CurID]["生命点数"] or 0)-math.modf(selfhurt)
		CurIDTXDH(WAR.CurID, 63,2, "天地同寿", C_ORANGE)
		if JY.Person[pid]["生命"] < 1 then
			JY.Person[pid]["生命"] = 1
		end
	end

	--赵敏反震
	if match_ID(eid, 609) and DWPD() and hurt > 10 and MyFj(WAR.CurID)== false then
		WAR.Person[enemyid]["特效动画"] = 144
		SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 4, 2)
		--无酒不欢：记录人物血量
		WAR.Person[WAR.CurID]["Life_Before_Hit"] = JY.Person[pid]["生命"]
		local selfhurt = math.modf(hurt * 0.3)
		JY.Person[pid]["生命"] = JY.Person[pid]["生命"] - math.modf(selfhurt)
		WAR.Person[WAR.CurID]["生命点数"] = (WAR.Person[WAR.CurID]["生命点数"] or 0)-math.modf(selfhurt)
		if JY.Person[pid]["生命"] < 1 then
			JY.Person[pid]["生命"] = 1
		end
	end
	
	--斗酒僧
	if match_ID(eid,638) and DWPD() and hurt > 10 and MyFj(WAR.CurID) == false then
		WAR.Person[enemyid]["特效动画"] = 88
		Set_Eff_Text(enemyid, "特效文字0", "九阳神功·反震")
		SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 4, 2)
		--无酒不欢：记录人物血量
		WAR.Person[WAR.CurID]["Life_Before_Hit"] = JY.Person[pid]["生命"]
		local selfhurt = math.modf(hurt * 0.4)
		JY.Person[pid]["生命"] = JY.Person[pid]["生命"] - math.modf(selfhurt)
		WAR.Person[WAR.CurID]["生命点数"] = (WAR.Person[WAR.CurID]["生命点数"] or 0)-math.modf(selfhurt)
		if JY.Person[pid]["生命"] < 1 then
			JY.Person[pid]["生命"] = 1
		end
	end	

	--死亡
	if JY.Person[pid]["生命"] < 0 then
		JY.Person[pid]["生命"] = 0
	end
  
	--误伤打到自己人
	if WAR.Person[WAR.CurID]["我方"] == WAR.Person[enemyid]["我方"] then
		--我方
		if WAR.Person[WAR.CurID]["我方"] then
			--水笙误伤加血
			if match_ID(pid, 589) then
				hurt = -(math.modf(hurt) + Rnd(3))
			--其他人误伤30%
			else
				hurt = math.modf(hurt * 0.3) + Rnd(3)
			end
		--NPC，误伤=20%
		else
			--倾国反弹100%
			if WAR.NZQK == 3 then
			
			--触发逆转乾坤，NPC误伤提高至50%
			elseif WAR.NZQK == 0 then
				hurt = math.modf(hurt * 0.2) + Rnd(3)
			else
				hurt = math.modf(hurt * 0.5) + Rnd(3)
			end
		end
	end

		   
	--无酒不欢：伤害的结算到此为止，扣除被攻击方血量
	if hurt > 1999 then
		hurt = 1999
	end
	
	--狄云赤心连城追加连击
	if match_ID(pid, 37) and hurt < 150 and DWPD()  then
		WAR.CXLC = 1
	end

	--林平之觉醒后，根据伤害回气
	if match_ID_awakened(pid, 36, 1) then
		WAR.LPZ = hurt/2
		if WAR.LPZ > 400 then
			WAR.LPZ = 400
		end
	end
	
	--石破天觉醒后，有30%几率挨打回血
	if (match_ID_awakened(eid, 38, 1) or Curr_NG(eid,102) and (JY.Person[191]["品德"] == 60 or not inteam(eid))) and DWPD() and math.random(10) < 3 then
		hurt = -math.modf(hurt/2)
		WAR.Person[enemyid]["特效文字2"] = "混沦太玄"
		WAR.Person[enemyid]["特效动画"] = 147
	end		
	
	if WAR.ZDDH == 356 and WAR.PD['天关阵4'][eid] == 5 then 
		hurt = -hurt
		WAR.Person[enemyid]["特效动画"] = 6
		Set_Eff_Text(enemyid, "特效文字0", "徐如林")
	end
		
	--防止伤害出现小数字
	hurt = math.modf(hurt)
  
	--扣血公式
	JY.Person[eid]["生命"] = JY.Person[eid]["生命"] - hurt
	
	if JY.Person[eid]["生命"] > JY.Person[eid]["生命最大值"] then
		JY.Person[eid]["生命"] = JY.Person[eid]["生命最大值"]
	end
	

	--太极蓄力
	if Curr_NG(eid,171) then
		if WAR.PD["太极蓄力"][eid] == nil or WAR.PD["太极蓄力"][eid] == 0 then
			WAR.PD["太极蓄力"][eid] = 0
		end
		if match_ID(eid,5) then
            WAR.PD["太极蓄力"][eid] = 50 + math.modf(WAR.PD["太极蓄力"][eid] + hurt*1.2);
		else
            WAR.PD["太极蓄力"][eid] = 50 + WAR.PD["太极蓄力"][eid] + hurt;
		end
		--上限1080
		if WAR.PD["太极蓄力"][eid] > 980 then
			WAR.PD["太极蓄力"][eid] = 980
			
		end
	end

		--梁萧 鲸息功蓄力
	if Curr_NG(eid, 180) then
		--蓄力机制
		if WAR.PD["鲸息蓄力"][eid] == nil or WAR.PD["鲸息蓄力"][eid] == 0 then
			WAR.PD["鲸息蓄力"][eid] = 50+hurt;
		else
			WAR.PD["鲸息蓄力"][eid] = WAR.PD["鲸息蓄力"][eid] + hurt;
		end
				--上限1080
		if WAR.PD["鲸息蓄力"][eid] > 1080 then
			WAR.PD["鲸息蓄力"][eid] = 1080
		end
	end	
	--获取得经验
	WAR.Person[WAR.CurID]["经验"] = WAR.Person[WAR.CurID]["经验"] + math.modf((hurt) / 5)
	
	--装备获取经验
	if WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[enemyid]["我方"] and WAR.ZDDH ~= 226 then
		--武器获取经验
		if JY.Person[pid]["武器"] ~= - 1 then
			JY.Thing[JY.Person[pid]["武器"]]["装备经验"] = JY.Thing[JY.Person[pid]["武器"]]["装备经验"] + 5
			if JY.Thing[JY.Person[pid]["武器"]]["装备经验"] > 100 and JY.Thing[JY.Person[pid]["武器"]]["装备等级"] < 6 then
				JY.Thing[JY.Person[pid]["武器"]]["装备经验"] = 0
				JY.Thing[JY.Person[pid]["武器"]]["装备等级"] = JY.Thing[JY.Person[pid]["武器"]]["装备等级"] + 1
			end
		end
		--防具获取经验
		if JY.Person[eid]["防具"] ~= - 1 then
			JY.Thing[JY.Person[eid]["防具"]]["装备经验"] = JY.Thing[JY.Person[eid]["防具"]]["装备经验"] + 5
			if JY.Thing[JY.Person[eid]["防具"]]["装备经验"] > 100 and JY.Thing[JY.Person[eid]["防具"]]["装备等级"] < 6 then
				JY.Thing[JY.Person[eid]["防具"]]["装备经验"] = 0
				JY.Thing[JY.Person[eid]["防具"]]["装备等级"] = JY.Thing[JY.Person[eid]["防具"]]["装备等级"] + 1
			end
		end
		--坐骑获取经验
		if JY.Person[eid]["坐骑"] ~= - 1 then
			JY.Thing[JY.Person[eid]["坐骑"]]["装备经验"] = JY.Thing[JY.Person[eid]["坐骑"]]["装备经验"] + 5
			if JY.Thing[JY.Person[eid]["坐骑"]]["装备经验"] > 100 and JY.Thing[JY.Person[eid]["坐骑"]]["装备等级"] < 6 then
				JY.Thing[JY.Person[eid]["坐骑"]]["装备经验"] = 0
				JY.Thing[JY.Person[eid]["坐骑"]]["装备等级"] = JY.Thing[JY.Person[eid]["坐骑"]]["装备等级"] + 1
			end
		end		
	end
	
	--七宝琉璃
	if WAR.QBLL == 1 then
		dng = dng/2
    end	
    
	--计算是否破气防，dng为0表示被破气防
	ang = ang - dng
	if 0 < ang then
		dng = 0
	else
		dng = -ang
		ang = 0
	end
	
	--东方不败，岳云精忠报国 葵花秘法·化凤为凰免疫杀气
	if (match_ID(eid, 27) or match_ID(eid,568)) and WAR.LQZ[eid] == 100 then
		dng = 1
	end	
	--白毫相
	if match_ID(eid, 497) and JLSD(20,70) and JY.Base["天书数量"] > 1  then
		Set_Eff_Text(enemyid,"特效文字1","白毫相");
	   --WAR.Person[enemyid]["特效文字1"] = "白毫相"
		WAR.Person[enemyid]["特效动画"] = 144
		dng = 1
	end	
	
	--扫地  免杀气
	if match_ID(eid, 114) then
		WAR.Person[enemyid]["特效文字2"] = "天地独尊"
		WAR.Person[enemyid]["特效动画"] = 39
		dng = 1
	end
	--达摩 免杀气
	if match_ID(eid, 577) then
		dng = 1
	end	
	--易筋真谛  免杀气
	if Curr_NG(eid, 108) and JLSD(30,70,eid) then
		Set_Eff_Text(enemyid,"特效文字1","易筋真谛");
		WAR.Person[enemyid]["特效动画"] = 39
		dng = 1
	end
	
	--狄云
	if match_ID(eid, 37) and Curr_NG(eid, 94) then
		Set_Eff_Text(enemyid,"特效文字1","真名神照");
		WAR.Person[enemyid]["特效动画"] = 89
		dng = 1
	end
	
	--盖世无双，50%几率免内伤，免杀气
	for i = 1, JY.Base["武功数量"] do
		if (JY.Person[eid]["武功" .. i] == 26 or JY.Person[eid]["武功" .. i] == 80) and JY.Person[eid]["武功等级" .. i] == 999 then
			WAR.GSWS = WAR.GSWS + 1
		end
	end
    
	if WAR.GSWS == 2 then
	   if Curr_NG(eid,204) or JLSD(20, 70, eid) then 	
	      dng = 1
		  WAR.Person[enemyid]["特效动画"] = 10
		  Set_Eff_Text(enemyid,"特效文字1","盖世无双")
	   end
    end
    
    if WAR.PD['西瓜刀·天人'][eid] ~= nil then 
        dng = 1
        Set_Eff_Text(enemyid,"特效文字1","天人合一")
    end
    
	WAR.GSWS = 0
  
	--伤害小于等于30 免内伤，免杀气 
	if hurt <= 30 then
		dng = 1
	end
	 --悲天佛怜 
	if match_ID(eid, 9983) and JY.Person[eid]["生命"] < JY.Person[eid]["生命最大值"]/2 then
		dng = 1
	end   
	--真太奥免疫杀气
	if WAR.TJAY == 4 then
		dng = 1
	end
    
	WAR.TJAY = 0
    
	--伤害小于等于30 免内伤，免杀气 
	if hurt <= 30  then
		dng = 1
	end  
    
	--刀系大招，忽视绝对气防
	if WAR.ASKD == 1 then
		dng = 0
	end
    
    if WAR.PD['侵如火'][pid] == 1 then 
        dng = 0
    end
	
	if WAR.ZDDH == 356 and WAR.PD['天关阵4'][pid] == 50 then 
		dng = 0
		--WAR.Person[enemyid]["特效动画"] = 6
		--Set_Eff_Text(enemyid, "特效文字0", "疾如风")
	end
		
	--排云掌
	if WAR.BJYPYZ > 9 then
		dng = 0
	end
	--天罡大招，忽视绝对气防
	if WAR.JSTG == 1 then
		dng = 0
	end

	--绣花针，忽视绝对气防 
	if WAR.PD["绣花针"][pid] ~= nil and WAR.PD["绣花针"][pid] > 0 then
		dng = 0
	end	
	--破尽天下，忽视绝对气防
	if WAR.PJTX == 1 then
		dng = 0
	end
	--陆渐大金刚神力，忽视绝对气防
	if WAR.JGSL == 1 then
		dng = 0
	end
	--青莲剑歌绝技，忽视绝对气防
	if WAR.QLJG == 1 then
		dng = 0
	end
	--忽视绝对气防
	if WAR.SL23 == 1 then
		dng = 0
	end	
	--五岳剑法+五岳剑诀，忽视绝对气防
	if WAR.ZWYJF == 1 then
		dng = 0
	end
	if WAR.JMZL == 2 then
	    dng = 0
	end
     if  WAR.DSP_LM1 == 1	then
	    dng = 0
	end	
	--龙象之力暴怒，忽视绝对气防
	if WAR.LXZL10 == 1 then
		dng = 0
	end				
	--李文秀14书，特效忽视绝对气防
	if WAR.LWX == 1 then
		dng = 0
	end
	--梅花三弄3
	if WAR.MHSN == 3  then
	dng = 0
  end	
	--郭靖降龙后劲超过11道，忽视绝对气防
	if WAR.YYBJ > 11 then
		dng = 0
	end
	--鲸息功 陷空力
    if WAR.BHJTZ6 == 1 then
       dng = 0
    end	    
	
	--太玄之轻40%几率
	if Curr_NG(eid, 102) and JLSD(20, 60, eid)  then
		WAR.TXZQ[eid] = 1
	end

	--陆渐60%几率 大自在相 
	if match_ID(eid, 497) and JLSD(20, 80, eid) and JY.Base["天书数量"] > 3 and WAR.SSESS[eid] ~= nil  then
		WAR.DZZ[eid] = 1
	end	

	--逍遥御风累积9点，未行动前不会被杀气
	if WAR.XYYF[eid] and WAR.XYYF[eid] == 11 then
		dng = 1
	end

	
	--破气防后内伤计算
	--除却四相免疫内伤
	--毒王大招不破气防也上内伤  	
	if (dng == 0 or WAR.YTML == 1) and hurt > 0 and DWPD() and myns(enemyid) == false then
		local n = 0;		--内伤点数值
		if inteam(eid) then		--队友内伤计算
			n = (hurt) / 10
		else
			n = (hurt) / 16
		end
		
		--张召重攻击，内伤加倍
		if match_ID(pid, 80) then
			n = n * 2
		end
	   
		--主运先天，逆运，蛤蟆，内伤-30%
		if Curr_NG(eid, 100) or Curr_NG(eid, 104) or Curr_NG(eid, 95) then
			n = n*0.7
		end
		
		--主运乾坤，罗汉，内伤-60%
		if Curr_NG(eid, 97) or Curr_NG(eid, 96) then
			n = n*0.4
		end
		
		--装备乌蚕衣，1级内伤-5，6级内伤-10
		if JY.Person[eid]["防具"] == 59 then
			n = n - 5 - 1*(JY.Thing[59]["装备等级"]-1)
		end

		n= math.modf(n)
		
    	WAR.Person[enemyid]["内伤点数"] = (WAR.Person[enemyid]["内伤点数"] or 0) + AddPersonAttrib(eid, "受伤程度", n);
	end

	--破防杀集气计算
	if dng == 0 and hurt > 0 and DWPD() then
		local killsq = 1

		
		local killjq = 0
        
		killjq = math.modf(ang / 15)

		--受伤害额外杀集气
		local spdhurt = 0
        
        local nd = JY.Base['难度']
        
        if inteam(pid) == false then
            spdhurt = spdhurt + (nd-1)*hurt*0.15
        end
        
		if WAR.ZDDH == 356 and WAR.PD['天关阵4'][pid] == 50 then 
			spdhurt = spdhurt + 200
		end
		
		--雷动九天追加伤害杀气
		if WAR.LDJT == 1 and DWPD() then
		   spdhurt = spdhurt + math.modf(hurt * 0.6)
		end
		
		--龙象减少杀气
		if PersonKF(eid, 103) then
			spdhurt = math.modf(spdhurt * 0.5)
		end

		--如果学了八荒不受伤害杀集气
		if Curr_NG(eid, 101) then
			spdhurt = 0
		elseif PersonKF(eid, 101) then
			spdhurt = math.modf(spdhurt * 0.5)
		end
	
        killjq = killjq + spdhurt

        if WAR.PD['西瓜刀'][pid] == 1 then 
            WAR.PD['回气'][pid] = (WAR.PD['回气'][pid] or 0) + killjq
        end
        
        if Curr_NG(eid, 227) and WAR.Defup[eid] ~= nil and WAR.Defup[eid] > 0 then
            if WAR.Person[enemyid].TimeAdd < 0 then
                WAR.Person[enemyid].TimeAdd = 0
            end
			if JLSD(0,35,eid) then
				WAR.Person[enemyid].TimeAdd = WAR.Person[enemyid].TimeAdd + 100
				Set_Eff_Text(enemyid,"特效文字1","伺机而动")
			end
        elseif match_ID(eid,9988) and JLSD(20,50,eid)  then
		   WAR.Person[WAR.CurID].TimeAdd = WAR.Person[WAR.CurID].TimeAdd - killjq*0.5					   
		--陆渐，被打加200集气
		elseif WAR.DZZ[eid] ~= nil and WAR.DZZ[eid] == 1 then
			WAR.Person[enemyid].TimeAdd = WAR.Person[enemyid].TimeAdd + 200
			Set_Eff_Text(enemyid,"特效文字1","大自在相")		
		--太玄之轻，把被杀的集气转为自己的集气值
		elseif WAR.TXZQ[eid] ~= nil and WAR.TXZQ[eid] == 1 then
			WAR.Person[enemyid].TimeAdd = WAR.Person[enemyid].TimeAdd + killjq
			Set_Eff_Text(enemyid,"特效文字1","太玄之轻")
        else
            WAR.Person[enemyid].TimeAdd = WAR.Person[enemyid].TimeAdd - killjq	
        end	 
	
		--太极+柔云，以柔克刚，50%几率将被杀气转化为回血
		if YiRouKG(eid) and JLSD(20, 70, eid) then
			local heal = math.modf(killjq/3)
			WAR.Person[enemyid]["生命点数"] = (WAR.Person[enemyid]["生命点数"] or 0) + AddPersonAttrib(eid, "生命", heal)
			Set_Eff_Text(enemyid,"特效文字1","太极道·以柔克刚")
			WAR.Person[enemyid]["特效动画"] = 21
		end
		if WAR.ZDDH == 356 and WAR.PD['天关阵4'][eid] == 27 then 
			if WAR.Person[enemyid].TimeAdd < 0 then 
				WAR.Person[enemyid].TimeAdd = 0
			end
			WAR.Person[enemyid].TimeAdd = WAR.Person[enemyid].TimeAdd + 300
			WAR.Person[enemyid]["特效动画"] = 6
			Set_Eff_Text(enemyid, "特效文字0", "疾如风")
		end
	end
  
	--小龙女死掉，杨过吼
	if match_ID(eid, 59) and JY.Person[eid]["生命"] <= 0 then
		WAR.XK = 1
		WAR.XK2 = WAR.Person[enemyid]["我方"]
	end 

    
    --张家辉的麻痹戒指
	if JY.Person[pid]["防具"] == 301 and DWPD() then
		local mb = 1
		if JY.Thing[301]["装备等级"] >=5 then
			mb = 3
		elseif JY.Thing[301]["装备等级"] >=3 then
			mb = 2
		end
		WAR.MBJZ[eid] = mb
	end

	
	--无酒不欢：优化钟灵闪电貂偷东西
	if WAR.TD == -2  and DWPD() then
		for i = 1, 4 do
			if 0 < JY.Person[eid]["携带物品数量" .. i] and -1 < JY.Person[eid]["携带物品" .. i] then
				WAR.TD = JY.Person[eid]["携带物品" .. i]
				WAR.TDnum = JY.Person[eid]["携带物品数量" .. i]
				JY.Person[eid]["携带物品数量" .. i] = 0
				JY.Person[eid]["携带物品" .. i] = -1
				break
			end
		end
	else
		WAR.TD = -1
	end

	--血刀吸血，1级5%，3级6%，5级7%
	--上限100点
	
	if JY.Person[pid]["武器"] == 44 then
		local bs = 0
		if JY.Thing[44]["装备等级"] >= 5 then
			bs = 2
		elseif JY.Thing[44]["装备等级"] >= 3 then
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
	--天魔功吸血20%
	if Curr_NG(pid, 160)  then
		WAR.TMGLeech = WAR.TMGLeech + math.modf(hurt * 0.2)
	end	
	--血河，10%吸血
	if PersonKF(pid, 163) then
		if WAR.XHSJ < 100 then
			WAR.XHSJ = WAR.XHSJ + limitX(math.modf(hurt * 0.1),0,100)
			if WAR.XHSJ > 100 then
				WAR.XHSJ = 100
			end
		end
	end
	
	--韦一笑吸血10%，上限100点
	if match_ID(pid, 14) then
		if WAR.WYXLeech < 100 then
			WAR.WYXLeech = WAR.WYXLeech + limitX(math.modf((hurt) * 0.1),0,100)
			if WAR.WYXLeech > 100 then
				WAR.WYXLeech = 100
			end
		end
	end


	--天山童姥 被攻击后生命+80
	if match_ID(eid, 117) and 0 < JY.Person[eid]["生命"] then
		WAR.Person[enemyid]["生命点数"] = (WAR.Person[enemyid]["生命点数"] or 0) + AddPersonAttrib(eid, "生命", 80);
	end


	--程英 杀内力
	if WAR.CY == 1 and DWPD() then
		WAR.Person[enemyid]["内力点数"] = (WAR.Person[enemyid]["内力点数"] or 0) + AddPersonAttrib(eid, "内力", -300);
	end
	-- 
	if WAR.PD["阵"][pid]~=nil and WAR.PD["阵"][pid]== 1 and DWPD() then
		WAR.Person[enemyid]["内力点数"] = (WAR.Person[enemyid]["内力点数"] or 0) + AddPersonAttrib(eid,"内力", -200)
   end
	--进阶万岳，杀内力
	if wugong == 33 and PersonKF(pid,175) then
		local neiliLoss = hurt
		WAR.Person[enemyid]["内力点数"] = (WAR.Person[enemyid]["内力点数"] or 0) + AddPersonAttrib(eid, "内力", -neiliLoss);
	end

	--阎基偷钱
	if eid ~= 591 and match_ID(pid, 4) and JY.Person[eid]["生命"] <= 0 and inteam(pid) and DWPD() then
		WAR.YJ = WAR.YJ + math.random(15) + 25
	end
	    
	--辟邪刺目，100%MISS
	if WAR.KHBX == 2 and 0 < hurt and DWPD() then
       WAR.KHCM[eid] = 2
	end
  
    if WAR.PD['野球拳'][pid] == 2 and 0 < hurt and DWPD() and math.random(100) <= 40 then
       WAR.KHCM[eid] = 2
	end

	--拳主大招，高几率封穴
	if WAR.LXZQ == 1 and JLSD(25, 75, pid) and DWPD() then
		WAR.BFX = 1
	end
	if match_ID(pid,613) and wugong == 206 and JLSD(10,60,pid) and DWPD() then
       WAR.BFX = 1
	end	
	--琴棋书画之倚天屠龙功，必封穴
	if WAR.QQSH3 == 1 and DWPD() then
		WAR.BFX = 1
	end
	
	--奇门主角大招，必封穴
	if WAR.GCTJ == 1 and DWPD() then
		WAR.BFX = 1
	end
	
	--一阳指50%几率封穴，优先判定
	if wugong == 17 and JLSD(30,80,pid) and DWPD() then
		WAR.BFX = 1
	end
	
	--拳法指法45%几率封穴
	if (WGLX == 1 or WGLX == 2) and JLSD(30, 75, pid) and DWPD() then
		WAR.BFX = 1
	end
    
    if wugong == 226 then 
        WAR.BFX = 1
    end
    
	--七宝指环
	if JY.Person[pid]["武器"] == 200 and JY.Thing[200]["装备等级"] == 6 and DWPD() then
		WAR.BFX = 1
	end			
	--毒王大招必封穴
	if WAR.YTML == 1 then
		WAR.BFX = 1
	end	
	--梁萧星罗散手必封穴
	if match_ID(pid,635) and JY.Wugong[wugong]["武功类型"] == 2 and DWPD() then
		WAR.BFX = 1
	end	
	--岳云岳王散手必封穴
	if match_ID(pid,568) and wugong == 198 and DWPD() then
		WAR.BFX = 1
    end
    
    --穴袖拂穴必封穴
	if wugong == 201 and DWPD() then
        WAR.BFX = 1
	end
	
    if WAR.PD['戳字决'][pid] == 1 and DWPD() then 
        WAR.BFX = 1
    end
    
	--指法主角，初始15%封穴率，每个指法+5%
	if JY.Base["标准"] == 2 and pid == 0 and DWPD() then
		local lxyz = 15
		for i = 1, JY.Base["武功数量"] do
			if JY.Wugong[JY.Person[0]["武功" .. i]]["武功类型"] == 2 and JY.Person[0]["武功等级" .. i] == 999 then
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

	
	--伤害小于50无封穴，拳法指法额外封穴，一阳指高封穴，其他30%几率封穴
	--除却四相免疫封穴
	if DWPD() and 50 <= hurt and (WAR.BFX == 1 or JLSD(30, 60, pid)) and myfx(enemyid) == false then
		--无酒不欢：使用分段函数
		local fxz = 1;
		if hurt >= 50 and hurt < 100 then
			fxz = fxz + math.modf((hurt - 50)/10)
		elseif hurt >= 100 and hurt <= 200 then
			fxz = math.modf((hurt - 50)/10) + math.random(3)
		elseif hurt > 200 then
			fxz = math.modf(hurt/15) + 5 + math.random(3)
		end
		--封穴调整
		if inteam(pid) then
			fxz = math.modf(fxz *0.4)
		else
			fxz = math.modf(fxz *0.6)
		end
        
		if match_ID(pid, 511) then 
			fxz = fxz + 10
		end
		
        if WAR.PD['戳字决'][pid] == 1 then 
            fxz = fxz + 10
        end
		--主运混元，造成的封穴效果提高20%
		--萧半和
		if Curr_NG(pid, 90) or match_ID(pid,189) then
			fxz = math.modf(fxz *1.2)
		--被动混元，造成的封穴效果提高10%
		elseif PersonKF(pid, 90) then
			fxz = math.modf(fxz *1.1)
		end
		--公孙止受封穴减半
		if match_ID(eid, 616) then
			fxz = math.modf(fxz *0.5)
		end
		--圣火受封穴减半
		if Curr_NG(eid, 93) then
			fxz = math.modf(fxz *0.5)
		end

		--乾坤受封穴减半
		if Curr_NG(eid, 97) then
			fxz = math.modf(fxz *0.5)
		end
			   
        if PersonKF(eid, 190) then
			fxz = math.modf(fxz *0.5)
		end
		--一苇渡江
		if Curr_QG(eid,186) then
		    fxz = math.modf(fxz *0.5)
		end
		--装备金丝背心，1级封穴-5，6级封穴-10
		if JY.Person[eid]["防具"] == 60 then
			fxz = fxz - 5 - 1*(JY.Thing[60]["装备等级"]-1)
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
			--玩家和NPC一样待遇
			if WAR.FXDS[eid] == nil then
				WAR.FXDS[eid] = fxz
			else
				WAR.FXDS[eid] = WAR.FXDS[eid] + fxz
			end
			WAR.FXXS[eid] = 1
			--封穴上限50点
			if 50 < WAR.FXDS[eid] then
				WAR.FXDS[eid] = 50
			end
		end
	end
    
	if match_ID(eid, 511) and DWPD() and myfx(WAR.CurID) == false then
		WAR.FXDS[pid] = limitX((WAR.FXDS[pid] or 0) + 10,0,50)
		WAR.FXXS[pid] = 1
	end
		
    if WAR.PD['野球拳'][pid] == 2 and 0 < hurt and DWPD() and myfx(enemyid) == false then
        local lx = WAR.LXZT[eid] or 0
        if lx >= 25 then 
			WAR.LXXS[eid] = nil
            WAR.FXDS[eid] = limitX((WAR.FXDS[eid] or 0) + lx,0,50)
            WAR.LXZT[eid] = nil
            WAR.FXXS[eid] = 1
            Set_Eff_Text(enemyid,"特效文字1","逆血封穴")
        end    
	end
    
	WAR.BFX = 0
	
	--for g = 1, 9 do
	--	if match_ID(pid, glxp[g]) and JLSD(30, 70, pid) then
	--		WAR.BLX = 1
	--	end
	--end
	  
	--倚天剑，必流血
	--1级70%几率流血
	--4级开始追加灼烧
	if JY.Person[pid]["武器"] == 37 then
		if JLSD(0, 40 + JY.Thing[37]["装备等级"] * 10, pid) then
			WAR.BLX = 1
		end
	end
	--狼牙，必流血
	--1级70%几率流血
	if JY.Person[pid]["武器"] == 320 then
		if JLSD(0, 40 + JY.Thing[320]["装备等级"] * 10, pid) then
			WAR.BLX = 1
		end
	end	
	--田归农装备闯王军刀，必流血
	if JY.Person[pid]["武器"] == 202 and match_ID(pid, 72) then
		WAR.BLX = 1
	end
	--陆无双，必流血
	if  match_ID(pid, 580) then
		WAR.BLX = 1
	end	
	--钟灵必流血
	if match_ID(pid, 90) then
		WAR.BLX = 1
	end
	
	--剑法刀法45%几率流血
	if (WGLX == 3 or WGLX == 4) and JLSD(30, 75, pid) then
		WAR.BLX = 1
	end
	
	--沧溟刀法特效，必流血
	if WAR.CMDF == 1 then
		WAR.BLX = 1
	end
	
	--主运血河神鉴，必流血
	if Curr_NG(pid, 163) then
		WAR.BLX = 1
	end
	
	--毒王大招必流血
	if WAR.YTML == 1 then
		WAR.BLX = 1
	end
	--龙爪手必流血
	if wugong == 20 and DWPD() then
	   WAR.BLX = 1
	end  
	--凝血神爪必流血
	if wugong == 134 and DWPD() then
		WAR.BLX = 1
    end
    -- 血战八方
 	if WAR.XZBF == 1 and DWPD() then
	   WAR.BLX = 1
	end
	--绣花针必流血
    if JY.Person[pid]["武器"] == 349  then   
       WAR.BLX = 1
	end
    if WAR.PD['野球拳'][pid] == 2 then
       WAR.BLX = 1
	end
	--装备倚天剑，屠龙刀第一种特效，奇门标主大招，必流血，其他30%几率流血
	--防御方带6级金丝免疫流血  不老长春功
	if hurt > 30 and DWPD() and (JY.Person[eid]["武器"] == 239 and JY.Thing[239]["装备等级"] == 6) == false 
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
	
	--冰封计算 
    -- 阴内九阴必冰封
	if JY.Wugong[wugong]["冰封系数"] == 1 and ((PersonKF(pid, 107) and (JY.Person[pid]["内力性质"] == 0 or JY.Person[pid]["内力性质"] == 3)) or JLSD(10,90,pid)) then
		WAR.BBF = 1
	end
	-- 寒冰真气 必冰封
	if PersonKF(pid,216) or match_ID(pid,9978) then
		WAR.BBF = 1
    end	
	--林朝英流风回雪
	if WAR.LFHX == 1 then
		WAR.BBF = 1
	end
	
	--琴棋书画的妙笔丹青特效
	if WAR.QQSH2 >= 1 then
		WAR.BBF = 1
	end
	
	--玉箫剑法配合桃花绝技60%冰封
	if wugong == 38 and TaohuaJJ(pid) and JLSD(20,80,pid) then
		WAR.BBF = 1
	end
	
	--左冷禅，李四，高几率冰封
	if (match_ID(pid, 22) or match_ID(pid, 42)) and JLSD(10,90,pid) then
		WAR.BBF = 1
	end
	--胡一刀攻击冰封
	if match_ID(pid,633) and JY.Person[pid]["武器"] == 45 then
		WAR.BBF = 1
	end		
	--毒王大招必冰封
	if WAR.YTML == 1 then
		WAR.BBF = 1
	end
	--白绣必冰封
	if match_ID(pid,582) then
		WAR.BBF = 1
	end	
    --阴阳流2	
	if WAR.BHJTZ1== 1 then
		WAR.BBF = 1
	end		

	--灼烧计算
	--阳内九阳必灼烧
	if JY.Wugong[wugong]["灼烧系数"] == 1 and ((PersonKF(pid, 106) and ( JY.Person[pid]["内力性质"] == 1 or JY.Person[pid]["内力性质"] == 3)) or JLSD(10,90,pid)) then
		WAR.BZS = 1
	end
	--圣火明尊
	if match_ID(pid,9992) or wugong == 93 then
		WAR.BZS = 1
    end
    if WAR.PD['火延'][pid] == 1 then 
        WAR.BZS = 1
    end
	--苗人凤，天门，张三，高几率灼烧
	if (match_ID(pid, 3) or match_ID(pid, 23) or match_ID(pid, 41)) and JLSD(10,90,pid) then
		WAR.BZS = 1
	end
	
	--毒王大招必灼烧
	if WAR.YTML == 1 then
		WAR.BZS = 1
	end
    -- 六脉大招1 天山六阳掌
    if WAR.DSP_LM2 == 1 or wugong == 8 then
      	WAR.BZS = 1
	end
	--林殊必灼烧
	if match_ID(pid,508) then
		WAR.BZS = 1
    end
	--寇仲必灼烧
	if match_ID(pid,578) and  JY.Person[pid]["内力性质"] == 1 then
		WAR.BZS = 1
	end	
	--九字真言 在
	if WAR.PD["在"][pid] ~= nil and WAR.PD["在"][pid] == 1 then
	  WAR.BZS = 1
    end
    --阴阳流1	
	if WAR.BHJTZ1== 1 then
        WAR.BZS = 1
	end	
	
    -- 丁当
 	if match_ID(pid,581) then
		WAR.BZS = 1
	end   	

    --长生
    if WAR.BZS == 1 and PersonKF(pid, 203) then
        WAR.BBF = 1
    elseif WAR.BBF == 1 and PersonKF(pid, 203) then
        WAR.BZS = 1
    end
    
	--除却四相免疫灼烧
	if hurt > 30 and DWPD() and WAR.BZS == 1 and myzs(enemyid) == false then
		local zsz = math.modf(hurt / 15)
		--if zsz > 20 then
			--zsz = 20
	    --end
	--装备佛心甲，1级灼烧-50%，6级免疫灼烧
		if JY.Person[eid]["防具"] == 62 then
			local kz = 0.5 + 0.1 * (JY.Thing[62]["装备等级"]-1)
			zsz = math.modf(zsz *(1-kz))
		end
	
	--玉女被动，灼烧-50%
		if PersonKF(eid, 154) then
			zsz = math.modf(zsz / 2)
		end
		if zsz > 0 then
			--JY.Person[eid]["灼烧程度"] = JY.Person[eid]["灼烧程度"] + zsz
			AddPersonAttrib(eid,'灼烧程度',zsz)
			WAR.ZSXS[eid] = 1
			--if 100 < JY.Person[eid]["灼烧程度"] then
			--	JY.Person[eid]["灼烧程度"] = 100
			--end
		end
	end
	
	WAR.BZS = 0

	--除却四相 寒冰真气 免疫冰封
	if hurt > 30 and DWPD() and WAR.BBF == 1 and mybf(enemyid) == false then
		local bfz = math.modf(hurt / 15)
		--琴棋书画的妙笔丹青特效江山如画
		if WAR.QQSH2 == 2 then
			bfz = bfz * 2
		end
		--装备皮衣，1级冰封-50%，6级免疫冰封
		if JY.Person[eid]["防具"] == 63 then
			local kh = 0.5 + 0.1 * (JY.Thing[63]["装备等级"]-1)
			bfz = math.modf(bfz *(1-kh))
		end
		
		--纯阳被动，冰封-50%
		if PersonKF(eid, 99) then
			bfz = math.modf(bfz / 2)
		end
		if bfz > 0 then
			--JY.Person[eid]["冰封程度"] = JY.Person[eid]["冰封程度"] + bfz
			AddPersonAttrib(eid,'冰封程度',bfz)
			WAR.BFXS[eid] = 1
			--if 100 < JY.Person[eid]["冰封程度"] then
			--	JY.Person[eid]["冰封程度"] = 100
			--end
		end
	end
	
	WAR.BBF = 0
    
	--先天罡气清蓄力
	if WAR.PD["先天罡气"][pid]~= nil  then
		if WAR.PD["太极蓄力"][eid] ~= nil and  WAR.PD["太极蓄力"][eid] > 0 then
			 WAR.PD["太极蓄力"][eid]  =  nil
		end
		if WAR.PD["鲸息蓄力"][eid] ~= nil and  WAR.PD["鲸息蓄力"][eid] > 0 then
			 WAR.PD["鲸息蓄力"][eid]  =  nil
		end
		if WAR.PD["蛤蟆蓄力"][eid] ~= nil and  WAR.PD["蛤蟆蓄力"][eid] > 0 then
			 WAR.PD["蛤蟆蓄力"][eid]  =  nil
		end	      
    end
	
	--怒气值计算，斗转星移不加怒，指法大招不加怒
	if 0 < JY.Person[eid]["生命"] and hurt > 0 and (WAR.LQZ[eid] == nil or WAR.LQZ[eid] < 100) and WAR.Person[enemyid]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.DZXY ~= 1 and WAR.LXYZ ~= 1 then
		local lqzj = math.modf((hurt) / 6 + 1)
		lqzj = math.random(lqzj, lqzj+10)
		
		--敌人难度下额外增加的怒气值
		if WAR.Person[enemyid]["我方"] == false then
			local flqzj = 0
			if JY.Base["难度"] == 1 then
				flqzj = 2
			elseif JY.Base["难度"] == 2 then
				flqzj = 5
			else
				flqzj = 8 + JY.Base["难度"]
			end
			lqzj = lqzj + flqzj;
		end
		
		if lqzj < 10 then 
			lqzj = 10 
		end	
        
		--逍遥游被击中破绽增加怒气值20
		if Curr_QG(eid,2) 	and WAR.Weakspot[eid] ~= nil and WAR.Person[enemyid].Time >= -200 and WAR.Person[enemyid].Time <= 200 then
			lqzj = lqzj+ 20
	    end
        
        if Curr_NG(pid, 102) then 
            lqzj = math.modf(lqzj/2)
        end
        
		--草木成佛
        if WAR.PD['西瓜刀'][pid] == 3 then
        --太玄之重，不加怒    
        elseif WAR.TXZZ == 1 then
		--琴棋书画之持瑶琴不加怒
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
	--王重阳在北斗七闪状态下不会被清怒
		if not (match_ID(eid, 129) and WAR.BDQS > 0) then
			--指法大招清一半怒
			if WAR.LXYZ == 1 and DWPD() and WAR.LQZ[eid] ~= nil then
				WAR.LQZ[eid] = math.modf(WAR.LQZ[eid] * 0.5)
			end
		end
        
		--怒气暴发
		if WAR.LQZ[eid] ~=  nil and 100 < WAR.LQZ[eid] then
			WAR.LQZ[eid] = 100
			--东方不败，葵花秘法·化凤为凰
			if match_ID(eid, 27) then
				WAR.Person[enemyid]["特效动画"] = 7
				Set_Eff_Text(enemyid,"特效文字1","葵花秘法·化凤为凰");
			else
				WAR.Person[enemyid]["特效动画"] = 6
				Set_Eff_Text(enemyid,"特效文字1","怒气爆发");
	        end	
        end		
        
    if WAR.PD['西瓜刀'][pid] == 3 then
        if WAR.LQZ[eid] == 100 then 
            WAR.HMZT[eid] = 1
        end
        if WAR.LQZ[eid] ~= nil then 
            WAR.LQZ[eid] = WAR.LQZ[eid] - 20
        end
    end
    
    --北冥吸怒，斗转不触发   
	if XiaoYaoYF(pid) and PersonKF(pid,85) and WAR.DZXY ~= 1 and WAR.LQZ[eid] ~= nil and DWPD() and JLSD(25, 40 + math.modf(JY.Person[pid]["实战"]/25), pid) then
		local lq = WAR.LQZ[eid] or 0
		if lq >= 10 then 
			WAR.BMSGXL = WAR.BMSGXL + 10
			WAR.LQZ[eid] = WAR.LQZ[eid] - 10
		else 
			WAR.BMSGXL = WAR.BMSGXL + lq
			WAR.LQZ[eid] = 0
		end
		Set_Eff_Text(enemyid,"特效文字1","北冥.气吞山河");
	end				
    
		--菩提清心清一半怒
	if WAR.QQSH1 == 2 and DWPD() and WAR.LQZ[eid] ~= nil then
		WAR.LQZ[eid] = math.modf(WAR.LQZ[eid] * 0.5)
	end
		
		--触发太玄之重时，敌方已经暴怒的话，则有几率清怒，
	if WAR.TXZZ == 1 and WAR.LQZ[eid] ~= nil and WAR.LQZ[eid] == 100  and JLSD(20,45+JY.Person[pid]["实战"]/20) then
		WAR.LQZ[eid] = WAR.LQZ[eid] - 20
		Set_Eff_Text(enemyid,"特效文字1","救赵挥金锤.邯郸先震惊");
	end
    
    --防止怒气小于0
    if WAR.LQZ[eid] ~= nil and WAR.LQZ[eid] < 0 then 
        WAR.LQZ[eid] = 0
    end
    
	if DWPD() and ZhongYongZD(eid) and WAR.LQZ[eid] == 100 then
		--if JLSD(20,40+JY.Base["天书数量"]*0.5,eid) or WAR.LQZ[eid] == 100 then
		WAR.Person[enemyid]["特效动画"] = 6
		Set_Eff_Text(enemyid, "特效文字0", "中庸之道")
        Cat('立刻出手',enemyid)
		WAR.ACT = 10
			--如果是由斗转触发的，则不打断左右
		--if WAR.DZXY == 0 then
		WAR.ZYHB = 0
		--end
	end	
    
	--成不忧 被令狐冲 秒杀
	if WAR.ZDDH == 205 and eid == 141 then
		WAR.Person[enemyid]["生命点数"] = -JY.Person[eid]["生命"];
		JY.Person[eid]["生命"] = 0
	end

	--丁敏君 被周芷若 秒杀
	if WAR.ZDDH == 279 and eid == 632 then
		WAR.Person[enemyid]["生命点数"] = -JY.Person[eid]["生命"];
		JY.Person[eid]["生命"] = 0
	end
  
	--铁掌，高机率造成内伤12~15点
	if wugong == 13 and JLSD(30, 90, pid) and DWPD() and myns(enemyid) == false then
		WAR.Person[enemyid]["内伤点数"] = (WAR.Person[enemyid]["内伤点数"] or 0) + AddPersonAttrib(eid, "受伤程度", math.random(12, 15));
	end
    
    if WAR.PD['野球拳'][pid] == 1 and myns(enemyid) == false then 
        WAR.Person[enemyid]["内伤点数"] = (WAR.Person[enemyid]["内伤点数"] or 0) + AddPersonAttrib(eid, "受伤程度", math.random(15, 20));
    end
    
	--萧半和混元一气
	if WAR.HYYQ == 1 and DWPD() and myns(enemyid) == false then 
		WAR.Person[enemyid]["内伤点数"] = (WAR.Person[enemyid]["内伤点数"] or 0) + AddPersonAttrib(eid, "受伤程度", math.random(10, 15));  
	end
    
	--伏魔禅杖造成内伤10~15点
	if JY.Person[pid]["武器"] == 323 and JY.Thing[323]["装备等级"] >= 2 and JLSD(0, 50+(JY.Thing[323]["装备等级"]-1)*10, pid) and DWPD() and myns(enemyid) == false then
		WAR.Person[enemyid]["内伤点数"] = (WAR.Person[enemyid]["内伤点数"] or 0) + AddPersonAttrib(eid, "受伤程度", math.random(10, 15));
	end	
    
	--玄澄 无量禅震 追加10-15点内伤
	if WAR.XC_WLCZ== 1 and DWPD() and myns(enemyid) == false then
        local ns = 10 + math.random(1, 5) 
        WAR.Person[enemyid]["内伤点数"] = (WAR.Person[enemyid]["内伤点数"] or 0) + AddPersonAttrib(eid, "受伤程度", ns);
	end
        
    if Curr_NG(eid, 227) and WAR.Defup[eid] ~= nil and WAR.Defup[eid] > 0 then
        WAR.Person[WAR.CurID]["内伤点数"] = (WAR.Person[WAR.CurID]["内伤点数"] or 0) + AddPersonAttrib(pid, "受伤程度", 15);
    end
    
	--七伤拳，机率造成内伤17点
	if WAR.YZQS == 1 and DWPD() and myns(enemyid) == false then
		local ns = 17
		--谢逊额外造成+7
		if match_ID(pid, 13) then
			ns = ns + 7
		end
		WAR.Person[enemyid]["内伤点数"] = (WAR.Person[enemyid]["内伤点数"] or 0) + AddPersonAttrib(eid, "受伤程度", ns);
		--当自己内力值低于5000时，会受到内伤
		if JY.Person[pid]["内力"] < 5000 then
			WAR.Person[WAR.CurID]["内伤点数"] = (WAR.Person[WAR.CurID]["内伤点数"] or 0) + AddPersonAttrib(pid, "受伤程度", 7);
		end
	end
    
	if (WAR.BMXH == 1 or WAR.BMXH == 2 ) and 0 < hurt and DWPD() then
		local xnl = nil
		xnl = math.modf(JY.Person[eid]["内力"] * 0.07)
		if xnl > 300 then
			xnl = 300
		end
		--方证不会被吸
		if match_ID(eid,149) then
			xnl = 0
		end
		WAR.Person[enemyid]["内力点数"] = (WAR.Person[enemyid]["内力点数"] or 0) + AddPersonAttrib(eid, "内力", -xnl);
		WAR.Person[WAR.CurID]["内力点数"] = (WAR.Person[WAR.CurID]["内力点数"] or 0) + AddPersonAttrib(pid, "内力", xnl)
		
        if isteam(pid) then
            AddPersonAttrib(pid, "内力最大值", xnl * 10)
        end    
		--畅想无崖子发动北冥时吸取属性
		if WAR.BMXH == 1 and match_ID(pid, 116) and pid == 0 then
			AddPersonAttrib(pid, "攻击力", 2)
			AddPersonAttrib(pid, "防御力", 2)
			AddPersonAttrib(pid, "轻功", 2)
		end
	end

     -- 逍遥子 梅花三弄2
	if WAR.MHSN == 2 and WAR.ACT == 1 and DWPD()then 
        local xnl = nil
        xnl = math.modf(JY.Person[eid]["内力"] * 0.05)
        --方证不会被吸
        if match_ID(eid,149) then
            xnl = 0
        end  
        WAR.Person[enemyid]["内力点数"] = AddPersonAttrib(eid, "内力", -xnl);
	end
    
	--化功大法 上毒 减内力
	if WAR.BMXH == 3 and 0 < hurt and DWPD() then
		local xnl = nil
		xnl = math.modf(JY.Person[eid]["内力"] * 0.05)
		if xnl < 100 then
			xnl = 100
		elseif xnl > 300 then
			xnl = 300
		end
		--方证不会被吸
		if match_ID(eid,149) then
			xnl = 0
		end
		WAR.Person[enemyid]["内力点数"] = AddPersonAttrib(eid, "内力", -xnl);
	end
  
	--吸星大法，一般人吸3-4体力
	if WAR.BMXH == 2 and 0 < hurt and DWPD() then
		local xt1 = 3 + Rnd(2)
		local n = AddPersonAttrib(eid, "体力", -xt1)
		local m = AddPersonAttrib(pid, "体力", xt1)
		
		--任我行 额外吸3体力
		if match_ID(pid, 26) then
			n = n + AddPersonAttrib(eid, "体力", -3)
			m = m + AddPersonAttrib(pid, "体力", 3)
		end

		WAR.Person[enemyid]["体力点数"] = (WAR.Person[enemyid]["体力点数"] or 0) + n;
		WAR.Person[WAR.CurID]["体力点数"] = (WAR.Person[WAR.CurID]["体力点数"] or 0) + m;
	end

	--主运北冥挨打也吸内
	if Curr_NG(eid, 85) and 0 < hurt and DWPD() and JLSD(20,70,eid) then
		local xnl = 200
		--方证不会被吸
		if match_ID(pid,149) then
			xnl = 0
		end
		WAR.Person[WAR.CurID]["内力点数"] = (WAR.Person[WAR.CurID]["内力点数"] or 0) + AddPersonAttrib(pid, "内力", -xnl)
		WAR.Person[enemyid]["内力点数"] = (WAR.Person[enemyid]["内力点数"] or 0) + AddPersonAttrib(eid, "内力", xnl)
		AddPersonAttrib(eid, "内力最大值", 2000)
		WAR.Person[enemyid]["特效动画"] = 63
		Set_Eff_Text(enemyid,"特效文字1","百川入海");
	end
	
	--主运吸星挨打也吸内
	if Curr_NG(eid, 88) and 0 < hurt and DWPD() and JLSD(20,70,eid) then
		local xnl = 200
		--方证不会被吸
		if match_ID(pid,149) then
			xnl = 0
		end
		WAR.Person[WAR.CurID]["内力点数"] = (WAR.Person[WAR.CurID]["内力点数"] or 0) + AddPersonAttrib(pid, "内力", -xnl)
		WAR.Person[enemyid]["内力点数"] = (WAR.Person[enemyid]["内力点数"] or 0) + AddPersonAttrib(eid, "内力", xnl/2)
		AddPersonAttrib(eid, "内力最大值", 1000)
		WAR.Person[enemyid]["特效动画"] = 71
		Set_Eff_Text(enemyid,"特效文字1","万物相吸");
	end
	
	--主运化功挨打也吸内+上毒
	if Curr_NG(eid, 87) and 0 < hurt and DWPD() and JLSD(20,70,eid) then
		local xnl = 200
		--方证不会被吸
		if match_ID(pid,149) then
			xnl = 0
		end
        WAR.Person[WAR.CurID]["中毒点数"] = AddPersonAttrib(pid, "中毒程度", math.random(10,15))
		WAR.Person[WAR.CurID]["内力点数"] = (WAR.Person[WAR.CurID]["内力点数"] or 0) + AddPersonAttrib(pid, "内力", -xnl)
		WAR.Person[enemyid]["特效动画"] = 64
		Set_Eff_Text(enemyid,"特效文字1","化功大法");
	end

        	
	--被虚竹生死符击中的
	if WAR.TZ_XZ == 1 and DWPD() then
		WAR.TZ_XZ_SSH[eid] = 1
	end
  
	if hurt > 0 and DWPD() then
		--中毒计算
		local poisonnum = math.modf(JY.Wugong[wugong]["敌人中毒点数"] + JY.Person[pid]["攻击带毒"])
        
		local kd = JY.Person[eid]["抗毒能力"] + JY.Person[eid]["内力"] / 50
        
        if WAR.PD['六阳正气'][eid] ~= nil then 
            kd = kd + WAR.PD['六阳正气'][eid]
        end
        
		--周芷若白骨爪无视敌人毒抗
		if match_ID(pid, 631) and wugong == 11 then
			kd = 0
		end
        
		poisonnum = math.modf((poisonnum - kd) / 4)
        
        --化功大法 上毒 减内力
        if WAR.BMXH == 3 then
            --WAR.Person[enemyid]["中毒点数"] = AddPersonAttrib(eid, "中毒程度", math.random(16,20))
            poisonnum = poisonnum + math.random(16,20)
        end

        --欧阳锋，攻击中毒+30
        if match_ID(pid, 60) then
            poisonnum = poisonnum + 30
            --WAR.Person[enemyid]["中毒点数"] = (WAR.Person[enemyid]["中毒点数"] or 0) + AddPersonAttrib(eid, "中毒程度", 30)
        end
	
        --西毒蛇杖
        if JY.Person[pid]["武器"] == 244 then
            local sz = 10 + 5 * (JY.Thing[244]["装备等级"]-1)
            poisonnum = poisonnum + sz
            --WAR.Person[enemyid]["中毒点数"] = (WAR.Person[enemyid]["中毒点数"] or 0) + AddPersonAttrib(eid, "中毒程度", sz)
        end
	
        --紫气天罗组合强制上毒
        if (wugong == 3 or wugong == 120 or wugong == 5 or wugong == 21 or wugong == 118) and ZiqiTL(pid) then
            poisonnum = poisonnum + math.random(20,30)
            --WAR.Person[enemyid]["中毒点数"] = (WAR.Person[enemyid]["中毒点数"] or 0) + AddPersonAttrib(eid, "中毒程度", math.random(20,30))
        end
	
        --赤练神掌，强制上毒20
        if WAR.WD_CLSZ == 1 then
            poisonnum = poisonnum + 20
            --WAR.Person[enemyid]["中毒点数"] = (WAR.Person[enemyid]["中毒点数"] or 0) + AddPersonAttrib(eid, "中毒程度", 20)
        end
        
        --五毒真经，强制上毒20
        if PersonKF(pid,220) then
            poisonnum = poisonnum + 30
            --WAR.Person[enemyid]["中毒点数"] = (WAR.Person[enemyid]["中毒点数"] or 0) + AddPersonAttrib(eid, "中毒程度", 30)
        end
	
        --田归农与阎基的加成，中毒+5 + 随机15
        if match_ID(pid, 72) then
            for j = 0, WAR.PersonNum - 1 do
                if match_ID(WAR.Person[j]["人物编号"],4) and WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[WAR.CurID]["我方"] then
                    poisonnum = poisonnum + 5 + math.random(15)
                    --WAR.Person[enemyid]["中毒点数"] = (WAR.Person[enemyid]["中毒点数"] or 0) + AddPersonAttrib(eid, "中毒程度", 5 + math.random(15));
                    break
                end
            end
        end
        
		if poisonnum < 0 then
			poisonnum = 0
		end
        
		if myzd(enemyid) == false then
			WAR.Person[enemyid]["中毒点数"] = (WAR.Person[enemyid]["中毒点数"] or 0) + AddPersonAttrib(eid, "中毒程度", math.modf(myrnd(poisonnum)))
		end
	end
	
	--不知道干嘛的
	if eid == -1 then
		local x, y = nil, nil
		while true do
			x = math.random(63)
			y = math.random(63)
			if not SceneCanPass(x, y) or GetWarMap(x, y, 2) < 0 then
				SetWarMap(WAR.Person[enemyid]["坐标X"], WAR.Person[enemyid]["坐标Y"], 2, -1)
				SetWarMap(WAR.Person[enemyid]["坐标X"], WAR.Person[enemyid]["坐标Y"], 5, -1)
                SetWarMap(WAR.Person[enemyid]["坐标X"], WAR.Person[enemyid]["坐标Y"], 10, -1)
				WAR.Person[enemyid]["坐标X"] = x
				WAR.Person[enemyid]["坐标Y"] = y
				SetWarMap(WAR.Person[enemyid]["坐标X"], WAR.Person[enemyid]["坐标Y"], 2, enemyid)
				SetWarMap(WAR.Person[enemyid]["坐标X"], WAR.Person[enemyid]["坐标Y"], 5, WAR.Person[enemyid]["贴图"])
                SetWarMap(WAR.Person[enemyid]["坐标X"], WAR.Person[enemyid]["坐标Y"], 10, JY.Person[WAR.Person[enemyid]["人物编号"]]['头像代号'])
				break;
			end
		end
	end
  
	--判断是否可以加实战
	if JY.Person[eid]["生命"] <= 0 and inteam(pid) and DWPD() and WAR.SZJPYX[eid] == nil and JY.Person[pid]["实战"] < 500 then
		--崆峒派战斗、高升客栈杀欧阳克、家里练功房、全真教练功、青城派练功、少林练功   不加实战
		local wxzd = {17, 67, 226, 220, 224, 219, 79}
		local wx = 0
		for i = 1, 7 do
			if WAR.ZDDH == wxzd[i] then
				wx = 1
			end
		end
		
		--丐帮门口
		if WAR.ZDDH == 82 and GetS(10, 0, 18, 0) == 1 then
			wx = 1
		end
		--木人巷
		if WAR.ZDDH == 214 and GetS(10, 0, 19, 0) == 1 then
			wx = 1
		end
		
		--如果可加实战
		if wx == 0 and inteam(pid) then
			local szexp = 1
			if eid < 191 and 0 < eid then
				szexp = WARSZJY[eid]
			end
			JY.Person[pid]["实战"] = JY.Person[pid]["实战"] + szexp
			if JY.Person[pid]["实战"] > 500 then
				JY.Person[pid]["实战"] = 500
			end
			WAR.SZJPYX[eid] = 1
		end
	end
	
	--长生诀重生
	if JY.Person[eid]["生命"] <= 0 and PersonKF(eid, 203) and WAR.PD['复活·长生'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.Person[enemyid]["特效动画"] = 89
		WAR.Person[enemyid]["特效文字3"] = "长生起死回生"
		local modifier = 0.6+JY.Base["天书数量"]*0.01
		--狄云 寇仲
		if match_ID(eid, 37) or match_ID(eid, 578) then
			modifier = 1
		--主运长生
		elseif Curr_NG(eid, 203) then
			modifier = 1
		end
		JY.Person[eid]["生命"] = math.modf(JY.Person[eid]["生命最大值"]*modifier)
		JY.Person[eid]["内力"] = JY.Person[eid]["内力"] + math.modf((JY.Person[eid]["内力最大值"]-JY.Person[eid]["内力"])*modifier)
		JY.Person[eid]["体力"] = JY.Person[eid]["体力"] + math.modf((100 - JY.Person[eid]["体力"])*modifier)
		JY.Person[eid]["中毒程度"] = JY.Person[eid]["中毒程度"]-math.modf(JY.Person[eid]["中毒程度"]*modifier)
		JY.Person[eid]["受伤程度"] = JY.Person[eid]["受伤程度"]-math.modf(JY.Person[eid]["受伤程度"]*modifier)
		JY.Person[eid]["冰封程度"] = JY.Person[eid]["冰封程度"]-math.modf(JY.Person[eid]["冰封程度"]*modifier)
		JY.Person[eid]["灼烧程度"] = JY.Person[eid]["灼烧程度"]-math.modf(JY.Person[eid]["灼烧程度"]*modifier)
        if match_ID(eid, 129) then
            WAR.LQZ[eid] = 100
            --畅想主角的七闪数量随天书增加，NPC固定为7
            if eid == 0 then
                WAR.BDQS = math.modf(JY.Base["天书数量"]/2)
            else
                WAR.BDQS = 7
            end
            
            WAR.Person[enemyid]["特效动画"] = 115
            WAR.Person[enemyid]["特效文字3"] = "重阳再现 论剑形态"
            
        end
		--流血
		if WAR.LXZT[eid] ~= nil then
			WAR.LXZT[eid] = WAR.LXZT[eid]-math.modf(WAR.LXZT[eid]*modifier)
			if WAR.LXZT[eid] < 1 then
				WAR.LXZT[eid] = nil
				WAR.LXXS[eid] = nil
			end
		end
		--封穴
		if WAR.FXDS[eid] ~= nil then
			WAR.FXDS[eid] = WAR.FXDS[eid]-math.modf(WAR.FXDS[eid]*modifier)
			if WAR.FXDS[eid] < 1 then
				WAR.FXDS[eid] = nil
				WAR.FXXS[eid] = nil
			end
		end				
		WAR.Person[enemyid].Time = WAR.Person[enemyid].Time + 500
		WAR.FUHUOZT[eid] = 1
        WAR.PD['复活·长生'][eid] = 1
		--狄云 寇仲
		if match_ID(eid, 37) or match_ID(eid, 578) then
			WAR.Person[enemyid].Time = 990
		end
		if WAR.Person[enemyid].Time > 990 then
			WAR.Person[enemyid].Time = 990
		end
		--10%的几率二次复活
		--if math.random(100) > 10 then		
		--WAR.PD["复活状态"][eid] = 1
		--end
	end	
	
	
	--神照重生
	if JY.Person[eid]["生命"] <= 0 and PersonKF(eid, 94) and WAR.PD['复活·神照'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.Person[enemyid]["特效动画"] = 89
		WAR.Person[enemyid]["特效文字3"] = "神照功起死回生"
		local modifier = 0.35+JY.Base["天书数量"]*0.01
		--狄云
		if match_ID(eid, 37) then
			modifier = 1
		--主运神照
		elseif Curr_NG(eid, 94) then
			modifier = 0.7+JY.Base["天书数量"]*0.02
		end
		JY.Person[eid]["生命"] = math.modf(JY.Person[eid]["生命最大值"]*modifier)
		JY.Person[eid]["内力"] = JY.Person[eid]["内力"] + math.modf((JY.Person[eid]["内力最大值"]-JY.Person[eid]["内力"])*modifier)
		JY.Person[eid]["体力"] = JY.Person[eid]["体力"] + math.modf((100 - JY.Person[eid]["体力"])*modifier)
		JY.Person[eid]["中毒程度"] = JY.Person[eid]["中毒程度"]-math.modf(JY.Person[eid]["中毒程度"]*modifier)
		JY.Person[eid]["受伤程度"] = JY.Person[eid]["受伤程度"]-math.modf(JY.Person[eid]["受伤程度"]*modifier)
		JY.Person[eid]["冰封程度"] = JY.Person[eid]["冰封程度"]-math.modf(JY.Person[eid]["冰封程度"]*modifier)
		JY.Person[eid]["灼烧程度"] = JY.Person[eid]["灼烧程度"]-math.modf(JY.Person[eid]["灼烧程度"]*modifier)
        if match_ID(eid, 129) then
            WAR.LQZ[eid] = 100
            --畅想主角的七闪数量随天书增加，NPC固定为7
            if eid == 0 then
                WAR.BDQS = math.modf(JY.Base["天书数量"]/2)
            else
                WAR.BDQS = 7
            end
            
            WAR.Person[enemyid]["特效动画"] = 115
            WAR.Person[enemyid]["特效文字3"] = "重阳再现 论剑形态"
            
        end
		--流血
		if WAR.LXZT[eid] ~= nil then
			WAR.LXZT[eid] = WAR.LXZT[eid]-math.modf(WAR.LXZT[eid]*modifier)
			if WAR.LXZT[eid] < 1 then
				WAR.LXZT[eid] = nil
				WAR.LXXS[eid] = nil
			end
		end
		--封穴
		if WAR.FXDS[eid] ~= nil then
			WAR.FXDS[eid] = WAR.FXDS[eid]-math.modf(WAR.FXDS[eid]*modifier)
			if WAR.FXDS[eid] < 1 then
				WAR.FXDS[eid] = nil
				WAR.FXXS[eid] = nil
			end
		end				
		WAR.Person[enemyid].Time = WAR.Person[enemyid].Time + 500
		WAR.FUHUOZT[eid] = 1
        --WAR.PD['复活·神照'][eid] = 1
		--狄云
		if match_ID(eid, 37) then
			WAR.Person[enemyid].Time = 990
		end
		if WAR.Person[enemyid].Time > 990 then
			WAR.Person[enemyid].Time = 990
		end
		--6%的几率二次复活
		if math.random(100) > 6 then		
		--	WAR.PD["复活状态"][eid] = 1
            WAR.PD['复活·神照'][eid] = 1
		end
	end
    
 	--天佛降世
	if JY.Person[eid]["生命"] <= 0 and match_ID(eid, 9986) and WAR.PD['复活·天佛'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.Person[enemyid]["特效动画"] = 19
		WAR.Person[enemyid]["特效文字3"] = "天佛降世 起死回生"
		WAR.PD['复活·天佛'][eid] = 1
		JY.Person[eid]["生命"] = JY.Person[eid]["生命最大值"] * 0.7
		JY.Person[eid]["内力"] = JY.Person[eid]["内力"] + (JY.Person[eid]["内力最大值"] - JY.Person[eid]["内力"])* 0.5
		JY.Person[eid]["体力"] = JY.Person[eid]["体力"] + (100 - JY.Person[eid]["体力"])* 0.5
		JY.Person[eid]["中毒程度"] = JY.Person[eid]["中毒程度"] * 0.5
		JY.Person[eid]["受伤程度"] = JY.Person[eid]["受伤程度"] * 0.5
        
        if match_ID(eid, 129) then
            WAR.LQZ[eid] = 100
            --畅想主角的七闪数量随天书增加，NPC固定为7
            if eid == 0 then
                WAR.BDQS = math.modf(JY.Base["天书数量"]/2)
            else
                WAR.BDQS = 7
            end
            
            WAR.Person[enemyid]["特效动画"] = 115
            WAR.Person[enemyid]["特效文字3"] = "重阳再现 论剑形态"
            
        end
        
		WAR.Person[enemyid].Time = 980
		WAR.FUHUOZT[eid] = 1
	end 
    
	--一灯，复活
	if JY.Person[eid]["生命"] <= 0 and match_ID(eid, 65) and WAR.PD['复活·一灯'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.Person[enemyid]["特效动画"] = 19
		WAR.Person[enemyid]["特效文字3"] = "先天一阳 起死回生"
		WAR.PD['复活·一灯'][eid] = 1
		JY.Person[eid]["生命"] = JY.Person[eid]["生命最大值"] * 0.7
		JY.Person[eid]["内力"] = JY.Person[eid]["内力"] + (JY.Person[eid]["内力最大值"] - JY.Person[eid]["内力"])* 0.5
		JY.Person[eid]["体力"] = JY.Person[eid]["体力"] + (100 - JY.Person[eid]["体力"])* 0.5
		JY.Person[eid]["中毒程度"] = JY.Person[eid]["中毒程度"] * 0.5
		JY.Person[eid]["受伤程度"] = JY.Person[eid]["受伤程度"] * 0.5
		WAR.Person[enemyid].Time = 980
        WAR.FUHUOZT[eid] = 1
	end
    
	--萧秋水，天意复活 
	if JY.Person[eid]["生命"] <= 0 and (match_ID(eid, 652) or Curr_NG(eid,177)) and JY.Base["天书数量"] > 0 and WAR.PD['复活·天意'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.Person[enemyid]["特效动画"] = 19
		WAR.Person[enemyid]["特效文字3"] = "长歌正气 武穆移魂"
		--WAR.WQTS_TY = WAR.WQTS_TY + 1
        WAR.PD['复活·天意'][eid] = 1
		JY.Person[eid]["生命"] = JY.Person[eid]["生命最大值"] * 0.8
		JY.Person[eid]["内力"] = JY.Person[eid]["内力"] + (JY.Person[eid]["内力最大值"] - JY.Person[eid]["内力"])* 0.5
		JY.Person[eid]["体力"] = JY.Person[eid]["体力"] + (100 - JY.Person[eid]["体力"])* 0.5
		JY.Person[eid]["中毒程度"] = JY.Person[eid]["中毒程度"] * 0.5
		JY.Person[eid]["受伤程度"] = JY.Person[eid]["受伤程度"] * 0.5
		WAR.Person[enemyid].Time = 980
		WAR.FUHUOZT[eid]=1
	end
        
	--阿九 复活
	if JY.Person[eid]["生命"] <= 0 and match_ID_awakened(eid, 629,1) and WAR.PD['复活·阿九'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.Person[enemyid]["特效动画"] = 154
		WAR.Person[enemyid]["特效文字3"] = "浴火重生"
		WAR.PD['复活·阿九'][eid] = 1
		JY.Person[eid]["生命"] = JY.Person[eid]["生命最大值"] * 0.8
		JY.Person[eid]["内力"] = JY.Person[eid]["内力"] + (JY.Person[eid]["内力最大值"] - JY.Person[eid]["内力"])* 0.5
		JY.Person[eid]["体力"] = JY.Person[eid]["体力"] + (100 - JY.Person[eid]["体力"])* 0.5
		JY.Person[eid]["中毒程度"] = JY.Person[eid]["中毒程度"] * 0.5
		JY.Person[eid]["受伤程度"] = JY.Person[eid]["受伤程度"] * 0.5
		WAR.Person[enemyid].Time = 980
        WAR.FUHUOZT[eid]=1
	end	
    
	--王重阳，复活
	if JY.Person[eid]["生命"] <= 0 and match_ID(eid, 129) and WAR.PD['复活·王重阳'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.LQZ[eid] = 100
		--畅想主角的七闪数量随天书增加，NPC固定为7
		if eid == 0 then
			WAR.BDQS = math.modf(JY.Base["天书数量"]/2)
		else
			WAR.BDQS = 7
		end
		WAR.Person[enemyid]["特效动画"] = 115
		WAR.Person[enemyid]["特效文字3"] = "重阳再现 论剑形态"
		WAR.PD['复活·王重阳'][eid] = 1
		JY.Person[eid]["生命"] = JY.Person[eid]["生命最大值"] * 0.7
		JY.Person[eid]["内力"] = JY.Person[eid]["内力"] + (JY.Person[eid]["内力最大值"] - JY.Person[eid]["内力"])* 0.5
		JY.Person[eid]["体力"] = JY.Person[eid]["体力"] + (100 - JY.Person[eid]["体力"])* 0.5
		JY.Person[eid]["中毒程度"] = JY.Person[eid]["中毒程度"] * 0.5
		JY.Person[eid]["受伤程度"] = JY.Person[eid]["受伤程度"] * 0.5
		WAR.Person[enemyid].Time = 980
		WAR.FUHUOZT[eid]=1
	end

	
	--戚长发，复活
	if JY.Person[eid]["生命"] <= 0 and match_ID(eid, 594) and WAR.QCF < 1 and WAR.PD['复活·戚长发'][eid] == nil and WAR.FUHUOZT[eid] < 1 then
		WAR.Person[enemyid]["特效动画"] = 19
		WAR.Person[enemyid]["特效文字3"] = "闭气离墙 起死回生"
		WAR.PD['复活·戚长发'][eid] = 1
		JY.Person[eid]["生命"] = JY.Person[eid]["生命最大值"] * 0.7
		JY.Person[eid]["内力"] = JY.Person[eid]["内力"] + (JY.Person[eid]["内力最大值"] - JY.Person[eid]["内力"])* 0.5
		JY.Person[eid]["体力"] = JY.Person[eid]["体力"] + (100 - JY.Person[eid]["体力"])* 0.5
		JY.Person[eid]["中毒程度"] = JY.Person[eid]["中毒程度"] * 0.5
		JY.Person[eid]["受伤程度"] = JY.Person[eid]["受伤程度"] * 0.5
		WAR.Person[enemyid].Time = 980
		WAR.FUHUOZT[eid]=1
	end
  
	--薛慕华 复活一个人
	if JY.Person[eid]["生命"] <= 0 and WAR.PD['复活·戚长发'][eid] == 0 and WAR.FUHUOZT[eid] < 1 then
		for i = 0, WAR.PersonNum - 1 do
			if match_ID(WAR.Person[i]["人物编号"], 45) and WAR.Person[i]["死亡"] == false and WAR.Person[i]["我方"] == WAR.Person[enemyid]["我方"] then
				WAR.Person[enemyid]["特效动画"] = 89
				WAR.Person[enemyid]["特效文字3"] = "阎王敌 重生"
				JY.Person[eid]["生命"] = JY.Person[eid]["生命最大值"]
				JY.Person[eid]["内力"] = JY.Person[eid]["内力最大值"]
				JY.Person[eid]["中毒程度"] = 0
				JY.Person[eid]["受伤程度"] = 0
				JY.Person[eid]["冰封程度"] = 0
				JY.Person[eid]["灼烧程度"] = 0
				JY.Person[eid]["体力"] = 100
                
                if match_ID(eid, 129) then
                    WAR.LQZ[eid] = 100
                    --畅想主角的七闪数量随天书增加，NPC固定为7
                    if eid == 0 then
                        WAR.BDQS = math.modf(JY.Base["天书数量"]/2)
                    else
                        WAR.BDQS = 7
                    end
                    
                    WAR.Person[enemyid]["特效动画"] = 115
                    WAR.Person[enemyid]["特效文字3"] = "重阳再现 论剑形态"
                    
                end
                
				--流血
				if WAR.LXZT[eid] ~= nil then
					WAR.LXZT[eid] = nil
					WAR.LXXS[eid] = nil
				end
				--封穴
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
	
	--张家辉的复活戒指
	if JY.Person[eid]["生命"] <= 0 and JY.Person[eid]["防具"] == 303 then
		JY.Person[eid]["生命"] = JY.Person[eid]["生命最大值"]
		JY.Person[eid]["内力"] = JY.Person[eid]["内力最大值"]
		JY.Person[eid]["体力"] = 100
		JY.Person[eid]["中毒程度"] = 0
		JY.Person[eid]["受伤程度"] = 0
		JY.Person[eid]["冰封程度"] = 0
		JY.Person[eid]["灼烧程度"] = 0
		--流血
		if WAR.LXZT[eid] ~= nil then
			WAR.LXZT[eid] = nil
			WAR.LXXS[eid] = nil
		end
		--封穴
		if WAR.FXDS[eid] ~= nil then
			WAR.FXDS[eid] = nil
			WAR.FXXS[eid] = nil
		end
        if match_ID(eid, 129) then
            WAR.LQZ[eid] = 100
            --畅想主角的七闪数量随天书增加，NPC固定为7
            if eid == 0 then
                WAR.BDQS = math.modf(JY.Base["天书数量"]/2)
            else
                WAR.BDQS = 7
            end
            
            WAR.Person[enemyid]["特效动画"] = 115
            WAR.Person[enemyid]["特效文字3"] = "重阳再现 论剑形态"
            
        end
		WAR.Person[enemyid]["特效动画"] = 154
		WAR.Person[enemyid]["特效文字3"] = "复活戒指·重生"
		JY.Person[651]["品德"] = JY.Person[651]["品德"] - 1
		if JY.Person[651]["品德"] == 0 then
			JY.Person[eid]["防具"] = -1
			JY.Thing[303]["使用人"] = -1
			instruct_32(303,-1)
			WAR.FHJZ = 1
		end
	end
  
	--人物死亡
	if JY.Person[eid]["生命"] < 0 then
		JY.Person[eid]["生命"] = 0
		WAR.Person[WAR.CurID]["经验"] = WAR.Person[WAR.CurID]["经验"] + JY.Person[eid]["等级"] * 5
		WAR.Person[enemyid]["反击武功"] = -1		--如果被打死则不会触发反击
		if WAR.SZSD == eid then						--取消死战标记
			WAR.SZSD = -1
		end
	end
	
	--血刀老祖 杀死敌人后转化为己方
	if match_ID(pid, 97) and JY.Person[eid]["生命"] <= 0 and DWPD() and JLSD(0,50,eid) then
		WAR.Person[enemyid]["我方"] = WAR.Person[WAR.CurID]["我方"]
		JY.Person[eid]["生命"] = JY.Person[eid]["生命最大值"]
		JY.Person[eid]["内力"] = JY.Person[eid]["内力最大值"]
		JY.Person[eid]["中毒程度"] = 0
		JY.Person[eid]["受伤程度"] = 0
		JY.Person[eid]["冰封程度"] = 0
		JY.Person[eid]["灼烧程度"] = 0
		JY.Person[eid]["体力"] = 100
		WAR.FXXS[eid] = nil
		WAR.LXXS[eid] = nil
		WAR.FXDS[eid] = nil
		WAR.LXZT[eid] = nil
		WAR.XDLZ[eid] = 1
	end
  
	--平一指杀人
	if JY.Person[eid]["生命"] <= 0 and match_ID(pid, 28) and DWPD() then
		WAR.PYZ = WAR.PYZ + 1
		if 10 < WAR.PYZ then
			WAR.PYZ = 10
		end
	end
	
	--阿紫杀人
	if JY.Person[eid]["生命"] <= 0 and match_ID(pid, 47) and DWPD() then
		WAR.MZSH = WAR.MZSH + 1
	end


	--李白杀人
	if JY.Person[eid]["生命"] <= 0 and match_ID(pid, 636) and DWPD() then
		WAR.SBSYR = 1
	end
    
	--血战八方
    if JY.Person[pid]["耍刀技巧"] >= 300 and JY.Person[eid]["生命"] <= 0 and DWPD() then
	   WAR.XZBFZT[pid]  = (WAR.XZBFZT[pid] or 0)  + 1
	end   
    
	--无酒不欢：袁承志碧血长风
	--限主角
	if JY.Person[eid]["生命"] <= 0 and match_ID(pid, 54) and DWPD() then
		WAR.BXCF = 1
	end
	--紫气天罗，杀人引爆毒素
	if JY.Person[eid]["生命"] <= 0 and (wugong == 3 or wugong == 120 or wugong == 5 or wugong == 21 or wugong == 118) and ZiqiTL(pid) and DWPD() then
		local dam = math.modf((JY.Person[eid]["中毒程度"]/100)*(JY.Person[eid]["生命最大值"]/10))
		WAR.ZQTL = {dam, enemyid, WAR.Person[enemyid]["坐标X"], WAR.Person[enemyid]["坐标Y"]}
	end
	--实力升级
    if inteam(pid) and DWPD() and JY.Person[eid]["生命"] <= 0 then 
        while JY.Person[pid]["畅想分阶"] > JY.Person[eid]["畅想分阶"] do
              JY.Person[pid]["畅想分阶"] = JY.Person[pid]["畅想分阶"] - 1	
              if JY.Person[pid]["畅想分阶"] == 6 then
				 --CC.TX["弟子"] = 1
				 AddPersonAttrib(pid, "攻击力", 3)
			     AddPersonAttrib(pid, "防御力",3)
		         AddPersonAttrib(pid, "轻功", 3)
				--say( "我方"..JY.Person[pid]["姓名"].."升"..JY.Person[pid]["畅想分阶"].."阶",0,1)
			  end
			  if JY.Person[pid]["畅想分阶"] == 5 then
				 --CC.TX["三流"] = 1
			     AddPersonAttrib(pid, "拳掌功夫", 3)
			     AddPersonAttrib(pid, "指法技巧", 3)
			     AddPersonAttrib(pid, "御剑能力", 3)
			     AddPersonAttrib(pid, "耍刀技巧", 3)
			     AddPersonAttrib(pid, "特殊兵器", 3)
			--say( "我方"..JY.Person[pid]["姓名"].."升"..JY.Person[pid]["畅想分阶"].."阶",0,1)	
			  end
			  if JY.Person[pid]["畅想分阶"] == 4 then
				 --CC.TX["二流"] = 1
			     AddPersonAttrib(pid, "攻击力", 7)
			     AddPersonAttrib(pid, "防御力", 7)
			     AddPersonAttrib(pid, "轻功", 7)
			--say( "我方"..JY.Person[pid]["姓名"].."升"..JY.Person[pid]["畅想分阶"].."阶",0,1)	
			  end
			  if JY.Person[pid]["畅想分阶"] == 3 then
				 --CC.TX["一流"] = 1
          	     AddPersonAttrib(pid, "拳掌功夫", 7)
			     AddPersonAttrib(pid, "指法技巧", 7)
			     AddPersonAttrib(pid, "御剑能力", 7)
			     AddPersonAttrib(pid, "耍刀技巧", 7)
			     AddPersonAttrib(pid, "特殊兵器", 7)
			--say( "我方"..JY.Person[pid]["姓名"].."升"..JY.Person[pid]["畅想分阶"].."阶",0,1)	
			  end
			  if JY.Person[pid]["畅想分阶"] == 2 then
				 --CC.TX["豪侠"] = 1
                 AddPersonAttrib(pid, "攻击力",20)
			--say( "我方"..JY.Person[pid]["姓名"].."升"..JY.Person[pid]["畅想分阶"].."阶",0,1)	
			  end
			  if JY.Person[pid]["畅想分阶"] == 1 then
				 --CC.TX["宗师"] = 1
                 AddPersonAttrib(pid, "防御力", 20)
                 AddPersonAttrib(pid, "轻功", 20)
			--say( "我方"..JY.Person[pid]["姓名"].."升"..JY.Person[pid]["畅想分阶"].."阶",0,1)	
			  end
			  if JY.Person[pid]["畅想分阶"] == 0 then
				 --CC.TX["传说"] = 1
			     AddPersonAttrib(pid, "拳掌功夫",20)
			     AddPersonAttrib(pid, "指法技巧",20)
			     AddPersonAttrib(pid, "御剑能力",20)
			     AddPersonAttrib(pid, "耍刀技巧",20)
			     AddPersonAttrib(pid, "特殊兵器",20)
			--say( "我方"..JY.Person[pid]["姓名"].."升"..JY.Person[pid]["畅想分阶"].."阶",0,1)
			  end
		 end					   
    end


	--北冥神功和吸星大法，加内力上限

	  
	WAR.NGHT = 0	--内功护体
	WAR.CQSX = 0	--除却四相



	--if WAR.Person[enemyid]["特效文字2"] == nil then
	--	WAR.Person[enemyid]["特效文字2"] = "  "
	--end
	--误伤不显示动画
	if DWPD() == false then
		WAR.Person[enemyid]["特效动画"] = -1
		WAR.Person[enemyid]["特效文字0"] = nil
		WAR.Person[enemyid]["特效文字1"] = nil
		WAR.Person[enemyid]["特效文字2"] = nil
		WAR.Person[enemyid]["特效文字3"] = nil
		WAR.Person[enemyid]["特效文字4"] = nil
	end	
	--达摩的特效动画
    if match_ID(eid,577) then	
        WAR.Person[enemyid]["特效动画"] = 156
    end   
	--被血刀老祖击杀的人物该回合显示动画
	if WAR.XDLZ[eid] ~= nil then
		WAR.Person[enemyid]["特效动画"] = 123
		WAR.XDLZ[eid] = nil
	end

	if match_ID(pid, 511) and DWPD() then
		local zt = {{'六阳正气',2},{'黄连解毒',2},{'牛黄血蝎',2},{'小还丹',2},{'天香续命',2},{'白云熊胆',2},
					{'即墨老酒',2},{'玉露酒',2},{'梨花酒',2},{'五宝花蜜酒',2},{'诸法无我',2},{'皆',1},{'前',1},{'在',1},{'阵',1},
					{'列',1},{'者',1},{'斗',1},{'兵',1},{'临',1},{'西瓜刀·天人',2},{'西瓜刀·残刀',2},
					{'西瓜刀·残刀',2},{'太极蓄力',1},{'蛤蟆蓄力',1},{'鲸息蓄力',1},{'疾如风',2},{'长生诀',2},
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
		{"洞火"},
		{"放下屠刀"},
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
        local ns = JY.Person[eid]['受伤程度']
        local zd = JY.Person[eid]['中毒程度']
        local bf = JY.Person[eid]['冰封程度']
        local zs = JY.Person[eid]['灼烧程度']
        if ns > 0 then 
            --WAR.Person[i]["解毒点数"];
            WAR.Person[WAR.CurID]["内伤点数"] = (WAR.Person[WAR.CurID]["内伤点数"] or 0) + AddPersonAttrib(pid,'受伤程度',ns)
            JY.Person[eid]['受伤程度'] = 0
            WAR.Person[enemyid]["内伤点数"] = nil
        end
        if zd > 0 then 
            --WAR.Person[i]["解毒点数"];
            WAR.Person[WAR.CurID]["中毒点数"] = (WAR.Person[WAR.CurID]["中毒点数"] or 0) + AddPersonAttrib(pid,'中毒程度',zd)
            JY.Person[eid]['中毒程度'] = 0
            WAR.Person[enemyid]["中毒点数"] = nil
        end
        if bf > 0 then 
            WAR.BFXS[pid] = 1
            AddPersonAttrib(pid,'冰封程度',bf)
            JY.Person[eid]['冰封程度'] = 0
            WAR.BFXS[eid] = nil
        end
        if zs > 0 then 
            WAR.ZSXS[pid] = 1
            AddPersonAttrib(pid,'灼烧程度',zs)
            JY.Person[eid]['灼烧程度'] = 0
            WAR.ZSXS[eid] = nil
        end
		WAR.Person[enemyid]["特效动画"] = 21
		Set_Eff_Text(enemyid,"特效文字0","转阴阳");
    end
    
	WAR.PD['氤氲紫气'][eid] = nil
    if match_ID(pid, 9965) then
        JY.Person[pid]['冰封程度'] = 0
        JY.Person[pid]['灼烧程度'] = 0
        WAR.BFXS[pid] = nil
        WAR.ZSXS[pid] = nil
    end
	::label0::
	return math.modf(hurt);
end

-- 绘制战斗地图
-- flag=0  绘制基本战斗地图
--     =1  显示可移动的路径，(v1,v2)当前移动坐标，白色背景(雪地战斗)
--     =2  显示可移动的路径，(v1,v2)当前移动坐标，黑色背景
--     =3  命中的人物用白色轮廓显示
--     =4  战斗动作动画  v1 战斗人物pic, v2贴图所属的加载文件id
--                       v3 武功效果pic  -1表示没有武功效果
function WarDrawMap(flag, v1, v2, v3, v4, v5, ex, ey, px, py)
	local x = WAR.Person[WAR.CurID]["坐标X"]
	local y = WAR.Person[WAR.CurID]["坐标Y"]
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
		--胡斐居，雪山，有间客栈，凌霄城，北京城，华山绝顶
		if v4 == 0 or v4 == 2 or v4 == 3 or v4 == 39 or v4 == 107 or v4 == 111 then
			lib.DrawWarMap(1, x, y, v1, v2, -1, v4)
		else
			lib.DrawWarMap(2, x, y, v1, v2, -1, v4)
		end
	elseif flag == 2 then
			lib.DrawWarMap(3, x, y, 0, 0, -1, v4)
	elseif flag == 4 then
		lib.DrawWarMap(4, x, y, v1, v2, v3, v4,v5, ex, ey)
	--单人动画
	elseif flag == 6 then
		lib.DrawWarMap(6, x, y, v1, v2, v3, v4,v5, ex, ey, px, py)

	--防御动画
	elseif flag == 7 then
		lib.DrawWarMap(7, x, y, 0, 0, v3, v4,v5, ex, ey, px, py)
	end
  
	if WAR.ShowHead == 1 then
		WarShowHead()
	end
	
	if CONFIG.HPDisplay == 1 then
		if WAR.ShowHP == 1 then
			HP_Display_When_Idle()	--常态显血
		end
	end
end

--敌方战斗数据
function WarSelectEnemy()
	--敌方数据特别调整
	if PNLBD[WAR.ZDDH] ~= nil then
		PNLBD[WAR.ZDDH]()
	end
  
    if WAR.ZDDH == 354 then 
        local x = 20
        local y = 46
        for i = 1,#CC.HSLJ2 do
            local id = CC.HSLJ2[i]
            WAR.Person[WAR.PersonNum]["人物编号"] = id
            WAR.Person[WAR.PersonNum]["我方"] = false
            WAR.Person[WAR.PersonNum]["坐标X"] = x
            WAR.Person[WAR.PersonNum]["坐标Y"] = y
            WAR.Person[WAR.PersonNum]["死亡"] = false
            WAR.Person[WAR.PersonNum]["人方向"] = 0
            WAR.PersonNum = WAR.PersonNum + 1
            x = x + 1
            if x == 34 then 
                x = 20
                y = y - 2
            end
        end
    else
        for i = 1, 20 do
            if WAR.Data["敌人" .. i] > 0 then
                --冰糖恋：单挑陈达海
                if WAR.ZDDH == 92 and GetS(87,31,33,5) == 1 then
                    for i=2,5 do	
                        WAR.Data["敌人" .. i] = -1;
                    end
                end
                
                --无酒不欢：新论剑敌人
                if WAR.ZDDH == 266 then
                    WAR.Data["敌人1"] = GetS(85, 40, 38, 4)
                end
                
                WAR.Person[WAR.PersonNum]["人物编号"] = WAR.Data["敌人" .. i]
                WAR.Person[WAR.PersonNum]["我方"] = false
                WAR.Person[WAR.PersonNum]["坐标X"] = WAR.Data["敌方X" .. i]
                WAR.Person[WAR.PersonNum]["坐标Y"] = WAR.Data["敌方Y" .. i]
                WAR.Person[WAR.PersonNum]["死亡"] = false
                WAR.Person[WAR.PersonNum]["人方向"] = 1
                
                --无酒不欢：调整战斗初始面向
                --战海大富
                if WAR.ZDDH == 259 then
                    WAR.Person[WAR.PersonNum]["人方向"] = 2
                end
                --双挑公孙止
                if WAR.ZDDH == 273 then
                    WAR.Person[WAR.PersonNum]["人方向"] = 3
                end
                --杨过单金轮
                if WAR.ZDDH == 275 then
                    WAR.Person[WAR.PersonNum]["人方向"] = 3
                end
                --战杨龙
                if WAR.ZDDH == 75 then
                    WAR.Person[WAR.PersonNum]["人方向"] = 3
                end
                --蒙哥
                if WAR.ZDDH == 278 then
                    WAR.Person[WAR.PersonNum]["人方向"] = 3
                end
                --芷若夺掌门
                if WAR.ZDDH == 279 then
                    WAR.Person[WAR.PersonNum]["人方向"] = 3
                end
                --单挑赵敏
                if WAR.ZDDH == 293 then
                    WAR.Person[WAR.PersonNum]["人方向"] = 3
                end
                --玄冥二老
                if WAR.ZDDH == 295 then
                    WAR.Person[WAR.PersonNum]["人方向"] = 3
                end
                --三挑岳不群
                if WAR.ZDDH == 298 then
                    WAR.Person[WAR.PersonNum]["人方向"] = 2
                end
                --侠客邪
                if WAR.ZDDH == 170 then
                    WAR.Person[WAR.PersonNum]["人方向"] = 3
                end
                WAR.PersonNum = WAR.PersonNum + 1
            end
        end
    end
end

--计算战斗人物贴图
function WarCalPersonPic(id)
	
	--local n = 5106
	--n = n + JY.Person[WAR.Person[id]["人物编号"]]["头像代号"] * 8 + WAR.Person[id]["人方向"] * 2
	

	local pid = WAR.Person[id]['人物编号']
	local t = 0
	local n = 0
	for i = 1,5 do 
		if JY.Person[pid]['出招动画帧数'..i] > 0 then 
			t = JY.Person[pid]['出招动画帧数'..i]
			break
		end
	end

	n = n + WAR.Person[id]["人方向"]*t*2
	return n
end

--计算标准主角特殊行走贴图
function WarCalPersonPic2(id, gender)
	local n = 5058
	if gender == 1 then
		n = 5010
	end
	n = n + WAR.Person[id]["人方向"] * 12
	return n
end

--战斗是否结束
function War_isEnd()
	for i = 0, WAR.PersonNum - 1 do
		if JY.Person[WAR.Person[i]["人物编号"]]["生命"] <= 0 then
			WAR.Person[i]["死亡"] = true
		end
	end
	Cat('实时特效动画')
	WarSetPerson()
	Cls()
	ShowScreen()
	lib.Delay(CC.BattleDelay)
	local myNum = 0
	local EmenyNum = 0
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["死亡"] == false then
			if WAR.Person[i]["我方"] == true then
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

--无酒不欢：战斗是否结束2
function War_isEnd2()
	local myNum = 0
	local EmenyNum = 0
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["死亡"] == false then
			if WAR.Person[i]["我方"] == true then
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
	WAR.WGWL = 0		--记录武功10级的攻击力
	WAR.ZYHB = 0		--左右互搏，1：发动左右的回合，2：左右的额外回合
	WAR.ZYHBP = -1		--记录发动左右的人的编号
	WAR.ZHB = 0			--周伯通的追加左右判定
	WAR.AQBS = 0		--暗器倍数
	WAR.BJ = 0			--暴击
	WAR.XK = 0			--西狂之怒啸
	WAR.XK2 = nil
	WAR.DXZL = 0			--东邪之怒
	WAR.DXZL2 = nil	
	WAR.SKXYXS = 0			--
	WAR.TD = -1			--偷盗
	WAR.TDnum = 0		--偷盗数量
	WAR.HTSS = 0		--医生大招
	WAR.ZSF = 0			--张三丰万法自然
	WAR.QLBLX = 0		--李白千里不留行
	
	WAR.XZZ = 0			--虚竹福泽加护
	WAR.KFKJ = 0		--封不平狂风快剑
	WAR.HTS = 0			--何铁手五毒随机2-5倍威力
	WAR.ZWX = 0	
	WAR.JYZJ_FXJ = 0	--	飞絮劲
    WAR.DZTG_DZS = 0	--	大宗师	
	WAR.FS = 0			--四帮主之战，乔峰用铁掌
	WAR.ZBT = 1			--周伯通，每行动一次，攻击时伤害一+10%
	WAR.HQT = 0			--霍青桐 杀体力
	WAR.CY = 0			--程英 杀内力
	WAR.HDWZ = 0		--霍都随机上毒
	WAR.ZJZ = 0			--朱九真，随机得到食材
	WAR.YJ = 0			--阎基偷钱
	WAR.DJGZ = 0		--刀剑归真
	WAR.DFMQ = 0		--大伏魔拳	
	WAR.WS = 0			--误伤
	WAR.ACT = 1			--连击回数
	WAR.WDKTJ = 0		--	
	WAR.LYSH = 0 		--两仪守护
	WAR.AJFHNP1 = 0 	--
	WAR.TKXJ = 0		--太空卸劲
	WAR.SJHB = 0		--双剑合壁
	WAR.SJHB_G = 0		--双剑合壁.攻
	WAR.SJHB_S = 0		--双剑合壁.守		
	WAR.DZXY = 0		--斗转星移
	WAR.LXZQ = 0		--拳主大招
	WAR.LXYZ = 0		--指主大招
	WAR.JSYX = 0		--剑神大招
	WAR.QLJG = 0		--青莲剑歌大招
	WAR.SL23 = 0	
	WAR.ASKD = 0		--刀主大招
	WAR.LXBR = 0		--龙象大招
	WAR.LXZL10 = 0			--龙象之力暴怒，忽视绝对气防	
	WAR.XC_WLCZ = 0			--	
	WAR.XC_JJNP = 0			--	
	WAR.YZHYZ = 0		--刀主大招增加怒气计数
	WAR.GCTJ = 0		--奇门大招
	WAR.JSTG = 0		--天罡大招
	WAR.YTML = 0 		--毒王大招
	WAR.SLSS = 0 		--梁萧 星罗散手	
	WAR.NGXS = 0		--内功攻击的系数
	WAR.TXZZ = 0		--太玄之重
	WAR.MMGJ = 0		--盲目攻击
	WAR.TFBW = 0		--听风辨位的文字记录
	WAR.TLDWX = 0		--天罗地网的文字记录
	WAR.JSAY = 0		--金蛇奥义
	WAR.JYSZ = 0		--九阴神爪
	WAR.OYFXL = 0 		--欧阳锋根据蛤蟆蓄力增加伤害
	WAR.LXXL = 0 		--梁萧蓄力增加伤害	
	WAR.XDLeech = 0		--血刀吸血量
	WAR.WYXLeech = 0	--韦一笑吸血量
	WAR.TMGLeech = 0	--天魔功吸血量
	WAR.BHLeech = 0	--碧海吸血量
	WAR.BMSGXL = 0	--北冥吸内	
	WAR.XHSJ = 0		--血河神鉴吸血量
	WAR.WDRX = 0		--宋远桥使用太极拳或太极剑攻击后自动进入防御状态
	WAR.KMZWD = 0 		--周伯通空明之武道
	WAR.ARJY = 0		--黯然极意
	WAR.ARJY1 = 0		--黯然极意	
	WAR.YLTW = 0		--云罗天网	
	WAR.LFHX = 0 		--林朝英流风回雪
	WAR.LWSWD = 0		--	
	WAR.YQFSQ = 0		--一气化三清	
	WAR.QXWXJ = 0		--七弦无形剑 莫大	
	WAR.YYBJ = 0 		--郭靖：有余不尽
	WAR.SEYB = 0
	WAR.MHSN = 0 		--	
    WAR.KZJYBF = 0      --
	WAR.BJYPYZ = 0 		--	
	WAR.BJYJF = 0 		--		
	WAR.YNXJ = 0		--玉女心经：夭矫空碧
	WAR.HXZYJ = 0		--会心之一击
	WAR.QQSH1 = 0		--琴棋书画之持瑶琴
	WAR.QQSH2 = 0		--琴棋书画之妙笔丹青
	WAR.QQSH3 = 0		--琴棋书画之倚天屠龙功
	WAR.YZQS = 0		--一震七伤
	WAR.HYYQ=0
	WAR.TYJQ = 0		--阿青天元剑气
	WAR.WWWJ = 0
	WAR.LDJT = 0		--雷动九天
	WAR.CXLZ = 0	
	WAR.QBLL = 0		--
	WAR.SZXM = 0		--
    WAR.BLCC = 0
	WAR.XMJDHS = 0
	WAR.XMHSQ = 0	
	WAR.JTYJ1 = 0		--
	WAR.HZD_1 = 0		--陆渐海之道，上善若水，
	WAR.HZD_2 = 0		--陆渐海之道，海纳百川		
	WAR.OYK = 0 		--欧阳克灵蛇拳
    WAR.JXG_SJG =0      --鲸息功 神鲸歌
	WAR.JQBYH = 0		--六脉：剑气碧烟横
	WAR.CMDF = 0		--沧溟刀法
	WAR.NZQK = 0		--逆转乾坤
	WAR.XMJDHS = 0
	WAR.XMHSQ = 0	
	WAR.JTYJ1 = 0		--
	WAR.HZD_1 = 0		--陆渐海之道，上善若水，
	WAR.HZD_2 = 0		--陆渐海之道，海纳百川		
	WAR.OYK = 0 		--欧阳克灵蛇拳
    WAR.JXG_SJG =0      --鲸息功 神鲸歌
	WAR.JQBYH = 0		--六脉：剑气碧烟横
	WAR.CMDF = 0		--沧溟刀法
	WAR.NZQK = 0		--逆转乾坤
	WAR.BXCF = 0 		--袁承志碧血长风
	WAR.XMCX = 0 		--西门吹雪
	WAR.LJXD = 0 		--立即行动
	WAR.LJXD1 = 0 		--立即行动1		
	WAR.SBSYR = 0 		--李白十步杀一人
	WAR.FLHS1 = 0		--其疾如风
	WAR.FLHS2 = 0		--其徐如林
	WAR.FLHS4 = 0		--不动如山	
	--WAR.FLHS5 = 0		--难知如阴
	WAR.ZYZD = 0		--中庸之道
	--WAR.SSESS = 0		--三十二身相
	WAR.SSESS1 = 0		--三十二身相.诸天相
	WAR.SSESS4 = 0		--三十二身相.白毫相
	WAR.SSESS5 = 0		--三十二身相.神鱼相
	WAR.SSESS6 = 0		--三十二身相.马王相
	WAR.NGJL = 0		--当前加力内功编号
	WAR.NGHT = 0		--当前护体内功编号
	WAR.CQSX = 0		--除却四相
	WAR.ZWWW = 0		--坐忘勿我
	WAR.BMXH = 0		--三大吸功
 	WAR.HDJY = 0		--胡刀极意   	
	WAR.BTJS = 0		--补天劫手
	WAR.ZYYD = 0		--记录左右的圣火移动步数
	WAR.LMSJwav = 0		--六脉神剑的音效
	WAR.JGZ_DMZ = 0		--达摩掌
	WAR.LHQ_BNZ = 0		--般若掌
	WAR.WD_CLSZ = 0		--赤练神掌
	WAR.QZ_QXJF = 0		--七星剑法
	WAR.BXXHSJ = 0		--	
	WAR.ShowHead = 0	--显示右下角头像信息
	WAR.Effect = 0		--本次攻击的效果，2：伤害，3：杀内，4：医疗，5：上毒，6：解毒
	WAR.Delay = 0
	WAR.LifeNum = 0
	WAR.TZ_MRF = 0		--慕容复指令
	WAR.KHBX = 0		--葵花刺目
	WAR.BFX = 0			--必封穴
	WAR.BLX = 0			--必流血
	WAR.BBF = 0 		--必冰封
	WAR.BZS = 0			--必灼烧
	WAR.GSWS = 0 		--盖世无双
	--WAR.SSESS = 0 		--陆渐三十二身相
	--WAR.JGFX = 0 		--陆渐金刚法相	
	WAR.TWLJ = 0 		--天外连击
	WAR.DJJJ_LJ = 0
	WAR.SYLJ = 0 		--陆渐三十二身相 神鱼相连击
	WAR.JYLJ = 0 		--九阴连击	
	WAR.hit_DGQB = 0	--无酒不欢：独孤求败反击的特效显示
	WAR.XTTX = 0			--先天调息
	WAR.WFCZ_1 = 0			--万佛朝宗	
	WAR.JHZT = 0	
	WAR.MZSH = 0			--阿紫曼珠沙华，每杀一个人+200气攻气防
   
	WAR.SZSD = -1			--被死战锁定的目标
	WAR.BJGX = 0
	WAR.JJZC = 0		--九剑真传的4种主动攻击特效
	WAR.JJDJ = 0 		--九剑荡剑式回气
	WAR.Dodge = 0		--判定是否闪避

	WAR.CXLC = 0		--狄云赤心连城
    WAR.YTLJ = 0		--倚天连击	
	WAR.CXLC_Count = 0	--狄云赤心连城计数
	WAR.WLLJ_Count = 0
	WAR.FQY = 0			--风清扬无招胜有招
	WAR.GHQH = 0		--黄衫女 广寒清辉
	WAR.LXXZD = 0	    --梁萧 谐之道	
	WAR.LPZ = 0			--林平之回气
	WAR.JMZL = 0
	WAR.L_TLD = 0;		--装备屠龙刀特效，1流血
	WAR.PJTX = 0 		--玄铁剑配玄铁剑法，破尽天下
    WAR.YLSJJ = 0
	WAR.NZZ1 = 0
	WAR.BXZS = 0				--辟邪招式
	WAR.JYZS = 0				--九阳招式
	WAR.KHSZ = 0			--葵花神针
	WAR.ZWYJF = 0			--有剑诀的五岳剑法，无视绝对气防
	WAR.KHLH = 0			--葵花 六合
	WAR.TXZS = 0 			--太玄招式
	WAR.AJFHNP = 0	        -- 阿九	
	WAR.JuHuo = 0			--举火燎原
	WAR.LiRen = 0			--利刃寒锋
	WAR.LWX = 0				--李文秀的破气防特效
	WAR.PDJN = 0			--陈家洛庖丁解牛
	WAR.KF = 0	
	WAR.ATNum = 1
	WAR.RULAISZ = 0
	WAR.RULAISZ_1 = 0
end	

--设置战斗全局变量
function WarSetGlobal()
	WAR = {}
	WAR.Data = {}
	WAR.Person = {}
	WAR.MCRS = 0 --无酒不欢：每场战斗选的人数
	for i = 0, 100 do
		WAR.Person[i] = {}
		WAR.Person[i]["人物编号"] = -1
		WAR.Person[i]["我方"] = true
		WAR.Person[i]["坐标X"] = -1
		WAR.Person[i]["坐标Y"] = -1
		WAR.Person[i]["死亡"] = true
		WAR.Person[i]["闪避"] = false;
		WAR.Person[i]["人方向"] = -1
		WAR.Person[i]["贴图"] = -1
		WAR.Person[i]["贴图类型"] = 0
		WAR.Person[i]["轻功"] = 0
		WAR.Person[i]["移动步数"] = 0
		WAR.Person[i]["经验"] = 0
		WAR.Person[i]["自动选择对手"] = -1
		WAR.Person[i].Move = {}
		WAR.Person[i].Action = {}
		WAR.Person[i].Time = 0
		WAR.Person[i].TimeAdd = 0
		WAR.Person[i].SpdAdd = 0
		WAR.Person[i].Point = 0
		WAR.Person[i]["特效动画"] = -1
		WAR.Person[i]["反击武功"] = -1
		WAR.Person[i]["特效文字0"] = nil
		WAR.Person[i]["特效文字1"] = nil
		WAR.Person[i]["特效文字2"] = nil
		WAR.Person[i]["特效文字3"] = nil
		WAR.Person[i]["特效文字4"] = nil	--无酒不欢：加到这里 8-11
		WAR.Person[i]["先手反击"] = -1
		WAR.Person[i]["反击"] = -1
		WAR.Person[i]["护盾"] = -1
		WAR.Person[i]["护盾贴图"] = -1
		WAR.Person[i]["护盾延迟"] = nil
		WAR.Person[i]["神游太虚"] = nil
	end
    
	WAR.PersonNum = 0
	WAR.AutoFight = 0
	WAR.CurID = -1
	WAR.MissPd = 0
	WAR.SXTJ = 0		--时序
	WAR.SSX_Counter = 0	--三时序计数器
	WAR.WSX_Counter = 0	--五时序计数器
	WAR.LSX_Counter = 0	--六时序计数器
	WAR.JSX_Counter = 0	--九时序计数器
	WAR.BDQS = 0		--王重阳北斗真打状态层数
	WAR.QCF = 0			--戚长发复活
	WAR.WQTS_TY = 0		--忘情天书 天意	
	WAR.XMH = 0			--薛慕华 复活一个人
	WAR.ZSHY = {}		--转瞬红颜计数器
	WAR.WCY = {}		--一灯复活
	WAR.CYZX = {} 		--王重阳复活
 
	--出手判定
	WAR.ATK = {['人物'] = nil,['人物table'] = {},['人物pd'] = {},
				}
    
    --常驻函数
	WarSet()
	
	WAR.PYZ = 0			--平一指杀人
	
	
	WAR.ZDDH = -1		--战斗代号
	WAR.NO1 = -1		--旧版论剑第一名
	
	WAR.TJAY = 0		--太极奥义
	

	WAR.DZXYLV = {}
	--WAR.fthurt = 0		--乾坤反弹的伤害

	
	WAR.TLDW = {}		--天罗地网
	
	--判定数据，统一书写
	WAR.PD = {
			['乾'] = {},			--八卦·乾特效
			['坤'] = {},			--八卦·坤特效
			['震'] = {},			--八卦·震特效
			['巽'] = {},			--八卦·巽特效
			['坎'] = {},			--八卦·坎特效
			['离'] = {},			--八卦·离特效
			['艮'] = {},			--八卦·艮特效
			['兑'] = {},			--八卦·兑特效
			['刀剑绝技'] = {},     --刀剑绝技
			['临'] = {},			--八卦·兑特效
			['兵'] = {},			--八卦·兑特效
			['斗'] = {},			--八卦·兑特效
			['者'] = {},			--八卦·兑特效
			['列'] = {},			--八卦·兑特效
			['阵'] = {},			--八卦·兑特效
			['皆'] = {},			--八卦·兑特效
			['在'] = {},			--八卦·兑特效
			['前'] = {},			--八卦·兑特效
			['神游太虚'] = {},		
			['蛇行狸翻'] = {},
			['氤氲紫气'] = {},
			['如来神掌'] = {},
            ['金刚般若']	= {},	
			['疾如风'] = {},
			['侵如火'] = {},
			['守如山'] = {},
			['徐如林'] = {},
			['绣花针'] = {},
			['无量禅震'] = {},
			['诸法无我'] = {},
			['偷天换日'] = {},
			['梅长苏'] = {},
			['先天护盾CD'] = {},
			['先天护盾'] = {},
			['蛤蟆蓄力'] = {},
			['鲸息蓄力'] = {},
			['太极蓄力'] = {},
			['复活状态'] = {},
			['走火状态'] = {},
			['先天罡气'] = {},
			['独孤求败'] = {},
            ['野球拳'] = {},
            ['西瓜刀'] = {},
            ['西瓜刀·残刀'] = {},
            ['西瓜刀·天人'] = {},
            ['长生诀'] = {},
            ['雪花六出'] = {},
            ['降龙·双龙取水'] = {},
            ['降龙·亢龙有悔'] = {},
            ['降龙·潜龙勿用'] = {},
            ['降龙·震惊百里'] = {},
            ['降龙·飞龙在天'] = {},
            ['降龙·见龙在田'] = {},
            ['降龙·时乘六龙'] = {},
            ['火延'] = {},
            ['复活·一灯'] = {},
            ['复活·天佛'] = {},
            ['复活·王重阳'] = {},
            ['复活·长生'] = {},
            ['复活·神照'] = {},
            ['复活·天意'] = {},
            ['复活·阿九'] = {},
            ['复活·戚长发'] = {},
            ['回气'] = {},
            ['绊字决'] = {},
            ['封字决'] = {},
            ['转字决'] = {},
            ['缠字决'] = {},
            ['挑字决'] = {},
            ['引字决'] = {},
            ['戳字决'] = {},
            ['曲夕烟隙'] = {},
            ['曲径通幽'] = {},
            ['八酒杯'] = {},
            ['梨花酒'] = {},
			['玉露酒'] = {},
            ['五宝花蜜酒'] = {},			
            ['即墨老酒'] = {},
            ['白云熊胆'] = {},
            ['天香续命'] = {},
            ['小还丹'] = {},
            ['黄连解毒'] = {},
            ['牛黄血蝎'] = {},
            ['六阳正气'] = {},
			['万佛朝宗'] = {},
			['洞火'] = {},
            ['中庸'] = {},
			['天关阵4'] = {},
			['立地成佛'] = {},
			['放下屠刀'] = {},
			['创伤'] = {},
	}
	
	WAR.TGCD = {[356] = 50,
	}
	WAR.CD = 0  --天关的CD
	
    WAR.BLCC_1 = {}		

	WAR.TXXS = {} 		--特效点数显示
	
	WAR.EffectXY = nil
	WAR.EffectXYNum = 0
	WAR.tmp = {}		-- 100：基础   200：蛤蟆功蓄力，1000：欧阳锋逆运走火，1500：鲸息功蓄力，2000：太极拳蓄力，3000：神照复活，4000：太虚剑意蓄力，5000：头像编号
	WAR.Actup = {}		--蓄力记录
	WAR.Defup = {}		--防御记录
	WAR.Wait = {}		--等待记录
	WAR.Focus = {}		--集中记录
	WAR.HMGXL = {}		--蛤蟆蓄力增加300集气
	WAR.Weakspot = {}	--破绽计数
	WAR.KHCM = {}		--被刺目的人记录
	WAR.LQZ = {}		--怒气值
	WAR.FXDS = {}		--封穴点数
	WAR.FXXS = {}		--封穴显示
	WAR.LXZT = {}		--流血点数
	WAR.LXXS = {}		--流血显示
	WAR.BFXS = {}		--冰封显示
	WAR.ZSXS = {}		--灼烧显示
	WAR.SZJPYX = {}		--已经提供过实战的人记录（被打死的）
	

	
	WAR.DXMX = {}		--大须弥相
	
	WAR.TZ_DY = 0		--段誉指令
	WAR.TZ_XZ = 0		--虚竹指令

	WAR.TZ_XZ_SSH = {}	--中了生死符的人记录
	WAR.TXZQ = {}		--太玄之轻

	WAR.DZZ = {}		--三十二身相 大自在相
	WAR.FGPZ = {}		--		
	WAR.JJJ = {}		--将进酒
	WAR.JQSDXS = {} 	--无酒不欢：集气速度显示
	
	
	WAR.WXFS = nil		--李秋水无相分身的编号记录
	WAR.JJPZ = {} 		--无酒不欢：九剑破招
	WAR.TKJQ = {}		--太空卸劲减少集气
	WAR.BHJQ = {}		--碧海惊涛掌招式4减少集气	

	WAR.TJZX = {}		--太极之形记录
	WAR.WFCZ = {}		--万佛朝宗
	WAR.TXSH = {}		--万佛朝宗	
	WAR.HZD_QF = {}		--曲风记录	


	WAR.WZSYZ = {}		--被无招胜有招击中的人
	WAR.ZXXS = {}		--紫霞蓄力
	WAR.GMYS = 0		--范遥挨打加减伤
	WAR.GMZS = {}		--被杨逍打中的人记录
	
		
	WAR.JYFX = {}		--九阳7时序解除封穴
		
	WAR.QYBY = {}		--林朝英轻云蔽月，每50时序可触发一次，免疫伤害10时序
	WAR.XZ_YB = {}		--小昭影步记录
	WAR.LSQ = {}		--被灵蛇拳击中的人记录
	
	WAR.HP_Bonus_Count = {}	--记录血量翻倍的编号
  
	WAR.L_EffectColor = {}					--异常状态的颜色显示
	WAR.L_EffectColor[1] = M_Silver;		--显示减少生命
	WAR.L_EffectColor[2] = M_Pink;			--显示增加生命
	WAR.L_EffectColor[3] = M_LightBlue;		--显示解毒
	WAR.L_EffectColor[4] = M_DeepSkyBlue;	--显示内力减少和增加
	WAR.L_EffectColor[5] = M_PaleGreen;		--显示体力减少和增加
	WAR.L_EffectColor[6] = C_GOLD;			--显示封穴
	WAR.L_EffectColor[7] = M_Red;			--显示流血
	WAR.L_EffectColor[8] = M_DarkGreen;		--显示中毒
	WAR.L_EffectColor[9] = PinkRed;			--显示内伤减少和增加
	WAR.L_EffectColor[10] = LightSkyBlue;	--显示冰封
	WAR.L_EffectColor[11] = C_ORANGE;		--显示灼烧
  
	WAR.L_WNGZL = {};		--王难姑指令，持续中毒减血
	WAR.L_HQNZL = {};		--胡青牛指令，持续回血回内伤
  
	WAR.L_QKDNY = {};		--设定攻击多个人时，乾坤只能被反一次
  
	WAR.L_NOT_MOVE = {};	--记录不可移动的人
	WAR.XDLZ = {};			--记录被血刀老祖杀掉的人
	WAR.ZZRZY = 0			--周芷若领悟左右的剧情
	--WAR.YLHF = 0			--
	--WAR.BSTX = 0			--白首太玄
	WAR.ShowHP = 1			--血条显示
	WAR.FF = 0				--主角觉醒后，喵姐开局前三次不受伤害
	WAR.ZQHT = 0 			--是否触发真气护体
	
	WAR.TSSB = {}			--进阶泰山，使用后30时序内闪避
	WAR.QLJX = {}			--李白深藏身与名，使用后50时序内闪避
	WAR.SFB = {}			--梁萧三三步，使用后30时序内闪避
	WAR.CSHF = {}			--长生回复 
	WAR.BTZT = {}			--霸体状态 	
	WAR.WQTS_WW = {}	    --我无	
	WAR.JDYJ = {}			--剑胆琴心增加御剑能力
	WAR.SKZX= {}	
	WAR.WMYH = {}			--无明业火状态，耗损使用的内力一半的生命
	WAR.TGJF = {}			--王重阳 同归剑法	
	
	WAR.JHLY = {}			--无酒不欢：举火燎原，金乌+燃木+火焰刀
	WAR.LRHF = {}			--无酒不欢：利刃寒锋，修罗+阴风+沧溟
	WAR.XZD = {}			--梁萧谐之道	
	WAR.SLSX = {}			--金轮，十龙十象
	WAR.HMZT = {}			--昏迷状态
	WAR.YYZS= {}           --一言止杀
	WAR.HQT_ZL= {}           --霍青桐指令
	WAR.HQT_CD= 0           --霍青桐指令
	WAR.JYZT = {}			--阿紫，禁药状态

	
	WAR.CSZT = {}			--沉睡状态

	WAR.SGZT = {}			--散功状态			
	WAR.PJZT = {}			--破军状态
	WAR.PJJL = {}			--被破军前的内功记录
	WAR.SGJL = {}			--散功前的内功记录	
	
	WAR.YSJF = {}			--玉石俱焚
	WAR.XLFD = {}			--小李飞刀
    WAR.JTYJ = {}			--惊天一剑
	
	WAR.HLZT = {}			--混乱状态
	WAR.MHZT = {}			--魅惑状态
	
	WAR.QYZT = {}			--琴音状态
	WAR.WFZT = {}			--	
    WAR.CHZT = {}			--迟缓状态
    WAR.JFJQ = {}			--疾风状态清0	
	WAR.XRZT = {}			--虚弱状态
	WAR.ZYCD = 0
	WAR.XRZT1 = {}			--虚弱状态1
	WAR.XZBFZT = {}			    --血战八方ZT
    WAR.WTL_PJTL= {}	
    WAR.WTL_1= {}	
	WAR.WMYS= {}
	WAR.JSZT1 ={}          --丘处机计时状态已方
	
	WAR.JSZT2 ={}          --通用计时状态敌方	
	WAR.QGZT = {}			--倾国状态
	
	WAR.BiXieZhaoShi = {}        --辟邪招式	
	WAR.BXLQ = {}				--辟邪冷却记录
	WAR.BXCD = {0,1,0,1,2,3}	--辟邪冷却时间

	--WAR.LXBHZS = 0					--碧海招式
	--WAR.LXBHLQ = {}				--碧海冷却记录	
   -- WAR.LXBHCD = {0,0,2,2,3,5}	--碧海冷却时间	
	--WAR.LXBIHAIZhaoShi = {}        --碧海招式

	WAR.JYLQ = {}				--九阳冷却记录	
	WAR.JYCD = {0,1,5}	       --九阳九阳冷却时间
	WAR.JIUYANGZhaoShi = {}     --九阳招式	
	

	WAR.SSESS = {}			--三十二身相
	WAR.JGFX = {}			--陆渐金刚法相

	

	
	WAR.XYYF = {}			--逍遥御风
	
	WAR.XYYF_10 = 0			--本回合逍遥御风累积至9点
	
	WAR.YFCS = 0			--逍遥御风次数

	
	
	WAR.ZQTL = {}			--紫气天罗

	WAR.ZTHSB = 0			--诸天化身步
	WAR.ZT_id = -1			--触发人的ID
	WAR.ZT_X = -1			--触发人的X坐标
	WAR.ZT_Y = -1			--触发人的Y坐标
	
	WAR.Miss = {}			--闪避的miss显示
	
	WAR.MBJZ = {}			--张家辉的麻痹戒指
	WAR.SZZT = {}			--锁足	
    WAR.WTL_LDJT= {} 
    WAR.MRSHZT= {}   	
	--WAR.JHZT = {}	
	WAR.ZTHF = {}		
	--WAR.JHZT1 = {}	
	WAR.FHJZ = 0 			--张家辉的复活戒指
    WAR.FUHUOZT={}	
	WAR.YSJZ = 0 			--张家辉的隐身戒指
	
	WAR.FW = {}
    WAR.Atid = -1
	CleanWarMap(7, 0)
end


--显示人物的战斗信息，包括头像，生命，内力等
function WarShowHead(id)
	if not id then
		id = WAR.CurID
	end
	if id < 0 then
		return 
	end
	local pid = WAR.Person[id]["人物编号"]
	local p = JY.Person[pid]
	local h = CC.FontSMALL
	local width = CC.FontSMALL*11 - 6
	local height = (CC.FontSMALL+CC.RowPixel)*9 - 12
	local x1, y1 = nil, nil
	local i = 1
	local size = CC.FontSmall3

	if WAR.Person[id]["我方"] == true then
		x1 = CC.ScreenW - width - 6
		y1 = CC.ScreenH - height - CC.ScreenH/6 -6
		lib.LoadPNG(91, 28 * 2 ,x1, y1+height+CC.ScreenH/30-253, 1)
	end
	if WAR.Person[id]["我方"] == false then		
        x1 = 10
        y1 = 35
	    lib.LoadPNG(91, 28 * 2 ,x1,y1-35, 1)	
	end
		 
	---------------------------------------------------------状态显示---------------------------------------------------------
	
	local zt_num = 0
	if WAR.ZDDH == 356 then 
		local ss = {[5] = '徐如林',[27] = '疾如风',[50] = '侵如火',[114] = '守如山'}
		if WAR.PD["天关阵4"][pid] ~= nil then 
			local sm = ss[WAR.PD["天关阵4"][pid]]
			if WAR.Person[id]["我方"] == true then
				lib.LoadPNG(98, 101 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len(sm)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, sm, C_WHITE, size)				
			else
				lib.LoadPNG(98, 101 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, sm, C_WHITE, size)
			end
			zt_num = zt_num + 1
		end
	end
	
	--六阳正气	
	if   WAR.PD["六阳正气"][pid] ~= nil and WAR.PD["六阳正气"][pid] > 0 then
		local tjzx = WAR.PD["六阳正气"][pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("六阳正气:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "六阳正气:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "六阳正气:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	
	--牛黄血蝎丹	
	if   WAR.PD["牛黄血蝎"][pid] ~= nil and WAR.PD["牛黄血蝎"][pid] > 0 then
		local tjzx = WAR.PD["牛黄血蝎"][pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("牛黄血蝎:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "牛黄血蝎:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "牛黄血蝎:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	
	--黄莲解毒丸	
	if   WAR.PD["黄连解毒"][pid] ~= nil and WAR.PD["黄连解毒"][pid] > 0 then
		local tjzx = WAR.PD["黄连解毒"][pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("黄连解毒:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "黄连解毒:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "黄连解毒:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	
	--小还丹	
	if   WAR.PD["小还丹"][pid] ~= nil and WAR.PD["小还丹"][pid] > 0 then
		local tjzx = WAR.PD["小还丹"][pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("小还丹:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "小还丹:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "小还丹:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	
	--天香续命膏	
	if   WAR.PD["天香续命"][pid] ~= nil and WAR.PD["天香续命"][pid] > 0 then
		local tjzx = WAR.PD["天香续命"][pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("天香续命:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "天香续命:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "天香续命:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	
	--白云熊胆	
	if   WAR.PD["白云熊胆"][pid] ~= nil and WAR.PD["白云熊胆"][pid] > 0 then
		local tjzx = WAR.PD["白云熊胆"][pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("白云熊胆:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "白云熊胆:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "白云熊胆:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	--五宝花蜜酒	
	if   WAR.PD["五宝花蜜酒"][pid] ~= nil and WAR.PD["五宝花蜜酒"][pid] > 0 then
		local tjzx = WAR.PD["五宝花蜜酒"][pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("五宝花蜜酒:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "五宝花蜜酒:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)		
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "五宝花蜜酒:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	--即墨老酒	
	if   WAR.PD["即墨老酒"][pid] ~= nil and WAR.PD["即墨老酒"][pid] > 0 then
		local tjzx = WAR.PD["即墨老酒"][pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("即墨老酒:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "即墨老酒:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)		
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "即墨老酒:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	
	--玉露酒	
	if   WAR.PD["玉露酒"][pid] ~= nil and WAR.PD["玉露酒"][pid] > 0 then
		local tjzx = WAR.PD["玉露酒"][pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("玉露酒:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "玉露酒:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "玉露酒:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	--梨花酒	
	if  WAR.PD["梨花酒"][pid] ~= nil and WAR.PD["梨花酒"][pid] > 0 then
		local tjzx = WAR.PD["梨花酒"][pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 136 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("梨花酒:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "梨花酒:"..tjzx, C_WHITE, size)				
		else
			lib.LoadPNG(98, 136 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)	
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "梨花酒:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end			
	--诸法无我	
	if   WAR.PD["诸法无我"][pid] ~= nil and WAR.PD["诸法无我"][pid] > 0 then
		local tjzx = WAR.PD["诸法无我"][pid] or 0

		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 98 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("诸法无我:"..tjzx.."层")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "诸法无我:"..tjzx.."层", C_WHITE, size)				
		else
			lib.LoadPNG(98, 98 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "诸法无我:"..tjzx.."层", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
		--皆
	if WAR.PD["皆"][pid] ~= nil and WAR.PD["皆"][pid] > 0 then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 134 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("智拳印:必击中破绽")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "智拳印:必击中破绽", C_WHITE, size)
		else
			lib.LoadPNG(98, 134 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "智拳印:必击中破绽", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end			
		--前
	if WAR.PD["前"][pid] ~= nil and WAR.PD["前"][pid] > 0 then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 133 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("宝瓶印:攻击范围扩大")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "宝瓶印:攻击范围扩大", C_WHITE, size)
		else
			lib.LoadPNG(98, 133 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "宝瓶印:攻击范围扩大", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
		--在
	if WAR.PD["在"][pid] ~= nil and WAR.PD["在"][pid] > 0 then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 132 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("日轮印:攻击必灼烧")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "日轮印:攻击必灼烧", C_WHITE, size)
		else
			lib.LoadPNG(98, 132 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "日轮印:攻击必灼烧", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	
		--阵
	if WAR.PD["阵"][pid] ~= nil and WAR.PD["阵"][pid] > 0 then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 131 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("内缚印:击中目标内力-200")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,  "内缚印:击中目标内力-200", C_WHITE, size)
		else
			lib.LoadPNG(98, 131 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "内缚印:击中目标内力-200", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
		--列
	if WAR.PD["列"][pid] ~= nil and WAR.PD["列"][pid] > 0 then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 130 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("外缚印:击中移动-3")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "外缚印:击中移动-3", C_WHITE, size)
		else
			lib.LoadPNG(98, 130 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "外缚印:击中移动-3", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
		--者
	if WAR.PD["者"][pid] ~= nil and WAR.PD["者"][pid] > 0 then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 129 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("内狮子印:气防提升500")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "内狮子印:气防提升500", C_WHITE, size)
		else
			lib.LoadPNG(98, 129 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "内狮子印:气防提升500", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
		--斗
	if WAR.PD["斗"][pid] ~= nil and WAR.PD["斗"][pid] > 0 then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 128 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("外狮子印:气攻提升500")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,  "外狮子印:气攻提升500", C_WHITE, size)
		else
			lib.LoadPNG(98, 128 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "外狮子印:气攻提升500", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
		--兵
	if WAR.PD["兵"][pid] ~= nil and WAR.PD["兵"][pid] > 0 then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 127 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("大金刚轮印:破防40%")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,  "大金刚轮印:破防40%", C_WHITE, size)
		else
			lib.LoadPNG(98, 127 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "大金刚轮印:破防40%", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
		--临
	if WAR.PD["临"][pid] ~= nil and WAR.PD["临"][pid] > 0 then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 126 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("不动根本印:减伤50点")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "不动根本印:减伤50点", C_WHITE, size)
		else
			lib.LoadPNG(98, 126 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "不动根本印:减伤50点", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
    
		--天人合一
	if WAR.PD["西瓜刀·天人"][pid] ~= nil and WAR.PD["西瓜刀·天人"][pid] > 0 then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 49 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("天人合一")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "天人合一", C_WHITE, size)
		else
			lib.LoadPNG(98, 49 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "天人合一", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
    
	--西瓜残刀
	if WAR.PD["西瓜刀·残刀"][pid] ~= nil then
        local cs = 0
        local sx = 0
        if WAR.PD["西瓜刀·残刀"][pid][1] ~= nil then 
            cs = WAR.PD["西瓜刀·残刀"][pid][1]..'层'
        end
        if WAR.PD["西瓜刀·残刀"][pid][2] ~= nil then 
            sx = WAR.PD["西瓜刀·残刀"][pid][2]..'时序'
        end
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 135 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("天残地缺:"..cs..sx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,"天残地缺:"..cs..sx, C_GOLD, size)
		else
			lib.LoadPNG(98, 135 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "天残地缺:"..cs..sx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    
	--血战八方
	if WAR.XZBFZT[pid] ~= nil and WAR.XZBFZT[pid] > 0  then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 107 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
			 DrawString(CC.ScreenW/936*705-string.len("血战八方:" .. WAR.XZBFZT[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "血战八方:"..WAR.XZBFZT[pid], C_WHITE, size)
		else
			lib.LoadPNG(98, 107 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "血战八方:" .. WAR.XZBFZT[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--止杀CD	
	if  match_ID(pid, 68) and WAR.JSZT1[pid] ~= nil then
	local tjzx = WAR.JSZT1[pid] or 0
		if tjzx == 0 then
			if WAR.Person[id]["我方"] == true then
				lib.LoadPNG(98, 58 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("止杀CD:"..tjzx.."回合")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "止杀CD:"..tjzx.."回合", C_WHITE, size)
			else
				lib.LoadPNG(98, 58 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "止杀可使用", C_WHITE, size)
			end
		else
			if WAR.Person[id]["我方"] == true then
				lib.LoadPNG(98, 57 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
				DrawString(CC.ScreenW/936*550, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "止杀CD:"..tjzx.."回合", C_WHITE, size)
				 DrawString(CC.ScreenW/936*705-string.len("止杀CD:"..tjzx.."回合")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "止杀CD:"..tjzx.."回合", C_WHITE, size)
			else
				lib.LoadPNG(98, 57 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num,"止杀可使用", C_WHITE, size)
			end
		end
		zt_num = zt_num + 1
	end	
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
			--文泰来计时CD倒计时冷确计算
	if  match_ID(pid, 151) and WAR.WTL_1[pid] ~= nil then
	        local tjzx = WAR.WTL_1[pid] or 0
		    if tjzx == 0 then
				if WAR.Person[id]["我方"] == true then
					lib.LoadPNG(98, 125 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )			
					 DrawString(CC.ScreenW/936*705-string.len("否极泰来CD:"..tjzx.."时序")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "否极泰来CD:"..tjzx.."时序", C_WHITE, size)
				else
					lib.LoadPNG(98, 6 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
					DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "否极泰来激活", C_WHITE, size)
				end
			else
				if WAR.Person[id]["我方"] == true then
					lib.LoadPNG(98, 125 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				  DrawString(CC.ScreenW/936*705-string.len("否极泰来CD:"..tjzx.."时序")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "否极泰来CD:"..tjzx.."时序", C_WHITE, size)
				else
					lib.LoadPNG(98, 8 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
					DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num,"否极泰来CD:"..tjzx.."时序", C_WHITE, size)
				end
			end
			zt_num = zt_num + 1
	end	
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--重生显示
	if WAR.FUHUOZT[pid]~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 1 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2)
         DrawString(CC.ScreenW/936*705-string.len("已复活")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "已复活", C_WHITE, size)			
		else
			lib.LoadPNG(98, 1 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3, "已复活", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--万佛朝宗显示
	if match_ID(pid, 577) then
		local tjzx = WAR.WFCZ[pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 25 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("万佛朝宗:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "万佛朝宗:"..tjzx, C_GOLD, size)	
		else
			lib.LoadPNG(98, 25 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "万佛朝宗:"..tjzx, C_GOLD , size)
		end
		zt_num = zt_num + 1
	end	
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--太极之形显示
	if Curr_NG(pid, 171) then
		local tjzx = WAR.TJZX[pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 2 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("太极之形:"..tjzx)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "太极之形:"..tjzx, C_GOLD, size)
		else
			lib.LoadPNG(98, 2 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "太极之形:"..tjzx, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--曲风显示
	if match_ID(pid, 586) then
		local qf = WAR.HZD_QF[pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 70 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )			
           DrawString(CC.ScreenW/936*705-string.len("曲风:"..qf)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "曲风:"..qf, C_GOLD, size)			
		else
			lib.LoadPNG(98, 70 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "曲风:"..qf, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	
	--迷踪步显示
	if pid == 0 and JY.Person[615]["论剑奖励"] == 1 then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 3 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
           DrawString(CC.ScreenW/936*705-string.len("迷踪步开启")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "迷踪步开启", C_GOLD, size)			
		else
			lib.LoadPNG(98, 3 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "迷踪步开启", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end


	
	--岳灵珊，慧中灵剑显示
	if match_ID(pid, 79) then
		local JF = 0
		for i = 1, JY.Base["武功数量"] do
			if JY.Wugong[JY.Person[pid]["武功" .. i]]["武功类型"] == 3 then
				JF = JF + 1
			end
		end
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 4 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("慧中灵剑:"..JF)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "慧中灵剑:"..JF, C_GOLD, size)
		else
			lib.LoadPNG(98, 4 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "慧中灵剑:"..JF, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--剑胆琴心显示
	if JiandanQX(pid) then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 5 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("剑胆琴心")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "剑胆琴心", C_GOLD, size)
		else
			lib.LoadPNG(98, 5 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "剑胆琴心", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--无明业火显示	
	if WAR.WMYH[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 6 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("无明业火:"..WAR.WMYH[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "无明业火:"..WAR.WMYH[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 6 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "无明业火:"..WAR.WMYH[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--王重阳1 同归剑法	
	if WAR.TGJF[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 6 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("同归")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "同归", C_GOLD, size)
		else
			lib.LoadPNG(98, 6 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "同归", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--天衣无缝显示
	if TianYiWF(pid) then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 7 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("天衣无缝")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "天衣无缝", C_GOLD, size)
		else
			lib.LoadPNG(98, 7 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "天衣无缝", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--武穆遗书
	if WAR.WMYS[pid]~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 109 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
	        DrawString(CC.ScreenW/936*705-string.len("武穆遗书")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "武穆遗书", C_GOLD, size)			
		else
			lib.LoadPNG(98, 109 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "武穆遗书", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--无酒不欢：举火燎原，金乌+燃木+火焰刀，造成引燃效果
	if WAR.JHLY[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 8 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("引燃状态:"..WAR.JHLY[pid].."时序")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "引燃状态:"..WAR.JHLY[pid].."时序", C_GOLD, size)			
		else
			lib.LoadPNG(98, 8 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "引燃状态:"..WAR.JHLY[pid].."时序", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--无酒不欢：利刃寒锋，修罗+阴风+沧溟，造成冻结效果
	if WAR.LRHF[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 9 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("冻结状态:"..WAR.LRHF[pid].."时序")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,"冻结状态:"..WAR.LRHF[pid].."时序", C_GOLD, size)
		else
			lib.LoadPNG(98, 9 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "冻结状态:"..WAR.LRHF[pid].."时序", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--无酒不欢：被死战锁定的目标
	if pid == WAR.SZSD then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 10 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("死战目标")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "死战目标", C_GOLD, size)
		else
			lib.LoadPNG(98, 10 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "死战目标", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--无酒不欢：金轮 十龙十象状态
	if WAR.SLSX[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 11 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("十龙十象")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "十龙十象", C_GOLD, size)
		else
			lib.LoadPNG(98, 11 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "十龙十象", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--无酒不欢：昏迷状态
	if WAR.HMZT[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 12 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("昏迷状态")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "昏迷状态", C_GOLD, size)
		else
			lib.LoadPNG(98, 12 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "昏迷状态", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--无酒不欢：阿紫曼珠沙华
	if match_ID(pid, 47) then
		local tjzx = WAR.TJZX[pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 13 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
            DrawString(CC.ScreenW/936*705-string.len("曼珠沙华:" .. WAR.MZSH)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "曼珠沙华:" .. WAR.MZSH, C_GOLD, size)
		else
			lib.LoadPNG(98, 13 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "曼珠沙华:" .. WAR.MZSH, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--太极蓄力
	if WAR.PD["太极蓄力"][pid]~= nil and WAR.PD["太极蓄力"][pid] > 0 then	
		local tjzx = WAR.PD["太极蓄力"][pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 104 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("太极蓄力值:" .. WAR.PD["太极蓄力"][pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "太极蓄力值:" .. WAR.PD["太极蓄力"][pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 104 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "太极蓄力值:" .. WAR.PD["太极蓄力"][pid], C_WHITE, size*0.8)
		end
		zt_num = zt_num + 1
	end	
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--蛤蟆功蓄力
	if WAR.PD["蛤蟆蓄力"][pid]~= nil and WAR.PD["蛤蟆蓄力"][pid] > 0 then	
		local tjzx = WAR.PD["蛤蟆蓄力"][pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 95 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("蛤蟆蓄力值:" .. WAR.PD["蛤蟆蓄力"][pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "蛤蟆蓄力值:" .. WAR.PD["蛤蟆蓄力"][pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 95 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "蛤蟆蓄力值:" .. WAR.PD["蛤蟆蓄力"][pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--鲸息功蓄力
	if WAR.PD["鲸息蓄力"][pid]~= nil and WAR.PD["鲸息蓄力"][pid] > 0 then	
		local tjzx = WAR.PD["鲸息蓄力"][pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 89 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("鲸息蓄力值:" .. WAR.PD["鲸息蓄力"][pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "鲸息蓄力值:" .. WAR.PD["鲸息蓄力"][pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 89 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "鲸息蓄力值:" .. WAR.PD["鲸息蓄力"][pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--无酒不欢：阿紫禁药状态
	if WAR.JYZT[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 14 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("禁药状态")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "禁药状态", C_GOLD, size)
		else
			lib.LoadPNG(98, 14 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "禁药状态", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--无酒不欢：沉睡状态
	if WAR.CSZT[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 15 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("沉睡状态")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "沉睡状态", C_GOLD, size)
		else
			lib.LoadPNG(98, 15 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "沉睡状态", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--无酒不欢：灭绝的玉石俱焚
	if WAR.YSJF[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 16 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("玉石俱焚:" .. WAR.YSJF[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "玉石俱焚:" .. WAR.YSJF[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 16 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "玉石俱焚:" .. WAR.YSJF[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--无酒不欢：混乱状态
	if WAR.HLZT[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 18 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("混乱状态:" .. WAR.HLZT[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "混乱状态:" .. WAR.HLZT[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 18 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "混乱状态:" .. WAR.HLZT[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--散功状态
	if WAR.SGZT[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 17 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("散功状态:" .. WAR.SGZT[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "散功状态:" .. WAR.SGZT[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 17 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "散功状态:" .. WAR.SGZT[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	--[[天仙锁魂状态
	if WAR.TXSH[pid] ~= nil  then
			if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 22 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("锁魂状态")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "锁魂状态", C_GOLD, size)
		else
			lib.LoadPNG(98, 22 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "锁魂状态", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	]]
    
	--雷音状态
	if WAR.WTL_LDJT[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 116 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("雷音" .. WAR.WTL_LDJT[pid].."层")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "雷音" .. WAR.WTL_LDJT[pid].."层", C_GOLD, size)
		else
			lib.LoadPNG(98, 116 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "雷音" .. WAR.WTL_LDJT[pid].."层", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--辰宿列张 参合效果状态
	if WAR.MRSHZT[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 116 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("参合" .. WAR.MRSHZT[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "参合" .. WAR.MRSHZT[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 116 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "参合" .. WAR.MRSHZT[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	--无酒不欢：琴音状态
	if WAR.QYZT[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 19 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("琴音" .. WAR.QYZT[pid].."层")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "琴音" .. WAR.QYZT[pid].."层", C_GOLD, size)
		else
			lib.LoadPNG(98, 19 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "琴音" .. WAR.QYZT[pid].."层", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--止杀状态
	if WAR.YYZS[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 58 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("剑胆琴心")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "止杀状态", C_GOLD, size)
		else
			lib.LoadPNG(98, 58 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "止杀状态:" .. WAR.YYZS[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	--霍青桐指令状态
	if WAR.HQT_ZL[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 117 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("号令三军:" .. WAR.HQT_ZL[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "号令三军:" .. WAR.HQT_ZL[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 117 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "号令三军:" .. WAR.HQT_ZL[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	--梅长苏偷天换日
	if WAR.PD["偷天换日"][pid] ~= nil  then
	 if  WAR.PD["偷天换日"][pid] >= 100  then
			if WAR.Person[id]["我方"] == true then
				lib.LoadPNG(98, 85 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("偷天换日")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "偷天换日", C_GOLD, size)
			else
				lib.LoadPNG(98, 85 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "偷天换日", C_WHITE, size)
			end
		   else
			if WAR.Person[id]["我方"] == true then
				lib.LoadPNG(98, 66 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("火寒毒发作:" .. WAR.PD["偷天换日"][pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "火寒毒发作:" .. WAR.PD["偷天换日"][pid], C_GOLD, size)
			else
				lib.LoadPNG(98, 66 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num,"火寒毒发作:" .. WAR.PD["偷天换日"][pid], C_WHITE, size)
			end
			end
		zt_num = zt_num + 1
	end		
	--大周天回复 养生主
	if WAR.ZTHF[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 110 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len( "养生主:" .. WAR.ZTHF[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,  "养生主:" .. WAR.ZTHF[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 110 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "养生主:" .. WAR.ZTHF[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--无酒不欢：虚弱状态
	if WAR.XRZT[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 20 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("虚弱状态:" .. WAR.XRZT[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "虚弱状态:" .. WAR.XRZT[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 20 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "虚弱状态:" .. WAR.XRZT[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    --yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--虚弱状态1
	if WAR.XRZT1[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 20 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("虚弱状态:" .. WAR.XRZT1[pid].."回合")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "虚弱状态:" .. WAR.XRZT1[pid].."回合", C_GOLD, size)
		else
			lib.LoadPNG(98, 20 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "虚弱状态:" .. WAR.XRZT1[pid].."回合", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--放下屠刀
	if WAR.PD["放下屠刀"][pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 20 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("伤害降低:" .. WAR.PD["放下屠刀"][pid].."回合")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "伤害降低:" .. WAR.PD["放下屠刀"][pid].."回合", C_GOLD, size)
		else
			lib.LoadPNG(98, 20 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "伤害降低:" .. WAR.PD["放下屠刀"][pid].."回合", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	--魅惑状态
	if WAR.MHZT[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 40 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("魅惑状态:" .. WAR.MHZT[pid].."回合")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "魅惑状态:" .. WAR.MHZT[pid].."回合", C_GOLD, size)
		else
			lib.LoadPNG(98, 40 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "魅惑状态:" .. WAR.MHZT[pid].."回合", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end		
	--无酒不欢：倾国状态
	if WAR.QGZT[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 21 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("倾国剩余" .. WAR.QGZT[pid].."次")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "倾国剩余" .. WAR.QGZT[pid].."次", C_GOLD, size)
		else
			lib.LoadPNG(98, 21 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "倾国剩余" .. WAR.QGZT[pid].."次", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--无酒不欢：盲目状态
	if WAR.KHCM[pid] == 2 then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 22 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("盲目状态")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "盲目状态", C_GOLD, size)
		else
			lib.LoadPNG(98, 22 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "盲目状态", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
		
	--无酒不欢：其疾如风
	--if WAR.FLHS1 == 1 and match_ID(pid,27) and WAR.ZDDH == 348  then
	if WAR.PD['疾如风'][pid] == 1 then	
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 24 * 2 ,  CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("其疾如风")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "其疾如风", C_GOLD, size)
		else
			lib.LoadPNG(98, 24 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "其疾如风", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	
--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
 if WAR.SSESS[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 25 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("一合相:" .. WAR.SSESS[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "一合相:" .. WAR.SSESS[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 25 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "一合相:" .. WAR.SSESS[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--陆渐金刚法相
   if WAR.JGFX[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 11 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("金刚法相:" .. WAR.JGFX[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,"金刚法相:" .. WAR.JGFX[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 11 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "金刚法相:" .. WAR.JGFX[pid], C_WHITE, size)
		end
				zt_num = zt_num + 1
	end
	--李寻欢 蜻蜓三抄水
	if match_ID(pid,498) then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 3 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("蜻蜓三抄水开启")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "蜻蜓三抄水开启", C_GOLD, size)
		else
			lib.LoadPNG(98, 3 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "蜻蜓三抄水开启", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
		--李寻欢 小李飞刀
	if WAR.XLFD[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 26 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("例不虚发:" .. WAR.XLFD[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "例不虚发:" .. WAR.XLFD[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 26 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "例不虚发:" .. WAR.XLFD[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
		--萧秋水 天剑BUFF
	if WAR.JTYJ[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 55 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len( "天剑:" .. WAR.JTYJ[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num,  "天剑:" .. WAR.JTYJ[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 55 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "天剑:" .. WAR.JTYJ[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end				
	
	--集中状态
	if WAR.Focus[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 14 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("心念合一")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "心念合一", C_GOLD, size)
		else
			lib.LoadPNG(98, 14 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "心念合一", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end

	--泰山十八盘，峻岭横空
	if WAR.TSSB[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 27 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("峻岭横空:"..WAR.TSSB[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "峻岭横空:"..WAR.TSSB[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 27 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "峻岭横空:"..WAR.TSSB[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end

	--青莲剑仙，深藏身与名
	if WAR.QLJX[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 52 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("深藏身与名:"..WAR.QLJX[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "深藏身与名:"..WAR.QLJX[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 52 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "深藏身与名:"..WAR.QLJX[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	
		--长生回天 回复
	if WAR.CSHF[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 14 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("长生回天:"..WAR.CSHF[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "长生回天:"..WAR.CSHF[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 14 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "长生回天:"..WAR.CSHF[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end

		--长生回天 回复
	if WAR.PD['长生诀'][pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 67 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("顾道长生:"..WAR.PD['长生诀'][pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "长生回天:"..WAR.PD['长生诀'][pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 67 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "顾道长生:"..WAR.PD['长生诀'][pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
    
	--逍遥御风
	if XiaoYaoYF(pid) then
		local count = WAR.XYYF[pid] or 0
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 28 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("逍遥御风:"..count)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "逍遥御风:"..count, C_GOLD, size)
		else
			lib.LoadPNG(98, 28 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "逍遥御风:"..count, C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--yctb = {WAR.KHCM,WAR.CHZT,WAR.SZZT,WAR.YYZS,WAR.WMYH,WAR.FXDS,WAR.XRZT,WAR.SGZT,WAR.CHZT,WAR.HLZT,WAR.PJZT,WAR.TGJF}
	--麻痹状态
	if WAR.MBJZ[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 29 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("麻痹：移动-"..WAR.MBJZ[pid])/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "麻痹：移动-"..WAR.MBJZ[pid], C_GOLD, size)
		else
			lib.LoadPNG(98, 29 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "麻痹：移动-"..WAR.MBJZ[pid], C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--锁足状态
	if WAR.SZZT[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 29 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("锁足状态")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "锁足状态", C_GOLD, size)
		else
			lib.LoadPNG(98, 29 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "锁足状态", C_WHITE, size)
				end	
		zt_num = zt_num + 1
	end	
		--迟缓状态
	if WAR.CHZT[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 64 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("迟缓" .. WAR.CHZT[pid].."层")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "迟缓" .. WAR.CHZT[pid].."层", C_GOLD, size)
		else
			lib.LoadPNG(98, 64 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "迟缓" .. WAR.CHZT[pid].."层", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end
	--疾风集气状态
	if WAR.JFJQ[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 47 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("疾风" .. WAR.JFJQ[pid].."层")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "疾风" .. WAR.JFJQ[pid].."层", C_GOLD, size)
		else
			lib.LoadPNG(98, 47 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "疾风" .. WAR.JFJQ[pid].."层", C_WHITE, size)
		end
		zt_num = zt_num + 1
	end	
	--霸体状态
	if WAR.BTZT[pid] ~= nil then
		if WAR.Person[id]["我方"] == true then
			lib.LoadPNG(98, 8 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
			DrawString(CC.ScreenW/936*705-string.len("霸体状态")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "霸体状态", C_GOLD, size)
		else
			lib.LoadPNG(98, 8 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
			DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "霸体状态", C_WHITE, size)
				end	
		zt_num = zt_num + 1
	end	
	--张家辉的隐身戒指
	if JY.Person[pid]["防具"] == 304 then
		if WAR.YSJZ == 0 then
			if WAR.Person[id]["我方"] == true then
				lib.LoadPNG(98, 30 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("隐匿中……")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "隐匿中……", C_GOLD, size)
			else
				lib.LoadPNG(98, 30 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "隐匿中……", C_WHITE, size)
			end
		else
			if WAR.Person[id]["我方"] == true then
				lib.LoadPNG(98, 31 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("下次隐匿:"..WAR.YSJZ)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "下次隐匿:"..WAR.YSJZ, C_GOLD, size)
			else
				lib.LoadPNG(98, 31 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "下次隐匿:"..WAR.YSJZ, C_WHITE, size)
			end
		end
		zt_num = zt_num + 1
	end
	--中庸内置CD
	if ZhongYongZD(pid) then
        local cd = WAR.PD['中庸'][pid] or 0
        local mcd = limitX(JY.Person[pid]['资质'] - 1,30) - cd

        --if cd == 0  then
            --[[
			if WAR.Person[id]["我方"] == true then
				lib.LoadPNG(98, 124 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("中庸可用")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "中庸可用", C_GOLD, size)
			else
				lib.LoadPNG(98, 124 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "中庸可用", C_WHITE, size)
			end
		else
            ]]
			if WAR.Person[id]["我方"] == true then
				lib.LoadPNG(98, 124 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("中庸CD:"..mcd)/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "中庸CD:"..mcd, C_GOLD, size)
			else
				lib.LoadPNG(98, 124 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "中庸CD:"..mcd, C_WHITE, size)
			end
		--end
		zt_num = zt_num + 1
	end
	--指挥CD
	if  match_ID(pid,74) then
	 if  WAR.HQT_CD == 0  then
			if WAR.Person[id]["我方"] == true then
				lib.LoadPNG(98, 118 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("指挥可使用")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "指挥可使用", C_GOLD, size)
			else
				lib.LoadPNG(98, 118 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num, "指挥可使用", C_WHITE, size)
			end
		   else
			if WAR.Person[id]["我方"] == true then
				lib.LoadPNG(98, 119 * 2 , CC.ScreenW/936*737, CC.ScreenH/702*667 -(size*2+CC.RowPixel*2)*zt_num, 2 )
				DrawString(CC.ScreenW/936*705-string.len("指挥CD:"..WAR.HQT_CD.."时序")/2*size, CC.ScreenH - size - CC.RowPixel*3 + 1 - (size*2+CC.RowPixel*2)*zt_num, "指挥CD:"..WAR.HQT_CD.."时序", C_GOLD, size)
			else
				lib.LoadPNG(98, 119 * 2 , x1 + width + CC.RowPixel, CC.RowPixel + 3 + (size*2+CC.RowPixel*2)*zt_num, 1)
				DrawString(x1 + width + size*2 + CC.RowPixel*3, size + 3 + (size*2+CC.RowPixel*2)*zt_num,"指挥CD:"..WAR.HQT_CD.."时序", C_WHITE, size)
			end
			end
		zt_num = zt_num + 1
	end		
	--------------------------------------------------------------------------------------------------------------------------

	local headw, headh = lib.GetPNGXY(1, p["半身像"])
	local headx = (width - headw) / 2
	local heady = (CC.ScreenH/5 - headh) / 2
	--头像信息
	local headid = JY.Person[pid]["半身像"]
	if WAR.Person[id]["我方"] then
        lib.LoadPNG(1, headid*2, CC.ScreenW/936*849,CC.ScreenH/702*421, 2)
	else
        lib.LoadPNG(1, headid*2, CC.ScreenW/936*99,CC.ScreenH/702*73, 2)
    end
	x1 = x1 + CC.RowPixel
	y1 = y1 + CC.RowPixel + CC.ScreenH/6 - 12
	local color = nil
	if p["受伤程度"] < p["中毒程度"] then
		if p["中毒程度"] == 0 then
			color = RGB(252, 148, 16)
		elseif p["中毒程度"] < 50 then
			color = RGB(120, 208, 88)
		else
			color = RGB(56, 136, 36)
		end
	elseif p["受伤程度"] < 33 then
		color = RGB(236, 200, 40)
	elseif p["受伤程度"] < 66 then
		color = RGB(244, 128, 32)
	else
		color = RGB(232, 32, 44)
	end
	local yy1 = y1 + CC.RowPixel + CC.ScreenH/15 - 100
	local zi = {}
	local name = p["姓名"]
    local namelen  = string.len(name) / 2	
	for i = 1,namelen do
		zi[i] = string.sub(name, i * 2 - 1, i * 2)
		DrawString(x1, yy1+12-100, zi[i], color, CC.DefaultFont*0.9)
		yy1 = yy1 + CC.DefaultFont*0.9
	end
	--有运功时的显示
	local ayy1 = y1 + CC.RowPixel + CC.ScreenH/10 +CC.DefaultFont-8
	if p["主运内功"] > 0 then
		--DrawString(x1 + 8, y1 + CC.RowPixel + CC.DefaultFont, "运功", MilkWhite, size)
		DrawString(x1+50, ayy1-47-CC.DefaultFont*2,JY.Wugong[p["主运内功"]]["名称"], TG_Red_Bright, CC.DefaultFont*0.7)
		else
		DrawString(x1+50, ayy1-47-CC.DefaultFont*2,"无", TG_Red_Bright, CC.DefaultFont*0.7)
	--end		
end	
	--有轻功时的显示
	local ayy2 =y1 + CC.RowPixel + CC.ScreenH/10 +CC.DefaultFont-5
	if p["主运轻功"] > 0 then
	DrawString(x1+50, ayy2-30-CC.DefaultFont*2, JY.Wugong[p["主运轻功"]]["名称"], M_DeepSkyBlue, CC.DefaultFont*0.7)
	else
	DrawString(x1+50, ayy2-30-CC.DefaultFont*2, "无", M_DeepSkyBlue, CC.DefaultFont*0.7)
	

  end	
	--颜色条
	local pcx = x1 + 3 - CC.RowPixel + 2;
	local pcy = y1 + CC.RowPixel +1+30
    local pcx1 = x1 + 3 - CC.RowPixel + 2+9;	
	--生命条
	lib.LoadPNG(91, 35 * 2 , pcx  , pcy, 1)
	local pcw, pch = lib.GetPNGXY(91, 31 * 2);  
	lib.SetClip(pcx1, pcy, pcx1 + (p["生命"]/p["生命最大值"])*(pcw-10), pcy + pch)
	lib.LoadPNG(91, 31 * 2 , pcx  , pcy, 1)
	pcy = pcy + CC.RowPixel + size -2
	lib.SetClip(0,0,0,0)
  
	--内力条
	lib.LoadPNG(91, 35 * 2 , pcx  , pcy, 1)
	local pcw, pch = lib.GetPNGXY(91, 32 * 2);
	lib.SetClip(pcx1, pcy, pcx1+ (p["内力"]/p["内力最大值"])*(pcw-18), pcy+ pch)
	lib.LoadPNG(91, 32 * 2 , pcx  , pcy, 1)
	pcy = pcy + CC.RowPixel + size -2
	lib.SetClip(0,0,0,0)
  
	--体力条
	lib.LoadPNG(91, 35 * 2 , pcx  , pcy, 1)
	local pcw, pch = lib.GetPNGXY(91, 34 * 2);
	lib.SetClip(pcx, pcy, pcx + (p["体力"]/100)*(pcw-10), pcy + pch)
	lib.LoadPNG(91, 34 * 2 , pcx  , pcy, 1)
	pcy = pcy + CC.RowPixel + size -2
	lib.SetClip(0,0,0,0)
  
	local lifexs = "命 "..p["生命"]
	local nlxs = "内 "..p["内力"]
	local tlxs = "体 "..p["体力"]
	local lqzxs = WAR.LQZ[pid] or 0;	--怒气
	local zdxs = p["中毒程度"]
  
	local nsxs = p["受伤程度"];		--内伤
	local bfxs = p["冰封程度"];		--冰封
	local zsxs = p["灼烧程度"];		--灼烧
	local fxxs = WAR.FXDS[pid] or 0;		--封穴
	local lxxs = WAR.LXZT[pid] or 0;		--流血
  
	DrawString(x1 + 9, y1 + CC.RowPixel + 6+29, lifexs, M_White, CC.FontSMALL)
	DrawString(x1 + 9, y1 + CC.RowPixel + size + 11+29, nlxs, M_White, CC.FontSMALL)
	DrawString(x1 + 9, y1 + CC.RowPixel + 2*size + 16+29, tlxs, M_White, CC.FontSMALL)

	y1 = y1 + 3*(CC.RowPixel + size) + 4
  	
  	local myx1 = 3;
  	local myy1 = 28;
	--怒气
	--DrawString(x1 + myx1, y1 + myy1, "怒气", C_RED, size)
	if lqzxs == 100 then
		lqzxs = "极"
	end
	DrawString(x1 + myx1 + size*2 + 10, y1 + myy1, lqzxs, C_RED, size)
	--如林
	--myx1 = myx1 + size * 4;
	--DrawString(x1 + myx1, y1 + myy1, "如林", M_DeepSkyBlue, size)
	--if pid == 0 then
		--DrawString(x1 + size*5/2 + myx1, y1 + myy1, WAR.FLHS2, M_DeepSkyBlue, size)
	--else
		--DrawString(x1 + size*5/2 + myx1, y1 + myy1, "※", M_DeepSkyBlue, size)
	--end
	--冰封
	myx1 = 3;
	myy1 = myy1 + size + 2;
	DrawString(x1 + myx1 + size*2 + 10, y1 + myy1, bfxs, M_LightBlue, size)
	--灼烧
	myx1 = myx1 + size * 4;
  	DrawString(x1 + size*5/2 + myx1, y1 + myy1, zsxs, C_ORANGE, size)
	--封穴
	myx1 = 3;
	myy1 = myy1 + size + 2;
	if fxxs == 50 then
		fxxs = "极"
	end
	DrawString(x1 + myx1 + size*2 + 10, y1 + myy1, fxxs, C_GOLD, size)
	--流血
	myx1 = myx1 + size * 4;
	if lxxs == 100 then
		lxxs = "极"
	end
  	DrawString(x1 + size*5/2 + myx1, y1 + myy1, lxxs, M_DarkRed, size)
	--内伤
	myx1 = 3;
	myy1 = myy1 + size + 2;
	if nsxs == 100 then
		nsxs = "极"
	end
	DrawString(x1 + myx1 + size*2 + 10, y1 + myy1, nsxs, PinkRed, size)
	--中毒
	myx1 = myx1 + size * 4;
	if zdxs == 100 then
		zdxs = "极"
	end
  	DrawString(x1 + size*5/2 + myx1, y1 + myy1, zdxs, LimeGreen, size)	
	
	if WAR.Person[id]["我方"] == false then
		y1 = y1 + 3*(CC.RowPixel + size) +12
	   lib.LoadPNG(91, 27 * 2 ,x1-6,y1+25, 1)	 
		local hl = 1
		for i = 1, 4 do
			local wp = p["携带物品" .. i]
			local wps = p["携带物品数量" .. i]
			if wp >= 0 then
				local wpm = JY.Thing[wp]["名称"]
				DrawString(x1+2, y1 + hl * (size+CC.RowPixel) , wpm .. wps, C_WHITE, size)
				hl = hl + 1
			end
		end
	end
end

--自动选择合适的武功
function War_AutoSelectWugong()
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	local probability = {}
	local wugongnum = JY.Base["武功数量"]
	for i = 1, JY.Base["武功数量"] do
		local wugongid = JY.Person[pid]["武功" .. i]
		if wugongid > 0 then
			if JY.Wugong[wugongid]["伤害类型"] == 0 then
		  
				--选择杀生命的武功，必须消耗内力比现有内力小，起码可以发出一级的武功。
				if JY.Wugong[wugongid]["消耗内力点数"] <= JY.Person[pid]["内力"] then
					local level = math.modf(JY.Person[pid]["武功等级" .. i] / 100) + 1
					probability[i] = get_skill_power(pid, wugongid, level)	--无酒不欢：采用新公式
				else
					probability[i] = 0
				end
				
				--轻功不可攻击特技不可攻击
				if JY.Wugong[wugongid]["武功类型"] == 7 or wugongid == 85 or wugongid == 87 or wugongid == 88 or wugongid == 144 or wugongid == 175  or wugongid == 182  or wugongid == 199 or wugongid == 43  then
					probability[i] = 0
				end
					
				--内功攻击
				if JY.Wugong[wugongid]["武功类型"] == 6 then
				
					if inteam(pid) == false and i == 1 then 				--NPC会用第一格内功
					
					elseif pid == 0 and JY.Base["畅想"] > 0 and i == 1 then --畅想会用第一格内功
			  
					elseif wugongid == 105 and (match_ID(pid, 36) or match_ID(pid, 27))then		--林平之 东方 使用葵花神功
					
					elseif wugongid == 102 and match_ID_awakened(pid, 38, 1) then		--石破天 使用太玄神功
					elseif wugongid == 106 and match_ID(pid, 638) then		--斗酒僧 九阳神功					
					
					elseif wugongid == 106 and match_ID(pid, 9) then		--张无忌 使用九阳神功
					
					elseif wugongid == 94 and match_ID(pid, 37) then		--狄云 使用神经照
					
					elseif wugongid == 108 and match_ID(pid, 114) then		--扫地 使用易筋经
					
					elseif wugongid == 93 and match_ID(pid, 66) then		--小昭 使用圣火
					
					elseif wugongid == 104 and match_ID(pid, 60) then		--欧阳锋 使用逆运
					
					elseif wugongid == 103 and (match_ID(pid, 39) or match_ID(pid, 40))then		--侠客岛主 使用龙象
						
					elseif (pid == 0 and GetS(4, 5, 5, 5) == 5) or match_ID(pid, 9985)  then		--天罡 游坦之 使用内功
						
					else
						probability[i] = 0
					end
				end

				--斗转星移
				if wugongid == 43 and match_ID(pid, 51) == false then
					probability[i] = 0
				end
				
				--乔峰不用打狗
				if wugongid == 80 and pid == 50 then
					probability[i] = 0
				end
				
				--黄药师不用玉萧落英
				if (wugongid == 12 or wugongid == 38) and pid == 57 then
					probability[i] = 0
				end
				
				--周伯通不用太极拳
				if wugongid == 16 and pid == 64 then
					probability[i] = 0
				end
				
				--二十大欧阳锋不用逆运蛤蟆
				if (wugongid == 95 or wugongid == 104) and pid == 60 and WAR.ZDDH == 289 then
					probability[i] = 0
				end
					
				--襄阳金轮不用龙象
				--神邪战三绝不用龙象
				--二十大不用龙象
				if wugongid == 103 and pid == 62 and (WAR.ZDDH == 275 or WAR.ZDDH == 277 or WAR.ZDDH == 289) then
					probability[i] = 0
				end
				
				--刀剑归真胡一刀不用苗剑
				if wugongid == 44 and pid == 633 and WAR.ZDDH == 280 then
					probability[i] = 0
				end
				
				--刀剑合璧苗人凤不用胡刀
				if wugongid == 67 and pid == 3 and WAR.ZDDH == 280 then
					probability[i] = 0
				end
				
				--左冷禅不用其他几个五岳剑法
				if pid == 22 and (wugongid == 30 or wugongid == 31 or wugongid == 32 or wugongid == 34) then
					probability[i] = 0
				end
			else
				probability[i] = 0		 --自动不会杀内力
			end
		else
			wugongnum = i - 1
			break;
		end
	end
  
	if wugongnum ==  0 then			--如果没有武功，直接返回-1
		return -1;
	end

	local maxoffense = 0			--计算最大攻击力
	for i = 1, wugongnum do
		if maxoffense < probability[i] then
			maxoffense = probability[i]
		end
	end
	
	local mynum = 0					--计算我方和敌人个数
	local enemynum = 0
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["死亡"] == false then
			if WAR.Person[i]["我方"] == WAR.Person[WAR.CurID]["我方"] then
				mynum = mynum + 1
			else
				enemynum = enemynum + 1
			end
		end
	end
	
	
	local factor = 0			--敌人人数影响因子，敌人多则对线面等攻击多人武功的选择概率增加
	if mynum < enemynum then
		factor = 2
	else
		factor = 1
	end
	
	for i = 1, wugongnum do		--考虑其他概率效果
		local wugongid = JY.Person[pid]["武功" .. i]
		if probability[i] > 0 then
			if probability[i] < maxoffense*3/4 then		--去掉攻击力小的武功
				probability[i] = 0
			else
				local level = math.modf(JY.Person[pid]["武功等级" .. i] / 100) + 1
				probability[i] = probability[i] + JY.Wugong[wugongid]["移动范围".. level]  * factor*10
				if JY.Wugong[wugongid]["杀伤范围" .. level] > 0 then
					probability[i] = probability[i] + JY.Wugong[wugongid]["杀伤范围" .. level]* factor*10
				end
			end
		end
	end
	
	local s = {}			--按照概率依次累加
	local maxnum = 0
	for i = 1, wugongnum do
		s[i] = maxnum
		maxnum = maxnum + probability[i]
	end
	s[wugongnum + 1] = maxnum
	if maxnum == 0 then		--没有可以选择的武功
		return -1
	end
	
	local v = Rnd(maxnum)		--产生随机数
	local selectid = 0
	for i = 1, wugongnum do		--根据产生的随机数，寻找落在哪个武功区间
		if s[i] <= v and v < s[i + 1] then
			selectid = i
		end
	end
	return selectid
end

--战斗武功选择菜单
--sb star为无意义参数，仅为防止代码语法错误跳出
function War_FightMenu(sb, star, wgnum)
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	local numwugong = 0
	local menu = {}
	local canuse = {}
	local c = 0;
	for i = 1, JY.Base["武功数量"] do
		local tmp = JY.Person[pid]["武功" .. i]
		if tmp > 0 then
			menu[i] = {JY.Wugong[tmp]["名称"], nil, 1}
	
			--内功无法攻击
			--游坦之可以
			if match_ID(pid, 48) == false and JY.Wugong[tmp]["武功类型"] == 6 then
				menu[i][3] = 0
			end
			
			--轻功无法攻击
			if JY.Wugong[tmp]["武功类型"] == 7  or 
           (tmp == 85 or tmp == 87 or tmp == 88 or tmp == 144 or tmp == 175  or tmp == 182  or tmp == 199)then
				menu[i][3] = 0
			end
			
			--斗转星移不显示
			if tmp == 43 then
				menu[i][3] = 0
			end

			--如果主角是天罡，内功可攻击，畅想第一格内功可攻击
			if ((pid == 0 and JY.Base["标准"] == 6) or (pid == 0 and JY.Base["畅想"] > 0 and i == 1)) and JY.Wugong[tmp]["武功类型"] == 6 then
				menu[i][3] = 1
			end
			--林平之 东方 萧半和 显示葵花神功
			if tmp == 105 and (match_ID(pid, 36) or match_ID(pid, 27) or match_ID(pid, 189) ) then
				menu[i][3] = 1
			end
		   
			--石破天 显示太玄神功
			if tmp == 102 and match_ID_awakened(pid, 38, 1) then
				menu[i][3] = 1
			end
		  
			--张无忌 显示九阳神功
			if tmp == 106 and match_ID(pid, 9) then
				menu[i][3] = 1
			end
			--斗酒僧 显示九阳神功
			if tmp == 106 and match_ID(pid, 638) then
				menu[i][3] = 1
			end			
		  
			--狄云 显示神经照
			if tmp == 94 and match_ID(pid, 37) then
				menu[i][3] = 1
			end
		  
			--慕容复 显示斗转星移
			if tmp == 43 and match_ID(pid, 51) then
				menu[i][3] = 1
			end
		  
			--欧阳锋 显示逆运
			if tmp == 104 and match_ID(pid, 60) then
				menu[i][3] = 1
			end

			--小昭 显示圣火
			if tmp == 93 and match_ID(pid, 66) then
				menu[i][3] = 1
			end
		  
			--内力少不显示
			if JY.Person[pid]["内力"] < JY.Wugong[tmp]["消耗内力点数"] then
				menu[i][3] = 0
			end

			--体力低于10不显示
			if JY.Person[pid]["体力"] < 10 then
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
		r = Cat('菜单',menu, numwugong, 0,CC.MainMenuX, CC.MainMenuY, 0, 0, 1, 1, CC.DefaultFont, C_ORANGE, C_WHITE)
		if r == 0 then
			return 0
		end
		WAR.ShowHead = 0
		local r2 = War_Fight_Sub(WAR.CurID, r)
		WAR.ShowHead = 1
		Cls()
		return r2
	--无酒不欢：数字快捷键直接使用武功
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

--自动战斗时 做思考
--吃药的flag：2 生命；3内力；4体力；6 解毒
function War_Think()
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	local r = -1
	local minNeili = War_GetMinNeiLi(pid)
	local can_eat_drug = 0
	--非我方，会考虑吃药
	if WAR.Person[WAR.CurID]["我方"] == false then
		can_eat_drug = 1
	--如果是我方，只有在队且允许才会吃药
	else
		if inteam(pid) and JY.Person[pid]["是否吃药"] == 1 then
			can_eat_drug = 1
		end
	end
	--侠客正岛主战不吃药
	--洪七公居洪七公不吃药
	if WAR.Person[WAR.CurID]["我方"] == false and (WAR.ZDDH == 188 or WAR.ZDDH == 257) then
		can_eat_drug = 0
	end
	--可以吃药的话
	if can_eat_drug == 1 then 
		--吃体力药
		local eat_eng_drug = 0
		if inteam(pid) then
			local fz = {50, 30, 10}
			if JY.Person[pid]["体力"] < fz[JY.Person[pid]["体力阈值"]] then
				eat_eng_drug = 1
			end
		else
			if JY.Person[pid]["体力"] < 10 then
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
		
		--吃血药
		local eat_hp_drug = 0
		if inteam(pid) then
			local fz = {0.7, 0.5, 0.3}
			if JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"]*fz[JY.Person[pid]["生命阈值"]] then
				eat_hp_drug = 1
			end
		else
			--根据生命确定吃血药几率
			local rate = -1
			if JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 5 then
				rate = 90
			elseif JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 4 then
				rate = 70
			elseif JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 3 then
				rate = 50
			elseif JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 2 then
				rate = 25
			end
			
			--内伤也增加吃血药几率
			if JY.Person[pid]["受伤程度"] > 50 then
				rate = rate + 50
			end
			
			--暴气时，不吃药
			if Rnd(100) < rate and WAR.LQZ[pid] ~= nil and WAR.LQZ[pid] ~= 100 then
				eat_hp_drug = 1
			end
		end
		if eat_hp_drug == 1 then
			r = War_ThinkDrug(2)
			if r >= 0 then				--如果有药吃药
				return r
			else
				r = War_ThinkDoctor()		--如果没有药，考虑医疗
				if r >= 0 then
					return r
				end
			end
		end
		
		--吃内力药
		local eat_mp_drug = 0
		if inteam(pid) then
			local fz = {0.7, 0.5, 0.3}
			if JY.Person[pid]["内力"] < JY.Person[pid]["内力最大值"]*fz[JY.Person[pid]["内力阈值"]] then
				eat_mp_drug = 1
			end
		else
			--考虑内力
			local rate = -1
			if JY.Person[pid]["内力"] < JY.Person[pid]["内力最大值"] / 6 then
				rate = 100
			elseif JY.Person[pid]["内力"] < JY.Person[pid]["内力最大值"] / 5 then
				rate = 75
			elseif JY.Person[pid]["内力"] < JY.Person[pid]["内力最大值"] / 4 then
				rate = 50
			end

			if Rnd(100) < rate or minNeili > JY.Person[pid]["内力"] then
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
		if CC.PersonAttribMax["中毒程度"] * 3 / 4 < JY.Person[pid]["中毒程度"] then
			jdrate = 60
		else
			if CC.PersonAttribMax["中毒程度"] / 2 < JY.Person[pid]["中毒程度"] then
				jdrate = 30
			end
		end
	  
		--半血以下吃解毒药
		--暴怒不吃解毒药
		if Rnd(100) < jdrate and JY.Person[pid]["生命"] < JY.Person[pid]["生命最大值"] / 2 and WAR.LQZ[pid] ~= nil and WAR.LQZ[pid] ~= 100 then
			r = War_ThinkDrug(6)
			if r >= 0 then
				return r
			end
		end
	end
	
	if inteam(pid) then 
		if JY.Person[pid]["行为模式"] == 4 then
			r = 0
		elseif JY.Person[pid]["行为模式"] == 3 then
			r = 7
		elseif JY.Person[pid]["行为模式"] == 2 then
			r = 8
		elseif JY.Person[pid]["行为模式"] == 1 then
			if minNeili <= JY.Person[pid]["内力"] and JY.Person[pid]["体力"] > 10 then
				r = 1
			else
				r = 0
			end
		end
	else
		if minNeili <= JY.Person[pid]["内力"] and JY.Person[pid]["体力"] > 10 then
			r = 1
		else
			r = 0
		end
	end
	return r
end

--自动攻击
function War_AutoFight()
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	local wugongnum;
	if  JY.Person[pid]["优先使用"] ~= 0 then
		for i = 1, JY.Base["武功数量"] do
			if JY.Person[pid]["武功"..i] == JY.Person[pid]["优先使用"] then
				wugongnum = i
				break
			end
		end
		--加一条防止被洗掉等意外
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

--自动战斗
function War_Auto()
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	WAR.ShowHead = 1
	Cat('实时特效动画')
	WarDrawMap(0)
	ShowScreen()
	lib.Delay(CC.BattleDelay)
	WAR.ShowHead = 0
	if CC.AutoWarShowHead == 1 then
		WAR.ShowHead = 1
	end
    if WAR.HLZT[pid] ~= nil then 
        Cat('随机移动')
    end
	local autotype = War_Think()
	--一言止杀
    if autotype == 1 and WAR.YYZS[pid]~= nil then
		WarDrawMap(0); --不加这条则动画位置无法正常显示
		CurIDTXDH(WAR.CurID, 122,1,"止杀状态中",C_ORANGE)
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

--人物升级
function War_AddPersonLVUP(pid)
	local tmplevel = JY.Person[pid]["等级"]
	if CC.Level <= tmplevel then
		return false
	end
	if JY.Person[pid]["经验"] < CC.Exp[tmplevel] then
		return false
	end
	while CC.Exp[tmplevel] <= JY.Person[pid]["经验"] do
		tmplevel = tmplevel + 1
		if CC.Level <= tmplevel then
			break;
		end
	end
    
    tmplevel = 30
    
	DrawStrBoxWaitKey(string.format("%s 升级了", JY.Person[pid]["姓名"]), C_WHITE, CC.DefaultFont)
	--计算提升的等级
	local leveladd = tmplevel - JY.Person[pid]["等级"]
	
	JY.Person[pid]["等级"] = 30--JY.Person[pid]["等级"] + leveladd
	
	--提高生命增长
	AddPersonAttrib(pid, "生命最大值", (JY.Person[pid]["生命增长"] ) * leveladd * 4)
	
	JY.Person[pid]["生命"] = JY.Person[pid]["生命最大值"]
	JY.Person[pid]["体力"] = CC.PersonAttribMax["体力"]
	JY.Person[pid]["受伤程度"] = 0
	JY.Person[pid]["中毒程度"] = 0
    
	local theadd = JY.Person[pid]["资质"] / 4
	--聪明人内力加少。。。
	--增加内力的成长
	AddPersonAttrib(pid, "内力最大值", math.modf(leveladd * ((16 - JY.Person[pid]["生命增长"]) * 7 + 210 / (theadd + 1))))
	
	--天罡内力每级额外加50
	if pid == 0 and JY.Base["标准"] == 6 then
        AddPersonAttrib(pid, "内力最大值", 50 * leveladd)
	end
	JY.Person[pid]["内力"] = JY.Person[pid]["内力最大值"]
	local p_zz = JY.Person[pid]["资质"];
	--循环提升等级，累加属性
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
		--令狐冲 内伤回复前，每级3点
		--[[
		if pid == 35 and GetD(82, 1, 0) == 1 then
			ups = 3
		end]]
		  
		--队友郭靖 20级之后，每级6点
		if pid == 55 and JY.Person[pid]["等级"] > 20 then
			ups = 6
		end
	  
		AddPersonAttrib(pid, "攻击力", ups)
		AddPersonAttrib(pid, "防御力", ups)
		AddPersonAttrib(pid, "轻功", ups)
		
		--修复医疗、用毒、解毒能力不与等级挂钩的问题
		if JY.Person[pid]["医疗能力"] >= 20 then
			AddPersonAttrib(pid, "医疗能力", 2)
		end
		if JY.Person[pid]["用毒能力"] >= 20 then
			AddPersonAttrib(pid, "用毒能力", 2)
		end
		if JY.Person[pid]["解毒能力"] >= 20 then
			AddPersonAttrib(pid, "解毒能力", 2)
		end
		
		--队友陈家洛 升级加五围
		if pid == 75 then
			if JY.Person[pid]["拳掌功夫"] >= 0 then
				AddPersonAttrib(pid, "拳掌功夫", (5 + math.random(0,1)))
			end
			if JY.Person[pid]["指法技巧"] >= 0 then
				AddPersonAttrib(pid, "指法技巧", (7 + math.random(0,1)))
			end
			if JY.Person[pid]["御剑能力"] >= 0 then
				AddPersonAttrib(pid, "御剑能力", (7 + math.random(0,1)))
			end
			if JY.Person[pid]["耍刀技巧"] >= 0 then
				AddPersonAttrib(pid, "耍刀技巧", (7 + math.random(0,1)))
			end
			if JY.Person[pid]["特殊兵器"] >= 0 then
				AddPersonAttrib(pid, "特殊兵器", (7 + math.random(0,1)))
			end
		end

		
		--暗器每级提高
		if JY.Person[pid]["暗器技巧"] >= 20 then
			AddPersonAttrib(pid, "暗器技巧", 2)
		end
	end

	local ey = 1;  --每级的自由点数
	ey = ey + JY.Base["难度"];
	
	--local zm = limitX(JY.Base["周目"],1,20)
	
	local n = ey*leveladd;		--计算随机额外点数
 
	n = n + math.ceil(p_zz*2.5*leveladd/29)
	
	--加点
	local gj = JY.Person[pid]["攻击力"];
	local fy = JY.Person[pid]["防御力"];
	local qg = JY.Person[pid]["轻功"];
	local tmpN = n;
	
	--天赋ID
	local tfid;
	--主角
	if pid == 0 then
		--标主
		if JY.Base["标准"] > 0 then
			tfid = 280 + JY.Base["标准"]
		--特殊
		elseif JY.Base["特殊"] > 0 then
			tfid = 289 + JY.Base["特殊"]
		--畅想
		else
			tfid = JY.Base["畅想"]
		end
	--队友
	else
		tfid = pid
	end
	
	--升级加点界面
	local current = 1
	while true do
		if JY.Restart == 1 then
			break
		end
		Cls();
		ShowPersonStatus_sub(pid, 1, 1, tfid, -17, 1)
		DrawString(CC.ScreenW/4-CC.Fontsmall*6-2+28-10,CC.ScreenH/2+100+20-15,string.format("可分配点数：%d 点",tmpN) ,C_ORANGE, CC.Fontsmall*0.7);
		for i = 1, 3 do
			local shade_color = C_GOLD
			if i ==  current then
				shade_color = PinkRed
			end
			DrawString(CC.ScreenW/4-CC.Fontsmall*7-30, CC.ScreenH/2+100+24+i*(CC.FontSmall4+CC.PersonStateRowPixel)-40, "→",shade_color, CC.Fontsmall*0.7);
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
				if current == 1 and JY.Person[pid]["攻击力"] > gj then
					JY.Person[pid]["攻击力"] = JY.Person[pid]["攻击力"]-1
					tmpN = tmpN+1
				elseif current == 2 and JY.Person[pid]["防御力"] > fy then
					JY.Person[pid]["防御力"] = JY.Person[pid]["防御力"]-1
					tmpN = tmpN+1
				elseif current == 3 and JY.Person[pid]["轻功"] > qg then
					JY.Person[pid]["轻功"] = JY.Person[pid]["轻功"]-1
					tmpN = tmpN+1
				end
			elseif keypress == VK_RIGHT and tmpN > 0 then
				if current == 1 and JY.Person[pid]["攻击力"] < 620 then
					JY.Person[pid]["攻击力"] = JY.Person[pid]["攻击力"]+1
					tmpN = tmpN-1
				elseif current == 2 and JY.Person[pid]["防御力"] < 620 then
					JY.Person[pid]["防御力"] = JY.Person[pid]["防御力"]+1
					tmpN = tmpN-1
				elseif current == 3 and JY.Person[pid]["轻功"] < 620 then
					JY.Person[pid]["轻功"] = JY.Person[pid]["轻功"]+1
					tmpN = tmpN-1
				end
			elseif keypress==VK_SPACE or keypress==VK_RETURN then
				if tmpN == 0 or (JY.Person[pid]["攻击力"] == 620 and JY.Person[pid]["防御力"] == 620 and JY.Person[pid]["轻功"] == 620) then
					Cls();
					break
				else
					DrawStrBoxWaitKey("对不起，"..JY.Person[pid]["姓名"].."还有剩余的点数没加!", C_WHITE, CC.DefaultFont)
				end
			end
		end
	end
	return true
end

--战斗结束处理函数
--isexp 经验值
--warStatus 战斗状态
function War_EndPersonData(isexp, warStatus)
	--无酒不欢：血量还原函数
	Health_in_Battle_Reset()
	--无酒不欢：战后状态恢复
	for i = 0, WAR.PersonNum - 1 do
		local pid = WAR.Person[i]["人物编号"]
		--敌方回复满状态
		if isteam(pid) == false then
			JY.Person[pid]["生命"] = JY.Person[pid]["生命最大值"]
			JY.Person[pid]["内力"] = JY.Person[pid]["内力最大值"]
			JY.Person[pid]["体力"] = CC.PersonAttribMax["体力"]
			JY.Person[pid]["受伤程度"] = 0
			JY.Person[pid]["中毒程度"] = 0
			JY.Person[pid]["冰封程度"] = 0
			JY.Person[pid]["灼烧程度"] = 0
		--我方恢复状态
		else	
			JY.Person[pid]["生命"] = JY.Person[pid]["生命最大值"]
			JY.Person[pid]["内力"] = JY.Person[pid]["内力最大值"]
			JY.Person[pid]["体力"] = CC.PersonAttribMax["体力"]
			JY.Person[pid]["受伤程度"] = 0
			JY.Person[pid]["中毒程度"] = 0
			JY.Person[pid]["冰封程度"] = 0
			JY.Person[pid]["灼烧程度"] = 0
			--出战统计
			JY.Person[pid]["出战"] = JY.Person[pid]["出战"] + 1
		end
	end

	--乔峰武功回复
	JY.Person[50]["武功1"] = 26
	JY.Wugong[13]["名称"] = "铁掌"
	
	--鸠摩智武功恢复
	if JY.Base["畅想"] == 103 then
		JY.Person[0]["武功2"] = 98
	end
  
	--破丐帮打狗阵
	if WAR.ZDDH == 82 then
		SetS(10, 0, 18, 0, 1)
	end
  
	--梅庄 秃笔翁战斗后
	if WAR.ZDDH == 44 then
		instruct_3(55, 6, 1, 0, 0, 0, 0, -2, -2, -2, 0, -2, -2)
		instruct_3(55, 7, 1, 0, 0, 0, 0, -2, -2, -2, 0, -2, -2)
	end
  
	--梅庄 黑白子战斗
	if WAR.ZDDH == 45 then
		instruct_3(55, 9, 1, 0, 0, 0, 0, -2, -2, -2, 0, -2, -2)
	end
  
	--梅庄 黄钟公战斗
	if WAR.ZDDH == 46 then
		instruct_3(55, 13, 0, 0, 0, 0, 0, -2, -2, -2, 0, -2, -2)
	end
  
  	--葵花尊者战斗胜利
	--用东方的品德记录
	if WAR.ZDDH == 54 and CC.TX["笑傲邪线"] == 1 and WAR.MCRS == 1 then
		CC.TX["笑傲邪线"] = 2
        CC.TG[9967] = 1
	end		
	
    if WAR.ZDDH == 100 and warStatus == 1 then
	    JY.Person[344]["品德"] = 10
    end
	--战斗失败，并且无经验
	if warStatus == 2 and isexp == 0 then
		return 
	end
  
	--统计活的人数
	local liveNum = 0
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["我方"] == true and JY.Person[WAR.Person[i]["人物编号"]]["生命"] > 0 then
			liveNum = liveNum + 1
		end
	end
  
	--分配经验
	local canyu = false
	if warStatus == 1 then
		if WAR.Data["经验"] < 1000 then
			WAR.Data["经验"] = 1000
		end
		--超级木桩和木桩的经验
		if WAR.ZDDH == 226 then
			WAR.Data["经验"] = 45000
		end
		for i = 0, WAR.PersonNum - 1 do
			local pid = WAR.Person[i]["人物编号"]
			if WAR.Person[i]["我方"] == true and inteam(pid) and JY.Person[pid]["生命"] > 0 then
				if pid == 0 then
					canyu = true
				end
				--超级木桩的经验
				if WAR.ZDDH == 226  then
					WAR.Person[i]["经验"] = 120000
				else
					WAR.Person[i]["经验"] = WAR.Person[i]["经验"] + math.modf(WAR.Data["经验"] / (liveNum))
				end
				--小无经验翻倍
				if PersonKF(pid, 98) then
					WAR.Person[i]["经验"] = WAR.Person[i]["经验"] + math.modf(WAR.Data["经验"] / (liveNum))
				end
			end
		end
	end
  
	--把等级放在修炼秘籍的后面
	for i = 0, WAR.PersonNum - 1 do
		local pid = WAR.Person[i]["人物编号"]
		if WAR.Person[i]["我方"] == true and inteam(pid) then
			--无酒不欢：小于30级，或者身上有物品才显示对话框提示
			if JY.Person[pid]["等级"] < 30 or JY.Person[pid]["修炼物品"] >= 0 then
				DrawStrBoxWaitKey(string.format("%s 获得经验点数 %d", JY.Person[pid]["姓名"], WAR.Person[i]["经验"]), C_WHITE, CC.DefaultFont)
			end
			--修炼物品
			AddPersonAttrib(pid, "物品修炼点数", math.modf(WAR.Person[i]["经验"] * 8 / 10))
			AddPersonAttrib(pid, "修炼点数", math.modf(WAR.Person[i]["经验"] * 8 / 10))
			if JY.Person[pid]["修炼点数"] < 0 then
				JY.Person[pid]["修炼点数"] = 0
			end
			War_PersonTrainBook(pid)     --修炼秘籍
			War_PersonTrainDrug(pid)		 --修炼药品
			--把等级放在修炼秘籍的后面
			AddPersonAttrib(pid, "经验", math.modf(WAR.Person[i]["经验"] / 2))
			War_AddPersonLVUP(pid)
		else
			AddPersonAttrib(pid, "经验", WAR.Person[i]["经验"])
		end
	end
  
	--青城四秀
	if WAR.ZDDH == 48 then
		SetS(57, 52, 29, 1, 0)
		SetS(57, 52, 30, 1, 0)
	--一灯居，欧阳锋，裘千刃
	elseif WAR.ZDDH == 175 then
		instruct_3(32, 12, 1, 0, 0, 0, 0, 0, 0, 0, -2, -2, -2)
	--破打狗阵
	elseif WAR.ZDDH == 82 then
		SetS(10, 0, 18, 0, 1)
	--木人巷
	elseif WAR.ZDDH == 214 then
		SetS(10, 0, 19, 0, 1)
	--侠客邪
	elseif WAR.ZDDH == 170 then
		JY.Scene[JY.SubScene]["进门音乐"] = -1
	end

	if JY.Restart == 1 then
		return
	end
end

--执行战斗，自动和手动战斗都调用
--id战斗人物编号
--wugongnum 使用的武功在位置
--x,y为战斗场景坐标
function War_Fight_Sub(id, wugongnum, x, y)
	WAR.Person[id]['特效动画'] = -1
	WAR.Person[id]['特效文字1'] = nil
	WAR.Person[id]['特效文字2'] = nil
	WAR.Person[id]['特效文字3'] = nil
	WAR.Person[id]['特效文字4'] = nil
	
	local pid = WAR.Person[id]["人物编号"]
	local x0, y0 = WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"]
	local wugong = 0
	if wugongnum < 100 then
		wugong = JY.Person[pid]["武功" .. wugongnum]
	else
		wugong = wugongnum - 100
		wugongnum = 1
		for i = 1, JY.Base["武功数量"] do
			if JY.Person[pid]["武功" .. i] == 43  then	--如果学习有斗转星移
				wugongnum = i							--记录斗转武功位置
				break;
			end
		end
        if x ~= nil and y ~= nil then
            x = WAR.Person[WAR.CurID]["坐标X"] - x
            y = WAR.Person[WAR.CurID]["坐标Y"] - y
        end
		WarDrawMap(0)   
		local fj = "错误"		--斗转错误
		--斗转星移提示的文字
		if WAR.DZXYLV[pid] == 100 then
			fj = string.format("%s三才归元掌·镜心", JY.Person[pid]["姓名"])
		elseif WAR.DZXYLV[pid] == 115 then
			fj = string.format("%s发动幻梦星辰反击", JY.Person[pid]["姓名"])
		elseif WAR.DZXYLV[pid] == 110 then
			fj = string.format("%s发动离合参商反击", JY.Person[pid]["姓名"])
		elseif WAR.DZXYLV[pid] == 85 then
			fj = string.format("%s发动斗转星移反击", JY.Person[pid]["姓名"])
		elseif WAR.DZXYLV[pid] == 60 then
			fj = string.format("%s发动北斗移辰反击", JY.Person[pid]["姓名"])
		end
		TXWZXS(fj, C_ORANGE)

	end

	WAR.WGWL = JY.Wugong[wugong]["攻击力10"]
	local fightscope = JY.Wugong[wugong]["攻击范围"]		--没啥用的玩意
	local kfkind = JY.Wugong[wugong]["武功类型"]
	local level = JY.Person[pid]["武功等级" .. wugongnum]   --判断武功是否为极

	if level == 999 then
		level = 11
	else
		level = math.modf(level / 100) + 1
	end
	WAR.ShowHead = 0
	
	--防止以后不指定主角的情况下被斗转带出特效
	--九阳归0
	WAR.JYZS = 0 
	--碧海归0
	WAR.LXBHZS = 0
    WAR.BHJTZ = 0
	
	local m1, m2, a1, a2, a3, a4, a5,a6 = refw(wugong, level)  --获取武功的范围
		
	local movefanwei = {m1, m2}				--可移动的范围
	local atkfanwei = {a1, a2, a3, a4, a5}	--攻击范围
    if a6 == 0	 then
		WAR.JYZS = 0;		
		WAR.LXBHZS = 0;
		return 0
	end 
	x, y = War_FightSelectType(movefanwei, atkfanwei, x, y,wugong)
    --取消时顺带恢复技能释放 九阳 碧海 招式
	--防止出现选择武功后取消的情况
	if x == nil  then
		WAR.JYZS = 0;		
		WAR.LXBHZS = 0;
		return 0
	end 
	
	if WAR.Person[WAR.CurID]["贴图"] ~= WarCalPersonPic(WAR.CurID) then
		WAR.Person[WAR.CurID]["贴图"] = WarCalPersonPic(WAR.CurID)
		SetWarMap(x0,y0, 5, WAR.Person[WAR.CurID]["贴图"])
		WarDrawMap(0)
		Cat('实时特效动画')
		ShowScreen()
		lib.Delay(CC.BattleDelay)
	end
	
	--使用了九阳，该招式进入冷却，
	if  wugong == 106 and level == 11 and  WAR.JYCD[WAR.JYZS] ~= nil and WAR.JYCD[WAR.JYZS] > 0 and inteam(pid)  and WAR.DZXY == 0 and WAR.AutoFight == 0 and WAR.ZYHB==0 then
		WAR.JYLQ[pid][WAR.JYZS] = WAR.JYCD[WAR.JYZS] + 1
	end
	--使用了辟邪，该招式进入冷却
	--林平之无冷却
	if wugong == 48 and level == 11 and inteam(pid) and WAR.AutoFight == 0 and WAR.DZXY == 0  then
		if not match_ID(pid, 36)  then
			WAR.BXLQ[pid][WAR.BXZS] = WAR.BXCD[WAR.BXZS] + 1
		end
	end
    
	--判断合击
	local ZHEN_ID = -1
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[WAR.CurID]["我方"] == WAR.Person[i]["我方"] and i ~= WAR.CurID and WAR.Person[i]["死亡"] == false then
			local nx = WAR.Person[i]["坐标X"]
			local ny = WAR.Person[i]["坐标Y"]
			local fid = WAR.Person[i]["人物编号"]
			for j = 1, JY.Base["武功数量"] do
				if JY.Person[fid]["武功" .. j] == wugong then         
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
							WAR.Person[i]["人方向"] = 3 - War_Direct(x0, y0, x, y)
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

	--攻击次数
	WAR.ATNum = 1

	--判定左右
	if JY.Person[pid]["左右互搏"] == 1 and WAR.ZYHB == 0 and fjpd(WAR.CurID) == false then
		--判断左右，71-资质
        local zyjl = (71-JY.Person[pid]['资质'])

		if zyjl < 0 then
			zyjl = 0
		end
		--周伯通100%
		if match_ID(pid, 64) then
			zyjl = 100
		end
		--郭靖80%
		if match_ID(pid, 55) then
			zyjl = 80
		end
		--小龙女70%
		if match_ID(pid, 59) then
			zyjl = 70
		end
		--周芷若觉醒后，70%
		if match_ID_awakened(pid, 631, 1) then
			zyjl = 70
		end
		--七夕郭靖100%
		--七夕龙女100%
		if match_ID(pid, 612) or match_ID(pid, 615) then
			zyjl = 100
		end
        
		--暴怒必左右
		if WAR.LQZ[pid] == 100 then
			zyjl = zyjl + 20
		end		
		--周伯通支线完成后，主角+20%
		if pid == 0 and JY.Person[64]["品德"] == 80 then
			zyjl = zyjl + 20
		end

		--上限100%
		if zyjl > 100 then
			zyjl = 100
		end
		--斗转星移不触发左右
		if JLSD(0, zyjl, pid) and WAR.DZXY == 0 then
			WAR.ZYHB = 1
			--改到特效文字4显示
			if WAR.Person[WAR.CurID]["特效文字4"] ~= nil then
				WAR.Person[WAR.CurID]["特效文字4"] = WAR.Person[WAR.CurID]["特效文字4"] .."·左右互搏";
			else
				WAR.Person[WAR.CurID]["特效文字4"] = "左右互搏";
			end
		end
	end
	
	--周伯通触发一次左右后，有几率根据资质追加第二次左右，畅想专属
	if match_ID(pid, 64) and WAR.ZYHB == 2 and WAR.ZHB == 0 then
		local zyjl = 80 - JY.Person[pid]["资质"]
		if zyjl < 0 then
			zyjl = 0
		end
		--斗转星移不触发左右
		--永无止境不触发左右
		if JLSD(0, zyjl, pid) and (WAR.DZXY == 0 or WAR.LJXD == 0) and fjpd(WAR.CurID) == false then
			WAR.ZYHB = 1
			WAR.ZHB = 1
		
			--改到特效文字4显示
			if WAR.Person[WAR.CurID]["特效文字4"] ~= nil then
				WAR.Person[WAR.CurID]["特效文字4"] = WAR.Person[WAR.CurID]["特效文字4"] .."·左右互搏";
			else
				WAR.Person[WAR.CurID]["特效文字4"] = "左右互搏";
			end
		end
	end
	
	--无酒不欢：连击率用函数计算
	local LJ;
	
	LJ = Person_LJ(pid)
	--敌人连击+20%
	--if WAR.Person[id]["我方"] == false then
	--	LJ = LJ + 10
	--end
		
	--连击率上限100
	if LJ > 100 then
		LJ = 100 
	end
	
	if JLSD(0,LJ,pid) then
		WAR.ATNum = 2
	end

	--高连击武功
	local glj = {7, 2, 34, 37, 55, 57, 70, 77,156}
	for i = 1, 8 do
		if JY.Person[pid]["武功" .. wugongnum] == glj[i] and JLSD(20, 75, pid) then
			WAR.ATNum = 2
			break;
		end
	end
	
	--五岳剑法组合额外连击
	if wugong >= 30 and wugong <= 34 and WuyueJF(pid) and JLSD(30, 60, pid) then
		WAR.ATNum = 2
	end
	
	--紫气天罗组合额外连击
	if (wugong == 3 or wugong == 120 or wugong == 5 or wugong == 21 or wugong == 118) and ZiqiTL(pid) and JLSD(30, 60, pid) then
		WAR.ATNum = 2
	end
	
	--天衣无缝组合，刀法连击率+30%
	if kfkind == 4 and TianYiWF(pid) and JLSD(30, 60, pid) then
		WAR.ATNum = 2
	end
	
	--萧中慧夫妻必连
	if match_ID(pid, 77) and wugong == 62 then
		WAR.ATNum = 2
	end
	
	--装备鸳鸯刀，夫妻必连
	if (JY.Person[pid]["武器"] == 217 or JY.Person[pid]["武器"] == 218) and wugong == 62 then
		WAR.ATNum = 2
	end
	
	--狄云，水笙连城高连
	if (match_ID(pid, 37) or match_ID(pid, 589)) and wugong == 114 and JLSD(20, 75, pid) then
		WAR.ATNum = 2
	end
	
	
	--枯荣一阳指高连
	if match_ID(pid, 102) and wugong == 17 and JLSD(20, 75, pid) then
		WAR.ATNum = 2
	end
	
	--小龙女玉女素心剑高连
	if match_ID(pid, 59) and wugong == 139 and JLSD(20, 75, pid) then
		WAR.ATNum = 2
	end
	
	--张三丰太极神功蓄力超过600，必连
	--适用任何武功 
	if Curr_NG(pid,171) and WAR.PD["太极蓄力"][pid] ~= nil then
	    if match_ID(pid,5) and WAR.PD["太极蓄力"][pid] > 500 then
	       WAR.ATNum = 2
	    elseif WAR.PD["太极蓄力"][pid] > 600 then
		   WAR.ATNum = 2
	    end
    end
    
    -- 三花聚顶掌必连击
    if wugong == 115 then
	   WAR.ATNum = 2
    end
	    
	--倚天密道，成昆必定单击
	--天外也不会连击
	if WAR.ZDDH == 237 and pid == 18 then
		WAR.ATNum = 1
		WAR.TWLJ = 2
	end
    --擒龙手
	if wugong == 187 then
		WAR.ATNum = 1
		WAR.TWLJ = 2
	end
	--化功大法必定单击
	if wugong == 87 then
		WAR.ATNum = 1
	end
  
	--无酒不欢：黯然极意和三叠浪
	--杨过才能触发
	if wugong == 25 and level == 11 and (match_ID(pid, 58) or pid == 0 ) then
		local jl = 20;
		--内伤大于30时，每点内伤增加1%几率
		if JY.Person[pid]["受伤程度"] > 30 then
			jl = jl + (JY.Person[pid]["受伤程度"]-30)
		end    
		--生命少于70%时，每少一百生命，机率增加10%
		if JY.Person[pid]["生命"] < (JY.Person[pid]["生命最大值"]*0.7) then
			jl = jl + math.ceil(((JY.Person[pid]["生命最大值"]*0.7) - JY.Person[pid]["生命"])/10);	  		
		end

		--几率大于0才触发
		if jl > 0 then
			--暴怒必触发
			if WAR.LQZ[pid] == 100 or JLSD(0,jl,pid) or match_ID(pid, 58) then	
                 WAR.ARJY = 1			
				--三叠浪，限杨过
				if match_ID(pid, 58) and JY.Person[pid]["资质"] > 50  then                  
					WAR.ATNum = 3;
					TXWZXS("黯然销魂.物我两忘.黯然三叠浪", M_DeepSkyBlue)
				else
					WAR.ATNum = 2;
				end			
			end
		end
	end
	
	--九阴极意 
	if  wugong == 11 and level == 11  and (Curr_NG(pid,107) or match_ID(pid,640))  then
	    WAR.JYSZ = 1
		TXWZXS("九阴神爪.无坚不摧", M_DeepSkyBlue)
			--WAR.ATNum = 2
	end
    
	--三连黄衫女
	if match_ID(pid, 640) and WAR.JYSZ == 1 then
		if JY.Base["天书数量"]>= 7 and(JLSD(20,60,pid) or WAR.LQZ[pid] == 100) then
		    WAR.ATNum = 3
		else
			WAR.ATNum = 2
		end
	end  
	--三连 黄赏
	if match_ID(pid, 637)  and WAR.JYSZ == 1then
		if (JY.Base["天书数量"] >= 7 or not inteam(pid)) and (JLSD(20,60,pid) or WAR.LQZ[pid] == 100)  then
            WAR.ATNum = 3
		else
            WAR.ATNum = 2	
        end	
    end		   

	--云罗天网 
	--if kfkind == 5 and pid == 0 and level == 11 and WAR.DZXY ~= 1 and (JLSD(20, 20+JY.Person[pid]["特殊兵器"]*0.1, pid) or WAR.LQZ[pid] == 100) then
	--    WAR.YLTW = 1
	--	local zs = {"奇门.九鬼拔刀势","奇门·青龙探抓势","奇门·三盘落地势","奇门·摘星换斗势"}
	--	WAR.Person[id]["特效文字3"] = zs[math.random(4)]
	--	WAR.Person[id]["特效动画"] = 119
	--end	
		
   
	--乔峰
	if match_ID(pid, 50)  then

		--如果乔峰用的是降龙，那么有40%的机率三连击，怒气暴发时必三连
		--音箱提高三叠浪几率，每级+5%
		local ex_chance = 0
		if JY.Person[pid]["武器"] == 300 then
			ex_chance = JY.Thing[300]["装备等级"] * 5
		end
		if wugong == 26 and (JLSD(25, 65+ex_chance, pid) or WAR.LQZ[pid] == 100) then
			WAR.FS = 1
			WAR.ATNum = 3
			local color = M_Red
			local display = "六军辟易.奋英雄怒.降龙三叠浪"
			--装备音箱，暴怒有50%几率出四叠浪
			if JY.Person[pid]["武器"] == 300 and WAR.LQZ[pid] == 100 and JLSD(25, 75, pid) then
				WAR.ATNum = 4
				display = "虎啸龙吟.帝释天威.降龙四叠浪"
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
		--NPC乔峰回内
		if inteam(pid) == false then
			if JY.Person[pid]["内力"] < 1000 then
				JY.Person[pid]["内力"] = 1200 + math.random(100)
			end
		end
	end


	
	--桃花绝技，有40%几率三连击，暴怒必触发
	if (wugong == 12 or wugong == 18 or wugong == 38) and TaohuaJJ(pid) and (WAR.LQZ[pid] == 100 or JLSD(35, 75, pid)) then
		WAR.ATNum = 3
		TXWZXS("桃花绝技·奇门五转", PinkRed)
	end
	
		--太虚剑意剑法50%几率三连击，
    if PersonKF(pid,152)  and kfkind == 3 then
       local jl = 30
	   if Curr_NG(pid,152) then
		jl = 50
		end
		if math.random(100) <= jl  then
			WAR.ATNum = 3	
			TXWZXS("三环套月", PinkRed)
		end
	end
    
  	--东方不败
	if match_ID(pid, 27) and (WAR.LQZ[pid]== 100 or JLSD(10,40,pid))then
		WAR.ATNum = WAR.ATNum + 1
    end 
    
	--倚天连击
	if JY.Person[pid]["武器"] == 37 and JY.Thing[37]["装备等级"] == 6 and kfkind == 3 then
	    local jl = 0;
        if JY.Person[pid]["御剑能力"] > 200 then
			jl = jl + (JY.Person[pid]["御剑能力"]*0.1);	
		end
        if jl > 0 then
			--暴怒必触发
			if WAR.LQZ[pid] == 100 or jl > Rnd(100) then	
		       WAR.ATNum = WAR.ATNum + 1
		      Set_Eff_Text(id,"特效文字0","谁与争锋");
	        end	
	    end
	end
    
	--陆渐三十二身相 神鱼相，33%追加连击一次 
	if match_ID(pid, 497)  and WAR.SSESS[pid] ~= nil and WAR.SSESS4 < 1 and (WAR.LQZ[pid] == 100 or JLSD(33, 53, pid)) and JY.Base["天书数量"] > 0 then
		WAR.ATNum = WAR.ATNum + 1
        WAR.SSESS4 = WAR.SSESS4 +1         		
		Set_Eff_Text(id,"特效文字2","神鱼相");
	end	  	
		
	--何太冲，40%几率动如雷震，暴怒必触发
	if match_ID(pid, 7) and(WAR.LQZ[pid] == 100 or JLSD(35, 75, pid)) and WAR.DZXY ~= 1 then
		WAR.ATNum = 3
		TXWZXS("昆仑秘传·太清剑法·迅雷大三式", M_Red)
	end
    
 	--狄云赤心连城追加连击
	if match_ID(pid, 37) and WAR.CXLC == 1 and WAR.CXLC_Count < 3 then
		WAR.ATNum = WAR.ATNum + 1
		WAR.CXLC_Count = WAR.CXLC_Count + 1
	end 

	--蓝烟清：装备真武剑时使用太极剑法必连击
	if JY.Person[pid]["武器"] == 236 and wugong == 46 then
		WAR.ATNum = 2;
	end
	--岳云 岳家枪法必连
    if match_ID(pid,568) and wugong == 200 then
		WAR.ATNum = 2
	end

	--尼摩星必定单击
	if match_ID(pid, 159) then
		WAR.ATNum = 1
	end
    
	--双剑合壁 必连
	if (wugong == 39 or wugong == 42 or wugong == 139) and ShuangJianHB(pid) then
	    WAR.ATNum = 2
	end
    
	 --玉女十九剑 满怒必连
	if WAR.YLSJJ == 1 and WAR.LQZ[pid] == 100 then
	   WAR.ATNum = 2
	end
    
	--进阶太岳，连击时为三连击
	if wugong == 34 and PersonKF(pid,175) and WAR.ATNum == 2 then
		WAR.ATNum = 3
	end
  
	WAR.ACT = 1
	WAR.SSESS4 = 0	--三十二身相

	--斗转
	if WAR.DZXY == 1 then
		--慕容博两次，其他人一次
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
    
    if WAR.WS == 1 then		--误伤
       WAR.WS = 0
    end
    
    if WAR.BJ == 1 then		--暴击
       WAR.BJ = 0
    end
    
	if WAR.PD["先天罡气"][pid] ~= nil then
       WAR.PD["先天罡气"][pid] = nil
	end
--清零--
    WAR.PD['野球拳'][pid] = nil
    WAR.PD['西瓜刀'][pid] = nil
    WAR.PD["金刚般若"][pid] = nil
    WAR.PD['雪花六出'][pid] = nil
    WAR.PD['降龙·亢龙有悔'][pid] = nil
    WAR.PD['降龙·震惊百里'][pid] = nil
    WAR.PD['降龙·见龙在田'][pid] = nil
    WAR.PD['火延'][pid] = nil
    WAR.PD['侵如火'][pid] = nil
    WAR.PD['绊字决'][pid] = nil
    WAR.PD['封字决'][pid] = nil
    WAR.PD['缠字决'][pid] = nil
    WAR.PD['挑字决'][pid] = nil 
    WAR.PD['戳字决'][pid] = nil
    WAR.PD['曲夕烟隙'][pid] = nil
    WAR.PD['曲径通幽'][pid] = nil
    WAR.PD['万佛朝宗'][pid] = nil	
    if WAR.DJGZ == 1 then	--刀剑归真
       WAR.DJGZ = 0
    end
    if WAR.HQT == 1 then	--霍青桐 杀体力
       WAR.HQT = 0
    end
    if WAR.CY == 1 then		--程英 杀内力
       WAR.CY = 0
    end
	WAR.JYZJ_FXJ= 0
	WAR.DFMQ = 0		--大伏魔拳	
    WAR.NGJL = 0		--当前加力内功编号
    WAR.KHBX = 0		--葵花刺目
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
    WAR.TZ_XZ = 0		--虚竹指令
    WAR.JGZ_DMZ = 0		--达摩掌
    WAR.LHQ_BNZ = 0		--般若掌
	WAR.WD_CLSZ = 0		--赤练神掌
	WAR.QZ_QXJF = 0		--七星剑法	
	WAR.BXXHSJ = 0		--
	WAR.LWSWD = 0		--	
	WAR.TXZQ = {}		--太玄之轻清除记录
	WAR.HSHD = {}		--黄赏气盾	
	WAR.DZZ = {}		--三十二身相 大自在相 大自在清除记录
	WAR.FGPZ = {}		--	
	WAR.JJJ = {}		--将进酒清除记录
    CleanWarMap(4, 0)           --全屏
    WAR.SJHB_G =0
    WAR.L_TLD = 0		--装备屠龙刀特效，流血
	WAR.XZBF = 0
	WAR.PJTX = 0 		--玄铁剑配玄铁剑法，破尽天下
	WAR.YLSJJ = 0
	WAR.NZZ1 = 0	
	WAR.JGSL = 0 		--大金刚神力
	WAR.CXLC = 0		--狄云赤心连城
	WAR.YTLJ = 0		--倚天连击	
	WAR.FQY = 0			--风清扬无招胜有招
	WAR.GHQH = 0		--黄衫女广寒清辉	
	WAR.LXXZD = 0		--梁萧谐之道
	
	WAR.AJFHNP = 0		--
	WAR.YTML = 0 		--毒王大招
	WAR.SLSS = 0 		--梁萧 星罗散手	
	WAR.JSTG = 0		--天罡大招
	WAR.TXZZ = 0		--太玄之重
	WAR.MMGJ = 0		--盲目攻击
	WAR.KHLH = 0	
	WAR.JSAY = 0		--金蛇奥义
	WAR.WDKTJ = 0		--
	WAR.GHQH = 0		--	
	WAR.YQFSQ = 0		--一气化三清	
	
	WAR.QXWXJ = 0		--七弦无形剑 莫大	
	WAR.OYFXL = 0 		--欧阳锋根据蛤蟆蓄力增加伤害
	WAR.LXXL = 0 		--梁萧蓄力增加伤害	
	WAR.XDLeech = 0		--血刀吸血量
	WAR.WYXLeech = 0	--韦一笑吸血量
	WAR.TMGLeech = 0	--天魔功吸血量
	WAR.BHGLeech = 0	--碧海吸血量	
	WAR.XHSJ = 0		--血河神鉴吸血量
	WAR.KMZWD = 0 		--周伯通空明之武道
	WAR.LFHX = 0 		--林朝英流风回雪
	WAR.YNXJ = 0		--夭矫空碧
	WAR.HXZYJ = 0		--会心之一击
	WAR.YYBJ = 0 		--郭靖：有余不尽
    WAR.SEYB = 0	
	WAR.BHJTZ = 0 		--		
	WAR.MHSN = 0 		--	
    WAR.KZJYBF = 0      --
	WAR.BJYPYZ = 0 		--
	WAR.XMJDHS = 0

	WAR.BJYJF = 0      --碧海招式
    WAR.BHJTZ1= 0
	WAR.BHJTZ2= 0
    WAR.BHJTZ3= 0
	WAR.BHJTZ4= 0
    WAR.BHJTZ5= 0
	WAR.BHJTZ6= 0
	
    WAR.DSP_LM1=0   --六脉大招
    WAR.DSP_LM2=0	    
    WAR.DSP_LM3=0	
    WAR.DSP_LM4=0
	
	WAR.NGXS = 0		--内功攻击的系数
	WAR.TYJQ = 0		--阿青天元剑气
	WAR.WWWJ = 0
	WAR.HYYQ=0
	WAR.LDJT = 0
	WAR.CXLZ = 0	
	WAR.QBLL = 0		--
	WAR.SZXM = 0		--	
    WAR.BLCC = 0
    WAR.BLCC_1 = {}	
    WAR.XMHSQ = 0		
	WAR.JTYJ1 = 0		--惊天一剑
	WAR.HZD_1 = 0		--陆渐海之道，上善若水，
	WAR.HZD_2 = 0		--陆渐海之道，海纳百川		
	WAR.OYK = 0 		--欧阳克灵蛇拳
	WAR.JQBYH = 0		--六脉：剑气碧烟横
	WAR.LPZ = 0			--林平之回气
    WAR.JXG_SJG =0      --鲸息功 神鲸歌
	
	WAR.QQSH1 = 0		--琴棋书画之持瑶琴
	WAR.QQSH2 = 0		--琴棋书画之妙笔丹青
	WAR.QQSH3 = 0		--琴棋书画之倚天屠龙功
	
	WAR.CMDF = 0		--沧溟刀法
    WAR.ZWX = 0	
	WAR.HTS = 0			--何铁手五毒随机2-5倍威力
	WAR.YZQS = 0		--一震七伤
	
	WAR.JJZC = 0		--九剑真传的4种主动攻击特效，攻击后会清0
	WAR.JMZL = 0
	
	WAR.ZWYJF = 0		--有剑诀的五岳剑法，无视绝对气防
	
	
	WAR.JuHuo = 0			--举火燎原
	WAR.LiRen = 0			--利刃寒锋
	
	
	WAR.LWX = 0				--李文秀的破气防特效
  	WAR.LXZL10 = 0			--龙象之力暴怒，忽视绝对气防 
	WAR.XC_WLCZ = 0			--	
	WAR.XC_JJNP = 0		
	WAR.PDJN = 0			--陈家洛庖丁解牛	
    WAR.L_QKDNY = {}	--重新计算乾坤大挪移是否被反弹过
	WAR.TXXS = {} 		--特效点数显示
    WAR.RULAISZ = 0
	WAR.RULAISZ_1 = 0
    
    WarDrawAtt(x, y, atkfanwei, 3)
    if ZHEN_ID >= 0 then
		local tmp_id = WAR.CurID
		WAR.CurID = ZHEN_ID
		WarDrawAtt(WAR.Person[ZHEN_ID]["坐标X"] + x0 - x, WAR.Person[ZHEN_ID]["坐标Y"] + y0 - y, atkfanwei, 3)
		WAR.CurID = tmp_id
    end
	
	Cat('神游太虚2')
	
    if wugong == 26 then
        local m = 1

        if WAR.PD['降龙·双龙取水'][pid] == 2 then
            m = 2
        end
        local jl = 0
        
        jl = limitX(JY.Person[pid]["拳掌功夫"]/14,0,25)
        
        if match_ID(pid, 50) then 
            if isteam(pid) == false then
                jl = 35
            else 
                jl = limitX(JY.Person[pid]["拳掌功夫"]/10,0,35)
            end
        end
        if JY.Base["标准"] == 1 then
            jl = limitX(JY.Person[pid]["拳掌功夫"]/10,0,35)
        end
        local a = math.random(m,7)
        if JLSD(0,jl,pid) then
            if a == 1 then
                if WAR.PD['降龙·双龙取水'][pid] == nil then
                    WAR.PD['降龙·双龙取水'][pid] = 1
                    TXWZXS('降龙极意·双龙取水', M_Red)
                end
            elseif a == 2 then 
                WAR.PD['降龙·亢龙有悔'][pid] = 1
                TXWZXS('降龙极意·亢龙有悔', M_Red)
            elseif a == 3 then 
                WAR.PD['降龙·潜龙勿用'][pid] = 1
                TXWZXS('降龙极意·潜龙勿用', M_Red)
            elseif a == 4 then 
                WAR.PD['降龙·震惊百里'][pid] = 1
                TXWZXS('降龙极意·震惊百里', M_Red)
            elseif a == 5 then 
                WAR.PD['降龙·飞龙在天'][pid] = 1
                TXWZXS('降龙极意·飞龙在天', M_Red)
            elseif a == 6 then 
                WAR.PD['降龙·见龙在田'][pid] = 1
                TXWZXS('降龙极意·见龙在田', M_Red)
            elseif a == 7 then
                --WAR.PD['降龙·时乘六龙'][pid] = 1
                TXWZXS('降龙极意·时乘六龙', M_Red)
                --if WAR.ATNum < 3 then
                WAR.ATNum = WAR.ATNum + 1
                --end
            end
        end
    end   
    
    --打狗
    if wugong == 80 then 
        local gl = 0
        gl = limitX(JY.Person[pid]["特殊兵器"]/14,0,25)
        if match_ID(pid, 69) then 
            if isteam(pid) == false then
                gl = 35
            else 
                gl = limitX(JY.Person[pid]["特殊兵器"]/10,0,35)
            end
        end
        if JY.Base["标准"] == 5 then
            gl = limitX(JY.Person[pid]["特殊兵器"]/10,0,35)
        end
            --['绊字决'] = {},
            --['封字决'] = {},
            --['转字决'] = {},
           -- ['缠字决'] = {},
            --['挑字决'] = {},
           -- ['引字决'] = {},
           -- ['戳字决'] = {},
        local a = math.random(1,6)
        if JLSD(0,gl,pid) then
            if a == 1 then 
                WAR.PD['绊字决'][pid] = 1
                TXWZXS('打狗奥义·绊字决', M_Red)
            elseif a == 2 then 
                WAR.PD['封字决'][pid] = 1
                TXWZXS('打狗奥义·封字决', M_Red)
            elseif a == 3 then 
                --WAR.PD['转字决'][pid] = 1
                --if WAR.ATNum < 3 then
                WAR.ATNum = WAR.ATNum + 1
                --end
                TXWZXS('打狗奥义·转字决', M_Red)
            elseif a == 4 then 
                WAR.PD['缠字决'][pid] = 1
                TXWZXS('打狗奥义·缠字决', M_Red)
            elseif a == 5 then 
                WAR.PD['挑字决'][pid] = 1
                TXWZXS('打狗奥义·挑字决', M_Red)
            elseif a == 6 then 
                WAR.PD['戳字决'][pid] = 1
                TXWZXS('打狗奥义·戳字决', M_Red)
            end
        end
    end
    
	--刀剑绝技
    if WAR.PD["刀剑绝技"][pid]~= nil and  WAR.PD["刀剑绝技"][pid] == 1 and WAR.ACT == 2 then
        WAR.Person[id]["特效动画"] = 119	   
        wugong = 44
		local HDJYLJZS = {"刀剑绝技·苗剑· 苏秦背剑","刀剑绝技·苗剑· 黄龙吐须","刀剑绝技·苗剑· 白鹤舒翅","刀剑绝技·苗剑· 怀中抱月","刀剑绝技·苗剑· 力劈华山"};
		local A = HDJYLJZS[math.random(5)];
		TXWZXS(A, M_DeepSkyBlue)
		WAR.PD["刀剑绝技"][pid] = 2
	end	
	
    --判断攻击次数大于1，显示连击
    if WAR.ACT > 1 and WAR.PD["刀剑绝技"][pid] == nil then   
		local A = "连击"
		if WAR.TWLJ == 1 then
			A = "天赋外功.炉火纯青"
		end	
		if WAR.TJZX_LJ == 1 then
			A = "太极之形.圆转不断"
			WAR.TJZX_LJ = 0
		end

		--夫妻刀法
		if wugong == 62 then
			--萧中慧
			if match_ID(pid, 77) then
				A = "碧箫声里双鸣凤"
			--主角男性
			elseif pid == 0 and JY.Person[0]["性别"] == 0 then
				A = "英雄无双风流婿"
			--主角女性
			elseif pid == 0 and JY.Person[0]["性别"] ~= 0 then
				A = "刀光掩映孔雀屏"
			end
		end

		
		--东方不败
		if match_ID(pid, 27) then
			A = "风云再起"
		end
		--改到特效文字4显示
		if WAR.Person[WAR.CurID]["特效文字4"] ~= nil then
			WAR.Person[WAR.CurID]["特效文字4"] = WAR.Person[WAR.CurID]["特效文字4"] .."·".. A
		else
			WAR.Person[WAR.CurID]["特效文字4"] = A;
		end
    end

	--玉女心经：进趋如风，第一击有几率发动，追加一次连击
	if Curr_NG(pid, 154)  and WAR.ACT == 1 then
		local ynjl = 0;
		if pid == 0 then
			ynjl = 5
		end
		--黄衫女女必发动  
		if  match_ID(pid,640) or WAR.LQZ[pid] == 100 or JLSD(30, 30 + JY.Base["天书数量"]*2 + ynjl, pid) then
			WAR.ATNum = WAR.ATNum + 1
			Set_Eff_Text(id,"特效文字1","进趋如风");
		end
	end

	--天外，有33%几率多连击一次
	if Given_WG(pid, wugong) and JLSD(33, 66, pid) and WAR.TWLJ == 0 and WAR.ATNum < 2 then
		WAR.ATNum = WAR.ATNum + 1
		WAR.TWLJ = 1
	end

	--九阴极意连击文字
	if WAR.JYSZ ==1 and WAR.SYLJ == 0 and  WAR.ACT > 1  then
		WAR.JYLJ = 1
		local color = M_DeepSkyBlue
		local n = {'二击','三击','四击','五击'}
		local display = "九阴神爪.无坚不催."
		if WAR.ACT > 1 then
			display = display..n[WAR.ACT-1]
			TXWZXS(display, color)
		end
    end		

	--无酒不欢：暴击率用函数计算
	local BJ;
	
	BJ = Person_BJ(pid)
	
	--敌人暴击+20%
    --if WAR.Person[id]["我方"] == false then
    	--BJ = BJ + 20
   -- end
	--金雁功
	if Curr_QG(pid,223) then
		BJ = BJ + 20
	end
	--鲸息功蓄力超过500，必暴
	if PersonKF(pid, 180) and WAR.PD["鲸息蓄力"][pid] ~= nil and WAR.PD["鲸息蓄力"][pid] > 500  then
		BJ = BJ + 100
	end	
	--暴击率上限100
    if BJ > 100 then
		BJ = 100
    end
    
	if JLSD(0,BJ,pid) then
		WAR.BJ = 1
    end
	
    --高暴击武功
    local gbj = {11, 13, 28, 33, 58, 59, 72, 75, 114}
    for i = 1, 9 do
		if JY.Person[pid]["武功" .. wugongnum] == gbj[i] and JLSD(20, 75, pid) then
			WAR.BJ = 1
			break;
		end
    end
    
    --装备玄铁剑，配合玄铁剑法
	--1级50%暴击率，6级100%
	--6级解锁破尽天下，必暴击，无视绝对气防
    if JY.Person[pid]["武器"] == 36 and wugong == 45 then
		if JLSD(0, 40 + JY.Thing[36]["装备等级"] * 10, pid) then
			WAR.BJ = 1
		end
		if JY.Thing[36]["装备等级"] == 6 then
			WAR.PJTX = 1
			Set_Eff_Text(id,"特效文字0","重剑无锋·破尽天下");
		end
    end
	--绣花针，忽视绝对气防 
	if JY.Person[pid]["武器"] == 349 and JY.Thing[349]["装备等级"] == 6 then
       WAR.PD["绣花针"][pid] = 1
	   --Set_Eff_Text(id,"特效文字0","葵花·空蝉");
	end	
	--碧海招式5必暴击 滴水劲
	if WAR.BHJTZ5== 1  then
	WAR.BJ = 1
	end			
	--弹指神通，配合桃花绝技，必暴击
	if wugong == 18 and TaohuaJJ(pid) then
		WAR.BJ = 1
	end
    --傲世神罡
	if match_ID(pid,9989) then
		WAR.BJ = 1
	end
	--无量禅震
	if wugong == 86 and match_ID(pid,9994) then
		WAR.BJ = 1
	end
	--金刚般若 大金刚掌
	if wugong == 22 and JinGangBR(pid) then
        WAR.BJ = 1 
    end  		
	--天魔功，必暴击
	if Curr_NG(pid, 160) then
		WAR.BJ = 1
	end
    if match_ID(pid,568) and wugong == 198 then
		WAR.BJ = 1
	end
   --装备屠龙刀，使用等级为极的刀法，有几率触发两种特效
	if JY.Person[pid]["武器"] == 43 then
	  	if kfkind == 4 and level == 11 then
    		--必流血，并追加等同于武功威力的杀气，50%几率优先判定
    		if JLSD(25, 75, pid) then
    			WAR.L_TLD = 1;
				Set_Eff_Text(id,"特效文字0","武林至尊.宝刀屠龙");
			--如果没有触发，则还有40%几率触发必定暴击
    		elseif JLSD(35, 75, pid) then	
    			WAR.BJ = 1
				Set_Eff_Text(id,"特效文字0","号令天下.莫敢不从");
    		end
    	end
	end
	  
	local ng = 0
	
	--化功大法必定不暴击
	if wugong == 87 then
		WAR.BJ = 0
	end
	--三花聚顶掌必定不暴击
	if wugong == 115 then
		WAR.BJ = 0
	end	
	--擒龙手必定不暴击
	if wugong == 187 then
	WAR.BJ = 0
	end		
	--如果暴击
    if WAR.BJ == 1 then
		WAR.Person[id]["特效动画"] = 89		--暴击特效动画
		if match_ID(pid, 50) then			--乔峰特效文字
			local r = nil
			r = math.random(3)
			if r == 1 then
				Set_Eff_Text(id,"特效文字1","教单于折箭 六军辟易 奋英雄怒");
			elseif r == 2 then
				Set_Eff_Text(id,"特效文字1","虽万千人吾往矣");
			elseif r == 3 then
				Set_Eff_Text(id,"特效文字1","胡汉恩仇 须倾英雄泪");
			end
		end
		--改成特效文字4显示
		if WAR.Person[WAR.CurID]["特效文字4"] ~= nil then
			WAR.Person[WAR.CurID]["特效文字4"] = WAR.Person[WAR.CurID]["特效文字4"] .."·".. "暴击"
		else
			WAR.Person[WAR.CurID]["特效文字4"] = "暴击";
		end
    end
	
    --无酒不欢：计算内功加力
	if JY.Person[pid]["主运内功"] > 0 then
		local cur_NG = JY.Person[pid]["主运内功"]
		--吸功，金刚不坏，风林六如，五岳剑诀不加力
		if cur_NG ~= 85 and cur_NG ~= 87 and cur_NG ~= 88 and cur_NG ~= 144 and cur_NG ~= 143 and cur_NG ~= 91 and cur_NG ~= 175 then
			local cur_NGL = 0;
			for i = 1, JY.Base["武功数量"] do
				if JY.Person[pid]["武功"..i] ==  cur_NG then
					cur_NGL = JY.Person[pid]["武功等级" .. i];
					if cur_NGL == 999 then
						cur_NGL = 11
					else
						cur_NGL = math.modf(cur_NGL / 100) + 1
					end
					break;
				end
			end
			--主运内功有35%的高优先级判定
			if cur_NGL ~= 0 and JLSD(30, 65, pid) then
				ng = get_skill_power(pid, cur_NG, cur_NGL);
				WAR.Person[id]["特效文字2"] = JY.Wugong[JY.Person[pid]["主运内功"]]["名称"] .. "加力"
				WAR.Person[id]["特效动画"] = 93
				WAR.NGJL = JY.Person[pid]["主运内功"];
			end
		end
	end
	
	--如果没有触发主运内功加力，再判定一般加力
	if WAR.NGJL == 0 then
		local N_JL = {};		
		local num = 0;	--当前学了多少个内功
		for i = 1, JY.Base["武功数量"] do
			local kfid = JY.Person[pid]["武功" .. i]
			local kflvl = JY.Person[pid]["武功等级" .. i]
			if kflvl == 999 then
				kflvl = 11
			else
				kflvl = math.modf(kflvl / 100) + 1
			end
			--先把内功都存入表格，吸功，金刚不坏，风林六如，五岳剑诀不加力
			if JY.Wugong[kfid]["武功类型"] == 6 and kfid ~= 85 and kfid ~= 87 and kfid ~= 88 and kfid ~= 144 and kfid ~= 143 and kfid ~= 91 and kfid ~= 175 then
				num = num + 1;
				N_JL[num] = {kfid,i,get_skill_power(pid, kfid, kflvl)};
			end
		end
				
		--如果学有内功
		if num > 0 then	
			--按照威力从大到小排序，威力一样的话按照面板的先后顺序
			for i = 1, num - 1 do
				for j = i + 1, num do
					if N_JL[i][3] < N_JL[j][3] or (N_JL[i][3] == N_JL[j][3] and N_JL[i][2] > N_JL[j][2])then
						N_JL[i], N_JL[j] = N_JL[j], N_JL[i]
					end
				end
			end
			--按顺序判定触发
			for i = 1, num do
				--王重阳北斗七闪状态必定加力
				if (match_ID(pid, 129) and WAR.BDQS > 0) or myrandom(10, pid) then
					ng = N_JL[i][3];
					WAR.Person[id]["特效文字2"] = JY.Wugong[N_JL[i][1]]["名称"] .. "加力"
					WAR.Person[id]["特效动画"] = 87 + math.random(6)
					WAR.NGJL = N_JL[i][1];
					break;
				end
					for i = 1, num do
			   end

			end
		end
	end

    if isteam(pid) == false then 
        local nd = JY.Base['难度']
        local fj = 7 - JY.Person[pid]["畅想分阶"]
        ng = ng + nd*300 + fj*300
        if WAR.NGJL == 0 then
            WAR.Person[id]["特效动画"] = 87
            WAR.Person[id]["特效文字2"] = '基础内功'.. "加力"
        end
    end
    
   --擒龙功加力动画
    if WAR.NGJL == 204 then
        WAR.Person[id]["特效动画"] = 111 
    end
    if match_ID(pid,50) and PersonKF(pid,204) and WAR.NGJL == 0 then
    		WAR.Person[id]["特效动画"] = 111
		WAR.Person[id]["特效文字2"] = "擒龙功加力"
		ng = ng + 1000
    end   
	--张无忌 斗酒僧 补偿加力
    if match_ID(pid, 9) or match_ID(pid, 638) and WAR.NGJL == 0 and PersonKF(pid, 106) then
		WAR.Person[id]["特效动画"] = math.fmod(106, 10) + 85
		WAR.Person[id]["特效文字2"] = "九阳神功加力"
		ng = ng + 1200
    end
		--鲸息功蓄力攻击
	if PersonKF(pid, 180) and WAR.DZXY == 0 then
		if WAR.PD["鲸息蓄力"][pid] == nil then
			WAR.PD["鲸息蓄力"][pid] = 0
		elseif WAR.PD["鲸息蓄力"][pid] > 100 then
			ng = ng + WAR.PD["鲸息蓄力"][pid]+500
		  
			if WAR.Person[id]["特效文字2"] ~= nil then
				WAR.Person[id]["特效文字2"] = WAR.Person[id]["特效文字2"].. "·一空沧海式"
			else
				WAR.Person[id]["特效文字2"] = "一空沧海式"
			end
			--梁萧提高伤害
			if match_ID(pid, 635) then
				WAR.LXXL = WAR.PD["鲸息蓄力"][pid]
			end
			WAR.Person[id]["特效动画"] = math.fmod(95, 10) + 85
			--蓄力清0
			WAR.PD["鲸息蓄力"][pid] = WAR.PD["鲸息蓄力"][pid]*0.5
		end
	end	

	--蟾震九天，斗转不触发
	if PersonKF(pid, 95) and WAR.DZXY == 0 then
		if WAR.PD["蛤蟆蓄力"][pid] == nil then
			WAR.PD["蛤蟆蓄力"][pid] = 0
		elseif WAR.PD["蛤蟆蓄力"][pid] > 100 then
			ng = ng + WAR.PD["蛤蟆蓄力"][pid] * 10 
			if ng > 1000 then
			ng = 1000	  
			if WAR.Person[id]["特效文字3"] ~= nil then
				WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"].. "·蟾震九天"
			else
				WAR.Person[id]["特效文字3"] = "蟾震九天"
			end
			--欧阳锋提高伤害
			if match_ID(pid, 60) then
				WAR.OYFXL = WAR.PD["蛤蟆蓄力"][pid]
			end
			WAR.Person[id]["特效动画"] = math.fmod(95, 10) + 85
			--三丰不清0
			--蓄力清0
			WAR.PD["蛤蟆蓄力"][pid] = 0
		    end
	    end	
    end

	--天赋外功提高100点气攻
	if Given_WG(pid, wugong) then
		ng = ng + 100
	end
    -- 碧海招式1 常规伤害
	--if WAR.LXBHZS == 1 then
	 -- ng = ng +200
	 --end
	 --狼牙 天狼啸月
	
	-- 	鲸息功
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
                Set_Eff_Text(id,"特效文字1","阴阳流");
			elseif bh == 2 then
                WAR.BHJTZ3= 1
                Set_Eff_Text(id,"特效文字1","生灭道");
			elseif bh == 3 then
                Set_Eff_Text(id,"特效文字1","漩涡劲");
                WAR.ATNum = WAR.ATNum + 1
            elseif bh == 4 then
                WAR.BHJTZ5= 1
                Set_Eff_Text(id,"特效文字1","滴水劲");
			elseif bh == 5 then
                WAR.BHJTZ2= 1
                Set_Eff_Text(id,"特效文字1","滔天炁");
			elseif bh == 6 then
                WAR.BHJTZ6= 1
                Set_Eff_Text(id,"特效文字1","陷空力");				
			end
		--end
    end

 		-- 	段思平 六脉神剑
	if wugong == 49 then
        local gl = math.modf(JY.Person[pid]["实战"]/20)
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
				Set_Eff_Text(id,"特效文字1","剑逆天光");
			end	
			if jhjy == 1 then
				Set_Eff_Text(id,"特效文字1","剑煌镜影");
				WAR.DSP_LM2= 1
				WAR.ATNum = WAR.ATNum + 1
			end		
			if nkwj == 1 then
				Set_Eff_Text(id,"特效文字1","南柯万剑");
				 WAR.BJ = 1
				 WAR.DSP_LM3= 1
			end			
			if hxjy == 1  then
				Set_Eff_Text(id,"特效文字1","皇玺剑印");			
			   WAR.DSP_LM4= 1			
			end
        end    
	end	
	
    if wugong == 109 then 
        local gl = 0
        if inteam(pid) then
            gl = math.modf(JY.Person[pid]["实战"]/20)
        else
            gl = 25
        end
        if JLSD(0,25+gl,pid) then
            local str = {'猜拳·拳崩如山','猜拳·裁云剪水','猜拳·星罗云布'}
            local a = math.random(3)
            WAR.PD['野球拳'][pid] = a
            Set_Eff_Text(id,"特效文字3",str[a])
        end
    end
    
    if wugong == 111 then 
        local gl = 0
        if inteam(pid) then
            gl = math.modf(JY.Person[pid]["实战"]/20)
        else
            gl = 25
        end
        if JLSD(0,25+gl,pid) then
            local str = {'刀·迎风回浪','刀·阴阳交错','刀·草木成佛','刀·天人合一'}
            local a = math.random(4)
            if a < 4 then
                WAR.PD['西瓜刀'][pid] = a
            else
                WAR.PD['西瓜刀·天人'][pid] = 2
            end
            Set_Eff_Text(id,"特效文字3",str[a])
        end
        if WAR.PD['西瓜刀·残刀'][pid] == nil then 
            WAR.PD['西瓜刀·残刀'][pid] = {}
            WAR.PD['西瓜刀·残刀'][pid][1] = 1
            WAR.PD['西瓜刀·残刀'][pid][2] = 50
        else
            WAR.PD['西瓜刀·残刀'][pid][1] = (WAR.PD['西瓜刀·残刀'][pid][1] or 0) + 1 
            if WAR.PD['西瓜刀·残刀'][pid][1] > 20 then 
                WAR.PD['西瓜刀·残刀'][pid][1] = 20
            end
            WAR.PD['西瓜刀·残刀'][pid][2] = 50
        end
    end
    
	--陈家洛庖丁解牛
	if match_ID(pid, 75) and JLSD(20,70,pid) then
		WAR.PDJN = 1
		Set_Eff_Text(id,"特效文字1","庖丁解牛")
	end
   -- 十龙十象
    if Curr_NG(pid,103) and JinGangBR(pid) and JLSD(20,40,pid) then
		WAR.SLSX[pid] = 1
    end	
   -- 九阴 飞絮劲
   if PersonKF(pid,107) and (JY.Person[pid]["内力性质"] == 0  or JY.Person[pid]["内力性质"] == 3) then
       local jl = 50
		if JLSD(0,jl,pid) or WAR.LQZ[pid] == 100 then
			WAR.JYZJ_FXJ = 1
			Set_Eff_Text(id,"特效文字1","飞絮劲");
		end
	end

   -- 大周天功 大宗师
    if PersonKF(pid,190)  then
		local jl = 30
		if Curr_NG(pid,190) then
			jl = 50
		end
		if JLSD(0,jl,pid) or WAR.LQZ[pid] == 100 then
			WAR.DZTG_DZS = 1
			Set_Eff_Text(id,"特效文字1","大宗师");
		end
	end
	
  --如果学会北冥神功
    if (PersonKF(pid, 85) and JLSD(45, 75, pid)) or (Curr_NG(pid, 85) and JLSD(20, 70, pid)) then
		if WAR.Person[id]["特效动画"] == -1 then
			WAR.Person[id]["特效动画"] = math.fmod(85, 10) + 85
		end
		Set_Eff_Text(id,"特效文字2","北冥神功");
		WAR.BMXH = 1
		  
		--北冥神功升级
		for w = 1, JY.Base["武功数量"] do
			if JY.Person[pid]["武功" .. w] < 0 then
				break;
			end
			if JY.Person[pid]["武功" .. w] == 85 then
				JY.Person[pid]["武功等级" .. w] = JY.Person[pid]["武功等级" .. w] + 50
				if JY.Person[pid]["武功等级" .. w] > 999 then
					JY.Person[pid]["武功等级" .. w] = 999
				end
				break;
			end
		end
    end
      
    --吸星大法，与北冥不可同时触发
	--萧半和自带50机率触发
    if (((PersonKF(pid, 88) and JLSD(45, 75, pid)) or (Curr_NG(pid, 88) and JLSD(20, 70, pid))) or (match_ID(pid,189) and JLSD(20, 70, pid))) and WAR.BMXH == 0  then
		if WAR.Person[id]["特效动画"] == -1 then
			WAR.Person[id]["特效动画"] = math.fmod(88, 10) + 85
		end
		Set_Eff_Text(id,"特效文字2","吸星大法");
		WAR.BMXH = 2

		--吸星大法升级
		for w = 1, JY.Base["武功数量"] do
			if JY.Person[pid]["武功" .. w] < 0 then
				break;
			end
			if JY.Person[pid]["武功" .. w] == 88 then
				JY.Person[pid]["武功等级" .. w] = JY.Person[pid]["武功等级" .. w] + 50
				if JY.Person[pid]["武功等级" .. w] > 999 then
					JY.Person[pid]["武功等级" .. w] = 999
				end
				break;
			end
		end
    end
    
    --化功大法
    if ((PersonKF(pid, 87) and JLSD(45, 75, pid)) or (Curr_NG(pid, 87) and JLSD(20, 70, pid))) and WAR.BMXH == 0 then
		if WAR.Person[id]["特效动画"] == -1 then
			WAR.Person[id]["特效动画"] = math.fmod(87, 10) + 85
		end
		Set_Eff_Text(id,"特效文字2","化功大法");
		WAR.BMXH = 3
		  
		--化功大法升级
		for w = 1, JY.Base["武功数量"] do
			if JY.Person[pid]["武功" .. w] < 0 then
				break;
			end
			if JY.Person[pid]["武功" .. w] == 87 then
				JY.Person[pid]["武功等级" .. w] = JY.Person[pid]["武功等级" .. w] + 50
				if JY.Person[pid]["武功等级" .. w] > 999 then
					JY.Person[pid]["武功等级" .. w] = 999
				end
				break;
			end
		end
    end
	
	--蒙哥，气攻+2000点
	if pid == 627 then
		ng = ng + 2000
	end
    --论剑风清扬奖励
    if pid == 0 and JY.Person[592]["论剑奖励"] == 1	then
	   ng = ng + 1000
	end
    
    --萧半和使用混元功增加1000气攻
    if match_ID(pid,189) and wugong ==90 then
       ng = ng +1000
    end     

    --东方其疾如风
    if match_ID(pid,27) and inteam(pid) == false and WAR.ZDDH == 348 and JLSD(10,40,pid) then
			WAR.Person[id]["特效动画"] = 6
			Set_Eff_Text(id,"特效文字0","其疾如风");
			--WAR.FLHS1 = 1
			WAR.PD['疾如风'][pid] = (WAR.PD['疾如风'][pid] or 0) + 1
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[WAR.CurID]["我方"] then
					WAR.Person[j].Time = WAR.Person[j].Time + 100
				end
				if WAR.Person[j].Time > 980 then
					WAR.Person[j].Time = 980
			   end
		  end
	end
		
	--其疾如风
	if match_ID(pid, 9973) and JLSD(10,40,pid) then 
		WAR.Person[id]["特效动画"] = 6
		Set_Eff_Text(id, "特效文字0", "其疾如风")
		WAR.PD['疾如风'][pid] = (WAR.PD['疾如风'][pid] or 0) + 1
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[WAR.CurID]["我方"] then
				WAR.Person[j].Time = WAR.Person[j].Time + 100
			end
			if WAR.Person[j].Time > 980 then
				WAR.Person[j].Time = 980
			end
		end
	end

	--乔峰侵略如火
	if match_ID(pid,50) and not inteam(pid) and WAR.ZDDH == 348 and JLSD(10,50,pid) then
		WAR.Person[id]["特效动画"] = 6
		Set_Eff_Text(id,"特效文字0","侵略如火");
		ng = ng + 2000
	end
		
		--乔峰侵略如火
	if match_ID(pid,9972) and JLSD(10,50,pid) then
        WAR.PD['侵如火'][pid] = 1
		WAR.Person[id]["特效动画"] = 6
		Set_Eff_Text(id,"特效文字0","侵略如火");
		ng = ng + 1000
	end

	
	   --萧秋水 天书加力
    if match_ID(pid, 652) then
		ng = ng + 1000

		WAR.Person[id]["特效动画"] = 83
		if WAR.Person[id]["特效文字2"] ~= nil then
			WAR.Person[id]["特效文字2"] = WAR.Person[id]["特效文字2"].."+忘情天书"
		else
			WAR.Person[id]["特效文字2"] = "忘情天书加力"
		end
    end	


	--鸠摩智
	if match_ID(pid, 103) and (inteam(pid)==false or JLSD(20,70+JY.Base["天书数量"]+math.modf(JY.Person[pid]["实战"]/50),pid)) then
		ng = ng + 600

		WAR.Person[id]["特效动画"] = math.fmod(98, 10) + 85
		Set_Eff_Text(id, "特效文字2", "明王真气")
	end
	
	--成昆
    if match_ID(pid, 18) and (inteam(pid)==false or JLSD(20,70+JY.Base["天书数量"]+math.modf(JY.Person[pid]["实战"]/50),pid)) then
		ng = ng + 600

		WAR.Person[id]["特效动画"] = 6
		if WAR.Person[id]["特效文字2"] == nil then
			WAR.Person[id]["特效文字2"] = "混元霹雳功加力"
		else
			WAR.Person[id]["特效文字2"] = WAR.Person[id]["特效文字2"].."+混元霹雳功"
		end
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = "魔相·幻阴".."·"..WAR.Person[id]["特效文字3"]
		else
			WAR.Person[id]["特效文字3"] = "魔相·幻阴"
		end
    end
	--何太冲
    if match_ID(pid, 7) then
		ng = ng + 1000

		WAR.Person[id]["特效动画"] = 6
		if WAR.Person[id]["特效文字2"] == nil then
			WAR.Person[id]["特效文字2"] = "太清罡气加力"
		else
			WAR.Person[id]["特效文字2"] = WAR.Person[id]["特效文字2"].."+太清罡气"
		end
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = "太清·道生一".."·"..WAR.Person[id]["特效文字3"]
		else
			WAR.Person[id]["特效文字3"] = "太清·道生一"
		end
    end
	
 	--殷天正
    if match_ID(pid, 12) and (inteam(pid)==false or JLSD(20,70+JY.Base["天书数量"]+math.modf(JY.Person[pid]["实战"]/50),pid)) then
		ng = ng + 500

		WAR.Person[id]["特效动画"] = 67
		Set_Eff_Text(id,"特效文字2","鹰王真气");
    end
	

	
	--brolycjw: 黄药师
    if match_ID(pid, 57) and (inteam(pid)==false or JLSD(20,70+JY.Base["天书数量"]+math.modf(JY.Person[pid]["实战"]/50),pid)) then
		ng = ng + 600

		WAR.Person[id]["特效动画"] = 95
		Set_Eff_Text(id,"特效文字2","奇门奥义");
    end
	

	
	--戚长发
    if match_ID(pid, 594) and (inteam(pid)==false or JLSD(20,70+JY.Base["天书数量"]+math.modf(JY.Person[pid]["实战"]/50),pid)) then
		ng = ng + 600

		WAR.Person[id]["特效动画"] = 93
		Set_Eff_Text(id,"特效文字2","铁锁横江");
    end
	
	--慕容博
    if match_ID(pid, 113) and (inteam(pid)==false or JLSD(20,70+JY.Base["天书数量"]+math.modf(JY.Person[pid]["实战"]/50),pid)) then
		ng = ng + 600

		WAR.Person[id]["特效动画"] = 93
		Set_Eff_Text(id,"特效文字2","参合真气");
    end
	
    --任我行 
    if match_ID(pid, 26) and (inteam(pid)==false or JLSD(20,70+JY.Base["天书数量"]+math.modf(JY.Person[pid]["实战"]/50),pid)) then
		ng = ng + 600

		WAR.Person[id]["特效动画"] = 6
		Set_Eff_Text(id,"特效文字2","魔帝·吸星");
    end
	
	--何铁手
    if match_ID(pid, 83) and (inteam(pid)==false or JLSD(20,70+JY.Base["天书数量"]+math.modf(JY.Person[pid]["实战"]/50),pid)) then
		ng = ng + 500

		WAR.Person[id]["特效动画"] =  92
		Set_Eff_Text(id,"特效文字2","红袖拂风");
    end
	
	--阿紫曼珠沙华，每杀一个人+200气攻
	if match_ID(pid, 47) then
		ng = ng + 200*WAR.MZSH
	end
	
	
    --枯荣
    if match_ID(pid, 102) and (inteam(pid)==false or JLSD(20,70+JY.Base["天书数量"]+math.modf(JY.Person[pid]["实战"]/50),pid)) then
		ng = ng + 600

		WAR.Person[id]["特效动画"] = 23
		if math.random(2) == 1 then
			if WAR.Person[id]["特效文字3"] ~= nil then
				WAR.Person[id]["特效文字3"] = "有常无常·双树枯荣·"..WAR.Person[id]["特效文字3"]
			else
				WAR.Person[id]["特效文字3"] = "有常无常·双树枯荣"
			end
		else
			if WAR.Person[id]["特效文字3"] ~= nil then
				WAR.Person[id]["特效文字3"] = "南北西东·非假非空·"..WAR.Person[id]["特效文字3"]
			else
				WAR.Person[id]["特效文字3"] = "南北西东·非假非空"
			end
		end
    end
    
    --天罡内功到极无误伤，50%几率发动天罡真气·
    if pid == 0 and JY.Base["标准"] == 6 and kfkind == 6 and level == 11 then
		WAR.WS = 1
		if JLSD(25, 75, pid) then
			if WAR.Person[id]["特效文字3"] ~= nil then
				WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"].."+天罡真气·"..JY.Wugong[wugong]["名称"]
			else
				WAR.Person[id]["特效文字3"] = "天罡真气·"..JY.Wugong[wugong]["名称"]
			end
			ng = ng + JY.Wugong[wugong]["攻击力10"]
		end
    end

	
	--斗转幻梦星辰特效动画
	if WAR.DZXYLV[id] == 115 then
		WAR.Person[id]["特效动画"] = 107
    end

	
    --九阴极意1
    if wugong == 11 and (Curr_NG(pid,107) or match_ID(pid,640)) then
		local jy = 0
		---黄衫50% 阴内其它40
		if  WAR.JYSZ == 0 and (JY.Person[pid]["内力性质"] == 0 or JY.Person[pid]["内力性质"] == 3)and (JLSD(20, 60+JY.Base["天书数量"]*2, pid) or WAR.LQZ[pid] == 100) then
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

    if WAR.PD['野球拳'][pid] == 3 then
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
    
    --使用降龙十八掌
    if wugong == 26 then
		local jy = 0
		local xljl = 0
		if PersonKF(pid,204) then
            xljl = 0
		end
		--乔峰必出极意，洪七公，郭靖，拳主角40% 擒龙功15%
		--if match_ID(pid, 50) or ((match_ID(pid, 69) or match_ID(pid, 55) or (pid == 0 and JY.Base["标准"] == 1)) and JLSD(30, 70+xljl, pid)) or (Curr_NG(pid,204) and JLSD(0,xljl*2,pid) then
	    if match_ID(pid, 69) then
			xljl = xljl + 40
		end
        if 	pid == 0 and JY.Base["标准"] == 1 then
			xljl = xljl + 40
		end
		if  match_ID(pid, 55) then
			xljl = xljl + 40
		end
		if Curr_NG(pid,204) then
			xljl = xljl + 15
		end
        if JLSD(30,40+xljl,pid) or 	match_ID(pid, 50) then
          Set_Eff_Text(id, "特效文字3", XL18JY[math.random(8)])		
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
				Set_Eff_Text(id, "特效文字3", XL18[math.random(6)])
				ng = ng + 800
			end
			for i = 1, (1 + (level)) / 2 do
				for j = 1, (1 + (level)) / 2 do
					SetWarMap(WAR.Person[WAR.CurID]["坐标X"] + i * 2 - 1, WAR.Person[WAR.CurID]["坐标Y"] + j * 2 - 1, 4, 1)
					SetWarMap(WAR.Person[WAR.CurID]["坐标X"] - i * 2 + 1, WAR.Person[WAR.CurID]["坐标Y"] + j * 2 - 1, 4, 1)
					SetWarMap(WAR.Person[WAR.CurID]["坐标X"] + i * 2 - 1, WAR.Person[WAR.CurID]["坐标Y"] - j * 2 + 1, 4, 1)
					SetWarMap(WAR.Person[WAR.CurID]["坐标X"] - i * 2 + 1, WAR.Person[WAR.CurID]["坐标Y"] - j * 2 + 1, 4, 1)
				end
			end
		end
    end
    
    
    --双剑合壁，连击文字
	if ShuangJianHB(pid) and (wugong == 39 or wugong == 42 or wugong == 139 )  then
		Set_Eff_Text(id, "特效文字3", SJHBJFZS[math.random(10)])		 
		ng = ng + 800
	    WAR.WS = 1
    end
    
	if ShuangJianHB(pid) == false and wugong == 39 then
		ng = ng + 800
		Set_Eff_Text(id, "特效文字3", QZJFZS[math.random(4)])
    end
    
    if ShuangJianHB(pid) == false and (wugong == 42 or wugong == 139) then
		ng = ng + 800
     	Set_Eff_Text(id, "特效文字3", YLJFZS[math.random(6)])
    end	
	
	--玄冥极意，主角有40%几率触发，暴怒必出，玄冥二老必出
	local xmjy = 0
	if match_ID(pid,647) or match_ID(pid,648) then
		xmjy = 1
	end
	if pid == 0 and (WAR.LQZ[pid] == 100 or JLSD(30, 70, pid)) then
		xmjy = 1
	end
	
	--六脉神剑，50%几率剑气碧烟横
	if wugong == 49 then
	    local jl = 50
	    if PersonKF(pid,207) then
            jl = jl + 10 
            if JLSD(20,jl,pid)  or match_ID(pid,499) then
                WAR.JQBYH = 1
                Set_Eff_Text(id, "特效文字3", "剑气碧烟横")
            end
        end
    end 
	--使用六脉神剑
    if wugong == 49 then
		local jl = 0
    	--学会一阳指
     	if PersonKF(pid, 17) then
			jl = jl + 30
		end
		if myrandom(level+jl, pid) or (match_ID(pid, 53) and myrandom(level+jl, pid)) then
			if WAR.Person[id]["特效文字3"] ~= nil then
				WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "·" ..LMSJ[math.random(6)]
			else
				WAR.Person[id]["特效文字3"] = LMSJ[math.random(6)]
			end
			ng = ng + 1000
			if match_ID(pid, 53) then
				WAR.LMSJwav = 1
				WAR.WS = 1
			end
		end
    end
    
      
    --罗汉拳，易筋经变身，般若掌，60%几率，敌方必出
    if wugong == 1 and PersonKF(pid, 108) then
    	if JLSD(20, 80, pid) then
     	 	WAR.LHQ_BNZ = 1
    	end
    end
      
    --大力金刚掌，易筋经变身，达摩掌，60%几率，敌方必出
    if wugong == 22 and PersonKF(pid, 108)  then
    	if JLSD(40, 100, pid) then
			WAR.JGZ_DMZ = 1
    	end
    end
	

	--五毒神掌，李莫愁用有70%几率变赤练神掌
    if wugong == 3 and match_ID(pid, 161) and JLSD(10, 80, pid) then
		WAR.WD_CLSZ = 1
    end	
   	--丘处机 全真剑法学会先天功 变七星剑法
    if wugong == 39 and match_ID(pid, 68) and PersonKF(pid,100) then
		WAR.QZ_QXJF = 1
    end	   
    --铜人阵，9个强力铜人，直接触发达摩掌
    if pid > 480 and pid < 490 then
		WAR.Person[id]["特效文字2"] = "易经筋加力"
		ng = ng + 1200
		WAR.JGZ_DMZ = 1
    end
    
    --狄云，神经照，追加气攻
    if match_ID(pid, 37) and wugong == 94 and level == 11 then
		WAR.Person[id]["特效文字3"] = "神照功·无影神拳"
		ng = ng + 800
    end
	
    --小昭，圣火，追加气攻
    if match_ID(pid, 66) and wugong == 93 and level == 11 then
		local zs = {"赤沙流虹降心火","恍起未明净萦魂","星引瀚光沙劫海","业火焚心无量尊"}
		WAR.Person[id]["特效文字3"] = zs[math.random(4)]
		ng = ng + 800
    end
	-- 七星剑法
	if WAR.QZ_QXJF == 1 and match_ID(pid,68)then
	ng = ng + 800
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "·七星剑法"
		else
			WAR.Person[id]["特效文字3"] = "七星剑法"
		end
		--50%几率触发再次追加杀气
		if JLSD(20, 70, pid) then
		local zs = {"天枢","天璇","天玑","天权","玉衡","开阳","瑶光"}
			ng = ng + 800
			if WAR.Person[id]["特效文字1"] ~= nil then
				WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·七星剑法".."·"..zs[math.random(7)]
			else
				WAR.Person[id]["特效文字1"] = "七星剑法-".."·"..zs[math.random(7)]
			end
		end
    end
    --莫大，追加气攻
    if match_ID(pid, 20) and (JY.Person[0]["六如觉醒"] > 0 or isteam(pid) == false) then
		local zs = {"沧海一声笑","滔滔两岸潮","纷纷世上潮","浮沉记今朝 "}
		WAR.Person[id]["特效文字3"] = zs[math.random(4)]
		ng = ng + 800
    end	
     --三十二身相追加气攻
    if match_ID(pid, 497) then
		local zs = {"光明相","如狮相","阴藏相","广平相","圆满相","牛王相",}
		WAR.Person[id]["特效文字3"] = zs[math.random(4)]
		ng = ng + 800
    end 
	
    --苗家剑法，为极，配合胡家刀法。 60%刀剑归真
    if wugong == 44 and level == 11 and JLSD(0,60,pid) then
		for i = 1, JY.Base["武功数量"] do
			if JY.Person[pid]["武功" .. i] == 67 and JY.Person[pid]["武功等级" .. i] == 999 then
				Set_Eff_Text(id, "特效文字1", "胡刀苗剑 归真合一")
				WAR.Person[id]["特效动画"] = 6
				WAR.DJGZ = 1
				ng = ng + 1000
				break
			end
		end
    end
    
    --胡家刀法，为极，配合苗家剑法。 60%刀剑归真、
	--胡一刀觉醒不需要
    if wugong == 67 and level == 11 and JLSD(0,60,pid) then
		if match_ID_awakened(pid,633,1) then
			Set_Eff_Text(id, "特效文字1", "胡刀苗剑 归真合一")
			WAR.Person[id]["特效动画"] = 6
			WAR.DJGZ = 1
			ng = ng + 1000
			if WAR.ACT == 1 then
				local  HDJYZS = {"刀剑绝技·胡刀·云龙三现","刀剑绝技·胡刀·拜佛听经","刀剑绝技·胡刀·沙鸥掠波","刀剑绝技·胡刀·参拜北斗","刀剑绝技·胡刀·八方藏刀式"};
				local display = HDJYZS[math.random(5)];
				WAR.Person[id]["特效动画"] = 119
				WAR.PD["刀剑绝技"][pid] = 1
				WAR.ATNum = 2
				TXWZXS(display, M_DeepSkyBlue)
			end
		else
			for i = 1, JY.Base["武功数量"] do
				if JY.Person[pid]["武功" .. i] == 44 and JY.Person[pid]["武功等级" .. i] == 999 or match_ID_awakened(pid,633,1)  then
					Set_Eff_Text(id, "特效文字1", "胡刀苗剑 归真合一")
					WAR.Person[id]["特效动画"] = 6
					WAR.DJGZ = 1
					ng = ng + 1000
					break
				end
			end
		end
    end
	
	--紫气天罗组合，气攻+1000
	if (wugong == 3 or wugong == 120 or wugong == 5 or wugong == 21 or wugong == 118) and ZiqiTL(pid) then
		ng = ng + 800
		Set_Eff_Text(id, "特效文字1", "紫气天罗")
	end
	--主运紫霞，50%几率剑系气攻+1000
    if PersonKF(pid,89)  and kfkind == 3 then
       local jl = 30
	   if Curr_NG(pid,89) then
		jl = 50
		end
		if JLSD(0,jl,pid) or WAR.LQZ[pid] == 100 then
			ng = ng + 800
			Set_Eff_Text(id, "特效文字2", "紫霞剑气")
		end
	end
	--五岳剑气
    if PersonKF(pid,175)  and kfkind == 3 and WAR.ZWYJF == 0 then
       local jl = 30
	   if Curr_NG(pid,175) then
		jl = 50
		end
		if JLSD(0,jl,pid) or WAR.LQZ[pid] == 100 then
			ng = ng + 800
			Set_Eff_Text(id, "特效文字2", "五岳剑气")
		end
	end
		
	--破尽天下，增加2000点气攻
	if WAR.PJTX == 1  then
		ng = ng + 1000
	end 
    --绣花针	
    if WAR.PD["绣花针"][pid] ~= nil and WAR.PD["绣花针"][pid] > 0 then	
		ng = ng + 800
	end
	--大金刚神力，增加1200点气攻
	if WAR.JGSL == 1 then
		ng = ng + 800
	end	
	
	--张家辉的隐身戒指
	if JY.Person[pid]["防具"] == 304 then
		local cd = 40
		if JY.Thing[304]["装备等级"] >=5 then
			cd = 20
		elseif JY.Thing[304]["装备等级"] >=3 then
			cd = 30
		end
		WAR.YSJZ = cd
	end
	
	--装备鸳鸯刀，5级开始，夫妻追加500气攻
	if JY.Person[pid]["武器"] == 217 and wugong == 62 and JY.Thing[217]["装备等级"] >=5 then
		ng = ng + 500
	end
	if JY.Person[pid]["武器"] == 218 and wugong == 62 and JY.Thing[218]["装备等级"] >=5 then
		ng = ng + 500
	end
	
	--五岳剑法组合，50%几率额外气攻+1000，暴怒必发动，学有五岳剑诀必发动
	if wugong >= 30 and wugong <= 34 and WuyueJF(pid) and (WAR.LQZ[pid] == 100 or PersonKF(pid, 175) or JLSD(20, 70, pid))then
		local qg = 500
		--学会五岳剑诀，气攻再加500，无视绝对气防
		if PersonKF(pid, 175) then
			qg = qg + 500
			WAR.ZWYJF = 1
		end
		ng = ng + qg
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = "气贯五岳·"..WAR.Person[id]["特效文字3"]
		else
			WAR.Person[id]["特效文字3"] = "气贯五岳"
		end
	end
    -- 剑魔再临 
	if WAR.JMZL == 2 then
	   ng = ng +800
	   end
    -- 剑魔再临 
	if WAR.DSP_LM1 == 1 then
	   ng = ng +800
	   end	
	--琴棋书画：棋盘招式，额外杀气
	if wugong == 72 and QinqiSH(pid) then
		ng = ng + 800
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "·棋高一着"
		else
			WAR.Person[id]["特效文字3"] = "棋高一着"
		end
		--50%几率触发再次追加杀气
		if JLSD(20, 70, pid) then
			ng = ng + 500
			if WAR.Person[id]["特效文字1"] ~= nil then
				WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·星罗棋布"
			else
				WAR.Person[id]["特效文字1"] = "星罗棋布"
			end
		end
    end

	--沧溟刀法，30%几率，额外杀气，必定流血
	--刀主二次判定
	if wugong == 153 and (JLSD(30, 60, pid) or (pid == 0 and JY.Base["标准"] == 4 and JLSD(30,60,pid))) then
		WAR.CMDF = 1
		ng = ng + 1000
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·颠动沧溟"
		else
			WAR.Person[id]["特效文字1"] = "颠动沧溟"
		end
	end
    -- 龙爪手 额外杀气
	if wugong == 20 then
		ng =ng +800
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·批亢捣虚"
		else
			WAR.Person[id]["特效文字1"] = "批亢捣虚"
		end
	end
	--龙象之力
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
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "+" .."龙象之力"
		else
			WAR.Person[id]["特效文字1"] = "龙象之力"
		end
	end

 	
	--王重阳北斗七闪追加气攻1000点
	if match_ID(pid, 129) and WAR.BDQS > 0 then
		ng = ng + 1000
		local BDQS = {"天枢", "天璇", "天玑", "天权", "玉衡", "开阳", "摇光"}
		if WAR.Person[id]["特效文字2"] ~= nil then
			WAR.Person[id]["特效文字2"] = WAR.Person[id]["特效文字2"] .. "+" .."北斗七闪·"..BDQS[WAR.BDQS]
		else
			WAR.Person[id]["特效文字2"] = "北斗七闪·"..BDQS[WAR.BDQS]
		end
	end

	
	--七伤拳，机率造成内伤17点
	--谢逊必出
	if wugong == 23 and (match_ID(pid, 13) or WAR.LQZ[pid] == 100 or JLSD(30, 60, pid))then
		WAR.YZQS = 1
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "+一震七伤"
		else
			WAR.Person[id]["特效文字1"] = "一震七伤"
		end
	end
 	--玄澄 无量禅震 追加10-15点内伤
	if match_ID(pid,9994) then
	    WAR.XC_WLCZ= 1 
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"].."+无量禅震"
		else
			WAR.Person[id]["特效文字1"] = "无量禅震"
		end
	end	
	
    --钟灵 使用闪电貂，可偷窃，朱聪妙手空空也可
	--陆渐补天劫手  司空摘星
    if (match_ID(pid, 90) and wugong == 113) 
	or (match_ID(pid, 131) and wugong == 116) 
	or match_ID(pid, 497) or match_ID(pid, 579)then
		WAR.TD = -2
		--蓝烟清：挑战战斗不可偷东西
		if WAR.ZDDH == 226 or WAR.ZDDH == 79 or WAR.ZDDH == 354 then
			WAR.TD = -1;
		end
    end
	
	--宋远桥使用太极拳或太极剑攻击后自动进入防御状态
	if match_ID(pid, 171) and (wugong == 16 or wugong == 46) then
		WAR.WDRX = 1
	end

	
	if wugong == 21 and level == 11 and xmjy == 1 then
		Set_Eff_Text(id, "特效文字1", "玄冥极意")
		ng = ng + 1000
		WAR.WS = 1
		TXWZXS("『玄冥神掌·寒阴侵体』", M_DeepSkyBlue)
		for i = 1, 5 do
			for j = 1, 5 do
				SetWarMap(x + i - 1, y + j - 1, 4, 1)
				SetWarMap(x - i + 1, y + j - 1, 4, 1)
				SetWarMap(x + i - 1, y - j + 1, 4, 1)
				SetWarMap(x - i + 1, y - j + 1, 4, 1)
			end
		end
	end		
	--黯然极意
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
	--[[云罗天网
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
	--刀剑绝技
	if WAR.PD["刀剑绝技"][pid] ~= nil and WAR.PD["刀剑绝技"][pid] < 3 then 
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
	
	--九阴极意
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
	
   	--碧海招式5 滔天炁
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
	if WAR.PD["前"][pid] == 1 then
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
	--何铁手五毒随机2-5倍威力
	if match_ID(pid, 83) and  wugong == 3 then
		WAR.HTS = math.random(2, 5)
    end
	--周威信随机2-5倍威力
	if match_ID(pid, 612) and  wugong == 206 then
		WAR.ZWX = math.random(2, 5)
    end	
		--卓天雄随机3倍威力
	if match_ID(pid, 613) and  wugong == 206 then
		WAR.ZWX = 3
    end	
		--卓天雄随机3倍威力
	if match_ID(pid, 613) and  wugong == 205 then
		WAR.ZWX = 2
    end	

    --喵姐 无误伤
    if match_ID(pid, 92) then
		WAR.WS = 1
    end
	
    --欧阳锋 无误伤
    if match_ID(pid, 60) then
		WAR.WS = 1
    end
    
    --东方不败 无误伤
    if match_ID(pid, 27) then
		WAR.WS = 1
    end
	
	--扫地 无误伤
    if match_ID(pid, 114) then
		WAR.WS = 1
    end
	
	--阿青，越女无误伤
	if match_ID(pid, 604) and wugong == 156 then
		WAR.WS = 1
	end
	
	--剑仙剑魔战，独孤无误伤
	if match_ID(pid, 592) and WAR.ZDDH == 291 then
		WAR.WS = 1
	end
    
    --乔峰，郭靖，洪七公，使用降龙十八掌 无误伤
    if (match_ID(pid, 50) or match_ID(pid, 55) or match_ID(pid, 69)) and wugong == 26 then
		WAR.WS = 1
    end
	
    --萧中慧使用夫妻刀法 无误伤
    if match_ID(pid, 77) and wugong == 62 then
		WAR.WS = 1
    end
    
    --令狐冲 二觉之后，使用独孤九剑 无误伤
    if match_ID_awakened(pid, 35, 2) and wugong == 47 then
		WAR.WS = 1
    end
	
	--玉女素心剑 无误伤
	if wugong == 139 then
		WAR.WS = 1
	end
    
    --金轮法王 气攻+2500
    if match_ID(pid, 62) then
		ng = ng + 2000
    end
    
    
    --花铁干，使用中平枪法，气攻+1500
    if match_ID(pid, 52) and wugong == 70 then
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "+" .."中平神枪"
		else
			WAR.Person[id]["特效文字3"] = "中平神枪"
		end
		ng = ng + 1000
    end
   
	
    --张三丰 万法自然，集气从500开始
    if match_ID(pid, 5) and JLSD(0,70,pid) then
		WAR.ZSF = 1
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "+" .."万法自然"
		else
			WAR.Person[id]["特效文字1"] ="万法自然"
		end
    end



	    --陆渐大金刚神力
    if match_ID(pid, 497) and JLSD(0,70,pid) and  WAR.JGFX[pid]~= nil then
		WAR.JGSL = 1
		if WAR.Person[id]["特效文字0"] ~= nil then
			WAR.Person[id]["特效文字0"] = WAR.Person[id]["特效文字0"] .. "+" .."大金刚神力"
		else
			WAR.Person[id]["特效文字1"] ="大金刚神力"
		end
    end
	
	
    --李白 诗酒化行，集气从200开始
    if match_ID(pid, 636) and JLSD(0,70,pid) then
		WAR.QLBLX = 1
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "+" .."诗酒化行"
		else
			WAR.Person[id]["特效文字1"] ="诗酒化行"
		end
    end

    --虚竹  福泽加护，集气从200开始
    if match_ID(pid, 49) and JLSD(0,60,pid) then
		WAR.XZZ = 1
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .."+".."福泽加护"
		else
			WAR.Person[id]["特效文字1"] = "福泽加护"
		end
    end
	
	--封不平狂风快剑，使用剑法回气
    if match_ID(pid, 142) and kfkind == 3 then
		WAR.KFKJ = 1
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .."+".."狂风快剑"
		else
			WAR.Person[id]["特效文字3"] = "狂风快剑"
		end
    end
	
	--九剑真传，荡剑式，攻击后回气+150
	if WAR.JJZC == 4  then
		WAR.JJDJ = 1
	end
    
    --东方不败 萧半和 葵花点穴手，气攻+1000
	--葵尊必出点穴手
    if match_ID(pid, 27) or match_ID_awakened(pid, 189, 1) or (PersonKF(pid, 105) and JLSD(0,30,pid)) then
		ng = ng + 1400
		WAR.BFX = 1
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "+" .."葵花点穴手"
		else
			WAR.Person[id]["特效文字3"] = "葵花点穴手"
		end
    end
    
	--太虚剑意 万剑归宗
    if Curr_NG(pid,152 ) and JLSD(20,70,pid) and kfkind == 3 then
		ng = ng + 1100
		elseif PersonKF(pid,152) and JLSD(20,45,pid) then
		 ng = ng + 600
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "+" .."万剑归宗"
		else
			WAR.Person[id]["特效文字1"] = "万剑归宗"
		end
    end	
    
    if match_ID(pid,510) then
        if JLSD(0,30,pid) then 
            WAR.PD['曲夕烟隙'][pid] = 1
            if WAR.Person[id]["特效文字1"] ~= nil then
                WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .."+".."曲夕烟隙"
            else
                WAR.Person[id]["特效文字1"] = "曲夕烟隙"
            end
            WAR.Person[id]["特效动画"] = 61
        end
        if JLSD(0,30,pid) then 
            WAR.PD['曲径通幽'][pid] = 1
            if WAR.Person[id]["特效文字1"] ~= nil then
                WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .."+".."曲径通幽"
            else
                WAR.Person[id]["特效文字1"] = "曲径通幽"
            end
            WAR.Person[id]["特效动画"] = 61
        end
        
    end

	
	--罗汉伏魔加力文字特效
	--同时学有易筋神功+罗汉伏魔功，主运易筋神功必出“罗汉伏魔”特效
	--石破天必出罗汉伏魔
	if Curr_NG(pid, 96) or (Curr_NG(pid, 108) and PersonKF(pid, 96)) or (match_ID(pid,38) and PersonKF(pid,96)) then
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "+罗汉伏魔";
		else
			WAR.Person[id]["特效文字1"] = "罗汉伏魔"
		end
	end
       --太极拳，借力打力
	   --张三丰使用任何武功
    if Curr_NG(pid,171)  and (wugong == 16 or wugong == 46 ) then
		if WAR.PD["太极蓄力"][pid] == nil then
			WAR.PD["太极蓄力"][pid] = 0
		elseif 0 < WAR.PD["太极蓄力"][pid] then
			if WAR.Person[id]["特效文字3"] ~= nil then
				WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"].."·借力打力"
			else
				WAR.Person[id]["特效文字3"] = "借力打力"
			end
			ng = ng + WAR.PD["太极蓄力"][pid]
		end
    end 
   
	-- 白秀 雪花神剑
    if match_ID_awakened(pid,582,1) and (JLSD(20,50+JY.Base["天书数量"],pid) or WAR.LQZ[pid] == 100) and WAR.DZXY ~= 1 then
	   WAR.BXXHSJ =1
	end
    
	--白秀 雪山剑法
    if wugong == 35 and match_ID_awakened(pid,582,1) and WAR.DZXY ~= 1then
	   ng = ng + 600
	end	
    
	if WAR.BXXHSJ == 1 then
		local exng = 0
		local CN_num = {"一式", "二式", "三式", "四式", "五式", "六式", "七式", "八式", "九式", "十式", "十一式","十二式", "十三式","十四式","十五式"}
		for i = 1, JY.Base["武功数量"] do
			if JY.Person[pid]["武功"..i] ~= 35 and JY.Person[pid]["武功等级"..i] == 999 then
				ng = ng + 100
				exng = exng + 1
			end
		end
		if exng > 0 then
			if WAR.Person[id]["特效文字0"] ~= nil then
				WAR.Person[id]["特效文字0"] = WAR.Person[id]["特效文字0"].."+雪花神剑·"..CN_num[exng]
			else
				WAR.Person[id]["特效文字0"] = "雪花神剑·"..CN_num[exng]
			end
		end
	end
 
	--天山折梅手，杀气提高
	if wugong == 14 and WAR.DZXY ~= 1 then
		local exng = 0
		local CN_num = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一","十二","十三","十四","十五"}
		for i = 1, JY.Base["武功数量"] do
			if JY.Person[pid]["武功"..i] ~= 14 and JY.Person[pid]["武功等级"..i] == 999 then
				ng = ng + 100
				exng = exng + 1
			end
		end
		if exng > 0 then
			if WAR.Person[id]["特效文字3"] ~= nil then
				WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"].."+天山折梅"..CN_num[exng]
			else
				WAR.Person[id]["特效文字3"] = "天山折梅"..CN_num[exng]
			end
		end
	end
  		--棋势伤害
	if match_ID(pid,586) and JY.Base["天书数量"] > 0  and WAR.DZXY ~= 1 then
	    local zs = {" 十王走马势","长气杀有眼","回龙征","一子解双征"}
        local exng = JY.Base["天书数量"]*1
	    local CN_num = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一","十二","十三","十四","十五"}	
	    ng = ng + 1000
	    if WAR.Person[id]["特效文字3"] ~= nil then
	        WAR.Person[id]["特效文字3"] = "奕棋·"..CN_num[exng].."势·"..zs[math.random(4)].."+"..WAR.Person[id]["特效文字3"]
	    else
	        WAR.Person[id]["特效文字3"] ="奕棋·"..CN_num[exng].."势·"..zs[math.random(4)]
	    end	
    end	
    --圣火神功
    if PersonKF(pid,93) and JY.Person[pid]["特殊兵器"] >= 200 then
	   Set_Eff_Text(id, "特效文字3", SHSGZS[math.random(6)])
	   ng = ng + 1200
	   WAR.DHBUFF = 1
	end
	
    --虚竹使用天山六阳掌或折梅手，出生死符，杀集气+1700
    if (wugong == 8 or wugong == 14) and match_ID(pid, 49) and PersonKF(pid, 101) and (JLSD(20, 80, pid) or WAR.NGJL == 98)  and WAR.DZXY ~= 1 then
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"].."+灵鹫宫绝学·生死符"
		else
			WAR.Person[id]["特效文字3"] = "灵鹫宫绝学·生死符"
		end
		ng = ng + 1000
		WAR.TZ_XZ = 1
    end

    --李文秀使用特系攻击，60%的机率大幅度杀集气
    if match_ID(pid, 590) and kfkind == 5 and JLSD(0, 50 + JY.Base["天书数量"]*2 + math.modf(JY.Person[pid]["实战"]/25), pid) then
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"].."+".."心秀天铃·星月争辉"
		else
			WAR.Person[id]["特效文字3"] = "心秀天铃·星月争辉"
		end	
    	ng = ng + 800
		--如有14天书，则忽视绝对气防
		if JY.Base["天书数量"] >= 14 then
			WAR.LWX = 1
		end
    end
	--黄衫女 广寒清辉
		--暴怒必触发
	if match_ID(pid, 640) and JY.Person[0]["六如觉醒"] > 0  and (JLSD(0, 10 + JY.Base["天书数量"]*1,  pid) or WAR.LQZ[pid] == 100) and WAR.DZXY ~= 1 then
		ng = ng + 1000
		WAR.GHQH = 1
		if WAR.Person[id]["特效文字0"] ~= nil then
			WAR.Person[id]["特效文字0"] = WAR.Person[id]["特效文字3"].."·".."广寒清辉"
		else
			WAR.Person[id]["特效文字0"] = "广寒清辉"
		end
	
	end
    -- 双剑合壁.攻击
	if ShuangJianHB(pid) and (wugong == 39 or wugong == 42 or wugong == 139)  then
	WAR.SJHB_G = 1
	end
	--梁萧谐之道
	--梁萧华山觉醒领悟谐之道
		if match_ID(pid, 635)  and WAR.LQZ[pid] == 100 and (JY.Person[pid]["六如觉醒"] > 0 or isteam(pid) == false) then
		   ng = ng + 1000
			WAR.LXXZD = 1
			if WAR.Person[id]["特效文字0"] ~= nil then
				WAR.Person[id]["特效文字0"] = WAR.Person[id]["特效文字0"].."·".."谐之道·天道有常"
			else
				WAR.Person[id]["特效文字0"] = "谐之道·天道有常"
				WAR.Person[id]["特效动画"] = 126
			end	
         end
			
	--王语嫣御法绝尘
	local YufaJC = 0
	for i = 0, WAR.PersonNum - 1 do
		local yfid = WAR.Person[i]["人物编号"]
		if WAR.Person[i]["死亡"] == false and WAR.Person[i]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and match_ID(yfid, 76) and Xishu_sum(yfid) >= 500 then
			YufaJC = 1
			break
		end
	end
	
	--武功招式加杀集气
	if YufaJC == 0 then
		--风清扬，暴怒九剑触发无招胜有招
		if match_ID(pid, 140) and wugong == 47 and WAR.LQZ[pid] == 100 then
			if WAR.Person[id]["特效文字3"] ~= nil then
				WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"].."·".."无招胜有招"
			else
				WAR.Person[id]["特效文字3"] = "无招胜有招"
			end
			ng = ng + 2000
			WAR.FQY = 1

		--看有没有招式
		elseif CC.KFMove[wugong] ~= nil then
			--npc必出招，小无相功加力必出招式，暴怒必出招式，辟邪必出招，太玄必出招
			if inteam(pid) == false or myrandom(level, pid) or WAR.NGJL == 98 or WAR.LQZ[pid] == 100 or ((wugong == 48 or wugong == 102 or wugong == 106) and level == 11 and WAR.DZXY == 0)  or (wugong == 151  and level == 11 and PersonKF(pid,152)) then
				local num
				if wugong == 48 and level == 11 and inteam(pid) and WAR.DZXY ~= 1 and WAR.AutoFight == 0 then		--辟邪招式固定
					num = WAR.BXZS
				--elseif  inteam(pid) and WAR.DZXY ~= 1 and WAR.AutoFight == 0 then		--碧海招式固定
				--	num = WAR.LXBHZS	
				elseif	wugong == 106 and inteam(pid) and level == 11 and WAR.DZXY ~= 1 and WAR.AutoFight == 0  then		--九阳招式固定
					num = WAR.JYZS					
				elseif wugong == 102 and level == 11 and inteam(pid) and match_ID_awakened(pid, 38, 1)  and WAR.DZXY ~= 1 and WAR.AutoFight == 0 then	--太玄招式固定
					num = WAR.TXZS								
				else
					local choice = math.random(#CC.KFMove[wugong])											--从数组从随机抽取一个
					num = choice
					if wugong == 102 and WAR.TXZS == 0 then
						WAR.TXZS = choice
					end
				end
				if WAR.Person[id]["特效文字3"] ~= nil then
					WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"].."·"..CC.KFMove[wugong][num][1]
				else
					WAR.Person[id]["特效文字3"] =CC.KFMove[wugong][num][1]
				end
				ng = ng + CC.KFMove[wugong][num][2]
			end
		end
	end
	
	--张三丰，50%机率增加气攻
    if match_ID(pid, 5) and WAR.Person[id]["特效文字3"] ~= nil and JLSD(30, 80, pid) then
		WAR.Person[id]["特效文字3"] = "化朽为奇" .. "·" .. WAR.Person[id]["特效文字3"]
		ng = ng + get_skill_power(pid, wugong, 11)
    end
	
	--王重阳，全真剑法，60%几率重阳剑气777气攻
	if wugong == 39 and match_ID(pid, 129) and JLSD(20, 80, pid) then
		ng = ng + 777
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = "重阳剑气·"..WAR.Person[id]["特效文字3"]
		else
			WAR.Person[id]["特效文字3"] = "重阳剑气"
		end
	end
	-- 九字真言 斗
	if WAR.PD["斗"][pid]~= nil and WAR.PD["斗"][pid] ==1 then
		ng = ng + 800
    end
	--弹指神通，配合桃花绝技，气攻+1000
	if wugong == 18 and TaohuaJJ(pid) then
		ng = ng + 1000
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "·无影神石"
		else
			WAR.Person[id]["特效文字3"] = "无影神石"
		end
	end
    --打狗棒法 极意
    if wugong == 80 and level == 11  then
	   local jl = 50
	   if JY.Person[pid]["武器"] == 218 and JY.Thing[218]["装备等级"] >=5 then
	      jl = jl + 10
	   end
	   if pid == 0 and JY.Base["标准"] == 5 then
	      jl = jl + 5
	   end
	   if Curr_NG(204,pid) then
	      jl = jl + 10
	   end
	   if WAR.LQZ[pid] == 100 or jl > Rnd(100) then	
		    if WAR.Person[id]["特效文字3"] ~= nil then
			   WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "·打狗棒法绝学--天下无狗"
		    else
			   WAR.Person[id]["特效文字3"] = "打狗棒法绝学--天下无狗"
		       WAR.Person[id]["特效动画"] = 89
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

    --蓝烟清：胡家刀法，极意
    --刀系主角40%，胡斐50%，暴怒必出
	--胡一刀70%
    if wugong == 67 and level == 11 and WAR.PD["刀剑绝技"][pid] == nil and ((((pid == 0 and JY.Base["标准"] == 4)
	and (WAR.LQZ[pid] == 100 or JLSD(30,70,pid))))or (match_ID(pid, 633) and (WAR.LQZ[pid] == 100 or JLSD(20,80,pid)))
	or (match_ID(pid, 1) and (WAR.LQZ[pid] == 100 or JLSD(20,70,pid)))) then
		local HDJY = {"极意·伏虎式","极意·拜佛听经","极意·穿手藏刀","极意·沙鸥掠波","极意·参拜北斗","极意·闭门铁扇刀",
		"极意·缠身摘心刀","极意·进步连环刀","极意·八方藏刀式"};
		WAR.Person[id]["特效文字3"] = HDJY[math.random(9)];
		WAR.Person[id]["特效动画"] = 6
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
				
    --杨过，神雕，标主剑神 玄铁极意
	--无招式时必触发，暴怒时必出
    if wugong == 45 and level == 11 and (match_ID(pid, 58) or match_ID(pid, 628) or (pid == 0 and JY.Base["标准"] == 3) ) 
	   and (WAR.LQZ[pid] == 100 or WAR.Person[id]["特效文字3"] == nil) then
		--WAR.Person[id]["特效文字3"] = "重剑真传·浪如山涌剑如虹"
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "+重剑真传·浪如山涌剑如虹"
		else
			WAR.Person[id]["特效文字3"] = "重剑真传·浪如山涌剑如虹"
		end
		WAR.Person[id]["特效动画"] = 84
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
    
    
    --葵花神功 刺目
    if wugong == 48 and PersonKF(pid, 105) then
		WAR.KHBX = 2
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "·辟邪刺目"
		else
			WAR.Person[id]["特效文字3"] = "辟邪刺目"
		end
		--WAR.Person[id]["特效文字1"] = "真辟邪剑法·葵花刺目";
		WAR.Person[id]["特效动画"] = 6
    end
	--六合迟缓
	--萧半和觉醒就有 
	if Curr_NG(pid, 105) and JLSD(20,70,pid) then
		WAR.KHLH = 1
		WAR.WS=1
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·葵花六合"
		else
			WAR.Person[id]["特效文字1"] = "葵花六合"
		end
		--WAR.Person[id]["特效文字1"] = "葵花诀·六合";
		WAR.Person[id]["特效动画"] = 6	
	end	
        
	--葵花尊者必刺目
	if match_ID(pid,27) or (PersonKF(pid,105) and JLSD(10,20,pid)) or (Curr_NG(pid,105) and JLSD(0,30,pid)) then
		WAR.KHBX = 2
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "·葵花刺目"
		else
			WAR.Person[id]["特效文字3"] = "葵花刺目"
		end
		--WAR.Person[id]["特效文字1"] = "葵花刺目";
		WAR.Person[id]["特效动画"] = 6
	end
  
    --盲目状态，20%几率攻击无效
    if WAR.KHCM[pid] == 2 and JLSD(0,50,pid) then
		WAR.MMGJ = 1
		WAR.Person[id]["特效动画"] = 89
		WAR.Person[id]["特效文字2"] = "盲目状态·攻击无效"
    end
    
    -- 开太极 WAR.PD["太极蓄力"][pid] > 600
    if Curr_NG(pid,171) and (wugong == 16 or  wugong == 46) and WAR.LQZ[pid] == 100 and ((WAR.PD["太极蓄力"][pid]~= nil and 
        WAR.PD["太极蓄力"][pid]>=600) or (WAR.TJZX[pid] ~= nil and WAR.TJZX[pid] >= 8)) then
		--WAR.Person[WAR.CurID]["体力点数"] = (WAR.Person[WAR.CurID]["生命点数"] or 0) + AddPersonAttrib(pid, "体力", -math.modf(JY.Person[pid]["体力"]/10));
		--WAR.Person[WAR.CurID]["内力点数"] = (WAR.Person[WAR.CurID]["内力点数"] or 0) + AddPersonAttrib(pid, "内力", -math.modf(JY.Person[pid]["内力"]/10))
	    local qg = JY.Person[pid]["内力"]/JY.Person[pid]["内力最大值"]*1200
	    WAR.WDKTJ = 1
	    ng = ng+ qg
		local size = 60
		local x = CC.ScreenW/2;
        local y = CC.ScreenH/2;
        local offx = (#"【太一初分.开太极】")*size/4
        local offy = size/2
		for k = 1,10 do
			Cat('实时特效动画')
			Cls()
			lib.Background(0,y-50,CC.ScreenW,y+50,98)
			DrawString(x-offx,y-offy,"【太一初分.开太极】",C_GOLD,size);  
			ShowScreen();
			lib.Delay(CC.BattleDelay)
		end
	end



	--李白七书觉醒后
	if (match_ID_awakened(pid, 636,1) or (not inteam(pid) and match_ID(pid,636)))  and kfkind == 3 and WAR.LQZ[pid] == 100 then
		WAR.QLJG  = 1
		ng = ng + 1500
		local size = 60
		local x = CC.ScreenW/2;
        local y = CC.ScreenH/2;
        local offx = (#"【绝技·青莲剑歌】")*size/4
        local offy = size/2
		for k = 1,10 do
			Cat('实时特效动画')
			Cls()
			lib.Background(0,y-50,CC.ScreenW,y+50,98)
			DrawString(x-offx,y-offy,"【绝技·青莲剑歌】",C_GOLD,size);  
			ShowScreen();
			lib.Delay(CC.BattleDelay)
		end
	end
	--袁承志觉醒后，生命低于30%，50%几率出金蛇奥义
	if (match_ID_awakened(pid, 54, 1) and wugong == 40 and JY.Person[pid]["生命"] <= (JY.Person[pid]["生命最大值"]*0.3) and JLSD(20,70,pid)) or  (match_ID(pid,639) and (WAR.LQZ[pid] == 100 or JLSD(10,40,pid))) then
		WAR.JSAY = 1
		ng = ng + 1000
	
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.Person[i]["死亡"] == false then
				local offset1 = math.abs(WAR.Person[WAR.CurID]["坐标X"] - WAR.Person[i]["坐标X"])
				local offset2 = math.abs(WAR.Person[WAR.CurID]["坐标Y"] - WAR.Person[i]["坐标Y"])
				if offset1 <= 5 and offset2 <= 5 then
					SetWarMap(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"], 4, 1)
				end
			end
		end
	end
    
	--血战八方
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
          local offx = (#"【刀法绝技.血战八方】")*size/4
          local offy = size/2
		  for k = 1,10 do
			 Cat('实时特效动画')
			 Cls()
			 lib.Background(0,y-50,CC.ScreenW,y+50,98)
			 DrawString(x-offx,y-offy,"【刀法绝技.血战八方】",C_GOLD,size);  
			 ShowScreen();
			 lib.Delay(CC.BattleDelay)
		  end
		  for i = 0, WAR.PersonNum - 1 do
			 if WAR.Person[i]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.Person[i]["死亡"] == false then
				local offset1 = math.abs(WAR.Person[WAR.CurID]["坐标X"] - WAR.Person[i]["坐标X"])
				local offset2 = math.abs(WAR.Person[WAR.CurID]["坐标Y"] - WAR.Person[i]["坐标Y"])
				if offset1 <= 5 and offset2 <= 5 then
					SetWarMap(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"], 4, 1)
					
				end
			end			
		end
		WAR.XZBF = 0
	end	
  
	--阿九 凤鸣九宵
	if match_ID_awakened(pid, 629,1) and WAR.LQZ[pid] == 100   and JY.Base["单通"] > 0 and WAR.DZXY ~= 1  then	
		WAR.Person[WAR.CurID]["内力点数"] = (WAR.Person[WAR.CurID]["内力点数"] or 0) + AddPersonAttrib(pid, "内力", -math.modf(JY.Person[pid]["内力"]/10))
        WAR.AJFHNP =1 
        WAR.WS =1
		ng = ng + 800
		local size = 60
		local x = CC.ScreenW/2;
        local y = CC.ScreenH/2;
        local offx = (#"【凤鸣九宵.谁主沉浮】")*size/4
        local offy = size/2
		for k = 1,10 do
			Cat('实时特效动画')
			Cls()
			lib.Background(0,y-50,CC.ScreenW,y+50,98)
			DrawString(x-offx,y-offy,"【凤鸣九霄.谁主沉浮】",C_GOLD,size);  
			ShowScreen();
			lib.Delay(CC.BattleDelay)
		end
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.Person[i]["死亡"] == false then
				local offset1 = math.abs(WAR.Person[WAR.CurID]["坐标X"] - WAR.Person[i]["坐标X"])
				local offset2 = math.abs(WAR.Person[WAR.CurID]["坐标Y"] - WAR.Person[i]["坐标Y"])
				if offset1 <= 5 and offset2 <= 5 then
					SetWarMap(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"], 4, 1)
				end
			end
		end
	end	
    
	--莫大，50%几率出七弦无形剑奥义
	if match_ID(pid, 20) and (WAR.LQZ[pid] == 100 or JLSD(35, 85, pid)) then
		--WAR.Person[WAR.CurID]["内力点数"] = (WAR.Person[WAR.CurID]["内力点数"] or 0) + AddPersonAttrib(pid, "内力", -math.modf(JY.Person[pid]["内力"]/10))
		WAR.QXWXJ = 1
		ng = ng + 800
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.Person[i]["死亡"] == false then
				local offset1 = math.abs(WAR.Person[WAR.CurID]["坐标X"] - WAR.Person[i]["坐标X"])
				local offset2 = math.abs(WAR.Person[WAR.CurID]["坐标Y"] - WAR.Person[i]["坐标Y"])
				if offset1 <= 4 and offset2 <= 4 then
					SetWarMap(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"], 4, 1)
				end
			end
		end
	end

	--王重阳1 一气化三清
	if match_ID(pid, 129) and (JY.Person[0]["六如觉醒"] > 0 or isteam(pid) == false) and WAR.LQZ[pid] == 100 then
		WAR.YQFSQ = 1
	end

	--无酒不欢：斗转第四层，幻梦星辰，反击全格
    if WAR.DZXYLV[pid] == 115 then
        CleanWarMap(4, 0)
        for i = 0, WAR.PersonNum - 1 do
            if WAR.Person[i]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.Person[i]["死亡"] == false then
                SetWarMap(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"], 4, 1)
            end
        end
	end

    local pz = math.modf(JY.Person[0]["资质"] / 10)
    
    --主角剑神大招，10格攻击
    if pid == 0 and JY.Base["标准"] == 3 and 120 <= TrueYJ(pid) and 0 < JY.Person[pid]["武功9"] and kfkind == 3 and wugong ~= 43 and JLSD(25, 50 +JY.Person[pid]["御剑能力"]*0.0625, pid) and JY.Person[pid]["六如觉醒"] > 0 then
		CleanWarMap(4, 0)
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.Person[i]["死亡"] == false then
				local offset1 = math.abs(WAR.Person[WAR.CurID]["坐标X"] - WAR.Person[i]["坐标X"])
				local offset2 = math.abs(WAR.Person[WAR.CurID]["坐标Y"] - WAR.Person[i]["坐标Y"])
				if offset1 <= 10 and offset2 <= 10then
					SetWarMap(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"], 4, 1)
				end
			end
		end
		WAR.Person[id]["特效动画"] = 6
		if WAR.Person[id]["特效文字3"] == nil then
			WAR.Person[id]["特效文字3"] = ZJTF[3]
		else
			WAR.Person[id]["特效文字3"] = ZJTF[3] .. "·" .. WAR.Person[id]["特效文字3"]
		end
		ng = ng + 1000
		WAR.WS = 1
		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('实时特效动画')
			Cls()
			NewDrawString(-1, -1, ZJTF[3] .. TFSSJ[3], C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
		WAR.JSYX = 1
    end

    --步惊云 剑廿三  6格
    if match_ID(pid,584) and (JY.Base["天书数量"] > 8 or isteam(pid) == false) and 230 <= TrueYJ(pid) and WAR.LQZ[pid] == 100 and kfkind == 3 then
        CleanWarMap(4, 0)
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.Person[i]["死亡"] == false then
				local offset1 = math.abs(WAR.Person[WAR.CurID]["坐标X"] - WAR.Person[i]["坐标X"])
				local offset2 = math.abs(WAR.Person[WAR.CurID]["坐标Y"] - WAR.Person[i]["坐标Y"])
				if offset1 <= 7 and offset2 <= 7 then
					SetWarMap(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"], 4, 1)
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
			Cat('实时特效动画')
			Cls()
			NewDrawString(-1, -1, " 剑圣再临--" .. "圣灵·『剑廿三』", C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end

		WAR.SL23 = 1
    end

      
    --主角拳系大招
    if pid == 0 and JY.Base["标准"] == 1 and 0 < JY.Person[pid]["武功9"] and 120 <= TrueQZ(pid) and JLSD(25, 50 +JY.Person[pid]["拳掌功夫"]*0.1, pid) and kfkind == 1 and JY.Person[pid]["六如觉醒"] > 0 then
		WAR.Person[id]["特效动画"] = 6
		if WAR.Person[id]["特效文字3"] == nil then
			WAR.Person[id]["特效文字3"] = ZJTF[1]
		else
			WAR.Person[id]["特效文字3"] = ZJTF[1] .. "·" .. WAR.Person[id]["特效文字3"]
		end
		ng = ng + 1000
		WAR.WS = 1

		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('实时特效动画')
			Cls()
			NewDrawString(-1, -1, ZJTF[1] .. TFSSJ[1], C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
		WAR.LXZQ = 1
    end
	
    --主角指法大招
    if pid == 0 and JY.Base["标准"] == 2 and 0 < JY.Person[pid]["武功9"] and 120 <= TrueZF(pid) and JLSD(25, 60 + JY.Person[pid]["指法技巧"]*0.1, pid) and kfkind == 2 and JY.Person[pid]["六如觉醒"] > 0 then
		WAR.Person[id]["特效动画"] = 6
		if WAR.Person[id]["特效文字3"] == nil then
			WAR.Person[id]["特效文字3"] = ZJTF[2]
		else
			WAR.Person[id]["特效文字3"] = ZJTF[2] .. "·" .. WAR.Person[id]["特效文字3"]
		end
		ng = ng + 1000
		WAR.WS = 1
		
		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('实时特效动画')
			Cls()
			NewDrawString(-1, -1, ZJTF[2] .. TFSSJ[2], C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end

		WAR.LXYZ = 1
    end
    
    --主角特系大招
    if pid == 0 and JY.Base["标准"] == 5 and 0 < JY.Person[pid]["武功9"] and 120 <= TrueTS(pid) and JLSD(25, 50 + JY.Person[pid]["特殊兵器"]*0.1, pid) and kfkind == 5 and JY.Person[pid]["六如觉醒"] > 0 then
		WAR.Person[id]["特效动画"] = 6
		if WAR.Person[id]["特效文字3"] == nil then
			WAR.Person[id]["特效文字3"] = ZJTF[5]
		else
			WAR.Person[id]["特效文字3"] = ZJTF[5] .. "·" .. WAR.Person[id]["特效文字3"]
		end
		ng = ng + 1000
		WAR.WS = 1
		
		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('实时特效动画')
			Cls()
			NewDrawString(-1, -1, ZJTF[5] .. TFSSJ[5], C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end

		WAR.GCTJ = 1
    end
    
    --主角刀系大招
    if pid == 0 and JY.Base["标准"] == 4 and 0 < JY.Person[pid]["武功9"] and 120 <= TrueSD(pid) and JLSD(25, 50 + JY.Person[pid]["耍刀技巧"]*0.1, pid) and kfkind == 4 and JY.Person[pid]["六如觉醒"] > 0 then
		WAR.Person[id]["特效动画"] = 6
		if WAR.Person[id]["特效文字3"] == nil then
			WAR.Person[id]["特效文字3"] = ZJTF[4]
		else
			WAR.Person[id]["特效文字3"] = ZJTF[4] .. "·" .. WAR.Person[id]["特效文字3"]
		end
		ng = ng + 1000
		WAR.WS = 1
		
		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('实时特效动画')
			Cls()
			NewDrawString(-1, -1, ZJTF[4] .. TFSSJ[4], C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end

		WAR.ASKD = 1
		--触发后给自己加怒气25
		WAR.YZHYZ = WAR.YZHYZ + 25
    end
 
    --主角天罡大招，内功可触发
    if pid == 0 and JY.Base["标准"] == 6 and 0 < JY.Person[pid]["武功9"] and JLSD(25, 60 + pz, pid) and kfkind == 6 and JY.Person[pid]["六如觉醒"] > 0 then
		WAR.Person[id]["特效动画"] = 6
		if WAR.Person[id]["特效文字3"] == nil then
			WAR.Person[id]["特效文字3"] = ZJTF[6]
		else
			WAR.Person[id]["特效文字3"] = ZJTF[6] .. "·" .. WAR.Person[id]["特效文字3"]
		end
		ng = ng + 1000
		WAR.WS = 1
		
		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('实时特效动画')
			Cls()
			NewDrawString(-1, -1, ZJTF[6] .. TFSSJ[6], C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end

		WAR.JSTG = 1
	end
	
    --主角毒王大招，自身中毒100可触发
    if pid == 0 and JY.Base["标准"] == 9 and 0 < JY.Person[pid]["武功9"] and JLSD(25, 60 + pz, pid) and JY.Person[pid]["中毒程度"] == 100 and JY.Person[pid]["六如觉醒"] > 0 then
		WAR.Person[id]["特效动画"] = 6
		if WAR.Person[id]["特效文字3"] == nil then
			WAR.Person[id]["特效文字3"] = ZJTF[9]
		else
			WAR.Person[id]["特效文字3"] = ZJTF[9] .. "·" .. WAR.Person[id]["特效文字3"]
		end
		WAR.WS = 1
		JY.Person[pid]["中毒程度"] = 0
		
		for n = 1, 20 do
			local i = n
			if i > 10 then 
				i = 10
			end
			Cat('实时特效动画')
			Cls()
			NewDrawString(-1, -1, ZJTF[9] .. TFSSJ[9], C_GOLD, CC.DefaultFont + i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end

		WAR.YTML = 1
	end
	

	--欧阳克，暴怒使用雪山白驼掌，变为灵蛇拳
	if match_ID(pid,61) and wugong == 9 and WAR.LQZ[pid] == 100 then
		WAR.OYK = 1
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·灵蛇拳"
		else
			WAR.Person[id]["特效文字1"] = "灵蛇拳"
		end
	end
	--鲸息功 神鲸歌
	if PersonKF(pid,180) and (JLSD(20,70,pid) or WAR.LQZ[pid] == 100) then
		WAR.JXG_SJG = 1
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·神鲸歌"
		else
			WAR.Person[id]["特效文字1"] = "神鲸歌"
		end
	end	

  --井月八法 寇仲
	if match_ID(pid,578)  and kfkind == 4  then
		local df = 0
		for i = 1, JY.Base["武功数量"] do
			if JY.Wugong[JY.Person[0]["武功" .. i]]["武功类型"] == 4 and JY.Person[0]["武功等级" .. i] == 999 then
				df = df + 1
			end
		end
		local DFWZ = {"不攻", "击奇", "战定", "用谋", "速战", "棋弈", "兵诈", "方圆"}
		if inteam(pid)  then
			WAR.KZJYBF = math.random(0, df)
			if WAR.KZJYBF > 8then
				WAR.KZJYBF = 8
			end
			--保底后三刀
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
	

	--步惊云 排云掌
	if match_ID(pid, 584) and kfkind == 1  then
		local DFWZ = {"一式『流水行云』", "二式『披云戴月』", "三式『翻云覆雨』", "四式『排山倒海』", "五式『乌云蔽日』", "六式『重云深锁』", "七式『撕天排云』", "八式『云海波涛』", 
		"九式『燮云无定』", "十式『殃云天降』", "十一式『云莱仙境』","十二式『愁云惨淡』"}
		if inteam(pid) then
			WAR.BJYPYZ = math.random(0, JY.Base["天书数量"])
			if WAR.BJYPYZ > 12then
				WAR.BJYPYZ = 12
			end
			--保底天书数量-5
			if JY.Base["天书数量"] > 5 then
				if WAR.BJYPYZ < JY.Base["天书数量"] - 5 then
					WAR.BJYPYZ = JY.Base["天书数量"] - 5
				end
			end
		else
			WAR.BJYPYZ = math.random(1, 10)
		end
		if WAR.BJYPYZ > 0 then
			ng = ng + 1000
			if WAR.Person[id]["特效文字0"] ~= nil then
				WAR.Person[id]["特效文字0"] = "排云掌·"..DFWZ[WAR.BJYPYZ].."+"..WAR.Person[id]["特效文字0"]
			else
				WAR.Person[id]["特效文字0"] = "排云掌·"..DFWZ[WAR.BJYPYZ]
			end
		end
	end	

	
	--步惊云 圣灵剑法15~22 "圣灵·『剑十』", "圣灵·『剑十一』", "圣灵·『剑十二』", "圣灵·『剑十三』", "圣灵·『剑十四』","圣灵·『剑十』", "圣灵·『剑十一』", 
		--"圣灵·『剑十二』", "圣灵·『剑十三』", "圣灵·『剑十四』",
	if match_ID(pid, 584) and kfkind == 3 and WAR.SL23 ==0 then
		local txwz = { "圣灵·『剑十五』", "圣灵·『剑十六』", "圣灵·『剑十七』", 
		"圣灵·『剑十八』", "圣灵·『剑十九』", "圣灵·『剑廿』", "圣灵·『剑廿一』", "圣灵·『剑廿二』"}
		if inteam(pid) then
			WAR.BJYJF = math.random(0, JY.Base["天书数量"])
			--保底天书数量-5
			if JY.Base["天书数量"] > 8 then
				if WAR.BJYJF < JY.Base["天书数量"] - 8 then
					WAR.BJYJF = JY.Base["天书数量"] - 8
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
			if WAR.Person[id]["特效文字0"] ~= nil then
				WAR.Person[id]["特效文字0"] = txwz[WAR.BJYJF].."+"..WAR.Person[id]["特效文字0"]
			else
				WAR.Person[id]["特效文字0"] = txwz[WAR.BJYJF]
			end
		end
	end
   --梅花三弄
	if  match_ID(pid,634) then
		local txwz = {"一", "二", "三"}
	    if inteam(pid) then	
	        WAR.MHSN = math.random(1, 3)
		if WAR.MHSN > 0 then
			ng = ng + WAR.MHSN*150
			if WAR.Person[id]["特效文字1"] ~= nil then
				WAR.Person[id]["特效文字1"] = "梅花"..txwz[WAR.MHSN].."弄".."+"..WAR.Person[id]["特效文字1"]
			else
				WAR.Person[id]["特效文字1"] = "梅花"..txwz[WAR.MHSN].."弄"
			end
		end
	end
	end

	--步惊云 圣灵剑法1-9
	if match_ID(pid, 584) and kfkind == 3 and WAR.BJYJF < 1 and WAR.SL23 ==0  then
		local zs = {"圣灵·『剑一』", "圣灵·『剑二』", "圣灵·『剑三』", "圣灵·『剑四』", "圣灵·『剑五』", "圣灵·『剑六』", "圣灵·『剑七』", "圣灵·『剑八』", 
		"圣灵·『剑九』",}
		WAR.Person[id]["特效文字1"] = zs[math.random(9)]
		ng = ng +1000
		end	
	

	--郭靖，降龙连击时随机后劲，有余不尽
	if match_ID(pid, 55) and wugong == 26 and WAR.ACT > 1 then
		local txwz = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一","十二","十三"}
		if inteam(pid) then
			WAR.YYBJ = math.random(0, JY.Base["天书数量"])
			if WAR.YYBJ > 13 then
				WAR.YYBJ = 13
			end
			--保底天书数量-7
			if JY.Base["天书数量"] > 7 then
				if WAR.YYBJ < JY.Base["天书数量"] - 7 then
					WAR.YYBJ = JY.Base["天书数量"] - 7
				end
			end
		else
			WAR.YYBJ = math.random(1, 10)
		end
		if WAR.YYBJ > 0 then
			ng = ng + WAR.YYBJ*150
			if WAR.Person[id]["特效文字1"] ~= nil then
				WAR.Person[id]["特效文字1"] = "降龙·有余不尽·"..txwz[WAR.YYBJ].."重后劲".."+"..WAR.Person[id]["特效文字1"]
			else
				WAR.Person[id]["特效文字1"] = "降龙·有余不尽·"..txwz[WAR.YYBJ].."重后劲"
			end
		end
	end

    --万佛朝宗
	if match_ID(pid,577) and (JLSD(20,45,pid) or WAR.WFCZ[pid]>=5) then
       WAR.PD["万佛朝宗"][pid] = 1
	   TXWZXS("万佛朝宗", C_GOLD)
	   if WAR.WFCZ[pid]>=5 then
		  WAR.WFCZ[pid] = 0
		end
	end 
	--仁者
	if JY.Base["标准"] == 7 and pid == 0  and JY.Person[pid]["品德"] == 120 then
		WAR.SEYB =1
		TXWZXS("善恶有报", M_DeepSkyBlue)
	end
 -- 陆无双 五毒
	if match_ID_awakened(pid,580,1)  and (JLSD(20,70,pid) or WAR.LQZ[pid]==100) then
	   WAR.LWSWD = 1 
	 if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·五毒真经"
		else
			WAR.Person[id]["特效文字1"] = "五毒真经"
		end
    end
 -- 文泰来 雷动九天
	if match_ID(pid,151) and WAR.LQZ[pid] == 100 then
	   WAR.LDJT = 1 
	 if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·雷动九天"
		else
			WAR.Person[id]["特效文字1"] = "雷动九天"
		end
    end	
	--黄赏，大伏魔拳
	if match_ID(pid, 637)  and (JLSD(10,30+JY.Base["天书数量"],pid) or WAR.LQZ[pid]==100) then
		WAR.DFMQ = 1
		WAR.WS = 1
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·大伏魔拳"
		else
			WAR.Person[id]["特效文字1"] = "大伏魔拳"
		end
    end
	--阿青，天元剑气
	if match_ID(pid, 604) and kfkind == 3 then
		WAR.TYJQ = 1
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·天元剑气"
		else
			WAR.Person[id]["特效文字1"] = "天元剑气"
		end
	end 


   -- 独孤无视一半剑系
    if match_ID(pid,592) then
		WAR.WWWJ = 1
    end
		
   -- 般若金刚掌
    if (wugong == 22 or wugong == 289) and JinGangBR(pid) then
		WAR.PD["金刚般若"][pid] = 1
    end
	--混元功
    if (Curr_NG(pid, 90) and (JLSD(20,90,pid) or WAR.LQZ[pid] == 100)) or match_ID(pid,189) then
       WAR.HYYQ = 1	   
	   if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·混元一气"
		else
			WAR.Person[id]["特效文字1"] = "混元一气"
	   end
    end  
	--七宝琉璃
	if JY.Person[pid]["武器"] == 200 and JY.Thing[200]["装备等级"] == 6 and JLSD(0, 40, pid) then
		WAR.QBLL = 1
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·七宝琉璃"
		else
			WAR.Person[id]["特效文字1"] = "七宝琉璃"
		end
    end	
   --世尊降魔
   if ShiZunXM(pid) then
   	   local ex_chance = 0
	   if JY.Person[pid]["武器"] == 323 then
			ex_chance = JY.Thing[323]["装备等级"] * 2
	   end
       if (wugong == 96 or wugong == 86 or wugong == 82 or wugong == 83 ) and (JLSD(20,60+ex_chance,pid) or WAR.LQZ[pid] == 100) then
           WAR.SZXM = 1
       if WAR.Person[id]["特效文字0"] ~= nil then
			WAR.Person[id]["特效文字0"] = WAR.Person[id]["特效文字0"] .. "·世尊降魔"
	   else
			WAR.Person[id]["特效文字0"] = "世尊降魔"
	   end
       end
    end	
	--阿九 凤鸣九宵
	if match_ID(pid, 629) and  WAR.AJFHNP == 1 then
	   WAR.Person[id]["特效动画"] = 154
    end	
	--宁中则 玉女十九剑
	if match_ID(pid, 649) and kfkind == 3 then
		WAR.YLSJJ = 1
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·玉女十九剑"
		else
			WAR.Person[id]["特效文字1"] = "玉女十九剑"
		end
    end	
	--宁中则 宁氏一剑
	if match_ID(pid, 649) and kfkind == 3 and (JLSD(20,80,pid) or WAR.LQZ[pid] == 100) then
		WAR.NZZ1 = 1
		if WAR.Person[id]["特效文字0"] ~= nil then
			WAR.Person[id]["特效文字0"] = WAR.Person[id]["特效文字0"] .. "·宁氏一剑·无双无对"
		else
			WAR.Person[id]["特效文字0"] = "宁氏一剑·无双无对"
		end
    end		
	--西门吹雪
	if match_ID_awakened(pid, 500,1)  then
		WAR.XMJDHS = 1
		ng = ng +1000
		if WAR.Person[id]["特效文字0"] ~= nil then
			WAR.Person[id]["特效文字0"] = WAR.Person[id]["特效文字0"] .. "剑道化身·破苍穹"
		else
			WAR.Person[id]["特效文字0"] = "剑道化身·破苍穹"
		end
    end	
	--陆渐海之道，上善若水，敌方系数按0算
	if match_ID(pid, 497) and JY.Person[0]["六如觉醒"] > 0 and JY.Base["天书数量"] > 9 and  WAR.LQZ[pid] == 100 then
		WAR.HZD_1 = 1
		if WAR.Person[id]["特效文字0"] ~= nil then
			WAR.Person[id]["特效文字0"] = WAR.Person[id]["特效文字0"] .. "·上善若水"
		else
			WAR.Person[id]["特效文字0"] = "上善若水"
		end
    end


	--林朝英，流风回雪
	if match_ID(pid, 605) and JLSD(20, 80, pid) then
		WAR.LFHX = 1
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "·流风回雪"
		else
			WAR.Person[id]["特效文字3"] = "流风回雪"
		end
    end
			--萧秋水 火延
	if (match_ID(pid, 652) or Curr_NG(pid,177)) and JLSD(0, 35, pid) and JY.Base["天书数量"] > 2  then
        WAR.PD['火延'][pid] = 1
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "·火延"
		else
			WAR.Person[id]["特效文字3"] = "火延"
		end
    end
		--萧秋水 水逝
	if (match_ID(pid, 652)  or Curr_NG(pid,177)) and JY.Base["天书数量"] > 1 and JLSD(0, 35, pid) then
		WAR.LFHX = 1
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "·水逝"
		else
			WAR.Person[id]["特效文字3"] = "水逝"
		end
    end
	
	--七夕黄蓉，打狗缠字诀
	if wugong == 80 and match_ID(pid, 613) then
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "+打狗棒法·缠字诀"
		else
			WAR.Person[id]["特效文字1"] = "打狗棒法·缠字诀"
		end
	end
	
	--进阶泰山，使用后30时序内闪避
	if wugong == 31 and PersonKF(pid,175) then
		WAR.TSSB[pid] = 30
	end

	--身藏身与名，使用后10时序内闪避
	if match_ID(pid, 636) then
		WAR.QLJX[pid] = 30
	end
	
	--碧海招式2 生灭道
	if WAR.BHJTZ3 == 1 and WAR.BTZT[pid]== nil then
		WAR.BTZT[pid] = 1
	end	
	   --陆渐金刚法相
	if match_ID(pid, 497) then
		WAR.JGFX[pid] = 100
	end	



    --九阳神功招式3 ，使用后100时序内大回复
	if  WAR.JYZS ==3 then
		WAR.CSHF[pid] = 100
	end	

	--主运天罗地网，减少敌方移动
	if Curr_QG(pid,148) then
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "+柔网势"
		else
			WAR.Person[id]["特效文字1"] = "柔网势"
		end
	end
		
	--无酒不欢：举火燎原，金乌+燃木+火焰刀，引燃效果，平时50%几率，暴怒必出
	--寇仲
	if ((wugong == 61 or wugong == 65 or wugong == 66)  and JuHuoLY(pid)) 
	or (match_ID(pid,578) and JY.Person[pid]["内力性质"] == 1 and (WAR.LQZ[pid] == 100 or JLSD(20,70,pid))) then
		Set_Eff_Text(id,"特效文字1","举火燎原")
		WAR.JuHuo = 1
	end
	-- 林殊概率引燃
	if match_ID(pid,508) and JLSD(20,30,pid) then
		WAR.JuHuo = 1
    end		
	--丁当，平时50%几率，暴怒必出
	if match_ID_awakened(pid,581,1) and wugong == 61 and (WAR.LQZ[pid] == 100 or JLSD(20,40,pid)) then
		Set_Eff_Text(id,"特效文字1","举火燎原")
		WAR.JuHuo = 1
	end	
	--无酒不欢：利刃寒锋，修罗+阴风+沧溟，冻结效果，平时50%几率，暴怒必出
	if (wugong == 58 or wugong == 174 or wugong == 153) and LiRenHF(pid) and (WAR.LQZ[pid] == 100 or JLSD(20,70,pid)) then
		Set_Eff_Text(id,"特效文字1","利刃寒锋")
		WAR.LiRen = 1
	end
	
	--逍遥御风
	if XiaoYaoYF(pid) and JLSD(20,70,pid) and (WAR.XYYF[pid] == nil or WAR.XYYF[pid] < 9) and WAR.YFCS < 3 then
		WAR.YFCS = WAR.YFCS + 1
		WAR.XYYF[pid] = (WAR.XYYF[pid] or 0) + 1
		Set_Eff_Text(id,"特效文字0","逍遥御风")
		if WAR.XYYF[pid] == 9 then
			WAR.XYYF[pid] = 11
		end
	end

	--主运太玄，太玄之重，不加怒
	if Curr_NG(pid, 102) and JLSD(20, 35 + math.modf(JY.Person[pid]["实战"]/25), pid)  then
		WAR.TXZZ = 1
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·太玄之重"
		else
			WAR.Person[id]["特效文字1"] = "太玄之重"
		end
    end
	--一灯用一阳指，无明业火
	if match_ID(pid, 65) and wugong == 17 then
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = "无明业火·"..WAR.Person[id]["特效文字1"]
		else
			WAR.Person[id]["特效文字1"] = "无明业火"
		end
	end
	--王重阳1，同归剑法
	if match_ID(pid, 129) and JLSD(20,60,pid) then
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = "同归剑法·"..WAR.Person[id]["特效文字1"]
		else
			WAR.Person[id]["特效文字1"] = "同归剑法"
		end
	end	
	
	--周伯通空明之武道使敌方不会护体，初始几率25%，每20点实战+1%几率
	if match_ID(pid, 64) and JLSD(20, 45 + math.modf(JY.Person[pid]["实战"]/20), pid) then
		WAR.KMZWD = 1
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = "空明之武道·"..WAR.Person[id]["特效文字1"]
		else
			WAR.Person[id]["特效文字1"] = "空明之武道"
		end
    end
	
	--九剑真传，剑法主动攻击70%几率触发4种特效之一
	if  (match_ID(pid,9974) or match_ID_awakened(pid,35,2) or (pid == 0 and JY.Person[241]["品德"] == 80)) and kfkind == 3 and JLSD(15, 85,pid) then
		local t = math.random(4)
		local wz = {"离剑式","倒剑式","撩剑式","荡剑式"}
		WAR.JJZC = t
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .."+九剑真传·"..wz[t]
		else
			WAR.Person[id]["特效文字1"] = "九剑真传·"..wz[t]
		end
	end
	--剑魔再临，剑法主动攻击50%几率触发2种特效之一
	if ((pid == 0 and JY.Person[242]["品德"] == 90 and JLSD(15, 65,pid)) or match_ID(pid,9975) or (match_ID(pid,58) and CC.TX['杨过剑魔'] == 1 )) and kfkind == 3 then	
		local t = math.random(2)
		local wz = {"剑魔再临·天极剑渊","剑魔再临·破尽天下"}
		WAR.JMZL = t
		TXWZXS(wz[t], M_Red)
	end
	
	--琴棋书画：持瑶琴，不加怒
	if wugong == 73 and QinqiSH(pid) then
		WAR.QQSH1 = 1
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·琴音悦耳"
		else
			WAR.Person[id]["特效文字1"] = "琴音悦耳"
		end
		--50%几率触发清怒
		if JLSD(20, 70, pid) then
			WAR.QQSH1 = 2
			if WAR.Person[id]["特效文字1"] ~= nil then
				WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "·菩提清心"
			else
				WAR.Person[id]["特效文字1"] = "菩提清心"
			end
		end
    end
	
	--琴棋书画：妙笔丹青，冰封
	if wugong == 142 and QinqiSH(pid) then
		--60%几率冰封
		if JLSD(20, 80, pid) then
			WAR.QQSH2 = 1
			if WAR.Person[id]["特效文字3"] ~= nil then
				WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "·画地为牢"
			else
				WAR.Person[id]["特效文字3"] = "画地为牢"
			end
		end
		
		--30%几率大冰封
		if JLSD(30, 60, pid) then
			WAR.QQSH2 = 2
			if WAR.Person[id]["特效文字3"] ~= nil then
				WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "·江山如画"
			else
				WAR.Person[id]["特效文字3"] = "江山如画"
			end
		end
	end
	
	--琴棋书画：倚天屠龙功，50%几率出特效，伤害提高20%，必封穴
	if wugong == 84 and QinqiSH(pid) and JLSD(20, 70, pid) then
		WAR.QQSH3 = 1
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "·秉笔直书"
		else
			WAR.Person[id]["特效文字3"] = "秉笔直书"
		end
	end
	
	--梁萧 星罗散手，必封穴
	if match_ID(pid,635) then
		WAR.SLSS = 1
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "+星罗散手"
		else
			WAR.Person[id]["特效文字3"] = "星罗散手"
		end
	end	
	
	--主运玉女：夭矫空碧，连击伤害杀气不减
	--黄衫女必发动
	if ((Curr_NG(pid, 154) and (JLSD(30, 60 + JY.Base["天书数量"]*2, pid))) or (match_ID(pid,640)and PersonKF(pid,154) and JLSD(30,80))) and WAR.ACT > 1then
		WAR.YNXJ = 1
		if WAR.Person[id]["特效文字0"] ~= nil then
			WAR.Person[id]["特效文字0"] = WAR.Person[id]["特效文字0"] .. "+夭矫空碧"
		else
			WAR.Person[id]["特效文字0"] = "夭矫空碧"
		end
    end
	--萧秋水 剑气飞纵 连击伤害杀气不减
	if  match_ID(pid,652) and JY.Base["天书数量"] > 5 then
		WAR.YNXJ = 1
		if WAR.Person[id]["特效文字0"] ~= nil then
			WAR.Person[id]["特效文字0"] = WAR.Person[id]["特效文字0"] .. "+剑气飞纵"
		else
			WAR.Person[id]["特效文字0"] = "剑气飞纵"
		end
    end	
	
    --怒气暴发，气攻+1200
    if WAR.LQZ[pid] == 100 and WAR.DZXY ~= 1 then
		WAR.HXZYJ = 1
		WAR.Person[id]["特效动画"] = 6
		ng = ng + 1200
    end
	
	--全真七子，天罡北斗阵，文字显示
	if WAR.ZDDH == 73 then
		if (pid >= 123 and pid <= 128) or pid == 68 then
			WAR.Person[id]["特效动画"] = 93
			if WAR.Person[id]["特效文字2"] ~= nil then
				WAR.Person[id]["特效文字2"] = WAR.Person[id]["特效文字2"] .. "+天罡北斗阵加力"
			else
				WAR.Person[id]["特效文字2"] = "天罡北斗阵加力"
			end
		end
	end
	
    --蓄力攻击
    if WAR.Actup[pid] ~= nil then
    	--主运蛤蟆，追加杀气
		if Curr_NG(pid, 95)  then
			ng = ng + 1200
		else
			ng = ng + 600
		end
		local str = "蓄力攻击"
		if WAR.SLSX[pid] ~= nil then
			str = str .. "·十龙十象"
		end
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "+"..str
		else
			WAR.Person[id]["特效文字1"] = str
		end
    end  
     
    --屠龙刀特效一，追加等同于武功威力的杀气
  	if WAR.L_TLD == 1 then
		ng = ng + get_skill_power(pid, wugong, 11)
  	end
    
	--任飞燕
    --if match_ID(pid,615)then
       --ng = ng + JY.Person[pid]["轻功"]*2
   -- end
    --特效文字1，动画为红色圈
    if WAR.Person[id]["特效文字1"] ~= nil and WAR.Person[id]["特效动画"] == -1 then
		WAR.Person[id]["特效动画"] = 88
    end
	
	--北斗七闪的特效动画
	if match_ID(pid, 129) and WAR.BDQS > 0 then
		WAR.Person[id]["特效动画"] = 126
	end
	--达摩攻击特效动画
	if match_ID(pid, 577)  then
		WAR.Person[id]["特效动画"] = 158
	end	
	--无酒不欢的特效动画
	if pid == 0 and JY.Base["特殊"] == 1 then
		WAR.Person[id]["特效动画"] = 132
	end

	--萧秋水觉醒特效动画
	if match_ID(pid, 652) and JY.Person[0]["六如觉醒"] > 0 then
		WAR.Person[id]["特效动画"] = 83
	end

    --开太极的动画
	if WAR.WDKTJ == 1 then
	    WAR.Person[id]["特效动画"] = 159
	end		
	--陆渐觉醒特效动画
	if match_ID(pid, 635) and JY.Person[0]["六如觉醒"] > 0 then
		WAR.Person[id]["特效动画"] = 126
	end
    -- 双剑合壁动画 	
    if (wugong == 39 or wugong == 42 or wugong == 139) and ShuangJianHB(pid) then 
	 WAR.Person[id]["特效动画"] = 83
	 end
	--苗人凤破军的动画和文字
	if match_ID(pid, 3) and WAR.MRF == 1 then
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = "破军·"..WAR.Person[id]["特效文字1"]
		else
			WAR.Person[id]["特效文字1"] = "破军"
		end
		WAR.Person[id]["特效动画"] = 146
	end
	
    if Given_WG(pid, wugong) and wugong == 35 then
        if WAR.ATNum > 1 then 
            local str = {'一','二','三','四','五','六'}
            WAR.PD['雪花六出'][pid] = math.random(6)
            if WAR.Person[id]["特效文字3"] == nil then 
                WAR.Person[id]["特效文字3"] = str[WAR.PD['雪花六出'][pid]]..'花'
            else
                WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"]..'·'..str[WAR.PD['雪花六出'][pid]]..'花'
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
        local mid = WAR.Person[i]['人物编号']
        if match_ID(mid, 9967) and Curr_NG(mid, 105)  then
			local jl = 30       	
            if WAR.Person[i]['死亡'] == false and GetWarMap(WAR.Person[i]['坐标X'],WAR.Person[i]['坐标Y'],4) > 0 and i ~= WAR.CurID and JLSD(0,jl,mid) then
                Cat('挪移',i,7,1)   
            end
        end
    end
    
	if JY.Person[pid]["生命"] <= 0 then
		return 1
	end	

	if JY.Person[pid]["武器"] == 320 and JY.Wugong[wugong]["武功类型"] == 2 and JY.Thing[320]["装备等级"] == 6  and JLSD(20,70,pid) then
		Set_Eff_Text(id,"特效文字1","天狼啸月");
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.Person[j]["死亡"] == false  then
				WAR.Person[j].TimeAdd = WAR.Person[j].TimeAdd - 100
			end
		end
    end

  --无酒不欢：狮子吼
    if PersonKF(pid, 92) then
    	if WAR.Person[id]["特效动画"] == -1 then
    		WAR.Person[id]["特效动画"] = math.fmod(92, 10) + 85
    	end
    	local nl = JY.Person[pid]["内力"];
    	local f = 0;
		local chance = 70
		local force = 100
		--主运提高效果
		if Curr_NG(pid, 92) then
			chance = 100
			force = 200
		end
		--一般人需要内力差大于2000，而谢逊只要内力差大于0即可
		local neilicha = 2000
		if match_ID(pid, 13) then
			neilicha = 0
		end

		if JLSD(0,chance,pid) or wugong == 92 then
			f = 1
		end
		if f == 1 then
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.Person[j]["死亡"] == false and (nl - JY.Person[WAR.Person[j]["人物编号"]]["内力"]) > neilicha then
					WAR.Person[j].TimeAdd = WAR.Person[j].TimeAdd - force 
					if Curr_NG(pid, 92) and myns(j) == false then
						WAR.Person[j]["内伤点数"] = (WAR.Person[j]["内伤点数"] or 0) + AddPersonAttrib(WAR.Person[j]["人物编号"], "受伤程度", math.random(5,9))
						WAR.TXXS[WAR.Person[j]["人物编号"]] = 1
					end
				end
			end
			Set_Eff_Text(id,"特效文字2","狮子吼");
		end
    end	
    
    --程英，使用玉箫剑法，杀内力300
    if match_ID(pid, 63) and wugong == 38 then
		WAR.CY = 1
    end

    --杨过 攻击，非吼 全体集气减100
    if match_ID(pid, 58) and WAR.XK ~= 2 then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
				WAR.Person[j].TimeAdd = WAR.Person[j].TimeAdd - 100
			end
		end
		if WAR.Person[id]["特效动画"] == nil then
			WAR.Person[id]["特效动画"] = 89
		end
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "+" .."西狂之怒啸"
		else
			WAR.Person[id]["特效文字1"] = "西狂之怒啸"
		end
    end
      
    --杨过吼
    if WAR.XK == 2 and match_ID(pid, 58) and WAR.Person[WAR.CurID]["我方"] == WAR.XK2 then
		for e = 0, WAR.PersonNum - 1 do
			if WAR.Person[e]["死亡"] == false and WAR.Person[e]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
				WAR.Person[e].TimeAdd = WAR.Person[e].TimeAdd - math.modf(JY.Person[WAR.Person[WAR.CurID]["人物编号"]]["内力"] / 5)
				if WAR.Person[e].Time < -450 then
					WAR.Person[e].Time = -450
				end
				JY.Person[WAR.Person[e]["人物编号"]]["内力"] = JY.Person[WAR.Person[e]["人物编号"]]["内力"] - math.modf(JY.Person[WAR.Person[WAR.CurID]["人物编号"]]["内力"] / 5)
				if JY.Person[WAR.Person[e]["人物编号"]]["内力"] < 0 then
					JY.Person[WAR.Person[e]["人物编号"]]["内力"] = 0
				end
				JY.Person[WAR.Person[e]["人物编号"]]["生命"] = JY.Person[WAR.Person[e]["人物编号"]]["生命"] - math.modf(JY.Person[WAR.Person[WAR.CurID]["人物编号"]]["内力"] / 25)
			end
			if JY.Person[WAR.Person[e]["人物编号"]]["生命"] < 0 then
				JY.Person[WAR.Person[e]["人物编号"]]["生命"] = 0
			end
		end
			
		--吼过之后，内力为0，内力最大值-1000，并且用声望控制上限
		if inteam(pid) then
			JY.Person[pid]["内力"] = 0
			JY.Person[pid]["内力最大值"] = JY.Person[pid]["内力最大值"] - 1000
			JY.Person[300]["声望"] = JY.Person[300]["声望"] + 1
		else
			AddPersonAttrib(pid, "内力", -1000)  --做敌方内力只减1000
		end
		  
		if JY.Person[pid]["内力最大值"] < 500 then
			JY.Person[pid]["内力最大值"] = 500
		end
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "+" .."西狂之震怒·雷霆狂啸"
		else
			WAR.Person[id]["特效文字1"] = "西狂之震怒·雷霆狂啸"
		end
		WAR.Person[id]["特效动画"] = 6
		WAR.XK = 3
	end    
  
    --任盈盈，使用持瑶琴，无形剑气
    if match_ID(pid, 73) and wugong == 73 then
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "+" .."七弦无形剑气"
		else
			WAR.Person[id]["特效文字3"] = "七弦无形剑气"
		end
		WAR.Person[id]["特效动画"] = 89
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
				WAR.TXXS[WAR.Person[j]["人物编号"]] = 1
				--无酒不欢：记录人物血量
				WAR.Person[j]["Life_Before_Hit"] = JY.Person[WAR.Person[j]["人物编号"]]["生命"]
				JY.Person[WAR.Person[j]["人物编号"]]["生命"] = JY.Person[WAR.Person[j]["人物编号"]]["生命"] - 50
				WAR.Person[j]["生命点数"] = (WAR.Person[j]["生命点数"] or 0) - 50
				--沉睡状态的敌人会醒来
				if WAR.CSZT[WAR.Person[j]["人物编号"]] ~= nil then
					WAR.CSZT[WAR.Person[j]["人物编号"]] = nil
				end
			end
		end
	end

	--剑胆琴心 持瑶琴回血5%，减少10内伤
	if wugong == 73 and JiandanQX(pid) then
		Set_Eff_Text(id, "特效文字3", "清心普善咒")
		WAR.Person[id]["特效动画"] = 89	
		WAR.Person[WAR.CurID]["生命点数"] = (WAR.Person[WAR.CurID]["生命点数"] or 0) + AddPersonAttrib(pid, "生命", JY.Person[pid]["生命"]*0.05)
		WAR.Person[WAR.CurID]["内伤点数"] = (WAR.Person[WAR.CurID]["内伤点数"] or 0) + AddPersonAttrib(pid, "受伤程度", -10)
	end
	
	--七夕任盈盈加强版效果
    if match_ID(pid, 611) and wugong == 73 then
		if WAR.Person[id]["特效文字3"] ~= nil then
			WAR.Person[id]["特效文字3"] = WAR.Person[id]["特效文字3"] .. "+" .."魔音搜魂"
		else
			WAR.Person[id]["特效文字3"] = "魔音搜魂"
		end
		WAR.Person[id]["特效动画"] = 89
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
				JY.Person[WAR.Person[j]["人物编号"]]["生命"] = JY.Person[WAR.Person[j]["人物编号"]]["生命"] - 100
			end
		end
	end
    
    --黄药师，第一次攻击，伤内力500，内力不足500追加伤害
    if match_ID(pid, 57) and WAR.ACT == 1  then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
				if JY.Person[WAR.Person[j]["人物编号"]]["内力"] > 500 then
					JY.Person[WAR.Person[j]["人物编号"]]["内力"] = JY.Person[WAR.Person[j]["人物编号"]]["内力"] - 500
					WAR.Person[j]["内力点数"] = (WAR.Person[j]["内力点数"] or 0) - 500;
				else
					WAR.Person[j]["内力点数"] = (WAR.Person[j]["内力点数"] or 0) - JY.Person[WAR.Person[j]["人物编号"]]["内力"];
					JY.Person[WAR.Person[j]["人物编号"]]["内力"] = 0
					--无酒不欢：记录人物血量
					WAR.Person[j]["Life_Before_Hit"] = JY.Person[WAR.Person[j]["人物编号"]]["生命"]
					JY.Person[WAR.Person[j]["人物编号"]]["生命"] = JY.Person[WAR.Person[j]["人物编号"]]["生命"] - 100
					WAR.Person[j]["生命点数"] = (WAR.Person[j]["生命点数"] or 0) - 100
				end
				WAR.TXXS[WAR.Person[j]["人物编号"]] = 1
			end
		end
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .. "+" .."魔音·碧海潮生曲"
		else
			WAR.Person[id]["特效文字1"] = "魔音·碧海潮生曲"
		end
		WAR.Person[id]["特效动画"] = 39
    end
    
     	--何足道，攻击时附加琴音状态，上限30层
	if match_ID(pid, 586) then
		WAR.HZD_QF[pid] = (WAR.HZD_QF[pid] or 0) + math.random(2,4)
		if WAR.HZD_QF[pid] > 30 then
			WAR.HZD_QF[pid] = 30
	    end
	    for j = 0, WAR.PersonNum - 1 do
            if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"]  then
                if WAR.QYZT[WAR.Person[j]["人物编号"]] == nil then
                    WAR.QYZT[WAR.Person[j]["人物编号"]] = math.random(2,3)
                else
                    WAR.QYZT[WAR.Person[j]["人物编号"]] = WAR.QYZT[WAR.Person[j]["人物编号"]] + math.random(3)
                    if WAR.QYZT[WAR.Person[j]["人物编号"]] > 30 then
                        WAR.QYZT[WAR.Person[j]["人物编号"]] = 30
                    end	
                end
            end	
        end	
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .."+".."凤求凰"
		else
			WAR.Person[id]["特效文字1"] = "凤求凰"
		end
		WAR.Person[id]["特效动画"] = 83
    end 
 
		
	--曲风伤害
	if match_ID(pid,586) and WAR.HZD_QF[pid] > 20 then
			CleanWarMap(4, 0)
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
					local eid = WAR.Person[j]["人物编号"]
					local qycs = WAR.QYZT[eid] or 0
					if qycs >0 then
						WAR.TXXS[eid] = 1
						--无酒不欢：记录人物血量
						WAR.Person[j]["Life_Before_Hit"] = JY.Person[eid]["生命"]
						JY.Person[eid]["生命"] = JY.Person[eid]["生命"] - 20*qycs
						WAR.Person[j]["生命点数"] = (WAR.Person[j]["生命点数"] or 0) - 20*qycs
						WAR.HZD_QF[pid] = nil
						SetWarMap(WAR.Person[j]["坐标X"], WAR.Person[j]["坐标Y"], 4, 1)

					end
				end
			end
		if WAR.Person[id]["特效文字0"] ~= nil then
			WAR.Person[id]["特效文字0"] = WAR.Person[id]["特效文字0"] .."+".."百鸟朝凤"
		else
			WAR.Person[id]["特效文字0"] = "百鸟朝凤"
		end
		WAR.Person[id]["特效动画"] = 154
    end 	
    --程灵素 攻击全屏中毒+20
	--扣除当前血量7%
    if match_ID(pid, 2) then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
				local loss = math.modf(JY.Person[WAR.Person[j]["人物编号"]]["生命"]*0.07)
				--无酒不欢：记录人物血量
				WAR.Person[j]["Life_Before_Hit"] = JY.Person[WAR.Person[j]["人物编号"]]["生命"]
				JY.Person[WAR.Person[j]["人物编号"]]["生命"] = JY.Person[WAR.Person[j]["人物编号"]]["生命"] - loss
				WAR.Person[j]["生命点数"] = (WAR.Person[j]["生命点数"] or 0) - loss
				WAR.Person[j]["中毒点数"] = (WAR.Person[j]["中毒点数"] or 0) + AddPersonAttrib(WAR.Person[j]["人物编号"], "中毒程度", 20)
				WAR.TXXS[WAR.Person[j]["人物编号"]] = 1
				--沉睡状态的敌人会醒来
				if WAR.CSZT[WAR.Person[j]["人物编号"]] ~= nil then
					WAR.CSZT[WAR.Person[j]["人物编号"]] = nil
				end
			end
		end
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .."+".."七心海棠"
		else
			WAR.Person[id]["特效文字1"] = "七心海棠"
		end
		WAR.Person[id]["特效动画"] = 64
    end
      
    --鸠摩智  使用火焰刀法，加内伤30，加杀集气1000
    --普通角色使用有30%的机率
	--刀主二次判定
    if wugong == 66 and level == 11 and (match_ID(pid, 103) or JLSD(30,60,pid) or (pid == 0 and JY.Base["标准"] == 4 and JLSD(30,70,pid)))  then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and myns(j) == false then
				WAR.Person[j]["内伤点数"] = (WAR.Person[j]["内伤点数"] or 0) + AddPersonAttrib(WAR.Person[j]["人物编号"], "受伤程度", 30)
				WAR.TXXS[WAR.Person[j]["人物编号"]] = 1
			end
		end
		if WAR.Person[id]["特效文字1"] ~= nil then
			WAR.Person[id]["特效文字1"] = WAR.Person[id]["特效文字1"] .."+".."大轮密宗·火焰刀"
		else
			WAR.Person[id]["特效文字1"] = "大轮密宗·火焰刀"
		end
		WAR.Person[id]["特效动画"] = 58
		ng = ng + 1000
    end
    
	--李秋水无相转身，没有触发过，或者分身已死，才可触发，有30%几率触发
	if (WAR.WXFS == nil or (WAR.WXFS ~= nil and WAR.Person[WAR.WXFS]["死亡"] == true)) and math.random(10) < 4 then
		local lqs_WXZS;
		for i = 0, CC.WarWidth - 1 do
			for j = 0, CC.WarHeight - 1 do
				local effect = GetWarMap(i, j, 4)
				if 0 < effect then
					local emeny = GetWarMap(i, j, 2)
					if emeny >= 0 and emeny ~= WAR.CurID then
						
						if WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[emeny]["我方"] and match_ID(WAR.Person[emeny]["人物编号"], 118) and WAR.Person[emeny]["人物编号"] == 0 then
							lqs_WXZS = emeny
							SetWarMap(i, j, 4, 0)
							break;
						end
					end
				end
			end
		end
	
		if lqs_WXZS ~= nil then
			
			--ID临时交给李秋水
			local s = WAR.CurID
			WAR.CurID = lqs_WXZS
			local wxlox, wxloy;
			War_CalMoveStep(WAR.CurID, 10, 0)
			local function SelfXY(x, y)
				local yes = 0
				if x == WAR.Person[WAR.CurID]["坐标X"] then
					yes = yes +1
				end
				if y == WAR.Person[WAR.CurID]["坐标Y"] then
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
				--ESC退出
				else
					WAR.ShowHead = 0
					x, y = WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"]
					--wxlox, wxloy = WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"]
					break;
				end
			end
			--不在自身位置才能触发幻象
			if SelfXY(x, y) == false then
				SetWarMap(wxlox, wxloy, 4, 0)
				--本场还没触发过无相转身，则加入新人物
				if WAR.WXFS == nil then
					WAR.Person[WAR.PersonNum]["人物编号"] = 600
					WAR.Person[WAR.PersonNum]["我方"] = WAR.Person[WAR.CurID]["我方"]
					WAR.Person[WAR.PersonNum]["坐标X"] = wxlox
					WAR.Person[WAR.PersonNum]["坐标Y"] = wxloy
					WAR.Person[WAR.PersonNum]["死亡"] = false
					WAR.Person[WAR.PersonNum]["人方向"] = WAR.Person[WAR.CurID]["人方向"]
					WAR.Person[WAR.PersonNum]["贴图"] = WarCalPersonPic(WAR.PersonNum)
                   
					--lib.PicLoadFile(string.format(CC.FightPicFile[1], JY.Person[600]["头像代号"]), string.format(CC.FightPicFile[2], JY.Person[600]["头像代号"]), 4 + WAR.PersonNum)
					WAR.JQSDXS[600] = 0	--直接指定集气，以免召唤出来马上被斗转跳出
					WAR.WXFS = WAR.PersonNum
					WAR.PersonNum = WAR.PersonNum + 1
				--已经触发过，则让分身复活
				else
					WAR.Person[WAR.WXFS]["死亡"] = false
					WAR.Person[WAR.WXFS]["我方"] = WAR.Person[WAR.CurID]["我方"]
					WAR.Person[WAR.WXFS]["坐标X"] = wxlox
					WAR.Person[WAR.WXFS]["坐标Y"] = wxloy
					WAR.Person[WAR.WXFS]["人方向"] = WAR.Person[WAR.CurID]["人方向"]
					WAR.Person[WAR.WXFS]["贴图"] = WarCalPersonPic(WAR.WXFS)
					JY.Person[600]["生命"] = JY.Person[600]["生命最大值"]
					JY.Person[600]["内力"] = JY.Person[600]["内力最大值"]
					JY.Person[600]["体力"] = 100
					JY.Person[600]["受伤程度"] = 0 
					JY.Person[600]["中毒程度"] = 0
					JY.Person[600]["冰封程度"] = 0
					JY.Person[600]["灼烧程度"] = 0
					WAR.Person[WAR.WXFS].Time = 0
					--流血
					if WAR.LXZT[600] ~= nil then
						WAR.LXZT[600] = nil
					end
					--封穴
					if WAR.FXDS[600] ~= nil then
						WAR.FXDS[600] = nil
					end
				end
		  
				--清除自身位置贴图
				SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, -1)
				SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, -1)
                SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, -1)
				--修改自身与幻象坐标
				WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], WAR.Person[WAR.WXFS]["坐标X"], WAR.Person[WAR.WXFS]["坐标Y"] = WAR.Person[WAR.WXFS]["坐标X"], WAR.Person[WAR.WXFS]["坐标Y"],WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"]
					
				--增加幻象贴图
				SetWarMap(WAR.Person[WAR.WXFS]["坐标X"], WAR.Person[WAR.WXFS]["坐标Y"], 5, WAR.Person[WAR.WXFS]["贴图"])
				SetWarMap(WAR.Person[WAR.WXFS]["坐标X"], WAR.Person[WAR.WXFS]["坐标Y"], 2, WAR.WXFS)
                SetWarMap(WAR.Person[WAR.WXFS]["坐标X"], WAR.Person[WAR.WXFS]["坐标Y"],10,JY.Person[WAR.Person[WAR.WXFS]["人物编号"]]['头像代号'])
                
				--增加自身贴图
				SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, WAR.Person[WAR.CurID]["贴图"])
				SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, WAR.CurID)
                SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"],10,JY.Person[WAR.Person[WAR.CurID]["人物编号"]]['头像代号'])
			end
			WarDrawMap(0)
			CurIDTXDH(WAR.CurID, 90,1,"无相转身")
				
			--还原ID并打断连击
			WAR.CurID = s
			WAR.ACT = 10
		end
	end
    
    --计算伤害的敌人
    for i = 0, CC.WarWidth - 1 do
		for j = 0, CC.WarHeight - 1 do
			lib.GetKey()
			local effect = GetWarMap(i, j, 4)
			if 0 < effect then
				local emeny = GetWarMap(i, j, 2)
				if 0 <= emeny and emeny ~= WAR.CurID then		--如果有人，并且不是当前控制人
					--触发逆转乾坤的情况下，无误伤特效和合击依然会打到自己人
                    if match_ID(WAR.Person[emeny]["人物编号"], 9965) then
                        JY.Person[WAR.Person[emeny]["人物编号"]]['冰封程度'] = 0
                        JY.Person[WAR.Person[emeny]["人物编号"]]['灼烧程度'] = 0
                        WAR.BFXS[WAR.Person[emeny]["人物编号"]] = nil
                        WAR.ZSXS[WAR.Person[emeny]["人物编号"]] = nil
                    end

					if WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[emeny]["我方"] or (ZHEN_ID < 0 and WAR.WS == 0) or WAR.NZQK > 0 or WAR.HLZT[pid] ~= nil then
						if JY.Wugong[wugong]["伤害类型"] == 1 and (fightscope == 0 or fightscope == 3) then
							if level == 11 then
								level = 10
							end
							SetWarMap(i, j, 4, 3)
							WAR.Effect = 3
						else
							--林朝英轻云蔽月，每50时序可触发一次，免疫伤害10时序，误伤不触发
							if match_ID(WAR.Person[emeny]["人物编号"], 605) and WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[emeny]["我方"] then
								if WAR.QYBY[WAR.Person[emeny]["人物编号"]] == nil then
									WAR.QYBY[WAR.Person[emeny]["人物编号"]] = 50
								end
								if WAR.QYBY[WAR.Person[emeny]["人物编号"]] > 40 then
									WAR.Person[emeny]["特效文字3"] = "轻云蔽月"
									WAR.Person[emeny]["特效动画"] = 102
								else
									WAR.Person[emeny]["生命点数"] = (WAR.Person[emeny]["生命点数"] or 0) - War_WugongHurtLife(emeny, wugong, level, ng, x, y)
									WAR.Effect = 2
									SetWarMap(i, j, 4, 2)
								end			
							--主角觉醒后，喵姐开局前三次不受伤害
							elseif match_ID(WAR.Person[emeny]["人物编号"], 92) and JY.Person[0]["六如觉醒"] > 0 and WAR.FF < 3 and WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[emeny]["我方"] then
								WAR.FF = WAR.FF + 1
								WAR.Person[emeny]["特效动画"] = 135						
							--黛绮丝倾国
							elseif WAR.QGZT[WAR.Person[emeny]["人物编号"]] ~= nil and WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[emeny]["我方"] then
								local list = {}
								for q = 0, WAR.PersonNum - 1 do
									if WAR.Person[q]["死亡"] == false and q ~= WAR.CurID and WAR.Person[q]["我方"] ~= WAR.Person[emeny]["我方"] then
										table.insert(list,q)
									end
								end
								local F_target
								if list[1] ~= nil then
									WAR.Person[emeny]["特效动画"] = 149
									F_target = list[math.random(#list)]
									WAR.NZQK = 3
									WAR.Person[F_target]["生命点数"] = (WAR.Person[F_target]["生命点数"] or 0) - War_WugongHurtLife(F_target, wugong, level, ng, x, y)
									WAR.Effect = 2
									SetWarMap(WAR.Person[F_target]["坐标X"], WAR.Person[F_target]["坐标Y"], 4, 2)
									WAR.NZQK = 0
								else
									WAR.Person[emeny]["生命点数"] = (WAR.Person[emeny]["生命点数"] or 0) - War_WugongHurtLife(emeny, wugong, level, ng, x, y)
									WAR.Effect = 2
									SetWarMap(i, j, 4, 2)
								end
								--无论是否有第三方，既无论是否反弹，都消耗一次次数
								WAR.QGZT[WAR.Person[emeny]["人物编号"]] = WAR.QGZT[WAR.Person[emeny]["人物编号"]] -1
								if WAR.QGZT[WAR.Person[emeny]["人物编号"]] < 1 then
									WAR.QGZT[WAR.Person[emeny]["人物编号"]] = nil
								end
							--郭襄，诸天化身步
                                elseif match_ID_awakened(WAR.Person[emeny]["人物编号"], 626, 1) and WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[emeny]["我方"] and JLSD(0,30,WAR.Person[emeny]["人物编号"]) then
								WAR.ZTHSB = 1
								WAR.ZT_id = emeny
								WAR.ZT_X = WAR.Person[emeny]["坐标X"]
								WAR.ZT_Y = WAR.Person[emeny]["坐标Y"]
								local dam = Xishu_max(WAR.Person[emeny]["人物编号"])
								local s = WAR.CurID
								WAR.CurID = emeny
								for f = 0, WAR.PersonNum - 1 do
									if WAR.Person[f]["我方"] ~= WAR.Person[emeny]["我方"] and WAR.Person[f]["死亡"] == false then					
										WAR.TXXS[WAR.Person[f]["人物编号"]] = 1
										WAR.Person[f]["Life_Before_Hit"] = JY.Person[WAR.Person[f]["人物编号"]]["生命"]
										JY.Person[WAR.Person[f]["人物编号"]]["生命"] = JY.Person[WAR.Person[f]["人物编号"]]["生命"] - 50*JY.Person[WAR.Person[f]["人物编号"]]
										WAR.Person[f]["生命点数"] = (WAR.Person[f]["生命点数"] or 0) - dam
									end
								end
								--一灯，避免被爆死
								if JY.Person[65]["生命"] <= 0 then
									JY.Person[65]["生命"] = 1
								end
								--王重阳
								if JY.Person[129]["生命"] <= 0 then
									JY.Person[129]["生命"] = 1
								end
								WAR.CurID = s
							else
								WAR.Person[emeny]["生命点数"] = (WAR.Person[emeny]["生命点数"] or 0) - War_WugongHurtLife(emeny, wugong, level, ng, x, y)
								WAR.Effect = 2
								SetWarMap(i, j, 4, 2)
							end
							--沉睡状态的敌人会醒来
							if WAR.CSZT[WAR.Person[emeny]["人物编号"]] ~= nil then
								WAR.CSZT[WAR.Person[emeny]["人物编号"]] = nil
							end
						end
					end
                    if match_ID(WAR.Person[emeny]["人物编号"], 9965) then
                        JY.Person[WAR.Person[emeny]["人物编号"]]['冰封程度'] = 0
                        JY.Person[WAR.Person[emeny]["人物编号"]]['灼烧程度'] = 0
                        WAR.BFXS[WAR.Person[emeny]["人物编号"]] = nil
                        WAR.ZSXS[WAR.Person[emeny]["人物编号"]] = nil
                    end
				end
			end
		end
    end

	--无酒不欢：标主的大招音效
    local dhxg = JY.Wugong[wugong]["武功动画&音效"]
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
	


	--血刀吸血，上限100点

	if WAR.XDLeech > 0 then
		WAR.Person[WAR.CurID]["生命点数"] = (WAR.Person[WAR.CurID]["生命点数"] or 0) + AddPersonAttrib(pid, "生命", WAR.XDLeech);
	end
	
	--韦一笑吸血10%，上限100点
	if WAR.WYXLeech > 0 then
		WAR.Person[WAR.CurID]["生命点数"] = (WAR.Person[WAR.CurID]["生命点数"] or 0) + AddPersonAttrib(pid, "生命", WAR.WYXLeech);
	end
	
	--天魔功吸血20%
	if WAR.TMGLeech > 0 then
		WAR.Person[WAR.CurID]["生命点数"] = (WAR.Person[WAR.CurID]["生命点数"] or 0) + AddPersonAttrib(pid, "生命", WAR.TMGLeech);
	end
	--血河神鉴吸血，上限100点
	if WAR.XHSJ > 0 then
		WAR.Person[WAR.CurID]["生命点数"] = (WAR.Person[WAR.CurID]["生命点数"] or 0) + AddPersonAttrib(pid, "生命", WAR.XHSJ);
	end

	--无酒不欢：人物的攻击动画和点数显示
	War_ShowFight(pid, wugong, JY.Wugong[wugong]["武功类型"], level, x, y, dhxg, ZHEN_ID)
	
	--紫气天罗，杀人引爆毒素
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
			if GetWarMap(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"], 4) == 1 then
				ys_num = ys_num + 1
				ys_list[ys_num] = {WAR.Person[i]["坐标X"],WAR.Person[i]["坐标Y"]}
			end
		end
		
		local yes = 1
		
		while (yes == 1) do
			yes = 0
			WAR.Person[ybid]["引爆"] = 1
			WAR.Person[ybid]["特效动画"] = 117
			for i = 0, WAR.PersonNum - 1 do
				if WAR.Person[i]["引爆"] == nil and WAR.Person[i]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.Person[i]["死亡"] == false then
					local bdid = WAR.Person[i]["人物编号"]
					local offset1 = math.abs(bpX - WAR.Person[i]["坐标X"])
					local offset2 = math.abs(bpY - WAR.Person[i]["坐标Y"])
					if offset1 <= 5 and offset2 <= 5 then
						WAR.Person[i]["生命点数"] = (WAR.Person[i]["生命点数"] or 0) - dam
						JY.Person[bdid]["生命"] = JY.Person[bdid]["生命"] - dam
						--一灯，避免被爆死
						if JY.Person[65]["生命"] <= 0 then
							JY.Person[65]["生命"] = 1
						end
						--王重阳
						if JY.Person[129]["生命"] <= 0 then
							JY.Person[129]["生命"] = 1
						end
						if JY.Person[bdid]["生命"] < 0 then
							JY.Person[bdid]["生命"] = 0
							yes = 1
							ybid = i
							bpX = WAR.Person[i]["坐标X"]
							bpY = WAR.Person[i]["坐标Y"]
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

	--无明业火状态，耗损使用的内力一半的生命
	if WAR.WMYH[pid] ~= nil then
		CurIDTXDH(WAR.CurID, 127,1, "无明业火", C_ORANGE)
		local nlDam = math.modf((math.modf((level + 3) / 2) * JY.Wugong[wugong]["消耗内力点数"])/2)
		WAR.Person[WAR.CurID]["生命点数"] = (WAR.Person[WAR.CurID]["生命点数"] or 0) + AddPersonAttrib(pid, "生命", -nlDam)
	    --至少留1滴血
	    if JY.Person[pid]["生命"] <= 0 then
			JY.Person[pid]["生命"] = 1
	    end
	end

	WAR.PD['神游太虚'] = {}
	War_Show_Count(WAR.CurID);		--显示当前控制人的点数
	
	WAR.TFBW = 0		--听风辨位的文字记录恢复
	WAR.TLDWX = 0		--天罗地网的文字记录恢复
    
	WAR.ZTHSB = 0			--诸天化身步
	WAR.ZT_id = -1			--触发人的ID
	WAR.ZT_X = -1			--触发人的X坐标
	WAR.ZT_Y = -1			--触发人的Y坐标
	
	if WAR.FHJZ == 1 then
		DrawStrBoxWaitKey("【Ｇ复活戒指Ｏ】损坏了！", C_ORANGE, CC.DefaultFont, 2)
		WAR.FHJZ = 0
	end
	
    WAR.Person[WAR.CurID]["经验"] = WAR.Person[WAR.CurID]["经验"] + 2
	
    --武功增加经验和升级
    if inteam(pid) then
		if JY.Person[pid]["武功等级" .. wugongnum] < 900 then
			JY.Person[pid]["武功等级" .. wugongnum] = JY.Person[pid]["武功等级" .. wugongnum] + 10
		elseif JY.Person[pid]["武功等级" .. wugongnum] < 999 then
			--JY.Person[pid]["武功等级" .. wugongnum] = JY.Person[pid]["武功等级" .. wugongnum] + math.modf(JY.Person[pid]["资质"] / 20 + math.random(2)) + rz
			--无酒不欢：空挥一次到极
			JY.Person[pid]["武功等级" .. wugongnum] = JY.Person[pid]["武功等级" .. wugongnum] + 99;
			--武功提升为极
			if 999 <= JY.Person[pid]["武功等级" .. wugongnum] then
				JY.Person[pid]["武功等级" .. wugongnum] = 999
				PlayWavAtk(42)
				DrawStrBoxWaitKey(string.format("%s修炼%s到登峰造极", JY.Person[pid]["姓名"], JY.Wugong[JY.Person[pid]["武功" .. wugongnum]]["名称"]), C_ORANGE, CC.DefaultFont)

				--虚竹 天山折梅手为极，资质变回50
				if match_ID(pid, 49) and wugong == 14 then
					say("逍遥派的武学果然博大精深，让小僧有醍醐灌顶之感。", 49, 0);
					DrawStrBoxWaitKey("虚竹资质改变！", C_ORANGE, CC.DefaultFont)
					set_potential(49, 50)
				end
				
				--狄云 神照功为极，增加轻功20点
				if match_ID(pid, 37) and wugong == 94 then
					say("神照经当真奇妙，四肢百骸感觉劲力充盈。丁大哥，我一定不会让你失望的！", 37, 0);
					DrawStrBoxWaitKey("狄云领悟神照经的真髓，轻功加二十", C_ORANGE, CC.DefaultFont)
					AddPersonAttrib(pid, "轻功", 20)
				end
				
				--胡斐，胡家刀法到极，增加10点耍刀技巧
				if match_ID(pid, 1) and wugong == 67 then
					say("刀法真是越练越精妙。", 1, 0);
					DrawStrBoxWaitKey("胡斐攻、防、轻、耍刀技巧各增加10点", C_ORANGE, CC.DefaultFont)
					AddPersonAttrib(pid, "攻击力", 10)
					AddPersonAttrib(pid, "防御力", 10)
					AddPersonAttrib(pid, "轻功", 10)
					AddPersonAttrib(pid, "耍刀技巧", 10)
				end
			end
		end
			
		--武功提升普通等级
		if level < math.modf(JY.Person[pid]["武功等级" .. wugongnum] / 100) + 1 then
			level = math.modf(JY.Person[pid]["武功等级" .. wugongnum] / 100) + 1
			for i = 1,10 do
				Cat('实时特效动画')
				Cls()
				DrawStrBox(-1, -1, string.format("%s 升为 %d 级", JY.Wugong[JY.Person[pid]["武功" .. wugongnum]]["名称"], level), C_ORANGE, CC.DefaultFont)
				ShowScreen()
				lib.Delay(CC.BattleDelay)
			end
		end
    end
  
    --我方，消耗的内力
    if WAR.Person[WAR.CurID]["我方"] then
		local nl = nil
	
		nl = math.modf((level + 3) / 2) * JY.Wugong[wugong]["消耗内力点数"]
		
		--纯阳减少内力消耗
		--主运
		if Curr_NG(pid, 99) then
			nl = math.modf(nl*0.4);
		--被动
		elseif PersonKF(pid, 99) then
			nl = math.modf(nl*0.5);
		end
	    if PersonKF(pid, 43) then
		   nl = math.modf(nl*0.7)
		end  
		--阳内主运九阳，减少70%耗内
		if Curr_NG(pid, 106) and (JY.Person[pid]["内力性质"] == 1 or JY.Person[pid]["内力性质"] == 3) then
			nl = math.modf(nl*0.3);
		end
		
		--乔峰降龙消耗减半
		if match_ID(pid, 50) and wugong == 26 then
			nl = math.modf(nl/2);
		end	
		
		--石破天觉醒后，太玄消耗减半
		if match_ID_awakened(pid, 38, 1) and wugong == 102 then
			nl = math.modf(nl/2);
		end
		  
		--段誉六脉消耗减半
		if match_ID(pid, 53) and wugong == 49 then
			nl = math.modf(nl/2);
		end

		--指法主角六脉消耗减半
		if pid == 0 and JY.Base["标准"] == 2 and wugong == 49 then
			nl = math.modf(nl/2);
		end
		  
		--天外攻击，只消耗一半内力
		if Given_WG(pid, wugong) then
			nl = math.modf(nl/2);
		end
		
		--周伯通论剑奖励，体内消耗减少50%
		if pid == 0 and JY.Person[64]["论剑奖励"] == 1 then
			nl = math.modf(nl/2)
		end

		AddPersonAttrib(pid, "内力", -(nl))
	--NPC的耗内
	else
		AddPersonAttrib(pid, "内力", -math.modf((level + 3) / 2) * JY.Wugong[wugong]["消耗内力点数"]/7*2)
    end
  
    if JY.Person[pid]["内力"] < 0 then
		JY.Person[pid]["内力"] = 0
    end
    
    if JY.Person[pid]["生命"] <= 0 then
		break;
    end
 
   
	
	--无酒不欢：被杀气的动态显示
  	DrawTimeBar2()
	

	--太极拳，借力打力，蓄力清除
	--张三丰不清除
	--if Curr_NG(pid,171) and (wugong == 16 or wugong == 46)  and WAR.PD["太极蓄力"][pid] ~= nil and WAR.PD["太极蓄力"][pid] > 0 and match_ID(pid, 5) == false then
	    
		--WAR.PD["太极蓄力"][pid] = 0
	--end

	WAR.ACT = WAR.ACT + 1   --统计攻击次数累加1
 		
  	--蓝烟清：攻击范围内的敌人全部死亡时取消连击
  	local flag = 0;
  	local n = 0;
    for i = 0, CC.WarWidth - 1 do
		for j = 0, CC.WarHeight - 1 do
			lib.GetKey()
			local effect = GetWarMap(i, j, 4)
			if 0 < effect then
				local emeny = GetWarMap(i, j, 2)
				if 0 <= emeny and WAR.Person[id]["我方"] ~= WAR.Person[emeny]["我方"] then
					n = n + 1;
					if JY.Person[WAR.Person[emeny]["人物编号"]]["生命"] > 0 then
						flag = 1;
					end
				end
    		end
    	end
    end
	
	--无酒不欢：程灵素不会中断连击
    if flag == 0 and n > 0 and match_ID(pid, 2) == false then
    	break
    end

	--主运太极神功，太极之形增加连击
	if Curr_NG(pid, 171) and  WAR.TJZX[pid] ~= nil and WAR.TJZX[pid] >= 5 then
		WAR.ATNum = WAR.ATNum + 1
		WAR.TJZX[pid] = WAR.TJZX[pid] - 5
		WAR.TJZX_LJ = 1
	end
	
	--if match_ID(pid,9994) then 
		if WAR.PD['无量禅震'][pid] ~= nil then
			if WAR.PD['无量禅震'][pid].s == 1 and WAR.PD['无量禅震'][pid].n < 3 then
				WAR.ATNum = WAR.ATNum + 1
				WAR.PD['无量禅震'][pid].s = nil
			end
		end
	--end
    
end

----------------状态清除-----------------
	--天外连击判定取消
	WAR.TWLJ = 0
	WAR.DJJJ_LJ = 0
	--黯然极意范围恢复
	WAR.ARJY = 0
	WAR.ARJY1 = 0		--黯然极意	
	--云罗天网恢复
	WAR.YLTW = 0	
	--九阴极意范围恢复
	WAR.JYSZ = 0
	--九阴极意1范围恢复
	WAR.JYSZ1 = 0
   
	WAR.PD["刀剑绝技"][pid] = nil
	
	--狄云赤心连城计数恢复
	WAR.CXLC_Count = 0
	--无量连击恢复
	WAR.WLLJ_Count = 0
	--逍遥御风计数恢复
	WAR.YFCS = 0
	WAR.MHSN = 0
	--连击结束

	--太极拳，借力打力，蓄力清除
	--张三丰在这里清除
	if (wugong == 16 or wugong == 46 ) and  WAR.PD["太极蓄力"][pid] ~= nil and WAR.PD["太极蓄力"][pid] > 0  then
		if match_ID(pid, 5) then
			WAR.PD["太极蓄力"][pid] = math.modf( WAR.PD["太极蓄力"][pid]/2)
		else	
			WAR.PD["太极蓄力"][pid] = 0
		end
	end	

	--如果触发了逆转乾坤的强化反弹效果，在这里恢复
	if WAR.NZQK > 0 then
		WAR.NZQK = 0
	end
  
	--计算消耗的体力
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
	
	--周伯通论剑奖励，体内消耗减少50%
	if pid == 0 and JY.Person[64]["论剑奖励"] == 1 then
		jtl = math.modf(jtl/2)
		if jtl < 1 then
			jtl = 1
		end
	end
       --体内消耗减少50%
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
	--装备青驴 集气速度+5点
		if JY.Person[id]["坐骑"] == 339 then
				jtl = jtl - 2
		if jtl < 1 then
			jtl = 1
		end
	end
	--太玄被动减少体力消耗2点
	if PersonKF(pid, 102) then
		jtl = jtl - 2
		if jtl < 1 then
			jtl = 1
		end
	end

	--人厨子攻击不消耗体力
	--NPC只消耗1点
	if match_ID(pid, 89) == false then
		if WAR.Person[WAR.CurID]["我方"] then
			AddPersonAttrib(pid, "体力", -(jtl))
		else
			AddPersonAttrib(pid, "体力", -1);
		end
	end
    

	
	--斗转星移计算
	local dz = {}
	local dznum = 0
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["反击武功"] ~= -1 and WAR.Person[i]["反击武功"] ~= 9999 then --如果反击武功不为空值 和？
			dznum = dznum + 1  --斗转 = 斗转 +1 
			dz[dznum] = {i, WAR.Person[i]["反击武功"], x - WAR.Person[WAR.CurID]["坐标X"], y - WAR.Person[WAR.CurID]["坐标Y"]} -- 斗转人数 = 反击武功 x Y坐标范围内
			WAR.Person[i]["反击武功"] = 9999
		end
	end
	for i = 1, dznum do
		local tmp = WAR.CurID
		WAR.CurID = dz[i][1]
		WAR.DZXY = 1
		if WAR.DZXYLV[WAR.Person[WAR.CurID]["人物编号"]] == 1 then
			WAR.DZXYLV[WAR.Person[WAR.CurID]["人物编号"]] = 60
		elseif WAR.DZXYLV[WAR.Person[WAR.CurID]["人物编号"]] == 2 then
			WAR.DZXYLV[WAR.Person[WAR.CurID]["人物编号"]] = 85
		elseif WAR.DZXYLV[WAR.Person[WAR.CurID]["人物编号"]] == 3 then
			WAR.DZXYLV[WAR.Person[WAR.CurID]["人物编号"]] = 110
		elseif WAR.DZXYLV[WAR.Person[WAR.CurID]["人物编号"]] == 5 then     --三才归元反击比例
			WAR.DZXYLV[WAR.Person[WAR.CurID]["人物编号"]] = 100
		elseif WAR.DZXYLV[WAR.Person[WAR.CurID]["人物编号"]] == 4 then	--无酒不欢：增加斗转第四层
			WAR.DZXYLV[WAR.Person[WAR.CurID]["人物编号"]] = 115
		end
        if WAR.AutoFight == 1 or WAR.Person[WAR.CurID]['我方'] == false or WAR.ZDDH == 354 or JY.Person[WAR.Person[WAR.CurID]['人物编号']]['资质'] <= 79 then
            War_Fight_Sub(dz[i][1], dz[i][2] + 100, dz[i][3], dz[1][4])
        else 
            War_Fight_Sub(dz[i][1], dz[i][2] + 100)
        end
		WAR.Person[WAR.CurID]["反击武功"] = -1
		WAR.DZXYLV[WAR.Person[WAR.CurID]["人物编号"]] = nil
		WAR.CurID = tmp
		WAR.DZXY = 0
	end 
		fjtx()
	if JY.Restart == 1 then
		return 1
	end
	WAR.PD['无量禅震'][pid] = {}
    
    if WAR.PD['降龙·双龙取水'][pid] ~= nil and WAR.PD['降龙·双龙取水'][pid] == 1 then
        WAR.PD['降龙·双龙取水'][pid] = 2
        WAR.Person[WAR.CurID]['移动步数'] = 0
        if WAR.AutoFight == 1 or WAR.Person[WAR.CurID]['我方'] == false or WAR.ZDDH == 354 then
            Cat('自动攻击',wugongnum)
        else
            War_Fight_Sub(WAR.CurID, wugongnum)
        end
        WAR.PD['降龙·双龙取水'][pid] = nil
    end
	return 1;
end

--无酒不欢：选择移动
--增加7*7的显示flag
function War_SelectMove(flag)
	local x0 = WAR.Person[WAR.CurID]["坐标X"]
	local y0 = WAR.Person[WAR.CurID]["坐标Y"]
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
		
		Cat('实时特效动画')
	
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
		
		--如阴时显示集气条
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
    
		--无酒不欢：避免跳出
		if GetWarMap(x2, y2, 3) ~= nil and GetWarMap(x2, y2, 3) < 128 then
			x = x2
			y = y2
		end
	end
end

--获取武功最小内力
function War_GetMinNeiLi(pid)
	local minv = math.huge
	for i = 1, JY.Base["武功数量"] do
		local tmpid = JY.Person[pid]["武功" .. i]
		if tmpid > 0 and JY.Wugong[tmpid]["消耗内力点数"] < minv then
			minv = JY.Wugong[tmpid]["消耗内力点数"]
		end
	end
	return minv
end

--无酒不欢：手动战斗菜单上级
function War_Manual()
	local r = nil
    local pid = WAR.Person[WAR.CurID]['人物编号']
    if WAR.HLZT[pid] ~= nil then
        Cat('随机移动')
    end
	local x, y, move, pic, face_dir = WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], WAR.Person[WAR.CurID]["移动步数"], WAR.Person[WAR.CurID]["贴图"], WAR.Person[WAR.CurID]["人方向"]
	while true do
		if JY.Restart == 1 then
			break
		end
		WAR.ShowHead = 1
		--r = War_Manual_Sub()
		r = Cat('战斗菜单')
		--移动，这里实际返回的应该是-1
		if r == 1 or r == -1 then
			--WAR.Person[WAR.CurID]["移动步数"] = 0 
		--ESC返回
		elseif r == 0 then
			SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, -1)
			SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, -1)
            SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, -1)
			WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], WAR.Person[WAR.CurID]["移动步数"] = x, y, move
			SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, WAR.CurID)
			SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, pic)
            SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, JY.Person[WAR.Person[WAR.CurID]["人物编号"]]['头像代号'])
			--无酒不欢：人物面相也要还原
			WAR.Person[WAR.CurID]["人方向"] = face_dir
		elseif r == 20 then
	
		else
			break;
		end
	end
	WAR.ShowHead = 0
	WarDrawMap(0)
	return r	--无酒不欢：这里的返回值似乎没什么屌用
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

	      
--手动战斗菜单
function War_Manual_Sub()
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	--local isEsc = 0
	
	local warmenu = {
	{"移动", War_MoveMenu, 1},	--1
	{"攻击", War_FightMenu, 1},	--2
	{"运功", War_YunGongMenu, 1},	--3
	{"战术", War_TacticsMenu, 1},	--4
     {"其它", War_OtherMenu, 1},	--13  --5		

	{"特色", War_TgrtsMenu, 1},	--11 --6
	{"撤退", War_Retreat, 1},	--12  --7
	{"自动", War_AutoMenu, 1}	--13  --8
	
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
	--特色指令
	
	if JY.Person[pid]["特色指令"] == 1 then
		--如果是畅想
		if pid == 0 then
			warmenu[6][1] = GRTS[JY.Base["畅想"]]
		else
			warmenu[6][1] = GRTS[pid]
		end
	else
		warmenu[6][3] = 0
	end
  
	--虚竹
	if match_ID(pid, 49) then
		--如果没有中生死符的人物则不显示特色指令
		local t = 0
		for i = 0, WAR.PersonNum - 1 do
			local wid = WAR.Person[i]["人物编号"]
			if WAR.TZ_XZ_SSH[wid] == 1 and WAR.Person[i]["死亡"] == false then
				t = 1
			end
		end
		if t == 0 then
			warmenu[6][3] = 0
		end
		--体力小于20不显示特色指令
		if JY.Person[pid]["体力"] < 20 then
			warmenu[6][3] = 0
		end
	end
  
	--祖千秋
	if match_ID(pid, 88) then
		--如果周围没有队友不显示特色指令
		local yes = 0
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["我方"] == true and WAR.Person[i]["死亡"] == false and RealJL(WAR.CurID, i, 5) and i ~= WAR.CurID then
				yes = 1
			end
		end
		if yes == 0 then
			warmenu[6][3] = 0
		end
		--体力小于20不显示特色指令
		--内力小于1000不显示
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 then
			warmenu[6][3] = 0
		end
	end

	--人厨子
	if match_ID(pid, 89) then
		--如果周围没有队友不显示特色指令
		local px, py = WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"]
		local mxy = {
					{WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"] + 1}, 
					{WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"] - 1}, 
					{WAR.Person[WAR.CurID]["坐标X"] + 1, WAR.Person[WAR.CurID]["坐标Y"]}, 
					{WAR.Person[WAR.CurID]["坐标X"] - 1, WAR.Person[WAR.CurID]["坐标Y"]}}

		local yes = 0
		for i = 1, 4 do
			if GetWarMap(mxy[i][1], mxy[i][2], 2) >= 0 then
			local mid = GetWarMap(mxy[i][1], mxy[i][2], 2)
			if inteam(WAR.Person[mid]["人物编号"]) then
				yes = 1
				end
			end  
		end
		if yes == 0 then
			warmenu[6][3] = 0
		end
		--体力小于25不显示特色指令
		if JY.Person[pid]["体力"] < 25 then
			warmenu[6][3] = 0
		end
	end

	--张无忌
	if match_ID(pid, 9) then
		--如果周围没有队友不显示特色指令
		local yes = 0
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["我方"] == true and WAR.Person[i]["死亡"] == false and RealJL(WAR.CurID, i, 8) and i ~= WAR.CurID then
				yes = 1
			end
		end
		if yes == 0 then
			warmenu[6][3] = 0
		end
		--体力小于20不显示特色指令
		if JY.Person[pid]["体力"] < 20 then
			warmenu[6][3] = 0
		end
	end
 
	--霍青桐指挥指令
	if match_ID(pid, 74) then
		--体力小于10不显示特色指令
		if JY.Person[pid]["体力"] < 10 or JY.Person[pid]["内力"] < 150 or  WAR.HQT_CD > 0 then
			warmenu[6][3] = 0
		end
	end
	
	--慕容复指令 幻梦
	if match_ID(pid, 51) then
		--体力小于20不显示特色指令
		if JY.Person[pid]["体力"] < 20 then
			warmenu[6][3] = 0
		end
	end

	--小昭指令 影步
	if match_ID(pid, 66) then
		--体力小于30，或内力小于2000不显示特色指令
		if JY.Person[pid]["体力"] < 30 or JY.Person[pid]["内力"] < 2000 then
			warmenu[6][3] = 0
		end
	end
  
	--钟灵指令 灵貂
	if match_ID(pid, 90) then
		--体力小于10不显示特色指令
		if JY.Person[pid]["体力"] < 10 then
			warmenu[6][3] = 0
		end
	end
	
	--喵姐指令 变装
	if match_ID(pid, 92) then
		--体力小于20不显示特色指令
		if JY.Person[pid]["体力"] < 20 then
			warmenu[6][3] = 0
		end
	end
	--丘机处 止杀
	if match_ID(pid, 68) then
		--体力小于20不显示特色指令
		if JY.Person[pid]["体力"] < 20 or WAR.JSZT1[pid]> 0 then
			warmenu[6][3] = 0
		end
	end	
	--胡斐指令 飞狐
	if match_ID(pid, 1) then
		--体力小于20不显示特色指令
		if JY.Person[pid]["体力"] < 20 then
			warmenu[6][3] = 0
		end
	end
	
	--鸠摩智指令 幻化
	if match_ID(pid, 103) then
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 then
			warmenu[6][3] = 0
		end
	end
	
	--达尔巴指令 死战
	if match_ID(pid, 160) then
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 or WAR.SZSD ~= -1 then
			warmenu[6][3] = 0
		end
	end
	
	--金轮 龙象
	if match_ID(pid, 62) then
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 then
			warmenu[6][3] = 0
		end
	end
	
	--黄蓉 遁甲
	if match_ID(pid, 56) then
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 then
			warmenu[6][3] = 0
		end
	end
	
	--韦小宝 口才
	if match_ID(pid, 601) then
		if JY.Person[pid]["体力"] < 30 then
			warmenu[6][3] = 0
		end
	end
	
	--苗人凤 破军
	if match_ID(pid, 3) then
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 then
			warmenu[6][3] = 0
		end
	end
	
	--何太冲 铁琴
	if match_ID(pid, 7) then
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 then
			warmenu[6][3] = 0
		end
	end
	

	--李寻欢 飞刀
	if match_ID(pid, 498) then
		if  JY.Person[pid]["内力"] < 1000 then
			warmenu[6][3] = 0
		end
	end	
	--萧秋水 天剑
	if match_ID(pid, 652) and JY.Base["天书数量"] < 7 then
			warmenu[6][3] = 0
		end
	
	--阎基 虚弱
	if match_ID(pid, 4) then	
		if JY.Person[pid]["体力"] < 20 then
			warmenu[6][3] = 0
		end
	end

	--出左右时，移动，解毒，医疗，物品，特色，自动不可见
	if WAR.ZYHB == 2 then
		warmenu[1][3] = 0
		warmenu[5][3] = 0	
		warmenu[8][3] = 0
	end
  
	--体力小于5或者已经移动过时，移动不可见
	if JY.Person[pid]["体力"] <= 5 or WAR.Person[WAR.CurID]["移动步数"] <= 0 then
		warmenu[1][3] = 0
		--isEsc = 1
	end
  
	--判断最小内力，是否可显示攻击
	local minv = War_GetMinNeiLi(pid)
	if JY.Person[pid]["内力"] < minv or JY.Person[pid]["体力"] < 10 then
		warmenu[2][3] = 0
	end

	lib.GetKey()
	Cls()
	DrawTimeBar_sub()
	return Cat('菜单',warmenu, #warmenu, 0, CC.MainMenuX, CC.MainMenuY, 0, 0, 1, 1, CC.DefaultFont, C_ORANGE, C_WHITE)
	
end

--无酒不欢：运功选择菜单
function War_YunGongMenu()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	local id = WAR.Person[WAR.CurID]["人物编号"]
	local menu={};
	menu[1]={"运行内功",SelectNeiGongMenu,1};
	--menu[2]={"停运内功",nil,1};
	menu[2]={"运行轻功",SelectQingGongMenu,1};
	--menu[4]={"停运轻功",nil,1};
	local r =  Cat('菜单',menu,#menu,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
   -- local r = Cat('菜单',menu,#menu,0,CC.MainMenuX, CC.MainMenuY,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);	
	if r == 0 then 
		return 0
	end	
	local r1 = menu[r][2]()
	if r1 == 2 then
		JY.Person[id]["主运内功"] = 0
		DrawStrBoxWaitKey(JY.Person[id]["姓名"].."停止了运行主内功",C_RED,CC.DefaultFont,nil,LimeGreen)
		return 20;
	elseif r1 == 20 then
		return 20;
	elseif r1 == 4 then
		JY.Person[id]["主运轻功"] = 0
		DrawStrBoxWaitKey(JY.Person[id]["姓名"].."停止了运行主轻功",M_DeepSkyBlue,CC.DefaultFont,nil,LimeGreen)
		return 20;
	elseif r1 == 10 then
		return 10;
	end
end

--无酒不欢：选择内功菜单
function SelectNeiGongMenu()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	local id, x1, y1 = WAR.Person[WAR.CurID]["人物编号"], WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"]
	local menu={};
	local a = 0
	for i=1,JY.Base["武功数量"] do
        menu[i]={JY.Wugong[JY.Person[id]["武功" .. i]]["名称"],nil,0};
		if JY.Wugong[JY.Person[id]["武功" .. i]]["武功类型"] == 6 then
			menu[i][3]=1;
		end
		--天罡不能运三大
		if (id == 0 and JY.Base["标准"] == 6)
		and (JY.Person[id]["武功" .. i] == 106 or JY.Person[id]["武功" .. i] == 107 or JY.Person[id]["武功" .. i] == 108) then
			menu[i][3]=0;	
		end
		--五岳剑诀不能运
		--if JY.Person[id]["武功" .. i] == 175 then
		--	menu[i][3]=0
		--end
		if menu[i][3] == 1 then 
			a = 1
		end
	end
	if a == 0 then 
		return 0
	end
	local main_neigong =  Cat('菜单',menu,#menu,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
   -- local main_neigong =  Cat('菜单',menu,#menu,0,CC.MainMenuX, CC.MainMenuY,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);
	if main_neigong ~= nil and main_neigong > 0 then
		CleanWarMap(4, 0)
		SetWarMap(x1, y1, 4, 1)
		War_ShowFight(id, 0, 0, 0, 0, 0, 9)	
		AddPersonAttrib(id, "内力", -200);
		AddPersonAttrib(id, "体力", -5);
		JY.Person[id]["主运内功"] = JY.Person[id]["武功" .. main_neigong]
		Hp_Max(id)
		return 20;
	end
end



--无酒不欢：选择轻功菜单
function SelectQingGongMenu()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	local id, x1, y1 = WAR.Person[WAR.CurID]["人物编号"], WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"]
	local menu={};
	local a = 0
	for i=1,JY.Base["武功数量"] do
        menu[i]={JY.Wugong[JY.Person[id]["武功" .. i]]["名称"],nil,0};
		if JY.Wugong[JY.Person[id]["武功" .. i]]["武功类型"] == 7 then
			menu[i][3]=1;
		end
		if menu[i][3] == 1 then 
			a = 1
		end
	end
	if a == 0 then 
		return 0
	end
	local main_qinggong =  Cat('菜单',menu,#menu,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
   -- local main_qinggong =  Cat('菜单',menu,#menu,0,CC.MainMenuX, CC.MainMenuY,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);
	if main_qinggong ~= nil and main_qinggong > 0 then
		CleanWarMap(4, 0)
		SetWarMap(x1, y1, 4, 1)
		War_ShowFight(id, 0, 0, 0, 0, 0, 9)	
		AddPersonAttrib(id, "体力", -10);
		WAR.YQG = 1
		JY.Person[id]["主运轻功"] = JY.Person[id]["武功" .. main_qinggong]
		return 10;
	end
end

--无酒不欢：战术菜单
function War_TacticsMenu()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	local menu={};
	menu[1]={"蓄力Ｐ",nil,1};
	menu[2]={"防御Ｄ",nil,1};
	menu[3]={"等待Ｗ",nil,1};
	menu[4]={"集中Ｊ",nil,1};
	menu[5]={"休息Ｒ",nil,1};	
	local r =  Cat('菜单',menu,10,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1,LimeGreen)
   -- local r = Cat('菜单',menu,#menu,0,CC.MainMenuX, CC.MainMenuY,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);
	--蓄力
	if r == 1 then
		return War_ActupMenu()
	--防御
	elseif r == 2 then
		return War_DefupMenu()
	--等待
	elseif r == 3 then
		return War_Wait()
	--集中
	elseif r == 4 then
		return War_Focus()
	--休息
	elseif r == 5then
		return War_RestMenu()
	--快捷键的额外判定	
	elseif r == 6 then
		return 1
	--快捷键的额外判定
	elseif r == 7 then
		return 20
	end
end

--无酒不欢：其它菜单
function War_OtherMenu()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	local menu={};
	menu[1]={"用毒Ｖ",nil,1};
	menu[2]={"解毒Ｑ",nil,1};
	menu[3]={"医疗Ｆ",nil,1};
	--menu[4]={"物品",nil,1};
	menu[4]={"状态Ｚ",nil,1};	
	local r =  Cat('菜单',menu,#menu,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1,LimeGreen)
   -- local r = Cat('菜单',menu,#menu,0,CC.MainMenuX, CC.MainMenuY,0,0,1,1,CC.DefaultFont,C_ORANGE, C_WHITE);
	
	--用毒
	if r == 1 then
		return War_PoisonMenu()
	--解毒
	elseif r == 2 then
		return War_DecPoisonMenu()
	--医疗
	elseif r == 3 then
		return War_DoctorMenu()
	--物品
	--elseif r == 4 then
		--return  War_ThingMenu()
	--状态
	elseif r == 4 then
		return  Ckstatus()		
	--快捷键的额外判定
	elseif r == 6 then
		return 1
	--快捷键的额外判定
	elseif r == 7 then
		return 20
	end
end

--修炼武功
function War_PersonTrainBook(pid)
  local p = JY.Person[pid]
  local thingid = p["修炼物品"]
  if thingid < 0 then
    return 
  end
  JY.Thing[101]["加御剑能力"] = 1
  JY.Thing[123]["加拳掌功夫"] = 1
  local wugongid = JY.Thing[thingid]["练出武功"]
  local wg = 0
  if JY.Person[pid]["武功" .. JY.Base["武功数量"]] > 0 and wugongid >= 0 then
    for i = 1, JY.Base["武功数量"] do
      if JY.Thing[thingid]["练出武功"] == JY.Person[pid]["武功" .. i] then
        wg = 1
      end
    end
  if wg == 0 then		--修复第一版本，不可修炼武功的BUG
  	return 
	end
  end
  
  
	local yes1, yes2, kfnum = false, false, nil
	while true do 
		local needpoint = TrainNeedExp(pid)
		if needpoint <= p["修炼点数"] then
			yes1 = true
			AddPersonAttrib(pid, "生命最大值", JY.Thing[thingid]["加生命最大值"])
			--修炼血刀减少生命
			--狄云不减
			if thingid == 139 and match_ID(pid, 37) == false then
				AddPersonAttrib(pid, "生命最大值", -15)
				AddPersonAttrib(pid, "生命", -15)
				if JY.Person[pid]["生命最大值"] < 1 then
					JY.Person[pid]["生命最大值"] = 1
				end
			end
			if JY.Person[pid]["生命"] < 1 then
				JY.Person[pid]["生命"] = 1
			end
			--主角练小无，北冥不调和
			if JY.Thing[thingid]["改变内力性质"] == 2 and JY.Person[pid]["内力性质"] ~= 3 then
				if thingid == 75 or thingid == 64 then
					if pid ~= 0 then
						p["内力性质"] = 2
					end
				else
					p["内力性质"] = 2
				end
			end
			
	    if match_ID(pid, 588)   then		--冯衡 双倍属性值
            AddPersonAttrib(pid, "内力最大值", JY.Thing[thingid]["加内力最大值"])
			AddPersonAttrib(pid, "攻击力", JY.Thing[thingid]["加攻击力"] * 2)
			AddPersonAttrib(pid, "轻功", JY.Thing[thingid]["加轻功"] * 2)
			AddPersonAttrib(pid, "防御力", JY.Thing[thingid]["加防御力"] * 2)
			AddPersonAttrib(pid, "医疗能力", JY.Thing[thingid]["加医疗能力"])
			AddPersonAttrib(pid, "用毒能力", JY.Thing[thingid]["加用毒能力"])
			AddPersonAttrib(pid, "解毒能力", JY.Thing[thingid]["加解毒能力"])
			AddPersonAttrib(pid, "抗毒能力", JY.Thing[thingid]["加抗毒能力"])
		else 
		    AddPersonAttrib(pid, "内力最大值", JY.Thing[thingid]["加内力最大值"])
			AddPersonAttrib(pid, "攻击力", JY.Thing[thingid]["加攻击力"])
			AddPersonAttrib(pid, "轻功", JY.Thing[thingid]["加轻功"])
			AddPersonAttrib(pid, "防御力", JY.Thing[thingid]["加防御力"])
			AddPersonAttrib(pid, "医疗能力", JY.Thing[thingid]["加医疗能力"])
			AddPersonAttrib(pid, "用毒能力", JY.Thing[thingid]["加用毒能力"])
			AddPersonAttrib(pid, "解毒能力", JY.Thing[thingid]["加解毒能力"])
			AddPersonAttrib(pid, "抗毒能力", JY.Thing[thingid]["加抗毒能力"])
			end
			if match_ID(pid, 56) or match_ID(pid, 77)   then		--黄蓉 萧中慧 双倍兵器值
				AddPersonAttrib(pid, "拳掌功夫", JY.Thing[thingid]["加拳掌功夫"] * 2)
				AddPersonAttrib(pid, "指法技巧", JY.Thing[thingid]["加指法技巧"] * 2)
				AddPersonAttrib(pid, "御剑能力", JY.Thing[thingid]["加御剑能力"] * 2)
				AddPersonAttrib(pid, "耍刀技巧", JY.Thing[thingid]["加耍刀技巧"] * 2)
				AddPersonAttrib(pid, "特殊兵器", JY.Thing[thingid]["加特殊兵器"] * 2)
			else
				AddPersonAttrib(pid, "拳掌功夫", JY.Thing[thingid]["加拳掌功夫"])
				AddPersonAttrib(pid, "指法技巧", JY.Thing[thingid]["加指法技巧"])
				AddPersonAttrib(pid, "御剑能力", JY.Thing[thingid]["加御剑能力"])
				AddPersonAttrib(pid, "耍刀技巧", JY.Thing[thingid]["加耍刀技巧"])
				AddPersonAttrib(pid, "特殊兵器", JY.Thing[thingid]["加特殊兵器"])
			end
			
			AddPersonAttrib(pid, "暗器技巧", JY.Thing[thingid]["加暗器技巧"])
			AddPersonAttrib(pid, "武学常识", JY.Thing[thingid]["加武学常识"])
			AddPersonAttrib(pid, "品德", JY.Thing[thingid]["加品德"])
			AddPersonAttrib(pid, "攻击带毒", JY.Thing[thingid]["加攻击带毒"])
			if JY.Thing[thingid]["加攻击次数"] == 1 then
			   p["左右互搏"] = 1
			end
			if thingid == 372 then
			   p["中庸"] = 1
			end
			p["修炼点数"] = p["修炼点数"] - needpoint

			if wugongid >= 0 then 
				yes2 = true
				local oldwugong = 0
				for i = 1, JY.Base["武功数量"] do
					if p["武功" .. i] == wugongid then
						oldwugong = 1
						p["武功等级" .. i] = math.modf((p["武功等级" .. i] + 100) / 100) * 100
						kfnum = i
						break;
					end
				end
				if oldwugong == 0 then
					for i = 1, JY.Base["武功数量"] do
						if p["武功" .. i] == 0 then
							p["武功" .. i] = wugongid
							p["武功等级" .. i] = 0;
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
		DrawStrBoxWaitKey(string.format("%s 修炼 %s 成功", p["姓名"], JY.Thing[thingid]["名称"]), C_WHITE, CC.DefaultFont)
	end
	if yes2 then
		--无酒不欢：自动到极的判定在这里
		if p["武功等级" .. kfnum] == 900 then
			--胡斐等人优先判定
			if (match_ID(pid, 1) and wugongid == 67) or (match_ID(pid, 37) and wugongid == 94) or (match_ID(pid, 49) and wugongid == 14) then
				DrawStrBoxWaitKey(string.format("%s 升为第%s级", JY.Wugong[wugongid]["名称"], math.modf(p["武功等级" .. kfnum] / 100) + 1), C_WHITE, CC.DefaultFont)
			--内功和轻功
			elseif JY.Wugong[wugongid]["武功类型"] == 6 or JY.Wugong[wugongid]["武功类型"] == 7 then
				--三大吸功直接到极
				if wugongid == 85 or wugongid == 87 or wugongid == 88 then
					p["武功等级" .. kfnum] = 999
					DrawStrBoxWaitKey(string.format("%s 已修炼到极", JY.Wugong[wugongid]["名称"]), C_WHITE, CC.DefaultFont)
				elseif match_ID(pid, 637) then
				    p["武功等级" .. kfnum] = 999
					DrawStrBoxWaitKey(string.format("%s 已修炼到极", JY.Wugong[wugongid]["名称"]), C_WHITE, CC.DefaultFont)
				--天内天轻可以到极
				elseif wugongid == p["天赋内功"] or wugongid == p["天赋轻功"] then
					p["武功等级" .. kfnum] = 999
					DrawStrBoxWaitKey(string.format("%s 已修炼到极", JY.Wugong[wugongid]["名称"]), C_WHITE, CC.DefaultFont)
				else
					DrawStrBoxWaitKey(string.format("%s 升为第%s级", JY.Wugong[wugongid]["名称"], math.modf(p["武功等级" .. kfnum] / 100) + 1), C_WHITE, CC.DefaultFont)
				end
			--外功直接到极
			else
				p["武功等级" .. kfnum] = 999
				DrawStrBoxWaitKey(string.format("%s 已修炼到极", JY.Wugong[wugongid]["名称"]), C_WHITE, CC.DefaultFont)
			end
		else
			DrawStrBoxWaitKey(string.format("%s 升为第%s级", JY.Wugong[wugongid]["名称"], math.modf(p["武功等级" .. kfnum] / 100) + 1), C_WHITE, CC.DefaultFont)
		end
	end
	Hp_Max(pid)
end

--特色指令
function War_TgrtsMenu()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	Cls()
	WAR.ShowHead = 0
	WarDrawMap(0)
	local grts_id;
	--如果是畅想
	if pid == 0 then
		grts_id = JY.Base["畅想"]
	else
		grts_id = pid
	end
	--local 
    --if JY.Person[pid]["特色指令"] == 1 then
	   
	--李清露的特色指令特殊
	if match_ID(pid, 574) then	
		local wg = JYMsgBox("特色指令：" .. GRTS[grts_id], GRTSSAY[grts_id], {"寒袖", "白虹"}, 2,  JY.Person[pid]["半身像"],1)
		if wg == 1 then
			JY.Person[pid]["武功1"] = 201
		elseif wg == 2 then
			JY.Person[pid]["武功1"] = 202
		end
		return 0
	--郭襄的指令特殊
	elseif match_ID(pid, 626) then
		local wg = JYMsgBox("特色指令：" .. GRTS[grts_id], GRTSSAY[grts_id], {"弹指", "玉萧", "落英"}, 3, JY.Person[pid]["半身像"],1)
		if wg == 1 then
			JY.Person[pid]["武功1"] = 18
		elseif wg == 2 then
			JY.Person[pid]["武功1"] = 38
		elseif wg == 3 then
			JY.Person[pid]["武功1"] = 12
		end
		return 0
	else
		local yn = JYMsgBox("特色指令：" .. GRTS[grts_id], GRTSSAY[grts_id], {"确定", "取消"}, 2, JY.Person[pid]["半身像"])
		if yn == 2 then
			return 0
		end
	end
		
	--段誉
	if match_ID(pid, 53) then
		if JY.Person[pid]["体力"] > 20 then
			WAR.TZ_DY = 1
			PlayWavE(16)
			CurIDTXDH(WAR.CurID, 72,1, "休迅飞凫 飘忽若神", M_DeepSkyBlue, 15);
			JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
  
	--虚竹
	if match_ID(pid, 49) then
		if JY.Person[pid]["体力"] > 20 and JY.Person[pid]["内力"] > 1000 then
		  JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 5
		  JY.Person[pid]["内力"] = JY.Person[pid]["内力"] - 500
		  local ssh = {}
		  local num = 1
		  for i = 0, WAR.PersonNum - 1 do
			local wid = WAR.Person[i]["人物编号"]
			if WAR.TZ_XZ_SSH[wid] == 1 and WAR.Person[i]["死亡"] == false then
				--封穴25点
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
			name[i][1] = JY.Person[ssh[i][2]]["姓名"]
			name[i][2] = nil
			name[i][3] = 1
		  end
		  --DrawStrBox(CC.MainMenuX, CC.MainMenuY, "催符：", C_GOLD, CC.DefaultFont)
			local r =  Cat('菜单',name,num-1,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
		 -- Cat('菜单',name, num - 1, 10, CC.MainMenuX, CC.MainMenuY + 45, 0, 0, 1, 0, CC.DefaultFont, C_RED, C_GOLD)
		  Cls()
		  PlayWavAtk(32)
		  CurIDTXDH(WAR.CurID, 72,1, "符掌生死 德折群雄")
		  PlayWavE(8)
		 -- local sssid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)
			for DH = 114, 129 do
				Cat('实时特效动画')
				Cls()
				for i = 1, num - 1 do
					local x0 = WAR.Person[WAR.CurID]["坐标X"]
					local y0 = WAR.Person[WAR.CurID]["坐标Y"]
					local dx = WAR.Person[ssh[i][1]]["坐标X"] - x0
					local dy = WAR.Person[ssh[i][1]]["坐标Y"] - y0
					local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
					local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
					local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)

					ry = ry - hb
					
					lib.PicLoadCache(3, DH * 2, rx, ry, 2, 192)
					if DH > 124 then
						DrawString(rx - 10, ry - 15, "封穴", C_GOLD, CC.DefaultFont)
					end
					
				end
				ShowScreen()
				--lib.ShowSurface(0)
				--lib.LoadSur(sssid, 0, 0)
				lib.Delay(CC.BattleDelay)
			end
		 -- lib.FreeSur(sssid)
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
  
  --人厨子
  if match_ID(pid, 89) then
    if JY.Person[pid]["体力"] > 25 and JY.Person[pid]["内力"] > 300 then
      local px, py = WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"]
      local mxy = {
					{WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"] + 1}, 
					{WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"] - 1}, 
					{WAR.Person[WAR.CurID]["坐标X"] + 1, WAR.Person[WAR.CurID]["坐标Y"]}, 
					{WAR.Person[WAR.CurID]["坐标X"] - 1, WAR.Person[WAR.CurID]["坐标Y"]}}
      local zdp = {}
      local num = 1
      for i = 1, 4 do
        if GetWarMap(mxy[i][1], mxy[i][2], 2) >= 0 then
          local mid = GetWarMap(mxy[i][1], mxy[i][2], 2)
          if inteam(WAR.Person[mid]["人物编号"]) then
          	zdp[num] = WAR.Person[mid]["人物编号"]
          	num = num + 1
        	end
        end
        
      end
      local zdp2 = {}
      for i = 1, num - 1 do
        zdp2[i] = {}
        zdp2[i][1] = JY.Person[zdp[i]]["姓名"] .. "·" .. JY.Person[zdp[i]]["体力"]
        zdp2[i][2] = nil
        zdp2[i][3] = 1
      end
		--DrawStrBox(CC.MainMenuX, CC.MainMenuY, "气补：", C_GOLD, CC.DefaultFont)
		local r =  Cat('菜单',zdp2,num-1,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
		--local r = Cat('菜单',zdp2, num - 1, 10, CC.MainMenuX, CC.MainMenuY + 45, 0, 0, 1, 0, CC.DefaultFont, C_RED, C_GOLD)
		Cls()
		AddPersonAttrib(zdp[r], "体力", 50)
		AddPersonAttrib(pid, "体力", -25)
		AddPersonAttrib(pid, "内力", -300)
		PlayWavE(28)
		--lib.Delay(10)
		CurIDTXDH(WAR.CurID, 86,1, "化气补元")
		local Ocur = WAR.CurID
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["人物编号"] == zdp[r] then
				WAR.CurID = i
			end
		end
		Cat('实时特效动画')
		WarDrawMap(0)
		PlayWavE(36)
      --lib.Delay(100)
		lib.Delay(CC.BattleDelay)
		CurIDTXDH(WAR.CurID, 86, 1, "恢复体力50点")
		WAR.CurID = Ocur
		WarDrawMap(0)
    else
    	DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
    	return 0
    end
  end
  
  --张无忌
  if match_ID(pid, 9) then
    if JY.Person[pid]["体力"] > 10 and JY.Person[pid]["内力"] > 500 then
      local nyp = {}
      local num = 1
      for i = 0, WAR.PersonNum - 1 do
        if WAR.Person[i]["我方"] == true and WAR.Person[i]["死亡"] == false and RealJL(WAR.CurID, i, 8) and i ~= WAR.CurID then
          nyp[num] = {}
          nyp[num][1] = JY.Person[WAR.Person[i]["人物编号"]]["姓名"]
          nyp[num][2] = nil
          nyp[num][3] = 1
          nyp[num][4] = i
          num = num + 1
        end
      end
      --DrawStrBox(CC.MainMenuX, CC.MainMenuY, "挪移：", C_GOLD, CC.DefaultFont)
		local r =  Cat('菜单',nyp,num-1,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
      --local r = Cat('菜单',nyp, num - 1, 10, CC.MainMenuX, CC.MainMenuY + 45, 0, 0, 1, 0, CC.DefaultFont, C_RED, C_GOLD)
      Cls()
      local mid = WAR.Person[nyp[r][4]]["人物编号"]
      QZXS("请选择要将" .. JY.Person[mid]["姓名"] .. "挪移到什么位置？")
      War_CalMoveStep(WAR.CurID, 8, 1)
      local nx, ny = nil, nil
      while true do
	      nx, ny = War_SelectMove()
	      if nx ~= nil then
		      if lib.GetWarMap(nx, ny, 2) > 0 or lib.GetWarMap(nx, ny, 5) > 0 then
		        QZXS("此处有人！请重新选择")			--此处有人！请重新选择
	      	elseif CC.SceneWater[lib.GetWarMap(nx, ny, 0)] ~= nil then
	        	QZXS("水面，不可进入！请重新选择")		--水面，不可进入！请重新选择
	       	else
	       		break;
	        end
	      end
	    end
	    PlayWavE(5)
	    CurIDTXDH(WAR.CurID, 88,1, "九阳明尊 挪移乾坤")		--九阳明尊 挪移乾坤
	    local Ocur = WAR.CurID
	    WAR.CurID = nyp[r][4]
	    WarDrawMap(0)
	    CurIDTXDH(WAR.CurID, 88,1)
	    SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, -1)
	    SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, -1)
        SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, -1)
	    WarDrawMap(0)
	    CurIDTXDH(WAR.CurID, 88,1)
	    WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"] = nx, ny
	    WarDrawMap(0)
	    CurIDTXDH(WAR.CurID, 88,1)
	    SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, WAR.Person[WAR.CurID]["贴图"])
	    SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, WAR.CurID)
        SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, JY.Person[WAR.Person[WAR.CurID]["人物编号"]]['头像代号'])
	    WarDrawMap(0)
	    CurIDTXDH(WAR.CurID, 88,1)
	    WAR.CurID = Ocur
	    AddPersonAttrib(pid, "体力", -10)
	    AddPersonAttrib(pid, "内力", -500)
	    
	  else
	  	DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
	  	return 0
	  end
	end
	
	--祖千秋
	if match_ID(pid, 88) then
	  if JY.Person[pid]["体力"] > 10 and JY.Person[pid]["内力"] > 700 then
	    local dxp = {}
	    local num = 1
	    for i = 0, WAR.PersonNum - 1 do
	      if WAR.Person[i]["我方"] == true and WAR.Person[i]["死亡"] == false and RealJL(WAR.CurID, i, 5) and i ~= WAR.CurID then
	        dxp[num] = {}
	        dxp[num][1] = JY.Person[WAR.Person[i]["人物编号"]]["姓名"]
	        dxp[num][2] = nil
	        dxp[num][3] = 1
	        dxp[num][4] = i
	        num = num + 1
	      end
	    end
	    --DrawStrBox(CC.MainMenuX, CC.MainMenuY, "传功：", C_GOLD, 30)
		local r =  Cat('菜单',dxp,num-1,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
	    --local r = Cat('菜单',dxp, num - 1, 10, CC.MainMenuX, CC.MainMenuY + 45, 0, 0, 1, 0, CC.DefaultFont, C_RED, C_GOLD)
	    Cls()
	    local mid = WAR.Person[dxp[r][4]]["人物编号"]
	    PlayWavE(28)
	    --lib.Delay(10)
	    CurIDTXDH(WAR.CurID,87,1, "酒神戏红尘")
	    local Ocur = WAR.CurID
	    WAR.CurID = dxp[r][4]
		Cat('实时特效动画')
		WarDrawMap(0)
	    PlayWavE(36)
	    lib.Delay(CC.BattleDelay)
	    CurIDTXDH(WAR.CurID, 87, 1, "集气上升500")
	    WAR.CurID = Ocur
	    WarDrawMap(0)
	    WAR.Person[dxp[r][4]].Time = WAR.Person[dxp[r][4]].Time + 500
	    if WAR.Person[dxp[r][4]].Time > 999 then
	      WAR.Person[dxp[r][4]].Time = 999
	    end
	    AddPersonAttrib(pid, "体力", -10)
	    AddPersonAttrib(pid, "内力", -1000)
	  else
	  	DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
	  	return 0
		end
	end
	

	--萧中慧，慧心
	if match_ID(pid, 77) then
		if JY.Person[pid]["生命"] > 500 and JY.Person[pid]["受伤程度"] < 50 then
			local zjwid = nil
			for i = 0, WAR.PersonNum - 1 do
				if WAR.Person[i]["人物编号"] == 0 and WAR.Person[i]["死亡"] == false then
					zjwid = i
					break
				end
			end
			if zjwid ~= nil then
				DrawStrBoxWaitKey("我心本慧·侠女柔情", C_RED, 36)
				say("２慧妹……！",0,1)
				if JY.Person[0]["性别"] == 0 then
					say("１ｎ哥哥，９请…………２加油！",77,0)
				else
					say("１ｎ姐姐，９请…………２加油！",77,0)
				end
				JY.Person[pid]["生命"] = 1
				JY.Person[pid]["受伤程度"] = 100
				WAR.Person[WAR.CurID].Time = -500
				JY.Person[0]["生命"] = JY.Person[0]["生命最大值"]
				JY.Person[0]["受伤程度"] = 0
				WAR.Person[zjwid].Time = 999
				WAR.FXDS[0] = nil
				WAR.LQZ[0] = 100
			else
				DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)		-- "未满足发动条件"
				return 0
			end

		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)		-- "未满足发动条件"
			return 0
		end
	end
	
	--蓝烟清：王难姑特色指令 - 施毒  周围五格范围内的敌人时序中毒并时序减血
	if match_ID(pid, 17) then
		if JY.Person[pid]["体力"] >= 30 and JY.Person[pid]["内力"] >= 300 then
			CleanWarMap(4,0);
			AddPersonAttrib(pid, "体力", -15)
			AddPersonAttrib(pid, "内力", -300)
			local x1 = WAR.Person[WAR.CurID]["坐标X"];
			local y1 = WAR.Person[WAR.CurID]["坐标Y"];
			for ex = x1 - 5, x1 + 5 do
				for ey = y1 - 5, y1 + 5 do
					SetWarMap(ex, ey, 4, 1)
					if GetWarMap(ex, ey, 2) ~= nil and GetWarMap(ex, ey, 2) > -1 then
						local ep = GetWarMap(ex, ey, 2)
						if WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[ep]["我方"] then
	          
							WAR.L_WNGZL[WAR.Person[ep]["人物编号"]] = 50;			--50时序内持续减中毒+减血
							SetWarMap(ex, ey, 4, 4)
						end
					end
				end
			end
			War_ShowFight(pid,0,0,0,x1,y1,30);
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--brolycjw：胡青牛特色指令 - 群疗  周围五格范围内的队友时序回内伤并按比例回血
	if match_ID(pid, 16) then
		if JY.Person[pid]["体力"] >= 30 and JY.Person[pid]["内力"] >= 300 then
			CleanWarMap(4,0);
			AddPersonAttrib(pid, "体力", -15)
			AddPersonAttrib(pid, "内力", -300)
			local x1 = WAR.Person[WAR.CurID]["坐标X"];
			local y1 = WAR.Person[WAR.CurID]["坐标Y"];
			
			for ex = x1 - 5, x1 + 5 do
				for ey = y1 - 5, y1 + 5 do
					SetWarMap(ex, ey, 4, 1)
					if GetWarMap(ex, ey, 2) ~= nil and GetWarMap(ex, ey, 2) > -1 then
						local ep = GetWarMap(ex, ey, 2)
						if WAR.Person[WAR.CurID]["我方"] == WAR.Person[ep]["我方"] then
				  
							WAR.L_HQNZL[WAR.Person[ep]["人物编号"]] = 20;			--20时序内持续回血+回内伤
							SetWarMap(ex, ey, 4, 4)
					  
						end
					end
				end
			end
			War_ShowFight(pid,0,0,0,x1,y1,0);

		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--慕容复 幻梦
	if match_ID(pid, 51) then
		if JY.Person[pid]["体力"] > 20 then
			WAR.TZ_MRF = 1
			CurIDTXDH(WAR.CurID, 127,1, "顾盼子孙贤 铭记复国志", C_GOLD);
			JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--小昭 影步
	if match_ID(pid, 66) then
		if JY.Person[pid]["体力"] > 30 and JY.Person[pid]["内力"] > 2000 then
			War_CalMoveStep(WAR.CurID, 10, 0)
			WAR.XZ_YB[1],WAR.XZ_YB[2]=War_SelectMove()
			JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 20
			JY.Person[pid]["内力"] = JY.Person[pid]["内力"] - 1000
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--钟灵指令 灵貂
	if match_ID(pid, 90) then
		if JY.Person[pid]["体力"] > 10 then
			War_CalMoveStep(WAR.CurID, 8, 1)
			local x,y = War_SelectMove()
			if lib.GetWarMap(x, y, 2) > 0 or lib.GetWarMap(x, y, 5) > 0 then
				local tdID = lib.GetWarMap(x, y, 2)
				if WAR.Person[tdID]["我方"] == WAR.Person[WAR.CurID]["我方"] then
					return 0
				end
				local eid = WAR.Person[tdID]["人物编号"]
				local x0, y0 = WAR.Person[WAR.CurID]["坐标X"],WAR.Person[WAR.CurID]["坐标Y"]
				local x1, y1 = WAR.Person[tdID]["坐标X"],WAR.Person[tdID]["坐标Y"]
				for i = 1, 4 do
					if 0 < JY.Person[eid]["携带物品数量" .. i] and -1 < JY.Person[eid]["携带物品" .. i] then
						WAR.TD = JY.Person[eid]["携带物品" .. i]
						WAR.TDnum = JY.Person[eid]["携带物品数量" .. i]
						JY.Person[eid]["携带物品数量" .. i] = 0
						JY.Person[eid]["携带物品" .. i] = -1
						break
					end
				end
				WAR.Person[WAR.CurID]["人方向"] = War_Direct(x0, y0, x1, y1)
				CleanWarMap(4, 0)
				SetWarMap(x1, y1, 4, 1)
				WAR.Person[tdID]["中毒点数"] = (WAR.Person[tdID]["中毒点数"] or 0) + AddPersonAttrib(eid, "中毒程度", 50)
				WAR.TXXS[eid] = 1
				War_ShowFight(WAR.Person[WAR.CurID]["人物编号"], 0, 0, 0, 0, 0, 12)
				if WAR.TD ~= -1 then
					if WAR.TD == 118 then
						say("１想要从我慕容复手中偷东西？哼哼，下辈子吧！", 51,0)
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
			JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 5
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--胡斐 飞狐
	if match_ID(pid, 1) then
		if JY.Person[pid]["体力"] > 20 then
			War_CalMoveStep(WAR.CurID, 10, 2)
			local x,y = War_SelectMove()
			if not x then
				return 0
			end
			if GetWarMap(x, y, 1) > 0 or GetWarMap(x, y, 2) > 0 or GetWarMap(x, y, 5) > 0 or CC.WarWater[GetWarMap(x, y, 0)] ~= nil then
				return 0
			else
				CurIDTXDH(WAR.CurID, 25,1, "雪山飞狐", Violet);
				WAR.Person[WAR.CurID]["移动步数"] = 10
				War_MovePerson(x, y, 1)
				WAR.Person[WAR.CurID]["移动步数"] = 0
				JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
			end
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--鸠摩智 幻化
	if match_ID(pid, 103) then
		if JY.Person[pid]["体力"] > 20 and JY.Person[pid]["内力"] > 1000 then
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
					if JY.Thing[id]["类型"] == 2 and JY.Thing[id]["练出武功"] > -1 then
						thing[num] = id
						thingnum[num] = JY.Base["物品数量" .. i + 1]
						num = num + 1
					end
				end 
			end
			IsViewingKungfuScrolls = 1
			local r = SelectThing(thing, thingnum)
			if r >= 0 then
				CurIDTXDH(WAR.CurID, 93,1, "无相幻化", C_GOLD)
				JY.Person[pid]["武功2"]= JY.Thing[r]["练出武功"]
				JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
				JY.Person[pid]["内力"] = JY.Person[pid]["内力"] - 500
			else
				return 0
			end
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--达尔巴指令 死战
	if match_ID(pid, 160) then
		if JY.Person[pid]["体力"] > 20 and JY.Person[pid]["内力"] > 1000 then
			War_CalMoveStep(WAR.CurID, 8, 1)
			local x,y = War_SelectMove()
			if lib.GetWarMap(x, y, 2) > 0 or lib.GetWarMap(x, y, 5) > 0 then
				local tdID = lib.GetWarMap(x, y, 2)
				if WAR.Person[tdID]["我方"] == WAR.Person[WAR.CurID]["我方"] then
					return 0
				end
				local eid = WAR.Person[tdID]["人物编号"]
				WAR.SZSD = eid
				
				CurIDTXDH(WAR.CurID, 93,1, "锁定目标", C_GOLD)
				JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
				JY.Person[pid]["内力"] = JY.Person[pid]["内力"] - 500
			else
				return 0
			end
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--金轮 龙象
	if match_ID(pid, 62) then
		if JY.Person[pid]["体力"] > 20 and JY.Person[pid]["内力"] > 1000 then
			War_ActupMenu()
			WAR.SLSX[pid] = 2
			JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
			JY.Person[pid]["内力"] = JY.Person[pid]["内力"] - 500
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end

	--黄蓉 遁甲
	if match_ID(pid, 56) then
		if JY.Person[pid]["体力"] > 20 and JY.Person[pid]["内力"] > 1000 then
			local x,y = WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"]
			--1绿色，2红色，3蓝色，4紫色
			CleanWarMap(6,-1);
					
			local QMDJ = {"休","生","伤","杜","景","死","惊","开"}
						
			--在自身周围绘制奇阵
			SetWarMap(x,y, 6, math.random(4))
			
			for j=1, 2 do
				SetWarMap(x + math.random(6), y + math.random(6), 6, math.random(4));
				for n = 30, 40 do
					local i = n
					if i > 40 then
						i = 40
					end
					Cat('实时特效动画')
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
					Cat('实时特效动画')
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
					Cat('实时特效动画')
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
					Cat('实时特效动画')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
				
			end
			JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
			JY.Person[pid]["内力"] = JY.Person[pid]["内力"] - 500
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--阿紫，禁药
	if match_ID(pid, 47) then
		WAR.JYZT[pid] = 1
		CurIDTXDH(WAR.CurID, 128,1, "禁药", C_RED);
		return 20
	end
	
	--韦小宝 口才
	if match_ID(pid, 601) then
		if JY.Person[pid]["体力"] > 30 then
			War_CalMoveStep(WAR.CurID, 8, 1)
			local x,y = War_SelectMove()
			if lib.GetWarMap(x, y, 2) > 0 or lib.GetWarMap(x, y, 5) > 0 then
				local tdID = lib.GetWarMap(x, y, 2)
				if WAR.Person[tdID]["我方"] == WAR.Person[WAR.CurID]["我方"] then
					return 0
				end
				local eid = WAR.Person[tdID]["人物编号"]
				WAR.CSZT[eid] = 1
				
				Cls()
				local KC = {"阁下英明神武","鸟生鱼汤"}
				
				for n = 1, #KC + 25 do
					local i = n 
					if i > #KC then 
						i = #KC
					end
					lib.GetKey()
					Cat('实时特效动画')
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
				JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 15
			else
				return 0
			end
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--苗人凤指令 破军
	if match_ID(pid, 3) then
		if JY.Person[pid]["体力"] > 20 and JY.Person[pid]["内力"] > 1000 then
			WAR.MRF = 1
			if Cat('武功') == 0 then
			--if War_FightMenu() == 0 then
				return 0
			end
			JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
			JY.Person[pid]["内力"] = JY.Person[pid]["内力"] - 300
			WAR.MRF = 0
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end

	
	--灭绝，俱焚
	if match_ID(pid, 6) then
		WAR.YSJF[pid] = 100
		CurIDTXDH(WAR.CurID, 124,1, "玉石俱焚", M_Silver);
		return 20
	end

	--谢逊指令 咆哮
	if match_ID(pid, 13) then
		if JY.Person[pid]["体力"] > 20 and JY.Person[pid]["内力"] > 3000 then
			CurIDTXDH(WAR.CurID, 118,1, "狮王咆哮", C_GOLD)
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.Person[j]["死亡"] == false then
					WAR.HLZT[WAR.Person[j]["人物编号"]] = 2
				end
			end
			JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
			JY.Person[pid]["内力"] = JY.Person[pid]["内力"] - 2000
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	--丘处机 一言止杀
	if match_ID(pid, 68) then
		if JY.Person[pid]["体力"] > 20 and WAR.JSZT1[pid]~= nil and WAR.JSZT1[pid] == 0 then
			CurIDTXDH(WAR.CurID, 118,1, "一言止杀", C_GOLD)
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.Person[j]["死亡"] == false then		
                local offset1 = math.abs(WAR.Person[j]["坐标X"] - WAR.Person[WAR.CurID]["坐标X"])
                local offset2 = math.abs(WAR.Person[j]["坐标Y"] - WAR.Person[WAR.CurID]["坐标Y"])				
				if offset1 < 10 and offset2 < 10 then
				WAR.YYZS[WAR.Person[j]["人物编号"]] = 1
				end
			 end
			end
			JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 15
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
		WAR.JSZT1[pid]= nil
	end
	--霍青桐统率指令，我方全体防御提升50时序
	if match_ID(pid, 74) then
		if JY.Person[pid]["体力"] > 10 and JY.Person[pid]["内力"] > 150 and WAR.HQT_CD == 0 then
			CurIDTXDH(WAR.CurID, 92,1, "指挥");		--动画显示
			for i = 0, WAR.PersonNum - 1 do
				if WAR.Person[i]["我方"] == true and WAR.Person[i]["死亡"] == false then
					WAR.HQT_ZL[WAR.Person[i]["人物编号"]] = 50
					WAR.HQT_CD = 2
					WAR.Person[i].Time = WAR.Person[i].Time + 500;
					if WAR.Person[i].Time > 999 then
						WAR.Person[i].Time = 999;
				end
			end
			end
			AddPersonAttrib(pid, "体力", -15)
			AddPersonAttrib(pid, "内力", -500)
			--lib.Delay(100)		
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
	  	return 0
		end
	end

	--何太冲指令 琴音
	if match_ID(pid, 7) then
		if JY.Person[pid]["体力"] > 20 and JY.Person[pid]["内力"] > 1000 then
			CleanWarMap(4, 0)
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
					local eid = WAR.Person[j]["人物编号"]
					local qycs = WAR.QYZT[eid] or 0
					if qycs > 0 then
						WAR.TXXS[eid] = 1
						--无酒不欢：记录人物血量
						WAR.Person[j]["Life_Before_Hit"] = JY.Person[eid]["生命"]
						JY.Person[eid]["生命"] = JY.Person[eid]["生命"] - 50*qycs
						WAR.Person[j]["生命点数"] = (WAR.Person[j]["生命点数"] or 0) - 50*qycs
						SetWarMap(WAR.Person[j]["坐标X"], WAR.Person[j]["坐标Y"], 4, 1)
						WAR.QYZT[eid] = nil
					end
				end
			end
			War_ShowFight(WAR.Person[WAR.CurID]["人物编号"], 0, 0, 0, 0, 0, 144)
			JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
			JY.Person[pid]["内力"] = JY.Person[pid]["内力"] - 500
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--阎基指令 虚弱
	if match_ID(pid, 4) then
		if JY.Person[pid]["体力"] > 20 then
			War_CalMoveStep(WAR.CurID, 8, 1)
			local x,y = War_SelectMove()
			if lib.GetWarMap(x, y, 2) > 0 or lib.GetWarMap(x, y, 5) > 0 then
				local tdID = lib.GetWarMap(x, y, 2)
				if WAR.Person[tdID]["我方"] == WAR.Person[WAR.CurID]["我方"] then
					return 0
				end
				local eid = WAR.Person[tdID]["人物编号"]
				local x0, y0 = WAR.Person[WAR.CurID]["坐标X"],WAR.Person[WAR.CurID]["坐标Y"]
				local x1, y1 = WAR.Person[tdID]["坐标X"],WAR.Person[tdID]["坐标Y"]
				
				WAR.XRZT[eid] = 40
				WAR.Person[WAR.CurID]["人方向"] = War_Direct(x0, y0, x1, y1)
				CleanWarMap(4, 0)
				SetWarMap(x1, y1, 4, 1)
				War_ShowFight(WAR.Person[WAR.CurID]["人物编号"], 0, 0, 0, 0, 0, 148)
			else
				return 0
			end
			JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	
	--黛绮丝，倾国
	if match_ID(pid, 15) then
	   if JY.Person[pid]['内力'] >= 2000 and JY.Person[pid]["体力"] >= 10 then
		  WAR.QGZT[pid] = 6
		  CurIDTXDH(WAR.CurID, 149,1)
		  JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
		  JY.Person[pid]["内力"] = JY.Person[pid]["内力"] - 2000
	   else 
          DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
       end	   
	   return 20
	end
	
	--喵姐指令 女装
	if match_ID(pid, 92) then
		if JY.Person[pid]["体力"] > 20 then
			WarDrawMap(0)
			CurIDTXDH(WAR.CurID, 135, 1, "日出东方 唯喵姐不败", C_GOLD)
			lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, -1)
			lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, -1)
			WarDrawMap(0)
			local mj = {}
			if JY.Person[pid]["性别"] == 0 then
				JY.Person[pid]["头像代号"] = 384
				JY.Person[pid]["半身像"] = 504
				JY.Person[pid]["性别"] = 1
				JY.Person[pid]["武功2"] = 105
				JY.Person[pid]["天赋内功"] = 105
				JY.Person[pid]["主运内功"] = 105
				mj[1]={0,13,0,0,0}
				mj[2]={0,11,0,0,0}
				mj[3]={0,11,0,0,0}
			else
				JY.Person[pid]["头像代号"] = 387
				JY.Person[pid]["半身像"] = 92
				JY.Person[pid]["性别"] = 0
				JY.Person[pid]["武功2"] = 105
				JY.Person[pid]["天赋内功"] = 105
				JY.Person[pid]["主运内功"] = 105
				mj[1]={0,14,0,0,0}
				mj[2]={0,12,0,0,0}
				mj[3]={0,12,0,0,0}
			end
			for i = 1, 5 do
				JY.Person[pid]["出招动画帧数" .. i] = mj[1][i]
				JY.Person[pid]["出招动画延迟" .. i] = mj[2][i]
				JY.Person[pid]["武功音效延迟" .. i] = mj[3][i]
			end	

			WAR.Person[WAR.CurID]["贴图"] = WarCalPersonPic(WAR.CurID)
			WarDrawMap(0)
			CurIDTXDH(WAR.CurID, 135, 1, "日出东方 唯喵不败", C_GOLD)
			SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, WAR.Person[WAR.CurID]["贴图"])
			SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, WAR.CurID)
            SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, JY.Person[WAR.Person[WAR.CurID]["人物编号"]]['头像代号'])
			WarDrawMap(0)
			CurIDTXDH(WAR.CurID, 135, 1, "日出东方 唯喵不败", C_GOLD)
			JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end
	--李寻欢 飞刀
	if match_ID(pid, 498) then
		if WAR.XLFD[pid] ~= nil then
			WAR.XLFD[pid] = nil
			return 20
		end
		if JY.Person[pid]["体力"] > 20 and JY.Person[pid]["内力"] > 1000 then
			WAR.XLFD[pid] = 100
			CurIDTXDH(WAR.CurID, 124,1,"小李飞刀",C_GOLD)
			JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
			JY.Person[pid]["内力"] = JY.Person[pid]["内力"] - 500
			return 20
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end	
	--萧秋水 惊天一剑
	if match_ID(pid, 652)  then
		if WAR.JTYJ[pid] ~= nil then
			WAR.JTYJ[pid] = nil
			return 20
		end
		if JY.Person[pid]["体力"] > 20 and JY.Person[pid]["内力"] > 1000 and WAR.LQZ[pid] == 100 and WAR.DZXY ~= 1  then
			WAR.JTYJ[pid] = 20
			CurIDTXDH(WAR.CurID, 132,1,"天剑",C_GOLD)
			JY.Person[pid]["体力"] = JY.Person[pid]["体力"] - 10
			JY.Person[pid]["内力"] = JY.Person[pid]["内力"] - 500
			return 20
		else
			DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
			return 0
		end
	end	
	
	--梅长苏 麒麟
	if match_ID(pid, 9969) then
		local ql = 1
		local bx,by = CC.ScreenW/936,CC.ScreenH/701
		local menu={};
		local mj = {}
		local str = '策马迎风 看人生起伏'
		local p = 507
		local ts = JY.Base['天书数量']
		menu[1]={"换装",nil,1};
		menu[2]={"麒麟不动",nil,1};
		mj[1]={0,10,0,0,0}
		mj[2]={0,9,0,0,0}
		mj[3]={0,9,0,0,0}
		if match_ID(pid, 507) then 
			mj[1]={0,14,0,0,0}
			mj[2]={0,14,0,0,0}
			mj[3]={0,14,0,0,0}
			p = 508
			str = '江左梅郎  麒麟之才'
			ql =  Cat('菜单',menu,#menu,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
			if ql == 0 then 
				return 0
			end	
		end
		if ql == 1 then
			WarDrawMap(0)
			CurIDTXDH(WAR.CurID, 135, 1, str, C_GOLD)
			lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, -1)
			lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, -1)
			WarDrawMap(0)
			JY.Person[pid]["头像代号"] = JY.Person[p]["头像代号"]
			JY.Person[pid]["半身像"] = JY.Person[p]["半身像"]
			for i = 1, 5 do
				JY.Person[pid]["出招动画帧数" .. i] = mj[1][i]
				JY.Person[pid]["出招动画延迟" .. i] = mj[2][i]
				JY.Person[pid]["武功音效延迟" .. i] = mj[3][i]
			end	
			JY.Base['畅想'] = p
			--lib.PicLoadFile(string.format(CC.FightPicFile[1], JY.Person[pid]["头像代号"]), string.format(CC.FightPicFile[2], JY.Person[pid]["头像代号"]), 4 + WAR.CurID)

			WAR.Person[WAR.CurID]["贴图"] = WarCalPersonPic(WAR.CurID)
			WarDrawMap(0)
			CurIDTXDH(WAR.CurID, 135, 1, str, C_GOLD)
			lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, WAR.Person[WAR.CurID]["贴图"])
			lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, WAR.CurID)
            SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, JY.Person[WAR.Person[WAR.CurID]["人物编号"]]['头像代号'])
			WarDrawMap(0)
			CurIDTXDH(WAR.CurID, 135, 1, str, C_GOLD)
		elseif ql == 2 then 
			if ts <= 0 or JY.Person[pid]['体力'] < 10 then 
				DrawStrBoxWaitKey("未满足发动条件", C_WHITE, CC.DefaultFont)
				return 0
			end
			local x = WAR.Person[WAR.CurID]["坐标X"];
			local y = WAR.Person[WAR.CurID]["坐标Y"];
			local page = 1

			War_CalMoveStep(WAR.CurID,255,1)
			Cat('实时特效动画')
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
			if i >= 0 and WAR.Person[i]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
				id = WAR.Person[i]['人物编号']
				for j = 1,JY.Base['武功数量'] do 
					if JY.Person[id]['武功'..j] > 0 then 
						kfmenu[#kfmenu+1] = {JY.Wugong[JY.Person[id]['武功'..j]]['名称'],JY.Person[id]['武功'..j],1,JY.Person[id]['武功等级'..j]}
					end
				end
			end
			if #kfmenu == 0 then 
				DrawStrBoxWaitKey("目标无武功可学", C_WHITE, CC.DefaultFont)
				return 0
			end
			local r = Cat('菜单',kfmenu,#kfmenu,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
			if r <= 0 then 
				return 0
			end
			
			kfid = kfmenu[r][2]
			kflv = kfmenu[r][4]
			local kfmenu1 = {}
			if ts > JY.Base["武功数量"] then
				ts = JY.Base["武功数量"]
			end
			for j = 1,ts do
				local kn = '空白'
				if JY.Person[pid]['武功'..j] > 0 then 
					kn = JY.Wugong[JY.Person[pid]['武功'..j]]['名称']
				end
				kfmenu1[#kfmenu1+1] = {kn,j,1}
				if JY.Person[pid]['武功'..j] <= 0 then 
					break
				end
			end
			local r1 = Cat('菜单',kfmenu1,#kfmenu1,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
			if r1 <= 0 then 
				return 0
			end
			JY.Person[pid]['武功'..kfmenu1[r1][2]] = kfid
			JY.Person[pid]['武功等级'..kfmenu1[r1][2]] = kflv
			AddPersonAttrib(pid,'体力',-10)
			CurIDTXDH(WAR.CurID, 135, 1, '江左梅郎  麒麟之才', C_GOLD)
		end
	end
	
	return 1
end

--战斗蓄力
function War_ActupMenu()
	local p = WAR.CurID
	local id = WAR.Person[p]["人物编号"]
	local x0, y0 = WAR.Person[p]["坐标X"], WAR.Person[p]["坐标Y"]
	


	--主运蛤蟆蓄力带防御效果
	if Curr_NG(id, 95) then
		WAR.Actup[id] = 2;
		WAR.Defup[id] = 1
		WAR.HMGXL[id] = 1
		CurIDTXDH(WAR.CurID, 85,1,"攻守兼备·蓄势待发", LightSlateBlue);
		return 1;
	
	--被动龙象蓄力带防御效果
	elseif PersonKF(id, 103) then
		WAR.Actup[id] = 2;
		WAR.Defup[id] = 1
		CurIDTXDH(WAR.CurID, 85, 1,"龙之蓄力·象之防御", LightGreen);
		return 1;
		--被动紫霞蓄力强化
	elseif PersonKF(id, 89) then
		WAR.Actup[id] = 2
		if inteam(id) then
			WAR.ZXXS[id] = 1 + math.modf(JY.Base["天书数量"]/7)
		else
			WAR.ZXXS[id] = 3
		end
		CurIDTXDH(WAR.CurID, 85, 1,"紫霞蓄势·连绵不绝", Violet);
		return 1;

	--标主蓄力必成功
	elseif id == 0  then
		WAR.Actup[id] = 2
	--NPC蓄力必成功
	elseif not inteam(id) then
		WAR.Actup[id] = 2
	--我方，赵敏在场必成功
	elseif ZDGH(WAR.CurID,609) then
		WAR.Actup[id] = 2
	--常态70%几率成功
	elseif JLSD(15, 85, id) then
		WAR.Actup[id] = 2
	end
	if WAR.Actup[id] ~= 2 then
			for i = 1,10 do
				Cat('实时特效动画')
				Cls()
				DrawStrBox(-1, -1, "蓄力失败", C_GOLD, CC.DefaultFont)
				ShowScreen()
				lib.Delay(CC.BattleDelay)
			end
	else
		CurIDTXDH(WAR.CurID, 85, 1,"蓄力成功", C_GOLD);
	end
	return 1
end


--战斗防御
function War_DefupMenu()
	local p = WAR.CurID
	local id = WAR.Person[p]["人物编号"]
	local x0, y0 = WAR.Person[p]["坐标X"], WAR.Person[p]["坐标Y"]
	WAR.Defup[id] = 1
	Cls()
	--local hb = GetS(JY.SubScene, x0, y0, 4)
	  
	--太玄防御带蓄力
	if PersonKF(id, 102) then
		WAR.Actup[id] = 2;
		CurIDTXDH(WAR.CurID, 86,1,"防御开始·太玄蓄力", C_RED);
		return 1;
	end
	  
	CurIDTXDH(WAR.CurID, 86,1,"防御开始", LimeGreen);

	return 1
end

--设置人物的集气值，返回一个综合值以便循环刷新集气条
function GetJiqi()
	local num, total = 0, 0
	--无酒不欢：轻功对于人物集气的影响函数
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
	--无酒不欢：敌人集气随难度变化
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
	local dgqb = {}			--记录独孤求败的数据
	local max_jq = 0		--记录全场最高集气	
	for i = 0, WAR.PersonNum - 1 do
		if not WAR.Person[i]["死亡"] then
			local id = WAR.Person[i]["人物编号"]
			WAR.Person[i].TimeAdd = (getnewmove(WAR.Person[i]["轻功"]) + getnewmove1(JY.Person[id]["内力"], JY.Person[id]["内力最大值"]) + JY.Person[id]["体力"] / 30)
			

			if not inteam(id) then
				local nd = JY.Base["难度"]-1
				WAR.Person[i].TimeAdd = math.modf(WAR.Person[i].TimeAdd*(1+nd*0.05))
			end	
			
			WAR.Person[i].TimeAdd = math.modf(WAR.Person[i].TimeAdd)
			--end
			
			--5点集气集气 JY.Person[id]["防具"] == 61
			if WAR.Person[i].TimeAdd < 5 then
				WAR.Person[i].TimeAdd = 5
			end
			--主运葵花，集气速度+20%
			--萧半和觉醒
			if Curr_NG(id,105) or (match_ID_awakened(id, 189, 1) and PersonKF(id, 105)) then
				WAR.Person[i].TimeAdd = math.modf(WAR.Person[i].TimeAdd * 1.2)
			end
			--葵花神功被动，集气+3
			--萧半和觉醒
			if PersonKF(id,105)  or (match_ID_awakened(id, 189, 1) ) then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 3
			end
			--
				--打狗阵
	        if WAR.ZDDH == 344 and inteam(id) == false then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 10
            end	
			
			--if match_ID(id,582)then
			for j = 0, WAR.PersonNum - 1 do
				if match_ID(WAR.Person[j]["人物编号"], 582) and WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[i]["我方"] then
					WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd - 5
					break	
				end
			end
			
			--玉女心经被动，集气+1
			if PersonKF(id,154) then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 1
			end		
			--主运飞天，集气+3 胡一刀
			if Curr_QG(id,145) or match_ID(id,633) then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 3
			end
			
			--运行天赋轻功
			if JY.Person[id]["主运轻功"] > 0 and JY.Person[id]["主运轻功"] == JY.Person[id]["天赋轻功"] then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 1
			end
			
			--胡斐，乔峰，集气+8
			if match_ID(id, 1) or match_ID(id, 50) then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 8
			end
			
			--东方不败，集气+6
			if match_ID(id, 27) then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 6
			end
			
            if WAR.PD['八酒杯'][id] ~= nil then 
                WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + WAR.PD['八酒杯'][id]*4
            end
            
			--韦一笑，成昆，黄药师
			if match_ID(id, 14) or match_ID(id, 18) or match_ID(id, 57)  then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 10
			end
			--一灯，重生后额外集气速度+5
			if match_ID(id, 65) and WAR.FUHUOZT[id] ~= nil then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 5
			end

			--王重阳，重生后额外集气速度+5
			if match_ID(id, 129) and WAR.FUHUOZT[id] ~= nil then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 5
			end
			
			
			--田伯光 万里独行 人越少集气越快
			--觉醒仪琳 单通
			if match_ID(id, 29)  then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 20
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[i]["我方"] then
						WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd - 4
					end
				end
			end
		  
			--公孙止，我方每死亡一个人，集气速度+2
			if match_ID(id, 616) then
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["死亡"] == true and WAR.Person[j]["我方"] == WAR.Person[i]["我方"] then
						WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 2
					end
				end
			end
            
			--司空摘星，敌方人越多集气速度越快
			if match_ID(id, 579) then
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[i]["我方"] then
						WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 5
					end
				end
			end	

			--圣火三使，同时在场时，每人集气速度额外+20点
			if WAR.ZDDH == 14 and (id == 173 or id == 174 or id == 175) then
				local shz = 0
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[i]["我方"] then
						shz = shz + 1
					end
				end
				
				if shz == 3 then
					WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 20
				end
			end
		  
			--蓝烟清：天罡北斗阵，集气+6
			if WAR.ZDDH == 73 and WAR.Person[i]["我方"] == false then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 6
			end
			  
			--山洞妹妹给主角+2集气
			if id == 0 then
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["人物编号"] == 92 and WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == WAR.Person[i]["我方"] then
						WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 2
						break
					end
				end
			end
			
			if WAR.PD['徐如林'][id] ~= nil then 
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + WAR.PD['徐如林'][id]
			end
			
			--主运太极神功，太极之形增加集气
			if Curr_NG(id, 171) and WAR.TJZX[id] ~= nil then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + WAR.TJZX[id]
			end
	      --司空摘星挨打增加集气
	        if match_ID(id, 579) and id == 0 and  WAR.SKZX[id] ~= nil then
	        WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + WAR.SKZX[id]
	        end			
			--主角论剑打赢东方奖励+8
			if id == 0 and JY.Person[27]["论剑奖励"] == 1 then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 8
			end
	  
			--平一指，集气速度额外加成5*杀人数
			if match_ID(id, 28) then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + WAR.PYZ * 5
			end
			--装备白马 1级加2集气，
			if JY.Person[id]["坐骑"] == 230 then
				local sd = 2
				if JY.Thing[230]["装备等级"] >= 5 then
					sd = 4
				elseif JY.Thing[230]["装备等级"] >= 3 then
					sd = 3
				end
				--李文秀的效果翻倍
				if match_ID(id, 590) then
					sd = sd * 2
				end
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + sd
			end
			
			--装备毛驴 集气速度+10点
			if JY.Person[id]["坐骑"] == 279 then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 10;
			end
			--装备飞云 集气速度+10点
			if JY.Person[id]["坐骑"] == 264 then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 12;
			end			
			--装备青驴 集气速度+5点
			if JY.Person[id]["坐骑"] == 339 then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 5;
			end
			--装备汗血宝马 集气速度+5点
			if JY.Person[id]["坐骑"] == 262 then
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 8;
			end			
			--瘦黄马，血量越低集气越快，50%血+5，0血+10
			if JY.Person[id]["坐骑"] == 284 and JY.Thing[284]["装备等级"] == 6 and JY.Person[id]["生命"] < JY.Person[id]["生命最大值"]/2 then
				local spd_add = 5;
				spd_add = spd_add + math.floor(JY.Person[id]["生命最大值"]/2 - JY.Person[id]["生命"]/100)
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + spd_add;
			end	
			--阿紫曼珠沙华，血量越低集气越快，100%血无加成，0血100%加成
			if match_ID(id, 47) and WAR.JYZT[id]~=nil then
				local bonus_perctge = 0
				bonus_perctge = 2 - JY.Person[id]["生命"] / JY.Person[id]["生命最大值"]
				WAR.Person[i].TimeAdd = math.modf(WAR.Person[i].TimeAdd * bonus_perctge)
			end
		
            if Curr_NG(id, 227) and WAR.Actup[id] ~= nil and WAR.Actup[id] > 0 then
                WAR.Person[i].TimeAdd = math.modf(WAR.Person[i].TimeAdd * 1.3)
            end
            
			--周芷若，每个外功+1集气
			if match_ID(id, 631) then
				local zzr = 0
				for i = 1, JY.Base["武功数量"] do
					if JY.Wugong[JY.Person[id]["武功" .. i]]["武功类型"] < 6 then
						zzr = zzr + 1
					end
				end
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + zzr
			end		
		  
		  
			--集气下限10点
			if WAR.Person[i].TimeAdd < 10 then
				WAR.Person[i].TimeAdd = 10
			end
		  
			--木桩不集气
			if id == 591 and WAR.ZDDH == 226 then
				WAR.Person[i].TimeAdd = 0
			end
			
			--李秋水的无相分身不集气
			if id == 600 then
				WAR.Person[i].TimeAdd = 0
			end
		  
			 
			--剑神，每个剑法到极，+2集气
			if JY.Base["标准"] == 3 and id == 0 then
				local jsyx = 0
				for i = 1, JY.Base["武功数量"] do
					if JY.Wugong[JY.Person[id]["武功" .. i]]["武功类型"] == 3 and JY.Person[id]["武功等级" .. i] == 999 then
						jsyx = jsyx + 1
					end
				end
				if jsyx > 7 then
					jsyx = 7
				end
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + jsyx*2
			end
		  
			--李文秀，每个奇门到极，+2集气
			if match_ID(id, 590) then
				local lwx = 0
				for i = 1, JY.Base["武功数量"] do
					if JY.Wugong[JY.Person[id]["武功" .. i]]["武功类型"] == 5 and JY.Person[id]["武功等级" .. i] == 999 then
						lwx = lwx + 1
					end
				end
				if lwx > 7 then
					lwx = 7
				end
				WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + lwx*2
			end

            if WAR.PD['降龙·飞龙在天'][id] == 1 then
                WAR.Person[i].TimeAdd = math.modf(WAR.Person[i].TimeAdd*1.5)
            end
            
			--集气上限80点
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
			
			
	        --独孤求败
          	if match_ID(id, 592) or JY.Person[id]["坐骑"] == 312 then
				dgqb = {i, WAR.Person[i].TimeAdd}
			end		  
			num = num + 1
			total = total + WAR.Person[i].TimeAdd
		end
	end
	     
  	--独孤求败集气锁定全场最高
	if dgqb[1] then
		if dgqb[2] < max_jq then
			total = total - WAR.Person[dgqb[1]].TimeAdd + max_jq + 1
			WAR.Person[dgqb[1]].TimeAdd = max_jq + 1
		end
	end
  
	--无酒不欢：这个返回值表达不明确，存疑
	WAR.LifeNum = num
	return math.modf(((total) / (num) + (num) - 2))
end


--武功范围选择
function War_KfMove(movefanwei, atkfanwei,wugong)
  local kind = movefanwei[1] or 0
  local len = movefanwei[2] or 0
  local x0 = WAR.Person[WAR.CurID]["坐标X"]
  local y0 = WAR.Person[WAR.CurID]["坐标Y"]
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
	Cat('实时特效动画')
	WarDrawMap(1, x, y)
	if wugong == 26 then
		WarDrawAtt(x, y, atkfanwei, 4, nil, nil, nil, 1)
	else
		WarDrawAtt(x, y, atkfanwei, 4)
	end
    
    --判断合击，判断是否有合击者

	local ZHEN_ID = -1;
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[WAR.CurID]["我方"] == WAR.Person[i]["我方"] and i ~= WAR.CurID and WAR.Person[i]["死亡"] == false then
			local nx = WAR.Person[i]["坐标X"]
			local ny = WAR.Person[i]["坐标Y"]
			local fid = WAR.Person[i]["人物编号"]
			for j = 1, JY.Base["武功数量"] do
				if JY.Person[fid]["武功" .. j] == wugong then         
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
							--合击人的战场编号
							ZHEN_ID = i
							
							--绘画合击的范围
							local tmp_id = WAR.CurID
							WAR.CurID = ZHEN_ID
							WarDrawAtt(WAR.Person[ZHEN_ID]["坐标X"] + x0 - x, WAR.Person[ZHEN_ID]["坐标Y"] + y0 - y, atkfanwei, 4)
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
	
	--合击人标识
	if ZHEN_ID ~= -1 then
		local nx = WAR.Person[ZHEN_ID]["坐标X"]
		local ny = WAR.Person[ZHEN_ID]["坐标Y"]
		local dx = nx - x0
		local dy = ny - y0
		local size = CC.FontSmall;
		local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
		local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
									
		local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)
									
		DrawString(rx - size*1.5, ry-hb-size/2, "合击者", M_DeepSkyBlue, size);
	end
	
	--显示可以覆盖的敌人信息
	for i = 0, CC.WarWidth - 1 do
		for j = 0, CC.WarHeight - 1 do
			local target = GetWarMap(i, j, 7)
			if target ~= nil and target == 2 then
				if GetWarMap(i, j, 2) ~= nil and WAR.Person[GetWarMap(i, j, 2)]["人物编号"] ~= nil then
					local x0 = WAR.Person[WAR.CurID]["坐标X"];
					local y0 = WAR.Person[WAR.CurID]["坐标Y"];
					local dx = i - x0
					local dy = j - y0
					local size = CC.FontSmall;
					local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
					local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
					
					local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)

					ry = ry - hb - CC.ScreenH/6;
							
					if ry < 1 then			--加上这个，防止看不到血的情况
						ry = 1;
					end
					
					--显示选中人物的生命值
					local color = RGB(245, 251, 5);
					local hp = JY.Person[WAR.Person[GetWarMap(i, j, 2)]["人物编号"]]["生命"] or 0;
					local maxhp = JY.Person[WAR.Person[GetWarMap(i, j, 2)]["人物编号"]]["生命最大值"] or 0;
					
					local ns = JY.Person[WAR.Person[GetWarMap(i, j, 2)]["人物编号"]]["受伤程度"] or 0;
					local zd = JY.Person[WAR.Person[GetWarMap(i, j, 2)]["人物编号"]]["中毒程度"] or 0;
					local len = #(string.format("%d/%d",hp,maxhp));
					rx = rx - len*size/4;
					
					--颜色根据所受的内伤确定
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
--xl为降龙的范围显示
function WarDrawAtt(x, y, fanwei, flag, cx, cy, atk, xl)
  local x0, y0 = nil
  if cx == nil or cy == nil then
    x0 = WAR.Person[WAR.CurID]["坐标X"]
    y0 = WAR.Person[WAR.CurID]["坐标Y"]
  else
    x0, y0 = cx, cy
  end
  local kind = fanwei[1]			--攻击范围
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
  
	--降龙的范围
	if xl then
		local xl_x = WAR.Person[WAR.CurID]["坐标X"]
		local xl_y = WAR.Person[WAR.CurID]["坐标Y"]
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
				if not inteam(WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["人物编号"]) and WAR.Person[WAR.CurID]["我方"] then
		      	local x0 = WAR.Person[WAR.CurID]["坐标X"];
		      	local y0 = WAR.Person[WAR.CurID]["坐标Y"];
		      	local dx = xy[i][1] - x0
		        local dy = xy[i][2] - y0
		        local size = CC.FontSmall;
		        local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
		        local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
		        
		        local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)

		        ry = ry - hb - CC.ScreenH/6;
						
		        if ry < 1 then			--加上这个，防止看不到血的情况
		        	ry = 1;
		        end
		      	
		      	--显示选中人物的生命值
		      	local color = RGB(245, 251, 5);
		      	local hp = JY.Person[WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["人物编号"]]["生命"];
		      	local maxhp = JY.Person[WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["人物编号"]]["生命最大值"];
		      	
		      	local ns = JY.Person[WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["人物编号"]]["受伤程度"];
		      	local zd = JY.Person[WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["人物编号"]]["中毒程度"];
		      	local len = #(string.format("%d/%d",hp,maxhp));
		      	rx = rx - len*size/4;
		      	
		      	--颜色根据所受的内伤确定
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
    local diwo = WAR.Person[WAR.CurID]["我方"]
    local atknum = 0
    for i = 1, num do
      if xy[i][1] >= 0 and xy[i][1] < CC.WarWidth and xy[i][2] >= 0 and xy[i][2] < CC.WarHeight then
        local id = GetWarMap(xy[i][1], xy[i][2], 2)
      
	      if id ~= -1 and id ~= WAR.CurID then
	        local xa, xb, xc = nil, nil, nil
			local e_diwo = WAR.Person[id]["我方"]
			--张家辉的隐身戒指
			if (JY.Person[WAR.Person[id]["人物编号"]]["防具"] == 304 and WAR.YSJZ == 0) then
				e_diwo = diwo
			end
			
	        if diwo ~= e_diwo then
				xa = 2
	        else
				xa = 0
	        end
			
			if WAR.HLZT[WAR.Person[id]["人物编号"]] ~= nil then
				if e_diwo == diwo and math.random(100) <= 40 then
					xa = 2
				end
				if e_diwo ~= diwo and math.random(100) <= 40 then 
					xa = 0
				end
			end
			
	        local hp = JY.Person[WAR.Person[id]["人物编号"]]["生命"]
	        if hp < atk / 6 then
	          xb = 2
	        elseif hp < atk / 3 then
	          xb = 1
	        else
	          xb = 0
	        end
	        local danger = JY.Person[WAR.Person[id]["人物编号"]]["内力最大值"]
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
	--武功选择范围
  elseif flag == 4 then
    for i = 1, num do
    	if xy[i][1] >= 0 and xy[i][1] < CC.WarWidth and xy[i][2] >= 0 and xy[i][2] < CC.WarHeight then
			if GetWarMap(xy[i][1], xy[i][2], 2) ~= nil and GetWarMap(xy[i][1], xy[i][2], 2) >= 0 then
				--七夕龙女的论剑奖励代表是否学有迷踪步
				--自动不触发
				if WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["人物编号"] == 0 and JY.Person[615]["论剑奖励"] == 1 and JLSD(0,100,0) and WAR.AutoFight == 0 and WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["我方"] then
					--用阿凡提的品德作为触发迷踪步的判定
					CC.TX["迷踪步"] = 1
				end
				if match_ID(WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["人物编号"], 498) and math.random(10) < 4 and WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["我方"] then
					--用李寻欢的品德作为触蜻蜓三抄水的判定
					JY.Person[498]["品德"] = 30
				end					
				--小昭影步
				if match_ID(WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["人物编号"], 66) and WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["我方"] then
					--用小昭的品德作为触发影步的判定
					JY.Person[66]["品德"] = 90
				end
				--畅想张无忌逆转乾坤
				--自动不触发
				if WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["人物编号"] == 0 and JY.Base["畅想"] == 9  and PersonKF(0, 97) and WAR.AutoFight == 0 and WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["我方"] then
					--基础35%几率
					local chance = 36
					--每本天书+1几率
					chance = chance + JY.Base["天书数量"]
					if WAR.LQZ[0] == 100 then
						chance = chance + 10
					end
					if JLSD(0,chance,WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["人物编号"]) then
						--JY.Person[614]["品德"] = 90
						CC.TX["逆转乾坤"] = 1
					end
				end
			
				--命中的敌方的点为2
				if not inteam(WAR.Person[GetWarMap(xy[i][1], xy[i][2], 2)]["人物编号"]) and WAR.Person[WAR.CurID]["我方"] then
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


--招亲郭靖
PNLBD[76] = function()
	JY.Person[683]["武功1"] = 26
	JY.Person[683]["武功等级1"] = 600
    JY.Person[683]["武功2"] = 15
	JY.Person[683]["武功等级2"] = 500
    JY.Person[683]["武功3"] = 107
	JY.Person[683]["武功等级3"] = 50
end

--神正杨过单金轮
PNLBD[275] = function()
	JY.Person[62]["武功3"] = 169
	JY.Person[62]["武功等级3"] = 999
	JY.Person[62]["天赋内功"] = 169
end

--boss 占位暴怒
function BOSSBF(id, x, y)
	local pid = WAR.Person[id]['人物编号']
	if r == 1 then
		return 
	end
	local s = WAR.CurID
	WAR.CurID =  id
	--1绿色，2红色，3蓝色，4紫色
	CleanWarMap(6,-1);
	    	
	local QMDJ = {"天","地","人","鬼"}
				
	--在自身周围绘制奇阵
	SetWarMap(x, y, 4, math.random(4));
	    		
	for j=1, 2 do
	    SetWarMap(x + math.random(4), y + math.random(4), 4, math.random(4));
				for n = 30, 100 do
					local i = n
					if i > 100 then
						i = 100
					end
					Cat('实时特效动画')
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
					Cat('实时特效动画')
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
					Cat('实时特效动画')
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
					Cat('实时特效动画')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
	end
	
	WAR.CurID =  s
end	
	
--黄蓉：奇门遁甲
function WarNewLand(id, x, y)
	if WAR.ZDDH == 226 then
		return 
	end
	local pid = WAR.Person[id]['人物编号']
	local r = JYMsgBox("奇门遁甲", "是否要开启奇门遁甲？", {"否","是"}, 2, JY.Person[pid]["半身像"])
	if r == 1 then
		return 
	end
	local s = WAR.CurID
	WAR.CurID =  id
	--1绿色，2红色，3蓝色，4紫色
	CleanWarMap(6,-1);
	    	
	local QMDJ = {"休","生","伤","杜","景","死","惊","开"}
				
	--在自身周围绘制奇阵
	SetWarMap(x, y, 6, math.random(4));
	    		
	for j=1, 2 do
	    SetWarMap(x + math.random(6), y + math.random(6), 6, math.random(4));
				for n = 30, 40 do
					local i = n
					if i > 40 then
						i = 40
					end
					Cat('实时特效动画')
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
					Cat('实时特效动画')
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
					Cat('实时特效动画')
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
					Cat('实时特效动画')
					Cls()
					NewDrawString(-1, -1, QMDJ[j], C_GOLD, CC.DefaultFont+i*2)
					ShowScreen()
					lib.Delay(CC.BattleDelay)	
				end
	end
	
	WAR.CurID =  s
end
		
--战斗主函数
function WarMain(warid, isexp)
	WarLoad(warid)			--初始化战斗数据
	WarSelectTeam_Enhance()	--选择我方（优化版）
	WarSelectEnemy()		--选择敌人
	
	Health_in_Battle()		--无酒不欢：血量翻倍
 
	if JY.Restart == 1 then
		return false
	end
	
	CleanMemory()
	--lib.PicInit()
	lib.ShowSlow(20, 1)
	WarLoadMap(WAR.Data["地图"])	--加载战斗地图
	
	--默认在当前场景战斗
	local BattleField = JY.SubScene
	if WAR.ZDDH == 354 then
        BattleField = 25
    end
	--倚天正线拿九阳战斗
	if WAR.ZDDH == 287 then
		BattleField = 116
	end

	for i = 0, CC.WarWidth-1 do
		for j = 0, CC.WarHeight-1 do
			lib.SetWarMap(i, j, 0, lib.GetS(BattleField, i, j, 0))
			lib.SetWarMap(i, j, 1, lib.GetS(BattleField, i, j, 1))
		end
	end
  
	--雪山落花流水战役
	if WAR.ZDDH == 42 then
		SetS(2, 24, 31, 1, 0)
		SetS(2, 30, 34, 1, 0)
		SetS(2, 27, 27, 1, 0)
	end
  
	--旧版华山论剑的擂台
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
	--天关修正地形
	if WAR.ZDDH == 348 or WAR.ZDDH == 349 or WAR.ZDDH == 350 then
		lib.SetWarMap(28, 6, 1, 1843*2)
        lib.SetWarMap(28, 5, 1, 1843*2)		
	end
 
	--20大高手，修正地形
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
	--20大高手，修正地形
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
	--战四大山，修正地形
	if WAR.ZDDH == 290 then
		for i = 5, 34 do
			lib.SetWarMap(7, i, 1, 0)
			lib.SetWarMap(9, i, 1, 0)
			lib.SetWarMap(54, i, 1, 0)
			lib.SetWarMap(56, i, 1, 0)
		end
	end
  
	--杀东方不败
	if WAR.ZDDH == 54 then
		lib.SetWarMap(11, 36, 1, 2)
	end
  
	--改变游戏状态
	JY.Status = GAME_WMAP
	  
	--加载贴图文件
	--lib.PicLoadFile(CC.WMAPPicFile[1], CC.WMAPPicFile[2], 0)						--战场贴图，内存区域0
	
	--lib.LoadPNGPath(CC.HeadPath, 1, CC.HeadNum, limitX(CC.ScreenW/936*100,0,100))	--人物大头像，内存区域1
	
	--lib.PicLoadFile(CC.ThingPicFile[1], CC.ThingPicFile[2], 2, 100, 100)			--物品贴图，内存区域2
	--lib.LoadPNGPath('./data/thing',0,-1,100)
	--lib.PicLoadFile(CC.EFTFile[1], CC.EFTFile[2], 3)								--特效贴图，内存区域3
	--lib.LoadPNGPath('./data/eft',0,-1,100)
	--lib.LoadPNGPath(CC.PTPath, 95, CC.PTNum, limitX(CC.ScreenW/936*100,0,100))
	
	--lib.LoadPNGPath(CC.UIPath, 96, CC.UINum, limitX(CC.ScreenW/936*100,0,100))
	
	--lib.LoadPNGPath(CC.IconPath, 98, CC.IconNum, limitX(CC.ScreenW/936*100,0,100))	--状态图标，内存区域98
	
	--lib.LoadPNGPath(CC.HeadPath, 99, CC.HeadNum, 26.923076923)						--人物小头像，用于集气条，内存区域99
   
   -- lib.LoadPNGPath(CC.BodyPath, 90, CC.BodyNum, limitX(CC.ScreenW/936*100,0,100))	--半身象
	--lib.LoadPNGPath(CC.XTPath, 91, CC.XTNum, limitX(CC.ScreenW/936*100,0,100))	--UI	
	--lib.PicLoadFile(CC.BJ[1], CC.BJ[2], 92) 
    --lib.LoadPNGPath('./data/bj',0,-1,100)	
	--无酒不欢：随机战斗音乐
	local zdyy = math.random(10) + 99
	
	--15大固定
	if WAR.ZDDH == 133 or WAR.ZDDH == 134 then
		zdyy = 27
	end
	
	--VS少林诸僧战固定
	if WAR.ZDDH == 80 then
		zdyy = 22
	end
	
	--葵花尊者战固定
	if WAR.ZDDH == 54  then
		zdyy = 112
	end

	--侠客邪固定
	if WAR.ZDDH == 170 then
		zdyy = 119
	end
	
	--蒙哥战固定
	if WAR.ZDDH == 278 then
		zdyy = 110
	end
	
	--武当战三丰固定
	if WAR.ZDDH == 22 then
		zdyy = 113
	end
	
	--20大高手战固定
	if WAR.ZDDH == 289 then
		zdyy = 115
	end
	
	--战四大山固定
	if WAR.ZDDH == 290 then
		zdyy = 117
	end
	
	--剑魔剑仙固定
	if WAR.ZDDH == 291 then
		zdyy = 118
	end
	
	PlayMIDI(zdyy)
	
	--PlayMIDI(WAR.Data["音乐"])  
	  
	local warStatus = nil		 --战斗状态
  
	WarPersonSort()			--按轻功排序
	CleanWarMap(2, -1)
	CleanWarMap(6, -2)
	  

	for i = 0, WAR.PersonNum - 1 do
		
		if i == 0 then
		  WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"] = WE_xy(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"])
		else
		  WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"] = WE_xy(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"], i)
		end
		
		SetWarMap(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"], 2, i)
		
		local pid = WAR.Person[i]["人物编号"]
		--lib.PicLoadFile(string.format(CC.FightPicFile[1], JY.Person[pid]["头像代号"]), string.format(CC.FightPicFile[2], JY.Person[pid]["头像代号"]), 4 + i)	--人物战斗动作贴图，内存区域4-29（一场战斗上限26人）
		
	end
	  
	--轻功对移动格子的计算
	--x为战场轻功，y为体力
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
		WAR.Person[i]["贴图"] = WarCalPersonPic(i)
	end
	WarSetPerson()
	WAR.CurID = 0
	WarDrawMap(0)
	lib.ShowSlow(20, 0)
	  
	--无酒不欢：设置人物的初始集气位置
	for i = 0, WAR.PersonNum - 1 do
		WAR.Person[i].Time = 800 - i * 1000 / WAR.PersonNum
        
			
        
		--岳灵珊 每个剑法+50点初始集气
		if match_ID(WAR.Person[i]["人物编号"], 79) then
			local JF = 0
			local bh = WAR.Person[i]["人物编号"]
			for i = 1, JY.Base["武功数量"] do
				if JY.Wugong[JY.Person[bh]["武功" .. i]]["武功类型"] == 3 then
					JF = JF + 1
				end
			end
			WAR.Person[i].Time = WAR.Person[i].Time + (JF) * 50
		end
		
		if WAR.Person[i].Time > 990 then
			WAR.Person[i].Time = 990
		end
		
		--令狐冲，一觉之后，初始满集气
		--闪电惊鸿
		if match_ID_awakened(WAR.Person[i]["人物编号"], 35, 1) or match_ID(WAR.Person[i]["人物编号"], 500) or match_ID(WAR.Person[i]["人物编号"], 9996) then
			WAR.Person[i].Time = 998
		end
		--独孤求败 风清扬
		if match_ID(WAR.Person[i]["人物编号"], 592) or  match_ID(WAR.Person[i]["人物编号"], 140) then
			WAR.Person[i].Time = 998
		end	

		--血刀老祖 初始集气900
		if match_ID(WAR.Person[i]["人物编号"], 97) then
			WAR.Person[i].Time = 900
		end
		--太监初始集气-200
		if JY.Person[WAR.Person[i]["人物编号"]]["性别"] == 2 then
			WAR.Person[i].Time = -200
		end
		
		--林平之 初始集气900
		if match_ID(WAR.Person[i]["人物编号"], 36) then
			WAR.Person[i].Time = 900
		end
		
		--木桩的初始集气
		if WAR.Person[i]["人物编号"] == 591 and WAR.ZDDH == 226 then
			WAR.Person[i].Time = 0
		end
		
		--圣火神功 初始集气加200和100随机
		local id = WAR.Person[i]["人物编号"]
		if PersonKF(id, 93) then
			WAR.Person[i].Time = WAR.Person[i].Time + 200 + math.random(100)
		end
		--一苇渡江
		if Curr_QG(id,186) then
		   WAR.Person[i].Time = WAR.Person[i].Time + 500
		end
		if WAR.Person[i].Time > 990 then
			WAR.Person[i].Time = 990
		end
		if JY.Person[id]["坐骑"] == 312 then
			WAR.Person[i].Time = 998
		end
		-- 绣花针
	    if JY.Person[id]["武器"] == 349  then
            WAR.Person[i].Time = 900
		end			
		--论剑打赢阿凡提奖励，绝对先手，且全场敌方位置-500
		if WAR.Person[i]["人物编号"] == 0 and JY.Person[606]["论剑奖励"] == 1 then
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["我方"] then
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
             WAR.Person[i]['护盾'] = 1
		end		
		if match_ID(id,577) then
             WAR.Person[i]['护盾'] = 2
		end	


	end
  
	--携带物品的初始化
	for a = 0, WAR.PersonNum - 1 do
		for s = 1, 4 do
			if JY.Person[WAR.Person[a]["人物编号"]]["携带物品数量" .. s] == nil or JY.Person[WAR.Person[a]["人物编号"]]["携带物品数量" .. s] < 1 then
				JY.Person[WAR.Person[a]["人物编号"]]["携带物品" .. s] = -1
				JY.Person[WAR.Person[a]["人物编号"]]["携带物品数量" .. s] = 0;
			end
		end
	end
	
	--笑傲邪线，黑木崖如果单挑东方不败，则东方会以葵花尊者形态出战
	if WAR.ZDDH == 54 and WAR.MCRS == 1 then
		local dfid;
		for i = 0, WAR.PersonNum - 1 do
			local id = WAR.Person[i]["人物编号"]
			if id == 27 then
				dfid = i;
				break
			end
		end
		local orid = WAR.CurID
		WAR.CurID = dfid
		
		Cls()
		local KHZZ = {"面对本座","对方竟敢单独出战","伤自尊啊"}
		
		for n = 1, #KHZZ + 25 do
			local i = n 
			if i > #KHZZ then 
				i = #KHZZ
			end
			lib.GetKey()
			Cat('实时特效动画')
			Cls()
			DrawString(-1, -1, KHZZ[i], C_GOLD, CC.Fontsmall)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
		Cls()
		CurIDTXDH(WAR.CurID, 7, 1)
		
		for n = 1,50 do
			Cat('实时特效动画')
			Cls()
			lib.Background(0,200,CC.ScreenW,400,78)
			NewDrawString(CC.ScreenW, CC.ScreenH/2 + 160, "葵花诀尊者形态", C_GOLD, 80)
			NewDrawString(CC.ScreenW, CC.ScreenH/2 + 360, "看吧 东方在赤红的燃烧", C_RED, 70)
			
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
		Cls()
		local KHZZ2 = {"不知死活的"..JY.Person[0]["外号2"],"好好体验一下死亡的恐怖吧"}

		for n = 1, #KHZZ2 + 25 do
			local i = n 
			if i > #KHZZ2 then 
				i = #KHZZ2
			end
			lib.GetKey()
			Cat('实时特效动画')
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
			Cat('实时特效动画')
			Cls()
			lib.Background(0,200,CC.ScreenW,400,78)
			NewDrawString(CC.ScreenW, CC.ScreenH/2 + 160, "四神之阵", C_GOLD, j)
			NewDrawString(CC.ScreenW, CC.ScreenH/2 + 360, "风林火山", C_RED, k)
			
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
		Cat('天关阵')
		--local 
		--WAR.PD['天关阵4'] = {5,27,50,114}
	end
	--圣火三使战开局的文字特效
	if WAR.ZDDH == 14 then
		say("Ｇ１妙风使！", 173, 0)   --妙风使
		say("Ｇ１流云使！", 174, 1)   --流云使
		say("Ｇ１辉月使！Ｈ圣火三绝阵！", 175, 5)   --辉月使！Ｈ圣火三绝阵！

        
		for n = 15,50 do
            local i = n 
            if i > 35 then 
                i = 35   
            end
            lib.GetKey()
			Cat('实时特效动画')
			Cls()
			lib.GetKey()
			NewDrawString(-1, -1, "圣火三绝阵", C_GOLD, CC.DefaultFont+i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end

	--侠客正太玄战李白对话
	if WAR.ZDDH == 302 then
		say("Ｄ２蓬莱文章建安骨，中间小谢又清发。", 636, 0)
		say("Ｄ２俱怀逸兴壮思飞，欲上青天览明月。", 0, 1)
		say("Ｄ２抽刀断水水更流，举杯消愁愁更愁。", 636, 0)
		say("Ｄ２人生在世不称意，明朝散发弄扁舟。", 0, 1)
	end
  
	--密道成昆战，我方集气全体为0
	if WAR.ZDDH == 237 then
		for a = 0, WAR.PersonNum - 1 do
			if WAR.Person[a]["我方"] == true then
				WAR.Person[a].Time = 0
			end
		end
	end

	--全真七子，天罡北斗阵
	if WAR.ZDDH == 73 then

        
		for n = 15,50 do
            local i = n 
            if i > 35 then 
                i = 35   
            end
            lib.GetKey()
			Cat('实时特效动画')
			Cls()
			lib.GetKey()
			NewDrawString(-1, -1, "天罡北斗阵", C_GOLD, CC.DefaultFont+i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end

			
		--梁萧 谐之道·归藏
	if WAR.ZDDH > 0 and JY.Base["畅想"] == 635 and JY.Person[0]["六如觉醒"] > 0 then

		for n = 15,50 do
            local i = n 
            if i > 35 then 
                i = 35   
            end
            lib.GetKey()
			Cat('实时特效动画')
			Cls()
			lib.GetKey()
			NewDrawString(-1, -1, "谐之道·归藏", C_GOLD, CC.DefaultFont+i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end
		--陆渐 海之道·海纳百川
	if WAR.ZDDH > 0 and JY.Base["畅想"] == 497 and JY.Person[0]["六如觉醒"] > 0   then
        
		for n = 15,50 do
            local i = n 
            if i > 35 then 
                i = 35   
            end
            lib.GetKey()
			Cat('实时特效动画')
			Cls()
			lib.GetKey()
			NewDrawString(-1, -1, "海之道·海纳百川", C_GOLD, CC.DefaultFont+i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end	
		--王重阳1 天罡北斗阵
	if WAR.ZDDH > 0 and JY.Base["畅想"] == 129   then

		for n = 15,50 do
            local i = n 
            if i > 35 then 
                i = 35   
            end
            lib.GetKey()
			Cat('实时特效动画')
			Cls()
			lib.GetKey()
			NewDrawString(-1, -1, "天罡北斗阵", C_GOLD, CC.DefaultFont+i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end		
		--丐帮打狗阵
	if WAR.ZDDH ==  344  then

		for n = 15,50 do
            local i = n 
            if i > 35 then 
                i = 35   
            end
            lib.GetKey()
			Cat('实时特效动画')
			Cls()
			lib.GetKey()
			NewDrawString(-1, -1, "真.打狗阵", C_GOLD, CC.DefaultFont+i*2)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end	
	--组合动画显示
	if CC.CoupleDisplay == 1 then
		local function fightcombo()
			local combo = {}
			for i = 1, #CC.COMBO do
				combo[i] = {CC.COMBO[i][1], CC.COMBO[i][2], CC.COMBO[i][3],0}
			end
			for i = 0, WAR.PersonNum - 1 do
				local t = WAR.Person[i]["人物编号"]
				for j = 1, #combo do
					lib.GetKey()
					if match_ID(t, combo[j][1]) then
						for z = 0, WAR.PersonNum - 1 do
							local t2 = WAR.Person[z]["人物编号"]
							if match_ID(t2, combo[j][2]) and WAR.Person[i]["我方"] == WAR.Person[z]["我方"] then
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
						local str = JY.Person[t1]["姓名"].."＆"..JY.Person[t2]["姓名"]
						local str2 = combo[i][3]
                        Cat('实时特效动画')
						Cls()
						DrawBox(150, CC.ScreenH / 3 + 30, CC.ScreenW - 150, CC.ScreenH / 3 * 2 - 20, C_BLACK)
						lib.LoadPNG(1, JY.Person[t1]["半身像"]*2, CC.ScreenW / 4 - 80, CC.ScreenH / 2 - 35, 1)
						lib.LoadPNG(1, JY.Person[t2]["半身像"]*2, CC.ScreenW / 4 + 50, CC.ScreenH / 2 - 35, 1)
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
	--Pre_Yungong()	--无酒不欢：战前运功
	
	--黄蓉奇门遁甲，我方才触发
	for j = 0, WAR.PersonNum - 1 do
		if match_ID(WAR.Person[j]["人物编号"], 56) and WAR.Person[j]["我方"] == true then
			WarNewLand(j, WAR.Person[j]["坐标X"], WAR.Person[j]["坐标Y"])
			break
		end
	end
	
	WAR.Delay = GetJiqi()
	local startt, endt = lib.GetTime()
  
 
  --战斗主循环
  while true do
	if JY.Restart == 1 then
		return false
	end
	
    
    WAR.ShowHead = 0
	WAR.CurID = DrawTimeBar()
    if WAR.ZYHB == 1 then
		WAR.ZYHB = 2
    end	
    Cat('人物移动步数')
    WarDrawMap(0)
    lib.GetKey()
    ShowScreen()
    local p = WAR.CurID
    local id = WAR.Person[p]["人物编号"]
    --for p = 0, WAR.PersonNum - 1 do
	--	lib.GetKey()

	if WAR.Person[p]["死亡"] == false and JY.Person[id]['生命'] > 0 then
      	WAR.Person[p].Time = 1000
	    Cat('实时特效动画')
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
        local pid = WAR.Person[WAR.CurID]["人物编号"]
        WAR.Defup[pid] = nil
		--悲酥清风
		
		--逍遥御风，行动前恢复
		--左右第二下不会清0
		if WAR.XYYF[pid] and WAR.XYYF[pid] == 11 and WAR.ZYHB ~= 2 then
			WAR.XYYF[pid] = nil
		end
		
		--段誉的指令，行动前恢复
        if match_ID(pid, 53) then
			WAR.TZ_DY = 0
        end
		
		--慕容复的指令，行动前恢复
        if match_ID(pid, 51) then
			WAR.TZ_MRF = 0
        end
		
		--阿青，行动前内伤中毒清0
	    if match_ID(pid, 604) then
			Cat('清除所有异常',WAR.CurID)
	    end
		
		--阿九，行动开始前，60%几率降低敌方集气-150点
		if match_ID(pid, 629) and JLSD(20,80,pid) then
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
					WAR.Person[j].TimeAdd = WAR.Person[j].TimeAdd - 150
				end
			end
			DrawTimeBar2()
		end
		--决胜千里 
		if match_ID(pid, 9968) and JLSD(20,80,pid) then
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
					WAR.Person[j].TimeAdd = WAR.Person[j].TimeAdd - 150
				end
			end
			DrawTimeBar2()
		end
        --丘处机通用计时状态已方
		if match_ID(pid,68) and WAR.JSZT1[pid] == nil then
				WAR.JSZT1[pid] = 3
		     end
		 
		--先天调息，60%几率休息
		if Curr_NG(pid, 100) and JLSD(0,60,pid) then
			WarDrawMap(0); --不加这条则动画位置无法正常显示
			CurIDTXDH(WAR.CurID, 19,1,"先天调息",C_ORANGE);
			--WAR.XTTX = 1
			War_RestMenu()
			--WAR.XTTX = 0
		end
		--天仙锁魂
		 if match_ID(pid,574) then
              local txsh = math.random(5)	 
		         for j = 0, WAR.PersonNum - 1 do
				     if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then 
                        if  WAR.XRZT1[WAR.Person[j]["人物编号"]] == nil and JLSD(0,60,pid) then     
	                        WAR.XRZT1[WAR.Person[j]["人物编号"]] = 2
	                   end
                   end
               end
         end
		--万佛朝宗
		if match_ID(pid,577) then 
			WAR.WFCZ[pid] = (WAR.WFCZ[pid] or 0) + 1
			if WAR.WFCZ[pid] > 5 then
				WAR.WFCZ[pid] = 5
			end
		end

			--霸体时序
		if WAR.BTZT[id] ~= nil then
			WAR.BTZT[id] = WAR.BTZT[id] - 1
			if WAR.BTZT[id] < 1 then
				WAR.BTZT[id] = nil
			end
		end
        if Curr_NG(pid,100) and WAR.PD["先天护盾CD"][pid] == nil then
			WAR.PD["先天护盾"][pid] = 500
			WarDrawMap(0); --不加这条则动画位置无法正常显示
			CurIDTXDH(WAR.CurID, 80,1,"先天罡气护体",C_ORANGE);
			WAR.Person[WAR.CurID]['护盾'] = 3
			WAR.PD["先天护盾CD"][pid] = 100
		end
		--九阳抱元守一
		if Curr_NG(pid,106)  and (JY.Person[pid]["内力性质"] == 1 or JY.Person[pid]["内力性质"] == 3)then 
			Cat('清除所有异常',WAR.CurID)
			WarDrawMap(0); --不加这条则动画位置无法正常显示
			CurIDTXDH(WAR.CurID, 78,1,"九阳.抱元守一",C_ORANGE);
			WAR.JHZT = 1
		end
		
		--净化状态
		if WAR.JHZT==1 then				
			JY.Person[pid]["中毒程度"] = 0
			JY.Person[pid]["受伤程度"] = 0
			JY.Person[pid]["冰封程度"] = 0
			JY.Person[pid]["灼烧程度"] = 0
			--流血
			if WAR.LXZT[pid] ~= nil then
				WAR.LXZT[pid] = nil
			end
		end	
		
	    WAR.JHZT=0 

		--龙象般若功，自动蓄力
		if Curr_NG(pid, 103) then
			WarDrawMap(0); --不加这条则动画位置无法正常显示
			War_ActupMenu()
		end	

		--徐子陵
		if match_ID(pid,9979) and WAR.ZYHB ~= 2 then
			Bagua(pid)
		end

		--战三渡时，超过100时序，周芷若领悟左右
		if WAR.ZDDH == 253 and match_ID(pid, 631) and WAR.ZZRZY == 0 and 100 < WAR.SXTJ then
			say("１Ｌ＜这三人心意相通，如攻其一人，则其余两人立即回护，这样如何能够破阵？ｗ……若能分心二用，同时攻击两方，且他们如何应对＞Ｗ", 357, 0,"周芷若")  --对话
			if JY.Base["畅想"] == 631 then
				JY.Person[0]["左右互搏"] = 1
			else
				JY.Person[631]["左右互搏"] = 1
			end
			WAR.ZZRZY = 1
		end

		--行动时显示血条
		WAR.ShowHP = 1
        
		WAR.PD['降龙·飞龙在天'][pid] = nil
        
        
		--无酒不欢：行动时，获取指令
		if WAR.HMZT[pid] ~= nil then			--昏迷状态
			WarDrawMap(0); --不加这条则动画位置无法正常显示
			CurIDTXDH(WAR.CurID, 94,1,"昏迷中",C_ORANGE)			
        elseif WAR.ZDDH == 354 then
            r = War_Auto()
        elseif inteam(pid) and WAR.Person[p]["我方"] then
			--混乱状态50%概率自动
			if WAR.HLZT[pid] ~= nil and math.random(100) <= 50 then
				r = War_Auto()
			elseif WAR.AutoFight == 0 then
				r = War_Manual()
			elseif JY.Person[pid]["禁用自动"] == 1 then
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
        
		
        --如果发动左右互搏
        if WAR.ZYHB == 1 then
            WAR.ATK['人物'] = p    
			WAR.Person[p].Time = 1000
			if WAR.ZHB == 0 then	--周伯通的额外左右这里不再重复记录
				WAR.ZYYD = WAR.Person[p]["移动步数"]
			end

			--阎基偷钱
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
		--步惊云 剑23	
	        if WAR.SL23  == 1 and match_ID(pid, 584) then
		   WAR.SL23 = 0
		   end   
	 	        
          --天域幻音
			if ZDGH(WAR.CurID,9998) then	
			    JY.Person[id]["中毒程度"] = 0
			    JY.Person[id]["受伤程度"] = 0
			    JY.Person[id]["灼烧程度"] = 0
			    JY.Person[id]["冰封程度"] = 0					
			    if WAR.LXZT[id] ~= nil then
					WAR.LXZT[id] = nil
			    end
				local heal_amount1;
				local heal_amount;
				heal_amount1 = (JY.Person[id]["生命最大值"] - JY.Person[id]["生命"])
				heal_amount = limitX(math.modf(heal_amount1 * 0.05),100,200)
					if heal_amount < 100 then
					heal_amount = 100
					end
					if  JY.Base["天书数量"] > 6 or not inteam(id) then
						heal_amount = math.modf(heal_amount1 * 0.1)
                    end
					WAR.Person[WAR.CurID]["生命点数"] = AddPersonAttrib(id, "生命", heal_amount);
					Cls();
					War_Show_Count(WAR.CurID, "");
		  end

		   --罗汉伏魔功 每回合回复生命
			if PersonKF(id, 96) and JY.Person[id]["生命"] > 0 then
				local heal_amount;
				heal_amount = limitX(JY.Person[id]["生命最大值"] - JY.Person[id]["生命"],1000,2000)
				if Curr_NG(id, 96) then
					heal_amount = math.modf(heal_amount * 0.1)
				else
					heal_amount = math.modf(heal_amount * 0.05)
				end
				WAR.Person[WAR.CurID]["生命点数"] = AddPersonAttrib(id, "生命", heal_amount);
				Cls();
				War_Show_Count(WAR.CurID, "罗汉伏魔功恢复生命");
			end
			--枯荣禅功每回合概率以内力换生命
			if PersonKF(id,207) and JY.Person[id]["生命"] > 0 and JY.Person[id]["内力"] > 0 and JY.Person[id]["生命"] < JY.Person[id]["生命最大值"] then
			local krnl = limitX(math.modf(JY.Person[id]["内力"]/50),100,200)
			 CurIDTXDH(WAR.CurID, 77,1,"亦枯亦荣",C_ORANGE);
			WAR.Person[WAR.CurID]["生命点数"] = AddPersonAttrib(id, "生命", krnl);
			Cls();
			WAR.Person[WAR.CurID]["内力点数"] = AddPersonAttrib(id, "内力", -krnl);
			Cls();
			War_Show_Count(WAR.CurID, "");
			end  
	        
	        --紫霞神功行动后，回复内力
			if PersonKF(id, 89) then
				local HN;
				if Curr_NG(id, 89) then
					HN = math.modf((JY.Person[id]["内力最大值"] - JY.Person[id]["内力"])*0.2)
				else
					HN = math.modf((JY.Person[id]["内力最大值"] - JY.Person[id]["内力"])*0.1)
				end
				WAR.Person[WAR.CurID]["内力点数"] = AddPersonAttrib(id, "内力", HN);
				Cls();
				War_Show_Count(WAR.CurID, "紫霞神功回复内力");
			end
         --梅长苏行动后冰封值+10 灼烧值+5
			if match_ID(id,507) then
				local bfz = 0
				local zsz = 0
				bfz = bfz + 10
				zsz =  zsz + 5
				--WAR.ZSXS[id] = 1
				--WAR.BFXS[id] = 1
				AddPersonAttrib(id,'灼烧程度',zsz)
				AddPersonAttrib(id,'灼烧程度',bfz)
				WAR.ZSXS[id] = zsz
				WAR.BFXS[id] = bfz
			end     
	        --混元功行动后，减少内伤
			--萧半和
			if PersonKF(id, 90) or (id == 0 and JY.Base["畅想"] == 189) then
				local NS;
				NS = 5 + math.modf(JY.Person[id]["受伤程度"]/10)
				WAR.Person[WAR.CurID]["内伤点数"] = (WAR.Person[WAR.CurID]["内伤点数"] or 0) + AddPersonAttrib(id, "受伤程度", -NS)
				Cls();
				War_Show_Count(WAR.CurID, "混元功回复内伤");
			end

	        --鳄皮护甲 每回合解毒
			if JY.Person[id]["防具"] == 61 and JY.Person[id]["中毒程度"] > 0 then
				local JD = 25 + 10 * (JY.Thing[61]["装备等级"]-1)
				if JY.Person[id]["中毒程度"] < JD then
					JD = JY.Person[id]["中毒程度"]
				end
				WAR.Person[WAR.CurID]["解毒点数"] = -AddPersonAttrib(id, "中毒程度", -JD)
				Cls();
				War_Show_Count(WAR.CurID, "鳄皮护甲生化解毒");
			end
			
			--无酒不欢：等待
			if WAR.Wait[id] == 1 then
				WAR.Wait[id] = 0
				WAR.Person[p].Time = WAR.Person[p].Time + 400
			end
			
			--蛤蟆蓄力
			if WAR.HMGXL[id] == 1 then
				WAR.HMGXL[id] = 0
				WAR.Person[p].Time = WAR.Person[p].Time + 300
			end
		
			--林平之根据伤害回气
			if match_ID_awakened(id, 36, 1) and WAR.LPZ > 0 then
				WAR.Person[p].Time = WAR.Person[p].Time + WAR.LPZ
				WAR.LPZ = 0
			end
 

			--虚竹福泽加护
	        if match_ID(id, 49) and WAR.XZZ == 1 then
				WAR.XZZ = 0
				WAR.Person[p].Time = WAR.Person[p].Time + 200
	        end
	        
			--张三丰万法自然 
	        if match_ID(id, 5)  and WAR.ZSF == 1 then
				WAR.Person[p].Time = WAR.Person[p].Time + 500
				WAR.ZSF = 0
	        end		
 
            --if WAR.PD['西瓜刀'][pid] == 1 then
            if WAR.PD['回气'][id] ~= nil then 
                WAR.Person[p].Time = WAR.Person[p].Time + WAR.PD['回气'][id] 
                WAR.PD['回气'][id] = nil
            end
               -- WAR.PD['西瓜刀'][pid] = nil
           -- end
            
			--李白诗酒化行 
	        if match_ID(id, 636) and WAR.QLBLX == 1 then
				WAR.Person[p].Time = WAR.Person[p].Time + 200
				WAR.QLBLX = 0
	        end
			
			--封不平狂风快剑
			if match_ID(id, 142) and WAR.KFKJ == 1 then
				WAR.Person[p].Time = WAR.Person[p].Time + 150
				WAR.KFKJ = 0
			end
			
			--九剑真传，荡剑式，回气200
			if WAR.JJDJ == 1 and id == 0 then
				WAR.JJDJ = 0
				WAR.Person[p].Time = WAR.Person[p].Time + 200
			end 
		
			--主运飞天回气200 胡一刀
			if Curr_QG(id,145) or match_ID(id,633) then
				WAR.Person[p].Time = WAR.Person[p].Time + 200
			end
			--闪 电惊鸿
			if match_ID(id,9996) then
				WAR.Person[p].Time = WAR.Person[p].Time + 200
			end
			--运轻功
			if WAR.YQG == 1 then
				WAR.Person[p].Time = WAR.Person[p].Time + 500
				WAR.YQG = 0
			end
	        
	        --朱九真，随机得到食材
	        if match_ID(id, 81) and WAR.ZJZ == 0 and JLSD(0,40,id) then
				instruct_2(210, 10)
				WAR.ZJZ = 1
	        end
	        

	        --杨过，行动后集气初始位置额外增加
	        --生命少过二分之一时每少100增加行动后集气位置加100
	        if match_ID(id, 58) and JY.Person[id]["生命"] < JY.Person[id]["生命最大值"]/2 then
	        	WAR.Person[p].Time = WAR.Person[p].Time + math.floor(JY.Person[id]["生命最大值"]/2 - JY.Person[id]["生命"]);
	        end
	          
			if WAR.PD['疾如风'][id] ~= nil and WAR.PD['疾如风'][id] > 0 then 
				local rf = WAR.PD['疾如风'][id]
				WAR.Person[p].Time = WAR.Person[p].Time + rf*300
			    if WAR.Person[p].Time > 980 then
					WAR.Person[p].Time = 980
			    end				
				WAR.PD['疾如风'][id] = nil
			end
			
			--阎基偷钱
	        if WAR.YJ > 0 then
				instruct_2(174, WAR.YJ)
				WAR.YJ = 0
	        end
	        

				--王重阳1 同归剑气 30时序
			if WAR.TGJF[id] ~= nil then
				WAR.TGJF[id] = nil
			end	
				
			--宋远桥使用太极拳或太极剑攻击后自动进入防御状态
			if match_ID(id, 171)  and WAR.WDRX == 1  then
				War_DefupMenu()
				WAR.WDRX = 0
			end
			
			--太极神功自动防御
	        if PersonKF(id,171) and WAR.Defup[id] == nil then
				WarDrawMap(0); --不加这条则动画位置无法正常显示
				War_DefupMenu()
			end
			
            if WAR.PD['降龙·潜龙勿用'][id] == 1 then 
                War_DefupMenu()
                WAR.PD['降龙·潜龙勿用'][id] = nil
            end
            
            if WAR.PD['西瓜刀·天人'][id] ~= nil then 
                WAR.PD['西瓜刀·天人'][id] = WAR.PD['西瓜刀·天人'][id] - 1 
                if WAR.PD['西瓜刀·天人'][id] < 1 then 
                    WAR.PD['西瓜刀·天人'][id] = nil   
                end
            end
            
	        if WAR.Actup[id] ~= nil then
				if WAR.ZXXS[id] ~= nil then				--紫霞蓄势状态，蓄力不减
					WAR.ZXXS[id] = WAR.ZXXS[id] - 1
					if WAR.ZXXS[id] == 0 then
						WAR.ZXXS[id] = nil
					end
				else
					WAR.Actup[id] = WAR.Actup[id] - 1	--蓄力，行动一次减1
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
			
				--[[魅惑状态，解除后，敌人状态恢复
				if WAR.MHZT[id] ~= nil then
					WAR.MHZT[id] = WAR.MHZT[id] - 1
					if WAR.MHZT[id] < 1 then
						WAR.MHZT[id] = nil
						if not inteam(id) then
                            WAR.Person[p]["我方"] = false
                        end
                    end
                end	]]
                
			if WAR.MRSHZT[id]~= nil then
			   WAR.MRSHZT[id]= WAR.MRSHZT[id] - 1
			    if WAR.MRSHZT[id]  == 0 then
				 WAR.MRSHZT[id] = nil
			end   
		end	
			--集中状态
			if WAR.Focus[id] ~= nil then
				WAR.Focus[id] = nil
			end

			--混乱状态，解除后，敌人状态恢复
			if WAR.HLZT[id] ~= nil then
				WAR.HLZT[id] = WAR.HLZT[id] - 1
				if WAR.HLZT[id] < 1 then
					WAR.HLZT[id] = nil
				end
			end
                
			--锁足状态
			if WAR.SZZT[id] ~= nil then
				WAR.SZZT[id] = nil
			end	
           if WAR.PD["洞火"][id] ~= nil then
              WAR.PD["洞火"][id] = nil
		   end	
	        --迟缓状态	        --盲目状态恢复
		
	        if WAR.KHCM[pid] ==2 then
				WAR.KHCM[pid] =WAR.KHCM[pid] - 1
				if WAR.KHCM[pid] == 0 then
					WAR.KHCM[pid] = nil 
				end
                for k = 0,10 do
                    Cat('实时特效动画')
                    Cls()
                    DrawStrBox(-1, -1, "盲目状态恢复", C_ORANGE, CC.DefaultFont)
                    ShowScreen();
                    lib.Delay(CC.BattleDelay)
                end
	        end
			--昏迷
			if WAR.HMZT[pid] ~= nil then
				WAR.HMZT[pid] = nil
			end
            --迟缓
		   if WAR.CHZT[pid]~=nil  then
			    WAR.CHZT[pid] = WAR.CHZT[pid] - 1
				if WAR.CHZT[pid] == 0 then
					WAR.CHZT[pid] = nil
				end
			end	
			--虚弱状态1
			if WAR.XRZT1 [pid]~=nil  then
			    WAR.XRZT1[pid] = WAR.XRZT1[pid] - 1
				if WAR.XRZT1[pid] == 0 then
					WAR.XRZT1[pid] = nil
				end
			end	
			--放下屠刀
			if WAR.PD["放下屠刀"][pid]~=nil  then
			    WAR.PD["放下屠刀"][pid] = WAR.PD["放下屠刀"][pid] - 1
				if WAR.PD["放下屠刀"][pid] == 0 then
					WAR.PD["放下屠刀"][pid] = nil
				end
			end		
		    if WAR.HQT_CD > 0  then
			    WAR.HQT_CD = WAR.HQT_CD - 1
			end				
			--行动后漏出破绽
			WAR.Weakspot[id] = 0
			--不老长春功无破绽
			if PersonKF(id,183) then
			WAR.Weakspot[id] = nil
			end
			--双剑合壁无破绽
			if ShuangJianHB(id)  then
			WAR.Weakspot[id] = nil
			end
			--瑜伽无破绽
			if PersonKF(id,169)  then
			WAR.Weakspot[id] = nil
			end
			--辟邪冷却时间恢复
			if WAR.BXLQ[id]  then
				for i = 1, 6 do
					WAR.BXLQ[id][i] = WAR.BXLQ[id][i] - 1
					if WAR.BXLQ[id][i] < 0 then
						WAR.BXLQ[id][i] = 0
					end
				end
			end
			--九阳冷却时间恢复
			if WAR.JYLQ[id]  then
				for i = 1, 3 do
					WAR.JYLQ[id][i] = WAR.JYLQ[id][i] - 1
					if WAR.JYLQ[id][i] < 0 then
						WAR.JYLQ[id][i] = 0
					end
				end
			end			
			--碧海冷却时间恢复
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
			--乔峰的铁掌名字恢复
	        JY.Wugong[13]["名称"] = "铁掌"
	        
	        --周伯通，每行动一次，攻击时伤害一+10%
	        if match_ID(id, 64) then
				WAR.ZBT = WAR.ZBT + 1
	        end
			if match_ID(id,9984) then
				if WAR.PD["诸法无我"][id] == nil then
                   WAR.PD["诸法无我"][id] = 1
				else
                   WAR.PD["诸法无我"][id] = WAR.PD["诸法无我"][id] +1
				end
				if WAR.PD["诸法无我"][id] > 6 then
					WAR.PD["诸法无我"][id] = 6
				end
			end

			
			--王重阳北斗七闪状态减少
			if match_ID(id, 129) and WAR.BDQS > 0 then
				WAR.BDQS = WAR.BDQS - 1
				if WAR.BDQS == 0 then
					CurIDTXDH(WAR.CurID, 126,1,"北斗七闪·收招",C_GOLD);
				end
			end
			
			--暴怒恢复
	        if WAR.LQZ[id] == 100 then
				--王重阳北斗七闪状态行动后暴怒不减
				if not (match_ID(id, 129) and WAR.BDQS > 0) then
					if  match_ID(id,639) then
	                 WAR.LQZ[id] = math.modf(60,90)
				else
					WAR.LQZ[id] = 0			  
				end
	        end
		end	
				
			--北冥神功给自己加怒气
	        if WAR.BMSGXL > 0 and id == 0 then
	           WAR.LQZ[id] =(WAR.LQZ[id] or 0)+WAR.BMSGXL
	           if WAR.LQZ[id] > 100 then
	              WAR.LQZ[id] = 100
	              WAR.BMSGXL = 0
                  if WAR.LQZ[id] ~= nil and WAR.LQZ[id] == 100 then
	                 CurIDTXDH(WAR.CurID, 6, 1, "怒气爆发")
				  end
			   end		
            end
            
			--刀主大招，行动后恢复怒气
			if id == 0 and JY.Base["标准"] == 4 and WAR.YZHYZ > 0 then
				WAR.LQZ[id] = limitX((WAR.LQZ[id] or 0) + WAR.YZHYZ, 0, 100)
				WAR.YZHYZ = 0
				if WAR.LQZ[id] ~= nil and WAR.LQZ[id] == 100 then
					CurIDTXDH(WAR.CurID, 6, 1, "怒气爆发")
				end
			end

	        --杨过 吼  龙儿~~
	        if WAR.XK == 1 then
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["人物编号"] == 58 and 0 < JY.Person[WAR.Person[j]["人物编号"]]["生命"] and WAR.Person[j]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
						WAR.Person[j].Time = 980
						say("１Ｒ龙儿－－－－－－！Ｈ５啊－－－－４－－－－３－－－－２－－－－１－－－－－－－－！！！", 58,0)
						WAR.XK = 2
					end
				end
	        end
	     	--[[   
	        --发动 难知如阴
	        if WAR.FLHS5 == 1 and WAR.ZYZD == 0 then
				local z = WAR.CurID
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["人物编号"] == 0 and 0 < JY.Person[0]["生命"] then
						WAR.FLHS5 = 2
						WAR.CurID = j
					end
				end
				if WAR.FLHS5 == 2 and WAR.AutoFight == 0 then
					WAR.Person[WAR.CurID]["移动步数"] = 6
					War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["移动步数"], 0)
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
	        --[[发动 中庸之道
	if WAR.ZYZD == 1 then
		local z = WAR.CurID
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["人物编号"] == 0 and 0 < JY.Person[0]["生命"] then
				WAR.ZYZD = 2
				WAR.CurID = j
                break
			end
		end
		if WAR.ZYZD == 2  then
				  	 
			WAR.Person[WAR.CurID]["移动步数"] = 6
			War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["移动步数"], 0)
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

      
	   				
	        --圣火神功 攻击后可移动
	        if (0 < WAR.Person[p]["移动步数"] or 0 < WAR.ZYYD) and WAR.Person[p]["我方"] == true and inteam(id) and WAR.AutoFight == 0 and PersonKF(id, 93) and 0 < JY.Person[id]["生命"] then
				if 0 < WAR.ZYYD then
					WAR.Person[p]["移动步数"] = WAR.ZYYD
					War_CalMoveStep(p, WAR.ZYYD, 0)
				else
					War_CalMoveStep(p, WAR.Person[p]["移动步数"], 0)
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
			
			--无酒不欢：无论是否触发了圣火再移动，这个变量都应该在这一步清除，否则会影响到下一个人的圣火判定
			--触发周伯通左右补偿不清除
			if WAR.ZHB == 0 then
				WAR.ZYYD = 0
			end
			
			--周伯通的追加互搏判定
			if WAR.ZHB == 1 then
				WAR.ZHB = 0
			end
	       -- 

			--阿凡提 攻击后可移动
			if match_ID(id,606) and WAR.Person[p]["我方"] == true and WAR.AutoFight == 0 and 0 < JY.Person[id]["生命"] then
				WAR.Person[p]["移动步数"] = 10
				War_CalMoveStep(p, WAR.Person[p]["移动步数"], 0)
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

			--司空摘星 攻击后可移动
			if match_ID(id,579) and WAR.Person[p]["我方"] == true and WAR.AutoFight == 0 and 0 < JY.Person[id]["生命"] then
				WAR.Person[p]["移动步数"] = 5
				War_CalMoveStep(p, WAR.Person[p]["移动步数"], 0)
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
	
	        --雪山上杀血刀老祖后，恢复我方人物 
	        if WAR.ZDDH == 7 then
				for x = 0, WAR.PersonNum - 1 do
					if WAR.Person[x]["人物编号"] == 97 and JY.Person[97]["生命"] <= 0 then
						for xx = 0, WAR.PersonNum - 1 do
							if WAR.Person[xx]["人物编号"] ~= 97 then
								WAR.Person[xx]["我方"] = true
							end
						end
					end
				end
	        end

			
			--九剑破招减少集气
			if WAR.JJPZ[id] == 1 then
				WAR.Person[p].Time = -200
				WAR.JJPZ[id] = nil
			end
			
			--太空卸劲减少集气
			if WAR.TKJQ[id] == 1 then
				WAR.Person[p].Time = -100
				WAR.TKJQ[id] = nil
			end
		
	        
			--行动后回气的效果上限600点
	        if 600 < WAR.Person[p].Time then
				WAR.Person[p].Time = 600
	        end
			

            --西门吹雪 
			 local ljxd = 0
             if  match_ID_awakened(pid,500,1) and JY.Person[0]["资质"]> 79  and  WAR.LJXD < 1 and JLSD(10,50,pid)then     				
				WAR.LJXD = WAR.LJXD + 1
				ljxd = 1

				WarDrawMap(0); --不加这条则动画位置无法正常显示
				CurIDTXDH(WAR.CurID, 132,1,"剑道巅峰·五方行尽",C_ORANGE);			
				--ShowScreen()
				--lib.Delay(400)
			  --立即行动 (周而复始) 多次行动
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
	
			--无酒不欢：袁承志，碧血长风，杀人后再动
	        if match_ID(id, 54) and WAR.BXCF == 1 and War_isEnd() == 0 then	
				for k = 1,20 do
					local i = 12+k
					if i > 24 then 
						i = 24 	
					end
					Cat('实时特效动画')
					Cls()
					NewDrawString(-1, -1, "碧血长风", C_RED, 25 + i)
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
			--李白十步杀一人，杀人后再动
	        if match_ID(id, 636) and id ==0 and WAR.SBSYR == 1 and War_isEnd() == 0 then	
				for k = 1,20 do
					local i = 12+k
					if i > 24 then 
						i = 24 	
					end
					Cat('实时特效动画')
					Cls()
					NewDrawString(-1, -1, "十步杀一人", C_RED, 25 + i)
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
	        
	        --资质越高发动几率越高
	        local pz = math.modf(JY.Person[0]["资质"] / 10)
	        --主角医生大招，直接再次行动
	        if id == 0 and JY.Base["标准"] == 8 and JY.Person[pid]["六如觉醒"] > 0 then
                if WAR.HTSS == 1 then 
                    WAR.HTSS = 0
                else
                    if JY.Person[0]["体力"] > 50 then
                        if WAR.HTSS == 0 and JLSD(25, 60 + pz, 0) and 0 < JY.Person[0]["武功9"] then
                            CurIDTXDH(WAR.CurID, 91, 1)

                            for k = 1,20 do
                                local i = 12+k
                                if i > 24 then 
                                    i = 24 	
                                end
                                Cat('实时特效动画')
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
                            JY.Person[0]["体力"] = JY.Person[0]["体力"] - 10
                            --有低概率再次发动
                            if JLSD(45, 50, 0) then
                                WAR.HTSS = 0        
                            else
                                WAR.HTSS = 1
                            end
                        end
                    end
                end
	        end
	
	        --成昆密道 100时序就跑
	        if WAR.ZDDH == 237 and 100 < WAR.SXTJ then
				for i = 0, WAR.PersonNum - 1 do
					if WAR.Person[i]["我方"] == false then
						WAR.Person[i]["死亡"] = true
					end
				end
				say("１Ｌ＜嗯，没功夫跟这"..JY.Person[0]["外号2"].."纠缠了＞Ｗ哈哈哈，"..JY.Person[0]["外号2"].."，算你走运！老夫还有要事待办，这次就放你一马！", 18,0)
	        end
	        --成昆密道 小于100时序战胜
	        if WAR.ZDDH == 237 and 100 > WAR.SXTJ and War_isEnd() then
				for i = 0, WAR.PersonNum - 1 do
					if WAR.Person[i]["我方"] == false and WAR.Person[i]["死亡"] == true then
			           instruct_2(14,1)
	               end						
			    end
			end	
			--大金刚掌战胜天虹半血即可
			if WAR.ZDDH == 353 and JY.Person[657]["生命"] < JY.Person[657]["生命最大值"]/2 then
				for i = 0, WAR.PersonNum - 1 do
					if WAR.Person[i]["我方"] == false then
					   WAR.Person[i]["死亡"] = true
					end
				end
			end
	        --张三丰 太极神功200时序
	        if WAR.ZDDH == 22 and 200 < WAR.SXTJ then
				for i = 0, WAR.PersonNum - 1 do
					if WAR.Person[i]["我方"] == false then
						WAR.Person[i]["死亡"] = true
					end
				end
				if JY.Person[0]["性别"] == 0 then
	           TalkEx("小兄弟年纪轻轻，武功就已到如此境界，实属难得。今日就到此为止", 5, 0)  --对话
              else
	        TalkEx("小姑娘年纪轻轻，武功就已到如此境界，实属难得。今日就到此为止", 5, 0)  --对话
	        end			
         end

	        --易筋战 达摩半血即获胜
	        if WAR.ZDDH == 309 and (JY.Person[577]["生命"] < JY.Person[577]["生命最大值"]/2 or 300 < WAR.SXTJ) then
				for i = 0, WAR.PersonNum - 1 do
					if WAR.Person[i]["我方"] == false then
						WAR.Person[i]["死亡"] = true
					end
		end
				if JY.Person[0]["性别"] == 0 then
	             TalkEx("小兄弟年纪轻轻，武功就已到如此境界，实属难得。今日就到此为止", 577, 0)  --对话
                else
	              TalkEx("小姑娘年纪轻轻，武功就已到如此境界，实属难得。今日就到此为止", 577, 0)  --对话
	        end			
        end

	
			--冰糖恋：邪十五大20时序胜利
	        if WAR.ZDDH == 133 and 20 < WAR.SXTJ and GetS(87,31,31,5) == 1 then
				for i = 0, WAR.PersonNum - 1 do
					if WAR.Person[i]["我方"] == false then
						WAR.Person[i]["死亡"] = true
					end
				end
				TalkEx("恭喜"..JY.Person[0]["外号"].."挺过20时序，成功过关。",269,0);
	        end

	        
	        --旧版华山论剑，敌我随机变换
	        if WAR.ZDDH == 238 then
	        	local life = 0  ---激活敌人
	        	WAR.NO1 = 114; --- 1号 战斗角色等于扫地
				for i = 0, WAR.PersonNum - 1 do   --执行指令
					if WAR.Person[i]["死亡"] == false and 0 < JY.Person[WAR.Person[i]["人物编号"]]["生命"] then   --如果没有死人和人物生命大于0 这样
						life = life + 1 -- 敌人+1
						if WAR.NO1 >= WAR.Person[i]["人物编号"] then  --如果编号大于等于1号人物
							WAR.NO1 = WAR.Person[i]["人物编号"] --敌人等于1号
						end
					end
				end
	          
				if 1 < life then  --如果激活人数大于1
					local m, n = 0, 0 --编号 设定 一个M方,一个N方
					while true do			--防止全部随机到已方
						if m >= 1 and n >= 1 then  --如果M方大于等于1，N方大于等于1
							break;  --终止循环
						else  -- 也可能是
							m = 0;  --M方为0 
							n = 0;  --N方为0
						end
						
						for i = 0, WAR.PersonNum - 1 do  --执行指令
							if WAR.Person[i]["死亡"] == false and 0 < JY.Person[WAR.Person[i]["人物编号"]]["生命"] then   --如果没有人死亡和人物生命大于0 
								if WAR.Person[i]["人物编号"] == 0 then  --如果人物编号等于0
									WAR.Person[i]["我方"] = true   --则为我方
									m = m + 1    --M方人数+1
								elseif math.random(2) == 1 then   --也可能 随机1~2为1时
									WAR.Person[i]["我方"] = true  --成为我方
									m = m + 1  --M方人数+1
								else
									WAR.Person[i]["我方"] = false  --也可能不是我方
									n = n + 1  --则N方人数+1
								end
							end
						end
					end
				end
	        end
	    end
       -- warStatus = War_isEnd()   --战斗是否结束？   0继续，1赢，2输
		--if 0 < warStatus then
		--	break;
		--end
	end
	    
		--warStatus = War_isEnd()   --战斗是否结束？   0继续，1赢，2输
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
 
	--战斗结束后的奖励
	if WAR.ZDDH == 238 then
		PlayMIDI(111)
		PlayWavAtk(41)
		DrawStrBoxWaitKey("论剑结束", C_WHITE, CC.DefaultFont)
		DrawStrBoxWaitKey("武功天下第一者：" .. JY.Person[WAR.NO1]["姓名"], C_RED, CC.DefaultFont)
		if WAR.NO1 == 0 then
		  r = true
		else
		  r = false
		end
	--战斗胜利
	elseif warStatus == 1 then
		PlayMIDI(111)
		PlayWavAtk(41)
		lib.LoadPNG(91, 1*2 , 295, 295, 1)
		ShowScreen();
		WaitKey();

		if WAR.ZDDH == 76 then
			DrawStrBoxWaitKey("特殊奖励：千年灵芝一枚", C_GOLD, CC.DefaultFont)
			instruct_32(14, 1)
		elseif WAR.ZDDH == 15 or WAR.ZDDH == 80 then
			DrawStrBoxWaitKey("特殊奖励：主角五系兵器值提升十点", C_RED, CC.DefaultFont,nil,C_GOLD)
			AddPersonAttrib(0, "拳掌功夫", 10)
			AddPersonAttrib(0, "指法技巧", 10)
			AddPersonAttrib(0, "御剑能力", 10)
			AddPersonAttrib(0, "耍刀技巧", 10)
			AddPersonAttrib(0, "特殊兵器", 10)

		elseif WAR.ZDDH == 172 then
			DrawStrBoxWaitKey("特殊奖励：获得蛤蟆功秘籍一本", C_GOLD, CC.DefaultFont)
			instruct_32(73, 1)
		elseif WAR.ZDDH == 173 then
			DrawStrBoxWaitKey("特殊奖励：获得天山雪莲两枚", C_GOLD, CC.DefaultFont)
			instruct_32(17, 2)
		elseif WAR.ZDDH == 188 then
			local hqjl = JYMsgBox("特殊奖励", "你完成了奖励战**请选择一项兵器值进行提高", {"拳法","指法","剑法","刀法","奇门"}, 5, 69)
			if hqjl == 1 then
				AddPersonAttrib(0, "拳掌功夫", 10)
				DrawStrBoxWaitKey("你的拳掌功夫提高了十点",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --清屏
			elseif hqjl == 2 then
				AddPersonAttrib(0, "指法技巧", 10)
				DrawStrBoxWaitKey("你的指法技巧提高了十点",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --清屏
			elseif hqjl == 3 then
				AddPersonAttrib(0, "御剑能力", 10)
				DrawStrBoxWaitKey("你的御剑能力提高了十点",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --清屏
			elseif hqjl == 4 then
				AddPersonAttrib(0, "耍刀技巧", 10)
				DrawStrBoxWaitKey("你的耍刀技巧提高了十点",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --清屏
			elseif hqjl == 5 then
				AddPersonAttrib(0, "特殊兵器", 10)
				DrawStrBoxWaitKey("你的特殊兵器提高了十点",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --清屏
			end
		elseif WAR.ZDDH == 292 then
			local hqjl = JYMsgBox("特殊奖励", "你完成了奖励战**请选择一项兵器值进行提高", {"拳法","指法","剑法","刀法","奇门"}, 5, 6)
			if hqjl == 1 then
				AddPersonAttrib(0, "拳掌功夫", 10)
				DrawStrBoxWaitKey("你的拳掌功夫提高了十点",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --清屏
			elseif hqjl == 2 then
				AddPersonAttrib(0, "指法技巧", 10)
				DrawStrBoxWaitKey("你的指法技巧提高了十点",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --清屏
			elseif hqjl == 3 then
				AddPersonAttrib(0, "御剑能力", 10)
				DrawStrBoxWaitKey("你的御剑能力提高了十点",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --清屏
			elseif hqjl == 4 then
				AddPersonAttrib(0, "耍刀技巧", 10)
				DrawStrBoxWaitKey("你的耍刀技巧提高了十点",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --清屏
			elseif hqjl == 5 then
				AddPersonAttrib(0, "特殊兵器", 10)
				DrawStrBoxWaitKey("你的特殊兵器提高了十点",C_GOLD,CC.DefaultFont,nil,LimeGreen)
				Cls()  --清屏
			end
		elseif WAR.ZDDH == 211 then
			DrawStrBoxWaitKey("特殊奖励：主角防御力和轻功各提升十点", C_GOLD, CC.DefaultFont)
			AddPersonAttrib(0, "防御力", 10)
			AddPersonAttrib(0, "轻功", 10)
		elseif WAR.ZDDH == 86 then
			instruct_2(66, 1)
		elseif WAR.ZDDH == 4 then
			if JY.Person[0]["实战"] < 500 then
				QZXS(string.format("%s 实战增加%s点",JY.Person[0]["姓名"],30));
				JY.Person[0]["实战"] = JY.Person[0]["实战"] + 30
				if JY.Person[0]["实战"] > 500 then
					JY.Person[0]["实战"] = 500
				end
			end
		elseif WAR.ZDDH == 77 then
			if JY.Person[0]["实战"] < 500 then
				QZXS(string.format("%s 实战增加%s点",JY.Person[0]["姓名"],20));
				JY.Person[0]["实战"] = JY.Person[0]["实战"] + 20
				if JY.Person[0]["实战"] > 500 then
					JY.Person[0]["实战"] = 500
				end
			end
		elseif WAR.ZDDH > 42 and  WAR.ZDDH < 47 then
			if JY.Person[0]["实战"] < 500 then
				QZXS(string.format("%s 实战增加%s点",JY.Person[0]["姓名"],10));
				JY.Person[0]["实战"] = JY.Person[0]["实战"] + 10
				if JY.Person[0]["实战"] > 500 then
					JY.Person[0]["实战"] = 500
				end
			end
		elseif WAR.ZDDH == 161 then
			if JY.Person[0]["实战"] < 500 then
				QZXS(string.format("%s 实战增加%s点",JY.Person[0]["姓名"],30));
				JY.Person[0]["实战"] = JY.Person[0]["实战"] + 30
				if JY.Person[0]["实战"] > 500 then
					JY.Person[0]["实战"] = 500
				end
			end
		--战胜海大富
		elseif WAR.ZDDH == 259 then
			DrawStrBoxWaitKey("特殊奖励：获得化骨绵掌秘籍一本", C_GOLD, CC.DefaultFont)
			instruct_32(275,1)
		elseif  WAR.ZDDH == 100 then
		DrawStrBoxWaitKey("特殊奖励：获得千年灵芝一枚", C_GOLD, CC.DefaultFont)
		instruct_32(14, 1)
		
	
		--新论剑奖励 根据敌人不同奖励不同
		elseif WAR.ZDDH == 266 then
			--老周
			if GetS(85, 40, 38, 4) == 64 then
				DrawStrBoxWaitKey("特殊奖励：你的体内消耗永久降低了50% ", LimeGreen, 36,nil, C_GOLD)
				JY.Person[64]["论剑奖励"] = 1
			--老王
			elseif GetS(85, 40, 38, 4) == 129 then
				DrawStrBoxWaitKey("特殊奖励：你的伤害量永久提高了20% ", LimeGreen, 36,nil, C_GOLD)
				JY.Person[129]["论剑奖励"] = 1
			--林朝英
			elseif GetS(85, 40, 38, 4) == 605 then
				DrawStrBoxWaitKey("特殊奖励：你的连击率永久提高了50% ", LimeGreen, 36,nil, C_GOLD)
				JY.Person[605]["论剑奖励"] = 1
			--阿青
			elseif GetS(85, 40, 38, 4) == 604 then
				DrawStrBoxWaitKey("特殊奖励：你的气防永久提高了800点", LimeGreen, 36,nil, C_GOLD)
				JY.Person[604]["论剑奖励"] = 1
				--instruct_32(278,1)
			--风清扬
			elseif GetS(85, 40, 38, 4) == 140 then
				if PersonKF(0, 47) then
					DrawStrBoxWaitKey("特殊奖励：你的气攻永久提高了1000点", LimeGreen, 36,nil, C_GOLD)
					JY.Person[592]["论剑奖励"] = 1
				else
					DrawStrBoxWaitKey("你似乎错过了一项奖励……", LimeGreen, 36,nil, C_GOLD)
				end
			--东方不败
			elseif GetS(85, 40, 38, 4) == 27 then
				DrawStrBoxWaitKey("特殊奖励：你的集气速度永久提高了8点", LimeGreen, 36,nil, C_GOLD)
				JY.Person[27]["论剑奖励"] = 1
			--扫地
			elseif GetS(85, 40, 38, 4) == 114 then
				DrawStrBoxWaitKey("特殊奖励：你的武学常识提高了100点", LimeGreen, 36,nil, C_GOLD)
				JY.Person[114]["论剑奖励"] = 1
				AddPersonAttrib(0, "武学常识", 100)
			--三丰
			elseif GetS(85, 40, 38, 4) == 5 then
				DrawStrBoxWaitKey("特殊奖励：你的攻防轻和五系兵器值全面提高了", LimeGreen, 36,nil, C_GOLD)
				JY.Person[5]["论剑奖励"] = 1
				AddPersonAttrib(0, "攻击力", 30)
				AddPersonAttrib(0, "防御力", 30)
				AddPersonAttrib(0, "轻功", 30)
				AddPersonAttrib(0, "拳掌功夫", 20)
				AddPersonAttrib(0, "指法技巧", 20)
				AddPersonAttrib(0, "御剑能力", 20)
				AddPersonAttrib(0, "耍刀技巧", 20)
				AddPersonAttrib(0, "特殊兵器", 20)
			--阿凡提
			elseif GetS(85, 40, 38, 4) == 606 then
				DrawStrBoxWaitKey("特殊奖励：你获得了绝对先手的能力", LimeGreen, 36,nil, C_GOLD)
				JY.Person[606]["论剑奖励"] = 1
			end
		end

		r = true
		--赵半山 李寻欢战斗胜利获得暗器
		if (JY.Base["畅想"] == 153 or JY.Base["畅想"] == 498) and WAR.ZDDH ~= 226 and WAR.ZDDH ~= 354 then
			local anqi = math.random(28,35)
			local num = math.random(5)
			instruct_2(anqi,num)
		end
		r = true
		--战斗胜利获得银两
		if (JY.Base["标准"] > 0 or JY.Base["畅想"] > 0) and WAR.ZDDH ~= 226 and WAR.ZDDH > 0 and WAR.ZDDH ~= 354 then
			local num = math.random(50,100)
			instruct_2(174,num)
			--instruct_2(209,num)			
		end
        if WAR.ZDDH ~= 226 and WAR.ZDDH ~= 354 then
            for i = 0,WAR.PersonNum-1 do
                local id = WAR.Person[i]['人物编号']
                if WAR.Person[i]['我方'] then
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

	--战斗失败
	elseif warStatus == 2 then
		--DrawStrBoxWaitKey("战斗失败", C_WHITE, CC.DefaultFont)
		lib.LoadPNG(91, 2 * 2 , 295, 295, 1)
		ShowScreen();
		WaitKey();
		r = false
	end
  
	War_EndPersonData(isexp, warStatus)
	lib.ShowSlow(20, 1)
	if 0 <= JY.Scene[JY.SubScene]["进门音乐"] then
		PlayMIDI(JY.Scene[JY.SubScene]["进门音乐"])
	else
		PlayMIDI(0)
	end
	CleanMemory()
	--lib.PicInit()
  
	--战斗结束，重新加载场景贴图
	--lib.PicLoadFile(CC.SMAPPicFile[1], CC.SMAPPicFile[2], 0)	--子场景贴图，内存区域0
	--lib.LoadPNGPath('./data/smap',0,-1,100)
	--lib.LoadPNGPath(CC.HeadPath, 1, CC.HeadNum, limitX(CC.ScreenW/936*100,0,100))	--人物头像，内存区域1
	--lib.LoadPNGPath(CC.XTPath, 91, CC.XTNum, limitX(CC.ScreenW/936*100,0,100))	--UI		
	--lib.LoadPNGPath(CC.BodyPath, 90, CC.BodyNum, limitX(CC.ScreenW/936*100,0,100))	--半身像，内存区域100
	--lib.LoadPNGPath(CC.UIPath, 96, CC.UINum, limitX(CC.ScreenW/936*100,0,100))
	--lib.PicLoadFile(CC.ThingPicFile[1], CC.ThingPicFile[2], 2, 100, 100)	--物品贴图，内存区域2
	--lib.LoadPNGPath('./data/thing',0,-1,100)
	--lib.PicLoadFile(CC.BJ[1], CC.BJ[2], 92)
	--lib.LoadPNGPath('./data/bj',0,-1,100)
	JY.Status = GAME_SMAP
	return r
end

--山洞妹妹，布阵
function buzhen()
	if not inteam(92) then
		return 
	end
	if WAR.ZDDH == 226 then
		return 
	end
	local line = "要布置阵型吗？";
	local tiles = 2;
	if (WAR.ZDDH == 133 or WAR.ZDDH == 134) and WAR.MCRS == 1 then
		if JY.Person[0]["性别"] == 0 then
			line = "哥哥你真勇敢，一个人挑战十五大高手，请千万小心。"
		else
			line = "姐姐你真勇敢，一个人挑战十五大高手，请千万小心。"
		end
		tiles = 4
	end
	say(line, 92,0,JY.Person[92]["姓名"])
	if not DrawStrBoxYesNo(-1, -1, "要布置阵型吗？", C_WHITE, CC.DefaultFont) then
		return 
	end
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["我方"] then
			WAR.CurID = i
            WAR.ShowHead = 1
            WarDrawMap(0)
            --布阵统一为2格
            WAR.Person[WAR.CurID]["移动步数"] = tiles
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

--无酒不欢：战前运功
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
		if WAR.Person[j]["人物编号"] == 0 then
			id, x1, y1 = j, WAR.Person[j]["坐标X"], WAR.Person[j]["坐标Y"]
			break
		end
	end
	if x1 == nil then
		return 
	end
	local s = WAR.CurID
	local pid = WAR.Person[id]['人物编号']
	local r = JYMsgBox("战前运功", "战前强行运功是有额外代价的*要继续吗？", {"否","是"}, 2, JY.Person[pid]["半身像"])
	if r == 2 then
		local menu={};
		for i=1,JY.Base["武功数量"] do
			menu[i]={JY.Wugong[JY.Person[0]["武功" .. i]]["名称"],nil,0};
			if JY.Wugong[JY.Person[0]["武功" .. i]]["武功类型"] == 6 then
				menu[i][3]=1;
			end
			--天罡不能运三大
			if (jqid == 0 and JY.Base["标准"] == 6 )  and (JY.Person[0]["武功" .. i] == 106 or JY.Person[0]["武功" .. i] == 107 or JY.Person[0]["武功" .. i] == 108) then
				menu[i][3]=0;	
			end
		end
		local main_neigong =  Cat('菜单',menu,#menu,bx*25,CC.ScreenH-by*60,C_WHITE,CC.FontSmall,1)
		if main_neigong ~= nil and main_neigong > 0 then
			WAR.CurID = id
			CleanWarMap(4, 0)
			SetWarMap(x1, y1, 4, 1)
			War_ShowFight(0, 0, 0, 0, 0, 0, 9)	
			--AddPersonAttrib(0, "内力", -500);
			AddPersonAttrib(0, "体力", -10);
			AddPersonAttrib(0, "生命", 500);
            AddPersonAttrib(0, "生命最大值", 500);			
			JY.Person[0]["主运内功"] = JY.Person[0]["武功" .. main_neigong]
			Hp_Max(pid)
			WAR.CurID = s
		end
	end
end

--无酒不欢：在自身位置播放动画的函数
function CurIDTXDH(id, eft, order, str, strColor, endFrame)
	--增加文字颜色控制
	if strColor == nil then
		strColor = C_GOLD
	end
	--增加强制结束帧
	if endFrame == nil then
		endFrame = CC.Effect[eft]
	end
	local x0, y0 = WAR.Person[id]["坐标X"], WAR.Person[id]["坐标Y"]
	local hb = GetS(JY.SubScene, x0, y0, 4)
	local starteft = 0
	
	for i = 0, eft - 1 do
		starteft = starteft + CC.Effect[i]
	end

	--local ssid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)
	for ii = 1, endFrame, order do
		lib.GetKey()
		Cat('实时特效动画')
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

--计算暗器伤害
function War_AnqiHurt(pid, emenyid, thingid, emeny)
	local num = nil
	local dam = nil
    local kd = JY.Person[emenyid]["抗毒能力"]

    if WAR.PD['六阳正气'][emenyid] ~= nil then 
        kd = kd + WAR.PD['六阳正气'][emenyid]
    end
    
	if JY.Person[emenyid]["受伤程度"] == 0 then
		num = JY.Thing[thingid]["加生命"] / 2 - Rnd(3)
	elseif JY.Person[emenyid]["受伤程度"] <= 33 then
		num = math.modf(JY.Thing[thingid]["加生命"] *2 / 3) - Rnd(3)
	elseif JY.Person[emenyid]["受伤程度"] <= 66 then
		num = JY.Thing[thingid]["加生命"] - Rnd(3)
	else
		num = math.modf(JY.Thing[thingid]["加生命"] *4 / 3) - Rnd(3)
	end
	  
	num = math.modf(num - JY.Person[pid]["暗器技巧"]/4 + JY.Person[emenyid]["暗器技巧"]/4)
	WAR.Person[emeny]["内伤点数"] = AddPersonAttrib(emenyid, "受伤程度", math.modf(-num / 6))
	dam = num * WAR.AQBS

	local r = AddPersonAttrib(emenyid, "生命", math.modf(dam))
	if (emenyid == 129 or emenyid == 65) and JY.Person[emenyid]["生命"] <= 0 then
		JY.Person[emenyid]["生命"] = 1
	end

	if JY.Person[emenyid]["生命"] <= 0 then
		WAR.Person[WAR.CurID]["经验"] = WAR.Person[WAR.CurID]["经验"] + JY.Person[emenyid]["等级"] * 5
	end
    
	if JY.Thing[thingid]["加中毒解毒"] > 0 then
		num = math.modf(JY.Thing[thingid]["加中毒解毒"] + JY.Person[pid]["暗器技巧"] / 4)
		num = num - kd
		num = limitX(num, 0, CC.PersonAttribMax["用毒能力"])
		WAR.Person[emeny]["中毒点数"] = AddPersonAttrib(emenyid, "中毒程度", num)
	end
    
	--沉睡状态的敌人会醒来
	if WAR.CSZT[emenyid] ~= nil then
		WAR.CSZT[emenyid] = nil
	end
	return r
end

--计算从(x,y)开始攻击最多能够击中几个敌人
function War_AutoCalMaxEnemy(x, y, wugongid, level)
  local wugongtype = JY.Wugong[wugongid]["攻击范围"]
  local movescope = JY.Wugong[wugongid]["移动范围" .. level]
  local fightscope = JY.Wugong[wugongid]["杀伤范围" .. level]
  local maxnum = 0
  local xmax, ymax = nil, nil
  if wugongtype == 0 or wugongtype == 3 then
    local movestep = War_CalMoveStep(WAR.CurID, movescope, 1)	--计算武功移动步数
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
          if n ~= WAR.CurID and WAR.Person[n]["死亡"] == false and WAR.Person[n]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
            local x = math.abs(WAR.Person[n]["坐标X"] - xx)
            local y = math.abs(WAR.Person[n]["坐标Y"] - yy)
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
        if id >= 0 and WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[id]["我方"] then
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
        if id >= 0 and WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[id]["我方"] then
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


--得到可以走到攻击到敌人的最近位置。
--scope可以攻击的范围
--返回 x,y。如果无法走到攻击位置，返回空
function War_AutoCalMaxEnemyMap(wugongid, level)
  local wugongtype = JY.Wugong[wugongid]["攻击范围"]
  local movescope = JY.Wugong[wugongid]["移动范围" .. level]
  local fightscope = JY.Wugong[wugongid]["杀伤范围" .. level]
  local x0 = WAR.Person[WAR.CurID]["坐标X"]
  local y0 = WAR.Person[WAR.CurID]["坐标Y"]
  CleanWarMap(4, 0)
  if wugongtype == 0 or wugongtype == 3 then
    for n = 0, WAR.PersonNum - 1 do
      if n ~= WAR.CurID and WAR.Person[n]["死亡"] == false and WAR.Person[n]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
        local xx = WAR.Person[n]["坐标X"]
        local yy = WAR.Person[n]["坐标Y"]
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
      if n ~= WAR.CurID and WAR.Person[n]["死亡"] == false and WAR.Person[n]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
        local xx = WAR.Person[n]["坐标X"]
        local yy = WAR.Person[n]["坐标Y"]
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

--自动医疗
function War_AutoDoctor()
  local x1 = WAR.Person[WAR.CurID]["坐标X"]
  local y1 = WAR.Person[WAR.CurID]["坐标Y"]
  War_ExecuteMenu_Sub(x1, y1, 3, -1)
end

--自动吃药
--flag=2 生命，3内力；4体力  6 解毒
function War_AutoEatDrug(flag)
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	local life = JY.Person[pid]["生命"]
	local maxlife = JY.Person[pid]["生命最大值"]
	local selectid = nil
	local minvalue = math.huge
	local shouldadd, maxattrib, str = nil, nil, nil
	if flag == 2 then
		maxattrib = JY.Person[pid]["生命最大值"]
		shouldadd = maxattrib - JY.Person[pid]["生命"]
		str = "加生命"
		
	elseif flag == 3 then
		maxattrib = JY.Person[pid]["内力最大值"]
		shouldadd = maxattrib - JY.Person[pid]["内力"]
		str = "加内力"
		
	elseif flag == 4 then
		maxattrib = CC.PersonAttribMax["体力"]
		shouldadd = maxattrib - JY.Person[pid]["体力"]
		str = "加体力"
		
	elseif flag == 6 then
		maxattrib = CC.PersonAttribMax["中毒程度"]
		shouldadd = JY.Person[pid]["中毒程度"]
		str = "加中毒解毒"
		
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
  
	--在队
	if inteam(pid) and WAR.Person[WAR.CurID]["我方"] == true then
		local extra = 0
		for i = 1, CC.MyThingNum do
			local thingid = JY.Base["物品" .. i]
			if thingid >= 0 then
				local add = Get_Add(thingid)
				if JY.Thing[thingid]["类型"] == 3 and add > 0 then
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
				local thingid = JY.Base["物品" .. i]
				if thingid >= 0 then
					local add = Get_Add(thingid)
					if JY.Thing[thingid]["类型"] == 3 and add > 0 then
						local v = add - shouldadd
						if v >= 0 and v < minvalue then
							minvalue = v
							selectid = thingid
						end
					end
				end
			end
		end
		--使用物品
		if UseThingEffect(selectid, pid) == 1 then
			instruct_32(selectid, -1)
			
		end
	--不在队
	else
		local extra = 0
		for i = 1, 4 do
			local thingid = JY.Person[pid]["携带物品" .. i]
			local tids = JY.Person[pid]["携带物品数量" .. i]
			if thingid >= 0 and tids > 0 then
				local add = Get_Add(thingid)
				if JY.Thing[thingid]["类型"] == 3 and add > 0 then
					local v = shouldadd - add
					if v < 0 then		--可以加满生命, 用其他方法找合适药品
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
				local thingid = JY.Person[pid]["携带物品" .. i]
				local tids = JY.Person[pid]["携带物品数量" .. i]
				if thingid >= 0 and tids > 0 then
					local add = Get_Add(thingid)
					if JY.Thing[thingid]["类型"] == 3 and add > 0 then
						local v = add - shouldadd
						if v >= 0 and v < minvalue then
							minvalue = v
							selectid = thingid
						end
					end
				end 
			end
		end
		--NPC使用物品
		if UseThingEffect(selectid, pid) == 1 then
			instruct_41(pid, selectid, -1)
		end
	end
	--lib.Delay(500)
end

--自动逃跑
function War_AutoEscape()
  local pid = WAR.Person[WAR.CurID]["人物编号"]
  if JY.Person[pid]["体力"] <= 5 then
    return 
  end
  local x, y = nil, nil
  War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["移动步数"], 0)		 --计算移动步数
  Cat('实时特效动画')
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
          if WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[k]["我方"] and WAR.Person[k]["死亡"] == false then
            local dx = math.abs(i - WAR.Person[k]["坐标X"])
            local dy = math.abs(j - WAR.Person[k]["坐标Y"])
	          if dx + dy < minDest then		--计算当前距离敌人最近的位置
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

  War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["移动步数"], 0)
  War_MovePerson(x, y)	--移动到相应的位置
end


--自动执行战斗，此时的位置一定可以打到敌人
function War_AutoExecuteFight(wugongnum)
  local pid = WAR.Person[WAR.CurID]["人物编号"]
  local x0 = WAR.Person[WAR.CurID]["坐标X"]
  local y0 = WAR.Person[WAR.CurID]["坐标Y"]
  local wugongid = JY.Person[pid]["武功" .. wugongnum]
  local level = math.modf(JY.Person[pid]["武功等级" .. wugongnum] / 100) + 1
  local maxnum, x, y = War_AutoCalMaxEnemy(x0, y0, wugongid, level)
  if x ~= nil then
    War_Fight_Sub(WAR.CurID, wugongnum, x, y)
    WAR.Person[WAR.CurID].Action = {"atk", x - WAR.Person[WAR.CurID]["坐标X"], y - WAR.Person[WAR.CurID]["坐标Y"]}
  end
end

--自动战斗
function War_AutoMenu()
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	WAR.AutoFight = 1
	WAR.ShowHead = 0
	Cls()
	if JY.Person[pid]["禁用自动"] == 1 then
		return 0
	else
		War_Auto()
		return 1
	end
end

--计算可移动步数
--id 战斗人id，
--stepmax 最大步数，
--flag=0  移动，物品不能绕过，1 武功，用毒医疗等，不考虑挡路。
--flag=2  无视建筑
function War_CalMoveStep(id, stepmax, flag)
  CleanWarMap(3, 255)
  local x = WAR.Person[id]["坐标X"]
  local y = WAR.Person[id]["坐标Y"]
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

--判断x,y是否为可移动位置
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

--解毒菜单
function War_DecPoisonMenu()
	WAR.ShowHead = 0
	local r = War_ExecuteMenu(2)
	WAR.ShowHead = 1
	Cls()
	return r
end

--判断攻击后面对的方向
function War_Direct(x1, y1, x2, y2)
	local x = x2 - x1
	local y = y2 - y1
	if x == 0 and y == 0 then
		return WAR.Person[WAR.CurID]["人方向"]
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

--医疗菜单
function War_DoctorMenu()
	WAR.ShowHead = 0
	local r = War_ExecuteMenu(3)
	WAR.ShowHead = 1
	Cls()
	return r
end

---执行医疗，解毒用毒
---flag=1 用毒， 2 解毒，3 医疗 4 暗器
---thingid 暗器物品id
function War_ExecuteMenu(flag, thingid)
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	local step = nil
	local sts =  nil
	if flag == 1 then
		step = math.modf(JY.Person[pid]["用毒能力"] / 40)
	elseif flag == 2 then
		step = math.modf(JY.Person[pid]["解毒能力"] / 40)
	elseif flag == 3 then
		step = math.modf(JY.Person[pid]["医疗能力"] / 40)
	elseif flag == 4 then
		step = math.modf(JY.Person[pid]["暗器技巧"] / 15) + 1
	end
	War_CalMoveStep(WAR.CurID, step, 1)
	--增加部分人物的7*7显示
	if pid == 0 and JY.Base["标准"] == 8 and flag == 3 then
		sts = 1
	elseif pid == 0 and JY.Base["标准"] == 9 and flag == 1 then 
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

--选择武功的函数，手动和AI都经过这里
function War_FightSelectType(movefanwei, atkfanwei, x, y,wugong)
	local x0 = WAR.Person[WAR.CurID]["坐标X"]
	local y0 = WAR.Person[WAR.CurID]["坐标Y"]
	if x == nil and y == nil then
		x, y = War_KfMove(movefanwei, atkfanwei,wugong)
		if x == nil then
			lib.GetKey()
			Cls()
			return 
		end
	--无酒不欢：AI也显示选择范围
	else
		Cat('实时特效动画')
		WarDrawAtt(x, y, atkfanwei, 4)
		WarDrawMap(1, x, y)
		ShowScreen()
		lib.Delay(CC.BattleDelay)
		Delay(5,x,y)
		--张无忌逆转乾坤
		if CC.TX["逆转乾坤"] == 1 then
			local z = WAR.CurID
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["人物编号"] == 0 and 0 < JY.Person[0]["生命"] then
					WAR.CurID = j
					break
				end
			end
			Cls()
			CurIDTXDH(WAR.CurID, 114,1,"逆转乾坤",C_ORANGE);
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
			Cat('实时特效动画')
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
					Cat('实时特效动画')
					CleanWarMap(7, 0)
					WarDrawAtt(x, y, atkfanwei, 4)
					WarDrawMap(1, x, y)
					ShowScreen()
					lib.Delay(CC.BattleDelay)
					break
				elseif (key == VK_SPACE or key == VK_RETURN) then
					--内力大于等于300才能使用
					if JY.Person[0]["内力"] >= 300 then
						JY.Person[0]["内力"] = JY.Person[0]["内力"] - 300
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
				Cat('实时特效动画')
				CleanWarMap(7, 0)
				WarDrawAtt(x, y, atkfanwei, 4)
				WarDrawMap(1, x, y)
				ShowScreen()
				lib.Delay(CC.BattleDelay)
			end
			CC.TX["逆转乾坤"] = 0
		end
		--主角，迷踪步躲避攻击
		if CC.TX["迷踪步"] == 1 then
			local z = WAR.CurID
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["人物编号"] == 0 and 0 < JY.Person[0]["生命"] then
					WAR.CurID = j
					break
				end
			end
			Cls()
			CurIDTXDH(WAR.CurID, 129,1,"迷踪步",Violet);
			WAR.Person[WAR.CurID]["移动步数"] = 6
			War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["移动步数"], 0)
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
			CC.TX["迷踪步"] = 0
		end
				--李寻欢 蜻蜓三抄水躲避攻击
		if JY.Person[498]["品德"] == 30 then
			local z = WAR.CurID
			for j = 0, WAR.PersonNum - 1 do
				if WAR.Person[j]["人物编号"] == 0 and 0 < JY.Person[0]["生命"] then
					WAR.CurID = j
					break
				end
			end
			Cls()
			CurIDTXDH(WAR.CurID, 129,1,"蜻蜓三抄水",Violet);
		
			WAR.Person[WAR.CurID]["移动步数"] = 6
			War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["移动步数"], 0)
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
			JY.Person[498]["品德"] = 10
		end
		--小昭影步
		if JY.Person[66]["品德"] == 90 then
			JY.Person[66]["品德"] = 50
			if WAR.XZ_YB[1] ~= nil then
				local z = WAR.CurID
				for j = 0, WAR.PersonNum - 1 do
					if WAR.Person[j]["人物编号"] == 0 and 0 < JY.Person[0]["生命"] then
						WAR.CurID = j
						break
					end
				end
				Cls()
				WarDrawMap(0)
				CurIDTXDH(WAR.CurID, 122,1, "接引离斯毒火海", C_RED)
				lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, -1)
				lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, -1)
                lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, -1)
				WarDrawMap(0)
				WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"] = WAR.XZ_YB[1], WAR.XZ_YB[2]
				WarDrawMap(0)
				CurIDTXDH(WAR.CurID, 122,1, "幻光游世常自在", C_RED)
				lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, WAR.Person[WAR.CurID]["贴图"])
				lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, WAR.CurID)
                SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, JY.Person[WAR.Person[WAR.CurID]["人物编号"]]['头像代号'])
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
		WAR.Person[WAR.CurID]["人方向"] = WAR.Person[WAR.CurID]["人方向"]
	else
		WAR.Person[WAR.CurID]["人方向"] = War_Direct(x0, y0, x, y)
	end
	SetWarMap(x, y, 4, 1)
	WAR.EffectXY = {}
	return x, y
end

--设置下一步可移动的坐标
function War_FindNextStep(steparray, step, flag, id)
	local num = 0
	local step1 = step + 1
  
	--ZOC判定
	local fujinnum = function(tx, ty)
		if flag ~= 0 or id == nil then
			return 0
		end
		local tnum = 0
		local wofang = WAR.Person[id]["我方"]
		local tv = nil
		tv = GetWarMap(tx + 1, ty, 2)
		if tv ~= -1 and WAR.Person[tv]["我方"] ~= wofang then
			tnum = 9999
		end
		tv = GetWarMap(tx - 1, ty, 2)
		if tv ~= -1 and WAR.Person[tv]["我方"] ~= wofang then
			tnum = 999
		end
		tv = GetWarMap(tx, ty + 1, 2)
		if tv ~= -1 and WAR.Person[tv]["我方"] ~= wofang then
			tnum = 999
		end
		tv = GetWarMap(tx, ty - 1, 2)
		if tv ~= -1 and WAR.Person[tv]["我方"] ~= wofang then
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

--判断是否能打到敌人
function War_GetCanFightEnemyXY()
	local num, x, y = nil, nil, nil
	num, x, y = War_realjl(WAR.CurID)
	if num == -1 then
		return 
	end
	return x, y
end

--移动
function War_MoveMenu()
  if WAR.Person[WAR.CurID]["人物编号"] ~= -1 then
    WAR.ShowHead = 0
    if WAR.Person[WAR.CurID]["移动步数"] <= 0 then
      return 0
    end
    War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["移动步数"], 0)
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
      if WAR.Person[i]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.Person[i]["死亡"] == false then
        ydd[n] = i
        n = n + 1
      end
    end
    local dx = ydd[math.random(n - 1)]
    local DX = WAR.Person[dx]["坐标X"]
    local DY = WAR.Person[dx]["坐标Y"]
    local YDX = {DX + 1, DX - 1, DX}
    local YDY = {DY + 1, DY - 1, DY}
    local ZX = YDX[math.random(3)]
    local ZY = YDY[math.random(3)]
    if not SceneCanPass(ZX, ZY) or GetWarMap(ZX, ZY, 2) < 0 then
      SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, -1)
      SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, -1)
      SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, -1)
      WAR.Person[WAR.CurID]["坐标X"] = ZX
      WAR.Person[WAR.CurID]["坐标Y"] = ZY
      SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, WAR.CurID)
      SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, WAR.Person[WAR.CurID]["贴图"])
      SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, JY.Person[WAR.Person[WAR.CurID]["人物编号"]]['头像代号'])
    end
  end
  return 1
end

--人物移动
function War_MovePerson(x, y, flag)
	local id = WAR.Person[WAR.CurID]['人物编号']
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
	--减少移动步数
	movetable.num = movenum
	movetable.now = 0
	WAR.Person[WAR.CurID].Move = movetable
	if WAR.Person[WAR.CurID]["移动步数"] < movenum then
		movenum = WAR.Person[WAR.CurID]["移动步数"]
		WAR.Person[WAR.CurID]["移动步数"] = 0
	else
		WAR.Person[WAR.CurID]["移动步数"] = WAR.Person[WAR.CurID]["移动步数"] - movenum
	end
	--移动人物
	--标主的特殊显示
	--七夕龙女的论剑奖励代表是否学有迷踪步(WAR.Person[WAR.CurID]["人物编号"] == 0 and JY.Base["标准"] > 0 and JY.Person[615]["论剑奖励"] == 1)  and
	if match_ID(id, 9976) then 
		Cat('神游太虚',x1,y1)
		--[[
	elseif  movenum > 2 and JY.Person[id]["主运轻功"] > 0 then
		local a = 0
		local gender = 0
		if JY.Person[0]["性别"] > 0 then
			gender = 1
		end
		for i = 1, movenum do
			local t1 = lib.GetTime()
			if a == 6 then
				a = 0
			end
			if i == 1 then
				SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, -1)
				SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, -1)
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
			WAR.Person[WAR.CurID]["坐标X"] = movetable[i].x
			WAR.Person[WAR.CurID]["坐标Y"] = movetable[i].y
			WAR.Person[WAR.CurID]["人方向"] = movetable[i].direct
			if i < movenum then
				WAR.Person[WAR.CurID]["贴图"] = WarCalPersonPic2(WAR.CurID, gender) + (a)*2
			else
				WAR.Person[WAR.CurID]["贴图"] = WarCalPersonPic(WAR.CurID)
			end
			--WAR.Person[WAR.CurID]["贴图"] = WarCalPersonPic(WAR.CurID)
			SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, WAR.CurID)
			SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, WAR.Person[WAR.CurID]["贴图"])
			Cat('实时特效动画')

			WarDrawMap(0)
			ShowScreen()
			a = a + 1
			lib.Delay(CC.BattleDelay)
		end
		]]
	else
		for i = 1, movenum do
			local t1 = lib.GetTime()
			SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, -1)
			SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, -1)
            SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, -1)
			WAR.Person[WAR.CurID]["坐标X"] = movetable[i].x
			WAR.Person[WAR.CurID]["坐标Y"] = movetable[i].y
			WAR.Person[WAR.CurID]["人方向"] = movetable[i].direct
			WAR.Person[WAR.CurID]["贴图"] = WarCalPersonPic(WAR.CurID)
			SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, WAR.CurID)
			SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, WAR.Person[WAR.CurID]["贴图"])
            SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, JY.Person[WAR.Person[WAR.CurID]["人物编号"]]['头像代号'])
			Cat('实时特效动画')
			WarDrawMap(0)
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end
	--主运轻功的话遇到ZOC移动不清0，反之清0
	if JY.Person[WAR.Person[WAR.CurID]["人物编号"]]["主运轻功"] == 0 then
		local fujinnum = function(tx, ty)
			local tnum = 0
			local wofang = WAR.Person[WAR.CurID]["我方"]
			local tv = nil
			tv = GetWarMap(tx + 1, ty, 2)
			if tv ~= -1 and WAR.Person[tv]["我方"] ~= wofang then
				tnum = 999
			end
			tv = GetWarMap(tx - 1, ty, 2)
			if tv ~= -1 and WAR.Person[tv]["我方"] ~= wofang then
				tnum = 999
			end
			tv = GetWarMap(tx, ty + 1, 2)
			if tv ~= -1 and WAR.Person[tv]["我方"] ~= wofang then
				tnum = 999
			end
			tv = GetWarMap(tx, ty - 1, 2)
			if tv ~= -1 and WAR.Person[tv]["我方"] ~= wofang then
				tnum = 999
			end
			return tnum
		end
		if fujinnum(WAR.Person[WAR.CurID]["坐标X"],WAR.Person[WAR.CurID]["坐标Y"]) ~= 0 then
			WAR.Person[WAR.CurID]["移动步数"] = 0
		end
	end
end

---用毒菜单
function War_PoisonMenu()
	WAR.ShowHead = 0
	local r = War_ExecuteMenu(1)
	WAR.ShowHead = 1
	Cls()
	return r
end

--战斗休息
function War_RestMenu()
	if WAR.CurID and WAR.CurID >= 0  then
		local pid = WAR.Person[WAR.CurID]["人物编号"]
		--走火不能休息
		if WAR.PD["走火状态"][pid] == 1 then
			return 1
		end
		local vv = math.modf(JY.Person[pid]["体力"] / 100 - JY.Person[pid]["受伤程度"] / 50 - JY.Person[pid]["中毒程度"] / 50) + 2
		if WAR.Person[WAR.CurID]["移动步数"] > 0 then
			vv = vv + 2
		end
		if inteam(pid) then
			vv = vv + math.random(3)
		else
			vv = vv + 6
		end
		vv = (vv) / 120
		local v = 3 + Rnd(3)
		WAR.Person[WAR.CurID]["体力点数"] = AddPersonAttrib(pid, "体力", v)
        
        if JY.Person[pid]["内力"] < 100 then
            local hn = 3 + math.modf(JY.Person[pid]["内力最大值"] * (vv))
            WAR.Person[WAR.CurID]["内力点数"] = AddPersonAttrib(pid, "内力", hn)
        else
			if not inteam(pid) then
			v = 3 + math.modf(JY.Person[pid]["生命最大值"]  * (vv))
			else
			v = 3 + math.modf(JY.Person[pid]["生命最大值"] /4* (vv))
			end
			WAR.Person[WAR.CurID]["生命点数"] = AddPersonAttrib(pid, "生命", v)
			v = 3 + math.modf(JY.Person[pid]["内力最大值"] * (vv))
			WAR.Person[WAR.CurID]["内力点数"] = AddPersonAttrib(pid, "内力", v)
		end
		
		War_Show_Count(WAR.CurID);		--显示当前控制人的点数
        
        if PersonKF(pid, 227) then 
			Cls()
			WAR.Defup[pid] = 1
			CurIDTXDH(WAR.CurID, 85,1,"调息·防御", LimeGreen);
        end
		
		if match_ID(pid, 721) then 
			Cls()
			WAR.Actup[pid] = 2;
			WAR.Defup[pid] = 1
			CurIDTXDH(WAR.CurID, 85,1,"蓄力·防御", LimeGreen);
        end
		--阿凡提休息带蓄力+防御
		if match_ID(pid, 606) then
			Cls()
			WAR.Actup[pid] = 2;
			WAR.Defup[pid] = 1
			CurIDTXDH(WAR.CurID, 85,1,"运筹帷幄·决胜千里", LimeGreen);
		end	
		--[[NPC休息会自动蓄力
		--先天调息不触发
		if not isteam(pid) and WAR.XTTX == 0 then
			if math.modf(JY.Person[pid]["生命最大值"] / 2) < JY.Person[pid]["生命"] then
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

--战斗查看状态
function War_StatusMenu()
	WAR.ShowHead = 0
	Menu_Status()
	WAR.ShowHead = 1
	Cls()	
end

--战斗物品菜单
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
		local id = JY.Base["物品" .. i + 1]
		if id >= 0 and (JY.Thing[id]["类型"] == 1 or JY.Thing[id]["类型"] == 3 or JY.Thing[id]["类型"] == 4) then
			thing[num] = id
			thingnum[num] = JY.Base["物品数量" .. i + 1]
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


--自动战斗判断是否能医疗
function War_ThinkDoctor()
  local pid = WAR.Person[WAR.CurID]["人物编号"]
  if JY.Person[pid]["体力"] < 50 or JY.Person[pid]["医疗能力"] < 20 then
    return -1
  end
  if JY.Person[pid]["医疗能力"] + 20 < JY.Person[pid]["受伤程度"] then
    return -1
  end
  local rate = -1
  local v = JY.Person[pid]["生命最大值"] - JY.Person[pid]["生命"]
  if JY.Person[pid]["医疗能力"] < v / 4 then
    rate = 30
  elseif JY.Person[pid]["医疗能力"] < v / 3 then
      rate = 50
  elseif JY.Person[pid]["医疗能力"] < v / 2 then
      rate = 70
  else
    rate = 90
  end
  if Rnd(100) < rate then
    return 5
  end
  return -1
end

--能否吃药增加参数
--flag=2 生命，3内力；4体力  6 解毒
function War_ThinkDrug(flag)
  local pid = WAR.Person[WAR.CurID]["人物编号"]
  local str = nil
  local r = -1
  if flag == 2 then
    str = "加生命"
  elseif flag == 3 then
    str = "加内力"
  elseif flag == 4 then
    str = "加体力"
  elseif flag == 6 then
    str = "加中毒解毒"
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
  
  --身上是否有药品
  if inteam(pid) and WAR.Person[WAR.CurID]["我方"] == true then
    for i = 1, CC.MyThingNum do
      local thingid = JY.Base["物品" .. i]
      if thingid >= 0 and JY.Thing[thingid]["类型"] == 3 and Get_Add(thingid) > 0 then
        r = flag
        break;
      end
    end
  else
    for i = 1, 4 do
      local thingid = JY.Person[pid]["携带物品" .. i]
      if thingid >= 0 and JY.Thing[thingid]["类型"] == 3 and Get_Add(thingid) > 0 then
        r = flag
        break;
      end
    end
  end
  return r
end

--使用暗器
function War_UseAnqi(id)

	return War_ExecuteMenu(4, id)
end

--初始化战斗数据
function WarLoad(warid)
	WarSetGlobal()
	local data = Byte.create(CC.WarDataSize)
	Byte.loadfile(data, CC.WarFile, warid * CC.WarDataSize, CC.WarDataSize)
	LoadData(WAR.Data, CC.WarData_S, data)
	WAR.ZDDH = warid
end

--加载战斗地图
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

--设置人物贴图
function WarSetPerson()
	CleanWarMap(2, -1)
	CleanWarMap(5, -1)
    CleanWarMap(10, -1)
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["死亡"] == false then
            
			SetWarMap(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"], 2, i)
			SetWarMap(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"], 5, WAR.Person[i]["贴图"])
            SetWarMap(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"], 10, JY.Person[WAR.Person[i]["人物编号"]]['头像代号'])
		end
	end
	--郭襄的诸天化身步
	if WAR.ZTHSB == 1 then
		lib.SetWarMap(WAR.Person[WAR.ZT_id]["坐标X"], WAR.Person[WAR.ZT_id]["坐标Y"], 5, -1)
	end
end

--显示武功动画，人物受伤动画，音效等
function War_ShowFight(pid, wugong, wugongtype, level, x, y, eft, ZHEN_ID)
	--攻击时不显示血条
	WAR.ShowHP = 0
	
	--没有合击
	if not ZHEN_ID then
		ZHEN_ID = -1
	end
	
	--内功
	if wugongtype == 6 then
		wugongtype = WAR.NGXS
	end
	if wugong == 93 then
		wugongtype = 5
	end	
	--无酒不欢：设置一下新的动画顺序
	if wugongtype == 2 then
		wugongtype = 1
	elseif wugongtype > 2 and wugongtype < 6 then
		wugongtype = wugongtype - 1
	end
  
	local x0 = WAR.Person[WAR.CurID]["坐标X"]
	local y0 = WAR.Person[WAR.CurID]["坐标Y"]
	
	local starteft = 0
	
	if pid > -1 then
	Cat('神游太虚2',1)
	local using_anqi = 0
	local anqi_name;
	--暗器动画
	if wugongtype == -1 then
		using_anqi = 1
		anqi_name = JY.Thing[eft]["名称"]
		--何铁手含沙射影
		if match_ID(pid, 83) then
			anqi_name = "含沙射影·"..anqi_name
		end
		eft = JY.Thing[eft]["暗器动画编号"]
		--李寻欢小李飞刀 例不虚发
		if  WAR.XLFD[pid] ~= nil then
			anqi_name = "小李飞刀·例不虚发"
		end		
		eft = 125
	end	

	
	--扫地老僧  随机动画
	if match_ID(pid, 114) then
		eft = math.random(100)
	end
	--萧秋水 动画
	if match_ID(pid, 652) then
		eft = 75
	end
	--陆渐 动画
	if match_ID(pid, 497) then
		eft = math.random(100)
	end
   if  match_ID(pid,721) and (WAR.PD['玉露酒'][pid] ~= nil or WAR.PD['梨花酒'][pid] ~= nil or WAR.PD['即墨老酒'][pid] ~= nil or WAR.PD['五宝花蜜酒'][pid] ~= nil )then
     eft =168
    end	  
	--伏魔杖法动画
	if (wugong == 86 or wugong == 96 or wugong == 82 or wugong == 83) and ShiZunXM(pid) then
		eft = 7
	end		
	--易筋经 动画
	if wugong == 108 then
		eft = math.random(100)
	end	
	--奔雷手 动画
	if WAR.LDJT == 1 then
	   eft = 9
	end	
 
    if wugong == 73  then
	eft = 61
	end	
	--双剑合壁动画
	if (wugong == 39 or wugong == 42 or wugong == 139 ) and ShuangJianHB(pid) then 
		eft = 83
	end	
	--黯然极意动画
	if  WAR.ARJY == 1 or WAR.ARJY1 == 1 then
		eft = 7
	end

	--霍都  龙象动画
	if match_ID(pid, 84) and wugong == 103 then
		eft = 73
	end

	--金蛇奥义动画
	if wugong == 40 and WAR.JSAY == 1 then
		eft = 44
	end
	--万佛朝宗动画
	if WAR.PD["万佛朝宗"][pid] == 1  then
	   eft = 169
	end
	--
	if WAR.WDKTJ == 1 then 
		eft = 170
	end
	if  WAR.AJFHNP == 1 then
		eft = 61
	end
	--七弦无形剑奥义动画
	if  WAR.QXWXJ == 1 then
		eft = 125
	end	
	--
	if  WAR.YQFSQ == 1 then
		eft = 126
	end	
	--追魂夺命的动画
	if wugong == 192 then
	 eft = 162
	end	
	--玄铁剑法的动画
	if wugong == 45 then
	 eft = 164
	end	
			
	--进阶万花
	if wugong == 30 and PersonKF(pid,175) then
		eft = 138
	end
	--进阶泰山
	if wugong == 31 and PersonKF(pid,175) then
		eft = 138
	end
	--进阶云雾
	if wugong == 32 and PersonKF(pid,175) then
		eft = 138
	end
	--进阶万岳
	if wugong == 33 and PersonKF(pid,175) then
		eft = 138
	end
	--进阶太岳
	if wugong == 34 and PersonKF(pid,175) then
		eft = 138
	end
	--阳春白雪曲
	if wugong == 185  then
		eft = 129
	end	
	--无酒不欢的特效动画
	if pid == 0 and JY.Base["特殊"] == 1 then
		if JY.Person[0]["性别"] == 0 then
			eft = 65
		else
			eft = 8
		end
	end

	--杨康的杨家枪法
	if match_ID(pid,650) and wugong == 68 then
		eft = 150
	end
	
	--无招胜有招动画
	if wugong == 47 and WAR.FQY == 1 then
		eft = 83
	end
------------------------------------------------------
-- 大武功特效	
	local ex, ey = -1, -1;		
	--指定XY，那么只显示在一个点显示动画
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
	--六脉神剑的类型设置为拳法
	if wugong == 49 then
		wugongtype = 1
	end

	--合击动画
	local ZHEN_pid, ZHEN_type, ZHEN_startframe, ZHEN_fightframe = nil, nil, nil, nil
	if ZHEN_ID >= 0 then
		ZHEN_pid = WAR.Person[ZHEN_ID]["人物编号"]
		ZHEN_type = wugongtype
		ZHEN_startframe = 0
		ZHEN_fightframe = 0
	end
  
	local fightdelay, fightframe, sounddelay = nil, nil, nil
	if wugongtype >= 0 then
		fightdelay = JY.Person[pid]["出招动画延迟" .. wugongtype + 1]
		fightframe = JY.Person[pid]["出招动画帧数" .. wugongtype + 1]
		sounddelay = JY.Person[pid]["武功音效延迟" .. wugongtype + 1]
	else
		fightdelay = 0
		fightframe = -1
		sounddelay = -1
	end
  
	if fightdelay == 0 or fightframe == 0 then
		for i = 1, 5 do
			if JY.Person[pid]["出招动画帧数" .. i] ~= 0 then
				fightdelay = JY.Person[pid]["出招动画延迟" .. i]
				fightframe = JY.Person[pid]["出招动画帧数" .. i]
				sounddelay = JY.Person[pid]["武功音效延迟" .. i]
				wugongtype = i - 1
			end
		end
	end

	if ZHEN_ID >= 0 then
		if JY.Person[ZHEN_pid]["出招动画帧数" .. ZHEN_type + 1] == 0 then
			for i = 1, 5 do
				if JY.Person[ZHEN_pid]["出招动画帧数" .. i] ~= 0 then
					ZHEN_type = i - 1
					ZHEN_fightframe = JY.Person[ZHEN_pid]["出招动画帧数" .. i]
				end
			end
		else
			ZHEN_fightframe = JY.Person[ZHEN_pid]["出招动画帧数" .. ZHEN_type + 1]
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
			startframe = startframe + 4 * JY.Person[pid]["出招动画帧数" .. i + 1]
		end
	end
	if ZHEN_ID >= 0 and ZHEN_type >= 0 then
		for i = 0, ZHEN_type - 1 do
			ZHEN_startframe = ZHEN_startframe + 4 * JY.Person[ZHEN_pid]["出招动画帧数" .. i + 1]
		end
	end
  
	--local starteft = 0
	for i = 0, eft - 1 do
		starteft = starteft + CC.Effect[i]
	end

	WAR.Person[WAR.CurID]["贴图类型"] = 0
	WAR.Person[WAR.CurID]["贴图"] = WarCalPersonPic(WAR.CurID)
	if ZHEN_ID >= 0 then
		WAR.Person[ZHEN_ID]["贴图类型"] = 0
		WAR.Person[ZHEN_ID]["贴图"] = WarCalPersonPic(ZHEN_ID)
	end
  
	local oldpic = WAR.Person[WAR.CurID]["贴图"] / 2		--当前贴图的位置
	local oldpic_type = 0
	local oldeft = -1
	local kfname = JY.Wugong[wugong]["名称"]
	local showsize = CC.FontBig
	local showx = CC.ScreenW / 2 - showsize * string.len(kfname) / 4
	local hb = GetS(JY.SubScene, x0, y0, 4)
  
	--显示武功，放到特效文字4
	if wugong ~= 0 then
		if WAR.LHQ_BNZ == 1 then
			kfname = "般若掌"
		end
		if WAR.JGZ_DMZ == 1 then
			kfname = "达摩掌"
		end
		if WAR.WD_CLSZ == 1 then
			kfname = "赤练神掌"
		end
		if WAR.QZ_QXJF == 1 then
			kfname = "七星剑法"
		end	
		if ( wugong == 22 or wugong == 189 ) and JinGangBR(pid) then
			kfname = "金刚般若掌"
		end	
        if wugong == 93 then
 	       kfname = "圣火令神功"
		end	
	end
	
	--王重阳一气化三清文字
	if WAR.YQFSQ == 1 then
		kfname = "中神通·一气化三清"
	end	
	if WAR.PD["如来神掌"][pid] == 1 then
		kfname = "如来神掌"
		WAR.PD["如来神掌"][pid] =nil
	end	
	if WAR.PD["如来神掌"][pid] == 2 then
		kfname = "如来神掌●灭"
		WAR.PD["如来神掌"][pid] =nil
	end	
	--金蛇奥义
	if WAR.JSAY == 1 then
		kfname = "奥义·金蛇狂舞"
	end
	--莫大七弦无形剑 奥义
	if WAR.QXWXJ == 1 then
		kfname = "绝技·七弦无形剑·无形剑气"
	end	
	--周威信呼延十八鞭显示倍数
	if wugong == 206 and match_ID(pid, 612) and WAR.ZWX > 0 then
		kfname = kfname.." X "..WAR.ZWX
	end 
	--卓天雄呼延十八鞭显示倍数
	if wugong == 206 and match_ID(pid, 613) and WAR.ZWX > 0 then
		kfname = kfname.." X "..WAR.ZWX
	end 	
	--卓天雄震天铁掌显示倍数
	if wugong == 205 and match_ID(pid, 613) and WAR.ZWX > 0 then
		kfname = kfname.." X "..WAR.ZWX
	end 		
	--何铁手五毒显示倍数
	if wugong == 3 and match_ID(pid, 83) and WAR.HTS > 0 then
		kfname = kfname.." X "..WAR.HTS
	end 
	--·云罗天网
	if WAR.YLTW > 0 then
		kfname = "〖云罗天网〗·"..kfname
	end
	--井月八法
	if WAR.KZJYBF > 0 then
		kfname = "【井月八法】·"..WAR.KZJYBF.." 式·"..kfname
	end	

    if WAR.JTYJ1 == 1 then
	  kfname = "『惊天一剑』·"..kfname
	  end  
    if ShuangJianHB(pid) and (wugong == 42 or wugong ==39 or wugong == 139 ) then
	  kfname = "『双剑合璧』·"..kfname
	  end 	  
    if WAR.BXXHSJ == 1 then
	  kfname = "『雪花神剑』·"..kfname
	  end  	  
	--内功显示随机到的系
	if WAR.NGXS > 0 and wugong ~= 93 then
		local display = {"拳罡","指力","剑气","刀风","奇术"}
		kfname = kfname.."·"..display[WAR.NGXS]
	end
  
	if ZHEN_ID >= 0 then
		kfname = "双人合击·"..kfname
	end
  
	--特效文字4和武功名称显示
	if wugong > 0 or WAR.hit_DGQB == 1 then				--使用武功时才显示，独孤求败反击也显示
		if WAR.Person[WAR.CurID]["特效文字4"] ~= nil then
			for k=0, 30, 4 do
				local i = k 
				if i > 20 then 
					i = 20 
				end	
				Cat('实时特效动画')
				Cls()
				local n, strs = Split(WAR.Person[WAR.CurID]["特效文字4"], "·");
				local len = string.len(WAR.Person[WAR.CurID]["特效文字4"]);
				local color = RGB(255,40,10);
				local off = 0;
				for j=1, n do
					if strs[j] == "连击" or strs[j] == "天赋外功.炉火纯青" 
					or strs[j] == "碧箫声里双鸣凤" or strs[j] == "英雄无双风流婿" or strs[j] == "刀光掩映孔雀屏" 
					or strs[j] == "太极之形.圆转不断" then
						color = M_LightBlue;
					elseif strs[j] == "左右互搏" then
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
		--武功显示
		for n = 5, 20 do
			local i = n 
			if i > 10 then 
				i = 10
			end
			Cat('实时特效动画')
			Cls()
			KungfuString(kfname, CC.ScreenW / 2 -#kfname/2, CC.ScreenH / 3 - 20 - hb  , C_GOLD, CC.FontBig+i, CC.FontName, 0)
			ShowScreen()
			lib.Delay(CC.BattleDelay)  
		end
	end
	
	--暗器显示
	if using_anqi == 1 then
		for i = 5, 10 do
			Cat('实时特效动画')
			Cls()
			if WAR.KHSZ == 1 then
				KungfuString("葵花神针", CC.ScreenW / 2 -#anqi_name/2, CC.ScreenH / 3 - 20 - hb  , C_RED, CC.FontBig+i, CC.FontName, 0)
			else
				KungfuString(anqi_name.."×"..WAR.AQBS, CC.ScreenW / 2 -#anqi_name/2, CC.ScreenH / 3 - 20 - hb  , C_GOLD, CC.FontBig+i, CC.FontName, 0)
			end
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end
  
  --显示攻击动画
	for i = 0, framenum - 1 do
		if JY.Restart == 1 then
			break
		end
		local tstart = lib.GetTime()
		local mytype = nil
		if fightframe > 0 then
			WAR.Person[WAR.CurID]["贴图类型"] = 1
			mytype = 101+JY.Person[pid]['头像代号']
			if i < fightframe then
				WAR.Person[WAR.CurID]["贴图"] = (startframe + WAR.Person[WAR.CurID]["人方向"] * fightframe + i) * 2
			end
		else
			WAR.Person[WAR.CurID]["贴图类型"] = 0
			WAR.Person[WAR.CurID]["贴图"] = WarCalPersonPic(WAR.CurID)
			mytype = 0
		end
    
		if ZHEN_ID >= 0 then
			if ZHEN_fightframe > 0 then
				WAR.Person[ZHEN_ID]["贴图类型"] = 1
				
				if i < ZHEN_fightframe and i < oldframe - 1 then
					WAR.Person[ZHEN_ID]["贴图"] = (ZHEN_startframe + WAR.Person[ZHEN_ID]["人方向"] * ZHEN_fightframe + i) * 2
				else
					WAR.Person[ZHEN_ID]["贴图"] = WarCalPersonPic(ZHEN_ID)
				end
			else
				WAR.Person[ZHEN_ID]["贴图类型"] = 0
				WAR.Person[ZHEN_ID]["贴图"] = WarCalPersonPic(ZHEN_ID)
			end
			SetWarMap(WAR.Person[ZHEN_ID]["坐标X"], WAR.Person[ZHEN_ID]["坐标Y"], 5, WAR.Person[ZHEN_ID]["贴图"])
		end
    
    if i == sounddelay then
		PlayWavAtk(JY.Wugong[wugong]["出招音效"])		--
    end
    
    if i == fightdelay then
		PlayWavE(eft)
    end
    
	--六脉神剑的音效
    if i == 1 and WAR.LMSJwav == 1 then
		PlayWavAtk(31)
		WAR.LMSJwav = 0
    end
    
    local pic = WAR.Person[WAR.CurID]["贴图"] / 2
    
    lib.SetClip(0, 0, 0, 0)
    
    oldpic = pic
    oldpic_type = mytype
    
    --无酒不欢：攻击特效文字显示 8-3
   
    if i < fightdelay then
		WarDrawMap(4, pic * 2, mytype, -1)
		
		--袁承志暴击倍数显示
		--仅限我方
		if match_ID(pid, 54) and inteam(pid) and using_anqi == 0 and WAR.BJ == 1 then
			local cri_factor = 1.5 + 0.1 * JY.Base["天书数量"]
			KungfuString("暴击×"..cri_factor, CC.ScreenW -230 +i*2, CC.ScreenH / 3 - 50 - hb -i*2, C_RED, CC.FontBig+i*2, CC.FontName, 0)
  		end
		
		if i == 1 and WAR.Person[WAR.CurID]["特效动画"] ~= -1 then
			local theeft = WAR.Person[WAR.CurID]["特效动画"]
			local sf = 0
			for ii = 0, theeft - 1 do
				sf = sf + CC.Effect[ii]
			end
			
			for ii = 1, CC.Effect[theeft] do
				lib.GetKey()
				
				Cat('实时特效动画')	
				WarDrawMap(6, pic * 2, mytype,  (sf+ii)*2, nil, 3, nil, nil)
				--lib.PicLoadCache(3, (sf+ii) * 2, CC.ScreenW/2 , CC.ScreenH/2  - hb, 2, 192, nil, 0, 0)	
				if WAR.Person[WAR.CurID]["特效文字0"] ~= nil then
					KungfuString(WAR.Person[WAR.CurID]["特效文字0"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_ORANGE, CC.FontSmall5, CC.FontName, 4)
				end
				if WAR.Person[WAR.CurID]["特效文字1"] ~= nil then
					KungfuString(WAR.Person[WAR.CurID]["特效文字1"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_RED, CC.FontSmall5, CC.FontName, 3)
				end
				if WAR.Person[WAR.CurID]["特效文字2"] ~= nil then
					KungfuString(WAR.Person[WAR.CurID]["特效文字2"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_GOLD, CC.FontSmall5, CC.FontName, 2)
				end
				if WAR.Person[WAR.CurID]["特效文字3"] ~= nil then
					KungfuString(WAR.Person[WAR.CurID]["特效文字3"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_WHITE, CC.FontSmall5, CC.FontName, 1)
				end
				ShowScreen()
				lib.Delay(CC.BattleDelay)
			  
			end
			WAR.Person[WAR.CurID]["特效动画"] = -1
		else
			if WAR.Person[WAR.CurID]["特效文字0"] ~= nil or WAR.Person[WAR.CurID]["特效文字1"] ~= nil or WAR.Person[WAR.CurID]["特效文字2"] ~= nil or WAR.Person[WAR.CurID]["特效文字3"] ~= nil then
				Cat('实时特效动画')	
				WarDrawMap(4, pic * 2, mytype, -1)
				KungfuString(WAR.Person[WAR.CurID]["特效文字0"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_ORANGE, CC.FontSmall5, CC.FontName, 4)
				KungfuString(WAR.Person[WAR.CurID]["特效文字1"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_RED, CC.FontSmall5, CC.FontName, 3)
				KungfuString(WAR.Person[WAR.CurID]["特效文字2"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_GOLD, CC.FontSmall5, CC.FontName, 2)
				KungfuString(WAR.Person[WAR.CurID]["特效文字3"], CC.ScreenW / 2, CC.ScreenH /702*265 - hb, C_WHITE, CC.FontSmall5, CC.FontName, 1)
			end
		end
    else
		
		for k = 0,WAR.PersonNum-1 do
			local sx,sy = WAR.Person[k]['坐标X'],WAR.Person[k]['坐标Y']
			if WAR.Person[k]['死亡'] == false then
				if WAR.Person[k]['闪避'] == true then

					if GetWarMap(sx,sy,4) <= 10 then 
						SetWarMap(sx,sy,4,11)
					else 
						SetWarMap(sx,sy,4,GetWarMap(sx,sy,4)+1) 
					end
				end
			end		
		end
		
		--人物动作计算
		if i <= oldframe-1 then
		   starteft = starteft + 1
		else   
		   starteft = -1
		end  
      
		if WAR.ZTHSB == 1 then
			lib.SetWarMap(WAR.Person[WAR.ZT_id]["坐标X"], WAR.Person[WAR.ZT_id]["坐标Y"], 5, -1)
		end
		Cat('实时特效动画')
        WarDrawMap(4, pic * 2, mytype, (starteft) * 2, nil, 3, ex, ey)
		
		--郭襄的诸天化身步
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

    WAR.Person[WAR.CurID]['特效文字0'] = nil;
    WAR.Person[WAR.CurID]['特效文字1'] = nil;
    WAR.Person[WAR.CurID]['特效文字2'] = nil;
    WAR.Person[WAR.CurID]['特效文字3'] = nil;
	WAR.Person[WAR.CurID]['特效文字4'] = nil;
    WAR.Person[WAR.CurID]['特效动画'] = -1;
	
  --lib.SetClip(0, 0, 0, 0)
	WAR.Person[WAR.CurID]["贴图类型"] = 0
	WAR.Person[WAR.CurID]["贴图"] = WarCalPersonPic(WAR.CurID)
	WAR.MissPd = 0
	WarSetPerson()
	Cat('实时特效动画')
	WarDrawMap(0)
	ShowScreen()
	lib.Delay(CC.BattleDelay)
	local yc = math.ceil(200/CC.BattleDelay)
	for j = 1,yc do
		Cat('实时特效动画')
		WarDrawMap(2)
		ShowScreen()
		lib.Delay(CC.BattleDelay)
	end
  --无酒不欢：命中的人物用白色表示
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

  --计算攻击到的人
  local HitXY = {}
  local HitXYNum = 0
  local hnum = 13;		--HitXY的长度个数
  for i = 0, WAR.PersonNum - 1 do
    local x1 = WAR.Person[i]["坐标X"]
    local y1 = WAR.Person[i]["坐标Y"]
	--被特效击中的也显示
    if WAR.Person[i]["死亡"] == false and (GetWarMap(x1, y1, 4) > 1 or WAR.TXXS[WAR.Person[i]["人物编号"]] == 1) then
		local dx = 0
		if GetWarMap(x1, y1, 4) > 1 then
			dx = 1
		end
      SetWarMap(x1, y1, 4, 1)
      --local n = WAR.Person[i]["点数"]
      local hp = WAR.Person[i]["生命点数"];
      local mp = WAR.Person[i]["内力点数"];
      local tl = WAR.Person[i]["体力点数"];
      local ed = WAR.Person[i]["中毒点数"];
      local dd = WAR.Person[i]["解毒点数"];
      local ns = WAR.Person[i]["内伤点数"];
      
      HitXY[HitXYNum] = {x1, y1, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil};		--x, y, 生命, 内力, 体力, 封穴, 流血, 中毒, 解毒, 内伤，冰封，灼烧
	  
		if hp ~= nil and (dx == 1 or hp ~= 0)  then
		 
			if hp == 0 then			--显示受到的生命
				--if WAR.Miss[WAR.Person[i]["人物编号"]] ~= nil  then
				HitXY[HitXYNum][3] = "miss"
				--end
			elseif hp > 0 then
				HitXY[HitXYNum][3] = "+"..hp;
			else
				HitXY[HitXYNum][3] = hp;
			end
	    end

    
      if mp ~= nil then			--显示内力变化
      	if mp > 0 then
      		HitXY[HitXYNum][5] = "内力+"..mp;
      	elseif mp ==  0 then
      		HitXY[HitXYNum][5] = nil;			--变化为0时不显示
      	else
      		HitXY[HitXYNum][5] = "内力"..mp;
      	end
      end
      
      if tl ~= nil then			--显示体力变化
      	if tl > 0 then
      		HitXY[HitXYNum][6] = "体力+"..tl;
      	elseif tl == 0 then
      		HitXY[HitXYNum][6] = nil;
      	else
      		HitXY[HitXYNum][6] = "体力"..tl;
      	end
      end
      
      if WAR.FXXS[WAR.Person[i]["人物编号"]] ~= nil and WAR.FXXS[WAR.Person[i]["人物编号"]] == 1 then			--显示是否封穴
       	HitXY[HitXYNum][7] = "封穴 "..WAR.FXDS[WAR.Person[i]["人物编号"]];
       	WAR.FXXS[WAR.Person[i]["人物编号"]] = 0
      end
      
      if WAR.LXXS[WAR.Person[i]["人物编号"]] ~=nil and WAR.LXXS[WAR.Person[i]["人物编号"]] == 1 then		--显示是否被流血
      	HitXY[HitXYNum][8] = "流血 "..WAR.LXZT[WAR.Person[i]["人物编号"]];
        WAR.LXXS[WAR.Person[i]["人物编号"]] = 0
      end
         
      if ed ~= nil then				--显示中毒
      	if ed == 0 then
      		HitXY[HitXYNum][9] = nil;
      	else
      		HitXY[HitXYNum][9] = "中毒↑"..ed;
      	end
      end
      
      if dd ~= nil then			--显示解毒
      	if dd  == 0 then
      		HitXY[HitXYNum][4] = nil;
      	else
      		HitXY[HitXYNum][4] = "中毒↓"..dd;
      	end
      end
      
      if ns ~= nil then		--显示内伤
      	if ns == 0 then
      		HitXY[HitXYNum][10] = nil;
      	elseif ns > 0 then
      		HitXY[HitXYNum][10] = "内伤↑"..ns;
      	else
      		HitXY[HitXYNum][10] = "内伤↓"..ns;
      	end
      end
	  
		if WAR.BFXS[WAR.Person[i]["人物编号"]] == 1 then		--显示是否被冰封
			HitXY[HitXYNum][11] = "冰封 "..JY.Person[WAR.Person[i]["人物编号"]]["冰封程度"];
			WAR.BFXS[WAR.Person[i]["人物编号"]] = 0
		end
		
		if WAR.ZSXS[WAR.Person[i]["人物编号"]] == 1 then		--显示是否被灼烧
			HitXY[HitXYNum][12] = "灼烧 "..JY.Person[WAR.Person[i]["人物编号"]]["灼烧程度"];
			WAR.ZSXS[WAR.Person[i]["人物编号"]] = 0
		end
		
		HitXYNum = HitXYNum + 1
    end
    
		--偷东西，斗转不可偷
		if WAR.TD > -1 then
			if WAR.TD == 118 then
				say("１想要从我慕容复手中偷东西？哼哼，下辈子吧！", 51,0)
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
	--挨打特效文字显示
	local txsx = 0
	local txwz = 0
	local mz = false
	--计算最大动画帧数
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["死亡"] == false then
			local theeft = WAR.Person[i]["特效动画"]
			if theeft ~= -1 then
				if txsx < CC.Effect[theeft] then 
					txsx = CC.Effect[theeft]
				end
			end
			if theeft == -1 and (WAR.Person[i]["特效文字0"] ~= nil or WAR.Person[i]["特效文字1"] ~= nil or WAR.Person[i]["特效文字2"] ~= nil or WAR.Person[i]["特效文字3"] ~= nil or WAR.Person[i]["特效文字4"] ~= nil) then	
				txwz = 1
			end
			mz = true
		end	 
	end
	local bj = {-6,6,-5,5,-4,4,-3,3}
	
	--显示特效文字
	--没有特效固定10次循环
	if txsx == 0 and (txwz == 1 or (WAR.BJ == 1 and CC.Bj == 1)) then 
		txsx = 10 
	end	


	local zt_count = 0
	for ii = 1, txsx do
		if JY.Restart == 1 then
			break
		end
		local yanshi = false
		local yanshi2 = false		--无动画时的延迟

		local _,ys = math.modf(ii/2)
		if ys == 0 then
			zt_count = zt_count + 1
		end
		
        for i = 0, WAR.PersonNum - 1 do
	        if WAR.Person[i]["死亡"] == false then
				local theeft = WAR.Person[i]["特效动画"]
				local ix,iy = WAR.Person[i]["坐标X"],WAR.Person[i]["坐标Y"]  
				if theeft ~= -1 and ii < CC.Effect[theeft] then
					
					starteft = ii
					for i = 0, WAR.Person[i]["特效动画"] - 1 do
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
		
		Cat('实时特效动画')
		

	    if (WAR.BJ == 1 and CC.Bj == 1) or WAR.PD["万佛朝宗"][pid] == 1 then

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
			if WAR.Person[i]["死亡"] == false then
				local theeft = WAR.Person[i]["特效动画"]
				--郭襄的诸天化身步
				if i ~= WAR.ZT_id and WAR.ZTHSB == 1 then
                    local zid = JY.Person[WAR.Person[WAR.ZT_id]["人物编号"]]['头像代号']
					local dx = WAR.Person[i]["坐标X"] - x0
					local dy = WAR.Person[i]["坐标Y"] - y0
					local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
					local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
					
					lib.PicLoadCache(101+zid, (0+zt_count)*2, rx-80+ii*4, ry+80-ii*4, 2, 100+ii*5)
					lib.PicLoadCache(101+zid, (11+zt_count)*2, rx-80+ii*4, ry-80+ii*4, 2, 100+ii*5)
					lib.PicLoadCache(101+zid, (22+zt_count)*2, rx+80-ii*4, ry+80-ii*4, 2, 100+ii*5)
					lib.PicLoadCache(101+zid, (33+zt_count)*2, rx+80-ii*4, ry-80+ii*4, 2, 100+ii*5)
					yanshi = true
				elseif theeft ~= -1 and ii < CC.Effect[theeft] then
					local dx = WAR.Person[i]["坐标X"] - x0
					local dy = WAR.Person[i]["坐标Y"] - y0
					local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
					local ry = CC.YScale * (dx + dy) + CC.ScreenH / 702*265
					local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)
					
					local py = 0

					ry = ry - hb
					starteft = ii
					for i = 0, WAR.Person[i]["特效动画"] - 1 do
						starteft = starteft + CC.Effect[i]
					end

					--lib.PicLoadCache(3, (starteft) * 2, rx, ry + py, 2, 192, nil, 0, 0)
	
					--无酒不欢：特效文字一起出，不再用依次显示的方式
					--if ii < TPXS[i] * TP and (TPXS[i] - 1) * TP < ii then	
						KungfuString(WAR.Person[i]["特效文字3"], rx, ry, C_WHITE, CC.FontSmall5, CC.FontName, 1)
						KungfuString(WAR.Person[i]["特效文字2"], rx, ry, C_GOLD, CC.FontSmall5, CC.FontName, 2)
						KungfuString(WAR.Person[i]["特效文字1"], rx, ry, C_RED, CC.FontSmall5, CC.FontName, 3)
						KungfuString(WAR.Person[i]["特效文字0"], rx, ry, C_ORANGE, CC.FontSmall5, CC.FontName, 4)
						yanshi = true
					--end
				else
					--蓝烟清： 修正无动画时不显示文字的BUG
					if theeft == -1 and (WAR.Person[i]["特效文字0"] ~= nil or WAR.Person[i]["特效文字1"] ~= nil or WAR.Person[i]["特效文字2"] ~= nil or WAR.Person[i]["特效文字3"] ~= nil or WAR.Person[i]["特效文字4"] ~= nil) then	
						local dx = WAR.Person[i]["坐标X"] - x0
						local dy = WAR.Person[i]["坐标Y"] - y0
						local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
						local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
						local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)

						ry = ry - hb
						
						KungfuString(WAR.Person[i]["特效文字3"], rx, ry, C_WHITE, CC.FontSmall5, CC.FontName, 1)
						KungfuString(WAR.Person[i]["特效文字2"], rx, ry, C_GOLD, CC.FontSmall5, CC.FontName, 2)
						KungfuString(WAR.Person[i]["特效文字1"], rx, ry, C_RED, CC.FontSmall5, CC.FontName, 3)
						KungfuString(WAR.Person[i]["特效文字0"], rx, ry, C_ORANGE, CC.FontSmall5, CC.FontName, 4)
						yanshi2 = true
					end
				end
			end
		end
		ShowScreen()
		lib.Delay(CC.BattleDelay)
	end
	--lib.FreeSur(sssid)
	--Cls()	--显示点数前清空动画残影
	
	--郭襄的诸天化身步
	if WAR.ZTHSB == 1 then
		lib.SetWarMap(WAR.Person[WAR.ZT_id]["坐标X"], WAR.Person[WAR.ZT_id]["坐标Y"], 5, WAR.Person[WAR.ZT_id]["贴图"])
	end
  
	--无酒不欢：挨打时的掉血和状态显示
	if HitXYNum > 0 then
		local clips = {}
		for i = 0, HitXYNum - 1 do
			local dx = HitXY[i][1] - x0
			local dy = HitXY[i][2] - y0
			local hb = GetS(JY.SubScene, HitXY[i][1], HitXY[i][2], 4)		--海拔
		  
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
		
		local area = (clip.x2 - clip.x1) * (clip.y2 - clip.y1)		--绘画的范围
		--local surid = lib.SaveSur(minx, miny, maxx, maxy)		--绘画句柄
		
		Cat('实时特效动画')
	    local xs = false
		--显示点数
		--无酒不欢：一次显示两种状态
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
						--无酒不欢：这里用字符串的首位判定是否为掉血
						if y == 3 and HitXY[j][y] ~= nil and string.sub(HitXY[j][y],1,1) == "-" then
							if CONFIG.HPDisplay == 1 then
								HP_Display_When_Hit(i) --无酒不欢：实时显血
							end
							DrawString(clips[j].x1 - string.len(HitXY[j][y])*CC.DefaultFont/4, clips[j].y1 - y_off, HitXY[j][y], Color_Hurt1, CC.DefaultFont)
						else
							--无酒不欢：双排显示暂时这样写了
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
					Cat('实时特效动画')
				    ShowScreen()
					lib.Delay(CC.BattleDelay)
				end
			end
		end
	end
	
	--动画后恢复血条
	WAR.ShowHP = 1

	--清除点数
	for i = 0, HitXYNum - 1 do
		local id = GetWarMap(HitXY[i][1], HitXY[i][2], 2);
		WAR.Person[id]["生命点数"] = nil;
		WAR.Person[id]["内力点数"] = nil;
		WAR.Person[id]["体力点数"] = nil;
		WAR.Person[id]["中毒点数"] = nil;
		WAR.Person[id]["解毒点数"] = nil;
		WAR.Person[id]["内伤点数"] = nil;
		WAR.Person[id]["Life_Before_Hit"] = 0;
	end
  
	--清除特效文字
	for i = 0, WAR.PersonNum - 1 do
        local id = WAR.Person[i]["人物编号"]
		WAR.Person[i]["特效动画"] = -1
		WAR.Person[i]["特效文字0"] = nil
		WAR.Person[i]["特效文字1"] = nil
		WAR.Person[i]["特效文字2"] = nil
		WAR.Person[i]["特效文字3"] = nil
		WAR.Person[i]["特效文字4"] = nil
		WAR.Person[i]["闪避"] = false;
        WAR.Miss[id] = nil
	end
	lib.SetClip(0, 0, 0, 0)
	Cat('实时特效动画')
	WarDrawMap(0)
	ShowScreen()
	lib.Delay(CC.BattleDelay)
	CleanWarMap(11,0)
end


---执行医疗，解毒用毒暗器的子函数，自动医疗也可调用
function War_ExecuteMenu_Sub(x1, y1, flag, thingid)
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	local x0 = WAR.Person[WAR.CurID]["坐标X"]
	local y0 = WAR.Person[WAR.CurID]["坐标Y"]
	CleanWarMap(4, 0)
	WAR.ShowHP = 0
	WAR.Person[WAR.CurID]["人方向"] = War_Direct(x0, y0, x1, y1)
	SetWarMap(x1, y1, 4, 1)
	local emeny = GetWarMap(x1, y1, 2)
	if emeny >= 0 then
		if flag == 1 and WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[emeny]["我方"] then
			Cat('神游太虚2')
			if myzd(emeny) == false then
				WAR.Person[emeny]["中毒点数"] = War_PoisonHurt(pid, WAR.Person[emeny]["人物编号"])
			end
			SetWarMap(x1, y1, 4, 5)
			WAR.Effect = 5
		elseif flag == 2 and WAR.Person[WAR.CurID]["我方"] == WAR.Person[emeny]["我方"] then
			WAR.Person[emeny]["解毒点数"] = ExecDecPoison(pid, WAR.Person[emeny]["人物编号"])
			SetWarMap(x1, y1, 4, 6)
			WAR.Effect = 6
		elseif flag == 3 then
			--医生单独判定
			if WAR.Person[WAR.CurID]["人物编号"] == 0 and JY.Base["标准"] == 8 then
			  
			elseif WAR.Person[WAR.CurID]["我方"] == WAR.Person[emeny]["我方"] then
			  WAR.Person[emeny]["生命点数"] = ExecDoctor(pid, WAR.Person[emeny]["人物编号"])
			  SetWarMap(x1, y1, 4, 4)
			  WAR.Effect = 4
			end
		--暗器
		elseif flag == 4 and WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[emeny]["我方"] then
			Cat('神游太虚2')
			--葵花尊者反击暗器
			if  WAR.Person[emeny]["人物编号"] == 27 and match_ID(WAR.Person[WAR.CurID]["人物编号"],498) == false then
				CleanWarMap(4, 0)
				local orid = WAR.CurID
				WAR.CurID = emeny
				
				WAR.Person[WAR.CurID]["人方向"] = War_Direct(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], x0, y0)
				
				Cls()
				local KHZZ = {"无知的"..JY.Person[0]["外号2"],"竟然想班门弄斧","吃我的葵花神针"}
				
				for n = 1, #KHZZ + 25 do
					local i = n 
					if i > #KHZZ then 
						i = #KHZZ
					end
					lib.GetKey()
					Cat('实时特效动画')
					Cls()
					DrawString(-1, -1, KHZZ[i], C_GOLD, CC.Fontsmall)
					ShowScreen()
					lib.Delay(CC.BattleDelay)
				end
		
				SetWarMap(x0, y0, 4, 1)
				
				WAR.Person[orid]["生命点数"] = (WAR.Person[orid]["生命点数"] or 0) + AddPersonAttrib(WAR.Person[orid]["人物编号"], "生命", -300)
				if myzd(orid) == false then
					WAR.Person[orid]["中毒点数"] = (WAR.Person[orid]["中毒点数"] or 0) + AddPersonAttrib(WAR.Person[orid]["人物编号"], "中毒程度", 100)
				end
				WAR.TXXS[WAR.Person[orid]["人物编号"]] = 1
				
				WAR.KHSZ = 1
				
				War_ShowFight(WAR.Person[WAR.CurID]["人物编号"], 0, -1, 0, x0, y0, 35)
				
				WAR.KHSZ = 0
				
				WAR.CurID = orid
				return 1
			end	

		
			--独孤求败免疫暗器
			if match_ID(WAR.Person[emeny]["人物编号"],592) and  match_ID(WAR.Person[WAR.CurID]["人物编号"],498)==false  then
				local orid = WAR.CurID
				WAR.CurID = emeny
				Cls()
				CurIDTXDH(WAR.CurID, 137,1, "料敌先机·破针式", C_GOLD)
				WAR.CurID = orid
				return 1
			end	
			--免疫暗器
			if match_ID(WAR.Person[emeny]["人物编号"],9990) and  match_ID(WAR.Person[WAR.CurID]["人物编号"],498)==false  then
				local orid = WAR.CurID
				WAR.CurID = emeny
				Cls()
				WAR.CurID = orid
				return 1
			end	
			if not match_ID(pid, 83) then
				--暗器随机伤害倍数
				WAR.AQBS = math.random(3)
				--袁承志用金蛇锥必定三倍
				if (match_ID(pid, 54) and thingid == 30) or match_ID(pid, 498) then
					WAR.AQBS = 3
				end
				--夏雪宜用金蛇锥必定三倍
				if match_ID(pid, 639) and thingid == 30 then
					WAR.AQBS = math.random(5,7)
				end				
				--李寻欢暗器攻击倍数
				if  WAR.XLFD[pid] ~= nil  then
                    WAR.AQBS = math.random(5,8)
				end
				if  WAR.XLFD[pid] ~= nil  and JLSD(35, 55, pid) and JY.Person[0]["六如觉醒"] > 0  then
                    WAR.AQBS = math.random(10,12)	
				end
				
				WAR.Person[emeny]["生命点数"] = War_AnqiHurt(pid, WAR.Person[emeny]["人物编号"], thingid, emeny)
				SetWarMap(x1, y1, 4, 2)
				WAR.Effect = 2
			end
            if match_ID(pid, 721) then
                WAR.AQBS = 1
            end
		end
	end
			
	--主角医生方阵医疗
	if flag == 3 and pid == 0 and JY.Base["标准"] == 8 then
		for ex = x1 - 3, x1 + 3 do
			for ey = y1 - 3, y1 + 3 do
				SetWarMap(ex, ey, 4, 1)
				if GetWarMap(ex, ey, 2) ~= nil and GetWarMap(ex, ey, 2) > -1 then
					local ep = GetWarMap(ex, ey, 2)
					if WAR.Person[WAR.CurID]["我方"] == WAR.Person[ep]["我方"] then
						WAR.Person[ep]["生命点数"] = ExecDoctor(pid, WAR.Person[ep]["人物编号"])
						SetWarMap(ex, ey, 4, 4)
						WAR.Effect = 4
					end
				end        
			end
		end
	end
	--主角毒王方阵上毒，可以给自己上毒
	if flag == 1 and pid == 0 and JY.Base["标准"] == 9 then
		for ex = x1 - 3, x1 + 3 do
			for ey = y1 - 3, y1 + 3 do
				SetWarMap(ex, ey, 4, 1)
				if GetWarMap(ex, ey, 2) ~= nil and GetWarMap(ex, ey, 2) > -1 then
					local ep = GetWarMap(ex, ey, 2)
					if (WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[ep]["我方"]) or ep == WAR.CurID then
						if myzd(ep) == false then
							WAR.Person[ep]["中毒点数"] = War_PoisonHurt(pid, WAR.Person[ep]["人物编号"])
						end
						SetWarMap(ex, ey, 4, 5)
						WAR.Effect = 5
					end
				end        
			end
		end
	end

	--何铁手使用暗器为7*7方阵
	if flag == 4 and match_ID(pid, 83) then
		--暗器随机伤害倍数
		WAR.AQBS = math.random(3)
		for ex = x1 - 3, x1 + 3 do
			for ey = y1 - 3, y1 + 3 do
				SetWarMap(ex, ey, 4, 1)
				if GetWarMap(ex, ey, 2) ~= nil and GetWarMap(ex, ey, 2) > -1 then
					local ep = GetWarMap(ex, ey, 2)
					if WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[ep]["我方"] then
						WAR.Person[ep]["生命点数"] = War_AnqiHurt(pid, WAR.Person[ep]["人物编号"], thingid, ep)
						SetWarMap(ex, ey, 4, 4)
						WAR.Effect = 2
					end
				end
			end
		end
	end
	--李寻欢 小李飞刀使用暗器为3*3方阵
	if flag == 4 and match_ID(pid,498) and  JY.Base["天书数量"] > 5 then
		for ex = x1 - 3, x1 + 3 do
			for ey = y1 - 3, y1 + 3 do
				SetWarMap(ex, ey, 4, 1)
				if GetWarMap(ex, ey, 2) ~= nil and GetWarMap(ex, ey, 2) > -1 then
					local ep = GetWarMap(ex, ey, 2)
					if WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[ep]["我方"] then
						WAR.Person[ep]["生命点数"] = War_AnqiHurt(pid, WAR.Person[ep]["人物编号"], thingid, ep)
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

	
		--暗器随机伤害倍数	
	--for i = 0, WAR.PersonNum - 1 do
		--WAR.Person[i]["点数"] = 0
	--end
	if flag == 4 then
		if emeny >= 0 or match_ID(pid, 83) then
			instruct_32(thingid, -1)
			--张家辉的隐身戒指
			if JY.Person[pid]["防具"] == 304 then
				local cd = 40
				if JY.Thing[304]["装备等级"] >=5 then
					cd = 20
				elseif JY.Thing[304]["装备等级"] >=3 then
					cd = 30
				end
				WAR.YSJZ = cd
			end
			return 1
		else
			return 0
		end
	else
		WAR.Person[WAR.CurID]["经验"] = WAR.Person[WAR.CurID]["经验"] + 1
		AddPersonAttrib(pid, "体力", -2)
	end
  
	if inteam(pid) then
		AddPersonAttrib(pid, "体力", -4)
	end
	return 1
end


--无酒不欢：挨打后，绘画动态集气条的判定
function DrawTimeBar2()
	local x1,x2,y = CC.ScreenW * 1 / 2 - 34, CC.ScreenW * 19 / 20 - 2, CC.ScreenH/10 + 29
	local draw = false
	
	--这三个是固定的，只需要加载一次就可以了
	--无酒不欢：这里也要判定是否有需要draw，如无需要则不加载
	local drawframe = false
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["死亡"] == false then
			if WAR.Person[i].TimeAdd ~= 0 then
				drawframe =  true
				break
			end
		end
	end
	if drawframe == true then
		DrawString(x2 + 10-410, y - 60-25, "时序", C_WHITE, CC.DefaultFont*0.8)	
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
			local pid = WAR.Person[i]["人物编号"];
			--首先判定人物是否活着
			if WAR.Person[i]["死亡"] == false then
                if Curr_NG(pid, 227) and WAR.Defup[pid] ~= nil and WAR.Defup[pid] > 0 then 
                    if WAR.Person[i].TimeAdd < 0 then 
                        WAR.Person[i].TimeAdd = 0
                    end
                end
				--这里TimeAdd小于0代表集气位置要减少，数值为减少总量
				if WAR.Person[i].TimeAdd < 0 then
					draw = true
					--减量以20为单位循环增加，增加到超过0时，判定将不再成立，既停止减少集气位置
					WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd + 20
					if WAR.Person[i].TimeAdd > 0 then
						WAR.Person[i].TimeAdd = 0;
					end					
					--如果人物的集气位置没有达到-500，则减少20，向-500靠近
					if WAR.Person[i].Time > -500 then
						--如果主运瑜伽，则不会低于300
						--李寻欢
						if Curr_NG(pid, 169)  or match_ID(pid,498) then
							if WAR.Person[i].Time > 300 then
								WAR.Person[i].Time = WAR.Person[i].Time - 20
								if WAR.Person[i].Time <= 300 then
									WAR.Person[i].Time = 300
									WAR.Person[i].TimeAdd = 0
								end
							end
						--被动瑜伽，不低于0 or ShuangJianHB(pid)
						elseif PersonKF(pid, 169) or match_ID(pid,581)  then
							if WAR.Person[i].Time > 0 then
								WAR.Person[i].Time = WAR.Person[i].Time - 20
								if WAR.Person[i].Time <= 0 then
									WAR.Person[i].Time = 0
									WAR.Person[i].TimeAdd = 0
								end
							end
						--双剑合壁杀气不会低于-100  
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
					--如果人物的集气位置已经达到-500，则集气位置不再减少，而是转换为内伤
					else
						for k = 0,-WAR.Person[i].TimeAdd,20 do
							if JY.Person[pid]["受伤程度"] < 100 then
								AddPersonAttrib(pid, "受伤程度", math.random(3))
							else 
								WAR.Person[i].TimeAdd = 0
								break
							end
						end	
						WAR.Person[i].TimeAdd = 0
					end
					if WAR.Person[i].Time <= -500 and PersonKF(pid, 100) then	--练了先天功后，当集气被杀到-500，内伤直接清0
						JY.Person[pid]["受伤程度"] = 0;	
					end						
				--大于0代表集气位置要增加，
				elseif WAR.Person[i].TimeAdd > 0 then
					draw = true
					--增量以20为单位循环减少，减少到低于0时，判定将不再成立，既停止增加集气位置
					WAR.Person[i].TimeAdd = WAR.Person[i].TimeAdd - 20
					--人物的集气位置以20为单位增加，如果集气位置超过995，则强制定为995
					WAR.Person[i].Time = WAR.Person[i].Time + 20
					if WAR.Person[i].Time > 995 then
						WAR.Person[i].Time = 995;
						WAR.Person[i].TimeAdd = 0
					end
				end
			end
		end
		
		if draw then		 
			Cat('实时特效动画')
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
			Cat('实时特效动画')
			Cls()
			DrawTimeBar_sub()
			ShowScreen()
			lib.Delay(CC.BattleDelay)
		end
	end
end

--绘制集气条
function DrawTimeBar()
	
	--local x1,x2,y = CC.ScreenW * 1 / 2 - 34, CC.ScreenW * 19 / 20 - 2, CC.ScreenH/10 + 29
	local xunhuan = true
    
	--local xh = 0
    local jqwz = 0
	local atid = -1
	if WAR.ATK['人物'] ~= nil then
		atid = WAR.ATK['人物']
		WAR.ATK['人物'] = nil
		goto label1
	end
    WAR.ZYHB = 0
    
	if #WAR.ATK['人物table'] > 0 then
		atid = WAR.ATK['人物table'][#WAR.ATK['人物table']]
		local id = WAR.Person[atid]['人物编号']
		table.remove(WAR.ATK['人物table'],#WAR.ATK['人物table'])
		WAR.ATK['人物pd'][id] = nil
		if #WAR.ATK['人物table'] == 0 then 
			WAR.ATK['人物table'] = {}
		end
		goto label1
	end
    
	while xunhuan do
		if JY.Restart == 1 then
			break
		end
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["死亡"] == false then
				local jqid = WAR.Person[i]["人物编号"]
				local jq = WAR.Person[i].TimeAdd	--人物集气速度
				--无酒不欢：每25点内伤-1集气，每25点中毒-1集气，玩家与NPC一样
				local ns_factor = math.modf(JY.Person[jqid]["受伤程度"] / 25)
				local zd_factor = math.modf(JY.Person[jqid]["中毒程度"] / 25)
				--毒王中毒反而增加集气
				if jqid == 0 and JY.Base["标准"] == 9 then
					zd_factor = -(zd_factor*2)
				end
				--冰封也减少
				local bf_factor = 0;
				if JY.Person[jqid]["冰封程度"] >= 50 then
					bf_factor = 6
				elseif JY.Person[jqid]["冰封程度"] > 0 then
					bf_factor = 3
				end
				--何太冲的铁琴减少集气，一层减少1%
				local HTC_tq = 0
				if WAR.QYZT[jqid] ~= nil then
					HTC_tq = jq * 0.015 * WAR.QYZT[jqid]
				end
                local chzt_jq = 0
				--迟缓减少集气，一层减少1%
				if WAR.CHZT[jqid] ~= nil then
					chzt_jq = jq * 0.01 * WAR.CHZT[jqid]
				end
				local hsv_jq = 0
				 --黄衫女 疾风增另集气 一层增加1.25%
				if WAR.JFJQ[jqid] ~= nil then
					hsv_jq = jq * (-0.0125) * WAR.JFJQ[jqid]
				end					
				--李秋水集气不受状态影响
				--一苇渡江
				
				if match_ID(jqid, 118) or  match_ID(jqid, 579) or (match_ID(jqid, 629) and WAR.LQZ[jqid] == 100) or PersonKF(jqid,186) then
				
				else
					jq = jq - ns_factor - zd_factor - bf_factor - HTC_tq - chzt_jq - hsv_jq
				end
				
				if jq < 0 then
					jq = 0
				end
				if WAR.LQZ[jqid] == 100 then
					if Curr_QG(jqid,150) then	--运功瞬息千里，暴怒4倍集气
						jq = jq * 4
					else
						jq = jq * 3				--暴怒3倍集气
					end
				end
				--沉睡的敌人，无法集气
				if WAR.CSZT[jqid] == 1 then
					jq = 0
				--被无招胜有招击中的人，无法集气
				elseif WAR.WZSYZ[jqid] ~= nil then
					jq = 0
					WAR.WZSYZ[jqid] = WAR.WZSYZ[jqid] - 1
					if WAR.WZSYZ[jqid] < 1 then
						WAR.WZSYZ[jqid] = nil
					end
				--冻结的敌人，无法集气				
				elseif WAR.LRHF[jqid] ~= nil then
					jq = 0
					WAR.LRHF[jqid] = WAR.LRHF[jqid] - 1
					if WAR.LRHF[jqid] < 1 then
						WAR.LRHF[jqid] = nil
					end
				--梁萧 谐之道击中的敌人，无法集气				
				elseif WAR.XZD[jqid] ~= nil then
					jq = 0
					WAR.XZD[jqid] = WAR.XZD[jqid] - 1
					if WAR.XZD[jqid] < 1 then
						WAR.XZD[jqid] = nil
					end					
				--没有封穴的情况下，可以集气
				elseif WAR.FXDS[jqid] == nil then
				    --
					--欧阳锋会跳气
					if match_ID(jqid, 60) and JLSD(0,20,jqid) then
						jq = jq + math.random(30, 60);
					end
                    
					--蛇行狸翻跳气
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
                    
					--丁当会跳气
					if match_ID(jqid, 581) and JLSD(0,20,jqid) then
                        local a = math.random(10, 30);
                        if WAR.LQZ[jqid] == 100 then 
                            a = a*3
                        end
                        jq = jq + a
					end		
			
					if WAR.LSQ[jqid] ~= nil then	--被灵蛇拳击中，集气波动20时序
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
                    
				--被封穴的话，不会集气，时序减少封穴
				else
					WAR.FXDS[jqid] = WAR.FXDS[jqid] - 1
			  
					--易筋经 封穴回复+1
					if PersonKF(jqid, 108) or Curr_NG(jqid,184)then
						WAR.FXDS[jqid] = WAR.FXDS[jqid] - 1
					end
					
					--先天+玉女，封穴回复+1
					if PersonKF(jqid, 100) and PersonKF(jqid, 154) then
						WAR.FXDS[jqid] = WAR.FXDS[jqid] - 1
					end

					--九阳5时序解除封穴
					--阳内主运或者阳罡学会九阳后
					if Curr_NG(jqid, 106) and (JY.Person[jqid]["内力性质"] == 1 or JY.Person[jqid]["内力性质"] == 3) then
						if WAR.JYFX[jqid] == nil then
							WAR.JYFX[jqid] = 1;
						elseif WAR.JYFX[jqid] < 5 then
							WAR.JYFX[jqid] = WAR.JYFX[jqid] + 1;
						else
							WAR.JYFX[jqid] = nil;
							WAR.FXDS[jqid] = 0;
						end
					end
					
					--暴怒时解穴速度加倍
					if WAR.LQZ[jqid] == 100 then
						WAR.FXDS[jqid] = WAR.FXDS[jqid] - 1
					end
					if WAR.FXDS[WAR.Person[i]["人物编号"]] < 1 then
						WAR.FXDS[WAR.Person[i]["人物编号"]] = nil
					end
				end  
				
				
				if PersonKF(jqid,199) then
					WAR.WMYS[jqid]=1
                end
				
				--文泰来计时状态
				if match_ID(jqid,151) and WAR.WTL_1[jqid] == nil then
					WAR.WTL_1[jqid] = 100
				end	
				----------------------------------生命内力体力回复-----------------------------------
			if  WAR.PD['创伤'][jqid] ~= nil then	
				--九阳神功回内
				--学会九阳并且是阳内或者天罡
				if PersonKF(jqid, 106) and (JY.Person[jqid]["内力性质"] == 1 or JY.Person[jqid]["内力性质"] == 3)  then
					--JY.Person[jqid]["内力"] = JY.Person[jqid]["内力"] + 9
					AddPersonAttrib(jqid,'内力',9)
				end

				--九阴神功回血
				--学会九阴并且是阴内或者天罡
				if PersonKF(jqid, 107)and (JY.Person[jqid]["内力性质"] == 0  or JY.Person[jqid]["内力性质"] == 3)then
					--JY.Person[jqid]["生命"] = JY.Person[jqid]["生命"] + 2
					AddPersonAttrib(jqid,'生命',2)
				end	
			
		        --九宵仙息
                if PersonKF(jqid, 184) then
					AddPersonAttrib(jqid,'生命',2)
					AddPersonAttrib(jqid,'内力',5)
					AddPersonAttrib(jqid,'体力',1)
				end
				
		        --阴阳无极功
                if Curr_NG(jqid, 221) then
					AddPersonAttrib(jqid,'生命',2)
					AddPersonAttrib(jqid,'内力',5)
				end
				
				--太虚剑意回血
				if PersonKF(jqid, 152) then
					--JY.Person[jqid]["生命"] = JY.Person[jqid]["生命"] + 2
					AddPersonAttrib(jqid,'生命',2)
				end
				
				--鲸息功回复内力
				if PersonKF(jqid, 180) then
					--JY.Person[jqid]["内力"] = JY.Person[jqid]["内力"] + 5
					AddPersonAttrib(jqid,'内力',5)
				end	
				
				--不老长春功回血
				if Curr_NG(jqid, 183) then
					--JY.Person[jqid]["生命"] = JY.Person[jqid]["生命"] + 5
					AddPersonAttrib(jqid,'生命',4)
				elseif PersonKF(jqid, 183) then
					AddPersonAttrib(jqid,'生命',2)
				end	
				
				--长生诀回血
				if Curr_NG(jqid, 203) then
					--JY.Person[jqid]["生命"] = JY.Person[jqid]["生命"] + 5
					AddPersonAttrib(jqid,'生命',5)
				elseif PersonKF(jqid, 203) then
					AddPersonAttrib(jqid,'生命',2)
				end	
			
				--九阴额外回血
				--阴内主运或者阴罡学会九阴后
				if inteam(jqid) then
					if Curr_NG(jqid, 107) and (JY.Person[jqid]["内力性质"] == 0 or JY.Person[jqid]["内力性质"] == 3) then
						--JY.Person[jqid]["生命"] = JY.Person[jqid]["生命"] + 2
						AddPersonAttrib(jqid,'生命',2)
					end
				end	
				
                if Curr_NG(jqid,227) then
                    AddPersonAttrib(jqid,'生命',2)
                end
                
				--先天功回血回内  --丘处机回复加倍
				--忘情天书回血回内
				if PersonKF(jqid, 100) or  PersonKF(jqid, 177) then
					if match_ID(jqid,68) then 
						AddPersonAttrib(jqid,'内力',8)
						AddPersonAttrib(jqid,'生命',4)
					else 
						AddPersonAttrib(jqid,'内力',4)
						AddPersonAttrib(jqid,'生命',2)
					end
				end
				--易筋经回内
				if PersonKF(jqid, 108) then
					AddPersonAttrib(jqid,'内力',6)
				end
				--太虚剑意回内
				if PersonKF(jqid, 152) then
					AddPersonAttrib(jqid,'内力',4)
				end				

                if WAR.PD['天香续命'][jqid] ~= nil then 
                    local sm = 2 
                    if JY.Person[jqid]['实战'] >= 500 then 
                        sm = 4
                    end
                    AddPersonAttrib(jqid,'生命',sm)
                    WAR.PD['天香续命'][jqid] = WAR.PD['天香续命'][jqid] - 1
                    if WAR.PD['天香续命'][jqid] < 1 then 
                        WAR.PD['天香续命'][jqid] = nil   
                    end
                end
                
                if WAR.PD['白云熊胆'][jqid] ~= nil then 
                    AddPersonAttrib(jqid,'内力',8)
                    WAR.PD['白云熊胆'][jqid] = WAR.PD['白云熊胆'][jqid] - 1
                    if WAR.PD['白云熊胆'][jqid] < 1 then 
                        WAR.PD['白云熊胆'][jqid] = nil   
                    end
                end
                
				--大周天回复
				if WAR.ZTHF[jqid] ~=nil then
					AddPersonAttrib(jqid,'生命',2)
					AddPersonAttrib(jqid,'内力',4)			
					JY.Person[jqid]["受伤程度"] = 0;
				end
				
				--主角医生回血内，减内伤，减中毒
				if jqid == 0 and JY.Base["标准"] == 8 then
					AddPersonAttrib(jqid,'生命',math.random(10))
					AddPersonAttrib(jqid,'内力',math.random(10))
					AddPersonAttrib(jqid,'中毒程度',-math.random(10))
					AddPersonAttrib(jqid,'受伤程度',-math.random(10))
				end				
				--毒王时序增加中毒
				if jqid == 0 and JY.Base["标准"] == 9 then
					AddPersonAttrib(jqid,'中毒程度',math.random(10))
				end
                ----------------------------------流血回复-----------------------------------
				--每时序回复1点流血
				if WAR.LXZT[jqid] ~= nil then
					JY.Person[jqid]["生命"] = JY.Person[jqid]["生命"] - 2 - math.modf(JY.Person[jqid]["受伤程度"] / 50)
					if JY.Person[jqid]["生命"] < 1 then
						JY.Person[jqid]["生命"] = 1
					end
					WAR.LXZT[jqid] = WAR.LXZT[jqid] - 1
                
					--主运乾坤，罗汉额外恢复流血
					--忘情天书
					if Curr_NG(jqid, 97) or Curr_NG(jqid, 96) or Curr_NG(jqid, 177) then
						WAR.LXZT[jqid] = WAR.LXZT[jqid] - 1
					end
					if JY.Person[jqid]["坐骑"] == 262 or PersonKF(jqid,204) and WAR.LXZT[jqid] ~= nil then 
						WAR.LXZT[jqid] = WAR.LXZT[jqid] - 2
					end					  
					if WAR.LXZT[jqid] < 1 then
						WAR.LXZT[jqid] = nil
					end
				end
				----------------------------------冰封回复-----------------------------------
                if JY.Person[jqid]["冰封程度"] > 0 and JY.Person[jqid]["灼烧程度"] > 0 then
                    AddPersonAttrib(jqid,'生命',-math.random(2,5))
                    AddPersonAttrib(jqid,'内力',-math.random(2,5))
                end
                
				--每时序回复1点冰封
				if JY.Person[jqid]["冰封程度"] > 0 then
					--每时序-5内
					AddPersonAttrib(jqid,'内力',-5)
					
					--深度冰封每时序-15内
					if JY.Person[jqid]["冰封程度"] >= 50 then
						AddPersonAttrib(jqid,'内力',-10)
					end
					AddPersonAttrib(jqid,'冰封程度',-1)
					
					--主运纯阳，九阳额外恢复冰封
					if Curr_NG(jqid, 99) or Curr_NG(jqid, 106) then
						AddPersonAttrib(jqid,'冰封程度',-1)
					end				
					
					--阴阳无极功
					if Curr_NG(jqid, 221) then
						AddPersonAttrib(jqid,'冰封程度',-2)
					end
				end
				----------------------------------灼烧回复-----------------------------------
				--每时序回复1点灼烧
				if JY.Person[jqid]["灼烧程度"] > 0 then
					--JY.Person[jqid]["灼烧程度"] = JY.Person[jqid]["灼烧程度"] - 1
					AddPersonAttrib(jqid,'灼烧程度',-1)
					--主运九阴额外恢复灼烧
					if Curr_NG(jqid, 107)  and (JY.Person[jqid]["内力性质"] == 0 or JY.Person[jqid]["内力性质"] == 3)  then
						AddPersonAttrib(jqid,'灼烧程度',-1)
					end
					--枯荣额外恢复灼烧
					if match_ID(jqid, 102) then
						AddPersonAttrib(jqid,'灼烧程度',-1)
					end
					
					--不老长春功
					if PersonKF(jqid, 183) then
						AddPersonAttrib(jqid,'灼烧程度',-1)
					end		

					--阴阳无极功
					if Curr_NG(jqid, 221) then
						AddPersonAttrib(jqid,'灼烧程度',-2)
					end
				end
				----------------------------------内伤回复-----------------------------------
                --无酒不欢：时序回复内伤的设定
                if JY.Person[jqid]["受伤程度"] > 0 then
                        --3时序回1内伤的判定
                        --紫霞，逆运，九阴，金刚，九阳，化功，吸星，北冥，太玄，易筋经，玉女心经，瑜伽密乘，混元 葵花,太虚剑意，鲸息功，不老长春功 太极神功
                        --萧半和，黄衫
                    if Curr_NG(jqid, 89) or Curr_NG(jqid, 105)or Curr_NG(jqid, 104) or Curr_NG(jqid, 107) or Curr_NG(jqid, 144) or Curr_NG(jqid, 106) 
                        or Curr_NG(jqid, 87) or Curr_NG(jqid, 88) or Curr_NG(jqid, 85) or Curr_NG(jqid, 102) or Curr_NG(jqid, 108) 
                        or Curr_NG(jqid, 154) or Curr_NG(jqid, 169) or Curr_NG(jqid, 90) or Curr_NG(jqid, 152) or Curr_NG(jqid, 180)
                        or Curr_NG(jqid, 183) or Curr_NG(jqid, 171) or Curr_NG(jqid, 184) then
                        if WAR.SSX_Counter == 3 then
                            AddPersonAttrib(jqid,'受伤程度',-1)
                        end
                    end

                    --5时序回1内伤的判定
                    --圣火，葵花，八荒，先天，蛤蟆，龙象，小无，血河 忘情,寒冰真气
                    if Curr_NG(jqid, 93)  or Curr_NG(jqid, 101) or Curr_NG(jqid, 100) 
                        or Curr_NG(jqid, 95) or Curr_NG(jqid, 103) or Curr_NG(jqid, 98) or Curr_NG(jqid, 163) or Curr_NG(jqid, 177) 
                        or Curr_NG(jqid, 190) or Curr_NG(jqid,216) or Curr_NG(jqid,227) then
                        if WAR.WSX_Counter == 5 then
                            --JY.Person[jqid]["受伤程度"] = JY.Person[jqid]["受伤程度"] - 1
                            AddPersonAttrib(jqid,'受伤程度',-1)
                        end
                    end
                        
                    --阴阳无极功
                    if Curr_NG(jqid, 221) then
                        if WAR.SSX_Counter == 3 then
                            --JY.Person[jqid]["受伤程度"] = JY.Person[jqid]["受伤程度"] - 1
                            AddPersonAttrib(jqid,'受伤程度',-1)
                        end
                    end
                        
                        -- 初阶内功回复5时序回1内伤
                    for i = 208,220 do
                        if Curr_NG(jqid,i) then
                            if WAR.WSX_Counter == 5 then
                                AddPersonAttrib(jqid,'受伤程度',-1)
                            end
                        end	
                    end	
                        --主运天赋内功，5时序额外回1内伤
                    if JY.Person[jqid]["主运内功"] ~= 0 and JY.Person[jqid]["主运内功"] == JY.Person[jqid]["天赋内功"] then
                        if WAR.WSX_Counter == 5 then
                            --JY.Person[jqid]["受伤程度"] = JY.Person[jqid]["受伤程度"] - 1
                            AddPersonAttrib(jqid,'受伤程度',-1)
                        end
                    end
                        
                    --主运三神功内伤大于50时，额外回复
                    if JY.Person[jqid]["受伤程度"] > 50 and (Curr_NG(jqid, 106) or Curr_NG(jqid, 107) or Curr_NG(jqid, 108)) then
                        if WAR.SSX_Counter == 3 then
                            --JY.Person[jqid]["受伤程度"] = JY.Person[jqid]["受伤程度"] - 1
                            AddPersonAttrib(jqid,'受伤程度',-1)
                        end
                    end
                        
                end
                    
                if WAR.PD['小还丹'][jqid] ~= nil then 
                    AddPersonAttrib(jqid,'受伤程度',-1)
                    WAR.PD['小还丹'][jqid] = WAR.PD['小还丹'][jqid] - 1
                    if WAR.PD['小还丹'][jqid] < 1 then 
                        WAR.PD['小还丹'][jqid] = nil   
                    end
                end
                ----------------------------------中毒回复-----------------------------------
                    --纯阳，九阳，逆运，易筋经每时序回复1点中毒
                if JY.Person[jqid]["中毒程度"] > 0 and (Curr_NG(jqid, 99) or Curr_NG(jqid, 106) or Curr_NG(jqid, 104) or Curr_NG(jqid, 108)) then	
                    AddPersonAttrib(jqid,'中毒程度',-1)
                end
                    
                    --任盈盈，每时序回复5点中毒
                if match_ID(jqid,73) then	
                    AddPersonAttrib(jqid,'中毒程度',-5)
                end
                        
                if WAR.PD['黄连解毒'][jqid] ~= nil then 
                    AddPersonAttrib(jqid,'中毒程度',-1)
                    WAR.PD['黄连解毒'][jqid] = WAR.PD['黄连解毒'][jqid] - 1
                    if WAR.PD['黄连解毒'][jqid] < 1 then 
                        WAR.PD['黄连解毒'][jqid] = nil   
                    end
                end
                
                if WAR.PD['牛黄血蝎'][jqid] ~= nil then 
                    AddPersonAttrib(jqid,'中毒程度',-1)
                    WAR.PD['牛黄血蝎'][jqid] = WAR.PD['牛黄血蝎'][jqid] - 1
                    if WAR.PD['牛黄血蝎'][jqid] < 1 then 
                        WAR.PD['牛黄血蝎'][jqid] = nil   
                    end
                end
                ----------------------------------体力回复-----------------------------------
                    --回复体力
                if JY.Person[jqid]["体力"] < 100 then
                    --主运混元，3时序回1体力 
                    --萧半和
                    if Curr_NG(jqid, 90) or (jqid == 0 and JY.Base["畅想"] == 189) then
                        if WAR.SSX_Counter == 3 then
                            AddPersonAttrib(jqid,'体力',1)
                        end
                    --被动混元，6时序回1体力
                    elseif PersonKF(jqid, 90) then
                        if WAR.LSX_Counter == 6 then
                            AddPersonAttrib(jqid,'体力',1)
                        end
                    end
                    --主运九阴，逆运，6时序回1体力 
                    if (Curr_NG(jqid, 107)  or Curr_NG(jqid, 104)) and (JY.Person[jqid]["内力性质"] == 0 or JY.Person[jqid]["内力性质"] == 3)  then
                        if WAR.LSX_Counter == 6 then
                            AddPersonAttrib(jqid,'体力',1)
                        end
                    end
				end
			end	
                ----------------------------------时序掉血-----------------------------------    
                --阿紫曼珠沙华，每时序掉1%血
                if match_ID(jqid, 47) and WAR.JYZT[jqid]~=nil then
                    AddPersonAttrib(jqid,'生命',-math.modf(JY.Person[jqid]["生命最大值"]*0.01))
                    if JY.Person[jqid]["生命"] < 1 then
                        JY.Person[jqid]["生命"] = 0
                        WAR.Person[WAR.CurID]["死亡"] = true
                        WarSetPerson()
                        
                        break
                    end
                end               
                --引燃：每时序损失2%当前血量
                if WAR.JHLY[jqid] ~= nil then
                    AddPersonAttrib(jqid,'生命',-math.modf(JY.Person[jqid]["生命"]*0.02))
                    
                    if JY.Person[jqid]["生命"] < 1 then
                        JY.Person[jqid]["生命"] = 1
                    end
                    WAR.JHLY[jqid] = WAR.JHLY[jqid] - 1
                    
                    if WAR.JHLY[jqid] < 1 then
                        WAR.JHLY[jqid] = nil
                    end
				end
                --创伤：每时序损失0.5%最大值血量
                if WAR.PD['创伤'][jqid] ~= nil then
                    AddPersonAttrib(jqid,'生命',-math.modf(JY.Person[jqid]["生命最大值"]*5/1000))
                    
                    if JY.Person[jqid]["生命"] < 1 then
                        JY.Person[jqid]["生命"] = 1
                    end
					WAR.PD['创伤'][jqid] = WAR.PD['创伤'][jqid] - 1
                    
                    if WAR.PD['创伤'][jqid] < 1 then
                        WAR.PD['创伤'][jqid] = nil
                    end
				end	
				----------------------------------时序掉内-----------------------------------    			
                --散功：每时序损失1%当前内力
                if WAR.SGZT[jqid] ~= nil then
                    AddPersonAttrib(jqid,'内力',-math.modf(JY.Person[jqid]["内力"]*0.01))
                    if JY.Person[jqid]["内力"] < 1 then
                        JY.Person[jqid]["内力"] = 1
                    end	
                    WAR.SGZT[jqid] = WAR.SGZT[jqid] - 1
                    if WAR.SGZT[jqid] < 1 then
                        WAR.SGZT[jqid] = nil
                    end
				end					
				--[[
            ['八酒杯'] = {},
            ['梨花酒'] = {},
            ['玉露酒'] = {},
            ['即墨老酒'] = {},
            ['白云熊胆'] = {},
            ['天香续命'] = {},
            ['小还丹'] = {},
            ['黄连解毒'] = {},
            ['牛黄血蝎'] = {},
            ['六阳正气'] = {},
            ]]
            
                if WAR.PD['梨花酒'][jqid] ~= nil then 
                    AddPersonAttrib(jqid,'冰封程度',-1)
                    WAR.PD['梨花酒'][jqid] = WAR.PD['梨花酒'][jqid] - 1
                    if WAR.PD['梨花酒'][jqid] < 1 then 
                        WAR.PD['梨花酒'][jqid] = nil   
                    end
                end
                
                if WAR.PD['玉露酒'][jqid] ~= nil then 
                    AddPersonAttrib(jqid,'灼烧程度',-1)
                    WAR.PD['玉露酒'][jqid] = WAR.PD['玉露酒'][jqid] - 1
                    if WAR.PD['玉露酒'][jqid] < 1 then 
                        WAR.PD['玉露酒'][jqid] = nil   
                    end
                end
                if WAR.PD['五宝花蜜酒'][jqid] ~= nil then 
                    WAR.PD['五宝花蜜酒'][jqid] = WAR.PD['五宝花蜜酒'][jqid] - 1
                    if WAR.PD['五宝花蜜酒'][jqid] < 1 then 
                        WAR.PD['五宝花蜜酒'][jqid] = nil   
                    end
                end                
                if WAR.PD['即墨老酒'][jqid] ~= nil then
                    if WAR.LXZT[jqid] ~= nil then
                        WAR.LXZT[jqid] = WAR.LXZT[jqid] - 1
                        if WAR.LXZT[jqid] < 1 then 
                            WAR.LXZT[jqid] = nil
                        end
                    end
                    WAR.PD['即墨老酒'][jqid] = WAR.PD['即墨老酒'][jqid] - 1
                    if WAR.PD['即墨老酒'][jqid] < 1 then 
                        WAR.PD['即墨老酒'][jqid] = nil   
                    end
                end

 				--灭绝的玉石俱焚，100时序
				if WAR.YSJF[jqid] ~= nil then
					WAR.YSJF[jqid] = WAR.YSJF[jqid] - 1
					
					if WAR.YSJF[jqid] < 1 then
						WAR.YSJF[jqid] = nil
					end
				end
				--李寻欢小李飞刀状态，
				if WAR.XLFD[jqid] ~= nil then
					WAR.XLFD[jqid] = WAR.XLFD[jqid] - 1
					
					if WAR.XLFD[jqid] < 1 then
						WAR.XLFD[jqid] = nil
					end
				end		
				--惊天一剑状态
				if WAR.JTYJ[jqid] ~= nil then
					WAR.JTYJ[jqid] = WAR.JTYJ[jqid] - 1
					
					if WAR.JTYJ[jqid] < 1 then
						WAR.JTYJ[jqid] = nil
					end
				end					
	
				if WAR.PD['西瓜刀·残刀'][jqid] ~= nil then 
                    if WAR.PD['西瓜刀·残刀'][jqid][2] ~= nil and WAR.PD['西瓜刀·残刀'][jqid][2] > 0 then 
                        WAR.PD['西瓜刀·残刀'][jqid][2] = WAR.PD['西瓜刀·残刀'][jqid][2] - 1
                        if WAR.PD['西瓜刀·残刀'][jqid][2] < 1 then 
                            WAR.PD['西瓜刀·残刀'][jqid] = nil
                        end
                    end
                end
                
				--虚弱状态 
				if WAR.XRZT[jqid] ~= nil then
					WAR.XRZT[jqid] = WAR.XRZT[jqid] - 1
					if WAR.XRZT[jqid] < 1 then
						WAR.XRZT[jqid] = nil
					end
				end		
                --先天护盾
				if WAR.PD["先天护盾CD"][jqid] ~= nil and WAR.PD["先天护盾"][jqid] == nil then
					WAR.PD["先天护盾CD"][jqid] = WAR.PD["先天护盾CD"][jqid] -1
					if WAR.PD["先天护盾CD"][jqid] < 1 then
						WAR.PD["先天护盾CD"][jqid] = nil
					end
                end	
				--无酒不欢：主运蛤蟆功 鲸息功时序增加怒气
				--胡一刀觉醒
				if Curr_NG(jqid, 95) or match_ID_awakened(jqid,633,1) or Curr_NG(jqid, 180)then
					if WAR.LQZ[jqid] == nil then
						WAR.LQZ[jqid] = 1
					elseif WAR.LQZ[jqid] < 100 then
						WAR.LQZ[jqid] = WAR.LQZ[jqid] + 1
						if WAR.LQZ[jqid] == 100 then
							--东方不败，葵花秘法·化凤为凰
							local s = WAR.CurID
							local say = "怒气爆发"
							local ani_num = 6
							WAR.CurID = i
							if match_ID(jqid, 27) then
								say = "葵花秘法·化凤为凰"
								ani_num = 7
							end
							if match_ID(jqid, 568) then
								say = "精忠报国"
								ani_num = 8
							end	
							WarDrawMap(0)

							CurIDTXDH(WAR.CurID, ani_num, 1, say)

						end
					end
				end
					
				--无酒不欢：萧远山时序增加怒气
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

							CurIDTXDH(WAR.CurID, 6, 1, "怒气爆发")

						end
					end
				end
			--文泰来，血量少于一半时，+2点时序怒气
	            if match_ID(jqid, 151)  then
					if WAR.LQZ[jqid] == nil then
                        WAR.LQZ[jqid] = 1
					elseif WAR.LQZ[jqid] < 100 then
                        WAR.LQZ[jqid] = WAR.LQZ[jqid] + 1
                        if JY.Person[jqid]["生命"] < JY.Person[jqid]["生命最大值"] *0.5 then
                            WAR.LQZ[jqid] = WAR.LQZ[jqid] + 1					
                            if WAR.LQZ[jqid] >= 100 then
                                WAR.LQZ[jqid] = 100
                                local s = WAR.CurID
                                WAR.CurID = i

                                WarDrawMap(0)

                                CurIDTXDH(WAR.CurID, 6, 1, "怒气爆发")

                            end
                        end
                    end
                end
                
               -- 梅长苏 偷天换日
                 if match_ID(jqid,507)   then
                    if WAR.PD["偷天换日"][jqid] == nil then
                        WAR.PD["偷天换日"][jqid] = 1
                    else
                        WAR.PD["偷天换日"][jqid] = WAR.PD["偷天换日"][jqid] + 1
                    end	
                    if WAR.PD["偷天换日"][jqid] >= 100 and JY.Person[jqid]["冰封程度"] == 0 and JY.Person[jqid]["灼烧程度"] == 0 then
                       WAR.PD["偷天换日"][jqid] = nil	
                       WAR.ZSXS[jqid] = 1
                       AddPersonAttrib(jqid,'灼烧程度',50)
                       WAR.BFXS[jqid] = 1										
                      AddPersonAttrib(jqid,'冰封程度',100)
                       local s = WAR.CurID
                       WAR.CurID = i
                       WarDrawMap(0)
                       CurIDTXDH(WAR.CurID, 104, 1, "火寒毒发·偷天换日", PinkRed)
                       WAR.CurID = s
                       JY.Person[jqid]["生命"] = JY.Person[jqid]["生命最大值"]
                       JY.Person[jqid]["内力"] = JY.Person[jqid]["内力最大值"]
                       JY.Person[jqid]["体力"] = 100
                       JY.Person[jqid]["中毒程度"] = 0
                       JY.Person[jqid]["受伤程度"] = 0
                        --流血
                       if WAR.LXZT[jqid] ~= nil then
                          WAR.LXZT[jqid] = nil
                       end
                       --封穴
                       if WAR.FXDS[jqid] ~= nil then
                          WAR.FXDS[jqid] = nil
                       end
                       
                    end
                end			   

				--天山童姥：转瞬红颜
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

						CurIDTXDH(WAR.CurID, 104, 1, "红颜弹指老·刹那芳华", PinkRed)
						WAR.CurID = s

						JY.Person[jqid]["生命"] = JY.Person[jqid]["生命最大值"]
						JY.Person[jqid]["内力"] = JY.Person[jqid]["内力最大值"]
						JY.Person[jqid]["体力"] = 100
						JY.Person[jqid]["中毒程度"] = 0
						JY.Person[jqid]["受伤程度"] = 0
						JY.Person[jqid]["冰封程度"] = 0
						JY.Person[jqid]["灼烧程度"] = 0
						--流血
						if WAR.LXZT[jqid] ~= nil then
							WAR.LXZT[jqid] = nil
						end
						--封穴
						if WAR.FXDS[jqid] ~= nil then
							WAR.FXDS[jqid] = nil
						end
					end
				end
	

				--葵花尊者，恢复
				if match_ID(jqid,608) then
					AddPersonAttrib(jqid,'生命',5)
					AddPersonAttrib(jqid,'内力',10)
					AddPersonAttrib(jqid,'体力',1)
					AddPersonAttrib(jqid,'中毒程度',-1)
					AddPersonAttrib(jqid,'受伤程度',-1)
					AddPersonAttrib(jqid,'冰封程度',-1)	
					AddPersonAttrib(jqid,'灼烧程度',-1)	
					--流血
					
					if WAR.LXZT[jqid] ~= nil then
						WAR.LXZT[jqid] = WAR.LXZT[jqid] - 1
					end
					--封穴
					if WAR.FXDS[jqid] ~= nil then
						WAR.FXDS[jqid] = WAR.FXDS[jqid] - 1
					end
				end
				
				--轻云蔽月时序计数
				if WAR.QYBY[jqid] ~= nil then
					WAR.QYBY[jqid] = WAR.QYBY[jqid] - 1	
					if WAR.QYBY[jqid] < 1 then
						WAR.QYBY[jqid] = nil
					end
				end
		
				--进阶泰山，使用后30时序内闪避 
				if WAR.TSSB[jqid] ~= nil then
					WAR.TSSB[jqid] = WAR.TSSB[jqid] - 1
					if WAR.TSSB[jqid] < 1 then
						WAR.TSSB[jqid] = nil
					end
				end
				--霍青桐指令
				if WAR.HQT_ZL[jqid] ~= nil then
					WAR.HQT_ZL[jqid] = WAR.HQT_ZL[jqid] - 1
					if WAR.HQT_ZL[jqid] < 1 then
						WAR.HQT_ZL[jqid] = nil
					end
				end			
				--文泰来 否极泰来状态计时 WTL_PJTL
				if WAR.WTL_PJTL[jqid] ~= nil then
				   WAR.WTL_PJTL[jqid] = WAR.WTL_PJTL[jqid] - 1
					if WAR.WTL_PJTL[jqid] < 1 then
						WAR.WTL_PJTL[jqid] = nil
						WAR.WTL_1[jqid] = nil
					end
				end	
				--文泰来 否极泰来倒计时
				if WAR.WTL_1[jqid] ~= nil then
				  WAR.WTL_1[jqid] = WAR.WTL_1[jqid] - 1
					if WAR.WTL_1[jqid] < 1 then
						WAR.WTL_1[jqid] = 0
					end
				end
			
				--青莲剑仙，使用后50时序内闪避
				if WAR.QLJX[jqid] ~= nil then
					WAR.QLJX[jqid] = WAR.QLJX[jqid] - 1
					if WAR.QLJX[jqid] < 1 then
						WAR.QLJX[jqid] = nil
					end
				end
				--大周天功回复50时序
				if WAR.ZTHF[jqid] ~= nil then
					WAR.ZTHF[jqid] = WAR.ZTHF[jqid] - 1
					if WAR.ZTHF[jqid] < 1 then
						WAR.ZTHF[jqid] = nil
					end
				end				
				--陆渐三十二身相 一合相
				if WAR.SSESS[jqid] ~= nil then
					WAR.SSESS[jqid] = WAR.SSESS[jqid] - 1
					if WAR.SSESS[jqid] < 1 then
						WAR.SSESS[jqid] = nil
					end
				end	
				--陆渐 金刚法相
				if WAR.JGFX[jqid] ~= nil then
					WAR.JGFX[jqid] = WAR.JGFX[jqid] - 1
					if WAR.JGFX[jqid] < 1 then
						WAR.JGFX[jqid] = nil
					end
				end	
			
				--梁萧十方步，使用后30时序内闪避
				if WAR.SFB[jqid] ~= nil then
					WAR.SFB[jqid] = WAR.SFB[jqid] - 1
					if WAR.SFB[jqid] < 1 then
						WAR.SFB[jqid] = nil
					end
				end
				--长生回天回复，使用后100时序内回复
				if WAR.CSHF[jqid] ~= nil then
					WAR.CSHF[jqid] = WAR.CSHF[jqid] - 1
					if WAR.CSHF[jqid] < 1 then
						WAR.CSHF[jqid] = nil
					end
				end	
	
                if WAR.PD['长生诀'][jqid] ~= nil then 
					AddPersonAttrib(jqid,'生命',math.modf(JY.Person[jqid]["生命最大值"]/100))
					AddPersonAttrib(jqid,'内力',math.modf(JY.Person[jqid]["内力最大值"]/100))
					AddPersonAttrib(jqid,'体力',1)
                    WAR.PD['长生诀'][jqid] = WAR.PD['长生诀'][jqid] - 1
                    if WAR.PD['长生诀'][jqid] < 1 then 
                       WAR.PD['长生诀'][jqid] = nil     
                    end
                end
				--无明业火状态，耗损使用的内力一半的生命，30时序
				if WAR.WMYH[jqid] ~= nil then
					WAR.WMYH[jqid] = WAR.WMYH[jqid] - 1
					if WAR.WMYH[jqid] < 1 then
						WAR.WMYH[jqid] = nil
					end
				end
			
				
				--张家辉的隐身戒指
				if WAR.YSJZ ~= 0 then
					WAR.YSJZ = WAR.YSJZ - 1
				end
                
                
                if ZhongYongZD(jqid) then 
                    local t = JY.Person[jqid]['资质']-1
                    if t < 30 then 
                        t = 30
                    end
                    if WAR.PD['中庸'][jqid] == nil or WAR.PD['中庸'][jqid] < t then 
                        WAR.PD['中庸'][jqid] = (WAR.PD['中庸'][jqid] or 0) + 1
                        if WAR.PD['中庸'][jqid] >= t then 
                            WAR.PD['中庸'][jqid] = 0
                            Cat('立刻出手',i)
                            WAR.CurID = i
                            WarDrawMap(0)
                            CurIDTXDH(WAR.CurID, 6, 1, "中庸之道", PinkRed)
                            --atid = i
                            xunhuan = false
                        end
                    end
                end
                
				--[[中庸CD
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
                            CurIDTXDH(WAR.CurID, 6, 1, "中庸之道", PinkRed)
                            xunhuan = false
                        end
                    end
				end	
                ]]
                --WAR.Person[i].Time = 1001
				--蓝烟清：王难姑指令，按时序中毒
				if WAR.L_WNGZL[jqid] ~= nil and WAR.L_WNGZL[jqid] > 0 then
					AddPersonAttrib(jqid,'中毒程度',1)
					WAR.L_WNGZL[jqid] = WAR.L_WNGZL[jqid] -1;
						
					if WAR.L_WNGZL[jqid] <= 0 then
						WAR.L_WNGZL[jqid] = nil;
					end
				end
					
				--brolycjw：胡青牛指令，每个时序回复1%血
				if WAR.L_HQNZL[jqid] ~= nil and WAR.L_HQNZL[jqid] > 0 then
					--JY.Person[jqid]["生命"] = JY.Person[jqid]["生命"] + math.modf(JY.Person[jqid]["生命最大值"]/100);
					AddPersonAttrib(jqid,'生命',math.modf(JY.Person[jqid]["生命最大值"]/100))
					
					if JY.Person[jqid]["受伤程度"] > 50 then
						--JY.Person[jqid]["受伤程度"] = JY.Person[jqid]["受伤程度"] - 2;
						AddPersonAttrib(jqid,'受伤程度',-2)
					else
						--JY.Person[jqid]["受伤程度"] = JY.Person[jqid]["受伤程度"] - 1;
						AddPersonAttrib(jqid,'受伤程度',-1)
					end
					WAR.L_HQNZL[jqid] = WAR.L_HQNZL[jqid] -1;
					if WAR.L_HQNZL[jqid] <= 0 then
						WAR.L_HQNZL[jqid] = nil;
					end
				end
				--长生回天回复 回血1%  回内伤2
				if WAR.CSHF[jqid] ~= nil  then
					--JY.Person[jqid]["生命"] = JY.Person[jqid]["生命"] + math.modf(JY.Person[jqid]["生命最大值"]/100);
					--JY.Person[jqid]["内力"] = JY.Person[jqid]["内力"] + math.modf(JY.Person[jqid]["生命最大值"]/100);
					--JY.Person[jqid]["体力"] = JY.Person[jqid]["体力"] + math.modf(JY.Person[jqid]["生命最大值"]/100);	
					AddPersonAttrib(jqid,'生命',math.modf(JY.Person[jqid]["生命最大值"]/100))
					AddPersonAttrib(jqid,'内力',math.modf(JY.Person[jqid]["内力最大值"]/100))
					AddPersonAttrib(jqid,'体力',1)
					if JY.Person[jqid]["受伤程度"] > 50 then
						--JY.Person[jqid]["受伤程度"] = JY.Person[jqid]["受伤程度"] - 2;
						AddPersonAttrib(jqid,'受伤程度',-2)
					else
						--JY.Person[jqid]["受伤程度"] = JY.Person[jqid]["受伤程度"] - 1;
						AddPersonAttrib(jqid,'受伤程度',-1)
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
                
				--无酒不欢：集气读数获取位置
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
		
		Cat('天关阵')
		
        if #WAR.ATK['人物table'] > 0 then
            atid = WAR.ATK['人物table'][#WAR.ATK['人物table']]
            local id = WAR.Person[atid]['人物编号']
            table.remove(WAR.ATK['人物table'],#WAR.ATK['人物table'])
            WAR.ATK['人物pd'][id] = nil
            if #WAR.ATK['人物table'] == 0 then 
                WAR.ATK['人物table'] = {}
            end
        end  
		
		--local num = math.ceil(CC.BattleDelay/10)
		--xh = xh + 1
		--if xh == num then 
		Cat('实时特效动画')
		--	xh = 0
		--end
		WarDrawMap(0) 
		--DrawString(x2 + 10-410, y - 60-25, "时序", C_WHITE, CC.DefaultFont*0.8)
		--lib.LoadPicture("./data/xt/23.png",0,0,1)	
		--DrawTimeBar_sub(x1, x2, nil, 0)
        DrawTimeBar_sub()
		ShowScreen()
		lib.Delay(CC.BattleDelay) --黑魅灵蜜汁调整刷新速度
		--lib.Delay(10)
		WAR.SXTJ = WAR.SXTJ + 1
		--无酒不欢：三时序，五时序，六时序，九时序的计数器
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
		--lib.Delay(10) -- 无酒不欢：减缓集气条速度	
		
		--集气过程中按空格或回车停止自动
		local keypress = lib.GetKey()
		if (keypress == VK_SPACE or keypress == VK_RETURN) then
			if WAR.AutoFight == 1 then 
				WAR.AutoFight = 0
			end	
            
		end
		--lib.LoadSur(surid, x1 - ((x2 - x1) / 2)-100, 0)	--无酒不欢：修复杀到-500后集气条小头像刷新问题
	end
    
	::label1::
  
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["死亡"] == false then
			WAR.Person[i].TimeAdd = 0
		end
	end
  
	--WAR.ZYHBP = -1
	--lib.SetClip(0, 0, 0, 0)
	--lib.FreeSur(surid)
    return atid
end

--绘画整体集气条
function DrawTimeBar_sub(x1, x2, y, flag)

	--无酒不欢：绘画部分增加破绽区显示
	if not x2 then
		x2 = CC.ScreenW * 19 / 20 - 2  --X上方位置
	end
	if not y then
		y = CC.ScreenH/10 + 29
	end
	if not x1 then
		x1 = CC.ScreenW * 1 / 2 - 34  --X下方位置
		lib.LoadPicture("./data/xt/23.png",0,0,1)	
	end
  
	for i = 0, WAR.PersonNum - 1 do
		if not WAR.Person[i]["死亡"] then
			--无酒不欢：修正集气条显示，不会飞过1000
			if WAR.Person[i].Time > 1001 then
				WAR.Person[i].Time = 1001
			end
			local id = WAR.Person[i]["人物编号"]
			local cx = x1 + math.modf(WAR.Person[i].Time*(x2 - x1)/1000)
			local headid = JY.Person[id]["半身像"]
			if headid == nil then
				headid = JY.Person[id]["半身像"]
			end
			local w, h = limitX(CC.ScreenW/25,12,35),limitX(CC.ScreenW/25,12,35)
			local jq_color = C_WHITE
			if JY.Person[id]["中毒程度"] == 100 then
				jq_color = RGB(56, 136, 36)
			elseif JY.Person[id]["中毒程度"] >= 50 then
				jq_color = RGB(120, 208, 88)
			end
			if WAR.LQZ[id] == 100 then
				jq_color = C_RED
			end
			if WAR.Person[i]["我方"] then
				drawname(cx, 1, id, CC.FontSmall)
				lib.LoadPNG(99, headid*2, cx - w / 2, y - h - 4, 1, 0)
				DrawString(cx-17-5, y-10-90-5, string.format("%3d",WAR.JQSDXS[id]), jq_color, CC.FontSMALL)	--集气速度
				if JY.Person[id]["灼烧程度"] ~= 0 then
					DrawString(cx, y-10-33, string.format("%3d",JY.Person[id]["灼烧程度"]), C_ORANGE, CC.FontSMALL)	--灼烧数值
				end
				if WAR.FXDS[id] ~= nil and WAR.FXDS[id] ~= 0 then
					DrawString(cx-21, y-10-33, string.format("%3d",WAR.FXDS[id]), C_GOLD, CC.FontSMALL)	--封穴数值
				end
			else
				drawname(cx, y+h, id, CC.FontSmall)
				lib.LoadPNG(99, headid*2, cx - w / 2, y + 6-5, 1, 0)
				DrawString(cx-21, y+h-5, string.format("%3d",WAR.JQSDXS[id]), jq_color, CC.FontSMALL)	--集气速度
				if JY.Person[id]["灼烧程度"] ~= 0 then
					DrawString(cx, y+h-33, string.format("%3d",JY.Person[id]["灼烧程度"]), C_ORANGE, CC.FontSMALL)	--灼烧数值
				end
				if WAR.FXDS[id] ~= nil and WAR.FXDS[id] ~= 0 then
					DrawString(cx-21, y+h-33, string.format("%3d",WAR.FXDS[id]), C_GOLD, CC.FontSMALL)	--封穴数值
				end
			end
		end
	end
	DrawString(x2 + 10-370, y-80-8 , WAR.SXTJ, C_GOLD, CC.DefaultFont*0.9)
    DrawString(x2 + 10-420, y - 60-25, "时序", C_WHITE, CC.DefaultFont*0.8)	
	
end

--绘画集气条上的名字
function drawname(x, y, id, size)
	local name = JY.Person[id]["姓名"]
	local color = C_WHITE
	--名字颜色随冰封和内伤变化
	if JY.Person[id]["受伤程度"] > JY.Person[id]["冰封程度"] then
		if JY.Person[id]["受伤程度"] > 99 then
			color = RGB(232, 32, 44)
		elseif JY.Person[id]["受伤程度"] > 66 then
			color = RGB(244, 128, 32)
		elseif JY.Person[id]["受伤程度"] > 33 then
			color = RGB(236, 200, 40)
		end
	else
		if JY.Person[id]["冰封程度"] >= 50 then
			color = M_RoyalBlue
		elseif JY.Person[id]["冰封程度"] > 0 then
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

--判断两人之间的距离
function RealJL(id1, id2, len)
	if not len then
		len = 1
	end
	local x1, y1 = WAR.Person[id1]["坐标X"], WAR.Person[id1]["坐标Y"]
	local x2, y2 = WAR.Person[id2]["坐标X"], WAR.Person[id2]["坐标Y"]
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

--计算武功范围
function refw(wugong, level)
  --无酒不欢：参数说明
  --m1为移动范围斜向延伸：
	--0：延伸为直线距离-1，1：延伸至直线距离，2：延伸为0 3：移动范围固定为自身周围8格
  --m2为移动范围直线延伸；
	--数字即等于延伸距离
  --a1为攻击范围类型：
	--0：点攻，1：十字，2：菱形，3：面攻，5：十字，6：井字，7：田字，8：卍字，9：卐字，10：直线，11：正三角，12：倒三角，13：横线
  --a2为攻击范围长度距离：
	--0：点攻，大于0时，距离 = a2
  --a3为攻击范围宽度(偏移1格)距离：
	--0：点攻，大于0时，距离 = a3  
  --a4为攻击范围宽度(偏移2格)距离：
	--0：点攻，大于0时，距离 = a4
  --a5为攻击范围宽度(偏移3格)距离：
	--0：点攻，大于0时，距离 = a5
	local m1, m2, a1, a2, a3, a4, a5, a6  = nil, nil, nil, nil, nil, nil, nil ,nil
	if JY.Wugong[wugong]["攻击范围"] == -1 then
		return JY.Wugong[wugong]["加内力1"], JY.Wugong[wugong]["加内力2"], JY.Wugong[wugong]["未知1"], JY.Wugong[wugong]["未知2"], JY.Wugong[wugong]["未知3"], JY.Wugong[wugong]["未知4"], JY.Wugong[wugong]["未知5"]
	end
	--0：点
	--1：线
	--2：十字
	--3：面
	local fightscope = JY.Wugong[wugong]["攻击范围"]
	local kfkind = JY.Wugong[wugong]["武功类型"]
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	--六脉神剑算剑法的范围
	if wugong == 49 then
		kfkind = 3
	end
	--玄女剑法算奇门的范围
	if wugong == 161 then
		kfkind = 5
	end

	--逍遥神剑算刀法的范围
	if wugong == 168 then
		kfkind = 4
	end
	--阴风刀算剑法的范围
	if wugong == 174 then
		kfkind = 3
	end
	if wugong == 47 then
		kfkind = 2
	end	
	--王语嫣妙法无形
	local MiaofaWX = 0
	local mx = 0
	for i = 0, WAR.PersonNum - 1 do
		local id = WAR.Person[i]["人物编号"]
		if WAR.Person[i]["死亡"] == false and WAR.Person[i]["我方"] and match_ID(id, 76) and inteam(pid) then
			MiaofaWX = MiaofaWX + 1
			break
		end
	end
	if mx > 2 then
	mx  = 2
	end	
	--天罗地网也增加攻击范围
	if Curr_QG(pid,148) and (JY.Person[pid]["武器"] == 335)  == false then
	    mx = MiaofaWX + 1
		MiaofaWX = mx
	end
	--诸行无常
	if match_ID(pid, 9985)  then
		MiaofaWX = MiaofaWX + 1
	end	
	--方证用拳法范围+1
	if match_ID(pid, 149) and kfkind == 1 then
		MiaofaWX = MiaofaWX + 1
	end
	--萧半和混元功范围+1
	if match_ID(pid, 189) and wugong == 90 then
		MiaofaWX = MiaofaWX + 1
	end	
    --萧秋水 剑气飞纵 用武功范围+1
	if match_ID(pid, 652) and JY.Base["天书数量"] > 5then
		MiaofaWX = MiaofaWX + 1
	end
    --莫大剑法范围+1
	if match_ID(pid, 20) and kfkind == 3 then
		MiaofaWX = MiaofaWX + 1
	end	
	
	--双剑合壁范围增加范围
	if  (wugong == 39 or wugong == 42 or wugong == 139) and ShuangJianHB(pid) then 
	   MiaofaWX	= MiaofaWX + 1
	end	

	--苗人凤，苗剑范围随御剑系数增加
	if match_ID(pid, 3) and wugong == 44 then
		MiaofaWX = MiaofaWX + math.modf(TrueYJ(pid)/200)
	end
	--闪电貂和妙手空空范围不增加
	if wugong == 113 or wugong == 116 then
		MiaofaWX = 0
	end
	--点
	if fightscope == 0 then
		if level > 10 then
			m1 = 1
			m2 = JY.Wugong[wugong]["移动范围" .. 10]
			a1 = 1
			a2 = 3 + MiaofaWX
			a3 = 3 + MiaofaWX
		else
			m1 = 0
			m2 = JY.Wugong[wugong]["移动范围" .. level]
			a1 = 1
			a2 = math.modf(level / 5) + MiaofaWX
			a3 = math.modf(level / 8) + MiaofaWX
		end
	--线
	elseif fightscope == 1 then
		--拳指
		if kfkind == 1 or kfkind == 2 then
			a1 = 12
			if level > 10 then
				m1 = 3
				m2 = 1
				a2 = JY.Wugong[wugong]["移动范围" .. 10] - 1 + MiaofaWX
			else
				m1 = 2
				m2 = 1
				a2 = JY.Wugong[wugong]["移动范围" .. level] - 1 + MiaofaWX
			end
		--剑
		elseif kfkind == 3 then
			a1 = 10
			if level > 10 then
				m1 = 3
				m2 = 1
				a2 = JY.Wugong[wugong]["移动范围" .. 10] + MiaofaWX
				a3 = a2 - 1
				a4 = a3 - 1
			else
				m1 = 2
				m2 = 1
				a2 = JY.Wugong[wugong]["移动范围" .. level] + MiaofaWX
			end
			if level > 7 then
				a3 = a2 - 1
			end
		--刀
		elseif kfkind == 4 then
			a1 = 11
			if level > 10 then
				m1 = 3
				m2 = 1
				a2 = JY.Wugong[wugong]["移动范围" .. 10] - 1 + MiaofaWX
			else
				m1 = 2
				m2 = 1
				a2 = JY.Wugong[wugong]["移动范围" .. level] - 1 + MiaofaWX
			end
		--奇
		elseif kfkind == 5 then
			m1 = 2
			if level > 10 then
				m2 = JY.Wugong[wugong]["移动范围" .. 10] - 1
				a1 = 7
				--田字斗转时不会增加范围
				if WAR.DZXY == 0 then
					a2 = 1 + math.modf(level / 3) + MiaofaWX
				else
					a2 = 1 + math.modf(level / 3)
				end
				a3 = a2
			else
				m2 = JY.Wugong[wugong]["移动范围" .. level] - 1
				a1 = 1
				a2 = 1 + math.modf(level / 3) + MiaofaWX
			end
		else
			a1 = 11
			if level > 10 then
				m1 = 3
				m2 = 1
				a2 = JY.Wugong[wugong]["移动范围" .. 10] - 1 + MiaofaWX
			else
				m1 = 2
				m2 = 1
				a2 = JY.Wugong[wugong]["移动范围" .. level] - 1 + MiaofaWX
			end
		end
	--十字
	elseif fightscope == 2 then
		m1 = 0
		m2 = 0
		--刀
		if kfkind == 4 then
			if level > 10 then
				a1 = 6
				a2 = JY.Wugong[wugong]["移动范围" .. 10] + MiaofaWX
			else
				a1 = 8
				a2 = JY.Wugong[wugong]["移动范围" .. level] + MiaofaWX
			end
		--到极的非刀
		elseif level > 10 then
			--拳指
			if kfkind == 1 or kfkind == 2 then
				a1 = 5
				a2 = JY.Wugong[wugong]["移动范围" .. 10] - 1 + MiaofaWX
				a3 = a2 - 3
			--剑
			elseif kfkind == 3 then
				a1 = 1
				a2 = JY.Wugong[wugong]["移动范围" .. 10] - 1 + MiaofaWX
				a3 = a2
			else
				a1 = 2
				a2 = 1 + math.modf(JY.Wugong[wugong]["移动范围" .. 10] / 2) + MiaofaWX
			end
		--不到极的非刀
		else
			  a1 = 1
			  a2 = JY.Wugong[wugong]["移动范围" .. level] + MiaofaWX
			  a3 = 0
		end
	--面
	elseif fightscope == 3 then
		m1 = 0
		a1 = 3
		if level > 10 then
			m2 = JY.Wugong[wugong]["移动范围" .. 10] + 1
			a2 = JY.Wugong[wugong]["杀伤范围" .. 10] + MiaofaWX
			a3 = a2
		else
			m2 = JY.Wugong[wugong]["移动范围" .. level]
			a2 = JY.Wugong[wugong]["杀伤范围" .. level] + MiaofaWX
		end
	end
	--悲天佛怜 
   if( match_ID(pid,9983) or JinGangBR(pid))   and wugong == 189 then
	  a1 = 0
	  m1 = 0
	  m2 = 8
    end
	--擒龙手
	if wugong == 187 then
	 a1 = 0
	 mi = 0
	 m2 = 7
	end
	--太极神功范围随着蓄力变化
	--斗转时范围不变化
	if Curr_NG(pid,171) and (wugong == 16 or wugong == 46 ) and WAR.PD["太极蓄力"][pid] ~= nil and WAR.PD["太极蓄力"][pid] > 0  and WAR.DZXY == 0 then
		if WAR.PD["太极蓄力"][pid] > 600 then
			m1 = 0
			m2 = 4
			a1 = 3
			a2 = 4 + MiaofaWX
			a3 = a2
		elseif WAR.PD["太极蓄力"][pid] > 500 then
			m1 = 0
			m2 = 4
			a1 = 3
			a2 = 3 + MiaofaWX
			a3 = a2			
		elseif WAR.PD["太极蓄力"][pid] > 300 then
			a2 = a2 + 2
			a3 = a3 + 2
		else
			a2 = a2 + 1
			a3 = a3 + 1
		end
	end

	
	--青冥剑随御剑系数增加
	if JY.Person[pid]["武器"] == 335 and kfkind == 3  then
        mx =  1
		a2 = a2 + mx
		a3 = a2
     
	end	
	
	--玉箫剑法，配合桃花绝技范围增加
	if wugong == 38 and level == 11 and TaohuaJJ(pid) then
		a2 = 8 + MiaofaWX
		a3 = a2 - 1
		a4 = a3 - 1
	end
	--落英神剑掌，配合桃花绝技可移动
	if wugong == 12 and level == 11 and TaohuaJJ(pid) then
		m1 = 0
		m2 = 6
	end
	if wugong == 47 then
		m1 = 0
		m2 = 6
	end
	--玄铁可移动
	if  wugong == 45 then
		m1 = 0
		m2 = 4
	end
	
	--进阶万花，范围+1
	if wugong == 30 and PersonKF(pid,175) then
		a2 = a2 + 1
		a3 = a2
	end


	--辟邪剑法手动选择范围
	if wugong == 48 and level == 11 and inteam(pid) and WAR.AutoFight == 0 and WAR.DZXY == 0 then
		m1, m2, a1, a2, a3, a4 , a5, a6 = BiXieZhaoShi(pid,MiaofaWX)
	end

	
	--九阳神功手动选择招式 
	if wugong == 106 and level == 11  and  inteam(pid)  and WAR.DZXY == 0 and WAR.AutoFight == 0 then
		m1, m2, a1, a2, a3, a4 , a5, a6 = JIUYANGZhaoShi(pid,MiaofaWX)
	end	
	--太玄神功手动选择系数
	if wugong == 102 and level == 11 and match_ID_awakened(pid, 38, 1)  and  inteam(pid) and WAR.AutoFight == 0 and WAR.DZXY == 0 then
		a6 = TaiXuanZhaoShi()
	end
	
	return m1, m2, a1, a2, a3, a4, a5 , a6

  
end

--用CC表判断人物是否为队友，不管在不在队
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

--判断人物是否有某种武功
function PersonKF(p, kf)
	for i = 1, JY.Base["武功数量"] do
		if JY.Person[p]["武功" .. i] <= 0 then
			return false;
		elseif JY.Person[p]["武功" .. i] == kf then
			return true
		end
	end
	return false
end

--判断人物是否有某种武功，并且等级为极
function PersonKFJ(p, kf)
	for i = 1, JY.Base["武功数量"] do
		if JY.Person[p]["武功" .. i] <= 0 then
			return false;
		elseif JY.Person[p]["武功" .. i] == kf and JY.Person[p]["武功等级" .. i] == 999 then
			return true
		end
	end
	return false
end

--判断触发机率
function myrandom(p, id)
	--生命越低，几率越高，最多10
	p = p + math.modf((JY.Person[id]["生命最大值"] - JY.Person[id]["生命"])/100 + 1);	
	
	--体力越高，几率越高，最多10
	p = p + math.modf(JY.Person[id]["体力"] / 10)
	
	--林朝英+10
	if match_ID(id, 605) then
		p = p + 10
	end

	--逆运走火+20
	if WAR.PD["走火状态"][id] == 1 then
		p = p + 20
	end

	--每25点实战+1，上限20
	local jp = math.modf(JY.Person[id]["实战"] / 25 + 1)
	if jp > 20 then
		jp = 20
	end
	p = p + jp

	--每500内力+1，最多20
	p = p + limitX(math.modf(JY.Person[id]["内力"] / 500), 0, 20)
	
	--每50点攻击力+1，最多10
	p = p + limitX(math.modf(JY.Person[id]["攻击力"] / 50), 0, 10)
	
	--每50点防御力+1，最多10
	p = p + limitX(math.modf(JY.Person[id]["防御力"] / 50), 0, 10)
	
	--每50点轻功+1，最多10
	p = p + limitX(math.modf(JY.Person[id]["轻功"] / 50), 0, 10)
	
	--基础判定次数为一次
	local times = 1
	--如果是我方
	if inteam(id) then
		--我方天书增加几率
		p = p + JY.Base["天书数量"]
		--50%几率二次判定
		if math.random(2) == 2 then
			times = 2
		end
		--石破天必定二次判定
		if match_ID(id, 38) and times == 1  then
			times = 2
		end
		--单通 必定二次判定
		if id ==0 and times == 1 and JY.Base["单通"] > 0 then
	    times = 2
		end		
	--NPC默认为三次判定且几率+60
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


--自动选择敌人
function War_AutoSelectEnemy()
	local enemyid = War_AutoSelectEnemy_near()
	WAR.Person[WAR.CurID]["自动选择对手"] = enemyid
	return enemyid
end

--选择最近敌人
function War_AutoSelectEnemy_near()
	War_CalMoveStep(WAR.CurID, 100, 1)			--标记每个位置的步数
	local maxDest = math.huge
	local nearid = -1
	for i = 0, WAR.PersonNum - 1 do		--查找最近步数的敌人
		if WAR.Person[WAR.CurID]["我方"] ~= WAR.Person[i]["我方"] and WAR.Person[i]["死亡"] == false then
			local step = GetWarMap(WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"], 3)
			if step < maxDest then
				nearid = i
				maxDest = step
			end
		end
	end
	return nearid
end

--战斗中加入新人物
function NewWARPersonZJ(id, dw, x, y, life, fx)
	WAR.Person[WAR.PersonNum]["人物编号"] = id
	WAR.Person[WAR.PersonNum]["我方"] = dw
	WAR.Person[WAR.PersonNum]["坐标X"] = x
	WAR.Person[WAR.PersonNum]["坐标Y"] = y
	WAR.Person[WAR.PersonNum]["死亡"] = life
	WAR.Person[WAR.PersonNum]["人方向"] = fx
	WAR.Person[WAR.PersonNum]["贴图"] = WarCalPersonPic(WAR.PersonNum)
	--lib.PicLoadFile(string.format(CC.FightPicFile[1], JY.Person[id]["头像代号"]), string.format(CC.FightPicFile[2], JY.Person[id]["头像代号"]), 4 + WAR.PersonNum)
	SetWarMap(x, y, 2, WAR.PersonNum)
	SetWarMap(x, y, 5, WAR.Person[WAR.PersonNum]["贴图"])
    SetWarMap(x, y, 10, JY.Person[WAR.Person[WAR.PersonNum]["人物编号"]]['头像代号'])
	WAR.PersonNum = WAR.PersonNum + 1
end

--无酒不欢：判定合击用的函数
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
--无酒不欢：独孤求败反击的伤害判定
function First_strike_dam_DG(pid, eid)
	local dam;
	local YJ_dif = TrueYJ(pid)*1.2 - TrueYJ(eid)
	local p_wc = JY.Person[pid]["武学常识"]
	local e_wc = JY.Person[eid]["武学常识"]
	if p_wc < e_wc then
		p_wc = e_wc
	end
	dam = (JY.Person[pid]["攻击力"]-JY.Person[eid]["防御力"])+(p_wc*1.2-e_wc)+(getnl(pid)/50*1.2-getnl(eid)/50)
	dam = math.modf(dam + YJ_dif)
	return dam
end

--伤害公式中的内力，当前内力和最大内力都参与计算
function getnl(id)
	return (JY.Person[id]["内力"] * 2 + JY.Person[id]["内力最大值"]) / 3
end

--无酒不欢：血量翻倍函数
function Health_in_Battle()
	for i = 0, WAR.PersonNum - 1 do
		local pid = WAR.Person[i]["人物编号"]

		--加一个变量避免重复翻倍
		--if JY.Person[pid]["血量翻倍"] > 1 and WAR.HP_Bonus_Count[pid] == nil then
			--JY.Person[pid]["生命最大值"] = JY.Person[pid]["生命最大值"] * JY.Person[pid]["血量翻倍"]
			--JY.Person[pid]["生命"] = JY.Person[pid]["生命"] * JY.Person[pid]["血量翻倍"]
			--WAR.HP_Bonus_Count[pid] = 1
		--end
        
		if WAR.ZDDH == 354 and WAR.Person[i]["我方"] then
			if JY.Person[pid]["天赋内功"] > 0 then
				JY.Person[pid]["主运内功"] = JY.Person[pid]["天赋内功"]
			end
			if JY.Person[pid]["天赋轻功"] > 0 then
			JY.Person[pid]["主运轻功"] = JY.Person[pid]["天赋轻功"]
			end
		end
        
		--无酒不欢：非我方自动运功
		if inteam(pid) == false or WAR.Person[i]["我方"] == false then
			if JY.Person[pid]["主运内功"] == 0 and (JY.Person[pid]["畅想分阶"] > 5 )  then
				JY.Person[pid]["主运内功"] = 219 
			end
			if JY.Person[pid]["主运内功"] == 0 and JY.Person[pid]["畅想分阶"] < 5 then
				JY.Person[pid]["主运内功"] = 219 
			end				
			if JY.Person[pid]["天赋内功"] > 0 then
				JY.Person[pid]["主运内功"] = JY.Person[pid]["天赋内功"]
			end
			if JY.Person[pid]["天赋轻功"] > 0 then
			JY.Person[pid]["主运轻功"] = JY.Person[pid]["天赋轻功"]
			end		
		end
	end
end

--无酒不欢：血量还原函数
function Health_in_Battle_Reset()
	--for i = 0, WAR.PersonNum - 1 do
	--	local pid = WAR.Person[i]["人物编号"]
	--	if JY.Person[pid]["血量翻倍"] > 1 and WAR.HP_Bonus_Count[pid] ~= nil then
	--		JY.Person[pid]["生命最大值"] = JY.Person[pid]["生命最大值"] / JY.Person[pid]["血量翻倍"]
	--		WAR.HP_Bonus_Count[pid] = nil
	--	end
	--end
end

--战斗中查看敌方简易信息
function MapWatch()
	local x = WAR.Person[WAR.CurID]["坐标X"];
	local y = WAR.Person[WAR.CurID]["坐标Y"];
	WAR.ShowHead = 0
	War_CalMoveStep(WAR.CurID,128,1);
	Cat('实时特效动画')
	WarDrawMap(1,x,y);
	ShowScreen();
	lib.Delay(CC.BattleDelay)
	x,y=War_SelectMove()
	if x == nil then
		return
	end
	WAR.ShowHead = 1
end

--无酒不欢：等待指令
function War_Wait()
	local id = WAR.Person[WAR.CurID]["人物编号"]
	WAR.Wait[id] = 1
	Cls()
  	CurIDTXDH(WAR.CurID, 72, 1, "伺机待发", LightGreen, 15)
	--穆人清等待时蓄力
	if match_ID(id, 185) then
		WAR.Actup[id] = 2
	end
  	return 1
end

--集中指令
function War_Focus()
	local id = WAR.Person[WAR.CurID]["人物编号"]
	WAR.Focus[id] = 1
	Cls()
  	CurIDTXDH(WAR.CurID, 151, 1, "心念合一", C_GOLD)
  	return 20
end

--无酒不欢：撤退
function War_Retreat()
	local id = WAR.Person[WAR.CurID]["人物编号"]
	local r = JYMsgBox(JY.Person[id]["姓名"], "确定要我撤退吗？", {"否","是"}, 2, JY.Person[id]["半身像"])
	if r == 2 then
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["我方"] then
			   WAR.Person[i]["死亡"] = true
			end		
		end 
		return 1;
	end
end

--无酒不欢：常态血条显示
function HP_Display_When_Idle()
    local x0 = WAR.Person[WAR.CurID]["坐标X"];
    local y0 = WAR.Person[WAR.CurID]["坐标Y"];
	for k = 0, WAR.PersonNum - 1 do
		local tmppid = WAR.Person[k]["人物编号"]
		if WAR.Person[k]["死亡"] == false then
			local dx = WAR.Person[k]["坐标X"] - x0
			local dy = WAR.Person[k]["坐标Y"] - y0

			local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
			local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
	 
			local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)
					ry = ry - hb - CC.YScale*7
					
			local pid = WAR.Person[k]["人物编号"]

			local Color = RGB(238,44, 44)
			--local Color1 = RGB(30, 144, 255)
			
			local HP_MAX = JY.Person[pid]["生命最大值"]
            local MP_MAX = JY.Person[pid]["内力最大值"]
			local PH_MAX = 100		
			local Current_HP = limitX(JY.Person[pid]["生命"],0,HP_MAX)
			local Current_MP = limitX(JY.Person[pid]["内力"],0,MP_MAX)
			local Current_PH = limitX(JY.Person[pid]["体力"],0,PH_MAX)	
			--友军NPC显示为绿色血条
			if WAR.Person[k]["我方"] == true then
				Color = RGB(0, 238, 0)
			end
			
			lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/9, rx+CC.XScale*1.4, ry-CC.YScale*30/17,C_GRAY22)	--背景
			if HP_MAX > 0 then
				lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/9, rx-CC.XScale*1.4+(Current_HP/HP_MAX)*(2.8*CC.XScale), ry-CC.YScale*30/17, Color)  --生命
			end
			DrawBox3(rx-CC.XScale*1.4, ry-CC.YScale*20/9, rx+CC.XScale*1.4, ry-CC.YScale*30/17, C_BLACK)

			lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/11+0.5, rx+CC.XScale*1.4, ry-CC.YScale*30/21,C_GRAY22)	--背景			
			if MP_MAX > 0 then
				lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/11+0.5, rx-CC.XScale*1.4+(Current_MP/MP_MAX)*(2.8*CC.XScale), ry-CC.YScale*30/21, C_BLUE)  --内力
			end
			DrawBox3(rx-CC.XScale*1.4, ry-CC.YScale*20/11+0.5, rx+CC.XScale*1.4, ry-CC.YScale*30/21, C_BLACK)			

			lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/13+1, rx+CC.XScale*1.4, ry-CC.YScale*60/54+1,C_GRAY22)	--背景			
			lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/13+1, rx-CC.XScale*1.4+(Current_PH/PH_MAX)*(2.8*CC.XScale), ry-CC.YScale*60/54+1, S_Yellow)  --内力
			DrawBox3(rx-CC.XScale*1.4, ry-CC.YScale*20/13+1, rx+CC.XScale*1.4, ry-CC.YScale*60/54+1, C_BLACK)
		end
	end
end

--无酒不欢：挨打掉血显示
function HP_Display_When_Hit(ssxx)
    local x0 = WAR.Person[WAR.CurID]["坐标X"];
    local y0 = WAR.Person[WAR.CurID]["坐标Y"];
	--掉血渐变显示			
	ssxx = ssxx - 4
	for k = 0, WAR.PersonNum - 1 do
		local tmppid = WAR.Person[k]["人物编号"]
		--血量有变化才显示
		if WAR.Person[k]["死亡"] == false and WAR.Person[k]["生命点数"] ~= nil and WAR.Person[k]["生命点数"] ~= 0 then
			local dx = WAR.Person[k]["坐标X"] - x0
			local dy = WAR.Person[k]["坐标Y"] - y0

			local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
			local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
	 
			local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)
					ry = ry - hb - CC.YScale*7
					
			local pid = WAR.Person[k]["人物编号"]

			local Color = RGB(238,44, 44)
			--local Color1 = RGB(30, 144, 255)
			
			--计算掉血
			local HP_MAX = JY.Person[pid]["生命最大值"]
			
			local HP_AfterHit = JY.Person[pid]["生命"]
			
			if HP_AfterHit < 0 then
				HP_AfterHit = 0
			end
				
			local HP_BeforeHit = WAR.Person[k]["Life_Before_Hit"] or 0

			local HP_Loss = HP_BeforeHit - HP_AfterHit
			
			local Gradual_HP_Loss;
			local Gradual_HP_Display;
			
			Gradual_HP_Loss = HP_Loss*(ssxx/11)
			Gradual_HP_Display = HP_BeforeHit - Gradual_HP_Loss			


			
			
			--友军NPC显示为绿色血条
			if WAR.Person[k]["我方"] == true then
				Color = RGB(0, 238, 0)
			end
			
			lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/9, rx+CC.XScale*1.4, ry-CC.YScale*15/9,grey21)	--背景
			
			lib.FillColor(rx-CC.XScale*1.4, ry-CC.YScale*20/9, rx-CC.XScale*1.4+(HP_AfterHit/HP_MAX)*(2.8*CC.XScale), ry-CC.YScale*15/9, Color)  --生命
			
			--掉血显示
			if HP_Loss > 0 then
				lib.FillColor(rx-CC.XScale*1.4+(HP_AfterHit/HP_MAX)*(2.8*CC.XScale), ry-CC.YScale*20/9, rx-CC.XScale*1.4+(Gradual_HP_Display/HP_MAX)*(2.8*CC.XScale), ry-CC.YScale*15/9, Color)  --失去生命
			end
		
			DrawBox3(rx-CC.XScale*1.4, ry-CC.YScale*20/9, rx+CC.XScale*1.4, ry-CC.YScale*15/9, C_BLACK)
		end
	end
end

--苍天泰坦：被战场显血函数调用
function DrawBox3(x1, y1, x2, y2, color)
	lib.DrawRect(x1, y1, x2, y1, color)
	lib.DrawRect(x1, y2, x2, y2, color)
	lib.DrawRect(x1, y1, x1, y2, color)
	lib.DrawRect(x2, y1, x2, y2, color)
	--无酒不欢：生命和内力的分隔线
	--lib.DrawRect(x1, y1+(y2-y1)/2+1, x2, y1+(y2-y1)/2+1, color)
end

--显示出招动画的选择出战人物界面
function WarSelectTeam_Enhance()
	if JY.Restart == 1 then
		do return end
	end
	local T_Num=GetTeamNum();
	--无酒不欢：高度以3为单位增加
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
            WAR.Person[WAR.PersonNum]["人物编号"] = id
            WAR.Person[WAR.PersonNum]["我方"] = true
            WAR.Person[WAR.PersonNum]["坐标X"] = x
            WAR.Person[WAR.PersonNum]["坐标Y"] = y
            WAR.Person[WAR.PersonNum]["死亡"] = false
            WAR.Person[WAR.PersonNum]["人方向"] = 3
            WAR.PersonNum = WAR.PersonNum + 1
            x = x + 1
            if x == 34 then 
                x = 20
                y = y + 2
            end
        end
        return
    end
    
	--单通模式
	if JY.Base["单通"] > 0 then
		WAR.Data["自动选择参战人1"] = 0
		for i = 2, 6 do
			WAR.Data["自动选择参战人" .. i] = -1
		end
	end
	
	--剪裁的背景图
	--没有自动选择出战人时才显示
	--单挑陈达海战特殊判定
	if WAR.Data["自动选择参战人1"] == -1 and not (WAR.ZDDH == 92 and GetS(87,31,33,5) == 1) then
		Clipped_BgImg((CC.ScreenW - width) / 2,(CC.ScreenH - height) / 2,(CC.ScreenW + width) / 2,(CC.ScreenH + height) / 2,1000)
		Clipped_BgImg((CC.ScreenW - (CC.DefaultFont+4)*4) / 2,(CC.ScreenH - height) / 2-(CC.DefaultFont+4)/2,
		(CC.ScreenW + (CC.DefaultFont+4)*4) / 2,(CC.ScreenH - height) / 2+(CC.DefaultFont+4)/2,1000)
	end
	for i=1,T_Num do
		local pid=JY.Base["队伍"..i];
		if pid <0 then
			break;
		end
	  
	  --冰糖恋：单挑陈达海
		if WAR.ZDDH == 92 and GetS(87,31,33,5) == 1 then
			WAR.Data["自动选择参战人1"] = 0;
			WAR.Data["我方X1"] = 33
			WAR.Data["我方Y1"] = 24
		end
		
		--战三渡，如果周芷若在队则周芷若必出战
		if WAR.ZDDH == 253 and inteam(631) then
			WAR.Data["手动选择参战人2"] = 631
		end
		
		--畅想杨过绝情谷两战
		if (WAR.ZDDH == 272 or WAR.ZDDH == 273) and JY.Base["畅想"] == 58 then
			WAR.Data["自动选择参战人2"] = 59
		end
		
		for i = 1, 6 do
			local id = WAR.Data["自动选择参战人" .. i]
			if id >= 0 then
				--畅想的情况，畅想主角会取代强制出战的队友
				if id == JY.Base["畅想"] then
					WAR.Person[WAR.PersonNum]["人物编号"] = 0
				else
					WAR.Person[WAR.PersonNum]["人物编号"] = id
				end
				WAR.Person[WAR.PersonNum]["我方"] = true
				WAR.Person[WAR.PersonNum]["坐标X"] = WAR.Data["我方X" .. i]
				WAR.Person[WAR.PersonNum]["坐标Y"] = WAR.Data["我方Y" .. i]
				WAR.Person[WAR.PersonNum]["死亡"] = false
				WAR.Person[WAR.PersonNum]["人方向"] = 2
				--无酒不欢：调整战斗初始面向
				--战海大富
				if WAR.ZDDH == 259 then
					WAR.Person[WAR.PersonNum]["人方向"] = 1
				end
				--双挑公孙止
				if WAR.ZDDH == 273 then
					WAR.Person[WAR.PersonNum]["人方向"] = 1
				end
				--杨过单金轮
				if WAR.ZDDH == 275 then
					WAR.Person[WAR.PersonNum]["人方向"] = 0
				end
				--战杨龙
				if WAR.ZDDH == 75 then
					WAR.Person[WAR.PersonNum]["人方向"] = 0
				end
				--蒙哥
				if WAR.ZDDH == 278 then
					WAR.Person[WAR.PersonNum]["人方向"] = 0
				end
				--周芷若夺掌门
				if WAR.ZDDH == 279 then
					WAR.Person[WAR.PersonNum]["人方向"] = 0
				end
				--单挑赵敏
				if WAR.ZDDH == 293 then
					WAR.Person[WAR.PersonNum]["人方向"] = 0
				end
				--玄冥二老
				if WAR.ZDDH == 295 then
					WAR.Person[WAR.PersonNum]["人方向"] = 0
				end
				--三挑岳不群
				if WAR.ZDDH == 298 then
					WAR.Person[WAR.PersonNum]["人方向"] = 1
				end
				--侠客邪
				if WAR.ZDDH == 170 then
					WAR.Person[WAR.PersonNum]["人方向"] = 0
				end
				WAR.PersonNum = WAR.PersonNum + 1
				WAR.MCRS = WAR.MCRS + 1
			end
		end

		if WAR.PersonNum > 0 and WAR.ZDDH ~= 235 then
			return 
		end

		--lib.PicLoadFile(string.format(CC.FightPicFile[1],JY.Person[pid]["头像代号"]),
		--string.format(CC.FightPicFile[2],JY.Person[pid]["头像代号"]), 4+i);
		local n=0;
		local m=0;
		for j=1,5 do
			if JY.Person[pid]['出招动画帧数'..j]>0 then
				if j>1 then
					m=j;
					break;
				end
				n=n+JY.Person[pid]['出招动画帧数'..j]
			end
		end
		p[i]= {id=pid, name=JY.Person[pid]["姓名"]; 
        zid = JY.Person[pid]["头像代号"]; 
		Pic=n*8+JY.Person[pid]['出招动画帧数'..m]*6, PicNum=JY.Person[pid]['出招动画帧数'..m], idx=0, 
		x=x2+((i+3)%4)*pic_w, y=y2+math.modf((i+3)/4)*pic_h, x=x2+((i+2)%3)*pic_w, y=y2+math.modf((i+2)/3)*pic_h, picked=0,
		};
		--无酒不欢：强制出战的队友
		for j = 1, 6 do
			if WAR.Data["手动选择参战人" .. j] == p[i].id then
				p[i].picked = 1
				WAR.MCRS = WAR.MCRS + 1
			end
		end
	end
	
	--战三渡
	if WAR.ZDDH == 253 then
		WAR.MCRS = WAR.MCRS + 3
	end
	
	--逍遥御风 天池怪侠 太白诗仙 古墓黄杉 金蛇郎君
	--限定1人
	if WAR.ZDDH == 281 or WAR.ZDDH == 283 or WAR.ZDDH == 284 or WAR.ZDDH == 285 or WAR.ZDDH == 286 then
		WAR.MCRS = WAR.MCRS + 5
	end
	
	--刀剑合璧
	--限定2人
	if WAR.ZDDH == 280 then
		WAR.MCRS = WAR.MCRS + 4
	end
 
	p[0]={name="全部选择"};

	if T_Num>6 then
		p[0]={name="自动选择"}
	end

	p[T_Num+1]={name="开始战斗"};
	local leader=-1;
	--无酒不欢：强制出战的预设leader
	for i=1,T_Num do
		if p[i].picked == 1 then
			leader = i
			break
		end
	end
	DrawBoxTitle(width,height,'出战准备',C_ORANGE);
	local select=1;
	local sid=lib.SaveSur(0,0,CC.ScreenW,CC.ScreenH);
	local function redraw(zdrs)
		lib.LoadSur(sid,0,0);
		DrawBox(x0,y1,x0+CC.DefaultFont*5+4*2,y1+CC.DefaultFont*(T_Num+2)+4*(T_Num+3),C_WHITE);
		for i=0,T_Num+1 do
			local str=p[i].name;
			--选中时的名字显示
			--小于7人，名字前显示√表示已选择
			--大于等于7人，名字前显示×表示需要取消方可开始战斗
			if i > 0 and i < T_Num+1 and p[i].picked > 0 then
				if zdrs < 7 then
					str="√"..str;
				else
					str="×"..str
				end
			--未选中的只显示名字
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
				--DrawString(p[i].x-CC.DefaultFont,p[i].y-CC.DefaultFont/2,"出战",C_WHITE,CC.DefaultFont*2/3)
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
				if p[0].name=="全部选择" or p[0].name=="自动选择" then
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
					p[0].name="全部取消";
				elseif p[0].name=="全部取消" then
					for i=1,T_Num do
						if p[i].picked == 2 then
							p[i].picked=0;
							WAR.MCRS=WAR.MCRS-1
						end
					end
					leader=-1;
					--无酒不欢：强制出战的预设leader
					for i=1,T_Num do
						if p[i].picked == 1 then
							leader = i
							break
						end
					end
					p[0].name="全部选择"

					if T_Num>6 then
						p[0].name="自动选择"
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
							WAR.Person[WAR.PersonNum]["人物编号"]=JY.Base["队伍" ..px[i]]
							WAR.Person[WAR.PersonNum]["我方"]=true
							WAR.Person[WAR.PersonNum]["坐标X"]=WAR.Data["我方X"..i]
							WAR.Person[WAR.PersonNum]["坐标Y"]=WAR.Data["我方Y"..i]
							WAR.Person[WAR.PersonNum]["死亡"]=false
							WAR.Person[WAR.PersonNum]["人方向"]=2
							--无酒不欢：调整战斗初始面向
							--战海大富
							if WAR.ZDDH == 259 then
								WAR.Person[WAR.PersonNum]["人方向"] = 1
							end
							--双挑公孙止
							if WAR.ZDDH == 273 then
								WAR.Person[WAR.PersonNum]["人方向"] = 1
							end
							--杨过单金轮
							if WAR.ZDDH == 275 then
								WAR.Person[WAR.PersonNum]["人方向"] = 0
							end
							--战杨龙
							if WAR.ZDDH == 75 then
								WAR.Person[WAR.PersonNum]["人方向"] = 0
							end
							--蒙哥
							if WAR.ZDDH == 278 then
								WAR.Person[WAR.PersonNum]["人方向"] = 0
							end
							--周芷若夺掌门
							if WAR.ZDDH == 279 then
								WAR.Person[WAR.PersonNum]["人方向"] = 0
							end
							--单挑赵敏
							if WAR.ZDDH == 293 then
								WAR.Person[WAR.PersonNum]["人方向"] = 0
							end
							--无聊单挑葵花
							if WAR.ZDDH == 355 then
								WAR.Person[WAR.PersonNum]["人方向"] = 0
							end							
							--玄冥二老
							if WAR.ZDDH == 295 then
								WAR.Person[WAR.PersonNum]["人方向"] = 0
							end
							--三挑岳不群
							if WAR.ZDDH == 298 then
								WAR.Person[WAR.PersonNum]["人方向"] = 1
							end
							--侠客邪
							if WAR.ZDDH == 170 then
								WAR.Person[WAR.PersonNum]["人方向"] = 0
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
						p[0].name="全部选择"

						if T_Num>6 then
							p[0].name="自动选择"
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
							p[0].name="全部取消";
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

--葵花魅影
function kuihuameiying()
	local x, y
	for i = 0, WAR.PersonNum - 1 do
		if WAR.Person[i]["我方"] ~= WAR.Person[WAR.CurID]["我方"] then
			x, y = WAR.Person[i]["坐标X"], WAR.Person[i]["坐标Y"]
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
		CurIDTXDH(WAR.CurID, 120, 1, "葵花魅影", C_GOLD)
		lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, -1)
		lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, -1)
        lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, -1)
		WarDrawMap(0)
		WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"] = telx, tely
		WarDrawMap(0)
		CurIDTXDH(WAR.CurID, 120, 1, "葵花魅影", C_GOLD)
		lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, WAR.Person[WAR.CurID]["贴图"])
		lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, WAR.CurID)
        SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, JY.Person[WAR.Person[WAR.CurID]["人物编号"]]['头像代号'])
        
		WarDrawMap(0)
		return true
	else
		return false
	end
end

--辟邪招式
function BiXieZhaoShi(id,MiaofaWX)
	WAR.BXZS = 0
	if not WAR.BXLQ[id] then
		WAR.BXLQ[id] = {0,0,0,0,0,0}
	end
	local zs={
	{name="指打奸邪",Usable=true,m1=1,m2=1,a1=1,a2=3+MiaofaWX,a3=3+MiaofaWX},
	{name="飞燕穿柳",Usable=true,m1=3,m2=1,a1=10,a2=8+MiaofaWX,a3=7+MiaofaWX,a4=6+MiaofaWX},
	{name="花开见佛",Usable=true,m1=0,m2=0,a1=5,a2=6+MiaofaWX,a3=3+MiaofaWX},
	{name="锺馗抉目",Usable=true,m1=0,m2=5,a1=2,a2=4+MiaofaWX},
	{name="扫荡群魔",Usable=true,m1=3,m2=1,a1=11,a2=6+MiaofaWX},
	{name="紫气东来",Usable=true,m1=0,m2=6,a1=3,a2=3+MiaofaWX,a3=3+MiaofaWX},
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
		Cat('实时特效动画')
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
		DrawString(500, 520, "招式气攻："..CC.KFMove[48][choice][2], C_WHITE, size)
		if WAR.BXCD[choice] == 0 or match_ID(id, 36) then
			DrawString(500, 570, "冷却时间：无", C_WHITE, size)
		else
			DrawString(500, 570, "冷却时间："..WAR.BXCD[choice].."回合", C_WHITE, size)
		end
		if choice > 2 and not PersonKF(id,105) then
			DrawString(500, 620, "习得葵花神功后方可使用", C_WHITE, size)
		elseif WAR.BXLQ[id][choice] > 0 then
			DrawString(500, 620, "冷却中，"..WAR.BXLQ[id][choice].."回合后可再次使用", C_WHITE, size)

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

--九阳招式
function JIUYANGZhaoShi(id,MiaofaWX)
	WAR.JYZS = 0
	if not WAR.JYLQ[id] then
		WAR.JYLQ[id] = {0,0,0}
	end
	local zs={
   {name="他强由他强，清风拂山冈",Usable=true,m1=0,m2=6,a1=3,a2=3+MiaofaWX,a3=3+MiaofaWX},
   {name="他横任他横，明月照大江",Usable=true,m1=0,m2=6,a1=3,a2=3+MiaofaWX,a3=3+MiaofaWX},
   {name="狠来他自恶，一口真气足",Usable=true,m1=0,m2=6,a1=3,a2=3+MiaofaWX,a3=3+MiaofaWX},
	}
	local size = CC.DefaultFont
	--local surid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)
	local m1, m2, a1, a2, a3, a4, a5,a6
	local choice = 1

	while true do
		if JY.Restart == 1 then
			break
		end
		Cat('实时特效动画')
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
		DrawString(500, 570, "招式气攻："..CC.KFMove[106][choice][2], C_WHITE, size)
		if WAR.JYCD[choice] == 0  then
			DrawString(500, 620, "冷却时间：无", C_WHITE, size)
		else
			DrawString(500, 620, "冷却时间："..WAR.JYCD[choice].."回合", C_WHITE, size)
		end
		if  WAR.JYLQ[id][choice] > 0 then
			DrawString(500, 670, "冷却中，"..WAR.JYLQ[id][choice].."回合后可再次使用", C_WHITE, size)
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


--太玄招式
function TaiXuanZhaoShi()
	WAR.TXZS = 0
	local zs={	
	{name="太玄神功·拳"},
	{name="太玄神功·指"},
	{name="太玄神功·剑"},
	{name="太玄神功·刀"},
	{name="太玄神功·奇"}
	}
	local size = CC.DefaultFont
	--local surid = lib.SaveSur(0, 0, CC.ScreenW, CC.ScreenH)

	local choice = 1

	while true do
		if JY.Restart == 1 then
			break
		end
		Cat('实时特效动画')
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
		local id = WAR.Person[i]['人物编号']
		if WAR.Person[i]['死亡'] == false and WAR.Person[WAR.CurID]['我方'] ~= WAR.Person[i]['我方']  then 
			local x,y = WAR.Person[i]['坐标X'],WAR.Person[i]['坐标Y']
			local eft = GetWarMap(x,y,4)
			if match_ID(id, 9982) and JY.Person[id]['生命'] > 0 and  JY.Person[id]['体力'] > 10 and fjpd(WAR.CurID) == false and eft > 0 and WAR.Person[i]['先手反击'] == -1  then
				WAR.Person[i]['先手反击'] = 1
				WAR.Person[i]["移动步数"] = 0
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
				local pid = WAR.Person[WAR.CurID]['人物编号']
				local tx = {}
				local at = WAR.CurID
				tx.dh = WAR.Person[WAR.CurID]['特效动画']
				tx.wz1 = WAR.Person[WAR.CurID]['特效文字1']
				tx.wz2 = WAR.Person[WAR.CurID]['特效文字2']
				tx.wz3 = WAR.Person[WAR.CurID]['特效文字3']
				tx.wz4 = WAR.Person[WAR.CurID]['特效文字4']
				WAR.Person[WAR.CurID]['特效动画'] = -1
				WAR.Person[WAR.CurID]['特效文字1'] = nil
				WAR.Person[WAR.CurID]['特效文字2'] = nil
				WAR.Person[WAR.CurID]['特效文字3'] = nil
				WAR.Person[WAR.CurID]['特效文字4'] = nil
	
				WAR.CurID = i
			
				WarDrawMap(0)
				CurIDTXDH(WAR.CurID, 84,1, "无我无剑", C_GOLD)
				WarSet()
				if WAR.AutoFight == 1 or WAR.Person[i]['我方'] == false or WAR.ZDDH == 354 then 
					War_AutoFight()
				else 
					--War_FightMenu()
					Cat('武功')
				end
				WAR.Person[i]['先手反击'] = -1
				WAR.CurID = at
				WarDrawMap(0)

				WAR.Person[WAR.CurID]['特效动画'] = tx.dh
				WAR.Person[WAR.CurID]['特效文字1'] = tx.wz1
				WAR.Person[WAR.CurID]['特效文字2'] = tx.wz2
				WAR.Person[WAR.CurID]['特效文字3'] = tx.wz3
				WAR.Person[WAR.CurID]['特效文字4'] = tx.wz4
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
	--say(WAR.Person[WAR.CurID]['人物编号'],0)
	return pd
end

function savewar()
	local file = io.open(CONFIG.DataPath..'1', "w");
	assert(file);
	for i,v in pairs(WAR) do
		local t = type(WAR[i]); --判断对象类型
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

--是否触发反击，用于反击的一些判定
function fjpd(i)
	local id = WAR.Person[i]['人物编号']
	if WAR.Person[i]["反击武功"] ~= -1  then 
		return true
	end
	if WAR.Person[i]["先手反击"] ~= -1  then 
		return true
	end
	if WAR.Person[i]["反击"] ~= -1 then 
		return true
	end
	return false
end

--免疫反击判定
function MyFj(i)
	local id = WAR.Person[i]['人物编号']
	if Curr_NG(id,204) then 
		return true
	end
	return false
end

function fjtx()
	local at = WAR.CurID
	for i = 0,WAR.PersonNum - 1 do 
		local id = WAR.Person[i]['人物编号']
		if WAR.Person[i]['死亡'] == false and WAR.Person[WAR.CurID]['我方'] ~= WAR.Person[i]['我方'] then 
			if fjpd(WAR.CurID) == false and WAR.Person[i]['反击'] == 1 and JY.Person[id]['生命'] > 0 and JY.Person[id]['体力'] > 10   then 
				WAR.Person[i]["移动步数"] = 0
				WAR.CurID = i
				WarDrawMap(0)
				if WAR.AutoFight == 1 or WAR.Person[i]['我方'] == false then 
					War_AutoFight()
				else 
					Cat('武功')
					--War_FightMenu()
				end
			
				WAR.CurID = at
				WarDrawMap(0)
			end
				WAR.Person[i]['反击'] = -1
		end
	end	
end

function Bagua(pid)
	
	local str = {}
	local lb = {'临','兵','斗','者','列','阵','皆','在','前'}

	local jl = {30,25,25,25,25,20,20,15,15}
	if JY.Base["天书数量"] < 10 then 
		table.remove(lb,#lb)
	end
	if JY.Base["天书数量"] < 7 then 
		table.remove(lb,#lb)
	end
	if JY.Person[pid]['实战'] < 500 then 
		table.remove(lb,#lb)
	end
	if JY.Person[pid]['实战'] < 400 then 
		table.remove(lb,#lb)
	end
	if JY.Person[pid]['实战'] < 300 then 
		table.remove(lb,#lb)
	end
	if JY.Person[pid]['实战'] < 200 then 
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

	local x0,y0 = WAR.Person[WAR.CurID]['坐标X'],WAR.Person[WAR.CurID]['坐标Y']
	local a = 2546
	local c = 1
	local e = 1
	local zoom = CONFIG.Zoom/100
   if #str > 0 then
		local hb = GetS(JY.SubScene, WAR.Person[WAR.CurID]['坐标X'], WAR.Person[WAR.CurID]['坐标Y'], 4)*CONFIG.Zoom/100
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
				Cat('实时特效动画')
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

Ct['实时特效动画'] = function(s)
	CleanWarMap(9,-1)

	local bx,by = CC.ScreenW/936,CC.ScreenH/701 
	for i = 0,WAR.PersonNum-1 do 
		local id = WAR.Person[i]['人物编号']
		local xx,yy = WAR.Person[i]['坐标X'],WAR.Person[i]['坐标Y']
		   
		local x0 = WAR.Person[WAR.CurID]["坐标X"]
		local y0 = WAR.Person[WAR.CurID]["坐标Y"]
		local dx = WAR.Person[i]["坐标X"] - x0
		local dy = WAR.Person[i]["坐标Y"] - y0
		local rx = CC.XScale * (dx - dy) + CC.ScreenW / 2
		local ry = CC.YScale * (dx + dy) + CC.ScreenH / 2
		local hb = GetS(JY.SubScene, dx + x0, dy + y0, 4)*CONFIG.Zoom/100
		ry = ry - hb
		
        if	WAR.Person[i]['死亡'] == false then
		
				if WAR.Person[i]['护盾'] ~= nil and WAR.Person[i]['护盾'] > 0 then
					local hd = WAR.Person[i]['护盾']
					if CC.HD[hd] ~= nil then
						local ys = math.ceil(30/CC.BattleDelay)
						local t1 = CC.HD[hd].tt
						local t2 = CC.HD[hd].tt1
						if WAR.Person[i]['护盾延迟'] == nil then 
							WAR.Person[i]['护盾延迟'] = 1 
						else 
							if WAR.Person[i]['护盾延迟'] < ys then
								WAR.Person[i]['护盾延迟'] = WAR.Person[i]['护盾延迟'] + 1
							end
						end
						if WAR.Person[i]['护盾延迟'] == ys then 
							if WAR.Person[i]['护盾贴图'] == -1 then 
								WAR.Person[i]['护盾贴图'] = t1 
							else 
								WAR.Person[i]['护盾贴图'] = WAR.Person[i]['护盾贴图'] + 1
							end	
							if WAR.Person[i]['护盾贴图'] > t2 then 
								WAR.Person[i]['护盾贴图'] = t1 
							end	
							SetWarMap(xx,yy,9,WAR.Person[i]['护盾贴图']*2)	
							WAR.Person[i]['护盾延迟'] = 0
						else	
							if WAR.Person[i]['护盾贴图'] == -1 then 
								WAR.Person[i]['护盾贴图'] = t1 
							end
							SetWarMap(xx,yy,9,WAR.Person[i]['护盾贴图']*2)
						end	
					end
				end	
        end       
	end
end

function Delay(tt,x,y)
	for i = 1, tt do
		Cat('实时特效动画')
		if x ~= nil and y ~= nil then 
		   WarDrawMap(1, x, y) 
		else 
		   WarDrawMap(0) 
		end
		ShowScreen()
		lib.Delay(CC.BattleDelay)
	end
end

Ct['菜单'] = function(me,num,x,y,color,size,lx,color2,h)
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
		Cat('实时特效动画')
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
		elseif menu[1] ~= nil and string.sub(menu[1][1],1,4) == '蓄力' and X == VK_P then 
			return 1
		elseif menu[2] ~= nil and string.sub(menu[2][1],1,4) == '防御' and X == VK_D then 
			return 2
		elseif menu[3] ~= nil and string.sub(menu[3][1],1,4) == '等待' and X == VK_W then 
			return 3
		elseif menu[4] ~= nil and string.sub(menu[4][1],1,4) == '集中' and X == VK_J then 
			return 4
		elseif menu[5] ~= nil and string.sub(menu[5][1],1,4) == '休息' and X == VK_R then 
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


Ct['战斗菜单'] = function()
	
	local bx,by = CC.ScreenW/936,CC.ScreenH/701 
	
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	
	local warmenu = {
					{'移动Ｍ','移动',1},
					{'武功Ａ','武功',1},
					{'绝技Ｌ','绝技',1},
					{'运功Ｇ','运功',1},
					{'战术Ｓ','战术',1},
					{'物品Ｅ','物品',1},
					{'其他Ｈ','其他',1},
					{'撤退Ｃ','撤退',1},
					{'自动Ｔ','自动',1},
	
				}
	
	if JY.Person[pid]["特色指令"] == 1 then
		--如果是畅想
		if pid == 0 then
			--'绝技'
			warmenu[3][1] = GRTS[JY.Base["畅想"]]..'Ｌ'
		else
			--'绝技'
			warmenu[3][1] = GRTS[pid]..'Ｌ'
		end
	else
		--'绝技'
		warmenu[3][3] = 0
	end
  
	--虚竹
	if match_ID(pid, 49) then
		--如果没有中生死符的人物则不显示特色指令
		local t = 0
		for i = 0, WAR.PersonNum - 1 do
			local wid = WAR.Person[i]["人物编号"]
			if WAR.TZ_XZ_SSH[wid] == 1 and WAR.Person[i]["死亡"] == false then
				t = 1
			end
		end
		--'绝技'
		if t == 0 then
			warmenu[3][3] = 0
		end
		--体力小于20不显示特色指令
		--'绝技'
		if JY.Person[pid]["体力"] < 20 then
			warmenu[3][3] = 0
		end
	end
  
	--祖千秋
	if match_ID(pid, 88) then
		--如果周围没有队友不显示特色指令
		local yes = 0
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["我方"] == true and WAR.Person[i]["死亡"] == false and RealJL(WAR.CurID, i, 5) and i ~= WAR.CurID then
				yes = 1
			end
		end
		--'绝技'
		if yes == 0 then
			warmenu[3][3] = 0
		end
		--体力小于20不显示特色指令
		--内力小于1000不显示
		--'绝技'
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 then
			warmenu[3][3] = 0
		end
	end

	--人厨子
	if match_ID(pid, 89) then
		--如果周围没有队友不显示特色指令
		local px, py = WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"]
		local mxy = {
					{WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"] + 1}, 
					{WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"] - 1}, 
					{WAR.Person[WAR.CurID]["坐标X"] + 1, WAR.Person[WAR.CurID]["坐标Y"]}, 
					{WAR.Person[WAR.CurID]["坐标X"] - 1, WAR.Person[WAR.CurID]["坐标Y"]}}

		local yes = 0
		for i = 1, 4 do
			if GetWarMap(mxy[i][1], mxy[i][2], 2) >= 0 then
			local mid = GetWarMap(mxy[i][1], mxy[i][2], 2)
			if inteam(WAR.Person[mid]["人物编号"]) then
				yes = 1
				end
			end  
		end
		--'绝技'
		if yes == 0 then
			warmenu[3][3] = 0
		end
		--'绝技'
		--体力小于25不显示特色指令
		if JY.Person[pid]["体力"] < 25 then
			warmenu[3][3] = 0
		end
	end

	--张无忌
	if match_ID(pid, 9) then
		--如果周围没有队友不显示特色指令
		local yes = 0
		for i = 0, WAR.PersonNum - 1 do
			if WAR.Person[i]["我方"] == true and WAR.Person[i]["死亡"] == false and RealJL(WAR.CurID, i, 8) and i ~= WAR.CurID then
				yes = 1
			end
		end
		--'绝技'
		if yes == 0 then
			warmenu[3][3] = 0
		end
		--'绝技'
		--体力小于20不显示特色指令
		if JY.Person[pid]["体力"] < 20 then
			warmenu[3][3] = 0
		end
	end
 
	--霍青桐指挥指令
	if match_ID(pid, 74) then
		--体力小于10不显示特色指令
		--'绝技'
		if JY.Person[pid]["体力"] < 10 or JY.Person[pid]["内力"] < 150 or  WAR.HQT_CD > 0 then
			warmenu[3][3] = 0
		end
	end
	
	--慕容复指令 幻梦
	if match_ID(pid, 51) then
		--体力小于20不显示特色指令
		--'绝技'
		if JY.Person[pid]["体力"] < 20 then
			warmenu[3][3] = 0
		end
	end

	--小昭指令 影步
	if match_ID(pid, 66) then
		--体力小于30，或内力小于2000不显示特色指令
		--'绝技'
		if JY.Person[pid]["体力"] < 30 or JY.Person[pid]["内力"] < 2000 then
			warmenu[3][3] = 0
		end
	end
  
	--钟灵指令 灵貂
	if match_ID(pid, 90) then
		--体力小于10不显示特色指令
		if JY.Person[pid]["体力"] < 10 then
			--'绝技'
			warmenu[3][3] = 0
		end
	end
	
	--喵姐指令 变装
	if match_ID(pid, 92) then
		--体力小于20不显示特色指令
		if JY.Person[pid]["体力"] < 20 then
			--'绝技'
			warmenu[3][3] = 0
		end
	end
	--丘机处 止杀
	if match_ID(pid, 68) then
		--体力小于20不显示特色指令
		--'绝技'
		if JY.Person[pid]["体力"] < 20 or WAR.JSZT1[pid]> 0 then
			warmenu[3][3] = 0
		end
	end	
	--胡斐指令 飞狐
	if match_ID(pid, 1) then
		--体力小于20不显示特色指令
		--'绝技'
		if JY.Person[pid]["体力"] < 20 then
			warmenu[3][3] = 0
		end
	end
	
	--鸠摩智指令 幻化
	if match_ID(pid, 103) then
		--'绝技'
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 then
			warmenu[3][3] = 0
		end
	end
	
	--达尔巴指令 死战
	if match_ID(pid, 160) then
		--'绝技'
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 or WAR.SZSD ~= -1 then
			warmenu[3][3] = 0
		end
	end
	
	--金轮 龙象
	if match_ID(pid, 62) then
		--'绝技'
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 then
			warmenu[3][3] = 0
		end
	end
	
	--黄蓉 遁甲
	if match_ID(pid, 56) then
		--'绝技'
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 then
			warmenu[3][3] = 0
		end
	end
	
	--韦小宝 口才
	if match_ID(pid, 601) then
		--'绝技'
		if JY.Person[pid]["体力"] < 30 then
			warmenu[3][3] = 0
		end
	end
	
	--苗人凤 破军
	if match_ID(pid, 3) then
		--'绝技'
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 then
			warmenu[3][3] = 0
		end
	end
	
	--何太冲 铁琴
	if match_ID(pid, 7) then
		--'绝技'
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 then
			warmenu[3][3] = 0
		end
	end
	
	--方证 金身
	--'绝技'
	if match_ID(pid, 149) then
		if JY.Person[pid]["体力"] < 20 or JY.Person[pid]["内力"] < 1000 then
			warmenu[3][3] = 0
		end
	end
	--李寻欢 飞刀
	if match_ID(pid, 498) then
		--'绝技'
		if  JY.Person[pid]["内力"] < 1000 then
			warmenu[3][3] = 0
		end
	end	
	--萧秋水 天剑
	--'绝技'
	if match_ID(pid, 652) and JY.Base["天书数量"] < 7 then
			warmenu[3][3] = 0
		end
	
	--阎基 虚弱
	if match_ID(pid, 4) then	
		--'绝技'
		if JY.Person[pid]["体力"] < 20 then
			warmenu[3][3] = 0
		end
	end

------------------------------------------------------
------------------------------------------------------
	--出左右时，移动，解毒，医疗，物品，特色，自动不可见
	if WAR.ZYHB == 2 then
		for i = 1,#warmenu do
			if i == 2 or i == 4 or i == 5  then
				warmenu[i][3] = 1
			else 	
				warmenu[i][3] = 0
			end
		end
	end
  
	--体力小于5或者已经移动过时，移动不可见
	if JY.Person[pid]["体力"] <= 5 or WAR.Person[WAR.CurID]["移动步数"] <= 0 then
		warmenu[1][3] = 0
		--isEsc = 1
	end
  
	--判断最小内力，是否可显示攻击
	local minv = War_GetMinNeiLi(pid)
	if JY.Person[pid]["内力"] < minv or JY.Person[pid]["体力"] < 10 then
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
		Cat('实时特效动画')
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
			--移动
		elseif X == VK_M then
			if warmenu[1][3] == 1 then
				local r = Cat(warmenu[1][2])
				if r == 1 then 
					return 1 
				end
			end	
			--武功
		elseif X == VK_A then
			if warmenu[2][3] == 1 then
				local r = Cat(warmenu[2][2])
				if r == 1 then 
					break
				end
			end	
			--绝技
		elseif X == VK_L then
			if warmenu[3][3] == 1 then
				local r = Cat(warmenu[3][2])
				if r == 1 then 
					break
				end
			end	
			--运功
		elseif X == VK_G then
			if warmenu[4][3] == 1 then
				local r = Cat(warmenu[4][2])
				if r == 1 then 
					break
				end
			end	
			--战术
		elseif X == VK_S then
			if warmenu[5][3] == 1 then
				local r = Cat(warmenu[5][2])
				if r == 1 then 
					break
				end
			end	
			--物品
		elseif X == VK_E then
			if warmenu[6][3] == 1 then
				local r = Cat(warmenu[6][2])
				if r == 1 then 
					break
				end
			end	
			--其他
		elseif X == VK_H then
			if warmenu[7][3] == 1 then
				local r = Cat(warmenu[7][2])
				if r == 1 then 
					break
				end
			end	
			--撤退
		elseif X == VK_C then
			if warmenu[8][3] == 1 then
				local r = Cat(warmenu[8][2])
				if r == 1 then 
					break
				end
			end	
			--自动
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
			--解毒
				if r == 1 then 
					break
				end
		elseif X == VK_Q and warmenu[7][3] == 1 then 
			local r = War_DecPoisonMenu()
			--医疗
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

Ct['移动'] = function()
	if WAR.Person[WAR.CurID]["人物编号"] ~= -1 then
		WAR.ShowHead = 0
		if WAR.Person[WAR.CurID]["移动步数"] <= 0 then
		  return 0
		end
		War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["移动步数"], 0)
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
			if WAR.Person[i]["我方"] ~= WAR.Person[WAR.CurID]["我方"] and WAR.Person[i]["死亡"] == false then
				ydd[n] = i
				n = n + 1
			end
		end
		local dx = ydd[math.random(n - 1)]
		local DX = WAR.Person[dx]["坐标X"]
		local DY = WAR.Person[dx]["坐标Y"]
		local YDX = {DX + 1, DX - 1, DX}
		local YDY = {DY + 1, DY - 1, DY}
		local ZX = YDX[math.random(3)]
		local ZY = YDY[math.random(3)]
		if not SceneCanPass(ZX, ZY) or GetWarMap(ZX, ZY, 2) < 0 then
		SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, -1)
		SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, -1)
        SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, -1)
		WAR.Person[WAR.CurID]["坐标X"] = ZX
		WAR.Person[WAR.CurID]["坐标Y"] = ZY
		SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, WAR.CurID)
		SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, WAR.Person[WAR.CurID]["贴图"])
        SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, JY.Person[WAR.Person[WAR.CurID]["人物编号"]]['头像代号'])
		end
	end
	return 1
end

Ct['武功'] = function()
	local bx,by = CC.ScreenW/936,CC.ScreenH/701 
	
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	
	local numwugong = 0
	local kfmenu = {}

	for i = 1, JY.Base["武功数量"] do
		local tmp = JY.Person[pid]["武功" .. i]
		if tmp > 0 then
			kfmenu[i] = {tmp, i, 1}
	
			--内功无法攻击
			--游坦之可以
			if match_ID(pid, 48) == false and JY.Wugong[tmp]["武功类型"] == 6
			then
				kfmenu[i][3] = 0
			end
			
			--轻功无法攻击
			if JY.Wugong[tmp]["武功类型"] == 7  or 
           (tmp == 85 or tmp == 87 or tmp == 88 or tmp == 144 or tmp == 175  or tmp == 182  or tmp == 199)then
				kfmenu[i][3] = 0
			end
			
			--斗转星移不显示
			if tmp == 43 then
				kfmenu[i][3] = 0
			end

			--如果主角是天罡，内功可攻击，畅想第一格内功可攻击
			if ((pid == 0 and JY.Base["标准"] == 6) or (pid == 0 and JY.Base["畅想"] > 0 and i == 1)) and JY.Wugong[tmp]["武功类型"] == 6 then
				kfmenu[i][3] = 1
			end
			--林平之 东方 萧半和 显示葵花神功
			if tmp == 105 and (match_ID(pid, 36) or match_ID(pid, 27) or match_ID(pid, 189))  then
				kfmenu[i][3] = 1
			end
		   
			--石破天 显示太玄神功
			if tmp == 102 and match_ID_awakened(pid, 38, 1) then
				kfmenu[i][3] = 1
			end
		  
			--张无忌 显示九阳神功
			if tmp == 106 and match_ID(pid, 9) then
				kfmenu[i][3] = 1
			end
			--斗酒僧 显示九阳神功
			if tmp == 106 and (match_ID(pid, 638) or match_ID(pid,9999)) then
				kfmenu[i][3] = 1
			end			
		  
			--狄云 显示神经照
			if tmp == 94 and match_ID(pid, 37) then
				kfmenu[i][3] = 1
			end
		  
			--慕容复 显示斗转星移
			if tmp == 43 and match_ID(pid, 51) then
				kfmenu[i][3] = 1
			end
		  
			--欧阳锋 显示逆运
			if tmp == 104 and match_ID(pid, 60) then
				kfmenu[i][3] = 1
			end

			--小昭 显示圣火
			if tmp == 93 and match_ID(pid, 66) then
				kfmenu[i][3] = 1
			end
		  
			--内力少不显示
			if JY.Person[pid]["内力"] < JY.Wugong[tmp]["消耗内力点数"] then
				kfmenu[i][3] = 0
			end

			--体力低于10不显示
			if JY.Person[pid]["体力"] < 10 then
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
		Cat('实时特效动画')
		Cls()
		
		for i = 1,num do 
			lib.PicLoadCache(92,1*2,bx*25+(i-1)*bx*40,CC.ScreenH-by*60,2,255)
			local cl = C_WHITE
			if i == cot then 
				cl = C_RED
			end
			local stn = string.len(JY.Wugong[menu[i+cot1][1]]['名称'])/2
			local hsize = bx*100/stn
			draw3(JY.Wugong[menu[i+cot1][1]]['名称'],bx*25+(i-1)*bx*40,CC.ScreenH-by*60- ((stn-1)*hsize+size)/2, cl, size,nil,hsize)
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

Ct['绝技'] = function()
	return War_TgrtsMenu()
end

Ct['运功'] = function()
	return War_YunGongMenu()
end

Ct['战术'] = function()
	return War_TacticsMenu()
end

Ct['其他'] = function()
	return War_OtherMenu()
end

Ct['物品'] = function()
	return War_ThingMenu()
end

Ct['撤退'] = function()
	return War_Retreat()
end

Ct['自动'] = function()
	return War_AutoMenu()
end

function Ckstatus()
--function MapWatch()
 --WAR.ShowHead = 0
	local x = WAR.Person[WAR.CurID]["坐标X"];
	local y = WAR.Person[WAR.CurID]["坐标Y"];
	local page = 1

	War_CalMoveStep(WAR.CurID,255,1)
	Cat('实时特效动画')
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
		if WAR.Person[i]["坐标X"] == x and WAR.Person[i]["坐标Y"] == y and WAR.Person[i]["死亡"] == false then
			id =  i-- WAR.Person[i]["人物编号"]
			break;
		end
	end

	if id >= 0 then
		--Cat('显示状态',id,page)
		ShowPersonStatus(id)
	end

--end
end

--护盾停止
Ct['护盾停止'] = function(i)
	WAR.Person[i]['护盾'] = -1 
	WAR.Person[i]['护盾贴图'] = -1 
	WAR.Person[i]['护盾延迟'] = nil
end

Ct['神游太虚'] = function(x,y)
	local id = WAR.Person[WAR.CurID]['人物编号']
	local x0,y0 = WAR.Person[WAR.CurID]['坐标X'],WAR.Person[WAR.CurID]['坐标Y']
	PlayWavE(5)
	CurIDTXDH(WAR.CurID, 129,1,'神游太虚')
	lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, -1)
	lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, -1)
    lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, -1)
	--WarDrawMap(0)
	--CurIDTXDH(WAR.CurID, 129,1)
	WAR.Person[WAR.CurID]["人方向"] = War_Direct(x0, y0, x, y)
	WAR.Person[WAR.CurID]["贴图"] = WarCalPersonPic(WAR.CurID)
	WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"] = x, y
	WarDrawMap(0)
	--CurIDTXDH(WAR.CurID, 129,1)
	lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, WAR.Person[WAR.CurID]["贴图"])
	lib.SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, WAR.CurID)
    SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, JY.Person[WAR.Person[WAR.CurID]["人物编号"]]['头像代号'])
	--WarDrawMap(0)
	CurIDTXDH(WAR.CurID, 129,1,'神游太虚')
end

Ct['神游太虚2'] = function(flag)
	if flag == nil then
		local x0,y0 = WAR.Person[WAR.CurID]['坐标X'],WAR.Person[WAR.CurID]['坐标Y']
		WAR.PD['神游太虚'] = {}
		for j = 0,WAR.PersonNum - 1 do 
			local mid = WAR.Person[j]['人物编号']
			local zbx,zby = WAR.Person[j]['坐标X'],WAR.Person[j]['坐标Y']
			local mx = WAR.Person[j]['人方向']
			local zm = false
			--为啥这么麻烦？我想看看中间的概率
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
			if zm == true and WAR.Person[j]['死亡'] == false and j ~= WAR.CurID and match_ID(mid,9976) then 
				WAR.PD['神游太虚'][mid] = {}
				WAR.PD['神游太虚'][mid].hp = JY.Person[mid]['生命']
				WAR.PD['神游太虚'][mid].nl = JY.Person[mid]['内力']
				WAR.PD['神游太虚'][mid].tl = JY.Person[mid]['体力']
				WAR.PD['神游太虚'][mid].zd = JY.Person[mid]['中毒程度']
				WAR.PD['神游太虚'][mid].ns = JY.Person[mid]['受伤程度']
				WAR.PD['神游太虚'][mid].bs = JY.Person[mid]['冰封程度']
				WAR.PD['神游太虚'][mid].zs = JY.Person[mid]['灼烧程度']
				WAR.PD['神游太虚'][mid]['生命点数'] = WAR.Person[j]['生命点数']
				WAR.PD['神游太虚'][mid]['内力点数'] = WAR.Person[j]['内力点数']
				WAR.PD['神游太虚'][mid]['体力点数'] = WAR.Person[j]['体力点数']
				WAR.PD['神游太虚'][mid]['中毒点数'] = WAR.Person[j]["中毒点数"];
				WAR.PD['神游太虚'][mid]['内伤点数'] = WAR.Person[j]["内伤点数"];
				for k,v in pairs(WAR) do 
					if k ~= 'Person' and k ~= 'Data' then
						local t = type(WAR[k])
						if t == 'table' then
							WAR.PD['神游太虚'][mid][k] = WAR[k][mid]
						end
					end
				end
				WAR.Person[j]['神游太虚'] = 1
			end
		end
	else 
		for j = 0,WAR.PersonNum - 1 do 
			local mid = WAR.Person[j]['人物编号']
			local zbx,zby = WAR.Person[j]['坐标X'],WAR.Person[j]['坐标Y']
			if WAR.Person[j]['死亡'] == false and match_ID(mid,9976) and WAR.Person[j]['神游太虚'] == 1 and (GetWarMap(zbx,zby,4) > 1 or WAR.TXXS[mid] ~= nil) then
				if WAR.PD['神游太虚'][mid] ~= nil then
					WAR.Person[j]["特效动画"] = -1
					WAR.Person[j]["特效文字0"] = nil
					WAR.Person[j]["特效文字1"] = nil
					WAR.Person[j]["特效文字2"] = nil
					WAR.Person[j]["特效文字3"] = nil
					WAR.Person[j]["特效文字4"] = nil
					JY.Person[mid]['生命'] = WAR.PD['神游太虚'][mid].hp
					JY.Person[mid]['内力'] = WAR.PD['神游太虚'][mid].nl
					JY.Person[mid]['体力'] = WAR.PD['神游太虚'][mid].tl
					JY.Person[mid]['中毒程度'] = WAR.PD['神游太虚'][mid].zd 
					JY.Person[mid]['受伤程度'] = WAR.PD['神游太虚'][mid].ns 
					JY.Person[mid]['冰封程度'] = WAR.PD['神游太虚'][mid].bs 
					JY.Person[mid]['灼烧程度'] = WAR.PD['神游太虚'][mid].zs 
					WAR.Person[j]['生命点数'] = WAR.PD['神游太虚'][mid]['生命点数']
					WAR.Person[j]['内力点数'] = WAR.PD['神游太虚'][mid]['内力点数']
					WAR.Person[j]['体力点数'] = WAR.PD['神游太虚'][mid]['体力点数']
					WAR.Person[j]['中毒点数'] = WAR.PD['神游太虚'][mid]['中毒点数']
					WAR.Person[j]['内伤点数'] = WAR.PD['神游太虚'][mid]['内伤点数']
					for k,v in pairs(WAR) do
						if k ~= 'Person' and k ~= 'Data' then
							local t = type(WAR[k])
							if t == 'table' then
								WAR[k][mid] = WAR.PD['神游太虚'][mid][k]
							end
						end
					end
					WAR.Person[j]["特效文字3"] = "神游太虚"
					WAR.Person[j]["特效动画"] = 129
					if WAR.Person[j].TimeAdd ~= nil and WAR.Person[j].TimeAdd < 0 then 
						WAR.Person[j].TimeAdd = 0
					end
					WAR.Person[j]['神游太虚'] = nil
					SetWarMap(zbx,zby,4,0)
					WAR.TXXS[mid] = nil
				end
			end
		end
		
		WAR.PD['神游太虚'] = {}
	end
end

--战场攻击力
function Atk(i)
	local id = WAR.Person[i]['人物编号']
	local gj = 0
	gj = gj + JY.Person[id]['攻击力']
			
	gj  = gj + limitX((JY.Person[id]['内力'] - JY.Person[id]['资质']*10)/60,0)

	for i =1,JY.Base["武功数量"] do  
        local level = 0            
		if JY.Person[id]["武功" .. i] == 108 then
			level = math.modf(JY.Person[id]["武功等级" .. i]/100)+1;
			level = limitX(level/10,0,1)
			gj = gj + math.modf(JY.Person[id]["攻击力"]*0.3*level)
			break
        end
    end
	
	if match_ID(id, 604) then
		gj = gj + TrueYJ(id)
	end
	--NPC的装备不带等级
	if inteam(id) then

		if JY.Person[id]["武器"] >= 0 then
			gj = gj + JY.Thing[JY.Person[id]["武器"]]["加攻击力"]*10+JY.Thing[JY.Person[id]["武器"]]["加攻击力"]*(JY.Thing[JY.Person[id]["武器"]]["装备等级"]-1)*2
		end
		if JY.Person[id]["防具"] >= 0 then
			gj = gj + JY.Thing[JY.Person[id]["防具"]]["加攻击力"]*10+JY.Thing[JY.Person[id]["防具"]]["加攻击力"]*(JY.Thing[JY.Person[id]["防具"]]["装备等级"]-1)*2
		end
		if JY.Person[id]["坐骑"] >= 0 then
			gj = gj + JY.Thing[JY.Person[id]["坐骑"]]["加攻击力"]*10+JY.Thing[JY.Person[id]["坐骑"]]["加攻击力"]*(JY.Thing[JY.Person[id]["坐骑"]]["装备等级"]-1)*2
		end		
	else
		if JY.Person[id]["武器"] >= 0 then
			gj = gj + JY.Thing[JY.Person[id]["武器"]]["加攻击力"]*10+JY.Thing[JY.Person[id]["武器"]]["加攻击力"]*(JY.Thing[JY.Person[id]["武器"]]["装备等级"]-1)*2
		end
		if JY.Person[id]["防具"] >= 0 then
			gj = gj + JY.Thing[JY.Person[id]["防具"]]["加攻击力"]*10+JY.Thing[JY.Person[id]["防具"]]["加攻击力"]*(JY.Thing[JY.Person[id]["防具"]]["装备等级"]-1)*2
		end
		if JY.Person[id]["坐骑"] >= 0 then
			gj = gj + JY.Thing[JY.Person[id]["坐骑"]]["加攻击力"]*10+JY.Thing[JY.Person[id]["坐骑"]]["加攻击力"]*(JY.Thing[JY.Person[id]["坐骑"]]["装备等级"]-1)*2
		end	
		
	end
	--霍青桐
	if match_ID(id, 74) then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == true then
				gj = gj+10
			end		
	    end
	end		
	--林殊
	if match_ID(id, 508) then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == false then
				gj = gj+5
			end		
	    end
	end		
	--for wid = 0, WAR.PersonNum - 1 do
		--队友攻击力加成
	for i,v in pairs(CC.AddAtk) do
		if match_ID(id, v[1]) then
			for wid = 0, WAR.PersonNum - 1 do
				if match_ID(WAR.Person[wid]["人物编号"], v[2]) and WAR.Person[wid]["死亡"] == false then
					gj = gj + v[3]
				end
			end
		end
	end
	--end
    if WAR.PD['西瓜刀·天人'][id] ~= nil then 
        gj = gj*1.5
    end
    
	return gj
end

--战场防御力
function Def(i)
	local id = WAR.Person[i]['人物编号']
	local fy = 0 
	fy = fy + JY.Person[id]['防御力']
	fy  = fy + limitX((JY.Person[id]['内力'] - JY.Person[id]['资质']*10)/60,0)
	
   for i =1,JY.Base["武功数量"] do  
		local level = 0            
		if JY.Person[id]["武功" .. i]==108 then
			level = math.modf(JY.Person[id]["武功等级" .. i]/100)+1;
			level = limitX(level/10,0,1)
			fy = fy + math.modf(JY.Person[id]["防御力"]*0.3*level)	
			break
        end
    end
	
	if match_ID(id, 604) then
		fy = fy + TrueYJ(id)
	end
	if inteam(id) then
		if JY.Person[id]["武器"] >= 0 then	
			fy = fy - JY.Thing[JY.Person[id]["武器"]]["加防御力"]*10+JY.Thing[JY.Person[id]["武器"]]["加防御力"]*(JY.Thing[JY.Person[id]["武器"]]["装备等级"]-1)*2
		end
		if JY.Person[id]["防具"] >= 0 then
			fy = fy - JY.Thing[JY.Person[id]["防具"]]["加防御力"]*10+JY.Thing[JY.Person[id]["防具"]]["加防御力"]*(JY.Thing[JY.Person[id]["防具"]]["装备等级"]-1)*2
		end
		if JY.Person[id]["坐骑"] >= 0 then
			fy = fy - JY.Thing[JY.Person[id]["坐骑"]]["加防御力"]*10+JY.Thing[JY.Person[id]["坐骑"]]["加防御力"]*(JY.Thing[JY.Person[id]["坐骑"]]["装备等级"]-1)*2
		end		
	else
		if JY.Person[id]["武器"] >= 0 then
			fy = fy - JY.Thing[JY.Person[id]["武器"]]["加防御力"]*10+JY.Thing[JY.Person[id]["武器"]]["加防御力"]*(JY.Thing[JY.Person[id]["武器"]]["装备等级"]-1)*2
		end
		if JY.Person[id]["防具"] >= 0 then
			fy = fy - JY.Thing[JY.Person[id]["防具"]]["加防御力"]*10+JY.Thing[JY.Person[id]["防具"]]["加防御力"]*(JY.Thing[JY.Person[id]["防具"]]["装备等级"]-1)*2
		end
		if JY.Person[id]["坐骑"] >= 0 then
			fy = fy - JY.Thing[JY.Person[id]["坐骑"]]["加防御力"]*10+JY.Thing[JY.Person[id]["坐骑"]]["加防御力"]*(JY.Thing[JY.Person[id]["坐骑"]]["装备等级"]-1)*2
		end		
	end
	
	if match_ID(id, 74) then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == true then
				fy = fy+10
			end		
	    end
	end		
	--林殊
	if match_ID(id, 508) then
		for j = 0, WAR.PersonNum - 1 do
			if WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] == false then
				fy = fy+5
			end		
	    end
	end		
	
	--队友防御力加成
	for i,v in pairs(CC.AddDef) do
		if match_ID(id, v[1]) then
			for wid = 0, WAR.PersonNum - 1 do
				if match_ID(WAR.Person[wid]["人物编号"], v[2]) and WAR.Person[wid]["死亡"] == false then
					fy = fy + v[3]
				end
			end
		end
	end

    if WAR.PD['西瓜刀·天人'][id] ~= nil then 
        fy = fy*1.5
    end
	return fy
end

--战场轻功
function Qg(i)
	local id

	id = WAR.Person[i]['人物编号']

	local qg = 0 
	qg = qg + JY.Person[id]['轻功']
	
	qg = qg + limitX((JY.Person[id]['内力'] - JY.Person[id]['资质']*10)/60,0)
	if inteam(id) then
		if JY.Person[id]["武器"] >= 0 then	
			qg = qg - JY.Thing[JY.Person[id]["武器"]]["加轻功"]*10+JY.Thing[JY.Person[id]["武器"]]["加轻功"]*(JY.Thing[JY.Person[id]["武器"]]["装备等级"]-1)*2
		end
		if JY.Person[id]["防具"] >= 0 then
			qg = qg - JY.Thing[JY.Person[id]["防具"]]["加轻功"]*10+JY.Thing[JY.Person[id]["防具"]]["加轻功"]*(JY.Thing[JY.Person[id]["防具"]]["装备等级"]-1)*2
		end
		if JY.Person[id]["坐骑"] >= 0 then
			qg = qg - JY.Thing[JY.Person[id]["坐骑"]]["加轻功"]*10+JY.Thing[JY.Person[id]["坐骑"]]["加轻功"]*(JY.Thing[JY.Person[id]["坐骑"]]["装备等级"]-1)*2
		end		
	else
		if JY.Person[id]["武器"] >= 0 then
			qg = qg - JY.Thing[JY.Person[id]["武器"]]["加轻功"]*10+JY.Thing[JY.Person[id]["武器"]]["加轻功"]*(JY.Thing[JY.Person[id]["武器"]]["装备等级"]-1)*2
		end
		if JY.Person[id]["防具"] >= 0 then
			qg = qg - JY.Thing[JY.Person[id]["防具"]]["加轻功"]*10+JY.Thing[JY.Person[id]["防具"]]["加轻功"]*(JY.Thing[JY.Person[id]["防具"]]["装备等级"]-1)*2
		end
		if JY.Person[id]["坐骑"] >= 0 then
			qg = qg - JY.Thing[JY.Person[id]["坐骑"]]["加轻功"]*10+JY.Thing[JY.Person[id]["坐骑"]]["加轻功"]*(JY.Thing[JY.Person[id]["坐骑"]]["装备等级"]-1)*2
		end		
	end	

	--金雁功
	if Curr_QG(id,223) then
		qg =qg + math.modf(JY.Person[id]["轻功"]*0.2)
	end	
		 
	--逍遥游
	if Curr_QG(id,2) then
	    qg = qg + 20
	end	 
		
	for i =1,JY.Base["武功数量"] do  
		local level = 0            
		if JY.Person[id]["武功" .. i]==108 then
			level = math.modf(JY.Person[id]["武功等级" .. i]/100)+1;
			level = limitX(level/10,0,1)
			qg = qg + math.modf(JY.Person[id]["轻功"]*0.3*level)	
			break
        end
    end
	
    if WAR.PD['西瓜刀·天人'][id] ~= nil then 
        qg = qg*1.5
    end
	return qg
end


function ZDGH(i,id)
     for j = 0, WAR.PersonNum - 1 do
		local zid = WAR.Person[j]["人物编号"]
		if WAR.Person[j]["死亡"] == false and WAR.Person[i]["我方"]  == WAR.Person[j]["我方"] and match_ID(zid, id) then
			return true
		end
	end
    return false
end

Ct['挪移'] = function(i,bs,lx,auto)
	local nx,ny = nil,nil
	local id = WAR.Person[i]['人物编号']
	if lx == nil then 
		lx = 0
	end	
    local at = WAR.CurID
	--auto 自动
	if WAR.Person[i]['我方'] == false or WAR.AutoFight == 1 or auto == '自动' or WAR.ZDDH == 354 then 
		--say('1')
		local menu = {}
		local menu2 = {}
		War_CalMoveStep(i, bs, lx)
		local xi,yi = WAR.Person[i]['坐标X'],WAR.Person[i]['坐标Y']
		--记录所有可以移动的坐标
		for ix = limitX(xi-bs,0,xi),limitX(xi+bs,xi,62) do 
			for iy = limitX(yi-bs,0,yi), limitX(yi+bs,yi,62) do 
				if GetWarMap(ix, iy, 3) ~= 255 and GetWarMap(ix, iy, 2) < 0 and GetWarMap(ix, iy, 4) <= 0 then 
				   menu[#menu+1] = {ix,iy}
				end
			end 
		end
		--随机选择一个可以移动的坐标，记录当前坐标地图层2的数值，设定当前坐标
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
			nx, ny = War_SelectMove() --显示+选择步数
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
	    CurIDTXDH(WAR.CurID, 89,1, "真·葵花挪移")
	    SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, -1)
	    SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, -1)
        SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, -1)
	    WarDrawMap(0)
	    --CurIDTXDH(WAR.CurID, 89,1, "真·葵花挪移")
	    WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"] = nx, ny
	    --WarDrawMap(0)
	    --CurIDTXDH(WAR.CurID, 89,1, "真·葵花挪移")
	    SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 5, WAR.Person[WAR.CurID]["贴图"])
	    SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 2, WAR.CurID)
        SetWarMap(WAR.Person[WAR.CurID]["坐标X"], WAR.Person[WAR.CurID]["坐标Y"], 10, JY.Person[WAR.Person[WAR.CurID]["人物编号"]]['头像代号'])
	    --WarDrawMap(0)
	    CurIDTXDH(WAR.CurID, 89,1, "真·葵花挪移")
    end
    

    WAR.CurID = at

	--return nx,ny
end 

Ct['自动攻击'] = function(kfid)
    local x,y = nil,nil
	local pid = WAR.Person[WAR.CurID]["人物编号"]
	local kungfuid = JY.Person[pid]["武功" .. kfid]
	local kungfulv = JY.Person[pid]["武功等级" .. kfid]
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
	--AI也用新的威力判定
	local kungfuatk = get_skill_power(pid, kungfuid, kungfulv)
	local atkarray = {}
	local num = 0
	CleanWarMap(4, -1)
	local movearray = War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["移动步数"], 0)

	for i = 0, WAR.Person[WAR.CurID]["移动步数"] do
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
			if WAR.Person[WAR.CurID]["我方"] == true then
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
		
		War_CalMoveStep(WAR.CurID, WAR.Person[WAR.CurID]["移动步数"], 0)
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

Ct['随机移动'] = function()
    local id = WAR.Person[WAR.CurID]['人物编号']
	local lx = 0 
	local x0,y0 = WAR.Person[WAR.CurID]['坐标X'],WAR.Person[WAR.CurID]['坐标Y']
	local bs = WAR.Person[WAR.CurID]['移动步数']
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
	    WAR.Person[WAR.CurID]['移动步数'] = 0
	end
end

Ct['破绽'] = function(enemyid)
    local pid = WAR.Person[WAR.CurID]['人物编号']
    local eid = WAR.Person[enemyid]['人物编号']
    --防御无法破绽
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
    
    if match_ID(pid,635) and WAR.Weakspot[eid] ~= nil and WAR.Weakspot[eid] < 6 and (JY.Person[pid]["六如觉醒"] > 0 or isteam(pid) == false) then 
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
    
    if WAR.PD["皆"][pid] == 1 then 
        return true    
    end
    return false
end

--免疫内伤
function myns(i)
	local eid = WAR.Person[i]['人物编号']
	
	if WAR.CQSX == 1 then 
		return true 
	end
	
	if Curr_NG(eid,207) then 
		return true 
	end
    
	--长生诀免疫内伤
    if Curr_NG(eid, 203) then
        return true 
    end	
	
      --天佛降世
	if match_ID(eid,9986) and WAR.FUHUOZT[eid]~=nil  then
		return true 
    end	
		--太玄之轻免疫内伤
	if WAR.TXZQ[eid] ~= nil and WAR.TXZQ[eid] == 1 then
		return true 
	end	
	return false
end

--免疫流血
function mylx(i)
	local eid = WAR.Person[i]['人物编号']
	
	if WAR.CQSX == 1 then 
		return true 
	end
	
	return false
end

--免疫中毒
function myzd(i)
	local eid = WAR.Person[i]['人物编号']
	
	--陆无双免疫中毒
	if match_ID_awakened(eid, 580,1) then
		return true 
	end	
	--太玄之轻免疫中毒
	if WAR.TXZQ[eid] ~= nil and WAR.TXZQ[eid] == 1 then
		return true 
	end
  	--五宝花蜜酒免疫中毒
	if WAR.PD['五宝花蜜酒'][eid] ~= nil  then
		return true 
	end      
	--五毒神功免疫中毒
	if Curr_NG(eid, 220) then
		return true 
	end
        
	return false
end

--免疫封穴
function myfx(i)
	local eid = WAR.Person[i]['人物编号']
	
	if WAR.CQSX == 1 then 
	    return true 
	end
	
	--逍遥御风累积9点，未行动前不会被封穴
	if WAR.XYYF[eid] and WAR.XYYF[eid] == 11 then
	    return true 
	end
	
	--逆运免疫封穴
	if Curr_NG(eid, 104) then
	    return true 
	end
	
	--大周天功回复50时序
	if WAR.ZTHF[eid]~= nil then
		return true 
	end	
	--阿九暴怒免封穴
	if match_ID(eid, 629) and WAR.LQZ[eid] == 100 then
	    return true 
	end	
    --黄赏免疫封穴
	if match_ID(eid,637)  then
	    return true 
	end	 
	
	--主运瞬息千里，暴怒状态不会被封穴
	if Curr_QG(eid,150) and WAR.LQZ[eid]==100 then
		return true 
	end
	return false
end

--免疫冰封
function mybf(i)
	local eid = WAR.Person[i]['人物编号']
	
	if WAR.CQSX == 1 then 
		return true 
	end
	
	--寒冰真气
	if PersonKF(eid,216) then
		return true 
	end
	
	--胡一刀免疫冰封
	if match_ID(eid,633)  then
		return true 
	end	
	
	--徐子陵免疫冰封
	if match_ID(eid,9978)  then
		return true 
	end	
	
	--白秀
	if match_ID(eid,582) then 
		return true 
	end	
	
	return false
end

--免疫灼烧
function myzs(i)
	local eid = WAR.Person[i]['人物编号']
	
	if WAR.CQSX == 1 then 
		return true 
	end
	
	return false
end

--免疫混乱
function myhl(i)

	return false
end

--免疫昏迷
function myhm(i)

	return false
end

Ct['立刻出手'] = function(i)
	local id = WAR.Person[i]['人物编号']
	if WAR.ATK['人物pd'][id] == nil then 
		WAR.ATK['人物table'][#WAR.ATK['人物table']+1] = i
		WAR.ATK['人物pd'][id] = #WAR.ATK['人物table']
	end
end

Ct['人物移动步数'] = function()
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
        local id = WAR.Person[p]['人物编号']
        --左右触发之后，不可移动
        if WAR.ZYHB == 2 then
			WAR.Person[p]["移动步数"] = 0
		--特效：不可移动
        elseif WAR.L_NOT_MOVE[WAR.Person[p]["人物编号"]] ~= nil and WAR.L_NOT_MOVE[WAR.Person[p]["人物编号"]] == 1 then
        	WAR.Person[p]["移动步数"] = 0
        	WAR.L_NOT_MOVE[WAR.Person[p]["人物编号"]] = nil
        else
        	--计算移动步数
			WAR.Person[p]["移动步数"] = math.modf(getnewmove(WAR.Person[p]["轻功"], JY.Person[id]["体力"]) - JY.Person[id]["中毒程度"] / 50 - JY.Person[id]["受伤程度"] / 50)
			
			--毒王中毒移动能力补偿
			if id == 0 and JY.Base["标准"] == 9 then
				WAR.Person[p]["移动步数"] = WAR.Person[p]["移动步数"] + math.modf(JY.Person[id]["中毒程度"] / 50)
			end
			for j = 0, WAR.PersonNum - 1 do
				--小昭，李寻欢敌人移步数少1格
				if match_ID(WAR.Person[j]["人物编号"], 66) and match_ID(WAR.Person[j]["人物编号"], 498) and WAR.Person[j]["死亡"] == false and WAR.Person[j]["我方"] ~= WAR.Person[p]["我方"] then
					WAR.Person[p]["移动步数"] = WAR.Person[p]["移动步数"] - 1
				end
			end

				
			--天罗地网，柔网势，敌人移动减一格
			if WAR.TLDW[WAR.Person[p]["人物编号"]] ~= nil and WAR.TLDW[WAR.Person[p]["人物编号"]] == 1 then
				WAR.Person[p]["移动步数"] = WAR.Person[p]["移动步数"] - 1
				WAR.TLDW[WAR.Person[p]["人物编号"]] = nil
			end
			--张家辉的麻痹戒指，减少敌人移动
			if WAR.MBJZ[WAR.Person[p]["人物编号"]] ~= nil then
				WAR.Person[p]["移动步数"] = WAR.Person[p]["移动步数"] - WAR.MBJZ[WAR.Person[p]["人物编号"]]
				WAR.MBJZ[WAR.Person[p]["人物编号"]] = nil
			end
	
			--锁足，敌人不可移动
			if WAR.SZZT[id] ~= nil then
				WAR.Person[p]["移动步数"] = WAR.Person[p]["移动步数"] - 15
				WAR.TLDW[WAR.Person[p]["人物编号"]] = nil
				end
				if WAR.Person[p]["移动步数"]<0 then
				WAR.Person[p]["移动步数"] = 0
			
			end			
			--令狐冲，灭绝，血刀老祖，阿凡提，神雕移动+3格
			if match_ID(id, 35) or match_ID(id, 6) or match_ID(id, 97) or match_ID(id, 606) or match_ID(id, 628) then
				WAR.Person[p]["移动步数"] = WAR.Person[p]["移动步数"] + 3
			end
			--张三丰，移动至少8格
			if match_ID(id, 5) and WAR.Person[p]["移动步数"] < 8 then
				WAR.Person[p]["移动步数"] = 8
			end	
			--主运飞天，凌波，天罗，移动+1 胡一刀 逍遥游
			if Curr_QG(id,145) or Curr_QG(id,147) or Curr_QG(id,148)   or match_ID(id,633)  or Curr_QG(id,2) then
				WAR.Person[p]["移动步数"] = WAR.Person[p]["移动步数"] + 1
			end
			--主运神行，瞬息，一苇渡江移动+2
			if Curr_QG(id,146) or Curr_QG(id,150) or Curr_QG(id,186) then
				WAR.Person[p]["移动步数"] = WAR.Person[p]["移动步数"] + 2
			end
			--踏雪无痕，移动锁定10格
			if match_ID(id, 511) then
				WAR.Person[p]["移动步数"] = WAR.Person[p]["移动步数"] + 2
			end
			--金雁功，蛇行狸翻 移动+2
			if Curr_QG(id,223) or Curr_QG(id,224) then
				WAR.Person[p]["移动步数"] = WAR.Person[p]["移动步数"] + 2
			end			
			--主角学会迷踪步后，移动+1
			if id == 0 and JY.Person[615]["论剑奖励"] == 1 then
				WAR.Person[p]["移动步数"] = WAR.Person[p]["移动步数"] + 1
			end
			--李寻欢学会蜻蜓三大抄水后，移动+2
			if match_ID(id, 498) and WAR.Person[p]["移动步数"] < 8 then
				WAR.Person[p]["移动步数"] = 8
			end	
			--孤独求败，移动锁定10格
			if match_ID(id, 592) then
				WAR.Person[p]["移动步数"] = 10
			end
        end

        --最大移动步数10
        if WAR.Person[p]["移动步数"] > 10 then
			WAR.Person[p]["移动步数"] = 10
        end
		--锁足，敌人不可移动
		if WAR.SZZT[id] ~= nil then
		WAR.Person[p]["移动步数"] = WAR.Person[p]["移动步数"] - 10
		WAR.TLDW[WAR.Person[p]["人物编号"]] = nil
		end
		if WAR.PD["洞火"][id] ~= nil then
		   WAR.Person[p]["移动步数"] = WAR.Person[p]["移动步数"] - 2
		  WAR.TLDW[WAR.Person[p]["人物编号"]] = nil	
		end		
		if WAR.Person[p]["移动步数"]<0 then
            WAR.Person[p]["移动步数"] = 0
			
		end	
end

Ct['天关阵'] = function()
	if WAR.ZDDH == 356 then
		if WAR.CD == 0 then 
			WAR.PD['天关阵4'] = {}
			local menu = {}
			local str = {[5] = '林',[27] = '风',[50] = '火',[114] = '山'}
			for i = 0,WAR.PersonNum-1 do 
				local id = WAR.Person[i]['人物编号']
				if WAR.Person[i]['死亡'] == false and WAR.Person[i]['我方'] == false then 
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
						WAR.PD['天关阵4'][menu[i][1]] = id
					end
				end
				WAR.CurID = menu[m][2]
				CurIDTXDH(WAR.CurID, 19,1,'风林火山·'..str[id],LimeGreen);
			end
			WAR.CD = WAR.TGCD[WAR.ZDDH]
		end
	end
end

Ct['清除所有异常'] = function(i)
	local pid = WAR.Person[i]['人物编号']
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
			{"洞火"},
			{"放下屠刀"},
            }
            for j = 1,#YC do
                local yc = YC[j][1]
                yc[pid] = nil
            end
            for j = 1,#YC2 do
                local yc = YC2[j][1]
                WAR.PD[yc][pid] = nil
            end
            JY.Person[pid]['受伤程度'] = 0
            JY.Person[pid]['中毒程度'] = 0
            JY.Person[pid]['冰封程度'] = 0
            JY.Person[pid]['灼烧程度'] = 0
            
end