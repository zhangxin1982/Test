//
//  ViewController.swift
//  Test
//
//  Created by 张欣 on 2020/12/28.
//

import UIKit


class ListCell: UITableViewCell {
    
    @IBOutlet var lb_key:UILabel?
    @IBOutlet var lb_value:UILabel?
    
    override class func awakeFromNib() {
        
    }
    public func setData(key:String,value:String)  {
        lb_key?.text = key
        lb_value?.text = value
    }
}

class DetialListCell:UITableViewCell {
    
    @IBOutlet var lb_title:UILabel?
    
    override class func awakeFromNib() {
        
    }

    public func setData(title:String)  {
        self.lb_title?.text = LocalData.getDataString(string: title)
    }
}

class ViewController: UIViewController {
    
    @IBOutlet var tableView:UITableView?
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var dc:[String:Any] = [:]
    var detailData:[String:Any]?
    var data:[String: Any]?
    {
        set{
            dc = newValue ?? [:]
        }
        get{
            return self.detailData ?? self.dc
        }
    }
    var timer: Timer?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI()  {
        guard let _ = self.detailData else {
            self.title = "list"
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector:#selector(requestData), userInfo: nil, repeats: true)
            guard let firstkey = LocalData.getAllKeys().first else {
                return
            }
            
            self.data = LocalData.getData(key: firstkey) as? [String : Any]
            self.tableView?.reloadData()
            return;
        }
        self.navigationItem.rightBarButtonItems?.removeAll()
        self.tableView?.reloadData()
    }
    
    @IBAction func history()
    {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "ViewDetialController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func refresh()
    {
        self.requestData()
    }
    
}

extension ViewController:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.keys.count ?? 0;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowKey = LocalData.getAllKeys(data: self.data!)[indexPath.row]
        let value = self.data![rowKey] as! String
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! ListCell;
        cell.selectionStyle = .none
        cell.setData(key: rowKey, value: value)
        return cell;
    }
    
}

extension ViewController{
   
    @objc public func requestData() {
        self.loading.isHidden = false
        self.loading.startAnimating()
        Service.requestApi { [weak self](data) in
            self?.loading.isHidden = true
            self?.loading.stopAnimating()
            guard let dic = data as? [String: Any] else {
                self?.data = [:]
                return
            }
            LocalData.setData(data: dic)
            self?.data = dic
            self?.tableView?.reloadData()
        } faile: { (error) in
            
        }
    }
}

class ViewDetialController: UIViewController,UITableViewDelegate,UITableViewDataSource
{

    var detailData:[String] = []
    @IBOutlet var tableView:UITableView?
    
    override func viewDidLoad() {
        self.title = "History"
        self.detailData = LocalData.getAllKeys()
        self.tableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.detailData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = detailData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetialListCell") as! DetialListCell;
        cell.accessoryType = .disclosureIndicator
        cell.setData(title: title)
        return cell;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let titleKey = detailData[indexPath.row]
        let dict = LocalData.getData(key: titleKey) as! [String:Any]
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "ViewController") as! ViewController
        vc.detailData = dict
        vc.title = LocalData.getDataString(string: titleKey)
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
}

