//
//  SibleWriteOperation.m
//  emberlight-sdk
//
//  Created by Kevin Rohling on 12/8/14.
//  Copyright (c) 2014 emberlight. All rights reserved.
//

#import "Sible.h"

@implementation SibleWriteOperation

- (id) initWithPeripheral: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) characteristicUUID WriteValue: (NSData *) writeValue {
    self = [super initWithPeripheral:peripheral ServiceUUID:serviceUUID CharacteristicUUID:characteristicUUID];
    
    if (self) {
        self.writeValue = writeValue;
        self.writeType = SibleWriteWithResponse;
    }
    
    return self;
}

- (id) initWithPeripheral: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) characteristicUUID WriteByte: (UInt8) writeByte {
    self = [super initWithPeripheral:peripheral ServiceUUID:serviceUUID CharacteristicUUID:characteristicUUID];
    
    if (self) {
        self.writeValue = [NSMutableData dataWithBytes:&writeByte length:1];
        self.writeType = SibleWriteWithResponse;
    }
    
    return self;
}

- (id) initWithPeripheral:(CBPeripheral *)peripheral ServiceUUID:(NSString *)serviceUUID CharacteristicUUID:(NSString *)characteristicUUID WriteString:(NSString *)writeString {
    self = [super initWithPeripheral:peripheral ServiceUUID:serviceUUID CharacteristicUUID:characteristicUUID];
    
    if (self) {
        NSData *data = [writeString dataUsingEncoding:NSASCIIStringEncoding];
        self.writeValue = data;
        self.writeType = SibleWriteWithResponse;
    }
    
    return self;
}

@end
