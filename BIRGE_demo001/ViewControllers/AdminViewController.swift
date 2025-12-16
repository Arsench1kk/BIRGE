import UIKit

class AdminViewController: UIViewController {

    // UI Elements
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
        
        // Настройка таблицы
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
    
    private func loadUsers() {
        users = CoreDataManager.shared.getAllUsers()
        tableView.reloadData()
    }
    
    private func deleteUser(_ user: UserEntity) {
        // Удаляем из CoreData
        CoreDataManager.shared.context.delete(user)
        CoreDataManager.shared.saveContext()
        
        // Обновляем таблицу
        loadUsers()
    }
}

extension AdminViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "UserCell")
        let user = users[indexPath.row]
        
        cell.textLabel?.text = "\(user.firstName ?? "") \(user.lastName ?? "")"
        cell.detailTextLabel?.text = "\(user.userType?.capitalized ?? "") | \(user.email ?? "")"
        
        // Красим водителей в оранжевый, пассажиров в синий
        if user.userType == "driver" {
            cell.imageView?.image = UIImage(systemName: "car.fill")
            cell.imageView?.tintColor = .systemOrange
        } else {
            cell.imageView?.image = UIImage(systemName: "person.fill")
            cell.imageView?.tintColor = .systemBlue
        }
        
        return cell
    }
    
    // Swipe to Delete (Требование CRUD)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let userToDelete = users[indexPath.row]
            
            // Не даем удалить самого себя
            if userToDelete.email == CoreDataManager.shared.getCurrentUser()?.email {
                let alert = UIAlertController(title: "Error", message: "You cannot delete yourself", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
            
            deleteUser(userToDelete)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}