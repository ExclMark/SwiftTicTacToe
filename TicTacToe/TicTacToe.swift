//
//  TicTacToe.swift
//  TicTacToe
//
//  Created by null on 05/09/2023.
//

import Foundation
import SwiftUI

struct Board {
    let pos: [SquareStatus]
    let turn: SquareStatus
    let lastMove: Int
    let opposite: SquareStatus
    
    init(position: [SquareStatus] = [.empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty], turn: SquareStatus = .x, lastMove: Int = -1) {
        self.pos = position
        self.turn = turn
        self.lastMove = lastMove
        self.opposite = turn == .x ? .o : .x
    }
    
    func move(_ location: Int) -> Board {
        var tempPosition = pos
        tempPosition[location] = turn
        return Board(position: tempPosition, turn: opposite, lastMove: location)
    }
    
    var legalMoves: [Int] {
        return pos.indices.filter { pos[$0] == .empty }
    }
    
    var isWin: Bool {
        return pos[0] == pos[1] && pos[0] == pos[2] && pos[0] != .empty ||
        pos[3] == pos[4] && pos[3] == pos[5] && pos[3] != .empty ||
        pos[6] == pos[7] && pos[6] == pos[8] && pos[6] != .empty ||
        pos[0] == pos[3] && pos[0] == pos[6] && pos[0] != .empty ||
        pos[1] == pos[4] && pos[1] == pos[7] && pos[1] != .empty ||
        pos[2] == pos[5] && pos[2] == pos[8] && pos[2] != .empty ||
        pos[0] == pos[4] && pos[0] == pos[8] && pos[0] != .empty ||
        pos[2] == pos[4] && pos[2] == pos[6] && pos[2] != .empty
    }
    
    var isDraw: Bool {
        return !isWin && legalMoves.count == 0
    }
    
    func minimax(_ board: Board, maximizing: Bool, originalPlayer: SquareStatus) -> Int {
        if board.isWin && originalPlayer == board.opposite { return 1 }
        else if board.isWin && originalPlayer != board.opposite { return -1 }
        else if board.isDraw { return 0 }
      
        if maximizing {
            var bestEval = Int.min
            for move in board.legalMoves {
                let result = minimax(board.move(move), maximizing: false, originalPlayer: originalPlayer)
                bestEval = max(result, bestEval)
            }
            return bestEval
        } else {
            var worstEval = Int.max
            for move in board.legalMoves {
                let result = minimax(board.move(move), maximizing: true, originalPlayer: originalPlayer)
                worstEval = min(result, worstEval)
            }
            return worstEval
        }
    }
    
    func findBestMove(_ board: Board) -> Int {
        var bestEval = Int.min
        var bestMove = -1
        for move in board.legalMoves {
            let result = minimax(board.move(move), maximizing: false, originalPlayer: board.turn)
            if result > bestEval {
                bestEval = result
                bestMove = move
            }
        }
        return bestMove
    }
}

@MainActor
class TicTacToeModel: ObservableObject {
    @Published var squares = [Square]()
    @Published var playerToMove: Bool = false
    @ObservedObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        for _ in 0...8 {
            squares.append(Square(status: .empty))
        }
    }
    
    func resetGame() -> Void {
        for i in 0...8 {
            squares[i].squareStatus = .empty
            playerToMove = false
        }
    }
    
    var gameOver: (SquareStatus, Bool) {
        get {
            if viewModel.gameOver == false {
                if winner.0 != .empty {
                    colorize(check: winner.0, row: winner.1)
                    viewModel.winner = winner.0
                    return (winner.0, true)
                } else {
                    for i in 0...8 {
                        if squares[i].squareStatus == .empty {
                            return (.empty, false)
                        }
                    }
                    viewModel.gameOver = true
                    return (.empty, true)
                }
            }
            return (.empty, false)
        }
    }
    
    func colorize(check: SquareStatus, row: [Int]) {
        withAnimation {
            if check == .x {
                squares[row[0]].squareStatus = .xw
                squares[row[1]].squareStatus = .xw
                squares[row[2]].squareStatus = .xw
            } else {
                squares[row[0]].squareStatus = .ow
                squares[row[1]].squareStatus = .ow
                squares[row[2]].squareStatus = .ow
            }
        }
        viewModel.gameOver = true
//        print(viewModel.gameOver)
//        return (check, true)
    }
    
    func makeMove(index: Int, gameType: Bool) -> Bool {
        var player: SquareStatus
        if playerToMove == false {
            player = .x
        } else {
            player = .o
        }
        if squares[index].squareStatus == .empty {
            squares[index].squareStatus = player
            if playerToMove == false && gameType == false && gameOver.1 == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.moveAI()
                    ContentView.triggerHapticFeedback(type: 2)
                    _ = self.gameOver
//                    self.playerToMove = true
                }
            }
            playerToMove.toggle()
            _ = self.gameOver
            return true
        }
        return false
    }
    
    var getBoard: [SquareStatus] {
        var moves: Array = [SquareStatus]()
        for i in 0...8 {
            moves.append(squares[i].squareStatus)
        }
        return moves
    }
    
    private func moveAI() {
        let boardMoves: [SquareStatus] = getBoard
        let testBoard: Board = Board(position: boardMoves, turn: .o, lastMove: -1)
        let answer = testBoard.findBestMove(testBoard)
        playerToMove = true
        _ = makeMove(index: answer, gameType: true)
    }
    
    private var winner: (SquareStatus, [Int]) {
        get {
            if let check = self.checkIndexes([0, 1, 2]) {
                return (check, [0, 1, 2])
            } else if let check = self.checkIndexes([3, 4, 5]) {
                return (check, [3, 4, 5])
            } else if let check = self.checkIndexes([6, 7, 8]) {
                return (check, [6, 7, 8])
            } else if let check = self.checkIndexes([0, 3, 6]) {
                return (check, [0, 3, 6])
            } else if let check = self.checkIndexes([1, 4, 7]) {
                return (check, [1, 4, 7])
            } else if let check = self.checkIndexes([2, 5, 8]) {
                return (check, [2, 5, 8])
            } else if let check = self.checkIndexes([0, 4, 8]) {
                return (check, [0, 4, 8])
            } else if let check = self.checkIndexes([2, 4, 6]) {
                return (check, [2, 4, 6])
            }
            return (.empty, [])
        }
    }
    
    private func checkIndexes(_ indexes : [Int]) -> SquareStatus? {
        var xCount : Int = 0
        var oCount : Int = 0
        for index in indexes {
            let square = squares[index]
            if square.squareStatus == .x || square.squareStatus == .xw {
                xCount += 1
            } else if square.squareStatus == .o || square.squareStatus == .ow {
                oCount += 1
            }
        }
        if xCount == 3 {
            return .x
        } else if oCount == 3 {
            return .o
        }
        return nil
    }
}
