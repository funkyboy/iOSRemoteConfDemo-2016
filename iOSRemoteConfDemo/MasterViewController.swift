//
//  MasterViewController.swift
//  iOSRemoteConfDemo
//
//  Created by Cesare Rocchi on 12/04/16.
//  Copyright © 2016 Cesare Rocchi. All rights reserved.
//

import UIKit
import WebKit

let MESSAGE_HANDLER = "didFetchSpeakers"

class MasterViewController: UITableViewController, WKScriptMessageHandler {

  var detailViewController: DetailViewController? = nil
  var speakers = [Speaker]()
  var speakersWebView:WKWebView?


  override func viewDidLoad() {
    super.viewDidLoad()
    title = "iOS Remote Conf Speakers"
    
    let speakersWebViewConfiguration = WKWebViewConfiguration()
    let scriptURL = NSBundle.mainBundle().pathForResource("fetchSpeakers", ofType: "js")
    
    let jsScript = try? String(contentsOfFile:scriptURL!,
                               encoding:NSUTF8StringEncoding)
    
    if let jsScript = jsScript {
      let fetchAuthorsScript = WKUserScript(source: jsScript, injectionTime: .AtDocumentEnd,
                                            forMainFrameOnly: true)
      speakersWebViewConfiguration.userContentController.addUserScript(fetchAuthorsScript)
      speakersWebViewConfiguration.userContentController.addScriptMessageHandler(self, name: MESSAGE_HANDLER)
      
      speakersWebView = WKWebView(frame: CGRectZero, configuration:speakersWebViewConfiguration)
      
      if let speakersWebView = speakersWebView {
        speakersWebView.addObserver(self, forKeyPath: "loading", options: .New,context: nil)
        speakersWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        let speakersURL = NSURL(string:"https://allremoteconfs.com/ios-2016");
        let speakersRequest = NSURLRequest(URL:speakersURL!)
        speakersWebView.loadRequest(speakersRequest)
      }
    }
  }
  
  func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
    if (message.name == MESSAGE_HANDLER) {
      if let resultArray = message.body as? [Dictionary<String, String>] {
        for d in resultArray {
          let speaker = Speaker(dictionary: d)
          speakers.append(speaker);
        }
      }
      tableView.reloadData()
    }
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
    
    if let key = keyPath {
      switch key {
        
      case "loading":
        UIApplication.sharedApplication().networkActivityIndicatorVisible = speakersWebView!.loading
        
      case "estimatedProgress":
        print("progress = \(speakersWebView!.estimatedProgress)")
        
      default:
        print("unknown key")
        
      }
    }
    
  }
  
  

  override func viewWillAppear(animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    super.viewWillAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  // MARK: - Segues

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      // This method is intentionally left blank
    }
  }

  // MARK: - Table View

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return speakers.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    
    cell.tag = indexPath.row;
    let speaker = speakers[indexPath.row]
    cell.textLabel?.text = speaker.speakerName
    
    // There's a better way, I was just in a hurry :)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
      if let url = NSURL(string:speaker.avatarURL) {
        
        
        if let imageData = NSData(contentsOfURL: url) {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            if (cell.tag == indexPath.row) {
              cell.imageView?.image = UIImage(data:imageData)
              cell.setNeedsLayout()
            }
            
          })
        }
        
      }
      
    })
    
    return cell
  }

  


}

