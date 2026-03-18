# Lab Creation Guide for ZeroTouch Labs

## Quick Start

Use `zt-filesystem-troubleshooting` as a reference template for creating new labs.

## Step-by-Step Lab Creation

### 1. Create Directory Structure

```bash
mkdir -p zt-{lab-name}/{config,content/modules/ROOT/pages,setup-automation,runtime-automation}
```

### 2. Create Configuration Files

#### config/instances.yaml
```yaml
---
virtualmachines:
  - name: "rhel"
    image: "rhel-10-0-07-09-25-3"
    bootloader: efi
    memory: "4G"
    cores: 2
    image_size: "20G"
    tags:
      - key: "AnsibleGroup"
        value: "bastions"
    networks:
      - default
    # Optional: Additional disks
    disks:
      - name: additional-disk
        size: 5G
```

#### config/networks.yaml
```yaml
---
# Default network exists by default, specify here always.
- name: default
```

#### config/firewall.yaml
```yaml
---
firewall:
  rules:
    - name: allow_ssh
      port: 22
      protocol: tcp
      action: accept
      source: any
```

### 3. Create Lab Metadata

#### lab-metadata.yml
```yaml
lab:
  name: "Your Lab Name"
  shortname: "zt-your-lab"
  maintainer: "Your Name (email@redhat.com)"

  description:
    summary: "Brief description"
    goal: "What users will learn"
    concepts:
     - "Key concept 1"
     - "Key concept 2"
    use_case: "Detailed scenario"
    time_to_complete: "30"

  git_ref:
    production: "prod"
    development: "dev"
```

### 4. Create Antora Configuration

#### content/antora.yml
```yaml
---
name: modules
version: master

asciidoc:
  attributes:
    lab_name: "Your Lab Name"
    release-version: master
    page-pagination: true
```

#### site.yml
```yaml
---
site:
  title: Your Lab Name
  start_page: modules::01-introduction.adoc
content:
  sources:
    - url: ./content
      branches: HEAD
      start_path: .
ui:
  bundle:
    url: https://github.com/redhat-scholar/course-ui/releases/latest/download/ui-bundle.zip
```

#### ui-config.yml
```yaml
antora:
  name: modules
  dir: www
  modules:
    - name: 01-introduction
      label: "Introduction"
      solveButton: false
    - name: 02-next-module
      label: "Module Name"
      solveButton: true

tabs:
  - name: ">_ terminal"
    url: /wetty
```

### 5. Create Content Files

Create AsciiDoc files in `content/modules/ROOT/pages/`:
- `01-introduction.adoc`
- `02-module-name.adoc`
- etc.

**AsciiDoc Tips:**
```asciidoc
= Module Title

== Section Heading

Regular text content.

[source,bash,role=execute]
----
command to execute
----

[NOTE]
====
Important note in a callout box
====

[TIP]
====
Helpful tip
====

[quote, Person Name]
____
A quote from someone
____
```

### 6. Create Setup Automation

#### setup-automation/setup-rhel.sh
```bash
#!/bin/bash
# Setup script for initial provisioning

set -e

# Your setup commands here
echo "Setting up lab environment..."

exit 0
```

#### setup-automation/ansible.cfg
```ini
[defaults]
inventory = inventory
host_key_checking = False
stdout_callback = yaml
```

#### setup-automation/main.yml
```yaml
---
- name: Setup lab environment
  hosts: all
  become: true
  gather_facts: false

  tasks:
    - name: Run setup script
      script: setup-rhel.sh
```

### 7. Create Runtime Automation

For each module, create a directory in `runtime-automation/`:

#### runtime-automation/{module-name}/setup-rhel.sh
```bash
#!/bin/bash
# Module setup - runs when module starts
exit 0
```

#### runtime-automation/{module-name}/solve-rhel.sh
```bash
#!/bin/bash
# Solution script - shows/performs the solution
echo "=== Solution ==="
# Your solution commands here
exit 0
```

#### runtime-automation/{module-name}/validate-rhel.sh
```bash
#!/bin/bash
# Validation script - checks if module objectives are met

# Check something
if [ condition ]; then
    echo "FAIL: Description of what failed"
    exit 1
fi

echo "PASS: Module objectives completed"
exit 0
```

#### runtime-automation/ansible.cfg
```ini
[defaults]
inventory = inventory
host_key_checking = False
stdout_callback = yaml
```

#### runtime-automation/inventory
```ini
[rhel]
localhost ansible_connection=local
```

#### runtime-automation/main.yml
```yaml
---
- name: Runtime automation
  hosts: all
  become: true
  gather_facts: false

  tasks:
    - name: Execute module script
      script: "{{ lookup('env', 'MODULE_PATH') }}"
      when: lookup('env', 'MODULE_PATH') is defined
```

### 8. Make Scripts Executable

```bash
chmod +x setup-automation/*.sh
chmod +x runtime-automation/*/*.sh
```

## Common Patterns

### Multiple VMs
```yaml
virtualmachines:
  - name: "rhel1"
    image: "rhel-10-0-07-09-25-3"
    # ... config ...
  - name: "rhel2"
    image: "rhel-10-0-07-09-25-3"
    # ... config ...
```

Then create `setup-rhel1.sh`, `setup-rhel2.sh`, etc.

### Adding Packages
```yaml
virtualmachines:
  - name: "rhel"
    # ... other config ...
    packages:
      - package1
      - package2
```

### Adding Services
```yaml
virtualmachines:
  - name: "rhel"
    # ... other config ...
    services:
      - name: service-name
        ports:
          - port: 8080
            protocol: TCP
            targetPort: 8080
            name: service-name
```

## Testing Your Lab

1. Verify all required files exist
2. Check that all scripts are executable
3. Validate YAML syntax
4. Test the lab in the platform environment

## Reference

See `zt-filesystem-troubleshooting` as a complete working example.
