# PortVoice Login Item Investigation

## Branch

feature/start-in-background-at-login

## Goal

Add optional Start in background at login behavior.

Expected final behavior:

- User enables Start in background at login.
- PortVoice starts automatically after macOS login.
- The main dashboard does not open.
- Barbara menu bar remains available.
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
- Barbara does not appear in the menu bar.
- This does not satisfy the background login requirement.

Conclusion:

SMAppService can make macOS launch PortVoice from /Applications, but current launch behavior is not correct yet.

Next technical direction:

- Detect background launch mode.
- Prevent dashboard/window from opening during login launch.
- Ensure Barbara and device monitoring start during background launch.
- Consider a user LaunchAgent or helper login item that starts PortVoice with a --background argument.

## Background Mode Manual Test Result

After moving monitoring and menu bar setup into AppRuntime and stabilizing SpeechService:

Confirmed:

- Manual background launch works with the --background argument.
- Barbara appears in the menu bar.
- The dashboard does not interfere with background use.
- Storage disconnect announcement works.
- Storage connect announcement works.
- VoiceOver did not crash during the latest one-cycle test.
- Speech delay feels faster and more usable.

Current conclusion:

The AppRuntime two-layer structure is the correct direction.

Layer 1:

- AppRuntime
- Barbara
- Device monitoring
- Speech coordination

Layer 2:

- Dashboard / ContentView
- User controls
- Status display

Next required step:

Connect login/startup behavior to launch PortVoice in background mode so that macOS login starts Barbara and monitoring without opening the dashboard.

## Successful LaunchAgent Background Test

Confirmed after the latest AppRuntime and background launch fixes:

- LaunchAgent starts PortVoice from /Applications.
- PortVoice runs with the --background argument.
- Barbara appears in the menu bar.
- Empty dashboard/window no longer appears during background launch.
- Storage disconnect announcement works.
- Storage connect announcement works.
- VoiceOver did not crash.
- Speech feels faster and more usable.

This satisfies the core V0.8 background login requirement for the current test environment.

Remaining validation before release:

- Test after real macOS logout/login.
- Test after full restart.
- Confirm checkbox disable removes or disables the LaunchAgent cleanly.
- Build fresh DMG.
- Install from DMG to /Applications.
- Confirm the installed app can enable background startup.

## Duplicate Voice Bug Result

A duplicate voice issue was observed after login.

Cause:

Two PortVoice processes were running:

- /Applications/PortVoice.app/Contents/MacOS/PortVoice
- /Applications/PortVoice.app/Contents/MacOS/PortVoice --background

After stopping all PortVoice processes and reloading only the LaunchAgent, only one process remained:

- /Applications/PortVoice.app/Contents/MacOS/PortVoice --background

Confirmed result:

- Barbara appears.
- No empty window appears.
- Storage disconnect announcement works.
- Storage connect announcement works.
- Voice output is no longer duplicated.

This confirms that the duplicate voice bug was caused by multiple running PortVoice instances, not by the notification mode logic.

## Disable Background Login Test Result

Confirmed:

- Turning off Start in background at login removes the LaunchAgent.
- After quitting PortVoice, no PortVoice process remains.
- The user can disable background startup without uninstalling PortVoice.

Observed terminal result:

- LaunchAgent sudah hilang
- PortVoice sudah mati

This satisfies the shared Mac requirement: users can turn PortVoice startup on or off without removing the app.
