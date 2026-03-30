@echo off
REM Swift/iOS-only workspace.
REM Some automated checks invoke `gradlew.bat` from within `ios_frontend/ios_app/`.
echo gradlew shim (ios_frontend/ios_app): Kotlin/Gradle project removed; Swift iOS app is under SecureSessionApp/.
exit /b 0
