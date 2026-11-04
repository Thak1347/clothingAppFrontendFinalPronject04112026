# Clothing App

The Flutter client for the clothing e-commerce project. It provides the storefront, customer account and address screens, cart and checkout, payment and order tracking, receipts, notifications, and an administrator dashboard.

The Laravel JSON API is the sibling `clothing-api/` project. See [`../clothing-api/README.md`](../clothing-api/README.md) for backend setup, API endpoints, database details, and server-side payment configuration.

## Contents

1. [Requirements and run the app](#1-requirements-and-run-the-app)
2. [Project structure](#2-project-structure)
3. [App startup and dependency setup](#3-app-startup-and-dependency-setup)
4. [Architecture and data flow](#4-architecture-and-data-flow)
5. [Feature guide](#5-feature-guide)
6. [Customer workflows](#6-customer-workflows)
7. [Storage, networking, and errors](#7-storage-networking-and-errors)
8. [Flavors and environment configuration](#8-flavors-and-environment-configuration)
9. [Maps, Firebase, and notifications](#9-maps-firebase-and-notifications)
10. [Tests and quality checks](#10-tests-and-quality-checks)

## 1. Requirements and run the app

- Flutter SDK with Dart 3.5 or later (`pubspec.yaml` requires Dart `>=3.5.0 <4.0.0`)
- Android Studio or Xcode for the platform you want to run
- A reachable instance of the Laravel API
- Google Maps API keys for map-enabled builds
- Flavor-specific Firebase configuration for push notifications

From this directory, install packages and launch the development flavor:

```powershell
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart
```

The dev API URL is set in `lib/core/config/env.dart` to `http://10.0.2.2:8000/api/v1`, which reaches the host computer from the Android emulator. A physical phone needs a reachable computer LAN IP and a Laravel server bound to the network, for example:

```powershell
php artisan serve --host=0.0.0.0
```

Update the dev URL in `lib/core/config/env.dart` if the API is not reachable at that address. Staging and production URLs are also set there.

`lib/main.dart` intentionally throws an error. Always select the matching flavor entry point instead of launching the unflavored target.

## 2. Project structure

```text
clothing_app/
  lib/
    main.dart                         Disabled unflavored entry point
    main_dev.dart                     Development bootstrap
    main_staging.dart                 Staging bootstrap
    main_prod.dart                    Production bootstrap
    flavors.dart                      Active flavor and display title
    firebase.dart                     Select Firebase options for active flavor
    app/
      app.dart
      bindings/
        initial_binding.dart
      routes/
        admin_route_middleware.dart
        app_pages.dart
        app_routes.dart
      theme/
        app_colors.dart
        app_spacing.dart
        app_text_styles.dart
        app_theme.dart
    core/
      config/
        env.dart
      constants/
        api_endpoints.dart
        storage_keys.dart
      errors/
        error_mapper.dart
        failures.dart
      network/
        auth_interceptor.dart
        dio_client.dart
      storage/
        prefs_storage.dart
        secure_storage.dart
      utils/
        asset_resolver.dart
        currency_formatter.dart
        image_url_resolver.dart
      widgets/
        app_bottom_navigation_bar.dart
        app_button.dart
        app_text_field.dart
        empty_view.dart
        error_view.dart
        loading_view.dart
        phone_number_field.dart
        product_card.dart
    features/
      addresses/
        data/
          datasources/address_remote_datasource.dart
          models/address_model.dart
          repositories/address_repository_impl.dart
        domain/
          entities/address.dart
          repositories/address_repository.dart
        presentation/
          controllers/addresses_controller.dart
          pages/
            address_form_page.dart
            address_list_page.dart
            map_picker_page.dart
          widgets/address_tile.dart
      admin/
        presentation/
          controllers/admin_controller.dart
          pages/
            admin_catalog_page.dart
            admin_categories_page.dart
            admin_dashboard_page.dart
            admin_orders_page.dart
            admin_overview_page.dart
            admin_payments_page.dart
            admin_products_page.dart
          widgets/admin_form_dialogs.dart
      auth/
        data/
          datasources/auth_remote_datasource.dart
          models/user_model.dart
          repositories/auth_repository_impl.dart
        domain/
          entities/user.dart
          repositories/auth_repository.dart
        presentation/
          controllers/auth_controller.dart
          pages/
            login_page.dart
            register_page.dart
      cart/
        data/
          datasources/cart_local_datasource.dart
          repositories/cart_repository_impl.dart
        domain/
          entities/cart_item.dart
        presentation/
          controllers/cart_controller.dart
          pages/cart_page.dart
          widgets/cart_item_tile.dart
      catalog/
        data/
          datasources/product_remote_datasource.dart
          models/
            category_model.dart
            product_model.dart
          repositories/catalog_repository_impl.dart
        domain/
          entities/
            category.dart
            product.dart
            product_variant.dart
          repositories/catalog_repository.dart
        presentation/
          catalog_binding.dart
          controllers/catalog_controller.dart
          pages/catalog_page.dart
          widgets/
            filter_sheet.dart
            sort_dropdown.dart
      checkout/
        data/
          datasources/checkout_remote_datasource.dart
          models/
            checkout_preview_model.dart
            order_model.dart
          repositories/checkout_repository_impl.dart
        domain/
          entities/
            checkout_preview.dart
            order.dart
          repositories/checkout_repository.dart
        presentation/
          controllers/checkout_controller.dart
          pages/
            checkout_page.dart
            order_confirmation_page.dart
      home/
        data/repositories/home_repository_impl.dart
        presentation/
          home_binding.dart
          controllers/home_controller.dart
          pages/home_page.dart
          widgets/
            banner_carousel.dart
            category_chips.dart
            new_arrivals_section.dart
      notifications/
        data/
          datasources/fcm_datasource.dart
          repositories/notification_repository_impl.dart
        domain/
          entities/app_notification.dart
          repositories/notification_repository.dart
        presentation/
          controllers/notification_controller.dart
          pages/notification_settings_page.dart
          services/
            local_notification_service.dart
            push_service.dart
      orders/
        data/
          datasources/orders_remote_datasource.dart
          models/order_list_model.dart
          repositories/orders_repository_impl.dart
        domain/
          entities/order.dart
          repositories/orders_repository.dart
        presentation/
          controllers/
            order_detail_controller.dart
            orders_controller.dart
          pages/
            order_detail_page.dart
            orders_page.dart
          widgets/order_status_chip.dart
      payments/
        data/
          datasources/payment_remote_datasource.dart
          repositories/payment_repository_impl.dart
        domain/
          entities/payment.dart
          repositories/payment_repository.dart
        presentation/
          controllers/payment_controller.dart
          pages/
            hosted_checkout_page.dart
            payment_page.dart
            payment_sucessful_screen.dart
          widgets/qr_display.dart
      product_details/
        presentation/
          product_details_binding.dart
          controllers/product_details_controller.dart
          pages/product_details_page.dart
          widgets/
            color_selector.dart
            product_image_gallery.dart
            quantity_stepper.dart
            size_selector.dart
      profile/
        data/
          datasources/profile_remote_datasource.dart
          models/user_profile_model.dart
          repositories/profile_repository_impl.dart
        domain/
          entities/user_profile.dart
          repositories/profile_repository.dart
        presentation/
          controllers/profile_controller.dart
          pages/
            change_password_page.dart
            edit_profile_page.dart
            profile_page.dart
      receipts/
        data/
          datasources/receipt_remote_datasource.dart
          models/receipt_model.dart
          repositories/receipt_repository_impl.dart
          services/receipt_pdf_service.dart
        domain/
          entities/receipt.dart
          repositories/receipt_repository.dart
        presentation/
          controllers/receipt_controller.dart
          pages/receipt_page.dart
          widgets/receipt_action_buttons.dart
    firebase_options_dev.dart         Firebase options for dev
    firebase_options_staging.dart     Firebase options for staging
    firebase_options_production.dart  Firebase options for prod
  assets/
    icons/
    templates/receipt.html            Receipt PDF template
  test/
    currency_formatter_test.dart
    features/payments/payment_qr_test.dart
    features/receipts/receipt_model_test.dart
  android/
  ios/
  web/
  windows/
  linux/
  macos/
```

Most feature folders use these layers:

| Layer | Responsibility |
|---|---|
| `presentation/pages/` | Flutter screens and user interactions |
| `presentation/controllers/` | Screen state, validation, loading, and actions |
| `presentation/widgets/` | Feature-specific UI components |
| `domain/entities/` | App-facing data types without HTTP/UI responsibilities |
| `domain/repositories/` | Abstract data operations used by controllers |
| `data/models/` | JSON parsing and serialization |
| `data/datasources/` | Calls to the Laravel API or local storage |
| `data/repositories/` | Implements domain repository contracts using data sources |

This is the dominant pattern, not a strict rule in every feature. For example, the admin controller calls the shared Dio client directly, and the cart is local-only.

## 3. App startup and dependency setup

Each runnable flavor entry point follows the same sequence:

1. Call `WidgetsFlutterBinding.ensureInitialized()`.
2. Set `F.appFlavor` to `dev`, `staging`, or `prod`.
3. Initialize Firebase using that flavor's generated Firebase options.
4. Initialize `PrefsStorage` and register it in GetX.
5. Run `MainApp`.
6. `MainApp` builds a `GetMaterialApp` with the app theme, route list, initial dependency binding, and home route.
7. `InitialBinding` registers long-lived storage, the Dio client, authentication, and feature repositories/controllers.

Repositories and most feature controllers are lazy registrations (`Get.lazyPut`). They are created when first requested and can be recreated as needed. Shared storage, Dio, auth, and cart objects are registered as permanent dependencies.

GetX is used for named navigation, dependency injection, and reactive screen state. Controllers expose observable values (such as `RxBool`, `RxList`, and `Rxn`) and screens use `Obx` to rebuild when those values change.

## 4. Architecture and data flow

The usual server-backed feature flow is:

```text
Page -> GetX controller -> domain repository -> repository implementation
     -> remote data source -> DioClient -> Laravel API
     -> JSON model -> domain entity -> controller state -> Page
```

For example, the catalog page observes `CatalogController`. The controller asks `CatalogRepository` for products and categories. The repository uses a remote data source that requests `/products` and `/categories`, parses Laravel's JSON resource response into models, and maps those to app entities.

For mutations, the flow runs in reverse. A page collects input, the controller validates the interaction and calls a repository method, the data source sends JSON or multipart data, and the controller updates observable state or exposes an error.

`lib/core/network/dio_client.dart` owns the shared Dio configuration. It sets the flavor-specific base URL, JSON content type, request timeouts, and interceptors. The auth interceptor adds the stored bearer token when present, always requests JSON, and removes an invalid token after an HTTP 401 response.

## 5. Feature guide

### `features/home`

The home binding wires catalog data into the home feature. The home controller/repository provide the storefront content; widgets such as the banner carousel, category chips, and new-arrivals section make up the home screen.

### `features/catalog`

Fetches and parses active products and categories from the API. `CatalogController` holds the lists and applies search, category, price-range, and sorting filters to the loaded product list. `CatalogBinding` registers its remote data source, repository, and controller.

### `features/product_details`

Loads a selected product and manages size/color variant selection, quantity, and stock-aware validation. Once a valid option is selected, the screen can add that product/variant to the cart.

### `features/cart`

The cart is a local feature. `CartController` manages items and quantities and limits quantities to the variant stock snapshot it has. `CartLocalDataSource` serializes items to JSON in `SharedPreferences`, so a cart can survive app restarts. The backend still rechecks availability and prices at checkout; local cart values are not authoritative.

### `features/auth`

Registration and login send credentials to the API. The remote data source stores the returned Sanctum token in secure storage and parses the user. On startup, `AuthController` checks for a token and calls the profile endpoint to restore the session. Login routes admins to the admin dashboard and customers to the storefront. Logout attempts to unregister notifications, calls the API, clears local authentication state, and returns to home.

### `features/profile`

Loads and updates the signed-in user's profile, password, and avatar through the API. Avatar selection uses the image picker. Profile data is separate from authentication token storage.

### `features/addresses`

Provides address listing, create/edit, default-address selection, and deletion. The map picker combines device location (`geolocator`), Google Maps, and geocoding to help choose/resolve an address. Address records are saved on the API and used during checkout.

### `features/checkout`

Loads saved addresses, selects a default/first address where possible, and requests a server-side checkout preview. It submits variant IDs, quantities, address, selected payment method, and an idempotency key. For COD, the UI collects customer contact and delivery details, a home photo, and terms acceptance; the photo is uploaded as multipart form data.

### `features/payments`

Initiates payment with the API, displays provider QR content or a hosted checkout page, can open supported bank-app links, and polls payment status. The controller checks again when the app returns to the foreground. A successful screen is shown only when the API reports paid or partially paid; a redirect or QR display alone is not considered confirmation.

### `features/orders`

Loads the customer's orders and order details. The detail flow supports refresh, cancellation requests, COD correction resubmission, and switching eligible rejected COD orders to ABA Pay. The server remains the authority for whether each action is allowed.

### `features/receipts`

Fetches a receipt from the API and can generate a PDF on the device. `ReceiptPdfService` fills `assets/templates/receipt.html`, writes the PDF in the app documents directory, and the receipt UI provides available share/print actions.

### `features/notifications`

Uses local notifications and Firebase Cloud Messaging on supported mobile platforms. After authentication, the push service requests permission, registers the FCM token with the API, listens for token refresh and foreground messages, and unregisters on logout. Notifications are optional and should not block login or a confirmed payment.

### `features/admin`

The admin dashboard controller loads summary metrics, orders, payments, categories, and products from `/admin/...` endpoints. Admin screens provide dashboard, order/payment review, and catalog management. A client-side GetX middleware checks that a current user has the admin role before opening the admin route; the Laravel API independently enforces admin authorization.

### `core` and `app`

- `core/constants/` centralizes API endpoint fragments and local-storage keys.
- `core/network/` configures HTTP and auth behavior.
- `core/storage/` separates non-sensitive preferences from secure credentials.
- `core/errors/` maps common Dio failures to user-facing failures/messages.
- `core/utils/` handles currency formatting and image/asset resolution.
- `core/widgets/` contains reusable buttons, fields, product cards, and loading/error/empty states.
- `app/theme/` contains shared design tokens and theme setup.
- `app/routes/` maps route names to pages and bindings.

## 6. Customer workflows

### Browse and choose a product

1. The app opens the home page.
2. Home/catalog controllers request product and category data from the API.
3. The customer searches, filters, sorts, and opens a product.
4. Product details load the product/variants and check that a size/color combination exists and has stock.
5. Adding the selection updates the local cart and persists it in preferences.

### Sign in or create an account

1. The customer submits the login or registration form.
2. The auth data source posts to `/auth/login` or `/auth/register`.
3. The response token is saved in secure storage; the user response becomes the current app user.
4. The app starts push-notification setup and loads addresses when applicable.
5. Admin users land on the admin dashboard; customers land on home.

Guest users can browse the storefront, but server-owned customer operations (such as saved addresses, order creation, and order history) require authentication.

### Checkout and order placement

1. Open the cart and continue to checkout.
2. The checkout controller loads addresses. Select one or add a new saved address.
3. The app sends address ID and each selected product variant ID/quantity to `/checkout/preview`.
4. The API calculates prices and returns the authoritative subtotal/total. The client formats and displays those values.
5. Choose ABA Pay QR, the hosted ABA Pay checkout, or cash on delivery.
6. For a non-COD order, the app sends JSON. For COD, it validates the required form, photo, and terms and submits multipart form data.
7. The controller creates and reuses an idempotency key for retries of the same cart/address combination, and submits it in the request body and header. The Laravel request currently validates that key; clients should not assume the API deduplicates orders by key unless server-side idempotency handling is added.
8. On success, the local cart is cleared and the app opens order confirmation.

### Payment and payment status

1. For a normal payment, the order confirmation screen offers “Continue to payment”. For COD, it instead explains the review/deposit steps and offers order status.
2. The payment screen calls `/payments/{paymentId}/initiate`.
3. For a QR response, the app displays the QR and any available banking-app links. For hosted checkout, it opens the provider URL in the checkout WebView.
4. The payment controller polls `/orders/{orderId}/payment-status` every three seconds, up to three minutes, while the payment remains pending/processing.
5. If the app resumes from the background, it checks status again.
6. Only a paid/partially-paid status returned by the API opens the payment-success screen. The API verifies provider status and creates the receipt; the client does not mark a payment paid itself.

### Cash on delivery

1. The customer chooses cash on delivery and provides the required verification/contact details, home photo, and consent.
2. The API creates an order pending admin document verification. No payment is taken at this stage.
3. If approved, the customer can pay the required 50% deposit via ABA Pay. The remainder is due in cash at delivery.
4. If the admin requests corrections, the customer can resubmit details. If rejected, the app can offer an eligible order switch to ABA Pay.
5. The customer can request cancellation; an administrator reviews it. The API controls allowed state transitions and any inventory/document cleanup.

### Order history and receipts

1. The orders screen requests the signed-in user's orders from the API.
2. Opening an order loads its current status and details.
3. When available, the customer opens the receipt screen. The app fetches receipt data and can create a locally stored PDF for printing or sharing.

## 7. Storage, networking, and errors

| Data | Storage/owner |
|---|---|
| Sanctum authentication token | `flutter_secure_storage` through `SecureStorage` |
| Cart JSON and non-sensitive preferences | `shared_preferences` through `PrefsStorage` |
| Products, addresses, orders, payments, receipts | Laravel API/database; loaded by repositories |
| Payment provider credentials/signatures | Laravel server only; never the Flutter app |
| Generated receipt PDFs | App documents directory |

The cart's serialized product/variant snapshots are for displaying a local cart. The API recalculates the total and checks inventory when an order is submitted, so stale cart data should be surfaced as an API error and corrected by refreshing the catalog/cart.

The Dio client uses 15-second connect and receive timeouts. Its debug log interceptor does not log request/response bodies or headers. `ErrorMapper` translates common network, authorization, and server failures; feature controllers provide context-specific messages for their screens.

The app's authentication token is not stored in `SharedPreferences`. Do not add payment signing secrets, provider profile keys, or Firebase service-account private keys to Flutter assets or source code.

## 8. Flavors and environment configuration

The flavor is assigned before Firebase setup and app startup. It determines the app title, Firebase options, API base URL, and application identifier.

| Flavor | Entry point | App title | Android ID / iOS bundle ID | API URL |
|---|---|---|---|---|
| `dev` | `lib/main_dev.dart` | Clothing Dev | `com.clothingapp.dev` | `http://10.0.2.2:8000/api/v1` |
| `staging` | `lib/main_staging.dart` | Clothing Staging | `com.clothingapp.staging` | `https://staging-api.clothingapp.com/api/v1` |
| `prod` | `lib/main_prod.dart` | Clothing | `com.clothingapp` | `https://api.clothingapp.com/api/v1` |

Run a flavor with its matching target:

```powershell
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor prod -t lib/main_prod.dart
```

Before using staging or production, confirm the URLs in `lib/core/config/env.dart`, the Firebase options, and the platform identifiers match the environments you operate. Payment methods exposed by the app must also be enabled and configured by the backend; the Laravel server is authoritative for payment initiation and confirmation.

## 9. Maps, Firebase, and notifications

### Google Maps

Android reads `GOOGLE_MAPS_API_KEY` from the Gradle project property `googleMapsApiKey`, the environment, or the local `.env` file (in that precedence order). Create a local file from `.env.example` and set your key there. Local `.env` files are ignored by Git.

For iOS, copy `ios/Flutter/MapsConfig.xcconfig.example` to `ios/Flutter/MapsConfig.xcconfig` and set `GOOGLE_MAPS_API_KEY`. This local config file is ignored by Git.

In Google Cloud Console, enable **Maps SDK for Android** and **Maps SDK for iOS**. Restrict Android keys to the app package name and signing certificate SHA-1, and iOS keys to the bundle ID. The Maps JavaScript API does not enable the native Flutter maps.

Run dev on Android:

```powershell
flutter run --flavor dev -t lib/main_dev.dart
```

Or build the dev APK with an explicit Gradle property:

```powershell
cd android
.\gradlew.bat :app:assembleDevDebug -PgoogleMapsApiKey=YOUR_GOOGLE_MAPS_API_KEY
```

Map builds fail with a configuration message if the key is missing. The unflavored Gradle application ID is `com.example.clothing_app`, but the unflavored `lib/main.dart` is disabled. Configure Maps restrictions for the flavor application ID and signing certificate you install.

### Firebase and push

`lib/firebase.dart` selects generated options from `firebase_options_dev.dart`, `firebase_options_staging.dart`, or `firebase_options_production.dart`, based on `F.appFlavor`. Keep each environment pointed at the intended Firebase project and register the appropriate Android/iOS app configuration. Firebase initializes during app startup; after authentication, the push service requests permission, registers the device token with the API, and listens for messages. Push token registration is optional at runtime.

## 10. Tests and quality checks

Run all Flutter tests and static analysis from this directory:

```powershell
flutter test
flutter analyze
```

The current tests cover currency formatting, receipt model parsing, and QR display/payment-response parsing. Add feature tests alongside the feature being changed, especially for checkout validation, payment status transitions, and API response parsing.

For a release build, use the correct flavor and configure production signing credentials in the platform build configuration. The Android Gradle release build currently uses the debug signing config as a development convenience; replace it before publishing.
