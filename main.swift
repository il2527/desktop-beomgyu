import AppKit
import UniformTypeIdentifiers

final class CompanionView: NSView {
    weak var owner: Companion?
    var dragStart: NSPoint?
    override init(frame: NSRect) {
        super.init(frame: frame)
        registerForDraggedTypes([.fileURL])
    }
    required init?(coder: NSCoder) { fatalError() }
    override func draw(_ dirtyRect: NSRect) {
        guard let owner else { return }
        let picture = owner.images[owner.celebrating ? "celebrate" : "standing"]!
        let h = bounds.height - 64
        let w = h * picture.size.width / picture.size.height
        let bounce = owner.celebrating ? abs(sin(owner.phase * 1.5)) * 15 : (owner.isWalking ? abs(sin(owner.phase * 2)) * 2 : 0)
        let rect = NSRect(x: (bounds.width-w)/2, y: 12+bounce, width: w, height: h)
        if owner.isHugging, !owner.hugFrames.isEmpty {
            let hug = owner.hugFrames[owner.hugFrame]
            let area = NSRect(x: 12, y: 8, width: bounds.width-24, height: bounds.height-118)
            let scale = min(area.width/hug.size.width, area.height/hug.size.height)
            let size = NSSize(width: hug.size.width*scale, height: hug.size.height*scale)
            hug.draw(in: NSRect(x: area.midX-size.width/2, y: area.minY, width: size.width, height: size.height))
        } else if owner.isWalking && owner.shouldRun, let run = owner.images["run-\(Int(owner.walkDistance/13)%2)"] {
            let width = min(bounds.width-12, h*run.size.width/run.size.height)
            let height = width*run.size.height/run.size.width
            let bob = sin(owner.walkDistance*0.19)*2
            NSGraphicsContext.saveGraphicsState()
            let mirror = NSAffineTransform()
            mirror.translateX(by: bounds.midX, yBy: 0)
            // Both running cutouts face left; flip them for rightward travel.
            mirror.scaleX(by: -owner.facing, yBy: 1)
            mirror.translateX(by: -bounds.midX, yBy: 0)
            mirror.concat()
            run.draw(in: NSRect(x: bounds.midX-width/2, y: 12+bob, width: width, height: height))
            NSGraphicsContext.restoreGraphicsState()
        } else if owner.isWalking, let sheet = owner.images["walk-right"] {
            // The atlas has six side-facing poses in row-major order.
            // Crop inside each cell to exclude atlas dividers.
            let position = owner.walkDistance / (owner.shouldRun ? 13 : 11)
            let frame = Int(position) % 6
            let cellW = sheet.size.width / 3
            let cellH = sheet.size.height / 2
            let source = NSRect(x: CGFloat(frame % 3)*cellW+cellW*0.025,
                                y: CGFloat(1-frame / 3)*cellH+cellH*0.025,
                                width: cellW*0.95, height: cellH*0.95)
            let width = h * source.width / source.height
            let target = NSRect(x: (bounds.width-width)/2, y: 12 + (owner.shouldRun ? abs(sin(owner.walkDistance/13 * .pi/3))*7 : 0), width: width, height: h)
            NSGraphicsContext.saveGraphicsState()
            do {
                let mirror = NSAffineTransform()
                mirror.translateX(by: bounds.midX, yBy: 0)
                mirror.scaleX(by: owner.facing, yBy: 1)
                mirror.translateX(by: -bounds.midX, yBy: 0)
                mirror.concat()
            }
            if owner.shouldRun {
                let lean = NSAffineTransform()
                lean.translateX(by: target.midX, yBy: target.minY)
                lean.rotate(byDegrees: -5)
                lean.translateX(by: -target.midX, yBy: -target.minY)
                lean.concat()
            }
            sheet.draw(in: target, from: source, operation: .sourceOver, fraction: 1)
            // Briefly ease into the next pose instead of abruptly replacing it.
            let fraction = position-floor(position)
            if fraction > 0.75 {
                let next = (frame+1)%6
                let nextSource = NSRect(x: CGFloat(next%3)*cellW+cellW*0.025,
                                        y: CGFloat(1-next/3)*cellH+cellH*0.025,
                                        width: cellW*0.95, height: cellH*0.95)
                let t = (fraction-0.75)/0.25
                sheet.draw(in: target, from: nextSource, operation: .sourceOver, fraction: t*t*(3-2*t))
            }
            NSGraphicsContext.restoreGraphicsState()
        } else {
            picture.draw(in: rect)
        }
        if let file = owner.pending.first {
            let icon = NSWorkspace.shared.icon(forFile: file.path)
            icon.draw(in: NSRect(x: bounds.midX+(owner.direction < 0 ? -49 : 15), y: bounds.height*0.43, width: 34, height: 34))
        }
        if owner.celebrating {
            ("✦  ✨  ✦" as NSString).draw(at: NSPoint(x: bounds.midX-40, y: bounds.height-66), withAttributes: [.font: NSFont.systemFont(ofSize: 19)])
        }
        let message = owner.message as NSString
        let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: NSColor.labelColor]
        if owner.isHugging {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let textRect = NSRect(x: 18, y: bounds.height-106, width: bounds.width-36, height: 88)
            let bubble = NSBezierPath(roundedRect: textRect.insetBy(dx: -8, dy: -5), xRadius: 16, yRadius: 16)
            NSColor.windowBackgroundColor.withAlphaComponent(0.97).setFill(); bubble.fill()
            message.draw(in: textRect, withAttributes: [.font: NSFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: NSColor.labelColor, .paragraphStyle: paragraph])
            return
        }
        let textSize = message.size(withAttributes: attributes)
        let bubbleWidth = min(bounds.width-4, textSize.width+20)
        let bubble = NSRect(x: (bounds.width-bubbleWidth)/2, y: bounds.height-34, width: bubbleWidth, height: 25)
        NSColor.windowBackgroundColor.withAlphaComponent(0.96).setFill()
        NSBezierPath(roundedRect: bubble, xRadius: 12, yRadius: 12).fill()
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byTruncatingTail
        paragraph.alignment = .center
        var bubbleAttributes = attributes
        bubbleAttributes[.paragraphStyle] = paragraph
        message.draw(in: NSRect(x: bubble.minX+6, y: bubble.minY+5, width: bubble.width-12, height: 16), withAttributes: bubbleAttributes)
    }
    override func mouseDown(with event: NSEvent) {
        if owner?.pending.isEmpty == false { return }
        if convert(event.locationInWindow, from: nil).y > bounds.height-42, owner?.lastTrashed.isEmpty == false { owner?.undoTrash(); return }
        owner?.pauseWander()
        dragStart = NSEvent.mouseLocation
        if event.clickCount == 2 { owner?.celebrate() }
    }
    override func mouseDragged(with event: NSEvent) {
        guard owner?.pending.isEmpty != false, let window, let previous = dragStart else { return }
        let current = NSEvent.mouseLocation
        window.setFrameOrigin(NSPoint(x: window.frame.minX+current.x-previous.x, y: window.frame.minY+current.y-previous.y))
        dragStart = current
    }
    override func mouseUp(with event: NSEvent) { dragStart = nil }
    override func rightMouseDown(with event: NSEvent) {
        guard let menu = owner?.makeMenu() else { return }
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard owner?.pending.isEmpty != false else { return [] }
        owner?.pauseWander()
        owner?.say("Drop to send to Trash")
        return .move
    }
    override func draggingExited(_ sender: NSDraggingInfo?) { owner?.say("Right-click for actions") }
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL] ?? []
        guard !urls.isEmpty else { return false }
        owner?.receive(urls)
        return true
    }
}

final class Companion: NSObject, NSApplicationDelegate {
    var window: NSPanel!
    var view: CompanionView!
    var statusItem: NSStatusItem!
    var images: [String: NSImage] = [:]
    var mode = "standing"
    var isHugging = false
    var hugFrames: [NSImage] = []
    var hugDelays: [Double] = []
    var hugFrame = 0
    var hugElapsed: Double = 0
    var sizeBeforeHug: NSSize?
    struct HugFrame: Decodable { let src: String; let delay: Double }
    var phase: CGFloat = 0
    var walkDistance: CGFloat = 0
    var lastTick = ProcessInfo.processInfo.systemUptime
    var frameDelta: CGFloat = 1.0/60
    var currentSpeed: CGFloat = 0
    var facing: CGFloat = 1
    var isRunning = false
    var shouldRun: Bool { isRunning || !pending.isEmpty }
    var travelSpeed: CGFloat { shouldRun ? 170 : 80 }
    var isWalking = false
    var celebrating = false
    var animation: Timer?
    var pending: [URL] = []
    var bin: NSPanel?
    var destination = NSPoint.zero
    var arrival: (() -> Void)?
    var message = "Right-click for actions"
    var wander: Timer?
    var reset: Timer?
    var focus: Timer?
    var lastTrashed: [(original: URL, trashed: URL)] = []
    var direction: CGFloat = 1
    var wanderTarget: NSPoint?
    var circleCenter: NSPoint?
    var circleRadius: CGFloat = 0
    var circleAngle: CGFloat = 0
    var circleRemaining: CGFloat = 0
    var circleSign: CGFloat = 1
    func applicationDidFinishLaunching(_ notification: Notification) {
        for name in ["standing", "walk-right", "celebrate", "run-0", "run-1"] {
            guard let image = NSImage(contentsOf: Bundle.main.resourceURL!.appendingPathComponent("beomgyu-\(name).png")) else { NSApp.terminate(nil); return }
            images[name] = image
        }
        do {
            let folder = Bundle.main.resourceURL!.appendingPathComponent("hug-frames")
            let data = try Data(contentsOf: folder.appendingPathComponent("frames.json"))
            let entries = try JSONDecoder().decode([HugFrame].self, from: data)
            for entry in entries {
                let name = URL(fileURLWithPath: entry.src).lastPathComponent
                guard let frame = NSImage(contentsOf: folder.appendingPathComponent(name)) else { throw NSError(domain: "Missing hug frame", code: 1) }
                hugFrames.append(frame); hugDelays.append(entry.delay/1000)
            }
        } catch { NSApp.terminate(nil); return }
        window = NSPanel(contentRect: NSRect(x: 100, y: 90, width: 145, height: 210), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.hidesOnDeactivate = false
        view = CompanionView(frame: NSRect(x: 0, y: 0, width: 145, height: 210))
        view.owner = self
        window.contentView = view
        window.orderFrontRegardless()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "✦ BG"
        statusItem.menu = makeMenu()
        if let saved = UserDefaults.standard.array(forKey: "trashHistory") as? [[String]] {
            lastTrashed = saved.compactMap { $0.count == 2 ? (URL(fileURLWithPath: $0[0]), URL(fileURLWithPath: $0[1])) : nil }
        }
        animation = Timer(timeInterval: 1.0/60, repeats: true) { [weak self] _ in
            guard let self else { return }
            let now = ProcessInfo.processInfo.systemUptime
            self.frameDelta = CGFloat(min(max(now-self.lastTick, 0), 0.05))
            self.lastTick = now
            self.phase += self.frameDelta*6.6
            if self.isHugging && !self.hugFrames.isEmpty {
                self.hugElapsed += Double(self.frameDelta)
                while self.hugElapsed >= self.hugDelays[self.hugFrame] {
                    self.hugElapsed -= self.hugDelays[self.hugFrame]
                    self.hugFrame = (self.hugFrame+1)%self.hugFrames.count
                }
            }
            let targetSpeed: CGFloat = self.isWalking ? self.travelSpeed : 0
            let acceleration: CGFloat = self.shouldRun ? 500 : 260
            let change = acceleration*self.frameDelta
            self.currentSpeed += min(max(targetSpeed-self.currentSpeed, -change), change)
            self.facing += (self.direction-self.facing)*min(1, self.frameDelta*14)
            if !self.pending.isEmpty { self.deliveryStep() }
            else if self.wander != nil { self.wanderStep() }
            self.view.needsDisplay = true
        }
        RunLoop.main.add(animation!, forMode: .common)
        toggleWander()
    }
    func say(_ text: String) { message = text; view.needsDisplay = true }
    func makeMenu() -> NSMenu {
        let menu = NSMenu()
        let actions: [(String, Selector)] = [
            ("Show / hide Beomgyu", #selector(toggleVisibility)),
            ("Stand here", #selector(sit)),
            ("Celebrate!", #selector(celebrate)),
            (isHugging ? "Finish hug" : "Need a hug? ♡", #selector(toggleHug)),
            (wander == nil ? "Start wandering" : "Stop wandering", #selector(toggleWander)),
            ("Walk faster", #selector(walk)),
            ("Run!", #selector(run)),
            ("25-minute focus timer", #selector(startFocus)),
            ("Move files to Trash…", #selector(chooseFilesToTrash)),
            ("Undo Trash deliveries", #selector(undoTrash)),
            ("Try Trash helper with a sample file", #selector(demo)),
            ("Tiny", #selector(makeTiny)),
            ("Small", #selector(makeSmall)),
            ("Large", #selector(makeLarge)),
            ("Quit", #selector(quit))]
        for (title, action) in actions {
            let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
            item.target = self
            if action == #selector(walk) { item.state = isRunning ? .off : .on }
            if action == #selector(run) { item.state = isRunning ? .on : .off }
            if !pending.isEmpty && action != #selector(quit) { item.isEnabled = false }
            if action == #selector(undoTrash) { item.isEnabled = !lastTrashed.isEmpty }
            menu.addItem(item)
        }
        menu.autoenablesItems = false
        return menu
    }
    func refreshMenu() { statusItem.menu = makeMenu() }
    func pauseWander() { wander?.invalidate(); wander = nil; wanderTarget = nil; circleCenter = nil; isWalking = false; if statusItem != nil { refreshMenu() } }
    @objc func toggleVisibility() { window.isVisible ? window.orderOut(nil) : window.orderFrontRegardless() }
    @objc func sit() { finishHug(); pauseWander(); reset?.invalidate(); celebrating = false; say("Keeping you company") }
    @objc func cozy() { sit() }
    func finishHug() {
        guard isHugging else { return }
        isHugging = false
        if let size = sizeBeforeHug { setSize(size) }
        sizeBeforeHug = nil
        refreshMenu()
    }
    @objc func toggleHug() {
        guard pending.isEmpty else { return }
        if isHugging { finishHug(); say("Keeping you company"); return }
        pauseWander(); reset?.invalidate(); celebrating = false
        sizeBeforeHug = window.frame.size
        isHugging = true; hugFrame = 0; hugElapsed = 0
        let area = (window.screen ?? NSScreen.main)?.visibleFrame
        setSize(NSSize(width: min(320, area?.width ?? 320), height: min(460, area?.height ?? 460)))
        say("Feel upset? Feel tired? Do not worry I will always be on your side")
        refreshMenu()
    }
    @objc func celebrate() {
        finishHug(); pauseWander(); reset?.invalidate(); celebrating = true; say("You did it! ✦")
        reset = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.celebrating = false
            self.say(self.lastTrashed.isEmpty ? "Right-click for actions" : "Delivered ✓ · Click to Undo")
        }
    }
    @objc func walk() {
        isRunning = false
        if wander == nil { toggleWander() }
        say("A brisk little walk")
        refreshMenu()
    }
    @objc func run() {
        isRunning = true
        if wander == nil { toggleWander() }
        say("Catch me! ✦")
        refreshMenu()
    }
    @objc func toggleWander() {
        if wander != nil { pauseWander(); say("I'll stay here"); return }
        finishHug(); celebrating = false; isWalking = true; say("A little stroll")
        // A marker for the enabled state; movement shares the render clock.
        wander = Timer(timeInterval: 60, repeats: false) { _ in }
        refreshMenu()
    }
    func wanderStep() {
            guard let screen = self.window.screen ?? NSScreen.main else { return }
            let area = screen.visibleFrame.insetBy(dx: 8, dy: 8)
            let minX = area.minX, maxX = max(minX, area.maxX-self.window.frame.width)
            let minY = area.minY, maxY = max(minY, area.maxY-self.window.frame.height)
            let current = self.window.frame.origin
            if let center = self.circleCenter {
                let delta = min(self.circleRemaining, (self.currentSpeed*self.frameDelta)/self.circleRadius)
                self.circleAngle += delta*self.circleSign
                self.circleRemaining -= delta
                let next = NSPoint(x: center.x+cos(self.circleAngle)*self.circleRadius,
                                   y: center.y+sin(self.circleAngle)*self.circleRadius)
                if abs(next.x-current.x) > 0.01 { self.direction = next.x < current.x ? -1 : 1 }
                self.walkDistance += hypot(next.x-current.x, next.y-current.y)
                self.window.setFrameOrigin(next)
                if self.circleRemaining <= 0 { self.circleCenter = nil }
                return
            }
            if self.wanderTarget == nil && Double.random(in: 0...1) < 0.35 {
                // Fit a complete loop inside the screen, starting at his current position.
                let radius = min(CGFloat.random(in: 55...110), (maxX-minX)/4, (maxY-minY)/4)
                if radius >= 25 {
                    let sx: CGFloat = current.x < (minX+maxX)/2 ? 1 : -1
                    let sy: CGFloat = current.y < (minY+maxY)/2 ? 1 : -1
                    let offset = radius/sqrt(2)
                    let center = NSPoint(x: current.x+sx*offset, y: current.y+sy*offset)
                    if center.x-radius >= minX && center.x+radius <= maxX && center.y-radius >= minY && center.y+radius <= maxY {
                        self.circleCenter = center
                        self.circleRadius = radius
                        self.circleAngle = atan2(current.y-center.y, current.x-center.x)
                        self.circleRemaining = 2 * .pi
                        self.circleSign = Bool.random() ? 1 : -1
                        return
                    }
                }
            }
            if self.wanderTarget == nil {
                self.wanderTarget = NSPoint(x: CGFloat.random(in: minX...maxX), y: CGFloat.random(in: minY...maxY))
            }
            guard let target = self.wanderTarget else { return }
            let dx = target.x-current.x, dy = target.y-current.y
            let distance = hypot(dx, dy)
            if distance < 2 {
                self.wanderTarget = nil
                return
            }
            let approachSpeed = min(self.currentSpeed, max(12, distance*3))
            let step = min(distance, approachSpeed*self.frameDelta)
            if abs(dx) > 0.1 { self.direction = dx < 0 ? -1 : 1 }
            self.walkDistance += step
            self.window.setFrameOrigin(NSPoint(x: min(max(current.x+dx/distance*step, minX), maxX),
                                              y: min(max(current.y+dy/distance*step, minY), maxY)))
    }
    @objc func makeTiny() { setSize(NSSize(width: 120, height: 175)) }
    @objc func makeSmall() { setSize(NSSize(width: 145, height: 210)) }
    @objc func makeLarge() { setSize(NSSize(width: 220, height: 310)) }
    func setSize(_ size: NSSize) {
        var rect = window.frame
        rect.size = size
        if let area = window.screen?.visibleFrame {
            rect.origin.x = min(max(rect.minX, area.minX), max(area.minX, area.maxX-size.width))
            rect.origin.y = min(max(rect.minY, area.minY), max(area.minY, area.maxY-size.height))
        }
        window.setFrame(rect, display: true)
        view.frame = NSRect(origin: .zero, size: size)
        wanderTarget = nil
        circleCenter = nil
    }
    @objc func startFocus() {
        focus?.invalidate(); sit(); say("Focus time · 25 minutes")
        focus = Timer.scheduledTimer(withTimeInterval: 25*60, repeats: false) { [weak self] _ in
            self?.cozy(); self?.say("Nice work. Stretch break?"); NSSound.beep()
        }
    }
    @objc func chooseFilesToTrash() {
        guard pending.isEmpty else { return }
        pauseWander()
        let picker = NSOpenPanel()
        picker.title = "Choose items for Beomgyu to carry to Trash"
        picker.prompt = "Choose items"
        picker.canChooseFiles = true
        picker.canChooseDirectories = true
        picker.allowsMultipleSelection = true
        NSApp.activate(ignoringOtherApps: true)
        if picker.runModal() == .OK { receive(picker.urls) }
    }
    @objc func demo() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Beomgyu-demo-\(UUID().uuidString.prefix(6)).txt")
        do { try "A disposable sample for Beomgyu's Trash helper. Undo brings it back.".write(to: url, atomically: true, encoding: .utf8); receive([url]) }
        catch { showError(error.localizedDescription) }
    }
    func receive(_ urls: [URL]) {
        guard pending.isEmpty else { return }
        finishHug(); pauseWander()

        let alert = NSAlert()
        alert.messageText = "Move \(urls.count == 1 ? urls[0].lastPathComponent : "\(urls.count) items") to Trash?"
        alert.informativeText = "Beomgyu will move these items to the Mac Trash. You can restore them with Undo last Trash action."
        alert.addButton(withTitle: "Move to Trash")
        alert.addButton(withTitle: "Cancel")
        NSApp.activate(ignoringOtherApps: true)
        guard alert.runModal() == .alertFirstButtonReturn else { say("Keeping that safe"); return }
        pending = urls
        reset?.invalidate(); celebrating = false; isWalking = true
        let screen = window.screen ?? NSScreen.main!
        let area = screen.visibleFrame
        let target = NSRect(x: area.maxX-92, y: area.minY+6, width: 80, height: 80)
        bin = NSPanel(contentRect: target, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        bin?.isOpaque = false; bin?.backgroundColor = .clear; bin?.level = .floating
        bin?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        let label = NSTextField(labelWithString: "🗑\nTrash")
        label.alignment = .center; label.font = .systemFont(ofSize: 24)
        label.frame = NSRect(x: 0, y: 0, width: 80, height: 80)
        bin?.contentView?.addSubview(label); bin?.orderFrontRegardless()
        destination = NSPoint(x: target.minX-window.frame.width+30, y: area.minY+8)
        say("Running with \(urls.count) item\(urls.count == 1 ? "" : "s")…")
        refreshMenu()
    }
    func deliveryStep() {
        let current = window.frame.origin
        let dx = destination.x-current.x, dy = destination.y-current.y
        let distance = hypot(dx, dy)
        if abs(dx) > 0.5 { direction = dx < 0 ? -1 : 1 }
        let step = min(distance, currentSpeed*frameDelta)
        walkDistance += step
        if distance <= step {
            window.setFrameOrigin(destination)
            let urls = pending; pending = []; isWalking = false
            bin?.orderOut(nil); bin = nil
            completeDelivery(urls)
            return
        }
        window.setFrameOrigin(NSPoint(x: current.x+dx/distance*step, y: current.y+dy/distance*step))
    }
    func saveHistory() {
        UserDefaults.standard.set(lastTrashed.map { [$0.original.path, $0.trashed.path] }, forKey: "trashHistory")
    }
    func completeDelivery(_ urls: [URL]) {
        var failures: [String] = []
        for url in urls {
            do {
                var destination: NSURL?
                try FileManager.default.trashItem(at: url, resultingItemURL: &destination)
                if let destination { lastTrashed.append((url, destination as URL)) }
            } catch { failures.append("\(url.lastPathComponent): \(error.localizedDescription)") }
        }
        if failures.isEmpty { celebrate(); say("Delivered to Trash ✓") }
        else { showError(failures.joined(separator: "\n")) }
        saveHistory(); refreshMenu()
    }
    @objc func undoTrash() {
        var remaining: [(original: URL, trashed: URL)] = []
        for item in lastTrashed {
            do { try FileManager.default.moveItem(at: item.trashed, to: item.original) }
            catch { remaining.append(item); showError(error.localizedDescription) }
        }
        lastTrashed = remaining
        saveHistory()
        say(remaining.isEmpty ? "Your files are back ✓" : "Some files couldn't be restored")
        refreshMenu()
    }
    func showError(_ message: String) { let alert = NSAlert(); alert.messageText = "Couldn't complete that"; alert.informativeText = message; alert.runModal() }
    @objc func quit() {
        if !pending.isEmpty { pending = []; bin?.orderOut(nil) }
        NSApp.terminate(nil)
    }
}
let app = NSApplication.shared
let companion = Companion()
app.delegate = companion
app.setActivationPolicy(.accessory)
app.run()
