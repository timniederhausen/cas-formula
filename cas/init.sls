{% from 'cas/map.jinja' import cas, sls_block with context %}
{% from 'cas/deploy.jinja' import deploy, deploy_requires %}

cas_directory:
  file.directory:
    - name: {{ deploy.directory }}
    - user: {{ deploy.user }}
    - group: {{ deploy.group }}
    - makedirs: true

cas_log_directory:
  file.directory:
    - name: {{ deploy.log_directory }}
    - user: {{ deploy.user }}
    - group: {{ deploy.group }}
    - makedirs: true

{% if cas.json_services %}
cas_services_directory:
  file.directory:
    - name: {{ deploy.directory }}/services
    - user: {{ deploy.user }}
    - group: {{ deploy.group }}
    - makedirs: true
{% endif %}

cas_log4j2:
  file.managed:
    - name: {{ deploy.directory }}/log4j2.xml
    - source: salt://cas/files/log4j2.xml
    - template: jinja
    - user: {{ deploy.user }}
    - group: {{ deploy.group }}
    - defaults:
        log_directory: {{ deploy.log_directory }}
    {{ deploy_requires() | indent(4) }}

cas_properties:
  file.managed:
    - name: {{ deploy.directory }}/cas.properties
    - user: {{ deploy.user }}
    - group: {{ deploy.group }}
    {{ sls_block(cas.properties_file) | indent(4) }}
    {{ deploy_requires() | indent(4) }}

{% if cas.json_services %}
{% for name, opts in cas.json_services.items() %}
cas_service_{{ name }}:
  file.managed:
    - name: {{ deploy.directory }}/services/{{ name }}.json
    - user: {{ deploy.user }}
    - group: {{ deploy.group }}
    {{ sls_block(opts) | indent(4) }}
    {{ deploy_requires() | indent(4) }}
{% endfor %}
{% endif %}
