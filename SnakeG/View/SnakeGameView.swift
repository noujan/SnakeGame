//
//  ContentView.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 2/24/21.
//

import SwiftUI
import Foundation

struct SnakeGameView: View {
    
//    enum direction {
//        case up, down, left, right
//    }

//    @State var startPos : CGPoint = .zero // the start poisition of our swipe
//    @State var isStarted = true // did the user started the swipe?
//    @State var gameOver = false // for ending the game when the snake hits the screen borders
//    @State var dir = direction.down // the direction the snake is going to take
//    @State var posArray = [CGPoint(x: 20, y: 100)] // array of the snake's body positions
//    @State var foodPos = CGPoint(x: 0, y: 0) // the position of the food
//    @State var snakeSize : CGFloat = 10 // width and height of the snake
//    @State var scoreLabel = "score: 0"
//
//    @State var timerOneSec = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
//    @State var timePassed = 0
//
//    @State var score : Int = 0 {
//        didSet{
//            scoreLabel = "score: \(score)"
//        }
//    }
    var snake = Snake()
    var thisGame = GeneralInfo()
    @EnvironmentObject var viewModel: AppViewModel
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // to updates the snake position every 0.1 second

    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
        let minX = CGFloat(20)
    let maxX = UIScreen.main.bounds.maxX - 60
    let minY = CGFloat(20)
    let maxY = UIScreen.main.bounds.maxY - 220

    func changeRectPos() -> CGPoint {
        let rows = Int(maxX/snake.snakeSize)
        let cols = Int(maxY/snake.snakeSize)
        
        let randomX = Int.random(in: 1..<rows) * Int(snake.snakeSize)
        let randomY = Int.random(in: 1..<cols) * Int(snake.snakeSize)
        
        return CGPoint(x: randomX, y: randomY)
    }


    
    func changeDirection () {

        let posX = snake.posArray[0].x
        let posY = snake.posArray[0].y
        if posX < minX - snake.snakeSize {
            snake.posArray[0] = CGPoint(
                x: (maxX/10).rounded()*10 + snake.snakeSize,
                y: posY
            )
        } else if posX > maxX + snake.snakeSize {
            snake.posArray[0] = CGPoint(
                x: minX - snake.snakeSize,
                y: posY
            )
        } else if posY < minY - snake.snakeSize {
            print("posY up: \(posY), minY: \(minY)")
            snake.posArray[0] = CGPoint(
                x: posX,
                y: (maxY/10).rounded()*10 + 5 * snake.snakeSize
            )
        } else if posY > maxY + 4 * snake.snakeSize {
            print("posY down: \(posY), maxY: \((maxY/10).rounded()*10)")
            snake.posArray[0] = CGPoint(
                x: posX,
                y: minY - 2 * snake.snakeSize
            )
        }

        var prev = snake.posArray[0]
        if snake.dir == .down {
            snake.posArray[0].y += snake.snakeSize
        } else if snake.dir == .up {
            snake.posArray[0].y -= snake.snakeSize
        } else if snake.dir == .left {
            snake.posArray[0].x += snake.snakeSize
        } else {
            snake.posArray[0].x -= snake.snakeSize
        }
        for index in 1..<snake.posArray.count {
            let current = snake.posArray[index]
            snake.posArray[index] = prev
            prev = current
        }
    }

    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            /// Signe out button
            Button{
                viewModel.signOut()
            } label: {
                Text("Sign out")
            }
            Text(snake.scoreLabel)
                .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
            ZStack {
                Color.pink.opacity(0.3)
                ZStack {
                    ForEach (0..<snake.posArray.count, id: \.self) { index in
                        Rectangle()
                            .frame(width: snake.snakeSize, height: snake.snakeSize)
                            .position(snake.posArray[index])
                    }
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: snake.snakeSize, height: snake.snakeSize)
                        .position(thisGame.foodPos)
                }
                
                if snake.gameOver {
                    VStack{
                        Text("Game Over")
                            .onReceive(thisGame.timerOneSec) { _ in
                                thisGame.timerOneSec.upstream.connect().cancel()
                                thisGame.timePassed = 0
                            }
                        Button(action: {
                            snake.posArray = [CGPoint(x: 20, y: 100)]
                            snake.gameOver = false
                            snake.startPos = .zero
                            snake.snakeSize = 10
                            snake.isStarted = true
                            snake.dir = direction.down
                            thisGame.foodPos = CGPoint(x: 0, y: 0)
                            thisGame.foodPos = self.changeRectPos()
                            
                            
                            thisGame.timerOneSec = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
                        }, label: {
                            Text("Restart")
                        })
                    }
                    
                }
            }
            .onAppear() {
                thisGame.foodPos = self.changeRectPos()
                snake.posArray[0] = self.changeRectPos()
            }
            .gesture(DragGesture()
                        .onChanged { gesture in
                            if snake.isStarted {
                                snake.startPos = gesture.location
                                snake.isStarted.toggle()
                            }
                            
                        }
                        .onEnded {  gesture in
                            let xDist =  abs(gesture.location.x - snake.startPos.x)
                            let yDist =  abs(gesture.location.y - snake.startPos.y)
                            if snake.startPos.y <  gesture.location.y && yDist > xDist {
                                snake.dir = direction.down
                            }
                            else if snake.startPos.y >  gesture.location.y && yDist > xDist {
                                snake.dir = direction.up
                            }
                            else if snake.startPos.x > gesture.location.x && yDist < xDist {
                                snake.dir = direction.right
                            }
                            else if snake.startPos.x < gesture.location.x && yDist < xDist {
                                snake.dir = direction.left
                            }
                            snake.isStarted.toggle()
                        }
                        
            )
            .onReceive(timer) { (_) in
                if !snake.gameOver {
                    self.changeDirection()
                    if snake.posArray[0] == thisGame.foodPos {
                        snake.posArray.append(snake.posArray[0])
                        thisGame.foodPos = self.changeRectPos()
                        thisGame.timePassed = thisGame.timePassed / 2
                    } else {
                        let tempArr = snake.posArray.dropFirst()
                        if tempArr.contains(snake.posArray[0]) {
                            print("No no - You are done! game over!")
                            snake.gameOver.toggle()
                        }
                    }
                    
                }
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
            .onReceive(thisGame.timerOneSec) { (_) in
                thisGame.timePassed += 1
                snake.score = thisGame.timePassed
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SnakeGameView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
        }
        
    }
}
