import UIKit
import CoreData

class ActiveRideViewController: UIViewController {

    private let infoLabel = UILabel()
    private let finishButton = UIButton()

    var ride: RideEntity!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fillData()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Active Ride"

        infoLabel.numberOfLines = 0
        infoLabel.font = .systemFont(ofSize: 18)
        infoLabel.textAlignment = .center

        finishButton.setTitle("Finish Ride", for: .normal)
        finishButton.backgroundColor = .systemGreen
        finishButton.setTitleColor(.white, for: .normal)
        finishButton.layer.cornerRadius = 16
        finishButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        finishButton.addTarget(self, action: #selector(finishRide), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [infoLabel, finishButton])
        stack.axis = .vertical
        stack.spacing = 40
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            finishButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func fillData() {
        guard let ride else { return }

        infoLabel.text = """
        🚕 Ride in progress

        📍 From:
        \(ride.departureAddress ?? "")

        🎯 To:
        \(ride.destinationAddress ?? "")

        👥 Seats:
        \(ride.currentPassengers)/\(ride.maxPassengers)
        """
    }

    @objc private func finishRide() {
        ride.status = "finished"
        CoreDataManager.shared.saveContext()

        let ratingVC = RatingViewController()
        ratingVC.ride = ride
        navigationController?.pushViewController(ratingVC, animated: true)
    }
}
