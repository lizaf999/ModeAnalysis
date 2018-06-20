import Cocoa
import MetalKit

class ViewController: NSViewController {
  @IBOutlet weak var mtkview: MTKView!
  @IBOutlet weak var idTextField: NSTextField!
  @IBOutlet weak var calcButton: NSButton!
  @IBOutlet weak var animationButton: NSButton!
  @IBAction func animationEnable(_ sender: NSButton) {
    UniformState.isSuspended = sender.state == .off
  }
  @IBAction func idEntered(_ sender: NSTextField) {
    if let id = Int(sender.stringValue) {
      sender.isEnabled = false
      
      if let mode = DrawMode(rawValue: drawModePopup.titleOfSelectedItem!) {
        switch mode {
        case .EigenVector:
          drawDisplacedVertices(ID: id)
        case .SeriesExpansion:
          drawProjectedOnEigenVec(ID: id)
        }
      }else{
        print("Invalid drawMode")
      }
      
      sender.isEnabled = true
    }
  }
  @IBAction func calcStart(_ sender: Any) {
    calcButton.isEnabled = false
    primitivePopup.isEnabled = false
    animationButton.isEnabled = false
    DispatchQueue.global(qos: .default).async {
      self.mode.solveEigen()
      DispatchQueue.main.async {
        self.drawDisplacedVertices(ID: 4)
        
        self.idTextField.isEnabled = true
        self.primitivePopup.isEnabled = true
        self.animationButton.isEnabled = true
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
  
  @IBOutlet weak var drawModePopup: NSPopUpButton!{
    didSet{
      drawModePopup.removeAllItems()
      
      for mode in DrawMode.modes {
        let menu = NSMenuItem(title: mode, action: nil, keyEquivalent: "")
        menu.target = self
        drawModePopup.menu?.addItem(menu)
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
    case Bunny = "Bunny"
    case Teapot = "Teapot"
    
    static let types:[String] = [Parallelogram,Sphere,Torus,GeodesicDome,SphereImplicit,Bunny,Teapot].map{$0.rawValue}
  }
  
  enum DrawMode:String {
    case EigenVector = "EigenVector"
    case SeriesExpansion = "SeriesExpansion"
    
    static let modes:[String] = [EigenVector,SeriesExpansion].map{$0.rawValue}
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    idTextField.isEnabled = false
    calcButton.isEnabled = false
    animationButton.state = .on
    animationButton.isEnabled = false
    
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
  
  func drawProjectedOnEigenVec(ID:Int) {
    if mode.vertices.isEmpty||ID<0||ID>=mode.vertices.count {
      return
    }
    let pos:[double3] = mode.getVerticesProjectedOn(ID: ID)
    
    let obj = MeshRender()
    let mesh = Mesh(pos: pos, normal: mode.getDisplacedNormal(pos: pos), indices: mode.faces)
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
      case .Bunny:
        mode = InputMesh(filename: "bunny_res4", Extension: "ply")
      case .Teapot:
        mode = InputMesh(filename: "Teapot", Extension: "obj")
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

