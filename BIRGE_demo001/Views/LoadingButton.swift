//
//  LoadingButton.swift
//  BIRGE_demo001
//
//  Created by Арсен Абдухалық on 10.11.2025.
//
import UIKit

class LoadingButton: UIButton {
    
    private var originalButtonText: String?
    private var activityIndicator: UIActivityIndicatorView!
    
    var isLoading: Bool = false {
        didSet {
            updateButtonAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActivityIndicator()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func updateButtonAppearance() {
        if isLoading {
            originalButtonText = titleLabel?.text
            setTitle("", for: .normal)
            activityIndicator.startAnimating()
            isEnabled = false
            alpha = 0.7
        } else {
            setTitle(originalButtonText, for: .normal)
            activityIndicator.stopAnimating()
            isEnabled = true
            alpha = 1.0
        }
    }
    
    func showLoading() {
        isLoading = true
    }
    
    func hideLoading() {
        isLoading = false
    }
}
