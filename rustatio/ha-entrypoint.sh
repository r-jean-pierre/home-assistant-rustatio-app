#!/bin/bash
set -Eeuo pipefail

APP_VERSION="$(cat /ha-app-version 2>/dev/null || printf 'unknown')"
UPSTREAM_IMAGE="$(cat /ha-upstream-image 2>/dev/null || printf 'unknown')"

WATCH_OPTION="/torrents"
if [ -f /data/options.json ]; then
    WATCH_OPTION="$(jq -r '.watch_folder // "/torrents"' /data/options.json)"
fi

WATCH_RELATIVE="${WATCH_OPTION#/}"
WATCH_RELATIVE="${WATCH_RELATIVE%/}"

if [ -z "${WATCH_RELATIVE}" ]; then
    echo "[HA wrapper] ERROR: watch_folder cannot be empty or '/'."
    exit 1
fi

case "/${WATCH_RELATIVE}/" in
    *"/../"*|*"/./"*)
        echo "[HA wrapper] ERROR: watch_folder may not contain '.' or '..' path segments."
        exit 1
        ;;
esac

WATCH_SOURCE="/ha_share/${WATCH_RELATIVE}"

rm -rf /torrents
ln -s "${WATCH_SOURCE}" /torrents

echo ""
echo "============================================================"
echo " Rustatio Home Assistant App"
echo " App version    : ${APP_VERSION}"
echo " Upstream image : ${UPSTREAM_IMAGE}"
echo " Rustatio port  : ${PORT:-8080}"
echo " Ingress proxy  : http://127.0.0.1:8099"
echo " Watch option   : ${WATCH_OPTION}"
echo " Watch source   : ${WATCH_SOURCE} (read-only)"
echo " Rustatio path  : /torrents"
echo " Started at     : $(date -Iseconds)"
echo "============================================================"

if [ ! -d "${WATCH_SOURCE}" ]; then
    echo "[HA wrapper] WARNING: selected watch folder does not currently exist: ${WATCH_SOURCE}"
fi

register_discovery() {
    if [ -z "${SUPERVISOR_TOKEN:-}" ]; then
        echo "[HA wrapper] WARNING: SUPERVISOR_TOKEN is unavailable; skipping Home Assistant discovery."
        return 0
    fi

    local auth_header="Authorization: Bearer ${SUPERVISOR_TOKEN}"
    local addon_info addon_slug discoveries existing_uuid payload response discovery_uuid

    if ! addon_info="$(curl -fsS -H "${auth_header}" http://supervisor/addons/self/info)"; then
        echo "[HA wrapper] WARNING: could not read app identity; skipping Home Assistant discovery."
        return 0
    fi

    addon_slug="$(jq -r '.data.slug // .slug // empty' <<<"${addon_info}")"
    if [ -z "${addon_slug}" ]; then
        echo "[HA wrapper] WARNING: Supervisor did not return the app slug; skipping discovery."
        return 0
    fi

    if discoveries="$(curl -fsS -H "${auth_header}" http://supervisor/discovery 2>/dev/null)"; then
        existing_uuid="$(
            jq -r --arg addon "${addon_slug}" '
                (.data.discovery // .discovery // [])
                | .[]?
                | select(.addon == $addon and .service == "rustatio")
                | .uuid
            ' <<<"${discoveries}" | head -n 1
        )"
        if [ -n "${existing_uuid}" ]; then
            echo "[HA wrapper] Home Assistant discovery already registered (${existing_uuid})."
            return 0
        fi
    fi

    payload="$(
        jq -nc \
            --arg host "$(hostname)" \
            '{service:"rustatio",config:{host:$host,port:8080}}'
    )"

    if ! response="$(
        curl -fsS \
            -H "${auth_header}" \
            -H "Content-Type: application/json" \
            -X POST \
            -d "${payload}" \
            http://supervisor/discovery
    )"; then
        echo "[HA wrapper] WARNING: failed to register Home Assistant discovery."
        return 0
    fi

    discovery_uuid="$(jq -r '.data.uuid // .uuid // empty' <<<"${response}")"
    if [ -n "${discovery_uuid}" ]; then
        echo "[HA wrapper] Registered Home Assistant discovery (${discovery_uuid})."
    else
        echo "[HA wrapper] Registered Home Assistant discovery."
    fi
}

echo "[HA wrapper] Checking Nginx Ingress configuration..."
nginx -t

echo "[HA wrapper] Starting Nginx Ingress proxy..."
nginx

register_discovery

echo "[HA wrapper] Starting upstream Rustatio..."

# The upstream entrypoint checks whether WATCH_DIR is writable. The Home
# Assistant share is intentionally read-only, so give only that permission
# check a non-existent path. The actual server still receives /torrents.
REAL_WATCH_DIR="/torrents"
export WATCH_DIR="/__ha_readonly_watch_check_skip__"

exec /app/entrypoint.sh env WATCH_DIR="${REAL_WATCH_DIR}" "$@"
