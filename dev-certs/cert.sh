#!/usr/bin/env sh

pwd="2FederateM0re"

ext=""
for product in access dataconsole datagovernance datasync directory federate federate-admin ; do
    ext="${ext}${ext:+,}dns:ping${product}"
done
    # service="ping${product}"
    alias="server-cert"
    file="dev-docker"
    jks="${file}.jks"
    p12="${file}.p12"
    cer="${file}.cer"
    pem="${file}.pem"
    keytool \
        -genkey \
        -keystore ${jks} \
        -alias ${alias} \
        -storepass ${pwd} \
        -keyalg  RSA \
        -keysize 4096 \
        -keypass ${pwd} \
        -validity 3650 \
        ${ext:+-ext SAN=}${ext}${ext:+,dns:localhost,ip:127.0.0.1} \
        -dname cn=dev,ou=docker,o=pingidentity,l=denver,st=co,c=us
    keytool \
        -importkeystore \
        -srckeystore ${jks} \
        -srcstorepass ${pwd} \
        -srcstoretype JKS \
        -destkeystore  ${p12} \
        -deststorepass ${pwd} \
        -deststoretype PKCS12
    keytool \
        -export \
        -keystore ${jks} \
        -storepass ${pwd} \
        -alias ${alias} \
        -file ${cer}
    keytool \
        -list \
        -rfc \
        -keystore ${jks} \
        -alias ${alias} \
        -storepass ${pwd} | openssl x509 -inform pem -pubkey -noout > ${pem}
# done