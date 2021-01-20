# Classification

Proper identification of workload classifications is critical to providing
separation of unclassified and protected workloads within the Advanced
Analytics Workspaces.

Due to the AAW’s origin in unclassified workloads, the environment will remain
unclassified by default. This provides the lowest friction to users as most
workloads do not require access to protected information. Workloads that are
classified explicitly assigned as protected workloads, then these workloads
will have a series of restrictions placed on them.

The proposed identification method for workload identification is labels.

## Labels

According to the Kubernetes documentation, labels are:

> key/value pairs that are attached to objects, such as pods. Labels are
> intended to be used to specify identifying attributes of objects that are
> meaningful and relevant to users, but do not directly imply semantics to the
> core system. Labels can be used to organize and to select subsets of objects.
> Labels can be attached to objects at creation time and subsequently added and
> modified at any time. Each object can have a set of key/value labels defined.
> Each Key must be unique for a given object.
>
> https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/

The proposed labelling for classification is:

### `data.statcan.gc.ca/classification`

> Only **bolded** values will be used within the AAW.

| Value              | Meaning          |
|--------------------|------------------|
| **`unclassified`** | **Unclassified** |
| `protected-a`      | Protected A      |
| **`protected-b`**  | **Protected B**  |
| `protected-c`      | Protected C      |
| `classified`       | Classified       |
| `secret`           | Secret           |
| `top-secret`       | Top Secret       |

> **Important note**: Labels in Kubernetes are mutable, meaning they can be
> changed at any time. To prevent security incidents, we must enforce that
> the classification label be immutable. This will be done through Gatekeeper
> and the Open Policy Agent.
