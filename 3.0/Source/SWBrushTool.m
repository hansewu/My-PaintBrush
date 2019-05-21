/**
 * Copyright 2007-2010 Soggy Waffles. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 * 
 *    1. Redistributions of source code must retain the above copyright notice, this list of
 *       conditions and the following disclaimer.
 * 
 *    2. Redistributions in binary form must reproduce the above copyright notice, this list
 *       of conditions and the following disclaimer in the documentation and/or other materials
 *       provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY SOGGY WAFFLES ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL SOGGY WAFFLES OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The views and conclusions contained in the software and documentation are those of the
 * authors and should not be interpreted as representing official policies, either expressed
 * or implied, of Soggy Waffles.
 */


#import "SWBrushTool.h"
#import "SWDocument.h"

@implementation SWBrushTool

// Generates the path to be drawn to the image
- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	if (!path)
	{  
    
    path = [[NSBezierPath bezierPath]  retain];
    [path setLineCapStyle:NSRoundLineCapStyle];
    [path setLineJoinStyle:NSRoundLineJoinStyle];
    }
    [path setLineWidth:lineWidth];	
	begin.x += 0.5;
	begin.y += 0.5;
	end.x += 0.5;
	end.y += 0.5;
	[path moveToPoint:begin];
	[path lineToPoint:end];
    //[path appendBezierPathWithRect:NSMakeRect(begin.x,begin.y,0.1,0.1)];
    //[path stroke];
    //[path release];

	return path;
}

- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSBitmapImageRep *)mainImage 
						 bufferImage:(NSBitmapImageRep *)bufferImage 
						  mouseEvent:(SWMouseEvent)event atLayer:(id)layer
{
    [[NSGraphicsContext currentContext] setShouldAntialias:YES]; 
	// Use the points clicked to build a redraw rectangle 	
    [super addRedrawRectFromPoint:point toPoint:savedPoint];
	
	if (event == MOUSE_UP) 
	{
		[layer handleUndoWithImageData:nil frame:NSZeroRect];
		[SWImageTools drawToImage:mainImage fromImage:bufferImage withComposition:YES];
		[SWImageTools clearImage:bufferImage];
		[path release];
        path = nil;
        m_MouseDown = NO;
    } 
	else 
	{		
        if(event == MOUSE_DOWN)
            m_MouseDown = YES;
        if(!m_MouseDown)
            return nil;
		SWLockFocus(bufferImage);
		
		// The best way I can come up with to clear the image
		[SWImageTools clearImage:bufferImage];
		
		//[[NSGraphicsContext currentContext] setShouldAntialias:YES];
		//[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeCopy];
		if (flags & NSAlternateKeyMask)
			[backColor setStroke];	
		else
			[frontColor setStroke];
		[[self pathFromPoint:savedPoint toPoint:point ] stroke];
		savedPoint = point;
		
		SWUnlockFocus(bufferImage);
	}
	return nil;
}

- (NSCursor *)cursor
{
	if (!customCursor) {
		NSImage *customImage = [NSImage imageNamed:@"brush-cursor.png"];
		customCursor = [[NSCursor alloc] initWithImage:customImage hotSpot:NSMakePoint(1,14)];
	}
	return customCursor;
}

- (NSString *)description
{
	return @"Brush";
}

@end
