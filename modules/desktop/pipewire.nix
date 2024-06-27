{...}: {
  # PipeWire is a new low-level multimedia framework. It aims to offer capture
  # and playback for both audio and video with minimal latency and support for
  # PulseAudio-, JACK-, ALSA- and GStreamer-based applications.
  # https://wiki.nixos.org/wiki/PipeWire

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
    pulse.enable = true;
  };

  # RealtimeKit is a D-Bus system service that allows user processes to gain
  # realtime scheduling priority on request. It is intended to be used as a
  # secure mechanism to allow real-time scheduling to be used by normal user
  # processes.
  security.rtkit.enable = true;
}
