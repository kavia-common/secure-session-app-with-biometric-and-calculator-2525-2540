@echo off
REM Swift/iOS-only workspace.
REM Some automated checks still invoke `gradlew` from within `ios_frontend/`.
echo gradlew shim (ios_frontend): Kotlin/Gradle project removed; Swift iOS app is under ios_app/.
exit /b 0
