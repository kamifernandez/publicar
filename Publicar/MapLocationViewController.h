//
//  MapLocationViewController.h
//  Publicar
//
//  Created by BitGray on 7/28/17.
//  Copyright © 2017 BitGray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCLController.h"
#import <MapKit/MapKit.h>

@interface MapLocationViewController : UIViewController{
    CLLocationManager *locationManager;
    //Location
    MyCLController *_MyCLController;
    int lat;
    int lon;
}

@property(nonatomic,strong)IBOutlet MKMapView * mapa;
@property(nonatomic,strong)NSMutableDictionary * dataArray;

// View map

@property(nonatomic,strong)IBOutlet UIView * viewMap;

@property(nonatomic,strong)IBOutlet UILabel * lblTittle;

@property(nonatomic,strong)IBOutlet UILabel * lblStreet;

@property(nonatomic,strong)IBOutlet UILabel * lblPhone;

@end
