#!/usr/bin/env bash

EDX_PLATFORM=/home/kyle/openedx/edx-platform
TUTOR_ENV=/home/kyle/tutor-root/env

SED_RM_WILD_IMPORTS='/^from .* import \*$/d' 
SED_RM_YAML_LOAD='/^CONFIG_FILE =/,/vars\(\)\..*$/d'

set -euo pipefail

(
	echo '# @@@@@@@@@ lms/envs/common.py' &&
	(cat "$EDX_PLATFORM/lms/envs/common.py") &&
	echo '# @@@@@@@@@ LMS_CFG yaml' &&
	(cat "$TUTOR_ENV/apps/openedx/config/lms.env.yml" | yaml_to_django_settings.py) &&
	echo '# @@@@@@@@@ lms/envs/production.py' &&
	(cat "$EDX_PLATFORM/lms/envs/production.py" | sed -E "$SED_RM_YAML_LOAD") &&
	echo '# @@@@@@@@@ tutor production.py' &&
	(cat "$TUTOR_ENV/apps/openedx/settings/lms/production.py")
) | sed -E "$SED_RM_WILD_IMPORTS" > "$EDX_PLATFORM/lms/settings.py"
