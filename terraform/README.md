**current issues**
- outputs file req our AWS environment. Currently waiting on Susan to decide how much room to give us for AWS deployment.... So I left it intentionally blank.

I wanted to explore different infrastructure ideas. Many of the terraform files were created with the help of claude. Im not entirely familiar with terraform, the files are plaintext files that are used in Terraforms language called HCL (hashicorp configuration language). Terraform takes plaintext and essentially 'figures' it out to build it. 


**other deployment notes**
- in variables.tf, currently set to region US-west 2, dont see a point in distributing test work across a bunch of areas.