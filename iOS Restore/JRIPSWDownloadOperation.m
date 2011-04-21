//
//  JRIPSWDownloadOperation.m
//  iOS Restore
//
//  Created by John Heaton on 4/21/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "JRIPSWDownloadOperation.h"


@implementation JRIPSWDownloadOperation

- (id)initWithDelegate:(id<JRRestoreOperationDelegate>)delegate ipswURL:(NSURL *)ipswURL {
    if(!delegate || !ipswURL) return nil;
    
    if((self = [super initWithDelegate:delegate]) != nil) {
        _ipswURL = [ipswURL retain];
    }
    
    return self;
}

- (void)beginRestoreOperation {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_ipswURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    NSURLDownload *download = [[NSURLDownload alloc] initWithRequest:request delegate:self];
}

- (BOOL)isIndeterminateOperation {
    return NO;
}

- (NSString *)statusString {
    return @"Downloading IPSW...";
}

- (void)dealloc {
    [_ipswURL release];
    [super dealloc];
}

@end
