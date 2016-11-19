{% from 'cas/map.jinja' import cas, sls_block with context %}
{% from 'cas/deploy.jinja' import deploy, deploy_requires %}

{% if cas.container == 'standalone' %}
cas_user:
  user.present:
    - name: {{ deploy.user }}

cas_group:
  group.present:
    - name: {{ deploy.group }}
{% endif %}

cas_war:
  file.managed:
    - name: {{ deploy.war }}
    {{ sls_block(cas.war_file) | indent(4) }}
    {{ deploy_requires() | indent(4) }}

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

{% if deploy.xml is defined %}
cas_war_xml:
  file.managed:
    - name: {{ deploy.xml }}
    - source: salt://cas/files/cas.xml
    - template: jinja
    - user: {{ deploy.user }}
    - group: {{ deploy.group }}
    - defaults:
        name: {{ cas.name }}
        context_path: {{ cas.context_path }}
    {{ deploy_requires() | indent(4) }}
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
{% if cas.properties_file %}
  file.managed:
    - name: {{ deploy.directory }}/cas.properties
    - user: {{ deploy.user }}
    - group: {{ deploy.group }}
    {{ sls_block(cas.properties_file) | indent(4) }}
    {{ deploy_requires() | indent(4) }}
{% else %}
  file.serialize:
    - name: {{ deploy.directory }}/cas.yaml
    - user: {{ deploy.user }}
    - group: {{ deploy.group }}
    - dataset_pillar: cas:properties
    - formatter: yaml
    {{ deploy_requires() | indent(4) }}
{% endif %}

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

{% if cas.container == 'standalone' and grains.os_family == 'FreeBSD' %}
cas_init_script:
  file.managed:
    - name: /usr/local/etc/rc.d/{{ cas.name }}
    - source: salt://cas/files/freebsd-rc.sh
    - template: jinja
    - mode: 755
    - defaults:
        service_name: {{ cas.name }}
        directory: {{ deploy.directory | yaml_encode }}
        user: {{ deploy.user | yaml_encode }}
        war: {{ deploy.war | yaml_encode }}

cas_service:
  service.running:
    - name: {{ cas.name }}
    - enable: true
{% endif %}
