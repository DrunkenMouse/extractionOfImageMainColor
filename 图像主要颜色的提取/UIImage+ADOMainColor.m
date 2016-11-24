//
//  UIImage+ADOMainColor.m
//  图像主要颜色的提取
//
//  Created by 王奥东 on 16/11/23.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "UIImage+ADOMainColor.h"

@implementation UIImage (ADOMainColor)

/**
 
    通过将图片缩小，来快速获取到图片中每个像素的RGBA值，出现最多的颜色值即为主要颜色。
    图片的缩小与颜色提取需要借助颜色空间信息CGColorSpaceRef，再配合位图上下文CGBitmapContextCreate。
    位图上下文是对颜色空间进行一些设置创建一个上下文，就相当于一个独特的画板，而后通过drawRect将图片绘制到画板中即可获取到像素信息。
    通过CGBitmapContextGetData获取到unsigned char * 类型数据data，其中即包含了像素信息。
    一个像素要占据4字节，根据RGBA的顺序，所以每个像素的值是从offset = 4 * x * y开始
    data[offset]到data[offset+3]之间，为了能够找到出现最多的颜色，可见一个像素的信息都放到一个数组NSArray中，再将数组都放到Set集合中，这里用的是NSCountedSet，存储空间需要自己设置：[NSCountedSet setWithCapacity:thumbSize.width * thumbSize.height];
    Set集合的方法objectEnumerator可以枚举NSEnumerator类型获取到集合中的所有不同对象，进而通过枚举的nextObject获取到每个对象，通过集合的[cls countForObject]获取到对象的个数，比较对象的个数即可获取到出现最多的颜色。
 
 */


-(UIColor *)mostColor {
    
    //先把图片缩小，加快计算速度，但越小结果误差可能越大
    CGSize thumbSize = CGSizeMake(50, 50);
    
    //CGColorSpaceRef 不透明颜色空间信息，用于解释获取到的颜色信息。也就是将获取到的颜色以RGB A的浮点式表达出来
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //CGBitmapContextCreate 位图上下文，第一个参数data如果为NULL则指向一个至少为bytesPerRow * height的内存块。第二个与第三个参数width/height指像素宽/像素高，也就是位图上下文的宽高,  第四个参数bitsPerComponent，每个像素的字节数等于（bitsPerComponent *组件数+ 7）/ 8 ,第五个参数bytesPerRow位图的每一行由bytesPerRow字节组成，必须是整数倍指每像素的字节数,第六个参数space，每个组件的数量像素由`space'指定，也可以指定目标颜色配置文件,第七个参数`bitmapInfo'指定位图是否应该包含 alpha通道及其如何生成，以及是否组件是浮点或整数。
    
    //colorSpace = CGColorSpaceCreateDeviceRGB(); 不透明颜色空间信息，用于解释获取到的颜色信息。也就是将获取到的颜色以RGB A的浮点式表达出来
    //每个像素的字节数等于（bitsPerComponent * 组件数(第六个参数space指定) + 7）/ 8
    //kCGImageAlphaPremultipliedLast,  包含Alpha通道，格式为RGB A
    //kCGBitmapByteOrder32Big 位图字节排序32Big
    CGContextRef context = CGBitmapContextCreate(NULL, thumbSize.width, thumbSize.height, 8, thumbSize.width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    //CGBitmapContextCreate生成的CGContextRef与CGColorSpaceRef配合使用，将图片绘制到这个上下文里获取到图片的信息。
    
    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    
    CGContextDrawImage(context, drawRect, self.CGImage);
    
    //绘制完后需要手动释放
    CGColorSpaceRelease(colorSpace);
 
    //第二步 取每个点的像素值
    //先把上线文转化为char *
    unsigned char * data = CGBitmapContextGetData(context);
    
    if (data == NULL) {
        return nil;
    }
    
    //创建NSCountedSet
    NSCountedSet *cls = [NSCountedSet setWithCapacity:thumbSize.width * thumbSize.height];
    for (int x = 0; x<thumbSize.width; x++) {
        for (int y = 0; y < thumbSize.height; y++) {
            //每一个像素是4个字节
            int offset = 4*(x*y);
            int red = data[offset];
            int green = data[offset+1];
            int blue = data[offset+2];
            int alpha = data[offset+3];
            NSArray *clr = @[@(red),@(green),@(blue),@(alpha)];
            [cls addObject:clr];
        }
    }
    CGContextRelease(context);
    //第三步 找到出现次数最多的那个颜色
    NSEnumerator *enumerator = [cls objectEnumerator];
    NSArray *curColor = nil;
    NSArray *maxColor = nil;
    NSUInteger maxCount = 0;
    
    while ((curColor = [enumerator nextObject] )!= nil) {
        NSUInteger tmpCount = [cls countForObject:curColor];
        if (tmpCount < maxCount) {
            continue;
        }
        maxCount = tmpCount;
        maxColor = curColor;
    }
    
    NSLog(@"colors: RGB A %f %d %d  %d",[maxColor[0] floatValue],[maxColor[1] intValue],[maxColor[2] intValue],[maxColor[3] intValue]);
                                                                                
    return [UIColor colorWithRed:([maxColor[0] intValue]/255.0f) green:([maxColor[1] intValue]/255.0f) blue:([maxColor[2] intValue]/255.0f) alpha:([maxColor[3] intValue]/255.0f)];
    
}




@end
