//
//  ContentView.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 2/24/21.
//

import SwiftUI
import Foundation

struct SnakeGameView: View {
    //TODO: Move the timer to GameView
    @State var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // to updates the snake position every 0.1 second
    @State private var showingMenu = false
    @StateObject var snake = Snake()
    @StateObject var thisGame = GeneralInfo()
    @EnvironmentObject var viewModel: AuthViewModel
    
    fileprivate func Pause() {
        //Mark: This pausees the game and timer.
        timer.upstream.connect().cancel()
        //TODO: Open the menu so I can show the options.
        showingMenu = true
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
            //MARK: Pause Button
            Button {
                Pause()
            } label: {
                Text("Pause")
            }
            .sheet(isPresented: $showingMenu) {
                MenuView(isPresented: $showingMenu)
            }
            
            //MARK: Score label
            Text(snake.getScoreLabel())
                .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
            
            //MARK: Pink background
            ZStack {
                Color.pink.opacity(0.3)
                ZStack {
                    //MARK: This section put our Snake on the map.
                    ForEach (0..<snake.posArray.count, id: \.self) { index in
                        Rectangle()
                            .frame(width: snake.snakeSize, height: snake.snakeSize)
                            .position(snake.posArray[index])
                    }
                    //MARK: This part put the food on a random place on the frame
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: snake.snakeSize, height: snake.snakeSize)
                        .position(thisGame.foodPos)
                }
                
                if snake.gameOver {
                    VStack {
                        Text("Game Over")
                        Button(action: {
                            /// Clean up this section and apply Dependecy injection. Reset should be in one place.
                            
                            snake.reset()
                            thisGame.reset(snakeSize: snake.snakeSize)
                            
                        }, label: {
                            Text("Restart")
                        })
                    }
                    
                }
            }
            .onChange(of: showingMenu, perform: { showingMenu in
                if showingMenu == false {
                    timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
                }
            })
            .onAppear() {
                // Start the game with a random food place
                thisGame.foodPos = thisGame.changeRectPos(snakeSize: snake.snakeSize)
                // Start the game with random Snake place.
                snake.posArray[0] = thisGame.changeRectPos(snakeSize: snake.snakeSize)
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        /// Recognizing the swipe
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
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SnakeGameView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
        }
        
    }
}
