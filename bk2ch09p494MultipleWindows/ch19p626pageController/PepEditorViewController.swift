

import UIKit

class PepEditorViewController: UIViewController {
    
    @IBOutlet var pepContainer : UIView!
    @IBOutlet weak var newWindowButton: UIButton!
    
    @IBOutlet weak var favoriteSwitch: UISwitch!
    
    var restorationInfo :  [AnyHashable : Any]?
    
    var pepName : String = "Manny"
    
    static let editingRestorationKey = "editing"
    static let isFavoriteRestorationKey = "favorite"
    static let whichPepBoyWeAreEditing = "whichPepEditing"
    static let newEditorActivityType = "com.neuburg.multiplewindows.pepEdit"

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let pep = Pep(pepBoy: pepName)
        
        pep.view.frame = self.pepContainer.bounds
        self.pepContainer.addSubview(pep.view)
        pep.didMove(toParent: self)
        
        let key = Self.isFavoriteRestorationKey
        let info = self.restorationInfo
        print("pep editor view did load", info as Any)
        if let fav = info?[key] as? Bool {
            print("restoring favorite switch")
            self.favoriteSwitch.isOn = fav
        }
        if self.presentingViewController == nil {
            self.newWindowButton.setTitle("Close", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.userActivity = self.view.window?.windowScene?.userActivity
        self.restorationInfo = nil

    }

    override func updateUserActivityState(_ activity: NSUserActivity) {
        super.updateUserActivityState(activity)
        print(self.view.window?.windowScene?.session.persistentIdentifier as Any)
        print("pep editor update user activity state")
        let key = Self.editingRestorationKey
        activity.addUserInfoEntries(from: [key:true])
        let key2 = Self.isFavoriteRestorationKey
        activity.addUserInfoEntries(from: [key2:self.favoriteSwitch.isOn])
        if self.presentingViewController == nil {
            let key3 = Self.whichPepBoyWeAreEditing
            activity.addUserInfoEntries(from: [key3:self.pepName])
        }
        print(activity.userInfo as Any)
    }

    @IBAction func doNewWindow(_ sender: Any) {
        guard let b = sender as? UIButton else {return}
        if b.currentTitle != "Close" {
            // new
            let opts = UIScene.ActivationRequestOptions()
            opts.requestingScene = self.view.window?.windowScene
            let act = NSUserActivity(activityType: Self.newEditorActivityType)
            let key = Self.whichPepBoyWeAreEditing
            act.addUserInfoEntries(from: [key:self.pepName])
            UIApplication.shared.requestSceneSessionActivation(
                nil,
                userActivity: act,
                options: opts,
                errorHandler: nil)
        } else {
            // close
            guard let session = self.view.window?.windowScene?.session else {return}
            let opts = UIWindowSceneDestructionRequestOptions()
            opts.windowDismissalAnimation = .standard
            UIApplication.shared.requestSceneSessionDestruction(session, options: opts, errorHandler: nil)
        }
    }
    
}