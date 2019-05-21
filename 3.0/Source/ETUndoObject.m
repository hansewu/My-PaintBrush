//
//  ETUndoObject.m
//  Paintbrush
//
//  Created by Chin ping Hsu on 12/10/12.
//
//

#import "ETUndoObject.h"

@implementation ETUndoObject
@synthesize  m_nUndoType;
@synthesize m_para1;
@synthesize m_para2;

- (id)init
{
    self = [super init];
    if (self)
    {
        m_nUndoType = None;
        m_para1 = nil;
        m_para1 = nil;
        
    }
    return self;
}

- (void)dealloc
{
    if (m_para1)
    {
        [m_para1 release];
    }
    if (m_para2)
    {
        [m_para2 release];
    }
    [super dealloc];
}

@end
