//
//  BorderTextField.swift
//  Slownik Rymow
//
//  Created by bucci on 31.03.2015.
//  Copyright (c) 2016 Michał Buczek. All rights reserved.
//

import UIKit

@IBDesignable
class BorderTextField: UITextField {
  
  @IBInspectable var color: UIColor = UIColor.orange {
    didSet {
      setupView()
    }
  }
  
  @IBInspectable var borderWidth: CGFloat = 1.0 {
    didSet {
      setupView()
    }
  }
  
  @IBInspectable var cornerRadius: CGFloat = 5.0 {
    didSet {
      setupView()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
    
  }
  
  
  func setupView() {
    self.layer.cornerRadius = cornerRadius
    self.layer.borderColor = color.cgColor
    self.layer.borderWidth = borderWidth
    self.tintColor = color
    self.textColor = color
    
    self.setNeedsDisplay()
  }
  
}
