//
//  KeyboardAdjuster.swift
//  Pods
//
//  Created by Daniel Loewenherz on 2/10/16.
//
//

import UIKit

public protocol KeyboardAdjusting {
    var keyboardAdjustmentConstraint: NSLayoutConstraint? { get set }
    var keyboardAdjustmentAnimated: Bool? { get set }
}

extension UIViewController {
    /**
     Activates keyboard adjustment for the calling view controller.

     - seealso: `activateKeyboardAdjustment(showBlock:hideBlock:)`
     - author: Daniel Loewenherz
     - copyright: ©2016 Lionheart Software LLC
     - date: February 18, 2016
     */
    public func activateKeyboardAdjustment() {
        activateKeyboardAdjustment(nil, hideBlock: nil)
    }

    /**
     Enable keyboard adjustment for the current view controller, providing optional closures to call when the keyboard appears and when it disappears.
     
     - parameter showBlock: (optional) a closure that's called when the keyboard appears
     - parameter hideBlock: (optional) a closure that's called when the keyboard disappears
     - author: Daniel Loewenherz
     - copyright: ©2016 Lionheart Software LLC
     - date: February 18, 2016
     */
    public func activateKeyboardAdjustment(showBlock: AnyObject?, hideBlock: AnyObject?) {
        if let conformingSelf = self as? KeyboardAdjusting {
            // Activate the bottom constraint.
            conformingSelf.keyboardAdjustmentConstraint?.active = true

            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: hideBlock)
            notificationCenter.addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: showBlock)

            if let viewA = conformingSelf.keyboardAdjustmentConstraint?.firstItem as? UIView,
                viewB = conformingSelf.keyboardAdjustmentConstraint?.secondItem as? UIView {
                    if viewB.subviews.contains(viewA) {
                        assertionFailure("Please reverse the order of arguments in your keyboard adjustment constraint.")
                    }
            }
        }
        else {
            print("You must define `keyboardAdjustmentConstraint` on your view controller to activate KeyboardAdjuster.")
        }
    }
    
    /**
     Call this in your `viewWillDisappear` method for your `UIViewController`. This method removes any active keyboard observers from your view controller.

     - author: Daniel Loewenherz
     - copyright: ©2016 Lionheart Software LLC
     - date: February 18, 2016
     */
    public func deactivateKeyboardAdjustment() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    }

    /**
     A private method called when the keyboard is about to be hidden.

     - parameter sender: An `NSNotification` containing a `Dictionary` with information regarding the keyboard appearance.
     - author: Daniel Loewenherz
     - copyright: ©2016 Lionheart Software LLC
     - date: February 18, 2016
     */
    func keyboardWillHide(sender: NSNotification) {
        guard let conformingSelf = self as? KeyboardAdjusting else {
            return
        }

        if let constraint = conformingSelf.keyboardAdjustmentConstraint {
            if let block = sender.object as? (() -> Void) {
                block()
            }
            


            if let userInfo = sender.userInfo as? [String: AnyObject],
                _curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int,
                curve = UIViewAnimationCurve(rawValue: _curve),
                duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
                animated = conformingSelf.keyboardAdjustmentAnimated {
                    var curveAnimationOption: UIViewAnimationOptions
                    switch curve {
                    case .EaseIn:
                        curveAnimationOption = .CurveEaseIn

                    case .EaseInOut:
                        curveAnimationOption = .CurveEaseInOut

                    case .EaseOut:
                        curveAnimationOption = .CurveEaseOut

                    case .Linear:
                        curveAnimationOption = .CurveLinear
                    }

                    constraint.constant = 0
                    if animated {
                        let animationOptions: UIViewAnimationOptions = [UIViewAnimationOptions.BeginFromCurrentState, curveAnimationOption]

                        UIView.animateWithDuration(duration, delay: 0, options: animationOptions, animations: {
                            self.view.layoutIfNeeded()
                            }, completion:nil)
                    }
                    else {
                        view.layoutIfNeeded()
                    }
            }
        }
    }
    /**
     A private method called after the keyboard is shown.
     
     - parameter sender: An `NSNotification` containing a `Dictionary` with information regarding the keyboard appearance.
     - author: Daniel Loewenherz
     - copyright: ©2016 Lionheart Software LLC
     - date: February 18, 2016
     */
    func keyboardDidShow(sender: NSNotification) {
        guard let conformingSelf = self as? KeyboardAdjusting else {
            return
        }

        if let constraint = conformingSelf.keyboardAdjustmentConstraint {
            if let block = sender.object as? (() -> Void) {
                block()
            }
            
            if let userInfo = sender.userInfo as? [String: AnyObject],
                value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                    let frame = value.CGRectValue()
                    let keyboardFrameInViewCoordinates = view.convertRect(frame, fromView: nil)

                    if let _curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int,
                        curve = UIViewAnimationCurve(rawValue: _curve),
                        duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
                        animated = conformingSelf.keyboardAdjustmentAnimated {
                            var curveAnimationOption: UIViewAnimationOptions
                            switch curve {
                            case .EaseIn:
                                curveAnimationOption = .CurveEaseIn
                                
                            case .EaseInOut:
                                curveAnimationOption = .CurveEaseInOut
                                
                            case .EaseOut:
                                curveAnimationOption = .CurveEaseOut
                                
                            case .Linear:
                                curveAnimationOption = .CurveLinear
                            }

                            constraint.constant = CGRectGetHeight(view.bounds) - keyboardFrameInViewCoordinates.origin.y
                            let animationOptions: UIViewAnimationOptions = [UIViewAnimationOptions.BeginFromCurrentState, curveAnimationOption]
                            if animated {
                                UIView.animateWithDuration(duration, delay: 0, options: animationOptions, animations: {
                                    self.view.layoutIfNeeded()
                                    }, completion: nil)
                            }
                            else {
                                view.layoutIfNeeded()
                            }
                    }
            }
        }
    }
}