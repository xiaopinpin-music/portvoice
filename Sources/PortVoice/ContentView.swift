import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRuntime: AppRuntime

    var body: some View {
        ZStack {
            VisualEffectBlur()
                .ignoresSafeArea()

            VStack(spacing: 22) {
                hero
                Divider()
                    .opacity(0.35)
                settings
                Spacer(minLength: 0)
            }
            .padding(26)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(minWidth: 380, minHeight: 430)
        .onAppear { appRuntime.start() }
    }

    // MARK: - Hero: one clear state

    private var hero: some View {
        VStack(spacing: 14) {
            Image(systemName: appState.isEnabled ? "waveform.circle.fill" : "waveform.slash")
                .font(.system(size: 56, weight: .regular))
                .foregroundColor(appState.isEnabled ? .accentColor : .secondary)
                .accessibilityHidden(true)

            Text(appState.isEnabled ? "hero.listening" : "hero.off", bundle: .module)
                .font(.system(size: 30, weight: .light))
                .foregroundColor(.primary)

            Text(appState.statusMessage)
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 6)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Primary control + deferred settings

    private var settings: some View {
        VStack(alignment: .leading, spacing: 18) {
            Toggle(isOn: enableBinding) {
                Text("control.enable", bundle: .module)
            }
            .toggleStyle(SwitchToggleStyle())
            .accessibilityHint(Text("control.enable.hint", bundle: .module))

            HStack {
                Text("settings.mode", bundle: .module)
                Spacer()
                Picker("", selection: $appState.notificationMode) {
                    ForEach(NotificationMode.allCases) { mode in
                        Text(mode.localizedName).tag(mode)
                    }
                }
                .labelsHidden()
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: 160)
                .accessibilityLabel(Text("settings.mode", bundle: .module))
                .accessibilityHint(Text(appState.notificationMode.localizedDescription))
            }

            Toggle(isOn: $appState.respectDoNotDisturb) {
                Text("settings.respectDND", bundle: .module)
            }
            .toggleStyle(SwitchToggleStyle())
            .accessibilityHint(Text("settings.respectDND.hint", bundle: .module))

            Toggle(isOn: $appState.startInBackgroundAtLogin) {
                Text("settings.startAtLogin", bundle: .module)
            }
            .toggleStyle(SwitchToggleStyle())
            .accessibilityHint(Text("settings.startAtLogin.hint", bundle: .module))

            Button(action: playTest) {
                Text("control.test", bundle: .module)
                    .frame(maxWidth: .infinity)
            }
            .accessibilityHint(Text("control.test.hint", bundle: .module))
            .padding(.top, 2)
        }
    }

    // MARK: - Actions

    private var enableBinding: Binding<Bool> {
        Binding(
            get: { appState.isEnabled },
            set: { newValue in
                appState.isEnabled = newValue
                appRuntime.setEnabled(newValue)
                appState.refreshStatus()
            }
        )
    }

    private func playTest() {
        SpeechService.shared.speak(
            NSLocalizedString("announce.device.connected", bundle: .module, comment: "")
        )
        appState.updateStatus(
            NSLocalizedString("status.testPlayed", bundle: .module, comment: "")
        )
    }
}
