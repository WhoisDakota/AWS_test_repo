**Requirements**
-in create:  pg8000>=1.30,<2

**Details**

API Gateway (HTTP API, Cognito JWT authorizer) + Lambda (Python) + RDS PostgreSQL in a private VPC,
with a static frontend on S3 + CloudFront. Everything is Terraform, for confusion and suffering

Browser (CloudFront + S3) -> Cognito Hosted UI as its our current choice (PKCE) -> ID token
   
   |
   push to 
   v
API Gateway ->JWT authorizer -> Lambda (private subnets) -> 5432, SG-to-SG -> RDS PostgreSQL

***nitty gritty database stuff***
Route | Auth | Purpose 

`POST /links` | JWT | create a short link 
`GET /links` | JWT | list your links 
`DELETE /links/{code}` | JWT | delete your link (ownership checked in SQL) 
`GET /{code}` | none | 302 redirect + atomic click count 
