//
//  DataModels.swift
//  Haikara
//
//  Created by Marko Wallin on 27.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//
//
//  News.swift
//  NewsPages
//
//  Created by Marko Wallin on 21.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

// Examples
// categories: http://fi.high.fi/api/?act=listCategories&usedLanguage=finnish
// { "responseData": { "categories": [ { "title": "Kotimaa", "sectionID": 95, "depth": 1, "htmlFilename": "kotimaa" }, { "title": "Ulkomaat", "sectionID": 96, "depth": 1, "htmlFilename": "ulkomaat" }, { "title": "Talous", "sectionID": 94, "depth": 1, "htmlFilename": "talous" }, { "title": "Urheilu", "sectionID": 98, "depth": 1, "htmlFilename": "urheilu" } ] } }

class Category: NSObject {
    let title: String
    let sectionID: Int
    let depth: Int
    let htmlFilename: String
    
    init(title: String, sectionID: Int, depth: Int, htmlFilename: String) {
        self.title = title
        self.sectionID = sectionID
        self.depth = depth
        self.htmlFilename = htmlFilename
    }
    
    override var description: String {
        return "Category: title=\(self.title), sectionID=\(self.sectionID), depth=\(self.depth), htmlFilename=\(self.htmlFilename)"
    }
}

//{
//	"responseData": {
//		"feed": {
//			"title": "HIGH.FI",
//			"link": "http://fi.high.fi/",
//			"author": "AfterDawn Oy",
//			"description": "News",
//			"type": "json",
//			"entries": [
//{
//	"title": "string",
//	"link": "url",
//	"author": "string",
//	"publishedDateJS": "2015-06-16T22:46:08.000Z",
//	"publishedDate": "June, 16 2015 22:46:08",
//	"originalPicture": "url",
//	"picture": "url",
//	"shortDescription": "",
//	"originalURL": "url",
//	"mobileLink": "",
//	"originalMobileURL": "",
//	"articleID": int,
//	"sectionID": int,
//	"sourceID": int,
//	"highlight": true
//
//},

class Entry: NSObject {
    let title: String
    let link: String
    let author: String
    let publishedDateJS: String
    //	let picture: String?
    //	let originalPicture: String?
    var shortDescription: String?
    let originalURL: String
    var mobileLink: String?
    let originalMobileUrl: String?
    let articleID: Int
    var sectionID: Int
    let sourceID: Int
    let highlight: Bool
    var section: String
    
    init(title: String, link: String, author: String, publishedDateJS: String,
        shortDescription: String?, originalURL: String, mobileLink: String?, originalMobileUrl: String?, articleID: Int, sectionID: Int, sourceID: Int, highlight: Bool, section: String) {
            self.title = title
            self.link = link
            self.author = author
            self.publishedDateJS = publishedDateJS
            //	let picture: String?
            //	let originalPicture: String?
            self.shortDescription = shortDescription
            self.originalURL = originalURL
            self.mobileLink = mobileLink
            self.originalMobileUrl = originalMobileUrl
            self.articleID = articleID
            self.sectionID = sectionID
            self.sourceID = sourceID
            self.highlight = highlight
            self.section = section
    }
    
    override var description: String {
        return "Entry: title=\(self.title), link=\(self.link), author=\(self.author), published=\(self.publishedDateJS), desc=\(self.shortDescription), originalURL=\(self.originalURL), mobileLink=\(self.mobileLink), originalMobileUrl=\(self.originalMobileUrl), articleID=\(self.articleID), sectionID=\(self.sectionID), sourceID=\(self.sourceID), highlight=\(self.highlight), section=\(self.section)"
    }
}
