import SwiftUI

// Наш кастомный компонент для кнопки-тега
struct TagButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void // Действие, которое будет выполняться при нажатии
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : .blue) // Цвет текста меняется
                .background(isSelected ? Color.blue : Color.clear) // Фон меняется
                .cornerRadius(10)
                .overlay( // Добавляем рамку
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
        }
    }
}
