//
//  ContentView.swift
//  slownik_rymow
//
//  Created by Michał Buczek on 04/08/2019.
//  Copyright © 2019 Michał Buczek. All rights reserved.
//

import SwiftUI
import Introspect
import Models

public struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @StateObject private var viewModel = RhymeFinderModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Group {
                if horizontalSizeClass == .compact {
                    VStack {
                        SearchParamsView(viewModel: viewModel)
                        ResultsView(viewModel: viewModel)
                    }
                } else {
                    VStack {
                        HStack {
                            SearchParamsView(viewModel: viewModel)
                                .frame(idealWidth: 400, maxWidth: 500)
                                .fixedSize(horizontal: true, vertical: false)
                            ResultsView(viewModel: viewModel)
                        }
                        Spacer()
                    }
                    
                }
            }
            .navigationBarTitle("Słownik Rymów", displayMode: .inline)
            .navigationBarColor(Color("Navigation Bar Color"), textColor: .white)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
