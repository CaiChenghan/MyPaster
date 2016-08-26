//
//  MyTextPasterItem.m
//  MyPaster
//
//  Created by 蔡成汉 on 16/8/25.
//  Copyright © 2016年 蔡成汉. All rights reserved.
//

#import "MyTextPasterItem.h"

@interface MyTextPasterItem ()

/**
 *  label
 */
@property (nonatomic , strong) UILabel *label;

/**
 *  内容缩放页
 */
@property (nonatomic , strong) UIImageView *textView;

@end

@implementation MyTextPasterItem

-(id)initWithFrame:(CGRect)frame paster:(MyPaster *)paster
{
    self = [super initWithFrame:frame paster:paster];
    if (self)
    {
        [self initialMyTextPasterItemView];
    }
    return self;
}

-(void)initialMyTextPasterItemView
{
    _label = [[UILabel alloc]init];
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.adjustsFontSizeToFitWidth = YES;
    _label.numberOfLines = 0;
    [self.contentView addSubview:_label];
}

-(void)setPaster:(Paster *)paster
{
    [super setPaster:paster];
    if ([paster isKindOfClass:[TextPaster class]])
    {
        _label.text = ((TextPaster *)paster).text;
        CGFloat size = (((TextPaster *)paster).font.pointSize > 250)?250:((TextPaster *)paster).font.pointSize;
        _label.font = [UIFont fontWithName:((TextPaster *)paster).font.fontName size:size];
        _label.textColor = ((TextPaster *)paster).textColor;
        [self displayLabel];
    }
}

-(void)displayLabel
{
    _label.frame = self.contentView.bounds;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _label.center = CGPointMake(self.contentView.bounds.size.width/2.0, self.contentView.bounds.size.height/2.0);
    CGFloat zoom = self.contentView.bounds.size.height/self.paster.size.height;
    CATransform3D transform = CATransform3DMakeScale(zoom, zoom, 1.0);
    _label.layer.transform = transform;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
