{ ... }:

{
  home.file.".ssh/config".text = ''
    Include config.d/*
  '';

  home.file.".ssh/config.d/lab".text = ''
Host bastion-lau1
  HostName 91.92.227.10
  User exoadmin
  SendEnv LANG LC_* EXOSCALE_API_KEY EXOSCALE_API_SECRET
  StrictHostKeyChecking yes

Host *.lau1
  User exoadmin
  ProxyJump bastion-lau1
  StrictHostKeyChecking off

Host infra-testbench.lau1
  HostName 192.168.240.03

Host test-a2sdi-01.lau1
  HostName 192.168.240.210
Host test-a2sdi-02.lau1
  HostName 192.168.240.212
Host test-a2sdi-03.lau1
  HostName 192.168.240.214
Host test-asrock-w680.lau1
  HostName 192.168.240.220

Host block-store.lau1
  HostName 192.168.240.225
Host virt-hv.lau1
  HostName 192.168.240.226
  '';
}
