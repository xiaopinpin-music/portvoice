import Foundation
import IOKit
import IOKit.usb

@MainActor
final class USBMonitor: ObservableObject {
    @Published private(set) var isMonitoring: Bool = false

    private var notificationPort: IONotificationPortRef?
    private var addedIterator: io_iterator_t = 0
    private var removedIterator: io_iterator_t = 0

    var onUSBConnected: ((DeviceIdentity) -> Void)?
    var onUSBDisconnected: ((DeviceIdentity) -> Void)?

    /// Identity of every device seen, by registry entry ID. A device that has
    /// just been unplugged can no longer be asked who it is, so its identity
    /// is remembered from when it arrived.
    fileprivate var identities: [UInt64: DeviceIdentity] = [:]

    func start() {
        guard !isMonitoring else { return }

        let matchingDictionary = IOServiceMatching(kIOUSBDeviceClassName)
        let removedMatchingDictionary = IOServiceMatching(kIOUSBDeviceClassName)

        notificationPort = IONotificationPortCreate(kIOMainPortDefault)

        guard let notificationPort else {
            return
        }

        let runLoopSource = IONotificationPortGetRunLoopSource(notificationPort).takeUnretainedValue()
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .defaultMode)

        let selfPointer = Unmanaged.passUnretained(self).toOpaque()

        IOServiceAddMatchingNotification(
            notificationPort,
            kIOFirstMatchNotification,
            matchingDictionary,
            usbAddedCallback,
            selfPointer,
            &addedIterator
        )

        IOServiceAddMatchingNotification(
            notificationPort,
            kIOTerminatedNotification,
            removedMatchingDictionary,
            usbRemovedCallback,
            selfPointer,
            &removedIterator
        )

        // Devices already connected at start: remember them, announce nothing.
        while case let device = IOIteratorNext(addedIterator), device != 0 {
            identities[Self.registryID(device)] = DeviceIdentity.read(device)
            IOObjectRelease(device)
        }
        drain(iterator: removedIterator)

        isMonitoring = true
    }

    func stop() {
        guard isMonitoring else { return }

        if addedIterator != 0 {
            IOObjectRelease(addedIterator)
            addedIterator = 0
        }

        if removedIterator != 0 {
            IOObjectRelease(removedIterator)
            removedIterator = 0
        }

        if let notificationPort {
            IONotificationPortDestroy(notificationPort)
            self.notificationPort = nil
        }

        isMonitoring = false
    }

    fileprivate func handleUSBConnected(_ id: UInt64, _ identity: DeviceIdentity) {
        identities[id] = identity
        onUSBConnected?(identity)
    }

    fileprivate func handleUSBDisconnected(_ id: UInt64, _ fallback: DeviceIdentity) {
        let identity = identities.removeValue(forKey: id) ?? fallback
        onUSBDisconnected?(identity)
    }

    nonisolated fileprivate static func registryID(_ device: io_service_t) -> UInt64 {
        var id: UInt64 = 0
        IORegistryEntryGetRegistryEntryID(device, &id)
        return id
    }

    private func drain(iterator: io_iterator_t) {
        while case let device = IOIteratorNext(iterator), device != 0 {
            IOObjectRelease(device)
        }
    }
}

private func usbAddedCallback(refCon: UnsafeMutableRawPointer?, iterator: io_iterator_t) {
    guard let refCon else { return }
    let monitor = Unmanaged<USBMonitor>.fromOpaque(refCon).takeUnretainedValue()

    while case let device = IOIteratorNext(iterator), device != 0 {
        // Read who it is now, while the device can still be asked.
        let id = USBMonitor.registryID(device)
        let identity = DeviceIdentity.read(device)
        IOObjectRelease(device)
        Task { @MainActor in
            monitor.handleUSBConnected(id, identity)
        }
    }
}

private func usbRemovedCallback(refCon: UnsafeMutableRawPointer?, iterator: io_iterator_t) {
    guard let refCon else { return }
    let monitor = Unmanaged<USBMonitor>.fromOpaque(refCon).takeUnretainedValue()

    while case let device = IOIteratorNext(iterator), device != 0 {
        let id = USBMonitor.registryID(device)
        let fallback = DeviceIdentity.read(device)
        IOObjectRelease(device)
        Task { @MainActor in
            monitor.handleUSBDisconnected(id, fallback)
        }
    }
}
