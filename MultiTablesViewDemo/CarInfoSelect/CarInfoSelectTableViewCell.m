//
//  CarInfoSelectTableViewCell.m
//  MultiTablesViewDemo
//
//  Created by 吴晓明 on 15/7/8.
//  Copyright (c) 2015年 吴晓明. All rights reserved.
//

#import "CarInfoSelectTableViewCell.h"
#import "UIView+Oxygen.h"
#import "UIImageView+WebCache.h"

@interface CarInfoSelectTableViewCell ()
@property(nonatomic,strong)UIImageView* carLogoView;
@property(nonatomic,strong)UIImageView* selectedTipView;
@property(nonatomic,strong)UILabel* itemDescriptionLabel;

@end

@implementation CarInfoSelectTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUP];
    }
    return self;
    
}
-(void)setUP{
    _carLogoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_carLogoView];
    
    _selectedTipView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_selectedTipView];
    
    _itemDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _itemDescriptionLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:_itemDescriptionLabel];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    _selectedTipView.hidden = !selected;
    if (selected) {
        _itemDescriptionLabel.textColor = THEME_TINT_COLOR;
    }else{
        _itemDescriptionLabel.textColor = [UIColor blackColor];
    }
}

-(void)setItemInfo:(GridItem *)itemInfo{
    _itemInfo = itemInfo;
    _itemDescriptionLabel.text = itemInfo.itemDescription;
    
    if ([itemInfo.imageUrl hasPrefix:@"http"]) {
        [_carLogoView sd_setImageWithURL:[NSURL URLWithString:itemInfo.imageUrl] placeholderImage:nil];
    }else{
        _carLogoView.image = [UIImage imageNamed:itemInfo.imageUrl];
    }
}

-(void)layoutSubviews{

    [super layoutSubviews];

    if (_itemInfo.imageUrl) {
        CGFloat imageWidth = 44;
        CGFloat imageHeight = imageWidth;
        CGFloat imageY = (self.contentView.height - imageHeight) / 2;
        CGFloat imageX = 10;
        _carLogoView.frame = CGRectMake(imageX, imageY, imageWidth, imageHeight);
        
    }else{
        _carLogoView.frame = CGRectZero;
    }

    CGFloat tipViewMargin = 4;
    CGFloat tipViewHeight = 6;
    CGFloat tipViewWidth = tipViewHeight;
    _selectedTipView.frame = CGRectMake(_carLogoView.right + tipViewMargin, (self.contentView.height - tipViewHeight) / 2, tipViewWidth, tipViewHeight);
    _selectedTipView.layer.cornerRadius = tipViewHeight / 2;
    _selectedTipView.backgroundColor = THEME_TINT_COLOR;
    _selectedTipView.clipsToBounds = YES;
    
    _itemDescriptionLabel.frame = CGRectMake(_selectedTipView.right + tipViewMargin, 0, self.contentView.width - _selectedTipView.right - tipViewMargin, self.contentView.height);

}


@end
