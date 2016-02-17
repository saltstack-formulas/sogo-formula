{% from "sogo/map.jinja" import sogo with context %}

{% set integrator = sogo.update_server.get('sogo-integrator') %}
{% if integrator %}
{% set version = integrator.version %}
{% set workdir = '/tmp/sogo-integrator-workdir-' + version %}

sogo-integrator-deps:
  pkg.installed:
    - pkgs:
      - unzip
      - zip

sogo-integrator-demo:
  cmd.run:
    - name: 'curl -Lf "http://www.sogo.nu/files/downloads/SOGo/Thunderbird/sogo-integrator-{{ version }}-sogo-demo.xpi" -o /tmp/sogo-integrator-demo-{{ version }}.xpi'
    - prereq:
      - archive: sogo-integrator-demo

  archive.extracted:
    - name: /tmp/sogo-integrator-workdir-{{ version }}
    - source: /tmp/sogo-integrator-demo-{{ version }}.xpi
    - archive_format: zip
    - if_missing: {{ workdir }}
    - require:
      - pkg: sogo-integrator-deps

sogo-integrator-updateurl:
  file.replace:
    - name: {{ workdir }}/chrome/content/extensions.rdf
    - pattern: ^(.*updateURL)=".*/(updates\.php\?[^\"]*)"(.*)$
    - repl: '\1="{{ sogo.update_server.url }}/\2"\3'
    - backup: False
    - require:
      - archive: sogo-integrator-demo
    - watch_in:
      - cmd: sogo-integrator-xpi

{% for key, value in integrator.preferences.items() %}
sogo-integrator-preference-{{ key }}:
  file.replace:
    - name: {{ workdir }}/defaults/preferences/site.js
    - pattern: (pref\("{{ key }}").*$
    - repl: '\1, {{ value|json }});'
    - append_if_not_found: True
    - backup: False
    - require:
      - archive: sogo-integrator-demo
    - watch_in:
      - cmd: sogo-integrator-xpi
{% endfor %}

sogo-integrator-xpi:
  cmd.wait:
    - name: 'zip -FS -9 -r /tmp/sogo-integrator.xpi {{ workdir }}/*'
{% endif %}
