#!/usr/bin/env python3
"""Read-only submodule drift detector for a local Workflow-Agentic-Sulas checkout.

Uses GitHub CLI authentication. Emits deterministic JSON; never turns an API error
into an empty (healthy) result. With --all, includes unchanged repositories too.
"""

import argparse
import configparser
import json
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlparse


def run(*args, cwd=None):
    result = subprocess.run(args, cwd=cwd, capture_output=True, text=True, check=True)
    return result.stdout.strip()


def parse_modules(text):
    parser = configparser.ConfigParser(interpolation=None)
    parser.read_string(text)
    modules = []
    for section in parser.sections():
        if section.startswith('submodule '):
            modules.append((parser.get(section, 'path'), parser.get(section, 'url')))
    if not modules:
        raise ValueError('No submodules in .gitmodules')
    return modules


def github_repo(url):
    parsed = urlparse(url)
    if parsed.scheme != 'https' or parsed.hostname != 'github.com':
        raise ValueError(f'Unsupported submodule URL: {url}')
    parts = parsed.path.strip('/').removesuffix('.git').split('/')
    if len(parts) != 2 or not all(parts):
        raise ValueError(f'Invalid GitHub repo URL: {url}')
    return '/'.join(parts)


def detect(root):
    # Fetch the parent only; never check out or mutate any submodule checkout.
    run('git', 'fetch', '-q', 'origin', 'main', cwd=root)
    base = run('git', 'rev-parse', 'origin/main', cwd=root)
    modules = parse_modules(run('git', 'show', f'{base}:.gitmodules', cwd=root))
    found = []
    errors = []
    for path, url in modules:
        try:
            repo = github_repo(url)
            old = run('git', 'rev-parse', f'{base}:{path}', cwd=root)
            meta = json.loads(run('gh', 'api', f'repos/{repo}', cwd=root))
            branch = meta['default_branch']
            new = json.loads(run('gh', 'api', f'repos/{repo}/commits/{branch}', cwd=root))['sha']
            found.append({'repo': repo, 'path': path, 'branch': branch,
                          'pinned': old, 'latest': new, 'changed': old != new})
        except (subprocess.CalledProcessError, KeyError, ValueError, json.JSONDecodeError) as exc:
            errors.append(f'{path}: {exc}')
    if errors:
        raise RuntimeError('Unable to inspect every submodule: ' + '; '.join(errors))
    return sorted(found, key=lambda item: item['path'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--all', action='store_true', help='Include up-to-date repos')
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    try:
        found = detect(root)
        print(json.dumps(found if args.all else [r for r in found if r['changed']],
                         sort_keys=True, separators=(',', ':')))
    except (RuntimeError, ValueError, subprocess.CalledProcessError) as exc:
        print(f'monitor_submodules: {exc}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
