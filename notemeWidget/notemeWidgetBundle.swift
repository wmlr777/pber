//
//  notemeWidgetBundle.swift
//  notemeWidget
//
//  Created by wenmo on 2026/4/10.
//

import WidgetKit
import SwiftUI

@main
struct notemeWidgetBundle: WidgetBundle {
    var body: some Widget {
        notemeWidget()
        notemeWidgetControl()
        notemeWidgetLiveActivity()
    }
}
