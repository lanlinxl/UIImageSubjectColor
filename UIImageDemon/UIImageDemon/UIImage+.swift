//
//  UIImage+.swift
//  UIImageDemon
//
//  Created by lzwk_lanlin on 2021/11/24.
//

import Foundation
import UIKit

public extension UIImage {
    func subjectColor(_ completion: @escaping (_ color: UIColor?) -> Void){
      DispatchQueue.global().async {
        if self.cgImage == nil {
            DispatchQueue.main.async {
                return completion(nil)
            }
        }
        let bitmapInfo = CGBitmapInfo(rawValue: 0).rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
          
        // 第一步 先把图片缩小 加快计算速度. 但越小结果误差可能越大
        let thumbSize = CGSize(width: 40 , height: 40)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: nil,
                                      width: Int(thumbSize.width),
                                      height: Int(thumbSize.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: Int(thumbSize.width) * 4 ,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else { return completion(nil) }
          
        let drawRect = CGRect(x: 0, y: 0, width: thumbSize.width, height: thumbSize.height)
        context.draw(self.cgImage! , in: drawRect)
          
        // 第二步 取每个点的像素值
        if context.data == nil{ return completion(nil)}
        let countedSet = NSCountedSet(capacity: Int(thumbSize.width * thumbSize.height))
        for x in 0 ..< Int(thumbSize.width) {
            for y in 0 ..< Int(thumbSize.height){
                let offset = 4 * x * y
                let red = context.data!.load(fromByteOffset: offset, as: UInt8.self)
                let green = context.data!.load(fromByteOffset: offset + 1, as: UInt8.self)
                let blue = context.data!.load(fromByteOffset: offset + 2, as: UInt8.self)
                let alpha = context.data!.load(fromByteOffset: offset + 3, as: UInt8.self)
                // 过滤透明的、基本白色、基本黑色
                if alpha > 0 && (red < 250 && green < 250 && blue < 250) && (red > 5 && green > 5 && blue > 5) {
                    let array = [red,green,blue,alpha]
                    countedSet.add(array)
                }
            }
        }
          
        //第三步 找到出现次数最多的那个颜色
        let enumerator = countedSet.objectEnumerator()
        var maxColor: [Int] = []
        var maxCount = 0
        while let curColor = enumerator.nextObject() as? [Int] , !curColor.isEmpty {
            let tmpCount = countedSet.count(for: curColor)
            if tmpCount < maxCount { continue }
            maxCount = tmpCount
            maxColor = curColor
        }
        let color = UIColor(red: CGFloat(maxColor[0]) / 255.0, green: CGFloat(maxColor[1]) / 255.0, blue: CGFloat(maxColor[2]) / 255.0, alpha: CGFloat(maxColor[3]) / 255.0)
        DispatchQueue.main.async { return completion(color) }
      }
   }
}
