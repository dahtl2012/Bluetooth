//
//  SensorTag.m
//  SensorApp
//
//  Created by Scott Gruby on 12/16/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import "SensorTag.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define kRightButtonMask 1 << 0
#define kLeftButtonMask 1 << 1

@interface EpocsT5400Calibration : NSObject
@property (nonatomic, assign) UInt16 c1;
@property (nonatomic, assign) UInt16 c2;
@property (nonatomic, assign) UInt16 c3;
@property (nonatomic, assign) UInt16 c4;
@property (nonatomic, assign) SInt16 c5;
@property (nonatomic, assign) SInt16 c6;
@property (nonatomic, assign) SInt16 c7;
@property (nonatomic, assign) SInt16 c8;
@end

@implementation EpocsT5400Calibration
- (id) initWithCalibrationData:(NSData *) data
{
	if (self = [super init])
	{
		if ([data length] >= 16)
		{
			unsigned char scratchVal[16];
			[data getBytes:&scratchVal length:16];
			_c1 = ((scratchVal[0] & 0xff) | ((scratchVal[1] << 8) & 0xff00));
			_c2 = ((scratchVal[2] & 0xff) | ((scratchVal[3] << 8) & 0xff00));
			_c3 = ((scratchVal[4] & 0xff) | ((scratchVal[5] << 8) & 0xff00));
			_c4 = ((scratchVal[6] & 0xff) | ((scratchVal[7] << 8) & 0xff00));
			_c5 = ((scratchVal[8] & 0xff) | ((scratchVal[9] << 8) & 0xff00));
			_c6 = ((scratchVal[10] & 0xff) | ((scratchVal[11] << 8) & 0xff00));
			_c7 = ((scratchVal[12] & 0xff) | ((scratchVal[13] << 8) & 0xff00));
			_c8 = ((scratchVal[14] & 0xff) | ((scratchVal[15] << 8) & 0xff00));
		}
	}
	
	return self;
}

@end

@interface SensorTag ()
@property (nonatomic, assign) BOOL leftButtonDown;
@property (nonatomic, assign) BOOL rightButtonDown;
@property (nonatomic, assign) double objectTemperature; // Temperature in degress Celsius
@property (nonatomic, assign) float relativeHumidity; // Relative humidity in %
@property (nonatomic, assign) NSUInteger pressure;
@property (nonatomic, assign) double ambientTemperatureFromTMP006Sensor;
@property (nonatomic, assign) double ambientTemperatureFromSHT21Sensor;
@property (nonatomic, assign) double ambientTemperatureFromT5400Sensor;

@property (nonatomic, assign) BOOL hasTemperatureFromTMP006Sensor;
@property (nonatomic, assign) BOOL hasTemperatureFromSHT21Sensor;
@property (nonatomic, assign) BOOL hasTemperatureFromT5400Sensor;

@property (nonatomic, assign) BOOL hasAmbientTemperature; // Is the value valid
@property (nonatomic, assign) BOOL hasObjectTemperature; // Is the value valid
@property (nonatomic, assign) BOOL hasPressure; // Is the value valid
@property (nonatomic, assign) BOOL hasRelativeHumidity; // Is the value valid

@property (nonatomic, strong) EpocsT5400Calibration *barometerSensorCalibration;
@end

@implementation SensorTag
+ (NSArray *) serviceUUIDsToMonitor
{
	return @[kKeyPressServiceUUIDString, kTemperatureServiceUUDString, kHumidityServiceUUIDString, kBaromoterServiceUUIDString];
}

- (void) processCharacteristicDataWithServiceID:(CBUUID *) serviceUUID withCharacteristicID:(CBUUID *) characteristicUUID withData:(NSData *) inData
{
	if ([[CBUUID UUIDWithString:kKeyPressServiceUUIDString] isEqual:serviceUUID] && [[CBUUID UUIDWithString:kKeyPressCharacteristicUUIDString] isEqual:characteristicUUID])
	{
		UInt8 keyPress = 0;
		[inData getBytes:&keyPress length:1];
		
		self.leftButtonDown = (keyPress & kLeftButtonMask) ? YES : NO;
		self.rightButtonDown = (keyPress & kRightButtonMask) ? YES : NO;
	}
	else if ([[CBUUID UUIDWithString:kTemperatureServiceUUDString] isEqual:serviceUUID] && [[CBUUID UUIDWithString:kTemperatureCharacteristicUUIDString] isEqual:characteristicUUID])
	{
		// TI TMP006 sensor
		if ([inData length] >= 4)
		{
			char scratchVal[4];
			SInt16 ambientTemp = 0;
			SInt16 objectVoltage = 0;
			
			[inData getBytes:&scratchVal length:4];
			ambientTemp = ((scratchVal[2] & 0xff)| ((scratchVal[3] << 8) & 0xff00));
			objectVoltage = ((scratchVal[0] & 0xff)| ((scratchVal[1] << 8) & 0xff00));
			
			self.ambientTemperatureFromTMP006Sensor = (float)((float)ambientTemp / (float)128);
			self.hasTemperatureFromTMP006Sensor = YES;
			
			// Calculation from: http://www.ti.com/lit/ug/sbou107/sbou107.pdf
			long double Vobj2 = (double)objectVoltage * .00000015625;
			long double Tdie2 = (double)self.ambientTemperatureFromTMP006Sensor + 273.15;
			long double S0 = 6.4*pow(10,-14);
			long double a1 = 1.75*pow(10,-3);
			long double a2 = -1.678*pow(10,-5);
			long double b0 = -2.94*pow(10,-5);
			long double b1 = -5.7*pow(10,-7);
			long double b2 = 4.63*pow(10,-9);
			long double c2 = 13.4f;
			long double Tref = 298.15;
			long double S = S0*(1+a1*(Tdie2 - Tref)+a2*pow((Tdie2 - Tref),2));
			long double Vos = b0 + b1*(Tdie2 - Tref) + b2*pow((Tdie2 - Tref),2);
			long double fObj = (Vobj2 - Vos) + c2*pow((Vobj2 - Vos),2);
			long double Tobj = pow(pow(Tdie2,4) + (fObj/S),.25);
			Tobj = (Tobj - 273.15);
			self.objectTemperature = Tobj;
			self.hasObjectTemperature = YES;
		}
	}
	else if ([[CBUUID UUIDWithString:kHumidityServiceUUIDString] isEqual:serviceUUID] && [[CBUUID UUIDWithString:kHumidityCharacteristicUUIDString] isEqual:characteristicUUID])
	{
		// Sensirion SHT21 Sensor
		if ([inData length] >= 4)
		{
			char scratchVal[4];
			UInt16 rawHumidity = 0;
			UInt16 rawTemperature = 0;
			[inData getBytes:&scratchVal length:4];
			rawHumidity = ((scratchVal[2] & 0xff)| ((scratchVal[3] << 8) & 0xff00));
			rawTemperature = ((scratchVal[0] & 0xff)| ((scratchVal[1] << 8) & 0xff00));
			// Calculation from: http://www.sensirion.com/fileadmin/user_upload/customers/sensirion/Dokumente/Humidity/Sensirion_Humidity_SHT21_Datasheet_V3.pdf
			self.relativeHumidity = -6.0f + 125.0f * ((float) rawHumidity / (float)pow(2, 16));
			self.ambientTemperatureFromSHT21Sensor = -46.85 + 175.72 * (float) rawTemperature / (float) pow(2,16);
			self.hasTemperatureFromSHT21Sensor = YES;
			self.hasRelativeHumidity = YES;
		}
	}
	else if ([[CBUUID UUIDWithString:kBaromoterServiceUUIDString] isEqual:serviceUUID] && [[CBUUID UUIDWithString:kBarometerCharacteristicUUIDString] isEqual:characteristicUUID])
	{
		if (self.barometerSensorCalibration)
		{
			if ([inData length] >= 4)
			{
				char scratchVal[4];
				[inData getBytes:&scratchVal length:4];
				SInt16 rawTemperature = (scratchVal[0] & 0xff) | ((scratchVal[1] << 8) & 0xff00);
				UInt16 rawPressure = (scratchVal[2] & 0xff) | ((scratchVal[3] << 8) & 0xff00);
				
				double temperature = ((self.barometerSensorCalibration.c1 * rawTemperature) / pow(2, 24)) + self.barometerSensorCalibration.c2 / pow(2, 10);
				self.ambientTemperatureFromT5400Sensor = temperature;
				self.hasTemperatureFromT5400Sensor = YES;

				long long S = self.barometerSensorCalibration.c3 + ((self.barometerSensorCalibration.c4 * (long long)rawTemperature)/((long long)1 << 17)) + ((self.barometerSensorCalibration.c5 * ((long long)rawTemperature * (long long)rawTemperature))/(long long)((long long)1 << 34));
				long long O = (self.barometerSensorCalibration.c6 * ((long long)1 << 14)) + (((self.barometerSensorCalibration.c7 * (long long)rawTemperature)/((long long)1 << 3))) + ((self.barometerSensorCalibration.c8 * ((long long)rawTemperature * (long long)rawTemperature))/(long long)((long long)1 << 19));
				long long Pa = (((S * (long long)rawPressure) + O) / (long long)((long long)1 << 14));
				self.pressure = Pa / 100;
				self.hasPressure = YES;
			}
		}
	}
	else if ([[CBUUID UUIDWithString:kBaromoterServiceUUIDString] isEqual:serviceUUID] && [[CBUUID UUIDWithString:kBarometerCalibrationUUIDString] isEqual:characteristicUUID])
	{
		self.barometerSensorCalibration = [[EpocsT5400Calibration alloc] initWithCalibrationData:inData];
	}
	else
	{
		//DebugLog(@"unknown");
	}
}

- (BOOL) hasAmbientTemperature
{
	return self.hasTemperatureFromSHT21Sensor || self.hasTemperatureFromT5400Sensor || self.hasTemperatureFromTMP006Sensor;
}

- (double) ambientTemperature
{
	double totalTemperature = 0;
	NSUInteger numberOfSensors = 0;
	if (self.hasTemperatureFromSHT21Sensor)
	{
		numberOfSensors++;
		totalTemperature += self.ambientTemperatureFromSHT21Sensor;
	}

	if (self.hasTemperatureFromTMP006Sensor)
	{
		numberOfSensors++;
		totalTemperature += self.ambientTemperatureFromTMP006Sensor;
	}

	if (self.hasTemperatureFromT5400Sensor)
	{
		numberOfSensors++;
		totalTemperature += self.ambientTemperatureFromT5400Sensor;
	}
	
	return (totalTemperature / (double) numberOfSensors);
}

- (BOOL) hasBarometricPressureCalibrationData
{
	return self.barometerSensorCalibration != nil;
}

@end
