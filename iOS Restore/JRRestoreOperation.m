//
//  JRRestoreOperation.m
//  iOS Restore
//
//  Created by John Heaton on 4/21/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "JRRestoreOperation.h"


@interface JRRestoreOperation (DelegationHelper)

- (void)sendDelegateMessage:(SEL)message withArg:(id)arg secondArg:(id)secondArg;

@end

@implementation JRRestoreOperation

@synthesize delegate=_delegate;
@synthesize progress=_progress;

- (id)initWithDelegate:(id)delegate {
    if(!delegate) return nil;
    
    if((self = [super init]) != nil) {
        _progress = 0.0f;
        _delegate = delegate;
    }
    
    return self;
}

- (void)sendDelegateMessage:(SEL)message withArg:(id)arg secondArg:(id)secondArg {
    if(_delegate && [_delegate respondsToSelector:message]) {
        [_delegate performSelector:message withObject:arg withObject:secondArg];
    }
}

- (void)start {
    [self sendDelegateMessage:@selector(restoreOperationBegan:) withArg:self secondArg:nil];
    [self beginRestoreOperation];
}

- (void)cancel {
    
}

- (void)beginRestoreOperation {
    // Subclasses override for functionality
}

- (void)updateProgress:(CGFloat)progress {
    _progress = progress;
    if(_delegate && [_delegate respondsToSelector:@selector(restoreOperation:updatedToProgress:)]) {
        [_delegate restoreOperation:self updatedToProgress:_progress];
    }
}

- (void)failWithErrorString:(NSString *)errStr {
    [self sendDelegateMessage:@selector(restoreOperation:failedWithErrorDescription:) withArg:self secondArg:errStr];
}

- (void)reportFinished {
    [self sendDelegateMessage:@selector(restoreOperationFinished:) withArg:self secondArg:nil];
}

- (BOOL)isIndeterminateOperation {
    return YES;
}

- (NSString *)statusString {
    return @"Restoring...";
}

@end
