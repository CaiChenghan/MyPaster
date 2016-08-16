//
//  MyPaster.m
//  MyPaster
//
//  Created by 蔡成汉 on 16/8/11.
//  Copyright © 2016年 蔡成汉. All rights reserved.
//

#import "MyPaster.h"

@interface MyPasterItem : UIView

/**
 *  内容图片
 */
@property (nonatomic , strong) UIImage *image;

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
 *  重写init方法
 *
 *  @param frame  frame
 *  @param paster paster
 *
 *  @return 实例化后的pasterItem
 */
-(id)initWithFrame:(CGRect)frame paster:(MyPaster *)paster;

@end


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
        _pasterSize = CGSizeMake(120, 120);
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
 *  set方法，设置paster初始大小
 *
 *  @param pasterSize pasterSize
 */
-(void)setPasterSize:(CGSize)pasterSize
{
    if (pasterSize.width != 0 && pasterSize.height != 0)
    {
        _pasterSize = pasterSize;
    }
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
 *  添加贴花
 *
 *  @param image 贴花
 */
-(void)addPaster:(UIImage *)image
{
    if (_contentImageView.image != nil && image != nil)
    {
        CGSize pasterSize = [self getPasterImageSize:image];
        [self addPaster:image size:pasterSize];
    }
}

/**
 *  添加贴花
 *
 *  @param image 贴花
 *  @param size  贴花尺寸
 */
-(void)addPaster:(UIImage *)image size:(CGSize)size
{
    //创建一个pasterItem对象，并且添加到底层图片上
    if (_contentImageView.image != nil && image != nil)
    {
        //随机贴纸位置
        CGPoint tpPoint = [self getPasterImagePoint:size];
        MyPasterItem *pasterItem = [[MyPasterItem alloc]initWithFrame:CGRectMake(tpPoint.x, tpPoint.y, size.width, size.height) paster:self];
        pasterItem.image = image;
        pasterItem.deleteIcon = _deleteIcon;
        pasterItem.sizeIcon = _sizeIcon;
        pasterItem.rotateIcon = _rotateIcon;
        [pasterItem setValue:[NSValue valueWithCGSize:_iconSize] forKey:@"iconSize"];
        [_contentImageView addSubview:pasterItem];
        self.currentSelectPasterItem = pasterItem;
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
 *  @param image 贴花
 *
 *  @return 贴花尺寸
 */
-(CGSize)getPasterImageSize:(UIImage *)image
{
    CGSize size = CGSizeZero;
    if (image != nil)
    {
        if (image.size.width > image.size.height)
        {
            //宽大于高
            size.width = _pasterSize.width;
            size.height = image.size.height/image.size.width*_pasterSize.width;
        }
        else
        {
            //宽不大于
            size.width = image.size.width/image.size.height*_pasterSize.height;
            size.height = _pasterSize.height;
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
    NSLog(@"%@-%@",NSStringFromCGRect(_contentImageView.frame),NSStringFromCGPoint(tpPoint));
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


@interface MyPasterItem ()
{
    /**
     *  起始尺寸
     */
    CGSize originSize;
    
    /**
     *  缩放最小尺寸
     */
    CGSize minSize;
    
    /**
     *  touch手势起点
     */
    CGPoint startTouchPoint;
    
    CGFloat deletaAngle;
    
    CGPoint prevPoint;
    
    /**
     *  开始缩放时的尺寸
     */
    CGSize startScaleSize;
    
    /**
     *  是否已经旋转
     */
    BOOL haveTransform;
}

/**
 *  贴花imageView
 */
@property (nonatomic , strong) UIImageView *pasterImageView;

/**
 *  删除按钮
 */
@property (nonatomic , strong) UIImageView *deleteView;

/**
 *  尺寸控制按钮
 */
@property (nonatomic , strong) UIImageView *sizeView;

/**
 *  镜像按钮
 */
@property (nonatomic , strong) UIImageView *rotateView;

/**
 *  是否为选中 -- 默认为NO
 */
@property (nonatomic , assign) BOOL isSelect;

/**
 *  paster
 */
@property (nonatomic , strong) MyPaster *paster;

/**
 *  按钮尺寸
 */
@property (nonatomic , assign) CGSize iconSize;

@end

@implementation MyPasterItem

/**
 *  重写init方法
 *
 *  @param frame  frame
 *  @param paster paster
 *
 *  @return 实例化后的pasterItem
 */
-(id)initWithFrame:(CGRect)frame paster:(MyPaster *)paster
{
    _paster = paster;
    return [self initWithFrame:frame];
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = YES;
        _iconSize = CGSizeMake(30.0, 30.0);
        originSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
        minSize = CGSizeMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
        deletaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,self.frame.origin.x+self.frame.size.width - self.center.x) ;
        [self initialView];
    }
    return self;
}

-(void)initialView
{
    //贴花
    _pasterImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    _pasterImageView.layer.borderWidth = 1.0;
    _pasterImageView.layer.borderColor = [[UIColor clearColor]CGColor];
    _pasterImageView.layer.shouldRasterize = YES;
    [self addSubview:_pasterImageView];
    
    //删除控制
    _deleteView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _iconSize.width, _iconSize.height)];
    _deleteView.backgroundColor = [UIColor clearColor];
    _deleteView.userInteractionEnabled = YES;
    _deleteView.image = _deleteIcon;
    [self addSubview:_deleteView];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGes:)];
    [_deleteView addGestureRecognizer:tapGes];
    
    //缩放+旋转控制
    _sizeView = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.height - _iconSize.height, self.bounds.size.width - _iconSize.width, _iconSize.width, _iconSize.height)];
    _sizeView.backgroundColor = [UIColor clearColor];
    _sizeView.image = _sizeIcon;
    _sizeView.userInteractionEnabled = YES;
    [self addSubview:_sizeView];
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGes:)];
    [_sizeView addGestureRecognizer:panGes];
    
    //镜像/Y轴对称
    _rotateView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - _iconSize.height, _iconSize.width, _iconSize.height)];
    _rotateView.backgroundColor = [UIColor clearColor];
    _rotateView.image = _rotateIcon;
    _rotateView.userInteractionEnabled = YES;
    [self addSubview:_rotateView];
    UITapGestureRecognizer *rotateTapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(rotateTapGes:)];
    [_rotateView addGestureRecognizer:rotateTapGes];
    
    //旋转手势
    UIRotationGestureRecognizer *rotationGes = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotationGes:)];
    [self addGestureRecognizer:rotationGes];
    
    UIPinchGestureRecognizer *pincheGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)] ;
    [self addGestureRecognizer:pincheGesture] ;
}

#pragma mark - 触摸手势

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.superview bringSubviewToFront:self];
    _paster.currentSelectPasterItem = self;
    startTouchPoint = [touches.anyObject locationInView:self.superview];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //判断手势是否在pan手势之上
    CGPoint touchLocation = [[touches anyObject]locationInView:self];
    if (CGRectContainsPoint(_sizeView.frame, touchLocation))
    {
        return;
    }
    
    //获取手势在父控件上的位置，并且根据手势位置更改自身位置
    CGPoint touchPoint = [[touches anyObject]locationInView:self.superview];
    [self resetFrameWithTouchPoint:touchPoint];
    startTouchPoint = touchPoint;
}


/**
 *  删除点击
 *
 *  @param ges 单击手势
 */
-(void)tapGes:(UITapGestureRecognizer *)ges
{
    [self removeFromSuperview];
}

/**
 *  缩放+旋转手势
 *
 *  @param ges 拖动手势
 */
-(void)panGes:(UIPanGestureRecognizer *)ges
{
    if (ges.state == UIGestureRecognizerStateBegan)
    {
        prevPoint = [ges locationInView:self];
        [self setNeedsLayout];
    }
    else if (ges.state == UIGestureRecognizerStateChanged)
    {
        if (self.bounds.size.width < minSize.width || self.bounds.size.height < minSize.height)
        {
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, minSize.width, minSize.height);
            prevPoint = [ges locationInView:self];
            [self setNeedsLayout];
        }
        else
        {
            CGPoint point = [ges locationInView:self];
            float wChange = 0.0;
            float hChange = 0.0;
            
            wChange = (point.x - prevPoint.x);
            float wRatioChange = (wChange/(float)self.bounds.size.width);
            
            hChange = wRatioChange * self.bounds.size.height;
            
            if (ABS(wChange) > 50.0f || ABS(hChange) > 50.0f)
            {
                prevPoint = [ges locationOfTouch:0 inView:self];
                return;
            }
            
            CGFloat finalWidth  = self.bounds.size.width + sqrtf(3.8)*wChange;
            CGFloat finalHeight = self.bounds.size.height + sqrtf(3.8)*hChange;
            
            //尺寸控制
            if (finalWidth < minSize.width)
            {
                finalWidth = minSize.width;
            }
            if (finalHeight < minSize.height)
            {
                finalHeight = minSize.height;
            }
            CGFloat maxSize = MAX(self.superview.bounds.size.width*1.3, self.superview.bounds.size.height*1.3);
            if (finalWidth > finalHeight)
            {
                //宽大于高
                if (finalHeight > maxSize)
                {
                    finalWidth = finalWidth/finalHeight*maxSize;
                    finalHeight = maxSize;
                }
            }
            else
            {
                //宽小于等于高
                if (finalWidth > maxSize)
                {
                    finalHeight = finalHeight/finalWidth*maxSize;
                    finalWidth = maxSize;
                }
            }
            
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, finalWidth, finalHeight);
            prevPoint = [ges locationOfTouch:0 inView:self] ;
            
            /* Rotation */
            float ang = atan2([ges locationInView:self.superview].y - self.center.y,[ges locationInView:self.superview].x - self.center.x) ;
            
            float angleDiff = deletaAngle - ang;
            
            self.transform = CGAffineTransformMakeRotation(-angleDiff);
            
            [self setNeedsLayout];
        }
    }
    else if (ges.state == UIGestureRecognizerStateEnded)
    {
        prevPoint = [ges locationInView:self];
        [self setNeedsLayout];
    }
}

/**
 *  镜像手势
 *
 *  @param ges 镜像手势
 */
-(void)rotateTapGes:(UITapGestureRecognizer *)ges
{
    if (ges.state == UIGestureRecognizerStateEnded)
    {
        if (haveTransform == NO)
        {
            haveTransform = YES;
            CATransform3D transform = CATransform3DMakeRotation(180.0*M_PI/180.0, 0, 1, 0);
            _pasterImageView.layer.transform = transform;
        }
        else
        {
            haveTransform = NO;
            CATransform3D transform = CATransform3DMakeRotation(0.0*M_PI/180.0, 0, -1, 0);
            _pasterImageView.layer.transform = transform;
        }
    }
}

/**
 *  旋转手势
 *
 *  @param ges 旋转手势
 */
-(void)rotationGes:(UIRotationGestureRecognizer *)ges
{
    self.transform = CGAffineTransformRotate(self.transform, ges.rotation) ;
    ges.rotation = 0 ;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchGesture
{
    if (pinchGesture.state == UIGestureRecognizerStateBegan)
    {
        startScaleSize = self.bounds.size;
    }
    else
    {
        CGFloat maxSize = MAX(self.superview.bounds.size.width*1.3, self.superview.bounds.size.height*1.3);
        CGFloat maxScale = MAX(maxSize/startScaleSize.width, maxSize/startScaleSize.height);
        if (pinchGesture.scale > maxScale)
        {
            pinchGesture.scale = maxScale;
        }
        self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, startScaleSize.width*pinchGesture.scale, startScaleSize.height*pinchGesture.scale);

    }
}


/**
 *  set方法，对pasterImageView进行赋值
 *
 *  @param image 贴花
 */
-(void)setImage:(UIImage *)image
{
    _pasterImageView.image = image;
}

-(void)setIsSelect:(BOOL)isSelect
{
    /**
     *  选中处理
     */
    _isSelect = isSelect;
    if (_isSelect == YES)
    {
        /**
         *  选中的
         */
        _pasterImageView.layer.borderColor = [[UIColor whiteColor]CGColor];
        _deleteView.hidden = NO;
        _sizeView.hidden = NO;
        _rotateView.hidden = NO;
    }
    else
    {
        /**
         *  未选中的
         */
        _pasterImageView.layer.borderColor = [[UIColor clearColor]CGColor];
        _deleteView.hidden = YES;
        _sizeView.hidden = YES;
        _rotateView.hidden = YES;
    }
}



/**
 *  set方法，设置删除按钮图片
 *
 *  @param deleteIcon 删除按钮图片
 */

-(void)setDeleteIcon:(UIImage *)deleteIcon
{
    _deleteIcon = deleteIcon;
    _deleteView.image = _deleteIcon;
}

/**
 *  set方法，设置旋转/尺寸控制按钮图片
 *
 *  @param sizeIcon 尺寸控制按钮图片
 */
-(void)setSizeIcon:(UIImage *)sizeIcon
{
    _sizeIcon = sizeIcon;
    _sizeView.image = _sizeIcon;
}

-(void)setRotateIcon:(UIImage *)rotateIcon
{
    _rotateIcon = rotateIcon;
    _rotateView.image = _rotateIcon;
}

/**
 *  set方法，设置按钮尺寸
 *
 *  @param iconSize 按钮尺寸
 */
-(void)setIconSize:(CGSize)iconSize
{
    _iconSize = iconSize;
    [self setNeedsLayout];
}

/**
 *  更改自身位置，以touch手势触摸点为依据
 *
 *  @param point 触摸点位置
 */
-(void)resetFrameWithTouchPoint:(CGPoint)point
{
    //获取新的中心点
    CGPoint newCenter = CGPointMake(self.center.x+(point.x - startTouchPoint.x), self.center.y+(point.y-startTouchPoint.y));
    
    //对newCenter进行矫正处理：不能偏移出界
    CGFloat midPointX = CGRectGetMidX(self.bounds) ;
    if (newCenter.x > self.superview.bounds.size.width + midPointX - minSize.width/2.0)
    {
        newCenter.x = self.superview.bounds.size.width + midPointX - minSize.width/2.0;
    }
    if (newCenter.x < minSize.width/2.0 - midPointX)
    {
        newCenter.x = minSize.width/2.0 - midPointX;
    }
    CGFloat midPointY = CGRectGetMidY(self.bounds);
    if (newCenter.y > self.superview.bounds.size.height + midPointY - minSize.width/2.0)
    {
        newCenter.y = self.superview.bounds.size.height + midPointY - minSize.width/2.0;
    }
    if (newCenter.y < minSize.height/2.0 - midPointY)
    {
        newCenter.y = minSize.height/2.0 - midPointY;
    }
    self.center = newCenter;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _deleteView.frame = CGRectMake(0, 0, _iconSize.width, _iconSize.height);
    _sizeView.frame = CGRectMake(self.bounds.size.width - _iconSize.width, self.bounds.size.height - _iconSize.height, _iconSize.width, _iconSize.height);
    _rotateView.frame = CGRectMake(0, self.bounds.size.height - _iconSize.height, _iconSize.width, _iconSize.height);
    _pasterImageView.frame = CGRectMake(_iconSize.width/2.0, _iconSize.height/2.0, self.bounds.size.width - _iconSize.width, self.bounds.size.height - _iconSize.height);
}

@end
