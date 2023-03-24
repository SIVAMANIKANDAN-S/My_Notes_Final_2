//
//  LargeImageCollectionViewCell.swift
//  My_Notes
//
//  Created by admin on 20/03/23.
//

import UIKit

class LargeImageCollectionViewCell: UICollectionViewCell {
    
    static var largeImageCellReuseIdentifier : String = "largeImageCellReuseIdentifier"
    
    
    lazy var scrollView : UIScrollView = {
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = false
//        scrollView.flashScrollIndicators()
//        scrollView.minimumZoomScale = 1.0
//        scrollView.maximumZoomScale = 10.0
//        scrollView.clipsToBounds = true
        
        return scrollView
    }()
    
    lazy var imageView : UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        return imageView
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .label
        
        self.contentView.addSubview(scrollView)
        scrollView.frame = contentView.bounds
        
        scrollView.delegate = self
        setupImgeView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func setupImgeView() {
        
        imageView.removeFromSuperview()
        doubleTapGesture()
        
        self.contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([ imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor ,constant:20),
                                      imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor ,constant: 10),
                                      imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor , constant: -10),
                                      imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20)])
        
    }
    
    private func setupZoomImgeView() {
        
        self.scrollView.addSubview(imageView)
        
        NSLayoutConstraint.activate([ imageView.topAnchor.constraint(equalTo: self.scrollView.topAnchor ,constant:0),
                                      imageView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor ,constant: 0),
                                      imageView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor , constant: 0),
                                      imageView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor , constant: 0)])
    }
    
    func doubleTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(tap)
    }
    
    
    @objc func doubleTapped() {
        imageView.removeFromSuperview()
        setupZoomImgeView()
    }
}



extension LargeImageCollectionViewCell : UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}



