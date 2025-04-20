import Cocoa
import Foundation

class CircleWindow: NSWindow {
    init(diameter: CGFloat) {
        let rect = NSRect(x: 0, y: 0, width: diameter, height: diameter)
        super.init(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: false)
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .screenSaver
        self.ignoresMouseEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        self.contentView = CircleView(frame: rect)
        self.makeKeyAndOrderFront(nil)
    }

    func moveToCursor() {
        let mouseLoc = NSEvent.mouseLocation
        let frame = NSRect(
            x: mouseLoc.x - self.frame.width / 2,
            y: mouseLoc.y - self.frame.height / 2,
            width: self.frame.width,
            height: self.frame.height
        )
        self.setFrame(frame, display: true)
    }
}

class CircleView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let circleRect = dirtyRect.insetBy(dx: 3, dy: 3)
        let path = NSBezierPath(ovalIn: circleRect)
        NSColor.red.setStroke()
        path.lineWidth = 6
        path.stroke()
    }

    override var isFlipped: Bool {
        true
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var timer: DispatchSourceTimer?
    var circleWindow: CircleWindow?
    var diameter: CGFloat

    init(diameter: CGFloat) {
        self.diameter = diameter
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        circleWindow = CircleWindow(diameter: diameter)
        circleWindow?.moveToCursor()

        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: .now(), repeating: .milliseconds(10))
        timer?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.circleWindow?.moveToCursor()
            }
        }
        timer?.resume()
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.cancel()
    }
}

let defaultDiameter: CGFloat = 70
let diameter: CGFloat = {
    if CommandLine.arguments.count > 1, let d = Double(CommandLine.arguments[1]), d > 10 {
        return CGFloat(d)
    }
    return defaultDiameter
}()

let app = NSApplication.shared
let delegate = AppDelegate(diameter: diameter)
app.delegate = delegate
app.run()
