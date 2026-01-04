# Zinus Connect Blueprint

## Overview

Zinus Connect is an internal mobile application for Zinus employees, designed to streamline communication and provide a centralized helpdesk system. This document outlines the project's current state, design principles, and future development plans.

## Current Features

* **Splash Screen:** A video splash screen for an engaging app launch.
* **Authentication:** A basic login screen.
* **Dashboard:** A central navigation hub for the app's features.
* **Limbah (Waste) Management:** A feature for managing waste, including a form with a camera for image capture and watermarking.

## Design

* **Theming:** The app uses Material 3 with a blue color scheme. It supports both light and dark modes and uses custom fonts from the `google_fonts` package. A `ThemeProvider` is used to manage the theme state.
* **Routing:** Navigation is handled by the `go_router` package.
* **State Management:** The app uses the `provider` package for state management.

## Next Steps

* **UI Polish:** Refine the UI of existing screens to improve aesthetics and user experience.
* **Firebase Integration:** Integrate Firebase for features like authentication, data storage, and push notifications.
* **Code Refactoring:** Refactor the code to improve its structure and maintainability.
