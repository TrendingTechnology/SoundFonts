// Copyright © 2018 Brad Howes. All rights reserved.

import UIKit
import os

/**
 Manages the view of Favorite items. Users can choose a Favorite by tapping it in order to apply the Favorite
 settings. The user may long-touch on a Favorite to move it around. Double-tapping on it will open the editor.
 */
public final class FavoritesViewController: UIViewController {
    private lazy var log = Logging.logger("FavsVC")

    //swiftlint:disable force_cast
    private let favoriteCell = FavoriteCell.nib.instantiate(withOwner: nil, options: nil)[0] as! FavoriteCell
    //swiftlint:enable force_cast

    @IBOutlet private var favoritesView: UICollectionView!
    @IBOutlet private var longPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet public var doubleTapGestureRecognizer: UITapGestureRecognizer!

    private var activePatchManager: ActivePatchManager!
    private var keyboard: Keyboard?
    private var favorites: Favorites!

    private var favoriteMover: FavoriteMover!

    private var swipeLeft = UISwipeGestureRecognizer()
    private var swipeRight = UISwipeGestureRecognizer()

    public override func viewDidLoad() {
        favoriteCell.translatesAutoresizingMaskIntoConstraints = false

        favoritesView.register(FavoriteCell.self)
        favoritesView.dataSource = self
        favoritesView.delegate = self

        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
        doubleTapGestureRecognizer.addTarget(self, action: #selector(handleTap))
        doubleTapGestureRecognizer.delaysTouchesBegan = true

        favoriteMover = FavoriteMover(view: favoritesView, lpgr: longPressGestureRecognizer)

        swipeLeft.direction = .left
        swipeLeft.numberOfTouchesRequired = 2
        view.addGestureRecognizer(swipeLeft)

        swipeRight.direction = .right
        swipeRight.numberOfTouchesRequired = 2
        view.addGestureRecognizer(swipeRight)

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8

        favoritesView.setCollectionViewLayout(layout, animated: false)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        favoritesView.reloadData()
    }
}

extension FavoritesViewController: ControllerConfiguration {

    public func establishConnections(_ router: ComponentContainer) {
        activePatchManager = router.activePatchManager
        favorites = router.favorites
        keyboard = router.keyboard

        activePatchManager.subscribe(self, notifier: activePatchChange)
        favorites.subscribe(self, notifier: favoritesChange)
    }

    private func activePatchChange(_ event: ActivePatchEvent) {
        os_log(.info, log: log, "activePatchChange")
        switch event {
        case let .active(old: old, new: new):
            if let favorite = favorites.getBy(soundFontPatch: old.soundFontPatch), favorite != new.favorite {
                os_log(.info, log: log, "updating previous favorite cell")
                updateCell(with: favorite)
            }

            if let favorite = new.favorite {
                os_log(.info, log: log, "updating new favorite cell")
                updateCell(with: favorite)
            }
        }
    }

    private func favoritesChange(_ event: FavoritesEvent) {
        os_log(.info, log: log, "favoritesChange")
        switch event {
        case let .added(index: index, favorite: favorite):
            os_log(.info, log: log, "added item %d", index)
            favoritesView.insertItems(at: [IndexPath(item: index, section: 0)])
            if favorite.soundFontPatch == activePatchManager.soundFontPatch {
                favoritesView.selectItem(at: indexPath(of: favorite), animated: false,
                                         scrollPosition: .centeredVertically)
                updateCell(with: favorite)
            }

        case let .selected(index: index, favorite: favorite):
            os_log(.info, log: log, "selected %d", index)
            activePatchManager.setActive(.favorite(favorite: favorite))

        case let .beginEdit(index: index, favorite: favorite, view: view):
            os_log(.info, log: log, "begin editing %d", index)
            edit(favorite: favorite, sender: view)

        case let .changed(index: index, favorite: favorite):
            os_log(.info, log: log, "changed %d", index)
            if let favorite = favorites.getBy(soundFontPatch: favorite.soundFontPatch) {
                updateCell(with: favorite)
            }

        case let .removed(index: index, favorite: _, bySwiping: _):
            os_log(.info, log: log, "removed %d", index)
            favoritesView.deleteItems(at: [IndexPath(item: index, section: 0)])

        case .removedAll:
            favoritesView.reloadData()
        }
    }
}

// MARK: - Editing

extension FavoritesViewController: SegueHandler {

    public enum SegueIdentifier: String {
        case favoriteEditor
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .favoriteEditor: beginEditFavorite(segue, sender: sender)
        }
    }

    private func beginEditFavorite(_ segue: UIStoryboardSegue, sender: Any?) {
        guard let nc = segue.destination as? UINavigationController,
            let vc = nc.topViewController as? FavoriteEditor,
            let (favorite, view) = sender as? (Favorite, UIView) else { return }
        vc.delegate = self
        vc.editFavorite(favorite, position: indexPath(of: favorite), currentLowestNote: keyboard?.lowestNote)
        if keyboard == nil {
            vc.modalPresentationStyle = .fullScreen
            nc.modalPresentationStyle = .fullScreen
        }
        nc.popoverPresentationController?.setSourceView(view)
    }

    /**
     Event handler for the double-tap gesture recognizer. We use this to begin editing a favorite.
     
     - parameter gr: the gesture recognizer that fired the event
     */
    @objc private func handleTap(_ gr: UITapGestureRecognizer) {
        let pos = gr.location(in: view)
        guard let indexPath = favoritesView.indexPathForItem(at: pos) else { return }
        let favorite = favorites.getBy(index: indexPath.item)
        guard let cell = favoritesView.cellForItem(at: indexPath) else { fatalError() }
        edit(favorite: favorite, sender: cell)
    }

    func edit(favorite: Favorite, sender: UIView) {
        performSegue(withIdentifier: .favoriteEditor, sender: (favorite, sender))
    }
}

// MARK: - FavoriteDetailControllerDelegate

extension FavoritesViewController: FavoriteEditorDelegate {

    public func dismissed(_ indexPath: IndexPath, reason: FavoriteEditorDismissedReason) {
        if case let .done(favorite) =  reason {
            favorites.update(index: indexPath.item, with: favorite)
            favoritesView.reloadItems(at: [indexPath])
            favoritesView.collectionViewLayout.invalidateLayout()
        }
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension FavoritesViewController: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        favorites.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
        UICollectionViewCell {
        limitWidth(cell: update(cell: collectionView.dequeueReusableCell(for: indexPath),
                                with: favorites.getBy(index: indexPath.row)))
    }
}

// MARK: - UICollectionViewDelegate

extension FavoritesViewController: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        favorites.selected(index: indexPath.row)
    }

    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        favorites.count > 1
    }

    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        favorites.move(from: sourceIndexPath.item, to: destinationIndexPath.item)
        collectionView.reloadItems(at: [sourceIndexPath, destinationIndexPath])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let favorite = favorites.getBy(index: indexPath.item)
        let cell = update(cell: favoriteCell, with: favorite)
        let size = cell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let constrainedSize = CGSize(width: min(size.width, collectionView.bounds.width), height: size.height)
        return constrainedSize
    }
}

// MARK: - FavoritesManager

extension FavoritesViewController: FavoritesViewManager {

    public func addTarget(_ event: UpperViewSwipingEvent, target: Any, action: Selector) {
        switch event {
        case .swipeLeft: swipeLeft.addTarget(target, action: action)
        case .swipeRight: swipeRight.addTarget(target, action: action)
        }
    }

    public func reload() {
        favoritesView.reloadData()
    }
}

// MARK: - Private

extension FavoritesViewController {

    private func indexPath(of favorite: Favorite) -> IndexPath {
        IndexPath(row: favorites.index(of: favorite), section: 0)
    }

    private func updateCell(with favorite: Favorite) {
        if let cell: FavoriteCell = favoritesView.cellForItem(at: indexPath(of: favorite)) {
            update(cell: cell, with: favorite)
        }
    }

    @discardableResult
    private func update(cell: FavoriteCell, with favorite: Favorite) -> FavoriteCell {
        cell.update(favoriteName: favorite.name, isActive: favorite.soundFontPatch == activePatchManager.soundFontPatch)
        return cell
    }

    private func limitWidth(cell: FavoriteCell) -> FavoriteCell {
        cell.maxWidth = cell.bounds.width - 15
        return cell
    }
}
