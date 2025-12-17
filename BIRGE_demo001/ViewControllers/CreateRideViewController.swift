import UIKit
import CoreData

class CreateRideViewController: UIViewController {

    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var seatsStepper: UIStepper!
    @IBOutlet weak var seatsLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "Create New Ride"
        createButton.layer.cornerRadius = 14

        seatsStepper.minimumValue = 1
        seatsStepper.maximumValue = 6
        seatsStepper.value = 4
        seatsLabel.text = "4 seats"
    }

    @IBAction func seatsChanged(_ sender: UIStepper) {
        seatsLabel.text = "\(Int(sender.value)) seats"
    }

    @IBAction func createRideTapped(_ sender: UIButton) {
        guard
            let from = fromTextField.text, !from.isEmpty,
            let to = toTextField.text, !to.isEmpty,
            let user = CoreDataManager.shared.getCurrentUser()
        else {
            showAlert("Fill all fields")
            return
        }

        _ = CoreDataManager.shared.createRide(
            creator: user,
            rideName: "\(from) → \(to)",
            departure: from,
            destination: to,
            scheduledTime: datePicker.date,
            maxPassengers: Int(seatsStepper.value)
        )

        navigationController?.popViewController(animated: true)
    }

    private func showAlert(_ text: String) {
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
