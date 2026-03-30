#!/bin/bash
cd /home/kavia/workspace/code-generation/secure-session-app-with-biometric-and-calculator-2525-2540/ios_frontend
./gradlew lint
LINT_EXIT_CODE=$?
if [ $LINT_EXIT_CODE -ne 0 ]; then
   exit 1
fi

