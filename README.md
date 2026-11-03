# SATELLITE IPTV

Flutter starter project for Android phones and Android TV boxes.

## Build an APK using a phone only

1. Upload the contents of this ZIP to a GitHub repository (not the ZIP file itself).
2. Open https://codemagic.io/ and sign in with GitHub.
3. Add the repository as a Flutter app.
4. Select the workflow `SATELLITE IPTV Android APK` from `codemagic.yaml`.
5. Start the build and download the APK artifact if the build succeeds.

## Notes

- The interface is designed around the agreed dark-blue channel list and black video area.
- The channel names shown initially are demonstration entries.
- Use the playlist button in the video area to enter an M3U playlist URL. Provider-specific playlist parsing and full Xtream Codes login are not yet implemented.
- A successful cloud build is required before an APK exists. This source ZIP is not itself an APK.
