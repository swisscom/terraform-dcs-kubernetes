#!/bin/sh

# fail on error
set -e

echo ""
echo "> checking the state of the helm releases"
helm list -A
_count_failed_releases=$(helm list --failed -o json -A | grep -o failed | wc -l)
echo ""

if [ "$_count_failed_releases" -eq "0" ]; then
    echo "> OK: no failed helm release found"
    exit 0
else
    echo "> WARNING: found $_count_failed_releases failed helm release(s)"
    echo "> consult the troubleshooting guide available at docs/troubleshooting.md"
    echo ""
    echo "> failed helm releases"
    helm list -A --failed
    exit 1
fi
