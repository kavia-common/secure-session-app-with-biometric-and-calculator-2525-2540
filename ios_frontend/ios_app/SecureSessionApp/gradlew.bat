@echo off
REM Swift/iOS-only workspace.
REM Some automated checks may run from within `ios_frontend/ios_app/SecureSessionApp/`.
echo gradlew shim (ios_frontend/ios_app/SecureSessionApp): Kotlin/Gradle project removed; Swift iOS app sources are under SecureSessionApp/.
exit /b 0
