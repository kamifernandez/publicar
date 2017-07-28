//
//  MapLocationViewController.m
//  Publicar
//
//  Created by BitGray on 7/28/17.
//  Copyright © 2017 BitGray. All rights reserved.
//

#import "MapLocationViewController.h"
#import "MyAnnotationView.h"
#import "myAnnotation.h"
#import "utility.h"

@interface MapLocationViewController ()

@end

@implementation MapLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configurerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configurerView{
    
    NSString * title = [self.dataArray objectForKey:@"commercialName"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.shadowColor = [UIColor clearColor];
    label.backgroundColor = [UIColor clearColor];
    label.textColor =[UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if(version >=8.0){
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:(id)self];
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
        [locationManager requestWhenInUseAuthorization];
        [locationManager startMonitoringSignificantLocationChanges];
        [locationManager startUpdatingLocation];
    }else{
        //Location
        _MyCLController = [[MyCLController alloc] init];
        [_MyCLController.locationManager startUpdatingLocation];
    }
}

#pragma mark - Custom Methods

-(void)updateMap{
    BOOL gpsActivo = [utility consultarGpsActivo];
    if (gpsActivo) {
        NSUserDefaults * _defaults = [NSUserDefaults standardUserDefaults];
        double latitud = [[_defaults objectForKey:@"latitud"] doubleValue];
        double longitud = [[_defaults objectForKey:@"longitud"] doubleValue];
        
        if (latitud == 0.0) {
            [self performSelector:@selector(updateMap) withObject:nil afterDelay:1.0];
        }else{
            MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
            region.center.latitude = latitud;
            region.center.longitude = longitud;
            region.span.longitudeDelta = 0.005f;
            region.span.longitudeDelta = 0.005f;
            [self.mapa setRegion:region animated:YES];
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
            singleTap.numberOfTapsRequired = 1;
            singleTap.numberOfTouchesRequired = 1;
            [self.mapa addGestureRecognizer:singleTap];
            
            [self setcoords];
        }
    }else{
        //[self mapaGoogle];
        NSMutableDictionary *msgDict=[[NSMutableDictionary alloc] init];
        [msgDict setValue:@"Sobre Ruedas" forKey:@"Title"];
        [msgDict setValue:@"¿Tu GPS no está activo, deseas activarlo para poder ayudarte?" forKey:@"Message"];
        [msgDict setValue:@"Cancelar" forKey:@"Cancel"];
        [msgDict setValue:@"1" forKey:@"alert"];
        [msgDict setValue:@"Activarlo" forKey:@"Aceptar"];
        [msgDict setValue:@"102" forKey:@"Tag"];
        
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:msgDict
                            waitUntilDone:YES];
    }
}

#pragma mark - Map Methods

- (void)setcoords{
    
    lat = 0.5;
    lon = 0.5;
    
    MKCoordinateSpan span;
    
    span.latitudeDelta=lat;
    span.longitudeDelta=lat;
    
    
    NSArray *annotationArrs = self.mapa.annotations;
    if(annotationArrs!=nil)
    {
        [self.mapa removeAnnotations:annotationArrs];
    }
    
    CLLocationCoordinate2D location;
    
    location.latitude=[[self.dataArray objectForKey:@"latitude"] doubleValue];
    location.longitude=[[self.dataArray objectForKey:@"longitude"] doubleValue];
    myAnnotation *addAnnotation = [[myAnnotation alloc] initWithCoordinate:location title:@" " subTitle:@" " subImagen:@" "];
    [self.mapa addAnnotation:addAnnotation];
    
    [self recenterMap];

}

- (void)recenterMap {
    
    NSArray *coordinates = [self.mapa valueForKeyPath:@"annotations.coordinate"];
    
    
    CLLocationCoordinate2D maxCoord = {-90.0f, -180.0f};
    
    CLLocationCoordinate2D minCoord = {90.0f, 180.0f};
    
    
    for(NSValue *value in coordinates) {
        
        CLLocationCoordinate2D coord = {0.0f, 0.0f};
        
        [value getValue:&coord];
        
        if(coord.longitude > maxCoord.longitude) {
            
            maxCoord.longitude = coord.longitude;
            
        }
        
        if(coord.latitude > maxCoord.latitude) {
            
            maxCoord.latitude = coord.latitude;
            
        }
        
        if(coord.longitude < minCoord.longitude) {
            
            minCoord.longitude = coord.longitude;
            
        }
        
        if(coord.latitude < minCoord.latitude) {
            
            minCoord.latitude = coord.latitude;
            
        }
        
    }
    
    MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
    
    region.center.longitude = (minCoord.longitude + maxCoord.longitude) / 2.0;
    
    region.center.latitude = (minCoord.latitude + maxCoord.latitude) / 2.0;
    
    region.span.longitudeDelta = maxCoord.longitude - minCoord.longitude;
    
    region.span.latitudeDelta = maxCoord.latitude - minCoord.latitude;
    
    [self.mapa setRegion:region animated:YES];
    
}

#pragma mark - Map Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    NSUserDefaults *_defaults = [NSUserDefaults standardUserDefaults];
    
    //NSLog(@"%f",annotation.coordinate.latitude);
    //NSLog(@"%f",[[_defaults objectForKey:@"latitude"] doubleValue]);
    
    
    if (annotation.coordinate.latitude == [[_defaults objectForKey:@"latitud"] doubleValue]) {
        return nil;
    }

    static NSString *identifier = @"myAnnotation";
    MyAnnotationView * annotationView = (MyAnnotationView *)[self.mapa dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    button.frame = CGRectMake(0, 0, 37, 56);
    annotationView.rightCalloutAccessoryView = button;
    
    if (!annotationView)
    {
        annotationView = [[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.image = [UIImage imageNamed:@"ic_person_pin_circle.png"];
        
    }else {
        annotationView = [[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.image = [UIImage imageNamed:@"ic_person_pin_circle.png"];
        annotationView.annotation = annotation;
    }
    annotationView.tag = 0;
    return annotationView;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    if (![view.annotation isKindOfClass:[MKUserLocation class]]){
        
        NSArray *selectedAnnotations = mapView.selectedAnnotations;
        for(id annotation in selectedAnnotations) {
            [self.mapa deselectAnnotation:annotation animated:NO];
        }
        
        if (self.viewMap) {
            [self.viewMap removeFromSuperview];
            self.viewMap = nil;
        }
        
        [[NSBundle mainBundle] loadNibNamed:@"CustomViewMap" owner:self options:nil];
        [view addSubview:self.viewMap];
    addSubview:self.viewMap.center = CGPointMake(view.bounds.size.width*0.5f, -self.viewMap.bounds.size.height*0.5f);
        
        [self.lblTittle setText:[self.dataArray objectForKey:@"commercialName"]];
        
        [self.lblStreet setText:[NSString stringWithFormat:@"Dirección: %@",[self.dataArray objectForKey:@"street"]]];
        
        [self.lblPhone setText:[NSString stringWithFormat:@"Télefono: %@",[self.dataArray objectForKey:@"number"]]];
        
        float latitude = [[self.dataArray objectForKey:@"latitude"] floatValue];
        float longitude = [[self.dataArray objectForKey:@"longitude"] floatValue];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude;
        coordinate.longitude = longitude;
        
        [mapView setCenterCoordinate:coordinate animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    for (UIView *i in view.subviews)
        [i removeFromSuperview];
}

#pragma mark - Delegate Location

- (void)requestAlwaysAuthorization{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"Para utilizar la localización debe activar esta opción en Ajustes -> Servicios de localización -> Siempre";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestAlwaysAuthorization];
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSUserDefaults * _defaults = [NSUserDefaults standardUserDefaults];
    if (status == kCLAuthorizationStatusDenied) {
        // permission denied
        [self updateMap];
    }
    else if (status == kCLAuthorizationStatusAuthorizedAlways) {
        //[self updateMap];
    }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_defaults setObject:@"YES" forKey:@"verifyGps"];
        [self updateMap];
    }
    [_defaults setObject:@"YES" forKey:@"gps"];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError: %@", error);
    /*UIAlertView *errorAlert = [[UIAlertView alloc]
     initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [errorAlert show];*/
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil) {
        NSUserDefaults *_defaults = [NSUserDefaults standardUserDefaults];
        [_defaults setObject:[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude] forKey:@"latitud"];
        [_defaults setObject:[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude] forKey:@"longitud"];
        [_defaults setObject:@"0" forKey:@"ciudadUsuario"];
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            for (CLPlacemark * placemark in placemarks) {
                [_defaults setObject:placemark.locality forKey:@"ciudadUsuario"];
            }
        }];
    }
}

#pragma mark - IBActions

-(IBAction)clickViewMap:(id)sender{
    
}

#pragma mark - Gesture Recognizer

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    NSArray *selectedAnnotations = self.mapa.selectedAnnotations;
    for(id annotation in selectedAnnotations) {
        [self.mapa deselectAnnotation:annotation animated:NO];
    }
    
    if (self.viewMap) {
        [self.viewMap removeFromSuperview];
        self.viewMap = nil;
    }
}

#pragma mark - showAlert metodo

-(void)showAlert:(NSMutableDictionary *)msgDict
{
    if ([[msgDict objectForKey:@"Aceptar"] length]>0) {
        UIAlertView *alert=[[UIAlertView alloc]
                            initWithTitle:[msgDict objectForKey:@"Title"]
                            message:[msgDict objectForKey:@"Message"]
                            delegate:self
                            cancelButtonTitle:[msgDict objectForKey:@"Cancel"]
                            otherButtonTitles:[msgDict objectForKey:@"Aceptar"],nil];
        [alert setTag:[[msgDict objectForKey:@"Tag"] intValue]];
        [alert show];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]
                            initWithTitle:[msgDict objectForKey:@"Title"]
                            message:[msgDict objectForKey:@"Message"]
                            delegate:self
                            cancelButtonTitle:[msgDict objectForKey:@"Cancel"]
                            otherButtonTitles:nil];
        [alert setTag:[[msgDict objectForKey:@"Tag"] intValue]];
        [alert show];
    }
}

@end
