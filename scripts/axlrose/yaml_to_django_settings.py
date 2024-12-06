#!/usr/bin/env python3
import json, sys, yaml
cfg = yaml.safe_load(sys.stdin)
for name, value in cfg.items():
    print(f"{name} = {json.dumps(value, indent=4)}")
