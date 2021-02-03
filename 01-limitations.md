# Limitations

During the preparation of a security design for enabling Protected B workloads
in the existing Advanced Analytics Workspaces (AAW) it was determined that
it is not feasible to properly secure the environment for Protected B
workloads. Therefore, this proposal does not propose adding Protected B
workloads into the existing AAW environment but instead re-construct
the AAW environment in a manner that facilitates the necessary controls
to properly isolate and control security controls.

## Options

Two options were identified on how to design the Protected B workloads:

1. Use two separate clusters: 1 Unclassified, 1 Protected B
2. Use one cluster, with isolation

While the first option provides the highest level of security, there
are major tradeoffs in relation to user experience and maintainability.
Therefore it was decided that the best balance between security
and usability/maintainability was provided by option 2.

Therefore, this proposal describes the use of one cluster for
both Unclassified and Protected B workloads.
