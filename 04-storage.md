# Storage

Data is the largest asset and attack surface of Protected B workloads
within the Advanced Analytics Workspaces. This section is focusing
on storage controlled by users directely. The AAW environment consists
currently of two main types of user storage:

*	Disk storage (attached to one pod at a time)
*	Object storage

Additionally, data is obtained from the following sources:

* Object storage (internal to AAW)
* Statistics Canada public data
* External data sources

Kubernetes supports other storage providers, including mounting of local
directories into a container, but this is blocked by existing Gatekeeper
policies.

In general, the rules are:

> **Data store**: Any location, physical or logical, which is capable of
> storing user-generated data.

1. Protected B data stores may be read and written to by a Protected B workload
2. Unclassified data stores may be **only read** by a Protected B workload
3. Protected B data stores may never be accessed from an unclassified workload

*Note: This proposal does not define sharing of data between Protected B
workloads. This is left to the DAaaS project to elaborate and design
should this funcationality be deemed necessary.*

## Disk storage

Access to disk storage will be restricted based on the classification of the
disk and the classification of the pod it is being connected to. The following
table describes the disk classification, disk mode and pod classification, and
whether the combination is permitted or denied:

| Pod Classification | Disk Classification | Disk Mode  | Result    |
|--------------------|---------------------|------------|-----------|
| Unclassified       | Unclassified        | Read only  | Permitted |
| Unclassified       | Unclassified        | Read/write | Permitted |
| Unclassified       | Protected B         | Read only  | Denied    |
| Unclassified       | Protected B         | Read/write | Denied    |
| Protected B        | Unclassified        | Read only  | Permitted |
| Protected B        | Unclassified        | Read/write | Denied    |
| Protected B        | Protected B         | Read only  | Permitted |
| Protected B        | Protected B         | Read/write | Permitted |

> Disk policies will be enforced by policy in Gatekeeper and the
> Open Policy Agent.

> **Recommendation STR-DSK-01**: The above disk policy be applied
> to the AAW environment.

## Object storage

A separate Protected B MinIO instance will be created for protected workloads.
This MinIO instance will operate similar to the existing MinIO instances,
except it will not be available outside of protected workloads
(no web interface).

Restricted access to MinIO storage will be implemented
using *Network Policies*.

> **Recommendation STR-OBJ-01**: The above object storage policy be applied
> to the AAW environment.

### One-way synchronization with unclassified MinIO instance

To facilitate fetching data from the internet, a one-way synchronization from
the unclassified Standard MinIO instance will be performed. A write-only bucket
on the Standard MinIO instance will be mirrored to a read-only bucket on
the protected B MinIO instance.

The synchronization pod will be the only pod which will be authorized to access
both the Unclassified and Protected B MinIO instances. The credentials assigned
to it will be:

* Read-only on the Unclassified instance in the “Sync” bucket
* Write-only on the Protected B instance in the “Sync” bucket

All users will have write access to the “Sync” bucket on the Unclassified
instance, and all users will have read access to the “Sync” bucket on the
Protected B instance.

> **Recommendation STR-OBJ-02**: The above object storage synchronization
> process be approved, providing a write-only bucket in the Unclassified
> instance mapped to a read-only bucket on the Protected B instance.

## Receiving and outputing Protected B data to/from AAW

This proposal does not propose a solution for receiving Protected B data into
the environment nor for extracting output from completed analysis. This will
require coordination with the appropriate groups at Statistics Canada
and will be left to the Data Analytics as a Service (DAaaS) project for
elaboration and design.
