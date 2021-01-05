//
//  NewItemController.swift
//  Do Plan
//
//  Created by Hossein Akbari on 10/7/1399 AP.
//

import UIKit
import RealmSwift

protocol NewItemDelegate: class {
    func fetchFreshList()
}

class NewItemController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesText: UILabel!
    @IBOutlet weak var listLabel: UILabel!
    // Priority
    @IBOutlet weak var priorityPicker: UIPickerView!
    @IBOutlet weak var priorityViewtHeight: NSLayoutConstraint!
    @IBOutlet weak var priorityLabel: UILabel!
    let priorityList = ["None","Low","Medium","High"]
    var isShowPriorityPicker: Bool = false
    //
    let realm = try! Realm()
    var currentCategory: Category?
    weak var delegate: NewItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isEnabled = false
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
        
        if currentCategory != nil {
            listLabel.text = currentCategory?.name
        }
        
    
        priorityLabel.text = priorityList[0]
        self.priorityViewtHeight.constant = 49
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.Segue.notes {
            let vc = segue.destination as! NotesController
            vc.delegate = self
            if let text = notesText.text, !text.isEmpty {
                vc.notes = text
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func donePressed(_ sender: UIButton) {
        saveItem()
    }

    @IBAction func noteViewTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: Constant.Segue.notes, sender: self)
    }

    @IBAction func priorityViewTapped(_ sender: UITapGestureRecognizer) {
        priorityPicker.isHidden = isShowPriorityPicker

        UIView.animate(withDuration: 0.5) {
            self.priorityViewtHeight.constant = self.isShowPriorityPicker ? 49 : 200
            self.view.layoutIfNeeded()
        }
        isShowPriorityPicker = !isShowPriorityPicker
    }
    
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    func closePage() {
        dismiss(animated: true, completion: nil)
    }

    func saveItem() {
        var title: String = ""
        var notes: String = ""
        var priority: String = priorityList[0]

        if let textTitle = textField.text, !textTitle.isEmpty { title = textTitle }
        if let textNotes = notesText.text, !textNotes.isEmpty { notes = textNotes }
        if let textPriority = priorityLabel.text { priority = textPriority }

        if !title.isEmpty && currentCategory != nil {
            do {
                try realm.write {
                    let newItem      = Item()
                    newItem.name     = title
                    newItem.notes    = notes
                    newItem.priority = priority
                    currentCategory?.items.append(newItem)
                }
                delegate?.fetchFreshList()
                closePage()
            } catch {
                print("❌ Error in save item \(error)")
            }
        }

    }
    
}


// MARK: - TextFieldDelegate

extension NewItemController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        doneButton.isEnabled = !textField.text!.isEmpty
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 40
    }

}

// MARK: - NoteDelegate

extension NewItemController: NotesDelegate {
    func setNotes(text: String = "") {
        if text.isEmpty {
            notesLabel.isHidden = false
            notesText.isHidden  = true
        } else {
            notesLabel.isHidden = true
            notesText.isHidden  = false
            notesText.text      = text
        }
        notesText.text = text
    }
}

// MARK: - UIPickerDelegate

extension NewItemController: UIPickerViewDelegate, UIPickerViewDataSource {


    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.priorityList.count
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = self.priorityList[row]
        pickerLabel?.textColor = .white

        return pickerLabel!
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        priorityLabel.text = priorityList[row]
    }
}
