//
//  ParseXML.h
//  Publicar
//
//  Created by BitGray on 7/26/17.
//  Copyright © 2017 BitGray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseXML : NSObject <NSXMLParserDelegate>

@property(nonatomic,strong)NSMutableString *currentElementValue;
@property(nonatomic,strong)NSString *numbers;

@property(nonatomic,strong)NSMutableDictionary * dataParseXml;
@property(nonatomic,strong)NSMutableArray * arrayDataParseXml;

// Called Methods

-(NSMutableArray *)calledParse:(NSString *)what andWhere:(NSString *)where andPage:(NSString *)page;

@end
