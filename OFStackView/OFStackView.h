//
//  OFStackView.h
//  MultiTablesViewDemo
//
//  Created by 吴晓明 on 15/7/8.
//  Copyright (c) 2015年 吴晓明. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OFStackView;

@protocol OFStackViewDataSource <NSObject>
@required

- (NSInteger)numberOfStackView:(OFStackView *)stackView ;
-(CGFloat)stackView:(OFStackView *)stackView viewOffSetAtIndex:(NSInteger)index;
- (UIView *)stackView:(OFStackView *)stackView customViewAtIndex:(NSInteger)index withContainerView:(UIView*)containerView;

@end

@protocol OFStackViewDelegate <NSObject>
@required

-(void)stackView:(OFStackView *)stackView loadDataAtIndex:(NSInteger)index;

@end

@interface OFStackView : UIView

@property(nonatomic,assign)id<OFStackViewDataSource> dataSource;
@property(nonatomic,assign)id<OFStackViewDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame;

- (void)hideStackViewFromIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(void))completion;
-(void)showStackViewAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(void))completion;
-(BOOL)viewHiddenAtIndex:(NSInteger)index;
-(void)reloadData;

@end
