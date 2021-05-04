//
//  SearchParamsView.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 04/08/2019.
//  Copyright © 2019 Michał Buczek. All rights reserved.
//

import SwiftUI
import Combine
import Introspect

struct SearchParamsView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  
  @State private var searchInput = ""
  @State private var rhymePrecision: SearchParameters.RhymePrecision = .precise
  @State private var rhymeOrder: SearchParameters.SortOrder = .alphabetical
  @State private var rhymeLength = 3
  
  @ObservedObject var viewModel: RhymeFinderModel
  
  init(viewModel: RhymeFinderModel) {
    self.viewModel = viewModel
    
    UISegmentedControl.appearance().selectedSegmentTintColor = Color("App Orange Color").uiColor
    // Selected state is always white-on-orange
    UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
    // Non selected color depends on theme
    UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor : UIColor.secondaryLabel], for: .normal)
    
    UITextField.appearance().clearButtonMode = .whileEditing
  }
  
  var body: some View {
    VStack {
      inputTextField
      rhymeTypeSection
      orderSection
      rhymeLengthSection
      searchButton
      // On iPads, search form should take all vertical space,
      // results are shown in column to the right.
      if horizontalSizeClass == .regular {
        Spacer()
      }
    }
    .padding()
    .accentColor(Color("App Orange Color"))
  }
  
  // MARK: - Views
  
  private var inputTextField: some View  {
    TextField("Wpisz słowo do zrymowania", text: $searchInput)
      .textFieldStyle(RoundedBorderTextFieldStyle())
      .keyboardType(.alphabet)
      .disableAutocorrection(true)
      .onReceive(Just(searchInput)) { input in
        let polishCharactersWord = input.wordWithPolishCharactersOnly
        // Check for equality to avoid infinite loop.
        if self.searchInput != polishCharactersWord {
          self.searchInput = polishCharactersWord
        }
      }
  }
  
  private var rhymeTypeSection: some View {
    HStack(alignment: .center) {
      Text("Rodzaj rymów")
      Spacer()
      Picker(selection: $rhymePrecision, label: Text("Rodzaj rymów")) {
        Text("Dokładne").tag(SearchParameters.RhymePrecision.precise)
        Text("Niedokładne").tag(SearchParameters.RhymePrecision.nonPrecise)
      }
      .pickerStyle(SegmentedPickerStyle())
      .frame(width: 200)
    }
  }
  
  private var orderSection: some View {
    HStack(alignment: .center) {
      Text("Kolejność")
      Spacer()
      Picker(selection: $rhymeOrder, label: Text("Kolejność")) {
        Text("A-Z").tag(SearchParameters.SortOrder.alphabetical)
        Text("Losowo").tag(SearchParameters.SortOrder.random)
      }
      .pickerStyle(SegmentedPickerStyle())
      .frame(width: 200)
    }
  }
  
  private var rhymeLengthSection: some View {
    HStack(alignment: .center) {
      Text("Długość rymu")
      Spacer()
      HStack {
        Spacer()
        Text("\(rhymeLength)")
        Spacer()
        Stepper("", value: $rhymeLength, in: 2...9)
          .frame(width: 100)
      }
      .frame(width: 200)
    }
  }
  
  private var searchButton: some View {
    Button(action: findRhymesAction, label: {
      Text("Szukaj")
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 34)
        .background(Color("App Orange Color"))
        .accentColor(Color.white)
        .cornerRadius(5)
    })
    .disabled(viewModel.searchPending || searchInput.count < 2)
  }
  
  // MARK: - Actions
  
  private func findRhymesAction() {
    let params = SearchParameters(word: searchInput, sortMethod: rhymeOrder, rhymePrecision: rhymePrecision, rhymeLenght: rhymeLength)
    
    viewModel.findRhymes(with: params)
    
    let keyWindow = UIApplication.shared.connectedScenes
      .filter { $0.activationState == .foregroundActive }
      .compactMap { $0 as? UIWindowScene }
      .first?.windows
      .filter { $0.isKeyWindow }.first
    
    keyWindow?.endEditing(true)
  }
}

// MARK: - Preview
#if DEBUG
struct SearchParamsView_Previews: PreviewProvider {
  static var previews: some View {
    SearchParamsView(viewModel: RhymeFinderModel())
      .preferredColorScheme(.dark)
  }
}
#endif
