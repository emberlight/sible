//
//  Sible.h
//  emberlight-sdk
//
//  Created by Kevin Rohling on 12/8/14.
//  Copyright (c) 2014 emberlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PeripheralScan : NSObject

@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) NSDictionary *advertisement;
@property (strong, nonatomic) NSNumber *RSSI;

@end

@interface SibleOperation : NSObject

@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBUUID *serviceUUID;
@property (strong, nonatomic) CBUUID *characteristicUUID;

- (id) initWithPeripheral: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) characteristicUUID;

@end

@interface SibleWriteOperation : SibleOperation

typedef enum {
    SibleWriteWithResponse,
    SibleWriteWithoutResponse
} SibleWriteType;

@property (assign) SibleWriteType writeType;
@property (strong, nonatomic) NSData *writeValue;

- (id) initWithPeripheral: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) characteristicUUID WriteValue: (NSData *) writeValue;
- (id) initWithPeripheral: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) characteristicUUID WriteByte: (UInt8) writeByte;
- (id) initWithPeripheral: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) characteristicUUID WriteString: (NSString *) writeString;

@end

@interface SibleReadOperation : SibleOperation

@property (strong, nonatomic) NSData *readValue;

@end

@interface SibleTransaction : NSObject

@property (strong, nonatomic) SibleOperation *currentOperation;

- (NSArray *) allOperations;
- (void) enqueueOperation: (SibleOperation *) operation;
- (SibleOperation *) nextOperation;
- (BOOL) containsOperation: (SibleOperation *) operation;
- (SibleReadOperation *) enqueueReadOperation: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID;
- (SibleWriteOperation *) enqueueWriteOperation: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID Value: (NSData *) value;
- (SibleWriteOperation *) enqueueWriteOperation: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID Value: (NSData *) value WriteType: (SibleWriteType) writeType;
- (SibleWriteOperation *) enqueueWriteOperation: (CBPeripheral *) peripheral ServiceUUID:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID Byte:(UInt8)byte;
- (SibleWriteOperation *) enqueueWriteOperation: (CBPeripheral *) peripheral ServiceUUID:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID Byte:(UInt8)byte WriteType:(SibleWriteType)writeType;
- (SibleWriteOperation *) enqueueWriteOperation: (CBPeripheral *) peripheral ServiceUUID:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID String:(NSString *)string;
- (SibleWriteOperation *) enqueueWriteOperation: (CBPeripheral *) peripheral ServiceUUID:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID String:(NSString *)string WriteType:(SibleWriteType)writeType;

@end

@interface SiblePeripheralTransaction : SibleTransaction

- (id) initWithPeripheral: (CBPeripheral *) peripheral;

- (SibleReadOperation *) enqueueReadOperation: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID;
- (SibleWriteOperation *) enqueueWriteOperation: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID Value: (NSData *) value;
- (SibleWriteOperation *) enqueueWriteOperation: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID Value: (NSData *) value WriteType: (SibleWriteType) writeType;
- (SibleWriteOperation *) enqueueWriteOperation: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID Byte: (UInt8) byte;
- (SibleWriteOperation *) enqueueWriteOperation: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID Byte: (UInt8) byte WriteType: (SibleWriteType) writeType;
- (SibleWriteOperation *) enqueueWriteOperation:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID String:(NSString *)string;
- (SibleWriteOperation *) enqueueWriteOperation:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID String:(NSString *)string WriteType:(SibleWriteType)writeType;

@end

@interface Sible : NSObject <CBCentralManagerDelegate>

- (id) initWithCentralManager: (CBCentralManager *) central;

- (void) scan:( void ( ^ )( NSArray *peripheralScans, NSError *error ) ) handler;
- (void) scan:(NSString *)serviceUUID Handler:(void (^)(NSArray *, NSError *))handler;
- (void) scan:(NSString *)serviceUUID WithDuration: (NSTimeInterval) duration Handler:(void (^)(NSArray *, NSError *))handler;
- (void) cancelScanning;

- (void) write: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID Value: (NSData *) value Handler:( void ( ^ )( CBPeripheral *peripheral, NSError *error ) ) handler;
- (void) write: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID Byte:(UInt8)byte Handler:(void (^)(CBPeripheral *peripheral, NSError *error))handler;
- (void) write:(CBPeripheral *)peripheral ServiceUUID:(NSString *)serviceUUID CharacteristicUUID:(NSString *)charUUID String:(NSString *)string Handler:(void (^)(CBPeripheral *peripheral, NSError *error))handler;    

- (void) read: (CBPeripheral *) peripheral ServiceUUID: (NSString *) serviceUUID CharacteristicUUID: (NSString *) charUUID Handler:( void ( ^ )( CBPeripheral *peripheral, NSData *data, NSError *error ) ) handler;

- (void) executeOperation: (SibleOperation *) operation Handler:( void ( ^ )( SibleOperation *operation, NSError *error ) ) handler;


- (void) executeTransaction: (SibleTransaction *) transaction Handler:( void ( ^ )( SibleTransaction *transaction, NSError *error ) ) handler;
- (void) executeTransaction:(SibleTransaction *)transaction WithTimeout: (NSTimeInterval) timeout Handler:(void (^)(SibleTransaction *transaction, NSError *error))handler;

@end
