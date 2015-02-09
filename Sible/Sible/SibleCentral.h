//
//  SibleCentral.h
//  emberlight-sdk
//
//  Created by Kevin Rohling on 12/8/14.
//  Copyright (c) 2014 emberlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Sible.h"

@interface SibleCentral : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

- (id) init;
- (id) initWithCentralManager: (CBCentralManager *) central;
- (void) startTransaction:(SibleTransaction *)transaction WithTimeout: (NSTimeInterval) timeout Handler:(void (^)(SibleTransaction *, NSError *))handler;

@end
