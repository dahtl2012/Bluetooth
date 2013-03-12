//
//  BluetoothLEService.m
//  SensorApp
//
//  Created by Scott Gruby on 12/13/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import "BluetoothLEService.h"
#import "BluetoothLEManager.h"
@interface BluetoothLEService () <CBPeripheralDelegate>
@property (nonatomic, weak) CBPeripheral *peripheral;
@property (nonatomic, weak) id<BluetoothLEServiceProtocol> delegate;
@property (nonatomic, strong) NSArray *serviceUUIDs;
@property (nonatomic, assign) NSUInteger remainingServicesToDiscover;
@end


@implementation BluetoothLEService
- (id) initWithPeripheral:(CBPeripheral *)peripheral withServiceUUIDs:(NSArray *) serviceUUIDs delegate:(id<BluetoothLEServiceProtocol>) delegate
{
	if (self = [super init])
	{
		self.peripheral = peripheral;
		self.delegate = delegate;
		self.serviceUUIDs = serviceUUIDs;
		self.peripheral.delegate = self;
	}
	
	return self;
}

- (void) dealloc
{
	if (self.peripheral)
	{
		self.peripheral.delegate = [BluetoothLEManager sharedManager];
		self.peripheral = nil;
    }
}

/****************************************************************************/
/*							Service Interactions							*/
/****************************************************************************/
- (void) discoverServices
{
	NSMutableArray *serviceArray = [NSMutableArray array];
	for (NSString *str in self.serviceUUIDs)
	{
		[serviceArray addObject:[CBUUID UUIDWithString:str]];
	}
	
    [self.peripheral discoverServices:serviceArray];
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	if (peripheral != self.peripheral)
	{
		return;
	}
    
	//	DebugLog(@"discover error: %@", error);
    if (error != nil)
	{
		return;
	}
	
	NSArray *services = [peripheral services];
	if (!services || ![services count])
	{
		return;
	}
	
	self.remainingServicesToDiscover = [services count];
	
	for (CBService *service in services)
	{
		[peripheral discoverCharacteristics:nil forService:service];
	}
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    if (error != nil)
	{
		return;
	}
    
	
	//DebugLog(@"discovered: %@", service.UUID);
	self.remainingServicesToDiscover--;

	if (self.remainingServicesToDiscover == 0)
	{
		[self.delegate didDiscoverCharacterisics:self];
	}
}

#pragma mark - Utilities
- (void) startNotifyingForServiceUUID:(NSString *) serviceUUID andCharacteristicUUID:(NSString *) charUUID
{
	CBCharacteristic *characteristic = [self findCharacteristicWithServiceUUID:serviceUUID andCharacteristicUUID:charUUID];
	if (characteristic)
	{
		[self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
	}
}

- (void) stopNotifyingForServiceUUID:(NSString *) serviceUUID andCharacteristicUUID:(NSString *) charUUID
{
	CBCharacteristic *characteristic = [self findCharacteristicWithServiceUUID:serviceUUID andCharacteristicUUID:charUUID];
	if (characteristic)
	{
		[self.peripheral setNotifyValue:NO forCharacteristic:characteristic];
	}
}

- (void) setValue:(NSData *) data forServiceUUID:(NSString *) serviceUUID andCharacteristicUUID:(NSString *) charUUID
{
	CBCharacteristic *characteristic = [self findCharacteristicWithServiceUUID:serviceUUID andCharacteristicUUID:charUUID];
	if (characteristic)
	{
		[self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
	}
}

- (void) readValueForServiceUUID:(NSString *) serviceUUID andCharacteristicUUID:(NSString *) charUUID
{
	CBCharacteristic *characteristic = [self findCharacteristicWithServiceUUID:serviceUUID andCharacteristicUUID:charUUID];
	if (characteristic)
	{
		[self.peripheral readValueForCharacteristic:characteristic];
	}
}

- (CBCharacteristic *) findCharacteristicWithServiceUUID:(NSString *) serviceUUID andCharacteristicUUID:(NSString *) charUUID
{
    for (CBService *service in [self.peripheral services])
	{
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:serviceUUID]] )
		{
            for (CBCharacteristic *characteristic in [service characteristics])
			{
                if ( [[characteristic UUID] isEqual:[CBUUID UUIDWithString:charUUID]] )
				{
					return characteristic;
                }
            }
        }
    }
	
	return nil;
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	if (peripheral != self.peripheral)
	{
		return ;
	}
	
    if ([error code] != 0)
	{
		return ;
	}
	
	[self.delegate didUpdateValue:self forServiceUUID:characteristic.service.UUID withCharacteristicUUID:characteristic.UUID withData:[characteristic value]];
}
@end
