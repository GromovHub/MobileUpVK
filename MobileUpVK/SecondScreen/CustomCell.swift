//
//  Project name: MobileUpVK
//  File name: CustomCell.swift
//
//  Copyright © Gromov V.O., 2024
//
import UIKit

class CustomCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let label: PaddedLabel = {
        let lbl = PaddedLabel()
        lbl.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        lbl.textColor = .black
        lbl.layer.cornerRadius = 16
        lbl.font = .systemFont(ofSize: 12)
        lbl.clipsToBounds = true
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        contentView.addSubview(label)
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.8).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
