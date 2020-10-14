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
    private var lastTouchPosition: CGPoint?
    
    private var autoScale = true
    private var isRotating = false
    private var planeDetected = false
    private var currentAngleY: Float = 0
    
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

    /// Runs the session with a new AR configuration to change modes.
    func resetTracking(autoScaleMode: Bool = true, environmentMode: ARWorldTrackingConfiguration.EnvironmentTexturing = .automatic) {
        environmentTexturingMode = environmentMode
        autoScale = autoScaleMode
        sceneView.scene.rootNode.childNodes.forEach{
            $0.removeFromParentNode()
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = environmentTexturingMode == .automatic ? true: false
        configuration.environmentTexturing = environmentTexturingMode
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        modelOnScene = false
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        planeDetected = true
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planeDetected = false
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
        guard let object = virtualObject, gesture.state == .changed, let camera = sceneView.session.currentFrame?.camera, case .normal = camera.trackingState
            else { return }
        let newScale = object.simdScale * Float(gesture.scale)
        object.simdScale = newScale
        gesture.scale = 1.0
    }
    
    func pan(_ gesture: UIPanGestureRecognizer) {
        guard let object = virtualObject, !isRotating, let camera = sceneView.session.currentFrame?.camera, case .normal = camera.trackingState  else { return }
        
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: sceneView)
            
            let previousPosition = lastTouchPosition ?? CGPoint(sceneView.projectPoint(object.position))
            // Calculate the new touch position
            let currentPosition = CGPoint(x: previousPosition.x + translation.x, y: previousPosition.y + translation.y)
            
            
            getARRaycastResults(currentPosition: currentPosition) { optionalResult in
                guard let result = optionalResult else {
                    return
                }
                object.simdPosition = result.worldTransform.translation
            }

            lastTouchPosition = currentPosition
           
            // reset the gesture's translation
            gesture.setTranslation(.zero, in: sceneView)
        default:
            // Clear the current position tracking.
            lastTouchPosition = nil
        }
    }
    
    func rotation(_ gesture: UIRotationGestureRecognizer) {
        
        guard let object = virtualObject, let camera = sceneView.session.currentFrame?.camera, case .normal = camera.trackingState else { return }
        
        let rotation = Float(gesture.rotation)

        if gesture.state == .changed{
            isRotating = true
            object.eulerAngles.y = currentAngleY + rotation
        }

        if(gesture.state == .ended) {
            currentAngleY = object.eulerAngles.y
            isRotating = false
        }
    }
    
    func tap(_ gesture: UITapGestureRecognizer?){
        guard let object = virtualObject, let camera = sceneView.session.currentFrame?.camera, let strongGesture = gesture, case .normal = camera.trackingState else { return }
        
        let currentPosition = strongGesture.location(in: sceneView)

        if modelOnScene {
            getARRaycastResults(currentPosition: currentPosition) { optionalResult in
                guard let result = optionalResult else {
                    return
                }
                DispatchQueue.main.async {
                    object.simdPosition = result.worldTransform.translation
                }
            }

            
        } else {
            self.place(object, currentPosition: currentPosition)
        }
        
    }
    
    private func place(_ object: SCNNode, currentPosition: CGPoint) {

        if environmentTexturingMode != .automatic {
            sceneView.scene.enableEnvironmentMapWithIntensity(5, queue: DispatchQueue.main)
        }
        


        getARRaycastResults(currentPosition: currentPosition) { optionalResult in
            guard let result = optionalResult else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                if self.autoScale {
                    object.opacity = 0
                }
                self.sceneView.scene.rootNode.addChildNode(object)
                object.simdPosition = result.worldTransform.translation
            }
        }
        

        

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
        DispatchQueue.main.async {
            object.scale = SCNVector3( scale, scale, scale )
            object.opacity = 1
        }

      
    }
    
    private func estimateDesiredSize( object: SCNNode,
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
        case .normal where planeDetected == true:
            message = "Tap to place a virtual object, then tap or drag to move it or pinch to scale it or rotate it."
            
        default:
            message = "Trying to find the surface, please wait"
        }
        infoCallback?(message)
    }
    
    private func getARRaycastResults(currentPosition: CGPoint ,completion: @escaping (ARRaycastResult?) -> Void){

        if let hitTestResult = sceneView.smartHitTest(currentPosition){
            
            let result = self.sceneView.session.raycast(hitTestResult).first
            completion(result)
            
        } else {
            fatalError("ARRaycastQuery is nil")
        }
    }
    
    deinit {
        sceneView = nil
        infoCallback = nil
        errorCallback = nil
    }
}
