# Kubernetes

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

#### Node selectors on workloads

> **Recommendation KUBE-NODE-01**: All pods must have a `nodeSelector
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
> is only permitted from pre-authorized namespaces.*

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
