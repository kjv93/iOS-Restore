//
//  JRRestoreController.h
//  iOS Restore
//
//  Created by John Heaton on 4/15/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRRestoreOperation.h"
#import "MobileDevice.h"

enum {
    kRestoreStateUnzippingIPSW = 0,
    kRestoreStateWaitingForNormalDevice = 1,
    kRestoreStateWaitingForRestoreDevice = 2,
    kRestoreStateWaitingForRecoveryDevie = 3,
    kRestoreStateWaitingForDFUDevice = 4,
    kRestoreStateSettingUpSignedFirmware = 5,
    kRestoreStateDownloadingIPSW = 6,
    kRestoreStateRestoringDevice = 7
};
typedef NSInteger JRRestoreState;

@protocol JRRestoreControllerDelegate;

@interface JRRestoreController : NSObject <JRRestoreOperationDelegate> {
@private
    id<JRRestoreControllerDelegate> _delegate;
    BOOL _started, _mustDownloadIPSW;
    NSURL *_ipswLocation;
    NSString *_version;
    JRRestoreState _currentState;
    NSOperationQueue *restoreQueue;
    id _currentOperation;
}

+ (JRRestoreController *)sharedInstance;

- (BOOL)beginRestoreProcess; // only call if -started is NO
- (void)cancel;

@property (assign) id<JRRestoreControllerDelegate> delegate;
@property (retain) NSURL *firmwareLocation;
@property (assign) NSString *firmwareVersion;
@property (readonly) JRRestoreState currentState; 
@property (readonly) BOOL started;
@property (assign) BOOL mustDownloadIPSW;

@end


@protocol JRRestoreControllerDelegate <NSObject>

@optional
- (void)restoreControllerBeganRestoring;
- (void)restoreControllerFailedToRestoreWithDescription:(NSString *)description;
- (void)restoreControllerBeganRestoreOperationNamed:(NSString *)operationName isIndeterminate:(BOOL)isIndetermindate;
- (void)restoreControllerIncreasedCurrentOperationProgress:(CGFloat)newProgress;
- (void)restoreControllerCompletedRestoreSuccessfully;

@end