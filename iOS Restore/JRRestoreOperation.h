//
//  JRRestoreOperation.h
//  iOS Restore
//
//  Created by John Heaton on 4/21/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JRRestoreOperationDelegate;

@interface JRRestoreOperation : NSOperation {
@private
    id <JRRestoreOperationDelegate> _delegate;
    CGFloat _progress;
}

- (id)initWithDelegate:(id)delegate; // Should always be JRRestoreController, but doesn't NEED to be if you're implementing things yourself

- (void)beginRestoreOperation; // Subclasses: use this instead of -start
- (void)updateProgress:(CGFloat)progress; // Will send delegate message and update Ivar
- (void)failWithErrorString:(NSString *)errStr; // Will send delegate message
- (void)reportFinished; // Will send the delegate message
- (void)cancel; // Emergencies only please :)
- (BOOL)isIndeterminateOperation; // DEFAULT=YES; Subclasses: override this if your operation has displayable progress
- (NSString *)statusString; // DEFAULT=@"Restoring..."; Subclasses: override for different text to be shown to the user when your operation is running

@property (assign) id<JRRestoreOperationDelegate> delegate;
@property (readonly) CGFloat progress;

@end


@protocol JRRestoreOperationDelegate <NSObject>

@optional
- (void)restoreOperationBegan:(id)restoreOperation;
- (void)restoreOperation:(id)restoreOperation updatedToProgress:(CGFloat)progress;
- (void)restoreOperationFinished:(id)restoreOperation;
- (void)restoreOperation:(id)restoreOperation failedWithErrorDescription:(NSString *)errorDescription;

@end