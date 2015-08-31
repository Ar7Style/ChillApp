//
//  CHLLocationDisplayViewController.m
//  Chill
//
//  Created by Виктор Шаманов on 8/4/14.
//  Copyright (c) 2014 Chill. All rights reserved.
//

#import "CHLLocationDisplayViewController.h"
#import <GoogleMaps/GMSMapView.h>
#import <GoogleMaps/GMSCameraPosition.h>
#import <GoogleMaps/GMSMarker.h>

static CGFloat const CHLLocationDisplayViewControllerDefaultZoom = 15.0;

@interface CHLLocationDisplayViewController ()

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation CHLLocationDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.navigationController.view.layer.cornerRadius=6;
    self.navigationController.view.clipsToBounds=YES;
    self.title = self.locationTitle;
    CLLocationCoordinate2D coordinates = self.location.coordinate;
    
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:coordinates.latitude
                                                                    longitude:coordinates.longitude
                                                                         zoom:CHLLocationDisplayViewControllerDefaultZoom];
    [self.mapView setCamera:cameraPosition];
    
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinates];
    marker.map = self.mapView;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
