//
//  ARService.swift
//  ARDemo
//
//  Created by Ilgiz Fazlyev on 12.10.2020.
//

import ARKit
import SceneKit
class ARService: NSObject, ARSCNViewDelegate, ARSessionDelegate {
    struct ManualProbe {
        // An environment probe for shading the virtual object.
        var objectProbeAnchor: AREnvironmentProbeAnchor?
        // A fallback environment probe encompassing the whole scene.
        var sceneProbeAnchor: AREnvironmentProbeAnchor?
        // Indicates whether manually placed probes need updating.
        var requiresRefresh: Bool = true
        // Tracks timing of manual probe updates to prevent updating too frequently.
        var lastUpdateTime: TimeInterval = 0
    }
    
    var sceneView: ARSCNView!
    
    
    // MARK: - ARKit Configuration Properties
    
    // Model of shiny sphere that is added to the scene
    var virtualObjectModel: SCNNode = {
        guard let sceneURL = Bundle.main.url(forResource: "fender_stratocaster", withExtension: "usdz", subdirectory: "Models.scnassets/sphere"),
            let referenceNode = SCNReferenceNode(url: sceneURL) else {
                fatalError("can't load virtual object")
        }
        referenceNode.load()
        
        return referenceNode
    }()
    
    // MARK: - Environment Texturing Configuration
    
    /// The virtual object that the user interacts with in the scene.
    var virtualObject: SCNNode?
    /// Object to manage the manual environment probe anchor and its state
    var manualProbe: ManualProbe?
    
    /// Place environment probes manually or allow ARKit to place them automatically.
    var environmentTexturingMode: ARWorldTrackingConfiguration.EnvironmentTexturing = .automatic {
        didSet {
            switch environmentTexturingMode {
            case .manual:
                manualProbe = ManualProbe()
            default:
                manualProbe = nil
            }
        }
    }
    
    /// Indicates whether ARKit has provided an environment texture.
    var isEnvironmentTextureAvailable = false
    
    /// The latest screen touch position when a pan gesture is active
    var lastPanTouchPosition: CGPoint?
    var autoScale: Bool = true
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
    
    func tap(_ gesture: UITapGestureRecognizer){
        
    }
    
    deinit {
        sceneView = nil
    }
}
