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
    
    @IBInspectable var leftTopRadius : CGFloat = 0{
        didSet{
            self.applyMask()
        }
    }
    @IBInspectable var rightTopRadius : CGFloat = 0{
        didSet{
            self.applyMask()
        }
    }
    @IBInspectable var rightBottomRadius : CGFloat = 0{
        didSet{
            self.applyMask()
        }
    }
    
    @IBInspectable var leftBottomRadius : CGFloat = 0{
        didSet{
            self.applyMask()
        }
    }
    
    @IBInspectable var roundedView: Bool = false{
        didSet{
            self.applyRounded()
        }
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyMask()
    }
        
    func applyMask()
    {
        let shapeLayer = CAShapeLayer(layer: self.layer)
        shapeLayer.path = self.pathForCornersRounded(rect:self.bounds).cgPath
        shapeLayer.frame = self.bounds
        shapeLayer.masksToBounds = true
        self.layer.mask = shapeLayer
    }
    
    func pathForCornersRounded(rect:CGRect) ->UIBezierPath
    {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0 + leftTopRadius , y: 0))
        path.addLine(to: CGPoint(x: rect.size.width - rightTopRadius , y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.size.width , y: rightTopRadius), controlPoint: CGPoint(x: rect.size.width, y: 0))
        path.addLine(to: CGPoint(x: rect.size.width , y: rect.size.height - rightBottomRadius))
        path.addQuadCurve(to: CGPoint(x: rect.size.width - rightBottomRadius , y: rect.size.height), controlPoint: CGPoint(x: rect.size.width, y: rect.size.height))
        path.addLine(to: CGPoint(x: leftBottomRadius , y: rect.size.height))
        path.addQuadCurve(to: CGPoint(x: 0 , y: rect.size.height - leftBottomRadius), controlPoint: CGPoint(x: 0, y: rect.size.height))
        path.addLine(to: CGPoint(x: 0 , y: leftTopRadius))
        path.addQuadCurve(to: CGPoint(x: 0 + leftTopRadius , y: 0), controlPoint: CGPoint(x: 0, y: 0))
        path.close()
        
        return path
    }
    
    func applyRounded() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
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

