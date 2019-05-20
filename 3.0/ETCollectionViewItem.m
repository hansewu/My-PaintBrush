//
//  ETCollectionViewItem.m
//  Paintbrush
//
//  Created by mac on 12-9-26.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ETCollectionViewItem.h"


@implementation ETCollectionViewItem
@synthesize  delegate;
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



-(IBAction)alphaValueChanged:(id)sender
{
    //float alphaValue = [m_AlphaSetting floatValue];
    //NSString* aphString = [[NSString alloc] initWithFormat:@"%f",alphaValue];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending UpDevice notification");
    [nc postNotificationName:@"ALPHA_CHANGED" object:nil];
}

-(IBAction)checkBoxValueChange:(id)sender
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending UpDevice notification");
    [nc postNotificationName:@"CHECKBOX_CHANGED" object:nil];
}

@end
