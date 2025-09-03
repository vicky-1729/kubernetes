# EKS Cluster Upgrade Strategies

This document outlines different strategies for upgrading an Amazon EKS cluster with minimal to zero downtime.

## Table of Contents

- [Understanding the Problem](#understanding-the-problem)
- [Strategy 1: Minimum Downtime Approach](#strategy-1-minimum-downtime-approach)
- [Strategy 2: Blue-Green Deployment for EKS](#strategy-2-blue-green-deployment-for-eks)
- [Strategy 3: Rolling Update](#strategy-3-rolling-update)
- [Our Current Approach](#our-current-approach)
- [Load Balancer Strategy for Zero Downtime](#load-balancer-strategy-for-zero-downtime)
- [Interview Scenario: Real-world EKS Upgrade](#interview-scenario-real-world-eks-upgrade)

## Understanding the Problem

Upgrading a Kubernetes cluster presents several challenges:
- Applications may experience downtime during upgrades
- Compatibility issues might arise between applications and the new Kubernetes version
- Teams need coordination to ensure smooth transitions

## Strategy 1: Minimum Downtime Approach

This approach involves a scheduled downtime window but minimizes actual downtime through careful preparation.

### Step-by-Step Process

1. **Preparation and Announcement**:
   - Announce downtime window (typically 3 hours) to all stakeholders
   - Configure firewalls to temporarily prevent other teams from connecting to the cluster
   - Ensure no application changes occur during the upgrade process

2. **Create New Node Group**:
   - Ensure EKS control plane and existing Node Group are fully functional
   - Create a new Node Group (blue/green approach) with identical capacity
   - Apply taints to the new nodes to prevent immediate scheduling of workloads

   ```terraform
   green = {
     ami_type       = "AL2023_x86_64_STANDARD"
     instance_types = ["m5.xlarge"]
     min_size     = 2
     max_size     = 10
     desired_size = 2
     
     taints = {
       upgrade = {
         key = "upgrade"
         value = "true"
         effect = "NO_SCHEDULE"
       }
     }
   }
   ```

3. **Control Plane Upgrade**:
   - Upgrade the EKS control plane to the target version (e.g., 1.33)
   - Wait for the control plane upgrade to complete and verify functionality

4. **Node Group Upgrade**:
   - Ensure the new Node Group is running the same Kubernetes version as the control plane (1.33)
   - At this point, the old Node Group is still running the previous version (e.g., 1.32)

5. **Workload Migration**:
   - Cordon old nodes to prevent new pods from being scheduled on them
   - Remove taints from the new Node Group to allow workload scheduling
   - Systematically drain nodes from the old Node Group, forcing workloads to reschedule on the new nodes

6. **Cleanup and Verification**:
   - Delete the old Node Group once all workloads have successfully migrated
   - Verify the control plane is running the new version (1.33)

7. **Restore Access**:
   - Restore firewall rules to allow normal access to the cluster
   - Announce completion of the upgrade to all teams
   - Request application teams to verify their applications are functioning correctly

### Benefits of This Approach
- Controlled environment during the upgrade
- Clear communication about downtime window
- Systematic migration of workloads

## Strategy 2: Blue-Green Deployment for EKS

This is a zero-downtime deployment strategy where we create an identical environment, test it thoroughly, and then switch traffic.

### Step-by-Step Process

1. **Create Parallel Infrastructure**:
   - If "blue" environment is currently running, create an identical "green" environment (or vice versa)
   - New environment should have the same capacity but running the new Kubernetes version

2. **Testing Phase**:
   - Thoroughly test the new environment to ensure compatibility and functionality
   - Deploy test workloads to verify behavior

3. **Traffic Switching**:
   - Once testing confirms the new environment is ready, begin switching workloads
   - This can be done gradually or all at once depending on risk tolerance

4. **Cleanup**:
   - After successful migration and verification, remove the old environment
   - Keep deployment scripts and configurations for future upgrades

### Benefits of Blue-Green
- Zero downtime for end users
- Complete isolation between old and new environments
- Easy rollback option if issues are detected

## Strategy 3: Rolling Update

This strategy updates the cluster incrementally, replacing old nodes with new ones one at a time.

### Step-by-Step Process

For example, with 4 pods:

1. **Create New Pod**:
   - Create a 5th pod with the new version
   - At this point: 4 old pods, 1 new pod

2. **Remove Old Pod**:
   - Delete one old pod
   - At this point: 3 old pods, 1 new pod

3. **Continue Incrementally**:
   - Create a 6th pod with the new version
   - Delete a 2nd old pod
   - At this point: 2 old pods, 2 new pods

4. **Complete Migration**:
   - Continue until all old pods are replaced with new pods
   - Final state: 0 old pods, 4 new pods

### Important Considerations
- During this process, users may see two different versions of the application
- Application code must be designed to handle this mixed-version state
- Database schemas must be backward and forward compatible

## Our Current Approach

Our current infrastructure is configured for a Blue-Green deployment approach with Node Groups. As shown in our Terraform configuration:

```terraform
module "eks" {
  // ... other configuration ...

  eks_managed_node_groups = {
    /* blue = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]
      min_size     = 2
      max_size     = 10
      desired_size = 2
    } */
    
    green = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]
      min_size     = 2
      max_size     = 10
      desired_size = 2

      iam_role_additional_policies = {
        AmazonEBS = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFS = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoad = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
      }

      /* taints = {
        upgrade = {
          key = "upgrade"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      } */
    }
  }
  // ... other configuration ...
}
```

We currently have the "green" Node Group active, with commented-out configurations for:
1. A potential "blue" Node Group for future use
2. Node taints that could be used during a controlled migration

### Load Balancer Strategy for Zero Downtime

Another approach for zero-downtime specifically focuses on the Load Balancer configuration:

### Step-by-Step Process

1. **Current State**:
   - Load Balancer → Listener → Rule → Target Group (Blue) → Instances

2. **Create Parallel Infrastructure**:
   - Create a new Target Group (Green)
   - Add new nodes running the updated version to this Target Group

3. **Testing Phase**:
   - Create a new internal Load Balancer with:
     - New Listener
     - New Rule
     - Connection to the new Target Group (Green)
   - Test the application using this internal URL to verify functionality

4. **Traffic Switching**:
   - Once testing confirms the new setup is ready, edit the main Load Balancer rules
   - Update rules to send traffic to the new Target Group (Green)

5. **Backup and Rollback Option**:
   - Keep the old Target Group (Blue) as a backup
   - This provides a quick rollback option if issues arise with the new setup

### Benefits of This Approach
- Zero downtime for end users
- Controlled testing before exposing to production traffic
- Quick rollback option if needed

---

## Interview Scenario: Real-world EKS Upgrade

### Question:

**"Describe how you handled a production EKS cluster upgrade in your previous role."**

### Simple Experience-Based Answer:

"In my last project, we had to upgrade our production EKS cluster from version 1.32 to 1.33. Since this cluster was running our e-commerce platform, we had to make sure the upgrade caused very little impact to customers. Here's how I handled it step by step:

First, I prepared a proper upgrade plan and shared it with all the teams – developers, QA, product owners, and even the support team. We fixed a 3-hour maintenance window during off-peak time (2 AM to 5 AM) and informed everyone one week in advance.

Two days before the actual upgrade, I created a test environment that was exactly like production and did a full dry run. This helped me catch small issues before touching the live system.

On the upgrade day, we started with some preparation:

* At 1:45 AM, I blocked any new deployments by updating firewall rules.
* At 2:00 AM, the support team informed customers about the maintenance.
* I also double-checked that all nodes were healthy and that we had fresh backups.

For the upgrade itself, I used a **blue-green style** approach:

1. I created a new node group in EKS with the same capacity as the old one but prevented it from taking workloads immediately.
   ```bash
   # Creating a new node group through Terraform
   # By adding taint configuration to the node group
   green = {
     ami_type       = "AL2023_x86_64_STANDARD"
     instance_types = ["m5.xlarge"]
     min_size     = 2
     max_size     = 10
     desired_size = 2
     
     taints = {
       upgrade = {
         key = "upgrade"
         value = "true"
         effect = "NO_SCHEDULE"
       }
     }
   }
   
   # Alternatively, adding taints manually
   kubectl taint nodes NODE_NAME upgrade=true:NoSchedule
   ```

2. I upgraded the EKS control plane to 1.33 from the AWS console and kept monitoring until it finished.
   ```bash
   # Check cluster version before upgrade
   kubectl version --short
   
   # After upgrading via AWS console, verify again
   kubectl version --short
   ```

3. Then I confirmed the new nodes were connected and running on the new version.
   ```bash
   # Verify node group is properly registered
   kubectl get nodes
   
   # Check Kubernetes version on new nodes
   kubectl get nodes -o wide
   ```

4. Next, I slowly moved workloads:

   * Stopped scheduling new pods on the old nodes.
     ```bash
     # Cordon old nodes to prevent new scheduling
     kubectl cordon old-node-1 old-node-2 old-node-3
     ```
   
   * Allowed scheduling on the new nodes.
     ```bash
     # Remove taints from new nodes
     kubectl taint nodes new-node-1 upgrade=true:NoSchedule-
     kubectl taint nodes new-node-2 upgrade=true:NoSchedule-
     ```
   
   * Drained old nodes one by one, with a small gap, while watching application health.
     ```bash
     # Drain old nodes with 5-minute intervals
     kubectl drain old-node-1 --ignore-daemonsets --delete-emptydir-data
     # Wait 5 minutes, monitoring application health
     kubectl drain old-node-2 --ignore-daemonsets --delete-emptydir-data
     # Wait 5 minutes, monitoring application health
     kubectl drain old-node-3 --ignore-daemonsets --delete-emptydir-data
     ```

During migration, I kept an eye on Prometheus and Grafana dashboards to ensure no service was breaking. After all pods were shifted to the new nodes, I tested key business flows like login, product search, and checkout.

Once everything looked good:

* I deleted the old node group.
  ```bash
  # Either through AWS console or Terraform
  terraform destroy -target=module.eks.aws_eks_node_group.blue
  ```

* Restored the firewall rules.
* Had the support team send an "all clear" message.
* Asked app teams to double-check their services.
* Finally, I documented the whole process including one small issue we faced with a stateful app, which we fixed quickly because we had steps ready.

The whole process took about 2 hours and 15 minutes, much less than the 3-hour window. Actual customer impact was only around 30 minutes, and overall the upgrade was smooth. Careful planning and the blue-green method helped us complete it without major downtime."

By implementing these strategies, we can ensure reliable and consistent upgrades to our Kubernetes clusters while minimizing or eliminating downtime for our users.
