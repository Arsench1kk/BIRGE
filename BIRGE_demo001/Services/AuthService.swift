import Foundation
import CoreData

class AuthService {
    static let shared = AuthService()
    private let coreDataManager = CoreDataManager.shared
    
    private init() {}
    
    // MARK: - Authentication
    func login(email: String, password: String, userType: String) -> (success: Bool, user: UserEntity?, message: String) {
        // Input validation
        guard !email.isEmpty, !password.isEmpty else {
            return (false, nil, "Email and password cannot be empty")
        }
        
        guard let user = coreDataManager.authenticateUser(email: email, password: password) else {
            return (false, nil, "Invalid email or password")
        }
        
        guard user.userType == userType else {
            return (false, nil, "User type mismatch. Please select correct user type.")
        }
        
        guard user.isVerified else {
            return (false, nil, "Account not verified. Please contact support.")
        }
        
        return (true, user, "Login successful")
    }
    
    func registerPassenger(firstName: String, lastName: String, email: String, phone: String, password: String) -> (success: Bool, user: UserEntity?, message: String) {
        // Validate inputs
        guard validateRegistrationInputs(firstName: firstName, lastName: lastName, email: email, phone: phone, password: password) else {
            return (false, nil, "Please fill in all fields correctly")
        }
        
        let result = coreDataManager.registerUser(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            password: password,
            userType: "passenger"
        )
        
        if result.success, let user = coreDataManager.getUserByEmail(email) {
            return (true, user, result.message)
        } else {
            return (false, nil, result.message)
        }
    }
    
    func registerDriver(firstName: String, lastName: String, email: String, phone: String, password: String, licenseNumber: String, carModel: String, carPlate: String, maxCapacity: Int) -> (success: Bool, user: UserEntity?, message: String) {
        // Validate inputs
        guard validateRegistrationInputs(firstName: firstName, lastName: lastName, email: email, phone: phone, password: password) else {
            return (false, nil, "Please fill in all fields correctly")
        }
        
        guard !licenseNumber.isEmpty, !carModel.isEmpty, !carPlate.isEmpty, maxCapacity > 0, maxCapacity <= 8 else {
            return (false, nil, "Please provide valid driver information")
        }
        
        let result = coreDataManager.registerDriver(
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
        
        if result.success, let user = coreDataManager.getUserByEmail(email) {
            return (true, user, result.message)
        } else {
            return (false, nil, result.message)
        }
    }
    
    func getCurrentUser() -> UserEntity? {
        return coreDataManager.getCurrentUser()
    }
    
    func logout() {
        coreDataManager.logout()
        print("✅ User logged out")
    }
    
    func isLoggedIn() -> Bool {
        return getCurrentUser() != nil
    }
    
    // MARK: - Validation Helpers
    private func validateRegistrationInputs(firstName: String, lastName: String, email: String, phone: String, password: String) -> Bool {
        guard !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              isValidEmail(email),
              isValidPhone(phone),
              password.count >= 8 else {
            return false
        }
        return true
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPhone(_ phone: String) -> Bool {
        let phoneRegEx = "^\\+?[0-9]{10,15}$"
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: phone)
    }
    
    // MARK: - Password Reset (Future Implementation)
    func requestPasswordReset(email: String) -> (success: Bool, message: String) {
        guard let user = coreDataManager.getUserByEmail(email) else {
            return (false, "User not found")
        }
        
        // TODO: Implement email sending logic
        print("Password reset requested for: \(user.email ?? "")")
        return (true, "Password reset instructions sent to your email")
    }
    
    // MARK: - Account Management
    func updateUserProfile(user: UserEntity, firstName: String?, lastName: String?, phone: String?) -> (success: Bool, message: String) {
        var updated = false
        
        if let firstName = firstName, !firstName.isEmpty {
            user.firstName = firstName
            updated = true
        }
        
        if let lastName = lastName, !lastName.isEmpty {
            user.lastName = lastName
            updated = true
        }
        
        if let phone = phone, isValidPhone(phone) {
            user.phone = phone
            updated = true
        }
        
        if updated {
            coreDataManager.saveContext()
            return (true, "Profile updated successfully")
        }
        
        return (false, "No changes made")
    }
    
    func updateDriverProfile(user: UserEntity, licenseNumber: String?, carModel: String?, carPlate: String?, maxCapacity: Int?) -> (success: Bool, message: String) {
        guard user.userType == "driver",
              let profile = coreDataManager.getDriverProfile(for: user) else {
            return (false, "Driver profile not found")
        }
        
        var updated = false
        
        if let license = licenseNumber, !license.isEmpty {
            profile.licenseNumber = license
            updated = true
        }
        
        if let model = carModel, !model.isEmpty {
            profile.carModel = model
            updated = true
        }
        
        if let plate = carPlate, !plate.isEmpty {
            profile.carPlate = plate
            updated = true
        }
        
        if let capacity = maxCapacity, capacity > 0, capacity <= 8 {
            profile.maxCapacity = Int32(capacity)
            updated = true
        }
        
        if updated {
            coreDataManager.saveContext()
            return (true, "Driver profile updated successfully")
        }
        
        return (false, "No changes made")
    }
}
