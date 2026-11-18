"""Ask OpenSSH what each configuration means, before and after each edit.

Uses `sshd -G`, which parses a configuration file, prints the effective settings and
exits. It starts no server and reads no live configuration.
"""

import pathlib
import shutil
import subprocess
import sys
import tempfile

sys.path.insert(0, str(pathlib.Path(__file__).parent))
from case import FILE_BEFORE, WINDOWS, apply, edit

SSHD = shutil.which("sshd") or "/usr/sbin/sshd"


def password_authentication(config_text: str) -> str:
    with tempfile.NamedTemporaryFile("w", suffix=".conf", delete=False) as f:
        f.write(config_text)
    try:
        done = subprocess.run([SSHD, "-G", "-f", f.name], capture_output=True, text=True, check=True)
    finally:
        pathlib.Path(f.name).unlink()
    for line in done.stdout.splitlines():
        if line.startswith("passwordauthentication "):
            return line.split()[1]
    raise ValueError("sshd -G printed no passwordauthentication line")


def table() -> list[tuple[str, str, str]]:
    rows = []
    for which in ("comment", "setting"):
        before = FILE_BEFORE[which]
        after = {apply(before, edit(which, w)) for w in WINDOWS}
        assert len(after) == 1, "every window must make the same change"
        rows.append((which, password_authentication(before), password_authentication(after.pop())))
    return rows


if __name__ == "__main__":
    print(f"{'line removed':13s} {'before':7s} after   (effective passwordauthentication)")
    for which, before, after in table():
        print(f"{which:13s} {before:7s} {after}")
