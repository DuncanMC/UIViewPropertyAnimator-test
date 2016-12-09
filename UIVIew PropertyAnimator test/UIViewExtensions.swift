//
//  UIViewExtensions.swift
//  SwiftTestProject
//
//  Created by Duncan Champney on 4/23/15.
//  Copyright (c) 2015 Duncan Champney. All rights reserved.
//

import Foundation
import UIKit

protocol LayerProperties {
  var borderWidth: CGFloat {get set}
  var borderColor: UIColor {get set}
  var cornerRadius: CGFloat {get set}
}

/**
 This extension to UIView exposes some properties of its backing layer and, with an `@IBInspectable` tag, allows those properties to be set from Interface Builder.
 */

extension UIView: LayerProperties {
  
  @IBInspectable
  var borderWidth: CGFloat {
    get {
      return self.layer.borderWidth
    }
    set {
      self.layer.borderWidth = newValue
    }
  }
  @IBInspectable
  var borderColor: UIColor {
    get {
      return UIColor(cgColor: self.layer.borderColor!)
    }
    set {
      self.layer.borderColor = newValue.cgColor
    }
  }
  @IBInspectable

  var cornerRadius: CGFloat {
    get {
      return self.layer.cornerRadius
    }
    set {
      self.layer.cornerRadius = newValue
    }
  }

}
