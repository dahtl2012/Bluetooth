//
//  BluetoothLEService+SensorTag.m
//  SensorApp
//
//  Created by Scott Gruby on 12/14/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import "BluetoothLEService+SensorTag.h"
#import "SensorTag.h"

#define kRightButtonMask 1 << 0
#define kLeftButtonMask 1 << 1

@implementation BluetoothLEService (SensorTag)
- (void) startMonitoringKeyPresses
{
	[self startNotifyingForServiceUUID:kKeyPressServiceUUIDString andCharacteristicUUID:kKeyPressCharacteristicUUIDString];
}

- (void) stopMonitoringKeyPresses
{
	[self stopNotifyingForServiceUUID:kKeyPressServiceUUIDString andCharacteristicUUID:kKeyPressCharacteristicUUIDString];
}

- (void) startMonitoringTemperatureSensor
{
	// Turn on the temperature sensor
	UInt8 value = 0x01;
	NSData *data = [NSData dataWithBytes:&value length:sizeof (value)];
	[self setValue:data forServiceUUID:kTemperatureServiceUUDString andCharacteristicUUID:kTemperatureMonitorUUIDString];
	
	// Start notifying for temperature change
	[self startNotifyingForServiceUUID:kTemperatureServiceUUDString andCharacteristicUUID:kTemperatureCharacteristicUUIDString];
}

- (void) stopMonitoringTemperatureSensor
{
	// Turn on the temperature sensor
	UInt8 value = 0x00;
	NSData *data = [NSData dataWithBytes:&value length:sizeof (value)];
	[self setValue:data forServiceUUID:kTemperatureServiceUUDString andCharacteristicUUID:kTemperatureMonitorUUIDString];
	
	// Start notifying for temperature change
	[self stopNotifyingForServiceUUID:kTemperatureServiceUUDString andCharacteristicUUID:kTemperatureCharacteristicUUIDString];
}

- (void) startMonitoringHumiditySensor
{
	// Turn on the humidity/temperature sensor
	UInt8 value = 0x01;
	NSData *data = [NSData dataWithBytes:&value length:sizeof (value)];
	[self setValue:data forServiceUUID:kHumidityServiceUUIDString andCharacteristicUUID:kHumidityMonitorUUIDString];
	
	// Start notifying for humidity/temperature change
	[self startNotifyingForServiceUUID:kHumidityServiceUUIDString andCharacteristicUUID:kHumidityCharacteristicUUIDString];
}

- (void) stopMonitoringHumiditySensor
{
	// Turn on the humidity/temperature sensor
	UInt8 value = 0x00;
	NSData *data = [NSData dataWithBytes:&value length:sizeof (value)];
	[self setValue:data forServiceUUID:kHumidityServiceUUIDString andCharacteristicUUID:kHumidityMonitorUUIDString];
	
	// Start notifying for humidity/temperature change
	[self stopNotifyingForServiceUUID:kHumidityServiceUUIDString andCharacteristicUUID:kHumidityCharacteristicUUIDString];
}

- (void) readBarometerSensorCalibration
{
	// Turn on the barometer sensor
	UInt8 value = 0x02;
	NSData *data = [NSData dataWithBytes:&value length:sizeof (value)];
	[self setValue:data forServiceUUID:kBaromoterServiceUUIDString andCharacteristicUUID:kBaromoterMonitorUUIDString];
	
	// Start notifying for barometeric pressue change
	[self startNotifyingForServiceUUID:kBaromoterServiceUUIDString andCharacteristicUUID:kBarometerCharacteristicUUIDString];

	// We need to grab the calibration data in order to figure out the pressure
	[self readValueForServiceUUID:kBaromoterServiceUUIDString andCharacteristicUUID:kBarometerCalibrationUUIDString];

	value = 0x01;
	data = [NSData dataWithBytes:&value length:sizeof (value)];
	[self setValue:data forServiceUUID:kBaromoterServiceUUIDString andCharacteristicUUID:kBaromoterMonitorUUIDString];
}

- (void) startMonitoringBarometerSensor
{
	// Turn on the barometer sensor
	UInt8 value = 0x01;
	NSData *data = [NSData dataWithBytes:&value length:sizeof (value)];
	[self setValue:data forServiceUUID:kBaromoterServiceUUIDString andCharacteristicUUID:kBaromoterMonitorUUIDString];
}

- (void) stopMonitoringBarometerSensor
{
	// Turn on the barometer sensor
	UInt8 value = 0x00;
	NSData *data = [NSData dataWithBytes:&value length:sizeof (value)];
	[self setValue:data forServiceUUID:kBaromoterServiceUUIDString andCharacteristicUUID:kBaromoterMonitorUUIDString];
	
	// Start notifying for barometric pressue change
	[self stopNotifyingForServiceUUID:kBaromoterServiceUUIDString andCharacteristicUUID:kBarometerCharacteristicUUIDString];
}

@end
