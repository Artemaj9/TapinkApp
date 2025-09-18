import Metal
import MetalKit

class MagicMetalView: MTKView {
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var effect: String!
    var time: Float = 0
    var texture: MTLTexture?

    let vertices: [SIMD2<Float>] = [
        SIMD2<Float>(0, 0),
        SIMD2<Float>(1, 0),
        SIMD2<Float>(0, 1),
        SIMD2<Float>(1, 1)
    ]

  init(effect: String, frame: CGRect, isTexture: Bool = false) {
        self.effect = effect
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
    if isTexture {
      self.isOpaque = false
      self.layer.isOpaque = false
      self.clearColor = MTLClearColorMake(0, 0, 0, 0)
    }
        self.commandQueue = device!.makeCommandQueue()
    self.setupPipeline(isTexture: isTexture)

        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .default)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

  func setupPipeline(isTexture: Bool = false) {
        let library = device!.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertexShader")
        let fragmentFunction = library?.makeFunction(name: effect)

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    if isTexture {
      let attachment = pipelineDescriptor.colorAttachments[0]!
      attachment.isBlendingEnabled = true
      attachment.rgbBlendOperation = .add
      attachment.alphaBlendOperation = .add
      attachment.sourceRGBBlendFactor = .sourceAlpha
      attachment.sourceAlphaBlendFactor = .sourceAlpha
      attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
      attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
    }

        do {
            pipelineState = try device!.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            print("Failed to create pipeline state: \(error)")
        }
    }

    @objc func update() {
        self.time += 1.0 / Float(self.preferredFramesPerSecond)
        self.setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let drawable = currentDrawable else { return }
        let renderPassDescriptor = currentRenderPassDescriptor!
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBytes(vertices, length: vertices.count * MemoryLayout<SIMD2<Float>>.size, index: 0)

        renderEncoder.setFragmentBytes(&time, length: MemoryLayout<Float>.size, index: 0)
        var resolution = SIMD2<Float>(Float(drawable.texture.width), Float(drawable.texture.height))
        renderEncoder.setFragmentBytes(&resolution, length: MemoryLayout<SIMD2<Float>>.size, index: 1)

        if let texture = texture {
            renderEncoder.setFragmentTexture(texture, index: 0)
        }

        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

func loadTexture(image: UIImage, device: MTLDevice) -> MTLTexture? {
    func dataForImage(_ image: UIImage) -> UnsafeMutablePointer<UInt8> {
        let imageRef = image.cgImage
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
        let bytePerPixel = 4
        let bytesPerRow = bytePerPixel * Int(width)
        let bitsPerComponent = 8
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        if let context = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) {
            context.clear(CGRect(x: 0, y: 0, width: width, height: height))
            context.draw(imageRef!, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        return rawData
    }
    
    let width = Int(image.size.width * image.scale)
    let height = Int(image.size.height * image.scale)
    let bytePerPixel = 4
    let bytesPerRow = bytePerPixel * width
    
    var texture: MTLTexture?
    let region = MTLRegionMake2D(0, 0, Int(width), Int(height))
    let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: width, height: height, mipmapped: false)
    texture = device.makeTexture(descriptor: textureDescriptor)
    
    let data = dataForImage(image)
    texture?.replace(region: region, mipmapLevel: 0, withBytes: data, bytesPerRow: bytesPerRow)

    data.deallocate()
    
    return texture
}
