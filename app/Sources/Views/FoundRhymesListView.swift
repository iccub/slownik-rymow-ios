//
//  FoundRhymesListView.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 04/08/2019.
//  Copyright © 2019 Michał Buczek. All rights reserved.
//

import SwiftUI
import Combine
import Models

struct FoundRhymesListView: View {
  @Binding var foundRhymes: FoundRhymesState
  
  var body: some View {
    
    switch foundRhymes {
    case .initial:
      Spacer()
      Text("Tutaj pojawią się znalezione przez ciebie rymy")
        .font(.footnote)
        .foregroundColor(.secondary)
      Spacer()
    case .found(let rhymes):
      List(rhymes) { rhyme in
        FoundRhymeRow(rhyme: rhyme.id)
      }
      .listStyle(PlainListStyle())
    case .noResults:
      Spacer()
      Text("Brak wyników")
      Spacer()
    }
  }
}

#if DEBUG
struct FoundRhymesListView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      VStack {
        FoundRhymesListView(
          foundRhymes: .constant(.found(rhymes: [Rhyme(id: "Test1"), Rhyme(id: "Test2")])))
        FoundRhymesListView(foundRhymes: .constant(.initial))
      }
    }
    
  }
}
#endif
