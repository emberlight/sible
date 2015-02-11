//
//  SiblePeripheralTransaction.m
//  emberlight-sdk
//
//  Created by Kevin Rohling on 12/8/14.
//  Copyright (c) 2014 emberlight. All rights reserved.
//

#import "Sible.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface SiblePeripheralTransaction ()

@property (strong, nonatomic) CBPeripheral *peripheral;

@end

@implementation SiblePeripheralTransaction

- (id) initWithPeripheral: (CBPeripheral *) peripheral {
    self = [super init];
    
    if (self) {
        self.peripheral = peripheral;
    }
    
    return self;
}

- (SibleReadOperation *) enqueueReadOperation: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID {
    return [super enqueueReadOperation:self.peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID];
}

- (SibleWriteOperation *) enqueueWriteOperation: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID Value: (NSData *) value {
    return [super enqueueWriteOperation:self.peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID Value:value];
}

- (SibleWriteOperation *) enqueueWriteOperation: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID Value: (NSData *) value WriteType: (SibleWriteType) writeType {
    return [super enqueueWriteOperation:self.peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID Value:value WriteType:writeType];
}

- (SibleWriteOperation *) enqueueWriteOperation:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID Byte:(UInt8)byte {
    return [super enqueueWriteOperation:self.peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID Byte:byte];
}

- (SibleWriteOperation *) enqueueWriteOperation:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID Byte:(UInt8)byte WriteType:(SibleWriteType)writeType {
    return [super enqueueWriteOperation:self.peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID Byte:byte WriteType:writeType];
}

- (SibleWriteOperation *) enqueueWriteOperation:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID String:(NSString *)string {
    return [super enqueueWriteOperation:self.peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID String:string];
}

- (SibleWriteOperation *) enqueueWriteOperation:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID String:(NSString *)string WriteType:(SibleWriteType)writeType {
    return [super enqueueWriteOperation:self.peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID String:string WriteType:writeType];
}

@end
