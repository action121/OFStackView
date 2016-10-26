//
//  TopBrandsTableViewCell.m
//  MultiTablesViewDemo
//
//  Created by 吴晓明 on 15/7/9.
//  Copyright (c) 2015年 吴晓明. All rights reserved.
//

#import "TopBrandsTableViewCell.h"
#import "MyUIPageControl.h"
#import "UIView+Oxygen.h"
#import "UIImageView+WebCache.h"
#import "GridItem.h"
#import "NSString+Oxygen.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define TEXT_PADDING            10
#define MAX_SHOW_ITEM_COUNT     4.0
const CGFloat pageControlHeight = 36 ; // 系统默认

@interface GridItemView ()<UIGestureRecognizerDelegate>
{
    UIImageView* _imageView;
    UILabel* _sortNameLabel;
    
}


@end

@implementation GridItemView

-(instancetype)initWithFrame:(CGRect)frame type:(GridItemViewType)type{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        [self setUp];
    }
    return self;
}
-(void)onClick:(UIGestureRecognizer*)gesture{
    if (_delegate && [_delegate respondsToSelector:@selector(GridItemViewClick:)]) {
        [_delegate GridItemViewClick:self];
    }
}
-(void)setUp{
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    switch (_type) {
        case GridItemViewType_ImageText:
            [self setUpImageTextType];
            break;
            
        default:
            [self setUpTextType];
            break;
    }
    
}
-(void)setUpImageTextType{
    
    CGFloat contentPadding = 10;
    CGFloat imageWidth = self.width - contentPadding * 2;
    imageWidth = MAX(imageWidth, 0);
    imageWidth = MIN(imageWidth, 64);
    contentPadding = (self.width - imageWidth) / 2;
    
    CGFloat imageHeight = imageWidth;
    CGRect imageRect = CGRectMake(0, 0, imageWidth, imageHeight);
    _imageView = [[UIImageView alloc] initWithFrame:imageRect];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    
    _sortNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 14)];
    _sortNameLabel.font = [UIFont systemFontOfSize:14];
    _sortNameLabel.backgroundColor = [UIColor clearColor];
    _sortNameLabel.textColor = UIColorFromRGB(0x999999);
    _sortNameLabel.textAlignment = NSTextAlignmentCenter;
    _sortNameLabel.lineBreakMode = NSLineBreakByClipping;
    [self addSubview:_sortNameLabel];

    CGFloat spaceY = TEXT_PADDING;
    
    CGFloat imageY = (self.height - _imageView.height - spaceY - _sortNameLabel.height) / 2;
    CGFloat imageX = (self.width - _imageView.width) / 2;
    _imageView.origin = CGPointMake(imageX, imageY);
    
    _sortNameLabel.top = _imageView.bottom + spaceY;
    
}
-(void)setUpTextType{

}
-(void)setItemInfo:(GridItem *)itemInfo{
    _itemInfo = itemInfo;
    if (_type == GridItemViewType_ImageText) {
        NSURL* URL = [NSURL URLWithString:itemInfo.imageUrl];
        [_imageView sd_setImageWithURL:URL
                      placeholderImage:nil options:SDWebImageRetryFailed];
        _sortNameLabel.text = itemInfo.itemDescription;
        
    }else if (_type == GridItemViewType_Text){
        
    }
}


-(void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    if (textColor) {
        _sortNameLabel.textColor = textColor;
    }
}
@end



@interface TopBrandsTableViewCell()<GridItemViewDelegate,UIScrollViewDelegate>{
    BOOL _itemViewContainerLayouted;
}
@property(nonatomic,strong)UIScrollView* scrollContainerView;
@property(nonatomic,strong)MyUIPageControl *pageControl;
@property(nonatomic,assign)NSInteger pageCount;
@end

@implementation TopBrandsTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUP];
    }
    return self;
}
-(void)setUP{
    _scrollContainerView = [[UIScrollView alloc] initWithFrame:CGRectZero];
     _scrollContainerView.pagingEnabled = YES;
    _scrollContainerView.delegate = self;
    _itemViewContainerLayouted = NO;
    _pageCount = 0;
    
    [self.contentView addSubview:_scrollContainerView];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

   
}
-(MyUIPageControl*)pageControl{
    if (!_pageControl) {
       
        _pageControl = [[MyUIPageControl alloc] initWithCenter:CGPointMake(self.width / 2, self.height - pageControlHeight / 2 )];
        _pageControl.currentPage = 0;
        _pageControl.userInteractionEnabled = NO;
        _pageControl.numberOfPages = _pageCount;
        _pageControl.currentPage = 0;
    }
    return _pageControl;
}
-(void)resetItems{
    _scrollContainerView.contentSize = _scrollContainerView.bounds.size;
    for (UIView* childView in _scrollContainerView.subviews) {
        [childView removeFromSuperview];
    }
    
    CGFloat itemWidth = _scrollContainerView.width / MAX_SHOW_ITEM_COUNT;
    CGFloat startX = 0;
    for (int i = 0; i < _carInfoArray.count; i ++) {
        GridItemView* itemView = [[GridItemView alloc] initWithFrame:CGRectMake(startX, 0, itemWidth, _scrollContainerView.height ) type:GridItemViewType_ImageText];
        GridItem* itemInfo = _carInfoArray[i];
        itemView.itemInfo = itemInfo;
        itemView.delegate = self.delegate;
        [_scrollContainerView addSubview:itemView];
        
        startX += itemWidth;
    }
    NSInteger pageCount = ceil([_carInfoArray count] / MAX_SHOW_ITEM_COUNT);
    _scrollContainerView.contentSize = CGSizeMake(pageCount*_scrollContainerView.width, _scrollContainerView.height);

    if (pageCount > 1){
        [_scrollContainerView setContentOffset:CGPointMake(_scrollContainerView.width, 0) animated:NO] ;
    }
}
-(void)resetContainer{
    if (_pageCount <= 1) {
        [_pageControl removeFromSuperview];
        _scrollContainerView.top = (self.contentView.height - _scrollContainerView.height) / 2;
    }else{
        _scrollContainerView.top = 0;
        _scrollContainerView.height = self.contentView.height - pageControlHeight;
        [self.contentView addSubview:self.pageControl];
    }
}
-(void)setCarInfoArray:(NSArray *)carInfoArray{
    NSInteger pageCount = ceil([carInfoArray count] / MAX_SHOW_ITEM_COUNT);
    _pageCount = pageCount;
    
    [self resetContainer];
    
    //添加最后一页 用于循环
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:pageCount+2];
    if (pageCount > 1){
        
        for (int i = (pageCount - 1) * MAX_SHOW_ITEM_COUNT; i < carInfoArray.count; i++) {
            id obj = [carInfoArray objectAtIndex:i];
            [itemArray addObject:obj];
        }
        if (itemArray.count < MAX_SHOW_ITEM_COUNT) {
            NSInteger emptyCount = (MAX_SHOW_ITEM_COUNT - itemArray.count);
            for (int i = 0; i < emptyCount; i++) {
                GridItem* emptyItem = [[GridItem alloc] init];
                [itemArray addObject:emptyItem];
            }
        }
    }
    
    [itemArray addObjectsFromArray:carInfoArray];
    
    NSInteger emptyCount = MAX_SHOW_ITEM_COUNT - (NSInteger)carInfoArray.count % (NSInteger)MAX_SHOW_ITEM_COUNT;
    if (emptyCount < MAX_SHOW_ITEM_COUNT) {
        for (int i = 0; i < emptyCount; i++) {
            GridItem* emptyItem = [[GridItem alloc] init];
            [itemArray addObject:emptyItem];
        }
    }

    //添加第一页 用于循环
    if (pageCount > 1){
        for (int i = 0; i < MAX_SHOW_ITEM_COUNT; i++) {
            id obj = [carInfoArray objectAtIndex:i];
            [itemArray addObject:obj];
        }
    }

    _carInfoArray = [NSArray arrayWithArray:itemArray];
    
    if (_itemViewContainerLayouted) {
        [self resetItems];
    }
    
}
-(void)layoutSubviews{

    [super layoutSubviews];

    CGRect containerFrame = self.contentView.bounds;
    containerFrame.size.height -= pageControlHeight;
    _scrollContainerView.frame = containerFrame;
     self.pageControl.numberOfPages = _pageCount;
    self.pageControl.center = CGPointMake(self.contentView.width / 2, self.contentView.height - pageControlHeight / 2 );
   
    [self resetContainer];
    
    if (!_itemViewContainerLayouted) {
        [self resetItems];
    }
    _itemViewContainerLayouted = YES;

}


#pragma mark - UIScrollViewDelegate
- (void)switchFocusImageItems
{

    CGFloat targetX = _scrollContainerView.contentOffset.x + _scrollContainerView.frame.size.width;
    targetX = (int)(targetX/_scrollContainerView.width) * _scrollContainerView.width;
    [self moveToTargetPosition:targetX];

    
}
- (void)moveToTargetPosition:(CGFloat)targetX
{
    BOOL animated = YES;
    [_scrollContainerView setContentOffset:CGPointMake(targetX, 0) animated:animated];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float targetX = scrollView.contentOffset.x;
    NSInteger pageCount = [_carInfoArray count] / MAX_SHOW_ITEM_COUNT;
    if (pageCount >= 3){
        if (targetX >= scrollView.width * (pageCount -1)) {
            targetX = scrollView.width;
            [scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
        }else if(targetX <= 0){
            targetX = scrollView.width *(pageCount - 2);
            [scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
        }
    }
    NSInteger page = (scrollView.contentOffset.x + scrollView.width/2.0) / scrollView.width;
    if (pageCount > 1) {
        page --;
        if (page >= _pageControl.numberOfPages){
            page = 0;
        }else if(page <0){
            page = _pageControl.numberOfPages - 1;
        }
    }

    _pageControl.currentPage = page;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        CGFloat targetX = scrollView.contentOffset.x + scrollView.frame.size.width;
        targetX = (int)(targetX/scrollView.width) * scrollView.width;
        [scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    }
}

@end
