# CurrenSee - The Real-Time Currency Converter 💸

> A secure and feature-rich cross-platform mobile application for real-time currency conversion and financial tracking, commissioned by ABC Finance Ltd..

## 🌟 **Overview**

The **CurrenSee** application is designed to meet the financial needs of a broad user base, including individuals, travelers, and businesses. Developed using Flutter, its primary goal is to provide fast, accurate, and real-time currency conversion, alongside access to historical data and market news.

## ✨ **Key Features**

### 📱 User Functionality (Mobile App)

* **Secure Authentication:** Users can securely create accounts or log in using mechanisms like email/password or social media login.
* **Real-Time Conversion:** Users can select base and target currencies, enter an amount, and the app calculates and displays the converted amount using real-time exchange rates.
* **Currency List & Search:** Provides a searchable and filterable list of supported currencies, displaying their respective symbols and names.
* **Historical Rate Data:** Users can view detailed information about exchange rates, including trends over time using historical data.
* **Conversion History:** The app stores a history of currency conversion transactions, allowing users to view past details (date, rates, and amounts).
* **Rate Alerts:** Users can set rate alerts for specific currency pairs and receive notifications when the exchange rate reaches the specified threshold.
* **Market News & Trends:** Access to news, articles, market trend information, charts, and analysis related to currency markets.
* **Preferences:** Users can set their default base currency and the app remembers preferred conversion settings.

### 🔒 Admin Functionality (Admin Panel)

* **Admin Dashboard:** A dedicated Admin Panel is available for administrative oversight.
* **User Management:** The Admin can view all registered users.
* **Transaction Monitoring:** The Admin can view all user conversion requests and transactions saved within the Admin Panel.
* **Access Details:** Admin credentials and usage instructions are provided in the **Developer Guide** document and demonstrated in the **`currensee ScreenRecoding`** file, both located in the project root folder.

## ⚙️ **Non-Functional Requirements**

| Requirement | Description |
| :--- | :--- |
| **Responsiveness** | The app should respond to user interactions within **1-2 seconds**, ensuring a smooth, lag-free experience. |
| **Security** | Adequate security measures, such as authentication, are implemented to ensure only registered users access certain features. |
| **Usability (UI/UX)** | The interface is intuitive, accessible (clear and legible fonts/elements), user-friendly, and follows mobile best design practices. |
| **Scalability** | The architecture is designed to handle increasing user traffic, data storage, and future feature expansions. |
| **Error Handling** | Robust error handling is implemented to provide clear error messages and gracefully handle unexpected situations. |

## 🛠️ **Tech Stack & Setup**

* **Framework:** **Flutter**
* **Language:** **Dart**
* **OS:** Windows 2000 Server or higher

### ⬇️ **Installation Steps**

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/Taijkhan/Currensee-Eproject.git
    ```

2.  **Navigate to Project Folder:**
    ```bash
    cd CurrenSee
    ```

3.  **Install Dependencies:**
    Upon opening the folder, **run `flutter pub get`** to install all required packages:
    ```bash
    flutter pub get
    ```

4.  **Run the Application:**
    Select your desired device/simulator and run:
    ```bash
    flutter run
    ```

## 🤝 **Contributing**

We welcome contributions! Please open an issue in the **Issues** section or submit a **Pull Request (PR)** with any suggestions or bug reports.


## 📄 **License**

This project is licensed under the **MIT License**. See the `LICENSE` file for more details.
---
