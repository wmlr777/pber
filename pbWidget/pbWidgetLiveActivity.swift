//
//  pbWidgetLiveActivity.swift
//  pbWidget
//
//  Created by wenmo on 2026/4/10.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct pbWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct pbWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: pbWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension pbWidgetAttributes {
    fileprivate static var preview: pbWidgetAttributes {
        pbWidgetAttributes(name: "World")
    }
}

extension pbWidgetAttributes.ContentState {
    fileprivate static var smiley: pbWidgetAttributes.ContentState {
        pbWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: pbWidgetAttributes.ContentState {
         pbWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: pbWidgetAttributes.preview) {
   pbWidgetLiveActivity()
} contentStates: {
    pbWidgetAttributes.ContentState.smiley
    pbWidgetAttributes.ContentState.starEyes
}
