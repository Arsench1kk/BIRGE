import UIKit
import CoreData

class ActiveRideViewController: UIViewController {

    // MARK: - UI Components
    
    // Вместо простого лейбла мы сделаем красивый заголовок с анимацией
    private let statusContainer = UIView()
    private let pulseView = UIView()
    private let statusLabel = UILabel()
    
    // Основная карточка поездки
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 12
        return view
    }()
    
    // Элементы маршрута
    private let departureLabel = UILabel()
    private let destinationLabel = UILabel()
    
    // Элементы пассажиров
    private let passengersContainer = UIView()
    private let passengersIcon = UIImageView()
    private let passengersCountLabel = UILabel()
    private let seatsTitleLabel = UILabel()
    
    // Кнопка
    private let finishButton = UIButton(type: .system)

    // Старый infoLabel оставляем (чтобы формально не удалять переменную),
    // но мы его переиспользуем или скроем, так как он нам не нужен в старом виде.
    private let infoLabel = UILabel()

    var ride: RideEntity!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        fillData()
        startPulseAnimation() // Запуск анимации "живого" процесса
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Current Trip"
        navigationItem.hidesBackButton = true // Обычно на активном экране скрывают кнопку "Назад"
        
        // --- Status Header ---
        pulseView.backgroundColor = .systemGreen
        pulseView.layer.cornerRadius = 6
        
        statusLabel.text = "RIDE IN PROGRESS"
        statusLabel.font = .systemFont(ofSize: 13, weight: .black)
        statusLabel.textColor = .systemGreen
        statusLabel.letterSpacing = 1.2
        
        // --- Route Text Styling ---
        departureLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        departureLabel.numberOfLines = 2
        departureLabel.textColor = .label
        
        destinationLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        destinationLabel.numberOfLines = 2
        destinationLabel.textColor = .label
        
        // --- Passengers Styling ---
        passengersContainer.backgroundColor = .systemGray6
        passengersContainer.layer.cornerRadius = 12
        
        passengersIcon.image = UIImage(systemName: "person.2.fill")
        passengersIcon.tintColor = .systemBlue
        passengersIcon.contentMode = .scaleAspectFit
        
        passengersCountLabel.font = .monospacedDigitSystemFont(ofSize: 20, weight: .bold)
        passengersCountLabel.textColor = .label
        
        seatsTitleLabel.text = "Occupied Seats"
        seatsTitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        seatsTitleLabel.textColor = .secondaryLabel
        
        // --- Button Styling ---
        finishButton.setTitle("Complete Ride", for: .normal)
        finishButton.backgroundColor = .systemGreen
        finishButton.setTitleColor(.white, for: .normal)
        finishButton.layer.cornerRadius = 28 // Полностью круглая по бокам
        finishButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        // Добавляем свечение кнопке
        finishButton.layer.shadowColor = UIColor.systemGreen.cgColor
        finishButton.layer.shadowOpacity = 0.4
        finishButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        finishButton.layer.shadowRadius = 10
        finishButton.addTarget(self, action: #selector(finishRide), for: .touchUpInside)
    }
    
    private func setupLayout() {
        // Подготовка компонентов
        [statusContainer, cardView, finishButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // Header Layout
        [pulseView, statusLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            statusContainer.addSubview($0)
        }
        
        // Card Layout Construction
        // Визуальная линия (Timeline)
        let topDot = createDot(color: .systemBlue)
        let bottomPin = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        bottomPin.tintColor = .systemRed
        let line = UIView()
        line.backgroundColor = .systemGray4
        
        let fromTitle = createSmallLabel(text: "PICKUP")
        let toTitle = createSmallLabel(text: "DROP-OFF")
        
        [topDot, line, bottomPin, fromTitle, departureLabel, toTitle, destinationLabel, passengersContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }
        
        // Passengers Layout
        [passengersIcon, seatsTitleLabel, passengersCountLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            passengersContainer.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // Status Header
            statusContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            statusContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusContainer.heightAnchor.constraint(equalToConstant: 30),
            
            pulseView.centerYAnchor.constraint(equalTo: statusContainer.centerYAnchor),
            pulseView.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor),
            pulseView.widthAnchor.constraint(equalToConstant: 12),
            pulseView.heightAnchor.constraint(equalToConstant: 12),
            
            statusLabel.centerYAnchor.constraint(equalTo: statusContainer.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: pulseView.trailingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor),
            
            // Card View
            cardView.topAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: 24),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Timeline Logic
            topDot.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            topDot.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            topDot.widthAnchor.constraint(equalToConstant: 16),
            topDot.heightAnchor.constraint(equalToConstant: 16),
            
            bottomPin.topAnchor.constraint(equalTo: topDot.bottomAnchor, constant: 60),
            bottomPin.centerXAnchor.constraint(equalTo: topDot.centerXAnchor),
            bottomPin.widthAnchor.constraint(equalToConstant: 24),
            bottomPin.heightAnchor.constraint(equalToConstant: 24),
            
            line.topAnchor.constraint(equalTo: topDot.bottomAnchor, constant: 4),
            line.bottomAnchor.constraint(equalTo: bottomPin.topAnchor, constant: -4),
            line.centerXAnchor.constraint(equalTo: topDot.centerXAnchor),
            line.widthAnchor.constraint(equalToConstant: 2),
            
            // Addresses
            fromTitle.leadingAnchor.constraint(equalTo: topDot.trailingAnchor, constant: 16),
            fromTitle.centerYAnchor.constraint(equalTo: topDot.centerYAnchor, constant: -10),
            
            departureLabel.topAnchor.constraint(equalTo: fromTitle.bottomAnchor, constant: 2),
            departureLabel.leadingAnchor.constraint(equalTo: fromTitle.leadingAnchor),
            departureLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            toTitle.leadingAnchor.constraint(equalTo: bottomPin.trailingAnchor, constant: 12),
            toTitle.centerYAnchor.constraint(equalTo: bottomPin.centerYAnchor, constant: -10),
            
            destinationLabel.topAnchor.constraint(equalTo: toTitle.bottomAnchor, constant: 2),
            destinationLabel.leadingAnchor.constraint(equalTo: toTitle.leadingAnchor),
            destinationLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            // Passengers Box inside Card
            passengersContainer.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 30),
            passengersContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            passengersContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            passengersContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            passengersContainer.heightAnchor.constraint(equalToConstant: 60),
            
            passengersIcon.leadingAnchor.constraint(equalTo: passengersContainer.leadingAnchor, constant: 16),
            passengersIcon.centerYAnchor.constraint(equalTo: passengersContainer.centerYAnchor),
            passengersIcon.widthAnchor.constraint(equalToConstant: 24),
            
            seatsTitleLabel.leadingAnchor.constraint(equalTo: passengersIcon.trailingAnchor, constant: 12),
            seatsTitleLabel.centerYAnchor.constraint(equalTo: passengersContainer.centerYAnchor),
            
            passengersCountLabel.trailingAnchor.constraint(equalTo: passengersContainer.trailingAnchor, constant: -16),
            passengersCountLabel.centerYAnchor.constraint(equalTo: passengersContainer.centerYAnchor),
            
            // Finish Button
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            finishButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Logic & Animation

    private func fillData() {
        guard let ride else { return }
        
        // Заполняем новые красивые лейблы
        departureLabel.text = ride.departureAddress ?? "Unknown"
        destinationLabel.text = ride.destinationAddress ?? "Unknown"
        passengersCountLabel.text = "\(ride.currentPassengers) / \(ride.maxPassengers)"
        
        // infoLabel скрываем, но данные в него можно записать, если нужно для отладки
        infoLabel.isHidden = true
    }
    
    // Анимация пульсации для статуса
    private func startPulseAnimation() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.3
        animation.duration = 1.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseView.layer.add(animation, forKey: "pulse")
    }

    // MARK: - Helpers
    
    private func createDot(color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = 4
        view.layer.cornerRadius = 8
        return view
    }
    
    private func createSmallLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .tertiaryLabel
        return label
    }

    // MARK: - Actions (Unchanged)
    
    @objc private func finishRide() {
        ride.status = "finished"
        CoreDataManager.shared.saveContext()

        let ratingVC = RatingViewController()
        ratingVC.ride = ride
        navigationController?.pushViewController(ratingVC, animated: true)
    }
}

// Extension to allow letter spacing (Kerning) easily
extension UILabel {
    var letterSpacing: CGFloat {
        get { return 0 }
        set {
            let attributedString: NSMutableAttributedString
            if let labelAttributedText = self.attributedText {
                attributedString = NSMutableAttributedString(attributedString: labelAttributedText)
            } else {
                attributedString = NSMutableAttributedString(string: self.text ?? "")
            }
            attributedString.addAttribute(NSAttributedString.Key.kern, value: newValue, range: NSRange(location: 0, length: attributedString.length))
            self.attributedText = attributedString
        }
    }
}
