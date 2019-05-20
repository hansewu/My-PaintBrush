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


#import <Cocoa/Cocoa.h>
#import "SWEditor.h"


@interface SWImageDataSource : NSObject 
{
	NSBitmapImageRep *mainImage;	// The main storage image
	NSBitmapImageRep *bufferImage;	// The buffer drawn to for temporary actions
	
	NSSize size;					// Cached size
	
	NSMutableArray *editors;		// Stack of SWEditors
}

// Initializers
- (id)initWithSize:(NSSize)size backGroundColor:(NSColor*)bgColor;
- (id)initWithSize:(NSSize)size;
- (id)initWithURL:(NSURL *)url;
- (id)initWithPasteboard;
- (id)initWithFile:(NSString *)fileName;
// Modifiers to the image
- (void)resizeToSize:(NSSize)size
		  scaleImage:(BOOL)shouldScale;
- (void)resizeToSize:(NSSize)newSize;
// Need to change the image?  We got your back -- here be datas
- (NSData *)copyMainImageData;
- (void)restoreMainImageFromData:(NSData *)tiffData;
- (void)restoreBufferImageFromData:(NSData *)tiffData; // For pasting

// Editors
- (NSArray *)editors;
- (void)pushEditor:(id <SWEditor>)editor;
- (void)removeEditor:(id <SWEditor>)editor;

// For drawing
- (void)renderToContext:(CGContextRef)context withFrame:(NSRect)frame isFocused:(BOOL)isFocused;

// Accessing information about the image source
@property (readonly) NSSize size;
@property (readonly) NSBitmapImageRep *mainImage;
@property (readonly) NSBitmapImageRep *bufferImage;

@end
