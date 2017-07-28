//
//  ViewController.h
//  Publicar
//
//  Created by BitGray on 7/26/17.
//  Copyright © 2017 BitGray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCLController.h"

@interface ViewController : UIViewController{
    CLLocationManager *locationManager;
    //Location
    MyCLController *_MyCLController;
}

@property(nonatomic,strong)NSMutableArray * cities;


// UIView

@property(nonatomic,strong)UIBarButtonItem *barButtonNext;
@property(nonatomic,weak)IBOutlet UIButton * btnCity;
@property(nonatomic,weak)IBOutlet UIView * viewBackCity;
@property(nonatomic,weak)IBOutlet UILabel * lblCity;

@property(nonatomic,weak)IBOutlet UITextField * txtSearch;

@property(nonatomic,weak)IBOutlet UIView * viewSelectCity;
@property(nonatomic,weak)IBOutlet UIPickerView * picker;

@end

