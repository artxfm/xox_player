# xox_player

A cross platform app to simply play the WXOX radio stream. Ideally this will be
easily customized/repurposed by other stations, and maintained by the community
so that nobody has to build one of these from scratch again.


Big thanks to 
https://suragch.medium.com/steaming-audio-in-flutter-with-just-audio-7435fcf672bf


## TODO


### nice to have for future release

- Can the main logo spin while we are playing?

- May need a new main icon (since the one we have now has a white
  background).

- Need better graphics. For example (at least on android) the "white" of the
  large logo does not quite match the white of the screen background. The icons
  could be much better too. For example (again on android) the WXOX logo used as
  the icon is a square with a circle, but really it should just be the circle
  part filling the whole icon.
  
- Would be nice to show some show times and name info. For example, what is the
  name of the current show and what is the name and start time of the next show.
  This would require that the app is able to load schedule info from the site or
  something like that.
  


## Development

Contributions are welcome! Please feel free to branch and create a PR.
Eventually bugs and TODOs will be in the github issues area.


### Generating Icons

Put a high res icon in assets/icon/icon.png and then run this to generate 
icons for ios and android:

```
  flutter pub run flutter_launcher_icons
```



### (Flutter) Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
