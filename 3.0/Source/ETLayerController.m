//
//  ETLayerController.m
//  Paintbrush
//
//  Created by Pisces Hsu on 12-9-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ETLayerController.h"
#import "SWDocument.h"
#import "SWAppController.h"
#define ETPASTETYPE  @"ETPASTETYPE"
@interface ETLayerController ()

@end



@implementation ETLayerController
extern id g_AppController;
@synthesize  delegate;
@synthesize  m_layerArrayDelegate;
@synthesize m_collectionView;
/*
-(void)awakeFromNib
{
    [m_AddLayer setEnabled:YES];
    [m_DeleteLayer setEnabled:NO];
    [m_MergeLayers setEnabled:NO];
}



- (id)initWithWindowNibName:(NSString *)windowNibName
{
	if ((self = [super initWithWindowNibName:windowNibName])) {		
		// Curiosity...
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowDidBecomeKey:)
                                                     name:NSWindowDidBecomeKeyNotification
                                                   object:nil];
		
        
		// Do some other initialization stuff
        [m_opacityField setStringValue:@"50%"];
	}
	
	return self;
}

*/
+ (id)sharedLayerManagerController
{
	// By calling it static, a second instance of the pointer will never be created
	static ETLayerController *sharedController;
	
	if (!sharedController) {
		sharedController = [[ETLayerController alloc] init];
	}
    
	
	return sharedController;
}
- (id)init
{
	if ((self = [super initWithWindowNibName:@"LayerManager"])) {
	}
 	return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    [m_AddLayer setEnabled:YES];
    [m_DeleteLayer setEnabled:NO];
    [m_MergeLayers setEnabled:NO];
    [m_DeleteAll setEnabled:NO];
    [m_btnDeleteLayer setEnabled:YES]; 
    [m_collectionView addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:nil];
    m_nSelectedLayerOrder = -1;
    [m_collectionView registerForDraggedTypes:[NSArray arrayWithObjects:
                                           ETPASTETYPE, nil]];//注册drag数据类型
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
//    NSLog(@"windowWillReturnUndoManager is called");
    return [delegate undoManager];
}

-(IBAction)addLayer:(id)sender
{
    SWDocument *document = delegate;
    NSIndexSet *selectedIndexes = [m_layerArrayController selectionIndexes];
    int nCount = [[m_layerArrayController arrangedObjects] count];
    NSUInteger nFirstIndex = [selectedIndexes firstIndex];
    int index = nCount-1-nFirstIndex;
    [document addNewLayer:index];   

}

-(IBAction)deleteSelectedLayers:(id)sender
{
    NSArray *seletedItems = [m_layerArrayController selectedObjects];
    NSIndexSet *selectedIndexes = [m_layerArrayController selectionIndexes];
    int nCount = [[m_layerArrayController arrangedObjects] count];
    SWDocument *document = delegate;
    
    NSUInteger nFirstIndex = [selectedIndexes firstIndex];
    
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    
    
    do 
    {
        [indexSet addIndex:nCount-1-nFirstIndex];
        nFirstIndex = [selectedIndexes indexGreaterThanIndex:nFirstIndex];
        
    } while (nFirstIndex!=NSNotFound);
    
    [document deleteLayerInIndexSet:indexSet];
    [m_layerArrayController removeObjects:seletedItems];
    if([[m_layerArrayController arrangedObjects] count] == 1)
    {
        [m_DeleteLayer setEnabled:NO];
        [m_DeleteAll setEnabled:NO];
        [m_btnDeleteLayer setEnabled:NO]; 
    }
    else
    {
        [m_DeleteAll setEnabled:YES];
        [m_DeleteLayer setEnabled:YES];
        [m_btnDeleteLayer setEnabled:YES]; 
    }
  
}

-(IBAction)deleteAllLayersButBackGround:(id)sender
{
    NSMutableArray* objectsArray = [m_layerArrayController arrangedObjects];
    int count = [objectsArray count];
    NSMutableArray* deleteArray = [[NSMutableArray alloc] init];
    int i = 0;
    do {
        [deleteArray addObject:[objectsArray objectAtIndex:i]];
        i++;
    } while (i < count -1);
    
    [m_layerArrayController removeObjects:deleteArray];
    NSMutableIndexSet* indexSet = [[NSMutableIndexSet alloc] init];
    for (i = count-1; i>0; i--)
    {
        [indexSet addIndex:i];
    }
    [delegate deleteLayerInIndexSet:indexSet];
    [m_DeleteAll setEnabled:NO];
    [m_DeleteLayer setEnabled:NO];
    [m_btnDeleteLayer setEnabled:NO]; 
}

-(void)deleteAllLayers
{
    int nCount = [[m_layerArrayController arrangedObjects] count];
    int nIndex = 0;
    for (nIndex=nCount -1; nIndex >= 0; nIndex--)
    {
        id layer = [m_layers objectAtIndex:nIndex];
        [m_layerArrayController removeObject:layer];
    }
    
    
}

-(void)addLayerProps:(ETLayerProperty *)props atIndex:(int)index
{
    ETLayerProperty *layerProps = [props retain];
    int nCount = [[m_layerArrayController arrangedObjects] count];
    int i = nCount-index;
    [m_layerArrayController insertObject:layerProps atArrangedObjectIndex:i];
}

-(void)deleteLayerProp:(ETLayerProperty*)props
{
    [m_layerArrayController removeObject:props];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectionIndexes"]) 
    {
        [g_AppController setLayerMenuState];
        NSIndexSet * selectedIndex = [m_collectionView selectionIndexes];
        int nSelectedCount = [selectedIndex count];
        if(nSelectedCount > 1)
        {
            
            [m_DeleteAll setEnabled:YES];
            [m_AddLayer setEnabled:YES];
            if(nSelectedCount != [m_layerArrayDelegate count])
            {
                [m_DeleteLayer setEnabled:YES];
                [m_btnDeleteLayer setEnabled:YES]; 
            }
            else
            {
                [m_DeleteLayer setEnabled:NO];
                [m_btnDeleteLayer setEnabled:NO]; 
            }
            [m_MergeLayers setEnabled:YES];
        }
        else if(nSelectedCount == 1)
        {
            [m_AddLayer setEnabled:YES];
            if([m_layerArrayDelegate count] != 1)
            {
                [m_DeleteLayer setEnabled:YES];
                [m_DeleteAll setEnabled:YES];
                [m_btnDeleteLayer setEnabled:YES]; 
            }
            else
            {
                [m_DeleteLayer setEnabled:NO];
                [m_DeleteAll setEnabled:NO];
                [m_btnDeleteLayer setEnabled:NO]; 
            }  
            [m_MergeLayers setEnabled:NO];
            
        }
        else if(nSelectedCount < 1)
        {
            [m_AddLayer setEnabled:YES];
            [m_DeleteLayer setEnabled:NO];
            [m_MergeLayers setEnabled:NO];
            [m_btnDeleteLayer setEnabled:NO]; 
            if([m_layerArrayDelegate count] != 1)
            {
                [m_DeleteAll setEnabled:YES];
            }
            else
            {
                [m_DeleteAll setEnabled:NO];
            } 
        }
        if(nSelectedCount == 0)
        {
            return;
        }
           
        if (nSelectedCount == 1) 
        {
            m_nSelectedLayerOrder = [selectedIndex firstIndex];
         
        }
        else if(nSelectedCount > 1)
        {
            m_nSelectedLayerOrder = [selectedIndex lastIndex];
        }
        
        if(m_nSelectedLayerOrder != -1)
        {
            int nCount = [[m_layerArrayController arrangedObjects] count];
            SWDocument *document = delegate;
            [document setCurLayerIndex:nCount-1-m_nSelectedLayerOrder];   
        }
       // NSLog(@"selectionIndexes is called");
        
    }
}

-(IBAction)layerCombine:(id)sender
{
    
    //NSArray *seletedItems = [m_layerArrayController selectedObjects];
    NSIndexSet *selectedIndexes = [m_layerArrayController selectionIndexes];
    int nCount = [[m_layerArrayController arrangedObjects] count];
    //SWDocument *document = delegate;
    NSUInteger nFirstIndex = [selectedIndexes firstIndex];
    //[m_layerArrayController removeObjects:seletedItems];
    NSMutableIndexSet *indexset = [[NSMutableIndexSet alloc] init]; 
    do 
    {
       
        [indexset addIndex:nCount-1-nFirstIndex];
        
        nFirstIndex = [selectedIndexes indexGreaterThanIndex:nFirstIndex];
    } while (nFirstIndex!=NSNotFound);
    [delegate comBineLayers:indexset];
    [indexset release];
}

-(IBAction)alphaValueChanged:(id)sender
{
    //float alphaValue = [m_AlphaSetting floatValue];
    //[delegate setCurLayerAlphaValue:alphaValue];
}

-(NSRect)getWindowRect
{
    return [m_Window frame];
}

//drag执行函数，将需要的内容写入粘贴板
- (BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard
{
    if([indexes count] != 1)
        return NO;
    NSMutableArray *indexArray = [[NSMutableArray array] init];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
     {
         [indexArray addObject:indexes];
     }];
    if ([indexArray count] > 0)
    {
        [pasteboard clearContents];
        [pasteboard declareTypes:[NSArray arrayWithObject:ETPASTETYPE] owner:self];
        dragIndexSet = indexes;
        return [pasteboard setPropertyList:indexArray forType:ETPASTETYPE];//[pasteboard writeObjects:indexArray];
    }
    return NO;
}

//检查函数
- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id < NSDraggingInfo >)draggingInfo proposedIndex:(NSInteger *)proposedDropIndex dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation
{
    if(*proposedDropIndex == -1)
    {
        *proposedDropIndex = 0;
        *proposedDropOperation = NSCollectionViewDropBefore;
         nDropIndex = *proposedDropIndex ;
    }
    
    if (*proposedDropOperation == NSCollectionViewDropOn)
    {
        nDropIndex = *proposedDropIndex ;
		return NSCollectionViewDropBefore;
    }
    
     nDropIndex = *proposedDropIndex ;
    if(nDropIndex == [[m_layerArrayController arrangedObjects] count])
        nDropIndex = [[m_layerArrayController arrangedObjects] count] -1;
    return NSCollectionViewDropBefore;
}

//drop后的执行函数，从粘贴板读入数据
- (BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id < NSDraggingInfo >)draggingInfo index:(NSInteger)index dropOperation:(NSCollectionViewDropOperation)dropOperation
{
    NSPasteboard* pboard = [draggingInfo draggingPasteboard];
    NSArray * array = [[NSArray alloc] init];
    if(collectionView == m_collectionView )
    {
        if ((array = [pboard pasteboardItems]/*propertyListForType:ETPASTETYPE]*/) != NULL)
        {
            NSArray *seletedItems = [m_layerArrayController selectedObjects];
            NSInteger indexChose = [m_layerArrayController selectionIndex];
            int i = 0;
            int count = [seletedItems count];
            [m_layerArrayController removeObjects:seletedItems];
            for (; i < count; i++)
            {
                [m_layerArrayController insertObject:[seletedItems objectAtIndex:i] atArrangedObjectIndex:nDropIndex];
            }
            [delegate dragAndDrop: ([[m_layerArrayController arrangedObjects] count] - indexChose -1) dropIndex:([[m_layerArrayController arrangedObjects] count] - nDropIndex -1)];
            
            
            return YES;
        }
    }
    return NO;
}
- (NSInteger)getSelectedIndex
{
    return [m_layerArrayController selectionIndex];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [m_Window orderOut:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LayerMenuItemSetState" object:nil];
    
    
}

-(void)EnableAdd_DeleteLayerBtn:(BOOL)bEnable
{
    //[m_addLayer setEnabled:bEnable];
    [m_btnDeleteLayer setEnabled:bEnable];
}

-(void)setAddBtnState:(BOOL)state
{
    [m_addLayer setEnabled:state];
}

-(NSCollectionView *)getCollectionView;
{
    return m_collectionView;
}
@end
