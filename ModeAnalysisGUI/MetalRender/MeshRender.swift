import Foundation
import MetalKit

struct VertexStructure {
    var pos: float4
    var normal:float4
    var color:float4
    var value: Float

    init(pos:float3,normal:float3,color:float4,value:Float) {
        self.pos = float4(pos.x,pos.y,pos.z,1)
        self.normal = float4(normal.x,normal.y,normal.z,0)
        self.color = color
        self.value = value
    }
}

public func addRenderTargets(target:MeshRender) {
    Render.current.renderTargets.append(target)
}

public func removeAllRenderTarget() {
    Render.current.renderTargets.removeAll()
}

//使い方
//Meshを作りmeshRenderのsetupを呼ぶ
//addRenderTargetsする
public class MeshRender: RenderProtocol {
    //Indices of vertex attribute in descriptor
    enum VertexAttribute: Int {
        case Position = 0
        case Normal = 1
        case Color = 2
        case Value = 3
        func index() -> Int {return self.rawValue}
    }

    //shader set
    public enum ShaderType:Int {
        case Diffuse = 0
        case Metal = 1
    }

    private var pipelineState : MTLRenderPipelineState! = nil
    private var depthState: MTLDepthStencilState! = nil

    //Mesh(Surface)
    private var meshs: [Mesh]! = nil
    private var frameUniformBuffers: [MTLBuffer] = []

    //Uniforms
    var modelMatrix = matrix_identity_float4x4

    public init() {}

    public func setup(_ shaderType:ShaderType, meshs: [Mesh] ) -> Bool {
        let device = Render.current.device
        let mtkview = Render.current.mtkView
        let library = Render.current.library

        var vertexShaderName:String = ""
        var fragmentShaderName:String = ""
        switch shaderType {
        case .Diffuse:
            vertexShaderName = "staticShaderVertex"
            fragmentShaderName = "staticShaderFragment"
        case .Metal:
            vertexShaderName = ""
            fragmentShaderName = ""
            fatalError("This shader is not implemented.")
        }

        guard let vertex_pg = library?.makeFunction(name: vertexShaderName) else {
            NSLog("Vertex shader could not be made.")
            return false
        }
        guard let fragment_pg = library?.makeFunction(name: fragmentShaderName) else {
            NSLog("Fragment shader could not be made.")
            return false

        }

        let vertexDescriptor = MTLVertexDescriptor()
        //Positions.
        let attr_pos = vertexDescriptor.attributes[VertexAttribute.Position.index()]
        attr_pos?.format = .float4
        attr_pos?.offset = 0
        attr_pos?.bufferIndex = Mesh.Buffer.MeshVertex.index()

        //Normal
        let attr_nor = vertexDescriptor.attributes[VertexAttribute.Normal.index()]
        attr_nor?.format = .float4
        attr_nor?.offset = 16
        attr_nor?.bufferIndex = Mesh.Buffer.MeshVertex.index()

        //Color
        let attr_col = vertexDescriptor.attributes[VertexAttribute.Color.index()]
        attr_col?.format = .float4
        attr_col?.offset = 32
        attr_col?.bufferIndex = Mesh.Buffer.MeshVertex.index()

        //Scalar value
        let attr_val = vertexDescriptor.attributes[VertexAttribute.Value.index()]
        attr_val?.format = .float
        attr_val?.offset = 48
        attr_val?.bufferIndex = Mesh.Buffer.MeshVertex.index()

        //interleaved buffer
        let layout = vertexDescriptor.layouts[Mesh.Buffer.MeshVertex.index()]
        layout?.stride = MemoryLayout<VertexStructure>.stride
        layout?.stepRate = 1
        layout?.stepFunction = .perVertex

        //Create pipeline state
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "MeshPipeline"
        pipelineDescriptor.sampleCount = (mtkview?.sampleCount)!///?
        pipelineDescriptor.vertexFunction = vertex_pg
        pipelineDescriptor.fragmentFunction = fragment_pg
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkview!.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = mtkview!.depthStencilPixelFormat
        //pipelineDescriptor.stencilAttachmentPixelFormat = mtkview!.depthStencilPixelFormat
        do {
            pipelineState = try device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            NSLog("MTLRenderPipelineState could not be made.")
            return false
        }

        let depthDescripor = MTLDepthStencilDescriptor()
        depthDescripor.depthCompareFunction = .less
        depthDescripor.isDepthWriteEnabled = true
        depthState = device?.makeDepthStencilState(descriptor: depthDescripor)

        //TODO: Create meshes here!
        self.meshs = meshs

        for _ in 0..<Render.bufferCount {
            frameUniformBuffers += [(device?.makeBuffer(length: MemoryLayout<VertexUniform>.size, options: .cpuCacheModeWriteCombined))!]
        }

        return true
    }

    func update() {
        //update uniformbuffer via pointer
        let render = Render.current

        let rawptr = OpaquePointer(frameUniformBuffers[render.activeBufferNumber].contents())
        let p = UnsafeMutablePointer<VertexUniform>(rawptr)
        var uni = p.pointee
        let mat = render.camera.GetViewMatrix() * modelMatrix
        uni.projectionView = render.projevtionMatrix * mat
        uni.normal = mat.inverse.transpose
        uni.time = UniformState.controlableTime
        p.pointee = uni
    }

    func render(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.pushDebugGroup("Render Meshes")
        //MARK: Attention FrontFacing
        //renderEncoder.setCullMode(.front)
        renderEncoder.setDepthStencilState(depthState)
        renderEncoder.setRenderPipelineState(pipelineState)

        renderEncoder.setVertexBuffer(frameUniformBuffers[Render.current.activeBufferNumber], offset: 0, index: Mesh.Buffer.FrameUniform.index())

        meshs.forEach { $0.render(encoder: renderEncoder) }

        renderEncoder.popDebugGroup()
    }
}













