import SwiftUI

struct IntroView: View {
    var body: some View {
        // NavigationView нужен для перехода на следующий экран
        NavigationView {
            VStack(spacing: 10) {
                Spacer() // Толкает контент к центру по вертикали
                
                // Логотип
                Text("Wandrly")
                    // Используем системный шрифт, но делаем его более "округлым"
                    // Это хороший компромисс, пока мы не добавляем кастомные шрифты
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(Color.accentColor) // Используем наш настроенный AccentColor
                
                // Подзаголовок
                Text("Where can you go next?")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Spacer() // Создает пространство между текстом и кнопкой
                Spacer() // Двойной Spacer, чтобы текст был выше центра
                
                // Ссылка-кнопка для перехода на главный экран
                NavigationLink(destination: HomeView()) {
                    Text("Start Searching")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.accentColor) // Используем наш настроенный AccentColor
                        .foregroundColor(.white)
                        .cornerRadius(25) // Более скругленные углы
                }
                .padding(.horizontal, 24) // Отступы по бокам для кнопки
                .padding(.bottom, 20) // Отступ кнопки от нижнего края
            }
            // Отступ для всего экрана от краев
            .padding()
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
