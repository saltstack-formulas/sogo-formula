{% from "sogo/map.jinja" import sogo with context %}

include:
  - apache

sogo-update-server-deps:
  pkg.installed:
    - name: php

sogo-update-server-dir:
  file.directory:
    - name: {{ sogo.update_server.dir }}
    - mode: 755
    - clean: True

sogo-updates.php:
  file.managed:
    - name: {{ sogo.update_server.dir }}/updates.php
    - mode: 644
    - source: salt://sogo/files/updates.php
    - template: jinja
    - makedirs: True
    - defaults:
        config: {{ sogo.update_server }}
    - require:
      - pkg: sogo-update-server-deps
    - require_in:
      - file: sogo-update-server-dir

sogo-update-server-httpd:
  file.managed:
    - name: /etc/httpd/conf.d/SOGo-update-server.conf
    - source: salt://sogo/files/sogo-update-server-httpd
    - template: jinja
    - defaults:
        config: {{ sogo.update_server }}
    - watch_in:
      - module: apache-reload

{% for plugin in sogo.update_server.get('plugins', []) %}
{% set file = sogo.update_server.dir + '/' + plugin.id + '-' + plugin.version + '.xpi' %}
sogo-update-server-plugin-{{ plugin.id }}:
  cmd.run:
    - name: 'curl -Lf "{{ plugin.url }}" -o "{{ file }}"'
    - unless: 'test -f "{{ file }}"'
    - require:
      - file: sogo-updates.php

  file.managed:
    - name: {{ file }}
    - replace: False
    - create: False
    - require:
      - cmd: sogo-update-server-plugin-{{ plugin.id }}
    - require_in:
      - file: sogo-update-server-dir
{% endfor %}
