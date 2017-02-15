# concourse-deploy-pmysql

Deploy Pivotal MySQL with [omg](https://github.com/enaml-ops) in a Concourse pipeline.

## Prerequisites

1. [Git](https://git-scm.com)
1. [Vault](https://www.vaultproject.io)
1. [Concourse](http://concourse.ci)

## Steps to use this pipeline

1. Clone this repository.

    ```
    git clone https://github.com/enaml-ops/concourse-deploy-pmysql.git
    ```

1. Copy the sample properties `deployment-props-sample.json`.

    ```
    cd concourse-deploy-pmysql
    cp deployment-props-sample.json deployment-props.json
    ```

1. Edit `deployment-props.json`, adding the appropriate values.

    This file is used to populate a `vault` hash.  It holds the BOSH credentials for both `omg` (username/password) and the Concourse `bosh-deployment` (UAA client) resource.

    ```
    $EDITOR deployment-props.json
    ```
   You need to fill all the values from that file. This is a reference for the values:
   
    network: The name of the network
    ip: IP Address of p-mysql server.
    proxy-ip:  Mysql Proxy IP Address
    monitoring-ip:  Monitoring IP Address
    broker-ip:  Broker IP Address
    base-domain: Cloud Foundry base domain
    az: Availability zone
    pivnet_api_token:  Pivotal Network API Token
    syslog-address:  Syslog Server IP Address

    Then you need to run the following command.
    
    ```
    ./setup-pipeline.sh
    ```
