

---

Student Support System

Overview

The **Student Support System** is an application designed to assist students by providing timely information, support, and resources for their academic journey. This platform integrates chat assistance, event tracking via a calendar, and the AI-powered assistant, **Gemini**, to deliver dynamic and personalized support to students. The system is built using **Flutter** and **Firebase** for seamless integration of front-end user interaction and back-end data management.

 Features

 1. Calendar Integration
- Displays important academic events, news, and announcements on a calendar with visual indicators (dots on the calendar) for days containing news.
- Easy navigation to view detailed descriptions of events or news on selected dates.

2. Weekly News Section
- A real-time stream of news and announcements displayed using **Firestore**, ensuring that students are updated with the latest information.
  
3. User Profile Management
- Users can view their profile settings on the **Settings** page, which includes a centered user logo and the student’s name retrieved from Firestore.
- Includes a **Logout** feature that clears session data using **Shared Preferences**.

### 4. **Chat Assistance**
- The system includes a chat-based assistant to handle various student inquiries, including course details, exam schedules, and campus resources.
- Initial recommendations include 'results,' 'schedule,' and 'courses,' making the interface intuitive and accessible.

### 5. **Gemini AI Assistant**
- **Gemini** is an AI-powered assistant designed to provide students with personalized help.
- Gemini can dynamically interact with students, offering support on FAQs, course guidance, and other academic assistance.

## Technologies Used

- **Flutter**: For building the mobile interface and creating a smooth and responsive UI.
- **Firebase Firestore**: A NoSQL cloud database used for storing news and student data.
- **Shared Preferences**: Used for maintaining user session data.
- **Table Calendar**: A Flutter package used for the calendar component, displaying events and notifications.
- **Gemini**: An AI assistant integrated to assist students dynamically.

## Setup Instructions

### Prerequisites
- Install [Flutter](https://flutter.dev/docs/get-started/install) and set it up on your local machine.
- Install [Firebase CLI](https://firebase.google.com/docs/cli) for Firebase integration.
- Ensure you have an Android/iOS device or emulator set up for testing.

### Installation

1. Clone the Repository:

   ```bash
   git clone https://github.com/your-username/student-support-system.git
   cd student-support-system
   ```

2. Install Dependencies:

   Run the following command to install the required Flutter packages:

   ```bash
   flutter pub get
   ```

3. Firebase Setup:

   - Set up a Firebase project and enable **Firestore**.
   - Download your `google-services.json` (for Android) and/or `GoogleService-Info.plist` (for iOS), and place them in the respective directories in your Flutter project.

4. **Run the Application:**

   Use the following command to run the application on a connected device or emulator:

   ```bash
   flutter run
   ```

## Firestore Structure

- **users** collection:
  - Each document represents a user, identified by their index.
  - Fields:
    - `name`: The user's name.
    - `index`: The user's index in the system.

- News collection:
  - Each document represents a news item.
  - Fields:
    - `title`: Title of the news.
    - `news`: News description.
    - `from`: Source of the news.
    - `time`: Timestamp for the event.

Screens

Home Screen
- Displays a calendar view where users can see events/news marked with dots on specific dates.
- Includes a real-time **weekly news section** retrieved from Firestore.
- ![home](https://github.com/user-attachments/assets/7f33ce82-4176-4f58-af86-65a18c76d5ad)



 Settings Screen
- Displays the user profile with a circular avatar and user name fetched from Firestore.
- Includes a logout button.
- 
![settings ](https://github.com/user-attachments/assets/c182d647-8909-4f17-9d38-ce6a9d999793)

 Chat Screen
- Features a **chatbot interface** where students can interact with the assistant for help with results, schedules, courses, and more.

  Gemini :

![gemini](https://github.com/user-attachments/assets/5349f0ee-3f18-4dc4-9980-0a53edd29a36)

Future assistance :

![future assitance ](https://github.com/user-attachments/assets/98aac89c-efe0-4a45-97e3-d3fe315a7e60)



 Future Enhancements

- Integrating more advanced natural language processing capabilities into **Chat assistance i** for improved user interaction.
- Expanding the notification system to allow for push notifications on upcoming events.
- Additional features for real-time collaboration among students and faculty.
