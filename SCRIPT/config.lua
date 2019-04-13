
-- �����ļ�
--Ϊ�˼򻯴����������ļ�Ҳ��lua��д
--����C�����ȡ�Ĳ�����lua��������Ҫ���������Ĳ�����lua������������Ȼ����jyconst.lua��

CONFIG={};

CONFIG.Debug = 1;         --������Ժʹ�����Ϣ��=0����� =1 �����Ϣ��debug.txt��error.txt����ǰĿ¼

--�����������С��640*480(��СΪ320*240) ��Ϊ0�����ڵ���640*480 ��Ϊ1
--Ŀǰֻ������������������ֱ�����Ȼ���ã���Ϣ���ܹ���ʾ��������ʾЧ����һ���ÿ���
--������������ֱ�����������ʾЧ��������������jyconst.lua���޸���Ӧ������
CONFIG.Type = 1;

CONFIG.Width  = 936;       -- ��Ϸͼ�δ��ڿ�, ����Ϊ0����ϵͳ�Զ���Ӧ
CONFIG.Height = 701;      -- ��Ϸͼ�δ��ڸ�

CONFIG.bpp = 32;        -- ȫ��ʱ����ɫ�һ��Ϊ16����32���ڴ���ģʽʱֱ�Ӳ��õ�ǰ��Ļɫ���������Ч
                         -- ��֧��8λɫ�Ϊ����ٶȣ�����ʹ��16λɫ�
						 -- 24λδ�������ԣ�����֤��ȷ��ʾ

CONFIG.XScale = 18;    	-- ��ͼ���ȵ�һ��
CONFIG.YScale = 9 ;    	-- ��ͼ�߶ȵ�һ��

CONFIG.LargeMemory = 0;             --�����ڴ�ʹ�÷�ʽ 1 ��ʹ���ڴ棬0 ��ʹ���ڴ�

CONFIG.CoupleDisplay = 1;			--ս����ʼǰ�Ƿ���ʾ��϶��� 1 �� 0 �ر�

--��ͼ��С����

if CONFIG.Zoom > 100 then
	CONFIG.XScale = math.modf(CONFIG.XScale*CONFIG.Zoom/100)    -- ��ͼ���ȵ�һ��
	CONFIG.YScale = math.modf(CONFIG.YScale*CONFIG.Zoom/100)     -- ��ͼ�߶ȵ�һ��
end


--���ø��������ļ���·�������������Ŀ¼��־��windows��ͬ��OS, ��linux�����Ϊ���ʵ�·��
CONFIG.Operation = 0;		--0:Windows	 1:android
if CONFIG.Operation == 1 then
	CONFIG.CurrentPath = "/sdcard/JYLDCR/";
	CONFIG.MP3 = 0;		--�Ƿ��MP3
else
	CONFIG.CurrentPath = "./";
	CONFIG.LargeMemory = 1;
	CONFIG.MP3 = 1;		--�Ƿ��MP3
end



CONFIG.DataPath=CONFIG.CurrentPath.."data/";
CONFIG.PicturePath=CONFIG.CurrentPath.."pic/";
CONFIG.SoundPath=CONFIG.CurrentPath.."sound/";
CONFIG.ScriptPath=CONFIG.CurrentPath.."script/";
CONFIG.CEventPath = CONFIG.ScriptPath .. "CEvent/";
CONFIG.WuGongPath = CONFIG.ScriptPath .. "WuGong/";
CONFIG.HelpPath = CONFIG.ScriptPath .. "Help/";

CONFIG.ScriptLuaPath = string.format("?.lua;%sscript/?.lua;%sscript/?.lua", CONFIG.CurrentPath, CONFIG.CurrentPath);

--CONFIG.ScriptLuaPath="?.lua;/sdcard/JYLDCR/script/?.lua;/sdcard/JYLDCR/script/?.lua";        --��lua����д��·��

CONFIG.JYMain_Lua=CONFIG.ScriptPath .. "jymain.lua";   --lua��������

CONFIG.FontName=CONFIG.CurrentPath..string.format("font/%s.ttf",CONFIG.ZT); --����


--ʹ��FMOD����MIDI����Ҫgm.dls�ļ�
if CONFIG.MP3 == 0 then
	CONFIG.MidSF2 = CONFIG.SoundPath.."mid.sf2";
else
	CONFIG.MidSF2 = "";
end


--��ʾ����ͼx��y�������ӵ���ͼ�����Ա�֤������ͼ��ȫ����ʾ
CONFIG.MMapAddX=2;
CONFIG.MMapAddY=2;
CONFIG.SMapAddX=2;
CONFIG.SMapAddY=16;
CONFIG.WMapAddX=2;
CONFIG.WMapAddY=16;



if CONFIG.LargeMemory==1 then
     --��ͼ����������һ��500-1000�������debug.txt�о�������"pic cache is full"�������ʵ�����
    CONFIG.MAXCacheNum=1200;
	CONFIG.CleanMemory=0;         --�����л�ʱ�Ƿ�����lua�ڴ档0 ������ 1 ����
	CONFIG.LoadFullS=1;           --1 ����S*�ļ������ڴ� 0 ֻ���뵱ǰ����������S*��4M�࣬�������Խ���ܶ��ڴ�
else
    CONFIG.MAXCacheNum=500;
	CONFIG.CleanMemory=1;
	CONFIG.LoadFullS=0;
end

--������λ�ã�-1ΪĬ��λ��
CONFIG.D1X = -1;
CONFIG.D1Y = -1;
CONFIG.D2X = -1;
CONFIG.D2Y = -1;
CONFIG.D3X = -1;
CONFIG.D3Y = -1;
CONFIG.D4X = -1;
CONFIG.D4Y = -1;
CONFIG.C1X = -1;
CONFIG.C1Y = -1;
CONFIG.C2X = -1;
CONFIG.C2Y = -1;
CONFIG.AX = -1;
CONFIG.AY = -1;
CONFIG.BX = -1;
CONFIG.BY = -1;
