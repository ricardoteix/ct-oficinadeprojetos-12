[<img src="https://em-content.zobj.net/thumbs/160/openmoji/338/flag-brazil_1f1e7-1f1f7.png" alt="us flag" width="48"/>](./README.md)

# Introduction

This project allows you to create the infrastructure on AWS to run [MediaCMS](https://github.com/mediacms-io/mediacms), which is an open-source media manager.

The goal is to create all the necessary resources, such as VPC, Subnet, Route Tables, EC2, RDS, S3, etc., to run a project on an Ubuntu 20.04 LTS instance.

Most of the project is written in Terraform with some shell scripts.

You can configure certain resources from the **terraform.tfvars** file. In this repository, the [terraform.tfvars.exemplo](./terraform.tfvars.exemplo) file serves as a foundation for creating the **terraform.tfvars** file.

# Architecture

Below, we have the main architecture diagram and a second diagram proposing the automation of a video encoding instance.

## Main Diagram
![Main Diagram](./arquitetura/Diagrama%20Principal.png)

## Automation Diagram
![Automation Diagram](./arquitetura/Diagrama%20Automacao.png)

# Terraform

Terraform is a technology used for Infrastructure as Code (IaaC), similar to AWS CloudFormation.

However, with Terraform, it's possible to define infrastructure for other clouds like GCP and Azure.

## Installation

To use Terraform, you need to download the compiled binary file for your system. Visit [https://www.terraform.io/downloads](https://www.terraform.io/downloads).

## Initializing the Repository

You need to initialize Terraform at the root of this project by executing

```
terraform init
```

## Defining Credentials

The Terraform definition file is named main.tf.

This is where we specify how our infrastructure will be set up.

It's important to note that in the provider "aws" block, we define that we're using Terraform with AWS.

```
provider "aws" {
  region = "us-east-1"
  profile = "my-project"
}
```

Since Terraform automatically creates the entire infrastructure on AWS, permissions are required for this through credentials.

Although it's possible to specify the keys directly within the provider block, this approach is not recommended. Especially since this code is in a Git repository, anyone with access to the repository would have access to the credentials.

A better option is to use an AWS *profile* configured locally.

Here, we're using a profile named **my-project**. To create a profile, execute the following command using the AWS CLI and fill in the prompted parameters.


```
aws configure --profile my-project
```

## Variables - Additional Configurations

In addition to configuring the profile, you'll need to define some variables.

To avoid exposing sensitive data on Git, such as database passwords, you need to copy the ``terraform.tfvars.example`` file to ``terraform.tfvars``.

In the ``terraform.tfvars`` file, redefine the values of the variables. Note that you'll need to have a domain registered in Route53 if you want to use a domain instead of just accessing via the LoadBalancer's URL.

All possible variables for this file can be seen in the ``variables.tf`` file. Only a few of them were used in the example.

## Applying the Defined Infrastructure

Terraform provides several basic commands to plan, apply, and destroy infrastructure.

When you start applying the infrastructure, Terraform creates the ``terraform.tfstate`` file, which should be preserved and not manually modified.

Through this file, Terraform knows the current state of the infrastructure and can add, modify, or remove resources.

In this repository, we're not versioning this file because it's a shared repository for study purposes. In a real repository, you would likely want to keep this file preserved in Git.

###  Checking What Will Be Created, Removed, or Modified
```
terraform plan
```

###  Applying the Defined Infrastructure
```
terraform apply
```
or, to automatically confirm.
```
terraform apply --auto-approve
```

###  Destroying Your Entire Infrastructure

<font color="red">
  <span><b>CAUTION!</b><br>
  After executing the commands below, you will lose everything specified in your Terraform file (database, EC2, EBS, etc.).</span>
</font>

```
terraform destroy
```
or, to automatically confirm.
```
terraform destroy --auto-approve
```

## Considerations Regarding Infrastructure Creation

1. After executing ``terraform apply``, the terminal will show how many resources were added, modified, or destroyed in your infrastructure.

1. As [SES](https://docs.aws.amazon.com/pt_br/ses/latest/dg/request-production-access.html) has certain limits, to send and receive emails from the platform, you need to validate the email address you specified. Shortly after executing ``terraform apply``, you should receive two confirmation and subscription emails in the email address specified in **terraform.tfvars**.

1. In our code, we added some additional output information necessary to access the created resources, such as the database. See below.

1. Access to the application will be through the address presented in ``elb-dns`` or the domain, if specified and configured as such.

1. Some configurations, such as database host, SMTP, and bucket name, will be stored in an [System Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) named **mediacms**.

1. For initial login, use the username **admin** and the password **adm2023cms**.

1. When destroying the infrastructure, in addition to the data on EC2, RDS, and Elasticache, all files in the bucket will be lost.


# Final Considerations

This project is designed for experimentation and studying Terraform. Although it provides the creation of the minimum resources to run the project on AWS, it is not recommended to use this project for deploying workloads in a production environment.

Despite employing techniques to support scalability in terms of user access, no real user testing has been conducted. Only minimal load testing simulations were performed with up to 200 virtual users using the [Locust](https://locust.io/) tool. See files in the[locust-load-test](./locust-load-test/) folder.

# Known Issues

1. The application performs multipart uploads for files considered large, larger than 4 MB apparently. Since the Lambda is triggered by the S3 ``CompleteMultipartUpload`` event, these smaller files won't trigger the Lambda. Tests need to be conducted with the PUT/POST trigger to determine whether they might cause issues by creating files in the same bucket.

2. Currently, the Lambda trigger fires when files with extensions .mp4, .m4v, .mov, and .avi arrive in any location within the bucket. Ideally, it should trigger when the file arrives in a specific folder, which hasn't been identified yet.

# References

1. [Media CMS](https://github.com/mediacms-io/mediacms/)
1. [Media CMS - Server Installation](https://github.com/mediacms-io/mediacms/blob/main/docs/admins_docs.md#2-server-installation)
1. [Media CMS - Configuration](https://github.com/mediacms-io/mediacms/blob/main/docs/admins_docs.md#5-configuration)
1. [S3FS](https://github.com/s3fs-fuse/s3fs-fuse)
1. [AWS Storage Gateway](https://aws.amazon.com/pt/storagegateway/)
1. [Terraform](https://www.terraform.io/)
1. [Locust](https://locust.io/)
