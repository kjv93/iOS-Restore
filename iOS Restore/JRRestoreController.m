//
//  JRRestoreController.m
//  iOS Restore
//
//  Created by John Heaton on 4/15/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "JRRestoreController.h"
#import "MDDeviceManager.h"
#import "MDNotificationCenter.h"
#import "JRIPSWDownloadOperation.h"
#import "JRIPSWExtractionOperation.h"


@implementation JRRestoreController

static JRRestoreController *sharedJRRestoreController = nil;

@synthesize delegate=_delegate;
@synthesize firmwareLocation=_ipswLocation;
@synthesize firmwareVersion=_version;
@synthesize currentState=_currentState;
@synthesize started=_started;
@synthesize mustDownloadIPSW=_mustDownloadIPSW;

+ (JRRestoreController *)sharedInstance {
    @synchronized(self) {
        if (!sharedJRRestoreController) {
            sharedJRRestoreController = [[self alloc] init];
        }
    }
    
	return sharedJRRestoreController;
}

- (id)init {
    self = [super init];
    if (self) {
        _started = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAttached) name:MDNotificationDeviceAttached object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDetached) name:MDNotificationDeviceDetached object:nil];
        
        restoreQueue = [[NSOperationQueue alloc] init];
        [restoreQueue setMaxConcurrentOperationCount:1];
        _currentOperation = nil;
    }
    
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

- (oneway void)release {}

- (id)retain {
    return sharedJRRestoreController;
}

- (id)autorelease {
    return sharedJRRestoreController;
}

- (void)sendDelegateMessage:(SEL)message withObject:(id)object {
    if(_delegate != nil && [_delegate respondsToSelector:message]) 
        [_delegate performSelector:message withObject:object];
}

- (void)sendDelegateMessage:(SEL)message withObject:(id)object anotherObject:(id)object2 {
    if(_delegate != nil && [_delegate respondsToSelector:message]) 
        [_delegate performSelector:message withObject:object withObject:object2];
}

- (BOOL)beginRestoreProcess {
    if(_started || !_delegate || !_ipswLocation)
        return NO;
    
    [self sendDelegateMessage:@selector(restoreControllerBeganRestoring) withObject:nil];
    _started = YES;
    
    [NSThread detachNewThreadSelector:@selector(_sortOutAndStart) toTarget:self withObject:nil];
    
    return YES;
}

- (void)deviceAttached {
    
}

- (void)deviceDetached {
    switch(_currentState) {
        case kRestoreStateDownloadingIPSW: {
            [self sendDelegateMessage:@selector(restoreControllerFailedToRestoreWithDescription:) withObject:@"Device unplugged. Restore bailed out."];
        } break;
    }
}

- (void)cancel {
    
}

- (void)restoreOperationBegan:(id)restoreOperation {
    [self sendDelegateMessage:@selector(restoreControllerBeganRestoreOperationNamed:isIndeterminate:) withObject:[_currentOperation statusString] anotherObject:(id)[_currentOperation isIndeterminateOperation]];
}

- (void)restoreOperation:(id)restoreOperation updatedToProgress:(CGFloat)progress {
    if(_delegate && [_delegate respondsToSelector:@selector(restoreControllerIncreasedCurrentOperationProgress:)]) {
        [_delegate restoreControllerIncreasedCurrentOperationProgress:progress];
    }
}

- (void)restoreOperationFinished:(id)restoreOperation {
    // start up the next one folks
    [restoreOperation release];
    
    switch(_currentState) {
        case kRestoreStateDownloadingIPSW: {
            _currentState = kRestoreStateUnzippingIPSW;
            
            _currentOperation = [[JRIPSWExtractionOperation alloc] initWithDelegate:self ipswPath:[_ipswLocation relativePath]];
            
            [restoreQueue addOperation:_currentOperation];
        } break;
        case kRestoreStateUnzippingIPSW: {
            [self sendDelegateMessage:@selector(restoreControllerCompletedRestoreSuccessfully) withObject:nil];
        }
    }
}

- (void)restoreOperation:(id)restoreOperation failedWithErrorDescription:(NSString *)errorDescription {
    [restoreOperation release];
    
    [self sendDelegateMessage:@selector(restoreControllerFailedToRestoreWithDescription) withObject:errorDescription];
}

- (void)_sortOutAndStart {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if(_mustDownloadIPSW) {
        _currentState = kRestoreStateDownloadingIPSW;
        
        _currentOperation = [[JRIPSWDownloadOperation alloc] initWithDelegate:self ipswURL:_ipswLocation];
        
        [restoreQueue addOperation:_currentOperation];
    } else {
        _currentState = kRestoreStateUnzippingIPSW;
        
        _currentOperation = [[JRIPSWExtractionOperation alloc] initWithDelegate:self ipswPath:[_ipswLocation relativePath]];
        
        [restoreQueue addOperation:_currentOperation];
    }
    
    [pool release];
}

- (void)dealloc {
    [restoreQueue release];
    [super dealloc];
}

@end
