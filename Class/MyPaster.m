//
//  MyPaster.m
//  MyPaster
//
//  Created by 蔡成汉 on 16/8/11.
//  Copyright © 2016年 蔡成汉. All rights reserved.
//

#import "MyPaster.h"
#import "MyImagePasterItem.h"
#import "MyTextPasterItem.h"

////////////////////////////////////////////////////////////////////////////////
//////////////////////////////                 /////////////////////////////////
//////////////////////////////     MyPaster    /////////////////////////////////
//////////////////////////////                 /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface MyPaster ()

/**
 *  底层内容图
 */
@property (nonatomic , strong) UIImageView *contentImageView;

/**
 *  当前选中的PasterItem
 */
@property (nonatomic , strong) MyPasterItem *currentSelectPasterItem;

@end

@implementation MyPaster

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = YES;
        _iconSize = CGSizeMake(30.0, 30.0);
        [self initialView];
    }
    return self;
}

/**
 *  初始化view
 */
-(void)initialView
{
    //底层内容图
    _contentImageView = [[UIImageView alloc]init];
    _contentImageView.userInteractionEnabled = YES;
    _contentImageView.clipsToBounds = YES;
    [self addSubview:_contentImageView];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGes:)];
    [self addGestureRecognizer:tapGes];
}

/**
 *  页面点击 -- 取消选中状态
 *
 *  @param ges 点击手势
 */
-(void)tapGes:(UITapGestureRecognizer *)ges
{
    CGPoint gesPoint = [ges locationInView:self];
    CGRect contentRect = _contentImageView.frame;
    if (CGRectContainsPoint(contentRect, gesPoint))
    {
        //在目标之内 -- KVC
        CGRect itemRect = [_currentSelectPasterItem convertRect:_currentSelectPasterItem.bounds toView:self];
        if (!CGRectContainsPoint(itemRect, gesPoint))
        {
            [_currentSelectPasterItem setValue:[NSNumber numberWithBool:NO] forKey:@"isSelect"];
            _currentSelectPasterItem = nil;
        }
    }
    else
    {
        //在目标之外 -- KVC
        [_currentSelectPasterItem setValue:[NSNumber numberWithBool:NO] forKey:@"isSelect"];
        _currentSelectPasterItem = nil;
    }
}

/**
 *  set方法
 *
 *  @param originImage 原始图片
 */
-(void)setOriginImage:(UIImage *)originImage
{
    _originImage = originImage;
    _contentImageView.image = originImage;
    [self setNeedsLayout];
}

/**
 *  set方法，设置删除按钮图片
 *
 *  @param deleteIcon 删除按钮图片
 */
-(void)setDeleteIcon:(UIImage *)deleteIcon
{
    _deleteIcon = deleteIcon;
    [_contentImageView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MyPasterItem class]])
        {
            MyPasterItem *tpItem = obj;
            tpItem.deleteIcon = _deleteIcon;
        }
    }];
}

/**
 *  set方法，设置尺寸控制按钮图片
 *
 *  @param sizeIcon 尺寸控制按钮图片
 */
-(void)setSizeIcon:(UIImage *)sizeIcon
{
    _sizeIcon = sizeIcon;
    [_contentImageView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MyPasterItem class]])
        {
            MyPasterItem *tpItem = obj;
            tpItem.sizeIcon = _sizeIcon;
        }
    }];
}

/**
 *  set方法，设置镜像按钮图片
 *
 *  @param rotateIcon 镜像按钮图片
 */
-(void)setRotateIcon:(UIImage *)rotateIcon
{
    _rotateIcon = rotateIcon;
    [_contentImageView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MyPasterItem class]])
        {
            MyPasterItem *tpItem = obj;
            tpItem.rotateIcon = _rotateIcon;
        }
    }];
}


/**
 *  set方法，设置按钮尺寸
 *
 *  @param iconSize 按钮尺寸
 */
-(void)setIconSize:(CGSize)iconSize
{
    if (iconSize.width != 0 && iconSize.height != 0)
    {
        _iconSize = iconSize;
        [_contentImageView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[MyPasterItem class]])
            {
                MyPasterItem *tpItem = obj;
                //KVC
                [tpItem setValue:[NSValue valueWithCGSize:_iconSize] forKey:@"iconSize"];
            }
        }];
    }
}

/**
 *  getPasterImage
 *
 *  @return pasterImage
 */
-(UIImage *)getPasterImage
{
    return [self pasterImage];
}

/**
 *  get方法
 *
 *  @return pasterImage
 */
-(UIImage *)pasterImage
{
    //取消选中
    self.currentSelectPasterItem = nil;
    return [self getImageFromView:_contentImageView];
}

/**
 *  set方法
 *
 *  @param currentPaster currentPaster
 */
-(void)setCurrentPaster:(Paster *)currentPaster
{
    if (_currentSelectPasterItem != nil)
    {
        _currentSelectPasterItem.paster = currentPaster;
    }
}


/**
 *  get方法
 *
 *  @return currentPaster
 */
-(Paster *)currentPaster
{
    if (_currentSelectPasterItem != nil)
    {
        return _currentSelectPasterItem.paster;
    }
    else
    {
        return nil;
    }
}


/**
 *  添加贴花 -- 位置随机
 *
 *  @param paster Paster
 */
-(void)addPaster:(Paster *)paster
{
    if ([paster isKindOfClass:[ImagePaster class]])
    {
        ImagePaster *imagePaster = (ImagePaster *)paster;
        [self addImagePaster:imagePaster];
    }
    else if ([paster isKindOfClass:[TextPaster class]])
    {
        TextPaster *textPaster = (TextPaster *)paster;
        [self addTextPaster:textPaster];
    }
}

/**
 *  添加贴花 -- 图片类型
 *
 *  @param paster 贴花
 */
-(void)addImagePaster:(ImagePaster *)paster
{
    //创建一个pasterItem对象，并且添加到底层图片上
    if (_contentImageView.image != nil && paster.image != nil)
    {
        //随机贴纸位置
        CGSize imageSize = [self getPasterImageSize:paster];
        CGPoint tpPoint = [self getPasterImagePoint:imageSize];
        MyImagePasterItem *imagePasterItem = [[MyImagePasterItem alloc]initWithFrame:CGRectMake(tpPoint.x, tpPoint.y, imageSize.width, imageSize.height) paster:self];
        imagePasterItem.paster = paster;
        imagePasterItem.deleteIcon = _deleteIcon;
        imagePasterItem.sizeIcon = _sizeIcon;
        imagePasterItem.rotateIcon = _rotateIcon;
        [imagePasterItem setValue:[NSValue valueWithCGSize:_iconSize] forKey:@"iconSize"];
        [_contentImageView addSubview:imagePasterItem];
        
        __block MyPaster *blockPaster = self;
        [imagePasterItem addTouchObj:^(MyPasterItem *pasterItem) {
            //delegate
            if ([blockPaster.delegate respondsToSelector:@selector(myPaster:pasterIsSelect:)])
            {
                [blockPaster.delegate myPaster:blockPaster pasterIsSelect:_currentSelectPasterItem.paster];
            }
        }];
        self.currentSelectPasterItem = imagePasterItem;
    }
}

/**
 *  添加贴花 -- 文字类型
 *
 *  @param paster 贴花
 */
-(void)addTextPaster:(TextPaster *)paster
{
    if (_contentImageView.image != nil)
    {
        //随机贴纸位置
        CGPoint tpPoint = [self getPasterImagePoint:paster.size];
        MyTextPasterItem *textPasterItem = [[MyTextPasterItem alloc]initWithFrame:CGRectMake(tpPoint.x, tpPoint.y, paster.size.width, paster.size.height) paster:self];
        textPasterItem.paster = paster;
        textPasterItem.deleteIcon = _deleteIcon;
        textPasterItem.sizeIcon = _sizeIcon;
        textPasterItem.rotateIcon = _rotateIcon;
        [textPasterItem setValue:[NSValue valueWithCGSize:_iconSize] forKey:@"iconSize"];
        [_contentImageView addSubview:textPasterItem];
        
        __block MyPaster *blockPaster = self;
        [textPasterItem addTouchObj:^(MyPasterItem *pasterItem) {
            //delegate
            if ([blockPaster.delegate respondsToSelector:@selector(myPaster:pasterIsSelect:)])
            {
                [blockPaster.delegate myPaster:blockPaster pasterIsSelect:_currentSelectPasterItem.paster];
            }
        }];
        self.currentSelectPasterItem = textPasterItem;
    }
}


/**
 *  set方法，设置当前选中的item
 *
 *  @param currentSelectPasterItem 当前选中的item
 */
-(void)setCurrentSelectPasterItem:(MyPasterItem *)currentSelectPasterItem
{
    _currentSelectPasterItem = currentSelectPasterItem;
    if (_currentSelectPasterItem == nil)
    {
        //没有选中行
        [_contentImageView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[MyPasterItem class]])
            {
                MyPasterItem *tpPasterItem = obj;
                [tpPasterItem setValue:[NSNumber numberWithBool:NO] forKey:@"isSelect"];
            }
        }];
    }
    else
    {
        //有选中行
        [_contentImageView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[MyPasterItem class]])
            {
                MyPasterItem *tpPasterItem = obj;
                if (tpPasterItem == currentSelectPasterItem)
                {
                    //发现自己，则将当前选中item，则通过KVC将item设置为选中状态
                    [tpPasterItem setValue:[NSNumber numberWithBool:YES] forKey:@"isSelect"];
                }
                else
                {
                    //没有发现自己，则将当前选中item，则通过KVC将item设置为未选中状态
                    [tpPasterItem setValue:[NSNumber numberWithBool:NO] forKey:@"isSelect"];
                }
            }
        }];
    }
}

/**
 *  获取图片展示尺寸
 *
 *  @param image 原始图片
 *
 *  @return 转换后的尺寸
 */
-(CGSize)getImageSize:(UIImage *)image
{
    CGSize size = CGSizeZero;
    if (image != nil)
    {
        CGFloat imageRate = image.size.width/image.size.height;
        CGFloat selfRate = self.bounds.size.width/self.bounds.size.height;
        if (imageRate > selfRate)
        {
            //图片顶左右边
            size.width = self.bounds.size.width;
            size.height = image.size.height/image.size.width*self.bounds.size.width;
        }
        else
        {
            //图片顶上下边
            size.width = image.size.width/image.size.height*self.bounds.size.height;
            size.height = self.bounds.size.height;
        }
    }
    return size;
}

/**
 *  获取贴花展示尺寸
 *
 *  @param paster 贴花
 *
 *  @return 贴花尺寸
 */
-(CGSize)getPasterImageSize:(ImagePaster *)paster
{
    CGSize size = CGSizeZero;
    if (paster.image != nil)
    {
        if (paster.image.size.width > paster.image.size.height)
        {
            //宽大于高
            size.width = paster.size.width;
            size.height = paster.image.size.height/paster.image.size.width*paster.size.width;
        }
        else
        {
            //宽不大于
            size.width = paster.image.size.width/paster.image.size.height*paster.size.height;
            size.height = paster.size.height;
        }
    }
    return size;
}

/**
 *  获取贴纸起点
 *
 *  @param size 贴纸尺寸
 *
 *  @return 贴纸起点
 */
-(CGPoint)getPasterImagePoint:(CGSize)size
{
    CGPoint tpPoint = CGPointZero;
    if (_contentImageView.bounds.size.width - 40.0 > size.width)
    {
        tpPoint.x = (arc4random()% (int)(_contentImageView.bounds.size.width - 20.0 - size.width)) + 20;
    }
    else
    {
        tpPoint.x = _contentImageView.bounds.size.width/2.0 - size.width/2.0;
    }
    if (_contentImageView.bounds.size.height - 40.0 > size.height)
    {
        tpPoint.y = (arc4random()% (int)(_contentImageView.bounds.size.height - 20.0 - size.height)) + 20;
    }
    else
    {
        tpPoint.y = _contentImageView.bounds.size.height/2.0 - size.height/2.0;
    }
    return tpPoint;
}

/**
 *  视图转image
 *
 *  @param view 目标视图
 *
 *  @return 转换后的image
 */
-(UIImage *)getImageFromView:(UIView *)view
{
    if (view.bounds.size.width == 0 || view.bounds.size.height == 0)
    {
        return nil;
    }
    else
    {
        CGSize orgSize = view.bounds.size;
        UIGraphicsBeginImageContextWithOptions(orgSize, YES, [UIScreen mainScreen].scale);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (_contentImageView.image != nil)
    {
        CGSize contentImageSize = [self getImageSize:_contentImageView.image];
        _contentImageView.frame = CGRectMake(0, 0, contentImageSize.width, contentImageSize.height);
    }
    else
    {
        _contentImageView.frame = CGRectZero;
    }
    _contentImageView.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


////////////////////////////////////////////////////////////////////////////////
//////////////////////////////                 /////////////////////////////////
//////////////////////////////      Paster     /////////////////////////////////
//////////////////////////////                 /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface Paster ()

@end

@implementation Paster


-(id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

@end


////////////////////////////////////////////////////////////////////////////////
//////////////////////////////                 /////////////////////////////////
//////////////////////////////   ImagePaster   /////////////////////////////////
//////////////////////////////                 /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface ImagePaster ()

@end

@implementation ImagePaster

-(id)init
{
    self = [super init];
    if (self)
    {
        self.size = CGSizeMake(120, 120);
    }
    return self;
}

@end

////////////////////////////////////////////////////////////////////////////////
//////////////////////////////                 /////////////////////////////////
//////////////////////////////    TextPaster   /////////////////////////////////
//////////////////////////////                 /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface TextPaster ()

@end

@implementation TextPaster

-(id)init
{
    self = [super init];
    if (self)
    {
        self.size = CGSizeMake(160, 80);
        self.font = [UIFont systemFontOfSize:32];
        self.textColor = [UIColor whiteColor];
    }
    return self;
}

@end
