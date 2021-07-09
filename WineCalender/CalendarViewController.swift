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
    
    let fullDateFormatter = DateFormatter()
    let monthFormatter = DateFormatter()
    let headDateFormatter = DateFormatter()
    var headerDate : String?
    var selectedPageMonth : String?
    var selectedDate = Date()
    
    var sampleDatas : [ScheduleAndMyWinesData] = []
    var currentPageMonthSampleDatas : [ScheduleAndMyWinesData] = []
    var currentPageMonthSampleDataDic : [Date:UIImage] = [:]
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendarView, action: #selector(self.calendarView.handleScopeGesture(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
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
        
        setDateFormat()
 
        //샘플 데이터
        setUpSampleData()
        
        updateCurrentPageMonthUI()
    }
    
// MARK: - UI
    
    func setDateFormat() {
        fullDateFormatter.locale = Locale(identifier: "ko_KR")
        fullDateFormatter.dateFormat = "yyyy-MM-dd E"
        monthFormatter.dateFormat = "M"
    }
    
    func setHeaderDate(){
        headDateFormatter.dateFormat = "yyyy년 M월"
        headerDate = headDateFormatter.string(from: calendarView.currentPage)
        calendarView.appearance.headerDateFormat = headerDate
    }
    
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
    }
    
    func updateCurrentPageMonthUI() {
        setHeaderDate()

        selectedPageMonth = monthFormatter.string(from: calendarView.currentPage)
        currentPageMonthSampleDatas = []
        currentPageMonthSampleDatas = sampleDatas.filter{ monthFormatter.string(from: $0.scheduleAndMyWinesDate ) == selectedPageMonth}
        calendarTableView.reloadData()
    }

// MARK: - Gesture
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
// MARK: - Navigation
    
    @IBAction func unwindToCalendarView(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "saveUnwind", let sourceViewController = unwindSegue.source as? AddScheduleTableViewController, let sampleData = sourceViewController.sampleData else { return }
        
        sampleDatas.append(sampleData)
        sortSampleDatas()
        currentPageMonthSampleDataDic[sampleData.scheduleAndMyWinesDate] = Categories.Schedule.categoryImage
        calendarView.reloadData()
        updateCurrentPageMonthUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController,
           let calendarAddTableViewController = navController.topViewController as? AddScheduleTableViewController {
            calendarAddTableViewController.receivedDateAndTime = selectedDate
        }
    }
// MARK: - Sample Data
    
    func setUpSampleData() {
        let sample1 = fullDateFormatter.date(from: "2021-06-11 금")!
        setUpEvent(date: sample1, scheduleDescription: "", wineName: "세인트 프란시스, 피노 누아", wineCategory: "Red")
        let sample2 = fullDateFormatter.date(from: "2021-06-02 수")!
        setUpEvent(date: sample2, scheduleDescription: "", wineName: "미구엘 토레스, 안디카 소비뇽 블랑 리제르바", wineCategory: "White")
        let sample3 = fullDateFormatter.date(from: "2021-06-19 토")!
        setUpEvent(date: sample3, scheduleDescription: "", wineName: "마스카 델 타코, 로시 피노 네로 로사토", wineCategory: "Rose")
        let sample4 = fullDateFormatter.date(from: "2021-06-27 일")!
        setUpEvent(date: sample4, scheduleDescription: "오후 7시 / 청담 / 대학모임 ", wineName: "", wineCategory: "Schedule")
        let sample5 = fullDateFormatter.date(from: "2021-06-22 화")!
        setUpEvent(date: sample5, scheduleDescription: "", wineName: "도멘 생그라, 엘 몰리", wineCategory: "Red")
        let sample6 = fullDateFormatter.date(from: "2021-07-09 금")!
        setUpEvent(date: sample6, scheduleDescription: "", wineName: "마스카 델 타코, 로시 피노 네로 로사토", wineCategory: "Rose")
        //print(sampleDatas)
    }
    
    func setUpEvent(date: Date, scheduleDescription: String, wineName: String, wineCategory: String) {
        switch wineCategory {
        case "Red":
            sampleDatas.append(ScheduleAndMyWinesData(scheduleAndMyWinesDate: date, scheduleDescription: scheduleDescription, wineName: wineName, category: Categories.Red))
            currentPageMonthSampleDataDic[date] = Categories.Red.categoryImage
        case "White":
            sampleDatas.append(ScheduleAndMyWinesData(scheduleAndMyWinesDate: date, scheduleDescription: scheduleDescription, wineName: wineName, category: Categories.White))
            currentPageMonthSampleDataDic[date] = Categories.White.categoryImage
        case "Rose":
            sampleDatas.append(ScheduleAndMyWinesData(scheduleAndMyWinesDate: date, scheduleDescription: scheduleDescription, wineName: wineName, category: Categories.Rose))
            currentPageMonthSampleDataDic[date] = Categories.Rose.categoryImage
        case "Schedule":
            sampleDatas.append(ScheduleAndMyWinesData(scheduleAndMyWinesDate: date, scheduleDescription: scheduleDescription, wineName: wineName, category: Categories.Schedule))
            currentPageMonthSampleDataDic[date] = Categories.Schedule.categoryImage
        default:
            break
        }
        sortSampleDatas()
    }
    
    func sortSampleDatas() {
        sampleDatas.sort { $0.scheduleAndMyWinesDate < $1.scheduleAndMyWinesDate }
    }
}

// MARK: - FSCalendarDelegate, FSCalendarDataSource

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        currentPageMonthSampleDataDic[date]
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        //print("선택한 날짜 \(selectedDate)")
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateCurrentPageMonthUI()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension CalendarViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentPageMonthSampleDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableViewCell", for: indexPath) as! CalendarTableViewCell
        //샘플 데이터
        cell.calendarImageView.image = currentPageMonthSampleDatas[indexPath.row].categoryImage
        
        let calendarAndMyWinesdate = currentPageMonthSampleDatas[indexPath.row].scheduleAndMyWinesDate
        cell.calendarDateLabel.text = fullDateFormatter.string(from: calendarAndMyWinesdate)
        
        if currentPageMonthSampleDatas[indexPath.row].category == Categories.Schedule {
            cell.calendarDescriptionLabel.text = currentPageMonthSampleDatas[indexPath.row].scheduleDescription
        } else {
            cell.calendarDescriptionLabel.text = currentPageMonthSampleDatas[indexPath.row].wineName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}
