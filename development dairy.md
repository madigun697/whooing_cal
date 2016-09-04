## Development dairy of Whooing app(Whooing Calendar)

[toc]

### Day 1(4 September 2016)
 * I started to work for my new application.
 * New version's concept is housekeeping diary by calender.
 * I tried to sign up in server side using node js. However it's so difficult. I couldn't pin number for access token. So new version will use previous method, using inapp browser.


#### Initial View
 * Initial View had application icon. So I added image, but iOS has several view size. This means I had to different constraints about image size by scrren size. 
 * My solution was adding contratins in code(viewDidLoad method), not in UI stroyboad.
 * I created new **NSLayoutContratint** variables and added in UIViewController's constraints array.

 ```
    let constraintWidth = NSLayoutConstraint(item: whooingIcon, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenSize.width/3)

    let constraintHeight = NSLayoutConstraint(item: whooingIcon, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: screenSize.width/3)

    whooingIcon.addConstraints([constraintWidth, constraintHeight])
 ```
 * I wanted to use some opensource libararies. So I decided to use [**cocoapod**](#cocoapod) that is Dependency Manager in iOS Project.
 * First, I need to get temporary token for getting access token. However swift do not wait return, just do next line([Non-blocking](http://ozt88.tistory.com/20)). So I used [GCD](https://blog.asamaru.net/2015/11/24/swift-background-threads-gcd-grand-central-dispatch/) in swift.
 * Following code will do getTempToken function first, and wait finish that function. And when getTempToken function finished, it will do print function.

 ```
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        
        if defaults.objectForKey("accessToken") == nil {
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                self.getTempToken()
                dispatch_async(dispatch_get_main_queue()) {
                    print(self.tempToken)
                }
            }   
        }
 ```
 * Application will do two different action. One is calling popup for sign-in(WebViewController), the other is going to main view(MainViewController).
  

#### Web View
 * I want to call web view like pop-up, and to be dimmed backgroud. So I used [Dimmable Protocol](http://www.totem.training/swift-ios-tips-tricks-tutorials-blog/ux-chops-dim-the-lights).
 * In Web View, application could gain pin number that will be used getting access token.
 * When Web View got a pin number, application unwinded this web view with pin number and recalled main view.

#### Main View After getting pin
 * When main view got a pin number through web view, application made new http request.
 * This request had to contain several values include pin number.
 * X-API-Key is encrypt key value is so important value of them. This key had to encrypt, so I need to use some extention for encryption.
 * Following code is [SHA1 encryption](http://stackoverflow.com/questions/25761344/how-to-crypt-string-to-sha1-with-swift) for X-API-Key.
 ```
 extension String {
    func sha1() -> String {
        
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joinWithSeparator("")
    }
}
 ```
 * However, If I want to this encryption code, I need to make [bridging header](https://spin.atomicobject.com/2015/02/23/c-libraries-swift/) in my project.
 * In this point, I tried to change http transaction way in my project. I used some code following.
 ```
 do {
        let url = NSURL(string: urlStr)
        let request = NSMutableURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            if error != nil {
                print("Error -> \(error)")
                return
            }
            do {
                result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:String]
                print("Result -> \(result)")
            } catch {
                print("Error -> \(error)")
            }
        }
        task.resume()
    }
 ```
 * But this code made me do duplicate using this code. It is not efficient.
 * So, I tried to use Alamofire library, but it doesn't work. I'll try to use this library again later.
 * After making X-API-Key, application changed initial view's label, and moved main view.


### References
#### Cocoapod
  * Using Cocoapod is so simple.
    1. Install cocoapod follow command
    	`sudo gem install cocoapods`
    2. Add new profile in your project
    	`pod init`
    3. Adding or updating profile(profile file)
    	```
        # platform :ios, '9.0'
        target 'project name' do
        	pod 'library name'
        end
        ```
    4. Install libraries
    	`pod install --verbose`
 * 