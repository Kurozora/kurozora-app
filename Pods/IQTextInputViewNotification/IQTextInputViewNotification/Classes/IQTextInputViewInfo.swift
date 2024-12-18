//
//  IQTextInputViewInfo.swift
//  https://github.com/hackiftekhar/IQTextInputViewNotification
//  Copyright (c) 2013-24 Iftekhar Qurashi.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import IQKeyboardCore

@available(iOSApplicationExtension, unavailable)
@MainActor
public struct IQTextInputViewInfo: Equatable {

    nonisolated public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.textInputView == rhs.textInputView &&
        lhs.event == rhs.event
    }

    @MainActor
    @objc public enum Event: Int {
        case beginEditing
        case endEditing

        public var name: String {
            switch self {
            case .beginEditing:
                return "BeginEditing"
            case .endEditing:
                return "EndEditing"
            }
        }
    }

    public let event: Event

    public let textInputView: any IQTextInputView

    internal init?(notification: Notification, event: Event) {
        guard let view: any IQTextInputView = notification.object as? (any IQTextInputView) else {
            return nil
        }

        self.event = event
        textInputView = view
    }
}

// MARK: Deprecated
@available(iOSApplicationExtension, unavailable)
public extension IQTextInputViewInfo {

    @available(*, unavailable, renamed: "event")
    var name: Event { event }

    @available(*, unavailable, renamed: "textInputView")
    var textFieldView: any IQTextInputView { textInputView }
}

@available(*, unavailable, renamed: "IQTextInputViewInfo")
@MainActor
public struct IQTextFieldViewInfo: Equatable {}

@available(iOSApplicationExtension, unavailable)
@objcMembers public class IQTextInputViewInfoObjC: NSObject {
    private let wrappedValue: IQTextInputViewInfo

    public var event: IQTextInputViewInfo.Event { wrappedValue.event }

    public var textInputView: any IQTextInputView { wrappedValue.textInputView }

    init(wrappedValue: IQTextInputViewInfo){
        self.wrappedValue = wrappedValue
    }
}
