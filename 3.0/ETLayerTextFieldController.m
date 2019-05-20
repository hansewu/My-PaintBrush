//
//  ETLayerTextFieldController.m
//  Paintbrush
//
//  Created by mac on 12-10-8.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ETLayerTextFieldController.h"


@implementation ETLayerTextFieldController

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

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
   // [super mouseUp:theEvent];
   // [super mouseDown:theEvent];
   // [super mouseUp:theEvent];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    [super mouseMoved:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:theEvent];
}

- (void)textDidChange:(NSNotification *)aNotification
{
    
}

@end
