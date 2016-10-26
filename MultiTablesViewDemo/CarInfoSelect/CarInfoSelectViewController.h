//
//  CarInfoSelectViewController.h
//  MultiTablesViewDemo
//
//  Created by 吴晓明 on 15/7/8.
//  Copyright (c) 2015年 吴晓明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridItem.h"

typedef void(^CarInfoSlectFinishBlock)();

@interface CarInfoSelectViewController : UIViewController

@property(nonatomic,copy)CarInfoSlectFinishBlock finishHandler;

@property(strong,nonatomic)GridItem* currentSelectedBrandItem;
@property(strong,nonatomic)GridItem* currentSelectedModelItem;
@property(strong,nonatomic)GridItem* currentSelectedDisplacementItem;

@end
