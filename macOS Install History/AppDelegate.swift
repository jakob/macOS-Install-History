//
//  AppDelegate.swift
//  macOS Install History
//
//  Created by Jakob Egger on 06.05.22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate {

	@IBOutlet var window: NSWindow!

	@IBOutlet weak var pathField: NSTextField!
	
	@IBAction func pathDidChange(_ sender: Any) {
		do {
			let url = URL(fileURLWithPath: pathField.stringValue)
			let newHistory = try InstallHistory(url: url)
			history = newHistory
		} catch let error {
			history = nil
			NSApp.presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
		}
		historyTableView.reloadData()
		checkDate()
	}
	
	@IBAction func choosePath(_ sender: Any) {
		let openDialog = NSOpenPanel()
		openDialog.beginSheetModal(for: window) { response in
			if response == .OK {
				self.pathField.stringValue = openDialog.url!.path
				do {
					let newHistory = try InstallHistory(url: openDialog.url!)
					self.history = newHistory
				} catch let error {
					self.history = nil
					NSApp.presentError(error, modalFor: self.window, delegate: nil, didPresent: nil, contextInfo: nil)
				}
				self.historyTableView.reloadData()
				self.checkDate()
			}
		}

	}
	@IBOutlet weak var historyTableView: NSTableView!
	
	var history: InstallHistory?
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		do {
			let newHistory = try InstallHistory.forCurrentMachine()
			history = newHistory
			pathField.stringValue = newHistory.url.path
			historyTableView.reloadData()
			checkDate()
		} catch let error {
			NSApp.presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
		}
	}
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return history?.records.count ?? 0
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let tableColumn = tableColumn else {
			return nil
		}

		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		
		let view = tableView.makeView(withIdentifier: .init(rawValue: (tableColumn.identifier.rawValue + "Cell")), owner: self) as! NSTableCellView
		switch tableColumn.identifier {
		case .init(rawValue: "date"):
			view.textField?.stringValue = formatter.string(from: history!.records[row].installDate)
		case .init(rawValue: "displayVersion"):
			view.textField?.stringValue = history!.records[row].displayVersion
		case .init(rawValue: "displayName"):
			view.textField?.stringValue = history!.records[row].displayName
		default:
			print("Unknoen table column: \(tableColumn)")
		}
		return view
	}

	@IBOutlet weak var checkDateField: NSTextField!
	@IBAction func checkDateFieldChanged(_ sender: Any) {
		checkDate()
	}
	
	func checkDate() {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		
		if let date = formatter.date(from: checkDateField.stringValue) {
			if let version = history?.macOSVersion(on: date) {
				versionField.stringValue = version
			} else {
				versionField.stringValue = "0"
			}
		} else {
			versionField.stringValue = "unknown date"
		}
	}
	@IBOutlet weak var versionField: NSTextField!
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}


}

