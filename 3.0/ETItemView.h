//
//  ETItemView.h
//  Paintbrush
//
//  Created by  on 13-1-7.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//



@interface ETItemView : NSView
{
    IBOutlet NSTextField* itemTextField; 
}

- (NSTextField*)getTextField;
@end
