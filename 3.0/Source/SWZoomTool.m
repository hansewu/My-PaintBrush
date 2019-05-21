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


#import "SWZoomTool.h"
#import "SWPaintView.h"
#import "SWDocument.h"
#import "SWScalingScrollView.h"

@implementation SWZoomTool

- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSBitmapImageRep *)mainImage 
						 bufferImage:(NSBitmapImageRep *)bufferImage 
						  mouseEvent:(SWMouseEvent)event atLayer:(id)layer
{ 
	// Only zoom on a down-click
	if (event == MOUSE_DOWN) 
	{
		savedPoint = point;
        if (document /*&& [document isKindOfClass:[SWDocument class]]*/) 
		{
			// Were they zooming in or out?
			if (flags & NSAlternateKeyMask)
				[document zoomOut:self];
			else
				[document zoomIn:self];
		}
    }
    else if(event == MOUSE_DRAGGED)
    {
		//NSDocumentController *controller = [NSDocumentController sharedDocumentController];
		//id document = [controller documentForWindow: [NSApp mainWindow]];
		
		// If it's a Paintbrush document, get its PaintView
		if (document /*&& [document isKindOfClass:[SWDocument class]]*/) 
		{
			// Were they zooming in or out?
			//if (flags & NSAlternateKeyMask)
            //{
            //if(point.x - savedPoint.x < 0)
            if([[document getCurLayer] _deltaX] < -1.0)      
                [document zoomOut:self];
            //}   
			//else
            //if(point.x - savedPoint.x > 0)
            else if([[document getCurLayer] _deltaX] > 1.0) 
                [document zoomIn:self];
            //savedPoint = point;
		}
	}
	return nil;
}

- (NSCursor *)cursor
{
	if(flags & NSAlternateKeyMask)
    {
        //[customCursor release];
        if(!customCursor)
        {
            NSImage *customImage;
            customImage = [NSImage imageNamed:@"zoom-cursor01.png"];
            customCursor = [[NSCursor alloc] initWithImage:customImage hotSpot:NSMakePoint(1,15)];
        }
        return customCursor;
    }
    else
    {
        //[customCursor release];
        if(!customCursorAlt)  
        {
            NSImage *customImage;
            customImage = [NSImage imageNamed:@"zoom-cursor02.png"];
            customCursorAlt = [[NSCursor alloc] initWithImage:customImage hotSpot:NSMakePoint(1,15)];
            
        }
        return customCursorAlt;
    }

}

- (NSString *)description
{
	return @"Zoom";
}

@end
