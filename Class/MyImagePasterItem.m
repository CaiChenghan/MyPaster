//
//  MyImagePasterItem.m
//  MyPaster
//
//  Created by 蔡成汉 on 16/8/25.
//  Copyright © 2016年 蔡成汉. All rights reserved.
//

#import "MyImagePasterItem.h"

@interface MyImagePasterItem ()

@property (nonatomic , strong) UIImageView *imageView;

@end

@implementation MyImagePasterItem

-(id)initWithFrame:(CGRect)frame paster:(MyPaster *)paster
{
    self = [super initWithFrame:frame paster:paster];
    if (self)
    {
        [self initialMyImagePasterItemView];
    }
    return self;
}

-(void)initialMyImagePasterItemView
{
    _imageView = [[UIImageView alloc]init];
    _imageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_imageView];
}

-(void)setPaster:(Paster *)paster
{
    [super setPaster:paster];
    if ([paster isKindOfClass:[ImagePaster class]])
    {
        _imageView.image = ((ImagePaster *)paster).image;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
