//
//  SibleTransactionState.m
//  emberlight-sdk
//
//  Created by Kevin Rohling on 12/8/14.
//  Copyright (c) 2014 emberlight. All rights reserved.
//

#import "SibleTransactionState.h"

@implementation SibleTransactionState

- (id) initWithTransaction:(SibleTransaction *)transaction AndHandler:(void (^)(SibleTransaction *, NSError *))handler {
    self = [super init];
    
    if (self) {
        self.transaction = transaction;
        self.handler = handler;
    }
    
    return self;
}

@end
