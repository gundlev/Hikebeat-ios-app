//
//  HikebeatWalkthroughFramework.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 12/11/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Protocols -


/// Walkthrough Delegate:
/// This delegate performs basic operations such as dismissing the Walkthrough or call whatever action on page change.
/// Probably the Walkthrough is presented by this delegate.
@objc public protocol HikebeatWalkthroughViewControllerDelegate{
    
    @objc optional func walkthroughCloseButtonPressed()              // If the skipRequest(sender:) action is connected to a button, this function is called when that button is pressed.
    @objc optional func walkthroughNextButtonPressed()               // Called when the "next page" button is pressed
    @objc optional func walkthroughPrevButtonPressed()               // Called when the "previous page" button is pressed
    @objc optional func walkthroughPageDidChange(_ pageNumber:Int)   // Called when current page changes
}


/// Walkthrough Page:
/// The walkthrough page represents any page added to the Walkthrough.
@objc public protocol HikebeatWalkthroughPage{
    /// While sliding to the "next" slide (from right to left), the "current" slide changes its offset from 1.0 to 2.0 while the "next" slide changes it from 0.0 to 1.0
    /// While sliding to the "previous" slide (left to right), the current slide changes its offset from 1.0 to 0.0 while the "previous" slide changes it from 2.0 to 1.0
    /// The other pages update their offsets whith values like 2.0, 3.0, -2.0... depending on their positions and on the status of the walkthrough
    /// This value can be used on the previous, current and next page to perform custom animations on page's subviews.
    @objc func walkthroughDidScroll(to:CGFloat, offset:CGFloat)   // Called when the main Scrollview...scrolls
}


@objc open class HikebeatWalkthroughViewController: UIViewController, UIScrollViewDelegate{
    
    // MARK: - Public properties -
    
    weak open var delegate:HikebeatWalkthroughViewControllerDelegate?
    var shouldAutoSlideshow: Bool = true
    var slideshowTimer : Timer?
    
    // If you need a page control, next or prev buttons, add them via IB and connect with these Outlets
    @IBOutlet open var pageControl:UIPageControl?
    @IBOutlet open var nextButton:UIButton?
    @IBOutlet open var prevButton:UIButton?
    @IBOutlet open var closeButton:UIButton?
    
    open var currentPage: Int {    // The index of the current page (readonly)
        get{
            let page = Int((scrollview.contentOffset.x / view.bounds.size.width))
            return page
        }
    }
    
    open var currentViewController:UIViewController{ //the controller for the currently visible page
        get{
            let currentPage = self.currentPage;
            return controllers[currentPage];
        }
    }
    
    open var numberOfPages:Int{ //the total number of pages in the walkthrough
        get {
            return self.controllers.count
        }
    }
    
    
    // MARK: - Private properties -
    
    open let scrollview = UIScrollView()
    private var controllers = [UIViewController]()
    private var lastViewConstraint: [NSLayoutConstraint]?
    
    
    // MARK: - Overrides -
    
    required public init?(coder aDecoder: NSCoder) {
        // Setup the scrollview
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.showsVerticalScrollIndicator = false
        scrollview.isPagingEnabled = true
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Scrollview
        
        scrollview.delegate = self
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        scrollview.bounces = false
        
        view.insertSubview(scrollview, at: 0) //scrollview is inserted as first view of the hierarchy
        
        // Set scrollview related constraints
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[scrollview]-0-|", options:[], metrics: nil, views: ["scrollview":scrollview] as [String: UIView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[scrollview]-0-|", options:[], metrics: nil, views: ["scrollview":scrollview] as [String: UIView]))
        
        pageControl?.numberOfPages = controllers.count-1
        pageControl?.currentPage = 0
        
        if shouldAutoSlideshow {
            startSlideshowTimer()
        }
    }
    
    
    func startSlideshowTimer()
    {
        if slideshowTimer == nil {
            slideshowTimer = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(HikebeatWalkthroughViewController.slideshowAction), userInfo: nil, repeats: true)
        }
    }
    
    func stopSlideshowTimer()
    {
        if slideshowTimer != nil {
            slideshowTimer!.invalidate()
            slideshowTimer = nil
        }
    }
    
    func slideshowAction() {
        if currentPage==controllers.count-2 {
            restartSlideshow()
        } else {
            nextPage()
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        updateUI()
    }
    
    
    // MARK: - Internal methods -
    
    @IBAction open func nextPage(){
        if (currentPage + 1) < controllers.count {
            
            delegate?.walkthroughNextButtonPressed?()
            gotoPage(currentPage + 1)
        }
    }
    
    @IBAction open func prevPage(){
        if currentPage > 0 {
            
            delegate?.walkthroughPrevButtonPressed?()
            gotoPage(currentPage - 1)
        }
    }
    
    /// If you want to implement a "skip" button
    /// connect the button to this IBAction and implement the delegate with the skipWalkthrough
    @IBAction open func close(_ sender: AnyObject) {
        delegate?.walkthroughCloseButtonPressed?()
    }
    
    fileprivate func gotoPage(_ page:Int){
        let animated = currentPage != controllers.count-1
        
        if page < controllers.count{
            let toPage = !animated ? 0 : page
            var frame = scrollview.frame
            frame.origin.x = CGFloat(toPage) * frame.size.width
            scrollview.scrollRectToVisible(frame, animated: animated)
        }
    }
    
    fileprivate func restartSlideshow(){
        var frame = scrollview.frame
        frame.origin.x = CGFloat(controllers.count-1) * frame.size.width
        scrollview.scrollRectToVisible(frame, animated: true)
        
        let when = DispatchTime.now() + 0.3
        DispatchQueue.main.asyncAfter(deadline: when) {
            var frame2 = self.scrollview.frame
            frame2.origin.x = CGFloat(0) * frame2.size.width
            self.scrollview.scrollRectToVisible(frame2, animated: false)
            self.pageControl?.currentPage = 0
        }
    }

    
    /// Add a new page to the walkthrough.
    /// To have information about the current position of the page in the walkthrough add a UIVIewController which implements HikebeatWalkthroughPage
    /// - viewController: The view controller that will be added at the end of the view controllers list.
    open func add(viewController:UIViewController)->Void{
        
        controllers.append(viewController)
        
        // Setup the viewController view
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        scrollview.addSubview(viewController.view)
        
        // Constraints
        
        let metricDict = ["w":viewController.view.bounds.size.width,"h":viewController.view.bounds.size.height]
        
        // Generic cnst
        let viewsDict: [String: UIView] = ["view":viewController.view, "container": scrollview]
        
        scrollview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view(==container)]", options:[], metrics: metricDict, views: viewsDict))
        scrollview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view(==container)]", options:[], metrics: metricDict, views: viewsDict))
        scrollview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]|", options:[], metrics: nil, views: viewsDict))
        
        // cnst for position: 1st element
        if controllers.count == 1{
            scrollview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]", options:[], metrics: nil, views: ["view":viewController.view]))
            
            // cnst for position: other elements
        } else {
            
            let previousVC = controllers[controllers.count-2]
            if let previousView = previousVC.view {
                // For this constraint to work, previousView can not be optional
                scrollview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[previousView]-0-[view]", options:[], metrics: nil, views: ["previousView":previousView,"view":viewController.view]))
            }
            
            if let cst = lastViewConstraint {
                scrollview.removeConstraints(cst)
            }
            lastViewConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:[view]-0-|", options:[], metrics: nil, views: ["view":viewController.view])
            scrollview.addConstraints(lastViewConstraint!)
        }
    }
    
    /// Update the UI to reflect the current walkthrough status
    public func updateUI(){
        
        pageControl?.currentPage = currentPage
        delegate?.walkthroughPageDidChange?(currentPage)
        
        // Hide/Show navigation buttons
        if currentPage == controllers.count - 1{
            nextButton?.isHidden = true
        }else{
            nextButton?.isHidden = false
        }
        
        if currentPage == 0{
            prevButton?.isHidden = true
        }else{
            prevButton?.isHidden = false
        }
    }
    
    // MARK: - Scrollview Delegate -
    
    open func scrollViewDidScroll(_ sv: UIScrollView) {
        
        for i in 0 ..< controllers.count {
            
            if let vc = controllers[i] as? HikebeatWalkthroughPage{
                
                let mx = ((scrollview.contentOffset.x + view.bounds.size.width) - (view.bounds.size.width * CGFloat(i))) / view.bounds.size.width
                
                // While sliding to the "next" slide (from right to left), the "current" slide changes its offset from 1.0 to 2.0 while the "next" slide changes it from 0.0 to 1.0
                // While sliding to the "previous" slide (left to right), the current slide changes its offset from 1.0 to 0.0 while the "previous" slide changes it from 2.0 to 1.0
                // The other pages update their offsets whith values like 2.0, 3.0, -2.0... depending on their positions and on the status of the walkthrough
                // This value can be used on the previous, current and next page to perform custom animations on page's subviews.
                
                // print the mx value to get more info.
                // println("\(i):\(mx)")
                
                // We animate only the previous, current and next page
                if(mx < 2 && mx > -2.0){
                    vc.walkthroughDidScroll(to:scrollview.contentOffset.x, offset: mx)
                }
            }
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopSlideshowTimer()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startSlideshowTimer()
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if currentPage==controllers.count-1 {
            gotoPage(0)
        }
        
        updateUI()
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateUI()
    }
    
    fileprivate func adjustOffsetForTransition() {
        
        // Get the current page before the transition occurs, otherwise the new size of content will change the index
        let currentPage = self.currentPage
        
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * 0.1 )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            [weak self] in
            self?.gotoPage(currentPage)
        }
    }
    
    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        adjustOffsetForTransition()
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        adjustOffsetForTransition()
    }
    
}


public enum WalkthroughAnimationType:String{
    case Linear = "Linear"
    case Curve = "Curve"
    case Zoom = "Zoom"
    case InOut = "InOut"
    
    init(_ name:String){
        
        if let tempSelf = WalkthroughAnimationType(rawValue: name){
            self = tempSelf
        }else{
            self = .Linear
        }
    }
}

open class HikebeatWalkthroughPageViewController: UIViewController, HikebeatWalkthroughPage {
    
    private var animation:WalkthroughAnimationType = .Linear
    private var subviewsSpeed:[CGPoint] = Array()
    private var notAnimatableViews:[Int] = [] // Array of views' tags that should not be animated during the scroll/transition
    
    // MARK: Inspectable Properties
    // Edit these values using the Attribute inspector or modify directly the "User defined runtime attributes" in IB
    @IBInspectable var speed:CGPoint = CGPoint(x: 0.0, y: 0.0);            // Note if you set this value via Attribute inspector it can only be an Integer (change it manually via User defined runtime attribute if you need a Float)
    @IBInspectable var speedVariance:CGPoint = CGPoint(x: 0.0, y: 0.0)     // Note if you set this value via Attribute inspector it can only be an Integer (change it manually via User defined runtime attribute if you need a Float)
    @IBInspectable var animationType:String {
        set(value){
            self.animation = WalkthroughAnimationType(rawValue: value)!
        }
        get{
            return self.animation.rawValue
        }
    }
    @IBInspectable var animateAlpha:Bool = false
    @IBInspectable var staticTags:String {                                 // A comma separated list of tags that you don't want to animate during the transition/scroll
        set(value){
            self.notAnimatableViews = value.components(separatedBy: ",").map{Int($0)!}
        }
        get{
            return notAnimatableViews.map{String($0)}.joined(separator: ",")
        }
    }
    
    // MARK: HikebeatWalkthroughPage Implementation
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.masksToBounds = true
        subviewsSpeed = Array()
        
        for v in view.subviews{
            speed.x += speedVariance.x
            speed.y += speedVariance.y
            if !notAnimatableViews.contains(v.tag) {
                subviewsSpeed.append(speed)
            }
        }
    }
    
    open func walkthroughDidScroll(to: CGFloat, offset: CGFloat) {
        
        for i in 0 ..< subviewsSpeed.count{
            
            // Perform animations
            switch animation{
                
            case .Linear:
                animationLinear(i, offset)
                
            case .Zoom:
                animationZoom(i, offset)
                
            case .Curve:
                animationCurve(i, offset)
                
            case .InOut:
                animationInOut(i, offset)
            }
            
            // Animate alpha
            if(animateAlpha){
                animationAlpha(i, offset)
            }
        }
    }
    
    // MARK: Animations
    
    private func animationAlpha(_ index:Int, _ offset:CGFloat) {
        let cView = view.subviews[index]
        var mutableOffset = offset
        if(mutableOffset > 1.0){
            mutableOffset = 1.0 + (1.0 - mutableOffset)
        }
        cView.alpha = (mutableOffset)
    }
    
    private func animationCurve(_ index:Int, _ offset:CGFloat) {
        var transform = CATransform3DIdentity
        let x:CGFloat = (1.0 - offset) * 10
        transform = CATransform3DTranslate(transform, (pow(x,3) - (x * 25)) * subviewsSpeed[index].x, (pow(x,3) - (x * 20)) * subviewsSpeed[index].y, 0 )
        applyTransform(index, transform: transform)
    }
    
    private func animationZoom(_ index:Int, _ offset:CGFloat){
        var transform = CATransform3DIdentity
        
        var tmpOffset = offset
        if(tmpOffset > 1.0){
            tmpOffset = 1.0 + (1.0 - tmpOffset)
        }
        let scale:CGFloat = (1.0 - tmpOffset)
        transform = CATransform3DScale(transform, 1 - scale , 1 - scale, 1.0)
        applyTransform(index, transform: transform)
    }
    
    private func animationLinear(_ index:Int, _ offset:CGFloat) {
        var transform = CATransform3DIdentity
        let mx:CGFloat = (1.0 - offset) * 100
        transform = CATransform3DTranslate(transform, mx * subviewsSpeed[index].x, mx * subviewsSpeed[index].y, 0 )
        applyTransform(index, transform: transform)
    }
    
    private func animationInOut(_ index:Int, _ offset:CGFloat) {
        var transform = CATransform3DIdentity
        
        var tmpOffset = offset
        if(tmpOffset > 1.0){
            tmpOffset = 1.0 + (1.0 - tmpOffset)
        }
        transform = CATransform3DTranslate(transform, (1.0 - tmpOffset) * subviewsSpeed[index].x * 100, (1.0 - tmpOffset) * subviewsSpeed[index].y * 100, 0)
        applyTransform(index, transform: transform)
    }
    
    private func applyTransform(_ index:Int, transform:CATransform3D){
        let subview = view.subviews[index]
        if !notAnimatableViews.contains(subview.tag){
            view.subviews[index].layer.transform = transform
        }
    }
}
