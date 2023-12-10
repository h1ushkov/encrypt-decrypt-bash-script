      #!/bin/bash

while getopts ":d:k:" opt; do
  case $opt in
    d)
      dir_to_decrypt="$OPTARG"
      ;;
    k)
      encrypted_file="$OPTARG"
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

if [ -z "$dir_to_decrypt" ] || [ -z "$encrypted_file" ]; then
  echo "Usage: sudo $0 -d <directory> -k <encrypted_file>"
  exit 1
fi

# Check if the directory exists
if [ ! -d "$dir_to_decrypt" ]; then
  echo "Error: Directory '$dir_to_decrypt' not found."
  exit 1
fi

# Check if the encrypted file exists
if [ ! -f "$encrypted_file" ]; then
  echo "Error: Encrypted file '$encrypted_file' not found."
  exit 1
fi

# Create a temporary directory to store the decrypted files
temp_dir=$(mktemp -d)

# Decrypt the GPG encrypted file
gpg --batch --yes --output "$temp_dir/decrypted.tar.gz" --decrypt "$encrypted_file"

# Extract the decrypted archive
tar xzf "$temp_dir/decrypted.tar.gz" -C "$(dirname "$dir_to_decrypt")"

# Remove the decrypted archive
rm "$temp_dir/decrypted.tar.gz"

# Clean up temporary directory
rmdir "$temp_dir"

echo "Directory '$dir_to_decrypt' decrypted successfully."

