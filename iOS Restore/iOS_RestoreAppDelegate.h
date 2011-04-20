//
//  iOS_RestoreAppDelegate.h
//  iOS Restore
//
//  Created by John Heaton on 4/15/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MDListener.h"
#import "MDNotificationCenter.h"
#import "JRFWServerManifestGrabber.h"
#import "JRIPSWUnzipper.h"


@interface iOS_RestoreAppDelegate : NSObject <NSApplicationDelegate, MDListener, NSTabViewDelegate, JRFWServerManifestGrabberDelegate, JRIPSWUnzipperDelegate, NSTextFieldDelegate, NSOpenSavePanelDelegate> {
@private
    NSWindow *window;
    NSImageView *statusOrbView;
    IBOutlet NSTextField *connectedDeviceLabel, *localIPSWPathField, *statusLabel;
    IBOutlet NSPanel *serverDownloadSheet;
    BOOL downloadedServerInfo;
    IBOutlet NSProgressIndicator *serverDownloadBar, *restoreProgressBar;
    JRFWServerManifestGrabber *manifestGrabber;
    IBOutlet NSPopUpButton *serverFWChoiceButton;
    IBOutlet NSTabView *restoreTypeTabView;
    NSDictionary *_currentServerManifest;
    IBOutlet NSButton *almightyRestoreButton;
    NSInteger selectedTab;
   // NSPoint replacementLabelPosition;
    IBOutlet NSView *mainView;
}

- (void)updateDeviceLabelForDetachedDevice;
- (void)updateDeviceLabelForProductID:(uint16_t)pid deviceID:(uint32_t)did isRestore:(BOOL)isRestore;
- (void)populateServerFirmwarePopupBox;

- (IBAction)browseForIPSW:(id)sender;
- (IBAction)serverFirmwareSelectionChange:(id)sender;
- (IBAction)attemptRestore:(id)sender;

- (void)resizeWindowForRestore:(BOOL)restore;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSImageView *statusOrbView;

@end
