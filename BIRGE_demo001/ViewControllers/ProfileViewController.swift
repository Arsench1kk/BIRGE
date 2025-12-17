import UIKit

class ProfileViewController: UIViewController {

    // MARK: - UI Elements (Outlets)
    // Убедись, что они подключены в Storyboard!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var savedMoneyLabel: UILabel! // Зеленая сумма "Saved Money"
    
    // Кнопка для админки (скрыта по умолчанию)
    // В Storyboard добавь кнопку, поставь ей Hidden = true и подключи сюда
    @IBOutlet weak var adminPanelButton: UIButton!
    
    // MARK: - Properties
    var currentUser: UserEntity?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Обновляем данные каждый раз при появлении экрана
        loadUserData()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Делаем аватарку круглой
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor(named: "AccentColor")?.cgColor ?? UIColor.systemBlue.cgColor
        
        // Скрываем кнопку админа (на всякий случай)
        adminPanelButton.isHidden = true
    }
    
    // MARK: - Data Loading
    private func loadUserData() {
        // Получаем текущего пользователя из базы
        currentUser = CoreDataManager.shared.getCurrentUser()
        
        guard let user = currentUser else { return }
        
        // Заполняем поля
        nameLabel.text = "\(user.firstName ?? "") \(user.lastName ?? "")"
        
        // Форматируем рейтинг (например, 4.9)
        ratingLabel.text = String(format: "⭐️ %.1f", user.avgRating)
        
        // Фейковые данные для демо (можно позже привязать к реальной истории поездок)
        savedMoneyLabel.text = "5 700 ₸"
        
        // --- ЛОГИКА АДМИНА ---
        // Проверяем: или есть флаг isAdmin, или в email есть слово "admin"
        let isAdmin = (user.value(forKey: "isAdmin") as? Bool) ?? false
        let isEmailAdmin = user.email?.lowercased().contains("admin") ?? false
        
        if isAdmin || isEmailAdmin {
            adminPanelButton.isHidden = false
        } else {
            adminPanelButton.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    // Действие для кнопки "Admin Panel"
    @IBAction func adminPanelTapped(_ sender: UIButton) {
        // Открываем контроллер админки
        let adminVC = AdminViewController()
        // Оборачиваем в NavigationController, чтобы была кнопка "Close" и заголовок
        let nav = UINavigationController(rootViewController: adminVC)
        present(nav, animated: true)
    }
    
    // Действие для кнопки "Log Out"
    @IBAction func logoutTapped(_ sender: UIButton) {
        // Показываем алерт подтверждения
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            self.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        AuthService.shared.logout()
        
        // Переход на экран входа (сбрасываем весь стек навигации)
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            
            // Анимация перехода
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            window.rootViewController = UINavigationController(rootViewController: loginVC)
        }
    }
}