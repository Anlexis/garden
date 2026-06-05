---
title: AWS IAM mental model
description: How I keep IAM straight — principals, policies, evaluation order, and the boundary trick.
tags: [aws, security]
maturity: budding
created: 2026-05-28
modified: 2026-06-06
confidence: 3
publish: true
---
# AWS IAM mental model

> **Maturity:** 🌿 budding — solid enough to review PRs against, but I want to test it on more scenarios.
>
> **Confidence:** 3/5

## The four things that meet

Every IAM decision is the intersection of:

1. **Principal** — the *who*: an IAM user, role, or AWS service.
2. **Action** — the *what*: an API call (`s3:GetObject`).
3. **Resource** — the *which*: an ARN.
4. **Condition** — the *when/how*: source IP, tag, MFA, time of day.

## Policy types, ranked by how often I need them

- **Identity policies** — attached to a user/role. The default mental model.
- **Resource policies** — attached to a resource (S3 bucket, KMS key). Cross-account access lives here.
- **Permission boundaries** — a *ceiling* on what an identity *can* be granted, even if a wide identity policy is attached. The grown-up version of "least privilege."
- **SCPs** — Organizations-wide guardrails. Apply to the management account too.
- **Session policies** — passed inline when assuming a role.

## Evaluation order, simplified

1. **Explicit Deny anywhere → deny.** Always wins.
2. **No allow anywhere → deny by default.**
3. Then it's the intersection of identity policies AND boundary AND SCP AND (if applicable) resource policy. An allow has to survive all of them.

## The boundary trick

Attaching `AdministratorAccess` to a role *with* a permission boundary makes the boundary the actual ceiling. Same admin power for everyday use, but a bad role attach (or a hijacked CI principal) can't escalate beyond the boundary. Recorded in [[2026-06-03]] as a decision.

## See also
- [[Daily/2026-06-03|2026-06-03]] — the notes that crystallized this for me (SCPs apply to org root).
