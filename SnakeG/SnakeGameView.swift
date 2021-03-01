//
//  ContentView.swift
//  SnakeG
//
//  Created by Noujan Fakhri on 2/24/21.
//

import SwiftUI

struct SnakeGameView: View {
    
    enum direction {
        case up, down, left, right
    }

    @State var startPos : CGPoint = .zero // the start poisition of our swipe
    @State var isStarted = true // did the user started the swipe?
    @State var gameOver = false // for ending the game when the snake hits the screen borders
    @State var dir = direction.down // the direction the snake is going to take
    @State var posArray = [CGPoint(x: 20, y: 100)] // array of the snake's body positions
    @State var foodPos = CGPoint(x: 0, y: 0) // the position of the food
    @State var snakeSize : CGFloat = 10 // width and height of the snake
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // to updates the snake position every 0.1 second

    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
//    let minX = UIScreen.main.bounds.minX
    let minX = CGFloat(20)
    let maxX = UIScreen.main.bounds.maxX - 60
//    let minY = UIScreen.main.bounds.minY
    let minY = CGFloat(20)
    let maxY = UIScreen.main.bounds.maxY - 220

    func changeRectPos() -> CGPoint {
        let rows = Int(maxX/snakeSize)
        let cols = Int(maxY/snakeSize)
        
        let randomX = Int.random(in: 1..<rows) * Int(snakeSize)
        let randomY = Int.random(in: 1..<cols) * Int(snakeSize)
        
        return CGPoint(x: randomX, y: randomY)
    }

    func changeDirection () {

        let posX = posArray[0].x
        let posY = posArray[0].y
        if posX < minX - snakeSize {
            posArray[0] = CGPoint(x: maxX + 2*snakeSize, y: posY)
        } else if posX > maxX + snakeSize {
            posArray[0] = CGPoint(x: minX - 2*snakeSize, y: posY)
        } else if posY < minY - snakeSize {
            posArray[0] = CGPoint(x: posX, y: maxY + 2*snakeSize)
        } else if posY > maxY + snakeSize {
            posArray[0] = CGPoint(x: posX, y: minY - 2*snakeSize)
        }

        var prev = posArray[0]
        if dir == .down {
            self.posArray[0].y += snakeSize
        } else if dir == .up {
            self.posArray[0].y -= snakeSize
        } else if dir == .left {
            self.posArray[0].x += snakeSize
        } else {
            self.posArray[0].x -= snakeSize
        }
        
        for index in 1..<posArray.count {
            let current = posArray[index]
            posArray[index] = prev
            prev = current
        }
    }

    
    var body: some View {
        
        ZStack {
            Color.pink.opacity(0.3)
            ZStack {
                ForEach (0..<posArray.count, id: \.self) { index in
                    Rectangle()
                        .frame(width: self.snakeSize, height: self.snakeSize)
                        .position(self.posArray[index])
                }
                Rectangle()
                    .fill(Color.red)
                    .frame(width: snakeSize, height: snakeSize)
                    .position(foodPos)
            }
            
            if self.gameOver {
                VStack{
                    Text("Game Over")
                    Button(action: {
                        posArray = [CGPoint(x: 20, y: 100)]
                        self.gameOver = false
                        startPos = .zero
                        snakeSize = 10
                        isStarted = true
                        dir = direction.down
                        foodPos = CGPoint(x: 0, y: 0)
                        self.foodPos = self.changeRectPos()
                        
                    }, label: {
                        Text("Restart")
                    })
                }
                
            }
        }
        .onAppear() {
            self.foodPos = self.changeRectPos()
            self.posArray[0] = self.changeRectPos()
        }
        .gesture(DragGesture()
                    .onChanged { gesture in
                        if self.isStarted {
                            self.startPos = gesture.location
                            self.isStarted.toggle()
                        }
                    }
                    .onEnded {  gesture in
                        let xDist =  abs(gesture.location.x - self.startPos.x)
                        let yDist =  abs(gesture.location.y - self.startPos.y)
                        if self.startPos.y <  gesture.location.y && yDist > xDist {
                            self.dir = direction.down
                        }
                        else if self.startPos.y >  gesture.location.y && yDist > xDist {
                            self.dir = direction.up
                        }
                        else if self.startPos.x > gesture.location.x && yDist < xDist {
                            self.dir = direction.right
                        }
                        else if self.startPos.x < gesture.location.x && yDist < xDist {
                            self.dir = direction.left
                        }
                        self.isStarted.toggle()
                    }
        )
        .onReceive(timer) { (_) in
            if !self.gameOver {
                self.changeDirection()
                if self.posArray[0] == self.foodPos {
                    self.posArray.append(self.posArray[0])
                    self.foodPos = self.changeRectPos()
                } else {
                    let tempArr = posArray.dropFirst()
                    print("temp--> \(tempArr)")
                    print("pos--> \(posArray)")
                    if tempArr.contains(posArray[0]) {
                        print("No no - You are done! game over!")
                        gameOver.toggle()
                    }
                }
                
            }
        }
        .padding(EdgeInsets(top: 100, leading: 20, bottom: 20, trailing: 20))
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SnakeGameView()
        }
    }
}
