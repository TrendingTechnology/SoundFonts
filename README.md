# SoundFonts

![](Patches.png)

This is a very simple iOS application that acts as a polyphonic synthesizer. It uses an `AVAudioUnitSampler`
instance to generate the sounds for touched keys. The sounds that are avaiable come from _sound font_ files such
as those available [online](http://www.synthfont.com/links_to_soundfonts.html) for free (and of variable
quaility). This app only supports sound font files that are bundled with the application, though it would be
nice to remotely fetch one to try it out.

## Sound Fonts

The repository comes with four SoundFont files, though the largest one -- `FluidR3_GM` -- is too large to store
natively on Github so it has been broken into three files: `FluidR3_GM.sf2.1`, `FluidR3_GM.sf2.2`, and
`FluidR3_GM.sf2.3`. To make the`FluidR3\_GM` file, you will need to run a simple Bash script -- `FluidR3\_GM.sh`
-- like so:

```
% ./FluidR3_GM.sh
```

There is also a simple Python script called `catalog.py` which will generate a SoundFont catalog in Swift. Each
`*.sf2` that is in the
[./SoundFonts](https://github.com/bradhowes/SoundFonts/tree/master/SoundFonts/SwiftMIDI/SoundFonts) directory
will get its own `*.swift` file with its own `SoundFont` instance that describes all of the patches or presets
that were found in the `*.sf2` file. If you add a new SoundFont file to this directory, you will also need to
add it to the Xcode project so that it gets installed in the iOS application bundle. You will also need to add
the generated `*.swift` file as well so that the application knows what presets are available in the SoundFont
file.

## User Interface

Apologies in advance for the state of the UI. Here is what you can do with it:

* Switch between the patches view (image above) and a _favorites_ view (see below) by swiping left/right on the
  black bar above the keyboard
* You can touch the labels at either end of the black bar to change the range of the keyboard. In the image
  above, the first key is at "C4" and the last key shown is "G5". You can go as low as "C0" and as high as "C9".
  (You can also perform a two-finger pan gesture on the left or right on the black bar to adjust the keyboard
  range.)
* Swipe right on a patch name to make it a favorite (same to unfavorite). Favorited patches have a star next to
  their name.

## Favorites

The favorites view shows all of the patches that have been "Faved".

![](Favorites.png)

Pressing on a favorite will make its associated patch active. You can also configure the starting key of the
keyboard in the favorite as well as gain and stereo pan settings that will apply when the favorite is touched.
To edit a favorite, long-press on the it and you should see an edit view:

![](FavoriteDetail.png)

Nothing fancy. Note that the _gain_ is not exactly like a volume. By default, it will be at 0.0 which means that
there is no gain applied to the syntesizer output. Positive values (max +12) will boost the signal, while
negative values (min -90) will reduce it. Note that these are the min/max values supported by the
`AVAudioUnitSampler`.

The _pan_ value is normally at 0.0. Moving to -1.0 should place the output entirely in the left speaker, while a
+1.0 will place it all in the right.
