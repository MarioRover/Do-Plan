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

enum dateType {
    case date
    case time
}

class NewItemController: MyUIViewController {
    static let identifier = "newItemsVCIdentifier"
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesText: UILabel!
    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    // Date
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dateSwitch: UISwitch!
    @IBOutlet weak var dateTitleTopLayout: NSLayoutConstraint!
    @IBOutlet weak var dateReminderBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var dateRemindLabel: UILabel!
    // Time
    @IBOutlet weak var timeSwitch: UISwitch!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timeViewHeight: NSLayoutConstraint!
    @IBOutlet weak var timeTitleTopLayout: NSLayoutConstraint!
    @IBOutlet weak var timeRemindLabel: UILabel!
    @IBOutlet weak var timeRemindBottomLayout: NSLayoutConstraint!
    // Priority
    @IBOutlet weak var priorityPicker: UIPickerView!
    @IBOutlet weak var priorityViewtHeight: NSLayoutConstraint!
    @IBOutlet weak var priorityLabel: UILabel!
    var priorityList: [String] = []
    var isShowPriorityPicker: Bool = false
    //
    let realm = try! Realm()
    var currentCategory: Category?
    weak var delegate: NewItemDelegate?
    var selectedItem: Item?
    var finalDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for value in Priority.allCases {
            priorityList.append(value.rawValue)
        }
            
        if currentCategory != nil {
            listLabel.text = currentCategory?.name
        }
    
        self.priorityViewtHeight.constant = 49

        datePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(timePickerChanged(picker:)), for: .valueChanged)
        
        if let item = selectedItem {
            doneButton.isEnabled = true
            textField.text = item.name
            setNotes(text: item.notes)
            priorityLabel.text = item.priority
            priorityPicker.selectRow(priorityList.firstIndex(of: item.priority)!, inComponent: 0, animated: false)
            if let itemCreateDate = item.createdAt { setCreatedLabel(date: itemCreateDate) }
            
            if let itemDate = selectedItem?.reminder {
                dateSwitch.isOn = true
                dateViewHeight.constant = 200
                datePicker.date = itemDate
                datePicker.isHidden = false
                dateRemindLabel.text = Date.dateFormatToString(date: itemDate, type: .date)
                
                timeSwitch.isOn = true
                timeViewHeight.constant = 98
                timePicker.date = itemDate
                timePicker.isHidden = false
                timeRemindLabel.text = Date.dateFormatToString(date: itemDate, type: .time)
                
                updateFinalDate(date: itemDate)
            } else {
                defaultDateView(type: .date)
                defaultDateView(type: .time)
            }
            
        } else {
            doneButton.isEnabled = false
            priorityLabel.text = priorityList[0]
            defaultDateView(type: .date)
            defaultDateView(type: .time)
        }
    }
    
    func defaultDateView(type: dateType) {
        if type == .date {
            dateRemindLabel.isHidden = true
            dateTitleTopLayout.constant = 16
            dateRemindLabel.text = Date.dateFormatToString(date: finalDate, type: .date)
            datePicker.date = finalDate
            self.dateViewHeight.constant      = 49
        } else {
            timeRemindLabel.isHidden = true
            timeTitleTopLayout.constant = 16
            timeRemindLabel.text = Date.dateFormatToString(date: finalDate, type: .time)
            timePicker.date = finalDate
            self.timeViewHeight.constant      = 49
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == NotesController.identifier{
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
        performSegue(withIdentifier: NotesController.identifier, sender: self)
    }

    func closePage() {
        dismiss(animated: true, completion: nil)
    }
    
    func setCreatedLabel(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        createdLabel.text = "Created at \(dateFormatter.string(from: date))"
    }
    

    func saveItem() {
        var title: String = ""
        var notes: String = ""
        var priority: String = priorityList[0]

        if let textTitle = textField.text, !textTitle.isEmpty { title = textTitle }
        if let textNotes = notesText.text, !textNotes.isEmpty { notes = textNotes }
        if let textPriority = priorityLabel.text { priority = textPriority }
        let reminder = dateSwitch.isOn ? finalDate : nil
        
        if !title.isEmpty && currentCategory != nil {
            if selectedItem != nil {
                
                if reminder != selectedItem?.reminder , let safeReminder = reminder {
                    print("⚠️ Update reminder")
                    LocalNotificationManager.setNotification(date: safeReminder, repeats: false, title: title, body: "")
                }
                
                do {
                    try realm.write {
                        selectedItem?.name     = title
                        selectedItem?.notes    = notes
                        selectedItem?.priority = priority
                        selectedItem?.reminder = reminder
                    }
                } catch {
                    print("❌ Error in update item \(error)")
                }
            } else {
                do {
                    try realm.write {
                        let newItem      = Item()
                        newItem.name     = title
                        newItem.notes    = notes
                        newItem.priority = priority
                        newItem.reminder = reminder
                        newItem.createdAt = Date()
                        currentCategory?.items.append(newItem)
                    }
                    
                    if let safeReminder = reminder {
                        LocalNotificationManager.setNotification(date: safeReminder, repeats: false, title: title, body: "")
                    }
                    
                } catch {
                    print("❌ Error in save item \(error)")
                }
            }
            
            delegate?.fetchFreshList()
            closePage()
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

// MARK: - DatePicker methods

extension NewItemController {
    @IBAction func priorityViewTapped(_ sender: UITapGestureRecognizer) {
        priorityPicker.isHidden = isShowPriorityPicker

        UIView.animate(withDuration: 0.5) {
            self.priorityViewtHeight.constant = self.isShowPriorityPicker ? 49 : 200
            self.view.layoutIfNeeded()
        }
        isShowPriorityPicker = !isShowPriorityPicker
    }

    @IBAction func dateSwitchPressed(_ sender: UISwitch) {
        let isOn = sender.isOn
        self.datePicker.isHidden = !isOn
        self.dateTitleTopLayout.constant = isOn ? 8 : 16
        self.dateViewHeight.constant = isOn ? 200 : 49
        if !isOn {
            self.dateRemindLabel.isHidden = true
        }
    
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        } completion: { finished in
            if isOn {
                self.dateRemindLabel.isHidden = false
            }
        }
    }
    
    @IBAction func timeSwitchPressed(_ sender: UISwitch) {
        let isOn = sender.isOn
        self.timePicker.isHidden = !isOn
        self.timeTitleTopLayout.constant = isOn ? 8 : 16
        self.timeViewHeight.constant = isOn ? 98 : 49
        if !isOn {
            self.timeRemindLabel.isHidden = true
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        } completion: { finished in
            if isOn {
                self.timeRemindLabel.isHidden = false
            }
        }
 
    }
    
    @objc func datePickerChanged(picker: UIDatePicker) {
        updateFinalDate(date: picker.date)
        dateRemindLabel.text = Date.dateFormatToString(date: picker.date, type: .date)
    }
    
    @objc func timePickerChanged(picker: UIDatePicker) {
        updateFinalDate(date: picker.date)
        timeRemindLabel.text = Date.dateFormatToString(date: picker.date, type: .time)
    }
    
    func updateFinalDate(date: Date) {
        finalDate = date
        datePicker.date = date
        timePicker.date = date
    }
}
