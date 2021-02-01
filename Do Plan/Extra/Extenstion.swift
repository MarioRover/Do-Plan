//
//  Extenstions.swift
//  Do Plan
//
//  Created by Hossein Akbari on 9/26/1399 AP.
//

import UIKit

// MARK: - UIFont

class MyUIViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
    }
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

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


extension Date {
    static func dateFormatToString(date: Date, type: type) -> String {
        let dateFormatter = DateFormatter()
        var dateFormat: String
        
        switch type {
            case .date:
                dateFormat = "EEE, MMM d, yyyy"
            case .time:
                dateFormat = "h:mm"
            case .timePA:
                dateFormat = "h:mm a"
            case .standard:
                dateFormat = "E, d MMM h:mm a"
        }
    
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    enum type {
        case standard
        case date
        case timePA
        case time
    }
}


extension UIImage {
    static func systemIcon(name withName: IconName) -> UIImage? {
        return UIImage(systemName: withName.rawValue)
    }
    
    
    enum IconName: String {
        case arrowUpCircle = "arrow.up.circle"
        case arrowUpRightCircle = "arrow.up.right.circle"
        case arrowDownCircle = "arrow.down.circle"
        case circle = "circle"
        case checkmarkCircleFill = "checkmark.circle.fill"
    }
}


extension UIColor {
    static func customColor(color withColor: CustomColorName) -> UIColor? {
        return UIColor(named: withColor.rawValue)
    }
    
    enum CustomColorName: String {
        case red    = "Red"
        case yellow = "Yellow"
        case green  = "Green"
        case main   = "Main"
        case grayDesc   = "GrayDesc"
        case grayWhite = "GrayWhite"
    }
}
