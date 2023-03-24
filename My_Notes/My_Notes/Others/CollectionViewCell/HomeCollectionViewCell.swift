//
//  HomeCollectionViewCell.swift
//  My_Notes
//
//  Created by admin on 20/03/23.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    static let reuseCellIdentifier: String = "HomeCollectionViewCell"
    
    
    private var backGroundColors : [UIColor] = [.systemRed , .systemGray2 , .systemGreen , .systemBlue , .systemCyan , .systemMint , .systemPink , .systemBrown , .systemPurple , .systemYellow , .systemOrange]
    
    private lazy var cellBackgropundView : UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    } ()
    
    private lazy var titleLabel : UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .light)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    } ()
    
    private lazy var timeLabel : UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .right
        label.backgroundColor = .clear
        label.numberOfLines = 1
        return label
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCellBackgroundView()
        
        setupTimeLabel()
        
        setupTitleLabel()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupCellBackgroundView() {
        
        self.contentView.addSubview(cellBackgropundView)
        
        NSLayoutConstraint.activate( [ cellBackgropundView.topAnchor.constraint(equalTo: self.contentView.topAnchor , constant: 0),
                                       cellBackgropundView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor , constant: 10),
                                       cellBackgropundView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
                                       cellBackgropundView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor , constant: 0) ] )
    }
    
    private func setupTitleLabel() {
        
        self.cellBackgropundView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate( [ titleLabel.topAnchor.constraint(equalTo: self.cellBackgropundView.topAnchor , constant: 20),
                                       titleLabel.leadingAnchor.constraint(equalTo: self.cellBackgropundView.leadingAnchor,constant: 0),
                                       titleLabel.trailingAnchor.constraint(equalTo: self.cellBackgropundView.trailingAnchor , constant: -10),
                                       titleLabel.bottomAnchor.constraint(equalTo: self.timeLabel.topAnchor) ] )
    }
    
    
    private func setupTimeLabel () {
        
        self.cellBackgropundView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([ timeLabel.bottomAnchor.constraint(equalTo: self.cellBackgropundView.bottomAnchor,
                                                                        constant: 0) ,
                                      timeLabel.leadingAnchor.constraint(equalTo: self.cellBackgropundView.leadingAnchor ,              constant: 20 ) ,
                                      timeLabel.trailingAnchor.constraint(equalTo: self.cellBackgropundView.trailingAnchor ,            constant: -20),
                                      timeLabel.heightAnchor.constraint(equalToConstant: 30)] )
    }
    
    func addValuesToLabels (title : String , time : String) {
        
        let color = backGroundColors[Int.random(in: 0..<backGroundColors.count)]
        
        self.titleLabel.text = title
        self.timeLabel.text  = time
        self.cellBackgropundView.backgroundColor = color //UIColor(red: 180 / 255, green: 100 / 255, blue: 288 / 255, alpha: 0.7)
        
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        titleLabel.preferredMaxLayoutWidth = layoutAttributes.size.width - contentView.layoutMargins.left - contentView.layoutMargins.left
        layoutAttributes.bounds.size.height = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        return layoutAttributes
    }
}



