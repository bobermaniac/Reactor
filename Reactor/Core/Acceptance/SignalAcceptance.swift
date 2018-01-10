import Foundation

struct SignalAcceptance<EmitterType: Emitting> where EmitterType.SignalType.PayloadType == Probe {
    init(emitterFactory: @escaping () -> EmitterType) {
        self.emitterFactory = emitterFactory
    }
    
    private let emitterFactory: () -> EmitterType
    
    func emitterPayloadImmediatelyTransferedToObserver() -> AcceptranceAssertion<Probes> {
        let emitter = emitterFactory()
        defer { finalize(emitter) }
        let collector = Collector<Probe>.attached(to: emitter)
        let probes = Probe.signals(count: 5)
        
        emitter.emit(probes)
        
        return specify(collector.pulses.takeLast(probes.count)).equals(to: probes)
            .because("Emitter payload should be immediatelly transfered to observers")
    }
    
    func allObserversSeeSimilarPayloadSequences() -> AcceptranceAssertion<Probes> {
        let emitter = emitterFactory()
        defer { finalize(emitter) }
        let firstCollector = Collector<Probe>.attached(to: emitter)
        let secondCollector = Collector<Probe>.attached(to: emitter)
        let probes = Probe.signals(count: 5)
        
        emitter.emit(probes)
        
        return specify(firstCollector.pulses).equals(to: secondCollector.pulses)
            .because("All observes should see similar payload sequences")
    }
    
    func observerDetachedAfterObsoletePulseEmitted() -> AcceptanceBoolAssertion {
        let emitter = emitterFactory()
        defer { finalize(emitter) }
        weak var collector = Collector<Probe>.attached(to: emitter)
        
        emitter.emit(Probe.obsolete)
        
        return specify(collector == nil).isTrue()
            .because("Observer should be detached after obsolete pulse emitted")
    }
    
    func observerDoesntReceiveAnySignalAfterObsoletePulseEmitted() -> AcceptranceAssertion<Probes> {
        let emitter = emitterFactory()
        defer { finalize(emitter) }
        let collector = Collector<Probe>.attached(to: emitter)
        let probes = Probe.signals(count: 5) + [ Probe.obsolete ]
        
        emitter.emit(probes)
        emitter.emit(Probe.signals(count: 5))
        
        return specify(collector.pulses.takeLast(probes.count)).equals(to: probes)
            .because("Observer should not receive any signal after obsolete pulse emitted")
    }
    
    func observerReceiveObsoletePulseOnAttachingIfApplicable() -> AcceptranceAssertion<Probe?> {
        let emitter = emitterFactory()
        defer { finalize(emitter) }
        emitter.emit(Probe.obsolete)
        
        let collector = Collector<Probe>.attached(to: emitter)
        
        return specify(collector.pulses.last).equals(to: Probe.obsolete)
            .because("Observer should receive obsolete pulse on attaching if it was emitted earlier")
    }
    
    func observationCancelingStopsReceivingEvent() -> AcceptranceAssertion<Probes> {
        let emitter = emitterFactory()
        defer { finalize(emitter) }
        let collector = Collector<Probe>()
        let subscription = collector.attach(to: emitter)
        let probes = Probe.signals(count: 5)
        
        emitter.emit(probes)
        subscription.cancel()
        emitter.emit(Probe.signals(count: 5))
        
        return specify(collector.pulses.takeLast(probes.count)).equals(to: probes)
            .because("Observation canceling should stop receiving events")
    }
    
    private func finalize(_ emitter: EmitterType) {
        emitter.emit(Probe.obsolete)
    }
}

// Copyright (c) 2017 Victor Bryksin <vbryksin@virtualmind.ru>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
