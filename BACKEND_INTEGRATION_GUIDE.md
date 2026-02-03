# Backend Integration Guide - Login Feature

This guide explains how the login feature is integrated with the backend using Clean Architecture principles.

## Architecture Overview

The project follows **Clean Architecture** with three main layers:

1. **Domain Layer** (`lib/domain/`)
   - Entities: Pure business objects
   - Repositories: Interfaces defining data operations
   - Use Cases: Business logic

2. **Data Layer** (`lib/data/`)
   - Models: Data transfer objects (DTOs)
   - Data Sources: Remote (API) and Local (Storage)
   - Repository Implementations: Concrete implementations of domain repositories

3. **Presentation Layer** (`lib/app/`)
   - Controllers: State management (GetX)
   - Views: UI components
   - Bindings: Dependency injection setup

## Setup Instructions

### 1. Update API Base URL

Edit `lib/core/constants/api_constants.dart` and update the `baseUrl`:

```dart
static const String baseUrl = 'https://your-api-domain.com/api/v1';
```

### 2. Install Dependencies

Run the following command to install the new dependencies:

```bash
flutter pub get
```

### 3. Expected API Response Format

The login endpoint should return a JSON response in one of these formats:

**Format 1:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user_id": "123",
  "username": "john_doe",
  "phone_number": "0912345678",
  "message": "Login successful"
}
```

**Format 2 (Nested data):**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user_id": "123",
    "username": "john_doe",
    "phone_number": "0912345678"
  },
  "message": "Login successful"
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Invalid credentials",
  "error": "Invalid phone number or password"
}
```

### 4. API Request Format

The login endpoint expects a POST request to `/auth/login` with:

```json
{
  "phone_number": "0912345678",
  "password": "user_password"
}
```

## Features Implemented

### ✅ Loading State
- The login button shows a loading spinner while the API request is in progress
- The button is disabled during loading to prevent multiple submissions

### ✅ Error Handling
- Network errors (timeout, no connection)
- API errors (401, 404, etc.)
- Validation errors (empty fields, invalid phone format)
- User-friendly error messages displayed in dialogs

### ✅ Local Storage
- Authentication token is saved automatically after successful login
- User data (username, phone, userId) is stored locally
- Data persists across app restarts

### ✅ Password Visibility Toggle
- Users can toggle password visibility using the eye icon
- State is managed reactively using GetX

## File Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart          # API endpoints and configuration
│   ├── di/
│   │   └── injection_container.dart    # Dependency injection setup
│   └── network/
│       └── dio_client.dart             # HTTP client configuration
├── domain/
│   ├── entities/
│   │   └── login_entity.dart           # Domain entities
│   ├── repositories/
│   │   └── auth_repository.dart        # Repository interface
│   └── usecases/
│       └── login_usecase.dart          # Login business logic
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   └── auth_local_datasource.dart    # Local storage
│   │   └── remote/
│   │       └── auth_remote_datasource.dart   # API calls
│   ├── models/
│   │   └── login_model.dart            # Data models
│   └── repositories/
│       └── auth_repository_impl.dart   # Repository implementation
└── app/
    └── modules/
        └── login/
            ├── bindings/
            │   └── login_binding.dart  # Controller binding
            ├── controllers/
            │   └── login_controller.dart  # State management
            └── views/
                └── login_view.dart     # UI
```

## Usage

### In the Login View

The login button automatically:
1. Validates input fields
2. Shows loading state
3. Calls the backend API
4. Handles success/error responses
5. Navigates to home on success
6. Shows error dialogs on failure

### Accessing User Data

After login, user data is stored in GetStorage and can be accessed:

```dart
final storage = Get.find<GetStorage>();
final username = storage.read('username');
final phone = storage.read('phone');
final token = storage.read('auth_token');
```

## Customization

### Changing API Endpoint

Edit `lib/core/constants/api_constants.dart`:

```dart
static const String loginEndpoint = '/your/custom/login/endpoint';
```

### Modifying Request/Response Format

1. Update `LoginModel.toJson()` in `lib/data/models/login_model.dart` for request format
2. Update `LoginResponseModel.fromJson()` in the same file for response format

### Adding Request Headers

Edit `lib/core/network/dio_client.dart` to add custom headers:

```dart
_dio = Dio(
  BaseOptions(
    // ... existing options
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Custom-Header': 'value',  // Add custom headers here
    },
  ),
);
```

## Testing

To test the login flow:

1. **With Backend**: Update the base URL and test with real API
2. **Without Backend**: You can mock the API response in `auth_remote_datasource.dart` for development

## Troubleshooting

### Error: "No internet connection"
- Check device network connectivity
- Verify API base URL is correct

### Error: "Connection timeout"
- Check if backend server is running
- Verify API endpoint is correct
- Increase timeout in `api_constants.dart` if needed

### Error: "Invalid credentials"
- Verify phone number format (Ethiopian: 09XXXXXXXX)
- Check password is correct
- Verify backend authentication logic

## Next Steps

1. Update `api_constants.dart` with your actual backend URL
2. Test the login flow with your backend
3. Adjust response parsing if your API format differs
4. Add additional authentication features (refresh token, logout, etc.)

