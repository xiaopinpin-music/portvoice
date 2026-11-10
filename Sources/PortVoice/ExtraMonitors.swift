import Foundation
import SystemConfiguration
import CoreAudio
import IOKit.ps

// Stage 2 ears (Ko, 10 Nov 2026): "tanpa bolong" — every port speaks.
//  - EthernetMonitor: a network cable plugged into or pulled from a wired port.
//  - HeadphoneMonitor: headphones in or out of the Mac's 3.5 mm jack.
//  - PowerMonitor: a MacBook charger connected or disconnected.
// Each one remembers the state it found at start and only reports changes.

// MARK: - Ethernet (kabel LAN)

/// Watches the link state of wired Ethernet ports, including USB and
/// Thunderbolt Ethernet adapters. Wi-Fi and the virtual bridge are not
/// Ethernet-type interfaces, so they are never counted.
@MainActor
final class EthernetMonitor {
    var onCableConnected: (() -> Void)?
    var onCableDisconnected: (() -> Void)?

    private var store: SCDynamicStore?
    private var source: CFRunLoopSource?
    private var active: Set<String> = []
    private var pending: Task<Void, Never>?

    func start() {
        guard store == nil else { return }
        var context = SCDynamicStoreContext(version: 0,
                                            info: Unmanaged.passUnretained(self).toOpaque(),
                                            retain: nil, release: nil, copyDescription: nil)
        guard let store = SCDynamicStoreCreate(nil, "PortVoice" as CFString, { _, _, info in
            guard let info else { return }
            let monitor = Unmanaged<EthernetMonitor>.fromOpaque(info).takeUnretainedValue()
            Task { @MainActor in monitor.linkMayHaveChanged() }
        }, &context) else { return }

        SCDynamicStoreSetNotificationKeys(store, nil,
                                          ["State:/Network/Interface/[^/]+/Link"] as CFArray)
        let source = SCDynamicStoreCreateRunLoopSource(nil, store, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        self.store = store
        self.source = source
        active = activeWiredPorts()
    }

    func stop() {
        if let source { CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes) }
        source = nil
        store = nil
        pending?.cancel()
        active = []
    }

    /// A link that flaps while it negotiates is announced once, after it has
    /// settled for 0.7 s.
    private func linkMayHaveChanged() {
        pending?.cancel()
        pending = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 700_000_000)
            guard !Task.isCancelled, let self else { return }
            let now = self.activeWiredPorts()
            let added = now.subtracting(self.active)
            let removed = self.active.subtracting(now)
            self.active = now
            if !added.isEmpty { self.onCableConnected?() }
            if !removed.isEmpty { self.onCableDisconnected?() }
        }
    }

    private func activeWiredPorts() -> Set<String> {
        guard let store else { return [] }
        // Thunderbolt ports also show up as Ethernet; their link only becomes
        // active when a Thunderbolt cable networks this Mac with another one.
        // That is a network cable being plugged in, so it is announced too.
        let interfaces = (SCNetworkInterfaceCopyAll() as? [SCNetworkInterface]) ?? []
        var result = Set<String>()
        for interface in interfaces {
            guard let type = SCNetworkInterfaceGetInterfaceType(interface) as String?,
                  type == (kSCNetworkInterfaceTypeEthernet as String),
                  let bsd = SCNetworkInterfaceGetBSDName(interface) as String? else { continue }
            let key = "State:/Network/Interface/\(bsd)/Link" as CFString
            if let link = SCDynamicStoreCopyValue(store, key) as? [String: Any],
               (link["Active"] as? Bool) == true {
                result.insert(bsd)
            }
        }
        return result
    }
}

// MARK: - Headphones (colokan 3,5 mm)

/// Listens to the built-in output's data source ("ispk" speakers, "hdpn"
/// headphones). On Macs where the jack appears as its own built-in device,
/// that device appearing or disappearing is treated the same way.
@MainActor
final class HeadphoneMonitor {
    var onHeadphonesConnected: (() -> Void)?
    var onHeadphonesDisconnected: (() -> Void)?

    private var watchedDevices: Set<AudioObjectID> = []
    private var listening = false
    private var registered = false
    private var pluggedIn = false
    private let headphonesSource: UInt32 = 0x6864_706E  // 'hdpn'

    func start() {
        guard !listening else { return }
        listening = true
        if !registered {
            registered = true
            var address = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices,
                                                     mScope: kAudioObjectPropertyScopeGlobal,
                                                     mElement: kAudioObjectPropertyElementMain)
            AudioObjectAddPropertyListenerBlock(AudioObjectID(kAudioObjectSystemObject), &address,
                                                DispatchQueue.main) { [weak self] _, _ in
                Task { @MainActor in self?.refresh() }
            }
        }
        watchBuiltInOutputs()
        pluggedIn = headphonesPresent()
    }

    func stop() {
        // Listener blocks stay registered for the app's lifetime; changes are
        // ignored while stopped.
        listening = false
    }

    private func refresh() {
        guard listening else { return }
        watchBuiltInOutputs()
        let now = headphonesPresent()
        guard now != pluggedIn else { return }
        pluggedIn = now
        if now { onHeadphonesConnected?() } else { onHeadphonesDisconnected?() }
    }

    private func watchBuiltInOutputs() {
        for device in builtInOutputDevices() where !watchedDevices.contains(device) {
            watchedDevices.insert(device)
            var address = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyDataSource,
                                                     mScope: kAudioObjectPropertyScopeOutput,
                                                     mElement: kAudioObjectPropertyElementMain)
            if AudioObjectHasProperty(device, &address) {
                AudioObjectAddPropertyListenerBlock(device, &address, DispatchQueue.main) { [weak self] _, _ in
                    Task { @MainActor in self?.refresh() }
                }
            }
        }
    }

    private func headphonesPresent() -> Bool {
        for device in builtInOutputDevices() {
            var address = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyDataSource,
                                                     mScope: kAudioObjectPropertyScopeOutput,
                                                     mElement: kAudioObjectPropertyElementMain)
            if AudioObjectHasProperty(device, &address) {
                var source: UInt32 = 0
                var size = UInt32(MemoryLayout<UInt32>.size)
                if AudioObjectGetPropertyData(device, &address, 0, nil, &size, &source) == noErr,
                   source == headphonesSource {
                    return true
                }
            } else if Self.name(of: device).localizedCaseInsensitiveContains("headphone") {
                // Jack shown as its own built-in device (e.g. "External Headphones").
                return true
            }
        }
        return false
    }

    private func builtInOutputDevices() -> [AudioObjectID] {
        var address = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices,
                                                 mScope: kAudioObjectPropertyScopeGlobal,
                                                 mElement: kAudioObjectPropertyElementMain)
        var size: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address,
                                             0, nil, &size) == noErr else { return [] }
        var ids = [AudioObjectID](repeating: 0, count: Int(size) / MemoryLayout<AudioObjectID>.size)
        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address,
                                         0, nil, &size, &ids) == noErr else { return [] }
        return ids.filter { id in
            var transport: UInt32 = 0
            var tsize = UInt32(MemoryLayout<UInt32>.size)
            var taddr = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyTransportType,
                                                   mScope: kAudioObjectPropertyScopeGlobal,
                                                   mElement: kAudioObjectPropertyElementMain)
            guard AudioObjectGetPropertyData(id, &taddr, 0, nil, &tsize, &transport) == noErr,
                  transport == kAudioDeviceTransportTypeBuiltIn else { return false }
            var saddr = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreams,
                                                   mScope: kAudioObjectPropertyScopeOutput,
                                                   mElement: kAudioObjectPropertyElementMain)
            var ssize: UInt32 = 0
            return AudioObjectGetPropertyDataSize(id, &saddr, 0, nil, &ssize) == noErr && ssize > 0
        }
    }

    private static func name(of device: AudioObjectID) -> String {
        var address = AudioObjectPropertyAddress(mSelector: kAudioObjectPropertyName,
                                                 mScope: kAudioObjectPropertyScopeGlobal,
                                                 mElement: kAudioObjectPropertyElementMain)
        var name: Unmanaged<CFString>?
        var size = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
        guard AudioObjectGetPropertyData(device, &address, 0, nil, &size, &name) == noErr,
              let value = name?.takeRetainedValue() else { return "" }
        return value as String
    }
}

// MARK: - Charger (MacBook)

/// Reports when a Mac with a battery switches between charger and battery.
/// Desktop Macs (no battery) never report anything.
@MainActor
final class PowerMonitor {
    var onChargerConnected: (() -> Void)?
    var onChargerDisconnected: (() -> Void)?

    private var source: CFRunLoopSource?
    private var onCharger = false

    func start() {
        guard source == nil, Self.hasBattery() else { return }
        onCharger = Self.isOnCharger()
        let context = Unmanaged.passUnretained(self).toOpaque()
        guard let source = IOPSNotificationCreateRunLoopSource({ info in
            guard let info else { return }
            let monitor = Unmanaged<PowerMonitor>.fromOpaque(info).takeUnretainedValue()
            Task { @MainActor in monitor.powerMayHaveChanged() }
        }, context)?.takeRetainedValue() else { return }
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .defaultMode)
        self.source = source
    }

    func stop() {
        if let source { CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .defaultMode) }
        source = nil
    }

    private func powerMayHaveChanged() {
        let now = Self.isOnCharger()
        guard now != onCharger else { return }
        onCharger = now
        if now { onChargerConnected?() } else { onChargerDisconnected?() }
    }

    private static func hasBattery() -> Bool {
        let info = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let list = IOPSCopyPowerSourcesList(info).takeRetainedValue() as [CFTypeRef]
        return !list.isEmpty
    }

    private static func isOnCharger() -> Bool {
        let info = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let type = IOPSGetProvidingPowerSourceType(info).takeUnretainedValue() as String
        return type == kIOPSACPowerValue
    }
}
