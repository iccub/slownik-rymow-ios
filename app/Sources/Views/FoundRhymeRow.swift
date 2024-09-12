//
//  FoundRhymeRow.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 06/08/2019.
//  Copyright © 2019 Michał Buczek. All rights reserved.
//

import SwiftUI
import Models

struct FoundRhymeRow: View {
  let rhyme: String
  
  @ObservedObject var viewModel = SJPParser()
  
  var body: some View {
    Button(action: {
      self.viewModel.parse(word: self.rhyme)
    }) {
      Text(rhyme)
    }
    .alert(isPresented: $viewModel.showAlert) {
      return Alert(title: Text(rhyme), message: Text(viewModel.wordDefinition), dismissButton: .default(Text("OK")))
    }
  }
}

#if DEBUG
struct FoundRhymeRow_Previews: PreviewProvider {
  static var previews: some View {
    FoundRhymeRow(rhyme: "test")
  }
}
#endif
