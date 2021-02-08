//
//  NotesController.swift
//  Do Plan
//
//  Created by Hossein Akbari on 10/11/1399 AP.
//

import UIKit

protocol NotesDelegate: class {
    func setNotes(text: String)
}

class NotesController: UIViewController {
    static let identifier = "notesVCIdentifier"

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    weak var delegate: NotesDelegate?
    
    var notes: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.becomeFirstResponder()
        textView.text = notes
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        closePage()
    }
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        delegate?.setNotes(text: textView.text)
        closePage()
    }
    
    func closePage() {
        dismiss(animated: true, completion: nil)
    }
}
