//
//  MyUIPageControl.m
//  GameVideo
//
//  Created by 吴晓明 on 14/10/24.
//  Copyright (c) 2014年 吴晓明. All rights reserved.
//

#import "MyUIPageControl.h"

#define kButtonTag 150

#define kPointWidth 8
#define kPointHeight 8
#define kPointDistance 6

#define SELECTED_COLOR      [UIColor colorWithWhite:0 alpha:0.4]
#define NORMAL_COLOR        [UIColor colorWithWhite:0 alpha:0.2]

@interface MyUIPageControl(private)
-(void)updateStateImage;
@end


@implementation MyUIPageControl
@synthesize hidesForSinglePage;
@synthesize imagePageStateNormal;
@synthesize imagePageStateHightlighted;
@synthesize currentPage;
@synthesize numberOfPages;

- (id)initWithCenter:(CGPoint)center
{
    self = [super init];
    if (self) {
        m_center = center;
        self.backgroundColor = [UIColor clearColor];
        
        hidesForSinglePage = YES;
        numberOfPages = 0;
        currentPage = 0;
    }
    return self;
}

- (void) setImagePageStateNormal:(UIImage *)image
{
    imagePageStateNormal = image;
}

- (void) setImagePageStateHightlighted:(UIImage *)image
{
    imagePageStateHightlighted = image;
}

-(void) setNumberOfPages:(NSUInteger)m_numberOfPages {
    
    numberOfPages = m_numberOfPages;
    
    if (hidesForSinglePage && numberOfPages==1) {
        self.hidden = YES;
    }else{
        self.hidden = NO;
    }
    
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
    
    float selfWidth = numberOfPages*kPointWidth+(numberOfPages-1)*kPointDistance;
    self.frame = CGRectMake(m_center.x - selfWidth/2, m_center.y-kPointHeight/2, selfWidth, kPointHeight);
    
    for (int i=0; i<numberOfPages; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((kPointWidth+kPointDistance)*i, 0, kPointWidth, kPointHeight)];
        button.backgroundColor = [UIColor clearColor];
        [button setImage:imagePageStateNormal forState:UIControlStateNormal];
        [button setImage:imagePageStateHightlighted forState:UIControlStateSelected];
        button.tag = kButtonTag+i;
        button.userInteractionEnabled = NO;
        button.layer.cornerRadius = kPointWidth / 2;
        [self addSubview:button];
    }
    
    [self updateStateImage];
}

-(void)setCurrentPage:(NSUInteger)m_currentPage {
    if (m_currentPage>=numberOfPages) {
        return;
    }
    currentPage = m_currentPage;
    
    [self updateStateImage];
}

-(void)updateStateImage {
    for (int i=0; i<numberOfPages; i++) {
        UIButton *button = (UIButton *)[self viewWithTag:kButtonTag+i];
        if (currentPage==i) {
            button.selected = YES;
           
            if (!imagePageStateHightlighted) {
                 button.backgroundColor = SELECTED_COLOR;
            }
        }else{
            button.selected = NO;
            if (!imagePageStateNormal) {
                button.backgroundColor = NORMAL_COLOR;
            }
            
        }
    }
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount {
    return CGSizeMake(pageCount*kPointWidth+(pageCount-1)*kPointDistance, kPointHeight);
}
@end
