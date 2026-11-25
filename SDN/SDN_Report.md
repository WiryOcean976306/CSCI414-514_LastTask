# Software-Defined Networking (SDN)
## CSCI 414/514 – Final Task

**Component:** Software-Defined Network Policy Control
**Technology:** Open vSwitch (OVS) and OpenFlow 1.3

### 1. Project Objective

The Multiplayer State Network platform already included application services, distributed storage, security controls, and monitoring capabilities. The purpose of the SDN extension was to add centralized network-policy control to the Multiplayer State Network platform. A dedicated SDN Controller component was developed to manage OpenFlow forwarding rules independently from application services and firewall enforcement. Rather than embedding network decisions within containers or firewall rules, the SDN layer provides a centralized mechanism for controlling traffic behavior through OpenFlow policies. Within the final architecture, SDN serves as the policy-management layer while the NFV firewall serves as the policy-enforcement layer.

### 2. SDN Design Overview

The SDN implementation consists of a dedicated SDN Controller service deployed alongside the existing project infrastructure. The controller uses Open vSwitch (OVS) and OpenFlow 1.3 to manage forwarding policies through programmable flow tables. A policy configuration file is used to define allowed and denied communication paths within the platform. Unlike static network configurations, policies can be modified dynamically while services remain operational.

### 3. Open vSwitch Configuration

After installing Open vSwitch, a bridge named br0 was created and OpenFlow 1.3 was assigned as a protocol.

```
sudo ovs-vsctl add-br br0

sudo ovs-vsctl set bridge br0 protocols=OpenFlow13
```

Network policies are defined within a JSON configuration file:

```
{
    "client_api": "allow",
    "api_redis": "allow",
    "client_redis": "deny"
}
```

This created an empty flow table with no custom forwarding policies. Policies are applied through the SDN Controller using:

```
./sdn/apply_policy.sh
```

All current policies can be viewed using this command:

```
./sdn/show_policy.sh
```

Policies can be removed by using this command:

```
./sdn/remove_policy.sh
```

### 4. Testing

The following tests were performed:

**Test 1: OpenFlow Enablement**

Verify communication between Open vSwitch and the OpenFlow subsystem.

Result: PASS. OpenFlow 1.3 was successfully enabled.

**Test 2: SDN Policy Deployment**

Confirm that forwarding policies can be installed dynamically.

Result: PASS. The SDN Controller successfully deployed multiple network policies from the policy configuration file. OpenFlow verification confirmed that allow and deny rules were installed correctly.

**Test 3: Flow Rule Removal**

Verify that policies can be removed without affecting system availability.

Result: PASS. The policies were removed and the switch returned to its baseline configuration.

**Test 4: Application Availability**

Ensure that SDN configuration changes did not affect platform stability.

Result: PASS. The application platform remained operational throughout SDN deployment and recovery testing.

### 6. Evidence

The following screenshots document the SDN implementation and testing:

1. `01_SDN_OVS_Installation.png` – Verification that Open vSwitch 3.7.1 was successfully installed.

2. `02_SDN_Bridge_Creation.png` – Open vSwitch bridge (br0) successfully created and displayed in the switch configuration.

3. `03_SDN_OpenFlow13_Enabled.png` – Verification that the bridge was configured to use the OpenFlow 1.3 protocol.

4. `04_SDN_Initial_Flow_Table.png` – Baseline OpenFlow flow table before any custom SDN policies were installed.

5. `05_SDN_Policy_Deployment.png` – Installation of a dynamic forwarding policy using OpenFlow commands.

6. `06_SDN_Policy_Display.png` – Displays the current OpenFlow policy.

7. `07_SDN_Policy_Removal.png` – Removal of the OpenFlow policy and restoration of the switch to its original state.
