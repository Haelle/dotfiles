# Implement plan

Implement plan defined in $1 (default: plan.md).
If you have strange failing tests not really related to the plan, just ignored them and keep tracks.
If you struggle with some features tests as well, try to fix them but do not block on them, if you consider to put wait within tests it is not the good way, just ignore them and keep tracks.
In the end, if there is any failing tests, just put them at the end of the plan with some explanations.

Rules :

- when plan have no steps :
  - do not stop until the plan is fully implemented and verified
- when plan have steps :
  - stop after writing tests for review (if working in TDD)
  - commit after writing the tests
  - stop after each steps avaiting for validation
  - commit after validation
