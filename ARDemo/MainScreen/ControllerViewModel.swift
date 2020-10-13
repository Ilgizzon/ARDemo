//
//  ViewModel.swift
//  ARDemo
//
//  Created by Ilgiz Fazlyev on 13.10.2020.
//

import Foundation
import ARKit

class ControllerViewModel: ViewModelControllerProtocol {
    
    weak var delegate: ViewControllerDelegate?
    var arService: ARService?
    var storageManager: StorageManager?
    
    init(with delegate: ViewControllerDelegate) {
        self.delegate = delegate
    }
    
    
    func setupARView(with sceneView: ARSCNView) {
        arService = ARService(arSceneView: sceneView)
    }
    
    func pauseAR() {
        arService?.pauseSession()
    }
    
    func resetAR(_ autoScaleMode: Bool) {
        arService?.resetTracking(autoScaleMode: autoScaleMode)
    }
    
    func tap(_ gesture: UITapGestureRecognizer) {
        arService?.tap(gesture)
    }
    
    func pan(_ gesture: UIPanGestureRecognizer) {
        arService?.pan(gesture)
    }
    
    func pinch(_ gesture: UIPinchGestureRecognizer) {
        arService?.pinch(gesture)
    }
    
    func rotation(_ gesture: UIRotationGestureRecognizer) {
        arService?.rotation(gesture)
    }
    
    deinit {
        storageManager = nil
        arService = nil
    }
}
