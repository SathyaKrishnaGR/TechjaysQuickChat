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

extension UIStoryboard {
  
  class func controller<T: UIViewController>(storyboard: StoryboardEnum) -> T {
    return UIStoryboard(name: storyboard.rawValue, bundle: Bundle(for: self)).instantiateViewController(withIdentifier: T.className) as! T
  }
  
  class func initial<T: UIViewController>(storyboard: StoryboardEnum) -> T {
    return UIStoryboard(name: storyboard.rawValue, bundle: Bundle(for: self)).instantiateInitialViewController() as! T
  }
  
  enum StoryboardEnum: String {
    case auth = "Auth"
    case conversations = "Conversations"
    case profile = "Profile"
    case previews = "Previews"
    case messages = "Messages"
  }
}
