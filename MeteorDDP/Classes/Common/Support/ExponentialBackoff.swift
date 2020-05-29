//
//  ExponentialBackoff.swift
//  MeteorDDP
//
//  Created by engrahsanali on 2020/04/17.
//  Copyright (c) 2020 engrahsanali. All rights reserved.
//
/*
 
 Copyright (c) 2020 Muhammad Ahsan Ali, AA-Creations
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
*/

// MARK:- 🚀 MeteorDDP ExponentialBackoff - Retry connection requests to the server. The retries exponentially increase the waiting time up to a certain threshold. The idea is that if the server is down temporarily, it is not overwhelmed with requests hitting at the same time when it comes back up.
class ExponentialBackoff {
    
    //Cached original interval time
    fileprivate var _retryInterval: Double = 0
    fileprivate var retryInterval: Double
    fileprivate var waitInterval: Double
    fileprivate var multiplier: Double
    
    /// Init with the configurations of ExponentialBackoff
    /// - Parameters:
    ///   - retryInterval: retryInterval
    ///   - maxWaitInterval: maxWaitInterval
    ///   - multiplier: multiplier
    init(retryInterval:Double = 0.01, maxWaitInterval:Double = 5, multiplier:Double = 1.5){
        
        self.retryInterval = retryInterval
        self._retryInterval = retryInterval
        self.waitInterval = maxWaitInterval
        self.multiplier = multiplier
    }
    
    /// Perform a closure with increasing exponential delay time up to a max wait interval
    /// - Parameter closure: closure
    func createBackoff(_ closure:@escaping ()->()) {
        
        let previousRetryInterval = self.retryInterval
        let newRetryInterval = min(previousRetryInterval * multiplier,waitInterval)
        
        self.retryInterval = previousRetryInterval < waitInterval ? newRetryInterval: waitInterval

        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(self.retryInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    /// Sets the backoff
    /// - Parameters:
    ///   - retryInterval: retryInterval
    ///   - maxWaitInterval: maxWaitInterval
    ///   - multiplier: multiplier
    func setBackoff(_ retryInterval:Double, maxWaitInterval:Double, multiplier:Double) {
        
        self.retryInterval = retryInterval
        self._retryInterval = retryInterval
        self.waitInterval = maxWaitInterval
        self.multiplier = multiplier
    }
    
    /// Reset backoff to orignal time
    func reset() {
        retryInterval = _retryInterval
    }
    
}


    
