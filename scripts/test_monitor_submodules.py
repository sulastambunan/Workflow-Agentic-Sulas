#!/usr/bin/env python3
"""Run with: python3 -m unittest discover -s scripts -p 'test_monitor_submodules.py'"""
import unittest
from unittest.mock import patch

import monitor_submodules as monitor


class MonitorTests(unittest.TestCase):
    def test_parse_modules(self):
        text = '[submodule "example"]\n path = repos/example\n url = https://github.com/acme/example.git\n'
        self.assertEqual(monitor.parse_modules(text),
                         [('repos/example', 'https://github.com/acme/example.git')])

    def test_reject_non_github(self):
        with self.assertRaises(ValueError):
            monitor.github_repo('https://attacker.invalid/acme/example.git')

    def test_detect_changed_and_unchanged(self):
        outputs = iter([
            '',  # git fetch
            'f' * 40,  # origin/main
            '[submodule "example"]\n path = repos/example\n url = https://github.com/acme/example.git',
            'a' * 40,  # pinned SHA
            '{"default_branch":"develop"}',
            '{"sha":"b' + 'b' * 39 + '"}',
        ])
        with patch.object(monitor, 'run', side_effect=lambda *args, **kw: next(outputs)) as cmd:
            records = monitor.detect('/scratch')
        self.assertEqual(len(records), 1)
        self.assertTrue(records[0]['changed'])
        self.assertEqual(records[0]['branch'], 'develop')
        self.assertEqual(records[0]['latest'], 'b' * 40)
        self.assertEqual(cmd.call_args_list[0].args[:4], ('git', 'fetch', '-q', 'origin'))

    def test_failed_lookup_is_error_not_empty(self):
        outputs = iter([
            '',  # git fetch
            'f' * 40,
            '[submodule "example"]\n path = repos/example\n url = https://github.com/acme/example.git',
            'a' * 40,
            '{}',
        ])
        with patch.object(monitor, 'run', side_effect=lambda *args, **kw: next(outputs)):
            with self.assertRaisesRegex(RuntimeError, 'Unable to inspect every submodule'):
                monitor.detect('/scratch')


if __name__ == '__main__':
    unittest.main()
