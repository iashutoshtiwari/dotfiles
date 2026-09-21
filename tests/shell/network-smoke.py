#!/usr/bin/env python3
"""Exercise the real QML service with fake nmcli; requires a connected desktop session.

No network settings are changed. The copied shell has no windows or autostart.
"""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time

REPO = Path(__file__).resolve().parents[2]
FIXTURE = '''import Quickshell
import Quickshell.Io
import qs.services
ShellRoot {
    IpcHandler {
        target: "audit"
        function dns(mode: string, value: string): void { NetworkService.applyDns(mode, value); }
        function status(): string {
            return JSON.stringify({connected: NetworkService.connected,
                ready: NetworkService.activeUuid.length > 0,
                busy: NetworkService.dnsBusy, status: NetworkService.dnsStatus});
        }
    }
}
'''
MOCK = '''#!/usr/bin/env python3
import sys, json, time
from pathlib import Path
root = Path(__file__).resolve().parent.parent
args = sys.argv[1:]
with (root / 'calls.jsonl').open('a') as f:
    f.write(json.dumps(args) + '\\n')
if '--fields' in args:
    print('GENERAL.CON-UUID:audit-original\\nIP4.ADDRESS[1]:192.0.2.2/24\\nIP4.GATEWAY:192.0.2.1\\nIP4.DNS[1]:192.0.2.53')
elif 'modify' in args:
    time.sleep(.3)
    if (root / 'fail-modify').exists():
        print('Simulated modification failure', file=sys.stderr)
        sys.exit(1)
elif '-g' in args:
    print('audit-other' if (root / 'changed-connection').exists() else 'audit-original')
elif 'reapply' not in args:
    sys.exit(1)
'''


def run(root):
    candidate = root / 'shell'
    shutil.copytree(REPO / 'home/.config/quickshell/predator-shell', candidate,
                    ignore=shutil.ignore_patterns('.qmlls.ini'))
    (candidate / 'shell.qml').write_text(FIXTURE)
    mock = root / 'bin'
    mock.mkdir()
    (mock / 'nmcli').write_text(MOCK)
    (mock / 'nmcli').chmod(0o755)
    base = ['qs', 'ipc', '-p', str(candidate), 'call', 'audit']

    def call(*args):
        return subprocess.run([*base, *args], capture_output=True, text=True,
                              check=True, timeout=5).stdout.strip()

    def status():
        return json.loads(call('status'))

    def wait_done():
        for _ in range(60):
            result = status()
            if not result['busy']:
                return result
            time.sleep(.05)
        raise AssertionError('DNS operation did not finish')

    calls = root / 'calls.jsonl'

    def commands():
        return [json.loads(line) for line in calls.read_text().splitlines()]

    with (root / 'shell.log').open('w+') as log:
        process = subprocess.Popen(['qs', '-p', str(candidate), '--no-color'],
                                   stdout=log, stderr=log,
                                   env=dict(os.environ, PATH=str(mock) + ':' + os.environ['PATH']))
        try:
            for _ in range(50):
                try:
                    if status()['ready']:
                        break
                except (subprocess.CalledProcessError, json.JSONDecodeError):
                    pass
                if process.poll() is not None:
                    raise AssertionError('Fixture exited before loading')
                time.sleep(.1)
            else:
                raise AssertionError('Fixture needs a running connected desktop session')
            calls.write_text('')
            call('dns', 'cloudflare', '')
            call('dns', 'google', '')
            assert wait_done()['status'] == 'DNS applied'
            assert sum('modify' in args for args in commands()) == 1
            assert sum('reapply' in args for args in commands()) == 1
            print('PASS: overlapping requests are serialized')

            (root / 'changed-connection').touch()
            calls.write_text('')
            call('dns', 'automatic', '')
            assert 'connection changed' in wait_done()['status']
            assert not any('reapply' in args for args in commands())
            print('PASS: a changed connection is not reapplied')

            (root / 'fail-modify').touch()
            calls.write_text('')
            call('dns', 'custom', 'not-an-ip')
            assert wait_done()['status'] == 'Simulated modification failure'
            assert not any('reapply' in args for args in commands())
            print('PASS: modification failures are visible and stop the operation')
        except Exception:
            log.flush()
            log.seek(0)
            print(log.read())
            raise
        finally:
            process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()


if __name__ == '__main__':
    with tempfile.TemporaryDirectory(prefix='predator-network-test-') as directory:
        run(Path(directory))
