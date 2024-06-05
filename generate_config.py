import json

with open("filled_template.json", 'r') as file:
    data = json.load(file)

DYNAMIC_URLS=data["DYNAMIC_URLS"]
IMPORTER_JSON_KEYS=["DB_CREDS","SF_CREDS","IMPORTER"]
UI_JSON_KEYS=["FIX_UI_VARS","UI_ENV_SPECIFIC"]
EXCLUDE_SERVICE_KEYS=["DYNAMIC_URLS","IMPORTER","FIX_UI_VARS","UI_ENV_SPECIFIC","EMAIL_AND_COMMON_VARS"]
# print(DYNAMIC_URLS)
ui_data={}
ui_admin_data={}
importer_data={}
service_data={}
admin_data={}
django_data={}


for k in UI_JSON_KEYS:
    ui_data.update(data[k])

for k in data.keys():
    if k not in EXCLUDE_SERVICE_KEYS:
        service_data.update(data[k])

for k in IMPORTER_JSON_KEYS:
    importer_data.update(data[k])

for k in data["EMAIL_AND_COMMON_VARS"].keys():
    if k in service_data.keys():
        service_data[k]=data["EMAIL_AND_COMMON_VARS"][k]
    if k in ui_data.keys():
        ui_data[k]=data["EMAIL_AND_COMMON_VARS"][k]


ui_admin_data=ui_data.copy()
ui_data["REACT_APP_BASE_API_URL"]=DYNAMIC_URLS["BASE_URL"]+"/api/v1"
ui_admin_data["REACT_APP_BASE_API_URL"]=DYNAMIC_URLS["BASE_ADMIN_URL"]+"/api/v1"
ui_admin_data["REACT_APP_ADMIN_ONLY"]="true"

# service_data["DJANGO_ADMIN"]="True"
service_data["ADMIN_FRONTEND_BASE_URL"]=DYNAMIC_URLS["ADMIN_FRONTEND_BASE_URL"] + "/"
service_data["FRONTEND_BASE_URL"]=DYNAMIC_URLS["FRONTEND_BASE_URL"] + "/"
service_data["BASE_URL"]=DYNAMIC_URLS["BASE_URL"]

django_data = service_data.copy()
admin_data = service_data.copy()

django_data["DJANGO_ADMIN"]="True"

admin_data["ENABLE_SF_APIS"]="True"
admin_data["ENABLE_CRON_JOBS"]="True"
admin_data["ENABLE_ADMIN_APIS"]="True"

service_data["CORS_ALLOWED_ORIGINS"]=DYNAMIC_URLS["FRONTEND_BASE_URL"]
admin_data["CORS_ALLOWED_ORIGINS"]=DYNAMIC_URLS["ADMIN_FRONTEND_BASE_URL"]
django_data["CORS_ALLOWED_ORIGINS"]=DYNAMIC_URLS["ADMIN_FRONTEND_BASE_URL"]

BASE_OUTPUT_PATH="sm_config_files"

with open(f'{BASE_OUTPUT_PATH}/_admin_service.json', 'w') as file:
    json.dump(admin_data, file, indent=4)
with open(f'{BASE_OUTPUT_PATH}/_vcheck_service.json', 'w') as file:
    json.dump(service_data, file, indent=4)
with open(f'{BASE_OUTPUT_PATH}/_django.json', 'w') as file:
    json.dump(django_data, file, indent=4)
with open(f'{BASE_OUTPUT_PATH}/_importer.json', 'w') as file:
    json.dump(importer_data, file, indent=4)

with open(f'{BASE_OUTPUT_PATH}/_ui_portal.json', 'w') as file:
    json.dump(ui_data, file, indent=4)
with open(f'{BASE_OUTPUT_PATH}/_ui_admin_portal.json', 'w') as file:
    json.dump(ui_admin_data, file, indent=4)

print(f"file created...")
# json_data = json.dumps(admin_data, ensure_ascii=False)

# print(json_data)

# with open('output.json', 'w') as file:
#     json.dump(data, file, indent=4)