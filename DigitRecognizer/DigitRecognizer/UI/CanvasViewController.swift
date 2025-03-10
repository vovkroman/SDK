import UIKit
import Canvas
import FutureKit

enum Recognizer {}

protocol Applyable: class {
    func apply(_ presenter: Recognizer.Node)
}

protocol Animatable {
    var from: UIView { get }
    var to: UIImageView { get }
    func performSnapshot(_ image: UIImage)
}

class CanvasViewController: UIViewController {
    
    @IBOutlet private weak var canvas: Canvas!
    @IBOutlet private var interpreter: Interpreter!
    
    private let viewModel = Recognizer.ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction private func didClear(_ sender: Any) {
        canvas.clear()
    }
}

extension CanvasViewController: DrawingDelegate {
    func drawingDidStart(on view: DrawingView) {}
    func drawingDidFinish(on view: DrawingView) {
        do {
            try canvas.makeSnapshot()
                .animate(view: self)
                .convertOf(viewModel)
                .apply(to: interpreter)
        } catch {
            debugPrint("Something went wrong")
        }
    }
}

extension CanvasViewController: Animatable {
    var from: UIView { return canvas }
    var to: UIImageView { return interpreter.imageView }
    
    func performSnapshot(_ image: UIImage) {
        let snapshot = from.makeSnapshotView()
        view.addSubview(snapshot)
        let toPoint = to.convert(to.center, to: view)
        let toFrame = to.convert(to.frame, to: view)
        UIView.animateKeyframes(withDuration: 0.55, delay: 0.0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                self.to.alpha = 0.0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                snapshot.center = toPoint
                snapshot.frame = toFrame
            }
        }, completion: { _ in
            self.to.alpha = 1.0
            self.to.image = image
            snapshot.removeFromSuperview()
        })
    }
}


