//
//  ETLayerProperty.h
//  Paintbrush
//
//  Created by Pisces Hsu on 12-9-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ETLayerProperty : NSObject
{
    NSString *m_strLayerName;
    NSImage  *m_layerThumbnail;
    BOOL     m_bChecked;
    float    m_fAlpha;
}
@property (retain) NSString *m_strLayerName;
@property (retain) NSImage  *m_layerThumbnail;
@property float m_fAlpha;
@property BOOL m_bChecked;
@end
