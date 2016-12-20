//
//  AdView.swift
//  DrinkChart
//
//  Created by 技术部 on 2016/12/20.
//  Copyright © 2016年 技术部. All rights reserved.
//

import UIKit

@objc
protocol AdViewDelegate {
    func adIndexSelect(index:NSInteger)
}

class AdView: UIView ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    var collectionView : UICollectionView?
    var adArray : NSMutableArray?{
        willSet{
            self.adArray = newValue
            if (self.adArray?.count)! > 1 {
                self.adArray?.add(self.adArray?.object(at: 0) as Any)
            }
            self.collectionView?.reloadData()
        }
    }
    var delegate : AdViewDelegate?
    
    var timer : Timer = Timer()
    
    typealias AdViewBlock = (_ index:NSInteger)->Void
    
    override init(frame:CGRect){
        super.init(frame: frame)
        setViews()
    }
    
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
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
    
    func nextPage(){
        
        let indexPath = returnIndexPath()
        var row = indexPath.row + 1
        if row == adArray?.count {
            row = 0
        }
        
        var flag = true
        if(row == 0){
            flag = false
            
            let nextIndexPath = NSIndexPath.init(row: row, section:0)
            collectionView?.scrollToItem(at: nextIndexPath as IndexPath, at: .top, animated: flag)
            
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
