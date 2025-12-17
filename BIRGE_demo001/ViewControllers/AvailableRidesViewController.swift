import UIKit

class AvailableRidesViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar! // Если добавил SearchBar
    @IBOutlet weak var filterButton: UIBarButtonItem! // Кнопка в навбаре
    
    // MARK: - Properties
    var rides: [RideEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupNavBar() {
        title = "Available Rides"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        // Регистрируем ячейку, если используем прототип из сториборда, то это не обязательно,
        // но убедись, что Identifier в сториборде = "RideCell"
    }
    
    private func loadData() {
        rides = CoreDataManager.shared.getAvailableRides()
        tableView.reloadData()
    }
    
    @IBAction func filterTapped(_ sender: Any) {
        // Здесь будет код открытия фильтра
        let alert = UIAlertController(title: "Filter", message: "Filter options coming soon", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - TableView Extensions
extension AvailableRidesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Убедись, что в Storyboard у ячейки Identifier "RideCell" и класс RideTableViewCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RideCell", for: indexPath) as? RideTableViewCell else {
            return UITableViewCell()
        }
        
        let ride = rides[indexPath.row]
        cell.configure(with: ride)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Логика бронирования
        let ride = rides[indexPath.row]
        showBookingAlert(for: ride)
    }
    
    private func showBookingAlert(for ride: RideEntity) {
        let alert = UIAlertController(title: "Book Ride", message: "Join ride to \(ride.destinationAddress ?? "")?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Join", style: .default, handler: { _ in
            if let user = CoreDataManager.shared.getCurrentUser() {
                _ = CoreDataManager.shared.bookRide(passenger: user, ride: ride, seats: 1)
                self.loadData() // Обновить счетчик мест
            }
        }))
        present(alert, animated: true)
    }
}