//
//  TicTacToeApp.swift
//  TicTacToe
//
//  Created by null on 05/09/2023.
//

import SwiftUI

@main
struct TicTacToeApp: App {
    let viewModel = ViewModel()
    let ticTacToe: TicTacToeModel
    
    init() {
        self.ticTacToe = TicTacToeModel(viewModel: viewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel, ticTacToe: ticTacToe)
        }
    }
}
