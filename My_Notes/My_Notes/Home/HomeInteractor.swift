//
//  HomeInteractor.swift
//  My_Notes
//
//  Created by admin on 18/03/23.
//

import Foundation

import UIKit

class HomeViewInteractor  {
    
    static let shared = HomeViewInteractor()
    
    private init() {
        
    }
    
    
    func findTextToBeBolded(stringToBeBoled : String) -> [String] {
        
        var text = stringToBeBoled
        
        var boldTextArray = [String]()
        
        while text.contains("**") {
            
            let startIndex = text.index(of:"**")
            
            if let range1 = text.range(of:"**") {
                text =  text.replacingCharacters(in: range1, with:"")
            }
            let endIndex = text.index(of:"**")
            
            if let range2 = text.range(of:"**") {
                text =  text.replacingCharacters(in: range2, with:"")
            }
            
            if let start = startIndex , let end = endIndex {
                print(start)
                print(end)
                
                let text = String(text[start..<end])
                print(text)
                
                boldTextArray.append(text)
            }
            
            
        }
        boldTextArray.append(text)
        return boldTextArray
    }
    
    func findMarkDownStringString(string : String ) -> String {
        var text = ""
        let startIndex = string.firstIndex(of: "[")
        if string.contains(")") {
            let endin = string.firstIndex(of: ")")
            
            if let start = startIndex , let end = endin {
                
                let text = String(string[start...end])
                return text
            }
        }
        return text
    }
    
    func findLinkDetailes(string : String) -> Link {
        
        var text = string
        
        text.removeFirst()
        let start = string.firstIndex(of: "]")
        guard start != nil else {return Link(text: "", url: "")}
        var linktext = String (text[..<start!] )
        linktext.removeLast()
        
        text.removeLast()
        let end = string.firstIndex(of: "(")
        var url =  String (text[start!...] )
        url.removeFirst()
        return Link(text: linktext, url: url )
        
        
    }
    
    
    
    func renderLink (notesDescription : String ) -> NSMutableAttributedString {
        var text = notesDescription
        
        var count = 2
        
        var linkDictionary : [String : String] = [:]
        
        while text.contains("[") {
            
            let markdownString = findMarkDownStringString(string: text)
            
            if markdownString == "" {
                break
            }
            
            let link = findLinkDetailes(string: markdownString)
            
            if linkDictionary["\(link.text)"] != nil {
                
                linkDictionary["\(link.text)_\(count)"] = link.url
                text = text.replacingOccurrences(of: markdownString, with: "\(link.text)_\(count)")
                count = count + 1
            }
            else {
                linkDictionary["\(link.text)"] = link.url
                text = text.replacingOccurrences(of: markdownString, with: "\(link.text)")
            }
            
            // make link with word markdownString in text with link link.url
            
            // replace markDownString by link.text
            
            
        }
        
        var textToBoldArray : [String] = findTextToBeBolded(stringToBeBoled: text)
        if let resultText = textToBoldArray.last {
            text = resultText
            textToBoldArray.removeLast()
        }
        
        let stringWithLink = NSMutableAttributedString(string: text , attributes: nil)
        
        stringWithLink.addAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 20, weight: .regular) , NSAttributedString.Key.foregroundColor : UIColor.label], range: (stringWithLink.string as NSString).range(of: stringWithLink.string))
        
        for (key , value) in linkDictionary {
            
            let range = (stringWithLink.string as NSString).range(of: key)
            
            stringWithLink.addAttribute(.link, value: value, range: range)
            
        }
        
        for (string) in textToBoldArray {
            
            let range = (stringWithLink.string as NSString).range(of: string)
            
            stringWithLink.addAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 29, weight: .semibold)], range: range)
            
        }
        
        
        return stringWithLink
    }
    
}


