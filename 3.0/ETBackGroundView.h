//
//  ETBackGroundView.h
//  Paintbrush
//
//  Created by mac on 12-9-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SWPaintView.h"

@class SWImageDataSource;
@class SWToolbox;
@class SWDocument;

@interface ETBackGroundView : NSView {
    id m_curLayer;
    IBOutlet SWDocument* document;
    SWImageDataSource* datasource;
    SWToolbox* toolBox;
}
- (SWPaintView*)creatCombineView;
- (SWImageDataSource*)getDatasource;
- (id)insertNewViewAtIndex:(int)index;
- (id)addNewView:(int)layerOrder type:(int)type;
- (NSRect)calculateWindowBounds:(NSRect)frameRect;
- (void)setUp:(SWToolbox*)toolbox;
- (void)setCurLayer:(id)curLayer;
- (id)getCurLayer;

-(void)addLayer:(id)layer atIndex:(int)index;
@end
