import UIKit

class AnalysisViewController: UIViewController {
    
    private let vm: TransactionsViewModel
    private let isIncome: Bool
    
    let headerCard = UIView()
    let periodStartLabel = UILabel()
    let periodStartBtn   = UIButton(type: .system)
    let periodEndLabel   = UILabel()
    let periodEndBtn     = UIButton(type: .system)
    let sumLabel         = UILabel()
    let sumValueLabel    = UILabel()
    let sortLabel        = UILabel()
    let sortBtn          = UIButton(type: .system)
    let chevron          = UIImageView(image: UIImage(systemName: "chevron.right"))
    let chartPlaceholder: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray5
        v.layer.cornerRadius = 60
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    
    var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    var endDate: Date = Date()
    var sortType: SortType = .dateDescending
    
    private var showingStartDatePicker = false
    private var showingEndDatePicker = false
    private var tempDate: Date = Date()
    private var activeDateType: DateType?
    private enum DateType { case start, end }
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    

    
    private let scrollView = UIScrollView()


    
    var onStartDateTap: (() -> Void)?
    var onEndDateTap: (() -> Void)?
    
    private var tableViewHeightConstraint: NSLayoutConstraint?

    private let service: TransactionsService

    private let bankVM: BankAccountViewModel
    
    init(isIncome: Bool, service: TransactionsService, bankVM: BankAccountViewModel) {
        self.isIncome = isIncome
        self.service = service
        self.bankVM = bankVM
        self.vm = TransactionsViewModel(service: service)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        navigationItem.title = "Анализ"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        setupUI()
        loadTransactions()
        updateSumLabel()
    }
    
    private func styledDateButton(_ button: UIButton) {
        button.setTitleColor(UIColor.label, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.backgroundColor = UIColor(named: "backgroundGreen") ?? UIColor.systemGreen.withAlphaComponent(0.2)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        button.layer.borderWidth = 0
        button.showsTouchWhenHighlighted = false
        button.adjustsImageWhenHighlighted = false
        button.tintColor = .clear
    }
    

    
    private func setupUI() {
        // 1. Настройка ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // 2. Настройка StackView
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16)
        ])

        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        // 3. Настройка HeaderCard
        setupHeaderCardContent()
        headerCard.backgroundColor = .systemBackground
        headerCard.layer.cornerRadius = 12
        headerCard.layer.masksToBounds = true
        headerCard.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(headerCard)
        NSLayoutConstraint.activate([
            headerCard.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
            headerCard.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16)
        ])

        // 4. Настройка ChartPlaceholder
        chartPlaceholder.backgroundColor = .systemGray5
        chartPlaceholder.layer.cornerRadius = 12
        chartPlaceholder.layer.masksToBounds = true
        chartPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(chartPlaceholder)
        NSLayoutConstraint.activate([
            chartPlaceholder.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
            chartPlaceholder.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16),
            chartPlaceholder.heightAnchor.constraint(equalToConstant: 185)
        ])

        // 5. Настройка TableView
        setupTableView()
        let rows = vm.getTransactions(by: isIncome ? .income : .outcome, from: startDate, until: endDate, sortedBy: sortType).count
        let tableHeight = max(CGFloat(rows) * 60 + 44, 100)
        let tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: tableHeight)
        tableHeightConstraint.isActive = true
        self.tableViewHeightConstraint = tableHeightConstraint
        let transactionsCardView = UIView()
        transactionsCardView.backgroundColor = .white
        transactionsCardView.layer.cornerRadius = 12
        transactionsCardView.layer.masksToBounds = false
        transactionsCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        transactionsCardView.layer.shadowOpacity = 1
        transactionsCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        transactionsCardView.layer.shadowRadius = 8
        transactionsCardView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(transactionsCardView)
        NSLayoutConstraint.activate([
            transactionsCardView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
            transactionsCardView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16)
        ])
        transactionsCardView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: transactionsCardView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: transactionsCardView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: transactionsCardView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: transactionsCardView.bottomAnchor)
        ])
    }
    
    private func setupHeaderCardContent() {
        headerCard.translatesAutoresizingMaskIntoConstraints = false

        periodStartLabel.text = "Начало"
        periodStartLabel.font = .systemFont(ofSize: 16)
        periodStartBtn.setTitle(dateString(startDate), for: .normal)
        styledDateButton(periodStartBtn)
        periodStartBtn.addTarget(self, action: #selector(startDateTapped), for: .touchUpInside)
        periodStartBtn.translatesAutoresizingMaskIntoConstraints = false
        periodStartBtn.heightAnchor.constraint(equalToConstant: 34).isActive = true
        periodStartBtn.widthAnchor.constraint(greaterThanOrEqualToConstant: 90).isActive = true

        periodEndLabel.text = "Конец"
        periodEndLabel.font = .systemFont(ofSize: 16)
        periodEndBtn.setTitle(dateString(endDate), for: .normal)
        styledDateButton(periodEndBtn)
        periodEndBtn.addTarget(self, action: #selector(endDateTapped), for: .touchUpInside)
        periodEndBtn.translatesAutoresizingMaskIntoConstraints = false
        periodEndBtn.heightAnchor.constraint(equalToConstant: 34).isActive = true
        periodEndBtn.widthAnchor.constraint(greaterThanOrEqualToConstant: 90).isActive = true

        sumLabel.text = "Сумма"
        sumLabel.font = .systemFont(ofSize: 16)
        sumValueLabel.font = .systemFont(ofSize: 16)
        sumValueLabel.textAlignment = .right

        sortLabel.text = "Сортировка"
        sortLabel.font = .systemFont(ofSize: 16)
        sortBtn.setTitle(sortType.rawValue, for: .normal)
        sortBtn.setTitleColor(.black, for: .normal)
        sortBtn.titleLabel?.font = .systemFont(ofSize: 16)
        sortBtn.contentHorizontalAlignment = .right
        sortBtn.addTarget(self, action: #selector(showSortPicker), for: .touchUpInside)
        chevron.tintColor = .systemGray2
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.widthAnchor.constraint(equalToConstant: 12).isActive = true
        chevron.heightAnchor.constraint(equalToConstant: 12).isActive = true
        chevron.contentMode = .scaleAspectFit

        let row1 = UIView()
        row1.translatesAutoresizingMaskIntoConstraints = false
        row1.heightAnchor.constraint(equalToConstant: 44).isActive = true
        let label1 = periodStartLabel
        label1.translatesAutoresizingMaskIntoConstraints = false
        let button1 = periodStartBtn
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.heightAnchor.constraint(equalToConstant: 34).isActive = true
        row1.addSubview(label1)
        row1.addSubview(button1)
        NSLayoutConstraint.activate([
            label1.leadingAnchor.constraint(equalTo: row1.leadingAnchor),
            label1.centerYAnchor.constraint(equalTo: row1.centerYAnchor),
            button1.trailingAnchor.constraint(equalTo: row1.trailingAnchor),
            button1.centerYAnchor.constraint(equalTo: row1.centerYAnchor),
            button1.topAnchor.constraint(greaterThanOrEqualTo: row1.topAnchor, constant: 5),
            button1.bottomAnchor.constraint(lessThanOrEqualTo: row1.bottomAnchor, constant: -5)
        ])

        let row2 = UIView()
        row2.translatesAutoresizingMaskIntoConstraints = false
        row2.heightAnchor.constraint(equalToConstant: 44).isActive = true
        let label2 = periodEndLabel
        label2.translatesAutoresizingMaskIntoConstraints = false
        let button2 = periodEndBtn
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.heightAnchor.constraint(equalToConstant: 34).isActive = true
        row2.addSubview(label2)
        row2.addSubview(button2)
        NSLayoutConstraint.activate([
            label2.leadingAnchor.constraint(equalTo: row2.leadingAnchor),
            label2.centerYAnchor.constraint(equalTo: row2.centerYAnchor),
            button2.trailingAnchor.constraint(equalTo: row2.trailingAnchor),
            button2.centerYAnchor.constraint(equalTo: row2.centerYAnchor),
            button2.topAnchor.constraint(greaterThanOrEqualTo: row2.topAnchor, constant: 5),
            button2.bottomAnchor.constraint(lessThanOrEqualTo: row2.bottomAnchor, constant: -5)
        ])

        let row3 = UIStackView(arrangedSubviews: [sumLabel, UIView(), sumValueLabel])
        let sortRow = UIStackView(arrangedSubviews: [sortLabel, UIView(), sortBtn, chevron])
        sortRow.alignment = .center
        sortRow.setCustomSpacing(0, after: sortBtn)

        let divider1 = UIView()
        divider1.backgroundColor = UIColor.systemGray4
        divider1.translatesAutoresizingMaskIntoConstraints = false
        divider1.heightAnchor.constraint(equalToConstant: 1).isActive = true
        let divider2 = UIView()
        divider2.backgroundColor = UIColor.systemGray4
        divider2.translatesAutoresizingMaskIntoConstraints = false
        divider2.heightAnchor.constraint(equalToConstant: 1).isActive = true
        let divider3 = UIView()
        divider3.backgroundColor = UIColor.systemGray4
        divider3.translatesAutoresizingMaskIntoConstraints = false
        divider3.heightAnchor.constraint(equalToConstant: 1).isActive = true
        let vstack = UIStackView(arrangedSubviews: [
            row1,
            divider1,
            row2,
            divider2,
            row3,
            divider3,
            sortRow
        ])
        vstack.axis = .vertical
        vstack.spacing = 0
        vstack.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(vstack)
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: headerCard.topAnchor),
            vstack.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            vstack.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            vstack.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor),
            divider1.leadingAnchor.constraint(equalTo: vstack.leadingAnchor),
            divider1.trailingAnchor.constraint(equalTo: vstack.trailingAnchor),
            divider2.leadingAnchor.constraint(equalTo: vstack.leadingAnchor),
            divider2.trailingAnchor.constraint(equalTo: vstack.trailingAnchor),
            divider3.leadingAnchor.constraint(equalTo: vstack.leadingAnchor),
            divider3.trailingAnchor.constraint(equalTo: vstack.trailingAnchor)
        ])

        row3.translatesAutoresizingMaskIntoConstraints = false
        row3.heightAnchor.constraint(equalToConstant: 44).isActive = true
        sortRow.translatesAutoresizingMaskIntoConstraints = false
        sortRow.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .clear
        tableView.sectionHeaderTopPadding = 0
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }
    
    func loadTransactions() {
        Task {
            guard let accountId = bankVM.accountId else { return }
            await vm.loadTransactions(accountId: accountId, from: startDate, until: endDate)
            tableView.reloadData()
            updateSumLabel()
            DispatchQueue.main.async {
                let rows = self.vm.getTransactions(by: self.isIncome ? .income : .outcome, from: self.startDate, until: self.endDate, sortedBy: self.sortType).count
                let tableHeight = max(CGFloat(rows) * 60 + 44, 100)
                self.tableViewHeightConstraint?.constant = tableHeight
                self.scrollView.layoutIfNeeded()
            }
        }
    }
    
    private func updateSumLabel() {
        let direction: Direction = isIncome ? .income : .outcome
        let sum = vm.sumTransactionsAmount(by: direction, from: startDate, until: endDate)
        sumValueLabel.text = vm.formatAmount(sum)
    }
    
    @objc private func startDateTapped() {
        onStartDateTap?()
    }
    @objc private func endDateTapped() {
        onEndDateTap?()
    }
    @objc private func showSortPicker() {
        let alert = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        for type in SortType.allCases {
            alert.addAction(UIAlertAction(title: type.rawValue, style: .default, handler: { _ in
                self.sortType = type
                self.sortBtn.setTitle(type.rawValue, for: .normal)
                self.loadTransactions()
            }))
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        let text = formatter.string(from: date)
        var parts = text.split(separator: " ", maxSplits: 3, omittingEmptySubsequences: false).map(String.init)
        if parts.count > 1 {
            parts[1] = parts[1].capitalized(with: formatter.locale)
        }
        return parts.joined(separator: " ")
    }
    
    func setSortType(_ type: SortType) {
        sortType = type
        sortBtn.setTitle(type.rawValue, for: .normal)
        loadTransactions()
    }
}

extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let direction: Direction = isIncome ? .income : .outcome
        return vm.getTransactions(by: direction, from: startDate, until: endDate, sortedBy: sortType).count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let direction: Direction = isIncome ? .income : .outcome
        let transactions = vm.getTransactions(by: direction, from: startDate, until: endDate, sortedBy: sortType)
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        let sum = vm.sumTransactionsAmount(by: direction, from: startDate, until: endDate)
        let percent = sum > 0 ? (transactions[indexPath.row].amount as NSDecimalNumber).doubleValue / (sum as NSDecimalNumber).doubleValue : 0.0
        cell.configure(with: transactions[indexPath.row], percent: percent)
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 0
        cell.layer.masksToBounds = false
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            header.textLabel?.textColor = .secondaryLabel
            header.contentView.backgroundColor = .clear
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.backgroundView = nil
    }
}

class TransactionCell: UITableViewCell {
    
    private let iconView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "backgroundGreen") ?? UIColor.systemGreen.withAlphaComponent(0.2)
        v.layer.cornerRadius = 11
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11.5)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .center
        return l
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .regular)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let commentLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let amountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .regular)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .right
        return l
    }()
    
    private let percentLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .right
        return l
    }()
    
    private lazy var labelsStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [titleLabel, commentLabel])
        st.axis = .vertical
        st.spacing = 2
        st.translatesAutoresizingMaskIntoConstraints = false
        return st
    }()
    
    private lazy var rightStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [percentLabel, amountLabel])
        st.axis = .vertical
        st.alignment = .trailing
        st.spacing = 2
        st.translatesAutoresizingMaskIntoConstraints = false
        return st
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layoutMargins = .zero
        self.preservesSuperviewLayoutMargins = false
        contentView.layoutMargins = .zero
        accessoryType = .disclosureIndicator
        contentView.addSubview(iconView)
        iconView.addSubview(emojiLabel)
        contentView.addSubview(labelsStack)
        contentView.addSubview(rightStack)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 0
        contentView.layer.masksToBounds = false
        backgroundColor = .clear
        selectionStyle = .none
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            emojiLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            labelsStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            labelsStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightStack.leadingAnchor.constraint(greaterThanOrEqualTo: labelsStack.trailingAnchor, constant: 8),
            contentView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(with transaction: Transaction, percent: Double) {
        emojiLabel.text = String(transaction.category.emoji)
        titleLabel.text = transaction.category.name
        if !transaction.comment.isEmpty {
            commentLabel.text = transaction.comment
            commentLabel.isHidden = false
        } else {
            commentLabel.isHidden = true
        }
        amountLabel.text = "\(transaction.amount) ₽"
        percentLabel.text = String(format: "%.0f%%", percent * 100)
    }
}
