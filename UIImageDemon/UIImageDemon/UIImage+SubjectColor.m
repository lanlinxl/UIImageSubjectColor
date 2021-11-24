//
//  UIImage+SubjectColor.m
//  WatermarkAPP
//
//  Created by lzwk_lanlin on 2021/11/24.
//

#import "UIImage+SubjectColor.h"

@implementation UIImage (SubjectColor)
//根据图片获取图片的主色调
-(void)getSubjectColor:(void(^)(UIColor*))callBack {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 第一步 先把图片缩小 加快计算速度. 但越小结果误差可能越大
        int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
        CGSize thumbSize = CGSizeMake(40, 40);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL,thumbSize.width,thumbSize.height, 8, thumbSize.width*4, colorSpace,bitmapInfo);
        CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
        CGContextDrawImage(context, drawRect, self.CGImage);
        CGColorSpaceRelease(colorSpace);
        
        // 第二步 取每个点的像素值
        unsigned char* data = CGBitmapContextGetData (context);
        if (data == NULL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callBack(nil);
            });
        };
        NSCountedSet* cls = [NSCountedSet setWithCapacity: thumbSize.width * thumbSize.height];
        for (int x = 0; x < thumbSize.width; x++) {
            for (int y = 0; y < thumbSize.height; y++) {
                int offset = 4 * (x * y);
                int red = data[offset];
                int green = data[offset + 1];
                int blue = data[offset + 2];
                int alpha =  data[offset + 3];
                // 过滤透明的、基本白色、基本黑色
                if (alpha > 0 && (red < 250 && green < 250 && blue < 250) && (red > 5 && green > 5 && blue > 5)) {
                    NSArray *clr = @[@(red),@(green),@(blue),@(alpha)];
                    [cls addObject:clr];
                }
            }
        }
        CGContextRelease(context);
        
        //第三步 找到出现次数最多的那个颜色
        NSEnumerator *enumerator = [cls objectEnumerator];
        NSArray *curColor = nil;
        NSArray *MaxColor = nil;
        NSUInteger MaxCount = 0;
        while ((curColor = [enumerator nextObject]) != nil){
            NSUInteger tmpCount = [cls countForObject:curColor];
            if ( tmpCount < MaxCount ) continue;
            MaxCount = tmpCount;
            MaxColor = curColor;
        }
        UIColor * subjectColor = [UIColor colorWithRed:([MaxColor[0] intValue]/255.0f) green:([MaxColor[1] intValue]/255.0f) blue:([MaxColor[2] intValue]/255.0f) alpha:([MaxColor[3] intValue]/255.0f)];
        dispatch_async(dispatch_get_main_queue(), ^{
            callBack(subjectColor);
        });
    });
}


@end
