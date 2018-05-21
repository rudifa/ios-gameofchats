//
//  util_regex.swift version 0.3
//  try_regex
//
//  Created by Rudolf Farkas on 28.04.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import Foundation

extension String
{
    // see
    //https://learnappmaking.com/regular-expressions-swift-string/
    //https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    
    // returns an array of substrings in self that matched the regex
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    // returns true if self is blank (empty or consists of whitespace characters only)
    func isBlank() -> Bool {
        return self.matches(for: "^\\s*$") != []
    }
    
    // returns true if self matches the pattern
    func doesMatch(regex: String) -> Bool {
        return self.matches(for: regex) != []
    }
    
}

