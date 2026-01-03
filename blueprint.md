# Zinus Connect Mobile App Blueprint

## Overview

Zinus Connect is an internal mobile application for Zinus employees, designed to streamline communication and provide a centralized helpdesk system. The app will feature:

*   **Real-time Chat:** Secure and efficient communication between employees and teams.
*   **Helpdesk & Ticketing:** A system for creating, tracking, and resolving internal support tickets.
*   **File & Image Sharing:** Seamlessly share documents and images within chats and tickets.
*   **Push Notifications:** Instant alerts for new messages, ticket updates, and important announcements.

## Style, Design, and Features (Initial Outline)

This section will be updated as the app is developed.

*   **UI/UX:**
    *   Clean, modern, and intuitive user interface following Material Design principles.
    *   Consistent branding with Zinus's corporate identity.
    *   Light and dark theme options.
*   **Core Features:**
    *   User authentication (initially with mock data, later with a proper backend).
    *   Dashboard/Home screen with an overview of recent activity.
    *   Chat module with one-on-one and group messaging.
    *   Helpdesk module with ticket creation, assignment, and status tracking.
    *   Search functionality for messages and tickets.
    *   User profile and settings.

## Current Task: Fix Dependency Issues and Run App

The initial goal is to get the application running after resolving dependency conflicts.

**Steps Taken:**

1.  **Analyzed `flutter run` Error:** The initial `flutter run` command failed due to a version conflict with the `go_router` package.
2.  **Corrected `go_router` Version:** The `pubspec.yaml` file was updated to use a valid version of `go_router` (`^17.0.1`).
3.  **Resolved `socket_io_client` Conflict:** After fixing `go_router`, another conflict was found with `socket_io_client`. The version was updated to a compatible one (`^2.0.3+1`) as suggested by the `flutter pub` tool.
4.  **Verified Dependencies:** `flutter pub get` was run successfully to ensure all dependencies are correctly installed.
5.  **Next Step:** Run the application to confirm it builds and launches without errors.
