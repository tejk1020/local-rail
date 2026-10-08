# 🚆 Local Rail – Mumbai Local Train Tracking & Digital Ticketing App

Local Rail is a Flutter-based mobile application designed for Mumbai local train passengers. It provides a single platform for **digital train ticket booking, ticket management, ticket transfer, online payments, and live Mumbai local train tracking**.

The application combines **Flutter, Dart, Firebase, Node.js, Express.js, Razorpay, REST APIs, and RailRadar API** to provide a modern railway travel experience.

---

## 📱 Project Overview

Mumbai local trains are one of the most important modes of daily transportation. Local Rail is designed to make railway-related services more convenient by providing important features through a mobile application.

The application allows users to:

- Create and manage their account
- Log in securely
- Book train tickets digitally
- Make online payments
- View booked tickets
- Send tickets to another user
- Receive transferred tickets
- View ticket transfer history
- Track Mumbai local trains
- View live train location
- View train routes
- View station information
- Check train delay information
- Manage their profile

---

# 🚀 Key Features

## 🔐 1. User Authentication

Local Rail uses **Firebase Authentication** for user authentication.

### Features

- User Registration
- User Login
- Secure Authentication
- User Session Management
- Remember Me functionality
- User Profile

---

## 🎫 2. Digital Train Ticket Booking

Users can book Mumbai local train tickets through the application.

The ticket booking system allows users to enter their journey details and generate a digital ticket.

### Ticket Features

- Source Station
- Destination Station
- Journey Details
- Passenger Details
- Ticket Generation
- Ticket Management

---

## 💳 3. Razorpay Payment Integration

Local Rail integrates **Razorpay** for online payment processing.

### Payment Flow

```text
Select Source & Destination
          ↓
      Ticket Details
          ↓
       Fare Amount
          ↓
     Razorpay Payment
          ↓
    Payment Verification
          ↓
      Ticket Generated
```
---
## 🚆 4. Live Mumbai Local Train Tracking
One of the major features of Local Rail is Live Train Tracking.
The application integrates the RailRadar API to obtain live Mumbai local train information.
Users can select a train and view available live information such as:
- Train Number
- Current Train Location
- Current Station
- Next Station
- Train Route
- Delay Information
- Train Coordinates
- Station Information
Live Tracking Flow
User Selects Train
        ↓
Flutter Application
        ↓
Local Rail Backend
        ↓
RailRadar API
        ↓
Live Train Information
        ↓
Train Location & Route
        ↓
Displayed in Application
---
## 📍 5. Real-Time Train Location
The live tracking feature uses train location data to display the current position of a selected train.
The system can provide:
Train Number
     ↓
Current Location
     ↓
Current / Next Station
     ↓
Delay Information
     ↓
Train Route

This helps users understand the current position and progress of their selected train.
---
## 🗺️ 6. Train Route Information
Local Rail provides train route information using railway API data.
The route functionality can provide:
- Train Route
- Stations on the Route
- Current Train Position
- Next Station
- Route Geometry
- Journey Direction

---

## 🚉 7. Station Information
The application provides railway station search and information functionality.
Users can search for railway stations and access available station-related information.

---

## 📤 8. Send Ticket
Local Rail provides a ticket transfer system that allows users to send a ticket to another user.
Transfer Flow
User A
   ↓
Select Ticket
   ↓
Enter Receiver Details
   ↓
Send Ticket
   ↓
User B
   ↓
Receive Ticket

---

## 📥 9. Receive Ticket
Users can receive tickets transferred by another Local Rail user.
Received tickets can be accessed through the ticket management section.

---

## 🔄 10. Ticket Transfer History
The application provides a transfer history feature to help users keep track of ticket transfers.
It can include:
- Sent Tickets
- Received Tickets
- Transfer Information
- Ticket Status
👤 11. User Profile
The Profile section provides access to user account information and profile-related features.
It is designed to include:
- Personal Information
- Account Details
- Settings
- Help & Support
- Notifications
---
## 🏠 Application Navigation
Local Rail uses a bottom navigation structure for easy access to the main sections.
┌──────────────────────────────────────┐
│              Local Rail              │
├──────────────────────────────────────┤
│                                      │
│          Application Content         │
│                                      │
├──────────────────────────────────────┤
│ Home │ Tickets │ Live │ Profile     │
└──────────────────────────────────────┘

🏠 Home
Provides access to major application features:
- Book Train Ticket
- Send Ticket
- Receive Ticket
- Transfer History
🎫 Tickets
Provides access to booked and managed tickets.
🚆 Live
Provides live Mumbai local train tracking.
👤 Profile
Provides access to user account and profile features.
---
## 🏗️ System Architecture
                       ┌─────────────────────┐
                       │     LOCAL RAIL      │
                       │   Flutter Mobile    │
                       │    Application      │
                       └──────────┬──────────┘
                                  │
             ┌────────────────────┼────────────────────┐
             │                    │                    │
             ▼                    ▼                    ▼
      ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
      │   Firebase   │    │   Node.js    │    │  RailRadar   │
      │ Authentication│    │   Express    │    │     API      │
      │ & Firestore  │    │   Backend    │    │              │
      └──────────────┘    └───────┬──────┘    └──────────────┘
                                  │
                                  ▼
                           ┌──────────────┐
                           │   Razorpay   │
                           │   Payments   │
                           └──────────────┘
---
## 🛠️ Technology Stack
Technology	Purpose
Flutter	Mobile application development
Dart	Programming language
Firebase Authentication	User authentication
Cloud Firestore	Cloud database
Node.js	Backend development
Express.js	REST API backend
Razorpay	Online payment integration
RailRadar API	Live train tracking
REST API	Data and service integration
Git	Version control
GitHub	Source code management

---

## 🔌 API Integration
Local Rail uses API integration to connect the mobile application with backend and railway services.
RailRadar API
RailRadar is used for railway-related information such as:
- Live train information
- Train location
- Train routes
- Station information
- Mumbai local train lookup
- Station search
Backend API
The Node.js and Express.js backend handles backend operations and communication between the application and external services.

---

## 💳 Payment Architecture
The payment system follows a backend-supported flow:
Flutter Application
        ↓
Backend Server
        ↓
Razorpay
        ↓
Payment Processing
        ↓
Payment Verification
        ↓
Ticket Processing

Sensitive payment credentials are handled through environment variables.

---

## 🔐 Security
The project follows basic security practices to avoid exposing sensitive configuration in the public repository.
Sensitive information such as API secrets and private credentials should be stored using environment variables.
Examples include:
RAZORPAY_KEY_SECRET
RAILRADAR_API_KEY

The following types of files are excluded from the repository:
- .env
- Firebase configuration files
- Service account credentials
- Private keys
- API secrets
- node_modules
- Generated files
Never add API keys, passwords, payment secrets, or private credentials directly to the GitHub repository.
