import UIKit
import CoreData

class AdminViewController: UIViewController {

    private let tableView = UITableView()
    private var users: [UserEntity] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUsers()
    }

    private func setupUI() {
        title = "Admin Panel"
        view.backgroundColor = .systemBackground

        // Кнопка закрытия
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

        // Таблица
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private func loadUsers() {
        users = CoreDataManager.shared.getAllUsers()
        tableView.reloadData()
    }

    private func deleteUser(_ user: UserEntity) {
        CoreDataManager.shared.context.delete(user)
        CoreDataManager.shared.saveContext()
        loadUsers()
    }
}

// MARK: - UITableViewDataSource & Delegate
extension AdminViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "UserCell",
            for: indexPath
        )

        let user = users[indexPath.row]

        cell.textLabel?.text = "\(user.firstName ?? "") \(user.lastName ?? "")"
        cell.detailTextLabel?.text = "\(user.userType?.capitalized ?? "") | \(user.email ?? "")"

        if user.userType == "driver" {
            cell.imageView?.image = UIImage(systemName: "car.fill")
            cell.imageView?.tintColor = .systemOrange
        } else {
            cell.imageView?.image = UIImage(systemName: "person.fill")
            cell.imageView?.tintColor = .systemBlue
        }

        cell.selectionStyle = .none
        return cell
    }

    // Swipe to delete
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }

        let userToDelete = users[indexPath.row]

        // Запрет удаления самого себя
        if userToDelete.email == CoreDataManager.shared.getCurrentUser()?.email {
            let alert = UIAlertController(
                title: "Error",
                message: "You cannot delete yourself",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        deleteUser(userToDelete)
    }
}
