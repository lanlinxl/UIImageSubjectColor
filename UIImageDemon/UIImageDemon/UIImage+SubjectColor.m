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
        int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
        CGFloat thumbWith = MIN(40, self.size.width / 10);
        CGFloat thumbHeight = MIN(40, self.size.height / 10);
        CGSize thumbSize = CGSizeMake(thumbWith, thumbHeight);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL,thumbSize.width,thumbSize.height, 8, thumbSize.width*4, colorSpace,bitmapInfo);
        CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
        CGContextDrawImage(context, drawRect, self.CGImage);
        CGColorSpaceRelease(colorSpace);
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
