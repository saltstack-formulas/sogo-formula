{% from "sogo/map.jinja" import sogo with context %}

{% set integrator = sogo.update_server.get('sogo-integrator') %}
{% if integrator %}
{% set version = integrator.version %}
{% set workdir = '/tmp/sogo-integrator-workdir-' + version %}
{% set file = '/tmp/sogo-integrator.xpi' %}

sogo-integrator-deps:
  pkg.installed:
    - pkgs:
      - unzip
      - zip

sogo-integrator-demo:
  cmd.run:
    - name: 'curl -Lf "http://www.sogo.nu/files/downloads/SOGo/Thunderbird/sogo-integrator-{{ version }}-sogo-demo.xpi" -o /tmp/sogo-integrator-demo-{{ version }}.xpi'
    - unless: 'test -f /tmp/sogo-integrator-demo-{{ version }}.xpi'

  archive.extracted:
    - name: /tmp/sogo-integrator-workdir-{{ version }}
    - source: /tmp/sogo-integrator-demo-{{ version }}.xpi
    - archive_format: zip
    - enforce_toplevel: false
    - if_missing: {{ workdir }}
    - require:
      - cmd: sogo-integrator-demo
      - pkg: sogo-integrator-deps

sogo-integrator-updateurl:
  file.replace:
    - name: {{ workdir }}/chrome/content/extensions.rdf
    - pattern: |
        (updateURL)=".*/(updates\.php\?[^\"]*)"(.*)$
    - repl: |
        \1="{{ sogo.update_server.url }}/\2"\3
    - backup: False
    - require:
      - archive: sogo-integrator-demo
    - watch_in:
      - cmd: sogo-integrator-xpi-delete

{% for key, value in integrator.preferences.items() %}
sogo-integrator-preference-{{ key }}:
  file.replace:
    - name: {{ workdir }}/defaults/preferences/site.js
    - pattern: |
        (pref\("{{ key }}").*$
    - repl: |
        pref("{{ key }}", {{ value|json }});
    - append_if_not_found: True
    - backup: False
    - require:
      - archive: sogo-integrator-demo
    - watch_in:
      - cmd: sogo-integrator-xpi-delete
{% endfor %}

sogo-integrator-xpi-delete:
  cmd.wait:
    - name: 'rm -f {{ file }} *'
    - onlyif: test -f {{ file }}

sogo-integrator-xpi:
  cmd.run:
    - name: 'zip -FS -9 -r {{ file }} *'
    - cwd: {{ workdir }}
    - unless: test -f {{ file }}
    - require:
      - cmd: sogo-integrator-xpi-delete
{% endif %}
