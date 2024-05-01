# TASK BREAKDOWN

## EXERCISE 1: Create IAM user

In this exercise, you will create a new IAM user with the necessary permissions to execute the subsequent tasks.

- [ ] Task 1: Create a new IAM user
  - Log in to the AWS Management Console using an Admin User account.
  - Navigate to the IAM (Identity and Access Management) service.
  - Click on "Users" in the left sidebar and then click on the "Add user" button.
  - Set the following details:
    - User name: Use "your name" as the username.
    - Access type: Select "Programmatic access" and "AWS Management Console access".
    - Console password: Choose "Custom password" and enter a strong password.
    - Require password reset: Uncheck this option.
  - Click on the "Next: Permissions" button.

- [ ] Task 2: Assign permissions to the IAM user
  - On the "Set permissions" page, click on "Create group".
  - Enter "devops" as the group name.
  - Search for and select the following permissions:
    - AmazonEC2FullAccess
    - IAMFullAccess
    - AmazonVPCFullAccess
  - Click on the "Create group" button.
  - Back on the "Set permissions" page, select the newly created "devops" group.
  - Click on the "Next: Tags" button.

- [ ] Task 3: Review and create the IAM user
  - Review the user details and permissions.
  - Click on the "Create user" button.

- [ ] Task 4: Save the IAM user credentials
  - On the success page, click on the "Download .csv" button to download the user credentials.
  - Store the downloaded file securely, as it contains the access key ID and secret access key for the IAM user.

> [!IMPORTANT]
> The IAM user created in this exercise will have full access to EC2, IAM, and VPC services. In a production environment, it is recommended to follow the principle of least privilege and grant only the necessary permissions based on the specific requirements of the user or application.

## EXERCISE 2: Configure AWS CLI

In this exercise, you will configure the AWS CLI to interact with your AWS account using the IAM user credentials created in Exercise 1.

- [ ] Task 1: Install AWS CLI
  - Open a terminal or command prompt on your local machine.
  - Run the following command to install AWS CLI:

    ```bash
    pip install awscli
    ```

  - Verify the installation by running:

    ```bash
    aws --version
    ```

- [ ] Task 2: Configure AWS CLI with IAM user credentials
  - Run the following command to configure AWS CLI:

    ```bash
    aws configure
    ```

  - Provide the following information when prompted:
    - AWS Access Key ID: Enter the access key ID obtained from Exercise 1.
    - AWS Secret Access Key: Enter the secret access key obtained from Exercise 1.
    - Default region name: Enter the desired AWS region (e.g., us-east-1).
    - Default output format: Press Enter to use the default format (json).

- [ ] Task 3: Verify AWS CLI configuration
  - Run the following command to verify the configuration:

    ```bash
    aws sts get-caller-identity
    ```

  - The command should return the IAM user details, confirming that AWS CLI is properly configured.

## EXERCISE 3: Create VPC

In this exercise, you will create a new VPC (Virtual Private Cloud) with a subnet and a security group using the AWS CLI.

- [ ] Task 1: Create a new VPC
  - Run the following command to create a new VPC:

    ```bash
    aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query Vpc.VpcId --output text
    ```

  - Take note of the VPC ID returned by the command.

- [ ] Task 2: Create a subnet within the VPC
  - Run the following command to create a subnet within the VPC:

    ```bash
    aws ec2 create-subnet --vpc-id <vpc-id> --cidr-block 10.0.1.0/24 --query Subnet.SubnetId --output text
    ```

  - Replace `<vpc-id>` with the VPC ID obtained in Task 1.
  - Take note of the Subnet ID returned by the command.

- [ ] Task 3: Create a security group
  - Run the following command to create a security group:

    ```bash
    aws ec2 create-security-group --group-name my-sg --description "My security group" --vpc-id <vpc-id>
    ```

  - Replace `<vpc-id>` with the VPC ID obtained in Task 1.
  - Take note of the Security Group ID returned by the command.

- [ ] Task 4: Configure inbound rules for the security group
  - Run the following commands to add inbound rules to the security group:

    ```bash
    aws ec2 authorize-security-group-ingress --group-id <security-group-id> --protocol tcp --port 22 --cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress --group-id <security-group-id> --protocol tcp --port 80 --cidr 0.0.0.0/0
    ```

  - Replace `<security-group-id>` with the Security Group ID obtained in Task 3.
  - The first command allows SSH access (port 22) from anywhere.
  - The second command allows HTTP access (port 80) from anywhere.

> [!NOTE]
> In a production environment, it is recommended to restrict the inbound rules to specific IP ranges or security groups instead of allowing access from anywhere (0.0.0.0/0).

## EXERCISE 4: Create EC2 Instance

In this exercise, you will create an EC2 instance within the VPC created in Exercise 3 using the AWS CLI.

- [ ] Task 1: Generate an SSH key pair
  - Run the following command to generate an SSH key pair:

    ```bash
    aws ec2 create-key-pair --key-name mykey --query KeyMaterial --output text > mykey.pem
    ```

  - This command generates a new key pair named "mykey" and saves the private key to a file named "mykey.pem".
  - Change the permissions of the private key file:

    ```bash
    chmod 400 mykey.pem
    ```

- [ ] Task 2: Create an EC2 instance
  - Run the following command to create an EC2 instance:

    ```bash
    aws ec2 run-instances --image-id ami-0c94855ba95c71c99 --instance-type t2.micro --key-name mykey --subnet-id <subnet-id> --security-group-ids <security-group-id> --associate-public-ip-address
    ```

  - Replace `<subnet-id>` with the Subnet ID obtained in Exercise 3, Task 2.
  - Replace `<security-group-id>` with the Security Group ID obtained in Exercise3, Task 3.
  - Take note of the Instance ID returned by the command.

> [!TIP]
> The `ami-0c94855ba95c71c99` used in the command represents the Amazon Machine Image (AMI) ID for Amazon Linux 2 in the US East (N. Virginia) region. If you are using a different region, you may need to find the appropriate AMI ID for that region.

## EXERCISE 5: SSH into the server and install Docker on it

In this exercise, you will SSH into the EC2 instance created in Exercise 4 and install Docker on it to prepare the server for running the dockerized application.

- [ ] Task 1: SSH into the EC2 instance
  - Run the following command to retrieve the public IP address of the EC2 instance:

    ```bash
    aws ec2 describe-instances --instance-ids <instance-id> --query 'Reservations[].Instances[].PublicIpAddress' --output text
    ```

  - Replace `<instance-id>` with the Instance ID obtained in Exercise 4.
  - Use the public IP address to SSH into the EC2 instance:

    ```bash
    ssh -i mykey.pem ec2-user@<public-ip>
    ```

  - Replace `<public-ip>` with the public IP address obtained in the previous step.

- [ ] Task 2: Install Docker on the EC2 instance
  - Once connected to the EC2 instance via SSH, run the following commands to install Docker:

    ```bash
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    ```

  - These commands update the package manager, install Docker, start the Docker service, and add the `ec2-user` to the `docker` group.

- [ ] Task 3: Verify Docker installation
  - Log out and log back in to the EC2 instance for the group membership changes to take effect.
  - Run the following command to verify that Docker is installed and running correctly:

    ```bash
    docker --version
    ```

  - The command should display the Docker version installed.

> [!NOTE]
> After completing this exercise, the EC2 instance is now ready to run the dockerized application from Exercise 1.
> Remember to stop or terminate the EC2 instance when you are done to avoid incurring unnecessary charges.
