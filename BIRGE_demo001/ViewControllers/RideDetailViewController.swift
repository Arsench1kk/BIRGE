import UIKit
import CoreData

class RideDetailViewController: UIViewController {

    // MARK: - Properties
    var ride: RideEntity!
    private let coreDataManager = CoreDataManager.shared

    // MARK: - UI
    private let stackView = UIStackView()
    private let fromLabel = UILabel()
    private let toLabel = UILabel()
    private let timeLabel = UILabel()
    private let seatsLabel = UILabel()
    private let statusLabel = UILabel()
    private let joinButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Ride Details"

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        [fromLabel, toLabel, timeLabel, seatsLabel, statusLabel, joinButton].forEach {
            stackView.addArrangedSubview($0)
        }

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        fromLabel.font = .systemFont(ofSize: 16)
        toLabel.font = .systemFont(ofSize: 16)
        timeLabel.font = .systemFont(ofSize: 16)
        seatsLabel.font = .systemFont(ofSize: 16)
        statusLabel.font = .systemFont(ofSize: 16, weight: .medium)

        joinButton.setTitle("Join Ride", for: .normal)
        joinButton.backgroundColor = .systemBlue
        joinButton.setTitleColor(.white, for: .normal)
        joinButton.layer.cornerRadius = 12
        joinButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        joinButton.addTarget(self, action: #selector(joinRideTapped), for: .touchUpInside)
    }

    // MARK: - Data
    private func populateData() {
        guard let ride = ride else { return }

        fromLabel.text = "📍 From: \(ride.departureAddress ?? "-")"
        toLabel.text = "🎯 To: \(ride.destinationAddress ?? "-")"

        if let date = ride.scheduledTime {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            timeLabel.text = "🕒 \(formatter.string(from: date))"
        }

        seatsLabel.text = "👥 Seats: \(ride.currentPassengers)/\(ride.maxPassengers)"
        statusLabel.text = "⏳ Status: \(ride.status ?? "waiting")"

        if ride.currentPassengers >= ride.maxPassengers {
            joinButton.isEnabled = false
            joinButton.backgroundColor = .systemGray
            joinButton.setTitle("No Seats Available", for: .normal)
        }
    }

    // MARK: - Actions
    @objc private func joinRideTapped() {
        guard let user = coreDataManager.getCurrentUser() else {
            showAlert(title: "Error", message: "User not found")
            return
        }

        let result = coreDataManager.createBooking(
            passenger: user,
            ride: ride,
            pickupLocation: ride.departureAddress ?? "",
            passengerCount: 1
        )

        if result.success {
            showAlert(title: "Success", message: "You joined the ride!") {
                self.dismiss(animated: true)
            }
        } else {
            showAlert(title: "Error", message: result.message)
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
