//
//  ContentView.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 2/24/21.
//

import SwiftUI
import Foundation

struct SnakeGameView: View {
    @State var timerOneSec = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    @StateObject var snake = Snake()
    @StateObject var thisGame = GeneralInfo()
    @EnvironmentObject var viewModel: AppViewModel
    
    //TODO: Move the timer to GameView
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // to updates the snake position every 0.1 second

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            /// Signe out button
            Button{
                viewModel.signOut()
            } label: {
                Text("Sign out")
            }
            Text(snake.getScoreLabel())
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
                            .onReceive(timerOneSec) { _ in
                                timerOneSec.upstream.connect().cancel()
                                thisGame.timePassed = 0
                            }
                        Button(action: {
                            snake.reset()
                            thisGame.reset(snakeSize: snake.snakeSize)
                            
                            timerOneSec = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
                        }, label: {
                            Text("Restart")
                        })
                    }
                    
                }
            }
            .onAppear() {
                thisGame.foodPos = thisGame.changeRectPos(snakeSize: snake.snakeSize)
                snake.posArray[0] = thisGame.changeRectPos(snakeSize: snake.snakeSize)
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
                    snake.changeDirection()
                    if snake.posArray[0] == thisGame.foodPos {
                        snake.posArray.append(snake.posArray[0])
                        thisGame.foodPos = thisGame.changeRectPos(snakeSize: snake.snakeSize)
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
            .onReceive(timerOneSec) { (_) in
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
