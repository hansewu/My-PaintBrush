//
//  ETMove&ResizeTool.m
//  Paintbrush
//
//  Created by Pisces Hsu on 12-9-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ETMove&ResizeTool.h"

@implementation ETMove_ResizeTool

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
	return @"Move&Resize";
}

@end
