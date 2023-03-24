//
//  NewNoteModel.swift
//  My_Notes
//
//  Created by admin on 18/03/23.
//

import Foundation
import UIKit


struct Link {
    
    var text : String
    
    var url : String
}


struct NewNote  {
    
    var title : String?
    
    var notes : String?
    
    var date  : Date
    
    var Image : Data?
    
    var lacalNote : Bool
}

struct NotesFromAPI  : Decodable {
    
    var title : String?
    
    var body : String?
    
    var created_time  : CLong
    
    var image : String?
    
}
