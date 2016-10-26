//
//  OFStackView.m
//  MultiTablesViewDemo
//
//  Created by 吴晓明 on 15/7/8.
//  Copyright (c) 2015年 吴晓明. All rights reserved.
//

#import "OFStackView.h"
#import "UIView+Oxygen.h"

@interface OFStackView ()
@property(nonatomic,assign)NSInteger stackViewNumber;
@property(nonatomic,strong)NSMutableArray* offsetArray;
@property(nonatomic,strong)NSMutableArray* stackViewArray;

@end

@implementation OFStackView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUP];
    }
    return self;
}
-(void)setUP{
    _offsetArray = [[NSMutableArray alloc] initWithCapacity:0];
    _stackViewArray = [[NSMutableArray alloc] initWithCapacity:0];
    _stackViewNumber = 0;
}
-(BOOL)viewHiddenAtIndex:(NSInteger)index{
    if (index >= _stackViewArray.count) {
        return YES;
    }
    UIView* container = [_stackViewArray objectAtIndex:index];
    return container.hidden;
}
-(void)reloadData{
    
    for (UIView* subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    [_stackViewArray removeAllObjects];
    
    _stackViewNumber = [_dataSource numberOfStackView:self];
    
    [_offsetArray removeAllObjects];
    
    for (NSInteger index = 0; index < _stackViewNumber; index ++) {
        CGFloat offset = [_dataSource stackView:self viewOffSetAtIndex:index];
        [_offsetArray addObject:@(offset)];
    }
    
    for (NSInteger index = 0; index < _stackViewNumber; index ++) {
        UIView* container = [[UIView alloc] init];
        CGFloat offset = [[_offsetArray objectAtIndex:index] floatValue];
        CGFloat containerWidth = self.width - offset;
        CGFloat containerStartX = self.width;
        if (index == 0) {
            containerStartX = 0;
            container.hidden = NO;
        }else{
            container.hidden = YES;
        }
        container.frame = CGRectMake(containerStartX, 0, containerWidth, self.height);
        [self addSubview:container];
        
        [_stackViewArray addObject:container];
        
        UIView* customView = [_dataSource stackView:self customViewAtIndex:index withContainerView:container];
        [container addSubview:customView];
        [container sendSubviewToBack:customView];

        if (index > 0) {
            CAGradientLayer *shadow = [[CAGradientLayer alloc] init];
            shadow.bounds = CGRectMake(-5, 0, 5, container.height * 2);
            shadow.startPoint = CGPointMake(0, 0);
            shadow.endPoint = CGPointMake(1.0,0);
            CGColorRef darkColor  = (CGColorRef)CFRetain([UIColor colorWithWhite:0.0f alpha:0.05f].CGColor);
            CGColorRef lightColor = (CGColorRef)CFRetain([UIColor clearColor].CGColor);
            shadow.colors = [NSArray arrayWithObjects:
                             (__bridge id)lightColor,
                             darkColor,
                             
                             nil];
            
            CFRelease(darkColor);
            CFRelease(lightColor);
            [container.layer addSublayer:shadow];
            container.layer.shadowOpacity = 0;
            
            [self addPanGestureRecognizer:container];
        }
        
    
    }

    
}
-(void)resetTablePositionFromIndex:(NSInteger)index{
    if (index >= _stackViewArray.count
        || index <= 0) {
        return;
    }
    
    for (NSInteger i = index; i < _stackViewArray.count; i++) {
        UIView* container = [_stackViewArray objectAtIndex:i];
        container.left = self.width;
        container.hidden = YES;
    }
    
}

- (void)hideStackViewFromIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(void))completion{

    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            [self resetTablePositionFromIndex:index];
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    }else{
         [self resetTablePositionFromIndex:index];
        if (completion) {
            completion();
        }
    }
}
-(void)showStackViewAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(void))completion{
    CGFloat offset = [[_offsetArray objectAtIndex:index] floatValue];
    UIView* container = [_stackViewArray objectAtIndex:index];
    container.hidden = NO;
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            container.left = offset;
        }completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    }else{
        container.left = offset;
        if (completion) {
            completion();
        }
    }

}

#pragma mark - pangesture

- (void)addPanGestureRecognizer:(UIView*)targetView {
    if ([targetView.gestureRecognizers count] == 0) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragTableView:)];
        [targetView addGestureRecognizer:panGestureRecognizer];
    }
}
- (void)removePanGestureRecognizer:(UIView*)targetView {
    [targetView removeGestureRecognizer:[targetView.gestureRecognizers lastObject]];
}

- (void)dragTableView:(UIPanGestureRecognizer *)panGestureRecognizer {
    UIView *draggedView = panGestureRecognizer.view;
    if (![_stackViewArray containsObject:draggedView]) {
        return;
    }
    NSInteger currentViewIndex = [_stackViewArray indexOfObject:draggedView];
    
    CGFloat draggedViewDefaultXCoordinate = [[_offsetArray objectAtIndex:currentViewIndex] floatValue];

    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateEnded: {
            if (currentViewIndex > 0) {
                if ([panGestureRecognizer velocityInView:draggedView].x > 500.0
                    || draggedView.frame.origin.x > draggedView.bounds.size.width / 3 * 2) {
                    [self hideStackViewFromIndex:currentViewIndex animated:YES completion:nil];
                }else{
                    [UIView animateWithDuration:0.3 animations:^{
                        for (NSInteger i = currentViewIndex; i < _stackViewArray.count; i++) {
                            UIView* container = [_stackViewArray objectAtIndex:i];
                            if (!container.hidden) {
                                container.left = [[_offsetArray objectAtIndex:i] floatValue];
                            }
                        }
                    }];

                }
            }
        } break;
        default: {

            for (NSInteger i = currentViewIndex; i < _stackViewArray.count; i++) {
                UIView* container = [_stackViewArray objectAtIndex:i];
                CGFloat newXCenter = MAX(container.center.x + [panGestureRecognizer translationInView:draggedView].x, draggedViewDefaultXCoordinate + draggedView.frame.size.width / 2);
                if (!container.hidden) {
                    [container setCenter:CGPointMake(newXCenter, container.center.y)];
                }
                
            }
            [panGestureRecognizer setTranslation:CGPointZero inView:draggedView];
        } break;
    }
}

@end
