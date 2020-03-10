# Lab 6: Monitor Experiments

In this lab we will demonstrate how you can monitor ongoing experiments.

## Splunk

We can attach Splunk Monitor server to our Chaos Engine service and do a data post processing there.

### Start Splunk

Go to you Chaos Engine instance and from the `chaos-engine` git repo run:

```bash tab="shell command"
docker-compose -f docker-compose-splunk.yml up
```

``` tab="expected command"
WARNING: Found orphan containers (chaos-engine_vault-loader_1, chaos-engine_vault_1, chaos-engine_chaosengine_1) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.
Starting chaos-engine_splunk_1 ... done
Attaching to chaos-engine_splunk_1
splunk_1  | 
splunk_1  | Splunk> 4TW
splunk_1  | 
splunk_1  | Checking prerequisites...
splunk_1  |     Checking http port [8000]: open
splunk_1  |     Checking mgmt port [8089]: open
splunk_1  |     Checking appserver port [127.0.0.1:8065]: open
splunk_1  |     Checking kvstore port [8191]: open
splunk_1  |     Checking configuration...  Done.
splunk_1  |     Checking critical directories...        Done
splunk_1  |     Checking indexes...
splunk_1  |             Validated: _audit _internal _introspection _telemetry _thefishbucket history main summary
splunk_1  |     Done
splunk_1  |     Checking filesystem compatibility...  Done
splunk_1  |     Checking conf files for problems...
splunk_1  |     Done
splunk_1  |     Checking default conf files for edits...
splunk_1  |     Validating installed files against hashes from '/opt/splunk/splunk-7.0.3-fa31da744b51-linux-2.6-x86_64-manifest'
splunk_1  | File '/opt/splunk/etc/apps/splunk_httpinput/default/inputs.conf' changed.
splunk_1  |     Problems were found, please review your files and move customizations to local
splunk_1  | All preliminary checks passed.
splunk_1  | 
splunk_1  | Starting splunk server daemon (splunkd)...  
splunk_1  | Done
splunk_1  | 
splunk_1  | 
splunk_1  | Waiting for web server at http://127.0.0.1:8000 to be available..... Done
splunk_1  | 
splunk_1  | 
splunk_1  | If you get stuck, we're here to help.  
splunk_1  | Look for answers here: http://docs.splunk.com
splunk_1  | 
splunk_1  | The Splunk web interface is at http://b987dc22238f:8000
splunk_1  | 
```

### Chaos Engine Dashboard
Splunk instance will be preloaded with a dashboard for Chaos Experiments monitoring.

```bash
https://${CHAOS_ENGINE_IP}:9000/en-US/app/search/chaos_overview
```

## Notification Modules

The Chaos Engine can send notifications to multiple channels. 

At the moment it supports:

- Slack

- DataDog Event Stream

- XMPP / Jabber

For detail description of each notification channel and message content [see documentation.](https://thalesgroup.github.io/chaos-engine/Logging_and_Reporting/Notifications/slack/)

### XMPP Module
Let's activate XMPP module to better understand how it works.

#### Deploy test XMPP server
We need to deploy a XMPP server who will be processing our notifications. 

##### Start XMPP server

Go to your Chaos Engine instance and run `ejabberd` server:

```bash tab="shell command"
docker run -it --rm --name ejabberd  \
    -p 5222:5222 \
    -p 5269:5269 \
    -p 5443:5443 \
    -p 1883:1883 \
    -p 5280:5280 ejabberd/ecs
```

``` tab="expected output"
2020-02-27 12:21:52.274868+00:00 [critical] Failed to set logging: {error,
                           {handler_not_added,
                               {invalid_config,logger_std_h,
                                   #{file =>
                                         "/home/ejabberd/logs/ejabberd.log"}}}}
2020-02-27 12:21:52.654284+00:00 [info] Loading configuration from /home/ejabberd/conf/ejabberd.yml
2020-02-27 12:21:52.703112+00:00 [warning] ACME directory URL https://acme-v01.api.letsencrypt.org defined in option acme->ca_url is deprecated and was automatically replaced with https://acme-v02.api.letsencrypt.org/directory. Please adjust your configuration file accordingly. Hint: run `ejabberdctl dump-config` command to view current configuration as it is seen by ejabberd.
2020-02-27 12:21:52.703553+00:00 [warning] Option 'log_rotate_date' is deprecated and has no effect anymore. Please remove it from the configuration.
2020-02-27 12:21:52.703873+00:00 [warning] Option 'log_rate_limit' is deprecated and has no effect anymore. Please remove it from the configuration.
2020-02-27 12:21:53.466033+00:00 [info] Configuration loaded successfully
2020-02-27 12:21:53.766025+00:00 [info] Building language translation cache
2020-02-27 12:21:54.377753+00:00 [info] Creating Mnesia ram table 'ejabberd_commands'
2020-02-27 12:21:54.477696+00:00 [info] Creating Mnesia ram table 'route'
2020-02-27 12:21:54.490312+00:00 [info] Creating Mnesia ram table 'route_multicast'
2020-02-27 12:21:54.515036+00:00 [info] Creating Mnesia ram table 'session'
2020-02-27 12:21:54.524188+00:00 [info] Creating Mnesia ram table 'session_counter'
2020-02-27 12:21:54.541913+00:00 [info] Creating Mnesia ram table 's2s'
2020-02-27 12:21:54.550388+00:00 [info] Creating Mnesia ram table 'temporarily_blocked'
2020-02-27 12:21:54.568955+00:00 [info] Loading modules for localhost
2020-02-27 12:21:54.570129+00:00 [info] Creating Mnesia ram table 'mod_register_ip'
2020-02-27 12:21:54.577959+00:00 [info] Creating Mnesia disc table 'sr_group'
2020-02-27 12:21:54.585388+00:00 [info] Creating Mnesia disc table 'sr_user'
2020-02-27 12:21:54.596781+00:00 [info] Creating Mnesia disc_only table 'privacy'
2020-02-27 12:21:54.628718+00:00 [warning] Mnesia backend for mod_mam is not recommended: it's limited to 2GB and often gets corrupted when reaching this limit. SQL backend is recommended. Namely, for small servers SQLite is a preferred choice because it's very easy to configure.
2020-02-27 12:21:54.629141+00:00 [info] Creating Mnesia disc_only table 'archive_msg'
2020-02-27 12:21:54.640068+00:00 [info] Creating Mnesia disc_only table 'archive_prefs'
2020-02-27 12:21:54.685725+00:00 [info] Creating Mnesia disc table 'muc_room'
2020-02-27 12:21:54.694844+00:00 [info] Creating Mnesia disc table 'muc_registered'
2020-02-27 12:21:54.704680+00:00 [info] Creating Mnesia ram table 'muc_online_room'
2020-02-27 12:21:54.717231+00:00 [info] Creating Mnesia disc_only table 'vcard'
2020-02-27 12:21:54.726915+00:00 [info] Creating Mnesia disc table 'vcard_search'
2020-02-27 12:21:54.750776+00:00 [info] Creating Mnesia disc_only table 'motd'
2020-02-27 12:21:54.760577+00:00 [info] Creating Mnesia disc_only table 'motd_users'
2020-02-27 12:21:54.789235+00:00 [info] Creating Mnesia ram table 'bosh'
2020-02-27 12:21:54.797795+00:00 [info] Creating Mnesia disc_only table 'push_session'
2020-02-27 12:21:54.819676+00:00 [info] Creating Mnesia disc_only table 'roster'
2020-02-27 12:21:54.845965+00:00 [info] Creating Mnesia disc_only table 'roster_version'
2020-02-27 12:21:54.922432+00:00 [info] Creating Mnesia disc_only table 'last_activity'
2020-02-27 12:21:54.947673+00:00 [info] Creating Mnesia disc_only table 'offline_msg'
2020-02-27 12:21:54.998384+00:00 [info] Creating Mnesia ram table 'sip_session'
2020-02-27 12:21:55.038610+00:00 [info] Creating Mnesia disc_only table 'caps_features'
2020-02-27 12:21:55.048919+00:00 [info] Creating Mnesia ram table 'pubsub_last_item'
2020-02-27 12:21:55.059239+00:00 [info] Creating Mnesia disc table 'pubsub_index'
2020-02-27 12:21:55.073598+00:00 [info] Creating Mnesia disc table 'pubsub_node'
2020-02-27 12:21:55.084673+00:00 [info] Creating Mnesia disc table 'pubsub_state'
2020-02-27 12:21:55.093349+00:00 [info] Creating Mnesia disc_only table 'pubsub_item'
2020-02-27 12:21:55.108872+00:00 [info] Creating Mnesia disc table 'pubsub_orphan'
2020-02-27 12:21:55.117947+00:00 [info] Creating Mnesia disc_only table 'private_storage'
2020-02-27 12:21:55.145023+00:00 [info] Creating Mnesia disc_only table 'mqtt_pub'
2020-02-27 12:21:55.160187+00:00 [info] Creating Mnesia ram table 'mqtt_session'
2020-02-27 12:21:55.169008+00:00 [info] Creating Mnesia ram table 'mqtt_sub'
2020-02-27 12:21:55.193342+00:00 [info] Building MQTT cache for localhost, this may take a while
2020-02-27 12:21:55.212517+00:00 [info] Creating Mnesia ram table 'bytestream'
2020-02-27 12:21:55.228890+00:00 [info] Creating Mnesia disc_only table 'passwd'
2020-02-27 12:21:55.238541+00:00 [info] Creating Mnesia ram table 'reg_users_counter'
2020-02-27 12:21:55.261166+00:00 [info] Creating Mnesia disc_only table 'oauth_token'
2020-02-27 12:21:55.272232+00:00 [info] Creating Mnesia disc table 'oauth_client'
2020-02-27 12:21:55.328426+00:00 [info] Waiting for Mnesia synchronization to complete
2020-02-27 12:21:55.401107+00:00 [warning] Invalid certificate in /home/ejabberd/conf/server.pem: at line 53: self-signed certificate
2020-02-27 12:21:55.620877+00:00 [warning] No certificate found matching conference.localhost
2020-02-27 12:21:55.621084+00:00 [warning] No certificate found matching upload.localhost
2020-02-27 12:21:55.621280+00:00 [warning] No certificate found matching proxy.localhost
2020-02-27 12:21:55.621436+00:00 [warning] No certificate found matching pubsub.localhost
2020-02-27 12:21:55.621592+00:00 [info] ejabberd 20.1.0 is started in the node ejabberd@97ac81e5b1ab in 3.36s
2020-02-27 12:21:55.624763+00:00 [info] Start accepting TCP connections at [::]:5222 for ejabberd_c2s
2020-02-27 12:21:55.624997+00:00 [info] Start accepting TCP connections at [::]:5269 for ejabberd_s2s_in
2020-02-27 12:21:55.626317+00:00 [info] Start accepting TLS connections at [::]:5443 for ejabberd_http
2020-02-27 12:21:55.626556+00:00 [info] Start accepting TCP connections at [::]:5280 for ejabberd_http
2020-02-27 12:21:55.628548+00:00 [info] Start accepting TCP connections at [::]:1883 for mod_mqtt
2020-02-27 12:21:55.630578+00:00 [info] Start accepting TCP connections at 172.17.0.2:7777 for mod_proxy65_stream

```
##### Adjust configuration

Add `${CHAOS_ENGINE_IP}` into the list of hosts in `ejabberd` config:
```bash
docker exec -it ejabberd vi /home/ejabberd/conf/ejabberd.yml
```

Reload server configuration
```bash
docker exec -it ejabberd bin/ejabberdctl reload_config
```

##### Provision test users

In the next step we are going to provision two users `chaos` and `test`. 
`chaos` is an account to be used by the Chaos Engine. 
`test` is a user who will receive notifications.

```bash
docker exec -it ejabberd bin/ejabberdctl register test localhost test
docker exec -it ejabberd bin/ejabberdctl register chaos localhost test

docker exec -it ejabberd bin/ejabberdctl register test ${CHAOS_ENGINE_IP} test
docker exec -it ejabberd bin/ejabberdctl register chaos ${CHAOS_ENGINE_IP} test

```

#### Connect a jabber client

Recommended client is `Pidgin` with XMPP plugin. If you don't have `Pidgin` installed or your organization blocks XMPP traffic you can used `finch` ([finch cheat cheat](https://developer.pidgin.im/wiki/Using%20Finch#HowdoIswitchbetweenwindows)) that is installed on your chaos engine machine.


Start your preferred client and and new account with following parameters:

- user: `test`
- password: `test`
- domain: `localhost`
- server: `${CHAOS_ENGINE_IP}`

#### Update Chaos Engine configuration
Stop your Chaos Engine instance by running:

```bash
docker-compose stop
```

Update `./developer-tools/vault-loader/vault-secrets.json` file in the Chaos Engine git repo with following parameters:

```json
  "xmpp.enabled": "true",
  "xmpp.user": "chaos",
  "xmpp.password" : "test",
  "xmpp.domain": "localhost",
  "xmpp.hostname": "${CHAOS_ENGINE_IP}",
  "xmpp.serverCertFingerprint": "CERTSHA256:f9:16:59:0b:93:72:66:a4:9a:db:df:2a:7f:8b:a3:cf:44:2b:a2:31:a8:1a:72:f5:7d:43:76:21:c6:2c:b3:81",
  "xmpp.recipients": "test@localhost"
```

Start the Chaos Engine again
```bash
docker-compose stop
```

If everything was configured well you should see new message popping up in your IM client.

Trigger `experiment` api and check content of incoming messages.

```bash
curl -X POST "http://${CHAOS_ENINE_IP}:8080/experiment/start"
```

