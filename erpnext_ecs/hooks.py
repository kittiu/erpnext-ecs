app_name = "erpnext_ecs"
app_title = "ERPNext ECS"
app_publisher = "Ecosoft"
app_description = "Ecosoft's HR app — the Frappe HR Vue app with only Salary and Expenses visible"
app_email = "kittiu@ecosoft.co.th"
app_license = "gpl-3.0"

# the SPA: every /hrms-ecs/... path renders the one page built from frontend/
website_route_rules = [
	{"from_route": "/hrms-ecs/<path:app_path>", "to_route": "hrms-ecs"},
]
