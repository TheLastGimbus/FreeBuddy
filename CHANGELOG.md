# Changelog

# 0.1.5 (todo)

- More Material3-ish look:
  - Colors from wallpaper on Android 12
- Better layout in landscape
- Move all headphone settings to own page - clearer home page
  - It's kinda empty now, so I hope to fill it with something soon 🙈

## 0.1.4 (2023-04-02)

- Remove sleep mode because noone knows what it's for 🙈
- Fully implement all gesture settings 🥳 - now you can uninstall Ai Life for good 😇

## 0.1.3 (2023-01-29)

- Remove twitter/reddit links so maybe google happy

## 0.1.2 (2023-01-29)

- **Actually** make it work >=12

## 0.1.1 (2023-01-29)

- Fix "not paired" not displaying incident
- Add alias display 💅

## 0.1.0 (2023-01-29)

- Huuuuuge refactors ⚙:
  - Migration to my own [`the_last_bluetooth`](https://github.com/TheLastGimbus/the_last_bluetooth/) plugin 🥳 - this should make it work on Android >= 12 🎉
  - Better handling of bt disabled/enabled/connected/disconnected etc
  - Tests 🧪
  - Flutter 3.7
- Prettier ui:
  - Nicer Material3 style
  - Nicer showing state - pretty animations instead of 1mm text
  - Animations ✨
- Features 🔨:⏸
  - Smart wear switch
  - Sleep mode 😴 - disables smart wear and anc
- Other:
  - Demo mode - available at https://freebuddy-web-demo.netlify.app/

## 0.0.5 (2022-10-03)

- Add introduction page on first launch
- Compliant with Google Play privacy policy requirements
- Sign with debug keys in release mode when `key.properties` doesn't exist (for CI build)

## 0.0.4 (2022-09-15)

- Fix finding paired device (now using name regex instead of mac)

## 0.0.3 (2022-09-15)

- Dark theme
- Multi lang - Polish
- Better connection handling
- Material 3
- Nicer about page and contacts

## 0.0.2 (2022-09-09)

- Add privacy policy and licenses page

## 0.0.1 (2022-09-01)

- Initial app launch
- Basic features to change mode and look at the battery
