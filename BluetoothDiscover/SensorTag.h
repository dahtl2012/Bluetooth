//
//  SensorTag.h
//  SensorApp
//
//  Created by Scott Gruby on 12/16/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBUUID;

#define kKeyPressServiceUUIDString					@"ffe0"
#define kKeyPressCharacteristicUUIDString			@"ffe1" // Key press data

#define kTemperatureServiceUUDString				@"f000aa00-0451-4000 b000-000000000000"
#define kTemperatureMonitorUUIDString				@"f000aa02-0451-4000 b000-000000000000" // Turn on the sensor
#define kTemperatureCharacteristicUUIDString		@"f000aa01-0451-4000 b000-000000000000" // Temperature data

#define kHumidityServiceUUIDString					@"f000aa20-0451-4000 b000-000000000000"
#define kHumidityMonitorUUIDString					@"f000aa22-0451-4000 b000-000000000000" // Turn on the sensor
#define kHumidityCharacteristicUUIDString			@"f000aa21-0451-4000 b000-000000000000" // Humidity data

#define kBaromoterServiceUUIDString					@"f000aa40-0451-4000 b000-000000000000"
#define kBaromoterMonitorUUIDString					@"f000aa42-0451-4000 b000-000000000000" // Configure the sensor
#define kBarometerCharacteristicUUIDString			@"f000aa41-0451-4000 b000-000000000000" // Barometer data
#define kBarometerCalibrationUUIDString				@"f000aa43-0451-4000 b000-000000000000" // Baraometer calibration data

typedef enum SensorType
{
	kSensorAmbientTemperatureType = 0,
	kSensorObjectTemperatureType,
	kSensorHumidityType,
	kSensorPressureType
} SensorType;

@interface SensorTag : NSObject
@property (nonatomic, readonly, assign) BOOL leftButtonDown;
@property (nonatomic, readonly, assign) BOOL rightButtonDown;
@property (nonatomic, readonly, assign) double ambientTemperature; // Temperature in degress Celsius (this is the average from 2 sensors, if enabled)
@property (nonatomic, readonly, assign) BOOL hasAmbientTemperature; // Is the value valid
@property (nonatomic, readonly, assign) double objectTemperature; // Temperature in degress Celsius
@property (nonatomic, readonly, assign) BOOL hasObjectTemperature; // Is the value valid
@property (nonatomic, readonly, assign) float relativeHumidity; // Relative humidity in %
@property (nonatomic, readonly, assign) BOOL hasRelativeHumidity; // Is the value valid
@property (nonatomic, readonly, assign)	NSUInteger pressure; // Pressure in mPa
@property (nonatomic, readonly, assign) BOOL hasPressure; // Is the value valid
- (void) processCharacteristicDataWithServiceID:(CBUUID *) serviceUUID withCharacteristicID:(CBUUID *) characteristicUUID withData:(NSData *) inData;
+ (NSArray *) serviceUUIDsToMonitor;
- (BOOL) hasBarometricPressureCalibrationData;		// The collection of pressure data should only be started after we have calibration data;
@end
