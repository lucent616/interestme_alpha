//
//  CharacterCollectionViewController.m
//  LittleFighters
//
//  Created by Alexander Hsu on 5/2/14 for CS193P Section

#import "PolaroidCollectionViewController.h"
#import "DraggableViewController.h"
#import "Polaroid+AddOn.h"
#import "PolaroidCardView.h"
#import "UIImage+AddOn.h"

@interface PolaroidCollectionViewController ()
// Image names for thumbnails
@property (strong, nonatomic) NSMutableArray *polaroidsSavedByMe;
@end

@implementation PolaroidCollectionViewController

#define NUM_THUMBNAIL 15

// Lazy instantiation for names of thumbnails
- (NSMutableArray *)polaroidsSavedByMe
{
    if(!_polaroidsSavedByMe)
    {
        _polaroidsSavedByMe = [[NSMutableArray alloc] init];
        NSError *error;
        NSFetchRequest *request  = [NSFetchRequest fetchRequestWithEntityName:@"Polaroid"];
        request.predicate = [NSPredicate predicateWithFormat:@"savedByMe == YES"];

        _polaroidsSavedByMe = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    }
    
    //NSLog(@"Saved Polaroid Array: %@", _polaroidsSavedByMe);
    return _polaroidsSavedByMe;
}

#pragma mark - DataSource methods

// OPTIONAL: Number of sections
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1; //default
}

// REQUIRED: Number of items in section. (Number of thumbnails)
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.polaroidsSavedByMe.count;
}

// REQUIRED: Set up each cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Cells that goes off screen are enqueued into a reuse pool
    // The method below looks for reuseable cell
    PolaroidCollectionViewCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PolaroidCell" forIndexPath:indexPath];
    if (!myCell)
        myCell = [[PolaroidCollectionViewCell alloc] init];
    
    // IndexPath specifies the section and row of a cell. Here, row is equivalent to the index.
    // Set the image of the cell.
    //NSLog(@"path: %d", indexPath.row);
    Polaroid *polaroid = self.polaroidsSavedByMe[indexPath.row];
    
    //TRYING TO RESIZE CELLS
//    float cellHeight = myCell.imageView.image.size.height;
//    float cellWidth = myCell.imageView.image.size.width;
//    CGSize targetCellSize = CGSizeMake(cellWidth, cellHeight);
//    UIImage *resizedCellImage = [UIImage imageToFitSize:[UIImage imageWithData:polaroid.image] size:targetCellSize method:MGImageResizeCrop];
    //myCell.imageView.image = resizedCellImage;
    myCell.imageView.image = [UIImage imageWithData:polaroid.image]; //THIS IS WHERE I NEED TO CHANGE THE RESIZING METHOD FOR THE TARGET CELLS
    return myCell;
}



// OPTIONAL: Set up header section in collectionView
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    // Will crash if return nil
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                          withReuseIdentifier:@"Header" forIndexPath:indexPath];
    return header;
}

@end
