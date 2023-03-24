//
//  Extensions.swift
//  My_Notes
//
//  Created by admin on 22/03/23.
//

import Foundation
import UIKit

extension Date {
    func formatted(as string: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = string
        return formatter.string(from: self)
    }
}

//
//extension UIImageView {
//
//    func downloadImageFromUrl(_ url: String) {
//        guard let url = URL(string: url) else { return }
//        URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, response, error) -> Void in
//            guard let httpURLResponse = response as? HTTPURLResponse where httpURLResponse.statusCode == 200,
//                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
//                let data = data where error == nil,
//                let image = UIImage(data: data)
//            else {
//                return
//            }
//        }).resume()
//    }
//
//}


extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
