import Foundation

// seat display state from the viewmodel
// the custom view turns this into colors from the theme
enum SeatVisualState {
    case available
    case selected
    case reserved
    case unavailable
    case highlighted
}
