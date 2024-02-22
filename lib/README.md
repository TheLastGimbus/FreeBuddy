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
