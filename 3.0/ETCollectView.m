//
//  collectView.m
//  Paintbrush
//
//  Created by mac on 12-9-24.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ETCollectView.h"


@implementation ETCollectView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


+ (void)setDele:(id)delegate
{
    self = delegate;
}

-(void)rightMouseUp:(NSEvent *)theEvent
{
    [self rightMouseDown:theEvent];
}
@end
