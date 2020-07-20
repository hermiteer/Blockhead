//
//  ViewController.swift
//  Pixelated Faces
//
//  Created by Christoph on 7/6/20.
//  Copyright © 2020 Hermiteer, LLC. All rights reserved.
//


import ARKit
import SceneKit
import UIKit
import VideoToolbox

class ViewController: UIViewController, ARSCNViewDelegate {

    // MARK: Views

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var screenView: UIView!
    @IBOutlet var hudView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewHeightConstraint: NSLayoutConstraint!

    let textureView: UIView = {
        let view = UIView()
        view.alpha = 0.5
        view.backgroundColor = .red
        return view
    }()

    private var sceneViewSize = CGSize.zero
    private var orientation = UIInterfaceOrientation.unknown

    private var hudViewIsHidden = false {
        didSet {
            self.screenView.isHidden = hudViewIsHidden
            self.hudView.subviews.forEach { $0.isHidden = hudViewIsHidden }
            self.sceneView.showsStatistics = !hudViewIsHidden
        }
    }

    // MARK: Filters

    private let context = CIContext()

    private let blocky: CIFilter? = {
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(32.0, forKey: kCIInputScaleKey)
        return filter
    }()

    private let chunky: CIFilter? = {
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(16.0, forKey: kCIInputScaleKey)
        return filter
    }()

    private lazy var filter: CIFilter? = nil

    // MARK: Various controls

    var boxOpacity: Amount = .full {
        didSet {
            self.sceneView.session.delegateQueue?.async {
                guard let node = self.boxNode else { return }
                node.opacity = self.boxOpacity.floatValue
            }
        }
    }

    var faceOpacity: Amount = .none {
        didSet {
            self.sceneView.session.delegateQueue?.async {
                guard let node = self.faceNode else { return }
                node.opacity = self.faceOpacity.floatValue
            }
        }
    }

    var screenOpacity: Amount = .none {
        didSet {
            self.screenView.alpha = self.screenOpacity.floatValue
        }
    }

    var pixellateAmount: Amount = .none {
        didSet {
            self.sceneView.session.delegateQueue?.async {
                switch self.pixellateAmount {
                    case .full: self.filter = self.blocky
                    case .some: self.filter = self.chunky
                    case .none: self.filter = nil
                }
            }
        }
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegateQueue = DispatchQueue(label: "delegate",
                                                        qos: .userInteractive,
                                                        attributes: .concurrent,
                                                        autoreleaseFrequency: .workItem,
                                                        target: nil)
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene

        // initial values
        self.imageView.addSubview(self.textureView)
        self.boxOpacity = .full
        self.faceOpacity = .none
        self.screenOpacity = .none

        let singleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(hudViewSingleTap(gesture:)))
        self.hudView.addGestureRecognizer(singleTap)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.sceneViewSize = self.sceneView.bounds.size
        self.orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .unknown
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = 1

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: Actions

    @IBAction
    func boxButtonTouchUpInside(button: UIButton) {
        let opacity = self.boxOpacity.next
        self.boxOpacity = opacity
        button.setImage(opacity.boxImage, for: .normal)
    }

    @IBAction
    func faceButtonTouchUpInside(button: UIButton) {
        let opacity = self.faceOpacity.next
        self.faceOpacity = opacity
        button.setImage(opacity.faceImage, for: .normal)
    }

    @IBAction
    func screenButtonTouchUpInside(button: UIButton) {
        let opacity = self.screenOpacity.next
        self.screenOpacity = opacity
        button.setImage(opacity.screenImage, for: .normal)
    }

    @IBAction
    func pixellateButtonTouchUpInside(button: UIButton) {
        let opacity = self.pixellateAmount.next
        self.pixellateAmount = opacity
        button.setImage(opacity.pixellateImage, for: .normal)
    }

    @objc func hudViewSingleTap(gesture: UITapGestureRecognizer) {
        self.hudViewIsHidden = !self.hudViewIsHidden
    }

    // MARK: ARSCNViewDelegate

    private var faceNode: SCNNode?
    private var boxNode: SCNNode?

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {

        // face node
        guard let _ = anchor as? ARFaceAnchor else { return nil }
        guard let device = self.sceneView.device else { return nil }
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let faceNode = SCNNode(geometry: faceGeometry)
        faceNode.opacity = self.faceOpacity.floatValue
        self.faceNode = faceNode

        // box node
        let box = SCNBox(width: 0.22, height: 0.22, length: 0.22, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.75)
        box.firstMaterial?.fillMode = .fill
        let boxNode = SCNNode(geometry: box)
        boxNode.castsShadow = true
        boxNode.opacity = self.boxOpacity.floatValue
        self.sceneView.scene.rootNode.addChildNode(boxNode)
        self.boxNode = boxNode

        // done
        self.update(boxNode, with: faceNode)
        return faceNode
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

        // update face geometry if tracked
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        guard faceAnchor.isTracked else { return }
        guard let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        faceGeometry.update(from: faceAnchor.geometry)

        // update box node
        guard let boxNode = self.boxNode else { return }
        self.update(boxNode, with: node)
    }

    private func update(_ boxNode: SCNNode, with faceNode: SCNNode) {

        // position box over face/head
        // slightly offset to center on head vs face
        var worldPosition = faceNode.worldPosition
        worldPosition.y += 0.01
        worldPosition.z += -0.03
        boxNode.worldPosition = worldPosition
        boxNode.worldOrientation = faceNode.worldOrientation

        // limit orientations for now
        guard self.orientation == .landscapeRight else { return }
        let orientation = self.orientation
        let screenSize = self.sceneViewSize

        // capture image from frame
        // this is 1440x1080 for iPhone 11 Pro
        // and must be transformed into screen orientation
        guard let frame = self.sceneView.session.currentFrame else { return }
        let buffer = frame.capturedImage
        let bufferWidth = CVPixelBufferGetWidth(buffer)
        let bufferHeight = CVPixelBufferGetHeight(buffer)
        let bufferSize = CGSize(width: bufferWidth, height: bufferHeight)
        let transform = frame.displayTransform(for: orientation,
                                               viewportSize: bufferSize)
        let bufferImage = CIImage(cvPixelBuffer: buffer).transformed(by: transform)

        // face to bounding
        let rootNode = self.sceneView.scene.rootNode
        let (faceCenter, faceRadius) = faceNode.boundingSphere
        let boundingRight = SCNVector3(faceCenter.x + faceRadius, faceCenter.y, faceCenter.z)
        let boundingUp = SCNVector3(faceCenter.x, faceCenter.y + faceRadius, faceCenter.z)
        let boundingFront = SCNVector3(faceCenter.x, faceCenter.y, faceCenter.z + faceRadius)

        // bounding to world
        let worldCenter = faceNode.convertPosition(faceCenter, to: rootNode)
        let worldRight = faceNode.convertPosition(boundingRight, to: rootNode)
        let worldUp = faceNode.convertPosition(boundingUp, to: rootNode)
        let worldFront = faceNode.convertPosition(boundingFront, to: rootNode)

        // world to screen
        let screenCenter = self.sceneView.projectPoint(worldCenter)
        let screenRight = self.sceneView.projectPoint(worldRight)
        let screenUp = self.sceneView.projectPoint(worldUp)
        let screenFront = self.sceneView.projectPoint(worldFront)

        // use the largest radius from all 3 axis
        let radiusRight = SCNVector3.distanceFrom(vector: screenCenter, toVector: screenRight)
        let radiusUp = SCNVector3.distanceFrom(vector: screenCenter, toVector: screenUp)
        let radiusFront = SCNVector3.distanceFrom(vector: screenCenter, toVector: screenFront)
        let radius = fmax(radiusRight, fmax(radiusUp, radiusFront))

        // screen center and radius to square
        let x = screenCenter.x - radius
        let y = screenCenter.y - radius
        let screenRect = CGRect(x: CGFloat(x),
                                y: CGFloat(y),
                                width: CGFloat(radius * 2),
                                height: CGFloat(radius * 2))

        // TODO transform utility
        // screen to image
        // the scene view only shows a vertically centered slice
        // of the entire camera image, so transform the screen
        // rect to be in the image coordinate space
        var imageRect = screenRect
        let height = (screenSize.width / (CGFloat(bufferWidth) / CGFloat(bufferHeight))) - screenSize.height
        let offset = height / 2.0
        imageRect.origin.y += offset
        let imageToScreenRatio = CGFloat(bufferWidth) / CGFloat(screenSize.width)
        imageRect.origin.x *= imageToScreenRatio
        imageRect.origin.y *= imageToScreenRatio
        imageRect.size.width *= imageToScreenRatio
        imageRect.size.height *= imageToScreenRatio

        // image to texture
        // image coordinates are top left but texture coordinates are bottom left
        // so flip the rect origin from top left to bottom left, it's important
        // to only use the textureRect values instead of recalculating from above
        var textureRect = imageRect
        textureRect.origin.y = CGFloat(bufferHeight) - textureRect.origin.y - textureRect.size.height

        // crop image to texture
        var textureImage = bufferImage.cropped(to: textureRect)

        // TODO texture gets larger when the face gets closer
        // TODO but the pixellate stays the same, needs to adjust
        // TODO so that the texture is decimated to the same scale
        // TODO no matter what the Z distance is
        // apply filter if necessary
        if let filter = self.filter {
            filter.setValue(textureImage, forKey: kCIInputImageKey)
            textureImage = filter.outputImage ?? textureImage
        }

        // TODO filter cuts off edge pixels, find a way to repeat?
        // TODO wrapS and wrapT options don't seem to work
        // apply texture and transform
        boxNode.geometry?.firstMaterial?.diffuse.contents = self.context.createCGImage(textureImage,
                                                                                       from: textureImage.extent)
        boxNode.geometry?.firstMaterial?.diffuse.wrapS = .mirror
        boxNode.geometry?.firstMaterial?.diffuse.wrapT = .mirror

        // update the UIKit overlays
        // this shows the frame buffer image
        DispatchQueue.main.async {

            // update screen view
            // this is the red square indicating where the texture
            // is being read from on the screen display
            let frame = self.view.convert(screenRect, from: self.sceneView)
            self.screenView.frame = frame

            // buffer image to image view
            let image = UIImage(ciImage: bufferImage)
            self.imageView.image = image
            let ratio = image.size.height / image.size.width
            self.imageViewHeightConstraint.constant = ratio * self.imageViewWidthConstraint.constant

            // image to view
            // this is the red square indicating where the texture
            // is being read from on the buffer image
            let viewToImageRatio = self.imageView.bounds.size.width / image.size.width
            var viewFrame = imageRect
            viewFrame.origin.x *= viewToImageRatio
            viewFrame.origin.y *= viewToImageRatio
            viewFrame.size.width *= viewToImageRatio
            viewFrame.size.height *= viewToImageRatio
            self.textureView.frame = viewFrame
        }
    }

    // MARK: Unused code

    // image to texture
    // coordinates from absolute into percentages i.e. 0 to 1
//    var textureRect = CGRect.zero
//    textureRect.origin.x = imageRect.origin.x / CGFloat(bufferWidth)
//    textureRect.origin.y = imageRect.origin.y / CGFloat(bufferHeight)
//    textureRect.size.width = imageRect.size.width / CGFloat(bufferWidth)
//    textureRect.size.height = imageRect.size.height / CGFloat(bufferHeight)

    // TODO transform utility
    // texture rect to texture coordinates
//    var textureTransform = SCNMatrix4Identity
//    let textureScaleX = Float(textureRect.size.width)
//    let textureScaleY = Float(textureRect.size.height)
//    textureTransform = SCNMatrix4Scale(textureTransform, textureScaleX, textureScaleY, 1.0)
//    let textureTranslateX = Float(textureRect.origin.x)
//    let textureTranslateY = Float(textureRect.origin.y)
//    textureTransform = SCNMatrix4Translate(textureTransform, textureTranslateX, textureTranslateY, 0)

//        boxNode.geometry?.firstMaterial?.diffuse.contentsTransform = textureTransform
}

// MARK:-

extension SCNVector3 {

    static func distanceFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> Float {
        let x0 = vector1.x
        let x1 = vector2.x
        let y0 = vector1.y
        let y1 = vector2.y
        let z0 = vector1.z
        let z1 = vector2.z

        return sqrtf(powf(x1-x0, 2) + powf(y1-y0, 2) + powf(z1-z0, 2))
    }
}

// MARK:-

fileprivate extension Amount {

    var boxImage: UIImage? {
        switch self {
            case .full: return UIImage(named: "Box-full")
            case .some: return UIImage(named: "Box-some")
            default: return UIImage(named: "Box-none")
        }
    }

    var faceImage: UIImage? {
        switch self {
            case .full: return UIImage(named: "Face-full")
            case .some: return UIImage(named: "Face-some")
            default: return UIImage(named: "Face-none")
        }
    }

    var screenImage: UIImage? {
        switch self {
            case .full: return UIImage(named: "Screen-full")
            case .some: return UIImage(named: "Screen-some")
            default: return UIImage(named: "Screen-none")
        }
    }

    var pixellateImage: UIImage? {
        switch self {
            case .full: return UIImage(named: "Pixellate-full")
            case .some: return UIImage(named: "Pixellate-some")
            default: return UIImage(named: "Pixellate-none")
        }
    }
}
