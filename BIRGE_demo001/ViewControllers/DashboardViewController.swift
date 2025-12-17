import UIKit
import MapKit
import CoreData

class DashboardViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var createRideButton: UIButton!

    var currentUser: UserEntity?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
    }

    private func setupUI() {
        createRideButton.layer.cornerRadius = 12

        if let user = currentUser {
            welcomeLabel.text = "Welcome, \(user.firstName ?? "User")!"
        } else {
            welcomeLabel.text = "Welcome!"
        }
    }

    private func setupMap() {
        // Центр карты — Алматы (статично, без логики)
        let coordinate = CLLocationCoordinate2D(latitude: 43.2389, longitude: 76.8897)
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        mapView.setRegion(region, animated: false)
    }

    @IBAction func createRideTapped(_ sender: UIButton) {
        let vc = CreateRideViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }




    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
