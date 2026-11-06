import Foundation
import IOKit
import IOKit.usb

/// Bekcil's "quick unboxing": works out what a plugged-in USB device is from
/// what the device reports about itself, so PortVoice never needs a list of
/// the world's devices.
///
/// The spoken name is chosen down a ladder, stopping at the first rung that
/// can be trusted:
///   1. A product name that reads like words ("Akai MPK88", "iPhone",
///      "My Passport"), tidied up.
///   2. Maker + kind when the product name is a chip code or too generic
///      ("Realtek storage" instead of "RTL9210B-CG").
///   3. Kind alone ("USB hub", "Camera").
///   4. Nothing trustworthy: nil, and the caller says "Device".
/// When unsure, a rung lower is always chosen — simpler, never wrong.
struct DeviceIdentity: Equatable {
    enum Kind: String {
        case storage, audio, midi, camera, keyboard, mouse, input, hub,
             network, phone, printer, bluetooth
    }

    let productName: String?
    let vendorName: String?
    let kind: Kind?

    /// The words PortVoice speaks for this device, already localized, or nil
    /// when nothing trustworthy is known.
    var spokenName: String? {
        if kind == .hub { return Self.localizedKind(.hub) }
        if let product = Self.tidy(productName), Self.isMeaningful(product) {
            return product
        }
        let vendor = Self.tidyVendor(vendorName)
        switch (vendor, kind) {
        case let (vendor?, kind?):
            return String(format: NSLocalizedString("device.vendorKind", comment: ""),
                          vendor, Self.localizedKind(kind))
        case let (nil, kind?):
            return Self.localizedKind(kind)
        case let (vendor?, nil):
            return String(format: NSLocalizedString("device.vendorKind", comment: ""),
                          vendor, NSLocalizedString("device.kind.device", comment: ""))
        default:
            return nil
        }
    }

    // MARK: - Reading the device

    /// Reads the identity of an IOUSBHostDevice registry entry.
    static func read(_ service: io_service_t) -> DeviceIdentity {
        let product = stringProperty(service, ["USB Product Name", "kUSBProductString"])
        let vendor = stringProperty(service, ["USB Vendor Name", "kUSBVendorString"])
        let deviceClass = intProperty(service, "bDeviceClass") ?? 0
        let vendorID = intProperty(service, "idVendor")

        var interfaces: [(cls: Int, sub: Int, proto: Int)] = []
        var iterator: io_iterator_t = 0
        if IORegistryEntryCreateIterator(service, kIOServicePlane,
                                         IOOptionBits(kIORegistryIterateRecursively),
                                         &iterator) == KERN_SUCCESS {
            while case let child = IOIteratorNext(iterator), child != 0 {
                if let cls = intProperty(child, "bInterfaceClass") {
                    interfaces.append((cls,
                                       intProperty(child, "bInterfaceSubClass") ?? 0,
                                       intProperty(child, "bInterfaceProtocol") ?? 0))
                }
                IOObjectRelease(child)
            }
            IOObjectRelease(iterator)
        }

        let kind = classify(deviceClass: deviceClass, interfaces: interfaces,
                            product: product, vendorID: vendorID)
        return DeviceIdentity(productName: product, vendorName: vendor, kind: kind)
    }

    /// Kind from the official USB class codes the device reports. Interface
    /// classes are checked in order of what a listener cares about most.
    static func classify(deviceClass: Int,
                         interfaces: [(cls: Int, sub: Int, proto: Int)],
                         product: String?, vendorID: Int?) -> Kind? {
        if deviceClass == 0x09 { return .hub }
        let lower = (product ?? "").lowercased()
        if vendorID == 0x05AC, ["iphone", "ipad", "ipod"].contains(where: lower.contains) {
            return .phone
        }
        let classes = Set(interfaces.map(\.cls))
        if classes.contains(0x09) { return .hub }
        if classes.contains(0x08) { return .storage }
        // A webcam also carries a microphone (audio class): video wins.
        if classes.contains(0x0E) { return .camera }
        if interfaces.contains(where: { $0.cls == 0x01 && $0.sub == 0x02 }) { return .audio }
        if interfaces.contains(where: { $0.cls == 0x01 && $0.sub == 0x03 }) { return .midi }
        if classes.contains(0x01) { return .audio }
        if classes.contains(0x06) {
            // Still-image (PTP): phones and cameras. MTP-style Android phones
            // also land here or under vendor class 0xFF.
            return lower.contains("android") || lower.contains("phone") ? .phone : .camera
        }
        if interfaces.contains(where: { $0.cls == 0x02 && [0x06, 0x0D].contains($0.sub) }) { return .network }
        if classes.contains(0x0A) || classes.contains(0x02) { return .network }
        if classes.contains(0x07) { return .printer }
        if classes.contains(0xE0) { return .bluetooth }
        if classes.contains(0x03) {
            let protos = Set(interfaces.filter { $0.cls == 0x03 }.map(\.proto))
            if protos.contains(1) { return .keyboard }
            if protos.contains(2) { return .mouse }
            return .input
        }
        if lower.contains("android") || lower.contains("phone") { return .phone }
        return nil
    }

    // MARK: - Making names speakable

    /// Light tidy-up: underscores to spaces, collapsed spaces, and a trailing
    /// serial-like hex token removed ("My Passport 259F" -> "My Passport").
    static func tidy(_ raw: String?) -> String? {
        guard var s = raw?.replacingOccurrences(of: "_", with: " ") else { return nil }
        s = s.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        var words = s.split(separator: " ").map(String.init)
        if words.count > 1, let last = words.last, isSerialToken(last) {
            words.removeLast()
        }
        s = words.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        return s.isEmpty ? nil : s
    }

    /// "Western Digital" stays; legal suffixes go ("VIA Labs, Inc." -> "VIA Labs").
    static func tidyVendor(_ raw: String?) -> String? {
        guard var s = tidy(raw) else { return nil }
        for suffix in [", Inc.", " Inc.", ", Inc", " Inc", " Corporation", " Corp.", " Corp",
                       " Co., Ltd.", " Co.,Ltd.", " Co., Ltd", " Ltd.", " Ltd", " LLC", " GmbH", " Technology"] {
            if s.hasSuffix(suffix) { s = String(s.dropLast(suffix.count)) }
        }
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: " ,."))
        // "TOSHIBA" -> "Toshiba", so speech says the word instead of spelling it.
        s = s.split(separator: " ").map { word -> String in
            let w = String(word)
            return w.count > 3 && w == w.uppercased() && w.allSatisfy(\.isLetter) ? w.capitalized : w
        }.joined(separator: " ")
        return isMeaningful(s) ? s : nil
    }

    /// True when a name reads like words a person would recognise.
    static func isMeaningful(_ name: String) -> Bool {
        let lower = name.lowercased()
        guard name.count >= 2, lower.rangeOfCharacter(from: .letters) != nil else { return false }
        let generic = ["usb", "external", "mass storage", "storage", "disk", "drive", "device",
                       "composite", "generic", "hub", "usb2.0", "usb3.0", "usb 2.0", "usb 3.0",
                       "flash", "card reader", "reader", "adapter", "bridge", "controller", "unknown"]
        let words = lower.split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "." })
            .map(String.init)
        if !words.isEmpty, words.allSatisfy({ w in
            generic.contains(where: { $0.split(separator: " ").contains(Substring(w)) })
                || w.allSatisfy(\.isNumber) || ["0", "2", "3", "3.0", "2.0", "3.1", "3.2"].contains(w)
        }) {
            return false
        }
        // Chip codes: one token, no lowercase letters, letters mixed with digits
        // ("RTL9210B-CG", "ASM1153E").
        if !name.contains(" "), name == name.uppercased(),
           name.rangeOfCharacter(from: .decimalDigits) != nil {
            return false
        }
        return true
    }

    private static func isSerialToken(_ token: String) -> Bool {
        token.count >= 4
            && token.allSatisfy({ $0.isHexDigit })
            && token.rangeOfCharacter(from: .decimalDigits) != nil
    }

    static func localizedKind(_ kind: Kind) -> String {
        NSLocalizedString("device.kind.\(kind.rawValue)", comment: "")
    }

    // MARK: - IORegistry helpers

    private static func stringProperty(_ service: io_service_t, _ keys: [String]) -> String? {
        for key in keys {
            if let value = IORegistryEntryCreateCFProperty(service, key as CFString,
                                                           kCFAllocatorDefault, 0)?
                .takeRetainedValue() as? String,
               !value.trimmingCharacters(in: .whitespaces).isEmpty {
                return value
            }
        }
        return nil
    }

    private static func intProperty(_ service: io_service_t, _ key: String) -> Int? {
        (IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0)?
            .takeRetainedValue() as? NSNumber)?.intValue
    }
}
