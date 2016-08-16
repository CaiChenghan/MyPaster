//
//  MyPaster.h
//  MyPaster
//
//  Created by 蔡成汉 on 16/8/11.
//  Copyright © 2016年 蔡成汉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPaster : UIView

/**
 *  原始图片
 */
@property (nonatomic , strong) UIImage *originImage;

/**
 *  贴花后生成的图片
 */
@property (nonatomic , readonly) UIImage *pasterImage;

/**
 *  删除按钮图片
 */
@property (nonatomic , strong) UIImage *deleteIcon;

/**
 *  尺寸控制按钮图片
 */
@property (nonatomic , strong) UIImage *sizeIcon;

/**
 *  旋转按钮图片
 */
@property (nonatomic , strong) UIImage *rotateIcon;

/**
 *  贴花尺寸 -- 默认为120x120：即初始化出的贴花尺寸；非方形图片会等比缩放。
 */
@property (nonatomic , assign) CGSize pasterSize;

/**
 *  按钮尺寸 -- 默认为30x30
 */
@property (nonatomic , assign) CGSize iconSize;

/**
 *  添加贴花
 *
 *  @param image 贴花
 */
-(void)addPaster:(UIImage *)image;

/**
 *  添加贴花
 *
 *  @param image 贴花
 *  @param size  贴花尺寸，贴花以此尺寸添加
 */
-(void)addPaster:(UIImage *)image size:(CGSize)size;

@end

