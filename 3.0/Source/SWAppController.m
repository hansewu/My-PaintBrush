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


#import "SWAppController.h"
#import "SWSizeWindowController.h"
#import "SWPreferenceController.h"
#import "SWToolboxController.h"
#import "SWDocument.h"
#import "PFMoveApplication.h"
#import "ETLayerController.h"
#ifdef SPARKLE
#import <Sparkle/Sparkle.h>
#endif // SPARKLE

NSString * const kSWUndoKey = @"UndoLevels";
id g_AppController = nil;

@implementation SWAppController
@synthesize isOpen;
@synthesize iDocControll;
@synthesize isOpenRecent;
- (id)init
{
	if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_4) {
		// Pop up a warning dialog... 
		NSRunAlertPanel(@"Sorry, this program requires Mac OS X 10.5.3 or later", @"You are running %@", 
						@"OK", nil, nil, [[[NSProcessInfo alloc] operatingSystemVersionString] autorelease]);
		DebugLog(@"Failed to run: running version %lf", NSAppKitVersionNumber);
		// then quit the program
		[NSApp terminate:self]; 
		
	} else if ((self = [super init])) {
		
		// Create a dictionary
		NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
		
		// Put initial defaults in the dictionary
		[defaultValues setObject:[NSNumber numberWithInt:800] forKey:@"HorizontalSize"];
		[defaultValues setObject:[NSNumber numberWithInt:600] forKey:@"VerticalSize"];
		[defaultValues setObject:[NSNumber numberWithInt:20] forKey:kSWUndoKey];
		[defaultValues setObject:@"MPB" forKey:@"FileType"];
		
		// Register the dictionary of defaults
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];		

		[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
		[NSColorPanel setPickerMode:NSCrayonModeColorPanel];
		[[SWToolboxController sharedToolboxPanelController] showWindow:self];
        [[ETLayerController sharedLayerManagerController] showWindow:self];
        
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(Closed:)
				   name:@"Closed"
				 object:nil];
        [nc addObserver:self
			   selector:@selector(zoomItemSetState:)
				   name:@"ZOOMSIZE"
				 object:nil];
        [nc addObserver:self
			   selector:@selector(layerMenuItemSetState:)
				   name:@"LayerMenuItemSetState"
				 object:nil];
        [nc addObserver:self
			   selector:@selector(toolBoxItemSetState:)
				   name:@"ToolBoxPanel"
				 object:nil];
        isOpen = NO;
        iDocControll = 2;
	}
    
    g_AppController = self;
	
	return self;
}


// Override to ensure that the app is in the /Applications/ directory
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	// Offer to the move the Application if necessary.
	// Note that if the user chooses to move the application,
	// this call will never return. Therefore you can suppress
	// any first run UI by putting it after this call.
	
	// Oh, and don't do it for debug builds
    
#ifndef DEBUG
	PFMoveToApplicationsFolderIfNecessary();
#endif // !DEBUG
 //   [self newDocument:nil]; //add for version 1.1.0 to new a document when finishing launch
}






// Makes the toolbox panel appear and disappear
- (IBAction)showToolboxPanel:(id)sender
{
	SWToolboxController *toolboxPanel = [SWToolboxController sharedToolboxPanelController];
	if ([[toolboxPanel window] isVisible]) {
		[toolboxPanel close];
	} else {
		[toolboxPanel showWindow:self];
	}
    [self toolBoxItemSetState:nil];
}

- (IBAction)showPreferencePanel:(id)sender
{
	if (!preferenceController) {
		preferenceController = [[SWPreferenceController alloc] init];
	}
	[preferenceController showWindow:self];
}

- (void)killTheSheet:(id)sender
{
	for (NSWindow *window in [NSApp windows]) 
	{
		if ([window isSheet] && [[[window windowController] class] isEqualTo:[SWSizeWindowController class]]) 
		{
			// Close all the size sheets, but no other ones
			[window close];
			//[NSApp endSheet:window returnCode:NSCancelButton];
		}
	}
}

-(IBAction)showLayerManager:(id)sender
{
 	ETLayerController *layerPanel = [ETLayerController sharedLayerManagerController];
	if ([[layerPanel window] isVisible]) {
		[layerPanel close];
	} else {
		[layerPanel showWindow:self];
	}
    [self layerMenuItemSetState:nil];

}

/*#ifdef SPARKLE
// Called immediately before relaunching by Sparkle
- (void)updaterWillRelaunchApplication:(SUUpdater *)updater
{
	[self killTheSheet:nil];
}
#endif // SPARKLE*/

- (IBAction)quit:(id)sender
{
	[self killTheSheet:nil];
	[NSApp terminate:self];
}

// Creates a new instance of SWDocument based on the image in the clipboard
- (IBAction)newFromClipboard:(id)sender
{
	NSData *data = [SWImageTools readImageFromPasteboard:[NSPasteboard generalPasteboard]];
	if (data) 
	{
		[SWDocument setWillShowSheet:NO];
		[[NSDocumentController sharedDocumentController] newDocument:self];
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	if (action == @selector(newFromClipboard:)) {
		return ([SWImageTools readImageFromPasteboard:[NSPasteboard generalPasteboard]] != nil);

	}
	return YES;
}



- (void)application:(NSApplication *)theApplication openFiles:(NSArray *)filenames
{
    isOpenRecent = YES;
    if(fileNames)
        [fileNames release];
    fileNames = [[NSArray alloc] initWithArray:filenames];
    int nCount = [filenames count];
    int i = 0;
    for (i = 0; i < nCount; i++)
    {
        NSLog(@"file %d: %@", i, [filenames objectAtIndex:i]);
    }
    //    NSDocumentController *docController = [NSDocumentController sharedDocumentController];
    //    [docController appl];
    NSDocumentController *dController = [NSDocumentController sharedDocumentController];
    SWDocument *doc = [dController currentDocument];
    if(doc)
        [[doc windowForSheet] performClose:self];
    else
        [self _openRecent];
    //[dController newDocument:nil];
    //[dController op];
    //   [theApplication openFile:[file]];
    //  [self openItems:filenames addToRecents:NO]; //see later
}

- (void)_openRecent
{
    isOpenRecent = NO;
    NSDocumentController *dController = [NSDocumentController sharedDocumentController];
    
    NSURL* url = [[NSURL alloc] initFileURLWithPath:[fileNames objectAtIndex:0]];
    
    [dController  openDocumentWithContentsOfURL:url display: YES error:nil];
    [url release];
}



- (void)Closed:(NSNotification*)noti
{
    if(iDocControll == 0)
    {
        NSDocumentController *dc = [NSDocumentController sharedDocumentController];
        id curDoc = [dc currentDocument];
        [curDoc openAfter];
        [dc openDocument:nil];
        [[NSColorPanel sharedColorPanel] close];
        iDocControll = 2;
        isOpen = NO;
    }
    else if(iDocControll == 1)
    {
        NSDocumentController *dc = [NSDocumentController sharedDocumentController];
        id curDoc = [dc currentDocument];
        [curDoc openAfter];
        [dc newDocument:nil];
        [[NSColorPanel sharedColorPanel] close];
        iDocControll = 2;

    }
    else
        return;
}

-(IBAction)openDocument:(id)sender
{
   
    NSDocumentController *dc = [NSDocumentController sharedDocumentController];
    int nDocCount = [[dc documents] count];
    nDocCount = 0;
    id curDoc = [dc currentDocument];
    if (curDoc) 
    {
        isOpen = YES;
        iDocControll = 2;
        [curDoc setNewOrOpenDocument:NO];
        if([curDoc hasInsertedPc])
            [curDoc concernTheInsertPicture];
        if([curDoc m_bPasting])
            [curDoc concernTheInsertPicture];
        [[curDoc windowForSheet] performClose:self];
      
        //[curDoc openAfter];
        //NSDocumentController *dc = [NSDocumentController sharedDocumentController];
        //[dc openDocument:nil];
           
    }
    else 
    {
        [self makeLayerManagerKeyWindow:NO];
        [dc openDocument:self];
    }
    
//    
    

}

-(IBAction)newDocument:(id)sender
{
    NSDocumentController *dc = [NSDocumentController sharedDocumentController];
    int nDocCount = [[dc documents] count];
    nDocCount = 0;
    id curDoc = [dc currentDocument];
    if (curDoc) 
    {
        iDocControll = 1;
        [curDoc setNewOrOpenDocument:YES];
        if([curDoc hasInsertedPc])
            [curDoc concernTheInsertPicture];
        if([curDoc m_bPasting])
            [curDoc concernTheInsertPicture];
        [[curDoc windowForSheet] performClose:self];
       // [curDoc openAfter];
       // NSDocumentController *dc = [NSDocumentController sharedDocumentController];
        //[dc newDocument:nil];
       
    }
    else 
    {
        [dc newDocument:self];
    }
}

#pragma mark URLS to web pages/email addresses

////////////////////////////////////////////////////////////////////////////////
//////////		URLs to web pages/email addresses
////////////////////////////////////////////////////////////////////////////////


- (IBAction)donate:(id)sender
{	
	// Open the URL
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:
												   @"http://sourceforge.net/project/project_donations.php?group_id=191288"]];
}

- (IBAction)forums:(id)sender
{	
	// Open the URL
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://sourceforge.net/forum/?group_id=191288"]];
	
}

- (IBAction)contact:(id)sender
{	
	// Open the URL
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:soggywaffles@gmail.com"]];
}

- (void)dealloc
{
	[preferenceController release];
	[super dealloc];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return YES;    
}

-(void)makeLayerManagerKeyWindow:(BOOL)bKeyWindow
{
    ETLayerController *layerPanel = [ETLayerController sharedLayerManagerController];
    [[layerPanel window] orderBack:nil];
}

- (void)zoomItemSetState:(NSNotification*)noti
{
    if ([[noti object] floatValue] == 1.0) 
    {
        [ActualSizeItem setState:YES];
        [zoomInItem setState:NO];
        [zoomOutItem setState:NO];
        SWDocument *curDoc = [[NSDocumentController sharedDocumentController] currentDocument];
        [curDoc hideScrollView:NO];
    }
    else if ([[noti object] floatValue] > 1.0)
    {
        [ActualSizeItem setState:NO];
        [zoomInItem setState:YES];
        [zoomOutItem setState:NO]; 
        SWDocument *curDoc = [[NSDocumentController sharedDocumentController] currentDocument];
        [curDoc hideScrollView:NO];
    }
    else
    {
        [ActualSizeItem setState:NO];
        [zoomInItem setState:NO];
        [zoomOutItem setState:YES]; 
        SWDocument *curDoc = [[NSDocumentController sharedDocumentController] currentDocument];
        [curDoc hideScrollView:NO];
    }
}

- (void)layerMenuItemSetState:(NSNotification*)noti
{
    id layerPanel =  [ETLayerController sharedLayerManagerController];
    if([[layerPanel window] isVisible])
        [layerManagerMenuItem setState:YES];
    else
        [layerManagerMenuItem setState:NO];
    
}

- (void)toolBoxItemSetState:(NSNotification*)noti
{
    SWToolboxController *toolboxPanel = [SWToolboxController sharedToolboxPanelController];
    if ([[toolboxPanel window] isVisible]) {
        [toolBoxMenuItem setState:YES];
		//[toolboxPanel close];
	} else {
        [toolBoxMenuItem setState:NO];
		//[toolboxPanel showWindow:self];
	}
}

-(IBAction)addLayer:(id)sender
{
    ETLayerController *layerController = [ETLayerController sharedLayerManagerController];
    [layerController addLayer:sender];
}

-(IBAction)deleteSelectedLayers:(id)sender
{
    ETLayerController *layerController = [ETLayerController sharedLayerManagerController];
    [layerController deleteSelectedLayers:sender];
}

-(IBAction)deleteAllLayersButBackGround:(id)sender
{
    ETLayerController *layerController = [ETLayerController sharedLayerManagerController];
    [layerController deleteAllLayersButBackGround:sender];
    [deleteAllLayersButBackGround setEnabled:NO];
    [deleteSelectedLayers setEnabled:NO];
}

-(IBAction)LayerCombine:(id)sender
{
    ETLayerController *layerController = [ETLayerController sharedLayerManagerController];
    [layerController layerCombine:sender];
    
}

-(void)setLayerMenuState
{
    ETLayerController *layerController = [ETLayerController sharedLayerManagerController];
    NSIndexSet * selectedIndex = [[layerController m_collectionView] selectionIndexes];
    int nSelectedCount = [selectedIndex count];
    if(nSelectedCount > 1)
    {
        [deleteAllLayersButBackGround setEnabled:YES];
        [addLayer setEnabled:YES];
        if(nSelectedCount != [[layerController m_layerArrayDelegate] count])
        {
            [deleteSelectedLayers setEnabled:YES];
            //[m_btnDeleteLayer setEnabled:YES]; 
        }
        else
        {
            [deleteSelectedLayers setEnabled:NO];
            //[m_btnDeleteLayer setEnabled:NO]; 
        }
        [LayCombine setEnabled:YES];
    }
    else if(nSelectedCount == 1)
    {
        [addLayer setEnabled:YES];
        if([[layerController m_layerArrayDelegate] count] != 1)
        {
            [deleteSelectedLayers setEnabled:YES];
            [deleteAllLayersButBackGround setEnabled:YES];
            // [m_btnDeleteLayer setEnabled:YES]; 
        }
        else
        {
            [deleteSelectedLayers setEnabled:NO];
            [deleteAllLayersButBackGround setEnabled:NO];
            //[m_btnDeleteLayer setEnabled:NO]; 
        }  
        [LayCombine setEnabled:NO];
        
    }
}
@end
