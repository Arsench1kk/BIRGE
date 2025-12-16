import UIKit
import CoreData

class DashboardViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var userTypeLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var carInfoLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var availableRidesLabel: UILabel!
    @IBOutlet weak var ridesTableView: UITableView!
    @IBOutlet weak var createRideButton: UIButton!
    @IBOutlet weak var myBookingsButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    // MARK: - Properties
    var currentUser: UserEntity?
    private let coreDataManager = CoreDataManager.shared
    private var availableRides: [RideEntity] = []
    private var myRides: [RideEntity] = []
    private var refreshTimer: Timer?
    
    private enum DisplayMode {
        case availableRides
        case myRides
        case myBookings
    }
    
    private var currentMode: DisplayMode = .availableRides
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayUserInfo()
        loadData()
        startAutoRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "BIRGE Dashboard"
        
        // Configure buttons
        logoutButton.backgroundColor = .systemRed
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.layer.cornerRadius = 8
        
        createRideButton.backgroundColor = .systemGreen
        createRideButton.setTitleColor(.white, for: .normal)
        createRideButton.layer.cornerRadius = 8
        
        myBookingsButton.backgroundColor = .systemBlue
        myBookingsButton.setTitleColor(.white, for: .normal)
        myBookingsButton.layer.cornerRadius = 8
        
        refreshButton.backgroundColor = .systemOrange
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.layer.cornerRadius = 8
        
        // Configure table view
        ridesTableView.dataSource = self
        ridesTableView.delegate = self
        ridesTableView.register(RideTableViewCell.self, forCellReuseIdentifier: "RideCell")
        ridesTableView.rowHeight = UITableView.automaticDimension
        ridesTableView.estimatedRowHeight = 100
        
        // Hide create ride button for drivers
        if currentUser?.userType == "driver" {
            createRideButton.isHidden = true
        }
        
        carInfoLabel.isHidden = true
        
        // Add pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        ridesTableView.refreshControl = refreshControl
    }
    
    private func displayUserInfo() {
        guard let user = currentUser else { return }
        
        welcomeLabel.text = "Welcome, \(user.firstName ?? "") \(user.lastName ?? "")!"
        userTypeLabel.text = "Type: \(user.userType?.capitalized ?? "User")"
        emailLabel.text = "📧 \(user.email ?? "")"
        phoneLabel.text = "📱 \(user.phone ?? "")"
        ratingLabel.text = String(format: "⭐️ %.1f", user.avgRating)
        
        // Show driver-specific info
        if user.userType == "driver", let driverProfile = coreDataManager.getDriverProfile(for: user) {
            carInfoLabel.isHidden = false
            carInfoLabel.text = "🚗 \(driverProfile.carModel ?? "") (\(driverProfile.carPlate ?? "")) - \(driverProfile.maxCapacity) seats"
        } else {
            carInfoLabel.isHidden = true
        }
    }
    
    private func loadData() {
        switch currentMode {
        case .availableRides:
            loadAvailableRides()
        case .myRides:
            loadMyRides()
        case .myBookings:
            loadMyBookings()
        }
    }
    
    private func loadAvailableRides() {
        availableRides = coreDataManager.getAvailableRides()
        
        // Filter out rides created by current user
        if let user = currentUser {
            availableRides = availableRides.filter { $0.creator != user }
        }
        
        availableRidesLabel.text = "Available Rides: \(availableRides.count)"
        createRideButton.setTitle("+ Create Ride", for: .normal)
        ridesTableView.reloadData()
    }
    
    private func loadMyRides() {
        guard let user = currentUser else { return }
        myRides = coreDataManager.getRidesCreatedByUser(user)
        availableRidesLabel.text = "My Created Rides: \(myRides.count)"
        createRideButton.setTitle("Back to Available", for: .normal)
        ridesTableView.reloadData()
    }
    
    private func loadMyBookings() {
        guard let user = currentUser else { return }
        let bookings = coreDataManager.getBookingsForUser(user)
        availableRides = bookings.compactMap { $0.ride }
        availableRidesLabel.text = "My Bookings: \(availableRides.count)"
        ridesTableView.reloadData()
    }
    
    private func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.loadData()
        }
    }
    
    @objc private func handleRefresh() {
        loadData()
        ridesTableView.refreshControl?.endRefreshing()
    }
    
    // MARK: - Actions
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    @IBAction func createRideButtonTapped(_ sender: UIButton) {
        if currentMode == .myRides {
            currentMode = .availableRides
            loadData()
        } else {
            showCreateRideAlert()
        }
    }
    
    @IBAction func myBookingsButtonTapped(_ sender: UIButton) {
        if currentMode == .myBookings {
            currentMode = .availableRides
            myBookingsButton.setTitle("My Bookings", for: .normal)
        } else {
            currentMode = .myBookings
            myBookingsButton.setTitle("Back to Rides", for: .normal)
        }
        loadData()
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        loadData()
        showToast(message: "Refreshed")
    }
    
    // MARK: - Logout
    private func performLogout() {
        AuthService.shared.logout()
        showLoginScreen()
    }
    
    private func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            let navController = UINavigationController(rootViewController: loginVC)
            navController.modalPresentationStyle = .fullScreen
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = navController
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
    }
    
    // MARK: - Create Ride
    private func showCreateRideAlert() {
        let alert = UIAlertController(title: "Create New Ride", message: "Enter ride details", preferredStyle: .alert)
        
        alert.addTextField { $0.placeholder = "Ride Name (e.g., Home - Work)" }
        alert.addTextField { $0.placeholder = "Departure Address" }
        alert.addTextField { $0.placeholder = "Destination Address" }
        alert.addTextField {
            $0.placeholder = "Max Passengers"
            $0.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Next: Choose Time", style: .default) { [weak self] _ in
            guard let self = self,
                  let name = alert.textFields?[0].text, !name.isEmpty,
                  let departure = alert.textFields?[1].text, !departure.isEmpty,
                  let destination = alert.textFields?[2].text, !destination.isEmpty,
                  let maxPassengersText = alert.textFields?[3].text,
                  let maxPassengers = Int(maxPassengersText) else {
                self?.showError("Please fill all fields correctly")
                return
            }
            
            self.showDateTimePicker(name: name, departure: departure, destination: destination, maxPassengers: maxPassengers)
        })
        
        present(alert, animated: true)
    }
    
    private func showDateTimePicker(name: String, departure: String, destination: String, maxPassengers: Int) {
        let datePickerVC = UIViewController()
        datePickerVC.preferredContentSize = CGSize(width: 320, height: 300)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        datePicker.frame = CGRect(x: 0, y: 0, width: 320, height: 250)
        datePickerVC.view.addSubview(datePicker)
        
        let alert = UIAlertController(title: "Select Ride Time", message: nil, preferredStyle: .alert)
        alert.setValue(datePickerVC, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            self?.createRide(name: name, departure: departure, destination: destination,
                           maxPassengers: maxPassengers, scheduledTime: datePicker.date)
        })
        
        present(alert, animated: true)
    }
    
    private func createRide(name: String, departure: String, destination: String, maxPassengers: Int, scheduledTime: Date) {
        guard let user = currentUser else { return }
        
        if let _ = coreDataManager.createRide(
            creator: user,
            rideName: name,
            departure: departure,
            destination: destination,
            scheduledTime: scheduledTime,
            maxPassengers: maxPassengers
        ) {
            showSuccess("Ride created successfully!")
            currentMode = .myRides
            loadData()
        } else {
            showError("Failed to create ride")
        }
    }
    
    // MARK: - Booking
    private func bookRide(_ ride: RideEntity) {
        guard let user = currentUser else { return }
        
        let alert = UIAlertController(title: "Book Ride",
                                     message: "How many passengers?",
                                     preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Number of passengers (1-\(ride.maxPassengers - ride.currentPassengers))"
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Book", style: .default) { [weak self] _ in
            guard let passengerCountText = alert.textFields?[0].text,
                  let passengerCount = Int(passengerCountText) else {
                self?.showError("Invalid passenger count")
                return
            }
            
            let result = self?.coreDataManager.createBooking(
                passenger: user,
                ride: ride,
                pickupLocation: ride.departureAddress ?? "",
                passengerCount: passengerCount
            )
            
            if result?.success == true {
                self?.showSuccess(result?.message ?? "Booking successful!")
                self?.loadData()
            } else {
                self?.showError(result?.message ?? "Booking failed")
            }
        })
        
        present(alert, animated: true)
    }
    
    private func deleteRide(_ ride: RideEntity) {
        let alert = UIAlertController(title: "Delete Ride",
                                     message: "Are you sure you want to delete this ride?",
                                     preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            if self?.coreDataManager.deleteRide(ride) == true {
                self?.showSuccess("Ride deleted")
                self?.loadData()
            } else {
                self?.showError("Failed to delete ride")
            }
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - UI Helpers
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccess(_ message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: 20, y: view.frame.height - 100,
                                               width: view.frame.width - 40, height: 50))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}

// MARK: - UITableView DataSource & Delegate
extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentMode == .myRides {
            return myRides.count
        }
        return availableRides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RideCell", for: indexPath)
        let ride = currentMode == .myRides ? myRides[indexPath.row] : availableRides[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        content.text = ride.rideName
        content.secondaryText = """
        📍 \(ride.departureAddress ?? "") → \(ride.destinationAddress ?? "")
        👥 \(ride.currentPassengers)/\(ride.maxPassengers) passengers
        💰 \(ride.groupDiscountPercent)% discount
        🕐 \(dateFormatter.string(from: ride.scheduledTime ?? Date()))
        """
        
        content.secondaryTextProperties.numberOfLines = 0
        cell.contentConfiguration = content
        
        if currentMode == .myRides {
            cell.accessoryType = .detailButton
        } else if currentUser?.userType == "passenger" {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let ride = currentMode == .myRides ? myRides[indexPath.row] : availableRides[indexPath.row]
        
        if currentMode == .myRides {
            showRideDetails(ride)
        } else if currentUser?.userType == "passenger" {
            bookRide(ride)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard currentMode == .myRides else { return nil }
        
        let ride = myRides[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.deleteRide(ride)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func showRideDetails(_ ride: RideEntity) {
        let bookings = coreDataManager.getBookingsForUser(currentUser!)
        let rideBookings = bookings.filter { $0.ride == ride }
        
        let message = """
        Status: \(ride.status ?? "")
        Created: \(DateFormatter.localizedString(from: ride.createdAt ?? Date(), dateStyle: .short, timeStyle: .short))
        Bookings: \(rideBookings.count)
        """
        
        let alert = UIAlertController(title: ride.rideName, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteRide(ride)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - Custom Cell
class RideTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.numberOfLines = 0
        detailTextLabel?.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
