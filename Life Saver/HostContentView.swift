import LifeSaverCore
import SwiftUI

struct HostContentView: View {
    @StateObject private var model = ConfigurationModel()

    var body: some View {
        HSplitView {
            LifeConfigurationView(model: model)
                .frame(minWidth: 380, idealWidth: 420, maxWidth: 520)
            LifeScenePreview(manager: model.manager)
                .frame(minWidth: 400, minHeight: 360)
                .background(Color.black)
        }
        .frame(minWidth: 900, minHeight: 620)
    }
}
