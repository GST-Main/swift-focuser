//
//  File.swift
//  
//
//  Created by Augustinas Malinauskas on 01/09/2021.
//

import SwiftUI
import Introspect

class TextFieldObserver: NSObject, UITextFieldDelegate {
    var onReturnTap: () -> () = {}
    weak var forwardToDelegate: UITextFieldDelegate?
    
    @available(iOS 2.0, *)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturnTap()
        return forwardToDelegate?.textFieldShouldReturn?(textField) ?? true
    }
}

public struct FocusModifier<Value: FocusStateCompliant & Hashable>: ViewModifier {
    @Binding var focusedField: Value?
    var equals: Value
    @State var observer = TextFieldObserver()
    
    public func body(content: Content) -> some View {
        content
            .introspectTextField { tf in
                if !(tf.delegate is TextFieldObserver) {
                    observer.forwardToDelegate = tf.delegate
                    tf.delegate = observer
                }
                
                /// when user taps return we navigate to next responder
                observer.onReturnTap = {
                    focusedField = focusedField?.next ?? Value.last
                }

                /// to show kayboard with `next` or `return`
                if equals.hashValue == Value.last.hashValue {
                    tf.returnKeyType = .done
                } else {
                    tf.returnKeyType = .next
                }
                
                if focusedField == equals {
                    tf.becomeFirstResponder()
                }
            }
            .simultaneousGesture(TapGesture().onEnded {
              focusedField = equals
            })
    }
}
