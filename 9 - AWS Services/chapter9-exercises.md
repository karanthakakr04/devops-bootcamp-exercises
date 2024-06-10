# TASK BREAKDOWN

## Prerequisites

Before proceeding with the exercises, ensure that you have the following prerequisites in place:

1. **Multi-Branch Pipeline**: Create a new multi-branch pipeline in Jenkins and configure the branch sources. Add the Git repository URL and specify the branch discovery strategy. Apply the necessary behaviors, such as filtering branches by name using a regular expression. Configure the build settings to use the Jenkinsfile located in the repository.

2. **Environment Variables**: Set up the following environment variables in Jenkins to store sensitive information securely:
   - **Deployment Server**: Create a secret text credential to store the deployment server details in the format `<username>@<deployment-server-public-ip>` (e.g., `ec2-user@<public-ip>`).
   - **Deployment Path**: Create another secret text credential to store the deployment path on the server (e.g., `/home/ec2-user`).

   These environment variables will be used in the pipeline to protect sensitive information and provide flexibility in the deployment process.

By completing these prerequisites, you will have a multi-branch pipeline set up in Jenkins, and the necessary environment variables will be securely stored for use in the subsequent exercises.

### Create a Multi-Branch Pipeline

- [x] **Task 1: Create a new multi-branch pipeline in Jenkins**
  - In the Jenkins web interface, click on "New Item".
  - Enter a name for your multi-branch pipeline (e.g., "my-app-pipeline") and select "Multibranch Pipeline" as the item type.
  - Click "OK" to create the multi-branch pipeline.

- [x] **Task 2: Configure the Branch Sources**
  - In the multi-branch pipeline configuration page, scroll down to the "Branch Sources" section.
  - Click "Add source" and select "Git".
  - In the "Project Repository" field, enter the repository URL for your project (e.g., `https://github.com/your-username/your-repo.git`).
  - In the "Credentials" field, select the appropriate credentials to access your repository (if required).
  - In the "Behaviors" section, you will see the "Discover branches" option. Leave it as the default setting.
  - Click the "Add" button under "Behaviors" and select "Filter by name (with regular expression)".
  - In the "Regular expression" field, enter the appropriate regular expression to filter branches based on your requirements (e.g., `.*` to include all branches).

- [x] **Task 3: Configure the Build Configuration**
  - Scroll down to the "Build Configuration" section.
  - The "Mode" dropdown should be set to "by Jenkinsfile" by default, which is the only available option.
  - In the "Script Path" field, enter the path to your Jenkinsfile within the repository (e.g., `Jenkinsfile`).

- [x] **Task 4: Configure Scan Multibranch Pipeline Triggers**
  - In the "Scan Multibranch Pipeline Triggers" section, check the "Periodically if not otherwise run" option.
  - Set the desired scanning interval (e.g., 1 hour) to automatically detect and build new branches.

- [x] **Task 5: Save the multi-branch pipeline configuration**
  - Optionally, you can configure additional build settings, such as "Orphaned Item Strategy" or "Health metrics" or "Pipeline Libraries" based on your requirements.
  - Click "Save" to apply the configuration changes for the entire multi-branch pipeline.

### Configuring Environment Variables in Jenkins Pipeline

To use the environment variables (`DEPLOYMENT_USER`, `DEPLOYMENT_SEVER`, `DEPLOYMENT_PATH`) defined in the `environment` block of the Jenkinsfile, you need to create corresponding credential entries in Jenkins. Follow these steps to configure the environment variables:

- [x] Task 1: Open the Jenkins web interface and navigate to the credentials page
  - In the Jenkins dashboard, click on "Manage Jenkins" in the left sidebar.
  - Click on "Manage Credentials" under the "Security" section.
  - Click on "Jenkins" under "Stores scoped to Jenkins".
  - Click on "Global credentials (unrestricted)".
  - Click on the "Add Credentials" link on the right side.

- [x] Task 2: Create credential entries for each environment variable
  - For `DEPLOYMENT_USER`:
    - Kind: Select "Secret text".
    - Scope: Select "Global".
    - Secret: Enter the value for your Docker Hub repository name.
    - ID: Enter "DEPLOYMENT_USER".
    - Description: Provide a meaningful description for the credential, such as "This credential stores the username for accessing and performing deployment operations on the target server.".
    - Click on the "Create" button to save the credential.

  - For `DEPLOYMENT_SEVER`:
    - Kind: Select "Secret text".
    - Scope: Select "Global".
    - Secret: Enter the value for your Docker Hub username.
    - ID: Enter "DEPLOYMENT_SEVER".
    - Description: Provide a meaningful description for the credential, such as "This credential stores the IP address of the target server where the application will be deployed.".
    - Click on the "Create" button to save the credential.

  - For `DEPLOYMENT_PATH`:
    - Kind: Select "Secret text".
    - Scope: Select "Global".
    - Secret: Enter the URL of your GitHub repository.
    - ID: Enter "DEPLOYMENT_PATH".
    - Description: Provide a meaningful description for the credential, such as "This credential stores directory path on the target server where application files will be deployed.".
    - Click on the "Create" button to save the credential.

- [x] Task 3: Use the configured credentials in the Jenkinsfile
  - In the Jenkinsfile, you can access the values of the environment variables using the `credentials()` function with the respective credential IDs. For example:

    ```groovy
    environment {
      DEPLOYMENT_USER = credentials('DEPLOYMENT_USER')
      DEPLOYMENT_SEVER = credentials('DEPLOYMENT_SEVER')
      DEPLOYMENT_PATH = credentials('DEPLOYMENT_PATH')
    }
    ```

  - Jenkins will retrieve the corresponding values from the configured credentials and assign them to the environment variables during the pipeline execution.

## Exercise 1

> [!CAUTION]
> **The IAM user created in this exercise should only have the necessary permissions to perform their required tasks. Avoid using overly permissive policies such as `AdministratorAccess`.**

- [x] **Task 1: Login to AWS Management Console**
  - Open your web browser.
  - Navigate to the [AWS Management Console](https://aws.amazon.com/console/).
  - Click on the _Sign in to the Console_ button.
  - Enter your admin username and password.
  - Click on _Sign In_.

- [x] **Task 2: Navigate to IAM Service**
  - On the AWS Management Console home page, you can either:
    - Find _IAM_ under the _Security, Identity, & Compliance_ section and click on it, or
    - Use the search bar at the top to search for _IAM_ and click on the _IAM_ result.
  - In the IAM dashboard, click on _Users_ in the left sidebar.
  - Click on the _Create user_ button.

- [x] **Task 3: Enter user details**
  - On the _Specify user details_ page:
    - You will be presented with two options:
      - _AWS IAM Identity Center_
      - _IAM User_
    - Select _IAM User_ to create a new IAM user.
    - _User name:_ Enter a desired username for the IAM user (e.g., "dev-user"). Replace "dev-user" with your preferred username.
    - Check the _Provide user access to the AWS Management Console_ option.
    - Under _Are you providing console access to a person?_, select _I want to create an IAM user_.
    - _Console password:_ Select "Autogenerated password".
    - _Password reset required:_ Keep the _User must create a new password at next sign-in_ option selected.
    - Click on _Next_ button.

> [!NOTE]
> **AWS recommends using AWS IAM Identity Center for centralized access management and short-term credentials. However, for this exercise, we will use _IAM User_ as it is within the scope of our demonstration. For more information, refer to the [AWS IAM Identity Center User Guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction_identity-management.html#intro-identity-users). You can also watch this [YouTube tutorial](https://www.youtube.com/watch?v=_KhrGFV_Npw) for a detailed setup of AWS IAM Identity Center.**

- [x] **Task 4: Assign permissions to the IAM user**
  - On the _Set permissions_ page, you will see three options to set permissions:
    - _Add user to group_
    - _Copy permissions from existing user_
    - _Attach policies directly_
  - AWS recommends adding the user to a group and then attaching policies to the group. Select _Add user to group_.
  - Click on _Create group_.
    - _Group name:_ Enter `devops`.
    - In the _Filter policies_ box, type relevant policies based on the permissions the user needs. Avoid using overly permissive policies such as `AdministratorAccess`.
    - Consider policies like:
      - _AmazonEC2FullAccess_ - For managing EC2 instances.
      - _AmazonVPCFullAccess_ - For managing VPCs, subnets, and security groups.
      - _CloudWatchFullAccess_ - For logging and monitoring.
      - _AmazonS3ReadOnlyAccess_ - For read-only access to S3 buckets (if needed for storing/retrieving objects).
    - Click the _Create group_ button.
  - Ensure the new user is added to the `devops` group.
  - Click on _Next_ button.

- [x] **Task 5: Finalize and create the IAM user**
  - On the _Review and create_ page:
    - Review the user details and permissions.
    - Optionally, add tags to the IAM user for better organization and management. Here are some suggested tags:
      - Project: DevOpsBootcamp
      - Role: NodeJSAppDeployment
      - Environment: Development
      - Department: Engineering
      - CreatedBy: Admin
      - CreationDate: 2024-05-19
    - If everything looks correct, click on the _Create user_ button.

- [x] **Task 6: Save IAM user credentials**
  - You will be presented with the _Step 4: Retrieve password_ page.
  - Click on the _Download .csv_ button to download the credentials file, which contains the access key ID, secret access key, and password for the IAM user.
  - Store the downloaded file securely, as it contains sensitive information.
  - Click on the _Return to users list_ button.

> [!WARNING]
> **Make sure to store the downloaded .csv file containing the IAM user credentials securely. Do not share or expose the credentials publicly, as they provide access to your AWS resources.**

## Exercise 2

- [x] **Task 1: Install AWS CLI**
  - Go to the [AWS CLI installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), choose the appropriate installation method for your operating system, and follow the provided installation instructions.
  - For more detailed information, source code, and to report issues, visit the [AWS CLI GitHub repository](https://github.com/aws/aws-cli).
  - Verify the installation by running:

    ```bash
    aws --version
    ```

- [x] **Task 2: Configure AWS CLI with IAM user credentials**
  - Run the following command to configure AWS CLI:

    ```bash
    aws configure
    ```

  - Provide the following information when prompted:
    - AWS Access Key ID: Enter the access key ID obtained from Exercise 1.
    - AWS Secret Access Key: Enter the secret access key obtained from Exercise 1.
    - Default region name: Enter the desired AWS region (e.g., us-east-1).
    - Default output format: Press Enter to use the default format (json).

- [x] **Task 3: Verify AWS CLI configuration**
  - Run the following command to verify the IAM identity and account information:

    ```bash
    aws sts get-caller-identity
    ```

  - This command returns details about the IAM identity used to make the request, including the UserId, Account, and ARN.

  - Run the following command to list the current configuration settings, including the default region and output format:

    ```bash
    aws configure list
    ```

  - This command displays the AWS CLI configuration values, including the profile being used, access keys, region, and output format.

## Exercise 3

- [x] **Task 1: Create a new VPC**
  - Run the following command to create a new VPC:

    ```bash
    aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=my-vpc}]' --query Vpc.VpcId --output text
    ```

  - Take note of the VPC ID returned by the command.

- [x] **Task 2: Create a subnet within the VPC**
  - Run the following command to create a subnet within the VPC:

    ```bash
    aws ec2 create-subnet --vpc-id <VPC_ID> --cidr-block 10.0.1.0/24 --availability-zone <AVAILABILITY_ZONE> --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=my-subnet}]' --query Subnet.SubnetId --output text
    ```

  - Replace `<vpc-id>` with the VPC ID obtained in Task 1.
  - Take note of the Subnet ID returned by the command.

- [x] **Task 3: Create a security group**
  - Run the following command to create a security group:

    ```bash
    aws ec2 create-security-group --group-name my-sg --description "My security group" --vpc-id <VPC_ID> --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=my-sg}]' --query GroupId --output text
    ```

  - Replace `<vpc-id>` with the VPC ID obtained in Task 1.
  - Take note of the Security Group ID returned by the command.

- [x] **Task 4: Configure Security Group Rules**
  - Run the following command to allow inbound SSH (port 22) access from a specific IP address or range:
  
    ```bash
    aws ec2 authorize-security-group-ingress --group-id <SECURITY_GROUP_ID> --protocol tcp --port 22 --cidr <YOUR_IP_ADDRESS>/32
    ```

  - Replace `<SECURITY_GROUP_ID>` with the Security Group ID from Task 3.
  - Replace `<YOUR_IP_ADDRESS>` with your specific IP address or the IP range you want to allow SSH access from. For example, if your IP address is `203.0.113.0`, you would use `203.0.113.0/32`. If you want to allow access from a range, you can use a subnet mask like `203.0.113.0/24`.
  - Run the following command to allow inbound HTTP (port 80) access:

    ```bash
    aws ec2 authorize-security-group-ingress --group-id <SECURITY_GROUP_ID> --protocol tcp --port 80 --cidr 0.0.0.0/0
    ```

## Exercise 4

- [x] **Task 1: Create Key Pair**
  - Run the following command to create a new key pair:

    ```bash
    aws ec2 create-key-pair --key-name my-key --query 'KeyMaterial' --output text > my-key.pem
    ```

  - This command creates a new key pair named "my-key" and saves the private key to a file named "my-key.pem" in the current directory.
  - For Linux and MacOS, secure the key pair file by running the following command:

    ```bash
    chmod 400 my-key.pem
    ```

  - Validate the key pair creation by checking the file existence and permissions:

    ```bash
    ls -l my-key.pem
    ```

- [x] **Task 2: Get the Latest Amazon Linux 2 AMI ID**
  - Run the following command to retrieve the latest Amazon Linux 2 AMI ID:

    ```bash
    aws ssm get-parameter --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --region <REGION> --query 'Parameter.Value' --output text
    ```

  - Replace `<REGION>` with your desired AWS region (e.g., us-east-1).
  - Save the AMI ID returned by the command.

- [x] **Task 3: Validate the AMI ID**
  - Run the following command to get detailed information about the AMI:

    ```bash
    aws ec2 describe-images --image-ids <AMI_ID> --query 'Images[0].{ID:ImageId,Name:Name,State:State,Description:Description,CreationDate:CreationDate,OwnerId:OwnerId,Public:Public,RootDeviceType:RootDeviceType,VirtualizationType:VirtualizationType,Architecture:Architecture,Platform:Platform,Tags:Tags,Hypervisor:Hypervisor}' --output table
    ```

  - Replace `<AMI_ID>` with the AMI ID from Task 2.
  - Verify the details of the AMI to ensure it meets your requirements.

- [x] **Task 4: Create EC2 Instance**
  - Run the following command to create an EC2 instance:

    ```bash
    aws ec2 run-instances --image-id <AMI_ID> --instance-type t2.micro --key-name my-key --security-group-ids <SECURITY_GROUP_ID> --subnet-id <SUBNET_ID> --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyDeploymentServer},{Key=Environment,Value=Development},{Key=Owner,Value=JohnDoe},{Key=Project,Value=AlphaProject},{Key=Application,Value=AlphaDeployApp},{Key=CostCenter,Value=12345},{Key=Department,Value=Operations},{Key=Purpose,Value=CI/CDPipeline},{Key=CreatedBy,Value=AWSCLI}]' --block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":8,"VolumeType":"gp3","DeleteOnTermination":true,"Encrypted":true}}]' --metadata-options '{"HttpTokens":"required","HttpPutResponseHopLimit":1,"HttpEndpoint":"enabled"}' --query 'Instances[0].InstanceId' --output text
    ```

  - Replace `<AMI_ID>` with the AMI ID from Task 2.
  - Replace `<SECURITY_GROUP_ID>` with the Security Group ID from Exercise 3, Task 3.
  - Replace `<SUBNET_ID>` with the Subnet ID from Exercise 3, Task 2.
  - The command uses the `t2.micro` instance type, which is eligible for the free tier.
  - The `--block-device-mappings` option specifies the EBS volume configuration, including the volume size (8 GB), volume type (gp3), and encryption.
  - The `--metadata-options` option configures the instance metadata service to require token-based access and limit the number of hops.
  - Save the Instance ID returned by the command.
  - For more information about Amazon Linux 2023, refer to the [Amazon Linux 2023 Documentation](https://docs.aws.amazon.com/linux/al2023/ug/ec2.html).

- [x] **Task 5: Verify EC2 Instance Creation**
  - Run the following command to describe the EC2 instance:

    ```bash
    aws ec2 describe-instances --instance-ids <INSTANCE_ID>
    ```

  - Replace `<INSTANCE_ID>` with the Instance ID from Task 3.
  - Review the output to ensure the instance details are correct, such as the VPC, subnet, security group, and key pair.

- [x] **Task 6: Retrieve Public IP Address**
  - Run the following command to retrieve the public IP address of the EC2 instance:

    ```bash
    aws ec2 describe-instances --instance-ids <INSTANCE_ID> --query 'Reservations[0].Instances[0].PublicIpAddress' --output text
    ```

  - Replace `<INSTANCE_ID>` with the Instance ID from Task 3.
  - Save the public IP address for connecting to the instance via SSH in Exercise 5.

## Exercise 5

> [!IMPORTANT]
> **The following task list assumes you are using an Amazon Linux 2023 AMI for your EC2 instance. If you are using a different operating system, such as Ubuntu or another Linux distribution, please be aware that the specific commands and steps may vary. In such cases, it is recommended to refer to the official documentation and guides specific to your operating system for installing Docker and Docker Compose.**

- [x] **Task 1: SSH into the EC2 instance**
  - Open a terminal or command prompt.
  - Navigate to the directory where you saved the key pair file (`my-key.pem`) in Exercise 4.
  - Run the following command to SSH into the EC2 instance:

    ```bash
    ssh -i /path/to/my-key.pem ec2-user@<PUBLIC_IP_ADDRESS>
    ```

  - Replace `/path/to/my-key.pem` with the actual path to your key pair file.
  - Replace `<PUBLIC_IP_ADDRESS>` with the public IP address of the EC2 instance obtained in Exercise 4, Task 5.
  - If prompted, type "yes" to add the instance to the known hosts list.

- [x] **Task 2: Update the installed packages and package cache on your instance**
  - Run the following command to update the installed packages and package cache:

    ```bash
    sudo yum update -y
    ```

- [x] **Task 3: Install Docker**
  - Run the following command to install the most recent Docker Community Edition package:

    ```bash
    sudo amazon-linux-extras install docker -y
    ```

  - This command installs Docker using the Amazon Linux Extras repository.
  - For more detailed instructions and alternative installation methods, refer to the [official AWS documentation on installing Docker](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-docker.html).

- [x] **Task 4: Start the Docker service**
  - Run the following command to start the Docker service:

    ```bash
    sudo service docker start
    ```

- [x] **Task 5: Add the `ec2-user` to the `docker` group**
  - Run the following command to add the `ec2-user` to the `docker` group:

    ```bash
    sudo usermod -aG docker ec2-user
    ```

  - This command grants the `ec2-user` permission to run Docker commands without using `sudo`.

- [x] **Task 6: Log out and log back in to pick up the new `docker` group permissions**
  - Log out of the SSH session by running:

    ```bash
    exit
    ```

  - SSH back into the EC2 instance using the same command from Task 1.
  - This ensures that the new SSH session has the appropriate `docker` group permissions.

- [x] **Task 7: Verify Docker installation and permissions**
  - Run the following command to verify that the `ec2-user` can run Docker commands without using `sudo`:

    ```bash
    docker ps
    ```

  - If Docker is installed correctly and the `ec2-user` has the necessary permissions, you should see an empty list of containers (since no containers are running yet).

- [x] **Task 8: Install Docker Compose**
  - Since Amazon Linux 2023 AMI does not come with Docker Compose pre-installed, we need to install it separately.
  - Run the following commands to download and install the latest version of Docker Compose:

    ```bash
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ```

  - Verify the installation by running:

    ```bash
    docker-compose version
    ```

  - You should see the version information for Docker Compose.

> [!TIP]
> For detailed installation guides and additional information, you can refer to the following resources:
>
> - [How To configure Docker & Docker-Compose in AWS EC2 [Amazon Linux 2023 AMI]](https://medium.com/@fredmanre/how-to-configure-docker-docker-compose-in-aws-ec2-amazon-linux-2023-ami-ab4d10b2bcdc)
> - [Docker & Docker Compose Installation Guide for Amazon Linux 2023](https://gist.github.com/npearce/6f3c7826c7499587f00957fee62f8ee9)

## Exercise 6

- [x] **Task 1: Use `docker init` to generate Docker configuration files**
  - Open a terminal and navigate to the `aws-exercises/app` directory.
  - Run the `docker init` command to automatically generate the following files:
    - `.dockerignore`
    - `Dockerfile`
    - `compose.yaml`
  - Provide the necessary information when prompted, such as the application platform, desired Node.js version, package manager, entry point, and port.

- [x] **Task 2: Review and customize the generated Docker configuration files**
  - Open the generated `Dockerfile` and review its contents.
  - Customize the `Dockerfile` if needed, based on your application's specific requirements.
  - Open the generated `compose.yaml` file and review its contents.
  - Customize the `compose.yaml` file if needed, such as adding additional services or volumes.
  - Open the generated `.dockerignore` file and review its contents.
  - Customize the `.dockerignore` file if needed, adding any additional files or directories to be excluded from the Docker build context.

- [x] **Task 3: Commit and push the changes**
  - Open a terminal and navigate to the root directory of your project.
  - Run the following commands to stage and commit the `.dockerignore` file:

    ```bash
    git add .dockerignore
    git commit -m "Add .dockerignore file"
    ```

  - Run the following commands to stage and commit the `Dockerfile`:

    ```bash
    git add Dockerfile
    git commit -m "Add Dockerfile for containerization"
    ```

  - Run the following commands to stage and commit the `compose.yaml` file:

    ```bash
    git add compose.yaml
    git commit -m "Add Docker Compose configuration"
    ```

  - Push the changes to your remote repository:

    ```bash
    git push origin main
    ```

![Screenshot of docker init command](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/c51d4747-4c24-40fa-ae2e-87c1b619061c)

## Exercise 7

### Understanding the `-o StrictHostKeyChecking=no` Flag

In the provided pipeline script, the `-o StrictHostKeyChecking=no` flag is used in the SSH command to disable strict host key checking. While this flag simplifies the SSH connection process by automatically adding the server's public key to the `known_hosts` file without verification, it poses a security risk.

When connecting to an SSH server for the first time, the server sends its public key to the client, which is then stored in the `~/.ssh/known_hosts` file. In subsequent connections, the client compares the server's public key with the one stored in the `known_hosts` file to verify the server's identity and prevent man-in-the-middle attacks.

By using `-o StrictHostKeyChecking=no`, the client automatically adds the server's public key to the `known_hosts` file without prompting or verifying it. If an attacker manages to intercept the connection and present a different public key, the client will trust it blindly, potentially compromising the security of the connection.

#### Alternative Methods for Secure SSH Connection

1. **Manual Verification**: Instead of using `-o StrictHostKeyChecking=no`, you can manually verify the server's public key by connecting to the server separately and comparing the displayed public key with the one provided by the server administrator or through a secure channel.

2. **SSH CA (Certificate Authority)**: Implement an SSH CA to manage and sign host keys. By using signed host keys, clients can verify the authenticity of the server's public key against the trusted CA, eliminating the need for manual verification or disabling strict host key checking.

3. **SSH Fingerprints**: Compare the SSH fingerprint of the server's public key with a pre-shared fingerprint. The fingerprint can be obtained securely from the server administrator or through a trusted source. If the fingerprints match, the client can trust the server's identity.

While these alternative methods provide more secure ways to establish SSH connections, they may require additional setup and coordination with the server administrator.

For the purpose of this exercise, we will proceed with using the `-o StrictHostKeyChecking=no` flag, but it is important to be aware of the security implications and consider implementing more secure methods in production environments.

- [ ] Task 1: Create a shell script for deployment commands
  - Create a new file named `server-commands.sh` in your project repository, in this case the `9 - AWS Services/aws-exercises` directory.
  - Open the `server-commands.sh` file and add the following content:

    ```bash
    #!/usr/bin/env bash

    export IMAGE=$1

    docker-compose -f compose.yaml up --detach

    echo 'success'
    ```

  - This shell script takes the image name as an argument, sets it as an environment variable, and runs the `docker-compose up` command with the provided `docker-compose.yaml` file to start the application container.

- [ ] Task 2: Create a `docker-compose.yaml` file
  - Create a new file named `docker-compose.yaml` in your project repository, in this case the `9 - AWS Services/aws-exercises` directory.
  - Open the `compose.yaml` file and add the following content:

    ```yaml
    version: '3.8'

    services:
      app:
        image: ${IMAGE}
        ports:
          - "3000:3000"
        environment:
          NODE_ENV: development
    ```

  - The `docker-compose.yaml` file defines a service named `app` that uses the Docker image specified by the `IMAGE` environment variable. It maps port 3000 on the host to port 3000 in the container.

- [ ] Task 3: Update the Jenkinsfile
  - Open the `Jenkinsfile` in your project repository, in this case the `9 - AWS Services/aws-exercises` directory.
  - Add a new stage named "Deploy App" after the existing stages:

    ```groovy
    stage('Deploy App') {
      steps {
        script {
          echo 'Deploying the Docker image to the deployment server...'
          def deploymentImage = "${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}:${IMAGE_VERSION}"
          def deploymentScript = "bash ./server-commands.sh ${deploymentImage}"
          def deploymentTarget = "${DEPLOYMENT_USER}@${DEPLOYMENT_SEVER}"
          dir('9 - AWS Services/aws-exercises'){
            sshagent(['deployment-server-ssh']) {
              sh "scp -o StrictHostKeyChecking=no server-commands.sh ${deploymentTarget}:${DEPLOYMENT_PATH}"
              sh "scp -o StrictHostKeyChecking=no compose.yaml ${deploymentTarget}:${DEPLOYMENT_PATH}"
              sh "ssh -o StrictHostKeyChecking=no ${deploymentTarget} 'chmod +x ${DEPLOYMENT_PATH}/server-commands.sh'"
              sh "ssh -o StrictHostKeyChecking=no ${deploymentTarget} ${deploymentScript}"
            }
          }
        }
      }
    }
    ```

  - Replace `<deployment-server-public-ip>` with the public IP address of your deployment server.
  - The `sshagent` block is used to authenticate with the deployment server using the SSH key stored in the Jenkins credentials.
  - The `scp` commands copy the `server-commands.sh` and `compose.yaml` files to the deployment server.
  - The `ssh` command connects to the deployment server and executes the `server-commands.sh` script with the `deploymentImage` as an argument.

- [ ] Task 4: Configure Jenkins credentials for SSH access
  - In the Jenkins web interface, navigate to "Manage Jenkins" > "Manage Credentials".
  - Click on "Jenkins" in the "Stores scoped to Jenkins" section.
  - Click on "Global credentials" and then "Add Credentials".
  - Select "SSH Username with private key" as the kind.
  - Provide a meaningful ID (e.g., "my-ssh-key") and description for the credentials.
  - Enter the username for accessing the deployment server (e.g., "ec2-user").
  - Select "Enter directly" for the private key and paste the contents of the SSH private key.
  - Click "OK" to save the credentials.

- [ ] Task 5: Run the Jenkins pipeline
  - Push the updated `Jenkinsfile`, `server-commands.sh`, and `compose.yaml` files to your project repository.
  - In the Jenkins web interface, navigate to your pipeline and click on "Build Now" to trigger a new build.
  - Monitor the pipeline execution and verify that the deployment stage runs successfully.

![Pipeline Success Output Screenshot](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/606aa34b-0fea-48d2-8f89-08c0ed44612d)

## Exercise 8

- [ ] Task 1: Retrieve the security group ID
  - Open the AWS Management Console and navigate to the EC2 dashboard.
  - In the left sidebar, click on "Instances" to view the list of EC2 instances.
  - Select the EC2 instance where your application is deployed.
  - In the "Description" tab, locate the "Security groups" section and note down the security group ID associated with the instance.

- [ ] Task 2: Modify the security group using AWS CLI
  - Open a terminal or command prompt.
  - Run the following command to add an inbound rule to the security group, allowing access to the application port (e.g., port 80) from any IP address:

    ```bash
    aws ec2 authorize-security-group-ingress --group-id <security-group-id> --protocol tcp --port 80 --cidr 0.0.0.0/0
    ```

  - Replace `<security-group-id>` with the ID of the security group associated with your EC2 instance.
  - This command allows incoming traffic on port 80 from any IP address.

- [ ] Task 3: Verify the updated security group
  - Run the following command to describe the security group and verify the new inbound rule:

    ```bash
    aws ec2 describe-security-groups --group-ids <security-group-id>
    ```

  - Replace `<security-group-id>` with the ID of the security group.
  - Look for the new inbound rule in the output and ensure it allows traffic on port 80 from the specified IP range.

- [ ] Task 4: Access the application from a web browser
  - Open a web browser.
  - Enter the public IPv4 address (e.g., <http://54.237.83.125:80>) or public IPv4 DNS name (e.g., <http://ec2-54-237-83-125.compute-1.amazonaws.com:80>) of your EC2 instance in the address bar.
  - Verify that you can access the deployed application successfully.

### Best Practices

1. **Principle of Least Privilege**: When configuring security group rules, follow the principle of least privilege. Only allow the minimum required access and ports necessary for your application to function properly. Avoid using overly permissive rules like allowing all traffic from any IP address.

2. **Use Specific IP Ranges**: Instead of allowing access from any IP address (0.0.0.0/0), consider restricting access to specific IP ranges or addresses that require access to your application. This can be achieved by specifying the appropriate CIDR block in the `--cidr` parameter of the `authorize-security-group-ingress` command.

3. **Regularly Review and Audit**: Regularly review and audit your security group configurations to ensure that only the necessary inbound and outbound rules are in place. Remove any unused or unnecessary rules to maintain a secure environment.

4. **Document Security Group Configuration**: Maintain documentation of your security group configurations, including the purpose and justification for each inbound and outbound rule. This helps in understanding the security posture of your application and makes it easier to manage and update the configurations in the future.

5. **Use Naming Conventions**: Follow a consistent naming convention for your security groups to easily identify their purpose and associated resources. This helps in managing and organizing security groups effectively.

6. **Monitor and Alert**: Implement monitoring and alerting mechanisms to detect and notify you of any unauthorized or suspicious changes to your security group configurations. This enables you to take prompt action in case of any security breaches or misconfigurations.

## Exercise 9

### Adding Branch-Based Logic to Jenkinsfile

- [x] **Task 1: Modify the Jenkinsfile to add branch-based logic**
  - Open the `Jenkinsfile` in your project repository.
  - Add the `when` directive with the `branch` condition to the relevant stages:
    - "Increment Version" stage: Execute only when the branch is `main` or `master`.
    - "Build Image" stage: Execute only when the branch is `main` or `master`.
    - "Push Image" stage: Execute only when the branch is `main` or `master`.
    - "Commit Version" stage: Execute only when the branch is `main` or `master`.
    - "Deploy App" stage: Execute only when the branch is `main` or `master`.
    - "Run Tests" stage: Execute for all branches.
  - Update the Jenkinsfile with the following changes:

    ```groovy
    stage('Increment Version') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
        }
      }
      steps {
        // Increment version logic
      }
    }

    stage('Run Tests') {
      steps {
        // Run tests logic
      }
    }

    stage('Build Image') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
        }
      }
      steps {
        // Build image logic
      }
    }

    stage('Push Image') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
        }
      }
      steps {
        // Push image logic
      }
    }

    stage('Commit Version') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
        }
      }
      steps {
        // Commit version logic
      }
    }

    stage('Deploy App') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
        }
      }
      steps {
        // Deploy app logic
      }
    }
    ```

  - Commit and push the updated Jenkinsfile to your repository.

### Configuring Webhook in GitHub for Multibranch Pipeline

- [ ] **Task 1: Install the "Multibranch Scan Webhook Trigger" plugin in Jenkins**
  - Go to your Jenkins dashboard and click on "Manage Jenkins" > "Manage Plugins".
  - In the "Available" tab, search for "Multibranch Scan Webhook Trigger" plugin.
  - Select the checkbox next to the plugin and click "Install without restart".
  - Wait for the plugin installation to complete.

- [ ] **Task 2: Configure the multibranch pipeline in Jenkins**
  - Go to your Jenkins dashboard and click on "New Item".
  - Enter a name for your multibranch pipeline and select "Multibranch Pipeline" as the item type.
  - Click "OK" to create the multibranch pipeline.
  - In the configuration page, under "Branch Sources", click "Add source" and select "GitHub".
  - Provide the repository URL and necessary credentials.
  - Under "Scan Multibranch Pipeline Triggers", select "Periodically if not otherwise run" and specify the desired scan interval.
  - Click "Add" > "Scan by webhook" and provide a unique trigger token (e.g., "github-webhook-token").
  - Save the multibranch pipeline configuration.

- [ ] **Task 3: Create a webhook in your GitHub repository**
  - Go to your GitHub repository's settings page.
  - Click on "Webhooks" in the left sidebar.
  - Click on the "Add webhook" button.
  - In the "Payload URL" field, enter the Jenkins webhook URL in the format: `http://<jenkins-server-url>/multibranch-webhook-trigger/invoke?token=<trigger-token>`.
    - Replace `<jenkins-server-url>` with your Jenkins server URL.
    - Replace `<trigger-token>` with the trigger token you specified in the multibranch pipeline configuration.
  - Select the "Content type" as `application/json`.
  - Under "Which events would you like to trigger this webhook?", select "Just the push event" or choose the desired events.
  - Ensure that the "Active" checkbox is selected.
  - Click on the "Add webhook" button to save the webhook configuration.

- [ ] **Task 4: Test the webhook integration**
  - Make a change to your GitHub repository, such as pushing a commit or creating a pull request.
  - Check the Jenkins multibranch pipeline to verify that the webhook triggered the pipeline execution.
  - Ensure that the appropriate stages are executed based on the branch and the defined branch-based logic in the Jenkinsfile.

By following these updated tasks, you will have successfully added branch-based logic to your Jenkinsfile and configured the webhook integration between GitHub and your Jenkins multibranch pipeline using the "Multibranch Scan Webhook Trigger" plugin. This setup will enable automatic triggering of the pipeline based on specific events in your GitHub repository, ensuring that the appropriate stages are executed for the `main` or `master` branch while running tests for all branches.
