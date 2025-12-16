//
//  CustomTextField.swift
//  BIRGE_demo001
//
//  Created by Арсен Абдухалық on 10.11.2025.
//
import UIKit

class CustomTextField: UITextField {
    
    enum TextFieldType {
        case email
        case password
        case phone
        case name
        case license
        case carModel
        case carPlate
        case capacity
    }
    
    var type: TextFieldType = .email {
        didSet {
            configureForType()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: frame.height))
        leftViewMode = .always
        
        font = UIFont.systemFont(ofSize: 16)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func configureForType() {
        switch type {
        case .email:
            placeholder = "Email"
            keyboardType = .emailAddress
            autocapitalizationType = .none
            autocorrectionType = .no
        case .password:
            placeholder = "Password"
            isSecureTextEntry = true
            autocapitalizationType = .none
        case .phone:
            placeholder = "Phone Number"
            keyboardType = .phonePad
        case .name:
            placeholder = "Name"
            autocapitalizationType = .words
        case .license:
            placeholder = "Driver License Number"
            autocapitalizationType = .allCharacters
        case .carModel:
            placeholder = "Car Model"
            autocapitalizationType = .words
        case .carPlate:
            placeholder = "Car Plate"
            autocapitalizationType = .allCharacters
        case .capacity:
            placeholder = "Max Passengers"
            keyboardType = .numberPad
        }
    }
    
    func setErrorState(_ isError: Bool) {
        layer.borderColor = isError ? UIColor.systemRed.cgColor : UIColor.systemGray4.cgColor
    }
}
