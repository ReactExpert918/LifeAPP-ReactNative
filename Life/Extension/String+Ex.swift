//
//  String+Ex.swift
//

import Foundation
import UIKit

extension String {
    
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func subString(_ from: Int, length: Int, defaultValue: String = "") -> String {
        guard let start = self.index(startIndex, offsetBy: from, limitedBy: endIndex),
            let end = self.index(start, offsetBy: length, limitedBy: endIndex) else {
                return defaultValue
        }
        
        return String(self[start..<end])
    }
   
     /**
     :  name: isValidEmailAddress
     : check and return if email is valid or not
     **/
    func isValidEmailAddress() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: self)
    }
    
    /**
    :  name: isValidPhoneNumber
    : check and return if phone number is valid or not
    **/
    func isValidPhoneNumber() -> Bool {
        let phoneRegEx = "^\\d{3}-\\d{3}-\\d{4}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return predicate.evaluate(with: self)
    }
    
    /**
    :  name: isAlphaNumberic
    : check and return if input is alphanumeric or not
    **/
    var isAlphaNumberic: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    // String to Date
    // format: "yyyy-MM-dd" ("MM-dd-yyyy hh:mm, a" "yyyy-MM-dd h:mm")
    func toDate(_ format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.date(from: self)
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    // get substring between two strings
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    func localized() -> String {
        
        if let path = Bundle.main.path(forResource: Locale.autoupdatingCurrent.languageCode, ofType: "lproj") {
            let bundle = Bundle(path: path)
            return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
        }
        return self
    }
}

extension StringProtocol { // for Swift 4 you need to add the constrain `where Index == String.Index`
    var byWords: [SubSequence] {
        var byWords: [SubSequence] = []
        enumerateSubstrings(in: startIndex..., options: .byWords) { _, range, _, _ in
            byWords.append(self[range])
        }
        return byWords
    }
}

extension String {
    func height(with size: CGSize, font: UIFont) -> CGFloat {
        let nsstring = NSString(string: self)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin,.usesFontLeading]
        return CGFloat(ceilf(Float(nsstring.boundingRect(with: size, options: options, attributes: [.font: font], context: nil).size.height)))
    }
}

extension UILabel {
    func textHeight(with width: CGFloat) -> CGFloat {
        if let txt = self.text {
            return txt.height(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), font: self.font)
        } else {
            return 0
        }
    }
}
