#!/bin/bash
# Script to generate Firebase configuration files for different environments/flavors
# Feel free to reuse and adapt this script for your own projects

if [[ $# -eq 0 ]]; then
  echo "Error: No environment specified. Use 'dev', 'stg', or 'prod'."
  exit 1
fi

case $1 in
  dev)
    flutterfire.bat config \
      --project=clothing-dev-b9e68 \
      --out=lib/firebase_options_dev.dart \
      --ios-bundle-id=com.clothing_app.dev \
      --ios-out=ios/flavors/dev/GoogleService-Info.plist \
      --android-package-name=com.clothing_app.dev \
      --android-out=android/app/src/dev/google-services.json
    ;;
  staging)
    flutterfire.bat config \
      --project=clothing-staging \
      --out=lib/firebase_options_stg.dart \
      --ios-bundle-id=com.clothing_app.staging \
      --ios-out=ios/flavors/stg/GoogleService-Info.plist \
      --android-package-name=com.clothing_app.staging \
      --android-out=android/app/src/stg/google-services.json
    ;;
  prod)
    flutterfire.bat config \
      --project=clothing-prod-220f3 \
      --out=lib/firebase_options_prod.dart \
      --ios-bundle-id=com.clothing_app \
      --ios-out=ios/flavors/prod/GoogleService-Info.plist \
      --android-package-name=com.clothing_app \
      --android-out=android/app/src/prod/google-services.json
    ;;
  *)
    echo "Error: Invalid environment specified. Use 'dev', 'stg', or 'prod'."
    exit 1
    ;;
esac


