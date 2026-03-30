#!/bin/sh
# This repository is Swift/iOS-only. The original Kotlin/Gradle project was removed.
# Some CI/lint scripts still call `./gradlew`; keep this shim so validation does not fail.
echo "gradlew shim: Kotlin/Gradle project removed; Swift iOS app is under ios_frontend/ios_app."
exit 0
