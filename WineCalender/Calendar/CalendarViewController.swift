//
//  CalendarViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/07/09.
//

import UIKit
import FSCalendar
import JJFloatingActionButton

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var calendarTableView: UITableView!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    let actionButton = JJFloatingActionButton()
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    let headerDateFormatter = DateFormatter()
    var headerDate: String?
    static var selectedPageMonth: String?
    var selectedDate = Date()
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendarView, action: #selector(self.calendarView.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    var token: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //navigationItem.title = "Calendar"
        
        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        self.calendarTableView.delegate = self
        self.calendarTableView.dataSource = self
        self.view.addGestureRecognizer(self.scopeGesture)
        self.calendarTableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        
        configureUI()
 
        //샘플 데이터 (앱 실행할 때마다 추가됨)
        setUpSampleData()
        
        DataManager.shared.fetchEvent()
        
        token = NotificationCenter.default.addObserver(forName: AddScheduleTableViewController.newScheduleDidInsert, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            self?.updateSelectedPageMonthUI()
        }
        token = NotificationCenter.default.addObserver(forName: DetailScheduleTableViewController.scheduleDidChange, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            self?.updateSelectedPageMonthUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataManager.shared.fetchEvent()
    }
    
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
// MARK: - UI
    
    func configureUI() {
        calendarView.scope = .month
        calendarView.scrollEnabled = true
        calendarView.scrollDirection = .horizontal
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        calendarView.pagingEnabled = true
        
        calendarView.allowsSelection = true
        calendarView.allowsMultipleSelection = false
        
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.appearance.headerTitleFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
        calendarView.appearance.headerTitleColor = .systemPink
        calendarView.appearance.weekdayFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        calendarView.appearance.weekdayTextColor = .systemPink
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 12)
        calendarView.appearance.titleDefaultColor = UIColor(named: "blackAndWhite")

        calendarView.appearance.titleOffset = .init(x: 0, y: 3)
        calendarView.appearance.imageOffset = .init(x: -1, y: -7)
        
        calendarView.appearance.borderRadius = 1
        
        calendarView.appearance.todayColor = UIColor(named: "wine1")
        calendarView.appearance.selectionColor = .systemGray2

        calendarView.placeholderType = .none
        
        setHeaderDate()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd E"
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.timeStyle = .short
        CalendarViewController.selectedPageMonth = headerDateFormatter.string(from: selectedDate)
        
        floatingButton()
    }
    
    func setHeaderDate(){
        headerDateFormatter.dateFormat = "yyyy년 M월"
        headerDate = headerDateFormatter.string(from: calendarView.currentPage)
        calendarView.appearance.headerDateFormat = headerDate
    }
    
    func floatingButton() {
        actionButton.addItem(title: "일정 추가", image: UIImage(systemName: "calendar.badge.plus")?.withRenderingMode(.alwaysOriginal)) { action in
            if let addScheduleNav = self.storyboard?.instantiateViewController(identifier: "AddScheduleNav") , let addScheduleVC = addScheduleNav.children.first as? AddScheduleTableViewController{
                addScheduleVC.receivedDateAndTime = self.selectedDate
                self.present(addScheduleNav, animated: true, completion: nil)
            }
        }
        actionButton.addItem(title: "와인 기록 추가", image: UIImage(named: "wine_black")?.withRenderingMode(.alwaysOriginal), action: nil)
        
        actionButton.display(inViewController: self)
        actionButton.itemAnimationConfiguration = .popUp()
        actionButton.buttonColor = UIColor(named: "wine1")!
        actionButton.buttonImageColor = .white
        
        actionButton.itemSizeRatio = CGFloat(0.75)
        actionButton.configureDefaultItem { item in
            item.titleLabel.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
            item.titleLabel.textColor = .white
            item.buttonColor = .white

            item.layer.shadowColor = UIColor.black.cgColor
            item.layer.shadowOffset = CGSize(width: 0, height: 1)
            item.layer.shadowOpacity = Float(0.4)
            item.layer.shadowRadius = CGFloat(2)
        }
    }
    
    func updateSelectedPageMonthUI() {
        setHeaderDate()
        CalendarViewController.selectedPageMonth = headerDateFormatter.string(from: calendarView.currentPage)
        DataManager.shared.fetchEvent()
        calendarView.reloadData()
        calendarTableView.reloadData()
    }

// MARK: - Navigation
    
    @IBAction func unwindToCalendarView(_ unwindSegue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController,
           let AddScheduleTableViewController = navController.topViewController as? AddScheduleTableViewController,
           segue.identifier == "AddScheduleSegue" {
            AddScheduleTableViewController.receivedDateAndTime = selectedDate
        }
    }
// MARK: - Sample Data
    
    func setUpSampleData() {
        let sample1 = dateFormatter.date(from: "2021-06-11 금")!
        DataManager.shared.addMyWine(date: sample1, category: "Red", wineName: "세인트 프란시스, 피노 누아")
        let sample2 = dateFormatter.date(from: "2021-06-02 수")!
        DataManager.shared.addMyWine(date: sample2, category: "White", wineName: "미구엘 토레스, 안디카 소비뇽 블랑 리제르바")
        let sample3 = dateFormatter.date(from: "2021-07-25 일")!
        DataManager.shared.addSchedule(date: sample3, category: "Schedule", place: "청담", description: "대학모임")
        let sample4 = dateFormatter.date(from: "2021-07-10 토")!
        DataManager.shared.addMyWine(date: sample4, category: "Rose", wineName: "마스카 델 타코, 로시 피노 네로 로사토")
    }
}

// MARK: - Gesture
    
extension CalendarViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.calendarTableView.contentOffset.y <= -self.calendarTableView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendarView.scope {
            case .month:
                calendarView.scrollEnabled = true
                return velocity.y < 0
            case .week:
                calendarView.scrollEnabled = false
                return velocity.y > 0
            @unknown default:
                break
            }
        }
        return shouldBegin
    }

    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
}

// MARK: - FSCalendarDelegate, FSCalendarDataSource

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        DataManager.shared.eventDic[date]
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        guard DataManager.shared.eventDic.isEmpty == false,
              DataManager.shared.selectedPageMonthEventList.isEmpty == false else { return }
        let dateAndTime = DataManager.shared.selectedPageMonthEventList.map{ $0.eventDate }
        let onlyDateStr = dateAndTime.map{ dateFormatter.string(from: $0!) }
        let onlyDate = onlyDateStr.map{ dateFormatter.date(from: $0) }
        let selctedDateStr = dateFormatter.string(from: selectedDate)
        if let selcted = dateFormatter.date(from: selctedDateStr),
           DataManager.shared.eventDic.keys.contains(selcted),
           onlyDate.contains(selcted),
           let index = onlyDate.firstIndex(of: selcted) {
            calendarTableView.scrollToRow(at: [0,index], at: .top, animated: true)
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateSelectedPageMonthUI()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension CalendarViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.selectedPageMonthEventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableViewCell", for: indexPath) as! CalendarTableViewCell
        
        let target = DataManager.shared.selectedPageMonthEventList[indexPath.row]
        
        switch target.eventCategory {
        case Categories.Red.rawValue:
            cell.calendarImageView.image = Categories.Red.categoryImage
        case Categories.White.rawValue:
            cell.calendarImageView.image = Categories.White.categoryImage
        case Categories.Rose.rawValue:
            cell.calendarImageView.image = Categories.Rose.categoryImage
        case Categories.Schedule.rawValue:
            cell.calendarImageView.image = Categories.Schedule.categoryImage
        default:
            break
        }

        cell.calendarDateLabel.text = dateFormatter.string(for: target.eventDate)
        
        if target.eventCategory == Categories.Schedule.rawValue {
            cell.calendarTimeLabel.text = timeFormatter.string(for: target.eventDate)
        } else {
            cell.calendarTimeLabel.text = nil
        }
        
        if target.eventCategory == Categories.Schedule.rawValue {
            let schedule = DataManager.shared.selectedPageMonthEventList as! [Schedule]
            if let schedulePlace = schedule[indexPath.row].schedulePlace,
               let scheduleDescription = schedule[indexPath.row].scheduleDescription {
                cell.calendarDescriptionLabel.text = schedulePlace + " / " + scheduleDescription
            }
        } else {
            let myWine = DataManager.shared.selectedPageMonthEventList as! [MyWine]
            cell.calendarDescriptionLabel.text = myWine[indexPath.row].wineName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if DataManager.shared.selectedPageMonthEventList[indexPath.row].eventCategory == "Schedule" {
            if let detailScheduleNav = storyboard?.instantiateViewController(withIdentifier: "DetailScheduleNav"),
               let detailScheduleVC = detailScheduleNav.children.first as? DetailScheduleTableViewController {
                detailScheduleVC.schedule = DataManager.shared.selectedPageMonthEventList[indexPath.row] as? Schedule
                present(detailScheduleNav, animated: true, completion: nil)
            }
        } else {
            if let detailMyWinesNav  = storyboard?.instantiateViewController(withIdentifier: "DetailMyWinesNav"){
                present(detailMyWinesNav, animated: true, completion: nil)
            }
        }
    }
}
