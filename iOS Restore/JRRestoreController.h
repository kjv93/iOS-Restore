//
//  JRRestoreController.h
//  iOS Restore
//
//  Created by John Heaton on 4/15/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRIPSWUnzipper.h"
#import "MDListener.h"
#import "JRIPSWUnzipper.h"


enum {
    kRestoreStateUnzippingIPSW = 0,
    kRestoreStateWaitingForNormalDevice = 1,
    kRestoreStateWaitingForRestoreDevice = 2,
    kRestoreStateWaitingForRecoveryDevie = 3,
    kRestoreStateWaitingForDFUDevice = 4,
    kRestoreStateSettingUpSignedFirmware = 5
};
typedef NSInteger JRRestoreState;

@protocol JRRestoreControllerDelegate;

@interface JRRestoreController : NSObject <MDListener, JRIPSWUnzipperDelegate> {
@private
    id<JRRestoreControllerDelegate> _delegate;
    BOOL _started;
    NSString *_ipswLocation, *_version;
    JRRestoreState _currentState;
}

+ (JRRestoreController *)sharedInstance;

- (BOOL)beginRestoreProcess;

@property (assign) id<JRRestoreControllerDelegate> delegate;
@property (assign) NSString *firmwareFilePath;
@property (assign) NSString *firmwareVersion;
@property (readonly) JRRestoreState currentState; 

@end


@protocol JRRestoreControllerDelegate <NSObject>

@optional
- (void)restoreControllerBeganRestoring;
- (void)restoreControllerFailedToRestoreWithDescription:(NSString *)description errorStatus:(AMStatus)errorStatus;
- (void)restoreControllerBeganRestoreOperationNamed:(NSString *)operationName;
- (void)restoreControllerIncreasedCurrentOperationProgress:(NSInteger)newProgress;
- (void)restoreControllerCompletedRestoreSuccessfully;

@end