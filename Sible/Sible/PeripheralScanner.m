//
//  BluetoothManager.m
//  emberlight-sdk
//
//  Created by Kevin Rohling on 8/1/14.
//  Copyright (c) 2014 emberlight. All rights reserved.
//

#import "PeripheralScanner.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "Sible.h"

@interface PeripheralScanner ()

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSString *pendingScanServiceUUID;

@end

@implementation PeripheralScanner

NSString *const BLUETOOTH_MANAGER_ERROR_DOMAIN = @"co.emberlight.PeripheralScanner";

- (id)init {
    self = [super init];
    
    if (self) {
        dispatch_queue_t centralQueue = dispatch_queue_create("co.emberlight", DISPATCH_QUEUE_SERIAL);
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:nil];
        self.peripheralScans = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id) initWithCentralManager: (CBCentralManager *) centralManager {
    self = [super init];
    if (self) {
        self.centralManager = centralManager;
        self.peripheralScans = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) scanForPeripheralsWithServiceUUID:(NSString *)serviceUUID {
    self.centralManager.delegate = self;
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        CBUUID *uuid = [CBUUID UUIDWithString:serviceUUID];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        [self.centralManager scanForPeripheralsWithServices:@[uuid] options:options];
        
        self.pendingScanServiceUUID = nil;
    }
    else {
        self.pendingScanServiceUUID = serviceUUID;
    }
}

- (void) stopScanningForPeripherals {
    [self.centralManager stopScan];
}

- (void) clearPeripheralScans {
    [self.peripheralScans removeAllObjects];
}






- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn && self.pendingScanServiceUUID) {
        CBUUID *uuid = [CBUUID UUIDWithString:self.pendingScanServiceUUID];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        [self.centralManager scanForPeripheralsWithServices:@[uuid] options:options];
        
        self.pendingScanServiceUUID = nil;
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (![self isPeripheralScanned:peripheral]) {
        PeripheralScan *scan = [[PeripheralScan alloc] init];
        scan.peripheral = peripheral;
        scan.advertisement = advertisementData;
        scan.RSSI = RSSI;
        
        [self.peripheralScans addObject:scan];
        NSLog(@"Peripheral Scanned");
    }
}

- (BOOL) isPeripheralScanned:(CBPeripheral *) peripheral {
    for (PeripheralScan *scan in self.peripheralScans) {
        if (scan.peripheral == peripheral) {
            return true;
        }
    }
    
    return false;
}


@end
