#!/bin/bash

while getopts ":d:u:" opt; do
  case $opt in
    d)
      dir_to_encrypt="$OPTARG"
      ;;
    u)
      gpg_user="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z "$dir_to_encrypt" ] || [ -z "$gpg_user" ]; then
  echo "Usage: sudo $0 -d <directory> -u <gpg_user>"
  exit 1
fi

# Check if the directory exists
if [ ! -d "$dir_to_encrypt" ]; then
  echo "Error: Directory '$dir_to_encrypt' not found."
  exit 1
fi

# Create a temporary directory to store the encrypted files
temp_dir=$(mktemp -d)

# Generate a new GPG key pair
gpg --batch --gen-key <<EOF
%no-protection
Key-Type: default
Subkey-Type: default
Name-Real: New User
Name-Comment: with no passphrase
Name-Email: newuser@example.com
Expire-Date: 0
%commit
EOF

# Export the public key for the specified user
gpg --armor --output "$temp_dir/public_key.asc" --export "$gpg_user"

# Archive and compress the directory
tar czf "$temp_dir/encrypted.tar.gz" -C "$(dirname "$dir_to_encrypt")" "$(basename "$dir_to_encrypt")"

# Encrypt the archive using the newly generated key
gpg --output "$temp_dir/encrypted.tar.gz.gpg" --encrypt --recipient "$gpg_user" --trust-model always "$temp_dir/encrypted.tar.gz"

# Remove the original archive
rm "$temp_dir/encrypted.tar.gz"

# Move the encrypted file to the original directory
mv "$temp_dir/encrypted.tar.gz.gpg" "$(dirname "$dir_to_encrypt")"

# Clean up temporary directory
rm -rf "$temp_dir"

# Remove all files from the original directory
rm -r "$dir_to_encrypt"/*

echo "Directory '$dir_to_encrypt' encrypted successfully."

