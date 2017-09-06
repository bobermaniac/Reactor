import Foundation

struct CompositeError: Error {
    public let errors: [ Error ]
    
    init() {
        errors = []
    }
    
    init(errors: [ Error ]) {
        self.errors = errors
    }
    
    func appending(_ error: Error) -> CompositeError {
        return CompositeError(errors: errors + [ error ])
    }
}
