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
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addItem,rightItem, nil];
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
    [_myPaster addPaster:[UIImage imageNamed:[NSString stringWithFormat:@"paster_%d",(arc4random()%5)]]];
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
