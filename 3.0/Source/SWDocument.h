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



#import <Cocoa/Cocoa.h>

@class ETBackGroundView;
@class SWPaintView;
@class SWScalingScrollView;
@class SWTool;
@class SWToolbox;
@class SWToolboxController;
@class SWSizeWindowController;
@class SWResizeWindowController;
@class SWCenteringClipView;
@class SWTextToolWindowController;
@class SWSavePanelAccessoryViewController;
@class SWImageDataSource;
@class ETCollectionViewItem;
#import "ETLayerController.h"
#import "ETUndoObject.h"
#import "ETImageViewForInsertPicture.h"
#import "ETInsertView.h"

@interface SWDocument : NSDocument
{
	//IBOutlet SWPaintView *paintView;
	IBOutlet SWScalingScrollView *scrollView;	/* ScrollView containing document */
	IBOutlet ETBackGroundView *backgroundView;
	// The image data
	SWImageDataSource * dataSource;
	
	// A bunch of controllers and one view
	SWToolboxController *toolboxController;
	SWToolbox *toolbox;
	SWCenteringClipView *clipView;
	SWTextToolWindowController *textController;
	SWSizeWindowController *sizeController;
	SWResizeWindowController *resizeController;
	SWSavePanelAccessoryViewController *savePanelAccessoryViewController;
    
    ETLayerController *m_layerController;
	NSTimer *timer;
	// Misc other member variables
	NSNotificationCenter *nc;
	NSString *currentFileType;
    id m_curLayer;
    NSMutableArray* m_layerArray;
//    NSMutableArray* m_deletedLayerArray;
//    NSMutableArray* m_addedLayerArray;
    NSMutableDictionary *m_proDictionary;
    NSMutableArray* m_proInfoArray;
    int m_nCurLayeIndex;
    int m_nTotalLayerCount;
    NSString *m_strProjectPath;
    BOOL m_bNewDocumentBeforeClose;
    BOOL m_bSetLayerImage;
    BOOL m_bOpenDocumentBeforeClose;
    NSTimer* timer2;
    BOOL m_bPasting;
    BOOL hasInsertedPc;
    ETInsertView* insertView;
    NSString* inserString;
    NSMutableArray * m_UndoOperationArray;
    NSMutableArray * m_RedoOperationArray;
}

// Properties
@property BOOL m_bPasting;
@property (copy) NSString *m_strProjectPath;
@property BOOL hasInsertedPc;
@property (readonly) SWToolbox *toolbox;
-(void)setCurLayerIndex:(int)curIndex;
- (void) handleTimer: (NSTimer *) timer;
- (void)timerStop;
- (void)timerStart;
- (SWScalingScrollView *)getScrollView;
//@property (readonly) SWPaintView *paintView;
-(id)getCurLayer;
- (void)addNewLayer:(int)layerOrder;
-(void)deleteLayerInIndexSet:(NSIndexSet*)indexSet;
-(void)layerSplitForUndo:(id)newLayer withOldLayerArray:(NSMutableArray*)layerArray;
-(void)layerCombineForUndo:(id)newLayer withOldLayerArray:(NSMutableArray*)layerArray;


//Methods used for Undo/Redo
-(void)addLayeForUndo:(int)layerCount;
-(void)deleteLayerForUndo:(int)layerCount;
- (BOOL)pointIsInRect:(NSRect)Rect point:(NSPoint)downPoint;
// Methods called by menu items
- (void)setUpBackGroundView:(NSSize)frameSize;
-(void)setUpFirstPaintView;
- (void)concernTheInsertPicture;
- (IBAction)flipHorizontal:(id)sender;
- (IBAction)flipVertical:(id)sender;
- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)actualSize:(id)sender;
//- (IBAction)fullScreen:(id)sender;
- (IBAction)crop:(id)sender;
- (IBAction)invertColors:(id)sender;
- (void)showTextSheet:(NSNotification *)n;
- (void)undoLevelChanged:(NSNotification *)n;

// Sheets for size!
- (void)sizeSheetDidEnd:(NSWindow *)sheet
			 returnCode:(NSInteger)returnCode
			contextInfo:(void *)contextInfo;
- (IBAction)raiseSizeSheet:(id)sender;
- (IBAction)raiseResizeSheet:(id)sender;
- (void)resizeSheetDidEnd:(NSWindow *)sheet
			   returnCode:(NSInteger)returnCode
			  contextInfo:(void *)contextInfo;
//- (void)setUpPaintView;

// Undo
- (void)handleUndoWithImageData:(NSData *)mainImageData 
						  frame:(NSRect)frame;
- (void)openAfter;
// For copy-and-paste
- (void)writeImageToPasteboard:(NSPasteboard *)pb;

+ (void)setWillShowSheet:(BOOL)showSheet;
- (SWPaintView*)layerCombine:(NSArray*)layerArray;
- (void)comBineLayers:(NSIndexSet*)indexset;
- (SWPaintView*)combineAllLayersForPrint; //add for version 1.1.0
- (IBAction)savePicture:(id)sender;
- (IBAction)saveProject:(id)sender;
- (IBAction)openProject:(id)sender;
- (void)setCurLayerAlphaValue:(float)alphaValue;
- (void)dragAndDrop:(NSInteger)dragIndex dropIndex:(NSInteger)dropIndex;

-(void)setNewOrOpenDocument:(BOOL)bNew;
-(IBAction)openDocument:(id)sender;

-(void)addUndoOperation:(ETUndoObject*)undoOpe;
-(void)deleteUndoOperation;

-(void)addOperationToUndo_RedoArray:(ETUndoObject*)undoObj toUndo:(BOOL)bUndo;
-(BOOL)undo_RedoArrayContainsLayer:(id)layer;
-(void)clearRepeatedObjForMutArray:(NSMutableArray *)mutArray;
-(void)releaseUndoOperation:(ETUndoObject *)undoOpe;
-(id)getCurLayer;
-(void)hideScrollView:(BOOL)bHide;
-(IBAction)UndoET:(id)sender;
-(IBAction)RedoET:(id)sender;
@end
