import SpriteKit

class GameScene: SKScene {
    
    var ball: SKShapeNode!
    var leftPaddle: SKShapeNode!
    var rightPaddle: SKShapeNode!
    var leftScoreLabel: SKLabelNode!
    var rightScoreLabel: SKLabelNode!
    
    var leftScore: Int = 0 {
        didSet {
            leftScoreLabel.text = "\(leftScore)"
        }
    }
    
    var rightScore: Int = 0 {
        didSet {
            rightScoreLabel.text = "\(rightScore)"
        }
    }
    
    var ballSpeed: CGFloat = 100.0
    var paddleSpeed: CGFloat = 100.0
    var ballSpeedMultiplier: CGFloat = 1.1
    
    var keysPressed: Set<UInt16> = []
    
    var lastUpdateTime: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.gray
        setupGameElements()
    }
    
    func setupGameElements() {
        // Ball setup
        let ballDiameter = CGFloat(15)
        ball = SKShapeNode(circleOfRadius: ballDiameter / 2)
        ball.fillColor = .black
        ball.position = CGPoint(x: size.width/2, y: size.height/2)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballDiameter / 2)
        configurePhysicsBody(ball.physicsBody)
        ball.physicsBody?.isDynamic = true  // Ensure the ball is dynamic
        addChild(ball)
        ball.physicsBody?.applyImpulse(CGVector(dx: ballSpeed, dy: ballSpeed))  // Apply initial impulse

        // Paddles setup
        let paddleSize = CGSize(width: 15, height: 80)
        leftPaddle = createPaddle(size: paddleSize, position: CGPoint(x: 30, y: size.height/2))
        rightPaddle = createPaddle(size: paddleSize, position: CGPoint(x: size.width - 30, y: size.height/2))
        
        // Score labels setup
        leftScoreLabel = SKLabelNode(fontNamed: "Helvetica")
        leftScoreLabel.fontSize = 20
        leftScoreLabel.position = CGPoint(x: size.width * 0.25, y: size.height - 40)
        leftScoreLabel.text = "\(leftScore)"
        addChild(leftScoreLabel)
        
        rightScoreLabel = SKLabelNode(fontNamed: "Helvetica")
        rightScoreLabel.fontSize = 20
        rightScoreLabel.position = CGPoint(x: size.width * 0.75, y: size.height - 40)
        rightScoreLabel.text = "\(rightScore)"
        addChild(rightScoreLabel)
    }

    func createPaddle(size: CGSize, position: CGPoint) -> SKShapeNode {
        let paddle = SKShapeNode(rectOf: size, cornerRadius: 10)
        paddle.fillColor = .black
        paddle.position = position
        paddle.physicsBody = SKPhysicsBody(rectangleOf: size)
        configurePhysicsBody(paddle.physicsBody)
        addChild(paddle)
        return paddle
    }

    func configurePhysicsBody(_ physicsBody: SKPhysicsBody?) {
        physicsBody?.affectedByGravity = false
        physicsBody?.restitution = 1
        physicsBody?.friction = 0
        physicsBody?.linearDamping = 0
        physicsBody?.allowsRotation = false    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Ball collision with top and bottom
        if ball.position.y - ball.frame.size.height/2 <= 0 || ball.position.y + ball.frame.size.height/2 >= size.height {
            let dy = -ball.physicsBody!.velocity.dy
            ball.physicsBody?.velocity = CGVector(dx: ball.physicsBody!.velocity.dx, dy: dy)
        }
        
        // Ball out of bounds handling
        handleBallOutOfBounds()

        // AI for right paddle
        updateRightPaddle(deltaTime: deltaTime)

        // Ball collision with paddles
        handleBallPaddleCollision()

        // Update left paddle position
        updateLeftPaddlePosition(deltaTime: deltaTime)
    }

    func handleBallOutOfBounds() {
        if ball.position.x - ball.frame.size.width/2 <= 0 {
            rightScore += 1
            resetBallPosition()
        } else if ball.position.x + ball.frame.size.width/2 >= size.width {
            leftScore += 1
            resetBallPosition()
        }
    }

    func resetBallPosition() {
        ball.position = CGPoint(x: size.width/2, y: size.height/2)
        ball.physicsBody?.velocity = CGVector(dx: ballSpeed, dy: ballSpeed)
    }

    func updateRightPaddle(deltaTime: TimeInterval) {
        guard let ball = ball, let rightPaddle = rightPaddle else {
            print("Ball or right paddle is not initialized")
            return
        }

        let distanceToBall = ball.position.y - rightPaddle.position.y
        if abs(distanceToBall) > 10 {
            if ball.position.y > rightPaddle.position.y {
                rightPaddle.position.y += min(paddleSpeed * CGFloat(deltaTime), abs(distanceToBall))
            } else {
                rightPaddle.position.y -= min(paddleSpeed * CGFloat(deltaTime), abs(distanceToBall))
            }
        }
    }

    func handleBallPaddleCollision() {
        if ball.frame.intersects(leftPaddle.frame) || ball.frame.intersects(rightPaddle.frame) {
            let dx = ball.physicsBody!.velocity.dx * ballSpeedMultiplier
            let dy = ball.physicsBody!.velocity.dy * ballSpeedMultiplier
            ball.physicsBody?.velocity = CGVector(dx: -dx, dy: dy)

            // Cool animations and spark effect
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            ball.run(SKAction.sequence([scaleUp, scaleDown]))
            createSpark(at: ball.position)
        }
    }

    func createSpark(at position: CGPoint) {
        if let spark = SKEmitterNode(fileNamed: "Spark.sks") {
            spark.position = position
            addChild(spark)
            let removeAction = SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.removeFromParent()])
            spark.run(removeAction)
        }
    }

    func updateLeftPaddlePosition(deltaTime: TimeInterval) {
        if keysPressed.contains(13) { // 'W' key
            leftPaddle.position.y += paddleSpeed * CGFloat(deltaTime)
        } else if keysPressed.contains(1) { // 'S' key
            leftPaddle.position.y -= paddleSpeed * CGFloat(deltaTime)
        }

        // Ensure paddle stays within the screen bounds
        leftPaddle.position.y = max(leftPaddle.frame.size.height/2, min(size.height - leftPaddle.frame.size.height/2, leftPaddle.position.y))
    }

    override func keyDown(with event: NSEvent) {
        keysPressed.insert(event.keyCode)
    }
        
    override func keyUp(with event: NSEvent) {
        keysPressed.remove(event.keyCode)
    }
}
