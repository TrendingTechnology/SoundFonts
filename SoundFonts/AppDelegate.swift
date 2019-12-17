// Copyright © 2018 Brad Howes. All rights reserved.

import UIKit
import AVKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let router = Router()
    var window: UIWindow?

    weak var mainViewController: MainViewController?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("application didFinishLaunchingWithOptions")

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        } catch let error as NSError {
            fatalError("Failed to set the audio session category and mode: \(error.localizedDescription)")
        }

        if let url = launchOptions?[.url] as? URL {
            addSoundFont(url: url)
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        addSoundFont(url: url)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        router.mainViewController.stopAudio()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        router.mainViewController.startAudio()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
        router.mainViewController.stopAudio()
    }
}

extension AppDelegate {

    private func addSoundFont(url: URL) {
        let alert: UIAlertController = {
            if let (_, soundFont) = router.soundFonts.add(url: url) {
                let alert = UIAlertController(
                    title: "SoundFont Added",
                    message: "New SoundFont added under the name '\(soundFont.displayName)'",
                    preferredStyle: .alert)
                return alert
            }
            else {
                let alert = UIAlertController(
                    title: "SoundFont Failure",
                    message: "Failed to add new SoundFont.",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                return alert
            }
        }()

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
