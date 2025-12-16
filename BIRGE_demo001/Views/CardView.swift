//
//  CardView.swift
//  BIRGE_demo001
//
//  Created by Арсен Абдухалық on 16.12.2025.
//


import UIKit

@IBDesignable
class CardView: UIView {


    @IBInspectable var cornerRadius: CGFloat = 10 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }


    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }


    @IBInspectable var shadowColor: UIColor = .black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
}
