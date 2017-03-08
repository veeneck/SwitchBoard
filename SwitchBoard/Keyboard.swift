//
//  Keyboard.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 3/8/17.
//  Copyright © 2017 Phalanx Studios. All rights reserved.
//

//
//  Keyboard.swift
//
//  Created by Bojan Percevic on 5/21/15.
//  Copyright (c) 2015 Bojan Percevic. All rights reserved.
//

import AppKit

enum Key: CUnsignedShort {
    case A = 0x00 // = 0
    case S = 0x01
    case D = 0x02
    case F = 0x03
    case H = 0x04
    case G = 0x05
    case Z = 0x06
    case X = 0x07
    case C = 0x08
    case V = 0x09
    case B = 0x0B
    case Q = 0x0C
    case W = 0x0D
    case E = 0x0E
    case R = 0x0F
    case Y = 0x10
    case T = 0x11
    case One = 0x12
    case Two = 0x13
    case Three = 0x14
    case Four = 0x15
    case Six = 0x16
    case Five = 0x17
    case Equals = 0x18
    case Nine = 0x19
    case Seven = 0x1A
    case Minus = 0x1B
    case Eight = 0x1C
    case Zero = 0x1D
    case RightBracket = 0x1E
    case O = 0x1F
    case U = 0x20
    case LeftBracket = 0x21
    case I = 0x22
    case P = 0x23
    case Return = 0x24
    case L = 0x25
    case J = 0x26
    case Quote = 0x27
    case K = 0x28
    case Semicolon = 0x29
    case Backslash = 0x2A
    case Comma = 0x2B
    case Slash = 0x2C
    case N = 0x2D
    case M = 0x2E
    case Period = 0x2F
    case Tab = 0x30
    case Space = 0x31
    case Grave = 0x32
    case Delete = 0x33
    
    case Escape = 0x35
    
    case Command = 0x37
    case LeftShift = 0x38
    case CapsLock = 0x39
    case LeftOption = 0x3A
    case LeftControl = 0x3B
    case RightShift = 0x3C
    case RightOption = 0x3D
    case RightControl = 0x3E
    case Function = 0x3F
    case F17 = 0x40
    case KeypadDecimal = 0x41
    
    case KeypadMultiply = 0x43
    
    case KeypadPlus = 0x45
    
    case KeypadClear = 0x47
    case VolumeUp = 0x48
    case VolumeDown = 0x49
    case Mute = 0x4A
    case KeypadDivide = 0x4B
    case KeypadEnter = 0x4C
    
    case KeypadMinus = 0x4E
    case F18 = 0x4F
    case F19 = 0x50
    case KeypadEquals = 0x51
    case KeypadZero = 0x52
    case KeypadOne = 0x53
    case KeypadTwo = 0x54
    case KeypadThree = 0x55
    case KeypadFour = 0x56
    case KeypadFive = 0x57
    case KeypadSix = 0x58
    case KeypadSeven = 0x59
    case F20 = 0x5A
    case KeypadEight = 0x5B
    case KeypadNine = 0x5C
    
    case F5 = 0x60
    case F6 = 0x61
    case F7 = 0x62
    case F3 = 0x63
    case F8 = 0x64
    case F9 = 0x65
    case F11 = 0x67
    case F13 = 0x69
    case F16 = 0x6A
    case F14 = 0x6B
    case F10 = 0x6D
    case F12 = 0x6F
    case F15 = 0x71
    case Help = 0x72
    case Home = 0x73
    case PageUp = 0x74
    case ForwardDelete = 0x75
    case F4 = 0x76
    case End = 0x77
    case F2 = 0x78
    case PageDown = 0x79
    case F1 = 0x7A
    case Left = 0x7B
    case Right = 0x7C
    case Down = 0x7D
    case Up = 0x7E // = 126
    
    case Count = 0x7F
}

struct KeyState {
    var keys = [Bool](repeating: false, count: Int(Key.Count.rawValue))
}

class Keyboard {
    
    static let sharedKeyboard = Keyboard()
    
    var prev: KeyState
    var curr: KeyState
    
    init() {
        prev = KeyState()
        curr = KeyState()
    }
    
    func handleKey(event: NSEvent, isDown: Bool) {
        if (isDown) {
            curr.keys[Int(event.keyCode)] = true
        } else {
            curr.keys[Int(event.keyCode)] = false
        }
    }
    
    func justPressed(keys: Key...) -> Bool {
        for key in keys {
            if (curr.keys[Int(key.rawValue)] == true && prev.keys[Int(key.rawValue)] == false) {
                return true
            }
        }
        return false
    }
    
    func justReleased(keys: Key...) -> Bool {
        for key in keys {
            if (prev.keys[Int(key.rawValue)] == true && curr.keys[Int(key.rawValue)] == false) {
                return true
            }
        }
        return false
    }
    
    func pressed(keys: Key...) -> Bool {
        for key in keys {
            if (prev.keys[Int(key.rawValue)] == true && curr.keys[Int(key.rawValue)] == true) {
                return true
            }
        }
        return false
    }
    
    func update() {
        prev = curr
    }
    
}
