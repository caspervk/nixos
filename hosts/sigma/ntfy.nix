{...}: {
  # UnifiedPush lets the user choose how push notifications are delivered
  # instead of relying on Google Firebase. It involves four components:
  #  - Application Server (e.g. Matrix Synapse).
  #  - UnifiedPush Server (e.g ntfy-sh).
  #  - UnifiedPush Distributor Android App (e.g. ntfy).
  #  - Android app (e.g. Matrix ElementX).
  # Communication between the UnifiedPush Server and Distributor App is not
  # part of the spec; we must use either e.g. ntfy-sh/ntfy or
  # NextCloud/NextPush.
  #
  # For example, ElementX registers for notifications with the ntfy app, which
  # provides ElementX with a webhook URL (topic) on the ntfy-sh server.
  # ElementX tells Synapse to send notifications through the webhook. On new
  # messages, Synapse makes a HTTP POST request to the ntfy-sh server, which
  # contacts the ntfy app through its persistent websocket connection, which
  # wakes up ElementX and tells it to fetch the notification contents from
  # Synapse.
  #
  # Webhook (topics) are created on the fly by subscribing or publishing to
  # them. By default, the ntfy-sh server allows anyone to use the server
  # without authentication. Because of this, the webhook is essentially a
  # password and should be kept secret. This is normally the case and therefore
  # not a confidentiality issue, although it can be a availability concern if
  # malicious actors abuse the service.
  #
  # NOTE: the ntfy app defaults to the centralised ntfy.sh server. Element does
  # not seem to overwrite prior webhooks, but instead append new ones.
  # Therefore, if it manages to register before the ntfy app's server is
  # changed, Synapse will contact the ntfy.sh server forever. Check with:
  # > sudo -u matrix-synapse psql -c 'select * from pushers;'
  # https://unifiedpush.org/
  # https://f-droid.org/2022/12/18/unifiedpush.html
  # https://f-droid.org/en/packages/io.heckel.ntfy/
  services.ntfy-sh = {
    enable = true;
    # https://docs.ntfy.sh/config/#config-options
    settings = {
      base-url = "https://ntfy.caspervk.net";
      behind-proxy = true;
      # Disable default centralised https://ntfy.sh server
      # https://docs.ntfy.sh/config/#ios-instant-notifications
      upstream-base-url = "";
      # Disable web interface
      web-root = "disable";
    };
  };
}
