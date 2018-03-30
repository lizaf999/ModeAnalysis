import Foundation
import MetalKit

//MARK: - Protocol
protocol RenderProtocol {
    func update()
    func render(renderEncoder :MTLRenderCommandEncoder)
}

public func defaultSetup(_ mtkView :MTKView) {
    if let curView = Render.current.setupView(view: mtkView) {
        curView.sampleCount = 1
        curView.depthStencilPixelFormat = .depth32Float
        curView.colorPixelFormat = .bgra8Unorm
        curView.clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1)
        //curView.clearColor = MTLClearColorMake(1,1,1, 1)
        
        //Compute Shader 利用時はfalse
        curView.framebufferOnly = false
        
        Render.current.camera.setUpDir()
    } else {
        assert(false)
    }
    
}

//MARk: -
//使い方
//defaultSetupを呼ぶ(Renderのインスタンス不要)
//RenderProtocolに適合するオブジェクトを追加する。
//Render.current.cameraはよく使う
class Render: NSObject,MTKViewDelegate {
    //Buffer count
    static let bufferCount = 3
    
    //camera prop.
    let defaultCameraFovY: Float = 75.0
    let defaultCameraNearZ: Float = 0.1
    let defaultCameraFarZ: Float = 100
    let camera = Camera(polar: float3(2,0,-Float.pi/2), center: float3(0), up: float3(0,1,0))
    
    //Singleton
    static let current = Render()
    private(set) static var canUse = false
    
    //View
    weak var mtkView: MTKView! = nil
    private let semaphore = DispatchSemaphore(value: Render.bufferCount)
    private(set) var activeBufferNumber = 0
    
    //Renderer
    private(set) var device: MTLDevice!
    private(set) var commandQueue: MTLCommandQueue!
    private(set) var library: MTLLibrary!
    
    //Uniforms
    var projevtionMatrix: float4x4 = matrix_identity_float4x4
    var cameraMatrix: float4x4 = matrix_identity_float4x4
    var viewportNear = 0.0
    var viewportFar = 1.0
    
    //Objects
    var renderTargets = [RenderProtocol]()
    
    override init() {
        Render.canUse = false
        
        //initialize Metal
        guard let new_dev = MTLCreateSystemDefaultDevice() else {NSLog("MTLDevice could not be created.");return}
        device = new_dev
        commandQueue = device.makeCommandQueue()
        guard let new_lib = device.makeDefaultLibrary() else {NSLog("MTLLibrary could not be made.");return}
        library = new_lib
        
        Render.canUse = true
        NSLog("Render initialization succeeded!")
    }
    
    //MARK: - public
    func setupView(view: MTKView?) -> MTKView? {
        guard Render.canUse else {return nil}
        guard view != nil else {return nil}
        
        mtkView = view!
        mtkView.delegate = self
        mtkView.device = device
        
        let aspect = Float(fabs(view!.bounds.size.width/view!.bounds.height))
        projevtionMatrix = perspective_fov(fovyDeg: defaultCameraFovY, aspect: aspect, near: defaultCameraNearZ, far: defaultCameraFarZ)
        
        return view
    }
    
    //MARK: - MTKViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let aspect = Float(fabs(view.bounds.size.width/view.bounds.height))
        projevtionMatrix = perspective_fov(fovyDeg: defaultCameraFovY, aspect: aspect, near: defaultCameraNearZ, far: defaultCameraFarZ)
    }
    
    func draw(in view: MTKView) {
        autoreleasepool{
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            let commandBuffer = Render.current.commandQueue.makeCommandBuffer()
            
            update()
            guard let renderDescriptor = mtkView.currentRenderPassDescriptor else{ return }
            
            let renderEncoder = (commandBuffer?.makeRenderCommandEncoder(descriptor: renderDescriptor))!
            renderEncoder.setViewport(MTLViewport(
                originX: 0, originY: 0, width: Double(mtkView.drawableSize.width), height: Double(mtkView.drawableSize.height), znear: viewportNear, zfar: viewportFar))
            
            render(renderEncoder: renderEncoder)
            
            renderEncoder.endEncoding()
            
            let block_sema = semaphore
            commandBuffer?.addCompletedHandler({_ in
                block_sema.signal()
            })
            commandBuffer?.present(mtkView.currentDrawable!)
            commandBuffer?.commit()
        }
    }
    
    //MARK: - private
    private func update() {
        renderTargets.forEach {$0.update()}
    }
    
    private func render(renderEncoder: MTLRenderCommandEncoder){
        renderTargets.forEach{$0.render(renderEncoder: renderEncoder)}
    }
    
    
}













