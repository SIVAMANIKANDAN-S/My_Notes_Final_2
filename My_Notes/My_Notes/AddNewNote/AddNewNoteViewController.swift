//
//  AddNewNoteViewController.swift
//  My_Notes
//
//  Created by admin on 18/03/23.
//

import UIKit

import PhotosUI

class AddNewNoteViewController: UIViewController {
    
    var notes = [Notes]()
    
    var imageChanged = false
    
    var string = NSAttributedString()
    
    var imagesArray : [UIImage] = []
    
    var currentNote : Notes?
    
    var currentObjectIndex : Int = 0
    
    private var notesImageviewConstriants : [NSLayoutConstraint]?
    
    private var titleConstraintsWithImage : [NSLayoutConstraint]?
    
    private var titleConstraintsWithoutImage : [NSLayoutConstraint]?
    
    private var descriptionConstriants : [NSLayoutConstraint]?
    
    
    private lazy var backgroundView : UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    } ()
    
    private lazy var backButton : UIButton = {
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.tintColor = .white
        
        return button
    } ()
    
    private lazy var attachButton : UIButton = {
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.tintColor = .white
        
        return button
    } ()
    
    private lazy var deleteButton : UIButton = {
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Clear", for: .normal)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .gray
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.tintColor = .white
        
        return button
    } ()
    
    private lazy var saveButton : UIButton = {
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save", for: .normal)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .gray
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.tintColor = .white
        
        return button
    } ()
    
    private lazy var notesImage : UIImageView = {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.shadowColor = UIColor.gray.cgColor
        imageView.layer.shadowRadius = 3
        imageView.layer.shadowOpacity = 0.7
        imageView.isUserInteractionEnabled = true
        return imageView
    } ()
    
    private lazy var titleTextView : UITextView = {
        
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth = 0
        textView.text = "  Title..!"
        textView.textColor = .systemGray3
        textView.font = .systemFont(ofSize: 30, weight: .semibold)
        textView.keyboardAppearance = .alert
        textView.keyboardType = .default
        return textView
    } ()
    
    private lazy var descriptionTextView : UITextView = {
        
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "  Note here . . . . ."
        textView.textColor = .systemGray3
        textView.backgroundColor = .clear
        textView.layer.borderWidth = 0
        textView.font = .systemFont(ofSize: 30, weight: .regular)
        textView.keyboardAppearance = .alert
        textView.keyboardType = .default
        return textView
    } ()
    
    lazy var largeImageCollectionView : UICollectionView = {
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor(red: 41 / 255, green: 42 / 255, blue: 47 / 255, alpha: 1)
        collectionView.isPagingEnabled = true
        return collectionView
        
    } ()
    
    lazy var referanceView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    } ()
    
    private var imageCheckerView : UIImageView = {
        let imageView = UIImageView()
        return imageView
    } ()
    
    private var detailedView : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        self.view.backgroundColor = UIColor(red: 41 / 255, green: 42 / 255 , blue: 47 / 255 , alpha: 1)
        
        self.navigationController?.navigationBar.isHidden = true
        
        createImagesArray()
        
        backButton.addTarget(self, action: #selector(backToHomeVC), for: .touchUpInside)
        
        if attachButton.allTargets.count == 0 {
            
            attachButton.addTarget(self, action: #selector(addImageToNotes), for: .touchUpInside)
        }
        
        actionButtonsConstriants()
        
        addReferanceViewCopnstraints()
        
        setupConstriantValues()
        
        configureConstraintsWithoutImage()
        
        titleTextView.delegate = self
        
        descriptionTextView.delegate = self
        
        if detailedView {
            setupLargeImageCollectioView()
            deleteButton.setTitle("Delete", for: .normal)
            deleteButton.addTarget(self, action: #selector(deleteNote), for: .touchUpInside)
        }
        else {
            deleteButton.addTarget(self, action: #selector(clear(sender:)), for: .touchUpInside)
            saveButton.addTarget(self, action: #selector(saveNote), for: .touchUpInside)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let size = CGSize(width: self.view.frame.width-40, height : .infinity)
        let estimatedsize = titleTextView.sizeThatFits(size)
        titleTextView.isScrollEnabled = true
        titleTextView.constraints.forEach { constraints in
            if constraints.firstAttribute == .height {
                constraints.constant = estimatedsize.height
            }
        }
    }
    
    func actionButtonsConstriants () {
        
        self.view.addSubview(backgroundView)
        self.backgroundView.addSubview(backButton)
        self.backgroundView.addSubview(deleteButton)
        self.backgroundView.addSubview(attachButton)
        self.backgroundView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     backgroundView.heightAnchor.constraint(equalToConstant: 50),
                                     backgroundView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor , constant: 20)])
        
        NSLayoutConstraint.activate([backButton.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor , constant: 20),
                                     backButton.widthAnchor.constraint(equalToConstant: 50),
                                     backButton.heightAnchor.constraint(equalToConstant: 50),
                                     backButton.topAnchor.constraint(equalTo: self.backgroundView.topAnchor)])
        
        NSLayoutConstraint.activate([deleteButton.widthAnchor.constraint(equalToConstant: 100),
                                     deleteButton.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor , constant: 20),
                                     deleteButton.heightAnchor.constraint(equalToConstant: 50),
                                     deleteButton.topAnchor.constraint(equalTo: self.backgroundView.topAnchor)])
        
        NSLayoutConstraint.activate([saveButton.widthAnchor.constraint(equalToConstant: 100),
                                     saveButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor , constant: -20),
                                     saveButton.heightAnchor.constraint(equalToConstant: 50),
                                     saveButton.topAnchor.constraint(equalTo: self.backgroundView.topAnchor)])
        
        NSLayoutConstraint.activate([attachButton.widthAnchor.constraint(equalToConstant: 50),
                                     attachButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor , constant: -20),
                                     attachButton.heightAnchor.constraint(equalToConstant: 50),
                                     attachButton.topAnchor.constraint(equalTo: self.backgroundView.topAnchor)])
    }
    
    @objc private func backToHomeVC (_ sender : UIButton) {
        
        if titleTextView.text == "" {
            titleTextView.text = "  Title..!"
        }
        
        if descriptionTextView.text == "" {
            descriptionTextView.text = "  Note here . . . . ."
        }
        
        if detailedView {
            guard let  note = self.currentNote else {
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                }
                return }
            if (self.descriptionTextView.attributedText != self.string) || (self.titleTextView.text != note.title)  || imageChanged  {
                discardChanges()
                
            }
            
            else {
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                }
            }
        }
        
        else if self.descriptionTextView.text != "  Note here . . . . ." || self.titleTextView.text != "  Title..!"  || notesImage.image != nil {
            discardChanges()
        }
        
        else {
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            }
        }
    }
    
    private func discardChanges() {
        
        let alert = UIAlertController(title: "Discard or Save Changes", message: "Are you sure to Discard Changes", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default,handler: { action in
            switch action.style {
            case .default :
                
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                }
                
            @unknown default:
                self.dismiss(animated: true)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            switch action.style {
            case .cancel :
                let alert2 = UIAlertController(title: "Save Changes", message: "You made Changes to Current Note Save from Lossing ", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Ok", style: .cancel)
                alert2.addAction(cancel)
                self.present(alert2, animated: true, completion: nil)
            @unknown default:
                self.dismiss(animated: true)
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func createImagesArray () {
        for item in self.notes {
            if item == currentNote {
                continue
            }
            if let imageData = item.noteImage {
                let image = UIImage(data: imageData)
                imagesArray.append(image!)
            }
        }
        
    }
    
    func addReferanceViewCopnstraints() {
        
        self.view.addSubview(referanceView)
        
        referanceView.topAnchor.constraint(equalTo: self.backgroundView.bottomAnchor , constant: 10).isActive = true
        referanceView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        referanceView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        referanceView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        referanceView.layoutIfNeeded()
    }
    
    func setupConstriantValues () {
        
        
        notesImageviewConstriants = [notesImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor , constant: 20),
                                     notesImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor , constant: -20),
                                     notesImage.topAnchor.constraint(equalTo: backgroundView.bottomAnchor , constant: 10),
                                     notesImage.heightAnchor.constraint(equalToConstant: (self.view.frame.height / 4))]
        
        titleConstraintsWithImage = [titleTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor , constant: 20),
                                     titleTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor , constant: -20),
                                     titleTextView.topAnchor.constraint(equalTo: notesImage.bottomAnchor , constant: 10),
                                     titleTextView.heightAnchor.constraint(equalToConstant: (self.view.frame.height / 10))]
        
        titleConstraintsWithoutImage = [titleTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor , constant: 20),
                                        titleTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor , constant: 20),
                                        titleTextView.topAnchor.constraint(equalTo: backgroundView.bottomAnchor , constant: 10),
                                        titleTextView.heightAnchor.constraint(equalToConstant: (self.view.frame.height / 10))]
        
        descriptionConstriants = [descriptionTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor , constant: 20),
                                  descriptionTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -20),
                                  descriptionTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor , constant: 20),
                                  descriptionTextView.bottomAnchor.constraint(equalTo: self.view.keyboardLayoutGuide.topAnchor , constant:  -5)]
        
    }
    
    func configureConstraintsWithImage () {
        self.view.addSubview(notesImage)
        self.view.addSubview(titleTextView)
        self.view.addSubview(descriptionTextView)
        
        if let notesImageviewConstriants = self.notesImageviewConstriants ,
           let titleConstraintsWithImage = self.titleConstraintsWithImage ,
           let descriptionConstriants = self.descriptionConstriants ,
           let titleConstraintsWithoutImage = self.titleConstraintsWithoutImage {
            
            NSLayoutConstraint.deactivate(titleConstraintsWithoutImage)
            
            NSLayoutConstraint.activate(notesImageviewConstriants)
            NSLayoutConstraint.activate(titleConstraintsWithImage)
            NSLayoutConstraint.activate(descriptionConstriants)
        }
        
        
    }
    
    func configureConstraintsWithoutImage () {
        self.notesImage.image = nil
        self.notesImage.removeFromSuperview()
        self.view.addSubview(titleTextView)
        self.view.addSubview(descriptionTextView)
        
        if let titleConstraintsWithImage = self.titleConstraintsWithImage ,
           let descriptionConstriants = self.descriptionConstriants ,
           let titleConstraintsWithoutImage = self.titleConstraintsWithoutImage {
            
            NSLayoutConstraint.deactivate(titleConstraintsWithImage)
            
            NSLayoutConstraint.activate(titleConstraintsWithoutImage)
            NSLayoutConstraint.activate(descriptionConstriants)
        }
        
        
    }
    
    @objc func addImageToNotes(sender : UIButton) {
        
        let actionSheetController = UIAlertController(title: "Add Image", message: "Choose Image picking option", preferredStyle: .actionSheet)
        
        let openCamera = UIAlertAction(title: "Camera", style: .default) {[weak self]_ in
            let picker = UIImagePickerController()
            picker.delegate = self as? any UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.sourceType = .camera
            self?.present(picker, animated: true)
            
        }
        
        let opengallery = UIAlertAction(title: "Gallary", style: .default) {[weak self] _ in
            
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self?.present(picker, animated: true)
        }
        
        actionSheetController.addAction(openCamera)
        actionSheetController.addAction(opengallery)
        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheetController, animated: true)
        
    }
    
    func changeAttachButtonToRemoveButton () {
        attachButton.removeTarget(self, action: #selector(addImageToNotes), for: .touchUpInside)
        attachButton.backgroundColor = .systemGreen
        attachButton.setImage(UIImage(named: "removeImage"), for: .normal)
        attachButton.addTarget(self, action: #selector(removeImage), for: .touchUpInside)
    }
    
    @objc func removeImage() {
        
        configureConstraintsWithoutImage()
        attachButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        attachButton.backgroundColor = .gray
        attachButton.tintColor = .white
        self.notesImage.image = nil
        imageChanged = true
        if detailedView {
            saveButton.isHidden = false
            saveButton.addTarget(self, action: #selector(updateNote), for: .touchUpInside)
            saveButton.setTitle("Update", for: .normal)
        }
        let size = CGSize(width: self.view.frame.width-40, height : .infinity)
        let estimatedsize = titleTextView.sizeThatFits(size)
        titleTextView.isScrollEnabled = true
        titleTextView.constraints.forEach { constraints in
            if constraints.firstAttribute == .height {
                constraints.constant = estimatedsize.height
            }
        }
        attachButton.addTarget(self, action: #selector(addImageToNotes), for: .touchUpInside)
    }
    
    func showDetailedNotes( noteDetailes:Notes ) {
        
        self.saveButton.isHidden = true
        self.detailedView = true
        if let noteImage = noteDetailes.noteImage {
            changeAttachButtonToRemoveButton()
            configureConstraintsWithImage()
            self.notesImage.image = UIImage(data: noteImage)
            self.imageCheckerView.image = UIImage(data: noteImage)
            self.notesImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showLargeSizeImage)))
        }
        
        else {
            configureConstraintsWithoutImage()
            attachButton.addTarget(self, action: #selector(addImageToNotes), for: .touchUpInside)
        }
        
        self.titleTextView.text = noteDetailes.title
        self.titleTextView.textColor = .label
        self.descriptionTextView.textColor = .label
        if let descriptions =  noteDetailes.descriptions {
            self.descriptionTextView.attributedText = HomeViewInteractor.shared.renderLink(notesDescription: descriptions)
            self.string = HomeViewInteractor.shared.renderLink(notesDescription: descriptions)
        }
        
    }
    
    private func setupLargeImageCollectioView () {
        
        let singleImageFlowLayout = UICollectionViewFlowLayout()
        //singleImageFlowLayout.itemSize = CGSize(width: self.largeImageCollectionView.frame.width , height: self.largeImageCollectionView.frame.height)
        singleImageFlowLayout.scrollDirection = .horizontal
        
        self.largeImageCollectionView.collectionViewLayout = singleImageFlowLayout
        
        largeImageCollectionView.delegate  = self
        largeImageCollectionView.dataSource = self
        
        largeImageCollectionView.register(LargeImageCollectionViewCell.self, forCellWithReuseIdentifier: LargeImageCollectionViewCell.largeImageCellReuseIdentifier)
    }
    
    @objc func showLargeSizeImage () {
        
        self.view.addSubview(largeImageCollectionView)
        self.largeImageCollectionView.frame = self.notesImage.frame// CGRect(x: 0, y: 0, width: 300, height: 300)
        self.largeImageCollectionView.center = self.notesImage.center
        self.saveButton.isHidden = true
        self.attachButton.isHidden = true
        self.deleteButton.isHidden = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.largeImageCollectionView.frame = self.referanceView.frame
        }
        
        self.backButton.removeTarget(self, action: #selector(backToHomeVC), for: .touchUpInside)
        self.backButton.addTarget(self, action: #selector(dismisLargeImageCollectionView), for: .touchUpInside)
        
    }
    
    @objc private func dismisLargeImageCollectionView () {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.largeImageCollectionView.frame = self.notesImage.frame
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {[weak self] in
            // self?.saveButton.isHidden = false
            self?.attachButton.isHidden = false
            self?.deleteButton.isHidden = false
            self?.largeImageCollectionView.removeFromSuperview()
            self?.backButton.removeTarget(self, action: #selector(self?.dismisLargeImageCollectionView), for: .touchUpInside)
            self?.backButton.addTarget(self, action: #selector(self?.backToHomeVC), for: .touchUpInside)
        }
    }
    
    @objc func clear(sender : UIButton) {
        removeImage()
        self.titleTextView.text = "  Title..!"
        self.titleTextView.textColor = .systemGray3
        self.descriptionTextView.text = "  Note here . . . . ."
        self.descriptionTextView.textColor = .systemGray3
        
    }
    
    @objc func deleteNote() {
        
        let alert = UIAlertController(title: "Notes", message: "Are you sure to delet this note?", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "Yes Delete", style: .default,handler: { action in
            switch action.style {
            case .default :
                if let objectToDelete = self.currentNote {
                    let resultText = CoreDataManager.shared.removeNotes(noteToRemove: objectToDelete)
                    if resultText == "Note deleted SuccesFully" {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
                break
            @unknown default:
                self.dismiss(animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func saveNote() {
        
        let resultString = CoreDataManager.shared.addNewNote(newNote: NewNote(title: self.titleTextView.text, notes: self.descriptionTextView.text, date: Date(), Image: self.notesImage.image?.pngData(), lacalNote: true))
        if resultString == "Note added SuccesFully" {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func updateNote() {
        let resultString = CoreDataManager.shared.updateNote( note : currentNote! , noteValues: NewNote(title: self.titleTextView.text, notes: self.descriptionTextView.text, date: Date(), Image: self.notesImage.image?.pngData(), lacalNote: currentNote!.localNote))
        if resultString == "Note Updated SuccesFully" {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}


// Extensions

// TextViewDelegate

extension AddNewNoteViewController : UITextViewDelegate  {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if !detailedView {
            if textView == titleTextView && textView.text == "  Title..!" {
                textView.text = ""
            }
            else if textView == descriptionTextView && textView.text == "  Note here . . . . ." {
                textView.text = ""
            }
            textView.textColor = .label
            
        }
//        let size = CGSize(width: self.view.frame.width-40, height : .infinity)
//        let estimatedsize = textView.sizeThatFits(size)
//        textView.isScrollEnabled = true
//        textView.constraints.forEach { constraints in
//            if constraints.firstAttribute == .height {
//                constraints.constant = estimatedsize.height
//            }
//        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            if textView == titleTextView {
                textView.text = "  Title..!"
            }
            if textView == descriptionTextView {
                textView.text = "  Note here . . . . ."
            }
            textView.textColor = .systemGray3
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if detailedView {
            saveButton.isHidden = false
            saveButton.setTitle("Update", for: .normal)
            saveButton.removeTarget(self, action: #selector(saveNote), for: .touchUpInside)
            saveButton.addTarget(self, action: #selector(updateNote), for: .touchUpInside)
        }
        
        let size = CGSize(width: self.view.frame.width-40, height : .infinity)
        let estimatedsize = textView.sizeThatFits(size)
        textView.isScrollEnabled = true
        textView.constraints.forEach { constraints in
            if constraints.firstAttribute == .height {
                constraints.constant = estimatedsize.height
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        if textView == titleTextView {
            return numberOfChars < 100;
        }
        else {
            return  numberOfChars < 3000
        }
    }
    
    
}

// ImagePicker

extension AddNewNoteViewController : UIImagePickerControllerDelegate ,PHPickerViewControllerDelegate{
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        
                        self?.configureConstraintsWithImage()
                        self?.notesImage.image = image
                        self?.imageChanged = true
                        self?.changeAttachButtonToRemoveButton()
                        guard let detailedview = self?.detailedView else {return}
                        if  detailedview {
                            self?.saveButton.isHidden = false
                            self?.saveButton.setTitle("Update", for: .normal)
                            self?.saveButton.addTarget(self, action: #selector(self?.updateNote), for: .touchUpInside)
                        }
                        
//                        let size = CGSize(width: self!.view.frame.width-40, height : .infinity)
//                        let estimatedsize = self?.titleTextView.sizeThatFits(size)
//                        self?.titleTextView.isScrollEnabled = true
//                        self?.titleTextView.constraints.forEach { constraints in
//                                    if constraints.firstAttribute == .height {
//                                        constraints.constant = estimatedsize!.height
//                                    }
//                                }
                        
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = (info[.originalImage] as? UIImage)
    }
}

// LargeImgaeView

extension AddNewNoteViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout  {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.imagesArray.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LargeImageCollectionViewCell.largeImageCellReuseIdentifier, for: indexPath) as? LargeImageCollectionViewCell else { return UICollectionViewCell() }
        
        if indexPath.row == 0 {
            if let notesIamge = self.notesImage.image {
                cell.imageView.image = notesIamge
                return cell
            }
        }
        
        else {
            cell.imageView.image = imagesArray[indexPath.row - 1]
            return cell
        }
        
        if let notesIamge = notes[indexPath.row].noteImage {
            cell.imageView.image = UIImage(data: notesIamge)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.largeImageCollectionView.frame.width , height: self.largeImageCollectionView.frame.height)
    }
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
    
}

