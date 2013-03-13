//
//  HumViewController.h
//  Thermometer
//
//  Created by Dominik Arnhof on 13.03.13.
//  Copyright (c) 2013 Klaus Bauernfeind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface HumViewController : UIViewController <CPTPlotDataSource>

@property NSMutableArray *data;

@property (weak, nonatomic) IBOutlet UILabel *humLabel;

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphView;
@property CPTXYGraph *tempGraph;        // Diagramm
@property CPTXYPlotSpace *plotSpace;

- (IBAction)resetDiagram:(id)sender;

- (void) rangeUpdate;

@end
