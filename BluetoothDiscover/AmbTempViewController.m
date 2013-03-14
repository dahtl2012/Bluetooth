//
//  AmbTempViewController.m
//  Thermometer
//
//  Created by Dominik Arnhof on 13.03.13.
//  Copyright (c) 2013 Klaus Bauernfeind. All rights reserved.
//

#import "AmbTempViewController.h"

@interface AmbTempViewController ()

@end

@implementation AmbTempViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tempData = [[NSMutableArray alloc] init];
    self.rangeLabel.text = [NSString stringWithFormat:@"Messwerte im Diagramm: %0.0f", self.rangeSlider.value];
    [self graphInit];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if (self.tempData.count > self.rangeSlider.value) {
        
        while (self.tempData.count > self.rangeSlider.value) {
            [self.tempData removeObjectAtIndex:0];
        }
    }
    
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

- (IBAction)rangeSliderSlided:(id)sender {
    self.rangeLabel.text = [NSString stringWithFormat:@"Messwerte im Diagramm: %0.0f", self.rangeSlider.value];
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
