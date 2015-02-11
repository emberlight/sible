//
//  Sible.m
//  emberlight-sdk
//
//  Created by Kevin Rohling on 12/8/14.
//  Copyright (c) 2014 emberlight. All rights reserved.
//

#import "Sible.h"
#import "SibleCentral.h"
#import "PeripheralScanner.h"

@interface Sible ()

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) SibleCentral *SibleCentral;
@property (strong, nonatomic) PeripheralScanner *SibleScanner;

@end

@implementation Sible
{
    BOOL scanningCancelled;
}

NSTimeInterval const Sible_DEFAULT_SCAN_TIMEOUT = 5.0f;
NSTimeInterval const Sible_DEFAULT_TRANSACTION_TIMEOUT = 5.0f;

- (id) init {
    self = [super init];
    
    if (self) {
        dispatch_queue_t centralQueue = dispatch_queue_create("co.emberlight.Sible", DISPATCH_QUEUE_SERIAL);
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:nil];
        self.SibleCentral = [[SibleCentral alloc] initWithCentralManager:self.centralManager];
        self.SibleScanner = [[PeripheralScanner alloc] initWithCentralManager:self.centralManager];
    }
    
    return self;
}

- (id) initWithCentralManager: (CBCentralManager *) central {
    self = [super init];
    
    if (self) {
        self.centralManager = central;
        self.SibleCentral = [[SibleCentral alloc] initWithCentralManager:central];
        self.SibleScanner = [[PeripheralScanner alloc] initWithCentralManager:central];
    }
    
    return self;
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
    
}


- (void) scan:(void (^)(NSArray *, NSError *))handler {
    [self scan:nil Handler:handler];
}

- (void) scan:(NSString *)serviceUUID Handler:(void (^)(NSArray *, NSError *))handler {
    [self scan:serviceUUID WithDuration:Sible_DEFAULT_SCAN_TIMEOUT Handler:handler];
}

- (void) scan:(NSString *)serviceUUID WithDuration: (NSTimeInterval) duration Handler:(void (^)(NSArray *, NSError *))handler {
    scanningCancelled = false;
    [self.SibleScanner scanForPeripheralsWithServiceUUID:serviceUUID];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (!scanningCancelled) {
            [self.SibleScanner stopScanningForPeripherals];
            NSArray *peripheralScans = [NSArray arrayWithArray:self.SibleScanner.peripheralScans];
            [self.SibleScanner clearPeripheralScans];
            handler(peripheralScans, nil);
        }
    });
}

- (void) cancelScanning {
    scanningCancelled = true;
    [self.SibleScanner stopScanningForPeripherals];
    [self.SibleScanner clearPeripheralScans];
}




- (void) read:(CBPeripheral *)peripheral ServiceUUID:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID Handler:(void (^)(CBPeripheral *peripheral, NSData *data, NSError *error))handler {
    SibleReadOperation *operation = [[SibleReadOperation alloc] initWithPeripheral:peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID];
    
    [self executeOperation:operation Handler:^(SibleOperation *operation, NSError *error) {
        handler(peripheral, ((SibleReadOperation *) operation).readValue, error);
    }];
}

- (void) write:(CBPeripheral *)peripheral ServiceUUID:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID Value:(NSData *)value Handler:(void (^)(CBPeripheral *peripheral, NSError *error))handler {
    SibleWriteOperation *operation = [[SibleWriteOperation alloc] initWithPeripheral:peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID WriteValue:value];
    
    [self executeOperation:operation Handler:^(SibleOperation *operation, NSError *error) {
        handler(peripheral, error);
    }];
}

- (void) write:(CBPeripheral *)peripheral ServiceUUID:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID Byte:(UInt8)byte Handler:(void (^)(CBPeripheral *peripheral, NSError *error))handler {
    SibleWriteOperation *operation = [[SibleWriteOperation alloc] initWithPeripheral:peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID WriteByte:byte];
    
    [self executeOperation:operation Handler:^(SibleOperation *operation, NSError *error) {
        handler(peripheral, error);
    }];
}

- (void) write:(CBPeripheral *)peripheral ServiceUUID:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID String:(NSString *)string Handler:(void (^)(CBPeripheral *peripheral, NSError *error))handler {
    SibleWriteOperation *operation = [[SibleWriteOperation alloc] initWithPeripheral:peripheral ServiceUUID:serviceUUID CharacteristicUUID:charUUID WriteString:string];
    
    [self executeOperation:operation Handler:^(SibleOperation *operation, NSError *error) {
        handler(peripheral, error);
    }];
}

- (void) executeOperation:(SibleOperation *)operation Handler:(void (^)(SibleOperation *operation, NSError *error))handler {
    [self executeOperation:operation WithTimeout:Sible_DEFAULT_TRANSACTION_TIMEOUT Handler:handler];
}

- (void) executeOperation:(SibleOperation *)operation WithTimeout: (NSTimeInterval) timeout Handler:(void (^)(SibleOperation *operation, NSError *error))handler {
    SibleTransaction *transaction = [[SibleTransaction alloc] init];
    [transaction enqueueOperation:operation];
    
    [self executeTransaction:transaction WithTimeout: timeout Handler:^(SibleTransaction *transaction, NSError *error) {
        handler(operation, error);
    }];
}

- (void) executeTransaction:(SibleTransaction *)transaction Handler:(void (^)(SibleTransaction *transaction, NSError *error))handler {
    [self executeTransaction:transaction WithTimeout:Sible_DEFAULT_TRANSACTION_TIMEOUT Handler:handler];
}

- (void) executeTransaction:(SibleTransaction *)transaction WithTimeout: (NSTimeInterval) timeout Handler:(void (^)(SibleTransaction *transaction, NSError *error))handler {
    [self executeTransactions:@[transaction] WithTransactionTimeout: timeout ProgressHandler:^(SibleTransaction *transaction, NSError *error) {
        handler(transaction, error);
    } CompletionHandler:^(NSArray *transactions) {
        
    }];
}

- (void) executeTransactions: (NSArray *) transactions WithTransactionTimeout: (NSTimeInterval) transactionTimeout ProgressHandler:(void (^)(SibleTransaction *transaction, NSError *error)) progressHandler CompletionHandler:(void (^)(NSArray *)) completionHandler {
    NSMutableArray *completedTransactions = [[NSMutableArray alloc] init];
    
    for (SibleTransaction *transaction in transactions) {
        [self.SibleCentral startTransaction:transaction WithTimeout: transactionTimeout Handler:^(SibleTransaction *transaction, NSError *error) {
            [completedTransactions addObject:transaction];
            progressHandler(transaction, error);
            
            if (completedTransactions.count == transactions.count) {
                completionHandler(transactions);
            }
        }];
    }
    
    
}

@end
