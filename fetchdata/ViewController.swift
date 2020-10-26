//
//  ViewController.swift
//  fetchdata
//
//  Created by Govardhan Goli on 10/20/20.
//

import UIKit

struct Result: Codable {
    var id: Int?
    var listId: Int?
    var name: String?
}

class ViewController: UIViewController {

    @IBOutlet weak var dataTableviewCell: UITableView!
    
    var responseData : [Result]?
    var section = 0
    var fetcheddatada = [Int : [Result]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetcheddatada.removeAll()
        dataRequest { [self] (proccesseddata) in
            fetcheddatada = proccesseddata
            DispatchQueue.main.async {
                dataTableviewCell.reloadData()
            }
        }
        dataTableviewCell.delegate = self
        dataTableviewCell.dataSource = self
    }
    
    func dataRequest(onComplete: @escaping (([Int : [Result]])->())) {
        let urlToRequest = "https://fetch-hiring.s3.amazonaws.com/hiring.json"

        let url = URL(string: urlToRequest)!
        let session4 = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        let task = session4.dataTask(with: request as URLRequest) { (data, response, error) in
          guard let _: Data = data, let _: URLResponse = response, error == nil else {
            print("*****error")
            return
          }
        if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([Result].self, from: data) {
                    var sorteddict = [Result]()
                    for response in decodedResponse{
                        if response.name != "" && response.name != nil{
                            sorteddict.append(response)
                        }
                    }
                    var dict = Dictionary(grouping: sorteddict) { $0.listId as! Int }
                   let sortedListDict = [Int : [Result]](uniqueKeysWithValues: dict.sorted{ $0.key < $1.key })
                    let keys = Array(sortedListDict.keys)
                    onComplete(sortedListDict);
                    return
                }
            }
        }
        task.resume()
      }
    


}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetcheddatada.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionNumber = Array(fetcheddatada.keys)[section]
        let rows = fetcheddatada[sectionNumber]
        return rows?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: fetchedDataTableviewCell.identifier, for: indexPath) as! fetchedDataTableviewCell
        let sectionNumber = Array(fetcheddatada.keys)[indexPath.section]
        let rowdata = fetcheddatada[sectionNumber]
        cell.itemName.text = rowdata?[indexPath.row].name ?? "This list is empty"
           return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: dataTableviewCell.bounds.size.width, height: 50))
        let lblHeader = UILabel.init(frame: CGRect(x: 15, y: 13, width: dataTableviewCell.bounds.size.width - 10, height: 24))
        let sectionname = Array(fetcheddatada.keys)[section]
        lblHeader.text =  "listId: \(sectionname)"
        lblHeader.font = UIFont (name: "OpenSans-Semibold", size: 18)
        lblHeader.textColor = UIColor.black
        headerView.addSubview(lblHeader)
        headerView.backgroundColor = UIColor.red
        return headerView
    }
    
    
}

class fetchedDataTableviewCell : UITableViewCell{
    static let identifier = String(describing: fetchedDataTableviewCell.self)

    @IBOutlet weak var itemName: UILabel!
}
