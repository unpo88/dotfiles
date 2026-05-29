import Cocoa

let pb = NSPasteboard.general
let path = "/tmp/claude_img_\(Int(Date().timeIntervalSince1970)).png"

func savePNG(_ data: Data) {
    do {
        try data.write(to: URL(fileURLWithPath: path))
        print(path)
        exit(0)
    } catch {
        fputs("저장 실패: \(error)\n", stderr)
        exit(1)
    }
}

if let data = pb.data(forType: .png) {
    savePNG(data)
} else if let tiff = pb.data(forType: .tiff),
          let image = NSImage(data: tiff),
          let rep = image.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: rep),
          let png = bitmapRep.representation(using: .png, properties: [:]) {
    savePNG(png)
} else {
    fputs("클립보드에 이미지가 없습니다.\n", stderr)
    exit(1)
}
