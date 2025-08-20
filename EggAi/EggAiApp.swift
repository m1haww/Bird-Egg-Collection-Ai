
import SwiftUI

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    static var orientMask: UIInterfaceOrientationMask = .portrait
    @AppStorage("isRate") var isRate = false
    var window: UIWindow?
    var eggDetailVM = EggDetailViewModel()
    var isRateRequested = false
}
