#/bin/bash
systemCertificates=$(mktemp)
systemRootCertificates=$(mktemp)
security export -t certs -f pemseq -k /Library/Keychains/System.keychain -o "$systemCertificates" &> /dev/null
security export -t certs -f pemseq -k /System/Library/Keychains/SystemRootCertificates.keychain -o "$systemRootCertificates" &> /dev/null
cat "$systemCertificates" "$systemRootCertificates" >> ssl_certificates.pem
rm "$systemCertificates"
rm "$systemRootCertificates"
mv ssl_certificates.pem "$HOME/engine-room/secrets/ssl_certificates.pem"
