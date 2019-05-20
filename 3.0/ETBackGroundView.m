//
//  ETBackGroundView.m
//  Paintbrush
//
//  Created by mac on 12-9-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ETBackGroundView.h"
#import "SWDocument.h"
#import "SWImageDataSource.h"
#import "SWToolbox.h"
#import "SWSelectionTool.h"

@implementation ETBackGroundView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    if (toolBox)
    {
        [toolBox release];
    }
    
    if (datasource)
    {
        [datasource release];
    }
    [super dealloc];
}

- (NSRect)calculateWindowBounds:(NSRect)frameRect
{
	// Set the window's maximum size to the size of the screen
	// Does not seem to work all the time
	NSRect screenRect = [[NSScreen mainScreen] frame];
	
	// Center the shrunken/enlarged window with respect to its initial location
	NSRect tempRect = [[super window] frameRectForContentRect:frameRect];
	NSPoint newOrigin = [[super window] frame].origin;
	
	tempRect.size.width += [NSScroller scrollerWidth];
	tempRect.size.height += [NSScroller scrollerWidth];
	
	newOrigin.y += floor(0.5 * ([[super window] frame].size.height - tempRect.size.height));
	newOrigin.x += floor(0.5 * ([[super window] frame].size.width - tempRect.size.width));
	tempRect.origin = newOrigin;
	
	// Ensures that the document is never wider than the screen
	tempRect.size.width = MIN(screenRect.size.width, tempRect.size.width);
	
	// Assert some minimum and maximum values!
	tempRect.size.width = MAX([[super window] minSize].width, tempRect.size.width);
	tempRect.size.height = MAX([[super window] minSize].height, tempRect.size.height);
	
	tempRect.origin.x = MAX(tempRect.origin.x, 0);
	
	return tempRect;
}

- (void)setUp:(SWToolbox*)toolbox
{
    toolBox = [toolbox retain];
    NSColor *bgColor = [NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:1];
        datasource = [[SWImageDataSource alloc] initWithSize:[self bounds].size backGroundColor:bgColor];  
    [self setNeedsDisplay:YES];	
}

- (id)addNewView:(int)layerOrder type:(int)type
{
    SWPaintView* paintView = [[SWPaintView alloc] init];
    
    [self addSubview:paintView];
    [paintView setFrame:[self bounds]];
    [paintView preparePaintViewWithDataSource:nil toolbox:toolBox type:type];
    [[paintView m_layerDataSource] setM_nLayerOrder:layerOrder+1];
    //NSRect viewRect = [paintView frame];
	//NSRect tempRect = [paintView calculateWindowBounds:viewRect];
	//[[paintView window] setFrame:tempRect display:YES animate:YES];
    m_curLayer = paintView;
    return paintView;
}

- (SWPaintView*)creatCombineView
{
    SWPaintView* paintView = [[SWPaintView alloc] init];
    
    [self addSubview:paintView];
    [paintView setFrame:[self bounds]];
    [paintView preparePaintViewWithDataSource:nil toolbox:toolBox type:1];
    [[paintView m_layerDataSource] setM_nLayerOrder:[[self subviews] count]-1];
    //NSRect viewRect = [paintView frame];
	//NSRect tempRect = [paintView calculateWindowBounds:viewRect];
	//[[paintView window] setFrame:tempRect display:YES animate:YES];
    return paintView;
}

- (id)insertNewViewAtIndex:(int)index
{
    SWPaintView* paintView = [[SWPaintView alloc] init];
    [self addSubview:paintView];
    int i ;
    int count = [[self subviews] count];
    for(i = index; i< count - 2 ; i++)
    {
        [self addSubview:[[self subviews] objectAtIndex:index+1]];
    }
    [paintView setFrame:[self bounds]];
    [paintView preparePaintViewWithDataSource:nil toolbox:toolBox type:1];
    [[paintView m_layerDataSource] setM_nLayerOrder:index+1];
   // NSRect viewRect = [paintView frame];
	//NSRect tempRect = [paintView calculateWindowBounds:viewRect];
	//[[paintView window] setFrame:tempRect display:YES animate:YES];
    return  paintView;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    CGContextRef cgContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    [datasource renderToContext:cgContext withFrame:dirtyRect isFocused:YES];

}

-(void)addLayer:(id)layer atIndex:(int)index
{
    
    id aboveLayer = nil;
    
       if (index > 0) 
    {
        aboveLayer = [[self subviews] objectAtIndex:index-1];
    }
    
    if (aboveLayer)
    {
        [self addSubview:layer positioned:NSWindowAbove relativeTo:aboveLayer];
    }
    else
        [self addSubview:layer positioned:NSWindowBelow relativeTo:aboveLayer];
}


- (void)mousedown:(NSEvent*)theEvent
{
    
}

- (void)mouseUp:(NSEvent *)theEvent
{
    
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    
}

- (void)rightMouseDragged:(NSEvent *)theEvent
{
    
}


- (void)setCurLayer:(id)curLayer
{
    m_curLayer = curLayer;
}

- (id)getCurLayer
{
    return m_curLayer;
}

- (SWImageDataSource*)getDatasource
{
    return datasource;
}
@end
