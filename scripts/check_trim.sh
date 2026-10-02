#!/usr/bin/env bash
# Feature contract for the ERPNext ECS HR app.
#
# The app is the upstream Frappe HR Vue app with some features deliberately hidden. Hiding them means
# DELETING their files (see CUSTOMIZATION.md), so the failure mode this guards against is quiet: a rebase
# on a new upstream tag, or a stray import, brings a hidden feature back into the shipped bundle and
# nobody notices until a user sees a menu they should not have.
#
# Usage: scripts/check_trim.sh [assets-dir]     (default: erpnext_ecs/public/frontend/assets)
set -uo pipefail

ASSETS="${1:-erpnext_ecs/public/frontend/assets}"

if ! compgen -G "$ASSETS/*.js" > /dev/null; then
	echo "FAIL: no built JS under $ASSETS — run 'yarn build' in frontend/ first" >&2
	exit 1
fi

# must be reachable in the shipped bundle
VISIBLE=(
	"dashboard/attendance"
	"attendance-requests"
	"shift-requests"
	"employee-checkins"
	"dashboard/expense-claims"
	"dashboard/salary-slips"
	"Request Attendance"
	"Claim an Expense"
	"View Salary Slips"
)

# must NOT appear anywhere in the shipped bundle
HIDDEN=(
	"dashboard/leaves"
	"LeaveApplicationFormView"
	"EmployeeAdvanceFormView"
	"Request Leave"
	"Request an Advance"
)

status=0

for needle in "${VISIBLE[@]}"; do
	count=$(grep -rl -- "$needle" "$ASSETS"/*.js 2>/dev/null | wc -l | tr -d ' ')
	if [ "$count" -eq 0 ]; then
		echo "FAIL: '$needle' is missing from the build — a feature we ship has gone" >&2
		status=1
	else
		echo "ok   visible: $needle ($count file(s))"
	fi
done

for needle in "${HIDDEN[@]}"; do
	count=$(grep -rl -- "$needle" "$ASSETS"/*.js 2>/dev/null | wc -l | tr -d ' ')
	if [ "$count" -ne 0 ]; then
		echo "FAIL: '$needle' is back in the build in $count file(s) — a hidden feature shipped" >&2
		status=1
	else
		echo "ok   hidden : $needle"
	fi
done

if [ "$status" -eq 0 ]; then
	echo "feature contract held"
else
	echo "feature contract BROKEN — see CUSTOMIZATION.md" >&2
fi
exit "$status"
