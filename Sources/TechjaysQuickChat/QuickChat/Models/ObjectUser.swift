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

class ObjectUser: ChatStorageCodable {
  
 var id = UUID().uuidString
  var name: String?
  var email: String?
  var profilePicLink: String?
  var profilePic: UIImage?
  var password: String?
    var medium_profile_pic: String?
    var thumbnail_profile_pic: String?
    var to_user_id: Int?
    var first_name: String?
    var last_name: String?
   var username: String?
   var is_following: Bool?
   var profile_pic:String?
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encodeIfPresent(name, forKey: .name)
    try container.encodeIfPresent(email, forKey: .email)
    try container.encodeIfPresent(profilePicLink, forKey: .profilePicLink)
      try container.encodeIfPresent(medium_profile_pic, forKey: .medium_profile_pic)
      try container.encodeIfPresent(thumbnail_profile_pic, forKey: .thumbnail_profile_pic)
      try container.encodeIfPresent(to_user_id, forKey: .to_user_id)
      try container.encodeIfPresent(first_name, forKey: .first_name)
      try container.encodeIfPresent(last_name, forKey: .last_name)
      try container.encodeIfPresent(username, forKey: .username)
      try container.encodeIfPresent(is_following, forKey: .is_following)
        try container.encodeIfPresent(profile_pic, forKey: .profile_pic)
    
  }
  
  init() {}
  
  public required convenience init(from decoder: Decoder) throws {
    self.init()
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    email = try container.decodeIfPresent(String.self, forKey: .email)
    profilePicLink = try container.decodeIfPresent(String.self, forKey: .profilePicLink)
      medium_profile_pic = try container.decodeIfPresent(String.self, forKey: .medium_profile_pic)
      thumbnail_profile_pic = try container.decodeIfPresent(String.self, forKey: .thumbnail_profile_pic)
      to_user_id = try container.decodeIfPresent(Int.self, forKey: .to_user_id)
      first_name = try container.decodeIfPresent(String.self, forKey: .first_name)
      last_name = try container.decodeIfPresent(String.self, forKey: .last_name)
      username = try container.decodeIfPresent(String.self, forKey: .username)
      is_following = try container.decodeIfPresent(Bool.self, forKey: .is_following)
      profile_pic = try container.decodeIfPresent(String.self, forKey: .profile_pic)
  }
}

extension ObjectUser {
  private enum CodingKeys: String, CodingKey {
    case id
    case email
    case name
    case profilePicLink
      case profile_pic
      case medium_profile_pic
      case thumbnail_profile_pic
      case to_user_id
      case first_name
      case last_name
      case username
      case is_following
  }
}

 
