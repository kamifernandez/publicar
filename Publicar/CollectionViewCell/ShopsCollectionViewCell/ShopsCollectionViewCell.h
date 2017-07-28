//
//  ShopsCollectionViewCell.h
//  Publicar
//
//  Created by BitGray on 7/27/17.
//  Copyright © 2017 BitGray. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopsCollectionViewCell : UICollectionViewCell

@property(nonatomic,weak)IBOutlet UIImageView * imgPhoto;
@property(nonatomic,weak)IBOutlet UILabel * lblName;
@property(nonatomic,weak)IBOutlet UILabel * lblAddres;
@property(nonatomic,weak)IBOutlet UILabel * lblPhone;
@property(nonatomic,weak)IBOutlet UIActivityIndicatorView * indicator;

@end
