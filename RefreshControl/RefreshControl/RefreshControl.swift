//
//  RefreshControl.swift
//  17- 刷新控件
//
//  Created by apple on 2019/2/14.
//  Copyright © 2019年 apple. All rights reserved.
//


import UIKit

///// 设置一个拖拽的临界点
//private let maxOffset: CGFloat = 60

/// 设置一个拖拽的临界点 (美团刷新用)
private let maxOffset: CGFloat = 126

class RefreshControl: UIControl {

    /// 懒加载 RefreshView 属性
    lazy var refreshView = RefreshView.refreshView()
    
    // 属性 为 UITableView UICollectionView 父类，当控件是这两个子类的时候都可以使用
    private weak var scrollView: UIScrollView?
    
    // 构造函数
    init() {
        super.init(frame: CGRect())
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // fatalError("init(coder:) has not been implemented") 
        super.init(coder: aDecoder)
        setupUI()
    }
    
    
    
    func setupUI() -> () {
        
        backgroundColor = superview?.backgroundColor
//        clipsToBounds = true
        
        // 把 refreshView 添加到 当前的 refreshControl 上
        addSubview(refreshView)
        
        // 取消 refreshView 的 Autoresizing
        refreshView.translatesAutoresizingMaskIntoConstraints = false

        // 苹果原生自动布局
        addConstraint(NSLayoutConstraint.init(item: refreshView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))

        addConstraint(NSLayoutConstraint.init(item: refreshView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))

        addConstraint(NSLayoutConstraint.init(item: refreshView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: refreshView.bounds.width))

        addConstraint(NSLayoutConstraint.init(item: refreshView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: refreshView.bounds.height))
    }
    
    
    
    
    /** 当前控件self 添别的控制添加父控件上时，调用 addSubView 时会调用些方法 willMove
        - 当添加到父视图的时候，newSuperview 是父视图
        - 当父视图移除时， newSuperview 是父视图 为 nil
     */
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard let sc = newSuperview as? UIScrollView else {
            return
        }
        
        // 记录 ScrollView
        scrollView = sc
        
        // 监听谁的属性，就由谁addObserver 添加监听者，KVO 监听父视图的 contentOffset
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [], context: nil)
    }
    
    override func removeFromSuperview() {
        // 在调用 super.removeFromSuperview() 之前 superview 还在, 在调用 super.removeFromSuperview() 之后 superview 为 nil
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        super.removeFromSuperview()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
//        print(scrollView?.contentOffset ?? CGPoint())
        guard let sv = scrollView else {
            return
        }
        
        // 初始高度应该是0
        var height = -(sv.contentInset.top + sv.contentOffset.y)
        height = (height == -0.0) ? 0.0 : -(sv.contentInset.top + sv.contentOffset.y)
        
        print("observeValue中的高\(height)    contentInset_top\(-sv.contentOffset.y)")
        
        //解决刷新中袋鼠变小办法一： 如果是正在刷新中，就不需要传递高度，因为如果正在刷新中传了高度就会导至袋鼠会有时会缩小
        if refreshView.refreshStatus != .willRefresh{
            // 把高度传给子视图 RefreshView 的属性 parentHeight
            //这里如果直传高会，如果下拉得很快袋鼠图片缩小了，因为height 为0
            refreshView.parentHeight = height;
        }

        self.frame = CGRect(x: 0, y: -height, width: scrollView?.bounds.width ?? 0, height: height)
    
        if sv.isDragging { // 正在拖拽时分支
            
//            case .normal:
//            tipTitleLabel.text = "继续使劲拉..."
//            case .pulling:
//            tipTitleLabel.text = "放手就刷新..."
//            case .willRefresh:
//            tipTitleLabel.text = "正在刷新中..."

            if height > maxOffset && (refreshView.refreshStatus == .normal) {
                refreshView.refreshStatus = .pulling
                print("+++放手立即刷新")
            }else if height <= maxOffset && (refreshView.refreshStatus == .pulling) {
                refreshView.refreshStatus = .normal
                print("+++继续使劲拉")
            }


        }else{ // 停止拖拽时分支
            
            if height == 0.0 {
                return
            }
            
            if refreshView.refreshStatus == .pulling {
                
                print("执行刷新")
                // 手动开始刷新 (不带动画)
                manualBeginRefreshing()
                
                // 发送刷新数据事件
                self.sendActions(for: .valueChanged)
            }
            

        }

    }

    
    
    
    /// 开始刷新 (带动画)
    func beginRefreshing() {
        
        // 如果正在刷新，就返回
        if refreshView.refreshStatus == .willRefresh {
            return
        }
        
        // 守护一下 弱引用  scrollView ，因为可能已经释放
        guard let sv = scrollView else {
            return
        }
        
        // 更改状态
        refreshView.refreshStatus = .willRefresh
        
        
        // 如果是一进页面主动刷新执行动画，如果是手动下拉就不执行动画
        UIView.animate(withDuration: 0.5) {
        
            // 更改表格inset
            var inset = sv.contentInset
            inset.top += maxOffset
            
            //下拉停止后表格上面的间距
            sv.contentInset = inset
        }

        // 为了设置给refreshView的属性parentHeight设置高度，RefreshMeitanView中进行缩放计算
        refreshView.parentHeight = maxOffset
    }
    
    
    /// 手动开始刷新 (不带动画)
    func manualBeginRefreshing() {

        if refreshView.refreshStatus == .willRefresh {
            return
        }

        guard let sv = scrollView else {
            return
        }

        refreshView.refreshStatus = .willRefresh

        // 更改表格inset
        var inset = sv.contentInset
        inset.top += maxOffset
        
        //下拉停止后表格上面的间距
        sv.contentInset = inset
        
        // 为了设置给refreshView的属性parentHeight设置高度，RefreshMeitanView中进行缩放计算
        refreshView.parentHeight = maxOffset
    }
    
    
    /// 结束刷新
    func endRefreshing() {
        
        // 守护一下 弱引用  scrollView ，因为可能已经释放
        guard let sv = scrollView else {
            return
        }
        
        // 判断是否正在刷新状态 .willRefresh，如果不是直接返回
        if refreshView.refreshStatus != .willRefresh {
            return
        }
        
        // 更改状态
        refreshView.refreshStatus = .normal
        
        UIView.animate(withDuration: 0.5) {
            // 更改表格inset,
            var inset = sv.contentInset
            inset.top -= maxOffset
            sv.contentInset = inset
        }
    }
    
}
