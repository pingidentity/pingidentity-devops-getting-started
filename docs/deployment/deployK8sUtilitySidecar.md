---
title: Using a Utility Sidecar
---
# Using a Utility Sidecar
## Why Use a Sidecar
When running containerized software, each individual container should represent one process. This model allows containers to be minimal, more easily secured, and to be configured with the proper resource allocations accurately.

There are common situations where running commands and tools on a pod running Ping Identity software is useful. These situations include collecting a support archive, exporting data, or running a backup. However, because many of these processes might introduce unexpected contention for CPU and memory resources, executing such commands inside the container running the actual server process can be risky. The container for the product is sized for the server process without consideration for auxiliary processes that might be executed at the same time.

To avoid these issues, one practice is to use a utility sidecar for tools that need to run alongside the main server process. This sidecar runs as a separate container on the pod.  However, in the Kubernetes model, all containers in the same pod can share a process namespace (if enabled), and can also be configured to share a persistent volume. This co-location allows any required processes to run in the sidecar without competing with the main server process for the same resources.  

The major downside of running a utility sidecar is that it must always be running because new containers cannot be attached to existing pods. The sidecar can be configured with minimal memory and CPU resources, but will continue to run even when it is not actively in use.

!!! error "StatefulSets"
    You cannot remove a sidecar from a running StatefulSet without rolling all the pods.

## How to Deploy a Sidecar
If you are using the [Ping Identity Helm charts](https://helm.pingidentity.com/), you can update your custom values.yaml file to enable a sidecar for any product. For example:

```yaml
pingdirectory:
  enabled: true
  workload:
    # Share process namespace for sidecar to get a view inside the main container
    shareProcessNamespace: true
  # Share /tmp so sidecar can see Java processes. Don't keep /tmp around between restarts though.
  volumes:
  - name: temp
    emptyDir: {}
  volumeMounts:
  - name: temp
    mountPath: /tmp
  # Backups, restores, and other CLI tools should be run from the sidecar to prevent interfering
  # with the main PingDirectory container process.
  utilitySidecar:
    enabled: true
```

These values will add a sidecar container using the same image as the main server container, configured with minimal resources and waiting in an endless loop. The generated yaml will look like the following example and could be applied directly outside of Helm:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app.kubernetes.io/name: pingdirectory
  name: sidecar-pingdirectory
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: pingdirectory
  serviceName: sidecar-pingdirectory-cluster
  template:
    metadata:
      labels:
        app.kubernetes.io/name: pingdirectory
    spec:
      containers:
      - envFrom:
        - secretRef:
            name: devops-secret
            optional: true
        image: pingidentity/pingdirectory:latest
        livenessProbe:
          exec:
            command:
            - /opt/liveness.sh
          failureThreshold: 4
          initialDelaySeconds: 30
          periodSeconds: 30
          successThreshold: 1
          timeoutSeconds: 5
        name: pingdirectory
        ports:
        - containerPort: 1443
          name: https
        - containerPort: 1389
          name: ldap
        - containerPort: 1636
          name: ldaps
        readinessProbe:
          exec:
            command:
            - /opt/readiness.sh
          failureThreshold: 4
          initialDelaySeconds: 30
          periodSeconds: 30
          successThreshold: 1
          timeoutSeconds: 5
        resources:
          limits:
            cpu: 2
            memory: 8Gi
          requests:
            cpu: 50m
            memory: 2Gi
        startupProbe:
          exec:
            command:
            - /opt/liveness.sh
          failureThreshold: 180
          periodSeconds: 10
          timeoutSeconds: 5
        volumeMounts:
        - mountPath: /tmp
          name: temp
        - mountPath: /opt/out
          name: out-dir
      - args:
        - -f
        - /dev/null
        command:
        - tail
        image: pingidentity/pingdirectory:latest
        name: utility-sidecar
        resources:
          limits:
            cpu: "1"
            memory: 2Gi
          requests:
            cpu: "0"
            memory: 128Mi
        volumeMounts:
        - mountPath: /opt/out
          name: out-dir
        - mountPath: /tmp
          name: temp
      securityContext:
        fsGroup: 0
        runAsGroup: 0
        runAsUser: 9031
      shareProcessNamespace: true
      terminationGracePeriodSeconds: 300
      volumes:
      - emptyDir: {}
        name: temp
      - name: out-dir
        persistentVolumeClaim:
          claimName: out-dir
  volumeClaimTemplates:
  - metadata:
      name: out-dir
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 8Gi
      storageClassName: null
```
