import Foundation

@main
struct RotationCheck {
    static func main() {
        var index = 0
        let packs = ["B": "세 번째 문구 ", "A": " 첫 문구\n\n두 번째 문구\r\n", "Empty": " "]
        assert((0..<5).map { _ in nextReminderLine(packs: packs, index: &index) }
            == ["첫 문구", "세 번째 문구", "두 번째 문구", "세 번째 문구", "첫 문구"])
        assert(nextReminderLine(packs: ["Only": "한 문구"], index: &index) == "한 문구")
        assert(nextReminderLine(packs: ["Empty": " \n"], index: &index) == "" && index == 0)
        index = -1
        assert(nextReminderLine(packs: packs, index: &index) == "첫 문구")
        print("PASS: round-robin packs, independent line wraparound, blank lines, single line, edited packs")
    }
}
