#!/usr/bin/env bash
# eqviz — menú admin. App = Swift/SwiftUI. Este script automatiza tooling + xcodebuild. No mata procesos sin confirmación.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

STATUS_FILE="$ROOT/roadmap/STATUS.md"
PROJECT_YML="$ROOT/macos/project.yml"
XCODEPROJ="$ROOT/macos/eqviz.xcodeproj"
DERIVED="$ROOT/macos/build"
SCHEME="eqviz"
DESTINATION="platform=macOS,arch=arm64"

c_reset=$'\033[0m'
c_dim=$'\033[2m'
c_cyan=$'\033[36m'
c_yellow=$'\033[33m'
c_red=$'\033[31m'
c_green=$'\033[32m'

info() { printf '%s%s%s\n' "$c_cyan" "$*" "$c_reset"; }
warn() { printf '%s%s%s\n' "$c_yellow" "$*" "$c_reset"; }
err() { printf '%s%s%s\n' "$c_red" "$*" "$c_reset"; }
ok() { printf '%s%s%s\n' "$c_green" "$*" "$c_reset"; }

confirm() {
  local msg="$1"
  printf '%s [y/N]: ' "$msg"
  local ans=""
  read -r ans || true
  case "${ans:-}" in
    y | Y | yes | YES) return 0 ;;
    *)
      warn "Cancelado."
      return 1
      ;;
  esac
}

pause() {
  printf '%s' "Enter para seguir..."
  read -r _ || true
}

has_xcode_project() {
  [[ -d "$XCODEPROJ" && -f "$XCODEPROJ/project.pbxproj" ]]
}

has_project_yml() {
  [[ -f "$PROJECT_YML" ]]
}

macos_ready() {
  has_xcode_project || has_project_yml
}

need_macos() {
  if ! macos_ready; then
    err "Proyecto macOS aún no existe. Siguiente: roadmap/02-xcode-bootstrap.md (hace falta Bundle ID). App = Swift+SwiftUI locked."
    return 1
  fi
  return 0
}

eqviz_pids() {
  pgrep -f '/eqviz\.app/Contents/MacOS/' 2>/dev/null || true
  pgrep -x eqviz 2>/dev/null || true
}

unique_pids() {
  eqviz_pids | awk 'NF && !seen[$0]++'
}

cmd_status() {
  info "=== eqviz status ==="
  printf 'root: %s\n' "$ROOT"
  printf 'darwin: %s\n' "$(uname -srm)"
  if command -v uv >/dev/null 2>&1; then
    ok "uv: $(uv --version 2>/dev/null | head -n1)"
  else
    warn "uv: no instalado"
  fi
  if [[ -f "$ROOT/pyproject.toml" ]]; then
    ok "tooling python: pyproject.toml presente"
  else
    warn "python project: ausente"
  fi
  if command -v xcodegen >/dev/null 2>&1; then
    ok "xcodegen: $(xcodegen --version 2>/dev/null | head -n1)"
  else
    printf '%s\n' "xcodegen: no instalado (roadmap/02; instalalo vos, p. ej. brew install xcodegen)"
  fi
  if command -v xcodebuild >/dev/null 2>&1; then
    ok "xcodebuild: presente"
  else
    warn "xcodebuild: ausente (instalá Xcode)"
  fi
  if has_project_yml; then
    ok "macos/project.yml: sí"
  else
    printf '%s\n' "macos/project.yml: no"
  fi
  if has_xcode_project; then
    ok "macos/eqviz.xcodeproj: sí"
  else
    printf '%s\n' "macos/eqviz.xcodeproj: no"
  fi
  local pids
  pids="$(unique_pids || true)"
  if [[ -n "${pids:-}" ]]; then
    warn "proceso eqviz PID(s): $(echo "$pids" | tr '\n' ' ')"
  else
    printf '%s\n' "proceso eqviz: no corre"
  fi
  echo
  cmd_roadmap_next
}

cmd_sync_python() {
  if ! command -v uv >/dev/null 2>&1; then
    err "uv no está en PATH. No instalo nada en silencio."
    return 1
  fi
  uv sync --group dev
}

cmd_run_python_stub() {
  if ! command -v uv >/dev/null 2>&1; then
    err "uv no está en PATH."
    return 1
  fi
  uv run python main.py
}

cmd_test_python() {
  if [[ ! -d "$ROOT/tests" ]]; then
    warn "No hay directorio tests/. Nada que correr."
    return 0
  fi
  uv run pytest
}

cmd_lint_python() {
  uv run ruff check .
}

cmd_format_python() {
  if ! confirm "Esto reescribe .py con ruff format. ¿Seguro?"; then
    return 0
  fi
  uv run ruff format .
}

cmd_precommit_install() {
  uv run pre-commit install
}

cmd_precommit_all() {
  if ! confirm "Correr pre-commit --all-files (puede autofix)?"; then
    return 0
  fi
  uv run pre-commit run --all-files
}

xcodegen_if_needed() {
  if has_project_yml; then
    if ! command -v xcodegen >/dev/null 2>&1; then
      err "Hay project.yml pero xcodegen no está. Instalalo vos (p. ej. brew install xcodegen). Este script no instala host tools."
      return 1
    fi
    (cd "$ROOT/macos" && xcodegen generate)
  fi
}

cmd_open_xcode() {
  need_macos || return 1
  xcodegen_if_needed || return 1
  if ! has_xcode_project; then
    err "No hay .xcodeproj después de generate."
    return 1
  fi
  open "$XCODEPROJ"
}

cmd_build_macos() {
  need_macos || return 1
  xcodegen_if_needed || return 1
  if ! command -v xcodebuild >/dev/null 2>&1; then
    err "xcodebuild ausente."
    return 1
  fi
  mkdir -p "$DERIVED"
  xcodebuild \
    -project "$XCODEPROJ" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -configuration Debug \
    -derivedDataPath "$DERIVED" \
    build
}

app_path() {
  local p="$DERIVED/Build/Products/Debug/eqviz.app"
  if [[ -d "$p" ]]; then
    printf '%s' "$p"
    return 0
  fi
  return 1
}

cmd_test_macos() {
  need_macos || return 1
  xcodegen_if_needed || return 1
  mkdir -p "$DERIVED"
  xcodebuild \
    -project "$XCODEPROJ" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -configuration Debug \
    -derivedDataPath "$DERIVED" \
    test
}

cmd_run_macos() {
  need_macos || return 1
  cmd_build_macos || return 1
  local app
  if ! app="$(app_path)"; then
    err "No encuentro eqviz.app en $DERIVED. No adivino otro DerivedData de usuario."
    return 1
  fi
  open "$app"
}

cmd_stop_macos() {
  local pids
  pids="$(unique_pids || true)"
  if [[ -z "${pids:-}" ]]; then
    warn "No hay proceso eqviz para detener."
    return 0
  fi
  printf 'PIDs:\n%s\n' "$pids"
  if ! confirm "Mandar SIGTERM a esos PID?"; then
    return 0
  fi
  # shellcheck disable=SC2086
  kill $pids 2>/dev/null || true
  sleep 1
  pids="$(unique_pids || true)"
  if [[ -n "${pids:-}" ]]; then
    warn "Siguen vivos: $pids"
    if confirm "Mandar SIGKILL?"; then
      # shellcheck disable=SC2086
      kill -9 $pids 2>/dev/null || true
    fi
  else
    ok "Detenido."
  fi
}

cmd_roadmap_next() {
  if [[ ! -f "$STATUS_FILE" ]]; then
    err "Falta $STATUS_FILE"
    return 1
  fi
  local line file
  line="$(grep -E '^- \[ \] \[' "$STATUS_FILE" | head -n1 || true)"
  if [[ -z "${line:-}" ]]; then
    ok "Roadmap: no hay pasos pendientes (todos [x]) o STATUS vacío de pendientes."
    return 0
  fi
  file="$(printf '%s' "$line" | sed -n 's/.*](\.\/\([^)]*\)).*/\1/p')"
  info "Siguiente paso: $line"
  if [[ -n "${file:-}" && -f "$ROOT/roadmap/$file" ]]; then
    printf '%s\n' "Archivo: roadmap/$file"
    printf '%s\n' "Decile al agente: Ejecutá roadmap/$file (leé antes roadmap/00-invariants.md)."
  fi
}

cmd_print_invariants() {
  if [[ -f "$ROOT/roadmap/00-invariants.md" ]]; then
    ${PAGER:-less} "$ROOT/roadmap/00-invariants.md"
  else
    err "Falta roadmap/00-invariants.md"
  fi
}

menu() {
  printf '\n%s eqviz setup.sh %s\n' "$c_cyan" "$c_reset"
  printf '%s  Admin. App = Swift+SwiftUI. Tooling = uv. macOS: xcodebuild → macos/build/.%s\n\n' "$c_dim" "$c_reset"
  cat <<'EOF'
  1)  Estado
  2)  Tooling: uv sync
  3)  Tooling: stub Python (main.py)
  4)  Tooling: tests (pytest)
  5)  Tooling: lint (ruff check)
  6)  Tooling: format (ruff format)  [pide confirmación]
  7)  Git: instalar hooks pre-commit
  8)  Git: pre-commit --all-files   [pide confirmación]
  9)  macOS: abrir Xcode
 10)  macOS: build
 11)  macOS: tests
 12)  macOS: run
 13)  macOS: stop                   [pide confirmación]
 14)  Roadmap: siguiente paso
 15)  Roadmap: ver contrato (00)
  0)  Salir
EOF
  printf '\nOpción: '
}

loop() {
  local opt
  while true; do
    menu
    opt=""
    read -r opt || exit 0
    echo
    case "${opt:-}" in
      1) cmd_status ;;
      2) cmd_sync_python ;;
      3) cmd_run_python_stub ;;
      4) cmd_test_python ;;
      5) cmd_lint_python ;;
      6) cmd_format_python ;;
      7) cmd_precommit_install ;;
      8) cmd_precommit_all ;;
      9) cmd_open_xcode ;;
      10) cmd_build_macos ;;
      11) cmd_test_macos ;;
      12) cmd_run_macos ;;
      13) cmd_stop_macos ;;
      14) cmd_roadmap_next ;;
      15) cmd_print_invariants ;;
      0 | q | Q)
        exit 0
        ;;
      *)
        warn "Opción inválida. No asumo nada."
        ;;
    esac
    echo
    pause
  done
}

usage() {
  cat <<EOF
uso: ./setup.sh [comando]

sin argumentos: menú interactivo

comandos:
  status | sync | stub | test-py | lint | format
  hooks | hooks-run
  xcode | build | test-mac | run | stop
  next | help
EOF
}

main() {
  if [[ $# -eq 0 ]]; then
    loop
    return
  fi
  case "$1" in
    status) cmd_status ;;
    sync) cmd_sync_python ;;
    stub) cmd_run_python_stub ;;
    test-py) cmd_test_python ;;
    lint) cmd_lint_python ;;
    format) cmd_format_python ;;
    hooks) cmd_precommit_install ;;
    hooks-run) cmd_precommit_all ;;
    xcode) cmd_open_xcode ;;
    build) cmd_build_macos ;;
    test-mac) cmd_test_macos ;;
    run) cmd_run_macos ;;
    stop) cmd_stop_macos ;;
    next) cmd_roadmap_next ;;
    -h | --help | help) usage ;;
    *)
      err "comando desconocido: $1"
      usage
      exit 1
      ;;
  esac
}

main "$@"
