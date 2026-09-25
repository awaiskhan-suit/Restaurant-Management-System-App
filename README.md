# 🍽️ Restaurant Management System

A modern **Restaurant Management System** developed with **Flutter** that provides separate functionality for **Admin** and **Customer** users. The application manages restaurant products, categories, customer orders, cart functionality, checkout, order status, invoices, and business statistics through a centralized platform.

## 🛠️ Technologies Used

* **Flutter** — Cross-platform mobile application development
* **Dart** — Application programming language
* **Firebase Authentication** — Email and password authentication
* **Cloud Firestore** — Storing and managing users, products, categories, and orders
* **Firebase Storage** — Storing product images
* **Provider / State Management** — Managing application state
* **PDF Generation** — Generating restaurant invoices
* **Material Design** — Building a modern and responsive user interface

---

## 👨‍💼 Admin Module

The Admin module provides complete control over restaurant products and customer orders.

### 📦 Product Management

Admin can:

* Add new products
* Enter product name
* Set product price
* Select product category
* Add product image
* Edit product information
* Delete products
* View products by category
* Search products using the search bar

This allows the admin to maintain and organize the restaurant's complete product catalog.

### 🧾 Order Management

Admin can manage customer orders and update their status, including:

* Accept orders
* Reject orders
* Update order status
* Manage pending orders
* Complete orders
* Mark orders as delivered
* Cancel orders
* Generate invoices from customer orders

Customers can view the updated order status from their account.

### 📊 Admin Dashboard

The admin dashboard provides an overview of restaurant performance, including:

* Total Cost
* Today's Cost
* Total Orders
* Today's Orders
* Pending Orders

This gives the admin a quick overview of important restaurant activities.

---

## 👤 Customer Module

Customers can create an account and access the restaurant's products after authentication.

### 🔐 Authentication

Customers can:

* Sign up using email and password
* Log in using email and password
* Access the restaurant home screen after successful login

### 🏠 Home Screen

After login, customers can:

* Browse available products
* Search for products
* Browse products by category
* View product information
* Select products for purchase

### 🛒 Shopping Cart

Customers can add products to their cart and manage their selected items.

The cart allows customers to:

* View selected products
* Increase product quantity
* Decrease product quantity
* Automatically update the corresponding product price
* Review their order before checkout

### 🚚 Checkout & Delivery

When the customer presses the **Checkout** button, a delivery form is displayed.

The customer can enter the required delivery information and submit the order.

After successfully submitting the delivery information, the application displays a **successful order message**.

### 📦 Order Tracking

Customers can track the status of their orders, such as:

* Pending
* Accepted
* Completed
* Delivered
* Cancelled
* Rejected

When the admin changes an order status, the updated status can be viewed by the customer.

### 🧾 Invoice

Admin can generate an invoice based on the customer's order and provide the invoice information to the customer.

---

## ⭐ Key Features

* 👨‍💼 Admin & Customer Modules
* 🔐 Email & Password Authentication
* 📦 Product Management
* 🏷️ Category Management
* 🔍 Product Search
* 🛒 Shopping Cart
* ➕➖ Quantity Management
* 💰 Automatic Price Calculation
* 🚚 Delivery Information
* 📦 Order Management
* 🔄 Order Status Tracking
* 🧾 Invoice Generation
* 📊 Admin Dashboard
* 📈 Sales & Order Statistics
* ☁️ Firebase Backend Integration
* 📱 Flutter Cross-Platform Development

---

## 🎯 Project Objective

The main objective of this project is to provide a complete **digital restaurant management and ordering solution** that connects restaurant administration with customers.

The system simplifies product management, online ordering, cart management, checkout, delivery information, order tracking, invoice generation, and restaurant performance monitoring through a user-friendly mobile application.

## 🚀 Project Highlights

* Separate **Admin and Customer** functionality
* Real-time restaurant product and order management
* Secure user authentication
* Dynamic cart and quantity management
* Automated order price calculation
* Order status monitoring
* Invoice generation
* Restaurant business statistics
* Firebase-powered backend
* Modern Flutter-based mobile UI
