//
//  Reducer.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 18/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import Foundation

class Reducer<Input, Accumulator> {
    public var input: [ Input ] = []
    public var accumulators: [ Accumulator ] = []
    public var output: [ Accumulator ] = []
    
    func provideImpl() -> (Input, Accumulator) -> Accumulator {
        func impl(_ payload: Input, _ accumulator: Accumulator) -> Accumulator {
            input.append(payload)
            accumulators.append(accumulator)
            return output.remove(at: 0)
        }
        return impl
    }
}
