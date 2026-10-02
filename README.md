# erpnext-ecs

Ecosoft's customisation app on top of **ERPNext** and **HRMS** (Frappe v16).
One app for every Ecosoft customisation; the first deliverable is the HR app.

## First deliverable — the HR app (Vue), Salary + Expenses only

The upstream Frappe HR Vue app (`frappe/hrms` → `frontend/`, Ionic + Vue 3 + `frappe-ui`) with every feature
hidden except **Salary** (Salary Slip) and **Expenses** (Expense Claim). No new features were written.

- Page: `/hrms-ecs` (route rule in `erpnext_ecs/hooks.py`), served as `erpnext_ecs/www/hrms-ecs.html`
- Route base inside the SPA: `createWebHistory("/hrms-ecs")`
- `frontend/CUSTOMIZATION.md` **is the contract**: every file changed or deleted against upstream, so an
  upgrade is "re-apply the list", not a re-discovery.

## Layout

```
frontend/                  the Vue app (copy of hrms frontend, trimmed) — the source of truth
erpnext_ecs/
├── hooks.py               app metadata + website_route_rules
├── public/manifest/       PWA icons / splash screens
└── www/                   hrms-ecs.html is produced by the build (git-ignored)
```

## Build

Needs Node and Yarn 1.x (`frontend/yarn.lock` is authoritative):

```bash
cd frontend
yarn install --frozen-lockfile
yarn build          # -> ../erpnext_ecs/public/frontend/ and ../erpnext_ecs/www/hrms-ecs.html
```

`yarn build` = `vite build --base=/assets/erpnext_ecs/frontend/` plus the copy of the built `index.html`
(a Jinja template carrying `{{ csrf_token }}` and `{{ boot }}`) into `erpnext_ecs/www/hrms-ecs.html`.

## Install on a bench

```bash
bench get-app https://github.com/kittiu/erpnext-ecs
bench --site <site> install-app erpnext_ecs
```
The app has no DocTypes of its own — it serves the SPA and will hold later customisations.

## Upgrading from upstream

Base pinned: **hrms v16.20.1**. To take a new upstream version: diff `hrms/frontend/` at the new tag against
`v16.20.1`, and re-apply the entries in `frontend/CUSTOMIZATION.md`.
