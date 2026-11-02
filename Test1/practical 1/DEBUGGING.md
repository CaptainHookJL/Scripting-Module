# Deliberate debugging exercise

Three small logic bugs were added after the validated solution in commit
`651d34a`. `answers.txt`, `session.log`, and `time.log` describe that earlier,
correct version; they are not validation results for these modified scripts.

- `accounts.sh` overcounts active accounts by one.
- `find_logs.sh` misses logs nested more than three levels below `exam-data`.
- `check_ip.sh` classifies exactly nine failed attempts as HIGH instead of MEDIUM.

The scripts remain syntactically valid. Restore the corresponding lines from
`651d34a` to return to the validated behavior.
