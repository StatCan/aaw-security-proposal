# Kubernetes

> Note: Generally in this section, the terminology of namespace vs. profile
> is interchangeable. Profiles map directly to a namespace, and in the
> AAW environment user namespaces are not seperately provisioned.

## Workloads scheduling

Kubernetes has a diverse and powerful scheduler for locating
user-level resources. Appropriate configuration of resources
will ensure that workloads get scheduled on the appropriate
nodes.

### Node labels + taints

Each node pool in Kubernetes will have a set of labels applied that
will assist with the scheduling of workloads on the appropriate
nodes.

| Label                               | Value                        | Purpose                                 |
|-------------------------------------|------------------------------|-----------------------------------------|
| `data.statcan.gc.ca/classification` | `(unclassified|protected-b)` | Maximum data classification of the node |
| `node.statcan.gc.ca/purpose`        | `(system|user)`              | Purpose of the node                     |

### Namespaces labels

System namespaces will be identified by

| Label                             | Value                 | Purpose                   |
|-----------------------------------|-----------------------|---------------------------|
| `namespace.statcan.gc.ca/purpose` | `(system|daaas|user)` | Purpose of the namespace. |

#### Node selectors on workloads

> **Recommendation KUBE-NODE-01**: All pods must have a `nodeSelector`
> which indicates the criteria for a node selection, requiring
> both the classification and purpose labels for any workload
> being scheduled in the AAW environment. This will be enforced
> by Gatekeeper.
>
> *Note: this restriction will not apply to workloads created
> by the Azure Kubernetes Service as we do not have control
> over them.*
>
> *Note: Setting `node.statcan.gc.ca/purpose=system` as a node selector
> is only permitted from namespaces having `namespace.statcan.gc.ca/purpose=system`
> and `namespace.statcan.gc.ca/purpose=daaas`.*
>
> If `namespace.statcan.gc.ca/purpose` is unset on a namespace, then the namespace
> is assumed to be a `user` namesapce.

## Images

The current Advanced Analytics Workspaces (AAW) environment restricts where
the container images are authorized to be pulled from
(https://github.com/StatCan/gatekeeper-policies/blob/master/general/container-allowed-images/constraint.yaml).
The current list of images is very large and shouldn't be used for
Protected B workloads.

> **Recommendation KUBE-IMG-01**: All container images associated
> with platform components must be stored in an AAW controlled
> image repository.

> **Recommendation KUBE-IMG-02**: The authorized image list for
> Protected B workloads be restricted to AAW controlled
> image repositories only.

> **Recommendation KUBE-IMG-03**: The authorized image list for
> unclassified workloads be further restricted than what is
> currently in place. Ideally, this list should be restricted
> to AAW controller image repositories only.

> **Recommendation KUBE-IMG-04**: Images running in the environment
> must align with CIS benchmarks. Images in the production environment
> must be built via an automated build pipeline which includes
> a `dockle` scan (for CIS benchmarks). In particular, user
> containers must not run as the `ROOT` user.
>
> Images built by developers must be restricted to the development
> environment. This can be accomplished via a different repository,
> where the production environment does not have permissions to
> the dev repository.

> **Recommendation KUBE-IMG-05**: User namespaces contain image pull
> credentials which restrict read-only access in Artifactory to:
>
> 1. DAaaS kubeflow images repository
> 2. Repositories assigned to the namespace

## Gatekeeper / Open Policy Agent

Gatekeeper and the Open Policy Agent provide a mechanism
for enforcing business policies on Kubernetes resources.
Gatekeeper is a Kubernetes webhook, which provides a callback
that is executed when a resource is created, updated
or deleted.

Gatekeeper is intented to enforce many of the policies
suggested in this proposal.

> **Recommendation KUBE-GK-01**: Gatekeeper be configured
> in a default-closed configuration, ensuring that if
> Gatekeeper is unavailable that all changes are blocked.
> This ensures that policy violations are not introduced
> in the event of a Gatekeeper outage.

> **Recommendation KUBE-GK-02**: Gatekeeper configuration
> be reviewed to ensure that it is highly-available
> and will scale with any increased load, to prevent
> a system outage.

> **Recommendation KUBE-GK-03**: Existing policies
> in https://github.com/StatCan/gatekeeper-policies be used.
> Any policy currently in "audit" state should be moved
> to enforce state on user namesapces.

> **Recommendation KUBE-GK-04**: A gatekeeper policy
> be created which prevents `kubectl exec` on any pods
> marked with a classification of `protected-b`.

> **Recommendation KUBE-GK-05**: A gatekeeper policy
> be created which prevents `kubectl cp` on any pods
> marked with a classification of `protected-b`.

## Access control

Kubernetes has a robust Role-Based Access Control (RBAC) system,
that enables fine-grained control over a user's permissions
within the cluster.

> **Recommendation KUBE-RBAC-01**: That the following Azure AD groups
> be created to align with Kubernetes roles:
>
> 1. **`DAaaS-Breakglass-Admins`**: Full administrative access
>    to the entire system, including user namespaces.
>
>    Users in this group may access the admin configuration
>    context in the event that Azure AD authentication is
>    not functioning.
>
>    This group should be assigned to admin cloud accounts only,
>    and not to normal user account.
> 2. **`DAaaS-Platform-Admins`**: Full administrative access to
>    system, no access to DAaaS or user namespaces.
> 3. **`DAaaS-Admins`**: Access to DAaaS system namespaces,
>    no access to user namespaces.
> 4. **`DAaaS-Support`**: Limited access to user namespaces to provide
>    general debugging support.
> 5. **`DAaaS-Users`**: No global RBAC configuration. Users will typically
>    be granted access to any profiles they have access to.
>
> All "-admins" and "-support" roles are to have the permission to pull
> the Kubernetes configuration file to access the cluster.

> **Recommendation KUBE-RBAC-01a**: As an extension of KUBE-RBAC-01,
> this recommendation further elaborates the permissions assigned
> to the `DAaaS-Support` group.
>
> - Read and list all resources associated with the Kubeflow
>   environment: `Profiles`, `Deployments`, `Statefulsets`, `Replicasets`,
>   `Pods`, `Notebooks`, `Workflows`, `PersistentVolumeClaims`, `Roles`
>   , `RoleBindings` and `Events`.
> - List `ConfigMaps` and `Secrets` (no read due to the possibility of
>   of sensitive values)
> - Read and list `Nodes`

> **Recommendation KUBE-RBAC-02**: Kubeflow assigns a large set of permissions
> to the `default-editor` account. These permissions should be reviewed and
> restricted to essential/functional needs only.
>
> *This is an ongoing excercise outside of this proposal, therefore
> I will not propose specific requirements, but instead strongly
> recommend that the excercise be continued and completed*.

> **Recommendation KUBE-RBAC-03**: To better restrict user access to the AAW
> environment, access to any web application which allows interaction with
> any compute or storage, other than publicly accessible component, is to
> be limited to the `DAaaS-Users` group.
