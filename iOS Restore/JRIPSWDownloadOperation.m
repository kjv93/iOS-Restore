//
//  JRIPSWDownloadOperation.m
//  iOS Restore
//
//  Created by John Heaton on 4/21/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "JRIPSWDownloadOperation.h"
#import "JRIPSWUnzipper.h"
#import "DeviceIdentification.h"
#import "MDDeviceManager.h"


static NSString *JRIPSWDownloadOperationErrorDescription = @"Failed to download IPSW";

@implementation JRIPSWDownloadOperation

- (id)initWithDelegate:(id<JRRestoreOperationDelegate>)delegate ipswURL:(NSURL *)ipswURL {
    if(!delegate || !ipswURL) return nil;
    
    if((self = [super initWithDelegate:delegate]) != nil) {
        _ipswURL = [ipswURL retain];
        
        _filePath = [[NSString stringWithFormat:@"%@/Library/iTunes/%@ Software Updates/%@", NSHomeDirectory(), iOSRestoreGetDeviceClassName([[MDDeviceManager sharedInstance] currentDeviceType]), [[_ipswURL relativeString] lastPathComponent]] retain];
        
        BOOL isDir;
        if(![[NSFileManager defaultManager] fileExistsAtPath:[_filePath stringByDeletingLastPathComponent] isDirectory:&isDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[_filePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
        [[NSFileManager defaultManager] createFileAtPath:_filePath contents:nil attributes:nil];
        _fileHandle = [[NSFileHandle fileHandleForWritingAtPath:_filePath] retain];
    }
    
    return self;
}

- (void)beginRestoreOperation {
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:_ipswURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15] autorelease];
    _download = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    CFRunLoopRun();
}

- (BOOL)isIndeterminateOperation {
    return NO;
}

- (void)cancel {
    [_download cancel];
    [self failWithErrorString:@"Download was cancelled."];
}

- (NSString *)statusString {
    return [NSString stringWithFormat:@"Downloading IPSW: %@", [[_ipswURL relativeString] lastPathComponent]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _dlSize = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_fileHandle seekToEndOfFile];
    [_fileHandle writeData:data];
    
    _dlRecvd += [data length];
    [self updateProgress:((_dlRecvd * 100)/_dlSize)];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
    [self failWithErrorString:JRIPSWDownloadOperationErrorDescription];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    CFRunLoopStop(CFRunLoopGetCurrent());
    [self reportFinished];
}

- (void)dealloc {
    [_filePath release];
    [_fileHandle release];
    [_ipswURL release];
    [_download release];
    [super dealloc];
}

@end
