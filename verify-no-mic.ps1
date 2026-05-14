# Lifetime guardrail: the app must never access the microphone (TRUST-04, Art. 179bis StGB).
# Run this before every commit. Exits 1 on any match.
$found = Select-String -Path ".\index.html",".\spike\index.html" -Pattern "getUserMedia" -SimpleMatch
if ($found) {
  Write-Host "TRUST-04 violation: getUserMedia found in source."
  $found | ForEach-Object { Write-Host $_.Path ":" $_.LineNumber ":" $_.Line }
  exit 1
}
Write-Host "verify-no-mic: no matches. OK."
exit 0
