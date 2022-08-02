//
//  CustomNSViewController.swift
//  Vinux.app (macOS)
//
//  Created by git on 8/1/22.
//

import AppKit

public class NavigationController: NSViewController {

   public private (set) var viewControllers: [NSViewController] = []

   open override func loadView() {
      view = NSView()
      view.wantsLayer = true
   }

   public init(rootViewController: NSViewController) {
      super.init(nibName: nil, bundle: nil)
      pushViewController(rootViewController, animated: false)
   }

   public required init?(coder: NSCoder) {
      fatalError()
   }
}

extension NavigationController {

   public var topViewController: NSViewController? {
      return viewControllers.last
   }

   public func pushViewControllerAnimated(_ viewController: NSViewController) {
      pushViewController(viewController, animated: true)
   }

   public func pushViewController(_ viewController: NSViewController, animated: Bool) {
      // viewController.navigationController = self
      viewController.view.wantsLayer = true
      if animated, let oldVC = topViewController {
         insertChild(viewController, at: 0)
         let endFrame = oldVC.view.frame
         let startFrame = endFrame.offsetBy(dx: endFrame.width, dy: 0)
         viewController.view.frame = startFrame
         viewController.view.alphaValue = 0.85
         viewControllers.append(viewController)
         NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            //context.timingFunction = .easeOut
            viewController.view.animator().frame = endFrame
            viewController.view.animator().alphaValue = 1
            oldVC.view.animator().alphaValue = 0.25
         }) {
            oldVC.view.alphaValue = 1
            oldVC.view.removeFromSuperview()
         }
      } else {
         insertChild(viewController, at: 0)
         viewControllers.append(viewController)
      }
   }

   @discardableResult
   public func popViewControllerAnimated() -> NSViewController? {
      return popViewController(animated: true)
   }

   @discardableResult
   public func popViewController(animated: Bool) -> NSViewController? {
      guard let oldVC = viewControllers.popLast() else {
         return nil
      }

      if animated, let newVC = topViewController {
         let endFrame = oldVC.view.frame.offsetBy(dx: oldVC.view.frame.width, dy: 0)
         view.addSubview(newVC.view, positioned: .below, relativeTo: oldVC.view)
         NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.23
            context.allowsImplicitAnimation = true
            // context.timingFunction = .easeIn
            oldVC.view.animator().frame = endFrame
            oldVC.view.animator().alphaValue = 0.85
         }) {
            self.unembedChildViewController(oldVC)
            // self.removeChild(at: 0)

         }
      } else {
         unembedChildViewController(oldVC)
         // self.removeChild(at: 0)
      }
      return oldVC
   }

}

extension NSViewController {

   private struct OBJCAssociationKey {
      static var navigationController = "com.mc.navigationController"
   }

   public var navigationController: NavigationController? {
      get {
         return ObjCAssociation.value(from: self, forKey: &OBJCAssociationKey.navigationController)
      } set {
         ObjCAssociation.setAssign(value: newValue, to: self, forKey: &OBJCAssociationKey.navigationController)
      }
   }
}

extension NSViewController {

   public func embedChildViewController(_ vc: NSViewController, container: NSView? = nil) {
      addChild(vc)
      vc.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
      vc.view.autoresizingMask = [.height, .width]
      (container ?? view).addSubview(vc.view)
   }

   public func unembedChildViewController(_ vc: NSViewController) {
      vc.view.removeFromSuperview()
      vc.removeFromParent()
   }
}

struct ObjCAssociation {

   static func value<T>(from object: AnyObject, forKey key: UnsafeRawPointer) -> T? {
      return objc_getAssociatedObject(object, key) as? T
   }

   static func setAssign<T>(value: T?, to object: Any, forKey key: UnsafeRawPointer) {
      objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_ASSIGN)
   }

   static func setRetainNonAtomic<T>(value: T?, to object: Any, forKey key: UnsafeRawPointer) {
      objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
   }

   static func setCopyNonAtomic<T>(value: T?, to object: Any, forKey key: UnsafeRawPointer) {
      objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_COPY_NONATOMIC)
   }

   static func setRetain<T>(value: T?, to object: Any, forKey key: UnsafeRawPointer) {
      objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN)
   }

   static func setCopy<T>(value: T?, to object: Any, forKey key: UnsafeRawPointer) {
      objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_COPY)
   }
}
