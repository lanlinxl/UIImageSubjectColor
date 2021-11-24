//
//  ViewController.swift
//  UIImageDemon
//
//  Created by lzwk_lanlin on 2021/11/24.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(type: .system)
        view.addSubview(button)
        button.setTitle("选择照片", for: .normal)
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        button.frame = CGRect(x: 10, y: 100, width: 100, height: 20)
  
        view.addSubview(imageView)
        imageView.frame = CGRect(x: 100, y: 150, width: 150, height: 150)
        
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
     
    }
    
    @objc func buttonClick(){
        /// 4. 点击选图片时，展示这个 picker controller
           present(imagePicker, animated: true) {
               print("UIImagePickerController: presented")
           }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        picker.dismiss(animated: true) { [unowned self] in
            self.imageView.image = selectedImage
            
            // Swift
            selectedImage.subjectColor({[unowned self] color in
                guard let subjectColor = color else { return }
                    self.view.backgroundColor = subjectColor
            })
            
            // OC
            selectedImage.getSubjectColor {[unowned self] color in
                guard let subjectColor = color else { return }
                self.view.backgroundColor = subjectColor
            }
        }
    }
}
