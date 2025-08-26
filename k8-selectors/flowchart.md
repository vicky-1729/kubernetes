```
Kubernetes Scheduling Rules – Quick Flow

1. Node Selector
   └─ Basic: Pod runs only on nodes with specific labels
   └─ Simple, exact match, no preferences

2. Node Affinity
   ├─ Hard Rule (requiredDuringSchedulingIgnoredDuringExecution)
   │   └─ Pod MUST run on matching node, else stays Pending
   ├─ Soft Rule (preferredDuringSchedulingIgnoredDuringExecution)
   │   └─ Pod PREFERS matching node, but can run elsewhere
   └─ Node Anti-Affinity
       └─ Pod MUST / PREFERS NOT to run on nodes with certain labels
       └─ Hard = strict, pod waits if no node available
       └─ Soft = preference, pod can still run if no other node available

3. Pod Affinity
   ├─ Hard Rule
   │   └─ Pod MUST run near pods with matching labels, else Pending
   └─ Soft Rule
       └─ Pod PREFERS to run near pods with matching labels, can run elsewhere
   └─ Use case: Reduce latency, keep pods together (e.g., app near DB)

4. Pod Anti-Affinity
   ├─ Hard Rule
   │   └─ Pod MUST avoid nodes with certain pods, else Pending
   └─ Soft Rule
       └─ Pod PREFERS to avoid nodes with certain pods, can run elsewhere
   └─ Use case: Spread replicas, improve high availability, avoid single-node failure

Extra Notes:
- Node Affinity / Anti-Affinity is **like advanced nodeSelector** with operators (In, NotIn, Exists, Gt, Lt)
- Pod Affinity / Anti-Affinity is **based on other pod labels**, not node labels
- Hard = strict, pod waits if condition not met
- Soft = preference, pod can still schedule if condition not met

```