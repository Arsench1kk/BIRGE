import UIKit
import CoreData

class RatingViewController: UIViewController {

    var ride: RideEntity!

    private let titleLabel = UILabel()
    private let starsStack = UIStackView()
    private let submitButton = UIButton()

    private var selectedRating = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Rate Ride"

        titleLabel.text = "How was your ride?"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center

        starsStack.axis = .horizontal
        starsStack.spacing = 12
        starsStack.alignment = .center

        for i in 1...5 {
            let button = UIButton(type: .system)
            button.setTitle("★", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 32)
            button.tag = i
            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starsStack.addArrangedSubview(button)
        }

        updateStars()

        submitButton.setTitle("Submit", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 16
        submitButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        submitButton.addTarget(self, action: #selector(submitRating), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            starsStack,
            submitButton
        ])

        stack.axis = .vertical
        stack.spacing = 32
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStars()
    }

    private func updateStars() {
        for case let button as UIButton in starsStack.arrangedSubviews {
            let filled = button.tag <= selectedRating
            button.setTitleColor(filled ? .systemYellow : .lightGray, for: .normal)
        }
    }

    @objc private func submitRating() {
        // для MVP просто считаем, что оценка сохранена
        let alert = UIAlertController(
            title: "Thank you!",
            message: "You rated this ride \(selectedRating) stars",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismissToRoot()
        })

        present(alert, animated: true)
    }

    private func dismissToRoot() {
        if let nav = navigationController {
            nav.dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
