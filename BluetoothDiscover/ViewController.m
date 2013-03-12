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
    [self graphInit];
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
    
    if (self.sensorTag.hasObjectTemperature)
	{
		double temp = self.sensorTag.objectTemperature;
        NSString *scaleAbbreviation = @"C";
        self.tempLabel.text = [NSString stringWithFormat:@"%0.2fº %@", temp, scaleAbbreviation];
        [self.tempData addObject:[NSDecimalNumber numberWithDouble:temp]];
        [self rangeUpdate];
	}
    
    if (self.sensorTag.hasAmbientTemperature)
	{
        double temp = self.sensorTag.ambientTemperature;
        NSString *scaleAbbreviation = @"C";
        self.tempAmbientLabel.text = [NSString stringWithFormat:@"%0.2fº %@", temp, scaleAbbreviation];
        
        
	}
    
    if (self.sensorTag.hasRelativeHumidity)
    {
        double hum = self.sensorTag.relativeHumidity;
        NSString *scaleAbbreviation = @"%";
        self.humidityLabel.text = [NSString stringWithFormat:@"%0.2f %@", hum, scaleAbbreviation];
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

// Diagramm
-(void)graphInit {
    self.tempGraph = [[CPTXYGraph alloc] initWithFrame: self.graphView.bounds];      //Diagramm initialisieren mit der gleichen Größe wie der View
    
    self.tempData = [[NSMutableArray alloc] init];
    
    
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];  // Design für das Diagramm erstellen
    [self.tempGraph applyTheme:theme];      // das Design dem Diagramm zuweisen
    
    self.graphView.hostedGraph = self.tempGraph;        // Das Diagramm den View zuweisen
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.tempGraph.axisSet;     // Achsen erzeugen um Anpassungen zu machen
    CPTXYAxis *x = axisSet.xAxis;       // x-Achse definieren
    x.majorIntervalLength = CPTDecimalFromString(@"1.0");   // Punkteabstand auf der x-Achse
    x.minorTicksPerInterval = 1;    // Anzahl der kleinen Punkte zwischen den Punkten
    
    // Define the space for the steps.
    self.plotSpace = (CPTXYPlotSpace *)self.tempGraph.defaultPlotSpace;      // Platz erstellen, wo die Kurven gezeichnet werden
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)        // Bereich der y-Achse einstellen
                                                         length:CPTDecimalFromFloat(30)];
    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)      // Bereich der x-Achse einstellen
                                                         length:CPTDecimalFromFloat(11)];
    
    // ScatterPlot Temp
    CPTScatterPlot *linePlot = [[CPTScatterPlot alloc] init];   // Liniendiagramm initialisieren
    linePlot.identifier = @"LinienDiagramm";        // Dem Liniendiagramm eine Kennung/Namen geben
    
    CPTMutableLineStyle *lineStyle = [linePlot.dataLineStyle mutableCopy];      // Linienstiel initialisieren und vom standard Stiel uebernehmen
    lineStyle.lineWidth = 3.f;      // Linienbreite einstellen
    lineStyle.lineColor = [CPTColor blueColor];        // Linienfarbe einstellen
    linePlot.dataLineStyle = lineStyle;     // Den Linienstiel dem Liniendiagramm zuweisen
    
    linePlot.dataSource = self;     // Die Datenquelle für das Diagramm auf diesen ViewController einstellen
    [self.tempGraph addPlot: linePlot];     // Das Liniendiagramm zum Diagramm hinzufügen
}

-(void)rangeUpdate {
    
    NSArray *array = self.tempData;
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingDescriptors:sortDescriptors];
    //NSLog(@"%@", sortedArray);
    float ymin, ymax, xmin, xmax;
    int count = [self.tempData count];
    
    ymin = [[sortedArray objectAtIndex:0] floatValue];
    ymax = [[sortedArray objectAtIndex:count - 1] floatValue];
    
    xmin = 0;
    xmax = count - 1;
    
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                         length:CPTDecimalFromFloat(ymax + 1)];
    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xmin)
                                                         length:CPTDecimalFromFloat(xmax)];
    [self.tempGraph reloadData];
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [self.tempData count];
    //return 1001;        // Anzahl der zu berechnenden Punkte einstellen
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    
    //double val = (idx/50.0)-5;      // x-Wert initialisieren, so dass er zwischen -5 und +5 liegt mit einer Schrittweite von 0,02
    //double val = idx % 12;
    if(fieldEnum == CPTScatterPlotFieldX) {
        return [NSNumber numberWithDouble:idx];     // der x-Wert für den aktuellen Punkt wird zurueckgegeben
    }
    else
    {
        if([plot.identifier isEqual: @"LinienDiagramm"]) {
            //return [NSNumber numberWithDouble:sin(val)];      // Der y-Wert für den aktuellen Punkt wird zurückgegeben
            return [self.tempData objectAtIndex:idx];
        }
    }
    return nil;
}

- (IBAction)resetDiagram:(id)sender {
    self.tempData = nil;
    self.tempData = [[NSMutableArray alloc] init];
}
@end
