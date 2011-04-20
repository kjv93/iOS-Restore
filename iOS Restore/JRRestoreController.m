//
//  JRRestoreController.m
//  iOS Restore
//
//  Created by John Heaton on 4/15/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "JRRestoreController.h"


@interface JRRestoreController (PrivateJellyBeans)

- (void)_initiateUnzippingOfIPSW;

@end

@implementation JRRestoreController

static JRRestoreController *sharedJRRestoreController = nil;

@synthesize delegate=_delegate;
@synthesize firmwareFilePath=_ipswLocation;
@synthesize firmwareVersion=_version;
@synthesize currentState=_currentState;

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
    
    [NSThread detachNewThreadSelector:@selector(_initiateUnzippingOfIPSW) toTarget:self withObject:nil];
    
    return YES;
}

- (void)_initiateUnzippingOfIPSW {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [self sendDelegateMessage:@selector(restoreControllerBeganRestoreOperationNamed:) withObject:@"Unzipping IPSW"];
    
    JRIPSWUnzipper *unzipper = [[JRIPSWUnzipper alloc] initWithIPSWPath:_ipswLocation inflationPath:JRIPSWPreferredInflationDirectoryForFirmware(_version)];
    
    [unzipper setDelegate:self];
    [unzipper beginUnzipping];
    
    [pool release];
}

- (void)ipswUnzipperFailedToUnzip:(JRIPSWUnzipper *)unzipper {
    [self sendDelegateMessage:@selector(restoreControllerFailedToRestoreWithDescription:errorStatus:) withObject:@"Failed to unzip firmware file." anotherObject:(id)kAMStatusFailure];
}

- (void)ipswUnzipperFinishedUnzipping:(JRIPSWUnzipper *)unzipper {
    [self sendDelegateMessage:<#(SEL)#> withObject:<#(id)#>];
}

- (void)dealloc {
    [super dealloc];
}

@end
