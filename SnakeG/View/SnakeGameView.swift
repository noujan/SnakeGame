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

    fileprivate func restartTimer() {
        timer.upstream.connect().cancel()
        timer = Timer.publish(every: thisGame.tickInterval, on: .main, in: .common).autoconnect()
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
            HStack {
                Text(snake.getScoreLabel())
                Spacer()
                Text("High: \(snake.highScore)")
                    .foregroundColor(.secondary)
            }
            .font(.system(size: 16, weight: .semibold, design: .monospaced))
            .padding(EdgeInsets(top: 30, leading: 20, bottom: 0, trailing: 20))
            
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
                    VStack(spacing: 16) {
                        Text("Game Over")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        VStack(spacing: 4) {
                            Text("Score: \(snake.score)")
                                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                            Text("Best: \(snake.highScore)")
                                .font(.system(size: 15, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        Button(action: {
                            /// Clean up this section and apply Dependecy injection. Reset should be in one place.

                            snake.reset()
                            thisGame.reset(snakeSize: snake.snakeSize)
                            restartTimer()

                        }, label: {
                            Text("Restart")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.horizontal, 28)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.pink))
                                .foregroundColor(.white)
                        })
                    }
                    .padding(28)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground).opacity(0.95)))
                    .shadow(radius: 10)
                }
            }
            .frame(width: boardWidth, height: boardHeight)
            .contentShape(Rectangle())
            .border(Color.pink, width: 2)
            .onChange(of: snake.gameOver) { isOver in
                // Save the player's result to Game Center when a run ends.
                if isOver {
                    GameCenterManager.shared.submit(score: snake.score)
                }
            }
            .onChange(of: showingMenu, perform: { showingMenu in
                if showingMenu == false {
                    timer = Timer.publish(every: thisGame.tickInterval, on: .main, in: .common).autoconnect()
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
                            snake.dir = direction.left
                        }
                        else if snake.startPos.x < gesture.location.x && yDist < xDist {
                            snake.dir = direction.right
                        }
                        snake.isStarted.toggle()
                    }
                
            )
            .onReceive(timer) { (_) in
                if !snake.gameOver {
                    snake.changeDirection()
                    if snake.posArray[0] == thisGame.foodPos {
                        snake.posArray.append(snake.posArray[0])
                        snake.award(points: thisGame.pointsForFood())
                        thisGame.foodPos = thisGame.changeRectPos(snakeSize: snake.snakeSize)
                        thisGame.speedUp()
                        restartTimer()
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

            Spacer(minLength: 0)
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
