//
//  UIButton.swift
//  BottomSheet
//
//  Created by Артем Павлов on 02.11.2023.
//

import UIKit

extension UIButton {
  private final class ButtonAdapter {
    let handler: () -> Void
    let controlEvent: UIControl.Event

    init(handler: @escaping () -> Void, controlEvent: UIControl.Event) {
      self.handler = handler
      self.controlEvent = controlEvent
    }

    @objc
    func handle() {
      handler()
    }
  }

  static private var key: UInt8 = 0

  private var adapters: [ButtonAdapter] {
    get {
      objc_getAssociatedObject(self, &Self.key) as? [ButtonAdapter] ?? []
    }
    set {
      objc_setAssociatedObject(self, &Self.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  convenience init(buttonAction: ButtonAction) {
    self.init(frame: .zero)

    backgroundColor = buttonAction.backgroundColor
    setTitle(buttonAction.title, for: .normal)
    addEventHandler(handler: buttonAction.handler, controlEvent: .touchUpInside)
  }

  func addEventHandler(handler: @escaping () -> Void, controlEvent: UIControl.Event) {
    let adapter = ButtonAdapter(handler: handler, controlEvent: controlEvent)
    addTarget(adapter, action: #selector(ButtonAdapter.handle), for: controlEvent)
    adapters.append(adapter)
  }
}
