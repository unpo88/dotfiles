import AppKit
import CoreGraphics
import Foundation

private let targetBundleID = "com.stablyai.orca"
private let escapeKey: CGKeyCode = 53
private let pKey: CGKeyCode = 35
private let kKey: CGKeyCode = 40

private func frontmostBundleID() -> String? {
  NSWorkspace.shared.frontmostApplication?.bundleIdentifier
}

private func postKey(_ keyCode: CGKeyCode) {
  let source = CGEventSource(stateID: .hidSystemState)
  let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
  let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
  keyDown?.flags = []
  keyUp?.flags = []
  keyDown?.post(tap: .cghidEventTap)
  keyUp?.post(tap: .cghidEventTap)
}

private func postMetaKey(_ keyCode: CGKeyCode) {
  postKey(escapeKey)
  postKey(keyCode)
}

private func eventCallback(
  proxy: CGEventTapProxy,
  type: CGEventType,
  event: CGEvent,
  userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
  guard type == .keyDown else { return Unmanaged.passUnretained(event) }
  guard frontmostBundleID() == targetBundleID else { return Unmanaged.passUnretained(event) }

  let flags = event.flags
  guard flags.contains(.maskCommand), flags.contains(.maskAlternate) else {
    return Unmanaged.passUnretained(event)
  }

  let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
  switch keyCode {
  case pKey:
    postMetaKey(pKey)
    return nil
  case kKey:
    postMetaKey(kKey)
    return nil
  default:
    return Unmanaged.passUnretained(event)
  }
}

private func createEventTap() -> CFMachPort? {
  let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
  return CGEvent.tapCreate(
    tap: .cgSessionEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: mask,
    callback: eventCallback,
    userInfo: nil
  )
}

private func runCheck() {
  let trusted = AXIsProcessTrusted()
  let tap = createEventTap()
  print("accessibilityTrusted=\(trusted)")
  print("eventTapCreated=\(tap != nil)")
}

private func run() -> Never {
  guard let tap = createEventTap() else {
    fputs("orca-nvim-key-remap: failed to create event tap. Grant Accessibility permission to ~/.local/bin/orca-nvim-key-remap, then reload the LaunchAgent.\n", stderr)
    exit(1)
  }

  let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
  CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
  CGEvent.tapEnable(tap: tap, enable: true)
  FileHandle.standardOutput.write(Data("orca-nvim-key-remap: ready\n".utf8))
  CFRunLoopRun()
  exit(0)
}

if CommandLine.arguments.contains("--check") {
  runCheck()
} else {
  run()
}
