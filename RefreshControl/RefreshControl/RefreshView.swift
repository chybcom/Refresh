//
//  RefreshView.swift
//  17- 刷新控件
//
//  Created by apple on 2019/2/15.
//  Copyright © 2019年 apple. All rights reserved.
//

import UIKit

enum RefreshStatus {
    /** 普通状态 */
    case normal
    
    /** 下拉到临界点 */
    case pulling
    
    /** 即将刷新状态 */
    case willRefresh
}


// 刷新视图负责刷新相关的UI显示和动画
// 而 RefreshControl 负责刷新的逻辑相关处理，比如控件RefreshView刷新视图
class RefreshView: UIView {

    /**
     iOS系统中的 UIView 封装的旋转动画
     - 默认是顺时针旋转
     - 就近原则
     - 要想实现同方向旋转，需要调整一个非常小的数值，为了（就近原则）回转
     - 如果想要实现 360 度旋转，需要核心动画 CABaseAnimation实现
     */
    
    var refreshStatus: RefreshStatus = .normal
    {
        
        didSet
        {
            
            switch refreshStatus
            {
            case .normal:
                
                tipImageView?.isHidden = false // 恢复简头图标
                indicator?.stopAnimating()     // 停止指示器动画，就隐藏指示器
                tipTitleLabel?.text = "继续使劲拉..."
                UIView.animate(withDuration: 0.25) {
                    self.tipImageView?.transform = CGAffineTransform.identity
                }
            case .pulling:
                tipTitleLabel?.text = "放手就刷新..."
                /**  Swift 3.0  M_PI已被弃用,使用 Double.pi 弧度 180度 */
                UIView.animate(withDuration: 0.25) {
                    self.tipImageView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi + 0.001))
                }
            case .willRefresh:
                tipTitleLabel?.text = "正在刷新中..."
                tipImageView?.isHidden = true // 隐藏箭头
                // 指示器之前在xib中，勾选了 Hides When Stopped ，隐藏的时候停止
                // startAnimating 开启动画就显示出
                indicator?.startAnimating()
            }
            
        }
    }
    
    
    /// 父视图的高  定义这个属性是为了，刷新控件不用关心当前控件是谁 ，多的这一层传值是为了解耦
    var parentHeight: CGFloat = 0
    
    
    // 改成 ? 是因为 RefreshMeitanView 这个xib 可能没有这些控件

    @IBOutlet weak var tipImageView: UIImageView?
    
    @IBOutlet weak var tipTitleLabel: UILabel?
    
    @IBOutlet weak var indicator: UIActivityIndicatorView?
    
    
    class func refreshView() -> RefreshView {
//        let nib = UINib(nibName: "RefreshView", bundle: Bundle.main)       // 箭头刷新
//        let nib = UINib(nibName: "RefreshPersonView", bundle: Bundle.main)   // 拉小人刷新
        let nib = UINib(nibName: "RefreshMeitanView", bundle: Bundle.main)   // 美团刷新
        
        return nib.instantiate(withOwner: nil, options: nil).first as! RefreshView
    }
    
}
