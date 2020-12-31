//
//  Extenstions.swift
//  Do Plan
//
//  Created by Hossein Akbari on 9/26/1399 AP.
//

import UIKit

// MARK: - UIFont

extension UIFont {
    
    static func shabnam(size: CGFloat, weight: Weight = .regular) -> UIFont {
        switch weight {
            case .black, .bold, .heavy:
                return UIFont(name: "Shabnam-Bold-FD", size: size)!
            case .medium, .semibold:
                return UIFont(name: "Shabnam-Medium-FD", size: size)!
            case .regular:
                return UIFont(name: "Shabnam-FD", size: size)!
            case .light:
                return UIFont(name: "Shabnam-Light-FD", size: size)!
            case .thin, .ultraLight:
                return UIFont(name: "Shabnam-Thin-FD", size: size)!
            default:
                return UIFont(name: "Shabnam-FD", size: size)!
        }
    }
}

// MARK: - UIView

@IBDesignable class CustomUIView: UIView {
        
    @IBInspectable var roundedView: Bool = false{
        didSet{
            self.applyRounded()
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var dashWidth: CGFloat = 0
    @IBInspectable var dashColor: UIColor = .clear
    @IBInspectable var dashLength: CGFloat = 0
    @IBInspectable var betweenDashesSpace: CGFloat = 0
    
    var dashBorder: CAShapeLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyDashBorder()
    }
    
    func applyRounded() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
    }
    
    func applyDashBorder() {
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        if cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
    }
    
}

// MARK: - UISearchBar

@IBDesignable class CustomSearchBar: UISearchBar {
    
    @IBInspectable var iconTint: UIColor? {
        didSet {
            self.searchTextField.leftView?.tintColor = iconTint
        }
    }
}

