#!/usr/bin/env python3
"""
METIME Auto-Commit Watcher
Monitora i file Swift, yml, md e xcprivacy del progetto e fa
automaticamente git add + commit + push ogni volta che rileva
una modifica. Il commit viene raggruppato con un debounce di 5 secondi
per evitare commit multipli su salvataggi ravvicinati.
"""

import subprocess
import threading
import logging
import sys
import os
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# ── Config ────────────────────────────────────────────────────────────────────
REPO_DIR    = Path("/home/ubuntu/METIME")
WATCH_EXTS  = {".swift", ".yml", ".md", ".xcprivacy", ".entitlements", ".plist"}
DEBOUNCE_S  = 5          # secondi di attesa prima del commit
LOG_FILE    = REPO_DIR / "scripts" / "auto_commit.log"

# ── Logging ───────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler(sys.stdout),
    ],
)
log = logging.getLogger("metime-watcher")

# ── Git helpers ───────────────────────────────────────────────────────────────

def git(*args: str) -> tuple[int, str, str]:
    """Esegue un comando git nella REPO_DIR e restituisce (returncode, stdout, stderr)."""
    result = subprocess.run(
        ["git", *args],
        cwd=REPO_DIR,
        capture_output=True,
        text=True,
    )
    return result.returncode, result.stdout.strip(), result.stderr.strip()


def has_changes() -> bool:
    """True se ci sono file modificati/aggiunti non ancora committati."""
    rc, out, _ = git("status", "--porcelain")
    return rc == 0 and bool(out)


def changed_files() -> list[str]:
    """Restituisce la lista dei file modificati."""
    _, out, _ = git("status", "--porcelain")
    return [line[3:].strip() for line in out.splitlines() if line.strip()]


def commit_and_push(changed: list[str]) -> None:
    """Esegue add, commit e push."""
    # Determina un messaggio di commit descrittivo
    if len(changed) == 1:
        fname = Path(changed[0]).name
        msg = f"auto: update {fname}"
    elif len(changed) <= 4:
        names = ", ".join(Path(f).name for f in changed[:4])
        msg = f"auto: update {names}"
    else:
        msg = f"auto: update {len(changed)} files"

    rc_add, _, err_add = git("add", "-A")
    if rc_add != 0:
        log.error(f"git add failed: {err_add}")
        return

    rc_commit, out_commit, err_commit = git("commit", "-m", msg)
    if rc_commit != 0:
        if "nothing to commit" in err_commit or "nothing to commit" in out_commit:
            log.info("Nessuna modifica da committare.")
        else:
            log.error(f"git commit failed: {err_commit}")
        return

    log.info(f"Commit: {msg}")

    rc_push, _, err_push = git("push", "origin", "main")
    if rc_push != 0:
        log.error(f"git push failed: {err_push}")
    else:
        log.info(f"Push completato → origin/main  [{', '.join(changed)}]")


# ── Watcher ───────────────────────────────────────────────────────────────────

class SwiftChangeHandler(FileSystemEventHandler):
    def __init__(self) -> None:
        super().__init__()
        self._timer: threading.Timer | None = None
        self._lock = threading.Lock()

    def _is_relevant(self, path: str) -> bool:
        p = Path(path)
        # Ignora directory nascoste, .git, build, DerivedData e script stessi
        parts = p.parts
        ignored_dirs = {".git", "build", "DerivedData", "scripts", ".build", "__pycache__"}
        if any(part in ignored_dirs for part in parts):
            return False
        return p.suffix in WATCH_EXTS

    def on_any_event(self, event):
        if event.is_directory:
            return
        src = getattr(event, "src_path", "")
        dest = getattr(event, "dest_path", src)
        path = dest if dest else src
        if not self._is_relevant(path):
            return

        rel = Path(path).relative_to(REPO_DIR)
        log.info(f"Modifica rilevata: {rel}  [{event.event_type}]")
        self._schedule_commit()

    def _schedule_commit(self) -> None:
        with self._lock:
            if self._timer is not None:
                self._timer.cancel()
            self._timer = threading.Timer(DEBOUNCE_S, self._do_commit)
            self._timer.daemon = True
            self._timer.start()

    def _do_commit(self) -> None:
        with self._lock:
            self._timer = None
        if not has_changes():
            log.info("Nessuna modifica pendente.")
            return
        changed = changed_files()
        commit_and_push(changed)


# ── Main ──────────────────────────────────────────────────────────────────────

def main() -> None:
    log.info(f"METIME Auto-Commit Watcher avviato — monitorando {REPO_DIR}")
    log.info(f"Estensioni monitorate: {', '.join(sorted(WATCH_EXTS))}")
    log.info(f"Debounce: {DEBOUNCE_S}s  |  Log: {LOG_FILE}")

    handler  = SwiftChangeHandler()
    observer = Observer()
    observer.schedule(handler, str(REPO_DIR), recursive=True)
    observer.start()

    try:
        observer.join()
    except KeyboardInterrupt:
        log.info("Interruzione ricevuta — arresto watcher.")
        observer.stop()
        observer.join()


if __name__ == "__main__":
    main()
