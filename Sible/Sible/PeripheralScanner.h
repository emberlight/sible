//
//  BluetoothManager.h
//  emberlight-sdk
//
//  Created by Kevin Rohling on 8/1/14.
//  Copyright (c) 2014 emberlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PeripheralScanner : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) NSMutableArray *peripheralScans;

- (id) initWithCentralManager: (CBCentralManager *) centralManager;
- (void) scanForPeripheralsWithServiceUUID: (NSString *) serviceUUID;
- (void) stopScanningForPeripherals;
- (void) clearPeripheralScans;

@end
