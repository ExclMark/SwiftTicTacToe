//
//  ContentView.swift
//  TicTacToe
//
//  Created by null on 05/09/2023.
//

import SwiftUI
import UIKit
import Combine
import Foundation

class ViewModel: ObservableObject {
    @Published var gameOver: Bool = false
    @Published var winner: SquareStatus = .empty
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var ticTacToe: TicTacToeModel
    @State var selection: Bool = false
    @State var move: Bool = false
    @State private var vibro: Bool = true
    @State var popup: Bool = false
    
    static func setVibro(mode: Bool) {
        UserDefaults.standard.set(mode, forKey: "vibro")
    }
    
    static func triggerHapticFeedback(type: Int, overrdie: Bool = false) {
        let vibro = Foundation.UserDefaults.standard.value(forKey: "vibro") as? Bool
        if vibro == true || overrdie == true {
            if type == 1 {
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.impactOccurred()
            } else if type == 2 {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            } else if type == 3 {
                let generator = UIImpactFeedbackGenerator(style: .rigid)
                generator.impactOccurred()
            } else if type == 4 {
                let generator = UIImpactFeedbackGenerator(style: .rigid)
                generator.impactOccurred()
            }
        }
    }
    
    static func showAIAlert(won: SquareStatus, reset: @escaping () -> Void) -> Alert {
        return Alert(title: Text("Game Over"),
              message: Text(won != .empty ? won == .x ? "You Won!" : "AI Won!" : "Draw!"),
              dismissButton: Alert.Button.destructive(Text("Ok"), action: reset)
        )
    }
    
    static func showPVPAlert(won: SquareStatus, reset: ()) -> Alert {
        Alert(title: Text("Game Over"),
              message: Text(won != .empty ? won == .x ? "X won!" : "O Won!" : "Draw!"),
              dismissButton: Alert.Button.destructive(Text("Ok"), action: { reset }
        ))
    }
    
    func buttonAction(_ index : Int) {
        if (self.ticTacToe.playerToMove == false && selection == false) || selection == true {
            _ = self.ticTacToe.makeMove(index: index, gameType: selection)
        }
        ContentView.triggerHapticFeedback(type: 2)
    }
    
    var currPlayer: String {
        return self.ticTacToe.playerToMove == false ? "X" : "O"
    }
    
    var AIMove: String {
        return self.ticTacToe.playerToMove == false ? "Your" : "AI"
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    ContentView.triggerHapticFeedback(type: 1, overrdie: true)
                    vibro.toggle()
                    ContentView.setVibro(mode: vibro)
                }) {
                    let icon = vibro == true ? "iphone.radiowaves.left.and.right" : "iphone.slash"
                    let padd: CGFloat = vibro == true ? 25 : 31
                    Image(systemName: icon)
                        .padding(.horizontal, padd)
                        .cornerRadius(10)
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7))
                }
                Picker(selection: $selection, label: Text("Game")) {
                    Text("AI").tag(false)
                    Text("PVP").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 10)
                .onChange(of: selection) { _ in
                    self.ticTacToe.resetGame()
                    ContentView.triggerHapticFeedback(type: 1)
                }
                ZStack {
                    Button(action: {
                        ContentView.triggerHapticFeedback(type: 4)
                        popup.toggle()
                    }) {
                        Image(systemName: "info.circle")
                            .padding(.horizontal, 30)
                            .cornerRadius(10)
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7))
                    }
                }
                .popover(isPresented: $popup) {
                    ZStack { // 4
                        VStack{
                            RoundedRectangle(cornerRadius: 10)
                                .padding(.horizontal, 40)
                                .frame(height: 5)
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7))
                            Text("TicTacToe")
                                .bold()
                                .font(.system(size: 80))
                                .padding(.top, 20)
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7))
                            Text("Demo Swift App, made by ExclMark")
                                .bold()
                                .font(.title3)
//                                .padding(.top)
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7))
//                                .padding(.horizontal, 80)
                            Link("GitHub Page", destination: URL(string: "https://github.com/ExclMark/SwiftTicTacToe")!)
                                .font(.headline)
                                .padding(.top, 3)
                            Spacer(minLength: 5)
                            Image("PreviewImage")
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(0.5)
                        }
                        .padding(.top, 3)
                    }
                }
            }
            Spacer()
            
            Text(self.selection == false ? "Tic Tac Toe - AI" : "Tic Tac Toe - PVP")
                .bold()
                .font(.title)
            //.padding(.bottom)
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7))
            
            Text(self.selection == true ? "\(currPlayer) to move" : "\(AIMove) move")
                .bold()
                .font(.title2)
                .padding(.bottom)
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7))
            
            ForEach(0 ..< ticTacToe.squares.count / 3, id: \.self, content: { row in
                HStack {
                    ForEach(0 ..< 3, content: { column in
                        let index = row * 3 + column
                        SquareView(dataSouce: ticTacToe.squares[index], action: { self.buttonAction(index) })
                    })
                }
            })
            
            Spacer()
            
            Button(action: {
                self.ticTacToe.resetGame()
                ContentView.triggerHapticFeedback(type: 3)
            }, label: {
                Text("Reset")
                    .foregroundColor(Color.red.opacity(0.7))
            })            .alert(isPresented: $viewModel.gameOver, content: {
                var text = ""
                if self.selection == false {
                    if viewModel.winner == .x { text = "You won!" }
                    else if viewModel.winner == .o { text = "AI won!" }
                    else { text = "Draw!" }
                } else {
                    if viewModel.winner == .x { text = "X won!" }
                    else if viewModel.winner == .o { text = "O won!" }
                    else { text = "Draw!" }
                }
                return Alert(title: Text(text),
                      dismissButton: Alert.Button.cancel(Text("Ok"), action: {
                    self.ticTacToe.resetGame()
                    viewModel.gameOver = false
                    viewModel.winner = .empty
                })
                )
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ViewModel()
        let ticTacToe = TicTacToeModel(viewModel: viewModel)
        return ContentView(viewModel: viewModel, ticTacToe: ticTacToe)
    }
}
