/*
* Rainbow SDK sample
*
* Copyright (c) 2018, ALE International
* All rights reserved.
*
* ALE International Proprietary Information
*
* Contains proprietary/trade secret information which is the property of
* ALE International and must not be made available to, or copied or used by
* anyone outside ALE International without its written authorization
*
* Not to be disclosed or used except in accordance with applicable agreements.
*/

import UIKit
import Rainbow

class RoomsTableViewController: UITableViewController {
    let serviceManager : ServicesManager
    let roomsManager : RoomService
    var populated = false
    var selectedIndex : IndexPath? = nil
    var allObjects : [Room] = []
        
    required init?(coder aDecoder: NSCoder) {
        serviceManager = ServicesManager.sharedInstance()
        roomsManager = serviceManager.roomService
        super.init(coder: aDecoder)
    }
    
    deinit {
        selectedIndex = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        allObjects = []
        configureRightButton()
        self.tableView.reloadData()
    }
    
    func configureRightButton() {
        let logout = UIAction(title: "Logout", image: UIImage(systemName: "power.circle")) { _ in
            Task { @MainActor in
                try? await ServicesManager.sharedInstance().loginManager.logout()
                self.dismiss(animated: false, completion: nil)
            }
        }
        
        let menu = UIMenu(title: "", children: [logout])
        let barButton = UIBarButtonItem(title: "", image: UIImage(systemName: "ellipsis"), menu: menu)
        navigationItem.rightBarButtonItem = barButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(didAddRoom(notification:)), name: RoomService.Notifications.didAddRoom, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateRoom(notification:)), name: RoomService.Notifications.didUpdateRoom, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRemoveRoom(notification:)), name: RoomService.Notifications.didRemoveRoom, object: nil)
        fetchRooms()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func insert(_ room : Room) {
        if let index = allObjects.firstIndex(of: room) {
            allObjects[index] = room
        } else {
            allObjects.append(room)
        }
    }
    
    @objc func didAddRoom(notification : Notification) {
        // Enforce that this method is called on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didAddRoom(notification: notification)
            }
            return
        }
        
        if let room = notification.object as? Room {
            self.insert(room)
            if self.isViewLoaded && populated {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func didUpdateRoom(notification : NSNotification) {
        // Enforce that this method is called on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didUpdateRoom(notification: notification)
            }
            return
        }
        
        if let userInfo = notification.object as? Dictionary<String, AnyObject> {
            let room = userInfo[RoomService.Constants.kRoomKey]! as! Room
            if let index = allObjects.firstIndex(of: room) {
                if (index != NSNotFound) {
                    self.allObjects.remove(at: index)
                }
            }
            self.insert(room)
        }
        if self.isViewLoaded && populated {
            self.tableView.reloadData()
        }
    }
    
    @objc func didRemoveRoom(notification : NSNotification) {
        // Enforce that this method is called on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.didRemoveRoom(notification: notification)
            }
            return
        }
        if let room = notification.object as? Room {
            if let index = allObjects.firstIndex(of: room) {
                self.allObjects.remove(at: index)
            }
            if self.isViewLoaded && populated {
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchRooms() {
        Task { @MainActor in
            do {
                let (rooms, _) = try await roomsManager.getRoomsByPage(filteredBy: .activeAll, page: .first)
                self.allObjects = rooms
                if self.isViewLoaded {
                    self.tableView.reloadData()
                }
            } catch {
                NSLog("Error: \(error)")
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allObjects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomsTableViewCell", for: indexPath)
        return cell
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let roomCell = cell as? RoomsTableViewCell {
            let room = allObjects[indexPath.row]
            roomCell.name.text = room.displayName()
            if let photoData = room.photoData {
                roomCell.avatar.image = UIImage.init(data: photoData)
                roomCell.avatar.tintColor = UIColor.clear
            } else {
                roomCell.avatar.image = UIImage.init(named: "Default_Room_Avatar")
                roomCell.avatar.tintColor = UIColor.init(hue: CGFloat(indexPath.row*36%100)/100.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "EditRoomSegue", sender: self)
    }

    override func tableView(_ tableView : UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let room = allObjects[indexPath.row]
        let isMyRoom = {
            guard let myContact = ServicesManager.sharedInstance().myUser.contact else { return false }
            return room.isOwner(contact: myContact)
        }()
        
        let swipeActions = UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: isMyRoom ? "Delete" : "Leave", handler: { [weak self] _,_,_ in
                guard let self else { return }
                Task {
                    if isMyRoom {
                        try? await self.roomsManager.delete(room: room)
                    } else {
                        try? await self.roomsManager.leave(room: room)
                    }
                }

            }),
            
            UIContextualAction(style: .normal, title: "Edit", handler: { _,_,_ in
                self.selectedIndex = indexPath
                self.performSegue(withIdentifier: "EditRoomSegue", sender: self)
            })
        ])
        
        return swipeActions
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditRoomSegue" {
            if let selectedIndex = self.selectedIndex {
                if let vc = segue.destination as? EditRoomViewController {
                    vc.room = allObjects[selectedIndex.row]
                    if let cell = self.tableView.cellForRow(at: selectedIndex) as? RoomsTableViewCell {
                        vc.roomImage = cell.avatar.image!
                        vc.roomImageTint = cell.avatar.tintColor
                    }
                }
            }
        }
    }
}
