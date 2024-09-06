---
marp: false
title: SDK and Debugging Lisbon
author: Alex Madon
footer: Lisbon 2024
---

<!-- headingDivider: 2 -->

# SDK and Debugging

Point of view: support: identifying/understanding problems 


# Plan

1. ActiveMQ and python
2. Adding java debugging ACS side, SDK side

# ActiveMQ and python

* you can use python to consume the event2 topic (SDK is no mandatory)
* you can use python to debug the queue (transformers) with AMQ mirrors


## ActiveMQ and python: why?

* write apps: `hyland_stomp_activemq_consume_alfresco_repo_event2` (DEMO1)
* debug, and debug not just topics, but also queues
* easy

```python
import stomp # pip3 install stomp.py
```

## Debug problem: messages org.apache.camel DEBUG are truncated

* camel is an apache project https://camel.apache.org/ (https://github.com/apache/camel/tree/main)

* set DEBUG an org.apache.camel at
http://localhost:8080/alfresco/s/enterprise/admin/admin-log-settings
```
2023-06-13 11:47:00,734  DEBUG [component.jms.JmsConfiguration] [eventAsyncDequeueThreadPool1] 
Sending JMS message to: topic://alfresco.repo.event2 with message: ActiveMQTextMessage 
...
text = {"specversion":"1.0","type":"org.alfresco.eve...rities":[]}}}
```
(DEMO2)

## debug rendition and transformer queues

```lua
transform.service.enabled=true
local.transform.service.enabled=false
```

https://hyland.atlassian.net/browse/MNT-23454 
https://hyland.atlassian.net/browse/MNT-23478 


## active MQ transport connectors and protocols

* JMS: Java
* openwire: wireshark (to be modified)
* stomp: python

```
        <!--
            The transport connectors expose ActiveMQ over a given protocol to
            clients and other brokers. For more information, see:

            http://activemq.apache.org/configuring-transports.html
        -->
        <transportConnectors>
            <!-- DOS protection, limit concurrent connections to 1000 and frame size to 100MB -->
            <transportConnector name="openwire" uri="tcp://0.0.0.0:61616?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
            <transportConnector name="amqp" uri="amqp://0.0.0.0:5672?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
            <transportConnector name="stomp" uri="stomp://0.0.0.0:61613?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
            <transportConnector name="mqtt" uri="mqtt://0.0.0.0:1883?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
            <transportConnector name="ws" uri="ws://0.0.0.0:61614?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
        </transportConnectors>
```

## Active MQ queue mirrors

https://activemq.apache.org/mirrored-queues.html

add in [activemq.xml](file:////home/madon/alfrescosoft/apache-activemq-5.18.1/conf/activemq.xml)

```xml
<destinationInterceptors>
    <mirroredQueue copyMessage = "true" postfix=".qmirroralex" prefix=""/>
</destinationInterceptors>
```

# Adding java debugging ACS side, SDK side

##  debug SDK side

You already know: spring boot debug, in CLI or application.properties

```
alexevent_05_handler_eventHandler_pure_all/README.md
java -Dlogging.level.org.alfresco.event.sdk.integration.transformer.EventGenericTransformer=DEBUG  -jar target/*jar
```




## ACS Java debugging, log4j: patching, example: bad scope REST keycloak


https://github.com/Alfresco/alfresco-java-sdk
https://github.com/Alfresco/alfresco-java-sdk?tab=readme-ov-file#4-configure-rest-api


authorization-grant-type

```
alex_05_rest_search_keycloak_token_refresh_admin/src/main/resources/application.properties
spring.security.oauth2.client.registration.alfresco-rest-api.authorization-grant-type=password
```

```
alex_06_rest_discovery_keycloak_token_refresh_admin/src/main/resources/application.properties
spring.security.oauth2.client.registration.alfresco-rest-api.authorization-grant-type=password
```



## Adding java debug lines

[MNT-24542: Improve ACS REST API error messages when using Keycloak token with bad scope](https://hyland.atlassian.net/browse/MNT-24542)

```java
LOGGER.debug("httpResponse.getHeaderMap()"+httpResponse.getHeaderMap());
LOGGER.debug("httpResponse.getContent()"+httpResponse.getContent());
```

Then root cause is clear: `Missing openid scope`

```
2024-07-24T16:00:15,097 [] DEBUG [authentication.identityservice.SpringBasedIdentityServiceFacade] 
[http-nio-127.0.0.1-8080-exec-10] Getting uri: <http://127.0.0.2:8180/auth/realms/alfresco/protocol/openid-connect/userinfo>
2024-07-24T16:00:15,120 [] DEBUG [authentication.identityservice.SpringBasedIdentityServiceFacade] 
[http-nio-127.0.0.1-8080-exec-10] httpResponse.getHeaderMap(){content-length=[0], 
Content-Type=[application/json], Referrer-Policy=[no-referrer], 
Strict-Transport-Security=[max-age=31536000; includeSubDomains], 
WWW-Authenticate=[Bearer realm="alfresco", error="insufficient_scope", error_description="Missing openid scope"], 
X-Content-Type-Options=[nosniff], 
X-Frame-Options=[SAMEORIGIN], 
X-XSS-Protection=[1; mode=block]}
```

# QA

Thank You!
