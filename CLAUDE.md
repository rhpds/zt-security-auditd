# ZeroTouch Labs - Claude Instructions

This repository contains RHEL online lab definitions for the ZeroTouch platform. When creating or modifying labs in this repository, follow these patterns and conventions.

## Lab Structure

Each lab is a self-contained directory named `zt-{lab-name}` with this structure:

```
zt-{lab-name}/
├── README.adoc                    # Lab overview documentation
├── lab-metadata.yml               # Single source of truth for lab info
├── site.yml                       # Antora site configuration
├── ui-config.yml                  # UI tabs and module configuration
├── config/
│   ├── instances.yaml            # VM definitions
│   ├── networks.yaml             # Network configuration
│   └── firewall.yaml             # Firewall rules
├── content/
│   ├── antora.yml                # Antora content config
│   └── modules/ROOT/
│       ├── assets/images/        # Images for documentation
│       └── pages/                # AsciiDoc module content files
├── setup-automation/              # Initial provisioning scripts
│   ├── setup-{vmname}.sh
│   ├── ansible.cfg
│   └── main.yml
└── runtime-automation/            # Per-module automation
    ├── {module-name}/
    │   ├── setup-{vmname}.sh     # Runs when module starts
    │   ├── solve-{vmname}.sh     # Shows/performs solution
    │   └── validate-{vmname}.sh  # Validates completion
    ├── ansible.cfg
    ├── inventory
    └── main.yml
```

## CRITICAL Configuration Patterns

### instances.yaml Format

**ALWAYS use this exact format:**

```yaml
---
virtualmachines:
  - name: "rhel"
    image: "rhel-10-0-07-09-25-3"
    bootloader: efi
    memory: "4G"
    cores: 2
    image_size: "30G"              # Size of main disk
    tags:
      - key: "AnsibleGroup"
        value: "bastions"
    networks:
      - default
    packages:                       # Optional
      - package1
      - package2
```

**Key points:**
- Top-level key is `virtualmachines` (NOT `instances`)
- Image must be `"rhel-10-0-07-09-25-3"`
- Must include `bootloader: efi`
- Use `image_size` for the main disk size (do NOT define a separate root disk)
- Memory and sizes use quoted strings with units: `"4G"`, `"20G"`, `"30G"`
- Always include the `AnsibleGroup: bastions` tag
- Networks is just `- default` (simple list format)
- **IMPORTANT**: Additional disks (via `disks:` section) may not work as expected - if you need more disk space, increase `image_size` instead

### networks.yaml Format

**ALWAYS use this minimal format:**

```yaml
---
# Default network exists by default, specify here always.
- name: default
```

**Do NOT specify subnet, gateway, or dhcp settings** - these are handled automatically.

### ui-config.yml Format

**Terminal tab MUST use this format:**

```yaml
antora:
  name: modules
  dir: www
  modules:
    - name: 01-module-name
      label: "Display Name"
      solveButton: true              # false for intro modules

tabs:
  - name: ">_ terminal"
    url: /wetty
```

**Key points:**
- Tab uses `url: /wetty` (NOT `port` and `path`)
- Module names match the content file names (e.g., `01-introduction` matches `01-introduction.adoc`)
- First module typically has `solveButton: false`

### lab-metadata.yml Format

```yaml
lab:
  name: "Full Lab Name"
  shortname: "zt-lab-shortname"
  maintainer: "Name (email@redhat.com)"

  description:
    summary: "Brief one-line description"
    goal: "What users will learn/accomplish"
    concepts:
     - "Key concept 1"
     - "Key concept 2"
     - "Key concept 3"
    use_case: "Detailed scenario description providing context"
    time_to_complete: "30"           # Estimated minutes

  git_ref:
    production: "prod"
    development: "dev"
```

## Content Guidelines

### AsciiDoc Module Files

- Place in `content/modules/ROOT/pages/`
- Name with number prefix: `01-introduction.adoc`, `02-next-step.adoc`, etc.
- Use proper AsciiDoc formatting:

```asciidoc
= Module Title

== Section Heading

Narrative text content goes here.

[source,bash,role=execute]
----
commands that users will run
----

[NOTE]
====
Important notes in callout boxes
====

[TIP]
====
Helpful tips
====

[IMPORTANT]
====
Critical warnings
====

[quote, Person Name]
____
Quotes for engagement or humor
____
```

### Script Requirements

**All scripts must:**
- Be bash scripts with `#!/bin/bash` shebang
- Be executable (`chmod +x`)
- Use `set -e` in setup scripts for early failure detection
- Exit with appropriate codes:
  - `exit 0` for success
  - `exit 1` for failure (validation scripts)

**Validation script pattern:**
```bash
#!/bin/bash
# Validate that objectives are met

if ! [condition]; then
    echo "FAIL: Clear description of what failed"
    echo "HINT: Suggestion for fixing it"
    exit 1
fi

echo "PASS: Description of success"
exit 0
```

## Creating New Labs

When asked to create a new lab:

1. **Create the directory structure** as shown above
2. **Use zt-filesystem-troubleshooting as the reference example** for correct configuration formats
3. **Create all required files:**
   - Configuration files (instances.yaml, networks.yaml, firewall.yaml)
   - Lab metadata (lab-metadata.yml)
   - Antora configs (antora.yml, site.yml, ui-config.yml)
   - Content files (AsciiDoc modules)
   - Setup automation scripts
   - Runtime automation scripts (setup/solve/validate per module)
4. **Make all scripts executable** with `chmod +x`

## Common Pitfalls to Avoid

❌ **DON'T:**
- Use `instances:` as top-level key (use `virtualmachines:`)
- Define a separate "root" disk (use `image_size:` instead)
- Try to add additional disks via `disks:` section (doesn't work reliably - increase `image_size` instead)
- Specify subnet/gateway/dhcp in networks.yaml
- Use `port:` and `path:` for terminal tabs (use `url: /wetty`)
- Forget the `AnsibleGroup: bastions` tag
- Forget `bootloader: efi`

✅ **DO:**
- Reference existing labs for patterns
- Use quoted strings for memory/size values
- Increase `image_size` if you need more disk space (e.g., "30G" instead of "20G")
- Keep networks.yaml minimal
- Make scripts executable
- Use clear pass/fail messages in validation scripts

## LVM and Storage Scenarios

If creating a lab that involves LVM expansion or disk management:

- **Use a single larger disk** with increased `image_size` (e.g., "30G")
- **Work within the existing root VG** - create small logical volumes and leave free space in the VG
- **Example approach**: For a 30GB disk, the system will use ~20GB, leaving ~10GB free in the VG for student exercises
- See `zt-filesystem-troubleshooting/setup-automation/setup-rhel.sh` for an example of creating a small LV with plenty of VG free space

## Reference Labs

- **zt-filesystem-troubleshooting** - Complete example with all correct patterns (created 2026-03-18)
  - Demonstrates single-disk LVM approach with VG free space for expansion exercises
- **zt-file-access-policy** - Good example of correct configuration
- **zt-openscap** - Another reference for proper structure

## Questions?

If uncertain about any pattern, check the reference labs mentioned above, particularly `zt-filesystem-troubleshooting` which demonstrates all current best practices.
