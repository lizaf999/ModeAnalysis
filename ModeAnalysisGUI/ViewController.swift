import Cocoa
import MetalKit

class ViewController: NSViewController {
    @IBOutlet weak var mtkview: MTKView!
    @IBOutlet weak var idTextField: NSTextField!
    @IBOutlet weak var calcButton: NSButton!
    @IBAction func idEntered(_ sender: NSTextField) {
        if let id = Int(sender.stringValue) {
            sender.isEnabled = false
            drawDisplacedVertices(ID: id)
            sender.isEnabled = true
        }
    }
    @IBAction func calcStart(_ sender: Any) {
        calcButton.isEnabled = false
        primitivePopup.isEnabled = false
        DispatchQueue.global(qos: .default).async {
            self.mode.solveEigen()
            DispatchQueue.main.async {
                self.idTextField.isEnabled = true
                self.primitivePopup.isEnabled = true
            }
        }
    }
    @IBOutlet weak var primitivePopup: NSPopUpButton!{
        didSet{
            primitivePopup.removeAllItems()
            primitivePopup.addItem(withTitle: "PrimitiveType")

            for type in PrimitiveType.types {
                let menu = NSMenuItem(title: type, action: #selector(typeSelected(item:)), keyEquivalent: "")
                menu.target = self
                primitivePopup.menu?.addItem(menu)
            }
        }
    }


    //for camera
    var preMouse:NSPoint = NSPoint()
    //model
    var mode:Polygon! = nil

    enum PrimitiveType:String {
        case Parallelogram = "Parallelogram"
        case Sphere = "Sphere"
        case Torus = "Torus"
        case GeodesicDome = "GeodesicDome"
        case SphereImplicit = "SphereImplict"

        static let types:[String] = [Parallelogram,Sphere,Torus,GeodesicDome,SphereImplicit].map{$0.rawValue}
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        idTextField.isEnabled = false
        calcButton.isEnabled = false

        defaultSetup(mtkview)
    }

    func drawPrimitive(){
        let obj = MeshRender()
        let mesh = Mesh(pos: mode.vertices, normal: mode.normal, indices: mode.faces)
        if !obj.setup(.Diffuse, meshs: [mesh]){
            NSLog("Mesh could not be created.")
            return
        }

        removeAllRenderTarget()
        addRenderTargets(target: obj)
    }

    func drawDisplacedVertices(ID:Int){
        //FIXME: 上限ギリギリのIDが入ってくるとgetEigenVectorで落ちる
        if mode.vertices.isEmpty||ID<0||ID>=mode.vertices.count {
            return
        }
        //let pos:[double3] = mode.getDisplacedVertices(ID: ID)
        let pos:[double3] = mode.vertices

        let obj = MeshRender()
        let mesh = Mesh(pos: pos, normal: mode.getDisplacedNormal(pos: pos), indices: mode.faces, values: mode.getEigenVector(ID: ID))
        if !obj.setup(.Diffuse, meshs: [mesh]){
            NSLog("Mesh could not be created.")
            return
        }

        removeAllRenderTarget()
        addRenderTargets(target: obj)
    }

    @objc func typeSelected(item:NSMenuItem){
        if primitivePopup.title != item.title {
            calcButton.isEnabled = true
        }
        primitivePopup.title = item.title

        if let type = PrimitiveType(rawValue: item.title) {
            switch type{
            case .Parallelogram:
                mode = Parallelogram()
            case .Sphere:
                mode = Sphere()
            case .Torus:
                mode = Torus()
            case .GeodesicDome:
                mode = GeodesicDome()
            case .SphereImplicit:
                mode = SphereImplicit()
            }

            mode.setMesh()
            drawPrimitive()
        }
        idTextField.isEnabled = false
    }

    override func mouseDown(with event: NSEvent) {
        preMouse = event.locationInWindow
    }
    override func mouseDragged(with event: NSEvent)
    {
        let p:NSPoint = event.locationInWindow
        let dP:CGFloat = p.x-preMouse.x
        let dT:CGFloat = p.y-preMouse.y
        Render.current.camera.polarPosRTP += float3(0,Float(dT/self.view.frame.width),Float(-dP/self.view.frame.height))*5
        Render.current.camera.setUpDir()
        preMouse = p

    }
    override func magnify(with event: NSEvent) {
        Render.current.camera.polarPosRTP.x += -Float(event.magnification*30)
    }



}

