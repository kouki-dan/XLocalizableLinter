@main
public struct XLocalizableLinter {
    public private(set) var text = "Hello, World!"

    public static func main() {
        print(XLocalizableLinter().text)
    }
}
