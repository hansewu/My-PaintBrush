//
//  ETInsertView.h
//  Paintbrush
//
//  Created by  on 13-1-24.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

//
//  ETInsertView.h
//  Paintbrush
//
//  Created by  on 13-1-14.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ETImageViewForInsertPicture.h"
struct CornerPoint
{
    float x;
    float y;
};
@interface ETInsertView : NSView 
{
    NSRect m_PictureRect;
    BOOL isDrewRect;
    id docDeleget;
    NSPoint savePoint;
    NSPoint rectOrigin;
    NSSize rectSize;
    BOOL bDragRect;
    ETImageViewForInsertPicture* imageView_1;
    ETImageViewForInsertPicture* imageView_2;
    ETImageViewForInsertPicture* imageView_3;
    ETImageViewForInsertPicture* imageView_4;
    BOOL isInDragRect;
    //float a;
    float angle;
    float angleInit;
    NSPoint rotateDragSavePoint;
    BOOL settlePic;
    ETImageViewForInsertPicture* rotateView;
    NSTextField *rectWidthAndHeight;
    NSPoint cornerPoint_1;
    NSPoint cornerPoint_2;
    NSPoint cornerPoint_3;
    NSPoint cornerPoint_4;
    NSRect dragRect_1;
    NSRect dragRect_2;
    NSRect dragRect_3;
    NSRect dragRect_4;
    BOOL bDragRect_1;
    BOOL bDragRect_2;
    BOOL bDragRect_3;
    BOOL bDragRect_4;
    BOOL bRotate;
    float alpha;
    BOOL rectSizeWidth;
    BOOL rectSizeHeight;
    NSPoint mouseMovePoint;
    NSCursor* cursor_Rotate;
    NSCursor* cursor_Move;
    NSCursor* cursor_Resize;
    NSCursor* cursor_confirm;
    NSCursor* cursor_MoveHand;
    NSTextField *degree;
    NSPoint MouseDownPoint;
    ETImageViewForInsertPicture* centerPointView;
    BOOL Move;
    BOOL Rotate;
    BOOL bConfirm;
    BOOL bMouseDown;
    // NSBitmapImageRep* mainImage;
}
@property (retain) id docDeleget;
@property float angle;
- (BOOL)pointIsInRect:(NSRect)Rect point:(NSPoint)downPoint;
- (void)drewPictureRect:(NSRect)rect;
- (NSSize)getRectSize;
- (NSPoint)getRectOrigin;
- (NSPoint)originPoint;
- (NSArray*)cornerPoint;
@end

