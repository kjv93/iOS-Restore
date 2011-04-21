//
//  JRIPSWExtractionOperation.h
//  iOS Restore
//
//  Created by John Heaton on 4/21/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRRestoreOperation.h"
#import "JRIPSWUnzipper.h"


@interface JRIPSWExtractionOperation : JRRestoreOperation <JRIPSWUnzipperDelegate> {
@private
    NSString *_ipswPath;
}

- (id)initWithDelegate:(id)delegate ipswPath:(NSString *)ipswPath;

@end
