//
//  LayerDataSource.m
//  Paintbrush
//
//  Created by mac on 12-9-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "LayerDataSource.h"
NSString* const XML_File = @"XML_File";
NSString* const ETPB_Width = @"ETPB_Width";
NSString* const ETPB_Height = @"ETPB_Height";
NSString* const ETPB_LAYER_FILE = @"ETPB_LAYER_FILE";
NSString* const ETPB_LAYER_bVisible = @"ETPB_LAYER_bVisible";
NSString* const ETPB_LAYER_Alpha = @"ETPB_LAYER_Alpha";
NSString* const ETPB_LAYER_ID = @"ETPB_LAYER_ID";
NSString* const ETPB_LAYER_Order = @"ETPB_LAYER_Order";
NSString*  const ETPB_LAYER_Name = @"ETPB_LAYER_Name";
NSString* const ETPB_Version =@"ETPB_Version";
NSString*  const Version = @"Pro1.20";
@implementation LayerDataSource
@synthesize  m_nLayerID;
@synthesize m_nLayerOrder;
@synthesize m_nAlpha;
@synthesize m_bVisible;
@synthesize m_dataSource;
@synthesize m_layerDic;
@synthesize m_sLayerName;

- (id)init
{
    self = [super init];
    if (self) {
        m_dataSource = [[SWImageDataSource alloc] init];
        m_layerDic = [[NSMutableDictionary alloc] init];
        m_nAlpha = 255;
        m_nLayerID = 0;
        m_nLayerOrder = 0;
        m_bVisible = YES;
    }
    
    return self;
}

- (void)dealloc
{
    [m_dataSource release];
    [m_layerDic release];
    [super dealloc];
}

- (void)setLayerRect:(NSRect)rc
{
    m_rc = rc;
}

- (NSRect)getLayerRect
{
    return m_rc;
}

- (void)setLayerRect:(NSRect)rc  stretch:(BOOL)bStretch
{
    
}


@end
