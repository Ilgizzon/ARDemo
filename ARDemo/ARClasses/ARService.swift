//
//  ARService.swift
//  ARDemo
//
//  Created by Ilgiz Fazlyev on 12.10.2020.
//

import ARKit
import SceneKit
class ARService: NSObject, ARSCNViewDelegate, ARSessionDelegate {
    
    private var sceneView: ARSCNView!
    
    /// The virtual object that the user interacts with in the scene.
    private var virtualObject: SCNNode?
    
    /// Place environment probes automatically.
    private var environmentTexturingMode: ARWorldTrackingConfiguration.EnvironmentTexturing = .automatic
    
    
    /// The latest screen touch position when a pan gesture is active
    private var lastPanTouchPosition: CGPoint?
    private var autoScale: Bool = true
    
    private var infoCallback: ((String?) -> Void)?
    private var errorCallback: ((String?) -> Void)?
    private var modelOnScene = false
    init(arSceneView: ARSCNView)
    {
        super.init()
        sceneView = arSceneView
        sceneView.delegate = self
        sceneView.session.delegate = self
        runSession()
        
    }
    /// - Tag: RunARSession
    private func runSession(){
        // Prevent the screen from dimming to avoid interrupting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true

        // Start the AR session with automatic environment texturing.
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        sceneView.session.run(configuration)
    }
    
    /// - Tag: PauseARSession
    func pauseSession(){
        sceneView.session.pause()
    }
    
    func setVirtualObject(object: SCNNode){
        virtualObject = object
        modelOnScene = false
        sceneView.scene.rootNode.childNodes.forEach{
            $0.removeFromParentNode()
        }
    }
    
    func subscribeErrors(errors: ((String?) -> Void)?){
        self.errorCallback = errors
    }
    
    func subscribeInfoMessages(messages: ((String?) -> Void)?){
        self.infoCallback = messages
    }

    /// Runs the session with a new AR configuration to change modes or reset the experience.
    func resetTracking(autoScaleMode: Bool = true) {
        autoScale = autoScaleMode
        sceneView.scene.rootNode.childNodes.forEach{
            $0.removeFromParentNode()
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = environmentTexturingMode
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        modelOnScene = false
    }
    

    
    // MARK: - ARSessionObserver
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        guard let _ = session.currentFrame else { fatalError("ARSession should have an ARFrame") }
        updateSessionInfo(trackingState: camera.trackingState)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        errorCallback?(errorMessage)
    }
    
    // MARK: ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        updateSessionInfo(trackingState: frame.camera.trackingState)
    }
    
    // MARK: - Gesture Recognizers
    

    
    func pinch(_ gesture: UIPinchGestureRecognizer) {
        
    }
    
    func pan(_ gesture: UIPanGestureRecognizer) {
        guard let object = virtualObject else { return }
        
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: sceneView)
            
            let previousPosition = lastPanTouchPosition ?? CGPoint(sceneView.projectPoint(object.position))
            // Calculate the new touch position
            let currentPosition = CGPoint(x: previousPosition.x + translation.x, y: previousPosition.y + translation.y)
            if let hitTestResult = sceneView.smartHitTest(currentPosition) {
                let result = sceneView.session.raycast(hitTestResult)
                guard let transition = result.first?.worldTransform.translation else {
                    return
                }
                object.simdPosition = transition
            }
            lastPanTouchPosition = currentPosition
            // reset the gesture's translation
            gesture.setTranslation(.zero, in: sceneView)
        default:
            // Clear the current position tracking.
            lastPanTouchPosition = nil
        }
    }
    
    func rotation(_ gesture: UIRotationGestureRecognizer) {
     
    }
    
    func tap(_ gesture: UITapGestureRecognizer?){
        guard let object = virtualObject, let camera = sceneView.session.currentFrame?.camera, let strongGesture = gesture, case .normal = camera.trackingState else { return }
        let touchLocation = strongGesture.location(in: sceneView)
        if modelOnScene {
            guard let hitTestResult = sceneView.smartHitTest(touchLocation), let translation = sceneView.session.raycast(hitTestResult).first?.worldTransform.translation else {
                return
            }
            object.simdPosition = translation
        } else {
            self.place(object, basedOn: touchLocation)
        }
        
    }
    
    func place(_ object: SCNNode, basedOn location: CGPoint) {
        guard let hitTestResult = sceneView.smartHitTest(location)
            else { return }
        sceneView.scene.rootNode.addChildNode(object)
        
        let result = sceneView.session.raycast(hitTestResult)
        guard let transition = result.first?.worldTransform.translation else {
            return
        }
        object.simdPosition = transition
        
        
        guard let frame = sceneView.session.currentFrame else { return }
        updateSessionInfo(trackingState: frame.camera.trackingState)
        if autoScale {
            setAutoScaleAndPosition(object: object, pointOfView: sceneView.pointOfView)
        }
    }
    
    private func setAutoScaleAndPosition(object: SCNNode,
                                  pointOfView: SCNNode?
    ) {

        
        let boundingBox = object.boundingBox
        
        
        let xSize: Float = abs( boundingBox.max.x - boundingBox.min.x )
        let ySize: Float = abs( boundingBox.max.y - boundingBox.min.y )
        let zSize: Float = abs( boundingBox.max.z - boundingBox.min.z )

        var scale: Float = 0

        
        // ok, we need to automatically resize, this is an AR character:
        let objectSize: Float = max( xSize, zSize, ySize )
        let desiredSize = self.estimateDesiredSize( object: object,
                                                    camera: pointOfView
        )
        scale = desiredSize/objectSize
        object.scale = SCNVector3( scale, scale, scale )
      
    }
    
    func estimateDesiredSize( object: SCNNode,
                              camera: SCNNode?
    ) -> Float {
        
        let modelPos  = object.worldPosition
        guard let cameraPos = camera?.worldPosition else { return 0.6 } // set desiredSize = 60cm
        
        let dx: Float = modelPos.x - cameraPos.x
        let dy: Float = modelPos.y - cameraPos.y
        let dz: Float = modelPos.z - cameraPos.z
        
        let distance: Float = sqrtf( pow(dx,2) + pow(dy,2) + pow(dz,2) )
        let desiredSize: Float = distance / 4

        return desiredSize > 10 ? 10 : desiredSize // should not be more than 10m
    }
    
    /// Provide feedback on the state of the AR experience.
    private func updateSessionInfo( trackingState: ARCamera.TrackingState) {
        let message: String?
        
        switch trackingState {
        case .notAvailable:
            message = "Tracking Unavailable"
        case .limited(.excessiveMotion):
            message = "Tracking Limited\nExcessive motion - Try slowing down your movement, or reset the session."
        case .limited(.insufficientFeatures):
            message = "Tracking Limited\nLow detail - Try pointing at a flat surface, or reset the session."
        case .limited(.initializing):
            message = "Initializing"
        case .limited(.relocalizing):
            message = "Recovering from interruption"
        case .normal where modelOnScene == false:
            message = "Tap to place a virtual object, then tap or drag to move it or pinch to scale it or rotate it."
            
        default:
            message = nil
        }
        infoCallback?(message)
    }
    
    deinit {
        sceneView = nil
        infoCallback = nil
        errorCallback = nil
    }
}
