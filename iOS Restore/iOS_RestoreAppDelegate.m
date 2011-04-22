//
//  iOS_RestoreAppDelegate.m
//  iOS Restore
//
//  Created by John Heaton on 4/15/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "iOS_RestoreAppDelegate.h"
#import "JRFWServerManifestGrabber.h"
#import "DeviceIdentification.h"
#import "MDDeviceManager.h"


@implementation iOS_RestoreAppDelegate

static NSImage *redOrbImage = nil;
static NSImage *greenOrbImage = nil;

@synthesize window;
@synthesize statusOrbView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    redOrbImage = [[NSImage imageNamed:@"red-orb.png"] retain];
    greenOrbImage = [[NSImage imageNamed:@"green-orb.png"] retain];
    
    selectedTab = 0;
    
    downloadedServerInfo = NO;
    [almightyRestoreButton setEnabled:NO];
    restoring = NO;
    
    restoreController = [JRRestoreController sharedInstance];
    restoreController.delegate = self;
    
    [connectedDeviceLabel setStringValue:@"No Device Connected"];
    
   // replacementLabelPosition = [connectedDeviceLabel frame].origin;
    
    statusLabel = [[NSTextField alloc] initWithFrame:NSMakeRect([restoreProgressBar frame].origin.x, [restoreProgressBar frame].origin.y + [restoreProgressBar frame].size.height + [connectedDeviceLabel frame].size.height + 55, [window frame].size.width - 10, [connectedDeviceLabel frame].size.height + 3)];
    [statusLabel setBackgroundColor:[NSColor clearColor]];
    [statusLabel setBordered:NO];
    [statusLabel setEditable:NO];
    
    [localIPSWPathField setDelegate:self];
    
    [window setContentBorderThickness:25.0 forEdge:NSMinYEdge];
    [window setMovableByWindowBackground:YES];
    
    [statusOrbView setImage:redOrbImage];
    
    [restoreProgressBar setMinValue:0];
    [restoreProgressBar setMaxValue:100.0];
    
    manifestGrabber = [[JRFWServerManifestGrabber alloc] init];
    manifestGrabber.delegate = self;
    
    _currentServerManifest = nil;
    
    [[MDNotificationCenter sharedInstance] addListener:self];
}

- (void)labelDeviceAs:(NSString *)name {
    [connectedDeviceLabel setStringValue:name];
    [self populateServerFirmwarePopupBox];
}

- (void)updateDeviceLabelForDetachedDevice {
    [statusOrbView setImage:redOrbImage];
    [self labelDeviceAs:@"No Device Connected"];
    [almightyRestoreButton setEnabled:NO];
    [self populateServerFirmwarePopupBox];
}

- (void)updateDeviceLabelForProductID:(uint16_t)pid deviceID:(uint32_t)did isRestore:(BOOL)isRestore {
    [statusOrbView setImage:greenOrbImage];
    [self labelDeviceAs:iOSRestoreGetDeviceConnectionType(pid, did, isRestore)];
    
    [self populateServerFirmwarePopupBox];
    
    switch(selectedTab) {
        case 1: {
            if([[[serverFWChoiceButton itemAtIndex:0] title] isEqualToString:@"None Available"])
                [almightyRestoreButton setEnabled:NO];
            else
                [almightyRestoreButton setEnabled:YES];
        }
    }
}
                      
- (void)normalDeviceAttached:(AMDeviceRef)device {
    [self updateDeviceLabelForProductID:AMDeviceUSBProductID(device) deviceID:0 isRestore:NO];
}

- (void)normalDeviceDetached:(AMDeviceRef)device {
    [self updateDeviceLabelForDetachedDevice];
}

- (void)normalDeviceConnectionError {
    [self updateDeviceLabelForDetachedDevice];
}

- (void)restoreDeviceAttached:(AMRestoreModeDeviceRef)device {
    [self updateDeviceLabelForProductID:AMDeviceUSBProductID((AMDeviceRef)device) deviceID:0 isRestore:YES];
}

- (void)restoreDeviceDetached:(AMRestoreModeDeviceRef)device {
    [self updateDeviceLabelForDetachedDevice];
}

- (void)recoveryDeviceAttached:(AMRecoveryModeDeviceRef)device {
    [self updateDeviceLabelForProductID:AMRecoveryModeDeviceGetProductID(device) deviceID:AMRecoveryModeDeviceGetProductType(device) isRestore:NO];
}

- (void)recoveryDeviceDetached:(AMRecoveryModeDeviceRef)device {
    [self updateDeviceLabelForDetachedDevice];
}

- (void)dfuDeviceAttached:(AMDFUModeDeviceRef)device {
    [self updateDeviceLabelForProductID:AMDFUModeDeviceGetProductID(device) deviceID:AMDFUModeDeviceGetProductType(device) isRestore:NO];
}

- (void)dfuDeviceDetached:(AMDFUModeDeviceRef)device {
    [self updateDeviceLabelForDetachedDevice];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [serverDownloadBar stopAnimation:self];
    [sheet orderOut:nil];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    selectedTab = [tabView indexOfTabViewItem:tabViewItem];
    
    if(selectedTab == 0) {
        if([[NSFileManager defaultManager] fileExistsAtPath:[localIPSWPathField stringValue]] 
           && [[MDDeviceManager sharedInstance] currentDeviceType] != NULL)
            [almightyRestoreButton setEnabled:YES];
        else
            [almightyRestoreButton setEnabled:NO];
    } else if(selectedTab == 1) {
        if(!downloadedServerInfo) {
            [NSApp beginSheet:serverDownloadSheet modalForWindow:window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
            [serverDownloadBar startAnimation:self];
            [manifestGrabber performSelector:@selector(beginGrabbing) withObject:nil afterDelay:0.0];
        } else {
            if(![[[restoreTypeTabView selectedTabViewItem] label] isEqualToString:@"None Available"] && [[MDDeviceManager sharedInstance] currentDeviceType] != NULL) {
                [almightyRestoreButton setEnabled:YES];
            }
        }
    }
}

- (void)populateServerFirmwarePopupBox {
    [serverFWChoiceButton removeAllItems];
    
    if(![[MDDeviceManager sharedInstance] deviceIsPluggedIn] || _currentServerManifest == nil) {
        [serverFWChoiceButton addItemWithTitle:@"None Available"];
        [almightyRestoreButton setEnabled:NO];
        return;
    }
    
    APPLE_MOBILE_DEVICE *deviceType = [[MDDeviceManager sharedInstance] currentDeviceType];
    
    for(NSString *firmwareVersion in [[_currentServerManifest objectForKey:[NSString stringWithUTF8String:deviceType->model]] allKeys]) {
        [serverFWChoiceButton addItemWithTitle:firmwareVersion];
    }
    
    if(selectedTab == 1) {
        [almightyRestoreButton setEnabled:YES];
    }
}

- (void)serverManifestGrabberDidFinishWithManifest:(NSDictionary *)manifest {
    [NSApp endSheet:serverDownloadSheet];
    downloadedServerInfo = YES;
    
    if(_currentServerManifest != nil) {
        [_currentServerManifest release];
    } 
    
    _currentServerManifest = [manifest retain];
    
    // populate popup box
    [self populateServerFirmwarePopupBox];
}

- (void)serverManifestGrabberFailedWithErrorDescription:(NSString *)errorDescription {
    [NSApp endSheet:serverDownloadSheet];
    [restoreTypeTabView selectTabViewItemAtIndex:0];
}

- (IBAction)browseForIPSW:(id)sender {
    NSOpenPanel *browser = [NSOpenPanel openPanel];
    [browser setAllowsMultipleSelection:NO];
    [browser setAllowedFileTypes:[NSArray arrayWithObject:@"ipsw"]];
    [browser setAllowsOtherFileTypes:NO];
    [browser setCanChooseFiles:YES];
    [browser setTitle:@"Please choose the firmware file you wish to restore to."];
    if([[MDDeviceManager sharedInstance] currentDeviceType] != NULL)
        [browser setDirectoryURL:[NSURL URLWithString:[[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"iTunes"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ Software Updates", iOSRestoreGetDeviceClassName([[MDDeviceManager sharedInstance] currentDeviceType])]]]];
    else
        [browser setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
    [browser setDelegate:self];
    
    [browser beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if(result != NSOKButton)
            [localIPSWPathField setStringValue:nil];
        else {
            if([[MDDeviceManager sharedInstance] currentDeviceType] != NULL) {
                if(!restoring) 
                    [almightyRestoreButton setEnabled:YES];
            }
        }
    }];
}

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError {
    [localIPSWPathField setStringValue:[url relativePath]];
    
    return YES;
}

- (IBAction)attemptRestore:(id)sender {
    // first step, unzip. NO. check for our own errors and animate window
    
    if(selectedTab == 0) {
        if(![[NSFileManager defaultManager] fileExistsAtPath:[localIPSWPathField stringValue]]) {
            NSBeginAlertSheet(@"File Not Found", @"OK", nil, nil, nil, nil, nil, nil, NULL, @"The firmware file could not be found");
        }
        
        // start local restore
        restoreController.firmwareLocation = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", [localIPSWPathField stringValue]]];
        restoreController.mustDownloadIPSW = NO;
        restoreController.firmwareVersion = [[serverFWChoiceButton selectedItem] title];
    } else if(selectedTab == 1) {
        // download restore
        restoreController.firmwareLocation = [NSURL URLWithString:[[[_currentServerManifest objectForKey:[NSString stringWithUTF8String:[[MDDeviceManager sharedInstance] currentDeviceType]->model]] objectForKey:[[serverFWChoiceButton selectedItem] title]] objectForKey:@"URL"]];
        restoreController.mustDownloadIPSW = YES;
        restoreController.firmwareVersion = [[serverFWChoiceButton selectedItem] title];
    }
    
    [restoreController beginRestoreProcess];
}

- (IBAction)serverFirmwareSelectionChange:(id)sender {
    if([[MDDeviceManager sharedInstance] deviceIsPluggedIn] && ![[[sender selectedItem] title] isEqualToString:@"None Available"])
        [almightyRestoreButton setEnabled:YES];
}

- (void)resizeWindowForRestore:(BOOL)restore {
    NSInteger sizeDifference = 65;
    restoring = restore;
    
    if(restore) {
        [window setFrame:NSMakeRect([window frame].origin.x, [window frame].origin.y - sizeDifference, [window frame].size.width, [window frame].size.height + sizeDifference) display:YES animate:YES];
        [mainView addSubview:statusLabel];
        
        [restoreProgressBar startAnimation:nil];
        [almightyRestoreButton setEnabled:NO];
    } else {
        [window setFrame:NSMakeRect([window frame].origin.x, [window frame].origin.y + sizeDifference, [window frame].size.width, [window frame].size.height - sizeDifference) display:YES animate:YES];
        [statusLabel removeFromSuperview];
        
        [restoreProgressBar stopAnimation:nil];
        [almightyRestoreButton setEnabled:YES];
    }
}

- (void)restoreControllerBeganRestoring {
    [self resizeWindowForRestore:YES];
}

- (void)restoreControllerFailedToRestoreWithDescription:(NSString *)description {
    [self resizeWindowForRestore:NO];
}

- (void)restoreControllerBeganRestoreOperationNamed:(NSString *)operationName isIndeterminate:(BOOL)isIndetermindate {
    [restoreProgressBar setIndeterminate:isIndetermindate];
    [restoreProgressBar setDoubleValue:0.0];
    
   [statusLabel setStringValue:operationName];
}

- (void)restoreControllerIncreasedCurrentOperationProgress:(CGFloat)newProgress {
   // [restoreProgressBar setDoubleValue:newProgress];
    double currentProgress = [restoreProgressBar doubleValue];
    int difference = (newProgress - currentProgress);
    
    for(int i=0;i<difference;++i) {
        [restoreProgressBar incrementBy:1];
    }
    
    [restoreProgressBar setDoubleValue:newProgress];
}

- (void)restoreControllerCompletedRestoreSuccessfully {
    [self resizeWindowForRestore:NO];
}

- (void)dealloc {
    [manifestGrabber release];
    [redOrbImage release];
    [greenOrbImage release];
    [statusLabel release];
    
    [super dealloc];
}

@end
