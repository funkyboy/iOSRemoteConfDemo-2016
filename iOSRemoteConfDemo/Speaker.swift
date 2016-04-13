//
//  Speaker.swift
//  iOSRemoteConfDemo
//
//  Created by Cesare Rocchi on 12/04/16.
//  Copyright © 2016 Cesare Rocchi. All rights reserved.
//

import UIKit

class Speaker: NSObject {
  var speakerName: String = ""
  var avatarURL: String = ""
  
  init(dictionary: NSDictionary) {
    self.speakerName = dictionary["speakerName"] as! String
    let s = dictionary["avatarURL"] as! String
    self.avatarURL = s
    super.init()
  }
}
