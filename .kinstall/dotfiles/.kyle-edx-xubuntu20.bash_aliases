#!/usr/bin/env bash
alias platform-dirs="echo -n '~/edx-platform/common,~/edx-platform/openedx/,~/edx-platform/lms/,~/edx-platform/cms,~/edx-platform/themes' | xcopy && echo 'Copied to clipboard.'"
alias vertica-driver="echo -n '(cd /edx/app/hadoop/sqoop/lib && curl https://vertica.com/client_drivers/9.1.x/9.1.1-0/vertica-jdbc-9.1.1-0.jar -O)' | xcopy"
alias rr="ssh kdmccormick@tools-edx-gp.edx.org"
alias rr-tee="ssh kdmccormick@tools-edx-gp.edx.org | tee"
alias mockprock="cd ~/src/mockprock && source venv/bin/activate && python -m mockprock.server mockprock-client-id mockprock-client-secret"
alias platform-static="echo 'NODE_ENV=development STATIC_ROOT_LMS=/edx/var/edxapp/staticfiles STATIC_ROOT_CMS=/edx/var/edxapp/staticfiles/studio LMS_ROOT_URL=http://localhost:18000 JWT_AUTH_COOKIE_HEADER_PAYLOAD=edx-jwt-cookie-header-payload EDXMKTG_USER_INFO_COOKIE_NAME=edx-user-info \$(npm bin)/webpack --config=webpack.dev.config.js' | xcopy && echo Copied to clipboard"
