# TASK BREAK DOWN

## Exercise 1

### Method 1: Set up Minikube locally

- [ ] Task 1: Install Minikube
  - **Check prerequisites:**
    - 2 CPUs or more
    - 2GB of free memory
    - 20GB of free disk space
    - Internet connection
    - Container or virtual machine manager (Docker, VirtualBox, etc.)
  
  - **Install Minikube using Windows Package Manager:**
    - If Windows Package Manager is installed, run:

      ```bash
      winget install Kubernetes.minikube
      ```

    - **Alternative installation methods:**
      - Using Chocolatey:

        ```bash
        choco install minikube
        ```

  - **Direct .exe download from the [official releases page](https://github.com/kubernetes/minikube/releases/latest/download/minikube-installer.exe)**

- [ ] Task 2: Start Minikube cluster
  - Open a terminal with administrator access
  - Run the following command:

    ```bash
    minikube start
    ```

  - If the start fails, refer to the [drivers page](https://minikube.sigs.k8s.io/docs/drivers/) for compatibility issues

- [ ] Task 3: Verify cluster installation
  - **If kubectl is already installed:**

    ```bash
    kubectl get po -A
    ```
  
  - **Using Minikube's built-in kubectl:**

    ```bash
    minikube kubectl -- get po -A
    ```
  
  - **Set up kubectl alias (optional):**

    ```bash
    alias kubectl="minikube kubectl --"
    ```

- [ ] Task 4: Access Kubernetes Dashboard (optional)

  ```bash
  minikube dashboard
  ```

### Method 2: Set up LKE Cluster

> [!IMPORTANT]
> For LKE clusters, ensure you have properly configured firewall rules to allow access to the Kubernetes API endpoint from your local machine. The default port for the Kubernetes API is 6443.

- [ ] Task 1: Access Linode Cloud Manager
  - Navigate to [Cloud Manager](https://cloud.linode.com)
  - Log in to your Linode account
  - Select "Kubernetes" from the left menu

- [ ] Task 2: Create Kubernetes cluster
  - Click "Create Cluster"
  - Configure basic cluster settings:
    - **Cluster Label:** Enter a unique name for your cluster
    - **Region:** Select the data center location
    - **Kubernetes Version:** Choose the desired version
  - Configure worker node pools:
    - Select plan type (Shared CPU, Dedicated CPU, High Memory, or Premium CPU)
    - Configure number of nodes
    - Add the node pool to your cluster
  - Review cluster configuration and monthly cost in the Cluster Summary
  - Click "Create Cluster" to deploy

- [ ] Task 3: Configure cluster access
  - **Download kubeconfig:**
    - From Kubernetes listing page: Click cluster's more options ellipsis → Download kubeconfig
    - Or from cluster details page: Click Download under kubeconfig section
  
  - **Set up kubeconfig:**

    ```bash
    # Set KUBECONFIG environment variable
    export KUBECONFIG=~/Downloads/kubeconfig.yaml
    
    # Make the config file secure
    chmod go-r ~/Downloads/kubeconfig.yaml
    ```

- [ ] Task 4: Verify cluster access

  ```bash
  # View cluster nodes
  kubectl get nodes
  
  # View all pods across namespaces
  kubectl get pods -A
  ```

> [!NOTE]
> The working directory path and kubeconfig file location may vary based on your system configuration. Adjust the paths accordingly.
