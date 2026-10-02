# Customisation against upstream `frappe/hrms`

**Base: hrms v16.20.1** (`frontend/` only — the Python side of hrms is untouched).
Goal: same features as upstream, minus everything except **Salary** and **Expenses**.

An upgrade = diff upstream `frontend/` at the new tag against v16.20.1, then re-apply this list.

## Modified

| File | Change |
|---|---|
| `frontend/index.html` | every `/assets/hrms/` → `/assets/erpnext_ecs/` (PWA icons, splash screens) |
| `frontend/vite.config.js` | `outDir` → `../erpnext_ecs/public/frontend`; PWA `start_url` → `/hrms-ecs` |
| `frontend/package.json` | name `erpnext-ecs-ui`; `build` / `copy-html-entry` write into `erpnext_ecs/` |
| `frontend/src/main.js` | service-worker URL → `/assets/erpnext_ecs/frontend/sw.js` (push notifications still use the `"hrms"` project name) |
| `frontend/src/router/index.js` | keeps `claims` + `salary_slips` routes only; dashboards limited to expense-claims and salary-slips; `createWebHistory("/hrms-ecs")` |
| `frontend/src/components/BottomTabs.vue` | `tabItems` = Home · Expenses · Salary; unused icon imports dropped |
| `frontend/src/views/Home.vue` | `CheckInPanel` and `RequestPanel` removed; `QuickLinks` = *Claim an Expense*, *View Salary Slips* |
| `frontend/src/views/expense_claim/Dashboard.vue` | the whole *Employee Advance Balance* block removed (advances are hidden) |
| `frontend/src/components/ListView.vue` | item-component map limited to `Expense Claim`; unused item imports dropped |

## Deleted

```
frontend/src/views/attendance/            frontend/src/views/leave/             frontend/src/views/employee_advance/
frontend/src/router/attendance.js         frontend/src/router/leaves.js        frontend/src/router/advances.js
frontend/src/components/CheckInPanel.vue          RequestPanel.vue        AttendanceCalendar.vue
frontend/src/components/AttendanceRequestItem.vue ShiftRequestItem.vue    ShiftAssignmentItem.vue
frontend/src/components/LeaveRequestItem.vue      LeaveBalance.vue        Holidays.vue
frontend/src/components/EmployeeAdvanceItem.vue   EmployeeAdvanceBalance.vue   EmployeeCheckinItem.vue
frontend/src/components/icons/AttendanceIcon.vue  LeaveIcon.vue  ShiftIcon.vue  EmployeeAdvanceIcon.vue
frontend/src/data/attendance.js  frontend/src/data/leaves.js  frontend/src/data/advances.js   (unreferenced once the views went)
```

**Why deleting files is required, not cosmetic:** `components/RequestActionSheet.vue` loads its field
components with a variable dynamic import — `import(\`../components/${field.componentName}.vue\`)`. Vite cannot
resolve that statically, so **every file in `frontend/src/components/` is folded into the bundle**. Removing
imports alone leaves the hidden features' code (and chunks) in the shipped build; deleting the files is what
actually removes them. Verified after the build: no `dashboard/attendance`, no `dashboard/leaves`, no
`EmployeeAdvanceFormView` anywhere in `assets/`.
