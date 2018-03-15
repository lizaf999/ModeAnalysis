import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mode = Polygon()
        let (v,f) = Palallelogram()
        mode.setMesh(vertices: v, faces: f)
        mode.solveEigen()
        
        mode.printDisplacedVertices(ID: 7)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

