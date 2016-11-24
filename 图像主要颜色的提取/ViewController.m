//
//  ViewController.m
//  图像主要颜色的提取
//
//  Created by 王奥东 on 16/11/23.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+ADOMainColor.h"

@implementation ViewController{
    
    IBOutlet UIImageView *_menuImgView;
    IBOutlet UISegmentedControl *_menuSegmented;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _menuImgView.layer.borderWidth = 2;
    UIImage *img = [UIImage imageNamed:@"1"];
    _menuImgView.image = img;
    
    UIColor *most = [img mostColor];
    self.view.backgroundColor = most;
}

- (IBAction)selectorImage:(id)sender {
    
    NSInteger select = _menuSegmented.selectedSegmentIndex;
    
    UIImage *img;
    if (select == 0) {
        img = [UIImage imageNamed:@"1"];
        
    }else if (select == 1) {
        img = [UIImage imageNamed:@"2"];
       
    }else {
        img = [UIImage imageNamed:@"3"];
    }
    
    _menuImgView.image = img;
    UIColor *most = [img mostColor];
    self.view.backgroundColor = most;
//

}


@end
