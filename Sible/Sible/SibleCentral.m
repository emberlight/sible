//
//  SibleCentral.m
//  emberlight-sdk
//
//  Created by Kevin Rohling on 12/8/14.
//  Copyright (c) 2014 emberlight. All rights reserved.
//

#import "Sible.h"
#import "SibleCentral.h"
#import "SibleTransactionState.h"

@interface SibleCentral ()

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableArray *activeTransactionStates;

@end

@implementation SibleCentral

NSString *const Sible_CENTRAL_ERROR_DOMAIN = @"co.emberlight.SibleCentral";

- (id) init {
    self = [super init];
    
    if (self) {
        dispatch_queue_t centralQueue = dispatch_queue_create("co.emberlight.Sible", DISPATCH_QUEUE_SERIAL);
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:nil];
        self.activeTransactionStates = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id) initWithCentralManager:(CBCentralManager *)centralManager {
    self = [super init];
    
    if (self) {
        self.centralManager = centralManager;
        self.centralManager.delegate = self;
        self.activeTransactionStates = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) startTransaction:(SibleTransaction *)transaction WithTimeout: (NSTimeInterval) timeout Handler:(void (^)(SibleTransaction *, NSError *))handler {
    SibleTransactionState *state = [[SibleTransactionState alloc] initWithTransaction:transaction AndHandler:handler];
    
    if (timeout > 0) {
        state.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(transactionTimeout:) userInfo:@{@"transactionState": state} repeats:NO];
    }
    
    [self.activeTransactionStates addObject:state];
    [self startOperation:[transaction nextOperation]];
}

- (void) transactionTimeout: (NSTimer *) timer {
    SibleTransactionState *state = [timer.userInfo objectForKey:@"transactionState"];
    
    if (state && [self.activeTransactionStates containsObject:state] && state.currentOperation) {
        NSString *message = [NSString stringWithFormat:@"Operation failed: Transaction execution timed out"];
        NSDictionary *errorDetails = @{ NSLocalizedDescriptionKey: message };
        NSError *error = [[NSError alloc] initWithDomain:Sible_CENTRAL_ERROR_DOMAIN code:1 userInfo:errorDetails];
        
        [self failOperation:state.currentOperation WithError:error];
    }
}

- (void) startOperation: (SibleOperation *) operation {
    self.centralManager.delegate = self;
    NSError *error = [self canStartOperation:operation];
    
    if (error) {
        [self failOperation:operation WithError:error];
    }
    else {
        NSLog(@"Starting Operation");
        SibleTransactionState *state = [self transactionStateForOperation:operation];
        state.currentOperation = operation;
        
        if (operation.peripheral.state == CBPeripheralStateConnected) {
            [self onOperationConnected:operation];
        }
        else {
            NSLog(@"Starting Peripheral connection");
            [self.centralManager connectPeripheral:operation.peripheral options:nil];
        }
    }
}

- (void) onOperationConnected: (SibleOperation *) operation {
    NSLog(@"Peripheral successfully connected.  Starting service discovery.");
    operation.peripheral.delegate = self;
    [operation.peripheral discoverServices:@[operation.serviceUUID]];
}

- (void) failOperation: (SibleOperation *) operation WithError: (NSError *) error {
    NSLog(@"Operation failed");
    
    if (operation.peripheral.state == CBPeripheralStateConnected || operation.peripheral.state == CBPeripheralStateConnecting) {
        NSLog(@"Cancelling Peripheral connection");
        [self.centralManager cancelPeripheralConnection:operation.peripheral];
    }
    
    SibleTransactionState *state = [self transactionStateForOperation:operation];
    if (state) {
        [self finishTransaction:state WithError:error];
    }
}

- (void) completeOperation: (SibleOperation *) operation {
    NSLog(@"Operation successfully completed.");
    SibleTransactionState *state = [self transactionStateForOperation:operation];
    
    if (state) {
        SibleOperation *nextOperation = [state.transaction nextOperation];
        
        if (nextOperation) {
            NSLog(@"Preparing for next transaction operation.");
            if (operation.peripheral != nextOperation.peripheral && operation.peripheral.state == CBPeripheralStateConnected) {
                [self.centralManager cancelPeripheralConnection:operation.peripheral];
            }
            
            state.currentOperation = nil;
            [self startOperation:nextOperation];
        }
        else {
            if (operation.peripheral.state == CBPeripheralStateConnected) {
                NSLog(@"Cancelling Peripheral connection");
                [self.centralManager cancelPeripheralConnection:operation.peripheral];
            }
            
            [self finishTransaction:state WithError:nil];
        }
    }
}


- (void) finishTransaction: (SibleTransactionState *) state WithError: (NSError *) error {
    if (state.timeoutTimer) {
        [state.timeoutTimer invalidate];
    }
    
    [self.activeTransactionStates removeObject:state];
    state.handler(state.transaction, error);
}












- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    SibleOperation *operation = [self activeOperationForPeripheral:peripheral];
    
    if (operation) {
        [self onOperationConnected:operation];
    }
    else {
        NSLog(@"No operation available, cancelling Peripheral connection.");
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Peripheral connection failed");
    SibleOperation *operation = [self activeOperationForPeripheral:peripheral];
    
    if (operation) {
        [self failOperation:operation WithError:error];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"Services discovered for peripheral.");
    
    SibleOperation *operation = [self activeOperationForPeripheral:peripheral];
    
    if (operation) {
        if (error) {
            [self failOperation:operation WithError:error];
        }
        else {
            CBService *targetService;
            
            for (CBService *service in peripheral.services) {
                if ([service.UUID isEqual:operation.serviceUUID]) {
                    targetService = service;
                    break;
                }
            }
            
            if (targetService) {
                NSLog(@"Starting Characteristic discovery.");
                [operation.peripheral discoverCharacteristics:@[operation.characteristicUUID] forService:targetService];
            }
            else {
                NSString *serviceUUID = [self stringForCBUUID:operation.serviceUUID];
                NSString *message = [NSString stringWithFormat:@"Operation failed: Unable to locate Service with UUID: %@", serviceUUID];
                NSDictionary *errorDetails = @{ NSLocalizedDescriptionKey: message };
                NSError *error = [[NSError alloc] initWithDomain:Sible_CENTRAL_ERROR_DOMAIN code:1 userInfo:errorDetails];
                [self failOperation:operation WithError:error];
            }
        }
    }
    else {
        NSLog(@"Cancelling peripheral connection.");
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)cbService error:(NSError *)error {
    NSLog(@"Characteristics discovered for peripheral.");
    SibleOperation *operation = [self activeOperationForPeripheral:peripheral];
    
    if (operation) {
        if (error) {
            [self failOperation:operation WithError:error];
        }
        else {
            CBCharacteristic *targetChar;
            
            for (CBCharacteristic *characteristic in cbService.characteristics) {
                if ([characteristic.UUID isEqual:operation.characteristicUUID]) {
                    targetChar = characteristic;
                    break;
                }
            }
            
            if (targetChar) {
                if ([operation isKindOfClass:[SibleWriteOperation class]]) {
                    SibleWriteOperation *writeOperation = (SibleWriteOperation *) operation;
                    if (writeOperation.writeType == SibleWriteWithResponse) {
                        NSLog(@"Starting Write With Response.");
                        [peripheral writeValue:writeOperation.writeValue forCharacteristic:targetChar type:CBCharacteristicWriteWithResponse];
                    }
                    else if (writeOperation.writeType == SibleWriteWithoutResponse) {
                        NSLog(@"Starting Write Without Response.");
                        [peripheral writeValue:writeOperation.writeValue forCharacteristic:targetChar type:CBCharacteristicWriteWithoutResponse];
                    }
                }
                else if([operation isKindOfClass:[SibleReadOperation class]]) {
                    [peripheral readValueForCharacteristic:targetChar];
                }
            }
            else {
                NSString *charUUID = [self stringForCBUUID:operation.characteristicUUID];
                NSString *message = [NSString stringWithFormat:@"Operation failed: Unable to locate Characteristic with UUID: %@", charUUID];
                NSDictionary *errorDetails = @{ NSLocalizedDescriptionKey: message };
                NSError *error = [[NSError alloc] initWithDomain:Sible_CENTRAL_ERROR_DOMAIN code:1 userInfo:errorDetails];
                [self failOperation:operation WithError:error];
            }
        }
    }
    else {
        NSLog(@"Cancelling peripheral connection.");
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"Characteristic value updated.");
    SibleOperation *operation = [self activeOperationForPeripheral:peripheral];
    
    if (error) {
        [self failOperation:operation WithError:error];
    }
    else {
        if ([operation isKindOfClass:[SibleReadOperation class]]) {
            SibleReadOperation *readOperation = (SibleReadOperation *) operation;
            readOperation.readValue = characteristic.value;
        }
        
        [self completeOperation:operation];
    }
    
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"Characteristic write completed.");
    SibleOperation *operation = [self activeOperationForPeripheral:peripheral];
    
    if (error) {
        [self failOperation:operation WithError:error];
    }
    else {
        [self completeOperation:operation];
    }
}










- (SibleOperation *) activeOperationForPeripheral: (CBPeripheral *) peripheral {
    SibleOperation *operation;
    
    for (SibleTransactionState *state in self.activeTransactionStates) {
        if (state.currentOperation && state.currentOperation.peripheral == peripheral) {
            operation = state.currentOperation;
            break;
        }
    }
    
    return operation;
}


- (SibleTransactionState *) transactionStateForOperation: (SibleOperation *) operation {
    SibleTransactionState *result;
    
    for (SibleTransactionState *state in self.activeTransactionStates) {
        if ([state.transaction containsOperation:operation]) {
            result = state;
            break;
        }
    }
    
    return result;
}

- (NSError *) canStartOperation: (SibleOperation *) operation {
    /*
    if (operation.peripheral.state == CBPeripheralStateConnecting) {
        NSDictionary *errorDetails = @{ NSLocalizedDescriptionKey: @"Operation cannot be started because a connection is already in progress using this peripheral." };
        return [[NSError alloc] initWithDomain:Sible_CENTRAL_ERROR_DOMAIN code:1 userInfo:errorDetails];
    }
    */
    
    for (SibleTransactionState *state in self.activeTransactionStates) {
        if (state.currentOperation && state.currentOperation.peripheral == operation.peripheral) {
            NSDictionary *errorDetails = @{ NSLocalizedDescriptionKey: @"Operation cannot be started because another active operation is using this peripheral." };
            return [[NSError alloc] initWithDomain:Sible_CENTRAL_ERROR_DOMAIN code:1 userInfo:errorDetails];
        }
    }
    
    return nil;
}

- (NSString *)stringForCBUUID: (CBUUID *) uuid
{
    NSData *data = [uuid data];
    
    NSUInteger bytesToConvert = [data length];
    const unsigned char *uuidBytes = [data bytes];
    NSMutableString *outputString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
    {
        switch (currentByteIndex)
        {
            case 3:
            case 5:
            case 7:
            case 9:[outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]]; break;
            default:[outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
        }
        
    }
    
    return outputString;
}

@end
