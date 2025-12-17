import UIKit
import CoreData

class AvailableRidesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIButton!

    private var rides: [RideEntity] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTableView()
        setupSearchBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRides()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func setupNavBar() {
        title = "Available Rides"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search destination"
    }

    // MARK: - Data
    private func loadRides() {
        rides = CoreDataManager.shared.getAvailableRides()
        tableView.reloadData()
    }

    // MARK: - Actions
    @IBAction func filterTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Filter",
            message: "Filters will be added later",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension AvailableRidesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RideCell",
            for: indexPath
        ) as? RideTableViewCell else {
            return UITableViewCell()
        }

        let ride = rides[indexPath.row]

        // Минимальная, безопасная конфигурация
        cell.configure(with: ride)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let ride = rides[indexPath.row]

        let detailVC = RideDetailViewController()
        detailVC.ride = ride

        let nav = UINavigationController(rootViewController: detailVC)
        present(nav, animated: true)
    }

}

// MARK: - Booking
extension AvailableRidesViewController {

    private func showBookingAlert(for ride: RideEntity) {
        let alert = UIAlertController(
            title: "Book Ride",
            message: "Join ride to \(ride.destinationAddress ?? "")?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)

            let ride = rides[indexPath.row]

            let vc = RideDetailViewController()
            vc.ride = ride
            navigationController?.pushViewController(vc, animated: true)
        }




        present(alert, animated: true)
    }
}

// MARK: - UISearchBarDelegate (пока без логики)
extension AvailableRidesViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
