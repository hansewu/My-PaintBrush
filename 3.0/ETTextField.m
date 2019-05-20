//
//  ETTextField.m
//  Paintbrush
//
//  Created by mac on 12-10-15.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ETTextField.h"


@implementation ETTextField

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
		
		[self setDrawsBackground:NO];
		
		if ([[self cell] controlSize] == NSMiniControlSize) {	// doesn't work well for mini size - text needs to be adjusted up
			[self setFont:[NSFont systemFontOfSize:11]];
		}
		else if ([[self cell] controlSize] == NSSmallControlSize) {
			[self setFont:[NSFont systemFontOfSize:11]];
		}
		else {
			[self setFont:[NSFont systemFontOfSize:11]];
		}
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	// bottom white highlight
	NSRect hightlightFrame = NSMakeRect(0.0, 10.0, [self bounds].size.width, [self bounds].size.height- 9.5);
	[[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:0.1] set];
	[[NSBezierPath bezierPathWithRoundedRect:hightlightFrame xRadius:3.6 yRadius:3.6] fill];
	
	
	// black outline
	NSRect blackOutlineFrame = NSMakeRect(0.0, 0.0, [self bounds].size.width, [self bounds].size.height-1.0);
	NSGradient *gradient = nil;
	if ([NSApp isActive]) {
		gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.24 alpha:0] endingColor:[NSColor colorWithCalibratedWhite:0.374 alpha:0]];
	}
	else {
		gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.55 alpha:0] endingColor:[NSColor colorWithCalibratedWhite:0.558 alpha:0]];
	}
	//[gradient drawInBezierPath:[NSBezierPath bezierPathWithRoundedRect:blackOutlineFrame xRadius:3.6 yRadius:3.6] angle:90];
    [gradient drawInBezierPath:[NSBezierPath bezierPathWithRect:blackOutlineFrame ] angle:90];
	
	
	// top inner shadow
	NSRect shadowFrame = NSMakeRect(1, 1, [self bounds].size.width-2.0, 0.5);
	[[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1] set];
	[[NSBezierPath bezierPathWithRoundedRect:shadowFrame xRadius:2.9 yRadius:2.9] fill];
	
	
	// main white area
	NSRect whiteFrame = NSMakeRect(1, 2, [self bounds].size.width-2.0, [self bounds].size.height-4.0);
	[[NSColor colorWithCalibratedRed:0.1 green:0.1 blue:0.1 alpha:0.5] set];
	[[NSBezierPath bezierPathWithRect:whiteFrame ] fill];
	
    
	// draw the keyboard focus ring if we're the first responder and the application is active
	if (([[self window] firstResponder] == [self currentEditor]) && [NSApp isActive])
	{	
		[NSGraphicsContext saveGraphicsState];
		NSSetFocusRingStyle(NSFocusRingOnly);
		[[NSBezierPath bezierPathWithRect:blackOutlineFrame ] fill]; 
		[NSGraphicsContext restoreGraphicsState];
	}
	else
	{
		// I don't like that the point to draw at is hard-coded, but it works for now
		[[self attributedStringValue] drawInRect:NSMakeRect(4.0, 3.0, [self bounds].size.width-8.0, [self bounds].size.width-6.0)];
	}
}


- (void)dealloc
{
    [super dealloc];
}

@end
