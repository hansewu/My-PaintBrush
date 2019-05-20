//
//  ETLayerProperty.m
//  Paintbrush
//
//  Created by Pisces Hsu on 12-9-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ETLayerProperty.h"


@implementation ETLayerProperty

@synthesize m_strLayerName;
@synthesize m_layerThumbnail;
@synthesize m_bChecked;
@synthesize  m_fAlpha;

- (id)init
{
    self = [super init];
    if (self) {
        m_bChecked = YES;
        m_layerThumbnail = [[NSImage alloc] init];
        m_strLayerName = @"";
    }
    return self;
}

@end
