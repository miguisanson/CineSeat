import Foundation

// module 2 event schedule viewmodel
// date time venue price and quantity rules stay outside the event detail screen
final class EventScheduleViewModel {
    let event: EventListing
    private let showings: [EventShowing]
    private(set) var selectedScheduleIndex: Int?
    private(set) var selectedTimeIndex: Int?
    private(set) var quantity = 1

    init(event: EventListing, fetchEventShowingsUseCase: FetchEventShowingsUseCase) {
        self.event = event
        showings = fetchEventShowingsUseCase.execute().filter { $0.eventID == event.id }
        selectedScheduleIndex = selectedShowing?.schedules.isEmpty == false ? 0 : nil
        selectedTimeIndex = selectedSchedule?.times.isEmpty == false ? 0 : nil
    }

    convenience init(event: EventListing, showings: [EventShowing]? = nil) {
        self.init(
            event: event,
            fetchEventShowingsUseCase: DefaultFetchEventShowingsUseCase(
                showingFetcher: MockEventShowingAPIClient(showings: showings ?? SeedData.eventShowings)
            )
        )
    }

    var selectedShowing: EventShowing? { showings.first }

    var selectedSchedule: EventSchedule? {
        guard let selectedScheduleIndex,
              let showing = selectedShowing,
              showing.schedules.indices.contains(selectedScheduleIndex) else { return nil }
        return showing.schedules[selectedScheduleIndex]
    }

    var selectedTime: EventTime? {
        guard let selectedTimeIndex,
              let selectedSchedule,
              selectedSchedule.times.indices.contains(selectedTimeIndex) else { return nil }
        return selectedSchedule.times[selectedTimeIndex]
    }

    var minimumDate: Date? { selectedShowing?.schedules.map(\.date).min() }
    var maximumDate: Date? { selectedShowing?.schedules.map(\.date).max() }
    var isBookingAvailable: Bool { selectedSchedule != nil && selectedTime != nil }
    var venue: EventVenue? { selectedTime?.venue }
    var ticketPrice: Double { selectedTime?.ticketPrice ?? 0 }
    var subtotal: Double { Double(quantity) * ticketPrice }
    var total: Double { subtotal + AppConstants.Booking.defaultFee }

    var maximumQuantity: Int {
        min(selectedTime?.capacity ?? 1, AppConstants.Booking.maximumEventTickets)
    }

    func selectDate(_ date: Date) {
        guard let showing = selectedShowing,
              let index = showing.schedules.firstIndex(where: {
                  CineSeatDateFormatters.isSameDay($0.date, date)
              }) else { return }
        selectedScheduleIndex = index
        selectedTimeIndex = showing.schedules[index].times.isEmpty ? nil : 0
        quantity = min(quantity, maximumQuantity)
    }

    func selectTime(at index: Int) {
        guard let selectedSchedule, selectedSchedule.times.indices.contains(index) else { return }
        selectedTimeIndex = index
        quantity = min(quantity, maximumQuantity)
    }

    func setQuantity(_ newQuantity: Int) {
        quantity = min(max(newQuantity, 1), maximumQuantity)
    }

    func makeDraft() -> EventBookingDraft? {
        guard let selectedSchedule, let selectedTime else { return nil }
        return EventBookingDraft(
            event: event,
            schedule: selectedSchedule,
            time: selectedTime,
            quantity: quantity
        )
    }
}
