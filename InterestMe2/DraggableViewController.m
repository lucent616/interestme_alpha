//
//  CDWViewController.m
//  InterestMe2
//
//  Created by Collin Wallace on 4/10/14.
//  Copyright (c) 2014 Collin Wallace. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "DraggableViewController.h"
#import "FullScreenViewController.h"
#import "PolaroidCardView.h"
#import "PolaroidDatabase.h"
#import "PolaroidCollectionViewController.h"
#import "SettingsTVC.h"


@interface DraggableViewController () <MFMessageComposeViewControllerDelegate>//<MFMailComposeViewControllerDelegate>
@property (nonatomic, strong,nonatomic) PolaroidWithinDraggableView *draggableView;

@property (weak, nonatomic) IBOutlet UIButton *thumbnailImageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *interestSettingsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *interestBoardButton;
@property (weak, nonatomic) IBOutlet UILabel *interestMeScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendScoreLabel;
@property (strong, nonatomic) NSMutableArray *urlBank;
@property (strong, nonatomic) IBOutlet UIView *globalView;

@property (weak, nonatomic) IBOutlet PolaroidCardView *frontPolaroidCardView;
@property (weak, nonatomic) IBOutlet PolaroidCardView *middlePolaroidCardView;
@property (weak, nonatomic) IBOutlet PolaroidCardView *backPolaroidCardView;
@property (weak, nonatomic) IBOutlet PolaroidCardView *tempPolaroidCardView;

@property (strong, nonatomic) UIImage *polaroidImage;
@property (strong, nonatomic) NSURL *polaroidImageURL;
@property (strong, nonatomic) UIImage *polaroidThumbnailImage;
@property (strong, nonatomic) NSString *polaroidThumbnailImageURL;
@property (strong, nonatomic) NSString *currentPolaroidImageURL;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGR;
@property (strong, nonatomic) NSData *imageData;
@property (nonatomic) CGPoint panPoint;
@property (nonatomic) CGPoint originalPoint;
@property (nonatomic) CGAffineTransform originalTransform;
@property (nonatomic) CGFloat xDistance;
@property (nonatomic) CGFloat  yDistance;
@property (nonatomic) int thumbnailIndex;
@property (nonatomic) int interestMeScore;
@property (nonatomic) int friendScore;
@end

@implementation DraggableViewController

///////////////////////////////////////////////////////////////////////////ADJUSTMENT VALUES
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define POLAROID_STAGING_OFFSET 2
static int ySensitivity = 150;
static int xSensitivity = 40;
////////////END OF ADJUSTMENT VALUES

- (void)viewDidLoad
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"interestMeTitle.png"]];
    
    [super viewDidLoad];
    
    //setup database
    PolaroidDatabase *polaroidDB = [PolaroidDatabase sharedDefaultPolaroidDatabase];
    if (polaroidDB.managedObjectContext) {
        self.managedObjectContext = polaroidDB.managedObjectContext;
        [self stagePolaroids];
    } else {
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:PolaroidDatabaseAvailable
                                                                        object:polaroidDB
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:^(NSNotification *note) {
                                                                        self.managedObjectContext = polaroidDB.managedObjectContext;
                                                                        [self stagePolaroids];
                                                                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                    }];
    }
    
    self.filterBank = [[NSMutableDictionary alloc]init];
    [self.filterBank setValue:@1 forKeyPath:@"art"];
    [self.filterBank setValue:@1 forKeyPath:@"cars"];
    [self.filterBank setValue:@1 forKeyPath:@"design"];
    [self.filterBank setValue:@1 forKeyPath:@"homes"];
    
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
        request.predicate = [self getPredicate];
        
        //NSLog(@"filterBank: %@", self.filterBank);
        //NSLog(@"predicates: %@", request.predicate);



        /*
        request.sortDescriptors = @[
                                    [NSSortDescriptor sortDescriptorWithKey:@"genre" ascending:YES],
                                    ];
         */
        _photoBank = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        
        _imageIndex = 0;
        _thumbnailIndex = 0;
    }
    
    return _photoBank;
}


- (void)stagePolaroids
{
    self.frontPolaroidCardView.polaroid = self.photoBank[0];
    [self.frontPolaroidCardView startDownloadingImage];
    
    
    self.middlePolaroidCardView.polaroid = self.photoBank[1];
    [self.middlePolaroidCardView startDownloadingImage];
    
    self.backPolaroidCardView.polaroid = self.photoBank[2];
    [self.backPolaroidCardView startDownloadingImage];


    self.tempPolaroidCardView = nil;
    
    [self.frontPolaroidCardView shadePolaroidBackground];
    self.currentPolaroidImageURL = self.frontPolaroidCardView.polaroid.imageURL;
    
//    CGAffineTransform clockwiseRotate = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-POLAROID_STAGING_OFFSET));
//    CGAffineTransform counterClockwiseRotate = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(POLAROID_STAGING_OFFSET));
//    
//    self.middlePolaroidCardView.transform = counterClockwiseRotate;
//    self.backPolaroidCardView.transform = clockwiseRotate;
}

- (void)interateTheNextPolaroid
{
    //NSLog(@"Initial imageIndex is: %d", self.imageIndex);
    self.polaroidThumbnailImage = self.frontPolaroidCardView.polaroidImage;
    self.polaroidThumbnailImageURL = self.frontPolaroidCardView.polaroid.imageURL;
    self.currentPolaroidImageURL = self.middlePolaroidCardView.polaroid.imageURL;
    [self.thumbnailImageButton setBackgroundImage:self.polaroidThumbnailImage forState:UIControlStateNormal];
/*
 Redraw the old frontPolaroid behind the nextPolaroid
 Set the middlePolaroid equal to the frontPolaroid
 Change the image of the frontpolaroid view
 Rename the frontPolaroidView the nextPolaroidView
 Reset the position of the frontPolaroid View
 
 */
    self.imageIndex++;
    [self positionNextPolaroid];

    if (self.imageIndex < [self.photoBank count])
    {
        self.tempPolaroidCardView = self.frontPolaroidCardView;
        
        self.tempPolaroidCardView.polaroid = self.photoBank[self.imageIndex];
        [self.tempPolaroidCardView startDownloadingImage];
        [self.tempPolaroidCardView setNeedsDisplay];
        
        self.frontPolaroidCardView = self.middlePolaroidCardView;
        [self.frontPolaroidCardView shadePolaroidBackground];
        
        self.middlePolaroidCardView = self.backPolaroidCardView;
        self.backPolaroidCardView = self.tempPolaroidCardView;
        //Amend the image information to reflect the users interest in the image
        
        [self calculateAndSetInterestMeScore];
        NSLog(@"InterestMe Score: %d", self.interestMeScore);
        self.friendScore++;

    }
    else if (self.imageIndex == [self.photoBank count])
    {
        self.imageIndex = 0;
        self.thumbnailIndex = 0;
        
        self.tempPolaroidCardView = self.frontPolaroidCardView;
        
        self.tempPolaroidCardView.polaroid = self.photoBank[self.imageIndex];
        [self.tempPolaroidCardView startDownloadingImage];
        [self.tempPolaroidCardView setNeedsDisplay];
        
        self.frontPolaroidCardView = self.middlePolaroidCardView;
        [self.frontPolaroidCardView shadePolaroidBackground];
        self.middlePolaroidCardView = self.backPolaroidCardView;
        self.backPolaroidCardView = self.tempPolaroidCardView;
    }
}

- (IBAction)dragPolaroid:(UIPanGestureRecognizer *)gestureRecognizer
{
    self.navigationController.navigationBar.hidden = NO;
    CGFloat xDistance = [gestureRecognizer translationInView:self.globalView].x;
    CGFloat yDistance = [gestureRecognizer translationInView:self.globalView].y;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            [self.middlePolaroidCardView shadePolaroidBackground];
            self.originalPoint = self.frontPolaroidCardView.center;
            self.originalTransform = self.frontPolaroidCardView.transform;
            break;
        };
        case UIGestureRecognizerStateChanged:
        {
            CGFloat rotationStrength = MIN(xDistance / 320, 1);
            CGFloat rotationAngle = (CGFloat) (2*M_PI/16 * rotationStrength);
            CGFloat scaleStrength = 1 - fabsf(rotationStrength) / 4;
            CGFloat scale = MAX(scaleStrength, 0.65);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(xDistance, yDistance);
            CGAffineTransform differentTransform = CGAffineTransformScale(translation, scale, scale);
            CGAffineTransform thirdTransfrom = CGAffineTransformRotate(differentTransform, rotationAngle);

            self.frontPolaroidCardView.transform = thirdTransfrom;

            //[self updateOverlay:xDistance];
                
            break;
        };
        case UIGestureRecognizerStateEnded:
        {
//            //If the image is moved more than 100 pixels in the x-direction, the image is removed from the view and
//            //a method WILL BE triggered to add the image to an array of boringImages or interestMeImages
                
            //Swipe Left - Image is boring
            if (xDistance < - 75 && yDistance < ySensitivity)
            {
                [UIView animateWithDuration:0.2 delay:0.00 options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     CGAffineTransform scale = CGAffineTransformMakeScale(.75, .75);
                                     CGAffineTransform translate = CGAffineTransformMakeTranslation(-700.0, 0.0);
                                     
                                     self.frontPolaroidCardView.center = CGPointMake(self.originalPoint.x + xDistance, self.originalPoint.y + yDistance);
                                     self.frontPolaroidCardView.transform = CGAffineTransformConcat(scale, translate);
                                     
                                 }
                                 completion:^(BOOL finished) {
                                     //self.boringToMe = YES;
                                     self.frontPolaroidCardView.polaroid.boringToMe = YES;
                                     self.frontPolaroidCardView.polaroid.numberOfPeopleBoredByThis++;
                                     [self interateTheNextPolaroid];
                                 }
                 ];
                
                break;
            }
            //Swipe Right - Image is interesting
            else if (xDistance > 75 && yDistance < ySensitivity)
            {
                [UIView animateWithDuration:0.2 delay:0.00 options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     CGAffineTransform scale = CGAffineTransformMakeScale(.75, .75);
                                     CGAffineTransform translate = CGAffineTransformMakeTranslation(700.0, 0.0);
                                     
                                     self.frontPolaroidCardView.center = CGPointMake(self.originalPoint.x + xDistance, self.originalPoint.y + yDistance);
                                     self.frontPolaroidCardView.transform = CGAffineTransformConcat(scale, translate);
                                     
                                 }
                                 completion:^(BOOL finished) {
                                    self.frontPolaroidCardView.polaroid.interestingToMe = YES;
                                    self.frontPolaroidCardView.polaroid.savedByMe = YES;
                                     self.frontPolaroidCardView.polaroid.numberOfTimesSaved++;
                                     self.frontPolaroidCardView.polaroid.numberOfPeopleInterestedInThis++;
                                    [self interateTheNextPolaroid];
                                 }
                 ];
                
                break;
            }
            //Swipe Up - Send Image
            if (yDistance < - 20 && xDistance < xSensitivity)
            {
                [UIView animateWithDuration:0.2 delay:0.00 options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     CGAffineTransform scale = CGAffineTransformMakeScale(.75, .75);
                                     CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, -700.0);
                                     
                                     self.frontPolaroidCardView.center = CGPointMake(self.originalPoint.x + xDistance, self.originalPoint.y + yDistance);
                                     self.frontPolaroidCardView.transform = CGAffineTransformConcat(scale, translate);
                                     
                                 }
                                 completion:^(BOOL finished) {
                                     //[self sendImageViaEmail];
                                     [self sendImageViaSMS];
                                     self.frontPolaroidCardView.polaroid.sentByMe = YES;
                                     self.frontPolaroidCardView.polaroid.numberOfTimesSent++;
                                     [self interateTheNextPolaroid];
                                 }
                 ];
                
                break;
            }
/////////////////////////////////////////////SWIPE DOWN - CURRENTLY DISABLED
//            else if (yDistance > 30 && xDistance < xSensitivity)
//            {
//                [UIView animateWithDuration:0.2 delay:0.00 options:UIViewAnimationOptionCurveEaseOut
//                                 animations:^{
//                                     CGAffineTransform scale = CGAffineTransformMakeScale(.75, .75);
//                                     CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 1000.0);
//                                     
//                                     self.frontPolaroidCardView.center = CGPointMake(self.originalPoint.x + xDistance, self.originalPoint.y + yDistance);
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
                         //self.overlayView.alpha = 0;
                     }];
}

- (void)positionNextPolaroid
{
    [self.view sendSubviewToBack:self.frontPolaroidCardView];
    [self.frontPolaroidCardView unshadePolaroidBackground];
    self.frontPolaroidCardView.center = self.originalPoint;
    self.frontPolaroidCardView.transform = CGAffineTransformMakeRotation(0);
}
//////////////////////////////////////////////////////END OF POLAROID BEHAVIOR

//////////////////////////////////////////////////////UPDATE SCORING INFORMATION

- (void)calculateAndSetInterestMeScore
{
    
    NSLog(@"Numbers %d", self.frontPolaroidCardView.polaroid.numberOfPeopleInterestedInThis);
    
    if (self.frontPolaroidCardView.polaroid.interestingToMe)
    {
        self.interestMeScore = (self.frontPolaroidCardView.polaroid.numberOfPeopleInterestedInThis/self.frontPolaroidCardView.polaroid.numberOfPeopleBoredByThis);
    }
    else
    {
        self.interestMeScore = (self.frontPolaroidCardView.polaroid.numberOfPeopleBoredByThis/self.frontPolaroidCardView.polaroid.numberOfPeopleInterestedInThis);
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

//////END OF SCORING INFORMATION





- (IBAction)tapOnGlobalView:(UITapGestureRecognizer *)sender
{
    self.navigationController.navigationBar.hidden = NO;
    //self.navigationController.navigationBar.hidden = !self.navigationController.navigationBarHidden;
    //NSLog(@"Someone tapped on my screen!");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"blowUpThumbnail"])
    {
        if ([segue.destinationViewController isKindOfClass:[FullScreenViewController class]]) {
            [[self navigationController] setNavigationBarHidden:YES animated:NO];
            FullScreenViewController *ivc = (FullScreenViewController *)segue.destinationViewController;
            //NSLog(@"Image Thumbnail hit: %d", self.imageIndex);
            ivc.imageURL = [NSURL URLWithString:self.tempPolaroidCardView.polaroid.imageURL];
        }
    }
    else if ([segue.identifier isEqualToString:@"savedByMe"])
    {
        if ([segue.destinationViewController isKindOfClass:[PolaroidCollectionViewController class]])
        {
            PolaroidCollectionViewController *ivc = (PolaroidCollectionViewController *) segue.destinationViewController;
            //NSLog(@"Polaroid Hit %d", self.imageIndex);
            ivc.managedObjectContext = self.managedObjectContext;
        }
    }
    else
    {
        if ([segue.destinationViewController isKindOfClass:[FullScreenViewController class]]) {
            [[self navigationController] setNavigationBarHidden:YES animated:NO];
            FullScreenViewController *ivc = (FullScreenViewController *)segue.destinationViewController;
            //NSLog(@"Polaroid Hit %d", self.imageIndex);
            ivc.imageURL = [NSURL URLWithString:self.currentPolaroidImageURL];
        }
    }
}


////////////////////////////////////////////////////////////////////////EMAIL PROTOCOL
//- (void)sendImageViaEmail
//{
//    NSString *emailTitle = @"Hey, I figured you would really like this. Found it on Pinterest";
//    NSString *messageBody = self.frontPolaroidCardView.polaroid.imageURL;
//    //NSArray *toRecipents = [NSArray arrayWithObject:@"any recipients I might want to add"];
//    NSData *attachment = UIImageJPEGRepresentation(self.polaroidThumbnailImage, 1.0);
//    NSString *uti = (NSString*)kUTTypeMessage;
//    
//    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
//    mc.mailComposeDelegate = self;
//    [mc setSubject:emailTitle];
//    [mc setMessageBody:messageBody isHTML:NO];
//    //[mc addAttachmentData:attachment mimeType:uti fileName:@"filename.jpg"];
//    
//    //[mc setToRecipients:toRecipents];
//
//    [self presentViewController:mc animated:YES completion:NULL];    // Call MailVC onto the screen
//}
//
//- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
//{
//    switch (result)
//    {
//        case MFMailComposeResultCancelled:
//            NSLog(@"Mail cancelled");
//            break;
//        case MFMailComposeResultSaved:
//            NSLog(@"Mail saved");
//            break;
//        case MFMailComposeResultSent:
//            NSLog(@"Mail sent");
//            break;
//        case MFMailComposeResultFailed:
//            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
//            break;
//        default:
//            break;
//    }
//    
//    [self dismissViewControllerAnimated:YES completion:NULL];    // Remove the MailVC
//}
/////////////END OF EMAIL PROTOCOL

////////////////////////////////////////////////////////////MMS PROTOCOL
- (void)sendImageViaSMS
{
    MFMessageComposeViewController* composer = [[MFMessageComposeViewController alloc] init];
    composer.messageComposeDelegate = self;
    NSString *imageTitle = self.frontPolaroidCardView.polaroid.title;
    composer.body = [NSString stringWithFormat:@"Hey, look at this %@ I found on InterestMe!", imageTitle];
    
    if([MFMessageComposeViewController respondsToSelector:@selector(canSendAttachments)] && [MFMessageComposeViewController canSendAttachments])
    {
        NSData *attachment = UIImageJPEGRepresentation(self.frontPolaroidCardView.polaroidImage, 1.0);
        NSString *uti = (NSString*)kUTTypeMessage;
        uti = @"adfkdlsfjdkf";
        [composer addAttachmentData:attachment typeIdentifier:uti filename:@"filename.jpg"];
    }
    
    [self presentViewController:composer animated:YES completion:nil];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSLog(@"Message Composition Result: %u", result);
    if (result == MessageComposeResultCancelled)
        NSLog(@"Message cancelled");
    else if (result == MessageComposeResultSent)
        NSLog(@"Message sent");
    else
        NSLog(@"Message failed");
    
    [self dismissViewControllerAnimated:YES completion:NULL];

}

@end
