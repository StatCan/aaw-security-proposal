# Classification

Proper identification of workload classifications is critical to providing
separation of unclassified and protected workloads within the Advanced
Analytics Workspaces.

Due to the AAW’s origin in unclassified workloads, the environment will continue
to support, and default to, this type of workload. In doing so, it will retain the
associated flexibility in tooling, connectivity, etc. This approach provides the
lowest friction to users:
* Existing unclassified workloads will continue to function
* Workloads that necessitate external connectivity (e.g. web scraping) remain
  possible
Workloads that are explicitly indicated as being Protected will have a series of
restrictions placed on them and, in turn, may gain controlled access to
Protected resources.

A metadata-driven approach to proactive identification of Protected
workloads is recommended, implemented using Kubernetes labels.

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
> — https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/

> **Recommendation CL-LBL-01**: Use Kubernetes label
> `data.statcan.gc.ca/classification` as a basis for tracking the data
> classification of, and controlling access to, Kubernetes objects.

### `data.statcan.gc.ca/classification`

The classification label will track the data classification of the labelled
object. The classification value on storage-related objects will identify
the data classification, whereas the classification on compute-related objects
will represent the classification of data that is processed by the object.

> Only **bolded** values will be used within the AAW.

| Value              | Meaning          |
|--------------------|------------------|
| **`unclassified`** | **Unclassified** |
| `protected-a`      | Protected A      |
| **`protected-b`**  | **Protected B**  |
| `protected-c`      | Protected C      |
| `confidential`     | Confidential     |
| `secret`           | Secret           |
| `top-secret`       | Top Secret       |

> If the classification label is not provided,
> then the workload is assumed to be Unclassified.

**Important note**: Labels in Kubernetes are mutable, meaning they can be
changed at any time. To prevent security incidents, we must enforce that
the `data.statcan.gc.ca/classification` label be immutable.
This will be done through Gatekeeper and the Open Policy Agent.

> **Recommendation CL-LBL-02**: The proposed Kubernetes label
> `data.statcan.gc.ca/classification` be made "immutable"
> via Gatekeeper / Open Policy Agent policies.
