//
//  LayerDataSource.h
//  Paintbrush
//
//  Created by mac on 12-9-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWImageDataSource.h"


@interface LayerDataSource : NSObject {
@private
    int m_nLayerID;
    int m_nLayerOrder;
    int m_nAlpha;
    BOOL m_bVisible;
    NSString* m_sLayerName;
    NSRect m_rc; 
    SWImageDataSource * m_dataSource;
    NSMutableDictionary* m_layerDic;
}
@property int m_nLayerID;
@property int m_nLayerOrder;
@property int m_nAlpha;
@property BOOL m_bVisible;
@property (retain) NSString* m_sLayerName;
@property (retain) SWImageDataSource* m_dataSource;
@property (retain) NSMutableDictionary* m_layerDic;
- (void)setLayerRect:(NSRect)rc;
- (NSRect)getLayerRect;
- (void)setLayerRect:(NSRect)rc  stretch:(BOOL)bStretch;

@end
extern  NSString*  const ETPB_Width;
extern  NSString*  const ETPB_Height;
extern  NSString*  const ETPB_LAYER_FILE;
extern  NSString*  const ETPB_LAYER_bVisible;
extern  NSString*  const ETPB_LAYER_Alpha;
extern  NSString*  const ETPB_LAYER_ID;
extern  NSString*  const ETPB_LAYER_Order;
extern  NSString*  const ETPB_LAYER_Name;
extern  NSString*  const XML_File;
extern  NSString*  const ETPB_Version;
extern NSString* const Version;