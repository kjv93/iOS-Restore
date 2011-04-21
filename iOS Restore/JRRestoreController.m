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
    
}

- (void)cancel {
    
}

- (void)_sortOutAndStart {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Really, we need to download the ipsw before anything.
    
    
    [pool release];
}

- (void)dealloc {
    [super dealloc];
}

@end
