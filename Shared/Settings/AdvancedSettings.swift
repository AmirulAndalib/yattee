import Defaults
import SwiftUI

struct AdvancedSettings: View {
    @Default(.showMPVPlaybackStats) private var showMPVPlaybackStats
    @Default(.mpvCacheSecs) private var mpvCacheSecs
    @Default(.mpvCachePauseWait) private var mpvCachePauseWait
    @Default(.mpvDeinterlace) private var mpvDeinterlace
    @Default(.mpvEnableLogging) private var mpvEnableLogging
    @Default(.showCacheStatus) private var showCacheStatus
    @Default(.feedCacheSize) private var feedCacheSize
    @Default(.showPlayNowInBackendContextMenu) private var showPlayNowInBackendContextMenu

    @State private var filesToShare = [MPVClient.logFile]
    @State private var presentingShareSheet = false

    private var settings = SettingsModel.shared

    var body: some View {
        VStack(alignment: .leading) {
            #if os(macOS)
                advancedSettings
                Spacer()
            #else
                List {
                    advancedSettings
                }
                #if os(iOS)
                .sheet(isPresented: $presentingShareSheet) {
                    ShareSheet(activityItems: filesToShare)
                        .id("logs-\(filesToShare.count)")
                }
                .listStyle(.insetGrouped)
                #endif
            #endif
        }
        #if os(tvOS)
        .frame(maxWidth: 1000)
        #endif
        .navigationTitle("Advanced")
    }

    var logButton: some View {
        Button {
            #if os(macOS)
                NSWorkspace.shared.selectFile(MPVClient.logFile.path, inFileViewerRootedAtPath: YatteeApp.logsDirectory.path)
            #else
                presentingShareSheet = true
            #endif
        } label: {
            #if os(macOS)
                let labelText = "Open logs in Finder".localized()
            #else
                let labelText = "Share Logs...".localized()
            #endif
            Text(labelText)
        }
    }

    @ViewBuilder var advancedSettings: some View {
        Section(header: SettingsHeader(text: "Advanced")) {
            showPlayNowInBackendButtonsToggle
        }

        Section(header: SettingsHeader(text: "MPV"), footer: mpvFooter) {
            showMPVPlaybackStatsToggle
            #if !os(tvOS)
                mpvEnableLoggingToggle
            #endif

            HStack {
                Text("cache-secs")
                    .frame(minWidth: 140, alignment: .leading)
                TextField("cache-secs", text: $mpvCacheSecs)
                #if !os(macOS)
                    .keyboardType(.numberPad)
                #endif
            }
            .multilineTextAlignment(.trailing)

            HStack {
                Text("cache-pause-wait")
                    .frame(minWidth: 140, alignment: .leading)
                TextField("cache-pause-wait", text: $mpvCachePauseWait)
                #if !os(macOS)
                    .keyboardType(.numberPad)
                #endif
            }
            .multilineTextAlignment(.trailing)

            Toggle("deinterlace", isOn: $mpvDeinterlace)

            if mpvEnableLogging {
                logButton
            }
        }

        Section(header: SettingsHeader(text: "Cache"), footer: cacheSize) {
            showCacheStatusToggle
            feedCacheSizeTextField
            clearCacheButton
        }
    }

    @ViewBuilder var mpvFooter: some View {
        let url = "https://mpv.io/manual/master"

        VStack(alignment: .leading) {
            Text("Restart the app to apply the settings above.")
            VStack(alignment: .leading, spacing: 2) {
                #if os(tvOS)
                    Text("More info can be found in MPV Documentation:")
                    Text(url)
                #else
                    Text("More info can be found in:")
                    Link("MPV Documentation", destination: URL(string: url)!)
                    #if os(macOS)
                        .onHover(perform: onHover(_:))
                    #endif
                #endif
            }
        }
        .foregroundColor(.secondary)
    }

    var showPlayNowInBackendButtonsToggle: some View {
        Toggle("Show video context menu options to force selected backend", isOn: $showPlayNowInBackendContextMenu)
    }

    var showMPVPlaybackStatsToggle: some View {
        Toggle("Show playback statistics", isOn: $showMPVPlaybackStats)
    }

    var mpvEnableLoggingToggle: some View {
        Toggle("Enable logging", isOn: $mpvEnableLogging)
    }

    #if os(macOS)
        private func onHover(_ inside: Bool) {
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    #endif

    private var feedCacheSizeTextField: some View {
        HStack {
            Text("Maximum feed items")
                .frame(minWidth: 200, alignment: .leading)
                .multilineTextAlignment(.leading)
            TextField("Limit", text: $feedCacheSize)
                .multilineTextAlignment(.trailing)
            #if !os(macOS)
                .keyboardType(.numberPad)
            #endif
        }
    }

    private var showCacheStatusToggle: some View {
        Toggle("Show cache status", isOn: $showCacheStatus)
    }

    private var clearCacheButton: some View {
        Button {
            settings.presentAlert(
                Alert(
                    title: Text(
                        "Are you sure you want to clear cache?"
                    ),
                    primaryButton: .destructive(Text("Clear"), action: BaseCacheModel.shared.clear),
                    secondaryButton: .cancel()
                )
            )
        } label: {
            Text("Clear all")
                .foregroundColor(.red)
        }
    }

    var cacheSize: some View {
        Text(String(format: "Total size: %@".localized(), BaseCacheModel.shared.totalSizeFormatted))
            .foregroundColor(.secondary)
    }
}

struct AdvancedSettings_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettings()
            .injectFixtureEnvironmentObjects()
    }
}
