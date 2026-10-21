# AWS_test_repo
For testing out different ideas for our backend. 

**File overview**
scripts/build.sh      #packages Lambda code + pg8000 + RDS CA bundle
lambda/               #db.py (shared), create, list, delete, redirect, migrate
terraform/            #network, database, cognito, lambda, api, frontend, outputs
frontend/index.html   #Cognito login (PKCE), create/list/copy/delete links
README.md


***Deployment***
from terminal (bash) : 
$ls  #check that scripts folder exists

$./scripts/build.sh
$cd terraform
$terraform init
$terraform apply


** what is still needed **
- front end (will work with other teams on this)
- I still have to write test cases
