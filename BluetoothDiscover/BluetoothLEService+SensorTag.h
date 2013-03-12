//
//  BluetoothLEService+SensorTag.h
//  SensorApp
//
//  Created by Scott Gruby on 12/14/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import "BluetoothLEService.h"

@interface BluetoothLEService (SensorTag)
- (void) startMonitoringKeyPresses;
- (void) stopMonitoringKeyPresses;

- (void) startMonitoringTemperatureSensor;
- (void) stopMonitoringTemperatureSensor;

- (void) startMonitoringHumiditySensor;
- (void) stopMonitoringHumiditySensor;

- (void) startMonitoringBarometerSensor;
- (void) readBarometerSensorCalibration;
- (void) stopMonitoringBarometerSensor;

@end
