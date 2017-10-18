//
//  Mapper.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 17/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import Foundation

class Mapper<Input, Result> {
    public var input: [ Input ] = []
    public var output: [ Result ] = []
    
    func provideImpl() -> (Input) -> Result {
        func impl(_ payload: Input) -> Result {
            input.append(payload)
            return output.remove(at: 0)
        }
        return impl
    }
}
