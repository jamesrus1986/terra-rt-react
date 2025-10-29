//
//  BLWidgetManager.swift
//  TerraRtReact
//
//  Created by Elliott Yu on 19/05/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation
import SwiftUI
import TerraRTiOS
import UIKit

@available(iOS 13.0, *)
@objc(BLWidget)
class BLWidget: UIView {
    private var hostingController: UIHostingController<TerraBLEWidget>?
    private var widgetContent: TerraBLEWidget?

    @objc var withCache: Bool = false {
        didSet {
            if oldValue != withCache {
                restartWidget()
            }
        }
    }

    @objc var onSuccessfulConnection: RCTDirectEventBlock?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            scheduleSetup()
        } else {
            tearDownWidget(animated: false)
        }
    }

    private func commonInit() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    private func restartWidget() {
        tearDownWidget(animated: false)
        scheduleSetup()
    }

    private func scheduleSetup(retryCount: Int = 0) {
        DispatchQueue.main.async { [weak self] in
            self?.setupWidgetIfPossible(retryCount: retryCount)
        }
    }

    private func setupWidgetIfPossible(retryCount: Int) {
        if hostingController != nil {
            return
        }

        guard let widget = makeWidgetContent() else {
            if retryCount < 5 {
                scheduleSetup(retryCount: retryCount + 1)
            }
            return
        }

        guard let presenter = findPresenter() else {
            if retryCount < 5 {
                scheduleSetup(retryCount: retryCount + 1)
            }
            return
        }

        let controller = UIHostingController(rootView: widget)
        controller.modalPresentationStyle = .automatic
        controller.modalTransitionStyle = .coverVertical
        controller.view.backgroundColor = .clear

        hostingController = controller
        presenter.present(controller, animated: true)
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
                self.tearDownWidget(animated: true)
            }
        }

        return widgetContent
    }

    private func tearDownWidget(animated: Bool) {
        guard let controller = hostingController else { return }

        hostingController = nil
        widgetContent = nil

        if controller.presentingViewController != nil {
            controller.dismiss(animated: animated)
        }
    }

    private func findPresenter() -> UIViewController? {
        if let parent = findParentViewController() {
            return topViewController(from: parent)
        }

        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive }
            for scene in scenes {
                if let root = scene.keyWindow?.rootViewController {
                    return topViewController(from: root)
                }
            }
        }

        if let root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            return topViewController(from: root)
        }

        return nil
    }

    private func topViewController(from controller: UIViewController) -> UIViewController {
        var candidate = controller
        while let presented = candidate.presentedViewController {
            candidate = presented
        }
        return candidate
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
        tearDownWidget(animated: false)
    }
}

@available(iOS 13.0, *)
@objc(BLWidgetManager)
class BLWidgetManager: RCTViewManager {
    override func view() -> UIView! {
        return BLWidget()
    }

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
}
