# PortVoice Login Item Investigation

## Branch

feature/start-in-background-at-login

## Goal

Add optional Start in background at login behavior.

Expected final behavior:

- User enables Start in background at login.
- PortVoice starts automatically after macOS login.
- The main dashboard does not open.
- the menu bar menu bar remains available.
- Device monitoring starts automatically.

## Implemented So Far

Current branch includes:

- Start in background at login checkbox
- UserDefaults persistence
- LoginItemService using ServiceManagement
- SMAppService.mainApp.register()
- SMAppService.mainApp.unregister()

## Confirmed Working

- Checkbox appears in the UI.
- VoiceOver can access the setting.
- Checkbox state persists after quit and reopen.
- LoginItemService is called when the setting changes.
- App builds successfully.

## Current Problem

SMAppService registration currently fails with:

The operation could not be completed. Invalid argument.

## Product Decision

Do not merge this branch into main until login item registration is verified.

The branch is useful for continued investigation, but the feature is not complete yet.

## Safe Public Wording

Start in background at login is planned and under investigation.

Do not claim it works until tested from a proper app bundle and verified after macOS login.

## Next Investigation Steps

1. Review app bundle identifier and Info.plist.
2. Test from /Applications instead of dist.
3. Investigate whether SMAppService.mainApp is enough.
4. Investigate helper login item requirements.
5. Consider Xcode-style app project packaging if needed.
6. Confirm behavior after logout, login, or restart.

## Accessibility Requirement

When complete, this feature must remain VoiceOver-friendly.

The user should be able to enable or disable startup behavior without uninstalling PortVoice.

## Login Test Result from /Applications

After copying PortVoice.app to /Applications and enabling Start in background at login:

Confirmed:

- macOS launches PortVoice after login.
- Process appears as /Applications/PortVoice.app/Contents/MacOS/PortVoice.

Observed problem:

- A window appears at login.
- The window is not the desired dashboard behavior.
- the menu bar does not appear in the menu bar.
- This does not satisfy the background login requirement.

Conclusion:

SMAppService can make macOS launch PortVoice from /Applications, but current launch behavior is not correct yet.

Next technical direction:

- Detect background launch mode.
- Prevent dashboard/window from opening during login launch.
- Ensure the menu bar and device monitoring start during background launch.
- Consider a user LaunchAgent or helper login item that starts PortVoice with a --background argument.
