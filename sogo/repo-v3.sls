sogo-repo:
  pkgrepo.managed:
    - humanname: Inverse SOGo Repository
    - baseurl: http://inverse.ca/rhel-v3/$releasever/$basearch
    - gpgcheck: 0
    - exclude: '*-3.0.0b*'
