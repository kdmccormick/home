#!/usr/bin/env bash
alias platform-dirs="echo -n '~/src/edx-platform/common,~/src/edx-platform/openedx/,~/src/edx-platform/lms/,~/src//edx-platform/cms,~/src//edx-platform/themes' | xcopy && echo 'Copied to clipboard.'"
alias mockprock="cd ~/src/mockprock && source venv/bin/activate && python -m mockprock.server mockprock-client-id mockprock-client-secret"
alias platform-static="echo 'NODE_ENV=development STATIC_ROOT_LMS=/edx/var/edxapp/staticfiles STATIC_ROOT_CMS=/edx/var/edxapp/staticfiles/studio LMS_ROOT_URL=http://localhost:18000 JWT_AUTH_COOKIE_HEADER_PAYLOAD=edx-jwt-cookie-header-payload EDXMKTG_USER_INFO_COOKIE_NAME=edx-user-info \$(npm bin)/webpack --config=webpack.dev.config.js' | xcopy && echo Copied to clipboard"
