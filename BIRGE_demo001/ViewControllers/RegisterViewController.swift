//
//  RegisterViewController.swift
//  BIRGE_demo001
//
//  Created by Арсен Абдухалық on 10.11.2025.
//
import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstNameTextField: CustomTextField!
    @IBOutlet weak var lastNameTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var phoneTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var confirmPasswordTextField: CustomTextField!
    @IBOutlet weak var registerButton: LoadingButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - Properties
    private let authService = AuthService.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Passenger Registration"
        
        // Configure text fields
        firstNameTextField.type = .name
        firstNameTextField.placeholder = "First Name"
        
        lastNameTextField.type = .name
        lastNameTextField.placeholder = "Last Name"
        
        emailTextField.type = .email
        phoneTextField.type = .phone
        passwordTextField.type = .password
        confirmPasswordTextField.type = .password
        confirmPasswordTextField.placeholder = "Confirm Password"
        
        // Configure button
        registerButton.backgroundColor = .systemGreen
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 8
        
        errorLabel.isHidden = true
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        
        // Set delegates
        [firstNameTextField, lastNameTextField, emailTextField, phoneTextField, passwordTextField, confirmPasswordTextField].forEach {
            $0.delegate = self
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @IBAction func registerButtonTapped(_ sender: LoadingButton) {
        dismissKeyboard()
        
        guard validateInputs() else { return }
        
        let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = phoneTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!
        
        registerButton.showLoading()
        errorLabel.isHidden = true
        
        let result = authService.registerPassenger(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            password: password
        )
        
        registerButton.hideLoading()
        
        if result.success, let user = result.user {
            showDashboard(for: user)
        } else {
            showError(result.message)
        }
    }
    
    // MARK: - Validation
    private func validateInputs() -> Bool {
        var isValid = true
        
        [firstNameTextField, lastNameTextField, emailTextField, phoneTextField, passwordTextField, confirmPasswordTextField].forEach {
            $0.setErrorState(false)
        }
        
        if let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), firstName.isEmpty {
            firstNameTextField.setErrorState(true)
            isValid = false
        }
        
        if let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), lastName.isEmpty {
            lastNameTextField.setErrorState(true)
            isValid = false
        }
        
        if let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), email.isEmpty || !isValidEmail(email) {
            emailTextField.setErrorState(true)
            isValid = false
        }
        
        if let phone = phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), phone.isEmpty {
            phoneTextField.setErrorState(true)
            isValid = false
        }
        
        if let password = passwordTextField.text, password.isEmpty || password.count < 8 {
            passwordTextField.setErrorState(true)
            isValid = false
        }
        
        if let confirmPassword = confirmPasswordTextField.text,
           let password = passwordTextField.text,
           confirmPassword != password {
            confirmPasswordTextField.setErrorState(true)
            isValid = false
            showError("Passwords do not match")
        }
        
        if !isValid && errorLabel.isHidden {
            showError("Please fill in all fields correctly")
        }
        
        return isValid
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    private func showDashboard(for user: UserEntity) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let tabBarController = storyboard.instantiateViewController(
            withIdentifier: "MainTabBarController"
        ) as? UITabBarController else {
            return
        }
        
        if let nav = tabBarController.viewControllers?.first as? UINavigationController,
           let dashboardVC = nav.viewControllers.first as? DashboardViewController {
            dashboardVC.currentUser = user
        }
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = tabBarController
            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: nil
            )
        }
    }

    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
}

// MARK: - UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            phoneTextField.becomeFirstResponder()
        case phoneTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
