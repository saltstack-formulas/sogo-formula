{% from "sogo/map.jinja" import sogo with context %}

include:
  - apache
  - memcached

sogo-repo:
  pkgrepo.managed:
    - humanname: Inverse SOGo Repository
    - baseurl: http://packages.inverse.ca/SOGo/nightly/{{ sogo.version }}/rhel/$releasever/$basearch
    - gpgcheck: 0

sogo:
  pkg.installed:
    - pkgs:
      - sogo
      - sogo-tool
      - sogo-ealarms-notify
      - sope49-gdl1-postgresql
      - sope49-gdl1-mysql
    - require:
      - pkgrepo: sogo-repo

  service.running:
    - name: sogod
    - enable: True
    - watch:
      - pkg: sogo

{% if sogo.get('config') %}
sogo-config:
  file.managed:
    - name: /etc/sogo/sogo.conf
    - mode: 640
    - group: sogo
    - contents: |
        {{ sogo.config|indent(8) }}
    - require:
      - pkg: sogo
    - watch_in:
      - service: sogo
{% endif %}

sogo-cronjob:
  file.managed:
    - name: /etc/cron.d/sogo
    - source: salt://sogo/files/sogo-cron
    - require:
      - pkg: sogo

sogo-httpd:
  file.managed:
    - name: /etc/httpd/conf.d/SOGo.conf
    - source: salt://sogo/files/sogo-httpd
    - template: jinja
    - defaults:
        url: {{ sogo.url }}
        port: {{ 443 if sogo.url.startswith('https') else 80 }}
    - require:
      - pkg: sogo
    - watch_in:
      - module: apache-reload
