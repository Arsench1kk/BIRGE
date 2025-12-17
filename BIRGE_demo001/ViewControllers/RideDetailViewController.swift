import UIKit
import CoreData

class RideDetailViewController: UIViewController {

    var ride: RideEntity!

    // MARK: - UI Components
    
    // Карточки для группировки контента
    private let routeCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let seatsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 20
        return view
    }()

    // Элементы маршрута (UI)
    private let timeLabel = UILabel()
    private let departureLabel = UILabel()
    private let destinationLabel = UILabel()
    
    // Элементы выбора мест
    private let seatsLabel = UILabel()
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)
    private let confirmButton = UIButton(type: .system)

    // MARK: - Logic Variables
    private var selectedSeats = 1

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateSeats()
        configureData() // Заполняем данные UI
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground // Светло-серый фон для контраста с карточками
        title = "Booking"
        navigationItem.largeTitleDisplayMode = .never

        setupRouteCard()
        setupSeatsCard()
        setupConfirmButton()
        
        // Общий Layout
        [routeCardView, seatsCardView, confirmButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // Карточка маршрута
            routeCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            routeCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            routeCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Карточка мест
            seatsCardView.topAnchor.constraint(equalTo: routeCardView.bottomAnchor, constant: 20),
            seatsCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            seatsCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            seatsCardView.heightAnchor.constraint(equalToConstant: 100),
            
            // Кнопка подтверждения (прибита к низу)
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Custom UI Construction
    
    private func setupRouteCard() {
        // Дата/Время (Header карточки)
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 32, weight: .bold) // Цифровой стиль
        timeLabel.textColor = .label
        
        let dateSubLabel = UILabel()
        dateSubLabel.text = "Scheduled Departure"
        dateSubLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        dateSubLabel.textColor = .secondaryLabel
        dateSubLabel.textAlignment = .left

        // Визуализация линии маршрута (Timeline)
        let topDot = createDotView(color: .systemBlue)
        let bottomPin = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        bottomPin.tintColor = .systemRed
        bottomPin.contentMode = .scaleAspectFit
        
        let lineView = UIView()
        lineView.backgroundColor = .systemGray4
        
        // Адреса
        departureLabel.font = .systemFont(ofSize: 16, weight: .medium)
        departureLabel.numberOfLines = 2
        
        destinationLabel.font = .systemFont(ofSize: 16, weight: .medium)
        destinationLabel.numberOfLines = 2
        
        let fromTitle = createSmallLabel(text: "FROM")
        let toTitle = createSmallLabel(text: "TO")

        // Собираем верстку внутри карточки
        [timeLabel, dateSubLabel, topDot, lineView, bottomPin, departureLabel, destinationLabel, fromTitle, toTitle].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            routeCardView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // Время
            dateSubLabel.topAnchor.constraint(equalTo: routeCardView.topAnchor, constant: 20),
            dateSubLabel.leadingAnchor.constraint(equalTo: routeCardView.leadingAnchor, constant: 20),
            
            timeLabel.topAnchor.constraint(equalTo: dateSubLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: routeCardView.leadingAnchor, constant: 20),
            
            // Timeline
            topDot.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 30),
            topDot.leadingAnchor.constraint(equalTo: routeCardView.leadingAnchor, constant: 24),
            topDot.widthAnchor.constraint(equalToConstant: 12),
            topDot.heightAnchor.constraint(equalToConstant: 12),
            
            bottomPin.topAnchor.constraint(equalTo: topDot.bottomAnchor, constant: 40),
            bottomPin.centerXAnchor.constraint(equalTo: topDot.centerXAnchor),
            bottomPin.widthAnchor.constraint(equalToConstant: 20),
            bottomPin.heightAnchor.constraint(equalToConstant: 20),
            bottomPin.bottomAnchor.constraint(equalTo: routeCardView.bottomAnchor, constant: -24),
            
            lineView.topAnchor.constraint(equalTo: topDot.bottomAnchor),
            lineView.bottomAnchor.constraint(equalTo: bottomPin.topAnchor),
            lineView.centerXAnchor.constraint(equalTo: topDot.centerXAnchor),
            lineView.widthAnchor.constraint(equalToConstant: 2),
            
            // Тексты адресов
            fromTitle.leadingAnchor.constraint(equalTo: topDot.trailingAnchor, constant: 16),
            fromTitle.centerYAnchor.constraint(equalTo: topDot.centerYAnchor, constant: -10),
            
            departureLabel.topAnchor.constraint(equalTo: fromTitle.bottomAnchor, constant: 2),
            departureLabel.leadingAnchor.constraint(equalTo: fromTitle.leadingAnchor),
            departureLabel.trailingAnchor.constraint(equalTo: routeCardView.trailingAnchor, constant: -20),
            
            toTitle.leadingAnchor.constraint(equalTo: bottomPin.trailingAnchor, constant: 12),
            toTitle.centerYAnchor.constraint(equalTo: bottomPin.centerYAnchor, constant: -10),
            
            destinationLabel.topAnchor.constraint(equalTo: toTitle.bottomAnchor, constant: 2),
            destinationLabel.leadingAnchor.constraint(equalTo: toTitle.leadingAnchor),
            destinationLabel.trailingAnchor.constraint(equalTo: routeCardView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupSeatsCard() {
        let titleLabel = UILabel()
        titleLabel.text = "Passengers"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        
        seatsLabel.font = .systemFont(ofSize: 24, weight: .bold)
        seatsLabel.textAlignment = .center
        
        // Стилизация кнопок +/-
        styleCircleButton(minusButton, icon: "minus", color: .systemGray5, tint: .label)
        styleCircleButton(plusButton, icon: "plus", color: .systemBlue, tint: .white)
        
        minusButton.addTarget(self, action: #selector(decrease), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(increase), for: .touchUpInside)
        
        let controlsStack = UIStackView(arrangedSubviews: [minusButton, seatsLabel, plusButton])
        controlsStack.axis = .horizontal
        controlsStack.spacing = 20
        controlsStack.alignment = .center
        
        [titleLabel, controlsStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            seatsCardView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: seatsCardView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: seatsCardView.centerYAnchor),
            
            controlsStack.trailingAnchor.constraint(equalTo: seatsCardView.trailingAnchor, constant: -20),
            controlsStack.centerYAnchor.constraint(equalTo: seatsCardView.centerYAnchor),
            
            minusButton.widthAnchor.constraint(equalToConstant: 44),
            minusButton.heightAnchor.constraint(equalToConstant: 44),
            plusButton.widthAnchor.constraint(equalToConstant: 44),
            plusButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupConfirmButton() {
        confirmButton.setTitle("Confirm Booking", for: .normal)
        confirmButton.backgroundColor = .systemBlue
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 16
        confirmButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        // Тень для кнопки
        confirmButton.layer.shadowColor = UIColor.systemBlue.cgColor
        confirmButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        confirmButton.layer.shadowOpacity = 0.3
        confirmButton.layer.shadowRadius = 8
        confirmButton.addTarget(self, action: #selector(confirmBooking), for: .touchUpInside)
    }

    private func configureData() {
        departureLabel.text = ride.departureAddress
        destinationLabel.text = ride.destinationAddress
        
        // Форматирование времени отдельно для красоты
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeLabel.text = formatter.string(from: ride.scheduledTime ?? Date())
    }

    // MARK: - Helpers
    
    private func createDotView(color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 6 // половина от 12
        return view
    }
    
    private func createSmallLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .systemGray2
        return label
    }
    
    private func styleCircleButton(_ button: UIButton, icon: String, color: UIColor, tint: UIColor) {
        button.setImage(UIImage(systemName: icon), for: .normal)
        button.backgroundColor = color
        button.tintColor = tint
        button.layer.cornerRadius = 22 // половина от 44
    }

    // MARK: - Original Logic (Unchanged)

    private func updateSeats() {
        seatsLabel.text = "\(selectedSeats)" // Убрал слово "Seats" для чистоты дизайна, оно теперь в заголовке
    }

    @objc private func decrease() {
        if selectedSeats > 1 {
            selectedSeats -= 1
            updateSeats()
        }
    }

    @objc private func increase() {
        let available = Int(ride.maxPassengers - ride.currentPassengers)
        if selectedSeats < available {
            selectedSeats += 1
            updateSeats()
        }
    }

    @objc private func confirmBooking() {
        guard let user = CoreDataManager.shared.getCurrentUser() else { return }

        let result = CoreDataManager.shared.createBooking(
            passenger: user,
            ride: ride,
            pickupLocation: ride.departureAddress ?? "",
            passengerCount: selectedSeats
        )

        guard result.success else { return }

        let activeVC = ActiveRideViewController()
        activeVC.ride = ride
        navigationController?.pushViewController(activeVC, animated: true)
    }
}
