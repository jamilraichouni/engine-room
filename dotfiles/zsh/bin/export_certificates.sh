#/bin/bash
systemCertificates=$(mktemp)
systemRootCertificates=$(mktemp)
security export -t certs -f pemseq -k /Library/Keychains/System.keychain -o "$systemCertificates" &> /dev/null
security export -t certs -f pemseq -k /System/Library/Keychains/SystemRootCertificates.keychain -o "$systemRootCertificates" &> /dev/null
cat "$systemCertificates" "$systemRootCertificates" >> .allCAbundle.pem
rm "$systemCertificates"
rm "$systemRootCertificates"
