//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


// MARK:- CompletionWrapper
public struct CompletionWrapper {
    
    var executionQueue:OperationQueue? = OperationQueue.current
    var methodCallback:MeteorMethodCallback?
    var connectedCallback:MeteorConnectedCallback?
    var callback:MeteorCallback?
    
    init(methodCallback:@escaping MeteorMethodCallback) {
        self.methodCallback = methodCallback
    }
    
    init(connectedCallback:@escaping MeteorConnectedCallback) {
        self.connectedCallback = connectedCallback
    }
    
    init(callback:@escaping MeteorCallback) {
        self.callback = callback
    }
    
    func execute(_ result:Any?, error:MeteorError?) {
        
        if let callback = methodCallback {
            if let queue = executionQueue {
                queue.addOperation() {
                    callback(result, error)
                }
            } else {
                OperationQueue.main.addOperation() {
                    callback(result, error)
                }
            }
        }
    }
    
    func execute(_ session:String) {
        
        if let callback = connectedCallback {
            if let queue = executionQueue {
                queue.addOperation() {
                    callback(session)
                }
            } else {
                OperationQueue.main.addOperation() {
                    callback(session)
                }
            }
        }
    }
    
    func execute() {
        
        if let callback = self.callback {
            if let queue = executionQueue {
                queue.addOperation() {
                    callback()
                }
            } else {
                OperationQueue.main.addOperation() {
                    callback()
                }
            }
        }
    }
    
}






