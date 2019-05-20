//
//  ETLayerManagerPanel.m
//  Paintbrush
//
//  Created by Chin ping Hsu on 11/24/12.
//
//

#import "ETLayerManagerPanel.h"

@implementation ETLayerManagerPanel
-(BOOL)canBecomeKeyWindow
{
    NSDocumentController *dc = [NSDocumentController sharedDocumentController];
    int nDocCount = [[dc documents] count];
    if (nDocCount) //控制层名字textfield的可编辑状态
    {
        return YES;
    }
    else
        return NO;
}

@end
