import UIKit

class RideTableViewCell: UITableViewCell {

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var seatsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none

        // Карточка
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        containerView.backgroundColor = .systemBackground
    }

    // MARK: - Configuration
    func configure(with ride: RideEntity) {

        fromLabel.text = "From: \(ride.departureAddress ?? "")"
        toLabel.text = "To: \(ride.destinationAddress ?? "")"

        if let date = ride.scheduledTime {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            timeLabel.text = formatter.string(from: date)
        } else {
            timeLabel.text = "—"
        }

        seatsLabel.text = "\(ride.currentPassengers)/\(ride.maxPassengers) seats"

        // Цена — статичная (как в макете)
        priceLabel.text = "900 ₸"

        if let driver = ride.creator {
            driverLabel.text = "Driver: \(driver.firstName ?? "")"
        } else {
            driverLabel.text = "Driver: —"
        }
    }

}
