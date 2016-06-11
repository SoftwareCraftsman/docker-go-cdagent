#!/bin/bash

if [ ! -f "/var/go/.ssh/id_rsa" ] ; then
  mkdir -p /var/go/.ssh
  ssh-keygen -C "docker-go-cdagent" -N '' -f /var/go/.ssh/id_rsa
  chown -R go:go /var/go/.ssh
  eval "$(ssh-agent -s)"
  ssh-add /var/go/.ssh/id_rsa

  # Dump the public key so we can use it later (e.g. accessing a Git repo using ssh)
  echo "######"
  echo "# The go-cdagent SSH public key"
  cat /var/go/.ssh/id_rsa.pub
  echo "######"

  #http://askubuntu.com/questions/123072/ssh-automatically-accept-keys
  ssh-keyscan -H bitbucket.org >> /var/go/.ssh/known_hosts
  ssh-keyscan -H github.com >> /var/go/.ssh/known_hosts
fi

GO_SERVER=${GO_SERVER:-buildserver}

sed -i -e 's/GO_SERVER=.*/GO_SERVER='$GO_SERVER'/' /etc/default/go-agent

mkdir -p /var/lib/go-agent/config
rm -f /var/lib/go-agent/config/autoregister.properties

AGENT_KEY="${AGENT_KEY:-7fd926aa8323}"
echo "agent.auto.register.key=$AGENT_KEY" >/var/lib/go-agent/config/autoregister.properties

if [ -n "$AGENT_RESOURCES" ]; then echo "agent.auto.register.resources=$AGENT_RESOURCES" >>/var/lib/go-agent/config/autoregister.properties; fi
if [ -n "$AGENT_ENVIRONMENTS" ]; then echo "agent.auto.register.environments=$AGENT_ENVIRONMENTS" >>/var/lib/go-agent/config/autoregister.properties; fi

if [ -f "/var/lib/go-agent/.agent-bootstrapper.running" ] ; then
    echo "######"
    echo "Detected improper previous shutdown. Lock file /var/lib/go-agent/.agent-bootstrapper.running will be deleted!"
    rm -v -f /var/lib/go-agent/.agent-bootstrapper.running
    echo "######"
fi

exec /etc/init.d/go-agent start
