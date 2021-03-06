//
//  ViewController.m
//  BluetoothDiscover
//
//  Created by Klaus Bauernfeind on 01.03.13.
//  Copyright (c) 2013 Klaus Bauernfeind. All rights reserved.
//

#import "ViewController.h"
#import "BluetoothLEManager.h"
#import "BluetoothLEService.h"

#import "ObjTempViewController.h"
#import "AmbTempViewController.h"
#import "HumViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [BluetoothLEManager sharedManagerWithDelegate:self];
    [[BluetoothLEManager sharedManager] discoverDevices];
    self.connectLabel.textColor = [UIColor redColor];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    

    // Dispose of any resources that can be recreated.
}

- (void) didDiscoverPeripheral:(CBPeripheral *) peripheral advertisementData:(NSDictionary *) advertisementData
{
	// Determine if this is the peripheral we want. If it is,
	// we MUST stop scanning before connecting
	NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
	if (localName && [localName caseInsensitiveCompare:@"SensorTag"] == NSOrderedSame)
	{
		[[BluetoothLEManager sharedManager] stopScanning];
		if (self.peripheral == nil)
		{
			NSLog(@"SensorTag found");
            self.peripheral = peripheral;
            [[BluetoothLEManager sharedManager] connectPeripheral:self.peripheral];
		}
	}
}

- (void) didConnectPeripheral:(CBPeripheral *) peripheral error:(NSError *)error
{
	self.peripheral = peripheral;
    self.service = [[BluetoothLEService alloc] initWithPeripheral:self.peripheral withServiceUUIDs:[SensorTag serviceUUIDsToMonitor]  delegate:self];
    [self.service discoverServices];
    self.connectLabel.text = @"Connected";
    self.connectLabel.textColor = [UIColor greenColor];
    [self.connectSwitch setOn:YES];
    NSLog(@"Connected");
    
	
}

- (void) didDisconnectPeripheral:(CBPeripheral *) peripheral error:(NSError *)error
{
    self.connectLabel.text = @"Disconnected";
    self.connectLabel.textColor = [UIColor redColor];
    NSLog(@"Disconnected");
    [self.connectSwitch setOn:NO];
    self.peripheral = nil;
    
}

- (void) didChangeState:(CBCentralManagerState) newState
{
	
}

- (void) didUpdateValue:(BluetoothLEService *) service forServiceUUID:(CBUUID *) serviceUUID withCharacteristicUUID:(CBUUID *) characteristicUUID withData:(NSData *) data
{
    if (self.sensorTag == nil)
	{
		self.sensorTag = [[SensorTag alloc] init];
	}
    [self.sensorTag processCharacteristicDataWithServiceID:serviceUUID withCharacteristicID:characteristicUUID withData:data];
    
    if ((self.sensorTag.hasObjectTemperature) && (self.objTempSwitch.isOn))
	{
		double temp = self.sensorTag.objectTemperature;
        NSString *scaleAbbreviation = @"C";
        //self.tempLabel.text = [NSString stringWithFormat:@"%0.2fº %@", temp, scaleAbbreviation];
        ObjTempViewController *controller = [self.parentViewController.childViewControllers objectAtIndex:1];
        [controller.tempData addObject:[NSDecimalNumber numberWithDouble:temp]];
        controller.tempLabel.text = [NSString stringWithFormat:@"%0.2fº %@", temp, scaleAbbreviation];
        
        [controller rangeUpdate];
	}
    
    if ((self.sensorTag.hasAmbientTemperature) && (self.ambTempSwitch.isOn))
	{
        double temp = self.sensorTag.ambientTemperature;
        NSString *scaleAbbreviation = @"C";
        //self.tempAmbientLabel.text = [NSString stringWithFormat:@"%0.2fº %@", temp, scaleAbbreviation];
        AmbTempViewController *controller = [self.parentViewController.childViewControllers objectAtIndex:2];
        [controller.tempData addObject:[NSDecimalNumber numberWithDouble:temp]];
        controller.tempLabel.text = [NSString stringWithFormat:@"%0.2fº %@", temp, scaleAbbreviation];

        
        [controller rangeUpdate];
	}
    
    if ((self.sensorTag.hasRelativeHumidity) && (self.humSwitch.isOn))
    {
        double hum = self.sensorTag.relativeHumidity;
        NSString *scaleAbbreviation = @"%";
        //self.humidityLabel.text = [NSString stringWithFormat:@"%0.2f %@", hum, scaleAbbreviation];
        HumViewController *controller = [self.parentViewController.childViewControllers objectAtIndex:3];
        [controller.data addObject:[NSDecimalNumber numberWithDouble:hum]];
        controller.humLabel.text = [NSString stringWithFormat:@"%0.2fº %@", hum, scaleAbbreviation];
        [controller rangeUpdate];
    }
    
}

- (void) didDiscoverCharacterisics:(BluetoothLEService *) service
{
    NSLog(@"start monitoring");
	[service startMonitoringTemperatureSensor];
    [service startMonitoringHumiditySensor];
}

- (IBAction)connectSwitchSwitched:(id)sender {
    if(self.connectSwitch.on) {
        [[BluetoothLEManager sharedManager] discoverDevices];
        
    }
    else
    {
        [[BluetoothLEManager sharedManager] disconnectPeripheral:self.peripheral];
        [[BluetoothLEManager sharedManager] stopScanning];
        [self.service stopMonitoringTemperatureSensor];
        [self.service stopMonitoringHumiditySensor];
        self.tempLabel.text = @"--.--°C";
        self.tempAmbientLabel.text = @"--.--°C";
        self.humidityLabel.text = @"--.--%";
        
    }
    
}
@end
