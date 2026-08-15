# Week 4: SkyPulse Weather - API Integration & Async UI

A modern Flutter weather application built to demonstrate asynchronous HTTP REST API integration, JSON parsing, dynamic state rendering via `FutureBuilder`, and robust error handling.

---

## 🎯 Project Objective
Learn and implement remote API integration in Flutter by fetching and displaying live weather metrics for any requested city worldwide.

### Key Objectives Achieved:
* **API Integration**: Connected to OpenWeatherMap REST API using the Dart `http` package.
* **Asynchronous Data Handling**: Utilized `FutureBuilder` to cleanly handle loading states, success data rendering, and runtime exceptions.
* **JSON Parsing**: Serialized raw JSON API responses into strongly typed Dart `Weather` model objects.
* **Error Handling**: Gracefully handled network timeouts, 404 city-not-found errors, and invalid API keys with user-friendly error UI.
* **Polished UI/UX**: Custom blue and sun-yellow gradient layout displaying primary temperature, dynamic icon, condition tags, and metrics (feels like, humidity, wind speed).

---

---

## 📸 Screenshots & Workflow Walkthrough

### 1. Default City View (Islamabad, PK)
On launch, the app fetches real-time weather data for the default city (Islamabad), displaying the ambient temperature, condition tag, weather icon, and detailed climate metrics.

<img width="1036" height="620" alt="ng4 1" src="https://github.com/user-attachments/assets/9a73872d-dce2-41fc-9a00-609bebce9852" />

---

### 2. Live Search & Real-Time API Update (Seoul, KR)
Entering a city name in the search field triggers a new asynchronous network request, updating the UI dynamically with the newly fetched weather condition and metrics.

<img width="1039" height="612" alt="ng4 2" src="https://github.com/user-attachments/assets/ba58712f-062f-470a-a09b-d6bab2408bbc" />


---
