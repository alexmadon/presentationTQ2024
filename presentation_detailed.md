---
marp: false
title: SDK and Debugging Lisbon
author: Alex Madon
---

SDK and Debugging
=================

Point of view: support: identifying/understanding problems 

---

Plan
====

1. ActiveMQ and python
2. Adding java debugging ACS side, SDK side


---

# Developer debugging


---

camel.apache.org
https://github.com/apache/camel/tree/main
https://camel.apache.org/

http://localhost:8080/alfresco/s/enterprise/admin/admin-log-settings
org.apache.camel DEBUG



https://stackoverflow.com/questions/26912344/full-text-of-message-in-activemq-log

Unfortunately the toString method of ActiveMQTextMessage is truncating the message text.

```
2023-06-13 11:47:00,734  DEBUG [component.jms.JmsConfiguration] [eventAsyncDequeueThreadPool1] 
Sending JMS message to: topic://alfresco.repo.event2 with message: ActiveMQTextMessage 
{commandId = 0, responseRequired = false, messageId = null, originalDestination = null, 
originalTransactionId = null, producerId = null, destination = null, transactionId = null, 
expiration = 0, timestamp = 0, arrival = 0, brokerInTime = 0, brokerOutTime = 0, correlationId = null, 
replyTo = null, persistent = true, type = null, priority = 0, groupID = null, groupSequence = 0, 
targetConsumerId = null, compressed = false, userID = null, content = null, 
marshalledProperties = null, dataStructure = null, redeliveryCounter = 0, size = 0, 
properties = {breadcrumbId=E2529D79EC4AAB9-00000000000000D2, JMS_AMQP_MESSAGE_FORMAT=0}, readOnlyProperties = false, readOnlyBody = false, droppable = false, jmsXGroupFirstForConsumer = false, 
text = {"specversion":"1.0","type":"org.alfresco.eve...rities":[]}}}
```

---

## note on renditions and transformers

force_remote=False
    # force_remote=True
    if force_remote:
        lines.append('transform.service.enabled=true')
        lines.append('local.transform.service.enabled=false') # -Dlocal.transform.service.enabled=false
    else:
        lines.append('transform.service.enabled=false')
        lines.append('local.transform.service.enabled=true') # -Dlocal.transform.service.enabled=false



https://hyland.atlassian.net/browse/MNT-23454 Enrich the transformer communication protocol to send also the UUID of the document to transform, CAD file transformation example 
https://hyland.atlassian.net/browse/MNT-23478 sending the sourceNodeRef to the async transformer for metadata extraction does not occur even when the transformer announces it supports that feature 

---

# bad scope

alex_03_rest_search_keycloak_token/README.md
3:MNT-24542: Improve ACS REST API error messages when using Keycloak token with bad scope

---

# adding java debug lines
https://hyland.atlassian.net/browse/MNT-24542

Catching the true root cause

The root cause has been identified by increasing the verbosity of this class SpringBasedIdentityServiceFacade.java, adding those two extra lines before line 146
LOGGER.debug("httpResponse.getHeaderMap()"+httpResponse.getHeaderMap());
LOGGER.debug("httpResponse.getContent()"+httpResponse.getContent());

 

ending up with something like
                .flatMap(httpResponse -> {
                    try
                    {
			            LOGGER.debug("httpResponse.getHeaderMap()"+httpResponse.getHeaderMap());
			            LOGGER.debug("httpResponse.getContent()"+httpResponse.getContent());
                        return Optional.of(UserInfoResponse.parse(httpResponse));
                    }

 for that try block.
When we look at the headers logged:
2024-07-24T16:00:15,097 [] DEBUG [authentication.identityservice.SpringBasedIdentityServiceFacade] [http-nio-127.0.0.1-8080-exec-10] Getting uri: <http://127.0.0.2:8180/auth/realms/alfresco/protocol/openid-connect/userinfo>
2024-07-24T16:00:15,120 [] DEBUG [authentication.identityservice.SpringBasedIdentityServiceFacade] [http-nio-127.0.0.1-8080-exec-10] httpResponse.getHeaderMap(){content-length=[0], Content-Type=[application/json], Referrer-Policy=[no-referrer], Strict-Transport-Security=[max-age=31536000; includeSubDomains], WWW-Authenticate=[Bearer realm="alfresco", error="insufficient_scope", error_description="Missing openid scope"], X-Content-Type-Options=[nosniff], X-Frame-Options=[SAMEORIGIN], X-XSS-Protection=[1; mode=block]}

then the root cause is clear:
error="insufficient_scope"
error_description="Missing openid scope"

---

# debug SDK side


MNT-24580 	

SDK 6 event api does not map correctly event data from JSON to Java object as it throws away Authority information present in the JSON 

alex_06_rest_discovery_keycloak_token_refresh_admin/README.md
15:MNT-24565: the REST API java SDK does not handle transparently failures to get an oauth refresh token, leaving REST API calls unanswered



alexevent_05_handler_eventHandler_pure_all/README.md
10:java -Dlogging.level.org.alfresco.event.sdk.integration.transformer.EventGenericTransformer=DEBUG  -jar target/*jar

# active MQ  transport connectors and protocols

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

---

# protocols

JMS: Java
openwire: wireshark (to be modified)
stomp: python

---

# Active MQ queue mirrors

queue vs topic

https://activemq.apache.org/mirrored-queues.html

```xml
<mirroredQueue copyMessage = "true" postfix=".qmirroralex" prefix=""/>
```

---

# python oneliners

```python
import stomp # pip3 install stomp.py
```



---

# Network dumps

---

# Java debugging

log4j


---

# debugging SDK REST applications with keycloak authentication


https://github.com/Alfresco/alfresco-java-sdk
https://github.com/Alfresco/alfresco-java-sdk?tab=readme-ov-file#4-configure-rest-api


#### 4. Configure REST API

In your ```application.properties``` file provide URL, authentication mechanism and credentials for accessing the REST API:

```
content.service.url=http://repository:8080
content.service.security.basicAuth.username=admin
content.service.security.basicAuth.password=admin
```

If you are using OAuth2, you can use client-credential based authentication:

```
spring.security.oauth2.client.registration.alfresco-rest-api.provider=alfresco-identity-service
spring.security.oauth2.client.registration.alfresco-rest-api.client-id=clientId
spring.security.oauth2.client.registration.alfresco-rest-api.client-secret=clientSecret
spring.security.oauth2.client.registration.alfresco-rest-api.authorization-grant-type=client_credentials
spring.security.oauth2.client.provider.alfresco-identity-service.token-uri=${keycloak.auth-server-url}/auth/realms/${keycloak.realm}/protocol/openid-connect/token
```

Or OAuth2 password based authentication:

```
spring.security.oauth2.client.registration.alfresco-rest-api.provider=alfresco-identity-service
spring.security.oauth2.client.registration.alfresco-rest-api.client-id=clientId
spring.security.oauth2.client.registration.alfresco-rest-api.client-secret=clientSecret
spring.security.oauth2.client.registration.alfresco-rest-api.username=username
spring.security.oauth2.client.registration.alfresco-rest-api.password=pwd
spring.security.oauth2.client.registration.alfresco-rest-api.authorization-grant-type=password
spring.security.oauth2.client.provider.alfresco-identity-service.token-uri=${keycloak.auth-server-url}/auth/realms/${keycloak.realm}/protocol/openid-connect/token
```

authorization-grant-type

alex_05_rest_search_keycloak_token_refresh_admin/src/main/resources/application.properties
37:spring.security.oauth2.client.registration.alfresco-rest-api.authorization-grant-type=password

alex_06_rest_discovery_keycloak_token_refresh_admin/src/main/resources/application.properties
37:spring.security.oauth2.client.registration.alfresco-rest-api.authorization-grant-type=password




recursive diff:

meld
