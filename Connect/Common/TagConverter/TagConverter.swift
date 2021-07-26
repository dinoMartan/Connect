//
//  TagConverter.swift
//  Connect
//
//  Created by Dino Martan on 26/07/2021.
//

import Foundation
import WSTagsField

final class TagConverter {
    
    //MARK: - Public properties
    
    static let shared = TagConverter()
    
    //MARK: - Public methods
    
    func stringArrayToWSTagArray(stringArray: [String]?) -> [WSTag] {
        var wsTagArray: [WSTag] = []
        if stringArray == nil { return wsTagArray }

        for string in stringArray! {
            let wsTag = WSTag(string)
            wsTagArray.append(wsTag)
        }
        
        return wsTagArray
    }
    
}
