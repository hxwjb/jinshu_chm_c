
// ��ȡidx/grp����ͼ�ļ���
// Ϊ����ٶȣ����û��淽ʽ��ȡ����idx/grp�����ڴ棬Ȼ�������ɸ��������
// �������ʵ�pic���ڻ��������

#include <stdlib.h>
#include "piccache.h"
#include "jymain.h"
#include "sdlfun.h"
#include <string>
#include <string.h>

PicFileCache pic_file[PIC_FILE_NUM];
//std::forward_list<CacheNode*> pic_cache;     //pic_cache����
Uint32 m_color32[256];               // 256��ɫ��
//int CacheFailNum = 0;

void CacheNode::toTexture()
{
    if (s)
    {
        if (t == NULL)
        {
            t = SDL_CreateTextureFromSurface(g_Renderer, s);
            tt[0] = t;
            SDL_FreeSurface(s);
            s = NULL;
        }
    }
}

// ��ʼ��Cache���ݡ���Ϸ��ʼʱ����
int Init_Cache()
{
    int i;
    for (i = 0; i < PIC_FILE_NUM; i++)
    {
        pic_file[i].num = 0;
        pic_file[i].idx = NULL;
        pic_file[i].grp = NULL;
        pic_file[i].fp = NULL;
        //pic_file[i].pcache = NULL;
    }
    return 0;
}

// ��ʼ����ͼcache��Ϣ
// PalletteFilename Ϊ256��ɫ���ļ�����һ�ε���ʱ����
//                  Ϊ���ַ������ʾ���������ͼcache��Ϣ��������ͼ/����/ս���л�ʱ����

int JY_PicInit(char* PalletteFilename)
{
    struct list_head* pos, *p;
    int i;

    LoadPalette(PalletteFilename);   //�����ɫ��

    //���������Ϊ�գ�ɾ��ȫ������
    //for (auto& c : pic_cache)
    //{
    //    delete c;
    //}
    //pic_cache.clear();

    for (i = 0; i < PIC_FILE_NUM; i++)
    {
        pic_file[i].num = 0;
        SafeFree(pic_file[i].idx);
        SafeFree(pic_file[i].grp);

        for (auto& p : pic_file[i].pcache)
        {
            delete p;
        }
        pic_file[i].pcache.clear();
        //SafeFree(pic_file[i].pcache);
        if (pic_file[i].fp)
        {
            fclose(pic_file[i].fp);
            pic_file[i].fp = NULL;
        }
    }
    //CacheFailNum = 0;
	JY_PicLoadFile("./data/wmap.idx", "./data/wmap.grp", 0, NULL, NULL);	//--��Ч��ͼ
	JY_LoadPNGPath("./data/head", 1, 2000, g_ScreenW / 936 * 100, "png");
	JY_PicLoadFile("./data/thing.idx", "./data/thing.grp", 2, NULL, NULL);
	JY_PicLoadFile("./data/Eft.idx", "./data/Eft.grp", 3, NULL, NULL);	//--��Ч��ͼ
	JY_LoadPNGPath("./data/body", 90, 2000, g_ScreenW / 936 * 100, "png");
	JY_LoadPNGPath("./data/xt", 91,2000, g_ScreenW / 936 * 100, "png");
	JY_PicLoadFile("./data/bj.idx", "./data/bj.grp", 92, NULL, NULL);
	JY_LoadPNGPath("./data/mmap", 93, -1, 100, "png");
	JY_LoadPNGPath("./data/smap", 94, -1, 100, "png");
	JY_LoadPNGPath("./data/portrait", 95, 2000, g_ScreenW / 936 * 100, "png");
	JY_LoadPNGPath("./data/ui", 96, 2000, g_ScreenW / 936 * 100, "png");
    JY_LoadPNGPath("./data/cloud", 97, -1, 100, "png");
	JY_LoadPNGPath("./data/icons", 98, 2000, g_ScreenW / 936 * 100, "png");
	JY_LoadPNGPath("./data/head", 99, 2000, 26.923076923, "png");
	for (i = 101; i < 1000; i++)
	{
		char figidx[512];
		char figgrp[512];
		sprintf(figidx, "./data/fight/fight%03d.idx", i - 101);
		sprintf(figgrp, "./data/fight/fight%03d.grp", i - 101);
		JY_PicLoadFile(figidx, figgrp, i, NULL, NULL);
	}
    return 0;
}

// �����ļ���Ϣ
// filename �ļ���
// id  0 - PIC_FILE_NUM-1
int JY_PicLoadFile(const char* idxfilename, const char* grpfilename, int id, int width, int height)
{
    int i;
    struct CacheNode* tmpcache;
    FILE* fp;

    if (id < 0 || id >= PIC_FILE_NUM)    // id������Χ
    {
        return 1;
    }

    if (pic_file[id].pcache.size())          //�ͷŵ�ǰ�ļ�ռ�õĿռ䣬������cache
    {
        int i;
        for (i = 0; i < pic_file[id].num; i++)     //ѭ��ȫ����ͼ��
        {
            tmpcache = pic_file[id].pcache[i];
            if (tmpcache)         // ����ͼ�л�����ɾ��
            {
                delete tmpcache;
            }
        }
        //SafeFree(pic_file[id].pcache);
    }
    SafeFree(pic_file[id].idx);
    SafeFree(pic_file[id].grp);
    if (pic_file[id].fp)
    {
        fclose(pic_file[id].fp);
        pic_file[id].fp = NULL;
    }

    // ��ȡidx�ļ�

    pic_file[id].num = FileLength(idxfilename) / 4;    //idx ��ͼ����
    pic_file[id].idx = (int*)malloc((pic_file[id].num + 1) * 4);
    if (pic_file[id].idx == NULL)
    {
        JY_Error("JY_PicLoadFile: cannot malloc idx memory!\n");
        return 1;
    }
    //��ȡ��ͼidx�ļ�
    if ((fp = fopen(idxfilename, "rb")) == NULL)
    {
        JY_Error("JY_PicLoadFile: idx file not open ---%s", idxfilename);
        return 1;
    }

    fread(&pic_file[id].idx[1], 4, pic_file[id].num, fp);
    fclose(fp);

    pic_file[id].idx[0] = 0;

    //��ȡgrp�ļ�
    pic_file[id].filelength = FileLength(grpfilename);

    //��ȡ��ͼgrp�ļ�
    if ((fp = fopen(grpfilename, "rb")) == NULL)
    {
        JY_Error("JY_PicLoadFile: grp file not open ---%s", grpfilename);
        return 1;
    }
    if (g_PreLoadPicGrp == 1)     //grp�ļ������ڴ�
    {
        pic_file[id].grp = (unsigned char*)malloc(pic_file[id].filelength);
        if (pic_file[id].grp == NULL)
        {
            JY_Error("JY_PicLoadFile: cannot malloc grp memory!\n");
            return 1;
        }
        fread(pic_file[id].grp, 1, pic_file[id].filelength, fp);
        fclose(fp);
    }
    else
    {
        pic_file[id].fp = fp;
    }

    pic_file[id].pcache.resize(pic_file[id].num);
    if (pic_file[id].pcache.size() == 0)
    {
        JY_Error("JY_PicLoadFile: cannot malloc pcache memory!\n");
        return 1;
    }

    for (i = 0; i < pic_file[id].num; i++)
    {
        pic_file[id].pcache[i] = NULL;
    }

    if (height == 0)
    {
        height = width;
    }

    if (width > 0)
    {
        pic_file[id].width = width;
        pic_file[id].height = height;
    }
    pic_file[id].type = 0;
    return 0;
}

// ���ز���ʾ��ͼ
// fileid        ��ͼ�ļ�id
// picid     ��ͼ���
// x,y       ��ʾλ��
//  flag ��ͬbit������ͬ���壬ȱʡ��Ϊ0
//  B0    0 ����ƫ��xoff��yoff��=1 ������ƫ����
//  B1    0     , 1 �뱳��alpla �����ʾ, value Ϊalphaֵ(0-256), 0��ʾ͸��
//  B2            1 ȫ��
//  B3            1 ȫ��
//  value ����flag���壬Ϊalphaֵ��

int JY_LoadPic(int fileid, int picid, int x, int y, int flag, int value, int color, int width, int height, double rotate, SDL_RendererFlip reversal)
{
    struct CacheNode* newcache, *tmpcache;
    int xnew, ynew;
    SDL_Surface* tmpsur;

    if (pic_file[fileid].type == 1)
    {
        JY_LoadPNG(fileid, picid, x, y, flag, value);
        return 0;
    }

    picid = picid / 2;

    if (fileid < 0 || fileid >= PIC_FILE_NUM || picid < 0 || picid >= pic_file[fileid].num)    // ��������
    {
        return 1;
    }

    if (pic_file[fileid].pcache[picid] == NULL)     //��ǰ��ͼû�м���
    {
        //����cache����
        newcache = new CacheNode();
        if (newcache == NULL)
        {
            JY_Error("JY_LoadPic: cannot malloc newcache memory!\n");
            return 1;
        }

        newcache->id = picid;
        newcache->fileid = fileid;
        LoadPic(fileid, picid, newcache);
        ////ָ�����Ⱥ͸߶�
        //if (newcache->s != NULL && pic_file[fileid].width > 0 && pic_file[fileid].height > 0
        //    && pic_file[fileid].width != newcache->s->w && pic_file[fileid].height != newcache->s->h)
        //{
        //    double zoomx = (double)pic_file[fileid].width / newcache->s->w;
        //    double zoomy = (double)pic_file[fileid].height / newcache->s->h;

        //    if (zoomx < zoomy)
        //    {
        //        zoomy = zoomx;
        //    }
        //    else
        //    {
        //        zoomx = zoomy;
        //    }

        //    tmpsur = newcache->s;

        //    newcache->s = zoomSurface(tmpsur, zoomx, zoomy, SMOOTHING_OFF);

        //    newcache->xoff = (int)(zoomx * newcache->xoff);
        //    newcache->yoff = (int)(zoomy * newcache->yoff);
        //    //SDL_SetColorKey(newcache->s, SDL_TRUE, ConvertColor(g_MaskColor32));  //͸��ɫ
        //    SDL_FreeSurface(tmpsur);
        //}
        pic_file[fileid].pcache[picid] = newcache;
    }
    else
    {
        newcache = pic_file[fileid].pcache[picid];
    }

    if (newcache->t == NULL)     //��ͼΪ�գ�ֱ���˳�
    {
        return 1;
    }

    if (flag & 0x00000001)
    {
        xnew = x;
        ynew = y;
    }
    else
    {
		if (width > 0 && height >0)  //̫��è�����������Զ��壬��ͼ��λ�õ���
		{
			xnew = x - newcache->xoff*width / newcache->w;
			ynew = y - newcache->yoff*height /newcache->h;
		}
		else if (width > 0 && height <= 0)  //̫��è���������Զ��壬��ͼ��λ�õ���
		{
			xnew = x - newcache->xoff*width / newcache->w;
			ynew = y - newcache->yoff*width / newcache->w;
		}
		else if (width <= 0 && height > 0)  //̫��è�����������Զ��壬��ͼ��λ�õ���
		{
			float bl = height/ 100.0;
			width = newcache->w*bl;
			height = newcache->h*bl;
			xnew = x - newcache->xoff*bl;
			ynew = y - newcache->yoff*bl;
		}
		else if (width == 0 && height == 0)    //̫��è���������߶�Ϊ0�����zoomֵ�ı���ͼ��С
		{
			width = newcache->w*g_Zoom;
			height = newcache->h*g_Zoom;
			xnew = x - newcache->xoff*g_Zoom;
			ynew = y - newcache->yoff*g_Zoom;
		}
		else
		{
			xnew = x - newcache->xoff;
			ynew = y - newcache->yoff;
		}
    }
    RenderTexture(newcache->t, xnew, ynew, flag, value, color, width, height, rotate,reversal);
    return 0;
}

// ������ͼ������
int LoadPic(int fileid, int picid, struct CacheNode* cache)
{

    SDL_RWops* fp_SDL;
    int id1, id2;
    int datalong;
    unsigned char* p, *data;

    SDL_Surface* tmpsurf = NULL, *tmpsur;

    if (pic_file[fileid].idx == NULL)
    {
        JY_Error("LoadPic: fileid %d can not load?\n", fileid);
        return 1;
    }
    id1 = pic_file[fileid].idx[picid];
    id2 = pic_file[fileid].idx[picid + 1];

    // ����һЩ��������������޸����еĴ���
    if (id1 < 0)
    {
        datalong = 0;
    }

    if (id2 > pic_file[fileid].filelength)
    {
        id2 = pic_file[fileid].filelength;
    }

    datalong = id2 - id1;

    if (datalong > 0)
    {
        //��ȡ��ͼgrp�ļ����õ�ԭʼ����
        if (g_PreLoadPicGrp == 1)           //��Ԥ�������ڴ��ж�����
        {
            data = pic_file[fileid].grp + id1;
            p = NULL;
        }
        else         //û��Ԥ�������ļ��ж�ȡ
        {
            fseek(pic_file[fileid].fp, id1, SEEK_SET);
            data = (unsigned char*)malloc(datalong);
            p = data;
            fread(data, 1, datalong, pic_file[fileid].fp);
        }

        fp_SDL = SDL_RWFromMem(data, datalong);
        if (IMG_isPNG(fp_SDL) == 0)
        {
            int w, h;
            w = *(short*)data;
            h = *(short*)(data + 2);
            cache->xoff = *(short*)(data + 4);
            cache->yoff = *(short*)(data + 6);
            cache->w = w;
            cache->h = h;
            cache->t = CreateTextureFromRLE(data + 8, w, h, datalong - 8);
			cache->tt[0] = cache->t;
            //cache->t = SDL_CreateTextureFromSurface(g_Renderer, cache->s);
            //SDL_FreeSurface(cache->s);
            cache->s = NULL;
        }
        else        //��ȡpng��ʽ
        {
            tmpsurf = IMG_LoadPNG_RW(fp_SDL);
            if (tmpsurf == NULL)
            {
                JY_Error("LoadPic: cannot create SDL_Surface tmpsurf!\n");
            }
            cache->xoff = tmpsurf->w / 2;
            cache->yoff = tmpsurf->h / 2;
            cache->w = tmpsurf->w;
            cache->h = tmpsurf->h;
            cache->s = tmpsurf;
            cache->toTexture();
            //cache->t = SDL_CreateTextureFromSurface(g_Renderer, cache->s);
            //SDL_FreeSurface(cache->s);
            //cache->s = NULL;
        }
        SDL_FreeRW(fp_SDL);
        SafeFree(p);
    }
    else
    {
        cache->s = NULL;
        cache->t = NULL;
        cache->xoff = 0;
        cache->yoff = 0;
    }

    return 0;
}


//�õ���ͼ��С
int JY_GetPicXY(int fileid, int picid, int* w, int* h, int* xoff, int* yoff)
{
    struct CacheNode* newcache;
    int r = JY_LoadPic(fileid, picid, g_ScreenW + 1, g_ScreenH + 1, 1, 0);   //������ͼ����������λ��

    *w = 0;
    *h = 0;
    *xoff = 0;
    *yoff = 0;

    if (r != 0)
    {
        return 1;
    }

    newcache = pic_file[fileid].pcache[picid / 2];

    if (newcache->t)        // ���У���ֱ����ʾ
    {
        *w = newcache->w;
        *h = newcache->h;
        *xoff = newcache->xoff;
        *yoff = newcache->yoff;
    }

    return 0;
}

//����ԭ����Ϸ��RLE��ʽ��������
SDL_Texture* CreateTextureFromRLE(unsigned char* data, int w, int h, int datalong)
{
    int p = 0;
    int i, j;
    int yoffset;
    int row;
    int start;
    int x;
    int solidnum;
    SDL_Surface* ps1, *ps2;
    Uint32* data32 = NULL;

    data32 = (Uint32*)malloc(w * h * 4);
    if (data32 == NULL)
    {
        JY_Error("CreatePicSurface32: cannot malloc data32 memory!\n");
        return NULL;
    }

    for (i = 0; i < w * h; i++)
    {
        data32[i] = 0;
    }

    for (i = 0; i < h; i++)
    {
        yoffset = i * w;
        row = data[p];            // i�����ݸ���
        start = p;
        p++;
        if (row > 0)
        {
            x = 0;                // i��Ŀǰ��
            for (;;)
            {
                x = x + data[p];    // i�пհ׵����������͸����
                if (x >= w)        // i�п��ȵ�ͷ������
                {
                    break;
                }

                p++;
                solidnum = data[p];  // ��͸�������
                p++;
                for (j = 0; j < solidnum; j++)
                {
                    if (g_Rotate == 0)
                    {
                        data32[yoffset + x] = m_color32[data[p]] | AMASK;
                    }
                    else
                    {
                        data32[h - i - 1 + x * h] = m_color32[data[p]] | AMASK;
                    }
                    p++;
                    x++;
                }
                if (x >= w)
                {
                    break;
                }     // i�п��ȵ�ͷ������
                if (p - start >= row)
                {
                    break;
                }    // i��û�����ݣ�����
            }
            if (p + 1 >= datalong)
            {
                break;
            }
        }
    }
    ps1 = SDL_CreateRGBSurfaceFrom(data32, w, h, 32, w * 4, RMASK, GMASK, BMASK, AMASK);  //����32λ����
    if (ps1 == NULL)
    {
        JY_Error("CreatePicSurface32: cannot create SDL_Surface ps1!\n");
    }
    ps2 = SDL_ConvertSurfaceFormat(ps1, g_Surface->format->format, 0);
    if (ps2 == NULL)
    {
        JY_Error("CreatePicSurface32: cannot create SDL_Surface ps2!\n");
    }
    auto tex = SDL_CreateTextureFromSurface(g_Renderer, ps2);
    SDL_FreeSurface(ps1);
    SDL_FreeSurface(ps2);
    SafeFree(data32);
    return tex;
}

// ��ȡ��ɫ��
// �ļ���Ϊ����ֱ�ӷ���
int LoadPalette(char* filename)
{
    FILE* fp;
    char color[3];
    int i;
    if (strlen(filename) == 0)
    {
        return 1;
    }
    if ((fp = fopen(filename, "rb")) == NULL)
    {
        JY_Error("palette File not open ---%s", filename);
        return 1;
    }
    for (i = 0; i < 256; i++)
    {
        fread(color, 1, 3, fp);
        m_color32[i] = color[0] * 4 * 65536l + color[1] * 4 * 256 + color[2] * 4 + 0x000000;

    }
    fclose(fp);

    return 0;
}


int JY_LoadPNGPath(const char* path, int fileid, int num, int percent, const char* suffix)
{
    int i;
    struct CacheNode* tmpcache;
    if (fileid < 0 || fileid >= PIC_FILE_NUM)    // id������Χ
    {
        return 1;
    }

    if (pic_file[fileid].pcache.size())          //�ͷŵ�ǰ�ļ�ռ�õĿռ䣬������cache
    {
        int i;
        for (i = 0; i < pic_file[fileid].num; i++)     //ѭ��ȫ����ͼ��
        {
            tmpcache = pic_file[fileid].pcache[i];
            if (tmpcache)         // ����ͼ�л�����ɾ��
            {
                delete tmpcache;
            }
        }
        //SafeFree(pic_file[fileid].pcache);
    }

    //sb500����
    pic_file[fileid].type = 1;
    int ll = 0;
    char zip_name[1024];
    sprintf(zip_name, "%s.zip", path);
    pic_file[fileid].zip_file.openFile(zip_name);

    char index_name[1024];
    std::vector<short> offset;

    if (pic_file[fileid].zip_file.opened())
    {
        std::string content = pic_file[fileid].zip_file.readEntryName("index.ka");
        ll = content.size();
        offset.resize(ll / 2);
        memcpy(offset.data(), content.data(), offset.size() * 2);
    }
    else
    {
        sprintf(index_name, "%s/index.ka", path);
        if (FILE* f = fopen(index_name, "rb"))
        {
            JY_Debug("JY_LoadPNGPath: found index file!\n");
            fseek(f, 0, SEEK_END);
            ll = ftell(f);
            fseek(f, 0, 0);
            offset.resize(ll / 2);
            fread(offset.data(), 2, ll / 2, f);
            fclose(f);
        }
    }

    if (num < 0)
    {
        num = ll / 4;    //ͼƬ����
    }

    //sb500�޸�
    if (num > 0)
    {
        pic_file[fileid].num = num;
        sprintf(pic_file[fileid].path, "%s", path);

        pic_file[fileid].pcache.resize(pic_file[fileid].num);
        if (pic_file[fileid].pcache.size() == 0)
        {
            JY_Error("JY_LoadPNGPath: cannot malloc pcache memory!\n");
            return 1;
        }
        for (i = 0; i < pic_file[fileid].num; i++)
        {
            pic_file[fileid].pcache[i] = NULL;
        }
    }

    if (ll == 0)
    {
        //û��index�ļ�
        pic_file[fileid].offset.resize(pic_file[fileid].num * 2);
        for (i = 0; i < pic_file[fileid].num; i++)
        {
            //û�ҵ�index�ļ�������Ϊһ�������ܵ�����
            pic_file[fileid].offset[i * 2] = 9999;
            pic_file[fileid].offset[i * 2 + 1] = 9999;
        }
    }
    else
    {
        //��index�ļ������ȡ���Ĳ��ְ���index����ƫ��
        pic_file[fileid].offset = offset;
        pic_file[fileid].offset.resize(pic_file[fileid].num * 2);
        for (i = ll / 4; i < pic_file[fileid].num; i++)
        {
            pic_file[fileid].offset[i * 2] = 9999;
            pic_file[fileid].offset[i * 2 + 1] = 9999;
        }
    }

    pic_file[fileid].percent = percent;
    sprintf(pic_file[fileid].suffix, "%s", suffix);

    return 0;
}

int JY_LoadPNG(int fileid, int picid, int x, int y, int flag, int value)
{
    struct CacheNode* newcache, *tmpcache;
    SDL_Surface* tmpsur;
    SDL_Rect r;

    picid = picid / 2;

    if (fileid < 0 || fileid >= PIC_FILE_NUM || picid < 0 || picid >= pic_file[fileid].num)    // ��������
    {
        return 1;
    }
    if (pic_file[fileid].pcache[picid] == NULL)     //��ǰ��ͼû�м���
    {
        char str[512];
        SDL_RWops* fp_SDL;
        double zoom = (double)pic_file[fileid].percent / 100.0;
        std::string content;
        //����cache����
        newcache = new CacheNode();
        if (newcache == NULL)
        {
            JY_Error("JY_LoadPNG: cannot malloc newcache memory!\n");
            return 1;
        }

        newcache->id = picid;
        newcache->fileid = fileid;
        newcache->t_count = 1;

        if (pic_file[fileid].zip_file.opened())
        {
            sprintf(str, "%d.png", picid);
            content = pic_file[fileid].zip_file.readEntryName(str);
            fp_SDL = SDL_RWFromMem((void*)content.data(), content.size());
            if (fp_SDL == NULL)
            {
                sprintf(str, "%d_0.png", picid);
                content = pic_file[fileid].zip_file.readEntryName(str);
                fp_SDL = SDL_RWFromMem((void*)content.data(), content.size());
                for (int i = 1; i < TEXTURE_NUM; i++)
                {
                    sprintf(str, "%d_%d.png", picid, i);
                    std::string content1 = pic_file[fileid].zip_file.readEntryName(str);
                    SDL_RWops* fp_SDL1 = SDL_RWFromMem((void*)content1.data(), content1.size());
                    if (IMG_isPNG(fp_SDL1))
                    {
                        tmpsur = IMG_LoadPNG_RW(fp_SDL1);
                        newcache->tt[i] = SDL_CreateTextureFromSurface(g_Renderer, tmpsur);
                        newcache->t_count = i + 1;
                        SDL_FreeSurface(tmpsur);
                    }
                    SDL_FreeRW(fp_SDL1);
                }
            }
        }
        else
        {
            sprintf(str, "%s/%d.png", pic_file[fileid].path, picid);
            fp_SDL = SDL_RWFromFile(str, "rb");
            if (fp_SDL == NULL)
            {
                sprintf(str, "%s/%d_0.png", pic_file[fileid].path, picid);
                fp_SDL = SDL_RWFromFile(str, "rb");
                for (int i = 1; i < TEXTURE_NUM; i++)
                {
                    sprintf(str, "%s/%d_%d.png", pic_file[fileid].path, picid, i);
                    /*newcache->tt[i] = IMG_LoadTexture(g_Renderer, str);
                    if (newcache->tt[i]) { newcache->t_count = i; }*/
                    SDL_RWops* fp_SDL1 = SDL_RWFromFile(str, "rb");
                    if (IMG_isPNG(fp_SDL1))
                    {
                        tmpsur = IMG_LoadPNG_RW(fp_SDL1);
                        newcache->tt[i] = SDL_CreateTextureFromSurface(g_Renderer, tmpsur);
                        newcache->t_count = i + 1;
                        SDL_FreeSurface(tmpsur);
                    }
                    SDL_FreeRW(fp_SDL1);
                }
            }
        }
        if (IMG_isPNG(fp_SDL))
        {
            tmpsur = IMG_LoadPNG_RW(fp_SDL);
            if (tmpsur == NULL)
            {
                JY_Error("JY_LoadPNG: cannot create SDL_Surface tmpsurf!\n");
                return 1;
            }

            //sb500
            newcache->xoff = pic_file[fileid].offset[picid * 2];
            newcache->yoff = pic_file[fileid].offset[picid * 2 + 1];

            if (newcache->xoff == 9999)
            {
                newcache->xoff = tmpsur->w / 2;
            }
            if (newcache->yoff == 9999)
            {
                newcache->yoff = tmpsur->h / 2;
            }

            newcache->w = tmpsur->w;
            newcache->h = tmpsur->h;
            newcache->s = tmpsur;
            newcache->toTexture();
            //newcache->t = SDL_CreateTextureFromSurface(g_Renderer, newcache->s);
            //SDL_FreeSurface(newcache->s);
            //newcache->s = NULL;
        }
        else
        {
            newcache->s = NULL;
            newcache->t = NULL;
            newcache->xoff = 0;
            newcache->yoff = 0;
        }

        SDL_FreeRW(fp_SDL);

        //ָ������
        if (pic_file[fileid].percent > 0 && pic_file[fileid].percent != 100 && zoom != 0 && zoom != 1)
        {
            newcache->w = (int)(zoom * newcache->w);
            newcache->h = (int)(zoom * newcache->h);
            //tmpsur = newcache->t;
            //newcache->s = zoomSurface(tmpsur, zoom, zoom, SMOOTHING_ON);
            newcache->xoff = (int)(zoom * newcache->xoff);
            newcache->yoff = (int)(zoom * newcache->yoff);
            //SDL_SetColorKey(newcache->s,SDL_SRCCOLORKEY|SDL_RLEACCEL ,ConvertColor(g_MaskColor32));  //͸��ɫ
            //SDL_FreeSurface(tmpsur);
        }
        pic_file[fileid].pcache[picid] = newcache;
    }
    else     //�Ѽ�����ͼ
    {
        newcache = pic_file[fileid].pcache[picid];
    }

    if (newcache->t == NULL)     //��ͼΪ�գ�ֱ���˳�
    {
        return 1;
    }

    if (flag & 0x00000001)
    {
        r.x = x;
        r.y = y;
    }
    else
    {
        r.x = x - newcache->xoff;
        r.y = y - newcache->yoff;
    }

    //SDL_BlitSurface(newcache->s, NULL, g_Surface, &r);
    r.w = newcache->w;
    r.h = newcache->h;

    SDL_SetRenderTarget(g_Renderer, g_Texture);
    if (g_DelayTimes % 2 == 0)
    {
        newcache->t = newcache->tt[g_DelayTimes / 2 % newcache->t_count];
    }
    SDL_RenderCopy(g_Renderer, newcache->t, NULL, &r);

    return 0;
}

int JY_GetPNGXY(int fileid, int picid, int* w, int* h, int* xoff, int* yoff)
{
    int r = JY_LoadPNG(fileid, picid, g_ScreenW + 1, g_ScreenH + 1, 1, 0);   //������ͼ����������λ��

    *w = 0;
    *h = 0;
    *xoff = 0;
    *yoff = 0;

    if (r != 0)
    {
        return 1;
    }

    auto newcache = pic_file[fileid].pcache[picid / 2];

    if (newcache->t)        // ���У���ֱ����ʾ
    {
        *w = newcache->w;
        *h = newcache->h;
        *xoff = newcache->xoff;
        *yoff = newcache->yoff;
    }

    return 0;
}


// �ѱ���blit����������ǰ������
// x,y Ҫ���ص���������Ͻ�����
int RenderTexture(SDL_Texture* lps, int x, int y, int flag, int value, int color, int width, int height, double rotate, SDL_RendererFlip reversal)
{
    SDL_Surface* tmps;
    SDL_Rect rect, rect0;
    int i, j;
    //color = ConvertColor(g_MaskColor32);
    if (value > 255)
    {
        value = 255;
    }
    rect.x = x;
    rect.y = y;
    SDL_QueryTexture(lps, NULL, NULL, &rect.w, &rect.h);

    if (width > 0 && height > 0)
    {
        rect.w = width;
        rect.h = height;
    }
    else if (width > 0 && height <= 0)
    {
        rect.h = width * rect.h / rect.w;
        rect.w = width;
    }
    rect0 = rect;
    rect0.x = 0;
    rect0.y = 0;
    if (!lps)
    {
        JY_Error("BlitSurface: lps is null!");
        return 1;
    }

    if ((flag & 0x2) == 0)          // û��alpha
    {
        SDL_SetTextureColorMod(lps, 255, 255, 255);
        SDL_SetTextureBlendMode(lps, SDL_BLENDMODE_BLEND);
        SDL_SetTextureAlphaMod(lps, 255);
        RenderToTexture(lps, NULL, g_Texture, &rect, rotate, NULL, reversal);
        //SDL_BlitSurface(lps, NULL, g_Surface, &rect);
    }
    else    // ��alpha
    {
        if ((flag & 0x4) || (flag & 0x8) || (flag & 0x10))     // 4-��, 8-��, 16-��ɫ
        {
            // 4-��, 8-��, 16-��ɫ
            if (flag & 0x4)
            {
                SDL_SetTextureColorMod(lps, 32, 32, 32);
                SDL_SetTextureBlendMode(lps, SDL_BLENDMODE_BLEND);
                SDL_SetTextureAlphaMod(lps, (Uint8)value);
                RenderToTexture(lps, NULL, g_Texture, &rect, rotate, NULL, reversal);
            }
            else if (flag & 0x8)
            {
                SDL_SetTextureColorMod(lps, 255, 255, 255);
                SDL_SetTextureBlendMode(lps, SDL_BLENDMODE_NONE);
                SDL_SetTextureAlphaMod(lps, 255);
                RenderToTexture(lps, NULL, g_TextureTmp, &rect, rotate, NULL, reversal);
                SDL_SetTextureBlendMode(lps, SDL_BLENDMODE_ADD);
                SDL_SetRenderDrawColor(g_Renderer, 255, 255, 255, 255);
                SDL_SetRenderDrawBlendMode(g_Renderer, SDL_BLENDMODE_ADD);
                SDL_RenderFillRect(g_Renderer, &rect);
                SDL_SetTextureColorMod(g_TextureTmp, 255, 255, 255);
                SDL_SetTextureBlendMode(g_TextureTmp, SDL_BLENDMODE_BLEND);
                SDL_SetTextureAlphaMod(g_TextureTmp, (Uint8)value);
                RenderToTexture(g_TextureTmp, &rect, g_Texture, &rect, rotate, NULL, reversal);
                SDL_SetTextureAlphaMod(g_TextureTmp, 255);
            }
            else
            {
                Uint8 r = (Uint8)((color & RMASK) >> 16);
                Uint8 g = (Uint8)((color & GMASK) >> 8);
                Uint8 b = (Uint8)((color & BMASK));
                Uint8 a = 255;
                SDL_SetTextureColorMod(lps, 255, 255, 255);
                SDL_SetTextureBlendMode(lps, SDL_BLENDMODE_NONE);
                SDL_SetTextureAlphaMod(lps, 255);
                RenderToTexture(lps, NULL, g_TextureTmp, &rect, rotate, NULL, reversal);
                SDL_SetTextureBlendMode(lps, SDL_BLENDMODE_ADD);
                SDL_SetRenderDrawColor(g_Renderer, r, g, b, a);
                SDL_SetRenderDrawBlendMode(g_Renderer, SDL_BLENDMODE_ADD);
                SDL_RenderFillRect(g_Renderer, &rect);
                SDL_SetTextureColorMod(g_TextureTmp, 255, 255, 255);
                SDL_SetTextureBlendMode(g_TextureTmp, SDL_BLENDMODE_BLEND);
                SDL_SetTextureAlphaMod(g_TextureTmp, (Uint8)value);
                RenderToTexture(g_TextureTmp, &rect, g_Texture, &rect, rotate, NULL, reversal);
                SDL_SetTextureAlphaMod(g_TextureTmp, 255);
                //SDL_SetTextureColorMod(lps, r, g, b);
                //SDL_SetTextureBlendMode(lps, SDL_BLENDMODE_BLEND);
                //SDL_SetTextureAlphaMod(lps, (Uint8)value);
                //RenderToTexture(lps, NULL, g_Texture, &rect);
            }
        }
        else
        {
            SDL_SetTextureColorMod(lps, 255, 255, 255);
            SDL_SetTextureBlendMode(lps, SDL_BLENDMODE_BLEND);
            SDL_SetTextureAlphaMod(lps, (Uint8)value);
            RenderToTexture(lps, NULL, g_Texture, &rect,rotate, NULL, reversal);
            //SDL_BlitSurface(lps, NULL, g_Surface, &rect);
        }
    }
    return 0;
}

