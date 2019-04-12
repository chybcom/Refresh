//
//  RefreshMeitanView.swift
//  17- 刷新控件
//
//  Created by apple on 2019/2/14.
//  Copyright © 2019年 apple. All rights reserved.
//

import UIKit

class RefreshMeitanView: RefreshView {
    
    // 重写父类的 parentHeight 属性
    override var parentHeight: CGFloat{
        
        didSet{
            
            // 只有在父视图的高度为 25至 126时，才计算绽放比例值，进行袋鼠缩放
            if parentHeight < 25 || parentHeight > 126{
                return
            }
            
            let scale = 1 - ((126 - parentHeight) / (126 - 25))

            // 设置袋鼠 transform 缩放
            kangarooIconView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    
    /// 城市图片
    @IBOutlet weak var buildingIconView: UIImageView!
    
    /// 袋鼠图片
    @IBOutlet weak var kangarooIconView: UIImageView!
    
    /// 地球图片
    @IBOutlet weak var earthIconView: UIImageView!
    
    override func awakeFromNib() {
        
        startBuildingIconViewAnimation()
        startEarthIconViewAnimation()
        startKangarooIconViewAnimation()
    }

    
    // MARK: 城市动画
    func startBuildingIconViewAnimation() {
        
        let building_1 = UIImage(named: "icon_building_loading_1")
        let building_2 = UIImage(named: "icon_building_loading_2")
        
        guard let image_1 = building_1,
              let image_2 = building_2 else {
                return
        }
        
        buildingIconView.image = UIImage.animatedImage(with: [image_1,image_2], duration: 0.5)
    }
    
    
    // MARK: 地球图片旋转动画
    func startEarthIconViewAnimation() {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        
        /* Swift 3.0  M_PI已被弃用,使用 Double.pi 弧度 180度   */
        let circumference = Double.pi * 2.0
        anim.toValue =  circumference
        anim.repeatCount = MAXFLOAT
        anim.duration = 3 //转一圈时间
        anim.isRemovedOnCompletion = false
        earthIconView.layer.add(anim, forKey: nil)
    }
    
    
    // MARK: 袋鼠图片动画
    func startKangarooIconViewAnimation() {
        
        let kangaroo_1 = UIImage(named: "icon_small_kangaroo_loading_1")
        let kangaroo_2 = UIImage(named: "icon_small_kangaroo_loading_2")
        
        guard let image_1 = kangaroo_1,
            let image_2 = kangaroo_2 else {
                return
        }
        kangarooIconView.image = UIImage.animatedImage(with: [image_1,image_2], duration: 0.3)
        
        // 设置袋鼠 锚点 (点位到父视图的点位置)
        kangarooIconView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        // 设置center ,前面设置的锚点位置， 所在父在父视图中的位置点
        let x = self.bounds.width * 0.5
        let y = self.bounds.height - 25  //父视图的最底部向上移 25
        kangarooIconView.center = CGPoint(x: x, y: y)
        kangarooIconView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
    }
    
}
