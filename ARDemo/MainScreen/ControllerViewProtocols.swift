//
//  Protocols.swift
//  ARDemo
//
//  Created by Ilgiz Fazlyev on 13.10.2020.
//

import Foundation
import ARKit

protocol ViewModelControllerProtocol: class {
    
    var delegate: ViewControllerDelegate? { get }
    func setupARView(with sceneView: ARSCNView)
    func pauseAR()
    func resetAR(_ autoScaleMode: Bool)
    func tap(_ gesture: UITapGestureRecognizer)
    func pan(_ gesture: UIPanGestureRecognizer)
    func pinch(_ gesture: UIPinchGestureRecognizer)
    func rotation(_ gesture: UIRotationGestureRecognizer)
    
}

protocol ViewControllerDelegate: class {
    
    func infoMessage(message: String?)
    func errorMessage(message: String?)
    
}
