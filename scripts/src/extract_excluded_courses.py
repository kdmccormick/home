#!/usr/bin/env python3
# First, query https://courses.edx.org/api/toggles/v0/state/.
# Then pipe the result to this script,
# passing in the base experiment flag name as the only argument.
# Results will print as JSON to stdout.
import json
import sys

assert (
    2 <= len(sys.argv) <= 3
), "usage: extract_excluded_courses.py BASE_FLAG_NAME [json|simple]"
exp_flag_name = sys.argv[1]
output_fmt = sys.argv[2] if len(sys.argv) >= 3 else "json"
assert output_fmt in ["json", "simple"]
zero_flag_name = exp_flag_name + ".0"

all_flags = json.load(sys.stdin)["waffle_flags"]
try:
    exp_flag_overrides = next(
        flag for flag in all_flags if flag["name"] == exp_flag_name
    ).get("course_overrides", [])
except StopIteration:
    exp_flag_overrides = []
try:
    zero_flag_overrides = next(
        flag for flag in all_flags if flag["name"] == zero_flag_name
    ).get("course_overrides", [])
except StopIteration:
    zero_flag_overrides = []
mfe_disabled = {}
mfe_disabled["via_experiment_flag"] = sorted(
    ovr["course_id"] for ovr in exp_flag_overrides if ovr["force"] == "off"
)
mfe_disabled["via_zero_flag"] = sorted(
    ovr["course_id"] for ovr in zero_flag_overrides if ovr["force"] == "on"
)
mfe_disabled["via_either_flag"] = sorted(
    list(set(mfe_disabled["via_experiment_flag"] + mfe_disabled["via_zero_flag"]))
)
if output_fmt == "json":
    print(json.dumps({"flag_is_disabled": mfe_disabled}, indent=4))
elif output_fmt == "simple":
    print("\n".join(mfe_disabled["via_either_flag"]))
