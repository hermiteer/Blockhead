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

    // MARK: Filters

    private let context = CIContext()
    private let pixellateFilter = CIFilter(name: "CIPixellate")!
    private lazy var filter: CIFilter? = nil

    // MARK: Scene (not SKScene)

    var scene = Scene() {
        didSet {
            self.applyCurrentScene()
        }
    }

    private func applyCurrentScene() {

        // apply main thread scene changes
        self.screenView.alpha = self.scene.screenOpacity.floatValue
        self.screenView.isHidden = self.scene.hudViewIsHidden
        self.hudView.subviews.forEach { $0.isHidden = self.scene.hudViewIsHidden }
        self.sceneView.showsStatistics = !self.scene.hudViewIsHidden

        // apply session queue changes
        self.sceneView.session.delegateQueue?.async {

            // node opacity
            self.boxNode?.opacity = self.scene.boxOpacity.floatValue
            self.faceNode?.opacity = self.scene.faceOpacity.floatValue

            // pixellate amount
            var value = 0.0
            switch self.scene.pixellateAmount {
                case .full: value = 32.0; break
                case .some: value = 16.0; break
                default: value = 0
            }
            self.pixellateFilter.setValue(value, forKey: kCIInputScaleKey)
            self.filter = self.scene.pixellateAmount == .none ? nil : self.pixellateFilter

            // light amount
            switch self.scene.lights {
                case .full: self.lightNode?.isHidden = false
                case .some: self.lightNode?.isHidden = false
                case .none: self.lightNode?.isHidden = true
            }

            // texture image
            if let image = self.scene.textureImage {
                self.textureCIImage = CIImage(cgImage: image)
                self.textureCIRect = CGRect(x: 0, y: 0, width: image.width, height: image.height)
            }
        }
    }

    // CoreImage texture and the extent rectangle
    // note that these are use for both buffer texture
    // and the user specified CGImage textureImage
    private var textureCIImage: CIImage?
    private var textureCIRect = CGRect.zero

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure scene view
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = false
        sceneView.automaticallyUpdatesLighting = false
        sceneView.showsStatistics = true

        // configure scene view session
        sceneView.session.delegateQueue = DispatchQueue(label: "delegate",
                                                        qos: .userInteractive,
                                                        attributes: .concurrent,
                                                        autoreleaseFrequency: .workItem,
                                                        target: nil)
        
        // Create a new scene
        let scene = SCNScene()
        scene.physicsWorld.gravity = SCNVector3(0, 0, 0)
        
        // Set the scene to the view
        sceneView.scene = scene

        // initial values
        self.imageView.addSubview(self.textureView)

        // gestures
        let singleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(hudViewSingleTap(gesture:)))
        self.hudView.addGestureRecognizer(singleTap)

        // scenes
        Scenes.shared.isSwitchingScenes = true
        Scenes.shared.controller = self
        self.applyCurrentScene()
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
        configuration.isLightEstimationEnabled = true

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // MARK: Actions

    @IBAction
    func boxButtonTouchUpInside(button: UIButton) {
        let opacity = self.scene.boxOpacity.next
        self.scene.boxOpacity = opacity
        button.setImage(opacity.boxImage, for: .normal)
        self.applyCurrentScene()
    }

    @IBAction
    func faceButtonTouchUpInside(button: UIButton) {
        let opacity = self.scene.faceOpacity.next
        self.scene.faceOpacity = opacity
        button.setImage(opacity.faceImage, for: .normal)
        self.applyCurrentScene()
    }

    @IBAction
    func screenButtonTouchUpInside(button: UIButton) {
        let opacity = self.scene.screenOpacity.next
        self.scene.screenOpacity = opacity
        button.setImage(opacity.screenImage, for: .normal)
        self.applyCurrentScene()
    }

    @IBAction
    func pixellateButtonTouchUpInside(button: UIButton) {
        let opacity = self.scene.pixellateAmount.next
        self.scene.pixellateAmount = opacity
        button.setImage(opacity.pixellateImage, for: .normal)
        self.applyCurrentScene()
    }

    @IBAction
    func lightsButtonTouchUpInside(button: UIButton) {
        let amount = self.scene.lights.next
        self.scene.lights = amount
        button.setImage(amount.lightsImage, for: .normal)
        self.applyCurrentScene()
    }

    @objc func hudViewSingleTap(gesture: UITapGestureRecognizer) {
        self.scene.hudViewIsHidden = !self.scene.hudViewIsHidden
        self.applyCurrentScene()
    }

    // MARK: ARSCNViewDelegate

    private var faceNode: SCNNode?
    private var boxNode: SCNNode?
    private var lightNode: SCNNode?

    private var boxNodePosition = SCNVector3Zero
    private var boxNodeRotation = SCNVector4Zero

    private var boxNodeForce: [SCNVector3] = []
    private var boxNodeTorque: [SCNVector4] = []

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {

        // face node
        guard let _ = anchor as? ARFaceAnchor else { return nil }
        guard let device = self.sceneView.device else { return nil }
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let faceNode = SCNNode(geometry: faceGeometry)
        faceNode.opacity = self.scene.faceOpacity.floatValue
        self.faceNode = faceNode

        // box node
        let box = SCNBox(width: 0.22, height: 0.22, length: 0.22, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.75)
        box.firstMaterial?.fillMode = .fill
        let boxNode = SCNNode(geometry: box)
        boxNode.castsShadow = true
        boxNode.opacity = self.scene.boxOpacity.floatValue
        self.sceneView.scene.rootNode.addChildNode(boxNode)
        self.boxNode = boxNode

        // light node
        let light = SCNLight()
        light.castsShadow = true
        light.shadowColor = UIColor.black.withAlphaComponent(0.2)
        light.shadowMode = .deferred
        light.type = .directional
        let lightNode = SCNNode()
        lightNode.light = light
        self.sceneView.pointOfView?.addChildNode(lightNode)
        self.lightNode = lightNode

        // wall node
        let plane = SCNPlane(width: 10.0, height: 10.0)
        plane.firstMaterial?.colorBufferWriteMask = SCNColorMask.alpha
        let planeNode = SCNNode(geometry: plane)
        planeNode.castsShadow = true
        planeNode.position = SCNVector3(0, 0, -2.0)
        planeNode.physicsBody = SCNPhysicsBody.static()
        self.sceneView.pointOfView?.addChildNode(planeNode)

        // done
        self.update(boxNode, with: faceNode)
        return faceNode
    }

    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {

        // ensure face anchor and box node
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        guard faceAnchor.isTracked == false else { return }
        guard let node = self.boxNode else { return }

        // create physics
        guard node.physicsBody == nil else { return }
        let body = SCNPhysicsBody.dynamic()
        body.angularDamping = 0.5
        body.damping = 0.5
        body.velocityFactor = SCNVector3(5.0, 5.0, 5.0)
        node.physicsBody = body

        // apply impluses
        body.applyForce(self.boxNodeForce.sum(), asImpulse: true)
        body.applyTorque(self.boxNodeTorque.sum(), asImpulse: true)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

        // update face geometry if tracked
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        guard faceAnchor.isTracked else { return }
        guard let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        faceGeometry.update(from: faceAnchor.geometry)

        // update box node
        // stop any physics
        guard let boxNode = self.boxNode else { return }
        boxNode.physicsBody?.clearAllForces()
        boxNode.physicsBody = nil
        self.update(boxNode, with: node)
    }

    private func update(_ boxNode: SCNNode, with faceNode: SCNNode) {

        // increment force
        self.boxNodeForce.add(boxNode.position - self.boxNodePosition)
        self.boxNodePosition = boxNode.position

        // increment torque
        self.boxNodeTorque.add(boxNode.rotation - self.boxNodeRotation)
        self.boxNodeRotation = boxNode.rotation

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
        // note that clamping is similar to cropping and requires
        // using the texture rectangle in buffer coordinates to
        // correctly create a cropped image later
        var textureImage = bufferImage.clamped(to: textureRect)

        // change the texture if one was specified
        if let image = self.textureCIImage {
            textureImage = image
            textureRect = self.textureCIRect
        }

        // apply filter if necessary
        // note that it was tempting to try and use texture magnification
        // to approximate the pixellation effect, but it proved not as
        // visibly consistent due to the use of the CoreImage scale filter
        // the texture will always be changing size so there is no way
        // to get an exact downscaled texture that won't "swim" as the
        // face changes proximity to the camera
        if let filter = self.filter {
            filter.setValue(textureImage, forKey: kCIInputImageKey)
            textureImage = filter.outputImage ?? textureImage
        }

        // apply texture and transform
        // note that the texture is clamped to the larger buffer
        // so the extent is the textureRect i.e. buffer coordinate space
        let contents = self.context.createCGImage(textureImage, from: textureRect)
        boxNode.geometry?.firstMaterial?.diffuse.contents = contents
        boxNode.geometry?.firstMaterial?.transparencyMode = .aOne

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

    var lightsImage: UIImage? {
        switch self {
            case .full: return UIImage(named: "Lights-full")
            case .some: return UIImage(named: "Lights-some")
            default: return UIImage(named: "Lights-none")
        }
    }
}
