//
//  ETLayerDataSource.h
//  Paintbrush
//
//  Created by mac on 12-9-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

//#include "SWImageDataSource.h"
#define MAX_PATH 10
struct Point {
    float x;
    float y;
};
struct Size {
    float width;
    float height;
};
struct RECT {
    Point origin;
    Size size;
};

struct RECTANGLE_PROPS {
    bool m_bIsRound;
    int m_nType;
    int m_nLineWidth;
    //RGB m_lineColor;
    //RGB m_fillColor;
};

struct ELLIPSE_PROPS {
    int m_nLineWidth;
    //RGB m_LineColor;
    //RGB m_fillColor;
    
};
struct TEXT_PROPS{
    char  m_cText[MAX_PATH];
    char  m_cFont[MAX_PATH];
    int   m_nFontSize;
    //RGB   m_textColor;
    
};

class CLayer
{
public:
    CLayer(int nLayerID, RECT rangeOfViewPosShow, int nLayerOrder, int nAlpha, bool bVisible);
    ~CLayer();
    RECT getLayerRect();
    void setLayerRect(RECT rc);
private:
    int m_nLayerID;
    int m_nLayerOrder;
    int m_nAlpha;
    bool m_bVisible;
    RECT m_rc; //相对于主程序view的rect
};

class CImageDataSourceLayer:CLayer
{
public:
    CImageDataSourceLayer(/*SWImageDataSource * dataSource,*/ int nLayerID, RECT rangeOfViewPosShow, int nLayerOrder , int nAlpha, bool bVisible);
    CImageDataSourceLayer(unsigned char *pBuf);
    ~CImageDataSourceLayer();
    RECT getLayerRect();
    void setLayerRect(RECT rc, bool bStretch = false);
    void Drawing(void *context); // [dataSource renderToContext:cgContext withFrame:rect isFocused:YES];
    
    int SaveToBuffer(unsigned char *pBuf);
    
private:
    //SWImageDataSource * m_dataSource;
};
