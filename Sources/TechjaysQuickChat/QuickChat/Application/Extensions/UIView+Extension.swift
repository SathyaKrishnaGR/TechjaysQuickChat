//
//  File.swift
//  
//
//  Created by SathyaKrishna on 24/09/21.
//

import Foundation
//
//  UIViewExtension.swift
//  Fayvit
//
//  Created by Sharran on 9/7/20.
//  Copyright © 2020 Iderize. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func shadow() {
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 4.0
        self.layer.shadowColor = UIColor(red: 20/255, green: 20/255, blue: 54/255, alpha: 0.1).cgColor
    }
    
    func maskedCornorRadius(cornors: CACornerMask, cornorRadius: CGFloat) {
        self.layer.cornerRadius = cornorRadius
        self.layer.maskedCorners = cornors
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var fayvShadow: Bool {
        get {
            return layer.shadowOpacity > 0
        }
        set {
            if newValue && UIScreen.main.traitCollection.userInterfaceStyle == .light {
                self.layer.shadowOpacity = 1
                self.layer.shadowOffset = CGSize(width: 2, height: 2)
                self.layer.shadowRadius = 5
                self.layer.shadowColor = UIColor(red: 20/255, green: 20/255, blue: 54/255, alpha: 0.1).cgColor
            } else {
                self.layer.shadowOpacity = 0
                self.layer.shadowRadius = 0
            }
        }
    }
    
    func loadNib(name: String) -> UIView? {
        return Bundle
            .main
            .loadNibNamed(name, owner: self, options: nil)?
            .first as? UIView
    }
    
    func embed(_ viewController: UIViewController, inParent controller: UIViewController, animation: EmbedAnimation = .none, animationCompletion: ((Bool) -> Void)? = nil) {
        viewController.willMove(toParent: controller)
        viewController.view.frame = bounds
        addSubview(viewController.view)
        controller.addChild(viewController)
        viewController.didMove(toParent: controller)
        viewController.view.animate(animation, animationCompletion: animationCompletion)
    }
    
    func animate(_ animation: EmbedAnimation = .none, animationCompletion: ((Bool) -> Void)? = nil) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        switch animation {
        case .slideFromLeft:
            frame = CGRect(x: -screenWidth, y: 0, width: frame.width, height: frame.height)
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform(translationX: screenWidth, y: 0)
            }, completion: animationCompletion)
        case .slideFromRight:
            frame = CGRect(x: screenWidth, y: 0, width: frame.width, height: frame.height)
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
            }, completion: animationCompletion)
        case .slideFromBottom:
            frame = CGRect(x: 0, y: screenHeight, width: frame.width, height: frame.height)
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
            }, completion: animationCompletion)
        case .slideFromTop:
            frame = CGRect(x: 0, y: -screenHeight, width: frame.width, height: frame.height)
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform(translationX: 0, y: screenHeight)
            }, completion: animationCompletion)
        case .slideToRight:
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform(translationX: screenWidth, y: 0)
            }, completion: animationCompletion)
        case .slideToLeft:
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
            }, completion: animationCompletion)
        case .slideToTop:
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
            }, completion: animationCompletion)
        case .slideToBottom:
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform(translationX: 0, y: screenHeight)
            }, completion: animationCompletion)
        default:
            return
        }
    }
    
    enum EmbedAnimation {
        case none
        case slideFromRight
        case slideFromLeft
        case slideFromTop
        case slideFromBottom
        case slideToRight
        case slideToLeft
        case slideToTop
        case slideToBottom
    }
}

extension UIView {
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
