import UIKit

final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    var onToggle: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(containerView)
        containerView.addSubview(emojiLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(countLabel)
        containerView.addSubview(toggleButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            countLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            countLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            toggleButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            toggleButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            toggleButton.widthAnchor.constraint(equalToConstant: 34),
            toggleButton.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        toggleButton.addAction(UIAction { [weak self] _ in
            self?.onToggle?()
        }, for: .touchUpInside)
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, completedCount: Int) {
        containerView.backgroundColor = tracker.color.withAlphaComponent(0.3)
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        countLabel.text = "\(completedCount) \(russianDayPlural(completedCount))"
        
        let imageName = isCompleted ? "checkmark" : "plus"
        let image = UIImage(systemName: imageName)
        toggleButton.setImage(image, for: .normal)
        toggleButton.backgroundColor = tracker.color
        toggleButton.tintColor = .white
        
        contentView.alpha = isCompleted ? 0.6 : 1.0
    }
    
    private func russianDayPlural(_ count: Int) -> String {
        let mod10 = count % 10
        let mod100 = count % 100
        if mod10 == 1 && mod100 != 11 { return "день" }
        if (2...4).contains(mod10) && !(12...14).contains(mod100) { return "дня" }
        return "дней"
    }
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		nil
	}
}
