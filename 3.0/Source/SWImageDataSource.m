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


#import "SWImageDataSource.h"
#import "SWToolboxController.h"
#import "SWEditor.h"


@implementation SWImageDataSource

// -----------------------------------------------------------------------------
//  Initializers
// -----------------------------------------------------------------------------


// Common initializer
- (id)initWithSize:(NSSize)sizeIn backGroundColor:(NSColor*)bgColor
{
	self = [super init];
	if (self)
	{
		// Save the size
		size = sizeIn;
		
		// Create the two images we'll be using
		[SWImageTools initImageRep:&mainImage withSize:size];
		[SWImageTools initImageRep:&bufferImage withSize:size];
		
		// New Image: gotta paint the background color
		SWLockFocus(mainImage);
		
		//NSColor *bgColor = [[SWToolboxController sharedToolboxPanelController] backgroundColor];
		[bgColor setFill];

		NSRect newRect = (NSRect) { NSZeroPoint, sizeIn };
		NSRectFill(newRect);
		
		SWUnlockFocus(mainImage);
		
		// Create the editors stack
		editors = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithSize:(NSSize)sizeIn
{
	self = [super init];
	if (self)
	{
		// Save the size
		size = sizeIn;
		
		// Create the two images we'll be using
		[SWImageTools initImageRep:&mainImage withSize:size];
		[SWImageTools initImageRep:&bufferImage withSize:size];
		
		// New Image: gotta paint the background color
		SWLockFocus(mainImage);
		
		NSColor *bgColor = [[SWToolboxController sharedToolboxPanelController] backgroundColor];
		[bgColor setFill];
        
		NSRect newRect = (NSRect) { NSZeroPoint, sizeIn };
		NSRectFill(newRect);
		
		SWUnlockFocus(mainImage);
		
		// Create the editors stack
		editors = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url
{
	// Temporary image to get dimensions
	NSBitmapImageRep *tempImage = [NSBitmapImageRep imageRepWithContentsOfURL:url];
	
	if (!tempImage)	// failure case
		return nil;
	
	// Run baseline initializer
	[self initWithSize:NSMakeSize([tempImage pixelsWide], [tempImage pixelsHigh])];
	
	// Copy the image to the mainImage
	[SWImageTools drawToImage:mainImage fromImage:tempImage withComposition:NO];
	
	// Flip it, since our views are all flipped
	if (mainImage)
		[SWImageTools flipImageVertical:mainImage];		
	
	return self;
}
- (id)initWithFile:(NSString *)fileName
{
	// Temporary image to get dimensions
	NSBitmapImageRep *tempImage = [NSBitmapImageRep imageRepWithContentsOfFile:fileName];
	
	if (!tempImage)	// failure case
		return nil;
	
	// Run baseline initializer
	//[self initWithSize:NSMakeSize([tempImage pixelsWide], [tempImage pixelsHigh])];
	
	// Copy the image to the mainImage
	[SWImageTools drawToImage:mainImage fromImage:tempImage withComposition:NO];
	
	// Flip it, since our views are all flipped
	if (mainImage)
		[SWImageTools flipImageVertical:mainImage];		
	
	return self;
}

- (id)initWithPasteboard
{
	NSBitmapImageRep *tempImage = [NSBitmapImageRep imageRepWithPasteboard:[NSPasteboard generalPasteboard]];
	
	NSAssert(tempImage, @"We can't initialize with a pasteboard without an image on it!");
	if (!tempImage)	// failure case
		return nil;
	
	// Run baseline initializer
	[self initWithSize:NSMakeSize([tempImage pixelsWide], [tempImage pixelsHigh])];

	// Copy the image to the mainImage
	[SWImageTools drawToImage:mainImage fromImage:tempImage withComposition:NO];
	
	// Flip it, since our views are all flipped
	if (mainImage)
		[SWImageTools flipImageVertical:mainImage];
	
	return self;
}


- (void)dealloc
{
	// Clean up a bit after ourselves
	[mainImage release];
	[bufferImage release];
	[editors release];
	
	[super dealloc];
}


// -----------------------------------------------------------------------------
//  Mutators
// -----------------------------------------------------------------------------

- (void)resizeToSize:(NSSize)newSize
		  scaleImage:(BOOL)shouldScale;
{
	// We'll be replacing the two images behind the scenes
	NSBitmapImageRep *newMainImage = nil;
	NSBitmapImageRep *newBufferImage = nil;
	[SWImageTools initImageRep:&newMainImage 
					  withSize:newSize];
	[SWImageTools initImageRep:&newBufferImage
					  withSize:newSize];
	
	NSRect newRect = (NSRect) { NSZeroPoint, newSize };
	SWLockFocus(newMainImage);
	if (shouldScale) 
	{
		// Stretch the image to the correct size
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
		[mainImage drawInRect:newRect];
	}
	else 
	{
		NSColor *bgColor = [NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:0];
		[bgColor setFill];
		NSRectFill(newRect);
		[mainImage drawAtPoint:NSZeroPoint];
	}
	SWUnlockFocus(newMainImage);
	
	// Release and set (no need to retain: we already own the new images)
	[mainImage release];
	[bufferImage release];
	mainImage = newMainImage;
	bufferImage = newBufferImage;
	
	// Finally, update our cached size
	size = newSize;
}
- (void)resizeToSize:(NSSize)newSize
{
    NSBitmapImageRep *newMainImage = nil;
	NSBitmapImageRep *newBufferImage = nil;
	[SWImageTools initImageRep:&newMainImage 
					  withSize:newSize];
	[SWImageTools initImageRep:&newBufferImage
					  withSize:newSize];
	
	NSRect newRect = (NSRect) { NSZeroPoint, newSize };
	SWLockFocus(newMainImage);
	
		NSColor *bgColor = [NSColor whiteColor];
		[bgColor setFill];
		NSRectFill(newRect);
		[mainImage drawAtPoint:NSZeroPoint];
	SWUnlockFocus(newMainImage);
	
	// Release and set (no need to retain: we already own the new images)
	[mainImage release];
	[bufferImage release];
	mainImage = newMainImage;
	bufferImage = newBufferImage;
	
	// Finally, update our cached size
	size = newSize;

}

// -----------------------------------------------------------------------------
//  Accessors
// -----------------------------------------------------------------------------

@synthesize size;
@synthesize mainImage;
@synthesize bufferImage;


// -----------------------------------------------------------------------------
//  Accessors
// -----------------------------------------------------------------------------

- (NSArray *)editors
{
	return [NSArray arrayWithArray:editors];
}


- (void)pushEditor:(id <SWEditor>)editor
{
	NSAssert(![editors containsObject:editor], @"Can't an editor that's already on the stack!");
	[editors insertObject:editor atIndex:0];
}


- (void)removeEditor:(id <SWEditor>)editor
{
	NSAssert([editors containsObject:editor], @"Can't remove an editor that isn't on the stack!");
	[editors removeObject:editor];
}


// -----------------------------------------------------------------------------
//  Drawing
// -----------------------------------------------------------------------------

- (void)renderToContext:(CGContextRef)context withFrame:(NSRect)frame isFocused:(BOOL)isFocused
{
	//CGContextBeginTransparencyLayer(cgContext, NULL);
	[NSGraphicsContext saveGraphicsState];

	if (!isFocused)
		[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO]];
		
	// If you don't do this, the image looks blurry when zoomed in
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
	
	// Draw the NSBitmapImageRep to the view
	if (mainImage) 
		CGContextDrawImage(context, NSRectToCGRect((NSRect){
			NSZeroPoint, [mainImage size]
		}), [mainImage CGImage]);
	
	// If there's an overlay image being used at the moment, draw it
	if (bufferImage) 
	{
		NSRect rect = (NSRect){ NSZeroPoint, [bufferImage size] };
		CGContextDrawImage(context, NSRectToCGRect(rect), [bufferImage CGImage]);
	}
	
	// TODO: iterate through our editors and let each one render its stuff
	for (id <SWEditor> editor in editors)
	{
		NSAssert([editor conformsToProtocol:@protocol(SWEditor)], @"We have an editor that isn't an editor...?");
		[editor renderToContext:context withFrame:frame];
	}
	//CGContextRotateCTM((CGContextRef)[[NSGraphicsContext currentContext] graphicsPort],M_PI*60/180);
	[NSGraphicsContext restoreGraphicsState];
}


// -----------------------------------------------------------------------------
//  Data
// -----------------------------------------------------------------------------

- (NSData *)copyMainImageData
{
	if (mainImage)
		return [mainImage TIFFRepresentation];
	
	// No image, no data
	return nil;
}


- (void)restoreMainImageFromData:(NSData *)tiffData
{
	if (!tiffData)
		return;
	
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:tiffData];
	[SWImageTools drawToImage:mainImage fromImage:imageRep withComposition:NO];
	[imageRep release];
}


- (void)restoreBufferImageFromData:(NSData *)tiffData
{
	if (!tiffData)
		return;
	
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:tiffData];
	
	// Unlike the main image, the buffer image can have its size change.  Do that here.
	NSRect bufferImageRect = NSMakeRect(0, 0, [bufferImage pixelsWide], [bufferImage pixelsHigh]);
	NSRect pastedImageRect = NSMakeRect(0, 0, [imageRep pixelsWide], [imageRep pixelsHigh]);
	NSRect finalRect = NSUnionRect(bufferImageRect, pastedImageRect);
	
	if (!NSEqualRects(bufferImageRect, finalRect))
	{
		// Pasting something bigger than the previous image, so create a new one with the new size
		[bufferImage release];
		bufferImage = nil;
		
		[SWImageTools initImageRep:&bufferImage withSize:finalRect.size];
	}
	
	[SWImageTools drawToImage:bufferImage fromImage:imageRep withComposition:NO];
	[imageRep release];
}


@end
