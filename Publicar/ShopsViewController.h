//
//  ShopsViewController.h
//  Publicar
//
//  Created by BitGray on 7/26/17.
//  Copyright © 2017 BitGray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopsCollectionViewCell.h"
#import "FTWCache.h"
#import "NSString+MD5.h"

@interface ShopsViewController : UIViewController

@property(nonatomic,strong)NSMutableArray * cities;
@property(nonatomic,strong)NSString *city;
@property(nonatomic,strong)NSString *search;
@property(nonatomic,strong)NSMutableArray * arrayData;

//UIView

@property(nonatomic,strong)UIBarButtonItem *barButtonNext;
@property(nonatomic,strong)IBOutlet UISearchBar *txtBusqueda;
@property(nonatomic,strong)IBOutlet UITextField *txtCity;
@property(nonatomic,strong)IBOutlet UICollectionView* ShopsCollectionView;
@property(nonatomic,strong)IBOutlet UIView* viewCityContent;

@property(nonatomic,weak)IBOutlet UIView * viewSelectCity;
@property(nonatomic,weak)IBOutlet UIPickerView * picker;

// Indicador

@property(nonatomic,weak)IBOutlet UIView *vistaWait;
@property(nonatomic,weak)IBOutlet UIActivityIndicatorView *indicador;

@end
