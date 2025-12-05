🍽️ Hey Waiter! – Restaurant Service Request System

Hey Waiter! is a Flutter-based web and mobile application designed to help restaurants streamline customer service, server workflow, and table management. Customers can submit service requests directly from their table, while employees and managers track and manage these requests through real-time dashboards powered by Firebase.

🚀 Features
🟣 Customer Interface

A clean and simple UI where customers can request:
Refills (Coke, Sprite, Water, etc.)
Desserts (Brownie, Cheesecake, Ice Cream)
Extras (Napkins, Ketchup, Ranch, Breadsticks)
Call Server
View Menu (PDF displayed in-app)
Each request:
Sends live updates to Firestore
Includes table number, timestamp, and status
Automatically appears on the Server Dashboard
🟡 Employer Dashboard (Server Dashboard)
Real-time dashboard using Firestore streams.
Includes:
Live Requests Tab
Shows Pending and In-Progress
Status buttons: Start → In-Progress, Done → Completed
Real-time auto-refresh
Category filter chips (Refills, Desserts, Extras, Call Server)
History Tab
Shows all completed requests
Includes a “Clear Done” button to remove all completed items
KPI Metrics Bar
Pending count
In-Progress count
Done count
🔵 Manager Dashboard
Includes everything employees have, PLUS:
Dedicated Manager Dashboard screen
Table Layout Page with 15 tables
Tables change color automatically:
🟢 Green = No active requests
🔴 Red = Table has active requests
This page provides a simple overview of the restaurant’s activity.
🟢 Menu PDF Viewer
Displays a restaurant menu stored in Firebase Storage
Opens inside the app (not a new tab)
🔐 Authentication
Role-based login:
Employee Login → Server Dashboard
Manager Login → Manager Dashboard
☁️ Firebase Integration
The app uses:
Firebase Core
Firebase Firestore
Firebase Storage
Firestore powers:
Real-time updates
Status changes
Table activity indicators
History tracking
🛠️ Tech Stack
Frontend
Flutter 3
Dart
Material Design 3
Responsive UI / Flutter Web
Backend
Firebase Firestore
Firebase Storage
Tools
GitHub Codespaces
GitHub PR workflow
StreamBuilder + TabController
📁 Project Structure
lib/
 ├── main.dart
 ├── Utils/
 │    ├── selection_tools.dart
 │    ├── item_counter.dart
 ├── screens/
 │    ├── Selection_screen.dart
 │    ├── item_selection_page.dart
 │    ├── employee_login.dart
 │    ├── employer_dashboard.dart
 │    ├── manager_dashboard.dart
 │    ├── manager_table_layout.dart
 │    ├── server_dashboard.dart
 │    ├── role_login_page.dart
 │    ├── menu_pdf_viewer.dart

📲 App Flow
Customer Flow
Customer opens the app (usually via QR code)
Picks a category
Submits a request
Request shows instantly in Firestore
Server sees it in Live tab
Employee Flow
Logs in
Views active requests
Presses Start → request goes In-Progress
Presses Done → moves to History
Manager Flom
Logs in as Manager
Accesses manager-specific dashboard
Opens Table Layout page
Watches table status update live
🧹 Future Enhancements
Assign servers to tables
Push notifications
Customer request history per table
QR code system (one per table)
Shift manager & break monitoring
Multi-restaurant support
👥 Contributors
KBD Solutions Team
Development by:
Kevin B.

Brandon

Douglas