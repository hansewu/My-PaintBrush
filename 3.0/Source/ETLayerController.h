//
//  ETLayerController.h
//  Paintbrush
//
//  Created by Pisces Hsu on 12-9-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ETLayerProperty.h"
#import "ETCollectView.h"
//#import "ETCollectionView.h"


@interface ETLayerController : NSWindowController <NSCollectionViewDelegate,NSWindowDelegate>
{
    IBOutlet NSCollectionView *m_collectionView;
    IBOutlet NSButton *m_addLayer;
    IBOutlet NSButton *m_deleteLayer;
    IBOutlet NSSlider *m_opacitySlider;
    IBOutlet NSTextField *m_opacityField;
    IBOutlet NSWindow* m_Window;
    IBOutlet NSButton* m_btnDeleteLayer;
    
    
    IBOutlet NSMenuItem* m_AddLayer;
    IBOutlet NSMenuItem* m_DeleteLayer;
    IBOutlet NSMenuItem* m_MergeLayers;
    IBOutlet NSMenuItem* m_DeleteAll;
    //IBOutlet NSSlider* m_AlphaSetting;
    
    IBOutlet NSArrayController *m_layerArrayController;
    
    NSMutableArray * m_layers;
    id delegate;
    id m_layerArrayDelegate;
    int m_nSelectedLayerOrder;
    NSIndexSet* dragIndexSet;
    int nDropIndex;
    
}

@property(retain) id delegate;
@property(retain) id m_layerArrayDelegate;
@property(retain) id m_collectionView;
-(NSCollectionView *)getCollectionView;
-(IBAction)addLayer:(id)sender;
-(IBAction)layerCombine:(id)sender;
-(IBAction)deleteSelectedLayers:(id)sender;
-(IBAction)deleteAllLayersButBackGround:(id)sender;
-(IBAction)deleteAllLayersButBackGround:(id)sender;
-(void)deleteAllLayers;//used to clear all layers for new document;
-(IBAction)alphaValueChanged:(id)sender;
-(NSRect)getWindowRect;
-(void)EnableAdd_DeleteLayerBtn:(BOOL)bEnable;
+(id)sharedLayerManagerController;
-(void)addLayerProps:(ETLayerProperty *)props atIndex:(int)index;
-(void)deleteLayerProp:(ETLayerProperty*)props;
-(NSInteger)getSelectedIndex;
-(void)setAddBtnState:(BOOL)state;

@end
