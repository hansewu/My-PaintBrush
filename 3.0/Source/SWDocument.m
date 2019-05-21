/**
 * Copyright 2007-2010 Soggy Waffles. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 * 
 *    1. Redistributions of source code must retain the above copyright notice, this list of
 *       conditions and the following disclaimer.
 * 
 *    2. Redistributions in binary form must reproduce the above copyright notice, this list
 *       of conditions and the following disclaimer in the documentation and/or other materials
 *       provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY SOGGY WAFFLES ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL SOGGY WAFFLES OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The views and conclusions contained in the software and documentation are those of the
 * authors and should not be interpreted as representing official policies, either expressed
 * or implied, of Soggy Waffles.
 */


#import "SWDocument.h"
#import "SWPaintView.h"
#import "SWScalingScrollView.h"
#import "SWCenteringClipView.h"
#import "SWToolbox.h"
#import "SWToolboxController.h"
#import "SWTextToolWindowController.h"
#import "SWSizeWindowController.h"
#import "SWResizeWindowController.h"
#import "SWToolList.h"
#import "SWAppController.h"
#import "SWSavePanelAccessoryViewController.h"
#import "SWPrintPanelAccessoryViewController.h"
#import "SWImageDataSource.h"
#import "ETBackGroundView.h"
#import "ETCollectionViewItem.h"
#import "ETItemView.h"
@implementation SWDocument
@synthesize toolbox;
@synthesize m_strProjectPath;
@synthesize m_bPasting;
@synthesize hasInsertedPc;
extern id g_AppController;

static BOOL kSWDocumentWillShowSheet = YES;

- (id)init
{
    if ((self = [super init])) 
	{			
        hasInsertedPc = NO;
        timer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                 target: self
                                               selector: @selector(handleTimer:)
                                               userInfo: nil
                                                repeats: YES];
		// Observers for the toolbox
		nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(showTextSheet:)
				   name:@"SWText"
				 object:nil];
		[nc addObserver:self 
			   selector:@selector(undoLevelChanged:) 
				   name:kSWUndoKey 
				 object:nil];
		[nc addObserver:self 
               selector:@selector(setAlphaValue:) 
                   name:@"ALPHA_CHANGED" 
                 object:nil];
        [nc addObserver:self 
               selector:@selector(setLayerChecked:) 
                   name:@"CHECKBOX_CHANGED" 
                 object:nil];
        
        
		NSNumber *undo = [[NSUserDefaults standardUserDefaults] objectForKey:kSWUndoKey];
		[[self undoManager] setLevelsOfUndo:[undo integerValue]];
		
		toolbox = [[SWToolbox alloc] initWithDocument:self];
        m_bPasting = NO;
		
	}
    return self;
}


- (void)dealloc
{	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[sizeController release];
	[clipView release];
	[currentFileType release];
	[textController release];
	[savePanelAccessoryViewController removeObserver:self forKeyPath:kSWCurrentFileType];
	[savePanelAccessoryViewController release];
	[toolbox release];
	[dataSource release];
	[super dealloc];
}

- (void)openAfter
{   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (backgroundView)
    {
        [backgroundView release];
        backgroundView = nil;
    }

    if(sizeController != nil)
    {
        [sizeController release];
        sizeController = nil;
    }
    if(clipView != nil)
    {
        [clipView release];
        clipView = nil;
    }
    if(currentFileType != nil)
    {
        [currentFileType release];
        currentFileType = nil;
    }
    if(textController != nil)
    {
        [textController release];
        textController = nil;
    }
    if(toolbox != nil)
    {
        [toolbox release];
        toolbox = nil;
    }
    if(dataSource != nil)
    {
        [dataSource release];
        dataSource = nil;
    }
    int nCount = 0;
    int i = 0;
    if ([m_RedoOperationArray count])
    {
        [self clearRepeatedObjForMutArray:m_RedoOperationArray];
        for (i = 0; i<[m_RedoOperationArray count]; i++)
        {
            ETUndoObject * undoOpe = [m_RedoOperationArray objectAtIndex:i];
            [m_RedoOperationArray removeObject:undoOpe];
            if (![m_UndoOperationArray containsObject:undoOpe])
            {
                [self releaseUndoOperation:undoOpe];
                i--;
            }
            
        }
    }
    
    if (m_UndoOperationArray)
    {
        [self clearRepeatedObjForMutArray:m_UndoOperationArray];
        
        for (i = 0; i<[m_UndoOperationArray count]; i++)
        {
            id undoOpe = [m_UndoOperationArray objectAtIndex:i ];
            [m_UndoOperationArray removeObjectAtIndex:i];
            [self releaseUndoOperation:undoOpe];
            
            i--;
            
        }
        [m_UndoOperationArray removeAllObjects];
        [m_UndoOperationArray release];
        m_UndoOperationArray = nil;
        
    }
    [m_RedoOperationArray removeAllObjects];
    [m_RedoOperationArray release];
    m_RedoOperationArray = nil;
    
    
    if(m_layerArray != nil)
    {
        nCount = [m_layerArray count];
        //    int j = 0;
        for (i=0;  i < nCount; i++)
        {
            
            [[m_layerArray objectAtIndex:i] release];
        }
        [m_layerArray removeAllObjects];
        [m_layerArray release];
        m_layerArray = nil;
    }
    
    if(insertView != nil)
    {
        [insertView release];
        insertView = nil;
    }
}


-(void)close
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
    int count = [[[m_layerController getCollectionView] subviews] count];
    int counter = 0;

    for( ;counter<count;counter++)
    {
        [[[[[[m_layerController getCollectionView] subviews] objectAtIndex:counter] subviews] objectAtIndex:2] setEditable:NO];
    }
    NSUndoManager *undoManager = [self undoManager];
    [undoManager removeAllActions];
    if(timer2 != nil)
    {
        [timer2 invalidate];
        timer2 = nil;
    }
    if(timer != nil)
    {
        [timer invalidate];
        timer = nil;
    }
    
     if(m_layerController != nil)
    {
        [m_layerController deleteAllLayers];
    } 
    [m_layerController EnableAdd_DeleteLayerBtn:NO];
    [m_layerController setAddBtnState:NO];
    [self openAfter];
    [[NSColorPanel sharedColorPanel] close];
    NSNotificationCenter *noti = [NSNotificationCenter defaultCenter];
    [noti postNotificationName:@"Closed" object:nil];
    [super close];
    if([g_AppController isOpen])
    {
        [g_AppController setIDocControll:0];
        [noti postNotificationName:@"Closed" object:nil];
        
    }
    if([g_AppController isOpenRecent])
    {
        [g_AppController _openRecent];
    }
    
}


- (NSString *)windowNibName
{
    return @"MyDocument";
}


- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{

    m_bSetLayerImage = YES;
    [super windowControllerDidLoadNib:aController];
    m_layerArray = [[NSMutableArray alloc] init];
   [[NSApplication sharedApplication] mainWindow] ;
    m_UndoOperationArray = [[NSMutableArray alloc] init];
    m_RedoOperationArray = [[NSMutableArray alloc] init];
    

    
    m_nTotalLayerCount = 0;
	if (!sizeController)
		sizeController = [[SWSizeWindowController alloc] initWithWindowNibName:@"SizeWindow"];
	
	if (!resizeController)
		resizeController = [[SWResizeWindowController alloc] initWithWindowNibName:@"ResizePanel"];

	toolboxController = [SWToolboxController sharedToolboxPanelController];
	
	clipView = [[SWCenteringClipView alloc] initWithFrame:[[scrollView contentView] frame]];
	backgroundView = [[ETBackGroundView alloc] init];
	[scrollView setContentView:(NSClipView *)clipView];
	[clipView setDocumentView:backgroundView];
	[scrollView setScaleFactor:1.0 adjustPopup:YES];

	NSImage *bgImage = [NSImage imageNamed:@"bgImage"];
	if (bgImage)
		[clipView setBgImagePattern:bgImage];
		
	if (dataSource && ([m_proInfoArray count] == 0)) 
    {
        [self setUpBackGroundView:[dataSource size]];
        [self setUpFirstPaintView];
    }
	else if([m_proInfoArray count] == 0)
	{
		if (kSWDocumentWillShowSheet) 
		{
			[[aController window] orderFront:self];
            [[NSColorPanel sharedColorPanel] close];
			[self raiseSizeSheet:aController];
		}
		else 
		{
			[SWDocument setWillShowSheet:YES];
			dataSource = [[SWImageDataSource alloc] initWithPasteboard];
		
		}
	}
	
    m_layerController = [ETLayerController sharedLayerManagerController];
    [m_layerController setDelegate:self];
    [m_layerController setM_layerArrayDelegate:m_layerArray];
    
    if ([m_proInfoArray count]) 
    { 
        
        NSSize proSize;
        proSize.height = [[[m_proInfoArray objectAtIndex:0] valueForKey:ETPB_Height] floatValue];
        proSize.width = [[[m_proInfoArray objectAtIndex:0] valueForKey:ETPB_Width] floatValue];
        NSString* versionString = [[NSString alloc] initWithFormat:@"%@",[[m_proInfoArray objectAtIndex:0] valueForKey:ETPB_Version]] ;
        [self setUpBackGroundView:proSize];
        
        [backgroundView setFrame:NSMakeRect(0, 0, proSize.width, proSize.height)];
        [[backgroundView getDatasource] resizeToSize:proSize];
        int count = [m_proInfoArray count]-1;
        int i=0;
        m_nCurLayeIndex = -1;
        for(i = 0; i < count ;i++)
        {
            [self addNewLayer:m_nCurLayeIndex];
            NSString *layerFile = nil;
            NSString *layerFileName = [[m_proInfoArray objectAtIndex:i+1] objectForKey:ETPB_LAYER_FILE];
            if ([layerFileName rangeOfString:@"/"].length > 0) 
            {
                layerFile = layerFileName;
            }
            else 
            {
                if([versionString  isEqualToString:Version])
                    layerFile = [[NSString alloc] initWithFormat:@"%@/%@.png", m_strProjectPath, [[m_proInfoArray objectAtIndex:i+1] objectForKey:ETPB_LAYER_Order]];
                else
                    layerFile = [[NSString alloc] initWithFormat:@"%@/%@.png", m_strProjectPath, [[m_proInfoArray objectAtIndex:i+1] objectForKey:ETPB_LAYER_Name]];
            }

            //NSLog(@"%@", layerFile);
            [[[m_layerArray objectAtIndex:i] m_layerProp] setM_strLayerName:[[m_proInfoArray objectAtIndex:i+1] objectForKey:ETPB_LAYER_Name]];
            [[[m_layerArray objectAtIndex:i] getDatasource] initWithFile:layerFile];
            [[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] setValue:[[m_proInfoArray objectAtIndex:i+1] objectForKey:ETPB_LAYER_ID] forKey:ETPB_LAYER_ID];
            [[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] setValue:[[m_proInfoArray objectAtIndex:i+1] objectForKey:ETPB_LAYER_Name] forKey:ETPB_LAYER_Name];
            [[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] setValue:[[m_proInfoArray objectAtIndex:i+1] objectForKey:ETPB_LAYER_Order] forKey:ETPB_LAYER_Order];
            [[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] setValue:[[m_proInfoArray objectAtIndex:i+1] objectForKey:ETPB_LAYER_Alpha] forKey:ETPB_LAYER_Alpha];
            
            [[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] setValue:[[m_proInfoArray objectAtIndex:i+1] objectForKey:ETPB_LAYER_bVisible] forKey:ETPB_LAYER_bVisible];
            if([[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] valueForKey:ETPB_LAYER_bVisible] boolValue])
            {
                [[m_layerArray objectAtIndex:i] setAlphaValue:[[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] objectForKey:ETPB_LAYER_Alpha] floatValue]/255.0];
                [[[m_layerArray objectAtIndex:i] m_layerProp] setM_fAlpha:[[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] objectForKey:ETPB_LAYER_Alpha] floatValue]/255.0];
                [[[m_layerArray objectAtIndex:i] m_layerProp] setM_bChecked:YES];
            }
            else {
                [[m_layerArray objectAtIndex:i] setAlphaValue:0];
                [[[m_layerArray objectAtIndex:i] m_layerProp] setM_fAlpha:[[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] objectForKey:ETPB_LAYER_Alpha] floatValue]/255.0];
                [[[m_layerArray objectAtIndex:i] m_layerProp] setM_bChecked:NO];

            }
            [[m_layerArray objectAtIndex:i] setNeedsDisplay:YES];
            [[m_layerArray objectAtIndex:i] setLayerImage];
            
            
        }
        timer2 = [NSTimer scheduledTimerWithTimeInterval: 2.0
                                                  target: self
                                                selector: @selector(handleTimer2:)
                                                userInfo: nil
                                                 repeats: YES];
        [m_layerController setAddBtnState:YES];
    }
 
    
    [[backgroundView window] setBackgroundColor: [NSColor redColor]];
    
    NSUndoManager *undoManager = [self undoManager];
    [undoManager removeAllActions];



}

- (void)addNewLayer:(int)layerOrder
{
    int i = 0;
    if(m_nCurLayeIndex == [m_layerArray count]-1)
    {
        m_curLayer = [backgroundView addNewView:m_nCurLayeIndex type:1];
        [m_layerArray addObject:m_curLayer];
     
    }
    else
    {
        m_curLayer = [backgroundView insertNewViewAtIndex:m_nCurLayeIndex];
        [m_layerArray insertObject:m_curLayer atIndex:m_nCurLayeIndex+1];
        for (i=m_nCurLayeIndex+2; i < [m_layerArray count]; i++)
        {
            if ([[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder] >= [[m_curLayer m_layerDataSource] m_nLayerOrder])
            {
                [[[m_layerArray objectAtIndex:i] m_layerDataSource] setM_nLayerOrder:([[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder] + 1)];
            }
        }
    }
    //add to resolve "paste" problem
    if ([[toolbox currentTool] isKindOfClass:[SWSelectionTool class]])
    {
        
        [m_curLayer mouseDown:nil];
    }
    //end
    
    [backgroundView setCurLayer:m_curLayer];
    [[m_layerArray objectAtIndex:[m_layerArray count]-1] setCurLayer:m_curLayer];
    [m_curLayer setCurLayer:m_curLayer];
    [m_curLayer setDocumentDeleget:self];
    NSString *strLayerName = [[NSString alloc] initWithFormat:@"Layer %d", m_nTotalLayerCount];
    m_nTotalLayerCount++;
    
    
    
    
    ETLayerProperty *layerProps = [[ETLayerProperty alloc] init];
    [layerProps setM_bChecked:YES];
    [layerProps setM_layerThumbnail:[NSImage imageNamed:@"background"]];
    [layerProps setM_strLayerName:strLayerName];
    [layerProps setM_fAlpha:[[m_curLayer m_layerDataSource] m_nAlpha]*1.0/255];
    [m_layerController addLayerProps:layerProps atIndex:m_nCurLayeIndex+1];
    [m_curLayer setM_layerProp:layerProps];
    [m_curLayer writeLayerDataSource];
    
    NSUndoManager *undoManager = [self undoManager];
    [[undoManager prepareWithInvocationTarget:self] deleteLayerForUndo:1];
    //    [m_deletedLayerArray addObject:m_curLayer];
    
    [strLayerName release];
    [layerProps release];
    
    ETUndoObject *undoOpe = [[ETUndoObject alloc] init];
    [undoOpe setM_nUndoType:Delete_Layer];
    NSMutableArray *deletedLayerArray = [[NSMutableArray alloc] init];
    [deletedLayerArray addObject:m_curLayer];
    [undoOpe setM_para1:deletedLayerArray];
    
    [self addOperationToUndo_RedoArray:undoOpe toUndo:YES];
    
    
    
    [deletedLayerArray release];
    
}


- (void)setUpBackGroundView:(NSSize)frameSize
{
    [backgroundView setFrame:NSMakeRect(0.0, 0.0, frameSize.width, frameSize.height)];
	NSRect viewRect = [backgroundView frame];
	NSRect tempRect = [backgroundView calculateWindowBounds:viewRect];
	
	[[backgroundView window] setFrame:tempRect display:YES animate:YES];
    
    [backgroundView setUp:toolbox];
    [[backgroundView window] setBackgroundColor:[NSColor blackColor]];
    [[backgroundView window] showsToolbarButton];
    
}

-(void)setUpFirstPaintView
{
    m_curLayer = [backgroundView addNewView:-1 type:0];
    [m_layerArray addObject:m_curLayer];
    [m_curLayer setCurLayer:m_curLayer];
    [m_curLayer setDocumentDeleget:self];
    [backgroundView setCurLayer:m_curLayer];
    [[m_layerArray objectAtIndex:[m_layerArray count]-1] setCurLayer:m_curLayer];
    int nLayerCount = [m_layerArray count];
    NSString *strLayerName = [[NSString alloc] initWithString:@"Background"];
    m_nTotalLayerCount++;
    
    //[[[backgroundView superview] window] useOptimizedDrawing:YES];
    ETLayerProperty *layerProps = [[ETLayerProperty alloc] init];
    [layerProps setM_bChecked:YES];
    [layerProps setM_layerThumbnail:[NSImage imageNamed:@"background"]];    
    [layerProps setM_strLayerName:strLayerName];
    [layerProps setM_fAlpha:[[m_curLayer m_layerDataSource] m_nAlpha]*1.0/255];
    [m_layerController addLayerProps:layerProps atIndex:nLayerCount-1];
    [m_curLayer setM_layerProp:layerProps];
    
    [strLayerName release];
    [layerProps release];
    [[NSColorPanel sharedColorPanel] close];
    timer2 = [NSTimer scheduledTimerWithTimeInterval: 2.0
                                              target: self
                                            selector: @selector(handleTimer2:)
                                            userInfo: nil
                                             repeats: YES];
}


- (NSString *)pathForImageBackgrounds
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	NSString *folder = @"~/Library/Application Support/Paintbrush/Background Images/";
	folder = [folder stringByExpandingTildeInPath];
	
	if ([fileManager fileExistsAtPath: folder] == NO)
	{
    
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:NO  attributes:nil error:nil];
	}
    
	NSString *fileName = @"bgImage.png";
	return [folder stringByAppendingPathComponent:fileName];   
}

#pragma mark Sheets - Size and Text

////////////////////////////////////////////////////////////////////////////////
//////////		Sheets - Size and Text
////////////////////////////////////////////////////////////////////////////////


// Called when a new document is made
- (IBAction)raiseSizeSheet:(id)sender
{
    
    [m_layerController EnableAdd_DeleteLayerBtn:NO];
    [m_layerController setAddBtnState:NO];
    [NSApp beginSheet:[sizeController window]
	   modalForWindow:[super windowForSheet]
		modalDelegate:self
	   didEndSelector:@selector(sizeSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}


- (void)sizeSheetDidEnd:(NSWindow *)sheet
			 returnCode:(NSInteger)returnCode
			contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) 
	{
		NSSize openingSize;
		openingSize.width = [sizeController width];
		openingSize.height = [sizeController height];
		
		NSAssert(dataSource == nil, @"We can't already have a DataSource when creating a document!");

		dataSource = [[SWImageDataSource alloc] initWithSize:openingSize];

        [self setUpBackGroundView:[dataSource size]];
        [self setUpFirstPaintView];
        [m_layerController setAddBtnState:YES];
	} 
	else if (returnCode == NSCancelButton)
	{
		[[super windowForSheet] close];
        [m_layerController setAddBtnState:NO];
	}
}


- (IBAction)raiseResizeSheet:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
	if ([[sender class] isEqualTo: [NSMenuItem class]])
		[resizeController setScales:[sender tag]];
	 [m_layerController setAddBtnState:NO];
	NSSize currSize = [[backgroundView getDatasource] size];//[dataSource size];
	[resizeController setCurrentSize:currSize];
	
    [NSApp beginSheet:[resizeController window]
	   modalForWindow:[super windowForSheet]
		modalDelegate:self
	   didEndSelector:@selector(resizeSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}


- (void)resizeSheetDidEnd:(NSWindow *)sheet
			   returnCode:(NSInteger)returnCode
			  contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) 
	{
		NSSize newSize;
		newSize.width = [resizeController width];
		newSize.height = [resizeController height];

		if ([[backgroundView getDatasource] size].width != newSize.width || [[backgroundView getDatasource] size].height != newSize.height) 
		{
			[toolbox tieUpLooseEndsForCurrentTool];

			[self handleUndoWithImageData:nil frame:NSZeroRect];
			
            [backgroundView setFrame:NSMakeRect(0.0, 0.0, newSize.width, newSize.height)];
            [[backgroundView getDatasource] resizeToSize:newSize];
			int count = [[backgroundView subviews] count];
            int i;
            for (i = 0; i < count; i++) 
            {
                [[m_layerArray objectAtIndex:i] setFrame:NSMakeRect(0.0, 0.0, newSize.width, newSize.height)];
                [[[m_layerArray objectAtIndex:i] getDatasource] resizeToSize:newSize scaleImage:[resizeController scales]];
            }
            
            
			[clipView setNeedsDisplay:YES];
		}
	}
     [m_layerController setAddBtnState:YES];
}


- (void)undoLevelChanged:(NSNotification *)n
{
	NSNumber *number = [n object];
	[[self undoManager] setLevelsOfUndo:[number integerValue]];
}


- (void)showTextSheet:(NSNotification *)n
{
	if ([[super windowForSheet] isKeyWindow]) {
		if (!textController)
			textController = [[SWTextToolWindowController alloc] initWithDocument:self];
		
		[NSApp beginSheet:[textController window]
		   modalForWindow:[super windowForSheet]
			modalDelegate:self
		   didEndSelector:@selector(textSheetDidEnd:string:)
			  contextInfo:NULL];
		
		[[NSFontManager sharedFontManager] orderFrontFontPanel:self];
		
		[[NSColorPanel sharedColorPanel] setColor:[n object]];
		
	}
}


- (void)textSheetDidEnd:(NSWindow *)sheet
				 string:(NSString *)string
{
	[[[NSFontManager sharedFontManager] fontPanel:NO] orderOut:self];
}


#pragma mark Menu actions (Open, Save, Cut, Print, et cetera)

////////////////////////////////////////////////////////////////////////////////
//////////		Menu actions (Open, Save, Cut, Print, et cetera)
////////////////////////////////////////////////////////////////////////////////


- (IBAction)saveDocument:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
	[toolbox tieUpLooseEndsForCurrentTool];
	[super saveDocument:sender];
}

-(IBAction)newDocument:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
    m_bNewDocumentBeforeClose = YES;
    m_bOpenDocumentBeforeClose = NO;
    
    [[self windowForSheet] performClose:sender ];
    
}

-(IBAction)openDocument:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
    m_bOpenDocumentBeforeClose = YES;
    m_bNewDocumentBeforeClose = NO;
    [[self windowForSheet] performClose:sender ];
}


- (BOOL) saveToURL:(NSURL *)absURL 
			ofType:(NSString *)type 
  forSaveOperation:(NSSaveOperationType)saveOp 
			 error:(NSError **)outError
{
    BOOL status = [super saveToURL:absURL ofType:type forSaveOperation:saveOp error:outError];
	
/*    if (status==YES && (saveOp==NSSaveOperation || saveOp==NSSaveAsOperation))
    {
		NSURL* url = [self fileURL];
		
		// reload the image (this could fail)
		status = [self readFromURL:url ofType:type error:outError];
		
		// re-initialize the UI
		//[paintView setNeedsDisplay:YES];
		
        //		// Tell the info panel that the url changed
        //		[ImageInfoPanel setURL:url];
    }*/
	
	return status;
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName
                               error:(NSError **)outError 
{
    
    [[m_layerController getCollectionView] setSelectionIndexes:[NSIndexSet indexSetWithIndex:-1]];
    int count = [[[m_layerController getCollectionView] subviews] count];
    int counter = 0;
    for( ;counter<count;counter++)
    {
        
        [[[[[[m_layerController getCollectionView] subviews] objectAtIndex:counter] subviews] objectAtIndex:2] setEditable:NO];
        
    }
    NSFileWrapper *documentFileWrapper = nil;
    
    if ([[typeName lowercaseString] isEqualToString:@"mpb"])
    {
        
        documentFileWrapper = [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil] autorelease];
        
        
        NSDictionary *fileWrappers = [documentFileWrapper fileWrappers];
        NSURL* url = [self fileURL];
        [url relativePath];
        m_proInfoArray =  [[NSMutableArray alloc] init];
        m_proDictionary = [[NSMutableDictionary alloc] init];
        NSString* proWidth = [[NSString alloc] initWithFormat:@"%f",[backgroundView bounds].size.width];
        NSString* proHeight = [[NSString alloc] initWithFormat:@"%f",[backgroundView bounds].size.height];
        [m_proDictionary setValue:proHeight forKey:ETPB_Height];
        [m_proDictionary setValue:proWidth forKey:ETPB_Width];
        [m_proDictionary setValue:Version forKey:ETPB_Version];
        [proWidth release];
        proWidth = nil;
        
        [proHeight release];
        proHeight = nil;
        
        int i;
        int count = [m_layerArray count];
        [m_proInfoArray addObject:m_proDictionary];
        NSData* layerData = nil;
        for(i = 0 ; i < count ; i++)
        {
            [[m_layerArray objectAtIndex:i] writeLayerDataSource];
            [SWImageTools flipImageVertical:[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_dataSource] mainImage]];
            layerData = [[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_dataSource] mainImage] representationUsingType:NSPNGFileType properties:nil];
            [SWImageTools flipImageVertical:[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_dataSource] mainImage]];
             NSString* imageFile = [[NSString alloc] initWithFormat:@"%i.png",[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder]];
            NSFileWrapper *imageFileWrapper = [[NSFileWrapper alloc]
                                               initRegularFileWithContents:layerData];
            [imageFileWrapper setPreferredFilename:imageFile];
            NSLog(@"%@", imageFile);
            if ([fileWrappers objectForKey:imageFile] == nil ) {
                [documentFileWrapper addFileWrapper:imageFileWrapper];
            }
            
            
            [[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] setValue:imageFile forKey:ETPB_LAYER_FILE];
            [m_proInfoArray addObject:[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic]];
        }
        NSString *errorDescription = nil;
        NSData *xmldata = [NSPropertyListSerialization dataFromPropertyList:m_proInfoArray format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorDescription];
        
        NSFileWrapper *xmlFileWrapper = [[NSFileWrapper alloc]
                                         initRegularFileWithContents:xmldata];
        [xmlFileWrapper setPreferredFilename:XML_File];
        if ([fileWrappers objectForKey:XML_File] == nil) {
            [documentFileWrapper addFileWrapper:xmlFileWrapper];
        }
        
        count = [[[m_layerController getCollectionView] subviews] count];
        counter = 0;
        for( ;counter<count;counter++)
        {
            [[[[[[m_layerController getCollectionView] subviews] objectAtIndex:counter] subviews] objectAtIndex:2] setEditable:YES];
        }
        
    }
    
    else 
    {
        NSData *imageData = [self dataOfType:typeName error:outError];
        documentFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:imageData];
        
    }
    
    return documentFileWrapper;
    
}



- (NSData *)dataOfType:(NSString *)aType error:(NSError **)anError
{  
    if([aType isEqualToString:@"xml"])
    {
    NSURL* url = [self fileURL];
        [url relativePath];
    m_proInfoArray =  [[NSMutableArray alloc] init];
    m_proDictionary = [[NSMutableDictionary alloc] init];
    NSString* proWidth = [[NSString alloc] initWithFormat:@"%f",[backgroundView bounds].size.width];
    NSString* proHeight = [[NSString alloc] initWithFormat:@"%f",[backgroundView bounds].size.height];
    [m_proDictionary setValue:proHeight forKey:ETPB_Height];
    [m_proDictionary setValue:proWidth forKey:ETPB_Width]; 
    int i;
    int count = [m_layerArray count];
    [m_proInfoArray addObject:m_proDictionary];
    NSData* layerData = nil;
    for(i = 0 ; i < count ; i++)
    {
        [SWImageTools flipImageVertical:[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_dataSource] mainImage]];
        layerData = [[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_dataSource] mainImage] representationUsingType:NSPNGFileType properties:nil];
        [SWImageTools flipImageVertical:[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_dataSource] mainImage]];
        NSString* imageFile = [[NSString alloc] initWithFormat:@"/Users/user/Desktop/pro/layer%i.png",[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder]];
        [layerData writeToFile:imageFile atomically:NO];
        [[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] setValue:imageFile forKey:ETPB_LAYER_FILE];
        [m_proInfoArray addObject:[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic]];
    }
    NSString *errorDescription = nil;
	NSData *data = [NSPropertyListSerialization dataFromPropertyList:m_proInfoArray format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorDescription];
	if (data == nil || errorDescription)
		NSLog(@"Error serializing AudioCDDocument: %@", errorDescription);
    [m_proDictionary release];
    [m_proInfoArray release];
    return data;
    }
	NSBitmapImageRep *bitmap ;
    [SWImageTools initImageRep:&bitmap withSize:[backgroundView bounds].size];
    SWLockFocus(bitmap);
    
    NSColor *bgColor = [NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:1];
    [bgColor setFill];
    
    NSRect newRect = (NSRect) { NSZeroPoint, [backgroundView bounds].size };
    NSRectFill(newRect);
    
    SWUnlockFocus(bitmap);
    NSBitmapImageRep *bitmapBuffer ;
    [SWImageTools initImageRep:&bitmapBuffer withSize:[backgroundView bounds].size];
   /* SWLockFocus(bitmapBuffer);
    
    NSColor *bgBufferColor = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0];
    [bgBufferColor setFill];
    
    NSRect newBufferRect = (NSRect) { NSZeroPoint, [backgroundView bounds].size };
    NSRectFill(newBufferRect);
    
    SWUnlockFocus(bitmapBuffer);*/
    int i;
    int count = [m_layerArray count];
    for (i = 0; i < count; i++)
    {
        int iWidth,iHeight;
        int offset = 0;
        int Width = [backgroundView bounds].size.width;
        int Height = [backgroundView bounds].size.height;
        
        SWLockFocus(bitmapBuffer);
        [SWImageTools clearImage:bitmapBuffer];
        
         
         NSColor *bgBufferColor = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0];
         [bgBufferColor setFill];
         
         NSRect newBufferRect = (NSRect) { NSZeroPoint, [backgroundView bounds].size };
         NSRectFill(newBufferRect);
         
         SWUnlockFocus(bitmapBuffer);
        
        float alpha;
        if([[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] objectForKey:ETPB_LAYER_bVisible] boolValue])
            alpha= [[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] objectForKey:ETPB_LAYER_Alpha] floatValue];
        else
            alpha = 0.0;
        
        
       // alpha = [[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] objectForKey:ETPB_LAYER_Alpha] intValue];
        unsigned char* dataBuffer = [bitmapBuffer bitmapData];
        //unsigned char* data = [bitmap bitmapData];
        unsigned char* curLayerBitmapData = [[[[m_layerArray objectAtIndex:i] getDatasource] mainImage] bitmapData];
        NSLog(@"%f",alpha);
        //[SWImageTools drawToImage:bitmapBuffer fromImage:[[[m_layerArray objectAtIndex:i] getDatasource] mainImage] withComposition:YES];
        for (iHeight = 0; iHeight < Height; iHeight++) 
        {
            for(iWidth = 0;iWidth < Width ;iWidth++)
            {
                offset = 4*(iHeight * Width + iWidth);
                if (curLayerBitmapData[offset ] !=0 || curLayerBitmapData[offset + 1] != 0 || curLayerBitmapData[offset + 2] != 0 || curLayerBitmapData[offset + 3] != 0)
                {
                    
                    dataBuffer[offset] = curLayerBitmapData[offset ];
                    dataBuffer[offset + 1] = curLayerBitmapData[offset + 1];
                    dataBuffer[offset + 2] = curLayerBitmapData[offset + 2];
                    dataBuffer[offset + 3] = curLayerBitmapData[offset + 3];
                    dataBuffer[offset + 3] = dataBuffer[offset + 3] * alpha / 255.0; 
                    dataBuffer[offset + 2] = dataBuffer[offset + 2] * alpha / 255.0; 
                    dataBuffer[offset + 1] = dataBuffer[offset + 1] * alpha / 255.0; 
                    dataBuffer[offset + 0] = dataBuffer[offset + 0] * alpha / 255.0; 
                    
               }
             
                
            }
        }
       
        [SWImageTools drawToImage:bitmap fromImage:bitmapBuffer withComposition:YES];
    
    }
	[SWImageTools flipImageVertical:bitmap];
	NSData *data = nil;
	NSBitmapImageFileType fileType = NSPNGFileType;
	
	if ([aType isEqualToString:@"bmp"])
		fileType = NSBMPFileType;
	else if ([aType isEqualToString:@"png"])
		fileType = NSPNGFileType;
	else if ([aType isEqualToString:@"jpg"])
		fileType = NSJPEGFileType;
	else if ([aType isEqualToString:@"gif"])
		fileType = NSGIFFileType;
	else if ([aType isEqualToString:@"tif"])
		fileType = NSTIFFFileType;
	else
		DebugLog(@"Error: unknown filetype!");
	NSTIFFCompression tiffCompression = (fileType == NSJPEGFileType ? NSTIFFCompressionJPEG : NSTIFFCompressionNone);
	CGFloat compressionFactor = [savePanelAccessoryViewController imageQuality];
	NSDictionary *propDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInteger:tiffCompression], NSImageCompressionMethod,
							  [NSNumber numberWithFloat:compressionFactor], NSImageCompressionFactor, 
							  nil];
	data = [bitmap representationUsingType:fileType 
								properties:propDict];//将bitmap转换为data数据
    
	
    [bitmap release];
	return data;
}


- (NSDictionary *)fileAttributesToWriteToURL:(NSURL *)absoluteURL
									  ofType:(NSString *)typeName
							forSaveOperation:(NSSaveOperationType)saveOperation
						 originalContentsURL:(NSURL *)absoluteOriginalContentsURL
									   error:(NSError **)outError
{
    NSMutableDictionary *fileAttributes = [[super fileAttributesToWriteToURL:absoluteURL
																	  ofType:typeName 
															forSaveOperation:saveOperation
														 originalContentsURL:absoluteOriginalContentsURL
																	   error:outError] mutableCopy];
	
    [fileAttributes setObject:[NSNumber numberWithUnsignedInt:'Pbsh']
					   forKey:NSFileHFSCreatorCode];
    return [fileAttributes autorelease];
}


- (BOOL)prepareSavePanel:(NSSavePanel *)savePanel
{
	if (!savePanelAccessoryViewController) {
		savePanelAccessoryViewController = [[SWSavePanelAccessoryViewController alloc] initWithNibName:@"SavePanelAccessoryView"
																								bundle:nil];
		[savePanelAccessoryViewController addObserver:self 
										   forKeyPath:kSWCurrentFileType 
											  options:NSKeyValueObservingOptionNew 
											  context:NULL];
	}
    
	NSString *savedValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"FileType"];
	[currentFileType release];
	currentFileType = [[SWImageTools convertFileType:savedValue] retain];
	
	[savePanelAccessoryViewController loadView];
	NSView *accessoryView = [savePanelAccessoryViewController viewForFileType:savedValue];
	if (accessoryView) {
		[savePanel setAccessoryView:accessoryView];
	}
	
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:currentFileType]];
	
	return YES;
}


- (NSString *)fileTypeFromLastRunSavePanel
{
    return currentFileType;
}


- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	NSString *newFileType = [change valueForKey:NSKeyValueChangeNewKey];
	if (newFileType) 
	{
		[currentFileType release];
		currentFileType = [newFileType retain];
		NSSavePanel *savePanel = (NSSavePanel *)[[savePanelAccessoryViewController view] window];
		[savePanel setAllowedFileTypes:[NSArray arrayWithObject:currentFileType]];
	}
}



-(BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError
{
    NSDictionary *fileWrappers = [fileWrapper fileWrappers];
    NSLog(@"fileName:%@", [fileWrapper filename]);
    
    NSFileWrapper *xmlFileWrapper = [fileWrappers objectForKey:XML_File];
    if (xmlFileWrapper != nil) 
    {
        NSString *errorDescription = nil;
        NSData *xmlData = [xmlFileWrapper regularFileContents];
        NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
        m_proInfoArray = [[NSPropertyListSerialization propertyListFromData:xmlData
                                                          mutabilityOption:NSPropertyListMutableContainers
                                                                    format:&format
                                                          errorDescription:&errorDescription] retain];
        
        NSSize proSize;
        proSize.height = [[[m_proInfoArray objectAtIndex:0] valueForKey:ETPB_Height] floatValue];
        proSize.width = [[[m_proInfoArray objectAtIndex:0] valueForKey:ETPB_Width] floatValue];
        
        
    }
  
  
    
    return YES;
}


/*-(id)initWithContentsOfURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    if(g_AppController)
    {
        if ([g_AppController m_bFirstInit]) 
        {
            [g_AppController setM_bFirstInit:NO];
            return nil;
        }
        else 
        {
            return [super initWithContentsOfURL:absoluteURL ofType:typeName error:outError];
        }
    }
    else
        return nil;
}
*/
- (BOOL)readFromURL:(NSURL *)URL ofType:(NSString *)aType error:(NSError **)anError
{
    if (![aType isEqualToString:@"MPB"]) 
    {
        
        NSImage *backImage = [[NSImage alloc] initWithContentsOfFile:[URL relativePath]];
        NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[backImage TIFFRepresentation]];
        NSSize size = NSMakeSize([rep pixelsWide], [rep pixelsHigh]);
        [backImage setSize: size];
        
        m_proInfoArray =  [[NSMutableArray alloc] init];
        m_proDictionary = [[NSMutableDictionary alloc] init];
        NSString* proWidth = [[NSString alloc] initWithFormat:@"%f",backImage.size.width];
        NSString* proHeight = [[NSString alloc] initWithFormat:@"%f",backImage.size.height];
        [m_proDictionary setValue:proHeight forKey:ETPB_Height];
        [m_proDictionary setValue:proWidth forKey:ETPB_Width]; 
        [m_proInfoArray addObject:m_proDictionary];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:[URL relativePath] forKey:ETPB_LAYER_FILE];
        [dic setValue:@"Background" forKey:ETPB_LAYER_Name];
        [dic setValue:@"0" forKey:ETPB_LAYER_Order];
        [dic setValue:@"255" forKey:ETPB_LAYER_Alpha];
        [dic setValue:@"1" forKey:ETPB_LAYER_bVisible]; //add for version 1.1.0
        [m_proInfoArray addObject:dic];
        return YES;
    }
    else 
    {
        [self setM_strProjectPath:[URL relativePath]];
        NSLog(@"%@", m_strProjectPath);
        return [super readFromURL:URL ofType:aType error:anError];
    }
}

- (void)printDocument:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
    SWPaintView *allLayers = [self combineAllLayersForPrint];//edited for version 1.1.0

     NSPrintOperation *op = [NSPrintOperation printOperationWithView:allLayers  printInfo:[self printInfo]];
	
 	SWPrintPanelAccessoryViewController *ppavc = [[[SWPrintPanelAccessoryViewController alloc]
												   initWithNibName:@"PrintPanelAccessoryView" bundle:nil] autorelease];
	[[op printPanel] addAccessoryController:ppavc];
    [op runOperationModalForWindow:[super windowForSheet]
						  delegate:self
					didRunSelector:NULL
					   contextInfo:NULL];

}

#pragma mark Handling undo

////////////////////////////////////////////////////////////////////////////////
//////////		Handling undo
////////////////////////////////////////////////////////////////////////////////


- (void)handleUndoWithImageData:(NSData *)mainImageData frame:(NSRect)frame
{
	NSUndoManager *undo = [self undoManager];
	NSRect currentFrame = NSZeroRect;
	currentFrame.size = [dataSource size];
	NSData *mainImageDataCurrent = [dataSource copyMainImageData];
	[[undo prepareWithInvocationTarget:self] handleUndoWithImageData:mainImageDataCurrent frame:currentFrame];
	
	if (NSEqualSizes(frame.size, NSZeroSize) || NSEqualSizes(frame.size, [dataSource size]))
		[undo setActionName:NSLocalizedString(@"Drawing", @"The standard undo command string for drawings")];
	else
	{
		[dataSource resizeToSize:frame.size scaleImage:NO];
		[clipView setNeedsDisplay:YES];
		[undo setActionName:NSLocalizedString(@"Resize", @"The undo command string image resizings")];
	}
	
	if (mainImageData == nil)
	{
		NSData *mainImageData = [dataSource copyMainImageData];
		[[undo prepareWithInvocationTarget:self] handleUndoWithImageData:mainImageData frame:frame];
	}
	
	[dataSource restoreMainImageFromData:mainImageData];
	
}


- (void)writeImageToPasteboard:(NSPasteboard *)pb
{
	NSAssert([[toolbox currentTool] isKindOfClass:[SWSelectionTool class]], 
			 @"How are we copying without a SWSelectionTool as the active tool?");
	if ([[toolbox currentTool] isKindOfClass:[SWSelectionTool class]])
	{
		SWSelectionTool *currentTool = (SWSelectionTool *)[toolbox currentTool];
		
		NSBitmapImageRep *selectedImage = [currentTool selectedImage];		
		
		[SWImageTools flipImageVertical:selectedImage];
		
		[pb declareTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:self];
		[pb setData:[selectedImage TIFFRepresentation] forType:NSTIFFPboardType];
		
		[SWImageTools flipImageVertical:selectedImage];
	}
}


- (IBAction)cut:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
	[self copy:sender];
	[m_curLayer clearOverlay];
}


- (IBAction)copy:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
	[self writeImageToPasteboard:[NSPasteboard generalPasteboard]];
}


- (IBAction)paste:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
	//[m_curLayer handleUndoWithImageData:nil frame:NSZeroRect];
	[toolboxController switchToScissors:nil];
	
	NSData *data = [SWImageTools readImageFromPasteboard:[NSPasteboard generalPasteboard]];
	if (data)
	{
            m_bPasting = YES;
            NSBitmapImageRep *pasteBoardImage = [[NSBitmapImageRep alloc] initWithData:data];
            //[SWImageTools flipImageVertical:pasteBoardImage]; //xjp add for version 1.1.0
            NSBitmapImageRep *tempImage;
            [SWImageTools initImageRep:&tempImage withSize:[pasteBoardImage size]];
            [SWImageTools drawToImage:tempImage fromImage:pasteBoardImage withComposition:NO];
        
            [SWImageTools flipImageVertical:tempImage];
            NSRect rect = NSZeroRect;
            rect.size = NSMakeSize(ceil([tempImage size].width), ceil([tempImage size].height));
           // [(SWSelectionTool *)[toolbox currentTool] setClippingRect:rect
           //                                                  forImage:tempImage
           //                                             withMainImage:[[m_curLayer getDatasource] mainImage]];
           // [pasteBoardImage release];
           // [tempImage release];
        
            
            //[m_curLayer setNeedsDisplay:YES];
            //[m_curLayer mouseDown:nil];  //xjp add for version 1.1.0
            //[m_curLayer mouseDragged:nil];//xjp add for version 1.1.0
        NSSize bcGVSize = [backgroundView frame].size;
        NSImage* image = [[NSImage alloc] initWithData:data];
        if(insertView != nil)
        {
            [insertView release];
            insertView = nil;
        }
        insertView = [[ETInsertView alloc] initWithFrame:[backgroundView frame]];
        [insertView setDocDeleget:self];
        //[image setSize:NSMakeSize(400, 400)];
        NSSize size = [image size];
        if(size.width <= 0||size.height<=0)
            return;
        else if(size.width >=bcGVSize.width||size.height>=bcGVSize.height)
        {
            if(size.width>=bcGVSize.height&&size.height>=bcGVSize.height)
            {
                if(size.width/bcGVSize.width >= size.height/bcGVSize.height)
                {
                    float times = size.width/bcGVSize.width; 
                    size.height = size.height/(size.width/bcGVSize.width) - 50/times;
                    size.width = bcGVSize.width-50;
                }
                else
                {
                    float times = size.height/bcGVSize.height;
                    size.width = size.width/(size.height/bcGVSize.height)- 50/times;
                    size.height = bcGVSize.height-50;
                }
            }
            else if(size.width>=bcGVSize.width)
            {
                float times = size.width/bcGVSize.width; 
                size.height = size.height/(size.width/bcGVSize.width)- 50/times;
                size.width = bcGVSize.width-50;
            }
            else if(size.height>=bcGVSize.height)
            {
                float times = size.height/bcGVSize.height;
                size.width = size.width/(size.height/bcGVSize.height)- 50/times;
                size.height = bcGVSize.height-50;
            }
        }
        [image setSize:size];
        NSLog(@"%f~%f",size.width,size.height);
        ETImageViewForInsertPicture* imageView = [[ETImageViewForInsertPicture alloc] initWithFrame:NSMakeRect(0, 0, 0, 0 )];
        [imageView setFrame:NSMakeRect((bcGVSize.width - size.width)/2, (bcGVSize.height - size.height)/2, size.width, size.height)];
        //[imageView ]
        [imageView setImage:image];
        [insertView addSubview:imageView];
        [backgroundView addSubview:insertView];
         rect = [imageView frame];
        [insertView drewPictureRect:rect];

    }

}


- (IBAction)selectAll:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
	[toolboxController switchToScissors:nil];
	
	[[toolbox currentTool] setSavedPoint:NSZeroPoint];
	[[toolbox currentTool] performDrawAtPoint:NSMakePoint([m_curLayer bounds].size.width, [m_curLayer bounds].size.height)
								withMainImage:[[m_curLayer getDatasource] mainImage] 
								  bufferImage:[[m_curLayer getDatasource] bufferImage] 
								   mouseEvent:MOUSE_UP atLayer:m_curLayer] ;
	
	[m_curLayer cursorUpdate:nil];
	[m_curLayer setNeedsDisplay:YES];
}


- (IBAction)zoomIn:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
	if ([sender isKindOfClass:[SWTool class]]) {
		NSPoint point = [(SWTool *)sender savedPoint];
		[scrollView setScaleFactor:([scrollView scaleFactor] * 2) atPoint:point adjustPopup:YES];
	} else {
		[scrollView setScaleFactor:([scrollView scaleFactor] * 2) adjustPopup:YES];
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZOOMSIZE" object:[[[NSString alloc] initWithFormat:@"%f",[scrollView scaleFactor]] autorelease]] ;
}


- (IBAction)zoomOut:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
	if ([sender isKindOfClass:[SWTool class]]) {
		NSPoint point = [(SWTool *)sender savedPoint];
		[scrollView setScaleFactor:([scrollView scaleFactor] / 2) atPoint:point adjustPopup:YES];
	} else {
		[scrollView setScaleFactor:([scrollView scaleFactor] / 2) adjustPopup:YES];
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZOOMSIZE" object:[[[NSString alloc] initWithFormat:@"%f",[scrollView scaleFactor]] autorelease]] ;
}


- (IBAction)actualSize:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
	[scrollView setScaleFactor:1 adjustPopup:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZOOMSIZE" object:[[[NSString alloc] initWithFormat:@"%f",[scrollView scaleFactor]] autorelease]] ;
}


- (IBAction)showGrid:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
	[m_curLayer setShowsGrid:![m_curLayer showsGrid]];
	[sender setState:[m_curLayer showsGrid]];
}


- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
	SEL action = [anItem action];
	if ((action == @selector(copy:)) || 
		(action == @selector(cut:)) || 
		(action == @selector(crop:))) 
	{
		return ([[[toolbox currentTool] class] isEqualTo:[SWSelectionTool class]] && 
				[(SWSelectionTool *)[toolbox currentTool] isSelected]);
	} 
	else if (action == @selector(paste:)) 
	{
		NSArray *array = [[NSPasteboard generalPasteboard] types];
		BOOL paste = NO;
		id object;
		for (object in array) 
		{
			if ([object isEqualToString:NSTIFFPboardType])// || [object isEqualToString:NSPICTPboardType])
				paste = YES;
		}
		return paste;
	}
	else if (action == @selector(zoomIn:))
		return [scrollView scaleFactor] < 16;
	else if (action == @selector(zoomOut:))
		return [scrollView scaleFactor] > 0.25;
	else if (action == @selector(showGrid:))
		return [scrollView scaleFactor] > 2.0;
	else if (action == @selector(newFromClipboard:))
		return YES;
	else
		return YES;
}


+ (void)setWillShowSheet:(BOOL)showSheet
{
	kSWDocumentWillShowSheet = showSheet;
}


#pragma mark Handling notifications from the toolbox, application controller

////////////////////////////////////////////////////////////////////////////////
//////////		Handling notifications from the toolbox, application controller
////////////////////////////////////////////////////////////////////////////////


- (IBAction)flipHorizontal:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
	if ([[super windowForSheet] isKeyWindow])
	{
		[self handleUndoWithImageData:nil frame:NSZeroRect];
		NSBitmapImageRep *image = [[m_curLayer getDatasource] mainImage];
		[SWImageTools flipImageHorizontal:image];
		[m_curLayer setNeedsDisplay:YES];
	}
}


- (IBAction)flipVertical:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
	if ([[super windowForSheet] isKeyWindow]) 
	{
		[self handleUndoWithImageData:nil frame:NSZeroRect];
		NSBitmapImageRep *image = [[m_curLayer getDatasource] mainImage];
		[SWImageTools flipImageVertical:image];
		[m_curLayer setNeedsDisplay:YES];
	}
}


- (IBAction)crop:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
	if ([[toolbox currentTool] isKindOfClass:[SWSelectionTool class]])
	{
		NSRect rect = [(SWSelectionTool *)[toolbox currentTool] clippingRect];
		[toolbox tieUpLooseEndsForCurrentTool];
		[self handleUndoWithImageData:nil frame:NSZeroRect];
        int count = [[backgroundView subviews] count];
        int i;
        for (i = 0; i < count; i++) 
        {
            id layer = [m_layerArray objectAtIndex:i];
            NSBitmapImageRep *mImage = [SWImageTools cropImage:[[layer getDatasource] mainImage] toRect:rect];
            [[layer getDatasource] resizeToSize:rect.size scaleImage:NO];
            [[layer getDatasource] restoreMainImageFromData:[mImage TIFFRepresentation]];
            [[m_layerArray objectAtIndex:i] setFrame:NSMakeRect(0.0, 0.0, rect.size.width, rect.size.height)];
        }
		[backgroundView setFrame:NSMakeRect(0.0, 0.0, rect.size.width, rect.size.height)];
		[clipView setNeedsDisplay:YES];

	}
}


- (IBAction)invertColors:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
	[self handleUndoWithImageData:nil frame:NSZeroRect];
	[SWImageTools invertImage:[[m_curLayer getDatasource] mainImage]];
	[m_curLayer setNeedsDisplay:YES];
}

-(void)setCurLayerIndex:(int)curIndex
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
    if([[toolbox currentTool] isKindOfClass:[SWSelectionTool class]])
        [(SWSelectionTool*)[toolbox currentTool] makeSelected:NO];
    m_nCurLayeIndex = curIndex;
    m_curLayer = [m_layerArray objectAtIndex:curIndex];
    [backgroundView setCurLayer:m_curLayer];
    [m_curLayer setCurLayer:m_curLayer];
    [[m_layerArray objectAtIndex:[m_layerArray count]-1] setCurLayer:m_curLayer];
    
    
    //这里不用给m_curLayer设置curlayer，除了顶层，每个layer中curlayer默认为self；
}

-(void)deleteLayerInIndexSet:(NSIndexSet*)indexSet
{
    ETUndoObject *undoOpe = [[ETUndoObject alloc] init];
    [undoOpe setM_nUndoType:Add_Layer];
    NSMutableArray *AddedLayerArray = [[NSMutableArray alloc] init];
    [undoOpe setM_para1:AddedLayerArray];
    
    NSIndexSet *selIndexs = [indexSet retain];
    NSInteger lastIndex = [selIndexs lastIndex];
    do {
        id deletedLayer = [m_layerArray objectAtIndex:lastIndex];
        [deletedLayer removeFromSuperview];
        //  [deletedLayer release];
        //  [backgroundView rem];
        //     [m_addedLayerArray addObject:deletedLayer];
        int i;
        int count = [m_layerArray count];
        for(i = 0; i < count ; i++)
        {
            if([[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder] > [[deletedLayer m_layerDataSource] m_nLayerOrder])
            {
                [[[m_layerArray objectAtIndex:i] m_layerDataSource] setM_nLayerOrder:([[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder] - 1)];
            }
        }
        [m_layerArray removeObject:deletedLayer];
        
        [AddedLayerArray addObject:deletedLayer];
        
        lastIndex = [selIndexs indexLessThanIndex:lastIndex];
    } while (lastIndex != NSNotFound);
    
    int nDelLayerCount = [selIndexs count];
    
    
    NSUndoManager *undoManager = [self undoManager];
    [[undoManager prepareWithInvocationTarget:self] addLayeForUndo:nDelLayerCount];
    if([m_layerArray count]!=0)
        [[m_layerArray objectAtIndex:[m_layerArray count]-1] setCurLayer:m_curLayer];
    
    
    /*   for (int i=0; i<[AddedLayerArray count]; i++)
     {
     [AddedLayerArray removeObjectAtIndex:i ];
     
     }*/
    [AddedLayerArray release];
    
    
    [self addOperationToUndo_RedoArray:undoOpe toUndo:YES];
    
}

-(void)addLayeForUndo:(int)layerCount
{
    ETUndoObject *undoOpe = nil;//[[ETUndoObject alloc] init];
    //    NSMutableArray * LayerArray = nil;
    
    if ([[self undoManager] isUndoing ])
    {
        undoOpe = [m_UndoOperationArray lastObject];
        [m_UndoOperationArray removeLastObject];
        [self addOperationToUndo_RedoArray:undoOpe toUndo:NO];
    }
    else if([[self undoManager] isRedoing])
    {
        undoOpe = [m_RedoOperationArray objectAtIndex:[m_RedoOperationArray count] - 1];
        [m_RedoOperationArray removeObject:undoOpe];
        [self addOperationToUndo_RedoArray:undoOpe toUndo:YES];
        
    }
    
    
    NSLog(@"Undo add:%d layers", layerCount);
    int nIndex = 0;
    //   int nCount = [m_addedLayerArray count];
    id addedLayer = nil;
    int i=0;
    for(nIndex = 0; nIndex < layerCount; nIndex++)
    {
        
        addedLayer = [[undoOpe m_para1] objectAtIndex:layerCount-1-nIndex];//[m_addedLayerArray objectAtIndex:nCount-1-nIndex];
        int addedLayerOrder = [[addedLayer m_layerDataSource] m_nLayerOrder];
        
        int count = [m_layerArray count];
        for(i = 0; i < count ; i++)
        {
            if([[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder] >= addedLayerOrder)
            {
                [[[m_layerArray objectAtIndex:i] m_layerDataSource] setM_nLayerOrder:([[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder] + 1)];
            }
        }
        
        NSLog(@"addedLayerOrder: %d", addedLayerOrder);
        [m_layerArray insertObject:addedLayer atIndex:addedLayerOrder];
        [backgroundView addLayer:addedLayer atIndex:addedLayerOrder];
        [m_layerController addLayerProps:[addedLayer m_layerProp] atIndex:addedLayerOrder];
        //    [m_addedLayerArray removeObject:addedLayer];
        //    [m_deletedLayerArray addObject:addedLayer];
        /*   if (LayerArray)
         {
         [LayerArray addObject:addedLayer];
         }*/
        
        
    }
    
    
    m_curLayer = [addedLayer retain];
    
    NSUndoManager *undoManager = [self undoManager];
    [[undoManager prepareWithInvocationTarget:self] deleteLayerForUndo:layerCount];
    

    
}

-(void)deleteLayerForUndo:(int)layerCount
{
    ETUndoObject *undoOpe = nil;
    //   NSMutableArray * AddedLayerArray = nil;
    
    if ([[self undoManager] isUndoing ])
    {
        undoOpe = [m_UndoOperationArray lastObject];
        [m_UndoOperationArray removeLastObject];
        [self addOperationToUndo_RedoArray:undoOpe toUndo:NO];
        
    }
    else if([[self undoManager] isRedoing])
    {
        undoOpe = [m_RedoOperationArray objectAtIndex:[m_RedoOperationArray count]-1];
        [m_RedoOperationArray removeObject:undoOpe];
        [self addOperationToUndo_RedoArray:undoOpe toUndo:YES];
    }
    
    NSLog(@"Undo delete:%d layers", layerCount);
    int nIndex = 0;
    //   int nCount = [m_deletedLayerArray count];
    int nDeletedLayerOrder = 0;
    id deletedLayer = nil;
    int i=0;
    
    
    
    for(nIndex = 0; nIndex < layerCount; nIndex++)
    {
        deletedLayer = [[undoOpe m_para1] objectAtIndex:nIndex];//[m_deletedLayerArray objectAtIndex:nCount-1-nIndex];
        nDeletedLayerOrder = [[deletedLayer m_layerDataSource] m_nLayerOrder];
        
        int count = [m_layerArray count];
        for(i = 0; i < count ; i++)
        {
            if([[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder] > [[deletedLayer m_layerDataSource] m_nLayerOrder])
            {
                [[[m_layerArray objectAtIndex:i] m_layerDataSource] setM_nLayerOrder:([[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder] - 1)];
            }
        }
        
        
        [deletedLayer removeFromSuperview];
        //    [m_deletedLayerArray removeObject:deletedLayer];
        //    [m_addedLayerArray addObject:deletedLayer];
        [m_layerArray removeObject:deletedLayer];
        
        /*   if (AddedLayerArray)
         {
         [AddedLayerArray addObject:deletedLayer];
         }*/
        
        
        [m_layerController deleteLayerProp:[deletedLayer m_layerProp]];
        
    }
    
    
    NSUndoManager *undoManager = [self undoManager];
    [[undoManager prepareWithInvocationTarget:self] addLayeForUndo:layerCount];
 
}

- (void)comBineLayers:(NSIndexSet*)indexset
{
    NSIndexSet *selIndexs = [indexset retain];
    NSMutableArray* layerArray = [[NSMutableArray alloc] init];
    NSInteger lastIndex = [selIndexs lastIndex];
    do {
        
        [layerArray addObject:[m_layerArray objectAtIndex:lastIndex]];
        id deletedLayer = [m_layerArray objectAtIndex:lastIndex];
        [[m_layerArray objectAtIndex:lastIndex] removeFromSuperview];
        int i;
        int count = [m_layerArray count];
        for(i = 0; i < count ; i++)
        {
            if([[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder] > [[deletedLayer m_layerDataSource] m_nLayerOrder])
            {
                [[[m_layerArray objectAtIndex:i] m_layerDataSource] setM_nLayerOrder:([[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder] - 1)];
            }
        }
        [m_layerController deleteLayerProp:[[m_layerArray objectAtIndex:lastIndex] m_layerProp]];
        [m_layerArray removeObject:deletedLayer];
        lastIndex = [selIndexs indexLessThanIndex:lastIndex];
        
    }while (lastIndex != NSNotFound);
    
    SWPaintView *combineView = [self layerCombine:layerArray];
    [backgroundView addSubview:combineView];
    [m_layerArray addObject:combineView];
    
    ETLayerProperty *layerProps = [[ETLayerProperty alloc] init];
    [layerProps setM_bChecked:YES];
    [layerProps setM_layerThumbnail:[NSImage imageNamed:@"background"]];
    [layerProps setM_strLayerName:[[NSString alloc] initWithFormat:@"Layer %d", m_nTotalLayerCount]];
    [layerProps setM_fAlpha:[[combineView m_layerDataSource] m_nAlpha]*1.0/255];
    m_nTotalLayerCount++;
    
    [combineView setM_layerProp:layerProps];
    [layerProps release];
    layerProps = nil;
    
    [m_layerController addLayerProps:[combineView m_layerProp] atIndex:[[backgroundView subviews] count]-1];
    
    m_curLayer = combineView;
    [backgroundView setCurLayer:m_curLayer];
    [m_curLayer setCurLayer:m_curLayer];
    [m_curLayer setDocumentDeleget:self];
    [[m_layerArray objectAtIndex:[m_layerArray count]-1] setCurLayer:m_curLayer];
    [m_curLayer setLayerImage];
    [combineView setNeedsDisplay:YES];
    
    NSUndoManager *undoManager = [self undoManager];
    [[undoManager prepareWithInvocationTarget:self] layerSplitForUndo:combineView withOldLayerArray:layerArray];
    
    
    
    ETUndoObject *undoOpe =[[ETUndoObject alloc] init];
    [undoOpe setM_nUndoType:Splite_Layer];
    [undoOpe setM_para1:combineView];
    [undoOpe setM_para2:layerArray];
    
    [self addOperationToUndo_RedoArray:undoOpe toUndo:YES];
    
    [layerArray release];

}

- (SWPaintView*)layerCombine:(NSArray*)layerArray
{
    SWPaintView* newPaintView = [backgroundView creatCombineView];
   // unsigned char* comBineLayerImageData = [[[newPaintView getDatasource] mainImage] bitmapData];
    int i;
    int count = [layerArray count];
    for (i = 0; i < count; i++)
    {
        int iWidth,iHeight;
        int offset = 0;
        int Width = [backgroundView bounds].size.width;
        int Height = [backgroundView bounds].size.height;
        
        
        
        NSBitmapImageRep* curImage = nil;
        
        [SWImageTools initImageRep:&curImage withSize:[backgroundView bounds].size]; 
        [SWImageTools drawToImage:curImage fromImage:[[[layerArray objectAtIndex:count-i-1] getDatasource] mainImage] withComposition:YES];
        unsigned char* curLayerImageData = [curImage  bitmapData];
           float curLayerAlpha;
        if([[[[[layerArray objectAtIndex:count - i -1] m_layerDataSource] m_layerDic] objectForKey:ETPB_LAYER_bVisible] boolValue])
            curLayerAlpha= [[[[[layerArray objectAtIndex:count - i -1] m_layerDataSource] m_layerDic] objectForKey:ETPB_LAYER_Alpha] floatValue];
        else
            curLayerAlpha = 0.0;
        for (iHeight = 0; iHeight < Height; iHeight++) 
        {
            for(iWidth = 0;iWidth < Width ;iWidth++)
            {
                offset = 4*(iHeight * Width + iWidth);
                
                if(curLayerImageData[offset] != 0 || curLayerImageData[offset+1] != 0 || curLayerImageData[offset+2] != 0 || curLayerImageData[offset + 3] != 0 )
               {
                curLayerImageData[offset ] = curLayerImageData[offset ] * curLayerAlpha/255;
                curLayerImageData[offset + 1] = curLayerImageData[offset + 1] * curLayerAlpha/255;
                curLayerImageData[offset + 2] = curLayerImageData[offset + 2] * curLayerAlpha/255;
                curLayerImageData[offset + 3] = curLayerImageData[offset + 3] * curLayerAlpha/255; 
               }
                
                

                //NSLog(@"%i~%i~%i~%i~%i",offset,curLayerImageData[offset ],curLayerImageData[offset + 1],curLayerImageData[offset + 2],curLayerImageData[offset + 3]); 
            }
            
        }
      
      [SWImageTools drawToImage:[[newPaintView getDatasource] mainImage] fromImage:curImage withtype:2];
    }
    
    return newPaintView;
}

- (SWPaintView*)combineAllLayersForPrint
{
    SWPaintView* newPaintView = [[SWPaintView alloc] init];
    
 //   [self addSubview:paintView];
    [newPaintView setFrame:[backgroundView bounds]];
    [newPaintView preparePaintViewWithDataSource:nil toolbox:toolbox type:1];
 //   [[newPaintView m_layerDataSource] setM_nLayerOrder:[[backgroundView subviews] count]-1];
//    NSRect viewRect = [newPaintView frame];
//	NSRect tempRect = [newPaintView calculateWindowBounds:viewRect];
//	[[newPaintView window] setFrame:tempRect display:YES animate:YES];

    
//    SWPaintView* newPaintView = [backgroundView creatCombineView];
    // unsigned char* comBineLayerImageData = [[[newPaintView getDatasource] mainImage] bitmapData];
    int i;
    int count = [m_layerArray count];
    for (i = 0; i < count; i++)
  //  for (i = count - 1; i >=0; i--)
    {
        int iWidth,iHeight;
        int offset = 0;
        int Width = [backgroundView bounds].size.width;
        int Height = [backgroundView bounds].size.height;
        
        
        
        NSBitmapImageRep* curImage = nil;
        
        [SWImageTools initImageRep:&curImage withSize:[backgroundView bounds].size];
        [SWImageTools drawToImage:curImage fromImage:[[[m_layerArray objectAtIndex:i] getDatasource] mainImage] withComposition:YES];
        unsigned char* curLayerImageData = [curImage  bitmapData];
        float curLayerAlpha;
        if([[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] objectForKey:ETPB_LAYER_bVisible] boolValue])
            curLayerAlpha= [[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] objectForKey:ETPB_LAYER_Alpha] floatValue];
        else
            curLayerAlpha = 0.0;
        for (iHeight = 0; iHeight < Height; iHeight++)
        {
            for(iWidth = 0;iWidth < Width ;iWidth++)
            {
                offset = 4*(iHeight * Width + iWidth);
                
                if(curLayerImageData[offset] != 0 || curLayerImageData[offset+1] != 0 || curLayerImageData[offset+2] != 0 || curLayerImageData[offset + 3] != 0 )
                {
                    curLayerImageData[offset ] = curLayerImageData[offset ] * curLayerAlpha/255;
                    curLayerImageData[offset + 1] = curLayerImageData[offset + 1] * curLayerAlpha/255;
                    curLayerImageData[offset + 2] = curLayerImageData[offset + 2] * curLayerAlpha/255;
                    curLayerImageData[offset + 3] = curLayerImageData[offset + 3] * curLayerAlpha/255;
                }
                
             }
            
        }
        
        [SWImageTools drawToImage:[[newPaintView getDatasource] mainImage] fromImage:curImage withtype:2];
        [curImage release];
        curImage = nil;
    }
    return newPaintView;
 
}

-(void)layerSplitForUndo:(id)newLayer withOldLayerArray:(NSMutableArray*)layerArray
{   
    NSLog(@"layerSplitForUndo:");
    ETUndoObject *undoOpe = nil;
    if ([[self undoManager] isUndoing])
    {
        undoOpe = [m_UndoOperationArray lastObject];
        [m_UndoOperationArray removeObject:undoOpe];
        [self addOperationToUndo_RedoArray:undoOpe toUndo:NO];
    }
    else if([[self undoManager] isRedoing])
    {
        undoOpe = [m_RedoOperationArray lastObject];
        [m_RedoOperationArray removeObject:undoOpe];
        [self addOperationToUndo_RedoArray:undoOpe toUndo:YES];
    }
    NSMutableArray *addedLayerArray = [layerArray retain];
    
    //remove the added combined layer from subview, layerController and m_layerArray
    [newLayer removeFromSuperview];
    [m_layerController deleteLayerProp:[newLayer m_layerProp]];
    [m_layerArray removeObject:newLayer];
    
    int nAddedLayerCount = [addedLayerArray count];
    id addedLayer = nil;
    int nAddedLayerOrder = 0;
    int i = 0;
    int index=0;
    for (index=nAddedLayerCount-1; index >=0; index--)
    {
        addedLayer = [addedLayerArray objectAtIndex:index];
        nAddedLayerOrder = [[addedLayer m_layerDataSource] m_nLayerOrder];
        int nCurLayerCount = [m_layerArray count];
        for (i=0; i<nCurLayerCount; i++)
        {
            if ([[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder] >= nAddedLayerOrder)
            {
                [[[m_layerArray objectAtIndex:i] m_layerDataSource] setM_nLayerOrder:[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder]+1];
            }
            
        }
        [m_layerArray insertObject:addedLayer atIndex:nAddedLayerOrder];
        [backgroundView addLayer:addedLayer atIndex:nAddedLayerOrder ];
        [m_layerController addLayerProps:[addedLayer m_layerProp] atIndex:nAddedLayerOrder];
    }
    
    [addedLayerArray release];
    
    
    NSUndoManager *undoManager = [self undoManager];
    [[undoManager prepareWithInvocationTarget:self] layerCombineForUndo:newLayer withOldLayerArray:layerArray];
    

    
}


-(void)layerCombineForUndo:(id)newLayer withOldLayerArray:(NSMutableArray*)layerArray
{
    NSLog(@"layerCombineForUndo:");
    
    ETUndoObject * undoOpe = nil;
    if ([[self undoManager] isUndoing])
    {
        undoOpe = [m_UndoOperationArray lastObject];
        [m_UndoOperationArray removeObject:undoOpe];
        [self addOperationToUndo_RedoArray:undoOpe toUndo:NO];
    }
    else if([[self undoManager] isRedoing])
    {
        undoOpe = [m_RedoOperationArray lastObject];
        [m_RedoOperationArray removeObject:undoOpe];
        [self addOperationToUndo_RedoArray:undoOpe toUndo:YES];
    }
    NSMutableArray *deletedLayerArray = [layerArray retain];
    
    //remove the added combined layer from subview, layerController and m_layerArray
    
    
    int nDeletedLayerCount = [deletedLayerArray count];
    id  deletedLayer = nil;
    int nDeletedLayerOrder = 0;
    int i = 0;
    int index=0;
    for (index=0; index < nDeletedLayerCount; index++)
    {
        deletedLayer = [deletedLayerArray objectAtIndex:index];
        nDeletedLayerOrder = [[deletedLayer m_layerDataSource] m_nLayerOrder];
        int nCurLayerCount = [m_layerArray count];
        for (i=0; i<nCurLayerCount; i++)
        {
            if ([[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder] > nDeletedLayerOrder)
            {
                [[[m_layerArray objectAtIndex:i] m_layerDataSource] setM_nLayerOrder:[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder]-1];
            }
            
        }
        [m_layerArray removeObject:deletedLayer];
        [deletedLayer removeFromSuperview];
        [m_layerController deleteLayerProp:[deletedLayer m_layerProp]];
    }
    
    [deletedLayerArray release];
    
    int nNewLayerOrder = [[newLayer m_layerDataSource] m_nLayerOrder];
    [backgroundView addLayer:newLayer atIndex:nNewLayerOrder];
    [m_layerArray insertObject:newLayer atIndex:nNewLayerOrder];
    [m_layerController addLayerProps:[newLayer m_layerProp] atIndex:nNewLayerOrder];
    
    NSUndoManager *undoManager = [self undoManager];
    [[undoManager prepareWithInvocationTarget:self] layerSplitForUndo: newLayer withOldLayerArray:layerArray];
    
    if ([[self undoManager] isUndoing])
    {
        id undoOpe = [m_UndoOperationArray lastObject];
        [m_UndoOperationArray removeLastObject];
        if ([undoOpe m_para1])
        {
            [[undoOpe m_para1] release];
            
        }
        if ([undoOpe m_para2])
        {
            [[undoOpe m_para2] release];
            
        }
        [undoOpe release];    }
    else if([[self undoManager] isRedoing])
    {
        ETUndoObject *undoOpe =[[ETUndoObject alloc] init];
        [undoOpe setM_nUndoType:Splite_Layer];
        [undoOpe setM_para1:newLayer];
        [undoOpe setM_para2:layerArray];
        
        int nUndoOpeCount = [m_UndoOperationArray count];
        while (nUndoOpeCount >= [[self undoManager] levelsOfUndo])
        {
            ETUndoObject *undoOpe = [m_UndoOperationArray objectAtIndex:0];
            [m_UndoOperationArray removeObject:undoOpe];
            [self releaseUndoOperation:undoOpe];
            nUndoOpeCount = [m_UndoOperationArray count];
        }
        [m_UndoOperationArray addObject:undoOpe];
    }
}


- (IBAction)savePicture:(id)sender
{
    NSBitmapImageRep* saveImage ;
    [SWImageTools initImageRep:&saveImage withSize:[backgroundView bounds].size];
    SWLockFocus(saveImage);
    
    NSColor *bgColor = [NSColor whiteColor];
    [bgColor setFill];
    
    NSRect newRect = (NSRect) { NSZeroPoint, [backgroundView bounds].size };
    NSRectFill(newRect);
    
    SWUnlockFocus(saveImage);
    int i;
    int count = [m_layerArray count];
    for (i = 0; i < count; i++)
    {
        [SWImageTools drawToImage:saveImage fromImage:[[[m_layerArray objectAtIndex:i] getDatasource] mainImage] withComposition:YES];
    }
    [SWImageTools flipImageVertical:saveImage];
    NSData *saveData = [[NSData alloc] init]; 
    saveData = [saveImage representationUsingType: NSBMPFileType properties: nil]; 
    [saveData writeToFile: @"/Users/user/Desktop/savePicture.BMP" atomically:NO]; 
}

- (IBAction)saveProject:(id)sender
{ 
    m_proInfoArray =  [[NSMutableArray alloc] init];
    m_proDictionary = [[NSMutableDictionary alloc] init];
    NSString* proWidth = [[NSString alloc] initWithFormat:@"%f",[backgroundView bounds].size.width];
    NSString* proHeight = [[NSString alloc] initWithFormat:@"%f",[backgroundView bounds].size.height];
    [m_proDictionary setValue:proHeight forKey:ETPB_Height];
    [m_proDictionary setValue:proWidth forKey:ETPB_Width]; 
    int i;
    int count = [m_layerArray count];
    [m_proInfoArray addObject:m_proDictionary];
    NSData* layerData = nil;
    for(i = 0 ; i < count ; i++)
    {
        [SWImageTools flipImageVertical:[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_dataSource] mainImage]];
        layerData = [[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_dataSource] mainImage] representationUsingType:NSPNGFileType properties:nil];
        [SWImageTools flipImageVertical:[[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_dataSource] mainImage]];
        NSString* imageFile = [[NSString alloc] initWithFormat:@"/Users/user/Desktop/pro/layer%i.png",[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder]];
        [layerData writeToFile:imageFile atomically:NO];
        [[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic] setValue:imageFile forKey:ETPB_LAYER_FILE];
        [m_proInfoArray addObject:[[[m_layerArray objectAtIndex:i] m_layerDataSource] m_layerDic]];
    }
    NSString *errorDescription = nil;
	NSData *data = [NSPropertyListSerialization dataFromPropertyList:m_proInfoArray format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorDescription];
	if (data == nil || errorDescription)
		NSLog(@"Error serializing AudioCDDocument: %@", errorDescription);
    [data writeToFile:@"/Users/user/Desktop/pro/pro.xml" atomically:NO];
    [m_proDictionary release];
    [m_proInfoArray release]; 
    m_proInfoArray = nil;
    
}

- (IBAction)openProject:(id)sender
{
    NSOpenPanel* op = [NSOpenPanel openPanel];
	
	[op setCanChooseDirectories:YES];
	[op setCanChooseFiles:YES];
	[op setAllowsMultipleSelection:YES];
    NSArray *filetypes = [NSArray arrayWithObjects:@"xml",nil];
    [op setAllowedFileTypes:filetypes];
	[op setPrompt:@"Select Project"];
	if ([op runModal] == NSOKButton)
    {
        NSArray* xmlArray = [op filenames];
        NSEnumerator *fileEnumerator = [xmlArray objectEnumerator];
        NSString *filepath;
        while((filepath = [fileEnumerator nextObject]) != nil)
        {
            NSString *errorDescription = nil;
            NSData *data = [[NSData alloc] initWithContentsOfFile:filepath];//@"/Users/user/Desktop/pro/pro.xml"];
            NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
            m_proInfoArray = [NSPropertyListSerialization propertyListFromData:data
                                                       mutabilityOption:NSPropertyListMutableContainers
                                                                 format:&format
                                                       errorDescription:&errorDescription];
            int i = 0 ;
            int count = [m_layerArray count];
            for (; i < count; i++) 
            {
                [m_layerController deleteLayerProp:[[m_layerArray objectAtIndex:0] m_layerProp]];
                [[m_layerArray objectAtIndex:0] removeFromSuperview];
                [m_layerArray removeObjectAtIndex:0];
        
            }
            NSSize proSize;
            proSize.height = [[[m_proInfoArray objectAtIndex:0] valueForKey:ETPB_Height] floatValue];
            proSize.width = [[[m_proInfoArray objectAtIndex:0] valueForKey:ETPB_Width] floatValue];
            [backgroundView setFrame:NSMakeRect(0, 0, proSize.width, proSize.height)];
            [[backgroundView getDatasource] resizeToSize:proSize];
            count = [m_proInfoArray count];
            m_nCurLayeIndex = -1;
            for(i = 1; i < count ;i++)
            {
                [self addNewLayer:m_nCurLayeIndex];
                [[[m_layerArray objectAtIndex:i-1] getDatasource] initWithFile:[[m_proInfoArray objectAtIndex:i] objectForKey:ETPB_LAYER_FILE]];
                [[[[m_layerArray objectAtIndex:i-1] m_layerDataSource] m_layerDic] setValue:[[m_proInfoArray objectAtIndex:i] objectForKey:ETPB_LAYER_ID] forKey:ETPB_LAYER_ID];
                [[[[m_layerArray objectAtIndex:i-1] m_layerDataSource] m_layerDic] setValue:[[m_proInfoArray objectAtIndex:i] objectForKey:ETPB_LAYER_Order] forKey:ETPB_LAYER_Order];
                [[[[m_layerArray objectAtIndex:i-1] m_layerDataSource] m_layerDic] setValue:[[m_proInfoArray objectAtIndex:i] objectForKey:ETPB_LAYER_Alpha] forKey:ETPB_LAYER_Alpha];
                [[[[m_layerArray objectAtIndex:i-1] m_layerDataSource] m_layerDic] setValue:[[m_proInfoArray objectAtIndex:i] objectForKey:ETPB_LAYER_bVisible] forKey:ETPB_LAYER_bVisible];
                [[m_layerArray objectAtIndex:i-1] setNeedsDisplay:YES];
            }
        }
    }
    else
        return;
}
- (void)setAlphaValue:(NSNotification*)noti
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
    float alphaValue = [[m_curLayer m_layerProp] m_fAlpha];
    if( [[m_curLayer m_layerProp] m_bChecked])
        [m_curLayer setAlphaValue:alphaValue];
    else
        [m_curLayer setAlphaValue:0.0];
    [m_curLayer setNeedsDisplay:YES];
    [m_curLayer writeLayerDataSource];
}
-(id)getCurLayer
{
    return m_curLayer;
}
- (void)setLayerChecked:(NSNotification*)noti
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
    int nCount = 0;
    for (; nCount < [[backgroundView subviews] count]; nCount++) 
    {
        BOOL layerBoxChecked = [[[[backgroundView subviews] objectAtIndex:nCount] m_layerProp] m_bChecked];
        if(layerBoxChecked)
        {
            [[[backgroundView subviews] objectAtIndex:nCount] setAlphaValue:[[[backgroundView subviews] objectAtIndex:nCount] m_layerProp].m_fAlpha];
            [[[backgroundView subviews] objectAtIndex:nCount] writeLayerDataSource];
        }
        else
        {
            [[[backgroundView subviews] objectAtIndex:nCount] setAlphaValue:0.0];
            [[[backgroundView subviews] objectAtIndex:nCount] setNeedsDisplay:YES];
            [[[backgroundView subviews] objectAtIndex:nCount] writeLayerDataSource];
        }
    }
    /* BOOL layerBoxChecked = [[m_curLayer m_layerProp] m_bChecked];
     if(layerBoxChecked)
     {
     [self setAlphaValue_:nil];
     }
     else
     {
     [m_curLayer setAlphaValue:0.0];
     [m_curLayer setNeedsDisplay:YES];
     [m_curLayer writeLayerDataSource];
     }
     */
}

- (void)setCurLayerAlphaValue:(float)alphaValue
{
    [m_curLayer setAlphaValue:alphaValue];
    [m_curLayer setNeedsDisplay:YES];
}

- (void) handleTimer: (NSTimer *) timer
{
    NSPoint locationInScr = [NSEvent mouseLocation];
    NSRect mainwindow = [[backgroundView window] frame];
    NSRect layerWindow = [m_layerController getWindowRect];
    if([self pointIsInRect:layerWindow point:locationInScr])
    {
        [[m_layerController window] makeKeyWindow];
        if(m_bSetLayerImage)
        {
            //[m_curLayer setLayerImage];
            m_bSetLayerImage = NO;
        }
    }
    else if([self pointIsInRect:mainwindow point:locationInScr])
    {
        [[backgroundView window] makeKeyWindow];
        m_bSetLayerImage = YES;
    }
}

- (void)timerStop
{
    if(timer != nil)
    {
        if([timer isValid])
        {
            [timer invalidate];
        }
    }
}
- (void)timerStart
{
    [timer fire];
}

- (BOOL)pointIsInRect:(NSRect)Rect point:(NSPoint)downPoint
{
    if(((downPoint.x > Rect.origin.x && downPoint.x < (Rect.origin.x + Rect.size.width))||(downPoint.x < Rect.origin.x && downPoint.x > (Rect.origin.x + Rect.size.width))) && ((downPoint.y > Rect.origin.y && downPoint.y < (Rect.origin.y + Rect.size.height))|| (downPoint.y < Rect.origin.y && downPoint.y > (Rect.origin.y + Rect.size.height))))
        return YES;
    else
        return NO;
}
- (void)dragAndDrop:(NSInteger)dragIndex dropIndex:(NSInteger)dropIndex
{
    if(dragIndex < dropIndex) 
    {
        
        [backgroundView addSubview:[m_layerArray objectAtIndex:dragIndex]];
        int i;
        int count = [m_layerArray count];
        for(i = dropIndex ; i < count -1; i++)
        {
            [backgroundView addSubview:[[backgroundView subviews] objectAtIndex:dropIndex]];
        }
        id dragLayer = [m_layerArray objectAtIndex:dragIndex];
        [m_layerArray removeObjectAtIndex:dragIndex];
        [m_layerArray insertObject:dragLayer atIndex:dropIndex ];
        [[dragLayer m_layerDataSource] setM_nLayerOrder:dropIndex];
        for (i = dragIndex; i < dropIndex; i++) 
        {
           [[[m_layerArray objectAtIndex:i] m_layerDataSource] setM_nLayerOrder:([[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder] -1)];
        }
    }
    else if(dragIndex > dropIndex)
    {
        [backgroundView addSubview:[m_layerArray objectAtIndex:dragIndex]];
        int i;
        int count = [m_layerArray count];
        for (i = dropIndex; i < count -1 ; i++) 
        {
            [backgroundView addSubview:[[backgroundView subviews] objectAtIndex:dropIndex]];
        }
        id dragLayer = [m_layerArray objectAtIndex:dragIndex];
        [m_layerArray removeObjectAtIndex:dragIndex];
        [m_layerArray insertObject:dragLayer atIndex:dropIndex];
        [[dragLayer m_layerDataSource] setM_nLayerOrder:dropIndex];
        for (i = dropIndex + 1; i < dragIndex + 1; i++) 
        {
            [[[m_layerArray objectAtIndex:i] m_layerDataSource] setM_nLayerOrder:([[[m_layerArray objectAtIndex:i] m_layerDataSource] m_nLayerOrder] +1)];
        }
    }
    else if(dragIndex == dropIndex)
    {          
    }
    [self setCurLayerIndex:dropIndex];

}

-(void)setNewOrOpenDocument:(BOOL)bNew
{
    m_bNewDocumentBeforeClose = bNew;
    m_bOpenDocumentBeforeClose = !bNew;
}

- (void) handleTimer2: (NSTimer *) timer
{
    if([m_curLayer mouseUp])
    {
        //NSLog(@"1");
        [m_curLayer setLayerImage];
    }
}

-(void)releaseUndoOperation:(ETUndoObject *)undoOpe
{
    id layer = nil;
    int i = 0;
    int nCount=0;
    
    if ((timer!=nil) && (([m_RedoOperationArray count] && [m_RedoOperationArray containsObject:undoOpe]) || ([m_UndoOperationArray count] &&[m_UndoOperationArray containsObject:undoOpe])))
    {
        return;
    }
    
    switch ([undoOpe m_nUndoType])
    {
        case Add_Layer:
            layer = [undoOpe m_para1];
            for (i=0; i<[layer count]; i++)
            {
                id layer1 = [layer objectAtIndex:i];
                if (layer1 && (![m_layerArray containsObject:layer1]) && (![self undo_RedoArrayContainsLayer:layer1]))
                {
                    NSLog(@"%@ will be released", [[layer1 m_layerDataSource] m_sLayerName]);
                    [layer removeObjectAtIndex:i];
                    [layer1 release];
                    layer1 = nil;
                    i--;
                }
                

            }
            break;
            
        case Delete_Layer:
            layer = [undoOpe m_para1];
            nCount = [layer count];
            
            for (i=0; i<[layer count]; i++)
            {
                id layer1 = [layer objectAtIndex:i];
                
                if (layer1 && (![m_layerArray containsObject:layer1]) && (![self undo_RedoArrayContainsLayer:layer1]))
                {
                    NSLog(@"%@ will be released", [[layer1 m_layerDataSource] m_sLayerName]);
                    [layer removeObject:layer1];
                    [layer1 release];
                    i--;
                    
                }
                

            }
          
            break;
            
        case Combine_Layer:
            layer = [undoOpe m_para1];
            if (layer && (![m_layerArray containsObject:layer]) && (![self undo_RedoArrayContainsLayer:layer]))
            {
                [layer release];
                layer = nil;
            }
            [layer release];
            
            layer = [undoOpe m_para2];
            for (i=0; i<[layer count]; i++)
            {
                id layer1 = [layer objectAtIndex:i];
                if (layer1 && (![m_layerArray containsObject:layer1])&& (![self undo_RedoArrayContainsLayer:layer1]))
                {
                    [layer removeObject:layer1];
                    [layer1 release];
                    layer1 = nil;
                    i--;
                }

            }
                        
            [layer release];
            
            break;
            
        case Splite_Layer:
            layer = [undoOpe m_para1];
            if (layer && (![m_layerArray containsObject:layer]) && (![self undo_RedoArrayContainsLayer:layer]))
            {
                [layer release];
                layer = nil;
            }
            
            layer = [undoOpe m_para2];
            for (i=0; i<[layer count]; i++)
            {
                id layer1 = [layer objectAtIndex:i];
                if (layer1 && (![m_layerArray containsObject:layer1])&& (![self undo_RedoArrayContainsLayer:layer1]))
                {
                    [layer removeObject:layer1];
                    [layer1 release];
                    i--;
                    layer1 = nil;
                }
                
            }
            
    
           
                        
            break;
            
        case Drawing:
            
            break;
            
        default:
            break;
    }
    
    [undoOpe release];
    return;
}

-(void)deleteUndoOperation
{
    id undoOpe = [m_UndoOperationArray lastObject];
    [m_UndoOperationArray removeLastObject];
    if ([undoOpe m_para1])
    {
        [[undoOpe m_para1] release];
        
    }
    if ([undoOpe m_para2])
    {
        [[undoOpe m_para2] release];
        
    }
    [undoOpe release];
}

-(void)addUndoOperation:(ETUndoObject*)undoOpe
{
    int nUndoOpeCount = [m_UndoOperationArray count];
    
    while (nUndoOpeCount >= [[self undoManager] levelsOfUndo])
    {
        ETUndoObject *undoOpe = [m_UndoOperationArray objectAtIndex:0];
        [m_UndoOperationArray removeObject:undoOpe];
        [self releaseUndoOperation:undoOpe];
        nUndoOpeCount = [m_UndoOperationArray count];
    }
    
    [m_UndoOperationArray addObject:undoOpe];
    
}

-(void)addOperationToUndo_RedoArray:(ETUndoObject*)undoObj toUndo:(BOOL)bUndo
{
    if (bUndo)
    {
        int nUndoOpeCount = [m_UndoOperationArray count];
        
        while (nUndoOpeCount >= [[self undoManager] levelsOfUndo])
        {
            ETUndoObject *undoOpe = [m_UndoOperationArray objectAtIndex:0];
            [m_UndoOperationArray removeObject:undoOpe];
            
            [self releaseUndoOperation:undoOpe];
            
            nUndoOpeCount = [m_UndoOperationArray count];
        }
        
        [m_UndoOperationArray addObject:undoObj];
        
    }
    else
    {
        int nRedoOpeCount = [m_RedoOperationArray count];
        
        while (nRedoOpeCount >= [[self undoManager] levelsOfUndo])
        {
            ETUndoObject *undoOpe = [m_RedoOperationArray objectAtIndex:0];
            [m_RedoOperationArray removeObject:undoOpe];
            
            [self releaseUndoOperation:undoOpe];
            
            nRedoOpeCount = [m_RedoOperationArray count];
        }
        
        [m_RedoOperationArray addObject:undoObj];
        
    }
}

-(BOOL)undo_RedoArrayContainsLayer:(id)layer
{
    //  BOOL bContained = NO;
    int nCount = [m_UndoOperationArray count];
    int nIndex = 0;
    for (nIndex = 0; nIndex < nCount; nIndex++)
    {
        ETUndoObject *undoObj = [m_UndoOperationArray objectAtIndex:nIndex];
        if (([undoObj m_nUndoType] == Splite_Layer) || ([undoObj m_nUndoType] == Combine_Layer))
        {
            if ([[undoObj m_para1] isEqual:layer])
            {
                return YES;
            }
            
            
        }
        else
        {
            if([[undoObj m_para1] containsObject:layer])
            {
                return YES;
            }
        }
        if ([undoObj m_para2])
        {
            if ([[undoObj m_para2] containsObject:layer])
            {
                return YES;
                
            }
        }
        
        
    }
    
    nCount = [m_RedoOperationArray count];
    for (nIndex = 0; nIndex < nCount; nIndex++)
    {
        ETUndoObject *undoObj = [m_RedoOperationArray objectAtIndex:nIndex];
        if (([undoObj m_nUndoType] == Splite_Layer) || ([undoObj m_nUndoType] == Combine_Layer))
        {
            if ([[undoObj m_para1] isEqual:layer])
            {
                return YES;
            }
            
            
        }
        else
        {
            if([[undoObj m_para1] containsObject:layer])
            {
                return YES;
            }
        }
        
        if ([undoObj m_para2])
        {
            if ([[undoObj m_para2] containsObject:layer])
            {
                return YES;
                
            }
        }
        
        
    }
    
    return NO;
}

-(void)clearRepeatedObjForMutArray:(NSMutableArray *)mutArray
{
    int i=0, j=0;
    for (i=0; i<[mutArray count]; i++)
    {
        id obj = [mutArray objectAtIndex:i];
        for (j=i+1; j<[mutArray count]; j++)
        {
            if ([obj isEqual:[mutArray objectAtIndex:j]])
            {
                [mutArray removeObjectAtIndex:j];
            }
        }
    }
}

-(void)hideScrollView:(BOOL)bHide
{
    //[[scrollView horizontalScroller] setHidden:bHide];
    //[[scrollView verticalScroller] setHidden:bHide];
    if([[[backgroundView window] contentView] frame].size.width > dataSource.size.width*[scrollView scaleFactor]+12&&[[[backgroundView window] contentView] frame].size.height > dataSource.size.height*[scrollView scaleFactor]+12)
    {
        [[scrollView horizontalScroller] setHidden:YES];
        [[scrollView verticalScroller] setHidden:YES];
    }
    else
    {
        [[scrollView horizontalScroller] setHidden:NO];
        [[scrollView verticalScroller] setHidden:NO];
    }
}

- (SWScalingScrollView *)getScrollView
{
    return scrollView;
}

- (void)windowWillMiniaturize:(NSNotification *)notification
{
    [[[SWToolboxController sharedToolboxPanelController] window] close];
    [[[ETLayerController sharedLayerManagerController] window] close];

}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    NSLog(@"windowDidBecomeMain is called");
    if (![[[SWToolboxController sharedToolboxPanelController] window] isVisible])
    {
       // if(!isSizing)
            [[SWToolboxController sharedToolboxPanelController] showWindow:self];
    }
    if (![[[ETLayerController sharedLayerManagerController] window] isVisible])
    {
        [[ETLayerController sharedLayerManagerController] showWindow:self];
        
    }

}

/***********************************1.20ADD***************************************************/

- (IBAction)insertPicutre:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];

    NSOpenPanel* op = [NSOpenPanel openPanel];
	
	[op setCanChooseDirectories:YES];
	[op setCanChooseFiles:YES];
	[op setAllowsMultipleSelection:NO];
    NSArray *filetypes = [NSArray arrayWithObjects:@"png",@"TIFF",@"BMP",@"jpg",@"gif",nil];
    [op setAllowedFileTypes:filetypes];
	[op setPrompt:@"Select Picture"];
	if ([op runModal] == NSOKButton)
    {
        hasInsertedPc = YES;
        NSSize bcGVSize = [backgroundView frame].size;
        NSArray* fileNameArray = [op filenames];
        NSEnumerator *fileEnumerator = [fileNameArray objectEnumerator];
        NSString *filepath;
        while((filepath = [fileEnumerator nextObject]) != nil)
        {
            inserString = [[NSString alloc] initWithFormat:@"%@",filepath];
            NSImage* image = [[NSImage alloc] initWithContentsOfFile:filepath];
            if(insertView != nil)
            {
                [insertView release];
                insertView = nil;
            }
            insertView = [[ETInsertView alloc] initWithFrame:[backgroundView frame]];
            [insertView setDocDeleget:self];
            //[image setSize:NSMakeSize(400, 400)];
            NSSize size = [image size];
            if(size.width <= 0||size.height<=0)
                return;
            else if(size.width >=bcGVSize.width||size.height>=bcGVSize.height)
            {
                if(size.width>=bcGVSize.height&&size.height>=bcGVSize.height)
                {
                    if(size.width/bcGVSize.width >= size.height/bcGVSize.height)
                    {
                        float times = size.width/bcGVSize.width; 
                        size.height = size.height/(size.width/bcGVSize.width) - 50/times;
                        size.width = bcGVSize.width-50;
                    }
                    else
                    {
                        float times = size.height/bcGVSize.height;
                        size.width = size.width/(size.height/bcGVSize.height)- 50/times;
                        size.height = bcGVSize.height-50;
                    }
                }
                else if(size.width>=bcGVSize.width)
                {
                    float times = size.width/bcGVSize.width; 
                    size.height = size.height/(size.width/bcGVSize.width)- 50/times;
                    size.width = bcGVSize.width-50;
                }
                else if(size.height>=bcGVSize.height)
                {
                    float times = size.height/bcGVSize.height;
                    size.width = size.width/(size.height/bcGVSize.height)- 50/times;
                    size.height = bcGVSize.height-50;
                }
            }
            [image setSize:size];
            NSLog(@"%f~%f",size.width,size.height);
            ETImageViewForInsertPicture* imageView = [[ETImageViewForInsertPicture alloc] initWithFrame:NSMakeRect(0, 0, 0, 0 )];
            [imageView setFrame:NSMakeRect((bcGVSize.width - size.width)/2, (bcGVSize.height - size.height)/2, size.width, size.height)];
            //[imageView ]
            [imageView setImage:image];
            [insertView addSubview:imageView];
            [backgroundView addSubview:insertView];
            //[imageView setFrameRotation:50.0];
            NSRect rect = [imageView frame ];
           //NSRect rect1 = [imageView frame];
            [insertView drewPictureRect:rect];
            //CAffineTransformRotate(imageView.layer.transform, M_PI_2);
            //imageView.layer.transform = CATransform3DRotate(imageView.layer.transform, M_PI,50.0,50.0,60.0);
            //sleep(5);
            //[imageView setFrame:NSMakeRect(0, -20, 400, 400)];
            
        }
    }
}

- (void)concernTheInsertPicture
{
    //NSData* data = [[[[insertView subviews] objectAtIndex:0] image] TIFFRepresentation];
    [m_curLayer handleUndoWithImageData:nil frame:NSZeroRect];
    NSBitmapImageRep* bitMap;
    NSBitmapImageRep* newImage;
    NSBitmapImageRep* _bitMap = nil;
    if(hasInsertedPc)
    {
        _bitMap = [NSBitmapImageRep imageRepWithContentsOfFile:inserString];
    }
    else if(m_bPasting)
    {
        NSData *data = [SWImageTools readImageFromPasteboard:[NSPasteboard generalPasteboard]];
        _bitMap = [NSBitmapImageRep imageRepWithData:data];
    }
    [SWImageTools initImageRep:&bitMap withSize:[_bitMap size]];
    [SWImageTools drawToImage:bitMap fromImage:_bitMap withComposition:YES];
    [SWImageTools flipImageVertical:bitMap];	
    
	[SWImageTools initImageRep:&newImage
					  withSize:[insertView getRectSize]];
	
	NSRect newRect = (NSRect) { NSZeroPoint, [insertView getRectSize] };
	SWLockFocus(newImage);
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    [bitMap drawInRect:newRect];
	SWUnlockFocus(newImage);
    
    
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:[[m_curLayer getDatasource] mainImage]]];
    [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceOver];
    CGContextRotateCTM((CGContextRef)[[NSGraphicsContext currentContext] graphicsPort],M_PI*(-[insertView angle]/180));//旋转angle角度
	/*CGContextDrawImage((CGContextRef)[[NSGraphicsContext currentContext] graphicsPort], 
					   CGRectMake([insertView getRectOrigin].x, [backgroundView frame].size.height - [insertView getRectOrigin].y - [insertView getRectSize].height, [[[[insertView subviews] objectAtIndex:0] image] size].width, [[[[insertView subviews] objectAtIndex:0] image] size].height), [bitMap CGImage]);*/
    CGContextDrawImage((CGContextRef)[[NSGraphicsContext currentContext] graphicsPort], 
					   CGRectMake([insertView originPoint].x - [insertView getRectSize].width/2, [insertView originPoint].y- [insertView getRectSize].height/2, [[[[insertView subviews] objectAtIndex:0] image] size].width, [[[[insertView subviews] objectAtIndex:0] image] size].height), [bitMap CGImage]);
    [insertView removeFromSuperview];
    [m_curLayer setNeedsDisplay:YES];
    [m_curLayer setLayerImage];
    if(hasInsertedPc)
        [inserString release];
    [[[[insertView subviews] objectAtIndex:0] image] release];
    id imageView = [[insertView subviews] objectAtIndex:0];
    [imageView removeFromSuperview];
    [imageView release];
    [bitMap release];
    [newImage release];
    hasInsertedPc = NO;
    m_bPasting = NO;
}

-(IBAction)UndoET:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager undo];
    //[toolboxController setM_bCanUndo:[undoManager canUndo]];
    //[toolboxController setM_bCanRedo:[undoManager canRedo]];
    //[self mainImageToDataBlockArray:nil image:[[m_curLayer getDatasource] mainImage]];
}

-(IBAction)RedoET:(id)sender
{
    if(hasInsertedPc)
        [self concernTheInsertPicture];
    if(m_bPasting)
        [self concernTheInsertPicture];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager redo];
    //[toolboxController setM_bCanUndo:[undoManager canUndo]];
    // [toolboxController setM_bCanRedo:[undoManager canRedo]];
    //[self mainImageToDataBlockArray:nil image:[[m_curLayer getDatasource] mainImage]];
}

@end
