Frontend scaffold for HelpLink — entities and quick start

Getting started

- cd frontend
- npm install
- npm run dev

Entities

This folder contains simple JSON schema files used by the UI during development (no backend required). They describe the shape of the core objects used across the app:

- User.json — basic profile and karma
- HelpRequest.json — requests posted by users
- BookExchange.json — book donation/request entries
- Announcement.json — announcements/events

You can use these files for mocking data, generating TypeScript types, or validating payloads in tests.
