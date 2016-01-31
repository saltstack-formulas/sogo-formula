{% from "sogo/map.jinja" import sogo with context %}

include:
  - .{{ 'repo-v3' if sogo.use_v3 else 'repo-v2' }}
  - apache

sogo:
  pkg.installed:
    - pkgs:
      - sogo
      - sogo-tool
      - sogo-ealarms-notify
      - sope49-gdl1-postgresql
      - sope49-gdl1-mysql

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
    - group: {{ sogo.group }}
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

sogo-httpd:
  file.managed:
    - name: /etc/httpd/conf.d/SOGo.conf
    - source: salt://sogo/files/sogo-httpd
    - template: jinja
    - defaults:
        url: {{ sogo.url }}
        port: {{ 443 if sogo.url.startswith('https') else 80 }}
    - watch_in:
      - module: apache-reload
