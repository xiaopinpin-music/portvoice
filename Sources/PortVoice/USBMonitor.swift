import Foundation
import IOKit
import IOKit.usb

@MainActor
final class USBMonitor: ObservableObject {
    @Published private(set) var isMonitoring: Bool = false

    private var notificationPort: IONotificationPortRef?
    private var addedIterator: io_iterator_t = 0
    private var removedIterator: io_iterator_t = 0

    var onUSBConnected: (() -> Void)?
    var onUSBDisconnected: (() -> Void)?

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

        drain(iterator: addedIterator)
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

    private func handleUSBConnected() {
        onUSBConnected?()
    }

    private func handleUSBDisconnected() {
        onUSBDisconnected?()
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
        IOObjectRelease(device)
        Task { @MainActor in
            monitor.handleUSBConnected()
        }
    }
}

private func usbRemovedCallback(refCon: UnsafeMutableRawPointer?, iterator: io_iterator_t) {
    guard let refCon else { return }
    let monitor = Unmanaged<USBMonitor>.fromOpaque(refCon).takeUnretainedValue()

    while case let device = IOIteratorNext(iterator), device != 0 {
        IOObjectRelease(device)
        Task { @MainActor in
            monitor.handleUSBDisconnected()
        }
    }
}
