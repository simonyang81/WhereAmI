//
//  ViewController.m
//  WhereAmI
//
//  Created by Simon Yang on 10/24/16.
//  Copyright © 2016 Simon Yang. All rights reserved.
//

#import "ViewController.h"
#import "Place.h"

@interface ViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *previousPoint;
@property (assign, nonatomic) CLLocationDistance totalMovementDistance;

@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *horizontalAccuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *verticalAccuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceTraveledLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.locationManager = [[CLLocationManager alloc] init];

    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    [self.locationManager requestWhenInUseAuthorization];

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

    NSLog(@"Authorization status changed to %d", status);

    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
            self.mapView.showsUserLocation = YES;
            break;

        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            [self.locationManager stopUpdatingLocation];
            self.mapView.showsUserLocation = NO;
            break;
    }

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

    NSString *errorType = error.code == kCLErrorDenied ? @"Access Denied" :
            [NSString stringWithFormat:@"Error %ld", (long) error.code, nil];
    UIAlertController *alertController
            = [UIAlertController alertControllerWithTitle:@"Location Message Error"
                                                  message:errorType
                                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {

    CLLocation *newLocation = [locations lastObject];
    NSString *latitudeString = [NSString stringWithFormat:@"%g\u00B0", newLocation.coordinate.latitude];
    self.latitudeLabel.text = latitudeString;

    NSString *longitudeString = [NSString stringWithFormat:@"%g\u00B0", newLocation.coordinate.longitude];
    self.longitudeLabel.text = longitudeString;

    NSString *horizontalAccuracyString = [NSString stringWithFormat:@"%gm", newLocation.horizontalAccuracy];
    self.horizontalAccuracyLabel.text = horizontalAccuracyString;

    NSString *altitudeString = [NSString stringWithFormat:@"%gm", newLocation.altitude];
    self.altitudeLabel.text = altitudeString;

    NSString *verticalAccuracyString = [NSString stringWithFormat:@"%gm", newLocation.verticalAccuracy];
    self.verticalAccuracyLabel.text = verticalAccuracyString;

    if (newLocation.verticalAccuracy < 0 || newLocation.horizontalAccuracy < 0) {
        return;
    }

    if (newLocation.horizontalAccuracy > 100 || newLocation.verticalAccuracy > 50) {
        return;
    }

    if (self.previousPoint == nil) {
        self.totalMovementDistance = 0;

        Place *start = [Place new];
        start.coordinate = newLocation.coordinate;
        start.title = @"Start Point";
        start.subtitle = @"This is where we started";
        [self.mapView addAnnotation:start];

        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 100, 100);
        [self.mapView setRegion:region animated:YES];

    } else {
        NSLog(@"movement distance: %f", [newLocation distanceFromLocation:self.previousPoint]);
        self.totalMovementDistance += [newLocation distanceFromLocation:self.previousPoint];
    }

    self.previousPoint = newLocation;

    NSString *distanceString = [NSString stringWithFormat:@"%gm", self.totalMovementDistance];
    self.distanceTraveledLabel.text = distanceString;


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
