//
//  MyCLController.m
//  iPublicar
//
//  Created by Gunther Vottela on 30/09/09.
//

#import "MyCLController.h"

@implementation MyCLController

@synthesize locationManager;

- (id) init {
    self = [super init];
    if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; // send loc updates to myself
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
	
	NSUserDefaults *_defaults = [NSUserDefaults standardUserDefaults];
	
    [_defaults setObject:[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude] forKey:@"latitudUsuario"];
    [_defaults setObject:[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude] forKey:@"longitudUsuario"];
    [_defaults setObject:@"0" forKey:@"ciudadUsuario"];
    
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            [_defaults setObject:placemark.locality forKey:@"ciudadUsuario"];
        }
    }];
	
	[self.delegate locationUpdate:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
		[self.delegate locationError:error];

}


@end
