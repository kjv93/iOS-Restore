//
//  JRIPSWExtractionOperation.m
//  iOS Restore
//
//  Created by John Heaton on 4/21/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "JRIPSWExtractionOperation.h"

@implementation JRIPSWExtractionOperation

static NSString *JRIPSWExtractionOperationErrorDescription = @"Failed to unzip firmware file.";

- (id)initWithDelegate:(id)delegate ipswPath:(NSString *)ipswPath {
    if(!delegate || !ipswPath) return nil;
    
    if((self = [super initWithDelegate:delegate]) != nil) {
        _ipswPath = [ipswPath copy];
        _cancelled = NO;
    }
    
    return self;
}

- (void)beginRestoreOperation {
    JRIPSWUnzipper *unzipper = [[JRIPSWUnzipper alloc] initWithIPSWPath:_ipswPath inflationPath:JRIPSWPreferredInflationDirectoryForFirmware];
    if(!unzipper)
        [self failWithErrorString:JRIPSWExtractionOperationErrorDescription];
    
    [unzipper setDelegate:self];
    [unzipper beginUnzipping];
}

- (void)cancel {
    _cancelled = YES;
}

- (void)ipswUnzipperFailedToUnzip:(JRIPSWUnzipper *)unzipper {
    [unzipper release];
    
    if(_cancelled) return;
    
    [self failWithErrorString:JRIPSWExtractionOperationErrorDescription];
}

- (void)ipswUnzipperFinishedUnzipping:(JRIPSWUnzipper *)unzipper {
    [unzipper release];
    
    if(_cancelled) return;
    
    [self reportFinished];
}

- (NSString *)statusString {
    return @"Unzipping IPSW...";
}

- (void)dealloc {
    [_ipswPath release];
    [super dealloc];
}

@end
