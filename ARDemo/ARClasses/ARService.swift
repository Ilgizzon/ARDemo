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
    
    
    // MARK: - ARKit Configuration Properties
    

    
    // MARK: - Environment Texturing Configuration
    
    /// The virtual object that the user interacts with in the scene.
    private var virtualObject: SCNNode?
    
    /// Place environment probes automatically.
    private var environmentTexturingMode: ARWorldTrackingConfiguration.EnvironmentTexturing = .automatic
    
    
    /// Indicates whether ARKit has provided an environment texture.
    private var isEnvironmentTextureAvailable = false
    
    /// The latest screen touch position when a pan gesture is active
    private var lastPanTouchPosition: CGPoint?
    private var autoScale: Bool = true
    
    private var infoCallback: ((String?) -> Void)?
    private var errorCallback: ((String?) -> Void)?
    
    init(arSceneView: ARSCNView)
    {
        super.init()
        sceneView = arSceneView
        sceneView.delegate = self
        sceneView.session.delegate = self
        
    }
    /// - Tag: RunARSession
    func runSession(){
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
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

    }
    
    // MARK: - ARSessionObserver
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {

    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {

    }
    
    // MARK: ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {

    }
    
    // MARK: - Gesture Recognizers
    

    
    func pinch(_ gesture: UIPinchGestureRecognizer) {
        
    }
    
    func pan(_ gesture: UIPanGestureRecognizer) {
        
    }
    
    func rotation(_ gesture: UIRotationGestureRecognizer) {
     
    }
    
    func tap(_ gesture: UITapGestureRecognizer?){
        
    }
    
    deinit {
        sceneView = nil
        infoCallback = nil
        errorCallback = nil
    }
}
