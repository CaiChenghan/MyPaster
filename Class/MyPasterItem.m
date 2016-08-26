//
//  MyPasterItem.m
//  MyPaster
//
//  Created by 蔡成汉 on 16/8/25.
//  Copyright © 2016年 蔡成汉. All rights reserved.
//

#import "MyPasterItem.h"

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
    
    /**
     *  开始\结束位置
     */
    CGPoint _startTcPint;
    CGPoint _endTcPoint;
}

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
 *  按钮尺寸
 */
@property (nonatomic , assign) CGSize iconSize;

/**
 *  pasterItemTouchObj
 */
@property (nonatomic , copy) void(^pasterItemTouchObj)(MyPasterItem *pasterItem);

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
    _myPaster = paster;
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
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.layer.borderWidth = 1.0;
    _contentView.layer.borderColor = [[UIColor clearColor]CGColor];
    _contentView.layer.shouldRasterize = YES;
    _contentView.clipsToBounds = YES;
    [self addSubview:_contentView];
    
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
    
    UITapGestureRecognizer *pasterTapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pasterTapGes:)];
    [self addGestureRecognizer:pasterTapGes];
}

/**
 *  点击block
 *
 *  @param touchObj touchObj
 */
-(void)addTouchObj:(void(^)(MyPasterItem *pasterItem))touchObj
{
    self.pasterItemTouchObj = touchObj;
}

#pragma mark - 触摸手势

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.superview bringSubviewToFront:self];
    
    //KVC
    [_myPaster setValue:self forKey:@"currentSelectPasterItem"];
    startTouchPoint = [touches.anyObject locationInView:self.superview];
    _startTcPint = startTouchPoint;
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
    _endTcPoint = startTouchPoint;
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
            _contentView.layer.transform = transform;
        }
        else
        {
            haveTransform = NO;
            CATransform3D transform = CATransform3DMakeRotation(0.0*M_PI/180.0, 0, -1, 0);
            _contentView.layer.transform = transform;
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

-(void)pasterTapGes:(UITapGestureRecognizer *)ges
{
    if (CGPointEqualToPoint(_startTcPint, _endTcPoint))
    {
        return;
    }
    CGPoint touchLocation = [ges locationInView:self];
    if (CGRectContainsPoint(_deleteView.frame, touchLocation) || CGRectContainsPoint(_sizeView.frame, touchLocation) || CGRectContainsPoint(_rotateView.frame, touchLocation))
    {
        return;
    }
    if (CGRectContainsPoint(_contentView.frame, touchLocation) != YES)
    {
        return;
    }
    if (self.pasterItemTouchObj != nil)
    {
        self.pasterItemTouchObj(self);
    }
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
        _contentView.layer.borderColor = [[UIColor whiteColor]CGColor];
        _deleteView.hidden = NO;
        _sizeView.hidden = NO;
        _rotateView.hidden = NO;
    }
    else
    {
        /**
         *  未选中的
         */
        _contentView.layer.borderColor = [[UIColor clearColor]CGColor];
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

-(void)setPaster:(Paster *)paster
{
    _paster = paster;
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
    _contentView.frame = CGRectMake(_iconSize.width/2.0, _iconSize.height/2.0, self.bounds.size.width - _iconSize.width, self.bounds.size.height - _iconSize.height);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
