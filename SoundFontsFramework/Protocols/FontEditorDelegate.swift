// Copyright © 2019 Brad Howes. All rights reserved.

import UIKit

/**
 Reason why the FontEditor view was dismissed by the user.
 */
public enum FontEditorDismissedReason {
    case cancel
    case done(index: Int, soundFont: SoundFont)
}

/**
 Protocol for the `SoundFontDetailController` delegate instance.
 */
public protocol FontEditorDelegate: NSObjectProtocol {
    /**
     Notification when the FontEditor is dismissed and editing of a particular SoundFont instance
     is over.
    
     - parameter reason: the reason for the dismisal
     */
    func dismissed(reason: FontEditorDismissedReason)
}
