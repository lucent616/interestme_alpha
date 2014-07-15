//
//  CDWViewController.m
//  InterestMe2
//
//  Created by Collin Wallace on 4/10/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Pinterest/Pinterest.h>
#import "DraggableViewController.h"
#import "FullScreenViewController.h"
#import "PolaroidDatabase.h"
#import "PolaroidCollectionViewController.h"
#import "SettingsCDTVC.h"
#import "UIImage+AddOn.h"
#import "LoginViewController.h"
#import "CDWAppDelegate.h"


@interface DraggableViewController ()

@property (nonatomic, strong,nonatomic) PolaroidWithinDraggableView *draggableView;

@property (weak, nonatomic) IBOutlet UIButton *thumbnailImageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *interestSettingsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *interestBoardButton;
@property (weak, nonatomic) IBOutlet UILabel *interestMeScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendScoreLabel;
@property (strong, nonatomic) NSMutableArray *urlBank;
@property (strong, nonatomic) IBOutlet UIView *globalView;

@property (strong, nonatomic) UIImage *polaroidImage;
@property (strong, nonatomic) NSURL *polaroidImageURL;
@property (strong, nonatomic) NSString *currentPolaroidImageURL;
@property (strong, nonatomic) NSString *currentPolaroidTitle;
@property (strong, nonatomic) NSString *currentPolaroidDescription;
@property (strong, nonatomic) NSString *currentPolaroidSourceURL;

@property (strong, nonatomic) NSString *polaroidThumbnailTitle;
@property (strong, nonatomic) NSString *polaroidThumbnailDescription;
@property (strong, nonatomic) NSString *polaroidThumbnailSourceURL;

@property (strong, nonatomic) UIPanGestureRecognizer *panGR;
@property (strong, nonatomic) UITapGestureRecognizer *tapGR;
@property (strong, nonatomic) NSData *imageData;
@property (nonatomic) CGPoint panPoint;
@property (nonatomic) CGPoint originalPoint;
@property (nonatomic) CGAffineTransform originalTransform;
@property (nonatomic) CGFloat xDistance;
@property (nonatomic) CGFloat  yDistance;
@property (nonatomic) int thumbnailIndex;

@property (nonatomic) int friendScore;

@property (strong, nonatomic) UIActivityViewController *activityViewController;

@property (strong, nonatomic) NSMutableData *webData;
@property (nonatomic) int userIdentification;
@property (strong, nonatomic) NSDictionary *userInformation;
@property (strong, nonatomic) NSDictionary *indexInformation;
@property (nonatomic) int currentImageIndex;
@property (strong, nonatomic) NSDictionary *shareMessageData;
@property (strong, nonatomic) NSString  *shareMessage;
@property (strong, nonatomic) Pinterest *pinterest;

@end

@implementation DraggableViewController

///////////////////////////////////////////////////////////////////////////ADJUSTMENT VALUES
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define POLAROID_STAGING_OFFSET 2
#define WEIGHT_OF_INTEREST .1
#define WEIGHT_OF_SAVE .25
#define WEIGHT_OF_SEND .5
BOOL resizeThumbnails = YES; //Turns thumbnail resizing on and off
static int ySensitivity = 150; //Adjust how sensity the drag feature is to the users movement
static int xSensitivity = 40;
////////////END OF ADJUSTMENT VALUES
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"savedUserInfo"] != nil)
    {
        NSLog(@"IMAGE INDEX WAS PREVIOUSLY STORED!!!");
        self.indexInformation = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"savedUserInfo"];
        self.imageIndex = [self.indexInformation[@"index"] intValue];
        self.filterBank = self.indexInformation[@"filterBank"];
        
        
        NSLog(@"Previously stored Image Index was: %d", self.imageIndex);
    
    }
    else
    {
        _imageIndex = 0;
        NSLog(@"No current Image Index found, Image Index was set to zero");
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"userInfo"] != nil)
    {
        self.userInformation = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"userInfo"];
        self.userIdentification = [self.userInformation[@"id"] intValue];
        //NSLog(@"User Identification: %d", self.userIdentification);
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{

}

- (void)viewDidLoad
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"interestMeTitle.png"]];
    
    [super viewDidLoad];
    
    CDWAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.draggableViewController = self;
    
    //SETUP THE DATABASE
    
    PolaroidDatabase *polaroidDB = [PolaroidDatabase sharedDefaultPolaroidDatabase];
    if (polaroidDB.managedObjectContext)
    {
        self.managedObjectContext = polaroidDB.managedObjectContext;
        [self stagePolaroids];
        //NSLog(@"photoBanks: %@", self.photoBank);

    } else
    {
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:PolaroidDatabaseAvailable
                                                                        object:polaroidDB
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:^(NSNotification *note) {
                                                                        self.managedObjectContext = polaroidDB.managedObjectContext;
                                                                        [self stagePolaroids];
                                                                        //NSLog(@"photoBanks: %@", self.photoBank);

                                                                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                    }];
    }
    
    [self collectPolaroidGenres];
    UIButton* pinItButton = [Pinterest pinItButton];
    [pinItButton addTarget:self
                    action:@selector(pinIt:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pinItButton];
}

- (void)collectPolaroidGenres
{
    if(!_polaroidGenres)
    {
        _polaroidGenres = [[NSMutableArray alloc] init];
        [self fetchPolaroidGenres:nil];
    }
}

- (void)fetchPolaroidGenres:(void (^)(BOOL success))completionHandler
{
    NSString *urlQuery = [NSString stringWithFormat:@"http://thawing-ocean-9569.herokuapp.com/polaroid/genres.json"];
    
    NSURL *url = [[NSURL alloc] initWithString:urlQuery];
    
    dispatch_queue_t fetchQueue = dispatch_queue_create("Polaroid Genre Fetch", NULL);
    dispatch_async(fetchQueue, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        self.polaroidGenres = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                         options:0
                                                                           error:NULL];
        
        NSLog(@"Genre Array: %@", self.polaroidGenres);
        self.filterBank = [[NSMutableDictionary alloc]init];
        
        for (NSString *each_genre in self.polaroidGenres)
        {
            [self.filterBank setValue:@1 forKey:each_genre];
        }
        
        NSLog(@"Filter Bank: %@", self.filterBank);
        
        if(completionHandler) dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(YES);
        });
    });
}


-(void) updatePolaroidBank
{
    if(self.managedObjectContext)
    {
        _photoBank = nil;
        [self stagePolaroids];
    }
}

-(NSPredicate *)getPredicate
{
    NSMutableArray *array_predicates = [[NSMutableArray alloc]init];
    
    for(NSString *each_filter_key in self.filterBank)
    {
        NSNumber *filter_value = self.filterBank[each_filter_key];
        if([filter_value intValue] == 1)
        {
            [array_predicates addObject:[NSPredicate predicateWithFormat:@"genre =[c] %@", each_filter_key]];
        }
    }
    
    return [NSCompoundPredicate orPredicateWithSubpredicates:array_predicates];
}

-(NSMutableArray *)photoBank
{
    if(!_photoBank)
    {
        NSError *error;
        NSFetchRequest *request  = [NSFetchRequest fetchRequestWithEntityName:@"Polaroid"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"polaroid_ID" ascending:YES]];
        request.predicate = [self getPredicate];
        
        _photoBank = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        
        _thumbnailIndex = 0;
    }
    
    return _photoBank;
}

///////////////////////////////////////////////////////////////BEGINING OF POLAROID BEHAVIOR
- (void)stagePolaroids
{
    if(self.imageIndex >= [self.photoBank count])
        self.imageIndex = [self.photoBank count] - 1.0;
    
    if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"savedUserInfo"] != nil)
    {
        NSLog(@"POLAROIDS PREVIOUSLY STAGED!!!");

        //LEGACY CODE
        self.frontPolaroidCardView.polaroid = self.photoBank[self.imageIndex + 0];
        [self.frontPolaroidCardView startDownloadingImage];
        
        self.middlePolaroidCardView.polaroid = self.photoBank[self.imageIndex + 1];
        [self.middlePolaroidCardView startDownloadingImage];
        
        self.backPolaroidCardView.polaroid = self.photoBank[self.imageIndex + 2];
        [self.backPolaroidCardView startDownloadingImage];
        
        self.imageIndex = self.imageIndex + 2;
        self.tempPolaroidCardView = nil;
        
        self.interestMeScore = [self.indexInformation[@"lastViewedInterestMeScore"] intValue];

        Polaroid *thumbnail = self.photoBank[self.imageIndex - 1];
        self.polaroidThumbnailImage = [UIImage imageWithData:thumbnail.image];
        self.polaroidThumbnailImageURL = thumbnail.imageURL;
        [self updateThumbnailInfo];
        
        [self setFriendScore:1];
        
        
        self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragPolaroid:)];
        self.tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPolaroidView:)];
        [self.frontPolaroidCardView addGestureRecognizer:self.panGR];
        [self.frontPolaroidCardView addGestureRecognizer:self.tapGR];
        [self.frontPolaroidCardView shadePolaroidBackground];
        self.currentPolaroidImageURL = self.frontPolaroidCardView.polaroid.imageURL;
        
        NSLog(@"Previously stored interestMe Score: %d", self.interestMeScore);
    }
    else
    {
        NSLog(@"FIRST TIME THAT POLAROIDS ARE BEING STAGED!!!");
        self.frontPolaroidCardView.polaroid = self.photoBank[self.imageIndex + 0];
        [self.frontPolaroidCardView startDownloadingImage];
        
        self.middlePolaroidCardView.polaroid = self.photoBank[self.imageIndex + 1];
        [self.middlePolaroidCardView startDownloadingImage];
        
        self.backPolaroidCardView.polaroid = self.photoBank[self.imageIndex + 2];
        [self.backPolaroidCardView startDownloadingImage];

        self.imageIndex = self.imageIndex + 2;
        self.tempPolaroidCardView = nil;
        
        self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragPolaroid:)];
        self.tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPolaroidView:)];
        [self.frontPolaroidCardView addGestureRecognizer:self.panGR];
        [self.frontPolaroidCardView addGestureRecognizer:self.tapGR];
        [self.frontPolaroidCardView shadePolaroidBackground];
        self.currentPolaroidImageURL = self.frontPolaroidCardView.polaroid.imageURL;
    }
}

- (void)updateThumbnailInfo
{
    //setup the thumbnail button after a polaroid is swiped
    NSLog(@"Image Index when iterating: %d", self.imageIndex);
    if (resizeThumbnails)
    {
        float thumbnailHeight = self.thumbnailImageButton.bounds.size.height;
        float thumbnailWidth = self.thumbnailImageButton.bounds.size.width;
        CGSize thumbnailSize = CGSizeMake(thumbnailWidth, thumbnailHeight);
        UIImage *resizedThumbnailImage = [UIImage imageToFitSize:self.frontPolaroidCardView.polaroidImage size:thumbnailSize method:MGImageResizeCrop];
        [self.thumbnailImageButton setBackgroundImage:resizedThumbnailImage forState:UIControlStateNormal];
    }
    else
    {
        [self.thumbnailImageButton setBackgroundImage:self.frontPolaroidCardView.polaroidImage forState:UIControlStateNormal];
    }
    [self.thumbnailImageButton setNeedsDisplay];
}

- (void)interateTheNextPolaroid
{
    [self calculateAndSetInterestMeScore];
    [self setFriendScore:1];
    
    self.polaroidThumbnailImage = self.frontPolaroidCardView.polaroidImage;
    self.polaroidThumbnailImageURL = self.frontPolaroidCardView.polaroid.imageURL;
    self.polaroidThumbnailTitle = self.frontPolaroidCardView.polaroid.title;
    self.polaroidThumbnailDescription = self.frontPolaroidCardView.polaroid.polaroidDescription;
    self.polaroidThumbnailSourceURL = self.frontPolaroidCardView.polaroid.sourceURL;
    [self updateThumbnailInfo];
/*
 Redraw the old frontPolaroid behind the nextPolaroid
 Set the middlePolaroid equal to the frontPolaroid
 Change the image of the frontpolaroid view
 Rename the frontPolaroidView the nextPolaroidView
 Reset the position of the frontPolaroid View
 
 */
    self.currentPolaroidImageURL = self.middlePolaroidCardView.polaroid.imageURL;
    self.currentPolaroidTitle = self.middlePolaroidCardView.polaroid.title;
    self.currentPolaroidDescription = self.middlePolaroidCardView.polaroid.polaroidDescription;
    NSLog(@"Middle Description:%@", self.middlePolaroidCardView.polaroid.polaroidDescription);
    NSLog(@"Current Description:%@", self.currentPolaroidDescription);
    self.currentPolaroidSourceURL = self.middlePolaroidCardView.polaroid.sourceURL;
    
    self.imageIndex++;
    [self positionLastPolaroid];

    if (self.imageIndex < [self.photoBank count])
    {
        self.tempPolaroidCardView = self.frontPolaroidCardView;
        self.frontPolaroidCardView = self.middlePolaroidCardView;
        self.middlePolaroidCardView = self.backPolaroidCardView;
        
        self.tempPolaroidCardView.polaroid = self.photoBank[self.imageIndex];

        self.backPolaroidCardView = self.tempPolaroidCardView;
        
        [self.tempPolaroidCardView startDownloadingImage];
        [self.tempPolaroidCardView setNeedsDisplay];
        
        [self.frontPolaroidCardView shadePolaroidBackground];
        [self.frontPolaroidCardView addGestureRecognizer:self.panGR];
        [self.frontPolaroidCardView addGestureRecognizer:self.tapGR];
    }
    else if (self.imageIndex == [self.photoBank count])
    {
        //RESET THE IMAGE INDEX IF THE USER HAS REACHED THE END OF THE POLAROID ARRAY
        self.imageIndex = 0;
        self.thumbnailIndex = 0;
        
        self.tempPolaroidCardView = self.frontPolaroidCardView;
        self.frontPolaroidCardView = self.middlePolaroidCardView;
        self.middlePolaroidCardView = self.backPolaroidCardView;
        
        self.tempPolaroidCardView.polaroid = self.photoBank[self.imageIndex];

        self.backPolaroidCardView = self.tempPolaroidCardView;
        
        [self.tempPolaroidCardView startDownloadingImage];
        [self.tempPolaroidCardView setNeedsDisplay];
        
        [self.frontPolaroidCardView shadePolaroidBackground];
        [self.frontPolaroidCardView addGestureRecognizer:self.panGR];
        [self.frontPolaroidCardView addGestureRecognizer:self.tapGR];
    }
}

- (void)positionLastPolaroid
{
    [self.view sendSubviewToBack:self.frontPolaroidCardView];
    [self.frontPolaroidCardView unshadePolaroidBackground];
    self.frontPolaroidCardView.center = self.originalPoint;
    self.frontPolaroidCardView.transform = CGAffineTransformMakeRotation(0);
}

- (IBAction)dragPolaroid:(UIPanGestureRecognizer *)gestureRecognizer
{
    self.navigationController.navigationBar.hidden = NO;
    self.xDistance = [gestureRecognizer translationInView:self.globalView].x;
    self.yDistance = [gestureRecognizer translationInView:self.globalView].y;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            [self.middlePolaroidCardView shadePolaroidBackground];
            self.originalPoint = self.frontPolaroidCardView.center;
            self.originalTransform = self.frontPolaroidCardView.transform;
            
            break;
        };
        case UIGestureRecognizerStateChanged:
        {
            CGFloat rotationStrength = MIN(self.xDistance / 320, 1);
            CGFloat rotationAngle = (CGFloat) (2*M_PI/16 * rotationStrength);
            CGFloat scaleStrength = 1 - fabsf(rotationStrength) / 4;
            CGFloat scale = MAX(scaleStrength, 0.65);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(self.xDistance, self.yDistance);
            CGAffineTransform differentTransform = CGAffineTransformScale(translation, scale, scale);
            CGAffineTransform thirdTransfrom = CGAffineTransformRotate(differentTransform, rotationAngle);

            self.frontPolaroidCardView.transform = thirdTransfrom;
            
            //[self updateOverlay:self.xDistance];
                
            break;
        };
        case UIGestureRecognizerStateEnded:
        {
//            //If the image is moved more than 75 pixels in the x-direction, the image is removed from the view and
//            //a method WILL BE triggered to add the image to an array of boringImages or interestMeImages
                
            //Swipe Left - Image is boring
            if (self.xDistance < - 75 && self.yDistance < ySensitivity)
            {
                [UIView animateWithDuration:0.2 delay:0.00 options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     CGAffineTransform scale = CGAffineTransformMakeScale(.75, .75);
                                     CGAffineTransform translate = CGAffineTransformMakeTranslation(-700.0, 0.0);
                                     
                                     self.frontPolaroidCardView.center = CGPointMake(self.originalPoint.x + self.xDistance, self.originalPoint.y + self.yDistance);
                                     self.frontPolaroidCardView.transform = CGAffineTransformConcat(scale, translate);
                                     
                                 }
                                 completion:^(BOOL finished) {
                                     //self.boringToMe = YES;
                                     self.frontPolaroidCardView.polaroid.boringToMe = YES;
                                     self.frontPolaroidCardView.polaroid.numberOfPeopleBoredByThis++;
                                     
                                    [self handlePostToServer:self.userIdentification polaroidID:self.frontPolaroidCardView.polaroid.polaroid_ID sent:0 saved:0 boring:1 interesting:0];
                                     [self interateTheNextPolaroid];
                                 }
                 ];
                
                break;
            }
            //Swipe Right - Image is interesting
            else if (self.xDistance > 75 && self.yDistance < ySensitivity)
            {
                [UIView animateWithDuration:0.2 delay:0.00 options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     CGAffineTransform scale = CGAffineTransformMakeScale(.75, .75);
                                     CGAffineTransform translate = CGAffineTransformMakeTranslation(700.0, 0.0);
                                     
                                     self.frontPolaroidCardView.center = CGPointMake(self.originalPoint.x + self.xDistance, self.originalPoint.y + self.yDistance);
                                     self.frontPolaroidCardView.transform = CGAffineTransformConcat(scale, translate);
                                     
                                 }
                                 completion:^(BOOL finished) {
                                    self.frontPolaroidCardView.polaroid.interestingToMe = YES;
                                    self.frontPolaroidCardView.polaroid.savedByMe = YES;
                                     
                                    [self handlePostToServer:self.userIdentification polaroidID:self.frontPolaroidCardView.polaroid.polaroid_ID sent:0 saved:0 boring:0 interesting:1];
                                    self.frontPolaroidCardView.polaroid.numberOfTimesSaved++;
                                    self.frontPolaroidCardView.polaroid.numberOfPeopleInterestedInThis++;
                                    [self interateTheNextPolaroid];
                                 }
                 ];
                
                break;
            }
            //Swipe Up - Send Image
            if (self.yDistance < - 20 && self.xDistance < xSensitivity)
            {
                [self resetViewPositionAndTransformations];
                [self sharePolaroid];

                break;
            }
/////////////////////////////////////////////SWIPE DOWN - CURRENTLY DISABLED
//            else if (self.yDistance > 30 && self.xDistance < xSensitivity)
//            {
//                [UIView animateWithDuration:0.2 delay:0.00 options:UIViewAnimationOptionCurveEaseOut
//                                 animations:^{
//                                     CGAffineTransform scale = CGAffineTransformMakeScale(.75, .75);
//                                     CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 1000.0);
//                                     
//                                     self.frontPolaroidCardView.center = CGPointMake(self.originalPoint.x + self.xDistance, self.originalPoint.y + self.yDistance);
//                                     self.frontPolaroidCardView.transform = CGAffineTransformConcat(scale, translate);
//                                     
//                                 }
//                                 completion:^(BOOL finished) {
//                                    
//
//                                     [self interateTheNextPolaroid];
//                                 }
//                 ];
//                
//                break;
//            }
//////////////////END OF SWIPE DOWN
            else
            {
                [self resetViewPositionAndTransformations];

                break;
            }
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
    
}

- (void)resetViewPositionAndTransformations
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.frontPolaroidCardView.center = self.originalPoint;
                         self.frontPolaroidCardView.transform = CGAffineTransformMakeRotation(0);
                     }
                     completion:^(BOOL finished) {
                         [self.middlePolaroidCardView unshadePolaroidBackground];
                         //self.overlayView.alpha = 0;
                     }
     ];
}
////////////////////////////END OF POLAROID BEHAVIOR

/////////////////////////////////////////////////////////////////////////////UPDATE SCORING INFORMATION
- (void)calculateAndSetInterestMeScore
{
    
    //NSLog(@"Numbers %d", self.frontPolaroidCardView.polaroid.numberOfPeopleInterestedInThis);
    
    int swipeValueDivisor = (self.frontPolaroidCardView.polaroid.numberOfPeopleInterestedInThis/self.frontPolaroidCardView.polaroid.numberOfPeopleBoredByThis);
    //NSLog(@"Swipe Value Divisor: %d", swipeValueDivisor);
    
    float swipeValue = WEIGHT_OF_INTEREST *swipeValueDivisor + WEIGHT_OF_SAVE * self.frontPolaroidCardView.polaroid.numberOfTimesSaved + WEIGHT_OF_SEND * self.frontPolaroidCardView.polaroid.numberOfTimesSent;
    //NSLog(@"SwipeValue: %d", swipeValue);
    
    if (self.frontPolaroidCardView.polaroid.interestingToMe)
    {
        self.interestMeScore = self.interestMeScore + swipeValue;
        NSLog(@"Score went up: %f", swipeValue);
    }
    else
    {
        self.interestMeScore = self.interestMeScore - swipeValue;
        NSLog(@"Score went down: %f", swipeValue);
    }
    self.interestMeScoreLabel.text = [NSString stringWithFormat:@"%d", self.interestMeScore];
}


- (void)setInterestMeScore:(int)interestMeScore
{
    _interestMeScore = interestMeScore;
    self.interestMeScoreLabel.text = [NSString stringWithFormat:@"%d", self.interestMeScore];
}

- (void)setFriendScore:(int)friendScore
{
    //Argument built in for future api, but not used in this immplementation
    _friendScore  = (arc4random() % 19) + 1;
    self.friendScoreLabel.text = [NSString stringWithFormat:@"%d", self.friendScore];
}

///////////////////////////END OF SCORING INFORMATION

- (IBAction)tapOnGlobalView:(UITapGestureRecognizer *)sender
{
    self.navigationController.navigationBar.hidden = NO;
    //self.navigationController.navigationBar.hidden = !self.navigationController.navigationBarHidden;
    //NSLog(@"Someone tapped on my screen!");
}

- (void) tapPolaroidView:(id)sender
{
    FullScreenViewController *ivc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"FullScreenViewID"];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    ivc.imageURL =  [NSURL URLWithString:self.currentPolaroidImageURL];
    NSLog(@"Current Polaroid Title:%@", self.currentPolaroidDescription);
    ivc.fullScreenTitle = self.currentPolaroidTitle;
    ivc.fullScreenDescription = self.currentPolaroidDescription;
    ivc.fullScreenSourceURL = self.currentPolaroidSourceURL;
 
    [self.navigationController pushViewController:ivc animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"thumbnailToFullScreen"])
    {
        if ([segue.destinationViewController isKindOfClass:[FullScreenViewController class]]) {
            [[self navigationController] setNavigationBarHidden:YES animated:NO];
            FullScreenViewController *ivc = (FullScreenViewController *)segue.destinationViewController;
            NSLog(@"Thumbnail Hit %d", self.thumbnailIndex);
            ivc.imageURL = [NSURL URLWithString:self.polaroidThumbnailImageURL];
            ivc.fullScreenTitle = self.polaroidThumbnailTitle;
            ivc.fullScreenDescription = self.polaroidThumbnailDescription;
            ivc.fullScreenSourceURL = self.polaroidThumbnailSourceURL;
        }
    }
    else if ([segue.identifier isEqualToString:@"savedByMe"])
    {
        if ([segue.destinationViewController isKindOfClass:[PolaroidCollectionViewController class]])
        {
            PolaroidCollectionViewController *ivc = (PolaroidCollectionViewController *) segue.destinationViewController;

            ivc.managedObjectContext = self.managedObjectContext;
        }
    }
    else if ([segue.identifier isEqualToString:@"settings"])
    {
        //SettingsCDTVC *ivc = (SettingsCDTVC *) segue.destinationViewController;
        //ivc.managedObjectContext = self.managedObjectContext;
    }
    else
    {
    }
}
////////////////////////////////////////////////////////////////////////////////////////ACTIVITY VIEW CONTROLLER CODE
- (void)fetchShareMessage:(void (^)(BOOL success))completionHandler
{
    NSString *urlQuery = [NSString stringWithFormat:@"http://thawing-ocean-9569.herokuapp.com/polaroid/message.json"];
    
    NSURL *url = [[NSURL alloc] initWithString:urlQuery];
    
    dispatch_queue_t fetchQueue = dispatch_queue_create("Sharing Message Fetch", NULL);
    dispatch_async(fetchQueue, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        self.shareMessageData = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                options:0
                                                                  error:NULL];
        
        self.shareMessage = [self.shareMessageData objectForKey:@"message"];
        
        if(completionHandler) dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(YES);
        });
    });
}

- (void)pinIt:(id)sender
{
    [self.pinterest createPinWithImageURL:[NSURL URLWithString:self.frontPolaroidCardView.polaroid.imageURL]
                            sourceURL:[NSURL URLWithString:self.frontPolaroidCardView.polaroid.sourceURL]
                          description:@"Pinning from Pin It Demo"];
}

- (void)sharePolaroid
{
    NSString *imageTitle = self.frontPolaroidCardView.polaroid.title;
    [self fetchShareMessage:^(BOOL success) {
        if (success)
        {
            //NSLog(@"String Message from Server: %@", self.shareMessage);
            NSString *finalShareMessage = [NSString stringWithFormat:self.shareMessage,imageTitle];
            //NSLog(@"String Final Message from Server: %@", finalShareMessage);
        
            __weak typeof(self) weakSelf = self;
            
            NSString *messageBody = finalShareMessage;
            NSString *messageSubject = finalShareMessage;
            UIImage *image = [[UIImage alloc] initWithData:self.frontPolaroidCardView.polaroid.image];
            self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[messageBody, image] applicationActivities:nil];
            self.activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
            
            [self.activityViewController setValue:messageSubject forKey:@"subject"];
            
            [self presentViewController:self.activityViewController animated:YES completion:nil];
            
            
            [self.activityViewController  setCompletionHandler:^(NSString *activityType, BOOL done)
             {
                 NSString *ServiceType = @"";
                 if ( [activityType isEqualToString:UIActivityTypeMail] )           ServiceType = @"Mail.";
                 if ( [activityType isEqualToString:UIActivityTypeMessage] )  ServiceType = @"Messenger.";
                 
                 NSMutableString *shareWithActivityResultMessage;
                 NSString *successMessage = @"Success";
                 NSString *errorMessage = @"Error";
                 NSString *alertTitle;
                 if (done)
                 {
                     [weakSelf animateExitOfSentPolaroid];
                     weakSelf.frontPolaroidCardView.polaroid.sentByMe = YES;
                     [weakSelf handlePostToServer:weakSelf.userIdentification polaroidID:weakSelf.frontPolaroidCardView.polaroid.polaroid_ID sent:1 saved:0 boring:0 interesting:0];
                     alertTitle = @"Success!";
                     
                     shareWithActivityResultMessage = [NSMutableString stringWithString:successMessage];
                     [shareWithActivityResultMessage appendString:ServiceType];
                 }
                 else
                 {
                     // didn't succeed.
                     alertTitle = @"Error";
                     shareWithActivityResultMessage = [NSMutableString stringWithString:errorMessage];
                 }
             }];
        }
    }];
}
///////////////////////////////////END OF ACTIVITY VIEW CONTROLLER CODE

- (void)animateExitOfSentPolaroid
{
    [UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseOut
                        animations:^{

    CGAffineTransform scale = CGAffineTransformMakeScale(.75, .75);
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, -700.0);
    
    self.frontPolaroidCardView.center = CGPointMake(self.originalPoint.x + self.xDistance, self.originalPoint.y + self.yDistance);
    self.frontPolaroidCardView.transform = CGAffineTransformConcat(scale, translate);
                        }
                     completion:^(BOOL finished) {
    self.frontPolaroidCardView.polaroid.sentByMe = YES;
    self.frontPolaroidCardView.polaroid.numberOfTimesSent++;
                         [self interateTheNextPolaroid];
                     }
        ];
}

/////////////////////////////////////////////////////HANDLING POST TO SERVER



- (void)handlePostToServer:(int)userID polaroidID:(int64_t)polaroidID sent:(int)sent saved:(int)saved boring:(int)boring interesting:(int)interesting
{
//    http://thawing-ocean-9569.herokuapp.com/relationships/build with the following parameters:
//
//    user_id
//    polaroid_id
//    sent (0 or 1)
//    saved (0 or 1)
//    boring (0 or 1)
//    interesting (0 or 1)
//
//    0 = false, 1 = true. user_id and polaroid_id are integer values.
//
    
    NSString *post = [NSString stringWithFormat:@"user_id=%d&polaroid_id=%lld&sent=%d&saved=%d&boring=%d&interesting=%d", userID, polaroidID, sent, saved, boring, interesting];
    //NSLog(@"%@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://thawing-ocean-9569.herokuapp.com/relationships/build"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(theConnection) {
        _webData = [NSMutableData data];
        //NSLog(@"connection initiated");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_webData appendData:data];
    //NSLog(@"connection received data");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"connection received response");
    NSHTTPURLResponse *ne = (NSHTTPURLResponse *)response;
    if([ne statusCode] == 200) {
        //NSLog(@"connection state is 200 - all okay");
    } else {
        //NSLog(@"connection state is NOT 200");
    }
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //NSLog(@"Conn Err: %@", [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSLog(@"Conn finished loading");
    //NSString *html = [[NSString alloc] initWithBytes: [_webData mutableBytes] length:[_webData length] encoding:NSUTF8StringEncoding];
    //NSLog(@"OUTPUT:: %@", html);
}

@end
