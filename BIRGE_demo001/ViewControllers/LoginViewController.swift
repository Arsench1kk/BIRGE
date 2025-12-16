//
//  LoginViewController.swift
//  BIRGE_demo001
//
//  Created by Арсен Абдухалық on 10.11.2025.
//
import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var userTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var loginButton: LoadingButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var demoInfoLabel: UILabel!
    
    // MARK: - Properties
    private let authService = AuthService.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        preloadDemoData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "BIRGE Login"
        
        // Configure text fields
        emailTextField.type = .email
        passwordTextField.type = .password
        
        // Configure buttons
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        
        registerButton.setTitleColor(.systemBlue, for: .normal)
        
        // Demo info
        demoInfoLabel.text = "Demo Accounts:\nPassenger: alia@demo.com / password123\nDriver: aslan@demo.com / password123"
        demoInfoLabel.numberOfLines = 0
        demoInfoLabel.textColor = .systemGray
        demoInfoLabel.font = UIFont.systemFont(ofSize: 12)
        
        // Hide error label initially
        errorLabel.isHidden = true
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func preloadDemoData() {
        // Preload demo data on first launch
        CoreDataManager.shared.preloadDemoData()
    }
    
    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: LoadingButton) {
        dismissKeyboard()
        
        guard validateInputs() else { return }
        
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!
        let userType = userTypeSegmentedControl.selectedSegmentIndex == 0 ? "passenger" : "driver"
        
        loginButton.showLoading()
        errorLabel.isHidden = true
        
        let result = authService.login(email: email, password: password, userType: userType)
        
        loginButton.hideLoading()
        
        if result.success, let user = result.user {
            showDashboard(for: user)
        } else {
            showError(result.message)
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        let userType = userTypeSegmentedControl.selectedSegmentIndex == 0 ? "passenger" : "driver"
        showRegistrationScreen(for: userType)
    }
    
    // MARK: - Validation
    private func validateInputs() -> Bool {
        var isValid = true
        
        // Validate email
        if let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), email.isEmpty || !isValidEmail(email) {
            emailTextField.setErrorState(true)
            isValid = false
        } else {
            emailTextField.setErrorState(false)
        }
        
        // Validate password
        if let password = passwordTextField.text, password.isEmpty {
            passwordTextField.setErrorState(true)
            isValid = false
        } else {
            passwordTextField.setErrorState(false)
        }
        
        if !isValid {
            showError("Please fill in all fields correctly")
        }
        
        return isValid
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
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
    
    private func showRegistrationScreen(for userType: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = userType == "passenger" ? "RegisterViewController" : "DriverRegisterViewController"
        
        if let registerVC = storyboard.instantiateViewController(withIdentifier: identifier) as? UIViewController {
            navigationController?.pushViewController(registerVC, animated: true)
        }
    }
    
    // MARK: - Error Handling
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        
        // Auto-hide error after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.errorLabel.isHidden = true
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
