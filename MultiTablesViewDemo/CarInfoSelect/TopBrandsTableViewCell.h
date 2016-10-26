//
//  TopBrandsTableViewCell.h
//  MultiTablesViewDemo
//
//  Created by 吴晓明 on 15/7/9.
//  Copyright (c) 2015年 吴晓明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridItem.h"

typedef NS_ENUM(NSInteger, GridItemViewType){
    GridItemViewType_ImageText,
    GridItemViewType_Text,
};

@class GridItemView;
@protocol GridItemViewDelegate <NSObject>

-(void)GridItemViewClick:(GridItemView*)itemView;

@end

/**
 搜索页面的单个cell
 */
@interface GridItemView : UIView
@property(nonatomic,strong)GridItem* itemInfo;
@property(nonatomic,retain)UIColor* textColor;
@property(nonatomic,assign)GridItemViewType type ;

@property(nonatomic,weak)id<GridItemViewDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame type:(GridItemViewType)type;

@end

@interface TopBrandsTableViewCell : UITableViewCell

//item 是 CarItem对象
@property(nonatomic,strong)NSArray* carInfoArray;
@property(nonatomic,weak)id<GridItemViewDelegate> delegate;
@end
