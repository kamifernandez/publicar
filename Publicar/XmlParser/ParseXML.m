//
//  ParseXML.m
//  Publicar
//
//  Created by BitGray on 7/26/17.
//  Copyright © 2017 BitGray. All rights reserved.
//

#import "ParseXML.h"

@implementation ParseXML

-(NSMutableArray *)calledParse:(NSString *)what andWhere:(NSString *)where andPage:(NSString *)page
{
    NSString * whereWhitOutAccents = [[NSString alloc]
                  initWithData:
                  [where dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                  encoding:NSASCIIStringEncoding];
    
    NSString * whatWhitOutAccents = [[NSString alloc]
                                      initWithData:
                                      [what dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                                      encoding:NSASCIIStringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:@"http://ws3.paginasamarillas.com/SearchService2.3.0/MobileService.aspx?op=BasicSearch&QueryId=&What=%@&Where=%@&Country=Colombia&directoryId=1&language=1&PageSize=%@",whatWhitOutAccents,whereWhitOutAccents,page];
    /*NSString *urlString = @"http://ws3.paginasamarillas.com/SearchService2.3.0/MobileService.aspx?op=BasicSearch&QueryId=&What=restaurantes&Where=Bogota&Country=Colombia&directoryId=1&language=1&PageSize=10";*/
    NSLog(@"URL %@",urlString);
    NSURL *url=[NSURL URLWithString:urlString];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [xmlParser setDelegate:self];
    [xmlParser parse];
    return self.arrayDataParseXml;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict {
    
    if([elementName isEqualToString:@"advertises"]) {
        self.arrayDataParseXml = [[NSMutableArray alloc] init];
    }
    else if([elementName isEqualToString:@"advertise"]) {
        
        self.dataParseXml = [NSMutableDictionary new];
        
        
        //Extract the attribute here.
        [self.dataParseXml setObject:[attributeDict objectForKey:@"commercialName"] forKey:@"commercialName"];
        
        NSLog(@"Reading commercialName value :%@", [self.dataParseXml objectForKey:@"commercialName"]);
        
        [self.dataParseXml setObject:[attributeDict objectForKey:@"latitude"] forKey:@"latitude"];
        [self.dataParseXml setObject:[attributeDict objectForKey:@"longitude"] forKey:@"longitude"];
        
    }else if([elementName isEqualToString:@"address"]) {
        
        //Extract the attribute here.
        [self.dataParseXml setObject:[attributeDict objectForKey:@"street"] forKey:@"street"];
        //book.bookID = [[attributeDict objectForKey:@"id"] integerValue];
        
        NSLog(@"Reading street value :%@", [self.dataParseXml objectForKey:@"street"]);
    }else if([elementName isEqualToString:@"phone"]) {
        
        
        if (self.numbers.length == 0) {
            self.numbers = [attributeDict objectForKey:@"number"];
        }else{
            self.numbers = [self.numbers stringByAppendingString:[attributeDict objectForKey:@"number"]];
            self.numbers = [self.numbers stringByAppendingString:@", "];
        }
        
        [self.dataParseXml setObject:self.numbers forKey:@"number"];
        //book.bookID = [[attributeDict objectForKey:@"id"] integerValue];
        
        NSLog(@"Reading street value :%@", [self.dataParseXml objectForKey:@"number"]);
    }else if([elementName isEqualToString:@"product"]) {
        
        if ([attributeDict objectForKey:@"value"]) {
            if (![self.dataParseXml objectForKey:@"value"]) {
                NSString *trimmedString=[[attributeDict objectForKey:@"value"] substringFromIndex:MAX((int)[[attributeDict objectForKey:@"value"] length]-3, 0)];
                if ([trimmedString isEqualToString:@"gif"] || [trimmedString isEqualToString:@"jpg"]) {
                    [self.dataParseXml setObject:[attributeDict objectForKey:@"value"] forKey:@"value"];
                }
            }
            //book.bookID = [[attributeDict objectForKey:@"id"] integerValue];
            
            NSLog(@"Reading street value :%@", [self.dataParseXml objectForKey:@"number"]);
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if(!self.currentElementValue)
        self.currentElementValue = [[NSMutableString alloc] initWithString:string];
    else
        [self.currentElementValue appendString:string];
    
    NSLog(@"Processing Value: %@", self.currentElementValue);
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if([elementName isEqualToString:@"advertises"])
        return;
    
    //There is nothing to do if we encounter the Books element here.
    //If we encounter the Book element howevere, we want to add the book object to the array
    // and release the object.
    
    if([elementName isEqualToString:@"advertise"]) {
        self.numbers = @"";
        [self.arrayDataParseXml addObject:self.dataParseXml];
        NSLog(@"count Advertised %i",(int)[self.arrayDataParseXml count]);
        NSLog(@"data %@",self.arrayDataParseXml);
        if (self.dataParseXml) {
            self.dataParseXml = nil;
        }
    }
    else{
        //[pelicula setValue:currentElementValue forKey:elementName];
    }
    
}

@end
