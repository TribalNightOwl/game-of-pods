# redis-cluster StatefulSet
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis-cluster
spec:
  selector:
    matchLabels:
      app: redis-cluster
  serviceName: redis-cluster-service
  replicas: 6
  template:
    metadata:
      labels:
        app: redis-cluster
    spec:
      containers:
      - name: redis
        image: redis:5.0.1-alpine
        ports:
        - name: client
          containerPort: 6379
        - name: gossip
          containerPort: 16379
        env:
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        command: ["/conf/update-node.sh", "redis-server", "/conf/redis.conf"]
        volumeMounts:
        - name: conf
          mountPath: /conf
          readOnly: false
        - name: data
          mountPath: /data
          readOnly: false
      volumes:
        - name: conf
          configMap:
            defaultMode: 0755
            name: redis-cluster-configmap
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "my-storage-class"
      resources:
        requests:
          storage: 1Gi
EOF


# redis-cluster service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
    name: redis-cluster-service
    labels:
        app: redis-cluster
spec:
    ports:
      - name: client
        port: 6379
      - name: gossip
        port: 16379
    clusterIP: None
    selector:
        app: redis-cluster
EOF









# redis deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
    name: redis-deployment
    labels:
      app: redis
spec:
    replicas: 1
    selector:
      matchLabels:
        app: redis
    template:
      metadata:
        labels:
          app: redis
      spec:
        containers:
          - name: redis
            image: redis:alpine
            volumeMounts:
              - mountPath: /data
                name: redis-data
        volumes:
          - name: redis-data
            emptyDir: {}
EOF

# redis service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
    name: redis
    labels:
        app: redis
spec:
    type: ClusterIP
    ports:
      - port: 6379
        targetPort: 6379
        name: redis
    selector:
        app: redis
EOF


# worker deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
    name: worker
    labels:
      app: worker
spec:
    replicas: 1
    selector:
      matchLabels:
        app: worker
    template:
      metadata:
        labels:
          app: worker
      spec:
        containers:
          - name: worker
            image: kodekloud/examplevotingapp_worker
EOF


# db deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
    name: db-deployment
    labels:
      app: db
spec:
    replicas: 1
    selector:
      matchLabels:
        app: db
    template:
      metadata:
        labels:
          app: db
      spec:
        containers:
          - name: db
            image: postgres:9.4
            volumeMounts:
              - mountPath: /var/lib/postgresql/data
                name: db-data
            env:
              - name: POSTGRES_PASSWORD
                value: passwor
        volumes:
          - name: db-data
            emptyDir: {}
EOF


# db service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
    name: db
    labels:
        app: db
spec:
    type: ClusterIP
    ports:
      - port: 5432
        targetPort: 5432
        name: db
    selector:
        app: db
EOF


# result deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
    name: result-deployment
    labels:
      app: result
spec:
    replicas: 1
    selector:
      matchLabels:
        app: result
    template:
      metadata:
        labels:
          app: result
      spec:
        containers:
          - name: result
            image: kodekloud/examplevotingapp_result:before
EOF


# result service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
    name: result-service
    labels:
        app: result
spec:
    type: NodePort
    ports:
      - port: 5001
        targetPort: 80
        nodePort: 31001
        name: result
    selector:
        app: result
EOF
