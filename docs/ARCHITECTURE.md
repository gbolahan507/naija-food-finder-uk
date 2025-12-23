# Architecture Design

*Last updated: December 23, 2025*

## Overview

This document outlines the technical architecture for Naija Food Finder UK.

## Status

🚧 **In Planning** - Architecture decisions being finalized

## Key Decisions to Make

### 1. State Management
**Options to evaluate:**
- Provider
- Riverpod
- Bloc
- GetX

### 2. Architecture Pattern
**Considering:**
- Clean Architecture
- Feature-first structure
- MVVM

### 3. Backend
**Firebase Services:**
- Firestore (database)
- Authentication
- Cloud Storage
- Analytics

## Folder Structure (Proposed)
```
lib/
├── core/
│   ├── constants/
│   ├── utils/
│   └── theme/
├── features/
│   ├── restaurants/
│   ├── map/
│   ├── reviews/
│   └── auth/
└── shared/
    ├── widgets/
    └── models/
```

## Data Models (Draft)

### Restaurant
- id
- name
- address
- location (lat/lng)
- cuisine_types
- rating
- images
- opening_hours

### Review
- id
- restaurant_id
- user_id
- rating
- comment
- timestamp

*More details to be added as design progresses...*