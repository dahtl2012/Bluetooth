//
//  BluetoothLEManager.h
//  SensorApp
//
//  Created by Scott Gruby on 12/12/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BluetoothLEManagerDelegateProtocol <NSObject>
@required
- (void) didDiscoverPeripheral:(CBPeripheral *) peripheral advertisementData:(NSDictionary *) advertisementData;
- (void) didConnectPeripheral:(CBPeripheral *) peripheral error:(NSError *) error;
- (void) didDisconnectPeripheral:(CBPeripheral *) peripheral error:(NSError *) error;
- (void) didChangeState:(CBCentralManagerState) newState;
@end

@interface BluetoothLEManager : NSObject <CBPeripheralDelegate>
+ (BluetoothLEManager *) sharedManagerWithDelegate:(id<BluetoothLEManagerDelegateProtocol>)delegate;
+ (BluetoothLEManager *) sharedManager;
- (void) discoverDevices;
- (void) connectPeripheral:(CBPeripheral *) peripheral;
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;
- (void) stopScanning;

@end
