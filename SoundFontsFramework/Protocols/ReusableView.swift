// Copyright © 2019 Brad Howes. All rights reserved.

import UIKit

/**
 Protocol for UIView "cell" classes that will be recycled and used over and over again to render content in a
 container such as UICollectionView.
 */
public protocol ReusableView: class {

    /// Obtain the name of the identifier for this class
    static var reuseIdentifier: String { get }
}

public extension ReusableView where Self: UIView {

    /// Default implementation of the reuseIdentifier that uses the name of the class
    static var reuseIdentifier: String { return NSStringFromClass(self).components(separatedBy: ".").last! }
}
