# Subscribing To a Cluster Server

## Publishing and subscribing with Red5 Pro clusters

With clustering, we need to determine which red5 pro instance the client will use. The other examples used a static configuration ip for streaming endpoints. Basic clustering uses more than one stream endpoint for subscribers. Advanced clustering uses more than one endpoint for publishers also.

In the basic clustering scenario, our configuration ip will be used differently for publishers and subscribers. Publishers will stream directly to the configuration ip. Subscribers will not. Instead, subscribers will call a web service to receive the ip that should be used.

### Example Code

- ***[SubscribeCluster.swift](SubscribeCluster.swift)***

## Configuration of the server

The cluster.xml file located in the conf directory. If the server is an edge, add an ip for its origin(s) within the origins list. Every server in your cluster must use the same password or core connections are denied. Set the public facing ip and port.

Origins provide round robin, and you can exclude instances from it by setting the privateInstance property to true on the edge. The hidden edge can be used for other purposes such as being a repeater origin.

```xml
    <bean name="clusterConfig" class="com.red5pro.cluster.ClusterConfiguration" >

        <property name="origins">

      <list>


          <!-- add origin ips and optional port if not the default.  -->
            <value>0.0.0.0:1935</value>

      </list>

        </property>
    <!-- edge/origin link cluster password-->
    <property name="password" value="changeme"/>
    <!-- EDGE public ip -->
    <property name="publicIp" value="0.0.0.0"/>
    <!-- EDGE public port -->
    <property name="publicPort" value="1935"/>
    <!-- EDGE include in round robin -->
    <property name="privateInstance" value="false"/>
    </bean>
</beans>
```

The round robin servlet is defined in web.xml of your webapp. It is the service point subscribers use to get a playback-ip.

```xml
    <servlet>

        <servlet-name>cluster</servlet-name>

        <servlet-class>

            com.red5pro.cluster.plugin.agent.ClusterWebService

        </servlet-class>

        <load-on-startup>2</load-on-startup>
    </servlet>
    <servlet-mapping>

        <servlet-name>cluster</servlet-name>

        <url-pattern>/cluster</url-pattern>

    </servlet-mapping>
```

The uri would be http://YOUR_IP:5080/YOURAPP/cluster

## How to Publish

Publishers must use the origin ip in their configuration. The stream is distributed to the edges from the origin. Use the publish example or a flash broadcaster to provide a live stream.

## How to Subscribe

Subscribers call the cluster servlet, and use the return data as the configuration ip. The origin will know which edges are active and provide the next in sequence.

```Swift
let urlString = "http://" + (Testbed.getParameter("host") as! String) + ":5080/cluster"

NSURLConnection.sendAsynchronousRequest(
  NSURLRequest( URL: NSURL(fileURLWithPath: urlString) ),
  queue: NSOperationQueue(),
  completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in

    if ((error) != nil) {
      NSLog("%@", error!);
      return;
    }

    //   Convert our response to a usable NSString
    let dataAsString = NSString( data: data!, encoding: NSUTF8StringEncoding)

    //   The string above is formatted like 99.98.97.96:1234, but we won't need the port portion
    let ip = dataAsString?.substringToIndex((dataAsString?.rangeOfString(":").location)!)
    NSLog("Retrieved %@ from %@, of which the usable IP is %@", dataAsString!, urlString, ip!);
```

[SubscribeCluster.swift #19](SubscribeCluster.swift#L19)
