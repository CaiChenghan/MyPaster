//
//  MyPasterViewController.m
//  MyPaster
//
//  Created by 蔡成汉 on 08/15/2016.
//  Copyright (c) 2016 蔡成汉. All rights reserved.
//

#import "MyPasterViewController.h"
#import <MyPaster/MyPaster.h>

@interface MyPasterViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>


/**
 *  myPaster
 */
@property (nonatomic , strong) MyPaster *myPaster;

@end

@implementation MyPasterViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initialNav];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _myPaster = [[MyPaster alloc]initWithFrame:CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.height - 150)];
    _myPaster.backgroundColor = [UIColor lightGrayColor];
    _myPaster.deleteIcon = [UIImage imageNamed:@"paster_delete"];
    _myPaster.sizeIcon = [UIImage imageNamed:@"paster_size"];
    _myPaster.rotateIcon = [UIImage imageNamed:@"paster_rotate"];
    [self.view addSubview:_myPaster];
    
}

-(void)initialNav
{
    self.title = @"MyPaster";
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(leftItemIsTouch)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(rightItemIsTouch)];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemIsTouch)];
    UIBarButtonItem *addItem2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(addItem2IsTouch)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addItem2,addItem,rightItem, nil];
}

-(void)leftItemIsTouch
{
    //图片输出
    [self saveImage:_myPaster.pasterImage];
}

-(void)rightItemIsTouch
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"手机相册", nil];
    [actionSheet showInView:self.view];
}

-(void)addItemIsTouch
{
    int type = arc4random()%2;
    if (type == 0)
    {
        ImagePaster *imagePaster = [[ImagePaster alloc]init];
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"paster_%d",(arc4random()%5)]];
        imagePaster.image = image;
        [_myPaster addPaster:imagePaster];
    }
    else
    {
        [_myPaster addPaster:[self createTextPaster]];
    }
}

/**
 *  更改贴花文字
 */
-(void)addItem2IsTouch
{
    if (_myPaster.currentPaster.class == [TextPaster class])
    {
        _myPaster.currentPaster = [self createTextPaster];
    }
}

-(TextPaster *)createTextPaster
{
    TextPaster *textPaster = [[TextPaster alloc]init];
    int type = arc4random()%5;
    if (type == 0)
    {
        textPaster.text = @"我爱你";
        textPaster.textColor = [UIColor redColor];
        textPaster.font = [UIFont systemFontOfSize:35];
        textPaster.backgroundImage = [UIImage imageNamed:@"my_image"];
    }
    else if (type == 1)
    {
        textPaster.text = @"我爱你我的祖国";
        textPaster.textColor = [UIColor purpleColor];
        textPaster.font = [UIFont boldSystemFontOfSize:35];
        textPaster.backgroundImage = [UIImage imageNamed:@"my_image"];
    }
    else if (type == 2)
    {
        textPaster.text = @"我爱你我的祖国，我要为你奋斗";
        textPaster.textColor = [UIColor colorWithRed:221.0/255 green:6.0/255 blue:234.0/255 alpha:1];
        textPaster.font = [UIFont systemFontOfSize:35];
        textPaster.backgroundImage = [UIImage imageNamed:@"my_image"];
    }
    else if (type == 3)
    {
        textPaster.text = @"Write the code.Change the world.";
        textPaster.textColor = [UIColor colorWithRed:91.0/255 green:69.0/255 blue:200.0/255 alpha:1];
        textPaster.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:35];
        textPaster.backgroundImage = [UIImage imageNamed:@"my_image"];
    }
    else
    {
        textPaster.text = @"abc123@从来都是我的错";
        textPaster.textColor = [UIColor colorWithRed:11.0/255 green:219.0/255 blue:65.0/255 alpha:1];
        textPaster.font = [UIFont fontWithName:@"Georgia-Italic" size:35];
    }
    return textPaster;
}


#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //相机
        [self doCamara];
    }
    else if (buttonIndex == 1)
    {
        //图库
        [self doAlbum];
    }
}

/**
 *  相机事件
 */
-(void)doCamara
{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    //如果相机不可用，则直接进入照相机的相册
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

/**
 *  图库事件
 */
-(void)doAlbum
{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//****图片库***另一个是相机目录下的相册
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

//选择照片调用的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //info字典中存有照片信息
    [self dismissViewControllerAnimated:YES completion:^{
        [self uploadImageToService:[info objectForKey:UIImagePickerControllerOriginalImage]];
    }];
}

/**
 *  图片上传
 */
-(void)uploadImageToService:(UIImage *)image
{
    _myPaster.originImage = image;
}

-(void)saveImage:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    if (error == nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已存入手机相册" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存失败" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
