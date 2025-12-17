import UIKit
import CoreData

class RatingViewController: UIViewController {

    var ride: RideEntity!

    // MARK: - UI Components
    private let containerView = UIView()
    
    // Декоративная иконка сверху
    private let successIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "checkmark.seal.fill")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGreen
        return iv
    }()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel() // Доп. подпись для UX
    private let starsStack = UIStackView()
    private let submitButton = UIButton(type: .system)

    private var selectedRating = 5
    private var starButtons: [UIButton] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStars() // Устанавливаем начальное состояние
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        // Убираем кнопку назад, чтобы пользователь не ушел не оценив (UX паттерн)
        navigationItem.hidesBackButton = true
        
        // --- Настройка текстов ---
        titleLabel.text = "Trip Completed!"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        
        subtitleLabel.text = "How was your experience?"
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryLabel
        
        // --- Настройка звезд ---
        starsStack.axis = .horizontal
        starsStack.spacing = 8
        starsStack.alignment = .center
        starsStack.distribution = .fillEqually

        for i in 1...5 {
                    let button = UIButton(type: .custom)
                    button.tag = i
                    
                    // Настраиваем размер иконки (40pt)
                    let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
                    
                    // ИСПРАВЛЕНИЕ ЗДЕСЬ: используем forImageIn вместо forNormal
                    button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
                    
                    button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
                    
                    starButtons.append(button)
                    starsStack.addArrangedSubview(button)
                }

        // --- Настройка кнопки ---
        submitButton.setTitle("Submit Rating", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 16
        submitButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        
        // Тень для кнопки
        submitButton.layer.shadowColor = UIColor.systemBlue.cgColor
        submitButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        submitButton.layer.shadowOpacity = 0.3
        submitButton.layer.shadowRadius = 8
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        // --- Layout ---
        let contentStack = UIStackView(arrangedSubviews: [
            successIcon,
            titleLabel,
            subtitleLabel,
            starsStack,
            submitButton
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.setCustomSpacing(8, after: titleLabel) // Меньше отступ между заголовком и подзаголовком
        contentStack.setCustomSpacing(40, after: subtitleLabel) // Больше отступ перед звездами
        contentStack.setCustomSpacing(40, after: starsStack) // Отступ до кнопки
        
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentStack)

        NSLayoutConstraint.activate([
            successIcon.heightAnchor.constraint(equalToConstant: 80),
            
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            contentStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            submitButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Logic & Animation

    private func updateStars() {
        for button in starButtons {
            let isSelected = button.tag <= selectedRating
            
            // Используем SF Symbols: fill для выбранных, line для пустых
            let imageName = isSelected ? "star.fill" : "star"
            button.setImage(UIImage(systemName: imageName), for: .normal)
            
            // Цвет: Желтый для выбранных, Серый для пустых
            button.tintColor = isSelected ? .systemYellow : .systemGray4
        }
    }

    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStars()
        animateSelection(sender) // Добавляем тактильности
    }
    
    // Анимация "Пружина" при нажатии
    private func animateSelection(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1,
                       animations: {
            sender.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
    }

    @objc private func submitTapped() {
        saveRating()
        navigationController?.popToRootViewController(animated: true)
    }

    private func saveRating() {
        guard let user = CoreDataManager.shared.getCurrentUser() else { return }

        // УПРОЩЁННАЯ логика для дедлайна:
        let oldRating = user.avgRating
        user.avgRating = (oldRating + Double(selectedRating)) / 2

        CoreDataManager.shared.saveContext()
    }
}
