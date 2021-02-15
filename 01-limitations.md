# Limitations

During the preparation of a security design for enabling Protected B workloads
in the existing Advanced Analytics Workspaces (AAW), it was determined that
while not unfeasible to integrate them in the existing environment, a more
secure AAW environment could be re-constructed to provide the appropriate
levels of defence, including providing better workload isolation between
levels of data classification.

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

## Development requirements

Some of the recommendations in this document may require some
custom development of control components in order to implement
the recommendation.

\newpage
