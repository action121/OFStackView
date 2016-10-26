//
//  CarInfoSelectTableViewCell.h
//  MultiTablesViewDemo
//
//  Created by 吴晓明 on 15/7/8.
//  Copyright (c) 2015年 吴晓明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridItem.h"

#define THEME_TINT_COLOR   [UIColor colorWithRed:0.220 green:0.706 blue:0.918 alpha:1.00]

@interface CarInfoSelectTableViewCell : UITableViewCell

@property(nonatomic,strong)GridItem* itemInfo;

@end
