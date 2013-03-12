//
//  BluetoothLEService.h
//  SensorApp
//
//  Created by Scott Gruby on 12/13/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class BluetoothLEService;

@protocol BluetoothLEServiceProtocol <NSObject>
@required
- (void) didDiscoverCharacterisics:(BluetoothLEService *) service;
- (void) didUpdateValue:(BluetoothLEService *) service forServiceUUID:(CBUUID *) serviceUUID withCharacteristicUUID:(CBUUID *) characteristicUUID withData:(NSData *) data;
@end

@interface BluetoothLEService : NSObject
- (id) initWithPeripheral:(CBPeripheral *)peripheral withServiceUUIDs:(NSArray *) serviceUUIDs delegate:(id<BluetoothLEServiceProtocol>) delegate;
- (void) discoverServices;
- (void) startNotifyingForServiceUUID:(NSString *) serviceUUID andCharacteristicUUID:(NSString *) charUUID;
- (void) stopNotifyingForServiceUUID:(NSString *) serviceUUID andCharacteristicUUID:(NSString *) charUUID;
- (void) setValue:(NSData *) data forServiceUUID:(NSString *) serviceUUID andCharacteristicUUID:(NSString *) charUUID;
- (void) readValueForServiceUUID:(NSString *) serviceUUID andCharacteristicUUID:(NSString *) charUUID;
@end
