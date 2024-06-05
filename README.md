terraform plan -var-file=terraform.tfvars

# Prerequisite for new environment creation

## Import TLS/SSL certificate in the region in ACM. you must **NOT** **NOT** create new certificate. this is one time activity to import certificate.

## You must update the `template.json` file with proper value. you can use `generate_secret.py` to generate the secret.

```
python generate_secret.py

```

## Once above prerequisite is done then run the following command to create the environment. you can remove `-auto-approve` if you want to see the plan before apply.

```
terraform init
terraform apply -var-file=terraform.tfvars -auto-approve
```

## After UI has been created you must manually register the domain in amplify console

## You need to take CNAME of domain and register in cloudflare manually

## Destory the environment

### First remove the Domain from amplify application manually

```
terraform destroy -var-file=terraform.tfvars
```

### After you must remove the web hook for ui app which has been created by amplify. go to github and find the webhook for this region and remove it.
