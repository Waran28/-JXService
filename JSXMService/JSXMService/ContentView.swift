//
//  ContentView.swift
//  JSXMService
//
//  Created by New on 2025-01-08.
//

import SwiftUI


struct ContentView: View {
    
    @StateObject private var viewModel = ModelClass()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Globe Hello world!")
                .onTapGesture {
                    viewModel.fetchXMLData()
                }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
