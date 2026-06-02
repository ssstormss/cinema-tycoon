# Cinema Empire Tycoon

A React Native + Expo + TypeScript mobile tycoon game.

## Run

```bash
npm install
npx expo start
```

Open it with Expo Go on your phone, or run it in an Android/iOS simulator.

## Build iOS from GitHub

This project includes `.github/workflows/eas-ios-build.yml`.

1. Create an Expo access token: Expo dashboard > Account settings > Access Tokens.
2. In GitHub, add it as a repository secret named `EXPO_TOKEN`.
3. Make sure the project is linked to EAS at least once with `npx eas-cli init` and commit the resulting `extra.eas.projectId` change in `app.json`.
4. For iPhone install builds, run the workflow with profile `preview`.
5. For iOS Simulator builds, run it with profile `simulator`.

The `preview` profile uses EAS internal distribution. For real iPhone installation, Apple signing/ad-hoc device setup is required by Apple.

## Stack

- React Native
- Expo
- TypeScript
- Zustand
- AsyncStorage
- React Native SVG

## Gameplay MVP

- Isometric cinema lobby
- Automatic visitors
- Ticket queue and ticket sales
- Snack queue and popcorn sales
- Money system
- Building menu
- Upgrade menu
- Staff system
- Missions
- Statistics
- Autosave and offline earnings
