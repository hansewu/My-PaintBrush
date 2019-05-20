//
//  ETImageViewForInsertPicture.m
//  Paintbrush
//
//  Created by  on 13-1-24.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

//
//  ETImageViewForInsertPicture.m
//  Paintbrush
//
//  Created by  on 13-1-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ETImageViewForInsertPicture.h"

@implementation ETImageViewForInsertPicture
@synthesize isDragged;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        isDragged = NO;
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame]
                                                                    options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow )
                                                                      owner:self
                                                                   userInfo:nil];
        [self addTrackingArea:trackingArea];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    isDragged = YES;
    [[self superview] mouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    isDragged = YES;
    [[self superview] mouseDragged:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    isDragged = YES;
    [[self superview] mouseUp:theEvent];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    [[self superview] mouseMoved:theEvent];
}
//- (void)drawRect:(NSRect)dirtyRect
//{

//}

- (void)setImage:(NSImage*)image
{
    [super setImage:image];
}
- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
}
@end
