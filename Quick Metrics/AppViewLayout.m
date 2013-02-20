//
//  AppViewLayout.m
//  Quick Metrics
//
//  Created by Alex Kurkin on 2/10/13.
//  Copyright (c) 2013 Brilliant Consulting Inc. All rights reserved.
//

#import "AppViewLayout.h"

static NSString * const AppViewLayoutMetricCell = @"AppViewMetricCell";

@interface AppViewLayout()

@property (nonatomic, strong) NSDictionary *layoutInfo;

@end

@implementation AppViewLayout

#pragma mark -
#pragma mark Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setup];
    }

    return self;
}

- (void)setup
{
//    NSLog(@"AppViewLayout setup called");
    self.itemInsets = UIEdgeInsetsMake(60.0f, 20.0f, 8.0f, 20.0f);
    self.itemSize = CGSizeMake(130.0f, 108.0f);
    self.interItemSpacingY = 20.0f;
    self.numberOfColumns = 2;

//    [self registerClass:[AppViewHeaderView class] forDecorationViewOfKind:@"AppViewHeader"];
}

#pragma mark -
#pragma mark Layout

- (void)prepareLayout {
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:@"AppViewHeader" withIndexPath:indexPath];

    headerAttributes.frame = CGRectMake(0, 0, 320, 40);
    newLayoutInfo[@"AppViewHeader"] = @{indexPath: headerAttributes};
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForMetricAtIndexPath:indexPath];
            
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[AppViewLayoutMetricCell] = cellLayoutInfo;
    
//    NSLog(@"newLayoutInfo: %@", newLayoutInfo);
    
    self.layoutInfo = newLayoutInfo;
}

- (CGRect) frameForMetricAtIndexPath: (NSIndexPath *) indexPath {
    NSInteger row = indexPath.row / self.numberOfColumns;
    NSInteger column = indexPath.row % self.numberOfColumns;

    CGFloat spacingX = self.collectionView.bounds.size.width - self.itemInsets.left - self.itemInsets.right - (self.numberOfColumns * self.itemSize.width);

    if (self.numberOfColumns > 1) {
        spacingX = spacingX / (self.numberOfColumns - 1);
    }

    CGFloat originX = floorf(self.itemInsets.left + (self.itemSize.width + spacingX) * column);
    CGFloat originY = floor(self.itemInsets.top + (self.itemSize.height + self.interItemSpacingY) * row);

//    NSLog(@"indexPath = {%i, %i}, row and column = {%i, %i} spacing = {%f, %f}, originX = %f, originY = %f", indexPath.section, indexPath.row, row, column, spacingX, self.interItemSpacingY, originX, originY);

    return CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[AppViewLayoutMetricCell][indexPath];
}

- (CGSize)collectionViewContentSize {
    NSInteger cellCount = [self.layoutInfo[AppViewLayoutMetricCell] allKeys].count;
    NSInteger rowCount = cellCount / self.numberOfColumns;
    
    // make sure we count another row if one is only partially filled
    if (cellCount % self.numberOfColumns) rowCount++;
    
    CGFloat height = self.itemInsets.top + rowCount * self.itemSize.height + (rowCount - 1) * self.interItemSpacingY + self.itemInsets.bottom;
    
    //    NSLog(@"collectionViewContentSize: rows: %i", rowCount);
    
    return CGSizeMake(self.collectionView.bounds.size.width, height);
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[@"AppViewHeader"][indexPath];
}

@end
