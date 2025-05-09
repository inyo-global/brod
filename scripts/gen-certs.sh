#!/bin/bash

# Diretórios para armazenar os certificados
CERTS_DIR="./certs"
KEYSTORE_DIR="./certs"
TRUSTSTORE_DIR="./certs"

# Nomes dos arquivos
CA_KEY="ca.key"
CA_CERT="ca.crt"
KAFKA_KEY="kafka.keystore.key"
KAFKA_CERT="kafka.keystore.pem"
KAFKA_TRUSTSTORE="kafka.truststore.pem"

# Criar diretórios
mkdir -p $CERTS_DIR $KEYSTORE_DIR $TRUSTSTORE_DIR

echo "Generating CA private key..."
openssl genrsa -out $CERTS_DIR/$CA_KEY 2048

echo "Generating CA certificate CA..."
openssl req -x509 -new -nodes -key $CERTS_DIR/$CA_KEY -sha256 -days 3650 -out $CERTS_DIR/$CA_CERT -subj "/CN=Kafka-CA"

echo "Generating o Kafka private key..."
openssl genrsa -out $KEYSTORE_DIR/$KAFKA_KEY 2048

echo "Generating CSR (Certificate Signing Request) for Kafka..."
openssl req -new -key $KEYSTORE_DIR/$KAFKA_KEY -out $CERTS_DIR/kafka.csr -subj "/CN=Kafka-Broker"

echo "Signing Kafka cert with CA..."
openssl x509 -req -in $CERTS_DIR/kafka.csr -CA $CERTS_DIR/$CA_CERT -CAkey $CERTS_DIR/$CA_KEY -CAcreateserial -out $KEYSTORE_DIR/$KAFKA_CERT -days 365 -sha256

echo "Copying CA para o truststore..."
cp $CERTS_DIR/$CA_CERT $TRUSTSTORE_DIR/$KAFKA_TRUSTSTORE

echo "Certificados gerados com sucesso!"
echo "Arquivos:"
echo "  - Keystore Key: $KEYSTORE_DIR/$KAFKA_KEY"
echo "  - Keystore Cert: $KEYSTORE_DIR/$KAFKA_CERT"
echo "  - Truststore Cert: $TRUSTSTORE_DIR/$KAFKA_TRUSTSTORE"

rm  certs/ca.key certs/ca.crt certs/ca.srl certs/kafka.csr