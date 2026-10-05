# 🚆 Local Rail

### Mumbai Local Train Tracking & Digital Ticketing App

Local Rail is a Flutter-based mobile application designed to make Mumbai local train travel more convenient by providing digital ticketing, ticket management, ticket transfer and real-time train tracking features.

The application combines Flutter, Firebase, Node.js, REST APIs, RailRadar and Razorpay to provide a complete mobile railway travel experience.

---

## 📱 Project Overview

Mumbai's suburban railway network is one of the busiest railway systems in India. Passengers often need to manage tickets, check train information and track trains while travelling.

Local Rail aims to provide these services through a single mobile application.

The application provides:

- Digital Mumbai local train ticket booking
- Ticket management
- QR-based ticket viewing
- Ticket transfer functionality
- Real-time Mumbai local train tracking
- Live train status
- Current train location
- Train route information
- Firebase authentication
- User profile management
- Online payment integration

---

## ✨ Features

### 🎫 Ticket Booking

Users can book Mumbai local train tickets by selecting their journey details.

Features include:

- Source station
- Destination station
- Number of passengers
- Journey date
- Fare calculation
- Ticket generation

---

### 🎟️ My Tickets

Users can view their booked tickets from the My Tickets section.

Each ticket displays information such as:

- Source station
- Destination station
- Passenger count
- Total fare
- Journey date
- Train type
- Ticket validity
- QR code

---

### 🔄 Ticket Transfer

Local Rail provides functionality for transferring tickets between users.

The application includes:

- Send ticket
- Receive ticket
- Transfer history

---

### 🚆 Live Train Tracking

The Live Trains section provides real-time Mumbai suburban train information.

Users can:

- Search for a source station
- Select a destination
- View available trains
- View train status
- View current station
- View next station
- View live train location
- View route information

Live train information is obtained through the RailRadar API.

---

### 📍 Real-Time Train Location

The application displays the train's current geographical position and railway route.

The live tracking system uses:

- Train coordinates
- Railway route geometry
- Current station
- Next station
- Train status
- Last updated time

---

### 💳 Online Payment

Razorpay is integrated for online payment processing.

The payment system uses a backend service to securely create payment orders and process transactions.

---

### 🔐 Firebase Authentication

Firebase Authentication is used for user authentication.

The application supports:

- User registration
- User login
- Logout
- Remember Me functionality

---

### ☁️ Cloud Firestore

Cloud Firestore is used to store application data.

User information includes:

- Name
- Email
- Phone number
- User ID
- Role
- Account creation information

---

### 👤 User Profile

The Profile section provides access to user-related information and account options.

---

## 🛠️ Technology Stack

### Frontend

- Flutter
- Dart
- Material Design

### Backend

- Node.js
- Express.js
- REST API

### Database & Authentication

- Firebase Authentication
- Cloud Firestore

### APIs & Services

- RailRadar API
- Razorpay

### Development Tools

- Android Studio
- Visual Studio Code
- Git
- GitHub

---

## 🏗️ Application Architecture

```text
                    ┌──────────────────────┐
                    │     Local Rail       │
                    │   Flutter Android    │
                    │      Application     │
                    └──────────┬───────────┘
                               │
                 ┌─────────────┼─────────────┐
                 │             │             │
                 ▼             ▼             ▼
          Firebase Auth    Firestore      Backend
                                           │
                              ┌────────────┼────────────┐
                              │            │            │
                              ▼            ▼            ▼
                         RailRadar     Razorpay     REST APIs
