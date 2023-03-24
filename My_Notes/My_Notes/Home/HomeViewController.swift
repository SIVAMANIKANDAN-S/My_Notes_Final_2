//
//  HomeViewController.swift
//  My_Notes
//
//  Created by admin on 18/03/23.
//

import UIKit
import CoreData

class HomeViewController: UIViewController{
    
    lazy var fetchResultController  : NSFetchedResultsController  = {
        
        let notesFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        notesFetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOfCreation", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: notesFetchRequest, managedObjectContext: CoreDataManager.shared.context, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
        
    } ()
    
    private lazy var addButton : UIButton = {
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.backgroundColor = .black
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
        
    } ()
    
    lazy var notesTitleCollectionView : UICollectionView = {
        
        let collectioView = UICollectionView(frame: .zero , collectionViewLayout: UICollectionViewFlowLayout())
        collectioView.translatesAutoresizingMaskIntoConstraints = false
        collectioView.backgroundColor = .clear
        collectioView.alwaysBounceVertical = true
        return collectioView
    } ()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 41 / 255, green: 42 / 255 , blue: 47 / 255 , alpha: 1)
        
        setupNavigationTitle()
        
        updateCoreDataFromAPIdata()
        
        try? self.fetchResultController.performFetch()
        fetchResultController.delegate = self
        
        setupNotesCollectionView()
        
        configureAddButtonConstraints()
        
        addButton.addTarget(self, action: #selector(navigateToNewNoteViewController), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.notesTitleCollectionView.reloadData()
    }
    
    
    
    
    private func setupNavigationTitle () {
        
        self.title = "Notes"
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationItem.largeTitleDisplayMode = .always
        
        self.navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        
    }
    
    private func configureAddButtonConstraints () {
        
        self.view.addSubview(addButton)
        
        NSLayoutConstraint.activate([ addButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor , constant:-20),
                                      addButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor , constant: -40),
                                      addButton.heightAnchor.constraint(equalToConstant: 60),
                                      addButton.widthAnchor.constraint(equalToConstant: 60)])
        addButton.layoutIfNeeded()
        
        let plusButtonView = UIImageView()
        plusButtonView.translatesAutoresizingMaskIntoConstraints = false
        plusButtonView.contentMode = .scaleToFill
        plusButtonView.tintColor = .white
        plusButtonView.backgroundColor = .clear
        self.addButton.addSubview(plusButtonView)
        
        NSLayoutConstraint.activate([plusButtonView.centerXAnchor.constraint(equalTo: addButton.centerXAnchor) , plusButtonView.centerYAnchor.constraint(equalTo: addButton.centerYAnchor) , plusButtonView.widthAnchor.constraint(equalToConstant: addButton.frame.width / 2.5) , plusButtonView.heightAnchor.constraint(equalToConstant: addButton.frame.width / 2.5)])
        plusButtonView.image = UIImage(systemName: "plus")
        
        
        
    }
    
    func addFlowLayoutToNotesCollectionView () {
        let compositionalFlowLayOut  = UICollectionViewFlowLayout()
        compositionalFlowLayOut.minimumLineSpacing = 1
        compositionalFlowLayOut.minimumInteritemSpacing = 1
        compositionalFlowLayOut.scrollDirection = .vertical
        compositionalFlowLayOut.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        self.notesTitleCollectionView.collectionViewLayout = TopAlignedCollectionViewFlowLayout()
        
    }
    
    func setupNotesCollectionView () {
        self.view.addSubview(notesTitleCollectionView)
        addFlowLayoutToNotesCollectionView()
        
        notesTitleCollectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.reuseCellIdentifier)
        notesTitleCollectionView.delegate = self
        notesTitleCollectionView.dataSource = self
        
        NSLayoutConstraint.activate( [
            
            notesTitleCollectionView.topAnchor.constraint(equalTo:self.view.safeAreaLayoutGuide.topAnchor),
            notesTitleCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            notesTitleCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            notesTitleCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor) ] )
    }
    
    @objc private func navigateToNewNoteViewController (_ sender : UIButton) {
        
        let newNoteVC = AddNewNoteViewController()
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(newNoteVC, animated: true)
        }
    }
    
    func updateCoreDataFromAPIdata () {
        
        CoreDataManager.shared.removeAllDataFormCoredata()
        
        let notesFromAPI = NetworkManager.shared.fetchDataFromAPI(completion: { notes in
            
            for note in notes {
                
                let date = Date(timeIntervalSince1970: TimeInterval((note.created_time)))
                var imageData : Data?
                if let url = URL(string: note.image ?? "") {
                    if let data = try? Data(contentsOf: url)  {
                        imageData = data
                    }
                }
                CoreDataManager.shared.addNewNote(newNote: NewNote(title: note.title, notes: note.body, date: date, Image: imageData, lacalNote: false))
            }
        } )
        
    }
}

// EXTENSION

// CollectionView

extension HomeViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //fetchResultController.sections?.count ?? 1
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fetchResultController.sections?[section].numberOfObjects ?? 1
        //return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.reuseCellIdentifier, for: indexPath) as? HomeCollectionViewCell else { return UICollectionViewCell() }
        
        let Note = fetchResultController.object(at: indexPath) as? Notes
        
        if let Note = Note {
            
            let date = Note.dateOfCreation!.formatted(as: "MMMM dd, yyyy")
            cell.addValuesToLabels(title: (Note.title)!, time:  date)
            return cell
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let note = fetchResultController.object(at: indexPath) as? Notes
        if note?.noteImage != nil  {
            return CGSize(width: self.notesTitleCollectionView.frame.width - 40, height: 150)
        }
        return CGSize(width: (self.notesTitleCollectionView.frame.width / 2 ) - 30, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailedVC = AddNewNoteViewController()
        detailedVC.currentNote = fetchResultController.object(at: indexPath) as? Notes
        detailedVC.currentObjectIndex = indexPath.row
        if let notes = fetchResultController.fetchedObjects {
            detailedVC.notes = notes as! [Notes]
        }
        
        if let Note = fetchResultController.object(at: indexPath) as? Notes {
            detailedVC.showDetailedNotes(noteDetailes: Note)
        }
        self.navigationController?.navigationBar.isHidden = true
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(detailedVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 20.0,left: 20.0,bottom: 20.0,right: 20.0)
    }
    
    
}

// FetchedResultControllerDelegate

extension HomeViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert :
            notesTitleCollectionView.insertItems(at: [newIndexPath!])
            notesTitleCollectionView.scrollToItem(at: newIndexPath!, at: .centeredVertically, animated: true)
            
        @unknown default:
            print(1)
            
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
}






