#!/usr/bin/env python3

import json
import requests
import sys

org = sys.argv[1]

repos = [
    repo
    for page in [
        requests.get(f'https://api.github.com/orgs/{org}/repos?per_page=100&page={n}').json()
        for n in {1,2}
    ]
    for repo in page
]
repo_names_with_pages = [r['name'] for r in repos if r['has_pages']]
print(*sorted(repo_names_with_pages), sep='\n')

