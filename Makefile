# Based on http://ejohn.org/blog/keeping-passwords-in-source-control/
# 
# John Resig needed a way to keep sensitive data (e.g. config files with
# passwords) out of source control. So he decided to encrypt the sensitive data.
#
# I decided to modify the script so it's purpose is quickly encrypting or
# decrypting any sensitive file you have on your computer.
#
# Usage: make encrypt
#        make decrypt

.PHONY: _pwd_prompt decrypt encrypt decrypt_conf encrypt_conf clean_encrypt clean_decrypt
 
FILE_DEC=conf/prod.casted5.json
FILE_ENC=conf/prod.json.cast5
 
_pwd_prompt:
	@echo "Contact the author for the password."

decrypt: decrypt_conf clean_decrypt

encrypt: encrypt_conf clean_encrypt

decrypt_conf: _pwd_prompt
	openssl cast5-cbc -d -in ${FILE_ENC} -out ${FILE_DEC}
	chmod 600 ${FILE_DEC}

encrypt_conf: _pwd_prompt
	openssl cast5-cbc -e -in ${FILE_DEC} -out ${FILE_ENC}

clean_encrypt:
	\rm ${FILE_DEC}

clean_decrypt:
	\rm ${FILE_ENC}