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


#import "SWRectangleTool.h"
#import "SWDocument.h"

@implementation SWRectangleTool

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	path = [NSBezierPath bezierPath];
	[path setLineWidth:lineWidth];
	[path setLineCapStyle:NSSquareLineCapStyle];
	[path moveToPoint:begin];
	if (lineWidth <= 1) 
	{
		begin.x += 0.5;
		begin.y += 0.5;
		end.x += 0.5;
		end.y += 0.5;
	}
	if (flags & NSShiftKeyMask) {
		CGFloat size = fmin(abs(end.x-begin.x),abs(end.y-begin.y));
		NSInteger x = (end.x-begin.x) / abs(end.x-begin.x);
		NSInteger y = (end.y-begin.y) / abs(end.y-begin.y);
		[path appendBezierPathWithRect:NSMakeRect(begin.x, begin.y, x*size, y*size)];
	} else {
		[path appendBezierPathWithRect:NSMakeRect(begin.x, begin.y, (end.x - begin.x), (end.y - begin.y))];
	}
	
	return path;	
}

- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSBitmapImageRep *)mainImage 
						 bufferImage:(NSBitmapImageRep *)bufferImage 
						  mouseEvent:(SWMouseEvent)event atLayer:(id)layer
{
	// Use the points clicked to build a redraw rectangle
	[super addRedrawRectFromPoint:savedPoint toPoint:point];
	
	[SWImageTools clearImage:bufferImage];
	
	if (event == MOUSE_UP)
	{
		[layer handleUndoWithImageData:nil frame:NSZeroRect];
		drawToMe = mainImage;	
	}
	else
		drawToMe = bufferImage;
	
	SWLockFocus(drawToMe); 
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	
	// Which colors should we draw with?
	if (event == MOUSE_DOWN) {
		if (flags & NSAlternateKeyMask) {
			primaryColor = backColor;
			secondaryColor = frontColor;
		} else {
			primaryColor = frontColor;
			secondaryColor = backColor;
		}
	}
	
	[self pathFromPoint:savedPoint toPoint:point];
	if (shouldFill && shouldStroke)//绘制矩形，同时填充内部用第二颜色
	{
		[primaryColor setStroke];
		[secondaryColor setFill];
		[path fill];
		[path stroke];
	}
	else if (shouldFill) //填充所绘制的矩形
	{
		[primaryColor setFill];
		[path fill];
	}
	else if (shouldStroke) //绘制矩形
	{
		[primaryColor setStroke];
		[path stroke];
	}
	
	SWUnlockFocus(drawToMe);
	return nil;
}

- (NSCursor *)cursor
{
	if (!customCursor) {
		customCursor = [[NSCursor crosshairCursor] retain];
	}
	return customCursor;
}

- (BOOL)shouldShowFillOptions
{
	return YES;
}

- (NSString *)description
{
	return @"Rectangle";
}

@end
