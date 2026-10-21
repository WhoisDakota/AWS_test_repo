**current issues**
- outputs file req our AWS environment. Currently waiting on Susan to decide how much room to give us for AWS deployment.... So I left it intentionally blank.

I wanted to explore different infrastructure ideas. Many of the terraform files were created with the help of claude. Im not entirely familiar with terraform, the files are plaintext files that are used in Terraforms language called HCL (hashicorp configuration language). Terraform takes plaintext and essentially 'figures' it out to build it. 


**other deployment notes**
- in variables.tf, currently set to region US-west 2, dont see a point in distributing test work across a bunch of areas.



**explanation of folder contents**
`versions.tf`	Which Terraform and provider versions to use, and the AWS region setup
`variables.tf`	self defined Inputs (region, project name)
`network.tf`	VPC, subnets, security groups
`database.tf`	The RDS PostgreSQL instance
`lambda.tf`	Lambda functions and their IAM roles
`api.tf`	API Gateway
`cognito.tf`	User login
`frontend.tf`	S3 bucket and CloudFront
`outputs.tf`	Values printed after apply (site URL)


**commands for running terraform**
`terraform init`      # download the AWS provider plugin (run once)
`terraform plan`      # preview what would change, without changing anything
`terraform apply`     # create or update the real infrastructure
`terraform destroy`   # delete everything it created