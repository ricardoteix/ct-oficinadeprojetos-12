[<img src="https://em-content.zobj.net/thumbs/160/openmoji/338/flag-brazil_1f1e7-1f1f7.png" alt="us flag" width="48"/>](./README.md)

# Using an AMI for MediaCMS

As the entire application preparation process after booting with user data can take a few minutes, it's recommended to create an AMI from an instance that is running fully.

This AMI can be specified in the **terraform.tfvars** file to be used instead of the default Ubuntu instance. This way, the application will become available much faster for subsequent instances created by AutoScaling.

After creating the AMI, make the following changes in the **terraform.tfvars** file.

- Specify the following new file for user data. It's just a placeholder and won't affect the instance.

  ``arquivo-user-data="./usando_ami/placeholder_user_data.sh"``

- Specify the new AMI to be used.

  ``ec2-ami="ami-12334545656790"``

- I've blocked the creation of instances in public networks as external access won't be needed. The VPC Endpoints are connecting AWS services with the private network.

  ``ec2-usar-ip-publico=false``

After applying these changes, a new upload instance will be created based on the AMI, and the LaunchTemplate will be updated. AutoScaling instances need to be terminated for new ones to be created from the AMI, if desired.