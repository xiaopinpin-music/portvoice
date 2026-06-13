import SwiftUI
import AppKit

/// A native macOS material background, wrapped for SwiftUI. NSVisualEffectView
/// adopts whatever material style the current system uses, so this stays
/// visually native across versions — from Big Sur through the latest macOS —
/// without hard-coding any version-specific appearance.
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .underWindowBackground
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
