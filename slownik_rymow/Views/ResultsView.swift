//
//  ResultsView.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 04/05/2021.
//  Copyright © 2021 Michał Buczek. All rights reserved.
//

import SwiftUI

struct ResultsView: View {
  
  @ObservedObject var viewModel: RhymeFinderModel
  
  var body: some View {
    if viewModel.searchPending {
      Spacer()
      ProgressView()
      Spacer()
    } else {
      FoundRhymesListView(foundRhymes: $viewModel.foundRhymesState)
    }
  }
}

struct ResultsView_Previews: PreviewProvider {
  static var previews: some View {
    ResultsView(viewModel: RhymeFinderModel())
  }
}
