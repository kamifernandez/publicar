//
//  ShopsViewController.m
//  Publicar
//
//  Created by BitGray on 7/26/17.
//  Copyright © 2017 BitGray. All rights reserved.
//

#import "ShopsViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "MapLocationViewController.h"
#import "ParseXML.h"

@interface ShopsViewController (){
    int page;
    BOOL fisrTime;
}

@end

@implementation ShopsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    page = 10;
    fisrTime = YES;
    [self threadCallService];
    [self configurerView];
}

-(void)viewDidDisappear:(BOOL)animated{
    if (self.viewSelectCity) {
        [self.viewSelectCity removeFromSuperview];
        self.viewSelectCity = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)threadCallService{
    NSUserDefaults * _defaults = [NSUserDefaults standardUserDefaults];
    if ([[_defaults objectForKey:@"connectioninternet"] isEqualToString:@"YES"]) {
        if (fisrTime) {
            [self loading];
        }
        NSOperationQueue * queue1 = [[NSOperationQueue alloc] init];
        [queue1 setMaxConcurrentOperationCount:1];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(callParserXML) object:nil];
        [queue1 addOperation:operation];
    }else{
        NSMutableDictionary *msgDict=[[NSMutableDictionary alloc] init];
        [msgDict setValue:@"Atención" forKey:@"Title"];
        [msgDict setValue:@"No tiene conexión a internet." forKey:@"Message"];
        [msgDict setValue:@"Aceptar" forKey:@"Cancel"];
        [msgDict setValue:@"" forKey:@"Aceptar"];
        
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:msgDict
                            waitUntilDone:YES];
    }
}

-(void)configurerView{
    
    self.cities = [[NSMutableArray alloc] initWithObjects:@"Bogotá", @"Bucaramanga",@"Medellín", nil];
    
    NSString * title = @"Comercios";
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.shadowColor = [UIColor clearColor];
    label.backgroundColor = [UIColor clearColor];
    label.textColor =[UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    self.txtBusqueda.text = self.search;
    self.txtCity.text = self.city;
    [self.viewCityContent.layer setBorderWidth:1.0];
    [self.viewCityContent.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    self.barButtonNext = [[UIBarButtonItem alloc] initWithTitle:@"Buscar" style:UIBarButtonItemStylePlain target:self action:@selector(search:)];
    self.barButtonNext.tintColor = [UIColor blackColor];
    [self.barButtonNext setEnabled:true];
    self.navigationItem.rightBarButtonItem = self.barButtonNext;
    
    __weak __typeof(&*self) weakSelf = self;
    
    [self.ShopsCollectionView addInfiniteScrollingWithActionHandler:^{
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"LOAD MORE");
            [weakSelf callParserXML];
        });
    } forPosition:SVInfiniteScrollingPositionBottom];
}

-(void)callParserXML{
    ParseXML * parseXML = [ParseXML new];
    
    NSString *pageSend = [NSString stringWithFormat:@"%i",page];
    NSMutableArray * dataSend = [parseXML calledParse:self.search andWhere:self.city andPage:pageSend];
    [self performSelectorOnMainThread:@selector(finishParseXML:) withObject:dataSend waitUntilDone:YES];
}

-(void)finishParseXML:(NSMutableArray *)dataSend{
    if ([dataSend count] > 0) {
        if (self.arrayData) {
            self.arrayData = nil;
        }
        self.arrayData = [dataSend copy];
        int countArrya = (int)[self.arrayData count];
        if (countArrya > 0) {
            [self.ShopsCollectionView reloadData];
            page += 10;
        }else{
            NSMutableDictionary *msgDict=[[NSMutableDictionary alloc] init];
            [msgDict setValue:@"Publicar" forKey:@"Title"];
            [msgDict setValue:@"No encontramos resultados para tu búsqueda, por favor intenta con otras opciones" forKey:@"Message"];
            [msgDict setValue:@"Aceptar" forKey:@"Cancel"];
            [msgDict setValue:@"" forKey:@"Aceptar"];
            [msgDict setValue:@"0" forKey:@"Tag"];
            
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:msgDict
                                waitUntilDone:YES];
        }
        [[self.ShopsCollectionView infiniteScrollingViewForPosition:SVInfiniteScrollingPositionBottom] stopAnimating];
    }else{
        NSMutableDictionary *msgDict=[[NSMutableDictionary alloc] init];
        [msgDict setValue:@"Publicar" forKey:@"Title"];
        [msgDict setValue:@"No encontramos resultados para tu búsqueda, por favor intenta con otras opciones" forKey:@"Message"];
        [msgDict setValue:@"Aceptar" forKey:@"Cancel"];
        [msgDict setValue:@"" forKey:@"Aceptar"];
        [msgDict setValue:@"0" forKey:@"Tag"];
        
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:msgDict
                            waitUntilDone:YES];
    }
    if (fisrTime) {
        [self loading];
        fisrTime = NO;
    }
}

#pragma mark IBAction


-(IBAction)getCity:(id)sender{
    [[NSBundle mainBundle] loadNibNamed:@"ViewSelectCity" owner:self options:nil];
    [self.viewSelectCity setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.picker reloadAllComponents];
    NSString *title = [self.cities objectAtIndex:0];
    self.txtCity.text = title;
    [self.view addSubview:self.viewSelectCity];
}

-(IBAction)selectCity:(id)sender{
    [self.viewSelectCity removeFromSuperview];
    self.viewSelectCity = nil;
}

-(void)search:(id)sender{
    [self.txtBusqueda resignFirstResponder];
    if (self.viewSelectCity) {
        [self.viewSelectCity removeFromSuperview];
        self.viewSelectCity = nil;
    }
    if (self.txtCity.text.length > 0 && self.txtBusqueda.text.length > 0) {
        self.city = self.txtCity.text;
        self.search = self.txtBusqueda.text;
        page = 10;
        fisrTime = YES;
        [self.ShopsCollectionView setContentOffset:CGPointMake(0, 0) animated:NO];
        [self threadCallService];
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

#pragma mark - CollectionView Delegates


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.arrayData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ShopsCollectionViewCell";
    
    ShopsCollectionViewCell *cell = (ShopsCollectionViewCell *)[self.ShopsCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    if ([[self.arrayData objectAtIndex:indexPath.row] objectForKey:@"value"]) {
        NSString * urlEnvio = [[self.arrayData objectAtIndex:indexPath.row] objectForKey:@"value"];
        NSURL *imageURL = [NSURL URLWithString:urlEnvio];
        NSString *key = [[[self.arrayData objectAtIndex:indexPath.row] objectForKey: @"value"] MD5Hash];
        NSData *data = [FTWCache objectForKey:key];
        if (data) {
            [cell.indicator stopAnimating];
            UIImage *image = [UIImage imageWithData:data];
            if (image != nil) {
                cell.imgPhoto.image = image;
            }else{
                [cell.indicator stopAnimating];
                cell.imgPhoto.image = [UIImage imageNamed:@"placeholder_pic.png"];
            }
        } else {
            //imagen.image = [UIImage imageNamed:@"img_def"];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                NSData *data = [NSData dataWithContentsOfURL:imageURL];
                [FTWCache setObject:data forKey:key];
                UIImage *image = [UIImage imageWithData:data];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [cell.indicator stopAnimating];
                    if (image != nil) {
                        cell.imgPhoto.image = image;
                    }else{
                        cell.imgPhoto.image = [UIImage imageNamed:@"placeholder_pic.png"];
                    }
                });
            });
        }
    }else{
        [cell.indicator stopAnimating];
        cell.imgPhoto.image = [UIImage imageNamed:@"placeholder_pic.png"];
    }
    
    cell.lblName.text = [[self.arrayData objectAtIndex:indexPath.row] objectForKey:@"commercialName"];
    
    cell.lblAddres.text = [[self.arrayData objectAtIndex:indexPath.row] objectForKey:@"street"];
    
    cell.lblPhone.text = [[self.arrayData objectAtIndex:indexPath.row] objectForKey:@"number"];
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (![[[self.arrayData objectAtIndex:indexPath.row] objectForKey:@"latitude"] isEqualToString:@"-1"]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MapLocationViewController *vc = [story instantiateViewControllerWithIdentifier:@"MapLocationViewController"];
        vc.dataArray = [self.arrayData objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        NSMutableDictionary *msgDict=[[NSMutableDictionary alloc] init];
        [msgDict setValue:@"Publicar" forKey:@"Title"];
        [msgDict setValue:@"Disculpanos, aun no ubicamos muy bien este anuncio para tu comodidad, pronto lo tendremos para ti." forKey:@"Message"];
        [msgDict setValue:@"Aceptar" forKey:@"Cancel"];
        [msgDict setValue:@"" forKey:@"Aceptar"];
        [msgDict setValue:@"0" forKey:@"Tag"];
        
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:msgDict
                            waitUntilDone:YES];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    int top = 0;
    int left = 10;
    int bottom = 0;
    int right = 10;
    CGRect bounds = [[UIScreen mainScreen] bounds];
    if ((bounds.size.width < 321)) {
        left = 0;
        right = 0;
    }
    return UIEdgeInsetsMake(top, left, bottom, right);
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
    self.txtCity.text = title;
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

#pragma mark - UISearch Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    if (self.viewSelectCity) {
        [self.viewSelectCity removeFromSuperview];
        self.viewSelectCity = nil;
    }
    if (self.txtCity.text.length > 0 && self.txtBusqueda.text.length > 0) {
        self.city = self.txtCity.text;
        self.search = self.txtBusqueda.text;
        page = 10;
        fisrTime = YES;
        [self.ShopsCollectionView setContentOffset:CGPointMake(0, 0) animated:NO];
        [self threadCallService];
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

#pragma mark - Method Loading

-(void)loading{
    @autoreleasepool {
        if (_vistaWait.hidden == TRUE) {
            _vistaWait.hidden = FALSE;
            CALayer * l = [_vistaWait layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:10.0];
            // You can even add a border
            [l setBorderWidth:1.5];
            [l setBorderColor:[[UIColor whiteColor] CGColor]];
            
            [_indicador startAnimating];
        }else{
            _vistaWait.hidden = TRUE;
            [_indicador stopAnimating];
        }
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
