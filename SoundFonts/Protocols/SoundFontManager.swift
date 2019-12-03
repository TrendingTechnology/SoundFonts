// Copyright © 2019 Brad Howes. All rights reserved.

import UIKit

protocol SoundFontEditor {

    func createEditSwipeAction(at cell: FontCell, with soundFont: SoundFont) -> UIContextualAction
    func createDeleteSwipeAction(at cell: FontCell, with soundFont: SoundFont) -> UIContextualAction
}
