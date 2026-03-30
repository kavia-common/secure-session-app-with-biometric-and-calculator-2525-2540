@echo off
REM Swift/iOS-only workspace.
REM Some automated checks invoke `gradlew.bat` from within the workspace folder.
echo gradlew shim (workspace root): Kotlin/Gradle project removed; Swift iOS app is under ios_frontend/ios_app/.
exit /b 0
