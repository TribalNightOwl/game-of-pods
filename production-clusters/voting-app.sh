# Create namespace
kubectl create namespace vote

# Set namespace as current
kubectl config set-context --current --namespace=vote


# vote deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
    name: vote-deployment
    labels:
      app: vote
spec:
    replicas: 1
    selector:
      matchLabels:
        app: vote
    template:
      metadata:
        labels:
          app: vote
      spec:
        containers:
          - name: vote
            image: kodekloud/examplevotingapp_vote:before
EOF


# vote service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
    name: vote-service
    labels:
        app: vote
spec:
    type: NodePort
    ports:
      - port: 5000
        targetPort: 80
        nodePort: 31000
        name: vote
    selector:
        app: vote
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
