import SwiftUI

for _ in 0..<100 {
    assert(OverlayStyle.random().textColor == Color.black)
}
print("PASS: 100 randomized overlay styles retain black text")

let font = NSFont(name: "NotoSansKR-Regular", size: 48)!
assert(font.familyName == "Noto Sans KR")
let characters = Array("오늘 내가 정해둔 내 삶을 살아가고 있는가?".utf16)
var glyphs = [CGGlyph](repeating: 0, count: characters.count)
assert(CTFontGetGlyphsForCharacters(font as CTFont, characters, &glyphs, characters.count))
print("PASS: Noto Sans KR resolves and covers the Korean reminder")
