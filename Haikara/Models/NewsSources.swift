//
//  NewsSources.swift
//  highkara
//
//  The MIT License (MIT)
//
//  Copyright (c) 2017 Marko Wallin <mtw@iki.fi>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

// https://high.fi/api/?act=listSources&usedLanguage=Finnish&APIKEY=123
// { "responseData": { "newsSources": [ { "sourceName": "Aamulehti", "sourceID": 316, "paywall": "monthly-limit" }, { "sourceName": "Aamuposti", "sourceID": 317, "paywall": "strict-paywall" }, { "sourceName": "Aamuset", "sourceID": 318, "paywall": "free" }
class NewsSources: NSObject, NSCoding {
	let sourceName: String
    let sourceID: Int
    let paywall: String?
	var selected: Bool
	
    init(sourceName: String, sourceID: Int, paywall: String, selected: Bool) {
		self.sourceName = sourceName
		self.sourceID = sourceID
		self.selected = selected
        self.paywall = paywall
		super.init()
    }

	required init(coder decoder: NSCoder) {
        sourceName = decoder.decodeObject(of: NSString.self, forKey: "sourceName")! as String
        sourceID = decoder.decodeObject(forKey: "sourceID") as? Int ?? decoder.decodeInteger(forKey: "sourceID")
        paywall = decoder.decodeObject(of: NSString.self, forKey: "paywall") as String?
        selected = decoder.decodeObject(forKey: "selected") as? Bool ?? decoder.decodeBool(forKey: "selected")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(sourceName, forKey: "sourceName")
        coder.encode(sourceID, forKey: "sourceID")
        coder.encode(paywall, forKey: "paywall")
        coder.encode(selected, forKey: "selected")
    }
	
//    override var description: String {
//        return "NewsSources: sourceName=\(self.sourceName), sourceID=\(self.sourceID), paywall=\(String(describing: self.paywall)), selected=\(self.selected)"
//    }

}
