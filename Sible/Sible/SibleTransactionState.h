//
//  SibleTransactionState.h
//  emberlight-sdk
//
//  Created by Kevin Rohling on 12/8/14.
//  Copyright (c) 2014 emberlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sible.h"

@interface SibleTransactionState : NSObject

- (id) initWithTransaction: (SibleTransaction *) transaction AndHandler:(void (^)(SibleTransaction *transaction, NSError *error)) handler;

@property (strong, nonatomic) SibleTransaction *transaction;
@property (strong, nonatomic) NSTimer *timeoutTimer;
@property (strong, nonatomic) SibleOperation *currentOperation;
@property (strong, nonatomic) void ( ^ handler)( SibleTransaction *transaction, NSError *error );

@end
