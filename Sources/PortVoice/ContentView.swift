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
                    .portVoiceGlassCard()
                if !Self.usesLiquidGlass {
                    Divider()
                        .opacity(0.35)
                }
                settings
                    .portVoiceGlassCard()
                Spacer(minLength: 0)
            }
            .padding(26)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        // The glass cards add their own padding, so the glass layout needs a
        // taller window; otherwise the cards are clipped at top and bottom.
        .frame(minWidth: 380, minHeight: Self.usesLiquidGlass ? 476 : 430)
        .onAppear { appRuntime.start() }
    }

    // MARK: - Hero: one clear state

    private var hero: some View {
        VStack(spacing: 14) {
            Image(systemName: appState.isEnabled ? "waveform.circle.fill" : "waveform.slash")
                .font(.system(size: 56, weight: .regular))
                .foregroundColor(appState.isEnabled ? .accentColor : .secondary)
                .accessibilityHidden(true)

            Text(appState.isEnabled ? "hero.listening" : "hero.off")
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
                Text("control.enable")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .toggleStyle(SwitchToggleStyle())
            .accessibilityHint(Text("control.enable.hint"))

            HStack {
                Text("settings.mode")
                Spacer()
                Picker("", selection: $appState.notificationMode) {
                    ForEach(NotificationMode.allCases) { mode in
                        Text(mode.localizedName).tag(mode)
                    }
                }
                .labelsHidden()
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: 160)
                .accessibilityLabel(Text("settings.mode"))
                .accessibilityHint(Text(appState.notificationMode.localizedDescription))
            }

            Toggle(isOn: $appState.respectDoNotDisturb) {
                Text("settings.respectDND")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .toggleStyle(SwitchToggleStyle())
            .accessibilityHint(Text("settings.respectDND.hint"))

            Toggle(isOn: $appState.startInBackgroundAtLogin) {
                Text("settings.startAtLogin")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .toggleStyle(SwitchToggleStyle())
            .accessibilityHint(Text("settings.startAtLogin.hint"))

            Button(action: playTest) {
                Text("control.test")
                    .frame(maxWidth: .infinity)
            }
            .portVoicePrimaryButton()
            .accessibilityHint(Text("control.test.hint"))
            .padding(.top, 2)
        }
    }

    // MARK: - Liquid Glass (macOS 26+)

    /// macOS 26 and later get Liquid Glass; macOS 12–15 keep the native
    /// material look. Glass only changes how things look, never what
    /// VoiceOver reads.
    static var usesLiquidGlass: Bool {
        if #available(macOS 26.0, *) { return true }
        return false
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
            NSLocalizedString("announce.device.connected", comment: "")
        )
        appState.updateStatus(
            NSLocalizedString("status.testPlayed", comment: "")
        )
    }
}

// MARK: - Liquid Glass helpers
//
// Glass is used only where it has a job (Kakek Jony): the status card, the
// settings card, and the one primary button. The window background stays the
// system material. Light/dark mode, the user's accent colour, Reduce
// Transparency, and Increase Contrast are handled by the system.
//
// No GlassEffectContainer: wrapping the window in one made the Enable switch
// flip itself off on about one launch in three (Xcode 27.3, macOS 27.3;
// 3 of 6 launches off with it, 15 of 15 on without it). The two cards are
// separate anyway, so the container added nothing.
private extension View {
    @ViewBuilder
    func portVoiceGlassCard() -> some View {
        if #available(macOS 26.0, *) {
            self
                .padding(18)
                .glassEffect(.regular, in: .rect(cornerRadius: 22))
        } else {
            self
        }
    }

    @ViewBuilder
    func portVoicePrimaryButton() -> some View {
        if #available(macOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self
        }
    }
}
