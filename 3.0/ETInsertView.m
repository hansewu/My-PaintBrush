//
//  ETInsertView.m
//  Paintbrush
//
//  Created by  on 13-1-14.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ETInsertView.h"

#import "SWDocument.h"
@implementation ETInsertView
@synthesize docDeleget;
@synthesize angle;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame]
                                                                    options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow | NSTrackingCursorUpdate | NSTrackingEnabledDuringMouseDrag | NSTrackingActiveWhenFirstResponder )
                                                                      owner:self
                                                                   userInfo:nil];
        
        [self addTrackingArea:trackingArea];
        
        isDrewRect = YES;
        bDragRect = NO;
        isInDragRect = NO;
        angle = 0.0;
        angleInit = 0.0;
        settlePic = NO;
        bDragRect_1 = NO;
        bDragRect_2 = NO;
        bDragRect_3 = NO;
        bDragRect_4 = NO;
        rectSizeWidth = NO;
        rectSizeHeight = NO;
        bRotate = NO;
        Move = NO;
        Rotate = NO;
        bConfirm = NO;
        bMouseDown = NO;
        cursor_Rotate = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"mouseRotate.png"] hotSpot:NSMakePoint(1,14)];
        cursor_Resize = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"S16.png"] hotSpot:NSMakePoint(1,14)];
        cursor_confirm = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"OK.png"] hotSpot:NSMakePoint(1,14)];
        cursor_MoveHand = [[NSCursor closedHandCursor] retain];
        cursor_Move = [[NSCursor openHandCursor] retain];
    }
    
    return self;
}

- (void)dealloc
{	
    [rotateView removeFromSuperview];
    [imageView_1 removeFromSuperview];
    [imageView_2 removeFromSuperview];
    [imageView_3 removeFromSuperview];
    [imageView_4 removeFromSuperview];
    [centerPointView removeFromSuperview];
    [centerPointView release];
    [imageView_4 release];
    [imageView_3 release];
    [imageView_2 release];
    [imageView_1 release];
    [degree release];
    [rotateView release];
    [rectWidthAndHeight release];
    [cursor_Rotate release];
    [cursor_Resize release];
    [cursor_Move release];
    [cursor_MoveHand release];
    [cursor_confirm release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
    if(isDrewRect)
    {       
        CGFloat dottedLineArray[2];
        dottedLineArray[0] = 3.0;
        dottedLineArray[1] = 5.0;
        
        
        NSBezierPath* path = [NSBezierPath bezierPath];
        [path setLineWidth:2.0];
        [path setLineDash:dottedLineArray count:2 phase:10.0];
        [path setLineCapStyle:NSSquareLineCapStyle];	
        
        [path moveToPoint:cornerPoint_1];
        [path lineToPoint:cornerPoint_2];
        [path moveToPoint:cornerPoint_2];
        [path lineToPoint:cornerPoint_3];
        [path moveToPoint:cornerPoint_3];
        [path lineToPoint:cornerPoint_4];
        [path moveToPoint:cornerPoint_4];
        [path lineToPoint:cornerPoint_1];
        
        
        [[NSColor blackColor] setStroke];
        [path stroke];
	}
    else 
    {
        
    }
}

- (void)drewPictureRect:(NSRect)rect
{
    m_PictureRect = rect;
    rectOrigin = m_PictureRect.origin;
    rectSize = m_PictureRect.size;
    alpha = atanf(rectSize.height/rectSize.width);
    centerPointView = [[ETImageViewForInsertPicture alloc] init];
    
    imageView_1 = [[ETImageViewForInsertPicture alloc] init];
    [imageView_1 setImage:[NSImage imageNamed:@"S30.png"]];
    [self addSubview:imageView_1];
    imageView_2 = [[ETImageViewForInsertPicture alloc] init];
    [imageView_2 setImage:[NSImage imageNamed:@"S30.png"]];
    [self addSubview:imageView_2];
    imageView_3 = [[ETImageViewForInsertPicture alloc] init];
    [imageView_3 setImage:[NSImage imageNamed:@"S30.png"]];
    [self addSubview:imageView_3];
    imageView_4 = [[ETImageViewForInsertPicture alloc] init];
    [imageView_4 setImage:[NSImage imageNamed:@"S30.png"]];
    [self addSubview:imageView_4];
    float width = [self frame].size.width + 2000;
    float height = [self frame].size.height + 2000;
    float x = [self frame].origin.x - 1000;
    float y = [self frame].origin.y - 1000;
    id A = [[self subviews] objectAtIndex:0];
    [A setFrame:NSMakeRect(x, y, width, height)];
    [centerPointView setFrame:NSMakeRect([A frame].origin.x + [A frame].size.width/2 - 8, [A frame].origin.y + [A frame].size.height/2 - 8, 16, 16)];
    [centerPointView setImage:[NSImage imageNamed:@"center.png"]];
    [self cornerPoint];
    dragRect_1 = NSMakeRect(cornerPoint_1.x-10, cornerPoint_1.y-10, 20, 20);
    dragRect_2 = NSMakeRect(cornerPoint_2.x-10, cornerPoint_2.y-10, 20, 20);
    dragRect_3 = NSMakeRect(cornerPoint_3.x-10, cornerPoint_3.y-10, 20, 20);
    dragRect_4 = NSMakeRect(cornerPoint_4.x-10, cornerPoint_4.y-10, 20, 20);
    [imageView_1 setFrame:dragRect_1];
    [imageView_2 setFrame:dragRect_2];
    [imageView_3 setFrame:dragRect_3];
    [imageView_4 setFrame:dragRect_4];
    [self setNeedsDisplay:YES];
    rotateView = [[ETImageViewForInsertPicture alloc] init];
    [rotateView setImage:[NSImage imageNamed:@"rotate_None.png"]];
    [rotateView setFrame:NSMakeRect([A frame].origin.x + [A frame].size.width/2 - 50, [A frame].origin.y + [A frame].size.height/2 - 50, 100, 100)];
    degree = [[NSTextField alloc] init];
    
    [self addSubview:rotateView];
    [self addSubview:centerPointView];
    [degree setFloatValue:0.00];
    [degree setEditable:NO];
    
    [degree setBackgroundColor:[NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:0]];
    [degree setBezeled:None];
    [degree setAlignment:NSCenterTextAlignment];
    rectWidthAndHeight = [[NSTextField alloc] init];
    [rectWidthAndHeight setEditable:NO];
    [rectWidthAndHeight setFrameSize:NSMakeSize(70, 40)];
    [rectWidthAndHeight setBackgroundColor:[NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:0.5]];
    [rectWidthAndHeight setBezelStyle:None];
}


- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)event
{
    NSString *chars = [event characters];
    unichar character = [chars characterAtIndex: 0];
    if (character == NSEnterCharacter) {
        isDrewRect = NO;
        [docDeleget concernTheInsertPicture];
        settlePic = YES;
    }
}

- (void)keyUp:(NSEvent *)event
{
    ;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    bMouseDown = YES;
    if([theEvent clickCount] == 2)
    {
        isDrewRect = NO;
        [docDeleget concernTheInsertPicture];
        settlePic = YES;
        return;
    }
    MouseDownPoint = [theEvent locationInWindow];
    MouseDownPoint = [self convertPoint:MouseDownPoint fromView:nil];
    rotateDragSavePoint = MouseDownPoint;
    savePoint = rotateDragSavePoint;
    if([self pointIsInRect:dragRect_1 point:savePoint]||[self pointIsInRect:dragRect_2 point:savePoint]||[self pointIsInRect:dragRect_3 point:savePoint]||[self pointIsInRect:dragRect_4 point:savePoint])
    {
        isInDragRect = YES;
        bDragRect = YES;
        if([self pointIsInRect:dragRect_1 point:savePoint])
        {
            bDragRect_1 = YES;
            cornerPoint_1.x>cornerPoint_3.x?(rectSizeWidth = YES):(rectSizeWidth = NO);
            cornerPoint_1.y>cornerPoint_3.y?(rectSizeHeight = YES):(rectSizeHeight = NO);
            
        }
        else if([self pointIsInRect:dragRect_2 point:savePoint])
        {
            bDragRect_2 = YES;
            cornerPoint_2.x>cornerPoint_4.x?(rectSizeWidth = YES):(rectSizeWidth = NO);
            cornerPoint_2.y>cornerPoint_4.y?(rectSizeHeight = YES):(rectSizeHeight = NO);
        }
        else if([self pointIsInRect:dragRect_3 point:savePoint])
        {
            bDragRect_3 = YES;
            cornerPoint_3.x>cornerPoint_1.x?(rectSizeWidth = YES):(rectSizeWidth = NO);
            cornerPoint_3.y>cornerPoint_1.y?(rectSizeHeight = YES):(rectSizeHeight = NO);
        }
        else if([self pointIsInRect:dragRect_4 point:savePoint])
        {
            bDragRect_4 = YES;
            cornerPoint_4.x>cornerPoint_2.x?(rectSizeWidth = YES):(rectSizeWidth = NO);
            cornerPoint_4.y>cornerPoint_2.y?(rectSizeHeight = YES):(rectSizeHeight = NO);
        }
    }
    else
    {
        isInDragRect = NO;
        id A = [[self subviews] objectAtIndex:0];
        NSPoint ceter = NSMakePoint([A frame].origin.x + [A frame].size.width/2, [A frame].origin.y + [A frame].size.height/2);
        if([[[self subviews] objectAtIndex:0] isDragged]||[[[self subviews] objectAtIndex:5] isDragged]||[[[self subviews] objectAtIndex:6] isDragged])
        {  
            if([[[self subviews] objectAtIndex:0] isDragged] )
            {
                isDrewRect = YES;
                Move = YES;
                Rotate = NO;
            }
            else if([[[self subviews] objectAtIndex:6] isDragged]||sqrt((ceter.x - MouseDownPoint.x)*(ceter.x - MouseDownPoint.x) + (ceter.y - MouseDownPoint.y)*(ceter.y - MouseDownPoint.y)) < 25)
            {
                isDrewRect = NO;
                [docDeleget concernTheInsertPicture];
                settlePic = YES;
                return;
            }
            else if(sqrt((ceter.x - MouseDownPoint.x)*(ceter.x - MouseDownPoint.x) + (ceter.y - MouseDownPoint.y)*(ceter.y - MouseDownPoint.y)) < 50 &&sqrt((ceter.x - MouseDownPoint.x)*(ceter.x - MouseDownPoint.x) + (ceter.y - MouseDownPoint.y)*(ceter.y - MouseDownPoint.y)) >25)
            {
                Rotate = YES;
                Move = NO;
            }
            else
            {
                isDrewRect = NO;
            }
        }
    }
    [self cornerPoint];
    dragRect_1 = NSMakeRect(cornerPoint_1.x-10, cornerPoint_1.y-10, 20, 20);
    dragRect_2 = NSMakeRect(cornerPoint_2.x-10, cornerPoint_2.y-10, 20, 20);
    dragRect_3 = NSMakeRect(cornerPoint_3.x-10, cornerPoint_3.y-10, 20, 20);
    dragRect_4 = NSMakeRect(cornerPoint_4.x-10, cornerPoint_4.y-10, 20, 20);
    [imageView_1 setFrame:dragRect_1];
    [imageView_2 setFrame:dragRect_2];
    [imageView_3 setFrame:dragRect_3];
    [imageView_4 setFrame:dragRect_4];
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    
    NSPoint curPoint = [theEvent locationInWindow];
    curPoint = [self convertPoint:curPoint fromView:nil];
    
    if(bDragRect)
    {
        if(bDragRect_1)
        {
            NSPoint origin = rectOrigin;
            NSSize size = rectSize;
            rectSize = NSMakeSize(rectSizeWidth?rectSize.width + curPoint.x - savePoint.x:rectSize.width - curPoint.x + savePoint.x, rectSizeHeight?rectSize.height + curPoint.y - savePoint.y:rectSize.height - curPoint.y + savePoint.y);
            rectOrigin.y = rectOrigin.y + curPoint.y - savePoint.y;
            if(rectSize.width <= 20 || rectSize.height <= 20)
            {
                rectSize = size;
                rectOrigin = origin;
                return;
            }
            [[[[self subviews] objectAtIndex:0] image] setSize:rectSize];
            id A = [[self subviews] objectAtIndex:0];
            
            [A setFrameOrigin:NSMakePoint([A frame].origin.x + (curPoint.x - savePoint.x)/2, [A frame].origin.y + (curPoint.y - savePoint.y)/2)];
            savePoint = curPoint;
            NSString *whString = [[NSString alloc] initWithFormat:@"W:%0.1f\nH:%0.1f",rectSize.width,rectSize.height];
            [rectWidthAndHeight setStringValue:whString];
            [rectWidthAndHeight setFrameOrigin:curPoint];
            [self addSubview:rectWidthAndHeight];
            [[[[self subviews] objectAtIndex:0] image] setSize:rectSize];
            [centerPointView setFrame:NSMakeRect([A frame].origin.x + [A frame].size.width/2 - 8, [A frame].origin.y + [A frame].size.height/2 - 8, 16, 16)];
            [rotateView setFrame:NSMakeRect([A frame].origin.x + [A frame].size.width/2 - 50, [A frame].origin.y + [A frame].size.height/2 - 50, 100, 100)];
        }
        else if(bDragRect_2)
        {
            NSPoint origin = rectOrigin;
            NSSize size = rectSize;
            rectOrigin.y = rectOrigin.y + curPoint.y - savePoint.y;
            rectSize = NSMakeSize(rectSizeWidth?rectSize.width + curPoint.x - savePoint.x:rectSize.width - curPoint.x + savePoint.x, rectSizeHeight?rectSize.height + curPoint.y - savePoint.y:rectSize.height - curPoint.y + savePoint.y);
            if(rectSize.width <= 20 || rectSize.height <= 20)
            {
                rectSize = size;
                rectOrigin = origin;
                return;
            }
            [[[[self subviews] objectAtIndex:0] image] setSize:rectSize];
            id A = [[self subviews] objectAtIndex:0];
            
            [A setFrameOrigin:NSMakePoint([A frame].origin.x + (curPoint.x - savePoint.x)/2, [A frame].origin.y + (curPoint.y - savePoint.y)/2)];
            savePoint = curPoint;
            NSString *whString = [[NSString alloc] initWithFormat:@"W:%0.1f\nH:%0.1f",rectSize.width,rectSize.height];
            [rectWidthAndHeight setStringValue:whString];
            [rectWidthAndHeight setFrameOrigin:curPoint];
            [self addSubview:rectWidthAndHeight];
            [[[[self subviews] objectAtIndex:0] image] setSize:rectSize];
            [centerPointView setFrame:NSMakeRect([A frame].origin.x + [A frame].size.width/2 - 8, [A frame].origin.y + [A frame].size.height/2 - 8, 16, 16)];
            [rotateView setFrame:NSMakeRect([A frame].origin.x + [A frame].size.width/2 - 50, [A frame].origin.y + [A frame].size.height/2 - 50, 100, 100)];
        }
        else if(bDragRect_3)
        {
            NSPoint origin = rectOrigin;
            NSSize size = rectSize;
            rectOrigin.y = rectOrigin.y + curPoint.y - savePoint.y;
            rectSize = NSMakeSize(rectSizeWidth?rectSize.width + curPoint.x - savePoint.x:rectSize.width - curPoint.x + savePoint.x, rectSizeHeight?rectSize.height + curPoint.y - savePoint.y:rectSize.height - curPoint.y + savePoint.y);
            if(rectSize.width <= 20 || rectSize.height <= 20)
            {
                rectSize = size;
                rectOrigin = origin;
                return;
            }
            
            [[[[self subviews] objectAtIndex:0] image] setSize:rectSize];
            id A = [[self subviews] objectAtIndex:0];
            
            [A setFrameOrigin:NSMakePoint([A frame].origin.x + (curPoint.x - savePoint.x)/2, [A frame].origin.y + (curPoint.y - savePoint.y)/2)];
            savePoint = curPoint;
            NSString *whString = [[NSString alloc] initWithFormat:@"W:%0.1f\nH:%0.1f",rectSize.width,rectSize.height];
            [rectWidthAndHeight setStringValue:whString];
            [rectWidthAndHeight setFrameOrigin:curPoint];
            [self addSubview:rectWidthAndHeight];
            [[[[self subviews] objectAtIndex:0] image] setSize:rectSize];
            [centerPointView setFrame:NSMakeRect([A frame].origin.x + [A frame].size.width/2 - 8, [A frame].origin.y + [A frame].size.height/2 - 8, 16, 16)];
            [rotateView setFrame:NSMakeRect([A frame].origin.x + [A frame].size.width/2 - 50, [A frame].origin.y + [A frame].size.height/2 - 50, 100, 100)];
        }
        else if(bDragRect_4)
        {
            NSPoint origin = rectOrigin;
            NSSize size = rectSize;
            rectOrigin.y = rectOrigin.y + curPoint.y - savePoint.y;
            rectSize = NSMakeSize(rectSizeWidth?rectSize.width + curPoint.x - savePoint.x:rectSize.width - curPoint.x + savePoint.x, rectSizeHeight?rectSize.height + curPoint.y - savePoint.y:rectSize.height - curPoint.y + savePoint.y);
            if(rectSize.width <= 20 || rectSize.height <= 20)
            {
                rectSize = size;
                rectOrigin = origin;
                return;
            }
            
            [[[[self subviews] objectAtIndex:0] image] setSize:rectSize];
            id A = [[self subviews] objectAtIndex:0];
            
            [A setFrameOrigin:NSMakePoint([A frame].origin.x + (curPoint.x - savePoint.x)/2, [A frame].origin.y + (curPoint.y - savePoint.y)/2)];
            savePoint = curPoint;
            NSString *whString = [[NSString alloc] initWithFormat:@"W:%0.1f\nH:%0.1f",rectSize.width,rectSize.height];
            [rectWidthAndHeight setStringValue:whString];
            [rectWidthAndHeight setFrameOrigin:curPoint];
            [self addSubview:rectWidthAndHeight];
            [[[[self subviews] objectAtIndex:0] image] setSize:rectSize];
            [centerPointView setFrame:NSMakeRect([A frame].origin.x + [A frame].size.width/2 - 8, [A frame].origin.y + [A frame].size.height/2 - 8, 16, 16)];
            [rotateView setFrame:NSMakeRect([A frame].origin.x + [A frame].size.width/2 - 50, [A frame].origin.y + [A frame].size.height/2 - 50, 100, 100)];
        }
    }
    else
    {
        id A = [[self subviews] objectAtIndex:0];
        //NSPoint ceter = NSMakePoint([A frame].origin.x + [A frame].size.width/2, [A frame].origin.y + [A frame].size.height/2);
        if([[[self subviews] objectAtIndex:0] isDragged]||[[[self subviews] objectAtIndex:5] isDragged]||[[[self subviews] objectAtIndex:6] isDragged])
        {
            if(Move)
            {
                isDrewRect = YES;
                
                rectOrigin.x = rectOrigin.x + curPoint.x - savePoint.x;
                rectOrigin.y = rectOrigin.y + curPoint.y - savePoint.y;
                
                //id A = [[self subviews] objectAtIndex:0];
                NSPoint origin = NSMakePoint([A frame].origin.x + curPoint.x - savePoint.x, [A frame].origin.y + curPoint.y - savePoint.y);
                savePoint = curPoint;
                [A setFrameOrigin:origin];
                [centerPointView setFrame:NSMakeRect([A frame].origin.x + [A frame].size.width/2 - 8, [A frame].origin.y + [A frame].size.height/2 - 8, 16, 16)];
                [rotateView setFrame:NSMakeRect([A frame].origin.x + [A frame].size.width/2 - 50, [A frame].origin.y + [A frame].size.height/2 - 50, 100, 100)];
            }
            else if(Rotate)
            {
                NSPoint centerPoint ;
                //id A = [[self subviews] objectAtIndex:0];
                centerPoint = NSMakePoint([A frame].origin.x + [A frame].size.width/2,[A frame].origin.y + [A frame].size.height/2);
                if(angle == 179)
                    angle = 180;
                else
                {
                    angle = angleInit + atan2f((curPoint.x - savePoint.x),(-curPoint.y + centerPoint.y))/M_PI*180;
                }
                if(angle > 180)
                    angle = angle - 360;
                else if(angle < -180)
                    angle = angle + 360;
                angle = (int)angle;
                NSLog(@"%f",angle);
                [A setBoundsRotation:angle];
                //[rotateView setFrameOrigin:NSMakePoint([rotateView frame].origin.x+curPoint.x-rotateDragSavePoint.x, [rotateView frame].origin.y+curPoint.y-rotateDragSavePoint.y)];
                rotateDragSavePoint = curPoint;
                [degree setFrame:NSMakeRect(26, 3, 48, 18)];
                
                [rotateView addSubview:degree];
                NSString* degreeString = [[NSString alloc] initWithFormat:@"%i°",(int)angle];
                [[[rotateView subviews] objectAtIndex:0] setStringValue:degreeString];
                [centerPointView setFrame:NSMakeRect([A frame].origin.x + [A frame].size.width/2 - 8, [A frame].origin.y + [A frame].size.height/2 - 8, 16, 16)];
            }
            
        }
        else
        {
            isDrewRect = NO;
        }
    }
    [self cornerPoint];
    dragRect_1 = NSMakeRect(cornerPoint_1.x-10, cornerPoint_1.y-10, 20, 20);
    dragRect_2 = NSMakeRect(cornerPoint_2.x-10, cornerPoint_2.y-10, 20, 20);
    dragRect_3 = NSMakeRect(cornerPoint_3.x-10, cornerPoint_3.y-10, 20, 20);
    dragRect_4 = NSMakeRect(cornerPoint_4.x-10, cornerPoint_4.y-10, 20, 20);
    [imageView_1 setFrame:dragRect_1];
    [imageView_2 setFrame:dragRect_2];
    [imageView_3 setFrame:dragRect_3];
    [imageView_4 setFrame:dragRect_4];
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    bMouseDown = NO;
    isInDragRect = NO;
    if(settlePic)
        return;
    angleInit = angle;
    if(angleInit>=360)
        angleInit = angleInit -360;
    else if(angleInit <= -360)
        angleInit = angleInit +360;
    id A = [[self subviews] objectAtIndex:0];
    [rotateView setFrame:NSMakeRect([A frame].origin.x + [A frame].size.width/2 - 50, [A frame].origin.y + [A frame].size.height/2 - 50, 100, 100)];
    if(bDragRect)
    {
        [[[self subviews] objectAtIndex:0] setIsDragged:NO];
        [rectWidthAndHeight removeFromSuperview];
    }
    else
    {
        if([[[self subviews] objectAtIndex:0] isDragged]||[[[self subviews] objectAtIndex:5] isDragged]||[[[self subviews] objectAtIndex:6] isDragged])
        {
            isDrewRect = YES;
            if(Rotate)
                [degree removeFromSuperview];
            Move = NO;
            Rotate = NO;
            [[[self subviews] objectAtIndex:0] setIsDragged:NO];
            [[[self subviews] objectAtIndex:5] setIsDragged:NO];
            [[[self subviews] objectAtIndex:6] setIsDragged:NO];
            
        }
        else
        {
            isDrewRect = NO;
            [docDeleget concernTheInsertPicture];
        }
    }
    bDragRect = NO;
    bDragRect_1 = NO;
    bDragRect_2 = NO;
    bDragRect_3 = NO;
    bDragRect_4 = NO;
    [self cornerPoint];
    dragRect_1 = NSMakeRect(cornerPoint_1.x-10, cornerPoint_1.y-10, 20, 20);
    dragRect_2 = NSMakeRect(cornerPoint_2.x-10, cornerPoint_2.y-10, 20, 20);
    dragRect_3 = NSMakeRect(cornerPoint_3.x-10, cornerPoint_3.y-10, 20, 20);
    dragRect_4 = NSMakeRect(cornerPoint_4.x-10, cornerPoint_4.y-10, 20, 20);
    [imageView_1 setFrame:dragRect_1];
    [imageView_2 setFrame:dragRect_2];
    [imageView_3 setFrame:dragRect_3];
    [imageView_4 setFrame:dragRect_4];
    [self setNeedsDisplay:YES];
}

- (void)mouseMoved:(NSEvent *)event
{
    mouseMovePoint = [event locationInWindow];
    mouseMovePoint = [self convertPoint:mouseMovePoint fromView:nil];
    id A = [[self subviews] objectAtIndex:0];
    NSPoint ceter = NSMakePoint([A frame].origin.x + [A frame].size.width/2, [A frame].origin.y + [A frame].size.height/2);
    dragRect_1 = NSMakeRect(cornerPoint_1.x-10, cornerPoint_1.y-10, 20, 20);
    dragRect_2 = NSMakeRect(cornerPoint_2.x-10, cornerPoint_2.y-10, 20, 20);
    dragRect_3 = NSMakeRect(cornerPoint_3.x-10, cornerPoint_3.y-10, 20, 20);
    dragRect_4 = NSMakeRect(cornerPoint_4.x-10, cornerPoint_4.y-10, 20, 20);
    if(sqrt((ceter.x - mouseMovePoint.x)*(ceter.x - mouseMovePoint.x) + (ceter.y - mouseMovePoint.y)*(ceter.y - mouseMovePoint.y)) < 50 &&sqrt((ceter.x - mouseMovePoint.x)*(ceter.x - mouseMovePoint.x) + (ceter.y - mouseMovePoint.y)*(ceter.y - mouseMovePoint.y)) >25)
    {
        bRotate = YES;
        bConfirm = NO;
        [rotateView setImage:[NSImage imageNamed:@"rotate_outside.png"]];
    }
    else if(sqrt((ceter.x - mouseMovePoint.x)*(ceter.x - mouseMovePoint.x) + (ceter.y - mouseMovePoint.y)*(ceter.y - mouseMovePoint.y)) <25)
    {
        bRotate = NO;
        bConfirm = YES;
        [rotateView setImage:[NSImage imageNamed:@"rotate_inside.png"]];
    }
    else
    {
        bRotate = NO;
        bConfirm = NO;
        [rotateView setImage:[NSImage imageNamed:@"rotate_None.png"]];
    }
    if([self pointIsInRect:dragRect_1 point:mouseMovePoint]||[self pointIsInRect:dragRect_2 point:mouseMovePoint]||[self pointIsInRect:dragRect_3 point:mouseMovePoint]||[self pointIsInRect:dragRect_4 point:mouseMovePoint])
        isInDragRect = YES;
    else
        isInDragRect = NO;
    [self cursorUpdate:nil];
}


- (void)cursorUpdate:(NSEvent *)event
{
    
    if(bConfirm)
    {
        [(NSClipView *)[[self superview] superview] setDocumentCursor:cursor_confirm];
        [cursor_confirm push];
    }
    else if(bRotate)
    {
        
        [(NSClipView *)[[self superview] superview] setDocumentCursor:cursor_Rotate];
        [cursor_Rotate push];
    }
    else if(isInDragRect)
    {
        [(NSClipView *)[[self superview] superview] setDocumentCursor:cursor_Resize];
        [cursor_Resize push];
        
    }
    else
    {
        if(bMouseDown)
        {
            [(NSClipView *)[[self superview] superview] setDocumentCursor:cursor_MoveHand];
            [cursor_MoveHand push];
        }
        else 
        {
            [(NSClipView *)[[self superview] superview] setDocumentCursor:cursor_Move];
            [cursor_Move push];
        }
    }
}



- (BOOL)pointIsInRect:(NSRect)Rect point:(NSPoint)downPoint
{
    if(((downPoint.x > Rect.origin.x && downPoint.x < (Rect.origin.x + Rect.size.width))||(downPoint.x < Rect.origin.x && downPoint.x > (Rect.origin.x + Rect.size.width))) && ((downPoint.y > Rect.origin.y && downPoint.y < (Rect.origin.y + Rect.size.height))|| (downPoint.y < Rect.origin.y && downPoint.y > (Rect.origin.y + Rect.size.height))))
        return YES;
    else
        return NO;
}

- (NSSize)getRectSize
{
    return rectSize;
}

- (NSPoint)getRectOrigin
{
    return rectOrigin;
}
/**************************************************************************************************/
- (NSPoint)originPoint //返回图片旋转后的中心点转换到paintView坐标系下坐标值
{
    NSPoint originPoint;
    id A = [[self subviews] objectAtIndex:0];
    NSPoint _centerPoint = NSMakePoint([A frame].origin.x + [A frame].size.width/2, [self frame].size.height - [A frame].origin.y - [A frame].size.height/2);
    float centerPoint_X = _centerPoint.x;
    float centerPoint_Y = _centerPoint.y;
    float sin0 = centerPoint_X/sqrt(centerPoint_X*centerPoint_X + centerPoint_Y*centerPoint_Y);
    float cos0 = centerPoint_Y/sqrt(centerPoint_X*centerPoint_X + centerPoint_Y*centerPoint_Y); 
    float x = sqrt(centerPoint_X*centerPoint_X + centerPoint_Y*centerPoint_Y)*(cos(M_PI*angle/180)*sin0 - sin(M_PI*angle/180)*cos0);
    float y = sqrt(centerPoint_X*centerPoint_X + centerPoint_Y*centerPoint_Y)*(cos(M_PI*angle/180)*cos0 + sin(M_PI*angle/180)*sin0);
    originPoint = NSMakePoint(x, y);
    return originPoint;
}

- (NSArray*)cornerPoint
{
    NSPoint centerPoint;
    id A = [[self subviews] objectAtIndex:0];
    centerPoint.x = [A frame].origin.x + [A frame].size.width/2;
    centerPoint.y = [A frame].origin.y + [A frame].size.height/2;
    float theta = atan((rectSize.height/2)/(rectSize.width/2));
    
    float r = sqrtf(rectSize.width*rectSize.width/4 + rectSize.height*rectSize.height/4);
    cornerPoint_1.x = centerPoint.x + r*sin(-(M_PI*angle/180 + theta+M_PI/2));
    cornerPoint_1.y = centerPoint.y + r*cos(-(M_PI*angle/180 + theta+M_PI/2));
    cornerPoint_2.x = centerPoint.x + r*sin(-(M_PI*angle/180 - theta+M_PI/2));
    cornerPoint_2.y = centerPoint.y + r*cos(-(M_PI*angle/180 - theta+M_PI/2));
    cornerPoint_3.x = centerPoint.x + (centerPoint.x - cornerPoint_1.x);
    cornerPoint_3.y = centerPoint.y + (centerPoint.y - cornerPoint_1.y);
    cornerPoint_4.x = centerPoint.x + (centerPoint.x - cornerPoint_2.x);
    cornerPoint_4.y = centerPoint.y + (centerPoint.y - cornerPoint_2.y);
    return nil;
}

@end
