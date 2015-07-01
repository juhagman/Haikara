//
//  ViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 15.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

import Alamofire

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	let cellIdentifier = "tableCell"
	var entries = NSMutableOrderedSet()
	let settings = Settings.sharedInstance
	
	var sections = OrderedDictionary<String, Array<Entry>>()
	var sortedSections = [String]()
	
	// default section
	var highFiSection: String = "uutiset"
	
	var navigationItemTitle: String = "Uutiset";

	@IBOutlet weak var tableView: UITableView!

	var refreshControl:UIRefreshControl!

	let calendar = NSCalendar.autoupdatingCurrentCalendar()
	let dateFormatter = NSDateFormatter()
	
	// MARK: Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.title = navigationItemTitle
		self.tableView!.dataSource = self

		setHeaders()
		
		configureTableView()
		
		dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT");
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000'Z'"

		getHighFiJSON()
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl.attributedTitle = NSAttributedString(string: "Vedä alas päivittääksesi")
		self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
		self.tableView.addSubview(refreshControl)
    }
	
	func setHeaders() {
		// Specifying the Headers
		Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
			"User-Agent": settings.appID,
			"Cache-Control": "private, must-revalidate, max-age=60"
		]
	}
	
	func configureTableView() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 75.0
	}
	
	func refresh(sender:AnyObject) {
//		println("refresh: \(sender)")
		getHighFiJSON()
	}
	
	// MARK: - Navigation

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using [segue destinationViewController].
		// Pass the selected object to the new view controller.
		if segue.identifier == "NewsItemDetails" {
			let path = self.tableView!.indexPathForSelectedRow()!
			let row = path.row
			
			let tableSection = sections[sortedSections[path.section]]
			let tableItem = tableSection![row]
			
//			println("mobileLink= \(tableItem.mobileLink), link= \(tableItem.link)")
			(segue.destinationViewController as! NewsItemViewController).title = tableItem.title
			if (tableItem.mobileLink?.isEmpty != nil) {
				(segue.destinationViewController as! NewsItemViewController).webSite = tableItem.originalURL
			} else {
				(segue.destinationViewController as! NewsItemViewController).webSite = tableItem.mobileLink
			}
			
			// make a silent HTTP GET request to the click tracking URL provided in the JSON's link field
			Alamofire.request(.GET, tableItem.link, parameters: ["APIKEY": settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID])
				.response { (request, response, data, error) in
					#if DEBUG
						println(request)
//						println(response)
//						println(error)
					#endif
			}
		}
	}

    // MARK: - Table view data source

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
		return self.sections.count
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
		return self.sections[sortedSections[section]]!.count
    }
	
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		// Configure the cell for this indexPath
		let cell: EntryCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? EntryCell

		let tableSection = sections[sortedSections[indexPath.section]]
		let tableItem = tableSection![indexPath.row]
//		println("tableItem=\(tableItem)")
		cell.entryTitle.text = tableItem.title
		cell.entryAuthor.text = tableItem.author
		if tableItem.shortDescription != "" {
			cell.entryDescription!.text = tableItem.shortDescription
		}
		if tableItem.highlight == true {
			cell.highlighted = true
		}
		
		return cell
    }
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sortedSections[section]
	}
	
    func getHighFiJSON(){
		let feed = "http://" + settings.domainToUse + "/" + highFiSection + "/" + settings.highFiEndpoint
		
		Manager.sharedInstance.request(.GET, feed, parameters: ["APIKEY": settings.APIKEY])
			.responseJSON() { (request, response, data, error) in
				#if DEBUG
					println("request: \(request)")
//					println("response: \(response)")
//					println("json: \(theJSON)")
				#endif
				
			if error == nil {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
					let responseData = (data!.valueForKey("responseData") as! NSDictionary)
					let feed = (responseData.valueForKey("feed") as! NSDictionary)
					let entries = (feed.valueForKey("entries") as! [NSDictionary])
						//.filter({ ($0["sectionID"] as! Int) == 98 })
						.map { Entry(
							title: $0["title"] as! String,
							link: $0["link"] as! String,
							author: $0["author"] as! String,
							publishedDateJS: $0["publishedDateJS"] as! String,
							shortDescription: $0["shortDescription"] as? String,
							originalURL: $0["originalURL"] as! String,
							mobileLink: $0["mobileLink"] as? String,
							originalMobileUrl: $0["originalMobileUrl"] as?	String,
							//	let picture: String?
							//	let originalPicture: String?
							articleID: $0["articleID"] as! Int,
							sectionID: $0["sectionID"] as! Int,
							sourceID: $0["sourceID"] as! Int,
							highlight: $0["highlight"] as! Bool,
							timeSince: "Juuri nyt"
						)
					}
//					println("entries: \(entries.count)")
					
					for item in entries {
						item.timeSince = self.getTimeSince(item.publishedDateJS)
					}
					
					dispatch_async(dispatch_get_main_queue()) {
						self.entries = NSMutableOrderedSet()
						self.entries.addObjectsFromArray(entries)
						//println("newsEntries=\(self.newsEntries.count)")
						
						// Put each item in a section
						for item in self.entries {
							// If we don't have section for particular time, create new one,
							// Otherwise just add item to existing section
							var entry = item as! Entry
//							println("section=\(entry.section), title=\(entry.title)")
							if self.sections[entry.timeSince] == nil {
								self.sections[entry.timeSince] = [entry]
							} else {
								self.sections[entry.timeSince]!.append(entry)
							}

							// Storing sections in dictionary, so we need to sort it
							self.sortedSections = self.sections.keys //.array.sorted(<)
						}
						//println("sections=\(self.sections.count)")
						
						self.tableView!.reloadData()
						self.refreshControl?.endRefreshing()
						return
					}
				}
			} else {
				println("error: \(error)")
			}
		}
	}
	
	func getTimeSince(item: String) -> String {
		//println("getTimeSince: \(item)")
		if let startDate = dateFormatter.dateFromString(item) {
			let components = calendar.components(
				NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: startDate, toDate: NSDate(), options: nil)
			let days = components.day
			let hours = components.hour
			let minutes = components.minute
//			println("\(days) days, \(hours) hours, \(minutes) minutes")
			
			if days == 0 {
				if hours == 0 {
					if minutes < 0 { return "Juuri nyt" }
					else if minutes < 5 { return "< 5 minuuttia" }
					else if minutes < 15 { return "< 15 minuuttia" }
					else if minutes < 30 { return "< 30 minuuttia" }
					else if minutes < 45 { return "< 45 minuuttia" }
					else if minutes < 60 { return "< tunti" }
				} else {
					if hours < 24 { return "< \(hours) tuntia" }
				}
			} else {
				if days == 1 {
					return "Eilen"
				} else {
					return "\(days) päivää"
				}
			}
		}
		
		return "0"
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}
