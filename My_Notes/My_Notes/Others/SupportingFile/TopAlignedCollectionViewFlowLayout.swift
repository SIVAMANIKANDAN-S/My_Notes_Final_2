//
//  TopAlignedCollectionViewFlowLayout.swift
//  My_Notes
//
//  Created by admin on 22/03/23.
//

import Foundation
import UIKit


//
//func findString(string : String ) -> String {
//    var text = ""
//    let startin = string.firstIndex(of: "[")
//    let endin = string.firstIndex(of: ")")
//    
//    if let start = startin , let end = endin {
//        
//        let text = string[start...end]
//    }
//    
//    return text
//}

class TopAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        self.sectionInset = UIEdgeInsets(top: 20.0,left: 20.0,bottom: 20.0,right: 20.0)
        let attributes = super.layoutAttributesForElements(in: rect)?
            .map { $0.copy() } as? [UICollectionViewLayoutAttributes]
        
        attributes?
            .reduce([CGFloat: (CGFloat, [UICollectionViewLayoutAttributes])]()) {
                guard $1.representedElementCategory == .cell else { return $0 }
                return $0.merging([ceil($1.center.y): ($1.frame.origin.y, [$1])]) {
                    ($0.0 < $1.0 ? $0.0 : $1.0, $0.1 + $1.1)
                }
            }
            .values.forEach { minY, line in
                line.forEach {
                    $0.frame = $0.frame.offsetBy(
                        dx: 0,
                        dy: minY - $0.frame.origin.y
                    )
                }
            }
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        
        
        return attributes
    }
}



// ReQIRED LAYOUT


protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class ReqiuredLayOut : UICollectionViewLayout {
    // 1
    weak var delegate: PinterestLayoutDelegate?
    
    // 2
    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 10
    
    // 3
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    // 4
    private var contentHeight: CGFloat = 0
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    // 5
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        // 1
        guard cache.isEmpty == true, let collectionView = collectionView
        else { return }
        
        // 2
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        // 3
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            // 4
            let photoHeight = delegate?.collectionView(
                collectionView, heightForPhotoAtIndexPath: indexPath
            ) ?? 180
            
            let height = cellPadding * 2 + photoHeight
            
            let frame = CGRect(
                x: xOffset[column],
                y: yOffset[column],
                width: columnWidth,
                height: height
            )
            
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            // 5
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            // 6
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}





// AddVC With ScrollView

//
//  AddNewNoteViewController.swift
//  My_Notes
//
//  Created by admin on 18/03/23.
//

//import UIKit
//
//import PhotosUI
//
//class AddNewNoteViewController: UIViewController {
//
//    var notes = [Notes]()
//
//    var currentNote : Notes?
//
//    var currentObjectIndex : Int = 0
//
//    private var notesImageviewConstriants : [NSLayoutConstraint]?
//
//    private var titleConstraintsWithImage : [NSLayoutConstraint]?
//
//    private var titleConstraintsWithoutImage : [NSLayoutConstraint]?
//
//    private var descriptionConstriants : [NSLayoutConstraint]?
//
//
//    private lazy var backgroundView : UIView = {
//
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .clear
//        return view
//    } ()
//
//    private lazy var backButton : UIButton = {
//
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//        button.backgroundColor = .gray
//        button.layer.cornerRadius = 15
//        button.layer.masksToBounds = true
//        button.tintColor = .white
//
//        return button
//    } ()
//
//    private lazy var attachButton : UIButton = {
//
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
//        button.backgroundColor = .gray
//        button.layer.cornerRadius = 15
//        button.layer.masksToBounds = true
//        button.tintColor = .white
//
//        return button
//    } ()
//
//    private lazy var deleteButton : UIButton = {
//
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle("Clear", for: .normal)
//        button.titleLabel?.textColor = .white
//        button.backgroundColor = .gray
//        button.layer.cornerRadius = 15
//        button.layer.masksToBounds = true
//        button.tintColor = .white
//
//        return button
//    } ()
//
//    private lazy var saveButton : UIButton = {
//
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle("Save", for: .normal)
//        button.titleLabel?.textColor = .white
//        button.backgroundColor = .gray
//        button.layer.cornerRadius = 15
//        button.layer.masksToBounds = true
//        button.tintColor = .white
//
//        return button
//    } ()
//
//    private lazy var scrollView : UIScrollView = {
//
//        let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//
//        scrollView.backgroundColor = .cyan
//        scrollView.showsVerticalScrollIndicator = false
//        return scrollView
//    } ()
//
//    private lazy var notesImage : UIImageView = {
//
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.backgroundColor = .clear
//        imageView.layer.cornerRadius = 20
//        imageView.layer.masksToBounds = true
//        imageView.layer.borderColor = UIColor.white.cgColor
//        imageView.layer.borderWidth = 2
//        imageView.layer.shadowColor = UIColor.gray.cgColor
//        imageView.layer.shadowRadius = 3
//        imageView.layer.shadowOpacity = 0.7
//        imageView.isUserInteractionEnabled = true
//        return imageView
//    } ()
//
//    private lazy var titleTextView : UITextView = {
//
//        let textView = UITextView()
//        textView.backgroundColor = .clear
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        textView.layer.borderWidth = 0
//        textView.text = "  Title..!"
//        textView.textColor = .systemGray3
//        textView.font = .systemFont(ofSize: 30, weight: .semibold)
//        textView.keyboardAppearance = .alert
//        textView.keyboardType = .default
//        return textView
//    } ()
//
//    private lazy var descriptionTextView : UITextView = {
//
//        let textView = UITextView()
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        textView.text = "  Note here . . . . ."
//        textView.textColor = .systemGray3
//        textView.backgroundColor = .clear
//        textView.layer.borderWidth = 0
//        textView.font = .systemFont(ofSize: 20, weight: .regular)
//        textView.keyboardAppearance = .alert
//        textView.keyboardType = .default
//        return textView
//    } ()
//
//    lazy var largeImageCollectionView : UICollectionView = {
//
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        collectionView.alwaysBounceHorizontal = true
//        collectionView.backgroundColor = UIColor(red: 41 / 255, green: 42 / 255, blue: 47 / 255, alpha: 1)
//        return collectionView
//
//    } ()
//
//    lazy var referanceView : UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .clear
//        return view
//    } ()
//
//    private var detailedView : Bool = false
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.view.backgroundColor = UIColor(red: 41 / 255, green: 42 / 255 , blue: 47 / 255 , alpha: 1)
//
//        self.navigationController?.navigationBar.isHidden = true
//
//        backButton.addTarget(self, action: #selector(backToHomeVC), for: .touchUpInside)
//
//        if attachButton.allTargets.count == 0 {
//
//            attachButton.addTarget(self, action: #selector(addImageToNotes), for: .touchUpInside)
//        }
//
//        actionButtonsConstriants()
//
//        addReferanceViewCopnstraints()
//
//        addScrollView()
//
//        setupConstriantValues()
//
//        configureConstraintsWithoutImage()
//
//        titleTextView.delegate = self
//
//        descriptionTextView.delegate = self
//
//        if detailedView {
//            setupLargeImageCollectioView()
//            deleteButton.setTitle("Delete", for: .normal)
//            deleteButton.addTarget(self, action: #selector(deleteNote), for: .touchUpInside)
//        }
//        else {
//            deleteButton.addTarget(self, action: #selector(clear(sender:)), for: .touchUpInside)
//            saveButton.addTarget(self, action: #selector(saveNote), for: .touchUpInside)
//        }
//
//    }
//
//    func actionButtonsConstriants () {
//
//        self.view.addSubview(backgroundView)
//        self.backgroundView.addSubview(backButton)
//        self.backgroundView.addSubview(deleteButton)
//        self.backgroundView.addSubview(attachButton)
//        self.backgroundView.addSubview(saveButton)
//
//        NSLayoutConstraint.activate([backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//                                     backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//                                     backgroundView.heightAnchor.constraint(equalToConstant: 50),
//                                     backgroundView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor , constant: 20)])
//
//        NSLayoutConstraint.activate([backButton.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor , constant: 20),
//                                     backButton.widthAnchor.constraint(equalToConstant: 50),
//                                     backButton.heightAnchor.constraint(equalToConstant: 50),
//                                     backButton.topAnchor.constraint(equalTo: self.backgroundView.topAnchor)])
//
//        NSLayoutConstraint.activate([deleteButton.widthAnchor.constraint(equalToConstant: 100),
//                                     deleteButton.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor , constant: 20),
//                                     deleteButton.heightAnchor.constraint(equalToConstant: 50),
//                                     deleteButton.topAnchor.constraint(equalTo: self.backgroundView.topAnchor)])
//
//        NSLayoutConstraint.activate([saveButton.widthAnchor.constraint(equalToConstant: 100),
//                                     saveButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor , constant: -20),
//                                     saveButton.heightAnchor.constraint(equalToConstant: 50),
//                                     saveButton.topAnchor.constraint(equalTo: self.backgroundView.topAnchor)])
//
//        NSLayoutConstraint.activate([attachButton.widthAnchor.constraint(equalToConstant: 50),
//                                     attachButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor , constant: -20),
//                                     attachButton.heightAnchor.constraint(equalToConstant: 50),
//                                     attachButton.topAnchor.constraint(equalTo: self.backgroundView.topAnchor)])
//    }
//
//    func addScrollView () {
//
//        self.view.addSubview(scrollView)
//
//        NSLayoutConstraint.activate([scrollView.topAnchor.constraint(equalTo: backgroundView.bottomAnchor , constant:  5) ,
//                                     scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                                     scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//                                     scrollView.bottomAnchor.constraint(equalTo: self.view.keyboardLayoutGuide.topAnchor)])
//    }
//
//    @objc private func backToHomeVC (_ sender : UIButton) {
//
//        if titleTextView.text == "" {
//            titleTextView.text = "  Title..!"
//        }
//
//        if descriptionTextView.text == "" {
//            descriptionTextView.text = "  Note here . . . . ."
//        }
//
//        if detailedView {
//            guard let  note = self.currentNote else { return }
//            if (self.descriptionTextView.text != note.descriptions) || (self.titleTextView.text != note.title) || (self.notesImage.image?.pngData() != note.noteImage) {
//                discardChanges()
//
//            }
//        }
//
//        else if self.descriptionTextView.text != "  Note here . . . . ." || self.titleTextView.text != "  Title..!"  || notesImage.image != nil {
//            discardChanges()
//        }
//
//        else {
//            if let navigationController = self.navigationController {
//                navigationController.popViewController(animated: true)
//            }
//        }
//    }
//
//    private func discardChanges() {
//
//        let alert = UIAlertController(title: "Discard or Save Changes", message: "Are you sure to Discard Changes", preferredStyle:.alert)
//        alert.addAction(UIAlertAction(title: "Yes", style: .default,handler: { action in
//            switch action.style {
//            case .default :
//
//                if let navigationController = self.navigationController {
//                    navigationController.popViewController(animated: true)
//                }
//
//            @unknown default:
//                self.dismiss(animated: true)
//            }
//
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
//            switch action.style {
//            case .cancel :
//                let alert2 = UIAlertController(title: "Save Changes", message: "You made Changes to Current Note Save from Lossing ", preferredStyle: .alert)
//                let cancel = UIAlertAction(title: "Ok", style: .cancel)
//                alert2.addAction(cancel)
//                self.present(alert2, animated: true, completion: nil)
//            @unknown default:
//                self.dismiss(animated: true)
//            }
//        }))
//        self.present(alert, animated: true, completion: nil)
//
//    }
//
//    func addReferanceViewCopnstraints() {
//
//        self.view.addSubview(referanceView)
//
//        referanceView.topAnchor.constraint(equalTo: self.backgroundView.bottomAnchor , constant: 10).isActive = true
//        referanceView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//        referanceView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
//        referanceView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
//
//        referanceView.layoutIfNeeded()
//    }
//
//    func setupConstriantValues () {
//
//
//        notesImageviewConstriants = [notesImage.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor , constant: 20),
//                                     notesImage.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor , constant: -20),
//                                     notesImage.topAnchor.constraint(equalTo: scrollView.topAnchor , constant: 5),
//                                     notesImage.heightAnchor.constraint(equalToConstant: (self.view.frame.height / 4))]
//
//        titleConstraintsWithImage = [titleTextView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor , constant: 20),
//                                     titleTextView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor , constant: -20),
//                                     titleTextView.topAnchor.constraint(equalTo: notesImage.bottomAnchor , constant: 10),
//                                     titleTextView.heightAnchor.constraint(equalToConstant: (self.view.frame.height / 12))]
//
//        titleConstraintsWithoutImage = [titleTextView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor , constant: 20),
//                                        titleTextView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor , constant: -20),
//                                        titleTextView.topAnchor.constraint(equalTo: scrollView.topAnchor , constant: 5),
//                                        titleTextView.heightAnchor.constraint(equalToConstant: (50))]
//
//        descriptionConstriants = [descriptionTextView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor , constant: 20),
//                                  descriptionTextView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor,constant: -20),
//                                  descriptionTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor , constant: 15),
//                                  descriptionTextView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant:  -5)]
//
//    }
//
//    func configureConstraintsWithImage () {
//        self.scrollView.addSubview(notesImage)
//        self.scrollView.addSubview(titleTextView)
//        self.scrollView.addSubview(descriptionTextView)
//
//        if let notesImageviewConstriants = self.notesImageviewConstriants ,
//           let titleConstraintsWithImage = self.titleConstraintsWithImage ,
//           let descriptionConstriants = self.descriptionConstriants ,
//           let titleConstraintsWithoutImage = self.titleConstraintsWithoutImage {
//
//            NSLayoutConstraint.deactivate(titleConstraintsWithoutImage)
//
//            NSLayoutConstraint.activate(notesImageviewConstriants)
//            NSLayoutConstraint.activate(titleConstraintsWithImage)
//            NSLayoutConstraint.activate(descriptionConstriants)
//        }
//
//
//    }
//
//    func configureConstraintsWithoutImage () {
//        self.notesImage.image = nil
//        self.notesImage.removeFromSuperview()
//        self.scrollView.addSubview(titleTextView)
//        self.scrollView.addSubview(descriptionTextView)
//
//        if let titleConstraintsWithImage = self.titleConstraintsWithImage ,
//           let descriptionConstriants = self.descriptionConstriants ,
//           let titleConstraintsWithoutImage = self.titleConstraintsWithoutImage {
//
//            NSLayoutConstraint.deactivate(titleConstraintsWithImage)
//
//            NSLayoutConstraint.activate(titleConstraintsWithoutImage)
//            NSLayoutConstraint.activate(descriptionConstriants)
//        }
//
//
//    }
//
//    @objc func addImageToNotes(sender : UIButton) {
//
//        let actionSheetController = UIAlertController(title: "Add Image", message: "Choose Image picking option", preferredStyle: .actionSheet)
//
//        let openCamera = UIAlertAction(title: "Camera", style: .default) {[weak self]_ in
//            let picker = UIImagePickerController()
//            picker.delegate = self as? any UIImagePickerControllerDelegate & UINavigationControllerDelegate
//            picker.sourceType = .camera
//            self?.present(picker, animated: true)
//
//        }
//
//        let opengallery = UIAlertAction(title: "Gallary", style: .default) {[weak self] _ in
//
//            var configuration = PHPickerConfiguration()
//            configuration.selectionLimit = 1
//            configuration.filter = .images
//
//            let picker = PHPickerViewController(configuration: configuration)
//            picker.delegate = self
//            self?.present(picker, animated: true)
//        }
//
//        actionSheetController.addAction(openCamera)
//        actionSheetController.addAction(opengallery)
//        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        present(actionSheetController, animated: true)
//
//    }
//
//    func changeAttachButtonToRemoveButton () {
//        attachButton.removeTarget(self, action: #selector(addImageToNotes), for: .touchUpInside)
//        attachButton.backgroundColor = .systemGreen
//        attachButton.setImage(UIImage(named: "removeImage"), for: .normal)
//        attachButton.addTarget(self, action: #selector(removeImage), for: .touchUpInside)
//    }
//
//    @objc func removeImage() {
//
//        configureConstraintsWithoutImage()
//        attachButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
//        attachButton.backgroundColor = .gray
//        attachButton.tintColor = .white
//
//        if detailedView {
//            saveButton.isHidden = false
//        }
//        attachButton.addTarget(self, action: #selector(addImageToNotes), for: .touchUpInside)
//    }
//
//    func showDetailedNotes( noteDetailes:NewNote/*noteDetailes : Notes*/ ) {
//
//        self.saveButton.isHidden = true
//        self.detailedView = true
//        if let noteImage = noteDetailes.Image {
//            changeAttachButtonToRemoveButton()
//            configureConstraintsWithImage()
//            self.notesImage.image = noteImage //UIImage(data: noteImage)
//            self.notesImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showLargeSizeImage)))
//        }
//
//        else {
//            configureConstraintsWithoutImage()
//            attachButton.addTarget(self, action: #selector(addImageToNotes), for: .touchUpInside)
//        }
//
//        self.titleTextView.text = noteDetailes.title
//        self.descriptionTextView.text = noteDetailes.notes
//
//    }
//
//    private func setupLargeImageCollectioView () {
//
//        let singleImageFlowLayout = UICollectionViewFlowLayout()
//        //singleImageFlowLayout.itemSize = CGSize(width: self.largeImageCollectionView.frame.width , height: self.largeImageCollectionView.frame.height)
//        singleImageFlowLayout.scrollDirection = .horizontal
//
//        self.largeImageCollectionView.collectionViewLayout = singleImageFlowLayout
//
//        largeImageCollectionView.delegate  = self
//        largeImageCollectionView.dataSource = self
//
//        largeImageCollectionView.register(LargeImageCollectionViewCell.self, forCellWithReuseIdentifier: LargeImageCollectionViewCell.largeImageCellReuseIdentifier)
//    }
//
//    @objc func showLargeSizeImage () {
//
//        self.view.addSubview(largeImageCollectionView)
//        self.largeImageCollectionView.frame = self.notesImage.frame// CGRect(x: 0, y: 0, width: 300, height: 300)
//        self.largeImageCollectionView.center = self.notesImage.center
//        self.saveButton.isHidden = true
//        self.attachButton.isHidden = true
//        self.deleteButton.isHidden = true
//
//        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
//            self.largeImageCollectionView.frame = self.referanceView.frame
//        }
//
//        self.backButton.removeTarget(self, action: #selector(backToHomeVC), for: .touchUpInside)
//        self.backButton.addTarget(self, action: #selector(dismisLargeImageCollectionView), for: .touchUpInside)
//
//    }
//
//    @objc private func dismisLargeImageCollectionView () {
//        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
//            self.largeImageCollectionView.frame = self.notesImage.frame
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {[weak self] in
//            self?.saveButton.isHidden = false
//            self?.attachButton.isHidden = false
//            self?.deleteButton.isHidden = false
//            self?.largeImageCollectionView.removeFromSuperview()
//            self?.backButton.removeTarget(self, action: #selector(self?.dismisLargeImageCollectionView), for: .touchUpInside)
//            self?.backButton.addTarget(self, action: #selector(self?.backToHomeVC), for: .touchUpInside)
//        }
//    }
//
//    @objc func clear(sender : UIButton) {
//        removeImage()
//        self.titleTextView.text = "  Title..!"
//        self.titleTextView.textColor = .systemGray3
//        self.descriptionTextView.text = "  Note here . . . . ."
//        self.descriptionTextView.textColor = .systemGray3
//
//    }
//
//    @objc func deleteNote() {
//
//        let alert = UIAlertController(title: "Notes", message: "Are you sure to delet this note?", preferredStyle:.alert)
//        alert.addAction(UIAlertAction(title: "Yes Delete", style: .default,handler: { action in
//            switch action.style {
//            case .default :
//                if let objectToDelete = self.currentNote {
//                    let resultText = CoreDataManager.shared.removeNotes(noteToRemove: objectToDelete)
//                    if resultText == "Note deleted SuccesFully" {
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                }
//
//                break
//            @unknown default:
//                self.dismiss(animated: true)
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    @objc func saveNote() {
//
//        let resultString = CoreDataManager.shared.addNewNote(newNote: NewNote(title: self.titleTextView.text, notes: self.descriptionTextView.text, date: Date(), Image: self.notesImage.image))
//        if resultString == "Note added SuccesFully" {
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
//
//}
//
//
//// Extensions
//
//// TextViewDelegate
//
//extension AddNewNoteViewController : UITextViewDelegate  {
//
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if detailedView {
//            saveButton.isHidden = false
//        }
//        else {
//            textView.text = ""
//            textView.textColor = .label
//
//        }
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text == "" {
//            if textView == titleTextView {
//                textView.text = "  Title..!"
//            }
//            if textView == descriptionTextView {
//                textView.text = "  Note here . . . . ."
//            }
//            textView.textColor = .systemGray3
//        }
//    }
//
//    func textViewDidChange(_ textView: UITextView) {
//        //        if detailedView {
//        //            saveButton.isHidden = false
//        //        }
//        //        else {
//        //            textView.textColor = .label
//        //
//        //        }
//    }
//}
//
//// ImagePicker
//
//extension AddNewNoteViewController : UIImagePickerControllerDelegate ,PHPickerViewControllerDelegate{
//
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        picker.dismiss(animated: true)
//
//        for result in results {
//            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
//                if let image = object as? UIImage {
//                    DispatchQueue.main.async {
//
//                        self?.configureConstraintsWithImage()
//                        self?.notesImage.image = image
//                        self?.changeAttachButtonToRemoveButton()
//
//                    }
//                }
//            }
//        }
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        let image = (info[.originalImage] as? UIImage)
//    }
//}
//
//// LargeImgaeView
//
//extension AddNewNoteViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout  {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        1//self.notes.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LargeImageCollectionViewCell.largeImageCellReuseIdentifier, for: indexPath) as? LargeImageCollectionViewCell else { return UICollectionViewCell()}
//
//        if indexPath.row == 0 {
//            if let notesIamge = self.notesImage.image {
//                cell.imageView.image = notesIamge
//                return cell
//            }
//        }
//
//        else if indexPath.row == self.currentObjectIndex {
//            if let noteImage = self.notes[0].noteImage {
//                cell.imageView.image = UIImage(data: noteImage)
//                return cell
//            }
//        }
//
//        if let notesIamge = notes[indexPath.row].noteImage {
//            cell.imageView.image = UIImage(data: notesIamge)
//        }
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: self.largeImageCollectionView.frame.width , height: self.largeImageCollectionView.frame.height)
//    }
//
//
//
//}
//
