//
//  UIImage+SubjectColor.h
//  WatermarkAPP
//
//  Created by lzwk_lanlin on 2021/11/24.
//

#import <UIKit/UIKit.h>

@interface UIImage (SubjectColor)

-(void)getSubjectColor:(void(^)(UIColor*))callBack;
@end


