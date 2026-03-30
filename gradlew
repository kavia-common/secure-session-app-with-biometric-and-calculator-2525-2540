#!/bin/sh
# Swift/iOS-only workspace.
# Some automated checks invoke `./gradlew` from within the workspace folder.
echo "gradlew shim (workspace root): Kotlin/Gradle project removed; Swift iOS app is under ios_frontend/ios_app/."
exit 0
