// Copyright © 2020 Brad Howes. All rights reserved.

import CoreAudioKit
import SoundFontsFramework
import os

public class SoundFontsAUViewController: AUViewController, AUAudioUnitFactory {
    private let log = Logging.logger("SFAU")

    let sampler = Sampler(mode: .audiounit)
    var components: Components<SoundFontsAUViewController>!
    var activePatchManager: ActivePatchManager!
    var infoBar: InfoBar!


    public override func viewDidLoad() {
        super.viewDidLoad()

        let sharedStateMonitor = SharedStateMonitor(changer: .audioUnit)
        components = Components<SoundFontsAUViewController>(sharedStateMonitor: sharedStateMonitor)
        components.setMainViewController(self)
    }

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        if case let .failure(failure) = sampler.start() {
            os_log(.error, log: log, "failed to start sampler - %s", failure.localizedDescription)
        }

        return sampler.auAudioUnit!
    }
}

// MARK: - Controller Configuration

extension SoundFontsAUViewController: ControllerConfiguration {

    /**
     Establish connections with other managers / controllers.

     - parameter context: the RunContext that holds all of the registered managers / controllers
     */
    public func establishConnections(_ router: ComponentContainer) {
        activePatchManager = router.activePatchManager
        infoBar = router.infoBar
        activePatchManager.subscribe(self, notifier: activePatchChange)
        router.favorites.subscribe(self, notifier: favoritesChange)
        useActivePatchKind(activePatchManager.active)
    }

    private func activePatchChange(_ event: ActivePatchEvent) {
        if case let .active(old: _, new: new) = event {
            useActivePatchKind(new)
        }
    }

    private func favoritesChange(_ event: FavoritesEvent) {
        switch event {
        case let .added(index: _, favorite: favorite): updateInfoBar(with: favorite)
        case let .changed(index: _, favorite: favorite): updateInfoBar(with: favorite)
        case let .removed(index: _, favorite: favorite, bySwiping: _): updateInfoBar(with: favorite.soundFontPatch)
        default: break
        }
    }

    private func updateInfoBar(with favorite: Favorite) {
        if favorite.soundFontPatch == activePatchManager.soundFontPatch {
            infoBar.setPatchInfo(name: favorite.name, isFavored: true)
        }
    }

    private func updateInfoBar(with soundFontPatch: SoundFontPatch) {
        if soundFontPatch == activePatchManager.soundFontPatch {
            infoBar.setPatchInfo(name: soundFontPatch.patch.name, isFavored: false)
        }
    }

    private func useActivePatchKind(_ activePatchKind: ActivePatchKind) {

        if let favorite = activePatchKind.favorite {
            infoBar.setPatchInfo(name: favorite.name, isFavored: true)
        }
        else {
            infoBar.setPatchInfo(name: activePatchKind.soundFontPatch.patch.name, isFavored: false)
        }

        _ = self.sampler.load(activePatchKind: activePatchKind)
    }
}
