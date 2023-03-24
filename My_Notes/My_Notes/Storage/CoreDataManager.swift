//
//  CoreDataManager.swift
//  My_Notes
//
//  Created by admin on 18/03/23.
//

import Foundation

import CoreData


class CoreDataManager {
    
    private init() {}
    
    static let shared = CoreDataManager()
    
    private var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Notes")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    } ()
    
    lazy var context = persistentContainer.viewContext
    
    
    private func save () {
        if self.context.hasChanges {
            self.context.perform {
                do {
                    try self.context.save()
                }
                catch {
                    print("Failure to save context: \(error)")
                }
            }
        }
    }
    
    
    // CRUD Operations
    
    func addNewNote (newNote : NewNote) -> String {
        
        let entity = NSEntityDescription.entity(forEntityName: "Notes", in: context)
        let note = NSManagedObject(entity: entity!, insertInto: context)
        
        note.setValue( newNote.date , forKey: "dateOfCreation")
        note.setValue(newNote.title, forKey: "title")
        note.setValue(newNote.notes, forKey: "descriptions")
        note.setValue(newNote.Image, forKey: "noteImage")
        note.setValue(newNote.lacalNote, forKey: "localNote")
        
        do {
            try self.context.save()
            return "Note added SuccesFully"
        }
        catch {
            
            return "Note Not Added"
        }
        
        
    }
    
    func removeNotes (noteToRemove : Notes) -> String{
        
        context.delete(noteToRemove)
        
        do {
            try context.save()
            return "Note deleted SuccesFully"
            
        }
        catch {
            return "Note Not Deleted"
        }
        
    }
    
    func updateNote (note : Notes , noteValues : NewNote) -> String {
        
        note.setValue( noteValues.date , forKey: "dateOfCreation")
        note.setValue(noteValues.title, forKey: "title")
        note.setValue(noteValues.notes, forKey: "descriptions")
        note.setValue(noteValues.Image, forKey: "noteImage")
        
        do {
            try self.context.save()
            return "Note Updated SuccesFully"
        }
        catch {
            
            return "Note Not updated"
        }
        
    }
    
    func fetchParticularNote (dateOfCreation : Date) -> Notes {
        
        return Notes()
    }
    
    func fetchAllNotes () -> [Notes] {
        
        return [Notes]()
    }
    
    
    func removeAllDataFormCoredata () {
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        let notes = try? context.fetch(fetchRequest) as? [Notes]
        
        // Then you can use your properties.
        
        if let notesData = notes {
            
            for note in notesData {
                
                if !note.localNote {
                    
                    context.delete(note)
                }
                
            }
        }
        //
        //        let coordinator = persistentContainer.persistentStoreCoordinator
        //
        //        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Notes")
        //        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        //
        //        do {
        //            try coordinator.execute(deleteRequest, with: context)
        //        }
        //        catch {
        //
        //        }
        //
        //    }
        
    }
}
