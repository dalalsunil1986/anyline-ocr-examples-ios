//
//  ALResultViewController.m
//  AnylineExamples
//
//  Created by Philipp Müller on 07.05.18.
//

#import "ALResultViewController.h"
#import <Foundation/Foundation.h>
#import "UIFont+ALExamplesAdditions.h"
#import "ALResultCell.h"
#import "ALResultEntry.h"
#import "UIColor+ALExamplesAdditions.h"

@interface ALResultViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *resultTitle;
@property (strong, nonatomic) IBOutlet UILabel *imageTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;

//optional:
@property (strong, nonatomic) IBOutlet UILabel *optionalTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *optionalImageView;

@property (nonatomic) NSInteger cellHeight;
@property (nonatomic) NSInteger tableHeight;

@end


@implementation ALResultViewController

- (instancetype)initWithResultData:(NSMutableArray<ALResultEntry *>*)resultData image:(UIImage *)image {
    return [self initWithResultDataDictionary:@{ @"Result Data" : resultData}
                                        image:image
                           optionalImageTitle:nil
                                optionalImage:nil];
}

- (instancetype)initWithResultData:(NSMutableArray<ALResultEntry *>*)resultData image:(UIImage *)image optionalImageTitle:(NSString *)optTitle optionalImage:(UIImage *)optImage {
    return [self initWithResultDataDictionary:@{ @"Result Data" : resultData}
                              image:image
                 optionalImageTitle:optTitle
                      optionalImage:optImage];
}


- (instancetype)initWithResultDataDictionary:(NSDictionary *)resultDataDictionary
                                       image:(UIImage *)image
                          optionalImageTitle:(NSString *)optTitle
                               optionalImage:(UIImage *)optImage {
    self = [super init];
    if (self) {
        _image = image;
        _resultData = resultDataDictionary;
        _optionalTitle = optTitle;
        _optionalImage = optImage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat padding = 10;
    
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.title = @"Scan Result";
   
    //Setup Confirm Button
    self.confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-60, self.view.bounds.size.width, 60)];
    [self.confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton setTitle:@"CONFIRM" forState:UIControlStateNormal];
    [self.confirmButton.titleLabel setFont:[UIFont AL_proximaRegularWithSize:18]];
    [self.confirmButton.titleLabel setTextColor:[UIColor whiteColor]];
    self.confirmButton.backgroundColor = [UIColor AL_examplesBlue];
    //Add button to viewController.view
    [self.view addSubview:self.confirmButton];
    
    
    //Setup Content ScrollView
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                            self.view.bounds.origin.y,
                                                                            self.view.bounds.size.width,
                                                                            self.view.bounds.size.height - self.confirmButton.frame.size.height)];
    self.contentScrollView.delegate = self;
    self.contentScrollView.showsVerticalScrollIndicator = YES;
    self.contentScrollView.scrollEnabled = YES;
    self.contentScrollView.userInteractionEnabled = YES;
    if (@available(iOS 13.0, *)) {
        //in light mode this is a slightly lighter colour than lightGrayColor, but it still looks okay
        self.contentScrollView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    } else {
        self.contentScrollView.backgroundColor = [UIColor lightGrayColor];
    }
    //Add scrollView to viewController.view
    [self.view addSubview:self.contentScrollView];
    
    //Setup TableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.resultTitle.frame.origin.y+self.resultTitle.frame.size.height, self.view.frame.size.width, 300) style:UITableViewStyleGrouped];
    [self.tableView registerClass:[ALResultCell class] forCellReuseIdentifier:@"alResultCell"];
    [self.tableView setSectionHeaderHeight:0];
    self.tableView.userInteractionEnabled = true;
    if (@available(iOS 13.0, *)) {
        self.tableView.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //Add view to scrollView
    [self.contentScrollView addSubview:self.tableView];
    
    //Setup Title Label for Image
    self.imageTitle = [[UILabel alloc] initWithFrame:CGRectMake(padding,
                                                                self.tableView.frame.origin.y + self.tableView.frame.size.height + padding,
                                                                self.view.frame.size.width - padding*2,
                                                                [self headerSize])];
    self.imageTitle.text = @"Control Image";
    self.imageTitle.textAlignment = NSTextAlignmentLeft;
    self.imageTitle.font = [UIFont AL_proximaSemiboldWithSize:18];
    //Add view to scrollView
    [self.contentScrollView addSubview:self.imageTitle];
    
    //Setup Image View
    CGFloat imageViewWidth = self.view.frame.size.width-4*padding;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(padding*2, self.imageTitle.frame.origin.y + self.imageTitle.frame.size.height, imageViewWidth, imageViewWidth)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.clipsToBounds = true;
    self.imageView.image = _image;
    //Resize imageView to fit image size
    CGSize imageSize = [self onScreenPointSizeOfImageInImageView:self.imageView];
    CGRect imageViewRect = self.imageView.frame;
    //_image should not be nil, but if it is, we don't want to crash by setting the size to NaN
    if (isnan(imageSize.height) || isnan(imageSize.width)) {
        imageSize = CGSizeZero;
    }
    imageViewRect.size = imageSize;
    self.imageView.frame = imageViewRect;
    //Add view to scrollView
    [self.contentScrollView addSubview:self.imageView];
    
    if (_optionalTitle && _optionalImage) {
        //Setup Title Label for Image
        self.optionalTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding,
                                                                    self.imageView.frame.origin.y + self.imageView.frame.size.height + padding,
                                                                    self.view.frame.size.width - padding*2,
                                                                    [self headerSize])];

        self.optionalTitleLabel.text = self.optionalTitle;
        self.optionalTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.optionalTitleLabel.font = [UIFont AL_proximaSemiboldWithSize:18];
        //Add view to scrollView
        [self.contentScrollView addSubview:self.optionalTitleLabel];
    
        //Setup Image View
        self.optionalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(padding*2,
                                                                               self.optionalTitleLabel.frame.origin.y + self.optionalTitleLabel.frame.size.height,
                                                                               self.view.frame.size.width/2, self.view.frame.size.width/2)];
        self.optionalImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.optionalImageView.image = _optionalImage;
        //Resize imageView to fit image size
        CGSize optionalImageSize = [self onScreenPointSizeOfImageInImageView:self.optionalImageView];
        CGRect optionalImageViewRect = self.optionalImageView.frame;
        optionalImageViewRect.size = optionalImageSize;
        self.optionalImageView.frame = optionalImageViewRect;
        //Add view to scrollView
        [self.contentScrollView addSubview:self.optionalImageView];
        
//        [self.tableView layoutSubviews];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 120.0;
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.tableHeight > self.tableView.contentSize.height) {
        [UIView animateWithDuration:0.2 animations:^{
            self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableHeight);
            [self updateViewItemLayout];
        } completion:^(BOOL finished) { }];
        
    }
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self updateViewItemLayout];
}

- (void)updateViewItemLayout {
    //Update Positions of subviews
    self.resultTitle.center = CGPointMake(self.view.center.x, self.resultTitle.center.y);
    self.imageTitle.center = CGPointMake(self.view.center.x, self.imageTitle.center.y);
    self.imageView.center = CGPointMake(self.view.center.x, self.imageView.center.y);
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                      self.tableView.frame.origin.y,
                                      self.tableView.frame.size.width,
                                      self.tableView.contentSize.height+[self headerSize]);
    
    
    self.imageTitle.frame = CGRectMake(self.imageTitle.frame.origin.x,
                                       self.tableView.frame.origin.y+self.tableView.frame.size.height,
                                       self.imageTitle.frame.size.width,
                                       self.imageTitle.frame.size.height);
    
    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x,
                                      self.imageTitle.frame.origin.y+self.imageTitle.frame.size.height,
                                      self.imageView.frame.size.width,
                                      self.imageView.frame.size.height);
    
    CGFloat contentSizeHeight = self.imageView.frame.origin.y + self.imageView.frame.size.height;
    
    if (_optionalTitle && _optionalImage) {
        self.optionalTitleLabel.frame = CGRectMake(self.optionalTitleLabel.frame.origin.x,
                                                   self.imageView.frame.origin.y+self.imageView.frame.size.height,
                                                   self.optionalTitleLabel.frame.size.width,
                                                   self.optionalTitleLabel.frame.size.height);
        
        self.optionalImageView.frame = CGRectMake(self.optionalImageView.frame.origin.x,
                                                  self.optionalTitleLabel.frame.origin.y+self.optionalTitleLabel.frame.size.height,
                                                  self.optionalImageView.frame.size.width,
                                                  self.optionalImageView.frame.size.height);
        
        self.optionalImageView.center = CGPointMake(self.contentScrollView.center.x, self.optionalImageView.center.y);
        
        //Update content size with optional imageView
        contentSizeHeight = self.optionalImageView.frame.origin.y + self.optionalImageView.frame.size.height;
    }
    
    self.contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width, contentSizeHeight);
    
}

#pragma mark - UITableView methods

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"alResultCell";
    ALResultCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ALResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    ALResultEntry *entry = [self.resultData[[[self.resultData allKeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    [cell setResultEntry:entry];
    [cell layoutSubviews];
    self.cellHeight = cell.cellHeight;
    self.tableHeight = self.tableHeight + self.cellHeight;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    self.tableView.estimatedRowHeight = 300;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [self.resultData  count];
    return [self.resultData[[[self.resultData allKeys] objectAtIndex:section]] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    self.resultTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, [self headerSize])];
    self.resultTitle.text = [[self.resultData allKeys] objectAtIndex:section];
    self.resultTitle.textAlignment = NSTextAlignmentLeft;
    self.resultTitle.font = [UIFont AL_proximaSemiboldWithSize:18];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self headerSize])];
    if (@available(iOS 13.0, *)) {
        view.backgroundColor = [UIColor systemBackgroundColor];
        self.resultTitle.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        view.backgroundColor = [UIColor whiteColor];
        self.resultTitle.backgroundColor = [UIColor whiteColor];
    }
    [view addSubview:self.resultTitle];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self headerSize];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.resultData allKeys].count;
}

#pragma mark - Utility methods
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return self.cellHeight;
//}

- (CGFloat)headerSize {
    return 40.0;
}

#pragma mark - IBAction methods
- (void)confirmAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(CGSize)onScreenPointSizeOfImageInImageView:(UIImageView *)imageView {
    CGFloat scale;
    if (imageView.frame.size.width > imageView.frame.size.height) {
        if (imageView.image.size.width > imageView.image.size.height) {
            scale = imageView.image.size.height / imageView.frame.size.height;
        } else {
            scale = imageView.image.size.width / imageView.frame.size.width;
        }
    } else {
        if (imageView.image.size.width > imageView.image.size.height) {
            scale = imageView.image.size.width / imageView.frame.size.width;
        } else {
            scale = imageView.image.size.height / imageView.frame.size.height;
        }
    }
    return CGSizeMake(imageView.image.size.width / scale, imageView.image.size.height / scale);
}

- (BOOL)tableView:(UITableView*)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender {

    if (action == @selector(copy:)) {
        return YES;
    }

    return NO;
}

- (BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath {
    return YES;
}

-(void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender {

    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];

    ALResultEntry *entry = [self.resultData[[[self.resultData allKeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    pasteboard.string = entry.value;
}

@end
            
