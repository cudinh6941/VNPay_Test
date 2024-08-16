//
//  PicsumTableViewCell.swift
//  VNpay_Test
//
//  Created by pham kha dinh on 15/8/24.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    private var imageTask: URLSessionDataTask?
    private var currentImageURL: String?
    
    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var aspectRatioConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(itemImageView)
        contentView.addSubview(authorLabel)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(sizeLabel)
        
        NSLayoutConstraint.activate([
            itemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            itemImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            itemImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            itemImageView.heightAnchor.constraint(equalToConstant: 300), // Default height
            
            authorLabel.leadingAnchor.constraint(equalTo: itemImageView.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: itemImageView.trailingAnchor),
            authorLabel.topAnchor.constraint(equalTo: itemImageView.bottomAnchor, constant: 10),
            
            sizeLabel.leadingAnchor.constraint(equalTo: itemImageView.leadingAnchor),
            sizeLabel.trailingAnchor.constraint(equalTo: itemImageView.trailingAnchor),
            sizeLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 10),
            sizeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            activityIndicator.centerXAnchor.constraint(equalTo: itemImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: itemImageView.centerYAnchor)
        ])
    }
    
    func configure(with item: ImageItem, viewModel: PicsumViewModel) {
        authorLabel.text = item.author
        sizeLabel.text = "Size: \(item.width) x \(item.height)"
        
        // Remove existing aspect ratio constraint if it exists
        if let existingConstraint = aspectRatioConstraint {
            itemImageView.removeConstraint(existingConstraint)
        }
        
        // Calculate aspect ratio and update constraint
        let aspectRatio = CGFloat(item.height) / CGFloat(item.width)
        aspectRatioConstraint = itemImageView.heightAnchor.constraint(equalTo: itemImageView.widthAnchor, multiplier: aspectRatio)
        aspectRatioConstraint?.isActive = true
        
        // Save current image URL
        let newImageURL = item.download_url
        currentImageURL = newImageURL
        
        // Clear current image and start activity indicator
        itemImageView.image = nil
        activityIndicator.startAnimating()
        
        // Cancel any previous image task
        imageTask?.cancel()
        
        // Download image and update UI
        imageTask = viewModel.downloadImage(from: newImageURL) { [weak self] image in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.itemImageView.image = image
                self.activityIndicator.stopAnimating()
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        itemImageView.image = nil
        currentImageURL = nil
        activityIndicator.stopAnimating()
    }
}

