# Customisation against upstream `frappe/hrms`

**Base: hrms v16.20.1** (`frontend/` only — the Python side of hrms is untouched).

Visible in our app: **Home** (check-in card + four quick links) · **Attendance** (incl. shift requests and
shift assignments) · **Expenses** · **Salary**.
Hidden: **Leaves** and **Employee Advances** — nothing else is trimmed.

An upgrade = diff upstream `frontend/` at the new tag against v16.20.1, then re-apply this list.

## Modified against upstream

| File | Change |
|---|---|
| `frontend/index.html` | every `/assets/hrms/` → `/assets/erpnext_ecs/` (PWA icons, splash screens) |
| `frontend/vite.config.js` | `outDir` → `../erpnext_ecs/public/frontend`; PWA `start_url` → `/hrms-ecs` |
| `frontend/package.json` | name `erpnext-ecs-ui`; `build` / `copy-html-entry` write into `erpnext_ecs/` |
| `frontend/src/main.js` | service-worker URL → `/assets/erpnext_ecs/frontend/sw.js` (push notifications still use the `"hrms"` project name) |
| `frontend/src/router/index.js` | adds `attendanceRoutes` next to `claims` + `salary_slips`; dashboards limited to attendance, expense-claims and salary-slips; `createWebHistory("/hrms-ecs")` |
| `frontend/src/components/BottomTabs.vue` | `tabItems` = Home · Attendance · Expenses · Salary (**no Leaves**) |
| `frontend/src/views/Home.vue` | `CheckInPanel` kept; `RequestPanel` (leave/advance requests) not restored; `QuickLinks` = Request Attendance · Request a Shift · Claim an Expense · View Salary Slips |
| `frontend/src/views/expense_claim/Dashboard.vue` | the *Employee Advance Balance* block removed (advances are hidden) |
| `frontend/src/components/ListView.vue` | item map = Employee Checkin · Attendance Request · Shift Request · Shift Assignment · Expense Claim (no Leave Application, no Employee Advance) |

## Deleted (upstream files not present here)

```
frontend/src/views/leave/                      frontend/src/views/employee_advance/
frontend/src/router/leaves.js                  frontend/src/router/advances.js
frontend/src/components/RequestPanel.vue       LeaveRequestItem.vue     LeaveBalance.vue
frontend/src/components/Holidays.vue           EmployeeAdvanceItem.vue  EmployeeAdvanceBalance.vue
frontend/src/components/icons/LeaveIcon.vue    EmployeeAdvanceIcon.vue
frontend/src/data/leaves.js                    frontend/src/data/advances.js
```

Everything else in `frontend/src` is upstream v16.20.1 as-is — the Attendance files (views, `router/attendance.js`,
`CheckInPanel`, `AttendanceCalendar`, `AttendanceRequestItem`, `ShiftRequestItem`, `ShiftAssignmentItem`,
`EmployeeCheckinItem`, their icons, `data/attendance.js`) were **restored verbatim** after first being removed.

**Why deleting files is required, not cosmetic:** `components/RequestActionSheet.vue` loads its field
components with a variable dynamic import built from a component name. Vite cannot resolve that statically, so
**every file in `frontend/src/components/` is folded into the bundle** — removing imports alone leaves the
hidden features' code (and chunks) in the shipped build. Deleting the files is what actually removes them.

Verified in the shipped `assets/*.js` after the last build: `dashboard/attendance`, `attendance-requests`,
`shift-requests`, `employee-checkins`, `dashboard/expense-claims`, `dashboard/salary-slips` present;
`dashboard/leaves`, `LeaveApplicationFormView`, `EmployeeAdvanceFormView` absent.
