//
//  BorderButtonView.swift
//  Slownik Rymow
//
//  Created by bucci on 23.03.2015.
//  Copyright (c) 2016 Michał Buczek. All rights reserved.
//

import UIKit

@IBDesignable
class BorderButtonView: UIButton {
  
  @IBInspectable var color: UIColor = UIColor.orange {
    didSet {
      setupView()
    }
  }
  
  @IBInspectable var borderWidth: CGFloat = 1.5 {
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
    self.tintColor = UIColor.white
    self.backgroundColor = color
    self.titleLabel?.textColor = UIColor.white
    
    
    self.setNeedsDisplay()
  }
  
}
