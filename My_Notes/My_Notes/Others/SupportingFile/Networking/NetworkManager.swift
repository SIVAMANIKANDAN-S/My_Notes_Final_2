////
////  NetworkManager.swift
////  My_Notes
////
////  Created by admin on 22/03/23.
////
//
import Foundation
import UIKit

enum HTTPMETHODS : String {
    
    case GET = "GET"
    
    case POST = "POST"
    
    case UPDATE = "UPDATE"
    
    case DELETE = "DELETE"
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    var notesFromAPI : [NotesFromAPI] = []
    
    private init() {
        
    }
    
    let urlString : String =  "https://raw.githubusercontent.com/RishabhRaghunath/JustATest/master/notes"
    
    func fetchDataFromAPI (completion : @escaping ([NotesFromAPI])->Void){
        
        guard let url = URL(string: urlString) else { return}
        
        if UIApplication.shared.canOpenURL(url) {
            
            var urlRequest : URLRequest = URLRequest(url: url)
            
            urlRequest.httpMethod = "GET"
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: urlRequest) { dataFromApI , responce , error in
                
                if error == nil  , let data = dataFromApI{
                    
                    if let requiredData = try? JSONDecoder().decode([NotesFromAPI].self, from: data) {
                        completion(requiredData)
//                        self.notesFromAPI = requiredData
//                        for note in requiredData {
//
//                            let date = Date(timeIntervalSince1970: TimeInterval((note.created_time)))
//                            var imageData : Data?
//                            if let url = URL(string: note.image ?? "") {
//                                if let data = try? Data(contentsOf: url)  {
//                                    imageData = data
//                                }
//                            }
//                            CoreDataManager.shared.addNewNote(newNote: NewNote(title: note.title, notes: note.body, date: date, Image: imageData, lacalNote: false))
                        //}
                      
                    }
                }
            }
            task.resume()
        }
    }
    
    
}
