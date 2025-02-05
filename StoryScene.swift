//
//  File.swift
//  AntiSmokingWWDC
//
//  Created by Batch - 1 on 05/02/25.
//

import SwiftUI
import SpriteKit
class StoryScene: SKScene {
    let boy = SKSpriteNode(imageNamed: "boy_character")
    let group = SKSpriteNode(imageNamed: "group_characters")
    let speechBubble = SKLabelNode(text: "Hey, wanna try?")
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        boy.position = CGPoint(x: size.width * 0.3, y: size.height * 0.5)
        boy.setScale(0.5)
        addChild(boy)
        
        group.position = CGPoint(x: size.width * 0.7, y: size.height * 0.5)
        group.setScale(0.6)
        addChild(group)
        
        speechBubble.fontSize = 24
        speechBubble.fontColor = .black
        speechBubble.position = CGPoint(x: size.width * 0.7, y: size.height * 0.7)
        addChild(speechBubble)
        
        runStoryAnimation()
    }
    
    func runStoryAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.speechBubble.text = "Haha! You're such a baby!"
            self.shake(node: self.boy)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.speechBubble.text = "Fine! I'll try..."
            self.boy.run(SKAction.moveBy(x: 30, y: 0, duration: 0.5))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.speechBubble.text = "*Cough Cough*"
            self.shake(node: self.boy)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            self.speechBubble.text = "Hahaha! Look at him choke!"
            self.shake(node: self.group)
        }
    }
    
    func shake(node: SKNode) {
        let moveLeft = SKAction.moveBy(x: -5, y: 0, duration: 0.1)
        let moveRight = SKAction.moveBy(x: 5, y: 0, duration: 0.1)
        let sequence = SKAction.sequence([moveLeft, moveRight, moveLeft, moveRight])
        node.run(SKAction.repeat(sequence, count: 3))
    }
}
