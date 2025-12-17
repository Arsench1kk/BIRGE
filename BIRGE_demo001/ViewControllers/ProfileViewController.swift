import UIKit
import CoreData

class ProfileViewController: UIViewController {

    // MARK: - Outlets (как в storyboard)
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UIButton!
    @IBOutlet weak var savedMoneyLabel: UIButton!
    @IBOutlet weak var totalRidesButton: UIButton!


    @IBOutlet weak var paymentMethodButton: UIButton!
    @IBOutlet weak var savedAddressesButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!

    // Админка (если есть на storyboard)
    @IBOutlet weak var adminPanelButton: UIButton!

    // MARK: - Properties
    var currentUser: UserEntity?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUser()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - UI
    private func setupUI() {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.clipsToBounds = true

        adminPanelButton?.isHidden = true
    }

    // MARK: - Data
    private func loadUser() {
        currentUser = CoreDataManager.shared.getCurrentUser()
        guard let user = currentUser else { return }

        nameLabel.text = "\(user.firstName ?? "") \(user.lastName ?? "")"

        ratingLabel.setTitle(
            String(format: " %.1f", user.avgRating),
            for: .normal
        )

        savedMoneyLabel.setTitle("💰 5 700 ₸", for: .normal)

        let totalRides = CoreDataManager.shared.getBookingsForUser(user).count
        totalRidesButton.setTitle("🚕 \(totalRides)", for: .normal)

        let isEmailAdmin = user.email?.lowercased().contains("admin") ?? false
        adminPanelButton?.isHidden = !isEmailAdmin
    }



    // MARK: - Actions (заглушки, но рабочие)
    @IBAction func totalRidesTapped(_ sender: UIButton) {
        showInfo(
            title: "Total Rides",
            message: "You have completed \(sender.currentTitle ?? "") rides"
        )
    }

    @IBAction func ratingTapped(_ sender: UIButton) {
        showInfo(title: "Rating", message: "Your current rating")
    }

    @IBAction func savedMoneyTapped(_ sender: UIButton) {
        showInfo(title: "Saved Money", message: "Money saved by group rides")
    }

    @IBAction func paymentMethodTapped(_ sender: UIButton) {
        showInfo(title: "Payment Method", message: "Payment methods coming soon")
    }

    @IBAction func savedAddressesTapped(_ sender: UIButton) {
        showInfo(title: "Saved Addresses", message: "Saved addresses coming soon")
    }

    @IBAction func languageTapped(_ sender: UIButton) {
        showInfo(title: "Language", message: "Language settings coming soon")
    }

    @IBAction func supportTapped(_ sender: UIButton) {
        showInfo(title: "Support", message: "Support service coming soon")
    }
    @IBAction func adminPanelTapped(_ sender: UIButton) {

        let adminVC = AdminViewController()

        let navController = UINavigationController(rootViewController: adminVC)

        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }



    @IBAction func logoutTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            self.performLogout()
        })

        present(alert, animated: true)
    }

    private func performLogout() {
        AuthService.shared.logout()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        let nav = UINavigationController(rootViewController: loginVC)

        if let window = UIApplication.shared.windows.first {
            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: nil
            )
            window.rootViewController = nav
        }
    }

    // MARK: - Helper
    private func showInfo(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
