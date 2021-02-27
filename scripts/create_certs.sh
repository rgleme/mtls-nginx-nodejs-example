#!/usr/bin/env bash

echo -n "Enter path for certificates directory and press [ENTER]: "
read CERT_DIR
echo -n "Enter certificate authority (CA) name and press [ENTER]: "
read CA_NAME
echo

if [ -z "$CERT_DIR" ]
then
      echo "Please provide certificate directory"
      exit 1
fi

if [ -z "$CA_NAME" ]
then
      echo "Please provide CA name"
      exit 1
fi


if [ -d "$CERT_DIR" ]; then
  read -p "Are you sure you want overwrite certificates (if exist)? (y) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
      cd $CERT_DIR
  else
      exit 1
  fi
else
  mkdir $CERT_DIR && cd $_
fi


# Create a certificate authority (CA) that both the client and server trust. The CA is just a public and private key with the public key wrapped up in a self-signed X.509 certificate.
openssl req -x509 -newkey rsa:4096 -keyout ca.key -out ca.crt -nodes -days 365 -subj "/CN=$CA_NAME/O=Client\ Certificate\ Demo"
# Inspect ...
openssl x509 -in ca.crt -text -noout


# Create the server’s key and certificate; Create a Certificate Signing Request (CSR) with the Common Name (CN) localhost
openssl req -newkey rsa:4096 -keyout server.key -out server.csr -nodes -days 365 -subj "/CN=localhost"
# Using the CSR, the CA (really using the CA key and certificate) creates the signed certificate
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 365 -out server.crt
# Inspect ...
openssl x509 -in server.crt -text -noout


# Create the client’s key and certificate; Creating the CSR with the arbitrary Common Name of client
openssl req -newkey rsa:4096 -keyout client.key -out client.csr -nodes -days 365 -subj "/CN=client"
# Creating the client’s certificate
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 365 -out client.crt
# Inspect ...
openssl x509 -in client.crt -text -noout