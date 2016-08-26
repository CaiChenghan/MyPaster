//
//  MyPasterItem.h
//  MyPaster
//
//  Created by 蔡成汉 on 16/8/25.
//  Copyright © 2016年 蔡成汉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyPaster.h"

@interface MyPasterItem : UIView

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
 *  内容View
 */
@property (nonatomic , strong) UIView *contentView;

/**
 *  myPaster
 */
@property (nonatomic , strong) MyPaster *myPaster;

/**
 *  paster
 */
@property (nonatomic , strong) Paster *paster;

/**
 *  重写init方法
 *
 *  @param frame  frame
 *  @param paster paster
 *
 *  @return 实例化后的pasterItem
 */
-(id)initWithFrame:(CGRect)frame paster:(MyPaster *)paster;

/**
 *  点击block
 *
 *  @param touchObj touchObj
 */
-(void)addTouchObj:(void(^)(MyPasterItem *pasterItem))touchObj;

@end
