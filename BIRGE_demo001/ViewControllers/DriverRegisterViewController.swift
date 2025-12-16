//
//  DriverRegisterViewController.swift
//  BIRGE_demo001
//
//  Created by Арсен Абдухалық on 10.11.2025.
//
import UIKit

class DriverRegisterViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Personal Info
    @IBOutlet weak var firstNameTextField: CustomTextField!
    @IBOutlet weak var lastNameTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var phoneTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var confirmPasswordTextField: CustomTextField!
    
    // Driver Info
    @IBOutlet weak var licenseTextField: CustomTextField!
    @IBOutlet weak var carModelTextField: CustomTextField!
    @IBOutlet weak var carPlateTextField: CustomTextField!
    @IBOutlet weak var capacityTextField: CustomTextField!
    
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
        title = "Driver Registration"
        
        // Configure text fields
        firstNameTextField.type = .name
        lastNameTextField.type = .name
        emailTextField.type = .email
        phoneTextField.type = .phone
        passwordTextField.type = .password
        confirmPasswordTextField.type = .password
        confirmPasswordTextField.placeholder = "Confirm Password"
        
        licenseTextField.type = .license
        carModelTextField.type = .carModel
        carPlateTextField.type = .carPlate
        capacityTextField.type = .capacity
        
        // Configure button
        registerButton.backgroundColor = .systemOrange
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 8
        
        errorLabel.isHidden = true
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        
        // Set delegates
        let textFields = [firstNameTextField, lastNameTextField, emailTextField, phoneTextField,
                         passwordTextField, confirmPasswordTextField, licenseTextField,
                         carModelTextField, carPlateTextField, capacityTextField]
        textFields.forEach { $0?.delegate = self }
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
        let licenseNumber = licenseTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let carModel = carModelTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let carPlate = carPlateTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let maxCapacity = Int(capacityTextField.text!) ?? 4
        
        registerButton.showLoading()
        errorLabel.isHidden = true
        
        let result = authService.registerDriver(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            password: password,
            licenseNumber: licenseNumber,
            carModel: carModel,
            carPlate: carPlate,
            maxCapacity: maxCapacity
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
        
        // Reset all error states
        let allTextFields = [
            firstNameTextField, lastNameTextField, emailTextField, phoneTextField,
            passwordTextField, confirmPasswordTextField, licenseTextField,
            carModelTextField, carPlateTextField, capacityTextField
        ]
        
        allTextFields.forEach { $0?.setErrorState(false) }
        
        // Validate personal info
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
        }
        
        // Validate driver info
        if let license = licenseTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), license.isEmpty {
            licenseTextField.setErrorState(true)
            isValid = false
        }
        
        if let carModel = carModelTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), carModel.isEmpty {
            carModelTextField.setErrorState(true)
            isValid = false
        }
        
        if let carPlate = carPlateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), carPlate.isEmpty {
            carPlateTextField.setErrorState(true)
            isValid = false
        }
        
        if let capacity = capacityTextField.text, capacity.isEmpty || Int(capacity) == nil {
            capacityTextField.setErrorState(true)
            isValid = false
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
        if let dashboardVC = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController {
            dashboardVC.currentUser = user
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = dashboardVC
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
}

// MARK: - UITextFieldDelegate
extension DriverRegisterViewController: UITextFieldDelegate {
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
        case confirmPasswordTextField:
            licenseTextField.becomeFirstResponder()
        case licenseTextField:
            carModelTextField.becomeFirstResponder()
        case carModelTextField:
            carPlateTextField.becomeFirstResponder()
        case carPlateTextField:
            capacityTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
