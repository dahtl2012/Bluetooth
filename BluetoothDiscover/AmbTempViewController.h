//
//  AmbTempViewController.h
//  Thermometer
//
//  Created by Dominik Arnhof on 13.03.13.
//  Copyright (c) 2013 Klaus Bauernfeind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface AmbTempViewController : UIViewController <CPTPlotDataSource>

@property NSMutableArray *tempData;

@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;
@property (weak, nonatomic) IBOutlet UISlider *rangeSlider;

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphView;
@property CPTXYGraph *tempGraph;        // Diagramm
@property CPTXYPlotSpace *plotSpace;

- (IBAction)resetDiagram:(id)sender;

- (void) rangeUpdate;
- (IBAction)rangeSliderSlided:(id)sender;

@end
