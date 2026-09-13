import Foundation

@main
struct RotationCheck {
    static func main() {
        var index = 0
        let text = " 첫 문구\n\n두 번째 문구\r\n세 번째 문구 "
        assert((0..<5).map { _ in nextReminderLine(text: text, index: &index) }
            == ["첫 문구", "두 번째 문구", "세 번째 문구", "첫 문구", "두 번째 문구"])
        assert(nextReminderLine(text: "한 문구", index: &index) == "한 문구")
        assert(nextReminderLine(text: " \n", index: &index) == "" && index == 0)
        index = -1
        assert(nextReminderLine(text: text, index: &index) == "첫 문구")
        print("PASS: ordered rotation, wraparound, blank lines, single line, edited pack")
    }
}
