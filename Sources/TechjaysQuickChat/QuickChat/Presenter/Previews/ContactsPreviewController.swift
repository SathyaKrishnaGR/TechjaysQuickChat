//  MIT License

//  Copyright (c) 2019 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

protocol ContactsPreviewControllerDelegate: class {
  func contactsPreviewController(didSelect user: ObjectUser)
}

class ContactsPreviewController: UIViewController {
  
    @IBOutlet weak var tableView: PaginatedTableView!
    @IBOutlet weak var collectionView: UICollectionView!
  weak var delegate: ContactsPreviewControllerDelegate?
  
  private var users = [ObjectUser]()
  private let manager = UserManager()
    private var conversations = [ObjectConversation]()
  
  @IBAction func closePressed(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard let id = manager.currentUserID() else { return }
    manager.contacts {[weak self] results in
//      self?.users = results.filter({$0.id != id})
      self?.collectionView.reloadData()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    modalTransitionStyle = .crossDissolve
    modalPresentationStyle = .overFullScreen
  }
}

extension ContactsPreviewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return users.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard !users.isEmpty else {
      return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
    }
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactsCell.className, for: indexPath) as! ContactsCell
    cell.set(users[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard !users.isEmpty else { return }
    dismiss(animated: true) {
      self.delegate?.contactsPreviewController(didSelect: self.users[indexPath.row])
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard !users.isEmpty else {
      return collectionView.bounds.size
    }
    let width = (collectionView.bounds.width - 30) / 3 //spacing
    return CGSize(width: width, height: width + 30)
  }
}


class ContactsCell: UICollectionViewCell {
  
  @IBOutlet weak var profilePic: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  
  override func prepareForReuse() {
    super.prepareForReuse()
//    profilePic.cancelDownload()
    profilePic.image = UIImage(named: "profile pic")
  }
  
  func set(_ user: ObjectUser) {
    nameLabel.text = user.name
    if let urlString = user.profilePicLink {
      profilePic.setImage(url: URL(string: urlString))
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    profilePic.layer.cornerRadius = (bounds.width - 10) / 2
  }
}

extension ContactsPreviewController:PaginatedTableViewDelegate {
    func paginatedTableView(paginationEndpointFor tableView: UITableView) -> PaginationUrl {
        return PaginationUrl(endpoint: "chat/chat-lists/")
    }
    
    func paginatedTableView(_ tableView: UITableView, paginateTo url: String, isFirstPage: Bool, afterPagination hasNext: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            self.fetchConversations(for: url, isFirstPage: isFirstPage, hasNext: hasNext)
        }
    }
    
    func paginatedTableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversations.count
    }
    
    func paginatedTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.className, for: indexPath) as? ConversationCell {
         //   cell.set(conversations[indexPath.row]
            var last = ""
            var first = ""
            if let lastName = conversations[indexPath.row].last_name {
                last = lastName
            }
            if let firstName = conversations[indexPath.row].first_name {
                first = firstName
            }
            cell.nameLabel.text = "\(first) \(last)"
            cell.messageLabel.text = conversations[indexPath.row].message
            if let timeStamp = conversations[indexPath.row].timestamp {
                cell.timeLabel.text = timeStamp.getElapsedIntervalWithAgo()
            }
            DispatchQueue.main.async {
                if let urlString = self.conversations[indexPath.row].medium_profile_pic {
                    cell.profilePic.setImage(url: URL(string: urlString))
                } else {
                    cell.profilePic.image = UIImage(named: "profile_pic", in: Bundle.module, compatibleWith: .some(.current))
                    cell.profilePic.contentMode = .scaleAspectFit
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    fileprivate func fetchConversations(for url: String, isFirstPage: Bool, hasNext: @escaping (Bool) -> Void) {
        APIClient().GET(url: url, headers: ["Authorization": FayvKeys.ChatDefaults.token]) { (status, response: APIResponse<[ObjectConversation]>) in
            switch status {
            case .SUCCESS:
                if let data = response.data {
                    if isFirstPage {
                        self.conversations = data
                    } else {
                        self.conversations.append(contentsOf: data )
                    }
                    
                    self.tableView.reloadData()
                    self.tableView.scroll(to: .top, animated: true)
                    self.tableView.reloadData()
                }
                hasNext(response.nextLink ?? false)
            case .FAILURE:
                hasNext(false)
            }
        }
    }
}
