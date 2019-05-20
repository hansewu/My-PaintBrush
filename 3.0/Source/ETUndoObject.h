//
//  ETUndoObject.h
//  Paintbrush
//
//  Created by Chin ping Hsu on 12/10/12.
//
//

#import <Foundation/Foundation.h>

typedef enum
{
    None,
    Drawing,
    Add_Layer,
    Delete_Layer,
    Combine_Layer,
    Splite_Layer
}UNDO_TYPE;

@interface ETUndoObject : NSObject
{
    UNDO_TYPE m_nUndoType;
    id m_para1;
    id m_para2;
}
@property UNDO_TYPE m_nUndoType;
@property (retain)id m_para1;
@property (retain)id m_para2;

@end
