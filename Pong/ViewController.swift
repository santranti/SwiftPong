import Cocoa
import SpriteKit

class ViewController: NSViewController {
    
    weak var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.window?.acceptsMouseMovedEvents = true
        
        // Ensure the view is of type SKView.
        guard let skView = self.view as? SKView else {
            return
        }

        self.skView = skView // Store a weak reference to the skView

        // Configure the view.
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        // Create and configure the scene.
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        
        // Present the scene.
        skView.presentScene(scene)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    // Allow the window to become a first responder to capture key events.
    override var acceptsFirstResponder: Bool {
        return true
    }

    override func mouseMoved(with event: NSEvent) {
        print("Mouse moved in ViewController!")
        // Delegate mouse movement to the scene.
        (skView.scene as? GameScene)?.mouseMoved(with: event)
    }
    
    override func keyDown(with event: NSEvent) {
        // Delegate key presses to the scene.
        (skView.scene as? GameScene)?.keyDown(with: event)
    }

    override func keyUp(with event: NSEvent) {
        // Delegate key releases to the scene.
        (skView.scene as? GameScene)?.keyUp(with: event)
    }
    
    
}

