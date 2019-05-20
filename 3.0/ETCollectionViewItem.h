//
//  ETCollectionViewItem.h
//  Paintbrush
//
//  Created by mac on 12-9-26.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ETCollectionViewItem : NSCollectionViewItem {
    IBOutlet NSSlider* m_AlphaSetting;
    id delegate;
    
}
@property (retain) id delegate;
-(IBAction)alphaValueChanged:(id)sender;
@end
