//
//  ETRotateView.m
//  Paintbrush
//
//  Created by  on 13-1-25.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ETRotateView.h"

@implementation ETRotateView
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame]
                                                                    options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow )
                                                                      owner:self
                                                                   userInfo:nil];
        [self addTrackingArea:trackingArea];
        // Initialization code here.
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
    [[self superview] mouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [[self superview] mouseDragged:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [[self superview] mouseUp:theEvent];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    [[self superview] mouseMoved:theEvent];
}

@end
