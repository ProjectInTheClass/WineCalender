//
//  CalendarViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/07/09.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var calendarTableView: UITableView!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    let monthFormatter = DateFormatter()
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
        calendarView.appearance.headerTitleColor = UIColor.systemRed
        calendarView.appearance.weekdayFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        calendarView.appearance.weekdayTextColor = UIColor.systemRed
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 12)

        calendarView.appearance.titleOffset = .init(x: 0, y: 3)
        calendarView.appearance.imageOffset = .init(x: -1, y: -7)
        
        calendarView.appearance.borderRadius = 1
        
        calendarView.appearance.todayColor = .systemRed
        calendarView.appearance.selectionColor = .lightGray

        calendarView.placeholderType = .none
        
        setHeaderDate()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd E"
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.timeStyle = .short
        monthFormatter.dateFormat = "M"
        CalendarViewController.selectedPageMonth = monthFormatter.string(from: selectedDate)
    }
    
    func setHeaderDate(){
        headerDateFormatter.dateFormat = "yyyy년 M월"
        headerDate = headerDateFormatter.string(from: calendarView.currentPage)
        calendarView.appearance.headerDateFormat = headerDate
    }
    
    func updateSelectedPageMonthUI() {
        setHeaderDate()
        CalendarViewController.selectedPageMonth = monthFormatter.string(from: calendarView.currentPage)
        DataManager.shared.fetchEvent()
        calendarView.reloadData()
        calendarTableView.reloadData()
    }

// MARK: - Navigation
    
    @IBAction func unwindToCalendarView(_ unwindSegue: UIStoryboardSegue) {
//        guard unwindSegue.identifier == "saveUnwind", let sourceViewController = unwindSegue.source as? AddScheduleTableViewController, let sampleData = sourceViewController.sampleData else { return }
//
//        sampleDatas.append(sampleData)
//        sortSampleDatas()
//        currentPageMonthSampleDataDic[sampleData.scheduleAndMyWinesDate] = Categories.Schedule.categoryImage
//        calendarView.reloadData()
//        updateCurrentPageMonthUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController,
           let AddScheduleTableViewController = navController.topViewController as? AddScheduleTableViewController {
            if segue.identifier == "AddScheduleSegue" {
                AddScheduleTableViewController.receivedDateAndTime = selectedDate
            } else if segue.identifier == "EditScheduleSegue",
            let cell = sender as? UITableViewCell,
            let indexPath = calendarTableView.indexPath(for: cell) {
                AddScheduleTableViewController.event = DataManager.shared.selectedPageMonthEventList[indexPath.row]
            }
        }
    }
// MARK: - Sample Data
    
    func setUpSampleData() {
        let sample1 = dateFormatter.date(from: "2021-06-11 금")!
        DataManager.shared.addEvent(eventDate: sample1, eventDescription: "", wineName: "세인트 프란시스, 피노 누아", category: "Red")
        let sample2 = dateFormatter.date(from: "2021-06-02 수")!
        DataManager.shared.addEvent(eventDate: sample2, eventDescription: "", wineName: "미구엘 토레스, 안디카 소비뇽 블랑 리제르바", category: "White")
        let sample3 = dateFormatter.date(from: "2021-07-25 일")!
        DataManager.shared.addEvent(eventDate: sample3, eventDescription: "청담 / 대학모임", wineName: "", category: "Schedule")
        let sample4 = dateFormatter.date(from: "2021-07-10 토")!
        DataManager.shared.addEvent(eventDate: sample4, eventDescription: "", wineName: "마스카 델 타코, 로시 피노 네로 로사토", category: "Rose")
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
                return velocity.y < 0
            case .week:
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
        //print("선택한 날짜 \(selectedDate)")
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
        
        switch target.category {
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
        
        if target.category == Categories.Schedule.rawValue {
            cell.calendarTimeLabel.text = timeFormatter.string(for: target.eventDate)
        } else {
            cell.calendarTimeLabel.text = ""
        }
        
        if target.category == Categories.Schedule.rawValue {
            cell.calendarDescriptionLabel.text = target.eventDescription
        } else {
            cell.calendarDescriptionLabel.text = target.wineName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
