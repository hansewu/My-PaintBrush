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
//#import "SWDocument.h"
@class SWPreferenceController;
@class SWToolboxController;

extern NSString * const kSWUndoKey;

@interface SWAppController : NSObject
{
	SWPreferenceController *preferenceController;
    int iDocControll;
    id docuDeleget;
    BOOL isOpen ;
    IBOutlet NSMenuItem* zoomInItem;
    IBOutlet NSMenuItem* zoomOutItem;
    IBOutlet NSMenuItem* ActualSizeItem;
    IBOutlet NSMenuItem* toolBoxMenuItem;
    IBOutlet NSMenuItem* layerManagerMenuItem;
    IBOutlet NSMenuItem* addLayer;
    IBOutlet NSMenuItem* deleteSelectedLayers;
    IBOutlet NSMenuItem* deleteAllLayersButBackGround;
    IBOutlet NSMenuItem* LayCombine;
    BOOL isOpenRecent;
    NSArray* fileNames;
}
@property BOOL isOpen;
@property int iDocControll;
@property BOOL isOpenRecent;
- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)showToolboxPanel:(id)sender;
- (void)_openRecent;
//- (IBAction)showGridPanel:(id)sender;

// A few methods to open a web page in the user's browser of choice
- (IBAction)donate:(id)sender;
- (IBAction)forums:(id)sender;
- (IBAction)contact:(id)sender;

// Overrides "Quit" to remove a sheet, if present
- (IBAction)quit:(id)sender;
- (IBAction)newFromClipboard:(id)sender;
-(IBAction)showLayerManager:(id)sender;
-(void)makeLayerManagerKeyWindow:(BOOL)bKeyWindow;

-(IBAction)openDocument:(id)sender;
-(IBAction)newDocument:(id)sender;
- (void)layerMenuItemSetState:(NSNotification*)noti;

- (void)toolBoxItemSetState:(NSNotification*)noti;
-(void)setLayerMenuState;
@end
