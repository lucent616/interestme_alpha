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
#import "OverlayView.h"
#import "myWebView.h"


@interface DraggableViewController ()

@property (nonatomic, strong,nonatomic) PolaroidWithinDraggableView *draggableView;

@property (weak, nonatomic) IBOutlet UIButton *thumbnailImageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *interestSettingsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *interestBoardButton;
@property (weak, nonatomic) IBOutlet UILabel *interestMeScoreLabel;
@property (nonatomic) int friendScore;
@property (weak, nonatomic) IBOutlet UILabel *friendScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendScoreDescription;

@property (strong, nonatomic) IBOutlet UIView *globalView;
@property (strong, nonatomic) NSMutableArray *urlBank;//May be unnecessary
@property (strong, nonatomic) NSMutableData *webData;
@property (nonatomic) int remainingPolaroids;

@property (strong, nonatomic) NSString *currentPolaroidImageURL;
@property (strong, nonatomic) NSString *currentPolaroidTitle;
@property (strong, nonatomic) NSString *currentPolaroidDescription;
@property (strong, nonatomic) NSString *currentPolaroidSourceURL;
@property (nonatomic) int currentImageIndex;

@property (strong, nonatomic) UIImage *polaroidImage;
@property (strong, nonatomic) NSString *polaroidImageURL;
@property (nonatomic) NSNumber *polaroidThumbnailID;
@property (strong, nonatomic) NSString *polaroidThumbnailTitle;
@property (strong, nonatomic) NSString *polaroidThumbnailDescription;
@property (strong, nonatomic) NSString *polaroidThumbnailSourceURL;
@property (strong, nonatomic) NSData *polaroidThumbnailImageData;
@property (nonatomic) int thumbnailIndex;

@property (strong, nonatomic) UIPanGestureRecognizer *panGR;
@property (strong, nonatomic) UITapGestureRecognizer *tapGR;
@property (strong, nonatomic)  UITapGestureRecognizer *doubleTapGR;
@property (strong, nonatomic) NSData *imageData;
@property (nonatomic) CGPoint panPoint;
@property (nonatomic) CGPoint originalPoint;
@property (nonatomic) CGAffineTransform originalTransform;
@property (nonatomic) CGFloat xDistance;
@property (nonatomic) CGFloat  yDistance;

@property (strong, nonatomic) UIActivityViewController *activityViewController;
@property (strong, nonatomic) NSDictionary *previousSessionInformation;
@property (strong, nonatomic) NSDictionary *userInformation;
@property (nonatomic) int userIdentification;

@property (strong, nonatomic) NSString  *shareMessage;
@property (strong, nonatomic) NSDictionary *shareMessageData;
@property (strong, nonatomic) Pinterest *pinterest;
@property (strong, nonatomic) NSDictionary *userFilterPreferences;

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

- (void)viewDidLoad
{   //Creates MOC and if one has not been created, then it observes until a database is created
    [super viewDidLoad];
    
    [self checkForPreviousSession:nil];
    
//    if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"savedPreviousSession"] == nil)
//    {
//        [self.friendScoreLabel setHidden:YES];
//        [self.friendScoreDescription setHidden:YES];
//    }
//    else
//    {
//        
//    }
    
    CDWAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.draggableViewController = self;
    
    //SETUP THE DATABASE
    
    PolaroidDatabase *polaroidDB = [PolaroidDatabase sharedDefaultPolaroidDatabase];
    if (polaroidDB.managedObjectContext)
    {
        self.managedObjectContext = polaroidDB.managedObjectContext;
        
        [self stagePolaroids];
        //NSLog(@"photoBank: %@", self.photoBank);
        
    }
    else
    {
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:PolaroidDatabaseAvailable
                                                                        object:polaroidDB
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:^(NSNotification *note) {
                                                                        self.managedObjectContext = polaroidDB.managedObjectContext;
                                                                        
                                                                        [self stagePolaroids];
                                                                        
                                                                        //Retrieve thumbnail information from previous session
                                                                        if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"savedPreviousSession"] != nil)
                                                                        {
                                                                            self.previousSessionInformation = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"savedPreviousSession"];
                                                                            
                                                                            self.polaroidThumbnailID = self.previousSessionInformation[@"thumbnailPolaroidID"];
                                                                            self.friendScore = [self.previousSessionInformation[@"lastViewedFriendScore"] intValue];
                                                                            NSLog(@"Friend score from previous session: %d", self.friendScore);
                                                                            NSLog(@"Polaroid Thumbnail ID from previous session: %@", self.polaroidThumbnailID);
                                                                            NSMutableArray *myPreviousThumbnail = [self findMyPolaroid:[self.polaroidThumbnailID intValue]];
                                                                            
                                                                            
                                                                            for (Polaroid *each_polaroid in myPreviousThumbnail)
                                                                            {
                                                                                NSString *thisThumbnailURL = each_polaroid.imageURL;
                                                                                
                                                                                if (thisThumbnailURL != nil)
                                                                                {
                                                                                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:thisThumbnailURL]];
                                                                                    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
                                                                                    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
                                                                                    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                                                                                                    completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error)
                                                                                                                      {
                                                                                                                          if (!error)
                                                                                                                          {
                                                                                                                              if ([[request.URL absoluteString] isEqual:thisThumbnailURL])
                                                                                                                              {
                                                                                                                                  NSData *thisThumbnailImageData = [NSData dataWithContentsOfURL:localfile];
                                                                                                                                  UIImage *thisThumbnailImage = [UIImage imageWithData:thisThumbnailImageData];
                                                                                                                                  [self.thumbnailImageButton setBackgroundImage:thisThumbnailImage forState:UIControlStateNormal];
                                                                                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                                                  });
                                                                                                                              }
                                                                                                                          }
                                                                                                                      }];
                                                                                    
                                                                                    [task resume];
                                                                                }
                                                                                
                                                                                self.polaroidThumbnailTitle = each_polaroid.title;
                                                                                self.polaroidThumbnailDescription = each_polaroid.polaroidDescription;
                                                                                self.polaroidThumbnailSourceURL = each_polaroid.sourceURL;
                                                                            }
                                                                            
                                                                            //[self.view setNeedsDisplay];
                                                                            
                                                                            //Pretend that a new friend score is being calculated
                                                                            [self calculateAndSetInterestMeScore]; //currently hidden
                                                                            self.friendScoreLabel.text = [NSString stringWithFormat:@"%d", self.friendScore];
                                                                        }
                                                                        
                                                                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                    }];
    }
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"interestMe_Navigation_Header.png"]];
    [self collectPolaroidGenres];
    
}

- (void)checkForPreviousSession:(void (^)(BOOL success))completionHandler
{
    //Check to see if the user has joined the application already, if not, show them the tutorial which leads to signup
    if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"User Information From Server"] != nil)
    {
        self.userInformation = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"User Information From Server"];
        self.userIdentification = [self.userInformation[@"userID"] intValue];
        NSLog(@"This user has created an account");
        NSLog(@"This users identification number is: %d", self.userIdentification);
        //NSLog(@"%@",[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"User Filter Preferences"][@"filterBank"]);
    }
    else
    {
        dispatch_queue_t tutorialQueue = dispatch_queue_create("Tutorial Loading", NULL);
        dispatch_async(tutorialQueue, ^{
            NSLog(@"This user has never created an account and needs to create one");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *tutorialVC = [storyboard instantiateViewControllerWithIdentifier:@"TutorialViewController"];
            tutorialVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:tutorialVC animated:YES completion:nil];
            if(completionHandler) dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Tutorial screen openned");
                completionHandler(YES);
            });
        });
    }
    
    if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"savedPreviousSession"] != nil)
    {
        NSLog(@"User is continuing a previous session");
        //NSLog(@"Photo bank at startup: %@", self.photoBank);
        
    }
    else
    {
        NSLog(@"This is the first session for this user");
        [self.friendScoreLabel setHidden:YES];
        [self.friendScoreDescription setHidden:YES];
    }
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//}


- (void)collectPolaroidGenres
{
    //Get an array of all of the Polaroid genres from the server
    if(!_polaroidGenres)
    {
        _polaroidGenres = [[NSMutableArray alloc] init];
        [self fetchPolaroidGenres:nil];
    }
}

- (void)fetchPolaroidGenres:(void (^)(BOOL success))completionHandler
{
    self.filterBank = [[NSMutableDictionary alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"User Filter Preferences"] != nil)
    {
        NSLog(@"Users filter preferences were previously stored");
        self.userFilterPreferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"User Filter Preferences"];
        self.filterBank = [self.userFilterPreferences[@"filterBank"] mutableCopy];
        
        //NSLog(@"Previously stored Filter Bank was: %@", self.filterBank);
        
    }
    NSString *urlQuery = [NSString stringWithFormat:@"http://thawing-ocean-9569.herokuapp.com/polaroid/genres.json"];
    NSURL *url = [[NSURL alloc] initWithString:urlQuery];
    
    dispatch_queue_t fetchQueue = dispatch_queue_create("Polaroid Genre Fetch", NULL);
    dispatch_async(fetchQueue, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        self.polaroidGenres = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                              options:0
                                                                error:NULL];

        //NSLog(@"%@", self.polaroidGenres);
        for (NSString *each_genre in self.polaroidGenres)
        {
            NSString *capitalized_genre = [each_genre capitalizedString];
            if (self.filterBank[capitalized_genre] == nil)
            {
                [self.filterBank setValue:@1 forKey:capitalized_genre];
            }
            //NSLog(@"The users current filter bank is: %@", self.filterBank);
        }
        NSLog(@"The users current filter bank is: %@", self.filterBank);
        
        NSUserDefaults *filterDefaults = [NSUserDefaults standardUserDefaults];
        self.userFilterPreferences = @{@"filterBank": self.filterBank};
        [filterDefaults setObject:self.userFilterPreferences forKey:@"User Filter Preferences"];
        [filterDefaults synchronize];
        
        if(completionHandler) dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(YES);
            
        });
    });
}

-(NSPredicate *)getPredicate
{   //Searches for all of the Polaroids matching the filter bank objects that have NOT been viewed already
    NSMutableArray *array_predicates = [[NSMutableArray alloc]init];
    //NSLog(@"Filter Bank before check for previous: %@", self.filterBank);

    if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"User Filter Preferences"] != nil)
    {
        NSMutableDictionary *filterInformation = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"User Filter Preferences"] mutableCopy];
        self.filterBank = [filterInformation[@"filterBank"] mutableCopy];
        
    }
    
    for(NSString *each_filter_key in self.filterBank)
    {
        NSNumber *filter_value = self.filterBank[each_filter_key];
        if([filter_value intValue] == 1)
        {
            [array_predicates addObject:[NSPredicate predicateWithFormat:@"genre =[c] %@ AND viewed = %@", each_filter_key, [NSNumber numberWithBool: NO]]];
        }
    }
    //NSLog(@"Array of Predicates: %@", array_predicates);
    return [NSCompoundPredicate orPredicateWithSubpredicates:array_predicates];
    
}

- (NSMutableArray *)photoBank
{
    [self photoBank:nil];
    return _photoBank;
}

- (NSMutableArray *)photoBank:(NSPredicate *)predicate
{   //Retrives all the Polaroids matching the search criteria and creates an array from them
    if(!_photoBank)
    {
        NSError *error;
        NSFetchRequest *request  = [NSFetchRequest fetchRequestWithEntityName:@"Polaroid"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"polaroid_ID" ascending:YES]];
        
        if (predicate)
        {
            request.predicate = predicate;
        }
        else
        {
            request.predicate = [self getPredicate];
        }
        
        _photoBank = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        
        _imageIndex = 0;
        _thumbnailIndex = 0;
        self.remainingPolaroids = (int32_t)[_photoBank count];
        
        //Test script
        //NSMutableArray *photoBankObjectIDs = [[NSMutableArray alloc]   init];
        //NSLog(@"Total number of polaroids in photo bank is: %d", (int32_t)[_photoBank count]);
        //NSLog(@"Photo Bank contents: %@", _photoBank);
        //NSLog(@"The contents of the photo bank are: %@", photoBankObjectIDs);
    }
    
    for (NSDictionary *each_polaroid in _photoBank)
    {
        NSNumber *tempPolaroidID = [each_polaroid valueForKey:@"polaroid_ID"];
        NSString *tempPolaroidURL = [each_polaroid valueForKey:@"imageURL"];
        NSLog(@"ID: %@, URL: %@",tempPolaroidID, tempPolaroidURL);
    }
    
    NSLog(@"imageIndex: %d", self.imageIndex);
    
    return _photoBank;
}

-(void) updatePolaroidBank
{
    if(self.managedObjectContext)
    {
        _photoBank = nil;
        self.imageIndex = 0;
        [self stagePolaroids];
        
    }
    self.remainingPolaroids = (int32_t)[_photoBank count];
}

- (void)trackRemainingPolaroids
{
    
    NSLog(@"imageIndex: %d", self.imageIndex);

    //NSLog(@"Are there are enough Polaroids to continue?");
    
    if (self.remainingPolaroids <= 3)
    {
        NSLog(@"There are only %d polaroids remaining, Fetch more from the server!", self.remainingPolaroids);
        
        //FETCH MORE POLAROIDS FROM THE SERVER
        PolaroidDatabase *ivc = [PolaroidDatabase sharedDefaultPolaroidDatabase];
        [ivc fetchWithCompletionHandler:^(BOOL success){
            [self updatePolaroidBank];
        }];
    }
    else
    {
        NSLog(@"There are %d polaroids remaining", self.remainingPolaroids);
    }
}

- (void)saveData
{
    NSLog(@"User Progress being saved.");
    NSUserDefaults *usersCurrentProgress = [NSUserDefaults standardUserDefaults];
    
    NSNumber *lastInterestMeScore = [NSNumber numberWithInt:self.interestMeScore];
    NSNumber *polaroidIDForLastViewedPolaroid = [NSNumber numberWithInt:self.frontPolaroidCardView.polaroid.polaroid_ID];
    NSNumber *polaroidIDForLastThumbnail = self.polaroidThumbnailID;
    NSNumber *lastFriendScore = [NSNumber numberWithInt:self.friendScore];
    
    NSLog(@"Friend Score being saved: %@", lastFriendScore);
    
    
    NSDictionary *savedUserInfo = @{@"lastViewedPolaroid":polaroidIDForLastViewedPolaroid,
                                    @"thumbnailPolaroidID":polaroidIDForLastThumbnail,
                                    @"lastViewedFriendScore":lastFriendScore,
                                    @"lastViewedInterestMeScore":lastInterestMeScore};
    
    [usersCurrentProgress setObject:savedUserInfo forKey:@"savedPreviousSession"];
    [usersCurrentProgress synchronize];
    
}

- (NSMutableArray *)findMyPolaroid:(int)polaroidID
{
    NSError *error;
    NSFetchRequest *request  = [NSFetchRequest fetchRequestWithEntityName:@"Polaroid"];
    request.predicate = [NSPredicate predicateWithFormat:@"polaroid_ID = %d", polaroidID];
    //NSLog(@"Predicate for retrieving Thumbnail: %@", request.predicate);
    NSMutableArray *myPolaroid = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    NSLog(@"error: %@", error);
    //NSLog(@"Polaroid returned by findMyPolaroid: %@",myPolaroid);
    return myPolaroid;
}

- (void)followGenre:(NSString *)genre
{
    
}

///////////////////////////////////////////////////////////////BEGINING OF POLAROID BEHAVIOR
- (void)stagePolaroids
{
    self.frontPolaroidCardView.polaroid = self.photoBank[self.imageIndex + 0];
    [self.frontPolaroidCardView startDownloadingImage];
    
    self.middlePolaroidCardView.polaroid = self.photoBank[self.imageIndex + 1];
    [self.middlePolaroidCardView startDownloadingImage];
    
    self.backPolaroidCardView.polaroid = self.photoBank[self.imageIndex + 2];
    [self.backPolaroidCardView startDownloadingImage];
    
    self.imageIndex = self.imageIndex + 2;
    self.tempPolaroidCardView = nil;
    
    if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"savedPreviousSession"] == nil)
    {
        self.interestMeScore = [self.previousSessionInformation[@"lastViewedInterestMeScore"] intValue];
    }

    [self updateThumbnailInfo];
    [self setFriendScore:1];
    
    self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragPolaroid:)];
    self.tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPolaroidView:)];
    self.tapGR.numberOfTapsRequired = 1;
    [self.tapGR setDelaysTouchesBegan : YES];
    
    self.doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapPolaroidView:)];
    self.doubleTapGR.numberOfTapsRequired = 2;
    [self.doubleTapGR setDelaysTouchesBegan : YES];
    
    [self.tapGR requireGestureRecognizerToFail:self.doubleTapGR];
    
    [self.frontPolaroidCardView addGestureRecognizer:self.panGR];
    [self.frontPolaroidCardView addGestureRecognizer:self.tapGR];
    [self.frontPolaroidCardView addGestureRecognizer:self.doubleTapGR];
    [self.frontPolaroidCardView shadePolaroidBackground];
    self.currentPolaroidImageURL = self.frontPolaroidCardView.polaroid.imageURL;

}

- (void)updateThumbnailInfo
{
    //setup the thumbnail button after a polaroid is swiped
    [self.friendScoreLabel setHidden:NO];
    [self.friendScoreDescription setHidden:NO];

    if (resizeThumbnails)
    {
        float thumbnailHeight = self.thumbnailImageButton.bounds.size.height;
        float thumbnailWidth = self.thumbnailImageButton.bounds.size.width;
        CGSize thumbnailSize = CGSizeMake(thumbnailWidth, thumbnailHeight);
        UIImage *resizedThumbnailImage = [UIImage imageToFitSize:self.polaroidThumbnailImage size:thumbnailSize method:MGImageResizeCrop];
        [self.thumbnailImageButton setBackgroundImage:resizedThumbnailImage forState:UIControlStateNormal];
    }
    else
    {
        [self.thumbnailImageButton setBackgroundImage:self.polaroidThumbnailImage forState:UIControlStateNormal];
    }
    [self.thumbnailImageButton setNeedsDisplay];
}

- (void)interateTheNextPolaroid
{
    //[self updatePolaroidBank];
    [self calculateAndSetInterestMeScore];
    [self setFriendScore:1];
    
    self.polaroidThumbnailImage = self.frontPolaroidCardView.polaroidImage;
    self.polaroidThumbnailImageURL = self.frontPolaroidCardView.polaroid.imageURL;
    self.polaroidThumbnailID = [NSNumber numberWithInt:self.frontPolaroidCardView.polaroid.polaroid_ID];
    self.polaroidThumbnailImageData = self.frontPolaroidCardView.polaroid.image;
    self.polaroidThumbnailTitle = self.frontPolaroidCardView.polaroid.title;
    self.polaroidThumbnailDescription = self.frontPolaroidCardView.polaroid.polaroidDescription;
    self.polaroidThumbnailSourceURL = self.frontPolaroidCardView.polaroid.sourceURL;
    [self updateThumbnailInfo];
    
    [self saveData];
/*
 Redraw the old frontPolaroid behind the nextPolaroid
 Set the middlePolaroid equal to the frontPolaroid
 Change the image of the frontpolaroid view
 Rename the frontPolaroidView the nextPolaroidView
 Reset the position of the frontPolaroid View
 
 */
    
    //NSLog(@"%@ %@ %@", self.frontPolaroidCardView.polaroid.title, self.middlePolaroidCardView.polaroid.title, self.backPolaroidCardView.polaroid.title);
    
    self.currentPolaroidImageURL = self.middlePolaroidCardView.polaroid.imageURL;
    self.currentPolaroidTitle = self.middlePolaroidCardView.polaroid.title;
    self.currentPolaroidDescription = self.middlePolaroidCardView.polaroid.polaroidDescription;
    //NSLog(@"Middle Description:%@", self.middlePolaroidCardView.polaroid.polaroidDescription);
    //NSLog(@"Current Description:%@", self.currentPolaroidDescription);
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
        [self.frontPolaroidCardView addGestureRecognizer:self.doubleTapGR];
        //NSLog(@"Genre of Current Polaroid: %@", self.frontPolaroidCardView.polaroid.genre);
    }
    else if (self.imageIndex == [self.photoBank count])
    {
//        //RESET THE IMAGE INDEX IF THE USER HAS REACHED THE END OF THE POLAROID ARRAY
        self.imageIndex = 0;
//        self.thumbnailIndex = 0;
//
        //PolaroidDatabase *ivc = [PolaroidDatabase sharedDefaultPolaroidDatabase];
        //[ivc fetch];
        NSLog(@"Fetch More Polaroids!");
    
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
        [self.frontPolaroidCardView addGestureRecognizer:self.doubleTapGR];
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
            
            [self.frontPolaroidCardView updateOverlay:_xDistance yDistance:_yDistance];
            self.frontPolaroidCardView.transform = thirdTransfrom;

            break;
        };
        case UIGestureRecognizerStateEnded:
        {
//            //If the image is moved more than 75 pixels in the x-direction, the image is removed from the view and
//            //a method WILL BE triggered to add the image to an array of boringImages or interestMeImages
                
//Swipe Right - Image is interesting
            if (self.xDistance > 75 && self.yDistance < ySensitivity)
            {
                [UIView animateWithDuration:0.2 delay:0.00 options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     CGAffineTransform scale = CGAffineTransformMakeScale(.75, .75);
                                     CGAffineTransform translate = CGAffineTransformMakeTranslation(700.0, 0.0);
                                     
                                     self.frontPolaroidCardView.center = CGPointMake(self.originalPoint.x + self.xDistance, self.originalPoint.y + self.yDistance);
                                     self.frontPolaroidCardView.transform = CGAffineTransformConcat(scale, translate);

                                 }
                                 completion:^(BOOL finished) {
                                    NSLog(@"Follow branch with polariods with genre %@", self.frontPolaroidCardView.polaroid.genre);
                                     self.frontPolaroidCardView.polaroid.interestingToMe = YES;
                                     self.frontPolaroidCardView.polaroid.savedByMe = YES;
                                     
                                     self.frontPolaroidCardView.polaroid.numberOfTimesSaved++;
                                     self.frontPolaroidCardView.polaroid.numberOfPeopleInterestedInThis++;
                                     self.frontPolaroidCardView.polaroid.viewed = YES;
                                      [self.frontPolaroidCardView hideOverlay];
                                     
                                     [self handlePostToServer:self.userIdentification polaroidID:self.frontPolaroidCardView.polaroid.polaroid_ID sent:0 saved:0 boring:0 interesting:1];
                                     
                                     //[self photoBank:[NSPredicate predicateWithFormat:self.frontPolaroidCardView.polaroid.genre]];
                                     [self interateTheNextPolaroid];
                                     self.remainingPolaroids--;
                                     [self trackRemainingPolaroids];

                                     
                                 }
                 ];
                
                break;
            }
            
//Swipe Left - Image is boring
            else if (self.xDistance < - 75 && self.yDistance < ySensitivity)
            {
                [UIView animateWithDuration:0.2 delay:0.00 options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     CGAffineTransform scale = CGAffineTransformMakeScale(.75, .75);
                                     CGAffineTransform translate = CGAffineTransformMakeTranslation(-700.0, 0.0);
                                     
                                     self.frontPolaroidCardView.center = CGPointMake(self.originalPoint.x + self.xDistance, self.originalPoint.y + self.yDistance);
                                     self.frontPolaroidCardView.transform = CGAffineTransformConcat(scale, translate);
                                     
                                 }
                                 completion:^(BOOL finished) {
                                     NSLog(@"Find a new branch");
                                     //self.boringToMe = YES;
                                     self.frontPolaroidCardView.polaroid.boringToMe = YES;
                                     self.frontPolaroidCardView.polaroid.image = nil;
                                     self.frontPolaroidCardView.polaroid.numberOfPeopleBoredByThis++;
                                     self.frontPolaroidCardView.polaroid.viewed = YES;
                                     [self.frontPolaroidCardView hideOverlay];
                                     
                                    [self handlePostToServer:self.userIdentification polaroidID:self.frontPolaroidCardView.polaroid.polaroid_ID sent:0 saved:0 boring:1 interesting:0];
                                     
                                     //[self photoBank];
                                     [self interateTheNextPolaroid];
                                     self.remainingPolaroids--;
                                     [self trackRemainingPolaroids];
                                     

                                 }
                 ];
                
                break;
            }

//Swipe Up - Send Image
            if (self.yDistance < - 15 && self.xDistance < xSensitivity)
            {
                [self resetViewPositionAndTransformations];
                self.frontPolaroidCardView.polaroid.viewed = YES;
                [self.frontPolaroidCardView hideOverlay];
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
                         [self.frontPolaroidCardView hideOverlay];
                     }
                     completion:^(BOOL finished) {
                         [self.middlePolaroidCardView unshadePolaroidBackground];
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
        //NSLog(@"Score went up: %f", swipeValue);
    }
    else
    {
        self.interestMeScore = self.interestMeScore - swipeValue;
        //NSLog(@"Score went down: %f", swipeValue);
    }
    self.interestMeScoreLabel.text = [NSString stringWithFormat:@"%d", self.interestMeScore];
}

- (void)setInterestMeScore:(int)interestMeScore //HIDDEN FOR THIS VERSION OF INTERESTME
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
}

- (void)tapPolaroidView:(id)sender
{
    NSLog(@"Polaroid View was Tapped!");
    FullScreenViewController *ivc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"FullScreenViewID"];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    ivc.imageURL =  [NSURL URLWithString:self.currentPolaroidImageURL];
    //NSLog(@"Current Polaroid Title:%@", self.currentPolaroidDescription);
    ivc.fullScreenTitle = self.currentPolaroidTitle;
    ivc.fullScreenDescription = self.currentPolaroidDescription;
    ivc.fullScreenSourceURL = self.currentPolaroidSourceURL;
 
    [self.navigationController pushViewController:ivc animated:YES];
}

- (void)doubleTapPolaroidView:(id)sender
{
    NSLog(@"Polaroid View was Double Tapped!");
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    myWebView *controller = (myWebView*)[mainStoryboard instantiateViewControllerWithIdentifier: @"WebViewID"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    controller.webViewURL = [NSURL URLWithString:self.frontPolaroidCardView.polaroid.sourceURL];
    
    // present
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"thumbnailToFullScreen"])
    {
        if ([segue.destinationViewController isKindOfClass:[FullScreenViewController class]]) {
            [[self navigationController] setNavigationBarHidden:YES animated:NO];
            FullScreenViewController *ivc = (FullScreenViewController *)segue.destinationViewController;
            //NSLog(@"Thumbnail Hit %d", self.thumbnailIndex);
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
                         self.remainingPolaroids--;
                         [self trackRemainingPolaroids];

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
