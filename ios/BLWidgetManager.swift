//
//  BLWidgetManager.swift
//  TerraRtReact
//
//  Created by Elliott Yu on 19/05/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation
import TerraRTiOS
import SwiftUI
import UIKit


@available(iOS 13.0, *)
@objc(BLWidget)
class BLWidget: UIView {
    private var hostingController: UIHostingController<TerraBLEWidget>?
    private var widgetContent: TerraBLEWidget?

    @objc var withCache: Bool = false {
        didSet {
            if oldValue != withCache {
                tearDownWidget()
                scheduleSetup()
            }
        }
    }

    @objc var onSuccessfulConnection: RCTDirectEventBlock?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            scheduleSetup()
        } else {
            tearDownWidget()
        }
    }

    private func commonInit() {
        backgroundColor = .clear
    }

    private func scheduleSetup() {
        DispatchQueue.main.async { [weak self] in
            self?.setupWidgetIfPossible()
        }
    }

    private func setupWidgetIfPossible(retryCount: Int = 0) {
        guard hostingController == nil else { return }
        guard let widget = makeWidgetContent() else {
            if retryCount < 5 {
                // Short retries give TerraRT time to finish initialising.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.setupWidgetIfPossible(retryCount: retryCount + 1)
                }
            }
            return
        }

        let controller = UIHostingController(rootView: widget)
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: topAnchor),
            controller.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            controller.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        if let parent = findParentViewController() {
            parent.addChild(controller)
            controller.didMove(toParent: parent)
        }

        hostingController = controller
    }

    private func makeWidgetContent() -> TerraBLEWidget? {
        guard let terraRT = TerraRtReact.terraRt else {
            return nil
        }

        widgetContent = terraRT.startBluetoothScan(
            type: .BLE,
            bluetoothLowEnergyFromCache: withCache
        ) { [weak self] success in
            guard let self = self else { return }
            if let callback = self.onSuccessfulConnection {
                callback(["success": success])
            }
            DispatchQueue.main.async {
                self.tearDownWidget()
            }
        }

        return widgetContent
    }

    private func tearDownWidget() {
    guard let controller = hostingController else { return }

        let parent = controller.parent
        if parent != nil {
            controller.willMove(toParent: nil)
        }
        controller.view.removeFromSuperview()
        if let parent = parent {
            controller.removeFromParent()
            parent.view.setNeedsLayout()
        }

        hostingController = nil
        widgetContent = nil
    }

    private func findParentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let viewController = next as? UIViewController {
                return viewController
            }
            responder = next
        }
        return nil
    }

    deinit {
        tearDownWidget()
    }
}

@available(iOS 13.0, *)
@objc(BLWidgetManager)
class BLWidgetManager: RCTViewManager {
    
    override func view() -> UIView!{
        return BLWidget()
    }

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
}
