{% from "sogo/map.jinja" import sogo with context %}

{% if sogo.update_server.get('sogo-integrator') %}
{% set version = sogo.update_server.get('sogo-integrator').version %}

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
    - if_missing: /tmp/sogo-integrator-workdir-{{ version }}
    - prereq:
      - cmd: sogo-integrator-xpi
    - require:
      - pkg: sogo-integrator-deps

{# TODO: update config files #}

sogo-integrator-xpi:
  cmd.run:
    - name: 'zip -FS -9 -r /tmp/sogo-integrator.xpi /tmp/sogo-integrator-workdir-{{ version }}/*'
{% endif %}
