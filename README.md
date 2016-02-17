SIBLE - Simple Bluetooth Low Energy for iOS
=======

Introduction
-------

Sible is an abstraction layer on top of the iOS Bluetooth Low Energy (BLE) API's.  When developing sophisticated BLE applications the process of discovering Services, Characteristics and initiating read/write requests quickly becomes complex and difficult to manage.  Sible encapsulates this complexity and makes it possible to interact with BLE devices using a much simpler pattern that is intuitive and easy to use.

Quick start
-------

1. Install [CocoaPods](http://cocoapods.org/) with `gem install cocoapods`.
2. Create a file in your Xcode project called `Podfile` and add the following line:

  ```ruby
  pod 'Sible'
  ```

3. Run `pod install` in your Xcode project directory. CocoaPods should download and
install the Sible library, and create a new Xcode workspace. Open up this workspace in Xcode.

Usage
-------

### Scan for nearby devices

  ```objc
  Sible *sible = [[Sible alloc] init];
  [sible scan:@"SERVICE-UUID" WithDuration:5.0 Handler:^(NSArray *scans, NSError *error) {
    for (PeripheralScan *scan in scans) {
      NSLog(@"Peripheral: %@", scan.peripheral);
      NSLog(@"Advertisement: %@", scan.advertisement);
      NSLog(@"RSSI: %@", scan.RSSI);
    }
  }];
  ```


### Reading a BLE Characteristic

  ```objc
  Sible *sible = [[Sible alloc] init];
  [sible read:peripheral ServiceUUID:@"SERVICE-UUID" CharacteristicUUID:@"CHAR-UUID" 
    Handler:^(CBPeripheral *peripheral, NSData *data, NSError *error) {
      NSLog(@"Result: %@", data);
  }];
  ```

### Writing a single byte to a BLE Characteristic

  ```objc
  Sible *sible = [[Sible alloc] init];
  [sible write:device.peripheral ServiceUUID:@"SERVICE-UUID" CharacteristicUUID:@"CHAR-UUID" Byte:0x99 
    Handler:^(CBPeripheral *peripheral, NSError *error) { }];
  ```

### Writing an ASCII string to a BLE Characteristic

  ```objc
  Sible *sible = [[Sible alloc] init];
  [sible write:device.peripheral ServiceUUID:@"SERVICE-UUID" CharacteristicUUID:@"CHAR-UUID" String:@"my data" 
    Handler:^(CBPeripheral *peripheral, NSError *error) { }];
  ```

### Writing a collection of bytes to a BLE Characteristic

  ```objc
  unsigned char bytes = {0x01, 0x02, 0x03};
  NSData *data = [NSData dataWithBytes:bytes length:3];
  Sible *sible = [[Sible alloc] init];
  
  [sible write:device.peripheral ServiceUUID:@"SERVICE-UUID" CharacteristicUUID:@"CHAR-UUID" Value:data 
    Handler:^(CBPeripheral *peripheral, NSError *error) { }];
  ```

### Interacting With Multiple Devices In Parallel

It's even possible to execute operations against multiple peripherals at the same time.  The example below will execute writes to a list of devices in parallel.

  ```objc
  for (CBPeripheral *peripheral in myListOfPeripherals) {
    [sible write:peripheral ServiceUUID:@"SERVICE-UUID" CharacteristicUUID:@"CHAR-UUID" Byte:0x99 Handler:^(CBPeripheral *peripheral, NSError *error) { }];
  }
  ```


Sible Transactions
-------

Transactions are a simple way of orchestrating a number operations that should occur in sequence.  These operations can be reads or writes, and can even be executed against different Peripherals.  All of the operations enqueued in a Transaction are executed serially, one at a time, until they all complete.  If an operation fails during the execution of a transaction, the transaction stops and calls the handling block with the appropriate error.

### Transaction Example

  ```objc
  //This transaction executes 2 write operations and then a read
  
  SiblePeripheralTransaction *transaction = [[SiblePeripheralTransaction alloc] initWithPeripheral:peripheral];
  [transaction enqueueWriteOperation:@"SERVICE1-UUID" CharacteristicUUID:@"CHAR1-UUID" Byte:0x01];
  [transaction enqueueWriteOperation:@"SERVICE2-UUID" CharacteristicUUID:@"CHAR2-UUID" String:@"my data"];
  SibleReadOperation *readOp = [transaction enqueueReadOperation:@"SERVICE3-UUID" CharacteristicUUID:@"CHAR3-UUID"];
    
  [sible executeTransaction:transaction Handler:^(SibleTransaction *transaction, NSError *error) {
      NSLog(@"Result: %@", readOp.readValue);
  }];
  ```

### Transaction Example with multiple Peripherals

  ```objc
  //This transaction executes 2 write operations and then a read.  
  //Each operation is executed against a different peripheral.
  
  SibleTransaction *transaction = [[SibleTransaction alloc] init];
  [transaction enqueueWriteOperation:peripheral1 ServiceUUID:@"SERVICE1-UUID" CharacteristicUUID:@"CHAR1-UUID" Byte:0x01];
  [transaction enqueueWriteOperation:peripheral2 ServiceUUID:@"SERVICE2-UUID" CharacteristicUUID:@"CHAR2-UUID" String:@"my data"];
  SibleReadOperation *readOp = [transaction enqueueReadOperation:peripheral3 ServiceUUID:@"SERVICE3-UUID" CharacteristicUUID:@"CHAR30UUID"];
    
  [sible executeTransaction:transaction Handler:^(SibleTransaction *transaction, NSError *error) {
      NSLog(@"Result: %@", readOp.readValue);
  }];
  ```
  
  
  
  
