import SwiftUI
import Swinject

@main struct FreeAPSApp: App {
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Dependencies Assembler
    // contain all dependencies Assemblies
    // TODO: Remove static key after update "Use Dependencies" logic
    private static var assembler = Assembler([
        StorageAssembly(),
        ServiceAssembly(),
        APSAssembly(),
        NetworkAssembly(),
        UIAssembly(),
        SecurityAssembly()
    ], parent: nil, defaultObjectScope: .container)

    var resolver: Resolver {
        FreeAPSApp.assembler.resolver
    }

    // Temp static var
    // Use to backward compatibility with old Dependencies logic on Logger
    // TODO: Remove var after update "Use Dependencies" logic in Logger
    static var resolver: Resolver {
        FreeAPSApp.assembler.resolver
    }

    private func loadServices() {
        resolver.resolve(AppearanceManager.self)!.setupGlobalAppearance()
        _ = resolver.resolve(DeviceDataManager.self)!
        _ = resolver.resolve(APSManager.self)!
        _ = resolver.resolve(FetchGlucoseManager.self)!
        _ = resolver.resolve(FetchTreatmentsManager.self)!
        _ = resolver.resolve(FetchAnnouncementsManager.self)!
        _ = resolver.resolve(CalendarManager.self)!
        _ = resolver.resolve(UserNotificationsManager.self)!
        _ = resolver.resolve(WatchManager.self)!
        _ = resolver.resolve(HealthKitManager.self)!
        _ = resolver.resolve(BluetoothStateManager.self)!
    }

    init() {
        debug(
            .default,
            "FreeAPS X Started: v\(Bundle.main.releaseVersionNumber ?? "")(\(Bundle.main.buildVersionNumber ?? "")) [buildDate: \(Bundle.main.buildDate)]"
        )
        loadServices()
    }

    var body: some Scene {
        WindowGroup {
            Main.RootView(resolver: resolver)
        }
        .onChange(of: scenePhase) { newScenePhase in
            debug(.default, "APPLICATION PHASE: \(newScenePhase)")
        }
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }

    var buildDate: Date {
        if let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
           let infoDate = infoAttr[.modificationDate] as? Date
        {
            return infoDate
        }
        return Date()
    }
}
