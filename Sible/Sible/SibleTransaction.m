//
//  SibleTransaction.m
//  emberlight-sdk
//
//  Created by Kevin Rohling on 12/8/14.
//  Copyright (c) 2014 emberlight. All rights reserved.
//

#import "Sible.h"
#import "ArrayQueue.h"

@interface SibleTransaction ()

@property (strong, nonatomic) NSMutableArray *operations;
@property (strong, nonatomic) ArrayQueue *operationQueue;

@end

@implementation SibleTransaction

- (id) init {
    self = [super init];
    
    if (self) {
        self.operations = [[NSMutableArray alloc] init];
        self.operationQueue = [[ArrayQueue alloc] init];
    }
    
    return self;
}

- (NSArray *) allOperations {
    return [NSArray arrayWithArray:self.operations];
}

- (SibleOperation *) nextOperation {
    self.currentOperation = [self.operationQueue dequeue];
    return self.currentOperation;
}

- (BOOL) containsOperation:(SibleOperation *)operation {
    return [self.operations containsObject:operation];
}







- (void) enqueueOperation: (SibleOperation *) operation {
    [self.operations addObject:operation];
    [self.operationQueue enqueue:operation];
}


- (SibleReadOperation *) enqueueReadOperation: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID {
    SibleReadOperation *operation = [[SibleReadOperation alloc] initWithPeripheral:peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID];
    [self enqueueOperation:operation];
    
    return operation;
}

- (SibleWriteOperation *) enqueueWriteOperation: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID Value: (NSData *) value {
    SibleWriteOperation *operation = [[SibleWriteOperation alloc] initWithPeripheral:peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID WriteValue:value];
    [self enqueueOperation:operation];
    
    return operation;
}

- (SibleWriteOperation *) enqueueWriteOperation: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID Value: (NSData *) value WriteType: (SibleWriteType) writeType {
    SibleWriteOperation *operation = [[SibleWriteOperation alloc] initWithPeripheral:peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID WriteValue:value];
    operation.writeType = writeType;
    [self enqueueOperation:operation];
    
    return operation;
}

- (SibleWriteOperation *) enqueueWriteOperation: (CBPeripheral *) peripheral ServiceUUID:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID Byte:(UInt8)byte {
    SibleWriteOperation *operation = [[SibleWriteOperation alloc] initWithPeripheral:peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID WriteByte:byte];
    [self enqueueOperation:operation];
    
    return operation;
}

- (SibleWriteOperation *) enqueueWriteOperation: (CBPeripheral *) peripheral ServiceUUID:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID Byte:(UInt8)byte WriteType:(SibleWriteType)writeType {
    SibleWriteOperation *operation = [[SibleWriteOperation alloc] initWithPeripheral:peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID WriteByte:byte];
    operation.writeType = writeType;
    [self enqueueOperation:operation];
    
    return operation;
}

- (SibleWriteOperation *) enqueueWriteOperation: (CBPeripheral *) peripheral ServiceUUID:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID String:(NSString *)string {
    SibleWriteOperation *operation = [[SibleWriteOperation alloc] initWithPeripheral:peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID WriteString:string];
    [self enqueueOperation:operation];
    
    return operation;
}

- (SibleWriteOperation *) enqueueWriteOperation: (CBPeripheral *) peripheral ServiceUUID:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID String:(NSString *)string WriteType:(SibleWriteType)writeType {
    SibleWriteOperation *operation = [[SibleWriteOperation alloc] initWithPeripheral:peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID WriteString:string];
    operation.writeType = writeType;
    [self enqueueOperation:operation];
    
    return operation;
}


@end
