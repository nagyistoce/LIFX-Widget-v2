//
//  Delay.swift
//  LiFX Widget
//
//  Created by Maxime de Chalendar on 18/07/2015.
//  Copyright (c) 2015 Maxime de Chalendar. All rights reserved.
//

import UIKit

typealias dispatch_cancelable_closure = (cancel : Bool) -> Void

func delay(time:NSTimeInterval, closure: ()->Void) ->  dispatch_cancelable_closure? {
    
    var retainedClosure: dispatch_block_t? = closure
    var cancelableClosure: dispatch_cancelable_closure?
    
    let delayedClosure: dispatch_cancelable_closure = { cancel in
        if retainedClosure != nil && !cancel {
            dispatch_async(dispatch_get_main_queue(), retainedClosure!);
        }
        retainedClosure = nil
        cancelableClosure = nil
    }
    
    cancelableClosure = delayedClosure
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        cancelableClosure?(cancel: false)
    }
    
    return cancelableClosure
}

func cancel_delay(closure:dispatch_cancelable_closure?) {
    closure?(cancel: true)
}
