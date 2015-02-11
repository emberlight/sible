//
//  RebleOperation.m
//  emberlight-sdk
//
//  Created by Kevin Rohling on 12/8/14.
//  Copyright (c) 2014 emberlight. All rights reserved.
//

#import "Sible.h"

@implementation SibleOperation

- (id) initWithPeripheral: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) characteristicUUID {
    self = [super init];
    
    if (self) {
        self.peripheral = peripheral;
        self.serviceUUID = [CBUUID UUIDWithString:serviceUUID];
        self.characteristicUUID = [CBUUID UUIDWithString:characteristicUUID];
    }
    
    return self;
}

@end
