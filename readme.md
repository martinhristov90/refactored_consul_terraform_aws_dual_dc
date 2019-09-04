### Simple example of how to create two Consul server in dual DC(dc_east and dc_west) using Terraform and AWS.

### Purpose:
- It is a simple example of creating two Consul DCs in same AWS VPC.

### How to use it :
- In a directory of your choice, clone the github repository :
    ```
    git clone https://github.com/martinhristov90/consul_terraform_aws_dual_dc.git
    ```

- Change into the directory :
    ```
    cd consul_terraform_aws_dual_dc
    ```
- Create a AWS AMI by running `packer build packer/template.json`.

- Run `terraform plan` and `terraform apply`

### Nota Bene:

- The `packer` directory contains a Packer template to build a AWS AMI with Consul installed as Systemd service.
- Private key to connect to the EC2 instance is going to be placed inside private_keys directory.
- For more detailed information review the comments inside the code.
- The `auto_join_user` used for auto-join has just `ec2:DescribeInstances`. 
- Only port 22 is exported to the outside world, to view the UI of Consul, you need to create SSH tunnel by using following command : `ssh -f -N -T -L localhost:8500:localhost:8500 -i ./private_keys/consul_server_key_east_private.key ubuntu@IP_OUTPUTTED_BY_TERRAFORM` and use your browser to connect to `localhost:8500/ui/`
