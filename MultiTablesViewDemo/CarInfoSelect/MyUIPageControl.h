//
//  MyUIPageControl.h
//  GameVideo
//
//  Created by 吴晓明 on 14/10/24.
//  Copyright (c) 2014年 吴晓明. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MyUIPageControl : UIView
{
    CGPoint m_center;
}

@property (nonatomic, setter = setImagePageStateNormal:,assign) UIImage *imagePageStateNormal;  //普通点点图片
@property (nonatomic, setter = setImagePageStateHightlighted:,assign) UIImage *imagePageStateHightlighted; //当前页面点点图片

@property(nonatomic) BOOL hidesForSinglePage;
@property (nonatomic, setter = setNumberOfPages:,assign) NSUInteger numberOfPages;
@property (nonatomic, setter = setCurrentPage:,assign) NSUInteger currentPage;

- (id)initWithCenter:(CGPoint)center;
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;
@end