
function  hi()
    CC={};
    --定义记录文件R×结构。  lua不支持结构，无法直接从二进制文件中读取，因此需要这些定义，用table中不同的名字来仿真结构。
    CC.TeamNum=15;          --队伍人数
    CC.MyThingNum=400      --主角物品数量

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


    JY={};
    JY.Base={};          --基本数据
    --读取R*.grp文件

end





ItemInfo={}
--newkdef[0小还丹]=function()
ItemInfo[0]={
    "Ｌ物品说明：可恢复少量生命",
    "Ｎ",
    "Ｄ使用效果：+150生命",
    -- by 飘夜
}

--newkdef[1天香续命膏]=function()
ItemInfo[01]={
    "Ｌ物品说明：可恢复较多生命",
    "Ｎ",
    "Ｄ使用效果：+300生命",
    -- by 飘夜
}