//
//  AdView.swift
//  
//  Created by lzqok on 2016/12/20.
//  Copyright © 2016年 lzqok. All rights reserved.
//

import UIKit

/**
 * 声明代理协议 OC访问swift代理方法需要在声明协议前添加@objc
 */
@objc
protocol AdViewDelegate {
    func adIndexSelect(index:NSInteger)
}

class AdView: UIView ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    //声明collectionView
    var collectionView : UICollectionView?
    //声明数组用于接收控制器传过来的数组进行
    var adArray : NSMutableArray?{
        willSet{
            self.adArray = newValue
            //将数组第一个元素添加到数组最后用于解决从最后一个元素滚动到第一个元素动画不协调问题
            if (self.adArray?.count)! > 1 {
                self.adArray?.add(self.adArray?.object(at: 0) as Any)
            }
            self.collectionView?.reloadData()
        }
    }
    var delegate : AdViewDelegate?
    
    var timer : Timer = Timer() //初始化定时器
    
    typealias AdViewBlock = (_ index:NSInteger)->Void
    
    
    //view布局的一些设置
    func setViews(){
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize.init(width: self.bounds.width, height: self.bounds.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: layout)
        
        collectionView?.isPagingEnabled = true
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView!.register(AdviewCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.addSubview(collectionView!)
        self.collectionView?.backgroundColor = UIColor.white
        collectionView!.mas_makeConstraints { (make) in
            make!.edges.equalTo()(self)
        }
        self.addTimer()
    }
    //代码中通过init创建view时执行
    override init(frame:CGRect){
        super.init(frame: frame)
        setViews()
    }
    
    //nib中custom class 引用该类时执行
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    //创建一个定时器timer1并将timer1赋给timer
    func addTimer(){
        let timer1 = Timer.init(timeInterval: 3, target: self, selector: #selector(nextPage), userInfo: nil, repeats: true)
        RunLoop.current.add(timer1, forMode: .commonModes)
        timer = timer1
    }
    
    func removeTimer(){
        self.timer.invalidate()
    }
    
    func returnIndexPath()->NSIndexPath {
        var currentIndexPath = collectionView?.indexPathsForVisibleItems.last
        currentIndexPath = NSIndexPath.init(row: (currentIndexPath?.row)!, section: 0) as IndexPath
        collectionView?.scrollToItem(at: currentIndexPath!, at: .top, animated: true)
        return currentIndexPath! as NSIndexPath
    }
    //自动滚动到下一页
    func nextPage(){
        
        let indexPath = returnIndexPath()
        var row = indexPath.row + 1
        if row == adArray?.count {
            row = 0
        }
        //flag 标示如果是最后一个者滚动到第一个位置不添加动画
        var flag = true
        if(row == 0){
            flag = false
            //滚动到第一个
            let nextIndexPath = NSIndexPath.init(row: row, section:0)
            collectionView?.scrollToItem(at: nextIndexPath as IndexPath, at: .top, animated: flag)
            //接着动画滚到到第二个位置
            let nextIndexPath1 = NSIndexPath.init(row: row+1, section:0)
            collectionView?.scrollToItem(at: nextIndexPath1 as IndexPath, at: .top, animated: true)
            
        }else{
            let nextIndexPath = NSIndexPath.init(row: row, section:0)
            collectionView?.scrollToItem(at: nextIndexPath as IndexPath, at: .top, animated: flag)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adArray!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:AdviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AdviewCollectionViewCell

        cell.titleLabel.text = adArray?[indexPath.row] as? String
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.collectionView!.bounds.width, height: self.collectionView!.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row >= self.adArray!.count-1 ? 0:indexPath.row
        delegate?.adIndexSelect(index: index)
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.addTimer()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.removeTimer()
    }
    
}
//UICollectionViewCell 可自定义此处实现图文并茂的广告
class AdviewCollectionViewCell : UICollectionViewCell {
    var titleLabel = UILabel()
    override init(frame: CGRect){
        super.init(frame: frame)
        titleLabel.textAlignment = .left
        self.contentView.addSubview(titleLabel)

        titleLabel.mas_makeConstraints { (make) in
            make!.edges.equalTo()(self)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
