//
//  SnakeGameView.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 2/24/21.
//

import SwiftUI
import Foundation

struct SnakeGameView: View {
    //TODO: Move the timer to GameView
    @State var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // to updates the snake position every 0.1 second
    // Spawns a bonus treat roughly every 10 seconds.
    @State private var bonusTimer = Timer.publish(every: GeneralInfo.bonusSpawnInterval, on: .main, in: .common).autoconnect()
    @State private var showingMenu = false
    @StateObject var snake = Snake()
    @StateObject var thisGame = GeneralInfo()
    @EnvironmentObject var viewModel: AuthViewModel
    
    fileprivate func Pause() {
        // Pauses the game by cancelling the timer, then shows the pause menu.
        timer.upstream.connect().cancel()
        showingMenu = true
    }

    fileprivate func restartTimer() {
        timer.upstream.connect().cancel()
        timer = Timer.publish(every: thisGame.tickInterval, on: .main, in: .common).autoconnect()
    }

    fileprivate func restartBonusTimer() {
        // Rebase the bonus publisher so a new run always waits a full interval
        // before its first bonus, instead of inheriting the old timer's phase.
        bonusTimer.upstream.connect().cancel()
        bonusTimer = Timer.publish(every: GeneralInfo.bonusSpawnInterval, on: .main, in: .common).autoconnect()
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

                    //MARK: Bonus treat — a bigger emoji worth extra points
                    if let bonusPos = thisGame.bonusPos {
                        let bonusSize = thisGame.bonusSize(snakeSize: snake.snakeSize)
                        Text(thisGame.bonusEmoji)
                            .font(.system(size: bonusSize))
                            // Emoji glyphs render larger than their point size, so
                            // shrink to fit and cap the height so the box isn't clipped.
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                            .frame(width: bonusSize, height: bonusSize)
                            .position(bonusPos)
                    }
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
                            // TODO: Apply dependency injection so reset lives in one place.
                            snake.reset()
                            thisGame.reset(snakeSize: snake.snakeSize)
                            // Re-spawn the snake away from the walls, matching onAppear.
                            snake.posArray[0] = thisGame.randomStartPosition(snakeSize: snake.snakeSize)
                            restartTimer()
                            restartBonusTimer()

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
                // Spawn the snake away from the walls so the first move is safe.
                snake.posArray[0] = thisGame.randomStartPosition(snakeSize: snake.snakeSize)
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
            .onReceive(bonusTimer) { (_) in
                // Drop a bonus treat on the board while the game is actively running,
                // keeping clear of the snake's body and the normal food.
                if !snake.gameOver && !showingMenu {
                    thisGame.spawnBonus(snakeSize: snake.snakeSize,
                                        avoiding: snake.posArray + [thisGame.foodPos])
                }
            }
            .onReceive(timer) { (_) in
                if !snake.gameOver {
                    snake.changeDirection()
                    // Age out the bonus if it has been sitting around too long.
                    thisGame.ageBonus(by: thisGame.tickInterval)
                    // Eating the bonus grows the snake and awards extra points. We
                    // note it so the self-collision check below skips the freshly
                    // appended segment (which shares the head's position).
                    let ateBonus = thisGame.hitsBonus(head: snake.posArray[0], snakeSize: snake.snakeSize)
                    if ateBonus {
                        snake.posArray.append(snake.posArray[0])
                        snake.award(points: thisGame.bonusPointsValue())
                        thisGame.collectBonus()
                    }
                    if snake.posArray[0] == thisGame.foodPos {
                        snake.posArray.append(snake.posArray[0])
                        snake.award(points: thisGame.pointsForFood())
                        thisGame.foodPos = thisGame.changeRectPos(snakeSize: snake.snakeSize)
                        // Eating normal food earns the right to one bonus.
                        thisGame.armBonus()
                        thisGame.speedUp()
                        restartTimer()
                    } else if !ateBonus {
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
