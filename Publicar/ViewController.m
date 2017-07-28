//
//  ViewController.m
//  Publicar
//
//  Created by BitGray on 7/26/17.
//  Copyright © 2017 BitGray. All rights reserved.
//

#import "ViewController.h"
#import "ShopsViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurerView];
}

-(void)configurerView{
    self.cities = [[NSMutableArray alloc] initWithObjects:@"Bogotá", @"Bucaramanga",@"Medellín", nil];
    
    NSString * title = @"Elige tu ciudad";
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.shadowColor = [UIColor clearColor];
    label.backgroundColor = [UIColor clearColor];
    label.textColor =[UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    [self.viewBackCity.layer setCornerRadius:5.0];
    
    self.barButtonNext = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(next:)];
    self.barButtonNext.tintColor = [UIColor blackColor];
    [self.barButtonNext setEnabled:FALSE];
    self.navigationItem.rightBarButtonItem = self.barButtonNext;
    
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

#pragma mark IBAction


-(IBAction)getCity:(id)sender{
    [[NSBundle mainBundle] loadNibNamed:@"ViewSelectCity" owner:self options:nil];
    [self.viewSelectCity setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.picker reloadAllComponents];
    NSString *title = [self.cities objectAtIndex:0];
    self.lblCity.text = title;
    [self.barButtonNext setEnabled:TRUE];
    [self.view addSubview:self.viewSelectCity];
}

-(IBAction)selectCity:(id)sender{
    [self.viewSelectCity removeFromSuperview];
    self.viewSelectCity = nil;
}

-(void)next:(id)sender{
    if (self.txtSearch.text.length > 0) {
        [self.txtSearch resignFirstResponder];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ShopsViewController *vc = [story instantiateViewControllerWithIdentifier:@"ShopsViewController"];
        vc.city = self.lblCity.text;
        vc.search = self.txtSearch.text;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        NSMutableDictionary *msgDict=[[NSMutableDictionary alloc] init];
        [msgDict setValue:@"Publicar" forKey:@"Title"];
        [msgDict setValue:@"Por favor ingresa una búsqueda" forKey:@"Message"];
        [msgDict setValue:@"Aceptar" forKey:@"Cancel"];
        [msgDict setValue:@"" forKey:@"Aceptar"];
        [msgDict setValue:@"0" forKey:@"Tag"];
        
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:msgDict
                            waitUntilDone:YES];
    }
}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.view endEditing:TRUE];
    
    return true;
}

#pragma mark UiPicker Delegates

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    int countData = (int)[self.cities count];
    return countData;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = [self.cities objectAtIndex:row];
    return title;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *title = [self.cities objectAtIndex:row];
    self.lblCity.text = title;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [self.cities objectAtIndex:row];
    NSAttributedString *attString =
    [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    return attString;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
    else if (status == kCLAuthorizationStatusAuthorizedAlways) {
        //[self updateMap];
    }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_defaults setObject:@"YES" forKey:@"verifyGps"];
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

@end
