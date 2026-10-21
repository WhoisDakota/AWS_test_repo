# AWS_test_repo
For testing out different ideas for our backend. 

**File overview**


scripts/build.sh      #packages Lambda code + pg8000 + RDS CA bundle
lambda/               #db.py (shared), create, list, delete, redirect, migrate
terraform/            #network, database, cognito, lambda, api, frontend, outputs
frontend/index.html   #Cognito login (PKCE), create/list/copy/delete links
README.md



**Details**


API Gateway (HTTP API, Cognito JWT authorizer) + Lambda (Python) + RDS PostgreSQL in a private VPC,
with a static frontend on S3 + CloudFront. Everything is Terraform, for confusion and suffering

Browser (CloudFront + S3) -> Cognito Hosted UI as its our current choice (PKCE) -> ID token      
...................................................
push to 
...................................................
API Gateway ->JWT authorizer -> Lambda (private subnets) -> 5432, SG-to-SG -> RDS PostgreSQL



***nitty gritty database stuff***


Route | Auth | Purpose 

`POST /links` | JWT | create a short link 
`GET /links` | JWT | list your links 
`DELETE /links/{code}` | JWT | delete your link (ownership checked in SQL) 
`GET /{code}` | none | 302 redirect + atomic click count 




***Deployment***
from terminal (bash) : 
`$ls`  #check that scripts folder exists


`$./scripts/build.sh` ->
`$cd terraform` -> 
`$terraform init`->
`$terraform apply`



**what is still needed**
- front end (will work with other teams on this)
- I still have to write test cases
