//
//  MasterViewController.swift
//  News
//
//  Created by Dmitry Reshetnik on 28.11.2020.
//

import UIKit

class MasterViewController: UITableViewController {
    private let dataManager = DataManager(baseURL: NewsAPI.BaseURL)
    private var currentPage = 1
    private var shouldShowLoadingCell = false
    var articles = [Response.Article]()
    var activityIndicatorView = UIActivityIndicatorView(style: .gray)
    var messageLabel = UILabel()
    var loadingView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        setupView()
        fetchNewsData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = articles.count
        return shouldShowLoadingCell ? count + 1 : count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.ReuseIdentifier, for: indexPath) as! ArticleTableViewCell

        // Configure the cell...
        if isLoadingIndexPath(indexPath) {
            return LoadingCell(style: .default, reuseIdentifier: "loading")
        } else {
            let title = articles[indexPath.row].title ?? "N/A"
            let description = articles[indexPath.row].description ?? "N/A"
            let author = articles[indexPath.row].author ?? "N/A"
            let source = articles[indexPath.row].source?.name ?? "N/A"
            let urlToImage = URL(string: articles[indexPath.row].urlToImage ?? "https://via.placeholder.com/150")!
            
            cell.titleLabel.text = title
            cell.descriptionLabel.text = description
            cell.authorLabel.text = "Author: \(author)"
            cell.sourceLabel.text = "Source: \(source)"
            cell.articleImageView.load(url: urlToImage)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = articles[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard isLoadingIndexPath(indexPath) else { return }
        fetchNextPage()
    }
    
    @objc private func refreshNewsData(_ sender: Any) {
        fetchNewsData()
    }
    
    private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
        guard shouldShowLoadingCell else { return false }
        return indexPath.row == self.articles.count
    }
    
    private func fetchNewsData() {
        dataManager.getNewsFor(category: "general", country: "us", page: currentPage, completion: { (news, error) in
            DispatchQueue.main.async {
                if let news = news {
                    self.articles = news.articles!
                    self.shouldShowLoadingCell = Double(self.currentPage) < (Double(news.totalResults!) / 20)
                    self.articles.sort { (lhs, rhs) -> Bool in
                        lhs.publishedAt! > rhs.publishedAt!
                    }
                }
                
                self.updateView()
                self.refreshControl?.endRefreshing()
                self.removeLoadingScreen()
            }
        })
    }
    
    private func fetchNextPage() {
        currentPage += 1
        fetchNewsData()
    }
    
    private func setupView() {
        setupLoadingScreen()
        setupRefreshControl()
    }
    
    private func updateView() {
        let hasArticles = articles.count > 0
        
        if hasArticles {
            tableView.reloadData()
        }
    }
    
    private func setupRefreshControl() {
        refreshControl?.tintColor = .gray
        refreshControl?.attributedTitle = NSAttributedString(string: "Fetching News ...")
        refreshControl?.addTarget(self, action: #selector(refreshNewsData(_:)), for: .valueChanged)
    }
    
    private func setupLoadingScreen() {
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (tableView.frame.width / 2) - (width / 2)
        let y = (tableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.text = "Loading..."
        messageLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        activityIndicatorView.style = .gray
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        activityIndicatorView.startAnimating()
        
        loadingView.addSubview(activityIndicatorView)
        loadingView.addSubview(messageLabel)
        
        tableView.addSubview(loadingView)
    }
    
    private func removeLoadingScreen() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
        messageLabel.isHidden = true
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
