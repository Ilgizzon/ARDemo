//
//  StorageManager.swift
//  ARDemo
//
//  Created by Ilgiz Fazlyev on 13.10.2020.
//

import Foundation
import ARKit
class StorageManager {
    
    public static let shared = StorageManager()
    /// Loading model
    /// - Parameters:
    ///     - modelName: full name with extension
    ///     - completion: returns a virtual object if the load was successful otherwise returns an error
    func load(
        modelName: String,
        completion: @escaping (Result<SCNNode, Error>) -> Void
    ){
        guard let parsedName = parseName(modelName: modelName) else {
            
            let error = NSError(
                domain: "wrong model name",
                code: 0, userInfo: nil
            )
            completion(.failure(error))
            return
        }
        
        guard let sceneURL = Bundle.main.url(forResource: parsedName.name,
                                             withExtension: parsedName.extension,
                                             subdirectory: "art.scnassets"
        ),
        let referenceNode = SCNReferenceNode(url: sceneURL) else {
            
            let error = NSError(
                domain: "can't load virtual object",
                code: 0,
                userInfo: nil
            )
            completion(.failure(error))
            return
        }
        referenceNode.load()
        completion(.success(referenceNode))
    }
    
    // MARK: Parsing name and returns the name and extension separately
    private func parseName(modelName: String) ->   (
                                                    name: String,
                                                    extension: String
                                                    )? {
        
        let separate = modelName.components(separatedBy: ".")
        if separate.count == 1 {
            return nil
        }
        guard let name = modelName.components(
                separatedBy: ".\(separate.last ?? "")"
        ).first,
              let extensionModel = separate.last else {
            
            return nil
        }
        
        return (name, extensionModel)
    }
}
