//
//  FilelistBgImageTransformer.m
//  Total Video Converter For Mac
//
//  Created by apple on 12-2-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FilelistBgImageTransformer.h"


@implementation FilelistBgImageTransformer


+ (Class)transformedValueClass 
{ 
    return [NSImage class]; 
}

+ (BOOL)allowsReverseTransformation 
{ 
    return YES; 
}

- (id)transformedValue:(id)value 
{
	
	BOOL _isWorking = [value boolValue];
    
	if(_isWorking){
		return [NSImage imageNamed:@"layer_bg_active.png"];
	}else{
		return [NSImage imageNamed:@"layer_bg.png"];
	}
	
	return nil;
}

@end
