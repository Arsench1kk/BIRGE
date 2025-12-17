import UIKit
import CoreData

class CreateRideViewController: UIViewController {

    // MARK: - UI Components
    
    // Header Label для красоты
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "New Ride"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    // Контейнеры для визуального оформления (карточки)
    private let locationContainer = UIView()
    private let optionsContainer = UIView()
    
    private let fromField = UITextField()
    private let toField = UITextField()
    
    // Разделитель между полями ввода
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    private let datePicker = UIDatePicker()
    
    // Label для даты
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Departure Time"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let seatsLabel = UILabel()
    private let seatsStepper = UIStepper()
    private let createButton = UIButton(type: .system) // Type system для анимации нажатия

    // MARK: - Data
    private var selectedSeats = 1
    private let currentUser = CoreDataManager.shared.getCurrentUser()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        // Скрываем стандартный title, так как у нас свой красивый header
        navigationItem.largeTitleDisplayMode = .never
        
        // --- Настройка полей ввода (Input Fields) ---
        setupTextField(fromField, placeholder: "From", iconName: "location.circle.fill", color: .systemBlue)
        setupTextField(toField, placeholder: "To", iconName: "mappin.circle.fill", color: .systemRed)
        
        // Контейнер локации (белая карточка с тенью)
        styleCardView(locationContainer)
        
        // --- Настройка Date Picker ---
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        datePicker.preferredDatePickerStyle = .compact // Современный стиль
        datePicker.tintColor = .systemBlue
        
        // --- Настройка Stepper ---
        seatsStepper.minimumValue = 1
        seatsStepper.maximumValue = 4
        seatsStepper.value = 1
        seatsStepper.addTarget(self, action: #selector(seatsChanged), for: .valueChanged)
        
        seatsLabel.text = "Seats: 1" // Чуть сократил для чистоты
        seatsLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        
        // Контейнер опций
        styleCardView(optionsContainer)

        // --- Настройка Кнопки ---
        createButton.setTitle("Create Ride", for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        createButton.backgroundColor = .systemBlue
        createButton.tintColor = .white
        createButton.layer.cornerRadius = 16
        // Добавляем тень кнопке для "парения"
        createButton.layer.shadowColor = UIColor.systemBlue.cgColor
        createButton.layer.shadowOpacity = 0.3
        createButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        createButton.layer.shadowRadius = 8
        createButton.addTarget(self, action: #selector(createRide), for: .touchUpInside)
    }
    
    private func setupLayout() {
        // Подготовка компонентов для AutoLayout
        [headerLabel, locationContainer, optionsContainer, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // Добавляем элементы внутрь карточки локации
        [fromField, separatorView, toField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            locationContainer.addSubview($0)
        }
        
        // Добавляем элементы внутрь карточки опций
        [dateLabel, datePicker, seatsLabel, seatsStepper].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            optionsContainer.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // Header
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            // Location Card
            locationContainer.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 24),
            locationContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            locationContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // From Field
            fromField.topAnchor.constraint(equalTo: locationContainer.topAnchor, constant: 4),
            fromField.leadingAnchor.constraint(equalTo: locationContainer.leadingAnchor, constant: 8),
            fromField.trailingAnchor.constraint(equalTo: locationContainer.trailingAnchor, constant: -8),
            fromField.heightAnchor.constraint(equalToConstant: 50),
            
            // Separator
            separatorView.topAnchor.constraint(equalTo: fromField.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: locationContainer.leadingAnchor, constant: 50), // Отступ под иконку
            separatorView.trailingAnchor.constraint(equalTo: locationContainer.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            // To Field
            toField.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            toField.leadingAnchor.constraint(equalTo: locationContainer.leadingAnchor, constant: 8),
            toField.trailingAnchor.constraint(equalTo: locationContainer.trailingAnchor, constant: -8),
            toField.heightAnchor.constraint(equalToConstant: 50),
            toField.bottomAnchor.constraint(equalTo: locationContainer.bottomAnchor, constant: -4),
            
            // Options Card
            optionsContainer.topAnchor.constraint(equalTo: locationContainer.bottomAnchor, constant: 24),
            optionsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            optionsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Date Row inside Options
            dateLabel.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor, constant: 16),
            dateLabel.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor),
            
            datePicker.topAnchor.constraint(equalTo: optionsContainer.topAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor, constant: -16),
            
            // Seats Row inside Options
            seatsLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 24),
            seatsLabel.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor, constant: 16),
            seatsLabel.bottomAnchor.constraint(equalTo: optionsContainer.bottomAnchor, constant: -16),
            
            seatsStepper.centerYAnchor.constraint(equalTo: seatsLabel.centerYAnchor),
            seatsStepper.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor, constant: -16),
            
            // Button (Bottom sticky or below content)
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Helper Styling Methods
    
    private func styleCardView(_ view: UIView) {
        view.backgroundColor = .secondarySystemGroupedBackground // Светлый серый/белый адаптивный
        view.layer.cornerRadius = 16
        // Мягкая тень
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
    }

    private func setupTextField(_ textField: UITextField, placeholder: String, iconName: String, color: UIColor) {
        textField.placeholder = placeholder
        textField.borderStyle = .none // Убираем стандартные рамки
        textField.font = .systemFont(ofSize: 17)
        
        // Создаем контейнер для иконки
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 50))
        iconView.frame = CGRect(x: 10, y: 15, width: 24, height: 20)
        containerView.addSubview(iconView)
        
        textField.leftView = containerView
        textField.leftViewMode = .always
    }

    // MARK: - Logic (Unchanged)
    
    @objc private func seatsChanged() {
        selectedSeats = Int(seatsStepper.value)
        seatsLabel.text = "Seats: \(selectedSeats)"
    }

    @objc private func createRide() {
        guard
            let from = fromField.text, !from.isEmpty,
            let to = toField.text, !to.isEmpty,
            let user = currentUser
        else {
            showAlert("Fill all fields")
            return
        }

        let ride = CoreDataManager.shared.createRide(
            creator: user,
            rideName: "\(from) → \(to)",
            departure: from,
            destination: to,
            scheduledTime: datePicker.date,
            maxPassengers: 4
        )

        if let ride {
            if user.userType == "passenger" {
                ride.currentPassengers = Int32(selectedSeats)
            } else {
                ride.currentPassengers = 0
            }

            ride.driver = nil
            ride.status = "waiting"
            CoreDataManager.shared.saveContext()

        }

        dismiss(animated: true)
    }

    private func showAlert(_ text: String) {
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
