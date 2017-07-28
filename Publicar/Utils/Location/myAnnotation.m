//
//  myAnnotation.m
//  iPublicar
//
//  Created by Gunther Vottela on 29/10/09.
//  Copyright 2009 International Development and Consulting Group S.A. All rights reserved.
//

#import "myAnnotation.h"


@implementation myAnnotation

@synthesize coordinate;

- (NSString *)subtitle{
	return mSubTitle;
}
- (NSString *)title{
	return mTitle;
}

- (NSString *)imagen{
	return mImagen;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c title:(NSString*)title subTitle:(NSString*)subTitle  subImagen:(NSString*)Imagen{
	coordinate=c;
	mTitle = title;
	mSubTitle = subTitle;
    mImagen = Imagen;
	return self;
}


@end