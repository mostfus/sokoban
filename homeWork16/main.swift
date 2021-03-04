//
//  main.swift
//  homeWork16
//
//  Created by Александр Соколов on 27.02.2021.
//

import Foundation

// Dictionary which contain all object in map
var map = [[Int : Int] : String]()
var wall = "⬛️"
var avatar = "👻"
var playingField = "🟩"
var objectMove = "📦"
var target = "⭕️"

class Room {
    var height: Int
    var width: Int
    
    static let minSizeMap = 12
    static let maxSizeMap = 12
    
    init(height: Int, width: Int) {
        if height < Room.minSizeMap {
            self.height = Room.minSizeMap
        } else if height > Room.maxSizeMap {
            self.height = Room.maxSizeMap
        } else {
            self.height = height
        }
        
        if width < Room.minSizeMap {
            self.width = Room.minSizeMap
        } else if width > Room.maxSizeMap {
            self.width = Room.maxSizeMap
        } else {
            self.width = width
        }
    }
}

enum Direction {
    case Up
    case Down
    case Left
    case Right
    
    var value: Int {
        switch self {
        case .Up:
            return -1
        case .Down:
            return 1
        case .Left:
            return -1
        case .Right:
            return 1
        }
    }
}

struct Person {
    var x, y: Int
    
    mutating func move(_ direction: Direction) {

        // Save oldValue coordinate Person
        let oldX = self.x
        let oldY = self.y
        
        // Get new coordinate Person
        switch direction {
        case .Up,.Down:
            self.x += direction.value
        case .Left,.Right:
            self.y += direction.value
        }
        
        // Update coordinates in map
        if checkBorderMove(x: x, y: y) && map[[x : y]] != objectMove && map[[x : y]] != target {
            // value in map with coordinates to move
            let temp = map[[self.x : self.y]]
            map[[self.x : self.y]] = avatar
            map[[oldX : oldY]] = temp
        } else if map[[x : y]] == objectMove {
            if box.move(x: x, y: y, direction: direction)  {
                map[[self.x : self.y]] = avatar
                map[[oldX : oldY]] = playingField
            } else {
                self.x = oldX
                self.y = oldY
            }
        } else {
            self.x = oldX
            self.y = oldY
            print("\n⛔️WRONG WAY⛔️")
        }
    }

}

struct Box {
    var x, y: Int
    
    mutating func move(x: Int, y: Int, direction: Direction) -> Bool {
        
        // Save oldValue coordinate Box
        let oldX = self.x
        let oldY = self.y
        
        // Get new coordinate Box
        switch direction {
        case .Up,.Down:
            self.x += direction.value
        case .Left,.Right:
            self.y += direction.value
        }
        
        if checkBorderMove(x: self.x, y: self.y) {
            map[[self.x : self.y]] = objectMove
            return true
        } else {
            self.x = oldX
            self.y = oldY
            print("\n⛔️WRONG WAY⛔️")
            return false
        }
        
    }
}

struct Target {
    var x, y: Int
}

// Check next coordinate

func checkBorderMove(x: Int, y: Int) -> Bool {
    if x > 1 && x < level.height && y > 1 && y < level.width && map[[x : y]] != wall {
        return true
    } else {
        return false
    }
    
}

// Add object to Dictionary map[:]
func addItemToMap(height: Int, width: Int, person: Person) {
    for h in 1...height {
        for w in 1...width {
            switch (h, w) {
            case (1, _):
                map[[h : w]] = wall
            case (let h, _) where h == height:
                map[[h : w]] = wall
            case (let h, 2...4) where h == height - 3:
                map[[h : w]] = wall
            case (2...3, let w) where w == width - 2:
                map[[h : w]] = wall
            case let(h, w) where h > 1 && h < height && w == 1 || w == width:
                map[[h : w]] = wall
            default:
                map[[h : w]] = playingField
            }
        }
    }
    
    map[[person.x : person.y]] = avatar
    
    // Add random wall
    let nums1 = randomInt(height, width, person)
    let nums2 = randomInt(height, width, person)
    map[[nums1.h : nums1.w]] = wall
    map[[nums2.h : nums2.w]] = wall
    
}


// Get random Numbers for object
func randomInt(_ height: Int,_ width: Int, _ person: Person) -> (h: Int, w: Int) {
    let h = Int.random(in: 2..<height)
    let w = Int.random(in: 2..<width)
    
    if h != person.x && w != person.y && map[[h : w]] != wall && map[[h : w]] != objectMove  {
        return (h: h, w: w)
    }
    return randomInt(height, width, person)
}

// Print all map in the game
func printMap(height: Int, width: Int, person: Person) {
    print("LEVEL \(countLevel)\n")
    for h in 1...height {
        for w in 1...width {
            if let value = map[[h : w]] {
                print(value, terminator: " ")
            }
        }
        print("")
    }
}

// Console part

//print("\u{001B}[2J")

func clearTerminal() {
    let cls = Process()
    let out = Pipe()
    cls.launchPath = "/usr/bin/clear"
    cls.standardOutput = out
    cls.launch()
    cls.waitUntilExit()
    print (String(data: out.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8) ?? "")
    
}

clearTerminal()
print("""


@@@This is Sokoban@@@

🎯your goal:
Your task is to move the box to the place marked with a cross.

@comands:
Start - enter to start the game
w - move up 🔼
s - move down 🔽
d - move right ▶️
a - move left ◀️



Exit - end game

Good luck!

@enter comand:
""")

var level = Room(height: 100, width: 100)
var user = Person(x: Int(level.height / 2), y: Int(level.width / 2))
var box = Box(x: 0, y: 0)
var targetBox = Target(x: 0, y: 0)
var countLevel = 1
var arrayBoxes = [Box]()


func checkPointBox(_ point: (x:Int, y:Int)) -> Bool {
    if map[[point.x : point.y]] == avatar || map[[point.x + 1 : point.y]] == wall || map[[point.x - 1 : point.y]] == wall || map[[point.x : point.y + 1]] == wall || map[[point.x : point.y - 1]] == wall || map[[point.x : point.y]] == objectMove {
        return true
    } else {
        return false
    }
}

func checkPointTarget(_ point: (x:Int, y:Int)) -> Bool {
    if map[[point.x : point.y]] == objectMove || map[[point.x : point.y]] == avatar || map[[point.x + 1 : point.y]] == wall || map[[point.x - 1 : point.y]] == wall || map[[point.x : point.y + 1]] == wall || map[[point.x : point.y - 1]] == wall {
        return true
    } else {
        return false
    }
}

func addBoxToMap() {
    var boxPoint: (Int, Int)
    repeat {
        boxPoint = randomInt(level.height, level.width, user)
    } while checkPointBox(boxPoint)
    box.x = boxPoint.0
    box.y = boxPoint.1
    map[[boxPoint.0 : boxPoint.1]] = objectMove

}

func addTargetToMap() {
    var targetPoint: (Int, Int)
    
    repeat {
        targetPoint = randomInt(level.height, level.width, user)
    } while checkPointTarget(targetPoint)
    targetBox.x = targetPoint.0
    targetBox.y = targetPoint.1
    map[[targetPoint.0 : targetPoint.1]] = target
}

func startGame() {
    addItemToMap(height: level.height, width: level.width, person: user)
    addBoxToMap()
    addTargetToMap()
    printMap(height: level.height, width: level.width, person: user)
}

func move(_ direction: Direction) {
    user.move(direction)
    printMap(height: level.height, width: level.width, person: user)
}

var comand = ""
var win = ("""

🎊🎊🎊 Congratulations, you won! 🎊🎊🎊

       Do you want to play again?

                 Y/N
""")
    
game: repeat {
    if let text = readLine() {
        comand = text.lowercased()
    
        switch comand {
        case "start":
            clearTerminal()
            startGame()
        case "w":
            clearTerminal()
            move(.Up)
        case "s":
            clearTerminal()
            move(.Down)
        case "a":
            clearTerminal()
            move(.Left)
        case "d":
            clearTerminal()
            move(.Right)
        case "y":
            map = [:]
            startGame()
        case "n":
            break game
        default:
            break
        }
        print("""
                 🔼
              ◀️     ▶️
                 🔽

""")
        print("@enter comand:")
    }
    
        if box.x == targetBox.x && box.y == targetBox.y {
            print(win)
            countLevel += 1
    }

} while comand != "Exit"
    


print("\nGood bye!\n")


