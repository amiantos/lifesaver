import LifeSaverCore
import SwiftUI

struct HostContentView: View {
    @StateObject private var model = ConfigurationModel()

    var body: some View {
        HSplitView {
            LifeConfigurationView(model: model)
                .frame(minWidth: 380, idealWidth: 440, maxWidth: 560)
            ZStack {
                Color.black
                LifeScenePreview(model: model)
                PreviewOverlay(model: model)
            }
            .frame(minWidth: 460, minHeight: 380)
        }
        .frame(minWidth: 960, minHeight: 660)
    }
}
