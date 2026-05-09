import SwiftUI

struct ThemeToggleButton: View {
    var appTheme: Binding<AppTheme>
    var resolvedIsDark: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color(red: 0.06, green: 0.06, blue: 0.06))
                .frame(width: 30, height: 26)

            HStack {
                if resolvedIsDark {
                    Spacer()
                }

                RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                    .fill(Color(red: 0.95, green: 0.42, blue: 0.11))
                    .frame(width: 10, height: 20)
                    .padding(.horizontal, 3)

                if !resolvedIsDark {
                    Spacer()
                }
            }
            .frame(width: 30, height: 26)
        }
        .frame(width: 30, height: 26)
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                appTheme.wrappedValue = appTheme.wrappedValue.next
            }
        }
    }
}

#Preview("Light") {
    ThemeToggleButton(appTheme: .constant(.light), resolvedIsDark: false)
        .padding()
}

#Preview("Dark") {
    ThemeToggleButton(appTheme: .constant(.dark), resolvedIsDark: true)
        .padding()
        .preferredColorScheme(.dark)
}
