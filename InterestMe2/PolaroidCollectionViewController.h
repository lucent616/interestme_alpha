//
//  CharacterCollectionViewController.h
//  LittleFighters
//
//  Created by Alexander Hsu on 5/2/14 for CS193P Section

#import <UIKit/UIKit.h>
#import "PolaroidCollectionViewCell.h"
#import "FullScreenViewController.h"

@interface PolaroidCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
