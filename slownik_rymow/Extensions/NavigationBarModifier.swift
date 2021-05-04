//
//  NavigationBarModifier.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 03/05/2021.
//  Copyright © 2021 Michał Buczek. All rights reserved.
//

import SwiftUI

struct NavigationBarModifier: ViewModifier {
  
  private let backgroundColor: Color
  
  init(backgroundColor: Color?, textColor: Color) {
    self.backgroundColor = backgroundColor ?? .clear
    let coloredAppearance = UINavigationBarAppearance()
    coloredAppearance.configureWithTransparentBackground()
    coloredAppearance.backgroundColor = .clear
    coloredAppearance.titleTextAttributes = [.foregroundColor: textColor.uiColor]
    coloredAppearance.largeTitleTextAttributes = [.foregroundColor: textColor.uiColor]
    
    UINavigationBar.appearance().standardAppearance = coloredAppearance
    UINavigationBar.appearance().compactAppearance = coloredAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    UINavigationBar.appearance().tintColor = textColor.uiColor
  }
  
  func body(content: Content) -> some View {
    ZStack{
      content
      VStack {
        GeometryReader { geometry in
          self.backgroundColor
            .frame(height: geometry.safeAreaInsets.top)
            .edgesIgnoringSafeArea([.top, .leading, .trailing])
          Spacer()
        }
      }
    }
  }
}

extension View {
  
  func navigationBarColor(_ backgroundColor: Color?, textColor: Color) -> some View {
    self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, textColor: textColor))
  }
  
}
