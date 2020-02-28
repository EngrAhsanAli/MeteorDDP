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

import Foundation

func debounce( _ delay:TimeInterval, queue:DispatchQueue, action: @escaping (()->()) ) -> ()->() {
    
    var lastFireTime = DispatchTime(uptimeNanoseconds: 0)
    let dispatchDelay = Int64(delay * Double(NSEC_PER_SEC))
    
    return {
        lastFireTime = DispatchTime.now() + Double(0) / Double(NSEC_PER_SEC)
        queue.asyncAfter(
            deadline: DispatchTime.now() + Double(dispatchDelay) / Double(NSEC_PER_SEC)) {
                let now = DispatchTime.now() + Double(0) / Double(NSEC_PER_SEC)
                let when = lastFireTime + Double(dispatchDelay) / Double(NSEC_PER_SEC)
                if now >= when {
                    action()
                }
        }
    }
}

func randomBase64String(_ n: Int = 20) -> String {
    
    var string = ""
    let BASE64_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"
    
    for _ in 1...n {
        let r = arc4random() % UInt32(BASE64_CHARS.count)
        let index = BASE64_CHARS.index(BASE64_CHARS.startIndex, offsetBy: Int(r))
        let c = BASE64_CHARS[index]
        string += String(c)
    }
    
    return string
}
