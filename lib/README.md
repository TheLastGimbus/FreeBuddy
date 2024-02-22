# Hi!!!!!! 👋👋👋👋👋
You're coding and want to help out/explore around here? That's great!!!

Okay, so - UI code is as pure-flutter-future-stream as possible, and most stuff has comments/documentation, so just look around and read those 👍

Interesting rev-eng stuff is in `headphones/` folder, and there is dedicated [headphones/README.md](headphones/README.md) - head there 🫡

# Development notes - philosophies, TODOs etc

## Migration to framework-ish organisation
TODO:
- [X] Implement basic stuff (ANC + battery)
- [X] Change ui to work at all with new stuff
- [ ] Implement hp settings
  This is non trivial cause we have to decide how to make this universal when almost all headphones have this different
- [ ] Change ui BIG to dynamically support *all* headphones by their features instead of concrete model
- [ ] Support multiple diff headphones
  - [ ] Basic fix in connection loops to show them at all
  - [ ] Basic fix in widget to maybe show their name to distinguish which ones are shown now
  - [ ] Some database stuf... ehhhh... to distinguish between them, remember their last time etc
    This is potentially waaayyy ahead todo as it requires *serious* decisions that will affect *everything* wayyy ahead in later development, so better not fuck it up
    - [ ] Selecting headphones when making new widget

## Future features:
- [ ] Detect hp colors and assign proper image
- [ ] ANC control widget
  This will require whole big background stuff, so that's far offs